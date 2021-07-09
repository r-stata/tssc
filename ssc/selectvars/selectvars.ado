*! 1.1.0 NJC 26 January 2011 
* 1.0.0 NJC 10 February 2003 
* all subsets of 0 ... k distinct selections from a varlist of k variables 
* no error checking that all of (possibly 2^k) selections can be held in macro
program selectvars, rclass
	version 8 
	syntax varlist [, max(numlist max=1 int >0) min(numlist max=1 int >=0)] 
	tokenize `varlist' 
	local nvars : word count `varlist'

	if "`max'" == "" { 
		local max = `nvars' 
	}
	else if `max' > `nvars' { 
		di ///
		"{p}{txt}maximum reset to number of variables {res}`nvars'" 
		local max = `nvars' 
	} 
	
	if "`min'" == "" { 
		local min = 0  
	}
	else if `min' > `max' { 
		di ///
		"{p}{err}minimum {res}`min' {err}exceeds maximum {res}`max'" 
		exit 198  
	} 

	local imax = 2^`nvars' - 1   

	forval i = `imax'(-1)1 { 
		qui inbase 2 `i'
		local which `r(base)' 
		local nzeros = `n' - `: length local which' 
		local zeros : di _dup(`nzeros') "0" 
		local which `zeros'`which'  
		local vars 
		forval j = 1 / `nvars' { 
			local char = substr("`which'",`j',1) 
			if `char' { 
				local vars "`vars'``j'' " 
			}
		}
		local nv : word count `vars' 
		if (`nv' >= `min') & (`nv' <= `max') { 
			local vlist `"`vlist'"`vars'" "'
		} 	
	}
	
	// initialise with null choice (no variables chosen)? 
	if `min' == 0 { 
		local varlist `"" " "' 
	}
	else local varlist 
 
	if `max' > `min' { 
		forval i = `min' / `max' { 
			foreach w of local vlist { 
				if `i' == `: word count `w'' { 
					local varlist `"`varlist'"`w'" "' 
				}
			}
		}	
	}	
	else local varlist "`vlist'" 

	return local varlist `"`varlist'"' 
end 
