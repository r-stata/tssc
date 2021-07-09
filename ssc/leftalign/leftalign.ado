*! version 2.0.3, 09sep2014, Robert Picard, picard@netbox.com      
program define leftalign

	version 9.2
	
	syntax [varlist] , [Label All]
	
	foreach v of varlist `varlist' {
	
		if "`all'" != "" local doit 1
		else local doit 0
		
		
		if "`label'" != "" {
			if "`: value label `v''" != "" local doit 1		
		}
	
		// do all string variables
		local f : format `v'
		if regexm("`f'", "^%.+s$") local doit 1
		
		if `doit' {
		
			// strip the "%", "%-", or "%~" prefix
			local ff = regexr("`f'", "^%~?\-?","")
		
			// ignore error if the left-aligned format is not legal		
			cap format %-`ff' `v'
		
			// check for change vs. original format
			if "`: format `v''" != "`f'" local vlist `vlist' `v'
			
		}
		
	}
	
	if "`vlist'" != "" des `vlist'
		
end
