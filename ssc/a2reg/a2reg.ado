/*
 *
 * a2reg: estimates models with two fixed effects
 * Author: Amine Ouazad
 * 	   PhD Candidate, Paris School of Economics
 *	   and Centre for the Economics of Education, London School of Economics
 * 	   amine.ouazad at pse.ens.fr
 *
 */

#delimit ;

cap program drop a2reg;
program define a2reg, sortpreserve eclass;
/*
 *
 * A2REG uses mata, therefore requires version 9
 * May work with earlier versions than 9.1
 *
 */
version 9.1;

/* 
 * Syntax: a2reg depvar indepvars, 
 *	individual(first fixed effect) unit(second fixed effect)
 *	resid(name) xb(name) largestgroup
 */
 if !replay() {;
syntax varlist(min=2) [if] [in], individual(varname) unit(varname) 
		[indeffect(name)] [uniteffect(name)]
		[resid(name)] [xb(name)] [largestgroup];

/* Checks whether all variables are numeric */
quietly {;
foreach v in `varlist' {;
	confirm numeric variable `v';
};

if ("`largestgroup'"!="") {;
	quietly{;
	tempvar group group_count;
	a2group, individual(`individual') unit(`unit') groupvar(`group');
	egen `group_count' = count(`group'), by(`group');
	summarize `group_count';
	local max = r(max);
	summarize `group' if `group_count' == `max';
	local largest_group = r(min);
	drop if `group' != `largest_group';
	};
};

if ("`indeffect'"!="") {;
	confirm new variable `indeffect';
};

if ("`indeffect'"=="") {;
	tempvar indeffect;
};

if ("`uniteffect'"!="") {;
	confirm new variable `uniteffect';
};

if ("`uniteffect'"=="") {;
	tempvar uniteffect;
};

if ("`resid'"!="") {;
	confirm new variable `resid';
};

if ("`resid'"=="") {;
	tempvar resid;
};

if ("`xb'"!="") {;
	confirm new variable `xb';
};

if ("`xb'"=="") {;
	tempvar xb;
};

marksample touse, novarlist strok;
keep if `touse';

gettoken dependent varlist : varlist;

tempvar indid unitid cellid;
tempfile save;

/* Creating sequenced ID variables */

egen `indid'  = group(`individual');
egen `unitid' = group(`unit');
egen `cellid' = group(`indid' `unitid');

/* Getting the size of the problem */

sort `indid';
summarize `indid', meanonly; 
local ninds = r(max); 

sort `unitid';
summarize `unitid', meanonly;
local nunits = r(max);

sort `cellid';
summarize `cellid', meanonly ;
local ncells = r(max) ;

sort `indid' `unitid';

/* 
 * Launches the Conjugate gradient estimation
 * Note : the program fails when explanatory variables are not linearly independent
 */
 };
mata: maincg("`dependent'",tokens("`varlist'"),"`indid'","`unitid'", `ninds', `nunits', `ncells', "`save'");

quietly{;
	gen double `indeffect' = .;
	gen double `uniteffect' = .;
	gen double `xb' = .;
};

quietly{;
mata: addresultscg("`dependent'",tokens("`varlist'"),"`indid'","`unitid'", `ninds', `nunits', `ncells', "`save'","`indeffect'","`uniteffect'","`xb'");
};

/* Computes the residual */
if ("`resid'" == "") {;
	tempvar resid;
};
quietly gen `resid' = `dependent' - `xb' - `indeffect' - `uniteffect';

/* The constant is absorbed in the average of the individual effects */
quietly summarize `indeffect';
local sdind = r(sd);
local mean_ie = r(mean);
quietly replace `indeffect' = `indeffect' - `mean_ie';

quietly summarize `indid';
local dfind = r(max);

quietly summarize `uniteffect';
local sdunit = r(sd);

quietly summarize `unitid';
local dfunit = r(max);

quietly summarize `resid';
local var_resid = r(Var);
local rss 	= r(Var)*(r(N)-1);

quietly summarize `dependent';
local var_dependent = r(Var);
local rss_dependent = r(Var)*(r(N)-1);

