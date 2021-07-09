program burr8asinh
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
   gen double `sigma' = exp(`Xd')
   gen double `mu' = `Xb'
   replace `lnf' = (-(1/(2*`sigma')))*(2*`sigma'*log(_pi) + 2*`sigma'*log(`sigma') ///
   + 2*`sigma'*log(exp((2*(`mu' - 1/(1 - $ML_y1)))/`sigma') + exp(1/(`sigma'*(-1 + $ML_y1)*$ML_y1))) ///
   + 4*`sigma'*log(1 - $ML_y1) + 4*`sigma'*log($ML_y1) - 2*`sigma'*log(1 - 2*(1 - $ML_y1)*$ML_y1) ///
   + 2*(1/(1 - $ML_y1)) - 2*`mu'*(1/(1 - $ML_y1)) + 1/((1 - $ML_y1)*$ML_y1) + 2*`mu'*($ML_y1/(1 - $ML_y1))) 
   }
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
