#delimit;
capture program drop machado_sel;
capture program drop mach;
mata mata clear;

mata;


real rowvector mean(real matrix X, real colvector w)
{
        real rowvector  CP
        real scalar     n 

        CP = quadcross(w,0, X,1)
        n  = cols(CP)
        return(CP[|1\n-1|] :/ CP[n])
}

real matrix variance(real matrix X, real colvector w)
{
        real rowvector  CP
        real rowvector  means
        real scalar     n 

        CP = quadcross(w,0, X,1)
        n  = cols(CP)
        means = CP[|1\n-1|] :/ CP[n]
        return(crossdev(X,0,means, w, X,0,means) :/ (CP[n]-1))
}

numeric scalar quantile(numeric x, numeric scalar q)
{
	numeric matrix hulp1;
	numeric scalar n, hulp2;
	
	hulp1 = sort(x,1);
	n = rows(x);
	hulp2 = trunc(n * q);

	return (hulp1[hulp2,.]);
}

transmorphic matrix sort(transmorphic matrix x, real rowvector idx)
{
        return(x[order(x,idx), .])
}


numeric matrix bereken_var2(numeric matrix q, numeric matrix theta, numeric matrix theta1,
			numeric matrix yb, numeric matrix y1a, numeric scalar m) {;
	real matrix var2;
	real scalar n2, i, f1b;

	n2 = rows(yb);
	
	for(i=1;i<=rows(theta);i++)
	{
		f1b = kerncv2(yb,theta1[i],0);
		if (i == 1)
		{	
			var2 = (((m/n2) * q[i]*(1-q[i]))/(f1b^2));
		}
		else
		{	
			var2 = var2 \ (((m/n2) * q[i]*(1-q[i]))/(f1b^2));
		}
	}
	
	return (var2);
};

numeric scalar quanc1(numeric matrix x, numeric scalar q, numeric matrix s)
{
	real matrix s1, hulp, x1;
	real scalar n, i, hulp2, hulp3;
		   
	s1 = s :/ mean(s, 1);

	hulp = x, s1;	
	hulp = sort(hulp,1);
	
	x1 = hulp[.,1];
	s1 = hulp[.,2];
	n = rows(s1);
	i = 0;
	hulp2 = 0;
	hulp2a = 0;

	while(i < rows(s1))
	{
		i = i + 1;
		hulp2 = hulp2 + s1[i];		
		hulp2a = hulp2a \ hulp2;		
	}
	
	hulp3 = mean(hulp2a :<= J(rows(hulp2a),1,q * n),1) * rows(hulp2a);

	if (hulp3 > 1)
		return (x1[hulp3,.]);
	else {
		if (s1[1] == .)
			return (.);
		else
			return (x1[hulp3,.]);
	}
}

numeric matrix kerncv2(numeric matrix y, numeric scalar theta, numeric scalar h)
{
	real matrix V;
	real scalar h1, n, c;

	n=rows(y);
	c = sqrt(variance(y,1)) * 1.1;
	
	if (h == 0) {
		h1=(n^(-0.2))*c;
	}
	else {
		h1 = h;
	}
	
	V=(1/(h1)):*(normalden((theta * J(rows(y),1,1) - y):/h1));

	return(mean(V,1));
}

numeric matrix variance_machmat(numeric matrix q, numeric matrix gamma,
				numeric scalar b0, numeric scalar b1, numeric matrix y, numeric matrix  x1,
						numeric matrix x2, 
			numeric scalar l, numeric scalar c, numeric scalar ba,
			numeric matrix cov_step1, numeric scalar m, numeric matrix beta, numeric matrix u,
			numeric matrix y1a,
			numeric matrix x1b, numeric matrix theta,
			numeric matrix y1, numeric matrix x1a, numeric matrix x2a,
			numeric matrix s1)
