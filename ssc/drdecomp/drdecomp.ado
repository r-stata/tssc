*! version 1.0   01Dec2012
*! Viviane Sanfelice, Andres Castanedas, Joao Pedro Azevedo


cap program drop drdecomp
program define drdecomp, rclass sortpreserve byable(recall)
	version 10.0, missing
	if c(more)=="on" set more off
	local version : di "version " string(_caller()) ", missing:"
	syntax varlist(numeric min=1 max=1) [if] [in] [aweight fweight], by(varname numeric)    ///
			varpl(varname numeric)                                              ///
			[mpl(numlist sort) INdicator(string)]	
	
	tempname a b temp PATH A B C pov_rate		
	tempvar  varname2
	marksample touse, strok
	
	preserve
	
	
	* * Indicator
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
	
	
		* ** Weights
	if ("`weight'"!="") {
		local weight "[`weight'`exp']"				
		local wvar : word 2 of `exp'
	}
	
	markout `touse' `varlist' `wvar' `by' `varpl' , strok
	qui keep if `touse'
	
	
	* ** Comparison variable
	cap tab `by' , matrow(`temp')
	local ct = r(N)
	if r(N)==0 error 2000	
	if (`r(r)'~=2)|(_rc==134) {
		di in red "Only 2 groups allow"
		exit 198
	}		
	local c = `temp'[1,1]
	local d = `temp'[2,1]
	
	local ing1 "`varlist'"
	local ing2 "`varname2'"	
	
		* Generate the varibles that has the same distribution, but have the average from another year
			qui gen double `ing2' = .
			qui sum `ing1' `weight' if `by'==`c' , meanonly
			local m1=r(mean)

			qui sum  `ing1' `weight' if `by'==`d' , meanonly
			local m2=r(mean)

			qui replace `ing2'=`ing1'*(`m2'/`m1') if `by'==`c'
			qui replace `ing2'=`ing1'*(`m1'/`m2') if `by'==`d'
		
						
				
			***=== Datt-Ravallion Decomposition ===***
			
			**** Poverty
			foreach year in `c' `d'{
				foreach income in `ing1' `ing2' {
					qui _mpl `income' `weight' if (`by'==`year' & `touse') , varpl(`varpl') mpl(`mpl') in(`fgt0' `fgt1' `fgt2')
					mat `a' = r(b)
					mat `income'_`year' = `a'[1...,3]
						
				}
			}
				
			mat `A' = ( `ing1'_`c', `ing2'_`c', `ing2'_`d', `ing1'_`d')	
			mat `B' = `a'[1...,1]	
			mat `C' = `a'[1...,2]
			
			* * Matrix of the three effects: Total, Growth and Distribution respectively
				
			mat `PATH' = nullmat(`PATH') \ /*
				*/	( J(rowsof(`A'), 1, 1), `C', `B', `A'[1...,2] - `A'[1...,1], `A'[1...,4] - `A'[1...,3] \ /* Growth
				*/    J(rowsof(`A'), 1, 2), `C', `B', `A'[1...,3] - `A'[1...,1], `A'[1...,4] - `A'[1...,2] \ /* Distribution
				*/    J(rowsof(`A'), 1, 3), `C', `B', `A'[1...,4] - `A'[1...,1], `A'[1...,4] - `A'[1...,1] ) /* Total effect */
				
				
				
			** Report poverty rates	
			
			mat `pov_rate' = (J(rowsof(`A'),1,0) ,`C', `B', `A'[1...,1]) \ (J(rowsof(`A'),1,1), `C', `B', `A'[1...,4]) \ (J(rowsof(`A'),1,2), `C', `B', `A'[1...,4]-`A'[1...,1])
			mat colnames `pov_rate' = Period Indicator Line rate
			cap	drop _all
			cap svmat double `pov_rate' , n(col)
			
			label define Period 0 "Rate in `by' `c'" 1 "Rate in `by' `d'"  2 "Total change in p.p."
			label values Period Period
			
			label var Period "Poverty rates"
			
			if "`mpl'"!="" {
				local pl "Line"
				label var `pl' "By multiples of `varpl'"
				cap tab `pl'
				forvalues i =1(1)`r(r)' {
					local j : word `i' of `mpl'
					label define `pl' `i' "`j'", add	
				}
				label values `pl' `pl'			
			}
			
			label define Indicator 0 "FGT0" 1 "FGT1" 2 "FGT2"
			label values Indicator Indicator
			
			display as text _newline "{hline 45}"
			display as text "Poverty rates"
			display as text "{hline 45}"	
			tabdisp Period Indicator, cell(rate) format(%12.2fc) by(`pl')
			
			mat `pov_rate' = (J(rowsof(`A'),1,0), `C', `A'[1...,1],`B') \ (J(rowsof(`A'),1,1), `C', `A'[1...,4],`B')
			mat colnames `pov_rate' = Period Indicator Rate Line
			return matrix poverty = `pov_rate'
			
			
			** Decomposition results
			mat colnames `PATH' = Effect Indicator Line effect1 effect2
			cap	drop _all
			cap svmat double `PATH', n(col)	
					
			
			label define Effect   1 "Growth" 2 "Distribution" 3 "Total change in p.p."
			label values Effect Effect
			
			if "`mpl'"!="" {
				label var `pl' "Multiples of poverty line"
				label values `pl' `pl'			
			}
			
				
			label values Indicator Indicator
			
			qui	egen effect_avg=rowmean(effect1 effect2)
						
			di
			display as text _newline "{hline 50}"
			display as text in yellow "Growth and Distribution - Poverty Decomposition"
			display as text "{hline 50}"
			di as txt "Welfare variable    : `varlist'"
			di as txt "Comparison variable : `by'"
			di as txt "Number of obs       :"as res %8.0f `ct'	
			
			tabdisp Effect Indicator, cell(effect_avg) format(%12.2fc) by(`pl')
			
			sort `pl' Indicator Effect, stable
			mkmat `pl' Indicator Effect effect1 effect2 effect_avg, matrix(`a')
			mkmat `pl' Indicator Effect effect_avg, matrix(`b')
			
			return matrix shapley = `a'
			return matrix b = `b'
			
			clear
			
end






* ** Another program need to calculate poverty
cap program drop _mpl
program define _mpl, rclass sortpreserve byable(recall)
	version 10.0, missing
	if c(more)=="on" set more off
	local version : di "version " string(_caller()) ", missing:"
	syntax varlist(numeric min=1 max=1) [if] [in] [aweight fweight], [varpl(varname numeric) LINEs(numlist sort) mpl(numlist sort) INdicator(string) max]	
	
	tempname fgt
	tempvar  w wwvar point0 point1 aux
	marksample touse
	
	qui {	
		
		* * Indicator
		if regexm("`indicator'","fgt0")!=0 local fgt0 "fgt0"
		if regexm("`indicator'","fgt1")!=0 local fgt1 "fgt1"
		if regexm("`indicator'","fgt2")!=0 local fgt2 "fgt2"
		
		* * Weight variable
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
		
		
		* * Points
		sum `varlist' if `touse' , meanonly
		local max1 `r(max)'
		local min `r(min)'
		if `min' > 0 local min 0
		
		if ("`max'"=="") local max1 ""	
		
		* * varpl
		if ("`varpl'"=="") {
			tempvar varpl
			gen byte `varpl' = 1 if `touse'
			local mpl "`lines'"
		}	
		if ("`mpl'"=="") local mpl "1"
	
		gen double `point0' = .
		gen double `point1' = .
		gen double `aux' = .
		local list "`min' `mpl'"
		
		local signal "<"
				
		local cont 0
		foreach pt1 in `mpl' `max1' {
			
			local ++cont
			local pt0 : word `cont' of `list'
				
			replace `point0' = `pt0'*`varpl'
			replace `point1' = `pt1'*`varpl'
			
			if 	"`pt0'"=="`min'" {
				replace `point0' = `min'
			}
			
			if 	"`pt1'"=="`max1'" {
				replace `point1' = `max1'
				local signal "<="
			}	

			
			* Observation on range
			if (`point0'>`point1') {
				di in red "The range used not valid" _new
				exit 198
			}				
		
		
			/* Indicators Calculation */
					
					
			* ** fgt0					
				
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


*** Save results			
return matrix b = `fgt'
	
end	
