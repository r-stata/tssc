* Tool to download data through the Census API
*! Version 1.0.0 01mar19
* Contact jesse.wursten@kuleuven.be for bug reports/inquiries.


* Changelog
** 01mar19: Minor fixes and help file written.
** 28feb19: The command is born
cap program drop censusapi censusapi_range censusapi_saveoption


* Define Programs
program define censusapi
	version 12
	syntax, [url(string)] [DESTination(string)] [dataset(string) VARiables(string) predicate(string)] [key(string) savekey]
	di as result "Importing variables through Census API."
	
	* Parse destination
	if strpos("`destination'", ".txt") == 0 & "`destination'" != "" {
		di as error _col(4) "Destination should be suffixed with .txt or problem might not run to completion."
	}
	if "`destination'" == "" {
		tempfile a
		local destination `a'
	}
		
	
	* Parse key
									local keyDefined ""					// 3. Default is empty
	if "${censusapi_key}" != "" 	local keyDefined `"${censusapi_key}"'	// 2. Saved key
	if `"`key'"' != "" 				local keyDefined `"`key'"'			// 1. Specified key
	if `"`key'"' == "overwrite" 	local keyDefined ""					// 0. Empty if user wants to overwrite key
	local keyText "&key=`keyDefined'"
	if "`keyDefined'" == "${censusapi_key}" & "`keyDefined'" != "`key'" di as text _col(3) "Using stored key (`keyDefined')"

	
	* Raw url way
	if "`url'" != "" {
		!curl "`url'`keyText'" -o "`destination'"
	}
	
	* Divided way
	else {
		** Parse variables
		*** Split variables
		tokenize `variables'
		
		*** Loop over variables
		local variablesToUse ""
		local variablesToUse_space ""
		di as text _col(3) "Parsing variable list"
		while "`1'"!= "" {
			* Parse ranges
			if strpos("`1'", "-") > 0 {
				censusapi_range `1'
				local 1 = s(expandedRange)
			}
			
			* Store variables
			di as result _col(6) "`1'"
			local variablesToUse = "`variablesToUse',`1'"
			macro shift
		}
		local variablesToUse = subinstr("`variablesToUse'", ",", "", 1)
		local variablesToUse_space = subinstr("`variablesToUse'", ",", " ", .)
		local variableCount = wordcount("`variablesToUse_space'")
		
		if `variableCount' > 50 {
			di as text _col(3) "Downloading all sets"
			** Split into sets
			local setsRequired = ceil(`variableCount'/50)
			forvalues set = 1/`setsRequired' {
				forvalues j = 1/50 {
					local i = `j' + 50*(`set'-1)
					if `i' > `variableCount' continue							// Last set does not necessarily contain 50 entries
					local word : word `i' of `variablesToUse_space'
					local set`set' "`set`set'',`word'"
				}
				local set`set' = subinstr("`set`set''", ",", "", 1)
			}
			
			** Download all sets
			forvalues set = 1/`setsRequired' {
				di as result _col(6) "set `set'"
				tempfile csv_`set'
				!curl "`dataset'?get=`set`set''&`predicate'`keyText'" -o "`csv_`set''"
			}
			
			** Combine all sets
			qui forvalues set = 1/`setsRequired' {
				tempfile stata_`set'
				tempfile b c
				filefilter "`csv_`set''" `b', replace from(",\n") to("\n") 
				filefilter `b' `c', replace from("[") to("") 
				filefilter `c' "`csv_`set''", replace from("]") to("") 
				import delimited "`csv_`set''", clear
				
				gen id = _n
				save "`stata_`set''"
			}
			
			*di as text _col(3) "Opening file"
			qui use "`stata_1'", clear
			qui forvalues set = 2/`setsRequired' {
				merge 1:1 id using "`stata_`set''", nogen
			}
			
			** Save 
			drop id
			qui export delimited "`destination'", replace
		}
		
		else {
			** Execute curl
			!curl "`dataset'?get=`variablesToUse'&`predicate'`keyText'" -o "`destination'"
		}
	}
		
	** Parse csv file
	tempfile b c
	qui filefilter "`destination'" `b', replace from(",\n") to("\n") 
	qui filefilter `b' `c', replace from("[") to("") 
	qui filefilter `c' "`destination'", replace from("]") to("") 
	
	** Open file
	di as text _col(3) "Opening file"
	qui import delimited "`destination'", clear
	
	* Option saving (to profile.do)
	if `"`savekey'"' != "" {
		if `"`key'"' != "" 		censusapi_saveoption, name(key) 		value(`"`key'"')
	}
end

program define censusapi_range, sclass 
	* Identify parts of range
	if regexm("`0'", "([a-zA-zZ]+[0]*)([0-9]+)[-]([a-zA-zZ]+[0]*)([0-9]+)") {
		local string1 = regexs(1)
		local number1 = regexs(2)
		local string2 = regexs(3)
		local number2 = regexs(4)
	}
	
	if "`string1'" != "`string2'" di as error "Warning: deduced prefixes `string1' and `string2' do not match in `0'"
	
	* Generate variable list
	numlist "`number1'(1)`number2'"
	local varlist = subinstr("`r(numlist)'", " ", ",`string1'", .)
	local varlist = "`string1'`varlist'"
	sreturn local expandedRange "`varlist'"
end

program define censusapi_saveoption
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
		if strpos(`"`macval(line)'"', "censusapi_`name'") > 0 {
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
	file write `profileDofile' _newline `"global censusapi_`name' `"`value'"'"'
	file close `profileDofile'
	
	** Define it now too, as profile.do changes only take place once it has ran
	global censusapi_`name' `"`value'"'

	* Report back to user
	di as text "Added a default " as result "`name'" as text " to " as result "`profileDofilePath'"
	di as text "On this PC, " as result `"`name'(`value')"' as text " will now be used even if no " as result "`name'" as text " option was specified for the censusapi command."
	di as text "In other words, you can now type " as result "censusapi, <options>" as text " and it will execute " as result `"censusapi, <options> `name'(`value')."' _newline
end