/*	function for the calculation of the standard erros of the Machado and Matta technique with
	sample selection as in Albrecht, Van Vuuren and Vroman, 2004.

	In :	q		- 	range of quantile-levels to be computed (in range 0-1) - k x 1 vector
			gamma	- 	estimates of the first stage, exluding normalized coefficients
			b0 		- 	normalized constant in first stage
			b1 		- 	normalized regressor of continuous coefficient in first stage
			y		-	left hand side variable. Observations that are missing
						should be NaN.
			x1		-	right hand side variable of the first stage, including instruments
						and constant (in first column).
			x2 		-	right hand side variable of the second stage, excluding instruments
						but also with observations of those individuals that do
						not have an observed lhs.
			m 		- 	number of repetitions of the MM-method
			theta	- 	function value obtained from function machado()
			beta	-	computed levels of quantile regression at u1 (size: m x 1).
			u		-	levels at which quantile regressions ar estimated (size: m x 1)
			y1a		-	estimated levels for Machado and Mata method (size: m x 1)
			x1b		-	sampled x's for Machado and Mata method (size: m x k); k = columns of x2
			
	Out	:	function value	=	k x 1 vector containing the quantiles using the MM-method
								computed at the levels of q.

	WARNING: Unfortunately I was not able to speed this procedure a bit more. It can take
				quite a while even with moderate levels of m and sample size.
*/
{
	numeric scalar n, n1, j1, j2;
	numeric matrix var_hulp;
	
	n = rows(y);
	n1 = rows(y1a);	
	
	var_hulp = J(cols(beta)-l,cols(beta)-l,0);

	hulp_x = x1a[.,1..cols(x1a)-1];
	hulp_gamma = b1 \ gamma;
	z = hulp_x * hulp_gamma;

	hulp_nd = normalden(-z);
	hulp_nd1 = (J(rows(z),1,1)-normal(-z));
	lambda = hulp_nd :/  hulp_nd1;

	vlambda = lambda;
	
	for (i=2;i<=l;i++)
	{
		i1 = J(rows(lambda),1,i);
		vlambda = vlambda, (lambda:^i1);
	}

	x3 = x2a[.,1..cols(x2a)-1], vlambda, x2a[.,cols(x2a)];
	psi1 = x3' * x3;
	n2 = J(rows(psi1), cols(psi1), 1 / rows(x1a));
	psi1 = n2 :* psi1;
	
	dlambda = lambda:^2 - lambda :* z;
	lambda1 = mean(s1:^2, 1);
	
	for(j1=1;j1<=m;j1++) {;
		j1;
		bhat1 = beta[j1,.]';
		m1 = kerncv3(x3,y1,bhat1);
		delta1 = bhat1[rows(bhat1)-cols(vlambda)..rows(bhat1)-1];
		v11 = y1 - x3 * bhat1;
		v21 = y1 - x2a[.,2..cols(x2a)] * bhat1[2..rows(bhat1)-cols(vlambda)];
		q1 = u[j1];
		mu21 = quanc1(v21, q1 ,s1);
		v31 = v21 - J(rows(v21),1,mu21);
		lambda21 = berekenlambda2(z, s1, v31);

		for(j2=j1+1;j2<=m;j2++) {;												  
			cov1 = J(cols(beta)-l, cols(beta)-l,n1) :* compute_cov1(gamma, b0, b1,
								y1,x1a,x2a,l,c,ba,beta[j1,.]', beta[j2,.]', u[j1],  u[j2],
								n, cov_step1, s1, z, lambda, vlambda, x3, psi1, m1, dlambda, delta1,
								lambda1, v11, v21, mu21, lambda21, n2);
			var_hulp = var_hulp + cov1 + cov1;
		};
		
	};
							   
	for(j=1;j<=m;j++)
	{
		bhat1 = beta[j,.]';
		m1 = kerncv3(x3,y1,bhat1);
		delta1 = bhat1[rows(bhat1)-cols(vlambda)..rows(bhat1)-1];
		v11 = y1 - x3 * bhat1;
		v21 = y1 - x2a[.,2..cols(x2a)] * bhat1[2..rows(bhat1)-cols(vlambda)];
		q1 = u[j];
		mu21 = quanc1(v21, q1 ,s1);
		v31 = v21 - J(rows(v21),1,mu21);
		lambda21 = berekenlambda2(z, s1, v31);
		cov1 = J(cols(beta)-l, cols(beta)-l,n1) :* compute_cov1(gamma, b0, b1,
								y1,x1a,x2a,l,c,ba,beta[j,.]', beta[j,.]', u[j],  u[j],
								n, cov_step1, s1, z, lambda, vlambda, x3, psi1, m1, dlambda, delta1,
								lambda1, v11, v21, mu21, lambda21, n2);
		var_hulp = var_hulp + cov1;
	}

	hulp2 = J(rows(y1a),1,1);
	for(i=1;i<=rows(theta);i++)
	{
		c = quantile(y1a,0.75)-quantile(y1a,0.25)
		h1 =(n^(-0.4))*c;
		V = (1/(h1))*(normalden((theta[i] * hulp2 - y1a)/h1));
		V = V :* J(rows(V),cols(x1b),1);
		hulp = x1b :* V;
		if (i==1){
			var10 = mean(hulp, 1);
		}
		else {
			var10 = var10 \ mean(hulp, 1);			
		}
	}
	
	var_hulp = (var_hulp) :/ (m^2);
	
	
	for(i=1;i<=rows(q);i++)
	{
		f1a = kerncv2(y1a,theta[i],0);
		hulp1 = var10[i,.] * var_hulp * var10[i,.]';
		if (i == 1)
		{
			var1 = (((m / n) * q[i]*(1-q[i]) + (m / n1) * hulp1) / (f1a^2));
		}
		else
		{
			var1 = var1 \ (((m / n) * q[i]*(1-q[i]) + (m / n1) * hulp1) / (f1a^2));
		}
	}

	return (sqrt(var1 / m));	 
}

