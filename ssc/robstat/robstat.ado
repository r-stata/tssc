*! version 1.0.1  21feb2019  Ben Jann

program robstat, eclass properties(svyb svyj)
    version 11
    if replay() {
        Display `0'
        exit
    }
    capt findfile lmoremata.mlib
    if _rc {
        di as err "-moremata- is required; see {stata ssc describe moremata}"
        error 499
    }
    capt findfile lkdens.mlib
    if _rc {
        di as err "-kdens- is required; see {stata ssc describe kdens}"
        error 499
    }
    local version : di "version " string(_caller()) ":"
    Parse_opts `0' // returns lhs, options, statistics, jbtest, jbtest2, jbwald, cluster
    `version' _vce_parserun robstat, mark(over) bootopts(`cluster') ///
        jkopts(`cluster') wtypes(pw iw fw) noeqlist: ///
        `lhs', nose `statistics' `options'
    if "`s(exit)'" != "" {
        ereturn local cmdline `"robstat `0'"'
        if "`jbtest'"!="" {
            JBtest, `jbtest2' `jbwald' display
        }
        exit
    }
    Estimate `0' // returns diopts
    ereturn local cmdline `"robstat `0'"'
    if "`jbtest'"!="" {
        JBtest, `jbtest2' `jbwald'
    }
    Display, `diopts'
    if `"`e(IFvars)'"'!="" {
        local IFnote "(influence functions stored in: `e(IFvars)')"
        local i 0
        while (1) {
            local ++i
            local line: piece `i' 80 of "`IFnote'"
            if "`line'"=="" continue, break
            di as txt "`line'"
        }
        di
    }
end

program Parse_opts
    _parse comma lhs 0 : 0
    syntax [, nose CLuster(passthru) Statistics(str) swap ///
        JBtest JBtest2(str) WALD  * ]
    if `"`jbtest2'"'!="" local jbtest jbtest
    if "`jbtest'"!="" & `"`statistics'"'!="" {
        di as err "statistics() not allowed with jbtest"
        exit 198
    }
    if "`jbtest'"!="" & "`swap'"!="" {
        di as err "swap not allowed with jbtest"
        exit 198
    }
    if "`wald'"!="" & "`jbtest'"=="" {
        di as err "wald only allowed if jbtest is specified"
        exit 198
    }
    if "`jbtest'"!="" JBtest_args `jbtest2' // sets local statistics
    c_local lhs `"`lhs'"'
    c_local cluster `cluster'
    c_local jbtest `jbtest'
    if "`jbtest2'"!="" {
        c_local jbtest2 jbtest2(`jbtest2')
    }
    c_local jbwald `wald'
    if "`statistics'"!="" {
        c_local statistics statistics(`statistics')
    }
    c_local options `swap' `options'
end

program Display
    syntax [, noHEader noTABle Level(passthru) CILog * ]
    if "`cilog'"!="" {
        if c(stata_version)<15 {
            di as err "option cilog only allowed in Stata 15 or newer"
            exit 198
        }
    }
    _get_diopts diopts, `options'
    if `"`e(cmd)'"'!="robstat" {
        di as err "last robstat results not found"
        exit 301
    }
    if `"`level'"'=="" local level level(`e(level)')
    if `"`header'"'=="" {
        if c(stata_version)>=12 {
            nobreak {
                Display_ereturn local cmd "total" // mimick header of -total-
                capture noisily break {
                    _coef_table_header
                }
                Display_ereturn local cmd "robstat"
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
        if "`cilog'"!="" {
            mata: st_local("cilog", "cilog" * anyof(st_matrix("e(class)"),2))
        }
        nobreak {
            local depvar `"`e(depvar)'"'
            local modified 0
            if e(N_stats)==1 {
                if e(N_vars)>1 | `"`e(over)'"'!="" {
                    Display_ereturn local depvar `"`e(statistics)'"'
                    local modified 1
                }
            }
            capture noisily break {
                Display_table "`cilog'" `"`level'"' `"`options'"'
            }
            if `modified' {
                Display_ereturn local depvar `"`depvar'"'
            }
            if _rc exit _rc
        }
    }
    capt confirm matrix e(jbtest)
    if _rc==0 JBtest_display
end
prog Display_ereturn, eclass
    ereturn `0'
end
program Display_table
    args cilog level options
    if c(stata_version)>=15 {
        if "`cilog'"!="" {
            qui _coef_table, `level'
            tempname CI
            mata: robstat_cilog()
            _coef_table, nopvalue cimat(`CI') `level' `options'
            mat drop `CI'
            di as txt `"(`cilognote')"'
        }
        else {
            eret di, nopvalue `level' `options'
        }
    }
    else if c(stata_version)>=14 {
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
    else if c(stata_version) >= 12 {
        _coef_table, cionly `level' `options'
    }
    else {
        eret di, `level' `options'
    }
end

program JBtest, eclass
    syntax [, jbtest2(str) WALD display ]
    JBtest_args `jbtest2'
    local vce   "`e(vce)'"
    local wtype "`e(vce)'"
    if "`vce'"=="" {
        if "`wtype'"!="" & "`wtype'"!="fweight" local wald wald
    }
    else if "`vce'"!="analytic" local wald wald
    local ntests: list sizeof jbtests
    local eqs: coleq e(b)
    local eqs: list uniq eqs
    if "`wald'"!="" {
        if e(df_r)<. {
            local jbtype F
            local jbtitle "Normality Tests (Wald F; df_r = `e(df_r)')"
        }
        else {
            local jbtype chi2
            local jbtitle "Normality Tests (Wald chi2)"
        }
        tempname jbtest tmp
        foreach eq of local eqs {
            local rown
            matrix `tmp' = J(`ntests', 3,.)
            local m 0
            foreach t of local jbtests {
                local ++m
                if "`t'"=="jbera" {
                    local rown `rown' JB
                    local exp (_b[`eq':skewness]=0) (_b[`eq':kurtosis]=3)
                }
                else if "`t'"=="moors" {
                    local rown `rown' MOORS
                    local exp (_b[`eq':SK25]=0) (_b[`eq':QW25]=1.23)
                }
                else if "`t'"=="mc" {
                    local rown `rown' MC
                    local exp (_b[`eq':MC]=0)
                }
                else if "`t'"=="lmc" {
                    local rown `rown' LMC
                    local exp (_b[`eq':LMC]=0.199)
                }
                else if "`t'"=="rmc" {
                    local rown `rown' RMC
                    local exp (_b[`eq':RMC]=0.199)
                }
                else if "`t'"=="lr" {
                    local rown `rown' LR
                    local exp (_b[`eq':LMC]=0.199) (_b[`eq':RMC]=0.199)
                }
                else if "`t'"=="mcl" {
                    local rown `rown' MC-L
                    local exp (_b[`eq':MC]=0) (_b[`eq':LMC]=0.199)
                }
                else if "`t'"=="mcr" {
                    local rown `rown' MC-R
                    local exp (_b[`eq':MC]=0) (_b[`eq':RMC]=0.199)
                }
                else if "`t'"=="mclr" {
                    local rown `rown' MC-LR
                    local exp (_b[`eq':MC]=0) (_b[`eq':LMC]=0.199) (_b[`eq':RMC]=0.199)
                }
                qui test `exp'
                matrix `tmp'[`m',1] = r(`jbtype'), r(df), r(p)
            }
            mat rown `tmp' = `rown'
            mat roweq `tmp' = `eq'
            mat `jbtest' = nullmat(`jbtest') \ `tmp'
        }
        mat coln `jbtest' = `jbtype' df "Prob>`jbtype'"
    }
    else {
        local nover = e(N_over)
        local jbtype chi2
        local jbtitle "Normality Tests"
        tempname jbtest tmp D V
        local k 0
        foreach eq of local eqs {
            local ++k
            local N = el(e(_N), mod(`k'-1,`nover')+1, 1)
            local rown
            matrix `tmp' = J(`ntests', 3,.)
            local m 0
            foreach t of local jbtests {
                local ++m
                if "`t'"=="jbera" {
                    local rown `rown' JB
                    local df 2
                    matrix `D' = (_b[`eq':skewness], _b[`eq':kurtosis]-3)'
                    matrix `V' = (6, 0) \ (0, 24)
                }
                else if "`t'"=="moors" {
                    local rown `rown' MOORS
                    local df 2
                    matrix `D' = (_b[`eq':SK25], _b[`eq':QW25]-1.23)'
                    matrix `V' = (1.84, 0) \ (0, 3.14)
                }
                else if "`t'"=="mc" {
                    local rown `rown' MC
                    local df 1
                    matrix `D' = (_b[`eq':MC])
                    matrix `V' = (1.25)
                }
                else if "`t'"=="lmc" {
                    local rown `rown' LMC
                    local df 1
                    matrix `D' = (_b[`eq':LMC]-0.199)
                    matrix `V' = (2.62)
                }
                else if "`t'"=="rmc" {
                    local rown `rown' RMC
                    local df 1
                    matrix `D' = (_b[`eq':RMC]-0.199)
                    matrix `V' = (2.62)
                }
                else if "`t'"=="lr" {
                    local rown `rown' LR
                    local df 2
                    matrix `D' = (_b[`eq':LMC]-0.199, _b[`eq':RMC]-0.199)'
                    matrix `V' = (2.62, -.0123) \ (-.0123, 2.62)
                }
                else if "`t'"=="mcl" {
                    local rown `rown' MC-L
                    local df 2
                    matrix `D' = (_b[`eq':MC], _b[`eq':LMC]-0.199)'
                    matrix `V' = (1.25, .323) \ (.323, 2.62)
                }
                else if "`t'"=="mcr" {
                    local rown `rown' MC-R
                    local df 2
                    matrix `D' = (_b[`eq':MC], _b[`eq':RMC]-0.199)'
                    matrix `V' = (1.25, .323) \ (.323, 2.62)
                }
                else if "`t'"=="mclr" {
                    local rown `rown' MC-LR
                    local df 3
                    matrix `D' = (_b[`eq':MC], _b[`eq':LMC]-0.199, _b[`eq':RMC]-0.199)'
                    matrix `V' = (1.25, .323, -.323) \  ///
                                 (.323, 2.62, -.0123) \ ///
                                 (-.323, -.0123, 2.62)
                }
                matrix `tmp'[`m',1] = `N'*`D''*invsym(`V')*`D', `df'
                matrix `tmp'[`m',3] = chi2tail(`df', `tmp'[`m',1])
            }
            mat rown `tmp' = `rown'
            mat roweq `tmp' = `eq'
            mat `jbtest' = nullmat(`jbtest') \ `tmp'
        }
        mat coln `jbtest' = `jbtype' df "Prob>`jbtype'"
        
    }
    ereturn matrix jbtest = `jbtest'
    ereturn local jbwald `wald'
    ereturn local jbtype `jbtype'
    ereturn local jbtitle "`jbtitle'"
    if "`display'"!="" JBtest_display
end
program JBtest_args
    if strtrim(`"`0'"')=="all" {
        local 0 jbera moors mclr mcl mcr mc lr lmc rmc
    }
    local jbtests
    foreach s of local 0 {
        local t = lower(`"`s'"')
        local l  = strlen(`"`t'"')
        // jbera
        if "`t'"==substr("jbera", 1, max(2,`l')) {
            local jbtests `jbtests' jbera
            local s1 skewness kurtosis
        }
        else if "`t'"==substr("moors", 1, max(2,`l')) {
            local jbtests `jbtests' moors
            local s2 sk25 qw25
        }
        else if "`t'"=="mc" {
            local jbtests `jbtests' mc
            local s3 mc
        }
        else if "`t'"==substr("lmc", 1, max(1,`l')) {
            local jbtests `jbtests' lmc
            local s4 lmc
        }
        else if "`t'"==substr("rmc", 1, max(1,`l')) {
            local jbtests `jbtests' rmc
            local s5 rmc
        }
        else if "`t'"=="lr" {
            local jbtests `jbtests' lr
            local s4 lmc
            local s5 rmc
        }
        else if inlist("`t'", "mcl", "mc-l") {
            local jbtests `jbtests' mcl
            local s3 mc
            local s4 lmc
        }
        else if inlist("`t'", "mcr", "mc-r") {
            local jbtests `jbtests' mcr
            local s3 mc
            local s5 rmc
        }
        else if inlist("`t'", "mclr", "mc-lr") {
            local jbtests `jbtests' mclr
            local s3 mc
            local s4 lmc
            local s5 rmc
        }
        else {
            di as err `"`s' not allowed in jbtest()"'
            exit 198
        }
    }
    if "`jbtests'"=="" {
        local jbtests jbera moors mclr
        local statistics skewness kurtosis sk25 qw25 mc lmc rmc
    }
    else {
        local statistics `s1' `s2' `s3' `s4' `s5'
    }
    c_local statistics `statistics'
    c_local jbtests `jbtests'
end

