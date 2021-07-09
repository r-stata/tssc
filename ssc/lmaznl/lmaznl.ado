*! lmaznl V1.0 08/08/2015
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

program define lmaznl , eclass
version 11.2
syntax varlist(min=1 max=1) [if] [in] [aw fw pw iw] , ///
 [fun(str) LAGs(int 1) vce(str) INitial(str) level(passthru) ///
 ITERate(int 0) NOLog VARiables(varlist numeric ts) ROBust VCE(passthru) * ]
gettoken yvar : varlist
qui marksample touse
qui markout `touse' `varlist' , strok
tempvar EE Eo DE Time TimeN U Ue_ML U2 E LE LEo
tempname E E1 Eo N SSEo Rho lmaz SSE
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
tempvar E`i' EE`i' LE`i' LEo`i' DE`i' LEE`i'
 gen `E`i''=`E'^`i' if `touse'
 gen `LEo`i''=L`i'.`E' if `touse'
 gen `LEE`i''=L`i'.`E'*`E' if `touse'
 summ `LEE`i'' if `touse'
scalar `SSE'`i'=r(sum)
scalar `Rho'`i'=`SSE'`i'/`SSEo'
scalar `lmaz'`i'=`Rho'`i'*sqrt(`N')
 }
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** NLS Autocorrelation Z Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
di _dup(78) "-"
if "`lags'"!="" {
forvalue i=1/`lags' {
di as txt "- Rho Value for Order(" `i' ")" _col(40) "AR(" `i' ")=" as res %8.4f `Rho'`i'
ereturn scalar rho`i'=`Rho'`i'
di as txt "- Z Test" _col(40) "AR(" `i' ")=" as res %8.4f `lmaz'`i' _col(56) as txt "P-Value >Chi2(`i')" _col(73) as res %5.4f chi2tail(`i', abs(`lmaz'`i'))
ereturn scalar lmaz`i'=`lmaz'`i'
ereturn scalar lmazp`i'=chi2tail(`i', abs(`lmaz'`i'))
di _dup(78) "-"
 }
 }
qui tsset `TimeN'
end

