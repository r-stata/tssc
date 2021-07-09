*! version 1.3.1 11aug2012

program stjm11_d0_fpm
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
	
	tempvar xb dxb
	mleval `xb' 		= `b', eq(`eq_num')							/* linear predictor of survival submodel */
	local `++eq_num'
	mleval `dxb'		= `b', eq(`eq_num')							/* spline derivatives */

	if $del_entry==1 {
		local `++eq_num'
		tempvar xb0
		mleval `xb0' 	= `b', eq(`eq_num')							/* delayed entry */
	}	
	
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

	/* Execute Mata program to evaluate likelihood contributions at each node */
	mata: betas_fixed 	= st_matrix("`newbetamat'")								// Pass longitudinal beta's
	mata: intercept 	= st_data(.,"`intercept'",st_global("touse"))			// Pass evaluated longitudinal linear predictor
	mata: alpha_mat 	= st_data(.,tokens(st_local("assocmlnames")),st_global("touse"))		// Pass association matrix
		
		if ("$rescale"=="0"){
			mata stjm_fpm_mata_init(st_global("surv_indlab"),	///
							y_ij,								///
							"`xb'",								///
							"`dxb'", 							///
							st_numscalar("`s_e'"),				///
							N, 									///
							Nmeas,								///
							nres,								///
							st_numscalar("`n_assoc_time'"),		///
							st_global("touse"),					///
							intercept,X_dm_surv,				///
							Z_dm,Z_dm_surv,						///
							diff_X_dm,diff_X_dm_surv,			///
							diff_Z_dm,diff_Z_dm_surv,			///
							diff2_X_dm_surv,					///
							diff2_Z_dm_surv,					///
							nodesfinal,weightsfinal,			///
							jlnodes,stime,d,					///
							betas_fixed,						///
							alpha_mat,"`xb0'",aghnodes,aghweights,`gen_nodes',info,nmeas,st_matrix("vcv"))	
			global rescale 1
		}
		
		mata stjm_fpm_mata("`finallnf2'",						///
							st_global("surv_indlab"),			///
							y_ij,								///
							"`xb'",								///
							"`dxb'", 							///
							st_numscalar("`s_e'"),				///
							N, 									///
							Nmeas,								///
							nres,								///
							st_numscalar("`n_assoc_time'"),		///
							st_global("touse"),					///
							intercept,X_dm_surv,				///
							Z_dm,Z_dm_surv,						///
							diff_X_dm,diff_X_dm_surv,			///
							diff_Z_dm,diff_Z_dm_surv,			///
							diff2_X_dm_surv,					///
							diff2_Z_dm_surv,					///
							nodesfinal,weightsfinal,			///
							jlnodes,stime,d,					///
							betas_fixed,						///
							alpha_mat,"`xb0'",aghnodes,aghweights,`gen_nodes',firstit,adaptit,info,nmeas,st_matrix("vcv"))
		
	mlsum `lnf' = ln(`finallnf2') if $surv_indlab==1
	
*}
	
end

