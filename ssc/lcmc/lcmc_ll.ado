*! Author: Alfonso Miranda (alfonso.miranda@cide.edu)
*! Center for Economic and Teaching Research (CIDE)
*! This version 7/03/2013

program define lcmc_ll
version 10.1
args todo b lnf g NegH
tempvar xb1 xb2 xb3 xb4 last group vartype edv mcvar yvar selvar
#delimit ;
 tempname
 lambda_1 lambda_2 lambda_3    /* 6 + ncuts equations */
 sigma_y
 thetaM
 kappaM
 lambdaM
 Vf lf bmv
 hvec;
#delimit cr
local Vs `Vf'
local xb `xb1' `xb2' `xb3'
local xbplus `xb1' `xb2' `xb3' `xb4'
local ncuts=$S_ncuts
local ncats=$S_ncats
local nex1 =$S_snex1
local nex2 =$S_snex2
local nex3 =$S_snex3
local nscores = 6 + `ncats' + `ncuts' 
local scale =$S_scale
local theta ""
forval x = 1/`ncats' {
 tempname theta`x'
 local theta "`theta' `theta`x''"
}
local kappa ""
forval x = 1/`ncuts' {
 tempname kappa`x'
 local kappa "`kappa' `kappa`x''"
}
local lambda `lambda_1' `lambda_2' `lambda_3'
local sigma_y `sigma_y'
local id "$S_id"
local rep "$S_rep"
local endogvs "$S_endogvs"
local method "$S_method"
local samp   "$ML_samp"
local vartype "$S_vartype"
local resp "$S_resp"
local Nyvar = $S_sNyvar
local k = 0
scalar `lf' = .
foreach v in `xb' {
 mleval `v' = `b', eq(`++k')
}
foreach v in `theta' {
  mleval `v' = `b', scalar eq(`++k')
}
foreach v in `kappa' {
  mleval `v' = `b', scalar eq(`++k')
}
foreach v in `lambda' {
 mleval `v' = `b', scalar eq(`++k')
}
foreach v in `sigma_y' {
 scalar `v' = `scale'
}
qui sort $S_id $S_vartype
qui gen `selvar'=cond(`vartype'==1,1,0)
qui gen `yvar'=cond(`vartype'==2,1,0)
qui gen `mcvar'=cond(`vartype'==3,1,0)
qui sort $S_id
qui by $S_id : gen `last' = cond(_n==_N,1,0)
qui by $S_id: gen `group' = (_n==2)
qui by $S_id: replace `group' = 1 if _n==3
qui {
 by $S_id: replace `xb1'=. if `selvar'==0 & `samp'
 by $S_id: replace `xb2'=. if `yvar'==0 & `samp'
 by $S_id: replace `xb3'=. if `mcvar'==0 & `samp'
}


/* ensure thetas are acceptable */

if ($S_threstr == 1) {
 local flag = 0
 forval x = 2/`ncats' {
  local j = `x' - 1 
  local flag = cond(`theta`x'' > `theta`j'',0,1) 
 }
 if (`flag'==1) {
  scalar `lnf'=.
  matrix `g' = J(1,colsof(`b'),.)
  matrix `NegH' = J(colsof(`b'),colsof(`b'),.)
  exit
 }
}

/* generate prediction for missing covariate in whole data using current values of coeff. */

mat `bmv' = `b'[1,(`nex1'+`nex2'+1)..(`nex1'+`nex2'+`nex3')]
mat score double `xb4' = `bmv'

/* prepare input matrices */

mat `lambdaM' =(`lambda_1',`lambda_2', `lambda_3')
mat `Vf' = (`sigma_y')
*mat Vf=.
mat `thetaM' = (`theta1')
forval x = 2/`ncats' {
  mat `thetaM' = (`thetaM', `theta`x'')
}
mat `kappaM' = (`kappa1')
forval x = 2/`ncuts' {
  mat `kappaM' = (`kappaM', `kappa`x'')
}

/* prepare variables for scores */

local D ""
forval i=1/`nscores' {
 tempvar d`i'
 local D "`D' `d`i''"
 qui gen double `d`i'' = .
}

/* matrix hvec */

mat `hvec' = ($S_hv_1, $S_hv_2, $S_hv_3, $S_hv_4)

/* calculate log-likelihood */

tempvar pr
qui gen double `pr' = .
#delimit ;
mata: mcvop_32_v2d1("xbplus","resp","endogvs","vartype","`lambdaM'","`thetaM'","`kappaM'","id",
 "Vs",`Nyvar',`method',`rep',"`hvec'","`pr'","`D'",`scale',"`samp'");
#delimit cr

qui replace `pr' = log(`pr') if `samp'
mlsum `lnf' = `pr' if `last' & `samp'


if (`todo'==0 | `lnf'>=.) {
 matrix `g' = J(1,colsof(`b'),.)
 matrix `NegH' = J(colsof(`b'),colsof(`b'),.)
 exit
}
/* Calculate the scores at equation level and feed them to Stata */

