program def dellist, rclass
*! NJC 1.5.0 14 December 2000 
* NJC 1.4.0 6 Sept 2000 
* NJC 1.3.0 6 June 2000 
* NJC 1.2.0 31 Jan 2000 
* NJC 1.1.0 22 Dec 1999 
* NJC 1.0.0 22 Sept 1999 	
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	
	local nlist : word count `list' 

	syntax , [ Delete(str) Pos(numlist sort int >=-`nlist' <=`nlist') /* 
	*/ Exact All Global(str) Noisily ]

	local nopts = ("`delete'" != "") + ("`pos'" != "") 
	if `nopts' != 1 { 
		di in r "must specify one of delete( ) and pos( )" 
		exit 198 
	} 

	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	
	
	if "`exact'" != "" & "`all'" != ""  { 
		di in r "all option not allowed with exact option" 
		exit 198 
	} 
	
	tokenize `list'

	if "`delete'" != "" { 
		local i = 1 
		while `i' <= `nlist' { 	
			local len = length("``i''") 
			if `len' > 80 { 
				di in r "cannot handle word length > 80"
				exit 498 
			}
			local i = `i' + 1 
		}	
	
		tknz `delete', s(d) 
		local nd : word count `delete' 

		if "`exact'" != "" { 
			while "`1'" != "" { 
				local i = 1 
				local OK = 0 
				while `i' <= `nd' & !`OK' { 
					local OK = "`1'" == "`d`i''" 
					local i = `i' + 1 
				} 	
				if !`OK' { local newlist "`newlist'`1' " } 
				mac shift
			}
		} 
		else { 
			while "`1'" != "" {
				local i = 1 
				local OK = 0 
				while `i' <= `nd' { 
					local thisOK = /* 
					*/ index("`1'", "`d`i''") > 0 
					local OK = `OK' + `thisOK'
					local i = `i' + 1 
				} 	
				if "`all'" != "" { local OK = `OK' == `nd' } 
	 			if !`OK' { local newlist "`newlist'`1' " }
				mac shift
			}
		} 	
	}	
	else { 
		local np1 = `nlist' + 1 
		tknz `pos' `np1', s(p)  
		local np : word count `pos'

		* negative indexes to positive 
		local i = 1 
		while `p`i'' < 0 { 
			local p`i' = `nlist' + 1 + `p`i'' 
			local i = `i' + 1 
		} 	

		local i = 1 
		local j = 1 
		while `i' <= `nlist' { 
			if `i' == `p`j'' { local j = `j' + 1 } 
			else local newlist "`newlist'``i'' "  
			local i = `i' + 1 
		} 	
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
			
