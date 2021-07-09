*! NJC 2.0.0 4 November 2006 
* NJC 1.5.0 14 November 2000 
* NJC 1.4.0 29 February 2000 
program countmatch, sortpreserve 
	version 8 
	syntax varlist(min=2 max=2) [if] [in] [, Generate(string) ///
		by(varlist) MISSing SUBVARname ABbreviate(int 12) * ] 
	
	local g `generate'
	local list = "`g'" == "" 
	if "`g'" != "" { 
		confirm new variable `g' 
	} 
	else tempvar g                    
	
	tokenize `varlist' 
	args var1 var2

	marksample touse, novarlist 	
	if "`missing'" == "" markout `touse' `var1', strok 
	qui count if `touse' 
	if r(N) == 0 error 2000

	capture confirm string variable `var1' 
	local var1num = _rc != 0
	capture confirm string variable `var2' 
	local var2num = _rc != 0 
	if `var1num' != `var2num' { 
		local var1is = cond(`var1num',"numeric","string") 
		local var2is = cond(`var2num',"numeric","string") 
		di as err "`var1' is `var1is', `var2' is `var2is'" 
		exit 198 
	}	

	tempvar group order  

	quietly { 
		gen byte `g' = cond(`touse',0,.) 

		if "`by'" == "" { 
			tempvar BY 
			gen byte `BY' = 1 
		} 	
		else local BY "`by'" 
	
		bysort `touse' `var1' `BY': ///
			gen byte `group' = _n == 1 & `touse' 
		replace `group' = sum(`group') 
		local ngrp = `group'[_N] 

		gen long `order' = _n 

		forval i = 1/`ngrp' {
			su `order' if `group' == `i' 
			local j = r(min) 
			count if `var1'[`j'] == `var2' & `BY' == `BY'[`j']
			replace `g' = r(N) if `group' == `i' 
		} 
	}	

	if `list' {
		char `g'[varname] "# of matches" 
		list `varlist' `g' if `touse', subvarname ///
			ab(`abbreviate') `options'
	} 	

end 		

