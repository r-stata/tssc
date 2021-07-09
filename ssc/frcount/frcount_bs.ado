!* Fractional response for endogenous count variable model (bootstraping)
!* Version 1.0.5 - Minh Nguyen & Hoa Nguyen - June 2010
!* mnguyen3@worldbank.org / nguye147@msu.edu

*** Bootstraping APE for frcount model ***
capture program drop frcount_bs
program frcount_bs, eclass
	version 10
	tempname b
	qui frcount $bsrun
	mata: apefrm = _APEendo(st_matrix("e(b)"))
	mat `b' = _APE_en_all	
	local endog `e(endog)' 
	local exog `e(exog)'
	local apenames `"`endog' "`endog'_01" "`endog'_12" "`endog'_23" `exog'"'
	if ("$bscons"=="") {
		local apenames `apenames' _cons
	}
	mat colnames `b' = `apenames'
	ereturn post `b'
end
