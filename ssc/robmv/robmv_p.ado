*! version 1.0.1  30dec2020  Ben Jann

program define robmv_p
    version 11
    if `"`e(cmd)'"'!="robmv" {
        di as err "last robmv results not found"
        exit 301
    }
    if `"`e(subcmd)'"'=="classic" {
        robmv_p_m `0'   // !!
    }
    else if `"`e(subcmd)'"'=="m" {
        robmv_p_m `0'
    }
    else if `"`e(subcmd)'"'=="s" {
        robmv_p_m `0'
    }
    else if `"`e(subcmd)'"'=="mm" {
        robmv_p_m `0'
    }
    else if `"`e(subcmd)'"'=="mcd" {
        robmv_p_mcd `0'
    }
    else if `"`e(subcmd)'"'=="mve" {
        robmv_p_mcd `0'
    }
    else if `"`e(subcmd)'"'=="sd" {
        if `"`e(nofit)'"'!="" {
            di as err "{bf:predict} not allowed after {bf:robmv sd}" /*
                */ " if option {bf:nofit} has been specified"
            exit 498
        }
        robmv_p_m `0'   // !!
    }
    else {
        di as err `"`e(subcmd)': unknown robmv subcommand"'
        exit 499
    }
end

program define Parse_outlier_inlier
    syntax [, Outlier Outlier2(numlist max=1) Inlier Inlier2(numlist max=1) ]
    if "`outlier2'"!="" {
        if `outlier2'<0 | `outlier2'>50 {
            di as err "outlier(): # must be in [0, 50]"
            exit 198
        }
    }
    else if "`outlier'"!="" local outlier2 2.5
    c_local outlier `outlier2'
    if "`inlier2'"!="" {
        if `inlier2'<50 | `inlier2'>100 {
            di as err "inlier(): # must be in [50, 100]"
            exit 198
        }
    }
    else if "`inlier'"!="" local inlier2 97.5
    c_local inlier `inlier2'
end

program define robmv_p_m
    syntax newvarname(generate) [if] [in] [, Rd Distance Weights * ]
    Parse_outlier_inlier, `options'
    local stat `rd' `distance' `outlier' `inlier' `weights'
    if `: list sizeof stat'>1 {
        di as err "only one of rd, distance, outlier, inlier, and weight allowed"
        exit 198
    }
    marksample touse, novarlist
    if "`outlier'"!="" {
        mata: robmv_p_m_outlier()
        lab var `varlist' "Outlier"
        exit
    }
    if "`inlier'"!="" {
        mata: robmv_p_m_inlier()
        lab var `varlist' "Inlier"
        exit
    }
    if "`weights'"!="" {
        if inlist(`"`e(subcmd)'"',"s","mm","sd") {
            di as err "option {bf:weights} not allowed after {bf:robmv `e(subcmd)'}"
            exit 198
        }
        mata: robmv_p_m_weights()
        lab var `varlist' "Huber weights"
        exit
    }
    if "`stat'"=="" {
        di as txt "(option {cmd:distance} assumed)"
    }
    mata: robmv_p_m_distance()
    if `"`e(subcmd)'"'=="classic" lab var `varlist' "Distance"
    else                          lab var `varlist' "Robust distance"
end

