program burr8t2
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
   gen double `sigma' = exp(`Xd')
   gen double `mu' = `Xb'
   replace `lnf' = log(cosh(((1 - 2*$ML_y1)/(sqrt(2)*sqrt((1 - $ML_y1)*$ML_y1)) ///
   + `mu')/`sigma')^(-1)/(2*sqrt(2)*_pi*((1 - $ML_y1)*$ML_y1)^(3/2)*`sigma')) 
   }
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
