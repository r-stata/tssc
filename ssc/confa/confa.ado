*! v.2.1.1 Confirmatory factor analysis, by Stas Kolenikov, skolenik at gmail dot com, 02 Feb 2010
program define confa, eclass properties( svyr svyb svyj ) sortpreserve
  version 10.0

  if replay() {
     if ("`e(cmd)'" != "confa") error 301
     Replay `0'
  }

  else {
    Estimate `0'
  }

end

program define Estimate, eclass properties( svyr svyb svyj )

  syntax anything [if] [in] [aw pw iw/ ], [ ///
     UNITvar(str) /// provides the list of factors where unit variance identification is used
     FREE /// estimate all parameters as free -- the user provides identification through constraints
     CONSTRaint(numlist)  /// see the previous one
     FROM(str) /// starting values, compliant with -ml init- syntax
     LEVel(int $S_level) ROBust VCE(string) CLUster(passthru) /// standard errors and inference
     LOGLEVel(int 1) /// logging level
     CORRelated(string) /// correlated measurement errors
     SUBtractone /// subtract one from the sample size in places
     USENames ///
     MISSing /// allow for special treatment of missing data
     SVY  * ]

  * preliminary work
  global CONFA_loglevel = `loglevel'
  qui mata : mata mlib index

  /* was before v.2.1
  cap bothlist a \ b, global( CONFA_t )
  if _rc==199 {
     * listutil not installed
     di as err "listutil not found, trying to install from SSC..."
     ssc install listutil
  }
  */

  if "`subtractone'"~="" local subtractone -1

  *** MISSING
  tempvar touse
  marksample touse, zeroweight
  global CONFA_touse `touse'
  if $CONFA_loglevel > 2 tab $CONFA_touse

  * weights?
  if "`weight'" ~= "" {
     global CONFA_wgt [`weight'=`exp']
     global CONFA_wgti [iw=`exp']
  }

  * initial values?
  if "`from'"~="" {
    if "`from'" == "iv" | "`from'" == "IV" | "`from'" == "ivreg" | "`from'" == "2SLS" {
      if "`unitvar'" ~= "" {
         di as err "cannot specify from(`from') and unitvar at the same time"
         CleanIt
         exit 198
      }
      else global CONFA_init IV
    }
    else if "`from'" == "ones" global CONFA_init ones
    else if "`from'" == "smart" global CONFA_init smart
    else {
       gettoken isitmat isitnot : from , parse(",")
       cap confirm matrix `isitmat'
       if _rc {
          di "{err}Warning: matrix `isitmat' not found"
          * do something sensible instead
          global CONFA_init smart
       }
       else {
          * do nothing --- let the hell break loose
          global CONFA_init
       }
    }
  }

  * vce?
  if "`vce'" ~= "" {
    gettoken vce1 rest : vce, parse(" ,")
    CheckVCE , `vce1'
    local lvce = length("`vce'")
    if `"`vce'"' != substr("sbentler", 1, max(2, `lvce')) ///
       & `"`vce'"' != substr("satorrabentler", 1, max(3, `lvce')) {
       local vceopt vce(`vce')
    }
  }

  if $CONFA_loglevel > 2 di as text "Parsing..."
  cap noi Parse `anything'
  if _rc {
     CleanIt
     exit 198
  }

  * copy everything down -- -ivreg- cleans -sreturn-
  local obsvar=s(obsvar)
  global CONFA_obsvar `obsvar'

  local nobsvar : word count `obsvar'
  local nfactors = s(nfactors)
  forvalues k=1/`nfactors' {
    local indicators`k' = s(indicators`k')
    local name`k' = s(name`k')
    local factorlist `factorlist' `name`k''
  }

  * begin collecting the equations, starting values, bounds, and model structure
  if $CONFA_loglevel > 2 di as text "Setting the structure up..."
  Structure, unitvar(`unitvar') correlated(`correlated') `usenames'
  local nicecorr $CONFA_t
  * produces a bunch of globals

  * did we need all this starting values business at all?
  gettoken isitmat isitnot : from , parse(",")
  cap confirm matrix `isitmat'
  if ~_rc | strpos("`from'",",") {
     * the user has provided the starting values
     global CONFA_start `from'
  }
  else {
    * not a matrix, no comma: use our ugly computations
    global CONFA_start $CONFA_start, copy
  }
*  if "$CONFA_bounds" ~= "" global CONFA_bounds bounds($CONFA_bounds)

  if $CONFA_loglevel > 3 di `"  ml model lf confa_lf $CONFA_toML $CONFA_wgt, constraint($CONFA_constr `constraint') `svy' `robust' `cluster' init($CONFA_start) bounds($CONFA_bounds) `options' maximize"'

  tempvar misspat touse1
  global CONFA_miss `misspat'
  qui gen byte `touse1' = 1-$CONFA_touse
  if "`missing'" != "" {
     if $CONFA_loglevel > 1 di "{txt}Working on missing values..."
     * cycle over the observed variables, create missing indicators
     forvalues k=1/`nobsvar' {
         local thisvar : word `k' of `obsvar'
         tempvar miss`k'
         qui gen byte `miss`k'' = mi( `thisvar' ) if $CONFA_touse
         local misslist `misslist' `miss`k''
     }

     * sort by pattern: relevant observations first
     * when $CONFA_touse==0 `misslist' will be missing
     qui {
       bysort `touse1' `misslist' : gen long $CONFA_miss = (_n==1)
       replace $CONFA_miss = sum( $CONFA_miss )
       replace $CONFA_miss = . if mi( $CONFA_touse )
     }
     cap assert $CONFA_miss == 1 if $CONFA_touse
     local anymissing = _rc
     if !`anymissing' {
        di "{txt}Option missing specified, but no missing data found"
     }
     else {
        qui tab $CONFA_miss
        di _n "{txt}Note: {res}" r(r) "{txt} patterns of missing data found"
     }
     if $CONFA_loglevel > 3 li $CONFA_miss `misslist'
  }
*  if "`anymissing'"=="0" | "`missing'" == "" {
  else {
     * -missing- option is omitted
     if $CONFA_loglevel > 1 di "{err}NOT {txt}working on missing values"
     markout $CONFA_touse `obsvar'
     qui gen byte $CONFA_miss = 1 if $CONFA_touse
     if $CONFA_loglevel > 2 {
        sum `obsvar' if $CONFA_touse
        tab $CONFA_miss, missing
     }
  }


  cap noi ml model lf confa_lfm $CONFA_toML $CONFA_wgt if $CONFA_touse, ///
      constraint($CONFA_constr `constraint') `svy' `robust' `cluster' `vceopt' ///
      init($CONFA_start) bounds($CONFA_bounds) `options' `missing' ///
      maximize

  local mlrc = _rc
  if `mlrc' {
     CleanIt
     error `mlrc'
  }

  * parametric matrices
  tempname bb
  mat `bb' = e(b)
  global CONFA_loglevel -1
  * to indicate to CONFA_StrucToSigma() that the matrices should be posted to Stata
  qui mata : CONFA_StrucToSigma(st_matrix("`bb'"))
  global CONFA_loglevel `loglevel'
  * now, post all those matrices to ereturn

  mat rownames CONFA_Sigma = `obsvar'
  mat colnames CONFA_Sigma = `obsvar'
  mat rownames CONFA_Lambda = `obsvar'
  mat colnames CONFA_Lambda = `factorlist'
  mat rownames CONFA_Phi = `factorlist'
  mat colnames CONFA_Phi = `factorlist'
  mat colnames CONFA_Theta = `obsvar'
  mat rownames CONFA_Theta = `obsvar'
  ereturn matrix Sigma = CONFA_Sigma, copy
  ereturn matrix Lambda = CONFA_Lambda, copy
  ereturn matrix Phi = CONFA_Phi, copy
  ereturn matrix Theta = CONFA_Theta, copy

  if "`missing'"!= "" ereturn local missing missing

  eret local observed `obsvar'
  eret local factors  `factorlist'
  if "`unitvar'" ~= "" {
     * need to unwrap the contents of `unitvar'...
     * or change its defintion from passthru to string
     if "`unitvar'" == "_all" eret local unitvar `factorlist'
     else eret local unitvar `unitvar'
  }
  forvalues k=1/`nfactors' {
    eret local factor`k' `name`k'' : `indicators`k''
  }
  if "`correlated'"!="" eret local correlated `nicecorr'

  if "`svy'`cluster'`exp'`robust'" == "" & "`vce'"!="robust" & substr("`vce'",1,2)!="cl" & "`missing'"=="" {

     * if the data are not i.i.d., LRT is not applicable
     * don't know what to do with missing data

     tempname S Sindep trind
     qui mat accum `S' = `obsvar' $CONFA_wgti if $CONFA_touse, dev nocons
     mat `S' = `S' / ( e(N) `subtractone' )
     mat `Sindep' = diag(vecdiag(`S'))

     * degrees of freedom
     local nconstr = `: word count $CONFA_constr' + `: word count `constraint''
     local pstar = `nobsvar' * (`nobsvar' + 1) / 2
     local df_m  = rowsof(CONFA_Struc) - `nobsvar' - `nconstr'
     ereturn scalar pstar = `pstar'

     * test against independence
     mat `trind' = trace( syminv(`Sindep') * `S' )
     local trind = `trind'[1,1]
     ereturn scalar ll_indep = -0.5 * `nobsvar' * e(N) * ln(2*_pi) - 0.5 * e(N) * ln(det(`Sindep')) - 0.5 * e(N) * `trind'
     ereturn scalar lr_indep = 2*(e(ll)-e(ll_indep))
     ereturn scalar df_indep = `pstar' - `nobsvar'
     ereturn scalar p_indep  = chi2tail(e(df_indep),e(lr_indep))

     * goodness of fit test
     ereturn scalar ll_0 = -0.5 * `nobsvar' * e(N) * ln(2*_pi) - 0.5 * e(N) * ln(det(`S')) - 0.5 * `nobsvar' * e(N)
     ereturn scalar df_u = `pstar' - `df_m'
     ereturn scalar lr_u = cond(e(df_u)==0,0,-2*(e(ll)-e(ll_0)))
     ereturn scalar p_u  = chi2tail(e(df_u),e(lr_u))

     * make the g.o.f. test the default test
     ereturn scalar df_m = `df_m'
     ereturn local chi2type LR
     ereturn scalar chi2 = e(lr_u)
     ereturn scalar p = e(p_u)

     * other crap
     ereturn matrix S = `S'

     if `"`vce'"'==substr("satorrabentler",1,max(3, length("`vce'"))) ///
       | "`vce'" ==substr("sbentler",1,max(4, length("`vce'"))) {
        * repost Satorra-Bentler covariance matrix
        * not defined for complex survey data,

        cap noi SatorraBentler, constraint(`constraint') `missing'

        if _rc {
           di as err "Satorra-Bentler standard errors are not supported; revert to vce(oim)"
        }
        else {

          tempname SBVar SBV Delta Gamma VV U trUG2 Tdf
          mat `SBVar' = r(SBVar)
          mat `Delta' = r(Delta)
          mat `Gamma' = r(Gamma)
          mat `SBV'   = r(SBV)
          mat `VV'    = e(V)
          mat `SBVar' = ( `VV'[1..`nobsvar',1..`nobsvar'], `VV'[1..`nobsvar',`nobsvar'+1 ...] ///
                        \ `VV'[`nobsvar'+1...,1..`nobsvar'], `SBVar'[`nobsvar'+1...,`nobsvar'+1...] )
          ereturn repost V = `SBVar'
          ereturn matrix SBGamma = `Gamma', copy
          ereturn matrix SBDelta = `Delta', copy
          ereturn matrix SBV = `SBV', copy
          ereturn local vce SatorraBentler
          ereturn local vcetype "Satorra-Bentler"

          * compute the corrected tests, too
          * only takes care of the covariance structure
          * Satorra-Bentler 1994
          mat `U' = `SBV' - `SBV'*`Delta'*syminv(`Delta''*`SBV'*`Delta')*`Delta''*`SBV'
          ereturn matrix SBU = `U'
          mat `U' = trace( e(SBU)*e(SBGamma) )
          ereturn scalar SBc = `U'[1,1]/e(df_u)
          ereturn scalar Tsc = e(lr_u)/e(SBc) * (e(N) `subtractone' ) / e(N)
          ereturn scalar p_Tsc = chi2tail( e(df_u), e(Tsc) )

          mat `trUG2' = trace( e(SBU)*`Gamma'*e(SBU)*`Gamma')
          ereturn scalar SBd = `U'[1,1]*`U'[1,1]/`trUG2'[1,1]
          ereturn scalar Tadj = ( e(SBd)/`U'[1,1]) * e(lr_u) * (e(N) `subtractone' ) / e(N)
          ereturn scalar p_Tadj = chi2tail( e(SBd), e(Tadj) )

* saddlepoint approximation comes here!!!

          * Yuan-Bentler 1997
          ereturn scalar T2 = e(lr_u)/(1+e(lr_u)/e(N) )
          ereturn scalar p_T2 = chi2tail( e(df_u), e(T2) )

        }
     }
  }

  * are we done yet?
  ereturn matrix CONFA_Struc = CONFA_Struc
  ereturn local predict confa_p
  ereturn local estat_cmd confa_estat
  ereturn local cmd confa

  Replay

  CleanIt

