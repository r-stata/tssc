*! Endogenous-Switch & Sample Selection
*! Count, Binary & Ordinal Response Regression (based on GLLAMM)
*! Version 2.3
*! Authors: Alfonso Miranda & Sophia Rabe-Hesketh
*! Date: 02.10.2006

program define ssm, eclass
version 9.1
 if replay() {
  if "`e(cmd)'" != "ssm" {
   error 301
  }
  ssmDisplay `0'
  exit
  }
 capture noisily Estimate `0'
 exit _rc
end

program define Estimate, eclass
syntax varlist [fweight pweight] [if] [in] , Switch(string) Family(string) Link(string) [ FRom(string) /*
 */  Quadrature(integer 6) ADAPT SELection DOts noLOg noCOnstant       /*
 */ TRace EVal ROBust COMmands LL0(real 0)]

/* Parse variables*/

gettoken en_c ex_c : varlist, parse("")
gettoken en_d junk:switch, parse ("=") match(parent)
local ex_d : subinstr local junk "=" " "
local junk "`varlist' `en_d' `ex_d'"
if "`selection'" == "" {
 local mname "switch"
}
else {
 local mname "selection"
}
local flag = 0
if "`commands'" != ""{
 local flag = 1
}

/* mark sample */

tempvar touse
mark `touse' `if' `in' [`weight'`exp']
if "`selection'" == "" {
 markout `touse' `en_c'
}

/* Deal with link and family */

lnkfm "`link'" "`family'"
local link1 = "$S_1"
local fami1 = "$S_2"

/* sort out constant */

if "`constant'" == "" {
 local numc = 1
}
else {
 local numc = 0
}
if "`link1'" == "ologit" | "`link1'" == "oprobit" {
 qui tab `en_c'
 local numc = r(r)-1
 local nocons
 local numex : word count `ex_c'
}
else {
 local nocons nocons
}

/* COLLAPSING DATA SET */

preserve
if `flag' == 1 {
 di ""
 noi di "*-------------------------------begin do-file-----------------------------------"
 di ""
}
if `flag'==1  {
 di "* Select sample"
 di ""
 di "mark touse `if' `in' [`weight'`exp']"
 if "`selection'" == "" {
  di "markout touse `en_c'"
 }
 di ""
}

tempvar wt2 wgt
if "`weight'" != "" {
 qui gen long `wgt' `exp'
}
else {
  qui gen long `wgt' = 1
}
if `flag' == 1 {
 if "`weight'" != "" {
  di "gen long wgt `exp'"
 }
}
qui gen one=1
qui collapse (sum) wt2=one, by(`junk' `wgt' `touse')
qui gen id=_n

/* Deal with weights */

local glweight
local cmglwei
if "`weight'" == "fweight" | "`weight'"==""{
 if `flag' == 1 {
  di "* deal with frequency weights"
  di ""
  di "gen one=1"
  if "`weight'" == "" {
   di "collapse (sum) wt2=one, by(`junk' touse)"
   di "gen id=_n"
  }
  else {
   di "collapse (sum) wt2=one, by(`junk' wgt touse)"
   di "gen id=_n"
   di "replace wt2 = wt2*wgt"
  }
  qui replace wt2 = wt2*`wgt'
 }
}
else if "`weight'" == "pweight" {
 if `flag' == 1 {
  di "* deal with probability weights"
  di ""
  di "gen _pwt2 = wgt"
  local cmglwei "pweight(_pwt2)"
 }
 qui gen double _pwt2 = `wgt'
 local glweight "pweight(_pwt)"
}
local glweight "`glweight' weightf(wt)"
local cmglwei "`cmglwei' weightf(wt)"

local wei
if "`weight'" != "" {
 local wei "=`wgt'"
}
qui su wt2 if `touse'
local N = r(sum)

if "`weight'" == "pweight" {
 keep id `junk' `touse' `wgt' wt2 _pwt2
}
else {
 keep id `junk' `touse' `wgt' wt2
}
if `flag' == 1 {
 if "`weight'" == "pweight" {
  di "#delimit ;"
  di "keep id `junk' wt2 _pwt2 touse;"
  di "#delimit cr"
 }
 else {
 di "#delimit ;"
 di "keep id `junk' wt2 touse;"
 di "#delimit cr"
 }
}

/* Expand data */

