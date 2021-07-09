*! Endogenous Participation Endogenous Treatment Poisson model by MSL
*! Version 3.0
*! Author: Alfonso Miranda
*! Date: 06.01.2011

capture program drop petpoisson
program define petpoisson, eclass
version 11
 if replay() {
  if "`e(cmd)'" != "petpoisson" {
   error 301
  }
  Display `0'
  exit
  }
 capture noisily Estimate `0'
 exit _rc
end

program define Estimate, eclass

/* Parse equations*/

local i = 1
local parent "("
while "`parent'" != "" {
 gettoken e`i' 0:0, parse (" ,[") match(parent)
 if "`parent'" == "" {
  local i = `i' - 1
  continue
 }
 local left "`0'"
 local junk: subinstr local e`i' ":" ":", count(local number)
 if "`number'" == "1" {
  gettoken eqname`i' e`i':e`i', parse(":")
  gettoken junk e`i':e`i', parse(":")
 }
 local e`i': subinstr local e`i' "=" " "
 gettoken endogv`i' 0:e`i', parse(" ,[")
 unab endogv`i':`endogv`i''
 local endogvs "`endogvs' `endogv`i''"
 confirm variable `endogv`i''
 if "`eqname`i''" == "" {
  local eqname`i' "`endogv`i''"
 }
 syntax [varlist(fv default=none)] [, noCONstant]
 local exogv`i' `varlist'
 local nexogv`i' : word count `exogv`i''
 if "`constant'" == "" {
  local nexogv`i' = `nexogv`i'' + 1
 }
 local exogvs "`exogvs' `exogv`i''"
 local nc`i' `constant'
 local 0 "`left'"
 gettoken check:left, parse(" ,[") match(paren)
 local i = `i' + 1
}
if `i' > 3 {
 di in red "only three equations are allowed"
 error 198
}

/* sort out constants */

if "`nc1'" == "" {
 local ncedv = 1
}
else {
 local ncedv = 0
}
if "`nc2'" == "" {
 local ncssv = 1
}
else {
 local ncssv = 0
}
if "`nc3'" == "" {
 local ncordv = 1
}
else {
 local ncordv = 0
}


/* Remaining options */

local 0 "`left'"
syntax [if] [in], [rep(integer 50) CONSTRaints(passthru) /*
 */ METHod(integer 1) FROM(string) HVECtor(string) cluster(string) /*
*/ CONSTRaint(passthru) TRace EVALuate MLOpts ROBust HBased *]

/* hvector option */

if "`hvector'" != "" {
  tokenize `hvector' 
  local c = 1
  while "`1'" != "" {
   if `c' > 3 {
    di in red "hvector takes 3 arguments"
    error 198
   }
  global S_hv_`c'=`1'
  local c = `c' + 1
  mac shift
 }
}
else{
 global S_hv_1=1
 global S_hv_2=1
 global S_hv_3=0 
}

/* Deal with eval + HBbased + trace */

if "`evaluate'"~="" & "`from'" == "" {
 disp in red "eval option only allowed with" in gre "from()"
 exit 198
}


/* Generate id */

preserve
marksample touse
gen id=_n

/* Expand data */

qui gen vartype1=1
qui gen vartype2=2
qui gen vartype3=3
qui reshape long vartype, i(id)
qui gen edv=cond(vartype==1,1,0)
qui gen ssv=cond(vartype==2,1,0)
qui gen ordv=cond(vartype==3,1,0)

/* Sort data */

tempvar last
qui sort id vartype
qui by id: gen `last'=(_n==_N)

/* Response */

qui gen resp=`endogv1'
qui replace resp=`endogv2' if ssv==1
qui replace resp=`endogv3' if ordv==1

/* remove collinear variables  */

_rmcoll `exogv1', expand 
local exogv1 `r(varlist)'
_rmcoll `exogv2', expand 
local exogv2 `r(varlist)'
_rmcoll `exogv3', expand 
local exogv3 `r(varlist)'

/* Select sample */

tempvar nouse
qui gen nouse=1
sort id vartype
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
 by id: replace `touse'=0 if resp[1]==. | `touse'[1]==0
 by id: replace `touse'=0 if resp[2]==. | `touse'[2]==0
}

/* get list of included variables */

