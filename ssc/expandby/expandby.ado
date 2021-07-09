*! 1.0.0 NJC 5 July 2000             
program define expandby, rclass 
        version 6
        gettoken nextra 0 : 0, parse(" ,")  
	confirm integer number `nextra'
	if `nextra' < 2 { 
		di in r "# should be 2 or more" 
		exit 198 
	} 	
        syntax [if] [in] , by(varname) /* 
	*/ [ MISSing Generate(str) SORTby(varname) usesortmiss first ] 
	
	if "`generate'" != "" { 
		confirm new variable `generate' 
	} 

        marksample touse
	if "`missing'" == "" { 
		markout `touse' `by', strok 
	} 
	if "`sortby'" != "" & "`usesortmiss'" == "" {
		markout `touse' `sortby', strok  
	} 	

	local N = _N 
	tempvar g 
	sort `touse' `by' `sortby'  
	local which = cond("`first'" != "", "1", "_N") 
        qui by `touse' `by': gen byte `g' = _n == `which' & `touse'
	expand `nextra' if `g' 

	if "`generate'" != "" { gen byte `generate' = _n > `N' } 

	local newobs = _N - `N' 
	return local newobs `newobs' 	
end

