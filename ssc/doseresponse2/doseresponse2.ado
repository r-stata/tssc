/* 

22-03-2013
ora pesca fam in forma scalare da gpscore2 e lo usa correttamente


21-03-2013
rispetto alla versione 24-05-2012
ho commentato le righe 
*confirm new variable `family'
*confirm new variable `link'


24-05-2012 
Versione ripulita rispetto al "doseresponse 19 si"

Program: dose_response
INPUT
cavariates

Compulsory options: 
outcome(varname) = Name of the outcome 
t(varname) 	     = Name of the treatment variable
gpscore(string)  = Name of the variable which contains the estimated gps
predict(string)  = Name of the variable which contains the hat treatment values
sigma(string)    = Name of the variable which contains the estimated standard deviation of the gpscore model

Cutpoints = numeric variable. It categorizes the treatment variable using the percentiles values of varname as category cutpoints
Index     = String variable. It identifies the mean or the percentile to which referring inside each class of treatment.
nq_gps    = requires, as input, a number between 1 and 100 that is the quantile according to which divide gpscore 
		range conditional to the index string of each class of treatment.

dose_response(string) = Name of the variable which contains the estimated values of the dose-response function

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


cmd		    = Logit/probit/ologit/oprobit/mlogit/mprobit/regression 
red_type_t      = Regression type in t (the treatment variable) "Linear" (the default) "Quadratic"  or "Cubic"
red_type_gps    = Regression type in gps (the gpscore) "Linear" (the default) "Quadratic"  or "Cubic"
interaction     = Binary variable which is equal to 1 (the default) if the model includes the interaction
		      between the treatment variable and the estimated gpscore

tpoints(varname numeric) = tpoints is a vector of treatment values where we evaluate the dose-response 
npoints(numlist) 		 = npoints is the number of points in the treatment range where we evaluate the dose-response 
delta				 = Treatment gap 

BOOTstrap   	     	 = Bootstraps the standard error of the dose response function
boot_reps			 = Number of bootstrap iterations
filename    		 = The name of the file where the output is saved

analysis			 = Graphics results
analysis_level		 = Confidence level for confidence bands  
graph 			 = The name of the file where the graphics output is saved

Remark: If the DETail option is specified, the results of the regression model estimation are shown
OUTPUT
Gpscore output

Dose response function  - It is stored in dose_response(string)
*/

program define doseresponse2
version 10.0

#delimit ;
syntax  varlist  [if] [in] [fweight iweight pweight],
outcome(varname)
t(varname) 
gpscore(string) 
predict(string) 
sigma(string) 
cutpoints(varname numeric)
index(string)
nq_gps(numlist)
family(string)
link(string)
dose_response(namelist)
[
test_varlist(varlist)
t_transf(string)
normal_test(string)
norm_level(real 0.05)
test(string) 
flag(int 1)
cmd(string) 
reg_type_t(string)
reg_type_gps(string)
interaction(int 1)
tpoints(namelist)
npoints(numlist)
delta(real 0)
BOOTstrap(string) 
boot_reps(int 50)
filename(string) 
analysis(string)
analysis_level(real 0.95) 
graph(string) 
flag_b(string)
opt_nb(string) 
opt_b(varname)
DETail 
]
;


#delimit cr 
/*If weights are specified, create local variable*/

if "`weight'" != ""{
tempvar wei 
qui gen double `wei' `exp'
local w [`weight' = `wei']
}

if !("`bootstrap'" == "" | "`bootstrap'"=="yes" | "`bootstrap'" == "no" ) {	
		di as error "Do you want bootstrap standard errors?"
		exit 198
	}


if "`weight'" != "" & "`bootstrap'" =="yes" { 

di "*********************************************************************************************************************"
di   "Warning: You are using weights in the estimation of the dose response standard error"
di   "together with the bootstrap option." 
di   "Note that the STATA command ''bsample'' we use to create bootstrap samples only allows"
di   "the use of frequency weights (fweight)."
di   "The user can also use either sampling weights (pweights) or importance weights (iweights), 
di   "but he/she has to keep in mind that the standard errors are calculated under the assumptions of random sampling."
di "*********************************************************************************************************************"
}

tokenize `varlist'
marksample touse
local k: word count `varlist'


	if ("`cmd'"==""){
				qui inspect `outcome' if `touse'
				local nuniq=r(N_unique)
				if `nuniq'==1 {
					noi di as err "only 1 distinct value of `outcome' found"
					exit 2000
				}
				if `nuniq'==2 {
					count if `outcome'==0 & `touse'==1
					if r(N)==0 | r(N)== _N{
						noi di as err "Binary variables must include at least one 0 and one 1"
						exit 198
					}
					local cmd logit
				}
				else if `nuniq'<=5 {
					local cmd mlogit
				}
				else local cmd regress
			}
			if "`cmd"=="mlogit" {
				* With mlogit, if outcome  carries a score label,
				* drop it since it causes prediction problems
				local outcome_lab: value label `outcome'
				capture label drop `outcome_lab'
			}



confirm new variable `gpscore'
confirm new variable `predict'
confirm new variable `sigma'
confirm new variable `dose_response'
*confirm new variable `family'
*confirm new variable `link'


if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
qui inspect `outcome'
local ncat = r(N_unique)
local nword: word count `dose_response'
if `nword' !=`ncat'{
di as error "The number of variables being to specify must be equals to the number of categories of the outcome variable ''`outcome'''"
if `nword' > `ncat'{
exit 103
}
if `nword' < `ncat'{
exit 102
}
}
}

di in green _newline(1) "********************************************"
di                      "ESTIMATE OF THE GENERALIZED PROPENSITY SCORE "
di                      "******************************************** "

