*! autosum version 0.1.3 22 July 2018
//changelog changed matrix names to accommodate longer var names
//provide check if subgroups have no observations
//added total obs (N) for comparison table

program autosum
	version 14.2
	global asum_groupvar // grouping variable
	global asum_format //group format 
	global asum_varlist // variables to be summed
	global asum_manual// manual option
	global asum_catvar //categorical variables
	global asum_contvar //continuous variables
	global asum_nonparavar //continuous variables in nonparametric distribution
	global asum_paravar //continuous variables in parametric distribution
	global asum_resmat //result matrices
	global asum_caption//table caption
	
	syntax [varlist(default=none)] [if] [in] [, *]
	groupformat `0'
	display_table 
	export_table `0'
	erase_data
end
	
//Detect group format setup and exclude variables

program groupformat
	syntax [varlist(default=none)] [if] [in] [, GRouping(varname) CONTinuous(varlist) CATegorical(varlist) EXclude(varlist) PAired CUToff(integer 7) SFrancia *]
	unab wholelist: _all
		local num: word count `varlist'	
		if `num'==0 {
		global asum_groupvar `grouping'
		global asum_varlist: list continuous | categorical
		global asum_catvar `categorical'
		global asum_contvar `continuous'
		global asum_manual "manual"
			if "$asum_groupvar" == "" & "$asum_varlist" == "" {
			di as error "please input variables manually to start analysis"
			exit(198)
			}
			if "$asum_groupvar" != "" {
			global asum_format = 1
			varformat $asum_groupvar
				if "`r(format)'" == "real" {
				di as error "group variable does not appear to be in a valid format"
				exit(198)
				}
			quietly levelsof $asum_groupvar,  local(catvar)
			local num4: word count `catvar'
			if `num4' ==1 {
			di as error "there must be more than one category in the group variable"
			exit(198)
			}
			}
			if "$asum_groupvar" != "" & "$asum_varlist" == "" {
			local newlist1: list wholelist - asum_groupvar
			local newlist2: list newlist1 - exclude
				if "`exclude'" != "" {
				global asum_varlist "`newlist2'"
				}
				else {
				global asum_varlist "`newlist1'"
				}
			global asum_manual
			}
			else if "$asum_groupvar" == "" {
			local num2: word count $asum_varlist
				if `num2' <2 {
				di as error "include at least two variables for parallel group comparison"
				exit(198)
				}
			if "$asum_catvar" != "" & "$asum_contvar" != "" {
			di as error "cannot have both continuous and categorical data for parallel group comparison"
			exit(198)
			}
			if "`paired'" == "paired" {
			global asum_format = 3
			}
			else {
			global asum_format = 2
			}
			}
		}
		if `num'>1 quietly{
			if "`paired'" == "paired" {
			global asum_varlist `varlist'
			global asum_format = 3
			}
			else {
			global asum_varlist `varlist'
			global asum_format = 2
			}
		}
		else if `num' ==1 quietly{
			if "`paired'" == "paired" {
			di as error "paired format is only supported in wide parallel group format"
			exit(198)
		}
			global asum_groupvar `varlist'
			global asum_format = 1
			varformat $asum_groupvar
			if "`r(format)'" == "real" {
			di as error "group variable does not appear to be in a valid format"
			exit(198)
		}
		quietly levelsof $asum_groupvar,  local(catvar)
		local num4: word count `catvar'
			if `num4' ==1 {
			di as error "there must be more than one category in the group variable"
			exit(198)
			}
		local newlist1: list wholelist - varlist
		local newlist2: list newlist1 - exclude
			if "`exclude'" != "" {
			global asum_varlist "`newlist2'"
			}
			else {
			global asum_varlist "`newlist1'"
			}
		}

