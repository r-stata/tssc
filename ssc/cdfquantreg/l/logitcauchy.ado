program logitcauchy
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
	gen double `sigma' = exp(`Xd')
	gen double `mu' = `Xb'
	replace `lnf' = (`mu' + `sigma'*log(_pi) - `sigma'*log(`sigma') + 1/tan(_pi*$ML_y1) ///
	- 2 * `sigma' * log(1 + exp((`mu' + 1/tan(_pi * $ML_y1))/`sigma')) + 2 * /// 
	`sigma' * log(1/sin(_pi * $ML_y1)))/`sigma' 
	}
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
