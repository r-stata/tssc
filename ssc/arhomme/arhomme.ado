*! version 1.0.1 26nov2020
/* by Pascal Erhardt & Martin Biewen, University of Tuebingen */

program define arhomme, eclass byable(recall)

version 16.0

syntax varlist(min=2 numeric) [if] [in] [pweight/], SELect(string) [RHOpoints(integer 19) ///
																TAUpoints(integer 3) ///
																REPetitions(integer 100) ///
																SUBsample(string) ///
																INSTRument(varname numeric) ///
																COPulaparameter(varname numeric) ///
																MESHsize(real 1) ///
																CENTergrid(real 0) ///
																Quantiles(numlist >0 <1 ascending max=100) ///
																GAUssian FRAnk PLACKett JOEma GRAph NOSTDerrors ///
																OUTput(string) FILLfraction(real 0.3)]
	

	
	if ("`copulaparameter'" != "") {
		qui sum `copulaparameter'
		local copmax = `r(max)'
		local copmin = `r(min)'
	}
	
	cmd_in `0' /* call the optional input interpreter */

	/* define copula */
	if (`r(fra)' + `r(gau)' + `r(plack)' + `r(joe)' == 0) {
		local copula "frank" // frank is default
	}
	else if (`r(fra)' + `r(gau)' + `r(plack)' + `r(joe)' > 1) {
		display as error "options {bf:frank}, {bf:gaussian}, {bf:plackett}, and {bf:joema} are mutually exclusive"
		exit 198
	}
	else {
		local copula `frank'`gaussian'`plackett'`joema'
	}
	
	/* restrict RHOpoints & TAUpoints >0 & REPetitions >= 0 & MESHsize >0 */
	if (`rhopoints' < 1) {
		display as error "{p}{bf:rhopoints(`rhopoints')} must be a positive " ///
		 "integer{p_end}"
		exit 198
	}
	if (`taupoints' < 1) {
		display as error "{p}{bf:taupoints(`taupoints')} must be a positive " ///
		 "integer{p_end}"
		exit 198
	}
	if (`meshsize' <= 0) {
		display as error "{p}{bf:meshsize(`meshsize')} must be strictly positive{p_end}"
		exit 198
	}
	else if ("`copula'"=="gaussian" & `meshsize'>1) {
		display as error "{p}{bf:meshsize(`meshsize')} must not exceed 1 when " ///
		 "option {bf:gaussian} is chosen{p_end}"
		exit 198
	}
	
	if ("`copula'" == "gaussian" & (`centergrid' <= -1 | `centergrid' >= 1) ) {
		display as error "{p}{bf:centergrid(`centergrid')} is restricted " ///
		" to ]-1,1[ with option {bf:gaussian}{p_end}"
		exit 198
	}
	else if (`r(plack)' + `r(joe)' > 0 & `centergrid' < 0) {
		display as error "{p}{bf:centergrid(`centergrid')} must be a positive" ///
		" real number when choosing option {bf:plackett} or {bf:joema}{p_end}"
		exit 198
	}
	if (`r(plack)' + `r(joe)' > 0 & `r(cent)' == 0) { /* set new default for plackett & joe copulae */
		local centergrid = 1
	}
	if (`r(nostd)' + `r(rep)' > 1) { //("`nostderrors'" != "" & "`repetitions'" != "") {
		display as error "options {bf:nostderrors} and {bf:repetitions} are mutually exclusive"
		exit 198
	}
	else if (`r(nostd)' + `r(sub)' > 1) { //(  "`nostderrors'" != "" & "`subsample'" != "") {
		display as error "options {bf:nostderrors} and {bf:subsample} are mutually exclusive"
		exit 198
	}
	else if (`r(nostd)' + `r(fill)' > 1) {
		display as error "options {bf:nostderrors} and {bf:fillfraction} are mutually exclusive"
		exit 198
	}
	
	if (`repetitions' < 2) {
		display as error "{bf:repetitions(`repetitions')} must be an integer greater than 1"
		exit 198
	}
	
	if (`fillfraction' < 0) {
		display as error "{p}{bf:fillfraction(`fillfraction')} must be greater than " ///
		"or equal to 0{p_end}"
		exit 198
	}
			
	if (`r(sub)' == 1) { /* default defined later */
		local n_substr: word count `subsample'
		if (`n_substr' != 1) {
			display as error "too many input arguments for option {bf:subsample(`subsample')}"
			exit 198
		}
		capture confirm integer number `subsample'
		if (_rc != 0){
			display as error "{bf:subsample(`subsample')} must be a positive integer"
			exit 198
		}
	}
	
	if (`r(cop)' == 1) {
		if (`r(nostd)' == 0) {
			di as error "option {bf:copulaparameter} must be chosen with option {bf:nostderrors}"
			exit 198
		}
		else if (`r(mesh)' + `r(cent)' + `r(rho)' + `r(tau)' + `r(gra)' + `r(instr)' > 0) {
			di as error "{p}options {bf:meshsize}, {bf:centergird}, {bf:rhopoints}," ///
			" {bf:taupoints}, {bf:graph}, and {bf:instrument} are not allowed when " ///
			" {bf:copulaparameter(`copulaparameter')} is defined{p_end}"
			exit 198
		}
		else if (`r(gau)' == 1 & (`copmax' >= 1 | `copmin' <= -1) ) {
			di as error "{p}{bf:copulaparameter(`copulaparameter')} is restricted to ]-1,1[" ///
			" when {bf:gaussian} copula is chosen{p_end}"
			exit 198
		}
		else if (`r(plack)' + `r(joe)' > 0 & `copmin' <= 0) {
			di as error "{p}{bf:copulaparameter(`copulaparameter')} is restricted to the postive" ///
			" real line when {bf:plackett} or {bf:joema} copula is chosen{p_end}"
			exit 198
		}
	}
	
	if (`r(out)' + `r(nostd)' > 1) {
			di as error "options {bf:nostderrors} and {bf:output} are mutually exclusive"
			exit 198
	}
	if (`r(out)' > 0) {
		local num_outp: word count `output'
		if (`num_outp' > 2) {
			di as error "too many input arguments for option {bf:output(`output')}"
			exit 198
		}
		else {
			tokenize `output'
			local out_normal = ("`1'" == "normal") + ("`2'" == "normal")
			local out_bootstrap = ("`1'" == "bootstrap") + ("`2'" == "bootstrap") 
			local out_check = `out_normal' + `out_bootstrap' + ("`1'" == "`2'")
			local 1 ""
			local 2 ""
			if (`out_check' != `num_outp') {
				di as error "no valid input argument for option {bf:output(`output')}"
				exit 198
			}
		}
	}
	else { /* define output default */
		local out_normal = 1
	}
	
	
	local num_vlist: word count `varlist'
	gettoken depvar indepvar : varlist
	tempvar seldep
	
	/* allow = after depvar in selection equation */
	tokenize `select', parse("=")
	if ("`1'" == "=") { /* allow binary response to be missing */
		qui gen byte `seldep' = 0
		qui replace `seldep' = 1 if `depvar' !=. /* build the binary response */ 
		gettoken eq_sign selreg : select
				
	}
	else if ("`2'" == "=") { /* case where binary response and selection regressors are seperated by '=' */
		local biname `1'
		qui gen byte `seldep' = .
		qui replace `seldep' = 0 if `1' == 0
		qui replace `seldep' = 1 if `1' != 0
		local selreg `3'
				
	}
	else { /* case where no '=' was typed */
		qui gen byte `seldep' = 0
		qui replace `seldep' = 1 if `depvar' !=. /* build the binary response */ 
		local selreg `select'
				
	}	
	
		
	tempvar touse probuse
	tempname sN N
	/* marker for conditional quantile regression */
	mark `touse' `if' `in'
	markout `touse' `seldep' `selreg' `varlist'
	qui replace `touse' = 0 if `seldep' == 0 /* markout selected individuals */
	
	/* marker for selection equation */
	mark `probuse' `if' `in'
	markout `probuse' `seldep' `selreg' `indepvar'
	qui replace `probuse' = 0 if `depvar'==. & `seldep'==1 /* remove all observations where dependent variable is missing despite no selection */
	
	capture confirm variable `instrument'
	if (_rc == 0) { // remove missings in user-specified instrument (if existent)
		markout `touse' `instrument'
		markout `probuse' `instrument'
	}
	capture confirm variable `copulaparameter'
	if (_rc == 0) { // remove any missings in user-specified copula parameters (if existen)
		markout `touse' `copulaparameter'
		markout `probuse' `copulaparameter'
	}
	
	qui sum `touse'
	sca `sN' = `r(sum)'
	
	qui sum `probuse'
	sca `N' = `r(sum)'
	local nobs = `r(sum)'
			
	qui sum `seldep' if `probuse'
	if `r(N)' == `r(sum)' {
		di in red "Dependent variable never censored because of selection: "
		di in red "model reduces to conditional quantile regression"
		exit 498
	}
	
	local num_sel: word count `selreg'
	
	if ("`subsample'" == "" & "`nostderrors'" == "") { /* now define default */
		local subsample = `nobs' /* if subsample size is left unspecified bootstrap is applied */
		display _newline(1) as text "{p}option {bf:subsample} left unspecified: " ///
		"{bf:subsample} automatically set to `subsample' (bootstrap){p_end}"
		display as text "use option {bf:nostderrors} to disable estimation of covariance matrix"
	}
	else if ("`subsample'" != "") {
		if (`subsample' <= `num_sel' | `subsample' < `num_vlist') {
			display as error "{p}{bf:subsample(`subsample')} must contain at least " ///
			"as many observations as regressors{p_end}"
			exit 198
		}
		else if (`subsample' > `nobs') {
			display _newline(1) as text "{bf:subsample(`subsample')} exceeds effective size of dataset: "
			display as text "{bf:subsample} automatically set to `nobs'"
			local subsample = `nobs'
		}
	}
	
	
	/* remove collinear quantile regressors */
	_rmcoll `indepvar' if `touse', forcedrop
	local indepvar "`r(varlist)'"
	local num_indepv: word count `indepvar'
	/* remove collinearity in selection regressors */
	_rmcoll `selreg' if `probuse', forcedrop
	local selreg "`r(varlist)'"
	local num_sel: word count `selreg'
	
	tempvar wght
	if ("`weight'" != "") {
		qui sum `exp' if `probuse'
		qui gen `wght'=`exp'/`r(mean)' /* rescale weights */
	}
	else {
		qui gen `wght' = 1
	}
	
	/* perform first stage of Arellano Bonhomme estimation*/
	tempvar zgamma
	tempname gammaCov gamma objvec rhovec minFval rho bvec COVmat subsize kendall spearman blomqvist actreps Vrho pvals b_betas s_betas cbands
	quietly { 
	probit `seldep' `selreg' if `probuse' [pw=`wght']
	predict double `zgamma' if `probuse', xb 
	mat `gamma' = get(_b)
	mat `gammaCov' = get(VCE)
	local probnames: colnames `gamma'
	// local probeq: coleq `gamma'
	}
	
	if (`e(converged)' == 1) { /* inform user about probit estimation */
		di _newline(1) as text "First step estimation (probit model) successfully completed."
	}
	else {
		di as error "probit model did not converge"
		exit 430
	}
	
	if ("`instrument'" == "") { /* if option instrument is left unspecified */
		tempname instrument
		qui gen `instrument' = normal(`zgamma')
	}
	
	tempname quant
	/* process quantile input */
	if ("`quantiles'" == "") { // set default quantiles
		local nq = 9
		mat `quant' = (.\.1\.2\.3\.4\.5\.6\.7\.8\.9)
		local quantiles = ".1 .2 .3 .4 .5 .6 .7 .8 .9"
		forvalues i = 1/`nq' {
			local temp_q = abbrev("`i'_quantile",11)
			local coef_eq = "`coef_eq'" + (`num_indepv'+1)*".`temp_q' "
		}
	}
	else { // user specific quantiles
		local nq : word count `quantiles'
		mat `quant' =.
		forvalues i = 1/`nq' {
			local temp_q: word `i' of `quantiles'
			mat `quant' = (`quant'\ `temp_q')
			local temp_q = abbrev("`temp_q'_quantile",11)
			local coef_eq = "`coef_eq' " + (`num_indepv' + 1)*".`temp_q' "
		}
	}
	
	if ("`biname'" == "") { /* binary response equation names */
		local biname "select"
		local probeq = (`num_sel' + 1)*"`biname' "
	}
	else {
		local probeq = (`num_sel' + 1)*"`biname' "	
	}
		
	if ("`copulaparameter'" == "") {
		mata: heavylift_7355("`indepvar'", ///
							"`depvar'", ///
							"`gamma'", ///
							"`zgamma'", ///
							"`copula'", ///
							`taupoints', ///
							`rhopoints', ///
							`nq', ///
							"`quant'", ///
							"`touse'", ///
							"`objvec'", ///
							"`rhovec'", ///
							"`minFval'", ///
							"`rho'", ///
							"`bvec'", ///
							"`wght'", ///
							"`spearman'", ///
							"`kendall'", ///
							"`blomqvist'", ///
							`meshsize', ///
							`centergrid', ///
							"`instrument'")
							
	local clist = `nq'*"_cons `indepvar' " + "rho"
	local coef_list = "`probnames' " + "`clist'"
	local ceq = "`coef_eq' " + "_anc"
	local coef_eq =  "`probeq' " + "`coef_eq' " + "_anc"
	matrix colnames `bvec' = `coef_list'
	matrix coleq `bvec' = `coef_eq'	
	}
	else {
		di _newline(1) as txt "{p}note: second step estimation redundant because copula parameter" ///
		" already defined as {bf:copulaparameter(`copulaparameter')}{p_end}"
		mata: main_fct2("`indepvar'", ///
						"`depvar'", ///
						"`gamma'", ///
						"`zgamma'", ///
						"`copula'", ///
						`nq', ///
						"`quant'", ///
						"`touse'", ///
						"`bvec'", ///
						"`wght'", ///
						"`copulaparameter'")
	
	local coef_list = "`probnames' " + `nq'*"_cons `indepvar' "
	local coef_eq =  "`probeq' " + "`coef_eq' "
	matrix colnames `bvec' = `coef_list'
	matrix coleq `bvec' = `coef_eq'
	}

								
	if ("`nostderrors'" == "") {
		mata: std_erf("`indepvar'", ///
						"`depvar'", ///
						"`gamma'", ///
						"`copula'", ///
						`taupoints', ///
						`rhopoints', ///
						`nq', ///
						"`quant'", ///
						"`touse'", ///
						"`probuse'", ///
						"`seldep'", ///
						"`selreg'", ///
						"`COVmat'", ///
						`subsample', ///
						`repetitions', ///
						"`gammaCov'", ///
						"`subsize'", ///
						"`wght'", ///
						`meshsize', ///
						`centergrid', ///
						"`bvec'", ///
						"`instrument'", ///
						"`actreps'", ///
						"`Vrho'", ///
						"`pvals'", ///
						"`b_betas'", ///
						"`s_betas'", ///
						"`cbands'", ///
						`fillfraction')
	}
	
	di _newline(3) as text "{hline 78}"	
	di as text "{bf:Arellano & Bonhomme (2017)} selection model"
	di as text "(conditional quantile regression with sample selection)"
	di as text "{hline 78}"
	
	if ("`nostderrors'" != "") {
		ereturn post `bvec', depname("`depvar'") esample(`probuse')
	}
	else {
		matrix rownames `COVmat' = `coef_list'
		matrix colnames `COVmat' = `coef_list'
		matrix roweq `COVmat' = `coef_eq'
		matrix coleq `COVmat' = `coef_eq'
		matrix colnames `cbands' = "2.5%" "97.5%"
		matrix rownames `cbands' = `clist'
		matrix rownames `b_betas' = `clist'
		matrix rownames `s_betas' = `clist'
		matrix rownames `pvals' = `clist'
		matrix roweq `cbands' = `ceq'
		matrix roweq `b_betas' = `ceq'
		matrix roweq `s_betas' = `ceq'
		matrix roweq `pvals' = `ceq'
		matrix colnames `pvals' = "P>|z-H_0|"
		ereturn post `bvec' `COVmat', depname("`depvar'") esample(`probuse')
	}
	
	ereturn scalar sN = `sN'
	ereturn scalar N = `N'
	if ("`copulaparameter'" == "") {
	ereturn scalar rho = `rho'
	ereturn scalar minFval = `minFval'
	ereturn scalar rhopts = `rhopoints'
	ereturn scalar taupts = `taupoints'
	ereturn scalar meshsize = `meshsize'
	ereturn scalar spearman = `spearman'
	ereturn scalar kendall = `kendall'
	ereturn scalar blomqvist = `blomqvist'
	}
	
	di as text _col(50) "Number of obs.   = " as result %10.0gc e(N)
	di as text _col(50) "Num. of selected = " as result %10.0gc e(sN)
	if ("`copulaparameter'" == "") {
	di as text _col(50) "Rho points       = " as result %10.0gc e(rhopts)
	di as text _col(50) "Tau points       = " as result %10.0gc e(taupts)
	di as text _col(50) "Meshsize         = " as result %10.4fc e(meshsize)
	di as text _col(50) "Spearman's rho   = " as result %10.4fc e(spearman)
	di as text _col(50) "Kendall's tau    = " as result %10.4fc e(kendall)
	di as text _col(50) "Blomqvist's beta = " as result %10.4fc e(blomqvist)
	di as text _col(50) "Minimum Fval     = " %10.7e as result e(minFval)
		if ("`nostderrors'" == "") {
			ereturn scalar subsample = `subsample'
			ereturn scalar repetitions = `actreps'
			ereturn scalar Vrho = `Vrho'
			ereturn scalar fillfrac = `fillfraction'
			ereturn matrix pvals = `pvals'
			ereturn matrix bbetas = `b_betas'
			ereturn matrix sbetas = `s_betas'
			ereturn matrix confivals = `cbands'
			di as text _col(50) "Replications     = " %10.0gc as result e(repetitions)
			di as text _col(50) "Subsample Size   = " %10.0gc as result e(subsample)
		}
	}
	if ("`out_normal'" == "1") {
		if (("`copula'" == "plackett" | "`copula'" == "joema") & ("`nostderrors'" == "")){
			local neq = `nq' + 1
			ereturn display, neq(`neq') nolstretch plus /* placket and joema copula parameters not normally distributed under H0 rho=0 */
			qui test [_anc]rho = 1
			local stdrho = sqrt(`e(Vrho)')
			local trho = (`e(rho)'-1)/`stdrho'
			local ub = `e(rho)' + invnormal(.975)*`stdrho'
			local lb = `e(rho)' - invnormal(.975)*`stdrho'
			di as text _col(14) "{c |}" _col(21) "Coef.   Std. Err.   rho=1   p_val     [95% Conf. Interval]"
			di as text "{hline 13}{c +}{hline 64}"
			di as text "{bf:_anc}" _col(14) "{c |}"
			di as text _col(10) "rho" _col(14) "{c |}  " as result %9.8g e(rho) _col(28) %9.8g `stdrho' _col(40) %6.2f `trho' _col(49) %4.3f `r(p)' _col(58) %9.8g `lb' "   " %9.8g `ub'
			di as text "{hline 13}{c BT}{hline 64}"
		}
		else {
			ereturn display, nolstretch
		}
	}
	
	if ("`out_bootstrap'" == "1") {
		qui ereturn display
		cmd_out ,dep("`depvar'") regs("`indepvar'") seldep("`biname'") selreg("`selreg'") nsel(`num_sel') beta("e(b)") cov("e(V)") nq(`nq') nvar(`num_vlist') quant("`quant'") pvals("e(pvals)") conf("e(confivals)") cop("`copula'")
	}
	
	if ("`copula'" == "frank") {
		di as text "note: parameter estimates based on Frank copula model"
	}
	else if ("`copula'" == "gaussian") {
    	di as text "note: parameter estimates based on Gaussian copula model"
	}
	else if ("`copula'" == "joema") {
    	di as text "note: parameter estimates based on Joe & Ma copula model"
	}
	else {
    	di as text "note: parameter estimates based on Plackett copula model"
	}
	
	if ("`nostderrors'" == "") {
		if (`actreps' != `repetitions') {
			local fsubs = `repetitions' - `actreps'
			local plu = plural(`fsubs',"subsample")
			local fillp = 100*`fillfraction'
			di _newline in red "`fsubs' `plu' had to be discarded because of failed convergence"
			di as text "note: user-specified limit for replacing failed repetitions reached"
			di as text "standard errors may be questionable"
            di as text "you may wish to increase {bf:subsample(`subsample')}"

		}
	}
	
	/* check whether graph was requested */
	if ("`graph'" != "") {
		_matplot (`objvec', `rhovec'), nonames ytitle("Objective function") xtitle("rho")
	}
	ereturn local cmdline `"`0'"'
	ereturn local cmd "arhomme"
	ereturn local instrument `"`instrument'"'
	ereturn local cparameter `"`copulaparameter'"'
	
	
end

mata:

/*  ===============================================================================
	*** This section replicates rq.m by D. Morillo, R. Koenker & P. Eilers.	
		Note that the subroutines below are in opposite order compared to rq.m 
		To perform a quantile regression call rq_fnm('Regressors X as (n x k) matrix',
		'Dependent Variable y as (n x 1) vector', 'Quantile p as scalar or (n x 1) vector')
		from your main code.
		--IMPORTANT-- p must not contain any elements that are (numerically) zero[one] for Stata.
		Thus, set all elements of p smaller[larger] than 5*epsilon(1)[1-5*epsilon(1)]
		to 5*epsilon(1)[1-5*epsilon(1)] beforehand.
		Otherwise this algorithm may break down.
		The tolerance level and maximum amount of iterations are set to 1e-5 and
		100, respectively. Both may be altered manually in lp_fnm. ***
    =============================================================================== */

real matrix bound(numeric matrix x, numeric matrix dx) {

/*  ===============================================================================
	*** Fill vector with allowed step lengths
		Support function for lp_fnm ***
	=============================================================================== */
real vector b, f
	
b = 1e20 :+ 0* x // define b either as column or row vector (depending on what x itself is)
f = selectindex(dx:<0) // now get the index of all negative elements
b[f] = -x[f] :/ dx[f] // then alter all negative elements
return(b)
// end of bound routine
}

real rowvector lp_fnm(numeric matrix A, real rowvector c, real colvector b, real colvector u, real colvector x)
{
/*	===============================================================================
	*** Solve a linear program by the interior point method:
		min(c * u), s.t. A * x = b and 0 < x < u
		An initial feasible solution has to be provided as x

		Function lp_fnm of Daniel Morillo & Roger Koenker
		Found at: http://www.econ.uiuc.edu/~roger/rqn/rq.ox
		Translated from Ox to Matlab by Paul Eilers 1999
		Modified slightly by Roger Koenker, April, 2001.	
		Translated from Matlab to Stata by Pascal Erhardt, October, 2019 ***
	
		for the remainder n denotes the sample size, k the number of regressors
	
			A is k x n
			c is 1 x n
			b is k x 1
			u is n x 1
			x is n x 1	
	=============================================================================== */
real vector s, y, r, z, w, q, rhs, dy, dx, dz, dw, fx, fs, fw, fz, dxdz, dsdw, xinv, sinv, xi
real matrix AQ, AQA
real scalar beta, small, max_it, n, k, gap, mu, g
	
// Set some constants
beta = 0.9995
small = 1e-5
max_it = 100
n = cols(A)
k = rows(A)

// Generate initial feasible point
s = u - x // n x 1
y = (qrsolve(A',c'))' // 1 x k -->> approximate a system of linear equations where n > k
r = c - y*A // 1 x n -->> r = -1* regression error
z = r :* (r:>0) // 1 x n
w = z - r // 1 x n
//Tau = s // weight of absolut sum
//check = colsum( (Tau - (-r':<=0)):*(-r') ) // calculates the value of the check function, i.e. sum of abs. weighted deviations
gap = c*x - y*b + w*u // 1 x 1

// Start iterations
it = 0
while (gap > small & it < max_it) {
	it = it +1
	
	// Compute affine step
	q = 1 :/ ((z' :/ x) + (w' :/ s)) // n x 1
	r = z - w // 1 x n
	//Q = diag(q) // no sparse option available
	AQ = J(k,n,0)
	for (i=1;i<=n;i++) {
		for (j=1;j<=k;j++) {
			AQ[j,i] = q[i,1]*A[j,i]
		}
	}	
	
	AQA = AQ * A' // k x k
	rhs = AQ * r' // k x 1
	dy = (invsym(AQA) * rhs)' // 1 x k
	dx = q :* (dy * A - r)' // n x 1
	ds = -dx // n x 1
	dz = -z :* (1 :+ (dx :/ x))' // 1 x n
	dw = -w :* (1 :+ (ds :/ s))' // 1 x n
	
	// Compute maximum allowable step lengths
	fx = bound(x, dx) // n x 1
	fs = bound(s, ds) // n x 1
	fw = bound(w, dw) // 1 x n
	fz = bound(z, dz) // 1 x n
	fp = rowmin((fx,fs)) // n x 1
	fd = colmin((fw \ fz)) // 1 x n
	fp = min((min(beta * fp), 1)) // 1 x 1
	fd = min((min(beta * fd), 1)) // 1 x 1
	
	// If full step is feasible, take it. Otherwise modify it
	if (min((fp, fd)) < 1) {
	
		// Update mu
		mu = z * x + w * s // 1 x 1
		g = (z + fd*dz) * (x + fp * dx) + (w + fd * dw) * (s + fp * ds) // 1 x 1
		mu = mu * ((g / mu)^3) / ( 2 * n)
		
		// Compute modified step
		dxdz = dx :* dz' // n x 1
		dsdw = ds :* dw' // n x 1
		xinv = 1 :/ x // n x 1
		sinv = 1 :/ s // n x 1
		xi = mu * (xinv - sinv) // n x 1
		rhs = rhs + A * ( q :* (dxdz - dsdw - xi)) // k x 1
		dy = (invsym(AQA)* rhs)' // 1 x k
		
		dx = q :* (A' * dy' + xi - r' - dxdz + dsdw) // n x 1
		ds = -dx // n x 1
		dz = mu * xinv' - z - (xinv' :* z :* dx') - dxdz' // 1 x n
		dw = mu * sinv' - w - (sinv' :* w :* ds') - dsdw' // 1 x n
		
		// Compute maximum allowable step lengths
		fx = bound(x, dx) // n x 1
		fs = bound(s, ds) // n x 1
		fw = bound(w, dw) // 1 x n
		fz = bound(z, dz) // 1 x n
		fp = rowmin((fx,fs)) // n x 1
		fd = colmin((fw\ fz)) // 1 x n
		fp = min((min(beta * fp), 1)) // 1 x 1
		fd = min((min(beta * fd), 1)) // 1 x 1
		
	}
	
	// Take the step
	x = x + fp * dx // n x 1
	s = s + fp * ds // n x 1
	y = y + fd * dy // 1 x k
	w = w + fd * dw // 1 x n
	z = z + fd * dz // 1 x n
	
	gap = c * x - y * b + w * u // 1 x 1
}
return(y)
// end of lp_fnm routine
}

real colvector rq_fnm(numeric matrix X, real colvector y, real colvector p)
{

/* ================================================================================
	*** Construct the dual problem of quantile regression
		Solve it with lp_fnm
 
		Function rq_fnm of Daniel Morillo & Roger Koenker
		Found at: http://www.econ.uiuc.edu/~roger/rqn/rq.ox
		Translated from Ox to Matlab by Paul Eilers 1999
		Translated from Matlab to Stata by Pascal Erhardt, October, 2019 ***
   ================================================================================ */
real scalar m
real vector u, a, b
   
m = rows(X)
u = J(m,1,1)
a = (1 :- p):*u
b = -lp_fnm(X', -y', X' * a, u, a)'
return(b)
// end of rq_fnm routine
}


end

mata:

real scalar Newton_Inter(real scalar u, real scalar opt) {

real colvector c_rho, c_tau, x /* nodes and coefficients of polynomial roots; calculated in matlab file 'NewtonInter' */
real scalar v /* output: approximated point */
real rowvector V

c_rho = (0 \ 0.0623226545583605\ 0.00367720639528224\ 0.000204476024281372\ 1.03437246404126e-05\ 4.15585381991934e-07\ 3.48909067719662e-09\ -1.98263806304224e-09\ -3.23883618501762e-10\ -3.34511912644218e-11\ -1.74556024907062e-12\ 2.11960643792196e-13\ 6.06149744183511e-14\ 6.66330930515645e-16\ -1.29555629687939e-15\ 6.39754640572107e-17\ 1.39285864150616e-17\ -2.55385247457695e-18\ 1.97566196797646e-19\ -5.30453701296442e-21\ -6.42712550471012e-22\ 1.09183691525891e-22\ -9.78501480707626e-24\ 6.42130274358149e-25\ -3.22318578611179e-26\ 1.09281841663308e-27\ -1.13739641406728e-38)
c_tau = (0\0.0510894916414473\0.00252120904203062\0.000117738370513448\4.87666340933214e-06\1.35916840733332e-07\-4.21027733773708e-09\-1.28045048336379e-09\-1.57284516072431e-10\-1.35771845429325e-11\-4.90746123562826e-13\1.11271766559380e-13\2.40530846253367e-14\-1.30696341745966e-16\-5.10195448652022e-16\3.03678711055533e-17\4.99892607168443e-18\-9.96986777421439e-19\8.01064607852310e-20\-2.39416931588077e-21\-2.30147399582405e-22\4.17106447699158e-23\-3.79389161698803e-24\2.50410109316078e-25\-1.25957705584903e-26\4.27058536216758e-28\-2.63735668609671e-39)

x = (0\ -14.8985753661291\ -14.5956730586974\ -14.0953893117886\-13.4044896048512\ -12.5323171711940\-11.4906666467847\-10.2936245680310\-8.95737887554179\-7.50000000000000\-5.94119649058735\-4.30204849066636\-2.60472266500396\-0.872172433657139\0.872172433657136\2.60472266500396\4.30204849066635\5.94119649058735\7.50000000000000\8.95737887554179\10.2936245680310\11.4906666467847\12.5323171711940\13.4044896048512\14.0953893117886\14.5956730586974\14.8985753661291)

V = J(1,27,1)
for (j=2; j<=27; j++) {
	V[1,j] = V[1,j-1]*(u-x[j-1,1])
}

if (opt==1) { /* option 1 approximates Spearman's rank coefficient */
	v = V*c_rho
}
else { /* option 2 approximates Kendall's tau */
	v = V*c_tau
}

return(v)
/* end of function Newton_Inter */
}

real scalar integral(real scalar t, real scalar k) {
return(t:^k :/ (expm1(t)))
/* end of function integral */
}


real scalar debye(real scalar x, real scalar k) { /* determines the k-th order debye function at x by quadrature */
class Quadrature scalar q
q = Quadrature()
q.setEvaluator(&integral())
q.setLimits((0,x))
q.setArgument(1,k)
integral = q.integrate() /* integrate the debye integral by quadrature */
return(k/(x^k) *integral)
/* end of function deye */
}

void heavylift_7355(string scalar invnames, ///
					string scalar depvname, ///
					string scalar gam, ///
					string scalar zgam, ///
					string scalar copula, ///
					real scalar taupoints, ///
					real scalar rhopoints, ///
					real scalar numq, ///
					string scalar quantiles, ///
					string scalar touse, ///
					string scalar object_fct, ///
					string scalar rho_vec, ///
					string scalar min_val, ///
					string scalar min_rho, ///
					string scalar est_bvec, ///
					string scalar weights, ///
					string scalar S_rho, ///
					string scalar K_tau, ///
					string scalar B_beta, ///
					real scalar mesh, ///
					real scalar cent, ///
					string scalar instr)
{

/* construct data matrices */				
xdata = st_data(., invnames, touse) /* import quantile vars */
ydata = st_data(., depvname, touse) /* import quantile vars */
zgamma = st_data(., zgam, touse) /* get probit prediction */
wght = st_data(., weights, touse) /* import weights */
gamma = st_matrix(gam) /* get probit coefficients */
instrument = st_data(., instr, touse) /* load instrument variable*/
v = cols(xdata) + 1
n = rows(xdata)
pscore = normal(zgamma)
varphi = wght :*instrument
X = wght :*(J(n,1,1), xdata) //[.,2::v])
y = wght :*ydata[.,1]
/* define grid points for tau */
tauvec = (1::taupoints):/(taupoints + 1)
/* define grid points for copula parameter */
equiUnit = (1::rhopoints):/(rhopoints + 1)
/* initialize objective function vector */
object = J(rhopoints,1,1)

/* 2nd step in Arellano Bonhomme estimation */
if (copula == "frank") {
	rhovec = tan( pi() :* (equiUnit :- .5)) :*mesh :+cent // generate grid points using a cauchy distribution
	/* minimization */
	for (j=1; j<=rhopoints; j++) { // rho grid points
		rhoa = rhovec[j,1]
		obj = 0
		for (k=1; k<=taupoints; k++) { // tau grid points
			tau = tauvec[k,1]
			/* frank copula */
			if (abs(rhoa) > 5*epsilon(1) ) {
				G = -1/rhoa :* log( 1 :+ ((exp(-rhoa*tau) - 1):*(exp(-rhoa:*pscore) :- 1)) :/ expm1(-rhoa) ) :/pscore
			}
			else { // for rhoa == 0 frank copula becomes independent copula, i.e. plain vanilla conditional quantile regression is conducted
				G = J(n,1,tau)
			}
			if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
				z = selectindex(G:<5*epsilon(1))
				NisZ = rows(z)
				G[z] = J(NisZ,1,5*epsilon(1))
			}
			if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
				o = selectindex(G:>=1-5*epsilon(1))
				Nis1 = rows(o)
				G[o] = J(Nis1,1,1-5*epsilon(1))
			}
			beta = rq_fnm(X,y,G) // call minimization routine to estimate beta
			yhat = X*beta // prediction
			indicator = (y:<=yhat) // define the indicator function in our object
			obj = obj + mean(varphi:*(indicator - G)) // sum_{k=1}^{K} sum_{n=1}^{N} varphi_i(Z)*( 1[y_i <= X_i*b] - G_i )
		}
		object[j,1] = obj^2 // pseudo-euclidean norm
	}
}
else if (copula == "gaussian"){
	rhovec = asin( 2:*(equiUnit :-.5)) :*(2/pi()):*mesh :*(1-abs(cent)) :+cent // generate grid points using sin() as density on [-1;1]
	/* minimization */
	for (j=1; j<=rhopoints; j++) { // rho grid points
		rhoa = rhovec[j,1]
		obj = 0
		for (k=1; k<=taupoints; k++) { // tau grid points
			tau = tauvec[k,1]
			/* gaussian copula */
			G = binormal(invnormal(tau),zgamma,rhoa):/pscore
			if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
				z = selectindex(G:<5*epsilon(1))
				NisZ = rows(z)
				G[z] = J(NisZ,1,5*epsilon(1))
			}
			if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
				o = selectindex(G:>=1-5*epsilon(1))
				Nis1 = rows(o)
				G[o] = J(Nis1,1,1-5*epsilon(1))
			}
			beta = rq_fnm(X,y,G) // call minimization routine to estimate beta
			yhat = X*beta // prediction
			indicator = (y:<=yhat) // define the indicator function in our object
			obj = obj + mean(varphi:*(indicator - G)) // sum_{k=1}^{K} sum_{n=1}^{N} varphi_i(Z)*( 1[y_i <= X_i*b] - G_i )
		}
		object[j,1] = obj^2 // pseudo-euclidean norm
	}
}
else if (copula == "plackett") {
	rhovec = sqrt(equiUnit:/(1:-equiUnit)) // plackett grid
	rhovec = rhovec:*(rhovec:<=1)*cent :+ (rhovec:+(cent-1)):*(rhovec:>1)
	rhovec = (rhovec:-cent)*(mesh<=1)*mesh :+ cent :+ (mesh>1)*(rhovec:<cent):*(rhovec/mesh :-cent) :+ (mesh>1)*(rhovec:>cent):*(rhovec*mesh :-cent)
	/* minimization */
	for (j=1; j<=rhopoints; j++) { // rho grid points
		rhoa = rhovec[j,1]
		obj = 0
		for (k=1; k<=taupoints; k++) { // tau grid points
			tau = tauvec[k,1]
			/* plackett copula */
			if (abs(rhoa - 1) > 5*epsilon(1) ) {
			G = (.5/(rhoa-1) *( 1 :+ (rhoa-1)*(pscore :+ tau) :- sqrt( (1 :+ (rhoa-1)*(pscore :+ tau)):^2 :- 4*rhoa*(rhoa-1)*pscore*tau ) ) ):/pscore
			}
			else { /* plackett for rhoa=1 => independent copula */
			G = J(n,1,tau)
			}
			if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
				z = selectindex(G:<5*epsilon(1))
				NisZ = rows(z)
				G[z] = J(NisZ,1,5*epsilon(1))
			}
			if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
				o = selectindex(G:>=1-5*epsilon(1))
				Nis1 = rows(o)
				G[o] = J(Nis1,1,1-5*epsilon(1))
			}
			beta = rq_fnm(X,y,G) // call minimization routine to estimate beta
			yhat = X*beta // prediction
			indicator = (y:<=yhat) // define the indicator function in our object
			obj = obj + mean(varphi:*(indicator - G)) // sum_{k=1}^{K} sum_{n=1}^{N} varphi_i(Z)*( 1[y_i <= X_i*b] - G_i )
		}
		object[j,1] = obj^2 // pseudo-euclidean norm
	}
}
else { /* Joe and Ma (2000) copula */
	rhovec = sqrt(equiUnit:/(1:-equiUnit)) // grid
	rhovec = rhovec:*(rhovec:<=1)*cent :+ (rhovec:+(cent-1)):*(rhovec:>1)
	rhovec = (rhovec:-cent)*(mesh<=1)*mesh :+ cent :+ (mesh>1)*(rhovec:<cent):*(rhovec/mesh :-cent) :+ (mesh>1)*(rhovec:>cent):*(rhovec*mesh :-cent)
	/* minimization */
	for (j=1; j<=rhopoints; j++) { // rho grid points
		rhoa = rhovec[j,1]
		obj = 0
		for (k=1; k<=taupoints; k++) { // tau grid points
			tau = tauvec[k,1]
			/* cf. Joe, H. 2014. Dependence Modelling with Copulas. Chapter 4. pp. 177-180 */
			G = (1 :- gammap( rhoa, ( (invgammap(rhoa,1-tau):^rhoa ) :+ (invgammap(rhoa,1:-pscore):^rhoa ) ):^(1/rhoa) ) ):/pscore
			
			if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
				z = selectindex(G:<5*epsilon(1))
				NisZ = rows(z)
				G[z] = J(NisZ,1,5*epsilon(1))
			}
			if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
				o = selectindex(G:>=1-5*epsilon(1))
				Nis1 = rows(o)
				G[o] = J(Nis1,1,1-5*epsilon(1))
			}
			beta = rq_fnm(X,y,G) // call minimization routine to estimate beta
			yhat = X*beta // prediction
			indicator = (y:<=yhat) // define the indicator function in our object
			obj = obj + mean(varphi:*(indicator - G)) // sum_{k=1}^{K} sum_{n=1}^{N} varphi_i(Z)*( 1[y_i <= X_i*b] - G_i )
		}
		object[j,1] = obj^2 // pseudo-euclidean norm
	}
}

minObj = colmin(object)
/* minimize euclidean norm */
minindex(object,1,row=.,nix=.)
/* estimated copula parameter */
rho = rhovec[row,1]

if (rows(rho)!=1) { // break if estimated copula parameter is not unique; in practice this only happens if rq_fnm did not converge
	printf("{error:unable to minimize objective function}\n")
	exit(error(430))
}
else {
	printf("\n{txt}Second step (" + copula + "{txt} copula parameter estimation) successfully completed.\n")
	printf("{txt}Found objective function minimum " + strofreal(minObj,"%10.7e") + "{txt} for rho = " + strofreal(rho,"%10.4fc") + "\n")
}

/* 3rd step in Arellano Bonhomme estimation */
Qtiles = st_matrix(quantiles)
Qtiles = Qtiles[2::(numq+1),1]
est_betas = J(numq*v,1,0)
if (copula == "frank") {
	for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
		if (abs(rho) > 5*epsilon(1) ) {
			G = -1/rho :* log( 1 :+ ((exp(-rho*Qtiles[q,1]) - 1):*(exp(-rho:*pscore) :- 1)) :/ expm1(-rho) ) :/pscore
		}
		else { // for rho == 0 frank copula becomes independent copula, i.e. plain vanilla conditional quantile regression is conducted
			G = J(n,1,Qtiles[q,1])
		}
		if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
			z = selectindex(G:<5*epsilon(1))
			NisZ = rows(z)
			G[z] = J(NisZ,1,5*epsilon(1))
		}
		if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
			o = selectindex(G:>=1-5*epsilon(1))
			Nis1 = rows(o)
			G[o] = J(Nis1,1,1-5*epsilon(1))
		}
		para = rq_fnm(X,y,G) // call minimization routine to estimate beta
		est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
	}
}
else if (copula == "gaussian"){
	for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
		G = binormal(invnormal(Qtiles[q,1]),zgamma,rho):/pscore
		if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
			z = selectindex(G:<5*epsilon(1))
			NisZ = rows(z)
			G[z] = J(NisZ,1,5*epsilon(1))
		}
		if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
			o = selectindex(G:>=1-5*epsilon(1))
			Nis1 = rows(o)
			G[o] = J(Nis1,1,1-5*epsilon(1))
		}
		para = rq_fnm(X,y,G) // call minimization routine to estimate beta
		est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
	}	
}
else if (copula == "plackett"){
	for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
		/* plackett copula */
		if (abs(rho - 1) > 5*epsilon(1) ) {
			G = (.5/(rho-1) *( 1 :+ (rho-1)*(pscore :+ Qtiles[q,1]) :- sqrt( (1 :+ (rho-1)*(pscore :+ Qtiles[q,1])):^2 :- 4*rho*(rho-1)*pscore*Qtiles[q,1] ) ) ):/pscore
			}
			else { /* plackett for rhoa=1 => independent copula */
			G = J(n,1,Qtiles[q,1])
			}
		if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
			z = selectindex(G:<5*epsilon(1))
			NisZ = rows(z)
			G[z] = J(NisZ,1,5*epsilon(1))
		}
		if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
			o = selectindex(G:>=1-5*epsilon(1))
			Nis1 = rows(o)
			G[o] = J(Nis1,1,1-5*epsilon(1))
		}
		para = rq_fnm(X,y,G) // call minimization routine to estimate beta
		est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
	}
}
else { /* Joe and Ma (2000) copula */
	for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
		/* joema copula */
		G = (1 :- gammap( rho, ( (invgammap(rho,1-Qtiles[q,1]):^rho ) :+ (invgammap(rho,1:-pscore):^rho ) ):^(1/rho) ) ):/pscore
			
		if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
			z = selectindex(G:<5*epsilon(1))
			NisZ = rows(z)
			G[z] = J(NisZ,1,5*epsilon(1))
		}
		if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
			o = selectindex(G:>=1-5*epsilon(1))
			Nis1 = rows(o)
			G[o] = J(Nis1,1,1-5*epsilon(1))
		}
		para = rq_fnm(X,y,G) // call minimization routine to estimate beta
		est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
	}
}

