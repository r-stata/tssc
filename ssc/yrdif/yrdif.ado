*! ab202001 modified personage by NJC 16 January 2013 see personage v1.2.1 
*! default: yrunit(actact) ... ~SAS yrdif 'ACT/ACT' or equivalently 'actual'
*! option:  yrunit(age)    ... ~SAS yrdif 'AGE' (28feb=b-day if b-day=29feb) per 365 dy/yr
*! option:  yrunit(ageact) ...  'ageact' (28 or 29 feb=b-day if b-day=29feb) per 36x dy/yr

program yrdif
	version 8.2 
	syntax varlist(numeric min=1 max=2) [if] [in] , Generate(str) [ currdate(str) YRunit(str) Snm(str)] 

	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	tokenize `varlist' 
	args sdate edate

	foreach v in `sdate' `edate' { 
		local fmt : format `v' 
		if substr("`fmt'", 1, 2) != "%d" { 
			if substr("`fmt'", 1, 3) != "%td" { 
				di "warning: `v' not formatted as daily date"  
			}
		}
	} 

	if "`yrunit'" == "" {
        local yrunit  "actact"
    }
    else if "`yrunit'" == "actact" {
	}
    else if "`yrunit'" == "actual" {
	}
	else if "`yrunit'" == "age" {
	} 
	else if "`yrunit'" == "ageact" {
	} 
	else {
		di as err "yrunit() option takes {actact (default), age, or ageact}" 
		exit 498 
	} 

	if "`currdate'" != "" & "`edate'" != "" { 
		di as err "two date variables supplied and also currdate() option" 
		exit 498 
	} 

	if "`edate'" == "" { 
		if "`currdate'" == "" { 
			di as err "only one date variable supplied, and no currdate() option" 
			exit 498 
		} 
		tempvar edate 
		cap gen double `edate' = `currdate' 
        if _rc !=0 {
        di as err "currdate() option is not a valid Stata expression to define, generate, an end date"
		exit _rc
        }
	} 
			
	tokenize `generate' 
	args xyrdif garbage 
	if "`garbage'" != "" { 
		di as err "at most one name should be given in generate()" 
		exit 198 
	} 
	confirm new variable `xyrdif'

	if "`snm'" != "" {
	if substr("`yrunit'",1,3) == "act" {
	di as err "snm (Save Name prefix) yrunit() option not relevant with 'actact' or 'actual'"
	exit 198
	}
	tokenize `snm' 
	args savenameprefix garbage 
	if "`garbage'" != "" { 
		di as err "at most one Save Name prefix should be given in snm()" 
		exit 198 
	    }
	cap confirm new var `snm'yrs `snm'dys `snm'loy 
    if _rc !=0 {
        di as err "snm (Save Name prefix): * {*yrs, *dys, *loy} defined var exists"
		exit 198
        }
	}
	
    quietly {
    tempvar sign wsdate wedate
	gen byte `sign' = cond(`sdate'<=`edate' , 1 , -1) if `touse'
	gen double `wsdate' = min(`sdate' ,`edate') if `touse'
	gen double `wedate' = max(`sdate' ,`edate') if `touse'
	format `wsdate' `wedate' %td

	if substr("`yrunit'",1,3) == "act" {
	tempvar syear eyear d1 dyr1 d2 dyr2 wholeyr
	
	gen double `syear'=year(`wsdate')
	gen double `eyear'=year(`wedate')
   
    if `syear' == `eyear' {
	gen double `d1' = `wedate' - `wsdate' 
	gen double `dyr1'= doy(mdy(12,31,`syear'))
	gen double `d2'  = 0
	gen double `dyr2'= `dyr1'
	gen double `wholeyr' = 0
	}
	else {
	gen double `d1'  = mdy(12,31,`syear') - `wsdate' + 1
	gen double `dyr1'= doy(mdy(12,31,`syear'))
	gen double `d2'  = `wedate' - mdy(01,01,`eyear') + 0
	gen double `dyr2'= doy(mdy(12,31,`eyear'))
	gen double `wholeyr' = (`eyear'-`syear')-1
	}
 	noisily gen double `xyrdif' = `sign' * round( ( `d1'/`dyr1' + `wholeyr' + `d2'/`dyr2' ) , 2^-48 )
	replace `xyrdif' = 0 if `wsdate' == `wedate' & !missing(`xyrdif')
	}
	else if substr("`yrunit'",1,3) == "age" {
	tempvar work yearsvar daysvar loyvar sasi_num sasi_den
	local bday_this_cal_yr ///
	(month(`wsdate') < month(`wedate')) | (month(`wsdate') == month(`wedate') & day(`wsdate') <= day(`wedate'))  

	// first focus on calculating last birthday 
	// 1. last b'day earlier this year if current date is as late or later in year 
	gen double `work' = mdy(month(`wsdate'), day(`wsdate'), year(`wedate')) if `bday_this_cal_yr' 
	// 2. else it was last year 
	replace `work' = mdy(month(`wsdate'), day(`wsdate'), year(`wedate') - 1) if missing(`work') 
	// but 1. won't work if born Feb 29 and it's not a leap year 
	//     2. won't work if born Feb 29 and last year not a leap year 
	local born_feb29 month(`wsdate') == 2 & day(`wsdate') == 29
	local this_not_leap missing(mdy(2, 29, year(`wedate'))) 
	local last_not_leap missing(mdy(2, 29, year(`wedate') - 1))  
	// 3. is a fix for problem with 1. 
	replace `work' = mdy(2, 28, year(`wedate')) ///
	if `this_not_leap' & `born_feb29' & `wedate' >= mdy(2, 28, year(`wedate')) 
	// 4. is a fix for problem with 2. 
	replace `work' = mdy(2, 28, year(`wedate') - 1) ///
	if `last_not_leap' & `born_feb29' & `wedate' <= mdy(2, 28, year(`wedate')) 
	// now we can calculate results 
	// traditional that messages about missing values are displayed 
	gen double `yearsvar' = year(`work') - year(`wsdate') 
	gen double `daysvar' = `wedate' - `work' 
	tempvar work2 
	gen double `work2' = mdy(month(`wsdate'), day(`wsdate'), year(`work') + 1) 
	replace `work2' = mdy(2, 28, year(`work') + 1) if missing(`work2') 
	gen double `loyvar' = `work2' - `work'
	// ***
	if "`yrunit'" == "ageact" {
	gen byte `sasi_num' = 0
	gen byte `sasi_den' = 0
	}
	else {
	gen byte `sasi_den' = cond(`loyvar' == 366 ,1,0)
	gen byte `sasi_num' = cond(`loyvar' == 366 & `daysvar' > 0,1,0)
	replace  `sasi_num' = 0 if cond((`loyvar' == 366 & `wedate' <=  mdy(2,28,year(`wedate'))) & !missing(mdy(2,29,year(`wedate'))) ,1,0)
	replace  `sasi_num' = 0 if cond((`loyvar' == 366 & `wedate' >=  mdy(3, 1,year(`wedate'))) &  missing(mdy(2,29,year(`wedate'))) ,1,0)
	}
	if "`snm'" != "" {
	gen double `snm'yrs = `sign' * `yearsvar'
	gen double `snm'dys = `sign' * (`daysvar'-`sasi_num')
	gen double `snm'loy = `loyvar'-`sasi_den'
	}
	// ***

	noisily gen double `xyrdif' =  `sign' * round( (`yearsvar' + (`daysvar'-`sasi_num')/(`loyvar'-`sasi_den')) , 2^-52 )
	}
	else {
	}
	compress `xyrdif'
    } // ending quietly	
end 

