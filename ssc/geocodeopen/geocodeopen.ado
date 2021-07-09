*! 1.0.0 VERSION OF MAPQUEST GEOCODER
* This program uses Mapquest Open APIs and Open Street Maps instead of the now junky Google Maps APIs, which no longer support .csv output and have severe limits on number of queries.  It reuses some code from the original geocode.ado file written by Ozimek and Miles.
program geocodeopen
	version 11.2
	syntax [if] [in], [key(string) address(string) city(string) state(string) zip(string) fulladdr(string) replace]
	marksample touse
	
	local proceed = 1
	if "`replace'"=="replace" {
		foreach var in longitude latitude geo_type geo_quality geo_address geo_city geo_state geo_zip {
			capture: drop `var'
		}
	}
	else {
		foreach var in longitude latitude geo_type geo_quality geo_address geo_city geo_state geo_zip {
			capture confirm variable `var'
			if !_rc {
				dis in red "Error: `var' variable already exists"
				local proceed = 0
			}
		}
	}

	if `proceed' {
		quietly {
			tempfile temp_all_files
			tempvar blank work mergevar mergetest zipvar varsort
			gen `varsort'= _n
			gen `blank' = ""
	
			if "`address'" == "" local address `blank'
			if "`city'" == ""    local city    `blank'
			if "`state'" == ""   local state   `blank'
			if "`zip'" == ""     local zip  `blank'
		
			if "`fulladdr'" == "" {
				capture: confirm string variable `zip'
				if !_rc {
					gen `zipvar' = `zip'
				}
				else {
					tostring `zip', gen(`zipvar')
				}
				gen `work' = `address' + ", " + `city' + ", " + `state' + " " + `zipvar' if `touse'
			}
			else gen `work' = `fulladdr' if `touse'
			drop `blank' 			
	
			replace `work' = " " + `work' if `touse'
			replace `work' = upper(`work') if `touse'
			replace `work' = subinstr(`work',"&","%26",.) if `touse'
			replace `work' = subinstr(`work',"#","",.) if `touse'
			replace `work' = subinstr(`work'," 01ST"," 1ST",.) if `touse'
			replace `work' = subinstr(`work'," 02ND"," 2ND",.) if `touse'
			replace `work' = subinstr(`work'," 03RD"," 3RD",.) if `touse'
			replace `work' = subinstr(`work'," 04TH"," 4TH",.) if `touse'
			replace `work' = subinstr(`work'," 05TH"," 5TH",.) if `touse'
			replace `work' = subinstr(`work'," 06TH"," 6TH",.) if `touse'
			replace `work' = subinstr(`work'," 07TH"," 7TH",.) if `touse'
			replace `work' = subinstr(`work'," 08TH"," 8TH",.) if `touse'
			replace `work' = subinstr(`work'," 09TH"," 9TH",.) if `touse'
			replace `work' = trim(`work') if `touse'
			replace `work' = itrim(trim(`work')) if `touse'
			replace `work' = subinstr(`work'," ","+",.) if `touse'
			replace `work' = subinstr(`work',`"""'," ",.) if `touse'

			local cnt = _N
			local counter = 1
			sum `touse'
			local totalgeocode = r(sum)
			gen long `mergevar' = .
			forval i = 1/`cnt' { 
				if `work'[`i']!="" {
					tempfile txtfile`counter'
					local addr = `work'[`i']			
					noisily di as text "MapQuest Open Geocoding `counter' of `totalgeocode'" 
					capture: copy "http://open.mapquestapi.com/geocoding/v1/address?key=`key'&location=`addr'&callback=renderGeocode&outFormat=csv&maxResults=1" `txtfile`counter''
					while _rc == 2 | _rc==612 {
						noi: di "Connection error, retrying observation #"`counter'
						capture: copy "http://open.mapquestapi.com/geocoding/v1/address?key=`key'&location=`addr'&callback=renderGeocode&outFormat=csv&maxResults=1" `txtfile`counter'', replace
					}
					replace `mergevar' = `counter' in `i'
					local ++counter
				}
			}
			preserve
			local endval = `counter' - 1
			forval counter = 1/`endval' {
				tempfile dtafile`counter'
					capture: insheet country geo_state county geo_city geo_zip geo_address latitude longitude dragpoint linkid type geo_type geo_quality streetside dislat dislong using `txtfile`counter'', clear comma
				*IN CASE CSV TEMPFILE DOESN'T EXIST
				if _rc==601 {
					dis "Geocode CSV file " `counter' " missing"
				}
				else {
					keep latitude longitude geo_type geo_quality geo_address geo_city geo_state geo_zip
					foreach var of varlist geo_type geo_quality geo_address geo_city geo_state geo_zip {
						capture: confirm string variable `var'
						if _rc {
							tostring `var', replace
						}
					}
					gen long `mergevar' = `counter'
					sort `mergevar'
					save `dtafile`counter'', replace	
				}
			}	
			use `dtafile1', clear
			forval counter = 2/`endval' {
				append using `dtafile`counter''
			}
			sort `mergevar'
			save `temp_all_files', replace
			restore
			sort `mergevar'
			merge `mergevar' using `temp_all_files', _merge(`mergetest')
			sort `varsort'
		}
	}
	
	dis "Geocoding Courtesy of MapQuest."
	dis "Data generated are made available under the Open Database License:"
	dis "http://opendatacommons.org/licenses/odbl/1.0/"

end

