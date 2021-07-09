*! v 1.0.1 Chunsen Wu 8March2019 bias analysis for selection bias
*! v 1.0.2 Chunsen Wu 19April2019 simple bias analysis for selection bias


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

**************************************************
//
**************************************************
capture program drop biasselecti
program biasselecti, rclass
version 13.1
syntax [anything] [if] [in] [, pa(real 0.90) pb(real 0.80) pc(real 0.75) pd(real 0.60) ]
marksample touse
local nnum : word count `anything'
if `nnum'!= 4 {
display as error "you should provide 4 values, which refer to a, b, c, and d in a 2x2 table"
exit
}
*
tokenize `anything'
local a=`1'
local b=`2'
local c=`3'
local d=`4'

*
if `pa'<0 | `pa'>1 {
display as error "pa indicates the selection proportion for a, which has to be between 0 and 1"
exit
}
*
if `pb'<0 | `pb'>1 {
display as error "pa indicates the selection proportion for a, which has to be between 0 and 1"
exit
}
*
if `pc'<0 | `pc'>1 {
display as error "pa indicates the selection proportion for a, which has to be between 0 and 1"
exit
}
*
if `pd'<0 | `pd'>1 {
display as error "pa indicates the selection proportion for a, which has to be between 0 and 1"
exit
}
*

mat R=J(3,3,.)

myrr `a' `b' `c' `d'
local rrr=r(rrr)
local orr=r(orr)
local rdd=r(rdd)

display as text _newline(1)"**************************************************"
display as result _newline(0)"//Observed 2x2 table"
display as text _newline(0)"**************************************************"
mat O=`1', `2' \ `3',`4'
mat colnames O= Exposed Unexposed
mat rownames O=Case Noncase
mat list O, noheader 

display _newline(1)"Conventional risk ratio = " %4.2f `rrr'
display _newline(0)"Conventional odds ratio = " %4.2f `orr'
display _newline(0)"Conventional risk difference= " %4.2f `rdd'
mat R[1,1]=`rrr'
mat R[2,1]=`orr'
mat R[3,1]=`rdd'
local DD=`1'+ `2'
local dd=`3'+`4'
display as text _newline(1)"**************************************************"
display as result _newline(0)"//Bias parameters: selection proportion 2x2 table"
display as text _newline(0)"**************************************************"
local ppa: display  `pa' %4.2f
local ppb: display %4.2f `pb'
local ppc: display %4.2f `pc'
local ppd: display %4.2f `pd'
mat B=  `ppa', `ppb' \ `ppc', `ppd'
mat colnames B= Exposed Unexposed
mat rownames B=Case Noncase
mat list B, noheader format(%4.2f)


display as text _newline(1)"**************************************************"
display as result _newline(0)"//Corrected 2x2 table"
display as text _newline(0)"**************************************************"
mat C=J(2,2,.)

foreach r of numlist 1/2 {
foreach c of numlist 1/2 {
mat C[`r',`c']=O[`r', `c']/B[`r', `c']
}
}
*
mat colnames C= Exposed Unexposed
mat rownames C=Case Noncase
mat list C, noheader format(%12.1f)

local A=C[1,1]
local B=C[1,2]
local C=C[2,1]
local D=C[2,2]
myrr `A' `B' `C' `D'
local rrr=r(rrr)
local orr=r(orr)
local rdd=r(rdd)


display _newline(1)"Corrected risk ratio = " %4.2f `rrr'
display _newline(0)"Corrected odds ratio = " %4.2f `orr'
display _newline(0)"Corrected risk difference= " %4.2f `rdd'
mat R[1,2]=`rrr'
mat R[2,2]=`orr'
mat R[3,2]=`rdd'

display as text _newline(1)"**************************************************"
display as result _newline(0)"//Missing data 2x2 table"
display as text _newline(0)"**************************************************"
mat M=J(2,2,.)
forvalue r=1/2 {
forvalue c=1/2 {
mat M[`r',`c']= C[`r', `c']- O[`r', `c']
}
}
*
mat colnames M= Exposed Unexposed
mat rownames M=Case Noncase
mat list M, noheader format(%12.1f)

local A=M[1,1]
local B=M[1,2]
local C=M[2,1]
local D=M[2,2]
myrr `A' `B' `C' `D'
local rrr=r(rrr)
local orr=r(orr)
local rdd=r(rdd)


display _newline(1)"Missing data risk ratio = " %4.2f `rrr'
display _newline(0)"Missing data odds ratio = " %4.2f `orr'
display _newline(0)"Missing data risk difference= " %4.2f `rdd'
mat R[1,3]=`rrr'
mat R[2,3]=`orr'
mat R[3,3]=`rdd'
mat rowname R="Risk ratio" "Odds ratio" "Risk difference"
mat colname R=Observed Corrected Missed
**************************************************
//
**************************************************
return scalar RD_Missed= R[3,3]
return scalar OR_Missed= R[2,3]
return scalar RR_Missed= R[1,3]

return scalar RD_Corrected= R[3,2]
return scalar OR_Corrected= R[2,2]
return scalar RR_Corrected= R[1,2]

return scalar RD_Observed= R[3,1]
return scalar OR_Observed= R[2,1]
return scalar RR_Observed= R[1,1]

return matrix R=R  /*rr, or, rd*/
return matrix M=M  /*missing data*/
return matrix B=B  /*bias parameters: selection proportions*/
return matrix C=C  /*corrected*/
return matrix O=O  /*observed*/


 /*the whold part*/
end


