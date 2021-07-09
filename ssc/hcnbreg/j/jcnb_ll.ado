*! version 1.1 25Sep2005 21Jan2009  23Feb09 revision
* Hilbe Canonical Negative binomial: log likelihood  function :Joseph Hilbe
program define jcnb_ll
version  9.1
args lnf xb  alpha

tempvar a mu
qui gen  double `a' = exp(`alpha')
qui gen double `mu' = 1/(`a'* (exp(-`xb')-1)) 
qui replace `lnf' = $ML_y1 *  ln((`a'*`mu')/(1+`a'*`mu')) - ///
ln(1+`a'*`mu')/`a' +  lngamma($ML_y1 + 1/`a') - lngamma($ML_y1 + 1) - lngamma(1/`a')
end
