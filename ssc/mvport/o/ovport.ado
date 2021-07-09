  ** mvport package v2
  * ovport command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx
capture program drop ovport
program ovport, rclass
    version 11.0
    syntax varlist(min=2 numeric ts) [if] [in][, rfrate(real 0)] [NOShort] [NPort(real 100)] [MINweight(real -1)] [MAXweight(real -1)] [CASEwise] [RMINweights(numlist)] [RMAXweights(numlist)] [COVMatrix(string)] [MRets(string)]

	marksample touse
	tempname peso i vecweights meanrets covmat srmin srmax rmin rmax vecmaxweights sumw 
	local nvar : word count `varlist'
	if "`casewise'"=="" {
	  marksample touse, novarlist
	}	
	
	if "`mrets'"!="" { 
	  capture matrix `meanrets' = `mrets'
	  if (_rc!=0) {
	    display as error "The matrix for Expected Returns does not exist; define a Stata Matrix (Vertical Vector of N rows and 1 column)"
	    exit
	  }
	  else if (rowsof(`meanrets')!=`nvar') {
	    display as error "The length of the vertical mean vector specified in the mrets option is not equal to the number of variables "
		exit
	  }
	  else { 
        mata: MR=st_matrix("`mrets'")
		mata: st_numscalar("srmin",min(MR))
        mata: st_numscalar("srmax",max(MR))
		local rmax=srmax
		local rmin=srmin
*		matrix `meanrets' = J(1,1,0)
	  }	  
	}
	else {
	  quietly meanrets `varlist' `if' `in', `casewise'	
	  scalar srmax=r(maxret)
	  scalar srmin=r(minret)
	  local rmax=srmax
	  local rmin=srmin
	  matrix `meanrets'=r(meanrets)

	}  
	if "`covmatrix'"!="" { 
	  capture matrix `covmat' = `covmatrix'
	  if (_rc!=0) {
	    display as error "The Variance-Covariance Matrix does not exist; define a Stata Matrix with that name or change to the right matrix name"
	    exit
	  }	 
	  else if (rowsof(`covmat')!=`nvar' | colsof(`covmat')!=`nvar') {
	    display as error "The number of columns or rows of the variance-covariance matrix specified in the covm option is not equal to the number of variables "
		exit
	  }
	}
	else {
	  matrix `covmat' = J(1,1,0)
	}
	local i=0
	local sumw=0

	matrix `vecmaxweights'=J(`nvar',1,100)
	matrix `vecweights'=J(`nvar',1,-100)
    if "`rmaxweights'"!="" {
     foreach peso in `rmaxweights' {
     if `i'<`nvar' {
	   local i=`i'+1
	   matrix `vecmaxweights'[`i',1] = `peso'
	   local sumw=`sumw'+`peso'
	 }
   }
   if `sumw'<=1 {
	  display as error "The sum of each weight specified for the returns is too small; it is not possible to assign 100% in the weights."
      exit
	    }
   }
	else {
	if `maxweight'!=-1 {
    	if `maxweight'*`nvar'<=1 {
	      display as error "The maximum weight specified for all returns is too small; it is not possible to assign 100% in the weights."
	      exit
	    }
	  matrix `vecmaxweights'=J(`nvar',1,`maxweight')
	}
	
	}
	if ("`rmaxweights'"!="" | `maxweight'!=-1) { 
	  mata: maxr=m_getmaxr(st_matrix("`meanrets'"),st_matrix("`vecmaxweights'"))
      mata: st_numscalar("srmax",maxr)	
	  local rmax=srmax
	}		
 local i=0
 local sumw=0
   if "`rminweights'"!="" {
	   local noshort "noshort"
	   matrix `vecweights'=J(`nvar',1,0)
       foreach peso in `rminweights' {
	    if `i'<`nvar' {
    	 local i=`i'+1
	     matrix `vecweights'[`i',1] = `peso'  
		 local sumw=`sumw'+`peso'
		} 
	   }
	   if `sumw'>=1 {
	      display as error "The minimum weights specified for each returns exceed 1 (100%); you have to change them so that the sum of all minimum weights is less than 1"
	    exit
	    }
    }
*	
	else {
	if `minweight'!=-1 {
    	if `minweight'*`nvar'>=1 {
	      display as error "The minimum weight specified for all returns is not valid; they exceed 1 (100%) considering all returns"
	    exit
	    }
	  matrix `vecweights'=J(`nvar',1,`minweight')
	  local noshort "noshort"
	}
	else if "`noshort'"!="" {
	  local minweight 0
	  matrix `vecweights'=J(`nvar',1,0)
	}

	}
		
    tempname rcov retp sdp vsharpe vsharpe_order sharpe wop rop sdop N exprets i wef vsdef vref nnoshort mcr cr pcr betas
	matrix `wop'=J(`nvar',1,.)
	local nnoshort=("`noshort'"!="")

	if "`noshort'"=="" {	
     qui gmvport `varlist' `if' `in', `casewise' maxweight(`maxweight') rmaxweight(`rmaxweight') covmatrix(`covmatrix') mrets(`mrets')
     if (`rfrate'>=r(retport)) {
  	   display as error "The risk-free rate is smaller than the global minimum variance portfolio return, which is equal to " r(retport) 
	   display as error "The risk-free rate was assigned to " r(retport) 
	   local rfrate=r(retport)
     }
  	  mata: `wop'=m_ovport("`varlist'",st_matrix("`vecweights'"),`nport',`rfrate',"`touse'", "`casewise'", st_matrix("`covmat'"), st_matrix("`meanrets'"),st_matrix("`vecmaxweights'"), `nnoshort')
    }
	else {
      cmline `varlist' `if' `in', noshort nport(`nport') rfrate(`rfrate') `casewise' minweight(`minweight') maxweight(`maxweight') rminweights(`rminweights') rmaxweights(`rmaxweights') covmatrix(`covmatrix') mrets(`mrets') nograph
    }

      matrix `exprets'=r(exprets)
      local N=rowsof(`exprets')	  
	  matrix `wop'=r(wop)
      matrix `rcov'=r(cov)	  
	  matrix `mcr' = r(mcr)
	  matrix `cr' = r(cr)
	  matrix `pcr' =r(pcr)
	  matrix `betas' =r(betas)
	foreach v of varlist `varlist' {
	   local nomvar "`nomvar' `v'"
	} 
	matrix colnames `wop' = "Weights"
	matrix rownames `wop' = `nomvar'
	matrix rownames `rcov' = `nomvar'
    matrix colnames `rcov' = `nomvar'
	matrix rownames `mcr' = `nomvar'
	matrix colnames `mcr' = "Marginal Contribution to Risk"
	matrix rownames `cr' = `nomvar'
	matrix colnames `cr' = "Contribution to Risk"
	matrix rownames `pcr' = `nomvar'
	matrix colnames `pcr' = "Percent Contribution to Risk"
	matrix rownames `betas' = `nomvar'
	matrix colnames `betas' ="Asset betas"
	
	  matrix `vsharpe'=r(vsharpe) 
      scalar `sharpe'=r(sharpe)
      scalar `rop'=r(rop) 
      scalar `sdop'=r(sdop) 

	display "Number of observations used to calculate expected returns and var-cov matrix : " r(N)
	if "`noshort'"=="" {
	display "The weight vector of the Tangent Portfolio with a risk-free rate of `rfrate'  (Allowing Short Sales) is:"
	}
	else { 
	display "The weight vector of the Tangent Portfolio with a risk-free rate of `rfrate' (NOT Allow Short Sales) is:" 
	}
	matrix list `wop', noh noblank
    display "The return of the Tangent Portfolio is: " r(rop)
	display "The standard deviation (risk) of the Tangent Portfolio is: " r(sdop)
    display "The marginal contributions to risk of the assets in the Tangent Portfolio are:"
	matlist `mcr'
	return matrix weights=`wop'
	return matrix cov=`rcov'
	return matrix exprets=`exprets'
	return matrix mcr=`mcr'
	return matrix cr=`cr'
	return matrix pcr=`pcr'
	return matrix betas=`betas'
	
	return scalar sharper= r(sharper) 
	return scalar rop=r(rop)
	return scalar sdop=r(sdop)
	return scalar varop=r(varop)
	return scalar rfrate=`rfrate'

end
