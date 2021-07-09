capture program drop iimpute_body
program define iimpute_body
	version 9.0
	syntax varlist, ///
		[additional(varlist)] contextvar(varname) [rangemin(integer 999999999)] [rangemax(integer -999999999)] ///
		imputeprefix(name) missingflagprefix(name) missingcountname(name) missingimputedcountname(name) ///
		limitdiag(integer) [ROUnd] [NOInflate] [log]
		
	// from string to genuine list
	//local thePTVs = "`varlist'"
	local thePTVs `varlist'
	
	/*
		incremental simple imputation:
			select cases with 1 missing PTV, impute that PTV (starting from PTVS with less missing cases...);
				cases with 2, etc..., until you reach cases with all PTVs missing
			on PTVs in imputed cases, add random noise so that variance equals variance in other cases
	*/		
	
	
	
	set more off
	
	local imputedvars
	
	display "Creating new variables..."
	
	foreach var of varlist `thePTVs' {
		//capture drop `imputeprefix'`var'
		//capture drop `missingflagprefix'`var'
	
		quietly clonevar `imputeprefix'`var' = `var' 
		local imputedvars `imputedvars' `imputeprefix'`var'
		local varlab : variable label `var'
		local newlab = "* IMPUTED * " + "`varlab'"
		label variable `imputeprefix'`var' "`newlab'"
	}
	
	foreach var of varlist `thePTVs' {
		quietly generate `missingflagprefix'`var' = missing(`var')
		capture label var `missingflagprefix'`var' "Was `var' originally missing?"
	}
	
	
	// loads all values of the context variable
	quietly levelsof `contextvar', local(contexts)
	
	/*
	 * store number of missing PTVs, depending on how many were really asked in each context
	 */
	
	local ncontexts : list sizeof contexts
	
	local nptvs: list sizeof varlist
	local nadd: list sizeof additional

	if (`nptvs' + `nadd' > 30) {
		if (`nptvs' > 30) {
			display "More than 30 variables were required to be imputed."
			exit
		}
		else {
			local newaddcount = 30 - `nadd'
			local newadditional
			local count = 0
			display "WARNING: Restricting additional variables to `newaddcount' to satisfy the 30-variable limit:"
			foreach var of varlist `additional' {
				local newadditional `newadditional' `var'
				local count = `count' + 1
				if (`count' >= `newaddcount') continue, break
			}
			display "{text}{pstd}restricting from {bf:`additional'} to {bf:`newadditional'}"
			display ""
			local additional `newadditional'
		}
	}
	
	local thisContext = 0
	
	display "Looping over contexts..."

	// loops over all contexts
	foreach context in `contexts' {	
	
		local contextLabel : label (`contextvar') `context'
		
		local thisContext = `thisContext' + 1
		
		local showDiag = 1
		local showMode = "noisily"
		
		if ((`limitdiag'>-1) & (`thisContext' > `limitdiag')) {
			local showDiag = 0
			local showMode = "quietly"
		}
		
		// count observations in this context
		quietly count if `contextvar'==`context'
		quietly return list
		local numobs = r(N)
		
		local countUsedPTVs = 0
		local usedPTVs
		local countPTVs = 0

		local ctximputedvars

		
		// loops over all PTVs
		foreach var of varlist `thePTVs' {
			
			// count missing values for this PTV within this context
			quietly count if missing(`var') & `contextvar'==`context'
			quietly return list
			local missingptvs = r(N)
			
			
			// if no. of missing values less than no. of observations, this PTV is used
			if `missingptvs'<`numobs' {
				local countUsedPTVs = `countUsedPTVs' + 1
				local usedPTVs `usedPTVs' `var'
				local ctximputedvars `ctximputedvars' `imputeprefix'`var'
			}
			local countPTVs = `countPTVs' + 1
		}

		local countUnusedPTVs = `countPTVs' - `countUsedPTVs'
		//local usedPTVs = trim("`usedPTVs'")
		
		if (`ncontexts' > 1) {
			display "{text}{pstd}Context {result:`context'} ({result:`contextLabel'}) uses "
		}
		else {
			display "{text}{pstd}"
		}
		display "{result:`countUsedPTVs'} items" " " "({result:" trim("`usedPTVs'") "})...{break}"
		
		
		quietly replace `missingcountname' = `missingcountname' - `countUnusedPTVs' if `contextvar'==`context'
		//tab `missingcountname' if `contextvar'==`context'
		
		display ""
		
		// rows
		forvalues numMissing = 1/`countUsedPTVs' {

			quietly count if `missingcountname'==`numMissing' & `contextvar'==`context'
			quietly return list

			local theseObs = r(N)
		
			if (`showDiag'==1) {
				display "{pmore}{result:`theseObs'} observations with {result:`numMissing'} missing items:"
			}

			
			local missingCounts = ""
			// count missing cases for each PTV
			foreach thisptv in `usedPTVs' {
				
				local column = `column' + 1
				quietly count if missing(`thisptv') & `missingcountname'==`numMissing' & `contextvar'==`context'
				quietly return list
				
				// very, very dirty trick.
				// 		number of missing cases with leading zeros
				//		will ensure that alphabetical sorting will lead to numerical sorting,
				//		but I append the party number! it will not affect sorting, but preserves party info...
				
				local missingCounts = ///
					"`missingCounts'" + ///
					substr("000000",1,7-length(string(r(N))))+string(r(N)) + ///
					"_`thisptv' "
					
			}
			local missingCounts : list sort missingCounts

			// from the best to the worst PTV
			foreach numMissingPTV in `missingCounts' {
				
				//display " [`numMissingPTV'] "
				local missingInfo = subinstr("`numMissingPTV'", "_"," ",.)
				local thisMissingCountTMP = word("`missingInfo'",1)
				local thisMissingCount = `thisMissingCountTMP'
				local thisPTV = subinstr("`numMissingPTV'", "`thisMissingCountTMP'_","",.)
				//local thisPTV = word("`missingInfo'",2)
				
				//display " (`thisPTV') "
				
				
				if (`thisMissingCount' > 0) & (strpos("`numMissingPTV'","_")>0) {
					if (`showDiag'==1) {
						display "{break}`thisPTV' (missing in `thisMissingCount' obs)... " _continue
					}

					
					// actual imputation at last!
					capture drop tmp
					
					// imputation uses the whole context as the sample
					local ctxcommand = "generate thisctx = (`contextvar'==`context')"
					quietly `ctxcommand'
					
					// if all PTVs are missing, i_PTVs are removed from IVs for imputation
					if (`numMissing' < `countUsedPTVs') {
					
						//local impcommand = "impute `thisPTV' `additional' `ctximputedvars' if `missingcountname'==`numMissing' & `contextvar'==`context', generate(tmp) regsample(thisctx)"
						local impcommand impute `thisPTV' `additional' `imputedvars' if `missingcountname'==`numMissing' & `contextvar'==`context', generate(tmp) regsample(thisctx)
						local repcommand replace `imputeprefix'`thisPTV'=tmp if `missingcountname'==`numMissing' & `contextvar'==`context'
						if ("`log'"=="log") {
							display ""
							display ""
							display "{pmore}*LOG* Will execute imputation-related commands:{break}"
							display "{bf:`ctxcommand'} (already executed){break}"
							display "{bf:`impcommand'}{break}"
							display "{bf:`repcommand'}{break}"
							display "{bf:drop tmp}{break}"
							display ""
							display "{pmore}"
						}
							
						capture `showMode' `impcommand'
						capture `showMode' `repcommand'
						capture drop tmp
						/*
						capture `showMode' impute `thisPTV' `additional' `ctximputedvars' ///
							if `missingcountname'==`numMissing' & `contextvar'==`context' ///
							, generate(tmp) regsample(thisctx)
						capture replace `imputeprefix'`thisPTV'=tmp if `missingcountname'==`numMissing' & `contextvar'==`context'
						*/

							display ""
							display "{pmore}"
						
					}
					else {
						
						if ("`additional'" != "") {
							
							local impcommand impute `thisPTV' `additional' if `missingcountname'==`numMissing' & `contextvar'==`context', generate(tmp) regsample(thisctx)
							local repcommand replace `imputeprefix'`thisPTV'=tmp if `missingcountname'==`numMissing' & `contextvar'==`context'
							if ("`log'"=="log") {
								display ""
								display ""
								display "{pmore}*LOG* Will execute imputation-related commands:{break}"
								display "{bf:`ctxcommand'} (already executed){break}"
								display "{bf:`impcommand'}{break}"
								display "{bf:`repcommand'}{break}"
								display "{bf:drop tmp}{break}"
								display ""
								display "{pmore}"
							}
							
							capture `showMode' `impcommand'
							capture `showMode' `repcommand'
							capture drop tmp
							
								display ""
								display "{pmore}"
							/*
							capture `showMode' impute `thisPTV' `additional' ///
								if `missingcountname'==`numMissing' & `contextvar'==`context' ///
								, generate(tmp) regsample(thisctx)
							capture replace `imputeprefix'`thisPTV'=tmp if `missingcountname'==`numMissing' & `contextvar'==`context'
							capture drop tmp
							*/
						}
						else {
							display "Cannot impute without additional variables."
						}
					}
					
					drop thisctx
					
				}
			}
			
			quietly egen tmpXXX = rowmiss(`imputedvars') if `contextvar'==`context'
			quietly replace `missingimputedcountname' = tmpXXX  - `countUnusedPTVs' if `contextvar'==`context'
			quietly drop tmpXXX
			
			if (`showDiag'==1) {
				display ""
			}

		}

		if ("`round'"=="round") {
		
			if (`showDiag'==1) {
				display "{pmore}Rounding imputed values..."
			}

			foreach thisptv in `usedPTVs' {
				//tab i_`thisptv' if orig_mis_`thisptv'==1 & `contextvar'==`context', missing
				quietly replace `imputeprefix'`thisptv' = round(`imputeprefix'`thisptv') if `missingflagprefix'`thisptv'==1 & `contextvar'==`context'
				//tab i_`thisptv' if orig_mis_`thisptv'==1 & `contextvar'==`context', missing
			}
			if (`showDiag'==1) {
				display "done."
				display ""
			}

		
		}
		
		
		if (`rangemin' != 999999999) | (`rangemax' != -999999999) {
			if (`showDiag'==1) {
				display "{pmore}Constraining imputed values..."
			}

			foreach thisptv in `usedPTVs' {
				//tab i_`thisptv' if orig_mis_`thisptv'==1 & `contextvar'==`context', missing
				if (`rangemin' != 999999999) {
					if (`showDiag'==1) {
						display "(using rangemin=`rangemin') "
					}

					quietly replace `imputeprefix'`thisptv' = `rangemin' if `imputeprefix'`thisptv' < `rangemin' & `missingflagprefix'`thisptv'==1 & `contextvar'==`context'
				}
				if (`rangemax' != -999999999) {
					if (`showDiag'==1) {
						display "(using rangemax=`rangemax') "
					}

					quietly replace `imputeprefix'`thisptv' = `rangemax' if `imputeprefix'`thisptv' > `rangemax' & `imputeprefix'`thisptv' < . & `missingflagprefix'`thisptv'==1 & `contextvar'==`context'
				} 
				//tab i_`thisptv' if orig_mis_`thisptv'==1 & `contextvar'==`context', missing
			}	
			
			if (`showDiag'==1) {
				display "done."
				display ""
			}

		}
			
		if (`showDiag'==1) {
			display "{pmore}Comparing SDs of original and imputed observations:{break}"
		}

		
		foreach thisptv in `usedPTVs' {
			quietly summarize `imputeprefix'`thisptv' if `contextvar'==`context' & `missingflagprefix'`thisptv'==0
			quietly return list
			local originalSD = r(sd)
			
			quietly summarize `imputeprefix'`thisptv' if `contextvar'==`context' & `missingflagprefix'`thisptv'==1
			quietly return list
			local imputedSD = r(sd)

			if (`imputedSD' != .) {
				if (`showDiag'==1) {
					display "`imputeprefix'`thisptv' original: " %5.2f `originalSD'  " imputed: " %5.2f `imputedSD' " "
				}

				
				
				if ("`inflate'"!="") {
					// it is actually "noinflate"!
				}
				else {
					if (`showDiag'==1) {
						display "Inflating...{break}"
					}

					quietly replace `imputeprefix'`thisptv' = `imputeprefix'`thisptv' + rnormal(0, `originalSD') if `contextvar'==`context' & `missingflagprefix'`thisptv'==1
				}
			}
			else {
				if (`showDiag'==1) {
					display "`imputeprefix'`thisptv' original: " %5.2f `originalSD'  " imputed: no missing values.{break}"
				}

			}
			
		}
		if (`showDiag'==1) {
			display ""
		}

		
			if ("`round'"=="round") {
			
			if (`showDiag'==1) {
				display "{pmore}Re-rounding..."
			}

			foreach thisptv in `usedPTVs' {
				//tab i_`thisptv' if orig_mis_`thisptv'==1 & `contextvar'==`context', missing
				quietly replace `imputeprefix'`thisptv' = round(`imputeprefix'`thisptv') if `missingflagprefix'`thisptv'==1 & `contextvar'==`context'
				//tab i_`thisptv' if orig_mis_`thisptv'==1 & `contextvar'==`context', missing
			}
			if (`showDiag'==1) {
				display "done."
				display ""
			}

			
		}		
		
		if (`rangemin' != 999999999) | (`rangemax' != -999999999) {
			if (`showDiag'==1) {
				display "{pmore}Re-constraining..."
			}

			foreach thisptv in `usedPTVs' {
				//tab i_`thisptv' if orig_mis_`thisptv'==1 & `contextvar'==`context', missing
				if (`rangemin' != 999999999) {
					if (`showDiag'==1) {
						display "(using rangemin=`rangemin') "
					}

					quietly replace `imputeprefix'`thisptv' = `rangemin' if `imputeprefix'`thisptv' < `rangemin' & `missingflagprefix'`thisptv'==1 & `contextvar'==`context'
				}
				if (`rangemax' != -999999999) {
					if (`showDiag'==1) {
						display "(using rangemax=`rangemax') "
					}

					quietly replace `imputeprefix'`thisptv' = `rangemax' if `imputeprefix'`thisptv' > `rangemax' & `imputeprefix'`thisptv' < . & `missingflagprefix'`thisptv'==1 & `contextvar'==`context'
				}
				//tab i_`thisptv' if orig_mis_`thisptv'==1 & `contextvar'==`context', missing
			}
			if (`showDiag'==1) {
				display "done."
			}

			if (`showDiag'==1) {
				display ""
			}

		}
		
		if ("`inflate'"!="") {
			// it is actually "noinflate"!
		}
		else {
				
			if (`showDiag'==1) {
				display "{pmore}Re-Comparing SDs after inflation:{break}"
			}

			foreach thisptv in `usedPTVs' {
				quietly summarize `imputeprefix'`thisptv' if `contextvar'==`context' & `missingflagprefix'`thisptv'==0
				quietly return list
				local originalSD = r(sd)
				
				quietly summarize `imputeprefix'`thisptv' if `contextvar'==`context' & `missingflagprefix'`thisptv'==1
				quietly return list
				local imputedSD = r(sd)
	   
				if (`imputedSD' != .) {
					if (`showDiag'==1) {
						display "`imputeprefix'`thisptv' original: " %5.2f `originalSD'  " imputed: " %5.2f `imputedSD' " {break}"
					}

				}
				else {
					if (`showDiag'==1) {
						display "`imputeprefix'`thisptv' original: " %5.2f `originalSD'  " imputed: no missing values.{break}"
					}

				}			
				
				
			}
		}
		if (`showDiag'==1) {
			display ""
		}

		
		if (`ncontexts' > 1) {
			if (`showDiag'==1) {
				display "{pstd}Results for context {result:`context'} ({result:`contextLabel'}):"
			}

		}
		else {
			if (`showDiag'==1) {
				display "{pstd}Results:"
			}

		}
		if (`showDiag'==1) {
			display ""
			tab `missingcountname' `missingimputedcountname' if `contextvar'==`context', missing
		}
		display ""
	}

	
end


capture program drop iimpute
program define iimpute

	version 9.0

	/*
	syntax varlist, impute(varlist) [contextvars(varname)] [minofrange(integer 999999999)] [rangemax(integer -999999999)]
	local thePTVs = "`impute'"
	local theAdditional = "`varlist'"
	capture drop missingItems
	quietly egen missingItems = rowmiss(`impute')
	*/
	
	syntax varlist, ///
		[ADDitional(varlist)] [CONtextvars(varlist)] [MINofrange(integer 999999999)] [MAXofrange(integer -999999999)] ///
		[IPRefix(name)] [MPRefix(name)] [MCOuntname(name)] [MIMputedcountname(name)] [LIMitdiag(integer -1)] ///
		[ROUnd] [STAckid(varname)] [NOStacks] [DROpmissing] [NOInflate] [REPlace] [log]
	
	
	local imputePref = "i_"
	if ("`iprefix'"!="") {
		local imputePref = "`iprefix'"
	}
	
	local missingFlagPref = "m_"
	if ("`mprefix'"!="") {
		local missingFlagPref = "`mprefix'"
	}
	
	local missingCntName = "_iimpute_mc"
	if ("`mcountname'"!="") {
		local missingCntName = "`mcountname'"
	}
	
	local missingImpCntName = "_iimpute_mic"
	if ("`mimputedcountname'"!="") {
		local missingImpCntName = "`mimputedcountname'"
	}
	
	
	
	local nvars : list sizeof varlist
	
	
	
	tokenize `varlist'
    local first `1'
	local last ``nvars''

	// from string to genuine list
	//local thePTVs = "`varlist'"
	local thePTVs `varlist'

	//capture drop `missingCntName'
	//capture label drop `missingCntName'
	quietly egen `missingCntName' = rowmiss(`varlist')
	capture label var `missingCntName' "N of missing values in `nvars' variables to impute (`first'...`last')"

	//capture drop `missingImpCntName'
	//capture label drop `missingImpCntName'
	quietly gen `missingImpCntName' = `missingCntName'
	capture label var `missingImpCntName' "N of missing values in imputed versions of `nvars' variables (`first'...`last')"
	
	if ("`stackid'" != "") & ("`nostacks'" == "") {
		local thisCtxVars = "`contextvars' `stackid'"
	}
	else {
		local thisCtxVars = "`contextvars'"
	}
	
	
	if ("`thisCtxVars'" == "") {
		quietly gen _hb_temp_ctx = 1
		local ctxvar = "_hb_temp_ctx"
	}
	else {
		quietly _mkcross `thisCtxVars', generate(_hb_temp_ctx) missing
		local ctxvar = "_hb_temp_ctx"
	}
	
	if (`minofrange' != 999999999) {
		local theMin = "rangemin(`minofrange')"
	} 
	else {
		local theMin = ""
	}
	if (`maxofrange' != -999999999) {
		local theMax = "rangemax(`maxofrange')"
	} 
	else {
		local theMax = ""
	}
	
	iimpute_body `thePTVs', additional(`additional') contextvar(`ctxvar') `theMin' `theMax' imputeprefix("`imputePref'") missingflagprefix("`missingFlagPref'") 	missingcountname("`missingCntName'") missingimputedcountname("`missingImpCntName'") limitdiag(`limitdiag') `round' `inflate' `log'

	if ("`replace'" != "") {
		capture drop `varlist'
	}

	if ("`dropmissing'"!="") {
		capture drop `missingFlagPref'*
	}

	
	capture drop _hb_temp_ctx
	capture label drop _hb_temp_ctx
	
end

