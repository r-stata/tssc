*! 1.1.0 NJC 25 Nov 2015 
*! 1.0.0 NJC 12 Feb 2015 
program depthplot 
	version 8.2 
	syntax varlist(min=2 numeric) [if] [in] [, * BY(str asis) RECAST(str) ] 

	gettoken y x : varlist 
	marksample touse, novarlist 
	markout `touse' `y' 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	preserve 
	qui keep if `touse' 
	local nx : word count `x' 
	isid `y'

	local j = 0 
	foreach v of local x { 
		local ++j 
		local tostack `tostack' `y' `v'   
		local lbl`j' `"`: var label `v''"' 
		if `"`lbl`j''"' == "" local lbl`j' "`v'" 
	} 
	
	local lbly : var label `y' 
	sort `y' 
	tempvar toshow 
	tempname toshowlbl 
	stack `tostack', into(`y' `toshow') clear
	label var `y' `"`lbly'"' 

	forval j = 1/`nx' { 
		label define `toshowlbl' `j' `"`lbl`j''"', modify
	}
	label val _stack `toshowlbl' 

	gettoken comma by2 : by, parse(,) 
	if "`comma'" == "," local by `by2' 

	if "`recast'" == "" { 
		line `y' `toshow', by(_stack, note("") `by'  ) ///
		xtitle("") ysc(reverse) `options' 
	}
	else if inlist("`recast'", "scatter", "connected", "line") { 
		line `y' `toshow', by(_stack, note("") `by'  ) ///
		xtitle("") ysc(reverse) recast(`recast') `options' 
	}
	else { 
		line `toshow' `y', by(_stack, note("") `by'  ) ///
		xtitle("") ysc(reverse) horizontal recast(`recast') `options' 
	}
end 

