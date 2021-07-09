/*******************************************************************************

Mike Barker
Ichimura 1993 SLS estimator

2013-12-11 - changed trimming to include observations exactly at the cutoff.
Otherwise, all observations may be trimmed from binary dependent variables.

*******************************************************************************/

*! sls version 1.0 2014-10-11 
*! author: Michael Barker mdb96@georgetown.edu

program sls
	version 11
	if replay() {
		if ("`e(cmd)'" != "sls") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Replay
	version 11
	syntax
	di as text _col(55) "Number of obs = " as result %8.0f e(N)
*	di as text _col(55) "SSE           = " as result %8.0g e(sse)
	di as text _col(55) "root MSE      = " as result %8.0g e(rmse)
	ereturn display
end

program Estimate, eclass
version 11
syntax varlist(min=2 numeric) [if] [in] , 	///
	[INIToptions(passthru) 					///
	TRim(numlist min=2 max=2 >=0)			///
	pilot trimvar(varname)					///
	]

	marksample touse
	
	_nobs `touse' [`weight'`exp'], min(2)
	local N = r(N)
	
	tempname M CE 
	tempvar  tx 
	
	* Parse varlist
	gettoken y  xvars : varlist
	
	* Trim vector
	* initialize default values
	if "`trim'"=="" local trim 1 99	
	* parse and check arguments
	tokenize "`trim'" 
	if `1' >= `2' 		error 124  
	if `1'<0 | `2'>100 	error 125
	
	* create indicator trimming vector: 0 is trimmed.
	quietly: gen int `tx'=1 if `touse'
	foreach var of varlist `xvars' {
		if `1'>0 {
			_pctile `var' if `touse' , p(`1')
			quietly: replace `tx'=0 if `var'<r(r1) & `touse'
		}
		if `2'<100 {
			_pctile `var' if `touse' , p(`2')
			quietly: replace `tx'=0 if `var'>r(r1) & `touse'
		}
	}

	* save trim percentiles for ereturn
	tempname trimpc
	matrix `trimpc' = (`1',`2')

	if "`trimvar'"!="" {
		replace `tx' = `tx'*`trimvar'
	}

	* Initialize SLS moptimize problem
	mata: `M' = moptimize_init()
	mata: moptimize_init_tracelevel(`M', "value")
	mata: moptimize_init_which(`M',"min")
	mata: moptimize_init_iterid(`M', "SLS")
	mata: moptimize_init_valueid(`M', "SSq(b)")
	mata: moptimize_init_vcetype(`M', "robust")

	* Evaluator and technique options 
	mata: moptimize_init_evaluator(`M', &slsfxn_gf())
	mata: moptimize_init_evaluatortype(`M', "gf1")
	mata: moptimize_init_technique(`M', "nr")
	mata: moptimize_init_nmsimplexdeltas(`M', 0.5)
	
	* Dependent and non-parameter variables
	mata: moptimize_init_touse(`M', "`touse'")
	mata: moptimize_init_depvar(`M', 1, "`y'" )
	mata: moptimize_init_depvar(`M', 2, "`tx'" )
	
	* Independent Index Variables
	gettoken x1 X2 : xvars
	mata: moptimize_init_eq_name(`M', 1, "Index")
	mata: moptimize_init_eq_cons(`M', 1, "off")
	mata: moptimize_init_eq_offset(`M', 1, "`x1'")
	mata: moptimize_init_eq_indepvars(`M', 1, "`X2'")

	* Define and save CE parameter structure
	mata: sls_CE(`M')	

	* User-Specified Init Options
	_init_options `M' , `initoptions' 

	* Solve with pilot bandwidth to get bw bounds and starting values 
	local maxiter 5
	if "`pilot'"=="pilot" {
		local maxiter 50
	}
	mata: sls_pilot(`M',`maxiter')

	* Equation for Simultaneous Bandwidth Estimation
	mata: moptimize_init_eq_name(`M', 2, "LogitBandwidth")
	mata: moptimize_init_eq_indepvars(`M', 2, "")

	if "`pilot'"=="pilot" { 
		mata: constrainbw(`M')	
	}
	
	*** Estimate parameters and calculate variance 
	mata: sls(`M')   
	
	* Post estimates 

	* Get Index equation name 
	mata: st_local("eqname" , moptimize_init_eq_name(`M'',1))

	* Save scalar return values
	tempname SSE iterations converged 
	scalar `SSE' = e(SSE)
	scalar `iterations' = e(iterations)
	scalar `converged' = e(converged)

	* Repost new estimates to copy col and row names
	tempname Vsls h hbounds 
	matrix `h' = e(h)
	matrix `hbounds' = e(hbounds)
	matrix `Vsls' = e(Vsls)
	ereturn repost V = `Vsls'
	
	* Extract index components. Exclude bandwidth, returned in e(h) 
	tempname b V
	matrix `V' = e(V)
	matrix `V' = `V'["`eqname':","`eqname':"]
	
	matrix `b' = e(b)
	matrix `b' = `b'[1,"`eqname':"]
	
	* Post index components only
	ereturn post `b' `V' , obs(`N') esample(`touse') depname("`y'") properties("b V")
	
	* Additional return values
	tempname rmse 
	scalar `rmse' = sqrt(`SSE' / `N')

	* locals
	ereturn local depvar "`y'"
	ereturn local indepvars = ltrim("`X2'")
	ereturn local offset "`x1'"
	ereturn local cmd "sls"
	ereturn local cmdline "sls `0'"
	ereturn local properties "b V"
	ereturn local predict "sls_p"

	* scalars
	ereturn scalar sse = `SSE' 
	ereturn scalar rmse = `rmse'
	ereturn scalar iterations = `iterations' 
	ereturn scalar converged = `converged' 

	* matrices
	ereturn matrix trimpc = `trimpc'
	ereturn matrix h = `h' 
	ereturn matrix hbounds = `hbounds' 
	
	Replay

end

// Enter Mata
version 11
mata

/*******************************************************************************
 Semiparametric Least Squares 
*******************************************************************************/

/*******************************************************************************
 General Form Objective Function with Simultaneous Bandwidth Estimation
*******************************************************************************/
void function slsfxn_gf(transmorphic M, real scalar todo, real rowvector b, real colvector fv, real matrix S, real matrix H) {

    // Declare data variables
    real colvector tx, est, diff
    struct cexp_parameters scalar CE 

    // Trimming vector
    tx = moptimize_util_depvar(M,2)

    // Conditional expectation parameters
    CE = moptimize_util_userinfo(M,1)

	// Bandwidth parameter
	lub = moptimize_util_userinfo(M,2)
	h0 = invlogit(moptimize_util_xb(M,b,2))
	lb = lub[1]
	ub = lub[2]
	h  = lub[1] + (lub[2]-lub[1])*h0

	// Estimate Conditional Expectation 
    est  = cexp(moptimize_util_depvar(M,1)  ,
                moptimize_util_xb(M,b,1)    , 
                CE , tx , h) 

	// diff = (Y - E(Y|Xb))
    diff = ((moptimize_util_depvar(M,1)-est))
 
    // Check for missing caused by zero in denominator of nonparametric density estimation.
    trim = missing(diff)
    if (trim>0) {
       printf("Warning: %f observations are missing in conditional expectation: trimmed to zero \n" , trim)
    }
    _editmissing(diff, 0)
    
    // Return trimmed value fxn 
    fv = tx :* diff:^2
	
	if (todo==1) {
		// derivative w.r.t. betas
		X    = moptimize_init_eq_indepvars(M, 1)
		dEdb = -2 :* tx :* diff :* dcexpdb_vec(moptimize_util_depvar(M,1) , moptimize_util_xb(M,b,1) , X , CE , tx , h)
		// derivative w.r.t bandwidth parameter
		// Note: correction for bounded estimation of (h): (ub-lb)*h0*(1-h0) 
		dEdh = -2 :* tx :* diff :* (ub-lb)*h0*(1-h0) :* dcexpdh1_vec(moptimize_util_depvar(M,1) , moptimize_util_xb(M,b,1) , CE , tx , h)

		S = (dEdb , dEdh)
	}
}

/*******************************************************************************
 General Form Objective Function with Pilot Bandwidth
*******************************************************************************/
void function slsfxn_pilot(transmorphic M, real scalar todo, real rowvector b, real colvector fv, real matrix S, real matrix H) {

    // Declare data variables
    real colvector tx, est, diff
    struct cexp_parameters scalar CE 
    pointer(function) scalar p

    // Trimming vector
    tx = moptimize_util_depvar(M,2)

    // Conditional expectation parameters
    CE = moptimize_util_userinfo(M,1)

	// Estimate Conditional Expectation 
    est  = cexp(moptimize_util_depvar(M,1)  ,
                moptimize_util_xb(M,b,1)    , 
                CE , tx) 
    // Check for missing caused by zero in denominator of nonparametric density estimation.
    diff = ((moptimize_util_depvar(M,1)-est))

    // Check for missing values
    trim = missing(diff)
    if (trim>0) {
       printf("Warning: %f observations are missing in conditional expectation: trimmed to zero \n" , trim)
    }
    _editmissing(diff, 0)
   	
    // Return trimmed value fxn 
    fv = tx :* diff:^2
}

/*******************************************************************************
 Quadratic Form Objective Function with Simultaneous Bandwidth Estimation
*******************************************************************************/
void function slsfxn_q(transmorphic M, real scalar todo, real rowvector b, real colvector r, real matrix S) {

    // Declare data variables
    real colvector tx, est, diff
    struct cexp_parameters scalar CE 

    // Trimming vector
    tx = moptimize_util_depvar(M,2)

    // Conditional expectation parameters
    CE = moptimize_util_userinfo(M,1)

	// Bandwidth parameter
	lub = moptimize_util_userinfo(M,2)
	h0 = invlogit(moptimize_util_xb(M,b,2))
	lb = lub[1]
	ub = lub[2]
	h  = lub[1] + (lub[2]-lub[1])*h0

	// Estimate Conditional Expectation 
    est  = cexp(moptimize_util_depvar(M,1)  ,
                moptimize_util_xb(M,b,1)    , 
                CE , tx , h) 

	// diff = (Y - E(Y|Xb))
    diff = ((moptimize_util_depvar(M,1)-est))
 
    // Check for missing caused by zero in denominator of nonparametric density estimation.
    trim = missing(diff)
    if (trim>0) {
       printf("Warning: %f observations are missing in conditional expectation: trimmed to zero \n" , trim)
    }
    _editmissing(diff, 0)
    
    // Return trimmed value fxn 
    r = tx :* diff
	
	if (todo==1) {
		// derivative w.r.t. betas
		X    = moptimize_init_eq_indepvars(M, 1)
		dEdb = -1 :* tx :* diff :* dcexpdb_vec(moptimize_util_depvar(M,1) , moptimize_util_xb(M,b,1) , X , CE , tx , h)
		// derivative w.r.t bandwidth parameter
		// Note: correction for bounded estimation of (h): (ub-lb)*h0*(1-h0) 
		dEdh = -1 :* tx :* diff :* (ub-lb)*h0*(1-h0) :* dcexpdh1_vec(moptimize_util_depvar(M,1) , moptimize_util_xb(M,b,1) , CE , tx , h)
		S = (dEdb , dEdh)
	}
}

/*******************************************************************************
 Define and save CE parameter structure
*******************************************************************************/

void sls_CE(transmorphic scalar M) {

	// Define semiparametric parameters	
	struct cexp_parameters scalar CE
    CE = cexp_define()

	CE.kernel = &kernel_gaussian()
	CE.dkernel = &dkernel_gaussian()

    moptimize_init_userinfo(M , 1, CE)

}

/*******************************************************************************
 SLS with pilot bandwidth 
*******************************************************************************/
void sls_pilot(transmorphic scalar M, real scalar maxit) {
	// Copy main moptimize problem
	transmorphic scalar Mp 
	Mp = M
	
	// estimate index with pilot bandwidth
	moptimize_init_evaluator(Mp , &slsfxn_pilot())
	moptimize_init_evaluatortype(Mp , "gf0") 
	moptimize_init_conv_maxiter(Mp,maxit)
	moptimize_init_conv_warning(Mp, "off")
	// moptimize_init_tracelevel(Mp, "value")
	// moptimize_init_technique(Mp, "nm")
	// moptimize_init_nmsimplexdeltas(Mp, 0.5)	
	moptimize(Mp)

	// Get semiparametric parameter structure
	struct cexp_parameters scalar CE
    CE = moptimize_init_userinfo(Mp , 1)

	y  = moptimize_util_depvar(Mp,1) 
    tx = moptimize_util_depvar(Mp,2)
	b  = moptimize_result_coefs(Mp)
	Xb = moptimize_util_xb(Mp,b,1) 

	// calculate pilot h and upper and lower bounds
	// 2 and 1/2 multiples for bounds were chosen arbitrarily
	// reduce bounds to 1.1 and 0.9 aug 14, 2014
	h=(*CE.bwidth)(y,Xb,CE,tx)
	"pilot bandwidth"
	h
	ub = 2 :* h 
	lb = 0.5 :* h
	// transform bandwidth estimates according to upper and lower bounds
	h0 = logit((h-lb)/(ub-lb))

	// Save bandwidth estimate and bounds
	// moptimize_init_eq_coefs(M,2,h0)		
	moptimize_init_eq_coefs(M,2,h0)		
	// Save bounds in original moptimize problem
	moptimize_init_userinfo(M,2,(lb,ub))

	// Set pilot estimates as intial coefficient values
	moptimize_init_eq_coefs(M,1,b)		
	// Turn off search for final sls estimation
 	moptimize_init_search(M, "off")

}


/*******************************************************************************
Subroutine to add bandwidth constraint, so bw is not estimated simultaneously. 
 moptimize_init_constraints(M, Cc) specifies an R x K+1 real matrix, Cc, that 
	places R linear restrictions on the 1 x K full set of coefficients, b.  
	From moptimize help page:
	Think of Cc as being (C,c), C: R x K and c: R x 1.  Optimization will be 
	performed subject to the constraint C*b' = c.  
	The default is no constraints.
*******************************************************************************/

void constrainbw(transmorphic scalar M) {
	moptimize_query(M)
	indices = moptimize_util_eq_indices(M,1)
	C = (J(1,indices[2,2],0) , 1)
	c = moptimize_init_eq_coefs(M,2)
	moptimize_init_constraints(M, (C,c))		
}

/*******************************************************************************
 Mata routine for SLS
*******************************************************************************/
void sls(transmorphic scalar M) {

	real matrix score, gradient

	// Estimate parameters
    moptimize(M)
	moptimize_result_post(M)
	// moptimize_result_display(M)

/*******************************************************************************
 Calculate Variance Estimate
*******************************************************************************/

	struct cexp_parameters scalar CE
    CE = moptimize_init_userinfo(M , 1)

	lub = moptimize_util_userinfo(M,2)
	h = lub[1] + (lub[2]-lub[1])*invlogit(moptimize_result_eq_coefs(M,2))

    tx = moptimize_util_depvar(M,2)
	b  = moptimize_result_eq_coefs(M,1)
	y  = moptimize_util_depvar(M,1) 
	X  = moptimize_init_eq_indepvars(M, 1)
	Xb = moptimize_util_xb(M,b,1)

	ey = cexp(y , Xb , CE , tx , h) 

	// Variance with Alternative Semiparametric correction (from Klein Vella, 2010)
	// Klein corrects gradient component, but not Hessian component
	dE = tx :* dcexpdb_vec(y , Xb , X , CE , tx , h)
	dQ = tx:* (y-ey) :* (dE :- cexp(dE , Xb , CE , tx, h))
	dQ = dQ :- mean(dQ)
	Vinv  = invsym(cross(dE,dE))
	Sigma = cross(dQ,dQ) 
	Vsls= Vinv * Sigma * Vinv 
	Vsls = ( (Vsls,J(rows(Vsls), 1, 0)) \ J(1 , cols(Vsls)+1 , 0) )

	// return transformed h and V with semiparametric correction

	st_matrix("e(h)"   , h)
	st_matrix("e(Vsls)" , Vsls)
	st_matrix("e(hbounds)" , lub)

	st_numscalar("e(SSE)" , moptimize_result_value(M))
	st_numscalar("e(iterations)" , moptimize_result_iterations(M))
	st_numscalar("e(converged)" , moptimize_result_converged(M))

}

end


