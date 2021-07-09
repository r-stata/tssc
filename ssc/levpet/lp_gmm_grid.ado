*! version 1.0.0  20031021                                     (SJ4-2: st0060)

*  J. Levinsohn, A. Petrin, and B. Poi
*  Usage: use -levpet-; this program is not for external use.
*  Performs grid search for GMM estimator

program define lp_gmm_grid, rclass

   version 7.0
   
   tempname bkstar bpstar critftn
   scalar `bkstar' = 0
   scalar `bpstar' = 0
   scalar `critftn' = .
   
   forvalues bk = 0.01(0.01)0.99 {
      forvalues bp = 0.01(0.01)0.99 {
         tempvar A btemp B C e j z
         gen double `A' = $LP_rssterm - `bk'*$LP_capital - `bp'*$LP_proxy
         gen double `btemp' = $LP_phihat - `bk'*$LP_capital - `bp'*$LP_proxy
         gen double `B' = L.`btemp'
         regress `A' `B'
         predict double `C', xb
         gen double `e' = `A' - `C'
         local obs = 1
         gen double `j' = 0
         gen double `z' = 0
         foreach var of global LP_insts {
            replace `j' = `e'*`var'
            su `j', meanonly
            if ($LPone == 1) {   /* original sample */
               replace `z' = (r(sum))^2 in `obs'
            }
            else {   /* recenter */
               replace `z' = (r(sum) - el(LPmoments, `obs', 1))^2 in `obs'
            }
            local obs = `obs' + 1      
         }
         summ `z', meanonly
         if (r(sum) < `critftn') {
            scalar `bkstar' = `bk'
            scalar `bpstar' = `bp'
            scalar `critftn' = r(sum)
            if ($LPone == 1) {    /* copy sample moments for reuse */
               local `obs' = `obs' - 1
               matrix LPmoments = J(`obs', 1, 0)
               forvalues i = 1/`obs' {
                  mat LPmoments[`i', 1] = `1'[`i']
               }
            }
         }
         cap drop `A' `btemp' `B' `C' `e' `j' `z'
      }
   }
   
   return scalar b_k = `bkstar'
   return scalar b_p = `bpstar'
   
end
