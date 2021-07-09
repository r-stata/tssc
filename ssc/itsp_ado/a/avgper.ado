capture program drop avgper

*! avgper 1.0.0  CFBaum 08oct2007
program avgper, rclass
	version 10.1
	syntax varlist(max=1 numeric) [in], per(integer)
	marksample touse
	quietly count if `touse'
	if `r(N)' == 0 {
	        error 2000
	}
* validate per versus selected sample
	if `per' <= 0 | `per' >= `r(N)' {
	        display as error "per must be > 0 and < N of observations."
	        error 198
	}
	if mod(`r(N)',`per' != 0) {
	        display as error "N of observations must be a multiple of per."
	        error 198
	}
* validate the new varname
	local newvar = "`varlist'A`per'"
	quietly generate `newvar' = .
* pass the varname and newvarname to Mata
	mata: avgper("`varlist'", "`newvar'",  `per', "`touse'")
	end
	