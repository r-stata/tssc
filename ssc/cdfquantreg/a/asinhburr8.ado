program asinhburr8
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
   gen double `sigma' = exp(`Xd')
   gen double `mu' = `Xb'
   replace `lnf' = log(_pi) - log(`sigma') + asinh((-`mu' + log(tan((_pi*$ML_y1)/2)))/`sigma') ///
   - 2*log(1 + exp(asinh((-`mu' + log(tan((_pi*$ML_y1)/2)))/`sigma'))) ///
   + log(1/sin(_pi*$ML_y1)) - (1/2)*log(1 + (`mu' - log(tan((_pi*$ML_y1)/2)))^2/`sigma'^2)
   } 
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
