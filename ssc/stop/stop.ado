* Convenient program stopper
*! Version 1.0.2 22may2020
* Contact jesse.wursten@kuleuven.be for bug reports/inquiries.

* Changelog
** 26jun2018: The command is born.

*stop																	// Stop dofile, close log
*stop, sts(default) save												// Save sts option "default"
*stop																	// Stop dofile, close log, send message to saved sts option
*stop, sts(overwrite)													// Stop dofile, close log, do not send message to saved sts option
*stop, sts(default) message(Custom message) logfile(named)				// Stop dofile "named", display "Custom Message" and send "Custom Message" to sts url "Default" (note that default corresponds to a url because it was saved through sts itself)

*cap program drop stop stop_saveoption
program define stop
	version 8.0
	syntax [, sts(string) Message(string) Logfile(string) SAVEoptions]
	
	* Normal operation
	if `"`saveoptions'"' == "" {
		** Message
										local messageDefined "Dofile ran until specified stopping point."	// 3. Default message
		if "${stop_message}" != "" 		local messageDefined `"${stop_message}"'							// 2. Saved message
		if `"`message'"' != "" 			local messageDefined `"`message'"'									// 1. Specified message
		if `"`message'"' == "overwrite" local messageDefined "Dofile ran until specified stopping point."	// 0. Default message if user wants to overwrite saved message
		di as text _col(4) `"`messageDefined'"' _newline
		
		** Logfile
										local logfileDefined "_all"				// 3. Close all logfiles
		if "${stop_logfile}" != "" 		local logfileDefined "${stop_logfile}"	// 2. Close saved logfile
		if "`logfile'" != "" 			local logfileDefined "`logfile'"		// 1. Close specified logfile
		if "`logfile'" == "overwrite" 	local logfileDefined "_all" 			// 0. Close all logfiles if user wants to overwrite saved logfile
		
		cap noisily log close `logfileDefined'
		
		** Sendtoslack
										local stsDefined ""					// 3. Default is empty
		if "${stop_sts}" != "" 			local stsDefined `"${stop_sts}"'	// 2. Saved sts url
		if `"`sts'"' != "" 				local stsDefined `"`sts'"'			// 1. Specified sts url
		if `"`sts'"' == "overwrite" 	local stsDefined ""					// 0. Empty if user wants to overwrite saved sts url
			
		if "`stsDefined'" != "" {
			* Verify that sendtoslack is installed
			cap which sendtoslack
			if _rc != 0 {
				di _col(4) as error "sendtoslack not installed. Use code below to install."
				di _col(8) as result "ssc install sendtoslack"
				di _col(4) as text "Skipping sending of message."
			}

			* Send message
			if _rc == 0 sendtoslack, url(`stsDefined') message(`"`messageDefined'"') col(4)
		}
		
		** Report
		local mEff `"message(`messageDefined')"'
		if `"`messageDefined'"' == "Dofile ran until specified stopping point." local mEff ""
		
		local logfileEff "logfile(`logfileDefined')"
		if "`logfileDefined'" == "_all" local logfileEff ""
		
		local stsEff "sts(`stsDefined')"
		if "`stsDefined'" == "" local stsEff ""
		
		di _col(4) as text "Effective command executed: " as result `"stop, `stsEff' `mEff' `logfileEff'"'
		
		** Stop
		error 1
	}
	
	* Option saving (to profile.do)
	if `"`saveoptions'"' != "" {
		if `"`sts'"' != "" 		stop_saveoption, name(sts) 		value(`"`sts'"')
		if `"`message'"' != "" 	stop_saveoption, name(message) 	value(`"`message'"')
		if `"`logfile'"' != "" 	stop_saveoption, name(logfile) 	value(`"`logfile'"')
	}
end

program define stop_saveoption
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
	file write `profileDofile' _newline `"global stop_`name' `"`value'"'"'
	file close `profileDofile'
	
	** Define it now too, as profile.do changes only take place once it has ran
	global stop_`name' `"`value'"'

	* Report back to user
	di as text "Added a default " as result "`name'" as text " to " as result "`profileDofilePath'"
	di as text "On this PC, " as result `"`name'(`value')"' as text " will now be used even if no " as result "`name'" as text " option was specified for the stop command."
	di as text "In other words, you can now type " as result "stop" as text " and it will execute " as result `"stop, `name'(`value')"' as text " (+ any other saved options)." _newline
end
