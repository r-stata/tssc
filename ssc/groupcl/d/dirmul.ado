*! version 1.1.1  08may2007
* Estimates the Dirichlet-Multinomial regression
* Author: Paulo Guimaraes
* version 1.0.1 first distribution to SSC
* version 1.1 added option to compute Pearson chi-square
* version 1.1.1 corrected bugs with starting values for eqcorr option

program dirmul, eclass sortpreserve
    version 9.1
    if replay() {
    if ("`e(cmd)'"!="dirmul") error 301
    Replay `0'
    }
    else Estimate `0'
end

program define Estimate, eclass sortpreserve
*************************************************************************************
* CHECKING SYNTAX & SAMPLE TO USE
************************************************************************************
    syntax varlist [if] [in],         ///
        GRoup(varname)                ///
        [STMul                        /// Use Grouped Multinomial for st values
        STRho(real 0.1)               /// Starting value for rho
        EQcorr                        /// Assume equicorrelated choices
        pearson                       /// Compute Pearson statistic
        var2(varlist numeric)         /// variables for groups
        Level(cilevel)                ///
        noLOg                         ///
        *                             ///
        ]
    mlopts mlopts, `options'
    marksample touse
    markout `touse' `group'
    markout `touse' `var2'
**********************************************************************************

******************************************************
* COLLECT INFORMATION ABOUT OPTIONS SELECTED
************************************************************
* 
************************************************************
gettoken lhs rhs_eq1: varlist
local rhsall `rhs_eq1' `var2'

if "`eqcorr'"=="" {
    local title "Dirichlet-Multinomial - Par1"
    local prog  "dirmul1_ll"
    local dtype "d1"
    local rhs `rhsall'
    }
else {
    local title "Dirichlet-Multinomial - Par2"
    local prog  "dirmul2_ll"
    local rhs `rhs_eq1'
    local offopt "(rho:`var2')"
    local constan "nocons"
    local dtype "d0"
}

confirm variable `group'
global GROUP `group'

************************************************************

************************************************************
* DO ADDITIONAL CHECKS ON THE DATA
************************************************************

* Abort if any problem is found
/* Count obs and check for negative values of y. */

summarize `lhs' if `touse', meanonly

if `strho'>=1|`strho'<=0 {
di "strho must be between 0 and 1"
error 2000
    }

if r(N) == 0 {
    error 2000
    }

if r(N) == 1 {
    error 2001
    }

if r(min) < 0 {
    di in red "`lhs' must be greater than or equal to zero"
    exit 459
    }

if r(min) == r(max) & r(min) == 0 {
    di in red "`lhs' is zero for all observations"
    exit 498
    }

capture assert `lhs' == int(`lhs') if `touse'

if _rc {
    di in gr "note: you are responsible for " ///
    "interpretation of non-count dep. variable"
    }

tempvar nn
gen long `nn' = _n
sort `touse' `group' `nn'
DropOne `touse' `group' `lhs' `nn'
DropZero `touse' `group' `lhs' `nn'

summarize `lhs' if `touse', meanonly
tempname meany
scalar `meany' = r(mean)
*******************************************************
* Generate starting values
*******************************************************
if "`stmul'"=="" {
capture poisson `lhs' `rhsall' if `touse', iter(1)
if _rc == 0 {
    tempname b0 b1 b2
    mat `b1'=e(b)
    mat `b2'=`strho'
    mat rownames `b2'=rho:_cons
    mat colnames `b2'=rho:_cons
    mat `b0' = (`b1',`b2')
    local initopt "init(`b0',skip)"
    }
    }
else {
multin `lhs' `rhs_eq1' if `touse', group($GROUP)
if _rc == 0 {
    tempname b0 b1 b2 b3
    mat `b1'=e(b)
    mat `b2'=log(`meany')
    mat rownames `b2'=y:_cons
    mat colnames `b2'=y:_cons
    mat `b3'=`strho'
    mat rownames `b3'=rho:_cons
    mat colnames `b3'=rho:_cons
    mat `b0' = (`b1',`b2',`b3')
    local initopt "init(`b0',skip)"
    }
}
*********************************************************
* Estimate model
*********************************************************
ml model `dtype' `prog' (y:`lhs'= `rhs', `constan' ) `offopt'  ///
    if `touse', ///
    missing max nooutput nopreserve `initopt' search(off) ///
    `mlopts' `log' `difficu' `continu' title(`title') 
************************************************************
tempvar T
qui bys `touse' `group': gen long `T' = _N if _n==1 & `touse'
qui count if `T'>0&`T'<.
ereturn scalar g_N=r(N)
summarize `T' if `touse', meanonly
ereturn scalar g_min=r(min)
ereturn scalar g_max=r(max)
ereturn scalar g_avg=r(mean)
ereturn local cmd dirmul

