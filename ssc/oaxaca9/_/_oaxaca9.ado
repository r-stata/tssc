*! version 1.0.0  15dec2009  Ben Jann
*! eqiuivalent to: oaxaca.ado version 1.1.2  20apr2009  Ben Jann

program define _oaxaca9, rclass sortpreserve
    version 9.2
    capt syntax [, Level(passthru) eform xb noLEgend ]
    if _rc==0 {
        Display `0'
        exit
    }
    syntax anything ///
        [if] [in] [fw aw pw iw] [,  ///
        THREEfold THREEfold2(str)                   ///
        Weights(numlist) Reference(name) split      ///
        Adjust(passthru)                            ///
        Detail Detail2(passthru)                    ///
        CATegorical(string)                         ///
        nocheck             /// undocumented: skip checks for categorical()
        x1(passthru) x2(passthru)                   ///
        FIXed FIXed2(string)                        ///
        noSE                                        ///
        SVY SVY2(str asis)                          ///
        vce(str) CLuster(passthru)                  ///
        NOSUEST SUEST SUEST2(name)                  ///
        eform                                       ///
        Level(passthru)                             ///
        xb                                          ///
        noLEgend                                    ///
        NOIsily                                     ///
        nodisplay                                   ///
        depname(passthru)   /// dependent variable name for returns/display
        nlcom               /// undocumented: use nlcom to derive SE's (slow)
    ]
    _parse_elist `anything' // returns local elist
    local se = "`se'"==""
    if `"`fixed2'"'!="" local fixed
    if `"`detail2'"'!="" local detail detail
    if `"`weights'"'=="" & `"`reference'"'=="" local threefold threefold
    if `"`threefold2'"'!="" {
        if `"`threefold2'"'!=substr("reverse",1,max(1,strlen(`"`threefold2'"'))) {
            di as err "invalid threefold() option"
            exit 198
        }
        local threefold threefold
        local threefold2 reverse
    }
    if (`"`weights'"'!="") + (`"`reference'"'!="") + ("`threefold'"!="")>1 {
        di as err "only one of threefold, weight(), and reference() allowed"
        exit 198
    }
    if `"`suest2'"'!="" local suest suest
    if "`nosuest'"!="" & "`suest'"!="" {
        di as err "suest and nosuest not both allowed"
        exit 198
    }
    if `"`svy2'"'!="" local svy "svy"
    if "`svy'"!="" {
        local i 0
        foreach opt in vce cluster weight {
            local optnm: word `++i' of "vce()" "cluster()" "weights"
            if `"``opt''"'!="" {
                di as err "`optnm' not allowed with svy"
                exit 198
            }
        }
    }
    local qui = cond("`noisily'"=="","quietly","")

// reference equal to one of the groups?
    if "`reference'"!="" {
        local tmp: list posof "`reference'" in elist
        if `tmp' {
            local weights = 2 - `tmp'
            local reference
        }
    }

// use suest?
    local suest = cond("`suest'"!="",1,0)
    if `"`reference'`svy'`cluster'"'!="" {
        local suest 1
    }
    if `"`vce'"'!="" {
        _vce_iscluster `vce'
        if `vce_iscluster' local suest 1
        local vce `"vce(`vce')"'
    }
    if `se'==0 | "`nosuest'"!="" {
        local suest 0
    }

// get estimates
    local robreg = (`suest'==0 & `se')
    nobreak {
    // preserve last estimates
        tempname hcurrent
        tempvar  touse1 touse2 subpop1 subpop2
        _est hold `hcurrent', restore nullok estsystem
        local g 0
        foreach est in `elist' `reference' {
            local ++g
            qui estimates restore `est'
        // determine esample (and subpop if svy)
            if `g'<3 {
                qui gen byte `touse`g'' = e(sample)==1
                _marksubpop `e(subpop)', g(`subpop`g'')
                qui replace `subpop`g'' = 0 if `touse`g''==0
                if "`svy'"=="" {
                    qui replace `touse`g'' = 0 if `subpop`g''==0
                }
                if "`e(cmd)'"=="heckman" | "`e(cmd)'"=="heckprob" {
                    local depvar: word 1 of `e(depvar)'
                    qui replace `subpop`g'' = 0 if `depvar'>=.
                    if "`svy'"=="" {
                        qui replace `touse`g'' = 0 if `depvar'>=.
                    }
                    local depvar_s: word 2 of `e(depvar)'
                    if "`depvar_s'"!="" {
                        qui replace `subpop`g'' = 0 if `depvar_s'==0
                        if "`svy'"=="" {
                            qui replace `touse`g'' = 0 if `depvar_s'==0
                        }
                    }
                }
            }
        // if not suest: get coefficients (and variances if se)
            if `suest'==0 {
                tempname b`g'
                mat `b`g'' = e(b)
                local firsteq: coleq `b`g'', q
                local firsteq: word 1 of `firsteq'
                mat `b`g'' = `b`g''[1,"`firsteq':"]
                local eqlab = "b`g'"
                if `g'==3 local eqlab = "b_ref"
                mat coleq `b`g'' = "`eqlab'"
                if `se' {
                    tempname V`g'
                    mat `V`g'' = e(V)
                    mat `V`g'' = `V`g''["`firsteq':","`firsteq':"]
                    mat coleq `V`g'' = "`eqlab'"
                    mat roweq `V`g'' = "`eqlab'"
                    if "`e(vce)'"!="robust" local robreg 0
                }
            }
        }
    }
    if `robreg' {
        local e_vce     "robust"
        local e_vcetype "Robust"
    }

// apply suest
    tempname b
    if `se' {
        tempname V
    }
    if `suest' {
        `qui' suest `elist' `reference', `svy' `vce' `cluster'
        if `"`suest2'"'!="" {
            est sto `suest2'
        }
        mat `b' = e(b)
        mat `V' = e(V)
        local e_vce     "`e(vce)'"
        local e_vcetype "`e(vcetype)'"
        ExtractFirstEqs "b1 b2 b_ref" `b' `V'
    }
    else {
        mat `b' = `b1', `b2'
        mat drop `b1' `b2'
        if `se' {
            mat `V' = `V1'
            MatAppendDiag `V' `V2'
            mat drop `V1' `V2'
        }
        if `g'==3 {
            mat `b' = `b', `b3'
            mat drop `b3'
            if `se' {
                MatAppendDiag `V' `V3'
                mat drop `V3'
            }
        }
    }

// apply deviation contrast transform to categorical variables
    if `"`categorical'"'!="" {
        if "`check'"=="" {
            local check check(`subpop1' `subpop2')
        }
        else local check
        if `se' {
            _devcon `b' `V', groups(`categorical') `check'
        }
        else {
            _devcon `b', groups(`categorical') `check'
        }
    }

// insert 0's for missing coefficients
    mata: oaxaca_insertmissingcoefs()  // returns coefnames in local coef

