*! 1.3.0 NJC 1 February 2007 
* 1.2.0 NJC 31 May 2004 
* 1.1.0 NJC 21 February 2000 
* 1.0.0 NJC 5 December 1997
program doubmass, sortpreserve 
	version 8.0
	syntax varlist(min=2) [if] [in] ///
	[ , RATIO PLOT(str asis) ADDPLOT(str asis) * ]

	quietly { 
		// will fail if not -tsset- 
		tsset 
		local time "`r(timevar)'" 
		
		marksample touse
		count if `touse' 
		if r(N) == 0 error 2000 

		if "`r(panelvar)'" != "" { 
			tab `r(panelvar)' if `touse' 
			if r(r) > 1 { 
				di as err "more than one panel in data" 
				exit 498 
			}
		} 	

		tokenize `varlist'
		local nvars : word count `varlist'
			
		forval i = 1 / `nvars' {  
			tempvar sum`i'
			gen `sum`i'' = sum(``i'') if `touse'
			_crcslbl `sum`i'' ``i''
			local sumvars "`sumvars' `sum`i''" 
		}

		if `nvars' > 2 {
			tempvar aveoth
			// rmean() for compatibility with Stata 8 
			egen `aveoth' = rmean(`sumvars')
			label var `aveoth' "average of `2'-``nvars''"
			local shlbl "average of others"
		}
		else {
			local aveoth `sum2'
			local shlbl "`2'"
		}
	} 	

	if "`ratio'" == "ratio" {
        	tempvar ratio
	        qui gen `ratio' = `sum1' / `aveoth'
        	local solbl : variable label `aveoth'
	        if length("`solbl'") > 20 local solbl "`shlbl'" 
	        label var `ratio' "`1' / `solbl'"
		
	        scatter `ratio' `time', `options' /// 
		|| `plot' || `addplot' 
        }
	else { 
		scatter `sum1' `aveoth', subtitle("double mass plot") ///
		`options' ///
		|| `plot' || `addplot' 
	}
end
