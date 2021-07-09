*! version 1.0.2  28oct2009  Ben Jann

program define viewresults
    version 9.0
    local caller : di _caller()

    _on_colon_parse `0'
    local command `"`s(after)'"'
    local 0 `"`s(before)'"'
    syntax [, noCmd noNew name(name) ]
    if ("`new'" == "" | "`new'"=="new") & "`name'" == "" {
        local name _new
    }
    if "`name'`marker'" != "" {
        local suffix "##`marker'|`name'"
    }

    set more off
    tempname rhold
    _return hold `rhold'
    tempname  logname
    tempfile logfn
    capt log close `logname' // just to be sure
    qui log using `"`logfn'"', smcl name(`logname')
    _return restore `rhold'
    if "`cmd'"=="" {
        di as inp `". `command'"'
    }
    capture noisily version `caller': `command'
    if _rc {
        _return hold `rhold'
        qui log close `logname'
        _return restore `rhold'
        exit _rc
    }
    else {
        _return hold `rhold'
        qui log close `logname'
        _return restore `rhold'
        nobreak {
            qui copy `"`logfn'"' `"`logfn'.smcl"'
            capt view `"`logfn'.smcl"'`suffix'
            erase `"`logfn'.smcl"'
        }
    }
end
