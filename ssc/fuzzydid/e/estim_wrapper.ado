/*
estim_wrapper.ado performs the following operations:
1) It checks whether the user's data is in one of the special cases defined in 
Section 3.1 of the paper. To do so, it calls special_cases
2) It computes the Wald-DID, Wald-TC, Wald-CIC and LQTE point estimates 
requested by the user, running:
- late_estim_noX for the Wald-DID, Wald-TC, Wald-CIC without covariates ;
- late_estim_X for the Wald-DID and Wald-TC with covariates ;
- lqte_estim_noX for the LQTE.
*/

quietly capture program drop estim_wrapper
quietly program estim_wrapper, eclass

	version 12

	syntax varlist(min=4 numeric) ///
	[, true_D(name) tot_obs(name) ///
	DID TC CIC LQTE continuous(varlist num fv) ///
	qualitative(varlist num fv) NUMERATOR ///
	y_reg_method(name) d_reg_method(name) d_reg_method2(name) ///
	sieve_expansion_Y(varlist num) sieve_expansion_D(varlist num) ///
	inf_method(name) PARTIAL BOOT MOREOUTPUT]
		
	tokenize `varlist', parse(" ,")		 
	
	local varlist_count=wordcount("`varlist'")
	
	/*rename outcome, group, time and treatment*/
	if `varlist_count'==4 {
	
		args Y G T D
	}
	
	if `varlist_count'==5 {
	
		args Y Gb Gf T D
	}	
	
	preserve
		
	quietly {
		
		tempvar indic_t G_star indic_decrease indic_increase
		tempname W_DID W_TC W_CIC DID_num TC_num CIC_num TC_inf ///
		TC_sup scaling_did scaling_tc scaling_tc_inf scaling_tc_sup ///
		scaling_cic lqte_temp
		tab `D', nofreq
		local ncateg_d=r(r)
		tab `true_D', nofreq
		local ncateg_d_init=r(r)
		tab `T', nofreq
		local ncateg_t=r(r)
		
		if `varlist_count'==4 {
		
			count if `T'>=1 & `G'!=.
		}
		else {
		
			count if (`T'>=2 & `Gb'!=.) 
		}
		
		local `tot_obs'=r(N)
		
		scalar `W_DID'=0
		scalar `DID_num'=0
		scalar `W_TC'=0
		scalar `TC_inf'=0
		scalar `TC_sup'=0
		scalar `TC_num'=0
		scalar `W_CIC'=0
		scalar `CIC_num'=0
		scalar `scaling_did'=0			
		scalar `scaling_tc'=0
		scalar `scaling_tc_inf'=0
		scalar `scaling_tc_sup'=0
		scalar `scaling_cic'=0	
		matrix `lqte_temp'=J(19,1,.)
		local true_zero=0

		forvalues t=2(1)`ncateg_t' {
			
			local t_bis=`t'-1
						
			gen `indic_t'=(`T'==`t')
			replace `indic_t'=. if (`T'!=`t' & `T'!=`t'-1)
			
			if `varlist_count'==4 {
			
				gen `G_star'=`G' if `indic_t'!=.
			}
			else {
			
				gen `G_star'=`Gb' if `indic_t'==1
				replace `G_star'=`Gf' if `indic_t'==0
			}
						
			gen `indic_decrease'=(`G_star'==-1) 
			replace `indic_decrease'=. if (`G_star'!=-1 & `G_star'!=0)
			replace `indic_decrease'=-1 if `G_star'==1
			gen `indic_increase'=(`G_star'==1) 
			replace `indic_increase'=. if (`G_star'!=1 & `G_star'!=0)
			replace `indic_increase'=-1 if `G_star'==-1
			
			local G_star_list "`indic_decrease' `indic_increase'"				
			
			tempname p_t
			count if `indic_t'==1 & `G_star'!=.
			scalar `p_t'=r(N)/`tot_obs'
			count if `G_star'==0

			if r(N)!=0 {
				
				local special=0
				
				tab `D' if `G_star'==0, nofreq

				if r(r)==1 {
					
					local special=1
				}			
			
				foreach A of local G_star_list {			
					
					local error_part_sharp=0
					
					count if `A'==1
						
					if r(N)!=0 {					
								
						/*check if treatment support coincides in the different subgroups. 
						special_cases is another subprogram. */
						if `special'==0 & ///
						("`tc'"!="" | "`cic'"!="" | "`lqte'"!="") {
						
							tempname is_part_sharp
							
							special_cases `A' `indic_t' ///
							`D' if (`A'==1 | `A'==0), ///
							ncateg(`ncateg_d') is_part_sharp(`is_part_sharp')
	
							if `is_part_sharp'!=0 {
						
								local error_part_sharp=1
							}				
						}
						
						if `error_part_sharp'==0 | "`did'"!="" {
						
							local error_comp=0
						
							if "`continuous'"!="" | "`qualitative'"!="" {
															
								tempname mean_00 mean_01 mean_10 mean_11
								tempvar pred						
								
								if `error_part_sharp'==1 {
								
									capture late_estim_X `Y' `A' `indic_t' `D' if (`A'==1 | `A'==0), ///
									ncateg(`ncateg_d') true_D(`true_D') ///
									continuous(`continuous') qualitative(`qualitative') ///
									y_reg_method(`y_reg_method') d_reg_method(`d_reg_method') ///
									d_reg_method2(`d_reg_method2') `did' didd /// 
									inf_method(`inf_method') sieve_expansion_Y(`sieve_expansion_Y') ///
									sieve_expansion_D(`sieve_expansion_D') ///
									is_special_case(`special')	
								}
								else {
								
									capture late_estim_X `Y' `A' `indic_t' `D' if (`A'==1 | `A'==0), ///
									ncateg(`ncateg_d') true_D(`true_D') ///
									continuous(`continuous') qualitative(`qualitative') ///
									y_reg_method(`y_reg_method') d_reg_method(`d_reg_method') ///
									d_reg_method2(`d_reg_method2') `did' `tc' didd /// 
									inf_method(`inf_method') sieve_expansion_Y(`sieve_expansion_Y') ///
									sieve_expansion_D(`sieve_expansion_D') `numerator' ///
									is_special_case(`special')	
								}								

								if _rc!=0 {
								
									local error_comp=1
								}
							}
							else {
								
								if ("`did'"!="" | "`tc'"!="" | "`cic'"!="") {
									
									if `error_part_sharp'==1 {
									
										capture late_estim_noX `Y' `A' `indic_t' `D' ///
										if (`A'==1 | `A'==0), true_D(`true_D') ///
										ncateg(`ncateg_d') is_special_case(`special') ///  
										`did' didd
									}
									else {
										
										capture late_estim_noX `Y' `A' `indic_t' `D' ///
										if (`A'==1 | `A'==0), true_D(`true_D') ///
										ncateg(`ncateg_d') is_special_case(`special') ///  
										`did' `tc' `cic' didd `partial' `numerator'									
									}
																		
									if _rc!=0  {
									
										local error_comp=1
									}
								}
								
								if "`lqte'"!="" & `error_part_sharp'==0 {				
									
									capture lqte_estim_noX `Y' `A' `indic_t' `D', ///
									true_D(`true_D') is_special_case(`special')	

									if _rc!=0  {
									
										local error_comp=1
									}										
								}					
							} 
							
							if `error_comp'==0 {
							
								replace `A'=0 if `A'==-1
								sum `A' if `indic_t'==1
								local g_star_weight=r(mean)
								local update_scaling=e(DID_D)*`g_star_weight'*`p_t'
								
								if `update_scaling'!=. {
								
									if "`A'"=="`indic_decrease'" {
										
										local plus_or_minus "-"
									}
									else {
										
										local plus_or_minus "+"
									}
							
									if "`did'"!="" {
										
										if "`numerator'"!="" {
											
											if e(DID_num)!=. {
											
												scalar `DID_num'=`DID_num' ///
												`plus_or_minus' `update_scaling'*e(DID_num)
												scalar `scaling_did'= ///
												`scaling_did' `plus_or_minus' `update_scaling'
												
												if `DID_num'==0 {
												
													local true_zero=1
												}
											}
										}
										else {
											
											if e(W_DID)!=. {
											
												scalar `W_DID'=`W_DID' ///
												`plus_or_minus' `update_scaling'*e(W_DID)
												scalar `scaling_did'= ///
												`scaling_did' `plus_or_minus' `update_scaling'	
												
												if `W_DID'==0 {
												
													local true_zero=1												
												}		
											}
										}
									}
									
									if "`tc'"!="" & `error_part_sharp'==0 {
										
										if "`numerator'"!="" {
											
											if e(TC_num)!=. {
											
												scalar `TC_num'=`TC_num' ///
												`plus_or_minus' `update_scaling'*e(TC_num)
												scalar `scaling_tc'= ///
												`scaling_tc' `plus_or_minus' `update_scaling'	
												
												if `TC_num'==0 {
												
													local true_zero=1
												}																								
											}
										}
										else {
											
											if "`partial'"=="" {
												
												if e(W_TC)!=. {
												
													scalar `W_TC'=`W_TC' ///
													`plus_or_minus' `update_scaling'*e(W_TC)
													scalar `scaling_tc'= ///
													`scaling_tc' `plus_or_minus' `update_scaling'
													
													if `W_TC'==0 {
												
														local true_zero=1
													}													
												}
											}
											else {
												
												if e(TC_inf)!=. {
												
													scalar `TC_inf'=`TC_inf' ///
													`plus_or_minus' `update_scaling'*e(TC_inf)
													scalar `scaling_tc_inf'= ///
													`scaling_tc_inf' `plus_or_minus' `update_scaling'
													
													if `TC_inf'==0 {
												
														local true_zero=1
													}																										
												}
												
												if e(TC_sup)!=. {
												
													scalar `TC_sup'=`TC_sup' ///
													`plus_or_minus' `update_scaling'*e(TC_sup)
													scalar `scaling_tc_sup'= ///
													`scaling_tc_sup' `plus_or_minus' `update_scaling'	
													
													if `TC_sup'==0 {
												
														local true_zero=1
													}													
												}
											}
										}											
									}
									
									if "`cic'"!="" & `error_part_sharp'==0 {
										
										if "`numerator'"!="" {
											
											if e(CIC_num)!=. {
											
												scalar `CIC_num'=`CIC_num' ///
												`plus_or_minus' `update_scaling'*e(CIC_num)
												scalar `scaling_cic'= ///
												`scaling_cic' `plus_or_minus' `update_scaling'	
												
												if `CIC_num'==0 {
											
													local true_zero=1
												}												
											}
										}
										else {
											
											if e(W_CIC)!=. {
											
												scalar `W_CIC'=`W_CIC' ///
												`plus_or_minus' `update_scaling'*e(W_CIC)
												scalar `scaling_cic'= ///
												`scaling_cic' `plus_or_minus' `update_scaling'		
												
												if `W_CIC'==0 {
											
													local true_zero=1
												}													
											}
										}												
									}														
								}
								
								/*LQTE option can only be used with two groups and periods => no need
								to compute weighted average of estimators across groups and periods*/
								if "`lqte'"!="" & `error_part_sharp'==0 {
											
									matrix `lqte_temp'=e(LQTE)
								}								
							}		
						}
					}
					
					*drop `A'
				}				
			}
	
			drop `G_star' `indic_t' `indic_decrease' `indic_increase'
		}
		
		ereturn clear			
		
		tempname degenerate_correction
		scalar `degenerate_correction'=runiform()
		scalar `degenerate_correction'= ///
		-1000000000000000*(`degenerate_correction'<0.5) ///
		+1000000000000000*(`degenerate_correction'>=0.5)
		
		if "`did'"!="" {
		
			if "`numerator'"!="" {
		
				if `DID_num'==0 & `true_zero'==0 {
				
					scalar `DID_num'=`degenerate_correction'
				}
				else {
				
					scalar `DID_num'=`DID_num'/`scaling_did'
				}
			}
			else {
					
				if `W_DID'==0 & `true_zero'==0 {
				
					scalar `W_DID'=`degenerate_correction'
				}
				else {
				
					scalar `W_DID'=`W_DID'/`scaling_did'				
				}
			}
		}
		
		if "`tc'"!="" {
		
			if "`numerator'"!="" {
			
				if `TC_num'==0 & `true_zero'==0 {
				
					scalar `TC_num'=`degenerate_correction'
				}
				else {
				
					scalar `TC_num'=`TC_num'/`scaling_tc'
				}
			}
			else {
				
				if "`partial'"!="" {
				
					if `TC_inf'==0 & `true_zero'==0 {
					
						scalar `TC_inf'=`degenerate_correction'
					}
					else {
					
						scalar `TC_inf'=`TC_inf'/`scaling_tc_inf'
					}
					
					if `TC_sup'==0 & `true_zero'==0 {
					
						scalar `TC_sup'=`degenerate_correction'
					}
					else {
					
						scalar `TC_sup'=`TC_sup'/`scaling_tc_sup'
					}					
				}
				else {
				
					if `W_TC'==0 & `true_zero'==0 {
					
						scalar `W_TC'=`degenerate_correction'
					}
					else {
					
						scalar `W_TC'=`W_TC'/`scaling_tc'
					}
				}
			}
		}
		
		if "`cic'"!="" {
		
			if "`numerator'"!="" {
		
				if `CIC_num'==0 & `true_zero'==0 {
				
					scalar `CIC_num'=`degenerate_correction'
				}
				else {
				
					scalar `CIC_num'=`CIC_num'/`scaling_cic'
				}
			}
			else {
							
				if `W_CIC'==0 & `true_zero'==0 {
				
					scalar `W_CIC'=`degenerate_correction'
				}
				else {
				
					scalar `W_CIC'=`W_CIC'/`scaling_cic'
				}
			}
		}	
		
		if "`lqte'"!="" {
						
			forvalues q=1(1)19 {
			
				if `lqte_temp'[`q',1]==. {
					display `degenerate_correction'
					matrix `lqte_temp'[`q',1]=`degenerate_correction'
				}
			}
		}
		
		if "`boot'"=="" {
		
			if "`did'"!="" {
				
				if "`numerator'"!="" {
				
					ereturn scalar DID_num=`DID_num'
				}
				else {
						
					ereturn scalar W_DID=`W_DID'	
				}
			}
			
			if "`tc'"!="" {
				
				if "`numerator'"!="" {
					
					ereturn scalar TC_num=`TC_num'
				}	
				else {
				
					if "`partial'"!="" {
					
						ereturn scalar TC_inf=`TC_inf'
						ereturn scalar TC_sup=`TC_sup'
					}
					else {
							
						ereturn scalar W_TC=`W_TC'					
					}
				}
			}
			
			if "`cic'"!="" {
			
				if "`numerator'"!="" {
				
					ereturn scalar CIC_num=`CIC_num'
				}	
				else {
					
					ereturn scalar W_CIC=`W_CIC'
				}
			}			
			
			if "`lqte'"!="" {
				
				ereturn matrix LQTE=`lqte_temp'
			}
		}
		else {
			
			tempname results_mat
			local done=0
			
			if "`did'"!="" {
				
				if "`numerator'"!="" {
				
					matrix `results_mat'=`DID_num'
					local done=1
				}
				else {
	
					matrix `results_mat'=`W_DID'	
					local done=1
				}
			}
			
			if "`tc'"!="" {
				
				if "`numerator'"!="" {
					
					if `done'==0 {
					
						matrix `results_mat'=`TC_num'
						local done=1
					}
					else {
					
						matrix `results_mat'=`results_mat' \ `TC_num'
					}
				}	
				else {
				
					if "`partial'"!="" {
						
						if `done'==0 {
						
							matrix `results_mat'= ///
							`TC_inf' \ `TC_sup'
							local done=1
						}
						else {
						
							matrix `results_mat'=`results_mat' \ ///
							`TC_inf' \ `TC_sup'	
						}
					}
					else {
						
						if `done'==0 {
						
							matrix `results_mat'=`W_TC'
							local done=1
						}
						else {
						
							matrix `results_mat'=`results_mat' \ `W_TC'	
						}
					}
				}
			}
			
			if "`cic'"!="" {

				if "`numerator'"!="" {
					
					if `done'==0 {
					
						matrix `results_mat'=`CIC_num'
						local done=1
					}
					else {
					
						matrix `results_mat'=`results_mat' \ `CIC_num'
					}
				}
				else {
					
					if `done'==0 {
					
						matrix `results_mat'=`W_CIC'
						local done=1
					}
					else {
					
						matrix `results_mat'=`results_mat' \ `W_CIC'
					}
				}
			}
			
			if "`moreoutput'"!="" {
			
				if "`did'"!="" & "`tc'"!="" {
				
					matrix `results_mat'=`results_mat' \ (`W_DID'-`W_TC')				
				}
				
				if "`did'"!="" & "`cic'"!="" {
				
					matrix `results_mat'=`results_mat' \ (`W_DID'-`W_CIC') 
				}
				
				if "`tc'"!="" & "`cic'"!="" {

					matrix `results_mat'=`results_mat' \ (`W_TC'-`W_CIC')			
				}
			}
				
			if "`lqte'"!="" {
			
				if `done'==0 {
				
					matrix `results_mat'=`lqte_temp'
				}
				else {
				
					matrix `results_mat'=`results_mat' \ `lqte_temp'
				}				
			}
						
			matrix `results_mat'=`results_mat''
			ereturn post `results_mat'
			ereturn local cmd="bootstrap"	
		}
	}
end
