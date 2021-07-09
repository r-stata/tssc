program def copydesc 
*! NJC 1.2.1 8 August 2000 
* NJC 1.2.0 9 May 2000 
* NJC 1.1.0 2 February 2000 
* NJC 1.0.0 29 October 1999 
	version 6.0 
	syntax varlist(min=2 max=2) [, Warn Restrain ] 
	tokenize `varlist' 
	args src dst
	
	if "`warn'`restrain'" != "" { 
		capture confirm numeric variable `src' 
		local snum = _rc == 0 
		capture confirm numeric variable `dst' 
		local dnum = _rc == 0 
		if `snum' != `dnum' { 
			local stype = cond(`snum', "numeric", "string") 
			local dtype = cond(`dnum', "numeric", "string") 
			if "`restrain'" != "" { 
				di in r "`src' is `stype', `dst' is `dtype'" 
				exit 198 
			}	
			else di in bl "`src' is `stype', `dst' is `dtype'" 
		}
	}
	
	local w : variable label `src'
	if `"`w'"' == "" { local w "`src'" } 
	label variable `dst' `"`w'"'
	local srclab : value label `src' 
	capture label val `dst' `srclab' 
	local srcfmt : format `src' 
	capture format `dst' `srcfmt'

	local chsrc : char `src'[] 
	if "`chsrc'" != "" { 
		tokenize `chsrc' 
		while "`1'" != "" {
			local schar : char `src'[`1'] 
			char `dst'[`1'] `"`schar'"'   
			mac shift 
		}
	} 	
end
	
