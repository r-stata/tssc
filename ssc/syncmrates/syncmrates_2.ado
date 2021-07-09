*! version 1.2 May 2015 E. Masset
/*test difference in mortality rates between groups subroutine*/
program syncmrates_2, rclass
version 13
syntax varlist(min=3 max=3) [iw pw] [if] [, testby(varlist max=1) t1(integer 1) t0(integer 61) *]
	tempvar touse 
	generate `touse' = 0 
	replace `touse'=1 `if' 
	quietly summ `testby' `if'															/*use max and min to build a temporary dummy*/
	local min=r(min)
    local max=r(max)
	syncmrates_1 `varlist' [`weight' `exp'] if `testby'==`min' & `touse', t0(`t0') t1(`t1') /*run mortality routine for the first group*/
	return scalar nmra=r(nmr)															/*save the results for the first group*/
	return scalar pmra=r(pmr)
	return scalar imra=r(imr)
	return scalar cmra=r(cmr)
	return scalar u5mra=r(u5mr)
	syncmrates_1 `varlist' [`weight' `exp'] if `testby'==`max' & `touse', t0(`t0') t1(`t1')	/*run mortality routing for the second group*/
	return scalar nmrb=r(nmr)															/*save the results for the second group*/
	return scalar pmrb=r(pmr)
	return scalar imrb=r(imr)
	return scalar cmrb=r(cmr)
	return scalar u5mrb=r(u5mr)
end
