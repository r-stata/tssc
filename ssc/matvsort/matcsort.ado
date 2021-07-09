*! 1.0.0 NJC 18 Dec 2003 
program matcsort 
        version 8.0
	gettoken A 0 : 0, parse(" ") 
	gettoken B 0 : 0, parse(" ,") 
	syntax [ , DECrease ] 
	
	confirm matrix `A'
	local nr = rowsof(matrix(`A')) 

	// one row: nothing to do except copy 
	if `nr' == 1 { 
		matrix `B' = `A' 
		exit 0 
	} 	

	local nc = colsof(matrix(`A'))  

	tempname C 
	mat `C' = J(`nr', `nc', 1) 
	
	forval j = 1/`nc' {
		local vals
		
		forval i = 1/`nr' { 
			local vals "`vals' `=`A'[`i', `j']'"  
		} 
		
		numlist "`vals'", sort 
		tokenize `r(numlist)' 

		forval i = 1/`nr' { 
			mat `C'[`i',`j'] = ///
			cond("`decrease'" != "", ``=`nr' - `i' + 1'', ``i'') 
		}	
	}
	
	mat `B' = `C'    
	mat colnames `B' = `: colfullnames(`A')' 
end

