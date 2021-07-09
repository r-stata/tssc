*! version 1.2.4  24jan2009  Ben Jann and Roberto G. Gutierrez

program pspline, sortpreserve rclass
    version 9.2
    syntax varlist(min=2 numeric) [if] [in], [ ///
        Generate(name)              ///
        Replace                     ///
        DIScrete                    ///
        at(str asis)                ///
        Degree(int 1)               ///
        NKnots(int -1)              ///
        Knots(numlist sort)         ///
        ALpha(real .3)              ///
        force                       ///
        NOIsily                     ///
        ESTOPts(str asis)           ///
        /*ci Level(cilevel)*/       ///
        noGRaph                     ///
        noSCatter                   ///
        noKNOTpos                   ///
        noPENalty                   ///
        * ]
    if !inrange(`alpha',0,1) {
        di as err "alpha() must be in [0,1]"
        exit 198
    }
    if `"`discrete'"'!="" {
        if `nknots'!=-1 {
            di as err "nknots() not allowed with discrete"
            exit 198
        }
        if `"`knots'"'!="" {
            di as err "knots() not allowed with discrete"
            exit 198
        }
        if `"`at'"'!="" {
            di as err "at() not allowed with discrete"
            exit 198
        }
    }
    if `"`at'"'!="" {
        tempname touse_at
        parse_at `at', touse(`touse_at')
    }
    if `nknots'>=0 & `"`knots'"'!="" {
        di as err "nknots() and knots() not both allowed"
        exit 198
    }
    if `degree'<0 {
        di as err "degree()<0 not allowed"
        exit 198
    }
    if "`noisily'"=="" local qui quietly
    if `"`generate'"'!="" & "`replace'"=="" {
        confirm new var `generate'
    }
    _get_gropts , graphopts(`options') gettwoway ///
        getallowed(LINEOPts /*CIOPts*/ addplot)
    local options `"`s(graphopts)'"'
    local twopts `"`s(twowayopts)'"'
    local lineopts `"`s(lineopts)'"'
*    local ciopts `"`s(ciopts)'"'
    local addplot `"`s(addplot)'"'
    _check4gropts lineopts, opt(`lineopts')
*    _check4gropts ciopts, opt(`ciopts')

// sample
    marksample touse
    gettoken depv controls : varlist
    gettoken var controls : controls
    sort `touse' `var'
    tempvar unique
    qui gen `unique' = `var' if `var'!=`var'[_n-1] & `touse'

// degree(): generate x^2, x^3, ...
    forv i = 1/`degree' {
        if `i'==1 {
            local powers "`var'"
            continue
        }
        tempvar power`i'
        qui gen `power`i'' = `var'^`i'
        local powers "`powers' `power`i''"
    }

