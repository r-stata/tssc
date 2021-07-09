*! theilr2 V1.0 15jan2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm
program define theilr2, eclass
version 10.0
syntax varlist [if] [in] , [NOCONStant]
tempvar COR DE DF L Q R2oS Time X0 DFF COR 
tempname Cov CovC Cr DCor eigVaL h ICOR J K LDCor N S Vec X X0 
tempvar `varlist'
marksample touse
gettoken yvar xvar : varlist
markout `touse' `varlist'
_rmdcoll `varlist' if `touse' , `noconstant'
tsunab xvar : `xvar'
tokenize `xvar'
local xvar `*'
qui cap count if `touse'
qui gen `X0'=1 if `touse'
local N = r(N)
qui gen `Time'=_n
qui tsset `Time'
local kx : word count `xvar'
scalar kx=`kx'
qui regress `yvar' `xvar' if `touse' , `noconstant'
scalar r2ols=e(r2)

qui mkmat `xvar'  if `touse' , matrix(`X')
qui corr `xvar' if `touse'
matrix `COR'=r(C)'
qui matrix symeigen `Vec' `eigVaL'=`COR'
matrix `LDCor'=log(det(`COR'))
matrix `DCor'=det(`COR')
scalar dcor=`DCor'[1,1]
qui svmat `X' , name(`X')
local XVars `X'
qui foreach var of local XVars {
qui forval i=1/`kx' {
qui const define `i' `var'`i'=0
qui cnsreg `yvar' `X'* if `touse' , constraints(`i') `noconstant'
qui scalar dfm=e(df_m)+1
qui scalar R2`i'=((dfm-1)*e(F))/((dfm-1)*e(F)+(e(N)-dfm))
 }
 }
qui gen double `R2oS' = . if `touse'
 scalar R2oSs = 0
qui forval i=1/`kx' {
qui replace `R2oS' = R2`i' if `touse'
qui sum `R2oS' if `touse' , meanonly
qui replace  `R2oS' = r(mean) if `touse'
qui sum `R2oS' if `touse' , meanonly
qui scalar R2oSs = R2oSs + r(mean)
 }
qui scalar r2th=r2ols-(`kx'*r2ols-R2oSs)
di
di _dup(65) "-"
di as txt "{bf:{err:* Theil R2 Multicollinearity Effect}}"
di as txt _col(3) "R2 = 0 No Multicollinearity - R2 = 1 Multicollinearity"
di
di as txt _col(5) "- Theil R2: " as res _col(30) "(0 < " %5.4f r2th " < 1)"
di _dup(65) "-"
ereturn scalar r2t = r2th
di
di as txt "{bf:{err:* Determinant of |X'X|:}}"
di as txt _col(3) "|X'X| = 1 No Multicollinearity - |X'X| = 0 Multicollinearity" 
di
di as txt _col(5) "Determinant of |X'X|: " as res _col(30) "(0 < " %5.4f dcor " < 1)"
di _dup(65) "-"
ereturn scalar dcor = dcor

end
