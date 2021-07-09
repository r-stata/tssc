*! qregpd 1.0.1 12jan2015
*! version 1.0.1
*! authors: David Powell, Travis Smith, Matthew Baker
program qregpd
	version 11.2
	if replay() {
		if (`"`e(cmd)'"' != "qregpd") error 301
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
			ANALYTIC						///
			USEMAX							///
		IDentifier(varname)   ///
		INSTRuments(varlist)  ///
		FIX(varname)          ///
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
	
	// panel info
	if ("`identifier'"=="") {
		di as error "Error: You must specify a panel identifier"
		exit
	}
	// fixed effect
	else if ("`fix'"=="") {
		di as error "Error: You must specify a fixed effect"
		exit
	}
	else {
		preserve
		sort `identifier' `fix'
		mata: id=st_data(.,"`identifier'","`touse'")
		mata: info=panelsetup(id,1)
		mata: fix=st_data(.,"`fix'","`touse'")
	}

	// Errors in choosing options
	if ("`optimize'" !="mcmc" & "`optimize'" !="grid") {
		local optimize "NM"
	}
	if ("`optimize'" !="mcmc") {
		if (`burn'!=0 | `draws'!=1000 | `arate'!=.234 | `dampparm'!=1 ///
		  | `thin'!=1 | "`sampler'"!="" ///
		  | "`saving'"!="" | "`replace'"=="replace" | "`append'"=="append" ///
		  | "`jumble'"=="jumble") {
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
	

	/* Starting values */
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

	/* Read in info */
	mata: tau     =strtoreal(st_local("tau"))
	mata: st_view(di=.,.,"`rhs'","`touse'")
	mata: st_view(zi=.,.,"`instruments'","`touse'")
	mata: st_view(yi=.,.,"`lhs'","`touse'")
	mata: st_view(wt=.,.,"`weightvar'","`touse'")

	//normalize weights to sum to total num of obs
	//mata: wt = wt:/colsum(wt)*rows(yi)
	//normalize weights to sum to N
	mata: wt = wt:/colsum(wt)*rows(info)
	
	// Useful panel matrices
	mata: mm_panels(id,ti=.)				/* Nx1 vec num of t per i,  */ 						
	mata: Ti=mm_expand(ti,ti,1,1) 			/* NTx1 vec of num of t per i */
	//mata: DTi=mm_expand(diag(ti),ti,1,1)	/* NTxN mat with Ti on Diag */

	*demeaned instruments
	mata: Znew=demeanX(id,zi,wt)	
	
	// weight matrix
	mata: A=weightMatrix(beta_start,tau,yi,di,Znew,id,fix,zi,wt,"efficient")
	
	// setup moptimize
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

	mata: G=qrpdInfoInit(yi,Znew,di,A,info,fix,zi,wt,tau,id,Ti)
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
			mata: bmcmc=findRowMax(valsf,betaf)[1,.]
		}
		*...or use mean of draws
		else {
			mata: bmcmc=mean(betaf)
		}
		
		* calculate analytic variance
		if "`analytic'"!="" {
			mata: Vmcmc=qrpd_var(yi,di,bmcmc,tau,fix,info,zi,wt,beta_start_se,id,Znew)
		}
		*...or use variance of draws
		else {
			mata: Vmcmc=variance(betaf)
		}
		
		mata: st_matrix("`b'",bmcmc)
		mata: st_matrix("`V'",Vmcmc)
		mata: st_numscalar("`valMean'",mean(valsf))
		mata: st_numscalar("`valMax'",max(valsf))
		mata: st_numscalar("`valMin'",min(valsf))
		mata: st_numscalar("`drawsKept'",rows(valsf))
	

		// get the values of gamma
		mata: gam=estimateGamma(bmcmc,yi,di,wt,tau,fix)
		mata: uniq_gam=uniqrows((fix,gam))						/* in "no constant" form */
		mata: constant=uniq_gam[rows(uniq_gam),2]				/* let constant be last value */
		//mata: uniq_gam1=uniq_gam[1..rows(uniq_gam),2]			/* drop the first column */
		//mata: gam_vec=(uniq_gam1[1..(rows(uniq_gam1)-1)]:-constant \ constant)
		
		mata: st_matrix("`gamma'", uniq_gam)
				
		tempname beta_start beta_start_var
		mata: st_matrix("`beta_start'",beta_start)
		mata: st_matrix("`beta_start_var'",beta_start_var)
	
		mat colnames `b' = `rhs' 
		mat colnames `V' = `rhs' 
		mat rownames `V' = `rhs' 
		mat colnames `gamma' = `fix' estimate
		
		tempname N_g N g_min g_max
		mata: st_numscalar("`N_g'",panelstats(info)[1])
		mata: st_numscalar("`N'",panelstats(info)[2])
		mata: st_numscalar("`g_min'",panelstats(info)[3])
		mata: st_numscalar("`g_max'",panelstats(info)[4])
		local N_g=`N_g'
		local N=`N'
		local g_min=`g_min'
		local g_max=`g_max'
	
		ereturn clear
		//ereturn post `b' `V', esample(`touse') obs(`N') dof(`dof')
		ereturn post `b' `V', esample(`touse') obs(`N') 
		
		ereturn local title "Quantile Regression for Panel Data (QRPD)"
		ereturn local cmd "qregpd"
		ereturn local indepvars `rhs'
		ereturn local depvar `lhs'

		ereturn matrix gamma `gamma'
		ereturn matrix b_init=`beta_start'
		ereturn matrix V_init=`beta_start_var'
		
		ereturn local sampler `sampler'
		ereturn local saving `saving'
		ereturn local jumble `jumble'
		
		ereturn scalar N=`N'
		ereturn scalar N_g=`N_g'
		ereturn scalar g_min=`g_min'
		ereturn scalar g_max=`g_max'
		
		ereturn scalar draws=`draws'
		ereturn scalar burn=`burn'
		ereturn scalar thin=`thin'
		ereturn scalar damper=`dampparm'
	
		ereturn scalar opt_arate=`arate'
		ereturn scalar arates_mean=`arates_mean'
		ereturn scalar f_mean=`valMean'
		ereturn scalar f_max =`valMax'
		ereturn scalar f_min =`valMin'
	
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
		di as txt "     Number of obs:        " as res %10.0f `e(N)'
		di as txt "     Number of groups:     " as res %10.0f `e(N_g)'
		di as txt "     Min obs per group:    " as res %10.0f `e(g_min)'
		di as txt "     Max obs per group:    " as res %10.0f `e(g_max)'
					
		ereturn display
		if ("`excluded_inst'"=="") {
			disp as text "No excluded instruments - standard QRPD estimation."
		}
		if ("`excluded_inst'"!="") {
			disp as text "Excluded instruments: " "`excluded_inst'"
		}
		
		di _newline
		di as txt "MCMC diagonstics:"
		di as txt "     Mean acceptance rate: " as res %10.3f `e(arates_mean)'
		di as txt "     Total draws:          " as res %10.0f `e(draws)'
		di as txt "     Burn-in draws:        " as res %10.0f `e(burn)'
		di as txt "     Draws retained:       " as res %10.0f `e(draws_retained)'
		di as txt "     Value of objective function:   "
		di as txt "             Mean:         " as res %12.4f `e(f_mean)'
		di as txt "             Min:          " as res %12.4f `e(f_min)'
		di as txt "             Max:          " as res %12.4f `e(f_max)'
		di as txt "MCMC notes:"
		if `e(thin)'!=1		{
		di as txt "     *One of every " %1.0f `e(thin)' " draws kept"
					} 
		if "`e(jumble)'"=="jumble" {
		di as txt "     *Draws Jumbled"
					} 
		if "`e(saving)'"!="" {
		di as txt "     *Draws saved in: " "`e(saving)'"
				}
		if "`usemax'"!="" {
			di as txt  "     *Point estimates correspond to max value of obj function."
		}
		*...or use mean of draws
		else {
			di as txt  "     *Point estimates correspond to mean of draws."
		}
		
		* calculate analytic variance
		if "`analytic'"!="" {
			di as txt "     *Standard errors are derived analytically."
		}
		*...or use variance of draws
		else {
			di as txt "     *Standard errors are derived from variance of draws."
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
					mata: gamma=estimateGamma(b_grid,yi,di,wt,tau,fix)
					//mata: below=wt:*(yi:<=(gamma:+di*b_grid')):/Ti
					mata: below=wt:*(yi:<=(gamma:+di*b_grid'))
					mata: g=cross(below,Znew)/sqrt(rows(info))
					mata: grid12[grid_index,3]=-0.5*g*A*g'
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
				mata: gamma=estimateGamma(b_grid,yi,di,wt,tau,fix)
				//mata: below=wt:*(yi:<=(gamma:+di*b_grid')):/Ti
				mata: below=wt:*(yi:<=(gamma:+di*b_grid'))
				mata: g=cross(below,Znew)/sqrt(rows(info))
				mata: grid1[grid_index,2]=-0.5*g*A*g'
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
		
		mata: deriv= beta_start_se		
		mata: V=qrpd_var(yi,di,b,tau,fix,info,zi,wt,deriv,id,Znew)
		
		// get the values of gamma
		mata: gam=estimateGamma(b,yi,di,wt,tau,fix)
		mata: uniq_gam=uniqrows((fix,gam))						/* in "no constant" form */
		mata: constant=uniq_gam[rows(uniq_gam),2]				/* let constant be last value */
		//mata: uniq_gam1=uniq_gam[1..rows(uniq_gam),2]			/* drop the first column */
		//mata: gam_vec=(uniq_gam1[1..(rows(uniq_gam1)-1)]:-constant \ constant)
	
		tempname b V gamma
		
		mata: st_matrix("`b'",b)
		mata: st_matrix("`V'",V)
		mata: st_matrix("`gamma'", uniq_gam)	
		
		mat colnames `b' = `rhs' 
		mat colnames `V' = `rhs' 
		mat rownames `V' = `rhs' 
		mat colnames `gamma' = `fix' estimate
		
		tempname N_g N g_min g_max fval
		mata: st_numscalar("`N_g'",panelstats(info)[1])
		mata: st_numscalar("`N'",panelstats(info)[2])
		mata: st_numscalar("`g_min'",panelstats(info)[3])
		mata: st_numscalar("`g_max'",panelstats(info)[4])
		local N_g=`N_g'
		local N=`N'
		local g_min=`g_min'
		local g_max=`g_max'
		mata: st_numscalar("`fval'",fval)
	
		ereturn clear
		ereturn post `b' `V', esample(`touse') obs(`N') 
		
		ereturn local title "Quantile Regression for Panel Data (QRPD)"
		ereturn local cmd "qregpd"
		ereturn local indepvars `rhs'
		ereturn local depvar `lhs'
		ereturn matrix solutions `grid_betas'
		ereturn matrix gamma `gamma'
		ereturn scalar N=`N'
		ereturn scalar N_g=`N_g'
		ereturn scalar g_min=`g_min'
		ereturn scalar g_max=`g_max'
		ereturn scalar fval=`fval'
		
		di _newline
		di as txt "`e(title)'" 
		di as txt "     Number of obs:        " as res %10.0f `e(N)'
		di as txt "     Number of groups:     " as res %10.0f `e(N_g)'
		di as txt "     Min obs per group:    " as res %10.0f `e(g_min)'
		di as txt "     Max obs per group:    " as res %10.0f `e(g_max)'
		ereturn display

		if ("`excluded_inst'"=="") {
			disp as text "No excluded instruments - standard QRPD estimation."
		}
		if ("`excluded_inst'"!="") {
			disp as text "Excluded instruments: " "`excluded_inst'"
		}		
		
		if rowsof(e(solutions)) > 1 {
			di as txt "Note: Alternative solutions exist. See e(solutions)."
		}
		di as txt "Value of objective function: " as res %12.8f `fval'
		
		
	} 
	
/* Nelder-Mead */
	else {
		di "Nelder-Mead optimization"
		mata: moptimize(M)	
		mata: b=moptimize_result_coefs(M)
		
		mata: deriv= beta_start_se	
		mata: V=qrpd_var(yi,di,b,tau,fix,info,zi,wt,deriv,id,Znew)
		
		// get the values of gamma
		mata: gam=estimateGamma(b,yi,di,wt,tau,fix)
		mata: uniq_gam=uniqrows((fix,gam))						/* in "no constant" form */
		mata: constant=uniq_gam[rows(uniq_gam),2]				/* let constant be last value */
		//mata: uniq_gam1=uniq_gam[1..rows(uniq_gam),2]			/* drop the first column */
		//mata: gam_vec=(uniq_gam1[1..(rows(uniq_gam1)-1)]:-constant \ constant)
	
		tempname b V gamma fval
		
		mata: st_matrix("`b'",b)
		mata: st_matrix("`V'",V)
		mata: st_matrix("`gamma'", uniq_gam)	
		mata: st_numscalar("`fval'",moptimize_result_value(M))
		
		mat colnames `b' = `rhs' 
		mat colnames `V' = `rhs' 
		mat rownames `V' = `rhs' 
		mat colnames `gamma' = `fix' estimate
		
		tempname N_g N g_min g_max
		mata: st_numscalar("`N_g'",panelstats(info)[1])
		mata: st_numscalar("`N'",panelstats(info)[2])
		mata: st_numscalar("`g_min'",panelstats(info)[3])
		mata: st_numscalar("`g_max'",panelstats(info)[4])
		local N_g=`N_g'
		local N=`N'
		local g_min=`g_min'
		local g_max=`g_max'
	
		ereturn clear
		ereturn post `b' `V', esample(`touse') obs(`N') 
		
		ereturn local title "Quantile Regression for Panel Data (QRPD)"
		ereturn local cmd "qregpd"
		ereturn local indepvars `rhs'
		ereturn local depvar `lhs'
		ereturn matrix gamma `gamma'
		ereturn scalar N=`N'
		ereturn scalar N_g=`N_g'
		ereturn scalar g_min=`g_min'
		ereturn scalar g_max=`g_max'
		ereturn scalar fval=`fval'

		di _newline
		di as txt "`e(title)'" 
		di as txt "     Number of obs:        " as res %10.0f `e(N)'
		di as txt "     Number of groups:     " as res %10.0f `e(N_g)'
		di as txt "     Min obs per group:    " as res %10.0f `e(g_min)'
		di as txt "     Max obs per group:    " as res %10.0f `e(g_max)'

		ereturn display
		if ("`excluded_inst'"=="") {
			disp as text "No excluded instruments - standard QRPD estimation."
		}
		if ("`excluded_inst'"!="") {
			disp as text "Excluded instruments: " "`excluded_inst'"
		}		
	
	}
end

	
program Replay
	syntax 
	ereturn display
end	

mata:
struct qrpdInfo {
	real matrix yi,Znew,di,A,info,fix,zi,wt,id,Ti
	real scalar tau
} 
struct qrpdInfo qrpdInfoInit(yi,Znew,di,A,info,fix,zi,wt,tau,id,Ti)
{
	struct qrpdInfo scalar G
	G.yi=yi
	G.Znew=Znew
	G.di=di
	G.A=A
	G.info=info
	G.fix=fix
	G.zi=zi
	G.wt=wt
	G.tau=tau
	G.id=id
	G.Ti=Ti
	return(G)
}

void objectiveFunGmm(M,todo,b,obj,h,H) 
{
	real scalar tau
	real matrix yi,Znew,di,info,fix,zi,wt,A,id,Ti
	struct qrpdInfo scalar G
	
	real matrix  gamma,below, g
	
	yi=moptimize_util_depvar(M,1)
	G=moptimize_util_userinfo(M,1)
	
	gamma=estimateGamma(b,yi,G.di,G.wt,G.tau,G.fix)
	below=G.wt:*(yi:<=(gamma:+G.di*b'))
	//below=G.wt:*(yi:<=(gamma:+G.di*b')):/G.Ti
	g=cross(below,G.Znew)/sqrt(rows(G.info))
	obj=-0.5*g*G.A*g'	
	
}


real matrix estimateGamma(	real matrix b,
							real matrix yi, 
							real matrix di, 
							real matrix wt, 
							real scalar tau, 
							real matrix fix)
{
	real matrix Gamma, u, fe_id, u_fe, wt_fe
	real scalar num_fe, gamma_fe, fe
	real matrix dum

	u = yi:-di*b'
	fe_id = uniqrows(fix)
	num_fe = rows(fe_id)
	Gamma = J(rows(di), 1, 0)
	dum = J(rows(di), num_fe, .)
	for (fe=1; fe<=num_fe; fe++) {
		u_fe=select(u, fix:==fe_id[fe])
		wt_fe=select(wt, fix:==fe_id[fe])
		gamma_fe=mm_quantile(u_fe, wt_fe, tau)
		dum[.,fe]=gamma_fe*(fix:==fe_id[fe])
		Gamma=Gamma+dum[.,fe]
	}
	return(Gamma)
}
	

real matrix weightMatrix(	real rowvector b,
							real scalar tau,
							real colvector yi,
							real matrix di,
							real matrix Znew,
							real colvector id,
							real matrix fix,
							real matrix zi,
							real colvector wt,
							string scalar type) 
{
	real scalar n,i
	real colvector info,gamma,below
	real matrix git,gi,A
	
	
	info=panelsetup(id,1)
	n=rows(info)
	
	if (type=="efficient") {
	
		gamma=estimateGamma(b,yi,di,wt,tau,fix)
		gi=J(rows(info),cols(zi),.)		
		for (i=1; i<=rows(info); i++) {
			dip=panelsubmatrix(di,i,info)
			zip=panelsubmatrix(zi,i,info)
			yip=panelsubmatrix(yi,i,info)
			wtp=panelsubmatrix(wt,i,info)
			gammap=panelsubmatrix(gamma,i,info)
			zim=panelsubmatrix(Znew,i,info)
			gi[i,.]=colsum(wtp:*zim:*(yip:<=(gammap:+dip*b')))
			//gi[i,.]=colsum(wtp:*zim:*(yip:<=(gammap:+dip*b')))/rows(dip)
		}
		A=invsym((1/rows(yi))*cross(gi,gi))
	}
	
	// NOT USED, place holder for now
	else {
		//A=(1/(tau*(1-tau)))*invsym((1/n)*cross(Znew,Znew))
		// scaling NT, not N
		A=(1/(tau*(1-tau)))*invsym((1/rows(yi))*cross(Znew,Znew))	
	}
	
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

// QRPD analytic standard errors.
real matrix qrpd_var(yi,di,beta,tau,fix,info,zi,wt,deriv,id,Znew)
{
	real scalar bdw,i
	real matrix dib,gamma,uu,iqr,meanuu,sqruu,pick,stderr,meansqr 
	real matrix beta_plus,gamma_psi_plus,beta_minus, gamma_psi_minus
	real matrix yearderiv,x_plus_dgdd,abs_u,abs_u_below_bdw
	real matrix G1,G2,G3,G,below,S1,S2,g0,g2,Sigma,variance,A

	dib=di*beta'
	
	info=panelsetup(id,1)

	gamma=estimateGamma(beta,yi,di,wt,tau,fix)		 					

	/* figure out bandwidth */
	uu = yi:-dib:-gamma
	iqr=mm_iqrange(uu, wt)
	meanuu=colsum(uu:*wt)/colsum(wt)
	sqruu=((uu:*wt):-meanuu):^2
	meansqr=(colsum(sqruu)/(colsum(wt)-1))^.5
	pick=(meansqr,iqr/1.349)
	stderr=rowmin(pick)
	bdw=1.0589*stderr*(rows(yi))^(-.2)
	//bdw = 1.364*((2*sqrt(pi()))^(-1/5))*sqrt(variance(uu,wt))*(rows(info)^(-1/5))
	
	
	// relationship btw year fe and coeff on X
	yearderiv=J(rows(di),cols(di),0)
	for (l=1; l<=cols(di); l++) {
		beta_plus=beta
		beta_plus[l]=beta[l]:+deriv[l]
		gamma_psi_plus=estimateGamma(beta_plus, yi,di,wt,tau,fix)
		beta_minus=beta
		beta_minus[l]=beta[l]:-deriv[l]
		gamma_psi_minus=estimateGamma(beta_minus,yi,di,wt,tau,fix)
		yearderiv[.,l]=(gamma_psi_plus:-gamma_psi_minus):/(2:*deriv[l])
	}

	// x + dgdd (di is x in the paper)
	x_plus_dgdd=di:+yearderiv	
	
	abs_u = abs(yi:-dib:-gamma)
	abs_u_below_bdw=(abs_u:<= bdw)
	
	A=weightMatrix(beta,tau,yi,di,Znew,id,fix,zi,wt,"efficient")
	
	//weight Znew, all weights will pass through
	wtZnew=wt:*Znew
	
	// G matrix
	G1=panelsubmatrix(x_plus_dgdd,1,info)			
	G2=panelsubmatrix(wtZnew,1,info)
	G3=panelsubmatrix(abs_u_below_bdw,1,info)	
	G=cross(G2,G3,G1)
	//G=cross(G2,G3,G1)/rows(G1)						
	for (i=2; i<=rows(info); i++) {
		G1=panelsubmatrix(x_plus_dgdd, i, info)			
		G2=panelsubmatrix(wtZnew, i, info)
		G3=panelsubmatrix(abs_u_below_bdw,i,info)
		G=cross(G2,G3,G1)+G
		//G=cross(G2,G3,G1)/rows(G1)+G 
	}	
	G=((1/2)*(1/bdw)):*G:*(1/rows(info))

	// Sigma
	below=(yi:<=(gamma:+di*beta'))
	S1=panelsubmatrix(below, 1, info)
	S2=panelsubmatrix(wtZnew,1,info)
	g0=(cross(S1,S2))
	//g0=(cross(S1,S2))/rows(S1)
	g2=cross(g0,g0)
	for (i=2; i<=rows(info); i++) {
		S1=panelsubmatrix(below, i, info)			
		S2=panelsubmatrix(wtZnew, i, info)					
		g0=(cross(S1,S2))
		//g0=(cross(S1,S2))/rows(S1)
		g2=cross(g0,g0)+g2
	}
	
	Sigma=g2/rows(info)
	
	//variance=invsym(G'*invsym(Sigma)*G)/rows(info)	
	variance=invsym(G'*A*G)*(G'*A*Sigma*A*G)*invsym(G'*A*G)/rows(info)
	
	return(variance)
}

real matrix demeanX(real colvector id,
					real matrix X,
					real colvector wt)
{
	real matrix Xmean,Xdemean
	real colvector Ti			

	mm_panels(id,Ti=.)				/* num of t per i */
	Xmean=mm_collapse(X,wt,id)		/* collapses into a Nx1 vec */
	Xmean=mm_expand(Xmean,Ti,1,1) 	/* expands into NTx1 */
	Xmean=Xmean[.,2..cols(Xmean)]	/* drop ids in first col */
	Xdemean=X:-Xmean
	return(Xdemean)
}

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
