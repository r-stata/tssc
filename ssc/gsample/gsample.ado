*! version 1.0.6  13aug2014  Ben Jann

program gsample
    version 9.2
    capt mata mata which mm_sample()
    if _rc {
        di as error "mm_sample() from -moremata- is required; type {stata ssc install moremata}"
        error 499
    }
    qui syntax [anything(name=n)] [if] [in] [iw aw] [, ///
      Generate(name)   /// store sample counts in newvar
      Percent          /// information in n is percentage
      wor              /// sample without replacement
      Strata(varlist)  /// stratified sampling
      Cluster(varlist) /// clutser sampling
      IDcluster(name)  /// add new id for resample clusters
      Keep             /// keep cases outside touse
      Replace          /// replace existing variables
      ]
    if `"`idcluster'"'!="" & `"`cluster'"'=="" {
        di as err "idcluster() can only be specified with the cluster() option"
        exit 198
    }
    if "`replace'"=="" {
        if `"`generate'"'!="" confirm new var `generate', exact
        if `"`idcluster'"'!="" confirm new var `idcluster', exact
    }
    if `"`n'"'=="" local n .
    if `"`n'"'!="." {
        capt confirm number `n'
        if _rc unab nvar: `n', max(1)
    }
    marksample touse, zeroweight
    markout `touse' `strata' `cluster', strok
    qui count if `touse'
    local N = r(N)
    local Nout = _N - `N'
    if `N'==0 error 2000
    capt assert `n'>=0 if `touse'
    if _rc {
        di as err "n must be 0 or larger"
        exit 198
    }
    if `"`exp'"'!="" {
        tempvar wgt
        qui generate double `wgt' `exp' if `touse'
        capt assert (`wgt'>=0) if `touse'
        if _rc error 402
        capt assert (`wgt'==0) if `touse'
        if _rc==0 {
            di as err "weights all zero"
            exit 499
        }
    }
    else local wgt
    if `"`strata'`cluster'"'=="" & `"`generate'"'=="" {
        _gsample1 `n' `"`nvar'"' `N' `Nout' `touse' `"`wgt'"' ///
         `"`generate'"' `"`wor'"' `"`percent'"' `"`keep'"' `"`replace'"'
        exit
    }
    if `"`strata'`cluster'"'=="" {
        _gsample1g `n' `"`nvar'"' `N' `Nout' `touse' `"`wgt'"' ///
         `"`generate'"' `"`wor'"' `"`percent'"' `"`keep'"' `"`replace'"'
        exit
    }
    if `"`generate'"'=="" {
        _gsample2 `n' `"`nvar'"' `N' `Nout' `touse' `"`wgt'"' ///
         `"`generate'"' `"`wor'"' `"`percent'"' `"`keep'"' `"`replace'"' ///
         `"`strata'"' `"`cluster'"' `"`idcluster'"'
        exit
    }
    _gsample2g `n' `"`nvar'"' `N' `Nout' `touse' `"`wgt'"' ///
     `"`generate'"' `"`wor'"' `"`percent'"' `"`keep'"' `"`replace'"' ///
     `"`strata'"' `"`cluster'"' `"`idcluster'"'
end

program _gsample1 // no strata, no clusters, return sample
    args n nvar N Nout touse wgt generate wor percent keep replace
    if `"`nvar'"'!="" {
        su `nvar' if `touse', mean
        local n = r(mean)
    }
    tempvar sortindex index
    nobreak {
        if `Nout' {
            gen long `sortindex' = _n
            sort `touse' `sortindex'
            gen long `index' = _n * (!`touse' & `"`keep'"'!="")
        }
        else gen long `index' = 0
        capt n mata: _gsample1()
        if _rc {
            if `Nout' sort `sortindex'
            exit _rc
        }
        keep if `index'
        sort `index'
    }
end

program _gsample1g // no strata, no clusters, return count variable
    args n nvar N Nout touse wgt generate wor percent keep replace
    if `"`nvar'"'!="" {
        su `nvar' if `touse', mean
        local n = r(mean)
    }
    tempvar index
    qui gen long `index' = (!`touse') * (`"`keep'"'!="")
    mata: _gsample1g()
    Vdrop `generate' `replace'
    rename `index' `generate'
