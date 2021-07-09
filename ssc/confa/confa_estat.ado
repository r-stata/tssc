*! version 2.0.2   08 Sep 2009; part of confa suite
program confa_estat, rclass
       version 10

       if "`e(cmd)'" != "confa" {
               error 301
       }

       gettoken subcmd rest : 0, parse(" ,")
       local lsubcmd= length("`subcmd'")

       if `"`subcmd'"' == substr("fitindices", 1, max(3, `lsubcmd')) {
               FitIndices `rest'
       }
       else if `"`subcmd'"' == substr("correlate", 1, max(4, `lsubcmd')) {
               Correlate `rest'
       }
       else if `"`subcmd'"' == substr("aic",1, max(3, `lsubcmd')) {
               FitIndices , aic
       }
       else if `"`subcmd'"' == substr("bic",1, max(3, `lsubcmd')) {
               FitIndices , bic
       }
       else if `"`subcmd'"' == substr("ic",1,max(2, `lsubcmd')) {
               FitIndices, aic bic
       }
       else if `"`subcmd'"' == substr("summarize", 1, max(2, `lsubcmd')) {
               Summarize  `rest'
       }
       else if `"`subcmd'"' == "vce" {
               vce `rest'
       }
       else {
          di as err "`subcmd' not allowed"
          exit 198
       }

       return add

end

program Summarize
       syntax , [noHEAder noWEIghts]
       if "`e(wexp)'" ~= "" & "`weights'"~="noweights" local wgt [iw `e(wexp)']
       sum `e(observed)' `wgt' if e(sample)
end

program Correlate, rclass
  * correlation matrix of estimated factors

  syntax, [level(passthru) bound]

  di _n "{txt}Correlation equivalents of covariances"

  if "`bound'" != "" local bound ci(atanh)

  local q = rowsof( e(Phi) )
  if `q'>1 {
    * display the factor correlations

    di as text "{hline 13}{c TT}{hline 64}"
    if "`e(vcetype)'" ~= "" {
    di as text "             {c |}           {center 15:`e(vcetype)'}"
    }
    di as text "             {c |}      Coef.   Std. Err.      z    P>|z|     [$S_level% Conf. Interval]"
    di as text "{hline 13}{c +}{hline 64}"

    * parse the factor names
    local fnames : rownames e(Phi)
    * parse the unitvar list to be used in -inlist-
    local unitvarlist = `"""' + subinstr("`e(unitvar)'"," ",`"",""',.) + `"""'

    _diparm __lab__ , label("Factors") eqlabel

    forvalues i=1/`q' {
       local i1 = `i'+1
       forvalues j=`i1'/`q' {
         if inlist("`: word `i' of `fnames''", `unitvarlist') & inlist("`: word `j' of `fnames''", `unitvarlist') {
            * both factor variances are constrained at 1, display as is
            _diparm phi_`i'_`j' , prob label("`: word `i' of `fnames''-`: word `j' of `fnames''") `level' `bound'
         }
         else if inlist("`: word `i' of `fnames''", `unitvarlist') & !inlist("`: word `j' of `fnames''", `unitvarlist') {
            * `i' is restricted unit variance, `j' is not
         _diparm phi_`i'_`j' phi_`j'_`j', ///
            function( @1/sqrt(@2) ) d( 1/sqrt(@2) -0.5*@1/sqrt(@2*@2*@2) ) ///
            prob label("`: word `i' of `fnames''-`: word `j' of `fnames''") `level' `bound'
         }
         else if !inlist("`: word `i' of `fnames''", `unitvarlist') & inlist("`: word `j' of `fnames''", `unitvarlist') {
            * `j' is restricted unit variance, `i' is not
         _diparm phi_`i'_`j' phi_`i'_`i', ///
            function( @1/sqrt(@2) ) d( 1/sqrt(@2) -0.5*@1/sqrt(@2*@2*@2) ) ///
            prob label("`: word `i' of `fnames''-`: word `j' of `fnames''") `level' `bound'
         }
         else {
            * display correlation transform
         _diparm phi_`i'_`j' phi_`i'_`i' phi_`j'_`j', ///
            function( @1/sqrt(@2*@3) ) d( 1/sqrt(@2*@3) -0.5*@1/sqrt(@2*@2*@2*@3) -0.5*@1/sqrt(@2*@3*@3*@3) ) ///
            prob label("`: word `i' of `fnames''-`: word `j' of `fnames''") `level' `bound'
         }
       }
    }

  }


  if "`e(correlated)'" ~= "" {

    if `q' < 2 {
       * need to display the header

       di as text "{hline 13}{c TT}{hline 64}"
       if "`e(vcetype)'" ~= "" {
       di as text "             {c |}           {center 15:`e(vcetype)'}"
       }
       di as text "             {c |}      Coef.   Std. Err.      z    P>|z|     [$S_level% Conf. Interval]"
       di as text "{hline 13}{c +}{hline 64}"
    }

    * print out correlated measurement errors
    _diparm __lab__ , label("Errors") eqlabel
    local correlated `e(correlated)'
    local obsvar `e(observed)'
    while "`correlated'" != "" {
       gettoken corrpair correlated : correlated , match(m)
       gettoken corr1 corrpair : corrpair, parse(":")
       unab corr1 : `corr1'
       gettoken sc corr2 : corrpair, parse(":")
       unab corr2 : `corr2'

       /* was before v.2.1:
       poslist `obsvar' \ `corr1', global(CONFA_temp)
       local k1 = $CONFA_temp
       poslist `obsvar' \ `corr2', global(CONFA_temp)
       local k2 = $CONFA_temp
       */
       local k1 : list posof `"`corr1'"' in obsvar
       local k2 : list posof `"`corr2'"' in obsvar

       _diparm theta_`k1'_`k2' theta_`k1' theta_`k2', ///
          function( @1/sqrt(@2*@3) ) d( 1/sqrt(@2*@3) -0.5*@1/sqrt(@2*@2*@2*@3) -0.5*@1/sqrt(@2*@3*@3*@3) ) ///
          prob label("`corr1'-`corr2'") `level' `bound'

    }

  }
  else if `q'<2 {
     di as text _n "Nothing to display" _n
  }

  di as text "{hline 13}{c BT}{hline 64}"

  global CONFA_temp

end

program FitIndices, rclass

  syntax , [all tli rmsea rmsr aic bic]

  di _n "{txt}  Fit indices" _n
  return add

  * all, by default
  if "`*'" == "" local all 1

  * the fundamentals
  local p = `: word count `e(obsvar)''

  if "`rmsea'`all'"~="" {
     return scalar RMSEA = sqrt( max( (e(lr_u)-e(df_u))/(e(N)-1), 0 )/e(df_u) )
     tempname ll lu
     scalar `ll' = cond(chi2(e(df_u),e(lr_u))>0.95,npnchi2(e(df_u),e(lr_u),0.95),0)
     scalar `lu' = cond(chi2(e(df_u),e(lr_u))>0.05,npnchi2(e(df_u),e(lr_u),0.05),0)
     return scalar RMSEA05 = sqrt( `ll'/( (e(N)-1)*e(df_u) ) )
     return scalar RMSEA95 = sqrt( `lu'/( (e(N)-1)*e(df_u) ) )
     di "{txt}RMSEA {col 8}= {res}" %6.4f return(RMSEA) _c
     di "{txt}, 90% CI{col 8}= ({res}" %6.4f return(RMSEA05) "{txt}, {res}" %6.4f return(RMSEA95) "{txt})"
  }

  if "`rmsr'`all'"~="" {
     cap mat li e(S)
     if _rc {
        * no matrix posted
        return scalar RMSR = .
     }
     else {
        tempname res
        mata : st_numscalar("`res'",norm(vech(st_matrix("e(Sigma)") - st_matrix("e(S)"))) )
        return scalar RMSR = `res'/sqrt(e(pstar) )
     }
     di "{txt}RMSR {col 8}= {res}" %6.4f return(RMSR)
  }

  if "`tli'`all'"~="" {
     return scalar TLI = (e(lr_indep)/e(df_indep)-e(lr_u)/e(df_u))/(e(lr_indep)/e(df_indep)-1)
     di "{txt}TLI {col 8}= {res}" %6.4f return(TLI)
  }

  if "`cfi'`all'"~="" {
     return scalar CFI = 1 - max( e(lr_u)-e(df_u),0 )/max( e(lr_u)-e(df_u), e(lr_indep)-e(df_indep),0 )
     di "{txt}CFI {col 8}= {res}" %6.4f return(CFI)
  }

  if "`aic'`all'"~="" {
     if "`e(wexp)'" == "" & "`e(vcetype)'"~="Robust" return scalar AIC = -2*e(ll) + 2*e(df_m)
     else return scalar AIC = .
     di "{txt}AIC {col 8}= {res}" %8.3f return(AIC)
  }

  if "`bic'`all'"~="" {
     if "`e(wexp)'" == "" & "`e(vcetype)'"~="Robust"  return scalar BIC = -2*e(ll) + e(df_m)*ln( e(N) )
     else return scalar BIC = .
     di "{txt}BIC {col 8}= {res}" %8.3f return(BIC)
  }

end

exit

Version history:
1.0.0 9 Jan 2008  -- Correlate
                    FitIndices
1.0.1 12 Sep 2008 -- AIC, BIC
1.0.2    Oct 2008 -- bound for Correlate CI
                    correlated measurement errors
                    CI for RMSEA