gen vartype1=1
gen vartype2=2
qui reshape long vartype, i(id)
gen cv=cond(vartype==1,1,0)
gen end=cond(vartype==2,1,0)
gen cons_c=cv
gen cons_d=end
gen cons=1
if `flag' == 1 {
 di ""
 di "* Expand data"
 di ""
 di "gen vartype1=1"
 di "gen vartype2=2"
 di "reshape long vartype, i(id)"
 di "gen cv=cond(vartype==1,1,0)"
 di "gen end=cond(vartype==2,1,0)"
 di "gen cons_c=cv"
 di "gen cons_d=end"
 di "gen cons=1"
}

/* New variables */

if `flag' == 1 {
 di ""
 di "* create new variables"
 di ""
}
local exogv_c
tokenize `ex_c'
while "`1'"!="" {
 qui gen `1'_c=`1'
 if `flag' == 1 {
  di "gen" " " "`1'""_c=""`1'"
 }
 local exogv_c "`exogv_c' `1'_c"
 mac shift
}

gen id_c=id
local exogv_d
tokenize `ex_d'
while "`1'"!="" {
 qui gen `1'_d=`1'
 if `flag' == 1 {
  di "gen" " " "`1'""_d=""`1'"
 }
 local exogv_d "`exogv_d' `1'_d"
 mac shift
}

/* Replace zeros where needed */

if `flag' == 1 {
 di ""
 di "* Replace zeros where needed"
 di ""
}
tokenize `exogv_c'
while "`1'"!="" {
 if "`1'"!="cons_c" {
  qui replace `1'=0 if cv==0
  if `flag' == 1 {
   di "replace `1' =0 if cv==0"
  }
 }
 mac shift
}
tokenize `exogv_d'
while "`1'"!="" {
 if "`1'"!="cons_d" {
  qui replace `1'=0 if end==0
  if `flag' == 1 {
   di "replace `1' =0 if end==0"
  }
 }
 mac shift
}

/* Response */

qui gen resp=`en_c'
qui replace resp=`en_d' if end==1
markout `touse' resp `exogv_c' `exogv_d' `wgt'

if "`link1'" == "log" | "`link1'" == "probit" | "`link1'" == "logit" {
 if `numc' == 1 {
  local exogv_c "`exogv_c' cons_c"
 }
}
local exogv_d "`exogv_d' cons_d"
if `flag' == 1 {
 di ""
 di "* Response"
 di ""
 di "gen resp=""`en_c'"
 di "replace resp=""`en_d'" " " "if end==1"
}
if `flag' == 1 {
 di ""
 di "* Select relevant sample"
 di ""
 if "`weight'" == "" {
  di "#delimit ;"
  di "markout touse resp `exogv_c' `exogv_d';"
  di "keep if touse;"
  di "#delimit cr"
 }
 else {
  di "#delimit ;"
  di "markout touse resp `exogv_c' `exogv_d' wgt;"
  di "keep if touse;"
  di "#delimit cr"
 }
}

/* Sort */

sort vartype cv id


/* initial values */