// compute means
    marksample touse, novarlist zeroweight
    qui replace `touse' = 0 if `touse1'==0 & `touse2'==0
    tempname x Vx
    if "`svy'"!="" {
        capt _parsesvyopt `svy2'
        if _rc {
            di as err "invalid svy() option"
            exit 198
        }
        capt _parsesvysubpop `svy_subpop'
        if _rc {
            di as err "invalid subpop() option"
            exit 198
        }
        //=> svy `svy_type', subpop(`svy_subpop') `svy_opts': ...
    }
    local cons
    if `: list posof "_cons" in coefs' {
        local cons "_cons"
    }
    local xvars: list coefs - cons
    if "`cons'"!="" {
        tempname xcons
        qui gen byte `xcons' = 1
        local xvars: list xvars | xcons
    }
    if `suest' {
        tempname grpvar
        gen byte `grpvar'= 0
        qui replace `grpvar' = 1 if `subpop1'
        capt assert (`grpvar'==0) if `subpop2'
        if _rc {
            error "overlapping samples (groups not distinct)"
            exit 498
        }
        qui replace `grpvar' = 2 if `subpop2'
        if "`svy'"=="" {
            `qui' mean `xvars' if `touse' [`weight'`exp'], ///
                over(`grpvar') `vce' `cluster'
            if e(N_clust)<. {
                local e_N_clust = e(N_clust)
                local e_clustvar "`e(clustvar)'"
            }
        }
        else {
            `qui' svy `svy_type', ///
                subpop(`svy_subpop' & (`subpop1' | `subpop2')) `svy_opts' : ///
                    mean `xvars' if `touse', over(`grpvar')
            local e_prefix "`e(prefix)'"
            local e_N_strata = e(N_strata)
            local e_N_psu = e(N_psu)
            local e_N_pop = e(N_pop)
            local e_df_r = e(df_r)
        }
        if "`e(vce)'"!="analytic" {
            local e_vce     "`e(vce)'"
            local e_vcetype "`e(vcetype)'"
        }
        local e_wtype "`e(wtype)'"
        local e_wexp `"`e(wexp)'"'
        mat `x' = e(b)
        mat `Vx' = e(V)
        local N1 = el(e(_N),1,1)
        local N2 = el(e(_N),1,2)
        if "`cons'"!="" {
            local coleq: coleq `x'
            local coleq: subinstr local coleq "`xcons'" "_cons", word all
            mat coleq `x' = `coleq'
            mat coleq `Vx' = `coleq'
            mat roweq `Vx' = `coleq'
        }
        mata: oaxaca_reorderxandVx()
    }
    else {
        tempname xtmp Vxtmp
        local tmp
        forv i = 1/2 {
            if "`svy'"=="" {
                `qui' mean `xvars' if `touse' & `touse`i'' [`weight'`exp'], `vce' `cluster'
            }
            else {
                `qui' svy `svy_type', subpop(`svy_subpop' & `subpop`i'') `svy_opts' : ///
                    mean `xvars' if `touse' & `touse`i''
            }
            mat `x`tmp'' = e(b)
            local N`i' = el(e(_N),1,1)
            local e_wtype "`e(wtype)'"
            local e_wexp `"`e(wexp)'"'
            if "`cons'"!="" {
                local coln: colnames `x`tmp''
                local coln: subinstr local coln "`xcons'" "_cons", word
                mat coln `x`tmp'' = `coln'
            }
            mat coleq `x`tmp'' = "x`i'"
            if `se' {
                mat `Vx`tmp'' = e(V)
                if "`cons'"!="" {
                    mat coln `Vx`tmp'' = `coln'
                    mat rown `Vx`tmp'' = `coln'
                }
                mat coleq `Vx`tmp'' = "x`i'"
                mat roweq `Vx`tmp'' = "x`i'"
            }
            local tmp tmp
        }
        mat `x' = `x', `xtmp'
        mat drop `xtmp'
        if `se' {
            MatAppendDiag `Vx' `Vxtmp'
            mat drop `Vxtmp'
        }
    }
    if `"`x1'`x2'"'!="" {
        _setXvals `x' `Vx', se(`se') `x1' `x2'
    }
    mat `b' = `b', `x'
    mat drop `x'
    if `se' {
        if "`fixed'"!="" {
            mat `Vx' = `Vx'*0
        }
        else if `"`fixed2'"'!=""{
            local fixedx
            foreach var of local fixed2 {
                capt unab temp: `var'
                if _rc {
                    local temp "`var'"
                }
                local temp: list temp & coefs
                if `"`temp'"'=="" {
                    di as err `"`var' not found"'
                    exit 111
                }
                local fixedx: list fixedx | temp
            }
            if `"`fixedx'"'!="" {
                mata: oaxaca_setfixedXtozero(0)
            }
        }
        MatAppendDiag `V' `Vx'
        mat drop `Vx'
    }

// post b and V for use with nlcom
    if `se' {
        eret post `b' `V'
        _eretpostcmd
        tempname V0
        mat `V0' = e(V)
    }
    else {
        eret post `b'
    }
    tempname b0
    mat `b0' = e(b)

// parse adjust() => returns locals adjust and coefsadj
    _parseadjust, `adjust' coefs(`coefs')

