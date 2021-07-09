*! version 1.1 08May2019

prog define swpermute, rclass
version 13.0

/*
DESCRIPTION

This program calculates the specified difference between two treatements and calculates a p value for this difference using permutations tests.

The program allows the user to analyse their data either as a vertical only analysis (analysing each period seperately then combining them in a weighted average) or as any other analysis model carried out on the entire dataset.

The vertical analysis can be a cluster summary analysis (as in Thompson and Davey et al 2017). If this is the case the user should calculate the cluster summaries in the required	format (risk, odds, log odds, rate etc) before running the command.

For continuous outcome and cluster summaries the user can also request for 	null values other than the default 0 to be tested. This is not possible for other data types as it involves contracting the data set, converting the outcome to	the require format, and expanding the dataset. This is risky to do in a generic program and we feel that it would be safer for the user to run these steps themselves.

Data should be in long format with a row for each cluster at each period. 	There must be a row for each period but the outcome may be missing for some 	rows. The program requires variables specifying the cluster, the group the cluster is randomised to, the period, the intervention status (control or interventon). These must be numeric variables. The intervention variable must be in the 0/1 format.

Using matrices for the estimation so is limited to 400 periods

UPDATES:
- default number of repetitions increased from 500 to 1000
*/


*Preserve original data
preserve

********************************************************************************

*split into before and after the colon
capture _on_colon_parse `0'
local cmd=`"`s(after)'"'
local prefix=`"`s(before)'"'

*Check the syntax is specified correctly:
*syntax check on "bla :"
if "`cmd'" == "" {
	di as error "Command not specified"
	exit 20
}
*syntax check on ": bla"
if "`prefix'" == "" {
	di as error "required variables and test statistic not found"
	exit 20
}  

*Set data to be the requested subset of data
local 0 "`cmd'"
syntax anything [if] [in], [*]

if "`if'`in'" != "" {
	quietly keep `if' `in'
}


tempvar touse
mark `touse'

* syntax check for parts before ":"
local 0 "`prefix'"
#delimit ;
syntax anything , CLuster(varname)
					PERiod(varname)
					INTervention(varname)
					[nodots] 
					[Reps(integer 1000)] 
					[seed(string)]
					[STRata(varlist)]
					[WIthinperiod]
					[WEightperiod(string)]
					[SAving(string)]
					[null(numlist)]
					[OUTcome(varname)]
					[RIGht]
					[LEFt]
					[LEVel(cilevel)];
#delimit cr


display _n


********************************************************************************
* Check that the command is specified correectly
********************************************************************************

* Check that the command is a known command
local cmd_1 = word("`cmd'", 1)

capture which `cmd_1'
if _rc != 0 {
	noi di as error "`cmd_1' not recognised"
	exit 198
}



********************************************************************************
*Check prefix parts correctly specified	
********************************************************************************


* Check something is given							
if "`anything'" == "" {
	display as error "No statistic given before ':'"
	exit 20
}
local statistic = "`anything'"


* Check design variables are numeric
confirm numeric variable `cluster' `period' `intervention'

*check period all missing
qui inspect `period'
if r(N_unique) == 0 {
	display as error "Period is missing for all observations"
	exit 198
}
*Drop rows with missing period, or clusters. Currently allowing missing values of 
* intervention- these could be wash-out periods?
qui keep if `period' < .

qui inspect `cluster'
if r(N_unique) == 0 {
	display as error "Cluster is missing for all observations"
	exit 198
}

qui keep if `cluster' < .

*encode the period variable in case it is a decimal
tempvar periodtemp periodtemp2 periodtemp3 periodcode
qui tostring `period', gen(`periodtemp') force
qui bysort `period': gen `periodtemp2' = 1 if _n==1
qui gen `periodcode' = sum(`periodtemp2')
local periodmax = `periodcode'[_N]	
qui gen long `periodtemp3' = _n 
forval i = 1 / `periodmax' { 
		su `periodtemp3' if `periodcode' == `i', meanonly 
		local label = `periodtemp'[`r(min)'] 
		local value = `periodcode'[`r(min)'] 
		label def periodcode `value' `"`label'"', modify         
} 

