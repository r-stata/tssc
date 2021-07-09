*! version 1.0.4  28jan2009  Ben Jann

prog logitcprplot, sortpreserve
    version 9.2
    syntax varlist [if] [in] [ , SAMPle(numlist max==1 <=100 >=1) ///
        Generate(name)                  ///
        Replace                         ///
        NORLine RLine(str asis)         ///
        Lowess Lowess2(str asis)        ///
        LPoly LPoly2(str asis)          /// Stata 10 required
        FPfit FPfit2(str asis)          ///
        RCspline RCspline2(str asis)    ///
        PSpline PSpline2(str asis)      /// -pspline- required
        RSpline RSpline2(str asis)      /// -uvrs- required
        RUNning RUNning2(str asis)      /// -running- required
        AUTOsmoo AUTOsmoo2(str asis)    /// -autosmoo- required
        noGRaph                         ///
        addplot(str asis) * ]
    if `"`generate'"'!="" & "`replace'"=="" {
        confirm new var `generate'
    }
    if `"`lpoly2'"'!="" local lpoly lpoly
    _parse_lpoly, `lpoly2'
    if `"`fpfit2'"'!="" local fpfit fpfit
    _parse_fpfit, `fpfit2'
    if `"`lowess2'"'!="" local lowess lowess
    if !inlist(`"`e(cmd)'"',"logit","logistic") {
        di as err "last estimates not found"
        exit 301
    }
    if "`sample'"!="" {
        capt which gsample
        local rc = _rc
        if _rc {
            di as error "-gsample- user command required; see {stata ssc describe gsample}"
        }
        capt findfile lmoremata.mlib
        if _rc {
            di as error "-moremata- user package required; see {stata ssc describe moremata}"
        }
        if `rc' | _rc exit 499
    }

    // compute predictions and partial residuals
    marksample touse, novar
    qui replace `touse' = 0 if e(sample)!=1
    local wtype `"`e(wtype)'"'
    local wexp `"`e(wexp)'"'
    tempvar pr r xb rplus
    local depvar = e(depvar)
    qui predict `pr' if `touse', pr
    qui gen `r' = (`depvar' - `pr') / (`pr'*(1-`pr'))
    local terms
    foreach var of local varlist {
        local terms `"`terms' + _b[`var']*`var'"'
    }
    qui gen `xb' = 0 `terms' if `touse'
    qui gen `rplus' = `r' + `xb'
    gettoken firstvar : varlist

    // compute rcspline smooth
    if `"`rcspline'`rcspline2'"'!="" {
        local rcspline rcspline
        tempvar rcvar rcci_l rcci_u
        _rcspline `rplus' `firstvar' if `touse' [`wtype'`wexp'], ///
            gen(`rcvar' `rcci_l' `rcci_u') `rcspline2'
    }

    // compute pspline smooth
    if `"`pspline'`pspline2'"'!="" {
        capt which pspline
        if _rc {
            di as error "-pspline- user command required; see {stata ssc describe pspline}"
            error 499
        }
        local pspline pspline
        tempvar psvar
        _pspline `rplus' `firstvar' if `touse' [`wtype'`wexp'], ///
            gen(`psvar') `pspline2'
    }

    // compute rspline smooth
    if `"`rspline'`rspline2'"'!="" {
        capt which uvrs
        if _rc {
            di as error "-uvrs- user command required; see {stata net sj 7-1 st0120}"
            error 499
        }
        local rspline rspline
        tempvar rsvar rsci_l rsci_u
        _rspline `rplus' `firstvar' if `touse' [`wtype'`wexp'], ///
            gen(`rsvar' `rsci_l' `rsci_u') `rspline2'
    }

    // compute running smooth
    if `"`running'`running2'"'!="" {
        capt which running
        if _rc {
            di as error "-running- user command required; see {stata net sj 5-2 sed9_2}"
            error 499
        }
        local running running
        tempvar runvar runci_l runci_u
        _running `rplus' `firstvar' if `touse' [`wtype'`wexp'], ///
            gen(`runvar' `runci_l' `runci_u') `running2'
    }

    // compute autosmoo smooth
    if `"`autosmoo'`autosmoo2'"'!="" {
        capt which autosmoo
        if _rc {
            di as error "-autosmoo- user command required; see {stata net stb 41 gr27}"
            error 499
        }
        local autosmoo autosmoo
        tempvar autovar
        _autosmoo `rplus' `firstvar' if `touse' [`wtype'`wexp'], ///
            gen(`autovar') `autosmoo2'
    }

    // select obs to be plotted; also affects lowess and lpoly (rcspline will always use all obs)
    if "`sample'"!="" {
        tempname touse2
        gsample `sample' if `touse', wor generate(`touse2') percent
    }
    else {
        local touse2 `touse'
    }
    tempname touse3 // unique X values
    qui bys `touse' `firstvar': gen byte `touse3' = _n==1 & `touse'

    // compile graph
    local i = 0
    local p = 1 + ("`norline'"=="")
    local lord
    if `"`lpci'"'!="" {
        local lpcigraph (lpolyci `rplus' `firstvar' if `touse2' [`wtype'`wexp'], ///
            clstyle(p`++p') yvarlabel("lpoly smooth") `lpoly2')
        local ++i
        local lord "`lord' `++i'"
    }
    if `"`fpci'"'!="" {
        local fpcigraph (fpfitci `rplus' `firstvar' if `touse' [`wtype'`wexp'], ///
            clstyle(p`++p') yvarlabel("fracpoly fit") `fpfit2')
        local ++i
        local lord "`lord' `++i'"
    }
    if `"`rcspline'"'!="" {
        if `"`rcci'"'!="" {
            local rccigraph (rarea `rcci_l' `rcci_u' `firstvar' if `touse3', ///
                sort yvarlabel("rcspline CI") `rcci2')
            local ++i
        }
    }
    if `"`rspline'"'!="" {
        if `"`rsci'"'!="" {
            local rscigraph (rarea `rsci_l' `rsci_u' `firstvar' if `touse3', ///
                sort yvarlabel("rspline CI") `rsci2')
            local ++i
        }
    }
    if `"`running'"'!="" {
        if `"`runningci'"'!="" {
            local runciraph (rarea `runci_l' `runci_u' `firstvar' if `touse3', ///
                sort yvarlabel("running CI") `runningci2')
            local ++i
        }
    }
    local ++i
    if "`norline'"=="" {
        local rlgraph (line `xb' `firstvar' if `touse3', ///
            sort pstyle(p2) yvarlabel("model fit") `rline')
        local lord "`++i' `lord'"
    }
    if `"`rcspline'"'!="" {
        local rcgraph (line `rcvar' `firstvar' if `touse3', ///
            sort pstyle(p`++p') yvarlabel("rcspline smooth") `rcspline2')
        local lord "`lord' `++i'"
    }
    if `"`pspline'"'!="" {
        local psgraph (line `psvar' `firstvar' if `touse3', ///
            sort pstyle(p`++p') yvarlabel("pspline smooth") `pspline2')
        local lord "`lord' `++i'"
    }
    if `"`rspline'"'!="" {
        local rsgraph (line `rsvar' `firstvar' if `touse3', ///
            sort pstyle(p`++p') yvarlabel("rspline smooth") `rspline2')
        local lord "`lord' `++i'"
    }
    if `"`running'"'!="" {
        local rungraph (line `runvar' `firstvar' if `touse3', ///
            sort pstyle(p`++p') yvarlabel("running smooth") `running2')
        local lord "`lord' `++i'"
    }
    if `"`autosmoo'"'!="" {
        local autograph (line `autovar' `firstvar' if `touse3', ///
            sort pstyle(p`++p') yvarlabel("auto smooth") `autosmoo2')
        local lord "`lord' `++i'"
    }
    if `"`lpoly'"'!="" & `"`lpci'"'=="" {
        local lpgraph (lpoly `rplus' `firstvar'  if `touse2' [`wtype'`wexp'], ///
            pstyle(p`++p') yvarlabel("lpoly smooth") `lpoly2')
        local lord "`lord' `++i'"
    }
    if `"`fpfit'"'!="" & `"`fpci'"'=="" {
        local fpgraph (fpfit `rplus' `firstvar'  if `touse' [`wtype'`wexp'], ///
            pstyle(p`++p') pstyle(p`++p') yvarlabel("fracpoly fit") `fpfit2')
        local lord "`lord' `++i'"
    }
    if `"`lowess'"'!="" {
        local lsgraph (lowess `rplus' `firstvar'  if `touse2' [`wtype'`wexp'], ///
            pstyle(p`++p') yvarlabel("lowess smooth") `lowess2')
        local lord "`lord' `++i'"
    }
    if `"`graph'"'=="" {
        twoway `lpcigraph' `fpcigraph' `rccigraph' `rscigraph' `runciraph' ///
            (scatter `rplus' `firstvar' if `touse2', ///
            pstyle(p1) yti("partial logit residual") xtit(`firstvar') ///
            legend(order(`lord') cols(3)) `options') ///
            `rlgraph' `rcgraph' `psgraph' `rsgraph' `rungraph' `autograph' ///
            `lpgraph' `fpgraph' `lsgraph' ///
            || `addplot'
    }

    // return results
    if `"`generate'"'!="" {
        if "`replace'"!="" {
            capt confirm var `generate', exact
            if _rc==0 drop `generate'
        }
        rename `rplus' `generate'
    }
end

program _parse_lpoly
    syntax [, ci CI2(str asis) * ]
    if `"`ci2'"'!="" {
        local ci ci
    }
    if "`ci'"!="" {
        local ci2 pstyle(ci) `ci2'
    }
    c_local lpci `ci'
    c_local lpoly2 `ci2' `options'
end

program _parse_fpfit
    syntax [, ci CI2(str asis) * ]
    if `"`ci2'"'!="" {
        local ci ci
    }
    if "`ci'"!="" {
        local ci2 pstyle(ci) `ci2'
    }
    c_local fpci `ci'
    c_local fpfit2 `ci2' `options'
end

program _rcspline // loosely following -rcspline- by Nick Cox
    syntax varlist(numeric min=2 max=2)  [if] [in] [fw aw iw pw], gen(str) [ ///
        NKnots(passthru) Knots(passthru) DIsplayknots regressopts(str) ///
        CI CI2(str asis) Level(cilevel) * ]
    if `"`ci2'"'!=""    {
        local ci ci
    }
    if "`ci'"!="" {
        local ci2 pstyle(ci) `ci2'
    }
    c_local rcci `ci'
    c_local rcci2 `ci2'
    c_local rcspline2 `options'

    gettoken y x : varlist
    gettoken pred gen : gen
    gettoken ci_l gen : gen
    gettoken ci_u gen : gen

    tempname hcurrent
    _est hold `hcurrent', restore

    marksample touse
    tempname stub
*    mkspline `stub' = `x' if `touse' [`weight'`exp'], cubic `nknots' `knots' `displayknots'
    cubicspline `stub' = `x' if `touse' [`weight'`exp'], `nknots' `knots' `displayknots'
    qui regress `y' `stub'* if `touse' [`weight' `exp'] , `regressopts'
    qui predict `pred' if e(sample)
    if "`ci'"!="" {
        tempvar se
        qui predict `se' if e(sample), stdp
        local z = invttail(e(df_r), (100 - `level') / 200)
        qui gen `ci_l' = `pred' - `z' * `se'
        qui gen `ci_u' = `pred' + `z' * `se'
    }
end

program _pspline
    syntax varlist(numeric min=2 max=2) [if] [in] [fw aw iw pw], gen(str) [ ///
        Degree(passthru) NKnots(passthru) Knots(passthru) ESTOPts(passthru) noPENalty ///
        * ]
    c_local pspline2 `options'

    tempname hcurrent
    _est hold `hcurrent', restore

    qui pspline `varlist' `if' `in' [`weight' `exp'], ///
        nograph gen(`gen') ///
        `degree' `nknots' `knots' `estopts' `penalty'
end

program _rspline
    syntax varlist(numeric min=2 max=2) [if] [in] [fw aw iw pw], gen(str) [ ///
        ALpha(passthru) DEGree(passthru) df(passthru) KNots(passthru) regressopts(str) ///
        CI CI2(str asis) Level(cilevel) * ]
    if `"`ci2'"'!="" {
        local ci ci
    }
    if "`ci'"!="" {
        local ci2 pstyle(ci) `ci2'
    }
    c_local rsci `ci'
    c_local rsci2 `ci2'
    c_local rspline2 `options'

    gettoken y x : varlist
    gettoken pred gen : gen
    gettoken ci_l gen : gen
    gettoken ci_u gen : gen

    tempname hcurrent
    _est hold `hcurrent', restore

    tempname X
    qui gen `X' = `x' // so that variables added by -uvrs- are dropped

    qui uvrs regress `y' `X' `if' `in' [`weight' `exp'], ///
        `alpha' `degree' `df' `knots' `regressopts'
    qui fracpred `pred'
    if "`ci'"!="" {
        tempvar se
        qui fracpred `se', stdp
        local z = invttail(e(df_r), (100 - `level') / 200)
        qui gen `ci_l' = `pred' - `z' * `se'
        qui gen `ci_u' = `pred' + `z' * `se'
    }
end

program _running
    syntax varlist(numeric min=2 max=2) [if] [in] [fw aw iw pw], gen(str) [ ///
        Double Knn(passthru) Mean Repeat(passthru) SPan(passthru) TWice  ///
        CI CI2(str asis) Level(cilevel) * ]

    if `"`ci2'"'!="" {
        local ci ci
    }
    if "`ci'"!="" {
        local ci2 pstyle(ci) `ci2'
    }
    c_local runningci `ci'
    c_local runningci2 `ci2'
    c_local running2 `options'

    gettoken pred gen : gen
    gettoken ci_l gen : gen
    gettoken ci_u gen : gen

    if "`ci'"!="" {
        tempvar se
        local gense gense(`se')
    }
    qui running `varlist' `if' `in' [`weight' `exp'], ///
        nograph generate(`pred') `gense' ///
        `double' `knn' `mean' `repeat' `span' `twice'
    if "`ci'"!="" {
        local z = invnormal(1 - (100 - `level') / 200)
        qui gen `ci_l' = `pred' - `z' * `se'
        qui gen `ci_u' = `pred' + `z' * `se'
    }
end

program _autosmoo
    syntax varlist(numeric min=2 max=2) [if] [in] [fw aw iw pw], gen(str) [ ///
        kmin(passthru) kmax(passthru) Repeat(passthru)  ///
         * ]
    c_local autosmoo2 `options'
    qui autosmoo `varlist' `if' `in' [`weight' `exp'], ///
        nograph gen(`gen') ///
        `kmin' `kmax' `repeat'
end


* based on code from mkspline.ado by StataCorp, version 1.2.3, 14may2007
* adapted to allow pweights
* - without weights: -altdef- formula => same as mkspline
* - with fweight: standard formula    => possibly different than mkspline (?)
* - with pweight: standard formula    => not supported in mkspline
program define cubicspline, rclass sortpreserve
    version 6, missing
    gettoken name 0 : 0, parse(" =")
    gettoken eqsign : 0, parse(" =")
    gettoken eqsign 0 : 0, parse(" =")
    syntax varname [if] [in] [fweight pweight] [, ///
        NKnots(numlist max=1) Knots(numlist) DIsplayknots ]

    marksample touse

    if "`nknots'"!="" {
        local nk `nknots'
    }
    else {
        local nk=5
    }
    if "`knots'"!="" {
        local nc 0
        tokenize "`knots'"
        while "`1'" != "" {
            local nc = `nc' + 1
            local t`nc' "`1'"
            mac shift
        }
    }
    if "`nknots'"!="" & "`knots'"=="" {
        local nc `nk'
    }
    if "`nknots'"=="" & "`knots'"!="" {
        local nk `nc'
    }

    if "`nknots'"!="" & "`knots'"!="" {
        if `nc' != `nk' {
            display as error ///
"Count in nknots must be the same as the number of knots specified."
            error 498
        }
    }

    sort `varlist'

    if "`knots'"!="" {
        if `nc' < 2 {
            display as error ///
"Restricted cubic splines must have at least 2 knots."
            error 498
        }
        local prevt=`t1'
        local j=2
        while `j'<=`nk' {
            if `t`j'' <= `prevt' {
                disp as error ///
                "Knots must be in increasing order."
                error 498
            }
            local prevt=`t`j''
            local j=`j'+1
        }
    }
    else {
        local altdef altdef
        if "`weight'"!="" {
            local altdef
            if "`weight'"=="pweight" {
                local suwgt "aweight"
            }
            else {
                local suwgt "`weight'"
            }
        }
        if `nk' == 3 {
            _pctile `varlist' if `touse' [`weight' `exp'], ///
                percentiles(10 50 90) `altdef'
        }
        else if `nk'== 4 {
            _pctile `varlist' if `touse' [`weight' `exp'], ///
                percentiles(5 35 65 95) `altdef'
        }
        else if `nk'== 5 {
            _pctile `varlist' if `touse' [`weight' `exp'], ///
                percentiles(5 27.5 50 72.5 95) `altdef'
        }
        else if `nk'== 6 {
            _pctile `varlist' if `touse' [`weight' `exp'], ///
                percentiles(5 23 41 59 77 95) `altdef'
        }
        else if `nk'== 7 {
            _pctile `varlist' if `touse' [`weight' `exp'], ///
                percentiles(2.5 18.33 34.17 50 65.83 81.67 97.5) `altdef'
        }
        else    {
            display as error ///
"Restricted cubic splines with `nk' knots at default values not implemented."
            display as error ///
"Number of knots specified in nknots() must be between 3 and 7."
            error 498
        }

        forvalues i=1 / `nk' {
            local t`i' = r(r`i')
        }

        qui sum `varlist' [`suwgt' `exp'], meanonly
        local cenmin = 5/(r(N)+1)*100
        local cenmax = (r(N)-4)/(r(N)+1)*100
        _pctile `varlist' if `touse' [`weight' `exp'], ///
            percentiles(`cenmin' `cenmax') `altdef'
        local min = r(r1)
        local max = r(r2)

        if `t1' < `min' {
            local t1 = `min'
        }

        if `t`nk'' > `max'  {
            local t`nk' = `max'
        }
    }

    local j = 1
    matrix loc = J(1,`nk',0)
    local col ""
    while `j' <= `nk' {
        mat loc[1,`j'] = `t`j''
        local col "`col' knot`j'"
        local j = `j'+1
    }
    mat colnames loc = `col'
    matrix rownames loc = "`varlist'"

    local km1 = `nk' - 1
    if `t1' >= `t2' | `t`nk'' <= `t`km1''  {
        display as error ///
            "Sample size too small for this many knots."
        error 198
    }

    qui gen `name'1=`varlist' if `touse'

    local j = 1
    while `j' <= `nk' {
        qui gen _Xm`j' = `varlist' - `t`j''
        uplus _Xm`j'  _Xm`j'p
        local j = `j'+1
    }

    local j = 1
    while `j' <= `nk' -2 {
        local jp1 = `j' + 1
        qui gen `name'`jp1' = (_Xm`j'p^3 - (_Xm`km1'p^3)* ///
            (`t`nk''   - `t`j'')/(`t`nk'' - `t`km1'') ///
            + (_Xm`nk'p^3  )*(`t`km1'' - `t`j'')/ ///
            (`t`nk'' - `t`km1'')) / (`t`nk'' - `t1')^2 ///
            if `touse'
        local j = `j' + 1
    }

    drop _Xm* _Xm*p

    if "`displayknots'"!="" {
        matlist loc
    }
    return scalar N_knots = `nk'
    return matrix knots loc
end
program define uplus
    version 7
    args u uplus
    qui gen `uplus' = `u'
    quietly replace `uplus' = 0 if `u' <= 0
end
