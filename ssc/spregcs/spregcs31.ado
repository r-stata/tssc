 program define spregcs31
 version 11.0
 qui {
 args lf XB Rho Sigma
 tempvar rYW1 D0 D1
 gen `D0'=0
 gen `D1'=0
 replace `D0' =1 if $ML_y1 ==spat_llt
 replace `D1' =1 if $ML_y1 > spat_llt
 gen double `rYW1'=`Rho'*w1y_$ML_y1
 replace `lf'= -`D1'*log(`Sigma') +`D1'*((($ML_y1-`rYW1'-`XB')/`Sigma') ///
 -exp(($ML_y1-`rYW1'-`XB')/`Sigma'))-`D0'*exp(($ML_y1-`rYW1'-`XB')/`Sigma')
 }
 end

