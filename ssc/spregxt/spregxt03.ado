 program define spregxt03
 version 11.0
 qui {
 args lf XB Rho1 Sigma
 tempvar Ro1 rYW1 D0 D1 A
 gen `D0'=0
 gen `D1'=0
 replace `D0' =1 if $ML_y1 ==spat_llt
 replace `D1' =1 if $ML_y1 > spat_llt
 gen double `Ro1' =`Rho1'*mstar_W1
 gen double `rYW1'=`Rho1'*w1y_$ML_y1
 replace `lf'=log(1-`Ro1')+`D1'*((($ML_y1-`rYW1'-`XB')/`Sigma') ///
 -exp(($ML_y1-`rYW1'-`XB')/`Sigma'))-`D0'*exp(($ML_y1-`rYW1'-`XB')/`Sigma')-`D1'*log(`Sigma')
 }
 end

