*! 2.0 VERSION OF GEOCODER
program geocode
	version 8.2
	syntax, [address(string) city(string) state(string) zip(string) fulladdr(string) yahoo both dist distm]
		

if ("`dist'"=="dist" & "`both'"=="") {
        di in red "error: must specify option 'both' in order to use distance feature"
	exit
	}

if ("`distm'"=="distm" & "`both'"=="") {
        di in red "error: must specify option 'both' in order to use distance feature"
	exit
	}

if ("`yahoo'"=="yahoo" & "`both'"=="both") {
	di in red "error: cannot select option both and option yahoo"
	exit
	}

	
quietly {
		tempfile temp_all_files txtfile ytemp_all_files
		tempvar blank work mergetest ymergetest
		g `blank' = ""
		
		if "`address'" == "" local address `blank'
		if "`city'" == ""    local city    `blank'
		if "`state'" == ""   local state   `blank'
		if "`zip'" == ""     local zip     `blank'
			
		if "`fulladdr'" == "" {	
			g `work' = `address' + ", " + `city' + ", " + `state' + " " + `zip'
		}
		else g `work' = `fulladdr'
		drop `blank' 			
		
  	g long geoid = _n		

		replace `work' = " " + `work'
		replace `work' = upper(`work')
		replace `work' = subinstr(`work',"&","%26",.)
		replace `work' = subinstr(`work',"#","",.)
		replace `work' = subinstr(`work'," 01ST"," 1ST",.)
		replace `work' = subinstr(`work'," 02ND"," 2ND",.)
		replace `work' = subinstr(`work'," 03RD"," 3RD",.)
		replace `work' = subinstr(`work'," 04TH"," 4TH",.)
		replace `work' = subinstr(`work'," 05TH"," 5TH",.)
		replace `work' = subinstr(`work'," 06TH"," 6TH",.)
		replace `work' = subinstr(`work'," 07TH"," 7TH",.)
		replace `work' = subinstr(`work'," 08TH"," 8TH",.)
		replace `work' = subinstr(`work'," 09TH"," 9TH",.)
		replace `work' = trim(`work')
		replace `work' = subinstr(`work'," ","+",.)
		replace `work' = subinstr(`work',`"""'," ",.)
  	replace `work' = itrim(trim(`work'))
		replace `work' = subinstr(`work'," ","+",.)


	if "`yahoo'" == "" {		

		local cnt = _N 
		forval i = 1/`cnt' { 
			tempfile dtafile`i'
			preserve
			local addr = `work'[`i'] 
			
			if "`addr'" != "" {
				noisily di as text "Google Geocoding `i' of `cnt'" 
				*capture: copy "http://maps.google.com/maps/geo?q=`addr'&output=csv" "txtfile`i'.txt", replace      /debugging code
				*noisily di as text "http://maps.google.com/maps/geo?q=`addr'&output=csv" "txtfile`i'.txt"			/debugging code
				capture: copy "http://maps.google.com/maps/geo?q=`addr'&output=csv" `txtfile', replace

				while _rc == 2 | _rc==612 {
					noi: di "Connection error, retrying observation #"`i'
					*capture: copy "http://maps.google.com/maps/geo?q=`addr'&output=csv" "txtfile`i'.txt", replace			/debugging code
					capture: copy "http://maps.google.com/maps/geo?q=`addr'&output=csv" `txtfile', replace
				}
				
			*capture: insheet geocode geoscore latitude longitude using "txtfile`i'.txt", clear comma			/debugging code
			capture: insheet geocode geoscore latitude longitude using `txtfile', clear comma					

			
			*IN CASE TEMPFILE DOESNT EXIST
			while _rc==601 {
			*capture: insheet geocode geoscore latitude longitude using "txtfile`i'.txt", clear comma			/debugging code
			capture: insheet geocode geoscore latitude longitude using `txtfile', clear comma

			}
			
			local err = 0
			
			*RETRYING 10 TIMES IF GEOCODING ERROR IS 620
			while geocode == 620 & `err'<=10 {
				noi: di "in RETRY loop"
				*capture: copy "http://maps.google.com/maps/geo?q=`addr'&output=csv" "txtfile`i'.txt", replace			/debugging code
				capture: copy "http://maps.google.com/maps/geo?q=`addr'&output=csv" `txtfile', replace
				*capture: insheet geocode geoscore latitude longitude using "txtfile`i'.txt", clear comma			/debugging code
				capture: insheet geocode geoscore latitude longitude using `txtfile', clear comma
				local ++err
			}
			}
			if "`addr'" == "" {
				noisily di as text "Google Geocoding `i' of `cnt': blank address" 
				clear
				set obs 1
				g geocode = 601 
				g geoscore = 0
				}
				
			g long geoid = `i'
			sort geoid
			save `dtafile`i'', replace
			restore
		}

		preserve 

		use `dtafile1', clear
		forval i = 2/`cnt' {
			append using `dtafile`i''
		}
		
		sort geoid
		save `temp_all_files', replace
		

	}
	
	
	
	
	if ("`yahoo'" == "yahoo" | "`both'" == "both") {		
	di "Yahoo select"
		capture: restore

		local cnt = _N 
		forval i = 1/`cnt' { 
			tempfile ydtafile`i'
			preserve
			local addr = `work'[`i'] 
			if "`addr'" != "" {
			noisily: di as text "Yahoo Geocoding `i' of `cnt'"
			
			*capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C" "txtfile`i'.txt", replace     /debugging code
			capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C"  `txtfile', replace     

			*noisily : di as text "http://where.yahooapis.com/geocode?q=`addr'&flags=C" "txtfile`i'.txt"


			while _rc == 2 | _rc==612 {
				noi: di "Connection error, retrying observation #"`i'
				*capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C" "txtfile`i'.txt", replace     /debugging code
				capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C"  `txtfile', replace     

				*sleep 500
			}
				
			*capture: insheet using "txtfile`i'.txt", clear delimiter("<")			/debugging code
			capture: insheet using `txtfile', clear delimiter("<")
			
			
			*IF THE FILE DOES NOT SHOW UP THE ANALYSIS IS RERUN
			while _rc==601 {
				noi: di "Connection error, retrying observation #"`i'
				*capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C" "txtfile`i'.txt", replace     /debugging code
				capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C"  `txtfile', replace     
				*insheet using "txtfile`i'.txt", clear delimiter("<")				/debugging code
				insheet using `txtfile', clear delimiter("<")
				}
			
			keep in 2
			
			*CHECKING FOR AN ERROR CODE AND RERUNNING IF FOUND
		
			local errorcheck = v3 in 1
			while "`errorcheck'" != "Error>0" {
				noi: di "Connection error, retrying observation #"`i'				
				*capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C" "txtfile`i'.txt", replace				/debugging code
				*capture: insheet using "txtfile`i'.txt", clear delimiter("<")
				capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C" `txtfile', replace
				capture: insheet using `txtfile', clear delimiter("<")
				
				while _rc==601 {
				*capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C" "txtfile`i'.txt", replace				/debugging code
				*capture: insheet using "txtfile`i'.txt", clear delimiter("<")
				capture: copy "http://where.yahooapis.com/geocode?q=`addr'&flags=C" `txtfile', replace
				capture: insheet using `txtfile', clear delimiter("<")
					}
				keep in 2
				local errorcheck = v3 in 1
			}
			
			*CHECKING FOR "FOUND" RESPONSE GREATER THAN ZERO
			local found = v11 in 1
			
			if "`found'" != "Found>0" {
			
			keep v3 v14 v16 v18
			
			rename v3 ygeocode
			replace ygeocode = subinstr(ygeocode,"Error>","",.)
			rename v14 ygeoscore
			replace ygeoscore = subinstr(ygeoscore,"quality>","",.)
			rename v16 ylat
			replace ylat = subinstr(ylat,"latitude>","",.)
			rename v18 ylon
			replace ylon = subinstr(ylon,"longitude>","",.)
			destring *, replace
			}
			}
			
			if "`addr'" == "" | "`found'" == "Found>0" {
				noisily: di as text "Yahoo Geocoding `i' of `cnt': blank address"
				clear
				set obs 1
				g ygeocode = 601
				g ygeoscore = 0
				}
				
			g long geoid = `i'
			sort geoid
			save `ydtafile`i'', replace
			restore
			
		}
		
		preserve

		use `ydtafile1', clear
		forval i = 2/`cnt' {
			append using `ydtafile`i''
		}
		
		sort geoid
		save `ytemp_all_files', replace


	}

	restore
	sort geoid
	
	if "`yahoo'" == "yahoo" {
		merge geoid using `ytemp_all_files', _merge(`ymergetest')		
		drop geoid `ymergetest' 
	}

	if "`both'"=="both" {

		merge geoid using `ytemp_all_files', _merge(`ymergetest')		
		drop `ymergetest' 
		sort geoid
		merge geoid using `temp_all_files', _merge(`mergetest')		
		drop geoid `mergetest' 
	}

	if  "`both'"=="" & "`yahoo'" == "" {
		
		sort geoid
		merge geoid using `temp_all_files', _merge(`mergetest')		
		drop geoid `mergetest' 

	}

	if ("`dist'"=="dist" | "`distm'"=="distm") {
		tempvar L
		qui g double `L' =(ylon-longitude)*_pi/180 
		qui replace `L'=(ylon-longitude-360)*_pi/180 if `L'<. & `L'>_pi
		qui replace `L'=(ylon-longitude+360)*_pi/180 if `L'<-_pi
		
		g double dist =1000*6367.44*2*atan2(sqrt((sin((latitude - ylat)*_pi/360))^2 + cos(ylat*_pi/180) * cos(latitude*_pi/180) * (sin(`L'/2))^2) ,sqrt(1-(( sin((latitude - ylat)*_pi/360))^2 + cos(ylat*_pi/180) * cos(latitude*_pi/180) * (sin(`L'/2))^2))) / 0.3048^("`distm'"=="")
		
	
		}


}
	
end
		

