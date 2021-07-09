*mces.ado
*Version 1.0.1--May 13, 2020



capture program drop mces
program mces, rclass
version 12.0

syntax , SDBYvar(string) [ SDUpdate COHensd NOWarning Force]

tempname B C E D


local coh `" if "`cohensd'" == "cohensd" "'
local unw " "
`coh' local unw "unweighted"

`coh' local esname `"Cohen's {it:d}"'
else local esname `"Hedges's {it:g}"'

*check to see if it's svyset, mi svyset, or not
capture mi svyset
if !_rc {
    if "`r(settings)'" == ", clear" local svyflag = 0
    else local svyflag = 1
    }
else {
    capture svyset
    local rsettings = "`r(settings)'"
    if "`rsettings'" != ", clear" local svyflag = 1
    else {
        local svyflag = 0
        }
    }

*make sure that sdbyvar is a variable
confirm variable `sdbyvar'

*check that -pwcompare- actually has something to compare
if strpos(`"`e(cmdline)'"', "pwcompare") > 0 & `"`e(cmd)'"' != "pwcompare" {
    di as error _n "{cmd:mces} requires at least two estimates for comparison."
    exit = 301    
    }
*check that -contrast- actually has something to compare
if strpos(`"`e(cmdline)'"', "contrast") > 0 & `"`e(cmd)'"' != "contrast" {
    di as error _n "{cmd:mces} requires at least two estimates for comparison."
    exit = 301    
    }

*make sure that the last command was -margins- or -mimrgns-
if `"`e(cmd2)'"' == "margins" {
    local miflag = 0
    }
else if `"`e(cmd2)'"' == "mimrgns"  {
    local miflag = 1
    }
else {
    di as error _n "The following commands are supported in {cmd:mces}: "
    di as text "{cmd:margins, pwcompare post} or {cmd:margins, contrast post}" 
    di as text "{cmd:mimrgns, pwcompare post} or {cmd:mimrgns, contrast post}" 
    exit = 301
    }

local mi "if `miflag' == 1"

*make sure that margins included -pwcompare- or -contrast- 
if `"`e(cmd)'"' == "pwcompare" {
    local cflag = 0
    }
else if `"`e(cmd)'"' == "contrast" {
    local cflag = 1
    }
else {
    di as error _n "The following commands are supported in {cmd:mces}: "
    di as text "{cmd:margins, pwcompare post} or {cmd:margins, contrast post}" 
    di as text "{cmd:mimrgns, pwcompare post} or {cmd:mimrgns, contrast post}" 
    exit = 301
    }

local con "if `cflag' == 1"


*Name matrices
`coh' {
    `con' matrix `C' = e(b)
    else matrix `C' = e(b_vs)
    local nummargins = colsof(`C')
    }
else {
    `con' matrix `B' = e(b)
    else matrix `B' = e(b_vs)
    local nummargins = colsof(`B')
    }


`mi' & `cflag' == 0 matrix `D' = e(df_vs)
`mi' & `cflag' == 1 matrix `D' = e(df_mi)


`con' matrix `E' = e(error)
else matrix `E' = e(error_vs)


*Confirm that matrices exist
local er1 "Either something has cleared the stored estimation results,"
local er2 "or your estimation command is not supported." 
local errmsg `"_n `er1'" _n "`er2'"'

`coh' {
    capture confirm matrix `C'
    if _rc {
        di as error "`errmsg'"
        exit = 301
        } 
   }
else {
    capture confirm matrix `B'
    if _rc {
        di as error "`errmsg'"
        exit = 301
        }
    }

capture confirm matrix `E'
if _rc {
    di as error "`errmsg'"
    exit = 301
    }


*get the dependent variable from -margins- or -mimrgns-
local cmdline `e(est_cmdline)'

local pos = 1
while `pos' > 0 {
    local pos = ustrpos(`"`cmdline'"',":")
    local len = ustrlen(`"`cmdline'"')
    local rlen = `len' - `pos'
    local cmdline = ustrright(`"`cmdline'"',`rlen')
    }

tokenize `"`cmdline'"'
local i = 1
while `i' < 111 {
    capture confirm variable `1'
    if _rc {
        local ++i 
        macro shift
        }
    else {
        local depvar `"`1'"'
        continue, break
        }
    }

