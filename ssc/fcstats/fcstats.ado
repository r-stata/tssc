*! version 1.0.0  10jun2017  CFBaum
// based on dmariano.ado 1.0.3

program define fcstats, rclass
	version 13
	syntax varlist(ts min=2 max=3) [if] [in] [, GRAPH *]
	marksample touse
	_ts tvar panelvar `if' `in', onepanel
	markout `touse' `tvar'
	su `touse', mean
	if `r(N)' == 0 {
		error 2000
	}
	qui tsset
	
	tempvar actual forecast vrmse vmae vmape num den en fc
	tempvar forecast2 vrmse2 vmae2 vmape2 num2 den2
	tempname rmse mae mape theilu
	tempname rmse2 mae2 mape2 theilu2
	tokenize `varlist'
	local actual `1'
	local forecast `2'
	local forecast2 `3'
	markout `touse' `actual' `forecast' `forecast2'
	
	qui {
	g double `vrmse' = sum((`forecast' - `actual')^2) if `touse'
	g double `vmae' = sum(abs(`forecast' -`actual')) if `touse'
	g double `vmape' = sum(abs(`forecast' -`actual') / `actual') if `touse'
	g double `num' = sum(((`forecast' - `actual') / L.`actual')^2) if `touse'
	g double `den' = sum((D.`actual' / L.`actual')^2) if `touse'
	}
	if "`forecast2'" != "" {
			qui {
			g double `vrmse2' = sum((`forecast2' - `actual')^2) if `touse'
			g double `vmae2' = sum(abs(`forecast2' -`actual')) if `touse'
			g double `vmape2' = sum(abs(`forecast2' -`actual') / `actual') if `touse'
			g double `num2' = sum(((`forecast2' - `actual') / L.`actual')^2) if `touse'
			g double `den2' = sum((D.`actual' / L.`actual')^2) if `touse'
			}
	}
	g  `en' = _n * `touse'	
	su `en', mean
	loc mx = r(max)
	su `forecast' if `touse', mean
	sca `rmse' = sqrt(`vrmse'[`mx'] / `r(N)')
	sca `mae'  = `vmae'[`mx'] / `r(N)'
	sca `mape' = `vmape'[`mx'] / `r(N)'
	sca `theilu' = sqrt(`num'[`mx'] / `den'[`mx'])
	if "`forecast2'" != "" {
		sca `rmse2' = sqrt(`vrmse2'[`mx'] / `r(N)')
		sca `mae2'  = `vmae2'[`mx'] / `r(N)'
		sca `mape2' = `vmape2'[`mx'] / `r(N)'
		sca `theilu2' = sqrt(`num2'[`mx'] / `den2'[`mx'])
	}
	
	di as res _n "Forecast accuracy statistics for `actual', N = `r(N)'"
	if "`forecast2'" == "" {	
		di _n _col(15) "`forecast'"  
		di    "RMSE  " _col(15) `rmse' 
		di    "MAE   " _col(15) `mae' 
		di    "MAPE  " _col(15) `mape' 
		di    "Theil's U " _col(15) `theilu' 
	} 	
	else {
		di _n _col(15) "`forecast'"          _col(30) "`forecast2'"
		di    "RMSE  " _col(15) `rmse'       _col(30) `rmse2' 
		di    "MAE   " _col(15) `mae'        _col(30) `mae2'
		di    "MAPE  " _col(15) `mape'       _col(30) `mape2'
		di    "Theil's U " _col(15) `theilu' _col(30) `theilu2'
	}
	
	return scalar rmse    = `rmse'
	return scalar mae     = `mae'
	return scalar mape    = `mape'
	return scalar theilu  = `theilu'
	if "`forecast2'" != "" {
		return scalar rmse    = `rmse'
		return scalar mae     = `mae'
		return scalar mape    = `mape'
		return scalar theilu  = `theilu'
		return local forecast2 = "`forecast2'"
	}
	return local forecast = "`forecast'"
	return scalar N       =  `r(N)'
	return local actual   = "`actual'"
	
	if "`graph'" != "" {
		loc leg legend(rows(1) size(small) label(1 "`actual'") label(2 "`forecast'")
		if "`forecast2'" != "" {
			loc leg `leg' label(3 "`forecast2'")
		}
		tsline `actual' `forecast' `forecast2' if `touse', `leg') `options'
	}
end