label val `periodcode' periodcode


*check intervention is 0 1
qui levelsof `intervention', local(levels)
if "`levels'" != "0 1" {
	display as error "intervention() is not a 0/1 variable"
	exit 450
}

*check that intervention is constant within a cluster-period
tempvar nonmiss t1 t2 t3 
qui gen `nonmiss' = 1 if `intervention'<.

qui bysort `cluster' `periodcode' `nonmiss': gen `t1' = _N
qui bysort `cluster' `periodcode' `intervention': gen `t2' = _N

qui count if `t1' != `t2' & `intervention' < .
if r(N)>0 {
	display as error "intervention() is not constant within cluster-periods"
	exit 198
}

*remove rows with missing intervention unless all missing in cluster-period
*We keep the observations if all missing as could be a washout period
qui bysort `cluster' `periodcode' : gen `t3' = _N
qui drop if `intervention' == . & `t3' != `t2'


*Give a warning about time periods that won't be included if its a within period analysis
* and all in control or intervention
qui levelsof `periodcode', local(periodlevels)
local periodlevels_orig "`periodlevels'"
local matdesign_colnames ""
local periodrows ""
foreach i of local periodlevels_orig {
	qui count if `intervention' == 0	& `periodcode' == `i'
	local intervention0 = r(N)
	qui count if `intervention' == 1	& `periodcode' == `i'

	local templevel: label (`periodcode') `i'

	local matdesign_colnames "`matdesign_colnames' `templevel'"

	if (`intervention0' == 0 | r(N) == 0) & `"`withinperiod'"' == "withinperiod" {		
		noi display as text _n "Warning: `period' = `templevel' not included in analysis. Clusters all in one condition" 
		
		local periodlevels = strtrim(stritrim(subinstr("`periodlevels'", "`i'","", 1)))
	}
	else {
		local periodrows "`periodrows' `period':`templevel'"
	}
}

* Check strata
qui inspect `cluster'
local n_clusters = r(N_unique)
tempvar strata_var

if `"`strata'"' != "" {
	*Check cluster, period, and intervention are not in strata
	if wordcount(`"`strata'"') > 9 {
		noi di as error "Too many strata variable listed. A maximum of 9 variables can be given"
		exit 198
	}
	if inlist(`"`cluster'"', subinstr(`"`strata'"', " ", ", ", .)) == 1 {
		noi di as error "clustervar may not be specified in strata"
		exit 198
	}	
	if inlist(`"`intervention'"', subinstr(`"`strata'"', " ", ", ", .)) == 1 {
		noi di as error "interventionvar may not be specified in strata"
		exit 198
	}	
	if inlist(`"`period'"', subinstr(`"`strata'"', " ", ", ", .)) == 1 {
		noi di as error "periodvar may not be specified in strata"
		exit 198
	}	
			
	egen `strata_var' = group(`strata')
	qui inspect `strata_var'
	local n_strata = r(N_unique)
	
	local di_strata "Number of strata = `n_strata'"
	
	* Check that there are at least 2 clusters for every level of strata
	if r(N_unique) > `n_clusters'/2 {
		noi di as error "Too many levels of strata specified"
		exit 198
	}
	
	* Check strata is constant within cluster
	tempvar levels_var1 levels_var2
	sort `cluster' `strata_var'
	by `cluster' `strata_var': gen `levels_var1' = 1 if _n == 1
	by `cluster': gen `levels_var2' = sum(`levels_var1')
	
	qui summ `levels_var2'
	if r(max)>1 {
		noi di as error "Strata not constant within cluster"	
		exit 198
	}
}
else {
	gen `strata_var' = 1
	local di_strata ""
}


* Only specify period weight with withinperiod analysis
if "`weightperiod'" != "" & "`withinperiod'" == "" {
	display as text "Warning: option weightperiod() only relevent for within period analysis"
}
if "`weightperiod'" == "" {
	local weightperiod = "N"
}
* Check that the period weight is valid
if inlist(word("`weightperiod'",1), "var", "variance","N", "none") == 0 {
	display as error "Invalid weightperiod()"
	exit 198
}

