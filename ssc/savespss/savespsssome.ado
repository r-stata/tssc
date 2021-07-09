*! savespsssome is part of the -savespss- package by Sergiy Radyakin.
*! Type: which savespss
*! to obtain version and date information

program define savespsssome, nclass

  version 10.0
  syntax [varlist] [if] [in], saving(string) [*]
  preserve
  
  marksample touse, strok novarlist
  quietly {
    keep if `touse'
    if !missing("`varlist'") keep `varlist'
  }
  
  savespss `"`saving'"', `options'

end
// eof
