*! lmcovxt V2.0 25/01/2014
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

program lmcovxt, rclass
version 11
syntax varlist [if] [in] [aw fw iw pw] , ID(str) IT(str) [ NOCONStant vce(passthru) level(passthru) coll]
gettoken yvar xvar : varlist
qui marksample touse
qui markout `touse' `varlist' , strok
local both : list yvar & xvar
if "`both'" != "" {
di
di as err " {bf:{cmd:`both'} included in both LHS and RHS Variables}"
di as res " LHS: `yvar'"
di as res " RHS: `xvar'"
 exit
 }
if "`xvar'"=="" {
di as err " {bf:Independent Variable(s) must be combined with Dependent Variable}"
 exit
 }
tempname NC NT T Sig2 N min max M s E U LMCov Ms E1 Em Ti U1 Uu
tempvar Sig2 SigLM SigLMs E E2 Time TimeN U LMCov Ms E1 Em Ti U1 Uu 
 if "`coll'"=="" {
_rmcoll `varlist' if `touse' , `noconstant' `coll' forcedrop
 local varlist "`r(varlist)'"
gettoken yvar xvar : varlist
 }
di
qui _xtstrbal `id' `it' `touse'
if r(strbal) == "no" {
di as err "{bf:lmcovxt} {cmd:works only with Strongly Balanced Data}"
exit 
 }
qui xtset `id' `it'
qui gen `TimeN'=_n
qui gen `Time'=_n if `touse'
local idv "`r(panelvar)'"
local itv "`r(timevar)'"
scalar `NC'=r(imax)
scalar `NT'= r(tmax)
scalar `T' = `NT'/`NC'
qui tsset `TimeN'
qui regress `yvar' `xvar' if `touse' `wgt' , `noconstant' `vce' `level'
qui predict double `E' if `touse' , resid
qui mkmat `E' if `touse' , matrix(`E')
qui levelsof `idv' if `touse' , local(levels)
qui foreach i of local levels {
qui summ `Time' if `idv' == `i'
tempname min max M
scalar `min'=r(min)
scalar `max'=r(max)
matrix `E'`i'=`E'[`min'..`max', 1..1]
qui svmat `E'`i' , name(`E'`i')
qui svmat `E'`i' , name(`Uu'`i')
 }
qui levelsof `idv' if `touse' , local(levels)
qui foreach i of local levels {
qui foreach j of local levels {
qui gen `U'`i'`j' = `E'`i'*`E'`j' if `touse' 
qui summ `U'`i'`j' if `touse' 
tempname s`i'`j'
scalar `s`i'`j''=r(sum)
 }
 }
scalar `M'=0
qui gen `Ms'=0 if `touse' 
qui levelsof `idv' if `touse' , local(levels)
qui foreach i of local levels {
qui foreach j of local levels {
 replace `Ms'=`s`i'`j''^2/(`s`i'`i''*`s`j'`j'') if `touse'
 summ `Ms' if `i' < `j'
 tempname M`i'`j'
scalar `M`i'`j''=`M'+ r(mean)
 gen `LMCov'`i'`j'=`M`i'`j'' if `touse' 
 }
 }
tempname lmcov lmcovdf lmcovp
qui egen `LMCov'=rowtotal(`LMCov'*) in 1/1
scalar `lmcov'=`LMCov'*`NT'
scalar `lmcovdf' = `NC'*(`NC'-1)/2
scalar `lmcovp' = chi2tail(`lmcovdf', abs(`lmcov'))
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** Panel Data Breusch-Pagan Diagonal Covariance Matrix LM Test}}"
di _dup(78) "{bf:{err:=}}"
di as res _col(5) "Ho: Run OLS Regression  -  Ha: Run Panel Regression"
di
di as txt _col(5) "Lagrange Multiplier Test" _col(30) " = " as res %10.5f `lmcov'
di as txt _col(5) "Degrees of Freedom" _col(30) " = " as res %10.1f `lmcovdf'
di as txt _col(5) "P-Value > Chi2(" `lmcovdf' ")" _col(30) " = " as res %10.5f `lmcovp'
di _dup(78) "{bf:{err:=}}"
qui `cmd'
return scalar lmcov = `lmcov'
return scalar lmcovp= `lmcovp'
return scalar lmcovdf= `lmcovdf'
qui tsset `TimeN'
end
