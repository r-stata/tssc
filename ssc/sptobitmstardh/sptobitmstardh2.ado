program define sptobitmstardh2
version 11.0
args lf XB ZB Rho1 Rho2 Sigma
tempvar Ro1 Ro2 rYW1 rYW2 D0 D1
qui gen `D0'=0
qui gen `D1'=0
qui replace `D0' =1 if $ML_y1 ==spat_llt
qui replace `D1' =1 if $ML_y1 > spat_llt
qui gen double `Ro1' =`Rho1'*mstar_W1
qui gen double `Ro2' =`Rho2'*mstar_W2
qui gen double `rYW1'=`Rho1'*w1y_$ML_y1
qui gen double `rYW2'=`Rho2'*w2y_$ML_y1
qui replace `lf' = log(1-`Ro1'-`Ro2') ///
 +`D0'*log(normal(-(`rYW1'+`rYW2'+`XB')/((`Sigma'*exp(`ZB'))))) ///
 -0.5*log(2*_pi)-0.5*log(((`Sigma'*exp(`ZB')))^2) ///
 -0.5*`D1'*($ML_y1-`rYW1'-`rYW2'-`XB')^2/((`Sigma'*exp(`ZB')))^2
end
