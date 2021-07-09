*! Date        : 11 April 2011
*! Version     : 1.01
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-bsu.cam.ac.uk
*!
*! Sample size calculations for Pearson's correlation

/*
 *  11Apr2011 v1.01  ONESIDED bug fixed
 */

prog def sampsi_rho, rclass
version 9.2
syntax [varlist] [, NULL(real 0) ALT(real 0.5) N1(real 100) Alpha(real 0.05) Power(real 0.9) ////
Solve(string) ONESIDED ]

/*
 Set defaults :
  1) that we are solving for n
*/

if "`solve'"=="" local solve "n"

/* Check values */
if `alt'>1 | `alt'<0 {
  di as error "WARNING: Alternative value `alt' needs to be in [0,1]"
  exit(196)
}
if `null'>1 | `null'<0 {
  di as error "WARNING: Null value `null' needs to be in [0,1]"
  exit(196)
}
if `power'>1 | `power'<0 {
  di as error "WARNING: Power `power' needs to be in [0,1]"
  exit(196)
}
if `alpha'>1 | `alpha'<0 {
  di as error "WARNING: Significance `alpha' needs to be in [0,1]"
  exit(196)
}

/*
 Need to calculate the residual variance 
 EITHER by 
*/

local transalt  =  0.5*ln( (1+`alt')/(1-`alt') )
local transnull =  0.5*ln( (1+`null')/(1-`null') )

if "`onesided'"~="" local localalpha = `alpha'
else local localalpha = `alpha'/2

if "`solve'"=="n" {
  /* Calculate the sample size */
  local zb = invnorm(1-`power')
  local za = invnorm(`localalpha')
  local newn = ( (`zb'+`za')^2  )/( (`transalt'-`transnull')^2 ) +3


  di
  di as text "Estimated sample size for Pearson Correlation"
  di "Test Ho: Rho alt = Rho null, usually null Rho is 0
  di "Assumptions:"
  di
  if "`onesided'"==""  di as text "          Alpha = " as res %9.4f `alpha' as text "  (two-sided)"
  else  di as text "          Alpha = " as res %9.4f `alpha' as text "  (one-sided)"
  di as text "          Power = " as res %9.4f `power'
  di as text "     Null   Rho = " as res %9.4f `null'
  di as text "      Alt   Rho = " as res %9.4f `alt'
  di
  di as text "Estimated required sample size:"
  di
  di "          n = " as res `newn'

  return local power=`power'
  return local N_1 =`newn'
  return local N_2 =`newn'
}

/* Calculate the power */
if "`solve'"=="power" {

  local z = invnorm(1-`localalpha')
  local delta = abs(`transalt'-`transnull')
  local power = ( normal(`delta'*sqrt(`n1'-3)-`z' ) + normal(-1*`delta'*sqrt(`n1'-3)-`z' )  )

  di
  di as text "Estimate power for linear regression
  di "Test Ho: Alt. Rho = Null Rho, usually Null Rho is 0
  di
  di "Assumptions:"
  di
  if "`onesided'"==""  di as text "          Alpha = " as res %9.4f `alpha' as text "  (two-sided)"
  else  di as text "          Alpha = " as res %9.4f `alpha' as text "  (one-sided)"
  di as text "              N = " as res %9.4f `n1'
  di as text "       Null Rho = " as res %9.4f `null'
  di as text "        Alt Rho = " as res %9.4f `alt'
  di
  di
  di as text "Estimated power:"
  di
  di "       Power = " as res `power'

  return local power=`power'
  return local N_1 =`n1'
  return local N_2 =`n1'


}



end

