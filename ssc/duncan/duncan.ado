*! Version 1.0.0, Ben Jann, 04nov2004

program define duncan, rclass byable(recall)
	version 8.2
	syntax varlist(min=2 max=2) [fw aw] [if] [in] [, ///
	 FREQuencies Missing noLabel Format(passthru) ]

//case selection
	marksample touse, novarlist

//temporary matrices
	tempname F D CT V

//obtain frequencies and group values
	local groupvar: word 2 of `varlist'
	confirm numeric variable `groupvar'
	`=cond("`frequencies'"=="","quietly","")' ///
	 tabulate `varlist' [`weight'`exp'] if `touse', ///
	 matcell(`F') matcol(`V') `missing' `label'

//calculate Ds
	matrix `D' = J(r(c),r(c),0)
	matrix `CT' = J(1,r(r),1)*`F' // column totals
	forvalues i = 1 / `=r(c)-1' {
		forvalues j = `=`i'+1' / `r(c)' {
			forvalues k = 1 / `r(r)' {
				matrix `D'[`i',`j'] = `D'[`i',`j'] + ///
				 abs( `F'[`k',`i'] / `CT'[1,`i'] - `F'[`k',`j'] / `CT'[1,`j'] ) / 2
			}
			matrix `D'[`j',`i'] = `D'[`i',`j']
		}
	}

//display results
	di as txt _n "Pairwise D:"
	forvalues i = 1 / `r(c)' {
		local val=`V'[1,`i']
		local vals "`vals'`val' "
		if "`label'"=="" local val: label (`groupvar') `val' 20
		local valls "`valls'`val' "
	}
	matrix rownames `D' = `valls'
	matrix colnames `D' = `valls'
	matrix list `D', noheader `format'
	matrix rownames `D' = `vals'
	matrix colnames `D' = `vals'
	di as txt _n "N. of categories   = " as res r(r)
	di as txt    "N. of observarions = " as res r(N)

//return results
	ret scalar N=r(N)
	ret scalar c=r(r)
	ret matrix D=`D'
end
