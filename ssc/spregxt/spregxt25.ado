 program define spregxt25
 version 11.0
 qui {
 args lf XB Rho
 tempvar rYW1 D0 D1
 gen `D0'=0
 gen `D1'=0
 replace `D0' =1 if $ML_y1 ==spat_llt
 replace `D1' =1 if $ML_y1 > spat_llt
 gen double `rYW1'=`Rho'*w1y_$ML_y1
 replace `lf'=-`D0'*(`rYW1'+`XB')+`D1'*($ML_y1-`rYW1'-`XB')-exp($ML_y1-`rYW1'-`XB')
 }
 end
