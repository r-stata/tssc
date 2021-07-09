*! efrontierm, version 1.0, Sep 2013
* Author: Alberto Dorantes, ITESM, Querétaro, México
* This command does the same as efrontier, but this one uses more mata programming, so it is more efficient.
capture program drop efrontierm
program efrontierm, rclass
  version 11.2
  syntax varlist(min=2 numeric ts) [if] [in], nport(real) [MINweight(real -1)] [CASEwise] [RWeights(numlist)] [ALLFront]
  marksample touse
  if (`nport'<3) {
     display as error "Number of portfolios must be greater than two"
     exit 
  }
  marksample touse
    qui count if `touse'	
    local nnmissing1=r(N)
	if "`casewise'"=="" {
	  marksample touse, novarlist
	}	
	tempname peso i vecweights meanrets	
	if `minweight'==-1 { 
       local minweight 0
	}
	local i=0
	local nvar : word count `varlist'
    if "`rweights'"!="" {
	   local noshort "noshort"
	   matrix `vecweights'=J(`nvar',1,0)
       foreach peso in `rweights' {
	    if `i'<`nvar' {
    	 local i=`i'+1
	     matrix `vecweights'[`i',1] = `peso'  
		} 
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
   tempname cov Rgmv wefwos wefws refwos refws sdefwos sdefws exprets
   gmvport `varlist' `if' `in', noshort `casewise' minweight(`minweight') rweights(`rweights')
   matrix  `cov'=r(cov)
  local Rgmv=`r(retport)'
  if missing(`Rgmv') {
     display as error "No se pudo calcular el Port de Min Var Global; tal vez hay 2 variables con correlación=1 o la varianza de alguna variable es igual a cero"
     exit
  }
  matrix `wefwos'=J(`nport',colsof(`cov'),.)
  matrix `refwos'=J(`nport',1,.)
  matrix `sdefwos'=J(`nport',1,.)

 mata: m_efrontiermwos("`varlist'", st_matrix("`vecweights'"),`nport', "`touse'", "`casewise'", "`allfront'")  
 matrix define `wefwos'=r(wefwos)
 matrix define `refwos'=r(refwos)
 matrix define `sdefwos'=r(sdefwos)
 matrix `exprets'=r(exprets)
 matrix  `wefws'= J(`nport',colsof(`cov'),.)
 matrix  `refws'= J(`nport',1,.)
 matrix  `sdefws'=J(`nport',1,.)

 mata: m_efrontiermws("`varlist'", `nport', "`touse'", "`casewise'", "`allfront'")
 matrix  define `wefws'=r(wefws)
 matrix  define `refws'=r(refws)
 matrix  define `sdefws'=r(sdefws)

preserve
capture drop risk* Ret_*
svmat `refwos', names(Ret_1)
label var Ret_1 "Portfolio Return NO Shorting"
svmat `sdefwos', names(risk1)
svmat `refws', names(Ret_2)
label var Ret_2 "Portfolio Return W/Shorting"
svmat `sdefws', names(rik2)

twoway (scatter Ret_2 rik2) (scatter Ret_1 risk1) , title(Efficient Frontier) xtitle(Portfolio Risk)	
restore 
foreach v of varlist `varlist' {
   local nomvar "`nomvar' `v'"
} 
matrix colnames `wefwos' = `nomvar'
matrix colnames `wefws' = `nomvar'
matrix rownames `cov' = `nomvar'
matrix colnames `cov' = `nomvar'
matrix colnames `refwos' = "Ret-no short"
matrix colnames `refws' = "Ret"
matrix colnames `sdefwos' = "Risk-shorting"
matrix colnames `sdefws' = "Risk"

return matrix wefwos=`wefwos'
return matrix wefws= `wefws'
return matrix refwos=`refwos'
return matrix refws=`refws'
return matrix sdefwos=`sdefwos'
return matrix sdefws=`sdefws'
return matrix cov=`cov'
return matrix exprets=`exprets'
end
