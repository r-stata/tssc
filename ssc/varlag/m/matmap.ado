program define matmap 
*! 1.0.0  NJC 23 August 2000
	version 6.0
	gettoken A 0 : 0
	gettoken B 0 : 0, parse(" ,") 
	syntax , Map(str) [ Symbol(str) ]

	if "`symbol'" == "" { local symbol "@" } 

	if !index("`map'","`symbol'") { 
		di in r "map( ) does not contain `symbol'" 
		exit 198 
	} 	
	
	local nr = rowsof(matrix(`A'))
	local nc = colsof(matrix(`A'))
	
	tempname C val 
	mat `C' = `A'  

	local i 1
	while `i' <= `nr' {
        	local j 1
		while `j' <= `nc' {
			local exp : /* 
			*/ subinstr local map "`symbol'" "`A'[`i',`j']", all 
			scalar `val' = `exp' 
			if `val' == . {
				di in r "matrix would have missing values"
				exit 504
		        }
			mat `C'[`i',`j'] = `val' 
		        local j = `j' + 1
	        }
	        local i = `i' + 1
	}

	mat `B' = `C' /* allows overwriting of either `A' or `B' */
end
