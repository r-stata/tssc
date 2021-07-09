*! version 1.0.5  Ben Jann  09apr2008

prog mgof, byable(recall)
    version 9.2
    capt mata mata which mm_mgof()
    if _rc {
        di as error "mm_mgof() from -moremata- is required; type {stata ssc install moremata}"
        error 499
    }
    syntax [anything(equalok)] [if] [in] [fw pw iw] [, ///
        Freq Percent ///
        Approx Approx2(real 0) ///
        mc reps(int 10000) Level(string) CItype(str) ///
        ee ///
        rc /// undocumented; do not use this
        noX2 nolr mlnp KSmirnov cr CR2(numlist max=1 missingok) ///
        MATrix(name) EXPected(name) VMATrix(name) df_r(numlist max=1) noDOTs ///
        vce(passthru) CLuster(passthru) svy SVY2(string) NOIsily /// => pass thru to -proportion-
     ]
    if "`freq'"!="" & "`percent'"!="" {
        di as err "freq and percent not both allowed"
        exit 198
    }
    local x2 = cond("`x2'"!="","","x2")
    local lr = cond("`lr'"!="","","lr")
    if `"`cr2'"'!="" local cr "cr"
    else local cr2 "."
    if `"`matrix'"'=="" {
        ParseVarnameExp `anything'
    }
    else {
        if `"`anything'`if'`in'`weight'`vce'`cluster'`svy'`svy2'"'!="" {
            di as err "varname, if, in, weights, vce, cluster, or svy" _c
            di as err " not allowed with matrix()"
            exit 198
        }
        confirm matrix `matrix'
    }
    if `"`level'"'=="" local level 99
    CheckCIopts, level(`level') `citype'
    local pw = (`"`weight'"'=="pweight")
    local iw = (`"`weight'"'=="iweight")
    if `"`svy2'"'!="" {
        local svy `"svy `svy2':"'
    }
    else if "`svy'"!="" local svy "svy:"
    local getV = (`pw' | `"`vce'`cluster'`svy'"'!="")
    local svycorr = (`getV' | ("`matrix'"!="" & "`vmatrix'"!="") )
    if _by() & `"`svy'"'!="" {
        di as err "svy may not be combined with by"
        exit 190
    }

// determin method and stats
    if ((("`approx'"!="")+("`mc'"!="")+("`rc'"!="")+("`ee'"!=""))>1) {
        di as err "only one of approx, mc, and ee allowed"
        exit 198
    }
    local method "`approx'`mc'`rc'`ee'"
    if "`method'"=="" local method "approx"
    if "`method'"=="approx" {
        if "`ksmirnov'"!="" {
            di as err "ksmirnov only allowed with mc, or ee"
            exit 198
        }
        if "`mlnp'"!="" {
            di as err "mlnp only allowed with mc, or ee"
            exit 198
        }
    }
    local stats = trim("`x2' `lr' `cr' `mlnp' `ksmirnov'")
    if `"`stats'"'=="" {
        di as err "at least one statistic must be specified"
        exit 198
    }
    if  "`method'"!="approx" {
        if `svycorr' {
            di as err "`method' not allowed with survey design correction"
            exit 198
        }
        if `iw' & "`method'"!="mc"  {
            di as err "iweights not allowed with `method'"
            exit 198
        }
    }

// get Var-Cov of proportions
    if `svycorr' {
        if `getV' {
            tempname ecurrent matrix vmatrix touse
            mark `touse' `if' `in' // to take account of -by:-
            _est hold `ecurrent', restore estsystem nullok
            local qui qui
            if "`noisily'"!="" local qui
            `qui' `svy' proportion `varlist' if `touse' [`weight'`exp'], nolabel `vce' `cluster'
            mat `matrix' = e(b)'
            //mat roweq `matrix' = ""
            if e(N_sub)<.   mat `matrix' = `matrix' * e(N_sub)
            else            mat `matrix' = `matrix' * e(N)
            qui replace `touse' = e(sample)
            if `"`h0exp'"'!="" {
                tempvar h0
                qui gen double `h0' = `h0exp' if `touse'
            }
            mat `vmatrix' = e(V)
            if e(df_r)<. local df_r = e(df_r)
            else {
                if e(N_psu)<.   local df_r = e(N_psu)
                else if e(N_clust)<. local df_r = e(N_clust)
                else            local df_r = e(N)
                if e(N_strata)<.    local df_r = `df_r' - e(N_strata)
                else                local df_r = `df_r' - 1
            }
        }
        else {
            if `"`df_r'"'=="" {
                di as err "must specify df_r()"
                exit 198
            }
        }
    }

