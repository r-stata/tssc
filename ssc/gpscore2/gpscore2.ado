/*
02-05-2013
ok questa versione la spediamo per il secondo invio.
Se vuoi vedere le modifiche apportate tra il primo e il secondo invio vedi
"C:\ado\plus\g\vecchi_ado_gpscore\gpscore2_02-05-2013.ado"


Program: Generalized Propensity Score
INPUT
cavariates

Compulsory options: 
t(varname) 	 = Name of the treatment variable
gpscore(string)  = Name of the variable which contains the estimated gps
predict(string)  = Name of the variable which contains the hat treatment values
sigma(string)    = Name of the variable which contains the estimated standard deviation of the gpscore model

Cutpoints = numeric variable. It categorizes the treatment variable using the percentiles values of varname as category cutpoints
Index     = String variable. It identifies the mean or the percentile to which referring inside each class of treatment.
nq_gps    = requires, as input, a number between 1 and 100 that is the quantile according to which divide gpscore 
		range conditional to the index string of each class of treatment.
family(string) = name of distribution family
link(string) = link function


Uncompulsory options

test_varlist = Cavariates for the balancing test
t_transf = Trasformation of the treatment variable 
Transformations:
		NULL    = original variable (or pre-defined trasformation)
	 	ln      = Logarithmic trasformation
		lnskew0 = ln(+/-Treatment - k) where k and the sign of Treatment are chosen 
			    so that the skewness of newvar is zero.
		bcskew0 = (Treatment ^L - 1)/L, the Box-Cox power transformation, choosing L so that the skewness of
			    the trasformation is zero.  (Treatment must be strictly positive)
		boxcox  = finds the maximum likelihood estimates of the parameters of the Box-Cox transform,

normal_test = Test on the normality of the residuals of the regression: Treatment = X*Beta + Epsilon, which can be performed only if family(normal)
Type of test:
		ksmirnov -- Kolmogorov-Smirnov equality-of-distributions test
		swilk    -- Shapiro-Francia tests for normality
	      sfrancia -- Shapiro-Wilk tests for normality
	      sktest   -- Skewness and kurtosis test for normality

norm_level(real 0.05) = Significance level of test on the normality 

test = type of balancing test (t_test or bayes factor)
flag_b(#) = skips either balancing or normal test or both, takes as arguments 0; 1; 2. If not specified in the commands estimates the GPS without performing both the balancing and the normal test
flag_b(0) skips both the balancing and the normal test
flag_b(1) skips the balancing test 
flag_b(2) skips the normal test

opt_nb(string) = negative binomial dispersion parameter. In the GLM approach you specify fam(nb #k) where #k is specified through the option opt_nb. The GLM then searches for #k that results in the deviance-based dispersion being 1. Instead, nbreg finds the ML estimate of #k.

opt_b(varname) = name of the variable which contains the number of binomial trials

Remark: If the DETail option is specified, the results of the regression model estimation are shown

OUTPUT
The estimated gpscore, stored in gpscore(string)

The fitted values of the treatment variable, stored in predict(string)

The GLM estimate of the conditional standard error of the
treatment given the covariates, obtained from Pearson residuals stored in sigma(string). Recall that in the case of normal distribution Pearson dispersion coincides with dispersion.


*/


program define gpscore2
version 10.0

#delimit ;
syntax  varlist [if] [in] [fweight iweight pweight], 
t(varname)
gpscore(string) 
predict(string) 
sigma(string) 
family(string)
link(string)
cutpoints(varname numeric)
index(string)
nq_gps(numlist)
[ 
t_transf(string)
normal_test(string)
norm_level(real 0.05)
test_varlist(varlist)
test(string) 
flag_b(string)
opt_nb(string) 
opt_b(varname)
DETail 
]
;
#delimit cr
display in ye _newline(1) "Generalized Propensity Score"


/*If weights are specified, create local variable*/

