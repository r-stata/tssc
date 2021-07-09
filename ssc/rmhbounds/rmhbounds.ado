/****************
This program tweaks the stock mhbounds program in two ways:
1. It removes the restriction on having a maximum of 99 strata.
2. It uses Rosenbaum's exact formulae for expectation and variance (as opposed to asymptotic formulae). These are more appropriate for small strata.
One can use this iteration of mhbounds to conduct sensitivity analyses within strata of any size (not required to be 1:1 matched).
********************/
cap program drop rmhbounds
program define rmhbounds, rclass
version 9.0

syntax varname [if/], Gamma(numlist >=1 sort) [treated(varname) weight(varname) support(varname) stratum(varname) stratamat]

tokenize `gamma'
if `1'~=1 {
  local gamma = "1 `gamma'"
}

local rownum = wordcount("`gamma'")

preserve

if `"`treated'"' != `""'  { /* if */
  cap qui gen _treated = `treated'
    if _rc!=0 {
      di as error "Treatment variable _treated already defined"
      exit 198
    }
} /* if */
else if `"`treated'"' == `""' { /* else */
  cap qui sum _treated
  if _rc!=0 {
    di as error "mhbounds.ado expects the variable _treated from psmatch2.ado or a user-provided variable"
    exit 198
  }
} /* else */


if `"`weight'"' != `""'  { /* if */
  cap qui gen _weight = `weight'
    if _rc!=0 {
      di as error "Weighting variable _weight already defined"
      exit 198
    }
} /* if */
else if `"`weight'"' == `""' { /* else */
  cap qui sum _weight
  if _rc!=0 {
    di as error "mhbounds.ado expects the variable _weight from psmatch2.ado or a user-provided variable"
    exit 198
  }
} /* else */


if `"`support'"' != `""'  { /* if */
  cap qui gen _support = `support'
    if _rc!=0 {
      di as error "Support variable _support already defined"
      exit 198
    }
} /* if */
else if `"`support'"' == `""' { /* else */
  cap qui sum _support
  if _rc!=0 {
    di as error "mhbounds.ado expects the variable _support from psmatch2.ado or a user-provided variable"
    exit 198
  }
} /* else */


tempvar _stratum
if `"`stratum'"' != `""'  { /* if */
//   qui inspect `stratum'
//   local nstrata = r(N_unique)
  egen `_stratum' = group(`stratum')
  quietly levelsof `_stratum'
  local nstrata=r(r)
//   if `nstrata' == . {
//     di as error "Too many strata: maximum 99"
//     exit 198
//   }
} /* if */
else if `"`stratum'"' == `""' { /* else */
  gen `_stratum'=1
  local nstrata = 1
} /* else */

