*! mimix v1.4 23apr2018
cap prog drop mimix
program define mimix, rclass 
version 13.0

/*
DESCRIPTION
	-mimix- performs reference based multiple imputation for sensitivity analysis 
	of a longitudinal clinical trial with protocol deviation. 
	Specific qualitative treatment arm based assumptions for missing data are made.
	Data is required in long format. 
	The user must specify: dependent/response variable, treatment group, time variable,
	individual id variable and the imputation method.
	Additional fully observed baseline covariates may also be included.
	Takes max covariate value if not consistent within id - if covariates 
	are not complete, associated individual is removed with warning to user.
	Any included covariates must be numeric, need to generate dummy variables for factor covariates.
	Time must be a numerical variable.
	Treatment group (& reference group) can be a numerical or character variable.
	Id can be a numerical or character or mix variable
	
	v1.0 - original
	v1.1 - bug in copying of original data thats not included in the imputation model to final MI data set fixed
	v1.2 - edited interim option so that imputation of interim values can be conducted under either MAR, CR, J2R, LMCF or CIR.
	       required inclusion of a new option iref to specify reference group for interim imputation.
	v1.3 - bug in ordering of id variable during MI process where covariates alphabetically later resolved. 
	       bug requiring covariates to be specified in order appear in dataset fixed.
	       covariates can now be specified in any order in the command line. mimix internally re-orders data to correspond with order specified;
		   note as order of variables changed internally when diff covariate specification used, diff mi results obtained with diff orders
		   as order effects the stochastic process.
	v1.4 - Transposed U (the cholesky decomposition of the conditional variance matrix) so U is now an upper triangular matrix as required.
	       Note: examples in Cro, Morris, Kenward and Carpenter (2016) stata journal conducted using v1.3 
		   */

syntax varlist, time(varname) id(varname) [ COVariates(varlist) methodvar(varname) METHOD(string) refgroupvar(varname) REFgroup(str) SAVing(string) clear m(integer 5) BURNin(integer 100) BURNBetween(integer 100) seed(integer 0) interim(string) iref(str) mixed regress]

preserve
*PRE-PROCESSING AND ERROR CHECKING
tempfile orig_data add_data mimix_d1 my_treat my_time mimix_d2 treat_code  int_out mimix_mj0 id_code
tempvar  flag1  mimix_method pattern indicator dupcheck  miss_ind mimix_time mimix_treat  nvals nobs mimix_intern_req numerical_id
*NOTE: refgroupvar methodvar mimix_refgroupvar ARE TEMPVAR's CREATED LATER ON

if `seed' > 0 set seed `seed'
local state = c(seed)
return local rseed `state'
if "`saving'" == "" & "`clear'" == "" {
	display as error "saving() and/or clear required"
	exit 100
}
if "`saving'" != "" {
	tokenize "`saving'", parse(",")
	local filename `1'
	local replace `3'
	if "`replace'" == "" {
		confirm new file `filename'.dta
	}
	if "`replace'" != "" {
		if "`replace'" != "replace" {
		display as error "option saving, `replace' not allowed"
		exit 198
		}
	}
}

cap confirm numeric variable `id' 
local id_num =  _rc
confirm numeric variable `time'
qui summ `time'
local maxtime=r(max)
qui inspect `time'
local ntime=r(N_unique)
	
*SAVE THE ORIGINAL DATA
qui save `orig_data'
local order ""
foreach var of varlist * {
	local order `order' `var' 
}
	
*SAVE THE DATA THAT WILL NOT BE SENT INTO MATA TO ADD TO IMPUTED DATA AT END
qui {
    capture drop `varlist'
    capture drop `covariates'
    sort `id' `time'
    save `add_data'
    use `orig_data' , clear
}

*PROCESS COVARIATES: TOKENIZE THEN CHECK COMPLETENESS
tokenize `covariates'
if "`*'" != "" {
    confirm numeric variable `1'
	local i = 1
	local cov`i' `1'
	macro shift
	while "`*'" != "" {
		confirm numeric variable `1'
		local i = `i' + 1
		local cov`i' `1'
		macro shift
	}
	local ncov `i'
	mata: mata_covflag = J(`ncov',1,0)
	mata: mata_covflag_nm = J(`ncov',1,1)
}

*methodvar & method ARE MUTUALLY EXCLUSIVE OPTIONS:
capture confirm variable `methodvar'
if `c(rc)' == 0 {
    local mvarspec 1 // local macro = 1 if user specified methodvar(), 0 if they specified method()
	if "`method'" != "" {
		display as error "The methodvar() and method() options are mutually exclusive"
		display as error "please specify either method() or methodvar()"
		exit 198
		
    }
}
*ONE OF methodvar or method MUST BE SPECIFIED
else if `c(rc)' != 0 {
	local mvarspec 0
    capture assert "`method'" != ""
    if `c(rc)' != 0 {
		display as error "The imputation method has not been specified"
		display as error "please specify either method() or methodvar()"
		exit 198
    }
	tempvar methodvar 
	qui generate str `methodvar' = "`method'"
}
qui sort `id' `time'

tokenize `varlist'
local response "`1'"
confirm numeric variable `response'
mac shift
local treat "`1'"

*ORDER DATA HERE IN TERMS OF COVARIATES ORDER:
if "`covariates'"!=""{
	if `ncov'>1 {
		local covorder="`cov1'"
		forvalues k=2(1)`ncov' {
			local covorder = "`covorder'"+" "+"`cov`k''"
		}
		order `covorder' /*note: get different results if specify covars round diff way as get diff order here - MI stochastic process*/
	}
}
order `response', first

*EXIT IF NO TREATMENT VARIABLE (OR RESPONSE) HAS BEEN SPECIFIED
if "`treat'" == "" 	{
	display as error "Response variable and treatment group are required options"
	exit 198
}

*refgroupvar & refgroup ARE MUTUALLY EXCLUSIVE OPTIONS:
capture confirm var `refgroupvar'
if `c(rc)' == 0 {
    if "`refgroup'" != "" {
		display as error "The refgroupvar() and refgroup() options are mutually exclusive"
		display as error "please specify either refgroup() or refgroupvar()"
		exit 198
    }
	cap confirm numeric variable `refgroupvar'
	if `c(rc)' == 0 {
		qui summ `treat'
		if r(mean) ==. {
			display as error "There are illegal values in the control-level variable `refgroupvar'. "
			display as error "Values should be one of the treatment groups. Type - tab `refgroupvar' , miss - to investigateX."
			exit 198
		}
	}	
}

if "`refgroup'" != "" {
	tempvar refgroupvar
	cap confirm number `refgroup'
	if `c(rc)' == 0 {
        generate int `refgroupvar' = `refgroup'
	}
    else {
		generate str `refgroupvar' = "`refgroup'"
        qui destring `refgroupvar' , replace
	}
}
 	
*CHECK refgroup IS A VALID NUMBER IF ITS A NUMBER, i.e. A TREATMENT LEVEL IF THIS OPTION IS USED (STRING PICKED UP LATER) 
if "`refgroup'" != "" {

	cap confirm number `refgroup'
	if `c(rc)' == 0 {
		qui levelsof `treat', clean local(levels2)
		foreach l of local levels2 {
			if "`refgroup'" == "`l'" {
				local check2 = 1
			}
		}
		if "`check2'" == "" {
			di as error "The reference specification is not a valid treatment group"
			di as error "The specified treatment group variable `treat' contains values: `levels2'"
			exit 198
		}
	}
	else {
		qui levelsof `treat', clean local(levels2)
		cap confirm numeric variable `treat'
		if `c(rc)' == 0 {	
			di as error "The reference specification is not a valid treatment group"
			di as error "The specified treatment group variable `treat' contains values: `levels2'"
			exit 198
		}
	}
}