if "`weight'" != ""{
tempvar wei 
qui gen double `wei' `exp'
local w [`weight' = `wei']
}

tokenize `varlist'
marksample touse

local k: word count `varlist'

confirm new variable `gpscore'
confirm new variable `predict'
confirm new variable `sigma'
*confirm new variable `family'
*confirm new variable `link'




tempvar treat min_t min_t_0
qui gen `treat' = `t' if `touse'
qui sum `t' 
qui scalar `min_t' =r(min)

qui sum `t' if `t'>=0
qui scalar `min_t_0' =r(min)


	if !("`t_transf'"=="" | "`t_transf'"=="ln" | "`t_transf'"=="lnskew0" | "`t_transf'"=="bcskew0" | "`t_transf'"=="boxcox") {
		di as error "Transformation `t_transf' not recognized"
		exit 198
	}

	if ("`t_transf'"=="") {
		}

	if ("`t_transf'"=="ln") {
	/*di _newline(1) in ye "Logarithmic transformation"*/
	if(`min_t'<0){
	di as error "The Logarithmic transformation cannot be applied: `t' contains observations that are not positive"
	}
	else{
	qui replace `treat'= ln(`t') if `touse'
	if(`min_t_0'==0){
	di "By agreement we assume that the logarithm of 0 is 0"
	}
	qui replace `treat'= 0       if `touse' & `t'==0
	}
	}

	if ("`t_transf'"=="lnskew0") {
	/*di _newline(1) in ye "Zero-skewness log transformation"*/
	qui lnskew0 ln_t = `t' if `touse'
	local K = r(gamma)
	local skew = r(skewness)
	tempvar aux1 aux2 sign
	qui gen `aux1' = ln(`t' - `K')
	qui gen `aux2' = ln(-`t' - `K')
	qui gen `sign' = 1      if `aux1' == ln_t
	qui replace `sign' = -1 if `aux2' == ln_t
	qui replace `treat'= ln_t  if `touse'
	drop ln_t
	}

	if ("`t_transf'"=="bcskew0") {
	/*di _newline(1) in ye "Zero-skewness Box Cox transformation"*/
	if(`min_t'<0){
	di as error "The Zero-skewness Box Cox transformation cannot be applied: `t' contains observations that are negative"
	}
	else{
      if(`min_t_0'==0){
	di "We assume that bcskew0 of t = 0 is: -1/(lambda) if lambda>0 & 0 if lambda=0"
	}
	qui bcskew0 bc_t = `t' if `touse'
	local Lambda = r(lambda)
	qui replace `treat'= bc_t        if `touse' & `treat'>0
	qui replace `treat'= -1/`Lambda' if `touse' & `treat'==0 & `Lambda'!=0
	qui replace `treat'= 0           if `touse' & `treat'==0 & `Lambda'==0
	drop bc_t
	}
	}

	if ("`t_transf'"=="boxcox") {
	/*di _newline(1) in ye "Box Cox transformation"*/
	qui boxcox `t' `varlist' [`weight'`exp'] if `touse' & `t' >0
	local L = r(est)
	if(`min_t'<0){
	di as error "The Box Cox transformation cannot be applied: `t' contains observations that are negative"
	}
	else{
	if(`min_t_0'==0){
	di "We assume that boxcox of t = 0 is: -1/(L) if L>0 & 0 if L=0"
	}
	qui replace `treat'= (`t'^`L' - 1)/`L' if `touse' & `treat'>=0 & `L'!=0
	qui replace `treat'= ln(`t')           if `touse' & `treat'>0 & `L'==0
	qui replace `treat'= 0          	   if `touse' & `treat'==0 & `L'==0
	}
	}


if `"`detail'"' == `""'  { 
   local qui "quietly"
}
di in ye _newline(1) "******************************************************"
di in ye	     	   "Algorithm to estimate the generalized propensity score "
di in ye	     	   "****************************************************** "


di _newline(3) "Estimation of the propensity score "

if ("`t_transf'"=="") {
di _newline(2) in ye "The treatment is `t'"
}
if ("`t_transf'"=="ln") {
di _newline(1) in ye "The log transformation of the treatment variable `t' is used"
}

if ("`t_transf'"=="lnskew0") {
di _newline(1) in ye "The Zero-skewness log transformation of the treatment variable `t' is used"
}
if ("`t_transf'"=="bcskew0") {
di _newline(1) in ye "The Zero-skewness BoxCox transformation of the treatment variable `t' is used"
}

if ("`t_transf'"=="boxcox") {
di _newline(1) in ye "The BoxCox transformation of the treatment variable `t' is used"
}

qui gen T = `treat' if `touse'



**************************************************
*HERE BEGINS THE GLM ESTIMATE
**************************************************


sum T if `touse', det


glm  T `varlist' [`weight'`exp'] if `touse', `noconstant' family(`family' `opt_nb'  `opt_b') link(`link') nolog robust
dis "robust standard errors reported"


qui gen double `sigma' = sqrt(e(dispers_p))
/*NB: this sigma is slightly different from that obtained from ML. Indeed, the latter is the sd of the squared residuals divided by N times (N-1)/N, i.e. sqrt(u'u/N)*((N-1)/N). The GLM sigma is sqrt of the sum of squared residuals over N-K, i.e. sqrt[u'u/(N-K)]. This is computed by retrieving e(dispers) which is the sum of squared residuals devided by N-K. The difference is very tiny and explains the different results in the gpscore between BM's and ours. Moreover, following Wooldridge's hint we retrieve the Pearson rediduals, where the latter are given by u_p=u/mu => e(dispers) is replaced by e(dispers_p). See Wooldridge's email 24-04-2012 stating that as a measure of SE of y|x you must use the Pearson residuals.
*/



tempvar mu res_etreat theta a_theta  k c fam 

qui predict double `mu'                    if e(sample) & `touse', mu

* the option mu (not strictly necessary because assumed by Stata if not otherwise stated) is essential to predict y_hat taking into account the non linear relationship between y and X*beta. In orther words it is g^-1, the inverse link funtion.


qui scalar `fam' = e(varfunct)  		  




if `fam' == "Gaussian"{
	qui predict double `res_etreat'                    if e(sample) & `touse', p		
	qui 	sum `res_etreat'
	qui gen `gpscore'=normalden(`res_etreat'/`sigma')/`sigma'
        
}
else if `fam' == "Poisson"{
        qui gen `gpscore' =exp((T*ln(`mu')-`mu')-lnfactorial(T))
}
else if `fam' == "Gamma" {
	gen `theta' = - 1/`mu'
	gen `a_theta' = - ln(-`theta')
    	qui gen `gpscore' = exp((T* `theta')- `a_theta') 
	
}
else if `fam' =="Inverse Gaussian" {
	gen `c' =sqrt(1/(2*_pi*T^3))
	qui gen `gpscore' = `c'*exp(-((T-`mu')^2)/(2*T*`mu'^2)) 
	
}
else if `fam' =="Neg. Binomial" {
        gen `k' = real(e(a)) 
        gen `theta' = ln((`k'* `mu')/(1+(`k'* `mu'))) 
        gen `a_theta' = (-1/`k')*ln(1-(`k'*exp(`theta'))) 
     	qui gen `gpscore' = exp(T*`theta1'-`a_theta') 
	qui gen k_nb = `k'

}
else if (`fam'  =="Binomial" & "`opt_b'" =="") {         		
	qui gen `gpscore'=`mu'
}	
else if (`fam'  =="Binomial" & "`opt_b'" !="") {         		
	qui gen `gpscore'=`mu'/`opt_b'
}




