*! 1.0.0 NJC 18 Dec 2003 
program matrsort 
        version 8.0
	gettoken A 0 : 0, parse(" ") 
	gettoken B 0 : 0, parse(" ,") 
	syntax [ , DECrease ] 
	
	confirm matrix `A'
	local nc = colsof(matrix(`A')) 

	// one column: nothing to do except copy 
	if `nc' == 1 { 
		matrix `B' = `A' 
		exit 0 
	} 	

	local nr = rowsof(matrix(`A'))  

	tempname C 
	mat `C' = J(`nr', `nc', 1) 
	
	forval i = 1/`nr' {
		local vals
		
		forval j = 1/`nc' { 
			local vals "`vals' `=`A'[`i', `j']'"  
		} 
	
		numlist "`vals'", sort 
		tokenize `r(numlist)' 

		forval j = 1/`nc' { 
			mat `C'[`i',`j'] = ///
			cond("`decrease'" != "", ``=`nc' - `j' + 1'', ``j'') 
		}	
	}
	
	mat `B' = `C'    
	mat rownames `B' = `: rowfullnames(`A')' 
end

