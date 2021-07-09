*! 2.1.1 NJC 29 September 2014
*! 2.1.0 NJC 15 November 2007
* 2.0.1 NJC 5 November 2003
* 2.0.0 NJC 3 November 2003
* 1.0.1  NJC 24 April 1998
* 1.0.0  NJC 27 January 1998
program qweibull, sort
	version 8 
	syntax varname(numeric) [fweight aweight/] [if] [in] ///
	[, Grid GENerate(namelist max=1) param(numlist min=2 max=2) show(str) ///
	plot(str asis) addplot(str asis) * ]
	
	_get_gropts , graphopts(`options') getallowed(rlopts)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	_check4gropts rlopts, opt(`rlopts')

	if "`generate'" != "" { 
		capture confirm new var `generate' 
		if _rc { 
			di as err "generate() must name new variable"
			exit 198 
		}
	}
	
	marksample touse
	qui count if `varlist' < 0 & `touse' 
	if r(N) { 
		di " " 
		di as txt "warning: {res:`varlist'} has `r(N)' values < 0; " _c
		di as txt " not used"
		replace `touse' = 0 if `varlist' < 0 
	} 	

	qui count if `touse' 
	if r(N) == 0 error 2000 

	if `"`show'"' != ""  { 
		capture count if `show' 
		if _rc { 
			di as err "invalid show() option"
			exit 198 
		} 
		else { 
			count if (`show') & `touse' 
			if r(N) == 0 error 2000 
		}

		local show "& (`show')" 
	}

	if "`param'" != "" { 
		tokenize `param' 
		args B C 
		if `B' <= 0 | `C' <= 0 { 
			di as err "parameters must both be positive"
			exit 498 
		}	
	} 	
	else { 
		tempname b c  
		if "`exp'" != "" {	
			qui weibullfit `varlist' if `touse' [`weight' = `exp']
		} 
		else qui weibullfit `varlist' if `touse' 
		mat `b' = e(bpar)
		mat `c' = e(cpar)
		local B = `b'[1,1] 
		local C = `c'[1,1] 
	} 
	
	tempvar Z Psubi
	
	quietly {
		if "`exp'" == "" local exp = 1 
		sort `touse' `varlist'
		gen float `Psubi' = sum(`touse' * `exp') - 0.5 * `exp'
		su `touse' [w = `exp'], meanonly 
		replace `Psubi' = `Psubi' / r(sum) if `touse' 
	        gen double `Z' = `B' * (-ln(1 - `Psubi'))^(1 / `C') if `touse' 
		label var `Z' "inverse Weibull"
		local xttl : var label `Z'
		local fmt : format `varlist'
		format `fmt' `Z'
	}
	
	qui if "`grid'" != "" {
		foreach p in 5 10 25 50 75 90 95 { 
			local wq`p' : di %4.3f /*
	                */ `B' * (-ln(1 - `p' / 100))^(1 / `C')
	        }
		
                local xtl "`wq50' `wq5' `wq95'"
                local xn  "`xtl' `wq25' `wq75' `wq10' `wq90'"
		
	        su `varlist' if `touse', detail
                local ytl = string(r(p50)) + " " ///
		          + string(r(p5)) + " " ///
			  + string(r(p95))  
                local yn = "`ytl'" + " " + /// 
                           string(r(p25)) + " " ///
		         + string(r(p75)) + " " /// 
                         + string(r(p10)) + " " ///
		         + string(r(p90)) 
			 
		local yl yaxis(1 2)		///
			ytitle("", 	///
				axis(2)		///
			)			///
			ylabels(`ytl',		///
				nogrid		///
				axis(2)		///
			)			///
			yticks(`yn',		///
				grid		///
				gmin		///
				gmax		///
				axis(2)		///
			)			///
			// blank

		local xl xaxis(1 2)		///
			xtitle("",		///
				axis(2)		///
			)			///
			xlabels(`xtl',		///
				nogrid		///
				axis(2)		///
			)			///
			xticks(`xn',		///
				grid		///
				gmin		///
				gmax		///
				axis(2)		///
			)			///
			// blank

		local note	///
		`"Grid lines are 5, 10, 25, 50, 75, 90, and 95 percentiles"'
	}
	
	local yttl : var label `varlist'
	if `"`yttl'"' == "" local yttl `varlist'
	if `"`plot'`addplot'"' == "" local legend legend(nodraw)

	graph twoway			          ///
	(scatter `varlist' `Z' if `touse' `show', ///
		sort				  ///
		ytitle(`"`yttl'"')		  ///
		xtitle(`"`xttl'"')		  ///
		`legend'			  ///
		ylabels(, nogrid)		  ///
		xlabels(, nogrid)		  ///
		`yl'				  ///
		`xl'				  ///
		note(`"`note'"')		  ///
		`options'			  ///
	)					  ///
	(function y=x if `touse' `show',          ///
		range(`Z')			  ///
		n(2)				  ///
		clstyle(refline)		  ///
		yvarlabel("Reference")		  ///
		yvarformat(`fmt')		  ///
		`rlopts'			  ///
	)					  ///
	|| `plot'				  ///
	|| `addplot'	
	// blank

	// user will see any message about missing values 
	if "`generate'" != "" { 
		gen `generate' = `Z' 
		label var `generate' "Weibull quantiles for `varlist'" 
	}	
end
