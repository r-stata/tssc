*! version 1.0.3  14jun2018  Ben Jann

program lorenz, eclass properties(svyb svyj)
    version 11
    if replay() {
        Display `0'
        exit
    }
    gettoken subcmd cmdline: 0, parse(", ")
    local length = length(`"`subcmd'"')
    if `"`subcmd'"'==substr("graph",1,max(`length',1)) {
        capt n Graph`cmdline'
        if _rc {
            di as err "error executing lorenz graph"
            exit _rc
        }
        exit
    }
    if `"`subcmd'"'==substr("contrast",1,max(`length',1)) {
        capt n Contrast`cmdline' // returns diopts, graph, graph2
        if _rc {
            di as err "error executing lorenz contrast"
            exit _rc
        }
        ereturn local cmdline0 `"`e(cmdline)'"'
        ereturn local cmdline `"lorenz `0'"'
        Display, `cdiopts'
        if "`graph'"!="" {
            Graph, `graph2'
        }
        exit
    }
    if `"`subcmd'"'!=substr("estimate",1,max(`length',1)) {
        capture confirm variable `subcmd'
        if _rc==0 {
            local cmdline `" `subcmd' `cmdline'"'
            local subcmd "estimate"
            local length = length(`"`subcmd'"')
        }
    }
    if `"`subcmd'"'==substr("estimate",1,max(`length',1)) {
        local version : di "version " string(_caller()) ":"
        Parse_opts `0' // returns lhs, options, cluster, graph, graph2
        `version' _vce_parserun lorenz, mark(over) bootopts(`cluster') ///
            jkopts(`cluster') wtypes(pw iw fw) noeqlist: `lhs', nose `options'
        if "`s(exit)'" != "" {
            ereturn local cmdline `"lorenz `0'"'
            if "`graph'"!="" {
                Graph, `graph2'
            }
            exit
        }
        Estimate`cmdline' // returns diopts, contrast, contrast2, graph, graph2
        ereturn local cmdline `"lorenz `0'"'
        if "`contrast'"!="" {
            capt n Contrast_opt `contrast2'
            if _rc {
                di as err "error in contrast() option"
                exit _rc
            }
        }
        Display, `diopts'
        if "`graph'"!="" {
            Graph, `graph2'
        }
        exit
    }
    di as err `"`subcmd' invalid subcommand"'
    exit 198
end

program Parse_opts
    _parse comma lhs 0 : 0
    syntax [, nose vce(passthru) CLuster(passthru) Graph Graph2(str asis) * ]
    if "`se'"!="" & `"`vce'"'!="" {
        di as err "vce() and nose not both allowed"
        exit 198
    }
    c_local lhs `"`lhs'"'
    c_local options `vce' `options'
    c_local cluster `cluster'
    if `"`graph2'"'!="" local graph graph
    c_local graph `graph'
    c_local graph2 `"`graph2'"'
end

program Display
    syntax [, noHEader noTABle noGTABle Level(passthru) * ]
    _get_diopts diopts, `options'
    if `"`e(cmd)'"'!="lorenz" {
        di as err "last lorenz results not found"
        exit 301
    }
    if `"`level'"'=="" local level level(`e(level)')
    if `"`header'"'=="" {
        if `"`e(contrast)'"'=="" & c(stata_version)>=12 {
            nobreak {
                Display_ereturn local cmd "total" // mimick header of -total-
                capture noisily break {
                    _coef_table_header
                }
                Display_ereturn local cmd "lorenz"
                if _rc exit _rc
            }
        }
        else _coef_table_header
        if `"`e(over)'"'!="" {
            _svy_summarize_legend
        }
        else di ""
    }
    if `"`table'"'=="" {
        if `"`e(contrast)'"'=="" & c(stata_version)>=12 {
            if c(stata_version)>=14 {
                eret di, nopvalue `level' `options'
            }
            else if c(stata_version)>=13 {
                quietly update
                if r(inst_ado)>=d(26jun2014) {
                    eret di, nopvalue `level' `options'
                }
                else {
                    _coef_table, cionly `level' `options'
                }
            }
            else {
                _coef_table, cionly `level' `options'
            }
        }
        else  eret di, `level' `options'
        if `"`e(norm)'`e(normpop)'"'!="" {
            di as txt "(normalized with respect to " _c
            if `"`e(normavg)'"'!="" di "average" _c
            else                    di "total" _c
            if `"`e(norm)'"'!="" {
                di " of " as res `"`e(norm)'"' _c
            }
            if `"`e(normpop)'"'!="" {
                if `"`e(normpop)'"'=="total" {
                    di as txt " across all subpopulations" _c
                }
                else {
                    di as txt `" for `e(normpop)'"' _c
                }
            }
            di as txt ")"
        }
        if `"`e(pvar)'"'!="" {
            di as txt "(ordering with respect to " as res `"`e(pvar)'"' as txt ")"
        }
        if `"`e(contrast)'"'!="" {
            if "`e(ratio)'"!=""        di as txt "(ratio with respect to " _c
            else if "`e(lnratio)'"!="" di as txt "(log. ratio with respect to " _c
            else                       di as txt "(difference to " _c
            if `"`e(baseval)'"'=="+" {
                if `"`e(over)'"'!="" di as txt "preceding subpopulation)"
                else                 di as txt "preceding outcome variable)"
            }
            else {
                if `"`e(over)'"'!="" {
                    if `"`e(baseval)'"'=="total" {
                        di as txt `"total population)"'
                    }
                    else {
                        di as txt `"`e(over)' = `e(baseval)')"'
                    }
                }
                else di as res `"`e(baseval)'"' as txt ")"
            }
        }
    }
    if `"`gtable'"'=="" {
        if "`e(gini)'"!="" {
            matlist e(G), border(top bottom)
        }
    }
end

prog Display_ereturn, eclass
    ereturn `0'
end

program Graph
    syntax [, ///
        PROPortion NOGini Gini(str) keep(str)                           ///
        BYOPTs(str asis) LABels(str asis) Level(passthru)               ///
        noci CI2(str) CIOPTs(str asis) OVERlay                          ///
        NODIAGonal DIAGonal(str asis)                                   ///
        prange(numlist min=2 max=2 >=0 <=100 ascending)                 ///
        LEGend(passthru) fxsize(passthru) fysize(passthru)              ///
        PSTYle(passthru) PCYCle(int 15) * ]
    if `"`e(cmd)'"'!="lorenz" {
        di as err "last lorenz results not found"
        exit 301
    }
    // options
    if `"`gini'"'=="" local gini "%9.3g"
    if `pcycle'<1 {
        di as err "pcycle() must be a positive integer"
        exit 198
    }
    _get_gropts, graphopts(`options') gettwoway getallowed(plot addplot)
    local twowayopts `s(twowayopts)' `legend' `fxsize' `fysize'
    local legend
    local options `pstyle' `s(graphopts)'
    local plot `"`s(plot)'"'
    local addplot `"`s(addplot)'"'
    if `"`level'"'!="" {
        Parse_level, `level' // returns cilevel
    }
    else {
        local cilevel `e(level)'
        if `"`cilevel'"'=="" { // get default cilevel if e(level) not set
            Parse_level
        }
    }
    Parse_ci, `ci2' // returns citype
    
    // prepare CIs
    if inlist("`citype'", "bc", "bca", "percentile") {
        if `"`level'"'!="" {
            di as err "level() not allowed with ci(`citype')"
            exit 198
        }
        confirm matrix e(ci_`citype')
    }
    else if "`citype'"=="normal" {
        capt confirm matrix e(V)
        if _rc {
            di as err "matrix e(V) not found; cannot compute confidence intervals"
            exit 111
        }
    }
    else {
        capt confirm matrix e(V)
        if _rc==0 {
            local citype normal
        }
    }
    
    // collect bars and CIs
    tempname S tmp0 tmp
    matrix `S' = e(b)'
    local eqs: roweq `S'
    local eqs: list uniq eqs
    capt mat drop `tmp'
    matrix `tmp0' = e(p)
    foreach eq of local eqs {
        matrix `tmp' = nullmat(`tmp'), `tmp0'[1,"`eq':"]
    }
    matrix `S' = `S', `tmp''
    if "`citype'"!="" {
        if inlist("`citype'", "bc", "bca", "percentile") {
            local cilab " `citype'"
            if "`citype'"=="bc"       local cilab " bias-corrected"
            else if "`citype'"=="bca" local cilab " BCa"
            matrix `S' = `S', e(ci_`citype')'
        }
        else {
            local cilab
            mata: st_matrix("`tmp'", (((1,-1)\(1,1)) * ///
                    (st_matrix("e(b)") \ invnormal(0.5 + `cilevel'/200) * ///
                    sqrt(diagonal(st_matrix("e(V)"))')))')
            mat `S' = `S', `tmp'
        }
    }
    
    // prepare keep()
    if `"`e(over)'"'!="" {
        local values `e(over_namelist)'
        foreach eq of local eqs { // collect over-labels from e()
            if "`eq'"=="total" continue
            local pos: list posof "`eq'" in values
            local overlab_`eq': word `pos' of `e(over_labels)'
        }
    }
    if `"`keep'"'!="" {
        local keeplist
        foreach k of local keep {
            if substr(`"`k'"', 1, 1)=="#" {
                local i = substr(`"`k'"', 2, .)
                capt confirm integer number `i'
                if _rc {
                    di as err `"keep(): `k' invalid"'
                    exit 198
                }
                local i: word `i' of `eqs'
            }
            else {
                local i `"`k'"'
                if `"`e(over)'"'!="" & substr("total", 1, strlen(`"`k'"'))==`"`k'"' {
                    local i total
                }
                if `: list i in eqs'==0 local i
            }
            if `"`i'"'=="" {
                di as err `"keep(): `k' invalid"'
                exit 198
            }
            local keeplist `keeplist' `i'
        }
        local eqs: copy local keeplist
    }

    // collect equations, select prange, and add topcode for last bar
    if "`citype'"!="" local cicols ", ., ."
    else              local cicols
    local ngrid = e(ngrid)
    if "`prange'"!="" {
        local prange_min: word 1 of `prange'
        local prange_max: word 2 of `prange'
        matrix `tmp' = `S'[1..`ngrid', 2]
        local bin_min 1
        local bin_max 0
        local pmin 0
        forv i = 1/`ngrid' {
            local p = `tmp'[`i',1]
            if `p'<`prange_min'  local bin_min = `bin_min' + 1
            if `bin_min'==`i' local pmin `p'
            if `p'<=`prange_max' {
                local bin_max = `i'
                local pmax `p'
            }
        }
        if `prange_max'==100 {
            local bin_max `ngrid'
            local pmax 100
        }
        local ngrid = `bin_max' - `bin_min' + 1
        if `ngrid'<1 {
            di as err "invalid prange(): no ordinates within specified range"
            exit 198
        }
    }
    else {
        local pmin 0
        local pmax 100
    }
    matrix rename `S' `tmp0', replace
    tempname tmp1
    mat `tmp1' = J(`ngrid', 1, .)
    forv i = 1/`ngrid' {
        mat `tmp1'[`i',1] = `i'
    }
    local i 0
    foreach eq of local eqs {
        local ++i
        matrix `tmp' = `tmp0'["`eq':", 1...]
        if "`prange'"!="" {
            matrix `tmp' = `tmp'[`bin_min'..`bin_max', 1...]
        }
        matrix `tmp' = `tmp', J(rowsof(`tmp'), 1, `i'), `tmp1'
        matrix `S' = nullmat(`S') \ `tmp'
    }
    local keq `i'

    // expand data if needed and save as variables
    tempvar Y X BY PID 
    local r = rowsof(`S')
    if _N<`r' {
        preserve
        qui set obs `r'
    }
    if "`citype'"!="" {
        tempvar LL UL
        matrix colnames `S' = `Y' `X' `LL' `UL' `BY' `PID'
    }
    else {
        matrix colnames `S' = `Y' `X' `BY' `PID'
    }
    svmat `S', names(col)
    if "`e(pvar)'"!="" local pvar " (ordered by `e(pvar)')"
    if "`proportion'"!="" {
        qui replace `X' = `X'/100
        local xti "population proportion`pvar'"
    }
    else local xti "population percentage`pvar'"
    lab var `X' "`xti'"
    local rtype "`e(type)'"
    if "`rtype'"=="generalized"    local yti "GL(p)"
    else if "`rtype'"=="absolute"  local yti "AL(p)"
    else if "`rtype'"=="sum"       local yti "TL(p)"
    else if "`rtype'"=="gap"       local yti "p-L(p)"
    else                           local yti "L(p)"
    if `"`e(contrast)'"'!="" {
        if "`e(ratio)'"!=""        local yti "`yti' ratio"
        else if "`e(lnratio)'"!="" local yti "log. `yti' ratio"
        else                       local yti "difference in `yti'"
    }
    lab var `Y' "`yti'"
    if "`rtype'"=="generalized"    local yti "GL(p)"
    else if "`rtype'"=="absolute"  local yti "AL(p)"
    else if "`rtype'"=="sum"       local yti "TL(p)"
    else if "`rtype'"=="gap" {
        if "`e(percent)'"!=""      local yti "(p-L(p))*100"
        else                       local yti "p-L(p)"
    }
    else                           local yti "L(p)"
    if `"`e(contrast)'"'!="" {
        if "`e(ratio)'"!=""        local yti "`yti' ratio"
        else if "`e(lnratio)'"!="" local yti "log. `yti' ratio"
        else                       local yti "difference in `yti'"
    }
    else {
        if "`rtype'"=="generalized" local yti "cumulative mean"
        else if "`rtype'"=="sum"    local yti "cumulative total"
        else if "`rtype'"=="" {
            if "`e(percent)'"!=""   local yti "cumulative outcome percentage"
            else                    local yti "cumulative outcome proportion"
        }
    }
    
    // collect labels
    local hasgini = (`"`e(gini)'"'!="") & ("`nogini'"=="")
    if `hasgini' {
        tempname G
        matrix `G' = e(G)
    }
    local i 0
    foreach eq of local eqs {
        local ++i
        gettoken bylab labels : labels
        if `"`bylab'"'=="" {
            if `"`e(over)'"'=="" {
                capt local bylab: var lab `eq'
                if `"`bylab'"'=="" {
                    local bylab `"`eq'"'
                }
            }
            else {
                if "`eq'"=="total" local bylab "Total"
                else local bylab `"`overlab_`eq''"'
            }
        }
        if `hasgini' {
            local g = rownumb(`G', "`eq'")
            local g `:di `gini' `G'[`g',1]'
            local bylab `"`bylab' (Gini = `g')"'
        }
        lab def `BY' `i' `"`bylab'"', add
    }
    lab val `BY' `BY'
    
    // graph
    if "`overlay'"!="" {
        local byopt
    }
    else if `keq'>1 {
        local byopt by(`BY', note("") `byopts')
    }
    else {
        if `hasgini' {
            if "`eqs'"=="_" local eqs `"`e(depvar)'"'
            local g = rownumb(`G', "`eqs'")
            local g `:di `gini' `G'[`g',1]'
            local byopt `"subtitle("Gini = `g'")"'
        }
        else local byopt
    }
    local xtitle xtitle("`xti'")
    local ytitle ytitle("`yti'")
    local mainplot
    local ciplot
    local diagplot
    local loffset 0
    if "`nodiagonal'"=="" & "`rtype'"=="" & "`e(contrast)'"=="" {
        su `X' in 1/`r', meanonly
        local x0 = r(min)
        local x1 = r(max)
        local y0 = r(min)
        local y1 = r(max)
        if "`proportion'"!="" & "`e(percent)'"!="" {
            local y0 = `y0' * 100
            local y1 = `y1' * 100
        }
        else if "`proportion'`e(percent)'"=="" {
            local y0 = `y0' / 100
            local y1 = `y1' / 100
        }
        local diagplot (pci `y0' `x0' `y1' `x1', lstyle(yxline) `diagonal')
        local loffset 1
    }
    if "`overlay'"!="" {
        local i 0
        foreach eq of local eqs {
            local ++i
            Parse_oopts `i', `options' // returns oopts_i, options
            Parse_ciopts `i', `oopts_`i'' // returns ci_i, ciopts_i, oopts_i
            if "`citype'"=="" {
                local ci_`i' ""
            }
            else {
                if "`ci'"=="" & "`ci_`i''"=="" {
                    local ci_`i' "ci"
                }
                else if "`ci_`i''"=="noci" {
                    local ci_`i' ""
                }
            }
            if "`ci_`i''"!="" {
                local ++loffset
            }
        }
        local legend
        local i 0
        foreach eq of local eqs {
            local ++i
            local k = mod(`i'-1, `pcycle') + 1
            local mainplot `mainplot' ///
                (line `Y' `X' if `BY'==`i', pstyle(p`k'line) `options' `oopts_`i'')
            local legend `legend' `=`loffset'+`i'' `"`:lab `BY' `i''"'
            if "`ci_`i''"!="" {
                local ciplot `ciplot' ///
                    (rarea `LL' `UL' `X' if `BY'==`i', pstyle(ci) `ciopts' `ciopts_`i'')
            }
        }
        local legend legend(order(`legend') all on)
    }
    else {
        local ++loffset
        local mainplot (line `Y' `X', pstyle(p1line) `options' )
        if "`citype'"!="" & "`ci'"=="" {
            local legend legend(order(`=`loffset'+1' `loffset' "`cilevel'%`cilab' CI"))
            local ciplot (rarea `LL' `UL' `X', pstyle(ci) `ciopts')
        }
    }
    twoway `diagplot' `ciplot' `mainplot' || `plot' || `addplot' || ///
        in 1/`r', `xtitle' `ytitle' `origin' `legend' `twowayopts' `byopt'
end

program Parse_level
    syntax [, Level(cilevel) ]
    c_local cilevel `"`level'"'
end

program Parse_ci
    syntax [, NORmal bc bca Percentile ]
    local citype `normal' `bc' `bca' `percentile'
    if `:list sizeof citype'>1 {
        di as err "only one of normal, bc, bca, and percentile allowed in ci()"
        exit 198
    }
    c_local citype `citype'
end

program Parse_oopts
    gettoken j 0 : 0, parse(" ,")
    syntax [, o`j'(str asis) * ]
    c_local oopts_`j' `o`j''
    c_local options `options'
end

program Parse_ciopts
    gettoken j 0 : 0, parse(" ,")
    syntax [, NOCI CI CIOPTs(str asis) * ]
    if "`ci'"!="" & "`noci'"!="" {
        di as err "o`j'(): only one of ci and noci allowed"
        exit 198
    }
    c_local ci_`j' `ci'`noci'
    c_local ciopts_`j' `ciopts'
    c_local oopts_`j' `options'
end

program Estimate, sortpreserve eclass
    // syntax
    syntax varlist(numeric) [if] [in] [pw iw fw/], [         ///
        percent gap sum GENERALized ABSolute                 ///
        NORMalize(str) gini                                  ///
        Nquantiles(numlist int max=1 >0)                     ///
        Percentiles(numlist >=0 <=100 ascending)             ///
        pvar(varname numeric) step                           ///
        over(varname numeric) Total                          ///
        Contrast Contrast2(str) Graph Graph2(str asis)       ///
        vce(str) CLuster(varname) svy SVY2(str) nose         ///
        /// display options
        Level(cilevel) noHEader noTABle noGTABle *           ///
        ]
    // varlist
    local varlist: list uniq varlist // remove repeated varnames
    local ndepv: list sizeof varlist 
    
    // type of results
    local rtype `gap' `sum' `generalized' `absolute'
    if `: list sizeof rtype'>1 {
        local rtype: list retok rtype
        di as err "`rtype': only one allowed"
        exit 198
    }
    if "`percent'"!="" & "`rtype'"!="" {
        if "`rtype'"!="gap" {
            di as err "percent not allowed with `rtype'"
            exit 198
        }
    }
    
    // normalize()
    if `"`normalize'"'!="" {
        Parse_normalize `normalize' // returns norm, normnum, normpop, normavg
        if "`norm'"=="*" local norm `varlist'
    }
    if "`rtype'"!="" {
        if `"`norm'`normnum'`normpop'"'!="" & "`rtype'"!="gap" {
            di as err "normalize() not allowed with `rtype'"
            exit 198
        }
    }
    
    // percentile cutoffs, labels for percentiles
    if "`nquantiles'"!="" & "`percentiles'"!="" {
        di as err "nquantiles() and percentiles() not both allowed"
        exit 198
    }
    if "`nquantiles'"=="" local nquantiles 20
    if "`percentiles'"=="" {
        local percentiles 0
        forv i = 1/`nquantiles' {
            local percentiles `percentiles' `=`i'*100/`nquantiles''
        }
    }
    local ngrid: list sizeof percentiles
    local qlbls: subinstr local percentiles "." ",", all  // to fix problem with decimal point
    
    // over(), total
    if "`over'"=="" {
        if "`total'"!="" {
            di as err "total only allowed if over() is specified"
            exit 198
        }
        if "`grandtotal'"!="" {
            di as err "grandtotal only allowed if over() is specified"
            exit 198
        }
    }
    else if `ndepv'>1 {
        di as err "over() not allowed if multiple variables are specified"
        exit 198
    }
    
    // vce
    local vce0 `"`vce'"'
    if `"`cluster'"'!="" {
        if "`se'"!="" {
            di as err "cluster() and nose not both allowed"
            exit 198
        }
        if `"`svy'`svy2'"'!="" {
            di as err "cluster() and svy() not both allowed"
            exit 198
        }
        if `"`vce'"'!="" {
            di as err "cluster() and vce() not both allowed"
            exit 198
        }
        local vce `"cluster `cluster'"'
        local cluster
    }
    if `"`vce'"'!="" {
        if "`se'"!="" {
            di as err "vce() and nose not both allowed"
            exit 198
        }
        if `"`svy'`svy2'"'!="" {
            di as err "vce() and svy() not both allowed"
            exit 198
        }
        gettoken vce clustvar : vce
        if `"`vce'"'=="analytic" & `"`clustvar'"'=="" {
            local vce analytic
        }
        else if `:list sizeof clustvar'==1 & ///
            substr("cluster", 1, max(2, strlen(`"`vce'"')))==`"`vce'"' {
            local vce cluster
            local vcetype Robust
            gettoken clustvar : clustvar
            local clustopt cluster(`clustvar')
        }
        else {
            di as err "invalid vce()"
            exit 198
        }
    }
    else if "`se'"=="" {
        local vce analytic
    }
    
    // svy 
    if `"`svy'`svy2'"'!="" {
        if "`weight'"!="" {
            di as err "weights not allowed with svy; supply weights to {help svyset}"
            exit 101
        }
        if "`se'"!="" {
            di as err "svy() and nose not both allowed"
            exit 198
        }
        local svy svy
        if `"`svy2'"'!="" {
            local svy2 `"subpop(`svy2')"'
        }
    }
    
    // display options
    local levelopt level(`level')
    _get_diopts diopts, `options'
    c_local diopts `header' `table' `gtable' `levelopt' `diopts'
    
    // graph option
    if `"`graph2'"'!="" local graph graph
    c_local graph `graph'
    c_local graph2 `"`graph2'"'
    
    // sample and weights
    marksample touse
    markout `touse' `clustvar' `over' `pvar' `norm'
    if "`svy'"!="" {
        if c(stata_version)>=14 {
            tempvar subpop exp
            _svy_setup `touse' `subpop' `exp', svy `svy2'
            local weight `"`r(wtype)'"'
            if "`weight'"=="" {
                drop `exp'
                local exp
            }
        }
        else {
            tempvar subpop
            _svy_setup `touse' `subpop', svy `svy2'
            local weight `"`r(wtype)'"'
            local exp `"`r(wvar)'"'
        }
        if `"`r(vce)'"'!="linearized" {
            di as err "option svy is only allowed if VCE is set to linearized; " ///
                `"use the {helpb svy} prefix command for `r(vce)' survey estimation"'
            exit 498
        }
        local svy_posts `"`r(poststrata)'"'
        local svy_postw `"`r(postweight)'"'
        if `"`svy_posts'"'!="" {
            if "`weight'"!="" local wexp `"[`weight' = `exp']"'
            tempvar exp
            svygen post double `exp' `wexp' if `touse', ///
                posts(`svy_posts') postw(`svy_postw')
            if "`weight'"=="" local weight pweight
        }
    }
    else local subpop `touse'
    if "`over'"!="" {
        capt assert ((`over'==floor(`over')) & (`over'>=0)) if `subpop'
        if _rc {
            di as err "variable in over() must be integer and nonnegative"
            exit 452
        }
        qui levelsof `over' if `subpop', local(overvals)
        local N_over: list sizeof overvals
        local over_labels
        foreach overval of local overvals {
            local over_labels `"`over_labels' `"`: label (`over') `overval''"'"'
        }
        local over_labels: list clean over_labels
        if `"`normpop'"'!="" & `"`normpop'"'!="total" {
            if substr(`"`normpop'"', 1, 1)=="#" {
                local normpop = substr(`"`normpop'"', 2, .)
                capt confirm integer number `normpop'
                if _rc {
                    di as err `"normalize(): #`normpop' invalid"'
                    exit 198
                }
                local normpop: word `normpop' of `overvals'
            }
            else {
                capt confirm integer number `normpop'
                if _rc {
                    di as err `"normalize(): `normpop' invalid"'
                    exit 198
                }
                local normpop: list overvals & normpop
            }
            if `"`normpop'"'=="" {
                di as err "normalize(): specified subpopulation not found"
                exit 198
            }
        }
    }
    else if `"`normpop'"'!="" {
        di as err "reference population in normalize() only allowed if over() is specified"
        exit 198
    }
    if "`weight'"!="" {
        capt confirm variable `exp'
        if _rc {
            local wexp `"= `exp'"'
            tempvar exp
            qui gen double `exp' `wexp'
        }
        local wgt `"[`weight' = `exp']"'
        if "`weight'"=="pweight" {
            local swgt `"[aw = `exp']"'
        }
        else {
            local swgt `"`wgt'"'
        }
    }
    else {
        local wgt
        local swgt
    }
    if "`svy'"!="" & `"`exp'"'!="" {
        su `touse' if `touse', meanonly
    }
    else {
        su `touse' `swgt' if `touse', meanonly
    }
    local N = r(N)
    if `N'==0 error 2000
    
    // contrast
    if `"`contrast2'"'!="" local contrast contrast
    if "`contrast'"!="" {
        if "`over'"=="" {
            if `ndepv'==1 {
                di as err "contrast not allowed with single outcome variable"
                exit 198
            }
        }
        else {
            if `N_over'==1 {
                di as err "contrast not allowed with single subpopulation"
                exit 198
            }
        }
    }
    c_local contrast `contrast'
    c_local contrast2 `"`contrast2'"'
    
    // check whether variance estimation is supported
    if "`se'"=="" {
        if "`weight'"=="fweight" {
            if "`vce'"=="analytic" & `"`vce0'"'=="" {
                di as txt "(variance estimation not supported with fweights)"
                local se nose
            }
            else if "`svy'`vce'"!="" {
                di as err "variance estimation not supported with fweights"
                exit 498
            }
        }
    }

    // generate helper variable for uvars
    if "`se'"=="" & ("`rtype'"=="sum" | "`normnum'"!="") {
        tempvar avar
        if "`svy'"!="" {
            qui gen byte `avar' = 0 if `touse'
        }
        else {
            Generate_avar `avar', touse(`touse') c(`clustvar') t(`normnum') ///
                n(`N') w(`exp') `svy'
        }
    }

    // compute shares
    tempname S
    local uvars
    if "`pvar'"!="" tempvar vtmp
    if "`norm'"!="" {
        tempname normvar
        qui gen double `normvar' = 0 if `touse'
        foreach v of local norm {
            qui replace `normvar' = `normvar' + `v' if `touse'
        }
    }
    if "`touse'"=="`subpop'" local offset 0
    else {
        qui count if `touse' & `subpop'==0
        local offset = r(N)
    }
    if "`over'"=="" {
        if "`gini'"!="" {
            tempname G
            mat `G' = J(`ndepv', 1, .)
            mat rown `G' = `varlist'
            mat coln `G' = "Gini"
        }
        local k_eq 0
        foreach v of local varlist {
            local uvarsi
            if "`se'"=="" {
                forv i = 1/`ngrid' {
                    tempvar u
                    qui gen double `u' = .
                    local uvarsi `uvarsi' `u'
                }
                local uvars `uvars' `uvarsi'
            }
            local ++k_eq
            if `ndepv'>1 local eq "`v'"
            else         local eq
            if "`pvar'"!="" {
                sort `subpop' `pvar' `v' `exp'
                if `"`exp'"'!="" {
                    qui by `subpop' `pvar': gen `vtmp' = ///
                        sum(`exp'*`v')/sum(`exp') if `subpop'
                }
                else {
                    qui by `subpop' `pvar': gen `vtmp' = sum(`v')/_N if `subpop'
                }
                qui by `subpop' `pvar': replace `vtmp' = `vtmp'[_N] if `subpop'
            }
            else {
                sort `subpop' `v' `exp'
                local vtmp `v'
            }
            _Estimate `vtmp' `v' `wgt', `gini' qlbls(`qlbls')               ///
                touse(`touse') subpop(`subpop') offset(`offset')            ///
                pvar(`pvar') percentiles(`percentiles') `step'              ///
                `percent' rtype(`rtype') eqlab(`eq') uvars(`uvarsi')        ///
                normnum(`normnum') avar(`avar') normvar(`normvar')
            mat `S' = nullmat(`S') \ r(S)
            if "`gini'"!="" {
                mat `G'[`k_eq',1] = r(gini)
            }
            if "`pvar'"!="" drop `vtmp'
        }
    }
    else {
        tempname _N
        mat `_N' = J(`N_over'+("`total'"!=""), 1, .)
        mat rown `_N' = `overvals' `total'
        mat coln `_N' = "N"
        if "`gini'"!="" {
            tempname G
            mat `G' = `_N'
            mat coln `G' = "Gini"
        }
        local ytotal
        local wtotal
        if "`normpop'"!="" {
            if "`normpop'"=="total" local ifnormpop
            else local ifnormpop `" & `over'==`normpop'"'
            if "`normnum'"!="" {
                su `varlist' `swgt' if `subpop'`ifnormpop', meanonly
                tempname wtotal
                scalar `wtotal' = r(sum_w)
            }
            else if "`normvar'"!="" {
                su `normvar' `swgt' if `subpop'`ifnormpop', meanonly
                tempname ytotal wtotal
                scalar `ytotal' = r(sum)
                scalar `wtotal' = r(sum_w)
            }
            else {
                su `varlist' `swgt' if `subpop'`ifnormpop', meanonly
                tempname ytotal wtotal
                scalar `ytotal' = r(sum)
                scalar `wtotal' = r(sum_w)
            }
        }
        if "`pvar'"!="" {
            sort `subpop' `over' `pvar' `varlist' `exp'
            if `"`exp'"'!="" {
                qui by `subpop' `over' `pvar': gen `vtmp' = ///
                    sum(`exp'*`varlist')/sum(`exp') if `subpop'
            }
            else {
                qui by `subpop' `over' `pvar': gen `vtmp' = sum(`varlist')/_N if `subpop'
            }
            qui by `subpop' `over' `pvar': replace `vtmp' = `vtmp'[_N] if `subpop'
        }
        else {
            sort `subpop' `over' `varlist' `exp'
            local vtmp `varlist'
        }
        local k_eq 0
        local offseti `offset'
        foreach overval of local overvals {
            local ++k_eq
            local uvarsi
            if "`se'"=="" {
                forv i = 1/`ngrid' {
                    tempvar u
                    qui gen double `u' = .
                    local uvarsi `uvarsi' `u'
                }
                local uvars `uvars' `uvarsi'
            }
            _Estimate `vtmp' `varlist' `wgt', `gini' qlbls(`qlbls')         ///
                touse(`touse') subpop(`subpop') offset(`offseti')           ///
                pvar(`pvar') percentiles(`percentiles') `step'              ///
                `percent' rtype(`rtype') eqlab(`overval') uvars(`uvarsi')   ///
                normnum(`normnum') avar(`avar') normvar(`normvar')          ///
                normpop(`normpop') normavg(`normavg') over(`over')          ///
                overval(`overval') ytotal(`ytotal') wtotal(`wtotal')
            mat `_N'[`k_eq', 1] = r(N)
            mat `S' = nullmat(`S') \ r(S)
            if "`gini'"!="" {
                mat `G'[`k_eq',1] = r(gini)
            }
        }
        if "`total'"!="" {
            local ++k_eq
            if "`pvar'"!="" {
                drop `vtmp'
                sort `subpop' `pvar' `varlist' `exp'
                if `"`exp'"'!="" {
                    qui by `subpop' `pvar': gen `vtmp' = ///
                        sum(`exp'*`varlist')/sum(`exp') if `subpop'
                }
                else {
                    qui by `subpop' `pvar': gen `vtmp' = sum(`varlist')/_N if `subpop'
                }
                qui by `subpop' `pvar': replace `vtmp' = `vtmp'[_N] if `subpop'
            }
            else {
                sort `subpop' `varlist' `exp'
                local vtmp `varlist'
            }
            local uvarsi
            if "`se'"=="" {
                forv i = 1/`ngrid' {
                    tempvar u
                    qui gen double `u' = .
                    local uvarsi `uvarsi' `u'
                }
                local uvars `uvars' `uvarsi'
            }
            _Estimate `vtmp' `varlist' `wgt', `gini' qlbls(`qlbls')         ///
                touse(`touse') subpop(`subpop') offset(`offset')            ///
                pvar(`pvar') percentiles(`percentiles') `step'              ///
                `percent' rtype(`rtype') eqlab(total) uvars(`uvarsi')       ///
                normnum(`normnum') avar(`avar') normvar(`normvar')          ///
                normpop(`normpop') normavg(`normavg') over(`over')          ///
                ytotal(`ytotal') wtotal(`wtotal')
            mat `_N'[`k_eq', 1] = r(N)
            mat `S' = nullmat(`S') \ r(S)
            if "`gini'"!="" {
                mat `G'[`k_eq',1] = r(gini)
            }
        }
    }
    if "`se'"=="" {
        tempname V
        if "`svy'"!="" {
            qui svy, `svy2': total `uvars' if `touse'
        }
        else {
            qui total `uvars' `wgt' if `touse', `clustopt'
        }
        matrix `V' = e(V)
        local rank = e(rank)
        local df_r = e(df_r)
        if "`vce'"=="cluster" {
            local N_clust = e(N_clust)
        }
        if "`svy'"!="" {
            local svy_scalars
            foreach l in N_sub N_strata N_strata_omit singleton census N_pop ///
                         N_subpop N_psu N_poststrata stages {
                if e(`l')<. {
                    local svy_`l' = e(`l')
                    local svy_scalars `svy_scalars' `l'
                }
            }
            local svy_macros
            foreach l in prefix wtype wvar wexp singleunit strata psu fpc ///
                         poststrata postweight vce vcetype mse subpop adjust {
                local svy_`l' `"`e(`l')'"'
                local svy_macros `svy_macros' `l'
            }
            forv l=1/`svy_stages' {
                local svy_su`l' `"`e(su`l')'"'
                local svy_fpc`l' `"`e(fpc`l')'"'
                local svy_weight`l' `"`e(weight`l')'"'
                local svy_strata`l' `"`e(strata`l')'"'
                local svy_macros `svy_macros' su`l' fpc`l' weight`l' strata`l'
            }
            local svy_matrices
            foreach l in V_srs V_srssub V_srswr V_srssubwr _N_strata_single ///
                _N_strata_certain _N_strata _N_postsum _N_postsize {
                capt confirm matrix e(`l')
                if _rc==0 {
                    tempname svy_`l'
                    mat `svy_`l'' = e(`l')
                    local svy_matrices `svy_matrices' `l'
                }
            }
        }
    }
    tempname b
    mat `b' = `S'[1..., 2]'
    
    // post results
    if "`se'"=="" {
        local coln: colfullnames `b'
        mat coln `V' = `coln'
        mat rown `V' = `coln'
    }
    else if "`weight'"=="iweight" { // add empty e(V) for svy
        tempname V
        mat `V' = `b'' * `b' * 0
    }
    eret post `b' `V' `wgt', obs(`N') esample(`touse')
    eret local cmd "lorenz"
    eret local depvar "`varlist'"
    eret local pvar "`pvar'"
    eret local percentiles "`percentiles'"
    eret local step "`step'"
    eret local type "`rtype'"
    eret local percent "`percent'"
    eret local norm "`norm'`normnum'"
    if "`normpop'"!="" {
        if "`normpop'"=="total" eret local normpop total
        else eret local normpop "`over' = `normpop'"
        eret local normavg `normavg'
    }
    if      "`rtype'"=="generalized" local title "GL(p)"
    else if "`rtype'"=="absolute"    local title "AL(p)"
    else if "`rtype'"=="sum"         local title "TL(p)"
    else if "`rtype'"=="gap"         local title "p-L(p)"
    else                             local title "L(p)"
    if "`percent'"!=""               local title "`title'*100"
    if "`svy'"!=""                   local title "Survey: `title'"
    eret local title "`title'"
    eret scalar k_eq = `k_eq'
    eret scalar ngrid = `ngrid'
    tempname tmp
    mat `tmp' = `S'[1..., 1]'
    mat rown `tmp' = "`m'"
    eret mat p = `tmp'
    if "`over'"!="" {
        eret local total "`total'"
        eret local over_labels `"`over_labels'"'
        eret local over_namelist `"`overvals'"'
        eret local over "`over'"
        eret scalar N_over = `N_over'
        eret mat _N = `_N'
    }
    if "`gini'"!="" {
        eret local gini "gini"
        eret mat G = `G'
    }
    if "`se'"=="" {
        eret local vcetype "`vcetype'"
        eret local vce "`vce'"
        eret scalar rank = `rank'
        eret scalar df_r = `df_r'
        eret scalar level = `level'
        if "`vce'"=="cluster" {
            eret local clustvar "`clustvar'"
            eret scalar N_clust = `N_clust'
        }
        if "`svy'"!="" {
            foreach l of local svy_scalars {
                eret scalar `l' = `svy_`l''
            }
            foreach l of local svy_macros {
                eret local `l' `"`svy_`l''"'
            }
            foreach l of local svy_matrices {
                if substr("`l'", 1, 1)=="V" {
                    mat coln `svy_`l'' = `coln'
                    mat rown `svy_`l'' = `coln'
                }
                eret matrix `l' = `svy_`l''
            }
        }
    }
    Return_clear // for some reason -return clear- does not delete r(S)
end

program Parse_normalize
    syntax [anything(name=norm)] [, Average ]
    // get over from over:total
    gettoken normpop norm : norm, parse(":")
    if `"`normpop'"'==":" {
        local norm `":`norm'"'
        local normpop
        local average
    } 
    else if `"`normpop'"'=="." {
        local normpop
        local average
    }
    else if `"`norm'"'!="" {
        if substr("total", 1, strlen(`"`normpop'"'))==`"`normpop'"' {
            local normpop total
        }
    }
    if `"`norm'"'==":" {
        c_local norm
        c_local normpop `"`normpop'"'
        c_local normnum
        c_local normavg `average'
        exit
    }
    if `"`norm'"'=="" {
        local norm `":`normpop'"'
        local normpop
        local average
    }
    // get total from norm(over:total)
    gettoken norm 0 : norm, parse(":")
    local 0 `", norm(`0')"'
    capt syntax, norm(numlist max=1)    // norm(#)
    if _rc==0 {
        if `norm'==0 {
            di as err "normalize() cannot be 0"
            exit 198
        }
        c_local norm
        c_local normpop `"`normpop'"'
        c_local normnum `norm'
        c_local normavg `average'
        exit
    }
    syntax [, norm(str) ]
    if `"`norm'"'=="." local norm
    if `"`norm'"'=="*" | `"`norm'"'=="" {
        c_local norm `norm'
        c_local normpop `"`normpop'"'
        c_local normnum
        c_local normavg `average'
        exit
    }
    syntax, norm(varlist numeric)
    c_local norm `norm'
    c_local normpop `"`normpop'"'
    c_local normnum
    c_local normavg `average'
end

program Generate_avar
    syntax name(name=avar) [, touse(str) c(str) t(str) n(str) w(str) ]
    if "`t'"=="" local t 1
    if "`w'"=="" local w `touse'
    if "`c'"=="" {
        tempvar c
        qui gen double `c' = _n if `touse'
    }
    sort `touse' `c'
    // count number of clusters
    qui by `touse': gen double `avar' = sum(`c'!=`c'[_n-1]) if `touse'
    qui by `touse': replace    `avar' = `avar'[_N] if `touse'
    // aggregate weights within clusters
    qui by `touse' `c': replace `avar' = `avar' * sum(`w') if `touse'
    qui by `touse' `c': replace `avar' = `avar'[_N] if `touse'
    // invert
    qui replace `avar' = `t' / `avar' if `touse'
end

program _Estimate, rclass
    syntax varlist [pw iw fw/] [,                                           ///
        gini qlbls(str) touse(str) subpop(str) offset(str) pvar(str)        ///
        percentiles(str) step percent rtype(str) eqlab(str) uvars(str)      ///
        normnum(str) avar(str) normvar(str) normpop(str) normavg(str)       ///
        over(str) overval(str) ytotal(str) wtotal(str)  ]
    gettoken y y0 : varlist // in case of pvar(): y contains averaged values
    gettoken y0 : y0        //                    y0 contrains original values
    if ("`y'"=="`y0'") local y0
    local touse0 `touse'
    if "`over'"=="" local touse `subpop'
    else {
        if "`overval'"=="" local touse `subpop' // total
        else {
            tempvar touse
            qui gen byte `touse' = `subpop' & (`over'==`overval')
        }
        if "`normpop'"!="" {
            if "`normpop'"=="total" local touseR `subpop'
            else {
                tempvar touseR
                qui gen byte `touseR' = `subpop' & (`over'==`normpop')
            }
        }
    }
    tempname S
    mata: lorenz_compute() // sets matrix S and local N (and G), replaces uvars 
    mat rown `S' = `qlbls'
    if "`eqlab'"!="" {
        mat roweq `S' = "`eqlab'"
    }
    return scalar N = `N'
    return matrix S = `S'
    if "`gini'"!="" {
        return scalar gini = `G'
    }
    c_local offseti `offset'
end

program Return_clear, rclass
    local x
end

program Contrast_opt
    syntax [anything] [, Ratio LNRatio ]
    Contrast `anything' , `ratio' `lnratio'
end

program Contrast, eclass
    // syntax
    syntax [anything(name=base)] [, Ratio LNRatio Graph Graph2(str asis) * ]
    if `"`e(cmd)'"'!="lorenz" {
        di as err "last lorenz results not found"
        exit 301
    }
    if `"`e(contrast)'"'!="" {
        di as err "contrast already applied"
        exit 321
    }
    if "`lnratio'"!="" & "`ratio'"!="" {
        di as err "only one of ratio and lnratio allowed"
        exit 198
    }
    c_local cdiopts `options'
    if `"`graph2'"'!="" local graph graph
    c_local graph `graph'
    c_local graph2 `"`graph2'"'

    // parse base
    local varlist `"`e(depvar)'"'
    local ndepv: list sizeof varlist
    local over `"`e(over)'"'
    local N_over = e(N_over)
    local overvals `"`e(over_namelist)'"'
    local total `"`e(total)'"'
    if `"`over'"'=="" {
        if `ndepv'==1 {
            di as err "contrast not allowed with single outcome variable"
            exit 198
        }
    }
    else {
        if `N_over'==1 {
            di as err "contrast not allowed with single subpopulation"
            exit 198
        }
    }
    local baseval
    if `"`base'"'!="" {
        if `: list sizeof base'>1 {
            di as err `"contrast: `base' invalid"'
            exit 198
        }
        if substr(`"`base'"', 1, 1)=="#" {
            local baseval = substr(`"`base'"', 2, .)
            capt confirm integer number `baseval'
            if _rc {
                di as err `"contrast: `base' invalid"'
                exit 198
            }
            if `"`over'"'=="" {
                local baseval: word `baseval' of `varlist'
            }
            else {
                local baseval: word `baseval' of `overvals'
            }
        }
        else {
            if `"`over'"'=="" {
                capt unab baseval: `base'
                if _rc local baseval `"`base'"'
                if `: list baseval in varlist'==0 local baseval
            }
            else {
                local baseval `"`base'"'
                if `: list baseval in overvals'==0 local baseval
            }
        }
        if "`baseval'"=="" {
            di as err `"contrast: `base' invalid"'
            exit 498
        }
    }
    if "`baseval'"=="" {
        if `"`total'"'!="" local baseval total
        else               local baseval +
    }

    // transform results
    tempname b
    mat `b' = e(b)
    capt confirm matrix e(V)
    if _rc local se nose
    else {
        local se
        tempname V
        mat `V' = e(V)
    }
    local k_eq = e(k_eq)
    local --k_eq
    if "`se'"=="" & "`ratio'`lnratio'"!="" {
        Ratio_V `ratio'`lnratio' `b' `V' "`baseval'"
    }
    else {
        local ngrid = e(ngrid)
        local eqs: coleq `b'
        local eqs: list uniq eqs
        tempname B tmp tmp2
        matrix rename `b' `tmp'
        if "`baseval'"!="+" {
            matrix `B' = `tmp'[1...,"`baseval':"]
        }
        local eq0
        foreach eq of local eqs {
            if "`baseval'"=="`eq'" continue
            if "`baseval'"=="+" {
                if "`eq0'"=="" {
                    local eq0 "`eq'"
                    continue
                }
                else {
                    matrix `B' = `tmp'[1...,"`eq0':"]
                    local eq0 "`eq'"
                }
            }
            matrix `tmp2' = `tmp'[1...,"`eq':"]
            if "`ratio'"!="" {
                mata: st_replacematrix("`tmp2'", st_matrix("`tmp2'"):/st_matrix("`B'"))
            }
            else if "`lnratio'"!="" {
                mata: st_replacematrix("`tmp2'", ln(st_matrix("`tmp2'"):/st_matrix("`B'")))
            }
            else {
                matrix `tmp2' = `tmp2' - `B'
            }
            mat coleq `tmp2' = "`eq'"
            matrix `b' = nullmat(`b') , `tmp2'
        }
        matrix drop `B' `tmp' `tmp2'
        if "`se'"=="" {
            local eq0
            if "`baseval'"!="+" local eq0 "`baseval'"
            foreach eq of local eqs {
                if "`baseval'"=="+" & "`eq0'"=="" local eq0 "`eq'"
                if "`eq'"=="`eq0'" {
                    foreach eq1 of local eqs {
                        if "`eq1'"=="`eq0'" continue
                        mat `tmp' = nullmat(`tmp'), I(`ngrid') * -1
                    }
                }
                else {
                    foreach eq1 of local eqs {
                        if "`eq1'"=="`eq0'" continue
                        if "`eq1'"=="`eq'" {
                             mat `tmp' = nullmat(`tmp'), I(`ngrid')
                        }
                        else {
                            mat `tmp' = nullmat(`tmp'), J(`ngrid', `ngrid', 0)
                        }
                    }
                }
                matrix `B' = nullmat(`B') \ `tmp'
                matrix drop `tmp'
                if "`baseval'"=="+" local eq0 "`eq'"
            }
            matrix `V' = `B'' * `V' * `B'
            matrix drop `B'
        }
    }
    
    // Post results
    if "`se'"=="" {
        local coln: colfullnames `b'
        mat coln `V' = `coln'
        mat rown `V' = `coln'
    }
    Erepost `b' `V'
    eret scalar k_eq = `k_eq'
    eret local contrast contrast
    eret local baseval  "`baseval'"
    eret local ratio    "`ratio'"
    eret local lnratio  "`lnratio'"
    eret local _estimates_name ""
end

program Ratio_V, eclass
    tempname ecurrent
    _estimates hold `ecurrent', restore
    args ratio b V baseval
    if "`ratio'"=="lnratio" local ln ln
    local coln: colfullnames `b'
    mat coln `V' = `coln'
    mat rown `V' = `coln'
    local coefs: colnames `b'
    local coefs: list uniq coefs
    local eqs: coleq `b'
    local eqs: list uniq eqs
    eret post `b' `V'
    local coleq
    local coln
    local eq0
    if "`baseval'"!="+" local eq0 "`baseval'"
    foreach eq of local eqs {
        if "`baseval'"=="+" & "`eq0'"=="" local eq0 "`eq'"
        if "`eq'"=="`eq0'" continue
        foreach c of local coefs {
            if (_b[`eq':`c']==0) & (_b[`eq0':`c']==0) {
                local nlcom `nlcom' (`ln'(1))
            }
            else {
                local nlcom `nlcom' (`ln'(_b[`eq':`c']/_b[`eq0':`c']))
            }
            local coleq `coleq' `eq'
        }
        local coln `coln' `coefs'
        if "`baseval'"=="+" local eq0 "`eq'"
    }
    qui nlcom `nlcom'
    mat `b' = r(b)
    mat coleq `b' = `coleq'
    mat coln `b' = `coln'
    mat `V' = r(V)
end

program Erepost, eclass
    args b V
    
    //backup existing e()'s
    tempvar sample
    gen byte `sample' = e(sample)
    local emacros: e(macros)
    foreach emacro of local emacros {
        local e_`emacro' `"`e(`emacro')'"'
    }
    local escalars: e(scalars)
    foreach escalar of local escalars {
        tempname e_`escalar'
        scalar `e_`escalar'' = e(`escalar')
    }
    local ematrices: e(matrices)
    local bV "b V"
    local ematrices: list ematrices - bV
    foreach ematrix of local ematrices {
        tempname e_`ematrix'
        matrix `e_`ematrix'' = e(`ematrix')
    }
    
    // post results
    eret post `b' `V', esample(`sample')
    foreach emacro of local emacros {
        eret local `emacro' `"`e_`emacro''"'
    }
    foreach escalar of local escalars {
        eret scalar `escalar' = scalar(`e_`escalar'')
    }
    foreach ematrix of local ematrices {
        eret matrix `ematrix' = `e_`ematrix''
    }
