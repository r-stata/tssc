
program define ivtobit6
version 6.0
syntax varlist  [if] [in], ENDOG(varlist) IV(varlist) EXOG(varlist) [LL(real 0)   UL(real 9999999)]

* parse "`*'"
local depvar "`varlist'"
tempvar tmpy touse
marksample touse

local niv : word count `iv' 
local nendog : word count `endog'
local nexog : word count `exog'

local K=`nexog'+`niv'		            /* K=total number of exogenous variables */
matrix Dhat=J(`K'+1,`nendog'+`nexog'+1,0)  /* Inititialize Dhat matrix */

/* fill in remaining columns of Dhat= I_1: lower right identity matrix */
matrix Dhat[`niv'+1,`nendog'+1]=I(`nexog'+1)

parse "`endog'", parse(" ")
local e = 1			/* do 1st stage regression for each endogenous variable */	
while `e'<=`nendog' {			
	qui regress `1' `iv' `exog' if `touse'
	matrix tmp=get(_b)
	matrix Dhat[1,`e']=tmp'
	tempvar fitted`e' resid`e'		
	qui predict `fitted`e'' `if'	
	qui replace  `fitted`e'' =. if `1' ==.  
	qui predict `resid`e'' `if', residuals	
	qui replace `resid`e'' =. if `1' ==.	
	local fitted "`fitted' `fitted`e''"	
	local resid "`resid' `resid`e''"	
	mac shift
  	local e = 1 + `e'	
}

/* get lee model estimates */

qui tobit `depvar' `fitted' `exog' if `touse',ll(`ll') ul(`ul')
matrix tmp = get(_b)
matrix beta=tmp[1,1..`nendog']
local nobs=e(N)



* Run tobit of depvar on resid, and exog variables
qui tobit `depvar' `iv' `exog' `resid' if `touse',ll(`ll') ul(`ul')
local obs = e(N)
local df = e(df_m)
matrix tmp = get(_b)
matrix alpha=J(1,`K'+1,0)  /* initialize alpha */

matrix alpha[1,1]=tmp[1,1..`K']  /* take coefficients on all exog variables */
matrix alpha[1,`K'+1]=tmp[1,`K'+`nendog'+1]  /*get coefficient on constant (skipping coefs on residuals */				
matrix lamda=tmp[1,`K'+1..`K'+`nendog'] 	/* coefficients on residuals go into lamda */
matrix tmp = get(VCE)			/* now get VCE matrix, skipping residuals */
matrix Jinv=J(`K'+1,`K'+1,0)		/* initialize Jinv matrix and move VCE matrix into it */
matrix Jinv[1,1]=tmp[1..`K',1..`K']
local i 1
while `i'<=`K'  {
	matrix Jinv[`K'+1,`i']=tmp[`K'+`nendog'+1,`i']
	matrix Jinv[`i',`K'+1]=Jinv[`K'+1,`i']
	local i=`i'+1
}
matrix Jinv[`K'+1,`K'+1]=tmp[`K'+`nendog'+1,`K'+`nendog'+1]

local e 1
gen `tmpy'=0
parse "`endog'", parse(" ")
while `e'<=`nendog' {
	local tmp=lamda[1,`e']-beta[1,`e']
	qui replace `tmpy'=`tmpy'+`1'*`tmp'
	mac shift
	local e=`e'+1
}
qui regress `tmpy' `iv' `exog' if `touse'
matrix V=get(VCE)

matrix Omega=V+Jinv
matrix OmInv=inv(Omega)
matrix delta1=Dhat' * OmInv  * Dhat
matrix rownames delta1= `endog' `exog' _cons
matrix colnames delta1= `endog' `exog' _cons
matrix delta1=inv(delta1)

matrix delta2=Dhat' * OmInv * alpha'
matrix delta=delta1 * delta2
matrix rownames delta = `endog' `exog' _cons
matrix delta=delta'


est post delta delta1, obs(`nobs<) depname(`depvar') esample(`touse')
estimates disp

end
