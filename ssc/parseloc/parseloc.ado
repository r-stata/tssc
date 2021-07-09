*! parseloc 1.0.0 by Sergiy Radyakin
*! 96903a99-0a10-4893-bf88-4a9d9082a74c
*! Parse the specified geolocation variable in the format as captured 
*! by Survey Solutions into 4 separate coordinate variables.

program define parseloc
  
  version 9.0
  
  local omit "0"
  local cfmt "%20.6f"
  local mfmt "%20.1f"

  syntax varname [, LATitude(string) LONgitude(string) ///
                    ALTitude(string) ACCuracy(string)]
  
  local location `"`varlist'"'

  if missing(`"`latitude'"') local latitude "latitude"
  if (`"`latitude'"'!="`omit'") {
    quietly generate `latitude'=substr(`location', 1, strpos(substr(`location', 1, ///
                        strpos(`location', "[") - 1), ",") - 1)
	capture destring `latitude', replace
	capture confirm numeric variable `latitude'
	if _rc {
	  display in yellow "Warning! Encountered invalid latitude values." _n ///
	          in green  "         -parseloc- will replace them with missing values." _n
	  quietly destring `latitude', replace force
	}
	format `latitude' `cfmt'
	label variable `latitude' "Latitude, degrees"
	note `latitude': Source variable: [`location'] `:variable label `location''
  }
  
  if missing(`"`longitude'"') local longitude "longitude"
  if (`"`longitude'"'!="`omit'") {
    quietly generate `longitude'=substr(substr(`location', 1, strpos(`location', "[") - 1), ///
                         strpos(substr(`location', 1, strpos(`location', "[") - 1), ",") + 1, .)
	capture destring `longitude', replace
	capture confirm numeric variable `longitude'
	if _rc {
	  display in yellow "Warning! Encountered invalid longitude values." _n ///
	          in green  "         -parseloc- will replace them with missing values." _n
	  quietly destring `longitude', replace force
	}
	format `longitude' `cfmt'
	label variable `longitude' "Longitude, degrees"
	note `longitude': Source variable: [`location'] `:variable label `location''
  }

  if missing(`"`altitude'"') local altitude "altitude"
  if (`"`altitude'"'!="`omit'") {
    quietly generate `altitude'=substr(`location', strpos(`location', "]") + 1, .)
	capture destring `altitude', replace
	capture confirm numeric variable `altitude'
	if _rc {
	  display in yellow "Warning! Encountered invalid altitude values." _n ///
	          in green  "         -parseloc- will replace them with missing values." _n
	  quietly destring `altitude', replace force
	}
	format `altitude' `mfmt'
	label variable `altitude' "Altitude, meters"
	note `altitude': Source variable: [`location'] `:variable label `location''
  }
  
  if missing(`"`accuracy'"') local accuracy "accuracy"
  if (`"`accuracy'"'!="`omit'") {
    quietly generate `accuracy'=substr(`location', strpos(`location', "[") + 1, ///
                        strpos(`location', "]") - strpos(`location', "[") - 1)
	capture destring `accuracy', replace
	capture confirm numeric variable `accuracy'
	if _rc {
	  display in yellow "Warning! Encountered invalid accuracy values." _n ///
	          in green  "         -parseloc- will replace them with missing values" _n
	  quietly destring `accuracy', replace force
	}
	format `accuracy' `mfmt'
	label variable `accuracy' "Accuracy, meters"
	note `accuracy': Source variable: [`location'] `:variable label `location''
  }

end

*** END OF FILE
