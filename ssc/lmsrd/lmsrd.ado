*! lmsrd V1.0 25/06/2012
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email:   emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program define lmsrd , rclass 
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
tempvar E time
gen `time'=_n
qui tsset `time'
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* Ordinary Least Squares (OLS)}}"
di _dup(78) "{bf:{err:=}}"
regress `yvar' `xvar' if `touse' `wgt' , `noconstant' `vce' `level'
tempname N SSEo SSE Rho kx r2
scalar `N'=e(N)
scalar `r2'=e(r2)
scalar `SSEo'=e(rss) 
scalar `kx'=e(df_m)+1
if "`noconstant'"!="" {
scalar `kx'=e(df_m)
 }
qui predict `E' if `touse' , resid
tempvar E1 LEE1 DW
qui gen `LEE1'=L1.`E'*`E' if `touse'
qui summ `LEE1' if `touse'
scalar `SSE'=r(sum)
scalar `Rho'=`SSE'/`SSEo'
qui gen `DW'1=sum((`E'-`E'[_n-1])^2)/sum(`E'*`E') if `touse'
local dw `DW'1[`N']
return scalar rho=`Rho'
return scalar dw=`dw'
return scalar r2=`r2'
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* OLS Spurious Regression Diagnostic}}"
di _dup(78) "{bf:{err:=}}"
di as res "{bf: Ho: No Spurious Regression: R2 < DW}"
di as res "{bf: Ha:    Spurious Regression: R2 > DW}"
di
di _dup(75) "-"
di as txt "* Rho Value" _col(30) "=" %9.5f `Rho'
di as txt "* R-squared" _col(30) "=" %9.5f `r2'
di as txt "* Durbin-Watson Test" _col(30) "=" %9.5f `dw' _col(50) "df: ("  `kx'  " , " `N' ")
di _dup(75) "-"
if `r2' > `dw' {
di as res "{bf: Spurious Regression: R2 (" %5.4f `r2' ") > DW (" %5.4f `dw' ")}"
 }
if `r2' < `dw' {
di as res "{bf: No Spurious Regression: R2 (" %5.4f `r2' ") < DW (" %5.4f `dw' ")}"
 }
end
