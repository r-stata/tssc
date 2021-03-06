program define sptobitmstard8
version 11.0
args lf XB Rho1 Rho2 Rho3 Rho4 Sigma
tempvar rYW1 rYW2 rYW3 rYW4 D0 D1
qui gen `D0'=0
qui gen `D1'=0
qui replace `D0' =1 if $ML_y1 ==spat_llt
qui replace `D1' =1 if $ML_y1 > spat_llt
qui gen double `rYW1'=`Rho1'*w1y_$ML_y1
qui gen double `rYW2'=`Rho2'*w2y_$ML_y1
qui gen double `rYW3'=`Rho3'*w3y_$ML_y1
qui gen double `rYW4'=`Rho4'*w4y_$ML_y1
qui replace `lf'=-`D1'*log(`Sigma') ///
   +`D1'*((($ML_y1-`rYW1'-`rYW2'-`rYW3'-`rYW4'-`XB')/`Sigma') ///
 -`D0'*exp(($ML_y1-`rYW1'-`rYW2'-`rYW3'-`rYW4'-`XB')/`Sigma') ///
      -exp(($ML_y1-`rYW1'-`rYW2'-`rYW3'-`rYW4'-`XB')/`Sigma'))
end