est_betas = (gamma' \est_betas \rho)

// maybe check whether est_betas contains missings from failed minimizaton

printf("\n{txt}Third step (minimization of rotated check function) successfully completed. \n")

/* for the following cf. Joe, H. 2014. Dependence Modelling with Copulas. Chapter 4. */
if (copula == "frank") {
	if (abs(rho)>5*epsilon(1)) { /* Joe, 2014, p.166 */
		spear = sign(rho)*(1 + (12/abs(rho)) *(debye(abs(rho),2) - debye(abs(rho),1) ) )
		kend = sign(rho)*(1 + (4/abs(rho)) *(debye(abs(rho),1) - 1) )
		blom = -4/rho * log( (2*exp(-rho/2) - 2*exp(-rho)) /(1-exp(-rho)) ) - 1
	}
	else {
		spear = 0
		kend = 0
		blom = 0
	}
}
else if (copula == "gaussian") { /* Joe, 2014, p.164 */
	spear = (6/pi()) *asin(rho/2)
	kend = (2/pi()) *asin(rho)
	blom = kend
}
else if (copula == "plackett") { /* Joe, 2014, pp.164-165 */
	if (abs(rho-1)<=5*epsilon(1)) {
		spear = 0
		kend = .
		blom = 0
	}
	else {
		spear = (rho+1)/(rho-1) - (2*rho*log(rho))/((rho-1)^2)
		kend = .
		blom = (sqrt(rho)-1)/(sqrt(rho)+1)
	}
}
else { /* Joe, 2014, pp.177-180 */
	if (abs(rho-1)<=5*epsilon(1)) {
		spear = .
		kend = 0
		blom = 0
	}
	else {
		spear = .
		kend = 1 - 2*gamma(.5 + rho)/( sqrt(pi())*gamma(1+rho) )
		blom = 3 - 4*gammap(rho, 2^(1/rho) * invgammap(rho,.5))
	}
}

st_matrix(object_fct,object)
st_matrix(rho_vec,rhovec)
st_numscalar(min_rho,rho)
st_numscalar(min_val,minObj)
st_numscalar(S_rho,spear)
st_numscalar(K_tau,kend)
st_numscalar(B_beta,blom)
st_matrix(est_bvec,est_betas')
/* end of function heavylift_7355 */
}



void main_fct2(string scalar invnames, ///
				string scalar depvname, ///
				string scalar gam, ///
				string scalar zgam, ///
				string scalar copula, ///
				real scalar numq, ///
				string scalar quantiles, ///
				string scalar touse, ///
				string scalar est_bvec, ///
				string scalar weights, ///
				string scalar cpara)
{

/* construct data matrices */				
xdata = st_data(., invnames, touse) /* import quantile vars */
ydata = st_data(., depvname, touse) /* import quantile vars */
zgamma = st_data(., zgam, touse) /* get probit prediction */
wght = st_data(., weights, touse) /* import weights */
gamma = st_matrix(gam) /* get probit coefficients */
rhovar = st_data(., cpara, touse) /* load user-specified copula parameter */
v = cols(xdata) + 1
n = rows(xdata)
pscore = normal(zgamma)
X = wght :*(J(n,1,1), xdata) //[.,2::v])
y = wght :*ydata[.,1]

/* 3rd step in Arellano Bonhomme estimation */
Qtiles = st_matrix(quantiles)
Qtiles = Qtiles[2::(numq+1),1]
est_betas = J(numq*v,1,0)

if (copula == "frank") {
	aindep = selectindex(abs(rhovar) :>= 5*epsilon(1)) /* mark non-independent copulae */

	for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
		G = J(n,1,Qtiles[q,1])
		/* frank copula */
		G[aindep] = (-1:/rhovar[aindep]) :* log( 1 :+ ((exp(-rhovar[aindep]:*Qtiles[q,1]) :- 1):*(exp(-rhovar[aindep]:*pscore[aindep]) :- 1)) :/ expm1(-rhovar[aindep]) ) :/pscore[aindep]
		
		if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
			z = selectindex(G:<5*epsilon(1))
			NisZ = rows(z)
			G[z] = J(NisZ,1,5*epsilon(1))
		}
		if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
			o = selectindex(G:>=1-5*epsilon(1))
			Nis1 = rows(o)
			G[o] = J(Nis1,1,1-5*epsilon(1))
		}
		para = rq_fnm(X,y,G) // call minimization routine to estimate beta
		est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
	}
}
else if (copula == "gaussian") {
	for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
		/* gaussian copula */
		G = binormal(invnormal(Qtiles[q,1]),zgamma,rhovar):/pscore
		
		if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
			z = selectindex(G:<5*epsilon(1))
			NisZ = rows(z)
			G[z] = J(NisZ,1,5*epsilon(1))
		}
		if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
			o = selectindex(G:>=1-5*epsilon(1))
			Nis1 = rows(o)
			G[o] = J(Nis1,1,1-5*epsilon(1))
		}
		para = rq_fnm(X,y,G) // call minimization routine to estimate beta
		est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
	}
}
else if (copula == "plackett"){
	aindep = selectindex(abs(rhovar:-1) :> 5*epsilon(1)) /* mark non-independent copulae */
	
	for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
		/* plackett copula */
		G = J(n,1,Qtiles[q,1])
		G[aindep] = (.5:/(rhovar[aindep]:-1) :*( 1 :+ (rhovar[aindep]:-1):*(pscore[aindep] :+ Qtiles[q,1]) :- sqrt( (1 :+ (rhovar[aindep]:-1):*(pscore[aindep] :+ Qtiles[q,1])):^2 :- 4*rhovar[aindep]:*(rhovar[aindep]:-1):*pscore[aindep]:*Qtiles[q,1] ) ) ):/pscore[aindep]
		
		if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
			z = selectindex(G:<5*epsilon(1))
			NisZ = rows(z)
			G[z] = J(NisZ,1,5*epsilon(1))
		}
		if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
			o = selectindex(G:>=1-5*epsilon(1))
			Nis1 = rows(o)
			G[o] = J(Nis1,1,1-5*epsilon(1))
		}
		para = rq_fnm(X,y,G) // call minimization routine to estimate beta
		est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
	}
}
else { /* Joe and Ma (2000) copula */
	for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
		/* joema copula */
		G = (1 :- gammap( rhovar, ( (invgammap(rhovar,1-Qtiles[q,1]):^rhovar ) :+ (invgammap(rhovar,1:-pscore):^rhovar ) ):^(1:/rhovar) ) ):/pscore
			
		if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
			z = selectindex(G:<5*epsilon(1))
			NisZ = rows(z)
			G[z] = J(NisZ,1,5*epsilon(1))
		}
		if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
			o = selectindex(G:>=1-5*epsilon(1))
			Nis1 = rows(o)
			G[o] = J(Nis1,1,1-5*epsilon(1))
		}
		para = rq_fnm(X,y,G) // call minimization routine to estimate beta
		est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
	}
}


