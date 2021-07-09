

*! v 1.0.1 Chunsen Wu 8march2019 bias analysis for unmeasured and unknown Confounders
*! v 1.0.2 Chunsen Wu 19Apirl2019 bias analysis for unmeasured and unknown Confounders

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

local risk1=`aa'/`MM'
local risk0= `bb'/`NN'
local rrr=`risk1'/`risk0'
local rdd=`risk1' - `risk0'
local odds1=`aa'/`cc'
local odds0=`bb'/`dd'
local orr=`odds1'/`odds0'

return scalar rrr=`rrr'
return scalar rdd=`rdd'
return scalar orr=`orr'

end
****************************************************************************************************
//Mantel-Haenszel
****************************************************************************************************
capture program drop mhmethod
program mhmethod, rclass
version 13.1
syntax [anything] 
tokenize `anything'

local R1=`1' + `2'
local R0=`3' + `4'
local C1=`1' + `3'
local C0=`2' + `4'
local T=`1' + `2' + `3' + `4'
mat A1=`1' , `2', `R1' \ `3', `4', `R0' \ `C1' , `C0', `T'

local R1=`5' + `6'
local R0=`7' + `8'
local C1=`5' + `7'
local C0=`6' + `8'
local T=`5' + `6' + `7' + `8'
mat A0=`5' , `6', `R1' \ `7', `8', `R0' \ `C1' , `C0', `T'

*mat list A1
*mat list A0
********************
//MH_RR
********************

local numerator= A1[1,1]*A1[3,2]/A1[3,3] + A0[1,1]*A0[3,2]/A0[3,3]
local denominator=A1[1,2]*A1[3,1]/A1[3,3] + A0[1,2]*A0[3,1]/A0[3,3]
local mhrr=`numerator' / `denominator'
display "Mantel-Haenszel risk ratio = " %6.4f `mhrr'


********************
//MH_OR
********************

local numerator= A1[1,1]*A1[2,2]/A1[3,3] + A0[1,1]*A0[2,2]/A0[3,3]
local denominator=A1[1,2]*A1[2,1]/A1[3,3] + A0[1,2]*A0[2,1]/A0[3,3]
local mhor=`numerator' / `denominator'
display "Mantel-Haenszel odds ratio = " %6.4f `mhor'

********************
//MH_RD
********************

local s1=A1[1,1]*A1[3,2]/A1[3,3] - A1[1,2]*A1[3,1]/A1[3,3] 
local s0=A0[1,1]*A0[3,2]/A0[3,3] - A0[1,2]*A0[3,1]/A0[3,3] 
local numerator= `s1' + `s0'
local denominator=(A1[3,1]*A1[3,2])/A1[3,3] + (A0[3,1]*A0[3,2])/A0[3,3]
local mhrd=`numerator' / `denominator'
display "Mantel-Haenszel type method of Greenland and Robins = " %6.4f `mhrd'

return scalar mhrd=`mhrd'
return scalar mhor=`mhor'
return scalar mhrr=`mhrr'


end
**************************************************
//
**************************************************
capture program drop biasconi
program biasconi, rclass
version 13.1
syntax [anything] [if] [in] [, p0(real 0.43) p1(real 0.42) effect0(real 1.50) effect1(numlist max=1) design(real 1)  TYPEeffect(real 1)]
marksample touse
local nnum : word count `anything'
if `nnum'!= 4 {
display as error "you should provide 4 values, which refer to a, b, c, and d in a 2x2 table"
exit
}
*
tokenize `anything'

if `typeeffect'!=1 & `typeeffect'!=2 & `typeeffect'!=3 {
display as error "The option can only be 1 (risk ratio), 2 (odds ratio), or 3 (risk difference)"
exit
}
*

*
if `p0'<0 | `p0'>1 {
display as error "pa indicates the selection proportion for a, which has to be between 0 and 1"
exit
}
*
if `p1'<0 | `p1'>1 {
display as error "pa indicates the selection proportion for a, which has to be between 0 and 1"
exit
}
*
if `effect0'<0  & `typeeffect'==1 {
display as error "Risk ratio has to be positive"
exit
}
*
if `effect0'<0  & `typeeffect'==2 {
display as error "Odds ratio has to be positive"
exit
}
*
if (`effect0'<-1 | `effect0'>1)  & `typeeffect'==3 {
display as error "Invalide value for risk difference"
exit
}
*

local mordification: word count `effect1'
if `mordification'!=0 {
if `effect1'<0  & `typeeffect'==1 {
display as error "Risk ratio has to be positive"
exit
}
*
if `effect1'<0  & `typeeffect'==2 {
display as error "Odds ratio has to be positive"
exit
}
*
if (`effect1'<-1 | `effect1'>1)  & `typeeffect'==3 {
display as error "Invalide value for risk difference"
exit
}
}
*




