*! Version 1.0.2 Timothy Mak, Jan 2014
program define matamatrix

	version 10
	gettoken left right : 0 , parse("=")
	if `"`right'"' == "" {
		local right "=`left'"
		local left
	}
	
	if substr("`right'",1,1) == "=" local right : subinstr local right "=" "= " 
	
	local expression_check `"`right'"'
	local expression `"`expression_check'"'
	
	// Check for temp matrices
	local hastempmat = regexm("`expression_check'", "[] \-\+\*\(\)\^\|\[\\&=<>/:!#,@;']__[0-9]+")
	if `hastempmat' {
		local name = regexs(0)
		local firstchar = substr(regexs(0),1,1)
		if "`firstchar'" == "" local macro `name'
		else local macro : subinstr local name "`firstchar'" ""
		di as err "We can't handle matrix names like `name'. Can you rename it?"
		exit 111
	}

	// Rename e(), r() matrices
	local i = 0
	foreach type in r e {
		local search = 1
		while `search' == 1 {
			local hasmatrix = regexm("`expression_check'", "[] \-\+\*\(\)\^\|\[\\&=<>/:!#,@;']`type'\([a-zA-Z0-9_]+\)")
			if `hasmatrix' {
				local match = regexs(0)
				local firstchar = substr(regexs(0),1,1)
				if "`firstchar'" == "" local macro `match'
				else local macro : subinstr local match "`firstchar'" ""

				capture confirm matrix `macro'
				if _rc == 0 {
					tempname macro`i' 
					matrix `macro`i'' = `macro'
					mata: `macro`i'' = st_matrix("`macro`i''")
					local list_of_macro `list_of_macro' `macro`i''
					local expression : subinstr local expression "`match'" "`firstchar'`macro`i''"
					local i = `i' + 1
				}
				local expression_check : subinstr local expression_check "`match'" ""
			}
			else local search = 0
		}
	}
	
	// Remove all non-name characters, e.g. + - 
	local expression2 `"`expression'"'
	foreach char in + - * / # ! = @ ' ^ & ( ) [ ] | \ : ; < > , {
		local expression2 : subinstr local expression2 "`char'" " ", all
	}
	
	// Sort `expression2' in order of size :- create `expression3' 
	local ntocheck : word count `expression2'
	tempname forsort
	mata: `forsort' = J(`ntocheck', 2, .)
	forval i=1/`ntocheck' {
		local tocheck : word `i' of `expression2' 
		local length = length("`tocheck'")
		mata: `forsort'[`i',1] = `i'; `forsort'[`i',2] = -`length'; 
	}
	mata: _sort(`forsort',2) ; st_matrix("`forsort'", `forsort'); 
	
	forval i=1/`ntocheck' {
		local wordtoadd : word `=`forsort'[`i',1]' of `expression2'
		local expression3 `expression3' `wordtoadd'
	}
	
	tokenize `expression3'
	// Earmark all the functions
	local j = 1
	while "``j''" != "" {
		if regexm("``j''", "^[0-9]+") == 0 {
			local expression : subinstr local expression "``j''(" "###`j'(" , all 
		}
		local j = `j' + 1
	}

	// change matrix names to tempnames
	// Warning: If your matrix names bears similarity to tempnames but are shorter than tempnames, there may be problems... 
	local j = 1
	while "``j''" != "" {
		if regexm("``j''", "^[0-9]+") == 0 {

			tempname macro`i'
			local expression : subinstr local expression "``j''" "`macro`i''" , all count(local count1)
			if `count1' > 0 {
				matrix `macro`i'' = ``j''
				// matrix list `macro`i''
				mata: `macro`i'' = st_matrix("`macro`i''")
				// mata: `macro`i''
				local list_of_macro `list_of_macro' `macro`i''
			}
			local i = `i' + 1
		}
		local j = `j' + 1
	}
	
	// Rename the functions 
	local j = 1
	while "``j''" != "" {
		if regexm("``j''", "^[0-9]+") == 0 {
			local expression : subinstr local expression "###`j'(" "``j''(" , all 
		}
		local j = `j' + 1
	}
	
	tempname macro`i'
	mata: `macro`i'' `expression' ; st_matrix("`macro`i''", `macro`i'') 
	mata: mata drop `list_of_macro' `macro`i'' `forsort'
	
	if "`left'" == "" {
		matrix list `macro`i''
	}
	else {
		matrix `left' = `macro`i''
	}

end

	
	
		
	
	