tempname ll_0
local nc: word count `exogv_c'
local nd: word count `exogv_d'
if "`from'" != "" {
 scalar `ll_0' = .
 if "`fami1'" == "poiss" & "`link1'" == "log" {
  iniscaleP `from' `nc' `nd' id
 }
 if "`fami1'" == "binom" {
  if "`link1'" == "ologit" {
   iniscaleOP `from' `nc' `nd' id `numc' OL
  }
  if "`link1'" == "oprobit" {
   iniscaleOP `from' `nc' `nd' id `numc' OP
  }
  if "`link1'" == "probit" {
   iniscalePr `from' `nc' `nd' id probit
  }
  if "`link1'" == "logit" {
   iniscalePr `from' `nc' `nd' id logit
  }
 }
 local from "from(`from')"
 local copy copy
}
else {
 tempname mat init mat_c mat_c1 mat_c2  mat_d mat_aux
 qui probit `en_d' `exogv_d' [`weight'`wei'] if end & `touse', nocons
 mat `mat_d' = e(b)
 scalar `ll_0' = e(ll)
 xcolnames `mat_d', head(resp)
 if "`fami1'" == "poiss" {
  qui poisson `en_c' `exogv_c' [`weight'`wei'] if cv & `touse', nocons
  mat `mat_c' = e(b)
  scalar `ll_0' = `ll_0' + e(ll)
  xcolnames `mat_c', head(resp)
  mat `init' = (`mat_c',`mat_d')
 }
 if "`link1'" == "probit" | "`link1'" == "logit" {
  if "`link1'" == "probit" {
   qui probit `en_c' `exogv_c' [`weight'`wei'] if cv & `touse', nocons
  }
  else {
   qui logit `en_c' `exogv_c' [`weight'`wei'] if cv & `touse', nocons
  }
  mat `mat_c' = e(b)
  scalar `ll_0' = `ll_0' + e(ll)
  xcolnames `mat_c', head(resp)
  mat `init' = (`mat_c',`mat_d')
 }
 if "`link1'" == "oprobit" | "`link1'" == "ologit" {
  if "`link1'" == "oprobit" {
   qui oprobit `en_c' `exogv_c' [`weight'`wei'] if cv & `touse'
  }
  else {
   qui ologit `en_c' `exogv_c' [`weight'`wei'] if cv & `touse'
  }
  mat `mat_c' = e(b)
  scalar `ll_0' = `ll_0' + e(ll)
  mat `mat_c1' = `mat_c'[1,1..`numex']
  xcolnames `mat_c1', head(resp)
  mat `mat_c2' = `mat_c'[1,(`numex'+1)..(`numex'+`numc')]
  local names
  forval i=1/`numc' {
   local names "`names' _cut1`i':_cons"
  }
  mat colnames `mat_c2' = `names'
  mat `init' = (`mat_c1',`mat_d',`mat_c2')
 }
 mat `mat_aux' = (.5,.5)
 mat colnames `mat_aux' = id1_1l:cv id1_1:end
 mat `init' = (`init',`mat_aux')
 local from "from(`init')"
}
if `flag' == 1 {
 di ""
 di "* Initial values"
 di ""
 local nnc = colsof(`init')
 local nncm1=`nnc' - 1
 di "#delimit ;"
 local matexp "matrix startv = ("
 forvalues is=1/`nncm1' {
  local junk = string(`init'[1,`is'],"%9.4g")
  local matexp "`matexp' `junk',"
 }
 local junk = string(`init'[1,`nnc'],"%9.4g")
 local matexp "`matexp' `junk');"
 di "`matexp'"
 di "#delimit cr"
 local from "from(startv)"
 local copy copy
}

/* ESTIMATION */

if `flag' == 1 {
 di ""
 di "* Estimation"
 di ""
 if "`fami1'" == "poiss" {
  di "eq fac: cv end"
 }
 else {
 di "eq fac: end cv"
 }
}
if "`fami1'" == "poiss" {
 eq fac: cv end
}
else {
 eq fac: end cv
}

