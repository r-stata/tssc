 program define spregxt04
 version 11.0
 qui {
 args lf XB ZB Rho1 Sigma
 tempvar Ro1 rYW1 D0 D1 A
 gen `D0'=0
 gen `D1'=0
 replace `D0' =1 if $ML_y1 ==spat_llt
 replace `D1' =1 if $ML_y1 > spat_llt
 gen double `Ro1' =`Rho1'*mstar_W1
 gen double `rYW1'=`Rho1'*w1y_$ML_y1
 replace `lf' = log(1-`Ro1')+`D0'*log(normal(-(`rYW1'+`XB')/((`Sigma'*exp(`ZB')))))
 replace `lf' = -0.5*log(2*_pi)-0.5*log(((`Sigma'*exp(`ZB')))^2) ///
 -0.5*`D1'*($ML_y1-`rYW1'-`XB')^2/((`Sigma'*exp(`ZB')))^2
 }
 end
