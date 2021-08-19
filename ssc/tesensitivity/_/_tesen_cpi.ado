// NOTES ON ORGANIZATION OF CODE
//  - The main program _tesen_cpi consists of 8 steps listed below
//  - Section A are Stata programs used by _tesen_cpi 
//  - Section B are mata functions used by these programs

// STEPS IMPLEMENTING _tesen_cpi
//  1. Define temporary variables
//  2. Parse input 
//  3. Calculate propensity score(s)
//  4. Steps required for particular statistics
//  4.1 (Averaged stats: calculate interpolation nodes)
//  4.2 (CQTE: approximate quantile function limits)
//  4.3 (ATET: unconditional expectations)
//  5. Form matrix of c-dependence values
//  6. Calculate bounds on TE statistic for each c
//  6.1 Monotonize solution
//  7. Calculate breakdown point
//  8. Return results

// PRIVATE STATA PROGRAMS USED BY _tesen_cpi
//  A.1 Stata programs that calculate bounds on a treatment effect statistics
//      for one value of c-dependence (one program for each statistic)
//  A.2 Stata programs that calculate the breakdown point (a general bisection 
//      algorithm, and a wrapper function handling interface with bisection 
//      algorithm)
//  A.3 Auxiliary code for calculation of QTE.
//  A.4 Miscellaneous Utilities.

// PRIVATE MATA FUNCTIONS USED BY _tesen_cpi
//  B.1 Functions to calculate treatment effects statistics
//  B.2 PCHIP approximations and integrals
//  B.3 Miscellaneous Utilities

