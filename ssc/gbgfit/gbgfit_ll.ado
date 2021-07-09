program define gbgfit_ll
 version 8.2
 args lnf a b p q
 quietly replace `lnf' = ($S_mln)*ln(ibeta(`p',`q',(${S_mlz2}/`b')^`a'/(1+(${S_mlz2}/`b')^`a'))-ibeta(`p',`q',(${S_mlz1}/`b')^`a'/(1+(${S_mlz1}/`b')^`a')))
 quietly replace `lnf' = ($S_mln)*ln(ibeta(`p',`q',(${S_mlz2}/`b')^`a'/(1+(${S_mlz2}/`b')^`a'))) if ${S_mlz1}==0
 quietly replace `lnf' = ($S_mln)*ln(ibeta(`p',`q',(${S_mlz1}/`b')^`a'/(1+(${S_mlz1}/`b')^`a'))) if ${S_mlz2}==.
 tempvar sum
 qui g double `sum' =lngamma(sum(1+$S_mln))
 qui count if `lnf'<.
 quietly replace `lnf' = `sum'[_N]/r(N) +`lnf' 
 end
exit

