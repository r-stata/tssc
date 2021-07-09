*! wjtest: Wald test of coefficients in cointegrating relationships
*! version 2.0   PJoly   07apr2002
* v.2.0   PJoly   07apr2002   updated to version 7 + misc
* v.1.0   PJoly   11jun2001   wcotest updated to version 6
* code taken from wcotest v.2.0 (Ken Heinecke, 2/22/93, sts9: STB-21)

program define wjtest, rclass
      version 7

      if "`e(cmd)'" != "johans" { error 301 }

      syntax varlist(min=1 ts), [ Cirel(int 1) ]

      tempname B BPK D I ID IDlI IKvvK _J K KBDBK KP KPB KPBD KPv
      tempname KvvK _K lambda NBETA stat v vPK TEVL

      mat `NBETA' = e(NBP)'
      local vlist : rownames `NBETA'
      local nv : word count `vlist'
      local nvar : word count `varlist'

      if `nvar'>=`nv' {
            di as err "varlist must contain fewer variables than " _c
            di as err "depvarlist of -johans ...-"
            exit 198
      }

      if `cirel'>`nv' {
            di as err "cir() invalid, can't have more cointegrating " _c
            di as err "relationships than equations"
            exit 198
      }

      /* Now create a list of the variables in the model that are NOT being
         tested */

      local clist "`vlist'"
      foreach var of local varlist {
            local clist : subinstr local clist "`var'" "", word all         /*
                                                        */  count(local any)
            if !`any' {
                  di as err "varlist must be a subset of depvarlist " _c
                  di as err "of -johans ...-"
                  exit 198
            }
      }

      mat `K' = I(`nv')
      mat colnames `K' = `vlist'
      mat rownames `K' = `vlist'

      /* Create restriction matrix */

      foreach var of local varlist {
            mat `_K' = `K'[.,"`var'"]
            mat `_J' = (nullmat(`_J'),`_K')
      }
      mat `K' = `_J'

      /* Calculate Wald squared statistic (J&J Oxford Bulletin 52,2 1990) */

      mat `B' = `NBETA'[.,1..`cirel']
      mat `KP' = `K''
      mat `KPB' = `KP'*`B'
      mat `BPK' = `KPB''
      mat `I' = I(`cirel')
      mat `TEVL' = e(TEVL)
      mat `lambda' = `TEVL'[1..`cirel',.]
      mat `D' = diag(`lambda')
      mat `ID' = inv(`D')
      mat `IDlI' = `ID'-`I'
      mat `D' = inv(`IDlI')
      mat `KPBD'=`KPB'*`D'
      mat `KBDBK' = `KPBD'*`BPK'
      local ncv = `cirel'+1
      mat `v' = `NBETA'[.,`ncv'...]
      mat `KPv' = `KP'*`v'
      mat `vPK' = `KPv''
      mat `KvvK' = `KPv'*`vPK'
      mat `IKvvK' = inv(`KvvK')
      mat `stat' = `KBDBK' * `IKvvK'

      ret sca df = `cirel'*`nvar'
      ret sca wald = e(N) * trace(`stat')
      ret sca p_wald = chiprob(`return(df)',`return(wald)')

      di _n as txt "Cointegration: Wald test"                               /*
                */     _col(40) "chi2("   as res         `return(df)'       /*
                */     as txt   ") = "    as res  %6.2g  `return(wald)'
      di as txt _col(40) "Prob > chi2 = " as res  %4.3f  `return(p_wald)'
end
