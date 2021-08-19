*! 1.0.0 NJC 18 March 2021 
program myaxis, sortpreserve 
	version 8.2 

	// syntax parsing 

	// starts: myaxis newvar = varname 
	gettoken newvar 0 : 0, parse(" =") 
	gettoken eqsign 0 : 0, parse("=") 
	syntax varname [if] [in], sort(str asis) ///
	[subset(str asis) DESCending varlabel(str asis) valuelabelname(passthru) MISSing] 

	capture confirm new var `newvar' 
	if "`eqsign'" != "=" exit 198 

	// data to use 
	if "`missing'" != "" marksample touse, novarlist 
	else marksample touse, strok 
	quietly count if `touse' 
	if r(N) == 0 error 2000

	if "`valuelabelname'" != "" { 
		capture label list `valuelabelname' 
		if _rc == 0 { 
			di as err "value labels `valuelabelname' already exist; specify new name?" 
			exit 498 
		} 
	}
	else { 
		capture label list `newvar' 
		if _rc == 0 { 
			di as err "value labels `newvar' already exist; specify new name?"
			exit 498 
		}
	} 

	// sort() option is key 
	// either like (count) meaning (count varname)  
	// or like (mean mpg)

	if "`subset'" != "" { 
		// does it make sense? are there are any such observations? 
		capture count if `touse' & `subset' 
		if _rc { 
			di as err "subset(`subset') not true or false condition?" 
			exit 498 
		} 
		if r(N) == 0 { 
			di as err "subset(`subset') not satisfied in data?"
			exit 2000 
		}
		local subset "& (`subset')" 
	} 

	tokenize `sort' 
	if "`1'" == "" | "`3'" != "" PROBLEM 
	
	tempvar work 

	if "`2'" != "" {
		capture confirm var `2' 
		if _rc { 
			di as err "`2' not an existing variable" 
			exit 111 
		}
	} 
	else local 2 "`varlist'" 

	// nub of the matter 
	quietly { 
 
		capture egen `work' = `1'(`2') if `touse' `subset', by(`varlist') 
		if _rc PROBLEM 
	
		if "`descending'" != "" replace `work' = -`work'  

		if "`subset'" != "" { 
			bysort `varlist' (`work') : replace `work' = `work'[1] 
		}  

		egen `newvar' = group(`work' `varlist') if `touse', missing 

	}

	// fix variable label: as supplied, or otherwise as on original variable, 
	// otherwise the original variable name 
	if `"`varlabel'"' == "" {
		local varlabel : variable label `varlist' 
		if `"`varlabel'"' == "" local varlabel "`varlist'" 
	}
	label variable `newvar' `"`varlabel'"' 

	// fix value labels: value labels of original, otherwise values of original
	local vallabel : value label `varlist' 
	if "`vallabel'" != "" { 
		_labmask `newvar' if `touse', values(`varlist') decode `valuelabelname' 
	}  
	else _labmask `newvar' if `touse', values(`varlist') `valuelabelname' 
end 

program PROBLEM 
	di as err "sort() invalid; see {help myaxis}" 
	exit 198 
end 

program _labmask, sortpreserve  
	// based on labmask 1.0.0 NJC 20 August 2002
	// values of -values-, or its value labels, to be labels of -varname-
	version 8.2 
	syntax varname(numeric) [if] [in], VALues(varname) [ valuelabelname(str) decode ]

	marksample touse, novarlist

	tempvar diff decoded group example 
	
	// do putative labels differ? 
	bysort `touse' `varlist' (`values'): /// 
		gen byte `diff' = (`values'[1] != `values'[_N]) * `touse' 
	su `diff', meanonly 
	if r(max) == 1 { 
		di as err "`values' not constant within groups of `varlist'" 
		exit 198 
	} 

	// decode? i.e. use value labels (will exit if value labels not assigned) 
	if "`decode'" != "" { 
		decode `values', gen(`decoded') 
		local values "`decoded'" 
	} 	

	// we're in business 
	if "`valuelabelname'" == ""  local valuelabelname "`varlist'" 
	
	// groups of values of -varlist-; assign labels 
	
	by `touse' `varlist' : gen byte `group' = (_n == 1) & `touse' 
	qui replace `group' = sum(`group') 

	gen long `example' = _n 
	local max = `group'[_N]  
	
	forval i = 1 / `max' { 
		su `example' if `group' == `i', meanonly 
		local label = `values'[`r(min)'] 
		local value = `varlist'[`r(min)'] 
		label def `valuelabelname' `value' `"`label'"', modify 	
	} 

	label val `varlist' `valuelabelname' 
end 