end


version 11
mata mata set matastrict on
mata:

void lorenz_compute()  // sets matrix S and local N, replaces uvars 
{
    string scalar  rtype
    real scalar    step, fw, se, N, ytot, wtot, wtotR, G, offset, pct, avg
    real colvector y, Y, w, W, p, P
    real matrix    S
    pointer(real colvector) scalar pvar
    
    // setup
    rtype = st_local("rtype")
    pct   = (st_local("percent")!="")
    avg   = (st_local("normavg")!="")
    step  = (st_local("step")!="")
    fw    = (st_local("weight")=="fweight")
    se    = (st_local("uvars")!="")
    y = st_data(., st_local("y"), st_local("touse"))
    if (st_local("pvar")!="") {
        pvar = &(st_data(., st_local("pvar"), st_local("touse")))
    }
    else pvar = &y
    if (st_local("weight")!="") {
        w = st_data(., st_local("exp"), st_local("touse"))
        Y = quadrunningsum(y:*w)
        W = quadrunningsum(w)
        N = rows(y)
        if (fw | (st_local("weight")=="iweight")) N = W[N] // sets N to sum of weights
    }
    else {
        w = 1
        Y = quadrunningsum(y)
        N = rows(y)
        W = 1::N
    }
    if (st_local("normnum")!="")      ytot = strtoreal(st_local("normnum"))
    else if (st_local("ytotal")!="")  ytot = st_numscalar(st_local("ytotal"))
    else if (st_local("normvar")!="") ytot = quadsum(st_data(., st_local("normvar"), st_local("touse")))
    else                              ytot = Y[rows(Y)]
    wtot = W[rows(W)]
    wtotR = (st_local("wtotal")!="" ? st_numscalar(st_local("wtotal")) : wtot)
    p = strtoreal(tokens(st_local("percentiles")))'
    P = (p/100) * wtot

    // compute Lorenz ordinates
    S = p, J(rows(p), 1, .)                               // p, L
    if (se) S = S, J(rows(S), 2, .)
    if (step) {
        if (se)      lorenz_compute_step_se(S, *pvar, Y, W, P)
        else if (fw) lorenz_compute_step_fw(S, Y, W, P)
        else         S[,2] = lorenz_compute_step(Y, W, P)'
    }
    else {
        if (se) lorenz_compute_ipolate_se(S, *pvar, Y, W, P)
        else    S[,2] = lorenz_compute_ipolate(Y, W, P)'
    }
    
    // scaling
    if (rtype=="") {                        // L(p)
        if (avg) S[,2] = S[,2] / (ytot * (wtot/wtotR))
        else     S[,2] = S[,2] / ytot
    }
    else if (rtype=="gap") {                // p-L(p) 
        if (avg) S[,2] = S[,1]/100 :- (S[,2] / (ytot * (wtot/wtotR)))
        else     S[,2] = S[,1]*(wtot/wtotR)/100 :- (S[,2] / ytot)
    }
    else if (rtype=="generalized") {        // GL(p)
        S[,2] = S[,2] / wtot
    }
    else if (rtype=="absolute") {           // AL(p)
        S[,2] = (S[,2] :- S[,1]*ytot/100) / wtot
    }
    if (pct) S[,2] = S[,2] * 100

    // Gini
    if (st_local("gini")!="") {
        G = lorenz_cindex((st_local("y0")!="" ? 
            st_data(., st_local("y0"), st_local("touse")) : y),
            w, *pvar)
    }

    // set uvars
    if (se) {
        offset = strtoreal(st_local("offset"))
        S[,4] = S[,4] :+ offset
        lorenz_compute_uvars(S, ytot, wtot, wtotR, rtype, pct, avg)
        S = S[|1,1 \ .,2|]
        if (st_local("over")!="") 
            st_local("offset", strofreal(offset + rows(W), "%18.0g"))
    }
    
    // returns
    st_matrix(st_local("S"), S)
    st_local("N", strofreal(N, "%18.0g"))
    st_local("G", strofreal(G, "%18.0g"))
}

