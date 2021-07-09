program t2t2
version 13.0
args lnf Xb Xd
tempvar sigma
tempvar mu
quietly {
	gen double `sigma' = exp(`Xd')
	gen double `mu' = `Xb'
	replace `lnf' = 2*log(`sigma') - (3/2)*log(1 + 2*sqrt(2)*`mu'*sqrt(1 - $ML_y1)*sqrt($ML_y1)  ///
				 + 2*(-2 + `mu'^2 + 2*`sigma'^2)*$ML_y1 ///
				 - 4*`mu'*sqrt(2 - 2*$ML_y1)*$ML_y1^(3/2) ///
				 - 2*(-2 + `mu'^2 + 2*`sigma'^2)*$ML_y1^2)
	}
end
/*
This distribution is from the CDF-quantile family presented in 
Smithson, M. & Shou, Y. (2017). CDF-quantile distributions for modeling 
random variables on the unit interval. 
British Journal of Mathematical and Statistical Psychology, 70(3), 412-438. 
*/
