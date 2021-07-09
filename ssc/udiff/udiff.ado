*! version 1.1.9  16nov2019  Ben Jann & Simon Seiler

program udiff, eclass byable(recall) properties(svyb svyj svyr mi)
    version 11
    if replay() {
        if "`e(cmd)'" != "udiff" error 301
        Display `0'
        exit
    }
    local version : di "version " string(_caller()) ":"
    `version' _vce_parserun udiff : `0'
    if "`s(exit)'" != "" {
        ereturn local cmdline `"udiff `0'"'
        exit
    }
    Estimate `0'
    ereturn local cmdline `"udiff `0'"'
end

program Estimate, eclass
    // syntax
        syntax [anything] [if] [in] [fw iw pw aw] [, ///
            /// model
            Baseoutcome(passthru)                    ///
            noConstant                               ///
            CFonly                                   ///
            /// estimation
            vce(passthru)                            ///
            CLuster(passthru) Robust                 ///
            CONSTRaints(numlist int <=1 <=1999)      ///
            from(str)                                ///
            lfado                           /// undocumented; for certification
            /// display
            NOIsily noLOg noHeader                   ///
            ALLequations eform                       ///
            *                                        ///
            ]
    if "`lfado'"=="" local lfspec lf2 udiff_lf2()
    else             local lfspec lf  udiff_lf
    if "`noisily'"=="" local quietly quietly
    ParseVarlist `anything' // returns depvar, controls, xvars, xvars#, layer#, layers, nunidiff
    local vceopt =  `:length local vce'      | ///
                    `:length local weight'   | ///
                    `:length local cluster'  | ///
                    `:length local robust'
    if `vceopt' {
        _vce_parse, argopt(CLuster) opt(OIM OPG Robust) old     ///
            : [`weight'`exp'], `vce' `robust' `cluster'
        local vce
        if "`r(cluster)'" != "" {
            local clustvar `r(cluster)'
            local vce vce(cluster `r(cluster)')
        }
        else if "`r(robust)'" != "" {
            local vce vce(robust)
        }
        else if "`r(vce)'" != "" {
            local vce vce(`r(vce)')
        }
    }
    _get_diopts diopts options, `options'
    local diopts `diopts' `header'
    mlopts mlopts, `options' `vce'
    if "`weight'" != "" {
       local wgt "[`weight'`exp']" 
    }
    
    // mark sample
    marksample touse
    markout `touse' `depvar' `xvars' `layers' `controls' `clustvar'
    
    // check depvar
    capt assert (`depvar'==abs(int(`depvar'))) if `touse'
    if _rc {
        di as err "{it:depvar} may not contain negative or noninteger values"
        exit 498
    }
    
    // collect information on outcomes and check for collinearity
    // - expand factor variables (so that terms can be matched after _rmcoll)
    local xvars
    local layers
    forv i=1/`nunidiff' {
        local XVARS`i' `xvars`i''
        fvexpand `xvars`i'' if `touse'
        local xvars`i' `r(varlist)'
        local xvars `xvars' `r(varlist)'
        local LAYER`i' `layer`i''
        fvexpand `layer`i'' if `touse'
        local layer`i' `r(varlist)'
        local layer`i': list uniq layer`i'
        local layers: list layers | layer`i'
    }
    if `"`controls'"'!="" {
        local CONTROLS `controls'
        fvexpand `controls' if `touse'
        local controls `r(varlist)'
    }
    local vlist `depvar' `xvars' `layers' `controls'
    local vlist0: list uniq vlist
    if `: list sizeof vlist'!=`: list sizeof vlist0' {
        di as err "inconsistent list of variables; depvar, xvars, and controls" ///
            " must be unique; layervars must not contain depvar, xvars, or controls"
        exit 198
    }
    // - run _rmcoll
    _rmcoll `vlist' `wgt' if `touse', `constant' noskipline mlogit `baseoutcome' expand
    // - get coefficients and ll of empty model
    if `"`from'"'=="" & "`constant'"=="" {
        tempname b0
        matrix `b0' = r(b0)
        local ll_0 = r(ll_0)
    }
    // - rebuild variable lists
    local vlist `r(varlist)'
    local xvars
    gettoken depvar vlist : vlist
    forv j=1/`nunidiff' {
        local n: list sizeof xvars`j'
        local xvars`j'
        forv i=1/`n' {
            gettoken term vlist : vlist
            local xvars`j' `xvars`j'' `term'
            local xvars `xvars' `term'
        }
    }
    local vlist0 `layers'
    local layers
    local n: list sizeof vlist0
    forv i=1/`n' {
        gettoken term0 vlist0 : vlist0
        gettoken term vlist : vlist
        local layers `layers' `term'
        if "`term'"!="`term0'" {
            forv j=1/`nunidiff' {
                local layer`j': subinstr local layer`j' "`term0'" "`term'", word
            }
        }
    }
    local n: list sizeof controls
    local controls
    forv i=1/`n' {
        gettoken term vlist : vlist
        local controls `controls' `term'
    }
    // - process info on outcomes
    tempname OUT
    matrix `OUT' = r(out)
    local nout = r(k_out)
    if (`nout' == 1) error 148
    local ibase = r(ibaseout)
    local baseout = r(baseout)
    local out
    forval i = 1/`nout' {
        local val = `OUT'[1,`i']
        local out `out' `val'
    }
    local out_labels
    if "`: val lab `depvar''"!="" {
        forval i = 1/`nout' {
            local val: word `i' of `out'
            local lbl: lab (`depvar') `val', strict
            local out_labels `"`out_labels'`"`lbl'"' "'
        }
        local out_labels: list clean out_labels
    }

    // put equations together
    local Phi "Phi"
    local Psi "Psi"
    local Theta "Theta"
    local eqnames
    if "`cfonly'"=="" {
        local thedepvar "`depvar'="
        forv j=1/`nunidiff' {
            if (`nunidiff'==1) local term `Phi'
            else               local term `Phi'`j'
            local phi `phi' (`term': `thedepvar'`layer`j'', nocons)
            local thedepvar
            local eqnames `eqnames' `term'
        }
    }
    local thedepvar "`depvar'="
    forv j=1/`nunidiff' {
        if (`nunidiff'==1) local term `Psi'
        else               local term `Psi'`j'
        forval i = 1/`nout' {
            if `i' == `ibase' continue
            local val: word `i' of `out'
            local psi0 `psi0' (`term'_`val': `thedepvar'`xvars`j'', nocons)
            local thedepvar
            local psi `psi' (`term'_`val': `xvars`j'', nocons)
            local eqnames `eqnames' `term'_`val'
        }
    }
    if "`cfonly'"!="" {
        local psi `psi0'
    }
    forval i = 1/`nout' {
        if `i' == `ibase' continue
        local val: word `i' of `out'
        local theta `theta' (`Theta'_`val': `layers' `controls', `constant')
        local thetalist `thetalist' `Theta'_`val'
    }
    local eqnames `eqnames' `thetalist'
    
    // starting values (constant fluidity model)
    if `"`from'"'!="" {
        local initopt init(`from')
    }
    else if "`cfonly'"!="" {
        mat coleq `b0' = `thetalist'
        local initopt init(`b0') 
        if !missing(`ll_0') {
            local initopt `initopt' lf0(`=`nout'-1' `ll_0')
        }
    }
    else {
        if "`noisily'"!="" di as txt _n "Constant-fluidity model"
        else if "`log'"=="" di as txt _n "fitting constant fluidity model ..." _c
        if "`b0'"!="" {
            mat coleq `b0' = `thetalist'
            local initopt init(`b0') 
            if !missing(`ll_0') {
                local initopt `initopt' lf0(`=`nout'-1' `ll_0')
            }
        }
        nobreak {
            global UDIFF_mtype    0
            global UDIFF_nout     `nout'
            global UDIFF_out      `out'
            global UDIFF_ibase    `ibase'
            global UDIFF_nunidiff `nunidiff'
            capture noisily `quietly' break ///
                ml model `lfspec' `psi0' `theta' if `touse' `wgt', ///
                   `initopt' `mlopts' `log' search(off) collinear ///
                    constraints(`constraints') maximize missing
            global UDIFF_mtype
            global UDIFF_nout
            global UDIFF_out
            global UDIFF_ibase
            global UDIFF_nunidiff
            if _rc exit _rc
        }
        if "`noisily'"!="" ml display
        else if "`log'"=="" di as txt " done"
        local initopt continue
    }
    
    // estimate unidiff model
    nobreak {
        global UDIFF_mtype    = ("`cfonly'"=="")
        global UDIFF_nout     `nout'
        global UDIFF_out      `out'
        global UDIFF_ibase    `ibase'
        global UDIFF_nunidiff `nunidiff'
        capture noisily break ///
            ml model `lfspec' `phi' `psi' `theta' if `touse' `wgt', ///
                `initopt' `mlopts' `log' search(off) collinear ///
                constraints(`constraints') maximize missing
        global UDIFF_mtype
        global UDIFF_nout
        global UDIFF_out
        global UDIFF_ibase
        global UDIFF_nunidiff
        if _rc exit _rc
    }

    // returns
    eret scalar k_eform    = e(k_eq)
    eret scalar ibaseout   = `ibase'
    eret scalar k_out      = `nout'
    eret scalar k_unidiff  = `nunidiff'
    eret local predict    "udiff_p"
    eret local cmd        "udiff"
    eret local estat_cmd  "udiff_estat"
    eret local out        "`out'"
    eret local baseout    "`baseout'"
    eret local out_labels `"`out_labels'"'
    eret local eqnames    `"`eqnames'"'
    eret local controlvars   `"`CONTROLS'"'
    forv j=1/`nunidiff' {
        if `nunidiff'==1 {
            eret local layervars `"`LAYER`j''"'
            eret local xvars     `"`XVARS`j''"'
        }
        else {
            eret local layervars`j' `"`LAYER`j''"'
            eret local xvars`j'     `"`XVARS`j''"'
        }
    }
    eret local cfonly     "`cfonly'"
    if "`cfonly'"!="" {
        eret local title  "Constant-fluidity model"
    }
    else {
        eret local title  "Unidiff model"
    }

    // display
    Display, `diopts' `eform' `allequations'
end

program ParseVarlist
    gettoken depvar vlist : 0, parse(" (")
    if `"`depvar'"'=="" {
        di as err "{it:depvar} required"
        exit 198
    }
    _fv_check_depvar `depvar'
    c_local depvar `depvar'
    local k 0
    while (`"`vlist'"'!="") {
        gettoken term : vlist, match(par) bind
        if `"`par'"'=="(" { // term is "(...)"
            gettoken term vlist : vlist, match(par) bind
        }
        else {
            if `k'>0 {  // controlvars
                local 0 `"`vlist'"'
                capt n syntax varlist(numeric fv)
                if _rc {
                    di as err "invalid specification of {it:controlvars}"
                    exit 198
                }
                local controls `varlist'
                continue, break
            }
            mata: st_local("term", strtrim(st_local("vlist")))
            local vlist
        }
        local ++k
        mata: parse_udiffterm(st_local("term"))
        local 0 `"`x'"'
        capt n syntax varlist(numeric fv)
        if _rc {
            di as err "invalid specification of unidiff terms"
            exit 198
        }
        c_local xvars`k' `varlist'
        local xvars `xvars' `varlist'
        local 0 `"`layer'"'
        capt n syntax varlist(numeric fv)
        if _rc {
            di as err "invalid specification of unidiff terms"
            exit 198
        }
        c_local layer`k' `varlist'
        local layers `layers' `varlist'
    }
    if `k'==0 {
        di as err "must specify at least one unidiff term"
        exit 198
    }
    c_local controls `controls'
    c_local layers   `layers'
    c_local xvars    `xvars'
    c_local nunidiff `k'
end

program Display
    syntax [, ALLequations noHeader * ]
    local cfonly `"`e(cfonly)'"'
    if "`cfonly'"!="" local allequations allequations
    if "`allequations'"=="" local first neq(`e(k_unidiff)')
    if "`header'"=="" {
        _coef_table_header
        if "`allequations'"!="" {
            local lbls `"`e(out_labels)'"'
            if `:list sizeof lbls' {
                local out "`e(out)'"
                local depvar "`e(depvar)'"
                di as txt ""
                foreach o of local out {
                    gettoken lbl lbls : lbls
                    di as txt %13s "`o'" ": `depvar' = " as res `"`lbl'"'
                }
            }
        }
        else if `"`cfonly'"'=="" {
            di ""
            local nunidiff = e(k_unidiff)
            if `nunidiff'==1 {
                Display_truncate_exp `": `e(layervars)' -> `e(xvars)'"'
                di as txt %13s "Phi" `"`exp'"'
            }
            else if `nunidiff'>1 & `nunidiff'<. {
                forv i = 1/`nunidiff' {
                    Display_truncate_exp `": `e(layervars`i')' -> `e(xvars`i')'"'
                    di as txt %13s "Phi`i'" `"`exp'"'
                }
            }
            local controls `"`e(controlvars)'"'
            if `"`controls'"'!="" {
                Display_truncate_exp `": `controls'"'
                di as txt %13s "Controls" `"`exp'"'
            }
        }
    }
    di ""
    ml display, noheader `first' `options'
