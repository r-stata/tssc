*! 1.0.5 NJC 18 March 2014 
* 1.0.4 NJC 7 August 2013 
* 1.0.3 NJC 28 June 2012 
* 1.0.2 NJC 27 June 2012 
* 1.0.1 NJC 26 May 2012 
* 1.0.0 NJC 1 February 2011 
program devnplot, sort  
	version 9    
	syntax varlist(min=1 max=3) [if] [in] [, /// 
	overall ///
	level(str) /// 
	sort(str) /// 
        DESCending /// 
	MISSing ///
	plines ///
	PLINES2(str asis) ///
	superplines /// 
	SUPERPLINES2(str asis) /// 
	pgap(numlist max=1 >0) /// 
	superpgap(numlist max=1 >0) /// 
	rspikeopts(str asis) ///
	lineopts(str asis) ///
	separate(str asis) /// 
	separateopts(str asis) /// 
	by(str) clean * ] 

	quietly { 
		if "`by'" != "" { 
			di as err "by() not supported" 
			exit 498
		} 

		// which observations and variables 
		tokenize `varlist' 
		args y g1 g2 

		if "`missing'" == "" { 
			marksample touse, strok 
		}
		else { 
			marksample touse, novarlist 
			markout `touse' `y' 
		} 

		count if `touse'
		if r(N) == 0 error 2000 

		if "`descending'" != "" { 
			tempvar negy 
			clonevar `negy' = `y' if `touse' 
			replace `negy' = -`negy' 
		}
	
		// sort order 
		if "`sort'" != "" { 
			if trim("`sort'") == "_n" { 
				tempvar obs 
				gen long `obs' = _n 
				local sort `obs' 
				local sti "observation number"
			} 
			else unab sort : `sort' 
		
			if "`descending'" != "" {
				sort `touse' `g1' `g2' `sort' `negy' 
			} 
			else sort `touse' `g1' `g2' `sort' `y' 

			local nvars : word count `sort' 
			if "`sti'" == "" & `nvars' == 1 { 
				local sti `"`: var label `sort''"'
			} 
			if `"`sti'"' == "" local sti "`sort'" 
			local sti subtitle(`"sorted by `sti'"', place(w)) 
		} 
		else { 
			if "`descending'" != "" {
				sort `touse' `g1' `g2' `sort' `negy' 
			} 
			else sort `touse' `g1' `g2' `sort' `y' 
		}

		// x axis variable 
		tempvar x mean 
		if "`g1'`g2'" == "" { 
			gen `x' = _n if `touse' 
		} 
		else { 
			tempvar g 
			egen `g' = group(`g1' `g2') if `touse', label `missing' 
			su `g', meanonly 
			if r(max) > 20 { 
				di as err "too many groups"
				exit 498
			} 
			local max = r(max) 

			if "`g2'" != "" { 
				tempvar G1 G2
				tempname glabel 
				egen `G1' = group(`g1') if `touse', label `missing'
				egen `G2' = group(`g2') if `touse', label `missing'  

				forval i = 1/`max' { 
					su `G2' if `g' == `i', meanonly 
					local label : label (`G2') `r(min)'
					label def `glabel' `i' `"`label'"', ///
					modify
				}
				label val `g' `glabel' 
				drop `G2' 
			}
			else local G1 = 0 

			if "`pgap'" == "" local pgap = 2
			if "`superpgap'" == "" local superpgap = 4 
			gen `x' = ///
				`pgap' * `g' + `superpgap' * `G1' +  _n if `touse' 
		} 

		// means (or alternative levels) 
		if "`level'" != "" { 
			gen `mean' = `level' 
		}
		else if "`overall'" == "" { 
			bysort `touse' `g' : egen `mean' = mean(`y')
		}
		else bysort `touse' : egen `mean' = mean(`y') 

		/// different groups?  
		if "`g'" != "" { 
			separate `mean' if `touse', by(`g')
			local mean2 `r(varlist)' 

			forval i = 1/`max' { 
				su `x' if `g' == `i', meanonly 
				local label : label (`g') `i' 
				local xlabel `xlabel' `r(mean)' `"`label'"'  
			}

			if "`plines'`plines2'" != "" { 
				forval i = 1/`= `max' - 1' { 
					local j = `i' + 1 
					su `x' if `g' == `i', meanonly 
					local min = r(max) 
					su `x' if `g' == `j', meanonly 
					local xthis = (`min' + r(min))/2  
					local xli `xli' `xthis' 
				}
				if "`plines2'" == "" local plines2 lc(gs8)  
				local XLI xli(`xli', `plines2') 
			} 

			tempname Y 
			separate `y' if `touse', by(`g') gen(`Y') 
			local y2 `r(varlist)' 
		} 
		else { 
			local mean2 `mean' 
			local xlabel none 
			local y2 `y' 
		}
	}

	// y axis title 
	local yti `"`: var label `y''"'  
	if `"`yti'"' == "" local yti "`y'"

	// x axis title(s) 
	if "`g'" != "" { 
		if "`g2'" != "" { 
			local xti2 `"`: var label `g2''"'
			if `"`xti2'"' == "" local xti2 "`g2'" 
		}
		 
		local xti `"`: var label `g1''"'
		if `"`xti'"' == "" local xti "`g1'" 	
	} 

	/// x axis range 
	su `x', meanonly  
	local xmin = r(min) - 1 
	local xmax = r(max) + 1 

	if "`clean'" != "" { 
		local rspikeopts "lc(none)" 
		local lineopts "lc(none ..)" 
	}

	if "`separate'" != "" { 
		local j1 = 1 + `: word count `mean2'' + 1   
		local j2 = `j1' + `: word count `y2'' 
	        local not if !`separate' 
		local separate || scatter `y2' `x' if `separate', pstyle(p2) ///
		ms(O ..) mcolor(orange ..) lcolor(orange ..)                 ///
		legend(on order(`j1' "!(`separate')" `j2' "`separate'"))  `separateopts' 
	}

	// two group variables, so also x axis labels on top axis
	if "`g2'" != "" { 
		su `G1', meanonly 
		local max = r(max) 

		forval i = 1/`max' { 
			su `x' if `G1' == `i', meanonly 
			local label : label (`G1') `i' 
			local XLABEL `XLABEL' `r(mean)' `"`label'"'  
		}

		if "`superplines'`superplines2'" != "" { 
			forval i = 1/`= `max' - 1' { 
				local j = `i' + 1 
				su `x' if `G1' == `i', meanonly 
				local min = r(max) 
				su `x' if `G1' == `j', meanonly 
				local xthis = (`min' + r(min))/2  
				local XLI2 `XLI2' `xthis' 
			}
			if "`superplines2'" == "" { 
				local superplines2 lc(gs4) lw(*1.2) 
			} 
			local XLI2 xli(`XLI2', `superplines2') 
		}

		twoway rspike `y' `mean' `x', pstyle(p1) ///
		lc(gs12) `rspikeopts' || ///
		line `mean2' `x', pstyle(p1) ///
		lc(gs12 ..) `lineopts' || ///
		scatter `y2' `x' `not', pstyle(p1) ///
		xaxis(1 2) `XLI' `XLI2' ///
		xla(`xlabel', noticks axis(2)) xsc(r(`xmin' `xmax') axis(2)) ///
		xtitle(`"`xti2'"', axis(2)) /// 
		xla(`XLABEL', noticks axis(1) labsize(*1.2)) ///
		xsc(r(`xmin' `xmax') axis(1)) ///
		xtitle(`"`xti'"', axis(1)) /// 
		ytitle(`"`yti'"') yla(, ang(h)) ///
		legend(off) ms(Oh ..) mcolor(blue ..) lcolor(blue ..)   ///
		plotregion(style(outline)) `sti' `options' ///
		`separate' 
	}
	/// one group variable or none 
	else { 
		twoway rspike `y' `mean' `x', pstyle(p1) ///
		lc(gs12) `rspikeopts' || ///
		line `mean2' `x', pstyle(p1) ///
		lc(gs12 ..) `lineopts' || ///
		scatter `y2' `x' `not', pstyle(p1) ///
		xla(`xlabel', noticks) xsc(r(`xmin' `xmax')) `XLI' ///
		xtitle(`"`xti'"') /// 
		ytitle(`"`yti'"') yla(, ang(h)) ///
		legend(off) ms(Oh ..) mcolor(blue ..) lcolor(blue ..)   ///
		`sti' `options' ///
		`separate' 
	}
end 