est_betas = (gamma' \est_betas)
fail = (est_betas :== .)
if (colsum(fail) > 0) {
	printf("\n{error:estimation of rotated check function failed for some quantiles}\n")
	exit(error(430))
}
else {
	printf("\n{txt:Third step (minimization of rotated check function) successfully completed.} \n")
}
st_matrix(est_bvec,est_betas')
/* end of function main_fct2 */
}


end

mata:

function probit_func(transmorphic M, ///
						real rowvector gamma, ///
						real colvector loglikeF)
{
	real colvector  para
	real colvector  binary

	para = moptimize_util_xb(M, gamma, 1)
	binary = moptimize_util_depvar(M, 1)
	w = moptimize_util_userinfo(M, 1)
              
	loglikeF = w:*( binary:*log(normal(para)) :+ (1:-binary):*log(1:-normal(para)) )

}

void std_erf(string scalar invnames, ///
					string scalar depvname, ///
					string scalar gam, ///
					string scalar copula, ///
					real scalar taupoints, ///
					real scalar rhopoints, ///
					real scalar numq, ///
					string scalar quantiles, ///
					string scalar touse, ///
					string scalar probuse, ///
					string scalar seldep, ///
					string scalar selreg, ///
					string scalar est_Vmat, ///
					real scalar subS, ///
					real scalar boots, ///
					string scalar gamCov, ///
					string scalar subsize, ///
					string scalar weights, ///
					real scalar mesh, ///
					real scalar cent, ///
					string scalar est_bvec, ///
					string scalar instr, ///
					string scalar actr, ///
					string scalar rhoVar, ///
					string scalar pvals, ///
					string scalar bbetas, ///
					string scalar sbetas, ///
					string scalar confb, ///
					real scalar fillfrac)
{

/* construct data matrices */				
xdata = st_data(., invnames, probuse) /* import quantile vars */
ydata = st_data(., depvname, probuse) /* import quantile vars */
Z = st_data(., selreg, probuse) /* import selection regressors */
D = st_data(., touse, probuse) /* import binary response var */
wght = st_data(., weights, probuse) /* import weights */
init_gamma = st_matrix(gam) /* get probit coefficients */
gammaCov = st_matrix(gamCov) /* get probit covariance matrix */
Ebetas = st_matrix(est_bvec)
instrument = st_data(., instr, probuse)
v = cols(xdata) + 1
n = rows(xdata)
Ebetas = Ebetas'
nEbetas = rows(Ebetas)
bmax = ceil((1+ fillfrac)*boots) /* maximum of samples to be drawn */
rep = 0
b = 1
prob_fail=0
q_fail=0
Ebetas = Ebetas[(cols(gammaCov)+1)::nEbetas,1]
/* define grid points for tau */
tauvec = (1::taupoints):/(taupoints + 1)
/* define grid points for copula parameter */
equiUnit = (1::rhopoints):/(rhopoints + 1)
/* subsample size */
subS = rowmin( (n, subS) )
Qtiles = st_matrix(quantiles)
Qtiles = Qtiles[2::(numq+1),1]
/* initialize bootstrap based beta matrix */
boots_betas = J(numq*v + 1,boots,0)

displayas("text")
printf("\n{txt:Initialising standard error estimation by }" + strofreal(subS) + "{txt: out of }" + strofreal(n) + "{txt: bootstrap method:}\n")
printf("{hline 4}{c +}{hline 3} 1 {hline 3}{c +}{hline 3} 2 {hline 3}{c +}{hline 3} 3 {hline 3}{c +}{hline 3} 4 {hline 3}{c +}{hline 3} 5 \n")

while (b<=boots & rep < bmax) {
	isel = subS
	
	conv=0
	mck=0
	rep++ /* start to count subsamping repetitioins */

	while (isel==subS | isel==0) { /* rule out subsamples with[out] [perfect] selection */
		inSample = ceil(n * runiform(subS,1))
		Sub_xdata = xdata[inSample,.]
		Sub_ydata = ydata[inSample,.]
		Sub_Z = Z[inSample,.]
		Sub_D = D[inSample,1]
		Sub_wght = wght[inSample,1]
		Sub_instr = instrument[inSample,1]
		isel = colsum(Sub_D)
	}

	y = Sub_wght :* Sub_ydata //[.,1]
	y = select(y,Sub_D) /* selected in subsample */
	X = Sub_wght :* (J(subS,1,1), Sub_xdata) //[.,2::v])
	X = select(X,Sub_D) /* selected regressors in subsample */
	M = moptimize_init()
	moptimize_init_evaluator(M, &probit_func())
	moptimize_init_depvar(M, 1, Sub_D )
	moptimize_init_eq_indepvars(M, 1, Sub_Z )
	moptimize_init_userinfo(M, 1, Sub_wght )
	moptimize_init_trace_value(M, "off")
	moptimize_init_trace_ado(M, "on")
	moptimize_init_eq_coefs(M, 1, init_gamma) /* use full-sample probit estimates as starting values to boost convergence */
	moptimize_init_search(M,"on")
	moptimize_init_search_rescale(M,"on") /* in rare cases probably better "on" */
	moptimize_init_conv_maxiter(M,50)
	moptimize_init_conv_warning(M,"off")
	moptimize_init_verbose(M, "off")
	moptimize(M)
	//moptimize_result_display(M)
	conv = moptimize_result_converged(M) /* end loop if probit succesfully converged */
	if (conv==0) {
		if (mod(rep,50) != 0 & b!=boots) {
				displayas("text")
				printf("{txt}x")
			}
			else if (mod(rep,50)== 0 | b==boots) {
				displayas("text")
				printf("x %6.0g", rep)
				printf("\n")
			}
	//displayas("error")
		//printf("\n{red:note: probit failed to converge for subsample }" + strofreal(b) + "/" + strofreal(boots) + "{red:. Subsample dropped and replaced}\n")
	}
			
	gamma = moptimize_result_coefs(M)
	mck = rowsum( (gamma :== .) )
	if (mck>=1) {
		if (mod(rep,50) != 0 & b!=boots) {
				displayas("text")
				printf("{txt}x")
		}
		else if (mod(rep,50)== 0 | b==boots) {
				displayas("text")
				printf("x %6.0g", rep)
				printf("\n")
		}
		//displayas("error")
		//printf("\n{red:note: probit estimation on subsample }" + strofreal(b) + "/" + strofreal(boots) + "{red: contains at least one missing. Subsample dropped and replaced}\n")
	}
	if ((mck >=1) | (conv==0)) {
		prob_fail++
	}
	else{ //if (conv==1 & mck==0) {	
		zgamma = (Sub_Z,J(subS,1,1)) * gamma'
		pscore = normal(zgamma)
		Sub_wght = select(Sub_wght,Sub_D)
		zgamma = select(zgamma,Sub_D) /* selected probit prediction in subsample */
		pscore = select(pscore,Sub_D) /* subsample pscore for selected individuals */
		Sub_instr = select(Sub_instr,Sub_D)
		varphi = Sub_wght :* Sub_instr

		/* initialize objective function vector */
		object = J(rhopoints,1,1)
		/* 2nd step in Arellano Bonhomme estimation */
		if (copula == "frank") {
			rhovec = tan( pi() :* (equiUnit :- .5)):*mesh :+cent // generate grid points using a cauchy distribution; now symmetric about entire sample estimate
			/* minimization */
			for (j=1; j<=rhopoints; j++) { // rho grid points
				rhoa = rhovec[j,1]
				obj = 0
				for (k=1; k<=taupoints; k++) { // tau grid points
					tau = tauvec[k,1]
					/* frank copula */
					if (abs(rhoa) > 5*epsilon(1) ) {
						G = -1/rhoa :* log( 1 :+ ((exp(-rhoa*tau) - 1):*(exp(-rhoa:*pscore) :- 1)) :/ expm1(-rhoa) ) :/pscore
					}
					else { // for rhoa == 0 frank copula becomes independent copula, i.e. plain vanilla conditional quantile regression is conducted
						G = J(isel,1,tau)
					}
					if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
						z = selectindex(G:<5*epsilon(1))
						NisZ = rows(z)
						G[z] = J(NisZ,1,5*epsilon(1))
					}
					if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
						o = selectindex(G:>=1-5*epsilon(1))
						Nis1 = rows(o)
						G[o] = J(Nis1,1,1-5*epsilon(1))
					}
					beta = rq_fnm(X,y,G) // call minimization routine to estimate beta
					yhat = X*beta // prediction
					indicator = (y:<=yhat) // define the indicator function in our object
					obj = obj + mean(varphi :*(indicator - G)) // sum_{k=1}^{K} sum_{n=1}^{N} varphi_i(Z)*( 1[y_i <= X_i*b] - G_i )
				}
				object[j,1] = obj^2 // pseudo-euclidean norm
			}
		}
		else if (copula == "gaussian") {
			rhovec = asin( 2:*(equiUnit :-.5)) :*(2/pi()):*mesh :*(1-abs(cent)) :+cent // generate grid points using sin() as density on [-1;1]; now symmetric about entire sample estimate of rho
			/* minimization */
			for (j=1; j<=rhopoints; j++) { // rho grid points
				rhoa = rhovec[j,1]
				obj = 0
				for (k=1; k<=taupoints; k++) { // tau grid points
					tau = tauvec[k,1]
					/* gaussian copula */
					G = binormal(invnormal(tau),zgamma,rhoa):/pscore
					if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
						z = selectindex(G:<5*epsilon(1))
						NisZ = rows(z)
						G[z] = J(NisZ,1,5*epsilon(1))
					}
					if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
						o = selectindex(G:>=1-5*epsilon(1))
						Nis1 = rows(o)
						G[o] = J(Nis1,1,1-5*epsilon(1))
					}
					beta = rq_fnm(X,y,G) // call minimization routine to estimate beta
					yhat = X*beta // prediction
					indicator = (y:<=yhat) // define the indicator function in our object
					obj = obj + mean(varphi :*(indicator - G)) // sum_{k=1}^{K} sum_{n=1}^{N} varphi_i(Z)*( 1[y_i <= X_i*b] - G_i )
				}
				object[j,1] = obj^2 // pseudo-euclidean norm
			}
		}
		else if (copula == "plackett") {
			rhovec = sqrt(equiUnit:/(1:-equiUnit)) // plackett grid
			rhovec = rhovec:*(rhovec:<=1)*cent :+ (rhovec:+(cent-1)):*(rhovec:>1)
			rhovec = (rhovec:-cent)*(mesh<=1)*mesh :+ cent :+ (mesh>1)*(rhovec:<cent):*(rhovec/mesh :-cent) :+ (mesh>1)*(rhovec:>cent):*(rhovec*mesh :-cent)
			/* minimization */
			for (j=1; j<=rhopoints; j++) { // rho grid points
				rhoa = rhovec[j,1]
				obj = 0
				for (k=1; k<=taupoints; k++) { // tau grid points
					tau = tauvec[k,1]
					/* plackett copula */
					if (abs(rhoa - 1) > 5*epsilon(1) ) {
						G = (.5/(rhoa-1) *( 1 :+ (rhoa-1)*(pscore :+ tau) :- sqrt( (1 :+ (rhoa-1)*(pscore :+ tau)):^2 :- 4*rhoa*(rhoa-1)*pscore*tau ) ) ):/pscore
					}
					else { /* plackett for rhoa=1 => independent copula */
						G = J(isel,1,tau)
					}
					if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
						z = selectindex(G:<5*epsilon(1))
						NisZ = rows(z)
						G[z] = J(NisZ,1,5*epsilon(1))
					}
					if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
						o = selectindex(G:>=1-5*epsilon(1))
						Nis1 = rows(o)
						G[o] = J(Nis1,1,1-5*epsilon(1))
					}
					beta = rq_fnm(X,y,G) // call minimization routine to estimate beta
					yhat = X*beta // prediction
					indicator = (y:<=yhat) // define the indicator function in our object
					obj = obj + mean(varphi:*(indicator - G)) // sum_{k=1}^{K} sum_{n=1}^{N} varphi_i(Z)*( 1[y_i <= X_i*b] - G_i )
				}
				object[j,1] = obj^2 // pseudo-euclidean norm
			}
		}
		else { /* Joe and Ma (2000) copula */
			rhovec = sqrt(equiUnit:/(1:-equiUnit)) // grid
			rhovec = rhovec:*(rhovec:<=1)*cent :+ (rhovec:+(cent-1)):*(rhovec:>1)
			rhovec = (rhovec:-cent)*(mesh<=1)*mesh :+ cent :+ (mesh>1)*(rhovec:<cent):*(rhovec/mesh :-cent) :+ (mesh>1)*(rhovec:>cent):*(rhovec*mesh :-cent)
			/* minimization */
			for (j=1; j<=rhopoints; j++) { // rho grid points
				rhoa = rhovec[j,1]
				obj = 0
				for (k=1; k<=taupoints; k++) { // tau grid points
					tau = tauvec[k,1]
					/* cf. Joe, H. 2014. Dependence Modelling with Copulas. Chapter 4. pp. 177-180 */
						G = (1 :- gammap( rhoa, ( (invgammap(rhoa,1-tau):^rhoa ) :+ (invgammap(rhoa,1:-pscore):^rhoa ) ):^(1/rhoa) ) ):/pscore
			
					if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
						z = selectindex(G:<5*epsilon(1))
						NisZ = rows(z)
						G[z] = J(NisZ,1,5*epsilon(1))
					}
					if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
						o = selectindex(G:>=1-5*epsilon(1))
						Nis1 = rows(o)
						G[o] = J(Nis1,1,1-5*epsilon(1))
					}
					beta = rq_fnm(X,y,G) // call minimization routine to estimate beta
					yhat = X*beta // prediction
					indicator = (y:<=yhat) // define the indicator function in our object
					obj = obj + mean(varphi:*(indicator - G)) // sum_{k=1}^{K} sum_{n=1}^{N} varphi_i(Z)*( 1[y_i <= X_i*b] - G_i )
				}
				object[j,1] = obj^2 // pseudo-euclidean norm
			}
		}
	
		minObj = colmin(object)
		/* minimize euclidean norm */
		minindex(object,1,row=.,nix=.)
		/* estimated copula parameter */
		rho = rhovec[row[1,1],1] /* make sure that rho is a scalar */

		/* 3rd step in Arellano Bonhomme estimation */
		est_betas = J(numq*v,1,0)
		if (copula == "frank") {
			for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
				if (abs(rho) > 5*epsilon(1) ) {
					G = -1/rho :* log( 1 :+ ((exp(-rho*Qtiles[q,1]) - 1):*(exp(-rho:*pscore) :- 1)) :/ expm1(-rho) ) :/pscore
				}
				else { // for rho == 0 frank copula becomes independent copula, i.e. plain vanilla conditional quantile regression is conducted
					G = J(isel,1,Qtiles[q,1])
				}
				if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
					z = selectindex(G:<5*epsilon(1))
					NisZ = rows(z)
					G[z] = J(NisZ,1,5*epsilon(1))
				}
				if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
					o = selectindex(G:>=1-5*epsilon(1))
					Nis1 = rows(o)
					G[o] = J(Nis1,1,1-5*epsilon(1))
				}
				para = rq_fnm(X,y,G) // call minimization routine to estimate beta
				est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
			}
		}
		else if (copula == "gaussian") {
			for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
				G = binormal(invnormal(Qtiles[q,1]),zgamma,rho):/pscore
				if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
					z = selectindex(G:<5*epsilon(1))
					NisZ = rows(z)
					G[z] = J(NisZ,1,5*epsilon(1))
				}
				if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
					o = selectindex(G:>=1-5*epsilon(1))
					Nis1 = rows(o)
					G[o] = J(Nis1,1,1-5*epsilon(1))
				}
				para = rq_fnm(X,y,G) // call minimization routine to estimate beta
				est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
			}

		}
		else if (copula == "plackett"){
			for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
				/* plackett copula */
				if (abs(rho - 1) > 5*epsilon(1) ) {
				G = (.5/(rho-1) *( 1 :+ (rho-1)*(pscore :+ Qtiles[q,1]) :- sqrt( (1 :+ (rho-1)*(pscore :+ Qtiles[q,1])):^2 :- 4*rho*(rho-1)*pscore*Qtiles[q,1] ) ) ):/pscore
					}
					else { /* plackett for rhoa=1 => independent copula */
					G = J(isel,1,Qtiles[q,1])
				}
				if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
					z = selectindex(G:<5*epsilon(1))
					NisZ = rows(z)
					G[z] = J(NisZ,1,5*epsilon(1))
				}
				if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
					o = selectindex(G:>=1-5*epsilon(1))
					Nis1 = rows(o)
					G[o] = J(Nis1,1,1-5*epsilon(1))
				}
				para = rq_fnm(X,y,G) // call minimization routine to estimate beta
				est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
			}
		}
		else { /* Joe and Ma (2000) copula */
			for (q=1; q<=numq; q++) { // estimate qunatile coefficients at user specified quantiles
				/* joema copula */
				G = (1 :- gammap( rho, ( (invgammap(rho,1-Qtiles[q,1]):^rho ) :+ (invgammap(rho,1:-pscore):^rho ) ):^(1/rho) ) ):/pscore
			
				if (colmin(G)<=5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) zero
					z = selectindex(G:<5*epsilon(1))
					NisZ = rows(z)
					G[z] = J(NisZ,1,5*epsilon(1))
				}
				if (colmax(G)>=1-5*epsilon(1)) { // IMPORTANT!! check whether one or more elements of G are (practically) one
					o = selectindex(G:>=1-5*epsilon(1))
					Nis1 = rows(o)
					G[o] = J(Nis1,1,1-5*epsilon(1))
				}
				para = rq_fnm(X,y,G) // call minimization routine to estimate beta
				est_betas[((v*q)-(v-1))::(q*v),1] = para // fill in the estimated parameters
			}
		}
				
		bmiss = colsum(est_betas :==.) /* check whether a subsample beta vector contains a missing */
		if (bmiss == 0) {
			boots_betas[.,b] = (est_betas\rho)
			if (mod(rep,50) != 0 & b!=boots) {
				displayas("text")
				printf("{txt}.")
			}
			else if (mod(rep,50) == 0 | b==boots) {
				displayas("text")
				printf(". %6.0g", rep)
				printf("\n")
			}
							
			b++ /* now consider such a sample properly estimated */
		}
		else {
			q_fail++ /* count as failed estimation */
			//displayas("error")
			//printf("\n{red:note: minimization of rotated check function on subsample }" + strofreal(b) + "{red: resulted in at least one missing. Subsample dropped and replaced}\n")
			if (mod(rep,50) != 0 & b!=boots) {
				displayas("text")
				printf("{txt}x")
			}
			else if (mod(rep,50)== 0 | b==boots) {
				displayas("text")
				printf("x %6.0g", rep)
				printf("\n")
			}
			
		}
	
	}
}

