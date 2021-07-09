program doseresponse_model, rclass
version 10.0

#delimit ;
syntax varlist(min=2 max=2) [if] [in] [fweight iweight pweight], 
outcome(string) 
[
cmd(string) 
reg_type_t(string)
reg_type_gps(string)
interaction(int 1)
] 
;
#delimit cr

if "`weight'" != ""{
tempvar wei 
qui gen double `wei' `exp'
local w [`weight' = `wei']
}

tokenize `varlist'
marksample touse

local t:       word 1 of `varlist'
local gpscore: word 2 of `varlist'


#delimit ;
	if !("`cmd'"=="" | "`cmd'"=="regress" | "`cmd'"=="logit" | "`cmd'"=="probit" | 
	     "`cmd'"=="ologit" | "`cmd'"=="oprobit"| "`cmd'"=="mlogit" | "`cmd'"=="mprobit") {;
#delimit cr
		di as error "The cmd of the outcome variable ''`cmd''' is not recognized"
		exit 198
	}


/*
	Assign default cmd for vars not so far accounted for.
	cmd is relevant only for vars requiring imputation, i.e. with >=1 missing values.
	Use logit if 2 distinct values, mlogit if 3-5, otherwise regress.
*/
				
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
			if "`cmd'"=="mlogit" {
				* With mlogit, if outcome  carries a score label,
				* drop it since it causes prediction problems
				local outcome_lab: value label `outcome'
				capture label drop `outcome_lab'
			}


if ("`cmd'"=="regress"){
di in green _newline(1)  "The outcome variable ''`outcome''' is a continuous variable"
}


if ("`cmd'"=="logit" | "`cmd'"=="probit"){
di in green _newline(1)  "The outcome variable ''`outcome''' is a binary variable"
}

if ("`cmd'"=="mlogit" | "`cmd'"=="mprobit"){
di in green _newline(1)  "The outcome variable ''`outcome''' is a categorical variable (Multinomial - polytomous)"
}

if ("`cmd'"=="ologit" | "`cmd'"=="oprobit"){
di in green _newline(1)  "The outcome variable ''`outcome''' is an ordinal variable"
}

qui gen `t'_sq = `t'^2
qui gen `gpscore'_sq = `gpscore'^2
qui gen `t'_`gpscore'  = `t'*`gpscore'
qui gen `t'_3 = `t'^3
qui gen `gpscore'_3 = `gpscore'^3


/* check reg_type & interaction*/

if !("`reg_type_t'"=="" | "`reg_type_t'"=="linear" | "`reg_type_t'"=="quadratic" | "`reg_type_t'"=="cubic") {	
		di as error "Regression model `reg_type_t' is not recognized"
		exit 198
	}

if !("`reg_type_gps'"=="" | "`reg_type_gps'"=="linear" | "`reg_type_gps'"=="quadratic" | "`reg_type_gps'"=="cubic") {	
		di as error "Regression model `reg_type_gps' is not recognized"
		exit 198
	}

if !(`interaction'== 1 | `interaction'==0){
		di as error "Interaction `interaction' not recognized"
		exit 198
	}

tempvar flag_model
qui gen `flag_model' = .

if ("`reg_type_t'"=="" | "`reg_type_t'"=="linear") {

if ("`reg_type_gps'"=="" | "`reg_type_gps'"=="linear") {
if (`interaction'== 0){
di in ye _newline(1)  "The regression model is: Y = T + GPS"
`cmd' `outcome' `t' `gpscore' [`weight'`exp'] 
qui replace `flag_model' = 1 
}

if (`interaction'== 1){
di in ye _newline(1)  "The regression model is: Y = T + GPS + T*GPS"
`cmd' `outcome' `t' `gpscore' `t'_`gpscore' [`weight'`exp'] 
qui replace `flag_model' = 2
	}
}

if ("`reg_type_gps'"=="quadratic") {
if (`interaction'== 0){
di in ye _newline(1)  "The regression model is: Y = T + GPS + GPS^2"
`cmd' `outcome' `t' `gpscore' `gpscore'_sq  [`weight'`exp'] 
qui replace `flag_model' = 3
}

if (`interaction'== 1){
di in ye _newline(1)  "The regression model is: Y = T + GPS +  GPS^2 + T*GPS"
 `cmd' `outcome' `t' `gpscore' `gpscore'_sq  `t'_`gpscore' [`weight'`exp'] 
qui replace `flag_model' = 4
}
}

if ("`reg_type_gps'"=="cubic") {
if (`interaction'== 0){
di in ye _newline(1)  "The regression model is: Y = T + GPS + GPS^2 + GPS^3"
 `cmd' `outcome' `t' `gpscore' `gpscore'_sq  `gpscore'_3  [`weight'`exp'] 
qui replace `flag_model' = 5
}

if (`interaction'== 1){
di in ye _newline(1)  "The regression model is: Y = T + GPS +  GPS^2 + GPS^3 + T*GPS"
 `cmd' `outcome' `t' `gpscore' `gpscore'_sq   `gpscore'_3  `t'_`gpscore' [`weight'`exp'] 
qui replace `flag_model' = 6
}
}
}

