*! version 1.3.1 11aug2012

program stjm11_d0_fpm_na
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
	
*quietly{
	
	/* Tempvar. to store final joint log-likelihood */
	tempvar finallnf2	
	qui gen double `finallnf2' = .

	/* Execute Mata program to evaluate likelihood contributions at each node */
	mata: betas_fixed 	= st_matrix("`newbetamat'")								// Pass longitudinal beta's
	mata: intercept 	= st_data(.,"`intercept'",st_global("touse"))			// Pass evaluated longitudinal linear predictor
	mata: alpha_mat 	= st_data(.,tokens(st_local("assocmlnames")),st_global("touse"))		// Pass association matrix
	
		mata stjm_fpm_mata$quick("`finallnf2'",st_global("surv_indlab"),y_ij,"`xb'","`dxb'", 
							st_numscalar("`s_e'"),N,Nmeas,nres,st_numscalar("`n_assoc_time'"),
							st_global("touse"),intercept,X_dm_surv,Z_dm,Z_dm_surv,
							diff_X_dm,diff_X_dm_surv,diff_Z_dm,diff_Z_dm_surv,
							diff2_X_dm_surv,diff2_Z_dm_surv,nodesfinal,weightsfinal,
							jlnodes,stime,d,betas_fixed,alpha_mat,"`xb0'",id)
	
	mlsum `lnf' = ln(`finallnf2') if $surv_indlab==1
	
*}
	
end

/*** MATA CODE ***/

mata:
mata set matastrict off
		 void stjm_fpm_mata(string scalar finallnf, 		///
						string scalar s_ind, 				///
						numeric matrix y_ij,	 			///
						string scalar xb1, 					///
						string scalar dxb1, 				///
						real scalar sdresidual, 			///
						numeric scalar N, 					///
						numeric scalar Nmeas,				///
						real scalar nres, 					///
						real scalar ntimeassoc,				///
						string scalar touse,				///
						numeric matrix intercept,			///
						numeric matrix X_dm_surv,			///
						numeric matrix Z_dm,				///
						numeric matrix Z_dm_surv,			///
						numeric matrix diff_X_dm,			///
						numeric matrix diff_X_dm_surv,		///
						numeric matrix diff_Z_dm,			///
						numeric matrix diff_Z_dm_surv,		///
						numeric matrix diff2_X_dm_surv,		///
						numeric matrix diff2_Z_dm_surv,		///
						numeric matrix nodesfinal,			///
						numeric matrix weightsfinal,		///
						numeric matrix jlnodes,				///
						numeric matrix stime,				///
						numeric matrix d,					///
						numeric matrix betas_fixed,			///
						numeric matrix alpha_mat,			///
						string scalar xb0,					//
						numeric matrix id)
 			
