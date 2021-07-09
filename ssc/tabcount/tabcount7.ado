*! was -tabcount-; renamed NJC 18 June 2003
*! NJC 1.0.0 3 Nov 2002 
program def tabcount7, byable(recall)  
	version 7 
	syntax varname [if] [in] , Values(str asis) 
	
	marksample touse, strok  
	tempvar Values Freq SFreq Percent Cum 
	qui gen long `Freq' = . 
	qui gen str1 `SFreq' = "" 
	
	capture numlist "`values'" 

	* string values 
	qui if _rc { 
		gen str1 `Values' = "" 
		tokenize `"`values'"' 
		local nvals : word count `values' 

		forval i = 1 / `nvals' { 
			replace `Values' = `"``i''"' in `i' 
			count if `touse' & `varlist' == `"``i''"' 
			replace `Freq' = r(N) in `i' 
		}
	} 	
	
	* numeric values 
	else qui { 
		gen `Values' = .
		tokenize `r(numlist)' 
		local nvals : word count `r(numlist)' 
		forval i = 1 / `nvals' { 
			replace `Values' = ``i'' in `i' 
			count if `touse' & `varlist' == ``i''
			replace `Freq' = r(N) in `i' 
		}
	} 
	
	qui { 
		su `Freq', meanonly 
		gen `Percent' = 100 * `Freq' / r(sum)
		gen `Cum' = sum(`Percent') in 1 / `nvals' 
		local nvalsp1 = `nvals' + 1 
		replace `Freq' = r(sum) in `nvalsp1'
		replace `Percent' = 100 in `nvalsp1' 
		replace `SFreq' = string(`Freq') 
	}	

	_crcslbl `Values' `varlist' 
	local vallbl : value label `varlist' 
	if "`vallbl'" != "" { 
		label val `Values' `vallbl' 
	} 	

	label var `SFreq' "Freq." 
	label var `Percent' "Percent" 
	label var `Cum' "Cum." 
	
	tabdisp `Values' in 1 / `nvalsp1', /* 
	*/ cell(`SFreq' `Percent' `Cum') format(%3.2f) total
	
end 
		