//  if `"`keep'"'=="" & `Nout' keep if `touse'
end

program _gsample2 // stratified/custered, return sample
    args n nvar N Nout touse wgt generate wor percent keep replace ///
     strata cluster idcluster
    tempvar sortindex index
    gen long `sortindex' = _n
    nobreak {
        sort `touse' `strata' `cluster' `sortindex'
        if `"`strata'"'!="" {
            capt confirm str var `strata'
            if `: list sizeof strata'==1 & _rc local sid "`strata'"
            else {
                tempvar sid
                by `touse' `strata': gen byte `sid' = (_n == 1)
                qui replace `sid' = sum(`sid')
            }
        }
        if `"`cluster'"'!="" {
            capt confirm str var `cluster'
            if `: list sizeof cluster'==1 & _rc & `"`idcluster'"'=="" ///
                local cid "`cluster'"
            else {
                tempvar cid
                by `touse' `strata' `cluster': gen byte `cid' = (_n == 1)
                qui replace `cid' = sum(`cid')
            }
        }
        else local idcluster
        gen long `index' = 0
        if `Nout' & `"`keep'"'!="" qui replace `index' = _n if !`touse'
        capt n mata: _gsample2()
        if _rc {
            sort `sortindex'
            exit _rc
        }
        keep if `index'
        if `"`idcluster'"'!="" {
            Vdrop `idcluster' `replace'
            bys `touse' `strata' `cluster' `sortindex' (`index'): ///
             gen long `idcluster' = _n
            qui bys `touse' `strata' `cluster' `idcluster' (`sortindex'): ///
             replace `idcluster' = (_n==1)
            sort `index'
            qui replace `idcluster' = sum(`idcluster')
        }
        else sort `index'
    }
end

program _gsample2g, sort // stratified/custered, return count variable
    args n nvar N Nout touse wgt generate wor percent keep replace ///
     strata cluster idcluster
    sort `touse' `strata' `cluster' `_sortindex' // => stable sort order
    if `"`strata'"'!="" {
        capt confirm str var `strata'
        if `: list sizeof strata'==1 & _rc local sid "`strata'"
        else {
            tempvar sid
            by `touse' `strata': gen byte `sid' = (_n == 1)
            qui replace `sid' = sum(`sid')
        }
    }
    if `"`cluster'"'!="" {
        capt confirm str var `cluster'
        if `: list sizeof cluster'==1 & _rc & `"`idcluster'"'=="" ///
         local cid "`cluster'"
        else {
            tempvar cid
            by `touse' `strata' `cluster': gen byte `cid' = (_n == 1)
            qui replace `cid' = sum(`cid')
        }
    }
    else local idcluster
    tempvar index
    qui gen long `index' = (!`touse') * (`"`keep'"'!="")
    mata: _gsample2g()
//  if `"`keep'"'=="" qui keep if `touse'
    Vdrop `generate' `replace'
    rename `index' `generate'
    if `"`idcluster'"'!="" {
        Vdrop `idcluster' `replace'
        by `touse' `strata' `cluster': gen byte `idcluster' = (_n == 1)
        qui replace `idcluster' = sum(`idcluster')
    }
end

program Vdrop
    args name replace
    if "`replace'"!="" {
        capt confirm var `name', exact
        if !_rc drop `name'
    }
end

version 9.1
mata:
void _gsample1()
{
    breakval = setbreakintr(1)
// variables
    touse = st_varindex(st_local("touse"))
    index = st_varindex(st_local("index"))
    w     = _st_varindex(st_local("wgt"))
    wor   = st_local("wor")!=""
    pct   = st_local("percent")!=""
    Nout  = strtoreal(st_local("Nout"))
// sample size / weights / population size
    n = strtoreal(st_local("n"))
    N = strtoreal(st_local("N"))
    if (w<.) st_view(w, ., w, touse)
    if (pct) n = round(N/100 :* n)
// draw sample
    s = Nout :+ mm_sample(n, N, ., w, wor, 0, 1)
    (void) setbreakintr(breakval)
    if (wor==0) _gsample_expand(s, index)
    if (rows(s)>0) st_store(s, index, touse, (Nout+1::Nout+rows(s)))
}

