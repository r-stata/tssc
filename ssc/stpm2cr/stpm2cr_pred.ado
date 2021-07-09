*! version 2.3 11Nov2018

program stpm2cr_pred, sortpreserve
	version 14.1
	syntax newvarname [if] [in], [CAUSE(numlist integer) CIF SUBhazard CUMODDS SUBDENSity CUMSUBhazard CSH XB DXB ///
									AT(string) SURVivor SHRDenominator(string) SHRNumerator(string) ///
									CHRDenominator(string) CHRNumerator(string) noOFFset CUREd UNCURED ///
									CI LEVel(real `c(level)') TIMEvar(varname) STDP PER(real 1) CIFRATIO  ///
									CIFDIFF1(string) CIFDIFF2(string) n(int 1000) zeros rml(string)]
									
	local newvarname `varlist'
	
	marksample touse, novarlist
	
	qui count if `touse'
	local nobs = r(N)
	
	if `nobs'==0 {
		error 2000          /* no observations */
	}
	
	/* Check Options */
	
	/*if "`e(scale)'" =="odds" {
		display as error "Post-estimation predictions for odds-of-failure models currently under work and will be available soon..."
		exit 198
	}*/
	if "`e(scale)'" =="multi" {
		display as error "Post-estimation predictions for models with different scales currently unavailable. Alternatively, use predictnl."
		exit 198
	}
	
	if "`cifdiff2'" != "" & "`cifdiff1'" == "" {
		display as error "You must specifiy the cifdiff1 option if you specify the cifdiff2 option"
		exit 198
	}
	
	if "`shrdenominator'" != "" & "`shrnumerator'" == "" {
		display as error "You must specify the shrnumerator option if you specify the shrdenominator option"
		exit 198
	}
	
	if "`chrdenominator'" != "" & "`chrnumerator'" == "" {
		display as error "You must specify the chrnumerator option if you specify the chrdenominator option"
		exit 198
	}
	
	local hratiotmp = substr("`hrnumerator'",1,1)
	local shratiotmp = substr("`shrnumerator'",1,1)
	local cifdifftmp = substr("`cifdiff1'",1,1)
	local rmltmp = substr("`rml'",1,1)

	if wordcount(`"`cif' `subhazard' `cumsubhazard' `cumodds' `subdensity' `survivor' `xb' `csh' `cured' `uncured' `cifdifftmp' `rmltmp'"') > 1 {
		display as error "You have specified more than one option for predict"
		exit 198
	}
	if wordcount(`"`cif' `subhazard' `cumsubhazard' `cumodds' `subdensity' `shratiotmp' `hratiotmp' `survivor' `xb' `csh' `cured' `uncured' `cifratio' `cifdifftmp' `chrnumerator' `shrnumerator' `rml'"') == 0 {
		display as error "You must specify one of the predict options"
		exit 198
	}
	
	if `per' != 1 & "`subhazard'" == "" {
		display as error "You can only use the per() option in combinaton with the subhazard or csh option."
		exit 198		
	}
	
	if "`at'" != "" & "`shrnumerator'" != "" {
		display as error "You can not use the at option with the shrnumerator and shrdenominator options"
		exit 198
	}
	if "`at'" != "" & "`chrnumerator'" != "" {
		display as error "You can not use the at option with the chrnumerator and chrdenominator options"
		exit 198
	}
	 if "`stdp'" != "" & "`ci'" != "" {
        display as error "You can not specify both the ci and stdp options."
        exit 19
     }

		
	/* End of Check Options */
	
	/* Specify Cause */
	if "`cause'"=="" {
		local causeList `e(causeList)'
	}
	else {
		local causeList `cause'
	}
	di "Calculating predictions for the following causes: `causeList'"
	
	/* store time-dependent covariates and main varlist */
	foreach n in `causeList' {
		local etvc`n' `e(tvc_c`n')'
		tempvar _d`n'
		qui gen `_d`n'' = 1 if `e(events)' == `n' 
		qui replace `_d`n'' = 0 if `e(events)' != `n'
		local main_varlist_c`n' `e(varlist_c`n')'
	}
	
	/* generate ocons for use when orthogonalising splines */
	tempvar ocons
	qui gen `ocons' = 1
	
	/* Use _t if option timevar not specified */
	tempvar t lnt 
	if "`timevar'" == "" {
		qui gen double `t' = _t if `touse'
		qui gen double `lnt' = ln(_t) if `touse'
	}
	else {
		qui gen double `t' = `timevar' if `touse'
		qui gen double `lnt' = ln(`timevar') if `touse'
	}
	
	/* Check to see if nonconstant option used */
	if "`e(noconstant)'" == "" {
		tempvar cons
		qui gen `cons' = 1 if `touse'
	}	

	
	/* Preserve data for out of sample prediction  */	
	tempfile newvars 
	preserve
	
	if "`rml'" == "" {
	/* Calculate new spline terms if timevar option specified */
        foreach n in `e(causeList)' {
			if "`timevar'" != "" & "`e(rcsbaseoff_c`n')'" == "" {
					capture drop _rcs_c`n'_* _d_rcs_c`n'_*
					if "`e(orthog)'" != "" {
							tempname rmatrix_c`n'
							matrix `rmatrix_c`n'' = e(R_bh_c`n')
							local rmatrixopt_c`n' rmatrix(`rmatrix_c`n'')
					}
					qui rcsgen `lnt' if `touse', knots(`e(ln_bhknots_c`n')') gen(_rcs_c`n'_) dgen(_d_rcs_c`n'_) if2(`_d`n'') `e(reverse_c`n')' `rmatrixopt_c`n'' `e(nosecondder_c`n')' `e(nofirstder_c`n')'
					
			}
		}
		// save knots from est command and refer to above in knots()
	
	
	/* calculate new spline terms if timevar option, cdiff, hdiff or cdiff option is specified */
	foreach n in `e(causeList)' {
		if "`timevar'" != "" | "`shrnumerator'" != "" | "`chrnumerator'" != "" | "`cifdiff1'" != "" | "`hdiff1'" != "" {
			foreach tvcvar in `e(tvc_c`n')' {
				if "`timevar'" != "" & "`e(rcsbaseoff_c`n')'" == "" {
					capture drop _rcs_`tvcvar'_c`n'_* _d_rcs_`tvcvar'_c`n'_*
				}			
				if (("`shrnumerator'" != "" | "`chrnumerator'" != "" | "`cifdiff1'" != "" | "`hdiff1'" != "") & "`timevar'" == "") | "`e(rcsbaseoff)'" != "" {
					capture drop _rcs_`tvcvar'_c`n'_* _d_rcs_`tvcvar'_c`n'_*
				}
				if "`e(orthog)'" != "" {
					tempname rmatrix_`tvcvar'_c`n'
					matrix `rmatrix_`tvcvar'_c`n'' = e(R_`tvcvar'_c`n')
					local rmatrixopt_c`n' rmatrix(`rmatrix_`tvcvar'_c`n'')
				}
				qui rcsgen `lnt' if `touse',  gen(_rcs_`tvcvar'_c`n'_) knots(`e(ln_tvcknots_`tvcvar'_c`n')') dgen(_d_rcs_`tvcvar'_c`n'_) if2(`_d`n'') `rmatrixopt_c`n'' `e(reverse_c`n')'
				if "`chrnumerator'" == "" & "`shrnumerator'" == "" & "`cifdiff1'"  == "" & "`hdiff1'" == "" {
					forvalues i = 1/`e(df_`tvcvar'_c`n')'{
						qui replace _rcs_`tvcvar'_c`n'_`i' = _rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
						qui replace _d_rcs_`tvcvar'_c`n'_`i' = _d_rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
					}
				}

			}
		}
	}
	
	/* zeros */
    foreach n in `e(causeList)' {
		if "`zeros'" != "" {
                local tmptvc_c`n' `e(tvc_c`n')'
                foreach var in `e(varlist_c`n')' {
                        _ms_parse_parts `var'
                        if `"`: list posof `"`r(name)'"' in at'"' == "0" { 
                                qui replace `r(name)' = 0 if `touse'
                                if `"`: list posof `"`r(name)'"' in tmptvc_c`n''"' != "0" { 
                                forvalues i = 1/`e(df_`r(name)'_c`n')' {
                                                qui replace _rcs_`r(name)'_c`n'_`i' = 0 if `touse'
                                                qui replace _d_rcs_`r(name)'_c`n'_`i' = 0 if `touse'
                                        }
                                }
                        }
                }
        }
	}

	
	/* Out of sample predictions using at() */
	foreach n in `causeList' {
	
		if "`at'" != "" {
			tokenize `at'
			while "`1'"!="" {
				fvunab tmpfv: `1'
				local 1 `tmpfv'
				_ms_parse_parts `1'
				if "`r(type)'"!="variable" {
					display as error "level indicators of factor" /*
									*/ " variables may not be individually set" /*
									*/ " with the at() option; set one value" /*
									*/ " for the entire factor variable"
					exit 198
				}
				cap confirm var `2'
				if _rc {
					cap confirm num `2'
					if _rc {
						di as err "invalid at(... `1' `2' ...)"
						exit 198
					}
				}

				qui replace `1' = `2' if `touse'
				if `"`: list posof `"`1'"' in etvc`n''"' != "0" {
					local tvcvar `1'
					if "`e(orthog)'" != "" {
						tempname rmatrix_`tvcvar'_c`n'
						matrix `rmatrix_`tvcvar'_c`n'' = e(R_`tvcvar'_c`n')
						local rmatrixopt_c`n' rmatrix(`rmatrix_`tvcvar'_c`n'')
					}
					capture drop _rcs_`tvcvar'_c`n'_* _d_rcs_`tvcvar'_c`n'_*
					qui rcsgen `lnt' if `touse', knots(`e(ln_tvcknots_`tvcvar'_c`n')') gen(_rcs_`tvcvar'_c`n'_) dgen(_d_rcs_`tvcvar'_c`n'_) if2(`_d`n'') `rmatrixopt_c`n'' `e(reverse_c`n')'
					forvalues i = 1/`e(df_`tvcvar'_c`n')'{
						qui replace _rcs_`tvcvar'_c`n'_`i' = _rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
						qui replace _d_rcs_`tvcvar'_c`n'_`i' = _d_rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
					}
				}
				mac shift 2
			}
		}
	}
	}
	
	
