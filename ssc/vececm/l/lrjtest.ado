*! lrjtest: LR test of coefficients in cointegrating relationships
*! version 2.0   PJoly   07apr2002
* v.2.0   PJoly   07apr2002   updated to version 7 + misc
* v.1.0   PJoly   04jan2001   lrcotest updated to version 6
* code taken from lrcotest v.2.0 (Ken Heinecke, 2/22/93, sts9: STB-21)

program define lrjtest, rclass
      version 7

      if "`e(cmd)'" != "johans" { error 301 }

      syntax varlist(min=1 ts), [ Cirel(int 1) Restrict ]

      tempname H HP _H IRCHOLD MAXL _M NPHIP NTREVEC RCHOLD REIGVAL REVECT
      tempname TIRCH TRALPHA TREVAL TREVECT Y1 Y2 Y3 Y4 Y5 Y6 Y7 TEMP NRBP NRA

      mat `TEMP' = e(NBP)
      local vlist : colnames `TEMP'
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

      /* Create restriction matrix H from the variables in the model */

      mat `H' = I(`nv')
      mat colnames `H' = `vlist'

      /* Create restriction matrix */

      foreach var of local clist {
            mat `_H' = `H'[.,"`var'"]
            mat `_M' = (nullmat(`_M'),`_H')
      }
      mat `H' = `_M'
      mat rownames `H' = `vlist'

      /* Finally, create a numbered list of vectors */

      forv j = 1/`cirel' { local vecl `vecl' vec`j' }

      /* Calculate eigenvalues from the restricted model */

      mat `HP' = `H''
      mat `Y1'= `HP' * e(SLL)
      mat `Y2' = `Y1' * `H'
      mat `RCHOLD' = cholesky(`Y2')
      mat `IRCHOLD' = inv(`RCHOLD')
      mat `TIRCH' = `IRCHOLD''
      mat `Y3' = `IRCHOLD' * `HP'
      mat `Y4' = `Y3' * e(TSDL)
      mat `Y5' = `Y4' * e(ISDD)
      mat `Y6' = `Y5' * e(SDL)
      mat `Y7' = `Y6' * `H'
      mat `MAXL' = `Y7' * `TIRCH'
      mat symeigen `REVECT' `REIGVAL' = `MAXL'
      mat `TREVAL' = `REIGVAL''
      if "`restrict'" != "" {               /* Display restricted estimates */
            di _n as txt "Eigenvalues from restricted model"
            mat l `TREVAL', noh nonames noblank

            /* Calculate and display the normalized restricted alpha and beta
               prime matrices */

            mat `TREVECT' = `REVECT''
            mat `NTREVEC' = `TREVECT' * `IRCHOLD'
            mat `NPHIP' = `NTREVEC'[1..`cirel',.]
            mat `NRBP' = `NPHIP' * `HP'
            mat rownames `NRBP' = `vecl'
            di _n as txt "Normalized restricted Beta'"
            mat l `NRBP', names nob noh
            mat `TRALPHA' = `NRBP' * e(TSDL)
            mat `NRA' = `TRALPHA''
            mat rownames `NRA' = `vlist'
            di _n as txt "Normalized restricted Alpha"
            mat l `NRA', nob noh
      }                 /* end restricted estimates */

      /* Calculate likelihood ratio test statistics */

      local stat = 0
      forv i = 1/`cirel' {
            tempname TEVL
            mat `TEVL' = e(TEVL)
            local stat = `stat' + log((1-`TREVAL'[`i',1])/(1-`TEVL'[`i',1]))
      }

      ret sca cirel = `cirel'
      ret sca df = `cirel' * `nvar'
      ret sca lr = e(N) * `stat'
      ret sca p_lr = chiprob(`return(df)',`return(lr)')
      if "`restrict'" != "" {
            ret mat NRBP `NRBP'
            ret mat NRA `NRA'
      }

      di _n as txt "Cointegration: likelihood ratio test"                   /*
                */     _col(40) "chi2("   as res         `return(df)'       /*
                */     as txt   ") = "    as res  %6.2g  `return(lr)'
      di as txt _col(40) "Prob > chi2 = " as res  %4.3f  `return(p_lr)'
end