*CHECK method SPECIFICATION
if "`methodvar'" != "" {
	qui {
		generate `mimix_method' = 0
		replace `mimix_method' = 1 if inlist(`methodvar', "MAR", "mar", "Mar", "MAr", "MaR", "Mr", "MR")
		replace `mimix_method' = 2 if inlist(`methodvar', "CR", "cr", "Cr", "cR")
		replace `mimix_method' = 3 if inlist(`methodvar', "J2R", "J2r", "j2r", "j2R")
		replace `mimix_method' = 4 if inlist(`methodvar', "CIR", "CiR", "Cir", "cir", "cIR", "ciR", "CIIR", "CIiR", "ciir")
		replace `mimix_method' = 5 if inlist(`methodvar', "LMCF", "lmcf", "Lmcf", "Last", "last", "LMcf")
		summarize `mimix_method'
    }
	if `r(min)' == 0 	{
		if `mvarspec' == 0	{
			if "`refgroupvar'" == "" {
				display as error "The method() option specified is illegal."
				display as error "Without refgroup() or refgroupvar() options, should be MAR or LMCF."
				exit 198
			}
			else {
				display as error "The method() option specified is illegal."
				display as error "Should be one of MAR, CR, J2R, CIR or LMCF."	
				exit 198
			}
		}
		else {
			if "`refgroupvar'" == "" 	{
				display as error "There are illegal values in the method variable `methodvar'."
				display as error "Without refgroup() or refgroupvar() options, should be MAR or LMCF."
				exit 198
			}
			else {
				display as error "There are illegal values in the method variable `methodvar'."
				display as error "Should be one of MAR, CR, J2R, CIR or LMCF."	
				exit 198
			}
		}
	}
	if "`refgroupvar'" == "" {
		qui generate `flag1' = 0
		qui replace `flag1' = 1 if inlist(`mimix_method', 2, 3, 4)
		qui summarize `flag1'
		if `r(max)' == 1 {								
			if `mvarspec' == 0 {
				display as error "The method specification is illegal because you have not specified a reference group."
				display as error "method() should be 'MAR' or 'LMCF', or you should use the refgroup() option."
				exit 198
			}
			else if `mvarspec' == 1 {
				display as error "The method specification is illegal because you have not specified a reference group."
				display as error "method values should be 'MAR' or 'LMCF', or you should use the refgroup() option."
				exit 198
			}
		}
		qui drop `flag1'
	}
}


*CHECK interim SPECIFICATION
if "`interim'"!=""{
	local interim_t = "`interim'"
	local interim_c = 1
	local interim_r = 0
	if "`interim'"=="MAR" {
		local interim = 1
		local interim_c = 0
	}
	if "`interim'"=="mar" {
		local interim = 1
		local interim_c = 0
	}
	if "`interim'"=="CR" {
		local interim = 2
		local interim_c = 0
		local interim_r = 1
	}
	if "`interim'"=="cr" {
		local interim = 2
		local interim_c = 0
		local interim_r = 1
	}
	if "`interim'"=="J2R" {
		local interim = 3
		local interim_c = 0
		local interim_r = 1
	}
	if "`interim'"=="j2r" {
		local interim = 3
		local interim_c = 0
		local interim_r = 1
	}
	if "`interim'"=="CIR" {
		local interim = 4
		local interim_c = 0
		local interim_r = 1
	}
	if "`interim'"=="cir" {
		local interim = 4
		local interim_c = 0
		local interim_r = 1
	}
	if "`interim'"=="LMCF" {
		local interim = 5
		local interim_c = 0
	}
	if "`interim'"=="lmcf" {
		local interim = 5
		local interim_c = 0
	}
}
if "`interim'"!="" {
	if `interim_c' !=0 {
		display as error "The interim() option specified is illegal."
		display as error "Should be one of MAR, CR, J2R, CIR or LMCF."	
		exit 198
	}
}
*CHECK iref IS A VALID NUMBER OR STRING, i.e. A TREATMENT LEVEL IF THIS OPTION IS USED
if "`iref'" != "" {
	qui levelsof `treat', clean local(levels)
	foreach l of local levels {
		if "`iref'" == "`l'" {
			local check2i = 1
		}
	}
	if "`check2i'" == "" {
		di as error "The iref specification is not a valid treatment group"
		di as error "The specified treatment group variable `treat' contains values: `levels'"
		exit 198
	}
}
*IF INTERIM IS CR, J2R of CIR check WE HAVE A iref SPECIFICAITON
if "`interim'" != "" {
	if "`iref'" == "" {
		if `interim_r' == 1 {
			display as error "The interim imputation method specification is illegal because you have not specified a interim reference group."
			display as error "interim() should be 'MAR' or 'LMCF', or you should use the iref() option."
			exit 198
		}
	}
}
if "`iref'" != "" {
	if "`interim'" == "" {
		if "`method'"!=""{
			display as error ""
			display as error "Warning: iref() has been specified, however interim() has not."
			display as error "Interim missing values are imputed as dropout, using `method'."
			display as error ""
			}
		else {
			display as error ""
			display as error "Warning: iref() has been specified, however interim() has not."
			display as error "Interim missing values are imputed as dropout, using `methodvar'."
			display as error ""
		}
	}
}


*CHECK m IS >=1
if `m'<=0 {
	display as error "m must be greater than or equal to 1"
	exit 198
}

*REMOVE OBSERVATIONS WITH INCOMPLETE COVARIATES & DISPLAY THE NUMBER DROPPED.
*CHECK COVARIATES ARE THE SAME ACROSS TIME POINTS BY ID NUMBER. IF NOT WARN AND TAKE FIRST VALUE.
if "`covariates'" != "" {
	forvalues i = 1/`ncov' {
		qui by `id': replace `cov`i'' = `cov`i''[1] if (`cov`i''[_n] != `cov`i''[_n-1]) & _n != 1
	}
	qui misstable patterns `covariates'
    if `r(N_incomplete)' != 0 {
		forvalues i = 1/`ncov' {
			qui drop if `cov`i'' == .
		}
		local npatients= `r(N_incomplete)'/`ntime'
		if `npatients'==1{
			display as error "Warning: `npatients' individual has missing covariate values and has been dropped."
			display as error "Type -misstable patterns `covariates'- to investigate."
		}
		if `npatients'>1 {
			display as error "Warning: `npatients' individuals have missing covariate values and have been dropped."
			display as error "Type -misstable patterns `covariates'- to investigate."
		}
    }
}


