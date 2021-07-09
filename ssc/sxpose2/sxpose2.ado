*! Stephan Huber (DrStephanHuber@yahoo.de) 1.0.0 17 October 2020
program sxpose2 
	version 8 
	syntax , clear [ force Format(string) FIRSTnames DEstring VARLabel VARName] 

	if "`force'" == "" { 
		foreach v of var * { 
			capture confirm string var `v' 
			if _rc { 
				di as err ///
				"{p}dataset contains numeric variables; " ///
				"use {cmd:force} option if desired{p_end}" 
				exit 7 
			} 	
		}
	} 	

	local nobs = _N 
	qui d 
	local nvars = r(k) 

	if `nobs' > `c(max_k_theory)' { 
		di as err "{p}not possible; would exceed present limit on " ///
			  "number of variables{p_end}" 
		exit 498 
	} 	

	forval j = 1/`nobs' { 
		local new "`new' _var`j'" 
	} 	
	
	capture confirm new var `new' 
	
	if _rc { 
		di as err "{p}sxpose2 would create new variables " ///
		          "_var1-_var`nobs', but names already in use{p_end}" 
		exit 110 
	} 	

	if "`format'" != "" { 
		capture di `format' 1234.56789 
		if _rc { 
			di as err "invalid %format" 
			exit 120 
		}
	}	
	else local format "%12.0g" 
	
	if `nvars' > `nobs' set obs `nvars' 

	unab varlist: * 
	tokenize `varlist' 

	qui forval j = 1/`nobs' { 
		gen _var`j' = "" 
		forval i = 1/`nvars' { 
			cap replace _var`j' = ``i''[`j'] in `i' 
			if _rc { 
				replace _var`j' = ///
				string(``i''[`j'], "`format'") in `i' 
			} 	
		} 	
	} 

	capture confirm variable ___000vlist?
	if !_rc {
		 di as err "{p}sxpose2 would create new variables " ///
			   "___000vlist?, but names already in use " ///
			   "please rename your variable ___000vlist before sxpose2"{p_end}"
		 exit 110      
	}
	
	gen ___000vlist="`varlist'"
	qui split ___000vlist

	capture confirm variable _varname
	if !_rc {
		 di as err "{p}sxpose2 would create new variables " ///
			   "_varname, but names already in use ssc" ///
			   "please rename your variable _varname before sxpose2"{p_end}"
		 exit 110      
	}
	
	qui if "`varname'" != "" {
		gen _varname=""
		forval j = 1/`nvars' {
			replace _varname =___000vlist`j' in `j'
			}
		}
		
	qui if "`varlabel'" != "" { 
		cap confirm variable _varlabel
		if !_rc { 
			exit 110 
			}
		qui gen str1 _varlabel = "" 
		local i 1                              
		foreach var of varlist `varlist' {	
			local lab: variable label `var' 
			replace _varlabel = `"`lab'"' in `i'  
			local i = `i' + 1
			}
		}
		
	drop `varlist' 
	if `nobs' > `nvars' qui keep in 1/`nvars' 

	qui if "`firstnames'" != "" { 
		forval j = 1/`nobs' { 
		capture rename _var`j' `= _var`j'[1]' 
		}
		drop in 1 
	} 	
		
	if "`destring'" != "" destring, replace 
	
	drop ___000vlist*
		
	if ( "`varlabel'" != "" & "`varname'" != "" ){ 
		capture order _varname _varlabel
		}
	if ( "`varlabel'" != "" & "`varname'" == "" ){ 
		capture order _varlabel
		}
	if ( "`varlabel'" == "" & "`varname'" != "" ){ 
		capture order _varname 
		}
	
end 

