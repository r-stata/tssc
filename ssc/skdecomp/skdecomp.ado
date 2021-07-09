*! version 1.0   15Apr2012
*! Bernardo Atuesta, Viviane Sanfelice, Andres Castanedas, Joao Pedro Azevedo


cap program drop skdecomp
program define skdecomp, rclass sortpreserve byable(recall)
	version 10.0, missing
	if c(more)=="on" set more off
	local version : di "version " string(_caller()) ", missing:"
	syntax varlist(numeric min=1 max=1) [if] [in] [aweight fweight], by(varname numeric)    ///
			varpl(varname numeric)                                              ///
			[mpl(numlist sort) INdicator(string) idpl(varname)]	
	
	tempname a b temp PATH A B C D pov_rate		
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
	
	qui markout `touse' `varlist' `wvar' `by' `varpl' `idpl', strok
	qui keep if `touse'
	
	
	* ** Comparison variable
	cap tab `by', matrow(`temp')
	local ct = r(N)
	if r(N)==0 error 2000	
	if (`r(r)'~=2)|(_rc==134) {
		di in red "Only 2 groups allow"
		exit 198
	}		
	local c = `temp'[1,1]
	local d = `temp'[2,1]
	
	
	* ** Poverty Line Check
	sum `varpl' if `by'==`c', meanonly
	local testc1 = round(`r(max)', .01)
	local testc2 = round(`r(min)', .01)
	sum `varpl' if `by'==`d', meanonly
	local testd1 = round(`r(max)', .01)
	local testd2 = round(`r(min)', .01)
	if (( `testc1' != `testc2') | ( `testd1' != `testd2')) & ( "`idpl'"=="") {
		di in red "Poverty line is not constant in each `by'. Use the option IDPL"
		exit 198
	}
	
	
	local ing1 "`varlist'"
	local ing2 "`varname2'"	
	
	* Generate the varibles that has the same distribution, but have the average from another year
	qui gen double `ing2' = .
		
	qui sum `ing1' `weight' if `by'==`c' , meanonly
	local m1 `r(mean)'

	qui sum `ing1' `weight' if `by'==`d' , meanonly
	local m2 `r(mean)'
		
	qui replace `ing2'=`ing1'*(`m2'/`m1') if `by'==`c'
	qui replace `ing2'=`ing1'*(`m1'/`m2') if `by'==`d'
	
	* Poverty line by period
	if "`idpl'"!="" {	
		tempvar varpl1
		qui transpose_pline, plvar(`varpl') by(`by') strata(`idpl') generate(`varpl1')
		
		* Poverty Line in t=0
		qui gen double lp1 =`varpl' if `by'==`c'
		qui gen double lp2 =`varpl1' if `by'==`c'
			
		* Poverty Line in t=1
		qui replace lp1 =`varpl1' if `by'==`d'
		qui replace lp2 =`varpl' if `by'==`d'
	}
	else {
		* Poverty Line in t=0
		qui sum `varpl' if `by'==`c', meanonly
		local lp1 `r(mean)'
		gen double lp1=`lp1'
			
		* Poverty Line in t=1
		qui sum `varpl' if `by'==`d', meanonly
		local lp2 `r(mean)'
		gen double lp2=`lp2'
	}
	
	***=== Shorrocks-Kolenikov Decomposition ===***
		
	foreach year in `c' `d' {
		foreach income in `ing1' `ing2' {
			foreach povline in lp1 lp2 {
				_mpl `income' `weight' if (`by'==`year') , varpl(`povline') mpl(`mpl') in(`fgt0' `fgt1' `fgt2')
				mat `a' = r(b)
				mat `income'_`year'_`povline' = `a'[1...,3]		
			}
		}
	}
		
	* ** Saving results
			
	* poverty line
	mat `C' = `a'[1...,1]
	* indicator
	mat `D' = `a'[1...,2]

	mat `A' = (`ing1'_`c'_lp1, `ing1'_`c'_lp2, `ing2'_`c'_lp1, `ing2'_`c'_lp2)	
	mat `B' = (`ing1'_`d'_lp2, `ing1'_`d'_lp1, `ing2'_`d'_lp2, `ing2'_`d'_lp1)	
			
			
	** Matrix of the three effects: Growth, Distribution and Poverty Line respectively
	mat `PATH' = /*
	Growth effect
	*/(J(rowsof(`A'),1,1), `D', `C', `B'[1...,2]-`B'[1...,4], `A'[1...,3]-`A'[1...,1], `A'[1...,3]-`A'[1...,1], `A'[1...,4]-`A'[1...,2], `B'[1...,1]-`B'[1...,3], `B'[1...,1]-`B'[1...,3] \ /*
	Distribution effect
	*/ J(rowsof(`A'),1,2), `D', `C', `B'[1...,4]-`A'[1...,1], `B'[1...,2]-`A'[1...,3], `B'[1...,1]-`A'[1...,4], `B'[1...,1]-`A'[1...,4], `B'[1...,3]-`A'[1...,2], `B'[1...,4]-`A'[1...,1] \ /*
	Prices effect
	*/ J(rowsof(`A'),1,3), `D', `C', `B'[1...,1]-`B'[1...,2], `B'[1...,1]-`B'[1...,2], `A'[1...,4]-`A'[1...,3], `A'[1...,2]-`A'[1...,1], `A'[1...,2]-`A'[1...,1], `B'[1...,3]-`B'[1...,4] \ /*
	Total change
	*/ J(rowsof(`A'),1,4), `D', `C', `B'[1...,1]-`A'[1...,1], `B'[1...,1]-`A'[1...,1], `B'[1...,1]-`A'[1...,1], `B'[1...,1]-`A'[1...,1], `B'[1...,1]-`A'[1...,1], `B'[1...,1]-`A'[1...,1])
		

		
		
		
	** Poverty rates by period	
	mat `pov_rate' = (J(rowsof(`A'),1,0) ,`C', `D', `A'[1...,1]) \ (J(rowsof(`A'),1,1), `C', `D', `B'[1...,1]) \ (J(rowsof(`A'),1,2), `C', `D', `B'[1...,1]-`A'[1...,1])
	mat colnames `pov_rate' = Period Line Indicator rate
	cap	drop _all
	cap svmat double `pov_rate' , n(col)
	
	label define Period 0 "Rate in `by' `c'" 1 "Rate in `by' `d'"  2 "Total change in p.p."
	label values Period Period
	
	label var Period "Poverty rates"
	
	if "`mpl'"!="" {
		local pl "Line"		
		label var `pl' "By multiples of `varpl'"
		cap tab `pl'
		local m = `r(r)'
		forvalues i =1(1)`m' {
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
	
	mat `pov_rate' = (J(rowsof(`A'),1,`c'),`D',`A'[1...,1],`C') \ (J(rowsof(`A'),1,`d'),`D',`B'[1...,1],`C')
	mat colnames `pov_rate' = Period Indicator Rate Line
	return matrix poverty = `pov_rate'
	
	
	
	** Results decomposition
	mat colnames `PATH' = Effect Indicator Line effect1 effect2 effect3 effect4 effect5 effect6
	cap	drop _all
	cap svmat double `PATH', n(col)

	label values Indicator Indicator
			
	label define Effect  1 "Growth" 2 "Redistribution" 3 "Line"  4 "Total change in p.p."
	label values Effect Effect
			
	egen effect_avg=rowmean(effect1 effect2 effect3 effect4 effect5 effect6)
						
	if "`mpl'"!="" {
		label var `pl' "By multiples of `varpl'"
		label values `pl' `pl'			
	}
	
	di
	display as text _newline "{hline 55}"
	display as text in yellow "Growth, Distribution and Line - Poverty Decomposition"
	display as text "{hline 55}"
	di as txt "Welfare variable    : `varlist'"
	di as txt "Comparison variable : `by'"
	di as txt "Number of obs       :"as res %8.0f `ct'	

	
	tabdisp Effect Indicator, cell(effect_avg) format(%12.2fc) by(`pl')
	
	sort `pl' Indicator Effect, stable
	mkmat `pl' Indicator Effect effect1 effect2 effect3 effect4 effect5 effect6 effect_avg, matrix(`a')
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
	
	return matrix b = `fgt'
		
	end	


* ** Another program need to switch poverty lines between periods
cap program drop transpose_pline
program define transpose_pline, nclass
	syntax, plvar(varname numeric) by(varname numeric) [strata(string)] generate(string)	
	
	tempfile temp1 temp2
	tempvar univ
	
	su `by', meanonly
	local obs `r(N)'
	local univ1 `r(min)'
	local univ2 `r(max)'
		
	sort `by' `strata' , stable
	save `temp1'.dta, replace
	
	
	* organizing data to switch between two periods
	gen `univ' = `univ2' if `by'==`univ1'
	replace `univ' = `univ1' if `by'==`univ2'
	keep `univ' `strata' `plvar'
	duplicates drop `univ' `strata' `plvar', force
	rename `plvar' `generate'
	sort `univ' `strata' , stable
	save `temp2'.dta, replace
					
	use `temp1'.dta, replace			
	gen `univ'  = `by' 	 		
	sort `univ' `strata' , stable
	merge `univ' `strata' using `temp2'.dta, nokeep
	cap sum _merge if _merge==1, meanonly
	if `r(N)'!=0  di in red "Warning: `r(N)' observations were not matched. Please, revise the identificator for poverty line, `strata'"
	cap sum _merge if _merge==3, meanonly
	if `r(N)'!=`obs'  di in red "Warning: `strata' is not unique identificator for poverty line"
	drop _merge `univ'
	
end