// algorithm for discrete x (using penalized errors for distinct values of x)
    if "`discrete'"!="" {
        qui levelsof `var' if `touse', local(levels)
        local K: list sizeof levels
        tempname knotmat
        mat `knotmat' = J(1,`K', .z)
        local i 0
        foreach l of local levels {
            mat `knotmat'[1,`++i'] = `l'
        }
        // - fit models
        if "`penalty'"=="" {
            // - GOF test for parametric model
            if "`force'"=="" {
                //qui levelsof `var' if `touse', local(levels)
                local i 0
                foreach l of local levels {
                    if `i++' <= (`degree') continue
                    tempvar dummy`i'
                    qui gen byte `dummy`i'' = `var' == `l' if `touse'
                    local dummyvars `dummyvars' `dummy`i''
                }
                qui xtmixed `depv' `powers' `controls' `dummyvars' if `touse' ///
                    , `estopts'
                foreach v of local dummyvars { // some may have been dropped due to collinearity
                    capt di _[#1]_b[`v']
                    if _rc==0 {
                        local testterms `testterms' `v'
                    }
                }
                if "`testterms'"!="" {
                    qui test `testterms'
                    di as txt "(pilot goodness-of-fit chi2(" r(df) ") = " string(r(chi2),"%9.2f") "; p =" %7.4f r(p) ")"
                    if r(p)<`alpha' local force force
                    return scalar gof_p = r(p)
                    return scalar gof_df = r(df)
                    return scalar gof_chi2 = r(chi2)
                }
                //else local force force
            }
            if "`force'"!="" {
                // - semi-parametric model
                di as txt "(using penalized model ...)"
                `qui' xtmixed `depv' `controls' if `touse' || `var': , `estopts'
            }
            else {
                // - parametric-only model
                local K = 0
                local knotpos noknotpos
                di as txt "(using parametric model ...)"
                `qui' xtmixed `depv' `powers' `controls' if `touse', `estopts'
            }
        }
        else {
            // - non-penalized model
            di as txt "(using non-penalized model ...)"
            `qui' xtreg `depv' `controls' if `touse' ///
                , fe i(`var') `estopts'
        }
        // - predictions
        tempvar yhat
        local predictopt = cond("`penalty'"=="","fitted","xbu")
        qui predict `yhat' if e(sample), `predictopt'
        label var `yhat' "pspline smooth"
        if "`controls'"=="" {
            local yvar `depv'
            local yti: var lab `depv'
            if `"`yti'"'=="" local yti `depv'
        }
        else {
            foreach v of local controls {
                qui replace `yhat' = `yhat' - [#1]_b[`v']*`v'
            }
            /* alternative approach (partial predictor without constant):
                tempname xb
                predict `xb' if e(sample), xb
                qui replace `yhat' = `yhat' - `xb'
                foreach v of local powers {
                    qui replace `yhat' = `yhat' + [#1]_b[`v']*`v'
                }
            */
            tempvar rplus
            local predictopt = cond("`penalty'"=="","residuals","e")
            qui predict `rplus' if e(sample), `predictopt'
            qui replace `rplus' = `rplus' + `yhat'
            local yvar `rplus'
            local yti "Partial residual"
        }
    }
// algorithm for continuous x (using penalized splines)
    else {
        // - determine knots
        if `"`knots'"'=="" {
            if `nknots'<0 {
                qui count if `unique'<.
                local U = r(N)
                local K = min(int(`U'/4), 35)
                if `K'<2 {
                    di as err "not enough distinct values" //=> linear only
                    exit 198
                }
            }
            else local K `nknots'
            if `K'>0 {
                forv i = 1/`K' {
                    local pct "`pct' `=(`i')/(`K'+1)*100'"
                    // Ruppert et al. (2003; eq. 5.8) give rule (i+1)/(k+2) which seems to be a typo
                    // rule with half steps at beginning and end: local pct "`pct' `=(`i'-.5)/`K'*100'"
                }
                _pctile `unique' if `touse', p(`pct')
            }
        }
        else {
            postknotsinr `unique', knots(`knots') // returns knots in r(r1), r(r2), ...; also sets local K
        }
        // - generate splines
        if `K'>0 {
            tempname knotmat
            mat `knotmat' = J(1,`K', .z)
            local vartype = cond(`degree'==0, "byte", "")
            forv i = 1/`K' {
                tempvar spline`i'
                local splinevars "`splinevars' `spline`i''"
                local k = r(r`i')
                mat `knotmat'[1,`i'] = `k'
                local knottick "`knottick' `k'"
                qui gen `vartype' `spline`i'' = cond(`var' - `k' > 0, (`var' - `k')^`degree', 0)
                if `degree'==0 {
                    qui replace `spline`i'' = 1 if `var'==`k' // include lower boundary
                }
            }
        }
        // - fit models
        if "`penalty'"=="" {
            // - GOF test for parametric model
            if `K'==0 local force
            else if "`force'"=="" {
                qui xtmixed `depv' `powers' `controls' `splinevars' if `touse' ///
                    , `estopts'
                foreach v of local splinevars { // some may have been dropped due to collinearity
                    capt di _[#1]_b[`v']
                    if _rc==0 {
                        local testterms `testterms' `v'
                    }
                }
                if "`testterms'"!="" {
                    qui test `testterms'
                    di as txt "(pilot goodness-of-fit chi2(" r(df) ") = " string(r(chi2),"%9.2f") "; p =" %7.4f r(p) ")"
                    if r(p)<`alpha' local force force
                    return scalar gof_p = r(p)
                    return scalar gof_df = r(df)
                    return scalar gof_chi2 = r(chi2)
                }
                //else local force force
            }
            if "`force'"!="" {
                // - semi-parametric model
                di as txt "(using penalized model ...)"
                `qui' xtmixed `depv' `powers' `controls' if `touse' ///
                    || _all:`splinevars', cov(identity) noconstant `estopts'
            }
            else {
                // - parametric-only model
                local K = 0
                local knotpos noknotpos
                di as txt "(using parametric model ...)"
                `qui' xtmixed `depv' `powers' `controls' if `touse', `estopts'
            }
        }
        else {
            // - non-penalized model
            di as txt "(using non-penalized model ...)"
            `qui' xtmixed `depv' `powers' `controls' `splinevars' if `touse' ///
                , `estopts'
        }
        // - compute predictions
        tempvar yhat
        qui predict `yhat' if e(sample), fitted
        label var `yhat' "pspline smooth"
        if "`controls'"=="" {
            local yvar `depv'
            local yti: var lab `depv'
            if `"`yti'"'=="" local yti `depv'
        }
        else {
            foreach v of local controls {
                qui replace `yhat' = `yhat' - [#1]_b[`v']*`v'
            }
            /* alternative approach (partial predictor without constant):
            tempname xb
            predict `xb' if e(sample), xb
            qui replace `yhat' = `yhat' - `xb'
            foreach v of local powers {
                qui replace `yhat' = `yhat' + [#1]_b[`v']*`v'
            }
            */
            tempvar rplus
            qui predict `rplus' if e(sample), residuals
            qui replace `rplus' = `rplus' + `yhat'
            local yvar `rplus'
            local yti "Partial residual"
        }
    }
