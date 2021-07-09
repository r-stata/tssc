/* update on 10 Sept 2014
- 2015-04-25: bug in derivative of linear variables fixed
- 2015-08-26: bug fix in the elimination of collinear variables
*/
program npseries, rclass
version 10.0
syntax varlist(numeric min=2) [in] [if] [aw pw iw fw /], ///
[MAXorder(numlist >=1 integer) Order(numlist >=1 integer)  ///
vce(string) DERivative(string) at(string) subpop(string) FIXEDreg ///
LINear(string) logit LISTonly GENerate DETail COLLkeep ]


****** errors
* order OR maxorder
if "`order'"!="" & "`maxorder'"!="" {
	di as err "do not specify order( ) and maxorder ( ) " /*
	*/ "simultaneously"
	exit
}
* check varlist and linear for intersections
loc intersect: list varlist & linear
if "`intersect'"!="" {
	di as err "variables in 'linear' must not appear in 'indepvar'"
	exit
}
******

* save original data
tempfile mydata
qui save `mydata', replace

******


* get dep var and indep var from varlist
gettoken (local) dep (local) indep: varlist
* display specification overview
di "{hline 60}"
di as text "dependent variable" 			_col(25) trim("`dep'")
di as text "covariates:" 					_col(25) trim("`indep' `linear'")
if "`exp'"!="" di as text "weights:" 		_col(25) "`exp'"
if "`derivative'"!="" di as text "derivatives: " _col(25) trim("`derivative'")
if "`maxorder'"!="" {
di as text "maximal order p:" 				_col(25) `maxorder' 
}
loc xlist1  "`indep'"
loc xpand1 "`indep'"

*default weights (if none specified)
if "`exp'"=="" {
tempvar exp
loc weight "pw" /* default weights*/
g `exp'=1 /*no weights specified*/
}
*remove missing observations
marksample touse
tempvar miss
egen `miss' = rowmiss(`varlist' `linear' `exp')
qui replace `touse'=0 if `miss'>0

*specify maxorder for CV
if "`maxorder'"=="" {
	if "`order'"!="" 	loc maxorder=`order'
	else				loc maxorder=2
}
* default: variance estimator
if "`vce'"=="" {
loc vce "robust"
}
* command: linear or logit
if "`logit'"==""		loc cmd "reg"
else					loc cmd "logit"

*derivative at-values
foreach v of loc at {
	tokenize `v', parse("=")
	if "`3'"!="" 	loc derval_`1' = `3'
	else 			loc derval_`1' = ""
}
*temporarily assign variable names to labels
loc all_indep "`indep' `linear'" // all covariates
foreach v of loc all_indep {
loc lab_orig_`v': var l `v'
la var `v' "`v'"
}


*generate variable lists
forvalues p=2/`maxorder' {
*qui {
	
	loc plag=`p'-1
	foreach w of loc xpand`plag' {
	

		foreach v of loc indep {
		
			if "`detail'"=="detail" {
			di "{hline 20}" _n "expand `w' against `v'"
			}
			
			if `p'==2 	loc oldlab "`w'"
			if `p'>2 	loc oldlab: var l `w'
			
			
			****
			*find number of terms of indepvar v
			loc num: word count `oldlab' /*count words in variable label*/
			loc higherpower=0
			forvalues l=1/`num' {
			
				*condition: word l matches to indepvar v
				if regexm(word("`oldlab'",`l'),"`v'\^[2-9]") | regexm(word("`oldlab'",`l'),"^`v'$")  {
					loc word_pos=`l'
					loc higherpower=1
					
					*extract power
					loc pow=trim(regexr(word("`oldlab'",`l'),"`v'",""))
					*define new power = old power + 1
					if "`pow'"==""	{
					loc newpow "^2"
					}
					else 			{
					loc newpow=real(substr("`pow'",2,.)) + 1
					loc newpow "^`newpow'"
					}
					
					*generate the new label
					loc ocount=1
					loc newlab ""
					foreach o of loc oldlab {
					*replace the powered-up variable in the new label
					if `ocount'==`word_pos'		loc newlab "`newlab' `v'`newpow'"
					*keep the other variables the same in the new label
					else 						loc newlab "`newlab' `o'"
					loc ocount=`ocount'+1
					}

					if "`detail'"=="detail" {
					di "oldlab: `oldlab'"
					di "newpow: `newpow'"
					di "newlab: `newlab'"
					}
					
				}
			}
			*if there is no match between indepvar v and w, add v to label
			if `higherpower'==0 {
			loc newlab "`oldlab' `v'"
			if "`detail'"=="detail" di "newlab: `newlab'"
			}

			*produce variable name and generating function
			loc num=`num'+1
			loc vname =trim("`newlab'")
			loc vgen = trim("`newlab'")
			forv l=1/`num' {
			loc vname = regexr("`vname'","\^","") /*delete ^ in name*/
			loc vname = regexr("`vname'"," ","_") /*change space to _ in name*/
			loc vgen = regexr("`vgen'"," ","*")		/*change space to multiplication*/
			}
			if "`detail'"=="detail" {
			di "vname: `vname'"
			di "vgen: `vgen'"
			}
			****
			
			*update expand list
			loc xpand`p' "`xpand`p'' `vname'"
			
			*generate variable if not yet existant
			cap confirm variable `vname' 
			if _rc>0 {
				qui g double `vname' = `vgen'
				lab var `vname' "`newlab'"
				* add to list of generated variables
				loc genvars "`genvars' `vname'"
			}
			

		} /* end of v-loop*/
		

	}	/* end of w-loop*/
	
	*generate overall xlist for order p
	loc xlist`p' "`xlist`plag'' `xpand`p''"
	
	*display detailed results if requested
	if "`detail'"!="" {
		di "expand-list `p' is `xpand`p''"
		di "x-vector of order `p' is " _n "`xlist`p''"
	}
	
