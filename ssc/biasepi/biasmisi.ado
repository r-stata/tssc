

*! v 1.0.1 Chunsen Wu 8march2019 bias analysis for misclassification
*! v 1.0.2 Chunsen Wu 19April2019 bias analysis for misclassification

**************************************************
//
**************************************************

capture program drop myrr
program myrr, rclass
version 13.1
args aa bb cc dd
local MM=`aa'+`cc'
local NN=`bb'+`dd'
local CA=`aa'+ `bb'
local NA=`cc'+ `dd'
local TTT=`aa'+`cc'+`bb'+`dd'
local risk1=`aa'/`MM'
local risk0= `bb'/`NN'
local rrr=`risk1'/`risk0'
local rdd=`risk1' - `risk0'
local odds1=`aa'/`cc'
local odds0=`bb'/`dd'
local orr=`odds1'/`odds0'

local selnrr=sqrt(1/`aa' + 1/`bb' - 1/`MM' - 1/`NN')
local selnor=sqrt(1/`aa' + 1/`bb' + 1/`cc' - 1/`dd')
local serisk1 = sqrt((`risk1'*(1-`risk1'))/`MM')
local serisk0 = sqrt((`risk0'*(1-`risk0'))/`NN')
local serd= sqrt(`serisk1'^2 + `serisk0'^2)

mat SE=J(3,1,.)
    mat rownames SE=selnrr selnor serd
	mat SE[1,1]=`selnrr'
	mat SE[2,1]=`selnor'
	mat SE[3,1]=`serd'

mat effect=J(3,1,.)
    mat rownames effect=RR OR RD	
	mat effect[1,1]=`rrr'
	mat effect[2,1]=`orr'
	mat effect[3,1]=`rdd'
return scalar rrr=`rrr'
return scalar rdd=`rdd'
return scalar orr=`orr'
return matrix SE=SE
return matrix effect=effect

end

****************************************************************************************************
//
****************************************************************************************************
capture program drop backtotrue
program backtotrue, rclass
version 13.1
syntax [anything] [, se(real 0.8) sp(real 0.9)  ppv(numlist max=1) npv(numlist max=1)]
tokenize `anything'
local x1=`1'
local x0=`2'

local pp: word count `ppv'
local np: word count `ppv'
*display "`pp'"
*display "`np'"

if `pp'==0 | `np'==0 {
local D=( `sp'* `x1'*(1-`se') - `sp'* `se'* `x0' ) / (1- `se' - `sp')
local C= `x0' - `D'

local A= (`se'* ( `x0'- `D'))/( 1- `se')
local B= `x1' - `A'

local T1=`A'+`C'
local T0=`B'+ `D'
local all=`T1' + `T0'
mat T=`A' , `B',  `x1' \ `C', `D', `x0' \ `T1', `T0', `all'
mat colnames T = Yes No All
mat rownames T = Yes No All
mat list T
local ppv=T[1,1]/T[1,3]
local npv=T[2,2]/T[2,3]
display "PPV = " %6.2f `ppv'
display "NPV = " %6.2f `npv'
return scalar ppv=`ppv'
return scalar npv=`npv'
return mat S=T
}
*


if `pp'!=0 & `np'!=0 {
local A= `x1' * `ppv'
local B= `x1' - `A'
local D= `x0' * `npv'
local C= `x0' - `D'

mat P=`A' , `B' \ `C', `D'
mat list P
return mat S=P
}
end

**************************************************
//
**************************************************
capture program drop biasmisi
program biasmisi, rclass
syntax [anything] [if] [in] [, sa(real 0.75) sb(real 0.95) sc(real 0.75) sd(real 0.95) MIStype(real 1)  ]
version 13.1
tokenize `anything'
marksample touse

local nnum : word count `anything'
if `nnum'!= 4 {
display as error "you should provide exactly 4 values, which refer to a, b, c, and d in a 2x2 table"
exit
}
*

if `sa'<=0 | `sa'>1 {
display as error "sa has to be between 0 and 1"
exit
}
*
if `sb'<=0 | `sb'>1 {
display as error "sa has to be between 0 and 1"
exit
}
*
if `sc'<=0 | `sc'>1 {
display as error "sa has to be between 0 and 1"
exit
}
*
if `sd'<=0 | `sd'>1 {
display as error "sa has to be between 0 and 1"
exit
}
*

if `mistype'!=1 & `mistype'!=2 {
display as error "Mistype can only be either 1 or 2, which refer to misclassification for exposure or outcome, respectively"
exit
}
*

local a=`1'
local b=`2'
local c=`3'
local d=`4'


local DD=`1'+ `2'
local dd=`3'+`4'
local EE=`1'+ `3'
local ee=`2'+ `4'
local TT=`1'+ `2' + `3'+`4'

mat O=`1', `2', `DD' \ `3',`4', `dd' \ `EE', `ee', `TT'
myrr `1' `2' `3' `4'
local or=r(orr)
local rr=r(rrr)
local rd=r(rdd)
mat CoventionalSE=r(SE)


