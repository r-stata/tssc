*! varlag: statistics to determine the appropriate lag length in VARs, ECMs
*! version 3.0.1   31may2002   PJoly
* v.3.0.1 31may2002   PJoly   pred only in sample for wntstmvq
* v.3.0   24may2002   PJoly   updated to Stata 7 and enabled -vecar-
* v.2.1   24may2002   PJoly   corrected dof for omnibus test
* v.2.0   24jun2001   PJoly

program define varlag, sortpreserve
      version 7.0

      syntax [varlist(default=none ts)] [if] [in],  Lags(int) [             /*
                                         */         TESTLag(int 40)         /*
                                         */         noMulti                 /*
                                         */         EXog(varlist ts)        /*
                                         */         Trend                   /*
                                         */         noConstant              /*
                                         */         Single                  /*
                                         */         noDetail                /*
                                         */         COV                     /*
                                         */         CORr                    /*
                                         */         large                   /*
                                         */         Level(integer $S_level) /*                                         */         noi  * vecar ]

      /* if `varlist' is empty ==> tests are for an ECM and statistics for
         individual eq'ns are not displayed. Otherwise ==> tests for a VAR  */

      if ("`varlist'" == "" & "`single'" != "") {
            di in r "individual equation statistics only available in " _c
            di in r "context of VARs, not ECMs"
            exit 198
      }

      if "`varlist'" == "" {
            local method vececm
            local header ECM
            local exog
            tempname betap
            cap mat `betap' = e(NBP)
            if _rc { cap mat `betap' = e(BP) }
            if _rc {
                  di as err "run johans prior to varlag or specify a varlist"
                  exit 198
            }
            local list : colnames `betap'
            local neq : word count `list'

            marksample touse, novarlist
            _ts tvar pvar if `touse', sort onepanel
            markout `touse' `list' l`lags'.(`list') `e(exog)' `tvar' `pvar'
            qui count if `touse'
            if !r(N) { n error 2000 }
            qui tsset
      }
      else {
            est clear
            cap which vecvar
            if _rc { local method vecar }
            else { local method vecvar }
            local header VAR
            local neq : word count `varlist'

            marksample touse
            _ts tvar pvar if `touse', sort onepanel
            markout `touse' l`lags'.(`varlist') `exog' `tvar' `pvar'
            qui count if `touse'
            if !r(N) { n error 2000 }
            qui tsset
      }

      local fmt : format `tvar'
      qui summ `tvar' if `touse', meanonly
      local tmin = trim(string(r(min), "`fmt'"))
      local tmax = trim(string(r(max), "`fmt'"))
      local n = r(N)
      if "`trend'" != "" { local trend `tvar' }

      local lgt = length("(obs = `n')")
      local col = 70 - `lgt' + 1
      di _n "{txt}Lag length selection statistics - `header'" _n
      di "System variables:    " "{res}`varlist'`list'"
      di "{txt}Exogenous variables: {res}`exog'`e(exog)'"
      di "{txt}Sample: {res:`tmin'} to {res:`tmax'}" _c
      di "{txt}{col `col'}(obs = {res:`n'})"

      if "`single'" != "" {
            tokenize `varlist'
            if "`noi'" == "" { local qui qui }
            local lagbg = int(min(.25*r(N),`testlag'))
            local LMZ LM`lagbg'

            while "`1'" != "" {
                  local x = length("Equation for `1'")
                  di _n "{txt}Equation for `1'"
                  di "{hline `x'}"
      /* <<====== */

      if "`detail'" == "" {
            local header : di "Lags" _col(6) "vars"     _col(12) "RMSE"     /*
              */  _col(23) "FPE"     _col(34) "SC"      _col(41) "P(BP)"    /*
              */  _col(48) "P(LM1)"  _col(56) "P(LM4)"  _col(64) "P(`LMZ')"
            local dup = length("`header'")
            di "{txt}`header'" _n "{hline `dup'}"

            local best `""{txt}{hline `dup'}" _n "Best" _col(12)"'
      }
      else {
            local header : di "RMSE"   _col(12) "FPE"     _col(23) "SC"     /*
              */  _col(30) "P(BP)"     _col(37) "P(LM1)"  _col(45) "P(LM4)" /*
              */  _col(55) "P(`LMZ')"
            local dup = length("`header'")
            di "{txt}`header'" _n "{hline `dup'}"
      }
      /* ======>> */

                  local bLrmse .
                  local bLFPE .
                  local bLSC .
                  local bLPBP .
                  local bLPLM .
                  local bLPLM4 .
                  local bLPLMZ .

                  local brmse .
                  local bFPE .
                  local bSC .
                  local bPBP .
                  local bPLM .
                  local bPLM4 .
                  local bPLMZ .

                  forv i = 1/`lags' {
                        `qui' reg `1' l(1/`i').(`varlist') `exog' `trend'   /*
                                                   */  if `touse', `constant'

                        /*  Calculate the model selection statistics  */

                        tempname rmse FPE SC PBP PLM PLM4 PLMZ
                        local k = e(N)-e(df_r)
                        sca `rmse' = e(rmse)
                        sca `FPE' = e(rss)/e(N)*(e(N)+`k')/(e(N)-`k')
                        sca `SC' = ln(e(rss)/e(N)) + ln(e(N))*`k'/e(N)
                        qui bpagan l(1/`i').(`varlist') `exog' `trend'      /*
                                                          */  if e(sample)
                        sca `PBP' = r(p)
                        qui bgtest if e(sample), lags(1)
                        sca `PLM' = r(p)
                        qui bgtest if e(sample), lags(4)
                        sca `PLM4' = r(p)
                        qui bgtest if e(sample), lags(`lagbg')
                        sca `PLMZ' = r(p)

                        /* taken from ts_flag ... */

                        local bLrmse = cond(`rmse'<`brmse',`i',`bLrmse')
                        local brmse = min(`brmse',`rmse')
                        local bLFPE = cond(`FPE'<`bFPE',`i',`bLFPE')
                        local bFPE = min(`bFPE',`FPE')
                        local bLSC = cond(`SC'<`bSC',`i',`bLSC')
                        local bSC = min(`bSC',`SC')
                        if "`bLPBP'" == "." {
                              local bLPBP = cond(`PBP'>(1-(`level'/100)),`i',.)
                        }
                        if "`bLPLM'" == "." {
                              local bLPLM = cond(`PLM'>(1-(`level'/100)),`i',.)
                        }
                        if "`bLPLM4'" == "." {
                              local bLPLM4 =                                /*
                                    */  cond(`PLM4'>(1-(`level'/100)),`i',.)
                        }
                        if "`bLPLMZ'" == "." {
                              local bLPLMZ =                                /*
                                    */  cond(`PLMZ'>(1-(`level'/100)),`i',.)
                        }

            /* <<====== */

            if "`detail'" == "" {
                  di as res        %2.0f `i'         _s(2) %2.0f `k'-1      /*
                    */       _s(2) %9.0g `rmse'      _s(2) %9.0g `FPE'      /*
                    */       _s(2) %7.0g `SC'        _s(3) %5.3f `PBP'      /*
                    */       _s(3) %5.3f `PLM'       _s(3) %5.3f `PLM4'     /*
                    */       _s(3) %5.3f `PLMZ'
            }
            if (`i'==`lags') {
                  di as txt `best' _c
                  di as res  _s(2) %-4.0f `bLrmse'   _s(7) %-4.0f `bLFPE'   /*
                    */       _s(6) %-3.0f `bLSC'     _s(5) %-3.0f `bLPBP'   /*
                    */       _s(5) %-3.0f `bLPLM'    _s(5) %-3.0f `bLPLM4'  /*
                    */       _s(5) %-3.0f `bLPLMZ'
            }
            /* ======>> */
                  }
                  mac shift
            }
      } /* end if */

      if "`multi'" == "" {
            if ("`exog'" != "" | "`trend'" != "") {
                  local exog "exog(`exog' `trend')"
            }
            di _n "{txt}BP independence test, Multivariate Ljung-Box and " _c
            di "Omnibus normality statistics"
            di "{hline 32}{c TT}{hline 26}{c TT}{hline 19}"
            di "{col 10}Breusch-Pagan{col 33}{c |}{col 40}Portmanteau" _c
            di "{col 60}{c |} Normal  asymptotic"
            local dofBP = (`neq'^2-`neq')/2
            local df_om = 2*`neq'

            di "{txt}Lags obs nvars chi2({res:`dofBP'}){col 25}P>chi2"    _c
            di "{col 33}{c |}   df   chi2({res:df}){col 52}P>chi2  {c |}" _c
            di "P>chi2({res:`df_om'}) P>chi2({res:`df_om'})"
            di "{hline 32}{c +}{hline 26}{c +}{hline 19}"

            local bLP_bp .
            local bLP_wn .
            local bLP_om .
            local bLP_oma .

            forv i = 1/`lags' {
                  if ("`method'"=="vecar" | "`vecar'"!="") {
                        if "`large'"=="" { local dfk dfk }

                        qui vecar `varlist' if `touse', max(`i') `exog'     /*
                             */ `constant' `dfk'

                        local rlist
                        forv eq = 1/`e(k_eq)' {
                              tempvar r`eq'
                              qui predict double `r`eq'' if e(sample),      /*
                                                */           resid eq(#`eq')
                              local rlist `rlist' `r`eq''
                        }
                        local lgs = int(min((e(N))/2 - 2,`testlag'))

                        qui wntstmvq `rlist' if e(sample), l(`lgs') var(`i')
                        local df_wn = r(df)
                        local chi2_wn = r(stat)
                        local p_wn = r(p)

                        qui omninorm `rlist' if e(sample)
                        local chi2_om  = r(stat)
                        local chi2_oma = r(statasy)
                        local p_om     = chiprob(`df_om',`chi2_om')
                        local p_oma    = chiprob(`df_om',`chi2_oma')

                        local df       = e(maxlag)*e(k_eq)

                        tempname mymat CCp
                        mat `mymat' = corr(e(Sigma))
                        mat `CCp' = `mymat' * `mymat''
                        local tsig    = (trace(`CCp') - e(k_eq))*e(N) / 2
                        local df_bp   = `e(k_eq)' * (`e(k_eq)' - 1) / 2
                        local chi2_bp = `tsig'
                        local p_bp    = chiprob(`df_bp',`tsig')
                  }
                  else {
                        qui `method' `varlist' if `touse', lags(`i') `exog' /*
                           */ `options' `constant' corr wn                  /*
                           */ `large' testlag(`testlag')

                        local df       = e(df_m1)
                        local chi2_bp  = e(chi2_bp)
                        local p_bp     = e(p_bp)
                        local df_wn    = e(df_wn)
                        local chi2_wn  = e(chi2_wn)
                        local p_wn     = e(p_wn)
                        local chi2_om  = e(chi2_om)
                        local chi2_oma = e(chi2_oma)
                        local p_om     = chiprob(`df_om',`chi2_om')
                        local p_oma    = chiprob(`df_om',`chi2_oma')
                  }

                  tempname W`i'
                  mat `W`i'' = e(Sigma)

                  if "`bLP_bp'" == "." {
                        local bLP_bp = cond(`p_bp'>(1-(`level'/100)),`i',.)
                  }
                  if "`bLP_wn'" == "." {
                        local bLP_wn = cond(`p_wn'>(1-(`level'/100)),`i',.)
                  }
                  if "`bLP_om'" == "." {
                        local bLP_om = cond(`p_om'>(1-(`level'/100)),`i',.)
                  }
                  if "`bLP_oma'" == "." {
                        local bLP_oma = cond(`p_oma'>(1-(`level'/100)),`i',.)
                  }

                  di as res    %2.0f `i'        _s(1) %5.0g e(N)            /*
                    */   _s(1) %4.0g `df'       _s(3) %6.2f `chi2_bp'       /*
                    */   _s(3) %5.3f `p_bp'     _s(2) "{txt}{c |}"          /*
                    */   _s(0) %6.0g `df_wn'    _s(2) %8.2f `chi2_wn'       /*
                    */   _s(3) %5.3f `p_wn'     _s(2) "{txt}{c |}"          /*
                    */   _s(3) %5.3f `p_om'     _s(4) %5.3f `p_oma'

                  if `i'== `lags' {
                        di "{txt}{hline 32}{c BT}{hline 26}{c BT}{hline 19}"
                        di "{txt}Best" as res                               /*
                         */ _col(25) %4.0g `bLP_bp' _col(52) %4.0g `bLP_wn' /*
                         */ _col(63) %4.0g `bLP_om' _col(72) %4.0g `bLP_oma'
                  }
            }
            if !("`cov'" == "" & "`corr'" == "") {
                  if ("`cov'" != "") { local mats "Covariance" }
                  else { local mats "Correlation" }
                  local header "`mats' matrices of residuals"
                  local dup = length("`header'")

                  di _n "{txt}`header'" _n "{hline `dup'}" _c
                  forv i = 1/`lags' {
                        di _n "{txt}Lag: {res}`i'"
                        if ("`cov'" != "") {
                              mat list `W`i'', nohead noblank
                        }
                        else {
                              mat CORR`i' = corr(`W`i'')
                              mat list CORR`i', nohead noblank format(%9.4f)
                              mat drop CORR`i'
                        }
                  }
            }

            /* LR test for smaller lag length */

            local increme = 1      /* may later let users specify increment */
            local p1 = `lags'
            local p0 = `p1'-`increme'
            local dof = `neq'^2*(`p1'-`p0')
            local header "Likelihood ratio tests for smaller lag length"
            local j = length("`header'")

            di _n "{txt}`header'" _n "{hline `j'}"
            di "Ho: lags = k" _n "H1: lags = k+`increme'"
            di "{col 7}k    chi2({res:`dof'}){col 23}P>chi2"
            di "{col 5}{hline 24}"
            while `p0' > 0 {
                  tempname lr`p0' pval`p0'
                  sca `lr`p0''   =  e(N)*(ln(det(`W`p0''))-ln(det(`W`p1'')))
                  sca `pval`p0'' =  chiprob(`dof',`lr`p0'')
                  di as res _col(6)  %2.0f `p0'     _col(12) %7.0g `lr`p0'' /*
                    */    _col(24) %5.3f `pval`p0''
                  local p1 = `p1'-`increme'
                  local p0 = `p0'-`increme'
            }
      }
end

exit