*} /* end of quiet */
} /* end of p-loop*/
***
*----------------------------------------------------------------

* get rid of collinear variables starting from largest expansion
*generate variable lists
if "`collkeep'"=="" {

if "`detail'"!="" {
di "{hline 60}" _n "remove collinear variables"
}


forvalues p=2/`maxorder' {


	loc m : word count `xlist`p'' /*number of words in covariate list*/
	loc remaining1 "`xlist`p''" /*copy initial list*/
	loc collvars`p' "" /*list of collinear variables*/
	*di "starting xlist order `p': `xlist`p''"
	*di "number of words : `m'"

		*run across variable list, starting with the last one
		forv i=`m'(-1)1  {
		
			loc vname : word `i' of `xlist`p'' /* extract variable name*/
			loc remaining2: list remaining1 - vname /*define remaining ones*/
			*di "test `vname' against list `remaining2'"
			
			*test for collinearity
			*only include max 10000 obs. in collinearity test for speed
			qui count if `touse'
			if r(N)>10000 {
			tempvar ind
			g `ind'=(runiform()<10000/r(N)) if `touse'
			loc inclu "& `ind'==1"
			}
			*perform test
			noi cap _rmdcoll `vname' `remaining2' if `touse' `inclu'
			
			*if yes: 
			if _rc==459 {
				*add to collvar-list
				loc collvars`p' "`collvars`p'' `vname'"
				* if vname is collinear, update remaining1-list
				loc remaining1: list remaining1 - vname
				*di "`vname' is collinear against `remaining2'"
			}
			else {
				*di "`vname' is NOT collinear against `remaining2'"
			}
			
		} /* end of i-loop*/
		
		*get difference between original list and collinear list
		loc xlist`p' : list xlist`p' - collvars`p'
		loc xpand`p' : list xpand`p' - collvars`p'
		loc collvars_all: list collvars_all | collvars`p' 
		
		*display detailed information
		if "`detail'"!="" {
			di "{hline 20}" _n "xlist `p' : `xlist`p'' "
			di "collinear: `collvars`p''"
			di "non-collinear (up to order `p'): `xlist`p''"
			di "non-collinear (only order `p') : `xpand`p''"
			di "{hline 20}"
		}
		

} /* end of p loop */
} /* end of if "`collkeep'"=="" */
**



*----------------------------------------------------------------

* return locals of lists
forv p=`maxorder'(-1)2 {
	ret loc expand_`p' "`xpand`p''"
}
ret loc linear "`linear'"

