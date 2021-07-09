*! lmalb V1.0 10nov2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmalb , rclass 
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
tempvar E EE time LE Eo SBB
gen `time'=_n if `touse'
qui tsset `time'
regress `yvar' `xvar' if `touse' `wgt' , `constant' `vce' `level'
scalar N=e(N)
scalar SSEo=e(rss) 
scalar Kx=e(df_m)+1
qui predict `E' if `touse' , resid
qui forval i=1/`lags' {
tempvar LEE`i'
qui gen `LEE`i''=L`i'.`E'*`E' if `touse'
qui summ `LEE`i'' if `touse'
scalar SSE`i'=r(sum)
scalar Rho`i'=SSE`i'/SSEo
scalar BB`i'=Rho`i'^2/(N-`i')
 }
qui gen double `SBB' = . if `touse'
scalar SBBs = 0
qui forval i=1/`lags' {
replace `SBB' = BB`i' if `touse'
summ `SBB' if `touse' , meanonly
replace  `SBB' = r(mean) if `touse'
summ `SBB' if `touse' , meanonly
scalar SBBs = SBBs + r(mean)
scalar lb`i'=N*(N+2)*SBBs
return scalar rho_`i'=Rho`i'
return scalar lbp_`i'=chiprob(`i',abs(lb`i'))
return scalar lb_`i'=lb`i'
 }
di as txt "{bf:{err:=============================================}}"
di as txt "{bf:{err:* Ljung-Box Autocorrelation LM Test         *}}"
di as txt "{bf:{err:=============================================}}"
di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
di
di _dup(65) "-"
if "`lags'"!="" {
forval i=1/`lags' {
di as txt "* Rho Value for" _col(25) "AR(" `i' ") = " %9.4f Rho`i'
di as txt "* Ljung-Box LM Test" _col(25) "AR(" `i' ") = " %9.4f lb`i' _col(45) "P>Chi2(`i')" _col(55) %5.4f chiprob(`i',abs(lb`i'))
di _dup(65) "-"
 }
 }
end