program define robmv_p_mcd
    syntax newvarname(generate) [if] [in] [, Rd Distance Subset noREweight ///
        noscale * ]
    Parse_outlier_inlier, `options'
    local stat `rd' `distance' `outlier' `inlier' `subset'
    if `: list sizeof stat'>1 {
        di as err "only one of rd, distance, outlier, inlier, and subset allowed"
        exit 198
    }
    marksample touse, novarlist
    if e(nhyper)!=0 {
        di as txt "(exact fit situation; using distances from hyperplane)"
    }
    if "`outlier'"!="" {
        mata: robmv_p_mcd_outlier()
        lab var `varlist' "Outlier"
        exit
    }
    if "`inlier'"!="" {
        mata: robmv_p_mcd_inlier()
        lab var `varlist' "Inlier"
        exit
    }
    if "`subset'"!="" {
        qui replace `touse' = 0 if e(sample)!=1 // restrict to estimation sample
        mata: robmv_p_mcd_subset()
        lab var `varlist' "Best H-subset"
        exit
    }
    if "`stat'"=="" {
        di as txt "(option {cmd:distance} assumed)"
    }
    mata: robmv_p_mcd_distance()
    lab var `varlist' "Robust distance"
end

version 11
mata mata set matastrict on
mata:

/* ------------------------------------------------------------------------- */
/* robmv m                                                                   */
/* ------------------------------------------------------------------------- */

void robmv_p_m_outlier()
{
    real scalar     pr
    real rowvector  m
    real matrix     X, V
    pragma unset    X
    
    pr = 1 - strtoreal(st_local("outlier"))/100
    _robmv_p_st_view(X, st_global("e(varlist0)"), st_local("touse"))
    m = st_matrix("e(mu)")
    V = st_matrix("e(Cov)")
    st_store(., st_local("varlist"), st_local("touse"), 
        _robmv_p_maha(X, m, V) :>= invchi2(cols(V), pr))
}

void robmv_p_m_inlier()
{
    real scalar     pr
    real rowvector  m
    real matrix     X, V
    pragma unset    X
    
    pr = strtoreal(st_local("inlier"))/100
    _robmv_p_st_view(X, st_global("e(varlist0)"), st_local("touse"))
    m = st_matrix("e(mu)")
    V = st_matrix("e(Cov)")
    st_store(., st_local("varlist"), st_local("touse"), 
        _robmv_p_maha(X, m, V) :< invchi2(cols(V), pr))
}

void robmv_p_m_weights()
{
    real scalar     k
    real rowvector  m
    real matrix     X, V
    pragma unset    X
    
    _robmv_p_st_view(X, st_global("e(varlist0)"), st_local("touse"))
    k = st_numscalar("e(k)")
    if (length(k)==0) k = .
    if (k>=.) { // classical estimate
        st_store(., st_local("varlist"), st_local("touse"), J(rows(X), 1, 1))
        return
    }
    m = st_matrix("e(mu)")
    V = st_matrix("e(Cov)") / st_numscalar("e(c)")
    st_store(., st_local("varlist"), st_local("touse"),
        _robmv_p_m_weights(X, m, V, k))
    
}
real colvector _robmv_p_m_weights(real matrix X, real rowvector m,
    real matrix V, real scalar k)
{
    real colvector d
    
    if (k>=.) return(J(rows(X),1,1)) // classical estimate
    d = sqrt(_robmv_p_maha(X, m, V))
    return((k :/ d):^(1 :- (d:<=k)))
}

void robmv_p_m_distance()
{
    real rowvector  m
    real matrix     X, V
    pragma unset    X
    
    _robmv_p_st_view(X, st_global("e(varlist0)"), st_local("touse"))
    m = st_matrix("e(mu)")
    V = st_matrix("e(Cov)")
    st_store(., st_local("varlist"), st_local("touse"), 
        sqrt(_robmv_p_maha(X, m, V)))
}

/* ------------------------------------------------------------------------- */
/* robmv mcd/robmv mve                                                       */
/* ------------------------------------------------------------------------- */

void robmv_p_mcd_outlier()
{
    real scalar     pr, salpha
    real rowvector  m
    real matrix     X, V
    pragma unset    X
    
    pr = 1 - strtoreal(st_local("outlier"))/100
    _robmv_p_st_view(X, st_global("e(varlist0)"), st_local("touse"))
    if (st_numscalar("e(nhyper)")!=0) {
        m = st_matrix("e(mu0)")
        V = st_matrix("e(gamma)")
        st_store(., st_local("varlist"), st_local("touse"), 
            abs(_robmv_p_mcd_hdist(X, m, V)) :>= 1e-8)
        return
    }
    if (st_local("scale")!="") {
        m = st_matrix("e(mu0)")
        V = st_matrix("e(Cov0)")
    }
    else if (st_local("reweight")!="") {
        if (st_global("e(subcmd)")=="mcd") salpha = st_numscalar("e(salpha)")
        else                               salpha = 1
        m = st_matrix("e(mu0)")
        V = st_numscalar("e(calpha)") * salpha * st_matrix("e(Cov0)")
    }
    else {
        m = st_matrix("e(mu)")
        V = st_matrix("e(Cov)")
    }
    st_store(., st_local("varlist"), st_local("touse"), 
        _robmv_p_maha(X, m, V) :>= invchi2(cols(V), pr))
}

void robmv_p_mcd_inlier()
{
    real scalar     pr, salpha
    real rowvector  m
    real matrix     X, V
    pragma unset    X
    
    pr = strtoreal(st_local("inlier"))/100
    _robmv_p_st_view(X, st_global("e(varlist0)"), st_local("touse"))
    if (st_numscalar("e(nhyper)")!=0) {
        m = st_matrix("e(mu0)")
        V = st_matrix("e(gamma)")
        st_store(., st_local("varlist"), st_local("touse"), 
            abs(_robmv_p_mcd_hdist(X, m, V)) :< 1e-8)
        return
    }
    if (st_local("scale")!="") {
        m = st_matrix("e(mu0)")
        V = st_matrix("e(Cov0)")
    }
    else if (st_local("reweight")!="") {
        if (st_global("e(subcmd)")=="mcd") salpha = st_numscalar("e(salpha)")
        else                               salpha = 1
        m = st_matrix("e(mu0)")
        V = st_numscalar("e(calpha)") * salpha * st_matrix("e(Cov0)")
    }
    else {
        m = st_matrix("e(mu)")
        V = st_matrix("e(Cov)")
    }
    st_store(., st_local("varlist"), st_local("touse"), 
        _robmv_p_maha(X, m, V) :< invchi2(cols(V), pr))
}

void robmv_p_mcd_subset()
{
    real scalar     h
    real rowvector  m
    real matrix     X, V
    pragma unset    X
    
    X = _robmv_p_st_view(st_global("e(varlist0)"), st_local("touse"))
    _robmv_p_st_view(X, st_local("varlist"), st_local("touse"), J(rows(X), 1, 0))
    m = st_matrix("e(mu0)")
    if (st_numscalar("e(nhyper)")!=0) {
        h = st_numscalar("e(nhyper)")
        V = st_matrix("e(gamma)")
        st_store(order(abs(_robmv_p_mcd_hdist(X, m, V)), 1)[|1 \ h|], st_local("varlist"), 
            st_local("touse"), J(h, 1, 1))
        return
    }
    h = st_numscalar("e(h)")
    V = st_matrix("e(Cov0)")
    st_store(order(_robmv_p_maha(X, m, V), 1)[|1 \ h|], st_local("varlist"), 
        st_local("touse"), J(h, 1, 1))
}

void robmv_p_mcd_distance()
{
    real scalar     salpha
    real rowvector  m
    real matrix     X, V
    pragma unset    X
    
    _robmv_p_st_view(X, st_global("e(varlist0)"), st_local("touse"))
    if (st_numscalar("e(nhyper)")!=0) {
        m = st_matrix("e(mu0)")
        V = st_matrix("e(gamma)")
        st_store(., st_local("varlist"), st_local("touse"), 
            _robmv_p_mcd_hdist(X, m, V))
        return
    }
    if (st_local("scale")!="") {
        m = st_matrix("e(mu0)")
        V = st_matrix("e(Cov0)")
    }
    else if (st_local("reweight")!="") {
        if (st_global("e(subcmd)")=="mcd") salpha = st_numscalar("e(salpha)")
        else                               salpha = 1
        m = st_matrix("e(mu0)")
        V = st_numscalar("e(calpha)") * salpha * st_matrix("e(Cov0)")
    }
    else {
        m = st_matrix("e(mu)")
        V = st_matrix("e(Cov)")
    }
    st_store(., st_local("varlist"), st_local("touse"), 
        sqrt(_robmv_p_maha(X, m, V)))
}

// compute distance from hyperplane
real colvector _robmv_p_mcd_hdist(real matrix X, real rowvector m, real colvector gamma) 
{
    return((X:-m)*gamma)
}

/* ------------------------------------------------------------------------- */
/* common functions                                                          */
/* ------------------------------------------------------------------------- */

// get data view excluding omitted, base, and empty variables
// (the trick is to first read the complete data and then remove columns that
// are not needed; this is necessary because Mata will read the data
// differently if base levels are not included in the variable list; to be
// precise, Mata will automatically treat one of the provided levels as the
// base level and will set X to 0 for this variable; this is not what we want)
// Note: In Stata 16 we could -set fvbase off- before importing the data into
//       Mata and and directly read the data using the varlist from which
//       omitted terms have been removed
void _robmv_p_st_view(real matrix X, string scalar varlist, string scalar touse)
{
    string rowvector vlist
    real matrix      X0
    pragma unset     X0
    
    vlist = tokens(varlist)
    st_view(X0, ., vlist, touse)
    st_subview(X, X0, ., indx_non_omitted(vlist))
}
real rowvector indx_non_omitted(string rowvector varlist)
{   // based on suggestion by Jeff Pitblado
    real scalar   c, k
    string scalar tm

    c = cols(varlist)
    if (c==0) return(J(1, 0, .))
    tm = st_tempname()
    st_matrix(tm, J(1, c, 0))
    st_matrixcolstripe(tm, (J(c, 1, ""), varlist'))
    stata(sprintf("_ms_omit_info %s", tm))
    k = st_numscalar("r(k_omit)")
    if (k==0) return(1..c)
    if (k==c) return(J(1, 0, .))
    return(select(1..c, st_matrix("r(omit)"):==0))
}

// compute (squared) Mahalanobis distance
real colvector _robmv_p_maha(real matrix X, real rowvector m, real matrix V) 
{
    real matrix Xm
    
    Xm  = (X:-m)
    return(rowsum((Xm * invsym(V)) :* Xm))
}

end
exit