// estimation sample
    if `"`matrix'"'=="" {
        marksample touse, zeroweight
        if `"`h0exp'"'!="" {
            tempvar h0
            qui gen double `h0' = `h0exp' if `touse'
        }
    }

// compute tests
    mata: _mgof()

// apply survey design correction
    if `svycorr' {
        mata: _mgof_svycorr()
    }

// display tests
    if inlist(r(method),"mc","rc")  local plusw 24
    else if `svycorr'               local plusw 11
    else local                      plusw 0
    di ""
    if "`svy'"!="" {
        di as txt "Number of strata =" as res %8.0g r(N_strata) _skip(8) ///
           as txt "Number of obs =" as res %8.0g r(N)
        di as txt "Number of PSUs   =" as res %8.0g r(N_psu) _skip(8) ///
           as txt "Pop size      =" as res %8.0g r(N_pop)
        di as txt _skip(`=23+`plusw'') ///
           as txt "Design df     =" as res %8.0g r(df_r)

    }
    else {
        di as txt _skip(`=23+`plusw'') "Number of obs =" as res %8.0g r(N)
    }
    if r(N_clust)<. & "`svy'"=="" {
         di as txt _skip(`=23+`plusw'') "N of clusters =" as res %8.0g r(N_clust)
    }
    di as txt _skip(`=23+`plusw'') "N of outcomes =" as res %8.0g r(r)
    if r(method)=="approx" {
        if `svycorr' {
            di as txt _skip(`=23+`plusw'') "F df1         =" as res %8.0g r(df1)
            di as txt _skip(`=23+`plusw'') "F df2         =" as res %8.0g r(df2)
        }
        else {
            di as txt _skip(`=23+`plusw'') "Chi2 df       =" as res %8.0g r(df)
        }
    }
    else if inlist(r(method),"mc","rc") {
        di as txt _skip(`=23+`plusw'') "Replications  ="  as res %8.0g r(reps)
    }
    else if r(method)=="ee" {
        capt confirm scalar r(partitions)
        if _rc {
            di as txt _skip(`=23+`plusw'') "Compositions  =" as res %8.0g r(compositions)
        }
        else {
            di as txt _skip(`=23+`plusw'') "Partitions    =" as res %8.0g r(partitions)
        }
    }
    di _n as txt "{hline 22}{c TT}{hline `=23+`plusw''}"
    if inlist(r(method),"mc","rc","ee") {
        di as txt %21s "" " {c |}" %12s "" %11s "Exact" _skip(`plusw')
    }
    di as txt %21s "Goodness-of-fit" " {c |}" %12s "Coef." _c
    if `svycorr' di %11s `"F-value"' _c
    di %11s "P-value" _c
    if inlist(r(method),"mc","rc") di %24s `"[`level'% Conf. Interval]"' _c
    di ""
    di as txt "{hline 22}{c +}{hline `=23+`plusw''}"
    foreach stat in `r(stats)' {
        if "`stat'"=="x2"            local crit "Pearson's X2"
        else if "`stat'"=="lr"       local crit "Log likelihood ratio"
        else if "`stat'"=="cr"       local crit `"Cressie-Read (`r(lambda)')"'
        else if "`stat'"=="mlnp"     local crit "Log outcome prob."
        else if "`stat'"=="ksmirnov" local crit "Kolmogorov-Smirnov D"
        di as txt %21s "`crit'" " {c |}   " as res %9.0g r(`stat') _c
        if `svycorr' di "  " %9.4f r(F_`stat') _c
        di "  " %9.4f r(p_`stat') _c
        if inlist(r(method),"mc","rc") {
            di as res "   " %9.4f r(p_`stat'_lb) "   " %9.4f r(p_`stat'_ub) _c
        }
        di ""
    }
    di as txt "{hline 22}{c BT}{hline `=23+`plusw''}"

