********************************************************************************
*! "cub14", v.16, GCerulli, 10apr2020
********************************************************************************
program cub14 , eclass
version 14.2
args todo b lnf
tempvar theta1 theta2
mleval `theta1' = `b', eq(1)
mleval `theta2' = `b', eq(2)
local y "$ML_y1" // this is just for readability
local m=e(M)
tempvar p M R S D
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
mlsum `lnf' = ln(`p'*(`M'*`R'-`S')+`S')  // new for shelter
ereturn scalar M=`m'
end
********************************************************************************
