*! 1.0.0 Ariel Linden 03Apr2018


program define itsaperm, rclass
version 11.0

	/* obtain settings */
	syntax varlist(min=1 numeric) [if] [in] [aweight] ,       		/// weight only relevant for -newey-
	TRPeriod(numlist min=1 max=1 sort)								/// start time of intervention    
	TREATid(numlist min=1 max=1 int sort)                         	/// ID of actual treated unit
	[ Pr(numlist max=1 >0 <1)										/// minimum p-value for balancing covariates
	MATCHvar(varlist)												/// variables used for matching
	LAG(int -1)														/// lag only relevant for -newey-
	PRAIS															///	use -prais- rather than default -newey-
	NOIsily															/// shows _zxt estimates as they are computed
	PLOt PLOt2(str asis)											/// generate forest-plot
	FAVors(str)														/// labels for left and right side of zero
	REPLace															/// replace variables generated in previous run
	* ]
				
	
	/* check if data is tsset with panel and time var */
	
	quietly {
		marksample touse
		count if `touse'
		if r(N) == 0 error 2000
		local N = r(N)
		replace `touse' = -`touse'
	
		tsset
		local tvar `r(timevar)'
		local pvar `r(panelvar)'

		/* drop program variables if option "replace" is chosen */
		if "`replace'" != "" {
			local itsapermvars : char _dta[_itsapermvars]
				if "`itsapermvars'" != "" {
					foreach v of local itsapermvars {
						capture drop `v'
					}
				}
		}
				
		/********* validate options ************/
		if "`exp'" != "" & "`prais'" != "" {
			di as err "weights may not be specified with prais option"
		exit 101
		}
	
		if "`prais'" != "" {
			if `lag' != -1 {
				di as err "lag() may not be specified with prais option"
			exit 198
			}
		}
		else if `lag' == -1 local lag 0
	
		if "`pr'" == "" {
			local pr = 0 
		}
	
		/* Get unique levels of the panel (pvar) variable */
		sum `pvar' if `touse'
		local rmin =r(min)
		local rmax =r(max)
		levelsof `pvar' if `touse', local(levels)

		/* determine if pvar has value labels and assign them to ID*/
		local pvarlabl: value label `pvar'
		if "`pvarlabl'" != "" {
			gen id:`pvarlabl' = . if `touse'
		}
		else {
			gen id = . if `touse'
		}
	
		gen strL idC = "" if `touse'
		gen estimate =. if `touse'
		gen se = . if `touse'
		gen t = . if `touse'
		gen p = . if `touse'
		gen lcl = . if `touse'
		gen ucl = . if `touse'
		
		/* if matchvar is not specified, use varlist */
		if "`matchvar'" == "" {
			local matchvar `varlist'
		}
		local r 1 // row
	} // end quietly
	
	/* setup for dots */
		if "`noisily'" == "" {
		di _n
		di as txt "Iterating across (" as res `cnt' as txt ") units of `pvar' "
		di as txt "{hline 4}{c +}{hline 3} 10 " "{hline 3}{c +}{hline 3} 20 " "{hline 3}{c +}{hline 3} 30 " "{hline 3}{c +}{hline 3} 40 " "{hline 3}{c +}{hline 3} 50 "
		}
	/* loop thru -itsamatch- then -itsa- for each unit of pvar */
	foreach i of local levels {
		if "`noisily'" == "" {
		_dots `cnt' 0
		}
		else if "`noisily'" != "" {
		di _n
		di "ID#: `i'"
		}
		capture `noisily' {
			qui replace id = `i' in `r' 
			qui itsamatch `matchvar' if `touse', treatid(`i') trperiod(`trperiod') pr(`pr') lag(`lag') `prais' local(controls) `options'
			qui	replace idC = "`controls'" in `r'
			qui itsa `varlist' if `touse', treatid(`i') trperiod(`trperiod') contid(`controls') lag(`lag') `prais' replace `options'
			lincom _b[_z_x_t`trperiod'] // diff-in-diffs
		
		quietly {
			replace estimate = r(estimate) in `r' 
			replace se = r(se) in `r'
			replace t = r(t) in `r'
			replace p = r(p) in `r'
			replace lcl = r(lb) in `r'
			replace ucl = r(ub) in `r'
			} // end quietly
		} // end capture
	local r = `r' + 1
	} // end foreach
	
	/* track variables generated */
     local itsapermvars id nC idC estimate se t p lcl ucl
     char def _dta[_itsapermvars] "`itsapermvars'"

	/* generate forest-plot */
	if `"`plot'`plot2'"' != ""{

		/* handling value labels */
		tempvar id2
		if "`pvarlabl'" != "" {
			tempvar id1
			decode id, gen(`id1')
			encode `id1', gen(`id2')
		}
		else {
			qui gen `id2' = id if id !=.
		}	
		
		/* get pvar variable label */
		local ydesc : var label `pvar'
		if `"`ydesc'"' == "" local ydesc "`pvar'"
				
		/* location of xmlabels */
		quietly sum lcl
		local lxmlabl = (r(min) - 0)/2
		quietly sum ucl
		local uxmlabl = (r(max) - 0)/2
				
		/* favors */
		if "`favors'" != "" {
			local pos = strpos("`favors'", "#")
			local leftfav = substr("`favors'",1,(`pos'-1))
			local rightfav = substr("`favors'",(`pos'+1),(length("`favors'")-`pos'+1) )
			local favopt `"xmlabel(`lxmlabl' `"`leftfav'"' `uxmlabl' `"`rightfav'"', noticks labels labsize(*1.5) labgap(5))"'
		}
		
		twoway(rcap lcl ucl `id2', lwidth(thin) lcolor(gray) hor) ///
		(scatter `id2' estimate, msymbol(circle_hollow) mcolor(gray) msize(medsmall)) ///
		(rcap lcl ucl `id2' if `id2'==`treatid', lwidth(thin) lcolor(black) hor) ///
		(scatter `id2' estimate if `id2'==`treatid', msymbol(circle) msize(medsmall) mcolor(black)), /// 
		ytitle("`ydesc'") ///
		ylabel(`rmin'(1)`rmax', labsize(vsmall) angle(hor) valuelabel glcolor(dimgray)) ///
		xtitle(Difference-in-differences in trends (95% CIs), size(medium)) ///
		xscale(titlegap(3)) ///
		xline(0) xlabel(, nogrid format(" %9.0fc") labsize(small)) `favopt' ///
		legend(off) scheme(s2mono) `plot2' 
	
	} // end plot

end
