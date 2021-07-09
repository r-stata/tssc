*! 3.1.1 NJC 20 Sept 2005 
* 3.1.0 NJC 10 Feb 2004 
* 3.0.0 NJC 25 Sept 2003 
* 2.0.0 NJC 5 February 2001 
* 1.0.0 NJC 26 March 1999 STB-49 dm67
program nmissing, byable(recall) rclass 
	version 8.0
	syntax [varlist] [if] [in] [, Min(str) Obs Piasm Trim * PRESENT ] 

	// -present- undocumented: backdoor key for -npresent- 
	local not = cond("`present'" != "", "!", "") 
	
	marksample touse, novarlist 
	qui count if `touse' 
	if r(N) == 0 error 2000 
	
	// "all" in previous version; now undocumented but remains legal 
	local OKlist "all _all * _N" 
	if "`min'" == "" local min 1 
	else if `: list min in OKlist' { 
		if "`obs'" == "" { 
			qui count if `touse' 
			local min = r(N) 
		} 
		else local min : word count `varlist' 
	} 
	else { 
		// evaluate first; hence allow expressions 
		local min = `min' 
		// fix negative values 
		local min = max(`min', 0) 
		capture confirm integer number `min' 
		if _rc { 
			di as err "min() invalid"
			exit 198 
		}
	} 
	
	qui if "`obs'" == "" {
		local first = 1 
		foreach v of local varlist {
			if "`piasm'" != "" local or `" | `trim'(`v') == ".""' 
			
			capture confirm string variable `v' 
			if _rc == 0 { 
				count if `not'(mi(`trim'(`v')) `or') & `touse' 
			} 	
			else count if `not'mi(`v') & `touse'
			
			if r(N) >= `min' { 
				if `first' { 
					noi di 
					local first = 0 
				} 	

				local vlist `vlist' `v' 
				
				if _caller() == 6 local name "`v'" 
				else local name = abbrev("`v'",12) 
				
				noi di as txt "`name'" _col(16) ///
					as res %6.0f r(N) 
			}
		}	
		
		return local varlist "`vlist'" 
	}
	else qui { 
		tempvar nmiss  
		gen byte `nmiss' = 0 
		if "`not'" != "" char `nmiss'[varname] "# present"
		else char `nmiss'[varname] "# missing" 
		foreach v of local varlist {
			if "`piasm'" != "" local or `" | `trim'(`v') == ".""' 

			capture confirm string variable `v' 
			if _rc == 0 { 
				replace `nmiss' = `nmiss' + ///
					`not'(mi(`trim'(`v')) `or')
			} 			  
 			else replace `nmiss' = `nmiss' + `not'mi(`v') 
		}
		noi list `nmiss' if `touse' & `nmiss' >= `min', /// 
			subvarname abb(9) `options' 
		
		// save probably not useful, but done for symmetry 
		return local varlist "`varlist'" 	
	} 	
end
	
