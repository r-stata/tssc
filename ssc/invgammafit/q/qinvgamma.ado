*! 1.0.0 NJC 19 December 2006
program qinvgamma, sort
	version 8 
	syntax varname(numeric) [fweight aweight/] [if] [in] ///
	[, Grid GENerate(namelist max=1) param(numlist min=2 max=2) show(str) * ]
	
	_get_gropts , graphopts(`options') getallowed(RLOPts plot addplot)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local addplot `"`s(addplot)'"'
	local plot `"`s(plot)'"'
	_check4gropts rlopts, opt(`rlopts')

	quietly { 
		if "`generate'" != "" { 
			capture confirm new var `generate' 
			if _rc { 
				di as err "generate() must name new variable"
				exit 198 
			}
		}
		
		marksample touse
		local y "`varlist'" 
		count if `y' <= 0 & `touse'
		if r(N) {
			noi di as txt "{p}warning: {res:`y'} has `r(N)' values <= 0;" ///
			" not used in calculations{p_end}"
		}
		replace `touse' = 0 if `y' <= 0
		count if `touse' 
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
			args alpha beta 
			if `alpha' <= 0 | `beta' <= 0 { 
				di as err "parameters must be positive"
				exit 498 
			}	
		} 	
		else { 
			if "`weight'" != "" { 
				invgammafit `y' if `touse' [`weight' = `exp'] 
			}
			else invgammafit `y' if `touse'
			local alpha = e(alpha) 
			local beta = e(beta) 
		} 
		
		tempvar Z Psubi
		if "`exp'" == "" local exp = 1 
		sort `touse' `y'
		gen float `Psubi' = sum(`touse' * `exp') - 0.5 * `exp' 
		su `touse' [w = `exp'], meanonly 
		replace `Psubi' = `Psubi' / r(sum) if `touse' 
		gen `Z' = `beta' / invgammap(`alpha', 1 - `Psubi') if `touse' 
		label var `Z' "inverse inverse gamma"
		local xttl : var label `Z'
		local fmt : format `y'
		format `fmt' `Z'
	}	
	
	qui if "`grid'" != "" {
		foreach p in 5 10 25 50 75 90 95 { 
			local igq`p' : di %4.3f `beta' / invgammap(`alpha', 1 - `p'/100)
	        }

                local xtl "`igq50' `igq5' `igq95'"
                local xn  "`xtl' `igq25' `igq75' `igq10' `igq90'"
		
	        su `y' if `touse', detail
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

	local yttl : var label `y'
	if `"`yttl'"' == "" local yttl `y'
	if `"`addplot'`plot'"' == "" local legend legend(nodraw)

	graph twoway			          ///
	(scatter `y' `Z' if `touse' `show', ///
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
	|| `addplot' || `plot' 
	// blank

	// user will see any message about missing values 
	if "`generate'" != "" { 
		gen `generate' = `Z' 
		label var `generate' "inverse gamma quantiles for `y'" 
	}	
end

