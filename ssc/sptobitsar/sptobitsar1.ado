program define sptobitsar1
version 11.0
args lf XB Rho Sigma
tempvar Ro rYW1 D0 D1
qui gen `D0'=0
qui gen `D1'=0
qui replace `D0' =1 if $ML_y1 ==spat_llt
qui replace `D1' =1 if $ML_y1 > spat_llt
qui gen double `Ro'=`Rho'*spat_eigw
qui gen double `rYW1'=`Rho'*w1y_$ML_y1
qui replace `lf'=log(1-`Ro')-0.5*`D1'*log(2*_pi*`Sigma'^2) ///
-0.5*`D1'*(($ML_y1-`rYW1'-`XB')/`Sigma')^2+`D0'*log(1-normal(($ML_y1-`rYW1'-`XB')/`Sigma'))
end
