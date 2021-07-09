
*! version 1.73.0 28jul2014 savespss by Sergiy Radyakin
*! saves data to SPSS system file (*.sav)
*! a11f515d-2e77-4c64-97e7-b42b70c7e742

program define savespss
  version 10.0
  syntax [anything], [replace ///
         extmiss(string) codepage(integer 1252) strlmax(integer 32767)]

  capture confirm file `anything'
  if (!_rc) {
    if (missing("`replace'")) error 602
	erase `anything'
  }
  
  if (missing(`"`anything'"')) {
    mata savespss_about()
    db savespss
  }
  else { 
    mata savespss(`anything') 
  }
end

// eof
