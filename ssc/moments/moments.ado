*! 1.1.0 NJC 27 September 2004
* 1.0.0 NJC 13 September 2004
program moments, byable(recall)   
        version 8.2
        syntax [varlist] [if] [in] [aweight fweight] /// 
        [, Matname(str) Format(str) ALLobs variablenames by(varlist) * ]

	qui { 
		ds `varlist', has(type numeric) 
		local varlist "`r(varlist)'" 

		if "`allobs'" != "" marksample touse, novarlist 
		else marksample touse 

		count if `touse' 
		if r(N) == 0 error 2000 

        	local ng : word count `varlist'
	
		if "`by'" != "" { 
			if `ng' > 1 { 
				di as err ///
				"by() cannot be combined with `ng' variables"
				exit 198 
			}
			tempvar group 
			egen `group' = group(`by') if `touse', label 
			su `group', meanonly  
			local ng = r(max) 
		} 	
		else tokenize `varlist' 

	        if `ng' > _N {
        	        preserve 
                	set obs `ng'
	        }

        	tempvar a id n mean SD skewness kurtosis which
	        tempname mylbl 

                gen long `which' = _n
                compress `which'
                
		gen `n' = "" 
		label var `n' "n" 
		
		foreach s in mean SD skewness kurtosis { 
			gen double ``s'' = . 
                	label var ``s'' "`s'"
		} 	

	        if "`matname'" != ""  mat `matname' = J(`ng',5,0) 

        	forval i = 1/`ng' {
			if "`by'" != "" { 
				su `varlist' [`weight' `exp'] ///
				if `touse' & `group' == `i', detail 
			} 	
			else    su ``i'' if `touse' [`weight' `exp'], detail 
		
        	        replace `n' = string(r(N)) in `i'
                	replace `mean' = r(mean) in `i'
	                replace `SD' = r(sd) in `i'
        	        replace `skewness' = r(skewness) in `i'
                	replace `kurtosis' = r(kurtosis) in `i'

	                if "`matname'" != "" {
				mat `matname'[`i',1] = r(N)
				mat `matname'[`i',2] = r(mean)
				mat `matname'[`i',3] = r(sd) 
				mat `matname'[`i',4] = r(skewness)
				mat `matname'[`i',5] = r(kurtosis) 
                	}

			if "`by'" != "" { 
				local V = trim(`"`: label (`group') `i''"')
				local rownames `"`rownames' `"`V'"'"' 
			}
			else {
				local V = trim(`"`: variable label ``i'''"')  
				if "`variablenames'" != "" | `"`V'"' == "" { 
					local V "``i''" 
				} 	
			}	
			label def `mylbl' `i' `"`V'"', modify 
		}

	        if "`matname'" != "" {
        	        mat colnames `matname' = n mean SD skewness kurtosis
			if "`by'" != "" { 
				capture mat rownames `matname' = `rownames' 
				if _rc { 
					numlist "1/`ng'" 
					mat rownames `matname' = `r(numlist)' 
				}
			}	
        	        else mat rownames `matname' = `varlist' 
	        }

        	label val `which' `mylbl'
		if "`by'" != "" label var `which' "Group" 
		else if "`allobs'" != "" label var `which' "Variable" 
	        else label var `which' "n = `r(N)'"

        	local fmt "format(%9.3f)"
		if "`format'" != "" { 
			tokenize `format' 
		
			if "`4'" != "" { 
				tempvar skurtosis 
				gen `skurtosis' = string(`kurtosis', "`4'") 
				label var `skurtosis' "kurtosis" 
				local kurtosis "`skurtosis'" 
			} 	
		
			if "`3'" != "" { 
				tempvar sskewness 
				gen `sskewness' = string(`skewness', "`3'") 
				label var `sskewness' "skewness" 
				local skewness "`skewness'" 
			} 	
		
			if "`2'" != "" { 
				tempvar sSD 
				gen `sSD' = string(`SD', "`2'") 
				label var `sSD' "SD" 
				local SD "`sSD'" 
			} 
		
			tempvar smean 
			gen `smean' = string(`mean', "`1'") 
			label var `smean' "mean" 
			local mean "`smean'" 
		} 	
		
		if "`allobs'`by'" != "" local shown "`n'" 
	}	
        	
	tabdisp `which' if `which' <= `ng', ///
        c(`shown' `mean' `SD' `skewness' `kurtosis') `options' `fmt'
       
end