// parse detail2() option => returns local cgroups
    _parsedetail2, `detail2' coefs(`coefsadj')

    if "`nlcom'"!="" {
    // nlcom step 1: detailed decomposition
        local terms1
        local terms2
        local terms3
        if "`threefold'"!="" {
            local 1 1
            local 2 2
            if "`threefold2'"!="" {
                local 1 2
                local 2 1
            }
            local i 0
            foreach coef of local coefsadj {
                local ++i
                local term1`i' (E_`coef':([x1]_b[`coef']-[x2]_b[`coef'])*[b`2']_b[`coef'])
                local terms1 `"`macval(terms1)' \`term1`i''"'
                local term2`i' (C_`coef':[x`2']_b[`coef']*([b1]_b[`coef']-[b2]_b[`coef']))
                local terms2 `"`macval(terms2)' \`term2`i''"'
                local term3`i' (I_`coef':([x1]_b[`coef']-[x2]_b[`coef'])*([b`1']_b[`coef']-[b`2']_b[`coef']))
                local terms3 `"`macval(terms3)' \`term3`i''"'
            }
            local eqnames "E_ C_ I_"
        }
        else {
            if "`reference'"!="" {
                local i 0
                foreach coef of local coefsadj {
                    local ++i
                    local term1`i' (E_`coef':([x1]_b[`coef']-[x2]_b[`coef'])*[b_ref]_b[`coef'])
                    local terms1 `"`macval(terms1)' \`term1`i''"'
                    if "`split'"=="" {
                        local term2`i' (U_`coef':[x1]_b[`coef']*([b1]_b[`coef']-[b_ref]_b[`coef']) ///
                                    + [x2]_b[`coef']*([b_ref]_b[`coef']-[b2]_b[`coef']))
                        local terms2 `"`macval(terms2)' \`term2`i''"'
                    }
                    else {
                        local term2`i' (U1_`coef':[x1]_b[`coef']*([b1]_b[`coef']-[b_ref]_b[`coef']))
                        local term3`i' (U2_`coef':[x2]_b[`coef']*([b_ref]_b[`coef']-[b2]_b[`coef']))
                        local terms2 `"`macval(terms2)' \`term2`i''"'
                        local terms3 `"`macval(terms3)' \`term3`i''"'
                    }
                }
            }
            else {  // => weights()
                local i 0
                local wgt
                foreach coef of local coefsadj {
                    if `"`wgt'"'=="" { // => recycle
                        local wgt "`weights'"
                    }
                    gettoken w wgt : wgt
                    local m = 1 - `w'
                    local ++i
                    local term1`i' (E_`coef':([x1]_b[`coef']-[x2]_b[`coef']) * ///
                                (`w'*[b1]_b[`coef']+`m'*[b2]_b[`coef']))
                    local terms1 `"`macval(terms1)' \`term1`i''"'
                    if "`split'"=="" {
                        local term2`i' (U_`coef':[x1]_b[`coef']*(`m'*[b1]_b[`coef']-`m'*[b2]_b[`coef']) ///
                                        + [x2]_b[`coef']*(`w'*[b1]_b[`coef']-`w'*[b2]_b[`coef']))
                        local terms2 `"`macval(terms2)' \`term2`i''"'
                    }
                    else {
                        local term2`i' (U1_`coef':[x1]_b[`coef']*(`m'*[b1]_b[`coef']-`m'*[b2]_b[`coef']))
                        local term3`i' (U2_`coef':[x2]_b[`coef']*(`w'*[b1]_b[`coef']-`w'*[b2]_b[`coef']))
                        local terms2 `"`macval(terms2)' \`term2`i''"'
                        local terms3 `"`macval(terms3)' \`term3`i''"'
                    }
                }
            }
            if "`split'"=="" {
                local eqnames "E_ U_"
            }
            else {
                local eqnames "E_ U1_ U2_"
            }
        }
        local plus
        local xb1
        local xb2
        foreach coef of local coefs {
            local xb1 `xb1'`plus'[x1]_b[`coef']*[b1]_b[`coef']
            local xb2 `xb2'`plus'[x2]_b[`coef']*[b2]_b[`coef']
            local plus "+"
        }
        local xb1 (D_xb1:`xb1')
        local xb2 (D_xb2:`xb2')
        local plus
        local adj
        foreach coef of local adjust {
            local adj `adj'`plus'[x1]_b[`coef']*[b1]_b[`coef']-[x2]_b[`coef']*[b2]_b[`coef']
            local plus "+"
        }
        if `"`adj'"'!="" {
            local adj (D_adj:`adj')
        }
        if `se' {
            quietly nlcom `xb1' `xb2' `adj' `terms1' `terms2' `terms3', post
        }
        else {
            nlcom_nose `xb1' `xb2' `adj' `terms1' `terms2' `terms3'
            mat `b' = r(b)
            eret post `b'
        }

    // nlcom step 2: totals
        local terms1
        local terms2
        local terms3
        local j 0
        foreach eq of local eqnames {
            local ++j
            local i 0
            local term`j'tot
            local plus
            foreach group of local cgroups {
                local ++i
                local term`j'`i'
                local plusplus
                gettoken gname gcoefs : group
                if `"`gcoefs'"'=="" {
                    local gcoefs `"`gname'"'
                }
                foreach coef of local gcoefs {
                    local term`j'tot `term`j'tot'`plus'_b[`eq'`coef']
                    local plus "+"
                    if "`coef'"=="_cons" & inlist("`eq'","E_","I_") continue
                    if "`detail'"!="" {
                        local term`j'`i' `term`j'`i''`plusplus'_b[`eq'`coef']
                        local plusplus "+"
                    }
                }
                if `"`term`j'`i''"'!="" {
                    local term`j'`i' (`eq'`gname':`term`j'`i'')
                    local terms`j' `"`macval(terms`j')' \`term`j'`i''"'
                }
            }
            if "`detail'"!="" {
                local term`j'tot (`eq'Total:`term`j'tot')
            }
            else {
                local term`j'tot (`eq':`term`j'tot')
            }
            local terms`j' `"`macval(terms`j')' \`term`j'tot'"'
        }
        if `"`adj'"'!="" {
            local adj (D_Adjusted:_b[D_xb1]-_b[D_xb2]-_b[D_adj])
        }
        if `se' {
            quietly nlcom (D_Prediction_1:_b[D_xb1]) (D_Prediction_2:_b[D_xb2]) ///
                (D_Difference:_b[D_xb1]-_b[D_xb2]) `adj' ///
                `terms1' `terms2' `terms3'
            mat `b' = r(b)
            mat `V' = r(V)
        }
        else {
            nlcom_nose (D_Prediction_1:_b[D_xb1]) (D_Prediction_2:_b[D_xb2]) ///
                (D_Difference:_b[D_xb1]-_b[D_xb2]) `adj' ///
                `terms1' `terms2' `terms3'
            mat `b' = r(b)
        }
    }
    else {
        mata: oaxaca_decomp()
    }

// post results
    local coln: coln `b'
    local coln `" `coln'"'
    local coln: subinstr local coln " D_" " Differential:", all
    local eqcolon = cond("`detail'"!="",":","")
    local eqname = cond("`detail'"!="","","Decomposition:")
    if "`threefold'"!="" {
        local coln: subinstr local coln " E_" " `eqname'Endowments`eqcolon'", all
        local coln: subinstr local coln " C_" " `eqname'Coefficients`eqcolon'", all
        local coln: subinstr local coln " I_" " `eqname'Interaction`eqcolon'", all
    }
    else {
        local coln: subinstr local coln " E_" " `eqname'Explained`eqcolon'", all
        if "`split'"=="" {
            local coln: subinstr local coln " U_" " `eqname'Unexplained`eqcolon'", all
        }
        else {
            local coln: subinstr local coln " U1_" " `eqname'Unexplained_1`eqcolon'", all
            local coln: subinstr local coln " U2_" " `eqname'Unexplained_2`eqcolon'", all
        }
    }
    mat coln `b' = `coln'
    if `se' {
        mat coln `V' = `coln'
        mat rown `V' = `coln'
    }
    if "`threefold'"!="" local model threefold `threefold2'
    else                 local model twofold `split'
    if "`reference'"!="" local refcoefs "b_ref"
    if `"`detail2'"'!="" {
        local dlegend
        local space
        foreach cgroup of local cgroups {
            if `:list sizeof cgroup'>1 {
                gettoken name vars : cgroup
                local dlegend `"`dlegend'`space'"`name':`vars'""'
                local space " "
            }
        }
    }
    PostResults `b' `V', b0(`b0') v0(`V0') `depname' esample(`touse') ///
        suest(`suest') model(`model') weights(`weights') ///
        refcoefs(`refcoefs') detail(`detail') legend(`dlegend') ///
        adjust(`adjust') fixed(`fixedx') ///
        n1(`N1') n2(`N2') wtype(`e_wtype') wexp(`e_wexp') ///
        vce(`e_vce') vcetype(`e_vcetype') n_clust(`e_N_clust') ///
        clustvar(`e_clustvar') prefix(`e_prefix') n_strata(`e_N_strata') ///
        n_psu(`e_N_psu') n_pop(`e_N_pop') df_r(`e_df_r')

// display
    if "`display'"=="" {
        Display, `level' `eform' `xb' `legend'
    }

// cleanup
    _est unhold `hcurrent', not
end

prog _parse_elist
    syntax namelist(name=elist min=2 max=2)
    if "`:word 1 of `elist''"=="`:word 2 of `elist''" {
        di as err "namelist:  too few specified"
        exit 102
    }
    c_local elist "`elist'"
end

prog Display, eclass
    syntax [, level(passthru) eform xb noLEgend ]
    if !inlist("`e(cmd)'","_oaxaca9","oaxaca9") {
        error 301
    }
    if "`eform'"!="" {
        local eform "eform(exp(b))"
        tempname b
        mat `b' = e(b)
        local coln: colnames `b'
        local newcoln: subinstr local coln "_cons" "__cons", word count(local cons)
        if `cons' {
            mat coln `b' = `newcoln'
            ereturn repost b = `b', rename
        }
    }
    _coef_table_header
    eret display, `level' `eform'
    if "`eform'"!="" {
        if `cons' {
            mat `b' = e(b)
            mat coln `b' = `coln'
            ereturn repost b = `b', rename
        }
    }
    if "`legend'"=="" {
        Display_legend
    }
    if `"`xb'"'!="" {
        Display_b0, `level'
    }
end

prog Display_legend
    if `"`e(legend)'"'=="" exit
    foreach line in `e(legend)' {
        local i 0
        local piece: piece `++i' 78 of `"`line'"'
        di as txt `"`piece'"'
        while (1) {
            local piece: piece `++i' 76 of `"`line'"'
            if `"`piece'"'=="" continue, break
            di as txt `"  `piece'"'
        }
    }
end

prog Display_b0
    syntax [, Level(passthru)]
    tempname hcurrent b
    mat `b' = e(b0)
    mat `V' = e(V0)
    capt confirm matrix e(V0)
    if _rc==0 {
        tempname V
        mat `V' = e(V0)
    }
    _est hold `hcurrent', restore estsystem
    di _n "Coefficients (b) and means (x)"
    eret post `b' `V'
    eret display, `level'
end

prog _marksubpop
    syntax [varname(default=none)] [if], g(name)
    marksample touse
    if "`varlist'"!="" {
        qui replace `touse' = 0 if `varlist'==0
    }
    rename `touse' `g'
end

prog ExtractFirstEqs
    args eqlab b V
    local i 0
    foreach nm in `e(names)' {
        local ++i
        local suffix: word 1 of `e(eqnames`i')'
        if `"`suffix'"'!="_" {
            local nm `"`nm'_`suffix'"'
        }
        local oldeqs `"`oldeqs'`space'`nm'"'
        local neweqs `"`neweqs'`space'`:word `i' of `eqlab''"'
        local space " "
    }
    mata: oaxaca_extracteqs()
end

prog MatAppendDiag
    args A D
    tempname B C
    mat `B' = J(rowsof(`A'),colsof(`D'),0)
    mat coln `B' = `:colfullnames `D''
    mat `C' = J(rowsof(`D'),colsof(`A'),0)
    mat rown `C' = `:rowfullnames `D''
    mat `A' = (`A', `B') \ (`C', `D')
end

program _parsesvyopt
    syntax [anything] [, SUBpop(str asis) * ]

    c_local svy_type `"`anything'"'
    c_local svy_opts    `"`options'"'
    c_local svy_subpop  `"`subpop'"'
end

program _vce_iscluster
    syntax [anything] [, * ]
    local vce_type: word 1 of `anything'
    local iscluster 0
    if `"`vce_type'"'==substr("cluster",1,max(2,strlen(`"`vce_type'"'))) local iscluster 1
    c_local vce_iscluster `iscluster'
end

program _parsesvysubpop
    syntax [varname(default=none)] [if/]
    if `"`if'"'!="" {
        local iff `"(`if') & "'
    }
    c_local svy_subpop `"`varlist' if `iff'1"'
