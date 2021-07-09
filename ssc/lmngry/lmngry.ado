*! lmngry V1.0 15dec2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmngry , rclass
version 10
syntax varlist [if] [in] [aw fw iw pw] , [noCONStant vce(passthru) level(passthru)]
marksample touse
tempvar `varlist'
gettoken yvar xvar : varlist
tempvar E DE LDE DF1 Time e
gen `Time' = _n if `touse' 
qui tsset `Time'
 if "`weight'" != "" {
 local wgt "[`weight'`exp']"
 if "`weight'" == "pweight" {
 local awgt "[aw`exp']"
 }
 else	local awgt "`wgt'"
 }
regress `yvar' `xvar'  if `touse' `wgt' , `constant' `vce' `level'
qui predict `E' if `touse' , res
qui summ `E'  if `touse' , det
scalar N=r(N)
qui gen `DE'=1 if `E' > 0
qui replace `DE'=0 if `E' <= 0
qui count if `DE' > 0
scalar N1=r(N)
scalar N2=N-r(N)
local EN=(2*N1*N2)/(N1+N2)+1
local S2N=(2*N1*N2*(2*N1*N2-N1-N2))/((N1+N2)^2*(N1+N2-1))
local SN=sqrt((2*N1*N2*(2*N1*N2-N1-N2))/((N1+N2)^2*(N1+N2-1)))
qui gen `LDE'= L.`DE' if `touse' 
qui replace `LDE'=0 if `DE'==1 in 1
qui gen `DF1'= 1 if `DE' != `LDE'
qui replace `DF1'= 1 if `DE' == `LDE' in 1
qui replace `DF1'= 0 if `DF1' == .
qui count if `DF1' > 0
local Rn=r(N)
local lmngry=(`Rn'-`EN')/`SN'
local p = chiprob(2, abs(`lmngry'))
di as txt "{bf:{err:======================================}}"
di as txt "{bf:{err:* Geary Non Normality LM Runs Test   *}}"
di as txt "{bf:{err:======================================}}"
di as txt _col(5) "Ho: Normality in Error Distribution"
di as txt _col(5) "Ha: Non Normality in Error Distribution"
di
di as txt _col(5) "LM Test      = " as res %8.4f `lmngry'
di as txt _col(5) "DF Chi2      = " as res %8.0f 2
di as txt _col(5) "Prob. > Chi2 = " as res %8.4f `p'
return scalar df = 2
return scalar p = `p'
return scalar lmn = `lmngry'
end
