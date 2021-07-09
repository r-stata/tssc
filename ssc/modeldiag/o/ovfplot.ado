*! 3.0.1 NJC 4 November 2004 
* 3.0.0 NJC 26 Feb 2003 
* 2.0.0 NJC 19 Sept 2001 
* 1.0.0 NJC 18 May 1998
program ovfplot 
	// observed vs. fitted 
	version 8 
	syntax [ , SOrt YTItle(str asis) XTItle(str asis) CLPattern(str asis) ///
	CLSTYle(str) CLWidth(str) CLColor(str) PLOT(str asis) * ]

	// initial checking and picking up what -regress- type command 
	// leaves behind
	
	if "`e(depvar)'" == "" { 
		di as err "estimates not found" 
		exit 301 
	} 

	if `: word count `e(depvar)'' > 1 { 
		di as err "ovfplot not allowed after `e(cmd)'" 
		exit 498 
	} 
	
	local y "`e(depvar)'" 

	// get fit 
        tempvar fit
	qui predict `fit' if e(sample) 

	// set up graph defaults 
	if `"`clpattern'"' == "" local clpattern `""-""'
	local msymbol "O i" 
	
	if `"`ytitle'"' == "" { 
		local what : variable label `y'
		if `"`what'"' == ""  local what "`y'"  
		local ytitle `""`what'""'  
	} 
	
	if `"`xtitle'"' == "" local xtitle : variable label `fit'
		
	foreach o in clstyle clwidth clcolor { 
		if "``o''" != "" local clopts "`clopts' `o'(``o'')"
	} 	

	// graph
	twoway function y = x, clp(`clpattern') `clopts' range(`fit') || /// 
	scatter `y' `fit' if e(sample)                                   /// 
	, ytitle(`ytitle') xtitle(`"`xtitle'"') ms(`msymbol')            ///
	legend(order(1 "observed = fitted")) `options'                   ///
	|| `plot'                                                        ///
	// blank
end

