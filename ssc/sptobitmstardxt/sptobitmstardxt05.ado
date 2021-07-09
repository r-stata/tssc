program define sptobitmstardxt05
version 11.0
args lf XB Rho1 Rho2
tempvar rYW1 rYW2 D0 D1
qui gen `D0'=0
qui gen `D1'=0
qui replace `D0' =1 if $ML_y1 ==spat_llt
qui replace `D1' =1 if $ML_y1 > spat_llt
qui gen double `rYW1'=`Rho1'*w1y_$ML_y1
qui gen double `rYW2'=`Rho2'*w2y_$ML_y1
qui replace `lf'=-`D0'*(`rYW1'+`rYW2'+`XB') ///
          +`D1'*($ML_y1-`rYW1'-`rYW2'-`XB') ///
            -exp($ML_y1-`rYW1'-`rYW2'-`XB')
end
