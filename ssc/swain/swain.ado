*! Swain V1, 15 March 2013
*! Authors: John Antonakis & Nicolas Bastardoz, University of Lausanne
  
  program define swain, rclass
  version 12
  	
    if "`e(cmd)'"!="sem" {
	di in red "This command only works after sem"
	exit 198
	}
	
  *obtain residuals
  qui: estat residuals
  
  *save residuals as a matrix 
  mat r = r(res_cov)
  
  *count the rows of the matrix (to give number of variables)
  local no_vars = rowsof(r)
  
  *sample size of model
  local N = e(N) 
  
  *df of model
  local df = e(df_ms)
  
  *Chi-square of model
  local chi = e(chi2_ms)

  *calculate Swain q
  local swain_q = (sqrt(1+4*(`no_vars')*(`no_vars'+1)-8*`df')-1)/2

  local swain = 1 - ((`no_vars')*(2*(`no_vars'^2) + 3*(`no_vars') - 1) - ///
                `swain_q'*(2*(`swain_q'^2)+3*(`swain_q')-1))/ ///
				(12*`df'*(`N'-1))
			
  local swain_chi = `swain'*`chi'
  local p_swain = chi2tail(`df',`swain_chi') 
  
  *stores saved results in r()
  return scalar swain_p = `p_swain'
  return scalar swain_chi = `swain_chi'
  return scalar swain_corr = `swain'   

  dis "" 
  dis "Swain correction factor = " `swain' 
  dis "Swain corrected chi-square = " `swain_chi' 
  dis "p-value of Swain corrected chi-square  = " `p_swain' 
  dis "" 
  
  end
  exit
