*! NJC 1.1.0 16 May 2004 
program adjacent 
	version 8 
	syntax varlist(numeric) [aweight fweight] [if] [in] ///
	[ , by(varlist) MISSing ] 

	quietly { 
		marksample touse 

		if "`by'" == "" { 
			tempvar by 
			tempname bylabel 
			gen byte `by' = 1 
			label def `bylabel' 1 `"  "' 
			label val `by' `bylabel' 
		} 
		else { 
			if "`missing'" == "" markout `touse' `by', strok 
		} 	
	
		count if `touse' 
		if r(N) == 0 error 2000 
		
		tempvar group upper lower 
		tempname u l 
		
		gen `upper' = . 
		gen `lower' = .
		label var `upper' "upper adjacent"
		label var `lower' "lower adjacent"
	
		egen `group' = group(`by') if `touse', label `missing' 
		su `group', meanonly 

		if `: word count `varlist'' == 1 | "`bylabel'" != "" { 
			local titleoff "*" 
		} 	
		
		foreach v of local varlist { 		
			if "`bylabel'" != "" label var `group' "`v'" 
			else label var `group' "`by'" 
					
			forval i = 1/`r(max)' { 
				su `v' [`weight' `exp'] if `group' == `i', ///
					detail 
				scalar `u' = r(p75) + (3/2) * (r(p75) - r(p25)) 
				scalar `l' = r(p25) - (3/2) * (r(p75) - r(p25)) 
				su `v' [`weight' `exp'] ///
					if `group' == `i' & `v' <= `u', meanonly  
				replace `upper' = r(max) if `group' == `i' 
				su `v' [`weight' `exp'] ///
					if `group' == `i' & `v' >= `l', meanonly  
				replace `lower' = r(min) if `group' == `i' 
			} 
		
			`titleoff' noi di _n "{title:`v'}" _c 
			noi tabdisp `group' if `touse', c(`lower' `upper')
		} 	
	} 	
end 	
	