numeric matrix berekenlambda2(numeric matrix z, numeric matrix s1, numeric matrix v)
{
	numeric matrix sigma, f;
	numeric scalar h, n;
	
	n = rows(v);
	sigma = sqrt(variance(v,1));
	h = 1.06 :* sigma * n:^(-0.2);
	arg = v :/ h;
	
	f = ((1 / (h)) :* normalden(arg));
	return (mean(f :* s1, 1));	
}

numeric matrix kerncv3(numeric matrix X, numeric matrix y, numeric matrix bhat){
	real scalar c, h;
	real matrix V;

	r= y - X * bhat;

	n=rows(X);

	c = quantile(r,0.75)-quantile(r,0.25);
	h=(n^-(0.2))*c;

	V= (normalden(r/h):*X)'*X;
	nh = J(rows(V),cols(V),1 / (n*h)); 
	V = invsym(V) :* nh;

	return(V);
}

numeric matrix compute_cov1(numeric matrix gamma, numeric scalar b0,
				numeric scalar b1, numeric matrix w, numeric matrix x,
				numeric matrix x1, numeric scalar l, numeric scalar c, numeric scalar ba,
					numeric matrix bhat1, numeric matrix bhat2,
					numeric scalar q1, numeric scalar q2, numeric scalar n,
					numeric matrix cov, numeric matrix s1, numeric matrix z, numeric matrix lambda, numeric matrix vlambda,
					numeric matrix x3, numeric matrix psi1, numeric matrix m1, numeric matrix dlambda,
					numeric matrix delta1, numeric matrix lambda1, numeric matrix v11, numeric matrix v21,
					numeric scalar mu21, numeric matrix lambda21, numeric matrix n2)
{
/* Computes variance as in Albrecht, Van Vuuren and Vroman, 2004 for off-diagonal elements
	In:
	q1		- 	level of quantile for row of the off-diagonal element
	q2		-	level of quantile for column of the off-diagonal element (q1 < q2)
	bhat1	-	estimate as returned from compute_regression
	Other inputs are the same as in  compute_regression
	Out:
	function value =	covariance matrix of quantile regression. Thes size is the same as
						the number of columns contained in x1

	*/
	numeric matrix y, delta2, v12, v22, hulp_gamma,
							hulp_x, hulp_nd, hulp_nd1, i1, hulp11, hulp21,
							m2, j, psi2, psi;
	numeric scalar i, mu22, smu2, q3, k;


	y = w;

	delta2 = bhat2[rows(bhat2)-cols(vlambda)..rows(bhat2)-1];


	v12 = y - x3 * bhat2;
	v22 = y - x1[.,2..cols(x1)] * bhat2[2..rows(bhat1)-cols(vlambda)];
	
	n1 = rows(x);
	
	mu22 = quanc1(v22, q2 ,s1);
	
	v32 = v22 - J(rows(v22),1,mu22);

	lambda22 = berekenlambda2(z, s1, v32);

	smu2 = sqrt((lambda1 / (lambda21 * lambda22)) * q1 * (1-q2) / n);

	hulp11 = J(rows(lambda),1,0);
	hulp21 = hulp11;
	
	for(i=1;i<=cols(vlambda);i++)
	{
		i1 = J(rows(lambda),1,i-1);
		i2 = J(rows(lambda),1,i);
		hulp11 = hulp11 + J(rows(lambda),1,delta1[i]) :* dlambda :* (lambda:^(i1)) :* i2;
		hulp21 = hulp21 + J(rows(lambda),1,delta2[i]) :* dlambda :* (lambda:^(i1)) :* i2;
	}
	
	
	m2 = kerncv3(x3,y,bhat2);

	q3 = J(rows(psi1), cols(psi1), q1 * (1-q2));
	psi1 = q3 :* psi1;
	psi2 = bereken_psi2b(v11, v12, x[.,2..cols(x)-1], x3, hulp11, hulp21, cov);
	  
	psi = psi1 + (n1 / n) * psi2;
	
	cov1 = (m1 * psi * m2) :* n2;
	k = cols(x1);
	
	return (cov1[1..k, 1..k]);
}

