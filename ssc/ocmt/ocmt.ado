*! ocmt v0.8 JOtero and HNunez 20jun2020


capture program drop ocmt
program define ocmt, rclass
version 14

syntax varlist(min=1 numeric ts fv) [if] [in] [, ///
                                           SIGnif(integer -1) ///
										   Delta1(real -1) Delta2(real -1) ///
                                           Zvar(varlist numeric ts fv) ///
										   ]

marksample touse
markout `touse' `tvar'
 
quietly tsreport if `touse'
if r(N_gaps) {
	display in red "sample may not contain gaps"
	exit
}
	
// sets significance level at 5% if not specified by user 
if `signif'<=0 {
	local pvalue = 0.05
	display as result "Significance level not specified. Using default value"
}
else if `signif'>0 {
	local pvalue = `signif'/100
}

if `delta1'<0 | `delta2'<0 {
    local delta1 = 1
	local delta2 = 2
	display as result "delta_1 and delta_2 not specified. Using default values"
}

if `delta1'>=`delta2' {
    display in red "delta_2 must be greater than delta_1"
    exit
}
    
local depvar : word 1 of `varlist'
local xvars : list varlist - depvar

local numvars  : word count `varlist'
local numxvars : word count `xvars'
local numzvars : word count `zvar'

local n = `numxvars'

local pval1 = `pvalue'/(`n'^(`delta1'-1))
local pval2 = `pvalue'/(`n'^(`delta2'-1))
	
local t_threshold1 = invnormal(1-(`pval1'/2/`n'))
local t_threshold2 = invnormal(1-(`pval2'/2/`n'))
	
display "Dependent variable: `depvar'"
display "Active set: `xvars'"
display "Number of variables in active set = " `n'
display "Pvalue = " _skip(8) `pvalue'
display "delta_1 = " _skip(6) `delta1'
display "delta_2 = " _skip(6) `delta2'
display "Pvalue_1 = " _skip(6) `pval1'
display "Pvalue_2 = " _skip(6) `pval2'
display "t_threshold_1 = " `t_threshold1'
display "t_threshold_2 = " `t_threshold2'

if `numzvars'>0 {
	display "Preselected variables (apart from constant): `zvar'"
}
else if `numzvars'==0 {
	display "Preselected variables: Constant"
}

	
local chosen ""	
forvalues i = 1/`numxvars' {
	local var`i' : word `i' of `xvars'
		
	qui reg `depvar' `var`i'' `zvar' if `touse'
	
	local tstat = abs(_b[`var`i'']/_se[`var`i''])
						
	// display "tstat " `tstat' " t_threshold1 " `t_threshold1'
	
	if `tstat'<=`t_threshold1' {
		local chosen `chosen'
	}
	else {
		local chosen `chosen' `var`i''
	}
}

display "Variables chosen in stage 1" 	
display "`chosen'" 
local numchosen : word count `chosen'
	
// display "numchosen " `numchosen'
	
// this reports the regression results if none of the variables in the active set is significant
if `numchosen' == 0 {
	display ""
	display as result  _dup(78) "-"
	display as result  _dup(78) "-"
	display as result "One Covariate at a Time Multiple Testing (OCMT)"
	display as result "Chosen regressors: Includes only constant (and preselected variables if any)"
	display as result  _dup(78) "-"
	reg `depvar' `zvar' if `touse'
	exit
}
	

forvalues j = 2/`n' {

	local toexclude "`chosen'"
	local xvars1 : list xvars - toexclude
	local xvars `xvars1'
	local numxvars : word count `xvars'
    local numchosen : word count `chosen'
    local check0 = `numchosen'
	
	local chosen`j' "`chosen'"
	
	forvalues i = 1/`numxvars' {
	
		local var`i' : word `i' of `xvars'

		qui reg `depvar' `chosen`j'' `var`i'' `zvar' if `touse'
	
		local tstat = abs(_b[`var`i'']/_se[`var`i''])
						
		// display "tstat " `tstat' " t_threshold2 " `t_threshold2'
	
		if `tstat'<=`t_threshold2' {
			local chosen `chosen'
		}
		else {
			local chosen `chosen' `var`i''
		}
	}

	local stage `j'
	
	display "Variables chosen in stage `j'" 
	display "`chosen'" 
	local numchosen : word count `chosen'
	local check1 = `numchosen'

	local check = `check1' - `check0'
	// display "check " `check'
	
	if `check' == 0 {
	local laststage = `stage' - 1
	display ""
	display as result  _dup(78) "-"
	display as result  _dup(78) "-"
	display as result "One Covariate at a Time Multiple Testing (OCMT)"
	display as result "Chosen model after " `laststage' " stages"
	display as result  _dup(78) "-"
	reg `depvar' `chosen' `zvar' if `touse'
	continue, break
	}
}
* next lines added on 29nov2019
local regressors `chosen' `zvar'
return local regressors : list clean regressors
return scalar stages = `laststage'
return scalar threshold1 = `t_threshold1'
return scalar threshold2 = `t_threshold2'
end

