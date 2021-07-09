program define mulogit,eclass
*!Multivariate and univariate odds ratios (logistic regression) plots
/*
Date: 4/02/08  
Last modification: 4/2/08
Author: Leif Peterson, TMHRI, Houston 
Generates plots of multivariate and univariate odds ratios and
write results into the data editor

Format:
 mulogit depvar varlist [if] [in]

See help.
*/

  version 10
  syntax varlist [if] [in]
  local touse `if' `in'
  local ncol:word count `varlist'
  local depvar:word 1 of `varlist'
  forv i=2(1)`ncol' {
    local indepvar:word `i' of `varlist'
    local indepvars `indepvars' `indepvar'
  }
  logit `depvar' `indepvars' `touse'
  quietly {
  matrix b=e(b)
  matrix V=e(V)
  cap drop typeor
  gen typeor=""
  cap drop myvarnames
  gen myvarnames=""
  cap drop or
  gen or=.
  cap drop ll95ci
  gen ll95ci=.
  cap drop ul95ci
  gen ul95ci=.
  cap drop test
  gen test=.
  cap label drop testlbl
  label values test testlbl
  cap drop multtest
  gen multtest=.
  cap label drop multtestlbl
  label values multtest multtestlbl
  local varnames : colnames(V)
  local p = colsof(V)-1
  forv i =1(1)`p' {
    local w:word `i' of `varnames'
    replace myvarnames="`w'" in `i'
    replace or=exp(b[1,`i']) in `i'
    replace ll95ci=exp(b[1,`i'] - 1.96 * sqrt(V[`i',`i'])) in `i'
    replace ul95ci=exp(b[1,`i'] + 1.96 * sqrt(V[`i',`i'])) in `i'
    replace test=`i' in `i'
    replace multtest=`i' in `i'
    label define testlbl `i' "`w'"  , add
    local z = abs(b[1,`i']/sqrt(V[`i',`i']))
    if `z' <1.96 {
       label define multtestlbl `i' "`w'"  , modify
    }
    else if `z' >=1.96 & `z' <2.326 {
       label define multtestlbl `i' "*`w'", modify
    }
    else if `z' >=2.326 & `z' <3.090 {
       label define multtestlbl `i' "**`w'" , modify
    }
    else if `z' >=3.090 {
       label define multtestlbl `i' "***`w'" , modify
    }
    replace typeor="Multivariate" in `i'
  }
}

quietly {
cap drop univtest
gen univtest=.
cap label drop univtestlbl
label values univtest univtestlbl
}

forv i =2(1)`ncol' {
  quietly {
  local indepvar:word `i' of `varlist'
  }
  logit `depvar' `indepvar' `touse'
  quietly {
  matrix b=e(b)
  matrix V=e(V)
  local row = `p' + `i' - 1
  replace myvarnames="`indepvar'" in `row'
  replace or=exp(b[1,1]) in `row'
  replace ll95ci=exp(b[1,1]- 1.96 * sqrt(V[1,1])) in `row'
  replace ul95ci=exp(b[1,1]+ 1.96 * sqrt(V[1,1])) in `row'
  local newtest=`i' - 1
  replace test=`newtest' in `row'
  replace univtest=`newtest' in `row'
  label define testlbl `newtest'  "`indepvar'" , modify
  local z = abs(b[1,1]/sqrt(V[1,1]))
  if `z' < 1.96 {
  label define univtestlbl `newtest'  "`indepvar'" , modify
  }
  else if `z' >=1.96 & `z' <2.326 {
     label define univtestlbl `newtest'  "*`indepvar'" , modify
  }
  else if `z' >=2.326 & `z' <3.090 {
     label define univtestlbl `newtest'  "**`indepvar'" , modify
  } 
  else if `z' >=3.090 {
     label define univtestlbl `newtest'  "***`indepvar'" , modify
  } 
  replace typeor="Univariate" in `row' 
  }
}

twoway rcap ul95ci ll95ci test,legend(off) || scatter or test,legend(off) by(typeor) xlabel(#"`p'", labels angle(vertical) valuelabel) note("*p<0.05, **p<0.01, ***p<0.001") saving(multuniv,replace)
twoway rcap ul95ci ll95ci multtest if typeor=="Multivariate"|| scatter or multtest if typeor=="Multivariate", legend(off) xlabel(#"`p'", labels angle(vertical) valuelabel) xtitle("") l2title("Multivariate") l1title("OR(95% CI)") note("*p<0.05, **p<0.01, ***p<0.001") saving(mult,replace)
twoway rcap ul95ci ll95ci univtest if typeor=="Univariate"|| scatter or univtest if typeor=="Univariate", legend(off) xlabel(#"`p'", labels angle(vertical) valuelabel) xtitle("") l2title("Univariate") l1title("OR(95% CI)") note("*p<0.05, **p<0.01, ***p<0.001") saving(univ,replace)
graph combine univ.gph mult.gph, ycommon

end



