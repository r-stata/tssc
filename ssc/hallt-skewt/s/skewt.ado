*! version 1.1 a 4 August 2009

capture program drop skewt
program define skewt, rclass
version 9
syntax varlist (numeric)[if] [in], [bs saving(string) size(integer 1) reps(integer 100) replace *]
marksample touse 
preserve
keep if `touse'
foreach var of varlist `varlist' { 
capture confirm numeric variable `var'
	if _rc==0 {
		qui sum `var' if `touse', detail
		di ""
		di in gr _col(5)  "`var'- stats from the sample"
		di ""
		di in gr _col(5) "N coefficient  = `=sqrt(r(N))'"
		di in gr _col(5) "S-coefficient  = `=r(mean)/r(sd)'"
		di in gr _col(5) "G-coefficient  = `r(skewness)'"
		di in gr _col(5) "Sample mean    = `r(mean)'"
		di ""
		local ratio = (`=sqrt(r(N))')* ((`=r(mean)/r(sd)') + ((1/3) * (`r(skewness)') * ((`=r(mean)/r(sd)')^2)) + ((1/(6*((`=sqrt(r(N))')^2)))* (`r(skewness)')))
		return scalar ratio_`var'=`ratio'
	}
	else {
		di as input "`var'" as text " is not a numeric variable skewness adjusted t-statistic cannot be calculated."
	}

if "`bs'" == "bs" {
	if "`saving'" != "" {
		local saving `saving'_`var'
		global pot `saving'
	}
	bootstrap r(ratio_`var') if `touse' , saving("`saving'", `replace') reps(`reps') size(`=int(_N/`size')') `options': skewt `var'
	}
}
restore
end
