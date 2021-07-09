*! 1.0.2 NJC 13 Oct 2009 
* 1.0.1 NJC 17 Sept 2009 
* 1.0.0 NJC 29 Aug 2009 
program pieplot 
	version 8.2 
	syntax varlist(min=1 max=2) [aweight fweight pweight] [if] [in] ///  
	[, missing sum PERcent format(passthru) gap(passthru)           ///
	bysubopts(str asis) plabelsubopts(str asis) *] 

	quietly { 
		if "`sum'" != "" & "`percent'" != "" { 
			di as err "must choose between sum and percent options" 
			exit 198 
		} 

		if "`missing'" != "" marksample touse, strok novarlist 
		else marksample touse, strok 
		count if `touse' 
		if r(N) == 0 error 2000 

		tokenize "`varlist'" 
		args y x 
		tab `y' if `touse', `missing'  
		local nvals = r(r)
	}

	local what = cond("`sum'`percent'" != "", "`sum'`percent'", "name")   

	// work-around bug affecting plabel(_all <stuff>) 
	forval i = 1/`nvals' { 
		local plabopts `plabopts' plabel(`i' `what', `format' `gap' `plabelsubopts') 
	} 

	if "`what'" == "name" local off legend(off)

	if "`x'" != "" local by by(`x', `bysubopts' note("") `off') 

	if "`exp'" != "" local wt [`weight' `exp'] 
	di _n as txt "  syntax would be:" _n ///
	"{p 2 2 2}. graph pie `wt', over(`y') `missing' `by' `plabopts' `off' `options'{p_end}" 

	graph pie [`weight'`exp'], over(`y') `missing' `by' `plabopts' `off' `options' 
end 

