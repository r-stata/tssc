*! Version 1.2.1 22aug2019
* Contact jesse.wursten@kuleuven.be for bug reports/inquiries.
/* INTERNAL NOTE: to run testprogram: 
	batcher //tsclient/G/Other/SSC programs\batcher/batcher_testprogram.do, i(1/2) sl(2) t(Y:/BatcherLogs)
*/

* Changelog
** 22aug2019: Fixed sleepduration issue
** 19aug2019: Added middleman finder
** 25jan2019: Changed Y:/middleman to G:/middleman (will break usage on pc)
** 04oct2018: Made file more robust to whitespaces in dofilenames
** 25jul2018: Added "`'-stripping to avoid errors on evaluating last line of log file
** 23jul2018: Changed to dofile middleman structure
** 23jan2018: Better folder management (creation and wd reset) and cleaner output.
** 08dec2017: Added notification when particular iteration finishes


cap program drop batcher
cap program drop batcher_saveoption
program define batcher
	* Syntax parsing
	version 8.0
	syntax anything(name=dofileName), [Tempfolder(string)] [STataexe(string)] Iter(numlist) [notrack] [SLeepduration(integer 60)] [sts(string) sts_exceptsuccess] [SAVEoptions(string)] [nostop noquit]
	
	** Saving options (to profile.do)
	if `"`saveoptions'"' != "" {
		if `"`sts'"' != ""				& strpos("`saveoptions'", "sts") > 0				batcher_saveoption, name(sts) 					value(`"`sts'"')
		if `"`sts_exceptsuccess'"' != ""& strpos("`saveoptions'", "sts_exceptsuccess") > 0	batcher_saveoption, name(sts_exceptsuccess) 	value(`"`sts_exceptsuccess'"')
		if `"`tempfolder'"' != "" 		& strpos("`saveoptions'", "tempfolder") > 0			batcher_saveoption, name(tempfolder) 			value(`"`tempfolder'"')
		if `"`sleepduration'"' != "60"	& strpos("`saveoptions'", "sleepduration") > 0		batcher_saveoption, name(sleepduration) 		value(`"`sleepduration'"')
		if `"`stop'"' != ""			& strpos("`saveoptions'", "nostop") > 0				batcher_saveoption, name(stop) 				value(`"`stop'"')
		if `"`quit'"' != ""			& strpos("`saveoptions'", "noquit") > 0				batcher_saveoption, name(quit) 				value(`"`quit'"')
	}
	
	** Loading options
	*** sts
												local stsDefined ""					// 3. Default is empty
	if "${batcher_sts}" != "" 					local stsDefined `"${batcher_sts}"'	// 2. Saved sts url
	if `"`sts'"' != "" 							local stsDefined `"`sts'"'			// 1. Specified sts url
	if `"`sts'"' == "overwrite" 				local stsDefined ""					// 0. Empty if user wants to overwrite saved sts url
	*** sts_exceptsuccess
												local sts_exceptsuccessDefined ""								// 3. Default is empty
	if "${batcher_sts_exceptsuccess}" != "" 	local sts_exceptsuccessDefined `"${batcher_sts_exceptsuccess}"'	// 2. Saved sts_exceptsuccess url
	if `"`sts_exceptsuccess'"' != "" 			local sts_exceptsuccessDefined `"`sts_exceptsuccess'"'			// 1. Specified sts_exceptsuccess url
	if `"`sts_exceptsuccess'"' == "overwrite" 	local sts_exceptsuccessDefined ""								// 0. Empty if user wants to overwrite saved sts_exceptsuccess
	
	*** tempfolder
											local tempfolderDefined ""							// 3. Default is empty
	if "${batcher_tempfolder}" != "" 		local tempfolderDefined `"${batcher_tempfolder}"'	// 2. Saved tempfolder url
	if `"`tempfolder'"' != "" 				local tempfolderDefined `"`tempfolder'"'			// 1. Specified tempfolder url
	if `"`tempfolder'"' == "overwrite" 		local tempfolderDefined ""							// 0. Empty if user wants to overwrite saved tempfolder
	
	*** sleepduration
											local sleepdurationDefined "60"							// 3. Default is empty
	if "${batcher_sleepduration}" != "" 	local sleepdurationDefined `"${batcher_sleepduration}"'	// 2. Saved sleepduration url
	if `"`sleepduration'"' != "60" 			local sleepdurationDefined `"`sleepduration'"'			// 1. Specified sleepduration url
	if `"`sleepduration'"' == "overwrite" 	local sleepdurationDefined ""							// 0. Empty if user wants to overwrite saved sleepduration
	
	*** nostop
										local stopDefined "stop"					// 3. Default is to stop on errors
	if "${batcher_stop}" != "" 			local stopDefined `"${batcher_stop}"'	// 2. Saved stop url
	if `"`stop'"' != "" 				local stopDefined `"`stop'"'			// 1. Specified stop url
	if `"`stop'"' == "overwrite" 		local stopDefined ""						// 0. Empty if user wants to overwrite saved stop
	
	*** noquit
										local quitDefined "quit"					// 3. Default is to quit on errors
	if "${batcher_quit}" != "" 			local quitDefined `"${batcher_quit}"'	// 2. Saved quit url
	if `"`quit'"' != "" 				local quitDefined `"`quit'"'			// 1. Specified quit url
	if `"`quit'"' == "overwrite" 		local quitDefined ""						// 0. Empty if user wants to overwrite saved quit url
	
	** Parsing options
	if `"`tempfolderDefined'"' == "" {
		di as text "No tempfolder specified nor saved. Using current working directory: " as result c(pwd)
		local tempfolderDefined = c(pwd)
	}
	local dofileName : subinstr local dofileName `"""' "", all
	local sleepduration_ms = `sleepdurationDefined'*1000

	if "`stataexe'" == "" {
		if c(flavor) == "IC" local flavor "IC"
		if c(SE) == 1 local flavor "SE"
		if c(MP) == 1 local flavor "MP"
		
		if c(bit) == 64 local bit "64"
		else local bit "32"
	}
	local stataexe "`c(sysdir_stata)'Stata`flavor'-`bit'"
	local numberOfIterations = wordcount("`iter'")

	* Find middleman
	qui findfile batcher.ado
	local middlemanPath = r(fn)
	local middlemanPath = subinstr("`middlemanPath'", "batcher.ado", "batcher_middleman.do", .)
	
	
	* Start dofiles
	cap mkdir "`tempfolderDefined'"
	noisily di `"Starting `dofileName'"'
	foreach iteration of numlist `iter' {
		* Start new stata process to perform the dofile
		noisily di _col(3) as text `"iteration `iteration'"'
		winexec "`stataexe'" do "`middlemanPath'" "0`dofileName'0" `iteration' "`tempfolderDefined'" "`stopDefined'" "`quitDefined'"
		sleep 10000
		*sleep 2000
	}


	* Assess whether finished
	if "`track'" != "notrack" {
		noisily di as result "Starting tracking in `sleepdurationDefined' seconds. Refreshing every 30 seconds."
		sleep `sleepduration_ms'
		local true "false"
		noisily di as text _col(4) "Finished: " _continue
		local finishedCount = 0
		local somethingFailed = 0
		local failures ""
		while "`true'" != "true" {
			foreach iteration of numlist `iter' {
				tempname log
				file open `log' using `"`tempfolderDefined'/iteration`iteration'.log"', read
				file seek `log' eof
				local posToStart = `r(loc)' - 27
				file seek `log' `posToStart'
				file read `log' line
				file close `log'
				local line = subinstr(`"`macval(line)'"', char(34), "", .)
				local line = subinstr(`"`macval(line)'"', char(39), "", .)
				local line = subinstr(`"`macval(line)'"', char(96), "", .)
				
				* Success
				if `"`line'"' == "Execution report: Success" & "`finished_`iteration''" != "1" {
					local finished_`iteration' = 1
					local finishedCount = `finishedCount' + 1
					noisily di as result " `iteration' " _continue
					if "`stsDefined'" != "" & "`sts_exceptsuccessDefined'" == "" qui sendtoslack, url(`stsDefined') message("Iteration `iteration' finished.")
				}
				
				* Failure
				if `"`line'"' == "Execution report: Failure" & "`finished_`iteration''" != "1" {
					local finished_`iteration' = 1
					local finishedCount = `finishedCount' + 1
					local somethingFailed = 1
					local failures = trim("`failures' `iteration'")
					noisily di as error " `iteration' " _continue
					if "`stsDefined'" != "" qui sendtoslack, url(`stsDefined') message("ERROR! Iteration `iteration' failed!")
				}
			}
			if "`finishedCount'" == "`numberOfIterations'" local true "true"
			
			if "`true'" != "true" {
				noisily di as txt "x" _continue
				sleep 30000
			}
		}
		if "`somethingFailed'" == "0" {
			noisily di as result " OK"
			noisily di _newline as result "Batch job has finished."
			if "`stsDefined'" != "" sendtoslack, url(`stsDefined') message("Batch job has finished.") col(4)
		}
		if "`somethingFailed'" == "1" {
			noisily di as error " Something failed!"
			noisily di _newline as result "Batch job has finished, but with " as error "failures" as result "!"
			noisily di as result "Failed iterations: " as error "`failures'"
			if "`stsDefined'" != "" sendtoslack, url(`stsDefined') message("Batch job has finished with failures: iterations `failures'.") col(4)
		}
	}
end

program define batcher_saveoption
	syntax, name(string) value(string)

	* Determine whether profile.do exists
	cap findfile profile.do

	** If profile.do does not exist yet
	** Create profile.do (asking permission)
	if _rc == 601 {
		di "Profile.do does not exist yet."
		di "Do you want to allow this program to create one for you? y: yes, n: no" _newline "(enter below)" _request(_createPermission)
		
		if "`createPermission'" == "y" {
			di "Creating profile.do as `c(sysdir_oldplace)'profile.do"
			tempname createdProfileDo
			
			file open `createdProfileDo' using `"`c(sysdir_oldplace)'profile.do"', write
			file close `createdProfileDo'
		}
		
		if "`createPermission'" != "y" {
			di "User did not give permission to create profile.do, aborting program."
			exit
		}
	}

	* Write in global for url
	** Verify if global is already defined (if so, give warning)
	*** Find location of profile.do
	qui findfile profile.do
	local profileDofilePath "`r(fn)'"

	*** Open
	tempname profileDofile
	file open `profileDofile' using "`profileDofilePath'", read text
	file read `profileDofile' line

	*** Loop over profile.do until ...
	***		you reached the end
	***		found the global we want to define
	local keepGoing = 1
	while `keepGoing' == 1 {
		if strpos(`"`macval(line)'"', "sts_`name'") > 0 {
			di as error  "Global was already defined in profile.do"
			di as result "The program will add the new definition at the bottom."
			di "You might want to open profile.do and remove the old entry."
			di "This is not required, but prevents clogging your profile.do."
			di "To do so, type: " as txt "doed `profileDofilePath'" _newline
			
			local keepGoing = 0
		}
		
		file read `profileDofile' line
		if r(eof) == 1 local keepGoing = 0
	}
	file close `profileDofile'

	** Write in the global
	file open `profileDofile' using "`profileDofilePath'", write text append
	file write `profileDofile' _newline `"global batcher_`name' `"`value'"'"'
	file close `profileDofile'
	
	** Define it now too, as profile.do changes only take place once it has ran
	global batcher_`name' `"`value'"'

	* Report back to user
	di as text "Added a default " as result "`name'" as text " to " as result "`profileDofilePath'"
	di as text "On this PC, " as result `"`name'(`value')"' as text " will now be used even if no " as result "`name'" as text " option was specified for the batcher command."
	di as text "In other words, you can now type " as result "batcher" as text " and it will execute " as result `"batcher, `name'(`value')"' as text " (+ any other saved options)." _newline
end