* abort if user only needs macro lists
if "`listonly'"!="" {
	if "`keepcoll'"=="" {
		*di "drop collinear variables: " _n "`collvars_all'"
		drop `collvars_all'
	}
	if "`generate'"=="" use `mydata', clear
	exit
}

*di "genvars is : `genvars'"

*---------------------------------------------------------


* determine CV-minimizing order

if "`order'"=="" {

	*CV: search for optimal order
	di "{hline 60}"
	di "Model is run for polynomial order 1 through `maxorder'." _n ///
		"The cross-validation criteria:"
	mat CV=J(`maxorder',2,.)	
	forv p=1/`maxorder' {
		mata: compute_cv("`dep'", "`xlist`p''", "`linear'", "`exp'", "`touse'")
		mat CV[`p',1]=`p'
		mat CV[`p',2]=sca_cv
		*reg `dep' `xlist`p'' if `touse'
		di as res "    CV(`p') = " %10.0g sca_cv
		if "`detail'"!="" di as text "(regressors: `xlist`p'')"
		sca drop sca_cv
	} 
	mat coln CV=order CV
	ret mat CV=CV, copy
	
	
	*pick minimum bandwidth out of grid
	mata:R=st_matrix("CV")
	mata:cv=R[.,2]
	mata:popt=.
	mata:w=J(1,2,.)
	mata:minindex(cv,1,popt,w)
	mata:popt=popt[1,1]
	mata:cv_popt=cv[popt,1]
	mata:st_numscalar("sca_popt", popt)
	*mata:st_numscalar("`sca_cv_popt'", cv_popt)

	*save optimal order p in local
	loc popt=sca_popt
	sca drop sca_popt

}

*Title
if "`cmd'"=="logit" loc logit_title "Logit "
di "{hline 78}" _n as res "Nonparametric `logit_title'Series Estimation"
if "`order'"=="" { /*CV order*/
	di as text _n "Model is estimated using the polynomial order p=`popt'," _n ///
	"where the cross-validation criterion is minimized"
}
else { /*user specified order*/
di as text "Polynomial order is set by the user: p=`order'"
loc popt=`order'
}

*---------------------------------------------------------

* Estimation

*estimate model
`cmd' `dep' `xlist`popt'' `linear'  [`weight'=`exp'] if `touse', vce(`vce')
if "`logit'"=="logit" {
	tempvar yhat 
	qui predict `yhat'
}
tempname myest Vb b
est sto `myest'
mat `Vb'=e(V)
mat `b'=e(b)
loc k=rowsof(`Vb')

*return locals
ret loc popt "`popt'"
ret loc xlist "`xlist`popt'' `linear'"

**
*---------------------------------------------------------

* derivatives
if "`derivative'"!="" {

tempname Der Dcov 
tempvar c
g `c' = 0 /*constant: always zero in derivative calculations*/

/*labels of original independent variables must be set to varnames
foreach v of loc indep {
la var `v' "`v'"
}*/

/*list of all regressors*/
loc xlist "`xlist`popt'' `linear'" 
*di "xlist: `xlist'"		


foreach cov of loc derivative {

	*restore estimates of model
	qui est res `myest'

	loc dervar "`cov'" /* covariate subject to derivative*/
	
	*reset lists
	loc Dxlist ""
	loc Dylist ""
	loc dMElist ""
	

	foreach v of loc xlist {

		/*get variable label and name*/
		loc vlab: var l `v'	
		* in case of linear variable: use variable name
		if strmatch("`v'","`linear'") {
		loc vlab "`v'"
		}
		loc nwords: word count `vlab' /*count words in variable label*/
		loc vgen "" /*reset variable generating string*/
		loc match=0
		
		* run across words 
		forv w=1/`nwords' {
		
			if `w'<`nwords' loc multiply "*" /*before last component*/
			else			loc multiply ""	 /*last component*/
			
			* w-th word of label
			loc vsub = word("`vlab'",`w')
			
			*does the w-th variable have a fixed value?
			tokenize `vsub', parse("^")
			*local 1: variable name
			*local 2: ^ (if present)
			*local 3: power (if present)
			if "`derval_`1''"!="" { /*assign fixed value*/
			loc wval = `derval_`1''
			loc vsub = `derval_`1'' `2' `3'
			}
			else { /*assign variable name*/
			loc wval = "`1'"
			}
			
			* if matched to dervar, we compute derivative component
			if strmatch("`1'","`dervar'") {
			
				loc match=1 /*indicate that a match was found*/
			
				*get power of variable in vsub
				loc pow = real("`3'")
				if `pow'==. loc pow=1
				*compute first-order derivative of the variable v w.r.t. dervar
				
				loc vgen "`vgen' `pow'*`wval'^(`pow'-1) `multiply'" 
			}
			else {
				loc vgen "`vgen' `vsub' `multiply'"
			}
			
		} /* end of w loop*/
		
		*if no match was made, set to zero
		if `match'==0 loc vgen " 0"
		
		*generate derivative
		if "`detail'"!="" di "d(`v')/d(`dervar') " _col(35) "= `vgen'"
		qui g double Dx_`v' = `vgen'
		loc Dxlist "`Dxlist' Dx_`v'"
		
		*in case of logit, multiply with odds for marginal effect
		if "`logit'"=="logit" {
			qui g double Dxb_`v' = `vgen' * _b[`v']
			qui g double Dy_`v' = `yhat'*(1-`yhat')*`vgen'
			loc Dylist "`Dylist' Dy_`v'"
		}
		
	} /* end of v loop */

	/*logit: derivative of marginal effect
	if "`logit'"!="" {
		su Dxb*
		egen Dxb_sum = rowtotal(Dxb_*) 
		foreach v of loc xlist {
			g double dME_`v'=`yhat'*(1-`yhat')*((1-2*`yhat')*Dxb_sum*`v' +  Dx_`v')
			loc dMElist "`dMElist' dME_`v'"
		}
	}*/
	
	* subpopulation
	if "`subpop'"!="" loc ifsubpop "& `subpop'"
	
	* estimate average derivatives
	tempname VDx Dx Dx2
	if "`cmd'"=="reg" 	qui mean `Dxlist' `c' if `touse' `ifsubpop'
	if "`cmd'"=="logit" qui mean `Dylist' `c' if `touse' `ifsubpop'
	mat `VDx' = e(V)
	mat `Dx' = e(b)'
	
	/*logit: derivative of marginal effect
	if "`logit'"=="logit" {
	mean `dMElist' `c' if `touse' `ifsubpop'
	mat `Dx2' = e(b)'
	}*/
	mata: b		=st_matrix("`b'")' 		/*coefs*/
	mata: Vb	=st_matrix("`Vb'")		/*Var(coefs)*/
	mata: Dx	=st_matrix("`Dx'")'		/*dervatives of x-vector*/
	*mata: Dx2	=st_matrix("`Dx2'")'	/*logit: dervatives of x-vector*/
	mata: VDx 	=st_matrix("`VDx'")		/*variance of derivatives of x-vector*/
	mata: der=Dx*b
	
	if "`cmd'"=="reg" { /*regression*/
		mata: se=sqrt(Dx*Vb*Dx' + b'*VDx*b)
		if "`fixedreg'"!="" {
			mata: se=sqrt(Dx*Vb*Dx')
		}
	}
	else { /*logit*/
		mata: se=sqrt(Dx*Vb*Dx')
	}
	
	*collect results
	mata: p=2*(1-normal(abs(der/se)))
	mata: st_matrix("`Dcov'",(der, se, p))
	mat `Der' = nullmat(`Der') \ `Dcov'

	cap drop Dx_*
	cap drop Dxb_*
	cap drop Dy_*
	cap drop dME_*

} /* end of cov loop */
***



* save matrix with derivative estimates
mat coln `Der' = derivative st_err pval
mat rown `Der' = `derivative'
ret mat Der = `Der', copy

* display derivative estimates
loc nrows = rowsof(`Der')
if "`at'"!="" 		loc text_at "calculated at `at'"
if "`subpop'"!="" 	loc text_subpop "for subpopulation with `subpop'"

di as text _n "Average Marginal Effects"
di as text _col(22) "Est." _col(29) "Std.Err." _col(41) "p-val."
di as text "{hline 50}"
forv r=1/`nrows' {
loc vname = word("`derivative'",`r')
di as text _col(2) "`vname'" _col(10)  as res ///
							_col(17) %9.0g 	`Der'[`r',1] ///
							_col(28) %9.0g  `Der'[`r',2] ///
							_col(39) %8.4f  `Der'[`r',3] 
}
di as text "{hline 50}"
di as text "`text_at'" _n "`text_subpop'"


* restore estimates of regress
qui est restore `myest'
}
***

*restore data if user doesn't want to generate variables
if "`generate'"=="" {
	qui use `mydata', clear
}
*if user wants to generate variables but without collinear ones:
if "`generate'"!="" & "`collkeep'"=="" {

		if "`detail'"!="" di "drop: `collvars_all'"
		foreach v of loc collvars_all {
				cap drop `v'
		} 

} /* end of if*/

*re-assign original variable labels
foreach v of loc all_indep {
	la var `v' "`lab_orig_`v''"
}
***

end


*---------------------------------------------------------
* cross-validation

mata
void compute_cv(string scalar dep, string scalar xlist, //
 string scalar linear, string scalar exp, string scalar touse)
{
	X=st_data(.,(tokens(xlist),tokens(linear)),touse)
	X=J(rows(X),1,1),X
	y=st_data(.,dep,touse)
	w=st_data(.,exp,touse)
	n=rows(y)
	k=cols(X)
	h=J(n,1,.)
	b=invsym( (X:*w)'*X ) * (X:*w)' * y
	e=y-X*b
	//e[1::10,1]
	W=invsym(X'*X)
	h = rowsum( (X*W):*X )
	e_cv=e :* (J(n,1,1):/(J(n,1,1)-h))
	mse=(1/(n-k)) * (e'*e)
	cv =(1/n) * (e_cv'*e_cv)
	//cv
	st_numscalar("sca_cv",cv)
}
end
