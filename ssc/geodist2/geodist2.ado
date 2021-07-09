*June 16, 2015

program drop _all
program geodist2, rclass
syntax [,from(string) to(string)]
	version 12

	if `"`from'"' == "" { 
		di as err "Please type first location address(from)" 
		exit 198 
	}

		if `"`from'"' ~= "" { 
local gl1 = subinstr("`from'", " ", "_", .)
                }
				
		if `"`from'"' == "," { 
local gl1 = subinstr("`from'", " ", "_", .)
                }
	
	if `"`to'"' == "" { 
		di as err "Please type second location address(to)" 
		exit 198 
	}

		if `"`to'"' ~= "" { 
local gl2 = subinstr("`to'", " ", "_", .)
                }
				
		if `"`to'"' == "," { 
local gl2 = subinstr("`to'", " ", "_", .)
                }
	
tempvar status1 location1 loctype1 type1 lat1 long1

cap gen str16  `status1'   = ""
cap gen str104 `location1' = ""
cap gen str24  `loctype1'  = ""
cap gen str48  `type1'     = ""
cap gen str9   `lat1'      = ""
cap gen str9   `long1'     = ""


tempfile k
qui capture copy "http://maps.googleapis.com/maps/api/geocode/json?address=`gl1'&sensor=false" `k'.json, replace
qui capture insheetjson `status1' using "`k'.json", table("status") col("status") replace 
qui capture insheetjson `location1' `loctype1' `type1' `lat1' `long1' using "`k'.json", table("results") col("formatted_address" "geometry:location_type" "types" "geometry:location:lat" "geometry:location:lng") replace 
qui destring `lat1' `long1',replace force
qui scalar long1 = `long1'
qui scalar lat1 = `lat1'

     di in white "."
     di in gr "--------------------"
     di in w "Geocode: Location 1
     di in gr "--------------------"
	 *di in gr "Status:" in y" " `status1'
	 di in gr "Type:" in y" " `type1'
     di in gr "Location Type:" in y" " `loctype1'
	 di in gr "Formatted Address:" in y" "`location1'
     di in gr "Latitude:" in y" " `lat1'
	 di in gr "Longitude:" in y" "`long1'
	 

tempvar status2 location2 loctype2 type2 lat2 long2
cap gen str16  `status2'    = ""
cap gen str104 `location2'  = ""
cap gen str24  `loctype2'   = ""
cap gen str48  `type2'      = ""
cap gen str9   `lat2'       = ""
cap gen str9   `long2'      = ""

tempfile s2
qui capture copy "http://maps.googleapis.com/maps/api/geocode/json?address=`gl2'&sensor=false" `s2'.json, replace
qui capture insheetjson `status2' using "`s2'.json", table("status") col("status") replace 
qui capture insheetjson `location2' `loctype2' `type2' `lat2' `long2' using "`s2'.json", table("results") col("formatted_address" "geometry:location_type" "types" "geometry:location:lat" "geometry:location:lng") replace 
qui destring `lat2' `long2',replace force
qui scalar long2 = `long2'
qui scalar lat2 = `lat2'

     di in white "."
     di in gr "--------------------"
     di in w "Geocode: Location 2
     di in gr "--------------------"
	 *di in gr "Status:" in y" " `status2'
	 di in gr "Type:" in y" " `type2'
     di in gr "Location Type:" in y" " `loctype2'
	 di in gr "Formatted Address:" in y" "`location2'
     di in gr "Latitude:" in y" " `lat2'
	 di in gr "Longitude:" in y" "`long2'
	

      scalar distance=6371 * acos(sin(`lat1'/57.2957795) * sin(`lat2'/57.2957795) + cos(`lat1'/57.2957795) * cos(`lat2'/57.2957795) * cos(`long1'/57.2957795-`long2'/57.2957795))
	  scalar distance2=distance*0.6214
	  di in white "."
      di in gr "-----------------------------------------------------------------------"
	  di in w  "Straight Distance : "%6.2f distance "(Km)" "/"%6.2f distance2 "(Miles)"
	  di in w  "From     	      : "`location1' 
	  di in w  "To       	      : "`location2'
	  di in gr "-----------------------------------------------------------------------"


	  scalar drop _all
end

exit
