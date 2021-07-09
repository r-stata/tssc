*! NJC 1.0.0 27 August 2004 
program reorder
	version 8
	capture syntax , PREVious

	// reset
	if _rc == 0 { 
		if "`: char _dta[reorder]'" == "" { 
			di as err "reordering information not found"
			exit 498 
		} 
		else { 
			capture confirm var `: char _dta[reorder]' 
			if _rc { 
				di as err "previous variable list not valid" 
				exit _rc 
			} 
			else { 
				unab temp : * 
				order `: char _dta[reorder]' 
				char _dta[reorder] "`temp'" 
				exit 0 
			}
		}
	}
	// new ordering 
	else { 
		syntax varlist 

		unab temp : * 
		order `varlist' 
		char _dta[reorder] "`temp'" 
	}
end 	
