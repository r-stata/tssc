*! 1.1.1 NJC 22 Apr 2010 
*! 1.1.0 NJC 4 May 2009 
*! 1.0.0 NJC 23 Oct 2007 
program rcspline, rclass 
	version 10 
	syntax varlist(numeric min=2 max=2) [if] [in] [fweight], ///
	[Stub(str) NKnots(passthru) Knots(passthru)              ///
	REGressopts(str) addplot(str asis) Generate(str)         ///
	SCatter(str asis) SHowknots CI CI2(str asis) Level(int `c(level)') * ] 

	if "`generate'" != "" { 
		capture confirm new variable `generate' 
		if _rc { 
			di as err "generate() requires new variable name" 
			exit _rc 
		} 
	} 

	quietly { 
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000 

		tokenize `varlist' 
		args y x 

		if "`stub'" == "" tempname stub 
		mkspline `stub' = `x' if `touse' [`weight' `exp'] ///
		, cubic `nknots' `knots'                
		local knots `r(N_knots)' 
		tempname xk 
		matrix `xk' = r(knots) 

		if "`showknots'" != "" { 
			forval i = 1/`knots' { 
				local k `k' `=`xk'[1, `i']' 
			} 
			local showk xline(`k', lw(vvthin)) 
		} 

		regress `y' `stub'* if `touse' [`weight' `exp'] , `regressopts'
		local rsq  : di %6.4f `e(r2)'
		local rmse : di %6.4g `e(rmse)' 
		local stat "knots `knots'; R-sq. `rsq'; RMSE `rmse'" 
		tempvar pred 
		predict `pred' 

		if `"`ci'`ci2'"' != "" { 
			tempvar se ul ll  
			predict `se', stdp  
			local level = (100 - `level') / 200  
			gen `ul' = `pred' + invttail(e(df_r), `level') * `se' 
			gen `ll' = `pred' - invttail(e(df_r), `level') * `se' 
			local ciplot rarea `ll' `ul' `x', sort `ci2' 
		}

		local ytitle `"`: var label `y''"' 
		if `"`ytitle'"' == "" local ytitle "`y'"  
		local xtitle `"`: var label `x''"' 
		if `"`xtitle'"' == "" local xtitle "`x'"  
	}

	twoway `ciplot'                         ///   
	|| scatter `y' `x' if `touse',          ///
	`scatter'                               ///
	|| mspline `pred' `x' if `touse',       /// 
	bands(200)                              ///
	note(`stat', place(w))                  ///
	`showk'                                 ///
	legend(nodraw)                          ///
	yti(`"`ytitle'"')                           ///
	xti(`"`xtitle'"')                           /// 
	`options'                               ///
	|| `addplot'                         

	if "`generate'" != "" { 
		gen `generate' = `pred' if `touse' 
	} 

	return scalar N_knots = `knots' 
	return matrix knots = `xk' 
end 	
