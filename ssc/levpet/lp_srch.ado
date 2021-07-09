*! version 1.0.0 20031022                                      (SJ4-2: st0060)

*  J. Levinsohn, A. Petrin, and B. Poi
*  Created: 20030520
*  Usage: use -levpet-; this program is not for external use.
*  Used by -levpet- for revenue version.

program define lp_srch, rclass sortpreserve
   
   version 7.0
   syntax varname, free(varlist) proxy(varlist) capital(varname) /*
               */  i(varname) t(varname)
   local va `varlist'

   quietly {

      /* Create polynomials in k and proxy(ies) */
      loc nprox : word count `proxy'   /* 1 or 2 */
      if (`nprox' == 1) {
         tempvar x10 x01 x20 x02 x30 x03 x21 x12 x11   
         gen double `x10' = `capital'
         gen double `x01' = `proxy'
         gen double `x20' = `capital'^2
         gen double `x02' = `proxy'^2
         gen double `x30' = `capital'^3
         gen double `x03' = `proxy'^3
         gen double `x21' = `capital'^2*`proxy'
         gen double `x12' = `capital'*`proxy'^2
         gen double `x11' = `capital'*`proxy'
         reg `va' `free' `x10' `x01' `x20' `x02' `x30' `x03' `x21' /*
              */ `x12' `x11'
      }
      else {
         loc proxy1 : word 1 of `proxy'
         loc proxy2 : word 2 of `proxy'
         tempvar x100 x010 x001 x110 x101 x011 x111 x200 x020 x002 
         tempvar x201 x210 x120 x102 x012 x021 x300 x030 x003
         gen double `x100' = `capital'
         gen double `x010' = `proxy1'
         gen double `x001' = `proxy2'
         gen double `x110' = `capital'*`proxy1'
         gen double `x101' = `capital'*`proxy2'
         gen double `x011' = `proxy1'*`proxy2'
         gen double `x111' = `capital'*`proxy1'*`proxy2'
         gen double `x200' = `capital'^2
         gen double `x020' = `proxy1'^2
         gen double `x002' = `proxy2'^2
         gen double `x201' = `capital'^2*`proxy2'
         gen double `x210' = `capital'^2*`proxy1'
         gen double `x120' = `capital'*`proxy1'^2
         gen double `x102' = `capital'*`proxy2'^2
         gen double `x012' = `proxy1'*`proxy2'^2
         gen double `x021' = `proxy1'^2*`proxy2'
         gen double `x300' = `capital'^3
         gen double `x030' = `proxy1'^3
         gen double `x003' = `proxy2'^3
         reg `va' `free' `x100' `x010' `x001' `x110' `x101' `x011' /*
             */          `x111' `x200' `x020' `x002' `x201' `x210' /*
             */          `x120' `x102' `x012' `x021' `x300' `x030' `x003'
      }

      /* First stage : regress log va on free vars & x** */
      /* Actual regression done above.  Collect stuff here. */
      loc numfree : word count `free'
      tempname freebetas
      mat `freebetas' = e(b)
      mat `freebetas' = `freebetas'[1, 1..`numfree']
      tempvar phihat rssterm junk
      predict double `phihat', xb
      matrix score double `junk' = `freebetas'
      replace `phihat' = `phihat' - `junk'
      gen double `rssterm' = `va' - `junk'
   
      /* Second stage : min RSS over beta_k */
      tsset `i' `t'
      tempname kstar unused1 unused2
      global LP_phihat `phihat'
      global LP_rssterm `rssterm'
      global LP_capital `capital'
      _linemax `kstar' `unused1' `unused2' : /*
         */      "lp_bs_ss" "k" 0.5 .1 100 1e-6
      macro drop LP_*
   }  /* End of quietly block. */      

   /* Return the stuff as r-class scalars; will bstrap these. */
   tempname k
   foreach var in `free' {
      mat `k' = `freebetas'[1, "`var'"]
      return scalar `var' = trace(`k')
   }
   return scalar `capital' = `kstar'
   
end
