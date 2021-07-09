/*
late_estim_X.ado performs the following operation:
1) It computes the Wald-DID and Wald-TC with covariates, calling 
build_cond_expectation_1.ado. If the tc option was specified, it also calls
build_cond_expectation_2.ado. If the sieve option was specified, it also calls 
legendrisation.ado to compute the Legendre polynomials in X. If the sieve option was 
specified, but sieve_order was not, it also calls five_fold_cv.ado to determine the 
polynomial order to be used in the series approximation.
*/

quietly capture program drop late_estim_X
quietly program late_estim_X, eclass

	version 12

	syntax varlist(min=4 numeric) [if] [in] ///
	[, ncateg(numlist) true_D(name) ///
	DID TC CIC LQTE DIDD ncateg_y(name) continuous(varlist num fv) ///
	qualitative(varlist num fv) numerator ///
	y_reg_method(name) d_reg_method(name) d_reg_method2(name) ///
	sieve_expansion_Y(varlist num) sieve_expansion_D(varlist num) ///
	inf_method(name) is_special_case(numlist) WEIGHTS ALPHA]
	
	tokenize `varlist', parse(" ,")		 
	marksample touse
	
	args Y G T D
	preserve
	
	quietly {
		
		keep if `touse'
		
		local n_quali=wordcount("`qualitative'")
		
		/*
		local quali_list ""
		
		/*binarisation of categorical variables*/
		forvalues i=1(1)`n_quali' {
		
			local a: word `i' of `qualitative'						
			tabulate `a', gen (`a'_)			
			tab `a', nofreq
			local ncateg_quali_var=r(r)
			
			forvalues j=2(1)`ncateg_quali_var' {
			
				local quali_list "`quali_list' `a'_`j'"
			}
		}
		
		local covariates "`quali_list' `continuous'"*/
		
		/*Means of D and Y conditional on G=1 and T=1*/		
		tempname mean_Y_11 mean_D_11
		sum `true_D' if `G'==1 & `T'==1, meanonly
		scalar `mean_D_11'=r(mean)
		
		if "`did'"!="" | "`tc'"!="" | "`cic'"!="" {
		
			sum `Y' if `G'==1 & `T'==1, meanonly
			scalar `mean_Y_11'=r(mean)
		}
	
		tempname mean_Y_10_11 mean_D_10_11
		tempvar pred
		
		if "`did'"!="" | "`tc'"!="" | "`cic'"!="" {
			
			/*computation of conditional expectation E(Y_10|X)*/
			
			sum `Y' if `G'==1 & `T'==0
			
			if r(min)==r(max) {
			
				scalar `mean_Y_10_11'=r(mean)
			}
			else {
									
				build_cond_expectation_1 `Y' `G' `T', ///
				inf_method(`inf_method') ///
				reg_method(`y_reg_method') ///
				continuous(`continuous') qualitative(`qualitative') ///
				i(1) j(0) target(`pred') ///
				sieve_expansion(`sieve_expansion_Y')						
				sum `pred', meanonly
				scalar `mean_Y_10_11'=r(mean)
				drop `pred'
			}
		}
		
		
		/*computation of conditional expectation E(D_10|X)*/
		
		sum `true_D' if `G'==1 & `T'==0
		
		if r(min)==r(max) {
		
			scalar `mean_D_10_11'=r(mean)
		}
		else {
		
			build_cond_expectation_1 `true_D' `G' `T', ///
			inf_method(`inf_method') ///
			reg_method(`d_reg_method') ///
			continuous(`continuous') qualitative(`qualitative') ///
			i(1) j(0) target(`pred') ///
			sieve_expansion(`sieve_expansion_D')
			sum `pred', meanonly
			scalar `mean_D_10_11'=r(mean)
			drop `pred'		
		}
			
		if "`tc'"!="" | "`cic'"!="" | "`lqte'"!="" {
		
			tempvar indic_D
			local d_probs_list ""
			
			forvalues d=1(1)`ncateg' {
				
				count if `D'==`d' & `G'==1 & `T'==0 

				/*value of treatment relevant only if some people in
				{G=1,T=0} have that value*/				
				
				if r(N)!=0 {
						
					/*conditional probability P(D_10=d|X_11) where D is
					recategorised*/
					tempvar pred_`d'
					gen `indic_D'=(`D'==`d')
					sum `indic_D' if `G'==1 & `T'==0
					
					if r(min)==r(max) {
					
						gen `pred_`d''=r(mean) if `G'==1 & `T'==1
					}
					else {
					
						build_cond_expectation_1 `indic_D' `G' `T', ///
						inf_method(`inf_method') ///
						reg_method(`d_reg_method2') ///
						continuous(`continuous') qualitative(`qualitative') ///
						i(1) j(0) target(`pred_`d'') ///
						sieve_expansion(`sieve_expansion_D')					
					}
					
					local d_probs_list "`d_probs_list' `pred_`d''"
					drop `indic_D'					
				}
			}
		}			
		
		***************************
		
		
		/*did computation*/
		if "`did'"!="" | "`didd'"!="" {
		
			tempname DID_Y DID_D W_DID
			
			forvalues i=0(1)1 {

				tempname mean_Y_0`i'_11 mean_D_0`i'_11
				tempvar pred			
				
				/*computation of E(Y_0t|X_11)*/	
				sum `Y' if `G'==0 & `T'==`i'
				
				if r(min)==r(max) {
				
					scalar `mean_Y_0`i'_11'=r(mean)
				}
				else {
				
					quietly build_cond_expectation_1 `Y' `G' `T', ///
					inf_method(`inf_method') ///
					reg_method(`y_reg_method') ///
					continuous(`continuous') qualitative(`qualitative') ///
					i(0) j(`i') target(`pred') ///
					sieve_expansion(`sieve_expansion_Y')						
					sum `pred', meanonly
					scalar `mean_Y_0`i'_11'=r(mean)	
					drop `pred'
				}
				
				/*computation of E(D_0t|X_11) with non-recategorised D*/	
				sum `true_D' if `G'==0 & `T'==`i'
				
				if r(min)==r(max) {
				
					scalar `mean_D_0`i'_11'=r(mean)
				}
				else {
				
					build_cond_expectation_1 `true_D' `G' `T', ///
					inf_method(`inf_method') ///
					reg_method(`d_reg_method') ///
					continuous(`continuous') qualitative(`qualitative') ///
					i(0) j(`i') target(`pred') ///
					sieve_expansion(`sieve_expansion_D')
					sum `pred', meanonly
					scalar `mean_D_0`i'_11'=r(mean)
					display `mean_D_0`i'_11'
					drop `pred'	
				}
			}
			
			scalar `DID_D'=`mean_D_11'-`mean_D_10_11'-(`mean_D_01_11'-`mean_D_00_11')	
			scalar `DID_Y'=`mean_Y_11'-`mean_Y_10_11'- ///
			(`mean_Y_01_11'-`mean_Y_00_11')
			scalar `W_DID'=`DID_Y'/`DID_D'		
		}
	
	
		if "`tc'"!="" {
			
			/*if treatment takes only one value in control, enter*/
			if `is_special_case'==0 {
	
				tempname mean_W_TC_build w_tc D_probs_vec num_tc			
				tempvar pred_Y0 pred_Y1 Wald_TC_build
				local ncateg=`ncateg'
				matrix `D_probs_vec'=J(`ncateg',1,0)
				gen `Wald_TC_build'=0
				
				forvalues d=1(1)`ncateg' {
					
					count if `D'==`d' & `G'==1 & `T'==0 
					
					    /*value of treatment relevant only if some people in
					    {G=1,T=0} have that value*/
					if r(N)!=0 {
												
						/*conditional expectations E(Y_d00|X_11) and E(Y_d01|X_11) 
						and computation of delta_d*/
						
						build_cond_expectation_2 `Y' `G' `T' `D', ///
						inf_method(`inf_method') ///
						reg_method(`y_reg_method') ///
						continuous(`continuous') qualitative(`qualitative') ///
						d(`d') target0(`pred_Y0') target1(`pred_Y1') ///
						sieve_expansion(`sieve_expansion_Y')
						
						/*update of W_TC*/
						replace `Wald_TC_build'=`Wald_TC_build'+`pred_`d''* ///
						(`pred_Y1'-`pred_Y0')
						drop `pred_Y0' `pred_Y1' 
					}
				}
				
				sum `Wald_TC_build', meanonly
				scalar `mean_W_TC_build'=r(mean)
				scalar `w_tc'=(`mean_Y_11'-`mean_Y_10_11'-`mean_W_TC_build')/ ///
				(`mean_D_11'-`mean_D_10_11')			
				scalar `num_tc'=`mean_Y_11'-`mean_Y_10_11'-`mean_W_TC_build'
			}
		}
		

		ereturn clear
		
		if "`didd'"!="" {
		
			ereturn scalar DID_D=`DID_D'
		}
		
		if "`did'"!="" {
		
			if "`numerator'"!="" {
			
				ereturn scalar DID_num=`DID_Y'
			}
			else {
			
				ereturn scalar W_DID=`W_DID'
			}
		}
		
		if "`tc'"!="" {
		
			if	`is_special_case'==1 {
			
				if "`numerator'"!="" {
				
					ereturn scalar TC_num=`DID_Y'
				}
				else {
				
					ereturn scalar W_TC=`W_DID'
				}
			}		
			else {
	
				if "`numerator'"!="" {
				
					ereturn scalar TC_num=`num_tc'
				}
				else {
				
					ereturn scalar W_TC=`w_tc'
				}
			}
		}	
	}
end
