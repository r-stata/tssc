prog drop _all

*! bcuse v1.0.4  2jun2017
prog bcuse
	version 11
	syntax anything [, CLEAR noDesc]
	if regexm("`anything'", ".+.zip$") {
		capt copy "http://fmwww.bc.edu/ec-p/data/wooldridge/`anything'" ., replace
		if _rc != 0 {
			di as err _n "Error: cannot copy `anything' to current working directory."
			exit 
		}
		qui unzipfile "`anything'", replace
		loc fn = reverse(substr(reverse("`anything'"), 5, .))
		capt use `fn', `clear'
	}
	else {
		capt use "http://fmwww.bc.edu/ec-p/data/wooldridge/`anything'", `clear'
	}
	if _rc != 0 {
 		if _rc == 4 {
 			di as err _n "Error: data in memory would be lost. Use  bcuse `anything', clear  to discard changes."
 		} 
 		else if _rc == 610 {
 			di as err _n "Error: BC datafile `anything' must be accessed from Stata 12.x." _n  "It cannot be read by earlier Stata versions."
 		}
 		else {
		di as err _n "Error: BC datafile `anything' does not exist. Contents of memory not altered."
		}
		exit
	}
	if "`desc'" != "nodesc" { 
		describe
	}
	capt tsset
	if _rc==0 {
		tsset
	}
end
// 1.0.1: trap rc 4 for separate message
// 1.0.2: trap rc 610 for separate message	
// 1.0.3: add logic to handle zipped dta files
// 1.0.4: display tsset if tsset