// display table (if -freq-)
    if "`freq'`percent'"!="" {
        tempname tmpmat
        mat `tmpmat' = r(count) \ ( r(N), r(N) )
        if "`percent'"!="" {
            mat `tmpmat' = `tmpmat' / r(N) * 100
            local matlistfmt "format(%9.2f)"
        }
        mat rown `tmpmat' = `: rown r(count)' Total
        matlist `tmpmat', rowtitle("`varlist'") nohalf lines(rowtotal) `matlistfmt'
        mat drop `tmpmat'
    }

end

prog ParseVarnameExp
    capt syntax varlist(min=2 max=2 numeric) // allow "mgof x y ..."
    if _rc==0 {
        c_local varlist: word 1 of `varlist'
        c_local h0exp: word 2 of `varlist'
        exit
    }
    else if _rc==109 {
        syntax varlist(min=2 max=2 numeric)
    }
    syntax varname(numeric) [=/exp]
    c_local varlist "`varlist'"
    c_local h0exp `"`exp'"'
end

prog CheckCIopts
    syntax , Level(cilevel) [ EXAct WAld Wilson Agresti Jeffreys ]
    local citype = trim("`exact' `wald' `wilson' `agresti' `jeffreys'")
    if `:list sizeof citype'>1 {
        di as err "Only one of exact, wald, agresti, wilson, and jeffreys allowed"
        exit 198
    }
    if "`citype'"=="" local citype "exact"
    c_local citype "`citype'"
end

version 9.2
mata:

mata set matastrict on