program JBtest_display
    local rspec
    local k_eq = e(k_eq)
    local njb  = rowsof(e(jbtest)) / `k_eq' - 1
    forv i = 1/`k_eq' {
        forv j = 1/`njb' {
            local rspec `rspec'&
        }
        local rspec `rspec'-
    }
    matlist e(jbtest), rspec(--`rspec') cspec(&%12s|%10.2f&%5.0g&%10.4f&) ///
        title(`e(jbtitle)')
end

program Estimate, eclass
    // syntax
    syntax varlist(numeric) [if] [in] [pw iw fw/], [          ///
        Statistics(str asis) swap                             ///
        over(varname numeric) Total                           ///
        vce(str) CLuster(varname) svy SVY2(str) nose          ///
        GENerate GENerate2(name) replace                      ///
        /// normality test (just for parsing)
        JBtest JBtest2(str) WALD                              ///
        /// optimization options for M-estimation
        TOLerance(real 1e-10) ITERate(integer `c(maxiter)')   ///
        /// kernel density estimation options
        Kernel(name) bw(name) Adaptive(int 2) n(int 512)      ///
        /// display options
        Level(cilevel) noHEader noTABle CILog *               ///
        ]
    if "`cilog'"!="" {
        if c(stata_version)<15 {
            di as err "option cilog only allowed in Stata 15 or newer"
            exit 198
        }
    }
    if `"`generate2'"'!=""   local generate generate
    else if "`generate'"!="" local generate2 _IF_
    if `"`jbtest'`jbtest2'"'!="" {
        JBtest_args `jbtest2' // sets local statistics
    }
    if `tolerance'<=0 {
            di as err  "tolerance() must be positive"
            exit 198
    }
    if `iterate'<=0 {
            di as err  "iterate() must be positive"
            exit 198
    }
    local estopts tolerance(`tolerance') iterate(`iterate')
    if "`kernel'"=="" local kernel epan2
    if "`bw'"=="" local bw dpi
    if `adaptive'<=0 {
        di as err "adaptive() must be positive"
        exit 198
    }
    if `n'<=2 {
        di as err "n() must be > 2"
        exit 198
    }
    local estopts `estopts' kernel(`kernel') bw(`bw') adaptive(`adaptive') n(`n')

    // varlist
    local varlist: list uniq varlist // remove repeated varnames
    local ndepv: list sizeof varlist 
    
    // statistics
    Parse_stats `statistics'    // returns stats, statslbl
    local nstats: list sizeof stats
    
    // over(), total
    if "`over'"=="" {
        if "`total'"!="" {
            di as err "total only allowed if over() is specified"
            exit 198
        }
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
    c_local diopts `header' `table' `levelopt' `cilog' `diopts'
    
    // sample and weights
    marksample touse
    markout `touse' `clustvar' `over'
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
        if "`total'"!="" {
            local ++N_over
        }
        local over_labels
        foreach overval of local overvals {
            local over_labels `"`over_labels' `"`: label (`over') `overval''"'"'
        }
        local over_labels: list clean over_labels
    }
    else {
        local total total
        local N_over 1
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
    
    // generate: check whether variables already exist
    if "`se'"=="" & "`generate'"!="" & "`replace'"=="" {
        foreach v of local varlist {
            foreach overval in `overvals' `total' {
                foreach stat of local stats {
                    Make_IF_Name `generate2' `stat' `v' `ndepv' "`over'" ///
                        `overval' `stat' `nstats' // returns vname
                    confirm new variable `vname'
                }
            }
        }
    }
    
    // compute statistics
    tempname b btmp class cltmp aux auxtmp _N
    local uvars
    if `nstats'>1 {
        local k_eq   = `ndepv' * `N_over'
        local k_coef = `nstats'
    }
    else {
        if "`over'"!="" {
            local k_eq   = `ndepv'
            local k_coef = `N_over'
        }
        else {
            local k_eq   = 1
            local k_coef = `ndepv'
        }
    }
    if "`over'"!="" {
        mat `_N' = J(`N_over', 1, .)
    }
    else {
        mat `_N' = J(1, 1, .)
    }
    mat rown `_N' = `overvals' `total'
    mat coln `_N' = "N"
    foreach v of local varlist {
        local k 0
        foreach overval in `overvals' `total' {
            local ++k
            // select obs
            if `"`overval'"'=="total" local touse1 (1)
            else                      local touse1 (`over'==`overval')
            // equation label
            if `k_eq'>1 {
                if `ndepv'==1        local eq "`overval'"
                else if "`over'"=="" local eq "`v'"
                else if `nstats'==1  local eq "`v'"
                else                 local eq "`v'_`overval'"
            }
            else if "`over'"!="" & `nstats'>1 local eq "`overval'"
            else local eq
            // count obs
            if "`svy'"!="" & `"`exp'"'!="" {
                su `touse' if `touse' & `subpop' & `touse1', meanonly
            }
            else {
                su `touse' `swgt' if `touse' & `subpop' & `touse1', meanonly
            }
            mat `_N'[`k', 1] = r(N)
            // compute stats
            mat `btmp' = J(1, `nstats', .)
            mat coln `btmp' = `statslbl'
            mat `cltmp' = `btmp'
            if `nstats'==1 {
                if "`over'"!="" {
                    mat coln `btmp' = `overval'
                }
                else if `ndepv'>1 {
                    mat coln `btmp' = `v'
                }
            }
            mat coleq `btmp' = `eq'
            mat `auxtmp' = `btmp'
            local j 0
            foreach stat of local stats {
                local u
                if "`se'"=="" {
                    tempvar u
                    qui gen double `u' = 0 if `touse'
                    local uvars `uvars' `u'
                }
                local ++j
                Estimate_`stat' `wgt' if `touse' & `subpop' & `touse1', ///
                    v(`v') u(`u') `estopts'
                mat `btmp'[1, `j']   = r(b)
                mat `cltmp'[1, `j']  = r(class)
                mat `auxtmp'[1, `j'] = r(k)
            }
            mat `b'     = nullmat(`b'), `btmp'
            mat `class' = nullmat(`class'), `cltmp'
            mat `aux'   = nullmat(`aux'), `auxtmp'
        }
    }
    
    // compute standard errors
    if "`se'"=="" {
        tempname V
        if "`svy'"!="" {
            //qui svy, `svy2': total `uvars' if `touse'
            qui svy, `svy2': mean `uvars' if `touse'
        }
        else {
            //qui total `uvars' `wgt' if `touse', `clustopt'
            qui mean `uvars' `wgt' if `touse', `clustopt'
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
    if "`swap'"!="" {   // flip equations and coefficients
        mata: _robstat_swap_eq_and_coefs(`k_eq', `k_coef')
    }
    eret post `b' `V' `wgt', obs(`N') esample(`touse')
    eret local cmd "robstat"
    eret local depvar "`varlist'"
    if "`svy'"!="" eret local title "Survey: Robust Statistics"
    else           eret local title "Robust Statistics"
    eret scalar k_eq = `k_eq'
    eret scalar N_stats = `nstats'
    eret local statistics "`statslbl'"
    eret scalar N_vars = `ndepv'
    if "`over'"!="" {
        eret local total "`total'"
        eret local over_labels `"`over_labels'"'
        eret local over_namelist `"`overvals'"'
        eret local over "`over'"
    }
    eret scalar N_over = `N_over'
    eret mat _N = `_N'
    eret mat class = `class'
    eret mat aux = `aux'
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
    
    // generate: rename uvars 
    if "`se'"=="" & "`generate'"!="" {
        local IFvars
        local i 0
        foreach v of local varlist {
            foreach overval in `overvals' `total' {
                foreach stat of local stats {
                    Make_IF_Name `generate2' `stat' `v' `ndepv' "`over'" ///
                        `overval' `stat' `nstats' // returns vname
                    capt confirm new variable `vname'
                    if _rc drop `vname'
                    local ++i
                    local uvar: word `i' of `uvars'
                    rename `uvar' `vname'
                    local IFvars `IFvars' `vname'
                }
            }
        }
        eret local IFvars `IFvars'
    }
    Return_clear // for some reason -return clear- does not delete r(S)
end
program Return_clear, rclass
    local x
end

program Make_IF_Name
    args vname stat v ndepv over overval stat nstats
    local stat: subinstr local stat ":" ""
    local uscore
    if `ndepv'>1 {
        local vname `vname'`v'
        local uscore _
    }
    if "`over'"!="" {
        local vname `vname'`uscore'`overval'
        local uscore _
    }
    if `nstats'>1 | "`uscore'"=="" {
        local vname `vname'`uscore'`stat'
    }
    c_local vname `vname'
end

program Parse_stats
    local stats
    local statslbl
    foreach s of local 0 {
        local ok = regexm(lower(`"`s'"'), "^([a-z]+)([0-9]*)$")
        if `ok' {
            local s1 = regexs(1)
            local s2 = regexs(2)
        }
        else {
            di as err `"`s' not allowed in statistics()"'
            exit 198
        }
        local l = strlen(`"`s1'"')
        // mean
        if "`s1'"==substr("mean", 1, max(1,`l')) & `"`s2'"'=="" {
            local stats     `stats'   mean
            local statslbl `statslbl' mean
            continue
        }
        // alpha-trimmed mean
        if "`s1'"==substr("alpha", 1, max(1,`l')) {
            if "`s2'"=="" local s2 5                // default is alpha5
            Parse_stats_confirm_num 1 49 `s2' `s'   // range is [1,49]
            local stats    `stats'    alpha:`s2'
            local statslbl `statslbl' alpha`s2'
            continue
        }
        // median
        if "`s1'"==substr("median", 1, max(3,`l')) & `"`s2'"'=="" {
            local stats     `stats'   median
            local statslbl `statslbl' median
            continue
        }
        // Hodges-Lehmann
        if "`s1'"=="hl" & `"`s2'"'=="" {
            local stats    `stats'    hl
            local statslbl `statslbl' HL
            continue
        }
        if "`s1'"=="hlnaive" & `"`s2'"'=="" {
            local stats    `stats'    hlnaive
            local statslbl `statslbl' HL(naive)
            continue
        }
        // Huber M
        if "`s1'"==substr("huber", 1, max(1,`l')) {
            if "`s2'"=="" local s2 95                // default is huber95
            Parse_stats_confirm_num 64 99 `s2' `s'   // range is [64,99]
            local stats    `stats'    huber:`s2'
            local statslbl `statslbl' Huber`s2'
            continue
        }
        // Biweight M
        if "`s1'"==substr("biweight", 1, max(2,`l')) {
            if "`s2'"=="" local s2 95                // default is biweight95
            Parse_stats_confirm_num 1 99 `s2' `s'    // range is [1,99]
            local stats    `stats'    biweight:`s2'
            local statslbl `statslbl' Biweight`s2'
            continue
        }
        // standard deviation
        if "`s1'"=="sd" & `"`s2'"'=="" {
            local stats     `stats'   sd
            local statslbl `statslbl' SD
            continue
        }
        // IQR
        if "`s1'"=="iqr" & `"`s2'"'=="" {
            local stats    `stats'    iqr
            local statslbl `statslbl' IQR
            continue
        }
        // IQRc
        if "`s1'"=="iqrc" & `"`s2'"'=="" {
            local stats    `stats'    iqrc
            local statslbl `statslbl' IQRc
            continue
        }
        // MAD
        if "`s1'"=="mad" & `"`s2'"'=="" {
            local stats    `stats'    mad
            local statslbl `statslbl' MAD
            continue
        }
        // MADN
        if "`s1'"=="madn" & `"`s2'"'=="" {
            local stats    `stats'    madn
            local statslbl `statslbl' MADN
            continue
        }
        // Qn coefficient
        if "`s1'"==substr("qn", 1, max(1,`l')) & `"`s2'"'=="" {
            local stats    `stats'    qn
            local statslbl `statslbl' Qn
            continue
        }
        if "`s1'"=="qnnaive" & `"`s2'"'=="" {
            local stats    `stats'    qnnaive
            local statslbl `statslbl' Qn(naive)
            continue
        }
        // M estimate of scale
        if "`s1'"=="s" {
            if "`s2'"=="" local s2 50               // default is s50
            Parse_stats_confirm_num 1 50 `s2' `s'   // range is [1,50]
            local stats    `stats'    s:`s2'
            local statslbl `statslbl' S`s2'
            continue
        }
        // skewness
        if "`s1'"==substr("skewness", 1, max(3,`l')) & `"`s2'"'=="" {
            local stats    `stats'    skewness
            local statslbl `statslbl' skewness
            continue
        }
        // SK(p)
        if "`s1'"=="sk" {
            if "`s2'"=="" local s2 25               // default is sk25
            Parse_stats_confirm_num 1 49 `s2' `s'   // range is [1,49]
            local stats    `stats'    sk:`s2'
            local statslbl `statslbl' SK`s2'
            continue
        }
        // medcouple
        if "`s1'"=="mc" & `"`s2'"'=="" {
            local stats    `stats'    mc
            local statslbl `statslbl' MC
            continue
        }
        if "`s1'"=="mcnaive" & `"`s2'"'=="" {
            local stats    `stats'    mcnaive
            local statslbl `statslbl' MC(naive)
            continue
        }
        // kurtosis
        if "`s1'"==substr("kurtosis", 1, max(1,`l')) & `"`s2'"'=="" {
            local stats    `stats'    kurtosis
            local statslbl `statslbl' kurtosis
            continue
        }
        // LQW(p)
        if "`s1'"=="qw" {
            if "`s2'"=="" local s2 25               // default is qw25
            Parse_stats_confirm_num 1 49 `s2' `s'   // range is [1,49]
            local stats    `stats'    qw:`s2'
            local statslbl `statslbl' QW`s2'
            continue
        }
        // LQW(p)
        if "`s1'"=="lqw" {
            if "`s2'"=="" local s2 25               // default is lqw25
            Parse_stats_confirm_num 1 49 `s2' `s'   // range is [1,49]
            local stats    `stats'    lqw:`s2'
            local statslbl `statslbl' LQW`s2'
            continue
        }
        // RQW(p)
        if "`s1'"=="rqw" {
            if "`s2'"=="" local s2 25               // default is rqw25
            Parse_stats_confirm_num 1 49 `s2' `s'   // range is [1,49]
            local stats    `stats'    rqw:`s2'
            local statslbl `statslbl' RQW`s2'
            continue
        }
        // LMC
        if "`s1'"=="lmc" & `"`s2'"'=="" {
            local stats    `stats'    lmc
            local statslbl `statslbl' LMC
            continue
        }
        if "`s1'"=="lmcnaive" & `"`s2'"'=="" {
            local stats    `stats'    lmcnaive
            local statslbl `statslbl' LMC(naive)
            continue
        }
        // RMC
        if "`s1'"=="rmc" & `"`s2'"'=="" {
            local stats    `stats'    rmc
            local statslbl `statslbl' RMC
            continue
        }
        if "`s1'"=="rmcnaive" & `"`s2'"'=="" {
            local stats    `stats'    rmcnaive
            local statslbl `statslbl' RMC(naive)
            continue
        }
        di as err `"`s' not allowed in statistics()"'
        exit 198
    }
    if "`stats'"=="" {
        local stats mean
        local statslbl mean
    }
    c_local stats `stats'
    c_local statslbl `statslbl'
end
program Parse_stats_confirm_num
    args l u n s
    capt numlist "`n'", min(1) max(1) range(>=`l' <=`u')
    if _rc {
        di as err `"`s' not allowed in statistics()"'
        exit 198
    }
end

program Estimate_mean, rclass
    syntax if [pw iw fw], v(str) [ u(str) * ]
    if "`weight'"=="pweight" local swgt [aw`exp']
    else if "`weight'"!=""   local swgt [`weight'`exp']
    su `v' `swgt' `if', meanonly
    tempname b
    scalar `b' = r(mean)
    if "`u'"!="" {
        qui replace `u' = (`v' - `b') `if'
    }
    return scalar b = `b'
    return scalar class = 1
end

program Estimate_alpha, rclass sortpreserve
    syntax anything(name=p) if [pw iw fw], v(str) [ u(str) * ]
    if "`weight'"=="pweight" local swgt  [aw`exp']
    else if "`weight'"!=""   local swgt  [`weight'`exp']
    if "`weight'"=="iweight" local pcwgt [aw`exp']
    else if "`weight'"!=""   local pcwgt [`weight'`exp']
    local p = substr("`p'", 2, .) // strip leading colon
    marksample touse
    sort `touse' `v'
    tempvar W
    if `"`exp'"'!="" qui gen double `W' `exp' if `touse'
    else             qui gen double `W' = 1 if `touse'
    qui by `touse': replace `W' = sum(`W') if `touse'
    qui by `touse': replace `W' = `W'*100/`W'[_N] if `touse'
    tempvar select
    qui by `touse': gen byte `select' = ///
        -1 + (`W'>`p') + (`W'[_n-1]>=(100-`p') & _n>1) if `touse'
    su `v' `swgt' if `touse' & `select'==0, meanonly
    tempname b
    scalar `b' = r(mean)
    if "`u'"!="" {
        qui replace `u' = 1 / (1 - `p'/50) * ///
            (cond(`select'==-1, r(min), cond(`select'==1, r(max), `v')) - `b') ///
            if `touse'
    } 
    return scalar b = `b'
    return scalar class = 1
end

program Estimate_median, rclass
    syntax if [pw iw fw/], v(str) [ u(str) ///
        kernel(str) bw(str) adaptive(str) n(str) * ]
    if "`weight'"=="iweight" local pcwgt [aw = `exp']
    else if "`weight'"!=""   local pcwgt [`weight' = `exp']
    marksample touse
    _pctile `v' `pcwgt' if `touse', percentiles(50)
    tempname b
    scalar `b' = r(r1)
    if "`u'"!="" {
        tempname d
        mata: robstat_kdens_s("`b'", "`d'")
        qui replace `u' = sign(`v'-`b') * (1 / (2*`d')) if `touse'
        //qui replace `u' =  -1 / `d' * ((`v'<=`b') - 0.5) if `touse'
    }
    return scalar b = `b'
    return scalar class = 1
end

program Estimate_hl, rclass
    syntax if [pw iw fw/], v(str) [ u(str) naive ///
        kernel(str) bw(str) adaptive(str) n(str) * ]
    if "`weight'"=="pweight" local swgt  [aw = `exp']
    else if "`weight'"!=""   local swgt  [`weight' = `exp']
    marksample touse
    tempname b
    mata: robstat_estimate_pairwise("hl`naive'") // returns result in scalar b
    if "`u'"!="" {
        tempvar v1 F1 dvar
        qui generate double `v1'   = 2*`b' - `v' if `touse'
        qui generate double `F1'   = .
        qui generate double `dvar' = .
        mata: robstat_relrank("`v1'", "`F1'")
        mata: robstat_kdens_v("`v1'", "`dvar'")
        summarize `dvar' `swgt' if `touse', meanonly
        qui replace `u' = (1/2 - `F1') / r(mean) if `touse'
    }
    return scalar b = `b'
    return scalar class = 1
end
program Estimate_hlnaive
    Estimate_hl `0' naive
end

program Estimate_huber, rclass
    syntax anything(name=p) if [pw iw fw/], v(str) [ u(str) ///
        tolerance(str) iterate(str) ///
        kernel(str) bw(str) adaptive(str) n(str) ]
    local p = substr("`p'", 2, .) // strip leading colon
    marksample touse
    tempname b k
    mata: robstat_estimate_m(`p', "huber", `tolerance', `iterate') 
        // returns result in b and k, fills in u
    return scalar b = `b'
    return scalar k = `k'
    return scalar class = 1
end

program Estimate_biweight, rclass
    syntax anything(name=p) if [pw iw fw/], v(str) [ u(str) ///
        tolerance(str) iterate(str) ///
        kernel(str) bw(str) adaptive(str) n(str) ]
    local p = substr("`p'", 2, .) // strip leading colon
    marksample touse
    tempname b k
    mata: robstat_estimate_m(`p', "biweight", `tolerance', `iterate') 
        // returns result in b and k, fills in u
    return scalar b = `b'
    return scalar k = `k'
    return scalar class = 1
end

program Estimate_sd, rclass
    syntax if [pw iw fw], v(str) [ u(str) * ]
    if "`weight'"=="pweight" local swgt  [aw`exp']
    else if "`weight'"!=""   local swgt  [`weight'`exp']
    qui su `v' `swgt' `if'
    tempname mean sd
    scalar `mean' = r(mean)
    scalar `sd' = r(sd)
    if (`sd'>=.) scalar `sd' = 0  // can happen if n=1
    if "`u'"!="" {
        if (`sd'!=0) {
            // qui replace `u' = 1/(2*`sd') * ///
            //     (`v'^2 - 2*`mean'*`v' + (`mean'^2 - `sd'^2)) `if'
            qui replace `u' = 1/(2*`sd') * ((`v'-`mean')^2 - `sd'^2) `if'
        }
    }
    return scalar b = `sd'
    return scalar class = 2
end

program Estimate_iqr, rclass
    syntax if [pw iw fw/], v(str) [ u(str) corr ///
        kernel(str) bw(str) adaptive(str) n(str) * ]
    if "`weight'"=="iweight" local pcwgt [aw = `exp']
    else if "`weight'"!=""   local pcwgt [`weight' = `exp']
    marksample touse
    tempname q1 q3 b d
    scalar `d' = cond("`corr'"!="", 1/(invnormal(0.75)-invnormal(0.25)), 1)
    _pctile `v' `pcwgt' if `touse', percentiles(25 75)
    scalar `q1' = r(r1)
    scalar `q3' = r(r2)
    scalar `b' = (`q3' - `q1') * `d'
    if "`u'"!="" {
        tempname d1 d3
        mata: robstat_kdens_s(("`q1'", "`q3'"), ("`d1'", "`d3'"))
        qui replace `u' = `d' * ///
            ((.75 - (`v'<`q3'))/`d3' - (.25 - (`v'<`q1'))/`d1') if `touse'
    }
    return scalar b = `b'
    return scalar class = 2
end
program Estimate_iqrc
    Estimate_iqr `0' corr
end

program Estimate_mad, rclass
    syntax if [pw iw fw/], v(str) [ u(str) corr ///
        kernel(str) bw(str) adaptive(str) n(str) * ]
    if "`weight'"=="iweight" local pcwgt [aw = `exp']
    else if "`weight'"!=""   local pcwgt [`weight' = `exp']
    marksample touse
    tempname b med mad d
    scalar `d' = cond("`corr'"!="", 1/invnormal(0.75), 1)
    _pctile `v' `pcwgt' if `touse', percentiles(50)
    scalar `med' = r(r1)
    tempvar tmp
    qui generate double `tmp' = abs(`v' - `med') if `touse'
    _pctile `tmp' `pcwgt' if `touse', percentiles(50)
    scalar `mad' = r(r1)
    scalar `b' = `d' * `mad'
    if "`u'"!="" {
        tempname q1 q3 d1 d2 d3
        scalar `q1' = `med' - `mad'
        scalar `q3' = `med' + `mad'
        mata: robstat_kdens_s(("`q1'", "`med'", "`q3'"), ///
                              ("`d1'", "`d2'", "`d3'"))
        qui replace `u' = `d' * (sign(abs(`v'-`med') - `mad') - ///
            (`d3' - `d1')/`d2' * sign(`v' - `med')) / (2*(`d3'+`d1')) if `touse'
    }
    return scalar b = `b'
    return scalar class = 2
end
program Estimate_madn
    Estimate_mad `0' corr
end

program Estimate_qn, rclass
    syntax if [pw iw fw/], v(str) [ u(str) naive ///
        kernel(str) bw(str) adaptive(str) n(str) * ]
    if "`weight'"=="pweight" local swgt  [aw = `exp']
    else if "`weight'"!=""   local swgt  [`weight' = `exp']
    marksample touse
    tempname b d
    scalar `d' = 1/(sqrt(2) * invnormal(5/8))
    mata: robstat_estimate_pairwise("qn`naive'") // returns result in scalar b
    if "`u'"!="" {
        tempvar v1 v2 F1 F2 dvar
        qui generate double `v1'   = `v' + `b' if `touse'
        qui generate double `v2'   = `v' - `b' if `touse'
        qui generate double `F1'   = .
        qui generate double `F2'   = .
        qui generate double `dvar' = .
        mata: robstat_relrank(("`v1'", "`v2'"), ("`F1'", "`F2'"))
        mata: robstat_kdens_v("`v1'", "`dvar'")
        summarize `dvar' `swgt' if `touse', meanonly
        qui replace `u' = `d' * (.25 - `F1' + `F2') / r(mean) if `touse'
    }
    return scalar b = `d' * `b'
    return scalar class = 2
end
program Estimate_qnnaive
    Estimate_qn `0' naive
end
//     if (n<=9) {
//         d = d * (0.399, 0.994, 0.512, 0.844, 0.611, 0.857, 0.669, 0.872)[n-1]
//     }
//     else {
//         if (mod(n,2)) d = d * n/(n + 1/4)
//         else          d = d * n/(n + 3.8)
//     }

program Estimate_s, rclass
    syntax anything(name=p) if [pw iw fw/], v(str) [ u(str) ///
        tolerance(str) iterate(str) ///
        kernel(str) bw(str) adaptive(str) n(str) ]
    local p = substr("`p'", 2, .) // strip leading colon
    marksample touse
    tempname b k
    mata: robstat_estimate_m(`p', "scale", `tolerance', `iterate') 
        // returns result in b and k, fills in u
    return scalar b = `b'
    return scalar k = `k'
    return scalar class = 2
end

program Estimate_skewness, rclass
    syntax if [pw iw fw], v(str) [ u(str) * ]
    if "`weight'"=="pweight" local swgt  [aw`exp']
    else if "`weight'"!=""   local swgt  [`weight'`exp']
    qui su `v' `swgt' `if', detail
    tempname b
    scalar `b' = r(skewness)
    if (`b'>=.) scalar `b' = 0  // can happen if n=1
    else if "`u'"!="" {
        tempvar z
        qui generate double `z' = (`v'-r(mean))/r(sd) `if'
        qui replace `u' = `z'^3 - 3*`z' - `b' - `b'*(3/2)*(`z'^2-1) `if'
    }
    return scalar b = `b'
    return scalar class = 3
end

program Estimate_sk, rclass
    syntax anything(name=p1) if [pw iw fw/], v(str) [ u(str) ///
        kernel(str) bw(str) adaptive(str) n(str) * ]
    if "`weight'"=="iweight" local pcwgt [aw = `exp']
    else if "`weight'"!=""   local pcwgt [`weight' = `exp']
    local p1 = substr("`p1'", 2, .) // strip leading colon
    local p3 = 100 - `p1'
    marksample touse
    _pctile `v' `pcwgt' if `touse', percentiles(`p1' 50 `p3')
    tempname q1 q2 q3 b
    scalar `q1' = r(r1)
    scalar `q2' = r(r2)
    scalar `q3' = r(r3)
    scalar `b' = (`q1' + `q3' - 2*`q2') / (`q3' - `q1')
    if (`b'>=.) scalar `b' = 0  // can happen if n=1
    else if "`u'"!="" {
        tempname d1 d2 d3
        mata: robstat_kdens_s(("`q1'", "`q2'", "`q3'"), ("`d1'", "`d2'", "`d3'"))
        qui replace `u' = 2 * ///
            ((`q3'-`q2')*((`p1'/100-(`v'<`q1'))/`d1' - (.5-(`v'<`q2'))/`d2')  ///
           - (`q2'-`q1')*((.5-(`v'<`q2'))/`d2' - (`p3'/100-(`v'<`q3'))/`d3')) ///
            / (`q3' - `q1')^2 if `touse'
    }
    return scalar b = `b'
    return scalar class = 3
end

program Estimate_mc, rclass
    syntax if [pw iw fw/], V0(str) [ u(str) naive ///
        kernel(str) bw(str) adaptive(str) n(str) lmc rmc * ]
    if "`weight'"=="pweight" local swgt  [aw = `exp']
    else if "`weight'"!=""   local swgt  [`weight' = `exp']
    if "`weight'"=="iweight" local pcwgt [aw = `exp']
    else if "`weight'"!=""   local pcwgt [`weight' = `exp']
    marksample touse
    tempname v b q med
    if "`lmc'"!="" {
        _pctile `v0' `pcwgt' if `touse', percentiles(50)
        scalar `med' = r(r1)
        local touse0 `touse'
        tempvar touse
        qui gen byte `touse' = `touse0' & (`v0'<`med')
        qui count if `touse' 
        if r(N)<1 {
            return scalar b = 0
            exit
        }
        _pctile `v0' `pcwgt' if `touse', percentiles(50)
        scalar `q'   = r(r1)
        qui generate double `v' = (`q' - `v0') if `touse'
        mata: robstat_estimate_pairwise("mc`naive'") // sets scalar b
        local touse `touse0'
    }
    else if "`rmc'"!="" {
        _pctile `v0' `pcwgt' if `touse', percentiles(50)
        scalar `med' = r(r1)
        local touse0 `touse'
        tempvar touse
        qui gen byte `touse' = `touse0' & (`v0'>`med')
        qui count if `touse' 
        if r(N)<1 {
            return scalar b = 0
            exit
        }
        _pctile `v0' `pcwgt' if `touse', percentiles(50)
        scalar `q'   = r(r1)
        qui generate double `v' = `v0' - `q' if `touse'
        mata: robstat_estimate_pairwise("mc`naive'") // sets scalar b
        local touse `touse0'
    }
    else {
        _pctile `v0' `pcwgt' if `touse', percentiles(50)
        scalar `q' = r(r1)
        qui generate double `v' = `v0' - `q' if `touse'
        mata: robstat_estimate_pairwise("mc`naive'") // sets scalar b
    }
    if "`u'"!="" {
        if (abs(`b')==1) {
            di as txt "(mc = " `b' ": cannot compute standard errors)"
            return scalar b = `b'
            exit
        }
        tempvar g1 g2 F1 F2 dg
        tempname mc Idg dq dH gmed Fmed
        if "`lmc'"!="" {
            scalar `mc' = -`b'
            local v `v0'
        }
        else if "`rmc'"!="" {
            scalar `mc' = -`b'
            scalar `q' = -`q'
            scalar `med' = -`med'
            drop `v'
            qui generate `v' = -`v0' if `touse'
        }
        else {
            scalar `mc' = `b'
            scalar `med' = .
            local v `v0'
        }
        qui generate `g1'   = (`v'*(`mc'-1) + 2*`q') / (`mc'+1) if `touse'
        qui generate `g2'   = (`v'*(`mc'+1) - 2*`q') / (`mc'-1) if `touse'
        qui generate `F1'   = .
        qui generate `F2'   = .
        mata: robstat_relrank(("`g1'", "`g2'"), ("`F1'", "`F2'"))
        qui generate `dg' = .
        mata: robstat_kdens_v("`g1'", "`dg'")
        qui replace `dg' = `dg' * (`v'>=`q' & `v'<=`med') if `touse'
        summarize `dg' `swgt' if `touse', meanonly
        scalar `Idg' = r(mean)
        mata: robstat_kdens_s("`q'", "`dq'")
        if "`lmc'`rmc'"!="" {
            qui replace `g1' = 32 * `dg' * ((`q'-`v')/(`mc'+1)^2) if `touse'
        }
        else {
            qui replace `g1' = 8 * `dg' * ((`v'-`q')/(`mc'+1)^2) if `touse'
        }
        summarize `g1' `swgt' if `touse', meanonly
        scalar `dH' = r(mean)
        if (`dH'==0) {
            //di as txt "(mc: cannot estimate standard errors)"
        }
        else if "`lmc'`rmc'"!="" {
            scalar `gmed' = (`med'*(`mc'-1) + 2*`q') / (`mc'+1)
            mata: robstat_relrank_s("`gmed'", "`Fmed'")
            qui replace `u' = 1/`dH' * (1 ///
                - 16*`F1'*((`v'>`q' & `v'<`med')) ///
                - 16*(`F2'-.25)*(`v'>`gmed' & `v'<`q') ///
                - 4*(`v'<`gmed') ///
                - 8*sign(`v'-`med')*`Fmed' ///
                + (.25-(`v'<`q'))*(4 - 32*`Idg'/(`dq'*(`mc'+1)))) if `touse'
        }
        else {
            qui replace `u' = 1/`dH' * ///
                (1 - 4*`F1'*(`v'>`q') - 4*(`F2'-.5)*(`v'<`q') ///
                + sign(`v'-`q')*(1 - 4*`Idg'/(`dq'*(`mc'+1)))) if `touse'
        }
        capt assert (`u'<.) if `touse'
        if _rc {
            di as txt "(mc: IF = .; cannot compute standard errors)"
            qui replace `u' = 0 if `touse'
        }
    }
    return scalar b = `b'
    return scalar class = 3
end
program Estimate_mcnaive
    Estimate_mc `0' naive
end

program Estimate_kurtosis, rclass
    syntax if [pw iw fw], v(str) [ u(str) * ]
    if "`weight'"=="pweight" local swgt  [aw`exp']
    else if "`weight'"!=""   local swgt  [`weight'`exp']
    qui su `v' `swgt' `if', detail
    tempname b
    scalar `b' = r(kurtosis)
    if (`b'>=.) scalar `b' = 0  // can happen if n=1
    else if "`u'"!="" {
        tempvar z
        qui generate double `z' = (`v'-r(mean))/r(sd) `if'
        qui replace `u' = (`z'^2 - `b')^2 - `b'*(`b'-1) - 4*r(skewness)*`z' `if'
    }
    return scalar b = `b'
    return scalar class = 4
end

program Estimate_qw, rclass
    syntax anything(name=p) if [pw iw fw/], v(str) [ u(str) ///
        kernel(str) bw(str) adaptive(str) n(str) * ]
    if "`weight'"=="iweight" local pcwgt [aw = `exp']
    else if "`weight'"!=""   local pcwgt [`weight' = `exp']
    local p = substr("`p'", 2, .) // strip leading colon
    local p1 = `p'/2
    local p2 = `p'          // or should this be 25?
    local p3 = 50 - `p'/2
    local p4 = 50 + `p'/2
    local p5 = 100 - `p'    // or should this be 75?
    local p6 = 100 - `p'/2
    marksample touse
    _pctile `v' `pcwgt' if `touse', percentiles(`p1' `p2' `p3' `p4' `p5' `p6')
    tempname q1 q2 q3 q4 q5 q6 b
    scalar `q1' = r(r1)
    scalar `q2' = r(r2)
    scalar `q3' = r(r3)
    scalar `q4' = r(r4)
    scalar `q5' = r(r5)
    scalar `q6' = r(r6)
    scalar `b' = (`q6' - `q4' + `q3' - `q1')/ (`q5' - `q2')
    if (`q1'==`q3') scalar `b' = 0
    else if "`u'"!="" {
        tempname d1 d2 d3 d4 d5 d6
        mata: robstat_kdens_s(  ///
            ("`q1'", "`q2'", "`q3'", "`q4'", "`q5'", "`q6'"), ///
            ("`d1'", "`d2'", "`d3'", "`d4'", "`d5'", "`d6'"))
        qui replace `u' = ///
            ((`q5'-`q2')*((`p6'/100-(`v'<`q6'))/`d6' - (`p4'/100-(`v'<`q4'))/`d4'  ///
                        + (`p3'/100-(`v'<`q3'))/`d3' - (`p1'/100-(`v'<`q1'))/`d1') ///
            - (`q6' - `q4' + `q3' - `q1') * ///
              ((`p5'/100-(`v'<`q5'))/`d5' - (`p2'/100-(`v'<`q2'))/`d2')) ///
            / (`q5' - `q2')^2 if `touse'
    }
    return scalar b = `b'
    return scalar class = 4
end

program Estimate_lqw, rclass
    syntax anything(name=p) if [pw iw fw/], v(str) [ u(str) ///
        kernel(str) bw(str) adaptive(str) n(str) * ]
    if "`weight'"=="iweight" local pcwgt [aw = `exp']
    else if "`weight'"!=""   local pcwgt [`weight' = `exp']
    local p = substr("`p'", 2, .) // strip leading colon
    local p1 = `p'/2
    local p2 = 25
    local p3 = 50 - `p'/2
    marksample touse
    _pctile `v' `pcwgt' if `touse', percentiles(`p1' `p2' `p3')
    tempname q1 q2 q3 b
    scalar `q1' = r(r1)
    scalar `q2' = r(r2)
    scalar `q3' = r(r3)
    scalar `b' = - (`q1' + `q3' - 2*`q2') / (`q3' - `q1')
    if (`q1'==`q3') scalar `b' = 0
    else if "`u'"!="" {
        tempname d1 d2 d3
        mata: robstat_kdens_s(("`q1'", "`q2'", "`q3'"), ("`d1'", "`d2'", "`d3'"))
        qui replace `u' = 2 * ///
            ((`q2'-`q1')*((`p2'/100-(`v'<`q2'))/`d2' - (`p3'/100-(`v'<`q3'))/`d3')  ///
           - (`q3'-`q2')*((`p1'/100-(`v'<`q1'))/`d1' - (`p2'/100-(`v'<`q2'))/`d2')) ///
            / (`q3' - `q1')^2 if `touse'
    }
    return scalar b = `b'
    return scalar class = 4
end

program Estimate_rqw, rclass
    syntax anything(name=p) if [pw iw fw/], v(str) [ u(str) ///
        kernel(str) bw(str) adaptive(str) n(str) * ]
    if "`weight'"=="iweight" local pcwgt [aw = `exp']
    else if "`weight'"!=""   local pcwgt [`weight' = `exp']
    local p = substr("`p'", 2, .) // strip leading colon
    local p1 = 50 + `p'/2
    local p2 = 75
    local p3 = 100 - `p'/2
    marksample touse
    _pctile `v' `pcwgt' if `touse', percentiles(`p1' `p2' `p3')
    tempname q1 q2 q3 b
    scalar `q1' = r(r1)
    scalar `q2' = r(r2)
    scalar `q3' = r(r3)
    scalar `b' = (`q1' + `q3' - 2*`q2') / (`q3' - `q1')
    if (`q1'==`q3') scalar `b' = 0
    else if "`u'"!="" {
        tempname d1 d2 d3
        mata: robstat_kdens_s(("`q1'", "`q2'", "`q3'"), ("`d1'", "`d2'", "`d3'"))
        qui replace `u' = 2 * ///
            ((`q3'-`q2')*((`p1'/100-(`v'<`q1'))/`d1' - (`p2'/100-(`v'<`q2'))/`d2')  ///
           - (`q2'-`q1')*((`p2'/100-(`v'<`q2'))/`d2' - (`p3'/100-(`v'<`q3'))/`d3')) ///
            / (`q3' - `q1')^2 if `touse'
    }
    return scalar b = `b'
    return scalar class = 4
end

program Estimate_lmc
    Estimate_mc `0' lmc
end
program Estimate_lmcnaive
    Estimate_mc `0' naive lmc
end

program Estimate_rmc
    Estimate_mc `0' rmc
end
program Estimate_rmcnaive
    Estimate_mc `0' naive rmc
end

version 11
mata mata set matastrict on
mata:

void robstat_cilog()
{
    real scalar      i, n, scale
    string scalar    stat, note
    real rowvector   b, se, crit, ll, ul, type
    real matrix      table
    string vector    cstripe, rstripe
    
    table   = st_matrix("r(table)")
    cstripe = st_matrixcolstripe("r(table)")[,2]
    rstripe = st_matrixrowstripe("r(table)")[,2]
    type    = st_matrix("e(class)")
    b = se = ll = ul = crit = J(1, cols(table), .)
    n = rows(rstripe)
    for (i=1;i<=n;i++) {
        if      (rstripe[i]=="b")    b    = table[i,]
        else if (rstripe[i]=="se")   se   = table[i,]
        else if (rstripe[i]=="ll")   ll   = table[i,]
        else if (rstripe[i]=="ul")   ul   = table[i,]
        else if (rstripe[i]=="crit") crit = table[i,]
    }
    n = rows(cstripe)
    for (i=1;i<=n;i++) {
        if (type[i]==2) { // Scale statistic
            se[i] = se[i] :/ b[i]
            b[i]  = ln(b[i])
            ll[i] = exp(b[i] - crit[i] * se[i])
            ul[i] = exp(b[i] + crit[i] * se[i])
        }
    }
    st_matrix(st_local("CI"), ll \ ul)
    note = "log-transformed confidence interval"
    if (allof(type, 2)) {
        if (length(type)>1) note = note + "s"
    }
    else note = note + "s for scale statistics"
    st_local("cilognote", note)
}

// helper program to rearrange b and V
void _robstat_swap_eq_and_coefs(real scalar keq, real scalar kcoef)
{
    real scalar    i, j, k
    real colvector p
    string matrix  mstripe
    
    // anything to do?
    if (keq==1 & (st_local("over")=="" | st_local("nstats")=="1")) return
    // permutation vector
    p = J(keq*kcoef, 1, .)
    i = 0
    for (j=1;j<=kcoef;j++) {
        for (k=1;k<=keq;k++) {
            p[++i] = j + kcoef*(k-1)
        }
    }
    st_local("k_eq", st_local("k_coef"))
    st_local("k_coef", strofreal(keq))
    // rearrange labels
    mstripe = st_matrixcolstripe(st_local("b"))[p,(2,1)]
    // rearrange b
    st_replacematrix(st_local("b"), st_matrix(st_local("b"))[1,p])
    st_matrixcolstripe(st_local("b"), mstripe)
    // rearrange V
    if (st_local("V")!="") {
        st_replacematrix(st_local("V"), st_matrix(st_local("V"))[p,p])
        st_matrixcolstripe(st_local("V"), mstripe)
        st_matrixrowstripe(st_local("V"), mstripe)
    }
}

// M-estimation
void robstat_estimate_m(
    real scalar p, 
    string scalar obj, 
    real scalar tol, 
    real scalar iter)
{
    real scalar    pw, b, k
    string scalar  wtype
    real colvector x, w, u
    
    x = st_data(., st_local("v"), st_local("touse"))
    wtype = st_local("weight")
    if (wtype!="") {
        w = st_data(., st_local("exp"), st_local("touse"))
        if (wtype!="fweight") w = w :/ quadsum(w) * rows(w) // normalize weights
    }
    else w = 1
    pw = (wtype=="pweight")
    u  = (st_local("u")!="")
    pragma unset k // k (tuning constant) will be filled in
    if (obj=="scale") b = robstat_m_scale(x, w, p, tol, iter, pw, u, k)
    else              b = robstat_m(x, w, p, tol, iter, obj=="biweight", pw, u, k)
    st_numscalar(st_local("b"), b); st_numscalar(st_local("k"), k)
    if (st_local("u")!="") st_store(., st_local("u"), st_local("touse"), u)
}

// M-estimate of location
real scalar robstat_m(
    real colvector x, 
    real colvector w, 
    real scalar    eff,
    real scalar    tol,
    real scalar    iter,
    real scalar    biweight,
    real scalar    pw,
    real colvector u,
    real scalar    k)
{
    real scalar     b, b0, s, med, mad, i
    real colvector  W
    pointer(real scalar function) scalar f
    
    if (mm_isconstant(x)) {
        if (u) u = J(rows(x), 1, 0)
        return(x[1])
    }
    if (biweight) {
        k = _robstat_biweight_k(eff)
        f = &_robstat_biweight_w()
    }
    else {
        k = _robstat_huber_k(eff)
        f = &_robstat_huber_w()
    }
    s = _robstat_madn(x, w, med, mad) // scale estimate
    b = med
    W = (x :- b) / s
    for (i=1; i<=iter; i++) {
        b0 = b
        W = (*f)(W, k) :* w
        b = mean(x, W)
        if ((abs(b - b0) / s) < tol) break
        W = (x :- b) / s
    }
    if (i>=iter) _error(3360)
    if (u) {
        u = _robstat_m_IF(x, w, k, biweight, b, s, med, mad, pw)
    }
    return(b)
}
real colvector _robstat_m_IF(
    real colvector x,
    real colvector w,
    real scalar    k,
    real scalar    biweight,
    real scalar    b,
    real scalar    s,
    real scalar    med,
    real scalar    mad,
    real scalar    pw)
{
    real colvector d, u, y, yd
    pointer(real scalar function) scalar phi, psi

    if (biweight)  {
        psi = &_robstat_biweight_psi()
        phi = &_robstat_biweight_phi()
    }
    else {
        psi = &_robstat_huber_psi()
        phi = &_robstat_huber_phi()
    }
    // step 1: part of IF due to scale estimate
    d = robstat_kdens(x, w, pw, (med-mad, med, med+mad)')
    y = x :- med
    u = (sign(abs(y) :- mad) - (d[3] - d[1])/d[2] * sign(y)) ///
        / (2 * invnormal(0.75) * (d[3] + d[1]))
    // step 2: main part of IF (see Wilcox 2005:83)
    y = (x :- b)/s
    yd = (*phi)(y, k)
    u = (s * (*psi)(y, k) :- u * mean(yd:*y, w)) / mean(yd, w)
    return(u)
}

// M-estimate of scale
real scalar robstat_m_scale(
    real colvector x, 
    real colvector w, 
    real scalar    bp,
    real scalar    tol,
    real scalar    iter,
    real scalar    pw,
    real colvector u,
    real scalar    k)
{
    real scalar     s, s0, med, mad, i, delta
    
    if (mm_isconstant(x)) {
        if (u) u = J(rows(x), 1, 0)
        return(0)
    }
    k = _robstat_biweight_k_from_bp(bp)
    delta = bp/100 * k^2/6
    s = _robstat_madn(x, w, med, mad) // initial estimate
    // // biweight midvariance
    // real colvector y, a
    // y = (x:-med)/(9*mad)
    // a = abs(y):<1
    // sqrt(rows(x))*sqrt(sum(a:*(x:-med):^2:*(1:-y:^2):^4)) / abs(sum(a:*(1:-y:^2):*(1:-5*y:^2)))
    for (i=1; i<=iter; i++) {
        s0 = s
        s = sqrt(mean(_robstat_biweight_rho((x:-med)/s0, k), w) / delta) * s0
        if (abs(s/s0 - 1) <= tol) break
    }
    if (i>=iter) _error(3360)
    if (u) {
        u = _robstat_m_scale_IF(x, w, k, med, s, delta, pw)
    }
    return(s)
}
real colvector _robstat_m_scale_IF(
    real colvector x,
    real colvector w,
    real scalar    k,
    real scalar    med,
    real scalar    s,
    real scalar    delta,
    real scalar    pw)
{
    real colvector y, u, yd
    // step 1: part of IF due to location estimate
    u = sign(x :- med) * (1 / (2*robstat_kdens(x, w, pw, med)))
    // step 2: main part of IF
    y = (x :- med)/s
    yd = _robstat_biweight_psi(y, k)
    u = (s * (_robstat_biweight_rho(y, k) :- delta) :- 
        u * mean(yd, w)) / mean(yd:*y, w)
    return(u)
}

// Huber objective function
real colvector _robstat_huber_psi(real colvector x, real scalar k)
{
    real colvector d
    
    d = abs(x):<=k
    return(x:*d :+ (sign(x)*k):*(1:-d))
}
real colvector _robstat_huber_phi(real colvector x, real scalar k)
{
    return(abs(x):<= k)
}
real colvector _robstat_huber_w(real colvector x, real scalar k)
{
    return((k :/ abs(x)):^(1 :- (abs(x):<=k)))
}

// get Huber tuning constant for given efficiency
real scalar _robstat_huber_k(real scalar eff)
{
    if (eff==95) return(1.34499751)
    if (eff==90) return( .98180232)
    if (eff==85) return( .73173882)
    if (eff==80) return( .52942958)
    return(round(mm_finvert(eff/100, &_robstat_huber_eff(), 0.001, 3), 1e-8))
}
real scalar _robstat_huber_eff(real scalar k)
{
    return((normal(k)-normal(-k))^2 / 
        (2 * (k^2 * (1 - normal(k)) + normal(k) - 0.5 - k * normalden(k))))
}

// biweight objective function
real colvector _robstat_biweight_rho(real colvector x, real scalar k)
{
    real colvector x2

    x2 = (x / k):^2
    return(k^2/6 * (1 :- (1 :- x2):^3):^(x2:<=1))
}
real colvector _robstat_biweight_psi(real colvector x, real scalar k)
{
    real colvector x2

    x2 = (x / k):^2
    return((x :* (1 :- x2):^2) :* (x2:<=1))
}
real colvector _robstat_biweight_phi(real colvector x, real scalar k)
{
    real colvector x2

    x2 = (x / k):^2
    return(((1 :- x2) :* (1 :- 5*x2)) :* (x2:<=1))
}
real colvector _robstat_biweight_w(real colvector x, real scalar k)
{
    real colvector x2

    x2 = (x / k):^2
    return(((1 :- x2):^2) :* (x2:<=1))
}

// get biweight tuning constant for given efficiency
real scalar _robstat_biweight_k(real scalar eff0)
{
    real scalar k, eff
    
    if (eff0==95) return(4.6850649)
    if (eff0==90) return(3.8826616)
    if (eff0==85) return(3.4436898)
    if (eff0==80) return(3.1369087)
    eff = eff0/100
    k = 0.8376 + 1.499*eff + 0.7509*sin(1.301*eff^6) + 
        0.04945*eff/sin(3.136*eff) + 0.9212*eff/cos(1.301*eff^6)
    return(round(mm_finvert(eff, &_robstat_biweight_eff(), k/5, k*1.1), 1e-7))
}
real scalar _robstat_biweight_eff(real scalar k) // Simpson's rule integration
{
    real scalar    l, u, n, d, phi, psi2
    real colvector x, w
    
    l = 0; u = k; n = 1000; d = (u-l)/n 
    x = rangen(l, u, n+1)
    w = 1 \ colshape((J(n/2,1,4), J(n/2,1,2)), 1)
    w[n+1] = 1
    phi = 2 * (d / 3) * quadcolsum(_robstat_biweight_eff_phi(x, k):*w)
    psi2 = 2 * (d / 3) * quadcolsum(_robstat_biweight_eff_psi2(x, k):*w)
    return(phi^2 / psi2)
}
real matrix _robstat_biweight_eff_phi(real matrix x, real scalar k)
{
    real matrix x2

    x2 = (x / k):^2
    return(normalden(x) :* ((1 :- x2) :* (1 :- 5*x2)) :* (x2:<=1))
}
real matrix _robstat_biweight_eff_psi2(real matrix x, real scalar k)
{
    real matrix x2

    x2 = (x / k):^2
    return(normalden(x) :* ((x :* (1 :- x2):^2) :* (x2:<=1)):^2)
}

// get biweight tuning constant for given breakdown point
real scalar _robstat_biweight_k_from_bp(real scalar bp)
{
    if (bp==50) return(1.547645)
    return(round(mm_finvert(bp/100, &_robstat_biweight_bp(), 1.5, 18), 1e-7))
}
real scalar _robstat_biweight_bp(real scalar k) // Simpson's rule integration
{
    real scalar    l, u, n, d
    real colvector x, w

    l = 0; u = k; n = 1000; d = (u-l)/n
    x = rangen(l, u, n+1)
    w = 1 \ colshape((J(n/2,1,4), J(n/2,1,2)), 1)
    w[n+1] = 1
    return(2 * (normal(-k) +  d/3 *
        quadcolsum(normalden(x):*_robstat_biweight_rho(x, k):*w) / (k^2/6)))
}

// normalized MAD
real scalar _robstat_madn(real colvector x, real colvector w,
    real scalar med,    // will be replaced
    real scalar mad)    // will be replaced
{
    med = mm_median(x, w)
    mad = mm_median(abs(x :- med), w)
    return(mad/invnormal(0.75))
}

// Pairwise estimators
void robstat_estimate_pairwise(string scalar fname)
{
    string scalar  wtype
    real scalar    b
    real colvector x, w
    pointer(real scalar function) scalar f
    
    wtype = st_local("weight")
    if (wtype=="fweight") f = findexternal("robstat_" + fname + "_fw()")
    else if (wtype!="")   f = findexternal("robstat_" + fname + "_w()")
    else                  f = findexternal("robstat_" + fname + "()")
    x = st_data(., st_local("v"), st_local("touse"))
    if (wtype!="") {
        w = st_data(., st_local("exp"), st_local("touse"))
        b = (*f)(x, w)
    }
    else b = (*f)(x)
    st_numscalar(st_local("b"), b)
}

// HL estimator
real scalar robstat_hl(real colvector x) // changes x
{
    // the trick of this algorithm is to consider only elements that are on the 
    // right of the main diagonal
    real scalar     i, j, m, k, n, nl, nr, nL, nR, trial
    real colvector  xx, /*ww,*/ l, r, L, R
    
    n = rows(x)                    // dimension of search matrix
    if (n==1) return(x)            // returning observed value if n=1
    _sort(x, 1)                    // sorted data
    xx      = /*ww =*/ J(n, 1, .)  // temp vector for matrix elements
    l = L   = (1::n):+1            // indices of left boundary (old and new)
    r = R   = J(n, 1, n)           // indices of right boundary (old and new)
    nl = nl = n + comb(n, 2)       // number of cells below left boundary
    nr = nR = n * n                // number of cells within right boundary
    k       = nl + comb(n, 2)/2    // target quantile
    while ((nr-nl)>n) {
        // get trial value
        m = 0
        for (i=1; i<n; i++) { // last row cannot contain candidates
            if (l[i]<=r[i]) {
                // high median within row
                xx[++m] = _robstat_hl_el(x, i, l[i]+trunc((r[i]-l[i]+1)/2))
                /*m++
                ww[m] = r[i] - l[i] + 1
                xx[m] = _robstat_hl_el(x, i, l[i]+trunc(ww[m]/2))*/
            }
        }
        trial = robstat_hiquantile(xx[|1 \ m|], .5)
        /*trial = robstat_hiquantile_w(xx[|1 \ m|], ww[|1 \ m|], .5)*/
        /*the unweighted quantile is faster; results are the same*/
        // move right border
        j = n-1
        for (i=(n-1); i>=1; i--) {
            if (i==j) {
                if (_robstat_hl_el(x, i, j)>=trial) {
                    R[i] = j
                    j = i-1
                    continue
                }
            }
            if (j<n) {
                while (_robstat_hl_el(x, i, j+1)<trial) {
                    j++
                    if (j==n) break
                }
            }
            R[i] = j
        }
        nR = sum(R)
        if (nR>k) {
            swap(r, R)
            nr = nR
            continue
        }
        // move left border
        j = n + 1
        for (i=1; i<=n; i++) {
            if (j>(i+1)) {
                while (_robstat_hl_el(x, i, j-1)>trial) {
                    j--
                    if (j==(i+1)) break
                }
            }
            if (j<(i+1)) j = (i+1)
            L[i] = j
        }
        nL = sum(L) - n
        if (nL<k) {
            swap(l, L)
            nl = nL
            continue
        }
        // trial = low quantile = high quantile
        if (ceil(k)!=k | (nR<k & nL>k)) return(trial)
        // trial = low quantile
        if (nL==k) {
            m = 0
            for (i=1; i<=n; i++) {
                if (L[i]>n) continue
                xx[++m] = _robstat_hl_el(x, i, L[i])
            }
            return((trial+min(xx[|1 \ m|]))/2)
        }
        // trial = high quantile
        m = 0
        for (i=1; i<=n; i++) {
            if (R[i]<=i) continue
            xx[++m] = _robstat_hl_el(x, i, R[i])
        }
        return((trial+max(xx[|1 \ m|]))/2)
    }
    // get target value from remaining candidates
    m = 0
    for (i=1; i<n; i++) { // last row cannot contain candidates
        if (l[i]<=r[i]) {
            for (j=l[i]; j<=r[i]; j++) {
                m++
                xx[m] = _robstat_hl_el(x, i, j)
            }
        }
    }
    return(robstat_quantile(xx[|1 \ m|], k, nl))
}
real scalar _robstat_hl_el(real colvector y, real scalar i, real scalar j)
{
    return((y[i] + y[j])/2)
}

real scalar robstat_hl_w(real colvector x, real colvector w) // changes x and w
{
    real scalar     i, j, m, k, n, nl, nr, trial, Wl, WR, WL, W0, W1
    real colvector  xx, ww, l, r, L, R, p, ccw
    
    n       = rows(x)              // dimension of search matrix
    if (n==1) return(x)            // returning observed value if n=1
    p       = order(x, 1)          // sort order
    x       = x[p]                 // sorted data
    w       = w[p]                 // row weights
    xx = ww = J(n, 1, .)           // temp vector for matrix elements
    l = L   = (1::n):+1            // indices of left boundary (old and new)
    r = R   = J(n, 1, n)           // indices of right boundary (old and new)
    nl      = comb(n, 2) + n       // number of cells below left boundary
    nr      = n * n                // number of cells within right boundary
    ccw     = quadrunningsum(w)    // cumulative column weights
    W1      = quadsum(w[|2 \ .|] :* ccw[|1 \ n-1|]) // sum of weights in target triangle
    W0      = W1 + quadsum(w:*w)   // sum of weights in rest of search matrix
    Wl = WL = W0                   // sum of weights below left boundary
    WR      = W0 + W1              // sum of weights within right boundary
    k       = W0 + W1/2            // target quantile
    while ((nr-nl)>n) {
        // get trial value
        m = 0
        for (i=1; i<n; i++) { // last row cannot contain candidates
            if (l[i]<=r[i]) {
                // high median within row
                xx[++m] = _robstat_hl_el(x, i, l[i]+trunc((r[i]-l[i]+1)/2))
            }
        }
        trial = robstat_hiquantile(xx[|1 \ m|], .5)
        // move right border
        j = n-1
        for (i=(n-1); i>=1; i--) {
            if (i==j) {
                if (_robstat_hl_el(x, i, j)>=trial) {
                    R[i] = j
                    j = i-1
                    continue
                }
            }
            if (j<n) {
                while (_robstat_hl_el(x, i, j+1)<trial) {
                    j++
                    if (j==n) break
                }
            }
            R[i] = j
        }
        WR = quadsum(w:*ccw[R])
        if (WR>k) {
            swap(r, R)
            nr = sum(R)
            continue
        }
        // move left border
        j = n + 1
        for (i=1; i<=n; i++) {
            if (j>(i+1)) {
                while (_robstat_hl_el(x, i, j-1)>trial) {
                    j--
                    if (j==(i+1)) break
                }
            }
            if (j<(i+1)) j = (i+1)
            L[i] = j
        }
        WL = quadsum(w:*ccw[L:-1])
        if (WL<k) {
            swap(l, L)
            Wl = WL
            nl = sum(L) - n
            continue
        }
        // trial = low quantile = high quantile
        if (WR==WL | (WR<k & WL>k)) return(trial)
        // trial = low quantile
        if (WL==k) {
            m = 0
            for (i=1; i<=n; i++) {
                if (L[i]>n) continue
                xx[++m] = _robstat_hl_el(x, i, L[i])
            }
            return((trial+min(xx[|1 \ m|]))/2)
        }
        // trial = high quantile
        m = 0
        for (i=1; i<=n; i++) {
            if (R[i]<=i) continue
            xx[++m] = _robstat_hl_el(x, i, R[i])
        }
        return((trial+max(xx[|1 \ m|]))/2)
    }
    // get target value from remaining candidates
    m = 0
    for (i=1; i<n; i++) { // last row cannot contain candidates
        if (l[i]<=r[i]) {
            for (j=l[i]; j<=r[i]; j++) {
                m++
                xx[m] = _robstat_hl_el(x, i, j)
                ww[m] = w[i] * w[j]
            }
        }
    }
    return(robstat_quantile_w(xx[|1 \ m|], ww[|1 \ m|], k, Wl))
}

real scalar robstat_hl_fw(real colvector x, real colvector w) // changes x and w
{   // the algorithm "duplicates" the diagonal so that the relevant pairs in 
    // case of w>1 can be taken into account
    real scalar     i, j, m, k, n, nl, nr, trial, Wl, WR, WL, W0, W1
    real colvector  xx, ww, l, r, L, R, p, ccw, wcorr, idx
    
    n       = rows(x)          // dimension of search matrix
    if (n==1) return(x)        // returning observed value if n=1
    p       = order(x, 1)      // sort order
    x       = x[p]             // sorted data
    w       = w[p]             // row weights
    xx = ww = J(n, 1, .)       // temp vector for matrix elements
    ccw     = runningsum(w)    // cumulative column weights
    wcorr   = mm_cond(w:<=1, 0, comb(w, 2)) // correction of weights
    idx     = 1::n             // diagonal indices
    l = L   = idx :+ 1 :+ (wcorr:==0) // indices of left boundary (old and new)
    r = R   = J(n, 1, n+1)     // indices of right boundary (old and new)
    nl      = comb(n, 2) + n + sum(wcorr:==0) // n. of cells below left boundary
    nr      = n * (n+1)        // number of cells within right boundary
    W0 = W1 = sum(w[|2 \ .|] :* ccw[|1 \ n-1|])
    W1      = W1 + sum(wcorr)  // sum of weights in target triangle
    W0      = W0 + sum(w) + sum(wcorr) // sum of weights in rest of search matrix
    Wl = WL = W0               // sum of weights below left boundary
    WR      = W0 + W1          // sum of weights within right boundary
    k       = W0 + W1/2        // target quantile
    while ((nr-nl)>n) {
        // get trial value
        m = 0
        for (i=1; i<=n; i++) {
            if (l[i]<=r[i]) {
                // high median within row
                xx[++m] = _robstat_hl_el(x, i, 
                    (l[i]-1) + trunc(((r[i]-1)-(l[i]-1)+1)/2))
            }
        }
        trial = robstat_hiquantile(xx[|1 \ m|], .5)
        // move right border
        j = n
        for (i=n; i>=1; i--) {
            if (j==i) {
                if (_robstat_hl_el(x, i, j)>=trial) {
                    R[i] = j + (wcorr[i]==0)
                    j = i-1
                    continue
                }
            }
            if (j<=n) {
                while (_robstat_hl_el(x, i, (j+1)-((j+1)>i))<trial) {
                    j++
                    if (j>n) break
                }
            }
            R[i] = j
        }
        WR = sum(w:*ccw[R:-(R:>idx)]) - sum(wcorr:*(R:==idx))
        if (WR>k) {
            swap(r, R)
            nr = sum(R)
            continue
        }
        // move left border
        j = n + 2
        for (i=1; i<=n; i++) {
            if (j>(i+1)) {
                while (_robstat_hl_el(x, i, (j-1)-((j-1)>i))>trial) {
                    j--
                    if (j==(i+1)) break
                }
            }
            if (j<(i+1)) j = (i+1)
            if (j==(i+1)) {
                if (wcorr[i]==0) j++
            }
            L[i] = j
        }
        WL = sum(w:*ccw[L:-1:-((L:-1):>idx)]) - sum(wcorr:*((L:-1):==idx))
        if (WL<k) {
            swap(l, L)
            Wl = WL
            nl = sum(L) - n
            continue
        }
        // trial = low quantile = high quantile
        if (ceil(k)!=k | (WR<k & WL>k)) return(trial)
        // trial = low quantile
        if (WL==k) {
            m = 0
            for (i=1; i<=n; i++) {
                if ((L[i]-(L[i]>i))>n) continue
                xx[++m] = _robstat_hl_el(x, i, L[i]-(L[i]>i))
            }
            return((trial+min(xx[|1 \ m|]))/2)
        }
        // trial = high quantile
        m = 0
        for (i=1; i<=n; i++) {
            if (R[i]<=i) continue
            if (R[i]==i+1) {
                if (wcorr[i]==0) continue
            }
            xx[++m] = _robstat_hl_el(x, i, R[i]-1)
        }
        return((trial+max(xx[|1 \ m|]))/2)
    }
    // get target value from remaining candidates
    m = 0
    for (i=1; i<=n; i++) {
        if (l[i]<=r[i]) {
            for (j=l[i]; j<=r[i]; j++) {
                m++
                xx[m] = _robstat_hl_el(x, i, j-1)
                ww[m] = (i==(j-1) ? comb(w[i], 2) : w[i]*w[j-1])
            }
        }
    }
    return(robstat_quantile_w(xx[|1 \ m|], ww[|1 \ m|], k, Wl))
}

real scalar robstat_hlnaive(real colvector x)
{
    real scalar    i, j, m, n
    real colvector xx
    
    n = rows(x)
    if (n==1) return(x) // HL undefined if n=1; returning observed value
    m = 0
    xx = J(comb(n,2), 1, .)
    for (i=1; i<n; i++) {
        for (j=(i+1); j<=n; j++) {
            xx[++m] = _robstat_hl_el(x, i, j)
        }
    }
    return(robstat_quantile(xx, .5))
}

real scalar robstat_hlnaive_w(real colvector x, real colvector w)
{
    real scalar    i, j, m, n
    real colvector xx, ww

    n = rows(x)
    if (n==1) return(x) // HL undefined if n=1; returning observed value
    m = 0
    xx = J(comb(n,2), 1, .)
    ww = J(rows(xx), 1, .)
    for (i=1; i<n; i++) {
        for (j=(i+1); j<=n; j++) {
            m++
            xx[m] = _robstat_hl_el(x, i, j)
            ww[m] = w[i]*w[j]
        }
    }
    return(robstat_quantile_w(xx, ww, .5))
}

real scalar robstat_hlnaive_fw(real colvector x, real colvector w)
{
    real scalar    i, j, m, n
    real colvector xx, ww

    n = rows(x)
    if (n==1) return(x) // HL undefined if n=1; returning observed value
    m = 0
    xx = J(comb(n,2)+sum(w:>1), 1, .)
    ww = J(rows(xx), 1, .)
    for (i=1; i<=n; i++) {
        for (j=i; j<=n; j++) {
            if (i==j) {
                if (w[i]==1) continue
            }
            m++
            xx[m] = _robstat_hl_el(x, i, j)
            ww[m] = (i==j ? comb(w[i], 2) : w[i]*w[j])
        }
    }
    return(robstat_quantile_w(xx, ww, .5))
}

// Qn estimator
real scalar robstat_qn(real colvector x) // changes x
{
    real scalar     i, j, m, k, n, nl, nr, nL, nR, trial
    real colvector  xx, /*ww,*/ l, r, L, R

    n = rows(x)                    // dimension of search matrix
    if (n==1) return(0)            // returning zero if n=1
    _sort(x, 1)                    // sorted data
    xx      = /*ww =*/ J(n, 1, .)  // temp vector for matrix elements
    l = L   = (n::1):+1            // indices of left boundary (old and new)
    r = R   = J(n, 1, n)           // indices of right boundary (old and new)
    nl = nl = comb(n, 2) + n       // number of cells below left boundary
    nr = nR = n * n                // number of cells within right boundary
    k       = nl + comb(n, 2)/4    // target quantile
    /*k = nl + comb(trunc(n/2) + 1, 2)*/
    while ((nr-nl)>n) {
        // get trial value
        m = 0
        for (i=2; i<=n; i++) { // first row cannot contain candidates
            if (l[i]<=r[i]) {
                // high median within row
                xx[++m] = _robstat_qn_el(x, i, l[i]+trunc((r[i]-l[i]+1)/2), n)
                /*m++
                ww[m] = r[i] - l[i] + 1
                xx[m] = _robstat_qn_el(x, i, l[i]+trunc(www[m]/2), n)*/
            }
        }
        trial = robstat_hiquantile(xx[|1 \ m|], .5)
        /*trial = robstat_hiquantile_w(xx[|1 \ m|], ww[|1 \ m|], .5)*/
        /*the unweighted quantile is faster; results are the same*/
        //move right border
        j = 0
        for (i=n; i>=1; i--) {
            if (j<n) {
                while (_robstat_qn_el(x, i, j+1, n)<trial) {
                    j++
                    if (j==n) break
                }
            }
            R[i] = j
        }
        nR = sum(R)
        if (nR>k) {
            swap(r, R)
            nr = nR
            continue
        }
        // move left border
        j = n + 1
        for (i=1; i<=n; i++) {
            while (_robstat_qn_el(x, i, j-1, n)>trial) {
                j--
            }
            L[i] = j
        }
        nL = sum(L) - n
        if (nL<k) {
            swap(l, L)
            nl = nL
            continue
        }
        // trial = low quantile = high quantile
        if (ceil(k)!=k | (nR<k & nL>k)) return(trial)
        // trial = low quantile
        if (nL==k) {
            m = 0
            for (i=1; i<=n; i++) {
                if (L[i]>n) continue
                xx[++m] = _robstat_qn_el(x, i, L[i], n)
            }
            return((trial+min(xx[|1 \ m|]))/2)
        }
        // trial = high quantile
        for (i=1; i<=n; i++) {
            xx[i] = _robstat_qn_el(x, i, R[i], n)
        }
        return((trial+max(xx))/2)
    }
    // get target value from remaining candidates
    m = 0
    for (i=2; i<=n; i++) { // first row cannot contain candidates
        if (l[i]<=r[i]) {
            for (j=l[i]; j<=r[i]; j++) {
                m++
                xx[m] = _robstat_qn_el(x, i, j, n)
            }
        }
    }
    return(robstat_quantile(xx[|1 \ m|], k, nl))
}
real scalar _robstat_qn_el(real colvector y, real scalar i, real scalar j, 
    real scalar n)
{
    return(y[i] - y[n-j+1])
}

real scalar robstat_qn_w(real colvector x, real colvector w) // changes x and w
{
    real scalar     i, j, m, k, n, nl, nr, trial, Wl, WR, WL, W0, W1
    real colvector  xx, ww, l, r, L, R, p, ccw

    n       = rows(x)              // dimension of search matrix
    if (n==1) return(0)            // returning zero if n=1
    p       = order(x, 1)          // sort order (will be replaced)
    x       = x[p]                 // sorted data
    w       = w[p]                 // row weights
    xx = ww = J(n, 1, .)           // temp vector for matrix elements
    l = L   = (n::1):+1            // indices of left boundary (old and new)
    r = R   = J(n, 1, n)           // indices of right boundary (old and new)
    nl      = comb(n, 2) + n       // number of cells below left boundary
    nr      = n * n                // number of cells within right boundary
    ccw     = quadrunningsum(w[n::1]) // cumulative column weights
    W0      = quadsum(w:*ccw[n::1]) // sum weights in rest of search matrix
    W1      = quadsum(w:*ccw[rows(ccw)]) - W0 // sum of weights target triangle
    Wl = WL = W0                   // sum of weights below left boundary
    WR      = W0 + W1              // sum of weights within right boundary
    k       = W0 + W1/4            // target sum (high 25% quantile)
    while ((nr-nl)>n) {
        // get trial value
        m = 0
        for (i=2; i<=n; i++) { // first row cannot contain candidates
            if (l[i]<=r[i]) {
                // high median within row
                xx[++m] = _robstat_qn_el(x, i, l[i]+trunc((r[i]-l[i]+1)/2), n)
            }
        }
        trial = robstat_hiquantile(xx[|1 \ m|], .5)
        //move right border
        j = 0
        for (i=n; i>=1; i--) {
            if (j<n) {
                while (_robstat_qn_el(x, i, j+1, n)<trial) {
                    j++
                    if (j==n) break
                }
            }
            R[i] = j
        }
        p = (R:>0)
        WR = quadsum(select(w, p) :* ccw[select(R, p)])
        if (WR>k) {
            swap(r, R)
            nr = sum(R)
            continue
        }
        // move left border
        j = n + 1
        for (i=1; i<=n; i++) {
            while (_robstat_qn_el(x, i, j-1, n)>trial) {
                j--
            }
            L[i] = j
        }
        WL = quadsum(w :* ccw[L:-1])
        if (WL<k) {
            swap(l, L)
            Wl = WL
            nl = sum(L) - n
            continue
        }
        // trial = low quantile = high quantile
        if (WR==WL | (WR<k & WL>k)) return(trial)
        // trial = low quantile
        if (WL==k) {
            m = 0
            for (i=1; i<=n; i++) {
                if (L[i]>n) continue
                xx[++m] =  _robstat_qn_el(x, i, L[i], n)
            }
            return((trial+min(xx[|1 \ m|]))/2)
        }
        // trial = high quantile
        for (i=1; i<=n; i++) {
            xx[i] = _robstat_qn_el(x, i, R[i], n)
        }
        return((trial+max(xx))/2)
    }
    // get target value from remaining candidates
    m = 0
    for (i=2; i<=n; i++) { // first row cannot contain candidates
        if (l[i]<=r[i]) {
            for (j=l[i]; j<=r[i]; j++) {
                m++
                xx[m] = _robstat_qn_el(x, i, j, n)
                ww[m] = w[i] * w[n-j+1]
            }
        }
    }
    return(robstat_quantile_w(xx[|1 \ m|], ww[|1 \ m|], k, Wl))
}

real scalar robstat_qn_fw(real colvector x, real colvector w) // changes x and w
{
    real scalar     i, j, m, k, n, nl, nr, trial, Wl, WR, WL, W0, W1
    real colvector  xx, ww, l, r, L, R, p, ccw, wcorr, idx

    n       = rows(x)              // dimension of search matrix
    if (n==1) return(0)            // returning zero if n=1
    p       = order(x, 1)          // sort order (will be replaced)
    x       = x[p]                 // sorted data
    w       = w[p]                 // row weights
    xx = ww = J(n, 1, .)           // temp vector for matrix elements
    idx     = n::1                 // (minor) diagonal indices
    l = L   = idx:+1               // indices of left boundary (old and new)
    r = R   = J(n, 1, n+1)         // indices of right boundary (old and new)
    nl      = comb(n, 2) + n       // number of cells below left boundary
    nr      = n * (n+1)            // number of cells within right boundary
    ccw     = runningsum(w[idx])   // cumulative column weights
    wcorr   = mm_cond(w:<=1, 0, comb(w, 2))[idx] // correction of weights
    W0      = sum(w:*ccw[idx]) - sum(wcorr) // sum of weights in rest of search matrix
    W1      = sum(w:*ccw[rows(ccw)]) - W0 // sum of weights in target triangle
    Wl = WL = W0                   // sum of weights below left boundary
    WR      = W0 + W1              // sum of weights within right boundary
    k       = W0 + W1/4            // target quantile
    while ((nr-nl)>n) {
        // get trial value
        m = 0
        for (i=1; i<=n; i++) {
            if (l[i]<=r[i]) {
                // high median within row
                xx[++m] = _robstat_qn_el(x, i, 
                    (l[i]-1)+trunc(((r[i]-1)-(l[i]-1)+1)/2), n)
            }
        }
        trial = robstat_hiquantile(xx[|1 \ m|], .5)
        //move right border
        j = 0
        for (i=n; i>=1; i--) {
            if (j<=n) {
                while (_robstat_qn_el(x, i, (j+1)-((j+1)>(n-i+1)), n)<trial) {
                    j++
                    if (j>n) break
                }
            }
            R[i] = j
        }
        p = (R:>0)
        WR = sum(select(w, p) :* ccw[select(R:-(R:>idx), p)]) - sum(wcorr:*(R:==idx))
        if (WR>k) {
            swap(r, R)
            nr = sum(R)
            continue
        }
        // move left border
        j = n + 2
        for (i=1; i<=n; i++) {
            while (_robstat_qn_el(x, i, (j-1)-((j-1)>(n-i+1)), n)>trial) {
                j--
            }
            L[i] = j
        }
        WL = sum(w:*ccw[L:-1:-((L:-1):>idx)]) - sum(wcorr:*((L:-1):==idx))
        if (WL<k) {
            swap(l, L)
            Wl = WL
            nl = sum(L) - n
            continue
        }
        // trial = low quantile = high quantile
        if (ceil(k)!=k | (WR<k & WL>k)) return(trial)
        // trial = low quantile
        if (WL==k) {
            m = 0
            for (i=1; i<=n; i++) {
                if ((L[i]-(L[i]>(n-i+1)))>n) continue
                xx[++m] = _robstat_qn_el(x, i, L[i]-(L[i]>(n-i+1)), n)
            }
            return((trial+min(xx[|1 \ m|]))/2)
        }
        // trial = high quantile
        for (i=1; i<=n; i++) {
            xx[i] = _robstat_qn_el(x, i, R[i]-(R[i]>(n-i+1)), n)
        }
        return((trial+max(xx))/2)
    }
    // get target value from remaining candidates
    m = 0
    for (i=1; i<=n; i++) {
        if (l[i]<=r[i]) {
            for (j=l[i]; j<=r[i]; j++) {
                m++
                xx[m] = _robstat_qn_el(x, i, j-1, n)
                ww[m] = ((n-i+1)==(j-1) ? comb(w[i], 2) : w[i]*w[n-(j-1)+1])
            }
        }
    }
    return(robstat_quantile_w(xx[|1 \ m|], ww[|1 \ m|], k, Wl))
}

real scalar robstat_qnnaive(real colvector x)
{
    real scalar    i, j, m, n
    real colvector xx
    
    n = rows(x)
    if (n==1) return(0) // returning zero if n=1
    m = 0
    xx = J(comb(n,2), 1, .)
    for (i=1; i<n; i++) {
        for (j=(i+1); j<=n; j++) {
            xx[++m] = abs(x[i] - x[j])
        }
    }
    return(robstat_quantile(xx, 0.25))
}

real scalar robstat_qnnaive_w(real colvector x, real colvector w)
{
    real scalar    i, j, m, n
    real colvector xx, ww
    
    n = rows(x)
    if (n==1) return(0) // Qn undefined if n=1; returning zero
    m = 0
    xx = J(comb(n,2), 1, .)
    ww = J(rows(xx), 1, .)
    for (i=1; i<n; i++) {
        for (j=(i+1); j<=n; j++) {
            m++
            xx[m] = abs(x[i] - x[j])
            ww[m] = w[i]*w[j]
        }
    }
    return(robstat_quantile_w(xx, ww, 0.25))
}

real scalar robstat_qnnaive_fw(real colvector x, real colvector w)
{
    real scalar    i, j, m, n
    real colvector xx, ww

    n = rows(x)
    if (n==1) return(0) // returning zero if n=1
    m = 0
    xx = J(comb(n,2)+sum(w:>1), 1, .)
    ww = J(rows(xx), 1, .)
    for (i=1; i<=n; i++) {
        for (j=i; j<=n; j++) {
            if (i==j) {
                if (w[i]==1) continue
            }
            m++
            xx[m] = abs(x[i] - x[j])
            ww[m] = (i==j ? comb(w[i], 2) : w[i]*w[j])
        }
    }
    return(robstat_quantile_w(xx, ww, 0.25))
}

real scalar robstat_mc(real colvector x) // changes x, assumes med(x)=0
{
    real scalar     i, j, m, k, n, q, nl, nr, nL, nR, trial, npos, nzero
    real colvector  xx, /*ww,*/ l, r, L, R, xpos, xneg

    if (rows(x)<=1) return(0)      // returning zero if n=1
    _sort(x, -1)
    xpos    = select(x, x:>0)      // obervations > median
    npos    = rows(xpos)           // number of obs > median
    xneg    = select(x, x:<0)      // observations < median
    nzero   = sum(x:==0)           // number of obs = median
    n       = npos + nzero         // number of rows in search matrix
    q       = rows(xneg) + nzero   // number of columns in search matrix
    xx      = /*ww =*/ J(n, 1, .)  // temp vector for matrix elements
    l = L   = J(n, 1, 1)           // indices of left boundary (old and new)
    r = R   = J(n, 1, q)           // indices of right boundary (old and new)
    nl = nL = 0                    // number of cells below left boundary
    nr = nR = n * q                // number of cells within right boundary
    k       = n*q/2                // target quantile
    while ((nr-nl)>n) {
        // get trial value
        m = 0
        for (i=1; i<=n; i++) {
            if (l[i]<=r[i]) {
                // high median within row
                xx[++m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i,
                           l[i]+trunc((r[i]-l[i]+1)/2))
                /*m++
                ww[m] = r[i] - l[i] + 1
                xx[m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i,
                          l[i]+trunc((ww[m])/2))*/
            }
        }
        trial = robstat_hiquantile(xx[|1 \ m|], .5)
        /*the unweighted quantile is faster; results are the same*/
        /*trial = robstat_hiquantile_w(xx[|1 \ m|], ww[|1 \ m|], .5)*/
        // move right border
        j = 0
        for (i=n; i>=1; i--) {
            if (j<q) {
                while (-_robstat_mc_el(xpos, xneg, npos, nzero, i, j+1)<trial) {
                    j++
                    if (j==q) break
                }
            }
            R[i] = j
        }
        nR = sum(R)
        if (nR>k) {
            swap(r, R)
            nr = nR
            continue
        }
        // move left border
        j = q + 1
        for (i=1; i<=n; i++) {
            while (-_robstat_mc_el(xpos, xneg, npos, nzero, i, j-1)>trial) {
                j--
            }
            L[i] = j
        }
        nL = sum(L) - n
        if (nL<k) {
            swap(l, L)
            nl = nL
            continue
        }
        // trial = low quantile = high quantile
        if (ceil(k)!=k | (nR<k & nL>k)) return(-trial)
        // trial = low quantile
        if (nL==k) {
            m = 0
            for (i=1; i<=n; i++) {
                if (L[i]>q) continue
                xx[++m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i, L[i])
            }
            return(-(trial+min(xx[|1 \ m|]))/2)
        }
        // trial = high quantile
        for (i=1; i<=n; i++) {
            xx[i] = -_robstat_mc_el(xpos, xneg, npos, nzero, i, R[i])
        }
        return(-(trial+max(xx))/2)
    }
    // get target value from remaining candidates
    m = 0
    for (i=1; i<=n; i++) {
        if (l[i]<=r[i]) {
            for (j=l[i]; j<=r[i]; j++) {
                m++
                xx[m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i, j)
            }
        }
    }
    return(-robstat_quantile(xx[|1 \ m|], k, nl))
}
real scalar _robstat_mc_el(real colvector xpos, real colvector xneg, 
    real scalar npos, real scalar nzero, real scalar i, real scalar j)
{
    if (i<=npos) {
        if (j<=nzero) return(1)
        // => (j>nzero)
        return((xpos[i] + xneg[j-nzero])/(xpos[i] - xneg[j-nzero]))
    }
    // => (i>npos)
    if (j>nzero)  return(-1)
    // => (j<=nzero)
    return(sign((npos+nzero-i+1)-j))
}

real scalar robstat_mc_w(real colvector x, real colvector w) 
{   // changes x and w, assumes med(x)=0
    real scalar     i, j, m, k, n, q, nl, nr, trial, npos, nzero, Wl, WR, WL, W
    real colvector  xx, ww, l, r, L, R, p, ccw, xpos, xneg, wpos, wneg, wzero

    if (rows(x)<=1) return(0)      // returning zero if n=1
    p       = order(x, -1)         // sort order (will be replaced)
    x       = x[p]                 // sorted data
    w       = w[p]                 // row weights
    p = (x:>0)
    xpos    = select(x, p)         // obervations > median
    wpos    = select(w, p)         // weights of obervations >= median
    npos    = rows(xpos)           // number of obs > median
    p = (x:<0)
    xneg    = select(x, p)         // observations < median
    wneg    = select(w, p)         // weights of obervations <= median
    wzero   = select(w, x:==0)     // weights of obervations = median
    nzero   = rows(wzero)          // number of obs = median
    if (nzero>0) {
        wpos = wpos \ wzero
        wneg = wzero[nzero::1] \ wneg // need to use reverse ordered wzero
    }
    n       = npos + nzero         // number of rows in search matrix
    q       = rows(xneg) + nzero   // number of columns in search matrix
    xx = ww = J(n, 1, .)           // temp vector for matrix elements
    l = L   = J(n, 1, 1)           // indices of left boundary (old and new)
    r = R   = J(n, 1, q)           // indices of right boundary (old and new)
    nl      = 0                    // number of cells below left boundary
    nr      = n * q                // number of cells within right boundary
    ccw     = quadrunningsum(wneg) // cumulative column weights
    W       = quadsum(wpos:*ccw[rows(ccw)]) // sum of weights in search matrix
    Wl = WL = 0                    // sum of weights below left boundary
    WR      = W                    // sum of weights within right boundary
    k       = W/2                  // target quantile
    while ((nr-nl)>n) {
        // get trial value
        m = 0
        for (i=1; i<=n; i++) {
            if (l[i]<=r[i]) {
                // high median within row
                xx[++m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i,
                           l[i]+trunc((r[i]-l[i]+1)/2))
            }
        }
        trial = robstat_hiquantile(xx[|1 \ m|], .5)
        // move right border
        j = 0
        for (i=n; i>=1; i--) {
            if (j<q) {
                while (-_robstat_mc_el(xpos, xneg, npos, nzero, i, j+1)<trial) {
                    j++
                    if (j==q) break
                }
            }
            R[i] = j
        }
        p = (R:>0)
        if (any(p)) WR = quadsum(select(wpos, p) :* ccw[select(R, p)])
        else        WR = 0
        if (WR>k) {
            swap(r, R)
            nr = sum(R)
            continue
        }
        // move left border
        j = q + 1
        for (i=1; i<=n; i++) {
            while (-_robstat_mc_el(xpos, xneg, npos, nzero, i, j-1)>trial) {
                j--
            }
            L[i] = j
        }
        p = (L:>1)
        WL = quadsum(select(wpos, p) :* ccw[select(L, p):-1])
        if (WL<k) {
            swap(l, L)
            Wl = WL
            nl = sum(L) - n
            continue
        }
        // trial = low quantile = high quantile
        if (WR==WL | (WR<k & WL>k)) return(-trial)
        // trial = low quantile
        if (WL==k) {
            m = 0
            for (i=1; i<=n; i++) {
                if (L[i]>q) continue
                xx[++m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i, L[i])
            }
            return(-(trial+min(xx[|1 \ m|]))/2)
        }
        // trial = high quantile
        for (i=1; i<=n; i++) {
            xx[i] = -_robstat_mc_el(xpos, xneg, npos, nzero, i, R[i])
        }
        return(-(trial+max(xx))/2)
    }
    // get target value from remaining candidates
    m = 0
    for (i=1; i<=n; i++) {
        if (l[i]<=r[i]) {
            for (j=l[i]; j<=r[i]; j++) {
                m++
                xx[m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i, j)
                ww[m] = wpos[i] * wneg[j]
            }
        }
    }
    return(-robstat_quantile_w(xx[|1 \ m|], ww[|1 \ m|], k, Wl))
}

real scalar robstat_mc_fw(real colvector x, real colvector w)
{   // changes x and w, assumes med(x)=0
    real scalar     i, j, m, k, n, q, nl, nr, trial, npos, nzero, Wl, WR, WL, W
    real colvector  xx, ww, l, r, L, R, p, ccw, ccwz, xpos, xneg, wpos, wneg, wnegz, wzero

    if (rows(x)<=1) return(0)       // returning zero if n=1
    p       = order(x, -1)          // sort order (will be replaced)
    x       = x[p]                  // sorted data
    w       = w[p]                  // row weights
    p = (x:>0)
    xpos    = select(x, p)          // obervations > median
    wpos    = select(w, p)          // weights of obervations >= median
    npos    = rows(xpos)            // number of obs > median
    p = (x:<0)
    xneg    = select(x, p)          // observations < median
    wneg    = select(w, p)          // weights of obervations <= median
    wzero   = sum(select(w, x:==0)) // aggregate weights for x==median
    nzero   = (wzero>0)             // has x==median
    if (nzero>0) {
        wpos  = wpos \ 1
        wnegz = (wzero>1 ? (comb(wzero, 2), wzero, comb(wzero, 2))' : wzero) \ wneg*wzero
        wneg  = wzero \ wneg
    }
    n       = npos + nzero          // number of rows in search matrix
    q       = nzero + rows(xneg)    // number of columns in search matrix
    xx = ww = J(n, 1, .)            // temp vector for matrix elements
    l = L   = J(n, 1, 1)            // indices of left boundary (old and new)
    r = R   = J(n, 1, q)            // indices of right boundary (old and new)
    if (wzero>1) {
        r[n] = q+2
        R[n] = q+2
    }
    nl      = 0                     // number of cells below left boundary
    nr      = sum(R)                // number of cells within right boundary
    ccw     = quadrunningsum(wneg)  // cumulative column weights
    if (nzero==0) {
        W   = quadsum(wpos:*ccw[rows(ccw)]) // sum of weights in search matrix
    }
    else {
        ccwz = quadrunningsum(wnegz)  // cumulative column weights in last row
        if (npos>=1) W = quadsum(wpos[|1 \ n-1|]:*ccw[rows(ccw)]) + ccwz[rows(ccwz)]
        else         W = ccwz[rows(ccwz)]
    }
    Wl = WL = 0                       // sum of weights below left boundary
    WR      = W                       // sum of weights within right boundary
    k       = W/2                     // target quantile
    while ((nr-nl)>n) {
        // get trial value
        m = 0
        for (i=1; i<=(n-(wzero>1)); i++) {
            if (l[i]<=r[i]) {
                // high median within row
                xx[++m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i,
                           l[i]+trunc((r[i]-l[i]+1)/2))
            }
        }
        if (wzero>1) { // handle last row
            if (l[n]<=r[n]) {
                m++
                xx[m] = -_robstat_mc_el(xpos, xneg, npos-1, 3, n,
                           l[n]+trunc((r[n]-l[n]+1)/2))
            }
        }
        trial = robstat_hiquantile(xx[|1 \ m|], .5)
        // move right border
        if (wzero>1) { // handle last row
            j = 0
            while (-_robstat_mc_el(xpos, xneg, npos-1, 3, n, j+1)<trial) {
                j++
                if (j==(q+2)) break
            }
            R[n] = j
        }
        j = 0
        for (i=(n-(wzero>1)); i>=1; i--) {
            if (j<q) {
                while (-_robstat_mc_el(xpos, xneg, npos, nzero, i, j+1)<trial) {
                    j++
                    if (j==q) break
                }
            }
            R[i] = j
        }
        p = (R:>0)
        if (nzero>0) p[n] = 0
        if (any(p)) WR = quadsum(select(wpos, p) :* ccw[select(R, p)])
        else        WR = 0
        if (nzero>0) {
            if (R[n]>0) WR = WR + ccwz[R[n]]
        }
        if (WR>k) {
            swap(r, R)
            nr = sum(R)
            continue
        }
        // move left border
        j = q + 1
        for (i=1; i<=(n-(wzero>1)); i++) {
            while (-_robstat_mc_el(xpos, xneg, npos, nzero, i, j-1)>trial) {
                j--
            }
            L[i] = j
        }
        if (wzero>1) { // handle last row
            j = q + 3
            while (-_robstat_mc_el(xpos, xneg, npos-1, 3, n, j-1)>trial) {
                j--
            }
            L[n] = j
        }
        p = (L:>1)
        if (nzero>0) p[n] = 0
        if (any(p)) WL = quadsum(select(wpos, p) :* 
            (rows(ccw)==1 ? ccw[select(L, p):-1]' : ccw[select(L, p):-1]))
        else        WL = 0
        if (nzero>0) {
            if (L[n]>1) WL = WL + ccwz[L[n]-1]
        }
        if (WL<k) {
            swap(l, L)
            Wl = WL
            nl = sum(L) - n
            continue
        }
        // trial = low quantile = high quantile
        if (ceil(k)!=k | (WR<k & WL>k)) return(-trial)
        // trial = low quantile
        if (WL==k) {
            m = 0
            for (i=1; i<=(n-(wzero>1)); i++) {
                if (L[i]>q) continue
                xx[++m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i, L[i])
            }
            if (wzero>1) { // handle last row
                if (L[n]<=(q+2)) {
                    xx[++m] = -_robstat_mc_el(xpos, xneg, npos-1, 3, n, L[n])
                }
            }
            return(-(trial+min(xx[|1 \ m|]))/2)
        }
        // trial = high quantile
        for (i=1; i<=(n-(wzero>1)); i++) {
            xx[i] = -_robstat_mc_el(xpos, xneg, npos, nzero, i, R[i])
        }
        if (wzero>1) { // handle last row
            xx[n] = -_robstat_mc_el(xpos, xneg, npos-1, 3, n, R[n])
        }
        return(-(trial+max(xx))/2)
    }
    // get target value from remaining candidates
    m = 0
    for (i=1; i<=(n-nzero); i++) {
        if (l[i]<=r[i]) {
            for (j=l[i]; j<=r[i]; j++) {
                m++
                xx[m] = -_robstat_mc_el(xpos, xneg, npos, nzero, i, j)
                ww[m] = wpos[i] * wneg[j]
            }
        }
    }
    if (nzero>0) { // handle last row
        if (l[n]<=r[n]) {
            for (j=l[n]; j<=r[n]; j++) {
                m++
                xx[m] = -_robstat_mc_el(xpos, xneg, npos-(wzero>1),
                    (wzero>1 ? 3 : 1), n, j)
                ww[m] = wnegz[j]
            }
        }
    }
    return(-robstat_quantile_w(xx[|1 \ m|], ww[|1 \ m|], k, Wl))
}

real scalar robstat_mcnaive(real colvector x) // assumes med(x)=0
{
    real scalar    i, j, m, n, q, npos, nzero
    real colvector xx, xpos, xneg 

    if (rows(x)<=1) return(0) // returning zero if n=1
    xpos   = select(x, x:>0)
    npos   = rows(xpos)
    xneg   = select(x, x:<0)
    nzero  = sum(x:==0)
    n      = npos + nzero
    q      = rows(xneg) + nzero
    m = 0
    xx = J(n*q, 1, .)
    for (i=1; i<=n; i++) {
        for (j=1; j<=q; j++) {
            xx[++m] = _robstat_mc_el(xpos, xneg, npos, nzero, i, j)
        }
    }
    return(robstat_quantile(xx, .5))
}

real scalar robstat_mcnaive_w(real colvector x, real colvector w)
{   // assumes med(x)=0
    real scalar    i, j, m, n, q, npos, nzero
    real colvector xx, ww, xpos, xneg, wpos, wneg, wzero

    if (rows(x)<=1) return(0) // returning zero if n=1
    xpos   = select(x, x:>0)
    wpos   = select(w, x:>0)
    npos   = rows(xpos)
    xneg   = select(x, x:<0)
    wneg   = select(w, x:<0)
    wzero  = select(w, x:==0)
    nzero  = rows(wzero)
    if (nzero>0) {
        wpos = wpos \ wzero
        wneg = wzero[nzero::1] \ wneg // need to use reverse ordered wzero
    }
    n      = npos + nzero
    q      = rows(xneg) + nzero
    m = 0
    xx = ww = J(n*q, 1, .)
    for (i=1; i<=n; i++) {
        for (j=1; j<=q; j++) {
            m++
            xx[m] = _robstat_mc_el(xpos, xneg, npos, nzero, i, j)
            ww[m] = wpos[i] * wneg[j]
        }
    }
    return(robstat_quantile_w(xx, ww, .5))
}

real scalar robstat_mcnaive_fw(real colvector x, real colvector w)
{   // assumes med(x)=0
    real scalar    i, j, m, n, q, npos, nzero, wzero
    real colvector xx, ww, xpos, xneg, wpos, wneg

    if (rows(x)<=1) return(0) // returning zero if n=1
    xpos   = select(x, x:>0)
    wpos   = select(w, x:>0)
    npos   = rows(xpos)
    xneg   = select(x, x:<0)
    wneg   = select(w, x:<0)
    wzero  = sum(select(w, x:==0)) // aggregate weights for x==median
    nzero  = (wzero>0)
    if (nzero>0) {
        wpos = wpos \ wzero
        wneg = wzero \ wneg
    }
    n      = npos + nzero
    q      = rows(xneg) + nzero
    m = 0
    xx = ww = J(n*q + 2*(wzero>1), 1, .)
    for (i=1; i<=n; i++) {
        for (j=1; j<=q; j++) {
            m++
            if (i>npos & j==nzero) { // x==median
                xx[m] = 0
                ww[m] = wzero
                if (wzero>1) {
                    m++
                    xx[m] = 1
                    ww[m] = comb(wzero, 2)
                    m++
                    xx[m] = -1
                    ww[m] = comb(wzero, 2)
                }
            }
            else {
                xx[m] = _robstat_mc_el(xpos, xneg, npos, nzero, i, j)
                ww[m] = wpos[i] * wneg[j]
            }
        }
    }
    return(robstat_quantile_w(xx, ww, .5))
}

// quantiles
real scalar robstat_quantile(real colvector x, real scalar P, 
    | real scalar offset) // must be integer; changes meaning of P if specified
{
    real scalar    j0, j1, n, k
    real colvector p

    n = rows(x)
    if (n<1) return(.)
    if (n==1) return(x)
    if (args()==3) k = P     // P is a count (possibly noninteger)
    else           k = P * n // P is a proportion
    j0 = ceil(k)      - (args()==3 ? offset : 0) // index of low quantile
    j1 = floor(k) + 1 - (args()==3 ? offset : 0) // index of high quantile
    if (j0<1)      j0 = 1
    else if (j0>n) j0 = n
    if (j1<1)      j1 = 1
    else if (j1>n) j1 = n
    p = order(x, 1)
    if (j0==j1) return(x[p[j1]])
    return((x[p[j0]] + x[p[j1]])/2)
}

real scalar robstat_hiquantile(real colvector x, real scalar P)
{
    real scalar    j, n
    real colvector p

    n = rows(x)
    if (n<1) return(.)
    p = order(x, 1)
    j = floor(P * n) + 1
    if (j<1)      j = 1
    else if (j>n) j = n
    return(x[p[j]])
}

real scalar robstat_quantile_w(real colvector x, real colvector w, real scalar P, 
    | real scalar offset) // changes meaning of P if specified
{
    real scalar    n, i, k
    real colvector p, cw

    n = rows(x)
    if (n<1) return(.)
    p = order(x, 1)
    if (anyof(w, 0)) {
         p = select(p, w[p]:!=0)
         n = rows(p)
    }
    if (n<1) return(.)
    if (n==1) return(x[p])
    if (args()==4) {
        cw = quadrunningsum(offset \ w[p])[|2 \ n+1|]
        k = P // P is a count
    }
    else {
        cw = quadrunningsum(w[p])
        k = P * cw[n] // P is a proportion
    }
    if (k>=cw[n]) return(x[p[n]])
    for (i=1; i<=n; i++) {
        if (k>cw[i]) continue
        if (k==cw[i]) return((x[p[i]]+x[p[i+1]])/2)
        return(x[p[i]])
    }
    // cannot be reached
}

real scalar robstat_hiquantile_w(real colvector x, real colvector w, real scalar P)
{
    real scalar    i, n, k
    real colvector p, cw

    n = rows(x)
    if (n<1) return(.)
    p = order(x, 1)
    cw = quadrunningsum(w[p])
    k  = cw[n] * P
    if (k>=cw[n]) return(x[p[n]])
    for (i=1; i<=n; i++) {
        if (k>=cw[i]) continue
        return(x[p[i]])
    }
    // cannot be reached
}

// density estimations
void robstat_kdens_v(string scalar atvar, string scalar dvar)
{   // store density estimate in variable
    real scalar    pw
    string scalar  touse, wtype
    real colvector x, w, at
    
    // data
    touse = st_local("touse")
    x  = st_data(., st_local("v"), touse)
    wtype = st_local("weight")
    if (wtype!="") {
        w = st_data(., st_local("exp"), touse)
        if (wtype!="fweight") w = w :/ quadsum(w) * rows(w) // normalize weights
    }
    else w = 1
    pw = wtype=="pweight"
    // density estimate
    at = st_data(., atvar, touse)
    st_store(., dvar, touse, robstat_kdens(x, w, pw, at))
}

void robstat_kdens_s(string rowvector in, string rowvector out)
{   // store density estimate in scalars
    real scalar    i, pw
    string scalar  touse, wtype
    real colvector x, w, at, d
    
    // data
    touse = st_local("touse")
    x  = st_data(., st_local("v"), touse)
    wtype = st_local("weight")
    if (wtype!="") {
        w = st_data(., st_local("exp"), touse)
        if (wtype!="fweight") w = w :/ quadsum(w) * rows(w) // normalize weights
    }
    else w = 1
    pw = wtype=="pweight"
    // density estimate
    at = J(cols(in), 1, .)
    for (i=1; i<=cols(in); i++) at[i] = st_numscalar(in[i])
    d = robstat_kdens(x, w, pw, at)
    for (i=1; i<=cols(out); i++) st_numscalar(out[i], d[i])
}

real colvector robstat_kdens(
    real colvector x,
    real colvector w,
    real scalar    pw,
    real colvector at)
{
    real scalar    h, a, m
    real colvector g
    string scalar  k, bw
    
    k  = st_local("kernel")
    bw = st_local("bw")
    a  = strtoreal(st_local("adaptive"))
    m  = strtoreal(st_local("n"))

    if (mm_isconstant(x)) return(x[1]:==at)
    h = kdens_bw(x, w, bw, k, m)
    if (pw) h = (quadsum(w:^2) / rows(w))^.2 * h // assuming normalized w
    g = kdens_grid(x, w, h, k, m)
    return(mm_ipolate(g, kdens(x, w, g, h, k, a), at, 1))
}

void robstat_relrank(string rowvector in, string rowvector out)
{   
    string scalar  touse
    real colvector x, w
    
    touse = st_local("touse")
    x = st_data(., st_local("v"), touse)
    w = (st_local("weight")!="" ? st_data(., st_local("exp"), touse) : 1)
    st_store(., out, touse, 
        mm_relrank(x, w, st_data(., in, touse), "midpoints"!=""))
}

void robstat_relrank_s(string rowvector in, string rowvector out)
{   
    string scalar  touse
    real scalar    i
    real colvector x, w, at, r
    
    touse = st_local("touse")
    x = st_data(., st_local("v"), touse)
    w = (st_local("weight")!="" ? st_data(., st_local("exp"), touse) : 1)
    at = J(cols(in), 1, .)
    for (i=1; i<=cols(in); i++) at[i] = st_numscalar(in[i])
    r = mm_relrank(x, w, at, "midpoints"!="")
    for (i=1; i<=cols(out); i++) st_numscalar(out[i], r[i])
}

end

exit

