 program define spregcs29
 version 11.0
 qui {
 args lf XB Rho Sigma
 tempvar Ro rYW1 D0 D1
 gen `D0'=0
 gen `D1'=0
 replace `D0' =1 if $ML_y1 ==spat_llt
 replace `D1' =1 if $ML_y1 > spat_llt
 gen double `Ro'=`Rho'*spat_eigw
 gen double `rYW1'=`Rho'*w1y_$ML_y1
 replace `lf'=log(1-`Ro')-0.5*`D1'*log(2*_pi*`Sigma'^2) ///
 +`D0'*log(1-normal(($ML_y1-`rYW1'-`XB')/`Sigma')) ///
         -0.5*`D1'*(($ML_y1-`rYW1'-`XB')/`Sigma')^2
 }
 end
