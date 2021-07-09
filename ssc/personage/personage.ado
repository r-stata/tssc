*! 1.2.1 NJC 16 January 2013 
*! 1.2.0 NJC 22 October 2012 
* 1.1.1 NJC 21 October 2012 
* 1.1.0 NJC 20 October 2012 
* 1.0.0 NJC 20 October 2012 
program personage 
	version 8.2 
	syntax varlist(numeric min=1 max=2) [if] [in] , Generate(str) [ currdate(str)] 

	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	tokenize `varlist' 
	args bdate cdate

	foreach v in `bdate' `cdate' { 
		local fmt : format `v' 
		if substr("`fmt'", 1, 2) != "%d" { 
			if substr("`fmt'", 1, 3) != "%td" { 
				di "warning: `v' not formatted as daily date"  
			}
		}
	} 

	if "`currdate'" != "" & "`cdate'" != "" { 
		di as err "two date variables supplied and also currdate() option" 
		exit 498 
	} 

	if "`cdate'" == "" { 
		if "`currdate'" == "" { 
			di as err "only one date variable supplied, and no currdate() option" 
			exit 498 
		} 
		tempvar cdate 
		gen `cdate' = `currdate' 
	} 
			
	tokenize `generate' 
	args yearsvar daysvar loyvar garbage 
	if "`garbage'" != "" { 
		di as err "at most three names should be given in generate()" 
		exit 198 
	} 
	if "`loyvar'" != "" { 
		confirm new variable `loyvar' 
	} 
	if "`daysvar'" != "" { 
		confirm new variable `daysvar' 
	} 
	confirm new variable `yearsvar' 

	tempvar work 
	local bday_this_cal_yr ///
	(month(`bdate') < month(`cdate')) | (month(`bdate') == month(`cdate') & day(`bdate') <= day(`cdate'))  

*quietly { 
		// first focus on calculating last birthday 

		// 1. last b'day earlier this year if current date is as late or later in year 
		gen `work' = mdy(month(`bdate'), day(`bdate'), year(`cdate')) if `bday_this_cal_yr' 

		// 2. else it was last year 
		replace `work' = mdy(month(`bdate'), day(`bdate'), year(`cdate') - 1) if missing(`work') 

		// but 1. won't work if born Feb 29 and it's not a leap year 
		//     2. won't work if born Feb 29 and last year not a leap year 
		local born_feb29 month(`bdate') == 2 & day(`bdate') == 29 
		local this_not_leap missing(mdy(2, 29, year(`cdate'))) 
		local last_not_leap missing(mdy(2, 29, year(`cdate') - 1))  

		// 3. is a fix for problem with 1. 
		replace `work' = mdy(2, 28, year(`cdate')) ///
		if `this_not_leap' & `born_feb29' & `cdate' >= mdy(2, 28, year(`cdate')) 
		// 4. is a fix for problem with 2. 
		replace `work' = mdy(2, 28, year(`cdate') - 1) ///
		if `last_not_leap' & `born_feb29' & `cdate' <= mdy(2, 28, year(`cdate')) 
*	}

	// now we can calculate results 
	// traditional that messages about missing values are displayed 

	gen `yearsvar' = year(`work') - year(`bdate') if `touse' 
	if "`daysvar'" != "" { 
		gen `daysvar' = `cdate' - `work' if `touse' 
	} 
	if "`loyvar'" != "" { 
		quietly {
			tempvar work2 
			gen `work2' = mdy(month(`bdate'), day(`bdate'), year(`work') + 1) 
			replace `work2' = mdy(2, 28, year(`work') + 1) if missing(`work') 
		} 
		gen `loyvar' = `work2' - `work' if `touse' 
	} 
	
	quietly compress `yearsvar' `daysvar' `loyvar' 
end 

