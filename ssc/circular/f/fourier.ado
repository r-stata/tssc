*! 2.0.0 NJC 30 March 2004 
* 1.0.0 NJC 13 May 1997
program fourier, rclass 
	version 8.0
	syntax varname [if] [in] [ , Nh(int 1) Cstub(str) Sstub(str) ] 
	if "`cstub'" == "" local cstub "cos_" 
	if "`sstub'" == "" local sstub "sin_" 

	// two loops here; i.e. check all names before creating any variable
	forval i = 1/`nh' { 
		confirm new variable `cstub'`i'
		confirm new variable `sstub'`i'
	} 	

	forval i = 1/`nh' {
		local j = cond(`i' > 1, "`i' * ", "") 
		gen `cstub'`i'  = cos(`i' * _pi * `varlist'/180) `if' `in'
		label var `cstub'`i' "cos(`j'`varlist')" 
		gen `sstub'`i'  = sin(`i' * _pi * `varlist'/180) `if' `in'
		label var `sstub'`i' "sin(`j'`varlist')" 
	}
	
	d `cstub'1-`sstub'`nh' 
	return local varlist "`cstub'1-`cstub'`nh' `sstub'1-`sstub'`nh'" 
end
