*! NJC 1.0.1 5 May 2005 
program vclose
	version 9 
	syntax [anything] 

	if inlist("`anything'", "", "_all") { 
		window manage close viewer _all
	}
	else { 
		capture numlist "`anything'" 

		if _rc == 0 { 
			foreach v in `r(numlist)' { 
				window manage close viewer "#`v'"
			}
		}
		else foreach v in `anything' { 
			window manage close viewer "`v'" 
		}	
	}
end 
