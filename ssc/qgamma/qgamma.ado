*! 2.0.2 NJC 16 May 2011
*! 2.0.1 NJC 17 November 2003
*! 2.0.0 NJC 6 November 2003
* 1.1.2  NJC 24 April 1998
* 1.1.1  NJC 3 March 1998
* 1.1.0  NJC 16 April 1997
program qgamma, sort
	version 8 
	syntax varname(numeric) [fweight aweight/] [if] [in] ///
	[, ALTernative Grid GENerate(namelist max=1) param(numlist min=2 max=2) show(str) * ]
	
	_get_gropts , graphopts(`options') getallowed(rlopts plot addplot)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local plot `"`s(plot)'"'
	local addplot `"`s(addplot)'"'
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
		args A B 
		if `A' <= 0 | `B' <= 0 { 
			di as err "parameters must both be positive"
			exit 498 
		}
		if "`alternative'" != "" local B = 1/`B' 	
	} 	
	else { 
		if "`exp'" != "" {	
			qui gammafit `varlist' if `touse' [`weight' = `exp']
		} 
		else qui gammafit `varlist' if `touse' 
		local A = e(alpha) 
		local B = e(beta) 
	} 
	
	tempvar Z Psubi
	
	quietly {
		if "`exp'" == "" local exp = 1 
		sort `touse' `varlist'
		gen float `Psubi' = sum(`touse' * `exp') - 0.5 * `exp'
		su `touse' [w = `exp'], meanonly 
		replace `Psubi' = `Psubi' / r(sum) if `touse' 
	        gen double `Z' = `B' * invgammap(`A',`Psubi') if `touse' 
		label var `Z' "inverse gamma"
		local xttl : var label `Z'
		local fmt : format `varlist'
		format `fmt' `Z'
	}
	
	qui if "`grid'" != "" {
		foreach p in 5 10 25 50 75 90 95 { 
			local gq`p' : di %4.3f `B' * invgammap(`A',`p'/100)
	        }
		
                local xtl "`gq50' `gq5' `gq95'"
                local xn  "`xtl' `gq25' `gq75' `gq10' `gq90'"
		
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
	if `"`plot'"' == "" local legend legend(nodraw)

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
	|| `addplot'				  ///
	// blank

	// user will see any message about missing values 
	if "`generate'" != "" { 
		gen `generate' = `Z' 
		label var `generate' "gamma quantiles for `varlist'" 
	}	
end