if ("`reg_type_t'"=="quadratic") {

if ("`reg_type_gps'"=="" | "`reg_type_gps'"=="linear") {
if (`interaction'== 0){
di in ye _newline(1)  "The regression model is: Y = T + T^2 + GPS"
`cmd' `outcome' `t' `t'_sq `gpscore'  [`weight'`exp'] 
qui replace `flag_model' = 7
}

if (`interaction'== 1){
di in ye _newline(1)  "The regression model is: Y = T +  T^2 + GPS + T*GPS"
`cmd' `outcome' `t' `t'_sq `gpscore' `t'_`gpscore' [`weight'`exp'] 
qui replace `flag_model' = 8
}
}

if ("`reg_type_gps'"=="quadratic") {
if (`interaction'== 0){
di in ye _newline(1)  "The regression model is: Y = T +  T^2  + GPS + GPS^2"
`cmd' `outcome' `t' `t'_sq `gpscore' `gpscore'_sq [`weight'`exp'] 
qui replace `flag_model' = 9
}

if (`interaction'== 1){
di in ye _newline(1)  "The regression model is: Y = T + T^2 + GPS +  GPS^2 + T*GPS"
`cmd' `outcome' `t' `t'_sq `gpscore' `gpscore'_sq  `t'_`gpscore' [`weight'`exp'] 
qui replace `flag_model' = 10
}
}

if ("`reg_type_gps'"=="cubic") {
if (`interaction'== 0){
di in ye _newline(1)  "The regression model is: Y = T + T^2 + GPS + GPS^2 + GPS^3"
`cmd' `outcome' `t' `t'_sq `gpscore' `gpscore'_sq  `gpscore'_3 [`weight'`exp'] 
qui replace `flag_model' = 11
}

if (`interaction'== 1){
di in ye _newline(1)  "The regression model is: Y = T + T^2 + GPS +  GPS^2 + GPS^3 + T*GPS"
`cmd' `outcome' `t' `t'_sq `gpscore' `gpscore'_sq  `gpscore'_3  `t'_`gpscore' [`weight'`exp'] 
qui replace `flag_model' = 12
}
}
}

if ("`reg_type_t'"=="cubic") {

if ("`reg_type_gps'"=="" | "`reg_type_gps'"=="linear") {
if (`interaction'== 0){
di in ye _newline(1)  "The regression model is: Y = T + T^2 + T^3 + GPS"
`cmd' `outcome' `t' `t'_sq `t'_3 `gpscore' [`weight'`exp'] 
qui replace `flag_model' = 13
}

if (`interaction'== 1){
di in ye _newline(1)  "The regression model is: Y = T +  T^2 + T^3 + GPS + T*GPS"
`cmd' `outcome' `t' `t'_sq `t'_3 `gpscore' `t'_`gpscore' [`weight'`exp'] 
qui replace `flag_model' = 14
}
}

if ("`reg_type_gps'"=="quadratic") {
if (`interaction'== 0){
di in ye _newline(1)  "The regression model is: Y = T +  T^2 + T^3 + GPS + GPS^2"
`cmd' `outcome' `t' `t'_sq `t'_3 `gpscore' `gpscore'_sq  [`weight'`exp'] 
qui replace `flag_model' = 15
}

if (`interaction'== 1){
di in ye _newline(1)  "The regression model is: Y = T + T^2 + T^3 + GPS +  GPS^2 + T*GPS"
`cmd' `outcome' `t' `t'_sq `t'_3 `gpscore' `gpscore'_sq  `t'_`gpscore' [`weight'`exp'] 
qui replace `flag_model' = 16
	}
}

if ("`reg_type_gps'"=="cubic") {
if (`interaction'== 0){
di in ye _newline(1)  "The regression model is: Y = T + T^2 + T^3 + GPS + GPS^2 + GPS^3"
`cmd' `outcome' `t' `t'_sq `t'_3 `gpscore' `gpscore'_sq  `gpscore'_3 [`weight'`exp'] 
qui replace `flag_model' = 17
}

if (`interaction'== 1){
di in ye _newline(1)  "The regression model is: Y = T + T^2 + T^3 + GPS +  GPS^2 + GPS^3 + T*GPS"
`cmd' `outcome' `t' `t'_sq `t'_3 `gpscore' `gpscore'_sq  `gpscore'_3  `t'_`gpscore' [`weight'`exp'] 
qui replace `flag_model' = 18
}
}
}

return scalar flag_model = `flag_model'
drop `t'_sq `gpscore'_sq `t'_3 `gpscore'_3 `t'_`gpscore' 

end
