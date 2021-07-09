program asinht2
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
   gen double `sigma' = exp(`Xd')
   gen double `mu' = `Xb'
   replace `lnf' =  log((exp(asinh((-`mu' + 2*(($ML_y1 > 1/2) - 1/2)*(sqrt((1 ///
   - 2*$ML_y1)^2/(2 * (1 - $ML_y1)*$ML_y1))))/`sigma')) * (($ML_y1 == 1/2)*2*sqrt(2) ///
   + ($ML_y1 > 1/2)*(2*$ML_y1 - 1)/sqrt(8*(1 - 2*$ML_y1)^2*((1 - $ML_y1)*$ML_y1)^3) ///
   + ($ML_y1 < 1/2)*(1 - 2*$ML_y1)/sqrt(8*(1 - 2*$ML_y1)^2*((1 - $ML_y1)*$ML_y1)^3)))/((1 ///
   + exp(asinh((-`mu' + 2*(($ML_y1 > 1/2) - 1/2)*(sqrt((1 - 2*$ML_y1)^2/(2 * (1 ///
   - $ML_y1)*$ML_y1))))/`sigma')))^2 * `sigma' *  sqrt(1 + (`mu' - 2*(($ML_y1 > 1/2) ///
   - 1/2)*(sqrt((1 - 2*$ML_y1)^2/(2 * (1 - $ML_y1)*$ML_y1))))^2/`sigma'^2)))
   }
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
