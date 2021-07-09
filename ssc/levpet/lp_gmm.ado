*! version 1.0.0 20031022                                      (SJ4-2: st0060)

*  J. Levinsohn, A. Petrin, and B. Poi
*  Created: 20030520
*  Usage: use -levpet-; this program is not for external use.
*  Sets up GMM problem, then calls -nl- or grid search.

program define lp_gmm, rclass sortpreserve
   
   version 7.0
   syntax varname, free(varlist) proxy(varlist) capital(varname) /*
               */  i(varname) t(varname) converrs(integer) just(integer) /*
               */  grid(integer)
               
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
         noi di "GMM version not implemented for multiple proxy variables."
         exit 198
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
   
      if `converrs' == 0 {
         /* Second stage  */
         tsset `i' `t'
      
         /* Build up instruments */
         tempvar lagp lagp2 lagk
         gen double `lagp' = L.`proxy'
         gen double `lagp2' = L2.`proxy'
         gen double `lagk' = L.`capital'
         local lagfree ""
         foreach var of local free {
            local lagfree "`lagfree' L.`var'"
         }
      
         if `just' == 0 {
            global LP_insts `capital' `lagk' `lagp' `lagp2' `lagfree'
         }
         else {
            global LP_insts `capital' `lagp'
         }
         global LP_phihat `phihat'
         global LP_rssterm `rssterm'
         global LP_capital `capital'
         global LP_proxy `proxy'
         tempname gmmk gmmp
         if `grid' == 0 {
            tempvar zero
            gen `zero' = 0
            replace `zero' = 1 in l
            nl lp_bs_gmm `zero'
            tempname gmmb 
            mat `gmmb' = e(b)
            mat `gmmk' = `gmmb'[1, "b_k"]
            sca `gmmk' = 1 / (1 + exp(trace(`gmmk')))
            mat `gmmp' = `gmmb'[1, "b_p"]
            sca `gmmp' = 1 / (1 + exp(trace(`gmmp')))
         }
         else {
            lp_gmm_grid
            sca `gmmk' = r(b_k)
            sca `gmmp' = r(b_p)
         }
         macro drop LP_*
      }
   }  /* End of quietly block. */      
   /* Return the stuff as r-class scalars; will bstrap these. */
   tempname k
   foreach var in `free' {
      mat `k' = `freebetas'[1, "`var'"]
      return scalar `var' = trace(`k')
   }
   if `converrs' == 0 {
      return scalar `capital' = `gmmk'
      return scalar `proxy' = `gmmp'
   }
   
end