*DROP VARIABLES WE DON'T NEED IN THE IMPUTATION MODEL
qui keep `varlist' `time' `id' `methodvar' `refgroupvar' `covariates' `mimix_method' 	
qui save `mimix_d1'
qui tabulate `treat'
local ntreat = `r(r)'
cap drop __00*
by `id', sort: generate `nvals' = _n == 1
qui count if `nvals'
local nid = r(N)
return scalar N = `nid'
matrix define r1 = J(1,`ntreat',0)
forvalues ir=1/`ntreat' {
	qui count if `nvals'
	local sample`ir' = r(N)
	matrix r1[1,`ir'] = `sample`ir''
}
return matrix Ntreat = r1
drop `nvals'
local id_by_time=`nid'*`ntime'
generate `nobs'=_n
qui summ `nobs'
drop `nobs'

*CHECK ONE ENTRY PER ID PER TIME POINT - REQUIRED - IF NOT ADVISE APPROPRIATE ACTION
if `id_by_time'!=r(max) {

	noi di as error "Warning:" as error " The data set does not have one entry per `id' per `time'."
	noi di as error ""
	noi di as result "         `ntime' " as text "unique levels of `time' exist in the data."
	noi di as text ""
	noi di as text "         If this is correct please type,"
	noi di as text "         -reshape wide `response', i(`id') j(`time')-"
	noi di as text "         -reshape long `response', i(`id') j(`time')-"
	noi di as text "         to obtain the required data format for mimix and re-run."
	noi di as text "         Note: if you have any additional variables in your data set that are not constant" 
	noi di as text "         within `id' add these to the list of xij variables to be reshaped, or drop them."
	noi di as text ""
	noi di as text "         If this is not correct type -tab `time'- to identify any data errors in the `time' variable."
	exit 459
}
*SAVE ORIGINAL DATA - WITH ANY CORRECTIONS MADE FOR COVARIATES
qui save `mimix_mj0'
qui use `mimix_d1', clear
contract `time'
drop _freq
qui generate `mimix_time' = _n
qui mkmat `mimix_time' `time', mat(mimix_time)
qui save `my_time'
qui use `mimix_d1', clear
contract `treat'
drop _freq
qui generate `mimix_treat' = _n
*FOR LATER RECODE:
cap confirm numeric variable `treat'
if `c(rc)'==0 {
	mkmat `mimix_treat' `treat', mat(mimix_treat)
}
else {
	forvalues i=1/`ntreat' {
		local mimix_a`i' = `treat'[`i']
		local mimix_b`i' = `mimix_treat'[`i']
	}
}
*RECODE iref
if "`iref'"!="" {
	cap confirm number `iref'
		if `c(rc)'==0 {
			forvalues i=1/`ntreat' {
				if mimix_treat[`i',2]==`iref' {
					local iref_mimix = mimix_treat[`i',1]
				}
			}
		}
		else {
			forvalues i=1/`ntreat' {
				if "`mimix_a`i''"=="`iref'" {
				local iref_mimix = "`mimix_b`i''"
				}
			}
		}
	}
qui save `my_treat'
local nct = `ntime'	
if "`covariates'" != ""	{
	local nct = `ncov' + `ntime'
}
qui merge m:m `treat' using `mimix_d1', nogenerate
sort `id' `time'
qui duplicates tag `id' `time', gen(`dupcheck')
qui summarize `dupcheck'
if `r(max)' == 1 {
	di as error "There are duplicate time entires for some individuals"
	display as error "Type -duplicates list `id' `time'- to investigate."
	exit 498
}
qui drop `dupcheck'
qui merge m:m `time' using `my_time', nogenerate
sort `id' `time'
drop `time'
drop `methodvar'
*RESHAPE 
*ALSO CHECKS IMPUTATION METHOD IS CONSISTENT WITHIN ID AND TREATMENT GROUP/RESPONE AROUND CORRECT WAY
qui cap reshape wide `response', i(`id') j(`mimix_time')

if _rc==119 {

	di as error "The following internal command failed: reshape wide `response', i(`id') j(`time')"
	di as error "Perhaps you are trying to use a data set that is already mi set"
	local rc=_rc	
	exit `rc'
}
if _rc==9 {
	di as error "The following internal command failed: reshape wide `response', i(`id') j(`time')"
	di as error "Perhaps the response/dependent variable and treatment variable are specified around the wrong way"
	di as error "Mimix syntax requires: mimix depvar treatvar, ...."
	di as error "Or, perhaps your methodvar/refgroupvar specification is not constant within `id' over `time'"
	local rc=_rc
	exit `rc'
}
if _rc!=0 & ( _rc!= 9 | _rc!=119)  {
	di as error "The following internal command failed: reshape wide `response', i(`id') j(`time')"	
	di as error "Check your `response', `time' and `id' variables"	
	local rc=_rc
	exit `rc'
}

return scalar burnin = `burnin'
return scalar bbetween = `burnbetween'
return local depvar `response'
return local treatvar `treat'
return local covariates `covariates'
	
if "`method'" != "" {
	return local method `method'
}
else {
	return local methodvar `methodvar'
}

if "`refgroup'" != "" {
	return local rgroup `refgroup'
	}

else {
	return local rgroupvar `refgroupvar'
	}

*CREATE MISSING DATA PATTERN VARIABLE
qui generate `pattern' = 0
forvalues i = 1/`ntime' {
	local k2 = 2^(`i'-1)
	qui replace `pattern' = `pattern' + `k2'  if `response'`i' == .
}
qui count if `pattern' == 0
return scalar Ncomp = r(N)
return scalar Nmiss = `nid' - r(N)
matrix define r4 = J(1,`ntreat',0)
forvalues ir = 1/`ntreat' {
	qui tab `pattern' if `mimix_treat' == `ir'
	local pat_`ir' = r(r)
	matrix r4[1,`ir']=`pat_`ir''												
}
return matrix Ntreat_pat = r4
sort `mimix_treat' `mimix_method' `refgroupvar' `pattern' `id' 

*ADD INTERIM VALUE INDICATOR IF TREATING INTERIM VALUES DIFFERENTLY

if "`interim'"!="" {
	local ntimeminus =`ntime'-1
	tempvar inter1
	qui generate `inter1'=0
	*Note: if ntime==1 there are no interim missing values.
	if `ntime'==2{
		qui replace `inter1'=1 if `response'1==. & `response'2!=.
	}
	if `ntime'>=2{
		qui replace `inter1'=1 if `response'1==. & `response'2!=.
		
		forvalues i=2/`ntimeminus' {
			local j = `i'+1
			qui replace `inter1'=1 if `response'`i'==. & `response'`j'!=.
		}
	}
}
qui save `mimix_d2'

*IF interim - CREATE A VARIABLE THAT HOLDS THE NAMES OF THE INTERIM MISSING VALUES. SAVE THIS VARIABLE AND `id' FOR LATER DATA MERGING
qui {
	if "`interim'"!="" {
		keep if `inter1'==1
		generate `mimix_intern_req'=""
		if `ntime'==2{
			replace `mimix_intern_req'= "`response'`1'" if `response'1==. & `response'2!=.
		}
		if `ntime'>=2{
			forvalues k=1/`ntimeminus'{
				forvalues l=2/`ntime'{
					replace `mimix_intern_req'= `mimix_intern_req' + " " + "`response'`k'" if `response'`k'==. & `response'`l'!=.
				}
			}
		}
		keep `id' `mimix_intern_req'
		tempfile intermediate
		save `intermediate', replace
		use `mimix_d2', clear
	}
}

