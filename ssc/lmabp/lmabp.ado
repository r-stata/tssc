*! lmabp V1.0 20oct2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmabp , rclass 
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
tempvar E`i' LEE`i'
qui gen `LEE`i''=L`i'.`E'*`E' if `touse'
qui summ `LEE`i'' if `touse'
scalar SSE`i'=r(sum)
scalar Rho`i'=SSE`i'/SSEo
 }
qui gen double `SRho' = . if `touse'
scalar SRhos = 0
qui forval i=1/`lags' {
replace `SRho' = Rho`i'^2 if `touse'
sum `SRho' if `touse' , meanonly
replace  `SRho' = r(mean) if `touse'
sum `SRho' if `touse' , meanonly
scalar SRhos = SRhos + r(mean)
scalar bp`i'=N*SRhos

return scalar rho_`i'=Rho`i'
return scalar bpp_`i'=chiprob(`i',abs(bp`i'))
return scalar bp_`i'=bp`i'

 }
di as txt "{bf:{err:===================================================}}"
di as txt "{bf:{err:* Box-Pierce Autocorrelation LM Test              *}}"
di as txt "{bf:{err:===================================================}}"
di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
di
di _dup(60) "-"
if "`lags'"!="" {
forval i=1/`lags' {
di as txt "* Rho Value for" _col(25) "AR(" `i' ") = " %9.4f Rho`i'
di as txt "* Box-Pierce LM Test" _col(25) "AR(" `i' ") = " %9.4f bp`i' _col(45) "P>Chi2(`i')" _col(55) %5.4f chiprob(`i',abs(bp`i'))
di _dup(60) "-"
 }
 }
end

