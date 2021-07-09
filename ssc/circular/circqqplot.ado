*! NJC 1.0.0 6 May 2004 
program circqqplot, sort 
	version 8 
	syntax varlist(min=2 max=2) [if] [in] , ///
	[ centre(numlist min=1 max=2) ///
	  center(numlist min=1 max=2) ///
	  yshow(numlist) xshow(numlist) plot(str asis) *  ] 

	if "`center'" != "" & "`centre'" != "" & "`center'" != "`centre'" { 
		di as txt "center, centre: confused?" 
		exit 1776 
	} 

	if "`centre'`center'" == "" { 
		di as err "centre() or center() option required"
		exit 198 
	} 	
	
	marksample touse, novarlist 
	qui count if `touse' 
	if r(N) == 0 exit 2000
	
	tempvar yc xc 
	tokenize `varlist' 
	args y x 
	tokenize `centre' 
	args Yc Xc 
	circcentre `y' if `touse', gen(`yc') c(`Yc')
	if "`Xc'" == "" local Xc `Yc' 
	circcentre `x' if `touse', gen(`xc') c(`Xc')
	
	local yti `"ytitle("`y', centred on `Yc'`=char(176)'")"' 
	local xti `"xtitle("`x', centred on `Xc'`=char(176)'")"' 

	// y axis labels  
	if "`yshow'" != "" { 
		foreach s of local yshow { 
			local yval = `s' - `Yc'  
			if `yval' > 180 local yval = `yval' - 360 
			if `yval' < -180 local yval = `yval' + 360 
			local ylabel `"`ylabel' `yval' "`s'""' 
		}
	} 	
	else {
		// default 
		su `yc' if `touse', meanonly
		local range = r(max) - r(min)
		local min = mod(360 + `Yc' + r(min), 360) 
		local max = mod(360 + `Yc' + r(max), 360) 

		if `range' > 45 numlist "0(45)315"
		else if `range' > 20 numlist "0(10)350"  
		else numlist "0(5)355" 
		local yshow "`r(numlist)'"
	 
		// we guess that if the centre is in S half of compass,  
		// then the usual min and max define the range;  
		if `Yc' > 90 & `Yc' < 270 { 
			su `y' if `touse', meanonly 
			foreach s of local yshow { 
				if `s' >= `r(min)' & `s' <= `r(max)' { 
					local yval = `s' - `Yc'  
					if `yval' > 180 local yval = `yval' - 360 
					if `yval' < -180 local yval = `yval' + 360 
					local ylabel `"`ylabel' `yval' "`s'""' 
				}
			} 	
		} 
		// otherwise, use the `min' and `max' calculated earlier  
		else { 
			foreach s of local yshow { 
				if `s' > `min' | `s' <= `max' { 
					local yval = `s' - `Yc'  
					if `yval' > 180 local yval = `yval' - 360 
					if `yval' < -180 local yval = `yval' + 360 
					local ylabel `"`ylabel' `yval' "`s'""' 
				}
			} 	
		} 	
	} 
	
	// x axis labels  
	if "`xshow'" != "" { 
		foreach s of local xshow { 
			local xval = `s' - `Xc'  
			if `xval' > 180 local xval = `xval' - 360 
			if `xval' < -180 local xval = `xval' + 360 
			local xlabel `"`xlabel' `xval' "`s'""' 
		}
	} 	
	else {
		// default 
		su `xc' if `touse', meanonly
		local range = r(max) - r(min)
		local min = mod(360 + `Xc' + r(min), 360) 
		local max = mod(360 + `Xc' + r(max), 360) 

		if `range' > 45 numlist "0(45)315"
		else if `range' > 20 numlist "0(10)350"  
		else numlist "0(5)355" 
		local xshow "`r(numlist)'"
	 
		// we guess that if the centre is in S half of compass,  
		// then the usual min and max define the range;  
		if `Xc' > 90 & `Xc' < 270 { 
			su `x' if `touse', meanonly 
			foreach s of local xshow { 
				if `s' >= `r(min)' & `s' <= `r(max)' { 
					local xval = `s' - `Xc'  
					if `xval' > 180 local xval = `xval' - 360 
					if `xval' < -180 local xval = `xval' + 360 
					local xlabel `"`xlabel' `xval' "`s'""' 
				}
			} 	
		} 
		// otherwise, use the `min' and `max' calculated earlier  
		else { 
			foreach s of local xshow { 
				if `s' > `min' | `s' <= `max' { 
					local xval = `s' - `Xc'  
					if `xval' > 180 local xval = `xval' - 360 
					if `xval' < -180 local xval = `xval' + 360 
					local xlabel `"`xlabel' `xval' "`s'""' 
				}
			} 	
		} 	
	} 	

	qqplot `yc' `xc', `yti' `xti' xli(0) yli(0) ms(oh none) legend(off) ///
	xla(`xlabel') yla(`ylabel', ang(h)) `plot' `options'
end 