real rowvector lorenz_compute_step( // determine lorenz ordinates from step function
    real colvector Y,
    real colvector W,
    real colvector P)
{
    real scalar    i, j, r
    real rowvector res

    r = rows(P)
    res = J(1, r, .)
    if (P[1]==0) {
        res[1] = 0
        if (r==1) return(res)
       j = 2
    }
    else j = 1
    for (i=1; i<=rows(Y); i++) {
        while (P[j]<=W[i]) {
            res[j] = Y[i]
            j++
            if (j>r) break
        }
        if (j>r) break
    }
    return(res)
}

void lorenz_compute_step_se( // determine lorenz ordinates from step function
    real matrix    S,
    real colvector y, 
    real colvector Y,
    real colvector W,
    real colvector P)
{
    real scalar    i, j, r

    r = rows(P)
    if (P[1]==0) {
        S[1,] = J(1, 4, 0)
        if (r==1) return
        j = 2
    }
    else j = 1
    for (i=1; i<=rows(Y); i++) {
        while (P[j]<=W[i]) {
            S[j, 2] = Y[i]
            S[j, 3] = y[i] // for SEs
            S[j, 4] = i    // for SEs
            j++
            if (j>r) break
        }
        if (j>r) break
    }
}

void lorenz_compute_step_fw( // (interpolation to next integer)
    real matrix    S,
    real colvector Y,
    real colvector W,
    real colvector P)
{
    real scalar    i, j, r, Y0, W0

    r = rows(P)
    if (P[1]==0) {
        S[1, 2] = 0
        if (r==1) return
        j = 2
    }
    else j = 1
    W0 = 0
    Y0 = 0
    for (i=1; i<=rows(Y); i++) {
        while (P[j]<=W[i]) {
            if (i>1) {
                Y0 = Y[i-1]
                W0 = W[i-1]
            }
            S[j, 2] = Y0 + (Y[i] - Y0) * (ceil(P[j] - W0) / (W[i] - W0))
            j++
            if (j>r) break
        }
        if (j>r) break
    }
}

