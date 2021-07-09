*  touched NJC 22 May 2007
*! version 0.2 23May2007
*  Author: Nikos Askitas
*  This little program is written for fun and as an exercise to learning stata. 
*  It looks at the values of a variable and tells you whether the first digits 
*  conform to Benford's Law.
*  The author wishes to thank N J Cox for a generous stata lesson
*  delivered through -this- a masterfull rewrite of the first writing
*  and point to firstdigit.ado Nick's more comprehensive  benford treatment.

program benford
	version 8   
	syntax varname(numeric) [if] [in]

	quietly {
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000 
		local N = r(N) 

		tempvar d 
		gen byte `d' = real(substr(string(`varlist'), 1, 1)) if `touse' 
	}

	di _n as txt "Digit       Count     Percent     Benford" 
	di "{hline 41}"

	forval s = 1/9 {
		qui count if `d' == `s' 
		di as res %5.0f `s' %12.0f r(N) %12.3f 100 * r(N)/`N' ///
			%12.3f 100 * log10(1 + 1/`s')
	}
end

