*! Version 2.0
*! Author: Alfonso Miranda
*! Date: 07.05.2013

capture program drop lcmc_predict
program define lcmc_predict, eclass
version 11

/* check that correct estimates are in memory */

if (e(cmd)!="lcmc") {
 error 301
}

/* deal with syntax */

syntax [if] [in],  [HVECtor(string) rep(integer 1600) METHod(integer 1)]

/* hvector option */

pause on
tempname hvec
if "`hvector'" != "" {
  tokenize `hvector' 
  local c = 1
  while "`1'" != "" {
   if `c' > 4 {
    di in red "hvector takes 4 arguments"
    error 198
   }
  global S_hv_`c'=`1'
  local c = `c' + 1
  mac shift
 }
}
else{
 global S_hv_1=2
 global S_hv_2=1
 global S_hv_3=2
 global S_hv_4=100 
}
mat `hvec' = ($S_hv_1, $S_hv_2, $S_hv_3, $S_hv_4)

/* temporal stuff */
//ereturn local selvar "req_sel"
//ereturn local yvar "sdsc"
//pause

/* get name of dependent variables */

local sname `e(selvar)'
local yname `e(yvar)'
local mcvname `e(mcvar)'
local ncats = `e(ncuts)'+1
local exogv1 `e(exselvar)'
local exogv2 `e(exyvar)'
local exogv3 `e(exmcvar)'

/* Generate id and set-up scale */

tempvar idi
gen `idi'=_n
preserve
marksample touse

/* Expand data */

qui gen vartype1=1
qui gen vartype2=2
qui gen vartype3=3
qui reshape long vartype, i(`idi')
qui gen selvar=cond(vartype==1,1,0)
qui gen yvar=cond(vartype==2,1,0)
qui gen mcvar=cond(vartype==3,1,0)

/* Sort data */

qui sort `idi' vartype
local vartype vartype

/* Response */

qui gen resp=`sname'
qui replace resp=`yname' if yvar==1
qui replace resp=`mcvname' if mcvar==1
local resp resp

/* Select sample */

sort `idi' vartype
foreach s of local exogv1 {
 qui replace `touse' = 0 if `s'==. & vartype==1
}
foreach s of local exogv2 {
 qui replace `touse' = 0 if `s'==. & vartype==2
}
foreach s of local exogv3 {
 qui replace `touse' = 0 if `s'==. & vartype==3
}
qui replace `touse'=0 if resp==.
qui {
 by `idi': replace `touse'=0 if resp[2]==. | `touse'[2]==0
}

/* Keep relevant sample */

tempvar last
qui keep if `touse'
sort `idi' vartype
by `idi': gen `last'= (_n==_N) 
qui su resp  if `touse' & vartype==2
local Nyvar = `e(N)'

/* prepare variables for yhat and posterior probabilities */

tempname yhat
qui gen double `yhat' = .
local PH ""
forval i=1/`ncats' {
 tempvar Phat`i'
 local PH "`PH' `Phat`i''"
 qui gen double `Phat`i'' = .
}
 
/* obtain posterior probabilities */

mata: mcvopp_Pr("resp","vartype","`idi'",`Nyvar', `method',`rep',"`hvec'","`yhat'","`PH'","`touse'")
local PP ""
forval i=1/`ncats' {
 qui gen double P`i' = `Phat`i''
 local PP "`PP' P`i'"
}

/* restore original data + PP */

tempfile ppfile
qui keep if vartype==2
qui keep  `idi' `PP' `samp'
sort `idi'
qui save "`ppfile'"
restore
sort `idi'
qui merge `idi' using "`ppfile'"
drop _merge

/* calculate predicted score */

tempname one
qui gen `one' = 1
qui gen double yhat = .
qui gen double seyhat = . 
tempvar A B
qui gen double `A' = .
qui gen double `B' = .
local yhat yhat
local seyhat seyhat

mata: CVA_Pr("yhat","seyhat","`idi'","PP","`samp'", "`A'", "`B'")

end