foreach var of local exogv1 {
 _ms_parse_parts `var'
 if !`r(omit)' {
  local exogv1_il `exogv1_il' `var'
 }	
}
foreach var of local exogv2 {
 _ms_parse_parts `var'
 if !`r(omit)' {
  local exogv2_il `exogv2_il' `var'
 }	
}
foreach var of local exogv3 {
 _ms_parse_parts `var'
 if !`r(omit)' {
  local exogv3_il `exogv3_il' `var'
 }	
}


/*Keep relevant sample */

qui keep if `touse'==1

/* Create globals */

#delimit ;
foreach x in
S_slambda_f S_sigma { ;
global `x';
};
#delimit cr
global S_id "id"
global S_neq "`i'"
global S_endogvs "`endogvs'"
global S_vartype "vartype"
global S_resp "resp"
global S_rep "`rep'"
global S_method `method'
global S_stouse "`touse'"
global S_sncedv=`ncedv'
global S_sncssv=`ncssv'
global S_sncord=`ncordv'


/* locals for exogv in each equation */
local nex1: word count `exogv1'
local nex2: word count `exogv2'
local nex3: word count `exogv3'
local nex1_il: word count `exogv1_il'
local nex2_il: word count `exogv2_il'
local nex3_il: word count `exogv3_il'

/* Initiate globals + initial values */

tempname b0 aux cat
forval i=1/$S_neq {
 if `i' < 3 {
   qui probit resp  `exogv`i'' if `touse' & vartype==`i', `nc`i''
 }
 else {
   qui poisson resp  `exogv`i'' if `touse' & vartype==`i', `nc`i''
 }
 tempname junk`i'
 mat `junk`i'' = e(b)
 if `i' == 1 {
  mat `b0' = `junk`i''
  local ll0 = e(ll)
 }
 if `i'>1 {
  mat `b0' = `b0', `junk`i''
  local ll0 = e(ll) + `ll0'
 }
 if `i' < 3 {
  #delimit ;
  global S_eqs "$S_eqs (`eqname`i'':
  resp = `exogv`i'', `nc`i'') " ;
  #delimit cr
 }
 else {
  #delimit ;
  global S_eqs "$S_eqs (`eqname`i'':
  resp = `exogv`i'', `nc`i'') " ;
  #delimit cr
 }
}
local aux_names
local lambda lambda_1 lambda_2
foreach v in `lambda' {
local aux_names "`aux_names' `v':_cons"
global S_slambda "$S_slambda (`v':)"
}
local sigma_u sigma_u
foreach v in `sigma_u' {
local aux_names "`aux_names' `v':_cons"
global S_sigma_u "$S_sigma_u (`v':)"
}
mat `aux' = (0.5,0.5,0)
mat `b0' = (`b0',`aux')
local df : word count `exogv1_il' `exogv2_il' `exogv3_il'
local l0 "lf0(`df' `ll0')"
if "`from'" != "" {
 iniscaleOP `from' `nex1' `nex2' `nex3' id `ncedv' `ncssv' `ncordv'
 mat `b0' = `from'
 local ll0 = .
}

/* create some additional globals */

global S_x_1 "`exogv1'"
global S_x_2 "`exogv2'"
global S_x_3 "`exogv3'"
global S_x_1_il "`exogv1_il'"
global S_x_2_il "`exogv2_il'"
global S_x_3_il "`exogv3_il'"

/* create globals for scores */
global S_snex1=  `nexogv1'
global S_snex2=  `nexogv2'
global S_snex3=  `nexogv3'

global S_snex1_il= `nex1_il'
global S_snex2_il= `nex2_il'
global S_snex3_il= `nex3_il'

