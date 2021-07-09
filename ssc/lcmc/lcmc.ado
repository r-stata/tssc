*! Authors: Alfonso Miranda (alfonso.miranda@cide.edu) & Sophia Rabe-Hesketh (sophiarh@berkeley.edu)
*! This version 07/05/2013

capture program drop lcmc
program define lcmc, eclass
version 10.1
 if replay() {
  if "`e(cmd)'" != "lcmc" {
   error 301
  }
  lcmc_Display `0'
  exit
  }
 capture noisily Estimate `0'
 exit _rc
end

program define Estimate, eclass

/* Drop globals from previous execution */

mac drop S_s* S_cat S_x* S_n* S_eqs S_e* S_r* S_i*

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
 syntax [varlist (default=none)] [, noCONstant]
 local exogv`i' `varlist'
 local nexogv`i' : word count `exogv`i''
 if ("`constant'" == "" & `i'==1) {
  local nexogv`i' = `nexogv`i'' + 1
 }
 local exogvs "`exogvs' `exogv`i''"
 local nc`i' `constant'
 local 0 "`left'"
 gettoken check:left, parse(" ,[") match(paren)
 local i = `i' + 1
}
if `i' > 3 {
  in red "only three equations are allowed"
 error 198
}

/* sort out constants */

if "`nc1'" == "" {
 local ncselvar = 1
}
else {
 local ncselvar = 0
}
if "`nc2'" != "" {
 in red "option nocons not available"
 error 198
}
else {
 local ncyvar = 0
}
if "`nc3'" != "" {
 in red "option nocons not available"
 error 198
}


/* varsion change */

version 10.1

/* Remaining options */

local 0 "`left'"
syntax [if] [in], [rep(integer 1600) /*
 */ METHod(integer 1) FROM(string) CONSTRaints(passthru) /*
 */ TRace EVALuate ROBust HBased HVECtor(string) /*
 */ cluster(string) SCale(real 0.2) THRESctr *]


/* hvector option */

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

/* Deal with eval + HBbased + trace */

if "`evaluate'"~="" & "`from'" == "" {
 disp in red "eval option only allowed with from()"
 exit 198
}


/* Generate id set-up scale */

preserve
marksample touse
capture confirm var id
if _rc!=0 {
 gen id=_n
}
global S_scale = `scale'

/* Expand data */

qui gen vartype1=1
qui gen vartype2=2
qui gen vartype3=3
qui reshape long vartype, i(id)
qui gen selvar=cond(vartype==1,1,0)
qui gen yvar=cond(vartype==2,1,0)
qui gen mcvar=cond(vartype==3,1,0)

/* Sort data */

qui sort id vartype

/* Response */

qui gen resp=`endogv1'
qui replace resp=`endogv2' if yvar==1
qui replace resp=`endogv3' if mcvar==1

/* Select sample */


tempvar nouse last
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
 by id: replace `touse'=0 if resp[2]==. | `touse'[2]==0
}


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
global S_sncselvar=`ncselvar'
global S_threstr = cond("`thresctr'"!="",1,0)

/* locals for exogv in each equation */
local nex1: word count `exogv1'
local nex2: word count `exogv2'
local nex3: word count `exogv3'

/* Initiate globals + initial values */

tempvar movar
local lmovar ""
qui ta `endogv3' if `touse', gen(`movar') 
local ncats= r(r) 
forval x = 1/`ncats' {
 local  lmovar "`lmovar' `movar'`x'"  
}

