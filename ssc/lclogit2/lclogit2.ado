*! Author: Hong Il Yoo (h.i.yoo@durham.ac.uk) 
*! HIY 1.2.0 10 November 2019 
*! HIY 1.1.0 24 February 2019
program lclogit2
	version 13.1
	if replay() {
		if (`"`e(cmd)'"' != "lclogit2" & `"`e(cmd)'"' != "lclogitml2") error 301
		Replay `0'
	}
	else Estimate `0'
end

program Estimate, eclass sortpreserve
		syntax varlist [if] [in],		///
			GRoup(varname)				///
			NCLasses(integer) 			///
			RAND(varlist) [			    ///
			ID(varname) 				///	
			MEMbership(varlist)			///
			SEED(numlist max=1)			///				
			LTOLerance(real 0.000001)	///
			TOLerance(real 0.0004)		///
			ITERate(integer 1000) 		///
			Nolog						///
			CONSTraints(numlist)		///
			TOLCheck					///
			]	
	
	//*************************
	//Step 1: Check basics
	//*************************
	**specify id = group if id is not supplied**
	if ("`id'" == "") local id `group'
	
	**Define temporary variables and scalars**
	tempvar prop _pr n_obs1 ///
				 miny maxy obs _p _pr _s ///
				 cm_chk ///
				 b_now b_rand b_share b_fix b_all b_from ///
				 share_sample P one ll_em
	
	**Define class-varying temporary variables scalars**
	forvalues c=1/`nclasses'{
		tempname b_from_`c'
		tempvar cp_`c' up_`c'
	}
		
	**sort out dependent and independent variables
	gettoken depvar fix: varlist	
	local rhs `fix' `rand'
	
	**Mark sample** 
	marksample touse
	markout `touse' `group' `id' `rhs' `membership'
	
	**Constant regressor 1**
	qui gen double `one' = 1 if `touse'
	
	**Check that group, id and other explanatory variables are numeric **
	foreach v of varlist `group' `id' `rhs' `membership' {
		capture confirm numeric variable `v'
		if _rc != 0 {
			display as error "variable `v' is not numeric."
			exit 498
		}
	}

	**Check that all specified options have elements within the allowed ranges **
	if (`nclasses' < 2) {
		di in r "nclasses(`nclasses') must be >=2."
        exit 197
    }
    if `ltolerance' < 0 {
        di as error "ltolerance(`ltolerance') must be >= 0."
        exit 197
    }
    if `tolerance' < 0 {
        di as error "tolerance(`tolerance') must be >= 0."
        exit 197
    }   
	if "`seed'" != "" {
		if (`seed' < 0) | (`seed' > 2147483647) {
			di as error "seed(`seed') must be between 0 and 2^31-1 (2,147,483,647)."
			exit 197
		}
	}	
    if (`iterate' < 0) {
        di as error "iterate(`iterate') must be >= 0."
        exit 197
    }

	** Check that no variable has been specified as both dependent and independent variables**
	foreach v of varlist `fix' `rand' {
		if ("`v'" == "`depvar'") {
			di as error "`depvar' cannot be specified as both dependent and independent variables."
			exit 498
		}
	}		
	
	** Check that no variables have been specified to have both fixed and random coefficients **
	if ("`fix'" != "") {
		foreach v_fix of varlist `fix' {
			foreach v_rand of varlist `rand' {
				if ("`v_fix'" == "`v_rand'") {
					di as error "remove `v_fix' from the main command line or rand():"
					di as error "the coefficient on `v_fix' cannot be both homogeneous and heterogeneous across classes."
					exit 498
				}
			}
		}
	}
	
	**Check that varlist in membership() do not vary within the same agent""
    if "`membership'" != "" {
        sort `id'
		capture fmlogit
		if (_rc == 199) {
			di as text "option membership() requires -fmlogit-. installing -fmlogit- now."
			ssc install fmlogit 
		}
        foreach v of varlist `membership' {
			qui by `id' : gen double `cm_chk' = `v'[_n] - `v'[_n-1] if `touse'
            qui tab `cm_chk'
            if r(r) > 1 {
				di as error "remove `v' from membership():" 
				di as error "across all observations with the same level of `id', a variable listed in membership() must remain constant."
                exit 498
            }
            drop `cm_chk'
        }
     }

	**Check that depvar is a 0/1 indicator of choice**
	sort `id' `group'
	qui by `id' `group': egen double `miny' = min(`depvar') if `touse'
	qui by `id' `group': egen double `maxy' = max(`depvar') if `touse'
	qui count if ((`miny' !=0 & `miny' !=1) | (`maxy' !=1 & `maxy' !=0)) & `touse' 
	if r(N)>0 {
		di as error "`depvar' is not a 0/1 variable which equals 1 for the chosen alternative."
		exit 450
	}

	** Switch on/off constraints as appropriate **
	if ("`constraints'" != "") local constr constraints(`constraints')	
	
	** Estimate conditional logit model; the estimation is terminated at iteration 0 as the acual results are not needed**  
	qui clogit `depvar' `rhs' if `touse', group(`group') iter(0) 
	qui replace `touse' = e(sample)		
	
	//*****************************
	//Step 2: Initialise estimates
	//*****************************
	**Count number of relevant variables** 
	local k_fix : word count `fix'
	local k_rand : word count `rand'
	local k_membership : word count `membership'
		
    **Randomly split the sample into nclasses segments**
	sort `id' `group' 
	qui by `id': gen double `n_obs1' = [_n == 1] // =1 for first observation on each subject 
	local o_seed `c(seed)' // Save the current seed so that it can be restored later. 
	if ("`seed'" == "") local seed `c(seed)' // Use c(seed) as the starting seed unless the user requested otherwise. 
 	set seed `seed' // Specify the starting seed for runiform().   			
	qui by `id': gen double `_p'=runiform() if `n_obs1'==1 // Make a random draw for each agent
	qui by `id': egen double `_pr'=sum(`_p') if `touse'
	set seed `o_seed' // Restore the original seed.  
	local prop= 1/`nclasses' // The remainder of this block splits the sample into nclasses() segements 
	qui gen double `_s'=1 if `_pr'<=`prop'  & `touse' // based on the realisations of the random draws.
	forvalues s=2/`nclasses'{
		qui replace `_s'=`s' if `_pr'>(`s'-1)*`prop' & `_pr'<=`s'*`prop' & `touse'
	}
	
	**Initialise posterior class membership probabilities
	forvalues c = 1/`nclasses' { 
		// temporary variable to hold conditional class membership probability for class c
		qui gen double `cp_`c'' = .
		local cp_all `cp_all' `cp_`c'' 
		// list of dependent variables for -fmlogit- later
		if ("`membership'" != "" & `=int(`c')' < `=int(`nclasses')') local y_fmlogit `y_fmlogit' `cp_`c''
		// temporary variable to hold unconditional class membership probability for class c
		qui gen double `up_`c'' = .
		local up_all `up_all' `up_`c''
	}
	if ("`membership'" != "") local y_fmlogit `cp_`=int(`nclasses')'' `y_fmlogit'
	
	**Obtain starting values for coefficients**
	if ("`fix'" == "" & "`constraints'" == "") {
		forvalues c = 1/`nclasses' {
			qui clogit `depvar' `rand' if `touse' == float(1) & `_s' == `c', group(`group')
			matrix `b_now' = e(b)
			matrix `b_rand' = nullmat(`b_rand'), `b_now'
			matrix `b_from_`c'' = `b_now'
		}
	}
	else {
		// set up equations
		local Class (Class1: `depvar' `cp_all' = `rand', nocons)
		forvalues c = 2/`nclasses' {
			local Class `Class' (Class`=int(`c')': = `rand', nocons)
			if (int(`c') < int(`nclasses')) local Share `Share' (Share`=int(`c')': = `membership')
		}
		if (`k_fix' != float(0)) local Fix (Fix: = `fix', nocons)
	
		// get starting values
		forvalues c = 1/`nclasses' {
			capture clogit `depvar' `rand' `fix' if `touse' == 1 & `_s' == `c', group(`group')
			if (_rc != float(0)) qui clogit `depvar' `rand' `fix' if `touse' == 1, group(`group')
			matrix `b_now' = e(b)
			matrix `b_rand' = nullmat(`b_rand'), `b_now'[1,1..`k_rand']
			if (`k_fix' != float(0)) { 
				matrix `b_fix' = nullmat(`b_fix') \ `b_now'[1,`=`k_rand'+1'..`=`k_rand'+`k_fix'']
			}
		}
		matrix `b_from' = `b_rand'
		if (`k_fix' != float(0)) {
			mata: st_matrix(st_local("b_fix"),quadcolsum(st_matrix(st_local("b_fix")),1)/strtoreal(st_local("nclasses")))
			matrix `b_from' = `b_from', `b_fix'
		}
		local from `b_from'
	}
	matrix `b_share' = J(1,`=(`nclasses'-1)*(`k_membership'+1)', 0.01)	
	matrix `b_all' = `b_rand', `b_share'
	if ("`fix'" != "") matrix `b_all' = `b_all', `b_fix'
	
	// send basic information to Mata
	sort `id' `group' 
	mata: st_view(id=.,.,st_local("id"),st_local("touse"))  // subject id
	mata: st_view(group=.,.,st_local("group"),st_local("touse")) // choice set id
	mata: nclasses = strtoreal(st_local("nclasses")) // # of classes	
	mata: k_fix = strtoreal(st_local("k_fix")) // # of fixed preference coefs
	mata: k_rand = strtoreal(st_local("k_rand")) // # of random preference coefs	
	mata: k_membership = strtoreal(st_local("k_membership")) // # of class share coefs (excl. const)
	
	// send data to Mata
	mata: st_view(Y=.,.,"`depvar'",st_local("touse"))
	mata: st_view(X_rand=.,.,"`rand'",st_local("touse"))
	mata: st_view(X_share=.,.,"`membership' `one'",st_local("touse"))
	if ("`fix'" != "") mata: st_view(X_fix=.,.,"`fix'",st_local("touse"))		
	
	//compute conditional probabilities and sample log-likelihood
	mata: ll_em = lclogitml2_cpll(st_matrix("`b_all'"),"`cp_all'","`touse'")
	mata: st_numscalar(st_local("ll_em"),ll_em)
	
	**Evaluate and display the likelihood function**
	display as text "Iteration " 0 ":  log likelihood = " as result `ll_em'

	//*****************************
	//Step 3: execute EM algorithm
	//*****************************
	set more off
		
	local i= 0 // i-th iteration
	gen double `share_sample' = [`touse' == float(1) & `n_obs1' == 1] // identify estimation sample for class share equation
	sort `id' `group'	
	
	// give name _cons to each intercept in b_share in case this is obtained by inverting analytic shares
	if ("`membership'" == "") {
		forvalues c=1/`=`nclasses'-1' {
			local names_share `names_share' _cons
		}
		matrix colnames `b_share' = `names_share'
	}
	
	while `i'< `iterate' {
		local i = `i' + 1
	
		// update pref coefs and scale coefs
		if ("`fix'" == "" & "`constraints'" == "") {
			forvalues c = 1/`nclasses' {
				if (`=int(`c')' == 1) matrix drop `b_rand' 
				qui clogit `depvar' `rand' [iw=`cp_`c''] if `touse', group(`group') from(`b_from_`c'', copy)
				matrix `b_now' = e(b)
				matrix `b_rand' = nullmat(`b_rand'), `b_now'[1,1..`k_rand']
				matrix `b_from_`c'' = `b_now'
			}	
		}
		else {
			capture ml model gf0 lclogit2_clogit_gf0() `Class' `Fix' if `touse', missing maximize nopreserve init(`b_from', copy) search(off) `constr' 
			if (_rc != float(0)) qui ml model gf0 lclogit2_clogit_gf0() `Class' `Fix' if `touse', missing maximize nopreserve init(`b_from', copy) search(on) `constr' difficult 
			matrix `b_now' = e(b)
			matrix `b_rand' = `b_now'[1,1..`=`k_rand'*`nclasses'']
			local k_coef = `k_rand'*`nclasses' 	
			if (`k_fix' > 0) {
				matrix `b_fix' = `b_now'[1,`=`k_coef'+1'..`=`k_coef'+`k_fix'']
				local k_coef = `k_coef' + `k_fix'
			}	
			matrix `b_from' = `b_now'
			local rank = e(rank)
		}	
		
		// update class share coefs
		if ("`membership'" == "") {
			mata: st_view(CP=.,.,"`cp_all'",st_local("share_sample"))
			mata: Share = quadcolsum(CP,1) / quadsum(CP,1)
			mata: st_matrix("`b_share'",ln(Share[1,1..(`nclasses'-1)] / Share[1,`nclasses']))
			matrix colnames `b_share' = `names_share'
		}
		else {
			qui fmlogit `y_fmlogit' if `share_sample' == float(1), eta(`membership') 
			matrix `b_share' = e(b)
			
			// -fmlogit- interfers with Mata's memory. Resent all information to Mata.
			// send basic information to Mata
			sort `id' `group' 
			mata: st_view(id = .,.,st_local("id"),st_local("touse"))  // subject id
			mata: st_view(group = .,.,st_local("group"),st_local("touse"))
			mata: nclasses = strtoreal(st_local("nclasses")) // # of classes	
			mata: k_fix = strtoreal(st_local("k_fix")) // # of fixed preference coefs
			mata: k_rand = strtoreal(st_local("k_rand")) // # of random preference coefs	
			mata: k_membership = strtoreal(st_local("k_membership")) // # of class share coefs (excl. const)
			
			// send data to Mata
			mata: st_view(Y=.,.,"`depvar'",st_local("touse"))
			mata: st_view(X_rand=.,.,"`rand'",st_local("touse"))
			mata: st_view(X_share=.,.,"`membership' `one'",st_local("touse"))
			if ("`fix'" != "") mata: st_view(X_fix=.,.,"`fix'",st_local("touse"))		
		}
		
		// collect together updated coefs
		matrix `b_all' = `b_rand', `b_share'
		if ("`fix'" != "") matrix `b_all' = `b_all', `b_fix'
		
		//compute conditional probabilities and sample log-likelihood 
		mata: ll_em = lclogitml2_cpll(st_matrix("`b_all'"),"`cp_all'","`touse'")
		mata: st_numscalar(st_local("ll_em"),ll_em)
		display as text "Iteration " `i' ":  log likelihood = " as result `ll_em'
		
		**Stop the loop if the relative change in the log likelihood over the last 5 iterations meet the convergence criterion**
		tempname b_all_`i'
		matrix `b_all_`i'' = `b_all'
		local ll_em_`i' = `ll_em'
		if `i' > 6 {
			// check if rel diff in log likelihood is less than ltol
			if (reldif(`ll_em_`i'',`ll_em_`=`i'-5'') <= `ltolerance') {
				// declare convergence if tolcheck is not requested
				if ("`tolcheck'" == "") continue, break
				// check rel dif in coefs if tolcheck is requested
				else if (mreldif(`b_all_`i'',`b_all_`=`i'-5'') <= `tolerance') continue, break
			}	
			macro drop _ll_em_`=`i'-5'
			matrix drop `b_all_`=`i'-5''
		}	
	}
	
	//*****************************
	//Step 4: Report the results
	//*****************************
	**Warn that EM iterations stopped prematurely**
	if (`i' == `iterate') { 
		di as txt "The maximum number of iterations has been reached."
		local converged = 0
	}
	else local converged = 1

	// name equations 
	forvalues c=1/`nclasses' {
		forvalues k=1/`k_rand' {
			local eq_rand `eq_rand' Class`c'
		}
		forvalues k=1/`=int(`k_membership'+1)' {
			if (`=int(`c')' != `=int(`nclasses')') local eq_share `eq_share' Share`c'
		}
	}
	if ("`fix'" != "") {
		forvalues k=1/`k_fix' {
			local eq_fix `eq_fix' Fix
		}
	}
	matrix coleq `b_rand'  = `eq_rand'
	matrix coleq `b_share' = `eq_share'
	
	if ("`fix'" != "") matrix coleq `b_fix' = `eq_fix'
	matrix coleq `b_all' = `eq_rand' `eq_share' `eq_fix' 
	
	// count # of observations
	qui count if `touse'
	local N = r(N)
	qui duplicates report `id' if `touse'
	local N_i = r(unique_value)
	qui duplicates report `group' if `touse'
	local N_g = r(unique_value)
	
	// collate choice model coefficients into a [nclasses x k_rand] matrix B
	tempname B B_row
	forvalues c = 1/`nclasses' {
		matrix `B_row' = `b_rand'[1,`=1+(`c'-1)*`k_rand''..`c'*`k_rand'] 
		matrix rownames `B_row' = Class`c'
		matrix coleq `B_row' = "Coef of"
		matrix `B' = nullmat(`B') \ `B_row'
	}	
	
	// generate a [nclasses x 1] vector P that collects class shares (or sample mean class shares in case the membership model includes co-variates)
	mata: st_view(X_share=.,.,"`membership' `one'","`share_sample'")
	mata: lclogitml2_up(st_matrix("`b_share'"), "`up_all'", "`share_sample'")
	qui tabstat `up_all' if `share_sample', stats(mean) save
	matrix `P' = r(StatTotal)'
	forvalues c = 1/`nclasses' {
		local names_P `names_P' Class`c'
	}
	matrix rownames `P' = `names_P'
	matrix colnames `P' = "Class Share"
	
	// generate a [1 x k_rand] vector of mean coefficients for choice model
	tempname PB
	matrix `PB' = `P''*`B'
	matrix coleq `PB'    = "Mean of"
	matrix rownames `PB' = "Coef"
	
	// generate a [nclasses x (k_membership + 1)] matrix CMB that stores membership model parameters
	tempname CMB CMB_row
	forvalues c = 1/`=`nclasses'' {
		if (`c' < `nclasses') matrix `CMB_row' = `b_share'[1,`=1+(`c'-1)*`=`k_membership'+1''..`c'*`=`k_membership'+1']
		if (`c' == `nclasses') matrix `CMB_row' = J(1,`=`k_membership'+1',0)
		matrix rownames `CMB_row' = Class`c'
		matrix coleq `CMB_row' = "Coef of"
		matrix `CMB' = nullmat(`CMB') \ `CMB_row'		
	}	
	
	/*
	// generate a [k_rand x k_rand] covariance matrix CB of choice model parameters
	tempname CB
	mat `CB' = `B''*`B'
	mata: st_replacematrix("`CB'",(st_matrix("`P'"):*(st_matrix("`B'"):-st_matrix("`PB'")))'*(st_matrix("`B'"):-st_matrix("`PB'")))
	mat coleq `CB' = : 	
	mat roweq `CB' = :	
	*/
	
	// post estimation results
	ereturn post `b_all', esample(`touse')
	
	ereturn scalar nclasses = `nclasses'
	ereturn scalar N = `N'
	ereturn scalar N_i = `N_i'
	ereturn scalar N_g = `N_g'
	ereturn scalar ll = `ll_em'
	ereturn scalar k = `k_rand'*`nclasses' + (`k_membership' + 1)*(`nclasses' - 1) + `k_fix' 
	ereturn scalar k_rand = `k_rand'
	ereturn scalar k_share = `k_membership'
	ereturn scalar k_fix = `k_fix'
	if ("`constraints'" != "") ereturn scalar rank = `rank' + (`k_membership' + 1)*(`nclasses' - 1)
	else ereturn scalar rank = e(k)
	ereturn scalar aic = -2*`ll_em' + e(rank)*2
	ereturn scalar caic = -2*`ll_em' + e(rank)*(ln(`N_i')+1)
	ereturn scalar bic = -2*`ll_em' + e(rank)*ln(`N_i')
	ereturn scalar converged = `converged'
	
	ereturn local group `group'
	ereturn local id `id'
	ereturn local depvar `depvar'
	ereturn local indepvars_rand `rand'
	if ("`membership'" != "") ereturn local indepvars_share `membership'
	if ("`fix'" != "") ereturn local indepvars_fix `fix'
	ereturn local cmd "lclogit2"
	ereturn local title "Model estimated via EM algorithm"
	ereturn local seed `seed' 	
	
	ereturn matrix b_rand = `b_rand'
	ereturn matrix b_share = `b_share'
	if ("`fix'" != "") ereturn matrix b_fix = `b_fix'
	ereturn matrix B   = `B'
	ereturn matrix P   = `P'
	ereturn matrix PB  = `PB'
	//ereturn matrix CB  = `CB'
	ereturn matrix CMB = `CMB'
	Replay
end

/*
program Replay
	di as gr ""	
	di as gr "Latent class model with `e(nclasses)' latent classes"
	di as gr ""
	matrix list e(b)
	di as gr "Note: `e(title)'"
end
*/

program Replay
	di as gr ""	
	di as gr "Latent class model with `e(nclasses)' latent classes"
	di as gr ""
	if "`e(indepvars_share)'" != "" {
		di as gr "Choice model parameters and average classs shares"
	}
	local _int = int(`e(nclasses)'/5)
	if `e(nclasses)'>20 {
		if (e(k_fix) == 0) {
			di as g "Note: Results for models with more than 20 classes can be displayed using the matrices in e(B) and e(P)"
			matlist e(B), format(%7.3f) rowtitle(Variable) border(top bottom) showcoleq(lcombined) 
			matlist e(P), format(%7.3f) border(top bottom)
		}
		if (e(k_fix) > 0) {
			di as g "Note: Results for models with more than 20 classes can be displayed using the matrices in e(B), e(b_fix) and e(P)"
			matlist e(B), format(%7.3f) rowtitle(Variable) border(top bottom) showcoleq(lcombined) 
			matlist e(b_fix), format(%7.3f) rowtitle(Variable) border(top bottom) showcoleq(lcombined) 			
			matlist e(P), format(%7.3f) border(top bottom)
		}		
	}
	else {
		tempname B B_5 B_10 B_15 B_20 
		if (e(k_fix) == 0) matrix `B' = e(B), e(P)
		if (e(k_fix) > 0)  {
			tempname B_fix
			forvalues c = 1/`e(nclasses)' {
				matrix `B_fix' = nullmat(`B_fix') \ e(b_fix) 
			}			
			matrix `B' = e(B), `B_fix', e(P)
		}
		matrix coleq `B' = :
		forvalues i = 1/`=`_int'+1' {
			if (`=`i'*5' <= `e(nclasses)') matrix `B_`=`i'*5'' = `B'[`=`i'*5-4'..`=`i'*5',1...]
			else if (`=`i'*5' != `=`e(nclasses)'+5') matrix `B_`=`i'*5'' = `B'[`=`i'*5-4'..`e(nclasses)',1...]		
			if (`=`i'*5' != `=`e(nclasses)'+5') matlist `B_`=`i'*5''', format(%7.3f) rowtitle(Variable) ///
																			border(top bottom) lines(rowtotal) noblank	
		}		
	}
	if "`e(indepvars_share)'" != "" {
		di as gr ""
		di as gr "Class membership model parameters : Class`e(nclasses)' = Reference class"
		tempname CMB CMB_5 CMB_10 CMB_15 CMB_20
		matrix `CMB' = e(CMB)
		if `e(nclasses)' > 20 {
			di as g "Note: Results for models with more than 20 classes can be displayed using the matrix in e(CMB)"		
			matlist e(CMB), format(%7.3f) rowtitle(Variable) border(top bottom) 
		}
		else {
			forvalues i = 1/`=`_int'+1' {
				if (`=`i'*5' <= `e(nclasses)') matrix `CMB_`=`i'*5'' = `CMB'[`=`i'*5-4'..`=`i'*5',1...]
				else if (`=`i'*5' != `=`e(nclasses)'+5') matrix `CMB_`=`i'*5'' = `CMB'[`=`i'*5-4'..`e(nclasses)',1...]
				if (`=`i'*5' != `=`e(nclasses)'+5') matlist `CMB_`=`i'*5''', format(%7.3f) rowtitle(Variable) border(top bottom) noblank
			}			 
		}
	}
	di as gr ""
	di as gr "Note: `e(title)'"
end

version 13.1
mata:
function lclogitml2_cpll(real rowvector b, string rowvector cp_all, string scalar touse) 
{
	//*******************************
	// Step 1. get things from Stata 
	//*******************************
	
	// [N x 1] vectors
	external id // subject id 
	external group // choice set id

	// scalars 
	external nclasses // # of classes	
	external k_rand // # of random preference coefs
	external k_membership // # of class share coefs (excl. const)
	external k_fix // # of fixed preference coefs	

	k_coef = 0 // scalar to keep running total of # of coefficients

	// [N x 1] vector of dependent variable
	external Y
	
	// [N x # of coefs] matrices of regressors 
	external X_rand
	external X_share
	if (k_fix > 0) external X_fix
	
	// break down b into parameter blocks
	b_rand = b[1,1..k_rand*nclasses]
	k_coef = k_coef + k_rand*nclasses 	
	b_share = b[1,(k_coef+1)..(k_coef+(k_membership+1)*(nclasses-1))]
	k_coef = k_coef + (k_membership+1)*(nclasses-1)	
	if (k_fix > 0) {
		b_fix = b[1,(k_coef+1)..(k_coef+k_fix)]
		k_coef = k_coef + k_fix
	}	

	// [N x nclasses] matrices of class-specific linear indices
	// Random preference indices	
	Xb_rand = X_rand * b_rand[1,1..k_rand]' 
	for (c=2; c<=nclasses; c++) {
		Xb_rand = Xb_rand, X_rand * b_rand[1,k_rand*(c-1)+1..k_rand*c]'
	}	
	
	// Class share indices
	Xb_share = X_share * b_share[1,1..(k_membership+1)]' 
	if (nclasses > 2) {
		for (c=2; c<=nclasses-1; c++) {
			Xb_share = Xb_share, X_share * b_share[1,(k_membership+1)*(c-1)+1..(k_membership+1)*c]' 
		}	
	}
	Xb_share = Xb_share, J(rows(id),1,0) // index for last class's share is 0 (i.e. it's the base class) 
	
	// Fixed preference indices
	if (k_fix > 0) Xb_fix = (X_fix * b_fix'):* J(rows(id),nclasses,1)
	
	//**********************************
	// Step 2. transform linear indices 
	//**********************************
	// [N x nclasses] matrices of transformed indices
	// EXP : exp(sig*v) where sig is the scale function and v is the preference index 
	if (k_fix == 0) Xb_pref = Xb_rand
	else Xb_pref = Xb_rand + Xb_fix

	EXP = exp(Xb_pref)
	
	// Share: class shares 
	Share = exp(Xb_share) :/ quadrowsum(exp(Xb_share),1) 

	//**************************************************************
	// Step 3. Compute conditional probabilities and log-likelihood
	//**************************************************************
	// set up panel information: input is [N x 1] vector "id", and output is [N_subject x 2] matrix "subject"
	subject = panelsetup(id,1)

	// # of panel units (subjects), identified by number of rows in "panel"
	N_subject = panelstats(subject)[1]
	
	// initialise [N_subject x 1] vector of each subject's log-likelihood 
	lnfj = J(N_subject,1,.)
	
	// initialise [N x nclasses] matrix of conditional class membership probabilities
	st_view(CP=.,.,cp_all,touse)
	
	// loop over subjects
	for(n=1; n<=N_subject; n++) {
		// read in data rows pertaining to subject n & store in a matrix suffixed _n
		Y_n = panelsubmatrix(Y,n,subject)
		EXP_n = panelsubmatrix(EXP,n,subject)
		Share_n = panelsubmatrix(Share,n,subject)
		group_n = panelsubmatrix(group,n,subject) 
	
		// set up panel information where each panel unit refers to a choice set 
		task_n = panelsetup(group_n,1)
		
		// # of choice sets for subject n
		N_task_n = panelstats(task_n)[1]
		
		// initialise [N_n x nclasses] matrix of choice probabilities where N_n is # of data rows for subject n
		Prob_n = J(rows(Y_n),nclasses,.)
		
		// loop over choice sets
		for(t=1; t<=N_task_n; t++) {
			// read in data rows pertaining to choice set t
			EXP_nt = panelsubmatrix(EXP_n,t,task_n)
			
			// fill in choice probabilities	
			Prob_n[task_n[t,1]..task_n[t,2],.] = EXP_nt :/ quadcolsum(EXP_nt,1)
		}
		
		// [1 x nclasses] vector of the likelihood of actual choice sequence
		ProbSeq_n = exp(quadcolsum(ln(Prob_n) :* Y_n,1))
	
		// compute subject n's log-likelihood
		lnfj[n,1] = ln(ProbSeq_n * Share_n[1,.]')
		
		// fill in subject n's conditional membership probabilities
		CP[subject[n,1]..subject[n,2],.] = (ProbSeq_n :* Share_n[1,.])/(ProbSeq_n * Share_n[1,.]') :* J(rows(Y_n),nclasses,1)
	}
	
	// return [1 x 1] sample log-likelihood 
	return(quadcolsum(lnfj,1)) 
}
end	

version 13.1
mata:
void lclogitml2_up(real rowvector b_share, string rowvector up_all, string scalar touse) 
{
	//*******************************
	// Step 1. get things from Stata 
	//*******************************
	// scalars 
	external nclasses // # of classes	
	external k_membership // # of class share coefs (excl. const)

	// [N x # of coefs] matrix of regressors 
	external X_share
	
	// [N x nclasses] matrix of class-specific linear indices	
	// Class share indices
	Xb_share = X_share * b_share[1,1..(k_membership+1)]' 
	if (nclasses > 2) {
		for (c=2; c<=nclasses-1; c++) {
			Xb_share = Xb_share, X_share * b_share[1,(k_membership+1)*(c-1)+1..(k_membership+1)*c]' 
		}	
	}
	Xb_share = Xb_share, J(rows(Xb_share),1,0) // index for last class's share is 0 (i.e. it's the base class) 
	
	//**********************************
	// Step 2. transform linear indices 
	//**********************************
	// [N x nclasses] matrix of transformed indices
	// Share: class shares 
	st_view(UP=.,.,up_all,touse)
	UP[,] = exp(Xb_share) :/ quadrowsum(exp(Xb_share),1) 
}
end	

exit
