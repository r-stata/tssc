*! version 1.1.4  05jun2020  Ben Jann

local rc 0
capt findfile lmoremata.mlib
if _rc {
    di as error "-moremata- is required; type {stata ssc install moremata}"
    local rc = _rc
}
capt findfile lkdens.mlib
if _rc {
    di as error "-kdens- is required; type {stata ssc install kdens}"
    local rc = _rc
}
if `rc' error 499
capt findfile kmatch.ado
if _rc {
    di as error "-kmatch- is required; type {stata ssc install kmatch}"
    local rc = _rc
}
if `rc' error 499

program reldist, eclass properties(svyb svyj)
    version 12
    if replay() {
        Replay `0'
        exit
    }
    gettoken subcmd 0 : 0, parse(", ")
    if `"`subcmd'"'==substr("graph",1,max(2,strlen(`"`subcmd'"'))) {
        GRAPH `0'
        exit
    }
    if `"`subcmd'"'==substr("olabel",1,max(4,strlen(`"`subcmd'"'))) {
        OLABEL `0'
        exit
    }
    local version : di "version " string(_caller()) ":"
    Check_vceprefix `subcmd'`0'
    `version' _vce_parserun reldist, noeqlist wtypes(aw pw iw) ///
        bootopts(force reject(e(k_omit))) : `00'
    if "`s(exit)'" != "" {
        ereturn local cmdline `"reldist `subcmd'`0'"'
        exit
    }
    if `"`subcmd'"'=="pdf" {
        PDF `0'
    }
    else if `"`subcmd'"'==substr("histogram",1,max(4,strlen(`"`subcmd'"'))) {
        HIST `0'
    }
    else if `"`subcmd'"'=="cdf" {
        CDF `0'
    }
    else if `"`subcmd'"'=="mrp" {
        MRP `0'
    }
    else if `"`subcmd'"'==substr("summarize",1,max(2,strlen(`"`subcmd'"'))) {
        SUM `0'
    }
    else {
        di as err `"invalid subcommand: `subcmd'"'
        exit 198
    }
    eret local cmdline `"reldist `subcmd'`0'"'
    Replay, `diopts'
    if `"`e(generate)'"'!="" {
        di as txt "(relative ranks stored in variable {bf:`e(generate)'})"
    }
end

program Check_vceprefix
    _parse comma lhs 0 : 0
    syntax [, vce(str) Generate(passthru) ///
        n(passthru) at(passthru) atx ATX2(passthru) DISCRete CATegorical ///
        GRaph GRaph2(passthru) ///
        BWidth(str) BWADJust(passthru) NOSE * ]
    local options `generate' `n' `at' `atx' `atx2' `discrete' `categorical' /*
        */ `graph' `graph2' `nose' `options'
    if `"`vce'"'!="" {
        Parse_vceprefix `vce'
        if "`vcecmd'"!="" {
            if "`generate'"!="" {
                di as err "option {bf:generate()} not allowed with {bf:vce(`vcecmd')}"
                exit 198
            }
            if "`discrete'"!="" {
                if "`categorical'`n'`at'"=="" {
                    di as err "option {bf:discrete} only allowed with "/*
                        */"{bf:vce(`vcecmd')} if {bf:n()}, {bf:at()}, or "/*
                        */"{bf:categorical} is specified"
                    exit 198
                }
            }
            else if `"`atx'`atx2'"'!="" {
                if "`categorical'"=="" {
                    di as err "option {bf:atx()} not allowed with {bf:vce(`vcecmd')}"
                    exit 198
                }
            }
            if `"`graph'`graph2'"'!="" {
                di as err "option {bf:graph} not allowed with {bf:vce(`vcecmd')}"
                exit 198
            }
            if "`nose'"=="" {
                local options nose `options'
            }
            Obtain_bwidth `lhs', _vcevars(`vcevars') ///
                bwidth(`bwidth') `bwadjust' `options'
        }
        local options vce(`vce') `options'
    }
    if `"`bwidth'"'!="" {
        local bwidth bwidth(`bwidth')
    }
    c_local 00 `lhs', `bwidth' `bwadjust' `options'
end

program Parse_vceprefix
    _parse comma vcecmd 0 : 0
    if `"`vcecmd'"'== substr("bootstrap",1,max(4,strlen(`"`vcecmd'"'))) {
        c_local vcecmd bootstrap
    }
    else if `"`vcecmd'"'== substr("jackknife",1,max(4,strlen(`"`vcecmd'"'))) {
        c_local vcecmd jackknife
    }
    else exit
    syntax [, STRata(varlist) CLuster(varlist) group(varname) JACKknifeopts(str) * ]
    Parse_vceopt_jack, `jackknifeopts'  // returns vcevars
    c_local vcevars `vcevars' `strata' `cluster' `group'
end

program Parse_vceopt_jack
    syntax [, CLuster(varlist) * ]
    c_local vcevars `cluster'
end

program Obtain_bwidth   // returns bwidth, bwadjust
    gettoken subcmd 0 : 0, parse(", ")
    if `"`subcmd'"'!="pdf" exit
    syntax [anything] [if] [in] [fw iw aw pw] [, _vcevars(str) bwidth(str) ///
        DISCRete CATegorical * ]
    if "`discrete'`categorical'"!="" exit
    capt confirm number `bwidth'
    if _rc==0 exit
    di as txt "(running {bf:reldist} to obtain bandwith)"
    marksample touse
    markout `touse' `_vcevars', strok
    qui PDF `anything' if `touse' [`weight'`exp'], `options'
    c_local bwidth = e(bwidth)
    c_local bwadjust
end

program Replay
    if `"`e(cmd)'"'!="reldist" {
        di as err "last reldist results not found"
        exit 301
    }
    local subcmd `"`e(subcmd)'"'
    if !inlist(`"`subcmd'"', "pdf", "histogram", "cdf", "mrp", "summarize") {
        di as err "last reldist results not found"
        exit 301
    }
    syntax [, Level(passthru) noHeader NOTABle TABle GRaph GRaph2(str asis) * ]
    if `"`graph2'"'!="" local graph graph
    if `"`level'"'=="" {
        if `"`e(level)'"'!="" {
            local level level(`e(level)')
        }
    }
    local options `level' `options'
    if "`header'"=="" {
        if `"`e(by)'"'!="" {
            local by `"`e(by)'"'
            if `"`e(by1lab)'"'!="" local by1 `"`e(by1lab)'"'
            else                   local by1 `"`e(by1)'"'
            if `"`e(by0lab)'"'!="" local by0 `"`e(by0lab)'"'
            else                   local by0 `"`e(by0)'"'
            local lby  = strlen(`"`by'"')
            local lbyl = max(strlen(`"`by1'"'), strlen(`"`by0'"'))
            local ll   = `lby' + `lbyl' + 3
            if `ll'>31 {
                if `lby'<=14 {
                    local by1  = abbrev(`"`by1'"', 28 - `lby')
                    local by0  = abbrev(`"`by0'"', 28 - `lby')
                }
                else if `lbyl'<=14 {
                    local by   = abbrev(`"`by'"', 28 - `lbyl')
                    local lby  = strlen(`"`by'"')
                }
                else {
                    local by   = abbrev(`"`by'"', 14)
                    local lby  = 14
                    local by1  = abbrev(`"`by1'"', 14)
                    local by0  = abbrev(`"`by0'"', 14)
                }
            }
            local ll = `lby' + strlen(`"`by0'"') + 3
            local line1 `"`by' = {res:`by1'}"'
            local line2 `"`by' = {res:`by0'}"'
        }
        else {
            local line1 = abbrev(`"`e(depvar)'"', 31)
            local line1 `"{res:`line1'}"'
            local line2 = abbrev(`"`e(refvar)'"', 31)
            local ll = strlen(`"`line2'"')
            local line2 `"{res:`line2'}"'
        }
        local line1 `" F comparison: `line1'"'
        local line2 `" F0 reference: `line2'"'
        local j 2
        if `"`e(pooled)'"'!="" {
            if `ll'<=22 {
                local line2 `"`line2' (pooled)"'
            }
            else {
                local ++j
                local line`j' "               (pooled)"
            }
        }
        if `"`e(adjust)'`e(refadjust)'"'!="" {
            local ++j
            if `"`e(adjust)'"'!=""    local line`j' `"{res:`e(adjust)'}"'
            else                      local line`j' `"(none)"'
            local line`j' `" Adjustment F: `line`j''"'
            local ++j
            if `"`e(refadjust)'"'!="" local line`j' `"{res:`e(refadjust)'}"'
            else                      local line`j' `"(none)"'
            local line`j' `"           F0: `line`j''"'
            local adjopts `"`e(adjmean)' `e(adjsd)' `e(adjmult)' `e(adjlog)'"'
            local adjopts: list retok adjopts
            if `"`adjopts'"'!="" {
                local ++j
                local line`j' `"         type: {res:`adjopts'}"'
            }
        }
        if `"`e(balance)'"'!="" {
            local ++j
            local line`j' " Balancing"
            if `"`e(balref)'"'!="" local line`j' `"`line`j'' F0"'
            else                   local line`j' `"`line`j''  F"'
            local line`j' `"`line`j'': method = {res:`e(balmethod)'}"'
            local ++j
            
            local xvars = abbrev(`"`e(balance)'"',31)
            local line`j' "        xvars: `xvars'"
        }
        _coef_table_header
        local i 0
        if `"`e(by)'"'!="" {
            di as txt `"`line`++i''"' /*
                */ as txt _col(49) "Comparison obs" _col(67) "= " as res %10.0gc e(N1)
            di as txt `"`line`++i''"' /*
                */ as txt _col(49) "Reference obs"  _col(67) "= " as res %10.0gc e(N0)
        }
        if "`subcmd'"=="pdf" {
            if `"`e(discrete)'"'=="" {
                di as txt `"`line`++i''"' /*
                    */ as txt _col(49) "Bandwidth" _col(67) "= " as res %10.0g e(bwidth)
            }
            if `"`e(divergence)'"'!="" {
                di as txt `"`line`++i''"' /*
                    */ as txt _col(49) "Divergence" _col(67) "= " as res %10.0g e(divergence)
            }
            if `"`e(chi2)'"'!="" {
                di as txt `"`line`++i''"' /*
                    */ as txt _col(49) "Chi-squared" _col(67) "= " as res %10.0g e(chi2)
            }
        }
        while (`i'<`j') { // flush remaining lines
            if `"`line`++i''"'=="" continue, break
             di as txt `"`line`i''"'
        }
        if `"`e(over)'"'!="" {
            _svy_summarize_legend
        }
        else di ""
    }
    if ("`table'"!="" | "`graph'"=="") & "`notable'"=="" {
        if `"`subcmd'"'=="pdf" {
            capt confirm matrix e(V)
            if _rc {
                capt confirm matrix e(se)
                if _rc==0 {
                    tempname V
                    mat `V' = e(se)
                    mata: st_replacematrix("`V'", st_matrix("`V'"):^2)
                    mat `V' = diag(`V')
                    local vmatrix vmatrix(`V')
                    if c(stata_version)<12 {
                        tempname b
                        mat `b' = e(b)
                        local vmatrix bmatrix(`b') `vmatrix'
                    }
                }
            }
        }
        _coef_table, `vmatrix' `options'
        capt confirm matrix e(at)
        if _rc==0 {
            di as txt "(evaluation grid stored in {stata matrix list e(at):{bf:e(at)}})"
        }
    }
    else if "`notable'"=="" {
        di as txt "(coefficients table suppressed)"
    }
    if "`graph'"!="" {
        GRAPH, `graph2'
    }
end

program GRAPH
    if `"`e(cmd)'"'!="reldist" {
        di as err "last {bf:reldist} results not found"
        exit 301
    }
    local subcmd `"`e(subcmd)'"'
    if !inlist(`"`subcmd'"', "pdf", "histogram", "cdf") {
        di as err `"{bf:reldist graph} not supported after {bf:reldist `subcmd'}"'
        exit 499
    }
    GRAPH_`subcmd' `0'
end

program _GRAPH_get_gropts // separate general twoway options from other options
                          // returns twopts, options
    _get_gropts, graphopts(`0') gettwoway
    local twopts `s(twowayopts)'
    local 0 `", `s(graphopts)'"'
    // parse some additional options that do not seem to be covered by
    // _get_gropts, gettwoway; this possibly has to be updated for
    // future Stata versions
    syntax [, ///
        LEGend(passthru)     ///
        play(passthru)       ///
        PCYCle(passthru)     ///
        YVARLabel(passthru)  ///
        XVARLabel(passthru)  ///
        YVARFormat(passthru) ///
        XVARFormat(passthru) ///
        YOVERHANGs           ///
        XOVERHANGs           ///
        /// recast(passthru)     ///
        fxsize(passthru)     ///
        fysize(passthru) * ]
    c_local twopts `twopts' `legend' `play' `pcycle' `yvarlabel' `xvarlabel'/*
        */ `yvarformat' `xvarformat' `yoverhangs' `fxsize' `fysize'
    c_local options `options'
end

program _GRAPH_get_CI // obtain CI, if available
                      // returns hasci, hashci
    args ll ul n offset level noci ci nhist nohci
    if "`nhist'"=="" local nohci nohci
    if "`noci'"!="" & "`nohci'"!="" {
        c_local hasci
        c_local hashci
        exit
    }
    if "`ci'"!="" {
        if `"`level'"'!="" {
            di as err "{bf:ci()} and {bf:level()} not both allowed"
            exit 198
        }
        capt confirm matrix e(`ci')
        if _rc {
            di as error "matrix e(`ci') not found"
            exit 111
        }
        if rowsof(e(`ci'))!=2 | colsof(e(`ci'))!=(`n'-("`offset'"!="")) {
            di as error "matrix e(`ci') not conformable"
            exit 499
        }
        tempname CI
        mat `CI' = e(ci)'
        local hasci hasci
    }
    else {
        if `"`level'"'=="" {
            if `"`e(level)'"'!="" {
                local level level(`e(level)')
            }
        }
        capt confirm matrix e(V)
        if _rc {
            capt confirm matrix e(se)
            if _rc==0 {
                tempname V
                mat `V' = e(se)
                mata: st_replacematrix("`V'", st_matrix("`V'"):^2)
                mat `V' = diag(`V')
                if c(stata_version)<12 {
                    tempname b
                    mat `b' = e(b)
                    qui _coef_table, bmatrix(`b')  vmatrix(`V') `level'
                }
                else {
                    qui _coef_table, vmatrix(`V') `level'
                }
                local hasci hasci
            }
        }
        else {
            qui _coef_table, `level'
            local hasci hasci
        }
        if "`hasci'"!="" {
            tempname CI
            mat `CI' = r(table)'
            mat `CI' = `CI'[1..., 5..6]
        }
    }
    if "`hasci'"!="" {
        if ("`offset'"!="") {
            if `"`e(subcmd)'"'=="cdf" {
                mat `CI' = (0,0) \ `CI'
            }
            else if `"`e(subcmd)'"'=="pdf" {
                mat `CI' = `CI'[1,1...] \ `CI'
            }
        }
        mata: rd_svmat("`CI'", ("`ll'", "`ul'"), 0)
    }
    else {
        c_local hasci
        c_local hashci
        exit
    }
    if "`noci'"=="" c_local hasci hasci
    else            c_local hasci
    if "`nohci'"=="" {
        local a = `n' - `nhist' + 1
        su `ll' in `a'/`n', meanonly // check whether CI exists
        if r(N) c_local hashci hashci
        else    c_local hashci
    }
    else c_local hashci
end

program _GRAPH_olab // returns oaxis, twopts
    _parse comma xy 0 : 0
    syntax [, `xy'olabel(str asis) `xy'otick(str asis) `xy'otitle(str asis) * ]
    if "`xy'"=="y" {
        local olabel `"`yolabel'"'
        local otick `"`yotick'"'
        local otitle `"`yotitle'"'
    }
    local twopts `options'
    // otitle
    _parse comma otitle 0 : otitle
    syntax [, * ]
    if `"`otitle'"'=="" local otitle `""""'
    local otitle  `"`otitle'"'
    local otiopts `"`options'"'
    // olabel and otick
    if `"`olabel'"'!="" {
        local 0 `"`olabel'"'
        syntax [anything] [, FORmat(passthru) * ]
        local olabel `"`anything'"'
        local olabopts `"`options'"'
    }
    if `"`otick'"'!="" {
        local 0 `"`otick'"'
        syntax [anything] [, * ]
        local otick `"`anything'"'
        local otickopts `"`options'"'
    }
    if `"`olabel'`otick'"'=="" exit     // nothing to do
    if `"`e(atx)'"'=="" {
        capt confirm matrix e(ogrid)
        if _rc==1 exit _rc
        if _rc {
            di as txt "(matrix {bf:e(ogrid)} does not exist; cannot compute outcome positions)"
            exit
        }
    }
    OLABEL `"`olabel'"', otick(`"`otick'"') `format' `xy'
    local olabel `"`r(label)'"'
    local otick  `"`r(tick)'"'
    // returns
    if "`xy'"=="" local xy x
    if `"`olabel'"'!="" {
        local twopts `xy'label(`olabel', axis(2) `olabopts') `twopts'
    }
    else {
        local twopts `xy'label(none, axis(2)) `twopts'
    }
    if `"`otick'"'!="" {
        local twopts `xy'tick(`otick', axis(2) `otickopts') `twopts'
    }
    c_local oaxis `xy'axis(1 2) // add to each plot so that axes do not move
    c_local twopts `xy'title(`otitle', axis(2) `otiopts') `twopts'
end

program _GRAPH_xyti // return xti, yti
    if `"`e(by)'"'=="" {
        local xti `"`e(refvar)'"'
        if `"`e(pooled)'"'!="" {
            local xti `"`xti' (pooled)"'
        }
        c_local xti `"`xti'"'
        c_local yti `"`e(depvar)'"'
    }
    else {
        if `"`e(by0lab)'"'!="" {
            local xti `"`e(by0lab)'"'
        }
        else {
            local xti `"`e(by)' = `e(by0)'"'
        }
        if `"`e(pooled)'"'!="" {
            local xti `"`xti' (pooled)"'
        }
        c_local xti `"`xti'"'
        if `"`e(by1lab)'"'!="" {
            c_local yti `"`e(by1lab)'"'
        }
        else {
            c_local yti `"`e(by)' = `e(by1)'"'
        }
    }
