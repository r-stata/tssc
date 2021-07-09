*! version 2.0.6  20may2008  Ben Jann
program _kdens, rclass sort
    version 9.2
    capt findfile lmoremata.mlib
    if _rc {
        di as error "-moremata- is required; type {stata ssc install moremata}"
        error 499
    }
    syntax varname(numeric) [if] [in] [fw aw pw] , ///
     Generate(namelist max=2) [                 ///
     Replace                                    ///
     N(numlist int max=1 >2)                    ///
     N2(numlist int max=1 >0)                   ///
     AT(varname numeric)                        ///
     RAnge(numlist min=2 max=2 ascending)       ///
     Kernel(name)                               ///
     exact                                      ///
     CI CI2(namelist max=2)                     ///
     vce(str)                                   ///
     VARiance(namelist max=1)                   ///
     USmooth USmooth2(numlist max=1 >=.2 <=1)   ///
     Level(cilevel)                             ///
     bw(str)                                    ///
     ADJust(real 1)                             ///
     Adaptive Adaptive2(int 0)                  ///
     LL(numlist max=1)                          ///
     UL(numlist max=1)                          ///
     REFLection                                 ///
     lc                                         ///
     noFIXED    /// undocumented: apply bandwidth selection within replicates;
                /// do not use -nofixed- with pweights
     ]

// Process options
// - n()
    if "`n'"=="" local n 512
    if "`n2'"=="" {
        local n2 `n'
        local no_n2 "1"
    }
    if (`n2'>`n') {
        di as err "n2() may not be larger than n()"
        exit 198
    }
// - generate()
    if "`at'"!="" & `:word count `generate''>1 {
        di as err "option generate():  too many names specified"
        exit 103
    }
    if "`at'"=="" & `:word count `generate''<2 {
        di as err "option generate():  too few names specified"
        exit 103
    }
    if "`replace'"=="" confirm new var `generate', exact
// - kernel()
    capt parse_kernel, `kernel'
    if _rc {
        di as err "option kernel(): `kernel' invalid"
        exit 198
    }
