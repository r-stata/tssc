*! 1.0.0 JDeutsch/MJacobus/AVigil 06feb2017
*! Mathematica Policy Research, Inc.

capture program drop rmpw
program define       rmpw, eclass
qui {

  version 14.1

  *** Parsing/Macros

  if c(N) == 0 {

    di as err "No using dataset in memory"
    exit 198

  }

  syntax anything [if] [in] [aweight pweight/], [PSmodel(string)]    ///
                                                [WINITial(passthru)] ///
                                                [QUICKDerivatives]   ///
                                                [vce(passthru)]

  _parse_varlist `anything'

  foreach mac in `s(parse_elems)' {

    if "`s(`mac')'" != "" local `mac' = s(`mac')
    else                  local `mac'

  }

  marksample touse
  markout   `touse' `yvar' `treat' `med' `covarsprop' `covarsout'

  if "`weight'" != "" {

    local wgt         "[`weight'=`exp']"
    local wgt_psmodel "[pw=`exp']"

  }
  else {

    local wgt         ""
    local wgt_psmodel ""

  }

  if `"`winitial'"' == "" local winitial "winitial(unadjusted, independent)"
  if `"`vce'"'      == "" local vce      "vce(robust)"

  *** Vet parameters

  *-  Vet vce option

  _vet_vce `"`vce'"'

  if "`s(cvar)'" != "" {

    markout `touse' `s(cvar)', strok

  }

  *-  Now that touse is fully-defined, exit if touse never equals 1

  count if `touse' == 1
  if r(N) == 0 {

    di as err "No observations in the estimation sample"
    exit 198

  }

  *-  Parameter psmodel can only be blank, logit, or probit

  local psmodel = lower(trim(`"`psmodel'"'))

  capt assert inlist(`"`psmodel'"', "", "logit", "probit")
  if _rc {

    di as error `"The value specified for psmodel (`psmodel') has to equal "logit" or "probit" (or blank)"'
    exit 198

  }

  if "`psmodel'"  == "" local psmodel "logit"

  *-  Treatment or mediator variables are not binary

  foreach var in `treat' `med' {

    capture assert inlist(`var', 0, 1) | missing(`var') if `touse'

    if _rc != 0 {

      di as error "The variable `var' is not binary (0, 1, or missing)"
      exit 198

    }

  }

  *-  One (or more) of the 4 treat*mediator cells contains zero observations

  local lvls 0

  forvalues t=0/1 {

    forvalues m=0/1 {

      count if `treat' == `t' & `med' == `m' & `touse'

      if r(N) > 0 {

        local ++lvls

      }
      else {

        di as err "There are no records in the estimation sample where `treat'==`t' and `med'==`m'"

      }

    }

  }

  if `lvls' != 4 exit 198

  *-  The outcome variable does not vary sufficiently

  summarize `yvar' if `touse'
  if r(Var) == 0 {

    di as error "The outcome variable `yvar' has no variation"
    exit 198

  }

  *-  The treatment effect on the mediator is not statistically significant

  logit `med' `treat' `wgt_psmodel' if `touse', level(95) `vce'
  test `treat'
  if float(r(p)) > float(0.05) {

    nois di as txt _n "WARNING: The treatment effect on the mediator is not statistically significant at the 0.05 level"

  }

  *** Estimation

  *-  Expand out covariate lists

  _rmcoll `covarsprop' `wgt' if `touse', expand
  local covarsprop "`r(varlist)'"

  if "`covarsout'" != "" {

    _rmcoll `covarsout' `wgt' if `touse', expand
    local covarsout "`r(varlist)'"

  }

  *-  Determine starting values for gmm

  *   (NOTE: This helps gmm converge by providing it with the correct coeffficients.
  *          gmm is being used to get accurate standard errors.)

  *-- Estimate propensity score models

  forvalues t=0/1 {

    tempvar   p`t'
    tempname eb`t'

    nois di as txt _n "----- 1. `psmodel' for `treat' == `t' -----"

    nois `psmodel' `med' `covarsprop' `wgt_psmodel' if `treat' == `t' & `touse', `vce'
    predict `p`t'', pr
    matrix `eb`t'' = e(b)

  }

  *-- Generate RMPW weights

  tempvar rmpw

  gen double `rmpw' = .m
  replace    `rmpw' = `p0'/`p1'           if `treat' == 1 & `med' == 1
  replace    `rmpw' = (1-`p0') / (1-`p1') if `treat' == 1 & `med' == 0
  replace    `rmpw' = `p1'/`p0'           if `treat' == 0 & `med' == 1
  replace    `rmpw' = (1-`p1') / (1-`p0') if `treat' == 0 & `med' == 0

  if "`weight'" != "" {

    replace `rmpw' = `rmpw' * `exp'

  }

  drop `p0' `p1'

  *-- Estimate model to generate t/c means as well as covarsout starting values

  tempname deltac deltat ebout deltastart deltastarc fromval

  nois di as txt _n "----- 2. OLS model -----"

  nois regress `yvar' `treat' `covarsout' `wgt' if `touse', `vce'
  matrix `deltac' = _b[_cons]
  matrix `deltat' = _b[_cons] + _b[`treat']

  if "`covarsout'" != "" {

    local Ncovarsout : word count `covarsout'

    matrix `ebout' = J(1, `Ncovarsout', 0)

    forvalues c=1/`Ncovarsout' {

      matrix `ebout'[1, `c'] = _b[`: word `c' of `covarsout'']

    }

  }

  tempvar  resid semi_resid
  predict `resid', residuals
  gen double `semi_resid' = `resid' + _b[_cons] + _b[`treat']*`treat'

  sum `semi_resid' [aw=`rmpw'] if `treat' == 1 & `touse'
  matrix `deltastart' = r(mean)

  sum `semi_resid' [aw=`rmpw'] if `treat' == 0 & `touse'
  matrix `deltastarc' = r(mean)

  drop `rmpw' `resid' `semi_resid'

  if "`covarsout'" != "" matrix `fromval' = `eb1', `eb0', `deltat', `ebout', `deltac', `deltastart', `deltastarc'
  else                   matrix `fromval' = `eb1', `eb0', `deltat',          `deltac', `deltastart', `deltastarc'

  *   (END of starting value section)

  *-  Run GMM

  *-- Specify equations

  *   1. Propensity score model for treatment group
  *   2. Propensity score model for control group
  *   3. Treatment group outcome (deltaT)
  *   4. Control   group outcome (deltaC)
  *   5. Weighted treatment group outcome (deltaStarT)
  *   6. Weighted control   group outcome (deltaStarC)
  *   7. Model for estimating coefficients associated with covariates in outcome model

  if "`covarsout'" == "" {

    local xbout_init "0"
    local xbout      "0"

  }
  else {

    local xbout_init "{xbout: `covarsout'}"
    local xbout      "{xbout:}"

  }

  *--- EQ 1 and 2

  if "`psmodel'" == "logit" {

    local 1_propscore_T (`med' - ( 1 / ( 1 + exp(-{xbT: `covarsprop' _cons})))) *      `treat'
    local 2_propscore_C (`med' - ( 1 / ( 1 + exp(-{xbC: `covarsprop' _cons})))) * (1 - `treat')

  }
  else {

    local 1_propscore_T (`med' - normal({xbT: `covarsprop' _cons})) *      `treat'
    local 2_propscore_C (`med' - normal({xbC: `covarsprop' _cons})) * (1 - `treat')

  }

  *--- EQ 3 and 4

  local 3_outcome_T (`yvar' - {deltaT} - `xbout_init') *      `treat'
  local 4_outcome_C (`yvar' - {deltaC} - `xbout')      * (1 - `treat')

  *--- EQ 5 and 6

  foreach tc in T C {

    if "`psmodel'" == "logit" {

      local  p`tc'               "1 / (1 + exp(-{xb`tc':}))"
      local mp`tc' "exp(-{xb`tc':}) / (1 + exp(-{xb`tc':}))"

    }
    else {

      local  p`tc'     "normal({xb`tc':})"
      local mp`tc' "1 - normal({xb`tc':})"

    }

  }

  local weight5 ((`med' * ((`pC') / (`pT'))) + ((1 - `med') * (`mpC') / (`mpT')))
  local weight6 ((`med' * ((`pT') / (`pC'))) + ((1 - `med') * (`mpT') / (`mpC')))

  local 5_outcome_wgt_T (`yvar' - {deltaStarT} - `xbout') * `weight5' *      `treat'
  local 6_outcome_wgt_C (`yvar' - {deltaStarC} - `xbout') * `weight6' * (1 - `treat')

  *--- EQ 7

  if "`covarsout'" != "" {

    local 7_covarsout (`=subinstr("`3_outcome_T'", " `covarsout'", "", 1)') + (`4_outcome_C') + (`5_outcome_wgt_T ') + (`6_outcome_wgt_C')

  }
  else {

    local 7_covarsout ""

  }

  *-- Specify instruments

  local 1_propscore_T_inst `covarsprop'
  local 2_propscore_C_inst `covarsprop'
  local 7_covarsout_inst   `covarsout'

  *-- Estimate GMM Model

  nois di as txt _n "----- 3. GMM -----"

  nois gmm (eq1: `1_propscore_T')    (eq2: `2_propscore_C')                                       ///
           (eq3: `3_outcome_T')      (eq4: `4_outcome_C')                                         ///
           (eq5: `5_outcome_wgt_T ') (eq6: `6_outcome_wgt_C')                                     ///
           `=cond("`7_covarsout'" != "", "(eq7: `7_covarsout')", "")'                             ///
           `wgt' if `touse' ,                                                                     ///
           instruments(eq1: `1_propscore_T_inst') instruments(eq2: `2_propscore_C_inst')          ///
           instruments(eq3: ) instruments(eq4: )                                                  ///
           instruments(eq5: ) instruments(eq6: )                                                  ///
           `=cond("`7_covarsout'" != "", "instruments(eq7: `7_covarsout_inst', noconstant)", "")' ///
           onestep from(`fromval') `winitial' `quickderivatives' `vce'

  if e(converged) != 1   exit

  if "`covarsout'" == "" nois _equal_coeffs `fromval'

  *--  Post-estimation

  nois di as txt _n "Intent-to-treat (ITT) effect"
  nois lincom _b[/deltaT] - _b[/deltaC]

  ereturn scalar itt_b  = r(estimate)
  ereturn scalar itt_se = r(se)

  nois di as txt _n "Direct effect"
  nois lincom _b[/deltaStarT] - _b[/deltaC]

  ereturn scalar de_b  = r(estimate)
  ereturn scalar de_se = r(se)

  nois di as txt _n "Indirect effect"
  nois lincom _b[/deltaT] - _b[/deltaStarT]

  ereturn scalar ie_b  = r(estimate)
  ereturn scalar ie_se = r(se)

  nois di as txt _n "Pure indirect effect"
  nois lincom _b[/deltaStarC] - _b[/deltaC]

  ereturn scalar pie_b  = r(estimate)
  ereturn scalar pie_se = r(se)

  nois di as txt _n "Treatment-by-mediator interaction effect"
  nois lincom _b[/deltaT] + _b[/deltaC] - _b[/deltaStarC] - _b[/deltaStarT]

  ereturn scalar txm_b  = r(estimate)
  ereturn scalar txm_se = r(se)

}
end

*** Parsing subroutines

*-  Vetting the vce option, which is supplied to all estimation commands called by rmpw

capture program drop _vet_vce
program define       _vet_vce, sclass

  version 14.1
  sreturn clear

  syntax anything(name=vce)

  if regexm(`vce', "^vce[ ]*\([ ]*(cl|clu|clus|clust|cluste|cluster)[ ]+([a-zA-Z0-9_][a-zA-Z0-9_\.\#\(\)\/]*)[ ]*\)$") {

    capture noisily confirm variable `=regexs(2)'
    if _rc == 101 di as err "with option vce(cluster clustvar)"
    if _rc != 0 exit 198

    sreturn local cvar "`=regexs(2)'"

  }
  else if !( regexm(`vce', "^vce[ ]*\([ ]*(r|ro|rob|robu|robus|robust)[ ]*\)$")                   | ///
             regexm(`vce', "^vce[ ]*\([ ]*(boot|boots|bootst|bootstr|bootstra|bootstrap)[ ]*\)$") | ///
             regexm(`vce', "^vce[ ]*\([ ]*(jack|jackk|jackkn|jackkni|jackknif|jackknife)[ ]*\)$") ) {

    di as err "The value specified for the vce option can only equal robust, cluster clustvar, bootstrap, or jackknife"
    exit 198

  }

end

*-  Parsing the variable syntax and issuing basic syntax err ors

capture program drop _parse_varlist
program define       _parse_varlist, sclass

  version 14.1
  sreturn clear

  syntax anything

  if regexm("`anything'", "^\((.*[^ ]+.*)\)[ ]*\((.*[^ ]+.*)\)[ ]*\((.*[^ ]+.*)\)$") {

    local outcome   = trim(regexs(1))
    local treat     = trim(regexs(2))
    local mediator  = trim(regexs(3))

    local anybadvar 0

    foreach s in outcome treat mediator {

      local balance 0

      forvalues i=1/`=length(`"``s''"')' {

        local curr = substr(`"``s''"', `i', 1)

        if      `"`curr'"' == "(" {

          local ++balance

        }
        else if `"`curr'"' == ")" {

          local --balance

        }

        if (`balance' < 0) | ((`i' == `=length(`"``s''"')') & `balance' != 0) {

          di as err "Invalid rmpw specification; check use of parentheses"
          exit 198

        }

      }

      capt unab `s' : ``s''

      if "`s'" == "treat" & `: word count `treat'' > 1 {

        di as err "Equation 2 can only contain one variable; the treatment variable"

        local anybadvar 1

      }

      if "`s'" == "mediator" & `: word count `mediator'' < 2 {

        di as error "Invalid rmpw specification; no propensity model covariates (covarsprop) specified"

        local anybadvar 1

      }

      local viter 0
      foreach var of local `s' {

        local ++viter

        if "`s'" == "treat" & `viter' > 1 continue, break

        capt unab dummy : `var'

        if _rc == 101 {

          capture noisily fvunab var : `var'

          if `viter' == 1 {

            di as err "The `s' variable cannot be a factor variable"

            local anybadvar 1

          }

        }
        else {

          capture noisily confirm numeric variable `var'

        }

        if _rc != 0 local anybadvar 1

      }

    }

    if `anybadvar' == 1 exit 198

    tokenize `outcome'
    sreturn local yvar `1'
    macro shift
    sreturn local covarsout `*'

    sreturn local treat "`treat'"

    tokenize `mediator'
    sreturn local med `1'
    macro shift
    sreturn local covarsprop `*'

    sreturn local parse_elems "yvar covarsout treat med covarsprop"

  }
  else {

    di as err "Invalid rmpw specification; check use of parentheses"
    exit 198

  }

end

*** Comparing the starting coefficients (logit/probit) against the final coefficients (gmm)

capture program drop _equal_coeffs
program define       _equal_coeffs
qui {

  version 14.1

  syntax name(name=start_eb)

  tempname gmm_eb
  matrix  `gmm_eb' = e(b)

  local lc = colsof(`start_eb')
  local gc = colsof(  `gmm_eb')

  capt assert `lc' == `gc'
  if _rc != 0 {

    di as err "The number of elements in the from() input matrix is different from the coefficients output by gmm!"
    exit _rc

  }

  forvalues c=1/`lc' {

    capt assert abs(`=`start_eb'[1,`c']' - `=`gmm_eb'[1,`c']') <= 1e-4
    if _rc != 0 {

      nois di as txt _n "WARNING: The GMM estimates differ from the starting values"
      continue, break

    }

  }

}
end
