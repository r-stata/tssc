* 1.3.1 LS 25 October 2002
* 1.3.0 NJC 25 October 2002
* 1.2.0 Lee Sieswerda 24 October 2002
* 1.1.0 NJC 22 October 2002 
*! version 1.0 Lee Sieswerda 14 July 2002

prog define mrdum, rclass
	version 7.0
	syntax varlist [if] [in], /* 
	*/ Stub(string) [RESponses(numlist int sort) LABels1(string) LABels2 ]

	* Observations to use 
	marksample touse, novarlist 
	quietly count if `touse'
	if r(N) == 0 { 
		di as err "no observations"
		exit 2000 
	}	
	else local total = r(N) 

	* How many variables and possible responses?
	local nvar : word count `varlist'

	if "`responses'" == "" { 
		numlist "1/`nvar'" 
		local responses "`r(numlist)'"
		di _n as text "(responses assumed coded from 1 to `nvar')"
	} 
	
	local nresp : word count `responses'
	* use of -tabdisp- depends on # responses <= _N 
	if `nresp' > _N { 
		di as txt "bailing out: more possible responses than rows" 
		exit 0 
	} 	

	* Initialise variables 
	tempvar values present percent  
	* ! `present' is held as a string to protect it from -tabdisp- format
	qui { 
		gen `values' = . 
		gen str1 `present' = "" 
		gen `percent' = . 
	} 

	label var `values' "responses" 
	label var `present' "code present"
	label var `percent' "percent" 
		
	if "`labels1'" != "" { 
		label val `values' `labels1' 
	} 	
	else if "`labels2'" ~= "" {
		foreach v of local varlist { 
			local vallbl : value label `v' 
			if "`vallbl'" != "" { 
				label val `values' `vallbl' 
			} 
		} 	
	}

	quietly {
		* Mark cases that are completely missing
		tempvar nmiss
		egen `nmiss' = rmiss(`varlist') if `touse'
		replace `nmiss' = `nmiss' == `nvar'
		count if `nmiss' == 1
		if r(N) { 
			gen byte `stub'_miss = `nmiss' 
			local misstxt "+ 1 for missing" 
			replace `touse' = 0 if `nmiss' == 1 
		} 	
		count if `touse' 
		local nonmiss = r(N)
		local i = 1 

		* Generate new dummy variables, one for each possible response
		foreach num of numlist `responses' {
			replace `values' = `num' in `i' 
			egen `stub'_r`num' = /* 
			*/ eqany(`varlist') if `touse', values(`num')
			replace `stub'_r`num' = . if ~`touse' 
			/* `stub'_miss == 1 */

			count if `stub'_r`num' == 1
			replace `present' = "`r(N)'" in `i'
			replace `percent' = 100 * `r(N)' / `nonmiss' in `i' 
			local i = `i' + 1 
		} /* end foreach */ 
	} /* end quietly */ 

	tabdisp `values' if `values' < . , c(`present' `percent') format(%3.2f)

	* Summary measures 
	local nonmissper = round(`nonmiss'/`total' * 100, 0.01) 
	local miss = `total' - `nonmiss'
	di 
	di as text `"Cases with at least one response `if': "' as result "`nonmiss' (`nonmissper' %)"
	di as text `"              Completely missing `if': "' as result `miss'
	di as text " "
	di as text `"                     Total cases `if': "' as result `total'
	di " "
	di as text "Variables created for `nresp' possible responses `misstxt'"
	
	return local varlist `varlist'
	return local responses `nresp'
end