void _mgof()
{
    real scalar            i, n, comp, m_arg, lambda, touse
    real colvector         x, w, f, h, h0, tmp, levels
    real matrix            res, ci
    string scalar          method, stats, citype, cilevel, eetype
    string colvector       labels

// prepare f (observed counts) and h (expected counts)
    if (st_local("matrix")!="") {
        tmp = st_matrix(st_local("matrix"))
        labels = st_matrixrowstripe(st_local("matrix"))[,2]
        f = tmp[,1]
        n = colsum(f)
        if (cols(tmp)>1) {
            h = tmp[,2]
            if (mm_isconstant(h)) h = 1
            else h = h * n / colsum(h)
        }
        else h = 1
    }
    else {
        touse = st_varindex(st_local("touse"))
        st_view(x, ., st_local("varlist"), touse)
        if (st_local("exp")!="") {
            st_view(w, ., substr(st_local("exp"),3,.), touse)
            if (st_local("iw")=="1") {
                n = colsum(w:!=0) // do not count obs with iweight==0
                w = w / colsum(w) * n
            }
            else n = colsum(w)
        }
        else {
            w = 1
            n = rows(x)
        }
        if (n<=0) _error(2000)
        f = mm_freq(x,w,levels=.)
        labels = strofreal(levels)
        for (i=1;i<=rows(levels);i++) {
            if (levels[i]<0 | strpos(labels[i],".")) labels[i] = "_cat_"+strofreal(i)
        }
        h = 1
    }
    if (st_local("h0exp")!="") {
        if (st_local("matrix")!="") {   // only possible if matrix is set internally
            touse = st_varindex(st_local("touse"))  // (i.e. if proportions is used)
            st_view(x, ., st_local("varlist"), touse)
            tmp = mm_freq(x,1,levels=.)
        }
        st_view(h0, ., st_local("h0"), touse)
        h = J(rows(levels),1,.)
        for (i=1;i<=rows(levels);i++) {
            tmp = select(h0, x:==levels [i] :& h0:<.)
            if (rows(tmp)<1) _error(3498,
                "exp is missing for some levels of " + st_local("varlist"))
            if (mm_isconstant(tmp)==0) _error(3498,
                "exp not constant within levels of " + st_local("varlist"))
            h[i] = tmp[1]
        }
        if (mm_isconstant(h)) h = 1
        else h = h * n / colsum(h)
    }
    else if (st_local("expected")!="") {
        h = st_matrix(st_local("expected"))
        if (mm_isconstant(h)) h = 1
        else h = h * n / colsum(h)
    }

// compute stats
    stats  = tokens(st_local("stats"))'
    method = st_local("method")
    if (method=="ee") {
        if (h==1 & !anyof(stats,"ksmirnov")) eetype = "partitions"
        else                                 eetype = "compositions"
    }
    if (method=="approx")                 m_arg = strtoreal(st_local("approx2"))
    else if (method=="mc" | method=="rc") m_arg = strtoreal(st_local("reps"))
    else                                  m_arg = .
    lambda = strtoreal(st_local("cr2"))
    res = mm_mgof(f, h, method, stats, lambda, m_arg, st_local("dots")=="", comp)

// compute ci's in case of mc method
    if (method=="mc") {
        citype = st_local("citype")
        cilevel = st_local("level")
        ci = J(rows(stats),2,.)
        for (i=1;i<=rows(stats);i++) {
            stata("qui cii " + strofreal(m_arg) + " " +
             strofreal(round(res[i,2]*m_arg)) +
             " , level(" + cilevel + ") " + citype)
            ci[i,] = st_numscalar("r(lb)"),st_numscalar("r(ub)")
        }
    }

// compute ci's in case of rc method
    if (method=="rc") {
        cilevel = st_local("level")
        ci = J(rows(stats),2,.)
        for (i=1;i<=rows(stats);i++) {
            ci[i,] = res[i,2] :+ (-1,1):*invttail(m_arg, (100-strtoreal(cilevel))/200) * res[i,3]
        }
    }

// keep results within bounds [0,1]
    res[,2] = rowmin((J(rows(res),1,1),rowmax((J(rows(res),1,0),res[,2]))))
    if (rows(ci)>0) {
        ci[,1]  = rowmax((J(rows(ci),1,0),ci[,1]))
        ci[,2]  = rowmin((J(rows(ci),1,1),ci[,2]))
    }

// returns
    st_rclear()
    st_numscalar("r(N)",n)
    st_numscalar("r(r)",rows(f))
    if (method=="approx") st_numscalar("r(df)",rows(f)-m_arg-1)
    else if (method=="mc" | method=="rc") {
        st_numscalar("r(reps)", m_arg)
        st_global("r(cilevel)", cilevel)
        if (method=="mc") st_global("r(citype)", citype)
    }
    else if (method=="ee") st_numscalar("r("+eetype+")",comp)
    if (anyof(stats,"cr"))
     st_global("r(lambda)",(lambda>=. ? "2/3" : strofreal(lambda)))
    st_global("r(stats)",st_local("stats"))
    st_global("r(method)",method)
    for (i=1;i<=rows(stats);i++) {
        st_numscalar("r("+stats[i]+")",res[i,1])
        st_numscalar("r(p_"+stats[i]+")",res[i,2])
        if (method=="mc" | method=="rc") {
            st_numscalar("r(p_"+stats[i]+"_lb)",ci[i,1])
            st_numscalar("r(p_"+stats[i]+"_ub)",ci[i,2])
        }
    }
    if (st_local("matrix")=="" & st_local("expected")=="") {
        st_global("r(h0)","= " + (st_local("h0exp")!="" ?
         st_local("h0exp") : "1/"+strofreal(rows(f))))
        st_global("r(depvar)",st_local("varlist"))
    }
    st_matrix("r(count)",(f,(h==1 ? J(rows(f),1,n/rows(f)): h)))
    st_matrixrowstripe("r(count)", (J(rows(f),1,""), labels))
    st_matrixcolstripe("r(count)", (J(2,1,""),("observed"\"expected")))
    if (st_local("svy")!="") {
        st_numscalar("r(N_strata)", st_numscalar("e(N_strata)"))
        st_numscalar("r(N_psu)", st_numscalar("e(N_psu)"))
        st_numscalar("r(N_pop)", st_numscalar("e(N_pop)"))
        st_numscalar("r(df_r)", st_numscalar("e(df_r)"))
    }
    else if (st_local("getV")=="1") {
        if (length(st_numscalar("e(N_clust)"))>0) {
            st_numscalar("r(N_clust)", st_numscalar("e(N_clust)"))
        }
    }
}