real rowvector lorenz_compute_ipolate( // determine lorenz ordinates using interpolation 
    real colvector Y,
    real colvector W,
    real colvector P)
{
    real scalar    i, j, r, Y0, W0
    real rowvector res

    r = rows(P)
    res = J(1, r, .)
    if (P[1]==0) {
        res[1] = 0
        if (r==1) return(res)
        j = 2
    }
    else j = 1
    W0 = Y0 = 0
    // if (Y[1]<0) Y0 = Y[1] // no extrapolation if y can be negative
    for (i=1; i<=rows(Y); i++) {
        while (P[j]<=W[i]) {
            if (i>1) {
                Y0 = Y[i-1]
                W0 = W[i-1]
            }
            res[j] = Y0 + (Y[i] - Y0) * ((P[j] - W0) / (W[i] - W0))
            // note: W[i]>W0 always true, even of some weights are zero
            j++
            if (j>r) break
        }
        if (j>r) break
    }
    return(res)
}

void lorenz_compute_ipolate_se( // determine lorenz ordinates using interpolation 
    real matrix    S,
    real colvector y, 
    real colvector Y,
    real colvector W,
    real colvector P)
{
    real scalar    i, j, r, y0, Y0, W0

    r = rows(P)
    if (P[1]==0) {
        S[1,] = J(1, 4, 0)
        if (r==1) return
        j = 2
    }
    else j = 1
    W0 = y0 = Y0 = 0
    // if (Y[1]<0) y0 = Y0 = Y[1] // no extrapolation if y can be negative
    for (i=1; i<=rows(Y); i++) {
        while (P[j]<=W[i]) {
            if (i>1) {
                y0 = y[i-1]
                Y0 = Y[i-1]
                W0 = W[i-1]
            }
            S[j, 2] = Y0 + (Y[i] - Y0) * ((P[j] - W0) / (W[i] - W0))
            // note: W[i]>W0 always true, even if some weights are zero
            S[j, 3] = y0 + (y[i] - y0) * ((P[j] - W0) / (W[i] - W0)) // for SEs
            S[j, 4] = i                                              // for SEs
            j++
            if (j>r) break
        }
        if (j>r) break
    }
}

