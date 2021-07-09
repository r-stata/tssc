********************************************************************************
*! "cub14s", v.16, Cerulli, 10apr2020
********************************************************************************
program cub14s , eclass
version 14.1
args todo b lnf
tempvar theta1 theta2 theta3
mleval `theta1' = `b', eq(1)
mleval `theta2' = `b', eq(2)
mleval `theta3' = `b', eq(3) // new for shelter
local y "$ML_y1" // this is just for readability
local m=e(M)
tempvar p M R S D LAMBDA
* Calculate p
quietly generate double `p' = 1/(1+exp(-`theta1'))
* Calculate M
local c = exp(lnfactorial(`m'-1))
mat cmb = J(`m',1,.)
forvalues i=1/`m' {
scalar d = (exp(lnfactorial(`i'-1))*exp(lnfactorial(`m'-`i')))
mat cmb[`i',1] = `c'/d
}
qui gen double `M' = cmb[`y',1]
* Calculate R 
quietly generate double `R' = ((exp(-`theta2'))^(`y'-1))/((1+exp(-`theta2'))^(`m'-1))
* Calculate S
quietly generate double `S' = 1/`m'
* Calculate D
quietly generate double `D'=(`y'==`e(SHELTER)')  // new for shelter
* Calculate LAMBDA
quietly generate double `LAMBDA'=`theta3'  // new for shelter
local DELTA=1/(1+exp(-`LAMBDA'))
mlsum `lnf' = ln(`DELTA'*`D' + (1-`DELTA')*(`p'*(`M'*`R'-`S')+`S'))  // new for shelter
ereturn scalar M=`m'
end
********************************************************************************
