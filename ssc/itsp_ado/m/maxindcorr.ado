
*! maxindcorr 1.0.0  CFBaum 11aug2008
program maxindcorr
    version 10.1
    syntax varlist(numeric), RET(varname numeric) FIRMid(varname) GEN(string)

* validate new variable names
    confirm new variable `gen'`firmid'
    confirm new variable `gen'max
    confirm new variable `gen'mu
    confirm new variable `gen'n

    tempvar trday
* establish trading day calendar using firmid variable
    bysort `firmid': gen `trday' = _n
    qui tsset `firmid' `trday'
    qui generate `gen'max = .
    qui generate `gen'mu = .
    qui generate `gen'n = .
    qui generate `gen'`firmid' = .
    qui levelsof `firmid'
    local firms `r(levels)'
    local nf : word count `r(levels)'
    forv i = 1/`nf' {
        local fid : word `i' of `firms'
        qui replace `gen'`firmid' = `fid' in `i'
    }
* create varlist of indices..ret
    local vl "`varlist' `ret'"	
* pass to Mata routine
    mata: indcorr("`firmid'", "`vl'","`gen'")	
    end
