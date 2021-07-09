program def varflist
*! NJC 1.0.0 3 Feb 2000 
	version 6
	gettoken list 0 : 0, parse(",") 
	if "`list'" == "" | "`list'" == "," { 
		di in r "nothing in list"
		exit 198 
	}	
	syntax , Generate(str) [ Type(str) Global SCalar STring ] 

	confirm new variable `generate' 

	local nopts = ("`global'" != "") + ("`scalar'" != "") 
	if `nopts' == 2 { 
		di in r "must choose between global and scalar" 
		exit 198 
	}	

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
	
	if `nwords' > _N { 
		local n = _N 
		di in r "too many words: `nwords' words, `n' obs" 
		exit 498 
	}

	if "`string'" != "" { 
		if "`type'" == "" { local type "str1" } 
		else if substr("`type'",1,3) != "str" { 
			di in r "string and type(`type') inconsistent""
			exit 109 
		}	
	}
	else if substr("`type'",1,3) == "str" { 
		local string "string" 
	}
	
	tokenize `list'
	tempvar g 

	if "`string'" != "" { 
		qui gen `type' `g' = ""
		local i = 1 
		qui while `i' <= `nwords' { 
			if "`global'`scalar'" == "" { 
				replace `g' = "``i''" in `i' 
			} 	
			else if "`global'" != "" { 
				replace `g' = "$``i''" in `i'
			} 
			else if "`scalar'" != "" { 
				local sval = scalar(``i'') 
				replace `g' = "`sval'" in `i' 
			} 	
			local i = `i' + 1 
		}	
	} 
	else { 
		qui gen `type' `g' = .
		local i = 1 
		qui while `i' <= `nwords' { 
			if "`global'`scalar'" == "" { 
				replace `g' = ``i'' in `i' 
			} 	
			else if "`global'" != "" { 
				replace `g' = $``i'' in `i'
			} 
			else if "`scalar'" != "" { 
				local sval = scalar(``i'') 
				replace `g' = `sval' in `i' 
			} 	
			local i = `i' + 1 
		}
	} 	

	* only generate new variable if all assignments OK
	local type : type `g' 
	gen `type' `generate' = `g' 
end 
