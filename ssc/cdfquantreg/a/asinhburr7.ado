program asinhburr7
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
   gen double `sigma' = exp(`Xd')
   gen double `mu' = `Xb'
   replace `lnf' = -log(2) - log(`sigma') + asinh((`mu' + atanh(1 - 2 * $ML_y1))/`sigma') ///
	- 2 * log(1 + exp(asinh((`mu' + atanh(1 - 2 * $ML_y1))/`sigma'))) ///
	- (1/2) * log(1 + (`mu' + atanh(1 - 2 * $ML_y1))^2/`sigma'^2) ///
	- log(1 - $ML_y1) - log($ML_y1) 
	}
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
