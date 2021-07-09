*! version 4.0.3 07jan2020 daniel klein
program mimrgns
    version 11.2
    nobreak {
        tempname er rr
        version `= _caller()' : mimrgns_init `er' `rr' 
        capture noisily break _mimrgns `0'
        local Rc = _rc
        mimrgns_done `Rc'
        exit `Rc'
    }
end

// -------------------------------------- main
program _mimrgns
    if (replay()) {
        mimrgns_replay `0'
        `exit'
    }
    mimrgns_parse `0'
    mimrgns_mi_est
    mimrgns_return
    mimrgns_report
end

// -------------------------------------- replay
program mimrgns_replay
    if ("`e(cmd_mimrgns)'"!="mimrgns") {
        if ("`r(cmd_mimrgns)'"!="mimrgns") exit
        local NOESTIMATE NOESTIMATE
    }
    else local NOESTIMATE [ NOESTIMATE ]
    
    capture syntax , CMDMARGINS `NOESTIMATE'
    local setcmd = (!_rc)
    
    if (("`e(cmd_mimrgns)'"!="mimrgns")&(!`setcmd')) exit
    
    c_local exit exit

    if (`setcmd') {
        global mimrgns__is_post = ("`e(cmd_mimrgns)'"=="mimrgns")
        mimrgns_setcmdmargins
        exit
    }
    
    syntax [ , * ]
    
    global mimrgns__is_replay    = replay()
    global mimrgns__is_contrast  = ("`e(cmd)'"=="contrast")
    global mimrgns__is_pwcompare = ("`e(cmd)'"=="pwcompare")
    
    mimrgns_get_reporting , `options'
    if (${mimrgns__is_contrast}|${mimrgns__is_pwcompare}) {
        mimrgns_get_contr_pwcomp_sub , `options'
    }
    else if (`"`options'"'!="") {
        local 0 , options `options'
        syntax  , OPTIONS
        // NotReached
    }
    
    mata : st_rclear()
    _return hold ${mimrgns__rr}
    
    mimrgns_at_varies
    mimrgns_report
end

// -------------------------------------- parse caller input
program mimrgns_parse
    syntax [ anything(id = "marginlist") ] ///
    [ if ] [ in ]                          ///
    [ using/ ]                             ///
    [ fweight aweight pweight iweight ]    ///
    [ , * ]
    
    mimrgns_opts_not_allowed `using' , `options'
    
    if mi(`"`using'"') mimrgns_confirm_eresults
    else mimrgns_confirm_using `using' , `options'
    
    if (`"`anything'"'!="") {
        capture fvunab discard : `anything' , min(1)
            // fails for contrast operators
        global mimrgns__is_contrast = (!inlist(_rc, 0, 111))
    }
    
    mimrgns_get_pr_exp       , `options'
    mimrgns_get_contr_pwcomp , `options'
    mimrgns_get_reporting    , `options'
    mimrgns_get_options      , `options'
    
    if mi(`"`using'"') mimrgns_get_cmdline_mi
    
    if ("`weight'"!="") local weight [`weight' `exp']
    global mimrgns__cmdline_margins                        ///
    `anything' `if' `in' `weight' , post ${mimrgns__marg_opts}
    
    global mimrgns__mimrgns_cmdline : copy local 0
end

program mimrgns_opts_not_allowed
    syntax [ anything(id = "using" equalok everything) ] ///
    [ ,                                                  ///
        NOSE                                             ///
        SAVing(passthru)                                 ///
        ESAMPLE(passthru)                                ///
        CONTRast                                         ///
        CONTRast1(string asis)                           ///
        PWCOMPare                                        ///
        PWCOMPare1(string asis)                          ///
        *                                                ///
    ]
    
    if (`"`anything'"'!="") local ESAMPLE ESAMPLE(varname numeric)
    
    foreach opt in contrast pwcompare {
        if (c(stata_version)>=12)  local `opt' // void
        else if (`"``opt'1'"'!="") local `opt' `opt'(``opt'1')
    }
    
    local 0 , options `nose' `saving' `esample' `contrast' `pwcompare'
    syntax  , OPTIONS `ESAMPLE'
end

program mimrgns_confirm_eresults
    if      ("`e(mi)'"!="mi")                           error 301
    else if (inlist("`e(cmd)'", "margins", "mimrgns"))  error 301
    else if (inlist("`e(cmd2)'", "margins", "mimrgns")) error 301
end

program mimrgns_confirm_using
    syntax anything , ESAMPLE(varname numeric) [ * ]
    
    quietly estimates describe using `"`anything'"'
    capture estimates use `"`anything'"' , number(`r(nestresults)')
    if ((_rc)|("`e(mi)'"!="mi")) {
        display as err `"`anything': invalid estimation results"'
        exit 301
    }
    local mi_opts imputations(`e(m_mi)')
    if (e(esampvary_mi)==1) local mi_opts `mi_opts' esampvaryok
    
    global mimrgns__using   : copy local anything
    global mimrgns__esample : copy local esample
    global mimrgns__mi_opts : copy local mi_opts
    
    c_local options : copy local options
end

program mimrgns_get_pr_exp
    syntax                   ///
    [ ,                      ///
        PRedict(string asis) ///
        EXPression(passthru) ///
        *                    ///
    ]
    
    if (mi(`"`predict'`expression'"')) {
        display as txt "note: option predict() not " ///
                       "specified; predict(xb) assumed"
        local predict xb // mimrgns default
    }
    else if (`"`predict'"'!="") {
        if (`"`expression'"'!="") opts_exclusive `"`predict' `expression'"'
        if (`"`predict'"'=="default") local predict // void; margins default
    }
    
    if (`"`predict'"'!="") local predict predict(`predict')
    
    global mimrgns__marg_opts `predict' `expression'
    
    c_local options : copy local options
end

program mimrgns_get_contr_pwcomp
    syntax                      ///
    [ ,                         ///
        CONTRast                ///
        CONTRast1(string asis)  ///
        PWCOMPare               ///
        PWCOMPare1(string asis) ///
        *                       ///
    ]
    
    if (`"`contrast1'"'!="")  local contrast  contrast(`contrast1')
    if (`"`pwcompare1'"'!="") local pwcompare pwcompare(`pwcompare1')
    
    opts_exclusive `"`contrast' `pwcompare'"'
    if (${mimrgns__is_contrast}) {
        if (`"`pwcompare'"'!="") {
            display as err "option pwcompare " ///
            "is not allowd with contrast operators"
            exit 198
        }
        if mi(`"`contrast'"') local contrast contrast
    }
    else global mimrgns__is_contrast = (`"`contrast'"'!="")
    
    global mimrgns__is_pwcompare = (`"`pwcompare'"'!="")
    
    if (!(${mimrgns__is_contrast}|${mimrgns__is_pwcompare})) exit
    
    mimrgns_get_contr_pwcomp_sub , `contrast1' `pwcompare1'
    
    global mimrgns__marg_opts ${mimrgns__marg_opts} `contrast' `pwcompare'
    
    c_local options : copy local options
end

program mimrgns_get_contr_pwcomp_sub
    if (${mimrgns__is_contrast}) local ATcontrast ATcontrast(string)
    else if (${mimrgns__is_pwcompare}) {
        local CIMargins  CIMargins
        local GROUPs     GROUPs
        local SORT       SORT
    }
    else {
        display as err "unexpected error parsing options"
        exit 9
    }
    
    syntax           ///
    [ ,              ///
        CIeffects    ///
        PVeffects    ///
        EFFects      ///
        `ATcontrast' ///
        `CIMargins'  ///
        `GROUPs'     ///
        `SORT'       ///
    ]
    
    if (c(stata_version)>=13) {
        local _cionly nopvalues
        local _pvonly noci
    }
    else {
        local _cionly cionly
        local _pvonly pvonly
    }
    
    if ("`cieffects'"!="") local  cionly  `_cionly'
    if ("`pveffects'"!="") local  pvonly  `_pvonly'
    if ("`effects'"!="")   local  effects `""""' // sic!
    if ("`cimargins'"!="") global mimrgns__cimargins `_cionly'
    
    if mi(`"`cionly'`pvonly'`effects'`cimargins'"') local cionly `_cionly'
    
    global mimrgns__table_style `pvonly' `cionly' `effects'
    global mimrgns__table_opts  ${mimrgns__table_opts} `groups' `sort'
end

program mimrgns_get_reporting
    if (!${mimrgns__is_replay}) {
        local DOTS    DOTS
        local NOIsily NOIsily
        local POST    POST
        local VERBOSE VERBOSE
        local STAR    *
    }
    
    syntax                 ///
    [ ,                    ///
        Level(passthru)    ///
        MCOMPare(passthru) ///
        VSQUISH            ///
        CFORMAT(passthru)  ///
        PFORMAT(passthru)  ///
        SFORMAT(passthru)  ///
        NOLSTRETCH         ///
        COEFlegend         ///
        NOATLEGEND         ///
        EFORM              ///
        DFTABle            ///
        DIOPTS(string)     /// no longer documented
        CMDMARGINS         ///
        `DOTS'             ///
        `NOIsily'          ///
        `POST'             ///
        `VERBOSE'          ///
        `STAR'             ///
    ]
    
    opts_exclusive "`dots' `noisily'"
    
    local reporting_opts   ///
        `level'            ///
        `mcompare'         ///
        `vsquish'          ///
        `cformat'          ///
        `pformat'          ///
        `sformat'          ///
        `nolstretch'       ///
        `coeflegend'
    
    local table_opts       ///
        `reporting_opts'   ///
        `eform'            ///
        `dftable'          ///
        `diopts'
    
    global mimrgns__is_noatlegend = ("`noatlegend'"=="noatlegend")
    global mimrgns__is_post       = ("`post'"=="post")
    global mimrgns__is_verbose    = ("`verbose'"=="verbose")
    if ("`cmdmargins'"=="cmdmargins") global mimrgns__setcmd "margins"
    
    global mimrgns__mi_opts    ${mimrgns__mi_opts} `dots' `noisily' `trace'
    global mimrgns__marg_opts  ${mimrgns__marg_opts} `reporting_opts'
    global mimrgns__marg_opts  ${mimrgns__marg_opts} `noatlegend'
    global mimrgns__table_opts ${mimrgns__table_opts} `table_opts'
    
    c_local options : copy local options
end

program  mimrgns_get_options
    if mi(`"${mimrgns__using}"') {
        local ERROROK     ERROROK
        local ESAMPVARYOK ESAMPVARYOK
    }
    
    syntax                       ///
    [ ,                          ///
        NOSMALL                  ///
        `ERROROK'                ///
        `ESAMPVARYOK'            ///
        MIOPTS(string)           /// not documented
        SETTOLERANCE(real 1e-14) /// not documented
        *        /// margins options
    ]
    
    local mi_opts `nosmall' `errorok' `esampvaryok' `miopts'
    
    global mimrgns__mi_opts    ${mimrgns__mi_opts} `mi_opts'
    global mimrgns__is_nosmall = ("`nosmall'"=="nosmall")
    global mimrgns__tolerance  `settolerance'
    global mimrgns__marg_opts  ${mimrgns__marg_opts} `options'
end

// -------------------------------------- parse e(cmdline_mi)
program mimrgns_get_cmdline_mi
    _estimates unhold ${mimrgns__er}
    _estimates   hold ${mimrgns__er} , copy nullok
    
    local cmdline_mi `e(cmdline_mi)'
    
    gettoken mi       cmdline_mi : cmdline_mi
    gettoken estimate cmdline_mi : cmdline_mi
    gettoken mi_spec  cmdline_mi : cmdline_mi , parse(":") bind
    
    if   (`"`mi_spec'"'==":") local stripfrom mi_spec
    else                      local stripfrom cmdline_mi
    
    gettoken colon `stripfrom' : `stripfrom' , parse(":")
    
    if ((`"`mi' `estimate'"'!="mi estimate")|(`"`colon'"'!=":")) {
        display as err  "unexpected error parsing e(cmdline_mi)"
        exit 9
    }
        
    local 0 : copy local mi_spec
    syntax [ anything(equalok everything) ] ///
    [ ,                                     ///
        NImputations(passthru)              ///
        Imputations(passthru)               ///
        CMDOK                               ///
        *           /// strip any other options
    ]
    
    local mi_opts `nimputations' `imputations' `cmdok'
    
    global mimrgns__mi_opts ${mimrgns__mi_opts} `mi_opts'
    global mimrgns__cmdline : copy local cmdline_mi
end

// -------------------------------------- mi estimate
program mimrgns_mi_est
    ${mimrgns__version} : mi estimate , post noheader notable ///
        ${mimrgns__mi_opts} : mimrgns_estimate ${mimrgns__caller}
    
    mimrgns_at_varies
    
    if (!(${mimrgns__at_varies}    | ///
          ${mimrgns__is_contrast}  | ///
          ${mimrgns__is_pwcompare})) exit
    
    _return restore ${mimrgns__rr}
    if (${mimrgns__at_varies}) mata : mimrgns_combine_at()
    if (${mimrgns__is_contrast}|${mimrgns__is_pwcompare}) {
        mata : st_numscalar("e(N_mi)", min(st_matrix("r(_N)")))
        if (${mimrgns__is_pwcompare}) mata : mimrgns_combine_vs()
    }
    _return hold ${mimrgns__rr}
end

// -------------------------------------- return
program mimrgns_return
    _return restore ${mimrgns__rr}
    mata : mimrgns_return()
    _return hold ${mimrgns__rr}
end

// -------------------------------------- report
program mimrgns_report
    if ("`e(mi)'"!="mi") error 301
    
    if (`"`e(predict_label)'"'!="") local prlabel "`e(predict_label)', "
    local Legend `"{txt}Expression{col 14}: {res}`prlabel'`e(expression)'"'
    
    local margderiv `e(derivatives)'
    if ("`margderiv'"!="") {
        mimrgns_report_xvars xvars hasfv
        local Legend `"`Legend'"' _newline         ///
            `"{txt}`margderiv' w.r.t. : {res}`xvars'"'
        if (`hasfv') local Note display "{txt}Note: `margderiv' for " ///
        "factor levels is the discrete change from the base level." _newline
    }
    
    if inlist(e(k_predict), 1, .) local k_predict 0
    else                          local k_predict = e(k_predict)
    
    if ((${mimrgns__is_contrast})|(${mimrgns__is_pwcompare})) {
        local coeftitle  coeftitle("Contrast")
        local coeftitle2 coeftitle2(`margderiv')
        local quietly    quietly
    }
    else {
        if mi("`margderiv'") local coeftitle coeftitle("Margin")
        else                 local coeftitle coeftitle(`margderiv')
    }
    
    local coef_table_opts `coeftitle' `coeftitle2' ${mimrgns__table_opts}
    
    mi estimate , notable
    
    display _newline `"`Legend'"'
    forvalues i = 1/`k_predict' {
        display "{txt}`i'._predict{col 14}: {res} "        ///
        "`e(predict`i'_label)', predict(`e(predict`i'_opts)')"
    }
    
    if (("`e(at)'"=="matrix")&(!${mimrgns__is_noatlegend})) ///
        mimrgns_report_atlegend , ${mimrgns__table_opts}
    display // newline
    
    `quietly' _coef_table , `coef_table_opts'
    `quietly' `Note'
    
    if (c(stata_version)>=12) mimrgns_rtable r(table)
    
    if ((${mimrgns__is_contrast})|(${mimrgns__is_pwcompare})) ///
        mimrgns_report_contr_pwcomp , `coef_table_opts'
    
    if (${mimrgns__at_varies}) {
        display as txt "note: values in {cmd:at()} vary across imputations;"
        display as txt _col(7) "reported values are mi point estimates."
    }
end

program mimrgns_report_xvars
    args lmacname1 lmacname2
    
    local `lmacname2' 0
    
    local X `e(xvars)'
    foreach x of local X {
        _ms_parse_parts `x'
        if (r(omit)) continue
        if (!``lmacname2'') local `lmacname2' = ("`r(type)'"=="factor") 
        local `lmacname1' ``lmacname1'' `x'
    }
    
    if (c(stata_version)>=14) {
        local ud ud
        local u  u
    }
    
    if (`ud'strlen("``lmacname''")>78) ///
        local `lmacname' = `u'substr("``lmacname''", 1, 78) + "{txt}.."
    
    c_local `lmacname1' : copy local `lmacname1'
    c_local `lmacname2' : copy local `lmacname2'
end

// copied verbatim from StataCorp _marg_report.ado version 1.4.0 09may2017
                // change b<strfcn>() to <strfcn>(); add comments
program mimrgns_report_atlegend
    syntax [, vsquish * ] // allow any options
    tempname at
    matrix `at' = e(at)
    local k_by  = e(k_by)
    local hasby = `k_by' > 1
    local r     = rowsof(`at')
    local c     = colsof(`at')
    if `r' == `k_by' {
        local vsquish vsquish
    }
    if "`vsquish'" == "" {
        local di di
    }
    if `hasby' {
        local within `"`e(within)'"'
        local r    = `r'/`k_by'
        local ind "{space 4}"
    }
    local NLIST : colna `at'
    local row 0
    local oldname
    local flushbal 0
    if `r' == 1 {
        local title at
        local first 1
        local stats `"`e(atstats1)'"'
        local stats : list uniq stats
        local asstats asbalanced asobserved
        local stats : list stats - asstats
        if `:list sizeof stats' == 0 {
            local flushbal 1
        }
    }
    forval i = 1/`r' {
        if `r' > 1 {
            local title `i'._at
            local first 1
        }
        local SLIST `"`e(atstats`i')'"'
        local allasobs : list uniq SLIST
        local allasobs = "`allasobs'" == "asobserved"
        `di'
    forval g = 1/`k_by' {
        if `k_by' > 1 {
            local group `"{txt}`e(by`g')'"'
            if `first' {
                mimrgns_report_legend "`title'" "`group'"
            }
            else {
                mimrgns_report_legend "" "`group'"
            }
            local first 0
        }
        local ++row
        local nlist : copy local NLIST
        local slist : copy local SLIST
        forval j = 1/`c' {
            gettoken name nlist : nlist
            gettoken spec slist : slist, bind
            local factor 0
            local asbal = "`spec'" == "asbalanced"
            if `asbal' {
                local factor 1
            }
            else if !`allasobs' {
                if missing(`at'[`row',`j']) {
                    if `at'[`row',`j'] != .g {
                        continue
                    }
                }
            }
            _ms_parse_parts `name'
            if r(type) == "factor" {
                if `at'[`row',`j'] == 0 {
                    continue
                }
                else if `at'[`row',`j'] == 1 {
                    local factor 1
                }
                local name `r(level)'`r(ts_op)'.`r(name)'
            }
            if `factor' {
                _ms_parse_parts `name'
                local op `"`r(ts_op)'"'
                local val = r(level)
                if `:length local op' {
                    local name `"`op'.`r(name)'"'
                }
                else    local name `"`r(name)'"'
                if `asbal' {
                    if `:list name in within' {
                        local olname
                        continue
                    }
                    if `"`name'"' == "`olname'" {
                        continue
                    }
                }
            }
            else {
                local name = abbrev("`name'", 12)
            }
            local olname : copy local name
            local ss = 16 - strlen("`name'")
            if `ss' > 0 {
                local space "{space `ss'}"
            }
            else    local space
            if !`factor' {
                local val : display %9.0g `at'[`row',`j']
                local val : list retok val
            }
            if `asbal' {
                if `flushbal' {
                    local val
                }
                else {
                    local val "{space 12}"
                }
            }
            else {
                local len : length local val
                local ss = 11 - `len'
                if `ss' > 0 {
                    local val "{space `ss'}`val'"
                }
            }
            if `factor' & !`asbal' {
                local spec
            }
            if substr("`spec'",1,1) == "(" {
                gettoken val : spec, match(PAR)
            }
            else if !inlist(`"`spec'"',    "",    ///
                        "asobserved",    ///
                        "value",    ///
                        "values",    ///
                        "zero") {
                if !`hasby' {
                    if substr("`spec'",1,1) == "o" {
                    local spec = substr("`spec'",2,.)
                    }
                }
                local val `"`val' {txt:(`spec')}"'
            }
            if `allasobs' {
                local pair `"`ind'{txt:(asobserved)}"'
            }
            else if `asbal' {
                local pair ///
                    "`ind'{txt:`name'}`space'  `val'"
            }
            else {
                local pair ///
                    "`ind'{txt:`name'}`space'{txt:=} `val'"
            }
            if `first' {
                mimrgns_report_legend "`title'" `"`pair'"'
                local first 0
            }
            else {
                mimrgns_report_legend "" `"`pair'"'
            }
            if `allasobs' {
                continue, break
            }
        } // j
    } // g
    } // i
end

program mimrgns_report_legend
    args name value
    local len = strlen("`name'")
    local c2 = 14
    local c3 = 16
    di "{txt}{p2colset 1 `c2' `c3' 2}{...}"
    if `len' {
        di `"{p2col:`name'}:{space 1}{res:`value'}{p_end}"'
    }
    else {
        di `"{p2col: }{space 2}{res:`value'}{p_end}"'
    }
    di "{p2colreset}{...}"