quietly corr `indeffect' `uniteffect';
local rho = r(rho);

local r2 	= 1.0 - `rss'/`rss_dependent';
local dfm	= `dfx'+`dfunit' + `dfind';
local dfe 	= _N - `dfm' - 1;
local ar2 	= 1 - (1-`r2')*(_N - 1)/`dfe';
local rmse	= sqrt(`rss'/_N);
local Ftot=(`r2'/`dfm')/((1-`r2')/`dfe');
local pvaltot=fprob(`dfm', `dfe', `Ftot');

/*
 *
 * Fisher tests: Compare the two-way fixed effects model to the two one way 
 * fixed effect models and the model without fixed effects
 *
 */
qui areg `dependent' `varlist' , absorb(`unitid');
local r2_ind=e(r2);
local Fstat_ind=((`r2' - `r2_ind')/`dfind')/((1-`r2')/(`dfe'));
local pval_ind=fprob(`dfind', `dfe', `Fstat_ind');

qui areg `dependent' `varlist', absorb(`indid');
local r2_unit=e(r2);
local Fstat_unit=((`r2' - `r2_unit')/`dfunit')/((1-`r2')/(`dfe'));
local pval_unit=fprob(`dfunit', `dfe', `Fstat_unit');

qui reg `dependent' `varlist';
local r2_nofe=e(r2);
local Fstat_nofe=((`r2' - `r2_nofe')/(`dfunit'+`dfind'))/((1-`r2')/(`dfe'));
local pval_nofe=fprob(`dfind'+`dfunit', `dfe', `Fstat_nofe');

/*matrix variance = J(`dfx',`dfx',.);

matrix colnames variance = `varlist';
matrix rownames variance = `varlist';*/



ereturn post betas /*variance*/;
ereturn scalar N 	= _N;
ereturn scalar RSS 	= `rss';
ereturn scalar r2 	= `r2';
ereturn scalar ar2 	= `ar2';
ereturn scalar nind 	= `dfind';
ereturn scalar nunit 	= `dfunit';
ereturn scalar constant = `mean_ie';
ereturn scalar rmse 	= `rmse';
ereturn scalar sdunit	= `sdunit';
ereturn scalar sdind	= `sdind';
ereturn local dependent   = "`dependent'";
ereturn local individual  = "`individual'";
ereturn local unit 	= "`unit'";
ereturn scalar rho 	= `rho';
ereturn scalar dfx	= `dfx';
ereturn scalar dfind	= `dfind';
ereturn scalar dfunit 	= `dfunit';
ereturn scalar dfe	= `dfe';
ereturn scalar dfm      = `dfm';
ereturn scalar F_all	= `Ftot';
ereturn scalar p_all 	= `pvaltot';
ereturn scalar Find = `Fstat_ind';
ereturn scalar pind = `pval_ind';
ereturn scalar Funit= `Fstat_unit';
ereturn scalar punit = `pval_unit';
ereturn scalar F_both = `Fstat_nofe';
ereturn scalar p_both = `pval_nofe';

/*ereturn matrix beta 	=  betas;*/
ereturn local title "Linear regression with two way fixed effects";
ereturn local cmd "reg";
ereturn local model "twowayfe";
};
 else {;
	 syntax , Level(integer `c(level)');
	 };
 
di _n in gr `"`e(title)'"' _col(56) `"Number of obs ="' in ye %8.0f e(N);
di in gr _col(56) `"F("' in gr %3.0f e(dfm) in gr `","' in gr %6.0f e(dfe) in gr `") ="' in ye %8.2f e(F_all);
di in gr _col(56) `"Prob > F      ="'  in ye %8.4f e(p_all);
di in gr _col(56) `"R-squared     ="'  in ye %8.4f e(r2);
di in gr _col(56) `"Adj R-squared ="'  in ye %8.4f e(ar2);
di in gr _col(56) `"Root MSE      = "' in ye %7.0g e(rmse) _n;
/*ereturn display, plus;*/

di in smcl in gr "{hline 13}{c +}{hline 65}";

di in smcl in gr %12s abbrev(`"`e(dependent)'"',12) " {c |}      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]";

di in smcl in gr "{hline 13}{c +}{hline 65}"; 

/* Display coefficient estimates */

matrix beta = e(b);
	
foreach v in `varlist' {;
		local value = beta[1,colnumb(beta,"`v'")];
		di in smcl in gr %12s abbrev("`v'",12) " {c |} " in ye %9.0g `value' " missing : standard errors only by bootstrapping ";
		};
	
	di in smcl in gr %12s "_cons" " {c |} " in ye %9.0g e(constant);
	
di in smcl in gr "{hline 13}{c +}{hline 65}";

di in yellow "SDs of FEs" in gr "   {c |}";
di in smcl in gr %12s  abbrev(`"`e(individual)'"',12) " {c |}  "  in ye %9.0g e(sdind);
di in smcl in gr %12s  abbrev(`"`e(unit)'"',12) " {c |}  "  in ye %9.0g e(sdunit);
di in smcl in gr %12s  "Correlation" " {c |}  " in ye %9.0g e(rho);
di in text "{hline 13}{c +}{hline 65}";

/*
 *
 * F tests for the joint significance of the fixed effects
 *
 */

di in yellow "Tests of FEs" in gr " {c |}";
local dfa1  = e(dfind) + 1;
local skip2 = max(14-length(`"`dfa1'"')-2,0);
local todisp `"F(`e(dfind)', `e(dfe)') = "';
local skip3 = max(23-length(`"`todisp'"')-2,0);
di in smcl in gr %12s  abbrev(`"`e(individual)'"',12) " {c |}"
   	   _skip(`skip3') `"`todisp'"'
	       in ye %10.3f e(Find) %8.3f e(pind)
	       in gr _skip(`skip2') `"(`dfind' categories)"';
	       
local dfa2  = e(dfunit) + 1;
local skip2 = max(14-length(`"`dfa2'"')-2,0);
local todisp `"F(`e(dfunit)', `e(dfe)') = "';
local skip3 = max(23-length(`"`todisp'"')-2,0);
di in smcl in gr %12s  abbrev(`"`e(unit)'"',12) " {c |}"
    	   _skip(`skip3') `"`todisp'"'
	       in ye %10.3f e(Funit) %8.3f e(punit)
	       in gr _skip(`skip2') `"(`dfunit' categories)"';
	       
local dfa3 = e(dfind) + e(dfunit) + 1;
local skip2 = max(14-length(`"`dfa3'"')-2,0);
local todisp `"F(`dfa3', `e(dfe)') = "';
local skip3 = max(23-length(`"`todisp'"')-2,0);
di in smcl in gr %12s  abbrev(`"Both"',12) " {c |}"
    	   _skip(`skip3') `"`todisp'"'
	       in ye %10.3f e(F_both) %8.3f e(p_both)
	       in gr _skip(`skip2');

end;

#delimit cr


mata

function maincg(string scalar dependent, string rowvector covariates,
				string scalar individualid, string scalar unitid,
				real scalar npupils, real scalar nschools,
				real scalar ncells, string scalar filerawoutput) {

	real scalar i, j, jp, jf;
	real vector dfp, dff, df, d;
	real matrix xd, xf, xx;
	real matrix u;	
	real vector b;

	real vector theta;

	st_view(cov=., 	., covariates)
	st_view(y=., 	., dependent)
	st_view(pupil=., 	., individualid)
	st_view(school=., ., unitid)

	n 		    = 	length(y);
	ncov		=	cols(cov);
	ncoef		= 	npupils + nschools + ncov - 1;

	stata(sprintf("local dfx = %f", ncov));
	
	printf("%f observations, %f covariates, %f individuals, %f units, %f cells\n",n,ncov,npupils,nschools,ncells);

	if ((length(y) != rows(cov)) | (length(y)!=length(pupil)) | (length(y)!=length(school)) ) {
		printf("Bug : invalid matrix length\n");
		printf("Please report to amine.ouazad@pse.ens.fr\n");
		exit();
	}

	icell = 1;
	xd	= J(npupils,ncov,0);
	xf	= J(nschools,ncov,0);
	d	= J(npupils,1, 0);
	dfp	= J(ncells, 1, 0);
	dff	= J(ncells, 1, 0);
	df	= J(ncells, 1, 0);
	f	= J(nschools, 1, 0);

	for ( i=1 ; i<=n ; i++ ) {

		if (i>1) {
			if (pupil[i] != pupil[i-1] || (school[i] != school[i-1] && pupil[i] == pupil[i-1])) {
				icell = icell +1;
			}
		}

		/* Construction de d */
		jp = pupil[i]
		d[jp] = d[jp] + 1

		/* Construction de dfp */
		dfp[icell] = jp

		/* Construction de f */
		jf = school[i]
		f[jf] = f[jf] + 1

		/* Construction de dff */
		dff[icell] = jf

		/* Construction de df */
		df[icell] = df[icell] + 1

		for ( j = 1; j <= ncov ; j++ ) {
		/* Construction de XD et XF */	
			xd[jp,j] = xd[jp, j] + cov[i, j]
			xf[jf,j] = xf[jf, j] + cov[i, j]
		}
	}

	if (icell != ncells) {
		printf("Bug: Error number of cells read %f not equal to %f\n", icell, ncells);
		printf("Please report to amine.ouazad@pse.ens.fr\n");
		exit();
	}

	theta = J(ncoef, 1, 0);

	/* 	Preconditioning steps - use diag of D'D and F'F and a transform
		of X'X (cov'cov) so that X'X = I
		Transform covariates using Cholesky Decomposition in several steps
		Compute Qtq = cov'cov
		Compute Cholesky Decomposition of xx=u'u
		Transform COV with inverse of u cov <- cov * inverse(u) so cov'cov = I
		Save R (upper triangular part) to restore covariate effects 
	*/
	
	xx = cross(cov,cov);
	xx = cholesky(xx);	
	u = xx';
	cov 				= cov * luinv(u) ;
	xd 				= xd * luinv(u) ;
	xf 				= xf * luinv(u) ;

	for (i = 1; i<=npupils ; i ++) {
		d[i] = 1/sqrt(d[i]);
	}

	for (i = 1; i<=nschools ; i ++) {
		f[i] = 1/sqrt(f[i]);
	}

	for (j=1;j<=ncov;j++) {
		for (i = 1; i<=npupils ; i ++ ) {
			xd[i, j] = xd[i, j]*d[i];
		}
		for (i = 1; i<=nschools ; i ++ ) {
			xf[i, j] = xf[i, j]*f[i];
		}
	}

	for (i=1; i<=ncells; i++) {	
		df[i] = df[i]*d[dfp[i]]*f[dff[i]]
	}

	// Does (X D F)'y and puts it in b 
	xtprod (pupil, school, cov[1 .. n,1..ncov], f, d, y, b, ncov, npupils, nschools, ncells, n);
	b = b'

	resid = 1.0e-7
	maxit = 1000

	theta[1..ncov] = u * theta[1..ncov]


	for (jp = 1; jp<=npupils; jp++) {
		j = ncov + jp
		theta[j]=theta[j]/d[jp]	
	}

	for (jf = 1; jf<=nschools-1; jf++) {
		j = ncov + npupils +jf
		theta[j] = theta[j]/f[jf]
	}
	
	printf("Beginning Iterations\n");

	modcg(b,theta,maxit,resid, xd, xf, df, dfp, dff, ncov, npupils, nschools, ncells, ncoef, n);

	theta[1 .. ncov] = luinv(u) * theta[1 .. ncov]

	for (jp = 1; jp <=npupils; jp++) {
		j = ncov + jp
		theta[j] = theta[j] * d[jp]
	}

	for (jf = 1; jf <=nschools-1; jf++) {
		j = ncov + npupils + jf
		theta[j] = theta[j] * f[jf]
	}

	/** Writes estimation results in file cgout */

	fp = fopen(filerawoutput,"w");

	fputmatrix(fp, theta);

	fclose(fp);
}

void modcg(real vector b, real vector x, real scalar maxit, real scalar resid, 
		real matrix xd, 	real matrix xf, 
		real matrix df,
		real matrix dfp, 	real matrix dff,
		real scalar ncov, real scalar npupils,
		real scalar nschools, real scalar ncells,
		real scalar ncoef, real scalar n) {

/* At the beginning x is the initial guess, x is then the approximate solution on output */

	real scalar eps
	real scalar info
	real scalar tol
	real scalar beta
	real scalar bnrm2
	real scalar itmax	

	real vector r , p , q

	printf("Starting Conjugate Gradient Algorithm\n");

	eps = 10e-15
	info = 0
	tol = resid
	beta = 0

	r = b
	p = J(ncoef, 1, 0) 

	bnrm2 = sqrt(b*b')

	if (bnrm2 == 0) {
		bnrm2 = 1
	}
	
	matvec (x, r, xd, xf, df, dfp, dff, ncov, npupils, nschools, ncells, ncoef);

	r = b - r'

	itmax = maxit
	maxit = 0
	rnrm2 = sqrt(r*r')
	resid = rnrm2 / bnrm2

	printf("Iteration %f, norm of residual %f, relative error %f\n", maxit, rnrm2, resid);

	if (resid <= tol) return
	
	w = r

	rho = r*w'

	for (maxit = 1 ; maxit <= itmax ; maxit ++) {
		p = w' + beta * p
		matvec (p, q, xd, xf, df, dfp, dff, ncov, npupils, nschools, ncells, ncoef)
		alpha = rho / (p'*q)
		x = x + alpha * p 
		r = r - alpha *q'
		rnrm2 = sqrt(r*r')
		resid = rnrm2 / bnrm2
		printf("Iteration %f, norm of residual %f, relative error %f\n", maxit, rnrm2, resid);
		if (rho < n*eps) return
		if (resid <= tol ) return
		rho1 = rho
		w = r
	 	rho = r*w'
		beta = rho/rho1
	}	

}

void matvec(real vector xin, 	real vector rout, 
		real matrix xd, 	real matrix xf,
		real matrix df,
		real matrix dfp, 	real matrix dff,
		real scalar ncov, real scalar npupils,
		real scalar nschools, real scalar ncells,
		real scalar ncoef ) {

/* 	Computes the matrix vector product rout <- A*xin
	with A =(X D F)'(X D F)
	
	X'X in xxin(ncov,ncov), assumed identity from preconditioning
	X'D in xd(npupils, ncov)
	X'F in xf(nschools, ncov)
	D'F in df(ncells), person and firm indices in dfp(ncells) and dff(ncells)
	D'D is identity from preconditioning dimension(npupils, npupils)
	F'F is identity from preconditioning dimension(nschools, nschools)

	The vectors X and R have three parts,
	The covariate effects 1:ncov
	The pupil effects ncov+1:ncov+npupils
	The school effects ncov+npupils+1:ncov+npupils+nschools 

*/

	real scalar i;

/* First the covariate effects */
	rout = xin
	rout[1 .. ncov] = cross(xd , (xin[ncov+1 .. ncov+npupils])) + rout[1 .. ncov]
	rout[1 .. ncov] 	 = cross(xf[1 .. nschools - 1, 1 .. ncov ], (xin[ncov+npupils+1 .. ncov+npupils+nschools-1]) ) + rout[1 .. ncov]

/* then the pupil effects */
	rout[ncov+1 .. ncov+npupils ] 			= xd * xin[1 .. ncov] + rout[ncov+1 .. ncov+npupils ] 

/* and finally the school effects */
	rout[ncov+npupils+1 .. ncov+npupils+nschools-1] 	= xf[1 .. nschools - 1 , 1 .. ncov] * xin[1 .. ncov] + rout[ncov+npupils+1 .. ncov+npupils+nschools-1]
	for ( i = 1 ; i <= ncells ; i++ ) {
		jpupil 	= dfp[i] + ncov
		jschool 	= dff[i] + ncov + npupils
	
		if (jschool <= ncoef) {
			rout[jpupil] 	= rout[jpupil] 	+ xin[jschool] * df[i]
			rout[jschool] 	= rout[jschool] 	+ xin[jpupil] * df[i]
		}
	}

}



/* This function multiplies X's */
void xtprod(real vector pupils, real vector schools, real matrix cov,
		real vector f, real vector d, 
		real vector s, real vector r,
		real scalar ncov, real scalar npupils,
		real scalar nschools, real scalar ncells,
		real scalar n ) {

	/*
		Multiplies X's -> r
		X is of size ( ncov x n ) and s of size ( ncov )

	 	pupils(n) 	: vector containing the pupilid of the record 
		schools(n)	: vector containing the schoolid of the record
		cov(n,ncov)	: the covariates of the record
		s(n)		: the vector being multiplied
		f(nschools) : vector containing  the number of times the school
					appears in the data 
		d(npupils)	: vector containing the number of times the pupil
					appears in the data
		r(ncoef)	: the output vector
	*/

	real scalar i;
	real scalar tmp;
	real vector jp, jf;

	r = J(ncov + npupils + nschools -1 ,1,0);

	for (i=1; i<=n; i++) {
		tmp = s[i]
		jp = pupils[i]
		j = jp + ncov
		r[j] = r[j] + tmp * d[jp]
		jf = schools[i]
		if (jf != nschools) {
			j = jf+ncov+npupils
			r[j] = r[j] + tmp * f[jf]

		}
	}		
	
	r[1..ncov] = cross(cov,s)

}

function addresultscg(string scalar dependent, string rowvector covariates,
				string scalar individualid, string scalar unitid,
				real scalar npupils, real scalar nschools,
				real scalar ncells, string scalar filerawoutput,
				string scalar indeffect,
				string scalar uniteffect,
				string scalar xb) {

	real scalar ncov;
	string scalar cmd_listcovnames; 
	string scalar cmd_listcovvalues;
	ncov = length(covariates);	
	fp = fopen(filerawoutput,"r")
	params = fgetmatrix(fp);
	betas = params[1 .. ncov];
	pupileffects = params[ncov+1 .. ncov + npupils];
	schooleffects = params[ncov+npupils+1 .. ncov + npupils + nschools -1];
	
	st_view(data, . ,(individualid, unitid, indeffect,uniteffect));

	n = rows(data);
	
	for (i = 1; i<= n ; i ++) {
		data[i,3] = pupileffects[data[i,1]];
		if (data[i,2] != nschools) {
			data[i,4] = schooleffects[data[i,2]];
		} else {
			data[i,4] = 0;
		}
	}
	
	cmd_listcovnames  =	"";
	cmd_listcovvalues = 	"";

	cmd_listcovnames 	= sprintf("%s %s",cmd_listcovnames, covariates[1]);
	cmd_listcovvalues	= sprintf("%s %g,",cmd_listcovvalues, betas[1]);
	stata(sprintf("quietly replace %s = %g * %s",xb,betas[1], covariates[1]));
	
	for (i = 2; i<= ncov; i++) {
		cmd_listcovnames 	= sprintf("%s %s",cmd_listcovnames, covariates[i]);
		cmd_listcovvalues	= sprintf("%s %g,",cmd_listcovvalues, betas[i]);
		stata(sprintf("quietly replace %s = %s + %g * %s",xb,xb,betas[i], covariates[i]));
	}

	stata(sprintf("matrix input betas = (%s)",cmd_listcovvalues));
	stata(sprintf("matrix colnames betas = %s",cmd_listcovnames));
	
	fclose(fp);
}



end


