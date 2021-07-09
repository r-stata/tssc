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

program define createSHAREDesc
	version 13.0
	syntax [, sDir(string) dirs(string)]
	if "`sDir'" == "" & "`dirs'" == "" {
		global inputsDir
		di "Please provide a path to SHARE data catalogues:" _request(inputsDir)
		local sDir "$inputsDir"
	}
	
	tempfile desc
	
	* Get directories with sharew[0-9].*
	if "`dirs'" == "" local dirs: dir "`sDir'" dirs "share*", respectcase
	local globalFid 0
	local nwaves 
	foreach wdir in `dirs' {
		di "Entering `wdir'"
		local absdir "`wdir'"
		if "`sDir'" != "" local absdir "`sDir'/`wdir'"
		local mods: dir "`absdir'" files "sharew*.dta", respectcase
		local nFiles `: word count `mods''
		if `nFiles' == 0 {
			di "	No sharew*.dta files in `wdir'"
			continue
		}
		local fid 1
		foreach mod in `mods' {
			di "	Reading `mod' (`fid'/`nFiles')"
			/* Extract wave & module */
			local reCond "(sharew)(.)_rel[0-9\-]+_([a-zA-Z0-9_\-]+)\.dta"
			local reMatch =regexm("`mod'", "`reCond'")
			if `reMatch' != 1 {
				di "		File `mod' not in default SHARE module format!"
				continue
			}
			local wave =regexs(2)
			local module =regexs(3)
			//di "`wave', `module'"
			
			qui use "`absdir'/`mod'", clear
			
			_genShDesc
			
			qui gen wave = "`wave'"
			qui gen fmod = "`module'"
			
			if `globalFid' == 0 qui save `desc', replace
			else {
				qui append using `desc'
				qui save `desc', replace
			}
			
			local ++fid
			local ++globalFid
		}
		local nwaves `nwaves' `wave'
		local w`wave'dir global w`wave'Dir "`absdir'"
	}
	di in red "SHARE data globals to be set before running readSHARE:" _n
	foreach v in `nwaves' {
		if regexm("`v'", "[0-9]+") di `" `w`v'dir' "'
	}
	di `" global shareDesc "" "' _n
	di in red "The output .dta has to be saved manually!"
	di in red "Absolute path to the .dta has to be put into shareDesc global."
	
end

/* Describe each SHARE module dta */
program define _genShDesc
	version 13.0
	//args saveFile
	qui keep if _n == 1
	tempfile descTemp dataTemp
	qui save `dataTemp', replace
	local rid 0
	qui foreach v of varlist * {
		use `dataTemp', clear
		local vLab: variable label `v'
		
		clear
		set obs 1
		gen varName = "`v'"
		gen statement = "`vLab'"
		
		if `rid' == 0 save `descTemp', replace
		else {
			append using `descTemp'
			save `descTemp', replace
		}
		
		local ++rid
	}
end
