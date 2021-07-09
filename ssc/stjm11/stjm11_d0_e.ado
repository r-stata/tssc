*! version 1.3.0 02Feb2012

program stjm11_d0_e
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
	mleval `lambda1' 	= `b', eq(`eq_num')							/* linear predictor of survival submodel */
	gen double `lambda' = exp(`lambda1')

	/* Extract longitudinal paramaters for survival submodel */
	tempname newbetamat
	matrix `newbetamat' = $ML_b[1,"Longitudinal:"]'

	/* See if first call for ith iteration */
	if $first_call != $ML_ic {
		global first_call = $ML_ic
		local gen_nodes 1
		mata: firstit = firstit :+ 1
	}
	else {
		local gen_nodes 0
	}	
	
*quietly{
	
	/* Tempvar. to store final joint log-likelihood */
	tempvar finallnf2	
	qui gen double `finallnf2' = .

	mata: betas_fixed 	= st_matrix("`newbetamat'")								// Pass longitudinal beta's
	mata: intercept 	= st_data(.,"`intercept'",st_global("touse"))			// Pass evaluated longitudinal linear predictor
	mata: alpha_mat 	= st_data(.,tokens(st_local("assocmlnames")),st_global("newsurvtouse"))		// Pass association matrix
	mata: lambda_mat 	= st_data(.,"`lambda'",st_global("newsurvtouse"))				// Pass lambda

	
	/* Mata program to evaluate joint likelihood */
		if ("$rescale"=="0"){
			mata stjm_e_mata_init$quick(st_global("surv_indlab"),y_ij,	
							st_numscalar("`s_e'"),N,Nmeas,nres,st_numscalar("`n_assoc_time'"),
							st_global("touse"),intercept,Z_dm,X_dm_surv,Z_dm_surv,
							diff_X_dm_surv,diff_Z_dm_surv,nodesfinal,weightsfinal,knewnodes,
							kweights,jlnodes,stime,d,betas_fixed,alpha_mat,
							aghnodes,aghweights,gknodes,gknodes_deriv,rand_ind_gk,`gen_nodes',
							info,nmeas,ngk,lambda_mat,st_matrix("vcv"))
			global rescale 1
		}
	
		mata stjm_e_mata$quick("`finallnf2'",st_global("surv_indlab"),y_ij,
							st_numscalar("`s_e'"),N,Nmeas,nres,st_numscalar("`n_assoc_time'"),
							st_global("touse"),intercept,Z_dm,X_dm_surv,Z_dm_surv,
							diff_X_dm_surv,diff_Z_dm_surv,nodesfinal,weightsfinal,knewnodes,
							kweights,jlnodes,stime,d,betas_fixed,alpha_mat,
							aghnodes,aghweights,gknodes,gknodes_deriv,rand_ind_gk,`gen_nodes',firstit,adaptit,
							info,nmeas,ngk,lambda_mat,st_matrix("vcv"))	

	mlsum `lnf' = ln(`finallnf2') if $surv_indlab==1
	
*}
	
end


/*** MATA CODE ***/


mata:
mata set matastrict off
			void stjm_e_mata_init( 							//
						string scalar s_ind, 				//
						numeric matrix y_ij,	 			//
						real scalar sdresidual, 			//
						numeric scalar N, 					//
						numeric scalar Nmeas,				//
						real scalar nres, 					//
						real scalar ntimeassoc,				//
						string scalar touse,				//
						numeric matrix intercept,			//
						numeric matrix Z_dm,				//
						numeric matrix X_dm_surv,			//
						numeric matrix Z_dm_surv,			//
						numeric matrix diff_X_dm_surv,		//
						numeric matrix diff_Z_dm_surv,		//
						numeric matrix nodesfinal,			//
						numeric matrix weightsfinal,		//
						numeric matrix knewnodes,			//
						numeric matrix kweights,			//
						numeric matrix jlnodes,				//
						numeric matrix stime,				//
						numeric matrix d,					//
						numeric matrix betas_fixed,			//
						numeric matrix alpha_mat,			//
						transmorphic aghnodes, 				//
						transmorphic aghweights, 			//
						transmorphic gknodes, 				//
						transmorphic gknodes_deriv,			//
						numeric matrix rand_ind_gk,			//
						real scalar gen_nodes,				//
						numeric matrix info,				// -Panel matrix set-up-
						numeric matrix nmeas,				// -Number of measurements per panel-
						real scalar ngk,					// -Number of GK nodes-
						numeric matrix lambda_mat,			// -Scale parameter for survival submodel-
						numeric matrix vcv)					// -Variance-covariance matrix of random effects-
														
