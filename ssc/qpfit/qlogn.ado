*! 1.1.0 NJC 24 Nov 2003
* 1.0.0 NJC 3 Nov 2003
program qlogn, sort
	version 8 
	syntax varname [pweight fweight aweight iweight/] [if] [in] ///
	[, Grid GENerate(namelist max=1) param(numlist min=2 max=2) ///
	show(str) a(real 0.5) * ]
	
	if "`generate'" != "" { 
		capture confirm new var `generate' 
		if _rc { 
			di as err "generate() must name new variable"
			exit 198 
		}
	}

	if "`param'" != "" { 
		tokenize "`param'" 
		args M V   
	} 
	else { 
		cap assert "`e(bm)'" != "" & "`e(bv)'" != "" 
		if _rc {
                	di as err "needs parameter estimates for m and v" 
	                exit 198
        	}
		else { 
			local M = e(bm) 
			local V = e(bv)
		}
	} 
	
	_get_gropts , graphopts(`options') getallowed(rlopts plot)
	local options `"`s(graphopts)'"'
	local rlopts `"`s(rlopts)'"'
	local plot `"`s(plot)'"'
	_check4gropts rlopts, opt(`rlopts')

	tempvar Z Psubi
	
	quietly {
		marksample touse 

		count if `varlist' <= 0 & `touse' 
		if r(N) { 
			noi di " " 
			noi di as txt "Warning: {res:`varlist'} has `r(N)' values <= 0." _c
			noi di as txt " Not used in graph"
			replace `touse' = 0 if `varlist' <= 0 
		} 	

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
		else { 
			qui count if `touse' 
			if r(N) == 0 error 2000 
		} 	

		if "`exp'" == "" local exp = 1 
						
		sort `touse' `varlist'
		gen float `Psubi' = sum(`touse' * `exp') 
		su `touse' [w = `exp'], meanonly 
		replace `Psubi' = ///
			(`Psubi' - `a') / (r(sum) - 2 * `a' + 1) if `touse' 
	        gen double `Z' = exp(invnorm(`Psubi') * `V' + `M') if `touse' 
		label var `Z' "Inverse lognormal"
		local xttl : var label `Z'
		local fmt : format `varlist'
		format `fmt' `Z'
	}
	
	qui if "`grid'" != "" {
		foreach p in 5 10 25 50 75 90 95 { 
                        local dq`p' : di %4.3f ///
			exp(invnorm((`p' / 100) * `V' + `M'))
                }
		
                local xtl "`dq50' `dq5' `dq95'"
                local xn  "`xtl' `dq25' `dq75' `dq10' `dq90'"
		
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
		label var `generate' "lognormal quantiles for `varlist'" 
	}	
end
