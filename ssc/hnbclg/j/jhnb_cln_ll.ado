*! version 1.0.0  25Sep2005
* Negative Binomial-Cloglog Hurdle: log likelihood function :Joseph Hilbe
program define jhnb_cln_ll
version 9.1
args lnf beta1 beta2 alpha
  tempvar pi mu a
  qui gen double `a'  = exp(`alpha') 
  qui gen double `pi' = exp(`beta1')
  qui gen double `mu' = exp(`beta2') * `a'
  qui replace `lnf' = cond($ML_y1==0, -`pi', ln(1-exp(-`pi')) +  ///
      $ML_y1 *  ln(`mu'/(1+`mu'))   -  ///
      ln(1+`mu')/`a' +  lngamma($ML_y1 + 1/`a') -  ///
      lngamma($ML_y1 + 1) -  lngamma(1/`a')   -    ///
      ln(1-(1+`mu')^(-1/`a') ) )
end

   

