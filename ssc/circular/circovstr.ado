*! 1.0.0 NJC 9 April 2004
program circovstr, sort rclass  
        version 8.0
        syntax varname(numeric) [if] [in]  [, noLIST * ] 
	
	quietly { 
		marksample touse
		count if `touse' 
		if r(N) == 0 error 2000
		else local N = r(N) 

		tempvar xsum ysum vstr tag  
		tempname XSUM YSUM veclng vecstr 

		bysort `touse' (`varlist') : ///
			gen `xsum' = sum(sin((`varlist' * _pi) / 180))
		by `touse' : replace `xsum' = `xsum'[_N]  	
		by `touse' : gen `ysum' = sum(cos((`varlist' * _pi) / 180))
		by `touse' : replace `ysum' = `ysum'[_N] 
		
		scalar `XSUM' = `xsum'[_N]
		scalar `YSUM' = `ysum'[_N]
		scalar `veclng' = sqrt((`XSUM')^2 + (`YSUM')^2)
		scalar `vecstr' = `veclng' / `N'
		local vecshow : di %4.3f scalar(`vecstr') 

		replace `xsum' = `xsum' - sin((`varlist' * _pi) / 180) 
		replace `ysum' = `ysum' - cos((`varlist' * _pi) / 180) 
		gen `vstr' = sqrt((`xsum')^2 + (`ysum')^2) / (`N' - 1) if `touse' 
		bysort `touse' `varlist' : gen byte `tag' = _n == 1 
		char `vstr'[varname] "strength without"
		label var `vstr' "vector strength omitting value" 
		format `vstr' %4.3f 
	} 
	
	circscatter `vstr' `varlist' if `tag' & `touse' ///
		,  yli(`=`vecstr'', lp(dash))           ///
		subtitle("vector strength for all `vecshow'", place(w)) ///
		`options'
	
	if "`list'" == "" { 
		list `varlist' `vstr' if `tag' & `touse' ///
		, subvarname abb(16) noobs
	} 	
	
	return scalar N = `N'
	return scalar veclng = `veclng'
	return scalar vecstr = `vecstr'
end