#delimit ;
gpscore2 `varlist' `if' `in'  [`weight' `exp'], family(`family') link(`link')  
t(`t')
gpscore(`gpscore') 
nq_gps(`nq_gps') 
predict(`predict') 
sigma(`sigma') 
cutpoints(`cutpoints')
index(`index')
t_transf(`t_transf')
normal_test(`normal_test')
norm_level(`norm_level')
test_varlist(`test_varlist')
test(`test') 
flag_b(`flag_b')
opt_nb(`opt_nb')
opt_b(`opt_b')
`detail'
;
#delimit cr

* filename:
	capture confirm file `filename' 
	if _rc == 0 {
		if "`replace'" == "" {
			di as err "file `filename'  already exists"
			exit 602
		}
	}

tempvar flag_model
tempname B VB

if `"`detail'"' == `""'  { /* BEGINDETAIL */
   local qui "quietly"
} /* ENDDETAIL */

if `"`detail'"' != `""'  { /* BEGINDETAIL */
#delimit ;
`qui' 
doseresponse_model `t' `gpscore' `if' `in'  [`weight' `exp'], 
outcome(`outcome')
cmd(`cmd') 
reg_type_t(`reg_type_t')
reg_type_gps(`reg_type_gps')
interaction(`interaction')
;
#delimit cr
} /* ENDDETAIL */


qui gen `flag_model' = r(flag_model)

matrix def `B' = e(b)
matrix def `VB' = e(V)

if ("`npoints'"!="" & "`tpoints'"!="") {	
		di as error "You can not specify both the options tpoints and npoints"
		exit 198
	}

tempvar treatment_values  tag id_treat 
tempname tvector mat_aux 

qui gen `treatment_values'  = .
if ("`npoints'"=="" & "`tpoints'"=="") {
sort `t'
qui duplicates report  `t'
local ntreat_values = r(unique_value) 
qui duplicates tag `t', gen(`tag')
sort `t'
qui gen `id_treat'=.
qui replace  `id_treat' = 1 if `tag'==0
qui replace  `id_treat' = 1 if `tag'>0 & `t'[_n-1]!=`t'[_n]
qui replace `treatment_values' = `t' if `id_treat'==1
sort  `treatment_values' 
mkmat `treatment_values', matrix(`mat_aux')
matrix def `tvector' = `mat_aux'[1..`ntreat_values',1]
}

tempvar max_t min_t 

if ("`npoints'"!="" & "`tpoints'"=="") {	
qui sum `t'
qui gen `max_t'= r(max)
qui gen `min_t'= r(min)

mkmat `min_t' if _n==1, matrix(`tvector')

local i =1
while `i'<=`npoints'{
qui replace `treatment_values' = `min_t' + `i'*((`max_t'-`min_t')/`npoints') if `i'< `npoints' | (`i'== `npoints' & `treatment_values' <=`max_t')  
qui replace `treatment_values' = `max_t'                                     if  (`i'== `npoints' & `treatment_values' >`max_t')
mkmat `treatment_values' if _n==1, matrix(`mat_aux')
matrix  `tvector'= `tvector' \ `mat_aux'
local i = 	`i' + 1
}
}

/*else{*/
if ("`npoints'"=="" & "`tpoints'"!="") {	
matrix def   `tvector' = `tpoints'
	}

local J = rowsof(`tvector')
local j = 1
while `j' <= `J'{
tempvar tt_`j'  
qui gen `tt_`j''  = el(`tvector',`j',1) 
local j = `j'+1
}


if "`filename'" ==""{
di _newline(1)  "Warning message: Option filename is not specified; the results won't be saved"
tempfile filename
}

if !(`delta' >= 0){
di as error "The difference between two adjacent treatment values has to be non negative"
exit 121
}

tempvar tt tt_transf gpscore_values ytt
qui gen `tt' = .
qui gen `tt_transf' = .
qui gen `gpscore_values'  = .
qui gen `ytt' =.

if `delta' > 0{
tempvar tt_plus tt_transf_plus gpscore_values_plus ytt_plus
qui gen `tt_plus' = .
qui gen `tt_transf_plus' = .
qui gen `gpscore_values_plus'  = .
qui gen `ytt_plus' =.
}

if ("`cmd'"=="logit" | "`cmd'"=="probit" | "`cmd'"=="regress" ){
qui gen `dose_response'= .
if `delta' > 0{
qui gen `dose_response'_plus= .
}
}
if ("`cmd'"=="mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
qui gen dose_response_`x' = .
if `delta' > 0{
qui gen dose_response_plus_`x'= .
}
}
}

tempfile  external external_1 external_2

local J = rowsof(`tvector')
local j = 1
while `j' <= `J'{
qui replace `tt' = `tt_`j''
if `delta' > 0{
qui replace `tt_plus' = `tt_`j'' + `delta'
}

	if ("`t_transf'"=="") {
	qui replace `tt_transf'= `tt' if `touse'
	if `delta' > 0{
	qui replace `tt_transf_plus' = `tt_plus' 
	}
		}

	if ("`t_transf'"=="ln") {
	if(`tt'<0){
	di as error "The Logarithmic transformation cannot be applied: element `j'  of `tpoints' is negative"
	}
	qui replace `tt_transf'= ln(`tt') if `touse' & `tt'>0
	qui replace `tt_transf'= 0        if `touse' & `tt'==0

	if `delta' > 0{
	if(`tt_plus'<0){
	di as error "The Logarithmic transformation cannot be applied: element `j'  of `tpoints' is negative"
	}
	qui replace `tt_transf_plus'= ln(`tt') if `touse' & `tt_plus'>0
	qui replace `tt_transf_plus'= 0        if `touse' & `tt_plus'==0 /*This is redundant*/
	}
	}

	if ("`t_transf'"=="lnskew0") {
	qui lnskew0 ln_t = `t' if `touse'
	local K = r(gamma)
	local skew = r(skewness)
	tempvar aux1 aux2 sign
	qui gen `aux1' = ln(`t' - `K')
	qui gen `aux2' = ln(-`t' - `K')
	qui gen `sign' = 1 if `aux1' == ln_t
	qui replace `sign' = -1 if `aux2' == ln_t
	qui replace `tt_transf' = ln(`sign'*`tt' -  `K') if `touse'
	if `delta' > 0{
	qui replace `tt_transf_plus' = ln(`sign'*`tt_plus'  -  `K')  if `touse' 
	}
	drop ln_t
	}

	if ("`t_transf'"=="bcskew0") {
	qui bcskew0 bc_t = `t' if `touse'
	local Lambda = r(lambda)
	if(`tt'<0){
	di as error "The Zero-skewness Box Cox transformation cannot be applied: element `j'  of `tpoints' is negative"
	}
	qui replace `tt_transf'= (`tt'^`Lambda' - 1)/`Lambda'    if `touse' & `tt'>=0 & `Lambda'!=0
	qui replace `tt_transf'= ln(`tt')                        if `touse' & `tt'>0  & `Lambda'!=0
	qui replace `tt_transf'= 0           			   if `touse' & `tt'==0 & `Lambda'==0

	if `delta' > 0{
	if(`tt_plus'<0){
	di as error "The Zero-skewness Box Cox transformation cannot be applied: element `j'  of `tpoints' is negative"
	}
	qui replace `tt_transf_plus'= (`tt_plus'^`Lambda' - 1)/`Lambda'    if `touse' & `tt_plus'>=0 & `Lambda'!=0
	qui replace `tt_transf_plus'= ln(`tt_plus')                        if `touse' & `tt_plus'>0  & `Lambda'!=0
	qui replace `tt_transf_plus'= 0           			       if `touse' & `tt_plus'==0 & `Lambda'==0
	}
	drop bc_t
	}

	if ("`t_transf'"=="boxcox") {
	qui boxcox `t' `varlist' [`weight'`exp'] if `touse'
	local L = r(est)
	if(`tt'<=0){
	di as error "The Box Cox transformation cannot be applied: element `j'  of `tpoints' is not strictly positive"
	}
	qui replace `tt_transf'= (`tt'^`L' - 1)/`L'  if `touse' & `tt'>=0 & `L'!=0
	qui replace `tt_transf'= ln(`tt')            if `touse' & `tt'>0  & `L'!=0
	qui replace `tt_transf'= 0           	   if `touse' & `tt'==0 & `L'==0

	if `delta' > 0{
	if(`tt_plus'<=0){
	di as error "The Box Cox transformation cannot be applied: element `j'  of `tpoints' is not strictly positive"
	}
	qui replace `tt_transf_plus'= (`tt_plus'^`L' - 1)/`L'  if `touse' & `tt_plus'>=0 & `L'!=0
	qui replace `tt_transf_plus'= ln(`tt_plus')            if `touse' & `tt_plus'>0  & `L'!=0
	qui replace `tt_transf_plus'= 0           	       if `touse' & `tt_plus'==0 & `L'==0
	}
	}


if fam == "Gaussian"{
qui replace `gpscore_values' = normalden(`tt_transf', `predict', `sigma')

