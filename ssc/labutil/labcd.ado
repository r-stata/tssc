program define labcd  
*! NJC 1.0.0 10 May 2000 
	version 6 
	gettoken vallbl 0 : 0, parse(" ,") 
	if "`vallbl'" == "," { error 198 }  
	
	syntax , Values(numlist min=1) [ List Format(str) Multiply(int 1) ]
	local nvals : word count `values' 
	tokenize `values' 

	capture numlist "`values'", int
	 
	if _rc == 126 { 
		if `multiply' == 1 { 
			di in r "nonintegers present: use multiply( ) option" 
			exit 198 
		}
	}
	
	local values 
	local i = 1 
	while `i' <= `nvals' { 
		local m`i' = `multiply' * ``i'' 
		local values "`values'`mi' " 
		local i = `i' + 1 
	} 
	
	if _rc == 126 { capture numlist "`values'", int } 
	if _rc == 126 { 
		di in r /* 
		*/ "nonintegers present even after multiply( )" 
		exit 126 
	}

	if "`format'" == "" { local format "%12.0gc" } 
	
	local i = 1 
	while `i' <= `nvals' {
		local m : di `format' ``i'' 
		local m : subinstr local m "." "!"
		local m : subinstr local m "," ".", all
		local m : subinstr local m "!" ","
		local m = trim("`m'")
		local m`i' = round(`m`i'',1) 
		local args `"`args' `m`i'' "`m'""' 
		local i = `i' + 1
	} 

	di _n `"label def `vallbl' `args', modify"' 
	label def `vallbl' `args', modify  
	
	if "`list'" != "" {
		di 
		label li `vallbl' 
	} 
end 