end

program define _devcon
// based on devcon.ado from SSC, version 1.0.9 06dec2005, by Ben Jann
    version 9.2
    syntax anything, Groups(passthru) [ check(str) ]
    gettoken b: anything

    mat `b' = `b''
    local eqs: roweq `b', quoted
    local eqs: list uniq eqs
    local mlbls `""model 1" "model 2" "pooled model""'
    foreach eq of local eqs {
        gettoken mlbl mlbls : mlbls
        gettoken chk check : check
        if `"`chk'"'!="" {
            local chk check(`chk')
        }
        __devcon `anything', `groups' eq(`eq':) eqs(`eqs') label(`mlbl') `chk'
    }
    mat `b' = `b''
end

program define __devcon, eclass
// based on devcon.ado from SSC, version 1.0.9 06dec2005, by Ben Jann
    syntax anything, Groups(string) [ eq(str asis) eqs(str asis) label(str) check(str) ]
    gettoken b V: anything
    gettoken V : V
    local hasV = (`"`V'"'!="")
    if `"`label'"'!="" {
        local label `" in `label'"'
    }
    if `"`check'"'!=""  tempvar rsum

// get coef names
    tempname btmp
    mat `btmp' = `b'[`"`eq'"',1]
    local vars: rownames `btmp'
    local rest `vars'

// parse groups
    gettoken 1 groups : groups, parse(",")
    while `"`1'"'!="" {
        local set `"`1'"'
        gettoken 1 cons : 1, parse("(")
        if "`cons'"!="" {
            unab cons: `cons'
        }
        if "`cons'"=="" local cons _cons
        if !`:list cons in vars' {
            di as error `"categorical(): `set'"'
            di as error `"`cons' not found`label'"'
            exit 111
        }
        unab 1: `1'
        local keep `1'
        local notinmodel: list 1 - vars
        local ref: word 1 of `notinmodel'
        local notinmodel: list notinmodel - ref
        if "`ref'"=="" {
            di as error `"categorical(): `set'"'
            di as error "no base category indicator found"
            exit 111
        }
        local 1: list vars & 1
        if "`1'"=="" {
            di as error `"categorical(): `set'"'
            di as error "set not found`label'"
            exit 111
        }
        if "`notinmodel'"!="" {
            di as txt `"(categorical(): ambiguous set`label': `set')"'
            di as txt `"(using '`ref'' as base category indicator; dropping '`notinmodel'')"'
        }
        if !`:list 1 in rest' {
            di as error "categorical(): sets must be distinct"
            exit 198
        }
        local rest: list rest - 1
        local 1: list 1 | ref
        local 1: list keep & 1
        local gvars `"`gvars'"`1'" "'
        if `:list ref in refs' {
            di as error "categorical(): sets must be distinct"
            exit 198
        }
        else local refs "`refs'`ref' "
        local conss "`conss'`cons' "
        if `"`check'"'!="" {
            if "`cons'"=="_cons" local cons 1
            qui gen double `rsum' = 0 if `check'
            foreach v of local 1 {
                qui replace `rsum' = `rsum' + `v' if `check'
            }
            capt assert reldif(`rsum',`cons') < 1e-10 if `check'
            if _rc {
                di as error `"categorical(): `set'"'
                di as error `"sum unequal `cons' for one or more observations`label'"'
                exit 499
            }
            drop `rsum'
        }
        gettoken 1 groups : groups, parse(",")
        gettoken 1 groups : groups, parse(",")
    }

// determine order of coefficients
    local var: word 1 of `vars'
    while "`var'"!="" {
        if `:list var in rest' {
            local master `"`master'`"`eq'`var'"' "'
            local vars: list vars - var
        }
        else {
            foreach gvar of local gvars {
                if `:list var in gvar' {
                    foreach temp of local gvar {
                        local master `"`master'`"`eq'`temp'"' "'
                    }
                    local vars: list vars - gvar
                    continue, break
                }
            }
        }
        local var: word 1 of `vars'
    }

// normalize coefficients and compute (co-)variances
    tempname I Icons Vtmp Z
    local g 0
    foreach vars of local gvars {
        local ref: word `++g' of `refs'
        local cons: word `g' of `conss'
        local k: word count `vars'
    // - prepare indicator vector
        mat `I' = `b' * 0
        foreach var of local vars {
            if "`var'"!="`ref'" {
                mat `I'[rownumb(`I',`"`eq'`var'"'),1] = 1
            }
        }
        mat `Icons' = `I'
        mat `Icons'[rownumb(`Icons',`"`eq'`cons'"'),1] = -1
    // - transform coefficients vector
        mat `btmp' = `I'' * `b' / `k'
        mat rown `btmp' = `"`eq'`ref'"'
        mat `b' = `b' - `Icons' * `btmp' \ -`btmp'
        if `hasV' {
        // - add ref cat to V
            mat `Vtmp' = ( `I'' * `V' / `k' )
            mat rown `Vtmp' = `"`eq'`ref'"'
            mat `V' = ( `V' \ -`Vtmp' ) , ( ( -`Vtmp'' \ `Vtmp' * `I' / `k' ))
        // - update indicator vectors and transform V
            mat `I' = `I' \ `btmp'*0
            mat `Icons' = `Icons' \ `btmp'*0
            mat `Vtmp' = ( `I'' * `V' / `k' )
            mat `V' = `V' - `Icons' * `Vtmp' - `Vtmp'' * `Icons'' ///
            + `Vtmp' * `I' / `k' * `Icons' * `Icons''
            mat drop `Vtmp'
        }
        mat drop `btmp'
    }

