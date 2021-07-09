#delimit;
					 /*
capture program drop single;
capture program drop dsingle;
program single, plugin;
program dsingle, plugin;
  					   */
program define single;
version 10.1;
	syntax varlist(numeric min = 2) [if] [, h(real 0.2)];		

	global vars_single = "";
	global h = `h';
	local y = "`1'";
	local age = "`2'";		 
	local i = 1;
	local k = wordcount("`varlist'")-1;
	local knew : list sizeof varlist;
	local knew = `knew' - 1;
	
	global vars_single1 `varlist';
	  
	local hulp1 = word("$vars_single1", 1);
	global vars_single2 : list global(vars_single1) - local(hulp1);
	
	local y = word("`varlist'", 1);

	
	quietly probit `y' $vars_single2;
	
	local names : colfullnames e(b);

	global vars_single2 `names';
	local const = "_cons";
	global vars_single2 : list global(vars_single2) - local(const);
	local knew1 : list sizeof global(vars_single2);
	
	matrix b1_prob = e(b);
	local b1 = b1_prob[1,1];
	local b0 = b1_prob[1,colsof(b1_prob)];
	
	constraint 1 `age' = `b1';
	constraint 2 _cons = `b0';

	ml model d1 mynormal1 (`y' = $vars_single2), constraint(1 2);
	lik_init `knew1';
	
	ml maximize, repeat(50) iterate(100) nonrtolerance nooutput;

	matrix b = e(b);

	tempvar mu;
	tempvar fh;
	tempvar rh;
	tempvar mh;
	tempvar jh;
	tempvar h1;
	tempvar hulp;
	
	g double `fh' = 1;
	g double `rh' = 1;
	g double `mh' = 1;
	g double `jh' = 1;
	g double `h1' = $h;
	g double `hulp' = 1;
	g double `mu' = 0;

	
	xb `knew1' `mu';

	capture program drop single;
	program single, plugin;
	  
	plugin call single `mu' `y' `h1' `mh' `rh' `fh' `jh';

	matrix gamma = b';

	tempvar gamma;
	quietly g `gamma' = .;
	local i = 0;
	while (`i' <= `knew') {;
		local i = `i' + 1;
		local hulp10 = el(gamma, `i', 1);
		quietly replace `gamma' = `hulp10' in `i';
	};
	
	local i = 0;
	local vars_rh1 = "";
	local vars_rh2 = "";

	local knew : list sizeof global(vars_single2);

	
	while (`i' <= `knew') {;
		local i = `i'+1;
		tempvar rh1_`i';
		tempvar rh2_`i';
		g double `rh1_`i'' = 0;
		g double `rh2_`i'' = 0;
		local vars_rh1 `vars_rh1' `rh1_`i'';
		local vars_rh2 `vars_rh2' `rh2_`i'';
	};
	
	capture program drop dsingle;
	program dsingle, plugin;

	
	plugin call dsingle `h1' `gamma' `y' `mu' $vars_single2 `hulp' `vars_rh1' `vars_rh2';

	local i = 0;
	
	while (`i' <= `knew') {;
		local i = `i'+1;
		tempvar dg_`i';
		tempvar dg1_`i';
		g double `dg_`i'' = 0;
		g double `dg1_`i'' = 0;			   
		local vars_dg `vars_dg' `dg_`i'';	 
		local vars_dg1 `vars_dg1' `dg1_`i'';
	};
	
	make_dg `knew1' `h1' `y' `fh' `rh' `mh' `vars_rh1' `vars_rh2' `vars_dg' `vars_dg1';

	bereken_c_d `knew1' `vars_dg' `vars_dg1';

	matrix hulp = inv(c);
	matrix cov = inv(c)' * d * inv(c);
	
	bereken_cov2 `knew';

	tempvar hulp1;

	g double `hulp1' = (`y' - `mh')^2;
			  
	quietly sum `hulp1';				  
				   
	local n = r(N);
	local lnf = r(mean);
	
	ml clear;
	
	ml model d0 cnsprobit (`y' = $vars_single2), constraint(1 2);
	lik_init `knew1';
	quietly ml maximize, iterate(1);
	
	matrix dV = V - e(V);
	matrix db = b - e(b);
	matrix n2 = rowsof(dV);
	local n2 = n2[1,1] - 1;
	matrix dV1 = dV[2..`n2',2..`n2'];
	matrix db1 = db[1,2..`n2'];
	matrix haus = db1 * inv(dV1) * db1';
	local haus = abs(haus[1,1]);

	display "";
	display "Single-index estimation                             Number of obs     =   " `n';
	display "";
	display "Mean squared error  = " %7.4f `lnf';
	display "Hausman test        = " %7.4f `haus';
	display "";
	
	capture program drop dsingle;
	capture program drop single;
	  
	ereturn post b V;
	ereturn display;

end;
			 
program define lik_init;
	local k = `1';
	local i = 0;
	local vars_single_hulp "$vars_single2";

	while (`i' < `k') {;
		local i = `i' + 1;
		local hulp1 = word("`vars_single_hulp'",1);
		local vars_single_hulp1 : list local(vars_single_hulp) - local(hulp1);
		local vars_single_hulp "`vars_single_hulp1'";
		local b_1 = b1_prob[1,`i'];
		ml init "`hulp1'" = `b_1';
	};
	local b_1 = b1_prob[1,`k'+1];
	ml init _cons = `b_1';
end;		   

program define bereken_cov2;
	local k = `1';

	matrix hulp = J(1,`k'-1,0);
	matrix cov1 = hulp \ cov;
	matrix hulp = J(1,`k',0);
	matrix hulp = hulp';
	matrix cov2 = hulp, cov1;
	matrix hulp = J(1,`k',0);
	matrix cov2 = cov2 \ hulp;
	matrix hulp = J(1,`k'+1,0);
	matrix hulp = hulp';
	matrix cov2 = cov2, hulp;
	matrix V = e(V);
	matrix b = e(b);

	local i=1;

	local k2 = rowsof(cov2);

	while (`i' < `k2') {;
		local i = `i' + 1;
		local j = 1;
		while (`j' < `k2') {;
			local j = `j' + 1;
			matrix V[`i',`j'] = cov2[`i',`j'];
			if (`i' == `j'){;
				if (cov2[`i', `i'] < 0){;
					matrix V[`i',`j'] = -cov2[`i',`j'];
				};
			};
		};
	};
end;

program define bereken_c_d;
	local k = `1';

	local i = 0;
	local k1 = `k'+1;
	while (`i' <= `k') {;
		local i = `i' + 1;
		local hulp2 = 1 + `i';
		local hulp3 = 1 + `k1' + `i';

		local dg_`i' = "``hulp2''";
		local dg1_`i' = "``hulp3''";
	};
	
	local i = 1;

	tempvar hulp10;
	tempvar hulp11;

	g double `hulp10' = 0;
	g double `hulp11' = 0;
	
	while (`i' <= `k'-1){;
		local i = `i' + 1;
		local j = 1;
		while (`j' <= `k'-1) {;
			local j = `j' + 1;
			quietly replace `hulp10' = `dg_`i'' * `dg_`j'';
			quietly sum `hulp10';
			matrix hulp10 = r(sum);

			quietly replace `hulp11' = `dg1_`i'' * `dg1_`j'';
			quietly sum `hulp11';
			matrix hulp11 = r(sum);
		
			if (`j' == 2) {;
				matrix hulp = hulp10;
				matrix hulp1 = hulp11;
			};
			else {;
				matrix hulp = hulp, hulp10;
				matrix hulp1 = hulp1, hulp11;
			};
		};


		if (`i' == 2) {;
			matrix c = hulp;
			matrix d = hulp1;
		};
		else {;
			matrix c = c \ hulp;
			matrix d = d \ hulp1;
		};
	};
end;

program define make_dg;
	local h = `2';
	local fh = "`4'";
	local rh = "`5'";
	local mh = "`6'";
	local d = "`3'";	
	local k = `1';

	local i = 0;
	local k1 = `k'+1;
	
	while (`i' <= `k') {;
		local i = `i' + 1;
		local hulp = 6 + `i';
		local hulp1 = 6 + `k1' + `i';
		local hulp2 = 6 + 2 * `k1' + `i';
		local hulp3 = 6 + 3 * `k1' + `i';

		local rh1_`i' = "``hulp''";
		local rh2_`i' = "``hulp1''";
		local dg_`i' = "``hulp2''";
		local dg1_`i' = "``hulp3''";
	};

	local i = 0;
	tempvar dm;
	g double `dm' = 0;

	while (`i' <= `k') {;
		local i = `i' + 1;
		
		quietly replace `dm' = (1 / `h') * (`rh1_`i'' * `fh' - `rh2_`i'' * `rh')
					/ (`fh' * `fh');

		quietly replace `dg1_`i'' = `dm' * (`d'-`mh');
		quietly replace `dg_`i'' = `dm';
	};
end;

program define xb;
	local i=0;
	local k = `1';
	local mu = "`2'";
	quietly replace `mu' = 0;

	tempvar hulp2;
	g double `hulp2' = 0;
	local vars_single_hulp "$vars_single2";
	
	while (`i' < `k') {;
		local i = `i' + 1;
		local hulp1 = word("`vars_single_hulp'",1);
		local vars_single_hulp1 : list local(vars_single_hulp) - local(hulp1);
		local vars_single_hulp "`vars_single_hulp1'";
		
		quietly replace `hulp2' = `hulp1';
		quietly replace `mu' = `mu' + `hulp2' * b[1,`i'];
	};
	sort `mu';
end; 
*/

exit;

 


	