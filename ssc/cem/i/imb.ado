/*
*
* imb.ado - L1-distance balance checking
*
* Inputs: varlist: coviariates to balance on
*         treatment(): name of the treatment variable
*         breaks(): name of the break method to use.
*
*/


program define imb, rclass
version 10.1


syntax varlist [if] [in] [, TReatment(varname) breaks(string) impvar(varname) USEweights]

marksample touse

if ("`breaks'" == "") {
  if ("`r(L1_breaks)'" == "") {
    local breaks scott
  }
  else {
    local breaks "`r(L1_breaks)'"
    dis in green "(using the `breaks' break method for L1 distance)"
  }
}

if ("`useweights'" == "") {
  local uw = 0
}
else {
  local uw = 1
}

mata: imbalance("`varlist'","`breaks'","`treatment'",`uw',"`impvar'")

dis ""
dis in green "Multivariate L1 distance: " as res r(L1)
dis ""
dis in green "Univariate imbalance:"
matrix list r(imbal), noheader format(%7.5g)

return scalar L1 = r(L1)
matrix A = r(imbal)
return matrix imbal = A
return local L1_breaks = "`breaks'"


end

version 10.1
do "`c(sysdir_plus)'c/cem-mata.do"
