capture program drop epiweek

*!epiweek v1.1.0 TXChu 6 Oct 2010
*epiweek v1.0.0 TXChu 14 May 2010
program epiweek
	version 10.0
	syntax varlist(max=1 numeric) [if] [in], EPIW(string) EPIY(string)
	marksample touse
	
	local format: format `varlist'
	if substr("`format'",1,3) != "%td" {
		display
		display as error "please assign the {input}{it:`varlist'}{error}{sf} as %td date type"
		exit
	}
	
	quietly {
		tempvar cal_year first_day wkday fwb last_day ewb
		gen `cal_year' = year(`varlist')
		
		gen `first_day' = mdy(01, 01, `cal_year')
		gen `wkday' = dow(`first_day')
		gen `fwb' = cond(`wkday' <= 3, `first_day' - `wkday', `first_day' + 7 - `wkday')
		
		replace `first_day' = mdy(01, 01, `cal_year' - 1) if `varlist' < `fwb'
		replace `wkday' = dow(`first_day') if `varlist'< `fwb'
		replace `fwb' = cond(`wkday' <= 3, `first_day' - `wkday', `first_day' + 7 - `wkday') ///
			if `varlist' < `fwb'

		gen `last_day' = mdy(12, 31, `cal_year')
		replace `wkday' = dow(`last_day')
		gen `ewb' = cond(`wkday' < 3 , `last_day' - `wkday' - 1, `last_day' + 6 - `wkday')
	    replace `fwb' = `ewb' + 1 if `varlist' > `ewb'
	    	
	    gen `epiw' = floor((`varlist' - `fwb') / 7 + 1) if `touse'
		gen `epiy' = year(`fwb' + 180) if `touse'
	}

end

 	 	 	 	 	 	 	 	
