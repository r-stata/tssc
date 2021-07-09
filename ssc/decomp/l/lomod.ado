program define lomod

* part of a program to conduct a Blinder-Oaxaca decomposition of earnings.
* Requires regression for subgroup of high wage persons to be
* run first, followed by himod [,ds]. Then the regression for the
* low wage persons, followed by lomod [,ds]. Then decomp is run.
*! ver 1.7 8nov2010 - fixed bug regards estimation sample (was using means
*! from full sample, now use wage equation sample means). 
*! Thanks to Anne Busch for drawing my attention to this.
* ver 1.6 25jan05 - added Tobit correction & removed Heck option (now built-in)
* ver 1.5 30sept04 - added Heckman option
* ver 1.4 26nov02 - added weighting
* ver 1.3 25july02 - fixed typo in himod and lomod
* ver 1.2  4feb02 - changed output presentation
* ver 1.1 14apr00 - original program developed


version 8.2
syntax [fweight aweight] [, ds heck] 

mat beta=e(b)
mat beta=beta'
local total=0
local varnms : rownames(beta)
local k=rowsof(beta)
local depvar = e(depvar)
gen __fullsample = e(sample)
gen __wagesample = cond(__fullsample==1 & !mi(`depvar'), 1, 0)
count if __wagesample==1
local numobs = r(N)
if e(cmd)=="heckman" | e(cmd)=="tobit" {
     local n=0
     while `n'<`k' {
     local `++n'
     local varnm: word `n' of `varnms'
     local reducednms="`reducednms' `varnm'"
     if "`varnm'"=="_cons"{
          local k=`n'
          }
     }
mat locoef=J(`k',1,1)
mat rownames locoef=`reducednms'
foreach r of numlist 1/`k'{
     mat locoef[`r',1]=beta[`r',1]
     }
}
else{
    mat locoef=beta
}
mat lomean=J(`k',1,1)
mat lopred=J(`k',1,1)
foreach r of numlist 1/`k'{
  local varnm: word `r' of `varnms'
  if `r'<`k'{
    qui sum `varnm' if __wagesample==1 [`weight' `exp']
    local varmn=r(mean)
    mat lomean[`r',1]=`varmn'
  }
  mat lopred[`r',1]=locoef[`r',1]*lomean[`r',1]  
  local total=`total'+lopred[`r',1]
}
local dtotal=exp(`total')
mat lofinal=locoef,lomean,lopred
mat colnames lofinal=Coeffs Means Predictions
if "`ds'" ~="" {
     di 
     di as text "{title:Coefficients, means & predictions for low model}"
     di
     di as text "{hline 13}{c TT}{hline 40}"
     di as text "{ralign 12: Variable} {c |} {ralign 13: Coefficent}" /*
          */ "{ralign 12: Mean} {ralign 13: Prediction}"
     di in text "{hline 13}{c +}{hline 40}"
     foreach r of numlist 1/`k'{
         local varnm: word `r' of `varnms'
         local varnm=abbrev("`varnm'",15)
         di as text "{ralign 12:`varnm'} {c |} {col 20}" /*
            */ as result %9.3f lofinal[`r',1] "{col 32}" /*
            */ as result %9.3f lofinal[`r',2] "{col 46}" /*
            */ as result %9.3f lofinal[`r',3] 
     }
     di as text "{hline 13}{c BT}{hline 40}"
     di
     di as text "Prediction (ln): " as result %9.3f `total'
     di as text "Prediction ($): " as result %9.2f `dtotal'
     di as text "Number of observations: " as result %9.0fc `numobs'
     }
capture drop __wagesample
capture drop __fullsample
end
