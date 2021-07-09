*! v.1.0, 21oct2016 Jan Helmdag

/*
Abstract: panell displays individual and overall panel length of a given set of variables 
	of a longitudinal/panel dataset. The output shows how many observations are non-missing
	for one variable or a certain combination of multiple variables
*/

program panell
version 12.0
syntax [varlist(ts)] [if] [in], [Generate(string)] [SUppress]

marksample touse, strok
	quietly count if `touse'
	if `r(N)' == 0{
		error 2000
	}

*xtset and time format
_xt, trequired
	local ivar `r(ivar)'
	local tvar `r(tvar)'
	local tfmt: format `r(tvar)'
	
if regexm("`tfmt'","%t")==0 {
	local tfmt ""
}

quietly xtdescribe
	local totalpanels `r(N)'
	local totallength `r(max)'

*labels for i
quietly levelsof `ivar', local(id)
local forlab: value label `ivar'

*build new varlist without string variables
foreach var in `varlist' {
	local `var'_fmt: format `var'
	if regexm("``var'_fmt'","s")==0 {
		local varlistnumeric `varlistnumeric' `var'
	}
}

if "`varlistnumeric'"=="" {
	display as error "No numeric variables specified"
	exit
}

local num: word count `varlistnumeric'

*placeholders	
local obspanels 0
local counter 1
local indgaps 0
local totalobs 0

*optionally generate variable
if "`gen'" != "" {
	local genvar "`gen'"
	capture mark `gen'
	markout `gen' `varlistnumeric'
}

*characteristics of t
quietly summ `tvar' if `touse'
	local commonlow `r(min)'
	local commonhigh `r(max)'
	local lowest `r(min)'
	local highest `r(max)'

display as text "{hline 105}"
if regexm("`suppress'","suppress")==1 {
	display "Detailed description of individual panels suppressed"
}

*single variable
if `num'==1 {
	if regexm("`suppress'","suppress")==0 {
		display as result "i" _col(30) "t" _col(40) "Range of t" _col(75) "Mean" _col(85) "Min" _col(95) "Max"
		display as text "{hline 105}"
	}
	foreach i of local id {
		capture local label: label `forlab' `i'
		tempvar marker_`i'
		capture mark `marker_`i''
		markout `marker_`i'' `varlistnumeric'
		quietly replace `marker_`i'' = . if `ivar'!=`i'
		quietly summ `varlistnumeric' if `marker_`i'' == 1 & `touse'
		local varmean: di %-8.0g `r(mean)'
		local varmin: di %-8.0g `r(min)'
		local varmax: di %-8.0g `r(max)'
		
		quietly summ `tvar' if `marker_`i'' == 1 & `touse'
		local tmin `r(min)'
		local tmax `r(max)'
		
		
		if `r(N)'!=0 {
			if `r(min)'>`commonlow' {
				local commonlow=`r(min)'
			}
		if `r(max)'<`commonhigh' {
				local commonhigh=`r(max)'
			}
		}
		
		if `r(N)'==0 {
			if regexm("`suppress'","suppress")==0 {
				display as error "`i' `label'" _col(30) "no observations"
			}
		}
		
		else if `r(max)'-`r(min)'+1-`r(N)'>0 { // "if there are gaps..."
			if regexm("`suppress'","suppress")==0 {
				if missing("`tfmt'") {
					display as result "`i' `label'" _col(30) as result "`r(N)' obs., " ///
						_col(40) "`tmin' -- `tmax', " ///
						as error "gaps: " `r(max)'-`r(min)'+1-`r(N)' ///
						as result ///
						_col(75) "`varmean'" ///
						_col(85) "`varmin'" ///
						_col(95) "`varmax'"
				}
				else {
					display as result "`i' `label'" _col(30) as result "`r(N)' obs., " ///
						_col(40) `tfmt' `tmin' " -- " `tfmt' `tmax' ", " ///
						as error "gaps: " `r(max)'-`r(min)'+1-`r(N)' ///
						as result ///
						_col(75) "`varmean'" ///
						_col(85) "`varmin'" ///
						_col(95) "`varmax'"
				}
			}
			
		local obspanels=`++obspanels'
		local indgaps=`indgaps'+`r(max)'-`r(min)'+1-`r(N)'
		local totalobs=`totalobs'+`r(N)'
		
		}
		
		else {
			if regexm("`suppress'","suppress")==0 {
				if missing("`tfmt'") {
					display as result "`i' `label'" _col(30) as result "`r(N)' obs., " ///
					_col(40) `tmin' " -- " `tmax' ", gaps: 0" ///
					_col(75) "`varmean'" ///
					_col(85) "`varmin'" ///
					_col(95) "`varmax'"
				}
				else {
					display as result "`i' `label'" _col(30) as result "`r(N)' obs., " ///
					_col(40) `tfmt' `tmin' " -- " `tfmt' `tmax' ", gaps: 0" ///
					_col(75) "`varmean'" ///
					_col(85) "`varmin'" ///
					_col(95) "`varmax'"
				}
			}
		local obspanels=`++obspanels'
		local totalobs=`totalobs'+`r(N)'
		}
	}
}

