* IVBOUNDS v1.0
* 06/22/2021
* requires installation of moremata, bsweights, and bs4rw (required by bsweights)
* 4/23/2021 -- 2 fixes, Z->Zvar, Wald_T_boot expression
* 4/25 -- added rngstate for random seet
* 5/4 -- error check for order() and strategy 3, removed treatment() and control()
* 5/10 -- revising code to create strata

capture program drop ivbounds
program ivbounds, eclass 
	version 13.0 								// go to an earlier version?
	syntax varlist (min=1) [if] [in] [pw iw], ///
		Treat(varname) IV(varname) STRATEGY(integer) ///
		[ORDer(integer 1) ///
		 Alpha(real 0.05) NBOOT(integer 500) KN(integer 3) LOWer(real -1) UPper(real -1) ///
		 STRATA(integer 3) ///
		 Survey Weights(int 0) NPSU(int -1) REPS(int 100) ///
		 NODISPLAY SEED(string) ///
		 SAving(string) REPLACE ///
		 verbose(real 0)]		// verbose: 0=no extra text, 1=progress text, 2=progress text and some SDs set to zero
		 
 		/* Control(real 0) TREATMENT(real 1) /// */
		 
	marksample touse   							// creates a flag 0/1 whether to use observation
		
	if ("`seed'" != "") {
		set seed `seed'
	}
	
	local state = c(rngstate)
	set rngstate `state'
	
	* denote e(sample) with touse

	markout `touse' `treat' `iv'  // sets touse=0 if missing on varlist, treat, or iv


	* getting sample size
	qui count if `touse'
	local N = r(N)
	if (`N' == 0) {
	  error 2000
	}
	
	
	* clear results if command was run previously
	matrix CI_out = .
	
	* survey settings
	capture _svy_newrule
	if _rc & "`survey'" != ""  {
		dis in red "Data not set up for svy. Please svyset your data in order to use survey weights."
		exit 119
	}

	if "`survey'" != "" {
		qui svyset
		global svy_settings=r(settings)
		local svyweightvar=r(wvar)
		local bsrw = r(bsrweight)
		
		* di "bsrw = `bsrw'"
		if ("`bsrw'" != "." & `weights'==0) {    /* user should specify weights(1) if bsrweights() already specified in svyset */
			di in red "Bootstrap weights already specified in svyset."
			di in red "Specify the ivbounds option weights(1) to use these weights, or respecify svyset without bootstrap weights to replace with new weights."
			exit
		} 
		
		qui svydes
		local str_count=r(N_strata)
		
		if `weights'==0 {   /* create bootstrap weights and respecify svyset with weights */
			if `str_count'>1 {
					qui bsweights bsw, reps(`reps') n(`npsu') replace
				}
				else {
					qui bsweights bsw, reps(`reps') n(`npsu') replace nosvy
				}
			qui svyset ${svy_settings} , bsrweight(bsw*) 
		}

		
	}
	
	
	* check that iv() is integer
	tempvar Zmod
	qui gen `Zmod' = mod(`iv', 1)
	qui summ `Zmod'
	local Zm = r(mean)
	if !(abs(`Zm') < 0.00000000001) { /* check this number */
	    di as error "Error: the instrument specified in iv() must be binary or discrete."
		exit
	}

	* check that treat variable is 0/1
	qui levelsof `treat', local(treat_levels)
	foreach l of local treat_levels {
		if (!inlist(`l',0,1)) {
			di as error "Error: the variable specified in treat() can only take the values 0 and 1."
			exit
		}
	}
	
	
	gettoken y covariates: varlist
	
	

	
	* order should only be used with strategy 1 or 2
	if (`order' != 1 & `strategy' == 3) {
		di as error "Warning: order specification ignored for strategy 3."
	}
	
	* if order not specified for strategy 1 or 2, 
	if (`order' == . & inlist(`strategy', 1, 2)) {
		local order = 1
	} 
	
	if (!inlist(`order', 0, 1)) {
		di as error "Error: order specification can only take values 0 or 1"
		exit
	}
		
	
	
	
	if (!inlist(`strategy', 1, 2, 3)) {
		di as error "Error: strategy specification can only take values 1, 2, or 3"
		exit
	}

	
	if (`strategy'==3 & (`lower' == -1 | `upper' == -1)) {
		di as error "Error: lower() and upper() must be specified for strategy(3)"
		exit
	}
	
	
	if (`strategy'==3) {
		if (`lower' == -1 | `upper' == -1) {
			di as error "Error: lower() and upper() must be specified for strategy(3)"
			exit
		}
		else {
			if(`lower' < -1 | `lower' > 1) {
				di as error "Error: The input value of lower() should be a value between -1 and 1"
				exit
			}
			if(`upper' < -1 | `upper' > 1) {
				di as error "Error: The input value of upper() should be a value between -1 and 1"
				exit
			}
			if(`lower' > `upper') {
				di as error "Error: The input value of lower() should be leass than or equal to upper()"
				exit
			}
		}
	}
	
	if (`strategy'!=3 & (`lower' != -1 | `upper' != -1)) {
		di as error "Error: lower() and upper() should only be specified for strategy(3)"
		exit
	}


	
	* checking that Z, the instrument, is discrete
	if (sum(mod(`iv',1)) != 0) {
	  di as error "Error: instrumental variable specified in iv() must be integer."
	  exit
	}

	
	local numcov: word count `covariates'
	
	* checking for sufficient number of observations per stratum
	*   only valid for discrete IV with covariates
	qui levelsof `iv', local(ivlevels)
	local n_ivlevels: word count `ivlelels'
	local nstrata = floor(`N'/`strata')
	if ((`nstrata'/(2*`kn')) < 30) {
	    di as error "Error: insufficient number of observations per strata."
		exit
	}
	
	
	* calculating pi-hat, Pr(Z=z), and Zz, levels of Z
	qui proportion `iv' if `touse'
	matrix proptab = r(table)
	matrix pi_hat = proptab[1,1...]  // pi_hat is a 1 X Kz row vector (matrix)
	matrix drop proptab
	
	qui levelsof `iv' if `touse', matrow(Zz)	
	

	
	
	if (`verbose'==0) {
		mata: verbose = 0
	}
	else {
		if (`verbose'==1) {
			mata: verbose = 1
		}
		else mata: verbose = 2
	}
	
	
	/* call main program in mata */
	mata: ivbounds_main("`y'", "`covariates'", `numcov', ///
						  "`treat'", "`iv'",  "`touse'", ///
						  `order', `strategy', ///
						  `alpha', `nboot',  `kn', ///
						  `lower', `upper',  /// 
						  `strata', ///
						  "`survey'", "`svyweightvar'", ///
						  `N') 
	
	if ("`nodisplay'" == "") {
	
	/* generate output to Stata */
	local coverage = (1-`alpha')*100
	
	if (rowsof(Zz) > 2 & `numcov' > 0) {
		di in text "{hline 40}"
		di in text "Confidence Interval Estimate"
		di in text "{hline 40}"
		di in text "Outcome:  `y'"
		di in text "Treatment: `treat'" 
		di in text "{hline 40}"
		di in text "`coverage'% confidence interval"
		di in text "{hline 40}"
		forvalues i = 1/`strata' {
			di in text "Strata = `i'" _column(15) "|" _column(21) as result "["  round(CI_out[`i',1],.0001) ", " round(CI_out[`i',2],.0001) "]"
		}
		di in text "{hline 40}"
		di in text "Number of obs: `N'"
		di in text "Instrumental variable: `iv'"
		di in text "Covariates: `covariates'"
		di in text "Strategy adopted: `strategy'"
		di in text "{hline 40}"
		
	}
	else {
		di in text "{hline 40}"
		di in text "Confidence Interval Estimate"
		di in text "{hline 40}"
		di in text "Outcome:  `y'"
		di in text "Treatment: `treat'"
		di in text "{hline 40}"
		di in text "`coverage'% confidence interval"
		di in text "{hline 40}"
		di in text "Full sample" _column(15) "|" _column(21) as result "["  round(CI_out[1,1],.0001) ", " round(CI_out[1,2],.0001) "]"
		di in text "{hline 40}"
		di in text "Number of obs: `N'"
		di in text "Instrumental variable: `iv'"
		di in text "Covariates: `covariates'"
		di in text "Strategy adopted: `strategy'"
		di in text "{hline 40}"		
	}
	
	}
	
	if `"`saving'"' != `""' {
			preserve
			clear
			matrix CI = CI_out
			qui svmat CI
			rename CI1 lower
			rename CI2 upper
			save `"`saving'"', `replace'
			restore
			
		}		
	
	
	* clears ereturn li, but put e(sample) back in
	ereturn post, esample(`touse')
	
	ereturn scalar N = `N'
	ereturn scalar strata = `strata'
	ereturn scalar strategy = `strategy'
	ereturn scalar order = `order'
	ereturn scalar lower = `lower'
	ereturn scalar upper = `upper'
	
	ereturn local depvar = "`y'"
	ereturn local indepvar = "`covariates'"
	ereturn local treat = "`treat'"
	ereturn local iv = "`iv'"
	
	ereturn matrix bounds = CI_out
	*estimates esample: if `touse', replace
	
	
end

* clear mata


mata:

mata set matastrict on

void ivbounds_main(string scalar y, string scalar covariates, real scalar numcov, 
				     string scalar treat, string scalar iv, string scalar touse, 
					 real scalar order, real scalar strategy, 
					 real scalar alpha, real scalar nboot, real scalar kn, 
					 real scalar lower, real scalar upper, real scalar strata,
						 string scalar survey, string scalar svyweightvar, 
					 real scalar n) {

					 
	
	real matrix Y, T, Z 			
	real matrix Zz, TOUSE
	real scalar Kz, eps, beta

	real matrix CI_out  
	

	external real scalar verbose
	
	if (verbose) printf("Loading data into Mata\n")
	
	TOUSE = st_data(., touse)
	
	Y = select(st_data(., y), TOUSE)
	T = select(st_data(., treat), TOUSE)
	Z = select(st_data(., iv), TOUSE)

	Zz = st_matrix("Zz")'	
	Kz = cols(Zz)
	
	eps = .01
	beta = .001

	
	/* for binary IV */
	if (Kz == 2) {    										
		
		
		CI_out = P_LATE_binaryIV(y, treat, iv, 
								 Y, T, Z, 
								 covariates, numcov,  
								 order, strategy, nboot, kn, Kz,
								 alpha, beta, eps,  
								 lower, upper,
								 survey, svyweightvar, 
								 n, 
								 TOUSE)
								 
								 
		
	}
	
	/* for discrete IV */
	else {
		
		
		CI_out = P_LATE_discreteIV(y, treat, iv, 
								   Y, T, Z,
								   covariates, numcov,    
								   order, strategy, nboot, kn, Kz, 
								   alpha, beta, eps,
							       lower, upper,
								   strata, n, 
								   survey, svyweightvar,
						           Zz, 
								   TOUSE)
								   
								   
		
	}
	
	/* final result is stored in a matrix CI_out */
	st_matrix("CI_out", CI_out)
	
	
}


real matrix P_LATE_binaryIV(string scalar Yvar, string scalar Tvar, string scalar Zvar, 
							real matrix Y, real matrix T, real matrix Z, 
							string scalar covariates, real scalar numcov,  
							real scalar order, real scalar strategy, real scalar nboot, real scalar kn, real scalar Kz, 
							real scalar alpha, real scalar beta, real scalar eps, 
							real scalar lower, real scalar upper, 
							string scalar survey, string scalar svyweightvar, 
							real scalar n, real matrix touse) {

	real scalar Wald_T, sd_Wald_T, kappa, lb, ub, pi_grid, delta, pi_index, Pi, cr_s3, i
	
	real matrix V_b, V,  M, PlusSet, X_boot, X_temp, pi_hat, b, temp, temp_b, CI_Wald_T, xiT
	
	real matrix Wald_T_boot, ind
	
	real matrix CI_out
	real matrix CI_LATE_S3_single
	
	real matrix svyweight
	real matrix bsw
	real scalar bswreps
	
	string scalar quietly
	external real scalar verbose
	
	quietly = "quietly"
	if (verbose) quietly = ""
	
	/* FIXED PARAMETERS FOR ALL STRATEGIES */
	
	Wald_T = .
	sd_Wald_T = .
	
	pi_grid = 5
	delta = .01
	
	lb = min(Y) - max(Y)
	ub = max(Y) - min(Y)
	
	/* binary IV with covariates */
	if (numcov > 0) { 		
	
		/* regression of IV on covariates */
		if (survey == "") {
			stata(sprintf("%s regress %s %s if \`touse'", quietly, Zvar, covariates))
			
		}
		else {
			stata(sprintf("%s svy bootstrap, subpop(\`touse'): regress %s %s", quietly, Zvar, covariates))
		}
		
		b = st_matrix("e(b)")'
		V_b = st_matrix("e(V)")
		
		stata("tempvar p_Z")
		stata("predict \`p_Z' if \`touse', xb")
		
		pi_hat = select(st_data(., st_local("p_Z")), touse)
		
		X_temp=(Z:-pi_hat):/(pi_hat:*(1:-pi_hat))
		
		if (survey == "") {
			Wald_T = mean(X_temp:*Y)/mean(X_temp:*T)
			Wald_T_boot = J(nboot, 1, 0)
			for (i=1; i<=nboot; i++) {
				ind = ceil(runiform(n, 1):*n)
				/*Wald_T_boot[i,1] = mean((Y[ind,1]:-mean(Y[ind,1])):*(Z[ind,1]:-mean(Z[ind,1])))/mean((T[ind,1]:-mean(T[ind,1])):*(Z[ind,1]:-mean(Z[ind,1])))*/
				Wald_T_boot[i,1] = mean(X_temp[ind,1]:*Y[ind,1])/mean(X_temp[ind,1]:*T[ind,1])
			}
			sd_Wald_T = sqrt(variance(Wald_T_boot)*(nboot-1)/nboot)
			
		}
		else {
			svyweight = st_data(., svyweightvar)
			Wald_T = mean(X_temp:*Y:*svyweight)/mean(X_temp:*T:*svyweight)
			bsw = st_data(., "bsw*")
			bswreps = cols(bsw)
			Wald_T_boot = J(bswreps, 1, 0)
			for (i=1; i<=bswreps; i++) {
				Wald_T_boot[i,1] =  mean(X_temp:*Y:*bsw[,i])/mean(X_temp:*T:*bsw[,i])
			}
			sd_Wald_T = sqrt(variance(Wald_T_boot)*(bswreps-1)/bswreps)
		}
		
		if (verbose) printf("Wald_T=%f\n", Wald_T)
		if (verbose) printf("sd_Wald_T=%f\n", sd_Wald_T)

		
		V = select(st_data(., covariates), touse)
		
		X_boot = J(rows(Z), pi_grid, 0)
		
		
		if (order == 1) {
			for (pi_index=1; pi_index <= pi_grid; pi_index++) {
				temp = rnormal(rows(b),cols(b),0,1)
				temp_b = b + cholesky(V_b)*temp*sqrt(chi2(rows(b), 1-delta)/(temp'*temp))
				Pi = (V, J(rows(Z), 1, 1))*temp_b  /* STATA puts coefficient for intercept last!!*/
				X_boot[.,pi_index] = (Z-Pi):/(Pi:*(1:-Pi))		

			}
		}
		else {
		    for (pi_index=1; pi_index <= pi_grid; pi_index++) {
				temp = rnormal(rows(b),cols(b),0,1)
				temp_b = b + cholesky(V_b)*temp*sqrt(chi2(rows(b), 1-delta)/(temp'*temp))
				Pi = (V, J(rows(Z), 1, 1))*temp_b  /* STATA puts coefficient for intercept last!!*/
				X_boot[.,pi_index] = -(Z-Pi):/(Pi:*(1:-Pi))			
			}
		}
		
		if (strategy == 1 | strategy == 2) {
		
			M = PlusSet = kappa = .
			
			if (verbose) printf("partition_single_proxy\n")
			partition_single_proxy(Y, T, kn, eps, n, M, PlusSet, kappa, survey, svyweightvar, touse) 
			if (verbose) printf("CI_LATE_S1_single\n")
			CI_out = CI_binaryIV(n, Y, M, PlusSet, X_boot, nboot, alpha, beta, kappa, lb, ub, pi_grid)

		}
		else {  /* STRATEGY 3 binary IV with covariates */

				
			cr_s3 = invnormal(1-alpha/2)
			
			
			
			CI_Wald_T = (Wald_T-cr_s3*sd_Wald_T \ Wald_T+cr_s3*sd_Wald_T)
			
			printf("alpha_mis = %6.4f, CI=[%6.4f, %6.4f]\n", Wald_T, CI_Wald_T[1], CI_Wald_T[2])
			
			/*
			if (verbose) {
				printf("cr_s3=%6.4f\n", cr_s3)
				printf("CI_Wald_T\n")
				CI_Wald_T
				printf("sd_Wald_T=%6.4f\n", sd_Wald_T)
			}
			*/
			
			xiT = (lower \ upper)

			
			CI_LATE_S3_single =(colmin(CI_Wald_T # xiT) , colmax(CI_Wald_T # xiT))
			

			if (verbose) printf("CI_LATE_S3_single\n")
			CI_out = CI_LATE_S3_single


		}
		

	}
	
	/* binary IV, no covariates */
	else {   /* P_LATE_binaryIV_NCOV */

	
		/* get probability Z=1 */
		if (survey == "") {
			stata(sprintf("%s regress %s if \`touse'", quietly, Zvar))
		}
		else {
			stata(sprintf("%s svy bootstrap, subpop(\`touse'): regress %s", quietly, Zvar))
			/*svyweight = select(st_data(., svyweightvar), touse)*/
		}
		
		b = st_matrix("e(b)")'
		V_b = st_matrix("e(V)")
		
		stata("tempvar p_Z")
		stata("predict \`p_Z' if \`touse', xb")
		
		pi_hat = select(st_data(., st_local("p_Z")), touse)
		X_temp=(Z:-pi_hat):/(pi_hat:*(1:-pi_hat))

		if (survey == "") {
			Wald_T = mean(X_temp:*Y)/mean(X_temp:*T)
			Wald_T_boot = J(nboot, 1, 0)
			for (i=1; i<=nboot; i++) {
				ind = ceil(runiform(n, 1):*n)
				Wald_T_boot[i,1] = mean((Y[ind,1]:-mean(Y[ind,1])):*(Z[ind,1]:-mean(Z[ind,1])))/mean((T[ind,1]:-mean(T[ind,1])):*(Z[ind,1]:-mean(Z[ind,1])))
				/*Wald_T_boot[i,1] = mean(X_temp[ind,1]:*Y[ind,1])/mean(X_temp[ind,1]:*T[ind,1])*/
			}
			sd_Wald_T = sqrt(variance(Wald_T_boot)*(nboot-1)/nboot)
			
		}
		else {
			svyweight = st_data(., svyweightvar)
			Wald_T = mean(X_temp:*Y:*svyweight)/mean(X_temp:*T:*svyweight)
			bsw = st_data(., "bsw*")
			bswreps = cols(bsw)
			Wald_T_boot = J(bswreps, 1, 0)
			for (i=1; i<=bswreps; i++) {
				Wald_T_boot[i,1] =  mean(X_temp:*Y:*bsw[,i])/mean(X_temp:*T:*bsw[,i])
			}
			sd_Wald_T = sqrt(variance(Wald_T_boot)*(bswreps-1)/bswreps)
		}
		
		if (verbose == 2) sd_Wald_T = 0
		if (verbose) printf("Wald_T=%f\n", Wald_T)
		if (verbose) printf("sd_Wald_T=%f\n", sd_Wald_T)
		
		
		X_boot = J(rows(Z), pi_grid, 0)

		if (order == 1) {
		    for (pi_index=1; pi_index <= pi_grid; pi_index++) {
				temp = rnormal(rows(b),cols(b),0,1)
				temp_b = b + cholesky(V_b)*temp*sqrt(chi2(rows(b), 1-delta)/(temp'*temp))
				Pi = J(rows(Z), 1, 1)*temp_b
				X_boot[.,pi_index] = (Z-Pi):/(Pi:*(1:-Pi))			
			}

		}
		else {
		    for (pi_index=1; pi_index <= pi_grid; pi_index++) {
				temp = rnormal(rows(b),cols(b),0,1)
				temp_b = b + cholesky(V_b)*temp*sqrt(chi2(rows(b), 1-delta)/(temp'*temp))
				Pi = J(rows(Z), 1, 1)*temp_b
				X_boot[.,pi_index] = -(Z-Pi):/(Pi:*(1:-Pi))			
			}
		}

		/* for binary IV, strategy 1 and 2 are the same */
		if (strategy == 1 | strategy == 2) {
			/* FIXED PARAMETERS FOR STRATEGY 1 */

			M = PlusSet = kappa = .
			
			 /* ONE PROXY */
			if (verbose) printf("partition_single_proxy\n")
			partition_single_proxy(Y, T, kn, eps, n, M, PlusSet, kappa, survey, svyweightvar, touse) 
		
			if (verbose) printf("CI_LATE_S1_single\n")
			CI_out = CI_binaryIV(n, Y, M, PlusSet, X_boot, nboot, alpha, beta, kappa, lb, ub, pi_grid)



		}
		else {

			cr_s3 = invnormal(1-alpha/2)
			
			CI_Wald_T = (Wald_T-cr_s3*sd_Wald_T \ Wald_T+cr_s3*sd_Wald_T)
			
			printf("alpha_mis = %6.4f, CI=[%6.4f, %6.4f]\n", Wald_T, CI_Wald_T[1], CI_Wald_T[2])

			/*
			if (verbose) {
				printf("cr_s3=%6.4f\n", cr_s3)
				printf("CI_Wald_T\n")
				CI_Wald_T
				printf("sd_Wald_T=%6.4f\n", sd_Wald_T)
			}
			*/
			
			xiT = (lower \ upper)

			CI_LATE_S3_single =(colmin(CI_Wald_T # xiT) , colmax(CI_Wald_T # xiT))
			

			if (verbose) printf("CI_LATE_S3_single\n")
			CI_out = CI_LATE_S3_single


			
		}
	}  

	
	
	return(CI_out)

}





real matrix P_LATE_discreteIV(string scalar Yvar, string scalar Tvar, string scalar Zvar, 
							  real matrix Y, real matrix T, real matrix Z, 
						      string scalar covariates, real scalar numcov,    
							  real scalar order, real scalar strategy, real scalar nboot, real scalar kn, real scalar Kz,  
							  real scalar alpha, real scalar beta, real scalar eps,
							  real scalar lower, real scalar upper, 
							  real scalar strata, real scalar n, 
						      string scalar survey, string scalar svyweightvar, 
			   				  real matrix Zz, real matrix touse) {

	
	
	real scalar i
	
	real scalar lb, ub, pi_grid, delta, pi_index, length_b 
	real scalar lb_p, ub_p

	real matrix CI_out 
	
	real matrix V, V_s, V_sT, e_V, e_V_sort
	string matrix covnames
	real matrix b_hat, pi_hat_sort, sort_ind, cutpoints_ind, cutpoints, index_strata, index_strata_temp, select_ind
	
	real matrix in_stratum
	
	real scalar strata_n
	
	
	string scalar quietly
	external real scalar verbose
	
	quietly = "quietly"
	if (verbose) quietly = ""
	

	
	beta = .001
	eps = .01
	
	if (strategy == 1) {
/*		lb = min(Y) - max(Y)
		ub = max(Y) - min(Y)  */
		pi_grid = 5
		delta = .01
	}
	
	if (strategy == 2) {
		real scalar e_amis_2 
		e_amis_2 = 0.01  
		lb_p = -1
		ub_p = 1
		pi_grid = 5
		delta = .01
	}
	
	/* discrete IV with covariates */
	if (numcov > 0) { 
		
		
		/* divide data into strata based on probability of being T=1 */
		if (survey == "") {		
			stata(sprintf("%s regress  %s %s if \`touse'", quietly, Tvar, covariates))
		}
		else {
			stata(sprintf("%s svy, subpop(\`touse'): regress  %s %s", quietly, Tvar, covariates))
		}
		
		stata("tempvar p_T")
		stata("predict \`p_T' if \`touse', xb")
		
		
		e_V = select(st_data(., st_local("p_T")), touse)
		
	
		cutpoints = mm_quantile(e_V, 1, range(0,1,1/strata))
		
		/* index_strata is indicator of which strata obs belongs to */
		index_strata = J(rows(e_V),1,1)
		for (i = 2; i <= rows(cutpoints); i++) {
			select_ind = selectindex((e_V:>=cutpoints[i-1,1]):*(e_V:<cutpoints[i,1]))
			index_strata[select_ind] = J(rows(select_ind), 1, i-1)
		}
		
		
	
		CI_out = J(strata, 2, -1)
		
		stata("qui cap drop _in_stratum")
		stata("qui gen _in_stratum = .") 
		
		
		/* now call P_LATE_discreteIV_NCOV within each stratum */
		for (i = 1; i <= strata; i++) {
			select_ind = selectindex(index_strata:==i)
			in_stratum = J(rows(Y), 1, 0)
			in_stratum[select_ind] = J(rows(select_ind), 1, 1)

			
			st_store(., "_in_stratum", in_stratum)  /* syntax st_store(data row, data column, matrix to fill with) */
			
			strata_n = rows(select_ind)
			if (verbose) printf("Strata %f n=%f\n",i, strata_n)
			

			
			/* call P_LATE_discreteIV_NCOV with select_ind, a vector of row numbers that belong to 
			   current strata */
			CI_out[i,.] = P_LATE_discreteIV_NCOV(select_ind, 
												 Yvar, Tvar, Zvar, 
												 Y, T, Z, 
												 order, strategy, nboot, kn, Kz,  
												 lower, upper, 
												 strata, strata_n, 
												 survey, svyweightvar,
												 alpha, beta, eps, delta, pi_grid,
												 Zz, lb, ub, lb_p, ub_p, 
												 touse)
												 
				
			

		 
			
		}
	
		stata("qui drop _in_stratum")
		
	}
	/* discrete IV no covariates */
	else {
		
		select_ind = selectindex(touse:==1)
		in_stratum = touse
		stata("qui cap drop _in_stratum")
		stata("qui gen _in_stratum = .") 
		st_store(., "_in_stratum", in_stratum)  
		CI_out = P_LATE_discreteIV_NCOV(select_ind,
									    Yvar, Tvar, Zvar,
										Y, T, Z,
										order, strategy, nboot, kn, Kz,  
										lower, upper,
										strata, n,  
										survey, svyweightvar,
										alpha, beta, eps, delta, pi_grid,
										Zz, lb, ub, lb_p, ub_p,
										touse)   
		stata("qui drop _in_stratum")

	}
	st_matrix("e(strata)", index_strata)
	return(CI_out)				  
}



real matrix P_LATE_discreteIV_NCOV(real matrix select_ind,
								   string scalar Yvar, string scalar Tvar, string scalar Zvar, 
								   real matrix Yfull, real matrix Tfull, real matrix Zfull, 
								   real scalar order, real scalar strategy, real scalar nboot, real scalar kn, real scalar Kz,  
								   real scalar lower, real scalar upper, 
								   real scalar strata, real scalar n, 
								   string scalar survey, string scalar svyweightvar, 
								   real scalar alpha, real scalar beta, real scalar eps, real scalar delta, real scalar pi_grid,
			   					   real matrix Zz, real scalar lb_old, real scalar ub_old, real scalar lb_p, real scalar ub_p,
								   real matrix touse) {

	
	real matrix Y, T, Z, S
	real matrix pi_hat
	
	real matrix alpha_mis_T_boot   						/* discrete IV, all strategies */
	real scalar sd_T									/* discrete IV, all strategies */
	
	real matrix CI_alpha								/* strategy 1*/
	
	real scalar cr_amis_2								/* discrete IV, strategy 2*/
	real matrix alpha_mis_T, alpha_mis_T_				/* discrete IV, strategy 2 & 3*/
	real matrix CI_p									/* discrete IV, strategy 2  sometimes called CI_p_T in mat*/
	
	real matrix X1, X2, M, PlusSet						/* strategies 1 and 2 */
	real scalar kappa, k								/* strategies 1 and 2 */					
	
	real scalar cr_amis_3, e_amis_2						/* strategy 3*/
	real matrix CI_alpha_mis_T							/* strategy 3*/
	real matrix CI_aIV_S3_single						/* strategy 3*/
	real matrix CI_out
	
	real matrix ind, xiT, xiS
	real scalar i, j
	
	real matrix Zz_, pi_hat_, covb_
	
	pointer(real matrix) matrix X_boot 					/* a vector of pointers to matrices */
	
	real matrix svyweight
	real matrix bsw
	real scalar bswreps
	
	
	string scalar quietly
	external real scalar verbose
	
	quietly = "quietly"
	if (verbose) quietly = ""
	
	real scalar lz
	real matrix covb
	
	real scalar lb, ub
	
	
	Y = Yfull[select_ind]
	T = Tfull[select_ind]
	Z = Zfull[select_ind]
	
	lb = min(Y) - max(Y)
	ub = max(Y) - min(Y)
	
	covb = J(1, Kz, 0)
	pi_hat = J(Kz, 1, 0)
	

	/* for all 3 strategies */
	stata("tempvar Zdummy") 
	stata("qui gen \`Zdummy' = .")
	
	/* calcualte probabilities of IV taking different values, store in pi_hat */
	for (lz=1; lz<=Kz; lz++) {
		
		if (verbose) stata(sprintf("di %f", Zz[lz]))
		stata(sprintf("%s replace \`Zdummy' = %s == %f", quietly, Zvar, Zz[lz]))
		if (survey == "") {
			stata(sprintf("%s regress \`Zdummy' if \`touse' & _in_stratum", quietly))
		}
		else {
			stata(sprintf("%s svy bootstrap, subpop(if \`touse'==1 & _in_stratum==1): regress \`Zdummy'", quietly))
		}
		pi_hat[lz,1] = st_matrix("e(b)")'
		covb[1,lz] = st_matrix("e(V)")
		
	}
	
		
	if (survey == "") {
		alpha_mis_T_ = mean((Y:-mean(Y)):*(Z:-mean(Z)))/mean((T:-mean(T)):*(Z:-mean(Z)))
		alpha_mis_T_boot = J(nboot, 1, 0)
		for (i=1; i<=nboot; i++) {
			ind = ceil(runiform(n, 1):*n)
			alpha_mis_T_boot[i,1] = mean((Y[ind,1]:-mean(Y[ind,1])):*(Z[ind,1]:-mean(Z[ind,1])))/mean((T[ind,1]:-mean(T[ind,1])):*(Z[ind,1]:-mean(Z[ind,1])))
		}
		sd_T = sqrt(variance(alpha_mis_T_boot)*(nboot-1)/nboot)
		
	}
	else {
		svyweight = st_data(select_ind, svyweightvar)
		alpha_mis_T_ = mean((Y:-mean(Y)):*(Z:-mean(Z)):*svyweight)/mean((T:-mean(T)):*(Z:-mean(Z)):*svyweight)
		bsw = st_data(select_ind, "bsw*")
		bswreps = cols(bsw)
		alpha_mis_T_boot = J(bswreps, 1, 0)
		for (i=1; i<=bswreps; i++) {
			alpha_mis_T_boot[i,1] = mean((Y:-mean(Y)):*(Z:-mean(Z)):*bsw[,i])/mean((T:-mean(T)):*(Z:-mean(Z)):*bsw[,i])
		}
		sd_T = sqrt(variance(alpha_mis_T_boot)*(bswreps-1)/bswreps)
	}
	
	
	if (verbose) printf("alpha_mis_T_=%f\n", alpha_mis_T_)
	if (verbose) printf("sd_T=%f\n", sd_T)
	
	if (verbose == 2) {
		sd_T = 0
	}

	
	
	if (strategy == 1) {
		
		if (order == 1) {
			Zz_ = Zz
			pi_hat_ = pi_hat
			covb_ = covb
		}
		else {
			Zz_ = Zz[cols(Zz)..1]
			pi_hat_ = pi_hat[rows(pi_hat)..1]
			covb_ = covb[cols(covb)..1]
		}
		

		X_boot = func_X_boot(Z, Zz, pi_grid, delta, pi_hat_, covb_)  /* NOTE: X_boot is a pi_grid*(Kz-1) matrix of pointers to matrices of size n*1 */
		
		X1 = X2 = .
		M = PlusSet = kappa = .
			

		if (verbose) printf("partition_single_proxy\n")
		
		partition_single_proxy(Y, T, kn, eps, n, M, PlusSet, kappa, survey, svyweightvar, touse) 
		

		CI_alpha = J(Kz-1, 2, 0)
		if (verbose) printf("Looping through partition_X_matrix &  CI_alpha\n")
		
		for (k=1; k<=Kz-1; k++) {
			partition_X_matrix(X_boot, Kz, k, X1, X2)   

			
			CI_alpha[k,.] = CI(n, Y, M, PlusSet, X1, X2, nboot, alpha, beta, kappa, lb, ub, pi_grid)
			
		}
		if (verbose) {
			printf("CI_alpha\n")
			CI_alpha
		}
		
		CI_out = CI_alpha_IV_Strategy1_single(CI_alpha)
		if (verbose) CI_out
			
		

		
	}
	if (strategy == 2) {
		e_amis_2 = 0.01
				
		cr_amis_2 = invnormal(1-e_amis_2/2)
		alpha_mis_T = (alpha_mis_T_ - cr_amis_2*sd_T \ alpha_mis_T_+cr_amis_2*sd_T)

		if (verbose) {
			printf("cr_amis_2 = %6.4f\n", cr_amis_2)
			printf("alpha_mis_T")
			alpha_mis_T
			
		}
		
		if (order == 1) {
			Zz_ = Zz
			pi_hat_ = pi_hat
			covb_ = covb
		}
		else {
			Zz_ = Zz[cols(Zz)..1]
			pi_hat_ = pi_hat[rows(pi_hat)..1]
			covb_ = covb[cols(covb)..1]
		}
		

		X_boot = func_X_boot(Z, Zz, pi_grid, delta, pi_hat_, covb_)  /* NOTE: X_boot is a pi_grid*(Kz-1) matrix of pointers to matrices of size n*1 */
		X1 = X2 = .
		M = PlusSet = kappa = .
		
				
		if (verbose) printf("partition_single_proxy\n")
	
		partition_single_proxy(Y, T, kn, eps, n, M, PlusSet, kappa, survey, svyweightvar, touse)
		
		

		CI_p = J(Kz-1, 2, 0)
		if (verbose) printf("Looping through partition_X_matrix &  CI_alpha\n")
		
		for (k=1; k<=Kz-1; k++) {
			partition_X_matrix(X_boot, Kz, k, X1, X2)   

			
			CI_p[k,.] = CI(n, T, M, PlusSet, X1, X2, nboot, alpha, beta, kappa, lb_p, ub_p, pi_grid)
			
		}
		
		if (verbose) {
			printf("CI_p\n")
			CI_p
		}
		
		CI_out = CI_alpha_IV_Strategy2_single(CI_p, alpha_mis_T)
		
			
	}
	if (strategy == 3) {
		
		cr_amis_3 = invnormal(1-alpha/2)
		CI_alpha_mis_T = (alpha_mis_T_-cr_amis_3*sd_T \ alpha_mis_T_+cr_amis_3*sd_T)
		
		printf("alpha_mis = %6.4f, CI=[%6.4f, %6.4f]\n", alpha_mis_T_, CI_alpha_mis_T[1], CI_alpha_mis_T[2])
		
		if (verbose) {
			("CI_alpha_mis_T\n")
			CI_alpha_mis_T
		}
		
		xiT = (lower \ upper)
		CI_aIV_S3_single = (colmin(CI_alpha_mis_T # xiT) , colmax(CI_alpha_mis_T # xiT))
		
		CI_out = CI_aIV_S3_single
	
	}
								   
								   
	return(CI_out)							   
								   
								   
}


/*
real matrix P_LATE_discreteIV_NCOV(real matrix select_ind,
								   string scalar Yvar, string scalar Tvar, string scalar Zvar, 
								   real matrix Yfull, real matrix Tfull, real matrix Zfull, 
								   real scalar order, real scalar strategy, real scalar nboot, real scalar kn, real scalar Kz,  
								   real scalar lower, real scalar upper, 
								   real scalar strata, real scalar n, 
								   string scalar survey, string scalar svyweightvar, 
								   real scalar alpha, real scalar beta, real scalar eps, real scalar delta, real scalar pi_grid,
			   					   real matrix Zz, real scalar lb, real scalar ub, real scalar lb_p, real scalar ub_p,
								   real matrix touse) {

	
	real matrix Y, T, Z, S
	real matrix pi_hat
	
	real matrix alpha_mis_T_boot   						/* discrete IV, all strategies */
	real scalar sd_T									/* discrete IV, all strategies */
	
	real matrix CI_alpha								/* strategy 1*/
	
	real scalar cr_amis_2								/* discrete IV, strategy 2*/
	real matrix alpha_mis_T, alpha_mis_T_				/* discrete IV, strategy 2 & 3*/
	real matrix CI_p									/* discrete IV, strategy 2  sometimes called CI_p_T in mat*/
	
	real matrix X1, X2, M, PlusSet						/* strategies 1 and 2 */
	real scalar kappa, k								/* strategies 1 and 2 */					
	
	real scalar cr_amis_3, e_amis_2						/* strategy 3*/
	real matrix CI_alpha_mis_T							/* strategy 3*/
	real matrix CI_aIV_S3_single						/* strategy 3*/
	real matrix CI_out
	
	real matrix ind, xiT, xiS
	real scalar i, j
	
	real matrix Zz_, pi_hat_, covb_
	
	pointer(real matrix) matrix X_boot 					/* a vector of pointers to matrices */
	
	real matrix svyweight
	real matrix bsw
	real scalar bswreps
	
	
	string scalar quietly
	external real scalar verbose
	
	quietly = "quietly"
	if (verbose) quietly = ""
	
	real scalar lz
	real matrix covb
	
	Y = Yfull[select_ind]
	T = Tfull[select_ind]
	Z = Zfull[select_ind]
	
	covb = J(1, Kz, 0)
	pi_hat = J(Kz, 1, 0)
	

	/* for all 3 strategies */
	stata("tempvar Zdummy") 
	stata("qui gen \`Zdummy' = .")
	
	for (lz=1; lz<=Kz; lz++) {
		
		if (verbose) stata(sprintf("di %f", Zz[lz]))
		stata(sprintf("%s replace \`Zdummy' = %s == %f", quietly, Zvar, Zz[lz]))
		if (survey == "") {
			stata(sprintf("%s regress \`Zdummy' if \`touse' & _in_stratum", quietly))
		}
		else {
			stata(sprintf("%s svy bootstrap, subpop(if \`touse'==1 & _in_stratum==1): regress \`Zdummy'", quietly))
		}
		pi_hat[lz,1] = st_matrix("e(b)")'
		covb[1,lz] = st_matrix("e(V)")
		
	}
	
		
	if (survey == "") {
		alpha_mis_T_ = mean((Y:-mean(Y)):*(Z:-mean(Z)))/mean((T:-mean(T)):*(Z:-mean(Z)))
		alpha_mis_T_boot = J(nboot, 1, 0)
		for (i=1; i<=nboot; i++) {
			ind = ceil(runiform(n, 1):*n)
			alpha_mis_T_boot[i,1] = mean((Y[ind,1]:-mean(Y[ind,1])):*(Z[ind,1]:-mean(Z[ind,1])))/mean((T[ind,1]:-mean(T[ind,1])):*(Z[ind,1]:-mean(Z[ind,1])))
		}
		sd_T = sqrt(variance(alpha_mis_T_boot)*(nboot-1)/nboot)
		
	}
	else {
		svyweight = st_data(select_ind, svyweightvar)
		alpha_mis_T_ = mean((Y:-mean(Y)):*(Z:-mean(Z)):*svyweight)/mean((T:-mean(T)):*(Z:-mean(Z)):*svyweight)
		bsw = st_data(select_ind, "bsw*")
		bswreps = cols(bsw)
		alpha_mis_T_boot = J(bswreps, 1, 0)
		for (i=1; i<=bswreps; i++) {
			alpha_mis_T_boot[i,1] = mean((Y:-mean(Y)):*(Z:-mean(Z)):*bsw[,i])/mean((T:-mean(T)):*(Z:-mean(Z)):*bsw[,i])
		}
		sd_T = sqrt(variance(alpha_mis_T_boot)*(bswreps-1)/bswreps)
	}
	
	
	if (verbose) printf("alpha_mis_T_=%f\n", alpha_mis_T_)
	if (verbose) printf("sd_T=%f\n", sd_T)
	
	if (verbose == 2) {
		sd_T = 0
	}

	
	
	if (strategy == 1) {
		
		if (order == 1) {
			Zz_ = Zz
			pi_hat_ = pi_hat
			covb_ = covb
		}
		else {
			Zz_ = Zz[cols(Zz)..1]
			pi_hat_ = pi_hat[rows(pi_hat)..1]
			covb_ = covb[cols(covb)..1]
		}
		

		X_boot = func_X_boot(Z, Zz, pi_grid, delta, pi_hat_, covb_)  /* NOTE: X_boot is a pi_grid*(Kz-1) matrix of pointers to matrices of size n*1 */
		
		X1 = X2 = .
		M = PlusSet = kappa = .
		
		
		/* SINGLE PROXY */
		if (verbose) printf("partition_single_proxy\n")
		
		partition_single_proxy(Y, T, kn, eps, n, M, PlusSet, kappa, survey, svyweightvar, touse) 
		

		CI_alpha = J(Kz-1, 2, 0)
		if (verbose) printf("Looping through partition_X_matrix &  CI_alpha\n")
		
		for (k=1; k<=Kz-1; k++) {
			partition_X_matrix(X_boot, Kz, k, X1, X2)   

			
			CI_alpha[k,.] = CI(n, Y, M, PlusSet, X1, X2, nboot, alpha, beta, kappa, lb, ub, pi_grid)
			
		}
		if (verbose) {
			printf("CI_alpha\n")
			CI_alpha
		}
		
		CI_out = CI_alpha_IV_Strategy1_single(CI_alpha)
		if (verbose) CI_out
			
		

		
	}
	if (strategy == 2) {
		e_amis_2 = 0.01
				
		cr_amis_2 = invnormal(1-e_amis_2/2)
		alpha_mis_T = (alpha_mis_T_ - cr_amis_2*sd_T \ alpha_mis_T_+cr_amis_2*sd_T)

		if (verbose) {
			printf("cr_amis_2 = %6.4f\n", cr_amis_2)
			printf("alpha_mis_T")
			alpha_mis_T
			
		}
		
		if (order == 1) {
			Zz_ = Zz
			pi_hat_ = pi_hat
			covb_ = covb
		}
		else {
			Zz_ = Zz[cols(Zz)..1]
			pi_hat_ = pi_hat[rows(pi_hat)..1]
			covb_ = covb[cols(covb)..1]
		}
		

		X_boot = func_X_boot(Z, Zz, pi_grid, delta, pi_hat_, covb_)  /* NOTE: X_boot is a pi_grid*(Kz-1) matrix of pointers to matrices of size n*1 */
		X1 = X2 = .
		M = PlusSet = kappa = .
		
				
		/* SINGLE PROXY */
		if (verbose) printf("partition_single_proxy\n")
	
		partition_single_proxy(Y, T, kn, eps, n, M, PlusSet, kappa, survey, svyweightvar, touse)
		
		

		CI_p = J(Kz-1, 2, 0)
		if (verbose) printf("Looping through partition_X_matrix &  CI_alpha\n")
		
		for (k=1; k<=Kz-1; k++) {
			partition_X_matrix(X_boot, Kz, k, X1, X2)   

			
			CI_p[k,.] = CI(n, T, M, PlusSet, X1, X2, nboot, alpha, beta, kappa, lb_p, ub_p, pi_grid)
			
		}
		
		if (verbose) {
			printf("CI_p\n")
			CI_p
		}
		
		CI_out = CI_alpha_IV_Strategy2_single(CI_p, alpha_mis_T)
		
			
	}
	if (strategy == 3) {
		
		cr_amis_3 = invnormal(1-alpha/2)
		CI_alpha_mis_T = (alpha_mis_T_-cr_amis_3*sd_T \ alpha_mis_T_+cr_amis_3*sd_T)
		if (verbose) {
			("CI_alpha_mis_T\n")
			CI_alpha_mis_T
		}
		
		xiT = (lower \ upper)
		CI_aIV_S3_single = (colmin(CI_alpha_mis_T # xiT) , colmax(CI_alpha_mis_T # xiT))
		
		CI_out = CI_aIV_S3_single
	
	}
								   
								   
	return(CI_out)							   
								   
								   
}
*/



void partition_single_proxy (real matrix Y, real matrix T, real scalar K_n, 
    real scalar eps, real scalar n, real matrix _M, real matrix _PlusSet, real scalar _kappa,
	string scalar survey, string scalar svyweightvar, real matrix touse) {
	
	
	/*real vector Y, T*/
	real matrix Ymatrix, probs, quantilematrix, compmatrix, M0, M_std, Y_d
	real matrix weights
	
	string matrix ps, PlusSet0
	real scalar colM, i, j
	real vector lengths, padding
	string vector padzeroes
	string scalar pad

	
    Ymatrix = J(1, K_n, Y)
	probs = range(1, K_n, 1)/K_n
	
	
	quantilematrix = J(n, 1, mm_quantile(Y, 1, probs)') 
	compmatrix = (Ymatrix :<= quantilematrix)
	Y_d = rowsum(compmatrix)  //  partition of Y first, each row of Y_d, taking a value from 1,2,...,K_n indicates which cell each observation of Y belongs to
	M0 = ( J(1, 2*K_n, K_n*T+Y_d) :== J(n, 1, range(1, 2*K_n, 1)') ) // partition of (Y, T)     /* DO I NEED SURVEY WEIGHTS HERE? */
	
	M_std = sqrt(mm_colvar(M0, 1)) 
	
	
	if (rowsum(M_std :> eps) <= 1) {
		_M = J(n, 1, 1)
		_PlusSet = 1
	}
	else {
		_M = select(M0, M_std :> eps)
		colM = cols(_M)
		ps	= inbase(2, range(0, 2^colM-1, 1))  
		lengths = strlen(ps)					
		padding = max(lengths) :- strlen(ps)	
		padzeroes = J(rows(padding), 1, "")		
		for (i = 1; i<=rows(padding); i++) {
			pad = ""
			for (j = 1; j <= padding[i]; j++) {
				pad = pad + "0"
			}
			padzeroes[i] = pad
		}
		ps = padzeroes + ps
		PlusSet0 = J(rows(padding), max(lengths), "")
		for (i=1; i<=max(lengths); i++) {
			PlusSet0[1...,i] = substr(ps, i, 1)
		}
		_PlusSet = (1 :- strtoreal(PlusSet0))'
	}

	_kappa = cols(_PlusSet)
	
	

}



void partition_X_matrix (pointer (real matrix) matrix X, real scalar Kz, real scalar k, ///
						 real matrix _X1, _X2) {
	
	

	
	pointer(real matrix) matrix X1temp, X2temp 
	
	real scalar i, j, count, n, pi_grid
	X1temp = X[.,k]
	X2temp = J(rows(X), Kz-2, NULL)
	count = 1
	
	for (j = 1; j<=Kz-1; j++) {

		if (j != k) {

			X2temp[.,count] = X[.,j]
			count++;
		}
	}
	
	
	n = rows(*X[1,1])
	pi_grid = rows(X)
	_X1 = J(n,pi_grid,0)
	_X2 = J(n,pi_grid*(Kz-2),0)  
	for (i = 1; i <= pi_grid; i++) {
		_X1[,i]  = *X1temp[i]
		for(j = 1; j <= Kz-2; j++) {
			_X2[,((j-1)*pi_grid)+i] = *X2temp[i,j]
		}
	}
	
	
	
}


real matrix CI_alpha_IV_Strategy1_single(real matrix ci_a) {
    
	return((min(ci_a[.,1]), max(ci_a[.,2])))
} 	
	
	


real matrix CI_alpha_IV_Strategy2_single(real matrix ci_p, real matrix alpha_mis_T) {
	
	real matrix ci_alpha_mis
	
	ci_alpha_mis = (alpha_mis_T[1] \ alpha_mis_T[2])
	return(colmin(ci_alpha_mis # vec(ci_p)) , colmax(ci_alpha_mis # vec(ci_p)))  
}


real scalar func_Test(real scalar theta, real matrix Y, real matrix M, real matrix PlusSet,
			   real matrix X, real matrix epsilon_boot, real rowvector scalars) {  

			   	
	real scalar s, pre_select, cr_2BM, cr_select
	real matrix M1, M2, M3
	real matrix Moment, boot_moment, m_Moment, s_Moment, select, select_Moment

	
	real scalar alpha, beta, kappa, n, test_diff
	
	alpha = scalars[1]
	beta = scalars[2]
	kappa = scalars[3]
	n = scalars[4]
	

	s = (theta>=0)-(theta<0)
	
	M1 = -X:*Y:*s				
	
	M2 = X:*Y:*s:-abs(theta)	
		
	M3 = -J(1,kappa,X):*(J(1,kappa,Y):*s+(M*PlusSet:-.5):*abs(theta))   
	Moment = (M1, M2, M3)
	
	m_Moment = mean(Moment)
	s_Moment =  sqrt(mm_colvar(Moment))

	
	boot_moment = epsilon_boot'*(sqrt(n):*(Moment - J(n, 1, m_Moment)):/J(n, 1, s_Moment)):/n
				
	pre_select = s_Moment :>= .001
	
	select_Moment = select(m_Moment, !pre_select)
		

	if (cols(select_Moment) > 0 & max(select_Moment) > 0 ) {
		test_diff = 10 
	}
	else {
		m_Moment = select(m_Moment, pre_select)
		s_Moment = select(s_Moment, pre_select)
		cr_select = -2*mm_quantile(rowmax(boot_moment), 1, 1-beta)
				
		select = (sqrt(n):*m_Moment:/s_Moment) :> cr_select
				
	
		if(sum(select)==0) { 
			test_diff = max(sqrt(n):*m_Moment:/s_Moment) 

		 }

		 else {

			cr_2BM = mm_quantile(rowmax(select(boot_moment,select:*pre_select)), 1, 1-alpha+2*beta)
			test_diff = max(sqrt(n):*m_Moment:/s_Moment) - cr_2BM 

		 } 

	}
	
	return(test_diff)
	
}


struct minimizeroutput
{
	real scalar xmin
	real scalar fval
}

struct minimizeroutput minimizer(pointer(function) scalar fun, real scalar ax, real scalar bx, 
					| a1, a2, a3, a4, a5, a6, a7, a8, a9) {  

	/* requires moremata functions mm_call_setup() and mm_callf() */
		
	real scalar rc /* return code */

	/* check bounds */
	if (ax > bx) {
		printf("{error}Error: Lower bound cannot be greater than upper bound.\n")
		exit(1) /* check on error code */
	}


	real scalar seps, c, a, b, v, w, xf, d, e, x, fx, funccount, iter
	real scalar r, p, q, fval

	real scalar fv, fw, xm, tol, tol1, tol2, gs, fu, si
	
	
	
	funccount = 0
	iter = 0

	/* compute the start point */

	 

	seps = sqrt(2^-52)         /* square root of smallest possible number that can be represented */
	c = 0.5*(3.0 - sqrt(5.0))   /* approximately .382, used for placement of golden section bounds */
	a = ax						/* lower limit */
	b = bx						/* upper limit */	
	v = a + c*(b-a)				/* point between a and b */
	w = v 
	xf = v
	d = 0.0 
	e = 0.0
	x= xf						/* at first, x is xf, which is set to "v" */


	transmorphic inputs


	inputs=mm_callf_setup(fun, args()-3, a1, a2, a3, a4, a5, a6, a7, a8, a9)  /* second argument is number of arguments to pass to f */
	fx = mm_callf(inputs, x)   /* the value of fun() at x */


	funccount = funccount + 1




	

	fv = fx				/* probably going to be the value of fun() at v */
	fw = fx				/* probably going to be the value of fun() at w */
	xm = 0.5*(a+b)      /* midpoint between a and b */


	tol = 1e-4
	tol1 = seps*abs(xf) + tol/3.0   
	tol2 = 2.0*tol1

	/* main loop */
	while (abs(xf-xm) > (tol2 - 0.5*(b-a))) {     /* converges when xf is nearly the same as xm? */
		gs = 1
		/* is parabolic fit possible */
		if (abs(e) > tol1) {
			/* Yes, so fit parabola */
			gs = 0
			r = (xf-w)*(fx-fv)						/* essentially (x-w)/(f(x)-f(v)) */
			q = (xf-v)*(fx-fw)						/* essentially (x-v)/(f(x)-f(w)) */
			p = (xf-v)*q-(xf-w)*r					/* essentially (x-v)^2/(f(x)-f(w)-(x-w)^2/(f(x)-f(v)) */			
			q = 2.0*(q-r)
			if (q > 0.0) p = -p
			q = abs(q)
			r = e  
			e = d
			
			/* Is the parabola acceptable */
			if ( (abs(p)<abs(0.5*q*r)) && (p>q*(a-xf)) && (p<q*(b-xf)) ) {
			
				/* Yes, parabolic interpolation step */
				d = p/q;
				x = xf+d;
				/*procedure = '       parabolic';*/
				
				if ( ((x-a) < tol2) || ((b-x) < tol2)) {
					si = sign(xm-xf) + ((xm-xf) == 0);
					d = tol1*si;
				}
			}
			
			else {  /* parabola not acceptable, must do a golden section step */
				gs = 1
			}
					
		}
		
		if (gs) { /* a golden-section step is required */
		
			if (xf >= xm) e = a-xf
			else e = b-xf
			
			d = c*e
			
			
		}
		
		/* the function must not be evaluated to close to xf */
		si = sign(d) + (d==0)
		x = xf + si * max( (abs(d)\ tol1) )
		
		inputs=mm_callf_setup(fun, args()-3, a1, a2, a3, a4, a5, a6, a7, a8, a9)  /* second argument is number of arguments to pass to f */
		fu = mm_callf(inputs, x)   /* the value of fun() at x */
		
		funccount = funccount + 1
		
		iter = iter + 1
		
		/* Update a, b, v, w, x, xm, tol1, tol2 */
		
		if (fu <= fx) {
			if (x >= xf) a = xf
			else b = xf
			v = w 
			fv = fw
			w = xf 
			fw = fx
			xf = x
			fx = fu
		}
		else { /*fu > fx*/
			if (x < xf) a = x
			else b = x
			if ( (fu <= fw) || (w == xf) ) {
				v = w
				fv = fw
				w = x 
				fw = fu
			}
			else {
				if ( (fu <= fv) || (v == xf) || (v == w) ) {
					v = x
					fv = fu
				}
			
			}
			
		}
		
		xm = 0.5*(a+b);
		tol1 = seps*abs(xf) + tol/3.0
		tol2 = 2.0*tol1
	
	} /* end while */


fval = fx

struct minimizeroutput scalar output
output.xmin = xf
output.fval = fval

return(output)

}



real scalar fun_root(pointer(function) scalar fun, real scalar ax, real scalar bx, 
					| a1, a2, a3, a4, a5, a6, a7, a8, a9) {

	/* ax and bx are used to check that function(ax) and function(bx) have different signs  */
	
	real scalar fcount, iter, intervaliter, exitflag, tol, toler

	fcount = 0
	iter = 0
	intervaliter = 0
	exitflag = 1

	tol = 2^-52


	real scalar a, b, c, d, e, r, s, savea, saveb, fa, fb, savefa, savefb, fval

	real scalar fc, p, q, m


	a = ax
	b = bx
	savea = a
	saveb = b




	transmorphic inputs

	inputs=mm_callf_setup(fun, args()-3, a1, a2, a3, a4, a5, a6, a7, a8, a9)  /* second argument is number of arguments to pass to f */
	fa = mm_callf(inputs, a)   /* the value of fun() at a */
	fb = mm_callf(inputs, b)   /* the value of fun() at b */

	fcount = fcount + 2
	savefa = fa
	savefb = fb

	if (fa == 0) {
		b = a
		fval = fa
		printf("Note: zero root found at input ax\n")

	}
	else {
		if (fb == 0) {
			fval = fb
			printf("Note: zero root found at input bx\n")
			return(b)

		}
		else {
			if ((fa>0) == (fb > 0))  { /* if fun(a) has same sign as fun(b) */
				printf("{error}Error: function fun() has same sign when evaluated at endpoints ax and bx.")
				exit(1)
			}
		}
	}



	fc = fb


	while (fb != 0 & a != b) {
		
		if ((fb > 0) == (fc > 0)) {  
			c = a
			fc = fa
			d = b - a
			e = d
		}
		if (abs(fc) < abs(fb)) {
			a = b
			b = c
			c = a
			fa = fb
			fb = fc
			fc = fa
		}
		
		
		m = 0.5*(c-b)
		toler = 2*tol*max( (abs(b) \ 1) )
		if ((abs(m) <= toler) || (fb == 0.0)) {  
			break
		}
		
		 if ( (abs(e) < toler) || (abs(fa) <= abs(fb)) )
		 {
		   
			d = m
			e = m
		 }
		else {
			
			s = fb/fa;
			if (a == c) {
				
				p = 2.0*m*s
				q = 1.0 - s
			}
			else {
			
				q = fa/fc
				r = fb/fc
				p = s*(2.0*m*q*(q - r) - (b - a)*(r - 1.0))
				q = (q - 1.0)*(r - 1.0)*(s - 1.0)
			}
			if (p > 0) q = -q
			else p = -p
			
			
			if ( (2.0*p < 3.0*m*q - abs(toler*q)) & (p < abs(0.5*e*q)) ) {
				e = d
				d = p/q
			}
			else {
				d = m
				e = m
			}
		}

		
		a = b
		fa = fb
		if (abs(d) > toler) {
			b = b + d
		}
		else {
			b = (b>c ? b-toler : b+toler)
		}
	   
		
		fb = mm_callf(inputs, b)
		fcount = fcount + 1
		iter = iter + 1
		
		
	} /* end main */

	/* printf("final iter count = %f\n", iter)*/
	fval = fb
	return(b)					
}




real matrix CI_binaryIV(real scalar n, real matrix Y, real matrix M, real matrix PlusSet,
						real matrix X_boot, real scalar nboot, real scalar alpha, real scalar beta, real scalar kappa,
						real scalar LB, real scalar UB, real scalar pi_grid) {
	
	real matrix epsilon_boot, pi_index, X, sign 
	real scalar itt_boot
	real scalar theta0, theta1

	real scalar obj_fun_LB, obj_fun_UB
	
	real scalar root
	
	real scalar fvalroot 
	
	
	struct minimizeroutput scalar results
	
	external real scalar verbose
	
	theta0 = UB
	theta1 = LB
	
	if (verbose) printf("theta0=%f, theta1=%f\n", theta0, theta1)
	
	epsilon_boot = rnormal(n,nboot,0,1)
	

	for (pi_index = 1; pi_index <= pi_grid; pi_index++) {
	
		if (verbose) printf("pi_index=%2.0f\n", pi_index)
		X = X_boot[.,pi_index]
		itt_boot = (X'*Y)/n    
		sign = (itt_boot >= 0)-(itt_boot<0)
		

		if (sign==1) LB=0
		else if (sign==-1) UB=0

		
		results = minimizer(&func_Test(), LB, UB, Y, M, PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))
		if (verbose) printf("theta_int=%f\n", results.xmin)
		if (verbose) printf("fval=%f\n", results.fval)
		
	

		if (results.fval > 0) {
			theta0 = LB
			theta1 = UB
		}
		else {
			
			obj_fun_LB = func_Test(LB, Y, M,PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))  
			if (verbose) printf("obj_fun_LB = %5.3f\n", obj_fun_LB)
			if (obj_fun_LB <= 0) {
				theta0 = LB
			}
			else {


				if (func_Test(itt_boot, Y, M,PlusSet, X, epsilon_boot, (alpha, beta, kappa, n)) < 0) {
					if (verbose) printf("A, LB=%f, itt_boot=%f\n", LB, itt_boot)
					 root = fun_root(&func_Test(), LB, itt_boot, Y, M, PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))
					 if (verbose)  {
					 	fvalroot = func_Test(root,  Y, M,PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))
					 	printf("theta0=%5.3f, root=%5.3f, fvalroot=%f\n", theta0, root, fvalroot)
					 }
					theta0 = min((theta0 \ root))
								
				}
				else {
					if (verbose) printf("B, LB=%f, itt_boot=%f\n", LB, itt_boot)
					root = fun_root(&func_Test(), LB, results.xmin, Y, M, PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))
					 if (verbose) {
					 	fvalroot = func_Test(root,  Y, M,PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))
					 	printf("theta0=%5.3f, root=%5.3f, fvalroot=%f\n", theta0, root, fvalroot)
					 }
					theta0 = min((theta0 \ root))
				}
			}
			
			obj_fun_UB = func_Test(UB, Y, M,PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))
			if (verbose) printf("obj_fun_UB = %5.3f\n", obj_fun_UB)
			
			if (obj_fun_UB <= 0) {
				theta1 = UB
			}
			else {
				
				if (func_Test(itt_boot, Y, M,PlusSet, X, epsilon_boot, (alpha, beta, kappa, n)) < 0) {
					if (verbose) printf("C, UB=%f, itt_boot=%f\n", UB, itt_boot)
					root = fun_root(&func_Test(), itt_boot, UB, Y, M, PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))    			
					 if (verbose) {
					 	fvalroot = func_Test(root,  Y, M,PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))
					 	printf("theta1=%5.3f, root=%5.3f, fvalroot=%f\n", theta1, root, fvalroot)
					 }
					theta1 = max((theta1 \ root))
				
				}
				else {
					if (verbose) printf("D, UB=%f, itt_boot=%f\n", UB, itt_boot)
					root = fun_root(&func_Test(), results.xmin, UB, Y, M, PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))		
					 if (verbose) {
					 	fvalroot = func_Test(root,  Y, M,PlusSet, X, epsilon_boot, (alpha, beta, kappa, n))
					 	printf("theta1=%5.3f, root=%5.3f, fvalroot=%f\n", theta1, root, fvalroot)
					 } 
					theta1 = max((theta1 \ root ))
				}
			}
		}
		if (verbose) (theta0, theta1)
	} 
	
	


	return(theta0, theta1)
	

}

pointer(real matrix) matrix func_X_boot(real matrix Z, real matrix Zz, real scalar pi_grid, real scalar delta, real matrix B, real matrix CovB) {
	
	real scalar Kz, pi_index, k, b, cov_b, temp  
	real matrix Pi
	real matrix X_boot_temp
	pointer(real matrix) matrix X_boot /* output matrix of pointers */	
		
	Kz = cols(Zz)
	
	Pi = J(rows(b), Kz, 0)
	/*X_boot = J(pi_grid, 1, 0)*/
	
	X_boot = J(pi_grid, Kz-1, NULL)
	
	for (pi_index = 1; pi_index <= pi_grid; pi_index++) {
		for (k = 1; k <= Kz; k++) {
			
			b=B[k]   
			cov_b = CovB[k]
			temp = rnormal(rows(b), cols(b), 0, 1)
			Pi[,k] = b + cholesky(cov_b)*temp*sqrt(chi2(rows(b), 1-delta)/(temp'*temp))
		}
		
		for (k = 1; k <= Kz-1; k++) {

			X_boot[pi_index, k] = &( ((Z:==Zz[1,(k+1)]):*Pi[1,k] - (Z:== Zz[1,k]):*Pi[1,(k+1)]) :/ (Pi[1,k]*Pi[1,(k + 1)]) )
		 
			
		}
	}

	return(X_boot)
}



real scalar func_Test_discrete(real scalar theta, real matrix Y, real matrix M, real matrix PlusSet,
							   real matrix X1, real matrix X2, real matrix epsilon_boot, real rowvector scalars) {

	real scalar s, pre_select, cr_2BM
	real matrix M1, M2_a,  M2_b, M2_c, M3_a, M3_b, M3_c, m1, m2, m3
	real matrix Moment, boot_moment, m_Moment, s_Moment, select, select_Moment

	
	real scalar alpha, beta, kappa, n
	real scalar test_diff, cr_select 
	
	alpha = scalars[1]
	beta = scalars[2]
	kappa = scalars[3]
	n = scalars[4]
	

	s = (theta>=0)-(theta<0)
	
	/* main parts of the moment inequalities (see Lemma 5.1)*/
	M1 = -X1:*Y:*s
	M2_a = J(1, kappa, X1)
	M2_b = J(1, kappa, Y)
	M2_c = M*PlusSet:-.5
	
	M3_a = M2_a
	M3_b = M2_b
	M3_c = 1:-J(1, kappa, rowsum(X2)):*M2_c
	
	/* moment inequalities Lemma 5.1 */
	m1 = M1
	m2 = -M2_a:*(M2_b:*s - M2_c:*abs(theta))
	m3 = M3_a:*s:*M3_b - abs(theta)*M3_c
	Moment = (m1, m2, m3)

	
	m_Moment = mean(Moment)
	s_Moment =  sqrt(mm_colvar(Moment))


	boot_moment = epsilon_boot'*(sqrt(n):*(Moment - J(n, 1, m_Moment)):/J(n, 1, s_Moment)):/n
				
	pre_select = s_Moment :>= .001
	
	select_Moment = select(m_Moment, !pre_select)
		


	if (cols(select_Moment) > 0 & max(select_Moment) > 0 ) {
		test_diff = 10 
	}
	else {
		m_Moment = select(m_Moment, pre_select)
		s_Moment = select(s_Moment, pre_select)
		cr_select = -2*mm_quantile(rowmax(boot_moment), 1, 1-beta)
				
		select = (sqrt(n):*m_Moment:/s_Moment) :> cr_select
				
		if(sum(select)==0) { 
			test_diff = max(sqrt(n):*m_Moment:/s_Moment) 

		 }

		 else {
			

			cr_2BM = mm_quantile(rowmax(select(boot_moment,select:*pre_select)), 1, 1-alpha+2*beta)
			test_diff = max(sqrt(n):*m_Moment:/s_Moment) - cr_2BM 
			

		 } 

	}
	
	return(test_diff)
	
}




real matrix CI(real scalar n, real matrix Y, real matrix M, real matrix PlusSet,
			   real matrix X1_boot, real matrix X2_boot, real scalar nboot, 
			   real scalar alpha, real scalar beta, real scalar kappa,
			   real scalar LB_init, real scalar UB_init, real scalar pi_grid) {
	
	/* CI for discrete IV */
	
	real matrix epsilon_boot, pi_index, X1, X2, sign 
	real scalar itt_boot
	real scalar theta0, theta1
	
	real scalar obj_fun_LB, obj_fun_UB
	real scalar X2k, i
	
	real scalar root 
	
	
	struct minimizeroutput scalar results
	
	external real scalar verbose
	
	real scalar LB, UB
	
	LB = LB_init
	UB = UB_init
	
	theta0 = UB
	theta1 = LB
	
	if (verbose) printf("theta0=%f, theta1=%f\n", theta0, theta1)
	
	epsilon_boot = rnormal(n,nboot,0,1)
	
	X2k = cols(X2_boot)/pi_grid
		
	X2 = J(rows(X2_boot), X2k, 0)  
	

	for (pi_index = 1; pi_index <= pi_grid; pi_index++) {
	
		if (verbose) printf("pi_index=%2.0f\n", pi_index)
		X1 = X1_boot[.,pi_index]
		for(i = 1; i <= X2k; i++) {
			if (verbose) (i-1)*pi_grid + pi_index
			X2[,i] = X2_boot[.,((i-1)*pi_grid + pi_index)]
		}
		
		
		
		
		itt_boot = (X1'*Y)/n
		sign = (itt_boot >= 0)-(itt_boot<0)
		

		if (sign==1) LB=0
		else if (sign==-1) UB=0


		results = minimizer(&func_Test_discrete(), LB, UB, Y, M, PlusSet, X1, X2, epsilon_boot, (alpha, beta, kappa, n))
		
		if (verbose) printf("theta_int=%f\n", results.xmin)
		if (verbose) printf("fval=%f\n", results.fval)
		
	

		if (results.fval > 0) {
			theta0 = LB
			theta1 = UB
		}
		else {
			
			obj_fun_LB = func_Test_discrete(LB, Y, M,PlusSet, X1, X2, epsilon_boot, (alpha, beta, kappa, n))  
			if (verbose) printf("obj_fun_LB = %5.3f\n", obj_fun_LB)

			if (obj_fun_LB <= 0) {
				theta0 = LB
			}   
			else {   /* if obj_fun_LB > 0 */
				
				root = fun_root(&func_Test_discrete(), LB, results.xmin, Y, M, PlusSet, X1, X2, epsilon_boot, (alpha, beta, kappa, n))
				if (verbose) printf("root=%5.3f\n", root)
				theta0 = min((theta0 \ root))
			}
			
			obj_fun_UB = func_Test_discrete(UB, Y, M,PlusSet, X1, X2, epsilon_boot, (alpha, beta, kappa, n))
			if (verbose) printf("obj_fun_UB = %5.3f\n", obj_fun_UB)
			
			if (obj_fun_UB <= 0) {
				theta1 = UB
			}
			else {
				root = fun_root(&func_Test_discrete(), results.xmin, UB, Y, M, PlusSet, X1, X2, epsilon_boot, (alpha, beta, kappa, n))
				if (verbose) printf("root=%5.3f\n", root)
				theta1 = max((theta1 \ root ))
			}
			

		}
		if (verbose) (theta0, theta1)
		
	} 
	
	return(theta0, theta1)
	

}




end	