*RECODE `id' AS A NUMERICAL VARIABLE IF NOT THE CASE FOR SUBSEQUENT MATRIX MANIPULATION OF THE DATA. SAVE RECODE FOR LATER MERGING.
qui {
	if `id_num'!=0 {
		gen `numerical_id'=_n
		keep `id'  `numerical_id'
		save `id_code', replace
		use `mimix_d2', clear
		gen `numerical_id'=_n
		drop `id'
		rename `numerical_id' `id'
		qui save `mimix_d2', replace
	}
}

*VARIABLES TO BE IMPUTED IN mi impute mvn 
local mi_impute = ""
local res_list = ""
forvalues i = 1/`ntime' {
	local mi_impute = "`mi_impute' `response'`i'"
	if `i'!=`ntime'{
		local res_list = "`res_list' `response'`i'==. |"
	}
	else {
		local res_list = "`res_list' `response'`i'==."
	}
}	
if "`covariates'"!=""	{
	local mi_impute = "`mi_impute' `covariates'"
}

cap confirm numeric variable `treat'
if _rc==0{
	qui summ `refgroupvar'
	if r(mean)==. {
		display as error "There are illegal values in the control-level variable `refgroupvar'. "
		display as error "Values should be one of the treatment groups. Type - tab `refgroupvar' , miss - to investigate."
		exit 198
	}

}
*CHECK AND RECODE THE REFERENCE GROUP VARIABLE TO CORRESPOND WITH `mimix_treat'
if "`refgroupvar'" != "" 		{
	contract `treat' `mimix_treat'
	rename `treat' `refgroupvar'
	qui drop _freq
	tempvar mimix_refgroupvar
	rename `mimix_treat' `mimix_refgroupvar'
	qui save `treat_code'
	qui use `mimix_d2'
	tempvar mimix_merge
	qui merge m:1 `refgroupvar' using `treat_code', gen(`mimix_merge')
	*Note: MERGE = 2 REFERS TO TREATMENT GROUPS THAT ARE NOT SPECIFIED AS CONTROL SO CAN BE DROPPED
	qui drop if `mimix_merge' == 2
	qui count if `mimix_merge' == 1
	drop `mimix_merge'
	local flag2 = r(N)
	
	if "`refgroup'"!=""{
	
		qui levelsof `refgroupvar', clean local(levels)
	
		if `flag2' == 1 {
		display as error "Warning: The refgroup specification of `levels' is illegal, should be one of the treatment groups."
		display as error "The specified treatment group variable treat contains values: `levels2'"
		exit 198
	}
	if `flag2'>1 {
		display as error "Warning: The refgroup specification of `levels' is illegal, should be one of the treatment groups."
		display as error "The specified treatment group variable treat contains values: `levels2'"
		exit 198
		}
	
	}
	
	if "`refgroup'"==""{
	
	if `flag2' == 1 {
		display as error "Warning: `flag2' individual has an illegal values in the control-level variable `refgroupvar'."
		display as error "Should be one of the treatment groups. Type - tab `refgroupvar' , miss - to investigate."
		exit 198
	}
	if `flag2'>1 {
		display as error "Warning: `flag2' individuals have illegal values in the control-level variable `refgroupvar'."
		display as error "Should be one of the treatment groups. Type - tab `refgroupvar' , miss - to investigate."
		exit 198
		}
		
	}
}
contract `mimix_treat' `mimix_method' `mimix_refgroupvar' `pattern'
qui generate `indicator'=_n
rename _freq mimix_count
qui summ `indicator'
local max_indicator = r(max)
mkmat `mimix_treat' `mimix_refgroupvar' `mimix_method' `pattern' mimix_count, mat(mimix_group)
local matrixcols = colsof(mimix_group)
local burninM = `burnin' + ((`m'-1)*`burnbetween')

* RUN MI IMPUTE MVN
return scalar M = `m'
forvalues i = 1/`ntreat'{
	tempfile mimix_parms_a`i' 
	qui use `mimix_d2', clear
	qui keep if `mimix_treat' == `i'
	qui generate `miss_ind' = 0
    qui replace `miss_ind' = 1 if `res_list'
	qui tab `miss_ind'
	if r(r) == 1 {
		local new = _N + 1
		qui set obs `new'
		sort `id'
		qui summ `id', mean
		qui replace `id' = `r(max)' + 1 in `new'
	}
	drop `miss_ind'
	*MI SET THE DATA WIDE IF SIZE ALLOWS FOR SPEED, ALTERNATIVELY MLONG
	qui describe
	local miset = `r(k)' + (`nct'*`m') + 3
	if `miset'>=2048 {
		qui mi set mlong
	}
	else {
		qui mi set wide
	}
	qui mi register imputed `mi_impute'
    display as text "Performing imputation procedure for group " as result "`i'" as text " of " as result "`ntreat'" as text "..."
	
	qui mi impute mvn `mi_impute' ,  mcmconly burnin(`burninM')  prior(jeffreys) initmcmc(em, iter(1000)) saveptrace(`mimix_parms_a`i'', replace)
    
	local N_miss`i' = r(N_mis_em)
	local N_iter`i' = r(niter_em)
	local lpobs_em`i' = r(lpobs_em)
	local conv`i' = r(converged_em)
	
	mi ptrace use `mimix_parms_a`i'', clear
	local burn = `burnin' - 1
	qui drop in 1/`burn'
	qui keep if !mod(_n-1,`burnbetween')
	qui generate `mimix_treat' = `i'
	drop m iter		
	capture mata: mata drop mimix_all
	mata: mimix_all= st_data( ., .)		
	forvalues k=1/`m' {						
		mata: mean_group`i'_imp`k' = mimix_all[`k',1..`nct']
		mata: mata_VAR_group`i'_imp`k'=J(`nct',`nct',0)
		local step = `nct'+ 1
		forvalues r = 1/`nct' {				
			forvalues j = 1/`nct'{ 
				if `j' <= `r' {
					mata: mata_VAR_group`i'_imp`k'[`r', `j'] = mimix_all[`k', `step']
					local step = `step' + 1
				}
			}
		}
		mata: mata_VAR_group`i'_imp`k' = makesymmetric(mata_VAR_group`i'_imp`k')
	}	 
}

