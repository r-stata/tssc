clear
mata : mata clear
set mem 10m
set more off

cap log close
log using confa-sj-examples

* get the data
use http://web.missouri.edu/~kolenikovs/stata/hs-cfa.dta
describe

* basic syntax
cap noi confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9)

* various starting values
confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(ones)
confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(iv)
confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(smart)
estimates store oim
matrix bb = e(b)

* Satorra-Bentler story
confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(iv) vce(sbentler) nolog
confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(bb) iter(1) vce(sbentler) nolog

* comparing standard errors
estimates store sb
confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(bb) iter(1) vce(robust) nolog
estimates store sandwich
estimates tab oim sb sandwich, se

* correlated errors
confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(bb, skip) corr( x7:x8 )

* Satorra-Bentler scaled difference test?
qui confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(bb) vce(sbentler)
local T0 = e(lr_u)
local r0 = e(df_u)
local c0 = e(SBc)
qui confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(bb, skip) vce(sbentler) corr(x7:x8)
local T1 = e(lr_u)
local r1 = e(df_u)
local c1 = e(SBc)
local DeltaT = (`T0'-`T1')*(`r0'-`r1')/(`r0'*`c0'-`r1'*`c1')
di as text "Scaled difference Delta = " as res %6.3f `DeltaT' as text "; Prob[chi2>" as res %6.3f `DeltaT' as text "] = " as res %6.4f chi2tail(`r0'-`r1',`DeltaT')

* Bollen-Stine
qui confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(bb, skip) corr(x7:x8)
* set seed 1010101
* bollenstine , reps(500) confaoptions( iter(5) corr( x7:x8 ) )
set seed 1010101
bollenstine , reps(500) confaoptions( iter(20) corr( x7:x8 ) )
est store bollst

* estat commands
qui confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(bb, skip) corr(x7:x8)
estat fit
estat corr
estat corr, bound

* factor predictions
predict fa1-fa3, reg
predict fb1-fb3, bart
corr fa1-fb3, cov
scatter fa1 fb1, aspect(1)

* alternative identification
confa (vis: x1 x2 x3) (text: x4 x5 x6) (math: x7 x8 x9), from(ones) unitvar(_all) corr(x7:x8)

* example with missing data
set seed 123456
forvalues k=1/9 {
  gen y`k' = cond( uniform()<0.0`k', ., x`k')
}

* list-wise deletion
confa (vis: y1 y2 y3) (text: y4 y5 y6) (math: y7 y8 y9), from(bb)
mat bbmis = e(b)
est store listwise

* sophisticated missing data
mat bbspec = 0.5*(bb + bbmis)
confa (vis: y1 y2 y3) (text: y4 y5 y6) (math: y7 y8 y9), from(iv) missing difficult
est store missing

* all saved results
* need Satorra-Bentler followed by Bollen-Stine with correlated errors!
est restore oim
ereturn list
est restore sb
ereturn list
est restore bollst
ereturn list

* MTMM example
use http://web.missouri.edu/~kolenikovs/stata/libdem80, clear
* base model
confa (pollib: party broad print civlb) (demrul: leg80 polrt compet effec) ///
   , vce(sbentler) from(smart) difficult usenames
estimates store traits
local T0 = e(lr_u)
local r0 = e(df_u)
local c0 = e(SBc)
mat b_t = e(b)

* methods model
confa (sussman: broad print) (gastil: civlb polrt) (banks: leg80 party compet effec) ///
  , difficult from(smart) usenames iter(20)
estimates store methods
mat b_m = e(b)

preserve
* replace the variables by their residuals
est restore traits
predict f1 f2, bartlett
foreach x of varlist party80 broad80 print80 civlb80 {
  replace `x' = `x' - [lambda_`x'_pollib]_cons*f1
}
foreach x of varlist leg80 polrt80 compet80 effec80 {
  replace `x' = `x' - [lambda_`x'_demrul]_cons*f2
}

confa (sussman: broad print) (gastil: civlb polrt) (banks: leg80 party compet effec) ///
  , difficult from(smart) usenames iter(20)
estimates store res
mat b_res = e(b)

mat bb2 = (b_t[1,1..19], b_res[1,9..30] )

restore

constr def 101 [phi_2_3]_cons = 0
constr def 102 [phi_2_4]_cons = 0
constr def 103 [phi_2_5]_cons = 0
constr def 104 [phi_1_3]_cons = 0
constr def 105 [phi_1_4]_cons = 0
constr def 106 [phi_1_5]_cons = 0

constr def 201 [phi_pollib_sussman]_cons = 0
constr def 202 [phi_pollib_gastil]_cons  = 0
constr def 203 [phi_pollib_banks]_cons   = 0
constr def 204 [phi_demrul_sussman]_cons = 0
constr def 205 [phi_demrul_gastil]_cons  = 0
constr def 206 [phi_demrul_banks]_cons   = 0

* Bollen's results
mat bb = J(1,8,0)
mat bb = (bb, 1, 0.86, 0.93, 0.72, 1, 1.08, 0.94, 0.44, 1, 1.19, 1, 0.63, 1, -0.2, 2.7, 1.94)
mat bb = (bb, 16, 12.9, 10.55, 2.59, 0, 0, 1.44, 1.48, 0, 0, 0.68, -0.35, -0.28, 0, 0)
mat bb = (bb, 2.1, 3.1, 1.6, 0.6, 1.6, 0.27, -0.42, 8.6)

confa (pollib: party broad print civlb) (demrul: leg80 polrt compet effec) ///
   (sussman: broad print) (gastil: civlb polrt) (banks: leg80 party compet effec) ///
   , constr(201 202 203 204 205 206) from(bb2) search(off) usenames iter(50)
est store full1
confa (pollib: party broad print civlb) (demrul: leg80 polrt compet effec) ///
   (sussman: broad print) (gastil: civlb polrt) (banks: leg80 party compet effec) ///
   , constr(201 202 203 204 205 206) from(bb, copy) search(off) usenames iter(50)
est store full2
local T1 = e(lr_u)
local r1 = e(df_u)
local c1 = e(SBc)
local DeltaT = (`T0'-`T1')*(`r0'-`r1')/(`r0'*`c0'-`r1'*`c1')
local df = `r0'-`r1'
di as text "Scaled difference Delta = " as res %6.3f `DeltaT' as text "; Prob[chi2({res}`df'{txt})>" as res %6.3f `DeltaT' as text "] = " as res %6.4f chi2tail(`df',`DeltaT')

log close

exit
