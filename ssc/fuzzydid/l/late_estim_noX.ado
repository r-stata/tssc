/*
late_estim_noX.ado performs the following operation:
1) It computes the Wald-DID, Wald-TC, Wald-CIC without covariates. To compute 
the Wald-CIC, it uses qq_transfo.mo . 
*/

quietly capture program drop late_estim_noX
quietly program late_estim_noX, eclass

	version 12

	syntax varlist(min=4 numeric) [if] [in] ///
	[, ncateg(numlist) cluster(name) true_D(name) NUMERATOR ///
	DID TC CIC DIDD LQTE MOREOUTPUT PARTIAL ///
	is_special_case(numlist)]
	
	tokenize `varlist', parse(" ,")		 
	marksample touse
	
	args Y G T D
	preserve	
	local equality_control=0
	local no_need_tc=0
			

	quietly {
	
		keep if `touse'
		
		sum `Y'
		local minY=r(min)

		/*did computation*/
		if "`did'"!="" | "`didd'"!="" {
		
			tempname DID_Y DID_D W_DID
						
			forvalues i=0(1)1 {
			
				forvalues j=0(1)1 {
				
					tempname mean_D_`i'`j' obs_`i'`j'
					sum `true_D' if `G'==`i' & `T'==`j' 
					scalar `mean_D_`i'`j''=r(mean)
					scalar `obs_`i'`j''=r(N)
				}
			}
			
			forvalues i=0(1)1 {
			
				forvalues j=0(1)1 {
				
					tempname mean_Y_`i'`j'
					sum `Y' if `G'==`i' & `T'==`j'
					scalar `mean_Y_`i'`j''=r(mean)
				}
			}
		
			scalar `DID_Y'=`mean_Y_11'-`mean_Y_10'-(`mean_Y_01'-`mean_Y_00')
			scalar `DID_D'=`mean_D_11'-`mean_D_10'-(`mean_D_01'-`mean_D_00')
			scalar `W_DID'=`DID_Y'/`DID_D'
		}
		
		/*tc computation*/
		if "`tc'"!="" {
					
			if `is_special_case'==0 {
				
				local Wald_TC_build=0
				local ncateg=`ncateg'
			
				forvalues i=0(1)1 {
					
					tempname mean_Y_1`i' 
					sum `Y' if `G'==1 & `T'==`i', meanonly
					scalar `mean_Y_1`i''=r(mean)
					
					forvalues j=0(1)1 {
					
						tempname mean_D_`i'`j' obs_`i'`j'
						sum `true_D' if `G'==`i' & `T'==`j'
						scalar `mean_D_`i'`j''=r(mean)
						scalar `obs_`i'`j''=r(N)
					}
				}	
												
				/*some quantities that need to be computed if partial option 
				specified*/
				if "`partial'"!="" {
				
					tempname minY maxY delta_inf delta_sup
					sum `Y'
					scalar `minY'=r(min)
					scalar `maxY'=r(max)
					scalar `delta_inf'=0
					scalar `delta_sup'=0
					local Wald_TC_inf_build=0
					local Wald_TC_sup_build=0
					
					forvalues j=0(1)1 {
					
						tempname P_D_10`j'
						scalar `P_D_10`j''=0
					}
					
					forvalues i=1(1)`ncateg' {
						
						local ibis=`i'+1
						
						forvalues j=0(1)1 {
						
							tempname P_D_`ibis'0`j'
							count if `D'<=`i' & `G'==0 & `T'==`j'
							scalar `P_D_`ibis'0`j''=r(N)/`obs_0`j''
						}					
					}
					
					forvalues j=0(1)1 {
					
						tempname P_D_10`j'
						scalar `P_D_10`j''=0
					}
				}
				
				/*compute delta_d for each value of the treatment (or the 
				corresponding quantities in the partial identification case when 
				partial specified)*/
				forvalues i=1(1)`ncateg' {
					
					local ibis=`i'+1
					quietly count if `D'==`i' & `G'==1 & `T'==0
					
					if r(N)!=0 {
						
						
						tempvar indic_`i' eta`i' psi_w`i'
						tempname delta_`i' P_D_`i'10 mean_Y`i'01 mean_Y`i'00
						
						scalar `P_D_`i'10'=r(N)/`obs_10'
						
						sum `Y' if `G'==0 & `T'==1 & `D'==`i', meanonly						
						scalar `mean_Y`i'01'=r(mean)						
						sum `Y' if `G'==0 & `T'==0 & `D'==`i', ///
						meanonly						
						scalar `mean_Y`i'00'=r(mean)
						
						scalar `delta_`i''=`mean_Y`i'01'-`mean_Y`i'00'
						local Wald_TC_build=`Wald_TC_build'+`P_D_`i'10'*`delta_`i''												
						
						if "`partial'"!="" {
							
							count if `D'==`i' & `G'==0 & `T'==1
							local N_dgt=r(N)	
							
							if `ncateg'==2 {
								
								tempname ratio qinf qsup 
								
								scalar `ratio'=(`P_D_`ibis'01'- ///
								`P_D_`i'01')/(`P_D_`ibis'00'- ///
								`P_D_`i'00')
								
								display `ratio'
									
								if `i'==1 {
							
									scalar `delta_inf'=(1-`ratio')*`minY'+ ///
									`ratio'*`mean_Y`i'01'
									scalar `delta_sup'=(1-`ratio')*`maxY'+ ///
									`ratio'*`mean_Y`i'01'	
								}
								else {
									
									local a=100*(1-1/`ratio')							
									
									if `a'<=100/`N_dgt' {
										
										sum `Y' if `D'==`i' & `G'==0 & `T'==1
										scalar `qsup'=r(min)										
									}
									else {
										
										if `a'!=. {
										
											if `a'>=100 {
											
												sum `Y' if `D'==`i' & `G'==0 & `T'==1
												scalar `qsup'=r(max)									
											}
											else {
											
												_pctile `Y' if `D'==`i' & `G'==0 & `T'==1, p(`a')
												scalar `qsup'=r(r1)
											}
										}
										else {
										
											scalar `qsup'=.
										}
									}
																						
		
									local a=100/`ratio'
									
									if `a'<=100/`N_dgt' {
										
										sum `Y' if `D'==`i' & `G'==0 & `T'==1
										scalar `qinf'=r(min)										
									}
									else {
										
										if `a'!=. {
										
											if `a'>=100 {
											
												sum `Y' if `D'==`i' & `G'==0 & `T'==1
												scalar `qinf'=r(max)									
											}
											else {
											
												_pctile `Y' if `D'==`i' & `G'==0 & `T'==1, p(`a')
												scalar `qinf'=r(r1)
											}										
										}
										else {
										
											scalar `qinf'=.
										}
									}
									
									if `qinf'!=. {
									
										sum `Y' if `D'==`i' & `G'==0 & `T'==1 & `Y'<=`qinf'
										scalar `delta_inf'=r(mean)
									}
									else {
									
										scalar `delta_inf'=.
									}
									
									if `qsup'!=. {
									
										sum `Y' if `D'==`i' & `G'==0 & `T'==1 & `Y'>=`qsup'
										scalar `delta_sup'=r(mean)	
									}
									else {
									
										scalar `delta_sup'=.
									}
								}
							}
							else {
								
								/*when treatment not binary and partial specified, 
								expression of the bounds depends on distribution
								of treatment in period 0 and 1 in control group,
								the lines below handle all the subcases*/
								if (`P_D_`i'01'>=`P_D_`i'00' & ///
								`P_D_`ibis'01'<=`P_D_`ibis'00') {
								
									tempname ratio
									scalar `ratio'=(`P_D_`ibis'01'- ///
									`P_D_`i'01')/(`P_D_`ibis'00'- ///
									`P_D_`i'00')									
									
									scalar `delta_inf'=`ratio'*`mean_Y`i'01'+ ///
									(1-`ratio')*`minY'
									scalar `delta_sup'=`ratio'*`mean_Y`i'01'+ ///
									(1-`ratio')*`maxY'	
								}
								else if (`P_D_`i'01'<=`P_D_`i'00' & ///
								`P_D_`ibis'01'>=`P_D_`ibis'00') {
								
									tempname ratio qsup qinf
									scalar `ratio'=(`P_D_`ibis'00'- ///
									`P_D_`i'00')/(`P_D_`ibis'01'- ///
									`P_D_`i'01')
									
									local a=100*(1-`ratio')

									if `a'<=100/`N_dgt' {
										
										sum `Y' if `D'==`i' & `G'==0 & `T'==1
										scalar `qsup'=r(min)										
									}
									else {
										
										if `a'!=. {
										
											if `a'>=100 {
											
												sum `Y' if `D'==`i' & `G'==0 & `T'==1
												scalar `qsup'=r(max)									
											}
											else {
											
												_pctile `Y' if `D'==`i' & `G'==0 & `T'==1, p(`a')
												scalar `qsup'=r(r1)
											}
										}
										else {
										
											scalar `qsup'=.
										}
									}
														
									local a=100*`ratio'
									
									if `a'<=100/`N_dgt' {
										
										sum `Y' if `D'==`i' & `G'==0 & `T'==1
										scalar `qinf'=r(min)										
									}
									else {
										
										if `a'!=. {
										
											if `a'>=100 {
											
												sum `Y' if `D'==`i' & `G'==0 & `T'==1
												scalar `qinf'=r(max)									
											}
											else {
											
												_pctile `Y' if `D'==`i' & `G'==0 & `T'==1, p(`a')
												scalar `qinf'=r(r1)
											}										
										}
										else {
										
											scalar `qinf'=.
										}
									}									
									
									if `qinf'!=. {
									
										sum `Y' if `D'==`i' & `G'==0 & `T'==1 & `Y'<=`qinf'
										scalar `delta_inf'=r(mean)
									}
									else {
									
										scalar `delta_inf'=.
									}
									
									if `qsup'!=. {
									
										sum `Y' if `D'==`i' & `G'==0 & `T'==1 & `Y'>=`qsup'
										scalar `delta_sup'=r(mean)	
									}
									else {
									
										scalar `delta_sup'=.
									}
								}
								else if (`P_D_`i'01'<=`P_D_`i'00' & ///
								`P_D_`ibis'01'>=`P_D_`i'00') {
								
									tempname ratio1 ratio2 qsup qinf
									scalar `ratio1'=(`P_D_`ibis'01'- ///
									`P_D_`i'00')/(`P_D_`ibis'01'- ///
									`P_D_`i'01')
									scalar `ratio2'=(`P_D_`ibis'01'- ///
									`P_D_`i'00')/(`P_D_`ibis'00'- ///
									`P_D_`i'00')
									
									
									local a=100*(1-`ratio1')
									
									if `a'<=100/`N_dgt' {
										
										sum `Y' if `D'==`i' & `G'==0 & `T'==1
										scalar `qsup'=r(min)										
									}
									else {
										
										if `a'!=. {
										
											if `a'>=100 {
											
												sum `Y' if `D'==`i' & `G'==0 & `T'==1
												scalar `qsup'=r(max)									
											}
											else {
											
												_pctile `Y' if `D'==`i' & `G'==0 & `T'==1, p(`a')
												scalar `qsup'=r(r1)
											}
										}
										else {
										
											scalar `qsup'=.
										}
									}
																									
									local a=100*`ratio1'
									
									if `a'<=100/`N_dgt' {
										
										sum `Y' if `D'==`i' & `G'==0 & `T'==1
										scalar `qinf'=r(min)										
									}
									else {
										
										if `a'!=. {
										
											if `a'>=100 {
											
												sum `Y' if `D'==`i' & `G'==0 & `T'==1
												scalar `qinf'=r(max)									
											}
											else {
											
												_pctile `Y' if `D'==`i' & `G'==0 & `T'==1, p(`a')
												scalar `qinf'=r(r1)
											}										
										}
										else {
										
											scalar `qinf'=.
										}
									}									

									if `qinf'!=. {
									
										sum `Y' if `D'==`i' & `G'==0 & `T'==1 & `Y'<=`qinf'
										scalar `delta_inf'=`ratio2'*r(mean)+(1-`ratio2')*`minY'
									}
									else {
									
										scalar `delta_inf'=.
									}
									
									if `qsup'!=. {
									
										sum `Y' if `D'==`i' & `G'==0 & `T'==1 & `Y'>=`qsup'
										scalar `delta_sup'=`ratio2'*r(mean)+(1-`ratio2')*`maxY'
									}
									else {
									
										scalar `delta_sup'=.
									}
								}
								else if (`P_D_`i'01'<=`P_D_`ibis'00' & ///
								`P_D_`ibis'01'>=`P_D_`ibis'00') {
								
									tempname ratio1 ratio2 qsup qinf
									scalar `ratio1'=(`P_D_`ibis'00'- ///
									`P_D_`i'01')/(`P_D_`ibis'01'- ///
									`P_D_`i'01')
									scalar `ratio2'=(`P_D_`ibis'00'- ///
									`P_D_`i'01')/(`P_D_`ibis'00'- ///
									`P_D_`i'00')

									local a=100*(1-`ratio1')
									
									if `a'<=100/`N_dgt' {
										
										sum `Y' if `D'==`i' & `G'==0 & `T'==1
										scalar `qsup'=r(min)										
									}
									else {
										
										if `a'!=. {
										
											if `a'>=100 {
											
												sum `Y' if `D'==`i' & `G'==0 & `T'==1
												scalar `qsup'=r(max)									
											}
											else {
											
												_pctile `Y' if `D'==`i' & `G'==0 & `T'==1, p(`a')
												scalar `qsup'=r(r1)
											}
										}
										else {
										
											scalar `qsup'=.
										}
									}									
									
									
									
								
									local a=100*`ratio'
									
									if `a'<=100/`N_dgt' {
										
										sum `Y' if `D'==`i' & `G'==0 & `T'==1
										scalar `qinf'=r(min)										
									}
									else {
										
										if `a'!=. {
										
											if `a'>=100 {
											
												sum `Y' if `D'==`i' & `G'==0 & `T'==1
												scalar `qinf'=r(max)									
											}
											else {
											
												_pctile `Y' if `D'==`i' & `G'==0 & `T'==1, p(`a')
												scalar `qinf'=r(r1)
											}										
										}
										else {
										
											scalar `qinf'=.
										}
									}									
									
									if `qinf'!=. {
									
										sum `Y' if `D'==`i' & `G'==0 & `T'==1 & `Y'<=`qinf'
										scalar `delta_inf'=`ratio2'*r(mean)+(1-`ratio2')*`minY'
									}
									else {
									
										scalar `delta_inf'=.
									}
									
									if `qsup'!=. {
									
										sum `Y' if `D'==`i' & `G'==0 & `T'==1 & `Y'>=`qsup'
										scalar `delta_sup'=`ratio2'*r(mean)+(1-`ratio2')*`maxY'		
									}
									else {
									
										scalar `delta_sup'=.
									}
								}
								else {
								
									scalar `delta_inf'=`minY'
									scalar `delta_sup'=`maxY'																										
								}
							}
							
							scalar `delta_inf'=`delta_inf'-`mean_Y`i'00'
							scalar `delta_sup'=`delta_sup'-`mean_Y`i'00'							
							local Wald_TC_inf_build=`Wald_TC_inf_build'+`P_D_`i'10'*`delta_sup'
							local Wald_TC_sup_build=`Wald_TC_sup_build'+`P_D_`i'10'*`delta_inf'							
						}						
					}		
				}
								
				if "`partial'"!="" {
					
					tempname W_TC_inf W_TC_sup
					scalar `W_TC_inf'=(`mean_Y_11'-`mean_Y_10'-`Wald_TC_inf_build')/ ///
					(`mean_D_11'-`mean_D_10')	
					scalar `W_TC_sup'=(`mean_Y_11'-`mean_Y_10'-`Wald_TC_sup_build')/ ///
					(`mean_D_11'-`mean_D_10')
				}
				else {
					
					tempname w_tc num_tc
					scalar `w_tc'=(`mean_Y_11'-`mean_Y_10'-`Wald_TC_build')/ ///
					(`mean_D_11'-`mean_D_10')
					scalar `num_tc'=`mean_Y_11'-`mean_Y_10'-`Wald_TC_build'
				}
			}
		}

		/*cic computation*/
		if "`cic'"!="" {
						
			local ncateg=`ncateg'
			
			tempname mean_Y_11 maxY mean_D_0
			tempvar Q
							
			sum `Y' if `G'==1 & `T'==1, meanonly
			scalar `mean_Y_11'=r(mean)
			
			forvalues i=0(1)1 {
			
				tempname mean_D_1`i'
				sum `true_D' if `G'==1 & `T'==`i'
				scalar `mean_D_1`i''=r(mean)
			}
		
			gen `Q'=. 
			
			/*if treatment variable takes only one value in control group, 
			identify that value.*/
			if `is_special_case'==1 {	
	
				sum `D' if `G'==0, meanonly
				scalar `mean_D_0'=r(mean)		
			}
		
			forvalues i=1(1)`ncateg' {
				
				count if `D'==`i' & `G'==1 & `T'==0 
				
				if r(N)!=0 {
					
					tempvar is_in_`i'10 is_in_`i'00 is_in_`i'01 Q`i'
					gen `is_in_`i'10'=(`D'==`i' & `G'==1 & `T'==0)
					
					if `is_special_case'==0 {

						gen `is_in_`i'00'=(`D'==`i' & `G'==0 & `T'==0)
						gen `is_in_`i'01'=(`D'==`i' & `G'==0 & `T'==1)
					}
					else {
					
						gen `is_in_`i'00'=(`D'==`mean_D_0' & `G'==0 & `T'==0)
						gen `is_in_`i'01'=(`D'==`mean_D_0' & `G'==0 & `T'==1)										
					}
										
					mata:qq_transfo("`Y'","`is_in_`i'01'","`is_in_`i'00'","`is_in_`i'10'","`Q`i''")
					drop `is_in_`i'10' `is_in_`i'00' `is_in_`i'01'					

					/*Creating the variable whose mean is computed in the second
					term of the numerator of the Wald-CIC estimator*/
					replace `Q'=`Q`i'' if `Q`i''!=.
				}			
			}	
			
			/*compute Wald-CIC*/
			tempname w_cic cic_num
			sum `Q'
			scalar `w_cic'=(`mean_Y_11'-r(mean))/(`mean_D_11'-`mean_D_10')		
			scalar `cic_num'=`mean_Y_11'-r(mean)	
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
					
					if "`partial'"!="" {

						ereturn scalar TC_inf=`W_TC_inf'
						ereturn scalar TC_sup=`W_TC_sup'
					}
					else {

						ereturn scalar W_TC=`w_tc'
					}
				}
			}
		}
		
		if "`cic'"!="" {
	
			if "`numerator'"!="" {

				ereturn scalar CIC_num=`cic_num'
			}
			else {

				ereturn scalar W_CIC=`w_cic'
			}
		}	
	}
end




