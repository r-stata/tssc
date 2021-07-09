*! version 2.1.2
*! Christoph Thewes - thewes@mailbox.org - 25.05.2020

* 1.0.0: 10.05.2011: Initial release 
* 2.0.0: 09.11.2012: added suport for different versions and formats of QoG
* 2.1.0: 05.08.2017: added support for new versions/formats + new filenaming with date-suffix
* 2.1.1: 31.08.2017: fixed QoG-filenaming for EQI-data
* 2.1.2: 25.05.2020: fixed http > https

program qoguse

version 11.0
	
	syntax [anything] [if] [in], Version(string) Format(string) [Years(numlist) clear]

	local q_source "https://www.qogdata.pol.gu.se/data/"

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



	if "`format'"=="cs" | "`version'"=="exp" {
		if "`years'" != "" {
			di as err "Option years() is not allowed and will be ignored."
			local years ""
		}
	}

	if "`version'"=="eqi" & "`format'"=="agg" {
		if "`years'" != "" {
			di as err "Option years() is not allowed and will be ignored."
			local years ""
		}
	}


	// LOAD DATA
	// ---------

	*// Solution proposed by William Lisowski
	preserve
		tempfile gnxl
		copy https://www.qogdata.pol.gu.se/data/ `gnxl'
		qui infix str line 1-500 using `gnxl', clear
		qui generate file = regexs(1) if regexm(line,">(qog_`version'_`format'_.*dta)<")
		
		qui keep if !missing(file)
		local q_filename = file[1]
	restore

	di as inp "Downloading file..."
	use `anything' `if' `in' using `q_source'/`q_filename', `clear'
	di as inp "Download complete!"



	// KEEP ONLY SPECIFIED YEARS
	// -------------------------
	if "`years'"!="" {	
		tempvar touse
		local i 1
		foreach num of numlist `years'  {
			if `i'== 1 local exp year == `num'
			else local exp `exp' | year == `num'
			local i = `i' + 1
		}
		gen byte `touse' = `exp'
		keep if `touse'
	}
	

	// Check if years() deleted all observationsfor EQI/IND
	if "`version'"=="eqi" & "`format'"=="ind" {
		if "`years'" != "" & _N == 0 {
			di as err "Note: EQI individual data is only available for 2010 & 2013."
			di as err "Option years() deleted all observations."
			local years ""
		}
	}


end
exit

