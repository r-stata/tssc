*! 1.2.0 NJC 10may2019 
* 1.1.0 NJC 17jul2017 
* 1.0.0 NJC 9may2017 
program multidot 
	version 10

	syntax varlist(numeric) [if] [in], over(varname)    ///
	[ recast(str) by(str asis) sort(varlist) DESCending ///
	savedata(str asis) SHOW(varname) MISSing SEParate SEPby(varname) *] 

	if "`sepby'" != "" { 
		if "`separate'" != "" { 
			di as err "separate and sepby() options cannot be combined"
			exit 198 
		}
		if "`recast'" != "" { 
			di as err "recast() and sepby() options cannot be combined"
			exit 198 
		} 
	} 

	local nvars : word count `varlist' 

	if `nvars' == 1 { 
		local which = ///
		cond(inlist("`recast'", "bar", "hbar"), "hbar", "dot") 
		
		di "{p}try say {cmd:graph `which' `varlist', over(`over')}{p_end}"
		exit 0 
	} 

	quietly { 
		if "`missing'" != "" marksample touse, novarlist 
		else marksample touse 
		count if `touse' 
		markout `touse' `over', strok 
		if r(N) == 0 exit 2000 

		preserve 
		keep if `touse' 
		drop `touse' 
		isid `over' 
		local nvals = _N 

		tempvar y rank 
		tempname ylbl rlbl 

		if "`sort'" != "" sort `sort' 
		else sort `varlist' 
		gen `rank' = cond("`descending'" != "", _N - _n + 1, _n) 

		local j = 0 
		foreach v of local varlist { 
			local ++j 
			local call `call' `v' `over' `rank' `show' `sepby' 
			local vlbl`j' `"`: var label `v''"' 
			if `"`vlbl`j''"' == "" local vlbl`j' "`v'" 
		} 

		local which : value label `over'
		if "`which'" != "" { 
			tempfile savelbls
			label save `which' using `savelbls' 
			local todo 1 
		}
		else local todo 0 

		local Ylbl : var label `over' 

		stack `call', into(`y' `over' `rank' `show' `sepby') clear 

		if `todo' {
			do `savelbls' 
			label val `over' `which' 
		} 

		label var `over' `"`Ylbl'"' 
		
		forval i = 1/`j' { 
			label define `ylbl' `i' `"`vlbl`i''"', add
		} 

		label val _stack `ylbl' 
	
		sort _stack `rank' 

		capture confirm string var `over' 
		if _rc == 0 { 
			forval j = 1/`nvals' { 
				label def `rlbl' `j' `"`=`over'[`j']'"', add 			
			}
		}
		else { 
			forval j = 1/`nvals' { 
				label def `rlbl' `j' `"`: label (`over') `=`over'[`j']''"', add 
			}
		}
		label val `rank' `rlbl' 
	
		local ytitle `"`: var label `over''"' 
		if `"`ytitle'"' == "" local ytitle "`over'" 
	
		local RANK `rank' 

		if "`sepby'" != "" { 
			separate `rank', by(`sepby') veryshortlabel 
			local rank `r(varlist)' 
			local off legend(off) 
		}
		else if "`separate'" != "" { 
			separate `rank', by(_stack) veryshortlabel 
			local rank `r(varlist)' 
			local off legend(off)
		}
	} 
    * end quietly 

  	if "`recast'" == "" { 
		if "`show'" != "" local show mla(`show') mlabpos(3) 
		twoway scatter `rank' `y', by(_stack, note("") xrescale `off' `by') ///
		ms(Oh) mc(dkgreen) subtitle(, fcolor(green*0.2)) xtitle("") ytitle(`"`ytitle'"') /// 
		yla(1/`nvals', grid glw(vthin) glc(gs12) valuelabel ang(h) tl(0)) ///
		`show' `options' 
	} 
	else if inlist("`recast'", "line", "connected") { 
		if "`show'" != "" local show mla(`show') mlabpos(3) 
        if "`recast'" == "connected" local markers ms(Oh) mc(dkgreen)
		twoway `recast' `rank' `y', by(_stack, note("") xrescale `off' `by') ///
		`markers' subtitle(, fcolor(green*0.2)) xtitle("") ytitle(`"`ytitle'"') /// 
		yla(1/`nvals', grid glw(vthin) glc(gs12) valuelabel ang(h) tl(0)) ///
		`show' `options' 
	}
*	else if inlist("`recast'", "hbar", "bar") { 
        else { 
		if "`recast'" == "hbar" local recast "bar" 
		if "`show'" != "" { 
			local show || scatter `rank' `y', ms(none) mla(`show') mlabpos(3) 
			local off legend(off) 
		}
		twoway bar `y' `rank', by(_stack, note("") xrescale `off' `by') ///
		horizontal barw(0.7) blcolor(dkgreen) bfcolor(none) base(0) ///
		subtitle(, fcolor(green*0.2)) xtitle("") ytitle(`"`ytitle'"') /// 
		yla(1/`nvals', valuelabel ang(h) tl(0)) ///
		`options' recast(`recast') ///
		`show' 
	} 

	if `"`savedata'"' != "" { 
		rename `y' _y 
		rename `RANK' _rank 
		save `savedata' 
	} 
end 

