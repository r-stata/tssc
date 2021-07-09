capture program drop how_many_imputations 

program how_many_imputations, rclass
 version 13
 syntax [if] [, cv_se(real .05)] [CONFidence(real .95)]

 local fmi = e(fmi_max_mi) 
 local pilot_M = e(M_mi)

 local z = invnormal(1-(1-`confidence')/2)
 local logit_fmi = logit(`fmi')
 local se_logit_fmi = sqrt(2/`pilot_M')
 local fmi_lcl = invlogit(`logit_fmi' - `z' * `se_logit_fmi')
 local fmi_ucl = invlogit(`logit_fmi' + `z' * `se_logit_fmi')

 local target_M = ceil(1 + (1/2) * (`fmi_ucl' / `cv_se')^2)
 local add_M = max(0,`target_M' - `pilot_M')

 return scalar pilot_M = `pilot_M'
 return scalar target_M = `target_M'
 return scalar add_M = `add_M'
 return scalar fmi_lcl = `fmi_lcl'
 return scalar fmi_ucl = `fmi_ucl'
 return scalar fmi = `fmi' 
 return scalar cv_se = `cv_se'
 return scalar confidence = `confidence'

 display "Fraction of missing information " "(" %2.0f = 100*`confidence' "% CI): " ///
   %5.2f = `fmi' " (" %4.2f = `fmi_lcl' "," %5.2f = `fmi_ucl' ")" 
 display "Imputations in pilot:" _col(44) `pilot_M'
 display "Imputations needed:" _col(44)`target_M'
 display "Imputations to add:" _col(44) `add_M'

end