tempname b0 b1 b2 aux cat auxcat
forval i=1/$S_neq {
 _rmcoll `exogv`i'' if `touse', `nc`i''
 local exogv`i' "`r(varlist)'"
 if `i' == 1 {
   qui probit resp  `exogv`i'' if `touse' & vartype==`i', `nc`i''
 }
 if `i'==2 {
   qui regress resp  `exogv`i'' `lmovar' if `touse' & vartype==`i', nocons
   global S_sNyvar = e(N)
 }
 if `i'==3 {
   qui oprobit resp  `exogv`i'' if `touse' & vartype==`i'
   local ncuts = e(k_cat) - 1
   local ncats = e(k_cat)
   mat `cat' = e(cat)
 }
 tempname junk`i'
 mat `junk`i'' = e(b)
 if `i' == 1 {
  mat `b0' = `junk`i''
  local ll0 = e(ll)
 }
 if `i'== 2 {
  tempname icat ib2
  if `nex2'!= 0 {
   mat `ib2' = `junk`i''[1,1..`nex2']
   mat `b0' = (`b0',`ib2')
  }
  mat `icat' = `junk`i''[1,`nex2'+1..`nex2'+`ncats']
  local ll0 = e(ll) + `ll0'
 }
 if `i'== 3 {
  if `nex3' != 0 {
   mat `b1' = `junk`i''[1,1..`nex3']
   mat `b0' = (`b0',`b1')
  }
  local r = `nex3' + 1
   mat `b2' = `junk`i''[1,`r'...]
   local ll0 = e(ll) + `ll0'
 }
 if (`i' == 1) {
  #delimit ;
  global S_eqs "$S_eqs (`eqname`i'':
  resp = `exogv`i'', `nc`i'') " ;
  #delimit cr
 }
 else {
  #delimit ;
  global S_eqs "$S_eqs (`eqname`i'':
  resp = `exogv`i'', nocons) " ;
  #delimit cr
 }
}
local aux_names
forval w = 1/`ncats' {
 local yunk = `cat'[1,`w']
 local aux_names "`aux_names' mcovar_`yunk':_cons"
 global S_scats "$S_scats (mcovar_`yunk':)"
}
forval w = 1/`ncuts' {
 local aux_names "`aux_names' cut`w':_cons"
 global S_scuts "$S_scuts (cut`w':)"
}
local lambda lambda_1 lambda_2 lambda_3
foreach v in `lambda' {
local aux_names "`aux_names' `v':_cons"
global S_slambda "$S_slambda (`v':)"
}
qui su resp  if `touse' & vartype==2
local ilambda_1 = sqrt(r(sd)^2-`scale'^2)
mat `auxcat' = `icat' 
mat `aux' = (`ilambda_1',0,0)
mat `b0' = (`b0',`auxcat',`b2',`aux')
local df : word count `exogv1' `exogv2' `exogv3'
local l0 "lf0(`df' `ll0')"
iniscaleOP `b0' `nex1' `nex2' `nex3' id `ncuts' `ncselvar' `scale'
if "`from'" != "" {
 iniscaleOP `from' `nex1' `nex2' `nex3' id `ncuts' `ncselvar' `scale'
 mat `b0' = `from'
 local ll0 = .
}

/* create some adtional globals */

global S_x_1 "`exogv1'"
global S_x_2 "`exogv2'"
global S_x_3 "`exogv3'"

/* create globals for scores */
global S_snex1=  `nexogv1'
global S_snex2=  `nexogv2'
global S_snex3=  `nexogv3'
global S_ncuts = `ncuts'
global S_ncats = `ncats'
global S_cat `cat'
global S_snames ""
global S_nscores : word count `exogv1' `exogv2' `exogv3'
global S_nscores = $S_nscores + `ncselvar' + `ncats' + `ncuts' + 3
forval x = 1/$S_nscores {
 gen double s_names_`x' = 0
 global S_snames "$S_snames s_names_`x'"
}

/* Calculate number of obs at level 1 and 2 */

tempname N Nf
qui duplicates report id if `touse'
scalar `Nf'  = r(unique_value)
qui su id if `touse'
scalar `N' = r(N)

/* Keep relevant sample */

tempvar last
qui keep if `touse'
sort id vartype
by id: gen `last'= (_n==_N) 

/* Estimate full model */

