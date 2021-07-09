*! lmhhpnl V1.0 06/10/2014
*! 
*! Emad Abd Elmessih Shehata
*! Professor (PhD Economics)
*! Agricultural Research Center - Agricultural Economics Research Institute - Egypt
*! Email: emadstat@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/psh494.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/psh494.htm

*! Sahra Khaleel A. Mickaiel
*! Professor (PhD Economics)
*! Cairo University - Faculty of Agriculture - Department of Economics - Egypt
*! Email: sahra_atta@hotmail.com
*! WebPage at IDEAS:      http://ideas.repec.org/f/pmi520.html
*! WebPage at EconPapers: http://econpapers.repec.org/RAS/pmi520.htm

program define lmhhpnl , eclass
version 11.2
syntax varlist(min=1 max=1) [if] [in] [aw fw pw iw] , ///
 [fun(str) LAGs(int 1) vce(str) INitial(str) level(passthru) ///
 ITERate(int 0) NOLog VARiables(varlist numeric ts) ROBust VCE(passthru) * ]
tempvar Time TimeN Yh Yh2 E2 LYh LYh2 Yh_ML Ue_ML
tempname N lmhhp1 lmhhp1p lmhhp2 lmhhp2p lmhhp3 lmhhp3p
gettoken yvar : varlist
qui marksample touse
qui markout `touse' `varlist' , strok
 local wgt
 if "`weight'`exp'" != "" {
 local wgt "[`weight'`exp']"
 }
qui gen `Time'=_n if `touse'
qui gen `TimeN'=_n
qui tsset `Time'
 nl ( `yvar' = `fun' )  if `touse' `wgt' , leave initial(`initial') `vce' `level' ///
 iterate(`iterate') `nolog' `variables' `robust'
local ZMat `e(params)'
qui predict `Yh_ML' if `touse' , yhat
qui predict `Ue_ML' if `touse' , res
qui gen `Yh'=`Yh_ML' if `touse'
qui gen `Yh2'=`Yh_ML'^2 if `touse'
qui gen `LYh2'=ln(`Yh2') if `touse'
qui gen `E2'=`Ue_ML'^2 if `touse'
qui regress `E2' `Yh' if `touse'
scalar `lmhhp1'=e(N)*e(r2)
scalar `lmhhp1p'= chi2tail(1, abs(`lmhhp1'))
qui regress `E2' `Yh2' if `touse'
scalar `lmhhp2'=e(N)*e(r2)
scalar `lmhhp2p'= chi2tail(1, abs(`lmhhp2'))
qui regress `E2' `LYh2' if `touse'
scalar `lmhhp3'=e(N)*e(r2)
scalar `lmhhp3p'= chi2tail(1, abs(`lmhhp3'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** NLS Heteroscedasticity Hall-Pagan Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
di _dup(78) "-"
di as txt "- Hall-Pagan LM Test:      E2 = Yh" _col(40) "=" as res %9.4f `lmhhp1' _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f `lmhhp1p'
di as txt "- Hall-Pagan LM Test:      E2 = Yh2" _col(40) "=" as res %9.4f `lmhhp2' _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f `lmhhp2p'
di as txt "- Hall-Pagan LM Test:      E2 = LYh2" _col(40) "=" as res %9.4f `lmhhp3' _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f `lmhhp3p'
di _dup(78) "-"
ereturn scalar lmhhp1= `lmhhp1'
ereturn scalar lmhhp1p= `lmhhp1p'
ereturn scalar lmhhp2= `lmhhp2'
ereturn scalar lmhhp2p= `lmhhp2p'
ereturn scalar lmhhp3= `lmhhp3'
ereturn scalar lmhhp3p= `lmhhp3p'
qui cap drop `ZMat'
qui tsset `TimeN'
end
