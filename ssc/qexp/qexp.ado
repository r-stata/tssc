*! 2.0.0 NJC 30 October 2003
* 1.0.0  NJC 13 October 1998
program qexp, sort
	version 8 
	syntax varname(numeric) [fweight aweight iweight/] [if] [in] ///
	[, Grid GENerate(namelist max=1) param(numlist max=1) show(str) * ]

	if "`generate'" != "" { 
		capture confirm new var `generate' 
		if _rc { 
			di as err "generate() must name new variable"
			exit 198 
		}
	}
	
	marksample touse
	qui count if `touse' 
	if r(N) == 0 error 2000 

	if "`exp'" == "" local exp = 1 

	if "`param'" != "" local M `param'
	else { 
		su `varlist' [w=`exp'] if `touse', meanonly 
		local M = r(mean) 
	} 
	
	_get_gropts , graphopts(`options') getallowed(rlopts plot)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local plot `"`s(plot)'"'
	_check4gropts rlopts, opt(`rlopts')

	tempvar Z Psubi
	
	quietly {
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
	
		sort `touse' `varlist'
		gen float `Psubi' = sum(`touse' * `exp') - 0.5 * `exp'
		su `touse' [w = `exp'], meanonly 
		replace `Psubi' = `Psubi' / r(sum) if `touse' 
	        gen double `Z' = - (`M' * log(1 - `Psubi')) if `touse' 
		label var `Z' "Inverse exponential"
		local xttl : var label `Z'
		local fmt : format `varlist'
		format `fmt' `Z'
	}
	
	qui if "`grid'" != "" {
		foreach p in 5 10 25 50 75 90 95 { 
                        local expq`p' : di %4.3f -(`M' * log(1 - `p' / 100))
                }
		
                local xtl "`expq50' `expq5' `expq95'"
                local xn  "`xtl' `expq25' `expq75' `expq10' `expq90'"
		
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
	// blank

	// user will see any message about missing values 
	if "`generate'" != "" { 
		gen `generate' = `Z' 
		label var `generate' "exponential quantiles for `varlist'" 
	}	
end