if "`hbased'" == "" {
 if "`evaluate'" != "" {
  #delimit ;
   capture ml model d2 lcmc_ll $S_eqs
   $S_scats $S_scuts $S_slambda, init(`b0', copy)
   `options'  `l0' search(off) `trace' missing
   novce  nowarn  nolog `options' iterate(0)
   max;
  #delimit cr
 }
 else {
  #delimit ;
   ml model d2 lcmc_ll $S_eqs
   $S_scats $S_scuts $S_slambda, init(`b0', copy)
    missing `constraints' `options'  search(off) 
    max `trace'  `l0'; 
  #delimit cr
 }
}
else {
 if "`evaluate'" != "" {
  #delimit ;
   capture ml model d1 lcmc_ll $S_eqs
   $S_scats $S_scuts $S_slambda, init(`b0', copy)
   `options'  `l0' search(off) `trace' missing
   novce  nowarn  nolog iterate(0)
   max ;
  #delimit cr
 }
 else {
  #delimit ;
   ml model d1 lcmc_ll $S_eqs
   $S_scats $S_scuts $S_slambda, init(`b0', copy)  search(off)
   `options' `l0' missing  `trace' `constraints' difficult   max;
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
   ml model d1 lcmc_ll $S_eqs
    $S_scats $S_scuts $S_slambda $S_sigma_y, init(`eb', copy) `l0'
   `mlopts' iter(0) nolog nowarning max missing;
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
scaleOP `b1' `V' `nex1' `nex2' `nex3' id `ncuts' `ncselvar' `scale'
mat coleq `b1' = `colnames'
mat coleq `V'  = `colnames'
mat roweq `V'  = `colnames'

/* Wald test */

if (`ncselvar' == 1) {
 local tot = `nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+3
 tempname R q chi2
 matrix `R'=J(`tot',`tot',0)
 matrix `q'=J(`tot',1,0)
 local i=1
 while `i'<=(`nex1'){
  matrix `R'[`i',`i']=1
  local i = `i'+1
 }
 local i = `i' + 1
 while `i'<=(`nex1'+`ncselvar'+`nex2') {
  matrix `R'[`i',`i']=1
  local i =`i' +1
 }
 local i = `i' + 1
 while `i'<=(`nex1'+`ncselvar'+`nex2'+`nex3') {
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

tempname rho_ys rho_xs rhoV
eRho `b1' `V' `rho_ys' `rho_xs'  `rhoV' `scale'

/* calculate rhos under archtanh trasnformation */

tempname arho_ys arho_ys_se arho_xs arho_xs_se
scalar `arho_ys' = `rho_ys'
scalar `arho_ys_se' = sqrt(`rhoV'[1,1])
scalar `arho_xs' = `rho_xs'
scalar `arho_xs_se' = sqrt(`rhoV'[2,2])
mata: aRho("`arho_ys'","`arho_ys_se'")
mata: aRho("`arho_xs'","`arho_xs_se'")

/* Post new estimates */

local ell=e(ll)
local ek =e(k)
local ekeq=e(k_eq)
local en=e(N)
ereturn post `b1' `V'
ereturn local cmd "lcmc"
ereturn local selvar "`endogv1'"
ereturn local yvar "`endogv2'"
ereturn local mcvar "`endogv3'"
ereturn local robust "`robust'"
ereturn local exselvar "`exogv1'"
ereturn local exyvar "`exogv2'"
ereturn local exmcvar "`exogv3'"
ereturn local chi2type "Wald"
ereturn local drawM "`drawM'"
ereturn scalar lambda_1=_b[lambda_1:_cons]
ereturn scalar lambda_2=_b[lambda_2:_cons]
ereturn scalar lambda_3=_b[lambda_3:_cons]
ereturn scalar ncuts=`ncuts'
ereturn scalar ncselvar=`ncselvar'
ereturn scalar rep = `rep'
ereturn scalar scale = `scale'
ereturn scalar ll=`ell'
ereturn scalar ll_0 = `ll0'
ereturn scalar k = `ek'
ereturn scalar k_eq=`ekeq'
ereturn scalar N=`N'
ereturn scalar Nf=`Nf'
ereturn scalar chi2=`chi2'
ereturn scalar chi2_df=`chi2_df'
ereturn scalar pchi=`pchi'
ereturn matrix cat = `cat'
ereturn scalar rho_ys = `rho_ys'
ereturn scalar rho_ys_se = sqrt(`rhoV'[1,1])
ereturn scalar rho_xs = `rho_xs'
ereturn scalar rho_xs_se = sqrt(`rhoV'[2,2])
ereturn scalar arho_ys = `arho_ys'
ereturn scalar arho_ys_se = `arho_ys_se'
ereturn scalar arho_xs = `arho_xs'
ereturn scalar arho_xs_se = `arho_xs_se'
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

lcmc_Display
end

program define scaleOP
version 7
tokenize "`0'"
tempname eb eV G g V load_1 load_2 load_3 
matrix `eb'= `1'
matrix `eV'= `2'
local nex1 = `3'
local nex2 = `4'
local nex3 = `5'
local id "`6'"
local ncuts = `7'
local ncselvar = `8'
local scale = `9'
local ncats = `ncuts' + 1
local nt1 = `nex1'+`nex2'+`nex3'+ `ncselvar' + `ncats' + `ncuts' + 3
scalar `load_1' = _b[lambda_2:_cons]
scalar `load_2' = _b[lambda_2:_cons]
scalar `load_3' = _b[lambda_3:_cons]
/* Transformation matrix */
matrix `G'=J(`nt1',`nt1',0)
local i=1
while `i'<=(`nex1'+`ncselvar') {  /* selvar*/
 matrix `G'[`i',`i']=1/sqrt(`load_2'^2 + `load_3'^2 + `scale'^2)
 local i =`i' +1
}
while `i'<=(`nex1'+`ncselvar'+`nex2') {    /* yvar */
 matrix `G'[`i',`i']=1
 local i = `i'+1
}
while `i'<=(`nex1'+`ncselvar'+`nex2'+`nex3') {   /* mcvar */
 matrix `G'[`i',`i']=1/sqrt(1 + `scale'^2)
 local i = `i' + 1
}
while `i'<=(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats') {   /* coeff on mcvar in main response */
 matrix `G'[`i',`i']=1
 local i = `i' + 1
}
while `i'<=(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts') {   /* cuts */
 matrix `G'[`i',`i']=1/sqrt(1 + `scale'^2)
 local i = `i' + 1
}
matrix `G'[(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+1),(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+1)]=1
matrix `G'[(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+2),(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+2)]=1
matrix `G'[(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+3),(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+3)]=1
/*Derivative of the transformation */
matrix `g'=`G'                 /* for most coefficients g=G, only when derivative wrt to  */
local i = 1                    /* lambdas_2 and lambda_3 is taken I need to adjust g */
local j = `nt1'-1
local k = `nt1'
while `i'<=(`nex1'+`ncselvar') {          /* Fix DF(coeff)/Dlambda_2 and DF(coeff)/Dlambda_3 */
 matrix `g'[`i',`j']=-(`eb'[1,`i']*`load_2')/(`load_2'^2 + `load_3'^2 + `scale'^2)^(3/2)    /* NEED TO FIX THIS */
 matrix `g'[`i',`k']=-(`eb'[1,`i']*`load_3')/(`load_2'^2+`load_3'^2+`scale'^2)^(3/2)  
 local i = `i' + 1
}
/*Use Delta method*/
mat `1'=(`G'*`eb'')'
mat `2'=`g'*`eV'*`g''
end

