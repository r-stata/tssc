capture program drop equation
program define equation
version 9
syntax [, Format(string)]
qui {
	tempname _colA
	matrix `_colA'=e(b)
	local _colnames: colnames `_colA'
	local i=1
	if "`format'" == "" {
		local format1="4.2f"
	}
	else {
		local format1=subinstr("`format'","%","",.)
	}
}
di _n
foreach var of local _colnames {
	if "`var'"~="_cons" {
		if `i'==1 {
			di as result e(depvar) " = " %`format1' _coef["`var'"] "*`var'" _c
		}
		else if _coef["`var'"]>=0 {
			di as result " + " %`format1' _coef["`var'"] "*`var'" _c
		}
		else {
			di as result " - " %`format1' (-1)*_coef["`var'"] "*`var'" _c
		}
	}
	else if _coef["`var'"]<0 {
		di as result " - " %`format1' (-1)*_coef["`var'"] _c
	}
	else {
		di as result " + " %`format1' _coef["`var'"] _c
	}
	local i=`i'+1
}
di _n
end