{

	/*************************************************************************************************************************************************/
	/* Prelims and building node matrix */
	
		st_view(final=.,.,finallnf,s_ind)
		nodes = cholesky(st_matrix("vcv")) * nodesfinal
		
	/*************************************************************************************************************************************************/
	/* Data */

		xb_mat1 = st_data(.,xb1,touse)												/* spline variables */
		dxb_mat1 = st_data(.,dxb1,touse)											/* differential of splines */
		xb0_mat1 = st_data(.,xb0,touse)				
		st_view(delstime=.,.,"_t0",touse)
		
	/*************************************************************************************************************************************************/
	/* Survival likelihood */
		
		alpha_ith = 1
		assoc1 = assoc2 = assoc1_del = J(Nmeas,1,0)
		if (st_global("current")=="yes") {
			assoc1 = alpha_mat[,alpha_ith] :* ((X_dm_surv * betas_fixed) :+ (Z_dm_surv * nodes))
			assoc2 = alpha_mat[,alpha_ith] :* ((diff_X_dm_surv * betas_fixed) :+ (diff_Z_dm_surv * nodes))
			assoc1_del = alpha_mat[,alpha_ith] :* (intercept :+ (Z_dm * nodes))
			alpha_ith = alpha_ith :+ 1
		}
		
		if (st_global("deriv")=="yes") {
			assoc1 = assoc1 :+ alpha_mat[,alpha_ith] :* ((diff_X_dm_surv * betas_fixed) :+ (diff_Z_dm_surv * nodes))
			assoc2 = assoc2 :+ alpha_mat[,alpha_ith] :* ((diff2_X_dm_surv * betas_fixed) :+ (diff2_Z_dm_surv * nodes))
			assoc1_del = assoc1_del :+ alpha_mat[,alpha_ith] :* ((diff_X_dm * betas_fixed) :+ (diff_Z_dm * nodes))
			alpha_ith = alpha_ith :+ 1
		}
		
		if (st_global("intassoc")=="yes") {
			assoc1 = assoc1 :+ alpha_mat[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:*J(Nmeas,1,nodes[nres,.]))
			assoc1_del = assoc1_del :+ alpha_mat[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:*J(Nmeas,1,nodes[nres,.]))
			alpha_ith = alpha_ith :+ 1
		}

		if (st_global("timeassoc")=="yes") {
			timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
			time_assoc_ind = st_matrix("timeassoc_re_ind")
			for(i=1; i<=ntimeassoc; i++) {
				assoc1 = assoc1 :+ alpha_mat[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(Nmeas,1,nodes[time_assoc_ind[m,1],.]))
				assoc1_del = assoc1_del :+ alpha_mat[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(Nmeas,1,nodes[time_assoc_ind[m,1],.]))
				alpha_ith = alpha_ith :+ 1
			}	
		}

		haz = (exp(xb_mat1:+assoc1):*((dxb_mat1:/stime):+assoc2)):^d
		surv = exp(-exp(xb_mat1:+assoc1) :+ (exp(xb0_mat1:+assoc1_del) :* (delstime:>0)))
		survlike = haz:*surv
	
	/*************************************************************************************************************************************************/
	/* Longitudinal likelihood */
	
		linpred = intercept :+ (Z_dm * nodes)
		longlike = normalden(y_ij,linpred,sdresidual)
		loglike = log(longlike)
		logsurv = log(survlike)
		
		loglike2 = loglike,id
		logsurv2 = logsurv,id
		dum = dums =  J(N,cols(loglike),.)
		for (i=1; i<=N; i++) {
			x = select(loglike2,loglike2[.,cols(loglike2)]:==i)
			colsumx = quadcolsum(x,1)
			dum[i,.] = colsumx[.,(1::cols(loglike))]
			xs = select(logsurv2,logsurv2[.,cols(logsurv2)]:==i)
			colsumxs = quadcolsum(xs,1)
			dums[i,.] = colsumxs[.,(1::cols(logsurv))]
		}
		expdum=exp(dum)															/* longitudinal likelihood for each patient at each node */
		expdums = exp(dums)
	/*************************************************************************************************************************************************/
	/* Final joint likelihood */
	
		jlnodes = weightsfinal:*expdum:*expdums 								/* joint likelihood for each patient at each node */
		final[,] = quadrowsum(jlnodes,1)											/* joint likelihood for each patient */

	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	

}				
end



mata:
mata set matastrict off
		 void stjm_fpm_mata_quick(string scalar finallnf, 	///
						string scalar s_ind, 				///
						numeric matrix y_ij,	 			///
						string scalar xb1, 					///
						string scalar dxb1, 				///
						real scalar sdresidual, 			///
						numeric scalar N, 					///
						numeric scalar Nmeas,				///
						real scalar nres, 					///
						real scalar ntimeassoc,				///
						string scalar touse,				///
						numeric matrix intercept,			///
						numeric matrix X_dm_surv,			///
						numeric matrix Z_dm,				///
						numeric matrix Z_dm_surv,			///
						numeric matrix diff_X_dm,			///
						numeric matrix diff_X_dm_surv,		///
						numeric matrix diff_Z_dm,			///
						numeric matrix diff_Z_dm_surv,		///
						numeric matrix diff2_X_dm_surv,		///
						numeric matrix diff2_Z_dm_surv,		///
						numeric matrix nodesfinal,			///
						numeric matrix weightsfinal,		///
						numeric matrix jlnodes,				///
						numeric matrix stime,				///
						numeric matrix d,					///
						numeric matrix betas_fixed,			///
						numeric matrix alpha_mat,			///
						string scalar xb0,					//
						numeric matrix id)
 			
