program t2asinh
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
	gen double `sigma' = exp(`Xd')
	gen double `mu' = `Xb'
	replace `lnf' = log(4) + 2*log(`sigma') + 3*log(1 - $ML_y1) + log($ML_y1) ///
	- (3/2)*log(1 + 4*(-1 + `mu')*$ML_y1 + 4*(1 - 3*`mu' + `mu'^2 ///
	+ 2*`sigma'^2)*$ML_y1^2 - 8*(-`mu' + `mu'^2 + 2*`sigma'^2)*$ML_y1^3 ///
	+ 4*(`mu'^2 + 2*`sigma'^2)*$ML_y1^4) 
	}
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
