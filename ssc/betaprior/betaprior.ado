*! Date    : 2 Mar 2011
*! Version : 1.01
*! Author  : Adrian Mander
*! Email   : adrian.mander@mrc-bsu.cam.ac.uk

*! For teaching how to find the Beta prior of choice
*!
*! betaprior, mean() var()


/*
  28Feb2011 v1.00 The command is born
   2Mar2011  v1.01 bug fix
*/

program define betaprior, rclass
version 10.0
preserve
syntax [, Mean(real 0.2) Variance(real 0.1) Graph]

/********************************************
 * Mean of beta is a/(a+b)
 * Var of beta(a,b) is ab/((a+b)^2*(a+b+1))
 ********************************************/

if `mean'>=1 | `mean'<=0 { 
  di "{err}ERROR: you can not have a mean outside the interval (0,1)"
  exit(196)
}  
di "{txt}The prior mean is {res}`mean'"
di      "{txt} and variance  is {res}`variance'"
local a = ((`mean')^2-(`mean')^3-`mean'*`variance')/`variance'
if `a'<0 {
  di "{err}ERROR: the variance is too large for this mean, {res} `mean'"
  di "{err}Select a smaller variance"
  exit(196)
}
local b = `a'/`mean'-`a'

local a3 : di %5.3f `a'
local b3 : di %5.3f `b'
local mn = `a'/(`a'+`b')
local va = `a'*`b'/((`a'+`b')^2*(`a'+`b'+1))
di "{txt}Your prior is {res}Beta(`a3',`b3')
twoway function y=betaden(`a3',`b3',x), title(Beta(`a3',`b3')) yscale(off)

restore
end
