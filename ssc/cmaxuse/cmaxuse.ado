prog drop _all

*! cmaxuse v1.0.0 C515  cloned from bcuse v1.0.3  BB29
prog cmaxuse
	version 11
	syntax anything [, CLEAR noDesc]
	if regexm("`anything'", ".+.zip$") {
		capt copy "http://www.cmaxxsports.com/data/`anything'" ., replace
		if _rc != 0 {
			di as err _n "Error: cannot copy `anything' to current working directory."
			exit 
		}
		qui unzipfile "`anything'", replace
		loc fn = reverse(substr(reverse("`anything'"), 5, .))
		capt use `fn', `clear'
	}
	else {
			capt use "http://www.cmaxxsports.com/data/`anything'", `clear'
	}
	if _rc != 0 {
 		if _rc == 4 {
 			di as err _n "Error: data in memory would be lost. Use  cmaxuse `anything', clear  to discard changes."
 		} 
 		else if _rc == 610 {
 			di as err _n "Error: Cmax datafile `anything' must be accessed from Stata 12.x." _n  "It cannot be read by earlier Stata versions."
 		}
 		else {
		di as err _n "Error: Cmax datafile `anything' does not exist. Contents of memory not altered."
		}
		exit
	}
	if "`desc'" != "nodesc" { 
		describe
	}
end
// 1.0.1: trap rc 4 for separate message
// 1.0.2: trap rc 610 for separate message	
// 1.0.3: add logic to handle zipped dta files
