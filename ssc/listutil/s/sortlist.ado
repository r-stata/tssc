program def sortlist, rclass
*! NJC 1.2.0 7 June 2000 
* NJC 1.1.0 22 Dec 1999 
* NJC 1.0.0 22 Sept 1999 	
	version 6.0 
	gettoken list 0 : 0, parse(",") 
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list" 
		exit 198 
	}
	syntax [, Noisily Global(str) ]
	
	if length("`global'") > 8 { 
		di in r "global name must be <=8 characters" 
		exit 198 
	} 	

	tokenize `list' 
	local nwords : word count `list' 
	
	if `nwords' > _N { 
		preserve
		clear 
		qui set obs `nwords' 
	}	

	tempvar words miss  
	qui gen str1 `words' = "" 
	 
	local i = 1  
	while `i' <= `nwords' { 
		local len = length("``i''") 
		if `len' > 80 { 
			di in r "cannot handle word length > 80"
			exit 498 
		}	
		qui replace `words' = "``i''" in `i' 
		local i = `i' + 1
	}
	gen byte `miss' = missing(`words') 
	sort `miss' `words' 

	local i = 1 
	while `i' <= `nwords' { 
		local word = `words'[`i'] 
		local newlist "`newlist' `word'"
		local i = `i' + 1 
	}	
	
	if "`noisily'" != "" { di "`newlist'" } 
	if "`global'" != "" { global `global' "`newlist'" } 
	return local list `newlist'
end 	
			