numeric matrix bereken_psi2b(numeric matrix z1, numeric matrix z2,
				numeric matrix x1, numeric matrix x2, numeric matrix hulp1,
				numeric matrix hulp2, numeric matrix cov)
{
	numeric matrix psi2, arg1, arg2, f1, f2, hulpa, hulpd;
	numeric scalar i, h1, h2, c1, c2, n;
	
	r1 = z1;
	r2 = z2;

	n = rows(r1);

	c1 = sqrt(variance(r1,1)) * 1.1;
	c2 = sqrt(variance(r2,1)) * 1.1;

	h1=(n^-(0.4))*c1;
	h2=(n^-(0.4))*c2;
	
	arg1 = z1 / h1;
	arg2 = z2 / h2;

	f1 = (1 / h1) * normalden(arg1);
	f2 = (1 / h1) * normalden(arg2);

	
	hulp3 = f1 :* x2;
	hulp4 = f2 :* x2;
	
	xb1 = x1 :* hulp1;
	xb2 = x1 :* hulp2;
	
	k1 = cols(x2);
	
	for(j=1;j<=k1;j++)
	{
		if (j == 1)											   
		{
			hulp_1 = (xb2 :* (hulp4[.,j]))';
			hulp_2 = mean((cov * hulp_1)',1)';
			hulpa = hulp_2';
		}
		else
		{
			hulp_1 = (xb2 :* (hulp4[.,j]))';
			hulp_2 = mean((cov * hulp_1)',1)';
			hulpa = hulpa \ hulp_2';
		}
	}
	
	
	for(i=1;i<=k1;i++)
	{
		hulpd = mean(((hulp3[.,i]) :* xb1), 1);
		
		if (i == 1)
		{
			psi2 = (hulpd * hulpa');
		}
		else
		{
			psi2 = psi2 \ (hulpd * hulpa');
		} 
	}

	return (psi2);
}

end;

program buchinsky, eclass;
	version 9.0;
	syntax varlist(numeric) [if] , gender(varlist min=1 max=1)  select(varlist) [, m(int 100)] [, q(int 9)]
					[, l(int 2)] [, method(int 1)]
					[, variance(int 1)] [, ba(real 0.8)] [, c(real 0.2)]
					[, display(int 1)];


	tempfile hulp_file_overall;
	quietly save `hulp_file_overall', replace;
	
	local n = `m';
	
	if (`method' > 6) {;
		local method = 1;
	};

	if (`method' < 0) {;
		local method = 1;
	};

	mata uniformseed("Xc644806e61911463d1cc0e3d7be41beb01ba");
	
	mata hulp_u = uniform(`n',1) * 0.9998 + J(`n', 1, 0.0001);
	mata hulp_u = sort(hulp_u,1);
								 
	local vars3_hulp = "`varlist'";
	local i = 0;
	local k_hulp : list sizeof varlist;
	
	while (`i' < `k_hulp') {;
		local i = `i'+ 1;

		tempvar hulp_x;
		local name_x = word("`vars3_hulp'",1);
		
		quietly g `hulp_x' = `name_x';
		
		local vars3_hulp1 : list local(vars3_hulp) - local(name_x);
		local vars3_hulp "`vars3_hulp1'";

		if (`i' > 1) {;
			quietly drop if missing(`hulp_x');
		};
	};
								 
	local k_hulp : list sizeof select;
	local vars3_hulp = "`select'";

	local i = 0;
	
	while (`i' < `k_hulp') {;
		local i = `i'+ 1;

		tempvar hulp_x;
		local name_x = word("`vars3_hulp'",1);		
		g `hulp_x' = `name_x';
		
		local vars3_hulp1 : list local(vars3_hulp) - local(name_x);
		local vars3_hulp "`vars3_hulp1'";

		quietly drop if missing(`hulp_x');
	};							   
	
	local y = "`1'";
	tempvar fulltime;
	g `fulltime' = !missing(`y');
	local i = 0;
	local k : list sizeof varlist;
	local k = `k' - 1;

	local hulp1_varlist = word("`varlist'", 1);
	
	global vars : list local(varlist) - local(hulp1_varlist);

	global vars1 = "";
	global vars2 : list local(select) - global(vars);
	local k_iv : list sizeof select;

	local k1 = 0;

	global vars3 $vars $vars2;

	
	tempfile hulp_file4;

	quietly save `hulp_file4', replace;
	quietly keep if `gender' == 1;
	capture program drop single;
	capture program drop dsingle;
											  
	single `fulltime' $vars $vars2, h(0.2);
		
	use `hulp_file4', clear;
	matrix gamma = e(b);
	local k_totaal = colsof(gamma);
	matrix cov_step1 = e(V);
	local b1 = gamma[1,1];
	local b0 = gamma[1,colsof(gamma)];

	local i = 0;
	tempvar lambda;
	tempvar lambda1;
	tempvar z;
	
	g `z' = `b0';
	local i = 0;
	local vars3_hulp "$vars3";
	
	while (`i' < `k_totaal'-1) {;
		local i = `i'+ 1;
		local b1 = gamma[1,`i'];

		tempvar hulp_x;
		local name_x = word("`vars3_hulp'",1);
		g `hulp_x' = `name_x';
		local vars3_hulp1 : list local(vars3_hulp) - local(name_x);
		local vars3_hulp "`vars3_hulp1'";
		
		quietly replace `z' = `z' + `b1' * `hulp_x';
	};
	
	g `lambda' = normalden(-`z') / (1-normal(-`z'));
	g `lambda1' = 1;
	
	local i = 0;
	
	while (`i' < `l') {;
		local i = `i' + 1;
		tempvar vlambda_`i';
		quietly replace `lambda1' = `lambda1' * `lambda';
		quietly g `vlambda_`i'' = `lambda1';
		local vars_lambda `vars_lambda' `vlambda_`i'';
	};

	local hulp_increment = 1 / (`q'+1);
	
	if ((`method' == 2) | (`method' == 4)) {;
		local q1 = 0;

		while (`q1' < 1 - (2 * `hulp_increment')) {;
			local q1 = `q1' + `hulp_increment';
			quietly qreg `y' if gender == 1, q(`q1');
			matrix b1 = e(b);
			
			local hulp_list : list local(hulp_list) | local(q1);

			if (`q1' == `hulp_increment'){;
				matrix result3 = `q1', b1;
			};
			else {;
				matrix result3 = result3 \ (`q1', b1);
			};		
		};
/*
		quietly sqreg `y' if gender == 1, q(`hulp_list') reps(2);

		matrix result3 = result3, e(b)';*/
	};


	if ((`method' == 3) | (`method' == 5)) {;
		local q1 = 0;
		local i = 0;
		
		while (`q1' < 1 - (2 * `hulp_increment')) {;
			local q1 = `q1' + `hulp_increment';
			local i = `i' + 1;
			quietly qreg `y' if gender == 0, q(`q1');
			matrix b1 = e(b);
			if (`i' == 1){;
				matrix result3 = `q1', b1;
			};
			else {;
				matrix result3 = result3 \ (`q1', b1);
			};		
		};
	};

	if (`method' == 5) {;
		tempvar gender1;
		g `gender1' = 1 - gender;
		mata yb_gender0 = st_data(., "`y'", "`gender1'");
	};

	local i = 0;

	tempfile hulp_file2;
	quietly save `hulp_file2', replace;

	quietly keep if gender == 1;
	quietly keep if `fulltime' == 1;

	tempvar x;
	tempvar hulp;
	tempvar s;
	tempvar hulp_x;
	tempvar hulp_v;
	tempvar v2;

	tempvar y1;
	g `y1'= !missing(`y'); 
	tempvar fulltime1;
	g `fulltime1' = `fulltime' * `y1';


	
	quietly g `x' = `z' - `c';
	quietly g `hulp' = `x' / (`ba' - `x') * (`x' < `ba') + (`x' >= `ba');
	quietly g `s' = (1 - exp(-`hulp')) * ((`x' >= 0) * (`x' < `ba')) + (`x' >= `ba');

	local n_hulp = 9;
	while (`i' < `n_hulp') {;
		local i = `i' + 1;
		mata: st_matrix("hulp2", hulp_u[`i',1]);

		local hulp2 = hulp2[1,1];

		local ni = `i' / (`n_hulp'+1);
		
		qreg `y' $vars `vars_lambda' if `fulltime' == 1 , q(`ni');

		matrix b = e(b);
		matrix b3 = e(b);
		matrix b = b[1,1..colsof(b)-`l'-1], b[1,colsof(b)];
		
		g `hulp_v' = 0;
		local j = 0;
		local vars3_hulp "$vars3";

		local k : list sizeof varlist;
		local k = `k' - 1;

		while (`j' < (`k' - `l')) {;
			local j = `j'+ 1;
			local b1 = b[1,`j'];

			tempvar hulp_x;
			local name_x = word("`vars3_hulp'",1);
			local vars3_hulp1 : list local(vars3_hulp) - local(name_x);
			local vars3_hulp "`vars3_hulp1'";
			quietly g `hulp_x' = `name_x';
			
			quietly replace `hulp_v' = `hulp_v' + `b1' * `hulp_x';
			drop `hulp_x';
		};

		quietly g `v2' = `y' - `hulp_v';				
		mata v2 = st_data(., "`v2'", "`fulltime1'");
		mata s = st_data(., "`s'", "`fulltime1'");
		mata q = hulp_u[`i',1];
		mata mu2 = quanc1(v2, q ,s);

		mata st_matrix("mu2", mu2);

		matrix b = b';
		matrix b3 = b3';
		
		matrix b = b[1..rowsof(b)-1,1] \ mu2;
		matrix b3 = b3[1..rowsof(b3)-1,1] \ mu2;
		  
		mata: b = st_matrix("b");
		mata: b3 = st_matrix("b3");
		
		if (`i'  == 1) {;
			mata: result = b';
			mata: result_b3 = b3';
		};
		else {;
			mata: result = result \ b';
			mata: result_b3 = result_b3 \ b3';
		};
		
		if (`i' > 1) {;		
			matrix result_b = result_b, e(b)';
			matrix sd = e(V);
			matrix sd = vecdiag(sd)';	 /*
			matrix sd = sd[1,1..colsof(sd)-`l'-1], sd[1,colsof(sd)];*/
			matrix result_sd = result_sd, sd;
		};
		else {;
			matrix result_b = e(b)';
			matrix sd = e(V);
			matrix sd = vecdiag(sd)';/*
			matrix sd = sd[1,1..colsof(sd)-`l'-1], sd[1,colsof(sd)];
			stop;					   */
			matrix result_sd = sd;		
		};
		
		drop `hulp_v';
		drop `v2';
		
	};

	mata st_matrix("result_b", result_b3);
	matrix result_b = result_b';
	
	ereturn clear;
	ereturn matrix b1 = result_b;
	ereturn matrix sd = result_sd;
end;


