***STNDZXAGE - STaNDardiZe scores byX AGE (version 1.0)
***by Sarah Anne Reynolds
***sar48@berkeley.edu
***March 2019
capture program drop stndzxage
program define stndzxage
version 11

syntax varlist(min=2) [if] [, BINWidth(integer 1) MINBinsize(integer 30) CONTinuous ///
	POLYnomial(integer 3) mean(real 0) sd(real 1) FLoor CEiling ///
	REFerence(varname) MEDian GRaph]

marksample touse
tokenize `varlist'
local testvar `1'
local agevar `2'
macro shift
macro shift
local rest `*'
tempvar int_agevar agegroup group_size Mean SD categories m s allbins one sdcalc
capture drop stx_`testvar' 

***If there is reference group, only keep observations in the reference group for standardizing
if "`reference'"~="" {
	capture assert (`reference'==0 |`reference'==1 | `reference'==.) if `touse'
	if _rc~=0 {
		di as error "reference group variable must have values of 0 & 1"
		exit 110
		}
	foreach cattype of local rest {
		if "`cattype'"=="`reference'" {
			di as error "do not include reference category in the list of grouping variables"
			exit 110
			}
			// end finding reference variable in the list
		}
		// end checking all elements in the list rest
	}
	
***Discrete - Using the bin method 	
if ("`continuous'"=="") {
	*check that given paremeters are ok!
	if (`binwidth' <= 0 | `minbinsize' <= 0) {
		di as error "invalid parameters (binwidth or minbinsize)"
		exit 110
		}
	*make agevar an integer for binning
	qui gen `int_agevar'=int(`agevar')
	
	preserve
	qui keep if `touse'
	*only use ages pertinent to the test for standardizing
	qui replace `int_agevar'=. if `testvar'==.
	if ("`reference'"!="") {
		qui keep if `reference'==1
		}
	*Divide the sample into the groups
	qui qui levelsof `int_agevar', local(ages)
	local num_ages: word count `ages'
	local first_age: word 1 of `ages'
	local last_age: word `num_ages' of `ages'
	local numgroups=int((`last_age'-`first_age'+1)/`binwidth')
	if `numgroups'<1 {
		local numgroups 1
		}
	local i `first_age'
	local k=`first_age'+`binwidth'
	qui gen `agegroup'=.
	forvalues j=1/`numgroups' {
		qui replace `agegroup'=`j' if `int_agevar'>=`i' & `int_agevar'<`k'
		local i=`i'+`binwidth'
		local k=`k'+`binwidth'
		}
		
	*determine if there is a singleton in the last set
	local remainder=`last_age'-`first_age' + 1 -(`numgroups'*`binwidth')
	if `remainder'==1 {
		qui replace `agegroup'=`numgroups' if `int_agevar'==`last_age'
		}	
	else if `remainder'>1 {
		qui replace `agegroup'=`numgroups'+1 if `int_agevar'>`numgroups'*`binwidth'+`first_age'
		}
	else if `remainder'==0 {
		*do nothing
		}
	else { // if remainder is <0 binwidth is wider than ages available
		*do nothing
		}
	
	*Make a variable to indicate groups
	qui egen `allbins'=group(`agegroup' `rest')
	foreach var of varlist `agegroup' `rest' {
		qui replace `allbins'=. if `var'==.
		}
	*List of the values of the group variable	
	qui levelsof `allbins', local(AllBins)
	
	**Find mean & s.d.
	*with floor or ceiling
	if ("`floor'"!="" | "`ceiling'"!="") {
		if ("`median'"!="") { 
			di as error "Do not use floor or ceiling options with median"
			exit 110
			}
		qui gen `Mean'=.
		qui gen `SD'=.
		qui sum `testvar'
		if "`floor'"!="" {
			local ll "ll(`r(min)')"
			}
		else {
			local ll ""
			}
		if "`ceiling'"!="" {
			local ul "ul(`r(max)')"
			}
		else {
			local ul ""
			}
		foreach x of local AllBins {
			qui sum `testvar' if `allbins'==`x'
			if r(N)>=`minbinsize' {
				qui tobit `testvar' if `allbins'==`x', `ul' `ll'
				local m = _b[_cons]
				local s = _b[sigma:_cons]
				qui replace `Mean'=`m' if `allbins'==`x'
				qui replace `SD'=`s' if `allbins'==`x'
				}
				// end if r(N)>=minbinsize
			}
			// end x levels of allbins
		}
		// end floor or ceiling
	*no floors or ceilings
	else {
		*generate the mean, if median not selected
		if ("`median'"=="") {
			qui bys `agegroup' `rest': egen `Mean'=mean(`testvar')
			}
		*if median was chosen, subsitute mean with median 
		*(note it's still called mean for coding simplicity)
		if ("`median'"!="") {
			qui bys `agegroup' `rest': egen `Mean'=median(`testvar')
			}
		*generate standard deviation
		qui bys `agegroup' `rest': egen `SD'=sd(`testvar')
		
		*remove means and medians if the group size is too small
		foreach x of local AllBins {
			qui sum `testvar' if `allbins'==`x'
			if r(N)<`minbinsize' {
				qui replace `Mean' =. if `allbins'==`x'
				qui replace `SD'   =. if `allbins'==`x'
				}
				// end checking size of bin
			}
			// end going through all bins x				
		}
		// end no floor/ceiling
	*keep a small data set of the ages with means & sd	
	keep `Mean' `SD' `int_agevar' `rest' `allbins'
	qui drop if `allbins'==. | `int_agevar'==.
	qui duplicates drop
	sort `int_agevar' `rest'	
	tempfile meansd
	qui save `meansd', replace
		
	*merge in the small data set to the original	
	*remember, we only did the standardization using the reference population - do not merge on this variable!
	restore
	sort `int_agevar' `rest'
	qui merge m:1 `int_agevar' `rest' using `meansd', nogenerate
	
	/*Suppose one age (integer) did not have observations for the reference
	group, only for the contrasting group.  However, the age bins were wide 
	enough to calculate a mean for the reference group that included that age.  
	Apply this mean.*/
	tempvar maxage minage meanref sdref restcats
	if ("`reference'"~="") {
		bys `allbins': egen `maxage'=max(`int_agevar')
		bys `allbins': egen `minage'=min(`int_agevar')
		local count: word count `rest'
		if `count'>0 {
			qui egen `restcats'=group(`rest')
			foreach x of local AllBins {
				qui sum `restcats' if `allbins'==`x'
				qui replace `allbins'=`x' if `int_agevar'>=`minage' & `int_agevar'<=`maxage' ///
					& `restcats'==`r(mean)' & `allbins'==.
				qui replace `allbins'=. if `int_agevar'==. | `testvar'==.
				}
				// end x
			}
			// end if count>0
		else {
			foreach x of local AllBins {
				qui replace `allbins'=`x' if `int_agevar'>=`minage' & `int_agevar'<=`maxage' ///
					& `allbins'==.
				}
				// end x
			}
			// end else
		qui bys `allbins': egen `meanref'=max(`Mean') 
		qui bys `allbins': egen `sdref'=max(`SD')
		qui replace `Mean'=`meanref' if `Mean'==.
		qui replace `SD'=`sdref' if `SD'==.
		}
		// end application of reference scores
	qui replace `Mean'=. if `int_agevar'==.
	qui replace `SD'=. if `int_agevar'==.
	}
	// end discrete bin method
	
*generate continuous normalized scores if continuous is selected as an option	
if ("`continuous'"!="") {	
	if 	("`binwidth'" != "1") {
		dis as error "binwidth may not be combined with continuous"
		exit 198
		}
	if 	("`median'" != "") {
		dis as error "median may not be combined with continuous"
		exit 198
		}
	local refcondition "& `touse'"
	if ("`reference'"!="") {
		local refcondition "& `reference'==1 & `touse'"
		}
	local polylist ""
	forvalues i=1/`polynomial' {
		qui gen agevar`i'=`agevar'^`i'
		local polylist "`polylist' agevar`i'"
		}
	qui gen `one'=1
	qui gen `Mean'=.
	qui gen `SD'=.
	
	**if floor or ceiling is selected
	if ("`floor'"!="" | "`ceiling'"!="") {
		qui sum `testvar'
		if "`floor'"!="" {
			local ll "ll(`r(min)')"
			}
		else {
			local ll ""
			}
		if "`ceiling'"!="" {
			local ul "ul(`r(max)')"
			}
		else {
			local ul ""
			}
		qui egen `allbins'=group(`one' `rest')
		foreach var of varlist `one' `rest' {
			qui replace `allbins'=. if `var'==.
			}
		qui levelsof `allbins', local(AllBins)
		foreach x of local AllBins {	
			qui sum `testvar' if `allbins'==`x'
			if r(N)>=`minbinsize' {
				qui tobit `testvar' `polylist' if `allbins'==`x' `refcondition', `ul' `ll' // "&" included in refcondition
				qui predict `m' 						if `allbins'==`x'
				qui replace `Mean'=`m' 					if `allbins'==`x'
				qui gen `sdcalc'=(`testvar'-`Mean')^2 	if `allbins'==`x'
				qui tobit `sdcalc' `polylist' if `allbins'==`x' `refcondition', `ul' `ll' // "&" included in refcondition
				qui predict `s' 						if `allbins'==`x'
				qui replace `SD'=sqrt(abs(`s')) 		if `allbins'==`x'
				qui drop `m' `s' `sdcalc'
				}
				// end if r(N) >= minbinsize
			}
			// end allbins
		}
		// end floor & ceiling
		
	**no floor, no ceiling assumtions
	else {
		qui egen `allbins'=group(`one' `rest')
		foreach var of varlist `one' `rest' {
			qui replace `allbins'=. if `var'==.
			}
		qui levelsof `allbins', local(AllBins)
		foreach x of local AllBins {
			qui sum `testvar' if `allbins'==`x'
			if r(N)>=`minbinsize' {
				qui reg `testvar' `polylist' if `allbins'==`x' `refcondition' // "&" included in refcondition												  
				qui predict `m' 						if `allbins'==`x'
				qui replace `Mean'=`m' 					if `allbins'==`x'
				qui gen `sdcalc'=(`testvar'-`Mean')^2 	if `allbins'==`x'
				qui reg `sdcalc' `polylist' if `allbins'==`x' `refcondition' // "&" included in refcondition
				qui predict `s' 						if `allbins'==`x'
				qui replace `SD'=sqrt(abs(`s')) 		if `allbins'==`x'
				qui drop `m' `s' `sdcalc'
				}
				// end if r(N)>=minbinsize
			}
			// end allbins
		}
		// end normal
	qui drop `polylist'
	}
	// end continuous
	