tempvar g1 g2 g3
mlvecsum `lnf' `g1' = `d1' if `selvar'==1, eq(1)   /* equations */
mlvecsum `lnf' `g2' = `d2' if `yvar'==1, eq(2) 
mlvecsum `lnf' `g3' = `d3' if `last'==1, eq(3)
local j = 3 + `ncats' 
forval i = 4/`j' {
 tempvar g`i'
 mlvecsum `lnf' `g`i'' = `d`i'' if `yvar'==1, eq(`i')        /* theta */
}
local k = `j' + 1
local j = `j' + `ncuts'
forval i = `k'/`j' {
 tempvar g`i'
 mlvecsum `lnf' `g`i'' = `d`i'' if `last'==1, eq(`i')        /* kappa */
}
local k_1 = `j' + 1
local k_2 = `j' + 2
local h = `j' + 3
tempvar g`k_1' g`k_2' g`h'
mlvecsum `lnf' `g`k_1'' = `d`k_1'' if `yvar'==1, eq(`k_1')    /* lambdas */
mlvecsum `lnf' `g`k_2'' = `d`k_2'' if `selvar'==1, eq(`k_2')
mlvecsum `lnf' `g`h'' = `d`h'' if `selvar'==1, eq(`h')         

/* deliver matrix of first derivatives */

matrix `g' = (`g1',`g2',`g3')
forval i = 4/`h' {
 matrix `g' = (`g',`g`i'')
}


/* Obtain the scores at variable level to calculate OPG approx to Variance */

local scores ""

/* calculate scores eqn 1 */

local scores_x_1 ""
local i = 1
foreach var of global S_x_1 {
 tempvar scores_x_1_`i'
 by $S_id: gen double `scores_x_1_`i'' = sum(`d1'*`var') if `samp'
 local scores_x_1 "`scores_x_1' `scores_x_1_`i''"
 local i = `i' + 1
}
if $S_sncselvar == 1 {
 local i = `i' + 1
 tempvar scores_x_1_`i'
 by $S_id: gen double `scores_x_1_`i'' = sum(`d1') if `samp'
 local scores_x_1 "`scores_x_1' `scores_x_1_`i''"
}
local scores "`scores' `scores_x_1'"

/* calculate scores eqn 2 */

local scores_x_2 ""
local i = 1
foreach var of global S_x_2 {
 tempvar scores_x_2_`i'
 by $S_id: gen double `scores_x_2_`i'' = sum(`d2'*`var') if `samp'
 local scores_x_2 "`scores_x_2' `scores_x_2_`i''"
 local i = `i' + 1
}
local scores "`scores' `scores_x_2'"

/* calculate scores eqn 3 */

local scores_x_3 ""
local i = 1
foreach var of global S_x_3 {
 tempvar scores_x_3_`i'
 by $S_id: gen double `scores_x_3_`i'' = sum(`d3'*`var') if `samp'
 local scores_x_3 "`scores_x_3' `scores_x_3_`i''"
 local i = `i' + 1
}
local scores "`scores' `scores_x_3'"

/* calculate scores theta */

local scores_theta ""
local j = 3 + `ncats' 
local bb = 1
forval i = 4/`j' {
 tempvar score_theta_`bb'
 by $S_id: gen double `score_theta_`bb'' = sum(`d`i'') if `samp'
 local scores_theta "`scores_theta' `score_theta_`bb''"
 local bb = `bb' + 1
}
local scores "`scores' `scores_theta'"

/* calculate scores kappas */

local scores_kappa ""
local bb = 1
local k = `j' + 1
local j = `j' + `ncuts'
forval i = `k'/`j' {
 tempvar score_kappa_`bb'
 by $S_id: gen double `score_kappa_`bb'' = sum(`d`i'') if `samp'
 local scores_kappa "`scores_kappa' `score_kappa_`bb''"
 local bb = `bb' + 1
}
local scores "`scores' `scores_kappa'"

/* lambdas */

tempvar score_lambda_1 score_lambda_2 score_lambda_3
by $S_id: gen double `score_lambda_1' = sum(`d`k_1'') if `samp'
by $S_id: gen double `score_lambda_2' = sum(`d`k_2'') if `samp'
by $S_id: gen double `score_lambda_3' = sum(`d`h'') if `samp'

local scores "`scores' `score_lambda_1' `score_lambda_2' `score_lambda_3' "

/* Keep the scores for future use */

local i = 1
tokenize $S_snames
foreach var of local scores {
 qui replace `1' = `var' if `samp'
 mac shift
}

if (`todo'==1 | `lnf'>=.) exit

/* Calculate OPG covariance matrix */

tempvar tus
gen `tus' = (`last'==1 & `samp'==1)
mata: OPG("scores","tus","`NegH'")
end



