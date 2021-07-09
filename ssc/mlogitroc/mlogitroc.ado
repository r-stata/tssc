program define mlogitroc,eclass
*!Multiclass ROC curve and AUC from mlogit
/*
Date: 9/27/10  
Author: Leif Peterson, TMHRI, Houston 
Generates ROC curve and AUC for multiclass logistic run (using mlogit)

Format:
 mlogitroc depvar varlist [if] [in]

See help.
*/
version 11
syntax varlist [if] [in]
local touse `if' `in'
local ncol:word count `varlist'
local depvar:word 1 of `varlist'
forv i=2(1)`ncol' {
  local indepvar:word `i' of `varlist'
  local indepvars `indepvars' `indepvar'
}

set more off
local iterations=100
cap drop cweight
gen cweight=0
matrix altacc=J(`iterations',1,0)
matrix nullacc=J(`iterations',1,0)
summarize `depvar' 
local numclasses = r(max)
forv m=1(1)2{
  forv iter=1(1)`iterations'{
    preserve
    quietly replace cweight=0
    bsample, weight(cweight)
    if `m'==1{
	   mlogit `depvar' `indepvars' `touse' [fweight=cweight],iterate(20)
    }
    if `m'==2{
  	   //shufflevar `depvar'
	    forv i=1(1)`sampsize'{
          local buff1 =`depvar'[`i']
		  local ran1 = int(runiform() * (`sampsize' - 1 ) + 1)
          local buff2 =`depvar'[`ran1']
		  quietly replace `depvar'=`buff2' in `i'
		  quietly replace `depvar'=`buff1' in `ran1'
        } 
	   mlogit `depvar' `indepvars' `touse' [fweight=cweight],iterate(20) 
    }
    forv k=1(1)`numclasses'{
      cap drop c`k'
      predict c`k',outcome(`k')
    }
    local nleftout=0
    local ncorrect=0
    local sampsize=_N
    forv i=1(1)`sampsize'{
      if cweight[`i']==0{
        local nleftout = `nleftout' + 1
        local maxpred=0
	    forv k=1(1)`numclasses'{
          if c`k'[`i'] > `maxpred'{
            local maxpred=c`k'[`i']
		    local predclass=`k'
          }	    
        }
	    if `predclass'==`depvar'[`i']{
    	    local ncorrect=`ncorrect' + 1
	    }
     }    
    }
    local accuracy=`ncorrect'/`nleftout'
    if `m'==1{
	  mat altacc[`iter',1]=`accuracy'
	}
    if `m'==2{
	  mat nullacc[`iter',1]=`accuracy'
	}
    di `accuracy'
    restore
  }
}
forv iter=1(1)`iterations'{
di altacc[`iter',1]
}
forv iter=1(1)`iterations'{
di nullacc[`iter',1]
}
cap drop altacc
gen altacc=.
forv iter=1(1)`iterations'{
  quietly replace altacc=altacc[`iter',1] in `iter'
}
cap drop nullacc
gen nullacc=.
forv iter=1(1)`iterations'{
  quietly replace nullacc=nullacc[`iter',1] in `iter'
}

cap drop xaltpdf yaltpdf xnullpdf ynullpdf
kdensity altacc,n(100) kernel(gaussian) generate(xaltpdf yaltpdf)  saving(kdealtpdf,replace)
kdensity nullacc,n(100) kernel(gaussian) generate(xnullpdf ynullpdf) saving(kdenullpdf,replace)

summarize yaltpdf
local fac1 = 1 / r(sum)
summarize ynullpdf
local fac2 = 1 / r(sum)

cap drop normyaltpdf normynullpdf
gen normyaltpdf=.
gen normynullpdf=.
forv i=1(1)100{
  replace normyaltpdf = yaltpdf[`i'] * `fac1' in `i'
}
forv i=1(1)100{
  replace normynullpdf = ynullpdf[`i'] * `fac2' in `i'
}
twoway (scatter normyaltpdf xaltpdf) (scatter normynullpdf xnullpdf), saving(pdfs,replace)

cap drop fpr tpr
gen fpr=.
gen tpr=.
forv i=1(1)100{
  local myfpr=0
  local mytpr=0
  local xcut=xnullpdf[`i']
  forv j=1(1)100{
     if xnullpdf[`j'] > `xcut'{
	   local myfpr= `myfpr' + normynullpdf[`j'] 
	 }
     if xaltpdf[`j'] > `xcut'{
	   local mytpr= `mytpr' + normyaltpdf[`j'] 
	 }
  }
  replace fpr=`myfpr' in `i'
  replace tpr=`mytpr' in `i'
}
local auc=0
forv i=1(1)100{
  local xcut=xnullpdf[`i']
  forv j=1(1)100{
     if xaltpdf[`j'] > `xcut'{
	 local auc = `auc' + normyaltpdf[`j'] 
     }
  }
}
local auc = `auc'/100
twoway scatter tpr fpr, msize(vtiny) lwidth(thick) lcolor(navy) connect(l) ysc(r(0 1))  xsc(r(0 1)) xlab(0.0(.2)1.0,format(%5.1f)) ylabel(0(0.2)1.0,format(%5.1f)) xsize(8) ysize(6) title("AUC=" `auc')  saving(roc,replace)  // subtitle("") xtitle("") // b1title("") 
graph combine kdealtpdf.gph kdenullpdf.gph pdfs.gph roc.gph

end




 



