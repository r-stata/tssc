*! lmhcwnl V1.0 28/09/2012
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

program define lmhcwnl , eclass
version 11.0
syntax varlist(min=1 max=1) [if] [in] [aw fw pw iw] , ///
 [fun(str) LAGs(int 1) vce(str) INitial(str) level(passthru) ///
 ITERate(int 0) NOLog VARiables(varlist numeric ts) ROBust VCE(passthru) * ]
gettoken yvar : varlist
qui marksample touse
qui markout `touse' `varlist' , strok
tempvar Time TimeN Yh U2 E E2 SSE Time U U2 Yh_ML Ue_ML
tempname E Q S SSEo h mh vh Sig2n Yh N SSE
tempname lmhcw1 cwdf1 lmhcw1p lmhcw2 cwdf2 lmhcw2p LMh_cwx
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
qui mkmat `Ue_ML' if `touse' , matrix(`Ue_ML')
local N = e(N)
matrix `SSE'=`Ue_ML''*`Ue_ML'
scalar `SSEo'=`SSE'[1,1]
scalar `Sig2n'=`SSEo'/`N'
qui gen `E' =`Ue_ML' if `touse'
qui gen `U2' =`Ue_ML'^2/`Sig2n' if `touse'
qui regress `U2' `Yh_ML' if `touse'
scalar `lmhcw1'= e(mss)/2
scalar `cwdf1'= e(df_m)
scalar `lmhcw1p'= chi2tail(`cwdf1', abs(`lmhcw1'))
qui regress `U2' `ZMat' if `touse'
scalar `lmhcw2'= e(mss)/2
scalar `cwdf2'= e(df_m)
scalar `lmhcw2p'= chi2tail(`cwdf2', abs(`lmhcw2'))
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** NLS Heteroscedasticity Cook-Weisberg Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
di _dup(78) "-"
di as txt "- Cook-Weisberg LM Test  E2/Sig2 = Yh" _col(40) "=" as res %9.4f `lmhcw1' _col(53) as txt " P-Value > Chi2(" `cwdf1' ")" _col(73) as res %5.4f `lmhcw1p'
di as txt "- Cook-Weisberg LM Test  E2/Sig2 = X" _col(40) "=" as res %9.4f `lmhcw2' _col(53) as txt " P-Value > Chi2(" `cwdf2' ")" _col(73) as res %5.4f `lmhcw2p'
di _dup(78) "-"
di as res "*** Single Variable Tests:"
local nx : word count `ZMat'
qui regress `yvar' `ZMat' if `touse'
tokenize `ZMat'
local i 1
while `i' <= `nx' {
qui regress `U2' ``i'' if `touse'
scalar `LMh_cwx'`i' = e(mss)/2
ereturn scalar lmhcwx`i'= `LMh_cwx'`i'
ereturn scalar lmhcwxp`i'= chi2tail(1 , abs(`LMh_cwx'`i'))
di as txt "- Cook-Weisberg LM Test: E2/Sig2 = " "``i''" _col(40) "=" as res %9.4f e(lmhcwx`i') _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f e(lmhcwxp`i')
local i =`i'+1
 }
di _dup(78) "-"
di as res "*** Single Variable Tests:"
foreach i of local ZMat {
tempvar ht
qui egen `ht'`i' = rank(`i') if `touse'
qui summ `ht'`i' if `touse'
scalar `mh' = r(mean)
scalar `vh' = r(Var)
qui summ `ht'`i' [aw=`E'^2] if `touse' , meanonly
scalar `h' = r(mean)
scalar `Q'`i' = (`N'^2 / (2*(`N'-1))) * (`h'-`mh')^2/`vh'
ereturn scalar lmhq_`i'= `Q'`i'
ereturn scalar lmhqp_`i'= chi2tail(1, abs(`Q'`i'))
di as txt "- King LM Test: " "`i'" _col(40) "=" as res %9.4f `Q'`i' _col(53) as txt " P-Value > Chi2(1)" _col(73) as res %5.4f chi2tail(1, abs(`Q'`i'))
 }
di _dup(78) "-"
ereturn scalar lmhcw1= `lmhcw1'
ereturn scalar lmhcw1p= `lmhcw1p'
ereturn scalar lmhcw2= `lmhcw2'
ereturn scalar lmhcw2p= `lmhcw2p'
qui cap drop `ZMat'
qui tsset `TimeN'
end
