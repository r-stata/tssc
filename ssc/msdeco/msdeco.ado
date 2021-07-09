* msdeco: computes the Mookherjee & Shorrocks (1982) decomposition
* version 1.0.0 2017-07-01 Andrew Silva

capture program drop msdeco
program msdeco, rclass
quietly {
	version 8.0

	syntax varname(numeric) [aweight fweight/] [if] [in], groupvar(varname numeric) yearvar(varname numeric) ///
		startyear(integer) endyear(integer) [preserve]
	local incvar = "`varlist'"
	local year = "`yearvar'"
	local year1 = "`startyear'"
	local year2 = "`endyear'"

	marksample useflag
	set more off
	
	if "`preserve'" != "" {
		noisily di " "
		noisily di as txt "Preserving data state; dropping observations from unused years"
		preserve
		keep if `year' == `year1' | `year' == `year2'
	}

	tempname I0_t1 N_t1 I0_t2 N_t2
	tempvar I0_k_t1 v_k_t1 lambda_k_t1 loglambda_k_t1 theta_k_t1 logmu_k_t1 ///
			I0_k_t2 v_k_t2 lambda_k_t2 loglambda_k_t2 theta_k_t2 logmu_k_t2 ///
			I0_k_bar v_k_bar lambda_k_bar loglambda_k_bar theta_k_bar I0_k_dif v_k_dif logmu_k_dif loglambda_k_dif ///
			fi I0_t1_vector I0_t2_vector weightvar
	
	* Define weight variable
	if "`weight'" == "" {
		generate byte `weightvar' = 1
		local weightvar = "`weightvar'"
	}
	else {
		local weightvar = "`exp'" // weight var is stored in `exp' without the "=" (indicated by the "/" in the syntax expression)
	}
	
	* Check if group levels are the same in year1 and year2
	capture levelsof `groupvar' if `year' == `year1' & `useflag', local(groupLevY1)
	capture levelsof `groupvar' if `year' == `year2' & `useflag', local(groupLevY2)
	if "`groupLevY1'" != "`groupLevY1'" {
		noisily di as error "'`groupvar'' does not have same levels in `year1' and `year2'!"
		exit 459
	}
	
	* Check if group levels are positive integers
	foreach lev of local groupLevY1 {
		if int(`lev') != `lev' | (`lev' < 0) { 
			noisily di as error "'`groupvar'' contains non-integer or negative values!"
			exit 459
		}
	}
	
	* Check for negataive and zero income values
	count if `incvar' < 0 & `useflag' & (`year' == `year1' | `year' == `year2')
	if r(N) > 0 {
		noisily di " "
		noisily di as txt "Warning: `inc' has `r(N)' values < 0." _c
		noisily di as txt " Not used in calculations"
	}
	
	count if `incvar' == 0 & `useflag' & (`year' == `year1' | `year' == `year2')
	noi if r(N) > 0 {
		noisily di " "
		noisily di as txt "Warning: `inc' has `r(N)' values = 0." _c
		noisily di as txt " Not used in calculations"
	}
	
	replace `useflag' = 0 if `incvar' <= 0 // only use positive income values
	
	* Parameters for year 1
	count if `year' == `year1' & `useflag'
	scalar `N_t1' = `r(N)'

	ineqdeco `incvar' [w=`weightvar'] if `year' == `year1' & `useflag', bygroup(`groupvar')
	scalar `I0_t1' = `r(ge0)' // Save overall I0 for t1
	
	
	* These variables store the respective index value, each value to a new line
	*  This is in place of using scalars, which clutter the workspace
	*  To create scalars with tempname, need to allocate them in advance, so can't do it dynamically
	*  (We don't know how many group levels in advance, so must be dynamic to an extent)
	*  However, variables (vectors) can be tempvar
	*  (This follows the method employed in ineqdeco (Jenkins 1999))
	
	* must match k to i, k potentially could be text, i must be integer
	generate `I0_k_t1' = .
	generate `v_k_t1' = .
	generate `lambda_k_t1' = .
	generate `loglambda_k_t1' = .
	generate `theta_k_t1' = .
	generate `logmu_k_t1'  = .
	
	local i = 1
	foreach k of local groupLevY1 {
		replace `I0_k_t1' = r(ge0_`k') if _n == `i'
		replace `v_k_t1' = r(v_`k') if _n == `i'
		replace `lambda_k_t1' = r(lambda_`k') if _n == `i'
		replace `loglambda_k_t1' = log(r(lambda_`k')) if _n == `i'
		replace `theta_k_t1' = r(theta_`k') if _n == `i'
		replace `logmu_k_t1' = r(lgmean_`k') if _n == `i'
	
		local i = `i' + 1
	}

	* Parameters for year 2
	count if `year' == `year2' & `useflag'
	scalar `N_t2' = `r(N)'
	
	ineqdeco `incvar' [w=`weightvar'] if `year' == `year2' & `useflag', bygroup(`groupvar')
	scalar `I0_t2' = `r(ge0)' // Save overall I0 for t2

	generate `I0_k_t2' = .
	generate `v_k_t2' = .
	generate `lambda_k_t2' = .
	generate `loglambda_k_t2' = .
	generate `theta_k_t2' = .
	generate `logmu_k_t2'  = .
	
	local i = 1
	foreach k of local groupLevY1 {
		replace `I0_k_t2' = r(ge0_`k') if _n == `i'
		replace `v_k_t2' = r(v_`k') if _n == `i'
		replace `lambda_k_t2' = r(lambda_`k') if _n == `i'
		replace `loglambda_k_t2' = log(r(lambda_`k')) if _n == `i'
		replace `theta_k_t2' = r(theta_`k') if _n == `i'
		replace `logmu_k_t2' = r(lgmean_`k') if _n == `i'
	
		local ++i
	}
	
	* Time averages and difference operators
	generate `I0_k_bar' = .
	generate `v_k_bar' = .
	generate `lambda_k_bar' = .
	generate `loglambda_k_bar' = .
	generate `theta_k_bar' = .
	generate `I0_k_dif' = .
	generate `v_k_dif' = .
	generate `logmu_k_dif' = .
	generate `loglambda_k_dif' = . // for exact decomp only
	
	local i = 1
	foreach k of local groupLevY1 {
		
		* Time averages
		replace `I0_k_bar' = (`I0_k_t1'[`i'] + `I0_k_t2'[`i'])/2 if _n == `i'
		replace `v_k_bar' = (`v_k_t1'[`i'] + `v_k_t2'[`i'])/2 if _n == `i'
		replace `lambda_k_bar' = (`lambda_k_t1'[`i'] + `lambda_k_t2'[`i'])/2 if _n == `i'
		replace `loglambda_k_bar' = (`loglambda_k_t1'[`i'] + `loglambda_k_t2'[`i'])/2 if _n == `i'
		replace `theta_k_bar' = (`theta_k_t1'[`i'] + `theta_k_t2'[`i'])/2 if _n == `i'
		
		* Difference operators
		replace `I0_k_dif' = `I0_k_t2'[`i'] - `I0_k_t1'[`i'] if _n == `i'
		replace `v_k_dif' = `v_k_t2'[`i'] - `v_k_t1'[`i'] if _n == `i'
		replace `logmu_k_dif' = `logmu_k_t2'[`i'] - `logmu_k_t1'[`i'] if _n == `i'
		replace `loglambda_k_dif' = `loglambda_k_t2'[`i'] - `loglambda_k_t1'[`i'] if _n == `i' // for exact decomp only
		
		local ++i
	}

	* Component sums
	local A = 0
	local B = 0
	local C = 0
	local D = 0
	local Cex = 0 // for exact decomposition
	local Dex = 0 // for exact decomposition
	
	local i = 1
	foreach k of local groupLevY1 {

		local A = `A' + (`v_k_bar'[`i'] * `I0_k_dif'[`i'])
		local B = `B' + (`I0_k_bar'[`i'] * `v_k_dif'[`i'])
		local C = `C' + ((`lambda_k_bar'[`i'] - `loglambda_k_bar'[`i']) * `v_k_dif'[`i'])
		local D = `D' + ((`theta_k_bar'[`i'] - `v_k_bar'[`i']) * `logmu_k_dif'[`i'])
		local Cex = `Cex' + (`loglambda_k_bar'[`i'] * `v_k_dif'[`i'])
		local Dex = `Dex' + (`v_k_bar'[`i'] * `loglambda_k_dif'[`i'])
		
		local ++i
	}

	local Cex = -`Cex'
	local Dex = -`Dex'
	
	local I0_dif_approx = `A' + `B' + `C' + `D'
	local I0_dif_exact = `I0_t2' - `I0_t1'
	local I0_dif_exact_sum =  `A' + `B' + `Cex' + `Dex'
	
	return scalar I0_dif_approx = `I0_dif_approx'
	return scalar A = `A'
	return scalar B = `B'
	return scalar C = `C'
	return scalar D = `D'
	return scalar I0_dif_exact = `I0_dif_exact'
	return scalar I0_dif_exact_sum = `I0_dif_exact_sum'
	return scalar Aexact = `A'
	return scalar Bexact = `B'
	return scalar Cexact = `Cex'
	return scalar Dexact = `Dex'
	return scalar I0_t1 = `I0_t1'
	return scalar I0_t2 = `I0_t2'
	return scalar N_t1 = `N_t1'
	return scalar N_t2 = `N_t2'

	* Print output
	noisily di " "
	noisily di "Approximation decomposition components:"
	noisily di "A: `A' (effect due to changes in within subgroup inequality)"
	noisily di "B: `B' (effect due to changes in population shares of within component)"
	noisily di "C: `C' (effect due to changes in population shares of between component)"
	noisily di "D: `D' (effect due to relative changes in subgroup means)"
	noisily di "Sum of components: `I0_dif_approx'"
	noisily di " "
	noisily di "Exact decomposition components:"
	noisily di "A: `A' (effect due to changes in within subgroup inequality)"
	noisily di "B: `B' (effect due to changes in population shares of within component)"
	noisily di "C: `Cex'"
	noisily di "D: `Dex'"
	noisily di "Sum of components: `I0_dif_exact_sum'"
	noisily di " "
	noisily di "Exact difference in I(0) (or GE(0)): `I0_dif_exact'"

	if "`preserve'" != "" {
		noisily di " "
		noisily di as txt "Restoring original data state"
		restore
	}	
} // end quietly block
end
