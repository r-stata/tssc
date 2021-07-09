*! soepdo.ado   Version 1.1.1   29jul2008

drop _all

program soepdo
  version 10
  syntax [namelist], ///
    Soepdir(string)                   /// where to find SOEP data
    Yperg(numlist >=-3 <=9 int sort)  /// reason(s) for drop-out
    [Erhebj(string)]                  /// must be one of first, last;
                                      //  defaults to all
//    [INCludevars(string)]             // variables to include; defaults to all



  local rdofile "ypbrutto"             // Macros
  local rdovar  "yperg"

  
  if "`namelist'" != "" {
    use persnr yperg erhebj `namelist' using `soepdir'/`rdofile'
  }
  else {
    use using `soepdir'/`rdofile'
  }



  /*
      Mark observations with the specified reason(s) for the drop-out in 
      option `yperg' and drop other observations
  */

  dis
  dis "Ok. I will keep drop-outs with the following YPERG values: `yperg'."
  dis  /* hier mehr machen, Label auslesen und auflisten, welche Werte gewaehlt
          wurden */

  qui{
  gen _userselection = .

  foreach sel of local yperg {
    replace _userselection = 1 if `rdovar' == `sel'
  }

  keep if _userselection == 1

  drop _userselection
  }


  
  
  
  /*
      Keep only first or last obs in terms of erhebj?
  */
  
  if "`erhebj'" == "last" {
    gsort +persnr +erhebj
    by persnr: drop if _n != _N
  }
  else if "`erhebj'" == "first" {
    gsort +persnr -erhebj
    by persnr: drop if _n != _N
  }



end
exit



/*

  Author's address:
  Tim Stegmann
  Institute for Work, Skills and Training (IAQ)
  University of Duisburg-Essen
  45117 Essen

  E-Mail: tim.stegmann@uni-due.de

*/