end

program define CleanIt
  * just in case
  return clear

  * release the constraints
  constr drop $CONFA_constr

  * clear the globals
  if $CONFA_loglevel < 3 {
     global CONFA_constr
     global CONFA_init
     global CONFA_loglevel
     global CONFA_toML
     global CONFA_start
     global CONFA_bounds
     global CONFA_args
     global CONFA_constr
     global CONFA_obsvar
     global CONFA_t
     global CONFA_wgt
     global CONFA_wgti
  }

  return clear

end

program define Parse, sclass

   * number of factors?
   local input `0'

   mata: st_local("nfactors",strofreal(CONFA_NF(`"`input'"')))

   if `nfactors' == 0 {
     * something terrible happened
     di as err "incorrect factor specification"
     exit 198
   }

   sreturn local nfactors `nfactors'

   tokenize `input', parse("()")

   local k = 0
   while "`1'"~="" {
     * right now, `1' should contain an opening bracket
     if "`1'"~="(" {
        * the first character is not a "("
        di as err "incorrect factor specification"
        exit 198
     }
     else {
        * the first character IS a "("
        mac shift
        * right now, `1' should contain a factor-type statement
        local ++k
        local factor`k' `1'
        mac shift
        * right now, `1' should contain a closing bracket
        if "`1'"~=")" {
           * the first character is not a ")"
           di as err "incorrect factor specification"
           exit 198
        }
        else mac shift
        * it may contain a space, I guess
        * then -mac shift- it again
        if trim("`1'")=="" mac shift
     }
   }
   forvalues k=1/`nfactors' {
     * now, parse each factor statement
     tokenize `factor`k'', parse(":")
     sreturn local name`k' `1'
     * `2' is the colon
     unab indicators : `3'
     sreturn local indicators`k' `indicators'
     local obsvar `obsvar' `indicators'
   }

   /* was:
   cap uniqlist `obsvar'
   if _rc == 199 {
     * uniqlist not found
     di as err "uniqlist not found, trying to install from SSC..."
     ssc install listutil
     uniqlist `obsvar'
   }
   */
   local obsvar : list uniq obsvar

