*! version 1.0.0  28jun2007  Ben Jann

program _digdis
    version 9.2
    gettoken subcmd 0 : 0, parse(", ")
    local length = length(`"`subcmd'"')
    if `"`subcmd'"'==substr("extract",1,max(`length',1)) {
        digdis_extract`0'
        //  digdis extract varlist [if] [in] [,
        //      Position(integer 1) Base(integer 10) Decimalplaces(integer -1)
        //      Generate(name) Replace ]
    }
    else if `"`subcmd'"'==substr("tabulate",1,max(`length',1)) {
        digdis_tabulate`0'
        //  digdis tabulate varlist [if] [in] [fw] [,
        //      Position(integer 1) Base(integer 10)
        //      BENford UNIform MATrix(name) by(varname)
    }
    else if `"`subcmd'"'=="test" {
        digdis_test`0'
        //  digdis test [, mgof_options ]
    }
    else if `"`subcmd'"'=="ci" {
        digdis_ci`0'
        //  digdis ci [, REFerence cii_options ]
    }
    else if `"`subcmd'"'=="save" {
        digdis_save`0'
        //  digdis save [namelist] [, PERcent FRACtion count Replace ]
        //  default namelist: [_grp] _val _obs _exp [_lb _ub]
    }
    else if `"`subcmd'"'==substr("graph",1,max(`length',2)) {
        digdis_graph`0'
        //  digdis graph [,
        //      noci CIOPTs(str asis) noref REFOPTs(str asis)
        //      addplot(str asis) BYOPTs(str asis)
        //      twoway_bar_options twoway_options ]
    }
    else {
        di as err `"`subcmd' invalid subcommand"'
        exit 198
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

program define digdis_extract
    syntax varlist(min=1) [if] [in] [, Generate(namelist) Replace * ]
    if "`replace'"=="" & "`generate'"!="" {
        confirm new var `generate'
    }
    local tmpvars
    foreach var of local varlist {
        tempvar tmp
        local tmpvars `tmpvars' `tmp'
        _digdis_extract `var' `if' `in' , ///
            generate(`tmp') `options'
    }
    local i 0
    foreach new of local generate {
        local var: word `++i' of `tmpvars'
        Vreturn "`var'" "`new'" `replace'
    }
end

program define _digdis_extract, rclass
    syntax varname [if] [in] , Generate(name) [  ///
        Position(integer 1) Base(integer 10) Decimalplaces(integer -1) ]
    local p "`position'"
    local M 6 // 1st through 6th position supported
    if `p'<1 | `p'>`M' {
        di as err "position() must be in [1,`M']"
        exit 198
    }
    if !inrange(`base',2,10) {
        di as err "base() must be in [2,10]"
        exit 198
    }
    local dmax = `base'-1

// generate variable containing digit
    marksample touse, strok
    tempvar temp
    local type: type `varlist'
    if substr("`type'",1,3)=="str" {
        local decimalplaces -1
        // trim and remove sign
        qui gen str `temp' = regexr(trim(`varlist'),"^[-+]","") if `touse'
        // remove decimal marker
        qui replace `temp' = regexr(`temp',"[.,]","") if `touse'
        // remove exponent
        qui replace `temp' = regexr(`temp',"([eE][-+]?[0-9]+)$","") if `touse'
        // remove leading zeros
        qui replace `temp' = regexr(`temp',"^[0]+","") if `touse'
    }
    else {
        if inlist("`type'","byte","int","long") local decimalplaces 0
        if inlist("`type'","byte","int") {
            qui gen str `temp' = string(abs(`varlist'),"%9.0g") if `touse'
        }
        else {
        // the difficulty is to prevent Stata from rounding; the approach
        // used here is to scale all numbers to have `p' (or sometimes
        // `p'+1 due to limited precision) digits and then cut off the
        // decimal places
            if `decimalplaces'>=0  {
                qui gen str `temp' = string( ///
                    int(abs(round(`varlist',10^-`decimalplaces')) * ///
                    10^min(`decimalplaces',(`p'-1)-floor(log10(abs(`varlist'))))), ///
                    "%`=`p'+3'.0g") if `touse'
                // due to limited precision some resulting numbers will have `p'+1 digits
            }
            else {
                qui gen str `temp' = string(int(abs(`varlist') * ///
                    10^((`p'-1)-floor(log10(abs(`varlist'))))), ///
                    "%`=`p'+3'.0g") if `touse'
            }
        }
    }
    // select digit
    qui gen byte `generate' = real(substr(`temp',`p',1)) if `touse'
    // remove if 0 or #>dmax or not numeric
    qui replace `generate' = . if regexm(`temp',"^[1-`dmax'][0-`dmax']*$")==0 & `touse'
    drop `temp'
    local N0 0
    qui count if `generate'>=. & `touse'
    if r(N)>0 {
        local N0 = r(N)
        di as err "`varlist': `N0' invalid observation" cond(`N0'==1,"","s")
    }
    local th = cond(`p'==1,"st",cond(`p'==2,"nd",cond(`p'==3,"rd","th")))
    lab var `generate' "`p'`th' digit from `varlist'"

// returns
    if (`decimalplaces'>=0) ret sca dp = `decimalplaces'
    ret sca base = `base'
    ret sca position = `p'
    ret sca N_invalid = `N0'
end

program define digdis_tabulate, rclass
    syntax varlist(numeric min=1) [if] [in] [fw] [, ///
        by(varname) BENford ///
        origvarnames(str) /// undocumented
        * ]
    local nvar: list sizeof varlist
    if `nvar'>1 & "`by'"!="" {
        di as err "only one variable allowed if by() is specified"
        exit 198
    }

    if `nvar'==1 & "`by'"=="" {
        _digdis_tabulate `varlist' `if' `in' [`weight'`exp'] , `benford' `options'
        ret local cmd "digdis"
        return add
        exit
    }

    if "`by'"!="" {
        marksample touse
        markout `touse' `by'
        qui levelsof `by', local(levels)
    }
    else {
        marksample touse, novarlist
        local levels "`varlist'"
    }
    local dist `benford'
    tempname distmat N mad count pvals tmp
    local i = 0
    foreach l of local levels {
        di as txt _n "{hline}"
        if "`by'"=="" {
            local var "`l'"
            local ifby
            gettoken lab origvarnames : origvarnames
            if "`lab'"=="" local lab "`var'"
            di "-> `lab'"
        }
        else {
            local var "`varlist'"
            local ifby "& `by'==`l'"
            local lab "`l'"
            di "-> `by' = `l'"

        }
        _digdis_tabulate `var' if `touse'`ifby' [`weight'`exp'] , ///
            `dist' `origvarname' `options'
        if r(N)==0 continue
        foreach mat in N mad pvals {
            mat `tmp' = r(`mat')
            mat coln `tmp' = `lab'
            mat ``mat'' = nullmat(``mat''), `tmp'
        }
        mat `tmp' = r(count)
        mat coleq `tmp' = `"`lab'"' `"`lab'"'
        mat `count' = nullmat(`count'), `tmp'
        if (`++i')==1 {
            local p = r(position)
            local base = r(base)
            local refdist "`r(refdist)'"
            if "`refdist'"=="Benford" {
                mat `distmat' = r(count)
                mat `distmat' = `distmat'[1...,2]
                local dist "matrix(`distmat')"
            }
        }
    }
    ret local cmd "digdis"
    if "`by'"!="" {
        ret local byvar "`by'"
    }
    if `i'>0 {
        ret local refdist "`refdist'"
        ret sca base = `base'
        ret sca position = `p'
        ret mat pvals = `pvals'
        ret mat count = `count'
        ret mat mad = `mad'
        ret mat N = `N'
    }
end

program define _digdis_tabulate, rclass
    syntax varname(numeric) [if] [in] [fw] [,   ///
        Position(integer 1) Base(integer 10)    ///
        BENford UNIform MATrix(name) ]
    if "`uniform'"!="" & "`benford'"!="" & "`matrix'"!="" {
        di as err "only one allowed of uniform, benford, and matrix()"
        exit 198
    }
    local p "`position'"
    local M 6 // 1st through 6th position supported
    if `p'<1 | `p'>`M' {
        di as err "position() must be in [1,`M']"
        exit 198
    }
    if !inrange(`base',2,10) {
        di as err "base() must be in [2,10]"
        exit 198
    }
    local dmax = `base'-1
    local dmin = cond(`p'==1,1,0)

// count digits
    marksample touse
    tempname vals count
    qui ta `varlist' if `touse' [`weight'`exp'], ///
        nofreq matrow(`vals') matcell(`count')
    local N = r(N)
    if `N'==0 {
        di as txt "no observations"
        return scalar N = 0
        exit
    }

// compile matrix containing observed and expected counts
    tempname res
    local r = `dmax'-`dmin'+1
    if "`uniform'"!="" {
        matrix `res' = J(`r',1,`N'/`r')
    }
    else if "`matrix'"!="" {
        matrix `res' = `matrix'[1...,1]
        if rowsof(`res')<`r' {
            matrix `res' = `res' \ J(`r'-rowsof(`res'),1,0)
        }
        mata: norm_mat("`res'",`N')
    }
    else /*if "`benford'"!=""*/ {
        mata: st_matrix("`res'", `N' * mm_benford(`dmin'::`dmax',`p',`base'))
    }
    local rown
    forv i = `dmin' / `dmax' {
        local rown "`rown'`i' "
    }
    mat `res' = J(`r',1,0), `res'
    mat rown `res' = `rown'
    mat coln `res' = "observed" "expected"
    forv i = 1 / `=rowsof(`vals')' {
        local r = rownumb(`res',"`=`vals'[`i',1]'")
        capt assert `r'<.
        if _rc {
            di as err "invalid input variable: contains `=`vals'[`i',1]'"
            exit 498
        }
        mat `res'[`r',1] = `count'[`i',1]
    }
    mat drop `vals' `count'

// perform individual tests
    tempname pvals
    _digdis_bitest `res' `N' `pvals'

// compute mean abs deviation in percentages
    tempname mad
    mata: st_numscalar("`mad'", mean(abs(st_matrix("`res'")*(1\-1)/`N'),1)*100)

// display results
    local refdist = cond("`uniform'"!="", "uniform", ///
        cond("`matrix'"!="", "user", "Benford"))
    di as txt ""
    di as txt "Digit distribution (" _c
    di as res "`p'" cond(`p'==1,"st",cond(`p'==2,"nd",cond(`p'==3,"rd","th"))) _c
    di as txt " digit)"
    _digdis_tab `res' `N' `pvals' `mad'

// return results
    ret local refdist "`refdist'"
    ret sca mad = scalar(`mad')
    ret sca base = `base'
    ret sca position = `p'
    ret sca N = `N'
    ret mat pvals = `pvals'
    ret mat count = `res'
end

prog _digdis_bitest // return matrix containing p-values
    args res N pvals
    local r = rowsof(`res')
    mat `pvals' = `res'[1...,1] * .
    mat coln `pvals' = p
    forv i = 1 / `r' {
        capt bitesti `N' `=`res'[`i',1]' `=`res'[`i',2]/`N''
        if _rc mat `pvals'[`i',1] = .
        else mat `pvals'[`i',1] = r(p)
    }
end

prog _digdis_tab
    args res N pvals mad
    local lhs 12
    di as txt ""
    di as txt %`lhs's "Value" " {c |}"  %10s "Count" %11s "Percent" ///
        %11s "Percent" %11s "Diff." %11s "P-value"
    di as txt %`lhs's "" " {c |}"  %10s "" %11s "Observed" ///
        %11s "Expected" %11s "(MAD)" %11s ""
    di as txt "{hline `lhs'}{hline 1}{c +}{hline 10}{hline 33}{hline 11}"
    local labels: rown `res'
    forv i = 1 / `=rowsof(`res')' {
        local p = el(`pvals',`i',1)
        di as txt %`lhs's "`:word `i' of `labels''" " {c |}"        ///
            " "  as res %9.0g el(`res',`i',1)                       ///
            "  " as res %9.3f el(`res',`i',1)/`N'*100               ///
            "  " %9.3f el(`res',`i',2)/`N'*100                      ///
            "  " %9.3f (el(`res',`i',1)-el(`res',`i',2))/`N'*100    ///
            "  " %9.4f `p'
    }
    di as txt "{hline `lhs'}{hline 1}{c +}{hline 10}{hline 33}{hline 11}"
    di as txt %`lhs's "Total" " {c |} " as res %9.0g `N' ///
        "  " %9.3f 100 "  " %9.3f 100 "  " %9.3f scalar(`mad')
end

program define digdis_test, rclass
    syntax [, * ]
    if `"`r(cmd)'"'!="digdis" {
        di as err "digdis results not found"
        exit 498
    }
    capt confirm matrix r(count)
    if _rc { // nothing to do
        return add
        exit
    }

// if only one variable/one group
    capt confirm matrix r(N)
    if _rc {
        tempname tmp
        matrix `tmp' = r(count)
        return add
        mgof, matrix(`tmp') `options'
        foreach stat in `r(stats)' {
            ret sca `stat' = r(`stat')
            ret sca p_`stat' = r(p_`stat')
        }
        exit
    }

// if multiple variables/multiple groups
    tempname tmp tmp2 N
    mat `N' = r(N)
    matrix `tmp' = r(count)
    local by "`r(byvar)'"
    return add
    local nby = colsof(`tmp')
    tempname tmp2
    forv i=1(2)`nby' {
        matrix `tmp2' = `tmp'[1...,`i'..`i'+1]
        qui mgof, matrix(`tmp2') `options'
        local stats "`r(stats)'"
        foreach stat of local stats {
            if `i'==1 tempname v_`stat' p_`stat'
            mat `v_`stat'' = nullmat(`v_`stat''), r(`stat')
            mat `p_`stat'' = nullmat(`p_`stat''), r(p_`stat')
        }
    }

// display
    if "`by'"=="" local by "Variable"
    di _n as txt "Goodness-of-fit tests"
    di _n as txt %12s "`by'" " {c |}" %10s "Obs." _c
    foreach stat of local stats {
        di %11s upper("`stat'") %11s "P-value" _c
    }
    di _n as txt "{hline 13}{c +}{hline 10}" _c
    foreach stat of local stats {
        di "{hline 22}" _c
    }
    local coln: colnames `N'
    local i 0
    foreach name of local coln {
        local ++i
        di _n as txt %12s "`name'" " {c |}" " " as res %9.0g `N'[1,`i']  _c
        foreach stat of local stats {
            di "  " %9.0g `v_`stat''[1,`i'] "  " %9.4f `p_`stat''[1,`i'] _c
        }
    }
    di

// return
    foreach stat of local stats {
        mat coln `v_`stat'' = `coln'
        mat coln `p_`stat'' = `coln'
        ret mat `stat' = `v_`stat''
        ret mat p_`stat' = `p_`stat''
    }
end

prog digdis_ci, rclass
    syntax [, Level(cilevel) REFerence EXAct WAld Wilson Agresti Jeffreys ]
    local citype = trim("`exact' `wald' `wilson' `agresti' `jeffreys'")
    if "`citype'"=="" local citype "exact"
    if `"`r(cmd)'"'!="digdis" {
        di as err "digdis results not found"
        exit 498
    }
    capt confirm matrix r(count)
    if _rc { // nothing to do
        return add
        exit
    }
    tempname N count tmp ci
    mat `N' = r(N)
    mat `count' = r(count)
    mat `ci' = `count'*0
    return add
    local nby = colsof(`N')
    local r = rowsof(`ci')
    local coln
    forv i = 1/`nby' {
        local coln "`coln' lb ub"
        local b = `i'*2
        local a = `b' - 1
        if "`reference'"=="" {
            forv j=1/`r' {
                qui cii `=el(`N',1,`i')' `=el(`count',`j',`a')' , ///
                    level(`level') `citype'
                mat `ci'[`j',`a'] = r(lb)*`N'[1,`i']
                mat `ci'[`j',`b'] = r(ub)*`N'[1,`i']
            }
        }
        else {
            forv j=1/`r' {
                mata: st_matrix("`tmp'", ///
                    digdis_refbounds(`=el(`N',1,`i')', ///
                    `=el(`count',`j',`b')',`level'))
                mat `ci'[`j',`a'] = `tmp'[1,1]
                mat `ci'[`j',`b'] = `tmp'[1,2]
            }
            local citype "reference"
        }


    }
    mat coln `ci' = `coln'
    ret local citype "`citype'"
    ret sca level = `level'
    ret mat ci = `ci'
end

prog digdis_save, rclass
    syntax [namelist] [, PERcent FRACtion count Replace ]
      //  namelist = [_grp] _val _obs _exp [_lb _ub]
    if `"`r(cmd)'"'!="digdis" {
        di as err "digdis results not found"
        exit 498
    }
    if ("`fraction'"!="") + ("`count'"!="") + ("`percent'"!="") > 1 {
        di as err "only one allowed of percent, fraction, and count"
        exit 198
    }
    if "`fraction'`count'"=="" local percent percent
    capt confirm matrix r(count)
    if _rc { // nothing to do
        exit
    }
    if "`replace'"=="" & "`namelist'"!="" {
        confirm new var `namelist'
    }
    mata: digdis_save() // sets local tmpvars
    local namelist0 _val _obs _exp _lb _ub
    capt confirm matrix r(N)
    if _rc==0 {
        local namelist0 "_grp `namelist0'"
    }
    local savenames
    local i 0
    foreach old of local tmpvars {
        local new: word `++i' of `namelist'
        if "`new'"=="" {
            local new: word `i' of `namelist0'
        }
        Vreturn "`old'" "`new'" `replace'
        local savenames `savenames' `new'
    }
    return add
    ret local savenames `savenames'
    ret local savescale = cond("`percent'"!="", "percent", ///
        cond("`fraction'"!="","fraction","count"))
end

prog digdis_graph
    syntax [, ///
        BARWidth(real .5) ///
        noci CIOPTs(str asis) ///
        noref REFOPTs(str asis) ///
        addplot(str asis) ///
        BYOPTs(str asis) * ]
    if `"`r(cmd)'"'!="digdis" {
        di as err "digdis results not found"
        exit 498
    }
    capt confirm matrix r(count)
    if _rc { // nothing to do
        exit
    }
    if `"`r(savenames)'"'=="" {
        di as err "digdis varnames not found"
        exit 498
    }
    local savenames `r(savenames)'
    capt confirm matrix r(N)
    if _rc==0 {
        gettoken byvar savenames : savenames
    }
    gettoken valvar savenames : savenames
    gettoken obsvar savenames : savenames
    gettoken expvar savenames : savenames
    if `"`savenames'"'!="" {
        gettoken lbvar savenames : savenames
        gettoken ubvar savenames : savenames
    }
    local yti = proper(r(savescale))
    if "`yti'"=="Fraction" local yti "Proportion"
    local citype "`r(citype)'"

    tempname hcurrent
    _return hold `hcurrent'

    sum `valvar', mean
    local range "`r(min)'/`r(max)'"
    local BarGraph ( bar `obsvar' `valvar', barwidth(`barwidth') ///
        legend(off) xlabel(`range') yti("`yti'") xti("Digits") ///
        ylabel(0, add) `options' )
    if `"`lbvar'"'!="" & "`ci'"=="" {
        if `"`citype'"'=="reference" {
            local CIGraph ( rconnected `lbvar' `ubvar' `valvar', `ciopts' )
        }
        else {
            local CIGraph ( rcap `lbvar' `ubvar' `valvar', `ciopts' )
        }
    }
    if "`ref'"=="" {
        local RefGraph ( connected `expvar' `valvar', `refopts' )
    }
    if `"`byvar'"'!="" {
        local ByGraph || , by(`byvar', legend(off) note("") `byopts')
    }
    capt n twoway `BarGraph' `CIGraph' `RefGraph' || `addplot' `ByGraph'

    _return restore `hcurrent'
    exit _rc
end

version 9.2
mata:
mata set matastrict on

void norm_mat(string scalar name, real scalar N)
{
    real colvector m

    m = st_matrix(name)
    st_matrix(name, m * ( N / colsum(m) ))
}

real rowvector digdis_refbounds(
    real scalar n, // n of cases
    real scalar k, // exp count
    real scalar l) // confidence level
{
    real scalar     a, ub, lb, p_lb, lb1, p_ub, ub1

    if (n<1)                _error(3300)
    if (k<0|k>n)            _error(3300)
    if (missing((n,k,l)))   _error(3351)

    if (l>=1)               a = (100-l)/200
    else                    a = (1-l)/2
    if (a<=0 | a>=.5)       _error(3300)

    // lower bound
    lb =  ceil(100*invbinomial(n,  ceil(k), a)) // first guess
    while ((1 - Binomial(n, lb, k/n)) <= a) lb++
    while ((1 - Binomial(n, lb, k/n)) > a)  lb--

    // upper bound
    ub = floor(100*invbinomial(n, floor(k), 1-a)) // first guess
    while (Binomial(n, ub+1, k/n) <= a) ub--
    while (Binomial(n, ub+1, k/n) > a)  ub++

    assert((1 - Binomial(n, lb, k/n)) < a)
    assert(Binomial(n, ub+1, k/n) < a)

    // refine interval
    lb1 = lb
    while ((Binomial(n, lb1+1, k/n)-Binomial(n, ub+1, k/n)) ///
        >= (1-2*a)) lb1++
    ub1 = ub
    while ((Binomial(n, lb, k/n)-Binomial(n, ub1, k/n)) ///
        >= (1-2*a)) ub1--

    p_lb = Binomial(n, lb1, k/n)-Binomial(n, ub+1, k/n)
    p_ub = Binomial(n, lb, k/n)-Binomial(n, ub1+1, k/n)

    assert(p_lb>=(1-2*a) & p_ub>=(1-2*a))

    if (p_lb<p_ub)      lb = lb1
    else if (p_ub<p_lb) ub = ub1

    // interval must include k
    if (lb==ub) {
        if (lb>k) lb--
        else if (ub<k) ub++
    }

    assert((Binomial(n, lb, k/n)-Binomial(n, ub+1, k/n))>=(1-2*a))

    return(lb,ub)
}

void digdis_save()
{
    real scalar     j, a, b, percent, fraction, idby, idval,
                    idobs, idexp, idlb, idub, scale
    real matrix     count, values, ci, N
    string vector   by, names

// settings
    percent = st_local("percent")!=""
    fraction = (percent==0 & st_local("fraction")!="")

// collect results
    count = st_matrix("r(count)")
    values = strtoreal(st_matrixrowstripe("r(count)")[,2])
    if (cols(count)>2) {
        N = st_matrix("r(N)")
        by = st_matrixcolstripe("r(N)")[,2]
        if (st_global("r(byvar)")!="")
            by = st_global("r(byvar)") + " = " :+ by
    }
    else {
        N = st_numscalar("r(N)")
        by = ""
    }
    ci = st_matrix("r(ci)")

// initialize variables
    if (by!="") {
        idby = st_addvar(max(strlen(by)),st_tempname())
    }
    idval = st_addvar("byte",st_tempname())
    idobs = st_addvar("double",st_tempname())
    idexp = st_addvar("double",st_tempname())
    if (rows(ci)>0) {
        idlb = st_addvar("double",st_tempname())
        idub = st_addvar("double",st_tempname())
    }

// loop over by
    a = 1
    for (j=1;j<=length(by);j++) {
        b = a - 1 + rows(count)
        if (b>st_nobs()) st_addobs(b-st_nobs())
        if (fraction) scale = 1 / N[j]
        else if (percent) scale = 100 / N[j]
        else scale = 1
        if (by!="") {
            st_sstore((a,b), idby, J(rows(count),1,by[j]))
        }
        st_store((a,b), idval, values)
        st_store((a,b), idobs, count[,j*2-1]*scale)
        st_store((a,b), idexp, count[,j*2]*scale)
        if (rows(ci)>0) {
            st_store((a,b), idlb, ci[,j*2-1]*scale)
            st_store((a,b), idub, ci[,j*2]*scale)
        }
        a = b + 1
    }

// return names
    names = st_varname((idval,idobs,idexp))
    if (by!="") {
        names = st_varname(idby), names
    }
    if (rows(ci)>0) {
        names = names, st_varname((idlb,idub))
    }
    st_local("tmpvars",mm_invtokens(names))
}

end
