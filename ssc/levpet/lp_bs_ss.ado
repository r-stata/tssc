*! version 1.0.0 20031022                                      (SJ4-2: st0060)

*  J. Levinsohn, A. Petrin, and B. Poi
*  Created: 20030520
*  Usage: use -levpet-; this program is not for external use.
*  Defines objective function for revenue model

program define lp_bs_ss
   
   version 7.0
   args      negssr    /* negative of residual sum of squares
         */  colon     /* colon
         */  beta_k    /* candidate beta coefficient           */
         
   tempvar omega omegal omegal2 omegal3 ohat resids
   gen double `omega' = $LP_phihat - `beta_k'*$LP_capital
   gen double `omegal' = L.`omega'
   gen double `omegal2' = `omegal'^2
   gen double `omegal3' = `omegal'^3
   reg `omega' `omegal' `omegal2' `omegal3'
   tempname tmpbeta
   mat `tmpbeta' = e(b)
   mat score double `ohat' = `tmpbeta'
   gen double `resids' = ($LP_rssterm - `beta_k'*$LP_capital - `ohat')^2
   su `resids', meanonly
   scalar `negssr' = -1*r(sum)

end
