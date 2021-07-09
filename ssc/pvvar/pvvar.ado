***************************
**   Maximo Sangiacomo   **
** Feb 2013. Version 1.0 **
***************************
program define pvvar, rclass
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
local generate d
}
gettoken v_cf v_rate: varlist
confirm new var `v_cf'_`generate'`due'
qui gen `v_cf'_`generate'`due'=.
mata: pvvar("`v_cf'", "`v_rate'", "`v_cf'_`generate'`due'", `due', "`touse'")
disp as txt "Present Value = " as res scalar(PV)
return scalar PV = scalar(PV)
return scalar due = scalar(due)
end

mata:
void pvvar(string scalar v_cf,
string scalar v_rate,
string scalar v_cf_d,
real scalar due,
string scalar touse)
{
	st_view(vcf=., ., v_cf, touse)
	st_view(vr=., ., v_rate, touse)
	st_view(vcfd=., ., v_cf_d, touse)
// validate rate
	for (i=1;i<=rows(vr);i++) {
		if (vr[i]<0|vr[i]>1) {
		errprintf("Each discount rate in {bf:%s} should be a number between 0 and 1\n", v_rate)
		exit(198)	
		}
	}
	vrd = J(rows(vr), 1, 0)
	if (due==0) {
		for (i=1;i<=rows(vrd);i++) {
			vrd[i] =(1+vr[i])^(-i)
		}
	}
	else {
		for (i=1;i<=rows(vrd);i++) {
			j = i - 1 
			vrd[i] =(1+vr[i])^(-j)
		}
	}
	
	vpv = vcf'*vrd
	vcfd[.,.]=vcf:*vrd
	st_numscalar("PV", vpv)
	st_numscalar("due", due)
}
end