label var `gpscore' "Estimated generalized propensity score"

qui gen double `predict' = `mu' 	if `touse'

sum `gpscore' if `touse', det 

local problem = 0
tempvar flag


if (`fam' == "Gaussian" & "`flag_b'" == "2"){
gen `flag' = 0 
}
else if (`fam' == "Gaussian" & "`flag_b'" == "1" ){
qui gen res_etreat=`res_etreat' 
gen `flag' = 1 
}
else if (`fam' == "Gaussian" & "`flag_b'" == "" ){
qui gen res_etreat=`res_etreat' 
gen `flag' = 1 
}
else if (`fam' == "Gaussian" & "`flag_b'" == "0" ){
gen `flag' = 0 
}
else {
gen `flag' = 0
}

if(`flag' == 1){
di _newline(1) in ye "Test for normality of the disturbances"

/* Normal Test */

	if !("`normal_test'"=="" | "`normal_test'"=="ksmirnov" | "`normal_test'"=="sktest" | "`normal_test'"=="swilk" | "`normal_test'"=="sfrancia") {
		di as error "Normal Test `normal_test' not recognized"
		exit 198
	}

	if ("`normal_test'"=="" | "`normal_test'"=="ksmirnov") {
	di _newline(1) in ye "Kolmogorov-Smirnov equality-of-distributions test"
	di 			   "Normal Distribution of the disturbances"
	if ("`normal_test'"==""){
	 local normal_test "ksmirnov"
	}
	 qui sum  res_etreat if `touse' 
	`qui' ksmirnov res_etreat = normal((res_etreat - r(mean))/sqrt(r(Var))) 
	 if r(p) < `norm_level'  { 
			  local problem = 1
			}
	}
	
	if ("`normal_test'"=="sktest") {
	di _newline(1) in ye "Skewness and kurtosis test for normality"
	`qui' sktest  res_etreat if `touse' 
		 if r(P_chi2) < `norm_level'  { 
		  local problem = 1
		}
	}

	if ("`normal_test'"=="swilk") {
	di _newline(1) in ye "Shapiro-Wilk tests for normality"
	`qui' swilk res_etreat if `touse' 
		 if r(p) < `norm_level' { 
			  local problem = 1
		}
	}

	if ("`normal_test'"=="sfrancia") {
	di _newline(1) in ye "Shapiro-Francia tests for normality"
	`qui' sfrancia res_etreat if `touse' 
		 if r(p) < `norm_level' { 
		  local problem = 1
		}
	}

if `problem' == 0 {
	di _newline(1) in green "The assumption of Normality is statistically satisfied at `norm_level' level"
}
else{
	di _newline(1) in red "The assumption of Normality is not statistically satisfied at `norm_level' level"
	di			    "It is advisable to try a different trasformation of the treatment variable"
	di			    "Or different family and link options"
	 } 