end

program GRAPH_pdf
    // syntax
    syntax [, Level(passthru) NOCI ci(name) CIOPTs(str) ///
        NOREFline REFline(str) NOHISTogram HISTopts(str) ///
        OLABel(passthru) OTICk(passthru) OTItle(passthru) ///
        addplot(str asis) * ]
    _GRAPH_pdf_histopts, `histopts'
    _GRAPH_get_gropts `options'
     
    // obtain original scale labels
    _GRAPH_olab, `olabel' `otick' `otitle' `twopts'
    
    // get data
    local npdf = e(n)
    tempname B AT
    mat `B' = e(b)'
    mat `AT' = e(at)'
    mat `AT' = `AT'[1...,1]
    if `"`e(discrete)'"'!="" {
        if `AT'[1,1]!=0 {
            mat `B' = `B'[1,1] \ `B'
            mat `AT' = 0 \ `AT'
            local ++npdf
            local offset offset
        }
    }
    local nhist = e(n_hist)
    if `nhist'>=. {
        local nhist
        local nohistogram nohistogram
    }
    
    // check number of obs and expand data if necessary
    local n = rowsof(`B')
    if `n'>_N {
        preserve
        qui set obs `n'
    }
    
    // store results to data
    tempname pdf at
    mata: rd_svmat("`B'", "`pdf'", 0)
    mata: rd_svmat("`AT'", "`at'", 0)
    
    // obtain CI if available
    tempname ll ul
    _GRAPH_get_CI `ll' `ul' `n' "`offset'" `"`level'"' "`noci'" "`ci'" ///
        "`nhist'" "`nohci'"
    
    // compile graph
    if `"`e(discrete)'"'!="" local connect connect(stepstair)
    else                     local connect
    local plots
    // - refline
    if "`norefline'"=="" {
        local yline yline(1, `refline')
    }
    // - histogram bars
    if "`nohistogram'"=="" {
        local hwidth = e(hwidth)
        local a = `npdf' + 1
        local plots `plots' /*
            */ (bar `pdf' `at' in `a'/`n', `oaxis'/*
            */ barwidth(`hwidth') pstyle(histogram) `histopts')
        if "`hashci'"!="" {
            local plots `plots' /*
                */ (rcap `ll' `ul' `at' in `a'/`n', `oaxis'/*
                */ pstyle(histogram) `hciopts')
        }
    }
    // - CI
    if "`hasci'"!="" {
        local plots `plots' /*
            */ (rarea `ll' `ul' `at' in 1/`npdf', `oaxis'/*
            */ pstyle(ci) `connect' `ciopts')
    }
    // - pdf
    local plots `plots' /*
        */ (line `pdf' `at' in 1/`npdf', `oaxis'/*
        */ pstyle(p1) `connect' `options')
    // - addplot
    if `"`addplot'"'!="" {
        local plots `plots' || `addplot' ||
    }
    // - axis titles
    _GRAPH_xyti
    // - draw
    twoway `plots', legend(off) `yline' xtitle(`"`xti'"') ytitle(`"`yti'"') ///
        ylabel(0, add) `twopts'
end

program _GRAPH_pdf_histopts
    syntax [, NOCI CIOPTs(str) * ]
    c_local nohci `noci'
    c_local hciopts `ciopts'
    c_local histopts `options'
end

program GRAPH_histogram
    // syntax
    syntax [, Level(passthru) NOCI ci(name) CIOPTs(str) ///
        NOREFline REFline(str) ///
        OLABel(passthru) OTICk(passthru) OTItle(passthru) ///
        addplot(str asis) * ]
    _GRAPH_get_gropts `options'
     
    // obtain original scale labels
    _GRAPH_olab, `olabel' `otick' `otitle' `twopts'
    
    // check number of obs and expand data if necessary
    local n = e(n_hist)
    if `n'>_N {
        preserve
        qui set obs `n'
    }
    
    // store results to data
    tempname pdf at
    mata: rd_svmat("e(b)", "`pdf'", 1)
    mata: rd_svmat("e(at)", "`at'", 1)
    
    // obtain CI if available
    tempname ll ul
    _GRAPH_get_CI `ll' `ul' `n' "" `"`level'"' "`noci'" "`ci'"
    
    // compile graph
    local plots
    // - refline
    if "`norefline'"=="" {
        local yline yline(1, `refline')
    }
    // - histogram bars
    local hwidth = e(hwidth) 
    local plots `plots' /*
        */ (bar `pdf' `at' in 1/`n', `oaxis'/*
        */ barwidth(`hwidth') pstyle(histogram) `options')
    // - CI
    if "`hasci'"!="" {
        local plots `plots' /*
            */ (rcap `ll' `ul' `at' in 1/`n', `oaxis'/*
            */ pstyle(histogram) `ciopts')
    }
    // - addplot
    if `"`addplot'"'!="" {
        local plots `plots' || `addplot' ||
    }
    // - axis titles
    _GRAPH_xyti
    // - draw
    twoway `plots', legend(off) `yline' xtitle(`"`xti'"') ytitle(`"`yti'"') ///
        ylabel(0, add) `twopts'
end

program GRAPH_cdf
    // syntax
    syntax [, Level(passthru) NOCI ci(name) CIOPTs(str) ///
        NOREFline REFline(str) NOORIGin ///
        OLABel(passthru) OTICk(passthru) OTItle(passthru) ///
        YOLABel(passthru) YOTICk(passthru) YOTItle(passthru) ///
        addplot(str asis) * ]
    _GRAPH_get_gropts `options'
    
    // obtain original scale labels
    _GRAPH_olab, `olabel' `otick' `otitle' `twopts'
    local oaxis0 `oaxis'
    local oaxis
    _GRAPH_olab y, `yolabel' `yotick' `yotitle' `twopts'
    local oaxis `oaxis' `oaxis0'
    
    // get coordinates
    tempname B AT
    mat `B' = e(b)'
    mat `AT' = e(at)'
    mat `AT' = `AT'[1...,1]
    if "`noorigin'"=="" {
        if `"`e(origin)'"'!="" {
            mat `B'  = 0 \ `B'
            mat `AT' = 0 \ `AT'
            local offset offset
        }
    }
    
    // check number of obs and expand data if necessary
    local n = rowsof(`B')
    if `n'>_N {
        preserve
        qui set obs `n'
    }
    
    // store results to data
    tempname cdf at
    mata: rd_svmat("`B'", "`cdf'", 0)
    mata: rd_svmat("`AT'", "`at'", 0)
    
    // obtain CI if available
    tempname ll ul
    _GRAPH_get_CI `ll' `ul' `n' "`offset'" `"`level'"' "`noci'" "`ci'" 
    
    // compile graph
    local plots
    // - refline
    if "`norefline'"=="" {
        local plots `plots' /*
            */ (scatteri 0 0 1 1, `oaxis'/*
            */ connect(l) ms(i) lstyle(xyline) `refline')
    }
    // - CI
    if "`hasci'"!="" {
        local plots `plots' /*
            */ (rarea `ll' `ul' `at' in 1/`n', `oaxis'/*
            */ connect(J) pstyle(ci) `ciopts')
    }
    // - cdf
    local plots `plots' /*
        */ (line `cdf' `at' in 1/`n', `oaxis'/*
        */ pstyle(p1) `options')
    // - addplot
    if `"`addplot'"'!="" {
        local plots `plots' || `addplot' ||
    }
    // - axis titles
    _GRAPH_xyti
    // - draw
    twoway `plots', legend(off) xtitle(`"`xti'"') ytitle(`"`yti'"') ///
        `twopts'
end

program OLABEL, rclass
    if `"`e(cmd)'"'!="reldist" {
        di as err "last {bf:reldist} results not found"
        exit 301
    }
    _parse comma lhs 0 : 0
    syntax [, OTICk(numlist sort) FORmat(str) y ]
    if "`y'"!="" {
        if `"`e(subcmd)'"'!="cdf" {
            di as err "option {bf:y} only allowed after {bf:reldist cdf}"
            exit 499
        }
    }
    return local tick_x `"`otick'"'
    if `"`format'"'=="" local format "%6.0g"
    confirm format `format'
    local 0 `", olabel(`lhs')"'
    syntax [, OLABel(numlist sort) ]
    return local label_x `"`olabel'"'
    if `"`olabel'`otick'"'=="" exit // nothing to do
    local atx = (`"`e(atx)'"'!="")
    if (`atx'==0) {
        capt confirm matrix e(ogrid)
        if _rc==1 exit _rc
        if _rc {
            di as txt "matrix {bf:e(ogrid)} does not exist; cannot" /*
                */ " compute outcome positions"
            exit 499
        }
        if "`y'"!="" {
            if rowsof(e(ogrid))<2 {
                di as err "matrix {bf:e(ogrid)} has only one row; cannot" /*
                    */ " compute outcome positions for comparison group"
                exit 499
            }
        }
    }
    mata: rd_olab("`y'"!="", `atx', "olabel", "`format'")
    mata: rd_olab("`y'"!="", `atx', "otick", "")
    return local label `"`olabel'"'
    return local tick  `"`otick'"'
end

program Parse_syntax    // preprocess syntax: two-sample vs. paired
                        // returns under syntax 1: 0, depvar, by, swap, pooled
                        // returns under syntax 2: 0, depvar, refvar, pooled
    syntax varlist(min=1 max=2 numeric) [if] [in] [fw iw aw pw] ///
        [, by(varname numeric) swap POOLed * ]
    // Syntax 1: two-sample
    if `"`by'"'!="" {
        if `:list sizeof varlist'>1 {
            di as err "{it:refvar} and {bf:by()} not both allowed"
            exit 198
        }
        c_local 0 `if' `in' [`weight'`exp'], `options'
        c_local depvar `varlist'
        c_local by     `by'
        c_local swap   `swap'
        c_local pooled `pooled'
        exit
    }
    // Syntax 2: paired
    if `:list sizeof varlist'==1 {
        di as err "{bf:by()} or {it:refvar} required"
        exit 198
    }
    if "`swap'"!="" {
        di as err "{bf:swap} not allowed in syntax 2"
        exit 198
    }
    c_local 0 `if' `in' [`weight'`exp'], `options'
    c_local depvar: word 1 of `varlist'
    c_local refvar: word 2 of `varlist'
    c_local pooled `pooled'
end

program Parse_adjust // parse the adjust() option
                     // returns adj1, ads0, adjmean, adjsd, adjlog, adjmult
    capt n syntax [anything] [, mean sd LOGarithmic MULTiplicative ]
    if _rc==1 exit _rc
    if _rc {
        di as err "(error in option {bf:adjust()})"
        exit 198
    }
    if "`logarithmic'"!="" & "`multiplicative'"!="" {
        di as err "only one of {bf:logarithmic} and {bf:multiplicative} allowed"
        di as err "(error in option {bf:adjust()})"
        exit 198
    }
    local k 1
    while (`"`anything'"'!="") {
        gettoken tok anything: anything, parse(": ")
        if `"`tok'"'==":" {    // start of reference adjustment
            local k 0
            continue
        }
        if `"`tok'"'==substr("location",1,max(1,strlen(`"`tok'"'))) {
            local tok location
        }
        else if `"`tok'"'==substr("scale",1,max(2,strlen(`"`tok'"'))) {
            local tok scale
            if "`multiplicative'"!="" {
                di as err "'scale' not with option {bf:multiplicative}"
                di as err "(error in option {bf:adjust()})"
                exit 198
            }
        }
        else if `"`tok'"'==substr("shape",1,max(2,strlen(`"`tok'"'))) {
            local tok shape
        }
        else if `"`tok'"'!="" {
            di as err "'" `"`tok'"' "' not allowed"
            di as err "(error in option {bf:adjust()})"
            exit 198
        }
        local adj`k' `adj`k'' `tok'
    }
    local adj1: list uniq adj1
    local adj0: list uniq adj0
    local adj1: list sort adj1
    local adj0: list sort adj0
    if "`adj0'`adj1'"=="" {
        local mean
        local logarithmic
        local multiplicative
    }
    c_local adj1: list sort adj1
    c_local adj0: list sort adj0
    c_local adjmean `mean'
    c_local adjsd   `sd'
    c_local adjlog  `logarithmic'
    c_local adjmult `multiplicative'
end

program Parse_at   // parse n(), at(), atx, atx(), categorical, descrete
                   // returns n, ATX0, atx, AT0, at, categorical, discrete
    args n at atx atx2 discrete categorical
    if `"`discrete'`categorical'"'!="" {
        c_local discrete discrete // categorical implies discrete
        if `"`n'`at'`atx2'"'=="" {
            c_local atx atx // discrete/categorical implies atx by default
            exit
        }
    }
    if `"`atx'`atx2'"'!="" {
        if "`n'"!="" {
            di as err "{bf:n()} and {bf:atx()} not both allowed"
            exit 198
        }
        if `"`at'"'!="" {
            di as err "{bf:at()} and {bf:atx()} not both allowed"
            exit 198
        }
        if `"`atx2'"'=="" exit // atx without argument; use observed values
        c_local atx atx
        if `: list sizeof atx2'==1 {
            capt confirm matrix `atx2'
            if _rc==1 exit _rc
            if _rc==0 {
                if "`categorical'"!="" {
                    capt mata: rd_check_mat("`atx2'", 1)
                    if _rc==1 exit _rc
                    if _rc {
                        di as err "noninteger or negative values not allowed"/*
                            */ " in {bf:atx()} is {bf:categorical} is specified"
                        exit 125
                    }
                }
                c_local ATX0 `atx2'
                c_local atx2
                exit
            }
        }
        local 0 `", atx(`atx2')"'
        syntax [, atx(numlist ascending) ]
        if "`categorical'"!="" {
            capt numlist "`atx'", integer range(>=0)
            if _rc==1 exit _rc
            if _rc {
                di as err "noninteger or negative values not allowed"/*
                    */ " in {bf:atx()} is {bf:categorical} is specified"
                exit 125
            }
        }
        c_local atx2 "`atx'"
        exit
    }
    if `"`at'"'!="" {
        if "`n'"!="" {
            di as err "{bf:n()} and {bf:at()} not both allowed"
            exit 198
        }
        if `: list sizeof at'==1 {
            capt confirm matrix `at'
            if _rc==1 exit _rc
            if _rc==0 {
                capt mata: rd_check_mat("`at'", 0)
                if _rc==1 exit _rc
                if _rc {
                    di as err "values provided in {bf:at()} must be in [0,1]"
                    exit 125
                }
                c_local AT0 `at'
                c_local at
                exit
            }
        }
        local 0 `", at(`at')"'
        syntax [, at(numlist ascending >=0 <=1) ]
        c_local at "`at'"
        exit
    }
    if "`n'"=="" c_local n 101
end

program Parse_cat_notallowed
    args discrete categorical adjust histogram
    if "`categorical'"!="" {
        if `"`adjust'"'!="" {
            di as err "{bf:adjust()} and {bf:categorical} not both allowed"
            exit 198
        }
        if `"`histogram'"'!="" {
            di as err "{bf:histogram()} and {bf:categorical} not both allowed"
            exit 198
        }
    }
    if "`discrete'"!="" {
        if `"`adjust'"'!="" {
            di as err "{bf:adjust()} and {bf:discrete} not both allowed"
            exit 198
        }
        if `"`histogram'"'!="" {
            di as err "{bf:histogram()} and {bf:discrete} not both allowed"
            exit 198
        }
    }
end

program Parse_ogrid 
    args noogrid ogrid atx
    if "`atx'"!="" {
        if "`ogrid'"!="" {
            di as err "{bf:ogrid()} and {bf:atx()} not both allowed"
            exit 198
        }
        exit
    }
    if "`noogrid'"!="" {
        if "`ogrid'"!="" {
            di as err "{bf:ogrid()} and {bf:noogrid} not both allowed"
            exit 198
        }
        exit
    }
    if "`ogrid'"=="" local ogrid 201
    c_local ogrid `ogrid'
end

program Parse_balance
    gettoken by 0 : 0
    gettoken pooled 0 : 0
    if strtrim(`"`0'"')=="" exit
    if "`by'"=="" {
        di as err "option {bf:balance()} not allowed in syntax 2"
        exit 499
    }
    _parse comma 0 rhs : 0
    local 0 `", balance(`0')"'
    syntax [, balance(str) ]
    if `"`balance'"'=="" {
        di as err "{it:varlist} required"
        di as err "(error in option {bf:balance()})"
        exit 100
    }
    local 0 `"`rhs'"'
    capt n syntax [, ate att atc ///
        Method(str) name(name) NOIsily REFerence WGENerate(name) NOGENLIST NOWARN * ]
    if _rc==1 exit _rc
    if _rc {
        di as err "(error in option {bf:balance()})"
        exit 198
    }
    if "`pooled'"!="" & "`reference'"!="" {
        di as err "option {bf:pooled} not allowed with {bf:balance(, reference)}"
        exit 198
    }
    foreach opt in ate att atc {  // other option to disallow?
        if `"``opt''"'!="" {
            di as err "option {bf:`opt'} not allowed"
            di as err "(error in option {bf:balance()})"
            exit 198
        }
    }
    if `"`method'"'=="" local method "ipw"
    if `: list sizeof method'>1 {
        di as err "too many methods specified"
        di as err "(error in option {bf:balance()})"
        exit 198
    }
    if !inlist(`"`method'"', "ipw", "eb", "md", "ps", "em") {
        di as err "method '" `"`method'"' "' not allowed"
        di as err "(error in option {bf:balance()})"
        exit 198
    }
    c_local bal_varlist   `"`balance'"'
    c_local bal_method    `method'
    c_local bal_name      `name'
    c_local bal_noisily   `noisily'
    c_local bal_ref       `reference'
    c_local bal_wvar      `wgenerate'
    c_local bal_nowarn    `nowarn'
    c_local bal_opts      `options'
end

program Balance // returns bal_Nout
                // may update N, N1, N0
    args pooled touse touse1 touse0 by by1 by0 wtype wexp over ///
        wvar method varlist ref name noisily nowarn opts
    if "`noisily'"=="" {
        di as txt "(running {cmd:kmatch `method'} to obtain balancing weights)"
    }
    else {
        local opts nogenlist `opts'
    }
    if "`wtype'"!="" {
        if "`wtype'"=="aweight" local wtype iweight // aw not allowed in kmatch
        local wgt `"[`wtype'`wexp']"'
    }
    if "`over'"!="" local opts over(`over') `opts'
    if "`ref'"==""  local tvalue `by0'
    else            local tvalue `by1'
    quietly `noisily' ///
        kmatch `method' `by' `varlist' `wgt' if `touse', ///
            att tvalue(`tvalue') wgenerate(`wvar') `opts'
    // number of observations lost due to lack of common suppott
    mata st_local("Nout", strofreal(sum(st_matrix("e(_N)")[,2]), "%18.0g"))
    if (`Nout'>0 & "`nowarn'"=="") {
        di as err "warning: `Nout' unmatched observations in " _c
        if "`ref'"=="" di as err "reference " _c
        else           di as err "comparison " _c
        di as err "distribution"
        di as err "         balancing may be poor"
    }
    c_local bal_Nout `Nout'
    // store kmatch results
    if "`name'"!="" {
        estimates store `name'
        di as txt "({cmd:kmatch} results stored under name {cmd:`name'})"
    }
    // update estimation sample (additional observation may have been 
    // excluded due to missing values on covariates)
    capt assert (`touse'==e(sample))
    if _rc {
        qui replace `touse' = 0 if e(sample)==0
        _nobs `touse' `wgt', min(1)
        c_local N = r(N)
        qui replace `touse1' = 0 if `touse'==0
        _nobs `touse1' `wgt', min(0)
        c_local N1 = r(N)
        qui replace `touse0' = 0 if `touse'==0
        _nobs `touse0' `wgt', min(0)
        c_local N0 = r(N)
    }
    // generate variable containing base weights
    if ("`wtype'"!="") {
        tempvar w
        qui gen double `w' `wexp' if `touse'
    }
    else local w 1
    /*
    // compensate loss observations due to lack of common support
    if (`Nout'>0) {
        if "`over'"=="" {
            if "`wtype'"!="" {
                su `w' if `touse' & `by'==`tvalue', meanonly
                local W1 = r(sum)
            }
            else {
                local W1 = el(e(_N),1,3)
            }
            su `wvar' if `touse' & `by'!=`tvalue', meanonly
            qui replace `wvar' = `wvar' * `W1' / r(sum) if `touse'
        }
        else {
            local i 0
            foreach o in `e(over_namelist)' {
                local ++i
                if el(e(_N),`i',2)==0 continue
                if "`wtype'"!="" {
                    su `w' if `touse' & `by'==`tvalue' & `over'==`o', meanonly
                    local W1 = r(sum)
                }
                else {
                    local W1 = el(e(_N),`i',3)
                }
                su `wvar' if `touse' & `by'!=`tvalue' & `over'==`o', meanonly
                qui replace `wvar' = `wvar' * `W1' / r(sum) if `touse' & `over'==`o'
            }
        }
    }
    */
    // update weights if target is pooled sample
    if "`pooled'"!="" {
        qui replace `wvar' = `w' + `wvar' if `touse' & `by'!=`tvalue'
    }
    // rescale final balancing weights (such that sum of weights is equal to
    // the original sample size or sum of weights in the reweighted group)
    if "`over'"=="" {
        if "`wtype'"!="" {
            su `w' if `touse' & `by'!=`tvalue', meanonly
            local W1 = r(sum)
        }
        else {
            qui count if `touse' & `by'!=`tvalue'
            local W1 = r(N)
        }
        su `wvar' if `touse' & `by'!=`tvalue', meanonly
        qui replace `wvar' = `wvar' * `W1' / r(sum) if `touse'
    }
    else {
        local i 0
        foreach o in `e(over_namelist)' {
            local ++i
            if "`wtype'"!="" {
                su `w' if `touse' & `by'!=`tvalue' & `over'==`o', meanonly
                local W1 = r(sum)
            }
            else {
                qui count if `touse' & `by'!=`tvalue' & `over'==`o'
                local W1 = r(N)
            }
            su `wvar' if `touse' & `by'!=`tvalue' & `over'==`o', meanonly
            qui replace `wvar' = `wvar' * `W1' / r(sum) if `touse' & `over'==`o'
        }
    }
    // set weights to missing in non-reweighted group
    qui replace `wvar' = . if `touse' & `by'==`tvalue'
end

program Samplesetup // common function to prepare estimation sample
            // general returns: wvar, exp, wgt, N
            // returns if syntax 1: by1, by0, by1lab, by0lab, N1, N0
            // returns if syntax 2: (none)
            // returns if over: N_over, overlevels, over_labels
    args touse touse1 touse0 wvar depvar by swap refvar weight exp over
    if "`weight'"!="" {
        capt confirm variable `exp'
        if _rc {
            qui gen double `wvar' = `exp' if `touse'
        }
        else {
            unab exp: `exp', min(1) max(1)
            local wvar `exp'
        }
        local wgt "[`weight'=`wvar']"
        c_local wvar `wvar'
        c_local exp `"= `exp'"'
        c_local wgt "`wgt'"
    }
    if "`by'"!="" {     // syntax 1
        markout `touse' `by'
        qui levelsof `by' if `touse', local(bylevels)
        if `:list sizeof bylevels'!=2 {
            di as err "{it:groupvar} must define two groups"
            exit 498
        }
        if "`swap'"=="" {
            local by0: word 1 of `bylevels'
            local by1: word 2 of `bylevels'
        }
        else {
            local by0: word 2 of `bylevels'
            local by1: word 1 of `bylevels'
        }
        qui gen byte `touse1' = (`touse' & `by'==`by1')
        _nobs `touse1' `wgt'
        c_local N1 = r(N)
        qui gen byte `touse0' = (`touse' & `by'==`by0')
        _nobs `touse0' `wgt'
        c_local N0 = r(N)
        c_local by1lab: label (`by') `by1', strict
        c_local by0lab: label (`by') `by0', strict
        c_local by1 `by1'
        c_local by0 `by0'
    }
    else {              // syntax 2
        markout `touse' `refvar'
    }
    _nobs `touse' `wgt', min(1)
    c_local N = r(N)
    if "`over'"!="" {
        capt assert ((`over'==floor(`over')) & (`over'>=0)) if `touse'
        if _rc {
            di as err "variable in over() must be integer and nonnegative"
            exit 452
        }
        qui levelsof `over' if `touse', local(overlevels)
        c_local N_over: list sizeof overlevels
        c_local overlevels "`overlevels'"
        local over_labels
        foreach o of local overlevels {
            local olab: label (`over') `o'
            local over_labels `"`over_labels' `"`olab'"'"'
        }
        c_local over_labels: list clean over_labels
    }
end

program Check_adjlog // logarithmic adjustment: assert that y > 0
    args touse depvar refvar by adjlog
    if "`adjlog'"=="" exit
    if "`by'"!="" {
        capt assert (`depvar'>0) if `touse'
    }
    else {
        capt assert (`depvar'>0) & (`refvar'>0) if `touse'
    }
    if _rc==1 exit _rc // break
    else if _rc {
        di as err "{bf:logarithmic} adjustment only allowed if outcomes are strictly positive"
        exit 499
    }
end

program Check_categorical // outcome variable(s) must be integer >=0
    args touse depvar refvar categorical
    if "`categorical'"=="" exit
    capt assert (`depvar'>=0 & trunc(`depvar')==`depvar') if `touse'
    if _rc {
        di as err "`depvar': noninteger or negative values not allowed"/*
        */ " if {bf:categorical} is specified"
        exit 452
    }
    if "`refvar'"=="" exit
    capt assert (`refvar'>=0 & trunc(`refvar')==`refvar') if `touse'
    if _rc {
        di as err "`refvar': noninteger or negative values not allowed"/*
        */ " if {bf:categorical} is specified"
        exit 452
    }
end

program PrepareOver // common function to prepare cycling across over groups
    args N_over overlevels by touse touse1 touse0 _N _N1 _N0
    mat `_N' = J(`N_over',1,.)
    mat rown `_N' = `overlevels'
    qui gen byte `touse' = .
    if "`by'"!="" {
        mat `_N1' = `_N'
        mat `_N0' = `_N'
        qui gen byte `touse1' = .
        qui gen byte `touse0' = .
    }
end

program PrepareOverlevel // common function to handle specific over level
    args i o by touse touse1 touse0 TOUSE TOUSE1 TOUSE0 _N _N1 _N0 wgt
    qui replace `touse' = `TOUSE' & `o'
    _nobs `touse' `wgt'
    mat `_N'[`i',1] = r(N)
    if "`by'"!="" {
        qui replace `touse1' = `TOUSE1' & `o'
        qui replace `touse0' = `TOUSE0' & `o'
        _nobs `touse1' `wgt', min(0)
        mat `_N1'[`i',1] = r(N)
        _nobs `touse0' `wgt', min(0)
        mat `_N0'[`i',1] = r(N)
    }
end

program PDF, eclass
    // syntax
    Parse_syntax `0'
    syntax [if] [in] [fw iw aw pw/], [ ///
        NOBReak NOMID ADJust(str) BALance(str) ///
        n(numlist int >1 max=1) at(str) atx ATX2(str) DISCRete CATegorical ///
        NOOGRID ogrid(numlist int >0 max=1) ///
        BWidth(str) BWADJust(numlist >0 max=1) ///
        BOundary(str) Kernel(string) ///
        ADAPTive(numlist int >=0 max=1) ///
        altlbwf /// (undocumented)
        exact NApprox(numlist int >1 max=1) ///
        HISTogram HISTogram2(numlist int >0 max=1) ///
        NOSE Level(cilevel) noHeader NOTABle TABle ///
        GRaph GRaph2(passthru) * ]
    _get_diopts diopts, `options'
    c_local diopts `diopts' `header' `notable' `table' `graph' `graph2'
    Parse_at "`n'" `"`at'"' "`atx'" `"`atx2'"' "`discrete'" "`categorical'"
    if "`discrete'"!="" local nose nose // standard errors not supported
    Parse_cat_notallowed "`discrete'" "`categorical'" `"`adjust'"' `"`histogram'`histogram2'"'
    Parse_adjust `adjust'
    Parse_balance "`by'" "`pooled'" `balance'
    Parse_ogrid "`noogrid'" "`ogrid'" "`atx'"
    if "`histogram2'"!=""     local nhist `histogram2'
    else if "`histogram'"!="" local nhist 10
    if "`napprox'"==""        local napprox = max(512, `n'+1)
    capt confirm number `bwidth'
    if _rc==0 {
        if `bwidth'<=0 {
            di as error "{bf:bwidth()} must be strictly positive"
            exit 198
        }
    }
    else PDF_parse_bwmethod, `bwidth'
    if "`bwadjust'"=="" local bwadjust 1
    if `"`kernel'"'=="" local kernel "epan2"
    if "`adaptive'"=="" local adaptive 1
    PDF_parse_boundary, `boundary'
    
    // mark sample
    marksample touse
    markout `touse' `depvar'
    tempvar touse1 touse0 wvar
    Samplesetup `touse' `touse1' `touse0' `wvar' `depvar' ///
        "`by'" "`swap'" "`refvar'" "`weight'" `"`exp'"' ""
    Check_adjlog `touse' `depvar' "`refvar'" "`by'" "`adjlog'"
    Check_categorical `touse' `depvar' "`refvar'" "`categorical'"
    
    // compute weights for balancing
    if `"`bal_varlist'"'!="" {
        if "`bal_wvar'"=="" tempvar bal_wvar
        Balance "`pooled'" `touse' `touse1' `touse0' `by' `by1' `by0' ///
            "`weight'" `"`exp'"' "" ///
            `bal_wvar' "`bal_method'" `"`bal_varlist'"' "`bal_ref'" ///
            "`bal_name'" "`bal_noisily'" "`bal_nowarn'" `"`bal_opts'"'
    }
    
    // compute relative PDF
    tempname b se AT OGRID BW DIV CHI2 k_omit
    scalar `k_omit' = 0
    mata: rd_PDF(strtoreal("`n'"))
    
    // returns
    eret post `b' [`weight'`exp'], obs(`N') esample(`touse')
    mata: rd_Post_common_e()
    eret local  subcmd      "pdf"
    eret local  title       "Relative density function"
    eret matrix at          = `AT'
    eret local atx          "`atx'"
    eret local discrete     "`discrete'"
    eret local categorical  "`categorical'"
    eret scalar n           = `n'
    if "`ogrid'"!="" {
        eret matrix ogrid    = `OGRID'
    }
    if "`nose'"=="" {
        eret matrix se = `se'
    }
    if "`discrete'"=="" {
        eret scalar napprox  = `napprox'
        eret scalar bwidth   = `BW'
        if "`bwmethod'"=="dpi" {
            local bwmethod `bwmethod'(`bwdpi')
        }
        eret local  bwmethod "`bwmethod'"
        eret scalar bwadjust = `bwadjust'
        eret local  kernel   "`kernel'"
        eret scalar adaptive = `adaptive'
        eret local  exact    "`exact'"
        eret local  boundary "`boundary'"
        eret local  altlbwf  "`altlbwf'"
        if "`exact'"=="" {
            eret scalar divergence = `DIV'
            eret scalar chi2 = `CHI2'
        }
    }
    else {
        eret scalar divergence = `DIV'
        eret scalar chi2 = `CHI2'
    }
    if "`nhist'"!="" {
        eret scalar n_hist = `nhist'
        eret scalar hwidth = 1/`nhist'
    }
end

program PDF_parse_bwmethod  // returns: bwmethod, bwdpi
    capt n syntax [, Silverman Normalscale Oversmoothed SJpi Dpi Dpi2(numlist int >=0 max=1) ]
    if _rc==1 exit _rc
    if _rc {
        di as err "(error in option {bf:bwidth()})"
        exit 198
    }
    if "`dpi2'"!="" local dpi dpi
    local bwmethod `silverman' `normalscale' `oversmoothed' `sjpi' `dpi'
    if "`bwmethod'"=="" local bwmethod "sjpi"
    if `: list sizeof bwmethod'>1 {
        di as err "too many methods specified"
        di as err "(error in option {bf:bwidth()})"
        exit 198
    }
    if "`dpi2'"=="" local dpi2 2
    c_local bwmethod `bwmethod'
    c_local bwdpi `dpi2'
end

program PDF_parse_boundary // returns: boundary
    capt n syntax [, RENorm REFlect lc ]
    if _rc==1 exit _rc
    if _rc {
        di as err "(error in option {bf:boundary()})"
        exit 198
    }
    local boundary `renorm' `reflect' `lc'
    if "`boundary'"=="" local boundary "renorm"
    if `: list sizeof boundary'>1 {
        di as err "too many methods specified"
        di as err "(error in option {bf:boundary()})"
        exit 198
    }
    c_local boundary `boundary'
end

program HIST, eclass
    // syntax
    Parse_syntax `0'
    syntax [if] [in] [fw iw aw pw/], [ ///
        NOBReak NOMID ADJust(str) BALance(str) ///
        n(numlist int >0 max=1) ///
        NOOGRID ogrid(numlist int >0 max=1) ///
        NOSE Level(cilevel) noHeader NOTABle TABle ///
        GRaph GRaph2(passthru) * ]
    _get_diopts diopts, `options'
    c_local diopts `diopts' `header' `notable' `table' `graph' `graph2'
    Parse_adjust `adjust'
    Parse_balance "`by'" "`pooled'" `balance'
    if "`n'"=="" local n 10
    Parse_ogrid "`noogrid'" "`ogrid'"
    
    // mark sample
    marksample touse
    markout `touse' `depvar'
    tempvar touse1 touse0 wvar
    Samplesetup `touse' `touse1' `touse0' `wvar' `depvar' ///
        "`by'" "`swap'" "`refvar'" "`weight'" `"`exp'"' ""
    Check_adjlog `touse' `depvar' "`refvar'" "`by'" "`adjlog'"
    
    // compute weights for balancing
    if `"`bal_varlist'"'!="" {
        if "`bal_wvar'"=="" tempvar bal_wvar
        Balance "`pooled'" `touse' `touse1' `touse0' `by' `by1' `by0' ///
            "`weight'" `"`exp'"' "" ///
            `bal_wvar' "`bal_method'" `"`bal_varlist'"' "`bal_ref'" ///
            "`bal_name'" "`bal_noisily'" "`bal_nowarn'" `"`bal_opts'"'
    }
    
    // compute relative PDF
    tempname b AT OGRID k_omit
    scalar `k_omit' = 0
    mata: rd_HIST(`n')
    
    // returns
    eret post `b' [`weight'`exp'], obs(`N') esample(`touse')
    mata: rd_Post_common_e()
    eret local  subcmd   "histogram"
    eret local  title    "Relative histogram"
    eret matrix at       = `AT'
    if "`ogrid'"!="" {
        eret matrix ogrid    = `OGRID'
    }
    eret scalar n_hist   = `n'
    eret scalar hwidth   = 1/`n'
end

program CDF, eclass
    // syntax
    Parse_syntax `0'
    syntax [if] [in] [fw iw aw pw/], [ ///
        NOBReak NOMID ADJust(str) BALance(str) ///
        n(numlist int >1 max=1) at(str) atx ATX2(str) DISCRete CATegorical ///
        NOOGRID ogrid(numlist int >0 max=1) ///
        NOSE Level(cilevel) noHeader NOTABle TABle ///
        GRaph GRaph2(passthru) * ]
    local nobreak nobreak // enforce nobreak; only affects e()-returns
    local nomid nomid     // enforce nomid; only affects e()-returns
    _get_diopts diopts, `options'
    c_local diopts `diopts' `header' `notable' `table' `graph' `graph2'
    if "`categorical'"!="" {
        if `"`adjust'"'!="" {
            di as err "{bf:adjust()} and {bf:categorical} not both allowed"
            exit 198
        }
    }
    Parse_at "`n'" `"`at'"' "`atx'" `"`atx2'"' "`discrete'" "`categorical'"
    Parse_cat_notallowed "`discrete'" "`categorical'" `"`adjust'"'
    Parse_adjust `adjust'
    Parse_balance "`by'" "`pooled'" `balance'
    Parse_ogrid "`noogrid'" "`ogrid'" "`atx'"
    
    // mark sample
    marksample touse
    markout `touse' `depvar'
    tempvar touse1 touse0 wvar
    Samplesetup `touse' `touse1' `touse0' `wvar' `depvar' ///
        "`by'" "`swap'" "`refvar'" "`weight'" `"`exp'"' ""
    Check_categorical `touse' `depvar' "`refvar'" "`categorical'"
    Check_adjlog `touse' `depvar' "`refvar'" "`by'" "`adjlog'"
    
    // compute weights for balancing
    if `"`bal_varlist'"'!="" {
        if "`bal_wvar'"=="" tempvar bal_wvar
        Balance "`pooled'" `touse' `touse1' `touse0' `by' `by1' `by0' ///
            "`weight'" `"`exp'"' "" ///
            `bal_wvar' "`bal_method'" `"`bal_varlist'"' "`bal_ref'" ///
            "`bal_name'" "`bal_noisily'" "`bal_nowarn'" `"`bal_opts'"'
    }
    
    // compute relative CDF
    tempname b AT OGRID k_omit
    scalar `k_omit' = 0
    mata: rd_CDF(strtoreal("`n'"))
    
    // returns
    eret post `b' [`weight'`exp'], obs(`N') esample(`touse')
    mata: rd_Post_common_e()
    eret local subcmd      "cdf"
    eret local title       "Cumulative relative distribution"
    eret matrix at         = `AT'
    eret local atx         "`atx'"
    eret local discrete    "`discrete'"
    eret local categorical "`categorical'"
    eret local origin      "`origin'"
    if "`ogrid'"!="" {
        eret matrix ogrid  = `OGRID'
    }
    eret scalar n = `n'
end

program MRP, eclass
    // syntax
    Parse_syntax `0'
    syntax [if] [in] [fw iw aw pw/], [ ///
        NOBReak NOMID BALance(str) Over(varname numeric) ///
        SCale SCale2(str) MULTiplicative LOGarithmic ///
        NOSE Level(cilevel) noHeader NOTABle TABle * ]
    _get_diopts diopts, `options'
    c_local diopts `diopts' `header' `notable' `table'
    if `"`scale2'"'!="" local scale scale
    local adj1 location
    if "`scale'"!="" {
        if "`multiplicative'"!="" {
            di as err "{bf:scale} and {bf:multiplicative} not both allowed"
            exit 198
        }
        local adj1 `adj1' scale
        if `"`scale2'"'=="sd" {
            local adjsd sd
        }
        else if `"`scale2'"'!="" {
            if `"`scale2'"'!=substr("iqrange",1,max(3,strlen(`"`scale2'"'))) {
                di as err "'" `"`scale2'"' "' not allowed in {bf:scale()}"
                exit 198
            }
        }
    }
    else if "`multiplicative'"!="" {
        local adjmult multiplicative
    }
    if "`logarithmic'"!="" {
        if "`multiplicative'"!="" {
            di as err "{bf:logarithmic} and {bf:multiplicative} not both allowed"
            exit 198
        }
        local adjlog logarithmic
    }
    Parse_balance "`by'" "`pooled'" `balance'
    
    // mark sample
    marksample touse
    markout `touse' `depvar' `over'
    tempvar touse1 touse0 wvar
    Samplesetup `touse' `touse1' `touse0' `wvar' `depvar' ///
        "`by'" "`swap'" "`refvar'" "`weight'" `"`exp'"' "`over'"
    Check_adjlog `touse' `depvar' "`refvar'" "`by'" "`adjlog'"
    
    // compute weights for balancing
    if `"`bal_varlist'"'!="" {
        if "`bal_wvar'"=="" tempvar bal_wvar
        Balance "`pooled'" `touse' `touse1' `touse0' `by' `by1' `by0' ///
            "`weight'" `"`exp'"' "`over'" ///
            `bal_wvar' "`bal_method'" `"`bal_varlist'"' "`bal_ref'" ///
            "`bal_name'" "`bal_noisily'" "`bal_nowarn'" `"`bal_opts'"'
    }
    
    // compute polarization statistics
    tempname b btmp k_omit
    scalar `k_omit' = 0
    if "`over'"=="" {
        mata: rd_MRP("`b'")
    }
    else {
        local TOUSE  `touse'
        local TOUSE1 `touse1'
        local TOUSE0 `touse0'
        tempname touse touse1 touse0 _N _N1 _N0 
        PrepareOver `N_over' "`overlevels'" "`by'" ///
            `touse' `touse1' `touse0' `_N' `_N1' `_N0'
        local i 0
        foreach o of local overlevels {
            local ++i
            PrepareOverlevel `i' "`over'==`o'" "`by'" `touse' `touse1' ///
                `touse0' `TOUSE' `TOUSE1' `TOUSE0' `_N' `_N1' `_N0' "`wgt'"
            mata: rd_MRP("`btmp'")
            mata: rd_FlagOmitted("`btmp'") // mrp can be missing if too few obs
            mat coleq `btmp' = "`o'"
            mat `b' = nullmat(`b'), `btmp'
        }
        local touse `TOUSE'
    }
    
    // returns
    eret post `b' [`weight'`exp'], obs(`N') esample(`touse')
    mata: rd_Post_common_e()
    eret local  subcmd   "mrp"
    eret local  title    "Median relative polarization"
end

program SUM, eclass
    // syntax
    Parse_syntax `0'
    syntax [if] [in] [fw iw aw pw/], [ ///
        NOBReak NOMID ADJust(str) BALance(str) Over(varname numeric) ///
        Statistics(passthru) Generate(name) Replace ///
        NOSE Level(cilevel) noHeader NOTABle TABle * ]
    _get_diopts diopts, `options'
    c_local diopts `diopts' `header' `notable' `table'
    Parse_adjust `adjust'
    if "`by'"=="" & "`pooled'"!="" {
        if `: list posof "shape" in adj1' {
            di as err "shape adjustment of comparison distribution not " /*
                */ "supported by {bf:reldist sum} in syntax 2 with option " /*
                */ "{bf:pooled}; {helpb reshape} the data and use syntax 1"
            exit 499
        }
    }
    Parse_balance "`by'" "`pooled'" `balance'
    if "`generate'"!="" & "`replace'"=="" {
        confirm new variable `generate'
    }
    
    // mark sample
    marksample touse
    markout `touse' `depvar' `over'
    tempvar touse1 touse0 wvar
    Samplesetup `touse' `touse1' `touse0' `wvar' `depvar' ///
        "`by'" "`swap'" "`refvar'" "`weight'" `"`exp'"' "`over'"
    Check_adjlog `touse' `depvar' "`refvar'" "`by'" "`adjlog'"
    
    // compute weights for balancing
    if `"`bal_varlist'"'!="" {
        if "`bal_wvar'"=="" tempvar bal_wvar
        Balance "`pooled'" `touse' `touse1' `touse0' `by' `by1' `by0' ///
            "`weight'" `"`exp'"' "`over'" ///
            `bal_wvar' "`bal_method'" `"`bal_varlist'"' "`bal_ref'" ///
            "`bal_name'" "`bal_noisily'" "`bal_nowarn'" `"`bal_opts'"'
        tempvar WVAR
        qui gen double `WVAR' = .
        local swgt "[aweight=`WVAR']"
    }
    else {
        if inlist("`weight'", "iweight", "pweight") local swgt "[aweight=`wvar']"
        else                                        local swgt "`wgt'"
    }
    
    // compute relative ranks and statistics
    tempvar ranks
    qui gen double `ranks' = .
    tempname b btmp k_omit
    scalar `k_omit' = 0
    if "`over'"=="" {
        mata: rd_SUM()
        quietly tabstat `ranks' if `touse' `swgt', save `statistics'
        mat `b' = r(StatTotal)'
        local statnames: coln `b'
        mata: rd_FlagOmitted("`b'") // stats can be missing if too few obs
    }
    else {
        local TOUSE  `touse'
        local TOUSE1 `touse1'
        local TOUSE0 `touse0'
        tempname touse touse1 touse0 _N _N1 _N0 
        PrepareOver `N_over' "`overlevels'" "`by'" ///
            `touse' `touse1' `touse0' `_N' `_N1' `_N0'
        local i 0
        foreach o of local overlevels {
            local ++i
            PrepareOverlevel `i' "`over'==`o'" "`by'" `touse' `touse1' ///
                `touse0' `TOUSE' `TOUSE1' `TOUSE0' `_N' `_N1' `_N0' "`wgt'"
            mata: rd_SUM()
            quietly tabstat `ranks' if `touse' & `over'==`o' `swgt', save `statistics'
            mat `btmp' = r(StatTotal)'
            if `i'==1 local statnames: coln `btmp'
            mata: rd_FlagOmitted("`btmp'") // stats can be missing if too few obs
            mat coleq `btmp' = "`o'"
            mat `b' = nullmat(`b'), `btmp'
        }
        local touse `TOUSE'
    }
    
    // returns
    eret post `b' [`weight'`exp'], obs(`N') esample(`touse')
    mata: rd_Post_common_e()
    eret local subcmd     "summarize"
    eret local title      "Relative ranks"
    eret local statistics "`statnames'"
    
    // store in variable
    if "`generate'"!="" {
        eret local generate `generate'
        capt confirm new variable `generate'
        if _rc==1 exit _rc
        if _rc drop `generate'
        rename `ranks' `generate'
        lab var `generate' "Relative ranks"
    }
end

version 12
// struct
local DATA   rd_data
local Data   struct `DATA' scalar
local ADJ    rd_adjset
local Adj    struct `ADJ' scalar
local MRP    rd_mrp
local Mrp    struct `Mrp' scalar
// string
local SS     string scalar
local SR     string rowvector
local SM     string matrix
// real
local RS     real scalar
local RV     real vector
local RC     real colvector
local RR     real rowvector
local RM     real matrix
// counters
local Int    real scalar
local IntC   real colvector
// boolean
local Bool   real scalar
local TRUE   1
local FALSE  0
// pointer
local PSRC   pointer(real colvector) scalar
local PSRCF  pointer(real colvector function) scalar
mata:
mata set matastrict on

/* Helper functions directly called by ado ----------------------------------*/

void rd_check_mat(`SS' nm, `Int' kind)
{
    `RM' m
    
    m = st_matrix(nm)
    if (kind==1) {  // check whether positive integer
        assert(!any(m:<0))
        assert(!any(m:!=trunc(m)))
        return
    }
    // check whether in [0,1]
    assert(!any(m:<0))
    assert(!any(m:>1))
}

void rd_Post_common_e()
{
    st_global("e(cmd)", "reldist")
    st_global("e(depvar)", st_local("depvar"))
    if (st_local("by")!="") {
        st_global("e(by)", st_local("by"))
        st_global("e(by1lab)", st_local("by1lab"))
        st_global("e(by0lab)", st_local("by0lab"))
        stata("ereturn scalar by1 = " + st_local("by1"))
        stata("ereturn scalar by0 = " + st_local("by0"))
        stata("ereturn scalar N1 = " + st_local("N1"))
        stata("ereturn scalar N0 = " + st_local("N0"))
    }
    else {
        st_global("e(refvar)", st_local("refvar"))
    }
    st_global("e(nobreak)",   st_local("nobreak"))
    st_global("e(nomid)",     st_local("nomid"))
    st_global("e(pooled)",    st_local("pooled"))
    st_global("e(adjust)",    st_local("adj1"))
    st_global("e(refadjust)", st_local("adj0"))
    st_global("e(adjmean)",   st_local("adjmean"))
    st_global("e(adjsd)",     st_local("adjsd"))
    st_global("e(adjlog)",    st_local("adjlog"))
    st_global("e(adjmult)",   st_local("adjmult"))
    if (st_local("over")!="") {
        st_global("e(over)", st_local("over"))
        st_global("e(over_namelist)", st_local("overlevels"))
        st_global("e(over_labels)", st_local("over_labels"))
        stata("ereturn scalar N_over = " + st_local("N_over"))
        stata("ereturn matrix _N = " + st_local("_N"))
        if (st_local("by")!="") {
            stata("ereturn matrix _N1 = " + st_local("_N1"))
            stata("ereturn matrix _N0 = " + st_local("_N0"))
        }
    }
    if (st_local("bal_varlist")!="") {
        st_global("e(balance)",      st_local("bal_varlist"))
        st_global("e(balmethod)",    st_local("bal_method"))
        st_global("e(balref)",       st_local("bal_ref"))
        st_global("e(balopts)",      st_local("bal_opts"))
        stata("ereturn scalar Nout = " + st_local("bal_Nout"))
    }
    stata("ereturn scalar level = " + st_local("level"))
    stata("ereturn scalar k_omit = " + st_local("k_omit"))
}

void rd_FlagOmitted(`SS' bnm)
{
    `Int' i, k_omit
    `RR'  b
    `SM'  cstripe
    
    b = st_matrix(bnm)
    if (hasmissing(b)==0) return
    cstripe = st_matrixcolstripe(bnm)
    k_omit = st_numscalar(st_local("k_omit"))
    i = cols(b)
    for (;i;i--) {
        if (b[i]>=.) {
            b[i] = 0
            cstripe[i,2] = "o." + cstripe[i,2]
            k_omit++
        }
    }
    st_matrix(bnm, b)
    st_matrixcolstripe(bnm, cstripe)
    st_numscalar(st_local("k_omit"), k_omit)
}

void rd_svmat(`SS' nm, `SR' vnms, `Bool' transpose)
{
    `RM' M

    if (transpose) M = st_matrix(nm)'
    else           M = st_matrix(nm)
    if (cols(M)>cols(vnms))      M = M[,1..cols(vnms)]
    else if (cols(M)<cols(vnms)) vnms = vnms[1..cols(M)]
    st_store((1,rows(M)), st_addvar("double",vnms), M)
}

void rd_olab(`Bool' cdf, `Bool' atx, `SS' nm, `SS' fmt)
{
    `RR' y, x
    `RC' p
    
    x  = strtoreal(tokens(st_local(nm)))
    if (length(x)==0) {
        st_local(nm,"")
        return
    }
    if (atx) {
        y = st_matrix("e(at)")[2,]
        if (cdf) p = st_matrix("e(b)")
        else     p = st_matrix("e(at)")[1,]
    }
    else {
        y = st_matrix("e(ogrid)")[1+cdf,]
        p = (0::length(y)-1) / (length(y)-1)
    }
    st_local(nm, _rd_olab_fmt(_rd_olab_pos(y, p, x), x, fmt))
}

`RV' _rd_olab_pos(`RV' y, `RV' p, `RV' x)
{
    // get positions of x in p = CDF(y)
    // if x is between two y values: use p of lower y
    // if x is equal to y:           use max(p) of matching y's
    // this also implies: if x < min(y):  position = 0
    //                    if x > max(y):  position = 1
    `Int' i, n, j, r 
    `RV'  P
    
    n = length(x)
    P = J(rows(x), cols(x), .)
    for (i=1; i<=n; i++) {
        if (x[i] >= y[1]) break
        P[i] = 0
    }
    r = length(y)
    j = 1
    for (; i<=n; i++) {
        for (; j<r; j++) {
            if (y[j+1] > x[i]) break
        }
        P[i] = p[j]
    }
    return(P)
}

`SS' _rd_olab_fmt(`RR' p, | `RR' x, `SS' fmt)
{
    if (fmt=="") return(invtokens(strofreal(p)))
    return(invtokens((strofreal(p) :+ `" ""' :+ strofreal(x, fmt)  :+ `"""')))
}

/* Data preparation and some common functions -------------------------------*/

struct `ADJ' {
    `Bool'  adj        // has adjustment
    `Bool'  location   // adjust location
    `Bool'  scale      // adjust scale
    `Bool'  shape      // adjust shape
}

struct `DATA' {
    `Bool'  by         // syntax 1
    `Bool'  method     // 0 continuous: at
                       // 1 continuous: full atx
                       // 2 continuous: custom atx,
                       // 3 discrete: at
                       // 4 discrete: full atx
                       // 5 discrete: custom atx
    `Bool'  tbreak     // break ties
    `Bool'  mid        // use midpoints for relative ranks: 1 yes, 0 no 
    `Bool'  pooled     // use pooled reference distribution
    `Int'   balanced   // balancing: 0 none, 1 comparison, 2 reference
    `RC'    y1, w1, p1 // data and weights comparison distribution
    `RS'    N1         // N of comparison distribution
    `RC'    y0, w0, p0 // data and weights reference distribution
    `RS'    N0         // N of reference distribution
    `Int'   wtype      // weights: 0 none, 1 fw, 2 pw, 3 aw, 4 iw
    `Adj'   adj1       // comparison distribution adjustments
    `Adj'   adj0       // reference distribution adjustments
    `Bool'  adjmean    // 0 use median, 1 use mean
    `Bool'  adjsd      // 0 use IQR, 1 use sd
    `Int'   adjlink    // 0 linear/additive, 1 logarithmic, 2 multiplicative
    `PSRC'  Y1, W1, P1 // (adjusted) comparison distribution
    `PSRC'  Y0, W0, P0 // (adjusted) reference distribution
    `RC'    ranks      // relative ranks
}

void rd_getadj(`Adj' adj, `SS' lnm)
{
    `SR'    ADJ
    
    ADJ = tokens(st_local(lnm))
    adj.adj      = (length(ADJ)!=0)
    adj.location = anyof(ADJ, "location")
    adj.scale    = anyof(ADJ, "scale")
    adj.shape    = anyof(ADJ, "shape")
}

void rd_getdata(`Data' data)
{
    `SS'   weight
    `Int'  depvar, refvar, touse1, touse0
    
    // setup
    data.by       = (st_local("by")!="")
    data.tbreak   = (st_local("nobreak")=="")
    data.mid      = (st_local("nomid")=="")
    data.method   = (st_local("atx")!="") + // => 1
                    (st_local("atx2")!="" | st_local("ATX0")!="") + // => 2
                    3*(st_local("discrete")!="") // => add 3
    data.pooled   = (st_local("pooled")!="")
    data.balanced = (st_local("bal_varlist")!="") + (st_local("bal_ref")!="")
    depvar        = st_varindex(st_local("depvar"))
    if (data.by) {
        touse1 = st_varindex(st_local("touse1"))
        if (data.pooled) touse0 = st_varindex(st_local("touse"))
        else             touse0 = st_varindex(st_local("touse0"))
        refvar = st_varindex(st_local("depvar"))
    }
    else {
        touse1 = touse0 = st_varindex(st_local("touse"))
        refvar = st_varindex(st_local("refvar"))
    }
    weight     = st_local("weight")
    data.wtype = (weight=="fweight" ? 1 :
                 (weight=="pweight" ? 2 :
                 (weight=="aweight" ? 3 :
                 (weight=="iweight" ? 4 : 0))))
    
    // comparison group data
    data.y1 = st_data(., depvar, touse1)
    if (data.balanced==1)      data.w1 = st_data(., st_local("bal_wvar"), touse1)
    else if (data.wtype)       data.w1 = st_data(., st_local("wvar"), touse1)
    else if (data.balanced==2) data.w1 = J(rows(data.y1),1,1)
    else                       data.w1 = 1
    
    // reference group data
    data.y0 = st_data(., refvar, touse0)
    if (data.balanced==2)      data.w0 = st_data(., st_local("bal_wvar"), touse0)
    else if (data.wtype)       data.w0 = st_data(., st_local("wvar"), touse0)
    else if (data.balanced==1) data.w0 = J(rows(data.y0),1,1)
    else                       data.w0 = 1
    if (data.by==0 & data.pooled) {
        data.y0 = data.y0 \ data.y1
        if (data.wtype) data.w0 = data.w0 \ data.w1
    }
    
    // set wtype to pw if balanced without base weights
    if (data.balanced & data.wtype==0) data.wtype = 2
    
    // compute N and normalize weights
    if (data.wtype>1) {     // pw, aw, iw
        data.N1 = rows(data.y1)
        data.w1 = data.w1 * data.N1 / quadsum(data.w1)
        data.N0 = rows(data.y0)
        data.w0 = data.w0 * data.N0 / quadsum(data.w0)
    }
    else if (data.wtype) {  // fw
        data.N1 = sum(data.w1)
        data.N0 = sum(data.w0)
    }
    else {                  // no weights
        data.N1 = rows(data.y1)
        data.N0 = rows(data.y0)
    }
    
    // sort data
    if (rows(data.w1)!=1) {
        data.p1 = order((data.y1,data.w1), (1,2))
        data.y1 = data.y1[data.p1]
        data.w1 = data.w1[data.p1]
    }
    else {
        data.p1 = order(data.y1, 1)
        data.y1 = data.y1[data.p1]
    }
    if (rows(data.w0)!=1) {
        data.p0 = order((data.y0,data.w0), (1,2))
        data.y0 = data.y0[data.p0]
        data.w0 = data.w0[data.p0]
    }
    else {
        data.p0 = order(data.y0, 1)
        data.y0 = data.y0[data.p0]
    }
    
    // adjustment settings
    rd_getadj(data.adj1, "adj1")
    rd_getadj(data.adj0, "adj0")
    data.adjmean = (st_local("adjmean")!="")
    data.adjsd   = (st_local("adjsd")!="")
    data.adjlink = 0 + (st_local("adjlog")!="") + 2*(st_local("adjmult")!="")
}

void rd_adjust(`Data' data)
{
    _rd_adjust(data.Y1, data.W1, data.P1, data.y1, data.w1, data.p1, 
        data.y0, data.w0, data.p0, data.adj1, data.adjmean, data.adjsd, data.adjlink)
    _rd_adjust(data.Y0, data.W0, data.P0, data.y0, data.w0, data.p0,
        data.y1, data.w1, data.p1, data.adj0, data.adjmean, data.adjsd, data.adjlink)
}

void _rd_adjust(`PSRC' Y, `PSRC' W, `PSRC' P, `RC' y, `RC' w, `RC' p, 
    `RC' y0, `RC' w0, `RC' p0, `Adj' adj, `Bool' mean, `Bool' sd, `Int' link)
{
    if (adj.adj==0) {
        Y = &y; W = &w; P = &p
        return
    }
    if (adj.shape) {
        if (adj.location & adj.scale) Y = &y0
        else if (adj.location) Y = _rd_adjust_s(y0, w0, y, w, mean, sd, link)
        else if (adj.scale) Y = _rd_adjust_l(y0, w0, y, w, mean, link)
        else Y = _rd_adjust_ls(y0, w0, y, w, mean, sd, link)
        W = &w0; P = &p0
        return
    }
    if (adj.location & adj.scale) Y = _rd_adjust_ls(y, w, y0, w0, mean, sd, link)
    else if (adj.location) Y = _rd_adjust_l(y, w, y0, w0, mean, link)
    else if (adj.scale) Y = _rd_adjust_s(y, w, y0, w0, mean, sd, link)
    W = &w; P = &p
}

`PSRC' _rd_adjust_ls(`RC' y, `RC' w, `RC' y0, `RC' w0, `Bool' mean, `Bool' sd,
    `Int' link)
{   // scale and location adjustment
    `RS' l, l0, s, s0
    `RC' lny
    
    if (link==1) {                       // logarithmic
        lny = ln(y)
        l  = (mean ? mean(lny, w)     : _rd_median(lny, w))
        l0 = (mean ? mean(ln(y0), w0) : _rd_median(ln(y0), w0))
        s  = (sd ? sqrt(variance(lny, w))     : _rd_iqrange(lny, w))
        s0 = (sd ? sqrt(variance(ln(y0), w0)) : _rd_iqrange(ln(y0), w0))
        return(&(exp((lny :- l) * (s0 / s) :+ l0)))
    }
    l  = (mean ? mean(y, w)   : _rd_median(y, w))
    l0 = (mean ? mean(y0, w0) : _rd_median(y0, w0))
    if (link==2) return(&(y * (l0 / l))) // multiplicative (scale not relevant)
    s  = (sd ? sqrt(variance(y, w))   : _rd_iqrange(y, w))
    s0 = (sd ? sqrt(variance(y0, w0)) : _rd_iqrange(y0, w0))
    return(&((y :- l) * (s0 / s) :+ l0)) // additive
}

`PSRC' _rd_adjust_l(`RC' y, `RC' w, `RC' y0, `RC' w0, `Bool' mean, `Int' link)
{   // location adjustment
    `RS' l, l0
    `RC' lny
    
    if (link==1) {                       // logarithmic
        lny = ln(y)
        l  = (mean ? mean(lny, w)     : _rd_median(lny, w))
        l0 = (mean ? mean(ln(y0), w0) : _rd_median(ln(y0), w0))
        return(&(exp(lny :+ (l0 - l))))
    }
    l  = (mean ? mean(y, w)   : _rd_median(y, w))
    l0 = (mean ? mean(y0, w0) : _rd_median(y0, w0))
    if (link==2) return(&(y * (l0 / l))) // multiplicative
    return(&(y :+ (l0 - l)))             // additive
}

`PSRC' _rd_adjust_s(`RC' y, `RC' w, `RC' y0, `RC' w0, `Bool' mean, `Bool' sd,
    `Int' link)
{   // scale adjustment
    `RS' l, s, s0
    `RC' lny
    
    if (link==1) {                       // logarithmic
        lny = ln(y)
        l  = (mean ? mean(lny, w) : _rd_median(lny, w))
        s  = (sd ? sqrt(variance(lny, w))     : _rd_iqrange(lny, w))
        s0 = (sd ? sqrt(variance(ln(y0), w0)) : _rd_iqrange(ln(y0), w0))
        return(&(exp((lny :- l) * (s0 / s) :+ l)))
    }
    if (link==2) return(&y)              // multiplicative (scale not relevant)
    l  = (mean ? mean(y, w) : _rd_median(y, w))
    s  = (sd ? sqrt(variance(y, w))   : _rd_iqrange(y, w))
    s0 = (sd ? sqrt(variance(y0, w0)) : _rd_iqrange(y0, w0))
    return(&((y :- l) * (s0 / s) :+ l)) // additive
}

void rd_get_at(`Data' data, `RC' at, `RC' atx, `Int' n)
{
    // grid based on outcome values
    if (mod(data.method,3)==1) {
        atx = _rd_uniq(sort(_rd_uniq(*data.Y1) \ _rd_uniq(*data.Y0), 1))
        at = _rd_relrank(*data.Y0, *data.W0, atx, ., 0, 0)
    }
    else if (mod(data.method,3)==2) {
        if (st_local("ATX0")!="") atx = _rd_get_at_mat("ATX0")
        else                      atx = strtoreal(tokens(st_local("atx2")))'
        at = _rd_relrank(*data.Y0, *data.W0, atx, ., 0, 0)
    }
    // grid based on probabilities
    else {
        if (st_local("at")!="")       at = strtoreal(tokens(st_local("at")))'
        else if (st_local("AT0")!="") at = _rd_get_at_mat("AT0")
        else                          at = (0::n-1) / (n-1)
        atx = _rd_quantile(*data.Y0, *data.W0, at, 1)
        if (at[1]==0) {
            if (min(*data.Y1)<atx[1]) {
                // set origin to infimum (i.e. the largest observed value below
                // the range of Y0)
                atx[1] = max(select(*data.Y1, *data.Y1:<atx[1]))
            }
        }
    }
    // set n if not defined yet
    if (n>=.) {
        n  = rows(atx)
        st_local("n", strofreal(n, "%18.0g"))
    }
}

`RC' _rd_get_at_mat(`SS' nm)
{
    `RM' at
    
    at = st_matrix(st_local(nm))'
    if (cols(at)>rows(at)) at = at'
    if (cols(at)>1) at = at[,1]
    return(_rd_uniq(sort(at,1)))
}

void rd_relrank(`Data' data)
{
    data.ranks = 
        _rd_relrank(*data.Y0, *data.W0, *data.Y1, *data.W1, data.tbreak, data.mid)
}

void rd_ogrid(`Data' data, `Bool' cdf)
{
    `Int' n
    `RC'  b
    `SM'  cstripe
    
    n = strtoreal(st_local("ogrid"))
    if (n<.) {
        cstripe = J(n,1,""), "q":+strofreal(1::n)
        if (cdf) b = _rd_ogrid(n, data, 0), _rd_ogrid(n, data, 1)
        else     b = _rd_ogrid(n, data, 0)
        st_matrix(st_local("OGRID"), b')
        st_matrixcolstripe(st_local("OGRID"), cstripe)
    }
}

`RC' _rd_ogrid(`Int' n, `Data' data, `Bool' grp)
{
    if (grp) return(_rd_quantile(*data.Y1, *data.W1, (0::n-1)/(n-1), 1))
             return(_rd_quantile(*data.Y0, *data.W0, (0::n-1)/(n-1), 1))
}


/* PDF estimation -----------------------------------------------------------*/

void rd_PDF(`Int' n)
{
    `RC'    at, atx
    `Data'  data
    pragma unset at
    pragma unset atx
    
    // prepare data
    rd_getdata(data)
    rd_adjust(data)
    
    // evaluation grid
    rd_get_at(data, at, atx, n)
    
    // estimation
    if (data.method>=3) rd_PDF_discrete(data, n, at, atx)
    else                rd_PDF_continuous(data, n, at, atx)
    
    // outcome grid
    rd_ogrid(data, 0)
}

void rd_PDF_discrete(`Data' data, `Int' n, `RC' at, `RC' atx)
{
    `RC'  b
    `SM'  cstripe
    
    // estimation
    if (data.method==4) b = _rd_PDF_discrete_b(*data.Y1, *data.W1, atx, at)
    else                b = _rd_PDF_discrete_map_b(data, at, atx)
    
    // remove missings (relative pdf will be missing for x-values that do not
    // exist in the reference distribution)
    if (data.method>3) {
        if (hasmissing(b)) _rd_PDF_discrete_rm(b, at, atx, n)
    }
    
    // return results
    if (data.method>3) {
        if (st_local("categorical")!="")
             cstripe = (J(n,1,""), strofreal(atx):+("."+st_local("depvar")))
        else cstripe = (J(n,1,""), "x":+strofreal(1::n))
    }
    else cstripe = (J(n,1,""), "p":+strofreal(1::n))
    st_matrix(st_local("b"), b')
    st_matrixcolstripe(st_local("b"), cstripe)
    st_matrix(st_local("AT"), (at, atx)')
    st_matrixcolstripe(st_local("AT"), cstripe)
    st_matrixrowstripe(st_local("AT"), (J(2,1,""), ("p" \ "x")))
}

`RC' _rd_PDF_discrete_map_b(`Data' data, `RC' at, `RC' atx)
{
    `Int'  i, j, n, r
    `RC'   b, rd, cdf, x
    
    // compute relative density at observed values
    x   = _rd_uniq(sort(_rd_uniq(*data.Y1) \ _rd_uniq(*data.Y0), 1))
    cdf = _rd_relrank(*data.Y0, *data.W0, x, ., 0, 0)
    rd  = _rd_PDF_discrete_b(*data.Y1, *data.W1, x, cdf)
    r   = rows(rd)
    
    // map rd to evaluation grid
    n = rows(at)
    b = J(n, 1, .)
    j = 1
    // - mat to at()
    if (data.method==3) {
        // first get rid of points that do not exist in refdist and were 
        // only included to get the computations for the other points right
        cdf = select(cdf, rd:<.)
        rd = select(rd, rd:<.)
        r = rows(rd)
        for (i=1; i<=n; i++) {
            for  (; j<r; j++) {
                if (cdf[j]>=at[i]) break
            }
            b[i] = rd[j]
        }
        return(b)
    }
    // - map to atx()
    r = rows(rd)
    for (i=1; i<=n; i++) {
        for  (; j<r; j++) {
            if (x[j]>=atx[i]) break
        }
        if (x[j]==atx[i]) b[i] = rd[j] // only fill in if exact match
    }
    return(b)
}

`RC' _rd_PDF_discrete_b(`RC' Y, `RC' w, `RC' atx, `RC' at)
{
    `Int' n
    `RC'  b, p
    
    b = _rd_relrank(Y, w, atx, ., 0, 0)
    n = rows(b)
    b = b  - (0 \  b[|1\n-1|])
    p = at - (0 \ at[|1\n-1|])
    b = b :/ p
    _rd_PDF_discrete_div(b, p)
    return(b)
}

void _rd_PDF_discrete_div(`RC' b, `RC' p) // compute divergence and chi2
{   
    st_numscalar(st_local("DIV"),  sum(b :* ln(b) :* p))
    st_numscalar(st_local("CHI2"), sum((b :- 1):^2 :* p))
}

void _rd_PDF_discrete_rm(`RC' b, `RC' at, `RC' atx, `Int' n)
{
    `Int'  i, j
    `IntC' p
    
    p = J(n,1,.)
    j = 0
    for (i=1;i<=n;i++) {
        if (b[i]>=.) {
            printf("{txt}(x = %g omitted due to zero frequency in reference distribution)\n", atx[i])
            continue
        }
        p[++j] = i
    }
    if (j==0) {
        display("{err}no remaining evaluation points")
        exit(499)
    }
    p = p[|1\j|]
    b = b[p]; at = at[p]; atx = atx[p]; n = rows(p)
    st_local("n", strofreal(n, "%18.0g"))
}

void rd_PDF_continuous(`Data' data, `Int' n, `RC' at, `RC' atx)
{
    `Bool'  exact, altlbwf, pw, nose
    `Int'   adaptive, boundary, n0, nhist
    `RS'    bw, bwdpi, bwadj
    `SS'    bwmethod, kernel
    `RC'    b, v, at0, lbwf, gc
    `SM'    cstripe
    `PSRCF' lbwffun
    pragma unset lbwf
    pragma unset gc
    
    // settings
    bw       = strtoreal(st_local("bwidth"))
    bwmethod = st_local("bwmethod")
    bwdpi    = strtoreal(st_local("bwdpi"))
    bwadj    = strtoreal(st_local("bwadjust"))
    kernel   = _mm_unabkern(st_local("kernel"))
    adaptive = strtoreal(st_local("adaptive"))
    exact    = (st_local("exact")!="")
    n0       = strtoreal(st_local("napprox"))
    altlbwf  = (st_local("altlbwf")!="")
    boundary = 0 + (st_local("boundary")=="reflect") + 2*(st_local("boundary")=="lc")
    nose     = (st_local("nose")!="")
    nhist    = strtoreal(st_local("nhist"))
    pw       = (data.wtype==2)
    
    // compute relative ranks
    rd_relrank(data)
    
    // bandwidth
    if (bw>=.) {
        bw = rd_PDF_bw(data.ranks, *data.W1, bwmethod, bwdpi, kernel, n0)
        if (bw>=.) {
            display("{txt}(bandwidth estimation failed; using oversmoothed bandwidth)")
            bwmethod = "oversmoothed"
            st_local("bwmethod", bwmethod)
            bw = rd_PDF_bw(data.ranks, *data.W1, bwmethod, bwdpi, kernel, n0)
        }
        if (data.wtype==2) {    // adjustment in case of pweights
            bw = bw * (colsum(*data.W1:^2)/rows(*data.W1))^.2
        }
    }
    bw = bw * bwadj
    
    // estimation
    lbwffun = (altlbwf ? &rd_PDF_lbwf() : &kdens_lbwf())
    if (exact) {    // exact estimator: can directly use evaluation grid
        b = _kdens(data.ranks, *data.W1, at, bw, kernel, adaptive, 0, 1, 
            boundary, lbwf, lbwffun)
    }
    else {          // binned approximation estimator: use grid of size n0
        at0 = (0::n0-1) / (n0-1)
        b = kdens(data.ranks, *data.W1, at0, bw, kernel, adaptive, 1, 1, 
            boundary, lbwf, gc, 1, lbwffun)
    }
    
    // standard errors
    if (nose==0) {
        if (exact) {
            v = _kdens_var(b, data.ranks, *data.W1, at, bw, kernel, pw, 0, 1,
                boundary, lbwf)
            if (rows(lbwf)>1) lbwf = mm_ipolate(data.ranks, lbwf, at, 1)
        }
        else {
            v = kdens_var(b, data.ranks, *data.W1, at0, bw, kernel, pw, 1, 1,
                boundary, lbwf, gc)
        }
        v = v + rd_PDF_varincr(data.N0, data.w0, b, bw*lbwf, kernel, pw)
    }
    
    // return results
    if (nhist<.) cstripe = J(n, 1, "pdf")
    else         cstripe = J(n, 1, "")
    if (data.method) cstripe = cstripe, "x" :+ strofreal(1::n)
    else             cstripe = cstripe, "p" :+ strofreal(1::n)
    if (exact) st_matrix(st_local("b"), b')
    else       st_matrix(st_local("b"), mm_ipolate(at0, b, at)')
    st_matrixcolstripe(st_local("b"), cstripe)
    st_matrix(st_local("AT"), (at, atx)')
    st_matrixcolstripe(st_local("AT"), cstripe)
    st_matrixrowstripe(st_local("AT"), (J(2,1,""), ("p" \ "x")))
    st_numscalar(st_local("BW"), bw)
    st_local("kernel", kernel)
    if (nose==0) {
        if (exact) st_matrix(st_local("se"), sqrt(v)')
        else       st_matrix(st_local("se"), mm_ipolate(at0, sqrt(v), at)')
        st_matrixcolstripe(st_local("se"), cstripe)
    }
    
    // divergence
    if (exact==0) {
        gc = J(rows(b),1,1); gc[1] = .5; gc[rows(gc)] = .5 // 1/2 weight at boundary
        st_numscalar(st_local("DIV"), mean(b :* ln(b), gc))
        st_numscalar(st_local("CHI2"), mean((b :-1):^2, gc))
    }
    
    // append histogram
    if (nhist<.) {
        b = _rd_HIST(nhist, data, at, atx)
        cstripe = cstripe \ (J(nhist,1,"histogram"), "h":+strofreal(1::nhist))
        st_matrix(st_local("b"), (st_matrix(st_local("b"))' \ b)')
        st_matrixcolstripe(st_local("b"), cstripe)
        st_matrix(st_local("AT"), (st_matrix(st_local("AT"))' \ (at, atx))')
        st_matrixcolstripe(st_local("AT"), cstripe)
        if (nose==0) {
            st_matrix(st_local("se"), (st_matrix(st_local("se")), J(1,nhist,0)))
            st_matrixcolstripe(st_local("se"), cstripe)
        }
    }
}

// bandwidth estimation
`RS' rd_PDF_bw(`RC' x, `RC' w, `SS' method, `Int' dpi, `SS' kernel, `Int' m) 
{
    `RS' bw

    if (method=="sjpi")     bw = rd_PDF_bw_sjpi(x, w, m, "minim")
    else if (method=="dpi") bw = rd_PDF_bw_dpi(x, w, m, "minim", dpi)
    else                    bw = rd_PDF_bw_simple(x, w, method)
    return( (*_mm_findkdel0(kernel))() * bw )
}

// alternative local bandwidth factor function
`RC' rd_PDF_lbwf(`RC' x, `RC' w, `RC' g, `RC' d)
{
    `RC' l

    if (x==g) l = d
    else      l = mm_ipolate(g, d, x)
    //l = l:*(l:>=1) + (2:-l):*(l:<1)    // 1 + |deviation from 1|
    l = l:*(l:>=1) + (1:/l):*(l:<1)      // symmetric
    l = sqrt( exp(mean(log(l), w)) :/ l)
    _editmissing(l, 1)
    return(l)
}

// bandwidth estimation: modified rule-of-thumb methods
`RS' rd_PDF_bw_simple(`RC' x, `RC' w, `SS' method)
{
    `SS' scale

    scale = (method=="oversmoothed" ? "stddev" : "minim")
    return(kdens_bw_simple(x, w, method, scale) *
        (1 + 1/(2*sqrt(pi())*_kdens_bw_scale(x, w, scale)))^.2)
}

// bandwidth estimation: modified DPI
`RS' rd_PDF_bw_dpi(`RC' x, `RC' w, `Int' m, `SS' scale, `Int' level)
{
    `RS' n, s, psi, alpha, i, psi0, alpha0
    `RC' g, gc

    // grid
    g  = mm_makegrid(x, m, 0, 0, 1)
    gc = mm_fastlinbin(x, w, g)
    n  = colsum(gc)
    s  = _kdens_bw_scale(x, w, scale)

    // plug-in steps
    if (level==0) {
        psi = 3/(8*sqrt(pi())*s^5)
        psi0 = 1/(2*sqrt(pi())*s)
    }
    else {
        alpha = (2*(sqrt(2)*s)^(3+2*(level+1)) /
            ((1+2*(level+1))*n))^(1/(3+2*(level+1)))
        alpha0 = (2*(sqrt(2)*s)^(3+2*(level-1)) /
            ((1+2*(level-1))*n))^(1/(3+2*(level-1)))
        for (i=level; i>=1; i--) {
            psi = kdens_df(g, gc, alpha, i+1, 1, 1)
            psi0 = kdens_df(g, gc, alpha0, i-1, 1, 1)
            if (i>1) {
                alpha = ( factorial(i*2)/(2^i*factorial(i)) *
                    sqrt(2/pi())/(psi*n) )^(1/(3+2*(i)))
                alpha0 = ( factorial((i-2)*2)/(2^(i-2)*factorial(i-2)) *
                    sqrt(2/pi())/(psi0*n) )^(1/(3+2*(i-2)))
            }
        }
    }
    return( ((1+psi0)/(psi*n))^(1/5) )
}

// bandwidth estimation: modified SJPI
`RS' rd_PDF_bw_sjpi(`RC' x, `RC' w, `Int' m, `SS' scale)
{
    `RS' n, s, lambda, hmin, ax, bx, rc
    `RC' g, gc
    `RR' h

    // grid
    g       = mm_makegrid(x, m, 0, 0, 1)
    gc      = mm_fastlinbin(x, w, g)
    n       = colsum(gc)
    s       = sqrt(variance(x, w))
    if      (scale=="minim")  lambda = min((s, mm_iqrange(x, w) / 1.349))
    else if (scale=="stddev") lambda = s
    else if (scale=="iqr")    lambda = mm_iqrange(x, w) / 1.349
    else    _error(3498, `"""' + scale + `"" invalid"')
    if      (lambda<=0)       lambda = s

    // root finding
    hmin = (g[rows(g)]-g[1])/(rows(g)-1) / 2 *
        mm_kdel0_gaussian() / mm_kdel0_rectangle()
    bx = s * (243/(35*n))^.2 * mm_kdel0_gaussian() *
        (1 + 1/(2*sqrt(pi())*s))^.2     // h_oversmoothed
    while (1) {
        if (hmin>=bx) return(.)
        ax = max((hmin, bx*0.1))
        rc = mm_root(h=., &_rd_PDF_bw_sjpi(), ax, bx, ax*0.1, 100,
            g, gc, lambda)
        if ( rc==2 ) bx = ax            // continue if solution < ax
        else return(h / mm_kdel0_gaussian())
    }
}

`RS' _rd_PDF_bw_sjpi(`RS' h, `RC' g, `RC' gc, `RS' lambda)
{
    `RS' n, a, b, tdb, sda, alpha2, sdalpha2, c, tdc, beta, sdbeta

    n           = colsum(gc)
    a           = 1.241 * lambda * n^(-1/7)
    b           = 1.230 * lambda * n^(-1/9)
    tdb         = kdens_df(g, gc, b, 3, 1, 1)
    sda         = kdens_df(g, gc, a, 2, 1, 1)
    alpha2      = 1.357 * (sda/tdb)^(1/7) * h^(5/7)
    sdalpha2    = kdens_df(g, gc, alpha2, 2, 1, 1)
    c           = 1.304 * lambda * n^(-1/5)
    tdc         = kdens_df(g, gc, c, 1, 1, 1)
    beta        = 1.414 * (sda/tdc)^(1/3) * h^(5/3)
    sdbeta      = kdens_df(g, gc, beta, 0, 1, 1)
    //simple alternative (Cwik and Mileniczuk 1993):
    //c           = 1.781 * lambda * n^(-1/3)
    //sdbeta      = kdens_df(g, gc, c, 0, 1, 1)
    return(((mm_kint_gaussian(2) * (1 + sdbeta))/(n * sdalpha2))^0.2 - h)
}

// variance correction
`RC' rd_PDF_varincr(`RS' N0, `RC' w0, `RC' g, `RC' h, `SS' kernel, `Bool' pw)
{
    `RC' c

    c = (g:^2 * (*_mm_findkint(kernel))(2)) :/ h
    if (pw) c = c * (colsum(w0:^2) / rows(w0)^2)
    else    c = c / N0
    return(c)
}

/* histogram estimation -----------------------------------------------------*/

void rd_HIST(`Int' n)
{
    `RC'    b, at, atx
    `SM'    cstripe
    `Data'  data
    pragma unset at
    pragma unset atx
    
    // prepare data
    rd_getdata(data)
    rd_adjust(data)
    rd_relrank(data)
    
    // estimation
    b = _rd_HIST(n, data, at, atx)
    
    // return results
    cstripe = J(n,1,""), "h":+strofreal(1::n)
    st_matrix(st_local("b"), b')
    st_matrixcolstripe(st_local("b"), cstripe)
    st_matrix(st_local("AT"), (at, atx)')
    st_matrixcolstripe(st_local("AT"), cstripe)
    st_matrixrowstripe(st_local("AT"), (J(2,1,""), ("p" \ "x")))
    
    // outcome grid
    rd_ogrid(data, 0)
}

`RC' _rd_HIST(`Int' n, `Data' data, `RC' at, `RC' atx)
{
    `RC' b
    
    at = (0::n) / n
    b = mm_exactbin(data.ranks, *data.W1, at, 1)
    b = b * (n / mm_nobs(data.ranks, *data.W1))
    at = at[|1 \ n |] :+ .5/n
    atx = _rd_quantile(*data.Y0, *data.W0, at, 1)
    return(b)
}

/* CDF estimation -----------------------------------------------------------*/

void rd_CDF(`Int' n)
{
    `RC'   b, at, atx
    `SM'   cstripe
    `Data' data
    pragma unset at
    pragma unset atx
    
    // prepare data
    rd_getdata(data)
    rd_adjust(data)
    
    // evaluation grid
    rd_get_at(data, at, atx, n)
    
    // estimate
    if (mod(data.method,3)) b = _rd_relrank(*data.Y1, *data.W1, atx, ., 0, 0)
    else                    b = _rd_CDF_ipolate(data, at)
    
    // return results
    if (data.method) {
        if (st_local("categorical")!="")
             cstripe = (J(n,1,""), strofreal(atx):+("."+st_local("depvar")))
        else cstripe = (J(n,1,""), "x":+strofreal(1::n))
    }
    else cstripe = (J(n,1,""), "p":+strofreal(1::n))
    st_matrix(st_local("b"), b')
    st_matrixcolstripe(st_local("b"), cstripe)
    st_matrix(st_local("AT"), (at, atx)')
    st_matrixcolstripe(st_local("AT"), cstripe)
    st_matrixrowstripe(st_local("AT"), (J(2,1,""), ("p" \ "x")))
    
    // indicator for whether zero coordinate should be added in graph
    //    only if: - evaluation has been done at outcome values
    //             - first y-coordinate is not zero
    //             - if first evaluation point is not larger than min of Y
    if (mod(data.method,3)) {
        if (at[1]>0) {
            if (mod(data.method, 3)==1)    st_local("origin", "origin")
            else if (atx[1]<=min(*data.Y1 \ *data.Y0)) st_local("origin", "origin")
        }
    }
    
    // - outcome grid
    rd_ogrid(data, 1)
}

`RC' _rd_CDF_ipolate(`Data' data, `RC' at)
{
    `Int' i, j
    `RC'  x, cdf0, cdf1, b
    
    // obtain exact cdf
    x    = _rd_uniq(sort(_rd_uniq(*data.Y1) \ _rd_uniq(*data.Y0), 1))
    cdf1 = 0 \ _rd_relrank(*data.Y1, *data.W1, x, ., 0, 0)
    cdf0 = 0 \ _rd_relrank(*data.Y0, *data.W0, x, ., 0, 0)
    
    // move to point where cdf0 first reaches 1
    for (j = rows(cdf0); j; j--) {
        if (cdf0[j]<1) break
    }
    j++
    
    // interpolate
    i = rows(at)
    b = J(i,1,.)
    for (; i; i--) {
        for (; j; j--) {
            if (cdf0[j]<=at[i]) break
        }
        if (cdf0[j]==at[i]) b[i] = cdf1[j]
        else b[i] = cdf1[j] + (cdf1[j+1]-cdf1[j]) * 
                   (at[i]-cdf0[j]) / (cdf0[j+1] - cdf0[j])
    }
    return(b)
}

/* MRP estimation -----------------------------------------------------------*/

void rd_MRP(`SS' bnm)
{
    `RR'   b
    `RC'   d
    `Data' data
    
    // prepare data
    rd_getdata(data)
    rd_adjust(data)
    rd_relrank(data)
    
    // estimation
    d = data.ranks :- 0.5
    b = J(1,3,.)
    b[2] = 8 * mean( -d :* (d:<0), *data.W1) - 1 // LRP
    b[3] = 8 * mean(  d :* (d:>0), *data.W1) - 1 // URP
    b[1] = (b[2] + b[3]) / 2                     // MRP
    //b[1] = 4 * mean(abs(d), *data.W1) - 1
    
    // return results
    st_matrix(bnm, b)
    st_matrixcolstripe(bnm, (J(3,1,""), tokens("MRP LRP URP")'))
}

/* Generate relative ranks for summarize ------------------------------------*/

void rd_SUM()
{
    `Int'  touse
    `Data' data
    
    // prepare data
    rd_getdata(data)
    rd_adjust(data)
    rd_relrank(data)
    
    // return results
    if (data.by) {
        if (data.adj1.shape) {
            if (data.pooled) touse = st_varindex(st_local("touse"))
            else             touse = st_varindex(st_local("touse0")) 
        }
        else touse = st_varindex(st_local("touse1"))
    }
    else touse = st_varindex(st_local("touse"))
    st_store(., st_local("ranks"), touse, data.ranks[invorder(*data.P1)])
    if (data.balanced) st_store(., st_local("WVAR"), touse, *data.W1[invorder(*data.P1)])
}

/* Helper functions ---------------------------------------------------------*/

// return unique values of X
// - X assumed sorted and nonmissing
`RC' _rd_uniq(`RC' X)  
{
    return(select(X, X:!=(X[|2\.|]\.)))
}

// quantile function:
// d=1: inverse of empirical CDF (definition 1 in Hyndman&Fan 1996)
// d=2: take averages where CDF is flat (definition 2 in Hyndman&Fan 1996)
// - X assumed sorted and nonmissing
// - P assumed sorted and in [0,1]
`RS' _rd_median(`RC' X, `RC' w) return(_rd_quantile(X, w, .5, 2))
`RS' _rd_iqrange(`RC' X, `RC' w)
{
    `RC' q

    q = _rd_quantile(X, w, (.25 \ .75), 2)
    return(q[2]-q[1])
}
`RC' _rd_quantile(`RC' X, `RC' w, `RC' P, `Int' d)
{
    if (d==2) {
        if (rows(w)!=1) return(_rd_quantile2_w(X, w, P))
        return(_rd_quantile2(X, P))
    }
    if (rows(w)!=1) return(_rd_quantile1_w(X, w, P))
    return(_rd_quantile1(X, P))
}

`RC' _rd_quantile1(`RC' X, `RC' P)
{
    `Int'  n
    `IntC' j
    
    n = rows(X)
    if (n==0) return(J(rows(P),1,.))
    j = ceil(P * n)
    _editvalue(j, 0, 1) // use minimum if P = 0
    return(X[j])
}

`RC' _rd_quantile2(`RC' X, `RC' P)
{
    `Int'  n
    `IntC' g, j, j1
    
    n = rows(X)
    if (n==0) return(J(rows(P),1,.))
    g = P * n
    j = floor(g)
    g = 0.5 :+ 0.5*((g - j):>0)
    j1 = j :+ 1
    _editvalue(j, 0, 1)
    _editvalue(j1, n+1, n)
    return((1:-g):*X[j] + g:*X[j1])
}

`RC' _rd_quantile1_w(`RC' X, `RC' w, `RC' P0)
{
    `Int'  n, r, i, j
    `RC'   W, P, Q
    `RS'   pi
    
    n = rows(X)
    if (n==0) return(J(rows(P0),1,.))
    W = quadrunningsum(w)
    P = P0 * W[n]
    r = rows(P)
    Q = J(r,1,.)
    j = n
    for (i=r; i; i--) {
        pi = P[i]
        for (;j>1; j--) {
            if (W[j-1]<pi) break
        }
        Q[i] = X[j]
    }
    return(Q)
}

`RC' _rd_quantile2_w(`RC' X, `RC' w, `RC' P0)
{
    `Int'  n, r, i, j, k
    `RC'   W, P, Q
    `RS'   pi
    
    n = rows(X)
    if (n==0) return(J(rows(P0),1,.))
    W = quadrunningsum(w)
    P = P0 * W[n]
    r = rows(P)
    Q = J(r,1,.)
    j = n
    for (i=r; i; i--) {
        pi = P[i]
        for (;j>1; j--) {
            if (W[j-1]<pi) break
        }
        if (W[j]==pi) {
            k = j
            while (1) {
                if (k==n) break
                if (W[k]>pi) break
                k++
            }
            Q[i] = (X[j] + X[k])/2
        }
        else Q[i] = X[j]
    }
    return(Q)
}

// compute relative ranks of X in distribution of Y
// - Y and X assumed sorted and nonmissing
`RC' _rd_relrank(`RC' Y, `RC' wY, `RC' X, `RC' wX, `Bool' tbreak, `Bool' mid)
{
    `RC' y, cdf
    pragma unset y
    
    // get cdf of Y0 at unique values; y will be filled in
    cdf = _rd_relrank_cdf(Y, wY, y)

    // get relative ranks
    if (!tbreak) {
        if (!mid) return(_rd_relrank_1(X, y, cdf))
                  return(_rd_relrank_2(X, y, cdf))
    }
    if (rows(wX)==1) {
        if (!mid) return(_rd_relrank_3(X, y, cdf))
                  return(_rd_relrank_4(X, y, cdf))
    }
    if (!mid)     return(_rd_relrank_5(X, wX, y, cdf))
                  return(_rd_relrank_6(X, wX, y, cdf))
}
// - compute CDF of X and replace x with uniq values of X
`RC' _rd_relrank_cdf(`RC' X, `RC' w, `RC' x)
{   
    `Int'  i, n, j
    `IntC' p
    `RS'   xi
    `RC'   cdf

    // compute ranks
    n = rows(X)
    if (rows(w)==1) cdf = 1::n
    else            cdf = quadrunningsum(w)
    
    // remove ties (get last obs in each group)
    x = X
    p = J(n, 1, 0)
    i = j = n
    p[j] = i
    xi = x[i]
    i--
    for (; i; i--) {
        if (x[i]!=xi) {
            j--
            p[j] = i
            xi = x[i]
        }
    }
    p   = p[|j \ n|]
    x   = x[p]
    cdf = cdf[p]
    
    // return normalized ranks
    return(cdf / cdf[rows(cdf)])
}
// - case 1: tbreak = 0, mid = 0
`RC' _rd_relrank_1(`RC' x, `RC' y, `RC' cdf)
{
    `Int'  i, j
    `RS'   xi
    `RC'   r
    
    i = rows(x)
    r = J(i, 1, 0)
    j = rows(y)
    for (; i; i--) {
        xi = x[i]
        for (; j; j--) {
            if (y[j]<=xi) break
        }
        if (j) r[i] = cdf[j]
        else break // x[i] is smaller than min(y)
    }
    return(r)
}
// - case 2: tbreak = 0, mid = 1
`RC' _rd_relrank_2(`RC' x, `RC' y, `RC' cdf)
{
    `Int'  i, j
    `RS'   xi
    `RC'   r, step
    
    i = rows(x)
    r = J(i, 1, 0)
    j = rows(y)
    step = cdf - (0 \ cdf[|1\j-1|])
    for (; i; i--) {
        xi = x[i]
        for (; j; j--) {
            if (y[j]<=xi) break
        }
        if (j) {
            if (y[j]==xi) r[i] = cdf[j] - step[j]/2
            else          r[i] = cdf[j]
        }
        else break // x[i] is smaller than min(y)
    }
    return(r)
}
// - case 3: tbreak==1, mid = 0, no weights
`RC' _rd_relrank_3(`RC' x, `RC' y, `RC' cdf)
{
    `Int'  i, j, k
    `RS'   xi
    `RC'   r, step
    
    i = rows(x)
    r = J(i, 1, 0)
    j = rows(y)
    step = cdf - (0 \ cdf[|1\j-1|])
    for (; i; i--) {
        xi = x[i]
        for (; j; j--) {
            if (y[j]<=xi) break
        }
        if (j) {
            r[i] = cdf[j]
            if (y[j]==xi) {
                for (k=i-1; k; k--) { // find ties in x
                    if (x[k]<xi) break
                }
                if ((++k)==i) continue // no ties
                r[|k\i-1|] = cdf[j] :- step[j] :* (i:-(k::i-1)) / (i-k+1)
                i = k
            }
        }
        else break // x[i] is smaller than min(y)
    }
    return(r)
}
// - case 4: tbreak==1, mid = 1, no weights
`RC' _rd_relrank_4(`RC' x, `RC' y, `RC' cdf)
{
    `Int'  i, j, k
    `RS'   xi
    `RC'   r, step
    
    i = rows(x)
    r = J(i, 1, 0)
    j = rows(y)
    step = cdf - (0 \ cdf[|1\j-1|])
    for (; i; i--) {
        xi = x[i]
        for (; j; j--) {
            if (y[j]<=xi) break
        }
        if (j) {
            if (y[j]==xi) {
                for (k=i-1; k; k--) { // find ties in x
                    if (x[k]<xi) break
                }
                if ((++k)==i) {
                    r[i] = cdf[j] - step[j] * 0.5
                    continue
                }
                r[|k\i|] = cdf[j] :- step[j] :* ((i+.5):-(k::i)) / (i-k+1)
                i = k
            }
            else r[i] = cdf[j]
        }
        else break // x[i] is smaller than min(y)
    }
    return(r)
}
// - case 5: tbreak==1, mid = 0, weighted
`RC' _rd_relrank_5(`RC' x, `RC' w, `RC' y, `RC' cdf)
{
    `Int'  i, j, k
    `RS'   xi, W
    `RC'   r, step, ww
    
    i = rows(x)
    r = J(i, 1, 0)
    j = rows(y)
    step = cdf - (0 \ cdf[|1\j-1|])
    for (; i; i--) {
        xi = x[i]
        for (; j; j--) {
            if (y[j]<=xi) break
        }
        if (j) {
            r[i] = cdf[j]
            if (y[j]==xi) {
                for (k=i-1; k; k--) { // find ties in x
                    if (x[k]<xi) break
                }
                if ((++k)==i) continue // no ties
                ww = runningsum(w[|k\i|])
                W  = ww[rows(ww)]
                if (W==0) {
                    r[|k\i-1|] = cdf[j] :- step[j] :* (i:-(k::i-1)) / (i-k+1)
                }
                else {
                    ww = ww[|1\rows(ww)-1|]
                    r[|k\i-1|] = cdf[j] :- step[j] :* (W:-ww) / W
                }
                i = k
            }
        }
        else break // x[i] is smaller than min(y)
    }
    return(r)
}
// - case 6: tbreak==1, mid = 1, weighted
`RC' _rd_relrank_6(`RC' x, `RC' w, `RC' y, `RC' cdf)
{
    `Int'  i, j, k
    `RS'   xi, W
    `RC'   r, step, ww, wstep
    
    i = rows(x)
    r = J(i, 1, 0)
    j = rows(y)
    step = cdf - (0 \ cdf[|1\j-1|])
    for (; i; i--) {
        xi = x[i]
        for (; j; j--) {
            if (y[j]<=xi) break
        }
        if (j) {
            if (y[j]==xi) {
                for (k=i-1; k; k--) { // find ties in x
                    if (x[k]<xi) break
                }
                if ((++k)==i) {
                    r[i] = cdf[j] - step[j] * 0.5
                    continue // no ties
                }
                ww = runningsum(w[|k\i|])
                W  = ww[rows(ww)]
                if (W==0) {
                    r[|k\i|] = cdf[j] :- step[j] :* ((i+.5):-(k::i)) / (i-k+1)
                }
                else {
                    wstep = ww - (0 \ ww[|1\rows(ww)-1|])
                    ww = ww - 0.5 * wstep
                    r[|k\i|] = cdf[j] :- step[j] :* (W:-ww) / W
                }
                i = k
            }
            else r[i] = cdf[j]
        }
        else break // x[i] is smaller than min(y)
    }
    return(r)
}

end
exit

