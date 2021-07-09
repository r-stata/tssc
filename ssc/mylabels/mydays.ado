*! NJC 2.0.0 4 August 2005 
* was lastdays NJC 1.0.0 2 August 2005, using code from Scott Merryman 
program mydays 
	version 9 
	syntax [if] [in] , Local(str) ///
	[Days(numlist int >0 <32) LAST Months(numlist int >0 <13) Format(str)] 

	quietly {
		if "`days'`last'" == "" { 
			di as txt "nothing to do?" 
			exit 0 
		}	
		
		// error if not -tsset- 
		tsset 

		// daily dates? 
		if !inlist("`r(unit)'", "daily", "generic") { 
			di as err "`r(timevar)' not daily dates" 
			exit 498 
		} 	
		else di as txt "`r(timevar)' assumed to be daily dates" 

		// test format if specified 
		if "`format'" != "" { 
			capture di `format' 0 
			if _rc { 
				di as err "invalid %format" 
				exit 120
			} 
		} 	
	
		local varlist "`r(timevar)'" 
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000 

		su `varlist' if `touse', meanonly      
		local min = r(min) 
		local max = r(max) 
		
		tempvar year
		gen `year' = year(`varlist') if `touse' 
		levelsof `year' if `touse', local(years) 
		
		if "`months'" == "" local months "1 2 3 4 5 6 7 8 9 10 11 12" 

		foreach y of local years { 
			foreach m of local months {
				foreach d of local days { 
					local t = mdy(`m',`d',`y')
					if inrange(`t',`min',`max') { 
						local D "`D'`t' "
					} 
				} 
				if "`last'" != "" { 
					local M = cond(`m' == 12, 1, `m' + 1) 
					local Y = cond(`m' == 12, `y' + 1, `y') 
					local t = mdy(`M',1,`Y') - 1
					if inrange(`t',`min',`max') { 
						local D "`D'`t' "
					}
				}
			}	
		}
	}

	if "`format'" == "" local format : format `varlist'
	foreach d of local D { 
		di as txt `format' `d' "  " _c 
	}	
	di " " 
	
	c_local `local' `D'
end 
