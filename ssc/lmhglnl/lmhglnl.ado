*! lmhglnl V1.0 07/03/2015
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

program define lmhglnl , eclass
version 11.2

syntax varlist(min=1 max=1) [if] [in] [aw fw pw iw] , [fun(str) LAGs(int 1) vce(str) ROBust ///
 INitial(str) level(passthru) ITERate(int 0) NOLog VARiables(varlist numeric ts) VCE(passthru) * ]

gettoken yvar : varlist
qui marksample touse
qui markout `touse' `varlist' , strok
tempvar Time TimeN absE SSE Ue_ML
tempname SSEo Sig2n Sig2 N SSEo SSE lmhgl lmhglp
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
qui predict `Ue_ML' if `touse' , res
qui mkmat `Ue_ML' if `touse' , matrix(`Ue_ML')
local N = e(N)
matrix `SSE'=`Ue_ML''*`Ue_ML'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2n'=`SSEo'/`N'
qui gen `absE'=abs(`Ue_ML') if `touse'
qui regress `absE' `ZMat' if `touse' 
scalar `lmhgl'=e(mss)/((1-2/_pi)*`Sig2n')
scalar `lmhglp'= chi2tail(2, abs(`lmhgl'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** NLS Heteroscedasticity Glejser Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
di _dup(78) "-"
di as txt "- Glejser LM Test:        |E| = X" _col(40) "=" as res %9.4f `lmhgl' _col(53) as txt " P-Value > Chi2(2)" _col(73) as res %5.4f `lmhglp'
di _dup(78) "-"
ereturn scalar lmhgl= `lmhgl'
ereturn scalar lmhglp= `lmhglp'
qui cap drop `ZMat'
qui tsset `TimeN'
end

