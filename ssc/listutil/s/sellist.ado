program def sellist, rclass
*! NJC 1.5.0 30 November 2000 
* NJC 1.4.0 5 Sept 2000 
* NJC 1.3.0 7 June 2000 
* NJC 1.2.0 31 Jan 2000 
* NJC 1.1.0 22 Dec 1999 
* NJC 1.0.0 22 Sept 1999 	
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	syntax , Select(str) /* 
	*/ [ PREfix SUFfix POSTfix Exact Noisily Global(str) All ] 

	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 
	
	if "`exact'" != "" & "`all'" != ""  { 
		di in r "all option not allowed with exact option" 
		exit 198 
	} 	
		
	if "`postfix'" != "" { local postop "postfix" } 
	else if "`suffix'" != "" { local postop "suffix" } 

	if "`postop'" != "" & "`prefix'" != "" { 
		di in r "choose between `postop' and prefix options" 
		exit 198 
	} 

	if "`postop'`prefix'" != "" & "`exact'`all'" != "" { 
		di in r /* 
	*/ "`postop'`prefix' option not allowed with `exact'`all' option" 
		exit 198 
	} 

	tokenize `list'
	local nwords : word count `list' 
	local i = 1 
	while `i' <= `nwords' { 	
		local len = length("``i''") 
		if `len' > 80 { 
			di in r "cannot handle word length > 80"
			exit 498 
		}
		local i = `i' + 1 
	}

	tknz `select', s(s) 
	local ns : word count `select' 
	
	if "`prefix'`postop'" != "" & `ns' > 1 { 
		di in r /* 
	*/ "select( ) should contain one word with `prefix'`postop' option" 
		exit 198 
	} 	

	if "`exact'" != "" { 
		while "`1'" != "" { 
			local i = 1 
			local OK = 0 
			while `i' <= `ns' & !`OK' { 
				local OK = "`1'" == "`s`i''" 
				local i = `i' + 1 
			} 	
			if `OK' { local newlist "`newlist' `1'" } 
			mac shift
		}
	} 
	else { 
		while "`1'" != "" {
			local i = 1 
			local OK = 0 
			while `i' <= `ns' {
				local spos = /* 
				*/ length("`1'") - length("`s`i''") + 1 
				local where = index("`1'", "`s`i''")
				
				if "`prefix'" != "" { 
					local thisOK = `where' == 1 
				} 
				else if "`postop'" != "" { 
					local thisOK = `where' == `spos' 
				} 	
				else local thisOK = index("`1'", "`s`i''") > 0
				
				local OK = `OK' + `thisOK'
				local i = `i' + 1 
			} 	
			if "`all'" != "" { local OK = `OK' == `ns' } 
	 		if `OK' { local newlist "`newlist' `1'" }
			mac shift
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
			
