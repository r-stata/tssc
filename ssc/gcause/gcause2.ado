*! gcause: Granger causality test
*! version 1.0   09oct2002   PJoly
*! modified to accept onepanel  cfb  21apr2010
program define gcause2, rclass
      version 7.0

      syntax varlist(min=2 max=2 ts) [if] [in],   /*
            */ Lags(numlist max=1 min=1 >0 int) [ EXog(varlist ts) REGress ]

      qui {
            marksample touse
            _ts tvar panelvar `if' `in', sort onepanel
            tsset
            markout `touse' `tvar' L(1/`lags').(`varlist') `exog'
            local fmt : format `tvar'
            qui summ `tvar' if `touse', meanonly
            local tmin = trim(string(r(min), "`fmt'"))
            local tmax = trim(string(r(max), "`fmt'"))
            local n = r(N)

            tempname rss0 rss1
            tokenize `varlist'
            reg `1' L(1/`lags').`1' `exog' if `touse'
            sca `rss0' = e(rss)
            reg `1' L(1/`lags').`1' L(1/`lags').`2' `exog' if `touse'
            sca `rss1' = e(rss)
            local df   = `lags'
            local df_r = e(df_r)
      }
      * asymptotic
      ret sca F = [(`rss0'-`rss1')/`df'] / [`rss1'/`df_r']
      ret sca p = fprob(`df',`df_r',`return(F)')
      * small sample
      ret sca F_a = e(N)*(`rss0'-`rss1') / `rss1'
      ret sca p_a = chiprob(`df',`return(F_a)')

      di "{txt}Granger causality test" _c
      di "{txt}{ralign 50:Sample: {res:`tmin'} to {res:`tmax'}}"
      di "{txt}{ralign 72:obs = {res:`n'}}"
      di "{txt}H0: {res:`2'} does not Granger-cause {res:`1'}" _n
      di "{txt}{ralign 25:F( `df', `df_r') =}" as res %8.2f `return(F)'
      di "{txt}{ralign 25:Prob > F =} " as res %8.4f `return(p)' _n
      di "{txt}{ralign 25:chi2(`df') =}" as res %8.2f `return(F_a)'  _c
      di "{txt}{col 40}(asymptotic)"
      di "{txt}{ralign 25:Prob > chi2 =}" as res %8.4f `return(p_a)' _c
      di "{txt}{col 40}(asymptotic)"
      if "`regress'" != "" { reg }
      ret sca df   = `df'
      ret sca df_r = `df_r'
end