end

program Display_truncate_exp
    args exp
    local linesize = max(78, c(linesize))
    if strlen(`"`exp'"')>(`linesize'-13) {
        local exp: piece 1 `=`linesize'-17' of `"`exp'"'
        local exp `"`exp' ..."'
    }
    c_local exp `"`exp'"'
end

version 11
mata:
mata set matastrict on

void parse_udiffterm(string scalar term)
{
    real scalar      n
    string scalar    arrow, x, layer
    string rowvector terms
    
    arrow = "<-"
    if ((n = strpos(term, arrow))) {
        x     = strtrim(substr(term, 1, n-1))
        layer = strtrim(substr(term, n+2, .))
    }
    else {
        arrow = "->"
        if ((n = strpos(term, arrow))) {
            x     = strtrim(substr(term, n+2, .))
            layer = strtrim(substr(term, 1, n-1))
        }
        else {
            terms = strtrim(tokens(term))
            terms = select(terms, terms:!="")
            if (length(terms)>=2) {
                x     = invtokens(terms[|1 \ length(terms)-1|])
                layer = terms[length(terms)]
            }
            else {
                x = layer = ""
            }
        }
    }
    if (strlen(layer)==0) {
        display("{err}invalid unidiff term; {it:layervar} required")
        exit(198)
    }
    if (strlen(x)==0) {
        display("{err}invalid unidiff term; {it:xvars} required")
        exit(198)
    }
    st_local("x"    , x)
    st_local("layer", layer)
}

end