void lorenz_compute_uvars( // sets the pseudo-variables for SE computation
    real matrix    S,
    real scalar    ytot,
    real scalar    wtot,
    real scalar    wtotR,
    string scalar  rtype,
    real scalar    pct,
    real scalar    avg)
{
    real scalar    j, b, touse, touse0, touseR, num, pop, nvar
    real rowvector id
    real colvector y, q, p, a, c, s, J, R
    real matrix    uvars
    
    // estimate E[Y|Z = Q_p] in case of pvar()
    if (st_local("pvar")!="" & st_local("pvar")!=st_local("y0")) {
        lorenz_compute_EY(S) // replaces S[,3]
    }

    // setup
    touse0 = st_varindex(st_local("touse0"))
    touse  = st_varindex(st_local("touse"))
    touseR = _st_varindex(st_local("touseR"))   // missing if not found
    nvar   = _st_varindex(st_local("normvar"))  // missing if not found
    num    = (st_local("normnum")!="")
    pop    = (st_local("normpop")!="")
    st_view(uvars, ., tokens(st_local("uvars")), touse0)
    y = st_data(., (st_local("y0")!="" ? st_local("y0") : st_local("y")), touse0)
    J = st_data(., touse, touse0)
    if (touseR<.) R = st_data(., touseR, touse0)
    s = S[,2]
    c = 0
    if (rtype=="" | rtype=="gap") {    // L(p) or p-L(p)
        if (num) {
            a = st_data(., st_local("avar"), touse0)
            if (pop & avg) {
                a = (a :+ ((ytot/wtot)*J :- (ytot/wtotR)*R)) * (wtot/wtotR)
            }
        }
        else {
            a = (nvar<. ? st_data(., nvar, touse0) : y)
            if (pop) {
                if (avg==0) a = a :* R
                else a = (a:*R :+ ((ytot/wtot)*J :- (ytot/wtotR)*R)) * (wtot/wtotR)
            }
            else a = a :* J
        }
        if (rtype=="gap" & pop & avg==0) {
            c = ((ytot/wtot)*J :- (ytot/wtotR)*R) * (wtot/wtotR)
        }
        if (avg) b = ytot * (wtot/wtotR)
        else     b = ytot
        if (rtype=="gap") _negate(s)
        if (pct) {
            if (rtype=="gap") {
                if (pop & avg==0) s = s :+ S[,1] * (wtot/wtotR)
                else              s = s :+ S[,1]
            }
            s = s / 100
            b = b / 100
        }
        else if (rtype=="gap") {
            if (pop & avg==0) s = s :+ (S[,1] * (wtot/wtotR) / 100)
            else              s = s :+ (S[,1] / 100)
        }
    }
    else if (rtype=="sum") {
        a = st_data(., st_local("avar"), touse0)
        b = 1
    }
    else if (rtype=="absolute") {
        a = J
        c = y :* J
        b = wtot
    }
    else /*if (rtype=="generalized")*/ {
        a = J
        b = wtot
    }
    
    // fill in uvars
    id = 1::rows(y)
    j = 1
    q = S[,3]
    p = S[,1] / 100
    for (j=1; j<=rows(S); j++) {
        if (S[j,1]==100) {  // q cancels out
            uvars[,j] = (y :* J :- (a :* s[j] :+ c :* p[j])) / b
        }
        uvars[,j] = (((y :- q[j]) :* (id :<= S[j,4]) :+ (p[j] * q[j])) :* J :- 
            (a :* s[j] :+ c :* p[j])) / b
    }
    if (rtype=="gap") _negate(uvars) // not really necessary
}