// reorder b and V
    foreach eqi of local eqs {
        if `"`eqi':"'==`"`eq'"' {
            foreach var of local master {
                mat `btmp' = nullmat(`btmp') \ `b'[`"`var'"',1]
            }
        }
        else {
            mat `btmp' = nullmat(`btmp') \ `b'[`"`eqi':"',1]
        }
    }
    mat `b' = `btmp'
    mat drop `btmp'
    if `hasV' {
        foreach eqi of local eqs {
            if `"`eqi':"'==`"`eq'"' {
                foreach var of local master {
                    mat `Vtmp' = nullmat(`Vtmp') \ `V'[`"`var'"',1...]
                }
            }
            else {
                mat `Vtmp' = nullmat(`Vtmp') \ `V'[`"`eqi':"',1...]
            }
        }
        mat `V' = `Vtmp'
        mat drop `Vtmp'
        foreach eqi of local eqs {
            if `"`eqi':"'==`"`eq'"' {
                foreach var of local master {
                    mat `Vtmp' = nullmat(`Vtmp') , `V'[1...,`"`var'"']
                }
            }
            else {
                mat `Vtmp' = nullmat(`Vtmp') , `V'[1...,`"`eqi':"']
            }
        }
        mat `V' = `Vtmp'
        mat drop `Vtmp'
    }
end

prog _setXvals
    syntax anything, se(str) [ x1(str) x2(str) ]
    gettoken x Vx : anything
    gettoken Vx : Vx
    tempname tmp
    local fixedx
    forv i = 1/2 {
        if `"`x`i''"'=="" continue
        mat `tmp' = `x'[1,"x`i':"]
        local coefs: colnames `tmp'
        while (1) {
            if `"`x`i''"'=="" continue, break
            gettoken var x`i' : x`i', parse(" =,")
            if `"`var'"'=="," {
                gettoken var x`i' : x`i', parse(" =")
            }
            gettoken val x`i' : x`i', parse(" =,")
            if `"`val'"'=="=" {
                gettoken val x`i' : x`i', parse(" ,")
            }
            capt confirm number `val'
            if _rc | `"`var'"'=="" {
                di as err "invalid x`i'() option"
                exit 198
            }
            capt unab trash : `var'
            if _rc {
                local trash `"`var'"'
            }
            local vars: list coefs & trash
            if `"`vars'"'=="" {
                di as err `"x`i'(): `var' not found"'
                exit 111
            }
            local coefs: list coefs - vars
            foreach v of local vars {
                mat `x'[1,colnumb(`x',`"x`i':`v'"')] = `val'
                local fixedx `"`fixedx' `"x`i':`v'"'"'
            }
        }
    }
    if `se' {
        mata: oaxaca_setfixedXtozero(1)
    }
end

program _eretpostcmd, eclass
    eret local cmd "_oaxaca9"
end

program _parsedetail2
    syntax [, Detail2(str) coefs(str) ]
    local rest "`coefs'"
    while (1) {
        if `"`detail2'"'=="" continue, break
        gettoken group detail2 : detail2, parse(",")
        gettoken gname vars : group, parse("=:")
        gettoken trash vars: vars, parse("=:")
        if `"`gname'"'=="" | `"`vars'"'=="" {
            di as err "invalid detail() option"
            exit 198
        }
        local gvars
        foreach var of local vars {
            capt unab trash: `var'
            if _rc local trash `"`var'"'
            local svar: list rest & trash
            if "`svar'"=="" {
                di as err `"`var' not found"'
                exit 111
            }
            else {
                local rest: list rest - svar
            }
            local gvars: list gvars | svar
        }
        local groups `"`groups' "`gname' `gvars'""'
        gettoken group detail2 : detail2, parse(",") // get rid of leading comma
    }
    local cgroups
    while (1) {
        if `"`coefs'"'=="" continue, break
        gettoken coef coefs : coefs
        if `:list coef in rest' {
            local cgroups `"`cgroups' "`coef'""'
        }
        else {
            foreach group in `groups' {
                gettoken name vars : group
                if `:list coef in vars' {
                    local group `""`group'""'
                    local cgroups `"`cgroups' `group'"'
                    local groups: list groups - group
                    local coefs: list coefs - vars
                    continue, break
                }
            }
        }
    }
    c_local cgroups `"`cgroups'"'
end

program _parseadjust
    syntax [, adjust(str) coefs(str) ]
    foreach var of local adjust {
        capt unab trash: `var'
        if _rc local trash `"`var'"'
        local svar: list coefs & trash
        if "`svar'"=="" {
            di as err `"`var' not found"'
            exit 111
        }
        else {
            local coefs: list coefs - svar
        }
        local vars: list vars | svar
    }
    c_local adjust `"`vars'"'
    c_local coefsadj  `"`coefs'"'
end

