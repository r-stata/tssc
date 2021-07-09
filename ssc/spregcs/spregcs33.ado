 program define spregcs33
 version 11.0
 qui {
 args lf $spat_ARGS
 tempvar L0 L1 L2 L3 Ro D0 D1
 gen `D0'=0
 gen `D1'=0
 replace `D0' =1 if `e(depvar)' ==spat_llt
 replace `D1' =1 if `e(depvar)' > spat_llt
 gen double `Ro'=`Rho'*w1y_`e(depvar)'
 gen double `L0'=`Rho'*spat_eigw
 gen double `L1'=`Lambda'*spat_eigw
 gen double `L2'=`Lambda'*w1y_`e(depvar)'
 gen double `L3'= `Rho'*`Lambda'*w2y_`e(depvar)'
 forvalue i=1/$spat_kx {
 tempvar X`i' XX`i'
 gen double `X`i''=`beta`i''*`:word `i' of `:colnames(spat_ols)''
 local XB "`XB'`X`i''-"
 gen double `XX`i''=`Lambda'*`beta`i''*spat_w1x_`i' 
 local ZB "`ZB'`XX`i''+"
 }
 replace `lf'=log(1-`L0') + log(1-`L1')-0.5*`D1'*log(2*_pi*`Sigma'^2) ///
 -0.5*`D1'*((`e(depvar)'-`Ro'-`L2'+`L3'-`XB'`beta0'+`ZB'`Lambda'*`beta0')/`Sigma')^2 ///
 +`D0'*log(1-normal((`e(depvar)'-`Ro'-`L2'+`L3'-`XB'`beta0'+`ZB'`Lambda'*`beta0')/`Sigma'))
 }
 end