if `mistype'==1 {
    display as result _newline(2)"The exposure misclassification"
    ********************
    //a-A
    ********************
    local A=(`a' - `DD'*(1- `sb'))/(`sa' - (1 - `sb'))
    ********************
    //b-B
    ********************
    local B=`DD'-`A'
    ********************
    //c-C
    ********************
    local C=(`c' - `dd'*(1- `sd'))/(`sc' - (1 - `sd'))
    ********************
    //d-D
    ********************
    local D=`dd'-`C'
    *
	
	qui backtotrue `a' `b', se(`sa') sp(`sb')
	local ppv1=r(ppv)
	local npv1=r(npv)
	mat S1=r(S)
	qui backtotrue `c' `d', se(`sc')  sp(`sd')
	local ppv0=r(ppv)
	local npv0=r(npv)
	mat S0=r(S)
	mat S=S1,S0
    **************************************************
    //
    **************************************************
	display as text _newline(1)"**************************************************"
    display as result _newline(0)"//Observed 2x2 table"
	display as text _newline(0)"**************************************************"
    mat colnames O= Exposed Unexposed  Total
    mat rownames O=Case Noncase  Total
    mat list O, format(%12.1f) noheader

display _newline(1)"Conventional risk ratio =" %6.4f  `rr'
display _newline(0)"Conventional odds ratio =" %6.4f  `or'
display _newline(0)"Conventional risk difference =" %6.4f  `rd'

	display as text _newline(1)"**************************************************"
    display as result _newline(0)"//Bias parameters"
	display as text _newline(0)"**************************************************"	
	
    display _newline(1)"Sensitivity for the exposed among the cases = " %5.4f `sa'
    display "Specificity for the unexposed among the cases  = " %5.4f `sb'
    display "Sensitivity for the exposed among the noncases = " %5.4f `sc'
    display "Specificity for the unexposed among the noncases = " %5.4f `sd'

}
*

if `mistype'==2 {
    display as result _newline(2)"The outcome/disease misclassification"
    ********************
    //a-A
    ********************
    local A=(`a' - `EE'*(1- `sc'))/(`sa' - (1 - `sc'))

    ********************
    //b-B
    ********************
    local B=(`b' - `ee'*(1- `sd'))/(`sb' - (1 - `sd'))
    ********************
    //c-C
    ********************
    local C=`EE'-`A'

    ********************
    //d-D
    ********************
    local D=`ee'-`B'

   *
   	qui backtotrue `a' `c', se(`sa') sp(`sc')
	local ppv1=r(ppv)
	local npv1=r(npv)
	mat S1=r(S)
	qui backtotrue `b' `d', se(`sb') sp(`sd')
	local ppv0=r(ppv)
	local npv0=r(npv)
	mat S0=r(S)
    mat S=S1,S0
    **************************************************
    //
    **************************************************
	display as text _newline(1)"**************************************************"
    display as result _newline(0)"//Observed 2x2 table"
	display as text _newline(0)"**************************************************"
    mat colnames O= Exposed Unexposed Total
    mat rownames O=Case Noncase Total
    mat list O, format(%12.1f)  noheader

display _newline(1)"Conventional risk ratio =" %6.4f  `rr'
display _newline(0)"Conventional odds ratio =" %6.4f  `or'
display _newline(0)"Conventional risk difference =" %6.4f  `rd'

	display as text _newline(1)"**************************************************"
    display as result _newline(0)"//Bias parameters"
	display as text _newline(0)"**************************************************"	
	
    display _newline(1)"Sensitivity for the case among the exposed = " %5.4f `sa'
    display "Sensitivity for the case among the unexposed = " %5.4f `sb'
    display "Specificity for the noncases among the exposed = " %5.4f `sc'
    display "Specificity for the noncases among the unexposed = " %5.4f `sd'

}
*

*
display as text _newline(1)"**************************************************"
display as result _newline(0)"//Corrected 2x2 table"
display as text _newline(0)"**************************************************"
myrr `A' `B'  `C' `D'
local aor=r(orr)
local arr=r(rrr)
local ard=r(rdd)


local DDv=`A' + `B'
local ddv=`C' + `D'
local EEv=`A' + `C'
local eev=`B' + `D'
local TTv=`A' + `B' + `C'+ `D'
mat C=`A', `B', `DDv'  \ `C', `D', `ddv' \ `EEv', `eev', `TTv'

mat colnames C= Exposed Unexposed Total
mat rownames C=Case Noncase Total
mat list C, format(%12.1f)  noheader


display _newline(1)"Corrected risk ratio = " %6.4f `arr'
display _newline(0)"Corrected odds ratio = " %6.4f `aor'
display _newline(0)"Corrected risk difference = " %6.4f `ard'

*
**************************************************
//predictive values
**************************************************
if `mistype'==1 {
local pa=`ppv1'
local pb=`npv1'
local pc=`ppv0'
local pd=`npv0'
}
if `mistype'==2 {
local pa=`ppv1'
local pb=`ppv0'
local pc=`npv1'
local pd=`npv0'
}
*
display as text _newline(1)"**************************************************"
display as result _newline(0)"//PPV, NPV 2x2 table"
display as text _newline(0)"**************************************************"
mat P=`pa' , `pb'  \ `pc' , `pd'
mat colnames P= Exposed Unexposed
mat rownames P=Case Noncase
mat list P, format(%4.2f) noheader

**************************************************
//illegal values
**************************************************
if C[1,1]<0 | C[1,2]<0 | C[2,1]<0 | C[2,2]<0 {
  display as error "Some of the values for the parameters are illegal, please check"
  local illegal=1
}
* 
else {
  local illegal=0
}
*

**************************************************
//return values
**************************************************
return scalar RD_Corrected=  `ard'
return scalar OR_Corrected=  `aor'
return scalar RR_Corrected=  `arr'
return scalar RD_Observed= `rd'
return scalar OR_Observed= `or'
return scalar RR_Observed= `rr'


return scalar illegal=`illegal'

retur matrix S=S  /*distribution according to the sensitivity*/
return matrix P=P  /*predictive value*/
return matrix C=C  /*corrected*/
return matrix SE=CoventionalSE
return matrix O=O  /*observed*/

end