if `delta' > 0{
qui replace `gpscore_values_plus' = normalden(`tt_transf_plus', `predict', `sigma')
}
}

else if fam == "Poisson"{
qui replace `gpscore_values' =exp((`tt_transf'*ln(`predict')-`predict')-lnfactorial(`tt_transf'))

if `delta' > 0{
qui replace `gpscore_values_plus' = exp((`tt_transf_plus'*ln(`predict')-`predict')-lnfactorial(`tt_transf_plus'))
}
}

else if fam == "Gamma"{
tempvar theta a_theta

gen `theta' = - 1/`predict'
gen `a_theta' = - ln(-`theta')
qui replace `gpscore_values' = exp((`tt_transf'* `theta')- `a_theta') 

if `delta' > 0{
qui replace `gpscore_values_plus' = exp((`tt_transf_plus'* `theta')- `a_theta') 
}
}


else if fam == "Inverse Gaussian"{
tempvar c

gen `c' =sqrt(1/(2*_pi*`tt_transf'^3))
qui replace `gpscore_values' = `c'*exp(-((`tt_transf'-`predict')^2)/(2*`tt_transf'*`predict'^2)) 

if `delta' > 0{
qui replace `gpscore_values_plus' = `c'*exp(-((`tt_transf_plus'-`predict')^2)/(2*`tt_transf_plus'*`predict'^2)) 
}
}


else if fam =="Neg. Binomial" {
tempvar theta a_theta

gen `theta' = ln((k_nb* `predict')/(1+(k_nb* `predict'))) 
gen `a_theta' = (-1/k_nb)*ln(1-(k_nb*exp(`theta'))) 
qui replace `gpscore_values' = exp(`tt_transf'*`theta1'-`a_theta') 


if `delta' > 0{
qui replace `gpscore_values_plus' = exp(`tt_transf_plus'*`theta1'-`a_theta')
}
}

*** either you use delta or not it does not affect the predict command


else if (fam  =="Binomial" & "`opt_b'" =="") {         		
	qui replace `gpscore_values'=`predict'

if `delta' > 0{
qui replace `gpscore_values_plus' = `predict'
}
}	
else if (fam  =="Binomial" & "`opt_b'" !="") {         		
	qui replace `gpscore_values'=`predict'/`opt_b'
if `delta' > 0{
qui replace `gpscore_values_plus' = `predict'/`opt_b'
}
}



tempvar cmd_aux
qui gen `cmd_aux'= "`cmd'"

#delimit ;
qui doseresponse_model `t' `gpscore' `if' `in'  [`weight'`exp'], 
outcome(`outcome')
cmd(`cmd') 
reg_type_t(`reg_type_t')
reg_type_gps(`reg_type_gps')
interaction(`interaction')
;
#delimit cr


if (`delta' == 0 ){
local k = 1
}

if (`delta' >0){
local k = 2
}

while(`k'>0){
#delimit ;
qui doseresponse_model `t' `gpscore' `if' `in'  [`weight'`exp'], 
outcome(`outcome')
cmd(`cmd') 
reg_type_t(`reg_type_t')
reg_type_gps(`reg_type_gps')
interaction(`interaction')
;
#delimit cr
if (`cmd_aux'=="regress" | `cmd_aux'=="logit" | `cmd_aux'=="probit"){

if (`k'==1){
preserve
keep `tt' `gpscore_values'  `dose_response' `cmd_aux' `outcome'
qui rename  `tt'  `t'
qui rename `gpscore_values' `gpscore' 
}

if (`k'==2){
preserve
keep `tt' `tt_plus' `gpscore_values_plus'  `dose_response'_plus `cmd_aux' `outcome'
qui rename  `tt_plus'  `t'
qui rename `gpscore_values_plus' `gpscore' 
}

qui gen `t'_sq = `t'^2
qui gen `t'_3 = `t'^3
qui gen `gpscore'_sq = `gpscore'^2
qui gen `gpscore'_3 = `gpscore'^3
qui gen `t'_`gpscore' = `t'*`gpscore'

qui predict ytt

if (`k'==1){
keep `t' ytt `dose_response' 
rename `t' `tt'
}

if (`k'==2){
keep `tt' `t' ytt `dose_response'_plus 
rename `t' `tt_plus'
}
qui save `external_`k'', replace

restore

preserve
use `external_`k'', clear

qui sum ytt

if (`k'==1){
qui replace `dose_response' = r(mean)
keep `tt' `dose_response' 
qui rename `tt'  treatment_level
}

if (`k'==2){
qui replace `dose_response'_plus = r(mean)
keep `tt' `tt_plus' `dose_response'_plus 
qui rename `tt'  treatment_level
qui rename `tt_plus'  treatment_level_plus
}

qui keep if _n==1
qui save `external_`k'', replace
clear
restore
}
if (`cmd_aux'== "mlogit" | `cmd_aux'=="mprobit" | `cmd_aux'=="ologit" | `cmd_aux'=="oprobit"){
if (`k'==1){
preserve
keep `tt' `gpscore_values'  `cmd_aux'  dose_response_*
qui rename  `tt'  `t'
qui rename `gpscore_values' `gpscore' 
}
if (`k'==2){
preserve
keep `tt' `tt_plus' `gpscore_values_plus'  `cmd_aux'  dose_response_plus_*
qui rename  `tt_plus'  `t'
qui rename `gpscore_values_plus' `gpscore' 
}
qui gen `t'_sq = `t'^2
qui gen `t'_3 = `t'^3
qui gen `gpscore'_sq = `gpscore'^2
qui gen `gpscore'_3 = `gpscore'^3
qui gen `t'_`gpscore' = `t'*`gpscore'

qui predict ytt_* 


if(`cmd_aux'=="ologit" | `cmd_aux'=="oprobit"){

local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
local xx = `x'-1
rename  ytt_`xx' yytt_`xx' 
}


local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
local xx = `x'-1
rename yytt_`xx' ytt_`x' 
}

}

if (`k'==1){
keep `t' ytt_*  dose_response_*
rename `t' `tt'
}

if (`k'==2){
keep  `tt' `t' ytt_* dose_response_plus_*
rename `t' `tt_plus'
}
qui save `external_`k'', replace
clear
restore

preserve

use `external_`k'', clear

local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
qui sum ytt_`x'
if (`k'==1){
qui replace dose_response_`x' = r(mean)
}
if (`k'==2){
qui replace dose_response_plus_`x' = r(mean)
}
}

if (`k'==1){
keep `tt' dose_response_*

qui rename `tt'  treatment_level
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
label var dose_response_`x' "Dose-response function (category `x')"
local xvar: word `x' of `dose_response'
qui rename dose_response_`x' `xvar'
drop dose_response_plus_`x' 
}
}

if (`k'==2){
keep `tt' `tt_plus' dose_response_plus_*
qui rename `tt'  treatment_level
qui rename `tt_plus'  treatment_level_plus

local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
label var dose_response_plus_`x' "Dose-response function (category `x')"
local xvar: word `x' of `dose_response'
qui rename dose_response_plus_`x' `xvar'_plus
}
}