* Obtain Predictions **
	
	/* Calculate S(t) */
	if ("`csh'" != "" | "`survivor'" != "" | "cured" != "") {
		tempvar st sumcif
		foreach y in `e(causeList)' {
			tempvar cifxb_c`y'
			local j = `j' + 1
			
			if "`e(scale)'" =="hazard" {
				qui predictnl double `cifxb_c`y'' = 1 - exp(-exp(xb(#`j'))) `addoff' if `touse', `prednlopt' level(`level')
			}
			if "`e(scale)'" =="odds" {
				qui predictnl double `cifxb_c`y'' = exp(xb(#`j'))/(1 + exp(xb(#`j'))) `addoff' if `touse', `prednlopt' level(`level')
			}
			local cifxb `cifxb' `cifxb_c`y'' +
		}
		qui gen double `st' = (1 - (`cifxb' 0))
		qui gen double `sumcif' = `cifxb' 0
	}
	
	/* survivor (1-C(t)) */
	if "`survivor'" != "" {
		foreach n in `e(causeList)' {
			qui predictnl double `newvarname'_c`n' = `st' if `touse'
			tempvar tmpSt_c`n'
			if "`ci'" != "" {
				qui gen double `tmpSt' = 1 - `newvarname'_c`n'_uci if `touse'
				qui replace `newvarname'_c`n'_uci = 1 - `newvarname'_c`n'_lci if `touse'
				qui replace `newvarname'_c`n'_lci = `tmpSt_c`n'' if `touse'
			}
		}
	}
	
	/* Predict Cause-specific HRs */ 
	foreach n in `e(causeList)' {
		if "`chrnumerator'" != "" {
			
			// set temp vars
			tempvar chr_c`n'
			if `"`ci'"' != "" {
				tempvar chr_c`n'_lci chr_c`n'_uci
				local predictnl_opts_c`n' ci(`chr_c`n'_lci' `chr_c`n'_uci')
			}
			else if "`stdp'" != "" {
				tempvar chr_c`n'_se
				local predictnl_opts_c`n' se(`chr_c`n'_se')
			}		
			
			
			forvalues i=1/`e(dfbase_c`n')' {
				local dxb1_c`n' `dxb1_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_d_rcs_c`n'_`i' 
				local dxb0_c`n' `dxb0_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_d_rcs_c`n'_`i'
				local xb1_plus_c`n' `xb1_plus_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_rcs_c`n'_`i'
				local xb0_plus_c`n' `xb0_plus_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_rcs_c`n'_`i'
				if `i' != `e(dfbase_c`n')' {
					local dxb0_c`n' `dxb0_c`n'' + 
					local dxb1_c`n' `dxb1_c`n'' + 
					local xb1_plus_c`n' `xb1_plus_c`n'' +
					local xb0_plus_c`n' `xb0_plus_c`n'' +
				}
			}
			
			/* use Parse_list to select appropriate values of factor variables */
			Parse_list, listname(chrnumerator) parselist(`chrnumerator') n(`n')
			tokenize `r(retlist_c`n')'
			
			while "`1'"!="" {
				cap confirm var `2'
				if _rc {
					if "`2'" == "." {
						local 2 `1'
					}
					else {
						cap confirm num `2'
						/*
						if _rc {
							di as err "invalid shrnumerator(... `1' `2' ...)"
							exit 198
						}
						*/
						}
				}
				if "`xb10_c`n''" != "" & "`2'" != "0" & `: list posof `"`1'"' in main_varlist_c`n'' != 0{
					local xb10_c`n' `xb10_c`n'' +
				}
				if "`xb1_plus_c`n''" != "" & "`2'" != "0" &  `: list posof `"`1'"' in main_varlist_c`n'' != 0{
					local xb1_plus_c`n' `xb1_plus_c`n'' +
				}

				if "`2'" != "0" & `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
					local xb10_c`n' `xb10_c`n'' [`e(cause_`n')'][`1']*`2' 
					local xb1_plus_c`n' `xb1_plus_c`n'' [`e(cause_`n')'][`1']*`2' 
				}
				

				if `"`: list posof `"`1'"' in etvc`n''"' != "0" & "`2'" != "0" {
					if "`e(rcsbaseoff)'" == ""  | (`: list posof `"`1'"' in etvc`n''>1) {
						local dxb1_c`n' `dxb1_c`n'' +
					}
					if "`xb10_c`n''" != "" {
						local xb10_c`n' `xb10_c`n'' +
					}
					local xb1_plus_c`n' `xb1_plus_c`n'' +
					
					forvalues i=1/`e(df_`1'_c`n')' {
						local dxb1_c`n' `dxb1_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_d_rcs_`1'_c`n'_`i'*`2' 
						local xb10_c`n' `xb10_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'  
						local xb1_plus_c`n' `xb1_plus_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'  
						if `i' != `e(df_`1'_c`n')' {
							local dxb1_c`n' `dxb1_c`n'' +
							local xb10_c`n' `xb10_c`n'' +
							local xb1_plus_c`n' `xb1_plus_c`n'' +
						}
					}
				}
				mac shift 2
			}			
		
		
			if "`chrdenominator'" != "" {
				/* use Parse_list to select appropriate values of factor variables */
				Parse_list, listname(chrdenominator) parselist(`chrdenominator') n(`n')
				tokenize `r(retlist_c`n')'
				while "`1'"!="" {
					cap confirm var `2'
					if _rc {
						if "`2'" == "." {
							local 2 `1'
						}
						else {
						/*
							cap confirm num `2'
							if _rc {
								di as err "invalid hrdenominator(... `1' `2' ...)"
								exit 198
							}
						*/
						}
					}
					if "`2'" != "0" & `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
						local xb10_c`n' `xb10_c`n'' - [`e(cause_`n')'][`1']*`2'
						if "`e(rcsbaseoff)'" == "" & `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
							local xb0_plus_c`n' `xb0_plus_c`n'' + [`e(cause_`n')'][`1']*`2' 
						}
						else if `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
							local xb0_plus_c`n' `xb0_plus_c`n'' [`e(cause_`n')'][`1']*`2' 
						}
					}
					if `"`: list posof `"`1'"' in etvc`n''"' != "0" & "`2'" != "0" {
						if "`e(rcsbaseoff)'" == "" {
							local dxb0_c`n' `dxb0_c`n'' +
						}
						local xb0_plus_c`n' `xb0_plus_c`n'' + 
						local xb10_c`n' `xb10_c`n'' - 
						forvalues i=1/`e(df_`1'_c`n')' {
							local dxb0_c`n' `dxb0_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_d_rcs_`1'_c`n'_`i'*`2'
							local xb10_c`n' `xb10_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'
							local xb0_plus_c`n' `xb0_plus_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'
							if `i' != `e(df_`1'_c`n')' {
								local dxb0_c`n' `dxb0_c`n'' +
								local xb10_c`n' `xb10_c`n'' -
								local xb0_plus_c`n' `xb0_plus_c`n'' +
							}
						}
					}
					mac shift 2
				}
			}
		
			if "`e(noconstant)'" == "" {
				local xb0_plus_c`n' `xb0_plus_c`n'' + [`e(cause_`n')'][_cons]
				local xb1_plus_c`n' `xb1_plus_c`n'' + [`e(cause_`n')'][_cons]
			}
		
		}
	}
	
	if ("`chrnumerator'" != "" | "`chrdenominator'" != "") {
		foreach ator in 0 1 {
			local st`ator' 
			local sumcif`ator'
			local cifxb`ator'
			foreach y in `causeList' {
				tempvar cifxb`ator'_c`y'
				qui predictnl double `cifxb`ator'_c`y'' = 1 - exp(-exp(`xb`ator'_plus_c`y'')) `addoff' if `touse', level(`level')
				local cifxb`ator' `cifxb`ator'' (`cifxb`ator'_c`y'') +
			}
			local st`ator' `st`ator'' (1 - (`cifxb`ator'' 0))
			local sumcif`ator' `sumcif`ator'' `cifxb`ator'' 0
		}
		
		foreach n in `causeList' {
			if "`e(scale)'" =="hazard" {				
				qui predictnl double `chr_c`n'' = ((((`dxb1_c`n'')*exp(`xb1_plus_c`n''))/(`t'))*(1 + (((`sumcif1') - (`cifxb1_c`n''))/(`st1')))) ///
					/ ((((`dxb0_c`n'')*exp(`xb0_plus_c`n''))/(`t'))*(1 + (((`sumcif0') - (`cifxb0_c`n''))/(`st0')))) if `touse', `predictnl_opts_c`n'' level(`level')
			}
			else if "`e(scale)'" =="odds" {
				/*qui predictnl double `lshr_c`n'' =  ln(`dxb1_c`n'') - ln(`dxb0_c`n'') + `xb10_c`n'' - ///
												ln(1+exp(`xb1_plus_c`n'')) + ln(1+exp(`xb0_plus_c`n'')) ///
												if `touse', `predictnl_opts' level(`level')*/
			}

			qui gen double `newvarname'_c`n' = (`chr_c`n'') if `touse'
			if `"`ci'"' != "" {
				qui gen double `newvarname'_c`n'_lci= (`chr_c`n'_lci')  if `touse'
				qui gen double `newvarname'_c`n'_uci= (`chr_c`n'_uci')  if `touse'
			}
			else if "`stdp'" != "" {
				qui gen double `newvarname'_c`n'_se = `chr_c`n'_se' * `newvarname_c`n''
			}
		}
		
	}
	
	
	
	local j = 0	
	/* Start loop over all causes */
	foreach n in `causeList' {
		
		tokenize `e(causeList)'
		forvalues i = 1/`e(n_causes)' {
			if "``i''" == "`n'" {
				local j = `i'
			}
		}
			
		//local j = `j' + 1
		local k = `j' + `e(n_causes)'
		
		/* linear predictor */	
		else if "`xb'" != "" {
			if "`ci'" != "" {
				local prednlopt ci(`newvarname'_c`n'_lci `newvarname'_c`n'_uci)
			}
			else if "`stdp'" != "" {
				local prednlopt se(`newvarname'_c`n'_se)
			}
			qui predictnl double `newvarname'_c`n' = xb(#`j') `addoff' if `touse', `prednlopt' level(`level')
		}
		
		else if "`dxb'" != "" {
			if "`ci'" != "" {
				local prednlopt ci(`newvarname'_c`n'_lci `newvarname'_c`n'_uci)
			}
			else if "`stdp'" != "" {
				local prednlopt se(`newvarname'_c`n'_se)
			}
			qui predictnl double `newvarname'_c`n' = xb(#`k') `addoff' if `touse', `prednlopt' level(`level')
		}

		
		/* Cumulative Hazard */
        else if "`cumsubhazard'" != "" {
			if "`ci'" != "" {
				local prednlopt ci(`newvarname'_c`n'_lci `newvarname'_c`n'_uci)
			}
                qui predictnl double `newvarname'_c`n' = -ln(1 - (1 - exp(-exp(xb(#`j'))))) if `touse', `prednlopt' level(`level')
        }
		else if "`cumodds'" != "" {
			if "`ci'" != "" {
				local prednlopt ci(`newvarname'_c`n'_lci `newvarname'_c`n'_uci)
			}
                qui predictnl double `newvarname'_c`n' = (exp(xb(#`j'))/(1 +exp(xb(#`j')))) / (1 - (exp(xb(#`j'))/(1 +exp(xb(#`j'))))) if `touse', `prednlopt' level(`level')
        }
		/* Subdensity */
        else if "`subdensity'" != "" {
			if "`ci'" != "" {
				local prednlopt ci(`newvarname'_c`n'_lci `newvarname'_c`n'_uci)
			}
			if "`e(scale)'" =="hazard" {
                qui predictnl double `newvarname'_c`n' = exp(-ln(`t') + ln(xb(#`k')) + xb(#`j'))*(1 - (1 - exp(-exp(xb(#`j'))))) if `touse', `prednlopt' level(`level')
			}
			else if "`e(scale)'" =="odds" {
				qui predictnl double `newvarname'_c`n' = (1/`t')*((xb(#`k')*exp(xb(#`j')))/(1 + exp(xb(#`j')))^2) if `touse', `prednlopt' level(`level')
			}
        }

		/* Cumulative Incidence Function */
		if "`cif'" != "" {
			if "`ci'" != "" {
				tempvar sxb_c`n'_lci sxb_c`n'_uci
				local prednlopt ci(`sxb_c`n'_lci' `sxb_c`n'_uci')
			}
			else if "`stdp'" != "" {
				tempvar sxb_c`n'_se
				local prednlopt se(`sxb_c`n'_se')
			}	
			//tempvar sxb_c`n'
			//qui predictnl double `sxb_c`n'' = xb(#`j') `addoff' if `touse', `prednlopt' level(`level') 

			/* Transform back */
			if "`e(scale)'" == "hazard" {
				qui predictnl double `newvarname'_c`n' = 1 - exp(-exp(xb(#`j'))) if `touse', `prednlopt' level(`level') 
				if "`ci'" != "" {
					qui gen `newvarname'_c`n'_lci = `sxb_c`n'_lci' if `touse'
					qui gen `newvarname'_c`n'_uci = `sxb_c`n'_uci' if `touse'
				}
				if "`stdp'" != "" {
					qui gen `newvarname'_c`n'_se = `sxb_c`n'_se' if `touse'
				}
			}
			else if "`e(scale)'" == "odds" {
				qui predictnl double `newvarname'_c`n' = exp(xb(#`j'))/(1 +exp(xb(#`j'))) if `touse', `prednlopt' level(`level')
				if "`ci'" != "" {
					qui gen `newvarname'_c`n'_lci = `sxb_c`n'_lci' if `touse'
					qui gen `newvarname'_c`n'_uci = `sxb_c`n'_uci' if `touse'
				}
				if "`stdp'" != "" {
					qui gen `newvarname'_c`n'_se = `sxb_c`n'_se' if `touse'
				}
			}
		}
		
		/* Sub-Hazard Function */
		else if "`subhazard'" != "" {
			tempvar lnsh_c`n' 
			if "`ci'" != "" {
				tempvar lnsh_c`n'_lci lnsh_c`n'_uci
				local prednlopt ci(`lnsh_c`n'_lci' `lnsh_c`n'_uci')
			}
			if "`e(scale)'" == "hazard" {
				qui predictnl double `lnsh_c`n'' = -ln(`t') + ln(xb(#`k')) + xb(#`j') `addoff'  if `touse', `prednlopt' level(`level') 
			}
			if "`e(scale)'" == "odds" {
				qui predictnl double `lnsh_c`n'' = -ln(`t') + ln(xb(#`k')) + (xb(#`j') `addoff') - ln(1 + exp(xb(#`j') `addoff' ))   if `touse', `prednlopt' level(`level') 
			}

			/* Transform back to hazard scale */
			qui gen double `newvarname'_c`n' = exp(`lnsh_c`n'') if `touse'
			if "`ci'" != "" {
				qui gen `newvarname'_c`n'_lci = exp(`lnsh_c`n'_lci')  if `touse'
				qui gen `newvarname'_c`n'_uci =  exp(`lnsh_c`n'_uci') if `touse'
			}
		}
		
		/* Cause-specific Hazard Function */	
		else if "`csh'" != "" {
			tempvar lncsh_c`n' /*lnsh_c`n' sh_c`n' cif_c`n'*/ 
			if "`ci'" != "" {
				tempvar lncsh_c`n'_lci lncsh_c`n'_uci
				local prednlopt ci(`lncsh_c`n'_lci' `lncsh_c`n'_uci')
			}
			if "`e(scale)'" == "hazard" {
				qui predictnl double `lncsh_c`n'' = exp(-ln(`t') + ln(xb(#`k')) + xb(#`j'))*(1 + (((`sumcif') - (1 - exp(-exp(xb(#`j')))))/(`st'))) `addoff'  if `touse', `prednlopt' level(`level') 
			}
			if "`e(scale)'" == "odds" {
				//qui predictnl double `lnsh_c`n'' = -ln(`t') + ln(xb(#`k')) + (xb(#`j')`addoff')  -ln(1+exp(xb(#`j')`addoff'))   if `touse', `prednlopt' level(`level') 
			}		

			/* Transform back */
			qui gen double `newvarname'_c`n' = `lncsh_c`n'' if `touse'
			if "`ci'" != "" {
				qui gen `newvarname'_c`n'_lci = `lncsh_c`n'_lci'  if `touse'
				qui gen `newvarname'_c`n'_uci =  `lncsh_c`n'_uci' if `touse'
			}
		}	

		/* Predict sub-Hazard Ratio */
		else if "`shrnumerator'" != "" {
			
			// set temp vars
			tempvar lshr_c`n'
			if `"`ci'"' != "" {
				tempvar lshr_c`n'_lci lshr_c`n'_uci
				local predictnl_opts ci(`lshr_c`n'_lci' `lshr_c`n'_uci')
			}
			else if "`stdp'" != "" {
				tempvar lshr_c`n'_se
				local predictnl_opts se(`lshr_c`n'_se')
			}		
			
			
			forvalues i=1/`e(dfbase_c`n')' {
				local dxb1_c`n' `dxb1_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_d_rcs_c`n'_`i' 
				local dxb0_c`n' `dxb0_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_d_rcs_c`n'_`i'
				local xb1_plus_c`n' `xb1_plus_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_rcs_c`n'_`i'
				local xb0_plus_c`n' `xb0_plus_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_rcs_c`n'_`i'
				if `i' != `e(dfbase_c`n')' {
					local dxb0_c`n' `dxb0_c`n'' + 
					local dxb1_c`n' `dxb1_c`n'' + 
					local xb1_plus_c`n' `xb1_plus_c`n'' +
					local xb0_plus_c`n' `xb0_plus_c`n'' +
				}
			}
			
			/* use Parse_list to select appropriate values of factor variables */
			Parse_list, listname(shrnumerator) parselist(`shrnumerator') n(`n')
			tokenize `r(retlist_c`n')'
			
			while "`1'"!="" {
				cap confirm var `2'
				if _rc {
					if "`2'" == "." {
						local 2 `1'
					}
					else {
						cap confirm num `2'
						/*
						if _rc {
							di as err "invalid shrnumerator(... `1' `2' ...)"
							exit 198
						}
						*/
						}
				}
				if "`xb10_c`n''" != "" & "`2'" != "0" & `: list posof `"`1'"' in main_varlist_c`n'' != 0{
					local xb10_c`n' `xb10_c`n'' +
				}
				if "`xb1_plus_c`n''" != "" & "`2'" != "0" &  `: list posof `"`1'"' in main_varlist_c`n'' != 0{
					local xb1_plus_c`n' `xb1_plus_c`n'' +
				}
				
				if "`2'" != "0" & `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
					local xb10_c`n' `xb10_c`n'' [`e(cause_`n')'][`1']*`2' 
					local xb1_plus_c`n' `xb1_plus_c`n'' [`e(cause_`n')'][`1']*`2' 
				}
				

				if `"`: list posof `"`1'"' in etvc`n''"' != "0" & "`2'" != "0" {
					if "`e(rcsbaseoff_c`n')'" == ""  | (`: list posof `"`1'"' in etvc`n''>1) {
						local dxb1_c`n' `dxb1_c`n'' +
					}
					if "`xb10_c`n''" != "" {
						local xb10_c`n' `xb10_c`n'' +
					}
					local xb1_plus_c`n' `xb1_plus_c`n'' +
					
					forvalues i=1/`e(df_`1'_c`n')' {
						local dxb1_c`n' `dxb1_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_d_rcs_`1'_c`n'_`i'*`2' 
						local xb10_c`n' `xb10_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'  
						local xb1_plus_c`n' `xb1_plus_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'  
						if `i' != `e(df_`1'_c`n')' {
							local dxb1_c`n' `dxb1_c`n'' +
							local xb10_c`n' `xb10_c`n'' +
							local xb1_plus_c`n' `xb1_plus_c`n'' +
						}
					}
				}
				mac shift 2
			}			
				
			if "`shrdenominator'" != "" {
				/* use Parse_list to select appropriate values of factor variables */
				Parse_list, listname(shrdenominator) parselist(`shrdenominator') n(`n')
				tokenize `r(retlist_c`n')'
				while "`1'"!="" {
					cap confirm var `2'
					if _rc {
						if "`2'" == "." {
							local 2 `1'
						}
						else {
						/*
							cap confirm num `2'
							if _rc {
								di as err "invalid hrdenominator(... `1' `2' ...)"
								exit 198
							}
						*/
						}
					}
					
					if "`2'" != "0" & `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
						local xb10_c`n' `xb10_c`n'' - [`e(cause_`n')'][`1']*`2'
						if "`e(rcsbaseoff_c`n')'" == "" & `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
							local xb0_plus_c`n' `xb0_plus_c`n'' + [`e(cause_`n')'][`1']*`2' 
						}
						else if `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
							local xb0_plus_c`n' `xb0_plus_c`n'' [`e(cause_`n')'][`1']*`2' 
						}
					}
					if `"`: list posof `"`1'"' in etvc`n''"' != "0" & "`2'" != "0" {
						if "`e(rcsbaseoff_c`n')'" == "" {
							local dxb0_c`n' `dxb0_c`n'' +
						}
						local xb0_plus_c`n' `xb0_plus_c`n'' + 
						local xb10_c`n' `xb10_c`n'' - 
						forvalues i=1/`e(df_`1'_c`n')' {
							local dxb0_c`n' `dxb0_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_d_rcs_`1'_c`n'_`i'*`2'
							local xb10_c`n' `xb10_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'
							local xb0_plus_c`n' `xb0_plus_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'
							if `i' != `e(df_`1'_c`n')' {
								local dxb0_c`n' `dxb0_c`n'' +
								local xb10_c`n' `xb10_c`n'' -
								local xb0_plus_c`n' `xb0_plus_c`n'' +
							}
						}
					}
					mac shift 2
				}
			}
			if "`e(noconstant)'" == "" {
				local xb0_plus_c`n' `xb0_plus_c`n'' + [`e(cause_`n')'][_cons]
				local xb1_plus_c`n' `xb1_plus_c`n'' + [`e(cause_`n')'][_cons]
			}	
			if "`e(scale)'" =="hazard" {
				qui predictnl double `lshr_c`n'' = (ln(`dxb1_c`n'') + (`xb1_plus_c`n'') - ln(`t')) - (ln(`dxb0_c`n'') + (`xb0_plus_c`n'') - ln(`t'))  if `touse', `predictnl_opts' level(`level')
			}
			else if "`e(scale)'" =="odds" {
				qui predictnl double `lshr_c`n'' =  (ln(`dxb1_c`n'') + (`xb1_plus_c`n'') - ln(1 + exp(`xb1_plus_c`n''))) - ///
													(ln(`dxb0_c`n'') + (`xb0_plus_c`n'') - ln(1 + exp(`xb0_plus_c`n'')))  ///
													if `touse', `predictnl_opts' level(`level') //ln(`dxb1_c`n'') - ln(`dxb0_c`n'') + `xb10_c`n'' - ln(1+exp(`xb1_plus_c`n'')) + ln(1+exp(`xb0_plus_c`n''))
			}

			qui gen double `newvarname'_c`n' = exp(`lshr_c`n'') if `touse'
			if `"`ci'"' != "" {
				qui gen double `newvarname'_c`n'_lci= exp(`lshr_c`n'_lci')  if `touse'
				qui gen double `newvarname'_c`n'_uci= exp(`lshr_c`n'_uci')  if `touse'
			}
			else if "`stdp'" != "" {
				qui gen double `newvarname'_c`n'_se = exp(`lshr_c`n'_se') * `newvarname_c`n''
			}
		}
		
		/* Predict Difference in CIF Curves */	
	else if "`cifdiff1'" != "" {
			if `"`ci'"' != "" {
				local predictnl_opts "ci(`newvarname'_c`n'_lci `newvarname'_c`n'_uci)"
			}
			else if "`stdp'" != "" {
				local predictnl_opts se(`newvarname'_c`n'_se)
			}

		forvalues i=1/`e(dfbase_c`n')' {
			local xb1_plus_c`n' `xb1_plus_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_rcs_c`n'_`i'
			local xb0_plus_c`n' `xb0_plus_c`n'' [`e(cause_`n')'][_rcs_c`n'_`i']*_rcs_c`n'_`i'
			if `i' != `e(dfbase_c`n')' {
					local xb1_plus_c`n' `xb1_plus_c`n'' +
					local xb0_plus_c`n' `xb0_plus_c`n'' +
			}
		
		}

/* use Parse_list to select appropriate values of factor variables */
			Parse_list, listname(cifdiff1) parselist(`cifdiff1') n(`n')
			tokenize `r(retlist_c`n')'
			
			while "`1'"!="" {
				cap confirm var `2'
				if _rc {
					if "`2'" == "." {
						local 2 `1'
					}
					else {
						/*cap confirm num `2'
						
						if _rc {
							di as err "invalid shrnumerator(... `1' `2' ...)"
							exit 198
						}
						*/
						}
				}
	
				if "`xb1_plus_c`n''" != "" & "`2'" != "0" &  `: list posof `"`1'"' in main_varlist_c`n'' != 0{
					local xb1_plus_c`n' `xb1_plus_c`n'' +
				}
				
				if "`2'" != "0" & `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
					
					local xb1_plus_c`n' `xb1_plus_c`n'' [`e(cause_`n')'][`1']*`2' 
				}
				
				if `"`: list posof `"`1'"' in etvc`n''"' != "0" & "`2'" != "0" {
					local xb1_plus_c`n' `xb1_plus_c`n'' +
					
					forvalues i=1/`e(df_`1'_c`n')' {
						local xb1_plus_c`n' `xb1_plus_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'  
						if `i' != `e(df_`1'_c`n')' {
							local xb1_plus_c`n' `xb1_plus_c`n'' +
						}
					}
				}
				mac shift 2
			}			
		
			if "`cifdiff2'" != "" {
				/* use Parse_list to select appropriate values of factor variables */
				Parse_list, listname(cifdiff2) parselist(`cifdiff2') n(`n')
				tokenize `r(retlist_c`n')'
				while "`1'"!="" {
					cap confirm var `2'
					if _rc {
						if "`2'" == "." {
							local 2 `1'
						}
						else {
						/*
							cap confirm num `2'
							if _rc {
								di as err "invalid hrdenominator(... `1' `2' ...)"
								exit 198
							}
						*/
						}
					}
					if "`2'" != "0" & `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
						local xb10_c`n' `xb10_c`n'' - [`e(cause_`n')'][`1']*`2'
						if "`e(rcsbaseoff)'" == "" & `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
							local xb0_plus_c`n' `xb0_plus_c`n'' + [`e(cause_`n')'][`1']*`2' 
						}
						else if `: list posof `"`1'"' in main_varlist_c`n'' != 0 {
							local xb0_plus_c`n' `xb0_plus_c`n'' [`e(cause_`n')'][`1']*`2' 
						}
					}
					if `"`: list posof `"`1'"' in etvc`n''"' != "0" & "`2'" != "0" {
						if "`e(rcsbaseoff)'" == "" {
							local dxb0_c`n' `dxb0_c`n'' +
						}
						local xb0_plus_c`n' `xb0_plus_c`n'' + 
						local xb10_c`n' `xb10_c`n'' - 
						forvalues i=1/`e(df_`1'_c`n')' {
							local dxb0_c`n' `dxb0_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_d_rcs_`1'_c`n'_`i'*`2'
							local xb10_c`n' `xb10_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'
							local xb0_plus_c`n' `xb0_plus_c`n'' [`e(cause_`n')'][_rcs_`1'_c`n'_`i']*_rcs_`1'_c`n'_`i'*`2'
							if `i' != `e(df_`1'_c`n')' {
								local dxb0_c`n' `dxb0_c`n'' +
								local xb10_c`n' `xb10_c`n'' -
								local xb0_plus_c`n' `xb0_plus_c`n'' +
							}
						}
					}
					mac shift 2
				}
			}
		
			if "`e(noconstant)'" == "" {
				local xb0_plus_c`n' `xb0_plus_c`n'' + [`e(cause_`n')'][_cons]
				local xb1_plus_c`n' `xb1_plus_c`n'' + [`e(cause_`n')'][_cons]
			}
		
			if "`e(scale)'" =="hazard" {
				
				qui predictnl double `newvarname'_c`n' = (1 - exp(-exp(`xb1_plus_c`n''))) - (1 - exp(-exp(`xb0_plus_c`n''))) if `touse', `predictnl_opts' level(`level')
			}
			else if "`e(scale)'" =="odds" {
				qui predictnl double `newvarname'_c`n' = (exp(`xb1_plus_c`n'')/(1 +exp(`xb1_plus_c`n''))) - ///
													(exp(`xb0_plus_c`n'')/(1 +exp(`xb0_plus_c`n''))) ///
													if `touse', `predictnl_opts' level(`level')
			}

		}
			
		/* Predict CIF Ratio */
		else if "`cifratio'" != "" {
			tempvar lcifr_c`n'
			local totcif
			local z1 = 0
			foreach sum in `e(causeList)' {
				tempvar cif_c`sum'
				local z1 = `z1' + 1
				local z2 = `z1' + `e(n_causes)'
				if "`e(scale)'" =="hazard" {
					qui predictnl double `cif_c`sum'' = 1 - exp(-exp(xb(#`z1'))) `addoff' if `touse', `prednlopt' level(`level') 
				}
				else if "`e(scale)'" =="odds" {
					qui predictnl double `cif_c`sum'' = exp(xb(#`z1'))/(1 +exp(xb(#`z1'))) `addoff' if `touse', `prednlopt' level(`level') 
				}
				local totcif `totcif' (`cif_c`sum'') +
			
			}
			local totcif `totcif' 0
			
			if "`e(noconstant)'" == "" {
				local xb0_plus_c`n' `xb0_plus_c`n'' + [`e(cause_`n')'][_cons]
				local xb1_plus_c`n' `xb1_plus_c`n'' + [`e(cause_`n')'][_cons]
			}	
			if "`e(scale)'" =="hazard" {
				qui predictnl double `lcifr_c`n'' = ln(1 - exp(-exp(xb(#`j')))) - ln(`totcif') if `touse', `predictnl_opts' level(`level')
			}
			else if "`e(scale)'" =="odds" {
				qui predictnl double `lcifr_c`n'' = ln((exp(xb(#`j')))/(1 +exp(xb(#`j')))) - ln(`totcif') ///
													if `touse', `predictnl_opts' level(`level')
			}

			qui gen double `newvarname'_c`n' = exp(`lcifr_c`n'') if `touse'
			if `"`ci'"' != "" {
				qui gen double `newvarname'_c`n'_lci=exp(`lcifr_c`n'_lci')  if `touse'
				qui gen double `newvarname'_c`n'_uci=exp(`lcifr_c`n'_uci')  if `touse'
			}
			else if "`stdp'" != "" {
				qui gen double `newvarname'_c`n'_se = `lcifr_c`n'_se' * `newvarname_c`n''
			}
		}
		
		/* estimate cure, survival of uncured or hazard of uncured */
        else if "`cured'" != "" | "`uncured'" != "" {
                local xblist_c`n' [`e(cause_`n')'][_cons]
                local rcslist_c`n'
                local drcslist_c`n'
                tempvar temp_c`n'
				tempvar cif_c`n'
                if "`ci'" != "" {
                        local prednlopt ci(`temp_c`n''_lci `temp_c`n''_uci)
                }
                foreach var in `e(varlist_c`n')' {
                        local xblist_c`n' `xblist_c`n'' + [`e(cause_`n')'][`var']*`var'
                }
                
                if "`cured'" != ""  {             /*if cure is specified this is what we want to estimate*/
                        
						qui predictnl double `temp_c`n'' = `xblist_c`n'' if `touse', `prednlopt' level(`level')
						qui gen double `newvarname'_c`n' = 1 - exp(-exp(`temp_c`n'')) if `touse'      /*we model on log(-log) scale*/
						if "`ci'" != "" {               
								qui gen double `newvarname'_lci = 1 - exp(-exp(`temp_c`n''_uci)) if `touse'
								qui gen double `newvarname'_uci = 1 - exp(-exp(`temp_c`n''_lci)) if `touse'
						}
						/*calculate cif for those that are still alive but will eventually die from the cause the cure was specified for*/
						if "`e(cure_c`n')'" != "" {
							qui predictnl double `cif_c`n'' = 1 - exp(-exp(xb(#`j'))) `addoff' if `touse', `prednlopt' level(`level') 
							qui gen double `newvarname'_c`n'_btd = `newvarname'_c`n' + `sumcif' - `cif_c`n'' if `touse' // get rid of cuf 
						}
                }
				                
                else {          /*continue, estimate survival or hazard of uncured or Predicted survival time among uncured for a given centile*/
                        forvalues i = 1/`e(dfbase_c`n')' {   	
                                if "`rcslist_c`n''" == "" local rcslist_c`n' [`e(cause_`n')'][_rcs_c`n']*_rcs_c`n'_`i'                        /*create a list of the sum of all spline variables*/
                                else local rcslist_c`n' `rcslist_c`n'' + [`e(cause_`n')'][_rcs_c`n'_`i']*_rcs_c`n'_`i'
                        }
                        foreach var in `e(tvc_c`n')' {
                                forvalues i = 1/`e(df_`var'_c`n')' {
                                        local rcslist_c`n' `rcslist_c`n'' + [`e(cause_`n')'][_rcs_`var'_c`n'_`i']*_rcs_`var'_c`n'_`i'
                                }
                        }
                        forvalues i = 1/`e(dfbase_c`n')' {
                                if "`drcslist_c`n''" == "" local drcslist_c`n' [`e(cause_`n')'][_rcs_c`n'_`i']*_d_rcs_c`n'_`i'            /*need derivatives of rcslist to calculate hazard and for centile*/
                                else local drcslist_c`n' `drcslist_c`n'' + [`e(cause_`n')'][_rcs_c`n'_`i']*_d_rcs_c`n'_`i'
                        }
                        foreach var in `e(tvc_c`n')' {
                                forvalues i = 1/`e(df_`var'_c`n')' {
                                                local drcslist_c`n' `drcslist_c`n'' + [`e(cause_`n')'][_rcs_`var'_c`n'_`i']*_d_rcs_`var'_c`n'_`i'
                                }
                        }               
                        local pi exp(-exp(`xblist'))            /*we need cure for estimation of cif and hazard*/
                        local exprcs exp(`rcslist')             /*we need exp of the sum of all spline variables for estimation of survival and hazard*/
						/*predicted cif of uncured*/               
                        if "`cif'" != "" & "`uncured'" != "" {                     
                                tokenize `e(boundary_knots)'
                                local lastknot = `2' 
                                qui predictnl double `temp' = ln(-(ln(`pi'^(`exprcs') - `pi') - ln(1 - `pi'))) if `touse', `prednlopt' level(`level')
                                qui gen double `newvarname' = exp(-exp(`temp')) if `touse'
                                qui replace `newvarname' = 0 if `newvarname' == . & `t'>=`lastknot' & `touse'
                                if "`ci'" != "" {
                                        qui gen double `newvarname'_lci = exp(-exp(`temp'_uci)) if `touse'
                                        qui gen double `newvarname'_uci = exp(-exp(`temp'_lci)) if `touse'
                                }
                        }
						/*predicted subhazard of uncured*/         
                        else if "`subhazard'" != "" & "`uncured'" != "" {    
                                qui predictnl double `temp' = ln(-ln(`pi')*((`drcslist')/`t')*`exprcs'*`pi'^(`exprcs'))- ln(`pi'^(`exprcs') - `pi')  if `touse', `prednlopt' level(`level') 
                                qui gen double `newvarname' = exp(`temp') if `touse'
                                if "`ci'" != "" {
                                        qui gen double `newvarname'_lci = exp(`temp'_lci) if `touse'
                                        qui gen double `newvarname'_uci = exp(`temp'_uci) if `touse'
                                }
                        }           
                }               
        }		
		
	} /* End loop over all causes */
	
	/* Estimate restricted mean lifetime */
	if "`rml'" != "" {
		//code adapted from strcs and stgenreg
		di "Calculating restricted mean lifetime"
		// gen weights
		// gen nodes and then use these nodes in rcsgen to get the generated spline variables
		// then add these new spline variables to the xb's predicted from the model
		// use gauss quad eqn
		local k  = 1
		
		parse_opt `rml'
		local tmin `s(tmin)'
		local tmax `s(tmax)'
		local nodes `s(nodes)'
		local quadopt `s(quadopt)'
		local quadtimeN `s(tpoints)'
		
		
		//local nodes : word 1 of `rml'
		//local quadopt : word 2 of `rml'
		tempname knodes kweights
		
 		gaussquad, n(`nodes') `quadopt'
		matrix `knodes' = r(nodes)'
		matrix `kweights' = r(weights)'
		
		qui gen double __tmpKnodes = . 
		
		/* Pass to Mata */
		//qui rcsgen `lnt' if `touse', knots(`e(ln_bhknots_c`n')') gen(_rcs_c`n'_) dgen(_d_rcs_c`n'_) if2(`_d`n'') `e(reverse_c`n')' `rmatrixopt_c`n'' `e(nosecondder_c`n')' `e(nofirstder_c`n')'
		local bhknots = "`e(ln_bhknots_c`k')'"
		/*tempname rml_temp
		mata: rml_setup("`rml_temp'")*/
		
		//mat li `knodes'
		//mat li `kweights'
		
		qui summ `t'
		local Nt = r(N)
		if "`tmax'" == "-99" {
			qui summ `t'
			local tmax = r(max)
		}
		
		qui gen `newvarname'_tbounds = .
		qui gen weights = .
		qui gen index = _n
		//qui drop if index > `nodes'
		
		qui gen `newvarname'_rml = .
		if "`ci'" != "" {
			qui gen `newvarname'_rml_lci = .
			qui gen `newvarname'_rml_uci = .
		}
		foreach n in `causeList' {
			qui gen `newvarname'_c`n' = .
			if "`ci'" != "" {
				qui gen `newvarname'_c`n'_lci = .
				qui gen `newvarname'_c`n'_uci = .
			}
		    if "`stdp'" != "" {
				qui gen `newvarname'_c`n'_se = .
		    }
		}
		//foreach tp in `tmax' {
		
		//save delete, replace
		//exit
		
		
		forvalue r = 1/`Nt' {	
			local maxminusmin2 = (`t'[`r'] - `tmin')/2
			local maxplusmin2 = (`t'[`r'] + `tmin')/2
			
			//di `t'[`r']
			
			tempvar lninttime
			
			local int_c1 `maxminusmin2' 
			
			forvalues m = 1/`nodes' {
				local node`m' = `knodes'[1,`m']
				local weight`m' = `kweights'[1,`m']
				qui replace weights = `weight`m'' if index == `m'
				qui replace `newvarname'_tbounds = (`node`m''*`maxminusmin2') + `maxplusmin2' if index == `m'
			}
			
			qui gen double `lninttime' = ln(`newvarname'_tbounds) if `touse'
			
			local cifxb
			foreach n in `causeList' {
			
					tokenize `e(causeList)'
					forvalues i = 1/`e(n_causes)' {
						if "``i''" == "`n'" {
							local j = `i'
						}
					}
					/* Calculate new spline terms for integration */
					
					//foreach n in `e(causeList)' {
					//if "`timevar'" != "" & "`e(rcsbaseoff_c`n')'" == "" {
							capture drop _rcs_c`n'_* _d_rcs_c`n'_*
							if "`e(orthog)'" != "" {
									tempname rmatrix_c`n'
									matrix `rmatrix_c`n'' = e(R_bh_c`n')
									local rmatrixopt_c`n' rmatrix(`rmatrix_c`n'')
							}
							qui rcsgen `lninttime' if `touse', knots(`e(ln_bhknots_c`n')') gen(_rcs_c`n'_) dgen(_d_rcs_c`n'_) if2(`_d`n'') `e(reverse_c`n')' `rmatrixopt_c`n'' `e(nosecondder_c`n')' `e(nofirstder_c`n')'
							
					//}
					//}
					// save knots from est command and refer to above in knots()
				
				
					/* calculate new spline terms if timevar option, cdiff, hdiff or cdiff option is specified */
					foreach tvcvar in `e(tvc_c`n')' {
						if "`rml'" != "" & "`e(rcsbaseoff_c`n')'" == "" {
							capture drop _rcs_`tvcvar'_c`n'_* _d_rcs_`tvcvar'_c`n'_*
						}			
						/*if (("`shrnumerator'" != "" | "`chrnumerator'" != "" | "`cifdiff1'" != "" | "`hdiff1'" != "") & "`timevar'" == "") | "`e(rcsbaseoff)'" != "" {
							capture drop _rcs_`tvcvar'_c`n'_* _d_rcs_`tvcvar'_c`n'_*
						}*/
						if "`e(orthog)'" != "" {
							tempname rmatrix_`tvcvar'_c`n'
							matrix `rmatrix_`tvcvar'_c`n'' = e(R_`tvcvar'_c`n')
							local rmatrixopt_c`n' rmatrix(`rmatrix_`tvcvar'_c`n'')
						}
						qui rcsgen `lninttime' if `touse',  gen(_rcs_`tvcvar'_c`n'_) knots(`e(ln_tvcknots_`tvcvar'_c`n')') dgen(_d_rcs_`tvcvar'_c`n'_) if2(`_d`n'') `rmatrixopt_c`n'' `e(reverse_c`n')'
						if "`chrnumerator'" == "" & "`shrnumerator'" == "" & "`cifdiff1'"  == "" & "`hdiff1'" == "" {
							forvalues i = 1/`e(df_`tvcvar'_c`n')'{
								qui replace _rcs_`tvcvar'_c`n'_`i' = _rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
								qui replace _d_rcs_`tvcvar'_c`n'_`i' = _d_rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
							}
						}
					}
					
					/* Out of sample predictions using at() */
					if "`at'" != "" {
						tokenize `at'
						while "`1'"!="" {
							fvunab tmpfv: `1'
							local 1 `tmpfv'
							_ms_parse_parts `1'
							if "`r(type)'"!="variable" {
								display as error "level indicators of factor" /*
												*/ " variables may not be individually set" /*
												*/ " with the at() option; set one value" /*
												*/ " for the entire factor variable"
								exit 198
							}
							cap confirm var `2'
							if _rc {
								cap confirm num `2'
								if _rc {
									di as err "invalid at(... `1' `2' ...)"
									exit 198
								}
							}

							qui replace `1' = `2' if `touse'
							if `"`: list posof `"`1'"' in etvc`n''"' != "0" {
								local tvcvar `1'
								if "`e(orthog)'" != "" {
									tempname rmatrix_`tvcvar'_c`n'
									matrix `rmatrix_`tvcvar'_c`n'' = e(R_`tvcvar'_c`n')
									local rmatrixopt_c`n' rmatrix(`rmatrix_`tvcvar'_c`n'')
								}
								capture drop _rcs_`tvcvar'_c`n'_* _d_rcs_`tvcvar'_c`n'_*
								qui rcsgen `lninttime' if `touse', knots(`e(ln_tvcknots_`tvcvar'_c`n')') gen(_rcs_`tvcvar'_c`n'_) dgen(_d_rcs_`tvcvar'_c`n'_) if2(`_d`n'') `rmatrixopt_c`n'' `e(reverse_c`n')'
								forvalues i = 1/`e(df_`tvcvar'_c`n')'{
									qui replace _rcs_`tvcvar'_c`n'_`i' = _rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
									qui replace _d_rcs_`tvcvar'_c`n'_`i' = _d_rcs_`tvcvar'_c`n'_`i'*`tvcvar' if `touse'
								}
							}
							mac shift 2
						}
					}		
		
				//}
				
				/* set up for all cause RML */
				//tempvar st_rml sumcif_rml
				//foreach y in `e(causeList)' {
					//tempvar cifxb_c`y'
					//local j = `j' + 1				
					if "`e(scale)'" =="hazard" {
						local cifxb_c`n' (1 - exp(-exp(xb(#`j')))) 
					}
					if "`e(scale)'" =="odds" {
						local cifxb_c`n' (exp(xb(#`j'))/(1 + exp(xb(#`j'))))
					}
					local cifxb `cifxb' `cifxb_c`n'' +
				//}			
				/**********************************/	
			
				//foreach n in `causeList' {
					if "`ci'" != "" {
						tempvar sxb_c`n'_lci sxb_c`n'_uci
						local prednlopt ci(`sxb_c`n'_lci' `sxb_c`n'_uci')
					}
					else if "`stdp'" != "" {
						tempvar sxb_c`n'_se
						local prednlopt se(`sxb_c`n'_se')
					}		
					/* Transform back */
					if "`e(scale)'" == "hazard" {
						qui predictnl `newvarname'_c`n'_temp = sum(weights*(1 - exp(-exp(xb(#`j')))))*`maxminusmin2' if `touse', `prednlopt' level(`level')  
						qui summ `newvarname'_c`n'_temp
						local value_c`n' r(max)
						qui replace `newvarname'_c`n' = r(max) in `r'
						if "`ci'" != "" {
							qui gen `newvarname'_c`n'_uci_temp = `sxb_c`n'_uci' if `touse'
							qui gen `newvarname'_c`n'_lci_temp = `sxb_c`n'_lci' if `touse'
							qui summ `newvarname'_c`n'_lci_temp
							qui replace `newvarname'_c`n'_lci = r(max) in `r'
							qui summ `newvarname'_c`n'_uci_temp
							qui replace `newvarname'_c`n'_uci = r(max) in `r'
						}
						if "`stdp'" != "" {
							qui gen `newvarname'_c`n'_se_temp = `sxb_c`n'_se' if `touse'
							qui summ `newvarname'_c`n'_se_temp
							qui replace `newvarname'_c`n'_se = r(max) in `r'
						}
					}
					else if "`e(scale)'" == "odds" {
						di "warning: not corrected"
						qui predictnl double `newvarname'_c`n'_`tp' = sum(weights*(exp(xb(#`j'))/(1 +exp(xb(#`j')))))*`maxminusmin2'  if `touse', `prednlopt' level(`level')
						qui summ `newvarname'_c`n'_`tp'
						scalar rmlval_c`n' = r(max)
						local value_c`n' rmlval_c`n'
						if "`ci'" != "" {
							qui gen `newvarname'_c`n'_lci_`tp' = `sxb_c`n'_lci' if `touse'
							qui gen `newvarname'_c`n'_uci_`tp' = `sxb_c`n'_uci' if `touse'
							
							qui summ `newvarname'_c`n'_lci_`tp'
							scalar rmlval_c`n'_lci = r(max)
							local value_c`n'_lci = rmlval_c`n'_lci
							qui summ `newvarname'_c`n'_uci
							scalar rmlval_c`n'_uci = r(max)
							local value_c`n'_uci rmlval_c`n'_uci
						}
						if "`stdp'" != "" {
							qui gen `newvarname'_c`n'_se_`tp' = `sxb_c`n'_se' if `touse'
							
							qui summ `newvarname'_c`n'_se_`tp'
							scalar rmlval_c`n'_se = r(max)
							local value_c`n'_se rmlval_c`n'_se
						}
					}
					/*if "`ci'" == "" & "`stdp'" == "" {
						di in yellow "The expected number of life-years lost before `tmax' years for cause `n' = `value_c`n'' years"
					}
					if "`ci'" != "" {
						di in yellow "The expected number of life-years lost before `tmax' years for cause `n' = `value_c`n''(`value_c`n'_lci', `value_c`n'_uci') years"
					}
					if "`stdp'" != "" {
						di in yellow "The expected number of life-years lost before `tmax' years for cause `n' = `value_c`n''(`value_c`n'_se') years"		
					}*/
					qui capture drop `newvarname'_c`n'_temp
					qui capture drop `newvarname'_c`n'_lci_temp `newvarname'_c`n'_uci_temp
					qui capture drop `newvarname'_c`n'_se_temp
			}
			if "`ci'" != "" {
				local prednlopt_rml ci(`newvarname'_rml_lci_temp `newvarname'_rml_uci_temp)
			}
			else if "`stdp'" != "" {
				local prednlopt_rml se(`newvarname'_rml_se_temp)
			}
			local sumcif_rml `cifxb' 0
			local st_rml (1 - (`cifxb' 0))
			//di "`st_rml'"
			qui predictnl double `newvarname'_rml_temp = sum(weights*(`st_rml'))*`maxminusmin2' if `touse', `prednlopt_rml' level(`level')
			qui summ `newvarname'_rml_temp
			qui replace `newvarname'_rml = r(max) in `r'
			if "`ci'" != "" {
				qui summ `newvarname'_rml_lci_temp
				qui replace `newvarname'_rml_lci = r(max) in `r'
				qui summ `newvarname'_rml_uci_temp
				qui replace `newvarname'_rml_uci = r(max) in `r'
			}

		//exit
		qui drop `newvarname'_rml_temp
		qui capture drop `newvarname'_rml_lci_temp `newvarname'_rml_uci_temp
		qui capture drop `newvarname'_rml_se_temp
		}
	}
	
	foreach n in `causeList' {
		/* Store cause n in keep variable list */
		if "`ci'" != "" { 
			local keepvarname `keepvarname' `newvarname'_c`n'_lci `newvarname'_c`n'_uci
		}
		if "`stdp'" != "" { 
			local keepvarname `keepvarname' `newvarname'_c`n'_se
		}
		
		if "`rml'" != "" { 
			local keepvarname `keepvarname' `newvarname'_rml*
			if "`ci'" != "" { 
				local keepvarname `keepvarname' `newvarname'_rml_lci* `newvarname'_rml_uci*
			}
			if "`stdp'" != "" { 
				local keepvarname `keepvarname' `newvarname'_rml_se*
			}
		}
		
		if "`cured'" != "" {
			local keepvarname `keepvarname' `newvarname'_c`n'
			if "`e(cure_c`n')'" != "" {
				local keepvarname `keepvarname' `newvarname'_c`n'_btd
			}
			local keepvarname_lci `keepvarname_lci' `newvarname'_c`n'_lci
			local keepvarname_uci `keepvarname_uci' `newvarname'_c`n'_uci
			local keepvarname_se `keepvarname_se' `newvarname'_c`n'_se
		} 
		else if "`cured'" == "" {
			local keepvarname `keepvarname' `newvarname'_c`n'*
			local keepvarname_lci `keepvarname_lci' `newvarname'_c`n'_lci
			local keepvarname_uci `keepvarname_uci' `newvarname'_c`n'_uci
			local keepvarname_se `keepvarname_se' `newvarname'_c`n'_se
		}
	}
	
	
	/* restore original data and merge in new variables */
	local keep `keepvarname'
	keep `keep'
	qui save `"`newvars'"'
	restore
	merge 1:1 _n using `"`newvars'"', nogenerate noreport
	
end
	

	
	
	
	
	
	
	
/**** SUBPROGRAMS ****/
/* Program for parsing option within option */
program parse_opt, sclass
    version 15.0
    
    syntax [anything] ///
    [ , ///
        tpoints(string) tmin(int 0) ///
    ]
    tokenize `anything'
    
	if "`tpoints'" == "" {
		sreturn local tmax -99
	}
	else {
		sreturn local tmax `tpoints' 
	}
	
	sreturn local tmin `tmin'
	sreturn local tpoints `tpoints'
	sreturn local nodes `1'
	sreturn local quadopt "leg"
end


/* 
program Parse_list converts the options give in hrnum, hrdenom, hdiff1, hdiff2, sdiff1 and sdiff2 
to factor notation
_varlist contains the variables listed in the predict option
*/
program define Parse_list, rclass
	syntax, listname(string) parselist(string) n(string)
	tokenize `parselist'
	local etvc`n' `e(tvc_c`n')'
	local main_varlist_c`n' `e(varlist_c`n')'
	
	while "`1'"!="" {
		fvunab tmpfv: `1'
		local 1 `tmpfv'
		_ms_parse_parts `1'
		if "`r(type)'"!="variable" {
			display as error "level indicators of factor" /*
							*/ " variables may not be individually set" /*
							*/ " with the `listname'() option; set one value" /*
							*/ " for the entire factor variable"
			exit 198
		}
		cap confirm var `2'
		if _rc {
			cap confirm num `2'
			if _rc {
				if "`2'" != "." {
					di as err "invalid `listname'(... `1' `2' ...)"
					exit 198
				}
			}
		}

		local _varlist_c`n' `_varlist_c`n'' `1'
		
		local `1'_value `2'
		mac shift 2
	}
	_ms_extract_varlist `e(varlist_c`n')', noomitted
	local varlist_omitted_c`n' `r(varlist)' 
	
	/* check if any tvc variables  not in varlist_omitted */
	local tvconly
	foreach tvcvar in `e(tvc_c`n')' {
		mata: st_local("addtvconly",strofreal(subinword(st_local("varlist_omitted_c`n'"),st_local("tvcvar"),"")==st_local("varlist_omitted_c`n'")))
		if `addtvconly' {
			local tvconly `tvconly' `tvcvar'
		}
	}

	
	
	/* loop over all variables in model	*/
	foreach var in `varlist_omitted_c`n'' `tvconly' {
		_ms_parse_parts `var'
		local vartype `r(type)'
		local intmult
		foreach parse_var in `_varlist_c`n'' {
			/* check parse_var in model */
			/*
			_ms_extract_varlist  `parse_var'
			if "`r(varlist)'" == "" {
				display as error "`parse_var' is not included in the model"
				exit 198
			}
			*/
			
			
			* NOW SEE IF MODEL VARIABLE IS LISTED IN PARSE_VAR
			_ms_parse_parts `var'
			local invar 0
			if "`r(k_names)'" == "" {
				if "`r(name)'" == "`parse_var'" {
					local invar 1
				}
			}
			else {
				forvalues i = 1/`r(k_names)' {
					if "`r(name`i')'" == "`parse_var'" {
						local invar 1
					}
				}
			}
			if `invar' {
				if "`vartype'" == "variable" {
					local retlist_c`n' `retlist_c`n'' `var' ``parse_var'_value'
				}
				else if "`vartype'" == "factor" {
					if `r(level)' == ``parse_var'_value' {
						local retlist_c`n' `retlist_c`n'' `var' 1
					}
					else {
						_ms_extract_varlist ``parse_var'_value'.`parse_var'
					}
				}
				else if "`vartype'" == "interaction" {
					if strpos("`var'","`parse_var'") >0 {
							_ms_parse_parts `var'
							forvalues i = 1/`r(k_names)' {
								if "`r(name`i')'" == "`parse_var'" {
									if "`r(op`i')'" == "``parse_var'_value'" {
										local intmult `intmult'*1
									}
									else if "`r(op`i')'" == "c" {
										local intmult `intmult'*`parse_var'
									}
									else {
										local intmult `intmult'*0
									}
								}
							}
					}
					else {
						local intmult `intmult'*0
					}
				}

				else if "`vartype'" == "product" {
						display "products not currently available"
				}
			}
		}
		
		if "`vartype'" == "interaction" { // & `invar' {
			local intmult: subinstr local intmult "*" ""
			if `intmult' != 0 {
				local retlist_c`n' `retlist_c`n'' `var' `intmult'
			}
		}
		return local retlist_c`n' `retlist_c`n''
	}
end

*********************************
* Gaussian quadrature 

program define gaussquad, rclass
        syntax [, N(integer -99) LEGendre CHEB1 CHEB2 HERmite JACobi LAGuerre alpha(real 0) beta(real 0)]
        
    if `n' < 0 {
        display as err "need non-negative number of nodes"
                exit 198
        }
        if wordcount(`"`legendre' `cheb1' `cheb2' `hermite' `jacobi' `laguerre'"') > 1 {
                display as error "You have specified more than one integration option"
                exit 198
        }
        local inttype `legendre'`cheb1'`cheb2'`hermite'`jacobi'`laguerre' 
        if "`inttype'" == "" {
                display as error "You must specify one of the integration type options"
                exit 198
        }

        tempname weights nodes
        mata gq("`weights'","`nodes'")
        return matrix weights = `weights'
        return matrix nodes = `nodes'
end

mata:
        void gq(string scalar weightsname, string scalar nodesname)
{
        n =  strtoreal(st_local("n"))
        inttype = st_local("inttype")
        i = range(1,n,1)'
        i1 = range(1,n-1,1)'
        alpha = strtoreal(st_local("alpha"))
        beta = strtoreal(st_local("beta"))
                
        if(inttype == "legendre") {
                muzero = 2
                a = J(1,n,0)
                b = i1:/sqrt(4 :* i1:^2 :- 1)
        }
        else if(inttype == "cheb1") {
                muzero = pi()
                a = J(1,n,0)
                b = J(1,n-1,0.5)
                b[1] = sqrt(0.5)
    }
        else if(inttype == "cheb2") {
                muzero = pi()/2
                a = J(1,n,0)
                b = J(1,n-1,0.5)
        }
        else if(inttype == "hermite") {
                muzero = sqrt(pi())
                a = J(1,n,0)
                b = sqrt(i1:/2)
        }
        else if(inttype == "jacobi") {
                ab = alpha + beta
                muzero = 2:^(ab :+ 1) :* gamma(alpha :+ 1) * gamma(beta :+ 1):/gamma(ab :+ 2)
                a = i
                a[1] = (beta - alpha):/(ab :+ 2)
                i2 = range(2,n,1)'
                abi = ab :+ (2 :* i2)
                a[i2] = (beta:^2 :- alpha^2):/(abi :- 2):/abi
                b = i1
        b[1] = sqrt(4 * (alpha + 1) * (beta + 1):/(ab :+ 2):^2:/(ab :+ 3))
        i2 = i1[2..n-1]
        abi = ab :+ 2 :* i2
        b[i2] = sqrt(4 :* i2 :* (i2 :+ alpha) :* (i2 :+ beta) :* (i2 :+ ab):/(abi:^2 :- 1):/abi:^2)
        }
        else if(inttype == "laguerre") {
                a = 2 :* i :- 1 :+ alpha
                b = sqrt(i1 :* (i1 :+ alpha))
                muzero = gamma(alpha :+ 1)
    }

        A= diag(a)
        for(j=1;j<=n-1;j++){
                A[j,j+1] = b[j]
                A[j+1,j] = b[j]
        }
        symeigensystem(A,vec,nodes)
        weights = (vec[1,]:^2:*muzero)'
        weights = weights[order(nodes',1)]
        nodes = nodes'[order(nodes',1)']
        st_matrix(weightsname,weights)
        st_matrix(nodesname,nodes)
}
                
end
