*! version 1.1.2  22aug2014  Ben Jann, Jennie E. Brand, Yu Xie

program hte
    version 10
    local caller : di _caller()
    gettoken subcmd 0 : 0
    if inlist(`"`subcmd'"', "sm", "ms", "sd") {
        version `caller': hte_`subcmd' `0'
    }
    else {
        di as err `"`subcmd' is not a valid subcommand;"' _c
        di as err " must type {cmd:hte sm}, {cmd:hte ms}, or {cmd:hte sd}"
        exit 198
    }
end

/* SM ---------------------------------------------------------------------- */

program hte_sm, rclass
    version 9.2
    syntax [anything(equalok)] [if] [in] [fw iw pw] [, * ]
    if replay() {
        hte_sm_tabulate `0'
        exit
    }
    gettoken first second : anything
    local flen = strlen(`"`first'"')
    if `"`first'"'==substr("graph",1,max(2,`flen')) & `"`second'"'=="" {
        hte_sm_graph `if' `in' [`weight'`exp'], `options'
        exit
    }
    hte_sm_compute `anything' `if' `in' [`weight'`exp'], `options'
end

program hte_sm_graph
    syntax [, Level(cilevel) Outcomes(numlist integer min=1) noCI * ]
    local z = invnorm((100+`level')/200)

    if `"`e(cmd)'"'!="hte sm" {
        di as err "hte sm results not found"
        exit 301
    }

    _get_gropts , graphopts(`options') getallowed(LINEOPts CIOPts plot addplot)
    local options `"`s(graphopts)'"'
    local lineopts `"`s(lineopts)'"'
    local ciopts `"`s(ciopts)'"'
    _check4gropts lineopts, opt(`lineopts')
    _check4gropts ciopts, opt(`ciopts')
    local plot `"`s(plot)'"'
    local addplot `"`s(addplot)'"'

    tempname b se block lfit coefs tmp
    mat `b'     = e(b)
    mat `se'    = e(se)
    mat `block' = e(block)
    mat `lfit'  = e(lfit)
    local neq   = e(neq)
    if "`outcomes'"=="" {
        if `neq'==1 local outcomes "_"
        else {
            numlist "1/`neq'"
            local outcomes "`r(numlist)'"
        }
    }
    else if `neq'==1 {
        local outcomes: subinstr local outcomes "1" "_", word all
    }
    foreach eq of local outcomes {
        mat `tmp' = `b'[1...,`"`eq':"']', `se'[1...,`"`eq':"']' // => error if outcome not found
        mat `tmp' = `tmp'[1..rowsof(`tmp')-2,1...], ///
            `block'[1...,`"`eq':"']', `lfit'[1...,`"`eq':"']'
        mat `coefs' = nullmat(`coefs') \ `tmp'
    }
    tempname B SE ID FIT touse
    mat coln `coefs' = `B' `SE' `ID' `FIT'
    svmat `coefs', names(col)
    qui gen byte `touse' = `ID'<.

    local depvar `"`e(depvar)'"'
    local ndepvar : list sizeof depvar
    local hasby = (`"`e(byvar)'"'!="")
    if `:list sizeof outcomes'==1 {
        local Bvars   `B'
        local FITvars `FIT'
        lab var `B'     "TE within strata"
        lab var `FIT'   "linear trend"
        if "`ci'"==""   {
            tempname LB UB
            qui gen `LB' = `B' - `z'*`SE'
            qui gen `UB' = `B' + `z'*`SE'
            local CIgraph (rcap `LB' `UB' `ID' if `touse', `ciopts')
            local legend legend(label(1 "`level'% CI"))
        }
        local title
        if `neq'>1 {
            if `ndepvar'>1 {
                local title `"`e(depvar`outcomes')'"'
                if `hasby' {
                    local title `"`title': "'
                }
            }
            if `hasby' {
                local title `"`title'`e(byvar)' = `e(by`outcomes')'"'
            }
            local title `"title(`title')"'
            local trend subtitle(`"`e(trend`outcomes')'"')
        }
        else {
            local trend subtitle(`"`e(trend)'"')
        }
    }
    else {
        local eqlist: roweq `coefs'
        local k = rowsof(`coefs')
        tempname by
        qui gen byte `by' = .
        forv i = 1/`k' {
            gettoken eq eqlist : eqlist
            qui replace `by' = `eq' in `i'
        }
        local i 0
        foreach eq of local outcomes {
            local ++i
            tempname B_`i' FIT_`i' LB_`i' UB_`i'
            qui gen `B_`i''   = `B'     if `by'==`eq'
            qui gen `FIT_`i'' = `FIT'   if `by'==`eq'
            local eqlab
            if `ndepvar'>1 {
                local eqlab `"`e(depvar`eq')'"'
                if `hasby' {
                    local eqlab `"`eqlab': "'
                }
            }
            if `hasby' {
                local eqlab `"`eqlab'`e(byvar)' = `e(by`eq')'"'
            }
            lab var `B_`i''   `"`eqlab'"'
            lab var `FIT_`i'' `"`eqlab'"'
            local Bvars   `Bvars' `B_`i''
            local FITvars `FITvars' `FIT_`i''
            local pstyles `pstyles' p`i'
            local legend `legend' `=`neqs'+`i''
        }
        local pstyles pstyle(`pstyles')
        local legend legend(order(`legend'))
    }
    su `ID', mean
    local xlabel "xlabel(1(1)`r(max)')"
    if r(max)==1 local xlabel // fix stata graph bug

    local Lgraph (line `FITvars' `ID' if `touse', `pstyles' `lineopts')
    graph twoway                                    ///
        `CIgraph'                                   ///
        (scatter `Bvars' `ID' if `touse',           ///
            `pstyles'                               ///
            `xlabel'                                ///
            xvarlabel("Propensity Score Strata")    ///
            ytitle("Treatment Effect")              ///
            `legend' `title' `trend'                ///
            `options'                               ///
        )                                           ///
        `Lgraph'                                    ///
        || `plot' || `addplot'                      ///
        // blank
end