/*
    if "`ci'"!="" {
        tempname se ci_lo ci_up
        generate `se' = ???
        local z =  invnormal(1 - (100 - `level') / 200)
        qui gen `ci_lo' = `yhat' - `z' * `se'
        qui gen `ci_up' = `yhat' + `z' * `se'
    }
*/

// interpolate to at() values
    if "`at'"!="" {
        tempname touse0 yhat_at
        gen byte `touse0' = `yhat'<. & `unique'<.
        qui gen `yhat_at' = .
        mata: pspline_ipolate()
        local yhat `yhat_at'
        if "`graph'"=="" {
            sort `touse_at' `at'
            qui replace `unique' = cond(`at'!=`at'[_n-1] & `touse_at', `at', .)
        }
    }

// draw graph
    if "`graph'"=="" {
        if "`discrete'"!="" local plottype connected
        else                local plottype line
        local xti: var lab `var'
        if `"`xti'"'=="" local xti "`var'"
        if `degree'==0 {
            local stepconnect "connect(J)"
        }
        if "`knotpos'"=="" {
            local knotxmtick "xmtick(`knottick', tpos(inside) tlength(*2) tlc(red))"
        }
/*
        if "`ci'"!="" {
            local CIgraph ( rarea `ci_lo' `ci_up' `unique', pstyle(ci) legend(off) `ciopts' )
        }
*/
        local linestyle p1
        if "`scatter'"=="" {
            local linestyle p2
            local SCgraph ( scatter `yvar' `var' if `touse', pstyle(p1) legend(off) `options' )
        }
        twoway /*`CIgraph'*/ `SCgraph' ///
            ( `plottype' `yhat' `unique', sort pstyle(`linestyle') `stepconnect' `lineopts' ) ///
            || `addplot' || , ytitle(`"`yti'"') xtitle(`"`xti'"') `knotxmtick' `twopts'
    }

// return results
    return local discrete "`discrete'"
    return local model = cond("`penalty'"=="", cond("`force'"!="", "penalized", ///
        "parametric"), "non-penalized")
    if `K'>0 {
        ret mat knots = `knotmat'
    }
    return scalar alpha = `alpha'
    return scalar nknots = `K'
    return scalar degree = `degree'
    if `"`generate'"'!="" {
        if "`replace'"!="" {
            capt confirm var `generate', exact
            if _rc==0 drop `generate'
        }
        rename `yhat' `generate'
    }
end


program Vreturn
    args oldname newname replace
    if "`replace'"!="" {
        capt confirm var `newname', exact
        if !_rc drop `newname'
    }
    rename `oldname' `newname'
end


program parse_at
    syntax varname(numeric) [if] [in], touse(str)
    marksample touse0
    rename `touse0' `touse'
    c_local at `varlist'
end

program postknotsinr, rclass
    syntax varname, knots(str)
    sum `varlist', meanonly
    local i 0
    foreach k of local knots {
        if (`k'<r(min)) | (`k'>r(max)) {
            di as err "(`k' not in data range; knot dropped)"
            continue
        }
        local ++i
        return scalar r`i' = `k'
    }
*    if `i'==0 {
*        di as err "no valid knots"
*        exit 198
*    }
    c_local K `i'
end


version 9.2
mata:

void pspline_ipolate()
{
    real colvector x, y, at

    st_view(x, ., st_local("unique"), st_local("touse0"))
    st_view(y, ., st_local("yhat"), st_local("touse0"))
    st_view(at, ., st_local("at"), st_local("touse_at"))
    st_store(st_viewobs(at), st_local("yhat_at"), _pspline_ipolate(x, y, at))
}

real colvector _pspline_ipolate(
    real colvector x,       /// assumed unique and sorted; must have at least length 2
    real colvector y,
    real colvector xnew)
{
    real scalar     i, j, r, xi
    real colvector  p, ynew

    r = rows(x)
    if (rows(y)!=r) _error(3200)
    if (r<2) return(J(rows(xnew), 1, .))

    p = order(xnew, 1)
    ynew = J(rows(xnew),1,.)
    j = 1
    for (i=1; i<=rows(xnew); i++) {
        xi = xnew[p[i]]
        while (x[j]<xi) {
            if (j==r) break
            j++
        }
        if (x[j]==xi) {
            ynew[p[i]] = y[j]
            continue
        }
        if (j==1) j++
        ynew[p[i]] = y[j-1] + (y[j] - y[j-1]) * (xi - x[j-1]) / (x[j] - x[j-1])
    }
    return(ynew)
}

end