*multiple variables
else {
	if regexm("`suppress'","suppress")==0 {
		display as result "i" _col(30) "t" _col(40) "Range of t" _col(70)
		display as text "{hline 105}"
	}

	foreach i of local id {
		capture local label: label `forlab' `i'
		tempvar marker_`i'
		capture mark `marker_`i''
		markout `marker_`i'' `varlistnumeric'
		quietly replace `marker_`i'' = . if `ivar'!=`i'
		
		quietly summ `tvar' if `marker_`i'' == 1 & `touse'
		local tmin `r(min)'
		local tmax `r(max)'
		
		if `r(N)'!=0 {
			if `r(min)'>`commonlow' {
				local commonlow=`r(min)'
			}
		if `r(max)'<`commonhigh' {
				local commonhigh=`r(max)'
			}
		}
		
		if `r(N)'==0 {
			if regexm("`suppress'","suppress")==0 {
				display as error "`i' `label'" _col(30) "no observations"
			}
		}
		
		*if there are gaps...
		else if `r(max)'-`r(min)'+1-`r(N)'>0 { 
			if regexm("`suppress'","suppress")==0 {
				if missing("`tfmt'") {
					display as result "`i' `label'" _col(30) as result "`r(N)' obs., " ///
						_col(40) `tmin' " -- " `tmax' ", " ///
						as error "gaps: " `r(max)'-`r(min)'+1-`r(N)'
				}
				else {
					display as result "`i' `label'" _col(30) as result "`r(N)' obs., " ///
						_col(40) `tfmt' `tmin' " -- " `tfmt' `tmax' ", " ///
						as error "gaps: " `r(max)'-`r(min)'+1-`r(N)'
				}
			}
		local obspanels=`++obspanels'
		local indgaps=`indgaps'+`r(max)'-`r(min)'+1-`r(N)'
		local totalobs=`totalobs'+`r(N)'
		}
		
		else {
			if regexm("`suppress'","suppress")==0 {
				if missing("`tfmt'") {
					display as result "`i' `label'" _col(30) as result "`r(N)' obs., " ///
						_col(40) `tmin' " -- " `tmax' ", gaps: 0"
				}
				else {
					display as result "`i' `label'" _col(30) as result "`r(N)' obs., " ///
						_col(40) `tfmt' `tmin' " -- " `tfmt' `tmax' ", gaps: 0"
				}
			}
		local obspanels=`++obspanels'
		local totalobs=`totalobs'+`r(N)'
		}
	}
}
*-------------------------------------------------------------------------------
*Display sample results
if missing("`tfmt'") {
	display as text "{hline 105}" ///
		_newline as result "No. of panels:" _col(30) `totalpanels' ///
		_newline "No. of t:" _col(30) `totallength' ///
		_newline "No. of panels with obs.:" _col(30) `obspanels' ///
		_newline "Sum of individual gaps:" _col(30) `indgaps' ///
		_newline "Total number of obs." _col(30) `totalobs' ///
		_newline ///
		_newline "Lowest start value:" _col(30) `lowest' ///
		_newline "Highest end value:" _col(30) `highest' ///
		_newline ///
		_newline "Highest start value:" _col(30) `commonlow' ///
		_newline "Lowest end value:" _col(30) `commonhigh' ///
		_newline as text "{hline 100}"
}
else {
	display as text "{hline 105}" ///
		_newline as result "No. of panels:" _col(30) `totalpanels' ///
		_newline "No. of t:" _col(30) `totallength' ///
		_newline "No. of panels with obs.:" _col(30) `obspanels' ///
		_newline "Sum of individual gaps:" _col(30) `indgaps' ///
		_newline "Total number of obs." _col(30) `totalobs' ///
		_newline ///
		_newline "Lowest start value:" _col(30) `tfmt' `lowest' ///
		_newline "Highest end value:" _col(30) `tfmt' `highest' ///
		_newline ///
		_newline "Highest start value:" _col(30) `tfmt' `commonlow' ///
		_newline "Lowest end value:" _col(30) `tfmt' `commonhigh' ///
		_newline as text "{hline 105}"
}
end
