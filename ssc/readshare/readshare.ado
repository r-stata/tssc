*! Date        : 22 Sep 2017
*! Version     : 0.0.2
*! Author      : Mateusz Najsztub
*! Email       : mnajsztub@cenea.org.pl
*! Description : Stata module for loading the Survey of Health Ageing and Retirement in Europe (SHARE) data 

/* 
The tool was developed within the project "Supporting the realisation of panel data surveys of individuasl aged 50+ in the international project: 
Survey of Health, Ageing and Retirement in Europe (SHARE)" cofinanced by the European Social Fund (Operational Programme: Knowledge, Education and Development – POWER: POWR.02.04.00-00-0059/16).
The basic concept of the tool was developed in cooperation of with dr Konrad Smoliński and Monika Oczkowska within the project SHARE-M4 financed by the European Commission (No261982).

*/


program define readSHARE
	version 13.0
	//assign 1st string as variabale names
	syntax anything [, Waves(string) HHres(string) FAMres(string) FINres(string) ///
		Long(string) descTab IMPutations mergeBy(string) Prefix(string) MODules(string) wide ///
		cv_r xt]

	local read_opts `anything', hh(`hhres') fam(`famres') fin(`finres') long(`long') ///
			`descTab' `imputations' mergeBy(`mergeBy') mod(`modules') `cv_r' `xt' 
	if "$DEBUG" == "1" di "Hello read: `read_opts' `wide' `waves' `xt'"
	local nWaves `:word count `waves'' 
	if `nWaves' == 0 {
		readSHARE `read_opts' w(5)
	}
	else if `nWaves' > 1 {
		// Merge waves
		if "`wide'" == "wide" {
			// Merge into wide
			local rid 0
			foreach w of local waves {
				if "`prefix'" == "" local pfix w`w'_
				else local pfix `prefix'_w`w'_
				if `rid' == 0 readSHARE `read_opts' w(`w') prefix(`pfix') `wide'
				else addSHARE `read_opts' w(`w') prefix(`pfix') `wide'
				local ++rid
			}
		}
		else {
			// Merge into long
			tempfile long
			local rid 0
			foreach w of local waves {
				readSHARE `read_opts' w(`w') prefix(`prefix')
				if "`descTab'" == "" qui gen wave = `w'
				if (`rid' > 0 ) append using `long'
				qui save `long', replace
				local ++rid
			}
		}
	}
	else {
		if ("`long'" != "") {
			local anything `anything' mn101_*
		}
		if ("`xt'" != "") {
			local anything `anything' interview
		}
		// Add vars needed for imputation
		if ("`hhres'" != "") {
			local anything `anything' hou_resp mergeidp* hhid*
		}
		if ("`famres'" != "") {
			local anything `anything' fam_resp mergeidp* hhid*
		}
		if ("`finres'" != "") {
			if (`waves' == 1) {
				local w1sepFin finsep
			}
			local anything `anything' `w1sepFin' fin_resp mergeidp* hhid*
		}
		* Check if `anything' includes vars in *res strings. Add if not
		foreach lv in hhres famres finres long {
			if "``lv''" != "" {
				local diff: list `lv' - anything
				if "`diff'" != "" local anything `anything' `diff'
			}
		}
		* Load imputations identifier
		if "`imputations'" == "imputations" {
			local anything `anything' implicat
		}
		// Set default merge variables if no mergeBy provided
		if ("`mergeBy'" == "") {
			local mergeBy mergeid // hhid
		}
		qui use ${shareDesc}, clear
		qui cap rename varname varName
		qui gen readVar = 0
		* Leave all module data
		if "`modules'" != "" {
			qui gen modVar = 0
			foreach m of local modules {
				qui replace modVar = 1 if fmod == lower("`m'")
			}
			qui keep if modVar == 1
		}
		local noVars
		foreach x of local anything {
			tempvar match
			qui gen `match' = regexm(varName, "^`=regexr("`x'", "\*", ".*")'\_?$") & wave == "`waves'"
			* Check if var is present
			qui count if `match' == 1
			if r(N) == 0 local noVars `noVars' `x'
			else qui replace readVar = 1 if `match'
		}
		* Check for empty dataset
		qui count if readVar == 1
		if r(N) == 0 {
			di as error "ERROR: No variables found to load. Check variable names!"
			exit 111
		}
		if "`noVars'" != "" {
			di as error "WARNING! Variables not found: `noVars'"
		}
		if "`imputations'" ~= "imputations" {
			qui drop if fmod == "gv_imputations"
		}
		* Drop duplicate vars except from cv_r
		qui {
			keep if wave == "`waves'" & readVar==1
			tempvar cvr_tmp
			gen `cvr_tmp' = fmod
			replace `cvr_tmp' = "aaa_" if fmod == "cv_r"
			sort varName `cvr_tmp'
			by varName: gen dups = _n
			by varName: gen dupsN = _N
			by varName: egen cvr_n = total(fmod == "cv_r")
			count if dups > 1 & cvr_n == 0
		}
		if r(N) > 0 {
			di as error "WARNING! Duplicate variable names found."
			di as error "Only the first variables from the list will be left."
			li varName wave fmod if dupsN > 1 & cvr_n == 0
		}
		qui {
			cap drop if dups > 1 
			cap drop dups dupsN cvr_n
		}
		sort varName wave
		qui merge 1:1 varName wave fmod using ${shareDesc}, gen(_shm)
		qui drop if _shm !=3
		if _N==0 & ( "`long'" != "long") {
			di as error "No variables: `anything' to read in Wave `waves'."
			exit
		}
		qui drop readVar _shm
		sort fmod
		* Load vars if there are any to load
		if ("`descTab'" != "descTab") {
			qui keep varName wave fmod 
			qui levelsof fmod, local(modules) clean
			//if regexm("`modules'", "(xt)") local xt "xt"
			di "Wave: `waves'"
			local addVars ""
			tempfile readTmp
			scalar nof = 0
			foreach f of local modules {	
				preserve
					qui levelsof varName if fmod=="`f'", local(tmpNames) clean
					di "Module `=upper("`f'")': `tmpNames'"
					local keepNames "`keepNames' `tmpNames'"
					if (`=nof' == 0) {

						local filel : dir "${w`waves'Dir}" files "sharew`waves'*_`f'.dta"		
						qui use "${w`waves'Dir}/`: word 1 of `filel''", clear
						* Keep all observations form cv_r
						if "`cv_r'" == "" & lower("`f'") == "cv_r" {
							if "`xt'" == "" qui keep if interview == 1
							else qui keep if interview == 2 
						}					
						if ("`f'" == "gv_exrates") 	qui keep country `keepNames'
						else qui keep `mergeBy' `keepNames'
						qui save `readTmp', replace
					} 
					else {
						local filel : dir "${w`waves'Dir}" files "sharew`waves'*_`f'.dta"
						qui use "${w`waves'Dir}/`: word 1 of `filel''", clear					
						if ("`f'" == "cv_h" & "`waves'" == "2" ){
							qui merge m:m hhid using `readTmp', gen(_shm)
						}
						else if ("`f'" == "gv_exrates") { 
							qui merge 1:m country using `readTmp', gen(_shm)
						}
						else {
							qui merge 1:1 `mergeBy' using `readTmp', gen(_shm)
							//qui keep if _merge !=2
						}
						* Keep all observations form cv_r
						if "`cv_r'" == "" & lower("`f'") == "cv_r" {
							if "`xt'" == "" qui keep if interview == 1
							else qui keep if interview == 2 
						}
						if ("`f'" == "gv_exrates") 	qui keep country `keepNames'
						else qui keep `mergeBy' `keepNames'
						qui save `readTmp', replace	
					}
				restore
				scalar nof = `=nof+1'
			}
			// Clean the data
			use `readTmp', clear
			if "`long'" != "" | "`hhres'" != "" | "`famres'" != "" | "`finres'" != "" {
				di "-----------------------------------------------"
				di "| Clean variables:"
				if ("`long'" != "" & `waves' > 1) {
					di "| Completing longitudinal variables: `long'"
					_imputeLongitudinal `long', wno(`waves') 
				}
				if ("`hhres'" != "") {
					di "| Completing HH Respondent variables: `hhres'"
					_imputeHH `hhres', wno(`waves') 
				}
				if ("`famres'" != "") {
					di "| Completing Fam Respondent variables: `famres'"
					_imputeFam `famres', wno(`waves') 
				}
				if ("`finres'" != "") {
					di "| Completing Fin Respondent variables: `finres'"
					_imputeFin `finres', wno(`waves') 
				}
				di "-----------------------------------------------"
			}
		}
		// Clean obs if XT
		if "`xt'" != "" qui keep if interview == 2
		// Add prefix to variables
		if "`prefix'" != "" {
			foreach v of varlist * {
				if "`v'" == "mergeid" continue
				if "`v'" == "implicat" continue
				rename `v' `prefix'`v'
			}
		}
	}
