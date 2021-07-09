*! version 1.1.1 04June2017 Mauricio Caceres Bravo, caceres@nber.org
*! (In)attentive logit regression post-estimation using C plugins

capture program drop alogit_p_fast
program alogit_p_fast, sclass sortpreserve
    version 13.1
    syntax [anything] [if] [in], [*]

    if ( "`e(method)'" != "exact" ) {
        di as err "-algorithm(`e(algorithm)')- only available for -method(exact)-"
        exit 198
    }

    /* Step 1:
        place command-unique options in local myopts
        Note that standard options are
        LR:
            Index XB Cooksd Hat
            REsiduals RSTAndard RSTUdent
            STDF STDP STDR noOFFset
        SE:
            Index XB STDP noOFFset
    */
    local myopts "py pyc pa u a p0 mp0 mp1 dydx(passthru) fit(str) counterfactual(passthru) sorted"


    /* Step 2:
        call _propts, exit if done,
        else collect what was returned.
    */
    local 0: list 0 - replace
    _pred_se "`myopts'" `0'
    if ( `s(done)' ) {
        exit
    }
    local vtyp `s(typ)'
    local varn `s(varn)'
    local 0 `"`s(rest)'"'


    /* Step 3:
        Parse your syntax.
    */
    syntax [if] [in] [, `myopts' noOFFset]


    /* Step 4:
        Concatenate switch options together
    */
    local type "`py'`pyc'`pa'`u'`a'`p0'`mp0'`mp1'`dydx'`counterfactual'"


    /* Step 5:
        quickly process default case if you can
        Do not forget -nooffset- option.
    */


    /* Step 6:
        mark sample (this is not e(sample)).
    */
    marksample touse
    qui count if `touse' & !e(sample)
    if ( ("`e(method)'" == "importance") & (`r(N)' > 0) ) {
        di as err "{p}out-of-sample predictions with " ///
                  "-method(`e(method)'`)- are not possible{p_end}"
        di as err "see {manhelp alogit_postestimation##warning R:alogit postestimation}"
        exit 400
    }


    /* Step 7:
        handle options that take argument one at a time.
        Comment if restricted to e(sample).
        Be careful in coding that number of missing values
        created is shown.
        Do all intermediate calculations in double.
    */


    /* Step 8:
        handle switch options that can be used in-sample or
        out-of-sample one at a time.
        Be careful in coding that number of missing values
        created is shown.
        Do all intermediate calculations in double.
    */

    tempvar notouse
    gen byte `notouse' = !`touse'

    local _cons _cons
    local markvars `e(depvar)' `e(indepvars)' `e(avars)'
    markout `touse' `:list markvars - _cons'

    * Parse counterfactual
    if regexm("`type'", "counterfactual\(.+\)") {
        local mcapture capture
        local 0 , `counterfactual'
        syntax, counterfactual(str)
        local 0 , `counterfactual'
        syntax, [u_ij(varname) phi_ij(varname) GRoup(varname) DEFault(varname) CONSider(varname) checksetup]

        if ( "`default'"  == "" ) local default  `e(default)'
        if ( "`consider'" == "" ) local consider `e(consider)'
        if ( "`group'"    == "" ) local cgroup   `e(group)'
        else local cgroup `group'

        markout `touse' `default' `consider' `u_ij' `phi_ij'
        markout `touse' `cgroup', strok
    }
    else {
        markout `touse' `e(default)' `e(consider)'
        markout `touse' `e(group)', strok
        local default   `e(default)'
        local consider  `e(consider)'
    }

    * Check the default good is sane
    if ( "`default'`consider'" == "" ) {
        di as err "Specify one of -default()- or -consider()-"
        exit 198
    }
    if ( ("`default'" != "") & ("`consider'" != "") ) {
        di as err "Specify only one of -default()- or -consider()-"
        exit 198
    }

    cap assert inlist(`default'`consider', 0, 1) != 0 if `touse'
    if ( _rc != 0 ) {
        di as err "`default'`consider' should be a 0/1 variable"
        exit 400
    }
    tempvar maxd
    egen `maxd' = total(`default'`consider'), by(`notouse' `e(group)')
    cap assert `maxd' >= 1 if `touse'
    if ( _rc != 0 ) {
        di as err "`default'`consider' should specify at least 1 good per group"
        exit 400
    }
    if ( "`default'" != "" ) {
        cap assert inlist(`maxd', 0, 1) != 0 if `touse'
        if (_rc != 0) {
            di as err "`default' should specify only one default per individual"
            exit 400
        }
    }

    if ( ("`e(model)'" == "dsc") & ("`default'" == "") ) {
        di as err "-model(dsc)- requires option -default()-"
        exit 198
    }

    * Check the outcome variable is sane
    tempvar maxy
    egen `maxy' = total(`e(depvar)'), by(`notouse' `e(group)')
    cap assert inlist(`e(depvar)', 0, 1) != 0 if `touse'
    if ( _rc != 0 ) {
        di as err "outcome should be a 0/1 variable"
        exit 400
    }
    cap assert `maxy' >= 1 if `touse'
    if ( _rc != 0 ) {
        di as err "encountered goods with no positive outcomes; these will be dropped"
    }
    cap assert inlist(`maxy', 0, 1) if `touse'
    if ( _rc != 0 ) {
        di as err "encountered goods with multiple positive outcomes; these will be dropped"
    }

    * Data has to be sorted to be read correctly
    if ( "`sorted'" == "" ) sort `notouse' `e(group)' `consider', stable
    local group `e(group)'
    local avars `e(avars)'
    local ivars `e(indepvars)'

    * Add a constant if the model had one
    if ( `:list _cons in avars' ) {
        tempvar cons
        gen byte `cons' = 1
        local avars `:list avars - _cons' `cons'
    }

    * Set up for predict in C
    if ( "`type'" == "" ) local type py
    qui count if `touse'
    local N = `r(N)'
    tempvar in1 in2 index nj tag
    gen `index' = _n
    by `notouse' `e(group)': gen `tag' = (_n == 1)
    by `notouse' `e(group)': gen `in1' = `index'[1]
    by `notouse' `e(group)': gen `in2' = `index'[_N]
    by `notouse' `e(group)': gen `nj'  = _N
    qui count if `touse' & `tag'
    local J = `r(N)'
    local kx:  list sizeof ivars
    local kxz: list sizeof avars
    local ktot = `kx' + `kxz'
    matrix __alogit_b      = e(b)
    if ( `e(expb)' ) mata: st_matrix("__alogit_b", log(st_matrix("__alogit_b")))
    scalar __alogit_ll     = .
    scalar __alogit_kx     = `kx'
    scalar __alogit_kxz    = `kxz'
    scalar __alogit_ktot   = `ktot'
    scalar __alogit_getdef = `:di ("`default'" != "") & ("`consider'" == "")'
    local cvarlist `e(depvar)' `default'`consider' `in1' `in2' `nj' `ivars' `avars'
    local plugargs if `touse' & `tag' in 1 / `N', `J'
    local plugcall plugin call aloglik_`e(algorithm)'

    ***********************************************************************
    *                      Call the predict function                      *
    ***********************************************************************

    tempvar pred
    qui gen double `pred' = .
    local afit "`e(afit)'"
    local adjust = 1

    if ( ("`type'" == "") | ("`type'" == "py") ) local lvar "P(Y_ij)"
    else if ( "`type'" == "pyc" ) {
             if ( "`e(model)'" == "alogit" ) local lvar "P(Y_ij | all goods considered)"
        else if ( "`e(model)'" == "dsc" )    local lvar "P(Y_ij | attention)"
    }
    else if ( "`type'" == "pa" )  local lvar "P(A_ij)"
    else if ( "`type'" == "u" )   local lvar "u_ij"
    else if ( "`type'" == "a" )   local lvar "A_ij"
    else if ( "`type'" == "p0" )  {
             if ( "`e(model)'" == "alogit" ) local lvar "P(c_i = empty)"
        else if ( "`e(model)'" == "dsc" )    local lvar "P(I_i | x_id)"
    }
    else if ( "`type'" == "mp0" ) {
        // Nothing
    }
    else if ( "`type'" == "mp1" ) {
        if ( "`e(model)'" == "alogit" ) {
            di as err "Option -mp1- not available with -model(alogit)-"
            exit 198
        }
    }
    else if regexm("`type'", "dydx\(.+\)") {
        local 0 , `dydx'
        syntax, dydx(str)
        local 0 `dydx'
        syntax varname, [elasticity]
        if ( `:list varlist in ivars' ) local dpyc dpyc
        if ( `:list varlist in avars' ) local dpc  dpc
        local type "`dpyc'`dpc'"
        local ipos `:list posof "`varlist'" in ivars'
        local apos `:list posof "`varlist'" in avars'
        if ( (`ipos' == 0) & (`apos' == 0) ) {
            di as err "`varlist' not used in model fit"  ///
                _n(1) "    utility vars: `e(indepvars)'" ///
                _n(1) "    attention vars: `e(avars)'"
            exit 198
        }

        tempvar adjust
        gen double `adjust' = 1
        if ( "`elasticity'" != "" ) {
            `plugcall' `cvarlist' `adjust' `plugargs' `e(model)'_p py
            if ( `ipos' > 0 ) {
                qui replace `adjust' = `:word `ipos' of `ivars'' / `adjust'
            }
            else if ( `apos' > 0 ) {
                qui replace `adjust' = `:word `apos' of `avars'' / `adjust'
            }
        }
    }
    else if regexm("`type'", "counterfactual\(.+\)") {
        local gsort `notouse'
        if ( "`cgroup'"  != "" ) {
            local gsort `gsort' `cgroup'
        }
        else {
            di as err "please specify -group(varname)-"
            error 198
        }

        if ( "`default'`consider'" != "" ) {
            local cvarlist `e(depvar)' `default'`consider' `in1' `in2' `nj' `ivars' `avars'
        }
        else {
            di as err "please specify -default(varname)- or -consider(varname)-"
            error 198
        }

        if ( "`sorted'" == "" ) sort `gsort' `consider', stable
        if ( "`u_ij'" == "" ) {
            tempvar uij
            alogit_p_linear `uij' if `touse', type(u) ivars(`ivars') avars(`avars')
        }
        else {
            local uij `u_ij'
        }

        if ( "`phi_ij'" == "" ) {
            tempvar pij
            alogit_p_linear `pij' if `touse', type(pa) ivars(`ivars') avars(`avars') consider(`consider')
        }
        else {
            local pij `phi_ij'
        }

        qui count if `touse'
        local N = `r(N)'
        tempvar in1 in2 index nj tag
        gen `index' = _n
        by `gsort': gen `tag' = (_n == 1)
        by `gsort': gen `in1' = `index'[1]
        by `gsort': gen `in2' = `index'[_N]
        by `gsort': gen `nj'  = _N
        qui count if `touse' & `tag'
        local J = `r(N)'
        local counter_cvarlist `default'`consider' `in1' `in2' `nj' `uij' `pij'
        local counter_plugargs if `touse' & `tag' in 1 / `N', `J'

        qui gen double `varn' = .
        `plugcall' `varn' `counter_cvarlist' `counter_plugargs' `e(model)'_c
        exit 0
    }
    else {
        di as err "can only handle one option at a time; pass: `myopts'"
        error 198
    }

    ***********************************************************************
    *                 Fit using user-specified parameters                 *
    ***********************************************************************

    if ( "`fit'" != "" ) {
        local 0 , `fit'
        syntax, [b0(numlist) g0(numlist) d0(numlist) last]

        local avars `e(avars)'
        local ivars `e(indepvars)'
        local kx    `:list sizeof ivars'
        local kz    `:list sizeof avars'

        tempname bb b
        matrix `bb' = e(b)
        matrix  b0  = `bb'[1, 1..`kx']
        matrix  d0  = `bb'[1, `:di `kx' + 1'..`:di `kx' + `kz'']

        * Parse the custom parameters
        if ( "`b0'" != "" ) {
            local ki  = `:word count `b0''
            local bb0 `:di subinstr("`b0'", " ", ", ", .)'
            if ( `ki' < `kx' ) {
                if ( "`last'" == "" ) {
                    matrix b0 = `bb0', b0[1, `:di `ki' + 1'..`kx']
                }
                else {
                    matrix b0 = b0[1, 1..`:di `kx' - `ki''], `bb0'
                }
            }
            else {
                matrix b0 = `bb0'
            }
        }

        if ( "`g0'" != "" ) {
            local ka = `:word count `g0''
            local gg0 `:di subinstr("`g0'", " ", ", ", .)'
        }
        else {
            local ka = 0
        }

        if ( "`d0'" != "" ) {
            local ka  = `ka' + `:word count `d0''
            if ( "`gg0'" == "" ) {
                local gg0 `:di subinstr("`d0'", " ", ", ", .)'
            }
            else {
                local gg0 `gg0', `:di subinstr("`d0'", " ", ", ", .)'
            }
        }

        if ( ("`d0'" != "") | ("`g0'" != "") ) {
            if ( `ka' < `kz' ) {
                if ( "`last'" == "" ) {
                    matrix g0 = `gg0', d0[1, `:di `ka' + 1'..`kz']
                }
                else {
                    matrix g0 = d0[1, 1..`:di `kz' - `ka''], `gg0'
                }
            }
            else {
                matrix g0 = `gg0'
            }
        }

        * Correct number of variables
        cap assert `:list sizeof ivars' == `:word count `:colnames b0''
        if ( _rc != 0 ) {
            di as err "Must specify equal number of covariates and parameters."
            exit 198
        }

        cap assert `:list sizeof avars' == `:word count `:colnames g0''
        if ( _rc != 0 ) {
            di as err "Must specify equal number of covariates and parameters."
            exit 198
        }
        matrix __alogit_b = b0, g0
        if ( `e(expb)' ) mata: st_matrix("__alogit_b", log(st_matrix("__alogit_b")))
    }

    ***********************************************************************
    *                             mp0 and mp1                             *
    ***********************************************************************
    if ( "`type'" == "mp0" ) {
        scalar __alogit_mp0 = .
        `plugcall' `cvarlist' `plugargs' `e(model)'_p mp0
        local mp0 = scalar(__alogit_mp0)
             if ( "`e(model)'" == "alogit" ) di "Average P(c_i = empty) = `:di %5.4f `mp0''"
        else if ( "`e(model)'" == "dsc" )    di "Average P(I_i | x_id) = `:di %5.4f `mp0''"
        sreturn local `varn' = `mp0'
        exit
    }
    else if ( "`type'" == "mp1" ) {
        scalar __alogit_mp1 = .
        `plugcall' `cvarlist' `plugargs' `e(model)'_p mp1
        di "Average P(A_i | x_id) = `:di %5.4f `mp1''"
        sreturn local `varn' = `mp1'
        exit
    }
    
    ***********************************************************************
    *                     Put the variable into Stata                     *
    ***********************************************************************

    if inlist("`type'", "u", "a", "pa") {
        if ( ("`type'" == "pa") & ("`e(model)'" == "dsc") ) {
            `plugcall' `cvarlist' `pred' `plugargs' `e(model)'_p `type' `ipos' `apos'
            gen double `varn' = `pred' * `adjust'
        }
        else {
            alogit_p_linear `varn' if `touse', type(`type') ivars(`ivars') avars(`avars') consider(`consider')
        }
    }
    else {
        `plugcall' `cvarlist' `pred' `plugargs' `e(model)'_p `type' `ipos' `apos'
        gen double `varn' = `pred' * `adjust'
    }
    label var `varn' "`lvar'"
    exit
end

capture program drop alogit_p_linear
program alogit_p_linear
    syntax newvarlist(max = 1) [if] [in], type(str) ivars(varlist) avars(varlist) [consider(varname)]
    cap matrix drop __alogit_bb
    cap matrix drop __alogit_bg
    forvalues k = 1 / `:di scalar(__alogit_kx)' {
        matrix __alogit_bb = nullmat(__alogit_bb), __alogit_b[1, `k']
    }
    forvalues k = `:di scalar(__alogit_kx) + 1' / `:di scalar(__alogit_ktot)' {
        matrix __alogit_bg = nullmat(__alogit_bg), __alogit_b[1, `k']
    }
    matrix colnames __alogit_bb = `ivars'
    matrix colnames __alogit_bg = `avars'
    if ( "`type'" == "u" ) matrix score double `varlist' = __alogit_bb `if' `in'
    if ( "`type'" == "a" ) matrix score double `varlist' = __alogit_bg `if' `in'
    if ( "`type'" == "pa" ) {
        tempvar pa
        matrix score double `pa' = __alogit_bg `if' `in'
        gen double `varlist' = invlogit(`pa') `if' `in'
        qui if ( "`consider'" != "" ) replace `varlist' = 1 if (`consider' == 1) & !mi(`varlist')
    }
end

cap program drop aloglik_fast
if ( inlist("`c(os)'", "Unix") & (`c(bit)' == 64) ) cap program aloglik_fast, plugin using("aloglik_fast.plugin")

cap program drop aloglik_faster
if ( inlist("`c(os)'", "Unix") & (`c(bit)' == 64) ) cap program aloglik_faster, plugin using("aloglik_faster.plugin")
