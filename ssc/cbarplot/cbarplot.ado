*! 1.0.0 NJC 13 Oct 2011 
program cbarplot
	version 8.2 
	syntax varlist(min=1 max=2) [if] [in] [fweight aweight iweight pweight] ///
	[, xasis yasis format(str) by(str) PERCent PERCent2(varlist) VERTical RBARopts(str asis) * ] 

	if `"`by'"' != "" { 
		gettoken byvar byopts : by, parse(",") 
		capture confirm var `byvar' 
		if _rc { 
			di as err "by() option: variable `byvar' not found"
			exit 111
		} 
		local arglist `varlist' `byvar' 
		if `"`byopts'"' == "" local comma "," 
	}
	else local arglist `varlist' 

	if "`percent2'" != "" { 
		if !`: list percent2 in arglist' { 
			di as err "`percent2' not otherwise specified"
			exit 498 
		}

		if "`percent'" != "" { 
			di as err "may not combine percent and percent() options"
			exit 498
		} 
	} 

	quietly { 
		marksample touse, strok 
		if "`byvar'" != "" { 
			markout `touse' `byvar', strok 
		} 
		count if `touse' 
		if r(N) == 0 error 2000 

		preserve
		keep if `touse' 
		tempvar freq 
		gen double `freq' = 1 
		collapse (sum) `freq' [`weight' `exp'], by(`varlist' `byvar') 

		local opt "yasis" 
		foreach v of local varlist { 
			if "``opt''" == "" {
				tempvar y 
				egen `y' = group(`v'), label
				_crcslbl `y' `v'  
				local newvarlist `newvarlist' `y' 
			} 
			else { 
				capture confirm numeric var `v' 
				if _rc { 
					di as err "`v' not numeric, so cannot apply `opt'"
					exit 498
				}
				local newvarlist `newvarlist' `v' 
			}

			local opt "xasis" 
		} 
		tokenize `newvarlist' 

		if "`2'" == "" { 
			tempvar x
			gen byte `x' = 1 
			if "`percent'`percent2'" != "" label var `x' "percent scale" 
			else label var `x' "frequency scale" 
			local 2 "`x'"
			local newvarlist `newvarlist' `x' 
			local nvar = 1 
		}
		else local nvar = 2 

		if "`format'" == "" local format "%2.1f"

		tempvar show 
		if "`percent'" != "" { 
			su `freq', meanonly 
			replace `freq' = 100 * `freq' / r(sum)
			gen `show' = string(`freq', "`format'") 
		} 
		else if "`percent2'" != "" { 
			tempvar bytotal
			bysort `percent2' : gen `bytotal' = sum(`freq') 
			by `percent2' : replace `freq' = 100 * `freq' / `bytotal'[_N]   
			gen `show' = string(`freq', "`format'") 
		}
		else { 
			count if `freq' != floor(`freq') 
			if r(N) == 0 gen `show' = string(`freq', "%2.0f") 
			else gen `show' = string(`freq', "`format'") 
		}

		su `freq', meanonly
		// the extra 0.1 is extra to stop bars touching 
		local scale = 2.1 * r(max) 
		local which = cond("`vertical'" != "", "`1'", "`2'") 
		tempvar x1 x2 
		gen `x1' =   `which' -  `freq' / `scale'        
		gen `x2' =   `which' +  `freq' / `scale' 

		if "`xasis'" == "" { 
			if `nvar' == 1 local levels2 "none" 
			else levelsof `2', local(levels2)
			local xno "no" 
			local byx "noixticks"
		}

		if "`yasis'" == "" { 
			levelsof `1', local(levels1)
			local yno "no"
			local byy "noiyticks"
		}
	}

	if "`by'" != "" { 
		local byby by(`by'`comma' `byy' `byx' legend(off)) 
	}

	if "`vertical'" == "" {

	local xtitle : var label `2' 
	if `"`xtitle'"' == "" local xtitle `2' 

	scatter `newvarlist', ms(i) mla(`show') mlabpos(0) mlabcolor(blue) `options' ///
	|| rbar `x1' `x2' `1', horizontal blcolor(blue) barw(0.95) bfcolor(none) legend(off)     ///
	yla(`levels1', `yno'ticks val ang(h)) xla(`levels2', val `xno'ticks) xtitle(`"`xtitle'"') `rbaropts' `byby' 

	} 

	else { 

	local ytitle : var label `1' 
	if `"`ytitle'"' == "" local ytitle `1' 

	scatter `newvarlist', ms(i) mla(`show') mlabpos(0) mlabcolor(blue) `options' ///
	|| rbar `x1' `x2' `2', blcolor(blue) barw(0.95) bfcolor(none) legend(off)     ///
	xla(`levels2', `xno'ticks val ang(h)) yla(`levels1', ang(h) val `yno'ticks) ytitle(`"`ytitle'"') `rbaropts' `byby' 

	}
end 

