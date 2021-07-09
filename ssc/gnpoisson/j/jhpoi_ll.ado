*! version 1.0.1  7Sep2005
* Generalized Poisson log likelihood function :Joseph Hilbe
program define jhpoi_ll
version  9.1
args lnf xb phi

tempvar a mu
qui gen  double `a' = exp(`phi')
qui gen double `mu' = exp(`xb') *  `a'
qui replace `lnf' = $ML_y1 * ln(exp(`xb')/(1+`mu')) + /// 
    ($ML_y1 -1)* log(1+`a'*$ML_y1) - lngamma($ML_y1 + 1) - ///
    (exp(`xb')*(1+`a'*$ML_y1))/(1+`mu')

end