* Check a statistic is given for a variance weightperiod
if inlist(word("`weightperiod'",1),"N", "none") == 1 {
	local variance "NOTUSED"
}
else if inlist(word("`weightperiod'",1), "var", "variance") == 1 & wordcount("`weightperiod'") == 1 {
	display as error "No variance statistic given for variance period weight"
	exit 198
}
else{
	if word("`weightperiod'",1) == "var" local variance = trim(subinstr("`weightperiod'","var","",1))
	if word("`weightperiod'",1) == "variance" local variance = trim(subinstr("`weightperiod'","variance","",1))
	
	local weightperiod "variance"
}


*check reps is a valid number of repetitions
if `reps' < 1 {
	display as error "reps() must be a positive integer"
	exit 198
}

*Check that only one of left or right is requested
if `"`left'"' == `"left"' & `"`right'"' == `"right"' {
	display as error "left and right cannot both be selected"
	exit 198
}

*Sort out where results are saved to, either a tempfile or the requested location
if "`saving'" ==""{
	tempfile saving
}
else {
	_prefix_saving `saving'
	
	local saving    `"`s(filename)'"'
	local replace   `"`s(replace)'"'
	local every  `"`s(every)'"'
	if "`double'" == "" {
		local double	`"`s(double)'"'
	}

}

tempname permuteresults
cap postclose `permuteresults'
postfile `permuteresults' null observed estimate using `saving', `double' `replace' `every'

if "`dots'" == "" local dots "dots" 


********************************************************************************
* Check data where testing different null values	
********************************************************************************


* error if null values given for command that isn't supported


* give null a default if it is blank
if "`null'" == "" {
	local null = 0
}
else if "`null'" != "0"{
	
	*Outcome must be specified if null is anything other than 0
	capture confirm variable `outcome' 
	if _rc !=0 {
		noi di as error "outcome() required with null values other than 0"
		exit 198
	}
	else {
		capture confirm numeric variable `outcome'
		if _rc != 0 {
			noi di as error "outcome not a numeric variable"
			exit 198
		}
	}		
}


********************************************************************************
* save data and create a design dataset
********************************************************************************


tempfile original
qui save `original', replace

sort `cluster' `periodcode' 

*save a file of the design being used
qui contract `cluster' `periodcode' `intervention' `strata_var'
drop _freq

*Create a design matrix in wide format
qui reshape wide `intervention', i(`cluster') j(`periodcode')

tempfile design
qui save `design', replace


*Check that there are at least 2 sequences
qui ds `intervention'*
local levels = r(varlist)

tempvar group
egen `group' = concat(`levels')
qui destring `group', replace
qui inspect `group'
if r(N_unique)<=1 {
	noi di as error "There are fewer than 2 randomised sequences"
	exit 198
}
drop `group'

*Make a matrix of the design
tempname matdesign

contract `levels' 

order * , sequential

mkmat `levels', matrix(`matdesign') rownames(_freq)
matrix colnames `matdesign' = "`matdesign_colnames'"





********************************************************************************
* Analysis
********************************************************************************


