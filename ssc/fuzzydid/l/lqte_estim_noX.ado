/*
lqte_estim_noX.ado performs the following operation:
1) It computes the LQTEs. It calls qq_transfo.mo to compute the 
quantile-quantile transforms Q_d, and my_sort.mo to rearrange the cdfs of
Y(0) and Y(1) and ensure that they are increasing and included between 0 and 1.
*/

quietly capture program drop lqte_estim_noX
quietly program lqte_estim_noX, eclass sortpreserve

	version 12

	syntax varlist(min=4 max=4 numeric) [if] [in] ///
	[, MOREOUTPUT true_D(name) BOOT is_special_case(numlist)]
	
	tokenize `varlist', parse(" ,")
	
	args Y G T D
	
	marksample touse
	
	preserve
		
	tempname minY maxY mean_Y_11 quantile quantiles
		
	quietly {
		
		keep if `touse'
		count
		local tot_obs=r(N)
		sum `Y'
		local minY=r(min)
		local maxY=r(max)
		sum `Y' if `G'==1 & `T'==1
		local maxY_11=r(max)-0.001
		
		/*compute P(D_1t=1)*/		
		forvalues i=0(1)1 {
			
			tempname mean_D_1`i'
			quietly sum `true_D' if `G'==1 & `T'==`i', meanonly
			scalar `mean_D_1`i''=r(mean)
		}
		
		/*if treatment variable takes only one value 
		in control group, identify this value.*/
		if `is_special_case'==1 {	
			
			tempname mean_D_0
			sum `D' if `G'==0, meanonly
			scalar `mean_D_0'=r(mean)		
		}

		local Ntierce=`tot_obs'+1
	
		/*if more than 11000 obs, create an equidistant grid of 11000 points 
		between min-1/11000 and max of the support of the data*/
		if `tot_obs'>11000 {
			
			tempvar newY_grid
			local N=`tot_obs'
			local Nbis=`tot_obs'+11000
			set obs `Nbis'
			local a=`minY'-(`maxY'-`minY')/11000
			range `newY_grid' `a' `maxY' 11000 
			replace `Y'=`newY_grid'[_n-`N'] in `N'/`Nbis'
			drop `newY_grid'
		}
		
		/*otherwise extract single values of Y in the data and use them
		as a new dataset*/
		else {
			
			tempvar is_first newY_grid
			tempname count_first
			sort `Y', stable
			bysort `Y': gen `is_first'=cond(_n==1,1,0)
			count if `is_first'==1
			scalar `count_first'=r(N)+1
			local Nbis=`tot_obs'+`count_first'
			mata: createYvalues("`Y'","`is_first'","`count_first'","`newY_grid'")
			replace `Y'=`newY_grid' in `Ntierce'/`Nbis'
			drop `newY_grid' `is_first'
		}
		
		/*create an index that identifies those "new" datapoints*/
		tempvar indice 
		gen `indice'=1 in `Ntierce'/`Nbis'
		replace `indice'=0 if `indice'==.
		
		/*compute counterfactual CDFs evaluated at new grid points*/		
		
		display `Ntierce'
		display `Nbis'		
		tab `indice'
		
		
		/*estimator of LQTE */		
		
		local pb_comp=0		

		forvalues i=1(1)2 {
			
			/*empty variable to store counterfactual CDF of Y(i) for switchers
			in treatment group*/
			tempvar F_`i'
			gen `F_`i''=0			
	
			/*update of the first term in numerator of CDF of Y(i) among switchers*/
			count if `D'==`i' & `G'==1 & `T'==1		
			
			if r(N)!=0 {
				
				tempvar F_`i'11			
				
				/*create CDF in group {D=i,G=1,T=1}*/
				cumul `Y' if `D'==`i' & `G'==1 & `T'==1, gen(`F_`i'11') equal
				sort `Y' `F_`i'11', stable

				/*apply this CDF to observations not belonging to that group*/
				replace `F_`i'11'=0 in 1/1 if `F_`i'11'>=. 
				replace `F_`i'11'=`F_`i'11'[_n-1] if `F_`i'11'>=.	
								
				/*update of counterfactual CDF*/
				if `i'==1 {
				
					replace `F_`i''=(1-`mean_D_11')*`F_`i'11'/ ///
					(1-`mean_D_11'-(1-`mean_D_10'))
				}
				else {
				
					replace `F_`i''=`mean_D_11'*`F_`i'11'/ ///
					(`mean_D_11'-`mean_D_10')
				}
			}
			
			/*update of the second term in numerator of CDF of Y(i) among switchers*/			
			count if `D'==`i' & `G'==1 & `T'==0 

			if r(N)!=0 {
	
				tempvar inv_Q`i' is_in_`i'00 is_in_`i'01 Ybis F_`i'10 is_in_`i'10
				
				/*create CDF in group {D=i,G=1,T=0}*/
				cumul `Y' if `D'==`i' & `G'==1 & `T'==0 ///
				, gen(`F_`i'10') equal					
				
				gen `is_in_`i'10'=(`D'==`i' & `G'==1 & `T'==0)
				
				if `is_special_case'==0 {
	
					gen `is_in_`i'00'=(`D'==`i' & `G'==0 & `T'==0)
					count if `is_in_`i'00'==1
					local count_`i'00=r(N)
					gen `is_in_`i'01'=(`D'==`i' & `G'==0 & `T'==1)
					count if `is_in_`i'01'==1
					local count_`i'01=r(N)					
				}
				else {
				
					gen `is_in_`i'00'=(`D'==`mean_D_0' & `G'==0 & `T'==0)
					count if `is_in_`i'00'==1
					local count_`i'00=r(N)					
					gen `is_in_`i'01'=(`D'==`mean_D_0' & `G'==0 & `T'==1)
					count if `is_in_`i'01'==1
					local count_`i'01=r(N)										
				}
				
				if (`count_`i'00'!=0 & `count_`i'01'!=0) {
					
					mata:qq_transfo("`Y'","`is_in_`i'00'","`is_in_`i'01'","`indice'","`inv_Q`i''")
					drop `is_in_`i'00' `is_in_`i'01' `is_in_`i'10'										
					
					/*create a variable equal to Y for old obs and Q_i^{-1} for new obs.
					Then we sort on this new variable and on F_{i10}. This allows
					to evaluate F_{i10} on Q_i^{-1}'s support.*/	
					gen `Ybis'=`inv_Q`i'' if `indice'==1
					replace `Ybis'=`Y' if `Ybis'==.
					sort `Ybis' `F_`i'10', stable
					replace `F_`i'10'=0 in 1/1 if `F_`i'10'>=. 
					replace `F_`i'10'=`F_`i'10'[_n-1] ///
					if `F_`i'10'>=.
					 	
						
					/*update counterfactual CDF*/
					if `i'==1 {
						
						replace `F_`i''=`F_`i''-(1-`mean_D_10')*`F_`i'10'/ ///
						(1-`mean_D_11'-(1-`mean_D_10'))
					}
					else {
						
						replace `F_`i''=`F_`i''-`mean_D_10'*`F_`i'10'/ ///
						(`mean_D_11'-`mean_D_10')					
					}
					
					drop `inv_Q`i''
					*`F_inv_Q`i''
				}
				else {
				
					local pb_comp=1
					drop `is_in_`i'00' `is_in_`i'01' `is_in_`i'10'
				}
			}
			
			sum `F_`i'', meanonly
			local pb_comp`i'=r(mean)
		}		

		local N_q=19
		
		if `pb_comp'==0 & `pb_comp1'!=0 & `pb_comp2'!=0 {
		
			/*keep only the new datapoints*/
			keep if `indice'==1
			quietly count if `indice'==1
			local N_obs=r(N)						
			sort `Y', stable
			mata: my_sort("`F_1'")
			mata: my_sort("`F_2'")					
			
			/*compute LQTEs for each treatment status*/			
			matrix `quantile'=J(`N_q',2,0)					
			
			forvalues h=1(1)2 {
				
				replace `F_`h''=0 if `F_`h''<0
				replace `F_`h''=1 if `F_`h''>1
				replace `F_`h''=1 if `Y'>=`maxY_11'
				
				forvalues i=1(1)`N_q' {
					
					local tau=(1/(`N_q'+1))*`i'
					sum `Y' if `F_`h''>=`tau'
					
					if r(N)==0 {
					
						matrix `quantile'[`i',`h']=.
					}
					else {
					
						matrix `quantile'[`i',`h']=r(min)
					}
				}
			}		
																									
			matrix `quantiles'=`quantile'[1...,2]-`quantile'[1...,1]
					
		}
		else {
		
			matrix `quantiles'=J(`N_q',1,.)	
		}
	
		local q_list ""
		forvalues i=1(1)19 {
		
			local q=`i'*5
			local q_list "`q_list' q_`q'"
		}
		
		matrix rownames `quantiles'=`q_list'

		ereturn matrix LQTE=`quantiles'
	}
end
