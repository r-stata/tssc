*! NJC 1.1.1 20 Jan 2009 
*! NJC 1.1.0 12 May 2003 
*! NJC 1.0.0 6 August 2001 
program domdiag
	version 8 
	syntax varname [if] [in], by(varname) [ note(str) * REVerse ] 
	qui { 
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000 

		* two groups? 
		tab `by' if `touse'
		local s = cond(`r(r)' == 1, "","s") 
		if `r(r)' != 2 {
			di as err "`r(r)' group`s' found, 2 required" 
			exit 420 
		} 
		
		* porder 
		ranksum `varlist' if `touse', by(`by') porder 
		local porder : di %4.3f `r(porder)' 

		* slim data set 
	        preserve 	
		keep if `touse' 
		keep `varlist' `by' 

		* restructure data set 
		tempvar rank1 rank2 copy show  
		bysort `by' (`varlist'): gen `rank1' = _n
		count if `by' == `by'[1] 
		local n1 = `r(N)' 
		count if `by' == `by'[_N] 
		local n2 = `r(N)' 
		expand `n2' if `by' == `by'[1]
		bysort `by' `rank1': gen `rank2' = _n 
		gen `copy' = `varlist'[_N - `n2' + `rank2'] 

		* graph symbol 
        	gen str1 `show' = /* 
		*/ substr("+0-", sign(`copy' - `varlist') + 2, 1) 
	}

	* default axis labels  
	local first = `by'[1] 
	local first : label (`by') `first' 
	local last = `by'[_N] 
	local last : label (`by') `last' 
	label var `rank1' "`varlist' rank, `by' is `first'" 
	label var `rank2' "`varlist' rank, `by' is `last'"
	
	* default note 
	if `"`note'"' == "" { 
		local note /* 
*/ `"P(`varlist' | `by' is `first') > P(`varlist' | `by' is `last') = `porder'"'
		if length("`note'") > 60 { 
			local note /* 
*/ `"P(`varlist' | `first' > `varlist' | `last') = `porder'"' 
		} 
		if length("`note'") > 60 { 
			local note `"P(`first' > `last') = `porder'"' 
		} 
		if length("`note'") > 60 { 
			local note "P = `porder'" 
		} 	
	}
	
	* assign variables to axes 
	local r = cond("`reverse'" == "","","!") 
	local args = /* 
	*/ cond(`r'(`n1' <= `n2'), "`rank1' `rank2'", "`rank2' `rank1'")
	
	* graph 
	scatter `args' if `by' == `by'[1], /// 
	ms(none) mlabel(`show') mlabpos(0) note(`"`note'"') `options' 
end 	

