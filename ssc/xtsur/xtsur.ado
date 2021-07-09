*! version 1.0.4  11Dec2009
*! Minh Cong Nguyen - Email: congminh6@gmail.com or mnguyen3@worldbank.org
*! Hoa Bao Nguyen - nguye147@msu.edu
* version history:
* 1.0.4: 11Dec2009 - report variance-covariance matrix of random effects.
* 1.0.3: 22Aug2009 - handle missing observations for variables.
* 1.0.1: 26Jun2008 - update with different independent variables for all equations.
*                  - the parsing structure was taken from the reg3.ado (Stata).
* 1.0.0: 01Aug2007 - same independent variables for all equations.

cap program drop xtsur
program define xtsur, eclass byable(recall) sortpreserve
	version 9
	if replay() {
		if "`e(cmd)'"!="xtsur" {
			error 301
		}
		if _by() {
			error 190
		}
		syntax [, Level(cilevel)]
		`not' _coef_table, level(`level')
	}
	else {
		/*  Parse (y1 x1 x2) (y2 y1 x2 x3) structure.
		 *  Pick up full varlist (flist), y-array (y`i'), indendent
		 *  variables (ind`i') left-hand  sides (lhslist), 
		 *  equation names (eqnm`i')
		*/
		local neqn = 0
		local cmdline: copy local 0
		/*  Parse the equations ([eqname:] y1 [y2 y3 =] x1 x2 x3) 
		 *  and fill in the structures required for estimation */

		gettoken fulleq 0 : 0, parse(" ,[") match(paren)
		IsStop `fulleq'
		while `s(stop)' == 0 { 
			if "`paren'" != "(" {		/* must be eq */
				eq ?? `fulleq' 
				local fulleq "`r(eqname)': `r(eq)'"
			} 
			parseEqn `fulleq'

			/* Set-up equation bookeeping structures */
			
			local flist `flist' `depvars' `indvars'
			
			tokenize `depvars'
			local i 1
			while "``i''" != "" {
				local neqn = `neqn' + 1
				local y`neqn' ``i''
				local lhslist `lhslist' ``i''
				local ind`neqn' `indvars'
				local cons`neqn' = ("`constan'" == "")
				nameEq "`eqname'" "``i''" "`eqlist'" `neq'
				local eqnm`neqn' = "`s(eqname)'"
				local eqlist `eqlist' `s(eqname)'
				local i = `i' + 1
			}
			
			gettoken fulleq 0 : 0, parse(" ,[") match(paren)
			IsStop `fulleq'
		}
		forvalue eq =1(1)`neqn' {
			local findvar `findvar' `ind`eq''
		} 
		
		local 0 `"`fulleq' `0'"'

		if `neqn' < 1 { 
			di in red "equation(s) required" 
			exit 198
		}
	syntax  [if] [in] [,Level(cilevel) TOLerance(real 1e-6) ONEstep MULTIstep]
	if ("`tolerance'"!="") {
		local tol = `tolerance'
	} 
	else {
		local tol = 1e-6
	}
	if ("`level'"!="") {
		local lvl = `level'
	} 
	else {
		local lvl = 95
	}
	if ("`onestep'"!="") + ("`multistep'"!="") >1 { 
        di in red "choose only one method: onestep  or multi-step"
        exit 198 
	}
	if (`"`multistep'"'!=`""' | `"`multistep'"'==`""' & `"`onestep'"'==`""') { 
		di in gr "(running multi-step estimates...)"
		di ""
		local method = 1
	}
	else if `"`onestep'"'!=`""' {
		di in gr "(running onestep estimates...)"
		di ""
		local method = 2
	}			
	/* set obs to use */
	marksample touse
	markout `touse' `flist' 
	// tsset must be defined before running the program, ivar must be numeric
	xt_iis
	local ivar "`s(ivar)'"
	xt_tis 
	local tvar "`s(timevar)'"
	
	tempname xtstr1 pd1 b var
	xtstructure `ivar' if `touse'
	mat `xtstr1' = r(xtstr)
	quietly { // sort the data to get the estimation structure N1 comes first.
		bysort `ivar': gen `pd1' =_N if `touse'
		gsort `pd1' `ivar' `tvar'
	}
	local k =`:word count `findvar''	
	mat `b' = J(1,`k',0)
	mat `var'  = J(`k',`k',1)
	mata: _xtsurub("`lhslist'", "`touse'", "`b'", "`var'")	
	
	global anames ""
	forv i=1/`neqn' {
		local nvarl: word count `ind`i''
		tokenize `ind`i''
		forv j=1/`nvarl' {
			global anames "$anames `eqnm`i'':``j''"
		}
	}
	qui _rmcoll `findvar' if `touse'
	local exog `r(varlist)'
	qui count if `touse'
	local N = r(N)
	qui su `ivar' if `touse'
	local Ng = r(max)
	mat colnames `b' = $anames
	mat colnames `var' = $anames
	mat rownames `var' = $anames
	qui xtset
	di in gr "Random effects u_i ~ " in ye "Gaussian" 
	di in gr "corr(u_i, e_it)" _col(20) "= " in ye "0" in gr " (assumed)"
    di in gr "Panel type" _col(20) ": " in ye "`r(balanced)'"             
	di 
	
	ereturn post `b' `var', esample(`touse')
	ereturn display, level(`lvl') plus
	ereturn scalar N =`N'
	ereturn scalar k_eq = `neqn'
	ereturn scalar N_g = `Ng'
	ereturn scalar g_min = `xtstr1'[1,1]
	ereturn scalar g_max = `xtstr1'[rowsof(`xtstr1'),1]
	ereturn scalar T = rowsof(`xtstr1')
	ereturn scalar tol = `tol'
	ereturn scalar cilevel = `lvl'
	ereturn local ivar "`ivar'"
	ereturn local tvar "`tvar'"
	ereturn local cmd "xtsur"
	ereturn local cmdline `"xtsur `cmdline'"'
	ereturn local endog "`lhslist'"
	ereturn local exog "`exog'"
	ereturn local depvar "`lhslist'"
	ereturn local eqnames "`eqlist'"
	ereturn local properties "b V"
	ereturn local version "1.0.3"
	ereturn local title "Seemingly-unrelated regressions in panel data with random effect"
	ereturn matrix sigma_u _sigma_u
	ereturn matrix sigma_e _sigma_e
	if (`method'==1) {
		ereturn local method "multi-step maximum likelihood"
	}
	else {
		ereturn local method "one-step maximum likelihood"
	}
	// Display covariance matrix of u (alpha) and e (error)
	di in smcl in gr "     sigma_u {c |} " in gr "  see e(sigma_u)"
    di in smcl in gr "     sigma_e {c |} " in gr "  see e(sigma_e)"
    di in smcl in gr "{hline 13}{c BT}{hline 64}"

	// Display additional information
	`nof' DispVars "Dependent variables:   " "`lhslist'" 24 78 green
	`nof' DispVars "Independent variables: " "`exog'" 24 78 green
	`noh' di in smcl in gr "{hline 78}"
	            
	} // end of if replay() condition

end

// -------------------------- MATA IN THIS PROGRAM --------------------------
version 9
mata:
mata drop *()
mata set matalnum off
mata set mataoptimize on
void _xtsurub(string scalar varname, string scalar tousename, string scalar bxtsur, string scalar vxtsur)
{	
	real scalar neq, method, tol
	real matrix Np, Npp
	pointer(real matrix) vector allX, pbeta_p, pVbeta_p, pVbeta, pvec_o_p, pvec_s_p, pWee_p, pBee_p, psigma_u_p, psigma_p, pXOmgX, pXOmgY

	tvar = st_local("tvar")
	ivar = st_local("ivar")
	
	neq = strtoreal(st_local("neqn"))
	Npp = st_matrix(st_local("xtstr1"))
	Np  = Npp[.,2] :/ Npp[.,1]
	Obs = rows(Npp)

	allX       = J(neq,1,NULL)
	pvec_o_p   = J(rows(Npp),1,NULL)
	pvec_s_p   = J(rows(Npp),1,NULL)
	pbeta_p    = J(rows(Npp),1,NULL)
	pVbeta_p   = J(rows(Npp),1,NULL)
	pVbeta     = J(rows(Npp),1,NULL)				
	pWee_p     = J(rows(Npp),1,NULL)	
	pBee_p     = J(rows(Npp),1,NULL)	
	psigma_u_p = J(rows(Npp),1,NULL)	
	psigma_p   = J(rows(Npp),1,NULL)
	pXOmgX     = J(rows(Npp),1,NULL)
	pXOmgY     = J(rows(Npp),1,NULL)
	
	//Yall=st_data(.,tokens(st_local("lhslist")),tousename)
	Yall=st_data(.,tokens(varname), tousename)
	
	for (i=1; i<=neq; i++) {
		tempind = `"ind"' + strofreal(i) // tao ind1, ind2, ind3,....
		allX[i] = &(st_data(.,tokens(st_local(tempind)), tousename)) 
		//allX[i] = &(st_data(.,tokens(tempind), tousename)) 
	}
	//*allX[1], *allX[2], *allX[3]
	// How to call element of this: (*allX[1])[1..10,.]
	
	// STEP 1: Run OLS seperately on all G equations in (2), using all observations on yit and Xit.
	// Stacking the estimators, we get the joint estimator vector BetaOLS, then get the residual
	// eit = yit - Xit*BetaOLS for all i and t.
	
	beta = invsym((*allX[1])'(*allX[1]))*((*allX[1])'Yall[.,1])
	for (i=2; i<=neq; i++) {
		temp = invsym((*allX[i])'(*allX[i]))*((*allX[i])'Yall[.,i])
		beta = beta \ temp
	}
	betaML = beta
	// form Xit
	Yvec = vec(Yall')
	// for the first block xit
	temp = (*allX[1])[1,.]
	for (i=2; i<=neq; i++) {
		Xit = blockdiag(temp,(*allX[i])[1,.])
		temp = Xit
	}
	// for the second blocks onwards
	for (j=2; j<=rows(Yall); j++) {
		temp = (*allX[1])[j,.]
		for (i=2; i<=neq; i++) {
			temp1 = blockdiag(temp,(*allX[i])[j,.])
			temp = temp1
		}
		Xit = Xit \ temp1
	}
	
	iter1 = 1
	lastbetaML = J(cols(Xit),1,0)	
	printf("{txt}Calculating multi-step estimates...\n")	
	tol = strtoreal(st_local("tol"))
	while (mreldif(betaML, lastbetaML) > tol) {
		iter = 1
		lastbeta = J(cols(Xit),1,0)
		lastbetaML = betaML
		while (mreldif(beta, lastbeta) > tol) {
		
			lastbeta = beta
			res = Yvec - Xit*beta // create OLS residuals
		
			// STEP 2: Compute Within and Between matrices of residuals, Wee and Bee
			resm = res[1::neq,1]
			for (i = neq + 1; i<=rows(res); i = i + neq) {
				temp1 = res[i::i + neq - 1,1]
				resm = resm, temp1
			}
			i=1
			x=1
			tb=0
			allbar = J(neq,1,0)
			while (i <= cols(resm)) {
				ta = 0
				for (j = 1; j <= Np[x]; j++) {  // loops between the number of individuals who observed Npp[x,1] times
					bar = J(neq,1,0)
					for (s = 1; s <= Npp[x,1]; s++) {  
						// loops between the number of periods for those individuals who observed Npp[x,1] periods
						temp = resm[.,tb + s + (ta*Npp[x,1])]
						bar = bar :+ (1/Npp[x,1])*temp
					}
					ta = ta + 1
					allbar = allbar , bar
				}	
				i = i + Npp[x,2]
				tb = tb + Npp[x,2]
				x = x + 1
			}
			allbar = allbar[.,2::cols(allbar)] // drop the first column of zeros since we assumed so.
			// allbar is the matrix of ebar_idot for all i	
			// using the same loop method to calculate Wee
			i=1
			x=1
			tb=0
			ja = 0
			Wee = J(neq,neq,0)
			
			while (i <= cols(resm)) {
				ta = 0
				for (j = 1; j <= Np[x]; j++) {  // loops between the number of individuals observed Npp[x,1] times
					bar = J(neq,1,0)
					for (s = 1; s <= Npp[x,1]; s++) {  // loops between the number of periods for those Np individuals
						temp = resm[.,tb + s + (ta*Npp[x,1])] :- allbar[.,j + ja]
						Wee = Wee :+ temp*temp'
					}
					ta = ta + 1
				}	
				ja = ja + Np[x]
				i = i + Npp[x,2]
				tb = tb + Npp[x,2]
				x = x + 1
			}
			
			// using the same loop method to calculate Bee
			// first calculate ebar
			ebar = J(neq,1,0)
			x=1
			ja = 0
			j = 1 
			while (j <= colsum(Np)) {  
				for (i = 1; i <= Np[x]; i++) {
					temp = (1/colsum(Np))*Npp[x,1]*allbar[.,i + ja]
					ebar = ebar :+ temp
				}
				j = j + Np[x]
				ja = ja + Np[x]
				x = x + 1
			}
	
			// calculate Bee
			Bee = J(neq,neq,0)
			x=1
			ja = 0
			j = 1 
			while (j <= colsum(Np)) {  
				for (i = 1; i <= Np[x]; i++) {
					temp = allbar[.,i+ja] :- ebar
					Bee = Bee :+ Npp[x,1]*temp*temp'
				}
				j = j + Np[x]
				ja = ja + Np[x]
				x = x + 1
			}
	
			// STEP 3: Estimate sigma_u, sigma_alpha, sigma_p for p = 1,...,P
			// Sigma_u
			sigma_u = Wee :/ (colsum(Npp[.,2])-colsum(Np))
	
			// calculate element to get sigma_a
			temp = 0
			for (i=1; i <= rows(Npp); i++) {
				temp = temp + Np[i]*Npp[i,1]*Npp[i,1]
			}
			temp = colsum(Npp[.,2]) - (1/colsum(Npp[.,2]))*temp
			sigma_a = (1/temp)*(Bee :- ((colsum(Np) - 1)/(colsum(Npp[.,2])-colsum(Np)))*Wee)
	
			// sigma_p, omega_p with p = P,...,1 are stored in pointer *pvec_s_p[] and *pvec_o_p[], accordingly.
	
			for (i=1; i <= rows(Npp); i++) {
				Ap = (1/Npp[i,1])*J(Npp[i,1],Npp[i,1],1)
				Bp = I(Npp[i,1]):-(1/Npp[i,1])*J(Npp[i,1],Npp[i,1],1)
				pvec_s_p[i] = &(sigma_u :+ Npp[i,1]*sigma_a)
				// pvec_o_p[i] = &(Bp#sigma_u :+ Ap#sigma_a) //?
				pvec_o_p[i] = &(Bp#sigma_u :+ Ap#(*pvec_s_p[i]))
			}
			
			// STEP 4: Compute the BetaGLS
			s = 0
			for (j=1; j <= rows(Npp); j++) {
				XOmgX = J(cols(Xit),cols(Xit),0)
				XOmgY = J(cols(Xit),1,0)
				t = 0
				for (i=1; i<=Np[j]; i++) {
					Xip = Xit[|s + t*neq*Npp[j,1] + 1 , 1 \ s + t*neq*Npp[j,1] + neq*Npp[j,1] , cols(Xit)|]
					Yip = Yvec[|s + t*neq*Npp[j,1] + 1 , 1 \ s + t*neq*Npp[j,1] + neq*Npp[j,1] , 1|]
					temp = Xip'*invsym(*pvec_o_p[j])*Xip
					temp1 = Xip'*invsym(*pvec_o_p[j])*Yip
					XOmgX = XOmgX :+ temp
					XOmgY = XOmgY :+ temp1
					t = t + 1
				}
				s = s + Npp[j,2]
				pXOmgX[j] = &(XOmgX)
				pXOmgY[j] = &(XOmgY)
				pbeta_p[j] = &(invsym(XOmgX)*XOmgY)
				pVbeta_p[j] = &(invsym(XOmgX))
			}
		
			// get the overall beta GLS and the variance of beta GLS
			temp = J(cols(Xit),cols(Xit),0)
			temp1 = J(cols(Xit),1,0)
			temp2 = J(cols(Xit),cols(Xit),0)
			temp3 = J(cols(Xit),1,0)
			for (j=1; j <= rows(Npp); j++) {
				temp = temp :+ invsym(*pVbeta_p[j])
				temp1 = temp1 :+ invsym(*pVbeta_p[j])**pbeta_p[j]
				temp2 = temp2 :+ *pXOmgX[j]
				temp3 = temp3 :+ *pXOmgY[j]			
			}
			Vbeta = invsym(temp2)
			beta = invsym(temp)*temp1
			iter = iter + 1
		} // end of while() GLS beta, iter
	
		// now get the new residual for ML part		
		res = Yvec - Xit*beta // create GLS residuals
		resm = res[1::neq,1]
		for (i = neq + 1; i<=rows(res); i = i + neq) {
			temp1 = res[i::i + neq - 1,1]
			resm = resm, temp1
		}
		i=1
		x=1
		tb=0
		
		// calculate the Weep tidle and Beep tidle
		while (i <= cols(resm)) {
			ta = 1
			Wee_p = J(neq,neq,0)
			Bee_p = J(neq,neq,0)
			for (j = 1; j <= Np[x]; j++) {  // loops between the number of individuals observed Npp[x,1] times
				Ap = (1/Npp[x,1])*J(Npp[x,1],Npp[x,1],1)
				Bp = I(Npp[x,1]):-(1/Npp[x,1])*J(Npp[x,1],Npp[x,1],1)
				Eip = resm[|1, 1 + tb + (ta-1)*Npp[x,1] \ neq, tb + ta*Npp[x,1]|]
				Wee_p = Wee_p :+ Eip*Bp*Eip'
				Bee_p = Bee_p :+ Eip*Ap*Eip'	
				ta = ta + 1
			}	
			psigma_p[x] = &((1/Np[x,1])*Bee_p)
			psigma_u_p[x] = &((1/(Np[x,1]*(Npp[x,1]-1)))*Wee_p)
			i = i + Npp[x,2]
			tb = tb + Npp[x,2]
			x = x + 1
		}
		
		// loops between rows of Npp to get sigma_p, sigma_u_p, and betaGLS_p
		s = 0
		for (j=1; j<= rows(Npp); j++) {
			XOmgX = J(cols(Xit),cols(Xit),0)
			XOmgY = J(cols(Xit),1,0)
			t = 0
			if (Npp[j,1] > 1) {
				for (i=1; i<=Np[j]; i++) {
					Ap = (1/Npp[j,1])*J(Npp[j,1],Npp[j,1],1)
					Bp = I(Npp[j,1]):-(1/Npp[j,1])*J(Npp[j,1],Npp[j,1],1)
					Xip = Xit[|s + t*neq*Npp[j,1] + 1 , 1 \ s + t*neq*Npp[j,1] + neq*Npp[j,1] , cols(Xit)|]
					Yip = Yvec[|s + t*neq*Npp[j,1] + 1 , 1 \ s + t*neq*Npp[j,1] + neq*Npp[j,1] , 1|]
					temp = Xip'*(Bp#invsym(*psigma_u_p[j]))*Xip :+ Xip'*(Ap#invsym(*psigma_p[j]))*Xip
					temp1 = Xip'*(Bp#invsym(*psigma_u_p[j]))*Yip :+ Xip'*(Ap#invsym(*psigma_p[j]))*Yip
					XOmgX = XOmgX :+ temp
					XOmgY = XOmgY :+ temp1
					t = t + 1
				}
			} else {
				// only sigma(1) is estimated
				for (i=1; i<=Np[j]; i++) {
					Ap = (1/Npp[j,1])*J(Npp[j,1],Npp[j,1],1)
					Bp = I(Npp[j,1]):-(1/Npp[j,1])*J(Npp[j,1],Npp[j,1],1)
					Xip = Xit[|s + t*neq*Npp[j,1] + 1 , 1 \ s + t*neq*Npp[j,1] + neq*Npp[j,1] , cols(Xit)|]
					Yip = Yvec[|s + t*neq*Npp[j,1] + 1 , 1 \ s + t*neq*Npp[j,1] + neq*Npp[j,1] , 1|]
					temp = Xip'*(Bp#invsym(sigma_u))*Xip :+ Xip'*(Ap#invsym(*psigma_p[j]))*Xip
					temp1 = Xip'*(Bp#invsym(sigma_u))*Yip :+ Xip'*(Ap#invsym(*psigma_p[j]))*Yip
					XOmgX = XOmgX :+ temp
					XOmgY = XOmgY :+ temp1
					t = t + 1
				}
			}
				
			s = s + Npp[j,2]
			pXOmgX[j] = &(XOmgX)
			pXOmgY[j] = &(XOmgY)
			pbeta_p[j] = &(invsym(XOmgX)*XOmgY)
			pVbeta_p[j] = &(invsym(XOmgX))
		}
		// get the betaML and the variance of betaML
		temp = J(cols(Xit),cols(Xit),0)
		temp1 = J(cols(Xit),1,0)
		temp2 = J(cols(Xit),cols(Xit),0)
		temp3 = J(cols(Xit),1,0)

		for (j=1; j <= rows(Npp); j++) {
			temp = temp :+ invsym(*pVbeta_p[j])
			temp1 = temp1 :+ invsym(*pVbeta_p[j])**pbeta_p[j]
			temp2 = temp2 :+ *pXOmgX[j]
			temp3 = temp3 :+ *pXOmgY[j]
		}
		VbetaML = invsym(temp2)
		betaML = invsym(temp)*temp1            // this is the betaML
		printf("{txt}Iteration {res}%3.0f{txt} : relative difference = {res}%10.0g\n", iter1, mreldif(betaML, lastbetaML)) 
		iter1 = iter1 + 1
		method = strtoreal(st_local("method"))
		if (method == 2) break
	} // end of ML, iter1

	st_matrix("_sigma_e", sigma_u)
	st_matrix("_sigma_u", sigma_a)
	st_replacematrix(bxtsur, betaML')
	st_replacematrix(vxtsur, VbetaML)

	printf("\n")
	printf("{txt}\nSeemingly unrelated regression (SUR) in panel data set\n")
	printf("{txt}\nOne-way random effect estimation:\n")
	printf("{hline 78}\nNumber of Group variable: {res}%4.0f{txt}{col 49}Number of obs      = {res}%9.0f\n", rows(Npp), rows(Yall))
	printf("{txt}Panel variable: {res}%s{txt}{col 49}Number of eqn      = {res}%9.0f\n", ivar, neq)
	printf("{txt}Time variable : {res}%s{txt}{col 49}Number of panels   = {res}%9.0f\n", tvar, Obs)
	printf("\n")

} // end of void _xtsurub() function
end
 
// ----------------- OTHER SUB-PROGRAMS NEEDED IN THIS PROGRAM -----------------
cap program drop parseEqn
program define parseEqn        
	version 9.2
	/* see if we have an equation name */
	gettoken token uu : 0, parse(" =:")   /* rare, pull twice if found */
	gettoken token2 : uu, parse(" =:")     /* rare, pull twice if found */
	if index("`token2'", ":") != 0 {
		gettoken token  0 : 0, parse(" =:")      /* sic, to set 0 */
		gettoken token2 0 : 0, parse(" =:")      /* sic, to set 0 */
		c_local eqname  `token'
	} 
	else    c_local eqname 

	/* search just for "=" */
	gettoken token 0 : 0, parse(" =")
	while "`token'" != "=" & "`token'" != "" {
		local depvars `depvars' `token'
		gettoken token 0 : 0, parse(" =")
	}

	if "`token'" == "=" {
		tsunab depvars : `depvars'
		syntax [varlist(ts)] [ , noConstant ]
	} 
	else {				/* assume single depvar */
		local 0 `depvars'
		syntax varlist(ts) [ , noConstant ]
		gettoken depvars varlist : varlist
	}

	c_local depvars `depvars'
	c_local indvars `varlist'
	c_local constan `constan'
end

cap program drop IsStop
program define IsStop, sclass
	version 9.2
	if 	     `"`0'"' == "[" /*
		*/ | `"`0'"' == "," /*
		*/ | `"`0'"' == "if" /*
		*/ | `"`0'"' == "in" /*
		*/ | `"`0'"' == "" {
		sret local stop 1
	}
	else	sret local stop 0
end

/*  Returns tokens found in both lists in the macro named by matches.
 *  Duplicates must be duplicated in both lists to be considered
 *  matches a 2nd, 3rd, ... time.  */

cap program drop Matches
program define Matches   
	version 9.2
	args	    matches     /*  macro name to hold cleaned list
		*/  colon	/*  ":"
		*/  list1	/*  a list of tokens
		*/  list2	/*  a second list of tokens */

	tokenize `list1'
	local i 1
	while "``i''" != "" {
		local list2 : subinstr local list2 "``i''" "", /*
			*/ word count(local count)
		if `count' > 0 {
			local matlist `matlist' ``i''
		}
		local i = `i' + 1
	}

	c_local `matches' `matlist'
end

/*  determine equation name */

cap program drop nameEq
program define nameEq, sclass
	version 9.2
	args	    eqname	/* user specified equation name
		*/  depvar	/* dependent variable name
		*/  eqlist	/* list of current equation names 
		*/  neq		/* equation number */
	
	if "`eqname'" != "" {
		if index("`eqname'", ".") {
di in red "may not use periods (.) in equation names: `eqname'"
		}
		local eqlist : subinstr local eqlist "`eqname'" "`eqname'", /*
			*/ word count(local count)    /* overkill, but fast */
		if `count' > 0 {
di in red "may not specify duplicate equation names: `eqname'"
			exit 198
		}
		sreturn local eqname `eqname'
		exit
	}
	
	local depvar : subinstr local depvar "." "_", all

	if length("`depvar'") > 32 {
		local depvar "eq`neq'"
	}
	Matches dupnam : "`eqlist'" "`depvar'"
	if "`dupnam'" != "" {
		sreturn local eqname = substr("`neq'`depvar'", 1, 32)
	}
	else {
		sreturn local eqname `depvar'
	}
end

/* Program xtsrtucture to find information on p and Np for unbalanced panel */
cap program drop xtstructure
prog def xtstructure, rclass sortpreserve
	version 9
	syntax varlist(max =1) [if] [in]	
   	tempname pd Np pdNp IDdrop
	marksample touse1
	quietly {
		gen `IDdrop' = `varlist'
		replace `IDdrop' = . if `touse1'==0
		bysort `IDdrop': gen `pd' =_N if `touse1'
		bysort `pd': gen `Np' =_N if _n==_N & `touse1'
		gsort `pd'
		preserve
		keep if `Np'<. & `touse1'
		mkmat `pd' `Np', mat(`pdNp')
		/* Matrix pdNp is the matrix of p periods and the number of individuals/firms 
		that observed in p periods, with p=1 comes first */
	}
	return matrix xtstr = `pdNp'
end


/*  Display a list of variables breaking line nicely */
/*  With new quotes `"..."' no longer need prefix, but kept */
cap program drop DispVars
program define DispVars  
        args         prefix     /* prefix string for first line 
                */   varlist    /* variable list 
                */   strtcol    /* starting column for all lines but first 
                */   maxlen     /* final column for writing 
                */   color      /* color for writing */

        di in `color' `"`prefix'"' _c
        local curlen = length(`"`prefix'"')

        tokenize `varlist'
        local i = 1
        while "``i''" != "" {
                local len = length("``i''")
                if (`curlen' + `len' + 1) > `maxlen' { 
                        di ""
                        di _col(`strtcol') _c
                        local curlen `strtcol'
                }
                di in `color' "``i'' " _c
                local curlen = `curlen' + `len' + 1
                local i = `i' + 1
        }
        disp ""
end
