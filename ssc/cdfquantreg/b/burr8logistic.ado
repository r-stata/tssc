program burr8logistic
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
   gen double `sigma' = exp(`Xd')
   gen double `mu' = `Xb'
   replace `lnf' = -((-`mu' - `sigma'*log(2) + `sigma'*log(_pi) + `sigma'*log(`sigma') ///
   + (1 + `sigma')*log(1 - $ML_y1) + (-1 + `sigma')*log($ML_y1) ///
   + `sigma'*log(exp((2*`mu')/`sigma') + $ML_y1^(2/`sigma')/(1 - $ML_y1)^ (2/`sigma')))/`sigma') 
   }
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
