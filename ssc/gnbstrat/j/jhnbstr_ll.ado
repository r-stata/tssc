* NEGATIVE BINOMIAL W ENDOGENOUS STRATIFICATION LL FUNCTION   J. Hilbe 4Oct2005
program jhnbstr_ll
  version 9.1
  args lnf xb alpha

  tempvar alph lambda
  qui gen double `alph' = exp(`alpha') 
  qui gen double `lambda' = exp(`xb') 
  qui replace  `lnf' = lngamma(($ML_y1+1/`alph'))+$ML_y1*ln(`alph')+($ML_y1-1)   ///  
    * ln((exp(`xb')))-($ML_y1+1/`alph')*ln(1+`alph'*(exp(`xb')))-  ///  
      lngamma($ML_y1+1)-lngamma(1/`alph') + ln($ML_y1)

end


/*
adds the +1 tha Hilbe saw
  qui replace  `lnf' = lngamma(($ML_y1+1/`alph'))+$ML_y1*ln(`alph')
  +($ML_y1-1)*ln((exp(`xb')))-($ML_y1+1/`alph')*ln(1+`alph'*(exp(`xb')))
  -lngamma($ML_y1+1)-lngamma(1/`alph')	
*/
