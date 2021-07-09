// github repository: https://github.com/jepusto/clubSandwich-Stata
//
*! version 0.0 updated 02-March-2017
// Updated by Marcelo Tyszler (tyszler.jobs@gmail.com):
//
// Wrapper function for reg_sandwich:
//
// allow for factor variables via xi:.
// have an option to absorb fixed effects, as in the areg command.
// work with pweights and aweights.
// disregard absorbed fixed effects when calculating the adjustment matrices, degrees of freedom, etc.
// save the abjustment matrices and any other required information for calculating F-tests based on the fitted model.
//
// Suggested syntax is as follows:
// reg_sandwich depvar [indepvars] [if] [in] [weight], cluster(varname) [absorb(varname)]
// 
// If the absorb option is present, then the model should be fit as in areg. 
// If the option is absent, then the model should be fit as in reg. 
// If weights are included, the model should be fit via WLS. 

capture program drop reg_sandwich
program define reg_sandwich, eclass sortpreserve
	
	version 14.2 
	syntax varlist(min=1 numeric) [if] [in] ///
	[aweight pweight],  ///
    cluster(varlist max=1 ) ///
	[absorb(varlist max=1 numeric)] ///
	[noCONstant] ///
	[Level(cilevel)]
	
	
	*mark sample
    marksample touse
	
	*create macros of variables
    tokenize `varlist'
    local t `1'
    macro shift
    local x `*'
	
	* Count valid observations and check matsize
	qui count if `touse'
    local nobs = r(N)
	
   *specify the temporary variables used in the program
    tempvar cons wfinal    ///
     prime_resid  clusternumber  ///
	theta ///
	selectvar
	
	* create placeholder for mata selection
	qui: gen `selectvar'=.
	   
    *specifiy the temporary scalars and matrixes
    tempname ///
		V b ///
		_dfs  ///
		cluster_list p ///
		b_temp
		


	*generate constant term
	if "`constant'"=="" {
		quietly : gen double `cons' = 1 if `touse'
	}

	
	** determine main function
	capture confirm existence `absorb'
	if _rc == 6{
		* no absorb, use default reg
		local main_function = "reg"
		local absorb_call = ""
		local absorb_call_display = ""
	} 
	else {
		* absorb, use areg
		local main_function = "areg"
		local absorb_call = "absorb(`absorb')"
		local absorb_call_display = ", with absorb option"
		if "`constant'"!="" {
			di as error "absorb and noconstant cannot be used simultaneously"
			exit 198
		}
	} 
	    
	** determine weights
	capture confirm existence `weight'
	if _rc == 6{
		* no weights
		local weight_call = ""
		local main_call_display = "OLS"
	} 
	else {
		* weights
		local weight_call = "[`weight'`exp']"
		local main_call_display = "WLS (`weight's)"
	}
	
	*collinearity 
    local olist "`x'"
	if "`constant'"=="" {
		_rmcoll `x' if `touse'
	}
	else {
		_rmcoll `x' if `touse', noconstant
	}

    local x = r(varlist)
    foreach v in `olist' {
        local x = regexr("`x' ","o\.`v' ","")
    }

    if "`x'" == "." local x ""
	
	
	** for absorb:
	if "`main_function'" == "areg" {
		* predict:
		local new_x = ""
		foreach xr of varlist `x' {
			tempvar _RS`xr'
			local new_x = trim("`new_x'") + " " + "`_RS`xr''"
			noisily capture: reg `xr' i.`absorb' `weight_call' if `touse'
			qui: predict `_RS`xr'' if `touse' , residuals 
		}
	}
	** call main regression:
	noisily capture: `main_function' `t' `x'  `weight_call' if `touse', `constant' cluster(`cluster') `absorb_call'
	
	if "`main_function'" == "areg" {
		local old_x = "`x'"
		local x = "`new_x'"
	}
	
	
	** prep for small sample reduced t-test:	
	matrix `p' = rowsof(e(V))
	local p = `p'[1,1]

	if "`main_function'" == "areg" {
		*ignore constant
		local --p
	}
	
	*capture ids
	capture confirm numeric variable `cluster'
	if _rc==0 {
		* numeric
	   quietly : gen double `clusternumber' = `cluster' if `touse'
	}
	else {
		* string
		quietly: encode `cluster' if `touse', gen(`clusternumber') 
	}
    
    quietly sort `clusternumber' `_sortindex'
    quietly : levelsof `clusternumber', local(idlist)
	
	*count ids, create macro m, number of studies
    local m = 0
    foreach j in `idlist' {
        local ++m
    }
	
	
	*weights & variance:
	capture confirm existence `weight'
	if _rc == 6{
		* no weights = OLS
		quietly : gen double `wfinal' = 1 if `touse'
		* Working variance is I
		qui: gen double `theta' = 1 if `touse'
		local type_VCR = "OLS"
	} 
	else {
		* weights = WLS
		local model_weights = substr("`exp'",2,.)
		quietly : gen double `wfinal' = `model_weights' if `touse' 
		
		if "`weight'"=="aweight"{				
			qui: gen double `theta' = 1/`model_weights'  if `touse'
			local type_VCR = "WLSa"
		}
		else{
		* p-weights
		* Working variance is I
			qui: gen double `theta' = 1 if `touse'
			local type_VCR = "WLSp"
		}
		
	
	}
	
	* beta
	*******
	matrix `b_temp' = e(b)
	matrix `b' = `b_temp'[1, 1..`p']

	* Auxiliary matrices
	*********************
	mata: X = .
	if "`constant'"=="" & "`main_function'" != "areg" {
		mata: st_view(X, ., "`x' `cons'","`touse'")
	}
	else{
		mata: st_view(X, ., "`x'","`touse'")
	}
	
	if "`type_VCR'" =="OLS"{
		mata: M = invsym(X' * X)
		mata: MXWTWXM = M
	} 
	else {
		mata: W = diag(st_data(.,"`wfinal'","`touse'"))
		mata: M = invsym(X' * W * X)
	}
				
		
	if "`type_VCR'" == "WLSp" {	
		mata: MXWTWXM = M*X'*W*W*X*M
	}
	else if "`type_VCR'" == "WLSa" {
		mata: MXWTWXM  =  M
	}
	
	if "`type_VCR'" ~="OLS"{
		mata: mata drop W
	}
	
	mata: mata drop X
	
	/********************************************************************/
    /*    Variance covariance matrix estimation for standard errors     */
	/* 																    */
	/*    And F-test												    */
    /********************************************************************/
	qui: predict `prime_resid', residuals
	
	mata: XWAeeAWX = J(`p', `p', 0)
		
	local current_jcountFtest = 0
	local first_cluster = 1
	
	mata: Xj = .
	mata: ej = .
    foreach j in `idlist' {

		qui: replace `selectvar' = `touse' & `clusternumber' == `j'
		
		if "`constant'"=="" & "`main_function'" != "areg" {
			mata: st_view(Xj, ., "`x' `cons'","`selectvar'")
		} 
		else {
			mata: st_view(Xj, ., "`x' ","`selectvar'")
		}
		
		mata: Tj = diag(st_data(.,"`theta'","`selectvar'"))
		
		****Adjustment matrix
		* 
		* we use that Bj = 
		* Dj*[(I-X*M*X'*W)j*T*(I-X*M*X'*W)j']Dj = 
		*
		* Dj*[Tj - Tj*(Wj*Xj*M*Xj') - (Xj*M*Xj'*Wj)*Tj + Xj*(M*X'*W*V*W*X*M)*Xj']*Dj
		*
		* For OLS this simplifies to (Dj = I):
		* Tj - Xj*M*Xj'
		*
		* For WLSp, this simplifies to (Dj = I):
		* Tj - Wj*Xj*M*Xj' - Xj*M*Xj'Wj + Xj'MXWWXM*Xj'
		*
		* For WLSa, this simplified to (Wj*Tj = Ij):
		* Dj*[Tj-Xj*M*Xj]*Dj
				
		if "`type_VCR'" == "OLS" {		
			mata: Bj = Tj-Xj*M*Xj'
		}
		else if "`type_VCR'" == "WLSp" {
			mata: Wj = diag(st_data(.,"`wfinal'","`selectvar'"))
			
			mata: Bj =  Tj-Wj*Xj*M*Xj'-Xj*M*Xj'*Wj + Xj*MXWTWXM*Xj'
		}
		else if "`type_VCR'" == "WLSa" {
			mata: Wj = diag(st_data(.,"`wfinal'","`selectvar'"))
			mata: Dj = cholesky(Tj)
			mata: Bj =  Dj'*(Tj-Xj*M*Xj')*Dj
		}
		
		* Symmetric square root of the Moore-Penrose inverse of Bj
		mata: evecs = .
		mata: evals = .
		mata: symeigensystem(Bj, evecs, evals)
		mata: sq_inv_Bj =  evecs*diag(editmissing(evals:^(-1/2),0))*evecs'
											
		if "`type_VCR'" == "WLSa" {
			mata: Aj =  Dj*(sq_inv_Bj)*Dj'
		}
		else {
			mata: Aj = sq_inv_Bj
		}
		mata: mata drop sq_inv_Bj
		
		mata: st_view(ej, ., "`prime_resid' ","`selectvar'")
		
		if "`type_VCR'" == "OLS" {
			mata: XWAeeAWX = Xj' * Aj * ej * ej' * Aj * Xj + XWAeeAWX
		}
		else {
			mata: XWAeeAWX = Xj' * Wj * Aj * ej * ej' * Aj * Wj * Xj + XWAeeAWX
		}
		
		**** F-test:
		* 
		* To compute the degress of freedom we need P:
		* Psi = (I-Hx)i'*Ai*Wi*Xi*M*C*gs
		*
		* These matrices are needed to compute the terms Psi'*Theta*Ptj:
		*  gs'*C'*M*Xi'*Wi*Ai*(I-Hx)i*Theta*(I-Hx)j'*Aj*Wj*Xj*M*C*gt
		*
		*
		* We save just the "middle" portion, which is independent of C and gs:
		* 
		* We use the fact that Hx = X*M*X'W and
		* (I-X*M*X'*W)i*T*(I-X*M*X'*W)j' = 
		*
		* if i==j
		* Tj - Tj*(Wj*Xj*M*Xj') - (Xj*M*Xj'*W)*Tj + Xj*(M*X'*W*V*W*X*M)*Xj' 
		*
		* For OLS this simplifies to:
		* Tj - Xj*M*Xj'
		*
		* For WLSp, this simplifies to (Dj = I):
		* Tj - Wj*Xj*M*Xj' - Xj*M*Xj'Wj + Xj'MXWWXM*Xj'
		*
		* For WLSa, this simplified to:
		* Tj - Xj*M*Xj
		* 
		*
		* and we call M*Xi'*Wi*Ai*(I-Hx)i*Theta*(I-Hx)j'*Aj*Wj*Xj*M:
		* Pi_Theta_Pi_relevant
		*
		*
		* if i!=j
		* - Ti*Wi*Xi*M*Xj'   - Xi*M*Xj'*Wj*Tj     + Xi*(M*X'*W*T*W*X*M)*Xj'
		*
		* For OLS this simplifies to:
		* - Xi*M*Xj'
		*
		* For WLSp, this simplifies to:
		* - Wi*Xi*M*Xj'   - Xi*M*Xj'*Wj     + Xi*(M*X'*W*W*X*M)*Xj'
		*
		* For WLSa, this simplified to:
		* - Xi*M*Xj' 
		*  
		* For OLS and WLSa we call M*Xi'*Wi*Ai*Xi:
		* Pi_relevant (and ignore the (min) sign, since it will be cancelled out after multiplication)
		*
		* For WLSp we call  M*Xi'*Wi*Ai
		* Pi_Pj_relevant, (this is more efficient to save)
		* 
		* and additionally save M*Xi'*Wi*Ai as PPi
		
		local current_jcountFtest = `current_jcountFtest'+1
        
		
		
		if "`type_VCR'" == "OLS" {
			mata: Pj_Theta_Pj_relevant =  M*Xj'*Aj*Bj*Aj'*Xj*M'
			// p x p
														
			mata: Pj_relevant =   M*Xj'*Aj*Xj
			// p x p
		}
		else if "`type_VCR'" == "WLSp" {	

			mata: Pj_Theta_Pj_relevant =  M* Xj'* Wj* Aj* Bj'* Aj'* Wj* Xj*M' 
			// pxp
													
			mata: Pj_relevant =    M*Xj'*Wj*Aj
			mata: P`current_jcountFtest'_relevant = Pj_relevant
			
			
			mata: PPj = Wj*Xj*M
			// kj x p
			mata: PP`current_jcountFtest' = PPj
		}
		else if "`type_VCR'" == "WLSa" {
			mata: Pj_Theta_Pj_relevant = M*Xj'*Wj* Aj* (Tj-Xj*M*Xj')* Aj'* Wj* Xj*M' 
			//p x p
													
			mata: Pj_relevant =   M*Xj'*Wj*Aj*Xj
			// p x p
		}
	
	
		
		* save for later
		if `first_cluster'==1 {
			mata: Big_PThetaP_relevant = Pj_Theta_Pj_relevant
			mata: Big_P_relevant = Pj_relevant'
			if "`type_VCR'" == "WLSp" {
				mata: Big_PP = PPj
			}
			local first_cluster = 0
		}
		else {	
			mata: Big_PThetaP_relevant = (Big_PThetaP_relevant \ Pj_Theta_Pj_relevant)
			mata: Big_P_relevant = (Big_P_relevant \ Pj_relevant')
			
			if "`type_VCR'" == "WLSp" {
				mata:  Big_PP = (Big_PP \ PPj)
			
			}
		}
		
    }
	
	
	mata: mata drop Xj
	mata: mata drop ej
	mata: mata drop Bj
	mata: mata drop Tj
	mata: mata drop evals
	mata: mata drop evecs
	mata: mata drop Aj
	mata: mata drop Pj_Theta_Pj_relevant
	mata: mata drop Pj_relevant
	if "`type_VCR'" ~="OLS"{
		mata: mata drop Wj
	}
	
	if "`type_VCR'" == "WLSa" {
		mata: mata drop Dj
	}
	if "`type_VCR'" == "WLSp" {
		mata: mata drop PPj
	}
	
	* RVE estimator
	mata: st_matrix ("`V'" , M * XWAeeAWX * M)
	mata: mata drop XWAeeAWX
	
	
	* Tests:
	if "`type_VCR'" == "WLSp" {
		
			qui: tab `clusternumber' if `touse', matrow(`cluster_list')
			forvalues i = 1/`m'{
		
				qui: replace `selectvar' = `touse' & `clusternumber' == `cluster_list'[`i',1]
				mata: X`i' = .
				
				if "`constant'"=="" & "`main_function'" != "areg" {
					mata: st_view(X`i', ., "`x' `cons'","`selectvar'")
				} 
				else {
					mata: st_view(X`i', ., "`x'","`selectvar'")
				}
			}
	}
	
	
	* T-test, using as a special case of an F-test:
	mata: st_matrix("`_dfs'", reg_sandwich_ttests("`type_VCR'", `m', `p', Big_PThetaP_relevant,  Big_P_relevant, M,  MXWTWXM))
	mata: mata drop M
	* Clean
	if "`type_VCR'" == "WLSp" {
	
			forvalues i = 1/`m'{
		
				mata: mata drop X`i'
				mata: mata drop PP`i'
				mata: mata drop P`i'_relevant
				
			}
	}

	
	forvalues coefficient = 1/`p' {
		matrix `_dfs'[1,`coefficient'] = 2/`_dfs'[1,`coefficient']
	}
	
     
    /*********************/
    /*  Display results  */
    /*********************/
	
	display _newline
    display as text "Robust Small Sample Corrected standard error estimation using " as result "`main_call_display'`absorb_call_display'"

	if "`main_function'" == "areg" {
		if "`type_VCR'" == "WLSp" {
			mata: Ur = st_data(., "`x'","`touse'")
		}
		local x = "`old_x'"
			
	}
	
	*name the rows and columns of the matrixes
	if "`constant'"=="" & "`main_function'" != "areg" {	
		matrix colnames `V' = `x' _cons
		matrix rownames `V' = `x' _cons
		matrix colnames `_dfs' = `x' _cons
	}
	else {
		matrix colnames `V' = `x' 
		matrix rownames `V' = `x' 
		matrix colnames `_dfs' = `x' 
	}
	

	* save main regression results
	local mss = `e(mss)'
	local rss = `e(rss)'
	local rmse = `e(rmse)'
	
	local r2 = `e(r2)'
	local r2_a = `e(r2_a)'
	

    display _col(55) as text "Number of obs" _col(69) "=" _col(69) as result %9.0f `nobs'
    display _col(55) as text "R-squared" _col(69) "=" _col(69) as result %9.4f `r2'
	display _col(55) as text "Adj R-squared" _col(69) "=" _col(69) as result %9.4f `r2_a'
    display _col(55) as text "Root MSE" _col(69) "=" _col(69) as result %9.4f `rmse'
	disp
    display _col(35) as text "(Std. Err. adjusted for `m' clusters in `cluster')"
	
    display as text  "{hline 13}" "{c TT}" "{hline 64}"
	
    display						   _col(14) "{c |}" ///
                                    _col(21) "" ///
                                    _col(29) "Robust" 
	
	display %12s abbrev("`t'",12)   _col(14) "{c |}" ///
                                    _col(21) "Coef." ///
                                    _col(29) "Std. Err." ///
                                    _col(40) "dfs" ///
                                    _col(50) "p-value" ///
                                    _col(60) "[" `level' "%Conf. Interval]"
									
	
    display as text  "{hline 13}" "{c +}" "{hline 64}"                            

	tempname effect variance dof
    local i = 1

    foreach v in `x' {
        scalar `effect' = `b'[1,`i']
        scalar `variance' = `V'[`i',`i']
        scalar `dof' = `_dfs'[1,`i']

        display %12s abbrev("`v'",12)   _col(14) "{c |}" ///
                                        _col(16) "" ///
                                        _col(21) %5.3f `effect' ///
                                        _col(29) %5.2f sqrt(`variance') ///
                                        _col(40) %5.2f `dof' ///
                                        _col(50) %5.4f 2*ttail(`dof',abs(`effect'/sqrt(`variance'))) ///
                                        _col(60) %5.4f `effect' - invttail(`dof',((100-`level')/100)/2)*sqrt(`variance') ///
                                        _col(70) %5.4f `effect' + invttail(`dof',((100-`level')/100)/2)*sqrt(`variance')
        local ++i
    }
	
	if "`constant'"=="" & "`main_function'" != "areg" {
		local v = "_cons"
	    scalar `effect' = `b'[1,`i']
        scalar `variance' = `V'[`i',`i']
        scalar `dof' = `_dfs'[1,`i']

        display %12s abbrev("`v'",12)   _col(14) "{c |}" ///
                                        _col(16) "" ///
                                        _col(21) %5.3f `effect' ///
                                        _col(29) %5.2f sqrt(`variance') ///
                                        _col(40) %5.2f `dof' ///
                                        _col(50) %5.4f 2*ttail(`dof',abs(`effect'/sqrt(`variance'))) ///
                                        _col(60) %5.4f `effect' - invttail(`dof',((100-`level')/100)/2)*sqrt(`variance') ///
                                        _col(70) %5.4f `effect' + invttail(`dof',((100-`level')/100)/2)*sqrt(`variance')
        local ++i
    }

    display as text  "{hline 13}" "{c BT}" "{hline 64}" 
    
    /*********************/
    /*  post results     */
    /*********************/
	ereturn post `b' `V', obs(`nobs') depname(`t') esample(`touse')
	
	ereturn local type_VCR "`type_VCR'"
	ereturn local vce "cluster"
	ereturn local vcetype "Robust"
	ereturn scalar N_clusters = `m'
	
	ereturn scalar r2 = `r2'
	ereturn scalar r2_a = `r2_a'
	
	ereturn scalar rss = `rss'
	ereturn scalar mss = `mss'
	ereturn scalar rmse = `rmse'
	
	ereturn matrix dfs = `_dfs'
	
	ereturn local clustvar = "`cluster'"
	
	if "`type_VCR'" ~= "OLS" {
		ereturn local wtype = "`weight'"
		ereturn local wexp = "`exp'"
	}
	
	
	
	if "`main_function'" == "areg" {
			ereturn local absvar = "`absorb'"
	}
    
	ereturn local indepvars `x'
	
	if "`constant'"=="" & "`main_function'" != "areg" {
		ereturn local constant_used = 1
	}
	else {
		ereturn local constant_used = 0
	}
	
	ereturn local cmdline "reg_sandwich `0'"
	ereturn local cmd "reg_sandwich"

end
	