{

	/*************************************************************************************************************************************************/
	/* Prelims and building node matrix */
	
		st_view(final=.,.,finallnf,s_ind)
		nodes = cholesky(st_matrix("vcv")) * nodesfinal
		
	/*************************************************************************************************************************************************/
	/* Data */

		xb_mat1 = st_data(.,xb1,touse)												/* spline variables */
		dxb_mat1 = st_data(.,dxb1,touse)											/* differential of splines */
		xb0_mat1 = st_data(.,xb0,touse)				
		st_view(delstime=.,.,"_t0",touse)
		
	/*************************************************************************************************************************************************/
	/* Survival likelihood */
		
		alpha_ith = 1
		assoc1 = assoc2 = assoc1_del = J(Nmeas,1,0)
		if (st_global("current")=="yes") {
			assoc1 = alpha_mat[,alpha_ith] :* ((X_dm_surv * betas_fixed) :+ (Z_dm_surv * nodes))
			assoc2 = alpha_mat[,alpha_ith] :* ((diff_X_dm_surv * betas_fixed) :+ (diff_Z_dm_surv * nodes))
			assoc1_del = alpha_mat[,alpha_ith] :* (intercept :+ (Z_dm * nodes))
			alpha_ith = alpha_ith :+ 1
		}
		
		if (st_global("deriv")=="yes") {
			assoc1 = assoc1 :+ alpha_mat[,alpha_ith] :* ((diff_X_dm_surv * betas_fixed) :+ (diff_Z_dm_surv * nodes))
			assoc2 = assoc2 :+ alpha_mat[,alpha_ith] :* ((diff2_X_dm_surv * betas_fixed) :+ (diff2_Z_dm_surv * nodes))
			assoc1_del = assoc1_del :+ alpha_mat[,alpha_ith] :* ((diff_X_dm * betas_fixed) :+ (diff_Z_dm * nodes))
			alpha_ith = alpha_ith :+ 1
		}
		
		if (st_global("intassoc")=="yes") {
			assoc1 = assoc1 :+ alpha_mat[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:*J(Nmeas,1,nodes[nres,.]))
			assoc1_del = assoc1_del :+ alpha_mat[,alpha_ith]:*(betas_fixed[rows(betas_fixed),]:*J(Nmeas,1,nodes[nres,.]))
			alpha_ith = alpha_ith :+ 1
		}

		if (st_global("timeassoc")=="yes") {
			timeassoc_fixed_ind = st_matrix("timeassoc_fixed_ind")
			time_assoc_ind = st_matrix("timeassoc_re_ind")
			for(i=1; i<=ntimeassoc; i++) {
				assoc1 = assoc1 :+ alpha_mat[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(Nmeas,1,nodes[time_assoc_ind[m,1],.]))
				assoc1_del = assoc1_del :+ alpha_mat[,alpha_ith]:*(betas_fixed[timeassoc_fixed_ind[m,1],]:+J(Nmeas,1,nodes[time_assoc_ind[m,1],.]))
				alpha_ith = alpha_ith :+ 1
			}	
		}

		haz = (exp(xb_mat1:+assoc1):*((dxb_mat1:/stime):+assoc2)):^d
		surv = exp(-exp(xb_mat1:+assoc1) :+ (exp(xb0_mat1:+assoc1_del) :* (delstime:>0)))
		survlike = haz:*surv
	
	/*************************************************************************************************************************************************/
	/* Longitudinal likelihood */
	
		linpred = intercept :+ (Z_dm * nodes)
		longlike = normalden(y_ij,linpred,sdresidual)
		loglike = log(longlike)
		logsurv = log(survlike)
		
		loglike2 = loglike,id
		logsurv2 = logsurv,id
		dum = dums =  J(N,cols(loglike),.)
		for (i=1; i<=N; i++) {
			x = select(loglike2,loglike2[.,cols(loglike2)]:==i)
			colsumx = quadcolsum(x,1)
			dum[i,.] = colsumx[.,(1::cols(loglike))]
			xs = select(logsurv2,logsurv2[.,cols(logsurv2)]:==i)
			colsumxs = quadcolsum(xs,1)
			dums[i,.] = colsumxs[.,(1::cols(logsurv))]
		}
		expdum=exp(dum)															/* longitudinal likelihood for each patient at each node */
		expdums = exp(dums)
	/*************************************************************************************************************************************************/
	/* Final joint likelihood */
	
		jlnodes = weightsfinal:*expdum:*expdums 								/* joint likelihood for each patient at each node */
		final[,] = quadrowsum(jlnodes,1)											/* joint likelihood for each patient */

	/* CRASH CODE */	
	//test = weights[1..i,2::2000]	

}				
end

