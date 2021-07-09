program define sptobitsemxt2
version 11.0
args lf $spat_ARGS
tempvar Ro D0 D1
qui gen `D0'=0
qui gen `D1'=0
qui replace `D0' =1 if `e(depvar)' ==spat_llt
qui replace `D1' =1 if `e(depvar)'  >spat_llt
qui gen double `Ro'=`Lambda'*w1y_`e(depvar)'
qui forval i=1/$spat_kx {
 tempvar X`i' XX`i'
qui gen double `X`i''=`beta`i''*`:word `i' of `:colnames(spat_ols)''
 local XB "`XB'`X`i''-"
qui gen double `XX`i''=`Lambda'*`beta`i''*spat_w1x_`i' 
 local ZB "`ZB'`XX`i''+"
 }
qui replace `lf' = -`D0'*(`Ro'+`XB'`beta0'-`ZB'`Lambda'*`beta0') ///
       +`D1'*(`e(depvar)'-`Ro'-`XB'`beta0'+`ZB'`Lambda'*`beta0') ///
         -exp(`e(depvar)'-`Ro'-`XB'`beta0'+`ZB'`Lambda'*`beta0')
end