matrix define r2 = J(1,`ntreat',0)
matrix define r3 = J(1,`ntreat',0)
matrix define r5 = J(1,`ntreat',0)
matrix define r6 = J(1,`ntreat',0)
matrix define r7 = J(1,`ntreat',0)

forvalues i = 1/`ntreat' {
    local N_complete`i' = `sample`i'' - `N_miss`i''
    matrix r2[1,`i'] = `N_miss`i''
    matrix r3[1,`i'] = `N_complete`i''
    matrix r5[1,`i'] = `N_iter`i''
    matrix r6[1,`i'] = `lpobs_em`i''
    matrix r7[1,`i'] = `conv`i''							
}

return matrix Ntreat_miss = r2
return matrix Ntreat_comp = r3
return matrix niter_em = r5
return matrix lpobs_em = r6
return matrix conv_em = r7

qui {	
    *CREATE AN EMPTY MATRIX FOR COLLECTING IMPUTED DATA 	
	*IF interim IS USED, SET THIS MATRIX SO THAT IT HAS AN EXTRA `nct' COLUMNS FOR MAR IMPUTATIONS
    local nct2 = `nct' + 2
    local nct3 = `nct'+3
	if "`interim'"!="" {
		local nct3inter1 = `nct'+4+`nct'
		mata: mata_all_new = J(1, `nct3inter1',.)
	}
	if "`interim'"==""  {
		mata: mata_all_new = J(1, `nct3',.)
	}
    local rstart = 1
    *FOR EACH TREATMENT GROUP AND MISSING DATA PATTERN COMPUTE 1) APPROPRIATE JOINT DISITRBUTION 2) IMPLIED CONDITIONAL DISTRIBUTION 
    *3) DRAW MISSING DATA FROM (2) `m' TIMES

    forvalues i = 1/`max_indicator'{
		if `matrixcols' == 5 {
			local trt_grp= mimix_group[`i',1]
			local meth= mimix_group[`i',3]
			local refer= mimix_group[`i',2]
			local pat= mimix_group[`i',4]
			local counter= mimix_group[`i',5]
		}
		else {
			local trt_grp= mimix_group[`i',1]
			local meth= mimix_group[`i',2]
			local refer= mimix_group[`i',5]
			local pat= mimix_group[`i',3]
			local counter= mimix_group[`i',4]
		}
		*CREATE VECTORS OF MISSINGNESS INDICATORS AND MISSINGNESS LOCATIONS
		mata: mata_miss = J(`ntime',1,0)
		mata: mata_nonmiss = J(`ntime',1,1)
		local k = (2^`ntime')
		local mypat = `pat'
		forvalues j = `ntime'(-1)1{	
			local k = `k'/2
				while `mypat' >= `k' {
					local mypat = `mypat' - `k'
					mata: mata_miss[`j',1] = 1
					mata: mata_nonmiss[`j',1] = 0
				}
		}
		if "`covariates'" != "" {
			mata: mata_miss=(mata_miss\ mata_covflag)
			mata: mata_nonmiss=(mata_nonmiss\ mata_covflag_nm)
		}									
		mata: st_matrix("stata_miss", mata_miss)
		mata: st_matrix("stata_nonmiss", mata_nonmiss)

		local list_required = ""
		local nct_m1 = `nct'-1
		local nonmiss_count = 0					
		forvalues s = 1/`nct'   {
			if stata_nonmiss[`s', 1] == 1 { 
				local nonmiss_count = `nonmiss_count' + 1
				local r_text `s',
				local list_required `list_required' `r_text'
			}
		}
		if "`list_required'" != "" {
			local list_test = length("`list_required'")
			local length2 = `list_test' - 1
			local list_required = substr("`list_required'", 1, `length2')
			mat S_nonmiss = (`list_required')
			mata: mata_S_nonmiss = st_matrix("S_nonmiss")
		}			
		if "`list_required'" == ""  {
			mat S_nonmiss = J(1,1,.)
			mata: mata_S_nonmiss = st_matrix("S_miss")
		} 													   
		local list_required_miss = ""
		local miss_count = 0
		forvalues s = 1/`nct'	  {
			if stata_miss[`s',1] == 1 {	
				local miss_count = `miss_count' + 1
				local r_text2 `s',
				local list_required_miss `list_required_miss' `r_text2'
			}
		}
		if "`list_required_miss'" != ""{
			local list_test = length("`list_required_miss'")
			local length2 = `list_test' - 1
			local list_test2 = substr("`list_required_miss'", 1, `length2')
			mat S_miss = (`list_test2')
			mata: mata_S_miss = st_matrix("S_miss")
		}								
		if "`list_required_miss'" == ""{
			mat S_miss = J(1,1,.)
			mata: mata_S_miss = st_matrix("S_miss")
		}
		*OBSERVED DATA FOR THE TREATMENT GROUP/MISSING DATA PROFILE IS KEPT IN MATA MATRIX: mata_obs
		local rend = `rstart' + `counter' - 1
		use `mimix_d2', clear 
		keep in `rstart'/`rend'						
		if "`covariates'" != "" {
			forvalues t = 1/`ncov'{
				local amount = `ntime'+`t'
				rename `cov`t'' `response'`amount'
			}			
		}														
		drop  `treat' `mimix_treat' `refgroupvar' `mimix_method' `pattern'
		order `response'1 - `response'`nct', sequential
		order  `id', last
		*Note: `intern1' variable IS KEPT HERE IF INTERIM OPTION IS USED 
		if "`interim'"!="" {
			order  `inter1', last
		}
		mata: mata_obs= st_data( . , .)
		*Note: SO IF INTERIM IS USED mata_obs CONTAINS intern1 indicator & mata_all_new HAS SPACE FOR IT AS ALREADY DECLARED
		forvalues imp = 1/`m'{
        *FOR INDIVIDUALS WITH NO MISSING DATA COPY COMPLETE DATA INTO THE NEW DATA MATRIX mata_all_new `m' TIMES
			if `pat' == 0{
				mata: mata_new = (mata_obs)
				mata: GI = J(`counter',1,`trt_grp')
				mata: II = J(`counter',1, `imp')
				if "`interim'"==""{
					mata: mata_new = ( GI, II, mata_new)
				}
				if "`interim'"!=""{
					mata: dummy = J(`counter',`nct', .)
					mata: mata_new = ( GI, II, mata_new, dummy)
				}
				mata: mata_all_new = (mata_all_new \ mata_new)
			}			
			*USE DRAWS OF MEAN AND COVARIANCE MATRICES FROM mi impute IN CONSTRUCTION DEPENDING ON SPECIFIED METHOD	
			else {
			
				*Interim MAR: IF interim IS USED, REGARDLESS OF MNAR METHOD ADD IN mata_MARMeans		
				if "`interim'"!=""{
					*MAR interim:
					if `interim' ==1 {
						mata: mata_MAR_Means= J(`counter', 1, mean_group`trt_grp'_imp`imp')
						mata: MAR_Sigma = mata_VAR_group`trt_grp'_imp`imp'
						if "`list_required'" != "" {
							mata: MAR_S11 = mata_VAR_group`trt_grp'_imp`imp'[mata_S_nonmiss, mata_S_nonmiss]
							mata: MAR_S12 = mata_VAR_group`trt_grp'_imp`imp'[mata_S_nonmiss, mata_S_miss]
							mata: MAR_S22 = mata_VAR_group`trt_grp'_imp`imp'[mata_S_miss, mata_S_miss]
						}
					}
					*CR interim:
					if `interim' ==2 {
						mata: mata_MAR_Means= J(`counter', 1, mean_group`iref_mimix'_imp`imp')
						mata: MAR_Sigma = mata_VAR_group`iref_mimix'_imp`imp'
						if "`list_required'" != "" {
							mata: MAR_S11 = mata_VAR_group`iref_mimix'_imp`imp'[mata_S_nonmiss, mata_S_nonmiss]
							mata: MAR_S12 = mata_VAR_group`iref_mimix'_imp`imp'[mata_S_nonmiss, mata_S_miss]
							mata: MAR_S22 = mata_VAR_group`iref_mimix'_imp`imp'[mata_S_miss, mata_S_miss]
						}
					}
					*J2R interim:
					if `interim' ==3 {
						mata: mata_MAR_Means= J(`counter', 1, mean_group`trt_grp'_imp`imp')
						mata: INT_MeansC= J(`counter', 1, mean_group`iref_mimix'_imp`imp')
						
						
						mata: INT_cc = mata_S_miss'
						mata: INT_cc=sort(INT_cc, 1)
						mata: INT_cc = INT_cc'
						forvalues b=1/`miss_count'{
							forvalues c=1/`counter' {
								mata: mata_MAR_Means[`c', INT_cc[1,`b']] = INT_MeansC[`c', INT_cc[1,`b']]
							}
						}
						mata: MAR_Sigma = mata_VAR_group`iref_mimix'_imp`imp'
						if "`list_required'" != "" {
							mata: MAR_S11 = mata_VAR_group`iref_mimix'_imp`imp'[mata_S_nonmiss, mata_S_nonmiss]
							mata: MAR_S12 = mata_VAR_group`iref_mimix'_imp`imp'[mata_S_nonmiss, mata_S_miss]
							mata: MAR_S22 = mata_VAR_group`iref_mimix'_imp`imp'[mata_S_miss, mata_S_miss]
						}
					}
					*CIR interim:
					if `interim' ==4 {
						mata: mata_MAR_Means= J(`counter', 1, mean_group`trt_grp'_imp`imp')
						mata: INT_MeansC= J(`counter', 1, mean_group`iref_mimix'_imp`imp')
					mata: INT_cc = mata_S_miss'
					mata: INT_cc=sort(INT_cc, 1)
					mata: INT_cc = INT_cc'
					mata: st_matrix("INT_cc", INT_cc)
					forvalues b=1/`miss_count'{
						if INT_cc[1, `b']==1 {
							forvalues c=1/`counter' {
								mata: mata_MAR_Means[`c', `b'] = INT_MeansC[`c', `b']													
							}
						}
						else {
							forvalues c=1/`counter' {	
								mata: mata_MAR_Means[`c', INT_cc[1,`b']] = mata_MAR_Means[`c',INT_cc[1,`b']-1]+ INT_MeansC[`c', INT_cc[1,`b']]- INT_MeansC[`c', INT_cc[1,`b']-1]									
							}
						}
					}
						mata: MAR_Sigma = mata_VAR_group`iref_mimix'_imp`imp'
						if "`list_required'" != "" {
							mata: MAR_S11 = mata_VAR_group`iref_mimix'_imp`imp'[mata_S_nonmiss, mata_S_nonmiss]
							mata: MAR_S12 = mata_VAR_group`iref_mimix'_imp`imp'[mata_S_nonmiss, mata_S_miss]
							mata: MAR_S22 = mata_VAR_group`iref_mimix'_imp`imp'[mata_S_miss, mata_S_miss]
						}
					}
					*LMCF interim:
					if `interim' ==5 {
						mata: mata_MAR_Means= J(`counter', 1, mean_group`trt_grp'_imp`imp')
						mata: INT_cc = mata_S_miss'
						mata: INT_cc=sort(INT_cc, 1)
						mata: INT_cc = INT_cc'
						mata: st_matrix("INT_cc", INT_cc)
						forvalues b=1/`miss_count' {
							if INT_cc[1, `b']>1 {
								forvalues c=1/`counter' {
									mata: mata_MAR_Means[`c', INT_cc[1,`b']] = mata_MAR_Means[`c', INT_cc[1,`b']-1]
								}
							}
						}
						mata: MAR_Sigma = mata_VAR_group`trt_grp'_imp`imp'
						if "`list_required'" != "" {
							mata: MAR_S11 = mata_VAR_group`trt_grp'_imp`imp'[mata_S_nonmiss, mata_S_nonmiss]
							mata: MAR_S12 = mata_VAR_group`trt_grp'_imp`imp'[mata_S_nonmiss, mata_S_miss]
							mata: MAR_S22 = mata_VAR_group`trt_grp'_imp`imp'[mata_S_miss, mata_S_miss]
						}
					}
				}
				
				if `meth' == 1 {
					*MAR 
					mata: mata_Means= J(`counter', 1, mean_group`trt_grp'_imp`imp')
					mata: Sigma = mata_VAR_group`trt_grp'_imp`imp'
					if "`list_required'" != "" {
						mata: S11 = mata_VAR_group`trt_grp'_imp`imp'[mata_S_nonmiss, mata_S_nonmiss]
						mata: S12 = mata_VAR_group`trt_grp'_imp`imp'[mata_S_nonmiss, mata_S_miss]
						mata: S22 = mata_VAR_group`trt_grp'_imp`imp'[mata_S_miss, mata_S_miss]
					}
				}
                                      
				if `meth' == 2 {
					*CR 
					mata: mata_Means= J(`counter', 1, mean_group`refer'_imp`imp')
					mata: Sigma = mata_VAR_group`refer'_imp`imp'
					if "`list_required'" != "" {
						mata: S11 = mata_VAR_group`refer'_imp`imp'[mata_S_nonmiss, mata_S_nonmiss]
						mata: S12 = mata_VAR_group`refer'_imp`imp'[mata_S_nonmiss, mata_S_miss]
						mata: S22 = mata_VAR_group`refer'_imp`imp'[mata_S_miss, mata_S_miss]
					}
				}

				if `meth' == 3	{
					*J2R 
					mata: mata_Means= J(`counter', 1, mean_group`trt_grp'_imp`imp')
					mata: MeansC= J(`counter', 1, mean_group`refer'_imp`imp')
					mata: cc = mata_S_miss'
					mata: cc=sort(cc, 1)
					mata: cc = cc'
					forvalues b=1/`miss_count'{
						forvalues c=1/`counter' {
							mata: mata_Means[`c', cc[1,`b']] = MeansC[`c', cc[1,`b']]
						}
					}
					mata: Sigma = mata_VAR_group`refer'_imp`imp'
					if "`list_required'" != "" {
						mata: S11 = Sigma[mata_S_nonmiss, mata_S_nonmiss]
						mata: S12 = Sigma[mata_S_nonmiss, mata_S_miss]
						mata: S22 = Sigma[mata_S_miss, mata_S_miss]		
					}	
				}
				
				if `meth' == 4	{
					*CIR 
					mata: mata_Means= J(`counter', 1, mean_group`trt_grp'_imp`imp')
					mata: MeansC= J(`counter', 1, mean_group`refer'_imp`imp')
					mata: cc = mata_S_miss'
					mata: cc=sort(cc, 1)
					mata: cc = cc'
					mata: st_matrix("cc", cc)
					forvalues b=1/`miss_count'{
						if cc[1, `b']==1 {
							forvalues c=1/`counter' {
								mata: mata_Means[`c', `b'] = MeansC[`c', `b']													
							}
						}
						else {
							forvalues c=1/`counter' {	
								mata: mata_Means[`c', cc[1,`b']] = mata_Means[`c',cc[1,`b']-1]+ MeansC[`c', cc[1,`b']]- MeansC[`c', cc[1,`b']-1]									
							}
						}
					}
					mata: Sigma = mata_VAR_group`refer'_imp`imp'	
					if "`list_required'" != "" {
						mata: S11 = Sigma[mata_S_nonmiss, mata_S_nonmiss]
						mata: S12 = Sigma[mata_S_nonmiss, mata_S_miss]
						mata: S22 = Sigma[mata_S_miss, mata_S_miss]
					}		
				}

				if `meth' == 5 	{
					*LMCF 
					mata: mata_Means= J(`counter', 1, mean_group`trt_grp'_imp`imp')
					mata: cc = mata_S_miss'
					mata: cc=sort(cc, 1)
					mata: cc = cc'
					mata: st_matrix("cc", cc)
					forvalues b=1/`miss_count' {
						if cc[1, `b']>1 {
							forvalues c=1/`counter' {
								mata: mata_Means[`c', cc[1,`b']] = mata_Means[`c', cc[1,`b']-1]
							}
						}
					}
					mata: Sigma = mata_VAR_group`trt_grp'_imp`imp'
					if "`list_required'" != "" {
						mata: S11 = Sigma[mata_S_nonmiss, mata_S_nonmiss]
						mata: S12 = Sigma[mata_S_nonmiss, mata_S_miss]	
						mata: S22 = Sigma[mata_S_miss, mata_S_miss]
					}
				}
                *FOR CASES WITH NO OBSERVED OUTCOMES:                              
				if `nonmiss_count'==0 {
					mata: U = cholesky(Sigma)
					mata: Z = invnormal(uniform(`counter',`miss_count'))
					mata: mata_y1 = mata_Means + Z*U'
					mata: mata_new = mata_y1[.,.]
					mata: GI=J(`counter',1,`trt_grp')
					mata: II=J(`counter',1, `imp')	
					if "`interim'"==""{
						mata: SNO = mata_obs[.,cols(mata_obs)]
						mata: mata_new= ( GI, II, mata_new, SNO)
					}
					if "`interim'"!=""{
					*DUMMY MAR DATA AS NOT REQUIRED HERE
						mata: dummy = J(`counter',`nct', .)
						mata: INTER = mata_obs[.,cols(mata_obs)]
						mata: SNO = mata_obs[.,cols(mata_obs)-1]
						mata: mata_new = ( GI, II, mata_new, SNO, INTER, dummy)
					}
					mata: mata_all_new = (mata_all_new \ mata_new)
				}
				else {
					*MNAR IMPUTATION:
					local impseed = c(seed)
					mata: m1=mata_Means[., mata_S_nonmiss]
					mata: m2=mata_Means[., mata_S_miss]
					mata: raw1=mata_obs[., mata_S_nonmiss]
					mata: t=cholsolve(S11,S12)
					mata: conds=S22-(S12')*t
					mata: meanval = m2 + (raw1 - m1)*t
					mata: U = cholesky(conds)
					mata: Z = invnormal(uniform(`counter',`miss_count'))
					mata: mata_y1 = meanval + Z*U'
					mata: mata_new =J(`counter', `nct',.)
					mata: mata_new[.,mata_S_nonmiss] = mata_obs[.,mata_S_nonmiss]
					mata: mata_new[.,mata_S_miss] = mata_y1[.,.]
					mata: GI=J(`counter',1,`trt_grp')
					mata: II=J(`counter',1, `imp')
					if "`interim'"==""{
						mata: SNO = mata_obs[.,cols(mata_obs)]
						mata: mata_new= ( GI, II, mata_new, SNO)
						mata: mata_all_new = (mata_all_new \ mata_new)
					}
					*SET SEED SAME HERE AS FOR MNAR GENERATION ABOVE
					if "`interim'"!=""{
					set seed `impseed'
					mata: m1I=mata_MAR_Means[., mata_S_nonmiss]
					mata: m2I=mata_MAR_Means[., mata_S_miss]
					mata: raw1I=mata_obs[., mata_S_nonmiss]
					mata: t=cholsolve(MAR_S11,MAR_S12)
					mata: conds=MAR_S22-(MAR_S12')*t
					mata: meanval = m2I + (raw1I - m1I)*t
					mata: U = cholesky(conds)
					mata: Z = invnormal(uniform(`counter',`miss_count'))
					mata: mata_y1 = meanval + Z*U'
					mata: mata_newI =J(`counter', `nct',.)
					mata: mata_newI[.,mata_S_nonmiss] = mata_obs[.,mata_S_nonmiss]
					mata: mata_newI[.,mata_S_miss] = mata_y1[.,.]
					mata: INTER = mata_obs[.,cols(mata_obs)]
					mata: SNO = mata_obs[.,cols(mata_obs)-1]
					mata: mata_new= (GI, II, mata_new, SNO, INTER, mata_newI)
					mata: mata_all_new = (mata_all_new \ mata_new)
					}
				}
			}	
		}
		local rstart = `rend'+1
    }
    drop _all
    mata: st_addobs(rows(mata_all_new))																							
    mata: varidx = st_addvar("double", st_tempname(cols(mata_all_new)))
    mata: st_store(., varidx, mata_all_new)
    drop in 1
    describe
    local nvars = `r(k)'
    unab varlist: _all
    local count 1
    foreach var of local varlist {
		rename `var' var`count++'
    }							
    rename var1 `mimix_treat'
    rename var2 _mj		
    forvalues i=3(1)`nct2' {
		local time22 = `i'-2
		rename var`i' `response'`time22'
    }
    rename var`nct3' `id'
	*FORMAT THE NEW IMPUTED DATA HERE
	*THIS CURRENTLY LABELE AROUND WRONG WAY!!
	if "`covariates'" != ""{
		local indi = `ntime' + 1
		forvalues i=`indi'(1)`nct' {
			local indi2 = `i'-`ntime'
			rename `response'`i' `cov`indi2''
		}
	}
	*IF ID WAS ORIGINALLY A STRING VAR MERGE ORIGINAL ID
	if `id_num'!=0{
		rename  `id' `numerical_id'
		merge m:1 `numerical_id' using `id_code', nogen
		drop `numerical_id'
	}
	*IF interim = 1, FOR EACH ID LOOK UP INTERIM VALUES & REPLACE AS SPECIFIED
	if "`interim'"!=""{
		local nct5 = `nct'+5
		local nctX = `nct5' + (`ntime'-1)
		forvalues i=`nct5'(1)`nctX' {
			local time22 = `i'-`nct'-4
			rename var`i' `response'`time22'MAR
		}	
	 *SAVE THE NEW DATA WE HAVE SO FAR
		local nct4 = `nct3'+1
		rename var`nct4' `inter1'
		tempfile new_intern
		save `new_intern'
		*KEEP ID's THAT HAVE INTERIM MISSING VALUES & MERGE WITH POSITION INDICATORS OF INTERIM VALUES
		keep if `inter1'==1
		merge m:1 `id' using `intermediate' ,  nogenerate
		summ _mj
		local num = r(N)
		forvalues i =1/`num' {
		*USE MAR IMPUTED VALUES FOR INTERIM MISSING RECORDS
			local req = `mimix_intern_req'[`i']
			foreach var of varlist `req' {
				replace `var'=`var'MAR
			}
		}
		order `id', first
		drop `inter1' -  `mimix_intern_req'
		order `id', last
		append using `new_intern'
		drop if `inter1'==1
		keep `mimix_treat'-`id'  
	}
	reshape long `response', i(`id' _mj) j(`time')
	rename `time' `mimix_time'
	merge m:1 `mimix_time' using `my_time' , nogenerate
	drop `mimix_time'	
	merge m:1 `mimix_treat' using `my_treat' , nogenerate
	drop `mimix_treat'
	drop if _mj==.
	sort _mj `id' `time'
	save `int_out', replace
	*APPEND TO THE ORIGINAL DATA HERE (MINUS CASES WHO HAD COVARIATES MISSING)
	use `mimix_mj0', clear
	append using `int_out'
	replace _mj=0 if _mj==.	
	label variable _mj "imputation number"
	merge m:1 `id' `time' using `add_data' , nogenerate
	order `order' _mj
	save `int_out', replace
}

*MI SET THE NEW IMPUTED DATA SET
qui mi import flong, m(_mj) id(`time' `id' ) clear 
qui drop _mj
restore, not

