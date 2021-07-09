*! Swaini V1, 30 March 2013
*! Authors: John Antonakis & Nicolas Bastardoz, University of Lausanne
  program define swaini, rclass
  version 12
  args no_vars df N chi too_much
*too many arguments
  if "`too_much'" != "" {
  di in red "You have entered more than four numbers; recheck your entries. " 
  di in red "Please enter data after the command swaini as follows: vars df N chi"
  exit 198
  } 
*not enough arguments
  foreach v in no_vars df N chi {
  cap confirm number `=``v'''
  if _rc!=0 {
  di in red "You have not entered four numbers; recheck your entries. " 
  di in red "Please enter data after the command swaini as follows: vars df N chi"
  exit 498
  }
  }
*check integers
  foreach v in no_vars df N {
  capture confirm integer number `=``v'''
  if _rc {
  di in red "Decimal places not allowed (for vars df N); you have to use positive integers. " 
  di in red "Please enter data after the command swaini as follows: vars df N chi"
  exit 498
  }       
  }
*check positive integers
  if `no_vars'<0 | `df'<0 | `N'<0 | `chi'<0 {
  di in red "You cannot use negative numbers; recheck your entries. " 
  di in red "Please enter data after the command swaini as follows: vars df N chi""
  exit 498
  }
*swain correction
  local swain_q = (sqrt(1+4*(`no_vars')*(`no_vars'+1)-8*`df')-1)/2
  local swain = 1 - ((`no_vars')*(2*(`no_vars'^2) + 3*(`no_vars') - 1) - ///
                `swain_q'*(2*(`swain_q'^2)+3*(`swain_q')-1))/ ///
				(12*`df'*(`N'-1))
			
  local swain_chi = `swain'*`chi'
  local p_swain = chi2tail(`df',`swain_chi') 
  
*store saved results in r()
  return scalar swain_p = `p_swain'
  return scalar swain_chi = `swain_chi'
  return scalar swain_corr = `swain'   

  dis "" 
  dis "Number of variables in model = "`no_vars'
  dis "Df of model = " `df'
  dis "N size of model = " `N'
  dis "Chi-square of model = " `chi'
  dis "p-value of chi-square of model = " chi2tail(`df',`chi')
  dis "" 
  dis "Swain correction factor = " `swain' 
  dis "Swain corrected chi-square = " `swain_chi' 
  dis "p-value of Swain corrected chi-square  = " `p_swain' 
  dis "" 
  
  end
  exit

  
  
  

