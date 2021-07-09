program define spregsemxt1
version 11.0
args lf $spat_ARGS
tempvar Ro Rho D0 D1
qui gen `D0'=0
qui gen `D1'=0
qui replace `D0' =1 if `e(depvar)' ==spat_llt
qui replace `D1' =1 if `e(depvar)' >spat_llt
qui gen double `Ro'=`Lambda'*spat_eigw 
qui gen double `Rho'=`Lambda'*w1y_`e(depvar)'
qui forval i=1/$spat_kx {
 tempvar X`i' XX`i'
qui gen double `X`i''=`beta`i''*`:word `i' of `:colnames(spat_ols)''
 local XB "`XB'`X`i''-"
qui gen double `XX`i''=`Lambda'*`beta`i''*spat_w1x_`i' 
 local ZB "`ZB'`XX`i''+"
 }
qui replace `lf'=log(1-`Ro')-0.5*`D1'*log(2*_pi*`Sigma'^2)  ///
         -0.5*`D1'*((`e(depvar)'-`Rho'-`XB'`beta0'+`ZB'`Lambda'*`beta0')/`Sigma')^2 ///
 +`D0'*log(1-normal((`e(depvar)'-`Rho'-`XB'`beta0'+`ZB'`Lambda'*`beta0')/`Sigma'))
end