*REGRESSION OPTION
if "`regress'" == "regress" {
	if `m'>1 {
		display ""
		di as text "Performing regress procedure ..."
		display ""
		xi: mi estimate:regress `response' i.`treat' `covariates' if `time'==`maxtime'	
		cap drop _I*
		
    }
 }

*MIXED OPTION
if "`mixed'" == "mixed" {
	if `m'>1 {
		*BUILD REQUIRED LIST FOR TREATMENT X TIME INTERACTION
		if "`covariates'" != ""{
			local cov_by_time = ""
			forvalues i=1/`ncov' {
				local key4 = "`time'##c.`cov`i''"
				local cov_by_time `cov_by_time' `key4'
			}
			local includer =""
			cap confirm numeric variable `treat'
			if `c(rc)'==0 {
				forvalues tr=2/`ntreat'{
					local two=mimix_treat[`tr',2]
					forvalues i=1/`ntime'{
						local j =mimix_time[`i',2]
						qui generate `treat'`two'_`time'`j'=1 if `treat'==`two' & `time'==`j'
						qui replace `treat'`two'_`time'`j'=0 if `treat'`two'_`time'`j'==.
						local includer="`includer' `treat'`two'_`time'`j'"
					}
				}
			}
			else {
				forvalues tr=2/`ntreat'{
					*local two=`mimix_b`tr''
					*local three="`mimix_a`tr''"
					forvalues i=1/`ntime'{
						local j =mimix_time[`i',2]
						qui generate `treat'_`mimix_a`tr''_`time'`j'=1 if `treat'=="`mimix_a`tr''" & `time'==`j'
						qui replace `treat'_`mimix_a`tr''_`time'`j'=0 if `treat'_`mimix_a`tr''_`time'`j'==.
						local includer="`includer' `treat'_`mimix_a`tr''_`time'`j'"
					}
				}
			}
			display ""
			di as text "Performing mixed procedure ..."
			xi: mi estimate: mixed `response'  `cov_by_time' `includer'  || `id':, nocons res(uns, t(`time') by(`treat')) reml
		}
		else {
			local includer =""
			cap confirm numeric variable `treat'
			if `c(rc)'==0 {
				forvalues tr=2/`ntreat'{
					local two=mimix_treat[`tr',2]
					forvalues i=1/`ntime'{
						local j =mimix_time[`i',2]
						qui generate `treat'`two'_`time'`j'=1 if `treat'==`two' & `time'==`j'
						qui replace `treat'`two'_`time'`j'=0 if `treat'`two'_`time'`j'==.
						local includer="`includer' `treat'`two'_`time'`j'"
					}
				}
			}
			else {
				forvalues tr=2/`ntreat'{
					forvalues i=1/`ntime'{
						local j =mimix_time[`i',2]
						qui generate `treat'_`mimix_a`tr''_`time'`j'=1 if `treat'=="`mimix_a`tr''" & `time'==`j'
						qui replace `treat'_`mimix_a`tr''_`time'`j'=0 if `treat'_`mimix_a`tr''_`time'`j'==.
						local includer="`includer' `treat'_`mimix_a`tr''_`time'`j'"
						}
			
					}
				}
			display ""
			di as text "Performing mixed procedure ..."
			xi: mi estimate: mixed `response'  i.`time' `includer'  || `id':, nocons res(uns, t(`time') by(`treat')) reml
		}
	}	
}
*SAVING AND CLEAR OPTIONS
if "`saving'" != "" & "`clear'" == "" {
	display ""	
    if 	"`method'" != "" {
		local method_spec = "`method'"
		display as text "Imputed data created in variable " as result "`response'" as text " and saved in " as result "`filename'.dta" as text " under " as result "`method_spec'" as text " assumption."
    }
    else {
		display as text "Imputed data created in variable " as result "`response'" as text " and saved in " as result "`filename'.dta"
		display as text "The variable " as result "`methodvar'" as text " specifies the imputation method for each individual"
    }
	cap drop __00*
    qui save `filename', `replace'
    qui use `orig_data', clear
}
                
else if "`clear'" != "" & "`saving'" == "" {
	display ""
	display as text "Imputed dataset now loaded in memory"
	if 	"`method'" != "" {
		local method_spec = "`method'"
		display as text "Imputed data created in variable" as result " `response'" as text " using" as result " `method_spec'"	
	}
	else {
		display as text "Imputed data created in variable" as result " `response'"
		display as text "The variable" as result " `methodvar'" as text " specifies the imputation method for each individual"
	}
}

