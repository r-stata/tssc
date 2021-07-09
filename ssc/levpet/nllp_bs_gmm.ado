*! version 1.0.0 20031022                                      (SJ4-2: st0060)

*  J. Levinsohn, A. Petrin, and B. Poi
*  Created: 20030520
*  Usage: use -levpet-; this program is not for external use.
*  -nl- function file for GMM estimator

program define nllp_bs_gmm

   version 7.0
   if "`1'" == "?" {
      global S_1 "b_k b_p"
      global b_k = -1
      global b_p = -1
      exit
   }
   
   tempname bk bp
   if ($b_k > 100) {          // This hack is needed because if $b_k
                              // equals something like 48468, then
                              // `bk' evaluates to missing.
      scalar `bk' = 0.001
   }
   else {
      scalar `bk' = 1 / (1 + exp($b_k))
   }
   if ($b_p > 100) {
      scalar `bp' = 0.001
   }
   else {
      scalar `bp' = 1 / (1 + exp($b_p))
   }
   tempvar A btemp B C e
   gen double `A' = $LP_rssterm - `bk'*$LP_capital - `bp'*$LP_proxy
   gen double `btemp' = $LP_phihat - `bk'*$LP_capital - `bp'*$LP_proxy
   gen double `B' = L.`btemp'
   regress `A' `B'
   predict double `C', xb
   gen double `e' = `A' - `C'
   
   local obs = 1
   foreach var of global LP_insts {
      tempvar j
      gen double `j' = `e'*`var'
      su `j', meanonly
      if ($LPone == 1) {   /* original sample */
         replace `1' = r(sum) in `obs'
      }
      else {   /* recenter */
         replace `1' = r(sum) - el(LPmoments, `obs', 1) in `obs'
      }
      local obs = `obs' + 1      
   }

   replace `1' = 0 in `obs'/l
   
   if ($LPone == 1) {    /* copy sample moments for reuse */
      local `obs' = `obs' - 1
      matrix LPmoments = J(`obs', 1, 0)
      forvalues i = 1/`obs' {
         mat LPmoments[`i', 1] = `1'[`i']
      }
   }
   
end
