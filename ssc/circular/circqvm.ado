*! NJC 1.1.3 10 May 2004 
* NJC 1.1.2 3 May 2004 
* NJC 1.1.1 21 April 2004 
* NJC 1.1.0 15 April 2004 
* NJC 1.0.0 20 January 2004 
program circqvm, sort 
	version 8 
	syntax varname [if] [in] [, Tol(passthru) log show(numlist) ///
	plot(str asis) *  ]  
	marksample touse
	qui count if `touse' 
	if r(N) == 0 exit 2000
	
	tempvar centred vonmises 
	tempname vecmean kappa 
	
	qui circvm `varlist' if `touse' 
	local vecmean = r(vecmean)
	local kappa = r(kappa) 
	local N = r(N) 
	local vtxt : di %2.1f `vecmean' 
	local ktxt : di %4.3f `kappa'
	
	circcentre `varlist' if `touse', gen(`centred') c(`vecmean')
	gsort -`touse' `centred'
	egen `vonmises' = invvm((_n - 0.5) / `N') if `touse', /// 
		k(`kappa') `tol' `log'  
	local yti `"ytitle("`varlist', centred on `vtxt'`=char(176)'")"' 
	label var `vonmises' "von Mises, mu `vtxt'`=char(176)' kappa `ktxt'"

	// labels in terms of `varlist' 
	if "`show'" != "" { 
		foreach s of local show { 
			local val = `s' - `vecmean'  
			if `val' > 180 local val = `val' - 360 
			if `val' < -180 local val = `val' + 360 
			local label `"`label' `val' "`s'""' 
		}
	} 	
	else {
		// default 
		su `centred' if `touse', meanonly
		local range = r(max) - r(min)
		local min = mod(360 + `vecmean' + r(min), 360) 
		local max = mod(360 + `vecmean' + r(max), 360) 

		if `range' > 45 numlist "0(45)315"
		else if `range' > 20 numlist "0(10)350"  
		else numlist "0(5)355" 
		local show "`r(numlist)'"
	 
		// we guess that if the vector mean is in S half of compass,  
		// then the usual min and max define the range;  
		if `vecmean' > 90 & `vecmean' < 270 { 
			su `varlist' if `touse', meanonly 
			foreach s of local show { 
				if `s' >= `r(min)' & `s' <= `r(max)' { 
					local val = `s' - `vecmean'  
					if `val' > 180 local val = `val' - 360 
					if `val' < -180 local val = `val' + 360 
					local label `"`label' `val' "`s'""' 
				}
			} 	
		} 
		// otherwise, use the `min' and `max' calculated earlier  
		else { 
			foreach s of local show { 
				if `s' > `min' | `s' <= `max' { 
					local val = `s' - `vecmean'  
					if `val' > 180 local val = `val' - 360 
					if `val' < -180 local val = `val' + 360 
					local label `"`label' `val' "`s'""' 
				}
			} 	
		} 	
	} 	

	twoway scatter `centred' `vonmises' `vonmises', /// 
	`yti' xli(0) yli(0) c(. l) ms(oh none) legend(off) ///
	xla(`label') yla(`label', ang(h)) `options' /// 
	|| `plot'				
	// blank

end 
