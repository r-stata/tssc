*! version 1.0.0  10oct2008  Ben Jann

prog nlcheck
    version 10
    local stdopts       ///
        Discrete        ///
        Splines         ///
        Bins(passthru)  ///
        Knots(passthru) ///
        EQfreq          ///
        NOIsily         ///
        // blank
    syntax varlist(min=1) [, `stdopts' ///
        Graph EQuation(passthru) step Level(passthru) CIOPTs(str asis) * ]
    if "`graph'"=="" {
        syntax varlist(min=1) [, `stdopts' ]
    }
    if "`discrete'"!="" & `"`splines'`bins'`knots'"'!="" {
        di as err "splines, bins(), or knots() not allowed with discrete"
        exit 198
    }

    //check varnames
    foreach var of local varlist {
        capt di [#1]_b[`var']
        if _rc {
            di as err `"`var' not found in model"'
            exit 111
        }
    }

    //estimation sample
    tempvar touse
    qui gen byte `touse' = e(sample)==1


    // prepare plot
    if `"`graph'"'!="" {
        tempvar xb0 xb1 xb1_lo xb1_up xbtouse
        local graphv "graph(`xb1' `xb1_lo' `xb1_up' `xbtouse')"
        _model_fit "`touse'" `"`equation'"' "`varlist'" "`xb0'"
    }

    // backup model
    local cmdline `"`e(cmdline)'"'
    tempname hcurrent
    _estimates hold `hcurrent', restore

    // test
    _parse comma lhs rhs : cmdline
    if `"`rhs'"'=="" local comma ", "
    _nlcheck `cmdline'`comma' ///
        _nlcheck_opts(check(`varlist') `discrete' `splines' `bins' `knots' `eqfreq' ///
        touse(`touse') `graphv' `equation' `step' `level' `noisily')

    // plot
    if `"`graph'"'!="" {
        local cutpos
        local i 0
        while (r(cut`++i')<.) {
            local cutpos `cutpos' `r(cut`i')'
        }
        tempname ret
        capt _return hold `ret'
        if _rc {
            capt _return drop `ret'
            _return hold `ret'
        }
        gettoken xvar : varlist
        if `"`cutpos'"'!="" {
            local cutxmtick `"xmtick(`cutpos', tpos(inside) tlength(*2) tlc(red))"'
        }
        if "`discrete'"=="" {
            local grtype    line
            local grtypeci  rarea
        }
        else {
            local grtype    connected
            local grtypeci  rcap
        }
        two (`grtypeci' `xb1_lo' `xb1_up' `xvar' if `xbtouse', sort astyle(ci) `ciopts') ///
            (`grtype'   `xb0' `xb1' `xvar' if `xbtouse', sort pstyle(p1 p2) ///
            legend(order(2 "model" 3 "adaptive fit"))  ///
            ytitle("adjusted linear prediction") `cutxmtick' `options')
        _return restore `ret'
    }
end

prog _model_fit
    args touse equation varlist fit
    _get_indepvars_from_b // sets local indepvars
    foreach var of local varlist {
        local indepvars: subinstr local indepvars "`var'" "", all word
    }
    qui adjust `indepvars', xb se generate(`fit') `equation'
end

prog _get_indepvars_from_b
    tempname b
    mat `b' = e(b)
    local eq: coleq `b', q
    gettoken eq : eq
    mat `b' = `b'[1...,`"`eq':"']    // first equation only
    local coefs: coln `b'
    foreach coef of local coefs {
        capt confirm var `coef', exact
        if _rc==0 {
            local vars `vars' `coef'
        }
    }
    c_local indepvars `vars'
end

prog _nlcheck, sortpreserve rclass
    syntax anything [if] [in] [fw aw iw pw], _nlcheck_opts(str asis) [ * ]
    _parse_nlcheck_opts, `_nlcheck_opts'
    gettoken checkvar : check

    if "`discrete'"!="" {
        qui levelsof `checkvar' if `touse', local(levels)
        local i 0
        local skip = 1 + `: list sizeof check'
        foreach l of local levels {
            if `++i'<=`skip' continue
            tempname cut`i'
            qui gen byte `cut`i'' = (`checkvar'==`l') if `touse'
            local cutnames `cutnames' `cut`i''
        }
    }
    else if "`splines'"!="" {
        su `checkvar' if `touse', mean
        local K = r(min)
        local pct
        forv i = 1/`knots' {
            local pct "`pct' `=(`i'-.5)/`knots'*100'"
        }
        if "`eqfreq'"=="" {
            tempvar first
            bys `touse' `checkvar': gen byte `first' = _n==1 & `touse'
            _pctile `checkvar' if `touse' & `first', p(`pct')
        }
        else {
            _pctile `checkvar' if `touse' [`weight'`exp'], p(`pct')
        }
        forv i = 1/`knots' {
            local rlast = `K'
            local K = r(r`i')
            if `K'==`rlast' continue
            local cutpos `cutpos' `K'
            tempname cut`i'
            qui gen double `cut`i'' = cond((`checkvar' - `K') > 0, (`checkvar' - `K'), 0) if `touse'
            local cutnames `cutnames' `cut`i''
        }
    }
    else {
        su `checkvar' if `touse', mean
        local K = r(min)
        local k = `bins'-1
        local pct
        forv i = 1/`k' {
            local pct "`pct' `=`i'/`bins'*100'"
        }
        if "`eqfreq'"=="" {
            tempvar first
            bys `touse' `checkvar': gen byte `first' = _n==1 & `touse'
            _pctile `checkvar' if `touse' & `first', p(`pct')
        }
        else {
            _pctile `checkvar' if `touse' [`weight'`exp'], p(`pct')
        }
        local omitfirst 1
        forv i=1/`bins' {
            local rlast = `K'
            local K = cond(`i'==`bins', ., r(r`i'))
            if `K'==`rlast' continue
            if `omitfirst' {
                local omitfirst 0
                continue
            }
            local cutpos `cutpos' `rlast'
            tempname cut`i'
            qui gen byte `cut`i'' = ( `checkvar'>=`rlast' & `checkvar'<`K') if `touse'
            local cutnames `cutnames' `cut`i''
        }
    }
    local i 0
    foreach cut of local cutpos {
        return scalar cut`++i' = `cut'
    }
    return local levels `"`levels'"'
    if `"`cutnames'"'=="" {
        di as err "no additional parameters"
        exit 499
    }

    qui `noisily' `anything' `cutnames' `if' `in' [`weight'`exp'], `options'
    di as txt _n "Nonlinearity test:"
    qui `noisily' testparm `cutnames'
    if "`noisily'"=="" {
        if r(df_r) < . {  // output code adapted from official test.ado
                di _n as txt /*
                */ "       F(" %3.0f r(df) "," %6.0f r(df_r) ") =" /*
                */ as res %8.2f r(F)
                di as txt _col(13) "Prob > F =" as res %10.4f r(p)
        }
        else {
                di _n as txt _col(12) "chi2(" %3.0f r(df) ") =" /*
                */ as res %8.2f r(chi2)
                di as txt _col(10) "Prob > chi2 =  " as res %8.4f r(p)
        }
    }
    return add
    capt mata: assert(anyof(st_matrix("e(V)"), 0)==0)
    if _rc {
        di as err "Warning: some elements in variance matrix of adaptive model are zero; " ///
                  "reduce the number of bins."
    }
    capt assert (`touse'==e(sample))
    if _rc {
        di as err "Warning: adaptive model has different estimation sample than original model."
    }

    if `"`graph'"'!="" {
        if "`step'"!="" & "`discrete'`splines'"=="" {   // refit model without linear term
            gettoken cmd vars : anything
            capt unab vars : `vars'
            local newvars
            foreach var of local vars {
                if `:list var in check'==0 {
                    local newvars `"`newvars' `var'"'
                }
            }
            qui `cmd' `newvars' `cutnames' `if' `in' [`weight'`exp'], `options'
        }
        qui replace `touse' = 0 if e(sample)!=1
        _adaptive_fit "`touse'" "`level'" `"`equation'"' "`check'" "`cutnames'" `graph'
    }