local a=`1'
local b=`2'
local c=`3'
local d=`4'
myrr `a' `b' `c' `d'

local rrr=r(rrr)
local orr=r(orr)
local rdd=r(rdd)
*
matrix A=(`a', `b' \ `c' ,`d')
local RN=rowsof(A)
local CN=colsof(A)
forvalue r=1/`RN'  {
forvalue c=1/`CN'  {
local A`r'`c'v= A[`r',`c']
}
}
*
*
/*get the total number*/
mat M=J(1,`CN',.)
forvalue c=1/`CN' {
   local tvalue=`A1`c'v'
   forvalue r=2/`RN' {
   local tvalue=`tvalue' + `A`r'`c'v'
   }
   mat M[1,`c']= `tvalue'
  }
 *


display as text _newline(1)"**************************************************"
display as result _newline(0)"//Observed 2*2 table"
display as text _newline(0)"**************************************************"
mat O=A\M
mat colnames O= "Exposed" "Unexposed" 
mat rownames O= "Case" "Noncase" "Total"
mat list O, noheader format(%12.1f)

display _newline(1)"Conventional risk ratio     = " %4.2f `rrr'
display _newline(0)"Conventional odds ratio     = " %4.2f `orr'
display _newline(0)"Conventional risk difference= " %4.2f `rdd'

 **************************************************
 //`typeeffect'==1
 **************************************************


display as text _newline(1)"**************************************************"
display as result _newline(0)"//Bias prameters"
display as text _newline(0)"**************************************************"

local mordification: word count `effect1'
if `mordification'==0 {
local effect1=`effect0'
}
*
display _newline(1)"P0 (Prevalence of the confounder among the unexposed)= " %4.2f `p0'
display _newline(0)"P1 (Prevalence of the confounder among the exposed)= " %4.2f `p1'

if `typeeffect'==1 {
display _newline(0)"Risk ratio between the confounder and the outcome among the unexposed = " %4.2f `effect0'
display _newline(0)"Risk ratio between the confounder and the outcome among the   exposed = " %4.2f `effect1'


**************************************************
//
**************************************************

*
********************
//
********************
*
local M1v=M[1,1]* `p1'
local N1v=M[1,2]* `p0'
local M0v=  M[1,1] - `M1v'
local N0v=  M[1,2] - `N1v'


********************
//
********************
local M12 = M[1,2]
local B1v= (`effect0' * `N1v' * `A12v') / (`effect0' *  `N1v' + M[1,2] - `N1v')   /*check here whether rr0cd or rr1cd  */
local B0v= `A12v' - `B1v'
local M11=M[1,1]
local A1v= (`effect1' * `M1v' * `A11v') / (`effect1' *  `M1v' + M[1,1] - `M1v')
local A0v= `A11v' - `A1v'

}
*

**************************************************
 //
**************************************************
if `typeeffect'==2 {
display "Odds ratio between the confounder and the outcome among the unexposed = " %4.2f `effect0'
display "Odds ratio between the confounder and the outcome among the   exposed = " %4.2f `effect1'

mat C1=J(3,2,.)
mat colnames C1= "Exposed" "Unexposed" 
mat rownames C1= "Case" "Noncase" "Total"
*

**************************************************
//
**************************************************

*
********************
//
********************
*
local C1v=A[2,1]* `p1'
local D1v=A[2,2]* `p0'
local C0v=  A[2,1] - `C1v'
local D0v=  A[2,2] - `D1v'


********************
//
********************

local B1v= (`effect0' * `D1v' * `A12v') / (`effect0' *  `D1v' + `A22v' - `D1v')   /*check here whether rr0cd or rr1cd  */
local B0v= `A12v' - `B1v'
local A1v= (`effect1' * `C1v' * `A11v') / (`effect1' *  `C1v' + `A21v' - `C1v')
local A0v= `A11v' - `A1v'

local M1v=`A1v' + `C1v'
local N1v=`B1v' + `D1v'
local M0v=`A0v' + `C0v'
local N0v=`B0v' + `D0v'
}
*
 **************************************************
 //
 **************************************************
if `typeeffect'==3 {
display "Risk difference between the confounder and the outcome among the unexposed = " %4.2f `effect0'
display "Risk difference between the confounder and the outcome among the   exposed = " %4.2f `effect1'

*
local M1v=M[1,1]* `p1'
local N1v=M[1,2]* `p0'
local M0v=  M[1,1] - `M1v'
local N0v=  M[1,2] - `N1v'

********************
//
********************
local M12=M[1,2]
local B1v= (`effect0' * `N1v'* (`M12'- `N1v') +  `A12v' * `N1v') / `M12'   /*check here whether rr0cd or rr1cd  */
local B0v= `A12v' - `B1v'
local M11=M[1,1]
local A1v= (`effect1' * `M1v'* (`M11' - `M1v')+ `A11v'* `M1v') / `M11'
local A0v= `A11v' - `A1v'
*
}
*

display as text _newline(1)"**************************************************"
display as result _newline(0)"//Stratified analysis among the confounder: Yes"
display as text _newline(0)"**************************************************"
mat C1=J(3,2,.)
mat colnames C1= "Exposed" "Unexposed" 
mat rownames C1= "Case" "Noncase" "Total"
*

