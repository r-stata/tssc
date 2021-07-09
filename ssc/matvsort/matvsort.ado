*! 1.2.0 NJC 18 Dec 2003 
* 1.1.0 NJC 20 April 2000 
* 1.0.0 NJC 13 April 2000 
program matvsort, sortpreserve 
        version 8.0
	gettoken A 0 : 0, parse(" ") 
	gettoken B 0 : 0, parse(" ,") 
	syntax [ , DECrease ] 
	
	confirm matrix `A'
	
	local nr = rowsof(matrix(`A'))  
	local nc = colsof(matrix(`A'))  

	if `nc' > 1 & `nr' > 1 { 
		di as err "`A' not a vector"
		exit 498 
	}

	local nvals = max(`nr', `nc') 

	if `nvals' > _N { 
		di as err "number of observations too small: set obs `nvals'" 
		exit 198 
	}	

	tempvar values names 	
	tempname C val 

	qui { 
		gen double `values' = . 
		gen str1 `names' = "" 
		mat `C' = J(`nr', `nc', 0)

		if `nr' == 1 { 
			local Names : colfullnames(`A')
			tokenize `Names' 
			local Row : rowfullnames(`A') 
			forval j = 1/`nc' { 
				replace `values' = `A'[1, `j'] in `j' 
	                        replace `names' = "``j''" in `j'
			} 
		} 	
		else { 
			local Names : rowfullnames(`A') 
			tokenize `Names' 
			local Col : colfullnames(`A') 
			forval i = 1/`nr' { 
				replace `values' = `A'[`i', 1] in `i' 
	                        replace `names' = "``i''" in `i'
			} 
		}
	 
	 	if "`decrease'" != "" replace `values' = -`values' 
		sort `values' 
	 	if "`decrease'" != "" replace `values' = -`values'
		
		local Names
		forval i = 1/`nvals' { 
			local Names "`Names' `=`names'[`i']'" 
		}
		
		local k = 1 
		forval i = 1/`nr'  { 
			forval j = 1/`nc' {
				mat `C'[`i', `j'] = `values'[`k++'] 
			} 
		} 	
	} 
	
	mat `B' = `C'

	if `nr' == 1 { 
		mat colnames `B' = `Names' 
		mat rownames `B' = `Row' 
	}
	else {
		mat rownames `B' = `Names'
		mat colnames `B' = `Col' 
	}	
end

