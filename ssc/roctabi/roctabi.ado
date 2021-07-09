*! version 1.0.1 Ariel Linden 13jan2016 //changed rowname and colname to rowlab and collab to represent labels instead of var names
*! version 1.0.0 Ariel Linden 04jan2016 

program define roctabi, rclass
        version 11.0

	syntax anything(id="argument numlist") [, ROWlabel(string asis) COLlabel(string asis) *] 

	preserve
	clear
	
	tokenize `anything', parse(",\ ")
	
	local r 1 
    local c 1
    local cols .
  
	while (`"`1'"'!="" & `"`1'"'!=",") { 
				if `"`1'"'=="\" {
                        local r = `r' + 1
							* limit to 2 rows
							if `r' > 2 {
							     di in red "only two rows allowed"
                                 exit = 198
							} 
							* end limit to 2 rows		
                        if `cols'==. { 
                                if `c'<=2 { 
                                        di in red "too few columns"
                                        exit = 198
                                }
                                local cols `c'
                        }
                        else {
 							if `c'!=`cols' exit = 198
						}

                        local c 1
                }
                else {
					conf integer num `1'
					if `1'<0 exit = 411
					local n`r'_`c' `1'
					local c = `c' + 1
					}
		mac shift
	}

		if `c'!=`cols' exit = 198 
		local cols = `cols' - 1
		local rows = `r' 

		capture {
			drop _all
			local obs 1 
			set obs 1 
			gen byte row = . 
			gen byte col = . 
			gen long pop = . 
			local r 1 
				while (`r'<=`rows') { 
					local c 1
					while (`c'<=`cols') { 
						set obs `obs'
						replace row = `r' in l 
						replace col = `c' in l 
						replace pop = `n`r'_`c'' in l 
						local obs = `obs' + 1
						local c = `c' + 1 
					}
					local r = `r' + 1
				}
        }
        if _rc { 
                drop _all
                exit _rc
        }

	quietly {

		expand pop
		drop if !pop 						// drops zero values
		recode row (1=0) (2=1)
		
		if "`rowlabel'" != "" {
			label var row "`rowlabel'" 
		}

		if "`collabel'" != "" {
			label var col "`collabel'" 
		}
	}	
	
	tab row col
	roctab row col, `options'	
		
	
	
	return scalar ub = r(ub)
    return scalar lb = r(lb)
    return scalar se = r(se)
    return scalar area = r(area) 
    return scalar N = r(N)
	return scalar pietra = r(pietra)
	return scalar gini = r(gini)
		
end
