*! lmabpnl V1.0 10/10/2012
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

program define lmabpnl , eclass
version 11.0
syntax varlist(min=1 max=1) [if] [in] [aw fw pw iw] , ///
 [fun(str) LAGs(int 1) vce(str) INitial(str) level(passthru) ///
 ITERate(int 0) NOLog VARiables(varlist numeric ts) ROBust VCE(passthru) * ]
gettoken yvar : varlist
qui marksample touse
qui markout `touse' `varlist' , strok
tempvar E EE Eo Time TimeN U Ue_ML U2 E LE LEo SBB SRho
tempname E E1 EE1 Eo N SSEo Rho BB SSE SBBs SRhos lmabp
 local wgt
 if "`weight'`exp'" != "" {
 local wgt "[`weight'`exp']"
 }
qui gen `Time'=_n if `touse'
qui gen `TimeN'=_n
qui tsset `Time'
 nl ( `yvar' = `fun' )  if `touse' `wgt' , initial(`initial') `vce' `level' ///
 iterate(`iterate') `nolog' `variables' `robust'
qui predict `Ue_ML' if `touse' , res
qui mkmat `Ue_ML' if `touse' , matrix(`Ue_ML')
local N = e(N)
matrix `SSE'=`Ue_ML''*`Ue_ML'
scalar `SSEo'=`SSE'[1,1]
qui gen `E' =`Ue_ML' if `touse'
cap drop `LE'*
qui forvalue i=1/`lags' {
tempvar E`i' EE`i' LE`i' DE`i' LEE`i'
 gen `E`i''=`E'^`i' if `touse'
 gen `LE`i'' =L`i'.`E' if `touse'
 gen `LEE`i''=L`i'.`E'*`E' if `touse'
 summ `LEE`i'' if `touse'
scalar `SSE'`i'=r(sum)
scalar `Rho'`i'=`SSE'`i'/`SSEo'
scalar `BB'`i'=`Rho'`i'^2/(`N'-`i')
 summ `E`i'' if `touse'
scalar `SSE'`i'=r(sum)
 gen `DE`i''=(`E'-`E'[_n-1])^2 if `touse'
 summ `DE`i'' if `touse'
scalar `SSE'`i'=r(sum)
 }
qui gen double `SBB' = . if `touse'
qui gen double `SRho'= . if `touse'
scalar `SBBs' = 0
scalar `SRhos'= 0
qui forvalue i=1/`lags' {
qui replace `SRho' = `Rho'`i'^2 if `touse'
summ `SRho' if `touse' , meanonly
qui replace `SRho' = r(mean) if `touse'
summ `SRho' if `touse' , meanonly
scalar `SRhos' = `SRhos' + r(mean)
scalar `lmabp'`i'=`N'*`SRhos'
 }
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** NLS Autocorrelation Box-Pierce Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
di _dup(78) "-"
if "`lags'"!="" {
forvalue i=1/`lags' {
di as txt "- Rho Value for Order(" `i' ")" _col(40) "AR(" `i' ")=" as res %8.4f `Rho'`i'
ereturn scalar rho`i'=`Rho'`i'
di as txt "- Box-Pierce LM Test" _col(40) "AR(" `i' ")=" as res %8.4f `lmabp'`i' _col(56) as txt "P-Value >Chi2(`i')" _col(73) as res %5.4f chi2tail(`i', abs(`lmabp'`i'))
ereturn scalar lmabp`i'=`lmabp'`i'
ereturn scalar lmabpp`i'=chi2tail(`i', abs(`lmabp'`i'))
di _dup(78) "-"
 }
 }
qui tsset `TimeN'
end

