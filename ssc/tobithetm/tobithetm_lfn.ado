program define tobithetm_lfn
version 10
tempvar D0 D1
qui gen `D0'=0
qui gen `D1'=0
qui replace `D0' =1 if $ML_y1 ==0
qui replace `D1' =1 if $ML_y1 >0
args lf XB Sig 
qui replace `lf' = -0.5*`D1'*ln(2*_pi*`Sig'^2)-0.5*`D1'*(($ML_y1-`XB')/`Sig')^2+`D0'*ln(1-normal(($ML_y1-`XB')/`Sig'))
end
