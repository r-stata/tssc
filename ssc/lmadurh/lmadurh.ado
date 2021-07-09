*! lmadurh V1.0 20oct2011
*! Emad Abd Elmessih Shehata
*! Assistant Professor
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage: http://emadstat.110mb.com/stata.htm

program define lmadurh , rclass 
version 10.1
syntax varlist [if] [in] [aw fw iw pw] , [dlag(int 1) noCONStant vce(passthru) level(passthru)]
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
tempvar E EE time Ea Ea1 Es Es1 DW WS DX_ DY_ LE Eo DE LEo SBB SRho
tempname v vy1
gen `time'=_n if `touse'
qui tsset `time'
regress `yvar' `xvar' if `touse' `wgt' , `constant' `vce' `level'
scalar N=e(N)
qui mat `v'= e(V)
qui predict `E' if `touse' , resid
qui matrix `vy1' = `v'[`dlag'..`dlag', `dlag'..`dlag']
scalar vy1=`vy1'[1,1]
tempvar E1 EE1 LE1 LEo1 DE1 LEE1
qui gen `LE1' =L1.`E' if `touse'

qui reg `E' `LE1' if `touse' , noconst
scalar Po= _b[`LE1']
local durho=Po*sqrt(N/(1-N*vy1))
local hrvho=Po^2*(N/(1-N*vy1))
qui prais `yvar' `xvar' if `touse' , rhotype(regress) twostep
scalar SSEa=e(rss)
qui predict `Ea' if `touse' , r
scalar Pa= e(rho)
local waldt=Pa/(sqrt((1-Pa^2)/N))
local waldchi=Pa^2/((1-Pa^2)/N)
qui gen `Es'=`Ea' - Po * L.`Ea' if `touse'
qui replace `Es'=`Ea' in 1/1 if `touse'
qui gen `Es1'=L1.`Es' if `touse'
qui reg `Es' `Es1' if `touse' , noconst
scalar Pa1= _b[`Es1']
local durha=Pa1*sqrt(N/(1-(N*((1-(Pa^2))/N))))
local hrvha=Pa1^2*(N/(1-(N*((1-(Pa^2))/N))))
di as txt "{bf:{err:============================================================}}"
di as txt "{bf:{err:* Dynamic Autocorrelation Tests after (OLS-ALS) Regression *}}"
di as txt "{bf:{err:============================================================}}"
di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
di
if `durho' ==. {
di _dup(70) "-"
di as txt "* Durbin h Test cannot be computed"
 }
if `durho' != . {
di _dup(70) "-"
di as txt "* Durbin  h Test" _col(33) "AR(1) = " %9.4f `durho' _col(55) "P>Z " _col(65) %5.4f (1-normal(abs(`durho')))
 } 
di as txt "* Harvey LM Test" _col(33) "AR(1) = " %9.4f `hrvho' _col(55) "P>Chi2(1) " _col(65) %5.4f chiprob(1,abs(`hrvho'))
di _dup(70) "-"
di "* Wald    T Test" _col(33) "AR(1) = " %9.4f `waldt' _col(55) "P>Z " _col(65) %5.4f (1-normal(abs(`waldt')))
di "* Wald Chi2 Test" _col(33) "AR(1) = " %9.4f `waldchi' _col(55) "P>Z " _col(65) %5.4f chiprob(1,abs(`waldchi'))
di _dup(70) "-"
di "* Durbin  h Test after ALS(1)" _col(33) "AR(1) = " %9.4f `durha' _col(55) "P>Z " _col(65) %5.4f (1-normal(abs(`durha')))
di "* Harvey LM Test after ALS(1)" _col(33) "AR(1) = " %9.4f `hrvha' _col(55) "P>Chi2(1) " _col(65) %5.4f chiprob(1,abs(`hrvha'))
di _dup(70) "-"
return scalar waldchi=`waldchi'
return scalar waldchip= chiprob(1,abs(`waldchi'))
return scalar waldt=`waldt'
return scalar waldtp= (1-normal(abs(`waldt')))
return scalar hrvha=`hrvha'
return scalar durhap=chiprob(1,abs(`hrvha'))
return scalar hrvho=`hrvho'
return scalar durhop=chiprob(1,abs(`hrvho'))
return scalar durho=`durho'
return scalar durhop=(1-normal(abs(`durho')))
return scalar durha=`durha'
return scalar durhop=(1-normal(abs(`durha')))
end
