*! version 1.1.2  11may2011  Ben Jann
* based on cloglog.ado, version 1.8.6  04aug2005
program define rrlogit, byable(onecall) prop(/*ml_score*/ swml or) 
version 9.1
    if _by() {
        local BY `"by `_byvars'`_byrc0':"'
    }
    `BY' _vce_parserun rrlogit : `0'
    if "`s(exit)'" != "" {
        exit
    }

    if replay() {
        if "`e(cmd)'" != "rrlogit" error 301
        if _by() error 190
        Display `0'
        error `e(rc)'
        exit
    }
    `BY' Estimate `0'
end

program Estimate, eclass byable(recall)
/* Parse. */

    syntax varlist(numeric ts) [if] [in] [fw iw pw] [, /*
    */ PWarner(str) PYes(str) p1(str) PNo(str) p2(str) /*
    */ ASIS FROM(string) /*
    */ Level(cilevel) or noCONstant Robust CLuster(varname) /*
    */ OFFset(varname numeric) SCore(string) noLOg noDISPLAY * ]

    if `"`pwarner'"'==""  local pwarner 1
    if `"`p1'"'=="" local p1 `"`pyes'"'
    if `"`p2'"'=="" local p2 `"`pno'"'
    if `"`p1'"'=="" local p1 0
    if `"`p2'"'=="" local p2 0
    if `"`robust'"' != "" | `"`cluster'"' != "" | /*
    */ `"`weight'"' == "pweight" {
        local crtype crittype("log pseudolikelihood")
    }
    if _by() {
        _byoptnotallowed score() `"`score'"'
    }

    mlopts mlopts, `options'

/* Check syntax. */

    if `"`score'"'!="" {
        confirm new variable `score'
        local nword : word count `score'
        if `nword' > 1 {
            di as err "score() must contain the name of only" /*
            */ " one new variable"
            exit 198
        }
        tempvar scvar
        local scopt "score(`scvar')"
    }
    if "`constant'"!="" {
        local nvar : word count `varlist'
        if `nvar' == 1 {
            di as err "independent variables required with " /*
            */ "noconstant option"
            exit 102
        }
    }

/* Mark sample. */

    marksample touse, zeroweight

    if `"`cluster'"'!="" {
        markout `touse' `cluster', strok
        local clopt cluster(`cluster')
    }
    if "`offset'"!="" {
        markout `touse' `offset'
        local offopt "offset(`offset')"
    }

/* Check p's. */

    capt assert (`pwarner'>=0) & (`pwarner'<=1) & (`pwarner'!=0.5) if `touse'
    if _rc {
        di as err "pwarner() must be in [0,1]; pwarner() must be unequal 0.5"
        exit 198
    }
    capt assert (`p1'>=0) & (`p2'>=0) & ((`p1'+`p2')<=1) if `touse'
    if _rc {
        di as err "pyes() and pno() must be in [0,1]; pyes()+pno() must be < 1"
        exit 198
    }

/* Count obs and check values of `y'. */

    gettoken y xvars : varlist

    tsunab yname : `y'
    loc yname : subinstr local yname "." "_"

    qui count if `touse'
    local n `r(N)'

    if `n' == 0 error 2000
    if `n' == 1 error 2001

    qui count if `y'==0 & `touse'
    local n0 `r(N)'
    if `n0'==0 | `n0'==`n' {
        di as err "outcome does not vary; remember:"
        di as err _col(35) "0 = negative outcome,"
        di as err _col(9) /*
        */ "all other nonmissing values = positive outcome"
                exit 2000
        }

    if "`log'"!="" | "`display'"!="" {
        local qui "quietly"
    }

/* If there are negative iweights, -logit- cannot be used. */

    local nonegwt 1

    if "`weight'"!="" {
        if "`weight'"=="pweight" { /* pweights create unneeded
                                      extra work when getting
                                      initial values, etc.
                                   */
            local wtype "iweight"
        }
        else local wtype "`weight'"

        if "`weight'"=="iweight" {
            tempname sumw
            tempvar w
            qui gen double `w' `exp' if `touse'
            summarize `w' if `touse', meanonly
            scalar `sumw' = r(sum)
            if `sumw' <= 0 {
                di as err "sum of weights less than " /*
                */ "or equal to zero"
                exit 402
            }
            if r(min) < 0 local nonegwt 0
        }
    }

