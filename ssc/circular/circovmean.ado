*! 1.0.0 NJC 9 April 2004
program circovmean, sort rclass  
        version 8.0
        syntax varname(numeric) [if] [in]  [, noLIST * ] 
	
	quietly { 
		marksample touse
		count if `touse' 
		if r(N) == 0 error 2000
		else local N = r(N) 

		tempvar xsum ysum vmean tag  
		tempname XSUM YSUM vecmean veclng vecstr 

		bysort `touse' (`varlist') : ///
			gen `xsum' = sum(sin((`varlist' * _pi) / 180))
		by `touse' : replace `xsum' = `xsum'[_N]  	
		by `touse' : gen `ysum' = sum(cos((`varlist' * _pi) / 180))
		by `touse' : replace `ysum' = `ysum'[_N] 
		
		scalar `XSUM' = `xsum'[_N]
		scalar `YSUM' = `ysum'[_N]
		
		// Stata atan routine takes a single argument
		// and gives the wrong answer in three out of four quadrants 
		Atan2 `XSUM' `YSUM'
		scalar `vecmean' = `r(angle)' 
		local vecshow : di %2.1f `r(angle)' 
		scalar `veclng' = sqrt((`XSUM')^2 + (`YSUM')^2)
		scalar `vecstr' = `veclng' / `N'

		replace `xsum' = `xsum' - sin((`varlist' * _pi) / 180) 
		replace `ysum' = `ysum' - cos((`varlist' * _pi) / 180) 
		egen `vmean' = atan2(`xsum' `ysum') if `touse' 
		bysort `touse' `varlist' : gen byte `tag' = _n == 1 
		char `vmean'[varname] "mean without"
		label var `vmean' "vector mean omitting value" 
		format `vmean' %2.1f 
	} 
	
	circscatter `vmean' `varlist' if `tag' & `touse' ///
		,  yli(`=`vecmean'', lp(dash))           ///
		subtitle("vector mean for all `vecshow'{c 176}", place(w)) ///
		`options'
	
	if "`list'" == "" { 
		list `varlist' `vmean' if `tag' & `touse' ///
		, subvarname abb(12) noobs
	} 	
	
	return scalar N = `N'
	return scalar vecmean = `vecmean'
	return scalar veclng = `veclng'
	return scalar vecstr = `vecstr'
end

program Atan2, rclass 
* 1.3.0 NJC 18 Dec 2003 
* 1.2.0 NJC 14 July 1998
version 8.0
	tempname at

	local sign1 = sign(`1')
	local sign2 = sign(`2')

	if (`sign1' == 1 & `sign2' == 1) | ((`sign1' == 0) & `sign2' == 1) {
		scalar `at' = atan(`1'/`2')
	}
	else if `sign1' == 1 & `sign2' == 0 {
		scalar `at' = _pi / 2
	}
	else if `sign1' == -1 & `sign2' == 0 {
		scalar `at' = 3 * _pi / 2
	}
	else if `sign2' ==  -1 {
		scalar `at' = _pi + atan(`1'/`2')
	}
	else if `sign1' == -1 & `sign2' == 1 {
		scalar `at' = 2 * _pi + atan(`1'/`2')
	}
  	else if `sign1' == 0 & `sign2' == 0 { 
		scalar `at' = . 
	}		
 
	return scalar angle = (180 / _pi) * `at'
end

