*! lmhharv V1.0 15jan2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmhharv , rclass 
version 10.1
syntax varlist [if] [in] [aw fw iw pw] , [NOCONStant vce(passthru) level(passthru)]
marksample touse
tempvar `varlist'
gettoken yvar xvar : varlist
 if "`weight'" != "" {
 local wgt "[`weight'`exp']"
 if "`weight'" == "pweight" {
 local awgt "[aw`exp']"
 }
 else local awgt "`wgt'"
 }
tempvar E E2 LnE2 absE time
gen `time'=_n
qui tsset `time'
regress `yvar' `xvar' if `touse' `wgt' , `noconstant' `vce' `level'
qui predict `E'  if `touse' , res
qui gen `E2'=`E'^2 if `touse'
qui gen `LnE2'=log(`E2') if `touse'
qui regress `LnE2' `xvar' if `touse'
local lmh=e(mss)/4.9348
local df=e(df_m)
local lmhp=chiprob(`df',abs(`lmh'))
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* OLS Harvey Lagrange Multiplier Heteroscedasticity Test}}"
di _dup(78) "{bf:{err:=}}"
di as res "{bf: Ho: No Heteroscedasticity - Ha: Heteroscedasticity}"
di
di as txt _col(5) "Harvey LM Test" _col(30) " = " as res %10.5f `lmh'
di as txt _col(5) "Degrees of Freedom" _col(30) " = " as res %10.1f `df'
di as txt _col(5) "P-Value > Chi2(" `df' ")" _col(30) " = " as res %10.5f `lmhp'
return scalar lmh = `lmh'
return scalar lmhp= `lmhp'
return scalar lmhdf= `df'
end
