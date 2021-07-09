*! opencagegeoi version 1.0 (16/03/2016)
*! Lars Zeigermannn
*  opencagegeoi is a (simplified) immediate version of opencagegeo
*  It reuses a code segment from the libjson help file written by Erik Lindsley

capture program drop opencagegeoi
program opencagegeoi, rclass
        version 12.1
		
		cap which libjson.mlib
        if _rc == 111 {
				di as err "Libjson.mlib not found, please ssc install libjson"
				assert 1 == 2
		}

        if "`0'" == "" { 
                di as err "Please enter location address" 
                exit 198 
        }
		
		if "$mykey" == "" {
				di as err "Define global macro mykey containing your OpenCage Data API key"
				exit 198
		}
		
		if "$language" == "" {
				local language = "en"
		}
		else {
				local language = "$language"
		}
 
		local work = "`0'"
		
		* Change some common address formats causing errors
		local work = lower("`work'")
		local work = subinstr("`work'","&","%26",.)
		local work = subinstr("`work'","#","",.)
		local work = subinstr("`work'"," 01st"," 1st",.)
		local work = subinstr("`work'"," 02nd"," 2nd",.)
		local work = subinstr("`work'"," 03rd"," 3rd",.)
		local work = subinstr("`work'"," 04th"," 4th",.)
		local work = subinstr("`work'"," 05th"," 5th",.)
		local work = subinstr("`work'"," 06th"," 6th",.)
		local work = subinstr("`work'"," 07th"," 7th",.)
		local work = subinstr("`work'"," 08th"," 8th",.)
		local work = subinstr("`work'"," 09th"," 9th",.)
		local work = subinstr("`work'",`"""'," ",.)

		* Remove multiple blanks
		local work = itrim("`work'")
		
		* Remove blanks after commas
		local work = subinstr(strtrim("`work'"), ", ", ",",.)		

		* Remove leading and trailing blanks and replace interior blanks with +
		local work = subinstr(strtrim("`work'"), " ", "+",.)
		
		* Check work for special characters (Stata 13 or older) or encode (if Stata 14 or newer)
		if c(stata_version) >= 14 {
			local work = ustrto("`work'", "ascii", 4)
			local work = subinstr("`work'","\","%",.)
		}
		else {
			foreach num of numlist 1/31 127/255 {
			cap assert index("`work'",char(`num')) == 0
				if _rc != 0 {
					di as err "Location address may not contain special characters"
					exit 499
				}
			}
		}

		local url "http://api.opencagedata.com/geocode/v1/json?q=`work'&key=$mykey&no_annotations=1&limit=1&language=`language'"
		
		cap mata: get_OpenCageData("`url'")

		if "`status'" != "OK" {
			di in red "Server refused to send file: Check key, internet connection and query limit"
			exit 199
		}
		
		if c(stata_version) >= 14 {
			local formatted = ustrunescape("`formatted'")
		}
		
		* Store results in r()
		return local confidence `conf'
		return local longitude `lon'
		return local latitude `lat'
		return local formatted_address `formatted'
		return local input_address `0'
		

		di "*********************************"
		di "*** OpenCage Geocoder Results ***"
		di "*********************************"
		di "Formatted address: `formatted'"
		di "Latitude: `lat'"
		di "Longitude: `lon'"
	
end

version 12.1
mata:
void get_OpenCageData(url) {

		selectors="results:1:formatted","results:1:geometry:lat","results:1:geometry:lng","results:1:confidence"
		
		pointer (class libjson scalar) scalar root
		root = libjson::webcall(url,"")
		if (root) {
				string rowvector res
				res = J(1,4,"")
				for (c=1; c<= 4; c++) {       
						res[c] = root->getString( libjson::parseSelector(selectors[c]) ,"")
				}
				
				st_local("status","OK")
				st_local("formatted", res[1,1])
				st_local("lat", res[1,2])
				st_local("lon", res[1,3])
				st_local("conf", res[1,4])
		} 
}
end	

exit
