  ** mvport package v2
  * mvport command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx
  
capture program drop mvport
program mvport, rclass
    version 11.0
    syntax varlist(min=2 numeric ts) [if] [in], ret(real) [NOShort] [MINweight(real -1)] [MAXweight(real -1)] [CASEwise] [RMINweights(numlist)] [RMAXweights(numlist)] [COVMatrix(string)] [MRets(string)] 
	marksample touse
	tempname peso i vecweights meanrets covmat srmin srmax rmin rmax vecmaxweights sumw rpesos
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
	if "`noshort'"!="noshort" {
    	matrix `vecweights'=J(`nvar',1,-100)
	}
	else {
	    matrix `vecweights'=J(`nvar',1,0)
	}
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
	  local noshort "noshort"
	}

	}
		
	   qui gmvport `varlist' `if' `in', `casewise' `noshort' minweight(`minweight') maxweight(`maxweight') rminweights(`rminweights') rmaxweights(`rmaxweights') covmatrix(`covmatrix') mrets(`mrets')
	   scalar srmin=r(retport)
	   local rmin=srmin
    if ( (`ret'>`rmax'  & "`noshort'"!="") | (`ret'<`rmin') )  {
       display as error "Return `ret' is out of range; according to the return variables specified, the return must be between `rmin' and `rmax'"
	   matrix `rpesos'=J(`nvar',1,0)
	   return matrix weights=`rpesos'
	   return scalar retport=0
	   return scalar sdport=0
	   return scalar N=0
    }
   else {
	tempname  rcov retp sdp rexprets nnoshort mcr cr pcr betas
	local nnoshort=("`noshort'"!="")
    mata: `rpesos'= m_mvport2("`varlist'",`ret',st_matrix("`vecweights'"),"`touse'", "`casewise'", st_matrix("`covmat'"), st_matrix("`meanrets'"),st_matrix("`vecmaxweights'"), `nnoshort')
	matrix `rpesos'=r(weights)
	matrix `rcov'=r(cov)
	matrix `rexprets' = r(exprets)
	matrix `mcr'=r(mcr)
	matrix `cr'=r(cr)
	matrix `pcr'=r(pcr)
	matrix `betas'=r(betas)
	if `r(retp)'<`ret' {
	  display "It was not possible to match the specified return due to the specified constraints"
	  display "A maximum return of `r(retp)' was calculated given the weight constraints"
	} 
	foreach v of varlist `varlist' {
	   local nomvar "`nomvar' `v'"
	} 
	matrix rownames `rpesos' = `nomvar'
	matrix colnames `rpesos' = "Weights"
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
	
	display "Portfolio weights of the portfolio: "
	matlist `rpesos'
	display "Number of observations used to calculate expected returns and var-covariance matrix : " r(N)
    display "Required return of the Portfolio:  " `r(retp)'
    if "`noshort'"=="" {
	  display "Minimum standard deviation of the portfolio (Allowing for short sales): " `r(sdp)'
	}
	else { 
      display "Minimum standard deviation of the portfolio (DO NOT Allow Short Sales): " `r(sdp)'
	}

	return matrix weights=`rpesos'
	return matrix cov=`rcov'
	return matrix exprets=`rexprets'
	return matrix mcr=`mcr'
	return matrix cr=`cr'
	return matrix pcr=`pcr'
	return matrix betas=`betas'
	return scalar retport=r(retp)
	return scalar sdport=r(sdp)
	return scalar varport=r(varp)
	return scalar N=r(N)
	}
end
