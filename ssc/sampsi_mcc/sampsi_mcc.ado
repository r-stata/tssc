*! Date        : 25 Oct 2005
*! Version     : 1.00
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*!
*! Sample size calculations for matched case/control study

prog def sampsi_mcc, rclass
version 9.0
syntax [varlist] [, P0(real 0.5) ALT(real 1.5) PHI(real 0.2) M(integer 1) N1(integer 100) Alpha(real 0.05) POWER(real 0.9) ////
Solve(string) ]

/* 
 Null is the probability of Control being exposed 
 Alt is the odds ratio alternative
 phi is the correlation between case and control exposure status

 n is the number of cases
 m is the number of matched controls

 p0 is probability that control is exposed
 p1 is the probability that a case is exposed
*/

if "`solve'"=="" local solve "n"

local or = `alt'

local q0 = 1-`p0'
local o1 = `or'*(`p0'/`q0')
local p1 = `o1'/(1+`o1')
local q1 = 1-`p1'

local p11 = `p1'*`p0'+`phi'* sqrt(`p0'*`p1'*`q0'*`q1')
local p10 = `p1'*`q0'-`phi'* sqrt(`p0'*`p1'*`q0'*`q1')
local p01 = `q1'*`p0'-`phi'* sqrt(`p0'*`p1'*`q0'*`q1')
local p00 = `q1'*`q0'+`phi'* sqrt(`p0'*`p1'*`q0'*`q1')

local p0p = `p11'/`p1'
local p0m = `p01'/`q1'

/* Not sure what to do with negatives?? it is possible with this phi parameterisation*/
/*
if `p0m'<0 local p0m 0
else if `p0m'>1 local p0m 1
*/

local q0p = 1-`p0p'
local q0m = 1-`p0m'

/*
local testphi = (`p11'*`p00'-`p10'*`p01')/sqrt(`p1'*`p0'*`q1'*`q0')
local testor = ( `p1'/`q1' )/( `p0'/`q0' )
local testp0m = `p0' - `phi'* sqrt(`p0'*`p1'*`q0'/`q1')
*/

local eor 0
local vor 0
local e1 0
local v1 0
forv i=1/`m' {
  qui _tk `i' `m' `p1' `p0p' `q0p' `q1' `p0m' `q0m'
  local eor = `eor'+ ( `i'*`r(tk)'*`or' ) / (`i'*`or'+`m'-`i'+1 )
  local vor = `vor'+ ( `i'*`r(tk)'*`or'*(`m'-`i'+1) ) / ((`i'*`or'+`m'-`i'+1 )^2 )
  local e1 = `e1'+ ( `i'*`r(tk)' ) / (`i'+`m'-`i'+1 )
  local v1 = `v1'+ ( `i'*`r(tk)'*(`m'-`i'+1) ) / ((`i'+`m'-`i'+1 )^2 )
}

if "`solve'"=="power" {
  local zalpha = invnorm(1-`alpha'/2)
  local prob = 1 + normprob(  ( sqrt(`n1')*(`e1'-`eor')-`zalpha'*sqrt(`v1') )/( sqrt(`vor') )  )  - ////
  normprob( ( sqrt(`n1')*(`e1'-`eor')+`zalpha'*sqrt(`v1') )/( sqrt(`vor') ) ) 

  di
  di as text "Estimate power for Matched Case Control Study"
  di "Test Ho: Odds ratio=1 Ha: Odds ratio = alt. OR
  di
  di "Assumptions:"
  di
  di as text "                Alpha = " as res %9.4f `alpha' 
  di as text "(number of controls)M = " as res %9.4f `m'
  di as text "  Prob. Exp. Controls = " as res %9.4f `p0'
  di as text "               Alt OR = " as res %9.4f `alt'
  di as text "                    N = " as res %9.4f `n1'
  di
  di
  di as text "Estimated Power:"
  di
  di "       Power = " as res `prob'
  return local N_1 = `n1'
  return local N_2 = `n1'
  return local power= `prob'
}
if "`solve'"=="n" {
  local zalpha = invnorm(1-`alpha'/2)
  local zbeta = invnorm(`power')

  local n1 = ( ( `zbeta'*sqrt(`vor')+`zalpha'*sqrt(`v1') )^2 )/( (`e1'-`eor')^2 )
  local n = int(`n1')+1

  di
  di as text "Estimate Sample Size for Matched Case Control Study"
  di "Test Ho: Odds ratio=1 Ha: Odds ratio = alt. OR
  di
  di "Assumptions:"
  di
  di as text "                Alpha = " as res %9.4f `alpha' 
  di as text "(number of controls)M = " as res %9.4f `m'
  di as text "  Prob. Exp. Controls = " as res %9.4f `p0'
  di as text "            Alt OR    = " as res %9.4f `alt'
  di as text "                Power = " as res %9.4f `power'
  di
  di
  di as text "Estimated Number of Cases:"
  di
  di "       N = " as res `n'

  return local N_1 = `n'
  return local N_2 = `n'
  return local power= `power'
}

end

/* Calculate the probability of observing k exposed subjects among a case and its m controls */

prog def _tk ,rclass
args k m p1 p0p q0p q1 p0m q0m 

local temp = (`p1')* comb(`m',`k'-1)*(`p0p')^(`k'-1)*(`q0p')^(`m'-`k'+1)+(`q1')*comb(`m',`k')*(`p0m')^(`k')*(`q0m')^(`m'-`k')
return local tk = (`temp')

end
