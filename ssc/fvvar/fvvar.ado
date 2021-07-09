***************************
**   Maximo Sangiacomo   **
** Feb 2013. Version 1.0 **
***************************
program define fvvar, rclass
version 10
syntax varlist(min=2 max=2 numeric) [if] [in] [, GENerate(string) due(integer 0) ]
marksample touse
markout `touse' `time'
quietly count if `touse'
if `r(N)' == 0 error 2000
*Due
if (`due'!=0&`due'!=1) {
disp as err "{bf:due} should be one (1) or zero (0)"
exit 198
}
*Gen
if ("`generate'"=="") {
local generate c
}
gettoken v_cf v_rate: varlist
confirm new var `v_cf'_`generate'`due'
qui gen `v_cf'_`generate'`due'=.
mata: fvvar("`v_cf'", "`v_rate'", "`v_cf'_`generate'`due'", `due', "`touse'")
disp as txt "Future Value = " as res scalar(FV)
return scalar FV = scalar(FV)
return scalar due = scalar(due)
end

mata:
void fvvar(string scalar v_cf,
string scalar v_rate,
string scalar v_cf_c,
real scalar due,
string scalar touse)
{
	st_view(vcf=., ., v_cf, touse)
	st_view(vr=., ., v_rate, touse)
	st_view(vcfc=., ., v_cf_c, touse)
// validate rate
	for (i=1;i<=rows(vr);i++) {
		if (vr[i]<0|vr[i]>1) {
		errprintf("Each discount rate in {bf:%s} should be a number between 0 and 1\n", v_rate)
		exit(198)	
		}
	}
	vrc = J(rows(vr), 1, 0)
	n = rows(vr)
	if (due==0) {
		for (i=1;i<=rows(vrc);i++) {
			vrc[i] =(1+vr[i])^(n-i)
		}
	}
	else {
		for (i=1;i<=rows(vrc);i++) {
			j = n + 1 - i 
			vrc[i] =(1+vr[i])^(j)
		}
	}
	
	vfv = vcf'*vrc
	vcfc[.,.]=vcf:*vrc
	st_numscalar("FV", vfv)
	st_numscalar("due", due)
}
end
