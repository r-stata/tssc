*February 15, 2015

program drop _all
program gcode, rclass
	version 12

	if `"`0'"' == "" { 
		di as err "Please type location address" 
		exit 198 
	}

		if `"`0'"' ~= "" { 
local x = subinstr("`0'", " ", "_", .)
                }
				
		if `"`0'"' == "," { 
local x = subinstr("`0'", " ", "_", .)
                }
				
tempvar status location loctype type lat  long NElat NElong SWlat SWlong

cap gen str16 `status'    = ""
cap gen str104 `location' = ""
cap gen str24 `loctype'   = ""
cap gen str48 `type'      = ""
cap gen str9 `lat'        = ""
cap gen str9 `long'       = ""


local ad="`x'" 
tempfile j
qui capture copy "http://maps.googleapis.com/maps/api/geocode/json?address=`ad'&sensor=false" `j'.json, replace
qui capture insheetjson `status' using "`j'.json", table("status") col("status") replace 
qui capture insheetjson `location' `loctype' `type' `lat' `long' using "`j'.json", table("results") col("formatted_address" "geometry:location_type" "types" "geometry:location:lat" "geometry:location:lng") replace 
qui destring `lat' `long',replace force
qui return scalar long = `long'
qui return scalar lat = `lat'


     di in gr "***********************
     di in ye "Google Geocode Response
     di in gr "***********************
	 di in gr "Status:" in y" " `status'
	 di in gr "Type:" in y" " `type'
     di in gr "Location Type:" in y" " `loctype'
	 di in gr "Formatted Address:" in y" "`location'
     di in gr "Latitude:" in y" " `lat'
	 di in gr "Longitude:" in y" "`long'
	end
exit