* mata: st_local("obsvar",CONFA_UL(`"`obsvar'"'))

   sreturn local obsvar `obsvar'
   sreturn local nobsvar `: word count `obsvar''

end

program define Structure

  syntax , [unitvar(str) correlated(str) usenames]

  * implement usenames:
  * the parameters go along with the factor and variable names
  * rather than matrix indices

  * utilize all the sreturn results
  if $CONFA_loglevel > 3 sreturn list

  * copy everything down -- -ivreg- cleans -sreturn-
  local obsvar=s(obsvar)
  local nobsvar : word count `obsvar'
  local nfactors = s(nfactors)

  forvalues k=1/`nfactors' {
    local indicators`k' = s(indicators`k')
    local name`k' = s(name`k')
    local factorlist `factorlist' `name`k''
  }

  if "`unitvar'" == "_all" {
     local unitvar `factorlist'
  }

  * set up the labeling system
  if "`usenames'" != "" {
    * give the parameters varname labels
    forvalues k=1/`nobsvar' {
      local o`k' : word `k' of `obsvar'
    }
    forvalues k=1/`nfactors' {
      local f`k' `name`k''
    }
  }
  else {
    * give the parameters numberic lables
    forvalues k=1/`nobsvar' {
      local o`k' `k'
    }
    forvalues k=1/`nfactors' {
      local f`k' `k'
    }
  }

  * returns:
  * - ML equations
  * - ML bounds
  * - the structure matrix
  * - ML statement for the likelihood evaluator

  * initialize everything
  local eqno = 0
  global CONFA_toML
  global CONFA_start
  global CONFA_args
  global CONFA_constr
  global CONFA_bounds
  mata : CONFA_Struc = J(0,4,.)

  * process the means first
  tokenize `obsvar'
  forvalues j=1/`nobsvar' {
     * 1. equations to ML
     local ++eqno
     global CONFA_toML $CONFA_toML (mean_`o`j'':)
     * 2. starting values
     sum ``j'', mean
     global CONFA_start $CONFA_start `r(mean)'
     * 3. confa_lf arguments
     global CONFA_args $CONFA_args mean_`o`j''
     * 4. CONFA structure
     mata : CONFA_Struc = CONFA_Struc \ (1, `eqno', `j', 0)
  }

  * next, process lambda's
  forvalues k=1/`nfactors' {
    * determine if unitvar is needed here
    local scale`k' : list name`k' & unitvar
    * was: bothlist `name`k'' \ `unitvar', global(CONFA_t)
    * was: if "$CONFA_t" ~= "" {
    if "`scale`k''" ~= "" {
       * identification by unit variance, no scaling variables
       local scalevar
    }
    else {
       * identification by the scaling variable: the 1st one on the list
       local scalevar : word 1 of `indicators`k''
    }
    forvalues j=1/`nobsvar' {
      * determine whether `k'-th factor loads on `j'-th variable
      if strpos( " `indicators`k'' ", " ``j'' ") {
         * 1. equations to ML
         local ++eqno
         global CONFA_toML $CONFA_toML (lambda_`o`j''_`f`k'':)
         * 2. starting values
         local r2_`j' = 0.5
         if "``j''" == "`scalevar'" {
            * the current one is the scaling variable
            * set up the constraints, initialize to 1
            global CONFA_start $CONFA_start 1
            constraint free
            local nconstr = r(free)
            constraint `nconstr' [lambda_`o`j''_`f`k'']_cons = 1
            global CONFA_constr $CONFA_constr `nconstr'
         }
         else if "$CONFA_init" == "IV" {
              * initialize by a simple version of instrumental variables
              * use the remaining indicators of this factor as instruments
              * was before v.2.1: dellist `indicators`k'', delete(`scalevar' ``j'')
              * local ivlist = r(list)
              local ivlist : list obsvar - scalevar
              local ivlist : list ivlist - `j'
              if "`ivlist'" == "." {
                di as err "Warning: no instruments available for ``j''"
                local ivl = 1
              }
              else {
                qui ivreg ``j'' (`scalevar' = `ivlist')
                local ivl = _b[`scalevar']
              }
              global CONFA_start $CONFA_start `ivl'
              if !mi(e(r2)) local r2_`j' = e(r2)
         }
         else if "$CONFA_init" == "ones" {
            global CONFA_start $CONFA_start 1
         }
         else {
            * no init options
            global CONFA_start $CONFA_start 0
         }
         global CONFA_bounds $CONFA_bounds /lambda_`o`j''_`f`k'' -100 100
         * 3. confa_lf arguments
         global CONFA_args $CONFA_args lambda_`o`j''_`f`k''
         * 4. CONFA structure
         mata : CONFA_Struc = CONFA_Struc \ (2, `eqno', `j', `k')
      }
    }
  }

  * next, process Phi matrix
  forvalues k=1/`nfactors' {
    local scalevar1 : word 1 of `indicators`k''

    foreach kk of numlist `k'/1 {
      * 1. equations to ML
      local ++eqno
      global CONFA_toML $CONFA_toML (phi_`f`kk''_`f`k'':)
      * 2. starting values
      if `k' == `kk' {
         * diagonal entry
         * was: bothlist `name`k'' \ `unitvar', global(CONFA_t)
         * was: if "$CONFA_t" ~= "" {
         local scale`k' : list name`k' & unitvar
         if "`scale`k''" ~= "" {
            * identification by unit variance
            constraint free
            local nconstr = r(free)
            constraint `nconstr' [phi_`f`k''_`f`k'']_cons = 1
            global CONFA_constr $CONFA_constr `nconstr'
            local v`k' = 1
         }
         else {
            * identification by the scaling variable
            if "$CONFA_init" == "smart" | "$CONFA_init" == "IV" {
              qui sum `scalevar1'
              local v`k' = r(Var)*0.5
            }
            else if "$CONFA_init" == "ones" local v`k' = 1
            else local v`k' = 0
         }
         global CONFA_start $CONFA_start `v`k''
         global CONFA_bounds $CONFA_bounds /phi_`f`k''_`f`kk'' 0 1000
      }
      else {
        * off-diagonal entry
         if "$CONFA_init" == "smart" | "$CONFA_init" == "IV" {
            local scalevar2 : word 1 of `indicators`kk''
            qui corr `scalevar1' `scalevar2'
            local v = 0.5*r(rho)*sqrt(`v`k''*`v`kk'')
         }
         else if "$CONFA_init" == "ones" local v = 0.5
              else local v = 0
         local vv = 1.5*abs(`v') + 0.01
         global CONFA_start $CONFA_start `v'
         global CONFA_bounds $CONFA_bounds /phi_`f`kk''_`f`k'' -`vv' `vv'
      }
      * 3. confa_lf arguments
      global CONFA_args $CONFA_args phi_`f`kk''_`f`k''
      * 4. CONFA structure
      mata : CONFA_Struc = CONFA_Struc \ (3, `eqno', `kk', `k')
    }

  }

  * residual variances
  forvalues j=1/`nobsvar' {
     * 1. equations to ML
     local ++eqno
     global CONFA_toML $CONFA_toML (theta_`o`j'':)
     * 2. starting values
     if "$CONFA_init" == "ones" {
        local v_`j' = 1
     }
     else if "$CONFA_init" == "IV" | "$CONFA_init" == "smart" {
       qui sum ``j''
       local v_`j' = r(Var)*(1-`r2_`j'')
     }
     else local v_`j' = 0.01
     global CONFA_start $CONFA_start `v_`j''
     global CONFA_bounds $CONFA_bounds /theta_`o`j'' 0 1000
     * 3. confa_lf arguments
     global CONFA_args $CONFA_args theta_`o`j''
     * 4. CONFA structure
     mata : CONFA_Struc = CONFA_Struc \ (4, `eqno', `j', 0)
  }

  * the error correlations
  while "`correlated'" != "" {
     gettoken corrpair correlated : correlated , match(m)
     gettoken corr1 corrpair : corrpair, parse(":")
     unab corr1 : `corr1'
     gettoken sc corr2 : corrpair, parse(":")
     unab corr2 : `corr2'

     * make sure both are present in the list of observed variables

     * was before v.2.1: poslist `obsvar' \ `corr1', global(CONFA_t)
     * was : local k1 = $CONFA_t
     local k1 : list posof `"`corr1'"' in obsvar
     if `k1' == 0 {
        di as err "`corr1' is not among the observed variables"
        CleanIt
        exit 198
     }
     * was: poslist `obsvar' \ `corr2', global(CONFA_t)
     * local k2 = $CONFA_t
     local k2 : list posof `"`corr2'"' in obsvar
     if `k2' == 0 {
        di as err "`corr2' is not among the observed variables"
        CleanIt
        exit 198
     }

     * will be empty @ the first call
     local nicecorr `nicecorr' (`corr1':`corr2')

     * 1. equations to ML
     local ++eqno
     global CONFA_toML $CONFA_toML (theta_`o`k1''_`o`k2'':)
     * 2. starting values
     global CONFA_start $CONFA_start 0
     local vv = sqrt(`v_`k1''*`v_`k2'')
     global CONFA_bounds $CONFA_bounds /theta_`o`k1''_`o`k2'' -`vv' `vv'
     * 3. confa_lf arguments
     global CONFA_args $CONFA_args theta_`o`k1''_`o`k2''
     * 4. CONFA structure
     mata : CONFA_Struc = CONFA_Struc \ (5, `eqno', `k1', `k2')
  }
  if "`nicecorr'"!="" global CONFA_t `nicecorr'

  if $CONFA_loglevel > 3 {
     di as text "ML input (" as res `: word count $CONFA_toML' as text "): " as res "$CONFA_toML"
     di as text "Starting values (" as res `: word count $CONFA_start' as text "): " as res "$CONFA_start"
     di as text "Likelihood evaluator (" as res `: word count $CONFA_args' as text"): " as res "$CONFA_args"
     di as text "Constraints (" as res `nfactors' as text "): " as res "$CONFA_constr"
     di as text "Correlated errors: " as res "`nicecorr'"
     constraint dir $CONFA_constr
     mata : CONFA_Struc
  }
  mata : st_matrix("CONFA_Struc",CONFA_Struc)


