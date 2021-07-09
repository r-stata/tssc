program def cvarlist, rclass
*! NJC 1.0.0 18 August 2000 
	version 6.0 
	gettoken list 0 : 0, parse(",")
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	syntax , [ new NUmeric String Noisily Global(str)] 

	local nopts : word count `new' `numeric' `string' 
	if `nopts' > 1 { 
		di in r "use just one of options new, numeric, string"
		exit 198 
	} 
	
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

	tokenize `list'
	local nwords : word count `list' 
	local i = 1 
	while `i' <= `nwords' { 	
		capture confirm `new' `numeric' `string' variable ``i'' 	
		if _rc == 0 { local newlist "`newlist'``i'' " } 
		else local badlist "`badlist'``i'' " 
		local i = `i' + 1 
	} 
	
	if "`noisily'" != "" { 
		if "`newlist'" != "" { 
			di in g "list 1: " in y "`newlist'" 
		} 
		if "`badlist'" != "" { 
			di in g "list 2: " in y "`badlist'" 
		}
	}
	
	if "`global1'" != "" { global `global1' "`newlist'" } 
	if "`global2'" != "" { global `global2' "`badlist'" } 
	return local list1 `newlist'
	return local list2 `badlist' 
end 	
			