if "`if'"~="" {
  qui keep if `if'
}

qui drop if `varlist'==.

qui keep if (_weight>0 & _weight!=.)
qui keep if _support==1


foreach stratval of numlist 1/`nstrata' { /* strata */

  if `nstrata'>1 {
    qui count if `_stratum'==`stratval'
  }
  else if `nstrata'==1 {
    qui count
  }
  
  if r(N)==0 {
    di as error "No treated in support, cannot compute Mantel-Haenszel (1959) statistic"
    exit 198
  }


  qui sum `varlist' [aw=_weight] if _treated ==1 & `varlist'==1 & `_stratum'==`stratval'
  scalar y_1 = r(N)
  qui sum `varlist' [aw=_weight] if _treated ==0 & `varlist'==1 & `_stratum'==`stratval'  
  scalar y_0 = r(N)

  qui sum _treated [aw=_weight] if _treated==1 & `_stratum'==`stratval'
  scalar n_1 = r(N)
  qui sum _treated [aw=_weight] if _treated==0 & `_stratum'==`stratval'
  scalar n_0 = r(N)

  qui sum `varlist' [aw=_weight] if `varlist'==1 & `_stratum'==`stratval'
  scalar y = r(N)
  qui sum _treated [aw=_weight] if `_stratum'==`stratval'
  scalar n = r(N)


  scalar lowbound = max(0,scalar(y)+scalar(n_1)-scalar(n))
  scalar uppbound = min(scalar(y),scalar(n_1))

  local j = 0
  matrix outmat_`stratval' = J(`rownum',9,.)
  matrix colnames outmat_`stratval' = e_y mhplus mhminus p_mhplus p_mhminus E_mhplus E_mhminus V_mhplus V_mhminus

  foreach i of numlist `gamma' { /* grid points */

    local j = `j' + 1

    scalar e_y = `i'
    matrix outmat_`stratval'[`j',1] = `i'


	
    /* assumption: overestimation: grid points >= 1 */
	
	 	forvalues k = `=lowbound'/`=uppbound' {
	if `k'>0 {
	local l = `k' - 1
	}
	if `k'==`=lowbound' & `=lowbound'!=0 {
	scalar numsum`l' = 0
	scalar densum`l' = 0
	}
	scalar numexp`k' = `k'*comb(scalar(y),`k')*comb(scalar(n)-scalar(y),scalar(n_1)-`k')*(scalar(e_y)^`k')
	scalar denexp`k' = comb(scalar(y),`k')*comb(scalar(n)-scalar(y),scalar(n_1)-`k')*(scalar(e_y)^`k')
	if `k'==0 {
	scalar numsum0 = scalar(numexp0)
	scalar densum0 = scalar(denexp0)
	}
	else if `k'>0 {
	scalar numsum`k' = scalar(numsum`l') + scalar(numexp`k')
	scalar densum`k' = scalar(densum`l') + scalar(denexp`k')
	}
	}
	scalar Ebar_over=scalar(numsum`=uppbound')/scalar(densum`=uppbound')

 	forvalues k = `=lowbound'/`=uppbound' {
	if `k'>0 {
	local l = `k' - 1
	}
	if `k'==`=lowbound' & `=lowbound'!=0 {
	scalar Vnumsum`l' = 0
	}
	scalar Vnumexp`k' = (`k'^2)*comb(scalar(y),`k')*comb(scalar(n)-scalar(y),scalar(n_1)-`k')*(scalar(e_y)^`k')
	if `k'==0 {
	scalar Vnumsum0 = scalar(Vnumexp0)
	}
	else if `k'>0 {
	scalar Vnumsum`k' = scalar(Vnumsum`l') + scalar(Vnumexp`k')
	}
	}
	scalar Vbar_over=scalar(Vnumsum`=uppbound')/scalar(densum`=uppbound') - (scalar(Ebar_over)^2)
	

//     scalar b = -((scalar(e_y) - 1) * (scalar(n_1) + scalar(y)) + scalar(n))
//     scalar a = (scalar(e_y) - 1)
//     scalar c = (scalar(e_y)*scalar(y)*scalar(n_1))

//     scalar E_over1 = (-scalar(b) + (scalar(b)^2-4*scalar(a)*scalar(c))^(0.5))/(2*scalar(a))
//     scalar E_over2 = (-scalar(b) - (scalar(b)^2-4*scalar(a)*scalar(c))^(0.5))/(2*scalar(a))
//
//     scalar Var_E_over1 = ( 1/scalar(E_over1) + 1/(scalar(y)-scalar(E_over1)) + 1/(scalar(n_1)-scalar(E_over1)) + 1 / (scalar(n)-scalar(y)-scalar(n_1)+scalar(E_over1)))^(-1)
//     scalar Var_E_over2 = ( 1/scalar(E_over2) + 1/(scalar(y)-scalar(E_over2)) + 1/(scalar(n_1)-scalar(E_over2)) + 1 / (scalar(n)-scalar(y)-scalar(n_1)+scalar(E_over2)))^(-1) 

*    scalar mh_over1 = (scalar(y_1) - scalar(E_over1))^2 / scalar(Var_E_over1) 
*    scalar mh_over2 = (scalar(y_1) - scalar(E_over2))^2 / scalar(Var_E_over2) 
     scalar mh_over = (abs(scalar(y_1)-scalar(Ebar_over))-0.5)/sqrt(scalar(Vbar_over)) 
//      scalar mh_over2 = (abs(scalar(y_1) - scalar(E_over2))-0.5) / sqrt(scalar(Var_E_over2)) 

//     if (scalar(lowbound) <= scalar(E_over1)) & (scalar(E_over1)<=scalar(uppbound)) {
       matrix outmat_`stratval'[`j',2] = scalar(mh_over)
       matrix outmat_`stratval'[`j',4] = 1-normal(scalar(mh_over))
       matrix outmat_`stratval'[`j',6] = scalar(Ebar_over)
       matrix outmat_`stratval'[`j',8] = scalar(Vbar_over)
//     }
//     else {
//        matrix outmat_`stratval'[`j',2] = scalar(mh_over2)
//        matrix outmat_`stratval'[`j',4] = 1-normal(scalar(mh_over2))
//        matrix outmat_`stratval'[`j',6] = scalar(E_over2)
//        matrix outmat_`stratval'[`j',8] = scalar(Var_E_over2)
//     }


    /* assumption: underestimation: inverse values */
    scalar e_y2 = 1/`i'

		 	forvalues k = `=lowbound'/`=uppbound' {
	if `k'>0 {
	local l = `k' - 1
	}
	if `k'==0 & `=lowbound'!=0 {
	scalar numsum`l' = 0
	scalar densum`l' = 0
	}
	scalar numexp`k' = `k'*comb(scalar(y),`k')*comb(scalar(n)-scalar(y),scalar(n_1)-`k')*(scalar(e_y2)^`k')
	scalar denexp`k' = comb(scalar(y),`k')*comb(scalar(n)-scalar(y),scalar(n_1)-`k')*(scalar(e_y2)^`k')
	if `k'==0 {
	scalar numsum0 = scalar(numexp0)
	scalar densum0 = scalar(denexp0)
	}
	else if `k'>0 {
	scalar numsum`k' = scalar(numsum`l') + scalar(numexp`k')
	scalar densum`k' = scalar(densum`l') + scalar(denexp`k')
	}
	}
	scalar Ebar_under=scalar(numsum`=uppbound')/scalar(densum`=uppbound')

 	forvalues k = `=lowbound'/`=uppbound' {
	if `k'>0 {
	local l = `k' - 1
	}
	if `k'==0 & `=lowbound'!=0 {
	scalar Vnumsum`l' = 0
	}
	scalar Vnumexp`k' = (`k'^2)*comb(scalar(y),`k')*comb(scalar(n)-scalar(y),scalar(n_1)-`k')*(scalar(e_y2)^`k')
	if `k'==0 {
	scalar Vnumsum0 = scalar(Vnumexp0)
	}
	else if `k'>0 {
	scalar Vnumsum`k' = scalar(Vnumsum`l') + scalar(Vnumexp`k')
	}
	}
	scalar Vbar_under=scalar(Vnumsum`=uppbound')/scalar(densum`=uppbound') - (scalar(Ebar_under)^2)

//     scalar b2 = -((scalar(e_y2) - 1) * (scalar(n_1) + scalar(y)) + scalar(n))
//     scalar a2 = (scalar(e_y2) - 1)
//     scalar c2 = (scalar(e_y2)*scalar(y)*scalar(n_1))
//
//     scalar E_under1 = (-scalar(b2) + (scalar(b2)^2-4*scalar(a2)*scalar(c2))^(0.5))/(2*scalar(a2)) 
//     scalar E_under2 = (-scalar(b2) - (scalar(b2)^2-4*scalar(a2)*scalar(c2))^(0.5))/(2*scalar(a2))
//
//     scalar Var_E_under1 = ( 1/scalar(E_under1) + 1/(scalar(y)-scalar(E_under1)) + 1/(scalar(n_1)-scalar(E_under1)) + 1 / (scalar(n)-scalar(y)-scalar(n_1)+scalar(E_under1)))^(-1)
//     scalar Var_E_under2 = ( 1/scalar(E_under2) + 1/(scalar(y)-scalar(E_under2)) + 1/(scalar(n_1)-scalar(E_under2)) + 1 / (scalar(n)-scalar(y)-scalar(n_1)+scalar(E_under2)))^(-1)

*    scalar mh_under1 = (scalar(y_1) - scalar(E_under1))^2 / scalar(Var_E_under1) 
*    scalar mh_under2 = (scalar(y_1) - scalar(E_under2))^2 / scalar(Var_E_under2) 
     scalar mh_under = (abs(scalar(y_1) - scalar(Ebar_under))-0.5) / sqrt(scalar(Vbar_under)) 
//      scalar mh_under2 = (abs(scalar(y_1) - scalar(E_under2))-0.5) / sqrt(scalar(Var_E_under2)) 

//     if (scalar(lowbound) <= scalar(E_under1)) & (scalar(E_under1)<=scalar(uppbound)) {
       matrix outmat_`stratval'[`j',3] = scalar(mh_under)
       matrix outmat_`stratval'[`j',5] = 1-normal(scalar(mh_under))
       matrix outmat_`stratval'[`j',7] = scalar(Ebar_under)
       matrix outmat_`stratval'[`j',9] = scalar(Vbar_under)
//     }
//     else {
//        matrix outmat_`stratval'[`j',3] = scalar(mh_under2)
//        matrix outmat_`stratval'[`j',5] = 1-normal(scalar(mh_under2))
//        matrix outmat_`stratval'[`j',7] = scalar(E_under2)
//        matrix outmat_`stratval'[`j',9] = scalar(Var_E_under2)
//     }

    if `j'==1 {
      matrix outmat_`stratval'[`j',6] = (scalar(n_1)*scalar(y)) / scalar(n)
      matrix outmat_`stratval'[`j',7] = (scalar(n_1)*scalar(y)) / scalar(n)
      matrix outmat_`stratval'[`j',8] = scalar(n_1)*scalar(n_0)*scalar(y)*(scalar(n)-scalar(y)) / ( scalar(n)^2*(scalar(n)-1) )
      matrix outmat_`stratval'[`j',9] = scalar(n_1)*scalar(n_0)*scalar(y)*(scalar(n)-scalar(y)) / ( scalar(n)^2*(scalar(n)-1) )
      matrix outmat_`stratval'[`j',2] = (abs(scalar(y_1) - outmat_`stratval'[`j',6])-0.5) / sqrt(outmat_`stratval'[`j',8])
      matrix outmat_`stratval'[`j',4] = 1-normal(outmat_`stratval'[`j',2])
      matrix outmat_`stratval'[`j',3] = (abs(scalar(y_1) - outmat_`stratval'[`j',7])-0.5) / sqrt(outmat_`stratval'[`j',9])
      matrix outmat_`stratval'[`j',5] = 1-normal(outmat_`stratval'[`j',3])
    }

  } /* grid points */

} /* strata */


