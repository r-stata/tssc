*! lmavonnl V1.0 28/09/2012
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

program define lmavonnl , eclass
version 11.0
syntax varlist(min=1 max=1) [if] [in] [aw fw pw iw] , ///
 [fun(str) LAGs(int 1) vce(str) INitial(str) level(passthru) ///
 ITERate(int 0) NOLog VARiables(varlist numeric ts) ROBust VCE(passthru) * ]
gettoken yvar : varlist
qui marksample touse
qui markout `touse' `varlist' , strok
tempvar DW EE Eo Time TimeN U Ue_ML U2 E E2 E3 E4 LE LEo
tempname E E1 EE1 Eo N kx SSEo Rho lmadw SSE
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
scalar `kx' =e(N)-e(df_r)
matrix `SSE'=`Ue_ML''*`Ue_ML'
scalar `SSEo'=`SSE'[1,1]
qui gen `E' =`Ue_ML' if `touse'
cap drop `LE'*
qui forvalue i=1/`lags' {
tempvar E`i' EE`i' LE`i' LEo`i' LEE`i'
 gen `E`i''=`E'^`i' if `touse'
 gen `LEo`i''=L`i'.`E' if `touse'
qui replace `LEo`i''= 0 in 1/`i'
 gen `LE`i'' =L`i'.`E' if `touse'
 gen `LEE`i''=L`i'.`E'*`E' if `touse'
 summ `LEE`i'' if `touse'
scalar `SSE'`i'=r(sum)
scalar `Rho'`i'=`SSE'`i'/`SSEo'
 gen `DW'`i'=sum((`E'-`E'[_n-`i'])^2)/sum(`E'*`E') if `touse'
scalar `lmadw'`i'= `DW'`i'[`N']
 }
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** NLS Autocorrelation Von Neumann Ratio Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: No Autocorrelation - Ha: Autocorrelation}"
di _dup(78) "-"
if "`lags'"!="" {
forvalue i=1/`lags' {
di as txt "- Rho Value for Order(" `i' ")" _col(40) "AR(" `i' ")=" as res %8.4f `Rho'`i'
ereturn scalar rho`i'=`Rho'`i'
di as txt "- Von Neumann Ratio Test" _col(40) "AR(" `i' ")=" as res %8.4f `lmadw'`i'*`N'/(`N'-1) _col(56) "df: ("  `kx'  " , " `N' ")
ereturn scalar lmavon`i'=`lmadw'`i'*`N'/(`N'-1)
di _dup(78) "-"
 }
 }
qui tsset `TimeN'
end