void _mgof_svycorr()
{
    string rowvector    s
    real scalar         n, k, nfit, r, l, a2, d, i, x2
    real colvector      p
    real matrix         V

    s    = tokens(st_global("r(stats)"))
    n    = st_numscalar("r(N)")
    p    = st_matrix("r(count)")[,1] / n
    k    = rows(p)
    nfit = strtoreal(st_local("approx2"))
    V    = st_matrix(st_local("vmatrix")) * (n-1)
    r    = strtoreal(st_local("df_r"))
    l    = colsum( diagonal(V) :/ p ) / (k-1)  // delta
    a2   = ( sum( V:^2 :/ (p*p') ) / (k-1) ) / l^2 - 1
    d    = (k - nfit - 1) / (1 + a2)
    for (i=1; i<=cols(s); i++) {
        // backup srs p-value
        st_numscalar("r(p_"+s[i]+"_srs)", st_numscalar("r(p_"+s[i]+")"))

        // Rao and Scott second order F ~ F(d, d*r)
        x2 = st_numscalar("r("+s[i]+")")
        st_numscalar("r(F_"+s[i]+")", x2/l/(k-nfit-1)) // = x2/(l*(a2+1)) / d
        st_numscalar("r(p_"+s[i]+")", Ftail(d, d*r, x2/l/(k-nfit-1)))
    }
    st_numscalar("r(df1)", d)
    st_numscalar("r(df2)", d*r)
    st_numscalar("r(delta)", l)
    st_numscalar("r(a2)", a2)

//    // extended results
//    real scalar         W
//    real colvector      p0
//    p0  = st_matrix("r(count)")[,2] / n
//    //Wald X2 ~ chi2(k-1)
//    W = (n-1)*(p[|1\k-1|]-p0[|1\k-1|])' * invsym(V[|1,1\k-1,k-1|]) *
//              (p[|1\k-1|]-p0[|1\k-1|])
//    st_numscalar("r(W)", W)
//    st_numscalar("r(p_W)", chi2tail(k-nfit-1, W))
//    //Wald F ~ F(k-1, r) (same as -proportion- followed by -test-)
//    st_numscalar("r(F_W)", W / (k-nfit-1))
//    st_numscalar("r(p_F_W)", Ftail(k-nfit-1, r, W / (k-nfit-1)))
//    //adjusted Wald F ~ F(k-1, r-k+1)
//    W =  W*(r-(k-nfit-1)+1)/((k-nfit-1)*r)
//    st_numscalar("r(F_W_a)", W)
//    st_numscalar("r(p_F_W_a)", Ftail(k-nfit-1, r-(k-nfit-1)+1, W))
//    for (i=1; i<=cols(s); i++) {
//        x2 = st_numscalar("r("+s[i]+")")
//        // Rao and Scott first order X2 ~ chi2(k-1)
//        st_numscalar("r("+s[i]+"_rs1)", x2/l)
//        st_numscalar("r(p_"+s[i]+"_rs1)", chi2tail(k-nfit-1, x2/l))
//        // Rao and Scott first order F ~ F(k-1, (k-1)*r)
//        st_numscalar("r(F_"+s[i]+"_rs1)", x2/l/(k-nfit-1))
//        st_numscalar("r(p_F_"+s[i]+"_rs1)", Ftail(k-nfit-1, (k-nfit-1)*r, x2/l/(k-nfit-1)))
//        // Rao and Scott second order X2 ~ chi2(d)
//        st_numscalar("r("+s[i]+"_rs2)", x2/l/(1 + a2))
//        st_numscalar("r(p_"+s[i]+"_rs2)", chi2tail(d, x2/l/(1 + a2)))
//    }
}

end