qui use `original', clear

if "`seed'" != "" {
	set seed `seed'
} 
else local seed = c(rngstate)


********************************************************************************
* Calculate observed effect


estimate  , cmd(`cmd') intervention(`intervention') cluster(`cluster') period(`periodcode') /*
		*/ statistic(`statistic') weightperiod(`weightperiod') variance(`variance') /*
		*/ `withinperiod' periodlevels(`periodlevels')
tempname overall

scalar `overall' = r(effect)

if "`withinperiod'" == "withinperiod" {
	tempname matwithin
	matrix `matwithin' = r(results)
	matrix rownames `matwithin' = `periodrows'
	matrix colnames `matwithin' = Estimate Weight
}


********************************************************************************
* Calculate p values for each specified null


*Don't run this if the overall estimate is missing
tempname nullobserved permuteb
foreach inull of local null {

	*calcualte the observed estimated effect
	qui use `original', clear
	
	if "`seed'" != "" {
	set seed `seed'
}

if `inull' != 0 {
		*if inlist("`outcometype'", "cluster-summary", "continuous") == 1 {
		qui replace `outcome' = `outcome' - `inull' if `intervention' == 1
	}
	
	tempfile nullchanged
	qui save `nullchanged', replace
	
	*estimate observed effect for this null value
	if `inull' != 0 {
		estimate  , cmd(`cmd') intervention(`intervention') cluster(`cluster') period(`periodcode') /*
			*/ statistic(`statistic') weightperiod(`weightperiod') variance(`variance') /*
			*/ `withinperiod' periodlevels(`periodlevels')
		scalar `nullobserved' = r(effect)
	}
	else scalar `nullobserved' = `overall'
	
	*Run permutations to calculate p value
	
	if "`dots'" == "dots" display as text _n "Null: `inull' Permutation replications (`reps')" 
	
	*There is a chance that the models wont run for some permutations
	if `nullobserved' < . {
		forvalue i = 1/`reps'{
			capture montecarlo , designdata(`design') originaldata(`nullchanged') /*
				*/cmd(`cmd') intervention(`intervention') cluster(`cluster') period(`periodcode') statistic(`statistic') /*
				*/ weightperiod(`weightperiod') variance(`variance') `withinperiod' /*
				*/ periodlevels(`periodlevels') strata(`strata_var')
			
			if _rc == 1 exit 1
			else if _rc == 0 {
				scalar `permuteb' = r(effect)
			}
			else  {
				scalar `permuteb' = .
			}
			post `permuteresults' (`inull') (`nullobserved') (`permuteb')
					
			if "`dots'" == "dots" {
				if `permuteb' < . local print `"as text `"."'"'
				else local print `"in red `"x"'"'
			
				if mod(`i', 50) == 0   display as text `print'" " _dup(`= strlen("`reps'") - strlen("`i'")') " " "`i'" 
				else                   display as text `print' _c
			}

		}
	}
	else post `permuteresults' (`inull') (.) (.)
}
postclose `permuteresults'

*calculate p value from permutation distribution
use `saving', clear

qui count if observed == .
local nullobserved_missing = r(N)

qui count if estimate == . & observed < .
local permute_missing = r(N)

gen extreme = 0 if observed < . & estimate < .
if `"`right'"' == `""' & `"`left'"' == `""' {
	qui replace extreme = 1 if abs(estimate) >= abs(observed) & observed < . & estimate < .
}
else if `"right"' == `"right"' & `"`left'"' == `""' {
	qui replace extreme = 1 if estimate >= observed & observed < . & estimate < .
}
else if `"left"' == `"left"' & `"`right'"' == `""'  {
	qui replace extreme = 1 if estimate <= observed & observed < . & estimate < .
}
else {
	display as error "left or right not correctly specified"
	exit 198
}

gen order = _n

collapse (count) n = estimate (sum) c = extreme (min) order, by(null)
*note collapse count and sum ignores missing values

sort order

gen nullrows = string(null)
qui gen p  = .
qui gen lb = .
qui gen ub = .



tempname nullmat
mkmat null c n p lb ub, matrix(`nullmat') rownames(nullrows)

local rows = rowsof(`nullmat')
forvalues i = 1/`rows' {
	*cii doesn't work with matrix cells so 
	local c = `nullmat'[`i',2]
	local n = `nullmat'[`i',3]
	
	qui cii `n' `c', level(`level')
	
	matrix  `nullmat'[`i',4] = r(mean)
	matrix  `nullmat'[`i',5] = r(lb)
	matrix  `nullmat'[`i',6] = r(ub)
}






******************************************
* Print results
******************************************


display as text _n "Monte Carlo permutation results" _n

display as text _col(6) "command:  " trim("`cmd'")
display _col(4) "statistic:  `statistic'"
display as text _col(7) "design:"
matlist `matdesign', rowtitle("freq") noblank nohalf tindent(10) twidth(6) left(14) format(%4.0f)
display _n

if "`withinperiod'" == "withinperiod" {
	display "Within period Estimates and Weights:"
	matrix list `matwithin', format(%5.4f) noheader nohalf
	display _n
}

if `nullobserved_missing' > 0 display _n "Warning: command returned a missing statistic " /*
*/ "for `nullobserved_missing' null values so no permutations were performed for these null values" _n
if `permute_missing' > 0 display _n "Warning: command returned a missing statistic " /*
	*/ "for `permute_missing' permutations across all null values. These have been discarded and not " /*
	*/ "repeated" _n

tempname Tab

.`Tab' = ._tab.new, col(8) lmargin(0) 

// column           1      2     3     4     5     6     7	   8
.`Tab'.width       13    |12     8     8     8     8    10     10
.`Tab'.titlefmt %-12s      .     .     .     .     .    %20s	.
.`Tab'.pad          .      2     0     0     0     0     0      1
.`Tab'.numfmt       .  %9.0g     .     .     . %7.4f     .     .

.`Tab'.sep, top
.`Tab'.titles  "statistic" "obs_value" "null" "c" "n" "p"  "[`level'% Conf. Interval]" ""
.`Tab'.sep, middle

if length("`statistic'")>13 local ab_statistic = substr("`statistic'",1,11)+".."
else local ab_statistic "`statistic'"

.`Tab'.row `"`ab_statistic'"' /*
		*/ `overall' /*
		*/ el(`nullmat',1,1) /*
		*/ el(`nullmat',1,2) /*
		*/ el(`nullmat',1,3) /*
		*/ el(`nullmat',1,4) /*
		*/ el(`nullmat',1,5) /*
		*/ el(`nullmat',1,6)

local rows = rowsof(`nullmat')
forvalues i = 2/`rows' {
	.`Tab'.row "" /*
			*/ "" /*
			*/ `nullmat'[`i',1] /*
			*/ `nullmat'[`i',2] /*
			*/ `nullmat'[`i',3] /*
			*/ `nullmat'[`i',4] /*
			*/ `nullmat'[`i',5] /*
			*/ `nullmat'[`i',6]
}
	 

.`Tab'.sep, bottom

display "Note: confidence interval is with respect to p"
if `"`right'"' == `""' & `"`left'"' == `""' {
	display "p-value is two-sided"
}
else if `"right"' == `"right"' & `"`left'"' == `""' {
	display "p-value is the one-sided right tail"
}
else if `"left"' == `"left"' & `"`right'"' == `""' {
	display "p-value is the one-sided left tail"
}

				
				
				
				
********************************************************************************
* Return results and end program
********************************************************************************


return scalar N_reps = `reps'
return scalar obs_value = `overall'
if "`strata'" != "" return scalar N_strata = `n_strata'
return scalar N_clusters = `n_clusters'

matrix `nullmat' = `nullmat'[1..., 1..6]
return matrix p = `nullmat'
if "`withinperiod'" == "withinperiod" return matrix obs_period = `matwithin'
return matrix design = `matdesign'

restore

end





********************************************************************************
* Programs
********************************************************************************


* program calculating the overall difference
prog define estimate, rclass
	syntax , cmd(string) intervention(varname) cluster(varname) period(varname)/*
		*/ statistic(string) weightperiod(string) variance(string) /*
		*/ [withinperiod periodlevels(numlist)] 
	
	tempname effect
	if `"`withinperiod'"' == "withinperiod" {
		tempname results wgt sum

		* get a macro of each period
		local first = 1

		* create weight of 1 if not weighting the estimates
		if "`weightperiod'" == "none" {
			scalar `wgt' = 1
		}

		* create effect for each period that has control and intervention clusters
		tempfile data
		qui save `data', replace

		foreach i in `periodlevels' {
		
			use `data', clear
			qui keep if `period' == `i'
			
			* Create a weight based on the number of clusters
			if "`weightperiod'" == "N" {
				tempname n0 n1
				qui inspect `cluster' if `intervention'==0
				scalar `n0' = r(N_unique)
				qui inspect `cluster' if `intervention'==1
				scalar `n1' = r(N_unique)
				scalar `wgt' = (1/`n0'+1/`n1')^-1
			}
			
			* Run the command
			local converged
			capture `cmd'
			
			if _rc == 0 local converged = e(converged)
			else if _rc == 1 exit 1
			else {
				noi di as error "An error occured when running the command:"
				cap noi `cmd'
				exit _rc
			}
			
			*check statistic exists
			capture confirm number `=`statistic''
			if _rc != 0 {
				noi di as error "`statistic' not found after running `cmd_1' in period `period'"
				exit 198
			}
			
			*replace with missing if the model didn't converge
			local statistic_copy = `=`statistic''
			if `converged' == 0 {
				local statistic_copy = .
			}
			
			* Create a weight based on the variance of the estimate
			if "`weightperiod'" == "variance" {
				capture confirm number `=`variance''
				if _rc != 0 {
					noi di as error "`variance' not found after running `cmd_1'"
					exit 198
				}
				
				scalar `wgt' = 1/ (`variance')
			}

			*Add the estimate and weight to the matrix
			if "`first'" == "1"  {
				matrix `results' = (`statistic_copy' , `wgt')
				local first = 99
			}
			else matrix `results' = (`results'\ `statistic_copy' , `wgt')
		}
		
		*standardised the weights to sum to 1
		matrix `sum' = J(1,rowsof(`results'),1) * `results'
		matrix `results' = `results' * matrix(1,0\0,1/`sum'[1,2])
				
		*calculate effect
		mata: period_statistic("`results'","`effect'")		
		
		* return period results
		return matrix results = `results'

	}
	else{
		qui `cmd'
		
		*check statistic exists
		capture confirm number `=`statistic''
		if _rc != 0 {
			noi di as error "`statistic' not found after running `cmd_1'"
			exit 198
		}

		scalar `effect' = `statistic'

	}

	return scalar effect = `effect'

end

mata:
void period_statistic(results, ename)
{
	x = st_matrix(results)[,1]
	y = st_matrix(results)[,2]
	
	if (hasmissing(x) == 0) z = mean(x,y)
	else z = .
	
	st_numscalar(ename,z)
}
end

/* end of programs to calculate effect */ 	
	
	
********************************************************************************


*program to do monte carlot permutations of the data and estimate effect on permuted data
prog define montecarlo, rclass
	syntax, designdata(string) originaldata(string) cmd(string) intervention(varname) /*
		*/ cluster(varname) period(varname) strata(varname) statistic(string) /*
		*/ weightperiod(string) variance(string) [withinperiod periodlevels(numlist)]

	tempvar order shuffled

	* Start with the original design dataset
	use `designdata', clear
	
	*Shuffle the clusters in a random order
	qui gen `order' = runiform()
	qui sort `strata' `order'
	
	qui by `strata': gen `shuffled' = `cluster'[_n-1]
	qui by `strata': replace `shuffled' = `cluster'[_N] if _n==1
	
	qui replace `cluster' = `shuffled' 
	
	* Put the data back in long format and merge the shuffled data with the rest of the data
	qui ds `intervention'*
	local nperiods = wordcount(r(varlist))
	
	qui expand `nperiods'
	qui gen `period' = .
	qui gen `intervention' = .
	sort `cluster'
	forvalues j = 1/`nperiods'{
		local select = word("`=r(varlist)'",`j')
		qui by `cluster': replace `period' = real(subinstr(`"`select'"',"`intervention'","",1)) if _n == `j'
		qui by `cluster': replace `intervention' = `select' if _n == `j'
	}
	drop `=r(varlist)'
	

	qui merge 1:m `strata' `cluster' `period' using `originaldata', nogen noreport

	
	* Calculate the effect for the shuffled data
	qui estimate , cmd(`cmd') intervention(`intervention') cluster(`cluster') period(`period') /*
		*/ statistic(`statistic') weightperiod(`weightperiod') variance(`variance') /*
		*/ `withinperiod' periodlevels(`periodlevels')
	tempname effect
	scalar `effect' = r(effect)

	return scalar effect = `effect'
	
end

/* End of program to perform permutations */




