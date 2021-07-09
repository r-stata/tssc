program def inslist, rclass
*! NJC 1.1.0 14 December 2000 
* NJC 1.0.0 7 November 2000 
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}

	local nlist : word count `list' 
	
	syntax , Insert(string) Pos(numlist sort int >=-`nlist' <=`nlist') /* 
	*/ [ Global(str) Noisily ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	}
	
	local np1 = `nlist' + 1 
	tknz `pos' `np1', s(p)  
	local np : word count `pos' 
	
	* negative indexes to positive 
	local i = 1 
	while `p`i'' < 0 { 
		local p`i' = `nlist' + 1 + `p`i'' 
		local i = `i' + 1 
	} 	

	local nins : word count `insert' 
	if `nins' < `np' { 
		local rep = 1 + int( `np' / `nins') 
		local insert : di _dup(`rep') "`insert' "
		local nins : word count `insert' 
	}
	
	tknz `insert', s(i) 
	
	local j = 1 

	while `p`j'' == 0 { 
		local newlist "`newlist'`i`j'' "
		local j = `j' + 1 
	} 	
	
	tokenize `list'

	local i = 1 
	while `i' <= `nlist' {
		local newlist "`newlist'``i'' "
		while `i' == `p`j'' & `j' <= `np' { 
			local newlist "`newlist'`i`j'' "
			local j = `j' + 1  
		}                  
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
	