drop res_etreat
} /*End if "Flag"*/






di in ye _newline(1) "******************************************** "
di                   "End of the algorithm to estimate the gpscore "
di                   "******************************************** "



if(("`flag_b'" == "")| ("`flag_b'" == "2")){

*******************************************************************
*We split the treatment range in sub - intervals
*The bounds of each treatment sub-interval are given by "cutpoints
******************************************************************

tempvar broken_t
qui xtile `broken_t' = `t' if `touse', cutpoints(`cutpoints')
qui tab `broken_t' if `touse', gen(broken_t) 
local nblock_t = r(r)


di in ye _newline(1) "******************************************************************************"
di                   "The set of the potential treatment values is divided into `nblock_t' intervals"
/*di                   "********************************************** "*/


if("`index'" == "mean"){
local i = 1
while(`i' <= `nblock_t'){
tempvar mean_t_`i'  
tempvar transf_mean_t_`i' 
qui sum `t' if broken_t`i' ==1 & `touse'
qui gen `mean_t_`i'' = r(mean)
qui gen `transf_mean_t_`i'' = r(mean)

if `fam' == "Gaussian" & "`link'" == "id" {

	if ("`t_transf'"=="") {
		}

	if ("`t_transf'"=="ln") {
	qui replace `transf_mean_t_`i''= ln(`mean_t_`i'') if `touse'==1 &  `mean_t_`i''>0
	qui replace `transf_mean_t_`i''= 0                if `touse'==1 &  `mean_t_`i''==0
	}

	if ("`t_transf'"=="lnskew0") {
	qui replace `transf_mean_t_`i'' = ln(`sign'*`mean_t_`i'' - `K') if `touse' ==1
	}

	if ("`t_transf'"=="bcskew0") {
	qui replace `transf_mean_t_`i'' =(`mean_t_`i''^`Lambda' - 1)/`Lambda' if `touse' ==1 & `Lambda'!= 0 &  `mean_t_`i''>=0
	qui replace `transf_mean_t_`i'' =ln(`mean_t_`i'')                     if `touse' ==1 & `Lambda'== 0 &  `mean_t_`i''>0
	qui replace `transf_mean_t_`i'' =0			              if `touse' ==1 & `Lambda'== 0 &  `mean_t_`i''==0
	}

	if ("`t_transf'"=="boxcox") {
	qui replace `transf_mean_t_`i'' =(`mean_t_`i''^`L' - 1)/`L' 	    if `touse' ==1 & `L'!= 0 &  `mean_t_`i''>=0
	qui replace `transf_mean_t_`i'' =ln(`mean_t_`i'')                     if `touse' ==1 & `L'== 0 &  `mean_t_`i''>0
	qui replace `transf_mean_t_`i'' =0			                      if `touse' ==1 & `L'== 0 &  `mean_t_`i''==0
	}
}


*************************************************************************

tempvar gpscore_`i' c1


if `fam' == "Gaussian"{
	qui gen `gpscore_`i''=normalden(`transf_mean_t_`i'', `mu', `sigma') if `touse'
}

else if `fam' == "Poisson"{
        qui gen `gpscore_`i''=exp((`transf_mean_t_`i''*ln(`mu')-`mu')-lnfactorial(`transf_mean_t_`i'')) if `touse'
}

else if `fam' == "Gamma" {
    	qui gen `gpscore_`i''= exp((`transf_mean_t_`i''*`theta')- `a_theta')  if `touse'
}

else if `fam' =="Inverse Gaussian" {
	gen `c1' =sqrt(1/(2*_pi*`transf_mean_t_`i''^3)) 

/*c1 contains T, for this reason it cannot be dropped and we substitute c with c1*/

	qui gen `gpscore_`i''= `c1'*exp(-((`transf_mean_t_`i''-`mu')^2)/(2*`transf_mean_t_`i''*`mu'^2))  if `touse'
}

else if `fam' =="Neg. Binomial" {
     	qui gen `gpscore_`i''= exp(`transf_mean_t_`i''*`theta'-`a_theta')  if `touse'
}

else if `fam'  =="Binomial" & "`opt_b'" !=""{         		
	qui gen `gpscore_`i'' =`mu'/`opt_b' if `touse'
}	
else if `fam'  =="Binomial" & "`opt_b'" ==""{         		
	qui gen `gpscore_`i'' =`mu' if `touse'
}



*******************************************************
local i = `i' + 1
}
}

foreach x of numlist 1/100{
if("`index'" == "p`x'"){
local i = 1
while(`i' <= `nblock_t'){
tempvar p`x'_t_`i'  
tempvar transf_p`x'_t_`i' 
qui egen `p`x'_t_`i'' = pctile(`t')   if  broken_t`i' ==1 & `touse', p(`x')
qui sum `p`x'_t_`i'' 
qui replace `p`x'_t_`i''  = r(mean)
qui gen `transf_p`x'_t_`i'' = `p`x'_t_`i''  

if `fam' == "Gaussian" & "`link'" == "id" {

	if ("`t_transf'"=="") {
		}

	if ("`t_transf'"=="ln") {
	qui replace `transf_p`x'_t_`i''= ln(`p`x'_t_`i'') if `touse'==1 &  `p`x'_t_`i''>0
	qui replace `transf_p`x'_t_`i''= 0                if `touse'==1 &  `p`x'_t_`i''==0
	}

	if ("`t_transf'"=="lnskew0") {
	qui replace `transf_p`x'_t_`i'' = ln(`sign'*`p`x'_t_`i'' - `K')
	}

	if ("`t_transf'"=="bcskew0") {
	qui replace `transf_p`x'_t_`i'' =(`p`x'_t_`i''^`Lambda' - 1)/`Lambda' if `touse' ==1 & `Lambda'!= 0 &  `p`x'_t_`i''>=0
	qui replace `transf_p`x'_t_`i''=ln(`p`x'_t_`i'')                      if `touse' ==1 & `Lambda'== 0 &  `p`x'_t_`i''>0
	qui replace `transf_p`x'_t_`i'' =0			                      if `touse' ==1 & `Lambda'== 0 &  `p`x'_t_`i''==0

	}

	if ("`t_transf'"=="boxcox") {
	qui replace `transf_p`x'_t_`i'' =(`p`x'_t_`i''^`L' - 1)/`L'		    if `touse' ==1 & `L'!= 0 &  `p`x'_t_`i''>=0
	qui replace `transf_p`x'_t_`i''=ln(`p`x'_t_`i'')                      if `touse' ==1 & `L'== 0 &  `p`x'_t_`i''>0
	qui replace `transf_p`x'_t_`i'' =0			                      if `touse' ==1 & `L'== 0 &  `p`x'_t_`i''==0
	}
}

tempvar gpscore_`i' std_p`x'_t_`i' c1


if `fam' == "Gaussian"{
	qui gen `gpscore_`i''=normalden(`transf_p`x'_t_`i'', `mu', `sigma') if `touse'
}

