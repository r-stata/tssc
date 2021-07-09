* LOGIT-GEOMETRIC HURDLE LOG-LIKELIHOOD: Joseph Hilbe: 30Sep2005
program jhgeo_logit_ll
  version 9.1
  args lnf beta1 beta2
  tempvar pi mu
  qui gen double `pi' = exp(`beta1')
  qui gen double `mu' = exp(`beta2')
  qui replace `lnf' = cond($ML_y1==0, ln(1/(1+`pi')), ///
    ln(`pi'/(1+`pi')) + $ML_y1 * ln(`mu') -   ///  
    (1+ $ML_y1)*ln(1+`mu') - ln(1+ ln(1+`mu')))

end