program nlcom_nose, rclass
    gettoken term rest : 0, match(paren)
    tempname b
    while (1) {
        if `"`term'"'=="" continue, break
        gettoken name exp : term, parse(":")
        gettoken trash exp : exp, parse(":")
        mat `b' = nullmat(`b'), (`exp')
        local coln `"`coln' `"`name'"'"'
        gettoken term rest : rest, match(paren)
    }
    mat coln `b' = `coln'
    ret mat b = `b'
end

program PostResults, eclass
    syntax anything,  b0(str) esample(str) suest(str) [ ///
        depname(str) model(str) weights(str) refcoefs(str) ///
        detail(str) legend(str asis) adjust(str) fixed(str) ///
        v0(str) n1(str) n2(str) ///
        wtype(str) wexp(str asis) vce(str) vcetype(str) ///
        n_clust(str) clustvar(str) prefix(str) n_strata(str) ///
        n_psu(str) n_pop(str) df_r(str)  ]
    qui count if `esample'
    if `"`depname'"'!="" {
        local depvar `"`depname'"'
        local depname `"depname(`depname')"'
    }
    eret post `anything', esample(`esample') obs(`r(N)') `depname'
    foreach opt in prefix clustvar vcetype vce wexp wtype  {
        eret local `opt' `"``opt''"'
    }
    if `suest' eret local suest suest
    foreach opt in fixed adjust legend detail refcoefs weights model depvar {
        eret local `opt' `"``opt''"'
    }
    eret local title "Blinder-Oaxaca decomposition"
    eret local cmd "_oaxaca9"
    if "`n1'`n2'"!="" {
        eret scalar N_1 = `n1'
        eret scalar N_2 = `n2'
    }
    foreach opt in N_clust N_strata N_psu N_pop df_r {
        local optt = lower("`opt'")
        if `"``optt''"'!="" {
            eret scalar `opt' = ``optt''
        }
    }
    eret mat b0 = `b0'
    if "`v0'"!="" {
        eret mat V0 = `v0'
    }
end

version 9.2
mata:

void oaxaca_extracteqs()
{
    b = st_matrix(st_local("b"))
    V = st_matrix(st_local("V"))
    old = tokens(st_local("oldeqs"))
    newi = tokens(st_local("neweqs"))
    stripe = st_matrixcolstripe(st_local("b"))
    r = 0
    j = 1
    match = 0
    for (i=1; i<=rows(stripe); i++) {
        if (stripe[i,1]==old[j]) {
            r++
            match = 1
        }
        else if (match) {
            j++
            i--
            match = 0
        }
        if (j>length(old)) break
    }
    p = J(r,1,.)
    r = 0
    j = 1
    for (i=1; i<=rows(stripe); i++) {
        if (stripe[i,1]==old[j]) {
            p[++r] = i
            match = 1
            stripe[i,1] = newi[j]
        }
        else if (match) {
            j++
            i--
            match = 0
        }
        if (j>length(old)) break
    }
    b = b[,p]
    V = V[p,p]
    stripe = stripe[p,]
    st_matrix(st_local("b"), b)
    st_matrixcolstripe(st_local("b"), stripe)
    st_matrix(st_local("V"), V)
    st_matrixcolstripe(st_local("V"), stripe)
    st_matrixrowstripe(st_local("V"), stripe)
}

void oaxaca_insertmissingcoefs()
{
    b = st_matrix(st_local("b"))
    stripe = st_matrixcolstripe(st_local("b"))
    coefs = select(stripe[,2],(stripe[,1]:=="b1"))
    coefs2 = select(stripe[,2],(stripe[,1]:=="b2"))
    r = 0
    for (i=1; i<=length(coefs2); i++) {
        if (anyof(coefs, coefs2[i])==0) r++
    }
    if (r>0) {
        p = J(r,1,.)
        r = 0
        for (i=1; i<=length(coefs2); i++) {
            if (anyof(coefs, coefs2[i])==0) p[++r] = i
        }
        coefs = coefs \ coefs2[p]
    }
    if (anyof(coefs,"_cons") & !allof(coefs,"_cons")) {
        coefs = select(coefs,coefs:!="_cons") \ "_cons"
    }
    ncoef = length(coefs)
    neq = 2 + (stripe[rows(stripe),1]=="b_ref")
    r = 0
    for (j=1; j<=neq; j++) {
        eq = ("b1", "b2", "b_ref")[j]
        for (i=1; i<=ncoef; i++) {
            r = r + (length(oaxaca_which(stripe[,1]:==eq :& stripe[,2]:==coefs[i]))>0)
        }
    }
    p = J(r,1,.)
    r = 1
    p0 = (1::neq*ncoef)
    for (j=1; j<=neq; j++) {
        eq = ("b1", "b2", "b_ref")[j]
        for (i=1; i<=ncoef; i++) {
            tmp = oaxaca_which(stripe[,1]:==eq :& stripe[,2]:==coefs[i])
            if (length(tmp)>0) {
                p[r++] = tmp[1]
            }
            else p0[(j-1)*ncoef+i] = .
        }
    }
    p0 = select(p0, p0:!=.)
    bnew = J(1,neq*ncoef,0)
    bnew[p0] = b[p]
    stripenew = (J(ncoef,1,"b1"),coefs) \ (J(ncoef,1,"b2"),coefs)
    if (neq==3)  stripenew = (stripenew) \ (J(ncoef,1,"b_ref"),coefs)
    st_matrix(st_local("b"), bnew)
    st_matrixcolstripe(st_local("b"), stripenew)
    st_local("coefs",oaxaca_invtokens(coefs))
    if (st_local("se")=="1") {
        V = st_matrix(st_local("V"))
        Vnew = J(rows(V),neq*ncoef,0)
        Vnew[,p0] = V[,p]
        V = J(neq*ncoef,neq*ncoef,0)
        V[p0,] = Vnew[p,]
        st_matrix(st_local("V"), V)
        st_matrixcolstripe(st_local("V"), stripenew)
        st_matrixrowstripe(st_local("V"), stripenew)
    }
}

void oaxaca_reorderxandVx()
{
    b = st_matrix(st_local("x"))
    coefs = st_matrixcolstripe(st_local("x")) //tokens(st_local("coefs"))'
    k = length(b)
    p = range(1, k-1, 2) \ range(2, k, 2)
    b = b[p]
    stripe = ("x":+coefs[p,2]), coefs[p,1] //(J(length(coefs),1,"x1"),coefs) \ (J(length(coefs),1,"x2"),coefs)
    st_matrix(st_local("x"), b)
    st_matrixcolstripe(st_local("x"), stripe)
    if (st_local("se")=="1") {
        V = st_matrix(st_local("Vx"))
        V = V[p,p]
        st_matrix(st_local("Vx"), V)
        st_matrixcolstripe(st_local("Vx"), stripe)
        st_matrixrowstripe(st_local("Vx"), stripe)
    }
}

void oaxaca_setfixedXtozero(real scalar eq)
{
    V = st_matrix(st_local("Vx"))
    fixed = tokens(st_local("fixedx"))'
    if (eq) {
        stripe = st_matrixcolstripe(st_local("Vx"))
        stripe = stripe[,1] :+ ":" :+ stripe[,2]
    }
    else stripe = st_matrixcolstripe(st_local("Vx"))[,2]
    r = 0
    for (i=1;i<=length(fixed);i++) {
        r = r + length(oaxaca_which(stripe:==fixed[i]))
    }
    p = J(r,1,.)
    r = 1
    for (i=1;i<=length(fixed);i++) {
        tmp = oaxaca_which(stripe:==fixed[i])
        p[|r \ r+length(tmp)-1|] = tmp
        r = r + length(tmp)
    }
    V[p,] = V[p,]*0
    V[,p] = V[,p]*0
    st_replacematrix(st_local("Vx"),V)
}

void oaxaca_decomp()
{
    se      = (st_local("se")=="1")
    tf      = (st_local("threefold")!="")
    tfr     = (st_local("threefold2")!="")
    ref     = (st_local("reference")!="")
    wgt     = strtoreal(tokens(st_local("weights")))
    split   = (st_local("split")!="")
    detail  = (st_local("detail")!="")
    cgroups = tokens(st_local("cgroups"))
    ngrp    = length(cgroups)
    adjust  = tokens(st_local("adjust"))
    adjyes  = length(adjust)>0
    b       = st_matrix("e(b)")
    stripe  = st_matrixcolstripe("e(b)")
    if (se) V = st_matrix("e(V)")
    ncoefs  = 0
    for (i=1; i<=ngrp; i++) {
        ncoefs  = ncoefs + max(((length(tokens(cgroups[i]))-1),1))
    }
    if (length(wgt)>0) { // expand wgt (recycle)
        w = J(1,ncoefs,.)
        for (i=1; i<=ncoefs; i=i+length(wgt)) {
            r = i + length(wgt) - 1
            if (r<=ncoefs)  w[|i \ r|] = wgt
            else            w[|i \ ncoefs|] = wgt[|1 \ i-ncoefs+1|]
        }
        m = 1:-w
    }
    b1 = x1 = b2 = x2 = p = J(1,ncoefs,.)
    G = J(ncoefs,ngrp,0)
    grpnms  = J(1,ngrp,"")
    k = 0
    for (i=1; i<=ngrp; i++) {
        grp = tokens(cgroups[i])
        if (length(grp)==1) grp = grp, grp
        grpnms[i] = grp[1]
        for (j=2; j<=length(grp); j++) { // skip first
            coef = grp[j]
            k++
            b1[k] = oaxaca_which(stripe[,1]:=="b1":&stripe[,2]:==coef)
            x1[k] = oaxaca_which(stripe[,1]:=="x1":&stripe[,2]:==coef)
            b2[k] = oaxaca_which(stripe[,1]:=="b2":&stripe[,2]:==coef)
            x2[k] = oaxaca_which(stripe[,1]:=="x2":&stripe[,2]:==coef)
            if (ref) p[k] = oaxaca_which(stripe[,1]:=="b_ref":&stripe[,2]:==coef)
            G[k,i] = 1
        }
    }
    coln = "D_Prediction_1", "D_Prediction_2", "D_Difference"
    if (length(adjust)>0) {
        b1a = x1a = b2a = x2a = J(1,length(adjust),.)
        for (i=1; i<=length(adjust); i++) {
            coef = adjust[i]
            b1a[i] = oaxaca_which(stripe[,1]:=="b1":&stripe[,2]:==coef)
            x1a[i] = oaxaca_which(stripe[,1]:=="x1":&stripe[,2]:==coef)
            b2a[i] = oaxaca_which(stripe[,1]:=="b2":&stripe[,2]:==coef)
            x2a[i] = oaxaca_which(stripe[,1]:=="x2":&stripe[,2]:==coef)
        }
        res =
            b[(x1,x1a)]*b[(b1,b1a)]',
            b[(x2,x2a)]*b[(b2,b2a)]',
            b[(x1,x1a)]*b[(b1,b1a)]' - b[(x2,x2a)]*b[(b2,b2a)]',
            b[x1]*b[b1]' - b[x2]*b[b2]'
        coln = coln, "D_Adjusted"
        if (se) {
            D = J(4, length(b), 0)
            D[1,(b1,b1a,x1,x1a)] = b[(x1,x1a,b1,b1a)]
            D[2,(b2,b2a,x2,x2a)] = b[(x2,x2a,b2,b2a)]
            D[3,(b1,b1a,x1,x1a,b2,b2a,x2,x2a)] = b[(x1,x1a,b1,b1a)], -b[(x2,x2a,b2,b2a)]
            D[4,(b1,x1,b2,x2)] = b[(x1,b1)], -b[(x2,b2)]
        }
    }
    else {
        res =
            b[x1]*b[b1]',
            b[x2]*b[b2]',
            b[x1]*b[b1]' - b[x2]*b[b2]'
        if (se) {
            D = J(3, length(b), 0)
            D[1,(b1,x1)] = b[(x1,b1)]
            D[2,(b2,x2)] = b[(x2,b2)]
            D[3,(b1,x1,b2,x2)] = b[(x1,b1)], -b[(x2,b2)]
        }
    }
    if (se) j = rows(D)
    if (tfr) { // threefold reverse
        if (detail) {
            res = res,
                ((b[x1]-b[x2]) :* b[b1]) * G,           (b[x1]-b[x2])*b[b1]',
                (b[x1] :* (b[b1]-b[b2])) * G,           b[x1]*(b[b1]-b[b2])',
                ((b[x1]-b[x2]) :* (b[b2]-b[b1])) * G,   (b[x1]-b[x2])*(b[b2]-b[b1])'
            coln = coln, "E_":+grpnms, "E_Total", "C_":+grpnms, "C_Total",
                "I_":+grpnms, "I_Total"
            if (se) {
                D = D \ J(3*(ngrp+1), length(b), 0)
                D[++j::j+ngrp-1,(x1,x2,b1)] = G'*diag(b[b1]),G'*diag(-b[b1]),G'*diag(b[x1]-b[x2])
                D[j=j+ngrp,(x1,x2,b1)] = b[b1], -b[b1], b[x1]-b[x2]
                D[++j::j+ngrp-1,(x1,b1,b2)] = G'*diag(b[b1]-b[b2]), G'*diag(b[x1]), G'*diag(-b[x1])
                D[j=j+ngrp,(x1,b1,b2)] = b[b1]-b[b2], b[x1], -b[x1]
                D[++j::j+ngrp-1,(x1,x2,b1,b2)] = G'*diag(b[b2]-b[b1]), G'*diag(b[b1]-b[b2]),
                    G'*diag(b[x2]-b[x1]), G'*diag(b[x1]-b[x2])
                D[j=j+ngrp,(x1,x2,b1,b2)] = b[b2]-b[b1], b[b1]-b[b2], b[x2]-b[x1], b[x1]-b[x2]
            }
        }
        else {
            res = res,
                (b[x1]-b[x2])*b[b1]',
                b[x1]*(b[b1]-b[b2])',
                (b[x1]-b[x2])*(b[b2]-b[b1])'
            coln = coln, "E_", "C_", "I_"
            if (se) {
                D = D \ J(3, length(b), 0)
                D[++j,(x1,x2,b1)] = b[b1], -b[b1], b[x1]-b[x2]
                D[++j,(x1,b1,b2)] = b[b1]-b[b2], b[x1], -b[x1]
                D[++j,(x1,x2,b1,b2)] = b[b2]-b[b1], b[b1]-b[b2], b[x2]-b[x1], b[x1]-b[x2]
            }
        }
    }
    else if (tf) { // threefold
        if (detail) {
            res = res,
                ((b[x1]-b[x2]) :* b[b2]) * G,           (b[x1]-b[x2])*b[b2]',
                (b[x2] :* (b[b1]-b[b2])) * G,           b[x2]*(b[b1]-b[b2])',
                ((b[x1]-b[x2]) :* (b[b1]-b[b2])) * G,   (b[x1]-b[x2])*(b[b1]-b[b2])'
            coln = coln, "E_":+grpnms, "E_Total", "C_":+grpnms, "C_Total",
                "I_":+grpnms, "I_Total"
            if (se) {
                D = D \ J(3*(ngrp+1), length(b), 0)
                D[++j::j+ngrp-1,(x1,x2,b2)] = G'*diag(b[b2]),G'*diag(-b[b2]),G'*diag(b[x1]-b[x2])
                D[j=j+ngrp,(x1,x2,b2)] = b[b2], -b[b2], b[x1]-b[x2]
                D[++j::j+ngrp-1,(x2,b1,b2)] = G'*diag(b[b1]-b[b2]), G'*diag(b[x2]), G'*diag(-b[x2])
                D[j=j+ngrp,(x2,b1,b2)] = b[b1]-b[b2], b[x2], -b[x2]
                D[++j::j+ngrp-1,(x1,x2,b1,b2)] = G'*diag(b[b1]-b[b2]), G'*diag(b[b2]-b[b1]),
                    G'*diag(b[x1]-b[x2]), G'*diag(b[x2]-b[x1])
                D[j=j+ngrp,(x1,x2,b1,b2)] = b[b1]-b[b2], b[b2]-b[b1], b[x1]-b[x2], b[x2]-b[x1]
            }
        }
        else {
            res = res,
                (b[x1]-b[x2])*b[b2]',
                b[x2]*(b[b1]-b[b2])',
                (b[x1]-b[x2])*(b[b1]-b[b2])'
            coln = coln, "E_", "C_", "I_"
            if (se) {
                D = D \ J(3, length(b), 0)
                D[++j,(x1,x2,b2)] = b[b2], -b[b2], b[x1]-b[x2]
                D[++j,(x2,b1,b2)] = b[b1]-b[b2], b[x2], -b[x2]
                D[++j,(x1,x2,b1,b2)] = b[b1]-b[b2], b[b2]-b[b1], b[x1]-b[x2], b[x2]-b[x1]
            }
        }
    }
    else if (ref) { // reference coefs
        if (detail) {
            res = res,
                ((b[x1]-b[x2]) :* b[p]) * G, (b[x1]-b[x2])*b[p]',
                (split ? (b[x1] :* (b[b1]-b[p])) * G, b[x1] * (b[b1]-b[p])',
                         (b[x2] :* (b[p]-b[b2])) * G, b[x2] * (b[p]-b[b2])'
                       : (b[x1] :* (b[b1]-b[p]) + b[x2] :* (b[p]-b[b2])) * G,
                         b[x1] * (b[b1]-b[p])' + b[x2] * (b[p]-b[b2])'
                       )
            coln = coln, "E_":+grpnms, "E_Total", (split ?
                ("U1_":+grpnms, "U1_Total", "U2_":+grpnms, "U2_Total")
                : ("U_":+grpnms, "U_Total"))
            if (se) {
                D = D \ J((2+split)*(ngrp+1), length(b), 0)
                D[++j::j+ngrp-1,(x1,x2,p)] = G'*diag(b[p]), G'*diag(-b[p]), G'*diag(b[x1]-b[x2])
                D[j=j+ngrp,(x1,x2,p)] = b[p], -b[p], b[x1]-b[x2]
                if (split) {
                    D[++j::j+ngrp-1,(x1,b1,p)] = G'*diag(b[b1]-b[p]), G'*diag(b[x1]), G'*diag(-b[x1])
                    D[j=j+ngrp,(x1,b1,p)] = b[b1]-b[p], b[x1], -b[x1]
                    D[++j::j+ngrp-1,(x2,p,b2)] = G'*diag(b[p]-b[b2]), G'*diag(b[x2]), G'*diag(-b[x2])
                    D[j=j+ngrp,(x2,p,b2)] = b[p]-b[b2], b[x2], -b[x2]
                }
                else {
                    D[++j::j+ngrp-1,(x1,x2,b1,b2,p)] = G'*diag(b[b1]-b[p]), G'*diag(b[p]-b[b2]),
                        G'*diag(b[x1]), G'*diag(-b[x2]), G'*diag(b[x2]-b[x1])
                    D[j=j+ngrp,(x1,x2,b1,b2,p)] = b[b1]-b[p], b[p]-b[b2], b[x1], -b[x2], b[x2]-b[x1]
                }
            }
        }
        else {
            res = res,
                (b[x1]-b[x2])*b[p]',
                (split ? b[x1] * (b[b1]-b[p])', b[x2] * (b[p]-b[b2])'
                       : b[x1] * (b[b1]-b[p])' + b[x2] * (b[p]-b[b2])'
                       )
            coln = coln, "E_", (split ? ("U1_", "U2_") : "U_")
            if (se) {
                D = D \ J(2+split, length(b), 0)
                D[++j,(x1,x2,p)] = b[p], -b[p], b[x1]-b[x2]
                if (split) {
                    D[++j,(x1,b1,p)] = b[b1]-b[p], b[x1], -b[x1]
                    D[++j,(x2,p,b2)] = b[p]-b[b2], b[x2], -b[x2]
                }
                else {
                    D[++j,(x1,x2,b1,b2,p)] = b[b1]-b[p], b[p]-b[b2], b[x1], -b[x2], b[x2]-b[x1]
                }
            }
        }
    }
    else /*if length(wgt)>0*/ { // weights
        if (detail) {
            res = res,
                ((b[x1]-b[x2]) :* (w:*b[b1]+m:*b[b2])) * G,
                    (b[x1]-b[x2]) * (w:*b[b1]+m:*b[b2])',
                (split ? (b[x1] :* (m:*b[b1]-m:*b[b2])) * G, b[x1] * (m:*b[b1]-m:*b[b2])',
                         (b[x2] :* (w:*b[b1]-w:*b[b2])) * G, b[x2] * (w:*b[b1]-w:*b[b2])'
                       : (b[x1] :* (m:*b[b1]-m:*b[b2]) + b[x2] :* (w:*b[b1]-w:*b[b2])) * G,
                         b[x1] * (m:*b[b1]-m:*b[b2])' + b[x2] * (w:*b[b1]-w:*b[b2])'
                       )
            coln = coln, "E_":+grpnms, "E_Total", (split ?
                ("U1_":+grpnms, "U1_Total", "U2_":+grpnms, "U2_Total")
                : ("U_":+grpnms, "U_Total"))
            if (se) {
                D = D \ J((2+split)*(ngrp+1), length(b), 0)
                D[++j::j+ngrp-1,(x1,x2,b1,b2)] =
                    G'*diag(w:*b[b1]+m:*b[b2]), G'*diag(-w:*b[b1]-m:*b[b2]),
                    G'*diag(w:*b[x1]-w:*b[x2]), G'*diag(m:*b[x1]-m:*b[x2])
                D[j=j+ngrp,(x1,x2,b1,b2)] = w:*b[b1]+m:*b[b2], -w:*b[b1]-m:*b[b2],
                    w:*b[x1]-w:*b[x2], m:*b[x1]-m:*b[x2]
                if (split) {
                    D[++j::j+ngrp-1,(x1,b1,b2)] = G'*diag(m:*b[b1]-m:*b[b2]), G'*diag(m:*b[x1]),
                        G'*diag(-m:*b[x1])
                    D[j=j+ngrp,(x1,b1,b2)] = m:*b[b1]-m:*b[b2], m:*b[x1], -m:*b[x1]
                    D[++j::j+ngrp-1,(x2,b1,b2)] = G'*diag(w:*b[b1]-w:*b[b2]), G'*diag(w:*b[x2]),
                        G'*diag(-w:*b[x2])
                    D[j=j+ngrp,(x2,b1,b2)] = w:*b[b1]-w:*b[b2], w:*b[x2], -w:*b[x2]
                }
                else {
                    D[++j::j+ngrp-1,(x1,x2,b1,b2)] =
                        G'*diag(m:*b[b1]-m:*b[b2]), G'*diag(w:*b[b1]-w:*b[b2]),
                        G'*diag(m:*b[x1]+w:*b[x2]), G'*diag(-m:*b[x1]-w:*b[x2])
                    D[j=j+ngrp,(x1,x2,b1,b2)] = m:*b[b1]-m:*b[b2], w:*b[b1]-w:*b[b2],
                        m:*b[x1]+w:*b[x2], -m:*b[x1]-w:*b[x2]
                }
            }
        }
        else {
            res = res,
                (b[x1]-b[x2]) * (w:*b[b1]+m:*b[b2])',
                (split ? b[x1] * (m:*b[b1]-m:*b[b2])', b[x2] * (w:*b[b1]-w:*b[b2])'
                       : b[x1] * (m:*b[b1]-m:*b[b2])' + b[x2] * (w:*b[b1]-w:*b[b2])'
                       )
            coln = coln, "E_", (split ? ("U1_", "U2_") : "U_")
            if (se) {
                D = D \ J(2+split, length(b), 0)
                D[++j,(x1,x2,b1,b2)] = w:*b[b1]+m:*b[b2], -w:*b[b1]-m:*b[b2],
                    w:*b[x1]-w:*b[x2], m:*b[x1]-m:*b[x2]
                if (split) {
                    D[++j,(x1,b1,b2)] = m:*b[b1]-m:*b[b2], m:*b[x1], -m:*b[x1]
                    D[++j,(x2,b1,b2)] = w:*b[b1]-w:*b[b2], w:*b[x2], -w:*b[x2]
                }
                else {
                    D[++j,(x1,x2,b1,b2)] = m:*b[b1]-m:*b[b2], w:*b[b1]-w:*b[b2],
                        m:*b[x1]+w:*b[x2], -m:*b[x1]-w:*b[x2]
                }
            }
        }
    }
    if (se) {
        V = D*V*D'
    }
    stripe = J(length(coln),1,""), coln'
    if (detail) {
        notcons = (stripe[,2]:!="E__cons":&stripe[,2]:!="I__cons")
        res = select(res, notcons')
        stripe = select(stripe, notcons)
    }
    st_matrix(st_local("b"), res)
    st_matrixcolstripe(st_local("b"), stripe)
    if (se) {
        if (detail) V = select(select(V, notcons'), notcons)
        st_matrix(st_local("V"),V)
        st_matrixrowstripe(st_local("V"),stripe)
        st_matrixcolstripe(st_local("V"),stripe)
    }
}

string scalar oaxaca_invtokens(string vector In)
{
    string scalar Out
    real scalar i

    Out = ""
    for (i=1; i<=length(In); i++) {
        Out = Out + (i>1 ? " " : "") + In[i]
    }
    return(Out)
}

real matrix oaxaca_which(real vector I)
{
        if (cols(I)!=1) return(select(1..cols(I), I))
        else return(select(1::rows(I), I))
}

end