end


/* Impute values based on the household respondent's ans */
program define _imputeHH

	syntax anything [, wno(integer 4) prefix(string) hhvar(string)]
	if "`hhvar'" == "" local hhvar `prefix'hou_resp
	
	/* Add prefix to anything */
	if "`prefix'" != "" {
		local tmpAny 
		foreach v of local anything {
			local tmpAny `tmpAny' `prefix'`v'
		}
		local anything `tmpAny'
	}
	
	/* Check if variables exist */
	qui _doExist `anything'
	local ex `r(Exist)'
	local nex `r(notExist)'
	local anything `ex'
	if "`ex'" != "" di "	Found `ex'"
	if "`nex'" != "" {
		di "    Variables missing in the data: `nex'"
		di "    Working with the rest..."
	}
	if regexm("`ex'", "[a-zA-Z]") != 1  {
		di "	None of the variables exist"
		exit
		//error 111
	}
		
	/* First merege only hhs with single hou_resp */
	tempfile tmp	
	tempvar nhhr
	tempvar hhr_miss
	qui gen `hhr_miss' = `hhvar' if `hhvar' >= 0
	qui bys `prefix'hhid`wno': egen `nhhr' =  sum(`hhr_miss')
	qui count if `nhhr' > 1
	if `r(N)' > 0 di "   There are `r(N)' HHs with multiple hou_resp"
	preserve	
		qui keep if `hhvar' == 1 & `nhhr'==1
		rename `prefix'mergeidp merged_mergeidp

		foreach v of local anything {
			rename `v' merged_`v'
		}
		qui keep `prefix'hhid`wno' merged_* `nhhr' 
		qui save `tmp', replace
	restore
	qui merge m:m `prefix'hhid`wno' using `tmp', gen(_shm)
	qui foreach v of local anything {
		qui replace `v' = merged_`v' if _shm == 3 & `v'==. & `nhhr'==1 & `hhvar' >= 0
	}
	qui drop merged_* _shm
	
	/* Now for the HHs with multiple hhResps */
	preserve	
		qui keep if `hhvar' == 1 & `nhhr' > 1
		qui replace mergeid = `prefix'mergeidp 
		foreach v of local anything {
			rename `v' merged_`v'
		}
		qui keep `prefix'hhid`wno' merged_* `nhhr' mergeid
		qui save `tmp', replace
	restore
	qui merge m:m `prefix'hhid`wno' mergeid using `tmp', gen(_shm)
	qui foreach v of local anything {
		qui replace `v' = merged_`v' if _shm == 3 & `v'==. & `nhhr'>1 & `hhvar' >= 0
	}
	drop if length(mergeid)!=12
	qui drop merged_* _shm

