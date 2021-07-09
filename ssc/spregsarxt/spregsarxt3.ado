program define spregsarxt3
version 11.0
args lf XB Rho Sigma
tempvar Rho1 rYW1 D0 D1
qui gen `D0'=0
qui gen `D1'=0
qui replace `D0' =1 if $ML_y1 ==spat_llt
qui replace `D1' =1 if $ML_y1 > spat_llt
qui gen double `Rho1'=`Rho'*spat_eigw
qui gen double `rYW1'=`Rho'*w1y_$ML_y1
qui replace `lf'=log(1-`Rho1')-`D1'*log(`Sigma')+`D1'*((($ML_y1-`rYW1'-`XB')/`Sigma') ///
 -`D0'*exp(($ML_y1-`rYW1'-`XB')/`Sigma')-exp(($ML_y1-`rYW1'-`XB')/`Sigma'))
end
