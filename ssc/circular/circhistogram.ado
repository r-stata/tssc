*! NJC 2.0.0 1 February 2004 
* NJC 1.5.0 16 December 1998
* NJC 1.4.0 15 May 1997
* NJC 1.3.0 13 May 1997
* NJC 1.2.1 29 October 1996
* histogram for circular data
program circhistogram 
	version 8.0
	syntax varname [if] [in] [fweight] /// 
	[, Pad(real 180) XMIN(real 0) XMAX(real 360) oneway * ] 

	marksample touse
	qui count if `touse' 
	if r(N) == 0 error 2000  
	
	preserve
	qui keep if `touse' 
	local np1 = _N + 1
	qui expand 1 + (`varlist' <= `xmin' + `pad' | `varlist' > `xmax' - `pad')
	qui if _N >= `np1' { /* need to check that expansion took place */
		replace `varlist' = /// 
		cond(`varlist' <= `xmin' + `pad', ///
	`varlist' + `xmax' - `xmin', `varlist' - `xmax' + `xmin') in `np1'/l 
	}
	local xli "xli(`xmin' `xmax')"
	if `xmin' == 0 & `xmax' == 360 {
		local xla `"xla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360")"'
	}

	if "`oneway'" != "" { 
		onewayplot `varlist' [`weight' `exp'], `xli' `xla' `options' 
	}	
	else histogram `varlist' [`weight' `exp'], freq `xli' `xla' `options' 
end
