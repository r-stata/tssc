*! version 1.0.0  30Sep2005
* Negative Binomial-Logit Hurdle: log likelihood function :Joseph Hilbe
program define jhnb_logit_ll
version 9
args lnf beta1 beta2 alpha
  tempvar pi mu a
  qui gen double `a'  = exp(`alpha') 
  qui gen double `pi' = exp(`beta1')
  qui gen double `mu' = exp(`beta2') * `a'
  qui replace `lnf' = cond($ML_y1==0, ln(`pi'/(1+`pi')), ln(1/(1+`pi')) +  ///
      $ML_y1 *  ln(`mu'/(1+`mu'))   -  ///
      ln(1+`mu')/`a' +  lngamma($ML_y1 + 1/`a') -  ///
      lngamma($ML_y1 + 1) -  lngamma(1/`a')   -    ///
      ln(1-(1+`mu')^(-1/`a') ) )
end

   

