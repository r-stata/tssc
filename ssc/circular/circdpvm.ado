*! NJC 1.0.0 10 June 2004 
program circdpvm, sort 
	version 8 
	syntax varname [if] [in] [, Tol(passthru) log show(numlist) ///
	GENerate(str) param(numlist min=2 max=2) a(real 0.5) ///
	plot(str asis) line(str asis) * ]
	
	if "`generate'" != "" { 
		cap confirm new var `generate' 
		if _rc { 
			di as err "generate() must specify new variables"
			exit _rc 
		} 
		local nvars : word count `generate' 
		if `nvars' != 2 { 
			di as err "generate() must specify two variables"
			exit 198 
		} 
	} 	

	marksample touse
	qui count if `touse' 
	if r(N) == 0 exit 2000
	local N = r(N) 

	tempvar centred x ft fo 

	if "`param'" == "" { 
		tempname vecmean kappa 
		qui circvm `varlist' if `touse' 
		local vecmean = r(vecmean)
		local kappa = r(kappa) 
	} 
	else { 
		tokenize `param' 
		args vecmean kappa 
	} 	
	
	circcentre `varlist' if `touse', gen(`centred') c(`vecmean')
	gsort -`touse' `centred'
	
	egen `ft' = vmden(`centred') if `touse', k(`kappa') m(0)   
	egen `x' = invvm((_n - `a') / (`N' - 2 * `a' + 1)) if `touse', ///
		k(`kappa') `tol' `log'  
	egen `fo' = vmden(`x') if `touse', k(`kappa') m(0)  	
	_crcslbl `centred' `varlist' 
	
	local vtxt : di %2.1f `vecmean' 
	local ktxt : di %4.3f `kappa'
	local ytitle "Probability density" 
	local caption "reference von Mises, mu `vtxt'`=char(176)' kappa `ktxt'"

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
	
	// graph 
	twoway mspline `ft' `centred' if `touse', bands(200) `line' ||    ///   
               scatter `fo' `centred' if `touse', xli(0) xla(`label')     /// 
	       yti("`ytitle'") caption("`caption'", size(medsmall))       ///
               yla(, ang(h)) legend(order(2 1 "`dist'") off) `options' || ///
               `plot'        

	// messages about missing values will be visible 
	if "`generate'" != "" { 
		tokenize `generate' 
		gen `1' = `ft' if `touse' 
		label var `1' "VM density, `varlist' (direct)" 
		gen `2' = `fo' if `touse'
		label var `2' "VM density, `varlist' (indirect)" 
	} 	
       
end 