else {
	display ""
	display as text  "Imputed dataset now loaded in memory"	
	if 	"`method'" != "" {
		local method_spec = "`method'"
		display as text "Imputed data created in variable" as result " `response'" as text " and saved in" as result " `filename'.dta" as text " using" as result " `method_spec'"	
	}
	else {
		display as text "Imputed data created in variable" as result " `response'" as text " and saved in" as result " `filename'.dta"
		display as text "The variable" as result " `methodvar'" as text " specifies the imputation method for each individual"
	}
	cap drop __00*
	qui save `filename', `replace'
}
if "`interim'"!=""{
	display as text "Interim missing data imputed using" as result " `interim_t'"
	return local interim `interim_t'
}
*RETURN OF iref
if "`iref'" != "" {
	return local iref `iref'
}
if "`mixed'" == "mixed"  {
	if `m'==1 {
		display as error "insufficient imputations for mixed command, m>=2 is required"
		error 2001 
	}
}  
if  "`regress'" == "regress" {
	if `m'==1 {
		display as error "insufficient imputations for regress command, m>=2 is required"
		error 2001 
	}
}   
*DROP MATRICES NO LONGER REQURIED
qui {
    forvalues i=1/`ntreat' {
		forvalues j=1/`m'{
			mata: mata drop mean_group`i'_imp`j' mata_VAR_group`i'_imp`j'
      }													
    }
	
    capture mata: mata drop GI  II mata_Means  S11   S12 S22  Sigma  U Z conds m1 m2 mata_all_new raw1 t varidx mata_new  mata_S_miss mimix_all  SNO
	capture mata: mata drop  mata_S_nonmiss   mata_miss  mata_nonmiss  mata_obs mata_y1 meanval  
	capture matrix drop stata_nonmiss  stata_miss  mimix_time 
	capture matrix drop mimix_group
	capture mata: mata drop mata_covflag mata_covflag_nm
	capture matrix drop S_miss 
	capture matrix drop S_nonmiss
	capture matrix drop mimix_treat 
	capture mata: mata drop cc
	capture matrix drop cc
	capture mata: mata drop INT_cc
	capture matrix drop INT_cc
	capture mata: mata drop INT_MeansC
	capture mata: mata drop MeansC
	capture mata: mata drop INTER MAR_S11 MAR_S12 MAR_S22 MAR_Sigma dummy m1I m2I  mata_MAR_Means mata_newI raw1I 
	
	
}

end
exit