/* Remove collinearity. */

    _rmcoll `xvars' [`weight'`exp'] if `touse', `constant'
    local xvars `r(varlist)'

/* Run logit to drop any variables and observations. */

    if "`asis'"=="" & `nonegwt' {
        logit `y' `xvars' [`wtype'`exp'] if `touse', /*
        */ iter(0) `offopt' nocoef nolog `constant'
        qui replace `touse' = e(sample)
        _evlist
        local xvars `s(varlist)'
    }

/* Set rrt probabilities. */

    global rrlogit_pw `pwarner'
    global rrlogit_p1 `p1'
    global rrlogit_p2 `p2'

/* Compute constant-only model. */

    if "`constant'"=="" & "`xvars'"!="" {
        if `"`from'"'=="" {
            `qui' di as txt _n "Fitting constant-only model:"

            ml model d2 rrlogit_lf                      /*
            */ (`yname': `y'=, `constant' `offopt')             /*
            */ if `touse' [`wtype'`exp'], collinear missing max /*
            */ nooutput nopreserve wald(0) search(off) `mlopts' /*
            */ `log' `crtype' nocnsnotes

            local continu "continue search(off)"

            `qui' di as txt _n "Fitting full model:"
        }
    }

/* Fit full model. */

    if `"`from'"'!=""  local initopt `"init(`from')"'

    ml model d2 rrlogit_lf (`yname': `y'=`xvars', `constant' `offopt')  /*
    */ if `touse' [`weight'`exp'], collinear missing max nooutput     /*
    */ nopreserve `initopt' `lf0' `mlopts' `log'     /*
    */ `scopt' `robust' `clopt' `continu'                 /*
    */ title(Randomized response logistic regression)

/* Clear rrt probabilities. */

    global rrlogit_pw
    global rrlogit_p1
    global rrlogit_p2

/* Returns. */

    eret local cmd

    if "`score'" != "" {
        label var `scvar' "Score index for x*b from rrlogit"
        rename `scvar' `score'
        eret local scorevars `score'
    }

    if "`weight'" == "fweight" {
        tempvar tmpsum
        qui gen double `tmpsum' `exp' if `touse' & `y' == 0
        summarize `tmpsum' if `touse' & `y' == 0 , meanonly
        eret scalar N_f = r(sum)
    }
    else {
        qui count if `touse' & `y' == 0
        eret scalar N_f = r(N)
    }
    eret scalar N_s = e(N) - e(N_f)
    eret scalar r2_p = 1 - e(ll)/e(ll_0)

    eret local offset1
    eret local offset  "`offset'"
    eret local predict "rrlogit_p"
    eret local cmd     "rrlogit"
    eret local cmd2    "logit"
    eret local pwarner `pwarner'
    eret local pyes `p1'
    eret local pno  `p2'

    if "`display'"=="" {
        Display, level(`level') `or'
    }
    error `e(rc)'
end

program define Display
    syntax [, Level(cilevel) or ]

    if e(chi2) < 1e5 {
        local fmt "%9.2f"
    }
    else     local fmt "%9.2e"

    local crtype = upper(substr(`"`e(crittype)'"',1,1)) + /*
        */ substr(`"`e(crittype)'"',2,.)
    di as txt _n "`e(title)'" _col(49) "Number of obs     =" /*
        */ as res _col(70) %9.0g e(N) _n /*
        */ as txt _col(49) "Nonzero outcomes  =" /*
        */ as res _col(70) %9.0g e(N_s) _n /*
        */ as txt  `"P(non-negated question) =  "' as res e(pwarner) /*
        */ as txt _col(49) "Zero outcomes     =" /*
        */ as res _col(70) %9.0g e(N_f) _n /*
        */ as txt  `"P(surrogate "yes")      =  "' as res e(pyes) /*
        */ as txt _col(49) "`e(chi2type)' chi2(" as res `e(df_m)' /*
        */ as txt ")" _col(67) "=" as res _col(70) `fmt' e(chi2) _n /*
        */ as txt  `"P(surrogate "no")       =  "' as res e(pno) /*        
        */ as txt _col(49) "Prob > chi2" _col(67) "=" as res _col(70) /*
        */ as res %9.4f chiprob(e(df_m),e(chi2)) _n /*
        */ as txt "`crtype' = " as res %10.0g e(ll) /*
        */ as txt _col(49) "Pseudo R2" _col(67) "=" as res _col(70) /*
        */ as res %9.4f e(r2_p) _n

    ml di, noheader first level(`level') nofootnote `or'
    _prefix_footnote
end