*Make sure sdbyvar and depvar are not the same
if "`sdbyvar'" == "`depvar'" {
    di as error _n "The {cmd:sdbyvar} may not be the same as the outcome variable."
    exit = 198
    }

local vallab `"`: value label `depvar''"'
qui tab `depvar'

*Make sure the dependent variable is continuous
if  "`vallab'" == "Cont" | "`vallab'" == "" | `r(r)' > 8 {
    }
else if "`force'" != "force" {
    di as error _n "`esname' may not be appropriate for your " ///
                "outcome variable as it appears to be categorical."
    di "Use the {cmd:force} option to bypass this check in the future."
    exit = 499
    }

local w1 "The standard deviation used to estimate `esname' only applies to ceteris paribus"
local w2 "    comparisons between groups defined by {cmd:`sdbyvar'}. Otherwise, the results are invalid."
local w3 "Ensure that this condition applies to each line of the {cmd:margins} results."
local w4 "You may want to run {cmd:margins} followed by {cmd:mces} once per dichotomous comparison."
local warning `"_n as error "WARNING: " as text "`w1'" _n "`w2'" _n "`w3'" _n "`w4'" _n"'

local e1 "The standard deviation used to estimate `esname' only applies to ceteris"
local e2 "    paribus comparisons between the two groups defined by {cmd:`sdbyvar'}."
local e3 "The estimated effect sizes are invalid if the {cmd:marginlist} contains more than one variable,"
local e4 "    or if there are too many {cmd:by/over/within/at} variables,"
local e5 "    or if there are more than two values of a {cmd:by/over/within/at} variable."
local e6 "You may want to run {cmd:margins} followed by {cmd:mces} once per dichotomous comparison."
local e7 "You might also try {cmd:recode, generate()} to generate dichotomous comparison variables."
local exit_warning `"_n as error "ERROR: " as text "`e1'" _n "`e2'" _n "`e3'" _n "`e4'" _n "`e5'" _n "`e6'" _n "`e7'" _n"'

*count mvars
tokenize "`e(cmdline)'", parse(",")
tokenize "`1'"
local mvars = 0

while "`1'" != "" {
    capture confirm variable `1'
    if !_rc local ++mvars
    macro shift
    }

*count mvar categories
tokenize "`e(margins)'", parse(".")
tokenize "`1'", parse(")i( ")
local marvals = 0
while "`1'" != "" {
    local isnum = real("`1'")
    if `isnum' != . local ++marvals
    macro shift
    }

*count byvars
tokenize "`e(by)'"
local byvars = 0

while "`1'" != "" {
    local ++byvars
    macro shift
    }

*count atvar categories
if "`e(atstats2)'" != "" local atvars = 2
else if "`e(atstats1)'" != "" local atvars = 1
else local atvars = 0

*Multiple mvars or 1 mvar & 2+ byvars
if `mvars' > 1 | (`mvars' == 1 & `byvars' > 1) {
    di `exit_warning'
    exit = 103
    }
*Too many byvars or values, or 3+ at values
else if  "`e(atstats3)'" != "" | "`e(by5)'" != "" | `byvars' >= 3 {
    di `exit_warning'
    exit = 134
    }
*Too many values of mvar
else if `marvals' > 2 {
    di `exit_warning'
    exit = 134
    }
*One mvar, one atvar (not oneat), one byvar
else if `mvars' >= 1 & `byvars' == 1 & `atvars' == 2 {
    di `exit_warning'
    exit = 134
    }
*One mvar, one atvar (oneat), one byvar
else if `mvars' == 1 & `byvars' == 1 & `atvars' == 1 {
    local warn = 1
    }
*One mvar, no atvar (or one atspec), one byvar
else if `mvars' == 1 & `byvars' == 1 & `atvars' <= 1 {
    local warn = 1
    }
*Two atstats plus one byvar or one mvar 
else if `atvars' == 2 & (`byvars' >= 1 | `mvars' >= 1) {
    local warn = 1
    }
*Two atstats OR two byvars 
else if `atvars' == 2 | `byvars' == 2 {
    local warn = 1
    }