if "`link1'" == "oprobit" | "`link1'" == "ologit" | "`link1'" == "probit" | "`link1'" == "logit" {
 constraint def 1 [id1_1]end=1
 local const "constr(1)"
 if `flag' == 1 {
  di "constraint def 1 [id1_1]end=1"
 }
}
else {
 local const ""
}
local nodis
if "`trace'" == "" {
 local nodis nodisplay
}
if "`trace'" != "" & `flag' != 1 {
 di _skip(6)
 di in gre "Calling gllamm"
 di " "
}
if `flag' == 1 {
 di ""
 di in w "* call gllamm:"
 di "#delimit ;"
 di "gllamm resp `exogv_c' `exogv_d', i(id) `cmglwei'"
 di "`const' `from' long family(`fami1' binom) nr(1)"
 di "link(`link1' probit) fv(vartype) lv(vartype) `nocons'"
 di "eq(fac) `adapt' nip(`quadrature') `trace' `dots' `log' `eval' `robust' `copy';"
 di "#delimit cr"
 di ""
 di "*------------------------------end do-file------------------------------------------"
 exit 0
 restore
}
#delimit ;
gllamm resp `exogv_c' `exogv_d' if `touse', i(id) `glweight' `const' `from' long
 family(`fami1' binom) nr(1) link(`link1' probit) fv(vartype) lv(vartype) `nocons'
 eq(fac) `adapt' nip(`quadrature') `trace' `dots' `nodis' `log' `eval' `robust' copy;
#delimit cr

/* POST-ESTIMATION ISSUES */

/* Re-scale Coefficients */

tempname b1 V
mat `b1' = e(b)
mat `V' = e(V)
if "`fami1'" == "poiss" & "`link1'" == "log" {
  scaleP `b1' `V' `nc' `nd' id
}
if "`fami1'" == "binom" {
 if "`link1'" == "ologit" {
  scaleOP `b1' `V' `nc' `nd' id `numc' OL
 }
 if "`link1'" == "oprobit" {
  scaleOP `b1' `V' `nc' `nd' id `numc' OP
 }
 if "`link1'" == "probit" {
  scalePr `b1' `V' `nc' `nd' id probit
 }
 if "`link1'" == "logit" {
  scalePr `b1' `V' `nc' `nd' id logit
 }
}

/* New Names */

tempname m1 m2 m3 m4 mC b
mat `m1'=`b1'[1,1..(`nc')]
local m1names ""
tokenize `ex_c'
while "`1'"!="" {
 local m1names "`m1names' `en_c':`1'"
 mac shift
}
if "`fami1'" == "poiss" | "`link1'"=="probit" | "`link1'"=="logit" {
 if `numc' == 1 {
  local m1names "`m1names' `en_c':_cons"
 }
}
mat colnames `m1'=`m1names'
mat `m2'=`b1'[1,(`nc'+1)..(`nc'+`nd')]
local m2names ""
tokenize `ex_d'
while "`1'"!="" {
 local m2names "`m2names' `mname':`1'"
 mac shift
}
local m2names "`m2names' `mname':_cons"
mat colnames `m2' = `m2names'
if "`fami1'" == "poiss" | "`link1'"=="probit" | "`link1'"=="logit" {
 mat `m3'=`b1'[1,(`nc'+`nd'+1)]
 mat colnames `m3' = load:_cons
 mat `m4'=`b1'[1,(`nc'+`nd'+2)]
 mat colnames `m4'= sigma:_cons
 mat `b'=(`m1',`m2',`m3',`m4')
 local newname : colfullnames(`b')
 mat rownames `V' = `newname'
 mat colnames `V' = `newname'
}
if "`link1'" == "oprobit" | "`link1'" == "ologit" {
 mat `mC' = `b1'[1,(`nc'+`nd'+1)..(`nc'+`nd'+`numc')]
 local auxeq ""
 forval i=1/`numc' {
  local auxeq "`auxeq' aux_`en_c':_cut`i'"
 }
  mat colnames `mC' = `auxeq'
 mat `m3'=`b1'[1,(`nc'+`nd'+`numc'+1)]
 mat colnames `m3' = load:_cons
 mat `m4'=`b1'[1,(`nc'+`nd'+`numc'+2)]
 mat colnames `m4'= sigma:_cons
 mat `b'=(`m1',`m2',`mC',`m3',`m4')
 local newname : colfullnames(`b')
 mat rownames `V' = `newname'
 mat colnames `V' = `newname'
}

/* Wald test */

if "`link1'" == "oprobit" | "`link1'" == "ologit" {
 local tot = `nc'+`nd'+`numc'+2
}
else {
 local tot = `nc' + `nd' + 2
 if `numc' == 1 {
  local nc = `nc' - 1
 }
}
tempname R q chi2
matrix `R'=J(`tot',`tot',0)
matrix `q'=J(`tot',1,0)
local i=1
while `i'<=(`nc'){
 matrix `R'[`i',`i']=1
 local i = `i'+1
}
if "`fami1'" == "poiss" | "`link1'"=="probit" | "`link1'"=="logit" {
 if `numc' == 1 {
  local i = `i' + 1
  local nc = `nc' + 1
 }
}
while `i'<=(`nc'+`nd'-1) {
 matrix `R'[`i',`i']=1
 local i =`i' +1
}
matrix `chi2'=(`R'*`b''-`q')'*syminv(`R'*`V'*`R'')*(`R'*`b''-`q')
if "`fami1'" == "poiss" | "`link1'"=="probit" | "`link1'"=="logit" {
 if `numc' == 0 {
  local chi2_df = `nc'+`nd' - 1
 }
 else {
  local chi2_df = `nc'+`nd' - 2
 }
}
else {
 local chi2_df = `nc' + `nd'-1
}
local chi2 = `chi2'[1,1]
local pchi=chiprob(`chi2_df',`chi2')

/* Post new estimates */

local ell=e(ll)
local ek =e(k)
local ekeq=e(k_eq)
local en=e(N)
ereturn post `b' `V', esample(`touse')
ereturn local cmd "ssm"
ereturn local id "`id'"
ereturn local edummy "`en_d'"
ereturn local quad "`quadrature'"
ereturn local adapt "`adapt'"
ereturn local robust "`robust'"
ereturn local depvar "`en_c'"
ereturn local exogv "`ex_c'"
ereturn local ed_ex "`ex_d'"
ereturn local mname "`mname'"
ereturn local family "`fami1'"
ereturn local link "`link1'"
ereturn local var_u=_b[sigma:_cons]^2
ereturn local load=_b[load:_cons]
ereturn local opt "ml"
ereturn local user "gllam_ll"
ereturn local chi2type "Wald"
ereturn scalar ll=`ell'
ereturn scalar ll_0 = `ll_0'
ereturn scalar k = `ek'
ereturn scalar k_eq=`ekeq'
ereturn scalar N=`N'
ereturn scalar chi2=`chi2'
ereturn scalar chi2_df=`chi2_df'
ereturn scalar pchi=`pchi'
restore

