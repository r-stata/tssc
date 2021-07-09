*! lmharchnl V1.0 06/08/2015
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

program define lmharchnl , eclass
version 11.2
syntax varlist(min=1 max=1) [if] [in] [aw fw pw iw] , ///
 [fun(str) LAGs(int 1) vce(str) INitial(str) level(passthru) ///
 ITERate(int 0) NOLog VARiables(varlist numeric ts) ROBust VCE(passthru) * ]
tempvar Time TimeN E2 Ue_MLo LE U U2 Ue Ue_ML
tempname lmharch lmharchp
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
 nl ( `yvar' = `fun' )  if `touse' `wgt' , initial(`initial') `vce' `level' ///
 iterate(`iterate') `nolog' `variables' `robust'
qui predict `Ue_ML' if `touse' , res
qui mkmat `Ue_ML' if `touse' , matrix(`Ue_ML')
qui gen `E2'=`Ue_ML'^2 if `touse'
di
di _dup(78) "{bf:{err:=}}"
di as txt "{bf:{err:*** NLS Heteroscedasticity Engle (ARCH) Test}}"
di _dup(78) "{bf:{err:=}}"
di as txt "{bf: Ho: Homoscedasticity - Ha: Heteroscedasticity}"
di _dup(78) "-"
qui cap drop `LE'*
 forvalue i = 1/`lags' {
qui gen `LE'`i'=L`i'.`E2' if `touse'
qui regress `E2' `LE'* if `touse'
scalar `lmharch'`i'=e(r2)*e(N)
scalar `lmharchp'`i'= chi2tail(`i', abs(`lmharch'`i'))
di as txt "- Engle LM ARCH Test AR(`i') E2=E2_1-E2_`i'" _col(40) "=" as res %9.4f `lmharch'`i' _col(53) as txt " P-Value > Chi2(`i')" _col(73) as res %5.4f `lmharchp'`i'
 }
di _dup(78) "-"
qui forvalue i = 1/`lags' {
ereturn scalar lmharchp`i'= `lmharchp'`i'
ereturn scalar lmharch`i'= `lmharch'`i'
 }
qui tsset `TimeN'
end

