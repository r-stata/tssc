program burr7burr8
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
   gen double `sigma' = exp(`Xd')
   gen double `mu' = `Xb'
   replace `lnf' = (_pi*1/sin((_pi*$ML_y1)/2)*1/cos((_pi*$ML_y1)/2)*1/cosh((`mu' ///
   - log(tan((_pi*$ML_y1)/2)))/`sigma')^2)/(4*`sigma') 
   }
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
