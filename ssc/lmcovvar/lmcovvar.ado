*! lmcovvar V1.0 28/09/2012
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage:               http://emadstat.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

*! Sahra Khaleel A. Mickaiel
*! Professor (PhD Economics)
*! Cairo University - Faculty of Agriculture - Department of Economics - Egypt
*! Email: sahra_atta@hotmail.com
*! WebPage:               http://sahraecon.110mb.com/stata.htm
*! WebPage at IDEAS:      http://ideas.repec.org/f/pmi520.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/pmi520.htm

program define lmcovvar , rclass
version 11
syntax varlist(ts) [if] [in] , [LAgs(numlist min=1 sort integer >=1) ///
 DFK EXog(varlist ts) CONSTraints(numlist sort) NOCONSTant LUTstats ///
 ITerate(numlist max =1 integer >0 ) TOLerance(numlist max =1 >0 <1 ) ///
 NOCNSReport SMall NOISure NOBIGf Level(cilevel)]
tempvar E`var' Yb_Y`var' YMAT R4S SYY Time
tempname Ybv Yb Yv E`var' Yb_Y`var' YM RS1 RS2 RS3 RS4 RS5
tempname Y Ev E W IMn Dt YMAT Mat1 Mat2 Mat3 R2Mat Trm RSQ Sig2
tempname SSE1 SSE2 SSE3 SSE4 MSS1 MSS2 MSS3 MSS4 SST1 SST2 SST3 SST4
tempname N K NQ DF llf klag LSig2 DF2 AIC AIC0 SC SC0 HQ HQ0 FPE FPE0 Q2
tempname N1 DFF DFChi v R2_ SY R5 R4 R ADR F Chi PChi PF DF1 DF2 
 if "`tolerance'" != "" {
 local tolerance "tolerance(`tolerance')"
 }	
 if "`iterate'" != "" {
 local iterate "iterate(`iterate')"
 }	
 if "`isure'" != "" & "`constraints'" == "" {
 di as err "{cmd:noisure} cannot be specified without " "{cmd:constraints}"
 exit
 }	
 if "`nolog'" != "" & "`constraints'" == "" {
 di as err "{cmd:nolog} cannot be specified without " "{cmd:constraints}"
 exit
 }	
 if "`tolerance'" != "" & "`constraints'" == "" {
 di as err "{cmd:tolerance()} cannot be specified without " "{cmd:constraints}"
 exit
 }	
 if "`iterate'" != "" & "`constraints'" == "" {
 di as err "{cmd:iterate()} cannot be specified without " "{cmd:constraints}"
 exit
 }	
di
 marksample touse
preserve
 if "`exog'" != "" {
 markout `touse' `exog'
 }
 markout `touse' `varlist'
_rmcoll `varlist' if `touse', `noconstant'
 local varlist "`r(varlist)'"
 if "`exog'" != "" {
_rmcoll `exog' if `touse' , `noconstant'
 local exog "`r(varlist)'"
 }
 local exogl " exog(`exog') "
 if "`constraints'" == "" {
 var `varlist' if `touse' , lags(`lags') `exogl' `dfk' `small' ///
 `noconstant' `nobigf' level(`level')
 }
 else {
 var `varlist' if `touse', lags(`lags')	const(`constraints') `exogl' `noconstant' ///
 `dfk' `small' `noisure' `iterate' `tolerance' `nolog' `nobigf' level(`level')
 }
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:* (VAR) Breusch-Pagan LM Diagonal Covariance Matrix Test}}"
di _dup(78) "{bf:{err:=}}"
di as res _col(2) "Ho: Diagonal Disturbance Covariance Matrix (Independent Equations)"
di as res _col(2) "Ho: Run OLS  -  Ha: Run SUR"
tempname Sig2 Omega
matrix `Omega'= e(Sigma)
matrix `Sig2' = corr(`Omega')
matrix `Sig2' = `Sig2'*`Sig2''
scalar `N'=e(N)
local eQ=e(k_eq)
local eQ `eQ'
local lmcovdf =`eQ'*(`eQ'-1)/2
local lmcov = (trace(`Sig2')-`eQ')*`N' / 2
local lmcovp= chi2tail(`lmcovdf', abs(`lmcov'))
di
di as txt _col(5) "Lagrange Multiplier Test" _col(30) " = " as res %10.5f `lmcov'
di as txt _col(5) "Degrees of Freedom" _col(30) " = " as res %10.1f `lmcovdf'
di as txt _col(5) "P-Value > Chi2(" `lmcovdf' ")" _col(30) " = " as res %10.5f `lmcovp'
di _dup(78) "{bf:{err:=}}"
qui `cmd'
return scalar lmcov = `lmcov'
return scalar lmcovp= `lmcovp'
return scalar lmcovdf= `lmcovdf'
end
