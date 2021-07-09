program define lablog  
*! NJC 1.0.0 6 April 2000 
	version 6 
	gettoken vallbl 0 : 0, parse(" ,") 

	if "`vallbl'" == "," { error 198 }  
	
	syntax , Values(numlist min=1 int) [ Max(int 7) List ]

	local nvals : word count `values' 
	tokenize `values' 
	
	local i = 1 
	while `i' <= `nvals' {
		if ``i'' <= -`max' | ``i'' >= `max' { 
			local l`i' "10^``i''" 
		} 
		else { 
			local w = abs(``i'') + 1 
			local d = `w' - 1 
			local format = cond(``i'' >= 0,"%`w'.0f","%`w'.`d'f")  
			local l`i' : di `format' 10^``i'' 
		} 	
		local args `"`args' ``i'' "`l`i''""'  
		local i = `i' + 1
	} 

	di _n `"label def `vallbl' `args', modify"' 
	label def `vallbl' `args', modify  
	
	if "`list'" != "" {
		di 
		label li `vallbl' 
	} 
end 