global S_snames ""
global S_nscores_il : word count `exogv1_il' `exogv2_il' `exogv3_il'
global S_nscores_il = $S_nscores_il + `ncedv' + `ncssv' + `ncordv' + 3
global S_nscores : word count `exogv1' `exogv2' `exogv3'
global S_nscores = $S_nscores + `ncedv' + `ncssv' + `ncordv' + 3
forval x = 1/$S_nscores {
 tempvar s_names_`x'
 gen double `s_names_`x'' = 0
 global S_snames "$S_snames `s_names_`x''"
}

/* Calculate number of obs at level 1 and 2 */

tempname N Nf
qui duplicates report id if `touse'
scalar `Nf'  = r(unique_value)
qui su id if `touse'
scalar `N' = r(N)

/* Keep relevant sample */

qui keep if `touse'

/* Estimate full model */

if "`hbased'" == "" {
 if "`evaluate'" != "" {
  #delimit ;
   capture ml model d2 petpoisson_ll $S_eqs
   $S_slambda $S_sigma_u, init(`b0', copy)
   `options'  `l0' search(off) `trace' missing negh
   novce  nowarn  nolog iterate(0)  nopreserve 
   max;
  #delimit cr
 }
 else {
  #delimit ;
   ml model d2 petpoisson_ll $S_eqs
   $S_slambda $S_sigma_u, init(`b0', copy)
    missing `constraints' `options' negh
   max `trace' search(off) `l0' nopreserve ;
  #delimit cr
 }
}
else {
 if "`evaluate'" != "" {
  #delimit ;
   capture ml model d1 petpoisson_ll $S_eqs
   $S_slambda $S_sigma_u, init(`b0', copy)
   `options'  `l0' search(off) `trace' missing
   novce  nowarn  nolog iterate(0)  nopreserve 
   max ;
  #delimit cr
 }
 else {
  #delimit ;
   ml model d1 petpoisson_ll $S_eqs
   $S_slambda $S_sigma_u, init(`b0', copy)
   `options'  `l0' search(off) `trace' missing 
   `constraints' nopreserve max;
  #delimit cr
 }
}

/* save convergence status locals */

tempname converged gradient
scalar `converged' = e(converged)
matrix `gradient' =  e(gradient) 

/* Deal with robust option */

local K = $S_nscores
if "`robust'" != "" {
 tempname eV rV eb
 mat `eb' = e(b)
 if "`hbased'" == "" {
 #delimit ;
  ml model d1 petpoisson_ll $S_eqs
   $S_slambda $S_sigma_u, init(`eb', copy) `l0'
  `mlopts' iter(0) nolog nowarning max missing  
   nopreserve;
 #delimit cr
 }
 mat `rV' = e(V)
 local Vnames: colfullnames `rV'
 local junk ""
 forval x = 1/`K' {
  local junk "`junk' eq`x':_cons"
 }
 if "`cluster'" != "" {
  tempvar clast
  global cS_snames ""
  sort `cluster' id
  by `cluster': gen `clast' = (_n==_N)
  forval x = 1/$S_nscores {
   qui {
    tempvar cs_names_`x'
    global cS_snames "$cS_snames `cs_names_`x''"
    gen double `cs_names_`x'' = 0
    by `cluster' id: replace `cs_names_`x'' = `s_names_`x'' if `last'==1
    by `cluster': replace `cs_names_`x'' = sum(`cs_names_`x'')
   }
  }
 }
 matrix colnames `rV' = `junk'
 matrix rownames `rV' = `junk'
 if "`cluster'" != "" {
  mata: RobustV("`clast'", "`rV'","cS_snames")
 }
 else {
  mata: RobustV("`last'", "`rV'","S_snames")
 }
 matrix colnames `rV' = `junk'
 matrix rownames `rV' = `junk'
 ereturn repost b=`eb' V=`rV', esample(`touse')
}

/* POST-ESTIMATION ISSUES */

/* Re-scale Coefficients */

tempname b1 V
mat `b1' = e(b)
mat `V' = e(V)
local colnames : colfullnames(`b1')
scaleOP `b1' `V' `nex1' `nex2' `nex3' id `ncedv' `ncssv' `ncordv'
mat coleq `b1' = `colnames'
mat coleq `V'  = `colnames'
mat roweq `V'  = `colnames'

/* Wald test */

if (`ncedv' + `ncssv' + `ncordv' == 3) {
 local tot = `nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+3
 tempname R q chi2
 matrix `R'=J(`tot',`tot',0)
 matrix `q'=J(`tot',1,0)
 local i=1
 while `i'<=(`nex1'){
  matrix `R'[`i',`i']=1
  local i = `i'+1
 }
 local i = `i' + 1
 while `i'<=(`nex1'+`ncedv'+`nex2') {
  matrix `R'[`i',`i']=1
  local i =`i' +1
 }
 local i = `i' + 1
 while `i'<=(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3') {
  matrix `R'[`i',`i']=1
  local i =`i' +1
 }
 matrix `chi2'=(`R'*`b1''-`q')'*syminv(`R'*`V'*`R'')*(`R'*`b1''-`q')
 local chi2_df = `nex1'+`nex2'+`nex3'
 local chi2 = `chi2'[1,1]
 local pchi=chiprob(`chi2_df',`chi2')
}
else{
 local chi2=.
 local chi2_df=.
 local pchi=.
}

/* Sort out type of random draws */

if `method'==1 {
 local drawM "Halton"
}
if `method'==2 {
 local drawM "Hammersley"
}
if `method'==3 {
 local drawM "pseudo-random"
}

/* get rho's */

tempname rho_1 rho_2 rho_12 rhoV
eRho `b1' `V' `rho_1' `rho_2' `rho_12' `rhoV'

tempname arho_1 arho_2 arho_12 arho_1_se arho_2_se arho_12_se 
scalar `arho_1' = `rho_1'
scalar `arho_1_se' = sqrt(`rhoV'[1,1])
scalar `arho_2' = `rho_2'
scalar `arho_2_se' = sqrt(`rhoV'[2,2])
scalar `arho_12' = `rho_12'
scalar `arho_12_se' = sqrt(`rhoV'[3,3])
mata: aRho("`arho_1'","`arho_1_se'")
mata: aRho("`arho_2'","`arho_2_se'")
mata: aRho("`arho_12'","`arho_12_se'")

/* Post new estimates */

local ell=e(ll)
local ek =e(k)
local ekeq=e(k_eq)
local en=e(N)
ereturn post `b1' `V'
ereturn local cmd "petpoisson"
ereturn local edv "`endogv1'"
ereturn local sv "`endogv2'"
ereturn local ordv "`endogv3'"
ereturn local robust "`robust'"
ereturn local exedv "`exogv1'"
ereturn local exsv "`exogv2'"
ereturn local exordv "`exogv3'"
ereturn local chi2type "Wald"
ereturn local drawM "`drawM'"
ereturn scalar lambda_1=_b[lambda_1:_cons]
ereturn scalar lambda_2=_b[lambda_2:_cons]
ereturn scalar sigma_u=_b[sigma_u:_cons]
ereturn scalar ncedv=`ncedv'
ereturn scalar ncsv=`ncssv'
ereturn scalar ncordv=`ncordv'
ereturn scalar rep = `rep'
ereturn scalar ll=`ell'
ereturn scalar ll_0 = `ll0'
ereturn scalar k = `ek'
ereturn scalar k_eq=`ekeq'
ereturn scalar N=`N'
ereturn scalar Nf=`Nf'
ereturn scalar chi2=`chi2'
ereturn scalar chi2_df=`chi2_df'
ereturn scalar pchi=`pchi'
ereturn scalar rho_Ty = `rho_1'
ereturn scalar rho_Ty_se = sqrt(`rhoV'[1,1])
ereturn scalar arho_Ty = `arho_1'
ereturn scalar arho_Ty_se = `arho_1_se'
ereturn scalar rho_Py = `rho_2'
ereturn scalar rho_Py_se = sqrt(`rhoV'[2,2])
ereturn scalar arho_Py = `arho_2'
ereturn scalar arho_Py_se = `arho_2_se' 
ereturn scalar rho_TP = `rho_12'
ereturn scalar rho_TP_se = sqrt(`rhoV'[3,3])
ereturn scalar arho_TP = `arho_12'
ereturn scalar arho_TP_se = `arho_12_se'
ereturn scalar converged = `converged'
ereturn matrix gradient = `gradient'
if ("`robust'" != "") {
 ereturn local vcetype "Robust"
}
if ("`robust'" == "" & "`hbased'"== "") {
 ereturn local vcetype "OPG"
}
if ("`robust'" == "" & "`hbased'" != "") {
 ereturn local vcetype ""
}
restore

/* Drop globals no longer needed */

mac drop S_s* S_cat S_x* S_n* S_eqs S_e* S_r* S_i*

/* Display */

Display
end

program define scaleOP
version 7
tokenize "`0'"
tempname eb eV G g V load_1 load_2 sigma_u
matrix `eb'= `1'
matrix `eV'= `2'
local nex1 = `3'
local nex2 = `4'
local nex3 = `5'
local id "`6'"
local ncedv = `7'
local ncssv = `8'
local ncordv = `9'
local nt1 = `nex1'+`nex2'+`nex3'+ `ncedv' + `ncssv' + `ncordv' + 3
scalar `load_1' = _b[lambda_1:_cons]
scalar `load_2' = _b[lambda_2:_cons]
scalar `sigma_u' = _b[sigma_u:_cons]
scalar `sigma_u' = exp(`sigma_u')
/* Transformation matrix */
matrix `G'=J(`nt1',`nt1',0)
local i=1
while `i'<=(`nex1'+`ncedv') {
 matrix `G'[`i',`i']=1/sqrt(`sigma_u'^2*`load_1'^2 + 1)
 local i = `i'+1
}
while `i'<=(`nex1'+`ncedv'+`nex2'+`ncssv') {
 matrix `G'[`i',`i']=1/sqrt(`sigma_u'^2*`load_2'^2 + 1)
 local i =`i' +1
}
while `i'<=(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv') {
 matrix `G'[`i',`i']=1
 local i = `i' + 1
}
matrix `G'[(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+1),(`nex1'+`ncedv'+`nex2'+`nex3'+`ncssv'+`ncordv'+1)]=1
matrix `G'[(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+2),(`nex1'+`ncedv'+`nex2'+`nex3'+`ncssv'+`ncordv'+2)]=1
matrix `G'[(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+3),(`nex1'+`ncedv'+`nex2'+`nex3'+`ncssv'+`ncordv'+3)]=1
/*Derivative of the transformation */
matrix `g'=`G'              /* for most coefficients g=G, only when derivative wrt to  */
local i = 1  /* lambdas is taken we need to adjust g */
local j = `nt1'-2
local k = `nt1'
while `i'<=(`nex1'+`ncedv') {                               /* Fix DF(coeff)/Dlambda_1 */
 matrix `g'[`i',`j']=-(`eb'[1,`i']*`sigma_u'^2*`load_1')/(1+`sigma_u'^2*`load_1'^2)^(3/2)
 local i = `i' + 1
}
local j = `nt1'-1
local i = `nex1'+`ncedv'+1                                  /* Fix DF(coeff)/Dlambda_2 */
while `i'<=(`nex1'+`ncedv'+`nex2'+`ncssv') {
 matrix `g'[`i',`j']=-(`eb'[1,`i']*`sigma_u'^2*`load_2')/(1+`sigma_u'^2*`load_2'^2)^(3/2)
 local i = `i' + 1
}
local j = `nt1'
local i = 1
while `i'<=(`nex1'+`ncedv') {                                /* Fix DF(coeff)/Dsigma_u */
 matrix `g'[`i',`j']=-(`eb'[1,`i']*`sigma_u'^2*`load_1'^2)/(1+`sigma_u'^2*`load_1'^2)^(3/2)
 local i = `i' + 1
}
local i = `nex1'+`ncedv'+1      
while `i'<=(`nex1'+`ncedv'+`nex2'+`ncssv') {
 matrix `g'[`i',`j']=-(`eb'[1,`i']*`sigma_u'^2*`load_2'^2)/(1+`sigma_u'^2*`load_2'^2)^(3/2)
 local i = `i' + 1
}
/*Use Delta method*/
mat `1'=(`G'*`eb'')'
mat `2'=`g'*`eV'*`g''
end