void _gsample1g()
{
// variables
    touse = st_varindex(st_local("touse"))
    index = st_varindex(st_local("index"))
    w     = _st_varindex(st_local("wgt"))
    wor   = st_local("wor")!=""
    pct   = st_local("percent")!=""
// sample size / weights / population size
    n = strtoreal(st_local("n"))
    N = strtoreal(st_local("N"))
    if (w<.) st_view(w, ., w, touse)
    if (pct) n = round(N/100 :* n)
// draw sample
    st_store(., index, touse, mm_sample(n, N, ., w, wor, 1, 1))
}

void _gsample2()
{
    real colvector strata, cluster
    breakval = setbreakintr(1)
// variables
    touse = st_varindex(st_local("touse"))
    index = st_varindex(st_local("index"))
    sid   = _st_varindex(st_local("sid"))
    cid   = _st_varindex(st_local("cid"))
    w     = _st_varindex(st_local("wgt"))
    nvar  = _st_varindex(st_local("nvar"))
    wor   = st_local("wor")!=""
    pct   = st_local("percent")!=""
    Nout  = strtoreal(st_local("Nout"))
    N     = strtoreal(st_local("N"))
// strata/clusters
    if (sid<.) st_view(strata, ., sid, touse)
    if (cid<.) st_view(cluster, ., cid, touse)
    mm_panels(strata, S=J(1,2,N), cluster, C=.)
// weights
    n = strtoreal(st_local("n"))
    if (w<.) {
        if (cid<.) st_view(w, Nout :+ mm_colrunsum(C[.,1]), w, touse)
        else st_view(w, ., w, touse)
    }
// sample size
    if (nvar<.) {
        if (sid<.) n = st_data(Nout :+ mm_colrunsum(S[.,1]), nvar)
        else n = _st_data(Nout+1, nvar)
    }
    else n = strtoreal(st_local("n"))
    if (pct) n = round(S[.,2]/100 :* n)
// draw sample
    s = Nout :+ mm_sample(n, S, C, w, wor, 0, 1)
    (void) setbreakintr(breakval)
    if (wor==0) _gsample_expand(s, index)
    if (rows(s)>0) st_store(s, index, touse, (Nout+1::Nout+rows(s)))
}

void _gsample2g()
{
    real colvector strata, cluster
// variables
    touse = st_varindex(st_local("touse"))
    index = st_varindex(st_local("index"))
    sid   = _st_varindex(st_local("sid"))
    cid   = _st_varindex(st_local("cid"))
    w     = _st_varindex(st_local("wgt"))
    nvar  = _st_varindex(st_local("nvar"))
    wor   = st_local("wor")!=""
    pct   = st_local("percent")!=""
    Nout  = strtoreal(st_local("Nout"))
    N     = strtoreal(st_local("N"))
// strata/clusters
    if (sid<.) st_view(strata, ., sid, touse)
    if (cid<.) st_view(cluster, ., cid, touse)
    mm_panels(strata, S=J(1,2,N), cluster, C=.)
// weights
    n = strtoreal(st_local("n"))
    if (w<.) {
        if (cid<.) st_view(w, Nout :+ mm_colrunsum(C[.,1]), w, touse)
        else st_view(w, ., w, touse)
    }
// sample size
    if (nvar<.) {
        if (sid<.) n = st_data(Nout :+ mm_colrunsum(S[.,1]), nvar)
        else n = _st_data(Nout+1, nvar)
    }
    else n = strtoreal(st_local("n"))
    if (pct) n = round(S[.,2]/100 :* n)
// draw sample
    st_store(., index, touse, mm_sample(n, S, C, w, wor, 1, 1))
}

void _gsample_expand(real colvector s, real scalar index)
{
    p = order(s,1)
    lastpos = 0
    j = st_nobs()
    for (i=1; i<=rows(p);i++) {
        pos = s[p[i]]
        if (pos == lastpos) {
            s[p[i]] = ++j // positions of duplicates after -expand-
            _st_store(pos, index, _st_data(pos, index) + 1)
        }
        else _st_store(pos, index, 1)
        lastpos = pos
    }
    stata("expand `" + "index" + "' if `" +
     "touse" + "' & `" + "index" + "'")
}
end
