*! version 1.0   01Aug2012
*! Joao Pedro Azevedo and Viviane Sanfelice


cap program drop mpovline
program define mpovline, rclass sortpreserve byable(recall)
	version 10.0, missing
	if c(more)=="on" set more off
	local version : di "version " string(_caller()) ", missing:"
	syntax varlist(numeric min=1 max=1) [if] [in] [aweight fweight], [varpl(varlist numeric) LINEs(numlist sort) mpl(numlist sort) INdicator(string) max]	
			            		
	tempvar  w wwvar point0 point1 aux
	tempname fgt matfgt0 matfgt1 matfgt2 mat_obs
	marksample touse, strok
	
	local n_line = wordcount("`varpl'")
	if ("`mpl'"~="")&("`varpl'"=="") {
		di in red "You must specify a poverty line variable with the option MPL" _new
		exit 198
	}
	if ("`lines'"=="")&("`varpl'"=="") {
		di in red "You must specify a poverty line variable" _new
		exit 198
	}
	if ("`lines'"!="")&("`varpl'"!="") {
		di in red "The LINES and VARPL option should not be combined" _new
		exit 198
	}
	if ("`mpl'"~="")&(`n_line'>1) {
		di in red "the MPL option should not be used when more than one variables is specified in VARPL option" _new
		exit 198
	}

	qui {	
		** Indicator
		if ("`indicator'"=="") {
			local fgt0 "fgt0"
		}
		else {
			local t 0
			forvalues i = 0(1)2 {
				local t = regexm("`indicator'","fgt`i'") + `t'
			}
			if `t'==0 {
				di in red "Indicator not valid"
				exit 198
			}	
			if regexm("`indicator'","fgt0")!=0 local fgt0 "fgt0"
			if regexm("`indicator'","fgt1")!=0 local fgt1 "fgt1"
			if regexm("`indicator'","fgt2")!=0 local fgt2 "fgt2"
		}	
		
		
		** Weight variable
		if ("`weight'"=="") {
			gen `w' = 1
			local wvar "`w'"
		}	
		else {
			local weight "[`weight'`exp']"				
			local wvar : word 2 of `exp'
		}
		sum `wvar'  if `touse' , meanonly
		local pop_sum = r(sum)
		local t_obs = r(N)
		gen double `wwvar' = `wvar'/`pop_sum'
		
		
		** Points
		sum `varlist' if `touse' , meanonly
		local max1 `r(max)'
		local min `r(min)'
		if `min' > 0 local min 0
				
		if ("`max'"=="") local max1 ""	
		
		** varpl
		if ("`varpl'"=="") {
			tempvar varpl
			gen byte `varpl' = 1 if `touse'
			local mpl "`lines'"
			
		}
		if ("`mpl'"=="")&(`n_line'==1) local mpl "1"
		local list2 "`mpl'"		
		if (`n_line'>1) local list2 "`varpl'"
		
		gen double `point0' = .
		gen double `point1' = .
		gen double `aux' = .
		local list1 "`min' `list2'"
		
		local signal "<"
				
		local cont 0
		foreach pt1 in `list2' `max1' {
			
			local ++cont
			local pt0 : word `cont' of `list1'
			
			replace `point0' = `pt0'
			replace `point1' = `pt1'
			
			if ("`mpl'"!="") {	
				replace `point0' = `pt0'*`varpl'
				replace `point1' = `pt1'*`varpl'
			}
			
			if 	"`pt0'"=="`min'" {
				replace `point0' = `min'
			}
			
			if 	"`pt1'"=="`max1'" {
				replace `point1' = `max1'
				local signal "<="
			}	
		
		
			* Observation on range
			if (`n_line'>1) {
				tempvar temp1
				gen `temp1' = 1 if ((`point0'-0.00000001)>`point1') & `touse'
				count if `temp1'==1
				if `r(N)'>0 {
					di in red "The range for poverty lines not valid" _new
					exit 198
				}
			}				
		
			** Number of observation on range
			cap sum `varlist' if (`varlist'>=(`point0'-0.00000001) & `varlist'<`point1') & `touse' , meanonly
			mat `mat_obs' = nullmat(`mat_obs') \ (`cont', `r(N)')

			
			/* Indicators Calculation */
					
					
			*** fgt0						
			tempvar in
			gen double `in' = (`varlist'>=(`point0'-0.00000001) & `varlist'`signal'(`point1')) if `touse'
			if("`fgt0'"~="") {	
				sum `wvar' if `touse' & `in'==1, meanonly
				local pop_sum_in `r(sum)'
				local fgt0 = 100*`pop_sum_in'/`pop_sum'
													
				mat `fgt' = nullmat(`fgt') \ (`cont', 0, `fgt0')
			}	
			
			
			* ** fgt1
			if("`fgt1'"~="") {		
				replace `aux' = 100*`in'*`wwvar'*(((`point1')-`varlist')/(`point1')) if `touse'
				sum `aux'  if `touse' , meanonly
				local fgt1  `r(sum)'
							
				mat `fgt' = nullmat(`fgt') \ (`cont', 1, `fgt1')
			}
						
			
			* ** fgt2
			if("`fgt2'"~="") {					
				replace `aux' = 100*`in'*`wwvar'*((((`point1')-`varlist')/(`point1'))^2) if `touse'
				sum `aux'  if `touse' , meanonly
				local fgt2 `r(sum)'
						
				mat `fgt' = nullmat(`fgt') \ (`cont', 2, `fgt2')	
			}	
		}	
		
	}

tempvar povertyline index  rate
mat colnames `fgt' =  `povertyline' `index' `rate'
svmat double `fgt', n(col)

* ** Show Results
	
label define `index' 	      ///
    0 "Headcount ratio - FGT(0)" ///
	1 "Poverty Gap - FGT(1)"   ///
 	2 "Poverty Severity - FGT(2)"   	
label values `index' `index'
		
label var `index' "Indicator"
label var `rate' "`varlist'"

local line ""
local aux = wordcount("`mpl'")
if (`aux'!=1) | ("`max'"!="") {
	local line "`povertyline'"			
	label var `povertyline' "Poverty line range"
	cap tab `povertyline'
	local m = `r(r)'
	if ("`max'"!="") local m = `r(r)'-1
	if ("`max'"!="") label define `povertyline' `r(r)' "max"
	forvalues i =1(1)`m' {
		local j : word `i' of `list2'
		label define `povertyline' `i' "`j'", add	
	}
	label values `povertyline' `povertyline'
}	
	
tabdisp `index' `line'  if `index'!=. , cell(`rate') format(%12.2fc)

if (`aux'!=1) local pline "pvline_range"
sort `line' `index', stable
if ("`fgt0'"~="") {
	mkmat `line' `rate' if `index'==0, matrix(`matfgt0')
	mat colnames `matfgt0' = `pline' rate
}	
if ("`fgt1'"~="") {
	mkmat `line' `rate' if `index'==1, matrix(`matfgt1')
	mat colnames `matfgt1' = `pline' rate
}
if ("`fgt2'"~="") {
	mkmat `line' `rate' if `index'==2, matrix(`matfgt2')
	mat colnames `matfgt2' = `pline' rate
}
		
*** Save results		
  		
if ("`fgt2'"~="") return matrix fgt2 = `matfgt2'
if ("`fgt1'"~="") return matrix fgt1 = `matfgt1'
if ("`fgt0'"~="") return matrix fgt0 = `matfgt0'

mat colnames `fgt' = pvline_range indicator rate
mat colnames `mat_obs' =  pvline_range obs

if (`aux'==1) mat `fgt' = `fgt'[1...,2..3]		
if (`aux'==1) mat `mat_obs' = `mat_obs'[1...,2]

return matrix b = `fgt'
return matrix obs = `mat_obs'
	
end			
			
