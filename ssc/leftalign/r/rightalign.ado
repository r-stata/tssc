*! version 1.0.0, 10sep2014, Robert Picard, picard@netbox.com      
program define rightalign

	version 9.2
	
	syntax [varlist]
	
	foreach v of varlist `varlist' {
	
		local f : format `v'

		// strip the "%", "%-", or "%~" prefix
		local ff = regexr("`f'", "^%~?\-?","")
	
		// ignore error if the left-aligned format is not legal		
		cap format %`ff' `v'
	
		// check for change vs. original format
		if "`: format `v''" != "`f'" local vlist `vlist' `v'
					
	}
	
	if "`vlist'" != "" des `vlist'
		
end
