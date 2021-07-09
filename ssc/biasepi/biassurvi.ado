

*! v 1.0.1 Chunsen Wu 19April2019 simple bias analysis for survival bias

**************************************************
//
**************************************************
capture program drop biassurvi
program biassurvi, rclass
version 13.1
syntax [anything] [if] [in] [, lostp1(real 50) lostp0(real 50) aver1(numlist max=1) aver0(numlist max=1) rate1(numlist max=1) rate0(numlist max=1) avet1(numlist max=1) avet0(numlist max=1) ftime1(numlist max=1) ftime0(numlist max=1) case1(numlist max=1) case0(numlist max=1)]
marksample touse
local nnum : word count `anything'
if `nnum'!= 6 {
display as error "you should provide 6 values, which refer to persons, person-time, persons, person-time"
exit
}
*
local aver1num: word count `aver1'
local aver0num: word count `aver0'
local rate1num: word count `rate1'
local rate0num: word count `rate0'
local avet1num: word count `avet1'
local avet0num: word count `avet0'
local ftime1num: word count `ftime1'
local ftime0num: word count `ftime0'

if `aver1num'==1 & `rate1num'==1 {
"Only one is allowed, either aver1 or rate1"
exit
}
*
if `aver0num'==1 & `rate0num'==1 {
"Only one is allowed, either aver0 or rate0"
exit
}
*
if `aver1num'==0 & `rate1'==0 {
"At least one (either aver1 or rate1) has to be specified"
exit
}
*
if `aver0num'==0 & `rate0'==0 {
"At least one (either aver0 or rate0) has to be specified"
exit
}
*
if `avet1num'==1 & `ftime1num'==1 {
"Only one is allowed, either ave1 or ftime1"
exit
}
*
if `avet0num'==1 & `ftime0num'==1 {
"Only one is allowed, either avet0 or ftime0"
exit
}
*
if `avet1num'==0 & `ftime1num'==0 {
"At least one (either avet0 or ftime0) has to be specified"
exit
}
*
if `avet0num'==0 & `ftime0num'==0 {
"At least one (either avet0 or ftime0) has to be specified"
exit
}
*
if `avet1num'==1 {
if `avet1'<=0  {
"avet1 can not be negative"
exit
}
}
*
if `avet0num'==1 {
if `avet0'<=0  {
"avet0 can not be negative"
exit
}
}
*
if `ftime1num'==1 {
if `ftime1'<=0  {
"ftime1 can not be negative"
exit
}
}
*
if `ftime0num'==1 {
if `ftime0'<=0 {
"ftime0 can not be negative"
exit
}
}
*
tokenize `anything'
local d1= `1'
local p1=  `2'
local t1=  `3'
local d0=  `4'
local p0= `5'
local t0= `6'


**************************************************
//follow-up time
**************************************************
local average1=`t1'/`p1'
local average0=`t0'/`p0'

if `avet1num'==1 {
local followuptime1= `average1'* `avet1' * `lostp1'
}
*
if `avet0num'==1 {
local followuptime0= `average0'* `avet0' * `lostp0'
}
*
if `ftime1num'==1 {
local followuptime1= `ftime1'
}
*
if `ftime0num'==1 {
local followuptime0= `ftime0'
}
*

**************************************************
//rate
**************************************************
if `aver1num'==1 {
local assumedRate1= (`d1'/`t1')* `aver1' 
}
*
if `aver0num'==1 {
local assumedRate0= (`d0'/`t0')* `aver0' 
}
*
if `rate1num'==1 {
local assumedRate1= `rate1'
}
*
if `rate0num'==1 {
local assumedRate0= `rate0'
}
*



**************************************************
//predicted cases
**************************************************
local case1num: word count `case1'
local case0num: word count `case0'
if `case1num'==0 {
local disease1=`assumedRate1'*`followuptime1'
}
*
if `case1num'==1 {
local disease1=`case1'
}
*
if `case0num'==0 {
local disease0=`assumedRate0'*`followuptime0'
}
*
if `case0num'==1 {
local disease0=`case0'
}
*




display as text _newline(1)"**************************************************"
display as result _newline(0)"//Observed 2x2 table"
display as text _newline(0)"**************************************************"
mat O=J(6,2,.)
mat O[1,1]=`d1'
mat O[2,1]=`p1'
mat O[3,1]=`t1'
mat O[4,1]=O[1,1]/O[3,1]

mat O[1,2]=`d0'
mat O[2,2]=`p0'
mat O[3,2]=`t0'
mat O[4,2]=O[1,2]/O[3,2]

mat O[5,1]=O[4,1] / O[4,2]  
mat O[5,2]=1

mat O[6,2]=0
mat O[6,1]=O[4,1] - O[4,2]
mat colnames O= Exposed Unexposed
mat rownames O="Case" "Persons" "Person-time" "Rate" "Rate ratio" "Rate diff"
mat list O, noheader 



display as text _newline(1)"**************************************************"
display as result _newline(0)"//Lost follow-up 2x2 table"
display as text _newline(0)"**************************************************"
mat L=J(6,2,.)
mat L[1,1]=`disease1'
mat L[2,1]=`lostp1'
mat L[3,1]=`followuptime1'
mat L[4,1]=L[1,1]/L[3,1]

mat L[1,2]=`disease0'
mat L[2,2]=`lostp0'
mat L[3,2]=`followuptime0'
mat L[4,2]=L[1,2]/L[3,2]

mat L[5,1]= L[4,1] / L[4,2] 
mat L[5,2]=1

mat L[6,2]=0
mat L[6,1]=L[4,1] - L[4,2]
mat colnames L= Exposed Unexposed
mat rownames L="Case" "Persons" "Person-time" "Rate" "Rate ratio" "Rate dif"
mat list L, noheader 

display as text _newline(1)"**************************************************"
display as result _newline(0)"//Bias parameters"
display as text _newline(0)"**************************************************"


display _newline(1)"Incidence rate among the lost-exposed population: "L[1,1]/L[3,1]
display _newline(0)"Follow-up time among the lost-exposed population: "`followuptime1'

display _newline(1)"Incidence rate among the lost-unexposed population: "L[1,2]/L[3,2]
display _newline(0)"Follow-up time among the lost-unexposed population: "`followuptime0'

display as text _newline(1)"**************************************************"
display as result _newline(0)"//Corrected 2x2 table"
display as text _newline(0)"**************************************************"
mat C=J(6,2,.)
mat C[1,1]=O[1,1] + L[1,1]
mat C[2,1]=O[2,1] + L[2,1]
mat C[3,1]=O[3,1] + L[3,1]
mat C[4,1]=C[1,1]/C[3,1]

          
mat C[1,2]=O[1,2] + L[1,2]
mat C[2,2]=O[2,2] + L[2,2]
mat C[3,2]=O[3,2] + L[3,2]
mat C[4,2]=C[1,2]/C[3,2]

mat C[5,1]=C[4,1] / C[4,2] 
mat C[5,2]=1

mat C[6,2]=0
mat C[6,1]=C[4,1] - C[4,2]
mat colnames C= Exposed Unexposed
mat rownames C="Case" "Persons" "Person-time" "Rate" "Rate ratio" "Rate diff"
mat list C, noheader 



**************************************************
//
**************************************************

return matrix L=L  /*bias parameters: selection proportions*/
return matrix C=C  /*corrected*/
return matrix O=O  /*observed*/


 /*the whold part*/

end