program define iniscaleOP
version 7
tokenize "`0'"
tempname ib iG rr load_1 load_2 load_3 sigma_y
matrix `ib'= `1'
local nex1 = `2'
local nex2 = `3'
local nex3 = `4'
local id "`5'"
local ncuts = `6'
local ncselvar = `7'
local scale = `8'
local ncats = `ncuts' + 1
local nt1 = `nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts' + 3
matrix `iG'=J(`nt1',`nt1',0)
mat `rr' = `ib'[1,1..`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts']
scalar `load_1' = `ib'[1,`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+1]
scalar `load_2' = `ib'[1,`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+2]
scalar `load_3' = `ib'[1,`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+3]
local i=1
while `i'<=(`nex1'+`ncselvar') {
  matrix `iG'[`i',`i']=sqrt(`load_2'^2 + `load_3'^2 + `scale'^2)
  local i = `i'+1
 }
while `i'<=(`nex1'+`ncselvar'+`nex2') {
 matrix `iG'[`i',`i']=1
 local i =`i' +1
}
while `i'<=(`nex1'+`ncselvar'+`nex2'+`nex3') {
 matrix `iG'[`i',`i']=sqrt(1+`scale'^2)
 local i =`i' +1
}
while `i'<=(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats') {
 matrix `iG'[`i',`i']=1
 local i =`i' +1
}
while `i'<=(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts') {
 matrix `iG'[`i',`i']=sqrt(1+`scale'^2)
 local i =`i' +1
}
matrix `iG'[(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+1),(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+1)]=1
matrix `iG'[(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+2),(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+2)]=1
matrix `iG'[(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+3),(`nex1'+`ncselvar'+`nex2'+`nex3'+`ncats'+`ncuts'+3)]=1
mat `1'=(`iG'*`ib'')'     /* `ib'' is a column vector and `G' a transformation matrix */
end