/* Display */

ssmDisplay

end

program define lnkfm
 version 6.0
 args link fam

 global S_1  /* link     */
 global S_2  /* family   */

 lnk "`1'"
 fm "`2'"

 if "$S_1" == "" {
  if "$S_2" == "poiss" { global S_1 "log"   }
  if "$S_2" == "binom" { global S_1 "logit" }
 }
 if "$S_2" == "poiss" {
  if ("$S_1" == "oprobit" | "$S_1" == "ologit" | "$S_2" == "probit" | "$S_2" == "logit") {
   di in red " poisson family cannot be combined with probit/logit/oprobit/ologit link"
   exit 198
  }
end

program define fm
 version 6.0
 args fam
 local f = lower(trim("`fam'"))
 local l = length("`f'")
 if "`f'" == substr("poisson",1,max(`l',3)) { global S_2 "poiss" }
  else if "`f'" == substr("binomial",1,max(`l',3)) { global S_2 "binom" }
  else if "`f'" != "" {
  noi di in red "family() `fam' is unknown or not allowed"
  exit 198
 }
 if "$S_1" == "log" {
  global S_2 "poiss"
 }
 if "$S_2" == "" {
  global S_2 "binom"
 }
end

program define lnk
version 6.0
args link
local f = lower(trim("`link'"))
local l = length("`f'")
if "`f'" == substr("log",1,max(`l',3))      { global S_1 "log"   }
 else if "`f'" == substr("probit",1,max(`l',3)) { global S_1 "probit" }
 else if "`f'" == substr("logit",1,max(`l',3)) {global S_1 "logit" }
 else if "`f'" == substr("ologit",1,max(`l',3))    { global S_1 "ologit" }
 else if "`f'" == substr("oprobit",1,max(`l',3))    { global S_1 "oprobit" }
 else if "`f'" != "" {
 noi di in red "link() `link' is unknown or not allowed"
 exit 198
}
end

program define xcolnames
version 7
tokenize "`0'", parse(,)
local com `1'
local head `3'
tokenize "`com'"
tokenize "`head'", parse("()")
local eqhead `3'
mat h = `com'
local names : colnames(h)
local i : word count `names'
local j = 1
while `j' <= `i' {
 gettoken v`j' names : names
 local v`j' `eqhead':`v`j''
 local j = `j'+1
}
local j = 2
local names2 `v1'
while `j' <= `i' {
 local names2 "`names2' `v`j''"
 local j = `j' +1
}
mat colnames `com' = `names2'
mat drop h
end

program define scaleP
version 7
tokenize "`0'"
tempname eb eV G g V load s2
matrix `eb'= `1'
matrix `eV'= `2'
local nc1 = `3'
local nd1 = `4'
local nt1 = `nc1' + `nd1' + 2
local id "`5'"
scalar `load' = _b[id1_1l:end]
scalar `s2' = _b[id1_1:cv]
/*transformation matrix */
matrix `G'=J(`nt1',`nt1',0)
local i=1
while `i'<=(`nc1'){
 matrix `G'[`i',`i']=1
 local i = `i'+1
}
while `i'<=(`nc1'+`nd1') {
 matrix `G'[`i',`i']=1/sqrt(1+`load'^2*`s2'^2)
 local i =`i' +1
}
while `i'<=(`nc1'+`nd1'+2) {
 matrix `G'[`i',`i']=1
 local i = `i' + 1
}
/*Derivative of the transformation */
matrix `g'=`G'
local i = 1
local j = `nt1' - 1
while `i'<=(`nc1'){
 local i = `i'+1
}
while `i'<=(`nc1'+`nd1') {
 matrix `g'[`i',`j']=-(`eb'[1,`i']*`load'*`s2'^2)/(1+`load'^2*`s2'^2)^(3/2)
 matrix `g'[`i',`nt1']=-(`eb'[1,`i']*`load'^2*`s2')/sqrt(1+`load'^2*`s2'^2)^(3/2)
 local i =`i' +1
}
/*Use Delta method*/
mat `1'=(`G'*`eb'')'
mat `2'=`g'*`eV'*`g''
end

program define iniscaleP
version 7
tokenize "`0'"
tempname ib iG rr load s2
matrix `ib'= `1'
local nc1 = `2'
local nd1 = `3'
local id "`4'"
mat `rr' = `ib'[1,`nc1'+`nd1'+1]
scalar `load' = `rr'[1,1]
mat `rr' = `ib'[1,`nc1'+`nd1'+2]
scalar `s2' = (`rr'[1,1])^2
matrix `iG'=J(`nc1'+`nd1'+2,`nc1'+`nd1'+2,0)
local i=1
while `i'<=(`nc1'){
 matrix `iG'[`i',`i']=1
 local i = `i'+1
}
while `i'<=(`nc1'+`nd1') {
 matrix `iG'[`i',`i']=sqrt(1+`s2'^2*`load'^2)
 local i =`i' +1
}
while `i'<=(`nc1'+`nd1'+2) {
 matrix `iG'[`i',`i']=1
 local i = `i' + 1
}
mat `1'=(`iG'*`ib'')'   /* `eb'' is a column vector and `G' a transformation matrix */
end

