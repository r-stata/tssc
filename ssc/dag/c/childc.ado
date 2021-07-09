

*! v 1.0.0 Chunsen Wu 10August2019 generate/simulate child variables for a given DAG (directed acyclic graph)

**************************************************
//
**************************************************

capture program drop childc
program childc, rclass
version 13.1
syntax namelist(min=2 max=21) [if] [in] [, BASElevel(numlist min=2 max=2)  p1coe(real 5)   p2coe(real 5) p3coe(real 5)  p4coe(real 5)  p5coe(real 5)  p6coe(real 5)  p7coe(real 5)  p8coe(real 5)  p9coe(real 5)  p10coe(real 5) p11coe(real 5)   p12coe(real 5) p13coe(real 5)  p14coe(real 5)  p15coe(real 5)  p16coe(real 5)  p17coe(real 5)  p18coe(real 5)  p19coe(real 5)  p20coe(real 5)]
tokenize `namelist'

marksample touse

local baseNum: word count `baselevel'
local i=1
foreach x of local baselevel {
local m`i'v= `x'
local i= `i'+1
}
*
tempvar unexposedLevel
gen `unexposedLevel'=rnormal(`m1v', `m2v')
capture drop `1'
local NNN : word count `namelist'
local NN= `NNN'-1

if `NN'==1 {
gen `1'=`unexposedLevel' + `p1coe'*`2' + rnormal() if `touse'
}
*

if `NN'==2 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3' + rnormal()  if `touse'
}
*

if `NN'==3 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + rnormal()  if `touse'
}
*
if `NN'==4 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + rnormal()  if `touse'
}
*
if `NN'==5 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + rnormal()  if `touse'
}
*
if `NN'==6 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + rnormal()  if `touse'
}
*
if `NN'==7 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + rnormal()  if `touse'
}
*
if `NN'==8 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9' + rnormal()  if `touse'
}
*
if `NN'==9 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10' + rnormal()  if `touse'
}
*
if `NN'==10 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + rnormal()  if `touse'
}
*
********** over 10
if `NN'==11 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + rnormal()  if `touse'
}
*
if `NN'==12 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + `p12coe'*`13' + rnormal()  if `touse'
}
*
if `NN'==13 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + `p12coe'*`13' + `p13coe'*`14' + rnormal()  if `touse'
}
*
if `NN'==14 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + `p12coe'*`13' + `p13coe'*`14' + `p14coe'*`15' + rnormal()  if `touse'
}
*
if `NN'==15 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + `p12coe'*`13' + `p13coe'*`14' + `p14coe'*`15' + `p15coe'*`16' + rnormal()  if `touse' 
}
*
if `NN'==16 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + `p12coe'*`13' + `p13coe'*`14' + `p14coe'*`15' + `p15coe'*`16' + `p16coe'*`17' + rnormal()  if `touse'
}
*
if `NN'==17 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + `p12coe'*`13' + `p13coe'*`14' + `p14coe'*`15' + `p15coe'*`16' + `p16coe'*`17'+ `p17coe'*`18' + rnormal()  if `touse'
}
*
if `NN'==18 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + `p12coe'*`13' + `p13coe'*`14' + `p14coe'*`15' + `p15coe'*`16' + `p16coe'*`17'+ `p17coe'*`18'+ `p18coe'*`19' + rnormal()  if `touse'
}
*
if `NN'==19 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + `p12coe'*`13' + `p13coe'*`14' + `p14coe'*`15' + `p15coe'*`16' + `p16coe'*`17'+ `p17coe'*`18'+ `p18coe'*`19'+ `p19coe'*`20' + rnormal()  if `touse'
}
*
if `NN'==20 {
gen `1'=`unexposedLevel' + `p1coe'*`2'  + `p2coe'*`3'  + `p3coe'*`4' + `p4coe'*`5' + `p5coe'*`6' + `p6coe'*`7' + `p7coe'*`8' + `p8coe'*`9'+ `p9coe'*`10'+ `p10coe'*`11' + `p11coe'*`12' + `p12coe'*`13' + `p13coe'*`14' + `p14coe'*`15' + `p15coe'*`16' + `p16coe'*`17'+ `p17coe'*`18'+ `p18coe'*`19'+ `p19coe'*`20'+ `p20coe'*`21' + rnormal()  if `touse'
}
*




end




