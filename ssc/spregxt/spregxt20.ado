 program define spregxt20
 version 11.0
 qui {
 args lf XB Rho Sigma
 tempvar Rho1 rYW1 D0 D1
 gen `D0'=0
 gen `D1'=0
 replace `D0' =1 if $ML_y1 ==spat_llt
 replace `D1' =1 if $ML_y1 > spat_llt
 gen double `Rho1'=`Rho'*spat_eigw
 gen double `rYW1'=`Rho'*w1y_$ML_y1
 replace `lf'=log(1-`Rho1')-0.5*`D1'*log(2*_pi*`Sigma'^2) ///
 -0.5*`D1'*(($ML_y1-`rYW1'-`XB')/`Sigma')^2+`D0'*log(1-normal(($ML_y1-`rYW1'-`XB')/`Sigma'))
 }
 end
