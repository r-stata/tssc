*! version 0.3.7
* Changelog
* 3.7 apikey instead of app_id and appcode
* 3.6 packaged for SSC and updated help file
* 3.5 added unicode support through urlencode taken from http://fmwww.bc.edu/repec/bocode/l/libjson_source.mata
* 3.4 helpfile update
* 3.3 changed the "noisily" output (link to long to be shown as {browse "vfvf"}
* 3.2 added language(...) option and match_code as return variable
*Simon Heß, 14.8.2017
cap program drop geocodehere
//this code is from http://fmwww.bc.edu/repec/bocode/l/libjson_source.mata
cap mata: string scalar urlencodeforjson(string scalar s) { res = J(1,0,.); a=ascii(s); for(c=1;c<=cols(a); c++) { if ((a[c]>=44 && a[c]<=59) || (a[c]>=64 && a[c]<=122)) { res=(res,a[c]);} else { h1 = floor(a[c]/16); h2 = mod(a[c],16); if (h1<10) {h1=h1+48;} else {h1=h1+55;}  if (h2<10) {h2=h2+48;} else {h2=h2+55;} res=(res, 37, h1,h2);} } return(char(res));}  

program geocodehere
    version 11.0
	syntax [if] [in], [REPlace] [NOIsily] [searchtext(string)] [appcode(string) appid(string)] apikey(string) [country(string)] [state(string)] [county(string)] [countryfocus(string)] [city(string)] [district(string)] [street(string)] [housenumber(string)] [postalcode(string)] [language(string)]
	marksample touse
	
	quietly `noisily' di "GEOCODEHERE Version: 0.3.6"
	
	local continue = 1
	
	if "`replace'"=="replace" { //if replace is specified drop all geocodehere_* variables, if they exists
		cap drop geocodehere_*
	}
	else {
		cap sum geocodehere_* // if not, cast an error message and quit
		if _rc==0 { //if there actually are variables called geocodehere_*
			foreach var of varlist geocodehere_* {
				capture confirm variable `var'
				if !_rc {
					di  "{err: Error: variable `var' exists}"
					local continue = 0
				}
			}
		}
		if `continue'==0 {
			di  "Please either remove/rename or run geocodehere with the replace option" //aside from casting an error, also tell the user how to fix it.
		}
	}
	if ("`app_key'`app_code'"!="") {
			di  as err "{HERE maps stopped using appids and appcodes, please use apikey instead. see }"
			di `"see {browse "https://developer.here.com/documentation/authentication/dev_guide/topics/api-key-credentials.html"}."'
	}
	****Does the connection to the server work? Let me run a fake request to find out
	tempfile data	//save the current dataset
	qui save `data', replace
	clear	
	tempfile test 
	//run a fake request, looking for a place called "Witzenhausen" and saving the result in a tempfile called test
	qui insheetjson using  "https://geocoder.ls.hereapi.com/search/6.2/geocode.json?apiKey=`apikey'&language=`language'&gen=8&searchtext=Witzenhausen&responseattributes=matchCode", savecontents(`test')
	qui infile a using  "`test'", clear
	cap desc a
	if _rc!=0 { //if this produced no valid file: cast an error, and give the user the opportunity to figure out why
		local continue = 0
		di "{err: Connection to the server failed}"
		di `"Try visiting {browse "https://geocoder.ls.hereapi.com/search/6.2/geocode.json?apiKey=`apikey'&gen=8&language=`language'&searchtext=Witzenhausen&responseattributes=matchCode"} to figure out why this failed."'
	}
	qui use `data', clear
	
**If `continue' is still 1, i.e. if we want to proceed geocoding:
	if `continue' {
		quietly {
			tempvar varsort  searchtext_ country_ state_ country_ city_ district_ street_ housenumber_ postalcode_ countryfocus_
			gen `varsort'= _n
			//for each input variable, generate a temporary copy, and strip characters that don't go well in URLs
			foreach var in searchtext country state country city district street housenumber postalcode countryfocus {
				cap gen ``var'_' = ``var''											if `touse'	//paste values of variablename given in option
				cap gen ``var'_' = ""												if `touse'	//if not possible, just make it missing
				replace ``var'_' = " " + ``var'_'									if `touse'
				replace ``var'_' = upper(``var'_')									if `touse'
				replace ``var'_' = subinstr(``var'_',"&","%26",.)				 	if `touse'
				replace ``var'_' = subinstr(``var'_',"#","",.) 						if `touse'
				replace ``var'_' = trim(``var'_')									if `touse'
				replace ``var'_' = itrim(trim(``var'_'))							if `touse'
				replace ``var'_' = subinstr(``var'_'," ","+",.)						if `touse'
				replace ``var'_' = subinstr(``var'_',`"""'," ",.)					if `touse'
			}

			local cnt = _N
			local counter = 1
			sum `touse'
	
			gen str3	geocodehere_country=""
			gen str30	geocodehere_lat=""
			gen str30	geocodehere_lon=""
			gen str90	geocodehere_label=""
			gen str30	geocodehere_match_level=""
			gen str30	geocodehere_match_code=""
			gen str30	geocodehere_locationtype=""
			gen str30	geocodehere_county=""
			gen str30	geocodehere_city=""
			gen str30	geocodehere_district=""
			gen str30	geocodehere_street=""
			gen str30	geocodehere_housenumber=""
			gen str30	geocodehere_postalcode=""
			
			cap label variable	geocodehere_country "Country code"
			cap label variable	geocodehere_lon "Longitude"
			cap label variable	geocodehere_lat "Latitude"
			cap label variable	geocodehere_label "Address label"
			cap label variable	geocodehere_match_level "Match level"
			cap label variable	geocodehere_match_level "Match code"
			cap label variable	geocodehere_locationtype "Location type"
			cap label variable	geocodehere_county "County"
			cap label variable	geocodehere_city "City"
			cap label variable	geocodehere_district "District"
			cap label variable	geocodehere_street "Street name"
			cap label variable	geocodehere_housenumber "House number"
			cap label variable	geocodehere_postalcode "Postal code"
			
			tempfile coordinates
			
			tempfile data	//save the current dataset
			
			*loop through observations:
			forval i = 1/`cnt' {
				*if an observation is selected to be geocoded (this is affected by the "if" or the "in" statements)
				if `touse'[`i']==1 {
					`noisily' dis as text "`i' of `cnt':"
					qui save `data', replace //preserve
					keep if `varsort'==`i'
					foreach var in searchtext country state country city district street housenumber postalcode countryfocus {
						levelsof ``var'_', local(`var'__) clean separate("+")
					}
					`noisily' di as text "JSON link:  " _continue
					mata: st_local("appid",urlencodeforjson(st_local("appid")))
					mata: st_local("appcode",urlencodeforjson(st_local("appcode")))
					mata: st_local("country__",urlencodeforjson(st_local("country__")))
					mata: st_local("state__",urlencodeforjson(st_local("state__")))
					mata: st_local("county__",urlencodeforjson(st_local("county__")))
					mata: st_local("city__",urlencodeforjson(st_local("city__")))
					mata: st_local("district__",urlencodeforjson(st_local("district__")))
					mata: st_local("street__",urlencodeforjson(st_local("street__")))
					mata: st_local("housenumber__",urlencodeforjson(st_local("housenumber__")))
					mata: st_local("postalcode__",urlencodeforjson(st_local("postalcode__")))
					mata: st_local("countryfocus__",urlencodeforjson(st_local("countryfocus__")))
					mata: st_local("language",urlencodeforjson(st_local("language")))
					mata: st_local("searchtext__",urlencodeforjson(st_local("searchtext__")))
					local link = "https://geocoder.ls.hereapi.com/search/6.2/geocode.json?apiKey=`apikey'&responseattributes=matchCode&country=`country__'&state=`state__'&county=`county__'&city=`city__'&district=`district__'&street=`street__'&housenumber=`housenumber__'&postalCode=`postalcode__'&countryfocus=`countryfocus__'&language=`language'&gen=8&searchtext=`searchtext__'"
					`noisily' di   " `link'"
					`noisily' insheetjson  geocodehere_country  geocodehere_lon  geocodehere_lat   geocodehere_label geocodehere_match_level geocodehere_match_code   geocodehere_locationtype geocodehere_county geocodehere_city geocodehere_district geocodehere_street geocodehere_housenumber geocodehere_postalcode using "`link'" , flatten tableselector("Response") columns("View:1:Result:1:Location:Address:Country" "View:1:Result:1:Location:DisplayPosition:Longitude" "View:1:Result:1:Location:DisplayPosition:Latitude"	"View:1:Result:1:Location:Address:Label" "View:1:Result:1:MatchLevel" "View:1:Result:1:MatchCode"  "View:1:Result:1:Location:LocationType" "View:1:Result:1:Location:Address:County" "View:1:Result:1:Location:Address:City" "View:1:Result:1:Location:Address:District"	 "View:1:Result:1:Location:Address:Street"	 "View:1:Result:1:Location:Address:HouseNumber"	 "View:1:Result:1:Location:Address:PostalCode" ) replace
					save `coordinates', replace
					qui use `data', clear //restore
					merge 1:1 `varsort' using `coordinates', update
					drop _merge
				}
				else {
					`noisily' dis "`i' of `cnt' [not in sample]"
				}
			}
			destring geocodehere_lat geocodehere_lon, replace
		}
	}
end