program define iniscaleOP
version 7
tokenize "`0'"
tempname ib iG rr load_1 load_2 sigma_u
matrix `ib'= `1'
local nex1 = `2'
local nex2 = `3'
local nex3 = `4'
local id "`5'"
local ncedv = `6'
local ncssv = `7'
local ncordv = `8'
local nt1 = `nex1'+`nex2'+`nex3'+ `ncedv' + `ncssv' + `ncordv' + 3
matrix `iG'=J(`nt1',`nt1',0)
mat `rr' = `ib'[1,1..`nex1'+`nex2'+`nex3'+`ncedv'+`ncssv'+`ncordv']
scalar `load_1' = `ib'[1,`nex1'+`nex2'+`nex3'+`ncedv'+`ncssv'+`ncordv'+1]
scalar `load_2' = `ib'[1,`nex1'+`nex2'+`nex3'+`ncedv'+`ncssv'+`ncordv'+2]
scalar `sigma_u' = `ib'[1,`nex1'+`nex2'+`nex3'+`ncedv'+`ncssv'+`ncordv'+3]
scalar `sigma_u' = exp(`sigma_u')
local i=1
while `i'<=(`nex1'+`ncedv') {
  matrix `iG'[`i',`i']=sqrt(`sigma_u'^2*`load_1'^2 + 1)
  local i = `i'+1
 }
while `i'<=(`nex1'+`ncedv'+`nex2'+`ncssv') {
 matrix `iG'[`i',`i']=sqrt(`sigma_u'^2*`load_2'^2 + 1)
 local i =`i' +1
}
while `i'<=(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv') {
 matrix `iG'[`i',`i']=1
 local i =`i' +1
}
matrix `iG'[(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+1),(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+1)]=1
matrix `iG'[(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+2),(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+2)]=1
matrix `iG'[(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+3),(`nex1'+`ncedv'+`nex2'+`ncssv'+`nex3'+`ncordv'+3)]=1
mat `1'=(`iG'*`ib'')'     /* `ib'' is a column vector and `G' a transformation matrix */
end

