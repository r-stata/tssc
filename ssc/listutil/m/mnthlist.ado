program def mnthlist, rclass
*! NJC 1.0.0 9 January 2001
	version 6.0 
	#delimit ; 
	syntax , [ Global(str) Noisily Caplc Uppercase Long 
	Number(int 12) Begin(str) Step(numlist int max=1 >=1)
	Year(numlist int max=1 >100 <10000) ] ; 
	#delimit cr 
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	if "`caplc'" != "" & "`uppercase'" != "" { 
		di in r "must choose between cap/lc and uppercase" 
		exit 198 
	} 	

	if "`begin'" == "" { 
		local begin 1 
	} 
	else { 
		capture confirm integer number `begin' 
		if _rc == 0 { 
			if `begin' < 1 | `begin' > 12 { 
				di in r "invalid begin( ) option" 
				exit 198 
			} 
		} 
		else {  /* grind through possible abbreviations */ 
			local b = lower(trim("`begin'")) 
			if substr("`b'",1,2) == "ja" { 
				local begin 1 
			} 
			else if substr("`b'",1,1) == "f" { 
				local begin 2 
			} 
			else if substr("`b'",1,3) == "mar" { 
				local begin 3 
			} 
			else if substr("`b'",1,2) == "ap" { 
				local begin 4 
			} 
			else if substr("`b'",1,3) == "may" {
				local begin 5 
			} 
			else if substr("`b'",1,3) == "jun" { 
				local begin 6 
			} 
			else if substr("`b'",1,3) == "jul" { 
				local begin 7 
			} 
			else if substr("`b'",1,2) == "au" { 
				local begin 8 
			} 
			else if substr("`b'",1,1) == "s" { 
				local begin 9 
			} 
			else if substr("`b'",1,1) == "o" { 
				local begin 10 
			} 
			else if substr("`b'",1,1) == "n" { 
				local begin 11 
			} 
			else if substr("`b'",1,1) == "d" { 
				local begin 12 
			} 
			else { 
				di in r "invalid begin( ) option" 
				exit 198 
			} 
		}
	}	
			
	if "`step'" == "" { local step = 1 } 

	* upper( ) and lower( ) won't take strings >80 chars
	if "`long'" != "" { 
		local m1 "January February March April May June"
		local m2 "July August September October November December" 
	} 
	else { 
		local m1 "Jan Feb Mar Apr May Jun"
		local m2 "Jul Aug Sep Oct Nov Dec" 
	} 	

	if "`caplc'" == "" { 
		local m1 = lower("`m1'") 
		local m2 = lower("`m2'") 
	} 	
	
	if "`uppercase'" != "" { 
		local m1 = upper("`m1'")
		local m2 = upper("`m2'")
	}

	local m "`m1' `m2'" 
	local i = 1 
	local j = `begin' 
	if "`year'" != "" { 
		local y = `year' + (`begin' - 0.5) / 12 
	} 	
	
	while `i' <= `number' {
		local mnth : word `j' of `m' 
		local newlist "`newlist'`mnth'`year' " 
		local j = mod(`j' + `step', 12) 
		local j = cond(`j' == 0, 12, `j')
		
		if "`year'" != "" { 
			local y = `y' + `step' / 12 
			local year = int(`y') 
		} 
		
		local i = `i' + 1 
	} 	
		
	if "`noisily'" != "" { di "`newlist'" } 	
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist' 
end 

