*! version 1.0 Austin Nichols, June 22, 2009
*! Fitting of Dagum distribution to grouped data by multinomial ML
*! Called by dagfit.ado
program define dagfit_ll
 version 8.2
 args lnf a b p
 quietly replace `lnf' = ($S_mln)*ln((1+((`b')/${S_mlz2})^(`a'))^(-(`p'))-(1+((`b')/${S_mlz1})^(`a'))^(-(`p')))
 quietly replace `lnf' = ($S_mln)*ln((1+((`b')/${S_mlz2})^(`a'))^(-(`p'))) if ${S_mlz1}==0
 quietly replace `lnf' = ($S_mln)*ln(1-((1+((`b')/${S_mlz1})^(`a'))^(-(`p')))) if ${S_mlz2}==.
 tempvar sum
 qui g double `sum' =lngamma(sum(1+$S_mln))
 qui count if `lnf'<.
 quietly replace `lnf' = `sum'[_N]/r(N) +`lnf' 
 end
exit