qui keep if _n==1
qui save `external_`k'', replace
clear
restore
}
local k = `k'- 1
} /*End while*/


if(`delta'>0){
preserve
use `external_2', clear
sort treatment_level
qui save `external_2', replace
clear
restore
}

preserve
qui use `external_1', clear
sort treatment_level
if(`delta'>0){
qui merge treatment_level using `external_2'
drop _merge
}
qui save `external', replace
clear
restore

preserve

if(`j' ==1) {
qui use `external', clear
qui save `filename', replace
}

if(`j' > 1) {
qui use `external', clear
append using `filename'
qui sort treatment_level
qui save `filename', replace
}

restore
local j = `j' + 1
} /*End ''while'' on j=1,..., J*/


if (`delta'>0){

if (`cmd_aux'=="regress" | `cmd_aux'=="logit" | `cmd_aux'=="probit"){
preserve
use `filename', clear
qui gen diff_`dose_response' = `dose_response'_plus - `dose_response' 
qui label var diff_`dose_response' "Treatment Effect for delta= `delta'"
drop `dose_response'_plus 
order treatment_level treatment_level_plus `dose_response' diff_`dose_response' 
qui save `filename', replace
clear
restore
}


if (`cmd_aux'== "mlogit" | `cmd_aux'=="mprobit" | `cmd_aux'=="ologit" | `cmd_aux'=="oprobit"){
preserve

use `filename', clear
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
local xvar: word `x' of `dose_response'
qui gen diff_dose_response_`x' = `xvar'_plus - `xvar'
label var diff_dose_response_`x' "Treatment Effect for delta= `delta' (category `x')"
qui rename diff_dose_response_`x' diff_`xvar'
drop `xvar'_plus 
}
order treatment_level treatment_level_plus
qui save `filename', replace
clear
restore
}
} /*End delta>0*/

*****************************************************************************
if fam =="Neg. Binomial" {
drop k_nb
}

scalar drop fam 

/*BOOTSTRAP*/

if "`bootstrap'" == "yes"{ 


di _newline(2) in gr  "Bootstrapping of the standard errors" 

tempfile output_boot
tempfile boot_sample

foreach k of numlist 1/`boot_reps'{

di _continue in gr "."

preserve

if "`weight'" == ""{
bsample _N `if' `in'
}

if "`weight'" != ""{
tempvar wei 
qui gen double `wei' `exp'
bsample _N `if' `in', weight(`wei') 
}

