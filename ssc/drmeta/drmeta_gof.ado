*! N.Orsini v.1.0.0 18sep18

capture program drop drmeta_gof
program define drmeta_gof, eclass
syntax [, r2s OPVDplot(string) DRVDplot(string) DOVPplot  * ]
version 13
if "`e(cmd)'"!="drmeta" error 301
	
	// Get graph options 
	
   _get_gropts , graphopts(`options')
 	local options `"`s(graphopts)'"'

di _n as res "Goodness-of-fit statistics"
di as txt "Deviance test (D) = " as res _col(15) %5.4f `e(D)'  as txt _col(40) " Prob >= chi2(" as res `e(N)'-`e(k_f)' as txt ") = " as res %5.4f `e(p_D)'
di as txt "Overall coefficient of determination R-squared = " as res %3.2f `e(r2)'

if "`r2s'" != "" {
	di _n as txt "Study-specific coefficient of determination R-squared" 
	foreach s of numlist `e(id)' {
	di as txt _col(3) "Study `s' = " as res %3.2f `e(r2_`s')'
	}
}

if "`opvdplot'" != "" {

	gettoken x opts : opvdplot, parse(", ")

	if regexm("`opts'", "xb") == 1 local typepred "xb"
	if regexm("`opts'", "xbs") == 1 local typepred "xbs"	
    if regexm("`opts'", "fitted") == 1 local typepred "fitted"
	
	if "`typepred'" == "" local typepred "xbs"
	local takeexp = 0 
	if ustrregexm("`opts'", "eform") local takeexp = 1

	tempvar xbs newid newy tp
	qui gen `newid' = `e(idname)'
	qui gen `newy' = `e(depvar)'
	predict `tp' , `typepred'
	local ytit "xb"
	
	if `takeexp' == 1 {
			qui replace `newy' = exp(`newy')
			qui replace `tp' = exp(`tp')		
			local takelog "yscale(log)"
			local ytit "exp(xb)"
	}
	
	if "`e(idname)'" != "" {
		twoway  (scatter `newy' `x' , mc(black) msymbol(o)    ) ///
		(scatter `tp' `x' , sort lc(blue) c(l) ms(o) mc(blue) lp(dash)) ///
		(scatter `newy' `x' if `e(se)' ==0, mc(red)  msymbol(o)  ) ///
		, by(`e(idname)' , plotregion(style(none)))  ///
		legend(label(1 "Observed") label(2 "Predicted (`typepred')") label(3 "Referent") region(style(none)) ring(1) pos(6) row(1))  ///
		note("") ytitle("`ytit'") xtitle("`x'")  legend(off) caption("") ///
		ylabel(#4, angle(horiz)) xlabel(#5)  name(opvdplot, replace) `takelog' `options'    
	}
	else {
	     twoway (scatter `newy' `x') (line `tp' `x' , sort) ,   ///
		note("") ytitle("`ytit'") xtitle("`x'") legend(off) caption("") ///
		ylabel(#4, angle(horiz)) xlabel(#5) `takelog'   name(opvdplot, replace) `options' 
	}
}
			
if "`drvdplot'" != "" {
	tempname _tresidual _dose _tpred _ty
	gettoken x opts : drvdplot, parse(", ")
	mat `_tresidual' = e(tres)
	mat `_tpred' = e(tpred)
	mat `_ty' = e(ty)
	svmat `_tresidual'
	svmat `_tpred'
	svmat `_ty'
	mkmat `x' if `e(depvar)' != 0 , matrix(`_dose')
	svmat `_dose'
	twoway (scatter `_tresidual'1 `_dose'1) (lowess `_tresidual'1 `_dose'1 , lw(thick) bwidth(.9) lc(red)) ///
	, ytitle("Decorrelated residuals") ///
	xtitle("`x'") legend(off) yline(0, lp(dot)) plotregion(style(none)) name(drvdplot, replace) `options' 

	capture drop `_tresidual'1
	capture drop `_dose'1
	capture drop `_tpred'1
	capture drop `_ty'1
}

if "`dovpplot'" != "" {
	tempname _tresidual _dose _tpred _ty
	mat `_tresidual' = e(tres)
	mat `_tpred' = e(tpred)
	mat `_ty' = e(ty)
	svmat `_tresidual'
	svmat `_tpred'
	svmat `_ty'

	twoway (scatter `_ty'1 `_tpred'1) (lowess `_ty'1 `_tpred'1 , lw(thick) bwidth(.9) lc(red)) ///
	, /// 
	ytitle("Decorrelated observed contrasts") ///
	xtitle("Decorrelated predicted contrasts") legend(off)  plotregion(style(none)) name(drvpplot, replace) `options' 
	
	capture drop `_tresidual'1
	capture drop `_tpred'1
	capture drop `_ty'1
}

end