//Allocation to category-specific programs
	foreach varcheck in $asum_varlist {
		capture assert missing(`varcheck')
		if _rc == 0 {
		di as error "`varcheck' contains only missing values - exclude this variable using exclude option"
		exit(198)
		}
	}

	marksample touse, novarlist
	if $asum_format == 1 {
		quietly levelsof $asum_groupvar, local(num4)
		local num5: word count `num4'	
		foreach v in $asum_varlist {
			quietly tab `v' $asum_groupvar if `touse'
				if r(c) < `num5' {
				di "one or more of the group categories in `v' has no observations and is therefore dropped."
				local newlist3 $asum_varlist
				local newlist4: list newlist3 - v
				global asum_varlist "`newlist4'"
				}
	
		}
	}
		
	if "$asum_manual" != "manual" {
	foreach v in $asum_varlist {
		capture levelsof `v', local(num2)
		local num3: word count `num2'
		varformat `v'
			if "`r(format)'" == "real" {
			normtest `v', `sfrancia'
				if `r(p)' <0.05 {
				global asum_nonparavar $asum_nonparavar `v'
				}
				else {
				global asum_paravar $asum_paravar `v'
				}
			}
			else if "`r(format)'" == "str" {
			global asum_catvar $asum_catvar `v'
			}
			else if "`r(format)'" == "int" & `num3'>`cutoff' {
			normtest `v', `sfrancia'
				if `r(p)' <0.05 {
				global asum_nonparavar $asum_nonparavar `v'
				}
				else {
				global asum_paravar $asum_paravar `v'
				}
			}
			else if "`r(format)'" == "int" & `num3'<`cutoff' {
			global asum_catvar $asum_catvar `v'
			}
	}
	}
	else if "$asum_manual" == "manual" {
		foreach w in $asum_contvar {
			normtest `w', `sfrancia'
				if `r(p)' <0.05 {
				global asum_nonparavar $asum_nonparavar `w'
				}
				else {
				global asum_paravar $asum_paravar `w'
				}		
		}	
	}
	if $asum_format ==2 | $asum_format ==3 {
		if "$asum_catvar" != "" {
			if "$asum_paravar" != "" |  "$asum_nonparavar" != "" {
		di as error "the group variables appear to be in different formats - both categorical and continuous"
		exit(198)
			}
		}
	}
	sum_catvar `0'
	sum_paravar `0'
	sum_nonparavar `0'
	sum_paired `0'
	
end

//Check format of variable
program varformat, rclass
	quietly compress
	capture confirm string variable `1'
	if _rc ==0 {
	return local format "str"
	}
	else {
		foreach i in byte int long {
			capture confirm `i' variable `1'
			local _rc`i' = _rc
			}
			if `_rcbyte' ==0 |`_rcint' ==0 | `_rclong' ==0 {
			return local format "int"
			}
		foreach i in float double {
			capture confirm `i' variable `1'
			local _rc`i' = _rc
			}
			if `_rcfloat' ==0 |`_rcdouble' ==0 {
			return local format "real"
			}
	}
	end

//Performs normality test
program normtest, rclass
	syntax varname [, sfrancia]
	if "`sfrancia'" == "" quietly {
	swilk `1'
	return local p = r(p)
	}
	else quietly{
	sfrancia `1'
	return local p = r(p)
	}
end	

//Summarise categorical variables
program sum_catvar
	syntax [varlist] [if] [in] [, *]
	marksample touse, novarlist
	if "$asum_catvar" != ""	{
	di _newline
	di "The following variables are detected as being categorical: "
	di "$asum_catvar"
	di _newline
		if $asum_format == 1  {
		di "Below are the frequency tables for each variable:"
		foreach v in $asum_catvar {
			tab `v' if `touse'
			di _newline
			quietly tab `v' $asum_groupvar if `touse', matcell(asum_A1) 
			mata: st_matrix("B1", rowsum(st_matrix("asum_A1")))
			mata: st_matrix("B2", colsum(st_matrix("asum_A1")))
			mata: st_matrix("B3", colsum(st_matrix("B1")))
			scalar mat_total = B3[1,1]
			mata: st_matrix("B4",min(st_matrix("B1")))
			mata: st_matrix("B5",min(st_matrix("B2")))
			scalar min_column = B4[1,1]
			scalar min_row = B5[1,1]
			scalar min_expected = min_column*min_row /mat_total
			local matrix_row = rowsof(asum_A1)
			local matrix_col= colsof(asum_A1)
			mat A =  J(`matrix_row',`matrix_col'+3,.z)
			quietly levelsof `v' if !missing($asum_groupvar) & `touse', local(R1) 
				foreach x in `R1' {
				local R2 = strtoname(`"`x'"')
				local R3 `R3' `R2'
				mat rownames A = `v':`R3'
				}
			quietly levelsof $asum_groupvar if !missing(`v') & `touse', local(R4) 
				foreach y in `R4' {
				local R5 = strtoname(`"`y'"')
				local R6 `R6' `R5'
				mat colnames A = $asum_groupvar:`R6' "Obs_N" "p_value" "test"
				}
			local R3
			local R6
			if min_expected <5 {
			quietly tab `v' $asum_groupvar if `touse', exact matcell(asum_A1)
				forvalues i =1/`matrix_row' {
					forvalues j=1/`matrix_col' {
						mat A[`i',`j']=  asum_A1[`i',`j']
						mat A[1,`matrix_col'+1]=  r(N)
						mat A[1,`matrix_col'+2]= r(p_exact)
						mat A[1,`matrix_col'+3]= 1
						}
					}
				}
			else {
			quietly tab `v' $asum_groupvar if `touse', chi2 matcell(asum_A1) 
				forvalues i =1/`matrix_row' {
					forvalues j=1/`matrix_col' {
						mat A[`i',`j'] =  asum_A1[`i',`j']
						mat A[1,`matrix_col'+1]=  r(N)
						mat A[1,`matrix_col'+2]= r(p)
						mat A[1,`matrix_col'+3]= 2
						}
					}
				}

			mat r_`v' = A
			global asum_resmat $asum_resmat "r_`v'"
		}
		}
			
		
		else if $asum_format == 2 | $asum_format ==3 {
			foreach v in $asum_catvar {
			tab `v' if `touse'
			}
		local num2: word count $asum_catvar
		local j 1
		local i 1
		while `j' < `num2' {
			while `i' < `num2' {
				local x`i': word `i' of $asum_catvar
				local i = `i'+1
				local x`i': word `i' of $asum_catvar
				quietly tab `x`j'' `x`i'' if `touse', matcell(asum_A1) 
				di _newline
				mata: st_matrix("B1", rowsum(st_matrix("asum_A1")))
				mata: st_matrix("B2", colsum(st_matrix("asum_A1")))
				mata: st_matrix("B3", colsum(st_matrix("B1")))
				scalar mat_total = B3[1,1]
				mata: st_matrix("B4",min(st_matrix("B1")))
				mata: st_matrix("B5",min(st_matrix("B2")))
				scalar min_column = B4[1,1]
				scalar min_row = B5[1,1]
				scalar min_expected = min_column*min_row /mat_total
				local matrix_row = rowsof(asum_A1)
				local matrix_col= colsof(asum_A1)
				mat A =  J(`matrix_row',`matrix_col'+3,.z)
				
				quietly levelsof `x`j'' if !missing(`x`i'') & `touse', local(R1)
					foreach x in `R1' {
					local R2 = strtoname(`"`x'"')
					local R3 `R3' `R2'
					mat rownames A = `x`j'':`R3'
					}
				quietly levelsof `x`i'' if !missing(`x`j'') & `touse', local(R4)
					foreach y in `R4' {
					local R5 = strtoname(`"`y'"')
					local R6 `R6' `R5'
					mat colnames A = `x`i'':`R6' "Obs_N" "p_value" "test"
					}
				local R3
				local R6			
				if $asum_format ==2 {
				
				if min_expected <5 {
				quietly tab `x`j'' `x`i'' if `touse', exact matcell(asum_A1)
						forvalues i2 =1/`matrix_row' {
							forvalues j2=1/`matrix_col' {
								mat A[`i2',`j2'] =  asum_A1[`i2',`j2']
								mat A[1,`matrix_col'+1]=  r(N)
								mat A[1,`matrix_col'+2]= r(p_exact)
								mat A[1,`matrix_col'+3]= 1
								}
							}
						}
					else {
					quietly tab `x`j'' `x`i'' if `touse', chi2 matcell(asum_A1) 
						forvalues i2 =1/`matrix_row' {
							forvalues j2=1/`matrix_col' {
								mat A[`i2',`j2'] =  asum_A1[`i2',`j2']
								mat A[1,`matrix_col'+1]=  r(N)
								mat A[1,`matrix_col'+2]= r(p)
								mat A[1,`matrix_col'+3]= 2
								}
							}
						}
					mat results_`x`j''_by_`x`i'' = A 
					global asum_resmat $asum_resmat "results_`x`j''_by_`x`i''"
				}
				}
			local j = `j'+1
			local i = `j'
		}
		}
	}	
end

//Summarise parametric variables
program sum_paravar
	syntax [varlist] [if] [in] [, *]
	marksample touse, novarlist
	if "$asum_paravar" != ""	{
	di _newline
	di "*********************************************************************"
	di _newline
	di "The following variables are detected as being continuous (parametric distribution): "
	di "$asum_paravar"
	di _newline
	di "Below are the summary characteristics for each variable:"
		tabstat $asum_paravar if `touse', s(n min max range mean sd variance ) columns(statistics)
		if $asum_format == 1  {
			foreach v in $asum_paravar {
			quietly levelsof $asum_groupvar if `touse', local(num4)
			local num5: word count `num4'	
			mat C1 = J(2,`num5'+3,.z)
			mat rownames C1 = `v':(mean) (sd) 
				
			quietly levelsof $asum_groupvar if `touse', local(R4)
				foreach y in `R4' {
				local R5 = strtoname(`"`y'"')
				local R6 `R6' `R5'
				mat colnames C1 = $asum_groupvar:`R6' "Obs_N" "p_value" "test"
				}
			local R6
					
				if `num5'==2 {
						local x: word 1 of `num4'
						quietly sum `v' if $asum_groupvar== `x' & `touse'
						mat C1[1,1]= r(mean)
						mat C1[2,1]= r(sd)
						local x: word 2 of `num4'
						quietly sum `v' if $asum_groupvar == `x' & `touse'
						mat C1[1,2]= r(mean)
						mat C1[2,2]= r(sd)	
						quietly sdtest `v' if `touse', by($asum_groupvar)
						if r(p) <0.05 {
						quietly ttest `v' if `touse', by($asum_groupvar) unequal
						}
						else {
						quietly ttest `v' if `touse', by($asum_groupvar)
						}
						mat C1[1,3] = r(N_1) + r(N_2)
						mat C1[1,4] = r(p)	
						mat C1[1,5] = 3
					mat r_`v' = C1
					global asum_resmat $asum_resmat "r_`v'"
				}
				else if `num5'>2 {
					forvalues z = 1/`num5' {
						local y: word `z' of `num4'
						quietly sum `v' if $asum_groupvar ==`y' & `touse'
						mat C1[1,`z'] = r(mean)
						mat C1[2,`z'] = r(sd)
					}
					quietly oneway `v' $asum_groupvar if `touse'
					mat C1[1,`num5'+1] = r(N)
					local p = Ftail(r(df_m), r(df_r), r(F))
					mat C1[1,`num5'+2] = `p'
					mat C1[1,`num5'+3] = 4
					mat r_`v' = C1
					global asum_resmat $asum_resmat "r_`v' "
				}
			}
		}
		else if $asum_format ==2 {
			if "$asum_nonparavar" == ""	{
			
			local num5: word count $asum_varlist
				if `num5'==2 {
					mat C1 = J(3,`num5'+3,.z)
					local x: word 1 of $asum_varlist
					local y: word 2 of $asum_varlist
					quietly sum `x' if `touse'
					mat C1[1,1] = r(N)
					mat C1[2,1]= r(mean)
					mat C1[3,1]= r(sd)
					quietly sum `y' if `touse'
					mat C1[1,2] = r(N)
					mat C1[2,2]= r(mean)
					mat C1[3,2]= r(sd)	
					quietly sdtest `x' ==`y' if `touse'
					if r(p) <0.05 {
					quietly ttest `x' ==`y' if `touse', unpaired unequal
					}
					else {
					quietly ttest `x' ==`y' if `touse', unpaired
					}
					mat C1[1,4] = r(p)
					mat C1[1,5] = 3
					mat colnames C1 = `x' `y' "_" "p_value"
					mat rownames C1 = n (mean) (sd) 
					mat results_`x'_by_`y' = C1
					global asum_resmat $asum_resmat "results_`x'_by_`y'"
				}
				else if `num5'>2 {
					mat C2 = J(3,(`num5'+2),.z)
					local w = 1
					forvalues z = 1/`num5' {
						local y: word `z' of $asum_varlist
						quietly sum `y' if `touse' 
						mat C2[1,`z'] = r(N)
						mat C2[2,`z'] = r(mean)
						mat C2[3,`z'] = r(sd)
						local rowvar `rowvar' `y'
						mat colnames C2 = `rowvar' "_" "p_value"
						mat rownames C2 = n (mean) (sd) 
					}
					preserve
					quietly stack $asum_varlist if `touse', into(_stackvar) clear
					quietly oneway _stackvar  _stack
					local p = Ftail(r(df_m), r(df_r), r(F))
					mat C2 [1,(`num5'+2)] = `p'
					mat C2 [1,(`num5'+3)] = 4
					mat results_`y'_by_3 = C2
					global asum_resmat $asum_resmat "results_`y'_by_3"
					
				}
		}
		}
	}
end

//	Summarise non-parametric variables
program sum_nonparavar
	syntax [varlist] [if] [in] [, *]
	marksample touse, novarlist
	if "$asum_nonparavar" != ""	{
	di _newline
	di "*********************************************************************"
	di _newline
	di "The following variables are detected as being continuous (non-parametric distribution): "
	di "$asum_nonparavar"
	di _newline
	di "Below are the summary characteristics for each variable:"
	tabstat $asum_nonparavar if `touse', s(n min max range median p25 p75 iqr ) columns(statistics)
		if $asum_format == 1  {
			foreach v in $asum_nonparavar {
				quietly levelsof $asum_groupvar if `touse', local(num4)
				local num5: word count `num4'
				
				mat D1 = J(4,`num5'+3,.z)
				mat rownames D1 = `v':"(median)" "(1st_quart)" "(3rd_quart)" "(IQR)" 
					
				quietly levelsof $asum_groupvar if `touse', local(R4)
					foreach y in `R4' {
					local R5 = strtoname(`"`y'"')
					local R6 `R6' `R5'
					mat colnames D1 = $asum_groupvar:`R6' "Obs_N" "p_value" "test"
					}
				local R6
			
					if `num5'==2 {
					local x: word 1 of `num4'
					quietly sum `v' if $asum_groupvar == `x' & `touse', detail
					mat D1[1,1]= r(p50)
					mat D1[2,1]= r(p25)
					mat D1[3,1]= r(p75)
					mat D1[4,1] =r(p75)-r(p25)
					local x: word 2 of `num4'
					quietly sum `v' if $asum_groupvar == `x' & `touse', detail
					mat D1[1,2]= r(p50)
					mat D1[2,2]= r(p25)
					mat D1[3,2]= r(p75)
					mat D1[4,2]= r(p75)-r(p25)
					quietly ranksum `v' if `touse', by($asum_groupvar)
					mat D1[1,3]= r(N_1) + r(N_2)
					mat D1[1,4] = 2 * normprob(-abs(r(z)))	
					mat D1[1,5] = 5	
					mat r_`v' = D1
					global asum_resmat $asum_resmat "r_`v'"
					}
					else if `num5'>2 {
					forvalues z = 1/`num5' {
						local y: word `z' of `num4'
						quietly sum `v' if $asum_groupvar ==`y' & `touse', detail
						mat D1[1,`z'] = r(p50)
						mat D1[2,`z'] = r(p25)
						mat D1[3,`z'] = r(p75)
						mat D1[4,`z'] = r(p75)-r(p25)
					}
					quietly sum `v' if !missing($asum_groupvar) & `touse'
					mat D1[1,`num5'+1] = r(N)
					quietly kwallis `v' if `touse', by($asum_groupvar)
					local p = chi2tail(r(df), r(chi2))
					mat D1[1,`num5'+2] = `p'
					mat D1[1,`num5'+3] = 6
					mat r_`v' = D1
					global asum_resmat $asum_resmat "r_`v'" 
				}
			}
		}
		else if $asum_format ==2 {
			local num5: word count $asum_varlist
				mat E1 = J(5,`num5'+3,.z)
				mat rownames E1 = "n" "(median)" "(1st_quart)" "(3rd_quart)" "(IQR)" 
				if `num5'==2 {
					local x: word 1 of $asum_varlist
					local y: word 2 of $asum_varlist
					quietly sum `x' if `touse', detail
					mat E1[1,1]= r(N)
					mat E1[2,1]= r(p50)
					mat E1[3,1]= r(p25)
					mat E1[4,1]= r(p75)
					mat E1[5,1] =r(p75)-r(p25)
					quietly sum `y' if `touse', detail
					mat E1[1,2]= r(N)
					mat E1[2,2]= r(p50)
					mat E1[3,2]= r(p25)
					mat E1[4,2]= r(p75)
					mat E1[5,2]= r(p75)-r(p25)
					preserve
					quietly stack $asum_varlist if `touse', into(_stackvar) clear
					quietly ranksum _stackvar, by(_stack)
					mat E1[1,4] = 2 * normprob(-abs(r(z)))	
					mat E1[1,5] = 5
					mat colnames E1 = `x' `y' "_" "p_value" "test"
					mat results_`x'_by_`y' = E1
					global asum_resmat $asum_resmat "results_`x'_by_`y'"
					restore
				}
				else if `num5'>2 {
					forvalues z = 1/`num5' {
						local y: word `z' of $asum_varlist
						quietly sum `y' if `touse', detail
						mat E1[1,`z'] = r(N)
						mat E1[2,`z'] = r(p50)
						mat E1[3,`z'] = r(p25)
						mat E1[4,`z'] = r(p75)
						mat E1[5,`z'] = r(p75)-r(p25)
						local rowvar `rowvar' `y'
						mat colnames E1 = `rowvar' "_" "p_value" "test"	
					}
					preserve
					quietly stack $asum_varlist if `touse', into(_stackvar) clear
					quietly kwallis _stackvar, by(_stack)
					local p = chi2tail(r(df), r(chi2))
					mat E1 [1,`num5'+2] = `p'
					mat E1 [1,`num5'+3] = 6
					mat results_`y'_by_3 = E1
					global asum_resmat $asum_resmat "results_`y'_by_3"
					restore
				}
		}
	}
end

program sum_paired
	syntax [varlist] [if] [in] [, *]
	marksample touse, novarlist
	if $asum_format == 3 {	
	if "$asum_catvar" != ""	{
		local num5: word count $asum_varlist
			if `num5'==2 {
			local x: word 1 of $asum_varlist
			local y: word 2 of $asum_varlist	
			quietly tab `x' `y' if `touse', matcell(asum_A1) 
			local matrix_row = rowsof(asum_A1)
			local matrix_col= colsof(asum_A1)
			mat A =  J(`matrix_row',`matrix_col'+3,.z)
				forvalues i2 =1/`matrix_row' {
					forvalues j2=1/`matrix_col' {
						mat A[`i2',`j2'] =  asum_A1[`i2',`j2']
						mat A[1,`matrix_col'+1]=  r(N)
						}
					}
				quietly levelsof `x' if !missing(`y') & `touse', local(R1)
					foreach m in `R1' {
					local R2 = strtoname(`"`m'"')
					local R3 `R3' `R2'
					mat rownames A = `x':`R3'
					}
				quietly levelsof `y' if !missing(`x') & `touse', local(R4)
					foreach n in `R4' {
					local R5 = strtoname(`"`n'"')
					local R6 `R6' `R5'
					mat colnames A = `y':`R6' "Obs_N" "p_value" "test"
					}
				local R3
				local R6	

			quietly symmetry `x' `y' if `touse'
			mat A[1,`matrix_col'+2]=  r(p_sm)
			mat A[1,`matrix_col'+3]=  7
			mat results_`x'_by_`y' = A 
			global asum_resmat $asum_resmat "results_`x'_by_`y'"
		}
		else if `num5'>2 {
				capture cochran $asum_varlist if `touse'
				if _rc!=0 {
				di _newline
				di as error "More than 2 categorical variables for paired data comparison"
				di as error `"Cochran Q test not installed - suggest to install  consider installing the cochran package by Ben Jann - type "y" to install"' _request(response1)
					if "$response1" == "y" | "$response1" == "Y" {
					net install cochran.pkg
					quietly cochran $asum_varlist if `touse'
					}
					else {
					exit(198)
					}
				}
				local p =r(p)
				di "Cochran's Q test for equality of proportions - p value is " %04.3f `p'
				exit(198)
		}
	}
	if "$asum_paravar" != ""	{
		if "$asum_nonparavar" == ""	{
				local num5: word count $asum_varlist
					mat F1 = J(3,`num5'+3,.z)
					mat rownames F1 = n (mean) (sd)
					if `num5'==2 {
					local x: word 1 of $asum_varlist
					local y: word 2 of $asum_varlist		
					quietly ttest `x' = `y' if `touse'
					mat F1[1,1]= r(N_1)
					mat F1[2,1]= r(mu_1)
					mat F1[3,1]= r(sd_1)
					mat F1[1,2]= r(N_2)
					mat F1[2,2]= r(mu_2)
					mat F1[3,2]= r(sd_2)	
					mat F1[1,4]= r(p)
					mat F1[1,5]= 8
 					mat colnames F1 = `x' `y' "_" "p_value" "test"
					mat results_`x'_by_`y' = F1
					global asum_resmat $asum_resmat "results_`x'_by_`y'"
					}
					if `num5'>2 {
					forvalues z = 1/`num5' {
						local y: word `z' of $asum_varlist
						quietly sum `y' if `touse'
						mat F1[1,`z'] = r(N)
						mat F1[2,`z'] = r(mean)
						mat F1[3,`z'] = r(sd)
						local rowvar `rowvar' `y'
						mat colnames F1 = `rowvar' "_" "p_value" "test"	
					}
					preserve
					stack $asum_varlist if `touse', into(_stackvar) clear
					bysort _stack: gen _stacknew = _n
					quietly anova _stackvar _stacknew _stack, repeated(_stack)
					local p = Ftail(e(df_m), e(df_r), e(F_2))
					mat F1[1,`num5'+2] = `p'
					mat F1[1,`num5'+3] = 9
					mat results_`y'_by_3 =  F1
					global asum_resmat $asum_resmat "results_`y'_by_3" 
					restore
					}
				}	
		}
	if "$asum_nonparavar" != ""	{
		local num5: word count $asum_varlist
			mat E1 = J(5,`num5'+3,.z)
			mat rownames E1 = "n" "(median)" "(1st_quart)" "(3rd_quart)" "(IQR)" 
				if `num5'==2 {
					local x: word 1 of $asum_varlist
					local y: word 2 of $asum_varlist
					quietly sum `x' if `touse', detail
					mat E1[1,1]= r(N)
					mat E1[2,1]= r(p50)
					mat E1[3,1]= r(p25)
					mat E1[4,1]= r(p75)
					mat E1[5,1] =r(p75)-r(p25)
					quietly sum `y' if `touse', detail
					mat E1[1,2]= r(N)
					mat E1[2,2]= r(p50)
					mat E1[3,2]= r(p25)
					mat E1[4,2]= r(p75)
					mat E1[5,2]= r(p75)-r(p25)
					quietly signrank `x' = `y' if `touse'
					mat E1[1,4] = 2 * normprob(-abs(r(z)))	
					mat E1[1,5] = 10
					mat colnames E1 = `x' `y' "_" "p_value" "test"
					mat results_`x'_by_`y' = E1
					global asum_resmat $asum_resmat "results_`x'_by_`y'"
				}
				if `num5'>2 {
				capture friedman $asum_varlist if `touse'
				mat E1[1,`num5'+2]=r(p)
				mat E1[1,`num5'+3]=11
				if _rc!=0 {
				di _newline
				di as error "More than 2 continuous variables in non-parametric distributions detected"
				di as error `"Friedman test not installed - suggest to install the snp2_1 package by Richard Goldstein - type "y" to install (consider using Skillings-Mack test if there is missing data)"' _request(response)
					if "$response" == "y" | "$response" == "Y" {
					net install snp2_1.pkg
					quietly friedman $asum_varlist if `touse'
					mat E1[1,`num5'+2]=r(p)
					mat E1[1,`num5'+3]=11
					}
					else {
					exit(198)
					}
				}
					forvalues z = 1/`num5' {
						local y: word `z' of $asum_varlist
						quietly sum `y' if `touse', detail
						mat E1[1,`z'] = r(N)
						mat E1[2,`z'] = r(p50)
						mat E1[3,`z'] = r(p25)
						mat E1[4,`z'] = r(p75)
						mat E1[5,`z'] = r(p75)-r(p25)
						local rowvar `rowvar' `y'
						mat colnames E1 = `rowvar' "_" "p_value" "test"	
					}
				mat results_`y'_by_3 = E1
				global asum_resmat $asum_resmat "results_`y'_by_3"
				}
		}
	}	
end

program display_table
	di _newline
	di "*********************************************************************"
	di _newline
	if $asum_format == 1  {
			quietly levelsof $asum_groupvar, local(cols)
			local coltotal: word count `cols'
			mat final = J(1,`coltotal'+3,.z)
				forvalues i = 1/`coltotal' {
				local num10: word `i' of `cols'
				quietly count if $asum_groupvar == `num10'
				mat final[1,`i'] = r(N)
				}
			mat rownames final = N
			quietly levelsof $asum_groupvar, local(R4)
				foreach y in `R4' {
				local R5 = strtoname(`"`y'"')
				local R6 `R6' `R5'
				mat colnames final = $asum_groupvar:`R6' "Obs_N" "p_value" "test"
				}
			local R6
			local numtotal: word count $asum_varlist
				forvalues i= 1/`numtotal' {
				local A: word `i' of $asum_varlist
				mat final = final\ r_`A'
				}
			matlist final, border(all) title(Comparison Table) rowtitle(Variables) nodotz underscore twidth(20) lines(oneline) format(%9.3g)
			}
	else if $asum_format ==2 | $asum_format ==3{
		foreach v in $asum_resmat {
		mat final = `v'	
		matlist final, border(all) title(Comparison Table) rowtitle(Variables) nodotz underscore twidth(20) lines(oneline) format(%9.3g)
		}
	}
	local final_row = rowsof(final)
	local final_col= colsof(final)	
	forvalues i= 1/`final_row' {
	local testvalue = final[`i',`final_col']  
	local testcolumn `testcolumn' `testvalue'
	}
	foreach v in `testcolumn' {
		if inlist(`v',1,2,7) {
		local cat1 "Summary of categorical data is presented in frequency tables. "
		}
		if inlist(`v',3,4,8,9) {
		local cat2 "Means and standard deviations are shown for continuous data (parametric distribution). "
		}
		else if inlist(`v',5,6,10,11) {
		local cat3 "Medians and interquartile ranges are shown for continuous data (non-parametric distribution). "
		}
		if inlist(`v',1) {
		local cat4 "Comparison between categorical groups is performed using Pearson's chi squared test (1). "
		}
		if inlist(`v',2) {
		local cat5 "Comparison between categorical groups is performed using Fisher's exact test (2). "
		}
		if inlist(`v',3) {
		local cat6 "Comparison between continuous data is performed using two-sample unpaired t test (3). "
		}
		if inlist(`v',4) {
		local cat7 "Comparison between continuous data is performed using one-way ANOVA (4). "
		}
		if inlist(`v',5) {
		local cat8 "Comparison between continuous data is performed using Wilcoxon rank-sum test (5). "
		}
		if inlist(`v',6) {
		local cat9 "Comparison between continuous data is performed using Kruskal-Wallis test (6). "
		}
		if inlist(`v',7) {
		local cat10 "Paired data comparison is performed using Stuart-Maxwell's marginal homogeneity test (7). "
		}
		if inlist(`v',8) {
		local cat11 "Paired data comparison is performed using paired t test (8). "
		}
		if inlist(`v',9) {
		local cat12 "Paired data comparison is performed using repeated measures ANOVA test (9). "
		}
		if inlist(`v',10) {
		local cat13 "Paired data comparison is performed using Wilcoxon matched-pairs signed-ranks test (10). "
		}
		if inlist(`v',11) {
		local cat14 "Paired data comparison is performed using Friedman's analysis of variance test (11). "
		}
		local cat15 "Two-tailed p values are shown with significance set at 95% level. "
		
	}
	global asum_caption `cat1' `cat2' `cat3' `cat4' `cat5' `cat6' `cat7' `cat8' `cat9' `cat10' `cat11' `cat12' `cat13' `cat14' `cat15' 
	di "$asum_caption"
	
end

program export_table
syntax [varlist] [if] [in] [, EXPort(string asis) Pvalue(string) *]
if "`export'" != "" {
	preserve
	drop _all
	quietly svmat final
	format _all %9.2g
	local coln: colnames final
	local rown: rownames final
	local coleq: coleq final
	local roweq: roweq final
	local coltotal: word count `coln'
		forvalues v= 1/`coltotal' {
		local newcolvar: word `v' of `coln'
		rename final`v' `newcolvar'
		}
	local rowtotal: word count `rown'
	quietly gen Variables = ""
	order Variables , first
		forvalues y= 1/`rowtotal' {
		local newrowvar: word `y' of `rown'
		quietly replace Variable = `"`newrowvar'"' in `y'
		}
	quietly recode p_value (.z = .)
	capture recode _ (.z = .)
	capture recode Obs_N (.z = .)

		if $asum_format==1 | "$asum_catvar" != "" {
		quietly gen Vartype = ""
		order Vartype , first
		forvalues x = 1/`rowtotal' {
			local newrowvar2: word `x' of `roweq'
			quietly replace Vartype = `"`newrowvar2'"' in `x'
			}
			quietly {
			gen dups =1 if Vartype[_n] == Vartype[_n-1]
			replace Vartype = "" if dups ==1
			drop dups
			replace Vartype = "" if Vartype == "_"
			}
		tokenize `coleq'
		rename Variable `1'
		rename Vartype Variables
		}
	
	if "`pvalue'" == "star" {
		quietly {
		gen p_star = ""
		replace p_star = "*" if p_value < 0.05
		replace p_star = "**" if p_value < 0.01
		replace p_star = "***" if p_value < 0.001
		tostring p_value, replace format(%4.3f) force
		replace p_value = "<0.001" if p_value == "0.000"
		replace p_value = p_value + p_star if !missing(p_star)
		replace p_value = "" if p_value == "."
		drop p_star		
		local catp "Significance level (* p <0.05; ** p <0.01; *** p <0.001)"
		global asum_caption $asum_caption `catp'
		}
	}
	
	quietly {
	quietly recode test (.z = .)
	tostring test, replace format(%2.0f) force
	replace Variables = Variables + " (" + test + ")" if test != "."
	drop test
	set obs `=_N+1'
	local finalrow = `rowtotal' +1
	replace Variables = `"$asum_caption"' in `finalrow'
	}
	
	quietly export delimited using `"`export'.csv"', datafmt replace
}

end



program erase_data
	capture mat drop A asum_A1 C1 C2 D1 E1 F1 final
	foreach v in $asum_resmat {
	mat drop `v'
	}
	capture mac drop asum_groupvar asum_varlist asum_manual asum_catvar asum_nonparavar asum_paravar asum_resmat response response1
	
end


/*
caption - test (1 - exact, 2 - chi2 3 - ttest, 4 - oneway, 5- ranksum, 6 - kwallis, 
7- symmetry, 8 paired ttest, 9 repeated anova, 10 - signrank, 11 - friedman

*/


