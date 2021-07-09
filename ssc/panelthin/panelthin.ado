*! 1.0.1 NJC 8 Dec 2008 
*! 1.0.0 NJC 19 May 2008 
program panelthin, sort  
	version 8 
	syntax [if] [in] , Minimum(numlist max=1 >0) Generate(str) 

	quietly { 
		capture confirm new var `generate' 
		if _rc { 
			di as err "generate() invalid" 
			exit _rc 
		} 

		marksample touse 
		tsset 
		local panel `r(panelvar)' 
		local time `r(timevar)' 
		markout `touse' `panel' `time' 
		count if `touse' 
		if r(N) == 0 error 2000 

		tempvar t T prev 
		bysort `touse' `panel' (`time') : gen `t' = _n * `touse' 
		by `touse' `panel' (`time') : gen `T' = _N * `touse' 
		su `T', meanonly 
		local tmax = r(max) 
		drop `T' 

		gen byte `generate' = `t' == 1 
		by `touse' `panel' : gen `prev' = `time'[1]

		forval i = 2/`tmax' { 
			replace `generate' = 1 ///
			if (`time' - `prev') >= `minimum' & `t' == `i' 

			by `touse' `panel' : ///
			replace `prev' = `time'[`i'] ///
			if (`time'[`i'] - `prev') >= `minimum'  
		}
	}
end 
	
