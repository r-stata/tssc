
** Draws a value p*, imputes x^p* and passively imputes x^1 M times
*  This version adds PMM functionality
*  and allows the user to define values of p* to consider via power() option
program define tuni, nclass
version 12.0
syntax varlist(min=1 numeric) [if] [in]  ///
  [ , ] ///
  [ method(string)  ///
	add(int 0)  ///
  replace ///
  by(string)  ///
  POWers(string)  ///
  truncval(real 0.1)  ///
  knn(int 10) ///
  BOOTstrap ///
  NOIsily ]

marksample touse

* Check for silly instuctions
capture quietly mi query
if c(rc) != 0 {
	display as error "data not mi set"
	exit 119
}
if `r(M)' == 0 {
  local replace  // cannot use replace if no existing imputations
  if `add' == 0 | `add' == . {
    display as error "option {bf:add()} is required when no imputations exist"
    exit 198
  }
}
if `add' > 1000 {
  display as error "Cannot input values larger than 1000 in add(#)"
  exit 125
}
else if `add' == 0 local addnum  // add none, use in conjunction with replace
else local addnum 1
if "`method'" == "" local method pmm // makes pmm the default if method is not specified
if "`method'" == "pmm" local pmm pmm
else if "`method'" == "truncreg" local truncreg truncreg
else {
  display as error "Option method() must contain either truncreg or pmm"
  exit 198
}
if "`truncreg'" != "" & `knn' != . {
  display as error "Option knn() and truncval() may not be combined"
  display as error "knn() can only be used with method(pmm); truncval can only be used with method(truncreg)"
  exit 184
}

if "`replace'" != "" {
	local M = `add' + `r(M)'
}
else {
	local M = `add'
}
gettoken impvar compvars : varlist

quietly misstable summ `impvar'
if "`r(vartype)'" == "none" {
	display as text "note: variable " as input "`impvar'" as text " contains no soft missing (.) values"
	display as text "(imputation variable is complete; imputing nothing)"
	exit
}
quietly misstable summ `compvars' if `touse'
if "`r(vartype)'" != "none" {
	display as error "one or more complete variables contains missing values"
	display as error "(check `compvars' for missing values)"
	exit 416
}
assert `truncval' > 0
if c(rc) != 0 {
	display as error "truncval must be positive"
	exit 459
}
* decide on range for p*
if "`powers'" == "" local range -2(0.2)3
else local range `powers'

if "`truncreg'" != "" noi display as text "tuni-ing, using truncated regression with constraint `impvar' > " as input `truncval'
else if "`pmm'" != "" noi display as text "tuni-ing, using PMM with knn(" `knn' ")"
display as text "Powers considered: `range'"

tempfile pre_imp
tempvar xp jacobian
tempname  mjimp  mjnull  ll  j  llj  lljmax
quietly generate `xp' = . // will contain x^`p'
//lab var `xp' "x^p*"
quietly mi register imputed `xp'
quietly mi unregister `impvar'
quietly save `pre_imp'

* draw `pstar' via single bootstrap for each imputed dataset
quietly levelsof _mj
local `mjimp' = r(levels)
gettoken `mjnull' `mjimp': `mjimp'
foreach m of numlist ``mjimp'' {
  quietly keep if _mj == `m'
	bsample if `impvar' != .
	//local r2max 0 // out of use because prefer MLE via ll + ln(J)
	local `lljmax' -1.000e+20 // initial log(L + J) set to a very low value
	* loop through values of p
/*	forvalues t = 1/26 {
		local p = (`t'-11)/5*/
  forvalues p = `range' {
		if abs(`p') < 0.00001 { // log transformation
			quietly replace `xp' = ln(`impvar')
		}
		else {
			quietly replace `xp' = `impvar'^`p'
		}
		quietly regress `xp' `compvars'
		local `ll' = `e(ll)'
		capture drop `jacobian'
		if abs(`p') < .00001 quietly generate `jacobian' = -ln(`impvar')
		else quietly generate `jacobian' = ln(abs(`p')) + (`p'-1) * ln(`impvar')
		quietly summarize `jacobian'
		local `j' = `r(sum)'
		local `llj' = ``ll'' + ``j''
//		if "`noisily'" != "" display as text "m = " `m' ", p-hat = " `p' ", lljmax = " ``lljmax'' ", llj = " as result ``llj''
		if ``llj'' > ``lljmax'' {
			local `lljmax' = ``llj''
			local pstar`m' = `p'
		}
	}
//  if "`noisily'" != "" display as text "In ABB loop `m', p* = " as result `pstar`m''
	use `pre_imp', clear
}

* Imputation, one at a time, cycling through stored values of `pstar`m''
foreach m of numlist ``mjimp'' {
	if abs(`pstar`m'') < 0.00001 {
		quietly replace `xp' = ln(`impvar') if _mj == `m'
		local lltrunc`m' = ln(`truncval')
		local ultrunc`m'
	}
	else if `pstar`m'' <= -.00001 {
		quietly replace `xp' = `impvar'^`pstar`m'' if _mj == `m'
		local lltrunc`m' // convert trunc boundary to scale of x^p*
		local ultrunc`m' = `truncval'^`pstar`m''
	}
	else if `pstar`m'' >= .00001 { // convert trunc boundary to scale of x^p*
		quietly replace `xp' = `impvar'^`pstar`m'' if _mj == `m'
		local lltrunc`m' = `truncval'^`pstar`m''
		local ultrunc`m'
	}
  if "`noisily'" != "" display as text "In m = `m', p* = " as result `pstar`m''
*  inspect `xp'
  * Impute using truncated regression (unworkable in my efficient version of imputation)
  if "`truncreg'" != "" {
    quietly mi impute truncreg `xp' `compvars' if `touse', by(`by') `bootstrap' ll(`lltrunc`m'') ul(`ultrunc`m'')  add(`addnum') replace
  }
}
* Impute using pmm
if "`pmm'" != "" {
  quietly mi impute pmm `xp' `compvars' if _mj != 0, by(`by') `bootstrap' knn(`knn') add(`addnum') replace
}
foreach m of numlist ``mjimp'' {
  if abs(`pstar`m'') < 0.00001 quietly replace `impvar' = exp(_1_`xp') if _mj == `m'
  else quietly replace `impvar' = _1_`xp'^(1/`pstar`m'') if _mj == `m'
}
//	if `pstar`m'' == 0 quietly mi passive: replace `impvar' = exp(`xp')
//	else quietly mi passive: replace `impvar' = `xp'^(1/`pstar`m'')
//	noi _dots `M' 0 // display dots
//	if "`noisily'" != "" {
//		display as text " m = " as result %-1.0f `m' as text ", imputing for `impvar'^" as result `pstar`m''
//	}

quietly erase `pre_imp'
//quietly mi register imputed `impvar'
quietly mi update
quietly mi unregister `xp'
quietly drop `xp'
display as text "" _n "  " as result %-1.0f `M' as text " imputations produceed for `impvar'"
end 
