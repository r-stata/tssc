*omega.ado
*Version 1.1--February 27, 2021

capture program drop omega
program omega, rclass
version 12.0

syntax varlist [, ITERate(integer 1000) USEMissing REVerse(varlist) NOREVerse(varlist)]

capture mi svyset
if !_rc {
    di as error "omega does not support survey weights."
    exit
    }
else {
    capture svyset
    if _rc != 0 {
        di as error "omega does not support survey weights."
        exit
        }
    }

qui ssd query
if `r(isSSD)' ==  1 {
    di as error "omega does not support summary statistics data."
    exit
    }

tokenize `varlist'
local i = 1
local k = 0
while `i' < 111 {
    capture confirm variable `1'
    if _rc & `"`1'"' != "" {
        di as error "`1' is not a variable."
        exit = 111
        }
    else if `"`1'"' == "" {
        continue, break
        }
    else {
        local var_`i' = `"`1'"'
        local ++i
        local ++k 
        macro shift
        }
    }

local vars ""
forvalues i=1/`k' {
    local vars = "`vars' `var_`i''"
    }

if `k' < 3 {
    di as error "Omega requires at least three variables to esimate."
    exit = 102 
    }

tokenize `reverse'
local k_rev = 0
local i = 1
while `i' < 111 {
    if `"`1'"' == "" {
        continue, break
        }
    else {
        local rev_`i' = `"`1'"'
        local ++i
        macro shift
        }
    }

tokenize `noreverse'
local k_norev = 0
local i = 1
while `i' < 111 {
    if `"`1'"' == "" {
        continue, break
        }
    else {
        local norev_`i' = `"`1'"'
        local ++i
        macro shift
        }
    }

if "`usemissing'" == "usemissing" local method "method(mlmv)"
else local method " "

di as text "Calculating McDonald's omega/Raykov's rho..." _n

qui sem (Factor -> `vars'), latent(Factor) var(Factor@1) nocapslatent ///
                            iterate(`iterate') `method' standardized

if `e(converged)' == 0 {
    di as error "omega could not be computed."
    di "Ensure that all variables are continuous, and"
    di "do not have correlations near -1 or +1." 
    exit = 430
    }

local bs = 0
local reversed ""
forvalues i=1/`k' {
    local rev = 0
    local col = (`i'*2)-1
    local b = el(e(b_std),1,`col')

    if `b' < 0 local rev = 1

    forvalues j = 1/`k' {
        if "`var_`i''" == "`rev_`j''" local rev = 1
        }

    forvalues j = 1/`k' {
        if "`var_`i''" == "`norev_`j''" local rev = 0
        }

    if `rev' == 1 {
        local bs = `bs' + abs(`b')
        local reversed = "`reversed' `var_`i''"
        }
    else local bs = `bs' + `b'

    if `b' < 0 & `rev' == 0 {
        di as error "WARNING: " as text "You specified variable `var_`i'' " ///
            "as noreverse, but its factor loading is negative." 
            di "You should strongly consider allowing it to be reverse coded" 
            di "in order to ensure that the results are trustworthy." _n
        }
    }


matrix B = e(b_std)
local cols = colsof(B)

local vs = 0
forvalues i=1/`k' {
    local col = `cols' - `k' + `i' - 1     
    local v = el(e(b_std),1,`col')
    local vs = `vs' + `v'
    }

local omega = (`bs'^2) / (`bs'^2+`vs')

if "`reversed'" != "" {
    di as text _n "NOTE: some of your items were treated as reverse coded."
    di "Reversed items: {cmd:`reversed'}" _n
    }

di as txt "Number of items in the scale:"  _col(34) as res %9.0f `k'
di as txt "Scale reliability coefficient:" _col(34) as res %9.4f `omega'

return scalar k = `k'
return scalar omega = `omega'

end
