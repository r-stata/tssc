*! 2.1.0 NJC 15 April 2004
* 2.0.0 NJC 12 January 2004
* 1.2.1 NJC 16 December 1998
* 1.2.0 NJC 14 May 1997
* 1.1.0 NJC 23 September 1996
* centring circular data
* generates new variable: angles expressed relative to centre, -180 0 180
program circcentre
	version 8.0
	syntax varname(numeric) [if] [in], Generate(str) [ Centre(string) SINE ]
	confirm new variable `generate'
	
	if "`centre'" == "" { 
		if "`r(vecmean)'" == "" { 
			di as err ///
			"no centre specified and no vector mean available"
			exit 198 
		} 
		else local centre = r(vecmean) 
	} 	

	quietly {
		gen `generate' = `varlist' - `centre' `if' `in'
		replace `generate' = `generate' + 360 if `generate' < 0
		replace `generate' = `generate' - 360 if `generate' > 180
		if "`sine'" != "" { 
			replace `generate' = sin((_pi / 360) * `generate') 
		} 	
		
		local Centre = trim("`: di %5.1f `centre''") 
		if "`sine'" != "" local label "sin((`varlist' - `Centre') / 2)" 
		else local label "`varlist' (centred at `Centre')" 
		label var `generate' "`label'" 
	} 	
end
