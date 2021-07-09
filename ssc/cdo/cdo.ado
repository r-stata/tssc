*! Version 2.1.2 22may2020
* Contact jesse.wursten@kuleuven.be for bug reports/inquiries.

* Changelog
** 16nov17, 1.1.1: Added timing functionality
** 16nov17, 1.1.2: Added logging functionality
** 16nov17, 1.1.3: Now runs copy of dofile, so you can edit while it is running
** 01dec17, 1.1.4: Bug fixes, improved logging handling and (program) execution
** 01dec17, 1.2.0: URL saving introduced, as well as a "run" option
** 28nov18, 2.0.0: General option saving introduced, reporting cleaned up, saves error code in r() for programmers
** 07dec18, 2.1.0: Crucial bug fix (no longer runs all dofiles as if you have version 8.0

** cdo stands for capture do
cap program drop cdo
cap program drop cdo_Saveurl
cap program drop parse_log_options

program define cdo, sclass
    * Syntax
	version 8.0
	syntax anything(name=dofileName), [Run Arguments(string) Url(string) Program(string) Log(string) nocopy SAVEoptions]
	local saveableOptions "run arguments url program log copy"
	
	noisily di _newline as result "cdo"
	
	* Normal operation
	if "`saveoptions'" == "" {
		** Parse saved options
		foreach option of local saveableOptions {
															local `option'Defined ""				// 3. Default is empty
			if "${cdo_`option'}" != "" 						local `option'Defined `"${cdo_`option'}"'	// 2. Saved option
			if `"``option''"' != "" 						local `option'Defined `"``option''"'			// 1. Option as specified
			if inlist(`"``option''"', "overwrite", "no") 	local `option'Defined ""						// 0. Empty if user wants to overwrite saved option
		}
		
		** Do or Run?
		local execute "do"
		if "`runDefined'" == "run" local execute "run"
		
		** Display command that will be executed
		noisily di _skip(3) as text "Command including optional saved options:" _continue
		noisily di _col(50) as result `"cdo `dofileName', arguments(`argumentsDefined') url(`urlDefined') program(`programDefined') log(`logDefined') `copyDefined'"'
		noisily di _skip(3) as text "This corresponds to following `execute'-command:" _continue
		noisily di _col(50) as result `"`execute' `dofileName' `argumentsDefined'"'
		
		** Parse logging options
		if "`logDefined'" != "" {
			* Standard options
			parse_log_options `logDefined'
			local cdo_log_filename "`s(cdo_log_filename)'"
			local cdo_log_options "`s(cdo_log_options)'"
			local cdo_log_date "`s(cdo_log_date)'"
			local cdo_log_time "`s(cdo_log_time)'"
			local cdo_log_forcemsg "`s(cdo_log_forcemsg)'"
			
			* By default we skip the logging message
			if "`cdo_log_forcemsg'" != "forcemsg" 	local cdo_log_options "`cdo_log_options' nomsg"
			else 									local cdo_log_options = subinstr("`cdo_log_options'", "forcemsg", "", .)
			
			* Users can add data and or time
			local cdo_date = subinstr("`c(current_date)'", " ", "", .)
			local cdo_time = subinstr("`c(current_time)'", ":", "", .)

			if "`cdo_log_date'" == "date" local cdo_log_filename "`cdo_log_filename'_`cdo_date'"
			if "`cdo_log_time'" == "time" local cdo_log_filename "`cdo_log_filename'_`cdo_time'"
		}
		
		* Notify user program has started
		if "`urlDefined'" != "" sendtoslack, url("`urlDefined'") message("Starting dofile `macval(dofileName)'") col(4)
		if "`programDefined'" != "" di _skip(3) as text "On error or completion, will initiate program: " as result "`programDefined'"
		
		* Start timing and/or logging
		local cdo_start = "`c(current_date)' `c(current_time)'"
		if "`logDefined'" != "" {
			qui log using "`cdo_log_filename'", `cdo_log_options' name(cdo_log)
			local cdo_log_filename "`r(filename)'"
		}
		
		* Main code
		** Copy dofile so main open remains saveable (else you get sharing errors)
		version `c(stata_version)'
		tempfile dofileCopy
		if "`copyDefined'" != "nocopy" {
			 copy `macval(dofileName)' `dofileCopy'
			 cap noisily `execute' `dofileCopy'	`argumentsDefined'						// This is where the (copied) dofile is actually executed
		}
		else {
			noisily di as text _skip(3) "Not copying dofile, executing original file instead."
			cap noisily `execute' `macval(dofileName)'	`argumentsDefined'						// This is where the dofile is actually executed
		}
		version 8.0
			
		* Stop timing and/or logging
		local cdo_stop = "`c(current_date)' `c(current_time)'"
		if "`logDefined'" != "" {
			log close cdo_log
			di as result `"Saved log as `cdo_log_filename'"'
		}
		noisily di ""
		sreturn local returnCode = _rc

		* Parse time elapsed
		local cdo_time_elapsed = (tc(`cdo_stop') - tc(`cdo_start'))/1000
		local cdo_hours_elapsed = floor(`cdo_time_elapsed'/3600)
		local cdo_minutes_elapsed = floor(mod(`cdo_time_elapsed', 3600)/60)
		local cdo_seconds_elapsed = floor(mod(`cdo_time_elapsed', 60))
		
		* If an error occurred, execute program or send slack message
		if _rc != 0 {
			local rc = _rc
			noisily di _skip(3) as text "Execution: " as result "failed (more info: search r(`rc'), local)"
			if "`urlDefined'" != "" sendtoslack, url("`urlDefined'") message("Error `rc' has occurred in dofile `dofileName'") col(4)
			`programDefined'		// Will run program if it was specified
		}
		
		* Notify user program successfully completed
		else {
			noisily di _skip(3) as text "Execution: " as result "success"
			if "`urlDefined'" != "" sendtoslack, url("`urlDefined'") message("Successfully completed dofile `dofileName' `argumentsDefined'. Execution took `cdo_hours_elapsed' hours, `cdo_minutes_elapsed' minutes and `cdo_seconds_elapsed' seconds.") col(4)
			`programDefined'		// Will run program if it was specified
		}
	}
	
	* Save Options
	if "`saveoptions'" != "" {
		foreach option of local saveableOptions {
			if `"``option''"' != "" saveoptions, name(`option') value(`"``option''"') programname(cdo)	// `"``option''"' because we are looking for the contents of the local whose name is `option'
		}
		noisily di _skip(3) "Rerun cdo command without saveoptions (and without the options you saved) to actually run the specified dofile."
	}
end

** parse_log_options
program define parse_log_options, sclass
	syntax anything(name=cdo_log_filename)[, append replace text smcl forcemsg date time]
	sreturn local cdo_log_filename `cdo_log_filename'
	sreturn local cdo_log_options "`append' `replace' `text' `smcl'"
	sreturn local cdo_log_forcemsg "`forcemsg'"
	sreturn local cdo_log_date "`date'"
	sreturn local cdo_log_time "`time'"
end

/* Save Options */
* 1. Verify existence of profile.do (else create it)
* 2. Save options
* 3. Report that options were saved

program define saveoptions
	syntax, name(string) value(string) programname(string)

	* Determine whether profile.do exists
	cap findfile profile.do

	** If profile.do does not exist yet
	** Create profile.do (asking permission)
	if _rc == 601 {
		di _skip(3) "Profile.do does not exist yet."
		di _skip(3) "Do you want to allow this program to create one for you? y: yes, n: no" _newline "(enter below)" _request(_createPermission)
		
		if "`createPermission'" == "y" {
			di _skip(3) "Creating profile.do as `c(sysdir_oldplace)'profile.do"
			tempname createdProfileDo
			
			file open `createdProfileDo' using `"`c(sysdir_oldplace)'profile.do"', write
			file close `createdProfileDo'
		}
		
		if "`createPermission'" != "y" {
			di _skip(3) "User did not give permission to create profile.do, aborting program."
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
			di _skip(3) as error  "Global was already defined in profile.do"
			di _skip(3) as result "The program will add the new definition at the bottom."
			di _skip(3) "You might want to open profile.do and remove the old entry."
			di _skip(3) "This is not required, but prevents clogging your profile.do."
			di _skip(3) "To do so, type: " as txt "doed `profileDofilePath'" _newline
			
			local keepGoing = 0
		}
		
		file read `profileDofile' line
		if r(eof) == 1 local keepGoing = 0
	}
	file close `profileDofile'

	** Write in the global
	file open `profileDofile' using "`profileDofilePath'", write text append
	file write `profileDofile' _newline `"global `programname'_`name' `"`value'"'"'
	file close `profileDofile'
	
	** Define it now too, as profile.do changes only take place once it has ran
	global `programname'_`name' `"`value'"'

	* Report back to user
	di _skip(3) as text "Added a default " as result "`name'" as text " to " as result "`profileDofilePath'"
	di _skip(3) as text "On this PC, " as result `"`name'(`value')"' as text " will now be used even if no " as result "`name'" as text " option was specified for the `programname' command."
	di _skip(3) as text "In other words, you can now type " as result "`programname'" as text " and it will execute " as result `"`programname', `name'(`value')"' as text " (+ any other saved options)." _newline
end