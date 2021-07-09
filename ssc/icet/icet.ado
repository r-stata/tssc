*! version 1.0 TMorris 20aug2013

** incorporates tuni into mice

program define icet, nclass sortpreserve
version 12
syntax varlist(min=1 numeric) [if] [in]  ///
  [ , ]	///
	[ METHOD(string)  ///
	COMPvars(string)	///
	ADD(int 5)  ///
	CYCLES(int 10) ///
  Powers(string)  ///
  TRUNCVAL(real 0.1)  ///
  KNN(int 10) ///
  BOOTstrap ///
  EQDisplay ///
  NOIsily ]

* ser up temp names
tempvar impvars imptmp imputeme
tempname expandno mistyle
local `impvars' `varlist'

* record mi style and mi un-set data before imputing
quietly mi query
local `mistyle' `r(style)'
quietly mi extract 0, clear

* generate indicators of response for each variable
foreach impvar of varlist ``impvars'' {
	tempvar R`impvar'
	quietly generate `R`impvar'' = !missing(`impvar')
}

* create imputed datasets with incomplete variables
local `expandno' = 1 + `add'
quietly gen _mi = _n
quietly expand ``expandno'', gen(`imputeme')
quietly gen _mj = 0 if `imputeme' == 0
quietly {
	bysort _mi: replace _mj = _n - 1
}
sort _mj _mi

* fill missing obs with random values sampled from observed data
* uses -initialise- subroutine
if "`eqdisplay'" != "" display as text "Prediction equations:"
foreach impvar of varlist ``impvars'' {
	initialise `imptmp' = `impvar'
	quietly replace `impvar' = `imptmp' if _mj > 0
	quietly drop `imptmp'
  local eq`impvar': list `impvars' - impvar
  if "`eqdisplay'" != "" display as text "->  `impvar'^p1* : f(`eq`impvar'') + `compvars'"
}

* Imputation step
display as text "Beginning `cycles' cycles for `add' imputations"
quietly mi set wide
forvalues c = 1/`cycles' {
  * Begin switching between variables
  foreach impvar of varlist ``impvars'' {
//  display as text "Cycle `c', imputing `impvar'"
    quietly replace `impvar' = . if `R`impvar'' == 0	// impose missing values again
//    quietly mi register passive `impvar'
//    if "`eqdisplay'" != "" display as text "Eq `impvar' = `eq`impvar'' + `compvars'"
    quietly tuni `impvar' `eq`impvar'' `compvars', by(_mj) add(1) `bootstrap' powers(-1(0.2)2) method(`method') knn(`knn') truncval(`truncval')
//    quietly replace `impvar' = . if `R`impvar'' == 0 & _mj == 0
  }
  noi _dots `c' 0 // display dots
  if "`noisily'" != "" display as text "Cycle " as result `c'
}


* Back to original mi style
//if "`r(style)'" != "wide" quietly mi convert ``mistyle'', clear
//sort _mj _mi
display as text _n "  " as result %-1.0f `add' as text " imputations of ``impvars'' complete"

end


* -initialise- fills missing obs with random values sampled from observed data
* code based on -sampmis- routine of -ice_-
program define initialise, sortpreserve
syntax newvarname =/exp
tempvar u
quietly gen double `u' = cond(missing(`exp'), _n, uniform())
sort `u'
quietly count if !missing(`exp')
local nonmis `r(N)'
drop `u'
local type: type `exp'
quietly gen `type' `varlist' = `exp'
local blocks = int( (_N - 1) / `nonmis' )
forvalues i = 1 / `blocks' {
	local j = `nonmis'*`i'
	local j1 = `j' + 1
	local j2 = min(`j' + `nonmis', _N)
	quietly replace `varlist' = `exp'[_n - `j'] in `j1' / `j2'
}
end

exit

History of icet
1.0 20aug2013   Program improved in parallel with tuni. Now imputes conditional on other impvars.
0.1 09aug2013		Program is working in principle but models for covariates only condition on compvars, not other impvars.
