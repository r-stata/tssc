  ** mvport package v2
  * meanrets command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx
  
capture program drop meanrets
program meanrets, rclass
    version 11.0
    syntax varlist(min=1 numeric ts) [if] [in] [,CASEwise] [LEWeight(real -1)] [WEightvar(varname)] [SIMPLEreturn]
	marksample touse	
	if "`casewise'"=="" {
	  marksample touse, novarlist
	}
	local nvar : word count `varlist'
	tempname meanrets W weights calcsimple
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
	local calcsimple=("`simplereturn'"!="") 
	matrix `meanrets'=J(`nvar',1,.)
    mata: `meanrets'= m_meanrets("`varlist'", "`touse'", `leweight', "`casewise'", st_matrix("`weights'"), `calcsimple')
	matrix `meanrets'=r(meanrets)
	foreach v of varlist `varlist' {
	   local nomvar "`nomvar' `v'"
	} 
	matrix rownames `meanrets' = `nomvar'
	matrix colnames `meanrets' = "Exp ret"

	
	return scalar minret=r(minret)
	return scalar maxret=r(maxret)
	return scalar numvar=r(numvar)
	return scalar N=r(N)
  
	display "Expected simple returns (Geometric means):"
	matlist `meanrets'
    display "Observations to calculate expected simple returns: `r(N)'"   	
	if (`leweight'!=-1 | "`weightvar'"!="") {
	  display "The weights used for the computations is stored in r(W)"
   }
	return matrix meanrets=`meanrets'
	matrix `W'=r(W)
	return matrix W=`W'
end
