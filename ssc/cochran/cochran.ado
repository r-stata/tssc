*! Version 1.0.2, Ben Jann, 27oct2004

program define cochran, rclass byable(recall)

	version 8.2
	syntax varlist(min=2 num) [if] [in] [fw] [, Detail ]
	marksample touse

//generate indicator variables
	local i 1
	foreach var of local varlist {
		capture assert `var' == 0 | `var' == 1 if `touse'
		if _rc {
			tempname x`i'
			qui gen byte `x`i'' = `var'!=0 if `touse'
		}
		else local x`i' `var'
		local templist "`templist'`x`i++'' "
	}

//determine proportions and sums
	tempname T c sum_u sum_u2 Q p N
	tempvar u2
	qui egen `u2' = rsum(`templist') if `touse'
	qui replace `u2' = `u2'^2 if `touse'
	qui tabstat `u2' `templist' [`weight'`exp'] if `touse', s(mean sum n) save
	mat `T' = r(StatTot)
	mat `T' = `T''
	sca `N' = `T'[1,3]
	sca `sum_u2' = `T'[1,2]
	mat `T' = `T'[2...,1..2]
	mat rown `T' = `varlist'
	mat coln `T' = proportion count
	sca `c' = rowsof(`T')
	mat `sum_u' = J(1,`c',1) * `T'[1...,2]

//calculate Cochran's Q
	capture mat `Q'  = ///
	  (`c'-1) * ( `c' * ( `T'[1...,2]' * `T'[1...,2] ) - `sum_u'[1,1]^2 ) ///
	  / ( `c' * `sum_u'[1,1] - `sum_u2' )
	if _rc sca `Q'  = .
	scalar `p' = chi2tail(`c'-1,`Q'[1,1])

//conduct exact test for 2 indicators (code adopted from the file cochQ.ado
//which was provided to me by Richard C. Phillips, rcpmd@u.washington.edu)
	if `c'==2 {
		tempvar bin
		qui gen byte `bin' = (`x1' & !`x2') ///
		  if `touse' & ( (`x1' & !`x2') | (!`x1' & `x2') )
		qui bitest `bin' = 0.5 [`weight'`exp']
		tempname p_exact
		scalar `p_exact' = r(p)
	}

//display results
	di _n as txt "Test for equality of proportions of nonzero"
	di "outcomes in matched samples (Cochran's Q):"
	di
	if "`detail'"!="" {
		di as txt %12s "Variable" " {c |}" %11s "Proportion" %11s "Count"
		di as txt "{hline 13}{c +}{hline 22}"
		local i 0
		foreach var of local varlist {
			di as txt %12s abbrev("`var'",12) " {c |}  " ///
			   as res %9.0g `T'[`++i',1] "  " %9.0g `T'[`i',2]
		}
		di as txt "{hline 13}{c BT}{hline 22}" _n
	}
	di as txt %-19s "Number of obs" " = " as res %9.0g `N'
	di as txt %-19s "Cochran's chi2(`=`c'-1')" " = " as res %9.0g `Q'[1,1]
	di as txt %-19s "Prob > chi2" " = " as res %9.4f `p'
	if `c'==2 {
		di as txt %-19s "Exact p" " = " as res %9.4f `p_exact'
	}

//return results
	ret mat T = `T'
	if `c'==2 ret sca p_exact = `p_exact'
	ret sca p = `p'
	ret sca df = `c'-1
	ret sca chi2 = `Q'[1,1]
	ret sca N = `N'

end