end

program define Replay

  syntax, [posvar llu(str) level(passthru)]

  * get the implied matrix
  tempname bb Sigma
  mat `bb' = e(b)
  * mata : st_matrix("Sigma",CONFA_StrucToSigma(st_matrix("`bb'")))
  mat `Sigma' = e(Sigma)
  mat CONFA_Struc = e(CONFA_Struc)

  * determine what kind of labeling has been used
  * RATHER FRAGILE: checking for mean_1 rather than trying to find
  * whether option usenames was specified
  cap local whatis = [mean_1]_cons
  if _rc {
    * mean_1 not found => labeling by names
    forvalues k=1/`: word count `e(observed)' ' {
      local o`k' : word `k' of `e(observed)'
    }
    forvalues k=1/`: word count `e(factors)' ' {
      local f`k' : word `k' of `e(factors)'
    }
  }
  else {
    * mean_1 was found => labeling by numbers
    forvalues k=1/`: word count `e(observed)' ' {
      local o`k' `k'
    }
    forvalues k=1/`: word count `e(factors)' ' {
      local f`k' `k'
    }
  }

  * header
  di _n as text "`e(crittype)' = " as res e(ll) _col(59) as text "Number of obs = " as res e(N)
  di as text "{hline 13}{c TT}{hline 64}"
  if "`e(vcetype)'" ~= "" {
  di as text "             {c |}           {center 15:`e(vcetype)'}"
  }
  di as text "             {c |}      Coef.   Std. Err.      z    P>|z|     [$S_level% Conf. Interval]"
  di as text "{hline 13}{c +}{hline 64}"

  tokenize `e(observed)'
  local nobsvar : word count `e(observed)'

  * let's go equation by equation
  local eqno = 0

  * Means
  _diparm __lab__, label("Means") eqlabel
  forvalues j = 1/`nobsvar' {
    local ++eqno
    _diparm mean_`o`j'' , label("``j''") prob `level'
  }

  * Loadings
  _diparm __lab__, label("Loadings") eqlabel
  local ++eqno // to point to the next line
  forvalues k=1/`: word count `e(factors)' ' {
     _diparm __lab__ , label("`: word `k' of `e(factors)' '")
     while CONFA_Struc[`eqno',1]<=2 & CONFA_Struc[`eqno',4]==`k' {
       local j = CONFA_Struc[`eqno',3]
       _diparm lambda_`o`j''_`f`k'', label("``j''") prob `level'
       local ++eqno
     }
  }

  * Factor covariance
  _diparm __lab__, label("Factor cov.") eqlabel
  forvalues k=1/`: word count `e(factors)'' {
    foreach kk of numlist `k'/1 {
      _diparm phi_`f`kk''_`f`k'', label("`: word `kk' of `e(factors)''-`: word `k' of `e(factors)''") prob `level'
      local ++eqno
    }
  }

  * Error variances
  _diparm __lab__, label("Var[error]") eqlabel
  forvalues j= 1/`nobsvar' {
     _diparm theta_`o`j'' , label("``j''") prob `level'
     local ++eqno
  }

  * Error correlations
  if `eqno' <= rowsof(CONFA_Struc) & CONFA_Struc[`eqno',1] == 5 {
    _diparm __lab__, label("Cov[error]") eqlabel
    while (`eqno' <= rowsof(CONFA_Struc) & CONFA_Struc[`eqno',1] == 5) {
      local k1 = CONFA_Struc[`eqno',3]
      local k2 = CONFA_Struc[`eqno',4]
      _diparm theta_`o`k1''_`o`k2'', label("``k1''-``k2''") prob `level'
      * range check: what am I supposed to check here? Hm...
      local ++eqno
    }
  }

  if "`e(vcetype)'"~="Robust" & "`e(missing)'"=="" {
     di as text "{hline 13}{c +}{hline 64}"
     di as text "R2{col 14}{c |}"
     forvalues j = 1/`nobsvar' {
       qui sum ``j'' if e(sample)
       local r2 = (`Sigma'[`j',`j']-_b[theta_`o`j'':_cons])/r(Var)
       di as text %12s "``j''" "{col 14}{c |}{col 20}" as res %6.4f `r2'
     }
  }


  di as text "{hline 13}{c BT}{hline 64}"

  if e(df_u)>0 {
     di as text _n "Goodness of fit test: LR = " as res %6.3f e(lr_u) ///
        as text _col(40) "; Prob[chi2(" as res %2.0f e(df_u) as text ") > LR] = " as res %6.4f e(p_u)
  }
  else {
     di as text "No degrees of freedom to perform the goodness of fit test"
  }
  di as text "Test vs independence: LR = " as res %6.3f e(lr_indep) ///
     as text _col(40) "; Prob[chi2(" as res %2.0f e(df_indep) as text ") > LR] = " as res %6.4f e(p_indep)

  if "`e(vce)'" == "SatorraBentler" & e(df_u)>0 {
     * need to report all those corrected statistics

     di as text _n "Satorra-Bentler Tsc" _col(26) "= " as res %6.3f e(Tsc) ///
        as text _col(40) "; Prob[chi2(" as res %2.0f e(df_u) as text ")   > Tsc ] = " as res %6.4f e(p_Tsc)

     di as text "Satorra-Bentler Tadj" _col(26) "= " as res %6.3f e(Tadj) ///
        as text _col(40) "; Prob[chi2(" as res %4.1f e(SBd) as text ") > Tadj] = " as res %6.4f e(p_Tadj)

     di as text "Yuan-Bentler T2" _col(26) "= " as res %6.3f e(T2) ///
        as text _col(40) "; Prob[chi2(" as res %2.0f e(df_u) as text ")   > T2  ] = " as res %6.4f e(p_T2)
  }

  if "`e(vce)'" == "BollenStine" {
     * need to report Bollen-Stine measures
     di as text _n "Bollen-Stine simulated Prob[ LR > " as res %6.4f e(lr_u) as text " ] = " as res %6.4f e(p_u_BS) ///
        as text _n "Based on " as res e(B_BS) as text " replications. " ///
        as text "The bootstrap 90% interval: (" as res %6.3f e(T_BS_05) as text "," ///
        as res %6.3f e(T_BS_95) as text ")"


  }

  mat drop CONFA_Struc