tempfile output_boot_`k' 
tempvar gpscore_boot predict_boot sigma_boot 


#delimit ;
qui gpscore2 `varlist' `if' `in', family(`family') link(`link')  
t(`t')
gpscore(`gpscore_boot') 
nq_gps(`nq_gps') 
predict(`predict_boot') 
sigma(`sigma_boot') 
cutpoints(`cutpoints')
index(`index')
t_transf(`t_transf')
normal_test(`normal_test')
norm_level(`norm_level')
test_varlist(`test_varlist')
test(`test') 
flag_b(int 2)
opt_nb(`opt_nb')
opt_b(`opt_b')
`detail'
;
#delimit cr


/*Bootstrap dose-response estimation*/

tempvar tt tt_transf gpscore_values ytt 
qui gen `tt' = .
qui gen `tt_transf' = .
qui gen `gpscore_values'  = .
qui gen `ytt' =.

if `delta' > 0{
tempvar tt_plus tt_transf_plus gpscore_values_plus 
qui gen `tt_plus' = .
qui gen `tt_transf_plus' = .
qui gen `gpscore_values_plus'  = .
}


if ("`cmd'"=="logit" | "`cmd'"=="probit" | "`cmd'"=="regress" ){
tempvar dose_response_boot 
qui gen `dose_response_boot'= .
if `delta' > 0{
tempvar dose_response_boot_plus 
qui gen `dose_response_boot_plus' = .
}
}

if ("`cmd'"=="mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
qui gen dose_response_boot_`x' = .
if `delta' > 0{
qui gen dose_response_boot_plus_`x'= .
}
}
}

qui save `boot_sample', replace 
clear
restore
preserve

use `boot_sample', clear

tempfile  external_boot external_boot_1 external_boot_2

local j = 1
while `j' <= `J' {

qui replace `tt' = `tt_`j''

if `delta' > 0{
qui replace `tt_plus' = `tt' + `delta'
}

	if ("`t_transf'"=="") {
	qui replace `tt_transf'= `tt' if `touse'
	if `delta' > 0{
	qui replace `tt_transf_plus' = `tt_plus' 
	}
		}

	if ("`t_transf'"=="ln") {
	qui replace `tt_transf'= ln(`tt') if `touse' & `tt'>0
	qui replace `tt_transf'= 0        if `touse' & `tt'==0
	if `delta' > 0{
	qui replace `tt_transf_plus'= ln(`tt') if `touse' & `tt_plus'>0
	qui replace `tt_transf_plus'= 0        if `touse' & `tt_plus'==0 /*This is redundant*/
	}
	}

	if ("`t_transf'"=="lnskew0") {
	qui lnskew0 ln_t = `t' if `touse'
	local K = r(gamma)
	local skew = r(skewness)
	tempvar aux1 aux2 sign
	qui gen `aux1' = ln(`t' - `K')
	qui gen `aux2' = ln(-`t' - `K')
	qui gen `sign' = 1 if `aux1' == ln_t
	qui replace `sign' = -1 if `aux2' == ln_t
	qui replace `tt_transf' = ln(`sign'*`tt' -  `K') if `touse'
	if `delta' > 0{
	qui replace `tt_transf_plus' = ln(`sign'*`tt_plus'  -  `K')  if `touse' 
	}
	drop ln_t
	}

	if ("`t_transf'"=="bcskew0") {
	qui bcskew0 bc_t = `t' if `touse'
	local Lambda = r(lambda)
	qui replace `tt_transf'= (`tt'^`Lambda' - 1)/`Lambda'    if `touse' & `tt'>=0 & `Lambda'!=0
	qui replace `tt_transf'= ln(`tt')                        if `touse' & `tt'>0  & `Lambda'!=0
	qui replace `tt_transf'= 0           			   if `touse' & `tt'==0 & `Lambda'==0

	if `delta' > 0{
	qui replace `tt_transf_plus'= (`tt_plus'^`Lambda' - 1)/`Lambda'    if `touse' & `tt_plus'>=0 & `Lambda'!=0
	qui replace `tt_transf_plus'= ln(`tt_plus')                        if `touse' & `tt_plus'>0  & `Lambda'!=0
	qui replace `tt_transf_plus'= 0           			       if `touse' & `tt_plus'==0 & `Lambda'==0
	}

	drop bc_t
	}

	if ("`t_transf'"=="boxcox") {
	qui boxcox `t' `varlist' [`weight'`exp'] if `touse'
	local L = r(est)
	qui replace `tt_transf'= (`tt'^`L'- 1)/`L'    if `touse' & `tt'>=0 & `L'!=0
	qui replace `tt_transf'= ln(`tt')             if `touse' & `tt'>0  & `L'!=0
	qui replace `tt_transf'= 0           	    if `touse' & `tt'==0 & `L'==0
	if `delta' > 0{
	qui replace `tt_transf_plus'= (`tt_plus'^`L' - 1)/`L'  if `touse' & `tt_plus'>=0 & `L'!=0
	qui replace `tt_transf_plus'= ln(`tt_plus')            if `touse' & `tt_plus'>0  & `L'!=0
	qui replace `tt_transf_plus'= 0           	       if `touse' & `tt_plus'==0 & `L'==0
	}
	}



if fam == "Gaussian"{
qui replace `gpscore_values' = normalden(`tt_transf', `predict_boot', `sigma_boot')

if `delta' > 0{
qui replace `gpscore_values_plus' = normalden(`tt_transf_plus', `predict_boot', `sigma_boot')
}
}

else if fam == "Poisson"{
qui replace `gpscore_values' =exp((`tt_transf'*ln(`predict_boot')-`predict_boot')-lnfactorial(`tt_transf'))

if `delta' > 0{
qui replace `gpscore_values_plus' = exp((`tt_transf_plus'*ln(`predict_boot')-`predict_boot')-lnfactorial(`tt_transf_plus'))
}
}

else if fam == "Gamma"{
tempvar theta a_theta

gen `theta' = - 1/`predict_boot'
gen `a_theta' = - ln(-`theta')
qui replace `gpscore_values' = exp((`tt_transf'* `theta')- `a_theta') 

if `delta' > 0{
qui replace `gpscore_values_plus' = exp((`tt_transf_plus'* `theta')- `a_theta') 
}
}


else if fam == "Inverse Gaussian"{
tempvar c

gen `c' =sqrt(1/(2*_pi*`tt_transf'^3))
qui replace `gpscore_values' = `c'*exp(-((`tt_transf'-`predict_boot')^2)/(2*`tt_transf'*`predict_boot'^2)) 

