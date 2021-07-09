program cauchitasinh
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
	gen double `sigma' = exp(`Xd')
	gen double `mu' = `Xb'
	replace `lnf' = log((2 * `sigma')/ _pi) + log(1 + 2 * (-1 + $ML_y1) * $ML_y1) /// 
	- log(4 * `sigma'^2 * (-1 + $ML_y1)^2 *$ML_y1^2 + (-1 + 2 * $ML_y1 /// 
	+ 2*`mu' * (-1 + $ML_y1) * $ML_y1)^2) 
	}
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
