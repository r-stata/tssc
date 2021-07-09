*! vececm: vector error correction model (ECM)
*!            You must run johans before running vececm
*! version 3.0.1   31may2002   PJoly
* v.3.0.1 31may2002   PJoly   pred only in sample for wntstmvq
* v.3.0   26apr2002   PJoly   Stata 7.0, vec_p as predict
* v.2.0   12mar2001
/* uses:   matrices   e(NBP),  e(NA)    from -johans-
                      r(NRBP), r(NRA)        -lrjtest-
           macros     e(exog)                -johans-
                      r(cirel)               -lrjtest-  */

program define vececm, eclass
      version 7.0

      syntax [if] [in] [, SM(string) Cirel(string) * ]

      if ("`sm'`cirel'" == "") {                     /* variation on replay */
            if `"`e(cmd)'"' != "vececm" {
                  error 301
            }
            else {
                  syntax [ , COV CORr WN TESTLag(int 40) noTable noHeader   /*
                         */  Level(integer $S_level) ]
            }
      }
      else {
            syntax [if] [in] ,           Cirel(numlist int >0 min=1 max=1)  /*
                                */       SM(string)                         /*
                                */   [   Lags(integer 2)                    /*
                                */       Restricted(numlist int >0)         /*
                                */       WN                                 /*
                                */       TESTLag(int 40)                    /*
                                */       CORr                               /*
                                */       LARGE                              /*
                                */       noTable                            /*
                                */       noHeader                           /*
                                */       Matrices                           /*
                                */       Level(integer $S_level) ]

            IsJohan
            IsSM `sm'
            cap drop Co_Rel*         /* possible vectors from previous ecms */
            if "`restricted'" != "" { Checks `cirel' `restricted' }

            tempname A BP b0 b1
            makeP `sm' `cirel' "`restricted'" `A' `BP' `b0' `b1'
            if "`matrices'" != "" {
                  di _n as txt "Normalized Beta'"
                  mat list `BP', noh nob
                  di _n as txt "Normalized Alpha"
                  mat list `A', noh nob
            }

            local varlist : colnames `BP'
            local exog `e(exog)'

            marksample touse
            _ts tvar panelvar if `touse', sort onepanel
            markout `touse' l`lags'.(`varlist') `exog' `tvar' `panelvar'
            qui count if `touse'
            if !r(N) { n error 2000 }
            local p : word count `varlist'
            if "`sm'" == "2" { local trend "`tvar'" }

            local fmt : format `tvar'
            qui summ `tvar' if `touse', meanonly
            local tmin = trim(string(r(min), "`fmt'"))
            local tmax = trim(string(r(max), "`fmt'"))
            if "`large'" == "" {
                  local dfk dfk
                  local small small
            }


            /* BUILD COINTEGRATING VECTORS */

            qui {
                  tokenize `varlist'
                  forv v = 1/`cirel' {
                        tempvar vec`v'
                        g double `vec`v'' = 0
                        forv i = 1/`p' {
                              replace `vec`v'' =`vec`v''+`BP'[`v',`i']*l.``i''
                        }
                        if "`sm'" == "1*" {
                              replace `vec`v'' = `vec`v'' + `b0'[`v',1]
                        }
                        if "`sm'" == "2*" {
                              replace `vec`v'' = `vec`v'' + `b1'[`v',1]*`tvar'
                        }
                        rename `vec`v'' Co_Rel`v'
                        la var Co_Rel`v' "Cointegrating vector #`v'"
                        local co_rlis `co_rlis' Co_Rel`v'
                  }
            }


            /* ESTIMATE ECM */

            local nlags =`lags'-1
            tempvar one                 /* used later too */
            g byte `one' = 1
            summ `one' if `touse', meanonly
            local T = r(N)

            /* Process information about equations */

            tsunab varlist : D.(`varlist')

            tokenize `varlist'
            tempname DF
            mat `DF' = I(`p')
            forv i = 1/`p' {
                  nameEq "`eqname'" "``i''" "`eqlist'" `i'
                  local eqnm`i' = "`s(eqname)'"
                  local eqlist `eqlist' `eqnm`i''    /* only used by nameEq */

                  local y`i' ``i''
                  local lhslist `lhslist' ``i''
                  forv l = 1/`nlags' { local laglist `laglist' L`l'.``i'' }
                  if `nlags' { tsunab laglist : `laglist' }
            }

            forv i = 1/`p' {
                  local ind`i' `laglist' `co_rlis' `exog' `trend'
                  if ("`sm'"=="0" | "`sm'"=="1*") { local cons`i' = 0 }
                  else { local cons`i' = 1 }

                  local eq : word `i' of `eqlist'
                  forv v = 1/`cirel' {  /* constrain adj weights in each eq */
                        tempname weight
                        sca `weight' = `A'[`i',`v']
                        local ncns = `ncns' + 1
                        cons def `ncns' [`eq']Co_Rel`v' = `weight'
                  }
            }

            local k : word count `ind1'            /* all eq'ns have same k */
            local k = `k' + `cons1'      /* if one has a constant, all will */
            local k_tot = `k'*`p'
            if `k' > `T' { n error 2001 }

            forv i = 1/`p' {
                  tempvar res`i'                       /* List of residuals */
                  local reslist `reslist' `res`i''
                  local matcols `matcols' `ind`i''          /* Column names */
                  if `cons`i'' { local matcols "`matcols' _cons" }
                  forv j = 1/`k' { local coleq `coleq' `eqnm`i'' }
                                 /* List of regressors with constant if any */
                  if `cons`i'' { local indi`i' `ind`i'' `one' }
                  else { local indi`i' `ind`i'' }
            }

            if "`dfk'" != "" {             /* Denominators for residual cov */
                  local df = 1/(`T'-`k')
            }
            else {
                  local df = 1/`T'
            }

/* <<====== */
/*  Disturbance mat ==> (B, VCE) ==> Disturbance mat loop */

tempname EpE EpEi EpEiB V b errll
tempname sZpZ Zpy sZpy ZpZ ZpyS sigma

mat `EpE' = I(`p')        /* prime for first-pass cov est */
local pass = 1
while `pass' <=2 {

      /*  Get the inverse covariance mat of errors.
       *  On first pass, just let the OLS cov mat result */

      if `pass' == 2 {
            qui mat accum `EpE' = `reslist' if `touse', noc
      }

      mat `EpE' = `EpE' * `df'
      mat `EpEi' = syminv(`EpE')
      mat `EpEiB' = `EpEi'

      /*  Get the Covariance mat of the estimator.  We build it
       *  in pieces extracting only portions of the Z_1'Z_2 accumulated
       *  matrices for each equation pair.  Get the (EpEi (X) I) y too.
       *  The latter is built separately looping over the full row and
       *  column combinations to avoid extra storage and bookeeping.
       *  Could make this a bit faster by using the Z_1'Z_1 and Z_n'Z_n
       *  computed with the 2nd and next to last accums.
       */

      local ktot : word count `matcols'
      mat `sZpZ' = J(`ktot', `ktot', 0)
      cap { mat drop `sZpy' }

      local from = `k' + 1
      local at_i 1
      local i 1
      while `i' <= `p' {
            mat `ZpyS' = J(1, `k', 0)
            local at_j 1
            local j 1
            while `j' <= `p' {
                  sca `sigma' = `EpEiB'[`i',`j']

                 /*  Get Cov. mat. */

                 if `j' <= `i' {
                        qui mat accum `ZpZ' = `indi`i'' `indi`j'' /*
                               */ if `touse', noc
                        mat `sZpZ'[`at_i',`at_j'] = /*
                               */ `ZpZ'[1..`k',`from'...]*`sigma'
                        if `i' != `j' {
                              mat `sZpZ'[`at_j',`at_i'] = /*
                               */ `ZpZ'[1..`k',`from'...]'*`sigma'
                        }
                  }

                  /*  Get sum(sigma Z_i y_j) */

                  mat vecaccum `Zpy' = `y`j'' `indi`i'' if `touse', noc
                  mat `ZpyS' = `ZpyS' + `Zpy'*`sigma'
                  local at_j = `at_j' + `k'
                  local j = `j' + 1
            }

            /*  Build (EpEiB (X) I) y    */

            mat `sZpy' = nullmat(`sZpy') \ `ZpyS''
            local at_i = `at_i' + `k'
            local i = `i' + 1
      }

      /*  Get var-cov mat and vector of coefficents. Post results. */

      mat `V' = syminv(`sZpZ')
      mat `b' = `sZpy'' * `V''
      mat rownames `V' = `matcols'
      mat roweq `V' = `coleq'
      mat colnames `V' = `matcols'
      mat coleq `V' = `coleq'
      mat colnames `b' = `matcols'
      mat coleq `b' = `coleq'

      if "`small'" == "small" {
            local tdof = `T'*`p' - `k_tot'
            est post `b' `V', dof(`tdof') esample(`touse')
      }
      else {
            local tdof = `T'
            est post `b' `V', obs(`T') esample(`touse')
      }
      gen byte `touse' = e(sample)

      /*  Apply constraints */

      Constrn "1-`ncns'" "`small'" `tdof'
      est repost, esample(`touse')                       /* was not in reg3 */
      gen byte `touse' = e(sample)                       /* was not in reg3 */

      if `pass'==1 {
            local i 1               /*  New resid vectors for error cov mat */
            while `i' <=`p' {
                  qui _predict double `res`i'' if `touse', eq(`eqnm`i'')
                  qui replace `res`i'' = `y`i'' - `res`i''
                  local i = `i' + 1
            }
      }
      local pass = `pass'+1

} /* end while */

/* ======>> */
            /*  Equation summary statistics and retained globals */

            est local eqnames
            tempvar errs
            local i 1
            while `i' <= `p' {
                  est sca cons_`i' = `cons`i''
                  if `k' > 1 | !`cons`i'' { qui test [`eqnm`i''] }
                  else { qui test [`eqnm`i'']_cons }
                  if "`small'" == "small" {
                        est sca F_`i' = r(F)
                        est sca p_`i' = r(p)
                  }
                  else {
                        est sca chi2_`i' = r(chi2)
                        est sca p_`i' = r(p)
                  }
                  qui gen double `errs' = `res`i''^2
                  summ `errs' if `touse', meanonly
                  drop `errs'
                  local mse = r(mean)
                  est sca rss_`i' = r(sum)
                  est sca rmse_`i' = sqrt(r(mean))
                  if "`small'" == "small" {
                        est sca rmse_`i' = sqrt(r(mean)*r(N) /(`T'-`k'))
                  }
                  if `cons`i'' {
                        qui summ `y`i'' if `touse'
                        est sca mss_`i' = (r(sum)-1)*r(Var) - e(rss_`i')
                        est sca r2_`i' = 1 - `mse'/(r(Var)*(`T'-1)/`T')
                  }
                  else {
                        tempvar ysqr
                        qui gen double `ysqr' = `y`i''^2 if `touse'
                        summ `ysqr', meanonly
                        est sca mss_`i' = r(sum) - e(rss_`i')
                        est sca r2_`i' = 1 - `mse' / r(mean)
                        drop `ysqr'
                  }
                  est sca df_m`i' = `k' - `cons`i''
                  est local eqnames `e(eqnames)' `eqnm`i''
                  local i = `i' + 1
            }
            est sca k = `ktot'
            est sca N = `T'
            if "`small'" != "" { est sca df_r = `tdof' }
            est sca k_eq = `p'
            est sca lags = `lags'

            mat rowname `EpE' = `e(eqnames)'
            mat colnames `EpE' = `e(eqnames)'
            est mat Sigma `EpE'
            qui mat accum `EpE'=`reslist' if `touse', noc
            setLL `EpE'
            est local depvar `lhslist'
            est local tmax `tmax'
            est local tmin `tmin'
            est local cnslist 1-`ncns'
            est local dfk `dfk'
            est local small `small'

            est mat A `A'
            est mat BP `BP'
            if substr("`sm'",1,1) == "1" { est mat b0 `b0' }
            if substr("`sm'",1,1) == "2" { est mat b1 `b1' }
            est sca cirel = `cirel'
            est local exog `exog'
            est local rest `restricted'
            est local sm `sm'
            est local predict vec_p
            est local cmd vececm

      } /* end else */

      /* Display results */

      if "`header'" != "" { local noh "*" }
      if "`table'"  != "" { local not "*" }

      if "`e(small)'" == "small" {
            local testtyp "F-Stat"
            local testpfx F
      }
      else {
            local testtyp "  Chi2"
            local testpfx chi2
      }

      di _n as txt "Vector error correction model (ECM)"
      di _n as txt "Sample: " as res "`e(tmin)'" as txt " to "              /*
                  */          as res "`e(tmax)'"

      /* if "`e(cnslist)'" != "" {
            `noh' di as txt _newline "Constraints:"  _c
            `noh' mat dispCns
      }                     I disabled the display of constraints 12mar2001 */
      `noh' di as txt "{hline 70}"
      `noh' di as txt "Equation          Obs  Parms        RMSE    " /*
            */ _quote "R-sq" _quote "     `testtyp'        P"
      `noh' di as txt "{hline 70}"
      tokenize `e(eqnames)'
      local i 1
      while "``i''" != "" {
            `noh' di as res abbrev("``i''",12)                              /*
                    */ _col(15) %7.0g e(N) %7.0g e(df_m`i')                 /*
                    */ "   " %9.0g e(rmse_`i') %10.4f e(r2_`i') "  "        /*
                    */ %9.2g e(`testpfx'_`i') %9.4f e(p_`i')
            local i = `i' + 1
      }
      `noh' if "`not'" != "" { di as txt "{hline 70}" }

      `not' est di, level(`level')

      if "`wn'" != "" {
            local i 0
            while `i' < e(k_eq) {
                  local i = `i'+1
                  tempvar r`i'
                  qui predict double `r`i'' if e(sample), yr eq(#`i')
                  local rlist `rlist' `r`i''
            }
            local lgs = int(min((e(N))/2 - 2,`testlag'))

            wntstmvq `rlist' if e(sample), l(`lgs') var(`e(lags)')
            est sca df_wn = r(df)
            est sca chi2_wn = r(stat)
            est sca p_wn = r(p)

            omninorm `rlist' if e(sample)
            est sca df_om = r(df)
            est sca chi2_om = r(stat)
            est sca chi2_oma = r(statasy)
      }

      if ("`corr'" != "" | "`cov'" != "") {
            tempname mymat
            mat `mymat' = corr(e(Sigma))
            if ("`cov'" != "") {
                  di _n as txt "Covariance matrix of residuals:"
                  mat list e(Sigma), nohead /* format(%9.4f) */
            }
            else {
                  di _n as txt "Correlation matrix of residuals:"
                  mat list `mymat', nohead /* format(%9.4f) */
            }
            tempname CCp
            mat `CCp' = `mymat' * `mymat''
            local tsig = (trace(`CCp') - e(k_eq))*e(N) / 2
            local df = `e(k_eq)' * (`e(k_eq)' - 1) / 2
            di _n as txt "Breusch-Pagan test of independence: chi2(`df') = "/*
                   */ as res  %9.3f `tsig' as txt ", Pr = " %6.4f           /*
                   */ as res  chiprob(`df',`tsig')
            est sca chi2_bp = `tsig'
            est sca df_bp   = `df'
            est sca p_bp = chiprob(`df',`tsig')
      }
end


/* Matrices of cointegrating vectors and corresponding weights */

program define makeP
      args sm cirel restric A BP b0 b1

      if ("`e(rest)'" !="" & "`restric'" =="") {
            di as err "run johans again or impose same restrictions as " _c
            di as err "last estimates"
            exit 198
      }
      cap mat list e(BP)
      if !_rc {
            mat `BP' = e(BP)
            mat `A' = e(A)
            cap mat `b0' = e(b0)                /* only relevant for sm(1*) */
            cap mat `b1' = e(b1)                /* only relevant for sm(2*) */

            local nrows = rowsof(`BP')
            if `nrows' < `cirel' {
                  di as err "too many cointegrating vectors, run johans " _c
                  di as err "again or change cirel()"
                  exit 198
            }
            exit
      }

      local j 0             /* numbered list of vectors */
      while `j'<`cirel' {
            local j = `j'+1
            local vecl `vecl' vec`j'
      }

      tempname I IR IU
      tokenize `restric'
      mat `I' = I(`cirel')
      mat `IR' = J(`cirel',`cirel',0)
      local i 1
      while "``i''" != ""  {
            mat `IR'[``i'',``i''] = 1
            mac shift
      }

      mat `IU' = `I' - `IR'

      cap mat list r(NRBP)
      if _rc {
            tempname NA NBP
            mat `NBP' = e(NBP)
            mat `NA' = e(NA)
            mat `BP' = `IU'*`NBP'[1..`cirel',.]
            mat `A' = (`IU'*`NA'[.,1..`cirel']')'
      }
      else {
            tempname NA NBP NRA NRBP
            mat `NBP' = e(NBP)
            mat `NA' = e(NA)
            mat `NRA' = r(NRA)
            mat `NRBP' = r(NRBP)
            mat `BP' = `IU'*`NBP'[1..`cirel',.] + `IR'*`NRBP'[1..`cirel',.]
            mat `A' = (`IU'*`NA'[.,1..`cirel']'+`IR'*`NRA'[.,1..`cirel']')'
      }

      mat rownames `BP' = `vecl'
      mat colnames `BP' = `e(varlist)'
      mat rownames `A' = `e(varlist)'
      mat colnames `A' = `vecl'

      if substr("`sm'",1,1) == "1" { mat `b0' = syminv(`A''*`A')*`A''*e(mu0) }
      if substr("`sm'",1,1) == "2" { mat `b1' = syminv(`A''*`A')*`A''*e(mu1) }
end


/* Checking for fatal conditions */

program define Checks
      gettoken cirel restric : 0, parse(" ")
      local r : word count `restric'
      if "`r(cirel)'" == "" { local lr 0 }
      else { local lr "`r(cirel)'" }

      if `r'>`cirel' {
            di as err "more restrictions than relationships"
            exit 198
      }

      if "`e(rest)'" == "" {
            cap mat list r(NRBP)
            if _rc {
                  di as err "use restrict option in lrcotest to impose " _c
                  di as err "restriction(s)"
                  exit 198
            }
            if `r' > `lr' {
                  di as err "more restrictions than relationships " _c
                  di as err "in likelihood ratio test"
                  exit 198
            }
      }
      else {
            if ("`restric'" != "`e(rest)'") {
                  di as err "restricted vectors different than last estimates"
                  di as err "run johans again or modify restricted"
            }
      }

      tokenize `restric'
      local i 0
      while `i'<`r' {
            local i = `i'+1
            if ``i''>`cirel' {
                  di as err "selected options inconsistent"
                  exit 198
            }
      }
end


/* Conditions relatied to choice of statistical model (sm) */

program define IsSM
      args sm

      if ( "`sm'" != "0" & "`sm'" != "1*" & "`sm'" != "1" &                 /*
                       */  "`sm'" != "2*" & "`sm'" != "2"   ) {
            di as err "sm() must be 0,1*,1,2*, or 2"
            exit 198
      }
      if (substr("`sm'",1,1) == substr("`e(sm)'",1,1)) { exit }

      cap mat list e(mu0)
      local rc0 = _rc
      cap mat list e(mu1)
      local rc1 = _rc
      local rc `rc0':`rc1'

      if "`sm'" == "0" {
            if ("`rc'" != "111:111") {
                  di as err "sm(`sm') requires running johans without " _c
                  di as err "constant nor trend"
                  exit 198
            }
      }
      if substr("`sm'",1,1) == "1" {
            if ("`rc'" != "0:111") {
                  di as err "sm(`sm') requires running johans with a " _c
                  di as err "constant and without a trend"
                  exit 198
             }
      }
      if substr("`sm'",1,1) == "2" {
            if ("`rc'" != "0:0") {
                  di as err "sm(`sm') requires running johans with " _c
                  di as err "constant and trend"
                  exit 198
            }
      }
end


program define IsJohan
      if ("`e(cmd)'" == "johans") {
            cap mat list e(NBP)
            local list = _rc
            cap mat list e(NA)
            local list = `list' + _rc
            if `list' {
                  di as err "run johans with option normal prior to vececm"
                  exit 301
            }
      }
      else {
            cap mat list e(BP)
            local list = _rc
            cap mat list e(A)
            local list = `list' + _rc
            if `list' {
                  di as err "run johans prior to vececm"
                  exit 301
            }
      }
