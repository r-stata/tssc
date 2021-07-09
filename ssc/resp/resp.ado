*! version 0.4.1 08jul2020
/*
  This function is a wrapper for
      by byvar: egen name = resp(varname) [if][in], dim(vardim1 vardim2) mode(string)
	  
  Author:
    Joel E. H. Fuchs a.k.a. Fantastic Captain Fox
	jfuchs@uni-wuppertal.de
*/
program define resp, rclass byable(onecall) sortpreserve
    version 7, missing
    syntax namelist(min=2 max=2) [if] [in], /*
	 */ Dim(namelist min=2 max=2) [*]
    local dim1 : word 1 of `dim'
    local dim2 : word 2 of `dim'
	local outvar : word 1 of `namelist'
	local invar  : word 2 of `namelist'
    tempvar touse
	if _by() { 
	    local byopt `"by `_byvars'`_byrc0':"'
    }
	quietly {
	    generate byte `touse' = 1 `if' `in'
        noisily `byopt' egen `outvar' = resp(`invar') if `touse' == 1, /*
		 */ dim(`dim1' `dim2') `options'
	    return local cmdline = /*
		 */ `"`byopt' egen `outvar' = resp(`invar')`if'`in', "' + /*
		 */ `"dim(`dim1' `dim2') `options'"'
    }
end