*! version 1.2.1 04June2017 Mauricio Caceres Bravo, caceres@nber.org
*! (In)attentive logit regression based on Abaluck and Adams (2017)

capture program drop alogit
program alogit, eclass sortpreserve
    version 13.1
    syntax varlist(numeric ts fv) /// dependent_var covariates
           [if] [in] ,            /// subset
        GRoup(varname)            /// individual groups
    [                             ///
        DEFault(varname)          /// default good
        CONSider(varname)         /// goods to always consider
                                  ///
        zvars(varlist)            /// additional attention covariates
        avars(varlist)            /// additional attention covariates (uses g0)
        exclude(varlist)          /// exclude from attention estimation
        NOConstant                /// omit a constant term when estimating p(a)
        CHECKsetup                /// stop execution if outcome is not correct
                                  ///
        b0(numlist)               /// starting parameters for utility covariates
        d0(numlist)               /// starting attn parameters for attn covariates
        g0(numlist)               /// starting attn parameters for utility covariates
                                  ///
        ALGorithm(str)            /// 'matrix', 'loop', 'fast', 'faster'
        model(str)                /// 'alogit', 'asc', 'dsc'
        eval(str)                 /// Evaluator type (d0, d1, d1debug, d2, d2debug)
        method(str)               /// 'exact' or 'importance'
        reps(int 100)             /// number of random draws for method 'importance'
        noprob(str)               /// how to handle probabilities = 0
                                  /// - error: Give an error message and exit
                                  /// - drop: Drop them from the likelihood
        NOdscnote                 /// Don't print note linking to DSC model help
        debug                     /// Print starting parameters and other debug info
        loglik                    /// Report loglik only
        exp                       /// Estimate the model for exp(b) instead of (b)
                                  ///
        DIFFicult                 /// spcify to pass "hybrid" to -moptimize()-
        TECHnique(str)            /// optimization technique to pass to -moptimize()-
        ITERate(int -1)           /// number of iterations to pass to -moptimize()-
        TRace                     /// display current parameter vector in iteration log
        coefdiffs                 /// display coefficient relative differences
        NOlog                     /// display an iteration log of the log likelihood
        GRADient                  /// display current gradient vector in iteration log
        showstep                  /// report steps within an iteration in iteration log
        HESSian                   /// display negative Hessian matrix in iteration log
        SHOWTOLerance             /// report result vs effective convergence criterion
        TOLerance(real -1)        /// tolerance for the coefficient vector
        LTOLerance(real -1)       /// tolerance for the log likelihood
        NRTOLerance(real -1)      /// tolerance for the scaled gradient
        NONRTOLerance             /// ignore the nrtolerance() option
        NOREScale                 /// don't rescale the likelihood
    ]

    * Default or consider required
    * ----------------------------

    if ( ("`model'" == "dsc") & ("`default'" == "") ) {
        di as err "-model(dsc)- requires option -default()-"
        exit 198
    }

    if ( ("`model'" == "dsc") & ("`consider'" != "") ) {
        di as err "option -consider()- not valid for -model(dsc)-"
        exit 198
    }

    if ( "`default'`consider'" == "" ) {
        di as err "Specify one of -default()- or -consider()-"
        exit 198
    }

    if ( ("`default'" != "") & ("`consider'" != "") ) {
        di as err "Specify only one of -default()- or -consider()-"
        exit 198
    }

    ***********************************************************************
    *                        Parse all the options                        *
    ***********************************************************************

    * Check model requested is known
    * ------------------------------

    local models alogit asc dsc
    if ( "`model'" == "" )    local model alogit
    if ( "`model'" == "asc" ) local model alogit
    if ( !`:list model in models' ) {
        di as err "Don't know model '`model''. Choose: `models'"
        exit 198
    }

    * Check method requested is known
    * -------------------------------

    local methods importance exact
    if ( "`method'" == "" ) local method exact
    if ( !`:list method in methods' ) {
        di as err "Don't know method '`method''. Choose: `methods'"
        exit 198
    }

    * Check model and method are compatible
    * -------------------------------------

    if ( ("`model'" == "dsc") & ("`nodscnote'" == "") ) {
        di "Model DSC was requested."
        * di "{p}Model DSC was requested. " ///
        *    "See {help alogit##description:help alogit (description)}{p_end}"
    }

    if ( ("`model'" == "dsc") & ("`method'" != "exact") ) {
        di as err "-model(dsc)- only available for -method(exact)-"
        exit 198
    }

    * Check default/consider consistent with method
    * ---------------------------------------------

    if ( ("`consider'" != "") & inlist("`method'", "importance") ) {
        di as err "{p}consider-goods handling with " ///
                  "-method(`method')- is not available{p_end}"
        exit 198
    }

    * Check -exp- not being called with -method(importance)-
    * ------------------------------------------------------

    if ( ("`exp'" != "") & inlist("`method'", "importance") ) {
        di as err "{p}option -exp- is not available with -method(`method')-{p_end}"
        exit 198
    }

    * Warn -exp- with -technique(nm)- has been unstable in testing
    * ------------------------------------------------------------

    if ( ("`technique'" == "nm") & ("`exp'" == "exp") ) {
        di as err "(warning: -exp- has been unstable with -technique(`method')- in testing)"
    }

    * Check algorithm requested is known
    * ----------------------------------

    local algswitch 0
    local algorithms matrix loop fast faster
    if ( ("`algorithm'" == "") & ("`method'" == "exact") & inlist("`model'", "asc", "alogit") ) {
        cap plugin call aloglik_faster, 1 check
        if ( _rc ) {
            cap plugin call aloglik_fast, 1 check
            if ( _rc ) {
                local algorithm matrix
                local algswitch 1
                if ("`debug'" != "") di "(selected algorithm(matrix) as default)"
            }
            else {
                local algorithm fast
                if ("`debug'" != "") di "(selected algorithm(fast) as default)"
            }
        }
        else {
            local algorithm faster
            if ("`debug'" != "") di "(selected algorithm(faster) as default)"
        }
    }
    else if ( "`algorithm'" == "" ) {
        local algorithm matrix
    }
    if ( !`:list algorithm in algorithms' ) {
        di as err "Don't know algorithm '`algorithm''. Choose: `algorithms'"
        exit 198
    }

    * Check method and algorithm are compatible
    * -----------------------------------------

    if ( ("`algorithm'" != "matrix") & ("`method'" != "exact") ) {
        di as err "-algorithm(`algorithm')- only available for -method(exact)-"
        exit 198
    }

    * For Model DSC, loop is superfluous
    * ----------------------------------

    if ( ("`algorithm'" == "loop") & ("`model'" != "alogit") ) {
        di "NOTE: -algorithm(`algorithm')- not available for -model(`model')-"
        exit 198
    }

    * For Model DSC, speed gains are nil
    * ----------------------------------

    if ( ("`algorithm'" != "matrix") & ("`model'" == "dsc") ) {
        di "NOTE: -algorithm(`algorithm')- will probably not afford speed gains for -model(`model')-"
        di "See -algorithm()- in {help alogit##options:help alogit (Options)}"
    }

    ********************************************
    *  Fast and Faster only vailable on Linux  *
    ********************************************
    if ( inlist("`algorithm'", "fast", "faster") & !inlist("`c(os)'", "Unix") ) {
        di as err "-algorithm(`algorithm')- is only available on Stata for Unix."
        exit 198
    }
    if ( inlist("`algorithm'", "fast", "faster") & (`c(bit)' != 64) ) {
        di as err "-algorithm(`algorithm')- is only available on 64-bit Stata."
        exit 198
    }
    ********************************************
    *  Fast and Faster only vailable on Linux  *
    ********************************************

    * Check noprob call is sane
    * -------------------------

    local noprobs error drop
    if ( "`noprob'" == "" ) local noprob error
    if ( !`:list noprob in noprobs' ) {
        di as err "Don't know noprob '`noprob''. Choose: `noprobs'"
        exit 198
    }

    * Check evaluator requested is known
    * ----------------------------------

    local evals d0 d1 d1debug d2 d2debug
    if ( "`eval'" == "" ) local eval d2
    if ( !`:list eval in evals' ) {
        di as err "Don't know evaluator type '`eval''. Choose: `evals'"
        exit 198
    }

    ***********************************************************************
    *                        Data checks and setup                        *
    ***********************************************************************

    * Get subset to use
    * -----------------

    tempvar notouse
    gettoken depvar xvars: varlist
    marksample touse, strok
    markout `touse' `depvar' `xvars' `avars' `zvars' `default' `consider'
    markout `touse' `group', strok
    gen byte `notouse' = !`touse'

    * Default and consider must be 0, 1
    * ---------------------------------

    cap assert inlist(`default'`consider', 0, 1) != 0 if `touse'
    if ( _rc != 0 ) {
        di as err "`default'`consider' should be a 0/1 variable"
        exit 400
    }

    * Check outcome variable is sane
    * ------------------------------

    cap assert inlist(`depvar', 0, 1) != 0 if `touse'
    if ( _rc != 0 ) {
        di as err "`depvar' should be a 0/1 variable"
        exit 400
    }

    ***********
    *  SORT!  *
    ***********
    sort `notouse' `group' `consider', stable
    ***********
    *  SORT!  *
    ***********

    * Check no multiple choices
    * -------------------------

    tempvar maxy
    egen `maxy' = total(`depvar'), by(`notouse' `group')
    cap assert `maxy' >= 1 if `touse'
    if ( _rc != 0 ) {
        if ( "`checksetup'" == "" ) local adds ; these will be dropped
        di as err "encountered groups with no" ///
                  " positive outcomes`adds'"
        if ( "`checksetup'" != "" ) exit 400
        else di ""
    }

    cap assert inlist(`maxy', 0, 1) if `touse'
    if ( _rc != 0 ) {
        if ( "`checksetup'" == "" ) local adds ; these will be dropped
        di as err "encountered groups with multiple" ///
                  " positive outcomes`adds'"
        if ( "`checksetup'" != "" ) exit 400
        else di ""
    }

    * Default and consider must be 1 for at least 1 good per group
    * ------------------------------------------------------------

    tempvar maxd bad mbad
    egen `maxd' = total(`default'`consider'), by(`notouse' `group')
    cap assert `maxd' >= 1 if `touse'
    if ( _rc != 0 ) {
        di as err "`default'`consider' should specify at least 1 good per group"
        exit 400
    }

    * Default in particular can only specify one good
    * -----------------------------------------------

    if ( "`default'" != "" ) {
        cap assert inlist(`maxd', 0, 1) != 0 if `touse'
        if ( _rc != 0 ) {
            di as err "`default' should specify only one default per individual"
            exit 400
        }
    }

    * Expand xvars, zvars and remove collinear variables
    * --------------------------------------------------

    * Do the constant manually
    if ( "`noconstant'" == "" ) {
        tempvar _cons
        gen byte `_cons' = 1
        label var `_cons' "_cons"
        local _cons_label " _cons"
    }
    else {
        local _cons       ""
        local _cons_label ""
    }

    * Expand xvars
    _rmcoll `xvars', noconstant expand
    local xvars `r(varlist)'

    if ( "`avars'" != "" ) {
        * Expand avars if requested
        qui xi: ds `avars'
        local avars `r(varlist)'
    }

    if ( "`zvars'" != "" ) {
        * Expand zvars if requested
        qui xi: ds `zvars'
        local zvars `r(varlist)'
    }

    * Exclude specified variables from attention equation
    if ( "`exclude'" != "" ) {
        qui xi: ds `exclude'
        local exclude `r(varlist)'
        foreach var in `exclude' {
            if ( `:list var in xvars' ) {
                if ( `:list var in zvars' | `:list var in avars' ) {
                    di "(warning: excluded variabrle `var' was also specified directly as an attention variable)"
                }
            }
            else {
                if ( `:list var in zvars' | `:list var in avars' ) {
                    di "(warning: excluded variabrle `var' was only specified directly as an attention variable)"
                }
                else {
                    di "(warning: excluded variabrle `var' was not in the utility equation)"
                }
            }
        }
        if ( "`avars'" == "" ) local avars `xvars'
        if ( "`avars'" != "" ) local avars: list avars - exclude
        if ( "`zvars'" != "" ) local zvars: list zvars - exclude
    }
    else if ( "`avars'" == "" ) local avars `xvars'

    * Concatenate avars and zvars. If avars was specified, it ignores
    * xvars; otherwise avars will be xvars. In both cases sans exclude.
    if ( "`avars'" != "" ) {
        local ka = `:word count `avars''
    }
    else {
        local ka = 0
    }

    tempname dlabels
    local xzvars `avars' `zvars'
    _rmcoll `xzvars' if `touse', `noconstant' expand
    local xzvars `r(varlist)' `_cons'
    local e2labels  = subinstr("`r(varlist)'`_cons_label'", " ", `"", ""', .)
    mata: `dlabels' = (`:di `""`e2labels'""'')

    * Default starting parameters
    * ---------------------------

    if ( "`b0'" == "" ) {
        qui clogit `depvar' `xvars', group(`group') iter(20)
        matrix b0 = e(b)
    }
    else {
        matrix b0 = `:di subinstr("`b0'", " ", ", ", .)'
    }

    if ( ("`d0'" == "") | ("`g0'" == "") ) {
        qui clogit `depvar' `xzvars', group(`group') iter(20)
        matrix d0 = e(b)
        if ( ("`g0'" != "") & ("`d0'" == "") ) {
            local gg0 `:di subinstr("`g0'", " ", ", ", .)'
            matrix d0 = `gg0', d0[1, `:di `ka' + 1'..`:word count `:colnames d0'']
        }
        if ( ("`g0'" == "") & ("`d0'" != "") ) {
            matrix d0 = d0[1, 1..`ka'], `:di subinstr("`d0'", " ", ", ", .)'
        }
    }
    else {
        matrix d0 = `:di subinstr("`g0'", " ", ", ", .)', `:di subinstr("`d0'", " ", ", ", .)'
    }

    * Correct number of variables
    * ---------------------------

    cap assert `:list sizeof xvars' == `:word count `:colnames b0''
    if ( _rc != 0 ) {
        di as err "Must specify equal number of covariates and parameters."
        exit 198
    }

    cap assert `:list sizeof xzvars' == `:word count `:colnames d0''
    if ( _rc != 0 ) {
        di as err "Must specify equal number of covariates and parameters."
        if (`:list sizeof xzvars' == (`:word count `:colnames d0'' + 1)) {
            di "List sizes are only off by 1. Maybe you forgot the constant?"
        }
        exit 198
    }

    * Display starting values
    * -----------------------

    if ( "`debug'" == "debug" ) {
        di "y: `depvar'" _n(1) ///
           "utility: `xvars'" _n(1) ///
           subinstr("attention: `xzvars'", "`_cons'", "_cons", .)
        matrix list b0, title("Utility parameters")
        matrix list d0, title("Attention parameters")
    }

    * Switch to loop if the number of goods is too large
    * --------------------------------------------------

    if ( `algswitch' ) {
        tempvar nj
        local njtype = cond(`:di _N < 2^31', "long", "`c(type)'")
        by `notouse' `group': gen `njtype' `nj' = _N
        qui sum `nj'
        local njmax `r(max)'
        local combos = 2^`njmax'
        if !mi(`combos') {
            local allvars `depvar' `xvars' `xzvars'
            local maxvars `:list sizeof allvars'
            local mib = (`combos' / (1024 * 1024)) * (15 + `maxvars')
            if ( (mi(`mib') | (`mib' > 256)) & ("`algorithm'" == "matrix") ) {
                local algorithm loop
                if ("`debug'" != "") di "(there were `njmax' groups; falling back to algorithm(loop))"
            }
        }
    }

    * Switch to loop if the number of goods is too large
    * --------------------------------------------------

    if ( `algswitch' ) {
        tempvar nj
        local njtype = cond(`:di _N < 2^31', "long", "`c(type)'")
        by `notouse' `group': gen `njtype' `nj' = _N
        qui sum `nj'
        local njmax `r(max)'
        local combos = 2^`njmax'
        if !mi(`combos') {
            qui ds `varlist' `avars' `zvars'
            local allvars `r(varlist)'
            local maxvars `:list sizeof allvars'
            local mib = (`combos' / (1024 * 1024)) * (15 + `maxvars')
            if ( (mi(`mib') | (`mib' > 256)) & ("`algorithm'" == "matrix") ) {
                local algorithm loop
                if ("`debug'" != "") di "(there were `njmax' groups; falling back to algorithm(loop))"
            }
        }
    }

    ***********************************************************************
    *                             Run alogit                              *
    ***********************************************************************

    * Options for -moptimize()-
    scalar difficult = `:di ("`difficult'" == "difficult")'
    local  technique = "`technique'"
    scalar iterate   = `iterate'

    * Set up for full run in C
    if inlist("`algorithm'", "fast", "faster") {
        qui count if `touse'
        local N = `r(N)'
        tempvar in1 in2 index nj tag
        gen `index' = _n
        by `notouse' `group': gen `tag' = (_n == 1)
        by `notouse' `group': gen `in1' = `index'[1]
        by `notouse' `group': gen `in2' = `index'[_N]
        by `notouse' `group': gen `nj'  = _N
        qui count if `touse' & `tag'
        local J = `r(N)'
        local kx:  list sizeof xvars
        local kxz: list sizeof xzvars
        local ktot = `kx' + `kxz'
        matrix __alogit_H      = J(`ktot', `ktot',  0)
        matrix __alogit_g      = J(1, `ktot',  0)
        scalar __alogit_ll     = .
        scalar __alogit_kx     = `kx'
        scalar __alogit_kxz    = `kxz'
        scalar __alogit_ktot   = `ktot'
        scalar __alogit_getdef = `:di ("`default'" != "") & ("`consider'" == "")'
        scalar __alogit_asexp  = ( "`exp'" == "exp" )
        local cvarlist `depvar' `default'`consider' `in1' `in2' `nj' `xvars' `xzvars'
        local fastcall `cvarlist' if `touse' & `tag' in 1 / `N', `J'
    }

    * Get the name of the optimization and predict mata functions
    if ( "`model'" == "dsc" ) local adddsc dsc_
    if inlist("`algorithm'", "fast", "faster") local addfast _fast
    else if ( "`algorithm'" == "loop" ) local addloop _loop
    local mata_loglik  _alogit_`adddsc'`method'`addfast'`addloop'
    local mata_predict alogit_`adddsc'predict`addloop'

    * Get results from Mata; the likelihood is only computed by Mata for
    * algorithms loop and matrix. For fast and faster, we can call the C
    * plugin directly from Stata
    di "Using method '`method'' to compute the likelihood."
    clear results
    if ( `:di ("`loglik'" != "")' & inlist("`algorithm'", "fast", "faster") ) {
        matrix __alogit_b = b0, d0
        plugin call aloglik_`algorithm' `fastcall' `model'_p ll
        scalar ll = __alogit_ll
    }
    else {
        mata: alogitM = alogit(`dlabels', &`mata_loglik'(), &`mata_predict'())
    }
    matrix b0 = b0, d0

    if inlist("`algorithm'", "fast", "faster") {
        scalar __alogit_mp0 = 0
        plugin call aloglik_`algorithm' `fastcall' `model'_p mp0
        scalar mp0 = __alogit_mp0
        if ("`model'" == "dsc") {
            scalar __alogit_mp1 = 0
            plugin call aloglik_`algorithm' `fastcall' `model'_p mp1
            scalar mp1 = __alogit_mp1
        }
    }

    if ( `:di ("`loglik'" != "")' ) {
        ereturn clear
        qui count if `touse'
        matrix b = b0
        cap ereturn post b, esample(`touse') obs(`r(N)')
        if ( _rc != 0 ) {
            di as err "Failed to post results; will not be able to use -predict-."
            di as err "Pass custom parameters to -predict- directly via -fit()-."
        }
        mata: st_numscalar("e(loglik)", `:di scalar(ll)')
        ereturn matrix b0 = b0
        ereturn local  depvar    "`depvar'"
        ereturn local  indepvars "`xvars'"
        ereturn local  avars     "`:list xzvars - _cons'`_cons_label'"
        ereturn local  group     "`group'"
        ereturn local  default   "`default'"
        ereturn local  consider  "`consider'"
        ereturn local  method    "`method'"
        ereturn local  model     "`model'"
        ereturn local  algorithm "`algorithm'"
        ereturn local  afit      "loglik"
        ereturn local  predict   "alogit_p`addfast'"
        ereturn scalar expb      = 0
        capture mata: mata drop `dlabels'
        exit 0
    }

    * Set return and ereturn values
    cap mata: moptimize_result_post(alogitM)
    if ( _rc == 0 ) {
        if ( (`:di scalar(mp0)' > 0.01) & ("`model'" == "alogit") ) {
            if ( "`default'" == "" ) local adds "; specify -default()-"
            di as txt _n(1) "Average probability of an empty choice set was " ///
                      "`:di %4.3f scalar(mp0)' > 0.01`adds'" _n(1)
        }

        if ( ("`default'" == "") & ("`model'" == "dsc") ) {
            if ( `:di scalar(mp1)' < 0.01 ) {
                di as txt _n(1) "Average probability of attention was " ///
                                "`:di %4.3f `:di scalar(mp1)'' < 0.01" _n(1)
            }
        }

        mata: st_matrix("e(Hessian)",    moptimize_result_Hessian(alogitM))
        mata: st_numscalar("e(loglik0)", moptimize_result_value0(alogitM))
        mata: st_numscalar("e(loglik)",  moptimize_result_value(alogitM))
        mata: st_numscalar("loglik",     moptimize_result_value(alogitM))
        mata: printf("\nAttentive logit regression" +                    ///
                     "                        Log likelihood  = %10.5f", ///
                     `:di scalar(loglik)')
        mata: moptimize_result_display(alogitM)
        ereturn matrix b0  = b0
        ereturn scalar mp0 = `:di scalar(mp0)'
        if ("`model'" == "dsc") {
            ereturn scalar mp1 = `:di scalar(mp1)'
        }

        ereturn local  afit      "full"
        ereturn local  predict   "alogit_p`addfast'"
        ereturn local  indepvars "`xvars'"
        ereturn local  avars     "`:list xzvars - _cons'`_cons_label'"
        ereturn local  group     "`group'"
        ereturn local  default   "`default'"
        ereturn local  consider  "`consider'"
        ereturn local  method    "`method'"
        ereturn local  model     "`model'"
        ereturn local  algorithm "`algorithm'"
        ereturn scalar expb      = ( "`exp'" == "exp" )

        capture mata: mata drop `dlabels'
    }
    else {
        capture mata: mata drop `dlabels'
        exit 400
    }
end

cap program drop aloglik_fast
if ( inlist("`c(os)'", "Unix") & (`c(bit)' == 64) ) cap program aloglik_fast, plugin using("aloglik_fast.plugin")

cap program drop aloglik_faster
if ( inlist("`c(os)'", "Unix") & (`c(bit)' == 64) ) cap program aloglik_faster, plugin using("aloglik_faster.plugin")
