program asinhasinh
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
   gen double `sigma' = exp(`Xd')
   gen double `mu' = `Xb'
   replace `lnf' = asinh(((1 - 2*$ML_y1)/(2*(-1 + $ML_y1)*$ML_y1) - `mu')/`sigma') ///
	- 2*log(1 + exp(asinh(((1 - 2*$ML_y1)/(2*(-1 + $ML_y1)*$ML_y1) - `mu')/`sigma'))) ///
	- log(1 - $ML_y1) - log($ML_y1) + log(1 - 2*$ML_y1 + 2*$ML_y1^2) ///
	- (1/2)*log(1 + 4*$ML_y1*(-1 + `mu') + 4*$ML_y1^4*(`mu'^2 + `sigma'^2) ///
	+ 4*$ML_y1^2*(1 - 3*`mu' + `mu'^2 + `sigma'^2) ///
	- 8*$ML_y1^3*(-`mu' + `mu'^2 + `sigma'^2)) 
	}
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
