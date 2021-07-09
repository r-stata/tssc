*! Author PWJ
*! Date: July 23, 2008
program define paverage
	syntax varlist, p(string) INDiv(varname) yr(varname)
	tempvar year1 year2
	if inlist(`"`p'"', "2", "3", "4", "5", "6", "7", "8", "9", "10")==0 {
		di as err "p takes one the following: 2, 3, 4, 5, 6, 7,, 8, 9, and 10"
		exit 198
	}
	* Check whether the panel is balanced
	sort `indiv'
      tempvar nobs
      qui by `indiv': gen `nobs' = _N
      capture assert `nobs' == `nobs'[1]
      if c(rc) {
		di
            di as err "{bf:{it:paverage}} works only with balanced panel datasets"
		exit 198
      }       
	local pn=real("`p'")
	qui sum `yr' 
	local n=(r(max)-r(min)+1)/`pn'
	capture confirm integer n `n'
	if !_rc {
		bysort `indiv': egen `year1'=seq(), f(1) t(`n') b(`pn')
		qui {
			foreach var of local varlist {
				by `indiv' `year1', sort: egen mean`var'=mean(`var')
				replace `var'=mean`var'
				drop mean`var'
			}		
			bysort `indiv': egen `year2'=seq(), f(1) t(`pn')
			by `indiv' `year1', sort: keep if `year2'==`pn'
		}
	}
	else { 
		di as err "The time period is not a multiple of `pn'"
		exit 198
	}
end