if `delta' > 0{
qui replace `gpscore_values_plus' = `c'*exp(-((`tt_transf_plus'-`predict_boot')^2)/(2*`tt_transf_plus'*`predict_boot'^2)) 
}
}


else if fam =="Neg. Binomial" {
tempvar theta a_theta

gen `theta' = ln((k_nb* `predict_boot')/(1+(k_nb* `predict_boot'))) 
gen `a_theta' = (-1/k_nb)*ln(1-(k_nb*exp(`theta'))) 
qui replace `gpscore_values' = exp(`tt_transf'*`theta1'-`a_theta') 


if `delta' > 0{
qui replace `gpscore_values_plus' = exp(`tt_transf_plus'*`theta1'-`a_theta')
}
}


else if (fam  =="Binomial" & "`opt_b'" =="") {         		
	qui replace `gpscore_values'=`predict_boot'

if `delta' > 0{
qui replace `gpscore_values_plus' = `predict_boot'
}
}	
else if (fam  =="Binomial" & "`opt_b'" !="") {         		
	qui replace `gpscore_values'=`predict_boot'/`opt_b'
if `delta' > 0{
qui replace `gpscore_values_plus' = `predict_boot'/`opt_b'
}
}
 
qui save `boot_sample', replace 


#delimit ;
qui doseresponse_model `t' `gpscore' `if' `in'  [`weight'`exp'], 
outcome(`outcome')
cmd(`cmd') 
reg_type_t(`reg_type_t')
reg_type_gps(`reg_type_gps')
interaction(`interaction')
;
#delimit cr


if (`delta' == 0 ){
local h = 1
}

if (`delta' >0){
local h = 2
}

while(`h'>0){
#delimit ;
qui doseresponse_model `t' `gpscore' `if' `in'  [`weight'`exp'], 
outcome(`outcome')
cmd(`cmd') 
reg_type_t(`reg_type_t')
reg_type_gps(`reg_type_gps')
interaction(`interaction')
;
#delimit cr

if ("`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit"){

if (`h'==1){
keep `tt' `gpscore_values'  `dose_response_boot'  `outcome'
qui rename  `tt'  `t'
qui rename `gpscore_values' `gpscore' 
}

if (`h'==2){
keep `tt' `tt_plus' `gpscore_values_plus'   `dose_response_boot_plus' `outcome'
qui rename  `tt_plus'  `t'
qui rename `gpscore_values_plus' `gpscore' 
}

qui gen `t'_sq = `t'^2
qui gen `t'_3 = `t'^3
qui gen `gpscore'_sq = `gpscore'^2
qui gen `gpscore'_3 = `gpscore'^3
qui gen `t'_`gpscore' = `t'*`gpscore'

qui predict ytt

if (`h'==1){
keep `t' ytt `dose_response_boot' 
rename `t' `tt'
}

if (`h'==2){
keep `tt' `t' ytt `dose_response_boot_plus'
rename `t' `tt_plus'
}
qui save `external_boot_`h'', replace


use `external_boot_`h'', clear
qui sum ytt
if (`h'==1){
qui replace `dose_response_boot' = r(mean)
keep `tt' `dose_response_boot' 
qui rename `tt'  treatment_level
}

if (`h'==2){
qui replace `dose_response_boot_plus' = r(mean)
keep `tt' `tt_plus' `dose_response_boot_plus'
qui rename `tt'  treatment_level
qui rename `tt_plus'  treatment_level_plus
}

qui keep if _n==1
qui save `external_boot_`h'', replace
}

if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){

if (`h'==1){
keep `tt' `gpscore_values'  dose_response_boot_*
qui rename  `tt'  `t'
qui rename `gpscore_values' `gpscore' 
}

if (`h'==2){
keep `tt' `tt_plus' `gpscore_values_plus' dose_response_boot_plus_*
qui rename  `tt_plus'  `t'
qui rename `gpscore_values_plus' `gpscore' 
}

qui gen `t'_sq = `t'^2
qui gen `t'_3 = `t'^3
qui gen `gpscore'_sq = `gpscore'^2
qui gen `gpscore'_3 = `gpscore'^3
qui gen `t'_`gpscore' = `t'*`gpscore'

qui predict ytt_* 

if("`cmd'"=="ologit" | "`cmd'"=="oprobit"){
local ncat: word count `dose_response'

foreach x of numlist 1/`ncat'{
local xx = `x'-1
rename  ytt_`xx' yytt_`xx' 
}


local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
local xx = `x'-1
rename yytt_`xx' ytt_`x' 
}

}

if (`h'==1){
keep `t' ytt_*  dose_response_boot_*
rename `t' `tt'
}

if (`h'==2){
keep `tt' `t' ytt_* dose_response_boot_plus_*
rename `t' `tt_plus'
}

qui save `external_boot_`h'', replace
clear

use `external_boot_`h'', clear
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
qui sum ytt_`x'
if (`h'==1){
qui replace dose_response_boot_`x' = r(mean)
}
if (`h'==2){
qui replace dose_response_boot_plus_`x' = r(mean)
}
}

if (`h'==1){
keep `tt'  dose_response_boot_*
qui rename `tt'  treatment_level
}

if (`h'==2){
keep `tt' `tt_plus' dose_response_boot_plus_*
qui rename `tt'  treatment_level
qui rename `tt_plus'  treatment_level_plus
}


qui keep if _n==1
qui save `external_boot_`h'', replace
}


local h = `h'- 1
use `boot_sample', clear

} /*End while*/


use `external_boot_1', clear
sort treatment_level
qui save `external_boot_1', replace

if(`delta'>0){
qui use `external_boot_2', clear
sort treatment_level
qui merge treatment_level using `external_boot_1'
drop _merge
}
qui save `external_boot', replace
clear


if(`j' ==1) {
qui use `external_boot', clear
qui save `output_boot_`k'', replace
}

if(`j' > 1) {
qui use `external_boot', clear
append using `output_boot_`k''
qui sort treatment_level
qui save `output_boot_`k'', replace
}
*restore
*preserve
use `boot_sample', clear
local j = `j' + 1
} /*End loop in j*/


qui use `output_boot_`k'', clear
if ("`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit"){
qui rename `dose_response_boot' dose_response_boot_`k'
if(`delta' >0) {
qui gen diff_dose_response_boot_`k' = `dose_response_boot_plus' - dose_response_boot_`k' 
}
}

if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){

local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
if(`delta' >0) {
qui gen diff_dose_response_boot_`x' = dose_response_boot_plus_`x' - dose_response_boot_`x'
drop dose_response_boot_plus_`x' 
qui rename diff_dose_response_boot_`x' diff_dose_response_boot_`x'_`k' 
}
qui rename dose_response_boot_`x' dose_response_boot_`x'_`k' 
}
}

if(`k' ==1) {
qui sort treatment_level
qui save `output_boot', replace
}

if(`k' > 1) {
merge treatment_level using `output_boot' 
if _merge != 3{
di as error "For some units _merge != 3"
}
drop _merge
qui sort treatment_level 
qui save `output_boot', replace
}

restore
} /*End loop in k=1,...,boot_reps*/


preserve

use `output_boot', clear
tempvar se_dose_response
if ("`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit"){
qui egen `se_dose_response' = rowsd(dose_response_boot_*)
if(`delta'>0){
tempvar se_diff_dose_response
qui egen `se_diff_dose_response' = rowsd(diff_dose_response_boot_*)
}
}

if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
tempvar se_dose_response_`x'
qui egen `se_dose_response_`x'' = rowsd(dose_response_boot_`x'_*)
if(`delta'>0){
tempvar se_diff_dose_response_`x'
qui egen `se_diff_dose_response_`x'' = rowsd(diff_dose_response_boot_`x'_*)
}
}
}

qui sort treatment_level 
qui save `output_boot', replace
restore

preserve 
use `output_boot', clear
if ("`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit"){
qui rename `se_dose_response' se_`dose_response'_bs
if(`delta'==0){
keep treatment_level  se_`dose_response'_bs
}
if(`delta'>0){
qui rename `se_diff_dose_response' se_diff_`dose_response'_bs
keep treatment_level  se_`dose_response'_bs se_diff_`dose_response'_bs
}
}