program hte_sm_tabulate
    syntax [, Level(cilevel) ]
    if `"`e(cmd)'"'!="hte sm" {
        di as err "hte sm results not found"
        exit 301
    }
    local z = invnorm((100+`level')/200)
    tempname b se
    mat `b' = e(b)
*    capt confirm matrix e(V)
*    if _rc | e(vce)=="bootstrap" {
        mat `se' = e(se)
*    }
*    else { // needed for jackknife, but not for bootstrap
*        mat `se' = vecdiag(e(V))
*        forv i=1/`=colsof(`se')' {
*            mat `se'[1,`i'] = sqrt(`se'[1,`i'])
*        }
*    }
    local namelist : colname `b'
    local eqlist : coleq `b'
    local k = colsof(`b')
    local depvar `"`e(depvar)'"'
    local hasby = (`"`e(byvar)'"'!="")
    di as txt _n _col(56) "Number of obs =" as res %8.0g  e(N)
    local topline as txt "{hline 13}{c TT}{hline 64}"
    local headline as txt %12s abbrev(`"\`depv'"',12) " {c |}" %11s "Coef." ///
        %12s "Std. Err." %8s "z " %8s "P>|z|" %25s "[`level'% Conf. Interval]"
    local sepline as txt "{hline 13}{c +}{hline 64}"
    local botline as txt "{hline 13}{c BT}{hline 64}"
    local legend as txt "TE = treatment effect"
    local eqlabstrata as res %-12s "TE by strata" as txt " {c |}" %64s ""
    local eqlabtrend as res %-12s "Linear trend" as txt " {c |}" %64s ""
    local eq0
    forv i = 1/`k' {
        gettoken name namelist : namelist
        gettoken eq eqlist : eqlist
        if "`eq'"!="`eq0'" {
            local eq0 "`eq'"
            if `i'>1 {
                di `botline'
                di ""
            }
            if "`eq'"=="_"  local depv `"`depvar'"'
            else            local depv `"`e(depvar`eq')'"'
            if `hasby' {
                di as res `"-> `e(byvar)' = `e(by`eq')'"'
            }
            di `topline'
            di `headline'
            di `sepline'
            di `eqlabstrata'
        }
        if `"`name'"'=="_slope" {
            di `sepline'
            di `eqlabtrend'
        }
        local t = `b'[1,`i']/`se'[1,`i']
        di as txt %12s abbrev(`"`name'"',12) " {c |}" ///
            "  "   as res %9.0g `b'[1,`i'] ///
            "  "   as res %9.0g `se'[1,`i'] ///
            "  "   as res %7.2f `t' ///
            "   "  as res %5.3f 2*norm(-abs(`t')) ///
            "    " as res %9.0g `b'[1,`i']-`se'[1,`i']*`z' ///
            "   "  as res %9.0g `b'[1,`i']+`se'[1,`i']*`z'
    }
    di `botline'
    di `legend'
end

program hte_sm_compute
    local stdopts ///
        by(passthru) SEParate NOIsily Level(passthru) CASEwise LISTwise Replace ///
        join(passthru) AUTOjoin AUTOjoin2(passthru) _blockid(passthru) /// _blockid() undocumented
        ALpha(passthru) pscore(passthru) blockid(passthru) logit comsup numblo(passthru) DETail  /// pscore opts
        CONtrols(passthru) ESTcom(passthru) ESTOPts(passthru)  /// regress options
        // blank
    syntax anything(equalok id="varlist") [if] [in] [fw iw pw] [, `stdopts' noGRaph * ]
    if "`graph'"!="" {
        syntax anything(equalok id="varlist") [fw iw pw] [if] [in] [, `stdopts' noGRaph ]
    }
    if "`detail'"!="" local noisily noisily

    gettoken depvar varlist : anything, parse("=")  // Parse "y1 [ y2 y3 ... = ] x1 x2 ..."
    if `"`depvar'"'=="=" {
        di as err "depvar required"
        exit 198
    }
    else if `"`varlist'"'!="" {
        gettoken junk varlist : varlist, parse("=") // get rid of "="
    }
    else {
        gettoken depvar varlist : anything          // just one depvar
    }

    capt which pscore
    if _rc {
        di as err "-pscore- is required. To install, type: " ///
            `"{stata "net install st0026_2, from(http://www.stata-journal.com/software/sj5-3)"}"'
        exit _rc
    }

    _hte_sm_compute `varlist' `if' `in' [`weight'`exp'], depvar(`depvar')          ///
        `by' `separate' `noisily' `casewise' `listwise' `replace'               ///
        `join' `autojoin' `autojoin2' `_blockid'                                ///
        `alpha' `pscore' `blockid' `logit' `comsup' `numblo' `detail'           ///
        `controls' `estcom' `estopts'

    hte_sm_tabulate , `level'

    if "`graph'"=="" {
        hte_sm_graph , `level' `options'
    }
end

program _hte_sm_compute, eclass
    syntax varlist(numeric) [if] [in] [fw iw pw] , depvar(varlist numeric) [ ///
        by(varname) SEParate NOIsily CASEwise LISTwise Replace ///
        join(str) AUTOjoin AUTOjoin2(passthru) _blockid(varname) /// _blockid() undocumented
        ALpha(passthru) pscore(name) blockid(name) logit comsup numblo(passthru) DETail /// pscore opts
        CONtrols(str) ESTcom(str) ESTOPts(passthru) /// regress options
        ]
    if "`autojoin2'"!="" local autojoin autojoin
    foreach opt in alpha join autojoin {
        if "`_blockid'"!="" & `"``opt''"'!="" {
            di as err "`opt'() not allowed with _blockid()"
            exit 198
        }
    }
    if "`_blockid'"!="" & `"`pscore'`blockid'`logit'`comsup'`numblo'"'!="" {
        di as err "{it:pscore_options} not allowed with _blockid()"
        exit 198
    }
    if `"`estcom'"'=="" local estcom regress
    hte_sm_ParseJoin `join' // returns local join
    if `"`controls'"'!="" {
        hte_sm_ParseControls `controls'
    }
    if "`listwise'"!="" local casewise casewise
    if "`replace'"=="" {
        foreach var in `pscore' `blockid' {
            confirm new var `var'
        }
    }

    // mark obs
    gettoken treatvar indepvars : varlist
    marksample touse
    if "`casewise'"!="" {
        markout `touse' `depvar' `controlvars'
    }
    if "`by'"!="" {
        markout `touse' `by', strok
    }
    if "`_blockid'"!="" {
         markout `touse' `_blockid', strok
    }
    tab `treatvar' if `touse', nofreq
    if r(N)==0 error 2000
    if r(r)!=2 {
        if r(r)>2 di as err "more than 2 groups found in treatvar, only 2 allowed"
        else      di as err "less than 2 groups found in treatvar, 2 required"
        exit 420
    }

    // compute treatment effects
    local ndepvar : list sizeof depvar
    if "`by'"!="" {
        qui levelsof `by' if `touse', local(bygrps)
        local byvar `by'
        local nby: list sizeof bygrps
    }
    else {
        local byvar  1
        local bygrps 1
        local nby    1
    }
    local neq = `ndepvar' * `nby'
    if "`_blockid'"!="" {
        local idvar `_blockid'
    }
    else {
        tempvar psvar idvar
        qui gen      `psvar' = .
        qui gen byte `idvar' = .
    }
    if `"`separate'"'=="" & "`_blockid'"=="" {
        _hte_sm_compute_pstrata `varlist' if `touse' [`weight'`exp'], ///
            pscore(`psvar') blockid(`idvar') ///
            `noisily' `join' `autojoin' `autojoin2' ///
            `alpha' `logit' `comsup' `numblo' `detail'
    }
    tempname b se obs block lfit tmp
    local j 0
    local i 0
    foreach depv of local depvar {
        local ++j
        if `ndepvar'>1 {
            qui `noisily' di as res _n `"-> Outcome variable is: `depv'"'
        }
        gettoken byi rest : bygrps, quotes
        while (`"`byi'"'!="") {
            local ++i
            if "`by'"!="" {
                qui `noisily' di as res _n `"-> Results for `by' == `byi':"'
            }
            if `"`separate'"'!="" & "`_blockid'"=="" & `j'==1 {
                _hte_sm_compute_pstrata `varlist' if `touse' & `byvar'==`byi' [`weight'`exp'], ///
                    pscore(`psvar') blockid(`idvar') ///
                    `noisily' `join' `autojoin' `autojoin2' ///
                    `alpha' `logit' `comsup' `numblo' `detail'
            }
            __hte_sm_compute `varlist' if `touse' & `byvar'==`byi' [`weight'`exp'], ///
                depvar(`depv') estcom(`estcom') blockid(`idvar') ///
                `noisily' `controls' `estopts'
            foreach m in b se obs block lfit {
                mat `tmp' = r(`m')
                if `neq'>1 {
                    mat coleq `tmp' = "`i'"
                }
                mat ``m'' = nullmat(``m'') , `tmp'
            }
            gettoken byi rest : rest, quotes
        }
    }

    // returns
    local wtype = cond("`weight'"=="pweight", "aweight", "`weight'")
    su `touse' if `touse' [`wtype'`exp'], mean
    local nobs = r(N)
    ereturn post `b', obs(`nobs') esample(`touse')
    ereturn scalar neq = `neq'
    ereturn local wexp "`exp'"
    ereturn local wtype "`weight'"
    if "`by'"!="" {
        capt confirm str var `by'
        local bynotstr = _rc
        ereturn local byvar `by'
    }
    if `ndepvar'>1 | "`by'"!="" {
        local i 0
        foreach depv of local depvar {
            gettoken byi rest : bygrps, quotes
            while (`"`byi'"'!="") {
                local ++i
                ereturn local depvar`i' `depv'
                if "`by'"!="" {
                    if `bynotstr' {
                        local byi: label (`by') `byi'
                        local byi `"`"`byi'"'"'
                    }
                    ereturn local by`i' `byi'
                }
                local slope: di %5.3f [`i']_b[_slope]
                local slope_se: di %5.3f `se'[1, colnumb(`se', `"`j':_slope"')]
                ereturn local trend`i' `"slope of linear trend (s.e.) = `slope' (`slope_se')"'
                gettoken byi rest : rest, quotes
            }
        }
        assert (`neq'==`i') // must be equal
    }
    else {
        local slope: di %5.3f _b[_slope]
        local slope_se: di %5.3f `se'[1, colnumb(`se', "_slope")]
        ereturn local trend `"slope of linear trend (s.e.) = `slope' (`slope_se')"'
    }
    ereturn local controls  `controls'
    ereturn local indepvars `indepvars'
    ereturn local treatvar  `treatvar'
    ereturn local depvar    `depvar'
    ereturn local estcom    `estcom'
    ereturn local cmd "hte sm"
    foreach mat in lfit block obs se {
        ereturn matrix `mat' = ``mat''
    }
    if "`pscore'"!="" {
        Vreturn `psvar' `pscore' `replace'
    }
    if "`blockid'"!="" {
        Vreturn `idvar' `blockid' `replace'
    }
    // total N vs. N_comsup (or return N_outofsup)