/*** MATA CODE ***/
mata:
mata set matastrict off
		 void stjm_fpm_mata_init(							//
						string scalar s_ind, 				//
						numeric matrix y_ij,	 			//
						string scalar xb1, 					//
						string scalar dxb1, 				//
						real scalar sdresidual, 			//
						numeric scalar N, 					//
						numeric scalar Nmeas,				//
						real scalar nres, 					//
						real scalar ntimeassoc,				//
						string scalar touse,				//
						numeric matrix intercept,			//
						numeric matrix X_dm_surv,			//
						numeric matrix Z_dm,				//
						numeric matrix Z_dm_surv,			//
						numeric matrix diff_X_dm,			//
						numeric matrix diff_X_dm_surv,		//
						numeric matrix diff_Z_dm,			//
						numeric matrix diff_Z_dm_surv,		//
						numeric matrix diff2_X_dm_surv,		//
						numeric matrix diff2_Z_dm_surv,		//
						numeric matrix nodesfinal,			//
						numeric matrix weightsfinal,		//
						numeric matrix jlnodes,				//
						numeric matrix stime,				//
						numeric matrix d,					//
						numeric matrix betas_fixed,			//
						numeric matrix alpha_mat,			//
						string scalar xb0,					//
						transmorphic aghnodes, 				//
						transmorphic aghweights,			//
						real scalar gen_nodes,				//
						numeric matrix info,				// -Panel matrix set-up-
						numeric matrix nmeas,				// -Scale parameter for survival submodel-
						numeric matrix vcv)					// -Number of measurements per panel-

 			
{
		
	/*************************************************************************************************************************************************/
	/* Data */

		xb_mat1 = st_data(.,xb1,touse)												/* spline variables */
		dxb_mat1 = st_data(.,dxb1,touse)											/* differential of splines */
		xb0_mat1 = st_data(.,xb0,touse)
		st_view(delstime=.,.,"_t0",touse)
	/*************************************************************************************************************************************************/
	/* Loop over patients */

		for (i=1; i<=rows(info); i++) {
			
			/* Patient level transformation of node and weight matrices */
			
				nodes_i = asarray(aghnodes,i)
				newweights = asarray(aghweights,i)
			
			/* Data */
			
				Z_dm_i = panelsubmatrix(Z_dm,i,info)
				X_dm_surv_i = panelsubmatrix(X_dm_surv,i,info)
				Z_dm_surv_i = panelsubmatrix(Z_dm_surv,i,info)
				diff_X_dm_surv_i = panelsubmatrix(diff_X_dm_surv,i,info)
				diff_Z_dm_surv_i = panelsubmatrix(diff_Z_dm_surv,i,info)
				xb_mat1_i = panelsubmatrix(xb_mat1,i,info)
				dxb_mat1_i = panelsubmatrix(dxb_mat1,i,info)	
				xb0_mat1_i = panelsubmatrix(xb0_mat1,i,info)
				stime_i = panelsubmatrix(stime,i,info)
				delstime_i = panelsubmatrix(delstime,i,info)
				d_i = panelsubmatrix(d,i,info)		
				assocmat_i = panelsubmatrix(alpha_mat,i,info)
			
			/* Survival likelihood */
			
				assoc1 = assoc2 = assoc1_del = J(nmeas[i,1],cols(nodes_i),0)
				alpha_ith = 1
				if (st_global("current")=="yes") {
					assoc1 = assocmat_i[,alpha_ith] :* (X_dm_surv_i * betas_fixed :+ (Z_dm_surv_i * nodes_i))
					assoc2 = assocmat_i[,alpha_ith] :* (diff_X_dm_surv_i * betas_fixed :+ (diff_Z_dm_surv_i * nodes_i))
					assoc1_del = assocmat_i[,alpha_ith] :* (panelsubmatrix(intercept,i,info) :+ (Z_dm_i * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("deriv")=="yes") {
					diff2_X_dm_surv_i = panelsubmatrix(diff2_X_dm_surv,i,info)
					diff2_Z_dm_surv_i = panelsubmatrix(diff2_Z_dm_surv,i,info)
					diff_X_dm_i = panelsubmatrix(diff_X_dm,i,info)
					diff_Z_dm_i = panelsubmatrix(diff_Z_dm,i,info)
					assoc1 		= assoc1 	 :+ assocmat_i[,alpha_ith] :* (diff_X_dm_surv_i * betas_fixed :+ (diff_Z_dm_surv_i * nodes_i))
					assoc2 		= assoc2 	 :+ assocmat_i[,alpha_ith] :* (diff2_X_dm_surv_i * betas_fixed :+ (diff2_Z_dm_surv_i * nodes_i))
					assoc1_del 	= assoc1_del :+ assocmat_i[,alpha_ith] :* (diff_X_dm_i * betas_fixed :+ (diff_Z_dm_i * nodes_i))
					alpha_ith 	= alpha_ith  :+ 1
				}
			
				if (st_global("intassoc")=="yes") {
					assoc1 = assoc1 :+ assocmat_i[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:+J(nmeas[i,1],1,nodes_i[nres,.]))
					assoc1_del = assoc1_del :+ assocmat_i[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:+J(nmeas[i,1],1,nodes_i[nres,.]))
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("timeassoc")=="yes") {
					timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
					time_assoc_ind = st_matrix("timeassoc_re_ind")
					for(m=1; m<=rows(time_assoc_ind); m++) {
						assoc1 = assoc1 :+ assocmat_i[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(nmeas[i,1],1,nodes_i[time_assoc_ind[m,1],]))
						assoc1_del = assoc1_del :+ assocmat_i[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(nmeas[i,1],1,nodes_i[time_assoc_ind[m,1],]))
						alpha_ith = alpha_ith :+ 1
					}	
				}
		
				haz = (exp(xb_mat1_i:+assoc1):*((dxb_mat1_i:/stime_i):+assoc2)):^d_i
				surv = exp(-exp(xb_mat1_i:+assoc1) :+ (exp(xb0_mat1_i:+assoc1_del) :* (delstime_i:>0)))
				survlike = haz:*surv	
		
			/* Longitudinal likelihood */
		
				y_ij_i = panelsubmatrix(y_ij,i,info)
			
				linpred = panelsubmatrix(intercept,i,info) :+ (Z_dm_i * nodes_i)
				longlike = normalden(y_ij_i,linpred,sdresidual)
			
			/* Final joint likelihood */
			
				longlike = exp(quadcolsum(log(longlike),1))
				survlike = exp(quadcolsum(log(survlike),1))
				
				phi = diagonal((det(2:*pi() :*vcv)):^(-0.5) :* exp((-1:/2) :* (nodes_i' * invsym(vcv)* nodes_i )))'

				jlnodes[i,.] = newweights:*longlike:*survlike:*phi
				
		}	
	
		for(i=1;i<=N;i++) {
				
			like_j = quadrowsum(jlnodes,1)
			mu_j_s2 = J(1,nres,.)
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(asarray(aghnodes,i)[j,.] :* jlnodes[i,.],1)
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
			
			newweights2 = (2):^(nres:/2):*sqrt(det(vcv_new)):*exp(quadcolsum(nodesfinal:^2,1)) :* weightsfinal
			
			asarray(aghnodes,i,nodes_i2)
			asarray(aghweights,i,newweights2)
			
		}			
	
	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	

}				
end


mata:
mata set matastrict off
		 void stjm_fpm_mata(string scalar finallnf, 		//
						string scalar s_ind, 				//
						numeric matrix y_ij,	 			//
						string scalar xb1, 					//
						string scalar dxb1, 				//
						real scalar sdresidual, 			//
						numeric scalar N, 					//
						numeric scalar Nmeas,				//
						real scalar nres, 					//
						real scalar ntimeassoc,				//
						string scalar touse,				//
						numeric matrix intercept,			//
						numeric matrix X_dm_surv,			//
						numeric matrix Z_dm,				//
						numeric matrix Z_dm_surv,			//
						numeric matrix diff_X_dm,			//
						numeric matrix diff_X_dm_surv,		//
						numeric matrix diff_Z_dm,			//
						numeric matrix diff_Z_dm_surv,		//
						numeric matrix diff2_X_dm_surv,		//
						numeric matrix diff2_Z_dm_surv,		//
						numeric matrix nodesfinal,			//
						numeric matrix weightsfinal,		//
						numeric matrix jlnodes,				//
						numeric matrix stime,				//
						numeric matrix d,					//
						numeric matrix betas_fixed,			//
						numeric matrix alpha_mat,			//
						string scalar xb0,					//
						transmorphic aghnodes, 				//
						transmorphic aghweights,			//
						real scalar gen_nodes,				//
						real scalar firstit,				//
						real scalar adaptit,				//
						numeric matrix info,				// -Panel matrix set-up-
						numeric matrix nmeas,				// -Scale parameter for survival submodel-
						numeric matrix vcv)
 			
{

		st_view(final=.,.,finallnf,s_ind)
		
	/*************************************************************************************************************************************************/
	/* Data */

		xb_mat1 = st_data(.,xb1,touse)												/* spline variables */
		dxb_mat1 = st_data(.,dxb1,touse)											/* differential of splines */
		xb0_mat1 = st_data(.,xb0,touse)
		st_view(delstime=.,.,"_t0",touse)
		
	/*************************************************************************************************************************************************/
	/* Loop over patients */

		for (i=1; i<=rows(info); i++) {
			
			/* Patient level transformation of node and weight matrices */
			
				nodes_i = asarray(aghnodes,i)
				newweights = asarray(aghweights,i)
			
			/* Data */
			
				Z_dm_i = panelsubmatrix(Z_dm,i,info)
				X_dm_surv_i = panelsubmatrix(X_dm_surv,i,info)
				Z_dm_surv_i = panelsubmatrix(Z_dm_surv,i,info)
				diff_X_dm_surv_i = panelsubmatrix(diff_X_dm_surv,i,info)
				diff_Z_dm_surv_i = panelsubmatrix(diff_Z_dm_surv,i,info)
				xb_mat1_i = panelsubmatrix(xb_mat1,i,info)
				dxb_mat1_i = panelsubmatrix(dxb_mat1,i,info)	
				xb0_mat1_i = panelsubmatrix(xb0_mat1,i,info)
				stime_i = panelsubmatrix(stime,i,info)
				delstime_i = panelsubmatrix(delstime,i,info)
				d_i = panelsubmatrix(d,i,info)		
				assocmat_i = panelsubmatrix(alpha_mat,i,info)
			
			/* Survival likelihood */
			
				assoc1 = assoc2 = assoc1_del = J(nmeas[i,1],cols(nodes_i),0)
				alpha_ith = 1
				if (st_global("current")=="yes") {
					assoc1 = assocmat_i[,alpha_ith] :* (X_dm_surv_i * betas_fixed :+ (Z_dm_surv_i * nodes_i))
					assoc2 = assocmat_i[,alpha_ith] :* (diff_X_dm_surv_i * betas_fixed :+ (diff_Z_dm_surv_i * nodes_i))
					assoc1_del = assocmat_i[,alpha_ith] :* (panelsubmatrix(intercept,i,info) :+ (Z_dm_i * nodes_i))
					alpha_ith = alpha_ith :+ 1
				}	

				if (st_global("deriv")=="yes") {
					diff2_X_dm_surv_i = panelsubmatrix(diff2_X_dm_surv,i,info)
					diff2_Z_dm_surv_i = panelsubmatrix(diff2_Z_dm_surv,i,info)
					diff_X_dm_i = panelsubmatrix(diff_X_dm,i,info)
					diff_Z_dm_i = panelsubmatrix(diff_Z_dm,i,info)
					assoc1 		= assoc1 	 :+ assocmat_i[,alpha_ith] :* (diff_X_dm_surv_i * betas_fixed :+ (diff_Z_dm_surv_i * nodes_i))
					assoc2 		= assoc2 	 :+ assocmat_i[,alpha_ith] :* (diff2_X_dm_surv_i * betas_fixed :+ (diff2_Z_dm_surv_i * nodes_i))
					assoc1_del 	= assoc1_del :+ assocmat_i[,alpha_ith] :* (diff_X_dm_i * betas_fixed :+ (diff_Z_dm_i * nodes_i))
					alpha_ith 	= alpha_ith  :+ 1
				}
				
				if (st_global("intassoc")=="yes") {
					assoc1 = assoc1 :+ assocmat_i[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:*J(nmeas[i,1],1,nodes_i[nres,.]))
					assoc1_del = assoc1_del :+ assocmat_i[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:*J(nmeas[i,1],1,nodes_i[nres,.]))
					alpha_ith = alpha_ith :+ 1
				}

				if (st_global("timeassoc")=="yes") {
					timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
					time_assoc_ind = st_matrix("timeassoc_re_ind")
					for(m=1; m<=rows(time_assoc_ind); m++) {
						assoc1 = assoc1 :+ assocmat_i[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(nmeas[i,1],1,nodes_i[time_assoc_ind[m,1],.]))
						assoc1_del = assoc1_del :+ assocmat_i[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(nmeas[i,1],1,nodes_i[time_assoc_ind[m,1],.]))
						alpha_ith = alpha_ith :+ 1
					}	
				}
				
				haz = (exp(xb_mat1_i:+assoc1):*((dxb_mat1_i:/stime_i):+assoc2)):^d_i
				surv = exp(-exp(xb_mat1_i:+assoc1) :+ (exp(xb0_mat1_i:+assoc1_del) :* (delstime_i:>0)))
				survlike = haz:*surv	
		
			/* Longitudinal likelihood */
		
				y_ij_i = panelsubmatrix(y_ij,i,info)
			
				linpred =  panelsubmatrix(intercept,i,info) :+ (Z_dm_i * nodes_i)
				longlike = normalden(y_ij_i,linpred,sdresidual)
			
			/* Final joint likelihood */
			
				longlike = exp(quadcolsum(log(longlike),1))
				survlike = exp(quadcolsum(log(survlike),1))
				
				phi = diagonal((det(2:*pi() :*vcv)):^(-0.5) :* exp( (-1:/2) :* (nodes_i' * invsym(vcv)* nodes_i )))'

				jlnodes[i,.] = newweights:*longlike:*survlike:*phi
				
		}	
		
		final[.,.] = quadrowsum(jlnodes,1)		

	
	if (gen_nodes == 1  & firstit>0 & firstit<adaptit) {
					
		for(i=1;i<=N;i++) {
				
			like_j = quadrowsum(jlnodes,1)
			mu_j_s2 = J(1,nres,.)
			for(j=1;j<=nres;j++) {
				numer_like_j = quadrowsum(asarray(aghnodes,i)[j,.] :* jlnodes[i,.],1)
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
			
			newweights2 = (2):^(nres:/2):*sqrt(det(vcv_new)):*exp(quadcolsum(nodesfinal:^2,1)) :* weightsfinal
			
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

