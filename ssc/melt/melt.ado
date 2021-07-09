*! version 0.0.6 20november2015 Johannes N. Blumenberg

program def melt
version 11 
syntax varlist [if] [in] [aweight] [, BY(varlist) MOreoff]
	
local variables `varlist'
local byvars "`by'"


if "`moreoff'"!="moreoff" {
		set more on
		di _newline(`=c(pagesize)-1') 
		display "Attention: All data in memory will be lost - press any key to continue"
		more
		set more off
}

local i = 1
local j = 1

foreach var of varlist `varlist' {

local templabel`var' : var label `var'

preserve
if "`byvars'"!="" {
collapse /// 
		(mean) mean=`var' ///
		(sd) sd=`var' ///
		(semean) semean=`var' ///
		(sum) sum=`var' ///
		(count) count=`var' ///
		(median) median=`var' ///
		(min) min=`var' ///
		(max) max=`var' ///
		(iqr) iqr=`var' ///
		(p25) p25=`var' ///
		(p75) p75=`var' ///
		, by("`byvars'")
} 
else {
collapse /// 
		(mean) mean=`var' ///
		(sd) sd=`var' ///
		(semean) semean=`var' ///
		(sum) sum=`var' ///
		(count) count=`var' ///
		(median) median=`var' ///
		(min) min=`var' ///
		(max) max=`var' ///
		(iqr) iqr=`var' ///
		(p25) p25=`var' ///
		(p75) p75=`var' ///
		[`weight'`exp']
}
gen varnumber=`i'
quietly {
gen varlabel=`"`templabel`var''"'
gen varname = "`var'"
save `i', replace
}
local i = `i'+1
restore
}

use `j'.dta, clear
quietly {
erase `j'.dta
local j = `j'+1
while `j' < `i' {
append using `j'
erase `j'.dta
local j = `j'+1
}
}
		
if "`byvars'"!="" {		
order varnumber varname varlabel `byvars' sum count p25 p75 iqr mean semean median sd min max
}
else {
order varnumber varname varlabel sum count p25 p75 iqr mean semean median sd min max
}

la var varlabel "Variable label"
la var mean "Mean"
la var semean "Standard Error of the Mean (sd/sqrt(n))"
la var sd "Standard Deviation"
la var sum "Sum"
la var count "Count"
la var median "Median"
la var min "Minimum"
la var max "Maximum"
la var p25 "25th Percentile"
la var p75 "75th Percentile"
la var iqr "Interquartile Range"
la var varnumber "Variable ID"
la var varname "Name of variable"

end
exit
