*! version 0.1, HS

program define wtd_is
	version 7.0
/*	if `"`_dta[_dta]'"'=="wtd" {
		if "`1'"=="analysis" {
			exit
		}
	} */
	if `"`_dta[_dta]'"'!="wtd" {
		di in red "data not wtd " _c
		if `"`_dta[_dta]'"'!="" {
			di in red /*
			*/ `"(data are marked as being `_dta[_dta]' data)"'
		}
		else	di
		exit 119
	}
end
