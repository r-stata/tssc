*! NJC 1.1.0 31 October 2005 
*! NJC 1.0.0 27 October 2004 
program sliceplot
	version 8 
	// plot type   
	gettoken plottype 0 : 0 
	
	syntax varlist(min=2) [if] [in] ///
	[, at(numlist sort) length(int 100) slices(numlist max=1 >0) ///
	unequal combine(str asis) * ] 

	marksample touse
	qui count if `touse' 
	if r(N) == 0 error 2000

	local nv : word count `varlist' 
	tokenize `varlist' 
	local t "``nv''" 
	
	su `t' if `touse', meanonly 
	local min = r(min) 
	local max = r(max) 

	if "`at'" != "" { 
		local i = 1 
		local j`i' = `min' 
		
		foreach e of local at { 
			if `e' < `min' | `e' > `max' { 
				di as txt ///
				"`e' ignored: range of `t' is [`min',`max']" 
			} 
			else if `e' < `max' { 
				local k`i++' = `e' 
				local j`i' = `e' + 1 
			} 
		} 
		
		local k`i' = `max' 
		local slices = `i' 

		if "`unequal'" == "" { 
			local range 0 
			forval i = 1/`slices' { 
				local range = max(`range', `k`i'' - `j`i'') 
			} 	
		
			forval i = 1/`slices' { 
				local K`i' = `j`i'' + `range' + 1 
			} 	
		} 
		else { 
			forval i = 1/`slices' { 
				local K`i' = `k`i''  
			} 	
		}	
	}
	else { 
		local range = r(max) - r(min) + 1 
		if "`slices'" != "" local length = ceil(`range' / `slices') 
		else local slices = ceil(`range' / `length') 

		forval i = 1/`slices' { 
			local j`i' = `min' + (`i' - 1) * `length' 
			local k`i' = `j`i'' + `length' - 1 
			local K`i' = `k`i'' 
		}
	}

	forval i = 1/`slices' { 
		tempname g`i' 
		twoway `plottype' `varlist' if inrange(`t', `j`i'', `k`i'') ///
		, xsc(ra(`j`i'' `K`i'')) name(`g`i'') nodraw `options' 
		local G "`G' `g`i''" 
	} 	

	local 0 ", `combine'" 
	syntax [, imargin(str) Cols(str) * ] 
	if "`imargin'" == "" local combine `combine' imargin(zero) 
	if "`cols'" == ""    local combine `combine' cols(1) 
	
	graph combine `G', `combine'  
end 