else {
    local warn = 0
    }

*Standard deviation
`coh' local sdscalar pooledsd
else local sdscalar sdstar


*Sampling weights
if `svyflag' == 1 {
    *check to see if -svysd- is necessary
    capture confirm scalar sd_byvar
    if _rc scalar sd_byvar = " "

    if "`sdupdate'" == "sdupdate" { // -sdupdate- option
        svysd `depvar', sdbyvar(`sdbyvar') force `unw'
        }
    else {
        capture confirm scalar sdisfor
        if _rc { // sdisfor is NOT a scalar
            svysd `depvar', sdbyvar(`sdbyvar') force `unw'
            }
        else {
            capture confirm scalar `sdscalar'
            if _rc { // the sdscalar is NOT a scalar
                svysd `depvar', sdbyvar(`sdbyvar') force `unw'
                }
            else if "`depvar'" != "`=sdisfor'" { // SD exists but wrong depvar
                svysd `depvar', sdbyvar(`sdbyvar') force `unw'
                }
            else if "`=sd_byvar'" != "`sdbyvar'" { // the SD exists but wrong sdvar
                svysd `depvar', sdbyvar(`sdbyvar') force `unw'
                }
            else {
                di _n as text "Using previously calculated standard deviation " ///
                "for " as result "`=sdisfor'" as text ", by " ///
                as result "`sdbyvar'" as text "..."
                }
           }
        }
    }
*Unweighted
else {
    qui levelsof `sdbyvar'
    tokenize "`r(levels)'"
    scalar m_0 = `1'
    macro shift
    scalar m_1 = `1'
    macro shift
    if "`1'" != "" {
        di as error _n "The {cmd:sdbyvar} must be dichotomous to calculate " ///
                        "the effect size."
        di as text "You might use {cmd:recode, generate()} to " ///
                    "achieve a dichotomous variable."
        exit = 198
        }
    qui summ `depvar' if `sdbyvar' == `=m_0'
    scalar sd_m0 = `r(sd)'
    scalar n_m0 = `r(N)'
    qui summ `depvar' if `sdbyvar' == `=m_1'
    scalar sd_m1 = `r(sd)'
    scalar n_m1 = `r(N)'
    `coh' scalar pooledsd = sqrt( (sd_m0^2+sd_m1^2)/2 )
    else scalar sdstar = sqrt((((n_m0-1)*(sd_m0^2)) + ((n_m1-1)*(sd_m1^2)))/(n_m0 + n_m1 - 2))
    }


*Calculate effect size

di as text _n "Calculating values of `esname'..."

if "`nowarning'" != "nowarning" {
    if `warn' == 1 di `warning'
    }

*Cohen's d
`coh' {
    forvalues b = 1/`nummargins' {
        matrix `C'[1,`b'] = el(`C',1,`b')/`=pooledsd'
        }
    matrix rownames `C' = d
    local matname `C'
    }

*Hedges's g
else {
    forvalues b = 1/`nummargins' {
        matrix `B'[1,`b'] = el(`B',1,`b')/`=sdstar'
        }
    matrix rownames `B' = g
    local matname `B'
    }

*Display  effect size
local size = c(linesize)
set linesize 120

`mi' {
_coef_table, bmat(`matname') emat(`E') dfmat(`D') compare ///
            coeftitle(`esname') cformat(%-9.2f) 
    }
else {
_coef_table, bmat(`matname') emat(`E') compare ///
            coeftitle(`esname') cformat(%-9.2f) 
    }

*Clean up
set linesize `size'

local sdby = abbrev("`sdbyvar'",12)

`coh' return matrix d = `C', copy
else return matrix g = `B', copy

`coh' {
    return scalar pooledsd = `=pooledsd'
    }
else {
    return scalar sdstar = `=sdstar'
    }

return scalar   sd_`sdby'_at_`=m_1' = `=sd_m1'
return scalar   sd_`sdby'_at_`=m_0' = `=sd_m0'
return scalar   n_`sdby'_at_`=m_1' = `=n_m1'
return scalar   n_`sdby'_at_`=m_0' = `=n_m0'
return local    sdbyvar "`sdbyvar'"
return local    depvar "`depvar'"

end


