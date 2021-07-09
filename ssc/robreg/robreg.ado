*! version 1.1.1  27jan2010  Ben Jann

// main.ado

program robreg
    version 10.1
    if replay() { // redisplay output
        Display `0'
        exit
    }
    capt findfile lmoremata.mlib
    if _rc {
        di as error "-moremata- is required; type {stata ssc install moremata}"
        error 499
    }
    local ecmd "lms lts lqs s m mm"
    local rcmd "mad"
    local cmd0 "`ecmd' `rcmd'"
    gettoken cmd 0 : 0
    if `:list cmd in cmd0'==0 {
        di as err `"invalid subcommand"'
        exit 198
    }
    syntax anything(id=varlist) [if] [in] [, Level(passthru) * ]
    robreg_`cmd' `anything' `if' `in' [`weight'`exp'], `options'
    if `:list cmd in ecmd' {
        Cmdline robreg `cmd'`0'
        Display, `level'
    }
end

program Cmdline, eclass
    eret local cmdline `"`0'"'
end

program Display
    syntax [, Level(cilevel) ]
    if `"`e(cmd)'"'!="robreg" {
        di as err "last robreg estimates not found"
        exit 111
    }
    if `"`e(prefix)'"'=="" {
        local col 51
        local space ""
        local fmt "%10.0g"
    }
    else {
        local col 49
        local space "   "
        local fmt "%9.0g"
    }
    *if inlist(`"`e(subcmd)'"',"lms","lqs","lts","s","m","mm")  {
        local nomodeltest nomodeltest
    *}
    _coef_table_header, `nomodeltest'
    if inlist(`"`e(subcmd)'"',"lms","lqs","lts") {
        if `"`e(subcmd)'"'!="lms" ///
        di as txt _col(`col') "Breakdown point `space'= " as res `fmt' e(bp)
        di as txt _col(`col') "Subsamples      `space'= " as res `fmt' e(nsamp)
        di as txt _col(`col') "Scale estimate  `space'= " as res `fmt' e(scale)
    }
    else if "`e(subcmd)'"'=="s" {
        di as txt _col(`col') "Subsamples      `space'= " as res `fmt' e(nsamp)
        di as txt _col(`col') "Breakdown point `space'= " as res `fmt' e(bp)
        di as txt _col(`col') "Bisquare k      `space'= " as res `fmt' e(k)
        di as txt _col(`col') "Scale estimate  `space'= " as res `fmt' e(scale)
    }
    else if "`e(subcmd)'"'=="rls" {
        di as txt _col(`col') "Scale estimate  `space'= " as res `fmt' e(scale)
    }
    else if "`e(subcmd)'"'=="m" {
        local obf = proper(`"`e(obf)'"')
        di as txt _col(`col') %-15s `"`obf' k"' " `space'= " as res `fmt' e(k)
        di as txt _col(`col') "Scale estimate  `space'= " as res `fmt' e(scale)
        di as txt _col(`col') "Robust R2 (w)   `space'= " as res `fmt' e(r2_w)
        di as txt _col(`col') "Robust R2 (rho) `space'= " as res `fmt' e(r2_rho)
    }
    else if "`e(subcmd)'"'=="mm" {
        di as txt _col(`col') "Subsamples      `space'= " as res `fmt' e(nsamp)
        di as txt _col(`col') "Breakdown point `space'= " as res `fmt' e(bp)
        di as txt _col(`col') "M-estimate: k   `space'= " as res `fmt' e(k)
        di as txt _col(`col') "S-estimate: k   `space'= " as res `fmt' e(k_init)
        di as txt _col(`col') "Scale estimate  `space'= " as res `fmt' e(scale)
        di as txt _col(`col') "Robust R2 (w)   `space'= " as res `fmt' e(r2_w)
        di as txt _col(`col') "Robust R2 (rho) `space'= " as res `fmt' e(r2_rho)
    }
    di ""
    eret di, level(`level')
end

// m.ado

program robreg_m, sortpreserve eclass   // loosely based on official Stata's rreg.ado
    version 10.1

    // syntax / options
    syntax varlist [if] [in] [aw fw pw iw] [,   /// //! (weights not implemented yet)
        Huber                                   ///
        BIweight BISquare                       /// (synonyms)
        init(str)                               /// initial estimates
        save(name)                              /// store initial estimates
        first                                   /// display initial estimate
        Scale0(real 0)                          /// provide scale (and keep fixed)
        CENter                                  /// center residuals when computig MAD
        UPDATEscale                             /// update MAD in each iteration
        EFFiciency(int 0)                       ///
        K(real 0)                               ///
        TOLerance(real 1e-6)                    ///
        relax                                   /// no error if convergence not reached
        ITERate(integer `c(maxiter)')           ///
        Generate(str)                           /// save weights
        REplace                                 ///
        LOg                                     ///
        Level(passthru)                         ///
        noRobust                                ///
        vce(str)                                ///
        nose                                    ///
        ]
    if "`first'"!="" local noisily noisily
    if `"`vce'"'!="" & "`robust'"!="" {
        di as err "vce() and norobust not both allowed"
        exit 198
    }
    if `"`vce'"'!="" {
        Parse_vce `vce'
    }
    else if "`robust'"=="" local vce robust
    if "`generate'"!="" {
        if "`replace'"=="" confirm new var `generate'
    }
    if `tolerance'<=0 {
            di as err  "tolerance() must be positive"
            exit 198
    }
    if `iterate'<=0 {
            di as err  "iterate() must be positive"
            exit 198
    }
    if `scale0'< 0 {
            di in red "scale() must be positive"
            exit 198
    }
    local obf `huber' `bisquare' `biweight'
    if `: list sizeof obf'>1 {
        di as err "`obf': only one allowed"
        exit 198
    }
    if "`obf'"=="biweight"  local obf bisquare
    if "`obf'"==""          local obf huber
    local efflist  70 75 80 85 90 95
    if `efficiency'!=0 {
        if `k'!=0 {
            di as err "only one of k() and efficiency() allowed"
            exit 198
        }
        if `:list posof "`efficiency'" in efflist'==0 {
            di as err "efficiency() must be one of: `efflist'"
            exit 198
        }
    }
    else local efficiency 95  // default
    local hasuserk = (`k'!=0)
    if `hasuserk'==0 {
        if "`obf'"=="huber" {
            local k: word `:list posof "`efficiency'" in efflist' of ///
                0.1916816 0.3528958 0.5294336 0.7317357 0.9818025 1.3449986
        }
        else /*if "`obf'"=="bisquare"*/ {
            local k: word `:list posof "`efficiency'" in efflist' of ///
                2.697221 2.897188 3.136898 3.443686 3.882678 4.685045
        }
    }
    else {
        if `k'<=0 {
            di as err  "k() must be positive"
            exit 198
        }
    }

    // mark sample / variables
    marksample touse
    qui count if `touse'
    local N = r(N)
    if `N'==0 error 2000
    gettoken depname rhs : varlist

    // initial estimate
    tempvar res
    if inlist(`"`init'"',"", "lav", "ols") {
        if `"`init'"'=="ols" {
            if "`noisily'"=="" di as txt "fitting initial OLS estimate ..." _c
            else di as txt _n "Initial OLS estimate:"
            qui `noisily' regress `depname' `rhs' [`weight'`exp'] if `touse'
        }
        else {
            local init "lav"
            if "`noisily'"=="" di as txt "fitting initial LAV estimate ..." _c
            else di as txt _n "Initial LAV estimate:"
            qui `noisily' qreg `depname' `rhs' [`weight'`exp'] if `touse'
        }
        if "`noisily'"=="" di as txt " done"
        else di as txt ""
        if "`save'"!="" {
            est sto `save'
            di as txt "(initial estimate saved as {stata est replay `save':`save'})"
        }
    }
    else {
        if `"`init'"'!="." {
            qui est restore `init'
        }
        if "`noisily'"!="" {
            di as txt _n "Initial estimate: " as res `"`init'"'
            `e(cmd)'
            di ""
        }
    }
    qui _predict double `res' if `touse', xb
    qui replace `res' = `depname' - `res'

    // compute M-estimate
    tempvar w
    _robreg_m_irwls `depname' `rhs' [`weight'`exp'] , w(`w') ///
        touse(`touse') res(`res') obf(`obf') k(`k') tolerance(`tolerance') ///
        iterate(`iterate') scale0(`scale0') `center' `updatescale' `log'
    local p = e(df_m) + 1
    local scale = e(scale)
    local it = e(it)
    local converged = e(converged)
    if `converged'==0 & "`relax'"=="" {
        di as err "convergence not achieved within `iterate' iterations"
        exit 430
    }

    // R-squared
    local r2_w = e(r2) // (cf. Heritier et al. 2009, p. 68)
    _robreg_m_r2_rho `varlist' [`weight'`exp'], scale(`scale') ///
        touse(`touse') res(`res') obf(`obf') k(`k') tolerance(`tolerance') ///
        iterate(`iterate') init(`init') `center' `updatescale'

    // Standard Errors
    if "`se'"!="" {
        tempname V
        mat `V' = e(b)
        mat `V' = `V'' * `V' * 0
    }
    else if "`vce'"=="pv" {  // pseudovalues approach (Street et al. 1988)
        tempvar phi y
        gen_`obf'_phi `phi' `res' `scale' `k' `touse'
        sum `phi' if `touse', meanonly
        local aa = r(mean)
        local lambda = 1 + (`p'/e(N)) * (1-`aa')/`aa'
        qui _predict double `y' if `touse'
        qui replace `y'= `y' + ///
            (`lambda'*`scale' / `aa') * (`res' / `scale') * `w' ///
            if `touse'
        qui reg `y' `rhs' if `touse', dep(`depname')
        tempname V
        matrix `V' = e(V)
    }
    else {
        tempname V
        if "`vce'"=="" { // (Avar_2s from Croux et al. 2003)
            mata: st_matrix("`V'", ///
                _robreg_m_Avar_2s(`scale', `k', `N', `p', &_robreg_`obf'()))
        }
        else /*if "`vce'"=="robust"*/ { // (Avar_1s from Croux et al. 2003)
            local vcetype "Robust"
            mata: st_matrix("`V'", ///
                _robreg_m_Avar_1s(`scale', `k', `N', `p', &_robreg_`obf'()))
        }
        local coln: coln e(b)
        mat coln `V' = `coln'
        mat rown `V' = `coln'
    }

    // returns
    if "`generate'"!="" {
        Vreturn `w' `generate' `replace'
        label var `generate' "M-Regression Weights"
    }
    tempname B
    mat `B' = e(b)
    eret post `B' `V', esample(`touse') depname(`depname') obs(`N')
    eret scalar df_m        = `p' - 1
    eret scalar r2_rho      = `r2_rho'
    eret scalar r2_w        = `r2_w'
    eret scalar iterations  = `it'
    eret scalar converged   = `converged'
    eret local vce          "`vce'"
    eret local vcetype      "`vcetype'"
    eret local depvar       "`depname'"
    eret local weights      "`generate'"
    if `scale0'==0 {
        eret local updatescale  "`updatescale'"
        eret local center       "`center'"
    }
    eret local init         "`init'"
    eret local obf          "`obf'"
    if `hasuserk'==0    eret local title "M-Regression (`efficiency'% efficiency)"
    else                eret local title "M-Regression"
    eret local subcmd       "m"
    eret local cmd          "robreg"
    global S_E_cmd          "robreg"       /* double save */   //! delete?
    eret scalar scale       = `scale'
    eret scalar k           = `k'
    if `hasuserk'==0    eret scalar efficiency = `efficiency'
end

program _robreg_m_irwls, eclass
    syntax varlist [aw fw pw iw] ,  /// //! (weights not implemented yet)
        touse(str) res(str) obf(str) k(str) tolerance(str) iterate(str) ///
        [ w(str) scale0(real 0) center updatescale log ]
    if "`log'"=="" local log "*"
    else           local log ""
    `log'          local dots "*"
    if `scale0'!=0 local scale `scale0'
    local center = cond("`center'"!="", "center", "nocenter")

    `dots' di as txt "iterating RWLS estimate " _c
    if `"`w'"'=="" tempvar w
    tempvar maxd y oldw
    qui gen double `maxd' = 1 if `touse'
    qui gen double `w'    = 1 if `touse'
    local it 0
    local max 1
    local p : list sizeof varlist
    while (`max'>`tolerance' & `it'<`iterate') {
        local ++it
        capture drop `oldw'
        rename `w' `oldw'
        if `scale0'==0 & (`it'==1 | "`updatescale'"!="") {
            robreg_mad `res' if `touse' [`weight'`exp'], normalize p(`p') `center'
            local scale = r(mad)
        }
        gen_`obf'_w `w' `res' `scale' `k' `touse'
*        if "`obf'"=="bisquare" {                       //! needed?
*            qui count if `w' != 0 & `touse'
*            if r(N) == 0 {
*                di as err "all weights went to zero;"
*                error 2000
*            }
*        }
        qui _regress `varlist' [aw=`w'] if `touse'
        drop `res'
        qui _predict double `res' if `touse', residual
        qui replace `maxd' = abs(`w' - `oldw') if `touse'
        sum `maxd' if `touse', meanonly
        local max = r(max)
        `log' di as txt "Iteration `it': maximum difference in weights = " ///
            as res `max'
        `dots' _dots 1 0
    }
    `dots' di " done"
    eret scalar it = `it'
    eret scalar scale = `scale'
    eret scalar converged = (`max' <= `tolerance')
end

program _robreg_m_r2_rho // (cf. Chen 2002, p.9)
    // R^2_rho = 1 - sum(rho((y-yhat)/s)) / sum(rho((y-ybar)/s))
    //      rho(): objective function
    //      yhat: predictions from full model (i.e. res = y-yhat)
    //      s: scale estimate from full model
    //      ybar: robust location estimate (constant-only model)
    syntax varlist [aw fw pw iw], scale(str) touse(str) res(str) obf(str) k(str) ///
        tolerance(str) iterate(str) [ init(str) center updatescale]
    local sumweight = cond("`weight'"=="pweight", "aweight", "`weight'")

    // fit constant-only model
    gettoken depname rhs : varlist
    if `"`rhs'"'!="" {
        tempname res0
        *di as txt "fitting constant only model ..." _c
        tempname hcurrent
        _est hold `hcurrent', estsystem
        if `"`init'"'=="ols" {
            su `depname' [`sumweight'`exp'] if `touse', meanonly
            qui gen double `res0' = `depname' - r(mean)
        }
        else {
            _pctile `depname' [`weight'`exp'], percentiles(50)
            qui gen double `res0' = `depname' - r(r1)
        }
        quietly _robreg_m_irwls `depname' [`weight'`exp'] , ///
            touse(`touse') res(`res0') obf(`obf') k(`k') ///
            tolerance(`tolerance') iterate(`iterate') `center' `updatescale'
        _est unhold `hcurrent'
        *di as txt " done"
    }
    else {
        local res0 "`res'"
    }

    // compute r2
    tempname rho0 rho
    gen_`obf'_rho `rho0' `res0' `scale' `k' `touse'
    gen_`obf'_rho `rho' `res' `scale' `k' `touse'
    su `rho0' if `touse' [`sumweight'`exp'], meanonly
    local sum_dev0 = r(sum)
    su `rho' if `touse' [`sumweight'`exp'], meanonly
    c_local r2_rho = 1 - r(sum) / `sum_dev0'
end

// s.ado

program robreg_s, sortpreserve eclass
    version 10.1
    syntax varlist(numeric min=2) [if] [in] [aw fw pw iw] [, ///    //! weights not implemented yet
        bp(real 0.5)                    /// breakdown point
        K0(str)                         /// tuning constant
        Nsamp(int 0)                    /// number of samples for the subsampling algorithm
        wr                              /// with replacement sampling (undocumented)
        NKeep(int 2)                    /// number of "best" candidates to keep for final refinement
        RSTEPs(int 1)                   /// number of refinement steps
        ITERate(integer `c(maxiter)')   /// max number of iterations for final M-refinement
        TOLerance(real 1e-6)            /// tolerance for final M-refinement
        SSTEPs(int 1)                   /// number of approximation iterations for scale estimate                                                            //!
        SITERate(integer `c(maxiter)')  /// max iterations for scale estimate
        STOLerance(real 1e-6)           /// tolerance for scale estimate
        alpha(real 0.01)                /// 1-alpha = probability of at least one "good" subsample
        EPSilon(real 0.2)               /// maximum contamination fraction
        Generate(name)                  /// store weights
        REplace                         ///
        Level(passthru)                 ///
        noRobust                        ///
        vce(str)                        ///
        noDOTs                          ///
        nose                            /// undocumented: omit standard errors
        ]

    if `"`vce'"'!="" & "`robust'"!="" {
        di as err "vce() and norobust not both allowed"
        exit 198
    }
    if `"`vce'"'!="" {
        Parse_vce `vce'
        if `"`vce'"'=="pv" {
            di as err `"invalid vce()"'
            exit 198
        }
    }
    else if "`robust'"=="" local vce robust

    if "`generate'"!="" {
        if "`replace'"=="" confirm new var `generate', exact
    }

    // breakdown point, tuning constant, and efficiency
    // see e.g. Rousseeuw & Leroy (1987: 142, Table 19)
    local delta = string(`bp',"%9.2f")
    local bplist 0.50 0.45 0.40 0.35 0.30 0.25 0.20 0.15 0.10
    if `:list posof "`delta'" in bplist'==0 | `delta'!=`bp' {
            di as err "bp() must be one of: `bplist'"
            exit 198
    }
    if `"`k0'"'=="" {
        local k: word `:list posof "`delta'" in bplist' of ///
            1.547645 1.756059 1.987965 2.251831 2.560843 2.937015 3.420681 4.096255 5.182361
        local efficiency: word `:list posof "`delta'" in bplist' of ///
            28.7  37.0  46.2  56.0  66.1  75.9  84.7  91.7  96.6
    }
    else {
        capt confirm number `k0'
        if _rc {
            di as err "invalid k()"
            exit 198
        }
        if `k0' <= 0 {
                di as err  "k() must be positive"
                exit 198
        }
        local k `k0'
    }
    local delta = `delta' * `k'^2/6   // rescale target value

    // number of subsamples options
    if `nsamp'<0 {
        di as err "nsamp() must be positive"
        exit 198
    }
    if `epsilon'==-1 local epsilon = min(0.2, `bp')
    if `epsilon'<=0 | `epsilon'>0.5 {
        di as err "epsilon() must be in (0,0.5]"
        exit 198
    }
    if `alpha'<=0 | `alpha'>=1 {
       di as err "alpha() must be in (0,1)"
       exit 198
    }

    // mark estimation sample and remove collinear variables
    marksample touse
    qui count if `touse'
    local N = r(N)
    _rmcoll `varlist' [`weight'`exp'] if `touse'
    local varlist `r(varlist)'
    local p: list sizeof varlist    // number of coefficients (including constant)
    if `p'==1 {
        di as err "too few variables"
        exit 102
    }
    if `N'<`p' error 2001
    gettoken depvar rhs : varlist

    // determine number of subsamples
    if `nsamp'==0 {
        local nsamp = ceil(ln(`alpha') / ln(1 - (1 - `epsilon')^`p'))
        local nsamp = min(max(`nsamp', 50), 10000)
    }
    local nkeep = min(`nkeep', `nsamp')

    // subsampling algorithm
    tempvar w
    qui generate double `w' = .
    mata: robreg_s(`nsamp', `k', `delta', `nkeep', `rsteps', "`wr'"!="", ///
        `iterate', `tolerance', `ssteps', `siterate', `stolerance', "`dots'"=="")
    qui reg `varlist' [aw=`w'] if `touse'   // final fit

    // Standard Errors
    if "`se'"!="" {
        local V
    }
    else {
        tempname e
        qui _predict double `e' if `touse', residual
        qui replace `e' = `e'/`scale' if `touse'
        tempname V
        if "`vce'"=="" {    // (Avar_2s from Croux et al. 2003)
            mata: st_matrix("`V'", _robreg_s_Avar_2s(`scale', `k', `N', `p'))
        }
        else /*if "`vce'"=="robust"*/ { // (Avar_1 from Croux et al. 2003)
            local vcetype "Robust"
            mata: st_matrix("`V'", _robreg_s_Avar_1(`scale', `k', `delta', `N', `p'))

        }
        local coln: coln e(b)
        mat coln `V' = `coln'
        mat rown `V' = `coln'
    }

    // return results
    if "`generate'"!="" {
        Vreturn `w' `generate' `replace'
    }
    tempname B
    mat `B' = e(b)
    eret post `B' `V', esample(`touse') depname(`depvar') obs(`N')
    eret scalar df_m        = `p'-1
    eret local vce          "`vce'"
    eret local vcetype      "`vcetype'"
    eret local depvar       "`depvar'"
    eret local model        "bisquare"
    if "`efficiency'"!=""   eret local title "S-Regression (`efficiency'% efficiency)"
    else                    eret local title "S-Regression"
    eret local subcmd       "s"
    eret local cmd          "robreg"
    global S_E_cmd          "robreg"       /* double save */
    eret scalar bp          = `bp'
    eret scalar k           = `k'
    if "`efficiency'"!=""   eret scalar efficiency  = `efficiency'
    eret scalar nsamp       = `nsamp'
    eret scalar scale       = `scale'
    eret scalar collin      = `collin'  // number of collinear samples
end

// mm.ado

program robreg_mm, eclass
    version 10.1
    syntax varlist(min=2 numeric) [if] [in] [aw fw pw iw] [, ///
        /// M-estimate
        EFFiciency(int 0)       ///
        K(passthru)             ///
        TOLerance(passthru)     ///
        ITERate(passthru)       ///
        relax                   ///
        LOg                     ///
        Generate(passthru)      ///
        /// S-estimate
        bp(passthru)            ///
        Nsamp(passthru)         ///
        noDOTs                  ///
        Sopts(str)              ///
        first                   ///
        save(name)              ///
        /// general
        noRobust                ///
        vce(str)                ///
        Level(passthru)         ///
        REplace                 ///
        ]

    if `"`vce'"'!="" & "`robust'"!="" {
        di as err "vce() and norobust not both allowed"
        exit 198
    }
    if `"`vce'"'!="" {
        Parse_vce `vce'
    }
    else if "`robust'"=="" local vce robust
    if "`vce'"=="" local vce norobust
    if "`vce'"=="robust" local se nose

    local efflist  70 75 80 85 90 95
    if `efficiency'!=0 {
        if `"`k'"'!="" {
            di as err "only one of k() and efficiency() allowed"
            exit 198
        }
        if `:list posof "`efficiency'" in efflist'==0 {
            di as err "efficiency() must be one of: `efflist'"
            exit 198
        }
    }
    else local efficiency 85  // default
    if `"`k'"'=="" {
        local effopt efficiency(`efficiency')
    }

    //initial S-estimate
    di as txt _n "Step 1: fitting S-estimate"
    robreg_s `varlist' `if' `in' [`weight'`exp'], vce(`vce') `bp' `nsamp' `dots' `replace' `sopts'
    local nsamp = e(nsamp)
    local k_s   = e(k)
    local bp    = e(bp)
    local collin = e(collin)
    if "`first'"!=""                Display, `level'
    if "`vce'"=="robust" {
        tempname e_s
        qui _predict double `e_s' if e(sample), xb
        qui replace `e_s' = (`e(depvar)' - `e_s')/e(scale) if e(sample)
    }
    if "`save'"!="" {
        estimates store `save'
        di as txt "(initial estimates stored as {stata estimates replay `save':`save'})"
    }

    // M-estimate
    di as txt _n "Step 2: fitting redescending M-estimate" _n
    robreg_m `varlist' `if' `in' [`weight'`exp'], biweight init(.) scale(`e(scale)') ///
        vce(`vce') `se' `k' `effopt' `tolerance' `iterate' `relax' `log' `generate' `replace'

    // Compute SE's
    if "`vce'"=="robust" {
        gettoken depvar rhs : varlist
        local scale = e(scale)
        local k_m = e(k)
        local N = e(N)
        local p = e(df_m) + 1
        tempvar touse e
        qui gen byte `touse' = e(sample)
        qui _predict double `e' if `touse', xb
        qui replace `e' = (`depvar' - `e')/`scale' if `touse'

        tempname V
        mata: st_matrix("`V'", _robreg_mm_Avar_1(`scale', `k_m', `k_s', `bp', `N', `p'))
        eret repost V=`V'
        eret local vce "robust"
        eret local vcetype "Robust"
    }

    // adjust returns
    eret local init ""
    eret local obf  ""
    if `"`k'"'=="" eret local title "MM-Regression (`efficiency'% efficiency)"
    else            eret local title "MM-Regression"
    eret local subcmd "mm"
    eret scalar nsamp  = `nsamp'
    eret scalar k_init = `k_s'
    eret scalar bp     = `bp'
    eret scalar collin = `collin'
end

// lms.ado

program robreg_lms
    version 10.1
    syntax anything [if] [in] [aw fw pw iw] [, bp(passthru) * ]
    if `"`bp'"'!="" {
        di as err "bp() not allowed"
        exit 198
    }
    robreg_lqs `anything' `if' `in' [`weight'`exp'], lms `options'
end

// lts.ado

program robreg_lts
    version 10.1
    syntax anything [if] [in] [aw fw pw iw] [, * ]
    robreg_lqs `anything' `if' `in' [`weight'`exp'], lts `options'
end

// lqs.ado

program robreg_lqs, sortpreserve eclass
    version 10.1
    syntax varlist(numeric min=2) [if] [in] [aw fw pw iw] [, ///    //! weights not implemented yet
        lms                 /// LMS-estimate
        lts                 /// LTS-estimate
        bp(real 0.5)        /// breakdown point [0,.5]
        Nsamp(int 0)        /// number of samples for the subsampling algorithm
        wr                  /// with replacement sampling (undocumented)
        alpha(real 0.01)    /// 1-alpha = probability of at least one "good" subsample
                            /// (alpha = gamma in Maronna et al. 2006)
        EPSilon(real -1)    /// maximum contamination fraction
        Generate(name)      /// store minimizing sample
        REplace             ///
        /*Level(passthru)*/ ///
        /* vce(...) ... */  ///
        noDOTs              ///
        ]

    if "`lms'"!="" & "`lts'"!="" {
        di as err "only one of lms and lts allowed"
        exit 198
    }
    if "`generate'"!="" {
        if "`replace'"=="" confirm new var `generate', exact
    }
    if `bp'<=0 | `bp'>0.5 {
        di as err "bp() must be in (0,0.5]"
        exit 198
    }
    if `nsamp'<0 {
        di as err "nsamp() must be positive"
        exit 198
    }
    if `alpha'<=0 | `alpha'>=1 {
        di as err "alpha() must be in (0,1)"
        exit 198
    }
    if `epsilon'==-1 local epsilon = min(0.2, `bp')
    if `epsilon'<=0 | `epsilon'>0.5 {
        di as err "epsilon() must be in (0,0.5]"
        exit 198
    }

    // estimation sample and remove collinear variables
    marksample touse
    qui count if `touse'
    local N = r(N)
    _rmcoll `varlist' [`weight'`exp'] if `touse'
    local varlist `r(varlist)'
    local p: list sizeof varlist        // number of coefficients (including constant)
    if `p'==1 {
        di as err "too few variables"
        exit 198
    }
    if `N'<`p' error 2001

    // number of subsamples
    if `nsamp'==0 {
        local nsamp = ceil(ln(`alpha') / ln(1 - (1 - `epsilon')^`p'))
        local nsamp = min(max(`nsamp', 500), 10000)
    }

    // subsampling algorithm
    local h = floor((1-`bp')*`N') + floor(`bp'*(`p' + 1)) // for LQS/LTS
    tempvar itouse
    qui generate byte `itouse' = 0 if `touse'
    if "`mata'"=="" {
        mata: robreg_lqs(`nsamp', 2 - ("`lms'"!="") + ("`lts'"!=""), ///
            `h', "`wr'"!="", "`dots'"=="")
    }
    else {
        _robreg_lqs "`varlist'" "`weight'" "`exp'" `touse' `itouse' `N' `p' `h' ///
                `bp' `nsamp' "`lms'" "`lts'"
    }
    qui reg `varlist' [`weight'`exp'] if `itouse'==1 // final fit

    // scale estimates
    if "`lms'"!="" {
        local s0 = 1/invnormal(0.75) * (1 + 5/(`N' - `p')) * sqrt(`crit')
    }
    else {
        local c = 1 / invnormal((`N'+`h')/(2*`N'))
        if "`lts'"!="" {
            local d = 1 / sqrt(1 - 2*`N' / (`h' * `c') * normalden(1/`c'))
            local s0 = `d' * sqrt(`crit'/`h')
        }
        else { // => LQS
            local s0 = `c' * sqrt(`crit')   //  (no finite sample correction)
        }
    }
    tempvar r
    qui _predict double `r' if `touse', residuals
    qui replace `r' = cond(abs(`r') <= 2.5 * `s0', `r'^2, .)
    su `r', meanonly
    local scale = sqrt( r(sum) / (r(sum_w)-`p') )

    // returns
    if "`generate'"!="" {
        Vreturn `itouse' `generate' `replace'
    }
    tempname B
    mat `B' = e(b)
    local depvar = e(depvar)
    eret post `B', esample(`touse') depname(`depvar') obs(`N')
    eret scalar df_m        = `p'-1
    eret local depvar "`depvar'"
    if "`lms'"!="" {
        eret local bp
        eret local title    "LMS regression"
        eret local subcmd   "lms"
    }
    else if "`lts'"!="" {
        eret scalar bp      = `bp'
        eret local title    "LTS regression"
        eret local subcmd   "lts"
    }
    else { // => LQS
        eret scalar bp      = `bp'
        eret local title    "LQS regression"
        eret local subcmd   "lqs"
    }
    eret local cmd          "robreg"
    global S_E_cmd          "robreg"       /* double save */    //! remove this?
    eret scalar nsamp       = `nsamp'
    eret scalar crit        = `crit'
    eret scalar scale0      = `s0'
    eret scalar scale       = `scale'
    eret scalar collin      = `collin'  // number of collinear samples
end

// mad.ado

// syntax:  robreg mad <varname> [if] [in] [weight] [, options ]
// options: NOCENter    do not center varname
//          NORMalize   return normalized MAD
//          p(#)        use N-p largest deviations only
// aweights, fweights, and pweights allowed
// saves in r():    r(mad)         scale estimate
//                  r(p)           value of p() option
//                  r(center)      "center" or "nocenter"
//                  r(normalize)   "normalize" or "nonormalize"
program robreg_mad, rclass
    version 10.1
    syntax varname [if] [in] [aw fw pw] [, noCENter NORMalize p(int 0) ]
    marksample touse
    if "`weight'"=="pweight" local weight aweight
    tempvar absdev
    if "`center'"=="" {
        _pctile `varlist' if `touse' [`weight'`exp'], p(50)
        qui generate `absdev' = abs(`varlist' - r(r1)) if `touse'
    }
    else {
        qui generate `absdev' = abs(`varlist') if `touse'
    }
    if (`p'>=1) { // use (N-p) largest residuals only
        _robreg_mad_marklargest `touse' `absdev' `p'
    }
    qui sum `absdev' if `touse' [`weight'`exp'], detail
    if "`normalize'"!="" {
        return scalar mad = r(p50) / invnormal(0.75) // approx. 0.6745
    }
    else {
        return scalar mad = r(p50)
    }
    return scalar N = r(N)
    return scalar p = `p'
    return local center = cond("`center'"=="", "center", "`center'")
    return local normalize = cond("`normalize'"=="", "nonormalize", "`normalize'")
end

prog _robreg_mad_marklargest, sort
    args touse absdev p
    sort `touse' `absdev'
    qui by `touse': replace `touse' = 0 if `touse' & (_n<=`p')
end

// obf.ado

program gen_bisquare_rho
    args varname x scale k touse
    qui gen double `varname' = ///
        cond(abs(`x') <= `k' * `scale', ///
            `k'^2/6 * (1 - (1 - (`x'/(`k'*`scale'))^2)^3), ///
            `k'^2/6) ///
        if `touse'
end

program gen_bisquare_psi
    args varname x scale k touse
    qui gen double `varname' = ///
        cond(abs(`x') <= `k' * `scale', ///
            `x'/`scale' * (1 - (`x'/(`k'*`scale'))^2)^2, ///
            0) ///
        if `touse'
end

program gen_bisquare_phi // derivative of psi
    args varname x scale k touse
    qui gen double `varname' = ///
        cond(abs(`x') <= `k' * `scale', ///
            (1 - (`x'/(`k'*`scale'))^2) * (1 - 5 * (`x'/(`k'*`scale'))^2), ///
            0) ///
        if `touse'
end

program gen_bisquare_w
    args varname x scale k touse
    qui gen double `varname' = ///
        cond(abs(`x') <= `k' * `scale', ///
            (1 - (`x'/(`k'*`scale'))^2)^2, ///
            0) ///
        if `touse'
    *qui gen double `varname' = ///
    *    max(1 - (`x'/(`k'*`scale'))^2, 0)^2 ///
    *    if `touse'
end

program gen_huber_rho
    args varname x scale k touse
    qui gen double `varname' = ///
        cond(abs(`x') <= `k' * `scale', ///
            0.5 * (`x'/`scale')^2, ///
            `k'/`scale' * abs(`x') - 0.5 * `k'^2) ///
        if `touse'
end

program gen_huber_psi
    args varname x scale k touse
    qui gen double `varname' = ///
        cond(abs(`x') <= `k' * `scale', ///
            `x'/`scale', ///
            sign(`x') * `k') ///
        if `touse'
end

program gen_huber_phi // derivative of psi
    args varname x scale k touse
    qui gen double `varname' = ///
        cond(abs(`x') <= `k' * `scale', 1, 0) ///
        if `touse'
end

program gen_huber_w
    args varname x scale k touse
    qui gen double `varname' = ///
        cond(abs(`x') <= `k' * `scale', ///
            1, ///
            `k' * `scale' / abs(`x')) ///
        if `touse'
end

// misc.ado

program Vreturn
    args oldname newname replace
    if "`replace'"!="" {
        capt confirm var `newname', exact
        if !_rc drop `newname'
    }
    rename `oldname' `newname'
end

program Parse_vce
    local l = strlen(`"`0'"')
    if      `"`0'"'==substr("robust",1,max(1,`l'))   local vce robust
    else if `"`0'"'==substr("norobust",1,max(3,`l')) local vce ""
    else if `"`0'"'=="pv"                            local vce pv     // undocumented
    else {
        di as err `"invalid vce()"'
        exit 198
    }
    c_local vce `vce'
end

version 10.1
mata:
mata set matastrict on

// s.mata
void robreg_s(
    real scalar nsamp,        // number of subsamples
    real scalar k,            // tuning constant
    real scalar delta,        // target value (= bp * k^2/6)
    real scalar nkeep,        // number of candidates to keep
    real scalar rsteps,       // refinements steps
    real scalar wr,           // with replacement sampling
    real scalar iterate,      // max iteration for M estimate
    real scalar tolerance,    // tolerance for M estimate
    real scalar ssteps,       // scale spproximation steps
    real scalar siterate,     // max iterations for scale estimate
    real scalar stolerance,   // tolerance for scale estimate
    real scalar dots          // display progress dots
    )
{
    real matrix         Z, Zi, CP, XXp, b_keep
    real rowvector      s_keep
    real colvector      P, b, b0, e, w, w_best
    real scalar         N, p, i, j, l, i_max, s, s0, smax, s_best, collin, doti

    st_view(Z, ., tokens(st_local("varlist")), st_local("touse"))   // get data (including depvar)
    p = cols(Z) // number of covariates + 1
    N = rows(Z)

    if (dots==0) {
        printf("{txt}enumerating {res}%g{txt} candidates ...", nsamp)
    }
    else {
        printf("\n{txt}enumerating {res}%g{txt} candidates (percent completed)\n", nsamp)
        display("{txt}0 {hline 5} 20 {hline 6} 40 {hline 6} 60 {hline 6} 80 {hline 5} 100")
        doti = 1
    }
    displayflush()

    b_keep = J(p, nkeep, .)
    s_keep = J(1, nkeep, maxdouble())
    smax  = maxdouble()
    i_max = 1
    collin = 0
    for (i=1; i<=nsamp; i++) {
        // draw sample and compute LS fit
        if (wr) P = ceil(uniform(p,1)*N)    // with replacement
        else    P = mm_unorder2(N)[|1 \ p|] // unorder(N)[|1 \ p|] // without replacement
        Zi = Z[P,]
        CP = cross(Zi,1 , Zi,1) // note: XX = CP[|2,2 \ .,.|],  Xy = CP[|2,1 \ .,1|]
        XXp = invsym(CP[|2,2 \ .,.|])
        if (diag0cnt(XXp)) {
            i--
            collin++
            continue
        }
        b = XXp * CP[|2,1 \ .,1|]

        // refinement steps (default 1)
        e  = Z[,1] - (Z[|1,2 \ .,.|]*b[|1 \ rows(b)-1|] :+ b[rows(b)])
        s0 = mm_median(abs(e), 1) / invnormal(0.75) // MADN (possibly: only use largest n-p)
        for (j=1; j<=rsteps; j++) {
            for (l=1; l<=ssteps; l++) { //  or: min(ssteps, siterate)
                s = sqrt(sum(_robreg_bisquare_rho(e, s0, k)) / ((N-p)*delta)) * s0
                if (abs(s/s0 - 1) <= stolerance) break
                s0 = s
            }
            w = _robreg_bisquare_w(e, s, k)
            CP = cross(Z,1, w, Z,1)
            b = invsym(CP[|2,2 \ .,.|]) * CP[|2,1 \ .,1|]
            e  = Z[,1] - (Z[|1,2 \ .,.|]*b[|1 \ rows(b)-1|] :+ b[rows(b)])
        }

        // optimize scale
        if ((sum(_robreg_bisquare_rho(e, smax, k))/(N-p)) <= delta)  {  // smax, not s
            s0 = s
            for (l=1; l<=siterate; l++) {
                s = sqrt(sum(_robreg_bisquare_rho(e, s0, k)) / ((N-p)*delta)) * s0
                if (abs(s/s0 - 1) <= stolerance) break
                if (i==siterate) _error(3360, "failure to converge")
                s0 = s
            }

            // possibly keep hold of candidate
            if (s<smax) {
                s_keep[i_max] = s
                b_keep[,i_max] = b
                smax = 0
                i_max = 1
                for (j=1; j<=nkeep; j++) {
                    if (s_keep[j] > smax) {
                        smax = s_keep[j]
                        i_max = j
                    }
                }
            }
        }

        // progress dots
        if (dots) {
            while (i*50 >= doti*nsamp) {
                printf(".")
                displayflush()
                doti++
            }
        }

    }
    if (dots) printf("\n\n")
    if (dots==0) printf("{txt} done\n")

    // refine candidates
    printf("{txt}refining {res}%g{txt} best candidates ...", nkeep)
    displayflush()
    s_best = .
    for (j=1; j<=nkeep; j++) {
        s0 = s_keep[j]
        b0 = b_keep[,j]
        for (i=1; i<=iterate; i++) {
            e  = Z[,1] - (Z[|1,2 \ .,.|]*b0[|1 \ rows(b0)-1|] :+ b0[rows(b0)])
            for (l=1; l<=ssteps; l++) {
                s = sqrt(sum(_robreg_bisquare_rho(e, s0, k)) / ((N-p)*delta)) * s0
                if (abs(s/s0 - 1) <= stolerance) break
                s0 = s
            }
            w = _robreg_bisquare_w(e, s, k)
            CP = cross(Z,1, w, Z,1)
            b = invsym(CP[|2,2 \ .,.|]) * CP[|2,1 \ .,1|]
            if (mreldif(b0,b) <= tolerance) break
            if (i==iterate) _error(3360, "failure to converge")
            b0 = b
        }
        if (s<s_best) {
            s_best = s
            swap(w_best, w)
        }
    }
    printf("{txt} done\n")
    st_store(., st_local("w"), st_local("touse"), w_best)
    st_local("scale", strofreal(s_best,"%18.0g"))
    st_local("collin", strofreal(collin))
}

// lqs.mata
void robreg_lqs(
    real scalar nsamp,        // number of subsamples
    real scalar etype,        // estimator (1=lms, 2=lqs, 3=lts)
    real scalar h,            // h for LQS/LTS
    real scalar wr,           // with replacement sampling
    real scalar dots          // display progress dots
    )
{
    real matrix         Z, Zi, CP, XXp
    real colvector      P, P_best, b, e
    real scalar         i, p, N, crit, C, collin, doti

    st_view(Z, ., tokens(st_local("varlist")), st_local("touse"))
    p = cols(Z)
    N = rows(Z)

    if (dots==0) {
        printf("{txt}enumerating {res}%g{txt} samples ...", nsamp)
    }
    else {
        printf("\n{txt}enumerating {res}%g{txt} samples (percent completed)\n", nsamp)
        display("{txt}0 {hline 5} 20 {hline 6} 40 {hline 6} 60 {hline 6} 80 {hline 5} 100")
        doti = 1
    }
    displayflush()

    crit = .
    collin = 0
    for (i=1; i<=nsamp; i++) {
        if (wr) P = ceil(uniform(p,1)*N)    // with replacement
        else    P = mm_unorder2(N)[|1 \ p|] // unorder(N)[|1 \ p|] // without replacement
        Zi = Z[P,]
        CP = cross(Zi,1 , Zi,1) // note: XX = CP[|2,2 \ .,.|],  Xy = CP[|2,1 \ .,1|]
        XXp = invsym(CP[|2,2 \ .,.|])
        if (diag0cnt(XXp)) {
            i--
            collin++
            continue
        }
        b = XXp * CP[|2,1 \ .,1|]
        e = Z[,1] - (Z[|1,2 \ .,.|]*b[|1 \ rows(b)-1|] :+ b[rows(b)])
        e = e:^2
        if (etype==1)       C = mm_quantile(e, 1, 0.5)  // LMS
        else if (etype==2)  C = mm_quantile(e, 1, h/N)  // LQS
        else if (etype==3) {                            // LTS
            _sort(e, 1)
            C = sum(e[|1 \ h|])
        }
        else _error(3498)
        if (C < crit) {
            P_best = P
            crit = C
        }
        if (dots) {
            while (i*50 >= doti*nsamp) {
                printf(".")
                displayflush()
                doti++
            }
        }
    }
    if (dots) printf("\n")
    if (dots==0) printf("{txt} done\n")

    P = J(N,1,0)
    P[P_best] = J(p,1,1)
    st_store(., st_local("itouse"), st_local("touse"), P)
    st_local("crit", strofreal(crit,"%18.0g"))
    st_local("collin", strofreal(collin))
}

// var.mata
real matrix _robreg_m_Avar_2s( // Avar_2s/N from Croux et al. (2003) for M-estimate
    real scalar scale,
    real scalar k,
    real scalar N,
    real scalar p,
    pointer scalar f)
{
    real colvector  e
    real matrix     X

    e  = st_data(., st_local("res"), st_local("touse")) / scale
    st_view(X, ., tokens(st_local("rhs")), st_local("touse"))

    return( scale^2 *
        mean((*f)(e, 1, k, 1):^2) /     // (*f)(..., 1) => psi
        mean((*f)(e, 1, k, 2))^2 *      // (*f)(..., 2) => phi
        invsym(cross(X,1, X,1)) )       // or multiply by N/(N-p) in analogy to OLS
}

real matrix _robreg_m_Avar_1s( // Avar_1s/N from Croux et al. (2003) for M-estimate
    real scalar scale,
    real scalar k,
    real scalar N,
    real scalar p,
    pointer scalar f)
{
    real colvector  e
    real matrix     X, A

    e  = st_data(., st_local("res"), st_local("touse")) / scale
    st_view(X, ., tokens(st_local("rhs")), st_local("touse"))

    A   = invsym(cross(X,1, (*f)(e, 1, k, 2), X,1)) * (N * scale) // (*f)(..., 2) => phi
    return( (A * (cross(X,1, (*f)(e, 1, k, 1):^2, X,1) / N) *     // (*f)(..., 1) => psi
        A) / N )                                 // or divide by (N-p) in analogy to OLS
}

real matrix _robreg_mm_Avar_1( // Avar_1/N from Croux et al. (2003) for MM-estimate
    real scalar scale,
    real scalar k,
    real scalar k0,
    real scalar b,
    real scalar N,
    real scalar p)
{
    real colvector  e, e0, psi, phi, rho0, psi0
    real matrix     X, A, a, Erho0psiX

    e  = st_data(., st_local("e"), st_local("touse"))
    e0 = st_data(., st_local("e_s"), st_local("touse"))
    st_view(X, ., tokens(st_local("rhs")), st_local("touse"))

    phi  = _robreg_bisquare_phi(e, 1, k)
    psi0 = _robreg_bisquare_psi(e0, 1, k0)
    A    = invsym(cross(X,1, phi, X,1)) * (N * scale)
    a    = A * cross(X,1, phi, e,0) / (N * mean(psi0 :* e0))

    psi  = _robreg_bisquare_psi(e, 1, k)
    rho0 = _robreg_bisquare_rho(e0, 1, k0)
    Erho0psiX = cross(X,1, rho0, psi,0) / N

    return( (A * (cross(X,1, psi:^2, X,1) / N)  * A
            - a * Erho0psiX' * A - A * Erho0psiX * a'
            + mean(rho0:^2 :- (b * k0^2/6)^2) * a * a') / N )  // or divide by (N-p) in analogy to OLS
}

real matrix _robreg_s_Avar_2s( // Avar_2s/N from Croux et al. (2003) for S-estimate
    real scalar scale,
    real scalar k,
    real scalar N,
    real scalar p)
{
    real colvector  e
    real matrix     X

    e  = st_data(., st_local("e"), st_local("touse"))
    st_view(X, ., tokens(st_local("rhs")), st_local("touse"))

    return( scale^2 *
        mean(_robreg_bisquare_psi(e, 1, k):^2) /
        mean(_robreg_bisquare_phi(e, 1, k))^2 *
        invsym(cross(X,1, X,1)) )             // or multiply by N/(N-p) in analogy to OLS
}

real matrix _robreg_s_Avar_1( // Avar_1/N from Croux et al. (2003) for S-estimate
    real scalar scale,
    real scalar k,
    real scalar delta,
    real scalar N,
    real scalar p)
{
    real colvector  e, rho, psi, phi
    real matrix     X, A, a, ErhopsiX

    e  = st_data(., st_local("e"), st_local("touse"))
    st_view(X, ., tokens(st_local("rhs")), st_local("touse"))

    phi = _robreg_bisquare_phi(e, 1, k)
    psi = _robreg_bisquare_psi(e, 1, k)
    A   = invsym(cross(X,1, phi, X,1)) * (N * scale)
    a   = A * cross(X,1, phi, e,0) / (N * mean(psi :* e))

    rho = _robreg_bisquare_rho(e, 1, k)
    ErhopsiX = cross(X,1, rho, psi,0) / N

    return( (A * (cross(X,1, psi:^2, X,1) / N)  * A
            - a * ErhopsiX' * A - A * ErhopsiX * a'
            + mean(rho:^2 :- delta^2) * a * a') / N )  // or divide by (N-p) in analogy to OLS
}

// obf.mata
real colvector _robreg_bisquare(
    real colvector x,
    real scalar scale,
    real scalar k,
    real scalar deriv
    )
{
    if (deriv==0)       return(_robreg_bisquare_rho(x, scale, k))
    else if (deriv==1)  return(_robreg_bisquare_psi(x, scale, k))
    else if (deriv==2)  return(_robreg_bisquare_phi(x, scale, k))
    else _error(198, "deriv must be in {0,1,2}")
}

real colvector _robreg_bisquare_rho(
    real colvector x,
    real scalar scale,
    real scalar k
    )
{
    real colvector x2

    x2 = (x * (1 / scale / k)):^2
    return( k^2/6 * (1 :- (1 :- x2):^3):^(x2:<=1) )
}

real colvector _robreg_bisquare_psi(
    real colvector x,
    real scalar scale,
    real scalar k
    )
{
    real colvector xs, x2

    xs = x / scale
    x2 = (xs / k):^2
    return((xs :* (1 :- x2):^2) :* (x2:<=1))
}

real colvector _robreg_bisquare_phi(
    real colvector x,
    real scalar scale,
    real scalar k
    )
{
    real colvector x2

    x2 = (x * (1 / scale / k)):^2
    return(((1 :- x2) :* (1 :- 5*x2)) :* (x2:<=1))
}

real colvector _robreg_bisquare_w(
    real colvector x,
    real scalar scale,
    real scalar k
    )
{
    real colvector x2

    x2 = (x * (1 / scale / k)):^2
    return(((1 :- x2):^2) :* (x2 :<= 1))
}

real colvector _robreg_huber(
    real colvector x,
    real scalar scale,
    real scalar k,
    real scalar deriv
    )
{
    if (deriv==0)       return(_robreg_huber_rho(x, scale, k))
    else if (deriv==1)  return(_robreg_huber_psi(x, scale, k))
    else if (deriv==2)  return(_robreg_huber_phi(x, scale, k))
    else _error(198, "deriv must be in {0,1,2}")
}

real colvector _robreg_huber_rho(
    real colvector x,
    real scalar scale,
    real scalar k
    )
{
    real colvector xs, d
    xs = x / scale
    d = abs(xs) :<= k

    return( (0.5 * xs:^2):*d :+ (k*abs(xs) :- 0.5*k^2):*(1 :- d) )
}

real colvector _robreg_huber_psi(
    real colvector x,
    real scalar scale,
    real scalar k
    )
{
    real colvector xs, d
    xs = x / scale
    d = abs(xs) :<= k

    return( xs :* d :+ (sign(x) * k):*(1 :- d))
}

real colvector _robreg_huber_phi(
    real colvector x,
    real scalar scale,
    real scalar k
    )
{
    return( abs(x / scale) :<= k )
}

real colvector _robreg_huber_w(
    real colvector x,
    real scalar scale,
    real scalar k
    )
{

    real colvector xs, d
    xs = abs(x / scale)
    d = xs :<= k

    return( (k:/xs):^(1:-d) )
}

end
