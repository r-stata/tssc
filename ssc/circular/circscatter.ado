*! NJC 2.0.0 18 January 2004 
* NJC 1.4.1 16 December 1998
* NJC 1.4.0 12 May 1997
* NJC 1.3.1 29 October 1996
* scatter plot for circular data
program circscatter 
	version 8.0
	syntax varlist(numeric) [if] [in] [aweight fweight iweight] ///
	[, Ycirc Xcirc Pad(int 180) plot(str asis) *]

	tokenize `varlist' 
	args yvar 
	local nvars: word count `varlist'
	preserve
	tempvar touse orig
	marksample touse
	qui keep if `touse'
	gen byte `orig' = 1

	qui if "`ycirc'" == "ycirc" {
		local np1 = _N + 1
		expand 1 + (`yvar' <= `pad' | `yvar' > 360 - `pad')
		if _N >= `np1' { /* need to check that expansion took place */
			replace `yvar' = ///
	    	cond(`yvar' <= `pad', `yvar' + 360, `yvar' - 360) in `np1'/l
			replace `orig' = 0 in `np1'/l
		}
		local yla "yla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360")" 
		local yli "yli(0 360)" 
	}

	qui if "`xcirc'" == "xcirc" {
		local np1 = _N + 1
		local xvar ``nvars''
		expand 1 + (`xvar' <= `pad' | `xvar' > 360 - `pad')
		if _N >= `np1' { /* need to check that expansion took place */
			replace `xvar' = ///
		cond(`xvar' <= `pad', `xvar' + 360, `xvar' - 360) in `np1'/l
			replace `orig' = 0 in `np1'/l
		}
		local xla "xla(0 "0" 90 "90" 180 "180" 270 "270" 360 "360")"
		local xli "xli(0 360)" 
	}

	scatter `varlist' [`weight' `exp'], ///
	`yla' `yli' `xla' `xli' `options'   ///
	|| `plot' 
	// blank 
end
