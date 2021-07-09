*! version 1.3.0 02Feb2012

program stjm11_d0_g_na
	args todo b lnf
	
	local eq_num = 1
	
	/* Longitudinal fixed linear predictor */
	tempvar beta`eq_num'
	mleval `beta`eq_num''	= `b', eq(`eq_num')
	local intercept "`beta`eq_num''"
	local `++eq_num'	
	
	/* Variance paramaters for random effects */
	matrix vcv = J($n_re,$n_re,0)
	if "$cov"=="ind" | "$cov"=="unstr" {
		forvalues i=1/$n_re {											
			tempname sd_`i' var_`i'
			mleval `sd_`i'' 	= `b', eq(`eq_num') scalar
			scalar `sd_`i'' 	= exp(`sd_`i'')
			scalar `var_`i'' 	= `sd_`i''^2
			mat vcv[`i',`i'] 	= `var_`i''
			local `++eq_num'
		}
	}
	else {
		tempname sd_1 var_1
		mleval `sd_1' 	= `b', eq(`eq_num') scalar
		scalar `sd_1' 	= exp(`sd_1')
		scalar `var_1' 	= `sd_1'^2
		local `++eq_num'
		forvalues i=1/$n_re {											
			mat vcv[`i',`i'] 	= `var_1'
		}
	}

	/* correlation eqn's, reparameterising and VCV matrix elements */
	if "$cov"=="exch" & $n_re>1 {
		tempname corr_1
		mleval `corr_1' = `b', eq(`eq_num') scalar
		scalar `corr_1' = tanh(`corr_1')
		local `++eq_num'
		local test=1												
		while (`test'<$n_re) {
			forvalues i=`=`test'+1'/$n_re {
				mat vcv[`test',`i'] 	 = `sd_1'*`sd_1'*`corr_1'
				mat vcv[`i',`test'] 	 = `sd_1'*`sd_1'*`corr_1'
			}
			local `++test'
		}	
	}
	else if "$cov"=="unstr" {
		local test=1												
		while (`test'<$n_re) {
			forvalues i=`=`test'+1'/$n_re {
				tempname corr_`test'_`i'
				mleval `corr_`test'_`i'' = `b', eq(`eq_num') scalar
				scalar `corr_`test'_`i'' = tanh(`corr_`test'_`i'')
				mat vcv[`test',`i'] 	 = `sd_`test''*`sd_`i''*`corr_`test'_`i''
				mat vcv[`i',`test'] 	 = `sd_`test''*`sd_`i''*`corr_`test'_`i''
				local `++eq_num'
			}
			local `++test'
		}	
	}

	/* Residual error */
	tempname s_e 
	mleval `s_e'    = `b', eq(`eq_num') scalar						/* residual error */
	scalar `s_e'	= exp(`s_e')
	local `++eq_num'
	
	tempname assoc_mat
	mat `assoc_mat' = J(1,$n_alpha,.)
	local assoc_ith = 1
	
	/* Association parameterisations */
	if "$current"=="yes" {
		tempvar alpha_c
		mleval `alpha_c'  	= `b', eq(`eq_num')				/* association - current value */
		local `++eq_num'
		local assocmlnames "`alpha_c'"
	}
	
	if "$deriv"=="yes" {
		tempname alpha_dy
		mleval `alpha_dy'	= `b', eq(`eq_num')
		local `++eq_num'
		local assocmlnames "`assocmlnames' `alpha_dy'"
	}
	
	if "$intassoc"=="yes" {
		tempname alpha_int
		mleval `alpha_int'  	= `b', eq(`eq_num')			/* association - intercept */
		local `++eq_num'
		local assocmlnames "`assocmlnames' `alpha_int'"
	}
	
	if "$timeassoc"=="yes" {
		tempname n_assoc_time
		scalar `n_assoc_time' = $n_time_assoc
		forvalues i=1/$n_time_assoc {
			tempname alpha_assoc_`i'
			mleval `alpha_assoc_`i''  	= `b', eq(`eq_num')			/* association - random time coefficients */
			local `++eq_num'
			local assocmlnames "`assocmlnames' `alpha_assoc_`i''"
		}
	}
	else {
			tempname n_assoc_time
			scalar `n_assoc_time' = 0
	}
	
	/* Survival parameters */
	tempvar lambda1 lambda 
	tempname gamma
	mleval `lambda1' 	= `b', eq(`eq_num')							/* linear predictor of survival submodel */
	gen double `lambda' = exp(`lambda1')
	local `++eq_num'
	mleval `gamma'		= `b', eq(`eq_num') scalar							
	
	/* Extract longitudinal paramaters for survival submodel */
	tempname newbetamat
	matrix `newbetamat' = $ML_b[1,"Longitudinal:"]'
	
*quietly{
	
	/* Tempvar. to store final joint log-likelihood */
	tempvar finallnf2	
	qui gen double `finallnf2' = .

	mata: betas_fixed 	= st_matrix("`newbetamat'")								// Pass longitudinal beta's
	mata: intercept 	= st_data(.,"`intercept'",st_global("touse"))			// Pass evaluated longitudinal linear predictor
	mata: alpha_mat 	= st_data(.,tokens(st_local("assocmlnames")),st_global("newsurvtouse"))		// Pass association matrix
	mata: lambda_mat 	= st_data(.,"`lambda'",st_global("newsurvtouse"))				// Pass lambda

	/* Mata program to evaluate joint likelihood */
		mata stjm_g_na_mata$quick("`finallnf2'",st_global("surv_indlab"),y_ij,st_numscalar("`gamma'"),
							st_numscalar("`s_e'"),N,Nmeas,nres,st_numscalar("`n_assoc_time'"),
							st_global("touse"),intercept,Z_dm,X_dm_surv,Z_dm_surv,
							diff_X_dm_surv,diff_Z_dm_surv,nodesfinal,weightsfinal,knewnodes,
							kweights,jlnodes,stime,d,betas_fixed,alpha_mat,
							gknodes,gknodes_deriv,rand_ind_gk,survlike,longlike,info,nmeas,ngk,
							lambda_mat,st_matrix("vcv"))	

	mlsum `lnf' = ln(`finallnf2') if $surv_indlab==1
	
*}
	
end


/*** MATA CODE ***/

mata:
	void stjm_g_na_mata(string scalar finallnf, 			// -Variable name to place likelihood contributions-
						string scalar s_ind, 				// -Final row per panel indicator-
						numeric matrix y_ij,	 			// -Observed longitudinal response-
						numeric scalar gamma, 				// -Shape parameter for Weibull submodel-
						real scalar sdresidual, 			// -Current residual error estimate-
						numeric scalar N, 					// -Number of panels-
						numeric scalar Nmeas,				// -Total number of longitudinal measurements-
						real scalar nres, 					// -Number of random effects-
						real scalar ntimeassoc,				// -Number of associations with random time coefficients-
						string scalar touse,				// -touse indicator variable name-
						numeric matrix intercept,			// -Evaluated longitudinal linear predictor-
						numeric matrix Z_dm,				// -Random effects design matrix for longitudinal submodel-
						numeric matrix X_dm_surv,			// -Fixed effects design matrix for survival submodel-
						numeric matrix Z_dm_surv,			// -Random effects design matrix for survival submodel-
						numeric matrix diff_X_dm_surv,		// -First derivative of fixed effects design matrix for survival submodel (or zero)-
						numeric matrix diff_Z_dm_surv,		// -First derivative of random effects design matrix for survival submodel (or zero)-
						numeric matrix nodesfinal,			// -Expanded GH node matrix-
						numeric matrix weightsfinal,		// -Expanded final GH weight matrix-
						numeric matrix knewnodes,			// -Adjusted final GK node matrix-
						numeric matrix kweights,			// -Adjusted final GK weight matrix-
						numeric matrix jlnodes,				// -Joint likelihood evaluated at each node-
						numeric matrix stime,				// -Survival times-
						numeric matrix d,					// -Event indicator-
						numeric matrix betas_fixed,			// -Longitudinal betas for survival submodel-
						numeric matrix alpha_mat,			// -Association parameters-
						transmorphic gknodes, 				// -Design matrix for survival submodel including GK nodes-
						transmorphic gknodes_deriv,			// -First derivative of desgin matrix for survival submodel-
						numeric matrix rand_ind_gk,			// -Indicator matrix to add GH nodes to beta's for survival submodel-
						numeric matrix survlike,			// -Matrix to contain survival likelihood at each GH node-
						numeric matrix longlike,			// -Matrix to contain longitudinal likelihood at each node-
						numeric matrix info,				// -Panel matrix set-up-
						numeric matrix nmeas,				// -Number of measurements per panel-
						real scalar ngk,					// -Number of GK nodes-
						numeric matrix lambda_mat,			// -Scale parameter for survival submodel-
						numeric matrix vcv)					// -Variance-covariance matrix of random effects-
														
{
		
		nodes = cholesky(vcv) * nodesfinal
		st_view(final=.,.,finallnf,s_ind)
		
	/*************************************************************************************************************************************************/
	/*** Likelihood ***/
	
		/* Hazard function at each random effect quadrature points */

			alpha_ith = 1
			assoc1 = assoc1_del = J(Nmeas,cols(nodes),0)
			if (st_global("current")=="yes") {
				assoc1 = alpha_mat[,alpha_ith] :* ((X_dm_surv * betas_fixed) :+ (Z_dm_surv * nodes))
				alpha_ith = alpha_ith :+ 1
			}

			if (st_global("deriv")=="yes") {
				assoc1 = assoc1 :+ alpha_mat[,alpha_ith] :* (diff_X_dm_surv * betas_fixed :+ (diff_Z_dm_surv * nodes))
				alpha_ith = alpha_ith :+ 1
			}
			
			if (st_global("intassoc")=="yes") {
				assoc1 = assoc1 :+ alpha_mat[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:*J(Nmeas,1,nodes[nres,.]))
				alpha_ith = alpha_ith :+ 1
			}

			if (st_global("timeassoc")=="yes") {
				timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
				time_assoc_ind = st_matrix("timeassoc_re_ind")	//move to syntax
				for(m=1; m<=ntimeassoc; m++) {
					assoc1 = assoc1 :+ alpha_mat[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(Nmeas,1,nodes[time_assoc_ind[m,1],.]))
					alpha_ith = alpha_ith :+ 1
				}	
			}
		
			haz = (lambda_mat:*exp(gamma:*stime):*exp(assoc1)):^d
		
			/* Longitudinal likelihood */

			linpred = intercept :+ (Z_dm * nodes)
			longtest = normalden(y_ij,linpred,sdresidual)
		
			/* Cumulative hazard */
			
			for (i=1; i<=rows(info); i++) {
				
				lambda_mat_i = panelsubmatrix(lambda_mat,i,info)
				knewnodes_i = panelsubmatrix(knewnodes,i,info)	
				kweights_i = panelsubmatrix(kweights,i,info)
				assocmat_i = panelsubmatrix(alpha_mat,i,info)
				surv = J(nmeas[i,1],cols(nodesfinal),.)
				
				for (q=1;q<=nmeas[i,1];q++) {
				
					beta_mat = J(1,cols(nodesfinal),betas_fixed)
					beta_mat[rand_ind_gk,] = beta_mat[rand_ind_gk,] :+ nodes			// adds GH nodes_i to appropriate betas_fixed_i 
					alpha_ith = 1
					assoc_ch = J(ngk,cols(nodesfinal),0)
					if (st_global("current")=="yes") {
						assoc_ch = assocmat_i[q,alpha_ith]:* (asarray(gknodes,(i,q)) * beta_mat)
						alpha_ith = alpha_ith :+ 1						
					}
					
					if (st_global("deriv")=="yes") {
						assoc_ch = assoc_ch :+ assocmat_i[q,alpha_ith]:* (asarray(gknodes_deriv,(i,q)) * beta_mat)
						alpha_ith = alpha_ith :+ 1						
					}					

					if (st_global("intassoc")=="yes") {
						assoc_ch = assoc_ch :+ assocmat_i[q,alpha_ith]:* beta_mat[rows(beta_mat),]
						alpha_ith = alpha_ith :+ 1
					}
					
					if (st_global("timeassoc")=="yes") {
						for(p=1; p<=ntimeassoc; p++) {
							assoc_ch = assoc_ch :+ assocmat_i[q,alpha_ith]:*beta_mat[timeassoc_fixed_ind[p,1],]
							alpha_ith = alpha_ith :+ 1
						}
					}
					
					haz_nodes = lambda_mat_i[q,]:*exp(gamma:*knewnodes_i[q,]'):*exp(assoc_ch)
					cumhaz = kweights_i[q,] * haz_nodes		
					surv[q,] = exp(-cumhaz)

				}				
				
				haz1 = panelsubmatrix(haz,i,info)
				survlike[i,] = exp(quadcolsum(log(haz1:*surv),1))
			
				long1 = panelsubmatrix(longtest,i,info)
				longlike[i,] = exp(quadcolsum(log(long1),1))
		
			}
		
			/* Final joint likelihood */
			
				jlnodes[,] = weightsfinal:*longlike:*survlike
				final[,] = quadrowsum(jlnodes,1)		
		
	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	
	
}				
end


mata:
	void stjm_g_na_mata_quick(string scalar finallnf, 		// -Variable name to place likelihood contributions-
						string scalar s_ind, 				// -Final row per panel indicator-
						numeric matrix y_ij,	 			// -Observed longitudinal response-
						numeric scalar gamma, 				// -Shape parameter for Weibull submodel-
						real scalar sdresidual, 			// -Current residual error estimate-
						numeric scalar N, 					// -Number of panels-
						numeric scalar Nmeas,				// -Total number of longitudinal measurements-
						real scalar nres, 					// -Number of random effects-
						real scalar ntimeassoc,				// -Number of associations with random time coefficients-
						string scalar touse,				// -touse indicator variable name-
						numeric matrix intercept,			// -Evaluated longitudinal linear predictor-
						numeric matrix Z_dm,				// -Random effects design matrix for longitudinal submodel-
						numeric matrix X_dm_surv,			// -Fixed effects design matrix for survival submodel-
						numeric matrix Z_dm_surv,			// -Random effects design matrix for survival submodel-
						numeric matrix diff_X_dm_surv,		// -First derivative of fixed effects design matrix for survival submodel (or zero)-
						numeric matrix diff_Z_dm_surv,		// -First derivative of random effects design matrix for survival submodel (or zero)-
						numeric matrix nodesfinal,			// -Expanded GH node matrix-
						numeric matrix weightsfinal,		// -Expanded final GH weight matrix-
						numeric matrix knewnodes,			// -Adjusted final GK node matrix-
						numeric matrix kweights,			// -Adjusted final GK weight matrix-
						numeric matrix jlnodes,				// -Joint likelihood evaluated at each node-
						numeric matrix stime,				// -Survival times-
						numeric matrix d,					// -Event indicator-
						numeric matrix betas_fixed,			// -Longitudinal betas for survival submodel-
						numeric matrix alpha_mat,			// -Association parameters-
						transmorphic gknodes, 				// -Design matrix for survival submodel including GK nodes-
						transmorphic gknodes_deriv,			// -First derivative of desgin matrix for survival submodel-
						numeric matrix rand_ind_gk,			// -Indicator matrix to add GH nodes to beta's for survival submodel-
						numeric matrix survlike,			// -Matrix to contain survival likelihood at each GH node-
						numeric matrix longlike,			// -Matrix to contain longitudinal likelihood at each node-
						numeric matrix info,				// -Panel matrix set-up-
						numeric matrix nmeas,				// -Number of measurements per panel-
						real scalar ngk,					// -Number of GK nodes-
						numeric matrix lambda_mat,			// -Scale parameter for survival submodel-
						numeric matrix vcv)					// -Variance-covariance matrix of random effects-
														
{
		
		nodes = cholesky(vcv) * nodesfinal
		st_view(final=.,.,finallnf,s_ind)
		
	/*************************************************************************************************************************************************/
	/*** Likelihood ***/
	
		/* Hazard function at each random effect quadrature points */

			alpha_ith = 1
			assoc1 = assoc1_del = J(N,cols(nodes),0)
			if (st_global("current")=="yes") {
				assoc1 = alpha_mat[,alpha_ith] :* ((X_dm_surv * betas_fixed) :+ (Z_dm_surv * nodes))
				alpha_ith = alpha_ith :+ 1
			}

			if (st_global("deriv")=="yes") {
				assoc1 = assoc1 :+ alpha_mat[,alpha_ith] :* (diff_X_dm_surv * betas_fixed :+ (diff_Z_dm_surv * nodes))
				alpha_ith = alpha_ith :+ 1
			}
			
			if (st_global("intassoc")=="yes") {
				assoc1 = assoc1 :+ alpha_mat[,alpha_ith]:*(betas_fixed[rows(betas_fixed),] :+ J(N,1,nodes[nres,.]))
				alpha_ith = alpha_ith :+ 1
			}

			if (st_global("timeassoc")=="yes") {
				timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
				time_assoc_ind = st_matrix("timeassoc_re_ind")	//move to syntax
				for(m=1; m<=ntimeassoc; m++) {
					assoc1 = assoc1 :+ alpha_mat[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(N,1,nodes[time_assoc_ind[m,1],.]))
					alpha_ith = alpha_ith :+ 1
				}	
			}
		
			haz = (lambda_mat:*exp(gamma:*stime):*exp(assoc1)):^d
		
			/* Longitudinal likelihood */

			linpred = intercept :+ (Z_dm * nodes)
			longtest = normalden(y_ij,linpred,sdresidual)
		
			/* Cumulative hazard */
				
			surv = J(N,cols(nodesfinal),.)
			
			for (i=1; i<=N; i++) {
				
				beta_mat = J(1,cols(nodesfinal),betas_fixed)
				beta_mat[rand_ind_gk,] = beta_mat[rand_ind_gk,] :+ nodes			// adds GH nodes_i to appropriate betas_fixed_i 
				
				alpha_ith = 1
				assoc_ch = J(ngk,cols(nodesfinal),0)
				if (st_global("current")=="yes") {
					assoc_ch = alpha_mat[i,alpha_ith]:* (asarray(gknodes,(i,1)) * beta_mat)
					alpha_ith = alpha_ith :+ 1		
				}
				
				if (st_global("deriv")=="yes") {
					assoc_ch = assoc_ch :+ alpha_mat[i,alpha_ith]:* (asarray(gknodes_deriv,(i,1)) * beta_mat)
					alpha_ith = alpha_ith :+ 1						
				}					

				if (st_global("intassoc")=="yes") {
					assoc_ch = assoc_ch :+ (alpha_mat[i,alpha_ith]:* beta_mat[rows(beta_mat),])
					alpha_ith = alpha_ith :+ 1
				}
				
				if (st_global("timeassoc")=="yes") {
					for(p=1; p<=ntimeassoc; p++) {
						assoc_ch = assoc_ch :+ alpha_mat[i,alpha_ith]:*beta_mat[timeassoc_fixed_ind[p,1],]
						alpha_ith = alpha_ith :+ 1
					}
				}
				
				haz_nodes = lambda_mat[i,]:*exp(gamma:*knewnodes[i,]'):*exp(assoc_ch)
				cumhaz = kweights[i,] * haz_nodes		
				surv[i,] = exp(-cumhaz)
				
				long1 = panelsubmatrix(longtest,i,info)
				longlike[i,] = exp(quadcolsum(log(long1),1))
		
			}

				survlike = haz:*surv
		
			/* Final joint likelihood */
			
				jlnodes[,] = weightsfinal:*longlike:*survlike
				final[,] = quadrowsum(jlnodes,1)		
		
	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	
	
}				
end