if "`pearson'"=="pearson" {
preserve
keep if e(sample)
tempvar xb1 xb2 vij sumvij prob ysum factor mij pearstat
qui predict double `xb1'
gen double `vij'=exp(`xb1')
bys $GROUP: egen double `sumvij'=sum(`vij')
gen double `prob'=`vij'/`sumvij'
bys $GROUP: egen double `ysum'=sum(`lhs')
if "`eqcorr'"=="eqcorr" {
qui predict double `xb2', equation(rho)
gen double `factor'=1+`xb2'*(`ysum'-1)
}
else {
gen double `factor'=(`sumvij'+`ysum')/(`sumvij'+1)
}
gen double `mij'=((`lhs'-`ysum'*`prob')^2)/(`ysum'*`prob'*`factor')
gen double `pearstat'=sum(`mij')
ereturn scalar pearstat=`pearstat'[_N]
ereturn scalar dfpears=_N-e(g_N)-e(k)
restore
}

Replay, level(`level') `eform' `pearson'
end
*************************************************************
program Replay
    syntax [, Level(integer `c(level)') eform pearson]
    disphdr
    ml display, noheader level(`level') `eform'
    if "`pearson'"=="pearson" {
    di as txt "Pearson statistic is --> " as res %12.4f e(pearstat) as txt ///
    " Prob = " as res %6.5f chi2tail(e(dfpears),e(pearstat)) as txt " df= " as res %6.0f e(dfpears)
    } 
    global $GROUP
end

program disphdr
    version 9
    args touse ivar
    di in gr _n "`e(title)'" _col(49) "Number of obs" _col(68) "=" _col(70) in ye %9.0g e(N)
    di in gr "Group variable: " in ye abbrev("$GROUP",14) _col(49) in gr "Number of groups" _col(68) "=" _col(70) in ye %9.0g e(g_N) _n
    di in gr _col(49) "Obs per group: min" _col(68) "=" _col(70) in ye %9.0g e(g_min)
    di in gr _col(64) "avg" _col(68) "=" _col(70) in ye %9.1f e(g_avg)
    di in gr _col(64) "max" _col(68) "=" _col(70) in ye %9.0g e(g_max)
    if !missing(e(df_r)) {
    di in gr _n _col(49) "F(" in ye %6.0f e(df_m) in gr "," in ye %8.0f e(df_r) in gr ")" _col(68) "=" _col(70) in ye %9.2f e(F)
    if "`e(ll)'" != "" {
    di in gr "Log likelihood  = " in ye %10.0g e(ll) _c
    }
    di in gr _col(49) "Prob > F" _col(68) "=" in ye _col(73) %6.4f Ftail(e(df_m),e(df_r),abs(e(F)))
    }
    else {
    di in gr _n _col(49) "`e(chi2type)' chi2(" in ye e(df_m) in gr ")" _col(68) "=" _col(70) in ye %9.2f abs(e(chi2))
    if "`e(ll)'" != "" {
    di in gr "Log likelihood  = " in ye %10.0g e(ll) _col(49) in gr "Prob > chi2" _col(68) "=" in ye _col(73) %6.4f chiprob(e(df_m),abs(e(chi2)))
    }
    else {
    di in gr _col(49) "Prob > chi2" _col(68) "=" in ye _col(73) %6.4f chiprob(e(df_m),abs(e(chi2)))
}
}
di
end

program define DropOne /* drop groups of size one */
    args touse ivar y nn
    tempvar one
    qui by `touse' `ivar': gen byte `one' = (_N==1) if `touse'
    qui count if `one' & `touse'
    local ndrop `r(N)'
    if `ndrop' == 0 {
    exit
    }
    if `ndrop' > 1 {
    local s "s"
    }
    di in gr "note: `ndrop' group`s' " /*
    */ "(`ndrop' obs) dropped because of only one obs per group"
    qui replace `touse' = 0 if `one' & `touse'
    sort `touse' `ivar' `nn' /* redo sort */
    summarize `y' if `touse', meanonly
    if r(N) == 0 {
    error 2000
    }
    if r(N) == 1 {
    error 2001
    }
end

program define DropZero /* drop groups with all zero counts */
    args touse ivar y nn
    tempvar sumy
    qui by `touse' `ivar': gen double `sumy' =cond(_n==_N, sum(`y'), .) if `touse'
    qui count if `sumy'==0
    local ngrp `r(N)'
    if `ngrp' == 0 {
    exit
    }
    qui by `touse' `ivar': replace `sumy' = `sumy'[_N] if `touse'
    qui count if `sumy'==0
    local ndrop `r(N)'
    if `ngrp' > 1 {
    local s "s"
    }
    di in gr "note: `ngrp' group`s' " "(`ndrop' obs) dropped due to all zero outcomes"
    qui replace `touse' = 0 if `sumy'==0 & `touse'
    sort `touse' `ivar' `nn'
    summarize `y' if `touse', meanonly
    if r(N) == 0 {
    error 2000
    }
    if r(N) == 1 {
    error 2001
    }
end

exit
