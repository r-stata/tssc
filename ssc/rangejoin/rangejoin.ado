*! version 1.1.2  25nov2017 Robert Picard
*! requires -rangestat- version 1.1.0, available from SSC
program define rangejoin

	version 11
	
	syntax anything(name=interval id="keyvar low high") 	///
		using/				///
		, 					///
		[					///
		BY(varlist)			///
		Keepusing(string)	///
		Prefix(string)		///
		Suffix(string)		///
		All					///
		]
		
	
	cap rangestat
	if _rc == 199 {
		dis as error "This command requires rangestat (from SSC)."
		dis as error "To install rangestat, click on the link below"
		dis as txt "{stata ssc install rangestat}"
		exit _rc
	}
	else if "`r(rangestat_version)'" == "" {
		dis as error "This command requires the latest version of rangestat (from SSC)."
		dis as error "To update rangestat, click on the link below"
		dis as txt "{stata adoupdate rangestat, update}"
		exit _rc
	}
	else dis as txt "  (using rangestat version `r(rangestat_version)')"

	// default for renaming variables in using dataset
	if "`prefix'`suffix'" == "" local suffix _U


	// be flexible if commas are use to separate keyvar, low, and high
	local interval : subinstr local interval "," " ", all
	tokenize "`interval'"
	
	if "`4'" != "" {
		dis as err "extra argument after keyvar low high: `4'"
		exit 198
	}
	
	args vkey low high 

	cap confirm numeric var `vkey'
	if _rc == 7 {
		dis as err "keyvar in the data in memory is not numeric"
		exit _rc
	}
	local hasvkey = _rc == 0 

	// the lower interval bound
	tempvar klow
	cap confirm numeric var `low'
	if _rc {
		cap confirm number `low'
		if _rc & "`low'" != "." {
			dis as err "was expecting a numeric variable, a number, or a system missing value for the interval low: `low'"
			exit 198
		}
		qui if !`hasvkey' gen double `klow' = `low'
		else qui gen double `klow' = `vkey' + `low'
	}
	else qui gen double `klow' = cond(`low' > ., ., `low')	// no extended missing
	
	// the higher interval bound
	tempvar khigh
	cap confirm numeric var `high'
	if _rc {
		cap confirm number `high'
		if _rc & "`high'" != "." {
			dis as err "was expecting a numeric variable, a number, or a system missing value for the interval high: `high'"
			exit 198
		}
		qui if !`hasvkey' gen double `khigh' = `high'
		else qui gen double `khigh' = `vkey' + `high'
	}
	else qui gen double `khigh' = cond(`high' > ., ., `high')	// no extended missing
	
	// inrange(z,a,b) returns 1 if mi(a) & !mi(z)
	qui replace `klow' = c(mindouble) if mi(`klow')
	
	// a missing for keyvar marks out the observation
	if `hasvkey' {
		qui replace `klow' = 1 if mi(`vkey')
		qui replace `khigh' = 0 if mi(`vkey')
	}
	
	if "`: list vkey & by'" != "" {
		dis as error "key variable -`vkey'- cannot appear in by(`by') option"
		exit 198
	}
	
	
	// if vkey is in the master, it will be renamed in the using
	local vkey0 `vkey'
	if `hasvkey' | "`all'" != "" local vkey `prefix'`vkey'`suffix'
	
	if _N == 0 error 2000

	tempvar obsm
	gen long `obsm' = _n
	
	// about to change the data
	preserve
	
	// save obs with invalid interval bounds separately
	qui count if `klow' > `khigh'
	if r(N) {
		qui keep if `klow' > `khigh'
		tempfile master_mi
		qui save "`master_mi'"
		restore, preserve
		qui drop if `klow' > `khigh'
	}
	
	if _N == 0 {
		dis as err "no observation with valid interval bounds to use"
		exit 2000
	}
	
	tempfile master2use
	qui save "`master2use'"
	

	if "`keepusing'" != "" qui use `keepusing' `by' `vkey0' using `"`using'"', clear
	else qui use `"`using'"', clear
	
	// obs with missing values in keyvar cannot match
	qui drop if mi(`vkey0')
	if _N == 0 {
		dis as err "no observation in using with non-missing values for key variable -`vkey0'-"
		exit 2000
	}
	
	// using data must be ordered by vkey; make it stable
	tempvar obsu
	gen long `obsu' = _n
	sort `by' `vkey0' `obsu'
	drop `obsu'
	tempfile keyuse
	qui save "`keyuse'"
	

	qui use "`master2use'"
	
	
	sidebyside using "`keyuse'", by(`by') prefix(`prefix') suffix(`suffix') `all' nogen
	local uvars `r(using_vars)'

	// using must include keyvar
	cap confirm numeric var `vkey'
	if _rc == 7 {
		dis as err "key variable `vkey' in using dataset is not numeric"
		exit 7
	}
	else if _rc error _rc
	
	
	// an overall observation identifier
	tempvar n
	gen long `n' = _n
	
/*
	Since -rangestat- will skip any obs with mi(vkey), we need to handle cases
	where there are more observations in master2use than in keyuse because the
	keyuse variables will have missing observations once side-by-side with
	master2use. The replacement value does not matter, the `indices' are missing
	if mi(`vkey'). We use the largest value that can be stored in the key variable's
	storage type to reduce the number of times these observations will be picked-up.
*/
	tempvar indices
	qui gen long `indices' = `n' if !mi(`vkey')
	qui replace `vkey' = c(max`:type `vkey'') if mi(`vkey')
	
/*
	If there are more obs in keyuse than in master2use, klow and khigh will 
	have missing values once side side-by-side. We can use `klow' to detect
	these since all missing lower bounds have been replaced with c(mindouble).
	Since all cases where low > high have been removed, we use that to
	exclude these extra cases.
*/
	qui replace `khigh' = 0 if mi(`klow')
	qui replace `klow' = 1 if mi(`klow')
	

	rangestat (min) `indices' (max) `indices', i(`vkey' `klow' `khigh') by(`by')
	
	
	tempfile hold finalusing finalmaster
	qui save "`hold'"
	
	qui keep if !mi(`indices')
	keep `n' `uvars'
	qui save "`finalusing'"
	
	qui use "`hold'"
	qui keep if !mi(`obsm')
	drop `n' `uvars'

	qui expand `indices'_max - `indices'_min + 1
	qui bysort `obsm': gen long `n' = `indices'_min + _n - 1
	
	sort `obsm' `n'
	
	qui merge m:1 `n' using "`finalusing'", keep(master match) nogen
	
	// reintroduce the obs with missing values for the interval bounds
	if "`master_mi'" != "" {
		append using "`master_mi'"
	}
	
	sort `obsm' `n'	
	
	restore, not
	
end


*! uses local copy of -sidebyside- version 1.0.0  12mar2016 Robert Picard
program define sidebyside, rclass

	version 11
	
	syntax using/				///
		, 					///
		[					///
		BY(varlist)			///
		Keepusing(string)	///
		Prefix(string)		///
		Suffix(string)		///
		GENerate(name)		///
		NOGENerate			///
		All					///
		]
		
		
	// default for renaming variables in using dataset
	if "`prefix'`suffix'" == "" local suffix _U
	
	if "`by'" != "" unab by : `by'

	// quick check that will fail if variables are not in using
	qui des `keepusing' `by' using `"`using'"'
	
	unab v_master : *
	
	if "`generate'" == "" & "`nogenerate'" == "" local generate _source
	
	preserve
	
	
	if "`keepusing'" != "" qui use `keepusing' `by' using `"`using'"', clear
	else qui use `"`using'"', clear
	
	
	unab keepusing : *
	local keepusing : list keepusing - by
	
	if "`all'" != "" local v_rename `keepusing'
	else local v_rename : list keepusing & v_master
	
	foreach v of local v_rename {
	
		local newname `prefix'`v'`suffix'
		if `: list newname in v_master' {
			dis as err "can't rename -`v'- to -`newname'- in using dataset; -`newname'- also found in data in memory"
			exit 110
		}
		
		cap rename `v' `newname'
		if _rc == 110 {
			dis as err "variable name conflict when renaming -`v'- to -`newname'- in using dataset"
			exit 110
		}
		else if _rc != 0 error _rc
		
	}
	
	unab keepusing : *
	local keepusing : list keepusing - by
	
		
	if "`by'" != "" {
	
		tempvar obs
		gen long `obs' = _n
		qui bysort `by' (`obs'): replace `obs' = _n
		sort `by' `obs'
		
	}


	tempfile from_using
	qui save "`from_using'"
	
	
	restore, preserve
	

	if "`by'" != "" {
	
		gen long `obs' = _n
		qui bysort `by' (`obs'): replace `obs' = _n
		sort `by' `obs'
		qui merge 1:1 `by' `obs' using "`from_using'", sorted `nogenerate' gen(`generate')
		sort `by' `obs'
		
	}
	else {
		
		qui merge 1:1 _n using "`from_using'",  `nogenerate' gen(`generate')
		
	}

	if "`generate'" != "" {
		order `v_master' `generate' `keepusing'
		label define _sidebyside 1 "master" 2 "using" 3 "both"
		cap label drop _merge
		label values `generate' _sidebyside
		format %-6.0g `generate'
	}
	
	
	restore, not

	
	return local master_vars `v_master'
	return local using_vars `keepusing'
	
end


