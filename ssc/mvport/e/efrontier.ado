  ** mvport package v2
  * efrontier command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx
  
capture program drop efrontier
program efrontier, rclass
  version 11.0
  syntax varlist(min=2 numeric ts) [if] [in] [,NPort(real 100)] [MINweight(real -1)] [MAXweight(real -1)] [CASEwise] [RMINweights(numlist)] [RMAXweights(numlist)] [COVMatrix(string)] [MRets(string)] [ALLFront] [NOGraf]
  if (`nport'<3) {
     display as error "Number of portfolios must be greater than two"
     exit 
  }
   marksample touse
   if "`casewise'"=="" {
	  marksample touse, novarlist
	}		  
  tempname cov Rgmv maxR N Nrows j delta exprets rmin mrax vecweights vecmaxweights sumw i covmat 
  	local nvar : word count `varlist'
	 if "`mrets'"!="" { 
	  capture matrix `exprets' = `mrets'
	  if (_rc!=0) {
	    display as error "The matrix for Expected Returns does not exist; define a Stata Matrix (Vertical Vector of N rows and 1 column)"
	    exit
	  }
	  else if (rowsof(`exprets')!=`nvar') {
	    display as error "The length of the vertical mean vector specified in the mrets option is not equal to the number of variables "
		exit
	  }
	  else { 
        mata: MR=st_matrix("`mrets'")
		mata: st_numscalar("rmin",min(MR))
        mata: st_numscalar("rmax",max(MR))
		matrix `exprets'=`mrets'
		local maxR=rmax	  
	  }
	}
	else {
	  quietly meanrets `varlist' `if' `in', `casewise'	
	  matrix `exprets'=r(meanrets)
	  local rmax=r(maxret)
	  local rmin=r(minret)
	  local maxR=`rmax'
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
	  mata: maxr=m_getmaxr(st_matrix("`exprets'"),st_matrix("`vecmaxweights'"))
      mata: st_numscalar("srmax",maxr)	
	  local rmax=srmax
	  local maxR=`rmax'
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
	else {
	  local minweight 0
	  matrix `vecweights'=J(`nvar',1,0)
	}

	}

   gmvport `varlist' `if' `in', noshort `casewise' minweight(`minweight') maxweight(`maxweight') rminweights(`rminweights') rmaxweights(`rmaxweights') covmatrix(`covmatrix') mrets(`mrets')
   matrix  `cov'=r(cov)
  local N=rowsof(`cov')   
  local Rgmv = r(retport)
  if missing(`Rgmv') {
     display as error "Global minimum variance portfolio can not be calculated; it might be high correlation or a return variable has a variance of zero"
     exit
  }
    if "`allfront'"!="" {
     local Rgmv = `rmin'
  }

  tempname wefwos wefws refwos refws sdefwos sdefws pmv rmvport Nobs
  
  local Nrows=round(`nport')+1

  matrix  `wefwos'=J(`Nrows',`N',.)
  matrix  `refwos'=J(`Nrows',1,.)
  matrix  `sdefwos'=J(`Nrows',1,.)
  local j=0
  local delta=(`maxR'-`Rgmv')/(`nport')
  di _skip(1)
  if `delta'==0 {
     display as error "The return of the global minimum variance is equal to the portfolio with maximum return possible, so a frontier cannot be constructed"
	 exit
  }
  display "Estimating `nport' Portfolios without allowing for short sales..."

  forvalues Ri = `Rgmv'(`delta')`maxR' {
    if `Ri'<=`maxR' {
     local j=`j'+1
    mata: `pmv'= m_mvport2("`varlist'",`Ri',st_matrix("`vecweights'"),"`touse'", "`casewise'", st_matrix("`covmat'"), st_matrix("`exprets'"),st_matrix("`vecmaxweights'"), 1)
	matrix  `pmv'=r(weights)
	local rmvport=r(retp)
    forvalues i= 1/`N' { 
	   matrix `wefwos'[`j',`i']=`pmv'[`i',1] 
	}
     matrix `refwos'[`j',1]=r(retp)
     matrix `sdefwos'[`j',1]=r(sdp)
   }
  }

gmvport `varlist' `if' `in', `casewise' maxweight(`maxweight') rmaxweights(`rmaxweights') covmatrix(`covmatrix') mrets(`mrets') 

local Rgmv=r(retport)

if ("`rmaxweights'"=="" & `maxweight'==-1) { 
  local maxR=2*`maxR'
 } 
  if "`allfront'"!="" {
     local Rgmv = `rmin'
  }


matrix  `wefws'= J(`Nrows',`N',.)
matrix  `refws'= J(`Nrows',1,.)
matrix  `sdefws'=J(`Nrows',1,.)
local j=0

local delta=(`maxR'-`Rgmv')/(`nport'-1)
matrix `vecweights'=J(`nvar',1,-100)
di _skip(1)
display "Estimating `nport' Portfolios allowing for short sales..."

forvalues Ri = `Rgmv'(`delta')`maxR' {
  if `Ri'<=`maxR' {
    local j=`j'+1
	mata: `pmv'= m_mvport2("`varlist'",`Ri',st_matrix("`vecweights'"),"`touse'", "`casewise'", st_matrix("`covmat'"), st_matrix("`exprets'"),st_matrix("`vecmaxweights'"), 0)	
	matrix  `pmv'=r(weights)
	local rmvport=r(retp)
	
    forvalues i= 1/`N' {
	   matrix `wefws'[`j',`i']=`pmv'[`i',1] 
	}
    matrix `refws'[`j',1]=r(retp)
    matrix `sdefws'[`j',1]=r(sdp)
  }
}
scalar `Nobs'=_N
tempvar Ret_1 Ret_2 risk1 risk2
if "`nograf'"=="" {
  qui svmat `refwos', names(`Ret_1')
  label var `Ret_1'1 "Portfolio Return NO Shorting"
  qui svmat `sdefwos', names(`risk1')
  qui svmat `refws', names(`Ret_2')
  label var `Ret_2'1 "Portfolio Return W/Shorting"
  qui svmat `sdefws', names(`risk2')

  twoway (scatter `Ret_2'1 `risk2'1) (scatter `Ret_1'1 `risk1'1) , title(Efficient Frontier) xtitle(Portfolio Risk)	
  qui drop if (_n>`Nobs')
}
local nomvar=""
foreach v of varlist `varlist' {
   local nomvar "`nomvar' `v'"
} 
matrix colnames `wefwos' = `nomvar'
matrix colnames `wefws' = `nomvar'
matrix rownames `cov' = `nomvar'
matrix colnames `cov' = `nomvar'
matrix colnames `refwos' = "Ret-no short"
matrix colnames `refws' = "Ret-w/short"
matrix colnames `sdefwos' = "Risk-no-short"
matrix colnames `sdefws' = "Risk-w/short"

return matrix wefwos=`wefwos'
return matrix wefws= `wefws'
return matrix refwos=`refwos'
return matrix refws=`refws'
return matrix sdefwos=`sdefwos'
return matrix sdefws=`sdefws'
return matrix cov=`cov'
return matrix exprets=`exprets'
return scalar N=`N'
end