else if `fam' == "Poisson"{
        qui gen `gpscore_`i''=exp((`transf_p`x'_t_`i''*ln(`mu')-`mu')-lnfactorial(`transf_p`x'_t_`i'')) if `touse'
}

else if `fam' == "Gamma" {
    	qui gen `gpscore_`i''= exp((`transf_p`x'_t_`i''*`theta')- `a_theta')  if `touse'
}

else if `fam' =="Inverse Gaussian" {
	gen `c1' =sqrt(1/(2*_pi*`transf_p`x'_t_`i''^3)) 
	qui gen `gpscore_`i''= `c1'*exp(-((`transf_p`x'_t_`i''-`mu')^2)/(2*`transf_p`x'_t_`i''*`mu'^2))  if `touse'
}

else if `fam' =="Neg. Binomial" {
     	qui gen `gpscore_`i''= exp(`transf_p`x'_t_`i''*`theta'-`a_theta')  if `touse'
}

else if `fam'  =="Binomial" & "`opt_b'" != ""{         		
	qui gen `gpscore_`i'' =`mu'/`opt_b' if `touse'
}	
else if `fam'  =="Binomial" & "`opt_b'" == ""{         		
	qui gen `gpscore_`i'' =`mu' if `touse'
}	



local i = `i' + 1
}
}
}



*********************************************************************
*We split the gpscore in nq_gps sub-classes in each treatment class 
*********************************************************************

/*di in ye _newline(1) "**************************************************************** "*/
di in ye _newline(1)   "The values of the gpscore evaluated at the representative point of each 
di			     "treatment interval are divided into `nq_gps' intervals"
di                     "******************************************************************************"


