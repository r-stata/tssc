*! Version 3.0
*! Author: Alfonso Miranda
*! Date: 17.12.2009

program define setpoisson_ll
version 11
args todo b lnf g NegH
tempvar xb1 xb2 xb3  last vartype edv ssv ordv
#delimit ;
 tempname
 lambda_1 lambda_2    /* 6 equations */
 sigma_u
 lambdaM
 Vu lf hvec;
#delimit cr
local Vs `Vu'
local xb `xb1' `xb2' `xb3'
local nex1_il =$S_snex1_il
local nex2_il =$S_snex2_il
local nex3_il =$S_snex3_il
local nscores = 6
local lambda `lambda_1' `lambda_2'
local sigma_u `sigma_u'
local id "$S_id"
local rep "$S_rep"
local endogvs "$S_endogvs"
local method "$S_method"
local samp   "$ML_samp"
local vartype "$S_vartype"
local resp "$S_resp"
local k = 0
scalar `lf' = .
foreach v in `xb' {
 mleval `v' = `b', eq(`++k')
}
foreach v in `lambda' {
 mleval `v' = `b', scalar eq(`++k')
}
foreach v in `sigma_u' {
 mleval `v' = `b', scalar eq(`++k')
}

qui sort $S_id $S_vartype
qui gen `edv'=cond(`vartype'==1,1,0)
qui gen `ssv'=cond(`vartype'==2,1,0)
qui gen `ordv'=cond(`vartype'==3,1,0)
qui sort $S_id
qui by $S_id : gen `last' = cond(_n==_N,1,0)
qui {
 by $S_id: replace `xb1'=. if `edv'==0 & `samp'
 by $S_id: replace `xb2'=. if `ssv'==0 & `samp'
 by $S_id: replace `xb3'=. if `ordv'==0 & `samp'
}

/* ensure that variance of y is within admisible range */

if (`sigma_u' < -20) scalar `sigma_u' = -20
if (`sigma_u' >  20) scalar `sigma_u' =  20

/* generate some stuff for scores */

tempname c_sigma_u
scalar `c_sigma_u' = exp(`sigma_u')

/* ensure that SEs of y is positive */

scalar `sigma_u' = exp(`sigma_u')

/* prepare input matrices */

mat `lambdaM' =(`lambda_1',`lambda_2')
mat `Vs' = (`sigma_u')

/* prepare variables for scores */

local D ""
forval i=1/`nscores' {
 tempvar d`i'
 local D "`D' `d`i''"
 qui gen double `d`i'' = .
}

/* matrix hvec */

mat `hvec' = ($S_hv_1, $S_hv_2, $S_hv_3)

/* calculate log-likelihood */


tempvar pr
qui gen double `pr' = .
mata: setpoisson_v2d1("xb","resp","endogvs","vartype","`lambdaM'","id","Vs",`method',`rep',"`hvec'","`pr'","`D'","`samp'")
qui replace `pr' = log(`pr') if `samp'

mlsum `lnf' = `pr' if `last' & `samp'

if (`todo'==0 | `lnf'>=.) {
 matrix `g' = J(1,colsof(`b'),.)
 matrix `NegH' = J(colsof(`b'),colsof(`b'),.)
 exit
}

/* do final adjustment to D */

qui replace `d`nscores''  =  `d`nscores''*`c_sigma_u'

/* Calculate the scores at equation level and feed them to Stata */

tempvar g1 g2 g3
local j = `nscores' - 3
*local j = `nscores' - 2
local k_1 = `j' + 1
local k_2 = `k_1' + 1
local h = `k_2' + 1
tempvar g`k_1' g`k_2' g`h'
mlvecsum `lnf' `g1' = `d1' if `edv'==1, eq(1)                /* equations */
mlvecsum `lnf' `g2' = `d2' if `ssv'==1, eq(2)
mlvecsum `lnf' `g3' = `d3' if `ordv'==1, eq(3)
mlvecsum `lnf' `g`k_1'' = `d`k_1'' if `edv'==1, eq(`k_1')    /* lambdas */
mlvecsum `lnf' `g`k_2'' = `d`k_2'' if `ssv'==1, eq(`k_2')
mlvecsum `lnf' `g`h'' = `d`h'' if `last'==1, eq(`h')         /* sigma_u */

/* deliver matrix of first derivatives */

matrix `g' = (`g1',`g2',`g3')
matrix `g' = (`g',`g`k_1'',`g`k_2'',`g`h'')

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
if $S_sncedv == 1 {
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
if $S_sncssv==1 {
 local i = `i' + 1
 tempvar scores_x_2_`i'
 by $S_id: gen double `scores_x_2_`i'' = sum(`d2') if `samp'
 local scores_x_2 "`scores_x_2' `scores_x_2_`i''"
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
if $S_sncord==1 {
 local i = `i' + 1
 tempvar scores_x_3_`i'
 by $S_id: gen double `scores_x_3_`i'' = sum(`d3') if `samp'
 local scores_x_3 "`scores_x_3' `scores_x_3_`i''"
}
local scores "`scores' `scores_x_3'"

/* lambdas */

tempvar score_lambda_1 score_lambda_2
by $S_id: gen double `score_lambda_1' = sum(`d`k_1'') if `samp'
by $S_id: gen double `score_lambda_2' = sum(`d`k_2'') if `samp'
local scores "`scores' `score_lambda_1' `score_lambda_2'"

/* sigma_y */

tempvar score_sigma_u
by $S_id: gen double `score_sigma_u' = sum(`d`h'') if `samp'
local scores "`scores' `score_sigma_u'"

/* Keep the scores for future use */

local i = 1
tokenize $S_snames
foreach var of local scores {
 qui replace `1' = `var' if `samp'
 mac shift
}

if (`todo'==1 | `lnf'>=.) exit

/* Calculate OPG covariance matrix */

//qui matrix accum `NegH' = `scores' if `last' & `samp', noconst

tempvar tus
gen `tus' = (`last'==1 & `samp'==1)
mata: OPG("scores","tus","`NegH'")



end