matrix outmat0 = outmat_1[1...,6..9]

if `nstrata'>1 {
  foreach stratval of numlist 2/`nstrata' { /* strata */
    matrix outmat0 = outmat0 + outmat_`stratval'[1...,6..9]
  }
}

matrix outmat0 = outmat_1[1...,1..1] , outmat0[1...,1..4]
matrix outmat = outmat0

local j = 0
matrix colnames outmat = e_y mhplus mhminus p_mhplus p_mhminus

qui count if `varlist'==1 & _treated==1 
local ytot = r(N)

foreach i of numlist `gamma' { /* grid points */

  local j = `j' + 1
  matrix outmat[`j',2] = (abs(`ytot'-outmat0[`j',2])-0.5) / sqrt(outmat0[`j',4])
  matrix outmat[`j',3] = (abs(`ytot'-outmat0[`j',3])-0.5) / sqrt(outmat0[`j',5])
  matrix outmat[`j',4] = 1-normal(outmat[`j',2])
  matrix outmat[`j',5] = 1-normal(outmat[`j',3])

}

matrix drop outmat0

if `"`stratamat'"' == `""'  {
  foreach stratval of numlist 1/`nstrata' {
    matrix drop outmat_`stratval'
  }
}
 
  
restore

di
di in green "Mantel-Haenszel (1959) bounds for variable " in yellow "`varlist'"
di
di in green "Gamma         Q_mh+     Q_mh-     p_mh+     p_mh-"
di in green "-------------------------------------------------"
local k = rowsof(outmat)
forval i = 1 (1) `k' {
    di in yellow %5.3g outmat[`i',1] "       " _c
    forval j = 2 (1) 5 {
        di in yellow %8.6g outmat[`i',`j'] "  " _c
    }
    di
}

di 
di in green "Gamma : odds of differential assignment due to unobserved factors"
di in green "Q_mh+ : Mantel-Haenszel statistic (assumption: overestimation of treatment effect)"
di in green "Q_mh- : Mantel-Haenszel statistic (assumption: underestimation of treatment effect)"
di in green "p_mh+ : significance level (assumption: overestimation of treatment effect)""
di in green "p_mh- : significance level (assumption: underestimation of treatment effect)""

end