program define lcmc_Display
di _newline(3)
if (e(ncselvar)==  1) {
 local flag=1
}
else{
 local flag=0
}
tempname b V Wrho pWrho cat
local ncuts = e(ncuts)
local ncats = `ncuts' + 1
local scale = e(scale)
mat `b' = e(b)
mat `V' = e(V)
mat `cat' = e(cat)
scalar `Wrho' = .
scalar `pWrho' = .
WaldRho `b' `V' `Wrho' `pWrho' `scale'
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
di as text "Latent class model for missing ordinal covariate and continuous main response";
di as text "by MSL (# " as text e(drawM) " draws = " as res e(rep) as text ")" ;
di _skip(12);
di as text  _col(30) "Number of indviduals (level 2)         = " as res %8.0g e(Nf);
di as text  _col(30) "Number of indvidual-occasion (level 1) = " as res %8.0g e(N);
di as text _col(30)  "Log likelihood                         = " as res %8.5g e(ll);
if `flag'==1 {;
di as text _col(30)  "Wald chi2(" as res %1.0f e(chi2_df) as text ")" as text _col(68) " = " as res %8.5g e(chi2);
di as text _col(30)  "Prob > chi2" as text _col(68) " = " as ye %8.4f e(pchi);
};
#delimit cr
ereturn display, neq(3) plus
// in ye e(yvar) in gre _col(14) "{c |}"
forval i = 1/`ncats' {
 local junk = `cat'[1,`i']
 _diparm mcovar_`junk', pr label(1(mcv=`junk'))
}
di in smcl in gr "{hline 13}{c +}{hline 64}"
local junk "sqrt((@1^2+`scale'^2)*(@2^2+@3^2+`scale'^2))"
local junk1 "(@1^2+`scale'^2)"
local junk2 "(@2^2+@3^2+`scale'^2)"
#delimit ;
_diparm lambda_1 lambda_2 lambda_3, f(@1*@2/`junk') d((@2*`junk'-@1^2*@2*`junk2'*`junk'^(-1))/`junk'^2
(@1*`junk'-@1*@2^2*`junk1'*`junk'^(-1))/`junk'^2 (-@1*@2*@3*`junk1'*`junk'^(-1))/`junk'^2) 
pr label(rho_{s,y}) ci(atanh);
local junk "sqrt((1+`scale'^2)*(@1^2+@2^2+`scale'^2))";
local junk1 "(1+`scale'^2)";
local junk2 "(@1^2+@2^2+`scale'^2)";
_diparm lambda_2 lambda_3, f(@2/`junk') d((-@1*@2*`junk1'*`junk'^(-1))/`junk'^2 (`junk'-@2^2*`junk1'*`junk'^(-1))/`junk'^2) pr label(rho_{s,mcv}) ci(atanh);
#delimit cr
di in smcl in gr "{hline 13}{c +}{hline 64}"
forval i = 1/`ncuts' {
 _diparm cut`i', pr
}
di in smcl in gr "{hline 13}{c +}{hline 64}"
_diparm lambda_1, f(@^2+`scale'^2) d(2*@) pr label(Var(e_y))
di in smcl in gr "{hline 13}{c +}{hline 64}"
di as text "Wald test for H0: rho_{s,y}=rho_{s,mcv}=0"
di _skip(12)
di as text _col(41) as txt "chi2 = " as res `fmt' `Wrho' /*
*/ in gre "  " " Prob > chi2 = "  in ye %5.4f `pWrho'
di in smcl in gr "{hline 13}{hline 65}"
#delimit ;
di as text "Note: Main response is continuous  and the missing covariate is in theory and";
di as text "practice an ordinal variable. Eqn for selection is reported in the top panel. ";
di as text "Eqn for main response  is reported  in second  from top panel. Coefficient on";
di as text "1(" as ye "mcovar = a" as text ")" as text " represents the effect of the" as ye " a "
as text "category of the missing covariate";
di as text "on the main response (second from top panel).";
#delimit cr
end

program define WaldRho
version 7
tokenize "`0'"
tempname b V Wrho pWrho R q rho_12 rho_13 load_1 load_2 load_3 G g chi2 
matrix `b'= `1'
matrix `V' = `2'
local scale = `5'
local ncols = colsof(`b')
matrix `V'=`V'[(`ncols'-2)..(`ncols'),(`ncols'-2)..(`ncols')]
scalar `load_1' =`b'[1,`ncols'-2]
scalar `load_2' = `b'[1,`ncols'-1]
scalar `load_3' = `b'[1,`ncols']
scalar `rho_12' = (`load_1'*`load_2')/sqrt((`load_1'^2+`scale'^2)*(`load_2'^2+`load_3'^2+`scale'^2))
scalar `rho_13' = `load_3'/sqrt((1+`scale'^2)*(`load_2'^2+`load_3'^2+`scale'^2))
matrix `G'=J(1,2,0)
matrix `g'=J(2,3,0)
matrix `G'[1,1]=`rho_12'
matrix `G'[1,2]=`rho_13'
local junk "sqrt((`load_1'^2+`scale'^2)*(`load_2'^2+`load_3'^2+`scale'^2))"
local junk1 "(`load_1'^2+`scale'^2)"
local junk2 "(`load_2'^2+`load_3'^2+`scale'^2)"
matrix `g'[1,1]= (`load_2'*`junk'-`load_1'^2*`load_2'*`junk2'*`junk'^(-1))/`junk'^2
matrix `g'[1,2]= (`load_1'*`junk'-`load_1'*`load_2'^2*`junk1'*`junk'^(-1))/`junk'^2
matrix `g'[1,3]= (-`load_1'*`load_2'*`load_3'*`junk1'*`junk'^(-1))/`junk'^2
local junk "sqrt((1+`scale'^2)*(`load_2'^2+`load_3'^2+`scale'^2))"
local junk1 "(1+`scale'^2)"
local junk2 "(`load_2'^2+`load_3'^2+`scale'^2)"
matrix `g'[2,2]= (-`load_3'*`load_2'*`junk1'*`junk'^(-1))/`junk'^2
matrix `g'[2,3]= (`junk'-`load_3'^2*`junk1'*`junk'^(-1))/`junk'^2
/* Get covariance matrix for rho_1 and rho_2 --- Delta method */
mat `V'=`g'*`V'*`g''
/* Now do the wald test */
matrix `R'=J(2,2,0)
matrix `q'=J(2,1,0)
local i=1
forval i = 1/2 {
 matrix `R'[`i',`i']=1
}
matrix `chi2'=(`R'*`G''-`q')'*syminv(`R'*`V'*`R'')*(`R'*`G''-`q')
scalar `3' = `chi2'[1,1]
scalar `4' = chiprob(2,`3')
end

program define eRho
version 7
tokenize "`0'"
tempname b V Wrho pWrho R q rho_12 rho_13 load_1 load_2 load_3 G g chi2 
matrix `b'= `1'
matrix `V' = `2'
local scale = `6'
local ncols = colsof(`b')
matrix `V'=`V'[(`ncols'-2)..(`ncols'),(`ncols'-2)..(`ncols')]
scalar `load_1' =`b'[1,`ncols'-2]
scalar `load_2' = `b'[1,`ncols'-1]
scalar `load_3' = `b'[1,`ncols']
scalar `rho_12' = (`load_1'*`load_2')/sqrt((`load_1'^2+`scale'^2)*(`load_2'^2+`load_3'^2+`scale'^2))
scalar `rho_13' = `load_3'/sqrt((1+`scale'^2)*(`load_2'^2+`load_3'^2+`scale'^2))
matrix `G'=J(1,2,0)
matrix `g'=J(2,3,0)
matrix `G'[1,1]=`rho_12'
matrix `G'[1,2]=`rho_13'
local junk "sqrt((`load_1'^2+`scale'^2)*(`load_2'^2+`load_3'^2+`scale'^2))"
local junk1 "(`load_1'^2+`scale'^2)"
local junk2 "(`load_2'^2+`load_3'^2+`scale'^2)"
matrix `g'[1,1]= (`load_2'*`junk'-`load_1'^2*`load_2'*`junk2'*`junk'^(-1))/`junk'^2
matrix `g'[1,2]= (`load_1'*`junk'-`load_1'*`load_2'^2*`junk1'*`junk'^(-1))/`junk'^2
matrix `g'[1,3]= (-`load_1'*`load_2'*`load_3'*`junk1'*`junk'^(-1))/`junk'^2
local junk "sqrt((1+`scale'^2)*(`load_2'^2+`load_3'^2+`scale'^2))"
local junk1 "(1+`scale'^2)"
local junk2 "(`load_2'^2+`load_3'^2+`scale'^2)"
matrix `g'[2,2]= (-`load_3'*`load_2'*`junk1'*`junk'^(-1))/`junk'^2
matrix `g'[2,3]= (`junk'-`load_3'^2*`junk1'*`junk'^(-1))/`junk'^2
/* Get covariance matrix for rho_1 and rho_2 --- Delta method */
mat `V'=`g'*`V'*`g''
scalar `3' = `rho_12'
scalar `4' = `rho_13'
matrix `5' = `V'
end
exit
