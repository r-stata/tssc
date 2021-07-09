*! NJC 1.3.2 24 April 2006 
* NJC 1.3.1 13 April 2006 
* NJC 1.3.0 12 April 2006 
* NJC 1.2.0 2 April 2006 
program tabexport
	version 8.2 
	syntax varlist(numeric) [if] [in] using/ ///
	[aweight fweight iweight pweight]        ///
	, Statistics(str)                        ///
	[ xpose BY(varlist) Format(str) noRESHAPE CW ///
	OUTFILE OUTSHEET TOTAL VARiableorder noNames Quote List(str asis) * ]

	// xpose undocumented for now 
	if "`xpose'" != "" & "`total'" != "" { 
		di as err "xpose and total may not be combined"
		exit 198 
	}	
	if "`xpose'" != "" & "`format'" != "" {
		di as err "xpose and format() may not be combined"
		exit 198
	}	

	marksample touse 
	if "`by'" != "" { 
		markout `touse' `by', strok 
		local byby "by(`by')" 
	}
		
	qui count if `touse' 
	if r(N) == 0 error 2000 

	if "`format'" != "" {
		if _caller() >= 9 { 
			foreach f of local format { 
				confirm format `f' 
			}
		}	
		
		local nf : word count `format' 
		local ns : word count `statistics' 
		if `nf' < `ns' { 
			local flast : word `nf' of `format' 
			forval j = `= `nf' + 1'/`ns' { 
				local format `format' `flast' 
			}
		}
	}

	if "`outfile'" != "" { 
		local out "outfile"
	}	
	else { 
		if "`quote'" == "" local quote "noquote" 
		local totoptions nonames `quote' `options' 
		local out "outsheet"
	}	

	// user -list- options might include subvarname, which is wired in 
	local subin = 0 
	if `"`list'"' != "" { 
		foreach l of local list { 
			if substr("`l'", 1, 6) == "subvar" local subin = 1 
		}
	}
	
	preserve 
	foreach s of local statistics {
		local call "`call'(`s') " 
		foreach v of local varlist { 
			local call "`call'`v'`s' = `v' " 
		}
	} 

	qui collapse `call' if `touse' [`weight' `exp'], `cw' `byby' 

	qui if "`format'" != "" { 
		tokenize "`format'" 
		local j = 1
		foreach s of local statistics { 
			tostring *`s', replace format(``j'') force 
			local ++j 
		} 
	}
	
	qui if "`reshape'" == "" { 
		if "`by'" == "" {
			tempvar by 
			gen `by' = _n      
		}
	
		reshape long `varlist', i(`by') j(_stats) string

		// -reshape- orders statistics alphabetically,  
		// so may need to put them back the way the user specified 
		local stats : list sort statistics
		if !`: list statistics == stats' {
			local reorder 1 
			local k = 1 
			tempname lbl  
			foreach s of local statistics { 
				label def `lbl' `k' "`s'", add
				local ++k 
			}
			tempvar toorder 
			encode _stats, gen(`toorder') label(`lbl') 
			sort `by' `toorder' 
			drop `toorder'
		}	
		else local reorder 0 
		
		if "`byby'" == "" { 
			drop `by' 
		}	
	}
	else { 
		if "`variableorder'" != "" { 
			foreach v of local varlist { 
				foreach s of local statistics { 
					local new `new' `v'`s' 
				}
			}

			order `new' 
		}
	}	
			
	if "`xpose'" != "" { 
		local nv = _N 
		forval i = 1/`nv' { 
			if "`byby'" != "" { 
				local BY `"`by'_`=`by'[`i']'"'
			}	
			local vars `vars' `BY'`= _stats[`i']' 
		}
		drop _stats 
		xpose, clear promote format varname 
		tokenize `vars' 
		forval i = 1/`nv' { 
			capture rename v`i' ``i'' 
		}	
		order _varname 
	}	

	if `subin' == 0 local subvar "subvar" 
	list, `subvar' `list' 
	
	`out' using "`using'", `names' `quote' `options' 

	if "`total'" != "" & "`byby'" != "" { 
		restore 
		preserve 
		marksample `touse' 
		markout `touse' `by', strok 
		qui collapse `call' if `touse' [`weight' `exp'], `cw' 

		qui if "`format'" != "" { 
			tokenize "`format'" 
			local j = 1
			foreach s of local statistics { 
				tostring *`s', replace format(``j'') force 
				local ++j 
			} 
		}	

		tempvar tot
		gen `tot' = "Total"
		char `tot'[varname] `" "' 

		qui if "`reshape'" == "" { 
			reshape long `varlist', i(`tot') j(_stats) string 
			if `reorder' { 
				local k = 1 
				tempname lbl  
				foreach s of local statistics { 
					label def `lbl' `k' "`s'", add
					local ++k 
				}
				tempvar toorder 
				encode _stats, gen(`toorder') label(`lbl') 
				sort `toorder' 
				drop `toorder'
			}	
		}	
		else { 
			if "`variableorder'" != "" { 
				foreach v of local varlist { 
					foreach s of local statistics { 
						local new `new' `v'`s' 
					}
				}
		
				order `new' 
			}
		}
		
		list, `subvar' `list'  
		
		tempfile total 
		qui `out' using `total', `totoptions' 
		if "`c(os)'" == "Windows" { 
			shell copy "`using'" + "`total'" "`using'" 
		}
		else shell cat `total' >> `using' 
	}

	c_local collapse_call ///
	collapse `call' `if' `in' [`weight' `exp'], `cw' `byby'
end 	
