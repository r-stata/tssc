*Adopted from Dr. Nicholas J. Cox's code for moments.ado
*5.0: 03 Jan 2019
program mads, byable(recall)   
        version 8.2
        syntax [varlist] [if] [in] [aweight fweight] /// 
        [, Matname(str) Format(str) ALLobs variablenames by(varlist) * ]

	qui { 
		ds `varlist', has(type numeric) /*varlist has vlues of the first case here*/
		local varlist "`r(varlist)'" 

		if "`allobs'" != "" marksample touse, novarlist 
		else marksample touse 
        		 
		count if `touse' 
		if r(N) == 0 error 2000 
		/*r(N) will change with "if" and "n"*/
        local ngrps : word count `varlist' /*ngrps here is number of variables*/
	
		if "`by'" != "" { 
			if `ngrps' > 1 { /*ngrps here is number of variables*/
				di as err ///
				"by() cannot be combined with `ngrps' variables"
				exit 198 
			}
			tempvar group 
			egen `group' = group(`by') if `touse', label 
			su `group', meanonly  
			local ngrps = r(max) /*ngrps here becomes number of by groups*/		
		} 	
		else tokenize `varlist' 
			
	        if `ngrps' > _N { /*ngrps here is number of variables*/
        	        preserve 
                	set obs `ngrps'
	        }

        	tempvar a id n mean SD median mad which
	        tempname mylbl 

                gen long `which' = _n
                compress `which'
				gen `n' = "" 
				label var `n' "n" 		
		
		foreach s in mean SD median mad { 
			gen double ``s'' = . 
                	label var ``s'' "`s'"
		} 	
			
	        if "`matname'" != ""  mat `matname' = J(`ngrps',5,0) 
				
        	forval i = 1/`ngrps' {
			if "`by'" != "" { 
				su `varlist' [`weight' `exp'] ///
				if `touse' & `group' == `i', detail 	
				
				/*r(N) for foreign == 0 in auto.dta, it is 52*/
				
				  global gillN = r(N)
				  
				  tempvar devi 
				  ge `devi' = abs(`varlist' - r(p50)) if `touse' & `group' == `i' 
				  su `devi', de	
				  global gillmad = round((r(p50) * 1.4826), .001)
				
				 su `varlist' [`weight' `exp'] ///
				 if `touse' & `group' == `i', detail /* get the returns back */
			} 	
			else   { 
						su ``i'' if `touse' [`weight' `exp'], detail
						/*r(N) here is the whole sample without if*/
						/*otherwise it is decided by if, in condition*/			
						
						    global gillN = r(N)

						    tempvar devi 
						    ge `devi' = abs(``i'' - r(p50)) if `touse'
						    su `devi', de	
						    global gillmad = round((r(p50) * 1.4826), .001)
							
			            su ``i'' if `touse' [`weight' `exp'], detail /* get the returns back */
					}
				
						replace `n' = string(r(N)) in `i'
						replace `mean' = r(mean) in `i'
						replace `SD' = r(sd) in `i'
						replace `median' = r(p50) in `i'
						replace `mad' = $gillmad in `i'
							
					
	                if "`matname'" != "" {

				mat `matname'[`i',1] = r(N)
				mat `matname'[`i',2] = r(mean)
				mat `matname'[`i',3] = r(sd) 
				mat `matname'[`i',4] = r(p50)
				mat `matname'[`i',5] = `mad' 
				
                	}
			if "`by'" != "" { 
				local V = trim(`"`: label (`group') `i''"')
				local rownames `"`rownames' `"`V'"'"' 
				display _newline(2) "rownames = "`rownames'""
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
        	        mat colnames `matname' = n mean SD median mad
			if "`by'" != "" { 
				capture mat rownames `matname' = `rownames' 
				if _rc { 
					numlist "1/`ngrps'" 
					mat rownames `matname' = `r(numlist)' 
				}
			}	
        	        else mat rownames `matname' = `varlist' 
	        }

        	label val `which' `mylbl'
		if "`by'" != "" label var `which' "Group" 
		else if "`allobs'" != "" label var `which' "Variable" 
	        else label var `which' "n = $gillN"

        	local fmt "format(%9.3f)"
		
		if "`format'" != "" { 
			tokenize `format' 
		
			if "`4'" != "" { 
				tempvar smad 
				gen `smad' = string(`mad', "`4'") 
				label var `smad' "mad" 
				local mad "`smad'" 
			} 	
		
			if "`3'" != "" { 
				tempvar smean 
				gen `smean' = string(`mean', "`3'") 
				label var `smean' "mean" 
				local mean "`mean'" 
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
        	
	tabdisp `which' if `which' <= `ngrps', ///
        c(`shown' `mean' `SD' `median' `mad') `options' `fmt'
       
end
