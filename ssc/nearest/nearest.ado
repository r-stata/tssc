program def nearest 
*! NJC 1.1.0 10 January 2003 
	version 7 
	syntax varlist(min=2 max=2 numeric) [if] [in] , dist(str) [id(str)] 
	confirm new var `dist'
	
	if "`id'" != "" { 
		confirm new var `id' 
	} 	
	else local noid "*" 
	
	marksample touse
	tokenize `varlist' 
	args x y 

	qui { 
		gen double `dist' = . 
		`noid' gen long `id' = . 
		tempname d
		local n = _N 
		
		forval i = 1/`n' { 
			forval j = 1/`n' { 
				if `touse'[`i'] & `touse'[`j'] & (`i' != `j') { 
					scalar `d' = /* 
			*/ (`x'[`i'] - `x'[`j'])^2 + (`y'[`i'] - `y'[`j'])^2 
					if `d' < `dist'[`i'] { 
						replace `dist' = `d' in `i' 
						`noid' replace `id' = `j' in `i' 
					}
				}
			}	
		}
		replace `dist' = sqrt(`dist') 
		`noid' compress `id' 
	} 
end 