program define Display
di _newline(3)
if (e(ncedv)==1 & e(ncsv)==1 & e(ncordv)==1) {
 local flag=1
}
else{
 local flag=0
}
tempname b V Wrho pWrho
mat `b' = e(b)
mat `V' = e(V)
scalar `Wrho' = .
scalar `pWrho' = .
WaldRho `b' `V' `Wrho' `pWrho'
if `Wrho' < 1e-5 {
 scalar `Wrho' = 0
}
if `Wrho'==0 {
 scalar `pWrho' = 1
 }
if (`Wrho' > 0.005) & (`Wrho'<1e4) | (`Wrho')==0 {
 local fmt "%8.5g"
}
#delimit ;
di as text "Endogenous Participation Endogenous Treatment Poisson Model by MSL";
di as text "(# " as text e(drawM) " draws = " as res e(rep) as text ")" ;
di _skip(12);
di as text  _col(47) "Number of level 2 obs = " as res %8.0g e(Nf);
di as text  _col(47) "Number of level 1 obs = " as res %8.0g e(N);
di as text _col(47)  "Log likelihood        = " as res %8.5g e(ll);
if `flag'==1 {;
di as text _col(47)  "Wald chi2(" as res %1.0f e(chi2_df) as text ")          = " as res %8.5g e(chi2);
di as text _col(47)  "Prob > chi2           =" " " as ye %8.4f e(pchi);
};
#delimit cr
_coef_table, noempty neq(3) plus
local sigma_u "exp(@2)"
local load_1 "@1"
local load_2 "@1"
local junk13 "sqrt(`sigma_u'^2*(1+`load_1'^2*`sigma_u'^2))"
local junk23 "sqrt(`sigma_u'^2*(1+`load_2'^2*`sigma_u'^2))"
local junk12 "sqrt((1+`load_1'^2*`sigma_u'^2)*(1+`load_1'^2*`sigma_u'^2))"
local junk1 "(1+`load_1'^2*`sigma_u'^2)"
local junk2 "(1+`load_2'^2*`sigma_u'^2)"
#delimit ;
_diparm lambda_1 sigma_u, f((`load_1'*`sigma_u'^2)/`junk13') 
d((`sigma_u'^2*`junk13'-`load_1'^2*`sigma_u'^6*`junk13'^(-1))/`junk13'^2
(2*`load_1'*`sigma_u'^2*`junk13'-`load_1'*`sigma_u'^4*(2*`load_1'^2*`sigma_u'^2+1)*`junk13'^(-1))/`junk13'^2
) pr label(rho_Ty) ci(atanh);
_diparm lambda_2 sigma_u, f((`load_2'*`sigma_u'^2)/`junk23') 
d((`sigma_u'^2*`junk23'-`load_2'^2*`sigma_u'^6*`junk23'^(-1))/`junk23'^2 
(2*`load_2'*`sigma_u'^2*`junk23'-`load_2'*`sigma_u'^4*(2*`load_2'^2*`sigma_u'^2+1)*`junk23'^(-1))/`junk23'^2) 
pr label(rho_Py) ci(atanh);
#delimit cr
local load_1 "@1"
local load_2 "@2"
local sigma_u "exp(@3)"
local junk1 "(1+(`load_1')^2*(`sigma_u')^2)"
local junk2 "(1+(`load_2')^2*(`sigma_u')^2)"
#delimit ;
_diparm lambda_1 lambda_2 sigma_u, func((`load_1'*`load_2'*`sigma_u'^2)/sqrt(`junk1'*`junk2'))
der((`load_2'*`sigma_u'^2*`junk12'-`load_1'^2*`load_2'*`sigma_u'^4*`junk2'*(`junk12')^(-1))/`junk12'^2
(`load_1'*`sigma_u'^2*`junk12'-`load_1'*`load_2'^2*`sigma_u'^4*`junk1'*(`junk12')^(-1))/`junk12'^2
(2*`load_1'*`load_2'*`sigma_u'^2*`junk12'-`load_1'*`load_2'*`sigma_u'^4*(`load_1'^2*`junk2'+`load_2'^2*`junk1')*(`junk12')^(-1))/`junk12'^2)
pr label(rho_TP) ci(atanh);
#delimit cr
di in smcl in gr "{hline 13}{c +}{hline 64}"
_diparm sigma_u, exp prob label(sigma_u) 
di in smcl in gr "{hline 13}{c BT}{hline 64}"
di as text "Wald test for rho_Ty=rho_Py=rho_TP=0:" _col(40) as txt "chi2(" as res "3" as txt") = " as res `fmt' `Wrho' /*
*/ in gre " Prob > chi2 = "  in ye %5.4f `pWrho'
di in smcl in gr "{hline 13}{hline 65}"
di as text "Note: Endogenous treatment  eqn  reported  in  top panel and participation  dummy"
di as text "      eqn reported in second from top panel."
end

program define WaldRho
version 7
tokenize "`0'"
tempname b V rho_1 rho_2 rho_12 load_1 load_2 sigma_u G g R q chi2
matrix `b'= `1'
matrix `V' = `2'
local ncols = colsof(`b')
matrix `V'=`V'[(`ncols'-2)..`ncols',(`ncols'-2)..`ncols']
scalar `load_1' = `b'[1,`ncols'-2]
scalar `load_2' = `b'[1,`ncols'-1]
scalar `sigma_u' = `b'[1,`ncols']
scalar `sigma_u' = exp(`sigma_u')
local junk13 "sqrt(`sigma_u'^2*(1+`load_1'^2*`sigma_u'^2))"
local junk23 "sqrt(`sigma_u'^2*(1+`load_2'^2*`sigma_u'^2))"
local junk12 "sqrt((1+`load_1'^2*`sigma_u'^2)*(1+`load_1'^2*`sigma_u'^2))"
local junk1 "(1+(`load_1')^2*(`sigma_u')^2)"
local junk2 "(1+(`load_2')^2*(`sigma_u')^2)"
scalar `rho_1' = (`load_1'*`sigma_u'^2)/`junk13'
scalar `rho_2' = (`load_2'*`sigma_u'^2)/`junk23'
scalar `rho_12' = (`load_1'*`load_2'*`sigma_u'^2)/sqrt(`junk1'*`junk2')
matrix `G'=J(1,3,0)
matrix `g'=J(3,3,0)
matrix `G'[1,1]=`rho_1'
matrix `G'[1,2]=`rho_2'
matrix `G'[1,3] = `rho_12'
matrix `g'[1,1]= (`sigma_u'^2*`junk13' - `load_1'^2*`sigma_u'^6*`junk13'^(-1))/`junk13'^2
matrix `g'[1,3]= (2*`load_1'*`sigma_u'^2*`junk13' - `load_1'*`sigma_u'^4*(2*`load_1'^2*`sigma_u'^2+1)*`junk13'^(-1))/`junk13'^2
matrix `g'[2,2]= (`sigma_u'^2*`junk23' - `load_2'^2*`sigma_u'^6*`junk23'^(-1))/`junk23'^2
matrix `g'[2,3]= (2*`load_2'*`sigma_u'^2*`junk23' - `load_2'*`sigma_u'^4*(2*`load_2'^2*`sigma_u'^2+1)*`junk23'^(-1))/`junk23'^2
matrix `g'[3,1] = (`load_2'*`sigma_u'^2*`junk12'-`load_1'^2*`load_2'*`sigma_u'^4*`junk2'*(`junk12')^(-1))/`junk12'^2
matrix `g'[3,2] = (`load_1'*`sigma_u'^2*`junk12'-`load_1'*`load_2'^2*`sigma_u'^4*`junk1'*(`junk12')^(-1))/`junk12'^2
matrix `g'[3,3] = (2*`load_1'*`load_2'*`sigma_u'^2*`junk12'-`load_1'*`load_2'*`sigma_u'^4*(`load_1'^2*`junk2'+`load_2'^2*`junk1')*(`junk12')^(-1))/`junk12'^2
/* Get covariance matrix for rho_1 and rho_2 --- Delta method */
mat `V'=`g'*`V'*`g''
/* Now do the wald test */
matrix `R'=J(3,3,0)
matrix `q'=J(3,1,0)
local i=1
forval i = 1/3 {
 matrix `R'[`i',`i']=1
}
matrix `chi2'=(`R'*`G''-`q')'*syminv(`R'*`V'*`R'')*(`R'*`G''-`q')
scalar `3' = `chi2'[1,1]
scalar `4' = chiprob(3,`3')
end

program define eRho
version 7
tokenize "`0'"
tempname b V rho_1 rho_2 rho_12 load_1 load_2 sigma_u G g 
matrix `b'= `1'
matrix `V' = `2'
local ncols = colsof(`b')
matrix `V'=`V'[(`ncols'-2)..`ncols',(`ncols'-2)..`ncols']
scalar `load_1' = `b'[1,`ncols'-2]
scalar `load_2' = `b'[1,`ncols'-1]
scalar `sigma_u' = `b'[1,`ncols']
scalar `sigma_u' = exp(`sigma_u')
local junk13 "sqrt(`sigma_u'^2*(1+`load_1'^2*`sigma_u'^2))"
local junk23 "sqrt(`sigma_u'^2*(1+`load_2'^2*`sigma_u'^2))"
local junk12 "sqrt((1+`load_1'^2*`sigma_u'^2)*(1+`load_1'^2*`sigma_u'^2))"
local junk1 "(1+`load_1'^2*`sigma_u'^2)"
local junk2 "(1+`load_2'^2*`sigma_u'^2)"
scalar `rho_1' = (`load_1'*`sigma_u'^2)/`junk13'
scalar `rho_2' = (`load_2'*`sigma_u'^2)/`junk23'
scalar `rho_12' = (`load_1'*`load_2'*`sigma_u'^2)/sqrt(`junk1'*`junk2')
matrix `G'=J(1,3,0)
matrix `g'=J(3,3,0)
matrix `G'[1,1]=`rho_1'
matrix `G'[1,2]=`rho_2'
matrix `G'[1,3] = `rho_12'
matrix `g'[1,1]= (`sigma_u'^2*`junk13' - `load_1'^2*`sigma_u'^6*`junk13'^(-1))/`junk13'^2
matrix `g'[1,3]= (2*`load_1'*`sigma_u'^2*`junk13' - `load_1'*`sigma_u'^4*(2*`load_1'^2*`sigma_u'^2+1)*`junk13'^(-1))/`junk13'^2
matrix `g'[2,2]= (`sigma_u'^2*`junk23' - `load_2'^2*`sigma_u'^6*`junk23'^(-1))/`junk23'^2
matrix `g'[2,3]= (2*`load_2'*`sigma_u'^2*`junk23' - `load_2'*`sigma_u'^4*(2*`load_2'^2*`sigma_u'^2+1)*`junk23'^(-1))/`junk23'^2
matrix `g'[3,1] = (`load_2'*`sigma_u'^2*`junk12'-`load_1'^2*`load_2'*`sigma_u'^4*`junk2'*(`junk12')^(-1))/`junk12'^2
matrix `g'[3,2] = (`load_1'*`sigma_u'^2*`junk12'-`load_1'*`load_2'^2*`sigma_u'^4*`junk1'*(`junk12')^(-1))/`junk12'^2
matrix `g'[3,3] = (2*`load_1'*`load_2'*`sigma_u'^2*`junk12'-`load_1'*`load_2'*`sigma_u'^4*(`load_1'^2*`junk2'+`load_2'^2*`junk1')*(`junk12')^(-1))/`junk12'^2
/* Get covariance matrix for rho_1 and rho_2 --- Delta method */
mat `V'=`g'*`V'*`g''
scalar `3' = `rho_1'
scalar `4' = `rho_2'
scalar `5' = `rho_12'
matrix `6' = `V'
end
exit
