*! v 1.0.0 Chunsen Wu 8march2018 generate/simulate ancestor variables for a given DAG (directed acyclic graph)
*! v 1.0.1 Chunsen Wu 3july2018 generate/simulate ancestor variables for a given DAG (directed acyclic graph)
*! v 1.0.2 Chunsen Wu 28Nov2018 generate/simulate ancestor variables for a given DAG (directed acyclic graph)
*! v 1.0.3 Chunsen Wu 10August2019 generate/simulate child variables for a given DAG (directed acyclic graph)

**************************************************
//
**************************************************

capture program drop ancestor
program ancestor, rclass
version 13.1
syntax namelist(min=1  max=15) [if] [in] [, pre1(real 0.05) pre2(real 0.05) pre3(real  0.05) pre4(real  0.05) pre5(real 0.05) pre6(real 0.05) pre7(real 0.05) pre8(real 0.05) pre9(real 0.05) pre10(real 0.05) pre11(real 0.05) pre12(real 0.05) pre13(real  0.05) pre14(real  0.05) pre15(real 0.05) popu(real 10000)]
tokenize `namelist'
marksample touse
local NN : word count `namelist'
display `NN'
qui {
d , varlist
foreach x in `r(varlist)' {
capture drop `x'
}
}
*
qui describe
if r(N)==0 {
set obs `popu'
}
*

if `NN'==1 {
forvalue i=1/1 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1'

}
*
if `NN'==2 {
forvalue i=1/2 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2'
}
*
if `NN'==3 {
forvalue i=1/3 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3'
}
*
if `NN'==4 {
forvalue i=1/4 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4'
}
*
if `NN'==5 {
forvalue i=1/5 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5'
}
*
if `NN'==6 {
forvalue i=1/6 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6'
}
*
if `NN'==7 {
forvalue i=1/7 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6' `7'
}
*
if `NN'==8 {
forvalue i=1/8 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6' `7' `8'
}
*
if `NN'==9 {
forvalue i=1/9 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6' `7' `8'  `9' 
}
*
if `NN'==10 {
forvalue i=1/10 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6'`7' `8'  `9'  `10' 
}
*
if `NN'==11 {
forvalue i=1/11 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6'`7' `8'  `9'  `10'  `11'
}
*
if `NN'==12 {
forvalue i=1/12 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6'`7' `8'  `9'  `10'   `11'  `12'
}
*
if `NN'==13 {
forvalue i=1/13 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6'`7' `8'  `9'  `10'   `11'  `12'   `13' 
}
*
if `NN'==14 {
forvalue i=1/14 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6'`7' `8'  `9'  `10'   `11'  `12'   `13'   `14' 
}
*
if `NN'==15 {
forvalue i=1/15 {
gen ``i'' =rbinomial(1, `pre`i'')
}
tab1 `1' `2' `3' `4' `5' `6'`7' `8'  `9'  `10'    `11'  `12'   `13'  `14'  `15' 
}
*


end