program define scaleOP
version 7
tokenize "`0'"
tempname eb eV G g V load
matrix `eb'= `1'
matrix `eV'= `2'
local nc1 = `3'
local nd1 = `4'
local id "`5'"
local numc = `6'
local model "`7'"
local nt1 = `nc1'+`nd1'+`numc'+2
scalar `load' = _b[id1_1l:cv]
/* Transformation matrix */
matrix `G'=J(`nt1',`nt1',0)
local i=1
if "`model'" == "OL" {
 while `i'<=`nc1'{
  matrix `G'[`i',`i']= (sqrt(_pi^2)/3)/sqrt(((_pi^2)/3)+`load'^2)
  local i = `i'+1
 }
}
else {
 while `i'<=`nc1'{
  matrix `G'[`i',`i']=1/sqrt(1+`load'^2)
  local i = `i'+1
 }
}
while `i'<=(`nc1'+`nd1') {
 matrix `G'[`i',`i']=1/sqrt(2)
 local i =`i' +1
}
if "`model'" == "OL" {
 while `i'<=(`nc1'+`nd1'+`numc') {
  matrix `G'[`i',`i']= (sqrt(_pi^2)/3)/sqrt(((_pi^2)/3)+`load'^2)
  local i = `i' + 1
 }
}
else {
 while `i'<=(`nc1'+`nd1'+`numc') {
  matrix `G'[`i',`i']=1/sqrt(1+`load'^2)
  local i = `i' + 1
 }
}
matrix `G'[(`nc1'+`nd1'+`numc'+1),(`nc1'+`nd1'+`numc'+1)]=1
matrix `G'[(`nc1'+`nd1'+`numc'+2),(`nc1'+`nd1'+`numc'+2)]=1
/*Derivative of the transformation */
matrix `g'=`G'
local i = 1
local j = `nt1'-1
if "`model'" == "OL" {
 while `i'<=(`nc1') {
  matrix `g'[`i',`j']=-((sqrt(_pi^2)/3)*`eb'[1,`i']*`load')/(((_pi^2)/3)+`load'^2)^(3/2)
  local i = `i' + 1
 }
 local i = `nc1'+`nd1'+1
 while `i'<=(`nc1'+`nd1'+`numc') {
  matrix `g'[`i',`j']=-((sqrt(_pi^2)/3)*`eb'[1,`i']*`load')/(((_pi^2)/3)+`load'^2)^(3/2)
  local i = `i' + 1
 }
}
else {
 while `i'<=(`nc1') {
  matrix `g'[`i',`j']=-(`eb'[1,`i']*`load')/(1+`load'^2)^(3/2)
  local i = `i' + 1
 }
 local i = `nc1'+`nd1'+1
 while `i'<=(`nc1'+`nd1'+`numc') {
  matrix `g'[`i',`j']=-(`eb'[1,`i']*`load')/(1+`load'^2)^(3/2)
  local i = `i' + 1
 }
}
/*Use Delta method*/
mat `1'=(`G'*`eb'')'
mat `2'=`g'*`eV'*`g''
end

