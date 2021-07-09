*! NJC 2.0.0 19 January 2004 
* NJC 1.3.1 1 January 1999
* NJC 1.3.0 16 December 1998
* NJC 1.2.0 15 May 1997
* NJC 1.1.0 30 September 1996
* lowess for circular data
program circxlowess
	version 8.0
	syntax varlist(min=2 max=2) [if] [in] ///
	[, Pad(real 180) XMIN(real 0) XMAX(real 360) *]
	tokenize `varlist'
	args y x 

	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	tempvar expand
	local np1 = _N + 1
	preserve 
	qui expand 1 + (`x' <= `xmin' + `pad' | `x' > `xmax' - `pad')
	gen byte `expand' = _n >= `np1'
	qui if _N >= `np1' { /* need to check that expansion took place */
		replace `x' = /// 
		cond(`x' <= `xmin' + `pad', `x' + `xmax' - `xmin', ///
		                            `x' - `xmax' + `xmin') in `np1'/l 
        }
	if `xmin' == 0 & `xmax' == 360 { 
		local xla `"xla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360")"' 
	} 	
	lowess `varlist' if `touse', `xla' xli(`xmin' `xmax') `options'
end

