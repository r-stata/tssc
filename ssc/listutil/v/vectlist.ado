*! NJC 1.1.0 7 June 2000 
* NJC 1.0.0 25 Jan 2000 
program define vectlist, rclass 
        version 6.0
	gettoken A 0 : 0, parse(" ,") 
	
	capture local nc = colsof(matrix(`A'))
        if _rc {
                di in r "matrix `A' not found"
                exit 111
        }
	
	local nr = rowsof(matrix(`A'))  

	if `nc' > 1 & `nr' > 1 { 
		di in r "`A' not a vector"
		exit 498 
	}	

	syntax [ , Noisily Global(str) ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	local isrow = `nr' == 1 
	local i = 1 		
			
	if `isrow' { 
		while `i' <= `nc' {
			local val = `A'[1, `i'] 
			local newlist "`newlist'`val' " 
			local i = `i' + 1
		}	
	} 
	else { 
		while `i' <= `nr' { 
			local val = `A'[`i', 1] 
			local newlist "`newlist'`val' " 
			local i = `i' + 1
		}
	}

	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list "`newlist'"  
end

