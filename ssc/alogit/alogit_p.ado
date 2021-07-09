*! version 1.1.1 04June2017 Mauricio Caceres Bravo, caceres@nber.org
*! (In)attentive logit regression post-estimation

capture program drop alogit_p
program alogit_p, sclass sortpreserve
    version 13.1
    syntax [anything] [if] [in], [*]

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
	if (`s(done)') {
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

    ***********************************************************************
    *                               Parsing                               *
    ***********************************************************************
    tempvar notouse
    gen byte `notouse' = !`touse'

    local _cons _cons
    local markvars `e(depvar)' `e(indepvars)' `e(avars)'
	markout `touse' `:list markvars - _cons'

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

    ***********************************************************************
    *                         Check default good                          *
    ***********************************************************************

    if ( "`default'`consider'" == "" ) {
        di as err "Specify one of -default()- or -consider()-"
        exit 198
    }
    if ( ("`default'" != "") & ("`consider'" != "") ) {
        di as err "Specify only one of -default()- or -consider()-"
        exit 198
    }

    * Default good and consider goods
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
        if ( _rc != 0 ) {
            di as err "`default' should specify only one default per individual"
            exit 400
        }
    }

    if ( ("`e(model)'" == "dsc") & ("`default'" == "") ) {
        di as err "-model(dsc)- requires option -default()-"
        exit 198
    }

    * Chosen good
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

    ***********************************************************************
    *                      Set up variables in mata                       *
    ***********************************************************************

    if ( "`sorted'" == "" ) sort `notouse' `e(group)' `e(consider)', stable
    local group `e(group)'
    local avars `e(avars)'
    local ivars `e(indepvars)'

    tempname y x xz adjust mp0 mp1 def
    mata: `adjust' = 1
    `mcapture' mata: `x' = st_data(., "`e(indepvars)'", "`touse'")
    `mcapture' mata: `y' = st_data(., "`e(depvar)'",    "`touse'")
    if ( `:list _cons in avars' ) {
        local avars `:list avars - _cons'
        `mcapture' mata: `xz' = st_data(., "`avars'", "`touse'")
        `mcapture' mata: `xz' = `xz', J(rows(`xz'), 1, 1)
    }
    else {
        `mcapture' mata: `xz' = st_data(., "`avars'", "`touse'")
    }

    * Default and consider
    mata: `def' = st_data(., "`default'`consider'",  st_local("touse"))

    ***********************************************************************
    *                      Call the predict function                      *
    ***********************************************************************

    if ( "`e(model)'" == "dsc" ) local adddsc dsc_
    if ( "`e(algorithm)'" == "loop" ) local addloop _loop
    if inlist("`e(algorithm)'", "fast", "faster") local addloop _loop
    local alogit_predict        alogit_`adddsc'predict`addloop'
    local alogit_counterfactual alogit_`adddsc'counterfactual`addloop'

    local afit "`e(afit)'"
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
            matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
            exit 198
        }
    }
    else if regexm("`type'", "dydx\(.+\)") {
        local 0 , `dydx'
        syntax, dydx(str)
        local 0 `dydx'
        syntax varname, [elasticity]
        if ( `:list varlist in ivars' ) local dpyc dpyc
        if ( `:list varlist in avars' ) local dpc dpc
        local type "`dpyc'`dpc'"
        local ipos `:list posof "`varlist'" in ivars'
        local apos `:list posof "`varlist'" in avars'
        if ( (`ipos' == 0) & (`apos' == 0) ) {
            di as err "`varlist' not used in model fit"  ///
                _n(1) "    utility vars: `e(indepvars)'" ///
                _n(1) "    attention vars: `e(avars)'"
            matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
            exit 198
        }

        if ( "`elasticity'" != "" ) {
            mata: `adjust' = `alogit_predict'(alogitM, `y', `x', `xz', `def', "`e(method)'", "py")
            if ( `ipos' > 0 ) {
                mata: `adjust' = `x'[, `ipos'] :/ `adjust'
            }
            else if ( `apos' > 0 ) {
                mata: `adjust' = `xz'[, `apos'] :/ `adjust'
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

        tempname d_ij uij pij pred info
        if ( "`default'`consider'" != "" ) {
            mata: `d_ij' = st_data(., "`default'`consider'",  st_local("touse"))
        }
        else {
            di as err "please specify -default(varname)- or -consider(varname)-"
            matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
            matadrop `d_ij' `uij' `pij' `pred' `info'
            error 198
        }

        if ( "`sorted'" == "" ) sort `gsort' `e(consider)', stable
        if ( "`u_ij'" == "" ) {
            mata: `uij' = `alogit_predict'(alogitM, `y', `x', `xz', `d_ij', "`e(method)'", "u")
        }
        else {
            mata: `uij' = st_data(., "`u_ij'")
        }
        if ( "`phi_ij'" == "" ) {
            mata: `pij' = `alogit_predict'(alogitM, `y', `x', `xz', `d_ij', "`e(method)'", "pa")
        }
        else {
            mata: `pij' = st_data(., "`phi_ij'")
        }
        mata: `info' = panelsetup(st_data(., "`cgroup'"), 1)
        mata: `pred' = `alogit_counterfactual'(`uij', `pij', `d_ij', `info')
        getmata `varn' = `pred', `replace' force
        matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
        matadrop `d_ij' `uij' `pij' `pred' `info'
        exit 0
    }
    else {
        di as err "can only handle one option at a time; pass: `myopts'"
        matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
        error 198
    }

    ***********************************************************************
    *                 Fit using user-specified parameters                 *
    ***********************************************************************

    tempname pred
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
            matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
            matadrop `d_ij' `uij' `pij' `pred' `info' `b'
            exit 198
        }

        cap assert `:list sizeof avars' == `:word count `:colnames g0''
        if ( _rc != 0 ) {
            di as err "Must specify equal number of covariates and parameters."
            matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
            matadrop `d_ij' `uij' `pij' `pred' `info' `b'
            exit 198
        }
        mata: `b'    = st_matrix("b0"), st_matrix("g0")
        if ( `e(expb)' ) mata: st_matrix("`b'", log(st_matrix("`b'")))
        mata: `pred' = `alogit_predict'(alogitM, `y', `x', `xz', `def', "`e(method)'", "`type'", `b')
    }
    else {
        mata: `pred' = `alogit_predict'(alogitM, `y', `x', `xz', `def', "`e(method)'", "`type'")
    }

    ***********************************************************************
    *                             mp0 and mp1                             *
    ***********************************************************************
    if ( "`type'" == "mp0" ) {
        mata: `mp0' = `pred'
        mata: st_local("mp0", strofreal(`mp0'))
             if ( "`e(model)'" == "alogit" ) di "Average P(c_i = empty) = `:di %5.4f `mp0''"
        else if ( "`e(model)'" == "dsc" )    di "Average P(I_i | x_id) = `:di %5.4f `mp0''"
        sreturn local `varn' = `mp0'
        matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
        exit
    }
    else if ( "`type'" == "mp1" ) {
        mata: `mp1' = `pred'
        mata: st_local("mp1", strofreal(`mp1'))
        di "Average P(A_i | x_id) = `:di %5.4f `mp1''"
        sreturn local `varn' = `mp1'
        matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
        exit
    }

    ***********************************************************************
    *                     Put the variable into Stata                     *
    ***********************************************************************

    mata: `pred' = `pred' :* `adjust'
    getmata `varn' = `pred', `replace' force
    label var `varn' "`lvar'"

    matadrop `y' `x' `xz' `adjust' `mp0' `mp1' `def'
    matadrop `d_ij' `uij' `pij' `pred' `info' `b'
    exit
end

capture program drop matadrop
program matadrop
    foreach object in `0' {
        capture mata: mata drop `object'
    }
end