end

program hte_sm_ParseJoin
    gettoken nlist rest : 0, parse(",")
    while (`"`nlist'"'!="") {
        capt numlist `"`nlist'"', integer range(>0) min(2) sort
        if _rc {
            di as err `"join(): numlist invalid"'
            exit 198
        }
        local nlist `"`r(numlist)'"'
        gettoken last nlist0 : nlist
        foreach num of local nlist0 {
            if `num'!=`last'+1 {
                di as err "join(): numlist not consecutive"
                exit 198
            }
            local last `num'
        }
        local dis: list fulllist & nlist
        if `"`dis'"'!="" {
            di as err "join(): numlists not disjunctive"
            exit 198
        }
        local fulllist : list fulllist | nlist
        local join "`join'`comma'`nlist'"
        local comma ", "
        gettoken nlist rest : rest, parse(",") // get rid of the comma
        gettoken nlist rest : rest, parse(",")
    }
    if `"`join'"'!="" {
        local join join(`join')
    }
    c_local join `join'
end

program hte_sm_ParseControls
    local S 0       // number of set
    local vtmp      // hold varlist
    local stmp      // hold strata numbers
    local 0: subinstr local 0 "," " ", all // allow comma separated list
    gettoken chunk rest : 0, parse(" :")
    local colonok 0
    local vlistok 1
    local nlistok 1
    while `"`chunk'"'!="" {
        gettoken dash : rest, parse("-")
        if `"`dash'"'=="-" {   // bind x - y
            gettoken dash rest : rest, parse("-")
            gettoken dash rest : rest, parse(" :")
            local chunk `"`chunk'-`dash'"'
        }
        if `"`chunk'"'==":" {
            if `colonok'==0 {
                di as err "invalid controls()"
                exit 198
            }
            local colonok 0
            local vlistok 1
            local nlistok 0
            gettoken chunk rest : rest, parse(" :")
            local ++S  // next set
            continue
        }
        capt unab v : `chunk'
        if _rc==0 | _rc==111 {
            if `vlistok'==0 {
                di as err "invalid controls()"
                exit 198
            }
            if _rc==111 {
                di as err "invalid controls(): " _c
                unab v : `chunk', name(controls())
                exit _rc // not needed
            }
            local vtmp `vtmp' `v'
            if `"`stmp'"'!="" {
                local s`S' : list uniq stmp
                local stmp
            }
            local colonok 0
            local nlistok 1
            gettoken chunk rest : rest, parse(" :")
            continue
        }
        capt numlist `"`chunk'"', integer range(>0) sort
        if _rc==0 {
            if `nlistok'==0 {
                di as err "invalid controls()"
                exit 198
            }
            local stmp `stmp' `r(numlist)'
            if `"`vtmp'"'!="" {
                local v`S' : list uniq vtmp
                local vtmp
            }
            local colonok 1
            local vlistok 0
            gettoken chunk rest : rest, parse(" :")
            continue
        }
        di as err "invalid controls()"
        exit 198
    }
    if `"`vtmp'"'!="" { // get last varlist
        local v`S' `vtmp'
        local vtmp
    }
    local ncontrols `v0'  // common controls
    local allv `v0'
    forv i=1/`S' {
        foreach s of local s`i' {
            local sv`s' `sv`s'' `v`i''
        }
        local alls : list alls | s`i'
        local allv : list allv | v`i'
    }
    if `"`alls'"'!="" {
        numlist `"`alls'"', sort
        local alls `r(numlist)'
        foreach s of local alls {
            local sv`s' : list uniq sv`s'
            local ncontrols `"`ncontrols',`s':`sv`s''"'
        }
    }
    c_local controls controls(`ncontrols') // layout is: [varlist][,#:varlist[,#:varlist[...]]]
    c_local controlvars `allv'
end

program hte_sm_ParseControls2
    gettoken chunk rest : 0, parse(",")
    if `"`chunk'"'!="," {
        local allv `chunk'
        c_local commoncontrols `chunk'
        gettoken chunk rest : rest, parse(",")
    }
    local i 0
    gettoken chunk rest : rest, parse(",")
    while (`"`chunk'"'!="") {
        gettoken s chunk : chunk, parse(":")  // get #
        gettoken chunk v : chunk, parse(":")  // remove :
        local allv : list allv | v
        c_local controls_`s' `v'
        gettoken chunk rest : rest, parse(",") // remove ,
        gettoken chunk rest : rest, parse(",")
    }
    c_local allcontrols `allv'
end

prog _hte_sm_compute_pstrata
    syntax varlist(numeric) [if] [in] [fw iw pw], pscore(varname) blockid(varname) [ ///
        NOIsily join(str) AUTOjoin AUTOjoin2(integer 0) ALpha(str asis) ///
        logit comsup numblo(passthru) DETail /// pscore opts
        ]
    if `"`join'"'!="" & ("`autojoin'"!="" | `autojoin2'!=0) {
        di as err "only one of join() and autojoin() allowed"
        exit 198
    }
    if "`autojoin'"!="" & `autojoin2'==0 local autojoin2 10
    if `"`alpha'"'!="" {
        local level level(`alpha')
    }
    marksample touse
    gettoken treatvar indepvars : varlist

    tempname psvar idvar
    capt confirm variable comsup, exact
    if _rc==0 {     // pscore will overwite variable comsup
        tempname comsupbak
        rename comsup `comsupbak'
    }
    if "`noisily'"=="" local noiqui noisily quietly // make sure that errors and warnings appear
    else               local noiqui noisily
    capture `noiqui' pscore `treatvar' `indepvars' if `touse' [`weight'`exp'], ///
        pscore(`psvar') blockid(`idvar') `logit' `comsup' `level' `numblo' `detail'
    local rc = _rc
    capt confirm variable comsup, exact
    if _rc==0 drop comsup
    if "`comsupbak'"!="" {
        rename `comsupbak' comsup
    }
    if `rc' {
        exit `rc'
    }
    if `autojoin2'>0 {
        local join
        tempname C R
        qui tab `idvar' `treatvar' if `touse', matcell(`C') matrow(`R')
        local N1 0
        local N2 0
        local joinl
        local i 0
        while (`i'<r(r)) {
            local ++i
            local num: di `R'[`i',1]
            local joinl `joinl' `num'
            local N1 = `N1' + `C'[`i',1]
            local N2 = `N2' + `C'[`i',2]
            if (`N1'>= `autojoin2') & (`N2'>=`autojoin2') continue, break
        }
        if `:list sizeof joinl'>1 {
            local join `joinl'
        }
        local N1 0
        local N2 0
        local joinr
        local i = r(r)+1
        while (`i'>1) {
            local --i
            local num: di `R'[`i',1]
            local joinr `num' `joinr'
            local N1 = `N1' + `C'[`i',1]
            local N2 = `N2' + `C'[`i',2]
            if (`N1'>= `autojoin2') & (`N2'>=`autojoin2') continue, break
        }
        if `:list sizeof joinr'>1 {
            if "`join'"!="" {
                if "`:list join & joinr'"!="" {
                    di as err "autojoin(): results in single stratum"
                    exit 499
                }
                local join "`join', `joinr'"
            }
            else local join `joinr'
        }
    }
    if `"`join'"'!="" {
        di as txt "(merged strata: " _c
        gettoken nlist rest : join, parse(",")
        local comma ""
        while (`"`nlist'"'!="") {
            di as txt `"`comma'`nlist'"' _c
            local comma ", "
            gettoken first nlist : nlist
            foreach num of local nlist {
                qui replace `idvar' = `first' if `idvar'==`num' & `touse'
            }
            gettoken nlist rest : rest, parse(",") // get rid of the comma
            gettoken nlist rest : rest, parse(",")
        }
        tempvar idvar2
        qui egen `idvar2' = group(`idvar')  // renumber strata
        drop `idvar'
        rename `idvar2' `idvar'
        di as txt "; strata renumbered)"
    }
    qui replace `pscore' = `psvar' if `touse'
    qui replace `blockid' = `idvar' if `touse'
end

prog __hte_sm_compute, rclass
    syntax varlist(numeric) [if] [in] [fw iw pw] , ///
        blockid(varname) depvar(varname) ESTcom(str) [ ///
        NOIsily COMBine(str) ///
        CONtrols(str) ESTOPts(str) /// regress options
        ]
    hte_sm_ParseControls2 `controls' // returns locals allcontrols, commoncontrols, controls_#

    marksample touse
    markout `touse' `blockid'     /// restrict to common support
        `depvar' `allcontrols'    //  estimation sample
    gettoken treatvar indepvars : varlist

    qui levelsof `blockid' if `touse', local(blocks)
    tempname coefs
    local k 0
    foreach l of local blocks {
        local ++k
        local controls_`k' : list commoncontrols | controls_`k'
        qui `noisily' di _n as txt "Treatment Effect within Propensity Score Stratum " `l' ":"
        qui `noisily' `estcom' `depvar' `treatvar' `controls_`k'' ///
            if `touse' & `blockid'==`l' [`weight'`exp'], `estopts'
        capt di _b[`treatvar']   // check whether treatvar has been dropped from model
        local rc = _rc
        if `rc'==0 {
            if _b[`treatvar']==0 & _se[`treatvar']==0 local rc 111  // "omitted" coef
        }
        if `rc'==111 {
            di as err "error in model for stratum `l': treatvar dropped due to collinearity"
            exit `rc'
        }
        mat `coefs' = nullmat(`coefs') \ (`l', e(N), _b[`treatvar'], _se[`treatvar'])
        local blocklbls `blocklbls' `l'
    }

    tempname IDvar Nvar Bvar SEvar
    mat coln `coefs' = `IDvar' `Nvar' `Bvar' `SEvar'
    mat rown `coefs' = `blocklbls'
    svmat `coefs', names(col)
    qui `noisily' di _n as txt "Linear Fit of Treatment Effect on Propensity Score Rank:"
    *qui `noisily' regress `Bvar' `IDvar', depname("TreatEfct")
    if `k'>1 {
        qui `noisily' vwls `Bvar' `IDvar', sd(`SEvar')
        tempvar lfit
        qui predict `lfit' if e(sample), xb
    }
    else if `k'==1 {
        local singleton_b = _b[`treatvar']
        local singleton_se = _se[`treatvar']
        tempvar lfit
        qui gen `lfit' = `singleton_b' in 1
    }
    else { // should never happen
        di as err "somethings wrong; no propensity score strata were generated by -pscore-"
        exit 499
    }
    mkmat `lfit' in 1/`k'
    drop `lfit'
    mat `coefs' = `coefs', `lfit'
    mat coln `coefs' = id N b se lfit

    tempname b se obs block
    if `k'>1 {
        mat `b'   = `coefs'[1...,3]', _b[`IDvar'] , _b[_cons]
        mat `se'  = `coefs'[1...,4]', _se[`IDvar'] , _se[_cons]
    }
    else {
        mat `b'   = `coefs'[1...,3]', 0, `singleton_b'
        mat `se'  = `coefs'[1...,4]', 0, `singleton_se'
    }
    mat coln `b'  = `blocklbls' _slope _cons
    mat coln `se' = `blocklbls' _slope _cons
    mat `obs'     = `coefs'[1...,2]'
    mat `block'   = `coefs'[1...,1]'
    mat `lfit'    = `coefs'[1...,5]'
    foreach mat in b se obs block lfit {
        return mat `mat' = ``mat''
    }
end

/* MS ---------------------------------------------------------------------- */

program hte_ms
    version 9.2

    // syntax
    syntax anything(equalok id="varlist") [if] [in] /*[fw iw pw]*/ [, ///
        /*by(varname) SEParate*/ ///
        /*CASEwise LISTwise*/ /// psmatch2 enforces listwise!
        lowess LOWESS2(str asis)        ///
        lpoly LPOLY2(str asis)          /// Stata 10 required
        lpolyci LPOLYCI2(str asis)      /// Stata 10 required
        tt TTOPTs(str asis) tc TCOPTs(str asis) noSCatter ///
        /// psmatch2 options
        Pscore(passthru) Neighbor(passthru) TIES RADIUS CALiper(passthru)       ///
        KERNEL LLR Kerneltype(passthru) BWidth(passthru)                        ///
        COMmon TRIM(passthru) ODDS LOGIT INDEX NOREPLacement DESCending SPLINE  ///
        NKnots(passthru) QUIetly NOWARNings                                     ///
        ///
        name(passthru) overlay combine(str asis) * /// twoway options
        ]
    if "`listwise'"!=""     local casewise casewise
    if `"`lowess2'"'!=""    local lowess lowess
    if `"`lpoly2'"'!=""     local lpoly lpoly
    if `"`lpolyci2'"'!=""   local lpolyci lpolyci
    if "`lowess'`lpoly'`lpolyci'"=="" local lpoly lpoly
    if "`overlay'"!="" {
        if `"`ttopts'"'!="" {
            di as err "ttopts() not allowed with -overlay-"
            exit 198
        }
        if `"`tcopts'"'!="" {
            di as err "tcopts() not allowed with -overlay-"
            exit 198
        }
        if ("`lowess'"!="") + ("`lpoly'"!="") + ("`lpolyci'"!="") > 1 {
            di as err "only one of lowess, lpoly, and lpolyci allowed with -overlay-"
            exit 198
        }
        local scatter noscatter
        local smcmd "`lowess'`lpoly'`lpolyci'"
    }
    
    // psmatch2 installed?
    capt which psmatch2
    if _rc {
        di as err "-psmatch2- is required. To install, type: " ///
            `"{stata "ssc install psmatch2"}"'
        exit _rc
    }

    // parse varlist
    gettoken depvar varlist : anything, parse("=")  // Parse "y1 [ y2 y3 ... = ] x1 x2 ..."
    if `"`depvar'"'=="=" {
        di as err "depvar required"
        exit 198
    }
    else if `"`varlist'"'!="" {
        gettoken junk varlist : varlist, parse("=") // get rid of "="
    }
    else {
        gettoken depvar varlist : anything          // just one depvar
    }
    gettoken treatvar indepvars : varlist

    // mark sample
    marksample touse
    //if "`casewise'"!="" {
        markout `touse' `depvar'
    //}
*     if "`by'"!="" {
*         markout `touse' `by', strok
*     }
    tab `treatvar' if `touse', nofreq
    if r(N)==0 error 2000
    if r(r)!=2 {
        if r(r)>2 di as err "more than 2 groups found in treatvar, only 2 allowed"
        else      di as err "less than 2 groups found in treatvar, 2 required"
        exit 420
    }

    // matching
    di as txt "(running psmatch2 ...)"
    local ate ate
    if "`tt'"!="" & "`tc'"=="" local ate
    psmatch2 `treatvar' `indepvars' if `touse', outcome(`depvar') `ate'     ///
        `pscore' `neighbor' `ties' `radius' `caliper' `kernel'              ///
        `llr' `kerneltype' `bwidth' `common' `trim' `odds' `logit' `index'  ///
        `noreplacement' `descending' `spline' `nknots' `quietly' `nowarnings'

    // compute individual TEs
    foreach v of local depvar {
        tempvar _`v'
        qui generate `_`v'' = cond(_treated==0, _`v'-`v', `v'-_`v') if _support==1
    }

    // graph
    di as txt "(compiling HTE graph ...)"
    local p 0
    local tlabs
    if "`tc'`tt'"=="" {
        local tcond `""& 1""'
    }
    else {
        local tcond
        if "`tc'"!="" {
            local tcond `""& _treated==0" "'
        }
        if "`tt'"!="" {
            local tcond `"`tcond'"& _treated==1""'
        }
        if "`tc'"!="" & "`tt'"!="" {
            local tlabs `"" (untreated)" " (treated)""'
        }
    }
    local ndepv: list sizeof depvar
    if "`overlay'"!="" {
        local plots
        local legend
        _parse comma `smcmd'2opts `smcmd'2 : `smcmd'2
        foreach v of local depvar {
            local i 0
            foreach t of local tcond {
                if "`smcmd'"=="lpolyci" local p = `p' + 1 // skip CI in legend
                local tlab: word `++i' of `tlabs'
                local plots `macval(plots)' ///
                    (`smcmd' `_`v'' _pscore if `touse' & _support `t', ///
                        leg(lab(`++p' "`v'`tlab'")) ``smcmd'2opts')
                local legend `legend' `p'
            }
            if `"``smcmd'2'"'!="" {
                gettoken trash `smcmd'2 : `smcmd'2, parse(",")
                _parse comma `smcmd'2opts `smcmd'2 : `smcmd'2
            }
        }
        twoway `plots', ytitle("Treatment Effect") xtitle("Propensity Score") ///
            leg(order(`legend')) `name' `options'
    }
    else {
        if "`scatter'"=="" {
            if "`tc'`tt'"=="" {
                local showtc showtc
                local showtt showtt
            }
            else {
                if "`tc'"!="" local showtc showtc
                if "`tt'"!="" local showtt showtt
            }
        }
        if "`scatter'"=="" {
            if "`showtc'"!="" {
                local gr_tc (scatter \`_\`v'' _pscore ///
                    if _treated==0 & `touse' & _support, ///
                    leg(lab(`++p' "untreated")) msize(*.5)  `tcopts')
            }
            if "`showtt'"!="" {
                local gr_tt (scatter \`_\`v'' _pscore ///
                    if _treated==1 & `touse' & _support, ///
                    leg(lab(`++p' "treated")) msize(*.5) `ttopts')
            }
        }
        if "`lpolyci'"!="" {
            local gr_lpolyci
            local i 0
            foreach t of local tcond {
                local tlab: word `++i' of `tlabs'
                local gr_lpolyci `macval(gr_lpolyci)' ///
                    (lpolyci \`_\`v'' _pscore if `touse' & _support `t', ///
                        leg(lab(`++p' "lpoly CI`tlab'") lab(`++p' "lpoly smooth`tlab'")) ///
                        \`lpolyci2opts')
            }
        }
        if "`lpoly'"!="" {
            local gr_lpoly
            local i 0
            foreach t of local tcond {
                local tlab: word `++i' of `tlabs'
                local gr_lpoly `macval(gr_lpoly)' ///
                    (lpoly \`_\`v'' _pscore if `touse' & _support `t', ///
                        leg(lab(`++p' "lpoly smooth`tlab'")) \`lpoly2opts')
            }
        }
        if "`lowess'"!="" {
            local gr_lowess
            local i 0
            foreach t of local tcond {
                local tlab: word `++i' of `tlabs'
                local gr_lowess `macval(gr_lowess)' ///
                    (lowess \`_\`v'' _pscore if `touse' & _support `t', ///
                        leg(lab(`++p' "lowess smooth`tlab'")) \`lowess2opts')
            }
        }
        if `ndepv'>1 {
            local nodraw nodraw
            local plots
        }
        else local nodraw
        foreach smcmd in `lpolyci' `lpoly' `lowess' {
            _parse comma `smcmd'2opts `smcmd'2 : `smcmd'2
        }
        foreach v of local depvar {
            if `ndepv'>1 {
                tempname _gr_`v'
                local plots `plots' `_gr_`v''
                local iname name(`_gr_`v'')
            }
            else {
                local iname `name'
                local lpolyci2opt: copy local lpolyci2
                local lpoly2opt: copy local lpoly2
                local lowess2opt: copy local lowess2
            }
            twoway `gr_tc' `gr_tt' `gr_lpolyci' `gr_lpoly' `gr_lowess' ///
                , `nodraw' ytitle("Treatment Effect") xtitle("Propensity Score") ///
                title(`v') `iname' `options'
            foreach smcmd in `lpolyci' `lpoly' `lowess' {
                if `"``smcmd'2'"'!="" {
                    gettoken trash `smcmd'2 : `smcmd'2, parse(",")
                    _parse comma `smcmd'2opts `smcmd'2 : `smcmd'2
                }
            }
        }
        if `ndepv'>1 {
            graph combine `plots', `combine' `name'
        }
    }
end

/* SD ---------------------------------------------------------------------- */

// should make computation and graph separate processes:
//  - makes implementation of bootstrap possible
//  - possibility to redraw graph on replay() (would this interfere with bootstrap?)

program hte_sd
    version 10
    if replay() {
        if ("`e(cmd)'"!="hte sd") error 301
        exit
    }
    _hte_sd `0'
end

program _hte_sd, rclass

    // syntax
    syntax anything(equalok id="varlist") [if] [in] [fw aw] [, ///
        /// propensity score estimation
        logit                /// use logit instead of probit
        ESTOPTs(string asis) /// estimation options 
        CASEwise LISTwise    /// restrict sample
        NOIsily              /// display output
        pscore(name)         /// save estimated pscore
        _pscore(varname)     /// provide pscore and skip estimation
        replace              /// allow replacing existing variables
        /// lpoly fit
        comsup              /// restrict to common support
        DEGree(integer 1)   ///
        AT(varname)         ///
        atmat(name)         ///
        NGrid(integer 50)   /// number of grid points
        Kernel(passthru)    ///
        BWidth(string)      /// bwidth(# [#] | varname)
        PWidth(string)      /// pwidth(# [#])
        Var(string)         /// var(# [#] | varname)
        /// treatment effect fit
        post                /// post retults in e()
        GENerate(namelist max=2)  /// store fit; generate(fit [at])
        SEgen(name)          /// store SE of fit
        CIgen(namelist min=2 max=2)  /// store CI of fit
        Level(cilevel)      ///
        CIOPTs(str asis)    /// options for CI
        noci                /// suppress CI
        overlay             /// put all smooths into one plot
        NOGRaph             /// suppress graph
        combine(str asis)   /// option for -graph combine- 
        name(passthru)  *   /// twoway options
        ]
    if "`listwise'"!="" local casewise casewise
    local ci = cond("`ci'"=="", "ci", "")
    if `:list sizeof bwidth'>2 {
        di as error "invalid bwidth()"
        exit 198
    }
    if `:list sizeof pwidth'>2 {
        di as error "invalid pwidth()"
        exit 198
    }
    if `:list sizeof var'>2 {
        di as error "invalid var()"
        exit 198
    }
    if "`at'"!="" & "`atmat'"!="" {
        di as err "at() and atmat() not both allowed"
        exit 198
    }
    if "`atmat'"!="" {
        if colsof(`atmat')>1 & rowsof(`atmat')>1 {
            di as err "invalid atmat(): matrix must be a vector"
            exit 499
        }
    }
     
    // check newvars
    if "`generate'"!="" {
            gettoken genfit genat : generate
            gettoken genat : genat
            if "`at'"!="" & "`genat'"!="" {
                di as err "only one name allowed in generate() if at() is specified"
                exit 198
            }
    }
    if "`cigen'"!="" {
            gettoken cilb ciub : cigen
            gettoken ciub : ciub
    }
    if "`replace'"=="" {
        if "`pscore'"!="" confirm new var `pscore', exact
        if "`genfit'"!="" confirm new var `genfit', exact
        if "`genat'"!=""  confirm new var `genfat', exact
        if "`segen'"!=""  confirm new var `segen', exact
        if "`cilb'"!=""   confirm new var `cilb', exact
        if "`ciub'"!=""   confirm new var `ciub', exact
    }
    
    // parse varlist
    gettoken depvar varlist : anything, parse("=")  // Parse "y1 [ y2 y3 ... = ] x1 x2 ..."
    if `"`depvar'"'=="=" {
        di as err "depvar required"
        exit 198
    }
    else if `"`varlist'"'!="" {
        gettoken junk varlist : varlist, parse("=") // get rid of "="
    }
    else {
        gettoken depvar varlist : anything          // just one depvar
    }
    local varlist: list retok varlist
    confirm numeric variable `depvar' `varlist'
    if `:list sizeof varlist'<2 {
        if "`_pscore'"=="" {
            di as err "must specify at least one independent variable"
            exit 198
        }
    }
    else if "`_pscore'"!="" {
        di as err "independent variables not allowed if _pscore() is specified"
        exit 198
    }
    local ndepv: list sizeof depvar
    gettoken treatvar indepvars : varlist
    
    // mark sample
    marksample touse
    if "`casewise'"!="" {
        markout `touse' `depvar'
    }
    if "`_pscore'"!="" {
        markout `touse' `_pscore'
    }
    tempname R
    tab `treatvar' if `touse', nofreq matrow(`R')
    if r(N)==0 error 2000
    if r(r)!=2 {
        if r(r)>2 di as err "more than 2 groups found in treatvar, only 2 allowed"
        else      di as err "less than 2 groups found in treatvar, 2 required"
        exit 420
    }
    local grp0 = `R'[1,1]
    local grp1 = `R'[2,1]
    mat drop `R'
    
    // n() for lpoly
    qui count
    if r(N)<`ngrid' {
        local ngrid = r(N)
        di as txt "(ngrid() reset to `ngrid')"
    }

    // estimation of PS
    if "`_pscore'"=="" {
        local estcmd `logit'
        if "`estcmd'"=="" local estcmd probit
        local qui quietly
        if "`noisily'"!="" local qui
        `qui' `estcmd' `treatvar' `indepvars' if `touse' [`weight'`exp'], `estopts'
        tempname ps
        qui predict `ps' if e(sample), pr
        qui replace `touse' = 0 if e(sample)==0
    }
    else {
        capt assert inrange(`_pscore',0,1) if `touse'
        if _rc {
            di as err "invalid _pscore(): must be within [0,1]"
            exit 499
        }
        markout `touse' `_pscore'
        local ps `_pscore'
    }

    // comput group-specific lpoly fit
    if "`at'"!="" {
        local userat 1
        local atj `at'
        
    }
    else if "`atmat'"!="" {
        local userat 1
        tempname at atrnames tmp
        mat `tmp' = `atmat'
        if colsof(`tmp')>1 {
            mat `tmp' = `tmp''
        }
        matrix coln `tmp' = `at'
        svmat `tmp', names(col)
        local atmatrnames: rownames `tmp'
        qui gen str1 `atrnames' = ""
        forv i = 1/`=rowsof(`tmp')' {
            gettoken rname atmatrnames : atmatrnames
            qui replace `atrnames' = "`rname'" in `i'
        }
        mat drop `tmp'
        local atj `at'
    }
    else {
        local userat 0
        tempname at atj
        local grid_lb = 1 / (`ngrid'*2)
        local grid_ub = 1 - `grid_lb'
        qui range `at' `grid_lb' `grid_ub' `ngrid' 
    }
    foreach opt in bwidth pwidth var {
        gettoken `opt'0 `opt'1 : `opt'
        gettoken `opt'1 : `opt'1
        if `"``opt'1'"'=="" local `opt'1 : copy local `opt'0
        if `"``opt'0'"'!="" local `opt'0 `opt'(``opt'0')
        if `"``opt'1'"'!="" local `opt'1 `opt'(``opt'1')
    }
    local j 0
    tempname g0fit g1fit 
    if "`ci'"!="" {
        tempvar g0se g1se
        local g0seopt se(`g0se')
        local g1seopt se(`g1se')
        local z = invnormal(1 - (100-`level')/200) 
    } 
    foreach v of local depvar {
        local ++j
        if `userat'==0 {        // determine common support
            su `ps' if `touse' & `treatvar'==`grp0' & `v'<., meanonly
            local min = r(min)
            local max = r(max)
            su `ps' if `touse' & `treatvar'==`grp1' & `v'<., meanonly
            if "`comsup'"!="" {
                local min = max(`min', r(min))
                local max = min(`max', r(max))
            }
            else {
                local min = min(`min', r(min))
                local max = max(`max', r(max))
            }
            qui gen `atj' = `at' if `at'>=`min' & `at'<=`max'
        }
        forv i = 0/1 {
            lpoly `v' `ps' if `touse' & `treatvar'==`grp`i'' [`weight'`exp'], ///
                nograph degree(`degree') `kernel' `bwidth`i'' `pwidth`i'' `var`i'' ///
                generate(`g`i'fit') at(`atj') `ci' `g`i'seopt'
            local r_N`i'      = r(N)
            local r_bwidth`i' = r(bwidth)
            if `"`ci'"'!="" {
                local r_pwidth`i' = r(pwidth)
            }
        }
        local r_ngrid  = r(ngrid)
        local r_kernel `r(kernel)'
        local r_degree = r(degree)
        if (`userat'==0) & (`j'<`ndepv') drop `atj' // (keep last)
        tempvar fit`j'
        qui gen `fit`j'' = `g1fit' - `g0fit'
        drop `g0fit' `g1fit'
        if "`ci'"!="" {
            tempvar se`j' lb`j' ub`j'
            qui gen `se`j'' = sqrt(`g0se'^2 + `g1se'^2)
            qui gen `lb`j'' = `fit`j'' + `z' * `se`j''
            qui gen `ub`j'' = `fit`j'' - `z' * `se`j''
            drop `g0se' `g1se'
        }
    }
    
    // draw graph
    if "`nograph'"=="" {
        if "`overlay'"=="" {
            local legend
            local i 0
            if "`ci'"!="" {
                local ci_plot (rarea \`lb\`j'' \`ub\`j'' `at' ///
                    if \`fit\`j''<., psty(ci) `ciopts')
                local legend label(`++i' "`level'% CI")
            }
            local te_plot (line \`fit\`j'' `at' if \`fit\`j''<., ///
                legend(`legend' label(`++i' "lpoly fit")) ///
                \`ti' xti(Propensity Score) ///
                yti(Treatment Effect) `options')
            if `ndepv'>1 {
                local nodraw nodraw
                local plots
            }
            else local nodraw
            local j 0
            foreach v of local depvar {
                local ++j
                if `ndepv'>1 {
                    tempname _gr_`v'
                    local plots `plots' `_gr_`v''
                    local iname name(`_gr_`v'')
                    local ti: variable label `v'
                    if `"`ti'"'=="" local ti "`v'"
                    local ti title(`ti')
                }
                else {
                    local iname `name'
                }
                twoway `ci_plot' `te_plot', `nodraw' `iname'
            }
            if `ndepv'>1 {
                graph combine `plots', `combine' `name'
            }
        }
        else {
            tempvar touse2
            qui gen byte `touse2' = 0
            local j 0
            local lj = ("`ci'"!="") * 2 * `ndepv'
            local legend
            local leglab
            local vlist
            local lblist
            local ublist
            local cilplist
            foreach v of local depvar {
                local ++j
                qui replace `touse2' = 1 if `fit`j''<.
                local vlist `vlist' `fit`j''
                if "`ci'"!="" {
                    local lblist `lblist' `lb`j''
                    local ublist `ublist' `ub`j''
                    local cilplist `cilplist' dash
                }
                local ti: variable label `v'
                if `"`ti'"'=="" local ti "`v'"
                local leglab `leglab' lab(`++lj' `"`ti'"')
                local legend `legend' `lj'
            }
            local legend legend(`leglab' order(`legend'))
            if "`ci'"!="" {
                local ci_plot (line `lblist' `at' if `touse2', lpattern(`cilplist') `ciopts') ///
                    (line `ublist' `at' if `touse2', lpattern(`cilplist') `ciopts')
                local pcycleopt pcycle(`ndepv')
            }
            two `ci_plot' (line `vlist' `at' if `touse2', ///
                xti(Propensity Score) yti(Treatment Effect) ///
                `pcycleopt' `legend' `name' `options')
            drop `touse2'
        }
    }

    // returns (last depvar only)
    local lastdepvar: word `ndepv' of `depvar'
    if "`post'"!="" {
        if "`atmat'"!="" local mkmatopt "rownames(`atrnames')"
        else             local mkmatopt "obs"
        tempname B AT
        mkmat `fit`ndepv'' if `at'<. & `fit`ndepv''<., matrix(`B') `mkmatopt'
        mat `B' = `B''
        mat rown `B' = b
        mkmat `at' if `at'<. & `fit`ndepv''<., matrix(`AT') `mkmatopt'
        mat `AT' = `AT''
        mat rown `AT' = at
        if `"`ci'"'!="" {
            tempname SE LB UB
            mkmat `se`ndepv'' if `at'<. & `fit`ndepv''<., matrix(`SE') `mkmatopt'
            mat `SE' = `SE''
            mat rown `SE' = se
            mkmat `lb`ndepv'' if `at'<. & `fit`ndepv''<., matrix(`LB') `mkmatopt'
            mat `LB' = `LB''
            mat rown `LB' = lb
            mkmat `ub`ndepv'' if `at'<. & `fit`ndepv''<., matrix(`UB') `mkmatopt'
            mat `UB' = `UB''
            mat rown `UB' = ub
        }
        qui count if `touse'
        eret post `B', esample(`touse') depname(`lastdepvar') obs(`r(N)')
        myeret local cmd "hte sd"
        myeret matrix at = `AT'
        if `"`ci'"'!="" {
            myeret matrix se = `SE'
            myeret matrix lb = `LB'
            myeret matrix ub = `UB'
            myeret scalar cilevel = `level'
        }
        local rtype mye
    }
    else local rtype
    `rtype'ret local indepvars `indepvars'
    `rtype'ret local treatvar  `treatvar'
    `rtype'ret local depvar    `lastdepvar'
    forv i = 1(-1)0 {
        if `"`ci'"'!="" {
            `rtype'ret scalar pwidth`i' = `r_pwidth`i''
        }
        `rtype'ret scalar bwidth`i'    = `r_bwidth`i''
        `rtype'ret scalar N`i'         = `r_N`i''
        `rtype'ret local treatgrp`i'   `"`grp`i''"'
    }
    `rtype'ret scalar degree = `r_degree'
    `rtype'ret scalar ngrid  = `r_ngrid'
    `rtype'ret local kernel  `r_kernel'

    // return variables (last depvar only)
    if "`pscore'"!="" {
        Vreturn `ps' `pscore' `replace'
    }
    if "`genfit'"!="" {
        Vreturn `fit`ndepv'' `genfit' `replace'
    }        
    if "`genat'"!="" {
        Vreturn `at' `genat' `replace'
    }
    if "`segen'"!="" {
        Vreturn `se`ndepv'' `segen' `replace'
    }
    if "`cilb'"!="" {
        Vreturn `lb`ndepv'' `cilb' `replace'
    }
    if "`ciub'"!="" {
        Vreturn `ub`ndepv'' `ciub' `replace'
    }
end

/* COMMON ------------------------------------------------------------------ */

program myeret, eclass
    eret `0'
end

program Vreturn
    args oldname newname replace
    if "`replace'"!="" {
        capt confirm var `newname', exact
        if !_rc drop `newname'
    }
    rename `oldname' `newname'
end

