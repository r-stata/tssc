*! version 1.0.1
*! LSTAR Model Test Program for the Command tslstarmod
*! Diallo Ibrahima Amadou
*! All comments are welcome, 18Sep2019



capture program drop tslstarmodtest
program tslstarmodtest, rclass sortpreserve
	version 15.1
	syntax varlist(ts) [if] [in], thresv(varname numeric ts) maxlags(integer)
	marksample touse
    markout `touse' `thresv'
    gettoken lhs rhs : varlist
	quietly {
		tsset
		regress `lhs' `rhs' if `touse'
		tempvar ereslr
		predict double `ereslr' if `touse', residuals
		tsset
		regress `ereslr' `rhs' c.(`rhs')#c.`thresv' c.(`rhs')#c.`thresv'#c.`thresv' c.(`rhs')#c.`thresv'#c.`thresv'#c.`thresv' if `touse'
		tempname xsqstat degfls probxsqstat
		scalar `xsqstat' = e(N)*e(r2)
		scalar `degfls' = 3*`maxlags'
		scalar `probxsqstat' = chi2tail(`degfls',`xsqstat')
	}	
    return clear	
    display
    display in gr "Lagrange Multiplier Test for the Existence of LSTAR Model"
    display
    display _skip(4) in gr "Chi2(" as res 2 as txt ")" _skip(1) as txt "=" as res %10.4f `xsqstat'
    display in gr "Prob > chi2" _skip(1) "="  as res %10.4f `probxsqstat'
    display
    display in gr "Ho: Presence of Linearity"
    display in gr "Ha: Presence of LSTAR Model"
    return scalar chi2   = `xsqstat'
    return scalar chi2_p = `probxsqstat'
    return scalar df     = `degfls'	
	
end