//bootstrap options
    if (`"`vce'"'!="") {
        if inlist(`"`weight'"',"fweight","aweight") {
            di as err `"`weight's not allowed with jackknife or bootstrap"'
            exit 198
        }
        parse_vce `vce'
    }
    else local vcetype standard
// - bandwidth (adaptive, width, bwtype, usmooth)
    if "`adaptive'"!="" local adaptive2 1
    if `"`bw'"'!="" {
        capt confirm number `bw'
        if _rc parse_bwtype , `bw'
        else {
            if `bw'<=0 {
                di as err `"option bw() incorrectly specified"'
                exit 198
            }
            local width `bw'
        }
    }
    if `adjust'<=0 {
        di as err `"option adjust() incorrectly specified"'
        exit 198
    }
    if "`usmooth'"!=""&`"`usmooth2'"'=="" local usmooth2 .25
// boundaries (ll, ul)
    if "`ll'"=="" local ll .
    if "`ul'"=="" local ul .
    if `ll'<. & `ll'>=`ul' {
        di as err "ll() must be smaller than ul()"
        exit 198
    }
    if "`reflection'"!="" & "`lc'"!="" {
        di as err `"'reflection' and 'lc' not allowed both"'
        exit 198
    }

// Prepare variables
// - touse
    marksample touse
    markout `touse' `strata' `cluster' `fpc' `subpop'
    qui count if `touse'
    if r(N)<2 {
        di as err "insufficient observations"
        exit 2000
    }
// - check ll, ul
    if (`ll'<.|`ul'<.) {
        su `varlist' if `touse', meanonly
        if (`ll'<. & `ll'>r(min)) {
            di as err "observed minimum smaller than ll(`ll')"
            exit 198
        }
        if (`ul'<. & `ul'<r(max)) {
            di as err "observed maximum larger than ul(`ul')"
            exit 198
        }
    }
// - check fpc
    if `"`fpc'"'!="" {
        capt assert `fpc'>=0 & `fpc'<=1 if `touse'
        if _rc {
            di as err "`fpc' not in [0,1]"
            exit 198
        }
    }
// - at2, touse_at (grid)
    if `"`at'"'=="" {
        tokenize `generate'
        local generate `1'
        local at `2'
        tempvar at2
        qui gen double `at2' = .
        format `at2' `:format `varlist''
    }
    else {
        local at2 `at'
        qui count if `at'<.
        if r(N)==0 {
            di as err "at(): no observations"
            exit 2000
        }
        tempvar touse_at
        qui gen byte `touse_at' = `at2'<.
    }
// - d (density estimate)
    tempvar d
    qui gen double `d' = .
// - ci2
    if "`ci'"!="" & "`ci2'"=="" local ci2 `generate'_lo `generate'_up
    if `:word count `ci2''==1 local ci2 `"`ci2'_lo `ci2'_up"'
    if "`ci2'"!="" {
        if "`replace'"=="" confirm new var `ci2', exact
        tempname ci_lo ci_up
        qui gen double `ci_lo' = .
        qui gen double `ci_up' = .
    }
    if "`variance'"!="" {
        if "`replace'"=="" confirm new var `variance', exact
        tempname var
        qui gen double `var' = .
    }
// strata/cluster
    local index `_sortindex'
    if `"`strata'`cluster'"'!="" {
        if `"`touse_at'"'=="" {
            tempvar idtag
            qui gen byte `idtag' = _n <= `n2'
        }
        sort `touse' `strata' `cluster'
        tempvar index
        qui gen long `index' = _n
    }

// Density estimation
    local dp = c(dp)
    set dp per
    mata: st_kdens()
    set dp `dp'

// Return results
    summ `d', meanonly
    local scale = 1/(r(N)*r(mean))
    if `ll'<.|`ul'<. {
        if "`reflection'`lc'"=="" ret local boundary renormalization
        else ret local boundary `reflection'`lc'
        if `ll'<. ret scalar ll = `ll'
        if `ul'<. ret scalar ul = `ul'
    }
    ret local bwtype "`bwtype'"
    ret local estimator = cond("`exact'"!="", "exact", "binned")
    ret local kernel "`kernel'"
    if "`dpilevel'"!="" {
        ret scalar dpilevel = `dpilevel'
    }
    ret scalar adaptive = `adaptive2'
    if "`usmooth2'"!="" {
        ret scalar usmooth = `usmooth2'
    }
    if "`width2'"!="" {
        ret scalar width2 = `width2'
    }
    if `width'!=real(`"`bw'"') {
        di as txt "(bandwidth = " as res `width' as txt ")"
    }
    ret scalar width = `width'
    if "`width2'"!="" {
        if `width'!=`width2' {
            di as txt "(undersmoothing bandwidth = " as res `width2' as txt ")"
        }
    }
    ret scalar n = `n'
    ret scalar scale = `scale'
    Vreturn `d' `generate' `replace'
    if "`ci2'"!="" {
        Vreturn `ci_lo' `:word 1 of `ci2'' `replace'
        Vreturn `ci_up' `:word 2 of `ci2'' `replace'
    }
    if "`variance'"!="" {
        Vreturn `var' `variance' `replace'
    }
    if "`at2'"!="`at'" {
        Vreturn `at2' `at' `replace'
    }
end

program parse_kernel
    syntax [, Biweight TRIWeight Cosine Epanechnikov ///
     Gaussian Parzen Rectangle Triangle epan2 user ]
    local kernel `biweight' `triweight' `cosine' `epanechnikov' ///
     `gaussian' `parzen' `rectangle' `triangle' `epan2' `user'
    if "`kernel'"=="" local kernel "epan2"
    c_local kernel `kernel'
end

program parse_vce
    syntax [name(id=vce)] [ , STRata(varname) CLuster(varname) ///
     mse noDots SUBpop(varname) fpc(varname) * ]
    local bsopts `options'
    c_local strata `strata'
    c_local cluster `cluster'
    c_local mse `mse'
    c_local nodots = ("`dots'"!="")
    c_local subpop `subpop'
    c_local fpc `fpc'
    local 0 , `namelist'
    syntax [ , BOOTstrap JACKknife ]
    local vcetype `bootstrap'`jackknife'
    if "`vcetype'"=="" local vcetype bootstrap
    if "`vcetype'"=="bootstrap" {
        if "`fpc'"!="" {
            di as err "fpc() not allowed with bootstrap"
            exit 198
        }
        if "`subpop'"!="" {
            di as err "subpop() not allowed with bootstrap"
            exit 198
        }
    }
    if "`vcetype'"=="jackknife" & `"`bsopts'"'!="" {
        di as err `"'`bsopts'' not allowed with jackknife"'
        exit 198
    }
    c_local vcetype `vcetype'
    if "`vcetype'"=="bootstrap" {
        local 0 , `bsopts'
        syntax [ , Reps(int 50) Normal Percentile bc bca t ]
        local citype `normal'`percentile'`bc'`bca'`t'
        if `"`citype'"'=="" local citype normal
        if `"`citype'"'=="normal"          c_local citype n
        else if `"`citype'"'=="percentile" c_local citype p
        else if `"`citype'"'=="bc"         c_local citype bc
        else if `"`citype'"'=="bca"        c_local citype bca
        else if `"`citype'"'=="t"          c_local citype t
        else if `"`citype'"'!="" {
            di as err "invalid specification of vce()"
            exit 198
        }
        if `reps' < 2 {
            di as err "reps() must be an integer greater than 1"
            exit 198
        }
        c_local reps `reps'
    }
end

program parse_bwtype
    syntax [ , Silverman Normalscale Oversmoothed SJpi Dpi ///
     Dpi2(numlist int max=1 >=0) ]
    if "`dpi2'"!="" local dpi dpi
    local bwtype `silverman' `normalscale' `oversmoothed' `sjpi' `dpi'
    if `:word count `bwtype'' > 1 {
        di as err `"only one bwtype may be specified"'
        exit 198
    }
    if "`bwtype'"=="" local bwtype silverman
    if "`bwtype'"=="dpi" & "`dpi2'"=="" local dpi2 2
    c_local bwtype `bwtype'
    c_local dpilevel `dpi2'
end

program Vreturn
    args oldname newname replace
    if "`replace'"!="" {
        capt confirm var `newname', exact
        if !_rc drop `newname'
    }
    rename `oldname' `newname'
end

version 9.2
mata:
mata set matastrict on

struct s_kdens {
    string scalar  kernel, bwtype, vce, citype
    real scalar    m, exact, h, h0, hf, adaptive, dpi, ll, ul, btype,
                   ci_yes, v_yes, us, n, pw, level, reps, mse, nodots
    real colvector x, x0, w, w0, stra, clus, subpop, fpc, minmax,
                   d, d_us, g, gc, v, l
    real matrix    ci
    pointer(real scalar) scalar hrep
}

void st_kdens() // grab stuff from Stata and write results back
{
    string scalar         touse, ci_lo, ci_up, var, weight
    real scalar           m2, m2o
    real colvector        at, id, cgrid, inrng
    struct s_kdens scalar D

// kernel and bandwidth
    D.m        = strtoreal(st_local("n"))
    D.kernel   = st_local("kernel")
    D.exact    = (st_local("exact")!="")
    D.h0       = strtoreal(st_local("width"))
    D.hf       = strtoreal(st_local("adjust"))
    D.h        = D.h0 * D.hf
    if (st_local("fixed")!="") D.hrep = &(D.h0 * D.hf)
    else                       D.hrep = &D.h
    D.bwtype   = st_local("bwtype")
    D.adaptive = strtoreal(st_local("adaptive2"))
    D.dpi      = strtoreal(st_local("dpilevel"))

// bounds
    D.ll       = strtoreal(st_local("ll"))
    D.ul       = strtoreal(st_local("ul"))
    D.btype    = (st_local("reflection")!="") + 2*(st_local("lc")!="")

// confidence intervals
    ci_lo      = st_local("ci_lo")
    ci_up      = st_local("ci_up")
    D.ci_yes   = (ci_lo!="")|(ci_up!="")
    var        = st_local("var")
    D.v_yes    = (var!="")
    D.level    = strtoreal(st_local("level"))
    D.us       = strtoreal(st_local("usmooth2"))
    D.vce      = st_local("vcetype")
    D.reps     = strtoreal(st_local("reps"))
    D.mse      = (st_local("mse")!="")
    D.citype   = st_local("citype")
    D.nodots   = strtoreal(st_local("nodots"))

// read data, normalize weights
    touse      = st_local("touse")
    D.x        = st_data(., st_local("varlist"), touse)
    weight     = st_local("weight")
    D.pw       = (weight=="pweight")
    D.n        = rows(D.x)
    if (weight!="") {
        D.w = st_data(., substr(st_local("exp"), 3), touse)
        if (weight=="fweight") D.n = colsum(D.w)
        else D.w = D.w * D.n / colsum(D.w)
    }
    else D.w = 1
    if (st_local("strata")!="")
      D.stra = st_data(., st_local("strata"), touse)
    if (st_local("cluster")!="")
      D.clus = st_data(., st_local("cluster"), touse)
    if (st_local("fpc")!="")
      D.fpc = st_data(., st_local("fpc"), touse)
    if (st_local("subpop")!="") {
        D.subpop = st_data(., st_local("subpop"), touse)
        swap(D.x0, D.x)
        D.x = select(D.x0, D.subpop)
        if (rows(D.w)!=1) {
            swap(D.w0, D.w)
            D.w = select(D.w0, D.subpop)
        }
    }
    cgrid = 0
    if (st_local("touse_at")!="") {
        at = st_data(., st_local("at2"), st_local("touse_at"))
        D.minmax = colminmax(at)
        if (D.exact & rows(at)>0) {
            if (D.adaptive) {
                printf("{txt}(adaptive estimator: interpolating density " +
                 "from {res}%g{txt} regular grid points)", D.m)
            }
            else {
                D.g = at
                D.m = rows(D.g)
                st_local("n",strofreal(D.m))
                cgrid = 1
            }
        }
    }
    else if (st_local("range")!="") {
        D.minmax = strtoreal(tokens(st_local("range")))
        if (D.exact & D.adaptive==0) {
            D.g = rangen( D.minmax[1], D.minmax[2], D.m)
            cgrid = 1
        }
    }

// compute density estimate
    _kdens_compute(D)
    if (cgrid) {
        if ( (D.ll<. & D.minmax[1]<D.ll) | D.minmax[2]>D.ul ) {
            inrng = 1 :- ( (D.ll<. :& D.g:<D.ll) :| D.g:>D.ul )
            _editvalue(inrng,0,.)
            D.d = D.d:*inrng
            if (rows(D.v)>0) D.v = D.v:*inrng
            if (rows(D.ci)>0) D.ci = D.ci:*inrng
        }
    }

// return results to Stata
    if (rows(at)>0)
     id = st_data( ., st_local("index"), st_local("touse_at"))
    else {
        m2 = m2o = strtoreal(st_local("n2"))
        if (cgrid==0 & length(D.minmax)>0 & st_local("no_n2")!="") {
            m2 = ceil(m2 * (D.minmax[2]-D.minmax[1])/(D.g[rows(D.g)]-D.g[1]))
            m2 = min((max((m2,2)),D.m))
        }
        if (st_nobs()<m2)   m2 = st_nobs()
        if (m2!=m2o)        printf("{txt}(n2() set to %g)\n", m2)
        if (st_local("idtag")!="")
         id = sort(st_data(.,(st_local("_sortindex"),
              st_local("index")), st_local("idtag")), 1)[|1,2 \ m2,2|]
        else id = (1, m2)
        if (m2!=D.m | (length(D.minmax)>0 & cgrid==0) ) {
            at = rangen( length(D.minmax)>0 ? D.minmax[1] : D.g[1],
                         length(D.minmax)>0 ? D.minmax[2] : D.g[rows(D.g)], m2)
            st_store(id, st_local("at2"), at)
        }
        else st_store(id, st_local("at2"), D.g)
    }
    st_local("width", strofreal(D.h, "%18.0g"))
    if (D.ci_yes|D.v_yes) st_local("width2", strofreal(D.h*D.us, "%18.0g"))
    if (rows(at)==0 | (cgrid & rows(at)==rows(D.g))) {
                       st_store(id, st_local("d"), D.d)
        if (var!="")   st_store(id, var, D.v)
        if (ci_lo!="") st_store(id, ci_lo, D.ci[,1])
        if (ci_up!="") st_store(id, ci_up, D.ci[,2])
        return
    }
                   st_store(id, st_local("d"), mm_ipolate(D.g, D.d, at))
    if (var!="")   st_store(id, var, mm_ipolate(D.g, sqrt(D.v), at):^2)
    if (ci_lo!="") st_store(id, ci_lo, mm_ipolate(D.g, D.ci[,1], at))
    if (ci_up!="") st_store(id, ci_up, mm_ipolate(D.g, D.ci[,2], at))
}

void _kdens_compute(struct s_kdens scalar D)
{
// compute initial bandwidth estimate
    if (D.h>=.) {
        D.h = D.hf * kdens_bw(D.x, D.w, D.bwtype, D.kernel,
              D.m, D.ll, D.ul, D.dpi)
        if (D.pw & rows(D.w)!=1) {
            D.h = D.h * (colsum(D.w:^2)/D.n)^.2
        }
        if (D.h>=.) {
            display("{err}automatic bandwidth selection failed")
            display("try increasing the number of estimation points")
            exit(499)
        }
    }
// set up evaluation grid
    if (rows(D.g)<1) {
        D.g = kdens_grid(D.x, D.w, D.h, D.kernel, D.m,
            (D.ll<. ? D.ll : (length(D.minmax)>=1 ? D.minmax[1] : .)),
            (D.ul<. ? D.ul : (length(D.minmax)>=2 ? D.minmax[2] : .)))
    }
// compute density estimate
    if (D.exact)
        D.d = _kdens(D.x, D.w, D.g, D.h, D.kernel, D.adaptive,
            D.ll, D.ul, D.btype, D.l)
    else
        D.d = kdens(D.x, D.w, D.g, D.h, D.kernel, D.adaptive,
            D.ll<., D.ul<., D.btype, D.l, D.gc, 1)
    if (D.v_yes==0 & D.ci_yes==0) return
// compute undersmoothed estimate
    if (D.us<.) {
        D.us = D.n^.2 / D.n^D.us
        if (D.exact)
            D.d_us = _kdens(D.x, D.w, D.g, D.h*D.us, D.kernel, D.adaptive,
                D.ll, D.ul, D.btype, D.l)
        else
            D.d_us = kdens(D.x, D.w, D.g, D.h*D.us, D.kernel, D.adaptive,
                D.ll<., D.ul<., D.btype, D.l, D.gc, 1)
    }
    else D.us = 1
// compute variance estimate
    if ((D.vce=="standard" & (D.v_yes | D.ci_yes)) |
     (D.vce=="bootstrap" & D.citype=="t")) {
        if (D.exact)
            D.v = _kdens_var((D.us==1 ? D.d : D.d_us), D.x, D.w, D.g, D.h,
                D.kernel, D.pw, D.ll, D.ul, D.btype, D.l)
        else
            D.v = kdens_var((D.us==1 ? D.d : D.d_us), D.x, D.w, D.g, D.h,
                D.kernel, D.pw, D.ll<., D.ul<., D.btype, D.l, D.gc)
    }
// compute ci
    if (D.ci_yes) {
        if (D.vce=="standard") _kdens_ci_std(D)
        else if (D.vce=="jackknife") _kdens_ci_jk(D)
        else if (D.vce=="bootstrap") _kdens_ci_bs(D)
    }
}

void _kdens_ci_std(struct s_kdens scalar D)
{
    real scalar z
    real colvector se

    z     = invnormal((100-D.level)/200) // negative
    se    = sqrt(D.v)
    D.ci  = (D.us==1 ? D.d : D.d_us) + z * se,
            (D.us==1 ? D.d : D.d_us) - z * se
}

void _kdens_ci_jk(struct s_kdens scalar D)
{
    transmorphic   jk
    pointer scalar d

    d = (D.us==1 ? &D.d : &D.d_us)
    jk = mm_jk(&_kdens_repl(),
         (rows(D.x0)>0 ? D.x0 : D.x), (rows(D.w0)>0 ? D.w0 : D.w),
         D.nodots, D.stra, D.clus, D.subpop, D.fpc, *d', D, 0)
    if (D.ci_yes) D.ci = mm_jk_report(jk,"ci", D.level, D.mse)'
    if (D.v_yes)  D.v = (mm_jk_report(jk,"v", ., D.mse):^2)'
}

void _kdens_ci_bs(struct s_kdens scalar D)
{
    transmorphic   bs, jk
    pointer scalar d, v

    d = (D.us==1 ? &D.d : &D.d_us)
    v = (D.citype=="t" ? &sqrt(D.v) : &J(D.m, 0, .))
    bs = mm_bs(&_kdens_repl(), D.x, D.w, D.reps, 0, D.nodots,
         D.stra, D.clus, (*d, *v)', D, (D.citype=="t"))
    if (D.citype=="bca")
     jk = mm_jk(&_kdens_repl(), D.x, D.w, D.nodots,
          D.stra, D.clus, ., ., *d', D, 0)
    if (D.ci_yes) D.ci = mm_bs_report(bs, D.citype, D.level, D.mse, jk)'
    if (D.v_yes)  D.v = (mm_bs_report(bs,"v", ., D.mse):^2)'
}

real matrix _kdens_repl(
 real colvector x,
 real colvector w,
 struct s_kdens scalar D,
 real scalar se)
{
    real scalar h
    real colvector d, gc, l

    h = *D.hrep
    if (h>=.) h = D.hf * kdens_bw(x, w, D.bwtype, D.kernel,
                  D.m, D.ll, D.ul, D.dpi)
    if (h>=.) return(res)
    h = h * D.us
    if (D.exact)
        d = _kdens(x, w, D.g, h, D.kernel, D.adaptive,
            D.ll, D.ul, D.btype, l)
    else
        d = kdens(x, w, D.g, h, D.kernel, D.adaptive,
            D.ll<., D.ul<., D.btype, l, gc, 1)
    if (se==0) return(d')
    if (D.exact)
        return(d' \ sqrt(_kdens_var(d, x, w, D.g, h, D.kernel,
            D.pw, D.ll, D.ul, D.btype, l))')
    else
        return(d' \ sqrt(kdens_var(d, x, w, D.g, h, D.kernel,
            D.pw, D.ll<., D.ul<., D.btype, l, gc))')
}

end
