*! mcmcsum.ado, Chris Charlton and George Leckie, 17Jun2019
program mcmcsum, rclass
	if _caller() >= 12 version 12.0
	if _caller() <= 9 version 9.0 
	syntax [anything(name=paropts id="parameter list" everything)] ///
		[, ///
			Getchains ///
			Variables ///
			Thinning(int 1) ///
			Eform SQrt MOde MEdian Zratio ///
			Level(cilevel) Width(integer 13) Detail ///
			TRAJectories DENSities FIVEway ///
			CFORMAT(string) PFORMAT(string) SFORMAT(string) ///
			NAME(string) ///
		]
		
	if ("`median'"=="" & "`mode'"=="") local mean "mean"

	if ("`name'"~="") {
		local 0 `name'
		syntax anything(name=graphname), [REPLACE]
		if "`replace'"=="" {
			local graphnameoption "name(`graphname')"
		}
		else {
			local graphnameoption "name(`graphname', replace)"
		}
	}

	if `"`cformat'"' == "" {
		local cformat `c(cformat)'
	}
	if `"`cformat'"' == "" {
		local cformat %9.0g
	}
	if fmtwidth(`"`cformat'"') > 9 {
		local cformat %9.0g
		display as text "note: invalid cformat(), using default"
	}

	if `"`pformat'"' == "" {
		local pformat `c(pformat)'
	}
	if `"`pformat'"' == "" {
		local pformat %5.3f
	}
	if fmtwidth(`"`pformat'"') > 5 {
		local pformat %5.3f
		display as text "note: invalid pformat(), using default"
	}

	if `"`sformat'"' == "" {
		local sformat `c(sformat)'
	}
	if `"`sformat'"' == "" {
		local sformat %8.2f
	}
	if fmtwidth(`"`sformat'"') > 8 {
    		local sformat %8.2f
    		display as text "note: invalid sformat(), using default"
	}

	// Separate off variable list
	// Parse if/in if needed
	local part parnames
	foreach current of local paropts {
		if "`current'" == "if" {
			local part if
			local ifin 1
		}
		else if  "`current'" == "in" {
			local part in
			local ifin 1
		}
		else {
			local `part' ``part'' `current'
		}
	}
	
	if "`if'" ~= "" {
		local if if `if'
	}
	if "`in'" ~= "" {
		local in in `in'
	}	
	
	if "`variables'" ~= "" {
		if "`getchains'" ~= "" {
			display as error "Options variables and getchains cannot be specified at the same time"
			exit 198
		}
		if "`parnames'" == "" local parnames *
		unab parnames: `parnames'
		
		//foreach parameter of local parnames {
		//	capture confirm variable `parameter' // This could take the whole varlist, but then we won't know which variables are invalid
		//	if _rc {
		//		display as error "`parameter' is not a valid variable"
		//		exit 198
		//	}
		//}
	}
	else {
	
	//	KEY:
	//	par = [RP2]var(cons)
	//	col = RP2:var(cons)
	//	var = RP2_var_cons
		******************************************************************************
		* (1) COMMAND SYNTAX CHECKING
		******************************************************************************


		* Check that previous model was an MCMC runmlwin model where the mcmcdiagnostics were saved
		if "`e(cmd)'" ~= "runmlwin" {
			display as error "Estimate results must come from runmlwin"
			exit 198
		}

		if "`e(method)'" ~= "MCMC" {
			display as error "The runmlwin model must be fitted using MCMC" 
			exit 198
		}

		if "`e(mcmcdiagnostics)'" ~= "1" {
			display as error "MCMC diagnostics were not calculated for the previous model"
			exit 198
		}
	}

	* Check that either no options (mcmc summaries) or one option (one of the plots) has been specified.
	local numoptions = 0
	if ("`trajectories'"~="") local numoptions = `numoptions' + 1
	if ("`densities'"~="") 	  local numoptions = `numoptions' + 1
	if ("`fiveway'"~="") 	  local numoptions = `numoptions' + 1
	if ("`getchains'"~="") 	  local numoptions = `numoptions' + 1
	if ("`detail'"~="") 	  local numoptions = `numoptions' + 1
	if (`numoptions'>1) {
		display as error "Specify only one of the following options: trajectories, densities, fiveway, getchains"
		exit 198
	}
	
	* Check that only one parameter has been requested if a fiveway plot has been requested
	if ("`fiveway'"~="") {
		if `:list sizeof parnames' ~= 1 {
			display as error "Specify only one parameter for the fiveway MCMC plot"
			exit 198
		}
	}

	* Specify that MCMC summaries is requested if no plotting options have been specified
	if (`numoptions'==0) local summaries summaries




	if "`variables'" ~= "" {
		local colnames `parnames'
		local varnames `parnames'
	}
	else {
	
		******************************************************************************
		* (2) CONVERT PARAMETER NAMES TO MATRIX COLUMN NAMES AND VARIABLE NAMES
		******************************************************************************

		* Valid matrix column parameter names and variable names
		local validcolnames :colfullnames e(b)
		local validparnames 
		foreach validcol of local validcolnames {
			local par [`=subinstr("`validcol'",":","]",.)'
			local validparnames `validparnames' `par'
		}
		local validvarnames
		foreach validcol of local validcolnames {
			if _caller() >= 11 {
				local validvar `=strtoname("`validcol'")'
			}
			else {
				mata: st_local("validvar", validname("`validcol'"))
				local validvar `=abbrev("`validvar'", 32)'
			}
			local validvarnames `validvarnames' `validvar'
		}

		* If not parameters have been specified then assume user wanted all parameters	
		if ("`parnames'"=="") {
			local parnames `validparnames'
			if "`trajectories'"~="" {
				local parnames deviance `parnames'
			}			
		}
		



		* Convert the requested parameter names into e(b) matrix column names
		local colnames
		local varnames
		foreach par of local parnames {	
			if "`par'" ~= "deviance" {
				local col `par'
				local col `=subinstr("`col'","[","",.)'
				local col `=subinstr("`col'","]",":",.)'
				if _caller() >= 11 {
					local var `=strtoname("`col'")'
				}
				else {
					mata: st_local("var", validname("`col'"))
					local var `=abbrev("`var'", 32)'
				}
				if ~`:list col in validcolnames' {
					local found = 0
					foreach poscol of local validcolnames {
						if _caller() >= 11 {
							if "`col'"=="`=strtoname("`poscol'")'" {
								local col `poscol'
								local found = 1
								break
							}
						}
						else {
							mata: st_local("tmpname", validname("`poscol'"))
							local tmpname `=abbrev("`tmpname'", 32)'
							if "`col'"=="`tmpname'" {
								local col `poscol'
								local found = 1
								break
							}
						}
					}
					if "`found'"=="0" {
						display as txt "`col' does not appear in the model. See mat list e(b)"
						exit 198
					}
				}
			}
			else {
				if "`trajectories'"=="" {
					display as error "deviance only allowed for trajectories plot"
					exit 198
				}
				local col `par'
				local var `par'
			}
			local colnames `colnames' `col'
			local varnames `varnames' `var'
		}
	}
	

	// Not actually needed for summaries based on ereturn or trajectories on the currently loaded data set, or for getchains
	preserve
	
	if "`variables'" == "" & ("`ifin'" == "1" | "`eform'" ~= "" | "`sqrt'" ~= "" | "`levels'" ~= "`e(level)'") { // Diagnostics will need to be recalculated
		drop _all
		label drop _all
		
		if _caller() >= 11.1 {
			getmata (iteration `validvarnames' deviance) = `e(chains)'	
		}
		else {
			local tmpnames
			mata: (void) st_addvar("double", "iteration")
			foreach tmpname of local validvarnames {
				mata: st_local("tmpname", validname("`tmpname'"))
				local tmpname `=abbrev("`tmpname'", 32)'
				mata: (void) st_addvar("double", "`tmpname'")
				local tmpnames `tmpnames', "`tmpname'"
			}
			mata: (void) st_addvar("double", "deviance")			
			mata: st_addobs(rows(`e(chains)'))
			mata: st_store(., ("iteration" `tmpnames', "deviance"), `e(chains)')		
		}
				
		local variables variables
		local thinning = e(thinning)
		local colnames `varnames'
		tempfile filechains
		quietly saveold "`filechains'"
	}
	
	if "`variables'" ~= "" {
		if "`eform'" ~= "" {
			foreach tmpname of local colnames {
				quietly replace `tmpname' = exp(`tmpname')
			}
		}
		
		if "`sqrt'" ~= "" {
			foreach tmpname of local colnames {
				quietly replace `tmpname' = sqrt(`tmpname')
			}
		}
	}

	
	
	******************************************************************************
	* (3) MCMC SUMMARY TABLE	
	******************************************************************************
	
	//if ("`detail'"=="") {
	if "`summaries'" ~= "" {
		* Display the MCMC summary statistics and diagnostics
		local i = 1
		local multiplier = invnormal(1 - ((100 - `level')/2)/100) // returns 1.96 if 95% confidence intervals are requested
		local kk = length("`level'") // as in 95 is two characters but 7 is only 1 character
	
		display as txt "{hline `width'}{c TT}{hline 64}"
		display as txt _col(`=`width' + 1') "{c |}" _continue
		if "`mean'" ~= "" display as txt _col(21) "Mean" _continue
		if "`median'" ~= "" display as txt _col(21) "Median" _continue
		if "`mode'" ~= "" display as txt _col(21) "Mode" _continue
		display as txt _col(29) "Std. Dev." _continue
		if "`zratio'" ~= "" {
			display as txt _col(44) "z" _continue
			display as txt _col(49) "P>|z|" _continue
		}
		else {
			display as txt _col(43) "ESS" _continue
			display as txt _col(51) "P" _continue
		}
		display as txt _col(`=61 -`kk'') `"[`=strsubdp("`level'")'% Cred. Interval]"'
		display as txt "{hline `width'}{c +}{hline 64}"	
		
		foreach col of local colnames {
			if "`variables'" ~= "" {
				local posit = 0
				if regexm("`col'", "RP[0-9]+_var_([a-zA-Z0-9_]+)_") == 1 {
					local posit = 1
				}
			
			
				quietly runmlwin_mcmcdiag `col' `if' `in',  thinning(`thinning') posit(`posit') level(`level') `options' `eform'
			
				local MATstats quantiles BD RL1 RL2 lb ub ESS meanmcse	
				foreach stat of local MATstats {
					local `=lower("`stat'")' r(`stat')
				}
				local modeval = r(mode)
				tempname quantiles
				matrix `quantiles' = r(quantiles)
				local numquants = rowsof(r(quantiles))
				local quantcol = 2
				local b = r(mean)
				local V = r(sd)*r(sd)
				local meanval = `b'
				local sdval = sqrt(`V')	
				local thinnedchain = r(N) // This may need to be adjusted if thinning is specified
				local pvalmean = r(pvalmean)
				local pvalmode = r(pvalmode)
				local pvalmedian = r(pvalmedian)
			}			
			else {
				* Pull all statistics back from ereturn
				local MATstats b quantiles bd rl1 rl2 lb ub ess meanmcse pvalmean pvalmode pvalmedian
				tempname MATstat
				foreach stat of local MATstats {
					matrix `MATstat' = e(`stat')
					matrix `MATstat' = `MATstat'[1,"`col'"]
					local `stat' = `MATstat'[1,1]
				}
				matrix `MATstat' = e(mode)
				matrix `MATstat'= `MATstat'[1,"`col'"]
				local modeval = `MATstat'[1,1]
				matrix `MATstat' = e(V)
				matrix `MATstat' = `MATstat'["`col'","`col'"]
				local V = `MATstat'[1,1]
				local meanval = `b'
				local sdval = sqrt(`V')				
				tempname quantiles
				matrix `quantiles' = e(quantiles)
				local numquants = rowsof(e(quantiles))
				local quantcol = colnumb(e(quantiles),"`col'")
				local thinnedchain = floor(e(chain)/e(thinning))
			}

			local rllb = `rl1'
			local rlub = `rl2'
			
			local currentpar = word("`parnames'", 1)
			local parnames :list parnames - currentpar

			local par = abbrev("`currentpar'", `width')
			local p = `width' - length("`par'")
			display as txt _col(`p') "`par'" _continue
			display as txt _col(`=`width' + 1') "{c |}" _continue
			if "`mean'" ~= "" display as res _col(17) `cformat' `meanval' _continue
			if "`median'" ~= "" display as res _col(17) `cformat' `quantiles'[5, `quantcol'] _continue
			if "`mode'" ~= "" display as res _col(17) `cformat' `modeval' _continue
			display as res _col(28) `cformat' `sdval' _continue
			if "`zratio'" ~= "" {
				display as res _col(36) `sformat' `meanval'/`sdval' _continue
				display as res _col(49) `pformat' 2*normal(-abs(`meanval'/`sdval')) _continue
			}
			else {
				display as res _col(36) %9.0f `ess' _continue
				if "`mean'" ~= "" display as res _col(49) `pformat' `pvalmean' _continue
				if "`median'" ~= "" display as res _col(49) `pformat' `pvalmedian' _continue
				if "`mode'" ~= "" display as res _col(49) `pformat' `pvalmode' _continue			
			}
			display as res _col(58) `cformat' `lb' _continue
			display as res _col(70) `cformat' `ub' 


			local ++i


			return scalar bd           = `bd'
			return scalar rlub         = `rlub'
			return scalar rllb         = `rllb'
			return scalar ess          = `ess'
			return scalar thinnedchain = `thinnedchain'
			return scalar p99_5        = `quantiles'[9, `quantcol']
			return scalar p97_5        = `quantiles'[8, `quantcol']
			return scalar p95          = `quantiles'[7, `quantcol']
			return scalar p75          = `quantiles'[6, `quantcol']
			return scalar p50          = `quantiles'[5, `quantcol']
			return scalar p25          = `quantiles'[4, `quantcol']
			return scalar p5           = `quantiles'[3, `quantcol']
			return scalar p2_5         = `quantiles'[2, `quantcol']
			return scalar p0_5         = `quantiles'[1, `quantcol']
			return scalar mode         = `modeval'
			return scalar sd           = `sdval'
			return scalar meanmcse     = `meanmcse'
			return scalar mean         = `meanval'

		}
		display as txt "{hline `width'}{c BT}{hline 64}"		
	}	
	

	******************************************************************************
	* (3) MCMC SUMMARY TABLE	
	******************************************************************************
	
	if "`detail'" ~= "" {
		* Display the MCMC summary statistics and diagnostics
		local i = 1
		foreach col of local colnames {
			if "`variables'" ~= "" {
				local posit = 0
				if regexm("`col'", "RP[0-9]+_var_([a-zA-Z0-9_]+)_") == 1 {
					local posit = 1
				}
			
				quietly runmlwin_mcmcdiag `col' `if' `in', thinning(`thinning') posit(`posit') `options' `eform'
				local MATstats quantiles BD RL1 RL2 lb ub ESS meanmcse	
				foreach stat of local MATstats {
					local `=lower("`stat'")' r(`stat')
				}
				local modeval r(mode)
				tempname quantiles
				matrix `quantiles' = r(quantiles)
				local numquants = rowsof(r(quantiles))
				local quantcol = 2
				local b = r(mean)
				local V = r(sd)*r(sd)
				local meanval = `b'
				local sdval   = sqrt(`V')	
				local thinnedchain = r(N) // This may need to be adjusted if thinning is specified
				local pvalmean = r(pvalmean)
				local pvalmode = r(pvalmode)
				local pvalmedian = r(pvalmedian)
			}			
			else {
				* Pull all statistics back from ereturn
				local MATstats b quantiles bd rl1 rl2 lb ub ess meanmcse pvalmean pvalmode pvalmedian
				tempname MATstat
				foreach stat of local MATstats {
					matrix `MATstat' = e(`stat')
					matrix `MATstat' = `MATstat'[1,"`col'"]
					local `stat' = `MATstat'[1,1]
				}
				matrix `MATstat' = e(mode)
				matrix `MATstat' = `MATstat'[1,"`col'"]
				local modeval = `MATstat'[1,1]

				matrix `MATstat' = e(V)
				matrix `MATstat' = `MATstat'["`col'","`col'"]
				local V `MATstat'[1,1]
				local meanval = `b'
				local sdval   = sqrt(`V')				
				tempname quantiles
				matrix `quantiles' = e(quantiles)
				local numquants = rowsof(e(quantiles))
				local quantcol = colnumb(e(quantiles),"`col'")
				local thinnedchain = floor(e(chain)/e(thinning))
			}

			local rllb = `rl1'
			local rlub = `rl2'
			
			local currentpar = word("`parnames'", 1)
			local parnames :list parnames - currentpar


			//         1         2         3         4         5         6         7
			//1234567890123456789012345678901234567890123456789012345678901234567890123456789
			//                              [RP2]var(cons)
			//------------------------------------------------------------------------------
			//                                Percentiles
			//Chain length #########       1%  #########     Raftery Lewis ( 2.5%) #########
			//ESS          #########     2.5%  #########     Raftery Lewis (97.5%) #########
			//                             5%  ######### 
			//                            25%  ######### 
			//
			//                            50%  #########
			//
			//Mean         #########      75%  #########     Brooks Draper (mean)  #########
			//MCSE of mean #########      95%  #########
			//Std. Dev.    #########    97.5%  ######### 
			//Mode         #########      99%  #########
			//------------------------------------------------------------------------------
			local title_col = floor(78/2 - length("`col'")/2)
			display _n(1) _col(`title_col') as txt "`currentpar'"
			display as txt "{hline 78}"
			display as txt _col(33) "Percentiles"
			display as txt "Mean"           _col(14) as res `cformat' `meanval'	 _col(27) as txt %4.1f = 100*`=`quantiles'[1, 1]' "%" _col(34) as result `cformat' `quantiles'[1, `quantcol'] _col(48) as txt "Thinned Chain Length"  _col(70) as res %9.0g `thinnedchain'
			display as txt "MCSE of Mean"   _col(14) as res `cformat' `meanmcse' _col(27) as txt %4.1f = 100*`=`quantiles'[2, 1]' "%" _col(34) as result `cformat' `quantiles'[2, `quantcol'] _col(48) as txt "Effective Sample Size" _col(70) as res %9.0g `ess'
			display as txt "Std. Dev."      _col(14) as res `cformat' sqrt(`V')  _col(27) as txt %4.0f = 100*`=`quantiles'[3, 1]' "%" _col(34) as result `cformat' `quantiles'[3, `quantcol'] _col(48) as txt "Raftery Lewis (2.5%)"  _col(70) as res %9.0g `rllb'
			display as txt "Mode"           _col(14) as res `cformat' `modeval'	 _col(27) as txt %4.0f = 100*`=`quantiles'[4, 1]' "%" _col(34) as result `cformat' `quantiles'[4, `quantcol'] _col(48) as txt "Raftery Lewis (97.5%)" _col(70) as res %9.0g `rlub'
			display as txt "P(mean)"        _col(14) as res `pformat' `pvalmean'                                                                                                          _col(48) as txt "Brooks Draper (mean)"  _col(70) as res %9.0g `bd'
			display as txt "P(mode)"        _col(14) as res `pformat' `pvalmode' _col(27) as txt %4.0f = 100*`=`quantiles'[5, 1]' "%" _col(34) as result `cformat' `quantiles'[5, `quantcol'] _col(48)
			display as txt "P(median)"      _col(14) as res `pformat' `pvalmedian'
			display as txt                                                   _col(27) as txt %4.0f = 100*`=`quantiles'[6, 1]' "%" _col(34) as result `cformat' `quantiles'[6, `quantcol'] _col(48) 
			display as txt                                                   _col(27) as txt %4.0f = 100*`=`quantiles'[7, 1]' "%" _col(34) as result `cformat' `quantiles'[7, `quantcol'] _col(48)
			display as txt                                                   _col(27) as txt %4.1f = 100*`=`quantiles'[8, 1]' "%" _col(34) as result `cformat' `quantiles'[8, `quantcol'] _col(48)
			display as txt                                                   _col(27) as txt %4.1f = 100*`=`quantiles'[9, 1]' "%" _col(34) as result `cformat' `quantiles'[9, `quantcol'] _col(48)

			local i = `i' + 1


			return scalar bd           = `bd'
			return scalar rlub         = `rlub'
			return scalar rllb         = `rllb'
			return scalar ess          = `ess'
			return scalar thinnedchain = `thinnedchain'
			return scalar p99_5        = `quantiles'[9, `quantcol']
			return scalar p97_5        = `quantiles'[8, `quantcol']
			return scalar p95          = `quantiles'[7, `quantcol']
			return scalar p75          = `quantiles'[6, `quantcol']
			return scalar p50          = `quantiles'[5, `quantcol']
			return scalar p25          = `quantiles'[4, `quantcol']
			return scalar p5           = `quantiles'[3, `quantcol']
			return scalar p2_5         = `quantiles'[2, `quantcol']
			return scalar p0_5         = `quantiles'[1, `quantcol']
			return scalar mode         = `modeval'
			return scalar sd           = `sdval'
			return scalar meanmcse     = `meanmcse'
			return scalar mean         = `meanval'

		}
		display as txt "{hline 78}"
	}


	
	******************************************************************************
	* (4) MCMC TRAJECTORIES WINDOW
	******************************************************************************
	
	if ("`trajectories'"~="") {
		if "`variables'" ~= "" {
			tempvar itervar
			quietly gen `itervar' = _n * `thinning' `if' `in'
		}
		else {
			drop _all
			label drop _all
			if _caller() >= 11.1 {
				getmata (iteration `validvarnames' deviance) = `e(chains)'	
			}
			else {
				local tmpnames
				mata: (void) st_addvar("double", "iteration")
				foreach tmpname of local validvarnames {
					mata: st_local("tmpname", validname("`tmpname'"))
					local tmpname `=abbrev("`tmpname'", 32)'
					mata: (void) st_addvar("double", "`tmpname'")
					local tmpnames `tmpnames', "`tmpname'"
				}
				mata: (void) st_addvar("double", "deviance")
				mata: st_addobs(rows(`e(chains)'))
				mata: st_store(., ("iteration" `tmpnames', "deviance"), `e(chains)')			
			}
			local itervar iteration
		}
		
		local i = 1
		local grlist
		foreach var of local varnames {
			tempname gr`i'
			local col = word("`colnames'",`i')
			
			if "`var'" ~= "deviance" {
				if "`variables'" ~= "" {
					local posit = 0
					if regexm("`col'", "RP[0-9]+_var_([a-zA-Z0-9_]+)_") == 1 {
						local posit = 1
					}				
					quietly runmlwin_mcmcdiag `col' `if' `in', thinning(`thinning') posit(`posit') `options' `eform'
					local lb = r(lb)
					local ub = r(ub)
				}
				else {
					tempname MATlb MATub
					mat `MATlb' = e(lb)
					mat `MATlb' = `MATlb'[1,"`col'"]
					local lb = `MATlb'[1,1]
					mat `MATub' = e(ub)
					mat `MATub' = `MATub'[1,"`col'"]
					local ub = `MATub'[1,1]
				}
			}
			else {
				local lb = 0
				local ub = 0
			}

			local par = word("`parnames'",`i')
			twoway (line `var' `itervar'), ///
				yline(`lb' `ub', lpattern(shortdash) lstyle(p2)) ///
				ytitle("`par'") xtitle("Iteration") ///
				ylabel(, angle(0)) ///
				nodraw name(`gr`i'')	
			local grlist `grlist' `gr`i''
			local i = `i' + 1
		}
		graph combine `grlist', iscale(*.8) xcommon `options' `graphnameoption'
	}




	******************************************************************************
	* (5) MCMC DENSITY WINDOW
	******************************************************************************
	if ("`densities'"~="") {
		local i = 1
		local grlist
		foreach col of local colnames {
			tempname gr`i'
			local par = word("`parnames'",`i')
			tempname KD_yvar
			tempname KD_xvar			
			mata: `KD_yvar' = J(1000, 1, .)
			mata: `KD_xvar' = J(1000, 1, .)
				
			if "`variables'" ~= "" {	
				local posit = 0
				if regexm("`col'", "RP[0-9]+_var_([a-zA-Z0-9_]+)_") == 1 {
					local posit = 1
				}				
				quietly runmlwin_mcmcdiag `col' `if' `in', thinning(`thinning') posit(`posit') `options' `eform'
				local lb = r(lb)
				local ub = r(ub)
				mata: `KD_yvar'[1..., 1] = st_matrix("r(KD)")[1..., 1]
				mata: `KD_xvar'[1..., 1] = st_matrix("r(KD)")[1..., 2]					
			}
			else {
				tempname MATlb MATub
				mat `MATlb' = e(lb)
				mat `MATlb' = `MATlb'[1,"`col'"]
				local lb = `MATlb'[1,1]
				mat `MATub' = e(ub)
				mat `MATub' = `MATub'[1,"`col'"]
				local ub = `MATub'[1,1]

				mata: `KD_yvar'[1..., 1] = st_matrix("e(KD1)")[1..., `=colnumb(e(KD1), "`col'")']
				mata: `KD_xvar'[1..., 1] = st_matrix("e(KD2)")[1..., `=colnumb(e(KD2), "`col'")']
			}

			drop _all
			label drop _all				
			if _caller() >= 11.1 {
				getmata `KD_yvar'
				getmata `KD_xvar'
			}
			else {
				mata: (void) st_addvar("double", "`KD_yvar'")
				mata: (void) st_addvar("double", "`KD_xvar'")
				mata: st_addobs(length(`KD_yvar'))
				mata: st_store(., "`KD_yvar'", `KD_yvar')
				mata: st_store(., "`KD_xvar'", `KD_xvar')
			}
			
			mata: mata drop `KD_yvar'
			mata: mata drop `KD_xvar'				
			
			twoway (line `KD_yvar' `KD_xvar'), ///
				xline(`lb' `ub', lpattern(shortdash) lstyle(p2)) ///
				ytitle("Kernel density") xtitle("`par'") ///
				ylabel(, angle(0)) ///
				nodraw name(`gr`i'')
			
			local grlist `grlist' `gr`i''
			local i = `i' + 1
			if "`variables'" ~= "" { // Reload initial data (currently breaks recalculating from chains)
				if "`filechains'" == "" {
					restore, preserve
				}
				else {
					use "`filechains'", clear
				}
			}				
		}
		graph combine `grlist',iscale(*.8) `options' `graphnameoption'
	}





	******************************************************************************
	* (6) MCMC FIVEWAY WINDOW
	******************************************************************************
	if ("`fiveway'"~="") {
		local par `parnames'
		local var `varnames'
		
		tempname KD_yvar
		tempname KD_xvar		
		tempname ACF_yvar
		tempname ACF_xvar
		tempname PACF_yvar
		tempname PACF_xvar
		tempname MCSE_yvar
		tempname MCSE_xvar
		
		mata: `KD_yvar' = J(1000, 1, .)
		mata: `KD_xvar' = J(1000, 1, .)			
		mata: `MCSE_yvar' = J(1000, 1, .)
		mata: `MCSE_xvar' = J(1000, 1, .)
		
		if "`variables'" ~= "" {
			local posit = 0
			if regexm("`var'", "RP[0-9]+_var_([a-zA-Z0-9_]+)_") == 1 {
				local posit = 1
			}			
			quietly runmlwin_mcmcdiag `var' `if' `in', thinning(`thinning') posit(`posit') `options' `eform'

			local lb = r(lb)
			local ub = r(ub)			
			mata: `KD_yvar'[1..., 1] = st_matrix("r(KD)")[1..., 1]
			mata: `KD_xvar'[1..., 1] = st_matrix("r(KD)")[1..., 2]
			matrix `ACF_yvar' = r(ACF)
			matrix `ACF_xvar' = r(ACF)
			matrix `ACF_yvar' = `ACF_yvar'[1..., 1]
			matrix `ACF_xvar' = `ACF_xvar'[1..., 2]	
			matrix `PACF_yvar' = r(PACF)
			matrix `PACF_xvar' = r(PACF)			
			matrix `PACF_yvar' = `PACF_yvar'[1..., 1]
			matrix `PACF_xvar' = `PACF_xvar'[1..., 2]	
			mata: `MCSE_yvar'[1..., 1] = st_matrix("r(MCSE)")[1..., 1]
			mata: `MCSE_xvar'[1..., 1] = st_matrix("r(MCSE)")[1..., 2]				
		}
		else {
			tempname MATlb MATub
			mat `MATlb' = e(lb)
			mat `MATlb' = `MATlb'[1,"`col'"]
			local lb = `MATlb'[1,1]
			mat `MATub' = e(ub)
			mat `MATub' = `MATub'[1,"`col'"]
			local ub = `MATub'[1,1]
			mata: `KD_yvar'[1..., 1] = st_matrix("e(KD1)")[1..., `=colnumb(e(KD1), "`col'")']
			mata: `KD_xvar'[1..., 1] = st_matrix("e(KD2)")[1..., `=colnumb(e(KD2), "`col'")']				
			matrix `ACF_yvar' = e(ACF)
			matrix `ACF_xvar' = e(ACF)			
			matrix `ACF_yvar' = `ACF_yvar'[1..., "`col'"]
			matrix `ACF_xvar' = `ACF_xvar'[1...,1]		
			matrix `PACF_yvar' = e(PACF)
			matrix `PACF_xvar' = e(PACF)			
			matrix `PACF_yvar' = `PACF_yvar'[1..., "`col'"]
			matrix `PACF_xvar' = `PACF_xvar'[1...,1]	
			mata: `MCSE_yvar'[1..., 1] = st_matrix("e(MCSE)")[1..., `=colnumb(e(MCSE), "`col'")']
			mata: `MCSE_xvar'[1..., 1] = st_matrix("e(MCSE)")[1..., 1]				
		}


		tempname gr1 gr2 gr3 gr4 gr5

		**************************************
		* (a) Trajectory
		**************************************
	
		if "`variables'" ~= "" {
			tempvar itervar
			quietly gen `itervar' = _n * `thinning'	`if' `in'
		}
		else {
			drop _all
			label drop _all
			if _caller() >= 11.1 {
				getmata (iteration `validvarnames' deviance) = `e(chains)'	
			}
			else {
				local tmpnames
				mata: (void) st_addvar("double", "iteration")
				foreach tmpname of local validvarnames {
					mata: st_local("tmpname", validname("`tmpname'"))
					local tmpname `=abbrev("`tmpname'", 32)'
					mata: (void) st_addvar("double", "`tmpname'")
					local tmpnames `tmpnames', "`tmpname'"
				}
				mata: (void) st_addvar("double", "deviance")
				mata: st_addobs(rows(`e(chains)'))
				mata: st_store(., ("iteration" `tmpnames', "deviance"), `e(chains)')			
			}
			local itervar iteration
		}

		line `var' `itervar', ///
			yline(`lb' `ub', lpattern(shortdash) lstyle(p2)) ///
			ytitle("`par'") xtitle("Iteration") ///
			ylabel(, angle(0)) ///
			nodraw name(`gr1')

		**************************************
		* (b) Kernel density
		**************************************
		
		drop _all
		label drop _all
		
		if _caller() >= 11.1 {
			getmata `KD_yvar'
			getmata `KD_xvar'
		}
		else {
			mata: (void) st_addvar("double", "`KD_yvar'")
			mata: (void) st_addvar("double", "`KD_xvar'")
			mata: st_addobs(length(`KD_yvar'))
			mata: st_store(., "`KD_yvar'", `KD_yvar')
			mata: st_store(., "`KD_xvar'", `KD_xvar')
		}

		line `KD_yvar' `KD_xvar', ///
			xline(`lb' `ub', lpattern(shortdash) lstyle(p2)) ///
			ytitle("Kernel density") xtitle("`par'") ///
			ylabel(, angle(0)) ///
			nodraw name(`gr2')
	
		**************************************
		* (c) ACF
		**************************************
		svmat `ACF_yvar'
		svmat `ACF_xvar'

		twoway dropline `ACF_yvar'1 `ACF_xvar'1, msymbol(i) ///
			ytitle("ACF") xtitle("Lag") ///
			yscale(range(-.05 1)) ///
			ylabel(0(.2)1, angle(0)) ///
			nodraw name(`gr3')

		**************************************
		* (d) PACF
		**************************************

		svmat `PACF_yvar'
		svmat `PACF_xvar'

		twoway dropline `PACF_yvar'1 `PACF_xvar'1, msymbol(i) ///
			ytitle("PACF") xtitle("Lag") ///
			yscale(range(-.05 1)) ///
			ylabel(0(.2)1, angle(0)) xlabel(1(1)10) ///
			nodraw name(`gr4')

		**************************************
		* (e) MCSE
		**************************************

		drop _all
		label drop _all			
		if _caller() >= 11.1 {
			getmata `MCSE_yvar'
			getmata `MCSE_xvar'
		}
		else {
			mata: (void) st_addvar("double", "`MCSE_yvar'")
			mata: (void) st_addvar("double", "`MCSE_xvar'")
			mata: st_addobs(length(`MCSE_yvar'))
			mata: st_store(., "`MCSE_yvar'", `MCSE_yvar')
			mata: st_store(., "`MCSE_xvar'", `MCSE_xvar')
		}			
		
		mata: mata drop `MCSE_yvar'
		mata: mata drop `MCSE_xvar'
	
		line `MCSE_yvar' `MCSE_xvar', ///
			ytitle("MCSE of posterior mean") xtitle("Iteration") ///
			ylabel(, angle(0)) ///
			nodraw name(`gr5')


		**************************************
		* (f) COMBINE ALL FIVE GRAPHS
		**************************************
		graph combine `gr1' `gr2' `gr3' `gr4' `gr5', row(3) iscale(*.8) `options' `graphnameoption'
	}
	
	restore

	*****************************************************************************
	* (7) GET CHAINS
	*****************************************************************************
	if ("`getchains'"~="") {
		drop _all
		label drop _all	
		if _caller() >= 11.1 {
			getmata (iteration `validvarnames' deviance) = `e(chains)'	
		}
		else {
			local tmpnames
			mata: (void) st_addvar("double", "iteration")
			foreach tmpname of local validvarnames {
				mata: st_local("tmpname", validname("`tmpname'"))
				local tmpname `=abbrev("`tmpname'", 32)'
				mata: (void) st_addvar("double", "`tmpname'")
				local tmpnames `tmpnames', "`tmpname'"
			}
			mata: (void) st_addvar("double", "deviance")
			mata: st_addobs(rows(`e(chains)'))
			mata: st_store(., ("iteration" `tmpnames', "deviance"), `e(chains)')			
		}

		foreach var of local validvarnames {
			if ~`:list var in varnames' {
				drop `var'
			}
		}
	}
	
end

mata:
	
	string scalar validname(string scalar name) {
		real rowvector codes;
		real rowvector valid;
		
		codes = ascii(name);
		if (codes[1] >=48 && codes[1] <= 57) {
			codes = 95,codes;
		}
		valid = ((codes:<65 :| codes:>90) :& (codes:<97 :| codes:>122) :& (codes:<48 :| codes:>57))
		for (i = 1; i <= length(codes); i++) {
			if (valid[i] == 1) {
				codes[i] = 95;
			}
		}
		// The following code would truncate to 32 characters
		/*
		if (length(codes) > 32) {
			codes = codes[|1\32|];
		}
		*/
		name = char(codes);
		return(name);
	}	
end

