program def tabmerge
*! NJC 1.1.0 9 March 2002
	version 7 
	syntax [varname(def=none)] [ , * ] 
	if "`varlist'" == "" { /* look for _merge */ 
		capture confirm var _merge 
		if _rc { /* didn't find it */ 
			di as err "_merge not found"
			exit 198 
		}
		else local varlist "_merge" 
	}
	
	local label : value label `varlist' 
	if "`label'" == "" { 
		tempname merge 
		lab def `merge' 1 "obs. from master data"         /* 
		*/ 2  "obs. from using data"                      /* 
		*/ 3  "obs. from both master and using data"      /* 
		*/ 4  "obs. from both, missing in master updated" /*   
		*/ 5  "obs. from both, master disagrees with using"
		lab val `varlist' `merge'
	} 	

	tab `varlist', `options' 
end 
