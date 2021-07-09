*! version 1.0.9, Ben Jann, 07aug2007
*! version 1.0.4, Tom Masterson, 02may2007
*! version 1.0.3, Ben Jann, 05jul2006

prog anogi, sort
    version 9.2
    capt findfile lmoremata.mlib
    if _rc {
        di as error "-moremata- is required; type {stata ssc install moremata}"
        error 499
    }
    syntax varname(numeric) [if] [in] [fw aw pw/], by(varname) [ ///
     Detail Oji Fji noLabel vce(str) ] // "Oji Fji" added by tnm - 5/2/07
    local yvce = `"`vce'"'!=""
    if `yvce' {
        if inlist(`"`weight'"',"fweight","aweight") {
            di as err `"`weight's not allowed with vce()"'
            exit 198
        }
        parse_vce `vce'
    }
    marksample touse
    markout `touse' `by' `strata' `cluster' `fpc', strok
    if `"`fpc'"'!="" {
        capt assert `fpc'>=0 & `fpc'<=1 if `touse'
        if _rc {
            di as err "`fpc' not in [0,1]"
            exit 198
        }
    }
    if r(N)<1 error 2000
    if `yvce' sort `touse' `strata' `cluster'  //`_sortindex'
    else      sort `touse' `by' `varlist' //`_sortindex'
    mata: st_anogi()
    local width = 23 + 11*`yvce'
    di _n as txt "Analysis of Gini" _n
    di as txt "{hline 26}{c TT}{hline `width'}"
    di as txt "                          {c |}      Coef." _c
    if `yvce' di "   Std.Err." _c
    di "          %"
    di as txt "{hline 26}{c +}{hline `width'}"
    local G = el(r(b),1,1)
    if `yvce' {
        forv i=1/7 {
            local name: word `i' of G G_wo G_b IG IGO BGp BGO
            local se_`name' = sqrt(el(r(V),`i',`i'))
        }
    }
    Dline "Overall Gini" `G' `se_G' 100
    di as txt "                          {c |}"
    Dline "G_wo = sum s_i*G_i*O_i   " el(r(b),1,2) `se_G_wo' el(r(b),1,2)/`G'*100
    Dline "G_b                      " el(r(b),1,3) `se_G_b' el(r(b),1,3)/`G'*100
    di as txt "                          {c |}"
    Dline "IG   = sum s_i*G_i       " el(r(b),1,4) `se_IG' el(r(b),1,4)/`G'*100
    Dline "IGO  = sum s_i*G_i(O_i-1)" el(r(b),1,5) `se_IGO' el(r(b),1,5)/`G'*100
    Dline "BGp  = G_bp              " el(r(b),1,6) `se_BGp' el(r(b),1,6)/`G'*100
    Dline "BGO  = G_b - G_bp        " el(r(b),1,7) `se_BGO' el(r(b),1,7)/`G'*100
    di as txt "{hline 26}{c +}{hline `width'}"
    Dline `"Mean of `varlist'"' r(mean)
    Dline "N. of obs" r(N)
    Dline "N. of subgroups" r(k)
    di as txt "{hline 26}{c BT}{hline `width'}"
    if "`detail'"!="" {
        di
        matlist r(stats), border(row) nohalf ///
         title("Detailed statistics for subgroups")
    }
    if "`oji'"!="" { // Added by tnm - 5/2/07
        di
        matlist r(O_ji), border(row) nohalf ///
         title("O_ji Overlapping matrix")
    }
    if "`fji'"!="" { // Added by tnm - 5/2/07
        di
        matlist r(F_ji), border(row) nohalf ///
         title("F_ji matrix")
    }
    if `yvce' {
        PostInE
        KillReturns
    }
end

prog KillReturns, rclass
    local nothing nothing
end

prog Dline
    gettoken label values: 0
    di as txt %-25s `"`label'"' " {c |}" _c
    local fmt "%9.0g"
    local n: list sizeof values
    local i = 1
    foreach value of local values {
        di as res "  " `fmt' `value' _c
        if (`++i'==`n') local fmt "%9.2f"
    }
    di
end

program PostInE, eclass
    tempname b V stats O_ji F_ji
    mat `b' = r(b)
    mat `V' = r(V)
    mat `stats' = r(stats)
    eret post `b' `V'
    eret local cmd anogi
    eret scalar N = r(N)
    eret scalar df_r = r(df_r)
    eret scalar mean = r(mean)
    eret scalar k = r(k)
    capt confirm matrix r(O_ji) // Added by bj - 5/10/07
    if _rc==0 { // Added by tnm - 5/2/07; modified by bj - 5/16/07
        mat `F_ji' = r(F_ji)
        eret matrix F_ji = `F_ji'
        mat `O_ji' = r(O_ji)
        eret matrix O_ji = `O_ji'
    }
    eret matrix stats = `stats'
end

program parse_vce
    syntax [name(id=vce)] [ , STRata(varname) CLuster(varname) ///
     mse noDots fpc(varname) * ]
    local bsopts `options'
    c_local strata `strata'
    c_local cluster `cluster'
    c_local mse `mse'
    c_local nodots = ("`dots'"!="")
    c_local fpc `fpc'
    local 0 , `namelist'
    syntax [ , BOOTstrap JACKknife ]
    local vcetype `bootstrap'`jackknife'
    if "`vcetype'"=="" local vcetype bootstrap
    if "`vcetype'"=="bootstrap" & "`fpc'"!="" {
        di as err "fpc() not allowed with bootstrap"
        exit 198
    }
    if "`vcetype'"=="jackknife" & `"`bsopts'"'!="" {
        di as err `"'`bsopts'' not allowed with jackknife"'
        exit 198
    }
    c_local vcetype `vcetype'
    if "`vcetype'"=="bootstrap" {
        local 0 , `bsopts'
        syntax [ , Reps(int 50) ]
        if `reps' < 2 {
            di as err "reps() must be an integer greater than 1"
            exit 198
        }
        c_local reps `reps'
    }
end

version 9.2
mata:

//mata set matastrict on

struct s_anogi {
    real scalar            N, mu, k, df
    transmorphic colvector k_i
    real colvector         N_i, mu_i, s_i, G_i, O_i, F_i // F_i added by tnm 7/6/07
    real rowvector         b // = G, G_wo, G_b, IG, IGO, BGp, BGO
    real matrix            V, O_ji, F_ji // O_ji, F_ji added by tnm - 5/2/07
}

void st_anogi()
{
    struct s_anogi scalar  r
    pointer scalar         klabels
    string scalar          touse, byname, wtype, byvl
    real scalar            i, oji
    real colvector         x, w
    transmorphic colvector by
    string matrix          bstripe

    st_rclear()
    touse  = st_local("touse")
    x      = st_data(., st_local("varlist"), touse)
    byname = st_local("by")
    if (st_isstrvar(byname)) by = st_sdata(., byname, touse)
    else by = st_data(., byname, touse)
    wtype  = st_local("weight")
    if (wtype=="") w = 1
    else {
        w = st_data(., st_local("exp"), touse)
        if (wtype!="fweight") w = w * rows(x) / colsum(w)
    }
    oji = (st_local("oji")!="" | st_local("fji")!="") // Added by bj - 5/16/07
    bstripe = J(7, 1, ""),
     ("G", "G_wo", "G_b", "IG", "IGO", "BGp", "BGO")'
    if (st_local("vcetype")=="") r = anogi(x, w, by, 1, oji)
    else {
        r = anogi(x, w, by, 0, oji)
        st_anogi_vce(r, x, w, by, touse)
        st_numscalar("r(df_r)", r.df)
        st_matrix("r(V)", r.V)
        st_matrixcolstripe("r(V)", bstripe)
        st_matrixrowstripe("r(V)", bstripe)
    }
    st_numscalar("r(N)", r.N)
    st_numscalar("r(mean)", r.mu)
    st_numscalar("r(k)", r.k)
    if (isstring(r.k_i)) klabels = &r.k_i
    else {
        byvl = st_varvaluelabel(byname)
        if (byvl!="" & st_local("label")=="") {
            klabels = &st_vlmap(byvl, r.k_i)
            for (i=1; i<=r.k; i++) {
                if ((*klabels)[i]=="") (*klabels)[i] = strofreal(r.k_i[i])
            }
        }
        else klabels = &strofreal(r.k_i)
    }
    if (oji) { // Added by tnm - 5/2/07; modified by bj - 5/16/07
        st_matrix("r(F_ji)", (r.F_ji))
        st_matrixrowstripe("r(F_ji)", (J(r.k, 1, ""), *klabels))
        st_matrixcolstripe("r(F_ji)", (J(r.k, 1, ""), *klabels))
        st_matrix("r(O_ji)", (r.O_ji))
        st_matrixrowstripe("r(O_ji)", (J(r.k, 1, ""), *klabels))
        st_matrixcolstripe("r(O_ji)", (J(r.k, 1, ""), *klabels))
    }
    st_matrix("r(stats)", (r.N_i, r.N_i/r.N, r.mu_i, r.s_i, r.G_i, r.O_i, r.F_i))
    st_matrixcolstripe("r(stats)",
     (J(7, 1, ""), ("N", "p", "mean", "s", "G", "O", "F")'))
    st_matrixrowstripe("r(stats)", (J(r.k, 1, ""), *klabels))
    st_matrix("r(b)", r.b)
    st_matrixcolstripe("r(b)", bstripe)
}

void st_anogi_vce(
 struct s_anogi scalar r,
 real colvector x,
 real colvector w,
 transmorphic colvector by,
 string scalar touse)
{
    string scalar   vce, strata, cluster
    real scalar     mse, nodots, reps
    real colvector  stra, clust, fpc

    vce     = st_local("vcetype")
    mse     = st_local("mse")!=""
    nodots  = strtoreal(st_local("nodots"))
    strata  = st_local("strata")
    cluster = st_local("cluster")
    reps    = strtoreal(st_local("reps"))
    if (strata!="")  stra  = st_data(., strata, touse)
    if (cluster!="") clust = st_data(., cluster, touse)
    if (vce=="bootstrap") {
        struct mm_bsstats scalar bs
        bs = mm_bs(&anogi_repl(),
         (x, (isstring(by) ? strtoreal(by) : by)),
         w, reps, 0, nodots, stra, clust, r.b)
        r.V = mm_bs_report(bs, "v", 95, mse)
        r.df = bs.reps-1
    }
    else if (vce=="jackknife") {
        struct mm_jkstats scalar jk
        if (st_local("fpc")!="")
         fpc = st_data(., st_local("fpc"), touse)
        jk = mm_jk(&anogi_repl(),
         x, w, nodots, stra, clust, ., fpc, r.b, by)
        r.V = mm_jk_report(jk, "v", 95, mse)
        r.df = rows(jk.rstat)-rows(jk.reps)
    }
    else _error(3498)
}

real rowvector anogi_repl(
 real matrix x,
 real colvector w,
 | transmorphic colvector by)
{
    struct s_anogi scalar r
    if (args()<3) r = anogi(x[,1], w, x[,2], 0)
    else          r = anogi(x, w, by, 0)
    return(r.b)
}

struct s_anogi scalar anogi(
 real colvector x,
 real colvector w,
 transmorphic colvector by,
 | real scalar sorted,
   real scalar oji) // Added by bj - 5/16/07
{
    struct s_anogi scalar  r
    real scalar            i, j
    real colvector         p, F, F_iu, F_i, x_i, w_i, F_ij, H
    real matrix            mv, g
    pointer scalar         X, W, B

    if (args()<4) sorted = 0
    if (sorted) {; X = &x; W = &w; B = &by; }
    else {
        p = order((by, x), (1,2))
        if (isfleeting(x)) {; _collate(x,p); X = &x; }
        else X = &x[p,]
        if (isfleeting(by)) {; _collate(by,p); B = &by; }
        else B = &by[p,]
        if (rows(w)==1) W = &w
        else if (isfleeting(w)) {; _collate(w,p); W = &w; }
        else W = &w[p,]
    }
    r.b    = J(1,7,.)
    r.N    = mm_nobs(*X, *W)
    F      = mm_ranks(*X, *W, 3, 1, 1)
    mv     = mm_meanvariance0((*X, F), *W)
    r.mu   = mv[1,1]
    r.b[1] = mv[3,1] * 2 / r.mu  // G
    g      = panelsetup(*B, 1)
    r.k    = rows(g)
    r.k_i  = J(r.k, 1, missingof(*B))
    r.G_i  = r.s_i = r.O_i = r.mu_i = r.N_i = r.F_i = J(r.k, 1, .)
    if (oji==1) { // Added by tnm - 5/2/07; modified by bj - 5/16/07
        H = mm_freq2(*X, *W)
        r.O_ji = r.F_ji = J(r.k, r.k, .)
    }
    for (i=1; i<=r.k; i++) {
        r.k_i[i]  = (*B)[g[i,1]]
        x_i       = (*X)[|g[i,1] \ g[i,2]|]
        F_iu      = F[|g[i,1] \ g[i,2]|]
        w_i       = (rows(*W)==1 ? *W : (*W)[|g[i,1] \ g[i,2]|])
        r.N_i[i]  = (rows(w_i)==1 ? rows(x_i)*w_i : colsum(w_i))
        F_i       = mm_ranks(x_i, w_i, 3, 1, 1)
        mv        = mm_meanvariance0((x_i, F_i, F_iu), w_i)
        r.mu_i[i] = mv[1,1]
        r.F_i[i]  = mv[1,3]
        r.G_i[i]  = mv[3,1] * 2 / r.mu_i[i]
        r.s_i[i]  = r.N_i[i]/r.N * r.mu_i[i] / r.mu
        r.O_i[i]  = mv[4,1] / mv[3,1]
        if (oji==1) { // Added by tnm - 5/2/07; modified by bj - 5/24/07
            for (j=1; j<=r.k; j++) {
                F_ij = _mm_relrank((*X)[|g[j,1] \ g[j,2]|],
                  (rows(*W)==1 ? *W : (*W)[|g[j,1] \ g[j,2]|]), x_i, 1)
                mv   = mm_meanvariance0((x_i, F_i, F_ij), w_i)
                r.F_ji[i,j] = mv[1,3]
                r.O_ji[i,j] = mv[4,1] / mv[3,1]
            }
        }
    }
    r.b[2]/*r.G_wo*/ = colsum(r.s_i:*r.G_i:*r.O_i)
    r.b[3]/*r.G_b*/  = mm_variance0((r.mu_i, r.F_i), r.N_i)[2,1] * 2 / r.mu
    r.b[4]/*r.IG*/   = colsum(r.s_i:*r.G_i)
    r.b[5]/*r.IGO*/  = colsum(r.s_i:*r.G_i:*(r.O_i :-1))
    r.b[6]/*r.BGp*/  = mm_variance0((r.mu_i, mm_ranks(r.mu_i, r.N_i, 3, 1, 1)),
                       r.N_i)[2,1] * 2 / r.mu
    r.b[7]/*r.BGO*/  = r.b[3] - r.b[6]
    return(r)
}

end