local i = 1
while(`i' <= `nblock_t'){
tempvar broken_gps_`i'  
qui xtile  `broken_gps_`i''   = `gpscore_`i''  if  broken_t`i' ==1 & `touse', n(`nq_gps')

local j = 1
while(`j' <= `nq_gps'){
tempvar min_`i'`j'  
tempvar max_`i'`j'
qui sum `gpscore_`i''  if `broken_gps_`i'' == `j' & `touse'
qui gen `max_`i'`j'' = r(max)
local j = `j' + 1
}

qui replace `broken_gps_`i'' = 1  if  `gpscore_`i'' <= `max_`i'1'  & `broken_gps_`i'' == . & `touse'
local j = 2
while(`j' <= `nq_gps'){
local k = `j'-1
qui replace `broken_gps_`i'' = `j'  if `gpscore_`i'' > `max_`i'`k'' & `gpscore_`i'' <= `max_`i'`j''  & `broken_gps_`i'' == . & `touse'
local j = `j' + 1
}

local i = `i' + 1
}




***************************************************************
*BEGINNING OF TEST THAT THE PROPENSITY SCORE IS NOT DIFFERENT
***************************************************************

di in ye _newline(1) "***********************************************************"
di                   "Summary statistics of the distribution of the GPS evaluated" 
di                   "at the representative point of each treatment interval"      
di                   "***********************************************************"


if `"`detail'"' != `""'{
local i = 1
while(`i' <= `nblock_t'){
qui gen gps_`i' = `gpscore_`i'' 
sum gps_`i'  
drop gps_`i'
local i = `i' + 1
}
}

di in ye _newline(2) "************************************************************************************"
di                   "Test that the conditional mean of the pre-treatment variables given the generalized "
di			   "propensity score is not different between units who belong to a particular treatment"
di			   "interval and units who belong to all other treatment intervals"
di                   "************************************************************************************"

	if !("`test'"=="" | "`test'"=="t_test" | "`test'"=="Bayes_factor" ) {
		di as error "Balancing Test `test' not recognized"
		exit 198
	}


	local test_varlist `test_varlist'
	if ("`test_varlist'"=="") {
		local test_varlist `varlist'
		}

local i = 1
while(`i' <= `nblock_t'){ /*Begin "while" on treatment classes*/
foreach x of varlist `test_varlist'{
tempvar diff_`x'_`i' var_diff_`x'_`i'  Nt_`x'_`i' Nc_`x'_`i'
qui gen `diff_`x'_`i'' = 0
qui gen `var_diff_`x'_`i'' = 0 
qui gen `Nt_`x'_`i'' = 0
qui gen `Nc_`x'_`i'' = 0 
}

local j = 1
while(`j' <= `nq_gps'){ /*Begin "while" on gpscore sub-classes in each treatment class*/
foreach x of varlist `test_varlist'{
qui ttest `x' if  `broken_gps_`i'' ==`j' , by(broken_t`i') 
qui replace `diff_`x'_`i'' = `diff_`x'_`i'' + ((r(N_1) + r(N_2))/_N)*(r(mu_1) - r(mu_2))
qui replace `var_diff_`x'_`i'' = `var_diff_`x'_`i''  +  (((r(N_1) + r(N_2))/_N)^2)*(r(se)^2)
qui replace  `Nt_`x'_`i'' = `Nt_`x'_`i''  + ((r(N_1) + r(N_2))/_N)*r(N_2)
qui replace  `Nc_`x'_`i'' = `Nc_`x'_`i''  + ((r(N_1) + r(N_2))/_N)*r(N_1) 
}
local j = `j' +1
}/*End "while" on gpscore sub-classes in each treatment class*/
foreach x of varlist `test_varlist'{
tempvar se_diff_`x'_`i'  t_diff_`x'_`i'  BF_`x'_`i'
qui gen `se_diff_`x'_`i'' = sqrt(`var_diff_`x'_`i'')
qui gen `t_diff_`x'_`i'' = `diff_`x'_`i''/`se_diff_`x'_`i''
qui gen `BF_`x'_`i'' = (3/2)*sqrt((`Nt_`x'_`i''*`Nc_`x'_`i'')/(`Nt_`x'_`i'' + `Nc_`x'_`i''))*((1+ ((`t_diff_`x'_`i'')^2)/((`Nt_`x'_`i'' + `Nc_`x'_`i''-2)))^(-0.5*(`Nt_`x'_`i'' + `Nc_`x'_`i'')))
}
local i =`i' +1
}/*End "while" on treatment classes*/


if ("`test'"=="" | "`test'"=="t_test") {/*Begin "if" t - test*/
tempvar t_max
qui gen `t_max'= 0


local i = 1
while(`i' <= `nblock_t'){ /*Begin "while" on treatment classes*/
qui sum `t' if broken_t`i'==1
local tmin = r(min)
local tmax = r(max)
if `"`detail'"' != `""'{
di ""
`quietly' di as text    "Treatment Interval No `i' - [`tmin', `tmax']"   
`quietly' di ""
`quietly' di as text    "               Mean "          "       Standard   " 
`quietly' di as text    "               Difference"     "  Deviation   "   "t-value"   
 `quietly' di ""
}

tempvar t_max`i'
qui gen `t_max`i''= 0

foreach x of varlist `test_varlist'{
if `"`detail'"' != `""'{
`quietly' di as text %12s abbrev("`x'            ",12) "  " as result %7.0g `diff_`x'_`i'' "      " as result %7.0g `se_diff_`x'_`i''      "    " as result %7.0g `t_diff_`x'_`i''  
`quietly' di ""    
}

qui replace `t_max`i''= abs(`t_diff_`x'_`i'') if  abs(`t_diff_`x'_`i'')>`t_max`i''
}
qui replace `t_max'= `t_max`i'' if  `t_max' < `t_max`i''

local i =`i' +1
}/*End "while" on treatment classes*/

 di _newline (1) "According to a standard two-sided t test:"

if(abs(`t_max') < 1.282){
 di _newline (1) "Evidence supports the balancing property"
 di _newline (1) "The balancing property is satisfied at level 0.20"
}

