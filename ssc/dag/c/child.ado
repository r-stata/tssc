
*! v 1.0.0 Chunsen Wu 8march2018 generate/simulate child variables for a given DAG (directed acyclic graph)
*! v 1.0.1 Chunsen Wu 3july2018 generate/simulate child variables for a given DAG (directed acyclic graph)
*! v 1.0.2 Chunsen Wu 28Nov2018 generate/simulate child variables for a given DAG (directed acyclic graph)
*! v 1.0.3 Chunsen Wu 10August2019 generate/simulate child variables for a given DAG (directed acyclic graph)

**************************************************
//
**************************************************

capture program drop child
program child, rclass
version 13.1
syntax namelist(min=2 max=21) [if] [in] [, BASErisk(real 0.05)  p1or(real 5)   p2or(real 5) p3or(real 5)  p4or(real 5)  p5or(real 5)  p6or(real 5)  p7or(real 5)  p8or(real 5)  p9or(real 5)  p10or(real 5) p11or(real 5)   p12or(real 5) p13or(real 5)  p14or(real 5)  p15or(real 5)  p16or(real 5)  p17or(real 5)  p18or(real 5)  p19or(real 5)  p20or(real 5)]
tokenize `namelist'

marksample touse

local odds0=`baserisk'/(1 - `baserisk')
tempvar myxb varpro
local NNN : word count `namelist'
local NN= `NNN'-1

if `NN'==1 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2' if `touse'
}
*

if `NN'==2 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  if `touse'
}
*

if `NN'==3 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4'  if `touse'
}
*
if `NN'==4 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5'  if `touse'
}
*
if `NN'==5 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6'  if `touse'
}
*
if `NN'==6 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7'  if `touse'
}
*
if `NN'==7 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8'  if `touse'
}
*
if `NN'==8 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'  if `touse'
}
*
if `NN'==9 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'  if `touse'
}
*
if `NN'==10 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11'  if `touse'
}
*
********** over 10
if `NN'==11 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12'  if `touse'
}
*
if `NN'==12 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12' + ln(`p12or')*`13'  if `touse'
}
*
if `NN'==13 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12' + ln(`p12or')*`13' + ln(`p13or')*`14'  if `touse'
}
*
if `NN'==14 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12' + ln(`p12or')*`13' + ln(`p13or')*`14' + ln(`p14or')*`15'  if `touse'
}
*
if `NN'==15 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12' + ln(`p12or')*`13' + ln(`p13or')*`14' + ln(`p14or')*`15' + ln(`p15or')*`16'  if `touse' 
}
*
if `NN'==16 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12' + ln(`p12or')*`13' + ln(`p13or')*`14' + ln(`p14or')*`15' + ln(`p15or')*`16' + ln(`p16or')*`17'  if `touse'
}
*
if `NN'==17 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12' + ln(`p12or')*`13' + ln(`p13or')*`14' + ln(`p14or')*`15' + ln(`p15or')*`16' + ln(`p16or')*`17'+ ln(`p17or')*`18'  if `touse'
}
*
if `NN'==18 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12' + ln(`p12or')*`13' + ln(`p13or')*`14' + ln(`p14or')*`15' + ln(`p15or')*`16' + ln(`p16or')*`17'+ ln(`p17or')*`18'+ ln(`p18or')*`19'  if `touse'
}
*
if `NN'==19 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12' + ln(`p12or')*`13' + ln(`p13or')*`14' + ln(`p14or')*`15' + ln(`p15or')*`16' + ln(`p16or')*`17'+ ln(`p17or')*`18'+ ln(`p18or')*`19'+ ln(`p19or')*`20'  if `touse'
}
*
if `NN'==20 {
gen `myxb'=ln(`odds0') + ln(`p1or')*`2'  + ln(`p2or')*`3'  + ln(`p3or')*`4' + ln(`p4or')*`5' + ln(`p5or')*`6' + ln(`p6or')*`7' + ln(`p7or')*`8' + ln(`p8or')*`9'+ ln(`p9or')*`10'+ ln(`p10or')*`11' + ln(`p11or')*`12' + ln(`p12or')*`13' + ln(`p13or')*`14' + ln(`p14or')*`15' + ln(`p15or')*`16' + ln(`p16or')*`17'+ ln(`p17or')*`18'+ ln(`p18or')*`19'+ ln(`p19or')*`20'+ ln(`p20or')*`21'  if `touse'
}
*
gen `varpro'=exp(`myxb')/(1 + exp(`myxb'))  if `touse'
capture drop `1'
generate `1'=rbinomial(1, `varpro')  if `touse'

end