void lorenz_compute_EY(real matrix S) // estimate E[Y|Z = Q_p] using local linear regression
{
    real colvector q
    real scalar    a, b, preserve, rc
    string scalar  y, z, w, s, at, yhat
    
    y = st_local("y0")
    z = st_local("pvar")
    w = st_local("exp")
    s = st_local("touse")
    if (S[1,1]==0) {
        a = 2
        S[1,3] = 0
    }
    else a = 1
    b = rows(S)
    if (S[b,1]==100) {
        S[b,3] = 0
        b--
    }
    if (b<a) return
    q = S[|a,3 \ b,3|]
    preserve = (st_nobs()<rows(q))
    if (preserve) {
        stata("preserve")
        stata("quietly set obs " + strofreal(rows(q)))
    }
    at   = st_tempname()
    yhat = st_tempname()
    (void) st_addvar("double", at)
    st_store((1, rows(q)), at, q)
    if (w!="") {
        rc = _stata("lpoly " + y + " " + z + " [aw=" + w + "] if " + s +
            ", nograph degree(1) at(" + at + ") generate(" + yhat + ")", 1)
    }
    else {
        rc = _stata("lpoly " + y + " " + z + " if " + s +
            ", nograph degree(1) at(" + at + ") generate(" + yhat + ")", 1)
    }
    if (rc) S[|a,3 \ b,3|] = J(b-a+1, 1, .)
    else S[|a,3 \ b,3|] = lorenz_compute_EY_ipolate(st_data((1,rows(q)), yhat), q)
    lorenz_compute_EY_mean(S, a, b) // should only happen if n<=2 
    if (preserve) stata("restore")
}
real colvector lorenz_compute_EY_ipolate(real colvector y, real colvector x)
{   // interpolates y where y is missing (using linear interpolation)
    // missing values at the start (end) of y are set to the first (last) 
    // non-missing y value
    // x is assumed to be complete, free of ties, and sorted
    real scalar i, r, mi
    
    if (!hasmissing(y)) return(y)
    r = rows(y)
    mi = .
    for (i=1; i<=r; i++) {
        if (mi<.) {
            if (y[i]>=.) continue
            if (mi==1) y[|mi \ i-1|] = J(i-mi, 1, y[i]) // missings at start
            else       y[|mi \ i-1|] = y[mi-1] :+ (y[i] - y[mi-1]) :* 
                                (x[|mi \ i-1|] :- x[mi-1]) :/ (x[i] - x[mi-1])
            mi = .
            continue
        }
        if (y[i]>=.) mi = i
    }
    if (mi==1) return(y) // all missing
    if (mi<.) y[|mi \ r|] = J(i-mi, 1, y[mi-1]) // missings at end
    return(y)
}
void lorenz_compute_EY_mean(real matrix S, real scalar a, real scalar b)
{   // insert mean of y if there are still missings
    real scalar m
    
    if (!hasmissing(S[|a,3 \ b,3|])) return
    if (st_local("exp")=="") m = mean(st_data(., st_local("y0"), st_local("touse")))
    else m = mean(st_data(., st_local("y0"), st_local("touse")), 
                  st_data(., st_local("exp"), st_local("touse")))
    S[|a,3 \ b,3|] = editmissing(S[|a,3 \ b,3|], m)
}

