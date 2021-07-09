program def takelist, rclass
*! NJC 1.3.0 14 December 2000 
* NJC 1.2.0 7 June 2000 
* NJC 1.1.0 22 Dec 1999 
* NJC 1.0.0 19 Dec 1999 from a suggestion by Kit Baum  	
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	
	local nlist : word count `list' 

	syntax , [ Pos(numlist int >=-`nlist' <=`nlist') Global(str) Noisily ]

	* blanking this out traps a bug if 0 is included in -pos( )- 
	local 0 

	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	tknz `pos', s(p)  
	local np : word count `pos' 
	
	* negative indexes to positive 
	local i = 1 
	while `i' <= `np' { 
		local p`i' = cond(`p`i'' < 0, `nlist' + 1 + `p`i'', `p`i'') 
		local i = `i' + 1 
	} 	
	
	tokenize `list' 

	local i = 1 
	while `i' <= `np' { 
		local newlist "`newlist'``p`i''' "
		local i = `i' + 1 
	} 
	
	if "`noisily'" != "" { di "`newlist'" }
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 

program def tknz, rclass 
* NJC 1.1.0 2 June 2000 
	version 6.0 
	gettoken list 0 : 0, parse(",") 
	syntax , Stub(str) [ * ] 
	tokenize `"`list'"' , `options'  
		
	local i = 1 	
	while "``i''" != "" { 
		c_local `stub'`i' `"``i''"'  
		local i = `i' + 1 
	} 
end 	
		
