*! version 1.0.0 4apr2017
capture program drop geocode_ip
program define geocode_ip
// Notes
//	- We require CLEAR because this destroys the data
//	- Since the program might fail at any time, we want to keep track of progress
//	  so we don't do preserve
//	- Also, only search an IP once (avoid duplicates)

	version 13 // could backport to 12 by using -insheet-

	syntax varname(string) [if] [in], CLEAR [SLEEP(real 0.4)]
	marksample touse, strok
	qui keep if `touse'
	contract `varlist'
	qui keep `varlist'
	loc sleep = `sleep' * 1000 // in msecs; default is 0.4s = 60/150 (max allowed)

	tempfile data
	loc first 1
	loc N = c(N)
	di as text "(parsing `N' addresses with http://freegeoip.net)"
	loc headers `varlist' country_code country_name region_code region_name city zip_code time_zone latitude longitude metro_code

	forval i = 1/`N' {
		loc ip = `varlist'[1]
		di as text "   `i'/`N' | `ip'"
		
		preserve
		qui import delimited `headers' using "http://freegeoip.net/csv/`ip'", clear varnames(nonames) stringcols(_all)
		qui save "`data'", replace
		restore

		// "Move" the obs to the end
		qui drop in 1
		qui append using "`data'"
		if (`i'<`N') sleep `sleep'
	}

	qui compress

end