end

/* Impute values based on the financial respondent's ans */
program define _imputeFin
	syntax anything [, wno(integer 4) prefix(string) finvar(string)]
	if "`finvar'" == "" local finvar `prefix'fin_resp
	/* Add prefix to anything */
	if "`prefix'" != "" {
		local tmpAny 
		foreach v of local anything {
			local tmpAny `tmpAny' `prefix'`v'
		}
		local anything `tmpAny'
	}
	
	/* Check if variables exist */
	qui _doExist `anything'
	local ex `r(Exist)'
	local nex `r(notExist)'
	local anything `ex'
	if "`ex'" != "" di "	Found `ex'"
	if "`nex'" != "" {
		di "    Variables missing in the data: `nex'"
		di "    Working with the rest..."
	}
	if regexm("`ex'", "[a-zA-Z]") != 1  {
		di "	None of the variables exist!"
		exit
		//error 111
	}

	preserve
		tempfile tmp
		if (`wno' == 1) {
			replace `prefix'`finvar' = 0 if `prefix'finsep == 1
		}
		qui keep if `prefix'`finvar' == 1

		foreach v of local anything {
			rename `v' merged_`v'
		}
		keep `prefix'hhid`wno' mergeid merged_*
		qui gen `prefix'mergeidp`wno' = mergeid
		qui save `tmp'
	restore
	qui merge m:m `prefix'hhid`wno' `prefix'mergeidp`wno' using `tmp', gen(_shm)
	qui drop if _shm == 2 
	qui foreach v of local anything {
		replace `v' = merged_`v' if _shm == 3 & `v' == . & `prefix'`finvar' == 0 
	}
	qui drop merged_* _shm

end

/* Impute values based on the family respondent's ans */
program define _imputeFam
	version 13.0
	syntax anything [, wno(integer 4) prefix(string) famvar(string)]
	if "`famvar'" == "" local famvar `prefix'fam_resp
	
	/* Add prefix to anything */
	if "`prefix'" != "" {
		local tmpAny 
		foreach v of local anything {
			local tmpAny `tmpAny' `prefix'`v'
		}
		local anything `tmpAny'
	}
	
	/* Check if variables exist */
	qui _doExist `anything'
	local ex `r(Exist)'
	local nex `r(notExist)'
	local anything `ex'
	if "`ex'" != "" di "	Found `ex'"
	if "`nex'" != "" {
		di "    Variables missing in the data: `nex'"
		di "    Working with the rest..."
	}
	if regexm("`ex'", "[a-zA-Z]") != 1  {
		di "	None of the variables exist"
		exit
		//error 111
	}
	
	* Impute
	preserve
		tempfile tmp
		qui keep if `prefix'`famvar' == 1
		foreach v of local anything {
			rename `v' merged_`v'
		}
		keep `prefix'hhid`wno' mergeid merged_*
		cap drop `prefix'mergeidp
		rename mergeid `prefix'mergeidp`wno'
		qui save `tmp'
	restore
	qui merge m:m `prefix'hhid`wno' `prefix'mergeidp`wno' using `tmp', gen(_shm)
	qui drop if _shm == 2 
	qui foreach v of local anything {
		replace `v' = merged_`v' if _shm == 3 & `v' == . & `prefix'`famvar' >= 0
	}
	qui drop merged_* _shm
end

* Impute longitudinal values
program define _imputeLongitudinal
	syntax anything [, wno(integer 4) *]
	/* Check if variables exist */
	qui _doExist `anything'
	local ex `r(Exist)'
	local nex `r(notExist)'
	local anything `ex'
	if "`ex'" != "" di "	Found `ex'"
	if "`nex'" != "" {
		di "    Variables missing in the data: `nex'"
		di "    Working with the rest..."
	}
	if regexm("`ex'", "[a-zA-Z]") != 1  {
		di "	None of the variables exist"
		error 111
	}
	tempvar orig_data
	qui gen `orig_data' = 1
	
	local wid `wno'
	if (`wid'==4) {
		local wid 3
	}
	/* Save info */
	qui foreach v of local anything {
		local lw `wid'
		if `lw' == 3 local lw 4
		gen long_info_`v' = ""
		cap confirm string variable `v'
		if _rc != 0 {
			replace long_info_`v' = long_info_`v' + "W`lw': 1" if `v' != . & `v' >=0
			replace long_info_`v' = long_info_`v' + "W`lw': 0" if `v' == .
			replace long_info_`v' = long_info_`v' + "W`lw': <0" if `v' < 0
		}
		else {
			replace long_info_`v' = long_info_`v' + "W`lw': 1" if `v' != ""
			replace long_info_`v' = long_info_`v' + "W`lw': 0" if `v' == ""
		}
	}

	qui gen source_mn = mn101_
	while (`wid' >1 ){
		if (`wid'==4) {
			local wid 3
			continue
		}
		foreach v of local anything {
			cap rename `v' merged_`v'
		}
		preserve
			qui keep if mn101_ == 1
			keep mergeid 

			noi di "Load Wave no: `=`wid'-1'"
			cap noi addSHARE `anything' mn101_, wave(`=`wid'-1') `options'
			* Continue if no vars found in a wave
			if _rc == 111 {
				restore
				qui foreach v of local anything {
					cap rename merged_`v' `v'
				}
				local --wid
				continue
			}
			if (`wid'>2) rename mn101_ merged_mn101_

			tempfile tmp`wid'Merged
			qui save `tmp`wid'Merged', replace
		restore
		qui merge 1:1 mergeid using `tmp`wid'Merged'
		/* Save info */
		qui foreach v of local anything {
			local lw `=`wid'-1'
			cap confirm variable `v' 
			if _rc == 0 {
				cap confirm string variable `v'
				if _rc != 0 {
					replace long_info_`v' = long_info_`v' + ", W`lw': 1" ///
						if `v' != . & `v' >=0
					replace long_info_`v' = long_info_`v' + ", W`lw': 0" if `v' == .
					replace long_info_`v' = long_info_`v' + ", W`lw': <0" if `v' < 0
				}
				else {
					replace long_info_`v' = long_info_`v' + ", W`lw': 1" if `v' != ""
					replace long_info_`v' = long_info_`v' + ", W`lw': 0" if `v' == ""
				}
			}
		}
		qui foreach v of local anything {
			* Replacing takes place here
			cap replace merged_`v' = `v'  if _merge == 3 ///
				& ( merged_`v'== . | (merged_`v' < 0 & `v' != .))
			cap drop `v'
			cap rename merged_`v' `v'
		}
		if (`wid'>2) {
			qui replace mn101 = merged_mn101_ if _merge ==3
		}
		qui cap drop merged_* 
		qui drop _merge
		local --wid
	}
	qui cap replace mn101_=source_mn
	qui keep if `orig_data' == 1
	qui cap drop source_mn `orig_data'
	cap drop _merge
end

/* Check if variables exist */
/* 
	Return lists with vars that do exist and 
	another with vars that don't 
*/
program define _doExist, rclass
	version 13.0
	syntax anything
	* Get names of varaibles in the dataset
	qui ds
	local dataset `r(varlist)'
	local Exist
	local notExist
	foreach var of local anything {
		local inData 0
		foreach dvar of local dataset {
			if regexm("`dvar'", "^`var'.*") {
				local Exist `Exist' `dvar'
				local inData 1
			}
		}
		if `inData' == 0 local notExist `notExist' `var'		
	}
	local Exist: list uniq Exist
	return local Exist `Exist'
	return local notExist `notExist'
end


