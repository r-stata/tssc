*! version 1.0.0  28oct2009  Ben Jann

program define saveresults
    version 9.0
    local caller : di _caller()

    _on_colon_parse `0'
    local command `"`s(after)'"'
    local 0 `"`s(before)'"'
    gettoken using : 0
    if `"`using'"'!="using" {
        local 0 `"using `macval(0)'"'
    }
    syntax using/ [, noCmd ps txt log smcl prn pdf * ]
    local to "`ps' `txt' `log' `smcl' `prn' `pdf'"
    local to: list clean to
    if `:list sizeof to'>1 {
        di as err "only one of ps, txt, log, smcl, prn, pdf allowed"
        exit 198
    }
    if "`to'"=="" {
        mata: st_local("to", substr(pathsuffix(st_local("using")),2,.))
        if `"`to'"'!="" {
            qui transmap query `to'
            local to `"`r(suffix)'"'
        }
        if !inlist(`"`to'"',"ps","txt","log","smcl","prn","pdf") local to "txt"
    }
    local translator "smcl2`to'"

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
        if "`to'"=="smcl" {
            copy `"`logfn'"' `"`using'"', `options'
            di as txt `"(file `using' written in .smcl format)"'
        }
        else {
            translate `"`logfn'"' `"`using'"', t(`translator') `options'
        }
    }
end
