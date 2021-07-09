*! Author: Hong Il Yoo (h.i.yoo@durham.ac.uk) 
*! HIY 1.2.0 10 November 2019
*! HIY 1.1.0 24 February 2019
program lclogitml2
	version 13.1
	if replay() {
		if (`"`e(cmd)'"' != "lclogitml2") error 301
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
			Level(cilevel)				///
			FRom(string)				///
			SEARCH(string)				///
			CONSTraints(numlist)		///
			*							///
			]	
	
	//*************************
	//Step 1: Check basics
	//*************************
	**specify id = group if id is not supplied**
	if ("`id'" == "") local id `group'
	
	**Define temporary variables**
	tempvar prop _pr n_obs1 ///
				 miny maxy _p _pr _s ///
				 cm_chk ///
				 b_now b_rand b_share b_fix b_all ///
				 share_sample P one
			
	**Define class-varying temporary variables scalars**
	forvalues c=1/`nclasses'{
		tempvar up_`c'
		qui gen double `up_`c'' = .
		local up_all `up_all' `up_`c''
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
	
	if "`seed'" != "" {
		if (`seed' < 0) | (`seed' > 2147483647) {
			di as error "seed(`seed') must be between 0 and 2^31-1 (2,147,483,647)."
			exit 197
		}
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
	sort `group'
	qui by `group': egen double `miny' = min(`depvar') if `touse'
	qui by `group': egen double `maxy' = max(`depvar') if `touse'
	qui count if ((`miny' !=0 & `miny' !=1) | (`maxy' !=1 & `maxy' !=0)) & `touse' 
	if r(N)>0 {
		di as error "`depvar' is not a 0/1 variable which equals 1 for the chosen alternative."
		exit 450
	}
	
	** Check that starting values are specified with the constraints option **
	if ("`constraints'" != "" & "`from'" == "") {
		di in red "When constraints are specified it is compulsory to supply starting values using the from option"
		exit 498
	}
	
	** Switch on/off constraints as appropriate **
	if ("`constraints'" != "") local constr constraints(`constraints')
	
	** Estimate conditional logit model; the estimation is terminated at iteration 0 as the acual results are not needed**  
	qui clogit `depvar' `rhs' if `touse', group(`group') iter(0) 
	qui replace `touse' = e(sample)		
		
	//*************************
	//Step 2: Run ML
	//*************************
	
	**Count number of relevant variables** 
	local k_fix : word count `fix'
	local k_rand : word count `rand'
	local k_membership : word count `membership'

	**Set up equations**
	local Class (Class1: `depvar' = `rand', nocons)
	local Share (Share1: = `membership')
	forvalues c = 2/`nclasses' {
		local Class `Class' (Class`=int(`c')': = `rand', nocons)
		if (int(`c') < int(`nclasses')) local Share `Share' (Share`=int(`c')': = `membership')
	}
	if (`k_fix' != float(0)) local Fix (Fix: = `fix', nocons)

	** Obtain starting values if not provided**
	if ("`search'" == "") local search off
	sort `id' `group' 
	qui by `id': gen double `n_obs1' = [_n == 1] 
	if ("`from'" == "") {
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
		
		// use clogit starting values when no scale function is specified		
		forvalues c = 1/`nclasses' {		
			capture clogit `depvar' `rand' `fix' if `touse' == 1 & `_s' == `c', group(`group')
			if (_rc != float(0)) qui clogit `depvar' `rand' `fix' if `touse' == 1, group(`group')
			matrix `b_now' = e(b)
			matrix `b_rand' = nullmat(`b_rand'), `b_now'[1,1..`k_rand']
			if (`k_fix' != float(0)) { 
				matrix `b_fix' = nullmat(`b_fix') \ `b_now'[1,`=`k_rand'+1'..`=`k_rand'+`k_fix'']
			}
		}
		matrix `b_all' = `b_rand', J(1,`=(`nclasses'-1)*(`k_membership'+1)', 0.01)
		if (`k_fix' != float(0)) {
			mata: st_matrix(st_local("b_fix"),quadcolsum(st_matrix(st_local("b_fix")),1)/strtoreal(st_local("nclasses")))
			matrix `b_all' = `b_all', `b_fix'
		}
		local from `b_all', copy
	}
	
	** send things to Mata**
	sort `id' `group' 
	mata: id = st_data(.,st_local("id"),st_local("touse"))  // subject id
	mata: group = st_data(.,st_local("group"),st_local("touse"))
	mata: nclasses = strtoreal(st_local("nclasses")) // # of classes	
	mata: k_fix = strtoreal(st_local("k_fix")) // # of fixed preference coefs
	mata: k_rand = strtoreal(st_local("k_rand")) // # of random preference coefs	
	mata: k_membership = strtoreal(st_local("k_membership")) // # of class share coefs (excl. const)
	
	**Estimate**
	ml model gf0 lclogitml2_gf0() `Class' `Share' `Fix' if `touse', ///
								   missing maximize nopreserve init(`from') search(`search') `constr' ///
								   `options' wald(0) 
	// count # of observations
	qui duplicates report `id' if `touse'
	local N_i = r(unique_value)
	qui duplicates report `group' if `touse'
	local N_g = r(unique_value)
	
	// break down b into parameter blocks
	matrix `b_now' = e(b)
	matrix `b_rand' = `b_now'[1,1..`=`k_rand'*`nclasses'']
	local k_coef = `k_rand'*`nclasses' 	
	matrix `b_share' = `b_now'[1,`=`k_coef'+1'..`=`k_coef'+(`k_membership'+1)*(`nclasses'-1)']
	local k_coef = `k_coef' + (`k_membership'+1)*(`nclasses'-1)
	if (`k_fix' > 0) {
		matrix `b_fix' = `b_now'[1,`=`k_coef'+1'..`=`k_coef'+`k_fix'']
		local k_coef = `k_coef' + `k_fix'
	}	
	
	// collate choice model coefficients into a [nclasses x (k_rand + k_fix)] matrix B
	tempname B B_row
	forvalues c = 1/`nclasses' {
		matrix `B_row' = `b_rand'[1,`=1+(`c'-1)*`k_rand''..`c'*`k_rand'] 
		matrix rownames `B_row' = Class`c'
		matrix coleq `B_row' = "Coef of"
		matrix `B' = nullmat(`B') \ `B_row'
	}	
	
	// generate a [nclasses x 1] vector P that collects class shares (or sample mean class shares in case the membership model includes co-variates)
	gen double `share_sample' = [`touse' == float(1) & `n_obs1' == 1] // identify estimation sample for class share equation
	mata: nclasses = strtoreal(st_local("nclasses")) // # of classes	
	mata: k_membership = strtoreal(st_local("k_membership")) // # of class share coefs (excl. const)
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
	
	**Report results**
	ereturn scalar nclasses = `nclasses'
	ereturn scalar N_i = `N_i'
	ereturn scalar N_g = `N_g'
	ereturn scalar k_rand = `k_rand'
	ereturn scalar k_share = `k_membership'
	ereturn scalar k_fix = `k_fix'
	ereturn scalar aic = -2*e(ll) + e(rank)*2
	ereturn scalar caic = -2*e(ll) + e(rank)*(ln(`N_i')+1)
	ereturn scalar bic = -2*e(ll) + e(rank)*ln(`N_i')
	
	ereturn local group `group'
	ereturn local id `id'
	ereturn local indepvars_rand `rand'
	if ("`membership'" != "") ereturn local indepvars_share `membership'
	if ("`fix'" != "") ereturn local indepvars_fix `fix'
	ereturn local cmd "lclogitml2"
	ereturn local title "Model estimated via `=strupper(e(technique))' algorithm"
	ereturn local seed `seed'
	
	ereturn matrix b_rand = `b_rand'
	ereturn matrix b_share = `b_share'
	if ("`fix'" != "") ereturn matrix b_fix = `b_fix'
	ereturn matrix B   = `B'
	ereturn matrix P   = `P'
	ereturn matrix PB  = `PB'
	//ereturn matrix CB  = `CB'
	ereturn matrix CMB = `CMB'
	
	Replay, level(`level')
end

program Replay
	syntax [, Level(cilevel)]
	di as gr ""
	di as gr "Latent class model with `e(nclasses)' latent classes"
	ereturn display, level(`level') 
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