end


/*  Apply constraints to the system */

program define Constrn    /* <constraints> <smallsmplstat> <dof> */
     args      constr     /*  list of constraint numbers
          */   small      /*  non-blank ==> t-stat, not z-stat
          */   dof        /*  degrees of freedom */
     tempname A beta C IAR j R Vbeta

     mat makeCns `constr'
     mat `C' = get(Cns)
     local cdim = colsof(`C')
     local cdim1 = `cdim' - 1

     mat `R' = `C'[1...,1..`cdim1']
     mat `A' = syminv(`R'*get(VCE)*`R'')
     local a_size = rowsof(`A')

     sca `j' = 1
     while `j' <= `a_size' {
          if `A'[`j',`j'] == 0 { error 412 }
          sca `j' = `j' + 1
     }
     mat `A' = get(VCE)*`R''*`A'
     mat `IAR' = I(colsof(get(VCE))) - `A'*`R'
     mat `beta' = get(_b) * `IAR'' + `C'[1...,`cdim']'*`A''
     mat `Vbeta' = `IAR' * get(VCE) * `IAR''

     if "`small'" == "small" {
          est post `beta' `Vbeta' `C',  dof(`dof')
     }
     else {
          est post `beta' `Vbeta' `C', obs(`dof')
     }
end


program define setLL, eclass
     args     EpE        /* accum of residuals (is modified) */

     tempname SIGi
     mat `SIGi' = (1/(e(N))) * `EpE'

     est sca ll = -0.5 * (e(N)*e(k_eq)*ln(2*_pi) + /*
               */  e(N)*ln(det(`SIGi')) + e(N)*e(k_eq))
end


/*  determine equation name   -- f/ reg3.ado */

program define nameEq, sclass
      args      eqname  /* user specified equation name
            */  depvar  /* dependent variable name
            */  eqlist  /* list of current equation names
            */  neq           /* equation number */

      if "`eqname'" != "" {
            if index("`eqname'", ".") {
di as err "may not use periods (.) in equation names: `eqname'"
            }
            local eqlist : subinstr local eqlist "`eqname'" "`eqname'", /*
                    */ word count(local count)    /* overkill, but fast */
            if `count' > 0 {
di as err "may not specify duplicate equation names: `eqname'"
                  exit 198
            }
            sreturn local eqname `eqname'
            exit
      }

      local depvar : subinstr local depvar "." "_", all

      if length("`depvar'") > 32 { local depvar "eq`neq'" }
      Matches dupnam : "`eqlist'" "`depvar'"
      if "`dupnam'" != "" {
            sreturn local eqname = substr("`neq'`depvar'", 1, 32)
      }
      else { sreturn local eqname `depvar'}
end


/*  Returns tokens found in both lists in the macro named by matches.
 *  Duplicates must be duplicated in both lists to be considered
 *  matches a 2nd, 3rd, ... time.  -- f/ reg3.ado */

program define Matches
      args      matches     /*  macro name to hold cleaned list
            */  colon   /*  ":"
            */  list1   /*  a list of tokens
            */  list2   /*  a second list of tokens */

      tokenize `list1'
      local i 1
      while "``i''" != "" {
            local list2 : subinstr local list2 "``i''" "", /*
                  */ word count(local count)
            if `count' > 0 { local matlist `matlist' ``i'' }
            local i = `i' + 1
      }

      c_local `matches' `matlist'
end


exit


Notes
-----
-vececm- is designed to enable users to invoke the command numerous times,
subject to certain exceptions, without having to perform -johans- each time.
That way, there's no need for the global macro -noP-. The exceptions are:

1) if `cirel' of a subsequent estimation is > a previous one.
(This error will be caught by the main routine i.e matrices `A' and `BP' will
not be of the right dimensions.)

2) if a subsequent estimation does not contain restrited vectors and the
previous estimation did or restrictions were different.
(That first possibility will be caught by -makeP-'s <if ("`e(rest)'" !="" &
"`restric'" =="")> and the latter possibility will be caught by -Checks-'s <if
("`restric'" != "`e(rest)'" & "`e(rest)'" !="")>.)

Note that -IsJohan- must appear before -makeP-.

- Note 1) above actually is not true. Eg. if mat A is (3x1) it is not illegal
to refer to A[1,2] which is simply regarded as missing, therefore no error is
generated contrary to what I thought. Could do a test by checking to make sure
that `cirel'<= number of rows of `BP'.
