*! lclogitpr version 1.00 - Last update: Mar 26, 2012 
*! Authors: Daniele Pacifico (daniele.pacifico@tesoro.it)
*!			Hong il Yoo 	 (h.yoo@unsw.edu.au)	

program define lclogitpr, sortpreserve
	version 11.2
	** Define macros **
	local pid "`e(id)'"
	local gid "`e(group)'"
	local depvar "`e(depvar)'"
	local C = e(nclasses)
	
	if ("`e(cmd)'" != "lclogit")&("`e(cmd)'" != "lclogitml") error 301
	
	syntax newvarname [if] [in] [,CLass(numlist >=1 <=`C') pr0 pr up cp ] 
	
	** Check whether specified options are valid **
	
	if ("`class'" != "") & ("`pr0'" != "") {
		display as error "class() and pr0 cannot be specified at the same time."
		exit 184
	}	
	
	local check : word count `pr0' `pr' `up' `cp'
	if (`check' > 1) {
		display as error "only one of pr0, pr, up and cp can be specified at a time." 
		exit 184
	}
	
	** Check that group, id and other explanatory variables are numeric **
	foreach v of varlist `e(group)' `e(id)' `e(indepvars)' `e(indepvars2)' {
		capture confirm numeric variable `v'
		if _rc != 0 {
			display as error "variable `v' is not numeric."
			exit 498
		}
	}	
	
	quietly {
	** Mark the prediction sample **
	marksample touse, novarlist
		
	** Sort sample ** 
	sort `pid' `gid'
	
	** Generate new temporary variables **
	forvalues c = 1/`C' {
		tempvar xb`c' xa`c' exb`c' exb`c'_sum exa`c' pr`c' lnpr`c' ll`c' up`c' cp`c' 
	}
	tempvar exa_sum pr ll
	
	** Generate prior probabilities of class membership
	generate double `exa_sum' = 1 if `touse' 
	forvalues c = 1/`=`C'-1' {
		_predict double `xa`c'' if `touse', xb equation(share`c')
		generate double `exa`c'' = exp(`xa`c'') if `touse'
		replace `exa_sum' = `exa_sum' + `exa`c'' if `touse'
	}	
	forvalues c = 1/`=`C'-1' {
		generate double `up`c'' = `exa`c'' / `exa_sum' if `touse' 
	}
	generate double `up`C'' = 1/ `exa_sum' if `touse' 
	
	if "`up'" == "up" {
		if "`class'" == "" {
			forvalues c = 1/`C' {
				generate `typlist' `varlist'`c' = `up`c'' if `touse'
				label variable `varlist'`c' `"prior probability of being in class `c'"'
			}
		}
		else {
			foreach n of numlist `class' {
				generate `typlist' `varlist'`n' = `up`n'' if `touse'
				label variable `varlist'`n' `"prior probability of being in class `n'"'
			}
		}
	}	
	
	else { 
		** Generate choice probabilities for each class
		forvalues c = 1/`C' {
			_predict double `xb`c'' if `touse', xb equation(choice`c')
			generate double `exb`c'' = exp(`xb`c'') if `touse'
		}	
		forvalues c = 1/`C' {
			by `pid' `gid' : egen double `exb`c'_sum' = sum(`exb`c'') if `touse'
			generate double `pr`c'' = `exb`c'' / `exb`c'_sum' if `touse'
		}
	
		** Generate weighted average choice probabilities
		generate double `pr' = 0 if `touse'
		forvalues c = 1/`C' {
			replace `pr' = `pr' + `up`c''*`pr`c'' if `touse' 
		}
		if ("`cp'" != "cp")&("`up'" != "up") {
			if "`class'" == "" {
				generate `typlist' `varlist' = `pr' if `touse'
				label variable `varlist' `"probability of choice unconditional on class"'
				if "`pr0'" == "" {
					forvalues c = 1/`C' {
						generate `typlist' `varlist'`c' = `pr`c'' if `touse'
						label variable `varlist'`c' `"probability of choice if in class `c'"'
					}
				}
			}
			else { 
				foreach n of numlist `class' {
					generate `typlist' `varlist'`n' = `pr`n'' if `touse'
					label variable `varlist'`n' `"probability of choice if in class `n'"'
				}			
			}
		}
		else if "`cp'" == "cp" {
			** Generate posterior probabilities of class membership 
			generate double `ll' = 0 if `touse'
			forvalues c = 1/`C' {
				generate double `lnpr`c'' = ln(`pr`c'')*`depvar' if `touse'  
				by `pid' : egen double `ll`c'' = sum(`lnpr`c'') if `touse'
				replace `ll`c'' = exp(`ll`c'') if `touse'
				replace `ll' = `ll' + `up`c''*`ll`c'' if `touse'
			}
			if "`class'" == "" {
				forvalues c = 1/`C' {
					generate double `varlist'`c' = `up`c''*`ll`c'' / `ll' if `touse'
					label variable `varlist'`c' `"posterior probability of being in class `c'"'
				}
			}
			else {
				foreach n of numlist `class' {
					generate double `varlist'`n' = `up`n''*`ll`n'' / `ll' if `touse'
					label variable `varlist'`n' `"posterior probability of being in class `n'"'
				}
			}
		}
	}
	}
end