// concentration (Gini) index (data must be sorted by y)
real scalar lorenz_cindex(real colvector x, real colvector w, real colvector y)
{   
    real matrix mv

    if (rows(x)<1) return(.)
    mv = lorenz_meanvar0((x, lorenz_ranks(y, w)), w)
    return(mv[3,1] * 2 / mv[1,1])
}
real matrix lorenz_meanvar0(real matrix X, real colvector w)
{
        real rowvector  CP
        real rowvector  means
        real scalar     n

        CP = quadcross(w,0, X,1)
        n  = cols(CP)
        means = CP[|1\n-1|] :/ CP[n]
        if (missing(means)) return(means \ J(cols(X),cols(X),.))
        return(means \ crossdev(X,0,means, w, X,0,means) :/ CP[n])
}
real colvector lorenz_ranks(real colvector x, real colvector w)
{   // assumes sorted input
    real scalar    i, r, lr
    real colvector ranks

    if (rows(x)==0) return(J(0,1,.))
    if (rows(w)!=1) ranks = runningsum(w)
    else            ranks = (1::rows(x)) * w
    // normalize ranks
    ranks = ranks / ranks[rows(x)]
    // lowest rank in case of ties
    for(i=rows(x)-1; i>=1; i--) {
        if (x[i]==x[i+1]) ranks[i] = ranks[i+1]
    }
    // compute midpoints
    r = ranks[1]
    ranks[1] =  r/2
    lr = r
    for(i=2; i<=rows(ranks); i++) {
        if (x[i]==x[i-1]) ranks[i] = ranks[i-1]
        else {
            r = ranks[i]
            ranks[i] = lr + (r-lr)/2
            lr = r
        }
    }
    return(ranks)
}

end

exit

