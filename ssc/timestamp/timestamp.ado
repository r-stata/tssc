*! timestamp version 1.0 (13/05/2016)
*! Lars Zeigermann

program define timestamp, rclass
        version 12
		
		syntax, [FORmat(string) TIMEzone(string) QUIetly]
		
		cap which insheetjson
		if _rc == 111 di as err "Insheetjson.ado not found, please ssc install insheetjson"
		cap which libjson.mlib
		if _rc == 111 di as err "Libjson.mlib not found, please ssc install libjson"
		if _rc == 111 exit 499
		
		if ("`format'" == "") {
			local format default
		}
		else {
			local format = lower("`format'")
			cap assert "`format'" == "default" | "`format'" == "german" | "`format'" == "english" ///
				| "`format'" == "english12" | "`format'" == "rfc1123" | "`format'" == "iso8601"
			if _rc != 0 {
				di as err "`format' is not a valid format. Choose default, english, english12, german, rfc1123 or iso8601."
				exit 199
			}
		}
		
		if ("`timezone'" == "") {
			local timezone utc
		}
		else {
			local timezone = subinstr("`timezone'","/","%2F",.)
		}
		
		qui insheetjson using "http://www.convert-unix-time.com/api?timestamp=now&format=`format'&timezone=`timezone'", topscalars printonly
		mata: st_local("break", strofreal(-dummy))
		
		if "`break'" == "1" {
			di as err "No timestamp obtained: Check internet connection."
			exit 631
		}
		
		if "`r(code)'" == "4" {
			local timezone = subinstr("`timezone'","%2F","/",.)
			di as err "`timezone' is not a valid timezone."
			exit 199
		}
		
		local timezone `r(timezone)'
		local timezone = subinstr("`timezone'","\","",.)
		local utcDate `r(utcDate)'
		local utcDate = subinstr("`utcDate'","\","",.)
		local localDate `r(localDate)'
		local localDate = subinstr("`localDate'","\","",.)
		if "`r(daylightSavingTime)'" == "true" {
			local dst yes
		}
		else {
			local dst no
		}
		
		if ("`timezone'" != "UTC") {
			return local dst `dst'
			return local localDate `r(localDate)'
		}
		return local utcDate `r(utcDate)'
		return local timestamp `r(timestamp)'
		return local timezone `timezone'

		if ("`quietly'" == "") {
			 disp "********************************************************"
			 disp "UNIX Timestamp: `r(timestamp)'"
			 disp "UTC Date and Time: `utcDate'"
			 if ("`timezone'" != "UTC") {
				disp "Local Date and Time: `localDate'"
				disp "Timezone: `timezone'"
				disp "Daylight Saving Time: `dst'"
			 }
			 disp "Timestamp obtained from http://www.convert-unix-time.com"
			 disp "********************************************************"
		
		}
				
end
