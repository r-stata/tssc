*! version 1.0.6  14aug2021  Ben Jann

program ebalfit_p
    if `"`e(cmd)'"'!="ebalfit" {
        di as err "last ebalfit results not found"
        exit 301
    }
    local opts xb pr w u PScore
    syntax [anything] [if] [in] [, `opts' IFs NOCons NOAlpha ]
    if `"`pscore'"'!="" local pr pr
    local opt `xb' `pr' `w' `u' `ifs'
    if `:list sizeof opt'>1 {
        di as err "only one option allowed"
        exit 198
    }
    if `"`if'`in'"'!="" local iff `if' `in'
    else                local iff if e(sample)
    if "`ifs'"=="" {
        syntax newvarname [if] [in] [, `opts' ]
        // linear prediction
        if "`opt'"=="xb" {
            _predict double `typlist' `varlist' `iff', xb
            exit
        }
        // propensity score
        tempname z
        qui _predict double `z' `iff', xb nolabel
        if "`opt'"=="pr" {
            tempname W TAU
            mat `W' = e(_W)
            scalar `TAU' = e(tau)
            if `TAU'!=`W'[1,2] {
                qui replace `z' = `z' + ln(`W'[1,2]/`TAU') `iff'
            }
            gen `typlist' `varlist' = invlogit(`z') `iff'
            lab var `varlist' "Propensity score"
            exit
        }
        // (raw) balancing weights
        if `"`e(by)'"'!="" {
            local byval = substr(e(balsamp),1,strpos(e(balsamp),".")-1)
            qui replace `z' = 0 if `e(by)'!=`byval' & `z'<.
        }
        // - raw
        if "`opt'"=="u" {
            gen `typlist' `varlist' = exp(`z') `iff'
            lab var `varlist' "Raw balancing weights"
            exit
        }
        // - balancing weights
        if `"`e(wtype)'"'!="" {
            tempname w0
            qui gen double `w0' `e(wexp)' `iff'
            gen `typlist' `varlist' = `w0' * exp(`z') `iff'
        }
        else {
            gen `typlist' `varlist' = exp(`z') `iff'
        }
        lab var `varlist' "Balancing weights"
        exit
    }
    // IFs
    if "`nocons'"!="" local noalpha noalpha
    // - parse newvarlist
    capt syntax newvarlist [if] [in]
    if _rc==1 exit _rc
    if _rc {
        tempname b
        mat `b' = e(b)
        mata: st_local("coleq", ///
            invtokens("eq":+strofreal(1..cols(st_matrix("e(b)")))))
        mat coleq `b' = `coleq'
        if "`noalpha'"!="" {
            matrix `b' = `b'[1,1..colsof(`b')-1]
        }
        _score_spec `anything', scores b(`b')
        local varlist `s(varlist)'
        local typlist `s(typlist)'
    }
    // - mark estimation sample
    tempname touse
    qui gen byte `touse' = e(sample)==1
    if `"`e(by)'"'!="" {
        local byval = substr(e(balsamp),1,strpos(e(balsamp),".")-1)
        tempname touse1 touse0
        qui gen byte `touse1' = `e(by)'==`byval' & `touse'
        if `"`e(refsamp)'"'=="pooled" local touse0 `touse'
        else {
            qui gen byte `touse0' = `touse1'==0 & `touse'
        }
    }
    else {
        local touse1 `touse'
        local touse0 `touse'
    }
    if `"`e(wtype)'"'!="" {
        tempname w0
        qui gen double `w0' `e(wexp)' if `touse'
    }
    // - compute IFs
    mata: ebalfit_p_IFs()
    local coln: colnames e(b)
    foreach v of local varlist {
        gettoken typ typlist : typlist
        gettoken lbl coln : coln
        gettoken IF IFs : IFs
        if "`IF'"=="" continue, break
        qui gen `typ' `v' = cond(e(sample), `IF', 0) `iff'
        lab var `v' `"IF of _b[`lbl']"'
    }
end

version 14

mata:
mata set matastrict on

void ebalfit_p_IFs()
{
    real scalar      k, pop, pooled, W, Wref, tau
    real colvector   b, omit, w, wbal
    real rowvector   mu, madj, adj, noadj
    real matrix      X, Xref
    string rowvector xvars, IFs
    string scalar    touse, touse1, touse0
    struct _mm_ebalance_IF scalar IF
    pragma unset X
    pragma unset Xref
    
    // collect info
    touse  = st_local("touse")
    touse1 = st_local("touse1")
    touse0 = st_local("touse0")
    mu   = st_matrix("e(baltab)")[,1]'
    madj = st_matrix("e(baltab)")[,4]'
    W    = st_matrix("e(_W)")[1,1]
    Wref = st_matrix("e(_W)")[1,2]
    tau  = st_numscalar("e(tau)")
    pop = st_global("e(by)")==""
    pooled = st_global("e(refsamp)")=="pooled"
    xvars = tokens(st_global("e(varlist)"))
    st_view(X, ., xvars, touse) // read full data matrix first
    if (st_local("w0")!="") w = st_data(., st_local("w0"), touse1)
    else                    w = 1
    if (pop) {
        Xref = mu
    }
    else if (pooled) {
        st_subview(Xref, X, ., .)
        st_subview(X, X, selectindex(st_data(., touse1, touse)), .)
    }
    else {
        st_subview(Xref, X, selectindex(st_data(., touse0, touse)), .)
        st_subview(X, X, selectindex(st_data(., touse1, touse)), .)
    }
    b = st_matrix("e(b)")'
    k = rows(b)
    wbal = w :* exp(X*b[|1\k-1|] :+ b[k])
    omit = st_matrix("e(omit)")'
    adj = strtoreal(tokens(st_global("e(adjust)")))
    noadj = strtoreal(tokens(st_global("e(noadjust)")))
    
    // prepare tempvars
    IFs = st_tempname(k)
    (void) st_addvar("double", IFs)
    st_local("IFs", invtokens(IFs))
    
    // compute IFs
    _mm_ebalance_IF_b(IF, X, Xref, w, wbal, madj, mu, tau, W, Wref, adj, noadj,
        omit)
    _mm_ebalance_IF_a(IF, X, w, wbal, tau, W)
    
    // copy IFs to tempvars
    if (pop) st_store(., IFs, touse, (IF.b, IF.a))
    else {
        st_store(., IFs, touse0, (IF.b0, IF.a0))
        if (pooled) st_store(., IFs, touse1,
            st_data(., IFs, touse1) + (IF.b, IF.a))
        else st_store(., IFs, touse1, (IF.b, IF.a))
    }
}

end

exit