end

prog  _parse_nlcheck_opts
    syntax , check(str) touse(str) ///
        [ discrete splines bins(passthru) knots(passthru) eqfreq NOIsily ///
            graph(str) step level(cilevel) equation(passthru) ]
    if `"`knots'"'!="" {
        _parse_knots_opt, `knots'
    }
    if `"`bins'"'!="" {
        _parse_bins_opt, `bins'
    }
    if `"`bins'"'=="" & `"`knots'"'=="" {
        _parse_bins_opt
        _parse_knots_opt
    }
    else if `"`knots'"'==""   local knots = `bins' - 1
    else if  `"`bins'"'==""   local bins = `knots' + 1
    foreach opt in check touse splines discrete bins knots eqfreq noisily graph step level equation {
        c_local `opt' `"``opt''"'
    }
end
prog _parse_bins_opt
    syntax [ , bins(int 10) ]
    if `bins'<2 {
        di as err "bins() must be 2 or larger"
        exit 198
    }
    c_local bins `bins'
end
prog _parse_knots_opt
    syntax [, knots(int 9) ]
    if `knots'<1 {
        di as err "knots() must be 1 or larger"
        exit 198
    }
    c_local knots `knots'
end

prog _adaptive_fit
    args touse level equation varlist cutnames fit lo up sample

    _get_indepvars_from_b // sets local indepvars
    foreach var in `varlist' `cutnames' {
        local indepvars: subinstr local indepvars "`var'" "", all word
    }
    tempname se
    qui adjust `indepvars', xb se generate(`fit' `se') `equation'

    if e(df_r)<. {
        local z = invttail(e(df_r), (100-`level')/200)
    }
    else {
        local z = invnormal(1-(100-`level')/200)
    }
    qui gen `lo' = `fit' - `z' * (`se') if `touse'
    qui gen `up' = `fit' + `z' * (`se') if `touse'

    gettoken checkvar : varlist
    qui bys `touse' `checkvar': gen byte `sample' = _n==1 & `touse'
end
