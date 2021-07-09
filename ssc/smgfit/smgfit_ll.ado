*! version 1.0 Austin Nichols, June 22, 2009
*! Fitting of Singh-Maddala distribution to grouped data by multinomial ML
*! Called by smgfit.ado
program define smgfit_ll
 version 8.2
 args lnf a b q
 quietly replace `lnf' = -lngamma(1+$S_mln)+($S_mln)*ln(1-(1+(${S_mlz2}/(`b'))^(`a'))^(-(`q'))-(1-(1+(${S_mlz1}/(`b'))^(`a'))^(-(`q'))))
 quietly replace `lnf' = -lngamma(1+$S_mln)+($S_mln)*ln(1-(1+(${S_mlz2}/(`b'))^(`a'))^(-(`q'))) if ${S_mlz1}==0
 quietly replace `lnf' = -lngamma(1+$S_mln)+($S_mln)*ln(1-(1-(1+(${S_mlz1}/(`b'))^(`a'))^(-(`q')))) if ${S_mlz2}==.
 tempvar sum
 qui g double `sum' =lngamma(sum(1+$S_mln))
 qui count if `lnf'<.
 quietly replace `lnf' = `sum'[_N]/r(N) +`lnf' 
 end
exit
