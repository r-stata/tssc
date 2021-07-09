*! lmnjb V2 20oct2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmnjb , rclass
version 10
syntax varlist [if] [in] [aw fw iw pw] , [noCONStant vce(passthru) level(passthru)]
marksample touse
tempvar `varlist'
tempvar E
gettoken yvar xvar : varlist

 if "`weight'" != "" {
 local wgt "[`weight'`exp']"
 if "`weight'" == "pweight" {
 local awgt "[aw`exp']"
 }
 else	local awgt "`wgt'"
 }

di as txt "{bf:{err:============================================}}"
di as txt "{bf:{err:* Jarque-Bera Non Normality LM Test        *}}"
di as txt "{bf:{err:============================================}}"
regress `yvar' `xvar' if `touse' `wgt' , `constant' `vce' `level'
qui predict `E' if `touse' , res
qui summ `E' if `touse' , det
scalar lmnjb = (r(N)/6)*((r(skewness)^2)+[(1/4)*(r(kurtosis)-3)^2])
scalar p  = chiprob(2, lmnjb)
scalar df = 2
di as txt _col(5) "{bf:Lagrange Multiplier Jarque-Bera Normality Test}"
di
di as txt _col(5) "Ho: Normality in Error Distribution"
di as txt _col(5) "Ha: Non Normality in Error Distribution"
di
di as txt _col(5) "LM Test      = " as res %7.5f lmnjb
di as txt _col(5) "DF Chi2      = " as res %7.0f 2
di as txt _col(5) "Prob. > Chi2 = " as res %7.5f p
return scalar df = df
return scalar p = p
return scalar lmn = lmnjb
end