if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
local xvar: word `x' of  `dose_response'
qui rename `se_dose_response_`x'' se_`xvar'_bs
if(`delta'>0){
qui rename `se_diff_dose_response_`x'' se_diff_`xvar'_bs
}
}
keep treatment_level  se_*_bs
}

qui sort treatment_level 
merge treatment_level using  `filename' 
if _merge != 3{
di as error "For some units _merge != 3"
}
drop _merge
label var treatment_level "Treatment level"

if ("`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit"){
label var `dose_response' "Dose-response function"
label var se_`dose_response'_bs "Bootstrap standard error of the dose-response function"
if(`delta'>0){
label var se_diff_`dose_response'_bs "Bootstrap standard error of the treatment effect (delta=`delta')"
}
if(`delta'==0){
order treatment_level `dose_response' se_`dose_response'_bs
}
if(`delta'>0){
order treatment_level treatment_level_plus `dose_response' se_`dose_response'_bs diff_`dose_response' se_diff_`dose_response'_bs
}
}

if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
local xvar: word `x' of  `dose_response'
label var se_`xvar'_bs  "Bootstrap standard error of the dose-response function (category `x')"
if(`delta'>0){
label var se_diff_`xvar'_bs "Bootstrap standard error of the treatment effect (delta=`delta') - category `x'"
}
}
}
if(`delta'==0){
order treatment_level `dose_response' se_*_bs
}
if(`delta'>0){
order treatment_level treatment_level_plus `dose_response' diff_* se_*_bs
}


qui sort treatment_level 
qui save `filename', replace
clear
restore

} /*End Bootstrap = "yes"*/

/* Analysis*/

if !("`analysis'"=="" | "`analysis'"=="yes" | "`analysis'"=="no") {	
		di as error "Flag `analysis' is not recognized"
		exit 198
	}


if(`analysis_level' < 0 | `analysis_level' > 1){
		di as error "The confidence level ''analysis_level'' must be bounded away from zero and one"
		exit 198
}


