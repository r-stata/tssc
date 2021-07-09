  ** mvport package v2
  * varrets command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx
  capture program drop varrets
program varrets, rclass
    version 11.0
    syntax varlist(min=2 numeric ts) [if] [in] [,CASEwise] [LEWeight(real -1)] [WEightvar(varname)] 
	marksample touse	
	if "`casewise'"=="" {
	  marksample touse, novarlist
	}
	tempname cov W weights
	local nvar : word count `varlist'
	
	if "`weightvar'"=="" {
	    matrix `weights' = J(1,1,1)
	}
	else {
	    mkmat `weightvar' if `touse', matrix(`weights')
	}
		
    if ((`leweight'!=-1) & (`leweight'<=0 | `leweight'>=1) ) {
	  display as error "Lamda coefficient for exponential weights must be greater than 0 and less than 1"
      exit
	}

	matrix `cov'=J(`nvar',`nvar',.)
    mata: `cov'= m_varrets("`varlist'", "`touse'", `leweight', "`casewise'", st_matrix("`weights'"))
	matrix `cov'=r(cov)
	
	foreach v of varlist `varlist' {
	   local nomvar "`nomvar' `v'"
	} 
	matrix rownames `cov' = `nomvar'
	matrix colnames `cov' = `nomvar'
	
	
	return scalar N=r(N)	
    display "The Variance-Covariance matrix is:"
	matlist `cov'
	
	display "Observations to calculate the var-cov matrix: `r(N)'"
	if (`leweight'!=-1 | "`weightvar'"!="") {
	  display "The weights used for the computations is stored in r(W)"
   }
	return matrix cov=`cov'	
	matrix `W'=r(W)
	return matrix W=`W'
end
