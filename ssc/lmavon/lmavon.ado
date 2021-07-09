*! lmavon V1.0 20oct2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmavon , rclass 
version 10.1
syntax varlist [if] [in] [aw fw iw pw] , [LAGs(int 1) noCONStant vce(passthru) level(passthru)]
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
tempvar E time SRho
gen `time'=_n
qui tsset `time'
regress `yvar' `xvar' if `touse' `wgt' , `constant' `vce' `level'
scalar N=e(N)
scalar SSEo=e(rss) 
scalar Kx=e(df_m)+1
qui predict `E' if `touse' , resid
qui forval i=1/`lags' {
tempvar E`i' LEE`i' DW
qui gen `LEE`i''=L`i'.`E'*`E' if `touse'
qui summ `LEE`i'' if `touse'
scalar SSE`i'=r(sum)
scalar Rho`i'=SSE`i'/SSEo
qui gen `DW'`i'=sum((`E'-`E'[_n-`i'])^2)/sum(`E'*`E') if `touse'
local dw`i' `DW'`i'[N]
return scalar rho_`i'=Rho`i'
return scalar von_`i'=`dw`i''*N/(N-1)
 }
di as txt "{bf:{err:====================================================}}"
di as txt "{bf:{err:* Von Neumann Ratio Autocorrelation Test           *}}"
di as txt "{bf:{err:====================================================}}"
di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
di
di _dup(75) "-"
if "`lags'"!="" {
forval i=1/`lags' {
di as txt "* Rho Value for" _col(30) "AR(" `i' ") = " %9.4f Rho`i'
di as txt "* Von Neumann Ratio Test" _col(30) "AR(" `i' ") = " %9.4f `dw`i''*N/(N-1) _col(50) "df: ("  Kx  " , " N ")
di _dup(75) "-"
 }
 }
end

