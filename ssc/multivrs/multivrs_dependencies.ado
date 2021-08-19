// Check for availability of dependencies (https://www.stata.com/statalist/archive/2012-06/msg00872.html)
	// try to install if not already present. 
program multivrs_dependencies
	capture findfile valuesof.ado
	local loc_valuesof "`r(fn)'"
	//di as result "loc_valuesof = `loc_valuesof'"
	
	capture mata mata which mm_invtokens()
	local isfound_moremata = _rc == 0
	//di as result "isfound_moremata = `isfound_moremata'"
	
	
	if ("`loc_valuesof'" == "" | `isfound_moremata' == 0) {
	
		di _newline
		di as txt "Note: Packages -valuesof- and/or -moremata- need to be installed first."		 	 
		di _newline
		di as result "Type Y to automatically install these and continue: " _request(ans)	     
		di _newline
		 if ("$ans" == "Y" | "$ans" == "y") {
		 		 
			if "`loc_valuesof'" == "" {
				di "Installing -values of- using {ssc install}..."
				di _newline
				capture ssc install valuesof
				if (_rc != 0) {
					di as error "Error during {ssc install valuesof}. Try typing {ssc uninstall valuesof} and then run your {multivrs} command again."
					exit _rc
				}
			}
			if `isfound_moremata' == 0 {		
				di "Installing -moremata- using {ssc install}..."
				di _newline
				capture ssc install moremata
				if (_rc != 0) {
					di as error "Error during {ssc install moremata}. Try typing {ssc uninstall moremata} and then run your {multivrs} command again."
					exit _rc
				}
			}
		} 
		else {	
			di as text "You entered: " as input "$ans"
			di as text "No packages were installed."
			di _newline
			di _newline
			di as result "In order to use the -multivrs- command, please first use {ssc install} to install -valuesof- and -moremata-."
			exit
		}
	}	
end
