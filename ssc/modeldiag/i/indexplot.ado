*! 3.0.1 NJC 10 November 2004 
* 3.0.0 NJC 3 November 2004 
* 2.0.0 NJC 13 February 2003 
* 1.2.3 NJC 4 July 2002 
* 1.0.0 NJC 1 Oct 2001 
program indexplot, sort 
	version 8.0
	syntax [if] [in]                                              /// 
	[, show(str) HIgh(numlist int min=1 max=1) LOw(numlist int min=1 max=1) ///
	Base(str) recast(passthru) plot(str asis) * ]   

	marksample touse, novarlist
	qui replace `touse' = `touse' * e(sample)
	qui count if `touse' 
	if r(N) == 0 error 2000 

	// get toshow 
	qui { 
		if "`show'" == substr("observed",1,length("`show'")) { 
			local toshow "`e(depvar)'"
		}
		else { 
			tempvar toshow 
			predict `toshow' if `touse', `show' 
		}	
	} 	

	if "`: variable label `toshow''" == "" {
		label var `toshow' "`show'" 
	} 	
			
	// get index 
	tempvar index 
	gen long `index' = _n 
	qui compress `index' 
	label var `index' "observation"
	
	// determine base 
	if "`base'" == "mean" { 
		su `toshow' if `touse', meanonly 
		local base = r(mean)
	}	
	else if "`base'" == "" local base = 0 

	local base = cond("`recast'" != "", "yline(`base')", "base(`base')") 

	// graph preparation 
	if "`high'`low'" != "" { 
		sort `touse' `toshow' 
		if "`low'" != "" { 
			qui count if !`touse' 
			local i1 = `r(N)' + 1 
			local i2 = `i' + `low' 
			forval i = `i1'/`i2' { 
				local this = `index'[`i'] 
				local lwhere "`lwhere' `this'" 
			} 
			local lxlabel "xla(`lwhere')" 
		} 
		if "`high'" != "" { 
			local i1 = _N - `high' + 1 
			local i2 = _N 
			forval i = `i1'/`i2' {
				local this = `index'[`i'] 
				local hwhere "`hwhere' `this'" 
			} 
			local hxlabel "xaxis(1 2) xla(`hwhere', axis(2))" 
		}	
		local xlabel "`hxlabel' `lxlabel'" 
	} 	
	
	// graph
	twoway dropline `toshow' `index' if `touse', /// 
	`base' `xlabel' `options' `recast' ///
	|| `plot' 
end