// PROGRAM: tesensitivity conditional partial independence
// SYNTAX/DOCUMENTATION: See Stata help file
program define _tesen_cpi, eclass

	// =========================================================================
	// 1. Define temporary variables
	// =========================================================================
	
	tempvar xw0 xw1 pindex p0 p1 pmax p11 p10 xnodes ynodes coef tau_n_0 tau_n_1
	tempvar exp_y0 exp_y1 up0 up1 c_table c_search_table lb ub b V
	tempvar wsupp call cref
	tempvar bscoef0 bscoef1 

	// =========================================================================
	// 2. Parse Input
	// =========================================================================

	syntax anything [if] [in],    ///
		 [cqte cate ate atet qte  ///
		 COVariates(string)	      ///
		 QCOVariates(string)      ///
		 MEDian                   ///
		 Quantile(real 0.5)      ///
		 Cgrid(int 40)            ///
		 CREFerence               ///
		 BREAKdown(real 0)        ///
		 NOBREAKdown              ///
		 nodes(int 100)          ///
		 tol(real 0.001)          ///
		 verbose				  ///
		 debug]
	
	if "`debug'" != "" {
		di "command line input is: `0'"
	}
	
	// parse model specification
	_parse expand eqn op: anything
	gettoken ovar omvarlist : eqn_1
	gettoken tvar tmvarlist : eqn_2
	
	// check if covariates are the same for both models
	local covariates_equal : list omvarlist == tmvarlist
	if ~`covariates_equal'{
		local tmvarlist : list omvarlist|tmvarlist
		di as error "{p}currently, covariates in the outcome and treatment models " ///
		            "must be the same, will use union of both varlists.{p_end}" ///
					"{p}covariates used are: `tmvarlist' {p_end}" 
	}
	
	// parse variables	
	local Y `ovar'
	local X `tvar'
	fvrevar `tmvarlist' // this expands factor variables using temporary variables
	local W `r(varlist)'
	
	// mark sample
    marksample touse
    markout `touse' `Y' `X' `W'
	
	// calculate dimensions
	qui count if `touse'
	local nobs = r(N)
	local K: word count `W'
	local nvars = `K' + 2 // treatment + covariates + intercept
	
	// process verbose + debug option
	local verbose = "`verbose'" != ""
	local debug = "`debug'" != ""
	
	// process nobreakdown option
	if "`nobreakdown'" == "nobreakdown"{
		local breakdown .
	}
	
	// check if treatment variable is binary
	_checkbinary `X', expect_supp(0, 1) fatal
	// TODO: throws error if support of treatment isn't 0/1 - include other
	//       defaults w/ warnings?
	
	// check if outcome variable is binary
	_checkbinary `Y'
	local binary_outcome `s(`Y'_binary)'
	if `binary_outcome' {
		_checkbinary `Y', expect_supp(0, 1) fatal
		// TODO: throws error if support of outcome isn't 0/1 - include other
		//       defaults w/ warnings?
	}

	// check for multiple statistics and store statistic type
	local stat `cqte'`cate'`ate'`atet'`qte'
	if strlen("`stat'") > 4 {
		di as error "only one statistic can be calculated in a single call to " /// 
		            "tesensitivity cpi"
		qui error 109
	}
	local cond_stat = ("`cate'" != "") | ("`cqte'" != "")
	local qtl_stat  = ("`qte'" != "") | ("`cqte'" != "")
	
	// store the name of the c_function to use (this is the function
	// that calculates bounds for a single c-dependence value)
	local c_function `stat'_bounds_c
	if `binary_outcome'{
		local c_function binary_`c_function'	
	}
	
	// check if binary outcome, check only ate specified
	if `binary_outcome' & "`stat'" != "ate" {
		di as error "for binary outcome, only ate is currently supported"
		error 109
	}
	
	// form covariate matrix for conditional statistics
	// TODO: move this code to auxiliary program?
    if `cond_stat' {

		local ncovariates : word count `covariates'	
		local nqcovariates : word count `qcovariates'
			
		// default to median if selected or mean otherwise
		if "`median'" != "" | "`covariates'" == "median" | "`qcovariates'" == "median" {
			foreach v of varlist `W' {
				_pctile `v' if `touse', p(50)
				matrix `wsupp' = (nullmat(`wsupp'), r(r1))
			}
			matrix colnames `wsupp' = `W'
		}
		else {
			quietly mean `W' if `touse'
			matrix `wsupp' = e(b)
			matrix colnames `wsupp' = `W' 
		}	
			
		// overwrite covariate matrix with custom direct values if specified
		if `ncovariates' == 1 & "`covariates'" != "mean" & "`covariates'" != "median" {
			local ncov : colsof `covariates'
			local nrow : rowsof `covariates'
			// transpose if passed a column vector rather than row vector
			if `ncov' < `nrow' {
				matrix `covariates' = `covariates''
				local ncov : colsof `covariates'
			}
			local covnames : colnames `covariates'
			local covname1 : word 1 of `covnames'
			if "`covname1'" == "c1" {
				matrix `wsupp' = `covariates'
				matrix colnames `wsupp' = `W' 
			}
			else {
				forvalues i = 1/`ncov' {
					local v : word `i' of `covnames'
					tempname newentry
					matrix `newentry' = `covariates'[1, "`v'"]
					matrix `wsupp'[1,colnumb(`wsupp', "`v'")] = `newentry'
				}
			}
		}				
		// convert list to matrix if supplied
		else if `ncovariates' > 1 {
			forvalues i = 1/`ncovariates'{
				local newval : word `i' of `covariates'
				matrix `wsupp'[1,`i'] = `newval'
			}
			matrix colnames `wsupp' = `W' 
		}

		// overwrite covariate matrix with custom quantile values if specified
		if `nqcovariates' == 1 & "`qcovariates'" != "median" {
			local nqcov : colsof `qcovariates'
			local nqrow : rowsof `qcovariates'
			// transpose if passed a column vector rather than row vector
			if `nqcov' < `nqrow' {
				matrix `qcovariates' = `qcovariates''
				local nqcov : colsof `qcovariates'
			}
			// check names of matrix
			local covnames : colnames `qcovariates'
			local covname1 : word 1 of `covnames'
			// if unlabeled, must be all covaraites in order - add names
			if "`covname1'" == "c1" {
				matrix colnames `qcovariates' = `W'
				local covnames `W'
			}
			// calculate quantiles and replace covariate values for each
			forvalues i = 1/`nqcov' {
				local v : word `i' of `covnames'
				local pct = `qcovariates'[1, `i'] * 100
				_pctile `v' if `touse', p(`pct')
				matrix `wsupp'[1,colnumb(`wsupp', "`v'")] = r(r1)
			}
		}
		// convert list to matrix if supplied and replace covariate values (must be all covariates)
		else if `nqcovariates' > 1 {
			forvalues i = 1/`nqcovariates'{ 
				local v : word `i' of `W'
				local newval : word `i' of `qcovariates'
				local pct = `newval' * 100 
				_pctile `v' if `touse', p(`pct')
				matrix `wsupp'[1,`i'] = r(r1)
			}
		} 
	
		// add a constant to covariate support
		matrix `wsupp' = (`wsupp', J(rowsof(`wsupp'), 1, 1))
		matrix colnames `wsupp' = `W' _const
	
		if `debug'{
			tempname wsuppt
			matrix `wsuppt' = `wsupp''
			noi di "covariate support to be used is:" _continue
			matrix list `wsuppt'
		}
	
	}
	// for non-conditional statistics, just save the covariates to a matrix
	else {
		mkmat `W' if `touse', matrix(`wsupp')
		matrix `wsupp' = (`wsupp', J(`nobs', 1, 1))
		matrix colnames `wsupp' = `W'
	}
	
	// =========================================================================
	// 3. Calculate propensity score(s)
	// =========================================================================		
	qui logit `X' `W' if `touse', nolog

	matrix `pindex' = `wsupp' * e(b)'
    mata: p1  = invlogit(st_matrix("`pindex'")) // mata invlogit is vectorized
	mata: p0 = 1 :- p1
    mata: st_matrix("`p1'", p1)
	mata: st_matrix("`p0'", p0)
	mata: st_numscalar("`pmax'", max((p1[,1] \ p0[,1])))
	mata: mata drop p0 p1
	// TODO: For averages, it would be better to get max for each obs
	
	if `cond_stat' & `debug'{
		di as text "propensity scores are p0: " as result `p0' as text " p1: " as result `p1'
	}
	
	// =========================================================================
	// 4. Steps required for particular statistics
	// =========================================================================
	// These are steps that are calculated once and used as an input to the
	// functions that calculate the stat bounds for each c-dependence value
	
	// =========================================================================
	// 4.1 (Averaged stats: calculate interpolation nodes)
	// =========================================================================
	// TODO: this should be moved into mata if possible to avoid just leaving
	//       pchipcoefs in mata global memory
	if !`qtl_stat' & !`binary_outcome'{
		if `verbose' nois _dots 0, title(calculating interpolation nodes) reps(`nodes')
		
		// TODO: move this to mata
		forvalues j = 1(1)`nodes' {
			tempname coef
			local x_`j' = -cos((2*`j'-1)*(_pi)/(2*`nodes'))
			local x_`j' = (`x_`j'' + 1) * (1/2)
			capture qui qreg `Y' `X' `W' if `touse', quantile(`x_`j'')
			matrix `xnodes' = (nullmat(`xnodes') \ `x_`j'')
			matrix `coef' = e(b)
			matrix `ynodes' = (nullmat(`ynodes') \ `coef')
			if `verbose' nois _dots `j' 0
			
		}

		// Debugging: show quantile function interpolated
		if `debug' {
			svmat `xnodes', n(xnodes)
			svmat `ynodes', n(matcol)
			foreach v of varlist `W'{
				twoway scatter `ynodes'`v' xnodes, msize("vsmall") name("`v'")
				qui drop `ynodes'`v'
			}
			qui drop xnodes
		}
		
		// Form the pointer array of pchip coeficients
		mata: pchipcoefs = pchip_all_coef(st_matrix("`xnodes'"), /// 
										  st_matrix("`ynodes'"), `nvars')
										 
	}
	
	// =========================================================================
	// 4.2 (Quantile stats: approximate quantile function limits)
	// =========================================================================
	// TODO: better way to do this?
	if "`stat'" == "cqte" {
		
		local alpha_accel = 0.5
		local iterate 30
		
		// approximate quantile coefficients for tau -> 1
		local tau = 0.01
		capture qreg `Y' `X' `W' if `touse', quantile(`=1-`tau'')
		matrix `bscoef1' = e(b)
		if `verbose' nois _dots 0, title(calculating approximate upper limit quantile function) reps(`iterate')
		forvalues k=1(1)`iterate' {
			if `verbose' nois _dots `k' 0
			local tau = `alpha_accel'* `tau'
			capture qreg `Y' `X' `W' if `touse', quantile(`=1-`tau'')
			mata: mat_eq("`bscoef1'", "e(b)", "check")
			matrix `bscoef1' = e(b)
			if `check' == 1 {        
				continue, break
			}
		}
		if `verbose' nois di

		// approximate quantile coefficients for tau -> 0
		local tau = 0.01
		capture qreg `Y' `X' `W' if `touse', quantile(`tau')
		matrix `bscoef0' = e(b)
		if `verbose' nois _dots 0, title(calculating approximate lower limit quantile function) reps(`iterate')
		forvalues k=1(1)`iterate' {
			if `verbose' nois _dots `k' 0
			local tau = `alpha_accel' * `tau'
			capture qreg `Y' `X' `W' if `touse', quantile(`tau')
			mata: mat_eq("`bscoef0'", "e(b)", "check")
			matrix `bscoef0' = e(b)
			if `check' == 1 {
				continue, break
			}
		}
		if `verbose' nois di
	}
	
	// =========================================================================
	// 4.3 (ATET: unconditional expectations)
	// =========================================================================
	if "`stat'" == "atet"{
		qui reg `Y' `X' if `touse'
		matrix `exp_y1' = (1,1) * (e(b))'
		scalar `exp_y1' = `exp_y1'[1,1]
		matrix `exp_y0' = (0,1) * (e(b))'
		scalar `exp_y0' = `exp_y0'[1,1]

		qui summarize `X' if `touse'
		scalar `up1' = 1/r(N) * r(sum)
		scalar `up0' = 1/r(N) * (r(N) - r(sum))
		
	}
	
	// =========================================================================
	// 4.4 (Binary ATE: outcome probabilities)
	// =========================================================================
	if "`stat'" == "`ate'" & `binary_outcome'{
		qui logit `Y' `X' `W' if `touse', nolog // Run a logit of Y on (X, W)
		
		local nobs : rowsof(`wsupp')
		// calculate: \hat{P}(Y=1 | X=1, W=w) = \Lambda( \hat{\beta}' [1 W] )
		mata: p11 = invlogit((J(`nobs',1,1), st_matrix("`wsupp'")) * st_matrix("e(b)")')
		// calculate: \hat{P}(Y=1 | X=0, W=w) = \Lambda( \hat{\beta}' [0 W] )
		mata: p10 = invlogit((J(`nobs',1,0), st_matrix("`wsupp'")) * st_matrix("e(b)")')
		mata: st_matrix("`p10'", p10)
		mata: st_matrix("`p11'", p11)
		mata: mata drop p10 p11
		
	}
	
	// =========================================================================
	// 5. Form matrix of c-dependence values
	// =========================================================================
	
	// uniform grid over range of c
	mata : cgrid = rangen(0, 1, strtoreal(st_local("cgrid")))
	mata : st_matrix("`call'", cgrid)
	mata : mata drop cgrid
	
	forvalues i = 1/`cgrid' {
		local gridnames `"`gridnames' grid`i'"'
	}
	matrix rownames `call' = `gridnames'
	matrix roweq `call' = "grid"
	
	// add reference c-dependence values if requested
	if `"`creference'"' != ""{
		_tesen_cscale `X' `W' if `touse', cmax fullmodel
		matrix `cref' = r(cmax)
		mata : sort_st_matrix("`cref'", 1)
		matrix roweq `cref' = "cref"
		matrix `call' = (`call' \ `cref')
	}	
	
	// add the max c (used in calculations)
	matrix `call' = (`pmax' \ `call')

	// total number of observations
	local cnum = rowsof(`call')
	
	// =========================================================================
	// 6. Calculate c-dependence bounds on statistics
	// =========================================================================

	// form arguments for statistic selected (documented below in section A)
	if "`stat'" == "cqte" {
		local c_function_args `"`quantile' `p0' `p1' `wsupp' "`bscoef0'" "`bscoef1'" "`Y' `X' `W'" `touse'"'
	}
	else if "`stat'" == "atet" {
		local c_function_args `"`p0' `p1' `wsupp' pchipcoefs `nvars' `nobs' `exp_y0' `exp_y1' `up0' `up1'"'
	}
	else if "`stat'" == "qte" {
		local c_function_args `"`quantile' `p0' `p1' `wsupp' `tol' `Y' `X' "`W'" `touse'"'
	}
	else if "`stat'" == "ate" & `binary_outcome' {
		local c_function_args `"`p0' `p1' `p10' `p11'"'
	}
	else { // ate (continous) + cate
		local c_function_args `"`p0' `p1' `wsupp' pchipcoefs `nvars' `nobs'"'
	}
	
	// initialize output matrices
	matrix `c_table' = J(`cnum', 2, .)
	
	// calculate bounds for each c-dependence value
	if `verbose' nois _dots 0, title(calculating `stat') reps(`cnum')
	forvalues i=1/`cnum'{
        local c = `call'[`i', 1]    
		
        if `c' <= `pmax' { 
			`c_function' `c' `c_function_args'
			matrix `c_table'[`i', 1] = `s(lower)'
			matrix `c_table'[`i', 2] = `s(upper)'
		}
		else {
			matrix `c_table'[`i', 1] = `c_table'[1,1]
			matrix `c_table'[`i', 2] = `c_table'[1,2]
		}
		if `verbose' nois _dots `i' 0

    }
	if `verbose' nois di 
	
	// form full c_table and drop the max value
	matrix `c_table' = (`call', `c_table')
	matrix `c_table' = `c_table'[2...,1...]
	mata: sort_st_matrix("`c_table'", 1)

	// =========================================================================
	// 6.1 Monotonize the output
	// =========================================================================
	mata: apply_cumfunc("`c_table'", 2, &min()) 
	mata: apply_cumfunc("`c_table'", 3, &max())
	
	// =========================================================================
	// 7. Calculate breakdown point
	// =========================================================================
	if `breakdown' < . { 
		if `verbose' nois di as text "calculating breakdown point..."
		
		_breakdown `c_table' `tol' `breakdown' `c_function' `"`c_function_args'"' 
		local c_breakdown `s(output)'
	}
	else {
		local c_breakdown .
	}
			
	// =========================================================================
	// 8. Return results
	// =========================================================================
	// NOTES:
	//   - for compatibility with Stata's ereturn functionality, results are
	//     stored in e(b). The same information is stored in the matrix 
	//     e(c_table) which is organized intuitively (col 1: c values, 
	//     cols 2-3: lower, upper bounds)
	//   - in order to use ereturn functionality, have to store a covariance
	//     matrix e(V). Since we aren't dealing with inferent yet, this is just
	//     the identify matrix.

	// save all results in e(b) following normal naming conventions
	matrix `lb' = `c_table'[1...,2]'
	matrix `ub' = `c_table'[1...,3]'
	forvalues i = 1/`=`cnum' - 1' {
		local lbnames `"`lbnames' lb:c`i'"'
		local ubnames `"`ubnames' ub:c`i'"'
	}
	
	matrix colnames `lb' = `lbnames'
	matrix colnames `ub' = `ubnames'
	matrix `b' = (`lb', `ub')
	local nb : colsof(`b')
	local allnames : colnames(`b')
	local alleq : coleq(`b')
	
	ereturn post `b', esample(`touse') depname(`Y') properties(b)
	
	// save results in c_table matrix (sorted)
	mata: sort_st_matrix("`c_table'", 1)
	
	// save the rest of the results		
	if "`creference'" != "" {
		ereturn matrix cref `cref', copy
	}
	ereturn matrix covsupp = `wsupp', copy
	ereturn matrix c_table = `c_table', copy
	
	ereturn hidden local estat_cmd _tesen_estat
	ereturn local tmodel logistic
	if `binary_outcome'{
		ereturn local omodel logistic
	} 
	else {
		ereturn local omodel linear quantile
	}
	ereturn local tvar `X'
	ereturn local stat `stat'
	ereturn local cmdline = stritrim(`"`0'"')
	ereturn local subcmd cpi
	ereturn local cmd tesensitivity
	
	ereturn scalar N = `nobs'
  	ereturn scalar y_breakdown = `breakdown'	
	ereturn scalar c_breakdown = `c_breakdown'
	
	// =========================================================================
	// 8.1 Cleanup
	// =========================================================================
	if !`qtl_stat' & !`binary_outcome'{
		mata: mata drop pchipcoefs
	}
		
end

// =============================================================================
// A.1 Bounds for a single c-dependence value for each statistic
// -----------------------------------------------------------------------------
// Notes:
// - these are primarily a stata interface to the mata functions in B.1
// =============================================================================

// PROGRAM: CQTE, single c-dependence value
// DESCRIPTION: Calculate bounds on the cqte for a given c-dependence value
// INPUT:
//   - c: (real scalar) c-dependence value
//   - qtl: (real scalar) quantile
//   - p0, p1: (real scalars) probability of treatment for person with given covariates
//   - bscoef0, bscoef1: (real scalars) approximate cqte values for c = 0,1
//   - varlist: (varlist) variables to be used in quantile regressions (Y X W)
//   - touse: (varname) sample flag
// TODO: Most of this should be moved to mata
program define cqte_bounds_c, sclass
	
	args c qtl p0 p1 wsupp bscoef0 bscoef1 varlist touse
	
	tempname qtl_bounds qtl_coef xw

	// calculate the arguments to the quantile function given c, p1, p0
	mata: qtls = cqtl_arg_c(`c', st_matrix("`p0'"), st_matrix("`p1'"), `qtl')
	mata: st_matrix("qtls", qtls)
	
	// calculate the upper and lower bound on the quantile function for
	// each potential outcome
	// There are 4 values:
	//   1. lower bound, x = 1
	//   2. upper bound, x = 0
	//   3. upper bound, x = 1
	//   4. lower bound, x = 0
	matrix `qtl_bounds' = J(4, 1, .)
	forvalues j = 1/4 {
		// select the right covariates for each set of coefficients
		// odd are treatment, even are control
		local nobs : rowsof(`wsupp')
		if mod(`j', 2) == 0{
			matrix `xw' = (J(`nobs', 1, 0), `wsupp')
		} 
		else {
			matrix `xw' = (J(`nobs', 1, 1), `wsupp')
		}
		
		// calculate the quantile regression if not on the boundary
		// use the approximate boundary coeficients if not
		local qtl = qtls[`j', 1]
		if (`qtl' > 0) & (`qtl' < 1) {
			capture qreg `varlist' if `touse', quantile(`qtl')
			matrix `qtl_coef' = e(b)
		} 
		else if(`qtl' == 0) {
			matrix `qtl_coef' = `bscoef0'
		} 
		else if(`qtl' == 1) {
			matrix `qtl_coef' = `bscoef1'
		}
	
		// calcaulte the quantile function value
		matrix `qtl_bounds'[`j', 1] = `xw' * `qtl_coef'' 
	}
	// take differences to calculate CQTE
	mata: qtl_bounds  = st_matrix("`qtl_bounds'")
	mata: qtl_bounds  = rowshape(qtl_bounds, 2)
	mata: cqtl_bounds = qtl_bounds[,1] - qtl_bounds[,2]
	mata: st_local("lower", strofreal(cqtl_bounds[1,1]))
	mata: st_local("upper", strofreal(cqtl_bounds[2,1]))
	
	mata: mata drop cqtl_bounds qtl_bounds qtls
	
	sreturn local lower = `lower'
	sreturn local upper = `upper'
	
end

// PROGRAM: CATE bounds, single c-dependence value
// DESCRIPTION: Calculate bounds on the cate for a given c-dependence value
// INPUT:
//   - c: (real scalar) c-dependence value
//   - p0, p1: (real scalars) probability of treatment for person with given covariates
//   - wsupp: (stata matrix) matrix of covariates (1 x nvars)
//   - nvars: (scalar int) number of covariates + intercept + treatment
//   - nobs: (scalar int) number of observations
program define cate_bounds_c, sclass

	args c p0 p1 wsupp pchipcoefs nvars nobs
	tempname bounds
	
	mata: p0 = st_matrix("`p0'")
	mata: p1 = st_matrix("`p1'")
	
	mata: bds = cate_integral_c(`c', p0, ///
								p1, st_matrix("`wsupp'")', ///
								`pchipcoefs', `nvars', 1, 0)	
	mata: st_matrix("`bounds'", bds)
	mata: mata drop p0 p1 bds
	
	sreturn local lower = `bounds'[1,1]
	sreturn local upper = `bounds'[2,1]
	
end

// PROGRAM: ATE bounds, single c-dependence value, continuous outcome
// DESCRIPTION: Calculate bounds on the ate (continuous) for a given c-dependence value
// INPUT:
//   - c: (real scalar) c-dependence value
//   - p0, p1: (real col vectors) probability of treatment for each observation
//   - wsupp: (stata matrix) matrix of covariates (nobs x K)
//   - pchipcoefs: (mata pointer arrray) matrix of pointers to pchip coefficients
//                                       (i.e., name of an object in mata global memory)
//   - nvars: (scalar int) number of covariates + intercept + treatment
//   - nobs: (scalar int) number of observations
program ate_bounds_c, sclass

	args c p0 p1 wsupp pchipcoefs nvars nobs
	tempname bounds
	
	mata: bds = J(2, `nobs', .)
	
	mata: p0 = st_matrix("`p0'")
	mata: p1 = st_matrix("`p1'")
	
	forvalues n=1/`nobs'{
	
		mata: bds[,`n'] = cate_integral_c(`c', p0[`n', 1], p1[`n', 1], ///
										  st_matrix("`wsupp'")[`n',]',     ///
									      `pchipcoefs', `nvars', 1, 0)		
	}
	mata: st_matrix("`bounds'", mean(bds'))
	
	mata: mata drop p0 p1 bds
	
	sreturn local lower = `bounds'[1, 1]
	sreturn local upper = `bounds'[1, 2]	
	
end

// PROGRAM: ATE bounds, single c-dependence value, binary outcome
// DESCRIPTION: Calculate bounds on the ate (binary) for a given c-dependence value
// INPUT:
//   - c: (real scalar) c-dependence value
//   - p0, p1: (real col vectors) probability of treatment for each observation
//   - p10, p11: (real col vectors) probablity outcome = 0,1 conditional on X = 1
//                              for each observation
program binary_ate_bounds_c, sclass

	args c p0 p1 p10 p11
	tempname bounds
	
	mata: bds = binary_ate_c(`c', st_matrix("`p0'"), st_matrix("`p1'"), st_matrix("`p10'"), st_matrix("`p11'")) 	
	mata: st_matrix("`bounds'", bds)
	
	mata: mata drop bds
	
	sreturn local lower = `bounds'[1, 1]
	sreturn local upper = `bounds'[1, 2]	
	
end

// PROGRAM: ATET bounds, single c-dependence value
// DESCRIPTION: Calculate bounds on the atet for a given c-dependence value
// INPUT:
//   - c: (real scalar) c-dependence value
//   - p0, p1: (real col vectors) probability of treatment for each observation
//   - wsupp: (stata matrix) matrix of covariates (nobs x K)
//   - pchipcoefs: (mata pointer arrray) matrix of pointers to pchip coefficients
//                                       (i.e., name of an object in mata global memory)
//   - nvars: (scalar int) number of covariates + intercept + treatment
//   - nobs: (scalar int) number of observations
//   - exp_y0: (stata scalar real) unconditional expectation of Y | X = 0
//   - exp_y1: (stata scalar real) unconditional expectation of Y | X = 1
//   - up0: (stata scalar real) unconditional probability of X = 0
//   - up1: (stata scalar real) unconditional probability of X = 1
// TODO: Additional calculations should be moved to mata
program atet_bounds_c, sclass

	args c p0 p1 wsupp pchipcoefs nvars nobs exp_y0 exp_y1 up0 up1
	tempname ub lb
	
	mata: bds = J(2, `nobs', .)
	
	mata: p0 = st_matrix("`p0'")
	mata: p1 = st_matrix("`p1'")
	
	forvalues n=1/`nobs'{
		mata: bds[,`n'] = cate_integral_c(`c', p0[`n', 1], p1[`n', 1], ///
										  st_matrix("`wsupp'")[`n',]',     ///
									      `pchipcoefs', `nvars', 0, 1)		
	}
	
	mata: bds =  mean(bds')
	mata: lower = st_numscalar("`exp_y1'") - ///
	              ((bds[1,2] - st_numscalar("`up0'")*st_numscalar("`exp_y0'")) ///
				  / st_numscalar("`up1'"))
	mata: upper = st_numscalar("`exp_y1'") - ///
	              ((bds[1,1] - st_numscalar("`up0'")*st_numscalar("`exp_y0'")) ///
				  / st_numscalar("`up1'"))
				  
	mata: st_numscalar("`ub'", upper)
    mata: st_numscalar("`lb'", lower)
	
	mata: mata drop p0 p1 bds

	sreturn local lower = `lb'
	sreturn local upper = `ub'	
	
end

// PROGRAM: QTE bounds, single c-dependence value
// DESCRIPTION: Calculate bounds on the qte for a given c-dependence value
// INPUT:
//   - c: (real scalar) c-dependence value
//   - qtl: (real scalar) quantile
//   - p0, p1: (real col vectors) probability of treatment for each observation
//   - wsupp: (stata matrix) matrix of covariates (nobs x K)
//   - tol: (scalar real) precision tolerance used in quantile calculations
//   - Y, X, W: (varlists) variables used for quantile regressions
//   - touse: (varname) sample flag
program qte_bounds_c, sclass

	args c qtl p0 p1 wsupp tol Y X W touse
	
	// TODO: the qte auxiliary functions uses these directly from mata global 
	//       memory - clean this up so they are passed by the functions rather 
	//       than hanging around in mata global memory
	local nobs : rowsof(`wsupp')
	mata: xw0 = (J(`nobs', 1, 0), st_matrix("`wsupp'"))
	mata: xw1 = (J(`nobs', 1, 1), st_matrix("`wsupp'"))
	mata: p0 = st_matrix("`p0'")
	mata: p1 = st_matrix("`p1'")

    LQ `c' `Y' `X' "`W'" `touse' `tol' `qtl' 0
    local LQ0 `s(LQ0)'
    UQ `c' `Y' `X' "`W'" `touse' `tol' `qtl' 1
    local UQ1 `s(UQ1)'
    local UQTE = `UQ1' - `LQ0'
	
	LQ `c' `Y' `X' "`W'" `touse' `tol' `qtl' 1
    local LQ1 `s(LQ1)'
    UQ `c' `Y' `X' "`W'" `touse' `tol' `qtl' 0    
    local UQ0 `s(UQ0)'
    local LQTE = `LQ1' - `UQ0'
	
	mata: mata drop xw1 xw0 p1 p0
	
	// TODO: these are other mata variables left in global memory by the
	//       auxiliary functions - should be cleaned up
	mata: mata drop Fy0w Fy1w LF0W LF1W UF0W UF1W index vecLF vecUF yhi ylow
	
	sreturn local upper = `UQTE'
    sreturn local lower = `LQTE'

end

// =============================================================================
// A.2 Programs for calculating the breakdown point 
// =============================================================================

// PROGRAM: breakdown point
// DESCRIPTION: calculate the breakdown point for treatment effect statistic
// INPUT:
//   - c_table: (stata matrix) col.1 = c-dep vals, cols 2,3 = lower, upper bounds
//   - tol: (scalar real) precision tolerance for breakdown point
//   - breakdown_y (scalar real) value for conclusion (stat > breakdown_y)
//   - function (function) function to calculate stat bounds for given c-dep.
//   - arguments (anything) list of arguments passed to the fucntion
// IMPLEMENTATION NOTES: 
//  - the grid of c-dependence is ordered, and the upper (lower) bounds are 
//    increasing (decreasing) monotonically with c. To start the bisection 
//    algorithm, find all the indicies where the lower (upper) bound is above 
//    (below) the conclusion value. This is the lower bound for the breakdown 
//    point, and the next c is the uppder bound. 
//  - The clow, chi values passed to the bisection algorithm are the values of
//    c such that bound(clow) < breakdown_y < bound(chi), where "bound" is either
//    the lower or upper bound function, depending on whether the bound(0) is
//    above or below breakdown_y. If it is above (below), then we are looking for 
//    where the lower (upper) bound crosses breakdown_y.
//  - If bound(0) < breakdown_y, then bound(clow) < bound(chi), otherwise the
//    reverse.
//  - the Mata function `breakdown_start_points` is written to handle this. It
//    saves the correct values to stata macros clow, chi.
program define _breakdown, sclass

	args c_table tol breakdown_y function arguments
	
	// get the values of the c-grid above and below the breakdown point	
	if `c_table'[1,2] > `breakdown_y' {
		local side "lower"
	}
	else {
		local side "upper"		
	}
	mata: breakdown_start_points("`c_table'", `breakdown_y', "`side'")
	
	// check if breakdown point = 1 (i.e., no breakdown), otherwise run bisection algorithm
	if `clow' == 1 {
		sreturn local output = 1
	}
	else {
		bisection `clow' `chi' `side' `tol' `breakdown_y' `function' `"`arguments'"'
		sreturn local output = `s(output)'
	}
		
end

// PROGRAM: bisection algorithm
// INPUT
//   - clow (scalar real) value of c such that bound(clow) < y bound(chi) where
//                        bound is the bound that could cross y. 
//   - chi (scalar real) see above 
//   - side (scalar string) "lower"/"upper": bound that could cross y
//   - tol: (scalar real) precision tolerance 
//   - y (scalar real) value for conclusion (stat > y)
//   - function (function) function to calculate stat bounds for given c-dep.
//   - arguments (anything) list of arguments passed to the fucntion

// IMPLEMENTATION NOTES: 
// - all functions must take as their first argument the value of c-dependence. 
//   After that, the function can take an arbitrary number of arguments.
// - also used in the calculate of qte
program define bisection, sclass
    args clow chi side tol y function arguments
    local cmid = (`chi' + `clow')/2

    `function' `cmid' `arguments'
    local fcmid `s(`side')'

    if abs(`fcmid' - `y') < `tol' | abs((`chi' - `clow')/2) < `tol' {
        sreturn local output = `cmid'
    }
    else {
        if `fcmid' < `y' {
            local clow = `cmid'
        }
        else {
            local chi = `cmid'
        }
        bisection `clow' `chi' `side' `tol' `y' `function' `"`arguments'"'
    }
end
// TODO: this is going to calculate both bounds and throw one away
//  is this a significant efficiency loss? 

// =============================================================================
// A.3 Auxiliary code for QTE calculation
// =============================================================================
// TODO: This should be moved to mata and/or documented

program define UF1, sclass // The upper bound on F_{Y_1}(y)
    args gridy gridc Y X W touse

    // Estimate F_{Y|X,W}(y | x,w)
    tempvar indicatorY
    qui gen `indicatorY' = (`Y' <= `gridy') if `touse' // indicator(Y<=y)
    qui logit `indicatorY' `X' `W' if `touse', nolog // logit indicator(Y<=y) on (1,X,W)
    mata: Fy1w = invlogit(xw1 * st_matrix("e(b)")') // coefficient*(X,W,1)
    mata: UF1W = min3(((p1 :* Fy1w) :/ (p1 :- `gridc')) :* (p1 :> `gridc') + (p1 :<= `gridc'), (p1 :* Fy1w :+ `gridc') :/ (p1 :+ `gridc'), p1 :* Fy1w :+ (1 :- p1))
    mata: st_local("UF1", strofreal(mean(UF1W)))
    sreturn local bound = `UF1'
end

program define UF0, sclass // The upper bound on F_{Y_0}(y)
    args gridy gridc Y X W touse
    // Estimate F_{Y|X,W}(y | x,w)
    tempvar indicatorY
    qui gen `indicatorY' = (`Y' <= `gridy') if `touse' // indicator(Y<=y)
    qui logit `indicatorY' `X' `W' if `touse', nolog // logit indicator(Y<=y) on (1,X,W)
    mata: Fy0w = invlogit(xw0 * st_matrix("e(b)")') // coefficient*(X,W,1)
    mata: UF0W = min3(((p0 :* Fy0w) :/ (p0 :- `gridc')) :* (p0 :> `gridc') + (p0 :<= `gridc'), (p0 :* Fy0w :+ `gridc') :/ (p0 :+ `gridc'), p0 :* Fy0w :+ (1 :- p0))
    mata: st_local("UF0", strofreal(mean(UF0W)))

    sreturn local bound = `UF0'
end
 
program define LF1, sclass // The lower bound on F_{Y_1}(y)
    args gridy gridc Y X W touse

    // Estimate F_{Y|X,W}(y | x,w)
    tempvar indicatorY
    qui gen `indicatorY' = (`Y' <= `gridy') if `touse' // indicator(Y<=y)
    qui logit `indicatorY' `X' `W' if `touse', nolog // logit indicator(Y<=y) on (1,X,W)
    mata: Fy1w = invlogit(xw1 * st_matrix("e(b)")') // coefficient*(X,W,1)
    mata: LF1W = max3((p1 :* Fy1w) :/ (p1 :+ `gridc'), ((p1 :* Fy1w :- `gridc') :/ (p1 :- `gridc')) :* (p1 :> `gridc'),  p1 :* Fy1w)
    mata: st_local("LF1", strofreal(mean(LF1W)))
    sreturn local bound = `LF1'
end

program define LF0, sclass // The lower bound on F_{Y_0}(y)
    args gridy gridc Y X W touse

    // Estimate F_{Y|X,W}(y | x,w)
    tempvar indicatorY
    qui gen `indicatorY' = (`Y' <= `gridy') if `touse' // indicator(Y<=y)
    qui logit `indicatorY' `X' `W' if `touse', nolog // logit indicator(Y<=y) on (1,X,W)
    mata: Fy0w = invlogit(xw0 * st_matrix("e(b)")') // coefficient*(X,W,1)
    mata: LF0W = max3((p0 :* Fy0w) :/ (p0 :+ `gridc'), ((p0 :* Fy0w :- `gridc') :/ (p0 :- `gridc')) :* (p0 :> `gridc'),  p0 :* Fy0w)
    mata: st_local("LF0", strofreal(mean(LF0W)))
    sreturn local bound = `LF0'
end

program define UQ, sclass // the upper bound on Q_{Y_x}(tau)
    args gridc Y X W touse tol tau treat // treat=1 or 0

    tempname ymax ymin vecLF
    qui sum `Y' if `touse'
    scalar `ymax' = r(max)
    scalar `ymin' = r(min)
    forvalues i = 2(1)9 {
        local y`i' = (`ymax' - `ymin') * (`=`i'-1'/9) + `ymin'
        LF`treat' `y`i'' `gridc' `Y' `X' "`W'" `touse' // lower bound for F_{Y_x}(y)
        local LF`treat'`i' `s(bound)'
    }
    local y1 `ymin'
    local y10 `ymax'
    local LF`treat'1 0 // h(y_min)=0
    local LF`treat'10 1 // h(y_max)=1
    forvalues i = 1(1)10 {
        matrix `vecLF' = (nullmat(`vecLF'), `LF`treat'`i'') // a vector of bound functions on the grid of y's
    }
    mata: vecLF = (st_matrix("`vecLF'"))'
    mata: index = selectindex((vecLF:<`tau')) // marks all the index of vecLF which is < y
    mata: ylow = index[rows(index),.] //corresponds to the largest LF that is smaller than y
    mata: yhi = ylow + 1
    mata: st_local("yhi", strofreal(yhi))
    mata: st_local("ylow", strofreal(ylow))
    local yhi = `y`yhi''
    local ylow = `y`ylow''
    bisection `ylow' `yhi' bound `tol' `tau' LF`treat' `"`gridc' `Y' `X' "`W'" `touse'"'
    sreturn local UQ`treat' = `s(output)'
end

program define LQ, sclass // the lower bound on Q_{Y_x}(tau)
    args gridc Y X W touse tol tau treat // treat=1 or 0
    tempname ymax ymin vecUF
    qui sum `Y' if `touse'
    scalar `ymax' = r(max)
    scalar `ymin' = r(min)
    forvalues i = 2(1)9 {
        local y`i' = (`ymax' - `ymin') * (`=`i'-1'/9) + `ymin'
        UF`treat' `y`i'' `gridc' `Y' `X' "`W'" `touse' // lower bound for F_{Y_x}(y)
        local UF`treat'`i' `s(bound)'
    }
    local y1 `ymin'
    local y10 `ymax'
    local UF`treat'1 0 // h(y_min)=0
    local UF`treat'10 1 // h(y_max)=1
    forvalues i = 1(1)10 {
        matrix `vecUF' = (nullmat(`vecUF'), `UF`treat'`i'') // a vector of bound functions on the grid of y's
    }
    mata: vecUF = (st_matrix("`vecUF'"))'
    mata: index = selectindex((vecUF:<`tau')) // marks all the index of vecUF which is < y
    mata: ylow = index[rows(index),.] //corresponds to the largest UF that is smaller than y
    mata: yhi = ylow + 1
    mata: st_local("yhi", strofreal(yhi))
    mata: st_local("ylow", strofreal(ylow))
    local yhi = `y`yhi''
    local ylow = `y`ylow''

    bisection `ylow' `yhi' bound `tol' `tau' UF`treat' `"`gridc' `Y' `X' "`W'" `touse'"'
    sreturn local LQ`treat' = `s(output)'
end

// =============================================================================
// A.4 Miscellaneous utilities
// =============================================================================
// PROGRAM: Check Binary
// DESCRIPTION: Checks if variables have binary support 
// INPUT:
//   - varlist (varlist) variables to check
//   - fatal (int 0/1) throw error if doesn't match `expect`
//   - expect (int 0/1) expect to be binary or note
//   - expect_supp (numlist) expected support values
// RETURN: if not fatal, return [varname]_binary for each variable (1 for binary)

program _checkbinary, sclass
	syntax varlist, [fatal expect(integer 1) expect_supp(numlist)]
	
	foreach v of varlist `varlist'{
		qui levelsof `v', local(lvls) 
		local nsupp: word count `lvls'
		local binary 1
		if `nsupp' > 2 {
			local binary 0
		}
		if "`fatal'" != "" & (`expect' != `binary') {
			di as error "expected `v' to have binary support, but it had `nsupp' support points"
			qui error 109
		}
		sreturn local `v'_binary = `binary'
		
		if "`expect_supp'" != "" & "`fatal'" != "" {
			local levels_match : list expect_supp == lvls
			if !`levels_match' {
				di as error "expected `v' to have support `expect_supp' but had support `lvls'"
				qui error 109
			}
		} 	
	}
	
end


// =============================================================================
// B. Mata Functions 
// =============================================================================

mata:
	
	// =========================================================================
	// B.1 Calculation of Treatment Effect statistics
	// =========================================================================
	
	// FUNCTION: Binary ATE Bounds
	// DESCRIPTION: Calculate bounds on the ATE for a given c-dependence value
	//              with a binary outcome variable.
	// INPUT: 
	//   - c: c-dependence value
	//   - p1, p0: N X 1 vector of propensity scores
	//   - p0: 1 - p1
	//   - p11: N X 1 vector of P(Y = 1|X = 1, W = w_i)
	//   - p10: N X 1 vector of P(Y = 1|X = 0, W = w_i)
	// RETURN: matrix (1 x 2): lower, upper bounds on ATE
	numeric matrix binary_ate_c(c, p0, p1, p10, p11)
	{
		UP1 = rowmin((
			((p11 :* p1) :/ (p1 :- c)) :* (p1 :> c) + (p1 :<= c),
			((p11 :* p1 :+ c)) :/ (p1 :+ c),
			(p11 :* p1) :+ (1 :- p1) 
		))
		LP1 = rowmax((
			(p11 :* p1) :/ (p1 :+ c),
			(((p11 :* p1) :- c) :/ (p1 :- c)) :* (p1 :> c),
			p11 :* p1	
		))
		UP0 = rowmin((
			((p10 :* p0) :/ (p0 :- c)) :* (p0 :> c) :+ (p0 :<= c), 
			((p10 :* p0 :+ c)) :/ (p0 :+ c),
			(p10 :* p0) :+ (1 :- p0) 
		))
		LP0 = rowmax((
			(p10 :* p0) :/ (p0 :+ c),
			(((p10 :* p0) :- c) :/ (p0 :- c)) :* (p0 :> c),
			p10 :* p0	
		))
		return(mean((LP1 - UP0, UP1 - LP0)), 1)
	}
	
	// FUNCTION: Conditional Quantile Argument 
	// DESCRIPTION: Calculate the arguments to the quantile function which are
	//              used to calculate upper and lower bounds on the quantile for a
	//              given a value of c-dependence.
	// INPUT:
	//   - c: scalar, c-dependence
	//   - p0, p1: scalar: propensity scores (and 1 - prop score)
	//   - qtl: scalar: quantile
	// RETURN: matrix (2 x 2): coefficients for argument to the quantile function.
	//         call the returned matrix m:
	//         - lower bound arg = m[1,1] + m[1,2] * quantile,
	//         - upper bound arg = m[2,1] + m[2,2] * quantile
	numeric colvector cqtl_arg_c(c, p0, p1, qtl)
	{

		limits = qtl_bound(c, p0, p1)
		coef   = qtl_coef(c, p0, p1)
		
		qtl_select = (limits[, 1] :<= J(8, 1, qtl)) :& (J(8, 1, qtl) :< limits[, 2])
		coef = select(coef, qtl_select)
		
		return(coef * (1 \ qtl))
	}
	
	// FUNCTION: CATE integral, single c dependence
	// DESCRIPTION: Calculate bounds on the conditional average treatment effect for
	//              for a given value of c-dependence.
	// INPUT:
	//  - c: scalar, c-depenendence value 
	//  - p0, p1: scalars: propensity scores (and 1 - prop score)
	//  - cov: colvector (K x 1): values of covariates
	//  - pchipcoefs: pointer matrix (1 x K): pointer to pchip coeficients for each
	//                covariate (for interpolated quantile regression coefficient function)
	//  - nvars: scalar: number of covariates (including constant, but not treatment)
	//  - cate, catt: logical: indicators to return cate and/or catt 
	// RETURN: colvector (2 x 1): lower, upper bound on CATE / CATT

	numeric matrix cate_integral_c(c, p0, p1, cov, pchipcoefs, nvars, cate, catt)
	{

		int_segs = J(8, 1, .)
		qtl_coef= J(4, nvars,.)
		
		// calculate the coeficients and limits
		limits = qtl_bound(c, p0, p1)
		coef   = qtl_coef(c, p0, p1)
		
		// calculate the integrals
		// outer loop: covariates
		// inner loop: intervals of integrals
		// TODO: is there a more efficient way to do this to avoid inner loop?
		for (k=1; k<=nvars; k++){
			for (i=1; i<=8; i++){
				int_segs[i,1] = analyint(limits[i, 1], limits[i,2], 
										   coef[i,2], coef[i,1],
										   *pchipcoefs[1,k])
			}
			// combine intervals of integration
			// NOTE: rowshape converts (1 \ ... \ 8) -> (1, 2 \ 3, 4 \ ...).
			//       given the order returned by `qtl_coef`, `qtl_bound`, this
			//       puts the segments of each integral in a row, so rowsum
			//       calculates the full integral
			qtl_coef[,k] = rowsum(rowshape(int_segs, 4))
			
		}
		
		// calculate bounds on CATE
		if (cate == 1){
			cate_bounds = J(2,1,.)
			control_cov = (0 \ cov)
			treat_cov = (1 \ cov)
			cate_bounds[1,1] = qtl_coef[1,] * treat_cov - qtl_coef[2,] * control_cov
			cate_bounds[2,1] = qtl_coef[3,] * treat_cov - qtl_coef[4,] * control_cov
			return(cate_bounds)
		}
		// calculate bounds on CATT
		if (catt == 1){
			exp_y0_bounds = J(2,1,.)	
			control_cov = (0 \ cov)
			exp_y0_bounds[1,1] = qtl_coef[4,] * control_cov // lower
			exp_y0_bounds[2,1] = qtl_coef[2,] * control_cov // upper
			return(exp_y0_bounds)
		}
	}
	
	// FUNCTION: Quantile Coefficients
	// DESCRIPTION: Returns the coeficients used to calculate the
	//   argument to the quantile function in the max/min quantile
	//   functions. These are documented in appendix B of an
	//   earlier unpublished version of MPZ2020.
	// INPUT:
	//  - c: scalar, c-dependence values
	//  - p0, p1: scalars: propensity scores (and 1 - prop score)
	// RETURN: matrix of coefficients (2 x 8). Columns: constant, slope. Rows: 
	//         There are 8 sets of coefficients, which are the combinations of 
	//         the treamtent, lower/upper bound, and the range the quantiles
	//         value falls into. The rows are ordered as they are used in calculations
	//         of the ATE:
	// 	    1. t1 , lower, seg1 
	//          2. ...,   ..., seg2
	//          3. t0 , upper, seg1
	//          4. ...,   ..., seg2
	//          5. t1 , upper, seg1
	//          6. ...,   ..., seg2
	//          7. t0 , lower, seg1
	//          8. ...,   ..., seg2
	numeric matrix qtl_coef(c, p0, p1)
	{
		numeric matrix coef
		
		if ((c < p0) & (c < p1)) {
			coef = (0     , 1 - c/p1 \ 
				- c/p1, 1 + c/p1 \ 
				0     , 1 + c/p0 \
				c/p0  , 1 - c/p0 \
				0     , 1 + c/p1 \
				c/p1  , 1 - c/p1 \
				0     , 1 - c/p0 \
				- c/p0, 1 + c/p0 )
		
		} else if ((p0 <= c) & (c < p1)) {
		
			coef = (0       , 1 - c/p1 \
				1 - 1/p1, 1/p1     \
				0       , 1 + c/p0 \
				1       , 0        \ 
				0       , 1/p1     \
				c/p1    , 1 - c/p1 \
				0       , 0        \ 
				-c/p0   , 1 + c/p0 )

		
		} else if ((p1 <= c) & (c < p0)) {
		
			coef = (0       , 0        \ 
				-c/p1   , 1 + c/p1 \
				0       , 1/p0     \
				c/p0    , 1 - c/p0 \
				0       , 1 + c/p1 \
				1       , 0        \ 
				0       , 1 - c/p0 \
				1 - 1/p0, 1/p0     )
		
		} else if ((p0 <= c) & (p1 <= c)){
		
			coef = (0        , 0      \
				1 - 1/p1 , 1/p1   \
				0        , 1/p0   \
				1        , 0      \ 
				0        , 1/p1   \
				1        , 0      \
				0        , 0      \ 
				1 - 1/p0 , 1/p0   )
		
		}
		return(coef)
	}
	
	// FUNCTION: Quatile Bounds
	// DESCRIPTION: The coefficients returned by qtl_coef depend on ranges
	//   that the quantile falls into. This function returns the corresponding
	//   matrix of lower and upper limits of those ranges for each set of
	//   coefficients. See Annex A of MPL2020
	// RETURN: matrix of lower and upper limits. Columns: lower limit, upper limit. 
	//   Rows: ordered as in the output of `qtl_coef`
	numeric matrix qtl_bound(c, p0, p1)
	{
		numeric matrix bounds
		
		if ((c < p0) & (c < p1)) {
			
			bound1 = .5
			bound2 = .5
			bound3 = .5
			bound4 = .5

		} else if ((p0 <= c) & (c < p1)) {
		
			bound1 = (1 - p1) / (1 - (p1 - c))
			bound2 = 1 / (1 + (c/p0))
			bound3 = c / (1-(p1 - c))
			bound4 = (c/p0) / (1 + c/p0)
			
		
		} else if ((p1 <= c) & (c < p0)) {
		
			bound1 = (c/p1) / (1 + c/p1)  
			bound2 = c / (1-(p0 - c))
			bound3 = 1 / (1 + (c/p1)) 
			bound4 = (1 - p0) / (1 - (p0 - c))
			
		} else if ((p0 <= c) & (p1 <= c)) {
			
			bound1 = p0
			bound2 = p0
			bound3 = p1
			bound4 = p1
			
		}
		bounds = (0   , bound1  \
			  bound1  , 1       \
			  0       , bound2  \ 
			  bound2  , 1       \
			  0       , bound3  \
			  bound3  , 1       \
			  0       , bound4  \
			  bound4  , 1       )
		
		return(bounds)
	}
	
	// =========================================================================
	// B.2 PCHIP approximations and integration
	// =========================================================================
	// NOTES:
	//   - This section provides code to construct piecewise cubic hermite 
	//     interpolating polynomials (pchip), and calculates interpolated values
	//     and integrals.
	
	// FUNCTION: PCHIP All Coefficients
	// DESCRIPTION: Calculates pchip coefficients for a series of functions
	//              with support on [0,1] given a set of nodes on a common
	//              grid on [a,b], for 0 < a < b < 1
	// INPUT: 
	//   - xnodes: colvector N x 1, grid of points between [0,1]
	//   - ynodes: matrix N x K, each column are the nodes for a function 
	//                           (e.g. y[n,k] = f[k](x[n])
	//   - nvars: ...
	// RETURN: pointer matrix, 1 x K: each column points to a N x 5 matrix
	//                                returned by `pchip`
	// NOTES:
	//   - Since [a,b] doesn't not cover the full support of the functions, the
	//     approach taken here is to first find the interpolated functions on 
	//     [a,b], then find the interpolated values at {0,1} and then recalculate
	//     the pchip coefficients including those points
	//   - TODO: This was in the original code. Is this right? It seems like it
	//           would only make the interpolated function worse to use the 
	//           interpolated points at {0,1}
	pointer matrix pchip_all_coef(xnodes, ynodes, nvars){
		pchipcoefs = J(1, nvars, NULL)
		
		// calculate all the pchip coefficients excluding 0/1
		for (k=1; k<=nvars; k++) {
			pchipcoefs[1,k] = & (pchip(xnodes, ynodes[,k]))
		}

		// calculate the 0/1 nodes by interpolation from the rest of the function
		coef1 = pchipval(*pchipcoefs[1,1],1)
		coef0 = pchipval(*pchipcoefs[1,1],0)
		for (k=2; k<=nvars; k++) {
			coef1 = (coef1, pchipval(*pchipcoefs[1,k],1))
			coef0 = (coef0, pchipval(*pchipcoefs[1,k],0))
		}
		
		// calcalate all the coefficients given the extended grid
		xnodes  = (0 \ xnodes \ 1)
		ynodes = (coef0 \ ynodes \ coef1)
		
		for (k=1; k<=nvars; k++) {
			pchipcoefs[1,k] = & (pchip(xnodes, ynodes[,k]))
		}
		
		return(pchipcoefs)	
	}
	
	// FUNCTION: PCHIP Coefficients
	// DESCRIPTION: Calculates coefficients to characterize the piecewise
	//              cubic hermite interpolating polynomial from a grid of nodes.
	// INPUT: 
	//   - x, colvector: a length K grid of function support points
	//   - y, colvector: a length K grid of function values at support grid
	// RETURN: K x 5 matrix: columns 1-3: coefficients, (b,c,d) as described
	//                       in the note below, columns 4-5, values of x,y grids.
	// NOTES:
	//  - The output of this function characterizes the function P(x) defined 
	//    in appendix B of Masten, Poirier and Zhang (2020)
	//  - Rather than store the canonical coefficients of the cubic polynomials,
	//    it is more convenient to coefficients in the following form. Dropping
	//    the grid subscripts so y = y_j, y' = y_{j + 1}, etc., for each interval
	//    there are coefficients (b,c,d) such that P(u) = y + s(d + s(c + sb)), 
	//    where s = u - x, for x < u < x'. d is defined in appendix B of MPZ2020
	//    and calculated by `pchipslopes`. There is an explicit solution for (b,c) 
	//    as a function of the x,y grids.
	//  - the b,c coefficients are only used to calculate interpolated values
	//    of the function, via `pchipval`. Calculation of integrals in `analytint`
	//    use only the d coefficients and the grid.
	real matrix pchip(real colvector x, real colvector y)
    { 
        real scalar n, nu, k, j
        real colvector h, delta, d, c, b, which, s  

        n = length(x) 
        h = x[2::n] - x[1::n-1] 
        delta = (y[2::n] - y[1::n-1]) :/ h
        d = pchipslopes(h, delta)

        c = (3*delta - 2*d[1::n-1] - d[2::n]) :/ h
        b = (d[1::n-1] - 2*delta + d[2::n]) :/ (h:^2)
        
        pchipcoef = (b,c\.,.)
        pchipcoef = (pchipcoef,d,y,x)
        return(pchipcoef)

    }
	
	// FUNCTION: PCHIP slopes
	// DESCRIPTION: Calculates the d coefficient as defined in the note for
	//              `pchip`
	// INPUT:
	//   - h: colvector, length K - 1: x_{j+1} - x_j
	//   - delta: colvector, length K - 1: (y_{j+1} - y_j) / (x_{j+1} - x_j)
	// RETURN:
	//   - d: colvector, length K: defined in MPZ2020 appendix B. (NOTE: this 
	//                             is the approximate slope, not the exact derivative)
    real colvector function pchipslopes(real colvector h, real colvector delta) {
        real scalar n 
        real colvector d, k, w1, w2
        n = length(h) + 1
        d = J(n, 1, 0)
        k = 1 :+ select((1::n-2), sign(delta[1::n-2]) :* sign(delta[2::n-1]) :> 0) 
        w1 = 2*h[k] + h[k:-1]
        w2 = h[k] + 2*h[k:-1]
        d[k] = (w1 + w2) :/ (w1 :/ delta[k:-1] + w2 :/ delta[k])
        d[1] = pchipend(h[1], h[2], delta[1], delta[2])
        d[n] = pchipend(h[n-1], h[n-2], delta[n-1], delta[n-2])

        return(d)
    }
	
	// FUNCTION: PCHIP end
	// DESCRIPTION: Calculate the d coefficient as defined in the note for `pchip`
	//              for endpoints in the grid.
	// INPUT: 
	//   - h1, h2: scalars, the first two or last two values of h_j = (x_{j+1} - x_j)
	//   - del1, del2: scalars, the first two or last two values of delta_j = 
	//                          (y_{j+1} - y_j) / h_j
	// RETURN: scalar, value of d coefficient at the end point
    real scalar function pchipend(h1, h2, del1, del2) { 
        real scalar d 
        d = ((2*h1 + h2)*del1 - h1*del2) / (h1 + h2)
        if (sign(d) != sign(del1)) d = 0
            else {
            if (sign(del1) != sign(del2) & (abs(d) > abs(3*del1))) {
                d = 3*del1
            }
        }

        return(d)   
    }
	
	// FUNCTION: PCHIP values
	// DESCRIPTION: Calcalate interpolated points given pchip coefficients
	// INPUT:
	//    - coef, matrix: pchip coefficients in the form returned by `pchip`
	//    - u, colvector/scalar: values of the support to find interpolated point
    // RETURN: colvector/scalar: interpolated points.
	real function pchipval(real matrix coef, real u) {
        nu = length(u) 
        n = rows(coef)
        k = J(nu, 1, 1)
        b = coef[1..(n-1),1]
        c = coef[1..(n-1),2]
        d = coef[1..(n-1),3]
        y = coef[1..(n-1),4]
        x = coef[,5]
        
        if (nu==1) {
            for (j = 2; j <= n-1; j++) {
                if (x[j] <= u) k=j
            }
        }
        else {
            for (j = 2; j <= n-1; j++) { 
                which = select((1::nu), x[j] :<= u) 
                k[which] = J(length(which), 1, j)
            }
        }
        s = u - x[k]
        return(y[k] + s :* (d[k] + s :* (c[k] + s :* b[k]))) 
    }
	
	// FUNCTION: Analytical Integral
	// DESCRIPTION: Calculate the integral of a PCHIP function with support one
	//              [0,1]
	// INPUT:
	//   - a, b: scalars, lower and upper bounds of integration
	//   
	real function analyint(real a, real b, real c, real d, real matrix pchipcoef) {
		
		if (c == 0){
			// TODO: avoid recalculating each time...
			return((b - a) * pchipval(pchipcoef, d))
		}
		
		
		lower_bound = c*a+d
		upper_bound = c*b+d
		difflower = J(rows(pchipcoef),1, lower_bound) - pchipcoef[,5]
		diffupper = J(rows(pchipcoef),1, upper_bound) - pchipcoef[,5]
		indexlower = select((1::rows(pchipcoef)), difflower:<=0)
		indexlower = indexlower[1,1]
		indexupper = select((1::rows(pchipcoef)), diffupper:>=0)
		indexupper = indexupper[rows(indexupper),1]
		if (indexlower == indexupper) {
			midint =0
		}
		else {
			yk1 = pchipcoef[indexlower+1::indexupper,4]
			yk = pchipcoef[indexlower::indexupper-1,4]
			hk = pchipcoef[indexlower+1::indexupper,5] - pchipcoef[indexlower::indexupper-1,5]
			dk1 = pchipcoef[indexlower+1::indexupper,3]
			dk = pchipcoef[indexlower::indexupper-1,3]
			integral = (1/2)*(yk1 + yk) :* hk - (1/12)*(dk1 - dk) :* (hk):^(2)
			midint = colsum(integral)
		}
		if (indexlower == 1) {
			leftint=0
		}
		else {
			y1 = pchipcoef[indexlower,4]
			y0 = pchipcoef[indexlower-1,4]
			d1 = pchipcoef[indexlower,3]
			d0 = pchipcoef[indexlower-1,3]
			h0 = pchipcoef[indexlower,5] - pchipcoef[indexlower-1,5]
			x0 = pchipcoef[indexlower-1,5]
			u0 = lower_bound - x0
			piece1 = (y1/(h0^2)) * u0^3 - (y1/(2*h0^3))*u0^4 + y0*u0 - (y0/h0^2)*u0^3 + (y0/(2*h0^3))*u0^4
			piece2 = (d1/h0^2)*( (1/4)*u0^4 - (h0/3)*u0^3 ) + (d0/h0^2)*( (1/4)*u0^4 - (2*h0/3)*u0^3 + ((h0^2)/2)*u0^2 )
			leftint = (1/2)*(y1+y0)*h0 - (1/12)*(d1-d0)*h0^2 - (piece1 + piece2)
		}

		if (indexupper == rows(pchipcoef)) {
			rightint=0
		}
		else {
			y1 = pchipcoef[indexupper+1,4]
			y0 = pchipcoef[indexupper,4]
			d1 = pchipcoef[indexupper+1,3]
			d0 = pchipcoef[indexupper,3]
			h0 = pchipcoef[indexupper+1,5] - pchipcoef[indexupper,5]
			x0 = pchipcoef[indexupper,5]
			u0 = upper_bound - x0
			piece1 = (y1/(h0^2)) * u0^3 - (y1/(2*h0^3))*u0^4 + y0*u0 - (y0/h0^2)*u0^3 + (y0/(2*h0^3))*u0^4
			piece2 = (d1/h0^2)*( (1/4)*u0^4 - (h0/3)*u0^3 ) + (d0/h0^2)*( (1/4)*u0^4 - (2*h0/3)*u0^3 + ((h0^2)/2)*u0^2 )
			rightint = piece1 + piece2

		}

		analyint = (1/c) * (leftint + midint + rightint)

		return(analyint)
	}
	
	// =========================================================================
	// B.3 Utilities
	// =========================================================================

	// FUNCTION: breakdown_start_points
	// DESCRIPTION: calculates the initial points from the c_grid to use
	//              in the bisection algorithm to find the breakdown point.
	// INPUTS:
	//   - c_table: (matrix): col 1 - c-dep vals, col 2/3 - lower/upper bounds
	//   - bd_y: (scalar): value for conclusion stat > bd_y
	//   - side: "lower" ("upper"): at c = 0, stat > (<) bd_y
	// OUTPUT: saves stata macros clow and chi. These are the values of c such
	//         that y(clow) < bd_y < y(chi) where y(.) is the lower or upper
	//         bound as specified by side
	void breakdown_start_points(c_table, bd_y, side){
		// collect all the values in cgrid before one of the bounds crosses bd_y 
		// + determine the ordering of c-dep vals: if side = "lower" ("upper") 
		// than y(c_max) > (<) y_bd. 
		if (side == "lower") {
			index = selectindex((st_matrix(c_table)[,2]:>bd_y))
			c1 = "chi"
			c2 = "clow"
		}
		else if (side == "upper") {
			index = selectindex((st_matrix(c_table)[,3]:<bd_y))
			c1 = "clow"
			c2 = "chi"
		}
		// case where it doesn't cross (i.e., no breakdown) set clow = 1
		if (rows(index) == rows(st_matrix(c_table))) {
			st_local("clow", "1")
		}
		// otherwise take the values in the cgrid on either side of the crossing
		else {
			clim = index[rows(index),.] // smallest LB that is larger than y
			st_local(c1,  strofreal(st_matrix(c_table)[clim,1]))
			st_local(c2, strofreal(st_matrix(c_table)[clim + 1,1]))
		}
	}
	
	
	// TODO: why do we need these min/max functions instead of built-in
	//       rowmin/rowmax (i.e., rowmin((A,B)))? faster?
	
	// FUNCTION: minimum 2
	// DESCRIPTION: calculate elementwise minimum of two vectors
    function min2(A, B) 
    {
        D = (A :<= B):*A + (B :< A):*B
        return(D)
    }

	// FUNCTION: minimum 3
	// DESCRIPTION: calculate elementwise minimum of three vectors
    function min3(A, B, C)
    {
        D = min2(A,B)
        E = min2(B,C)
        F = min2(D,E)
        return(F)
    }

	// FUNCTION: maximum 2
	// DESCRIPTION: calculate elementwise maximum of two vectors
    function max2(A,B)
    {
        D = (A :>= B) :* A + (B :> A) :* B
        return(D)
    }

	// FUNCTION: maximum 3
	// DESCRIPTION: calculate elementwise maximum of three vectors
    function max3(A,B,C)
    {
        D = max2(A,B)
        E = max2(B,C)
        F = max2(D,E)
        return(F)

    }

	// FUNCTION: Apply Cumulative Function
	// DESCRIPTION: applies a mata vector function to rows 1:k for each row k
	//              for a specified column of the matrix.
	// INPUT:
	//   - matname (string): name of the stata matrix to operate on
	//   - col (integer): column index to operate on
	//   - f (pointer to function): function to apply cumulatively
	// RETURN: void, modifies column of input Stata matrix
	void apply_cumfunc(string scalar matname, real scalar col, pointer(real scalar function) scalar f){
		mat = st_matrix(matname)
		for (row = 1; row <= rows(mat); row++) {
				mat[row, col] = (*f)(mat[|1, col \ row, col|])
		}
		st_replacematrix(matname, mat)
	}
	
	// FUNCTION: Sort Stata matrix
	// DESCRIPTION: sort a Stata matrix in ascending order on one column
	// INPUT:
	//   - matname, string: name of stata matrix to operate one
	//   - sortcol, scalar: number of column to sort on
	// RETURN: void, replace input Stata matrix with sorted matrix
	void sort_st_matrix(string scalar matname, real scalar sortcol){
		orig_mat = st_matrix(matname)
		perm = order(orig_mat, sortcol)
		sort_mat = orig_mat[perm,]
		row_l = st_matrixrowstripe(matname)
		sort_row_l = row_l[perm,]
		
		st_replacematrix(matname, sort_mat)
		st_matrixrowstripe(matname, sort_row_l)
	}
	
	
	// FUNCTION: Matrix Equal
	// DESCRIPTION: Check if two stata matrices are equal
	// INPUT:
	//   - a,b: stata matrices to compare
	//   - out: string: name of local to save result to
	// RETURN: save stata macro named `out` (1 = equal)
	void mat_eq(a, b, out){
		st_local(out, strofreal(st_matrix(a) == st_matrix(b)))
	}
	
end
