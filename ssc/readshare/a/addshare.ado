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


program define addSHARE
	version 13.0
	syntax anything [, saveMerge prefix(string) Waves(string) wide xt *]

	if "$DEBUG" == "1" di "Hello addSHARE!"
	if "`xt'" != "" local wide wide
	if "`waves'" == "" local waves 5
	// Merge by wave if wave var exists
	local mergeWave
	local has_wave 0
	cap confirm variable wave
	if !_rc local has_wave 1
	if `has_wave' == 1 & "`wide'" == "" local mergeWave wave 
	
	local mt 1:m
	local mergeImp
	cap confirm variable implicat
	if !_rc {
		local mergeImp implicat
	}
	local is_cvr 1
	cap confirm variable mergeid
	local mid mergeid
	if !_rc {	
		preserve
			clear
			local tmpxt `xt'
			local tmpwide 
			// Check if XT & CV_R
			if "`xt'" != ""	{		
				qui readSHARE `anything', w(`waves') descTab
				qui levelsof fmod, local(mods)
				if !regexm(lower(`mods'), "cv_r") {
					local tmpxt 
					local tmpwide `wide'
					local is_cvr 0
				}
			}
			else local tmpwide `wide'
			if "$DEBUG" == "1" di "XT: `xt', XTtmp: `tmpxt', WIDE: `wide', WIDEtmp: `tmpwide'"
			if "$DEBUG" == "1" di "readSHARE `anything', `options' w(`waves') `tmpwide' `tmpxt'"
			readSHARE `anything', `options' w(`waves') `tmpwide' `tmpxt'
			tempfile addSHARE
			// In case some vars do not exist in Wave
			local anythingVars
			if "`imputations'" == "imputations" {
				qui bys mergeid: gen dropId = _n
				reshape wide `anything', i(mergeid) j(dropId)
			}
			if "`prefix'" != "" {
				foreach v of varlist * {
					if "`v'" == "mergeid" continue
					if "`v'" == "implicat" continue
					rename `v' `prefix'`v'
				}
			}
			// Add wave info if wave exists and only 1 wave given
			if `:word count `waves'' == 1 & "`mergeWave'" != "" {
				if "`waves'" != "X"	qui gen wave = `waves'
				else gen wave = .
			}
			// Remove implicat from merge var if not present
			cap confirm variable implicat
			if _rc != 0 {
				if "`mergeImp'" != "" local mt m:1
				local mergeImp
			}
			// Remove mergeid from merge var if not present
			cap confirm variable mergeid
			if _rc != 0 {
				local mid country
				local mt m:1
			}
			qui save `addSHARE'
		restore
		if "`wide'" != "" {
			local mt m:m
			local mergeWave
		}
		if "$DEBUG" == "1" {
			di "merging add: merge `mt' `mid' `mergeWave' `mergeImp' using `addSHARE'"
		}
		merge `mt' `mid' `mergeWave' `mergeImp' using `addSHARE', gen(_shm)
		if "`xt'" == "xt" & !`is_cvr' qui keep if _shm != 2
		if "`saveMerge'" != "saveMerge" {
			qui drop _shm
		}
	}
	else {
		readSHARE `anything', `options' prefix(`prefix') w(`waves') `wide' `xt'
	}

end