*Standardize score (if median was chosen, it was renamed mean earlier!)
qui gen stx_`testvar'=(`testvar'-`Mean')/`SD' if `touse'
	
*Change if alternate mean & sd are chosen (default are mean=0 & sd=1, so nothing changes) 
qui replace stx_`testvar'=stx_`testvar'*`sd'
qui replace stx_`testvar'=stx_`testvar'+`mean'
	
*label variable
local refgroupcite ""
if "`reference'"~="" {
	local refgroupcite "; ref grp `reference'=1"
	}
if "`continuous'"=="" {
	local notcont " binwidth `binwidth'"
	}	
qui label var stx_`testvar' "Stndz `testvar' by `agevar' `rest' ~N(`mean',`sd')`notcont'`refgroupcite'"

*Diagnostic graph
if ("`graph'" !="") {
	preserve
	keep if `touse'
	local graph_names ""
	local num 1
	qui sum `agevar' if `testvar'~=.
	qui drop if `agevar'>r(max) | `agevar'<r(min)
	if ("`reference'" !="") {
		qui keep if `reference'==1
		local subtitle "subtitle(`reference'==1)"
		}
	qui replace `Mean'=. if stx_`testvar'==.
	if ("`rest'"=="") {
		tempvar zmean agemean
		qui bys `agevar' `rest' `reference': egen `zmean'=mean(stx_`testvar')
		qui bys `agevar' `rest' `reference': egen `agemean'=mean(`Mean')
		qui twoway (scatter `testvar' `agevar', msize(tiny)) ///
			   (scatter `agemean' `agevar'), ///
				name(raw, replace) title(Raw Data) ///
				legend(on order(1 "individual scores" 2 "means"))
		qui twoway (scatter stx_`testvar' `agevar', msize(tiny)) ///
			   (scatter `zmean' `agevar'), ///
				name(stn, replace) title(Standardized Data) ///
				legend(on order(1 "individual scores" 2 "means"))			
		local graph_names raw stn
		}
		// end no other grouping variables (rest)
	if ("`rest'"!="") {	
		tempvar group
		qui egen `group'=group(`rest'), label
		qui levelsof `group', local(restgroups)
		local lblname: value label `group'
		local num: word count `restgroups'
		foreach i of local restgroups {
			local vlname: label `lblname' `i'
			tempvar zmean`i' agemean`i'
			qui bys `agevar' `reference': egen `zmean`i''=mean(stx_`testvar') if `group'==`i'
			qui bys `agevar' `reference': egen `agemean`i''=mean(`Mean') if `group'==`i'
			
			local raw_`i'a 	(scatter `testvar' `agevar', msize(tiny))
			local raw_`i'b 	(scatter `agemean`i'' `agevar') if `group'==`i', 
			local raw_`i'c	name(raw`i', replace) title(Raw Data - `vlname', size(small))
			local raw_`i'd	legend(on order(1 "individual scores" 2 "means"))
			qui graph twoway `raw_`i'a' `raw_`i'b' `raw_`i'c' `raw_`i'd'
			
			local stn_`i'a  (scatter stx_`testvar' `agevar', msize(tiny)) 
			local stn_`i'b  (scatter `zmean`i'' `agevar') if `group'==`i', 
			local stn_`i'c	name(stn`i', replace) title(Standardized Data - `vlname', size(small)) 
			local stn_`i'd	legend(on order(1 "individual scores" 2 "means"))
			qui graph twoway `stn_`i'a' `stn_`i'b' `stn_`i'c' `stn_`i'd'
			
			local graph_names `graph_names' raw`i' stn`i'
			}
			// end i levels of restgroups	
		}
		// end other grouping variables (rest)
	restore			
	qui grc1leg `graph_names', title("Raw & Standardized Scores by Age (integer)") ///
		`subtitle' cols(2) name(all, replace) xcommon ///
		caption ("Raw shows mean (or median) used to standardize." ///
			"Standardized shows mean of standardized scores.")
	graph display all, ysize(`num') xsize(2)
	graph close `graph_names'
	}
	// end graph
end program
