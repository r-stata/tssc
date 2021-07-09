*! lmnwhite V1.0 15jan2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmnwhite , rclass 
version 10.1
syntax varlist [if] [in] [aw fw iw pw] , [NOCONStant vce(passthru) level(passthru)]
tempvar `varlist'
gettoken yvar xvar : varlist
marksample touse
tempvar E Hat U2 DE LDE DF DF1 Es Yt U E2 Time
gen `Time' = _n  
qui tsset `Time'
 if "`weight'" != "" {
 local wgt "[`weight'`exp']"
 if "`weight'" == "pweight" {
 local awgt "[aw`exp']"
 }
 else	local awgt "`wgt'"
 }
regress `yvar' `xvar' if `touse' `wgt' , `noconstant' `vce' `level'
local N=e(N)
scalar SSEo=e(rss) 
if "`noconstant'"!="" {
local K=e(df_m)
 }
else {
local K=e(df_m)+1
 }
qui predict `E'  if `touse' , res
qui predict `Hat' if `touse' , hat
qui predict `U' if `touse' , res
qui cap drop `U2'
qui gen `U2'=`E'*`E' if `touse' 
qui regress `U2' `Hat' if `touse'
qui scalar R2W=e(r2)
qui summ `E'  if `touse' , det
scalar Eb=r(mean)
scalar Sk=r(skewness)
scalar Ku=r(kurtosis)
scalar N=r(N)
scalar GK = ((Sk^2/6)+((Ku-3)^2/24))
local lmn=N*(R2W+GK)
local lmnp= chiprob(2,`lmn')
local df= 2
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* OLS White Lagrange Multiplier Non Normality Test}}"
di _dup(78) "{bf:{err:=}}"
di as res _col(5) "Ho: Normality - Ha: Non Normality"
di
di as txt _col(5) "White LM Test" _col(30) " = " as res %10.5f `lmn'
di as txt _col(5) "Degrees of Freedom" _col(30) " = " as res %10.1f `df'
di as txt _col(5) "P-Value > Chi2(" `df' ")" _col(30) " = " as res %10.5f `lmnp'
return scalar lmn = `lmn'
return scalar lmn= `lmnp'
return scalar lmndf= `df'
end
