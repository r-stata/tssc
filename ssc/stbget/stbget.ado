*! 1.2.0 NJC 2 May 2001
* 1.1.0 NJC 26 April 2001 
* 1.0.0 NJC 21 March 2001     
program define stbget 
	version 6.0
	gettoken stuff 0 : 0, parse(",") 
	
	tokenize `stuff' 
	if "`3'" != "" { error 198 } 
	else if "`2'" == "" {
		Zapstb 1 `1' 
		capture confirm integer n `1' 
		if _rc { 
			di in r "incorrect syntax" 
			exit 198 
		} 
		local issueno `1' 
		local twoargs 0
	} 	
	else { 
		args pkgname issueno
		Zapstb issueno `issueno' 
		capture confirm integer n `issueno' 
		if _rc { 
			Zapstb pkgname `pkgname' 
			capture confirm integer n `pkgname' 
			if _rc { 
				di in r "incorrect syntax" 
				exit 198 
			} 
			else { /* swap them */ 
				local temp `issueno' 
				local issueno "`pkgname'" 
				local pkgname "`temp'" 
			} 	
		} 	

		local twoargs 1
		local qui "qui" 
		local pkgname : subinstr local pkgname "." "_" 
	}	
	
	syntax [, all replace Describe ] 
	`qui' net from http://www.stata.com/stb/stb`issueno' 
	if `twoargs' { 
		if "`describe'" != "" { 
			net describe `pkgname' 
		} 	
		else net install `pkgname', `all' `replace' 
	} 	
end

program def Zapstb 
* "STB60" "STB-60" "stb60" "stb-60" all get mapped to "60" 
	version 6.0 
	args macname value 
	local value = lower("`value'") 
	local value : subinstr local value "stb" ""
	local value : subinstr local value "-" ""
	c_local `macname' "`value'"
end 
