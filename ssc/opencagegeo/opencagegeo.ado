*! opencagegeo version 1.2.0 (22/02/2018)
*! Lars Zeigermannn
*  opencagegeo uses the OpenCage Geocoder API. It reuses some code segments of 
*  geocode written by Adam Ozimek and Daniel Miles. opencagegeo requires 
*  insheetjson and libjson written by Erik Lindsley.

* Version 1.1.0:        a bug affecting users of paid keys has been fixed and a
*							and the paidkey option was added
* Version 1.2.0:		opencagegeo no longer requires the paidkey option

program opencagegeo
        version 12.1
        syntax [in] [if],															///                                                                                                               
                        [															///
                        key(str)													///
                        NUMber(varname) STReet(varname str) POSTcode(varname)		///
                        city(varname str) county(varname str) state(varname str)	///
                        country(varname str) FULLaddress(varname str)				/// 
                        COORDinates(varname str) LATitude(varname)					///
                        LONgitude(varname) countrycode(str) LANGuage(str)			///
                        replace RESume PAIDkey										///
                ]
                
                
                *** Mark sample
                marksample touse, novarlist
                qui count if `touse' == 1
                local todo = `r(N)'
                
                *** Generate tempvar sorder
                tempvar sorder
                gen `sorder' = _n
                
                *** Check that _N > 0
                cap assert _N > 0
                        if _rc!= 0 {
                                di as err "No observations"
                                exit 2000
                        }
                
                
                *** Check for insheetjson and libsjson
				cap which insheetjson
				if _rc == 111 di as err "Insheetjson.ado not found, please ssc install insheetjson"
				cap which libjson.mlib
				if _rc == 111 di as err "Libjson.mlib not found, please ssc install libjson"
				qui if _rc == 111 assert 1 == 2
                
                
                *** Check that replace and resume are not combined
                if ("`resume'" != "") {
                        if ("`replace'" != "") {
                                di as err "Options replace and resume may not be combined"
                                exit 184
                        }
                        cap confirm variable g_quality
                        if _rc != 0 {
                                di as err "Variable g_quality not found, cannot resume geocoding"
                                exit 499
                        }
                        
                        * Reset local touse
                        qui count if `touse' == 1 & g_quality != .
                        local geocoded = `r(N)' + 1

                        
                        * Adjust touse if resume
                        qui replace `touse' = 0 if g_quality != .
                }
                else {
                        local geocoded = 1
                }

                if ("`replace'" != "") {
                        cap replace g_quality = . if `touse'
                }
                
                *** Check that touse is not zero for all observations
                qui sum `touse'
                if `r(mean)' == 0 {
                        di as err "Nothing to geocode"
                        exit 2000
                }
                
                        
                *** Generate language tempvar (if specified)
                local langvar = 0
                if ("`language'" != "") {
                cap confirm variable `language'
                        if _rc == 0 {
                                tempvar languageresponse
                                qui gen `languageresponse' = `language'
                                local langvar = 1
                        }
                }
                else {
                        local language = "en"
                }

                
                *** Generate countrycode tempvar (if specified
                local countrycodevar = 0
                if ("`countrycode'" != "") {
                        local iso_3166  AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA      /// 
                                                BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW   ///
                                                BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW   ///
                                                CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ   ///
                                                FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR   ///
                                                GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ   ///
                                                IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ   ///
                                                LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH   ///
                                                MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC   ///
                                                NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL   ///
                                                PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE   ///
                                                SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD   ///
                                                TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US   ///
                                                UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW
                                                
                
                        cap confirm variable `countrycode'
                                if _rc == 0 {
                                        tempvar countrycodequery
                                        qui gen `countrycodequery' = `countrycode'
                                        local countrycodevar = 1
                                        tempvar iso_check
                                        qui gen `iso_check' = 0
                                        foreach i of local iso_3166 {
                                                qui replace `iso_check' = 1 if upper(`countrycodequery') == "`i'"
                                        }
                                        cap assert `iso_check' == 1 if `countrycodequery' != ""
                                        
                                if _rc == 9 {
                                        qui levelsof `countrycodequery' if `iso_check' == 0, local(levels)
                                        di as err "Following country codes are invalid: "`r(levels)'""
                                        exit 9
                                }
                                }
                                else {
                                        local continue = 0
                                        foreach i of local iso_3166 {
                                                cap assert upper("`countrycode'") == "`i'"
                                                if _rc == 0{
                                                local continue = 1
                                                continue, break
                                                }
                                        }
                                        if (`continue' == 0) {
                                                di as err "Country code `countrycode' is not valid"
                                                exit 9
                                        }
                                }

                }

                
                *** Check that key was provided
                if ("`key'" == "") {
                        di as err "Opencagedata API key required: Sign up for a free key at www.opencagedata.com"
                        exit 198
                }

                
                *** Check that no options are combined inconsistently   
                if ("`fulladdress'" != "") {
                        cap assert "`coordinates'" == ""
                        if _rc != 0 {
                                di as err "Options fulladdress and coordinates may not be combined"
                                exit 184
                        }
                        
                        cap assert "`latitude'" == ""
                        if _rc != 0 {
                                di as err "Options fulladdress and latitude not be combined"
                                exit 184
                        }
                        
                        cap assert "`longitude'" == ""
                        if _rc != 0 {
                                di as err "Options fulladdress and longitude not be combined"
                                exit 184
                        }       
                        
                        local type fulladdress
                }
                
                if ("`coordinates'" != "") {
                        cap assert "`latitude'" == ""
                        if _rc != 0 {
                                di as err "Options coordinates and latitude may not be combined"
                                exit 184
                        }
                        
                        cap assert "`longitude'" == ""
                        if _rc != 0 {
                                di as err "Options coordinates and longitude may not be combined"
                                exit 184
                        }
                        
                        cap assert regexm(`coordinates',",")==1
                        if _rc != 0 {
                                di as err "Latitudes and longitudes must be separated by a comma"
                                exit 499
                        }
                        
                        cap assert length(`coordinates') == (length(subinstr(`coordinates',",","",.)) +1)
                        if _rc != 0{
                                di as err "Variable fed into coordinates option may only contain one comma"
                                exit 499
                        }
                        
                        tempvar latcheck
                        qui gen `latcheck' = real(substr(`coordinates',1,strpos(`coordinates',",")-1))
                        
                        cap assert `latcheck' != .
                        if _rc != 0 {
                                di as err "Latitudes may not contain non-numeric characters"
                                exit 499
                        }
                        
                        cap assert abs(`latcheck') <= 90
                        if _rc != 0 {
                                di as err "Latitudes must take values between -90 and 90"
                                exit 499
                        }
                        
                        tempvar loncheck
                        qui gen `loncheck' = real(substr(`coordinates',strpos(`coordinates',",")+1,.))
                        
                        cap assert `loncheck' != .
                        if _rc != 0 {
                                di as err "Longitudes may not contain non-numeric characters"
                                exit 499
                        }
                        
                        cap assert abs(`loncheck') <= 180
                        if _rc != 0 {
                                di as err "Longitudes must take values  between -180 and 180"
                                exit 499
                        }
                        
                        local type coordinates
                }
                
                if ("`latitude'" != "" | "`longitude'" != "") {
                        
                        cap assert "`latitude'" != "" 
                        if _rc != 0 {
                                di as err "The longitude option must be specified together with latitude"
                                exit 499
                        }
                        
                        cap assert "`longitude'" != "" 
                        if _rc != 0 {
                                di as err "The latitude option must be specified together with longitude"
                                exit 499
                        }
                        
                        cap assert "`longitude'" == "`latitude'"
                        if _rc == 0 {
                                di "Warning: same variable specified for latitude and longitude"
                        }
                        
                        * Check that latitude values are between -90 and 90
                        tempvar templat
                        tempvar latcheck
                        
                        cap confirm numeric variable `latitude'
                        if _rc == 7 {
                                qui gen `templat' = `latitude'
                                qui gen `latcheck' = real(`latitude')
                                cap assert `latcheck' != .
                                if _rc != 0 {
                                        di as err "Latitudes may not contain non-numeric characters"
                                        exit 499                                        
                                }               
                        }
                        else {
                                qui gen `templat' = string(`latitude')
                                qui gen `latcheck' = `latitude'         
                        }
                        
                        cap assert abs(`latcheck') <= 90
                        if _rc != 0 {
                                di as err "Latitudes must take values between -90 and 90"
                                exit 499
                        }
                        
                        * Check that longitude values are between -180 and 180
                        tempvar templon
                        tempvar loncheck
                        
                        cap confirm numeric variable `longitude'
                        if _rc == 7 {
                                qui gen `templon' = `longitude'
                                qui gen `loncheck' = real(`longitude')
                                cap assert `loncheck' != .
                                if _rc != 0 {
                                        di as err "Longitudes may not contain non-numeric characters"
                                        exit 499                                        
                                }
                        }
                        else {
                                qui gen `templon' = string(`longitude')
                                qui gen `loncheck' = `longitude'
                        }
                        
                        cap assert abs(`loncheck') <= 180
                        if _rc != 0 {
                                di as err "Longitudes must take values between -180 and 180"
                                exit 499
                        }
                        
                        * Insert leading zeros for values below absolute 1 (required by the Opencage Geocoder)
                        qui replace `templat' = "0" + `templat' if strpos(`templat',".") == 1
                        qui replace `templat' = subinstr(`templat',"-.","-0.",.)
                        qui replace `templon' = "0" + `templon' if strpos(`templon',".") == 1
                        qui replace `templon' = subinstr(`templon',"-.","-0.",.)
                        
                        local type latlon
                }
                
                if "`type'" != "" {
                        local address_parts "number street postcode city county state country"
                        
                        foreach i of local address_parts {
                                capture assert "``i''" == ""
                                if _rc != 0 {
                                        di as err "Options `type' and `i' may not be combined"
                                        exit 184
                                }
                        }
                }
                else {          
                        if "`street'" == "" & "`number'" == "" & "`postcode'" == "" & ///
                        "`city'" == "" & "`county'" == "" & "`country'" == "" {
                                di as err "No location specified"
                                exit 498
                        }
                        
                        local type address 
                }
                
                quietly {
                
                
                        *** Generate tempvar work containing the location
                        tempvar work

                        if ("`type'" == "fulladdress") {
                                gen `work' = " " + `fulladdress' if `touse'
                        }

                        if ("`type'" == "address") {
                                tempvar blank
                                tempvar tempnumber
                                tempvar temppostcode
                                
                                if ("`number'" != "") {
                                        cap confirm numeric variable `number'
                                        if _rc == 0 {
                                                qui tostring `number', gen(`tempnumber')
                                                qui replace `tempnumber' = "" if `tempnumber' == "."
                                        }
                                        else if _rc == 7 {
                                                gen `tempnumber' = `number'
                                        }
                                }
                                        
                                if ("`postcode'" != "") {
                                        cap confirm numeric variable `postcode'
                                        if _rc == 0 {
                                                qui tostring `postcode', gen(`temppostcode')
                                                qui replace `temppostcode' = "" if `temppostcode' == "."
                                        }
                                        else if _rc == 7 {
                                                gen `temppostcode' = `postcode'
                                        }
                                }

                                gen `blank' = ""
                                gen `work' = ""
                                
                                if ("`number'" != "") replace `work' = `work' + `tempnumber' if `touse' & `tempnumber' != ""
                                if ("`street'" != "") replace `work' = `work' + " " + `street' if `touse' & `street' != ""
                                if ("`postcode'" != "") replace `work' = `work' + "%2C" + `temppostcode' if `touse' & `work' != "" & `temppostcode' != "" 
                                if ("`city'" != "" & "`postcode'" != "") replace `work' = `work' +" " + `city' if `touse' & `city' != ""
                                if ("`city'" != "" & "`postcode'" == "") {
                                        replace `work' = `work' + "%2C" if `touse' & `city' != "" & `work' != ""
                                        replace `work' = `work' + `city' if `touse' & `city' != ""
                                }
                                if ("`county'" != ""){
                                        replace `work' = `work' + "%2C" if `touse' & `work' != "" & `county' != ""
                                        replace `work' = `work' + `county' if `touse'
                                }
                                if ("`state'" != "") {
                                        replace `work' = `work' + "%2C" if `touse' & `work' != "" & `state' != ""
                                        replace `work' = `work' + `state' if `touse'    
                                }
                                if ("`country'" != "") {
                                        replace `work' = `work' + "%2C" if `touse' & `work' != "" & `country' != ""
                                        replace `work' = `work' + `country' if `touse'
                                }
                        }
                        
                        if ("`type'" == "coordinates") {
                                gen `work' = `coordinates' if `touse'
                        }
                        
                        if ("`type'" == "latlon") {
                                gen `work' = `templat' + "%2C" + `templon' if `touse'
                        }
                        
                        
                        *** Generate local containing all var names to be filled in
                        local tobefilled g_lat g_lon g_country g_state g_county g_city  ///
                        g_postcode g_street g_number g_confidence g_formatted   
                        
                        
                        *** Replace observations if replace option specified
                        cap confirm new var `tobefilled'
                        local needreplace = _rc

                        
                        if ("`replace'" != "" | "`resume'" != "" | `needreplace' == 0) {
                                foreach var of local tobefilled{
                                        cap gen str224 `var' = ""
                                        if ("`replace'" != "") cap replace `var' = "" if `touse'
                                }
                                cap recast str224 `tobefilled'
                        }
                        else {
                                foreach var of local tobefilled{
                                        cap confirm variable `var'
                                        if !_rc {
                                                noi di as err "`var' does already exist."
                                        }
                                                
                                }
                                cap confirm variable g_quality
                                        if !_rc {
                                                noi di as err "g_quality does already exist."
                                        }
                                noi di as err "Drop above variables or use replace option."
                                exit 110                                        

                        }
                        
                        *** Generate tempvars
                        tempvar g_town g_village g_hamlet g_street_name g_road g_footway ///
                        g_residential g_pedestrian g_code
                        
                        cap gen str224 `g_town' = ""
                        cap gen str224 `g_village' = ""
                        cap gen str224 `g_hamlet' = ""
                        cap gen str224 `g_street_name' = ""
                        cap gen str224 `g_road' = ""
                        cap gen str224 `g_footway' = ""
                        cap gen str224 `g_residential' = ""
                        cap gen str224 `g_pedestrian' = ""
                        cap gen str224 `g_code' = ""
                        
                        
                        *** Clean up tempvar work to avoid problems when sending the query
                        * Change some common address formats causing errors
                        replace `work' = lower(`work')
                        replace `work' = subinstr(`work',"&","%26",.) if `touse'
                        replace `work' = subinstr(`work',"#","",.) if `touse'
                        replace `work' = subinstr(`work'," 01st"," 1st",.) if `touse'
                        replace `work' = subinstr(`work'," 02nd"," 2nd",.) if `touse'
                        replace `work' = subinstr(`work'," 03rd"," 3rd",.) if `touse'
                        replace `work' = subinstr(`work'," 04th"," 4th",.) if `touse'
                        replace `work' = subinstr(`work'," 05th"," 5th",.) if `touse'
                        replace `work' = subinstr(`work'," 06th"," 6th",.) if `touse'
                        replace `work' = subinstr(`work'," 07th"," 7th",.) if `touse'
                        replace `work' = subinstr(`work'," 08th"," 8th",.) if `touse'
                        replace `work' = subinstr(`work'," 09th"," 9th",.) if `touse'
                        replace `work' = subinstr(`work',`"""'," ",.) if `touse'

                        * Remove multiple blanks
                        replace `work' = itrim(`work')
                        
                        * Remove blanks after commas
                        replace `work' = subinstr(strtrim(`work'), ", ", ",",.)         

                        * Remove leading and trailing blanks and replace interior blanks with +
                        replace `work' = subinstr(strtrim(`work'), " ", "+",.)
                        
                        *** Check tempvar work for special characters (Stata 13 or older) or encode (if Stata 14 or newer)
                        if c(stata_version) >= 14 {
                                replace `work' = ustrto(`work', "ascii", 4)
                                replace `work' = subinstr(`work',"\","%",.)
                        }
                        else {
                                foreach num of numlist 1/31 127/255 {
                                        cap assert index(`work',char(`num')) == 0
                                        if _rc != 0 {
                                                di as err "Location names may not contain special characters"
                                                exit 499
                                        }
                                }
                        }
                        
                        *** Generate local containing column selectors
                        local selectors results:1:geometry:lat results:1:geometry:lng   ///
                        results:1:components:country results:1:components:state                 ///
                        results:1:components:county results:1:components:city                   /// 
                        results:1:components:postcode results:1:components:street               ///
                        results:1:components:house_number results:1:confidence                  /// 
                        results:1:formatted results:1:components:town                                   ///
                        results:1:components:village results:1:components:hamlet                ///
                        results:1:components:street_name results:1:components:road              ///
                        results:1:components:footway results:1:components:residential   ///
                        results:1:components:pedestrian status:code
                        
                        
                        
                        *** Order data set for geocoding
                        sort `touse' `sorder'
                        
                        *** Generate locals for loop
                        local cnt = _N
                        count if `touse' == 0
                        local start = `r(N)' + 1
                        
                        *** Loop over observations to be geocoded
                        forval i = `start'/`cnt' {
							cap {
 
                                        local offset = `i'-1
                                        local query = `work'[`i']
                                        
                                        if (`countrycodevar' == 1) local countrycode = `countrycodequery'[`i']
                                        if (`langvar' == 1) local language = `languageresponse'[`i'] 

												insheetjson `tobefilled' `g_town' `g_village' `g_hamlet' `g_street_name' `g_road' ///
                                                `g_footway' `g_residential' `g_pedestrian' `g_code' ///
                                                using "http://api.opencagedata.com/geocode/v1/json?q=`query'&key=`key'&no_annotations=1&language=`language'&countrycode=`countrycode'&limit=1", col(`selectors') flatten limit(1) offset(`offset') replace

									if (`g_code'[`i'] != "200") {
										if (`i' == `start') {
											local error = 111
										}
										else {
											local error = 112
										}
										qui replace `touse' = 0 if _n >= `i'
										continue, break
									}
										noi di "OpenCage geocoded `geocoded' of `todo'"
										local ++geocoded
								}
						
								if _rc!=0 {
                                        local error = _rc
                                        qui replace `touse' = 0 if _n >= `i'
                                        continue, break
                                }
								
                        }
					
                        
                      
                       *** Generate unique street variable
                        cap replace g_street = g_street + `g_street_name' + `g_road' +  ///
                        `g_pedestrian' + `g_residential' if (missing(g_street) | g_street == "[]") & `touse'
                        
                       *** Generate unique city variable
                        cap replace g_city = g_city + `g_town' + `g_village' + `g_hamlet' ///
                        if (missing(g_city) | g_city == "[]") & `touse'
                        
                       *** Compress variables and convert to UTF-8 if Stata 14
                       foreach var of local tobefilled {
                                if c(stata_version) >= 14 {
									replace `var' = ustrunescape(`var') if `touse'
                                }
                                replace `var' = subinstr(`var',"[]","",.) if `touse'
                        }
                        
                        cap compress `tobefilled' 
                        sort `sorder'
                        
                        *** Generate g_quality variable
                        cap gen g_quality = . 
                        replace g_quality = 0 if `touse'
                        replace g_quality = 1 if g_country != "" & `touse'
                        replace g_quality = 2 if g_state != "" & `touse'
                        replace g_quality = 3 if g_county != "" & `touse' 
                        replace g_quality = 4 if g_city != "" & `touse'
                        replace g_quality = 5 if g_postcode != "" & `touse'             
                        replace g_quality = 6 if g_street != "" & `touse'
                        replace g_quality = 7 if g_number != "" & `touse'

                        
                        *** Define labels and label values of g_quality
                        cap label define quality  0 "not found" 1 "country"  2 "state"  ///
                        3 "county"  4 "city"  5 "postcode"  6 "street" 7 "number"
                        label values g_quality quality
                        
						
                        *** Exit if error occured
                        if ("`error'" != "") {
                                if (`error' == 111) {
                                        noi di as err "No observations geocoded: Invalid key, rate limit exceeded or no internet connection"
										exit
                                }
								else if (`error' == 112) {
										noi di as err "Rate limit exceeded or internet connection failed"
										exit
								}
                                exit `error'
                        }

                        *** Display summary table of g_quality
                        if ("`resume'" != "") marksample touse, novarlist
                        noi tab g_quality if `touse'
                        noi di _newline  "Data generated is jointly licensed under the ODbL and CC-BY-SA licenses"

		}

end