mat C1[3, 1]=`M1v'
mat C1[3, 2]=`N1v'
mat C1[1, 1]=`A1v'
mat C1[1, 2]=`B1v'
mat C1[2, 1]=`M1v'-`A1v'
mat C1[2, 2]=`N1v'-`B1v'



mat list C1, noheader format(%6.1f)
local RN=rowsof(C1)
local CN=colsof(C1)
forvalue r=1/`RN'  {
forvalue c=1/`CN'  {
local C1`r'`c'v= C1[`r',`c']
}
}
myrr `C111v' `C112v' `C121v' `C122v'

local rrr_c1=r(rrr)
local orr_c1=r(orr)
local rdd_c1=r(rdd)


display _newline(1)"Risk ratio between the exposure and the outcome among the strata of confounder (yes)= " %6.4f `rrr_c1'
display _newline(0)"Odds ratio between the exposure and the outcome among the strata of confounder (yes)= " %6.4f `orr_c1'
display _newline(0)"Risk difference between the exposure and the outcome among the strata of confounder (yes)= " %6.4f `rdd_c1'




display as text _newline(1)"**************************************************"
display as result _newline(0)"//Stratified analysis among the confounder: No"
display as text _newline(0)"**************************************************"
mat C0=J(3,2,.)
mat colnames C0= "Exposed" "Unexposed" 
mat rownames C0= "Case" "Noncase" "Total"


mat C0[3, 1]=`M0v'
mat C0[3, 2]=`N0v'
mat C0[1, 1]=`A0v'
mat C0[1, 2]=`B0v'
mat C0[2, 1]=`M0v'-`A0v'
mat C0[2, 2]=`N0v'-`B0v'
mat list C0, noheader format(%6.1f)

local RN=rowsof(C0)
local CN=colsof(C0)
forvalue r=1/`RN'  {
forvalue c=1/`CN'  {
local C0`r'`c'v= C0[`r',`c']
}
}
myrr `C011v' `C012v' `C021v' `C022v'

local rrr_c0=r(rrr)
local orr_c0=r(orr)
local rdd_c0=r(rdd)


display _newline(1)"Risk ratio between the exposure and the outcome among the strata of confounder (no)= " %6.4f `rrr_c0'
display _newline(0)"Odds ratio between the exposure and the outcome among the strata of confounder (no)= " %6.4f `orr_c0'
display _newline(0)"Risk difference between the exposure and the outcome among the strata of confounder (no)= " %6.4f `rdd_c0'



display as text _newline(1)"**************************************************"
display as result _newline(0)"//Adjusted for the confounder"
display as text _newline(0)"**************************************************"

local i=1
foreach r of numlist 1/2 {
	foreach c of numlist 1/2 {
	    local v`i'v= C1[`r', `c']
		local i= `i'+1
	}
	
}
*
local i=5
foreach r of numlist 1/2 {
	foreach c of numlist 1/2 {
	    local v`i'v= C0[`r', `c']
		local i= `i'+1
	}
	
}
*
mhmethod `v1v' `v2v' `v3v' `v4v' `v5v' `v6v' `v7v' `v8v'
local mhrr=r(mhrr)
local mhor=r(mhor)
local mhrd=r(mhrd)


mat P=J(2,2,.)
mat colnames P= "Exposed" "Unexposed" 
mat rownames P= "Case" "Noncase" 
foreach r of numlist 1/2 {
foreach c of numlist 1/2 {
mat P[`r',`c']=C1[`r',`c']/O[`r',`c']
}
}
*


mat R=J(3,4,.)
mat R[1,1]=`rrr'
mat R[2,1]=`orr'
mat R[3,1]=`rdd'
mat R[1,2]=`rrr_c1'
mat R[2,2]=`orr_c1'
mat R[3,2]=`rdd_c1'
mat R[1,3]=`rrr_c0'
mat R[2,3]=`orr_c0'
mat R[3,3]=`rdd_c0'

mat R[1,4]=`mhrr'
mat R[2,4]=`mhor'
mat R[3,4]=`mhrd'
mat colname R=Crude "confounder=1" "confounder=0" "Mantel-Haenszel"
mat rowname R="Risk ratio" "Odds ratio" " Risk difference"

return matrix P=P   /*probability*/
return matrix R=R    /*rr, or, rd*/
return matrix C0=C0  /*C=0*/
return matrix C1=C1  /*C=1*/
return matrix O=O   /*observed*/

return scalar mhRD=`mhrd'
return scalar mhOR=`mhor'
return scalar mhRR=`mhrr'

return scalar RD_c0=`rdd_c0'
return scalar OR_c0=`orr_c0'
return scalar RR_c0=`rrr_c0'

return scalar RD_c1=`rdd_c1'
return scalar OR_c1=`orr_c1'
return scalar RR_c1=`rrr_c1'

return scalar cRD= `rdd'
return scalar cOR= `orr'
return scalar cRR= `rrr'


*



* /*for the whole*/
end