end

**************************** Satorra-Bentler covariance matrix code

program SatorraBentler, rclass
   syntax [, noisily constraint(numlist) missing]

   if "`missing'"!="" {
      di "{err}cannot specify Satorra-Bentler standard errors with missing data"
      exit 198
   }

   * assume the maximization completed, the results are in memory as -ereturn data-
   * we shall just return the resulting matrix

   * assume sample is restricted to e(sample)
   * preserve
   * keep if e(sample)

   * get the variable names
   tempname VV bb
   mat `bb' = e(b)
   mat `VV' = e(V)
   local p : word count $CONFA_obsvar
   qui count if $CONFA_touse
   local NN = r(N)

   * compute the implied covariance matrix
   tempname Lambda Theta Phi Sigma
   mata : st_matrix("`Sigma'",CONFA_StrucToSigma(st_matrix("`bb'")))

   * compute the empirical cov matrix
   tempname SampleCov
   qui mat accum `SampleCov' = $CONFA_obsvar $CONFA_wgti if $CONFA_touse , nocons dev
   * divide by sum of weights instead???
   mat `SampleCov' = `SampleCov' / (`NN'-1)

   * compute the matrix Gamma (fourth moments)
   if $CONFA_loglevel > 4 {
       di as text "Computing the Gamma matrix of fourth moments..."
   }
   tempname Gamma
   SBGamma $CONFA_obsvar if $CONFA_touse
   mat `Gamma' = r(Gamma)
   return add

   * compute the V matrix, the normal theory weight
   if $CONFA_loglevel > 4 {
      di as text "Computing the V matrix..."
   }
   SBV `SampleCov' `noisily'
   if !mi(r(needmatsize)) {
     di as err "matsize too small; need at least " r(needmatsize)
     exit 908
   }
   tempname V
   mat `V' = r(SBV)
   return add

   * compute the Delta matrix
   if $CONFA_loglevel > 4 {
      di as text "Computing the Delta matrix..."
   }

   tempname Delta DeltaId
   noi mata : SBStrucToDelta("`Delta'")

   *** put the pieces together now

   * enact the constraints!
   SBconstr `bb', constraint(`constraint')

   * zero out the rows of Delta that correspond to fixed parameters
   mat `DeltaId' = `Delta' * diag( r(Fixed) )

   local dcnames : colfullnames `bb'
   local drnames : rownames `Gamma'
   mat colnames `DeltaId' = `dcnames'
   mat rownames `DeltaId' = `drnames'
   return matrix Delta = `DeltaId', copy

   tempname VVV
   mat `VVV' = ( `DeltaId'' * `V' * `DeltaId' )
   mat `VVV' = syminv(`VVV')
   mat `VVV' = `VVV' * ( `DeltaId'' * `V' * `Gamma' * `V' * `DeltaId' ) * `VVV'/`NN'

   * add the covariance matrix for the means, which is just Sigma/_N
   * weights!
   * third moments!
   return matrix SBVar = `VVV'

end
* of satorrabentler

* Compute Gamma: the fourth moments matrix -- check!
program define SBGamma, rclass
   syntax varlist [if] [in]
   unab varlist : `varlist'
   tokenize `varlist'

   marksample touse

   local p: word count `varlist'

   forvalues k=1/`p' {
     * make up the deviations; weights are used in a weird way
     *** MISSING: change r(mean) to _b[whatever] ?
     qui sum ``k'' $CONFA_wgti if `touse', meanonly
     tempvar d`k'
     qui g double `d`k'' = ``k'' - r(mean) if `touse'
     local dlist `dlist' `d`k''
   }

   local pstar = `p'*(`p'+1)/2
   forvalues k=1/`pstar' {
      tempvar b`k'
      qui g double `b`k'' = .
      local blist `blist' `b`k''
   }


   * convert into vech (z_i-bar z)(z_i-bar z)'
   mata : SBvechZZtoB("`dlist'","`blist'")

   * blist now should contain the moments around the sample means
   * we need to get their covariance matrix

   tempname Gamma
   qui mat accum `Gamma' = `blist' $CONFA_wgti if `touse', dev nocons
   mat `Gamma' = `Gamma'/(r(N)-1)
   mata : Gamma = st_matrix( "`Gamma'" )

   * make nice row and column names
   forvalues i=1/`p' {
     forvalues j=`i'/`p' {
        local namelist `namelist' ``i''_X_``j''
     }
   }
   mat colnames `Gamma' = `namelist'
   mat rownames `Gamma' = `namelist'

   return matrix Gamma = `Gamma'

end
* of computing Gamma

* compute V = 1/2 D' (Sigma \otimes Sigma) D
* normal theory weight matrix, see Satorra (1992), eq (24) -- check!
program define SBV, rclass
   args A noisily
   tempname D Ainv V
   local p = rowsof(`A')
   if $CONFA_loglevel > 3 di as text "Computing the duplication matrix..."
   mata : Dupl(`p',"`D'")
   mat `Ainv' = syminv(`A')
   cap mat `V' = .5*`D''* (`Ainv' # `Ainv') * `D'
   if _rc == 908 {
     * need a larger matrix
     return scalar needmatsize = rowsof(`A')*rowsof(`A')
   }
   else {
     return matrix SBV = `V'
   }
end
* of computing V

program define SBconstr, rclass
   * need to figure out whether a constraint has the form [parameter]_cons = value,
   * and to nullify the corresponding column
   syntax anything, [constraint(numlist)]
   local bb `anything'
   * that's the name of the parameter vector, a copy of e(b)
   tempname Iq
   mat `Iq' = J(1,colsof(`bb'),1)
   tokenize $CONFA_constr `constraint'
   while "`1'" ~= "" {
     constraint get `1'
     local constr `r(contents)'
     gettoken param value  : constr, parse("=")
     * is the RHS indeed a number?
     local value = substr("`value'",2,.)
     confirm number `value'
     * parse the square brackets and turn them into colon
     * replace the opening brackets with nothing, and closing brackets, with colon
     * that way, we will get "parameter:_cons", which is the format of e(b) labels
     local param = subinstr("`param'","["," ",1)
     local param = subinstr("`param'","]",":",1)
     local param = trim("`param'")
     local coln = colnumb(`bb',"`param'" )
     mat `Iq'[1,`coln']=0

     mac shift
   }
   return matrix Fixed = `Iq'
end

program define CheckVCE
  syntax [anything] , [ROBust CLuster oim opg SBentler SATorrabentler BOOTstrap JACKknife]
  if "`bootstrap'" ~= "" {
    di "{err}vce(bootstrap) not allowed, but you can run {inp}bootstrap ... : confa ... {err}instead."
    CleanIt
    exit 198
  }
  if "`jackknife'" ~= "" {
    di "{err}vce(jackknife) not allowed, but you can run {inp}jackknife ... : confa ... {err}instead."
    CleanIt
    exit 198
  }
end

exit

if "$SOCST" == "c:\-socialstat" {
  // at home, run the Mata file
  do C:\-Mizzou\CONFA\confa.mata
}
else {
   // for public release, add Mata code
   mata : mata mlib index
}

Globals used:
CONFA_init     -- initialization type
CONFA_loglevel -- detail level
CONFA_toML     -- model statement for -ml model-
CONFA_start    -- default starting values
CONFA_bounds   -- ml search bounds
CONFA_args     -- the list of parameters, to appear in -confa_lf-
CONFA_constr   -- the list of constraints
CONFA_obsvar   -- the list of observed variables
CONFA_wgt      -- weight specification
CONFA_wgti     -- iweight
CONFA_t        -- temporary global for -listutil-

Structure matrix:
CONFA_Struc    -- the model structure: (parameter type, equation number, index1, index2)

History:
v.1.0 -- Jan 09, 2008
      -- basic formulation without -cluster-, -robust-, -weights-, -svy-
v.1.1 -- Mar 21, 2008
      -- Satorra-Bentler?
v.1.2 -- Sep 16, 2008
      -- Ken Higbee comments
v.1.5 -- usenames
      -- Mata moved to lcfa.mlib
      -- survey-compatible
v.1.6 -- listwise deletion for missing data
      -- what kind of idiot should Stas be to not pay attention to this???
      -- informative message about matsize in Satorra-Bentler calculations
v.2.0 -- FIML missing data
      -- prepared for revision in SJ
v.2.0.1 -- fixed -if- in Satorra-Bentler calculations
v.2.0.2 -- fixed reporting of correlations with -unitvar-: confa.ado, confa_estat.ado
v.2.0.3 -- cosmetic: unified =return local name expression=
v.2.1   -- list operations via -local : list- rather than -listutil-
v.2.1.1 -- a small bug fixed in handling the lists of observed variables

v.2.x -- someday?
      -- Bartlett correction: (N - 1 - (2p+4m+5)/6)
      -- F-statistic in place of chi-square, both normal theory and S-B
