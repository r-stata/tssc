*! genqreg 1.0.0 14Nov2014
*! version 1.0.0
*! authors: David Powell, Travis Smith, Matthew Baker
*! MJB edited this file on 30Jul2015 to include perfect predictors
*!    for the proneness model.
*! version 1.0.1 February232016
*! TAS added some stuff for covariance matrices
*! MJB added in a scale term to scale the GMM objective for more control over MCMC
 
program genqreg
	version 11.2
	if replay() {
		if (`"`e(cmd)'"' != "genqreg") error 301
		Replay `0'
	}
	else Estimate `0'
end
program Estimate, eclass

	syntax varlist [fw aw/] [if] [in] , 	///
		[OPTIMIZE(string)					///
			DRAWs(int 1000)					///
			BURN(int 0)						///
			ARATE(real .234)                ///
			SAMPLER(string)					///
			DAMPPARM(real 1)				///
			FROM(string)					///
			FROMVariance(string)			///
			SAVING(string)					///
			REPLACE							///
			APPEND							///
			THIN(int 1)						///
			JUMBLE							///
			NOISY							///
			grid1(numlist)					///
			grid2(numlist)					///
			NMSIMplex(string)				///
			USEMAX							///
			SCALE(real 1)                   ///
		TECHnique(string) 					///
		PRONEness(varlist)    				///
		INSTRuments(varlist)         		///
		Quantile(real 0.5)]

	marksample touse
	gettoken lhs rhs : varlist
	markout `touse' `lhs' `rhs'

	if `quantile' >= 1 {
			local tau = `quantile'/100
		}
		else	local tau "`quantile'"
		if `tau' <= 0 | `tau' >= 1 {
			di in red "quantiles(`quantile') out of range"
			exit 198
		}
	
	// technique 
	if "`technique'"=="logit" {
		local technique "logit"
		mata: f=&LogitObjective()
	}
	else if "`technique'"=="probit" {
		local technique "probit"
		mata: f=&ProbitObjective()
	}
	else {
		local technique "linear"
		mata: f=&pi()
	}
	// The last bit of code just passes an arbitrary function, because none is needed
	
	// col of ones
	tempvar ones
	qui gen `ones'=1 if `touse'
	
	// get weights, else use wt=1
	tempvar weightvar
	if `"`exp'"' != "" {
		qui gen double `weightvar' = `exp' if `touse'
	}
	else	{
		qui gen `weightvar' = `ones' if `touse'
	}
	
	// If proneness is blank then standard QR where x=1
	if ("`proneness'"!="") {
		mata: xi=st_data(.,"`proneness'","`touse'")
	}
	else {
		mata: xi=st_data(.,"`ones'","`touse'")
	}

	// Errors in choosing options
	if ("`optimize'" !="mcmc" & "`optimize'" !="grid") {
		local optimize "NM"
	}
	if ("`optimize'" !="mcmc") {
		if (`burn'!=0 | `draws'!=1000 | `arate'!=.234 | `dampparm'!=1 ///
		  | `thin'!=1 | "`sampler'"!=""  ///
		  | "`saving'"!="" | "`replace'"=="replace" | "`append'"=="append" ///
		  | "`jumble'"=="jumble" | "`noisy'"=="noisy") {
			disp as err "An mcmc option has been set but estimation method is not mcmc. Option is superfluous." 
			disp as err "Please consult the help file for information on how to use mcmc options."
			disp as txt " "
		}
	}
	if ("`optimize'" !="grid") {
		if ("`grid1'"!="" | "`grid2'"!="") {
			disp as err "A grid search option has been set but estimation method is not grid search. Option is superfluous." 
			disp as err "Please consult the help file for information on how to use grid search options."
			disp as txt " "
		}
	}
	
	// Checking instruments and rank condition
	if ("`instruments'" == "") {
		local instruments  "`rhs'"
	}
	
	if wordcount("`instruments'") < wordcount("`rhs'") {
		di as error "Error: # of instruments must be >= # of right-hand side variables."
		exit
	}

	tempname excluded_inst exog_vars endog_vars
	local excluded_inst : list instruments - rhs
	local exog_vars : list instruments - excluded_inst
	local endog_vars : list rhs - instruments
	
	// for variance calculation of QR and IVQR when proneness==""
	mata: st_view(excluded_inst=.,.,"`excluded_inst'","`touse'")
	mata: st_view(exog_vars=.,.,"`exog_vars'","`touse'")
	mata: st_view(endog_vars=.,.,"`endog_vars'","`touse'")
	
	/* Set starting values */
	if ("`from'" == "" &  "`fromvariance'"=="") {
		qui qreg `lhs' `rhs' if `touse' [aw= `weightvar'], q(`tau')
		mata: beta_start=st_matrix("e(b)")
		mata: beta_start=beta_start[1..cols(beta_start)-1]
		mata: beta_start_var=st_matrix("e(V)")
		mata: beta_start_var=beta_start_var[1..(cols(beta_start)),1..(cols(beta_start))]
		mata: beta_start_se=sqrt(diagonal(beta_start_var))'
	}
	else if ("`from'" == "" & "`fromvariance'"!="" ) {
		mata: beta_start_var=st_matrix("`fromvariance'")
		mata: beta_start_se=sqrt(diagonal(beta_start_var))'
		qui qreg `lhs' `rhs' if `touse' [aw= `weightvar'], q(`tau')
		mata: beta_start=st_matrix("e(b)")
		mata: beta_start=beta_start[1..cols(beta_start)-1]
	}
	else if ("`from'" != "" & "`fromvariance'"=="" ) {
		mata: beta_start=st_matrix("`from'")
		qui qreg `lhs' `rhs' if `touse' [aw= `weightvar'], q(`tau')
		mata: beta_start_var=st_matrix("e(V)")
		mata: beta_start_var=beta_start_var[1..(cols(beta_start)),1..(cols(beta_start))]
		mata: beta_start_se=sqrt(diagonal(beta_start_var))'
	}
	else {
		mata: beta_start=st_matrix("`from'")
		mata: beta_start_var=st_matrix("`fromvariance'")
		mata: beta_start_se=sqrt(diagonal(beta_start_var))'
	}
	

	/* Read in the options and desired quantile */
	mata: technique   =st_local("technique")
	mata: tau     =strtoreal(st_local("tau"))
	mata: scale   =strtoreal(st_local("scale"))             /* Added in so the MCMC estimates won't be so nuts if user so desires! */
	
	mata: info=st_data(.,"`ones'","`touse'")
	mata: fix=st_data(.,"`ones'","`touse'")
	mata: st_view(di=.,.,"`rhs'","`touse'")
	mata: st_view(zi=.,.,"`instruments'","`touse'")
	mata: st_view(yi=.,.,"`lhs'","`touse'")
	mata: st_view(wt=.,.,"`weightvar'","`touse'")
	
	//normalize weights to sum to N
	mata: wt = wt:/colsum(wt)*rows(info)

	mata: A=weightMatrix(beta_start,tau,yi,di,xi,technique,f,info,fix,zi,wt,"efficient")

	
	mata: M=moptimize_init()
	mata: moptimize_init_evaluator(M,&objectiveFunGmm())
	mata: moptimize_init_touse(M,"`touse'")	
	mata: moptimize_init_evaluatortype(M,"d0")
	mata: moptimize_init_technique(M,"nm")
	if "`nmsimplex'"=="" {
		mata: moptimize_init_nmsimplexdeltas(M,J(1,1,10))
	}
	else {
		mata: simplex=st_matrix("`nmsimplex'")
		mata: moptimize_init_nmsimplexdeltas(M,simplex)
	}
	mata: moptimize_init_depvar(M,1,yi)
	mata: moptimize_init_eq_indepvars(M,1,di)
	mata: moptimize_init_eq_cons(M,1, "off")
	mata: moptimize_init_eq_coefs(M,1, beta_start)

	mata: G=grqInfoInit(yi,xi,di,A,technique,info,fix,zi,wt,tau,f,scale)
	mata: moptimize_init_userinfo(M,1,G)
	
/* MCMC optimization */
	if "`optimize'"=="mcmc" {
		di "Adaptive MCMC optimization"
		
		mata: junk=moptimize_evaluate(M)
		
		if (`burn'>=`draws') {
			di as error "Error: The # of burn in draws must be less than # draws"
			exit
		}	
				   
		if "`sampler'"!="mwg" {
			local sampler "global"
		}
		
		mata: noisy   =st_local("noisy")
		mata: sampler =st_local("sampler")	
		mata: arate   =strtoreal(st_local("arate"))
		mata: alginfo ="standalone",st_local("sampler")
		mata: draws   =strtoreal(st_local("draws"))
		mata: dampparm=strtoreal(st_local("dampparm"))
		mata: burn    =strtoreal(st_local("burn"))
		mata: thin    =strtoreal(st_local("thin"))
		mata: jumble  =st_local("jumble")
		
		/* set up and execute the amcmc run */
		mata: alginfo=sampler,"gf0","moptimize"
		mata: Draws = amcmc(alginfo,&objectiveFunGmm(),beta_start, beta_start_var,draws,burn,dampparm,arate,ar=.,vals=.,lam=.,.,M,noisy)
		
		/* process all of the information that does not need further */
		/* manipulation */
		
		tempname arates arates_mean arates_min arates_max
		mata: st_matrix("`arates'",ar)
		mata: st_numscalar("`arates_mean'",mean(ar'))
		mata: st_numscalar("`arates_min'",min(ar))
		mata: st_numscalar("`arates_max'",max(ar))
		
		/* A function to process draws after they are done */
		mata: gqreg_process_draws(Draws,vals,jumble,thin,0,betaf=.,valsf=.)
		
		tempname dof
		mata: st_numscalar("`dof'",rows(betaf))
		local dof=`dof'
		
		tempname b V gamma valMean valMax valMin drawsKept
		
		* find betas corresponding to max objfunval
		if "`usemax'"!="" {
			mata: b=findRowMax(valsf,betaf)[1,.]
			mata: GAMMA=mm_quantile(yi:-di*b',wt,tau); GAMMA=GAMMA'
			
			//
			// Covariance
			//
			
			// GQR covariance
			if ("`proneness'"!="") {
				mata: deriv= beta_start_se
				mata: V=gqr_var(yi,di,xi,b,tau,zi,wt,deriv,technique,f,fix,info)
				
				// Output without constant
				tempname b V 
			
				mata: st_matrix("`b'",b)
				mata: st_matrix("`V'",V)	
					
				mat colnames `b' = `rhs' 
				mat colnames `V' = `rhs'  
				mat rownames `V' = `rhs'  
			}
			// QR and IVQR covariance
			else {
				//  QR covariance
				if ("`excluded_inst'"=="") {
					mata: b=b, GAMMA
					mata: V=kcov_qr(b,tau,yi,di,wt)
				}	
			
				// IVQR Just-id covariance
				else if wordcount("`excluded_inst'") == wordcount("`endog_vars'") {
					mata: b=b, GAMMA
					mata: V=kcov_iqr(b,tau,yi,endog_vars,exog_vars,excluded_inst,wt)
				}
				// Over-id covariance
				else {
					mata: b=b, GAMMA
					mata: V=kcov_iqr_oid(b,tau,yi,endog_vars,exog_vars,excluded_inst,wt)
				}
			
				// Output with constant	
				tempname b V 
			
				mata: st_matrix("`b'",b)
				mata: st_matrix("`V'",V)	
			
				mat colnames `b' = `rhs' _cons
				mat colnames `V' = `rhs' _cons 
				mat rownames `V' = `rhs' _cons 
			}
		
		
		}
		*...or use mean of draws
		else {
			// Get the constant for each MCMC draw
			mata: GAMMA=mm_quantile(yi:-di*betaf',wt,tau); GAMMA=GAMMA'
			mata: b=mean((betaf, GAMMA))
			mata: V=variance((betaf, GAMMA))
			
			// Output with constant	
			tempname b V 
		
			mata: st_matrix("`b'",b)
			mata: st_matrix("`V'",V)	
		
			mat colnames `b' = `rhs' _cons
			mat colnames `V' = `rhs' _cons 
			mat rownames `V' = `rhs' _cons 
		}
			
		mata: st_numscalar("`valMean'",mean(valsf))
		mata: st_numscalar("`valMax'",max(valsf))
		mata: st_numscalar("`valMin'",min(valsf))
		mata: st_numscalar("`drawsKept'",rows(valsf))
		
			
		tempname beta_start beta_start_var
		mata: st_matrix("`beta_start'",beta_start)
		mata: st_matrix("`beta_start_var'",beta_start_var)
		
		tempname nobs
		quietly tab `touse' if `touse'
		local nobs=`r(N)'
	
		ereturn clear
		ereturn post `b' `V', esample(`touse') obs(`nobs') dof(`dof')
		
		ereturn local title "mcmc-estimated Generalized Quantile Regression"
		ereturn local cmd "genqreg"
		ereturn local indepvars `rhs'
		ereturn local depvar `lhs'
		ereturn local technique `technique'
		ereturn matrix b_init=`beta_start'
		ereturn matrix V_init=`beta_start_var'
	
	
	
	/* Return if MCMC */	
		ereturn local sampler `sampler'
		ereturn local saving `saving'
		ereturn local jumble `jumble'
		
		ereturn scalar draws=`draws'
		ereturn scalar burn=`burn'
		ereturn scalar thin=`thin'
		ereturn scalar damper=`dampparm'
	
		ereturn scalar opt_arate=`arate'
		ereturn scalar arates_mean=`arates_mean'
		ereturn scalar f_mean=`valMean'
		ereturn scalar f_max =`valMax'
		ereturn scalar f_min =`valMin'
		ereturn scalar scale = `scale'
	
		ereturn scalar draws_retained = `drawsKept'
		ereturn matrix arates=`arates'
	
			if "`saving'"!="" {
			preserve
			clear
	
			local exnames "`rhs'"
			getmata (`exnames')=betaf
			getmata (fun_val)=valsf

			gen t=_n
			if "`append'"=="append" {
				append using "`saving'"
	
			}
			else {
				qui save "`saving'", `replace'
			}
			restore
		}		
		
		di _newline
		di as txt "`e(title)'" 
		di as txt "     Observations:         " as res %10.0f `e(N)'
		di as txt "     Mean acceptance rate: " as res %10.3f `e(arates_mean)'
		di as txt "     Total draws:          " as res %10.0f `e(draws)'
		di as txt "     Burn-in draws:        " as res %10.0f `e(burn)'
		di as txt "     Draws retained:       " as res %10.0f `e(draws_retained)'
		if `e(thin)'!=1		{
		di as txt	_col(10) "*One of every " %1.0f `e(thin)' " draws kept"
					} 
		if "`e(jumble)'"=="jumble" {
		di as txt			   _col(10) "*Draws Jumbled"
					} 
					
		ereturn display
		if ("`excluded_inst'"=="" & "`proneness'"=="") {
			disp as text "No excluded instruments and no proneness variables."
			disp as text "--> Estimation is equivalent to standard quantile regression."
		}
		if ("`excluded_inst'"!="") {
			disp as text "Excluded instruments: " "`excluded_inst'"
		}
		if ("`proneness'"!="") {
			disp as text "Proneness variables: " "`proneness'"
		}
		
		di as txt " Value of objective function:   "
		di as txt "             Mean:         " as res %12.2f `e(f_mean)'
		di as txt "             Min:          " as res %12.2f `e(f_min)'
		di as txt "             Max:          " as res %12.2f `e(f_max)'
		if "`e(saving)'"!="" {
		di as txt "   Draws saved in: " "`e(saving)'"
							}
		di _newline
		di as txt "    *Results are presented to conform with Stata convention, but "
		di as txt "     are summary statistics of draws, not coefficient estimates. " 
		if `scale' != 1 {
			di as txt ""
			di as txt "    *Objective function rescaled by a factor of: " %12.2f `scale'
		}
	}

/* grid search */	
	else if "`optimize'"=="grid" {
		di "Grid-search optimization"
		
		// if rhs > 2 then exit
		if wordcount("`rhs'") > 2 {
			di as error "Error: The # of RHS variables is > 2. Grid search not feasible."
			exit
		}
		
		// if 2 RHS, search over 2x2 grid
		if wordcount("`rhs'") == 2 {
		
			if "`grid1'"!="" {
				// passes the numlist as a vector to mata
				local grid1: subinstr local grid1 " " ", ", all
				mata: grid1=(`grid1')'
			}
			// default grid values: 95% CI in each direction over 81 points
			else {
				mata: min1=beta_start[1,1]-1.96*beta_start_se[1,1]
				mata: max1=beta_start[1,1]+1.96*beta_start_se[1,1]
				mata: intvl1=(min1-max1)/8
				mata: grid1=range(min1,max1,intvl1)
				mata: st_numscalar("min1",min1)
				mata: st_numscalar("max1",max1)
				mata: st_numscalar("intvl1",intvl1)
				local grid1 "`=min1'(`=intvl1')`=max1'"
				numlist "`grid1'"
			}
			
			if "`grid2'"!="" {
				local grid2: subinstr local grid2 " " ", ", all
				mata: grid2=(`grid2')'
			}
			else {
				mata: min2=beta_start[1,2]-1.96*beta_start_se[1,2]
				mata: max2=beta_start[1,2]+1.96*beta_start_se[1,2]
				mata: intvl2=(min2-max2)/8
				mata: grid2=range(min2,max2,intvl2)
				mata: st_numscalar("min2",min2)
				mata: st_numscalar("max2",max2)
				mata: st_numscalar("intvl2",intvl2)
				local grid2 "`=min2'(`=intvl2')`=max2'"
				numlist "`grid2'"
			}
			
			// set up grid
			mata: expand_grid1=J(rows(grid2),1,grid1)
			mata: expand_grid2=vec(J(rows(grid1),1,grid2'))
			mata: grid12=(expand_grid1, expand_grid2)
			mata: st_numscalar("grid_points",rows(grid12))
			di as txt "Number of grid points: " `=grid_points'
			// column for obj func value
			mata: grid12=grid12,J(rows(grid12),1,.)
			mata: grid_index=0
			
			local iter=0
			qui foreach num2 of numlist `grid2' { 
				qui foreach num of numlist `grid1' {
					if "`noisy'"!="" {
						local iter=`iter'+1
						noisily di as txt "." _c
						if mod(`iter',50)==0 {
							noisily di as txt "`iter'" 
						}
					}
					mata: grid_index=grid_index+1					
					mata: b_grid=grid12[grid_index,1..2]
					mata: g=momentEvaluator(grid12[grid_index,1..2],tau,yi,di,xi,technique,f,info,fix,zi,wt)
					mata: g=colsum(g)/sqrt(rows(info))
					mata: grid12[grid_index,3]=-.5*g*A*g'
				}
			}
			// find the maximum 
			// findRowMax(X1,X2) where X1 is a colVec to search for max
			//							X2 is the corresponding matrix of betas
			mata: grid_max=findRowMax(grid12[.,3],grid12)
			// take the first instance of beta if there are ties
			//mata: b=grid_max[1,1..2]
			// midpoint of grid, find unique values first
			mata: b1=(min(uniqrows(grid_max[.,1]))+max(uniqrows(grid_max[.,1])))/2
			mata: b2=(min(uniqrows(grid_max[.,2]))+max(uniqrows(grid_max[.,2])))/2
			mata: b=b1,b2
			mata: fval=grid_max[1,3]
		}	
	
		if wordcount("`rhs'") == 1 {
			if "`grid1'"!="" {
				// passes the numlist as a vector to mata
				local grid1: subinstr local grid1 " " ", ", all
				mata: grid1=(`grid1')'
			}
			// default grid values: 95% CI over 81 points
			else {
				mata: min1=beta_start[1,1]-1.96*beta_start_se[1,1]
				mata: max1=beta_start[1,1]+1.96*beta_start_se[1,1]
				mata: intvl1=(min1-max1)/80
				mata: grid1=range(min1,max1,intvl1)
				mata: st_numscalar("min1",min1)
				mata: st_numscalar("max1",max1)
				mata: st_numscalar("intvl1",intvl1)
				local grid1 "`=min1'(`=intvl1')`=max1'"
				numlist "`grid1'"
			}
			
			mata: st_numscalar("grid_points",rows(grid1))
			di as txt "Number of grid points: " `=grid_points'
			// column for obj func value
			mata: grid1=grid1,J(rows(grid1),1,.)
			mata: grid_index=0
			
			local iter=0
			qui foreach num of numlist `grid1' {
				if "`noisy'"!="" {
					local iter=`iter'+1
					noisily di as txt "." _c
					if mod(`iter',50)==0 {
						noisily di as txt "`iter'" 
					}
				}
				mata: grid_index=grid_index+1
				mata: b_grid=grid1[grid_index,1]
				mata: g=momentEvaluator(grid1[grid_index,1],tau,yi,di,xi,technique,f,info,fix,zi,wt)
				mata: g=colsum(g)/sqrt(rows(info))
				mata: grid1[grid_index,2]=-.5*g*A*g'
			}
			// find the maximum
			mata: grid_max=findRowMax(grid1[.,2],grid1)
			// take the first instance of beta if there are ties
			// mata: b=grid_max[1,1]
			// midpoint
			mata: b=(min(uniqrows(grid_max[.,1]))+max(uniqrows(grid_max[.,1])))/2
			mata: fval=grid_max[1,2]
		}	
		
		tempname grid_betas
		mata: st_matrix("`grid_betas'",grid_max)
		mat colnames `grid_betas' = `rhs' obj_fun_value
		
		// Get the constant 
		mata: GAMMA=mm_quantile(yi:-di*b',wt,tau); GAMMA=GAMMA'
		
		//
		// Covariance
		//

		// GQR covariance
		if ("`proneness'"!="") {
			mata: deriv= beta_start_se
			mata: V=gqr_var(yi,di,xi,b,tau,zi,wt,deriv,technique,f,fix,info)
			
			// Output without constant
			tempname b V 
		
			mata: st_matrix("`b'",b)
			mata: st_matrix("`V'",V)	
				
			mat colnames `b' = `rhs' 
			mat colnames `V' = `rhs'  
			mat rownames `V' = `rhs'  
		}
		// QR and IVQR covariance
		else {
			//  QR covariance
			if ("`excluded_inst'"=="") {
				mata: b=b, GAMMA
				mata: V=kcov_qr(b,tau,yi,di,wt)
			}	
		
			// IVQR Just-id covariance
			else if wordcount("`excluded_inst'") == wordcount("`endog_vars'") {
				mata: b=b, GAMMA
				mata: V=kcov_iqr(b,tau,yi,endog_vars,exog_vars,excluded_inst,wt)
			}
			// Over-id covariance
			else {
				mata: b=b, GAMMA
				mata: V=kcov_iqr_oid(b,tau,yi,endog_vars,exog_vars,excluded_inst,wt)
			}
		
			// Output with constant	
			tempname b V 
		
			mata: st_matrix("`b'",b)
			mata: st_matrix("`V'",V)	
		
			mat colnames `b' = `rhs' _cons
			mat colnames `V' = `rhs' _cons 
			mat rownames `V' = `rhs' _cons 
		}
		
		tempname nobs
		quietly tab `touse' if `touse'
		local nobs=`r(N)'
	
		ereturn clear
		ereturn post `b' `V', esample(`touse') obs(`nobs') 

/*				ereturn post `b' , esample(`touse') obs(`nobs') 	
		disp ""
		disp as err "Grid search: bootstrap to obtain standard errors"	*/	
		
		ereturn local title "Generalized Quantile Regression (GQR)"
		ereturn local cmd "genqreg"
		ereturn local indepvars `rhs'
		ereturn local depvar `lhs'
		ereturn local technique `technique'
		ereturn matrix solutions `grid_betas'

		display as txt " "
		display as txt "`e(title)'"
		display as txt "     Observations:         " as res %10.0f `e(N)'	
		display as txt " "		
	
		ereturn display 
		
		if ("`excluded_inst'"=="" & "`proneness'"=="") {
			disp as text "No excluded instruments and no proneness variables."
			disp as text "--> Estimation is equivalent to standard quantile regression."
		}
		if ("`excluded_inst'"!="") {
			disp as text "Excluded intstruments: " "`excluded_inst'"
		}
		if ("`proneness'"!="") {
			disp as text "Proneness variables: " "`proneness'"
		}
		
		if rowsof(e(solutions)) > 1 {
			di as txt "    Note: Alternative solutions exist. See e(solutions)."
		}	
	} 
	
/* Nelder-Mead */
	else {
		di "Nelder-Mead optimization"
		mata: moptimize(M)	
		mata: b=moptimize_result_coefs(M)
		
		// Get the constant 
		mata: GAMMA=mm_quantile(yi:-di*b',wt,tau); GAMMA=GAMMA'
	
		// standard QR cov-var
		if ("`excluded_inst'"=="" & "`proneness'"=="") {
			mata: b=b, GAMMA
			mata: V=kcov_qr(b,tau,yi,di,wt)
			
			tempname b V 
		
			mata: st_matrix("`b'",b)
			mata: st_matrix("`V'",V)	
			
			mat colnames `b' = `rhs' _cons
			mat colnames `V' = `rhs' _cons 
			mat rownames `V' = `rhs' _cons
		}
		// standard IVQR cov-var
		else if ("`proneness'"=="") {
			if wordcount("`excluded_inst'") == wordcount("`endog_vars'") {
				mata: b=b, GAMMA
				mata: V=kcov_iqr(b,tau,yi,endog_vars,exog_vars,excluded_inst,wt)
				tempname b V 
		
				mata: st_matrix("`b'",b)
				mata: st_matrix("`V'",V)	
				
				mat colnames `b' = `rhs' _cons
				mat colnames `V' = `rhs' _cons 
				mat rownames `V' = `rhs' _cons
			}
			else {
				mata: b=b, GAMMA
				mata: V=kcov_iqr_oid(b,tau,yi,endog_vars,exog_vars,excluded_inst,wt)
				tempname b V 
		
				mata: st_matrix("`b'",b)
				mata: st_matrix("`V'",V)	
				
				mat colnames `b' = `rhs' _cons
				mat colnames `V' = `rhs' _cons 
				mat rownames `V' = `rhs' _cons
			}
		}
		// GQR covariance
		else {
			mata: deriv=beta_start_se 
			mata: V=gqr_var(yi,di,xi,b,tau,zi,wt,deriv,technique,f,fix,info)
			tempname b V 
		
			mata: st_matrix("`b'",b)
			mata: st_matrix("`V'",V)	
			
			mat colnames `b' = `rhs' 
			mat colnames `V' = `rhs'  
			mat rownames `V' = `rhs'
		}
	 
		
		tempname nobs
		quietly tab `touse' if `touse'
		local nobs=`r(N)'
	
		ereturn clear
		ereturn post `b' `V', esample(`touse') obs(`nobs') 
		
		ereturn local title "Generalized Quantile Regression (GQR)"
		ereturn local cmd "genqreg"
		ereturn local indepvars `rhs'
		ereturn local depvar `lhs'
		ereturn local technique `technique'
		
		display as txt " "
		display as txt "`e(title)'"
		display as txt "     Observations:        " as res %10.0f `e(N)'	
		display as txt " "
		ereturn display 
		if ("`excluded_inst'"=="" & "`proneness'"=="") {
			disp as text "No excluded instruments and no proneness variables."
			disp as text "--> Estimation is equivalent to standard quantile regression."
		}
		if ("`excluded_inst'"!="") {
			disp as text "Excluded intstruments: " "`excluded_inst'"
		}
		if ("`proneness'"!="") {
			disp as text "Proneness variables: " "`proneness'"
		}		
		
	}
end

	
program Replay
	syntax 
	ereturn display
end

mata:
struct gqrInfo {
	real matrix yi,xi,di,A,info,fix,zi,wt
	real scalar tau, scale
	string scalar technique
	pointer (real scalar function) scalar fun
} 

struct gqrInfo grqInfoInit(yi,xi,di,A,technique,info,fix,zi,wt,tau,fun,scale)
{
	struct gqrInfo scalar G
	G.yi=yi
	G.xi=xi
	G.di=di
	G.A=A
	G.technique=technique
	G.info=info
	G.fix=fix
	G.zi=zi
	G.wt=wt
	G.tau=tau
	G.fun=fun
	G.scale=scale
	return(G)
}

void objectiveFunGmm(M,todo,b,obj,g,H) 
{
	real scalar tau
	real matrix yi,xi,di,info,fix,zi,wt,A
	string scalar technique
	pointer(real scalar function) scalar fun
	struct gqrInfo scalar G
	
	real matrix gi

	yi=moptimize_util_depvar(M,1)
		
	G=moptimize_util_userinfo(M,1)	

	gi=momentEvaluator(b,G.tau,yi,G.di,G.xi,G.technique,G.fun,G.info,G.fix,G.zi,G.wt)

	gi=colsum(gi)/sqrt(rows(G.info))

	obj =-.5*G.scale*(1/(G.tau-G.tau^2))*gi*G.A*gi'
}

real matrix momentEvaluator(real matrix b,
							real scalar tau,
							real matrix yi,
							real matrix di,
							real matrix xi,
							string scalar technique,
							pointer(real scalar function) scalar f,
							real matrix info,
							real matrix fix,
							real matrix zi,
							real matrix wt)
{
	real colvector gamma, tauXi, yip, gammap, wtp
	real matrix gi, zi1, dip, zip, zim, delHat, below
	real scalar i
	
	// computes gamma for both cross-sectional GQR and QRPD depending on technique
	gamma=estimateGamma(b,yi,di,wt,tau,technique,fix)
	
	// GQR
	if (technique=="logit" | technique=="probit" | technique=="linear") {
		delHat=estimateProneness(yi,gamma,di,b,xi,technique,f,wt,flagMat=.)
		if (technique=="logit") {
			tauXi =exp((xi,J(rows(xi),1,1))*delHat'):/(1:+exp((xi,J(rows(xi),1,1))*delHat'))
		}
		else if (technique=="probit") {
			tauXi =normal((xi,J(rows(xi),1,1))*delHat')
		}
		else {
			tauXi=(xi,J(rows(xi),1,1))*delHat
		}
		zeroPreds=mm_which(rowsum(flagMat:==-1):>0)
		onePreds=mm_which(rowsum(flagMat:==1):>0)
		if (rows(zeroPreds)>0) tauXi[zeroPreds]=J(rows(zeroPreds),1,0)
		if (rows(onePreds)>0) tauXi[onePreds]=J(rows(onePreds),1,1)		/* Check function set at 0,1 with perfect preds */
		gi=wt:*zi:*((yi:<(gamma:+di*b'))-tauXi)	
	}	
	// IV-QR
	else {
		gi=wt:*zi:*((yi:<(gamma:+di*b'))-tau)
	}

	return(gi)	
}

// estimate the constant
real matrix estimateGamma(	real matrix b,
							real matrix yi, 
							real matrix di, 
							real matrix wt, 
							real scalar tau, 
							string scalar technique, 
							real matrix fix)
{
	real matrix Gamma, u, fe_id, u_fe, wt_fe
	real scalar num_fe, gamma_fe, fe
	real matrix dum

	Gamma=mm_quantile(yi-di*b',wt,tau)*J(rows(yi),1,1)
	return(Gamma)	
}

real matrix estimateProneness(	real matrix yi, 
								real matrix gamma, 
								real matrix di,
								real matrix b, 
								real matrix xi,  
								string scalar technique, 
						  		pointer(real scalar function) scalar f,
						  		real matrix wt,
								real matrix flagMat)
{
	transmorphic Model
	real matrix yDum,delHat,xx,xy
	yDum=(yi:<=(gamma+di*b'))
	if (technique=="logit" | technique=="probit") {	
		flagMat=checkSupport(yDum,xi)
		nonPerfPredInd=(rowsum(abs(flagMat)):==0)
		yDum=select(yDum,nonPerfPredInd)
		xiToUse=select(xi,nonPerfPredInd)
		Model=moptimize_init()
		moptimize_init_tracelevel(Model,"none")
		moptimize_init_evaluatortype(Model,"lf")
		moptimize_init_depvar(Model,1,yDum)
		moptimize_init_eq_indepvars(Model,1,xiToUse)
		moptimize_init_evaluator(Model,f)
		moptimize_init_weight(Model, wt)
		moptimize(Model)
		delHat=moptimize_result_coefs(Model)
		return(delHat)
	}
	else {
		xx = cross(xi,1,wt,xi,1)
		xy = cross(xi,1,wt,yDum,0)
		delHat=invsym(xx)*xy
	}
	return(delHat)
}

void ProbitObjective(M, b, f)
{
	real matrix y,bX
	y=moptimize_util_depvar(M,1)
	bX=moptimize_util_xb(M,b,1)
	displayflush()
	f=y:*ln(normal(bX)):+(1:-y):*ln(normal(-bX))
}
void LogitObjective(M,b,f)
{
	real matrix y,bX
	y=moptimize_util_depvar(M,1)
	bX=moptimize_util_xb(M,b,1)
	f=y:*(bX:-ln(1:+exp(bX))):-(1:-y):*ln(1:+exp(bX))
}

real matrix weightMatrix(	real rowvector b,
							real scalar tau,
							real matrix yi,
							real matrix di,
							real matrix xi,
							string scalar technique,
							pointer(real scalar function) scalar f,
							real matrix info,
							real matrix fix,
							real matrix zi,
							real matrix wt,
							string scalar type) 
{
	real scalar i
	real matrix gi,A, wt0,zbar
	
	gi=momentEvaluator(b,tau,yi,di,xi,technique,f,info,fix,zi,wt)
	A=invsym((1/rows(yi))*cross(gi,gi))
	
	return(A)
} 

void gqreg_process_draws(real matrix Draws,
							 real matrix vals,
							 string scalar jumble,
							 real scalar thin,
							 real scalar burn,
							 transmorphic betaf,
							 transmorphic valsf)
{
	real scalar i
	real matrix ordVec

	Draws = Draws[burn+1::rows(Draws),]

	if (thin!=1) {
		keep=J(0,1,.)
		for (i=thin;i<=rows(Draws);i=i+thin) keep=keep \ i
	}
	else keep=(1::rows(Draws))

	if (jumble=="jumble") _jumble(keep)
	betaf=Draws[keep,]
	valsf=vals[keep,]
}	

// GQR analytic standard errors.
real matrix gqr_var(yi,di,xi,beta,tau,zi,wt,deriv,technique,f,fix,info)
{	
	real scalar bdw,n
	real matrix dib,gamma,uu,iqr,meanuu,sqruu,pick,stderr,meansqr
	real matrix dep1, dep2, diff, G
	
	n=rows(yi)
	
	dib=di*beta'
	
	gamma=mm_quantile(yi-dib,wt,tau)*J(rows(yi),1,1)
	
	// figure out bandwidth 
	uu = yi:-dib:-gamma
	iqr=mm_iqrange(uu, 1)
	meanuu=colsum(uu)/rows(uu)
	sqruu=(uu:-meanuu):^2
	meansqr=(colsum(sqruu)/(rows(uu)-1))^.5
	pick=(meansqr,iqr/1.349)
	stderr=rowmin(pick)
	bdw=1.0589*stderr*(rows(yi))^(-.2)

	//Get G
	dep1=(uu :< bdw)
	dep2=(uu :< -bdw)
	
	if (technique=="logit" | technique=="probit") {	
		Mod1=moptimize_init()
		moptimize_init_tracelevel(Mod1,"none")
		moptimize_init_evaluatortype(Mod1,"lf")
		moptimize_init_depvar(Mod1,1,dep1)
		moptimize_init_eq_indepvars(Mod1,1,xi)
		moptimize_init_evaluator(Mod1,f)
		moptimize_init_weight(Mod1, wt)
		moptimize(Mod1)
		delHat1=moptimize_result_coefs(Mod1)
		
		Mod2=moptimize_init()
		moptimize_init_tracelevel(Mod2,"none")
		moptimize_init_evaluatortype(Mod2,"lf")
		moptimize_init_depvar(Mod2,1,dep2)
		moptimize_init_eq_indepvars(Mod2,1,xi)
		moptimize_init_evaluator(Mod2,f)
		moptimize_init_weight(Mod2, wt)
		moptimize(Mod2)
		delHat2=moptimize_result_coefs(Mod2)
		
	}
	else {
		xx = cross(xi,1,wt,xi,1)
		xy = cross(xi,1,wt,dep1,0)
		delHat1=invsym(xx)*xy
		
		xx = cross(xi,1,wt,xi,1)
		xy = cross(xi,1,wt,dep2,0)
		delHat2=invsym(xx)*xy
	}

		if (technique=="logit") {
			pr1 =exp((xi,J(rows(xi),1,1))*delHat1'):/(1:+exp((xi,J(rows(xi),1,1))*delHat1'))
			pr2 =exp((xi,J(rows(xi),1,1))*delHat2'):/(1:+exp((xi,J(rows(xi),1,1))*delHat2'))
		}
		else if (technique=="probit") {
			pr1 =normal((xi,J(rows(xi),1,1))*delHat1')
			pr2 =normal((xi,J(rows(xi),1,1))*delHat2')
		}
		else {
			pr1 =(xi,J(rows(xi),1,1))*delHat1
			pr2 =(xi,J(rows(xi),1,1))*delHat2
		}
	diff=(dep1:-dep2):-(pr1:-pr2)

	// relationship btw constant and coeff on X
	constderiv=J(rows(di),cols(di),0)
	for (l=1; l<=cols(di); l++) {
		beta_plus=beta
		beta_plus[l]=beta[l]:+deriv[l]
		gamma_psi_plus=estimateGamma(beta_plus, yi,di,wt,tau,technique,fix)
		beta_minus=beta
		beta_minus[l]=beta[l]:-deriv[l]
		gamma_psi_minus=estimateGamma(beta_minus,yi,di,wt,tau,technique,fix)
		constderiv[.,l]=(gamma_psi_plus:-gamma_psi_minus):/(2:*deriv[l])
	}
	
	diff=wt:*diff
	G=cross(zi,diff,(di:+ constderiv))/(2*bdw*n)

	//SIGMA	
	gi=momentEvaluator(beta,tau,yi,di,xi,technique,f,info,fix,zi,wt)	
	Sigma=((1/n)*cross(gi,gi))
		
	variance=invsym(G'*invsym(Sigma)*G)/rows(info)	
	//variance=invsym(G'*A*G)*(G'*A*Sigma*A*G)*invsym(G'*A*G)

	return(variance)
}

// heteroskedastic consistent variance-covariance matrix for standard quantile regression.
// adapted from Chernozhukov and Hansen's vcqr.ox code
real matrix kcov_qr(beta,tau,y,x,wt)
{
	real matrix  vc, n, S, e, J, k, h

	n=rows(y)
	x=(x,J(rows(x),1,1))
	k=cols(beta)
	vc=J(k,k,0)
	S=(1/n)*cross(x,wt,x)
	e=y-x*beta'

	h = 1.364*((2*sqrt(pi()))^(-1/5))*sqrt(variance(e,wt))*(n^(-1/5));
	J = (1/(n*h))*cross((normalden(e/h):*x),wt,x)
	J = cholinv(J)

    vc = (1/n)*(tau-tau^2)*J'*S*J;

	return(vc)
}

// heteroskedastic consistent variance-covariance matrix for standard IV-quantile regression.
// adapted from Chernozhukov and Hansen's vciqr.ox code
real matrix kcov_iqr(beta,tau,y,d,xi,z,wt)
{
	real matrix  vc, n, S, e, J, k, h
 
	n=rows(y)
	x=(xi,J(rows(xi),1,1))
	k=cols((d,x))
	vc=J(k,k,0)
	S = (1/n)*cross((z,x),wt,(z,x))
	e=y-(d,x)*beta'

	h = 1.364*((2*sqrt(pi()))^(-1/5))*sqrt(variance(e,wt))*(n^(-1/5));
	J = (1/(n*h))*cross((normalden(e/h):*(d,x)),wt,(z,x))
	J = invsym(J)

    vc = (1/n)*(tau-tau^2)*J'*S*J;
	
	return(vc)
}

// heteroskedastic consistent variance-covariance matrix for standard IV-quantile regression.
// Over-identified case.
// adapted from Chernozhukov and Hansen's vciqr_oid.m code

real matrix kcov_iqr_oid(beta,tau,y,d,xi,z,wt)
{
	real matrix  vc, n, x, S, e, h, Ja, H,JT,Jg,Jb,K,L,M 

	n=rows(y)
	x=(xi,J(rows(xi),1,1))
	k=cols((d,x))
	vc=J(k,k,0)
	S = (tau-tau^2)*(1/n)*cross((z,x),wt,(z,x))
	e=y-(d,x)*beta'

	h = 1.364*((2*sqrt(pi()))^(-1/5))*sqrt(variance(e,wt))*(n^(-1/5));
	Ja = (1/(n*h))*cross((normalden(e/h):*d),wt,(z,x))
	H = (1/(n*h))*cross((normalden(e/h):*(z,x)),wt,(z,x))
	JT = invsym(H)
	Jg = JT[1..cols(z),.]
	Jb = JT[(cols(z)+1)..rows(JT),.]
	K = invsym(Ja*Jg'*invsym(Jg*S*Jg')*Jg*Ja')*(Ja*Jg'*invsym(Jg*S*Jg')*Jg);
	L  = Jb - Jb*Ja'*K;

	M = (K \ L);

    vc = (1/n)*M*S*M';

	return(vc)
}

// Functions added by Matt on 7/31/2015 to check whether there are any perfect predictors and act accordingly. 
// This is then reported to the user. 
real matrix checkSupport(y,X) {
	flag=J(rows(X),cols(X),0)
	for (i=1;i<=cols(X);i++) {
		vals=uniqrows(X[,i])
		check=rows(vals)
		if (check==2) {
			for (j=1;j<=check;j++) {
				yCheck=select(y,X[,i]:==vals[j])
				if (all(yCheck:==0)) {
					pos=mm_which(X[,i]:==vals[j])
					flag[pos,i]=J(rows(pos),1,-1)
				}
				else if (all(yCheck:==1)) {
					pos=mm_which(X[,i]:==vals[j])
					flag[pos,i]=J(rows(pos),1,1)
				}
			}	
		}	
	}
	return(flag)
	
}
/* Maybe return a message at some point? */
void supportMessage(real matrix X,string matrix namesX) 
{
		predY1=colsum(X:==1)
		predY0=colsum(X:==-1)
		for (i=1;i<=cols(X);i++) {
				if (predY1[i]>0) {
					printf("{txt}Variable {cmd}%s {txt}predicts p(y>gamma+d'b)=1 for %f values perfectly in last iteration.\n",
						namesX[i],predY1[i]) 
					printf("Proneness set to p(y>gamma+d'b)=1.\n")
					displayflush()
				}
				if (predY0[i]>0) {
					printf("{txt}Variable {cmd}%s {txt}predicts p(y<=gamma+d'b)=0 for %f values perfectly in last iteration.\n",
						namesX[i],predY0[i]) 
					printf("  Proneness set to p(y>gamma+d'b)=0.\n")
				}
		}
}

/* function added by Travis to find row max */
real matrix findRowMax(	real colvector X1,
						real matrix X2)
{
	real colvector row_index
	real matrix trash
	
	row_index=.; trash=.; maxindex(X1,1,row_index,trash)
	RowMax=X2[row_index,.]
	
	return(RowMax)
}
end	


