* LOGIT-POISSON HURDLE LOG-LIKELIHOOD: Joseph Hilbe: 30Sep2005
program jhpoi_logit_ll
  version 9.1
  args lnf beta1 beta2
  tempvar pi mu
  qui gen double `pi' = exp(`beta1')
  qui gen double `mu' = exp(`beta2')
  qui replace `lnf' = cond($ML_y1==0, ln(`pi'/(1+`pi')),   ///
    ln(1/(1+`pi')) -`mu' + $ML_y1 * `beta2'  ///
    - lngamma($ML_y1 + 1) - ln(1 - exp(-`mu')) )

end