program define iniscaleOP
version 7
tokenize "`0'"
tempname ib iG rr load
matrix `ib'= `1'
local nc1 = `2'
local nd1 = `3'
local id "`4'"
local numc = `5'
local model "`6'"
local nt1 = `nc1' + `nd1' + `numc' + 2
matrix `iG'=J(`nt1',`nt1',0)
mat `rr' = `ib'[1,`nc1'+`nd1'+`numc'+1]
scalar `load' = `rr'[1,1]
local i=1
if "`model'" == "OL" {
 while `i'<=`nc1'{
  matrix `iG'[`i',`i']= sqrt((_pi^2/3)+`load'^2)/(sqrt(_pi^2)/3)
  local i = `i'+1
 }
}
else {
 while `i'<=`nc1'{
  matrix `iG'[`i',`i']=sqrt(1+`load'^2)
  local i = `i'+1
 }
}
while `i'<=(`nc1'+`nd1') {
 matrix `iG'[`i',`i']=sqrt(2)
 local i =`i' +1
}
if "`model'" == "OL" {
 while `i'<=(`nc1'+`nd1'+`numc') {
  matrix `iG'[`i',`i']= sqrt((_pi^2/3)+`load'^2)/(sqrt(_pi^2)/3)
  local i = `i' + 1
 }
}
else {
 while `i'<=(`nc1'+`nd1'+`numc') {
  matrix `iG'[`i',`i']=sqrt(1+`load'^2)
  local i = `i' + 1
 }
}
matrix `iG'[(`nc1'+`nd1'+`numc'+1),(`nc1'+`nd1'+`numc'+1)]=1
matrix `iG'[(`nc1'+`nd1'+`numc'+2),(`nc1'+`nd1'+`numc'+2)]=1
mat `1'=(`iG'*`ib'')'     /* `eb'' is a column vector and `G' a transformation matrix */
end

