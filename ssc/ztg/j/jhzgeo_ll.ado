*! version 1.0.0  25Sep2005
* 0-Truncated geometric regression: log likelihood function :Joseph Hilbe
program define jhzgeo_ll
version  9.1
args lnf xb  

tempvar mu
qui gen double `mu' = exp(`xb')
qui replace `lnf' = $ML_y1*ln(`mu') - (1 + $ML_y1)*ln(1+`mu') - ///
  ln(1 + ln(1+`mu'))

end






