*! version 1.0  07mar2017

*===============================================================================
*
*  Copyright (C) 2017  Joss Roßmann
*
*  This program is free software: you can redistribute it and/or modify
*  it under the terms of the GNU General Public License as published by
*  the Free Software Foundation, either version 3 of the License, or
*  (at your option) any later version.
*
*  This program is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
*  GNU General Public License for more details <http://www.gnu.org/licenses/>.          
*
*  Recommended citation (APA Style, 6th ed.): 
*  Roßmann, J. (2017). RESPDIFF: Stata module for generating
*  response differentiation indices (Version: 1.0) 
*  [Computer Software]. Chestnut Hill, MA: Boston College.
*
*===============================================================================

program define respdiff, byable(onecall) sortpreserve
	version 12.1
	
	gettoken name 0 : 0, parse(" =(")
	gettoken eqsign 0 : 0, parse(" =(")
	if `"`eqsign'"' != "=" {
		error 198
	}
    confirm new variable `name'
	gettoken fcn 0 : 0, parse(" =(")
	gettoken args 0 : 0, parse(" ,") match(par)
	if `"`par'"' != "(" { 
			exit 198 
	}
	if `"`args'"' == "_all" | `"`args'"' == "*" {
			unab args : _all
			local args : subinstr local args "`_sortindex'"  "", all word
	}
	
	foreach var of varlist `args' {
		capture confirm numeric variable `var'
		if !_rc {
			local args_num "`args_num' `var'"
		}
	}
	
	syntax [if] [in] [, *]
	if `"`options'"' != "" { 
			local cma ","
	}
	tempvar rtrn
	capture noisily `fcn' `rtrn' = (`args_num') `if' `in' `cma' `options'
	if _rc { 
		exit _rc 
	}
	quietly count if missing(`rtrn')
	if r(N) { 
			local s = cond(r(N)>1,"s","")
			di in bl "(" r(N) " missing value`s' generated)"
	}
	rename `rtrn' `name'
end


*====== FUNCTION: STANDARD DEVIATION =====*
program define sd
        version 12.1
        gettoken rtrn 0 : 0
        gettoken eqsgn 0 : 0
		
        syntax varlist(min=2) [if] [in]

        tempvar nobs mean sqdev touse
        mark `touse' `if' `in'
		quietly {
			gen double `mean' = 0 if `touse'
			gen long `nobs' = 0 if `touse'
			gen double `sqdev' = 0 if `touse'
			tokenize `varlist'
			local i 1
			while "``i''"!="" {
				replace `mean' = `mean' + cond(``i''>=.,0,``i'') if `touse'
				replace `nobs' = `nobs' + (``i''<.) if `touse'
				local i = `i' + 1
			}
			replace `mean' = `mean' / `nobs' if `touse'
			local i 1
			while "``i''" != "" { 
				replace `sqdev'=`sqdev'+cond(``i''>=.,0,``i''-`mean')^2 `if' `in'
				local i = `i' + 1
			}
			drop `mean'
			gen `rtrn' = cond(`nobs'==0,.,sqrt(`sqdev'/(`nobs'-1))) if `touse'
			lab var `rtrn' "Standard deviation of responses"
		}
end


*====== FUNCTION: STANDARDIZED STANDARD DEVIATION =====*
program define stdsd
        version 12.1
        gettoken rtrn 0 : 0
        gettoken eqsgn 0 : 0
		
        syntax varlist(min=2) [if] [in]

        tempvar nobs mean sqdev touse
        mark `touse' `if' `in'
		quietly {
			gen double `mean' = 0 if `touse'
			gen long `nobs' = 0 if `touse'
			gen double `sqdev' = 0 if `touse'
			tokenize `varlist'
			local i 1
			while "``i''"!="" {
				replace `mean' = `mean' + cond(``i''>=.,0,``i'') if `touse'
				replace `nobs' = `nobs' + (``i''<.) if `touse'
				local i = `i' + 1
			}
			replace `mean' = `mean' / `nobs' if `touse'
			local i 1
			while "``i''" != "" { 
				replace `sqdev'=`sqdev'+cond(``i''>=.,0,``i''-`mean')^2 `if' `in'
				local i = `i' + 1
			}
			drop `mean'
			gen `rtrn' = cond(`nobs'==0,.,sqrt(`sqdev'/(`nobs'-1))) if `touse'
			sum `rtrn' if `touse'
			replace `rtrn' = (`rtrn'-r(mean))/r(sd) if `touse'
			lab var `rtrn' "z-standardized standard deviation of responses"
		}
end


*====== FUNCTION: COEFFICIENT OF VARIATION =====*
program define cv
        version 12.1
        gettoken rtrn 0 : 0
        gettoken eqsgn 0 : 0

        syntax varlist(min=2) [if] [in]

        tempvar nobs mean sqdev sd touse
        mark `touse' `if' `in'
		quietly {
			gen double `mean' = 0 if `touse'
			gen long `nobs' = 0 if `touse'
			gen double `sqdev' = 0 if `touse'
			gen double `sd' = 0 if `touse'
			tokenize `varlist'
			local i 1
			while "``i''"!="" {
				replace `mean' = `mean' + cond(``i''>=.,0,``i'') if `touse'
				replace `nobs' = `nobs' + (``i''<.) if `touse'
				local i = `i' + 1
			}
			replace `mean' = `mean' / `nobs' if `touse'
			local i 1
			while "``i''" != "" { 
				replace `sqdev'=`sqdev'+cond(``i''>=.,0,``i''-`mean')^2 `if' `in'
				local i = `i' + 1
			}
			replace `sd' = cond(`nobs'==0,.,sqrt(`sqdev'/(`nobs'-1))) if `touse'
			gen `rtrn' = cond(`nobs'==0,.,`sd'/`mean') if `touse'
			lab var `rtrn' "Coefficient of variation of responses"
		}
end


*====== FUNCTION: NON-DIFFERENTIATED RESPONSE PATTERNS =====*
program define nondiff
        version 12.1
        gettoken rtrn 0 : 0
		gettoken eqsgn 0 : 0
		gettoken args_num 0 : 0, parse(" ,") match(par)
		capture noisily sd `rtrn' = (`args_num') `if' `in' `cma' `options'
        
		syntax [if] [in]
				
        tempvar nondiff touse
        mark `touse' `if' `in'
		quietly {
			gen double `nondiff' = 0 if `touse' & `rtrn' != .
			replace `nondiff' = 1 if `touse' & `rtrn' == 0
			drop `rtrn'
			gen `rtrn' = `nondiff' if `touse'
			lab var `rtrn' "Non-differentiated response patterns"
		}
end


