*! version 2.1.2
*! Christoph Thewes - thewes@mailbox.org - 25.05.2020

* 1.0.0: 10.05.2011: Initial release 
* 1.1.0: 16.11.2011: added "from()"-option, varname-bugfix (year)
* 2.0.0: 09.11.2012: added suport for different versions and formats of QoG
* 2.1.0: 05.08.2017: added support for new versions/formats, new filenaming with date-suffix, modified from()-option > using
* 2.1.1: 31.08.2017: fixed QoG-filenaming for EQI-data
* 2.1.2: 25.05.2020: fixed http > https

program qogmerge

	version 11.0

	syntax anything [using/], Version(string) Format(string) [keep(string) * ]

	local q_source "https://www.qogdata.pol.gu.se/data/"

	local temp1: word 1 of `anything'		//countryvar
	local temp2: word 2 of `anything'		//timevar



	// check format
	// ------------

	if "`format'" == "ind" {
		di as err "-Individual Expert Survey- can`t be merged." _newline ///
		"It contains personal infortmation: Web survey by country experts." _newline ///
		"Variables do not uniquely identify observations in the using data."
		exit 459
	}


	if "`format'"=="cs" | "`version'"=="exp" local base c
	if "`version'"=="eqi" & "`format'"=="agg" local base c
	if inlist("`format'","ts","long","wide1","wide2") local base cy
	
	if "`base'"=="cy" & "`temp2'" == "" {
		di as err "no TIME-variable spcified"
		exit 
	}

	if "`base'"=="c" & "`temp2'" != "" {
		di as err _col(5) "Note: Format" as inp " cs " as err "and" as inp " ctry " as err "can not be merged with TIME variable."
		di as err _col(5) "-" as inp "`temp2'" as err "- will be ignored"
	}
	

	// CHECK FOR WRONG SPECIFIED OPTIONS
	// ---------------------------------
	
	if "`version'"=="bas" | "`version'"=="std" | "`version'"=="oecd" {
		if "`format'"!="cs" & "`format'"!="ts" {
			di as err "You have to specify" as inp " format(cs) " as err "or" as inp " format(ts)" as err " for BASIC, STANDARD and OECD dataset."
			exit
		}
	}

	if "`version'"=="eureg" {
		if "`format'"!="long" & "`format'"!="wide1" & "`format'"!="wide2" {
			di as err "You have to specify" as inp " format(long)" as err "," as inp " format(wide1)" as err " or" as inp " format(wide2)" as err " for EU REGIONAL dataset."
			exit
		}
	}

	if "`version'"=="exp" | "`version'"=="eqi" {
		if "`format'"!="ind" & "`format'"!="agg" {
			di as err "You have to specify" as inp " format(ind) " as err "or" as inp " format(agg)" as err " for EXPERT SURVEY  or EQI dataset."
			exit
		}
	}
	


	// check if time or country is invariable
	// --------------------------------------
	capture confirm variable `temp1'
	if _rc {						// >>> temp1 is not a variable
		tempvar countryvar
		capture confirm integer number `temp1'
		if !_rc {					// temp1 is integer
			gen `countryvar' = `temp1'
			local cformat num
		}
		if _rc {					// temp1 is string
			gen `countryvar' = "`temp1'"
			local cformat name
		}
	}
	
	else {							// >>> temp1 is a variable
		capture confirm string variable `temp1'
		if !_rc {					// temp1 is string
			local countryvar "`temp1'"
			local cformat name
		}
		if _rc {					// temp1 is integer
			local countryvar `temp1'
			local cformat num
		}
		capture assert !mi(`countryvar')
		if _rc== 9 {
			di as smcl as res _col(5) "Note: COUNTRY variable contains missings"
		}

	}
		
	
	if "`base'" == "cy" {
		capture confirm variable `temp2'
		if _rc {						// >>> temp2 is not a variable
			tempvar timevar
			gen `timevar' = `temp2'
		}
		
		else {							// >>> temp2 is a variable
			local timevar `temp2'
			confirm numeric variable `timevar'
		
			capture assert !mi(`timevar')
			if _rc== 9 {
				di as smcl as res _col(5) "Note: TIME variable contains missings"
			}
		}
	
	// general checks
	// --------------

		capture assert mod(`timevar',1)==0 | mi(`timevar')
		if _rc!= 0 {
			di as error "TIME variable contains noninteger values"
			exit 9
		}
		
		
		capture assert inrange(`timevar',1000,9999) | mi(`timevar')	
		if _rc!= 0 {
			di as error "TIME variable should be 4 digit"
			exit 9
		}
	}
		
	
	if "`keep'" == "" local keep "keep(1 3)"
	else local keep "keep(`keep')"


	// check if `using' is a file
	capture confirm file `using'
	if !_rc local from "`using'"
	
	if _rc {				// from here: only if `using' is NOT a file
		// check if `using' is a folder. Code by Dan Blanchette (confirmdir.ado)
		local cwd `"`c(pwd)'"'
		quietly capture cd `"`using'"'
		local confirmdir=_rc 
		quietly cd `"`cwd'"'
		*local confirmdir `"`confirmdir'"'
		if _rc != 0 {
			di as err "`using'"
			di as err "No such file or folder found."
			exit
		}

		preserve
			*// Solution proposed by William Lisowski
			tempfile gnxl
			copy https://www.qogdata.pol.gu.se/data/ `gnxl'
			qui infix str line 1-500 using `gnxl', clear
			qui generate file = regexs(1) if regexm(line,">(qog_`version'_`format'_.*dta)<")
			qui keep if !missing(file)
			local q_filename = file[1]
		restore

		if "`using'" == "" local from "`q_source'/`q_filename'"
		if "`using'" != "" local from "`using'/`q_filename'"
	}





	// generate
	
	if "`cformat'" == "name" {
		capture gen cname = `countryvar' 
		if _rc == 110 {
			display as error "cname already defined"
			exit 110
		}
		local var1 cname
	}
	
	
	if "`cformat'" == "num" {
		capture gen ccode = `countryvar' 
		if _rc == 110 {
			display as error "ccode already defined"
			exit 110
		}
		local var1 ccode
	}


	if "`base'" == "cy" {
		if "`timevar'" != "year" {
			capture confirm var year
			if _rc != 111 {					// = var "year" is in original data
				ren year qogtempyear
				gen int year = `timevar'
				local markyear "yes"
			}
			else {
				gen int year = `timevar'
				local markyear "no"
			}
		}	
		local var2 year
	}



	//  merge
	// =======

	if "`base'" == "cy" merge m:1 `var1' `var2' using `from', `keep' `options'
	if "`base'" == "c" merge m:1 `var1' using `from', `keep' `options'


	// undo country and year identifier renaming
	// -----------------------------------------

	if "`timevar'" != "year" & "`base'" == "cy" {
		if "`markyear'" == "yes" {
			drop `var1' `var2'
			ren qogtempyear year
		}
		else {
			drop `var1' `var2'
		}
	}
	
	else {
		drop `var1' 
	}

	

end
exit
