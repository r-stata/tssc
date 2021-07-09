program def fndmtch, rclass
*! NJC 1.1.0 10 November 2000 
*! NJC/DEMW 1.0.0 1 December 1999 
	version 6.0 
	syntax varname [if] [in], Search(varlist) [Generate(string) List] 
	
	if "`generate'" != "" {
		local g "`generate'" 
		confirm new variable `g' 
	} 

	* missing values not automatically excluded 
	tempvar touse 
	mark `touse' `if' `in' 

	tempvar nfound
	gen byte `nfound' = 0 

	capture confirm string variable `varlist' 
	local visnum = _rc != 0

	* exclude varname itself from variables to be searched 
	local search : subinstr local search "`varlist'" "", word all  
	tokenize `search' 

	qui while "`1'" != "" { 
		capture confirm string variable `1' 
		local thisnum = _rc != 0 
		if `visnum' != `thisnum' { 
			local badlist "`badlist' `1'"
		} 	
		else { 
			capture assert `1' != `varlist' if `touse' 
			if _rc == 9 { 
				local where "`where' `1'"  
				replace `nfound' = /* 
				*/ `nfound' + (`1' == `varlist') if `touse' 
			}	
		} 	
		mac shift 
	} 

	local badlist = trim("`badlist'") 
	if "`badlist'" != "" { 
		local nbad : word count `badlist' 
		local isare = cond(`nbad' == 1, "is", "are") 
		local bad = cond(`visnum' == 1, "string", "numeric") 
		local good = cond(`visnum' == 0, "string", "numeric") 
		di in g "`badlist' " in bl "`isare' `bad'" _c 
		di in bl " whereas " in g "`varlist' " in bl "is `good'" _n  
	} 

	local where = trim("`where'") 
	if "`where'" != "" { 
		di in y "matching values in " in g "`where'" 
	} 	

	if "`list'" != "" & "`where'" != "" { 
		list `varlist' `where' if `nfound'  
	} 

	qui if "`g'" != "" { 
		generate byte `g' = . 
		replace `g' = `nfound' 
	} 	

	return local where "`where'" 
end 
	