if (rep == bmax & b<=boots) {
	displayas("text")
	printf("%6.0g", rep)
	displayas("error")
	printf("\n{red:note: standard error computation by }" + strofreal(subS) + "{red: out of }" + strofreal(n) + "{red: bootstrap aborted because maximum of allowed repetitions (}" + strofreal(bmax) + "{red:) was reached}\n")
}

if (prob_fail > 0) {
	displayas("text")
	printf("\n{txt}note: probit model failed to converge for " + strofreal(prob_fail) + plural(prob_fail," subsample"))
}
if (q_fail >0) {
	displayas("text")
	printf("\n{txt}note: selection corrected quantile regression failed to converge for " + strofreal(q_fail) + plural(q_fail," subsample"))
}


if (b>=3) {
	// Ebetas = (mean(boots_betas'))' /* average coefficient estimates */
	colZ = cols(gammaCov)
	CMatrix =( ( boots_betas[.,1::(b-1)] :- Ebetas )* ( boots_betas[.,1::(b-1)] :- Ebetas )' ):/(b - 2) /* calculate covariance matrix */
	CMatrix = ( J(colZ,numq*v + 1,0) \ CMatrix ) * (subS/n)
	gammaCov = (gammaCov\J(numq*v + 1,colZ,0))
	CMatrix = (gammaCov, CMatrix) /* covariance matrix including first step standard errors */
	
	if (copula == "plackett" | copula == "joema") {
		 relF = rowsum(boots_betas[.,1::(b-1)]:<=(J(numq*v,1,0)\1)):/(b-1) /* test for significance with bootstrap distribution */
		 p_vals = 2*rowmin((relF,1:-relF))
	}
	else {
		relF = rowsum(boots_betas[.,1::(b-1)]:<=0):/(b-1) /* test for significance with bootstrap distribution */
		p_vals = 2*rowmin((relF,1:-relF))
	}
	
	vrs = 1
	sorted_betas = J(numq*v+1,b-1,0)
	while (vrs<=numq*v+1) {
		sorted_betas[vrs,.] = sort(boots_betas[vrs,1::(b-1)]',1)'
		vrs++
	}
	lconfb = sorted_betas[.,ceil(.025*(b-1))]
	uconfb = sorted_betas[.,ceil(.975*(b-1))]
	
	st_matrix(est_Vmat,CMatrix) /* export entire covariance matrix */
	st_numscalar(subsize,subS)
	st_numscalar(actr,b-1)
	st_numscalar(rhoVar,CMatrix[rows(CMatrix),cols(CMatrix)])
	st_matrix(pvals,p_vals)
	st_matrix(bbetas,boots_betas)
	st_matrix(sbetas,sorted_betas)
	st_matrix(confb,(lconfb, uconfb))
}
else {
	printf("\n{error:too few subsamples left to compute standard errors}\n")
	exit(error(430))
}

/* end of function std_erf */
}

end
/* end of program arhomme */

program cmd_in, rclass
	
	tokenize `"`0'"', parse("(")
	mac shift 2
	local options "`*'"
	gettoken sel options : options, parse(")")
	local options = subinstr("`options'","(","",.)
		
	local n_opt : word count `options'
	local idx = 1

	while (`idx'<=`n_opt') {
		local temp_w : word `idx' of `options'
		local is_inp = strpos("`temp_w'",")")
		
		if (`is_inp' !=0) {
			local options : subinstr local options "`temp_w'" ""
		}
		local idx = `idx' + 1
	}
	local options = stritrim("`options'")
	local options = strltrim("`options'")
	
	local rho = (strpos("`options'","rho") != 0)
	local tau = (strpos("`options'","tau") != 0)
	local rep = (strpos("`options'","rep") != 0)
	local sub = (strpos("`options'","sub") != 0)
	local instr = (strpos("`options'","instr") != 0)
	local cop = (strpos("`options'","cop") != 0)
	local mesh = (strpos("`options'","mesh") != 0)
	local cent = (strpos("`options'","cent") != 0)
	local q = (strpos("`options'","q") != 0)
	local gau = (strpos("`options'","gau") != 0)
	local fra = (strpos("`options'","fra") != 0)
	local plack = (strpos("`options'","plack") != 0)
	local joe = (strpos("`options'","joe") != 0)
	local gra = (strpos("`options'","gra") != 0)
	local nostd = (strpos("`options'","nostd") != 0)
	local out = (strpos("`options'","out") != 0)
	local fill = (strpos("`options'","fill") != 0)
	
	return local opt `"`options'"'
	return local rho `"`rho'"'
	return local tau `"`tau'"'
	return local rep `"`rep'"'
	return local sub `"`sub'"'
	return local instr `"`instr'"'
	return local cop `"`cop'"'
	return local mesh `"`mesh'"'
	return local cent `"`cent'"'
	return local q `"`q'"'
	return local gau `"`gau'"'
	return local fra `"`fra'"'
	return local plack `"`plack'"'
	return local joe `"`joe'"'
	return local gra `"`gra'"'
	return local nostd `"`nostd'"'
	return local out `"`out'"'
	return local fill `"`fill'"'
	/* end of sub-program cmd_in */
end


program cmd_out

syntax [anything], [dep(string) regs(string) nvar(string) seldep(string) selreg(string) nsel(string) beta(string) cov(string) nq(string) quant(string) conf(string) pvals(string) cop(string)]

di as text "{hline 13}{c TT}{hline 64}"
di as text %12s abbrev("`dep'",12) " {c |}" _col(21) "Coef.   Std. Err.     z     P>|z|     [95% Conf. Interval]"
di as text "{hline 13}{c +}{hline 64}"
local seldep = abbrev("`seldep'",12)
di as text "{bf:`seldep'}" _col(14) "{c |}"

local line=1
while(`line'<=`nsel') {
	local temp_name: word `line' of `selreg'
	local b = `beta'[1,`line']
	local std = sqrt(`cov'[`line',`line'])
	local z = `b'/`std'
	local p = 2*(1-normal(abs(`z')))
	local lb = `b'+invnormal(.025)*`std'
	local ub = `b'+invnormal(.975)*`std'
	di as text %12s abbrev("`temp_name'",12) " {c |}  " as result %9.8g `b' _col(28) %9.8g `std' _col(40) %6.2f `z' _col(49) %4.3f `p' _col(58) %9.8g `lb' "   " %9.8g `ub'
	local line = `line'+1
}
local b = `beta'[1,`nsel'+1]
local std = sqrt(`cov'[`nsel'+1,`nsel'+1])
local z = `b'/`std'
local p = 2*(1-normal(abs(`z')))
local lb = `b'+invnormal(.025)*`std'
local ub = `b'+invnormal(.975)*`std'
di as text %12s "_cons" " {c |}  " as result %9.8g `beta'[1,`nsel'+1] _col(28) %9.8g sqrt(`cov'[`nsel'+1,`nsel'+1]) _col(40) %6.2f `z' _col(49) %4.3f `p' _col(58) %9.8g `lb' "   " %9.8g `ub'
di as text "{hline 13}{c +}{hline 64}"

local eqs = 0
while (`eqs'<`nq') {
	local temp_q = `quant'[`eqs'+2,1]
	local temp_q = abbrev("`temp_q'_quantile",11)
	di as text "{bf:.`temp_q'}" _col(14) "{c |}"
	local b = `beta'[1,`nsel'+2+`eqs'*`nvar']
	local std = sqrt(`cov'[`nsel'+2+`eqs'*`nvar',`nsel'+2+`eqs'*`nvar'])
	local z = `b'/`std'
	local p = `pvals'[`eqs'*`nvar'+1,1]
	local lb = `conf'[`eqs'*`nvar'+1,1]
	local ub = `conf'[`eqs'*`nvar'+1,2]
	di as text %12s "_cons" " {c |}  " as result %9.8g `b' _col(28) %9.8g `std' _col(40) %6.2f `z' _col(49) %4.3f `p' _col(58) %9.8g `lb' "   " %9.8g `ub'

	
	local line=1
	while(`line'<`nvar') {
		local temp_name: word `line' of `regs'
		local b = `beta'[1,`line'+`nsel'+2+`eqs'*`nvar']
		local std = sqrt(`cov'[`line'+`nsel'+2+`eqs'*`nvar',`line'+`nsel'+2+`eqs'*`nvar'])
		local z = `b'/`std'
		local p = `pvals'[`eqs'*`nvar'+`line'+1,1]
		local lb = `conf'[`eqs'*`nvar'+`line'+1,1]
		local ub = `conf'[`eqs'*`nvar'+`line'+1,2]
		di as text %12s abbrev("`temp_name'",12) " {c |}  " as result %9.8g `b' _col(28) %9.8g `std' _col(40) %6.2f `z' _col(49) %4.3f `p' _col(58) %9.8g `lb' "   " %9.8g `ub'
		local line = `line'+1
	}
	di as text "{hline 13}{c +}{hline 64}"
	local eqs = `eqs'+1
}
local b = `beta'[1,`nsel'+2+`nq'*`nvar']
local std = sqrt(`cov'[`nsel'+2+`nq'*`nvar',`nsel'+2+`nq'*`nvar'])
if ("`cop'" == "plackett" | "`cop'" == "joema") {
	local z = (`b'-1)/`std'
	di as text _col(14) "{c |}" _col(21) "Coef.   Std. Err.   rho=1   p_val     [95% Conf. Interval]"
	di as text "{hline 13}{c +}{hline 64}"
}
else {
	local z = `b'/`std'
}
local p = `pvals'[`nq'*`nvar'+1,1]
local lb = `conf'[`nq'*`nvar'+1,1]
local ub = `conf'[`nq'*`nvar'+1,2]
di as text "{bf:_anc}" _col(14) "{c |}"
di as text %12s "rho" " {c |}  " as result %9.8g `b' _col(28) %9.8g `std' _col(40) %6.2f `z' _col(49) %4.3f `p' _col(58) %9.8g `lb' "   " %9.8g `ub'
di as text "{hline 13}{c BT}{hline 64}"
/* end of sub-program cmd_out */
end