program define scalePr
version 7
tokenize "`0'"
tempname eb eV G g V load
matrix `eb'= `1'
matrix `eV'= `2'
local nc1 = `3'
local nd1 = `4'
local id "`5'"
local model "`6'"
local nt1 = `nc1' + `nd1' + 2
scalar `load' = _b[id1_1l:cv]
matrix `G'=J(`nt1',`nt1',0)
/* Transformation matrix */
local i=1
if "`model'" == "logit" {
 while `i'<=`nc1'{
  matrix `G'[`i',`i']= (sqrt(_pi^2)/3)/sqrt(((_pi^2)/3)+`load'^2)
  local i = `i'+1
 }
}
else {
 while `i'<=`nc1'{
  matrix `G'[`i',`i']=1/sqrt(1+`load'^2)
  local i = `i'+1
 }
}
while `i'<=(`nc1'+`nd1') {
 matrix `G'[`i',`i']=1/sqrt(2)
 local i = `i' + 1
}
matrix `G'[(`nc1'+`nd1'+1),(`nc1'+`nd1'+1)]=1
matrix `G'[(`nc1'+`nd1'+2),(`nc1'+`nd1'+2)]=1
/*Derivative of the transformation */
matrix `g'=`G'
local i = 1
local j = `nt1' - 1
if "`model'" == "OL" {
 while `i'<=(`nc1') {
  matrix `g'[`i',`j']=-((sqrt(_pi^2)/3)*`eb'[1,`i']*`load')/(((_pi^2)/3)+`load'^2)^(3/2)
  local i = `i'+1
 }
}
else {
 while `i'<=(`nc1') {
  matrix `g'[`i',`j']=-(`eb'[1,`i']*`load')/(1+`load'^2)^(3/2)
  local i = `i'+1
 }
}
/*Use Delta method*/
mat `1'=(`G'*`eb'')'
mat `2'=`g'*`eV'*`g''
end

program define iniscalePr
version 7
tokenize "`0'"
tempname ib iG rr load
matrix `ib'= `1'
local nc1 = `2'
local nd1 = `3'
local id "`4'"
local model "`5'"
local tot = `nc1'+`nd1'+2
matrix `iG'=J(`tot',`tot',0)
mat `rr' = `ib'[1,`nc1'+`nd1'+1]
scalar `load' = `rr'[1,1]
local tot = `nc1'+`nd1'+2
matrix `iG'=J(`tot',`tot',0)
local i=1
if "`model'" == "logit" {
 while `i'<=`nc1'{
  matrix `iG'[`i',`i']= sqrt(((_pi^2)/3)+`load'^2)/(sqrt(_pi^2)/3)
  local i = `i'+1
 }
}
else {
 while `i'<=`nc1'{
  matrix `iG'[`i',`i']=sqrt(1+`load'^2)
  local i = `i'+1
 }
}
while `i'<=(`nc1'+`nd1') {
 matrix `iG'[`i',`i']=sqrt(2)
 local i = `i' + 1
}
matrix `iG'[(`nc1'+`nd1'+1),(`nc1'+`nd1'+1)]=1
matrix `iG'[(`nc1'+`nd1'+2),(`nc1'+`nd1'+2)]=1
mat `1'=(`iG'*`ib'')'     /* `eb'' is a column vector and `G' a transformation matrix */
end

program define ssmDisplay
di _skip(12)
if "`e(family)'" == "poiss" {
 if "`e(mname)'" == "selection" {
  di _n as text /*
  */ "Sample Selection Poisson Regression"
 }
 else {
  di _n as text /*
  */ "Endogenous Switch Poisson Regression"
 }
}
if "`e(family)'" == "binom" & "`e(link)'" == "oprobit" {
 if "`e(mname)'" == "selection" {
  di _n as text /*
  */ "Sample Selection Ordered Probit Regression"
 }
 else {
  di _n as text /*
  */ "Endogenous Switch Ordered Probit Regression"
 }
}
if "`e(family)'" == "binom" & "`e(link)'" == "ologit" {
 if "`e(mname)'" == "selection" {
  di _n as text /*
  */ "Sample Selection Ordered Logit Regression"
 }
 else {
  di _n as text /*
  */ "Endogenous Switch Ordered Logit Regression"
 }
}
if "`e(family)'" == "binom" & "`e(link)'" == "probit" {
 if "`e(mname)'" == "selection" {
  di _n as text /*
  */ "Sample Selection Probit Regression"
 }
 else {
  di _n as text /*
  */ "Endogenous Switch Probit Regression"
 }
}
if "`e(family)'" == "binom" & "`e(link)'" == "logit" {
 if "`e(mname)'" == "selection" {
  di _n as text /*
  */ "Sample Selection Logit Regression"
 }
 else {
  di _n as text /*
  */ "Endogenous Switch Logit Regression"
 }
}
if "`e(adapt)'"=="" {
 di as text "(`e(quad)' quadrature points)"
}
else {
 di as text "(Adaptive quadrature -- `e(quad)' points)"
}
di _n in gre _col(54) "Number of obs  =" " " in ye %8.0f `e(N)'
di in gre _col(54) "Wald chi2(" in ye `e(chi2_df)' in gre ")   =" " " in ye %8.2f `e(chi2)'
di in gre "Log likelihood =" " " in ye e(ll) in gre /*
 */ _col(54) "Prob > chi2    =" " " in ye %8.4f e(pchi)
 di _skip(2)
if "`e(family)'" == "poiss" {
 ereturn di, neq(2) plus
 _diparm sigma, p label(sigma)
 local junk "sqrt(@2^2*(@1^2*@2^2+1))"
 _diparm load sigma, f((@1*@2^2)/`junk') /*
 */ d((@2*`junk'-@1^2*@2^6*`junk'^(-1))/(`junk'^2) /*
  */ (2*@1*@2*`junk'-2*@1^3*@2^5*`junk'^(-1))/(`junk'^2)) p label(rho)
}
if "`e(family)'" == "binom" {
 if "`e(link)'" == "oprobit" | "`e(link)'" == "ologit" {
  ereturn di, neq(3) plus
 }
 else {
  ereturn di, neq(2) plus
 }
 if "`e(link)'" == "oprobit" | "`e(link)'" == "probit" {
  local junk "sqrt(2*(1+@^2))"
  _diparm load, f(@/`junk') d((`junk' - 2*@^2*`junk'^(-1))/(2*(1+@^2))) p label(rho)
 }
 if "`e(link)'" == "ologit" | "`e(link)'" == "logit" {
 local junk "sqrt(2*((_pi^2/3)+@^2))"
 _diparm load, f(@/`junk') d((`junk' - 2*@^2*`junk'^(-1))/(2*(((_pi^2)/3)+@^2))) p label(rho)
 }
}
di in gre in smcl "{hline 13}{c BT}{hline 64}"
if `e(ll_0)' != . {
 tempname chi2 pval
 scalar `chi2' = -2*(e(ll_0)-e(ll))
 if `chi2' < 1e-5 {
  scalar `chi2' = 0
 }
 scalar `pval' =  chiprob(1, `chi2')
 if e(chi2)==0 {
  scalar `pval'= 1
 }
 if (`chi2' > 0.005) & (`chi2'<1e4) | (`chi2')==0 {
  local fmt "%4.2f"
 }
  di in green "Likelihood ratio test for rho=0: " /*
  */ in green "chi2("in ye 1 in gre ")= " in ye `fmt' `chi2' /*
  */ in green " Prob>=chi2 = " in ye %5.3f `pval'
}
if "`e(robust)'" != "" {
 di in green "Robust Standard Errors presented."
}
end
exit
