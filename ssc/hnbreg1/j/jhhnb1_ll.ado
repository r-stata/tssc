*! version 1.0.00  12Sep2007
* Negative binomial Type 1: log likelihood  function :Joseph Hilbe
program define jhhnb1_ll
version  9.1
args lnf xb  delta

tempvar d mu
qui gen  double `d' = exp(`delta')
qui gen double `mu' = exp(`xb') *  `d'

qui replace `lnf' = $ML_y1 * ln(`d') - ($ML_y1+`mu')*ln(1+`d') +    /// 
lngamma(`mu' + $ML_y1) - lngamma($ML_y1+1) - lngamma(`mu')


end
