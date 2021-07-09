program def choplist, rclass
*! NJC 1.4.0 13 December 2000 
* NJC 1.3.0 29 June 2000 
* NJC 1.2.0 7 June 2000 
* NJC 1.1.0 22 Dec 1999 
* NJC 1.0.0 20 Dec 1999 after discussion with Kit Baum  	
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	syntax , [ Pos(str) Value(str asis) Length(str) Char(int 0) /* 
	*/ Noisily Global(str) ]

	if "`global'" != "" { 
		tokenize `global' 
		args global1 global2 global3 
		if "`global3'" != "" { 
			di in r "global( ) must contain at most 2 names"
			exit 198 
		} 
		if (length("`global1'") > 8) | (length("`global2'") > 8)  { 
			di in r "global name must be <=8 characters" 
			exit 198 
		} 	
	} 	

	local nopts = /* 
        */ ("`pos'" != "") + (`"`value'"' != "") + /* 
	*/ ("`length'" != "") + (`char' != 0) 
	if `nopts' != 1 { 
		di in r "must specify pos( ), value( ), length( ) or char( )" 
		exit 198 
	}
	
 	* as string <= contains quote 
	local asstr = index(`"`value'"', `"""') 

	tokenize `list'
	local n : word count `list'
	
	if "`length'" != "" | `char' != 0 { 
		local i = 1 
		while `i' <= `n' { 	
			local len = length("``i''") 
			if `len' > 80 { 
				di in r "cannot handle word length > 80"
				exit 498 
			}
			local i = `i' + 1 
		}	
	}	

	local i = 1 
	if "`pos'" != "" {
		local negsign = index("`pos'", "-") 
		if `negsign' { 
			local pos1 = substr("`pos'",1,`negsign' - 1) 
			local pos2 = substr("`pos'",`negsign', .) 
			local pos2 = `n' + 1 + `pos2' 
			local pos "`pos1'`pos2'" 
			capture confirm integer number `pos' 
			if _rc == 0 { local pos ">= `pos'" } 
		} 	
		else { 
			capture confirm integer number `pos' 
			if _rc == 0 { local pos "<= `pos'" }
		} 	
		while `i' <= `n' { 
			if `i' `pos' { local list1 "`list1' ``i''" }
			else local list2 "`list2' ``i''" 
			local i = `i' + 1 
		}
	} 
	else if "`value'" != "" { 
		capture confirm number `value' 
		if _rc == 0 { local value "<= `value'" }  
		if `asstr' { 
			while `i' <= `n' {
				if "``i''" `value' { 
					local list1 `"`list1' ``i''"' 
				}
				else local list2 `"`list2' ``i''"' 
				local i = `i' + 1 
			}
		}	
		else { 
			while `i' <= `n' { 
				if ``i'' `value' { 
					local list1 "`list1' ``i''" 
				}
				else local list2 "`list2' ``i''" 
				local i = `i' + 1
			}
		}	
	} 		
	else if "`length'" != "" { 
		capture confirm number `length' 
		if _rc == 0 { local length "<= `length'" }  
		while `i' <= `n' { 
			if length("``i''") `length' { 
				local list1 "`list1' ``i''" 
			}
			else local list2 "`list2' ``i''" 
			local i = `i' + 1
		}
	} 	
	else { 
		if `char' >= 0 { 
			while `i' <= `n' { 
				local one = substr("``i''",1,`char')
				local two = substr("``i''",`char'+1,.) 
				local list1 "`list1' `one'" 
				local list2 "`list2' `two'" 
				local i = `i' + 1 
			} 
		} 
		else if `char' < 0 { 
			while `i' <= `n' { 
				local one = substr("``i''",`char',.)
				local ltwo = length("``i''") + `char' 
				local two = substr("``i''",1,`ltwo') 
				local list1 "`list1' `one'" 
				local list2 "`list2' `two'" 
				local i = `i' + 1 
			}
		}
	}
	
	if "`noisily'" != "" { 
		di in g "list 1: " in y `"`list1'"' 
		di in g "list 2: " in y `"`list2'"' 
	}
	if "`global1'" != "" { global `global1' `"`list1'"' } 
	if "`global2'" != "" { global `global2' `"`list2'"' } 
	return local list1 `"`list1'"'
	return local list2 `"`list2'"'  
end 	
			