if(abs(`t_max') > 1.282 & abs(`t_max') < 1.645){
 di _newline (1) "Very slight evidence against the balancing property"
 di _newline (1) "The balancing property is satisfied at level 0.10"
}

if(abs(`t_max') > 1.645 & abs(`t_max') < 1.96){
 di _newline (1) "Moderate evidence against the balancing property"
 di _newline (1) "The balancing property is satisfied at level 0.05"
}

if(abs(`t_max') > 1.96 & abs(`t_max') < 2.576){
 di _newline (1) "Strong to very strong evidence against the balancing property"
 di _newline (1) "The balancing property is satisfied at level 0.01"
}


if(abs(`t_max') > 2.576){
 di _newline (1) "Decisive evidence against the balancing property"
 di _newline (1) "The balancing property is satisfied at a level lower than 0.01"
}

}

if ("`test'"=="Bayes_factor") { /*Begin "if" Bayes-Factor*/

tempvar BF_min
qui gen `BF_min'= .


local i = 1
while(`i' <= `nblock_t'){ /*Begin "while" on treatment classes*/
qui sum `t' if broken_t`i'==1
local tmin = r(min)
local tmax = r(max)
if `"`detail'"' != `""'{
di ""
`quietly' di as text    "Treatment Gruop No `i' - [`tmin', `tmax']"   
`quietly' di ""
`quietly' di as text    "               Mean "          "       Standard   " 
`quietly' di as text    "               Difference"     "  Deviation   "   "Bayes-Factor"   
 `quietly' di ""
}
tempvar BF_min`i'
qui gen `BF_min`i''= .

foreach x of varlist `test_varlist'{
if `"`detail'"' != `""'{
`quietly' di as text %12s abbrev("`x'            ",12) "  " as result %7.0g `diff_`x'_`i'' "      " as result %7.0g `se_diff_`x'_`i''      "    " as result %7.0g `BF_`x'_`i''  
`quietly' di ""    
}

qui replace `BF_min`i''= `BF_`x'_`i'' if  `BF_`x'_`i'' < `BF_min`i''
}

qui replace `BF_min'= `BF_min`i'' if  `BF_min' > `BF_min`i''

local i =`i' +1
} /*End "while" on treatment classes*/

 di _newline (1) "According to the Bayes Factor:"

if(`BF_min' > 1){
 di _newline (1) "Evidence supports the balancing property"
 di _newline (1) "Minimum bayes factor = " `BF_min' " >  1"
}

if(`BF_min' > sqrt(0.1) & `BF_min' < 1){
 di _newline (1) "Very slight evidence against the balancing property"
 di _newline (1) "Minimum bayes factor =" `BF_min' " in (0.316; 1)"
}

if(`BF_min' > 0.1 & `BF_min'< sqrt(0.1)){
 di _newline (1) "Moderate evidence against the balancing property"
 di _newline (1) "Minimum bayes factor =" `BF_min' " in (0.1; 0.316)"
}

if(`BF_min' > 0.01 & `BF_min' < 0.10){
 di _newline (1) "Strong to very strong evidence against the balancing property"
 di _newline (1) "Minimum bayes factor =" `BF_min' " in (0.01; 0.1)"
}

if(`BF_min'< 0.01){
 di _newline (1) "Decisive evidence against the balancing property"
 di _newline (1) "Minimum bayes factor =" `BF_min' " < 0.01"
}

}/*End "if" BF*/


drop broken_t*

} /*End "if" flag*/


qui scalar fam = `fam'


/* this line is essential to allow the program doseresponse2 to withdraw family from gpscore2 */

drop T
end

