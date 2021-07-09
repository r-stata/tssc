*! 1.0.0 NJC 12 Dec 2006
* Fit two-parameter inverse Gaussian distribution by closed form ML 
program invgausscf, rclass byable(recall)
	version 8.1
	syntax varname [fw aw] [if] [in] 

	quietly {
		local y "`varlist'"
		marksample touse 
		count if `y' <= 0 & `touse'
		noi if r(N) {
			di " "
			di as txt ///
"{p}warning: {res:`y'} has `r(N)' values <= 0; not used in calculations{p_end}"
		}
		replace `touse' = 0 if `y' <= 0

		count if `touse' 
		if r(N) == 0 error 2000 
	}	

	di as txt _n ///
	"ML fit of two-parameter inverse Gaussian distribution"

	su `y' [`weight' `exp'] if `touse', meanonly 
	di as res "mu     = " %10.4f r(mean)
	return scalar mu = r(mean)

	tempvar newy 
	qui gen double `newy' = 1/`y' - 1/r(mean) if `touse' 
	su `newy' [`weight' `exp'] if `touse', meanonly 
	di as res "lambda = " %10.4f 1/r(mean)
	return scalar lambda = 1/r(mean) 
end

