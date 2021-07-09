capture program drop epiweekr

*!epiweek2 v1.0.0 TXChu 1 May 2014
program epiweek2
	version 10.0
	syntax varlist(max=1 string), Start(string) End(string)
	marksample touse
	
	capture confirm string variable `varlist'
	if _rc != 0 {
		display
		display as error "please assign the {input}{it:`varlist'}{error}{sf} as string type"
		exit
	}
	
	quietly {
		tempvar cal_year cal_week first_day 
		
		gen `cal_year' = real(regexs(1)) if regexm(`varlist', "([0-9][0-9][0-9][0-9])[w|W]")
		gen `cal_week' = real(regexs(1)) if regexm(`varlist', "[w|W]([0-9]+)")
		
		gen `first_day' = mdy(1, 1, `cal_year')
		
		replace `first_day' = `first_day' - dow(`first_day') if dow(`first_day') <= 3
		replace `first_day' = `first_day' + (7 - dow(`first_day')) if dow(`first_day') > 3
		
		gen `start' = `first_day' + (`cal_week' - 1) * 7
		gen `end' = `start' + 6
		format `start' `end' %td		
	}	
end

 	 	 	 	 	 	 	 	
