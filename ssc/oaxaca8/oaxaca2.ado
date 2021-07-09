*!version 1.0.2  Ben Jann  22apr2008

program define oaxaca2, byable(recall)
    version 8.2
    syntax anything(id=varlist) [if] [in] [aw fw iw pw] , ///
      By(varname)         ///
    [ cmd(str asis)       ///
      CMDOpts(str asis)   ///
      ADDVars(str asis)   ///
      NOIsily             ///
      Pooled Includeby    ///
      Reference(str) asis * ]

    if `"`reference'"'!="" {
        di as err "reference() not allowed"
        exit 198
    }
    if "`asis'"!="" {
        di as err "asis not allowed"
        exit 198
    }
    if "`noisily'"=="" local qui quietly
    local cmd1 regress
    local cmd2 regress
    local cmd3 regress
    if `"`cmd'"'!="" {
        tokenize `"`cmd'"'
        local cmd1 `1'
        if `: list sizeof cmd'>1 macro shift
        local cmd2 `1'
        if `: list sizeof cmd'>1 macro shift
        local cmd3 `1'
    }
    if `"`cmdopts'"'!="" {
        tokenize `"`cmdopts'"'
        local cmdopts1 `1'
        if `: list sizeof cmdopts'>1 macro shift
        local cmdopts2 `1'
        if `: list sizeof cmdopts'>1 macro shift
        local cmdopts3 `1'
    }
    if `"`addvars'"'!="" {
        tokenize `"`addvars'"'
        local addvars1 `1'
        local addvars2 `2'
        local addvars3 `3'
    }
    if "`includeby'"!="" local includeby `by'

    marksample touse
    markout `touse' `by', strok
    markout `touse' `addvars1' `addvars2' `addvars3'
    qui levels `by' if `touse', local(groups)
    if `: list sizeof groups'>2 {
        di as err "more than 2 groups found, only 2 allowed"
        exit 420
    }
    gettoken group1 group2: groups, quotes
    local group2: list retok group2

    local v: display string(_caller())
    tempname est1 est2 est3
    forv i=1/2 {
        `qui' version `v': `cmd`i'' `anything' `addvars`i'' if `touse' ///
            & `by'==`group`i'' [`weight'`exp'], `cmdopts`i''
        local N`i' = e(N)
        est sto `est`i''
    }
    if "`pooled'"!="" {
        `qui' version `v': `cmd3' `anything' `addvars3' `includeby' if `touse' ///
            & (`by'==`group1' | `by'==`group2') [`weight'`exp'], `cmdopts3'
        est sto `est3'
        local reference "reference(`est3') referencenames(pooled)"
    }
    ereturn clear

    di _n as txt "Group 1: `by' = " `group1' _col(50) ///
                 "Number of obs 1   = " as res %9.0g `N1'
    di    as txt "Group 2: `by' = " `group2' _col(50) ///
                 "Number of obs 2   = " as res %9.0g `N2'
    oaxaca8 `est1' `est2' , asis `reference' `options'
end