{

	/*************************************************************************************************************************************************/
	/* Loop over patients */

		for (i=1; i<=rows(info); i++) {
			
			/* Patient level transformation of node and weight matrices */
					
				nodes_i = asarray(aghnodes,i)
				newweights = asarray(aghweights,i)
				
				/* Can move hazard and final survival calc's to outside loop */				

			/* Data */
			
				Z_dm_i = panelsubmatrix(Z_dm,i,info)
				X_dm_surv_i = panelsubmatrix(X_dm_surv,i,info)
				Z_dm_surv_i = panelsubmatrix(Z_dm_surv,i,info)
				lambda_mat_i = panelsubmatrix(lambda_mat,i,info)
				assocmat_i = panelsubmatrix(alpha_mat,i,info)
				stime_i = panelsubmatrix(stime,i,info)
				d_i = panelsubmatrix(d,i,info)		

			/* Hazard function at each random effect quadrature points */

				assoc1 = J(nmeas[i,1],cols(nodes_i),0)
				alpha_ith = 1
				
				if (st_global("current")=="yes") {
					assoc1 = assocmat_i[,alpha_ith] :* ((X_dm_surv_i * betas_fixed) :+ (Z_dm_surv_i * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("deriv")=="yes") {
					diff_X_dm_surv_i = panelsubmatrix(diff_X_dm_surv,i,info)
					diff_Z_dm_surv_i = panelsubmatrix(diff_Z_dm_surv,i,info)
					assoc1 = assoc1 :+ assocmat_i[,alpha_ith] :* ((diff_X_dm_surv_i * betas_fixed) :+ (diff_Z_dm_surv_i * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}
				
				if (st_global("intassoc")=="yes") {
					assoc1 = assoc1 :+ assocmat_i[,alpha_ith]:*(betas_fixed[rows(betas_fixed),] :+ J(nmeas[i,1],1,nodes_i[nres,.]))
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("timeassoc")=="yes") {					/* Check index of surv_betas_fixed */
					timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
					time_assoc_ind = st_matrix("timeassoc_re_ind")
					for(m=1; m<=ntimeassoc; m++) {
						assoc1 = assoc1 :+ assocmat_i[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(nmeas[i,1],1,nodes_i[time_assoc_ind[m,1],.]))
						alpha_ith = alpha_ith :+ 1
					}	
				}
				
				haz = (lambda_mat_i:*exp(assoc1)):^d_i
		
		
			/* Cumulative hazard */
				
				surv = J(nmeas[i,1],cols(nodesfinal),.)
				knewnodes_i = panelsubmatrix(knewnodes,i,info)	
				kweights_i = panelsubmatrix(kweights,i,info)

				for (q=1;q<=nmeas[i,1];q++) {
					
					beta_mat = J(1,cols(nodesfinal),betas_fixed)
					beta_mat[rand_ind_gk,] = beta_mat[rand_ind_gk,] :+ nodes_i			// adds GH nodes_i to appropriate betas_fixed_i 
										
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
						assoc_ch = assoc_ch :+ (assocmat_i[q,alpha_ith]:* beta_mat[rows(beta_mat),])
						alpha_ith = alpha_ith :+ 1
					}
					
					if (st_global("timeassoc")=="yes") {
						for(p=1; p<=ntimeassoc; p++) {
							assoc_ch = assoc_ch :+ assocmat_i[q,alpha_ith]:*beta_mat[timeassoc_fixed_ind[p,1],]
							alpha_ith = alpha_ith :+ 1
						}
					}
					
					haz_nodes = lambda_mat_i[q,]:*exp(assoc_ch)
					cumhaz = kweights_i[q,] * haz_nodes		
					surv[q,] = exp(-cumhaz)

				}				
			
				survlike = haz:*surv

				/* Longitudinal likelihood */
					y_ij_i = panelsubmatrix(y_ij,i,info)
					linpred = panelsubmatrix(intercept,i,info) :+ (Z_dm_i * nodes_i)
					longlike = normalden(y_ij_i,linpred,sdresidual)
		
				/* Final joint likelihood */
					longlike = exp(quadcolsum(log(longlike)))
					survlike = exp(quadcolsum(log(survlike)))
					phi = diagonal((det(2:*pi() :*vcv)):^(-0.5) :* exp( (-1:/2) :* (nodes_i' * invsym(vcv)* nodes_i )))'
					jlnodes[i,.] = newweights:*longlike:*survlike:*phi						
		
		}
				
		for(i=1;i<=N;i++) {
				
			like_j = quadrowsum(jlnodes)
			mu_j_s2 = J(1,nres,.)
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(asarray(aghnodes,i)[j,.] :* jlnodes[i,.])
				mu_j_s2[1,j] = numer_like_j:/like_j[i,.]
			}
							
			nn=nres:^2
			basis1 = J(cols(jlnodes),nn,.)
			
			for (k=1;k<=cols(jlnodes);k++) {
				basis1[k,.] = rowshape(asarray(aghnodes,i)[.,k] * asarray(aghnodes,i)[.,k]',1)
			}
			
			vcv_new = ((jlnodes[i,.]:/like_j[i,.]) * basis1) :- rowshape(mu_j_s2[1,.]' * mu_j_s2[1,.],1)
			vcv_new = rowshape(vcv_new,nres)
		
			mu_j_s2 = mu_j_s2'
			nodes_i2 = mu_j_s2 :+ cholesky(vcv_new) * (sqrt(2):*nodesfinal)
			
			newweights2 = (2):^(nres:/2):*sqrt(det(vcv_new)):*exp(quadcolsum(nodesfinal:^2)) :* weightsfinal
		
			asarray(aghnodes,i,nodes_i2)
			asarray(aghweights,i,newweights2)
						
		}			
					
	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	
	
}				
end

mata:
mata set matastrict off
			void stjm_e_mata(string scalar finallnf, 				//
								string scalar s_ind, 				//
								numeric matrix y_ij,	 			//
								real scalar sdresidual, 			//
								numeric scalar N, 					//
								numeric scalar Nmeas,				//
								real scalar nres, 					//
								real scalar ntimeassoc,				//
								string scalar touse,				//
								numeric matrix intercept,			// -Evaluated longitudinal linear predictor-
								numeric matrix Z_dm,				//
								numeric matrix X_dm_surv,			//
								numeric matrix Z_dm_surv,			//
								numeric matrix diff_X_dm_surv,		//
								numeric matrix diff_Z_dm_surv,		//
								numeric matrix nodesfinal,			//
								numeric matrix weightsfinal,		//
								numeric matrix knewnodes,			//
								numeric matrix kweights,			//
								numeric matrix jlnodes,				//
								numeric matrix stime,				//
								numeric matrix d,					//
								numeric matrix betas_fixed,			//
								numeric matrix alpha_mat,			//
								transmorphic aghnodes, 				//
								transmorphic aghweights, 			//
								transmorphic gknodes, 				//
								transmorphic gknodes_deriv,			//
								numeric matrix rand_ind_gk,			// -Indicator matrix to add GH nodes to beta's for survival submodel-
								real scalar gen_nodes, 				//
								real scalar firstit,				//
								real scalar adaptit,				//
								numeric matrix info,				// -Panel matrix set-up-
								numeric matrix nmeas,				// -Number of measurements per panel-
								real scalar ngk,					// -Number of GK nodes-
								numeric matrix lambda_mat,			// -Scale parameter for survival submodel-
								numeric matrix vcv)					// -Variance-covariance matrix of random effects-
														
{

		st_view(final=.,.,finallnf,s_ind)
		
	/*************************************************************************************************************************************************/
	/* Loop over patients */

		for (i=1; i<=rows(info); i++) {
			
			/* Patient level transformation of node and weight matrices */
					
				nodes_i = asarray(aghnodes,i)
				newweights = asarray(aghweights,i)
				
				/* Can move hazard and final survival calc's to outside loop */				

			/* Data */
			
				Z_dm_i = panelsubmatrix(Z_dm,i,info)
				X_dm_surv_i = panelsubmatrix(X_dm_surv,i,info)
				Z_dm_surv_i = panelsubmatrix(Z_dm_surv,i,info)
				lambda_mat_i = panelsubmatrix(lambda_mat,i,info)
				assocmat_i = panelsubmatrix(alpha_mat,i,info)
				stime_i = panelsubmatrix(stime,i,info)
				d_i = panelsubmatrix(d,i,info)		

			/* Hazard function at each random effect quadrature points */

				assoc1 = J(nmeas[i,1],cols(nodes_i),0)
				alpha_ith = 1
				
				if (st_global("current")=="yes") {
					assoc1 = assocmat_i[,alpha_ith] :* ((X_dm_surv_i * betas_fixed) :+ (Z_dm_surv_i * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("deriv")=="yes") {
					diff_X_dm_surv_i = panelsubmatrix(diff_X_dm_surv,i,info)
					diff_Z_dm_surv_i = panelsubmatrix(diff_Z_dm_surv,i,info)
					assoc1 = assoc1 :+ assocmat_i[,alpha_ith] :* ((diff_X_dm_surv_i * betas_fixed) :+ (diff_Z_dm_surv_i * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}
				
				if (st_global("intassoc")=="yes") {
					assoc1 = assoc1 :+ assocmat_i[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:+J(nmeas[i,1],1,nodes_i[nres,.]))
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("timeassoc")=="yes") {					/* Check index of surv_betas_fixed */
					timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
					time_assoc_ind = st_matrix("timeassoc_re_ind")
					for(m=1; m<=ntimeassoc; m++) {
						assoc1 = assoc1 :+ assocmat_i[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(nmeas[i,1],1,nodes_i[time_assoc_ind[m,1],.]))
						alpha_ith = alpha_ith :+ 1
					}	
				}
				
				haz = (lambda_mat_i:*exp(assoc1)):^d_i
		

			/* Cumulative hazard */
				
				surv = J(nmeas[i,1],cols(nodesfinal),.)
				knewnodes_i = panelsubmatrix(knewnodes,i,info)	
				kweights_i = panelsubmatrix(kweights,i,info)
				
				for (q=1;q<=nmeas[i,1];q++) {
				
					beta_mat = J(1,cols(nodesfinal),betas_fixed)
					beta_mat[rand_ind_gk,] = beta_mat[rand_ind_gk,] :+ nodes_i			// adds GH nodes_i to appropriate betas_fixed_i 
					
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
					
					haz_nodes = lambda_mat_i[q,]:*exp(assoc_ch)
					cumhaz = kweights_i[q,] * haz_nodes		
					surv[q,] = exp(-cumhaz)
				}				
			
				survlike = haz:*surv
	
				/* Longitudinal likelihood */
					y_ij_i = panelsubmatrix(y_ij,i,info)
					linpred = panelsubmatrix(intercept,i,info) :+ (Z_dm_i * nodes_i)
					longlike = normalden(y_ij_i,linpred,sdresidual)
		
				/* Final joint likelihood */
					longlike = exp(quadcolsum(log(longlike)))
					survlike = exp(quadcolsum(log(survlike)))
					phi = diagonal((det(2:*pi() :*vcv)):^(-0.5) :* exp( (-1:/2) :* (nodes_i' * invsym(vcv)* nodes_i )))'
					jlnodes[i,.] = newweights:*longlike:*survlike:*phi						
		
		}

		
	final[.,.] = quadrowsum(jlnodes)		
	
		
		
	if (gen_nodes == 1 & firstit>0 & firstit<adaptit) {
	
		for(i=1;i<=N;i++) {
				
			like_j = quadrowsum(jlnodes)
			mu_j_s2 = J(1,nres,.)
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(asarray(aghnodes,i)[j,.] :* jlnodes[i,.])
				mu_j_s2[1,j] = numer_like_j:/like_j[i,.]
				
			}
							
			nn=nres:^2
			basis1 = J(cols(jlnodes),nn,.)
			
			for (k=1;k<=cols(jlnodes);k++) {
				basis1[k,.] = rowshape(asarray(aghnodes,i)[.,k] * asarray(aghnodes,i)[.,k]',1)
			}
			
			vcv_new = ((jlnodes[i,.]:/like_j[i,.]) * basis1) :- rowshape(mu_j_s2[1,.]' * mu_j_s2[1,.],1)
			vcv_new = rowshape(vcv_new,nres)
		
			mu_j_s2 = mu_j_s2'
			nodes_i2 = mu_j_s2 :+ cholesky(vcv_new) * (sqrt(2):*nodesfinal)
			
			newweights2 = (2):^(nres:/2):*sqrt(det(vcv_new)):*exp(quadcolsum(nodesfinal:^2)) :* weightsfinal
			
			asarray(aghnodes,i,nodes_i2)
			asarray(aghweights,i,newweights2)
						
		}			
					
	}
	
	if (firstit==adaptit) {
		stata(`"di"')
		stata(`"di in yellow "-> No longer updating quadrature node locations""')
		stata(`"di"')
		firstit = firstit:+1
	}
	
	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	
	
}				
end



mata:
mata set matastrict off
			void stjm_e_mata_init_quick( 					//
						string scalar s_ind, 				//
						numeric matrix y_ij,	 			//
						real scalar sdresidual, 			//
						numeric scalar N, 					//
						numeric scalar Nmeas,				//
						real scalar nres, 					//
						real scalar ntimeassoc,				//
						string scalar touse,				//
						numeric matrix intercept,			//
						numeric matrix Z_dm,				//
						numeric matrix X_dm_surv,			//
						numeric matrix Z_dm_surv,			//
						numeric matrix diff_X_dm_surv,		//
						numeric matrix diff_Z_dm_surv,		//
						numeric matrix nodesfinal,			//
						numeric matrix weightsfinal,		//
						numeric matrix knewnodes,			//
						numeric matrix kweights,			//
						numeric matrix jlnodes,				//
						numeric matrix stime,				//
						numeric matrix d,					//
						numeric matrix betas_fixed,			//
						numeric matrix alpha_mat,			//
						transmorphic aghnodes, 				//
						transmorphic aghweights, 			//
						transmorphic gknodes, 				//
						transmorphic gknodes_deriv,			//
						numeric matrix rand_ind_gk,			//
						real scalar gen_nodes,				//
						numeric matrix info,				// -Panel matrix set-up-
						numeric matrix nmeas,				// -Number of measurements per panel-
						real scalar ngk,					// -Number of GK nodes-
						numeric matrix lambda_mat,			// -Scale parameter for survival submodel-
						numeric matrix vcv)					// -Variance-covariance matrix of random effects-
														
{

	/*************************************************************************************************************************************************/
	/* Loop over patients */

	for (i=1; i<=rows(info); i++) {
			
			/* Patient level transformation of node and weight matrices */
					
				nodes_i = asarray(aghnodes,i)
				newweights = asarray(aghweights,i)
				
				/* Can move hazard and final survival calc's to outside loop */				

			/* Data */
			
				Z_dm_i = panelsubmatrix(Z_dm,i,info)

			/* Hazard function at each random effect quadrature points */

				assoc1 = J(1,cols(nodes_i),0)
				alpha_ith = 1
				
				if (st_global("current")=="yes") {
					assoc1 = alpha_mat[i,alpha_ith] :* ((X_dm_surv[i,] * betas_fixed) :+ (Z_dm_surv[i,] * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("deriv")=="yes") {
					assoc1 = assoc1 :+ alpha_mat[i,alpha_ith] :* ((diff_X_dm_surv[i,] * betas_fixed) :+ (diff_Z_dm_surv[i,] * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}
				
				if (st_global("intassoc")=="yes") {
					assoc1 = assoc1 :+ alpha_mat[i,alpha_ith]:*(betas_fixed[rows(betas_fixed),] :+ nodes_i[nres,.])
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("timeassoc")=="yes") {					/* Check index of surv_betas_fixed */
					timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
					time_assoc_ind = st_matrix("timeassoc_re_ind")
					for(m=1; m<=ntimeassoc; m++) {
						assoc1 = assoc1 :+ alpha_mat[i,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+nodes_i[time_assoc_ind[m,1],.])
						alpha_ith = alpha_ith :+ 1
					}	
				}
				
				haz = (lambda_mat[i,]:*exp(assoc1)):^d[i,]
		
		
			/* Cumulative hazard */
				
				surv = J(1,cols(nodesfinal),.)
				
					beta_mat = J(1,cols(nodesfinal),betas_fixed)
					beta_mat[rand_ind_gk,] = beta_mat[rand_ind_gk,] :+ nodes_i			// adds GH nodes_i to appropriate betas_fixed_i 
				
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
						assoc_ch = assoc_ch :+ (alpha_mat[i,alpha_ith] :* beta_mat[rows(beta_mat),])
						alpha_ith = alpha_ith :+ 1
					}
					
					if (st_global("timeassoc")=="yes") {
						for(p=1; p<=ntimeassoc; p++) {
							assoc_ch = assoc_ch :+ alpha_mat[i,alpha_ith]:*beta_mat[timeassoc_fixed_ind[p,1],]
							alpha_ith = alpha_ith :+ 1
						}
					}
				
					haz_nodes = lambda_mat[i,]:*exp(assoc_ch)
					cumhaz = kweights[i,] * haz_nodes
					surv = exp(-cumhaz)
			
				survlike = haz:*surv

				/* Longitudinal likelihood */
					y_ij_i = panelsubmatrix(y_ij,i,info)
					linpred = panelsubmatrix(intercept,i,info) :+ (Z_dm_i * nodes_i)
					longlike = normalden(y_ij_i,linpred,sdresidual)
		
				/* Final joint likelihood */
					longlike = exp(quadcolsum(log(longlike)))
					phi = diagonal((det(2:*pi() :*vcv)):^(-0.5) :* exp( (-1:/2) :* (nodes_i' * invsym(vcv)* nodes_i )))'
					jlnodes[i,.] = newweights:*longlike:*survlike:*phi						
		
		}
			
		for(i=1;i<=N;i++) {
				
			like_j = quadrowsum(jlnodes)
			mu_j_s2 = J(1,nres,.)
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(asarray(aghnodes,i)[j,.] :* jlnodes[i,.])
				mu_j_s2[1,j] = numer_like_j:/like_j[i,.]
			}
							
			nn=nres:^2
			basis1 = J(cols(jlnodes),nn,.)
			
			for (k=1;k<=cols(jlnodes);k++) {
				basis1[k,.] = rowshape(asarray(aghnodes,i)[.,k] * asarray(aghnodes,i)[.,k]',1)
			}
			
			vcv_new = ((jlnodes[i,.]:/like_j[i,.]) * basis1) :- rowshape(mu_j_s2[1,.]' * mu_j_s2[1,.],1)
			vcv_new = rowshape(vcv_new,nres)
		
			mu_j_s2 = mu_j_s2'
			nodes_i2 = mu_j_s2 :+ cholesky(vcv_new) * (sqrt(2):*nodesfinal)
			
			newweights2 = (2):^(nres:/2):*sqrt(det(vcv_new)):*exp(quadcolsum(nodesfinal:^2)) :* weightsfinal
		
			asarray(aghnodes,i,nodes_i2)
			asarray(aghweights,i,newweights2)
						
		}			
					
	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	
	
}				
end

mata:
mata set matastrict off
			void stjm_e_mata_quick(string scalar finallnf,	//
						string scalar s_ind, 				//
						numeric matrix y_ij,	 			//
						real scalar sdresidual, 			//
						numeric scalar N, 					//
						numeric scalar Nmeas,				//
						real scalar nres, 					//
						real scalar ntimeassoc,				//
						string scalar touse,				//
						numeric matrix intercept,			//
						numeric matrix Z_dm,				//
						numeric matrix X_dm_surv,			//
						numeric matrix Z_dm_surv,			//
						numeric matrix diff_X_dm_surv,		//
						numeric matrix diff_Z_dm_surv,		//
						numeric matrix nodesfinal,			//
						numeric matrix weightsfinal,		//
						numeric matrix knewnodes,			//
						numeric matrix kweights,			//
						numeric matrix jlnodes,				//
						numeric matrix stime,				//
						numeric matrix d,					//
						numeric matrix betas_fixed,			//
						numeric matrix alpha_mat,			//
						transmorphic aghnodes, 				//
						transmorphic aghweights, 			//
						transmorphic gknodes, 				//
						transmorphic gknodes_deriv,			//
						numeric matrix rand_ind_gk,			//
						real scalar gen_nodes,				//
						real scalar firstit,				//
						real scalar adaptit,
						numeric matrix info,				// -Panel matrix set-up-
						numeric matrix nmeas,				// -Number of measurements per panel-
						real scalar ngk,					// -Number of GK nodes-
						numeric matrix lambda_mat,			// -Scale parameter for survival submodel-
						numeric matrix vcv)					// -Variance-covariance matrix of random effects-

												
{

	st_view(final=.,.,finallnf,s_ind)

	/*************************************************************************************************************************************************/
	/* Loop over patients */

	for (i=1; i<=rows(info); i++) {
			
			/* Patient level transformation of node and weight matrices */
					
				nodes_i = asarray(aghnodes,i)
				newweights = asarray(aghweights,i)
				
				/* Can move hazard and final survival calc's to outside loop */				

			/* Data */
			
				Z_dm_i = panelsubmatrix(Z_dm,i,info)

			/* Hazard function at each random effect quadrature points */

				assoc1 = J(1,cols(nodes_i),0)
				alpha_ith = 1
				
				if (st_global("current")=="yes") {
					assoc1 = alpha_mat[i,alpha_ith] :* ((X_dm_surv[i,] * betas_fixed) :+ (Z_dm_surv[i,] * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("deriv")=="yes") {
					assoc1 = assoc1 :+ alpha_mat[i,alpha_ith] :* ((diff_X_dm_surv[i,] * betas_fixed) :+ (diff_Z_dm_surv[i,] * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}
				
				if (st_global("intassoc")=="yes") {
					assoc1 = assoc1 :+ alpha_mat[i,alpha_ith]:*(betas_fixed[rows(betas_fixed),] :+ nodes_i[nres,.])
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("timeassoc")=="yes") {					/* Check index of surv_betas_fixed */
					timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
					time_assoc_ind = st_matrix("timeassoc_re_ind")
					for(m=1; m<=ntimeassoc; m++) {
						assoc1 = assoc1 :+ alpha_mat[i,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+nodes_i[time_assoc_ind[m,1],.])
						alpha_ith = alpha_ith :+ 1
					}	
				}
				
				haz = (lambda_mat[i,]:*exp(assoc1)):^d[i,]
		
		
			/* Cumulative hazard */
				
				surv = J(1,cols(nodesfinal),.)
				
					beta_mat = J(1,cols(nodesfinal),betas_fixed)
					beta_mat[rand_ind_gk,] = beta_mat[rand_ind_gk,] :+ nodes_i			// adds GH nodes_i to appropriate betas_fixed_i 
				
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
						assoc_ch = assoc_ch :+ (alpha_mat[i,alpha_ith] :* beta_mat[rows(beta_mat),])
						alpha_ith = alpha_ith :+ 1
					}
					
					if (st_global("timeassoc")=="yes") {
						for(p=1; p<=ntimeassoc; p++) {
							assoc_ch = assoc_ch :+ alpha_mat[i,alpha_ith]:*beta_mat[timeassoc_fixed_ind[p,1],]
							alpha_ith = alpha_ith :+ 1
						}
					}
				
					haz_nodes = lambda_mat[i,]:*exp(assoc_ch)
					cumhaz = kweights[i,] * haz_nodes
					surv = exp(-cumhaz)
			
				survlike = haz:*surv

				/* Longitudinal likelihood */
					y_ij_i = panelsubmatrix(y_ij,i,info)
					linpred = panelsubmatrix(intercept,i,info) :+ (Z_dm_i * nodes_i)
					longlike = normalden(y_ij_i,linpred,sdresidual)
		
				/* Final joint likelihood */
					longlike = exp(quadcolsum(log(longlike)))
					phi = diagonal((det(2:*pi() :*vcv)):^(-0.5) :* exp( (-1:/2) :* (nodes_i' * invsym(vcv)* nodes_i )))'
					jlnodes[i,.] = newweights:*longlike:*survlike:*phi						
		
		}
		
	final[.,.] = quadrowsum(jlnodes)		
		
	if (gen_nodes == 1 & firstit>0 & firstit<adaptit) {
	
		for(i=1;i<=N;i++) {
				
			like_j = quadrowsum(jlnodes)
			mu_j_s2 = J(1,nres,.)
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(asarray(aghnodes,i)[j,.] :* jlnodes[i,.])
				mu_j_s2[1,j] = numer_like_j:/like_j[i,.]
			}
							
			nn=nres:^2
			basis1 = J(cols(jlnodes),nn,.)
			
			for (k=1;k<=cols(jlnodes);k++) {
				basis1[k,.] = rowshape(asarray(aghnodes,i)[.,k] * asarray(aghnodes,i)[.,k]',1)
			}
			
			vcv_new = ((jlnodes[i,.]:/like_j[i,.]) * basis1) :- rowshape(mu_j_s2[1,.]' * mu_j_s2[1,.],1)
			vcv_new = rowshape(vcv_new,nres)
		
			mu_j_s2 = mu_j_s2'
			nodes_i2 = mu_j_s2 :+ cholesky(vcv_new) * (sqrt(2):*nodesfinal)
			
			newweights2 = (2):^(nres:/2):*sqrt(det(vcv_new)):*exp(quadcolsum(nodesfinal:^2)) :* weightsfinal
		
			asarray(aghnodes,i,nodes_i2)
			asarray(aghweights,i,newweights2)
						
		}			
	}
	
	if (firstit==adaptit) {
		stata(`"di"')
		stata(`"di in yellow "-> No longer updating quadrature node locations""')
		stata(`"di"')
		firstit = firstit:+1
	}

	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	
	
}				
end

