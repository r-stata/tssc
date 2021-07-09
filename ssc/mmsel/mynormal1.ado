#delimit;
capture program drop single;
capture program drop dsingle;
program single, plugin;
program dsingle, plugin;

program define mynormal1;
	version 8.1;
	args todo b lnf g negH g1 g2;

	tempvar fh;
	tempvar rh;
	tempvar mh;
	tempvar jh;
	tempvar h;

	gen double `fh' = 1;
	gen double `rh' = 1;
	gen double `mh' = 1;
	gen double `jh' = 1;
	gen double `h' = $h;
	tempvar mu;
	
	mleval `mu' = `b';

	sort `mu';
	
	plugin call single `mu' $ML_y1 `h' `mh' `rh' `fh' `jh';
	/*	 
	quietly {;*/
		quietly sum $ML_y1;
		local n = r(N);/*
		display -($ML_y1 - `mh')^2 / `n';*/
		mlsum `lnf' = -($ML_y1 - `mh')^2 / `n';


		if (`todo'==0 | `lnf' >= .) exit;

		local k : list sizeof global(ML_x1);
		matrix b1 = `b';
		matrix b1 = b1';

		tempvar gamma;
		quietly g `gamma' = .;
		local i = 0;
		while (`i' <= `k') {;
			local i = `i' + 1;
			local hulp = el(b1, `i', 1);
			quietly replace `gamma' = `hulp' in `i';
		};
						 
		tempvar hulp_c;
		g `hulp_c' = 1;
		local i = 0;
		
		while (`i' <= `k') {;
			local i = `i'+1;
			tempvar rh1_`i';
			tempvar rh2_`i';
			g double `rh1_`i'' = 0;
			g double `rh2_`i'' = 0;
			local vars_rh1 `vars_rh1' `rh1_`i'';
			local vars_rh2 `vars_rh2' `rh2_`i'';
		};
		
		plugin call dsingle `h' `gamma' $ML_y1 `mu' $ML_x1 `hulp_c' `vars_rh1' `vars_rh2';
		
		tempvar hulp2;
		tempvar hulp3;
		tempvar dm;

		g double `hulp2' = 0;
		g double `hulp3' = 0;
		g double `dm' = 0;
		
		local i = 0;
		while (`i' <= `k') {;
			local i = `i'+1;
			quietly replace `dm' = (1 / `h') * (`rh1_`i'' * `fh' - `rh2_`i'' * `rh')
					/ (`fh' * `fh');
			
			quietly replace `hulp2' = `dm' * `mh';
			quietly replace `hulp3' = $ML_y1 * `dm';
	
			quietly sum `hulp2';
			local hulp = r(sum);
			quietly sum `hulp3';
			local hulp1 = r(sum);

			local hulp5 = (- 2 * `hulp' + 2 * `hulp1')  / `n';
			if (`i' == 1) {;
				matrix result = `hulp5';
			};
			else {;
				matrix result = result, `hulp5' ;
			};

		};		

		matrix `g' = (result);
				/*
	};			  */
end;