end
// end code from StataCorp

program mimrgns_report_contr_pwcomp
    syntax [ , * ]
    
    if      (${mimrgns__is_contrast})  local coding coding
    else if (${mimrgns__is_pwcompare}) {
        local coding compare
        local vs_mats         ///
            bmat(e(b_vs))     ///
            vmat(e(V_vs))     ///
            mmat(e(b))        ///
            mvmat(e(V))       ///
            suffix(_vs)       ///
            dfmat(e(df_vs))   ///
            emat(e(error_vs))
    }
    
    if ("${mimrgns__cimargins}"!="") {
        _coef_table , `coding' `options' ${mimrgns__cimargins}
        `Note'
    }
    
    foreach style in ${mimrgns__table_style} {
        _coef_table , `coding' `options' `vs_mats' `style'
        `Note'
    }
    
    if (c(stata_version)<12) exit
    
    if (${mimrgns__is_pwcompare}) local _vs _vs
    mimrgns_rtable r(table`_vs')
end

// -------------------------------------- utility
program mimrgns_init
    args er rr
    
    mimrgns_init_assert_void globals
    mimrgns_init_assert_void matrices
    
    global mimrgns__version       version `= _caller()'
    global mimrgns__er            `er'
    global mimrgns__rr            `rr'
    global mimrgns__is_replay     0
    global mimrgns__is_contrast   0
    global mimrgns__is_pwcompare  0
    global mimrgns__is_noatlegend 0
    global mimrgns__is_post       0
    global mimrgns__is_verbose    0
    global mimrgns__is_nosmall    0
    global mimrgns__caller        "mimrgns"
    global mimrgns__m             0
    global mimrgns__setcmd        "mimrgns"
    _estimates hold `er' , copy nullok
end

program mimrgns_init_assert_void
    args cat
    
    local names : all `cat' "mimrgns__*"
    if mi("`names'") exit
    
    local globals  global
    local matrices matrix
    gettoken name : names
    display as err "``cat'' `name' already exists"
    exit 499
end

program mimrgns_setcmdmargins
    if ("`e(cmd)'"=="mimrgns")  mata : st_global("e(cmd)",  "margins")
    if ("`e(cmd2)'"=="mimrgns") mata : st_global("e(cmd2)", "margins")
    if ("`r(cmd)'"=="mimrgns")  mata : st_global("r(cmd)",  "margins")
    if ("`r(cmd2)'"=="mimrgns") mata : st_global("r(cmd2)", "margins")
end

program mimrgns_at_varies
    local vv `e(names_vvm_mi)'
    local at at
    global mimrgns__at_varies : list at in vv
end

program mimrgns_rtable
    args rtable
    
    tempname mat
    matrix `mat' = `rtable'
    
    _return restore ${mimrgns__rr}
    mata : st_matrix("`rtable'", st_matrix("`mat'"))
    mata : st_matrixrowstripe("`rtable'", st_matrixrowstripe("`mat'"))
    mata : st_matrixcolstripe("`rtable'", st_matrixcolstripe("`mat'"))
    _return hold ${mimrgns__rr}
end

program mimrgns_done
    args Rc
    
    if (`Rc') {
        mata : st_rclear()
        _estimates unhold ${mimrgns__er}
    }
    else {
        capture _return restore ${mimrgns__rr}
        if ((!${mimrgns__is_post})|(${mimrgns__is_replay})) ///
            _estimates unhold ${mimrgns__er}
    }
    
    capture _estimates drop ${mimrgns__er}
    capture _return    drop ${mimrgns__rr}
    
    macro drop mimrgns__*
    local names : all matrices "mimrgns__*"
    if ("`names'"!="") matrix drop `names'
end

// -------------------------------------- Mata
version 11.2

if (c(stata_version)>=12) local hidden , "hidden"
if (c(stata_version)>=14) local u      u

local RS real scalar
local RR real rowvector
local RM real matrix

local SR string rowvector
local SS string scalar

mata :

mata set matastrict on

void mimrgns_combine_at()
{
    st_matrix("e(at)", st_matrix("mimrgns__at"):/
              strtoreal(st_global("mimrgns__m")))
    st_matrixrowstripe("e(at)", st_matrixrowstripe("r(at)"))
    st_matrixcolstripe("e(at)", st_matrixcolstripe("r(at)"))
}

void mimrgns_combine_vs()
{
    `RS' M, nosmall, nu_c, gamma
    `RR' q, r, df, nu_obs
    `RM' U, B, T
    
    M = strtoreal(st_global("mimrgns__m"))
    q = mean(st_matrix("mimrgns__b_vs"))
    U = (st_matrix("mimrgns__V_vs")/M)    
    B = quadvariance(st_matrix("mimrgns__b_vs"))
    T = U + (1+1/M) * B
    
    if (!issymmetric(T)) {
        if (mreldifsym(T)>strtoreal(st_global("mimrgns__tolerance"))) {
            errprintf("covariance matrix not symmetric\n")
            exit(499)
        }
        _makesymmetric(T)
    }
    
    r  = (((1+1/M)*diagonal(B)):/diagonal(U))'
    df = (M-1)*(1:+1:/r):^2
    
    nosmall = strtoreal(st_global("mimrgns__is_nosmall"))
    
    if (nosmall & (st_global("e(dfadjust_mi)")=="Small sample")) {
        st_global("e(dfadjust_mi)", "Large sample")
    }
    else if ((!nosmall) & ((nu_c=st_numscalar("r(df_r)"))!=J(0, 0, .))) {
        gamma  = ((1+1/M)*(diagonal(B):/diagonal(T)))'
        nu_obs = nu_c * (nu_c+1) * (1:-gamma):/(nu_c+3)
        df     = 1:/((1:/df):+(1:/nu_obs))
    }
    
    st_matrix("e(b_vs)", q)
    st_matrixcolstripe("e(b_vs)", st_matrixcolstripe("r(b_vs)"))
    
    st_matrix("e(V_vs)", T)
    st_matrixrowstripe("e(V_vs)", st_matrixrowstripe("r(V_vs)"))
    st_matrixcolstripe("e(V_vs)", st_matrixcolstripe("r(V_vs)"))
    
    st_matrix("e(df_vs)", df)
    st_matrixcolstripe("e(df_vs)", st_matrixcolstripe("r(b_vs)"))
    
    st_matrix("e(error_vs)", ((st_matrix("r(error_vs)"):!=0)*8))
}

void mimrgns_return()
{
    `SR' vv
    `RS' i
    
    st_global("e(cmd_mimrgns)", "mimrgns" `hidden')
    if (st_global("e(cmd)")=="margins")
        st_global("e(cmd)", st_global("mimrgns__setcmd"))
    else if (st_global("e(cmd2)")=="margins")
        st_global("e(cmd2)", st_global("mimrgns__setcmd"))
    
    // delete varying r()
    vv = tokens(st_global("e(names_vvs_mi)"))
    for (i=1; i<=cols(vv); ++i) 
        st_numscalar(sprintf("r(%s)", vv[i]), J(0, 0, .))
    vv = tokens(st_global("e(names_vvl_mi)"))
    for (i=1; i<=cols(vv); ++i) 
        st_global(sprintf("r(%s)", vv[i]), "")
    vv = tokens(st_global("e(names_vvm_mi)"))
    for (i=1; i<=cols(vv); ++i) 
        st_matrix(sprintf("r(%s)", vv[i]), J(0, 0, .))
    
    st_global("r(overall)", "")
    st_matrix("r(k_groups)", J(0, 0, .))
    for (i=1; i<=cols(st_matrix("r(b)")); ++i)
        st_global(sprintf("r(groups%s)", strofreal(i)), "")
    st_matrix("r(chi2)", J(0, 0, .))
    st_matrix("r(p)", J(0, 0, .))
    
    // return r()
    st_numscalar("r(N)", st_numscalar("e(N_mi)"))
    st_global("r(cmd_mimrgns)", "mimrgns" `hidden')
    if (st_global("r(cmd)")=="margins")
        st_global("r(cmd)", st_global("mimrgns__setcmd"))
    else if (st_global("r(cmd2)")=="margins")
        st_global("r(cmd2)", st_global("mimrgns__setcmd"))
    else if (stataversion()<1200) 
        st_global("r(cmd)", st_global("mimrgns__setcmd"))
    
    st_global("r(est_cmdline_margins)", 
        `u'strtrim(stritrim(st_global("e(cmdline)"))))
    st_global("r(est_cmdline_mi)", 
        `u'strtrim(stritrim(st_global("e(cmdline_mi)"))))
    st_global("r(cmdline)", 
        `u'strtrim(stritrim("mimrgns " + 
                 st_global("mimrgns__cmdline_mimrgns"))))
            
    mimrgns_matrix_e2r("error")
    mimrgns_matrix_e2r("df_mi", "df")
    
    mimrgns_matrix_e2r("V")
    mimrgns_matrix_e2r("b")
    mimrgns_matrix_e2r("error_vs")
    
    mimrgns_matrix_e2r("df_vs")
    mimrgns_matrix_e2r("V_vs")
    mimrgns_matrix_e2r("b_vs")
    mimrgns_matrix_e2r("at")
}

void mimrgns_matrix_e2r(`SS' name, | `SS' newname)
{
    if (args()<2) newname = name
    name    = sprintf("e(%s)", name)
    newname = sprintf("r(%s)", newname)
    if (st_matrix(name)==J(0, 0, .)) 
        return
    st_matrix(newname, st_matrix(name))
    st_matrixrowstripe(newname, st_matrixrowstripe(name))
    st_matrixcolstripe(newname, st_matrixcolstripe(name))
}

end
exit

/* ---------------------------------------
4.0.3 07jan2020 bug fix predict() with more than one argument
                catch error predict() and contrast() earlier
4.0.2 22sep2019 bug fix for option -noatlegend-
                set r(cmd) in Stata version 11.2
                matastrict setting within mata environment
                code polish
4.0.1 21dec2018 fix bug returned cmd with contrast and pwcompare 
4.0.0 01dec2018 rewrite in terms of globals and matrices mimrgns__*
                shift everything back to mimrgns.ado
                mimrgns_work.class no longer required
                new mimrgns_estimate 3.0.0
                fix a couple of minor bugs
3.3.0 07apr2017 new mimrgns_work version 2.3.0
                tolerance for non-symmetric VC-matrix set to 1e-14
                new option settolerance() (not documented)
                new mimrgns_estimate version 2.1.1
3.2.1 11feb2017 new mimrgns_work version 2.2.1
                adjust output for multiple predictions (Stata 14)
3.2.0 03nov2016 new mimrgns_work version 2.2.0
                bug fix for marginlist with contrast option
                allow contrast(atcontrast()) option
                return r(at) despite varying results
                copy AtLegend and Legend from _marg_report
                new mimrgns_estimate version 2.1.0
3.1.0 05aug2016 new mimrgns_work version 2.1.0
                copy -cmdok- option from previous -mi- call
                new mi options -errorok- and -esampvaryok-
3.0.0 28jun2016 new mimrgns_work version 2.0.0
                bug fix for -noatlegend- option
                bug fix df correction for pwcompare
                new using syntax works with ster-files
                new syntax can replay() results
                changed returned results
                return r(table) and r(table_vs)
                margins option -nose- no longer allowed
                margins option -saving()- no longer allowed
                new mimrgns_estimate.ado version 2.0.0
                shift everything to mimrgns_work.class
2.1.6 15jan2016 new mimrgns_work version 1.1.1
                bug fix in mimrgns_return()
2.1.5 18aug2015 new mimrgns_work version 1.1.0
                report legend despite varying -at- values
                remove results reported in names_vv* by mi
                ignore -cmdmargins- with varying -at-
                change handle _rc in mimrgns.ado
2.1.4 02jul2015 bug fix on Linux OS (could not find MiMrgns)
                rewrite and reorganize complete code
                new mimrgns_work.class
                new mimrgns_estimate.ado
2.1.3 18feb2015 bug fix for marginlist (triggered contrast)
                new output has appropriate coeftitles
2.1.2 17feb2015 new output adds predict label and derivatives
                new output shows legend above tables
2.1.1 28jan2015 fix bug contrast/pwcompare opts (new _coef_table)
2.1.0 06jan2015 bug fix for reporting and display options
                support for -contrast- (option and operators)
                report -at- legend (code adapted from StataCorp)
                remove -at- matrices if stats are specified
                option -diopts- no longer documented
                code polish
2.0.1 30dec2014 support for -contrast- option (beta)
                nicer output for -contrast-
                subroutine -SetTableOpts- sets locals in caller
                sent to Evan Kontopantelis
                beta version; never released on SSC
2.0.0 09oct2014 bug fix get cmd from e(cmdline_mi) not e(cmdline)
                bug fix ignored reporting and display options
                support for -pwcompare- option
                default prediction is now -xb-
                new output replays results; _coef_table
                new option -eform-
                new option -diopts-
                new option -cmdmargins-; r|e(cmd) now -mimrgns-
                new option -miopts- (not documented)
                rewrite code, add subroutine and Mata functions
1.1.2 18apr2014 bug fix with mixed models syntax; parsing on ||
                bug fix for options without mi options
                bug fix for mi option -noisily-
                add caller version support
                code polish remove more matrices from results
1.1.1 27mar2014 bug fix ignored weights specified with -mimrgns-
1.1.0 27feb2014 remove potentially missleading and/or invalid results
                support for -margins-' -post- option
                Stata version 11.2 declared
                first version sent to SSC
1.0.2 24feb2014 global macros mimrgns_* no longer created
1.0.1 24feb2014 bug fix problem with -mi-'s -post- and -eform- options
                bug fix problem with -margins-' -at()- option
1.0.0 21feb2014 initial draft
