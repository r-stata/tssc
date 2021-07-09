*! version 1.0.1  16sep2008  Ben Jann
*! (based on cprplot.ado version 3.1.7 10dec2002 by StataCorp)
program define cprplot2
    version 8.2

    _isfit cons anovaok
    syntax varlist [if] [in] [, RETRansform(string) YRETRansform(string) LOWess MSPline LPoly *]

    _get_gropts , graphopts(`options') getallowed(rlopts lsopts msopts lpopts plot)
    local options `"`s(graphopts)'"'
    local rlopts `"`s(rlopts)'"'
    local lsopts `"`s(lsopts)'"'
    local msopts `"`s(msopts)'"'
    local lpopts `"`s(lpopts)'"'
    local plot `"`s(plot)'"'
    _check4gropts rlopts, opt(`rlopts')
    _check4gropts lsopts, opt(`lsopts')
    _check4gropts msopts, opt(`msopts')
    _check4gropts lpopts, opt(`lpopts')
    if `"`lsopts'"' != "" {
        local lowess lowess
    }
    if `"`msopts'"' != "" {
        local mspline mspline
    }
    if `"`lpopts'"' != "" {
        local lpoly lpoly
    }

    if "`e(cmd)'" == "anova" {
        anova_terms
        local cterms `r(continuous)'
        foreach var of local varlist {
            if !`:list var in cterms' {
                di in red /*
                */ "`var' is not a continuous variable in the model"
                exit 398
            }
        }
    }

    local wgt `"[`e(wtype)' `e(wexp)']"'
    marksample touse
    qui replace `touse' = e(sample) if `touse'
    *tempvar touse
    *qui gen byte `touse' = e(sample)

    foreach var of local varlist {
        capt local beta=_b[`var']
        if _rc {
            di in red `"`var' is not in the model"'
            exit 398
        }
    }
    tempvar resid hat lest
    quietly {
        _predict `resid' if `touse', resid
        foreach var of local varlist {
            replace `resid'=`resid'+`var'*_b[`var']
        }
    }
    _est hold `lest'
    capture {
        regress `resid' `varlist' `wgt' if `touse'
        _predict `hat' if `touse'
    }
    local rc=_rc
    _est unhold `lest'
    if `rc' {
        error `rc'
    }
    gettoken varlist controls: varlist
    if "`controls'"=="" local yttl "Component plus residual"
    else local yttl "Multiple component plus residual"
    local xttl : var label `varlist'
    if `"`xttl'"' == "" {
        local xttl `varlist'
    }
    if `"`retransform'"'!="" {
        if !index(`"`retransform'"',"@") {
            local retransform `"`retransform'(@)"'
        }
        tempvar tvar
        local transform: subinstr local retransform "@" "`varlist'", all
        qui gen `tvar' = `transform' if `touse'
        capt assert `tvar'<. if `touse'
        if _rc {
            di as txt "(warning: retransform of `varlist' evaluates " ///
             "to missing for some observations)"
        }
        local varlist `tvar'
        local xttl: subinstr local retransform "@" `"`xttl'"', all
    }
    if `"`yretransform'"'!="" {
        if !index(`"`yretransform'"',"@") {
            local yretransform `"`yretransform'(@)"'
        }
        tempvar tvar
        local transform: subinstr local yretransform "@" "`resid'", all
        qui replace `resid' = `transform' if `touse'
        capt assert `resid'<. if `touse'
        if _rc {
            di as txt "(warning: retransform of partial residuals evaluates " ///
             "to missing for some observations)"
        }
        local transform: subinstr local yretransform "@" "`hat'", all
        qui replace `hat' = `transform' if `touse'
        capt assert `hat'<. if `touse'
        if _rc {
            di as txt "(warning: retransform of partial predictions evaluates " ///
             "to missing for some observations)"
        }
        local yttl: subinstr local yretransform "@" `"`yttl'"', all
    }
    if `"`lowess'"' != "" {
        if `"`e(wtype)'"'!="" {
            di in red "not possible with weighted fit"
            exit 398
        }
        local grlow             ///
        (lowess `resid' `varlist'       ///
            if `touse',         ///
            sort                ///
            yvarlabel("Lowess smooth")  ///
            `lsopts'            ///
        )
    }
    if `"`mspline'"' != "" {
        local grmsp             ///
        (mspline `resid' `varlist'      ///
            if `touse',         ///
            sort                ///
            yvarlabel("Spline smooth")  ///
            `msopts'            ///
        )
    }
    if `"`lpoly'"' != "" {
        local grlpoly             ///
        (lpoly `resid' `varlist' `wgt' ///
            if `touse',         ///
            sort                ///
            yvarlabel("lpoly smooth")  ///
            `lpopts'            ///
        )
    }
    if `"`plot'"' == "" {
        local legend legend(nodraw)
    }
    version 8: graph twoway             ///
    (scatter `resid' `varlist'          ///
        if `touse',             ///
        sort                    ///
        ytitle(`"`yttl'"')          ///
        xtitle(`"`xttl'"')          ///
        `legend'                ///
        `options'               /// graph opts
    )                       ///
    (line `hat' `varlist'               ///
        if `touse',             ///
        sort                    ///
        clstyle(refline)            ///
        `rlopts'                /// graph opts
    )                       ///
    `grlow'                     ///
    `grmsp'                     ///
    `grlpoly'                   ///
    || `plot'                   ///
    // blank
end
