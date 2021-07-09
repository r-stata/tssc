*svysd.ado
*Version 1.0.1--May 13, 2020



capture program drop svysd
program svysd, rclass
version 12.0

syntax varlist, SDBYvar(string) [UNWeighted NOWarning force]

local unw `" if "`unweighted'" == "unweighted" "'

tempname eb
tempfile temp_marginsave
qui capture estimates save `temp_marginsave', replace

*Dependent variable
tokenize `varlist'

if "`1'" == "" {
    di as error "Please include an outcome variable."
    exit = 100
    }

local depvar `"`1'"'
macro shift
if "`1'" != "" {
    di as error "Only one outcome variable is allowed."
    exit = 198
    }

tokenize "`sdbyvar'"
local mvar `"`1'"'
macro shift
if "`1'" != "" {
    di as error "Only one {cmd:sdbyvar} is allowed."
    exit = 198
    }

*sdbyvar
scalar sd_byvar = "`mvar'"

capture confirm variable `mvar'
if !_rc {
    }
else {
    di as error "The {cmd:sdbyvar} `mvar'" is not a variable."
    exit = 100
    }

qui levelsof `mvar'
tokenize "`r(levels)'"
scalar m_0 = `1'
macro shift
scalar m_1 = `1'
macro shift
if "`1'" != "" {
    di as error _n "The {cmd:sdbyvar} must be dichotomous."
    di as text "You might use {cmd:recode, generate()} to " ///
                "achieve a dichotomous variable."
    exit = 198
    }

*Make sure sdbyvar and depvar are not the same
if "`sdbyvar'" == "`depvar'" {
    di as error "The {cmd:sdbyvar} may not be the same as the outcome variable."
    exit = 198
    }

local vallab `"`: value label `depvar''"'
qui tab `depvar'

*Make sure the dependent variable is continuous
if  "`vallab'" == "Cont" | "`vallab'" == "" | `r(r)' > 8 {
    }
else if "`force'" != "force" {
    di as error "Hedges's {it:g} and Cohen's {it:d} may not be appropriate " ///
                "for your outcome variable" _n "as it appears to be categorical."
    di as error "Use the {cmd:force} option to bypass this check in the future."
    exit = 499
    }

scalar sdisfor = "`depvar'"
di as text _n "Calculating the survey-adjusted standard deviation for " ///
    "{cmd:`depvar'}, by {cmd:`mvar'}..."

*Estimate standard deviation
capture mi svyset  //check to see if it's mi svyset or not
if !_rc { //if it's mi svyset

    if "`r(settings)'" == ", clear" {
        di as error "Data must be either svyset or mi svyset"
        exit = 101
        }

    preserve
    qui mi passive:         gen double `depvar'_temp = `depvar'
    qui mi estimate, cmdok: svy, subpop(if `mvar' == `=m_0'): ///
                            intreg `depvar' `depvar'_temp 
    scalar                  sd_m0 = exp(el(e(b_mi),1,2))
    scalar                  n_m0 = `e(N_subpop_mi)'

    qui mi estimate, cmdok: svy, subpop(if `mvar' == `=m_1'): ///
                            intreg `depvar' `depvar'_temp   
    scalar                  sd_m1 = exp(el(e(b_mi),1,2))
    scalar                  n_m1 = `e(N_subpop_mi)'

    `unw' scalar pooledsd = sqrt( (sd_m0^2+sd_m1^2)/2 )
    else scalar sdstar = sqrt((((n_m0-1)*(sd_m0^2)) + ((n_m1-1)*(sd_m1^2)))/(n_m0 + n_m1 - 2))

    restore
}
else {
capture svyset
if !_rc { //if it's svyset but not mi svyset

    preserve
    qui gen                 double `depvar'_temp = `depvar'
    qui svy,                subpop(if `mvar' == `=m_0'): ///
                            intreg `depvar' `depvar'_temp  
    matrix                  `eb' = e(b)
    scalar                  sd_m0 = exp(el(`eb',1,2))
    scalar                  n_m0 = `e(N_subpop)'

    qui svy,                subpop(if `mvar' == `=m_1'): ///
                            intreg `depvar' `depvar'_temp  
    matrix                  `eb' = e(b)
    scalar                  sd_m1 = exp(el(`eb',1,2))
    scalar                  n_m1 = `e(N_subpop)'

    `unw' scalar pooledsd = sqrt( (sd_m0^2+sd_m1^2)/2 )
    else scalar sdstar = sqrt((((n_m0-1)*(sd_m0^2)) + ((n_m1-1)*(sd_m1^2)))/(n_m0 + n_m1 - 2))

    restore
    }

else {
    di as error "Data must be either svyset or mi svyset"
    exit = 101
    }
}

*Output standard deviation
`unw' {
    di as text _n "The pooled unweighted standard deviation for " ///
       as result "`=sdisfor'" as text " by " as result "`=sd_byvar'" ///
       as text " is: " as result `=pooledsd' 
    }
else {
    di as text _n "The pooled weighted standard deviation for " ///
       as result "`=sdisfor'" as text " by " as result "`=sd_byvar'" ///
       as text " is: " as result `=sdstar' 
    }

*Clean up
qui capture estimates use `temp_marginsave'

local sdby = abbrev("`sdbyvar'",12)

`unw' {
    return scalar pooledsd = `=pooledsd'
    capture scalar drop sdstar
    }
else {
    return scalar sdstar = `=sdstar'
    capture scalar drop pooledsd
    }

return scalar   sd_`sdby'_at_`=m_1' = `=sd_m1'
return scalar   sd_`sdby'_at_`=m_0' = `=sd_m0'
return scalar   n_`sdby'_at_`=m_1' = `=n_m1'
return scalar   n_`sdby'_at_`=m_0' = `=n_m0'
return local    sdbyvar "`mvar'"
return local    depvar "`depvar'"

end