if ("`analysis'"=="yes" | "`analysis'" ==""){


di _newline(3) "The program is drawing graphs of the output"
di "This operation may take a while"
di ""

preserve
use `filename', clear

if("`graph'" == ""){

if ("`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit"){
tempfile graph
}

if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
tempfile graph_`x'
}
}
}

if ("`analysis'" ==""){

if ("`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit"){

if ("`cmd'"=="regress" ){
#delimit ;
qui line `dose_response' treatment_level, ytitle("E[`outcome'(t)]")  
title("Dose Response Function")  note("Dose response function = Linear prediction") saving(graph_outcome, replace) 
;
#delimit cr
if(`delta'==0){
graph use graph_outcome
qui graph save `graph'
}

if(`delta'>0){
#delimit ;
qui line diff_`dose_response' treatment_level, ytitle("E[`outcome'(t+`delta')]-E[`outcome'(t)]",  margin(medlarge)) 
title("Treatment Effect Function")  note("Dose response function = Linear prediction") saving(graph_effect, replace) 
;
#delimit cr
graph combine graph_outcome.gph graph_effect.gph, col(2) scale(1) saving(`graph', replace) 
erase graph_effect.gph
}
erase graph_outcome.gph
}

if ("`cmd'"=="logit" | "`cmd'"=="probit"){
#delimit ;
qui line `dose_response' treatment_level, ytitle("E[`outcome'(t)]",  margin(medlarge)) 
title("Dose Response Function")  
note("Dose response function = Probability of a positive outcome" "Regression command = `cmd'") 
saving(graph_outcome, replace)
;
#delimit cr

#delimit cr
if(`delta'==0){
graph use graph_outcome
qui graph save `graph'
}

if(`delta'>0){
#delimit ;
qui line diff_`dose_response' treatment_level, ytitle("E[`outcome'(t+`delta')]-E[`outcome'(t)]")  
title("Treatment Effect Function")  note("Dose response function = Probability of a positive outcome" "Regression command = `cmd'") 
saving(graph_effect, replace) 
;
#delimit cr
graph combine graph_outcome.gph graph_effect.gph, col(2) scale(1) saving(`graph', replace) 
erase graph_effect.gph
}
erase graph_outcome.gph
}
}

if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
local ncat: word count `dose_response'

foreach x of numlist 1/`ncat'{
local xvar: word `x' of `dose_response'
#delimit ;
qui line `xvar' treatment_level, ytitle("E[`outcome'_`x'(t)]", margin(medlarge)) 
title("Dose Response Function")  
note("Dose response function = Probability - Category = `x'"
"Regression command = `cmd'") 
saving(graph_outcome_`x', replace)
;
#delimit cr
if(`delta'==0){
graph use graph_outcome_`x'
qui graph save `graph'_`x'
}
if(`delta'>0){
#delimit ;
qui qui line diff_`xvar' treatment_level,  ytitle("E[`outcome'_`x'(t+`delta')]-E[`outcome'_`x'(t)]")  
title("Treatment Effect Function")  
note("Dose response function = Probability - Category = `x'"
"Regression command = `cmd'") 
saving(graph_effect_`x', replace)
;
#delimit cr
graph combine graph_outcome_`x'.gph graph_effect_`x'.gph, col(2) scale(1) saving(`graph'_`x', replace) 
erase graph_effect_`x'.gph
}
erase graph_outcome_`x'.gph
}
}
} /*End  if ("`analysis'" =="")*/

if ("`analysis'" =="yes"){

if(`analysis_level' > 0 & `analysis_level' < 1 & "`bootstrap'" != "yes"){
		di as error "Boostrap has not been run: bootstrap standard errors cannot be found"
		exit 198
}



if("`bootstrap'" == "yes" & `analysis_level' > 0 & `analysis_level' < 1){
if ("`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit"){
tempvar low_bound high_bound 
qui gen `low_bound'  = `dose_response' - invnormal(1-(1-`analysis_level')/2)*se_`dose_response'_bs
qui gen `high_bound' = `dose_response' + invnormal(1-(1-`analysis_level')/2)*se_`dose_response'_bs

if ("`cmd'"=="regress" ){
#delimit ;
qui line `dose_response' `low_bound' `high_bound' treatment_level, ytitle("E[`outcome'(t)]",margin(medlarge))  
title("Dose Response Function")  note("Confidence Bounds at `analysis_level' % level"
"Dose response function = Linear prediction") legend(on size(small)) legend(region(lcolor(none))) legend(symxsize(6)) 
legend(label(1 "Dose Response") label(2 "Low bound") label(3 "Upper bound"))
saving(graph_outcome, replace) 
;
#delimit cr
if(`delta'==0){
graph use graph_outcome
qui graph save `graph', replace 
}
if(`delta'>0){
tempvar l_bound h_bound 
qui gen `l_bound'  = diff_`dose_response' - invnormal(1-(1-`analysis_level')/2)*se_diff_`dose_response'_bs
qui gen `h_bound' =  diff_`dose_response' + invnormal(1-(1-`analysis_level')/2)*se_diff_`dose_response'_bs


#delimit ;
qui line diff_`dose_response' `l_bound' `h_bound' treatment_level, 
ytitle("E[`outcome'(t+`delta')]-E[`outcome'(t)]", margin(medlarge))
title("Treatment Effect Function")  note("Confidence Bounds at `analysis_level' % level"
"Dose response function = Linear prediction") legend(on size(small)) legend(region(lcolor(none))) legend(symxsize(6)) 
legend(label(1 "Treatment Effect") label(2 "Low bound") label(3 "Upper bound"))
saving(graph_effect, replace) 
;
#delimit cr
graph combine graph_outcome.gph graph_effect.gph, col(2) scale(1) saving(`graph', replace) 
erase graph_effect.gph
}
erase graph_outcome.gph 
}

if ("`cmd'"=="logit" | "`cmd'"=="probit"){
#delimit ;
qui line `dose_response' `low_bound' `high_bound' treatment_level, ytitle("E[`outcome'(t)]", margin(medlarge))  
title("Dose Response Function")  note("Confidence Bounds at `analysis_level' % level"
"Dose response function = Probability of a positive outcome" "Regression command = `cmd'")  legend(on size(small)) legend(region(lcolor(none))) legend(symxsize(6)) 
legend(label(1 "Dose Response") label(2 "Low bound") label(3 "Upper bound"))
saving(graph_outcome, replace) 
;
#delimit cr

if(`delta'==0){
graph use graph_outcome
qui graph save `graph', replace 
}
if(`delta'>0){
tempvar l_bound h_bound 
qui gen `l_bound'  = diff_`dose_response' - invnormal(1-(1-`analysis_level')/2)*se_diff_`dose_response'_bs
qui gen `h_bound' =  diff_`dose_response' + invnormal(1-(1-`analysis_level')/2)*se_diff_`dose_response'_bs

#delimit ;
qui line diff_`dose_response' `l_bound' `h_bound' treatment_level, 
ytitle("E[`outcome'(t+`delta')]-E[`outcome'(t)]",margin(medlarge))
title("Treatment Effect Function")  note("Confidence Bounds at `analysis_level' % level"
"Dose response function = Probability of a positive outcome" "Regression command = `cmd'")  
legend(on size(small)) legend(region(lcolor(none))) legend(symxsize(6)) 
legend(label(1 "Treatment Effect") label(2 "Low bound") label(3 "Upper bound"))
saving(graph_effect, replace) 
;
#delimit cr
graph combine graph_outcome.gph graph_effect.gph, col(2) scale(1) saving(`graph', replace) 
erase graph_effect.gph
}
erase graph_outcome.gph 
}
}


if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){

local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
tempvar low_bound_`x' high_bound_`x'   
local xvar: word `x' of `dose_response'
qui gen `low_bound_`x''  = `xvar' - invnormal(1-(1-`analysis_level')/2)*se_`xvar'_bs
qui gen `high_bound_`x'' = `xvar' + invnormal(1-(1-`analysis_level')/2)*se_`xvar'_bs


#delimit ;

qui line `xvar' `low_bound_`x'' `high_bound_`x'' treatment_level, ytitle("E[`outcome'_`x'(t)]", margin(medlarge))  
title("Dose Response Function")  note("Confidence Bounds at `analysis_level' % level"
"Dose response function = Probability - Category = `x'" "Regression command = `cmd'")  
legend(on size(small)) legend(region(lcolor(none))) legend(symxsize(6)) 
legend(label(1 "Dose Response") label(2 "Low bound") label(3 "Upper bound"))
saving(graph_outcome_`x', replace) 
;
#delimit cr
if(`delta'==0){
graph use graph_outcome_`x'
qui graph save `graph'_`x'
}

if(`delta'>0){
tempvar  l_bound_`x' h_bound_`x'
qui gen `l_bound_`x''  = diff_`xvar' - invnormal(1-(1-`analysis_level')/2)*se_diff_`xvar'_bs
qui gen `h_bound_`x''  = diff_`xvar' + invnormal(1-(1-`analysis_level')/2)*se_diff_`xvar'_bs

#delimit ;
qui line diff_`xvar' `l_bound_`x'' `h_bound_`x'' treatment_level, 
ytitle("E[`outcome'_`x'(t+`delta')]-E[`outcome'_`x'(t)]",margin(medlarge))
title("Treatment Effect Function")  note("Confidence Bounds at `analysis_level' % level"
"Dose response function = Probability - Category = `x'" "Regression command = `cmd'")  
legend(on size(small)) legend(region(lcolor(none))) legend(symxsize(6)) 
legend(label(1 "Treatment Effect") label(2 "Low bound") label(3 "Upper bound"))
saving(graph_effect_`x', replace) 
;
#delimit cr
qui graph combine graph_outcome_`x'.gph graph_effect_`x'.gph, col(2) scale(1) saving(`graph'_`x', replace) 
erase graph_effect_`x'.gph
}
erase graph_outcome_`x'.gph
} 
}
} /*End cmd*/

} /*End analysis ==yes.*/

if("`graph'" == ""){

if ("`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit"){
graph use `graph'
graph save graph, replace
erase `graph'.gph
}

if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
local ncat: word count `dose_response'
foreach x of numlist 1/`ncat'{
graph use `graph'_`x'
graph save graph_`x', replace
erase `graph'_`x'.gph
}
}
}

restore

}  /*End analysis != no.*/




if ("`analysis'" == "no") {	
if("`graph'" != ""){

di _newline(2) in red "Warning message: No graph is drawn, therefore no figure is saved"
}
}

if ("`cmd'"== "mlogit" | "`cmd'"=="mprobit" | "`cmd'"=="ologit" | "`cmd'"=="oprobit"){
drop dose_response_*  
}

di _newline(2) in gr "End of the Algorithm" 
end



