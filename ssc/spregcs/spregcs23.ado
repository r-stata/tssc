 program define spregcs23
 version 7.0
 qui {
 args lf $spat_ARGS
 tempvar Rho D0 D1
 gen `D0'=0
 gen `D1'=0
 replace `D0' =1 if `e(depvar)' ==spat_llt
 replace `D1' =1 if `e(depvar)'  >spat_llt
 gen double `Rho'=`Lambda'*w1y_`e(depvar)'
 forvalue i=1/$spat_kx {
 tempvar X`i' XX`i'
 gen double `X`i''=`beta`i''*`:word `i' of `:colnames(spat_ols)''
 local XB "`XB'`X`i''-"
 gen double `XX`i''=`Lambda'*`beta`i''*spat_w1x_`i' 
 local ZB "`ZB'`XX`i''+"
 }
 replace `lf' = -`D0'*(`Rho'+`XB'`beta0'-`ZB'`Lambda'*`beta0') ///
       +`D1'*(`e(depvar)'-`Rho'-`XB'`beta0'+`ZB'`Lambda'*`beta0') ///
         -exp(`e(depvar)'-`Rho'-`XB'`beta0'+`ZB'`Lambda'*`beta0')
 }
 end
