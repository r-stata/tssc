// ASSUMES Rparameterization CODES
	// 1	alpha, tau
	// 2	alpha, omega
	// 3	eta,   tau
	// 4	eta,   omega
	// 5	iota,  tau
	// 6	iota,  omega
	// 7    eta,   kappa
	// 8    phi
	// 9    ln phi
capture mata: mata drop xtmixediou_estimation()
capture mata: mata drop NR_REML_d2()
capture mata: mata drop crossProductMatrices()
capture mata: mata drop sweep_partitionK()
capture mata: mata drop Gdot_logcholG()
capture mata: mata drop Gdot_arctanG()
capture mata: mata drop Gdotdot_logcholG()
capture mata: mata drop Gdotdot_arctanG()
capture mata: mata drop IOUcov()
capture mata: mata drop Browniancov()
capture mata: mata drop Rdot_at()
capture mata: mata drop Rdotdot_at()
capture mata: mata drop Rdot_ao()
capture mata: mata drop Rdotdot_ao()
capture mata: mata drop Rdot_et()
capture mata: mata drop Rdotdot_et()
capture mata: mata drop Rdot_eo()
capture mata: mata drop Rdotdot_eo()
capture mata: mata drop Rdot_it()
capture mata: mata drop Rdotdot_it()
capture mata: mata drop Rdot_io()
capture mata: mata drop Rdotdot_io()
capture mata: mata drop Rdot_ek()
capture mata: mata drop Rdotdot_ek()
capture mata: mata drop Rdot_phi()
capture mata: mata drop Rdotdot_phi()
capture mata: mata drop Rdot_lnphi()
capture mata: mata drop Rdotdot_lnphi()
capture mata: mata drop Rconversion()
capture mata: mata drop tabulatingBeta()
capture mata: mata drop tabTheta_sigmaSq()
mata:
void xtmixediou_estimation(string vector id, string vector dependent, string vector fevars, string vector reffects, string vector time, ///
					  real scalar Rparameterization, string rowvector initialValues, string matrix scheme, string scalar singularHmethod, ///
					  string scalar tr_log, string scalar tr_trace, string scalar tr_gradient, string scalar tr_showstep, string scalar tr_hessian, ///
					  real scalar maxIterations)
{
	real scalar todo, lnf, sigmaSquared, converged, numberOfIterations, colsZ, numberOfGparas, ll_reml, iter_algorithm, type_algorithm
	real scalar errorCode, returnCode, IOU1, IOU2, numberOfPanels, numberOfObs, min_ni, max_ni, numFE, cols_b, isPositiveDefinite
	real scalar iter0start, final_sigma, final_sigmaSquared, final_alpha, final_tau, final_phi
	
	string scalar errorText
	
	real rowvector startingValues, optimizedParameters, settings, gradient, b, final_Rparameters 
	real colvector Y, idVar, timeVar, beta, final_beta
	
	real matrix Hessian, X, Z, panelInfo, varbeta, final_varbeta, table_beta, table_theta, V, algorithm
	real matrix final_G, final_arctanG
	
	transmorphic S

	// CREATE VIEWS
	st_view(idVar=., ., id)
	st_view(Y=., ., dependent)
    st_view(X=., ., tokens(fevars))
	st_view(Z=., ., tokens(reffects))
	st_view(timeVar=., ., tokens(time))
	
	startingValues =  st_matrix(initialValues)
	algorithm = st_matrix(scheme)
	
	// CONVERT THE startingValues TO THE CORRECT PARAMETERIZATION BEFORE PERFORMING OPTIMIZATION
		// IF THE IOU MODEL THE startingValues WILL ALWAYS CONTAIN logcholGstar, aLpha AND taustar
		// IF THE BROWNIAN MOTION MODEL THE startingValues WILL ALWAYS CONTAIN logcholGstar, phistar
	colsZ = cols(Z)
	numberOfGparas = 0.5*colsZ*(colsZ+1)
	optimizedParameters = startingValues
	if (Rparameterization > 1 & Rparameterization < 8) {	// IOU MODEL
		Rconversion(1, startingValues[1,numberOfGparas+1], startingValues[1,numberOfGparas+2], ///
					Rparameterization, IOU1=., IOU2=.)
		optimizedParameters[1,numberOfGparas+1] = IOU1
		optimizedParameters[1,numberOfGparas+2] = IOU2	
	}
	
	// PANEL SET-UP
	panelInfo = panelsetup(idVar,1)
	numberOfPanels = panelstats(panelInfo)[1]
	numberOfObs = panelstats(panelInfo)[2]
	min_ni = panelstats(panelInfo)[3]
	max_ni = panelstats(panelInfo)[4]

	// SETS ALL PRINTED RESULTS TO THE SCREEN AS TEXT
	displayas("text")
	
	/********************************
	          ESTIMATION 
	 ********************************/
	printf("Performing Hessian-based optimization\n")
	iter_algorithm = 1
	converged = 0
	iter0start = 1		// TO ENABLE TO ENTER WHILE LOOP WHEN iterate(0) IS SPECIFIED
	numberOfIterations = 0
	while(converged == 0 & (iter0start == 1 | numberOfIterations < maxIterations)) {
		type_algorithm = algorithm[iter_algorithm,1]
		settings = (1,Rparameterization,type_algorithm)
		maxIter_algorithm = algorithm[iter_algorithm,2]
		// IF THE NEXT maxIter_algorithm WILL EXCEED THE TOTAL NUMBER OF ITERATIONS THEN RESET maxIter_algorithm
		if (numberOfIterations+maxIter_algorithm >= maxIterations) {
			maxIter_algorithm = maxIterations - numberOfIterations - 1  
		}
		
		if (rows(algorithm) > 1) {
			if (type_algorithm ==1) {
				if (iter0start==1) {				
					printf("(setting algorithm to nr)\n")
				}
				else {
					printf("(switching algorithm to nr)\n")
				}
			}
			else if (type_algorithm ==2) {
				if (iter0start==1) {				
					printf("(setting algorithm to fs)\n")
				}
				else {
					printf("(switching algorithm to fs)\n")
				}
			}	
			else {
				if (iter0start==1) {				
					printf("(setting algorithm to ai)\n")
				}
				else {
					printf("(switching algorithm to ai)\n")
				}
			}
		}
		iter0start = 0	// SWITCH OFF THEREAFTER
		
		S = optimize_init()
		optimize_init_which(S, "min")
		optimize_init_evaluator(S, &NR_REML_d2())
		optimize_init_conv_maxiter(S, maxIter_algorithm)
		optimize_init_evaluatortype(S, "d2")
		optimize_init_params(S, optimizedParameters)
		optimize_init_argument(S, 1, X)
		optimize_init_argument(S, 2, Y)
		optimize_init_argument(S, 3, Z)
		optimize_init_argument(S, 4, panelInfo)
		optimize_init_argument(S, 5, timeVar)
		optimize_init_argument(S, 6, settings)
		optimize_init_argument(S, 7, sigmaSquared)
		optimize_init_argument(S, 8, beta)
		optimize_init_argument(S, 9, varbeta)
		optimize_init_valueid(S, "-2 x log restricted-likelihood")
		optimize_init_conv_warning(S, "off")
		optimize_init_singularHmethod(S, singularHmethod)
		optimize_init_tracelevel(S, tr_log)		
		optimize_init_trace_params(S, tr_trace)	
		optimize_init_trace_gradient(S, tr_gradient)
		optimize_init_trace_Hessian(S, tr_hessian)
        optimize_init_trace_step(S,tr_showstep)

		errorCode = _optimize(S)
		if (errorCode > 0) {
			returnCode = optimize_result_returncode(S)
			errorText =  optimize_result_errortext(S)
			printf(errorText)
			exit(error(returnCode))
		}	
		converged = optimize_result_converged(S)  
		numberOfIterations = numberOfIterations + optimize_result_iterations(S)
		optimizedParameters = optimize_result_params(S)

		iter_algorithm = iter_algorithm + 1
		if(iter_algorithm > rows(algorithm)) iter_algorithm = 1
	} // END OF while LOOP
	ll_reml = optimize_result_value(S)  
	ll_reml = -0.5*ll_reml 
	final_sigmaSquared = sigmaSquared
	final_sigma = sqrt(final_sigmaSquared)
	
	if(converged == 0) {  
		printf("Convergence not achieved\n")
		if(numberOfIterations >= maxIterations) {
			errorCode = 3360
		}
	}
	
	/*****************************************
	     CALCULATION OF STANDARD ERRORS
	*****************************************/
	// CONVERT PARAMETERS FROM logcholGstar -> G
	final_G = invvech(optimizedParameters[|1,1 \ 1,numberOfGparas|]')
	_diag(final_G,exp(diagonal(final_G)))			// CONVERTS logcholGstar TO cholGstar
	_lowertriangle(final_G)
	final_G = final_G*final_G'						// CONVERTS cholGstar TO Gstar
	final_G = final_sigmaSquared:*final_G			// CONVERTS Gstar to G
	
	// CONVERT PARAMETERS FROM G -> arctanG
	final_arctanG = final_G
		// OFF DIAGONAL TERMS
	for(row=1; row<=colsZ; row++) {
		for(col=row+1; col<=colsZ; col++) {
			final_arctanG[row,col] = atanh(final_arctanG[row,col]/sqrt(final_arctanG[row,row]*final_arctanG[col,col]))
			final_arctanG[col,row] = final_arctanG[row,col]
		}
	}
		// DIAGONAL TERMS
	_diag(final_arctanG,log(sqrt(diagonal(final_arctanG))))		

	// CONVERT R PARAMETERS TO (lnalpha,lntau,lnsigma) OR (lnphi,lnsigma)
	if (Rparameterization < 8) {	// IOU MODEL
		// IOUstar -> (alpha, taustar)
		Rconversion(Rparameterization, optimizedParameters[1,numberOfGparas+1], optimizedParameters[1,numberOfGparas+2], ///
                1, final_alpha=., final_tau=.)
		// CONVERTS taustar -> tau
		final_tau = final_tau*final_sigma				
		final_Rparameters = (final_alpha,final_tau,final_sigmaSquared)
		
		// alpha, tau, sigma -> lnalpha, lntau, lnsigma
		optimizedParameters = (vech(final_arctanG)',ln(final_alpha),ln(final_tau),ln(final_sigma))
		settings = (2,7,1)
	}
	else {	// BROWNIAN-MOTION MODEL
		final_phi = optimizedParameters[1,numberOfGparas+1]
		final_phi = final_phi*final_sigmaSquared
		final_Rparameters = (final_phi,final_sigmaSquared)
		
		// phi, sigma -> lnphi, lnsigma
		optimizedParameters = (vech(final_arctanG)',ln(final_phi),ln(final_sigma))
		settings = (2,9,1)
	}
	
	if (hasmissing(optimizedParameters)==1) {
			displayas("error")
			printf("One or more estimates of the variance parameters are invalid\n")
			exit(error(430))
	}	
	
	// CALCULATION OF COVARIANCE MATRIX FOR (vech(arctanG), ln R PARAMETERS) USING NR'S HESSIAN
	printf("\nComputing standard errors:\n")
	NR_REML_d2(0, optimizedParameters, X, Y, Z, panelInfo, timeVar, settings, sigmaSquared=., ///
	beta=., varbeta=., lnf=., gradient=., Hessian=.)
	final_beta = beta	
	final_varbeta = varbeta	// NEEDS TO BE CALCULATED BASED ON THE UNPROFILED REML  

	// b AND V FOR (beta', vech(arctanG), lnalpha, lntau, lnsigma)  
	b = (final_beta', optimizedParameters) 
	cols_b = cols(b)
	numFE = rows(final_beta)
	V = J(cols_b, cols_b, 0)
	V[|1,1 \ numFE, numFE|] = final_varbeta
	
	// TABULATE THE RESULTS FOR THE FIXED EFFECTS
	tabulatingBeta(final_beta, final_varbeta, table_beta=.)

	// TEST IF THE Hessian MATRIX IS POSITIVE DEFINITE 
	isPositiveDefinite = isPositiveDefinite(Hessian)
	if(isPositiveDefinite==-1 | isPositiveDefinite==0) {
		errorCode = 3353
		table_theta = J(cols(optimizedParameters),3,.)
		table_theta = ((vech(final_G)\final_Rparameters'), table_theta)
	}
	else {
		V[|numFE+1, numFE+1 \ cols_b, cols_b|] = 2:*invsym(Hessian)
		
		// TABULATE THE RESULTS FOR THE VARIANCE PARAMETERS
			// CALCULATES THE UNTRANSFORMED PARAMETERS
			// USES THE DELTA METHOD TO CALCULATE THE STANDARD ERRORS OF THE UNTRANSFORMED PARAMETERS
			// CALCULATES THE CIs ON THE TRANSFORMED SCALE AND THEN BACK-TRANSFORMS
		tabTheta_sigmaSq(optimizedParameters, V[|numFE+1, numFE+1 \ cols_b, cols_b|], colsZ, numberOfGparas, ///
						table_theta=.) 
	}
	
	st_rclear()
	st_numscalar("r(errorCode)", errorCode)
	st_numscalar("r(converged)", converged)
	st_numscalar("r(ll_reml)", ll_reml)
	st_numscalar("r(numberOfObs)", numberOfObs)
	st_numscalar("r(numberOfPanels)", numberOfPanels)
	st_numscalar("r(min_ni)", min_ni)
	st_numscalar("r(max_ni)", max_ni)
	
	st_matrix("r(b)", b)	
	st_matrix("r(V)", V)	
	st_matrix("r(table_beta)", table_beta)	
	st_matrix("r(table_theta)", table_theta)	
	st_matrix("r(G)", final_G)	
	st_matrix("r(Rparameters)", final_Rparameters)	
	
} // END OF FUNCTION xtmixediou_estimation()
 	
void NR_REML_d2(real scalar todo, real rowvector parameters, ///
                real matrix X, real colvector Y, real matrix Z, ///
                real matrix panelInfo, real colvector timeVar, ///
                real rowvector settings, real scalar sigmaSquared, /// 
				real colvector beta, real matrix CC_T, ///
			    real scalar lnf, real rowvector gradient, real matrix Hessian)
{
	real scalar panel, numberOfPanels, colsX, colsZ, numberOfParameters, deriv_r, deriv_s, ni, N
	real scalar numberOfGparas, numberOfWparas, numberOfRparas, minusLogDetR, lndet_augW0_part1, lndet_augWG_part1
	real scalar row_r, col_r, row_s, col_s, l2_scalar, l3_scalar
	real scalar aLpha, tau, lnsigma, triangle, iter_algorithm 
	real scalar Gparameterization, Rparameterization, maxMissing
	
	real rowvector Gparameters, Rparameters, g1, g2, g3, g2star, missing, Wparameters
	
	real colvector residuali, Yi, timeVari, l1
	
	real matrix Xi, Zi, sw1_augW0_part4, Xstari, matrix_g1, matrix_g2
	real matrix vech_sw1_augW0_part4, sum_sw1_augW0_part4, sw1_augWG_part4, WGzz, WGzr, WGxz
	real matrix cholG, invcholG, Gdot_r, Gdot_s, Gdotdot_rs
	real matrix invcholRi, invRi, Rdot_r, Rdot_s, Rdotdot_rs
	real matrix vech_H1, H1, H2, H3, M, invRZMZ_TinvR, MZ_TinvR, A1_r, A2_r, B, sum_H3rs
	real matrix vech_H2rs, Wi, timeVari_s, timeVari_t, oneMatrix, minMatrix, Gpositions, Rpositions, Vpositions

	pointer(real matrix) colvector p_matrix_H2r, p_vech_H3r, p_sum_H3r, p_Gdot, p_Gdotdot, p_invcholRi, p_Rdot, p_Rdotdot
	pointer(real matrix) colvector p_vech_H3rs
	pointer(function) rowvector fnarray_Gdot, fnarray_Gdotdot, fnarray_Rcov, fnarray_Rdot, fnarray_Rdotdot

	// EXTRACT FEATURES FROM THE DATA
	numberOfPanels = panelstats(panelInfo)[1]
	N = rows(X)
	colsX = cols(X)
	colsZ = cols(Z)
	numberOfGparas = 0.5*colsZ*(colsZ+1) // CALCULATED FROM THE TRIANGLE NUMBER SERIES
	
	// EXTRACT PARAMETERIZATION AND PARAMETERS
	Gparameterization = settings[1,1]
	Rparameterization = settings[1,2]
	iter_algorithm = settings[1,3]
	numberOfParameters = cols(parameters)
	numberOfRparas = numberOfParameters - numberOfGparas
	Gparameters = parameters[|1,1 \ 1,numberOfGparas|]
	Rparameters = parameters[|1,numberOfGparas+1 \ 1,numberOfParameters|]
		
	// EXTRACT cholG [CODE TESTED BY "xtIOU\test command\test cholGextraction for logcholGstar and arctanG parameterizations.do"
	cholG = invvech(Gparameters')
	if (Gparameterization==1) {				  // logcholGstar PARAMETERIZATION
		_diag(cholG,exp(diagonal(cholG)))    // logcholGstar -> cholGstar; EXPONENTIATE THE DIAGONAL ELEMENTS
		_lowertriangle(cholG)
		
		lnsigma = 0							// i.e.; ln(1) = 0
	}
	else {	// arctanG PARAMETERIZATION
		// arctanG -> G
		// OFF-DIAGONAL ELEMENTS
		for(row_r=1; row_r<=colsZ; row_r++) {
			for(col_r=row_r+1; col_r<=colsZ; col_r++) {
				cholG[row_r,col_r] = tanh(cholG[row_r,col_r])*exp(cholG[row_r,row_r])*exp(cholG[col_r,col_r])
				cholG[col_r,row_r] = cholG[row_r,col_r]
			}
		}	
		// DIAGONAL ELEMENTS
		_diag(cholG,exp(2:*diagonal(cholG)))

		// G -> cholG
		cholG = cholesky(cholG)
		
		lnsigma = Rparameters[1,cols(Rparameters)]
	}
	invcholG = luinv(cholG)	// MAY BE luinv(cholesky[(1/sigma^2):*G]) OR luinv(cholesky(G)) 
			
	if (Rparameterization < 8) {
		// OBTAIN aLpha AND tau (OR taustar)
		Rconversion(Rparameterization, Rparameters[1,1], Rparameters[1,2], 1, aLpha=., tau=.)
		Wparameters = (aLpha, tau)
	}
	else if (Rparameterization == 8) {
		Wparameters = Rparameters[1,1]			// phistar
	}
	else {
		Wparameters = exp(Rparameters[1,1])		// ln(phi)
	}
	numberOfWparas = cols(Wparameters)

	// INITIALIZE VECTORS AND MATRICES
	Gpositions = invvech(1::(0.5*numberOfGparas*(numberOfGparas+1)))
	Rpositions = invvech(1::(0.5*numberOfRparas*(numberOfRparas+1)))
	l1 = J(numberOfPanels,1,0)
	triangle = colsX+colsZ+1
	triangle = 0.5*triangle*(triangle+1)
	vech_sw1_augW0_part4 = J(triangle,numberOfPanels,0)
	matrix_g1 = J(numberOfPanels,numberOfParameters,0)
	matrix_g2 = J(numberOfPanels,numberOfParameters,0)
	g3 = J(1,numberOfParameters,0)
	triangle = 0.5*numberOfParameters*(numberOfParameters+1)
	Vpositions = invvech(1::triangle)
	vech_H1 = J(triangle,numberOfPanels,0)
	vech_H2rs = J(triangle,numberOfPanels,0)
	H2 = J(numberOfParameters,numberOfParameters,0)
	H3 = J(numberOfParameters,numberOfParameters,0)

	// INITIALIZE POINTERS
	p_Gdot = J(numberOfGparas,1,NULL)
	p_Gdotdot = J(0.5*numberOfGparas*(numberOfGparas+1),1,NULL)
	p_invcholRi = J(numberOfPanels,1,NULL)
	p_sum_H2r = J(numberOfParameters, 1, NULL)
	p_sum_H3r = J(numberOfParameters, 1, NULL)
	// NON-NULL POINTERS (REQUIRES A SEPARATE ZERO MATRIX FOR EACH POINTER ELEMENT)
	triangle = 0.5*colsX*(colsX+1)
	p_matrix_H2r = &(J(colsX,numberOfPanels,0))			
	p_vech_H3r = &(J(triangle,numberOfPanels,0))
	p_vech_H3rs = &(J(triangle,numberOfPanels,0))
	for(deriv_r=2; deriv_r<=numberOfParameters; deriv_r++) {
		p_vech_H3r = p_vech_H3r \ &(J(triangle,numberOfPanels,0))
		p_matrix_H2r = p_matrix_H2r \ &(J(colsX,numberOfPanels,0))
		
		for(deriv_s=1; deriv_s<=deriv_r; deriv_s++) {
			p_vech_H3rs = p_vech_H3rs \ &(J(triangle,numberOfPanels,0))
		}
	}
	// FUNCTION ARRAYS
	fnarray_Rcov = (&Browniancov(),&IOUcov())
	fnarray_Gdot = (&Gdot_logcholG(), &Gdot_arctanG())
	fnarray_Gdotdot = (&Gdotdot_logcholG(), &Gdotdot_arctanG())
	fnarray_Rdot = (&Rdot_at(), &Rdot_ao(), &Rdot_et(), &Rdot_eo(), ///
	                &Rdot_it(), &Rdot_io(), &Rdot_ek(), &Rdot_phi(), &Rdot_lnphi())					
	fnarray_Rdotdot = (&Rdotdot_at(), &Rdotdot_ao(), &Rdotdot_et(), &Rdotdot_eo(), ///
	                   &Rdotdot_it(), &Rdotdot_io(), &Rdotdot_ek(), &Rdotdot_phi(), &Rdotdot_lnphi())
	
	// GENERATE Gdot AND Gdotdot
	col_r = 1
	row_r = 0
	for(deriv_r=1; deriv_r<=numberOfGparas; deriv_r++) {
		row_r = row_r + 1
		if(row_r > colsZ) {
			col_r = col_r + 1
			row_r = col_r
		}
				
		p_Gdot[deriv_r] = &((*fnarray_Gdot[Gparameterization])(Gparameters, row_r, col_r))
		
		col_s = 1
		row_s = 0
		for(deriv_s=1; deriv_s<=deriv_r; deriv_s++) {
			row_s = row_s + 1
			if(row_s > colsZ) {
				col_s = col_s + 1
				row_s = col_s
			}
			p_Gdotdot[Gpositions[deriv_r,deriv_s]] = &((*fnarray_Gdotdot[Gparameterization])(Gparameters, row_r, col_r, row_s, col_s))
		}	// END OF deriv_s FOR-LOOP
	} // END OF deriv_r FOR-LOOP
	
	// CALCULATING lnf
	for(panel=1; panel<=numberOfPanels; panel++) {
		ni = panelInfo[panel,2] - panelInfo[panel,1] + 1

		Zi = panelsubmatrix(Z,panel,panelInfo)
		Xi = panelsubmatrix(X,panel,panelInfo)
		Yi = panelsubmatrix(Y,panel,panelInfo)
		timeVari = panelsubmatrix(timeVar,panel,panelInfo)
		
		oneMatrix = J(ni,ni,1)
		minMatrix = makesymmetric(lowertriangle(timeVari' :* oneMatrix))
		timeVari_s = timeVari :* oneMatrix 
		timeVari_t = timeVari':* oneMatrix 
		
		// GENERATE COVARIANCE MATRIX Wi
		(*fnarray_Rcov[numberOfWparas])(Wparameters, oneMatrix, timeVari_s, timeVari_t, minMatrix, Wi=.)
		
		p_invcholRi[panel] = &(luinv(cholesky(Wi + exp(2*lnsigma):*I(ni)))) 
		// POINTER MUST POINT TO CALCULATION AND NOT MATRIX CALLED invcholRi
			//(i.e. IF p_invcholRi[panel]=invcholRi THEN A PROBLEM OCCURS: CONTENTS OF POINTER CHANGES AS invcholRi CHANGES
		invcholRi = *p_invcholRi[panel]		
		invRi = cross(invcholRi,invcholRi)
		 
		/*********************************************************************
	                   WOLFINGER LIKELIHOOD CALCULATIONS	
		*********************************************************************/
		// SECTION 3 OF "check - xtIOU" SHOWS THAT THE FOLLOWING GIVES -log|R| 
		minusLogDetR = 2*quadcolsum(ln(diagonal(invcholRi)))
		
		// GENERATES MATRIX W AND THE LOG(DET(FIRST PARTITION OF AUGMENTED W0))
			// STEP 1: GENERATE CROSS-PRODUCTS MATRIX W0
			// STEP 2: GENERATE THE AUGMENTED MATRIX OF W0
			// STEP 3: SWEEP THE AUGMENTED MATRIX
			// W = C-B'A^-1B OF THE SWEEP; THE FOURTH PARTITION OF THE SWEPT MATRIX		
		crossProductMatrices(Xi, colsX, Yi, Zi, colsZ, cholG, invcholRi, lndet_augW0_part1=., sw1_augW0_part4=.)	

		// l1 = ln|I+L'*Z'*invR*Z*L| + log|R|
		//    = log|V| - log|R| + log|R|
		l1[panel] = lndet_augW0_part1 - minusLogDetR
		
		// EXITS EARLY IF ONE PANEL HAS A MISSING VALUE
		maxMissing = hasmissing(l1[panel])
		if (maxMissing==1) break
		
		// TO CALCULATE l2 AND l3 YOU MUST SUM sw1_augW0_part4 OVER THE m SUBJECTS
			// e.g. SEE THE FORMULAE GIVEN TO Lindstrom and Bates 1988
			// THE MATRIX IS SYMMETRIC
		vech_sw1_augW0_part4[,panel] = vech(sw1_augW0_part4)
	} // END OF panel FOR-LOOP

	sum_sw1_augW0_part4 = invvech(quadrowsum(vech_sw1_augW0_part4))

	// SWEEP THE APPROPRIATE SUBMATRIX OF sw1_augW0_part4 TO OBTAIN l2 AND l3
		// APPLIED TO THE sum OF SUBMATRIX OF W0
	sweep_partitionK(sum_sw1_augW0_part4[|1,1\colsX,colsX|], sum_sw1_augW0_part4[|1,1+colsX+colsZ \colsX,1+colsX+colsZ|], sum_sw1_augW0_part4[1+colsX+colsZ,1+colsX+colsZ], ///
	                 CC_T=., beta=., l2_scalar=., l3_scalar=.)

	sigmaSquared = l2_scalar/(N-colsX)
	
	if(maxMissing==0 & l2_scalar !=. & l3_scalar !=.) { 
	
		/*********************************************************************
						 WOLFINGER DERIVATIVE CALCULATIONS	
		*********************************************************************/
		for(panel=1; panel<=numberOfPanels; panel++) {
			Zi = panelsubmatrix(Z,panel,panelInfo)
			Xi = panelsubmatrix(X,panel,panelInfo)
			Yi = panelsubmatrix(Y,panel,panelInfo)
			timeVari = panelsubmatrix(timeVar,panel,panelInfo)
			invcholRi = *p_invcholRi[panel]
			invRi = cross(invcholRi,invcholRi)

			ni = rows(Yi)
			oneMatrix = J(ni,ni,1)
			minMatrix = makesymmetric(lowertriangle(timeVari' :* oneMatrix))
			timeVari_s = timeVari :* oneMatrix 
			timeVari_t = timeVari':* oneMatrix 

			// DERIVATIVES OF R
			(*fnarray_Rdot[Rparameterization])(ni, Rparameters, timeVari_s, timeVari_t, minMatrix, p_Rdot=NULL)
			(*fnarray_Rdotdot[Rparameterization])(ni, Rparameters, timeVari_s, timeVari_t, minMatrix, p_Rdotdot=NULL)
			
			Xstari = Xi*cholesky(CC_T) // SAME AS POPULATION LEVELS
			residuali = Yi-Xi*beta
			
			// DERIVATIVE CALCULATIONS USING WOLFINGER 1994	
			// GENERATE MATRIX WG	- this matrix is required for the second derivatives too.
			crossProductMatrices(Xstari, colsX, residuali, Zi, colsZ, cholG, invcholRi, lndet_augWG_part1=., sw1_augWG_part4=.)	
		
			// SUBMATRICES OF WG
			WGzz = sw1_augWG_part4[|colsX+1,colsX+1 \ colsX+colsZ,colsX+colsZ|]
			WGzr = sw1_augWG_part4[|colsX+1,colsX+colsZ+1 \ colsX+colsZ,colsX+colsZ+1|]
			WGxz = sw1_augWG_part4[|1,colsX+1 \ colsX,colsX+colsZ|]

			// DERIVATIVES W.R.T. PARAMETERS OF MATRIX G
			for(deriv_r=1; deriv_r<=numberOfGparas; deriv_r++) {
				Gdot_r = *p_Gdot[deriv_r]
			
				matrix_g1[panel,deriv_r] = trace(WGzz,Gdot_r)
				matrix_g2[panel,deriv_r] = - WGzr'*Gdot_r*WGzr
				
				(*p_matrix_H2r[deriv_r])[,panel] = WGxz*Gdot_r*WGzr 
				(*p_vech_H3r[deriv_r])[,panel] = vech(WGxz*Gdot_r*WGxz') 

				for(deriv_s=1; deriv_s<=deriv_r; deriv_s++) {
					Gdot_s = *p_Gdot[deriv_s]
					Gdotdot_rs = *p_Gdotdot[Gpositions[deriv_r,deriv_s]]

					vech_H2rs[Vpositions[deriv_r,deriv_s],panel] = 2*WGzr'*Gdot_r*WGzz*Gdot_s*WGzr - WGzr'*Gdotdot_rs*WGzr 
					
					
					(*p_vech_H3rs[Vpositions[deriv_r,deriv_s]])[,panel] = vech(2*WGxz*Gdot_r*WGzz*Gdot_s*WGxz' - WGxz*Gdotdot_rs*WGxz') 
					
					// MUST FILL IN THE LOWER TRIANGLE AS makesymmetric REFLECTS THE BELOW DIAGONAL TO ABOVE 
					// SECOND DERIVATIVES OF AN UNSTRUCTURED G MATRIX ALWAYS RESULTS IN A ZERO VECTOR
					vech_H1[Vpositions[deriv_r,deriv_s],panel] = -trace(WGzz*Gdot_r,WGzz*Gdot_s) + trace(WGzz,Gdotdot_rs)
				}	// END OF deriv_s FOR-LOOP
			}	// END OF deriv_r FOR-LOOP
			
			// DERIVATIVES W.R.T. PARAMETERS OF COVARIANCE MATRIX R
			M = luinv(cross(invcholG,invcholG) + Zi'*invRi*Zi)
			invRZMZ_TinvR = invRi*Zi*M*Zi'*invRi 
			MZ_TinvR = M*Zi'*invRi

			for(deriv_r=numberOfGparas+1; deriv_r<=numberOfParameters; deriv_r++) {
				col_r = deriv_r-numberOfGparas
				Rdot_r = *p_Rdot[col_r]
				
				(*p_matrix_H2r[deriv_r])[,panel] = Xstari'*invRi*Rdot_r*invRi*residuali ///
												  -Xstari'*invRZMZ_TinvR*Rdot_r*invRi*residuali ///
												  -Xstari'*invRi*Rdot_r*invRZMZ_TinvR*residuali ///
												  +Xstari'*invRZMZ_TinvR*Rdot_r*invRZMZ_TinvR*residuali 
				
				(*p_vech_H3r[deriv_r])[,panel] = vech(Xstari'*invRi*Rdot_r*invRi*Xstari ///
													 -Xstari'*invRZMZ_TinvR*Rdot_r*invRi*Xstari ///
													 -Xstari'*invRi*Rdot_r*invRZMZ_TinvR*Xstari ///
													 +Xstari'*invRZMZ_TinvR*Rdot_r*invRZMZ_TinvR*Xstari) 

				// GRADIENT COMPONENTS CORRESPONDING TO PARAMETERS OF R
				matrix_g1[panel,deriv_r] = trace(invRi*Rdot_r) - ///
										   trace(MZ_TinvR*Rdot_r*invRi*Zi)
						
				matrix_g2[panel,deriv_r] = -residuali'*invRi*Rdot_r*invRi*residuali ///
										   +2:*residuali'*invRZMZ_TinvR*Rdot_r*invRi*residuali ///
										   -residuali'*invRZMZ_TinvR*Rdot_r*invRZMZ_TinvR*residuali
			
				for(deriv_s=numberOfGparas+1; deriv_s<=deriv_r; deriv_s++) {
					col_s = deriv_s-numberOfGparas
					Rdot_s = *p_Rdot[col_s]
					Rdotdot_rs = *p_Rdotdot[Rpositions[col_r,col_s]]
					
					// SIMPLIFYING COMPONENTS
					vech_H2rs[Vpositions[deriv_r,deriv_s],panel] = 2:*residuali'*invRi*Rdot_r*invRi*Rdot_s*invRi*residuali ///
																  -2:*residuali'*invRZMZ_TinvR*Rdot_r*invRi*Rdot_s*invRi*residuali ///
																  -2:*residuali'*invRi*Rdot_r*invRZMZ_TinvR*Rdot_s*invRi*residuali ///
																  +2:*residuali'*invRZMZ_TinvR*Rdot_r*invRZMZ_TinvR*Rdot_s*invRi*residuali ///
																  -2:*residuali'*invRi*Rdot_r*invRi*Rdot_s*invRZMZ_TinvR*residuali ///
																  +2:*residuali'*invRZMZ_TinvR*Rdot_r*invRi*Rdot_s*invRZMZ_TinvR*residuali ///
																  +2:*residuali'*invRi*Rdot_r*invRZMZ_TinvR*Rdot_s*invRZMZ_TinvR*residuali ///
																  -2:*residuali'*invRZMZ_TinvR*Rdot_r*invRZMZ_TinvR*Rdot_s*invRZMZ_TinvR*residuali ///
																  -residuali'*invRi*Rdotdot_rs*invRi*residuali ///
																  +2:*residuali'*invRi*Rdotdot_rs*invRZMZ_TinvR*residuali ///
																  -residuali'*invRZMZ_TinvR*Rdotdot_rs*invRZMZ_TinvR*residuali

					(*p_vech_H3rs[Vpositions[deriv_r,deriv_s]])[,panel] = vech(2:*Xstari'*invRi*Rdot_r*invRi*Rdot_s*invRi*Xstari /// 
																			  -2:*Xstari'*invRZMZ_TinvR*Rdot_r*invRi*Rdot_s*invRi*Xstari ///
																			  -2:*Xstari'*invRi*Rdot_r*invRZMZ_TinvR*Rdot_s*invRi*Xstari ///
																			  +2:*Xstari'*invRZMZ_TinvR*Rdot_r*invRZMZ_TinvR*Rdot_s*invRi*Xstari ///
																			  -2:*Xstari'*invRi*Rdot_r*invRi*Rdot_s*invRZMZ_TinvR*Xstari ///
																			  +2:*Xstari'*invRZMZ_TinvR*Rdot_r*invRi*Rdot_s*invRZMZ_TinvR*Xstari ///
																			  +2:*Xstari'*invRi*Rdot_r*invRZMZ_TinvR*Rdot_s*invRZMZ_TinvR*Xstari ///
																			  -2:*Xstari'*invRZMZ_TinvR*Rdot_r*invRZMZ_TinvR*Rdot_s*invRZMZ_TinvR*Xstari ///
																			  -Xstari'*invRi*Rdotdot_rs*invRi*Xstari ///
																			  +2:*Xstari'*invRi*Rdotdot_rs*invRZMZ_TinvR*Xstari ///
																			  -Xstari'*invRZMZ_TinvR*Rdotdot_rs*invRZMZ_TinvR*Xstari)
				   
					// FILLING IN MATRIX H
					vech_H1[Vpositions[deriv_r,deriv_s],panel] = - trace(invRi*Rdot_r*invRi*Rdot_s) ///
																 + trace(MZ_TinvR*Rdot_r*invRi*Rdot_s*invRi*Zi) ///
																 + trace(MZ_TinvR*Rdot_s*invRi*Rdot_r*invRi*Zi) ///
																 - trace(MZ_TinvR*Rdot_r*invRZMZ_TinvR*Rdot_s*invRi*Zi) ///
																 + trace(invRi*Rdotdot_rs) ///
																 - trace(MZ_TinvR*Rdotdot_rs*invRi*Zi)
				}	// END OF deriv_s FOR-LOOP		
			}	// END OF deriv_r FOR-LOOP
			
			// CROSS DERIVATIVES d/dG(d/dR)
				// e.g. H1[r,s] DERIVATIVE OF L1 W.R.T. PARAMETER r FROM R AND PARAMETER s FROM G
			for(deriv_r=numberOfGparas+1; deriv_r<=numberOfGparas+numberOfRparas; deriv_r++) {
				Rdot_r = *p_Rdot[deriv_r-numberOfGparas]
			
				for(deriv_s=1; deriv_s<=numberOfGparas; deriv_s++) {
					Gdot_s = *p_Gdot[deriv_s,1]
				
					// SIMPLYFYING COMPONENTS
					A1_r = residuali'*invRi*Rdot_r*invRi*Zi ///
						  -residuali'*invRZMZ_TinvR*Rdot_r*invRi*Zi  
					A2_r = Xstari'*invRi*Rdot_r*invRi*Zi ///
						  -Xstari'*invRZMZ_TinvR*Rdot_r*invRi*Zi
					B = MZ_TinvR*Zi - I(colsZ)
					
					vech_H2rs[Vpositions[deriv_r,deriv_s],panel] = 2*A1_r*B*Gdot_s*B'*Zi'*invRi*residuali
					
					
					(*p_vech_H3rs[Vpositions[deriv_r,deriv_s]])[,panel] = vech(2*A2_r*B*Gdot_s*B'*Zi'*invRi*Xstari)
			
					// CROSS DERIVATIVES
					vech_H1[Vpositions[deriv_r,deriv_s],panel] = - trace(Zi'*invRi*Rdot_r*invRi*Zi*Gdot_s) ///
																 + 2*trace(Zi'*invRi*Rdot_r*invRi*Zi*Gdot_s*Zi'*invRi*Zi*M) ///
																 - trace(Zi'*invRi*Rdot_r*invRZMZ_TinvR*Zi*Gdot_s*Zi'*invRi*Zi*M)
				}	// END OF deriv_s FOR-LOOP		
			}	// END OF deriv_r FOR-LOOP
			
			// EXITS EARLY IF ONE PANEL HAS A MISSING VALUE
			missing = hasmissing(matrix_g1[panel,])
			missing = missing, hasmissing(matrix_g2[panel,])
			missing = missing, hasmissing(vech_H1[,panel])
			missing = missing, hasmissing(vech_H2rs[,panel])
			maxMissing = max(missing)
			if (maxMissing==1) break
			
		} // END OF panel FOR-LOOP
		
		if(maxMissing==0) { 

			H1 = invvech(quadrowsum(vech_H1))
			vech_H2rs = quadrowsum(vech_H2rs)
				
			// AVOIDS IF STATEMENTS IN THE PREVIOUS LOOP AND COLLECTS RESULTS BY LOOPING THROUGH THE PARAMETERS AGAIN
			for(deriv_r=1; deriv_r<=numberOfParameters; deriv_r++) {	
				p_sum_H2r[deriv_r] = &(quadrowsum(*p_matrix_H2r[deriv_r]))
				p_sum_H3r[deriv_r] = &(invvech(quadrowsum(*p_vech_H3r[deriv_r])))
			
				g3[deriv_r] = -trace(*p_sum_H3r[deriv_r])

				for(deriv_s=1; deriv_s<=deriv_r; deriv_s++) {	
					sum_H3rs = invvech(quadrowsum(*p_vech_H3rs[Vpositions[deriv_r,deriv_s]]))
					
					H2[deriv_r,deriv_s] = vech_H2rs[Vpositions[deriv_r,deriv_s]] - 2*(*p_sum_H2r[deriv_r]')*(*p_sum_H2r[deriv_s])
					H3[deriv_r,deriv_s] = trace(sum_H3rs - (*p_sum_H3r[deriv_r])*(*p_sum_H3r[deriv_s]))
				}	// END OF deriv_s FOR-LOOP		
			}	// END OF deriv_r FOR-LOOP
			_makesymmetric(H1) // SAVES FILLING IN THE OTHER ENTRIES
			_makesymmetric(H2) // SAVES FILLING IN THE OTHER ENTRIES
			_makesymmetric(H3) // SAVES FILLING IN THE OTHER ENTRIES

			g1 = quadcolsum(matrix_g1)
			g2 = quadcolsum(matrix_g2)
			
			// CALCULATES lnf, gradient AND THE Hessian MATRIX 	
			if(Gparameterization == 1) {		// logcholGstar AND taustar OR omegastar
				lnf = quadcolsum(l1) + (N-colsX)*log(l2_scalar) + l3_scalar ///
				      + (N-colsX) + (N-colsX)*ln(2*pi()/(N-colsX))			
				g2star = (1/sigmaSquared):*g2
				gradient = g1 + g2star + g3

				if(iter_algorithm==1) {	// NR
					Hessian = H1 + (1/sigmaSquared):*H2 - (1/(N-colsX)):*g2star'*g2star + H3	

				}
				else if(iter_algorithm==2) {	// FS
					Hessian = -H1 + H3 - (1/(N-colsX)):*g2star'*g2star 	
				}
				else {	// AI
					Hessian = 0.5*(1/sigmaSquared):*H2 + H3 - (1/(N-colsX)):*g2star'*g2star	
				}
			} 
			else {								// arctanG AND tau OR omega AND sigma
				lnf = quadcolsum(l1) + l2_scalar + l3_scalar + (N-colsX)*ln(2*pi())
				gradient = g1 + g2 + g3
				
				if(iter_algorithm==1) {	// NR
					Hessian = H1 + H2 + H3	

				}
				else if(iter_algorithm==2) {	// FS
					Hessian = -H1 + H3
				}
				else {	// AI
					Hessian = 0.5:*H2 + H3	
				}
			}
		} // END OF if g1,g2,vech_H1,vech_H2rs HAS A MISSING VALUE
		else {
			lnf = .
			gradient = .
			Hessian = .
		}
	} // END OF if(maxMissing==0 & l2_scalar !=. & l3_scalar !=.)
	else {
		lnf = .
		gradient = .
		Hessian = .
	}
	
} // END OF FUNCTION NR_REML_d2()

void IOUcov(real rowvector Wparameters, real matrix oneMatrix, real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, real matrix Wi)
{
	real scalar aLpha, tau
	
	aLpha = Wparameters[1,1]
	tau = Wparameters[1,2]
	Wi = (tau^2)/((aLpha^3)*2):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix ///
		 - exp(-aLpha:*abs(timeVari_t-timeVari_s)))

} // END OF FUNCTION IOUcov()

void Browniancov(real rowvector Wparameters, real matrix oneMatrix, real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, real matrix Wi)
{
	real scalar phi

	phi = Wparameters[1,1]
	Wi = phi:*minMatrix

} // END OF FUNCTION Browniancov()

// FUNCTION PERFORMS THE FOLLOWING: 
	// GENERATES CROSS-PRODUCT MATRIX W0
	// GENERATES THE AUGMENTATION OF W0
	// SWEEPS THE AUGMENTATION OF W0 ON THE FIRST PARTITION
void crossProductMatrices(real matrix A, real scalar colsA, real colvector B, real matrix C, real scalar colsC, real matrix cholD, ///
                          real matrix invcholE, real scalar lndet_augW_part1, real matrix sw1_augW_part4)	
{
	real matrix invcholEA, invcholEC, invcholEB, W, augW_part1, augW_part2, sw1_augW_part1, sw1_augW_part2
	
	invcholEA = invcholE*A			// invcholE*A
	invcholEC = invcholE*C	  	   	// invcholE*C
	invcholEB = invcholE*B			// invcholE*B
	
	// GENERATE CROSS-PRODUCT MATRIX W
	W = J(1+colsA+colsC,1+colsA+colsC,0)
	W[|1,1\colsA,colsA|] = cross(invcholEA,invcholEA)          							// A'*invcholE'*invcholE*A
	W[|1+colsA,1\colsA+colsC,colsA|] = cross(invcholEC,invcholEA)						// C'*invcholE'*invcholE*A
	W[|1+colsA,1+colsA\colsA+colsC,colsA+colsC|] = cross(invcholEC,invcholEC)			// C'invcholE'*invcholE*C
	W[|1+colsA+colsC,1\1+colsA+colsC,colsA|] = cross(invcholEB,invcholEA)				// B'*invcholE'*invcholE*A	
	W[|1+colsA+colsC,1+colsA\1+colsA+colsC,colsA+colsC|] = cross(invcholEB,invcholEC)	// B'*invcholE'*invcholE*C 
	W[1+colsA+colsC,1+colsA+colsC] = cross(invcholEB,invcholEB)							// B'*invcholE'*invcholE*B
	_makesymmetric(W) // SAVES FILLING IN THE OTHER ENTRIES

	// GENERATE AUGMENTATION OF W - IN 4 PARTITIONS
	// CODING CHECKED - SEE SECTION 2 OF "check - xtIOU.do"
	// aug W = [augW_part1	augW_part2
	//          augW_part3	augW_part4]
	// ONLY REQUIRE THE UPPER TRIANGLE (PARTS 1, 3 AND 4)
	// augW_part4 = W
	augW_part1 = I(colsC) + cross(invcholEC*cholD,invcholEC*cholD)    
	augW_part2 = cholD'*W[|colsA+1,1 \ colsA+colsC,colsA+colsC+1|]
	
	// SWEEP THE AUGMENTED W MATRIX AND REPORT THE SUM THE LOG OF THE POSITIVE PIVOTS DURING THE SWEEP 
	sweep_partitionK(augW_part1, augW_part2, W, sw1_augW_part1=., sw1_augW_part2=., sw1_augW_part4=., lndet_augW_part1=.)
} // END OF FUNCTION crossProductMatrices

void sweep_partitionK(real matrix partitionKK, real matrix partitionKJ, real matrix partitionJJ, real matrix sweptKK, real matrix sweptKJ, ///
					  real matrix sweptJJ, real scalar lndet_partitionKK)	  
{
	sweptKK = luinv(partitionKK)
	sweptKJ = sweptKK*partitionKJ
	sweptJJ = partitionJJ - cross(partitionKJ,sweptKJ)		// partitionJJ - partitionJK*sweptKK*partitionKJ
	
	// SUM THE LOG OF THE POSITIVE PIVOTS DURING THE SWEEP  
	lndet_partitionKK = ln(det(partitionKK))		
} // END OF FUNCTION sweep_partitionK

real matrix Gdot_logcholG(real rowvector Gparameters, real scalar row, real scalar col) 
{
	real scalar colsZ
	real matrix logcholG, Gdot
	
	logcholG = invvech(Gparameters')
	colsZ = cols(logcholG)
	
	Gdot = J(colsZ,colsZ,0)
	if(row==col) {
		Gdot[|row,row \ row,colsZ|] = exp(logcholG[row,row]):*logcholG[|row,row \ colsZ,row|]'
		Gdot[row,row] = exp(2*logcholG[row,row])
	}
	else {
		Gdot[|row,col \ row,colsZ|] = logcholG[|col,col \ colsZ,col|]'
		Gdot[row,col] = exp(logcholG[col,col])			
	}
	Gdot[row, row] = 2*Gdot[row, row]
	Gdot[|1,row \ colsZ,row|] = Gdot[|row,1 \ row,colsZ|]'	
	
	return(Gdot)
} // END OF FUNCTION Gdot_logcholG

real matrix Gdotdot_logcholG(real rowvector Gparameters, real scalar row_r, real scalar col_r, real scalar row_s, real scalar col_s) 
{
	real scalar colsZ
	real matrix logcholG, Gdotdot
	
	logcholG = invvech(Gparameters')
	colsZ = cols(logcholG)
	
	Gdotdot = J(colsZ,colsZ,0)
	
	// deriv_r==deriv_s
	if(row_r==row_s & col_r==col_s) {
		if(row_r==col_r) {
			Gdotdot[|row_r,row_r \ colsZ,row_r|] = exp(logcholG[row_r,row_r]):*logcholG[|row_r,row_r \ colsZ,row_r|]
			Gdotdot[|row_r,row_r \ row_r,colsZ|] = Gdotdot[|row_r,row_r \colsZ,row_r|]'
			Gdotdot[row_r,row_r] = 4*exp(2*logcholG[row_r,row_r])			
		}
		else {
			Gdotdot[row_r,row_r] = 2
		}
	}
	else if(row_r!=row_s & col_r==col_s) {	// e.g. row_r=3,col_r=2 and row_s=2,col_s=2
		if(row_s==col_s) {
			Gdotdot[row_r,col_r] = exp(logcholG[row_s,row_s]) 
			Gdotdot[col_r,row_r] = Gdotdot[row_r,col_r]
		}
		else {
			Gdotdot[row_r,row_s] = 1
			Gdotdot[row_s,row_r] = 1
		}
	}
	// ELSE A ZERO MATRIX (i.e. row_r!=row_s & col_r!=col_s)
	return(Gdotdot)
} // END OF FUNCTION Gdotdot_logcholG

real matrix Gdot_arctanG(real rowvector Gparameters, real scalar row, real scalar col) 
{
	real scalar colsZ, index
	real matrix arctanG, Gdot

	arctanG = invvech(Gparameters')
	
	colsZ = cols(arctanG)
	
	Gdot = J(colsZ,colsZ,0)
	
	if(row==col) {
		for(index=1; index<=colsZ; index++) {
			Gdot[row,index] = exp(arctanG[index,index]+arctanG[row,row])*tanh(arctanG[row,index])		
		}
		Gdot[row,row] = 2*exp(2*arctanG[row,row])
		Gdot[|1,row \ colsZ,row|] = Gdot[|row,1 \ row,colsZ|]'
	}
	else {
		Gdot[row,col] = exp(arctanG[row,row]+arctanG[col,col])*(cosh(arctanG[row,col])^-2)	// sech[x] = 1/cosh[x]
		Gdot[col,row] = Gdot[row,col]
	}
	return(Gdot)
} // END OF FUNCTION Gdot_arctanG

real matrix Gdotdot_arctanG(real rowvector Gparameters, real scalar row_r, real scalar col_r, real scalar row_s, real scalar col_s) 
{
	real scalar colsZ, index
	real matrix arctanG, Gdotdot
	
	arctanG = invvech(Gparameters')
	colsZ = cols(arctanG)
	
	Gdotdot = J(colsZ,colsZ,0)
		
	if(row_r==row_s & col_r==col_s) {      // deriv_r==deriv_s
		if(row_r==col_r) {		// OPTION 1
			for(index=1; index<=colsZ; index++) {
				Gdotdot[row_r,index] = exp(arctanG[index,index]+arctanG[row_r,row_r])*tanh(arctanG[row_r,index])		
			}
			Gdotdot[row_r,row_r] = 4*exp(2*arctanG[row_r,row_r])
			Gdotdot[|1,row_r \ colsZ,row_r|] = Gdotdot[|row_r,1 \ row_r,colsZ|]'
		}
		else {					// OPTION 2
			Gdotdot[row_r,col_r] = -2*exp(arctanG[row_r,row_r]+arctanG[col_r,col_r])*(1/cosh(arctanG[row_r,col_r]))^2*tanh(arctanG[row_r,col_r])
			Gdotdot[col_r,row_r] = Gdotdot[row_r,col_r]
		}
	}
	else {			// deriv_r!=deriv_s
		if(col_r==row_s & row_s==col_s) {
			Gdotdot[row_r,col_r] = exp(arctanG[row_r,row_r]+arctanG[col_r,col_r])*(1/cosh(arctanG[row_r,col_r]))^2 
			Gdotdot[col_r,row_r] = Gdotdot[row_r,col_r]
		}
		else if(col_r==row_s & row_r==col_r) {
			Gdotdot[row_r,col_s] = exp(arctanG[row_r,row_r]+arctanG[col_s,col_s])*(1/cosh(arctanG[row_r,col_s]))^2 
			Gdotdot[col_s,row_r] = Gdotdot[row_r,col_s]
		}
		else if(row_r==col_r & row_s==col_s) {	// OUTER else IMPLIES THAT row_r!=row_s AND col_r!=col_s
			Gdotdot[row_r,row_s] = exp(arctanG[row_r,row_r]+arctanG[row_s,row_s])*tanh(arctanG[row_r,row_s])
			Gdotdot[row_s,row_r] = Gdotdot[row_r,row_s]			
		}
	}	// ELSE ZERO MATRIX
	return(Gdotdot)
} // END OF FUNCTION Gdotdot_arctanG

void Rdot_at(real scalar ni, real rowvector Rparameters, ///
             real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			 pointer(real matrix) colvector p_Rdot) 
{
	real scalar aLpha, tau
	real matrix oneMatrix
	
	aLpha = Rparameters[1]
	tau = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdot = J(2,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO aLpha 
	p_Rdot[1] = &(makesymmetric( ///
	               (tau^2)/(2*(aLpha^4)):*(3:*oneMatrix - 3:*exp(-aLpha:*timeVari_s) - 3:*exp(-aLpha:*timeVari_t) + 3:*exp(-aLpha:*abs(timeVari_t-timeVari_s)) /// 
					- exp(-aLpha:*timeVari_s):*(aLpha:*timeVari_s) - exp(-aLpha:*timeVari_t):*(aLpha:*timeVari_t) ///
					+ exp(-aLpha:*abs(timeVari_t-timeVari_s)):*(aLpha:*abs(timeVari_t-timeVari_s)) - 4*aLpha:*minMatrix) ///
				))

	// DIFFERENTIATE WITH RESPECT TO tau 
	p_Rdot[2] = &(makesymmetric( ///
	                tau/(aLpha^3):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - ///
                    oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s))) ///
				))
				
} // END OF FUNCTION Rdot_at()

void Rdotdot_at(real scalar ni, real rowvector Rparameters, ///
                real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
				pointer(real matrix) colvector p_Rdotdot) 
{
	real scalar aLpha, tau
	real matrix oneMatrix
	
	aLpha = Rparameters[1]
	tau = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdotdot = J(3,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO aLpha AND aLpha
	p_Rdotdot[1] = &(makesymmetric( ///
					(tau^2)/(2*(aLpha^5)):*( ///
				    (aLpha^2):*(exp(-aLpha:*timeVari_s):*timeVari_s:*timeVari_s + exp(-aLpha:*timeVari_t):*timeVari_t:*timeVari_t ///
				    - exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s):*abs(timeVari_t-timeVari_s)) ///
				    - 6*aLpha:*(-exp(-aLpha:*timeVari_s):*timeVari_s - exp(-aLpha:*timeVari_t):*timeVari_t ///
				    + exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s) + 2:*minMatrix) ///
				    + 12:*(-1:*oneMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - exp(-aLpha:*abs(timeVari_t-timeVari_s)) + 2*aLpha:*minMatrix)) /// 			
				   ))
					
	// DIFFERENTIATE WITH RESPECT TO aLpha AND tau 
	p_Rdotdot[2] = &(makesymmetric( ///
						tau/(aLpha^4):*(3:*oneMatrix - 3:*exp(-aLpha:*timeVari_s) - 3:*exp(-aLpha:*timeVari_t) + 3:*exp(-aLpha:*abs(timeVari_t-timeVari_s)) ///
						- exp(-aLpha:*timeVari_s):*aLpha:*timeVari_s  - exp(-aLpha:*timeVari_t):*aLpha:*timeVari_t  ///
						+ exp(-aLpha:*abs(timeVari_t-timeVari_s)):*aLpha:*abs(timeVari_t-timeVari_s) - 4*aLpha:*minMatrix) ///		
					))

	// DIFFERENTIATE WITH RESPECT TO tau AND tau 
	p_Rdotdot[3] = &(makesymmetric( ///
						1/(aLpha^3):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) ///
						- oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s))) ///
					))
			
} // END OF FUNCTION Rdotdot_at()

void Rdot_ao(real scalar ni, real rowvector Rparameters, ///
             real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			 pointer(real matrix) colvector p_Rdot) 
{
	real scalar aLpha, omega
	real matrix oneMatrix
	
	aLpha = Rparameters[1]
	omega = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdot = J(2,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO aLpha 
	p_Rdot[1] = &(makesymmetric( ///
					(omega/(2*aLpha^2)):*(oneMatrix + exp(-aLpha:*abs(timeVari_t-timeVari_s)) - exp(-aLpha:*timeVari_s):*(oneMatrix + aLpha:*timeVari_s) ///
					- exp(-aLpha:*timeVari_t):*(oneMatrix + aLpha:*timeVari_t) + exp(-aLpha:*abs(timeVari_t-timeVari_s)):*aLpha:*abs(timeVari_t-timeVari_s)) ///
					))

	// DIFFERENTIATE WITH RESPECT TO omega 
	p_Rdot[2] = &(makesymmetric( ///
					(1/(2*aLpha)):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s)))	
				))
				
} // END OF FUNCTION Rdot_ao()

void Rdotdot_ao(real scalar ni, real rowvector Rparameters, ///
                real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
				pointer(real matrix) colvector p_Rdotdot) 
{
	real scalar aLpha, omega
	real matrix oneMatrix
	
	aLpha = Rparameters[1]
	omega = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdotdot = J(3,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO aLpha AND aLpha
	p_Rdotdot[1] = &(makesymmetric( ///
						(-omega/(2*aLpha^3)):*exp(-aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))):* ///
						(2*exp(aLpha:*(timeVari_s+timeVari_t)) + 2*exp(aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))) ///
						- exp(aLpha:*(timeVari_t+abs(timeVari_t-timeVari_s))):*(2:*oneMatrix+aLpha:*timeVari_s:*(2:*oneMatrix+aLpha:*timeVari_s)) ///
						- exp(aLpha:*(timeVari_s+abs(timeVari_t-timeVari_s))):*(2:*oneMatrix+aLpha:*timeVari_t:*(2:*oneMatrix+aLpha:*timeVari_t)) ///
						+ 2*exp(aLpha:*(timeVari_s+timeVari_t)):*aLpha:*abs(timeVari_t-timeVari_s) ///
						+ exp(aLpha:*(timeVari_s+timeVari_t)):*(aLpha^2):*(abs(timeVari_t-timeVari_s):*abs(timeVari_t-timeVari_s))) ///					
				   ))
					
	// DIFFERENTIATE WITH RESPECT TO aLpha AND omega 
	p_Rdotdot[2] = &(makesymmetric( ///
						(1/(2*aLpha^2)):*(oneMatrix + exp(-aLpha:*abs(timeVari_t-timeVari_s)) - exp(-aLpha:*timeVari_s):*(oneMatrix+aLpha:*timeVari_s) ///		
						- exp(-aLpha:*timeVari_t):*(oneMatrix+aLpha:*timeVari_t) + exp(-aLpha:*abs(timeVari_t-timeVari_s)):*aLpha:*abs(timeVari_t-timeVari_s)) ///	 
					))

	// DIFFERENTIATE WITH RESPECT TO omega AND omega 
	p_Rdotdot[3] = &( ///
						J(ni,ni,0)
					)
			
} // END OF FUNCTION Rdotdot_ao()

void Rdot_et(real scalar ni, real rowvector Rparameters, ///
             real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			 pointer(real matrix) colvector p_Rdot) 
{
	real scalar aLpha, tau
	real matrix oneMatrix
	
	aLpha = exp(Rparameters[1])
	tau = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdot = J(2,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO eta 
	p_Rdot[1] = &(makesymmetric( ///
					((tau^2)/(2*(aLpha^3))):*(3:*(oneMatrix - exp(-aLpha:*timeVari_s) - exp(-aLpha:*timeVari_t) + exp(-aLpha:*abs(timeVari_t-timeVari_s))) /// 
					+ aLpha:*(-exp(-aLpha:*timeVari_s):*timeVari_s - exp(-aLpha:*timeVari_t):*timeVari_t + exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s) - 4:*minMatrix))
				))

	// DIFFERENTIATE WITH RESPECT TO tau
	p_Rdot[2] = &(makesymmetric( ///
					(tau/aLpha^3):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s)))
				))
				
} // END OF FUNCTION Rdot_et()

void Rdotdot_et(real scalar ni, real rowvector Rparameters, ///
                real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
				pointer(real matrix) colvector p_Rdotdot) 
{
	real scalar aLpha, tau
	real matrix oneMatrix
	
	aLpha = exp(Rparameters[1])
	tau = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdotdot = J(3,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO eta AND eta
	p_Rdotdot[1] = &(makesymmetric( ///
						((tau^2)/(2*(aLpha)^3)):*(9:*(-oneMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - exp(-aLpha:*abs(timeVari_t-timeVari_s))) ///
						+ 5*aLpha:*(exp(-aLpha:*timeVari_s):*timeVari_s + exp(-aLpha:*timeVari_t):*timeVari_t - exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s)) ///
						+ aLpha^2:*(exp(-aLpha:*timeVari_s):*timeVari_s:*timeVari_s + exp(-aLpha:*timeVari_t):*timeVari_t:*timeVari_t - exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s):*abs(timeVari_t-timeVari_s)) ///
						+ 8*aLpha:*minMatrix)	
				   ))
					
	// DIFFERENTIATE WITH RESPECT TO eta AND tau 
	p_Rdotdot[2] = &(makesymmetric( ///
						(tau/aLpha^3):*(3:*(oneMatrix - exp(-aLpha:*timeVari_s) - exp(-aLpha:*timeVari_t) + exp(-aLpha:*abs(timeVari_t-timeVari_s))) /// 
						+ aLpha:*(-exp(-aLpha:*timeVari_s):*timeVari_s - exp(-aLpha:*timeVari_t):*timeVari_t + exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s) - 4:*minMatrix))		
					))

	// DIFFERENTIATE WITH RESPECT TO tau AND tau 
	p_Rdotdot[3] = &(makesymmetric( ///
						(1/aLpha^3):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s)))
					))
			
} // END OF FUNCTION Rdotdot_et()

void Rdot_eo(real scalar ni, real rowvector Rparameters, ///
             real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			 pointer(real matrix) colvector p_Rdot) 
{
	real scalar aLpha, omega
	real matrix oneMatrix
	
	aLpha = exp(Rparameters[1])
	omega = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdot = J(2,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO eta 
	p_Rdot[1] = &(makesymmetric( ///
					(omega/(2*aLpha)):*(oneMatrix + exp(-aLpha:*abs(timeVari_t-timeVari_s)):*(oneMatrix + aLpha:*abs(timeVari_t-timeVari_s)) ///
					- exp(-aLpha:*timeVari_s):*(oneMatrix + aLpha:*timeVari_s) - exp(-aLpha:*timeVari_t):*(oneMatrix + aLpha:*timeVari_t))
				))

	// DIFFERENTIATE WITH RESPECT TO omega
	p_Rdot[2] = &(makesymmetric( ///
					(1/(2*aLpha)):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s)))	
				))
				
} // END OF FUNCTION Rdot_eo()

void Rdotdot_eo(real scalar ni, real rowvector Rparameters, ///
                real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
				pointer(real matrix) colvector p_Rdotdot) 
{
	real scalar aLpha, omega
	real matrix oneMatrix
	
	aLpha = exp(Rparameters[1])
	omega = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdotdot = J(3,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO eta AND eta
	p_Rdotdot[1] = &(makesymmetric( ///
						(-omega/(2*aLpha)):*exp(-aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))):*(exp(aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))) ///
						+ exp(aLpha:*(timeVari_s+timeVari_t)):*(oneMatrix + aLpha:*abs(timeVari_t-timeVari_s) + aLpha^2:*abs(timeVari_t-timeVari_s):*abs(timeVari_t-timeVari_s)) ///
						- exp(aLpha:*(timeVari_t+abs(timeVari_t-timeVari_s))):*(oneMatrix + aLpha:*timeVari_s + aLpha^2:*timeVari_s:*timeVari_s) ///
						- exp(aLpha:*(timeVari_s+abs(timeVari_t-timeVari_s))):*(oneMatrix + aLpha:*timeVari_t + aLpha^2:*timeVari_t:*timeVari_t))
				   ))
					
	// DIFFERENTIATE WITH RESPECT TO eta AND omega 
	p_Rdotdot[2] = &(makesymmetric( ///
						(1/(2*aLpha)):*(oneMatrix + exp(-aLpha:*abs(timeVari_t-timeVari_s)):*(oneMatrix + aLpha:*abs(timeVari_t-timeVari_s)) ///
						- exp(-aLpha:*timeVari_s):*(oneMatrix + aLpha:*timeVari_s) - exp(-aLpha:*timeVari_t):*(oneMatrix+aLpha:*timeVari_t))
					))

	// DIFFERENTIATE WITH RESPECT TO omega AND omega 
	p_Rdotdot[3] = &(J(ni,ni,0))
			
} // END OF FUNCTION Rdotdot_eo()

void Rdot_it(real scalar ni, real rowvector Rparameters, ///
             real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			 pointer(real matrix) colvector p_Rdot) 
{
	real scalar aLpha, tau
	real matrix oneMatrix
	
	aLpha = sqrt(1/Rparameters[1])
	tau = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdot = J(2,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO iota 
	p_Rdot[1] = &(makesymmetric( ///
					0.25*(tau^2):*(exp(-aLpha:*timeVari_s):*timeVari_s + exp(-aLpha:*timeVari_t):*timeVari_t - (3/aLpha):*(oneMatrix - exp(-aLpha:*timeVari_s) - exp(-aLpha:*timeVari_t) + exp(-aLpha:*abs(timeVari_t-timeVari_s))) ///
					- exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s) + 4:*minMatrix)
				))

	// DIFFERENTIATE WITH RESPECT TO tau
	p_Rdot[2] = &(makesymmetric( ///
					tau/(aLpha^3):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s)))	
				))
				
} // END OF FUNCTION Rdot_it()

void Rdotdot_it(real scalar ni, real rowvector Rparameters, ///
                real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
				pointer(real matrix) colvector p_Rdotdot) 
{
	real scalar aLpha, tau
	real matrix oneMatrix
	
	aLpha = sqrt(1/Rparameters[1])
	tau = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdotdot = J(3,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO iota AND iota
	p_Rdotdot[1] = &(makesymmetric( ///
						-(((tau^2)*(aLpha^3))/8):*exp(-aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))):* ///
						(- exp(aLpha:*(timeVari_t+abs(timeVari_t-timeVari_s))):*(timeVari_s:*timeVari_s+(3/aLpha^2):*oneMatrix+(3/aLpha):*timeVari_s) ///
						- exp(aLpha:*(timeVari_s+abs(timeVari_t-timeVari_s))):*(timeVari_t:*timeVari_t+(3/aLpha^2):*oneMatrix+(3/aLpha):*timeVari_t) ///
						+ (3/aLpha^2):*exp(aLpha:*(timeVari_s+timeVari_t)) + (3/aLpha^2):*exp(aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))) ///
						+ (3/aLpha):*exp(aLpha:*(timeVari_s+timeVari_t)):*abs(timeVari_t-timeVari_s) + exp(aLpha:*(timeVari_s+timeVari_t)):*abs(timeVari_t-timeVari_s):*abs(timeVari_t-timeVari_s)) 
				   ))
					
	// DIFFERENTIATE WITH RESPECT TO iota AND tau 
	p_Rdotdot[2] = &(makesymmetric( ///
						0.5*tau:*(exp(-aLpha:*timeVari_s):*timeVari_s + exp(-aLpha:*timeVari_t):*timeVari_t - (3/aLpha):*(oneMatrix - exp(-aLpha:*timeVari_s) - exp(-aLpha:*timeVari_t) + exp(-aLpha:*abs(timeVari_t-timeVari_s))) ///
						- exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s) + 4:*minMatrix)		
					))

	// DIFFERENTIATE WITH RESPECT TO tau AND tau 
	p_Rdotdot[3] = &(makesymmetric( ///
						1/(aLpha^3):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s)))
					))
			
} // END OF FUNCTION Rdotdot_it()

void Rdot_io(real scalar ni, real rowvector Rparameters, ///
             real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			 pointer(real matrix) colvector p_Rdot) 
{
	real scalar aLpha, omega
	real matrix oneMatrix
	
	aLpha = sqrt(1/Rparameters[1])
	omega = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdot = J(2,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO iota 
	p_Rdot[1] = &(makesymmetric( ///
					-0.25*aLpha*omega:*exp(-aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))):*(exp(aLpha:*(timeVari_s+timeVari_t)):*(oneMatrix+aLpha:*abs(timeVari_t-timeVari_s)) ///
					+ exp(aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))) - exp(aLpha:*(timeVari_t+abs(timeVari_t-timeVari_s))):*(oneMatrix+aLpha:*timeVari_s) ///
					- exp(aLpha:*(timeVari_s+abs(timeVari_t-timeVari_s))):*(oneMatrix+aLpha:*timeVari_t))
				))

	// DIFFERENTIATE WITH RESPECT TO omega
	p_Rdot[2] = &(makesymmetric( ///
					(1/(2*aLpha)):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s)))	
				))
				
} // END OF FUNCTION Rdot_io()

void Rdotdot_io(real scalar ni, real rowvector Rparameters, ///
                real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
				pointer(real matrix) colvector p_Rdotdot) 
{
	real scalar aLpha, omega
	real matrix oneMatrix
	
	aLpha = sqrt(1/Rparameters[1])
	omega = Rparameters[2]
	oneMatrix = J(ni,ni,1) 
	p_Rdotdot = J(3,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO iota AND iota
	p_Rdotdot[1] = &(makesymmetric( ///
						-(omega/8)*(aLpha^5):*exp(-aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))):*(exp(aLpha:*(timeVari_s+timeVari_t)):*abs(timeVari_t-timeVari_s):*abs(timeVari_t-timeVari_s) + ///
						exp(aLpha:*(timeVari_t+abs(timeVari_t-timeVari_s))):*(-timeVari_s:*timeVari_s+(1/aLpha^2):*oneMatrix+(1/aLpha):*timeVari_s) + ///
						exp(aLpha:*(timeVari_s+abs(timeVari_t-timeVari_s))):*(-timeVari_t:*timeVari_t+(1/aLpha^2):*oneMatrix+(1/aLpha):*timeVari_t) - ///
						(1/aLpha^2):*(exp(aLpha:*(timeVari_s+timeVari_t))+exp(aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s)))) - ///
						(1/aLpha):*exp(aLpha:*(timeVari_s+timeVari_t)):*abs(timeVari_t-timeVari_s))		 		
				   ))
					
	// DIFFERENTIATE WITH RESPECT TO iota AND omega 
	p_Rdotdot[2] = &(makesymmetric( ///
						-0.25*aLpha:*exp(-aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))):*(exp(aLpha:*(timeVari_s+timeVari_t)):*(oneMatrix+aLpha:*abs(timeVari_t-timeVari_s)) ///
						+ exp(aLpha:*(timeVari_s+timeVari_t+abs(timeVari_t-timeVari_s))) - exp(aLpha:*(timeVari_t+abs(timeVari_t-timeVari_s))):*(oneMatrix+aLpha:*timeVari_s) ///
						- exp(aLpha:*(timeVari_s+abs(timeVari_t-timeVari_s))):*(oneMatrix+aLpha:*timeVari_t))
					))

	// DIFFERENTIATE WITH RESPECT TO omega AND omega 
	p_Rdotdot[3] = &(J(ni,ni,0))
			
} // END OF FUNCTION Rdotdot_io()

void Rdot_ek(real scalar ni, real rowvector Rparameters, ///
             real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			 pointer(real matrix) colvector p_Rdot) 
{
	real scalar aLpha, tau, sigma
	real matrix oneMatrix
	
	aLpha = exp(Rparameters[1])
	tau = exp(Rparameters[2])
	sigma = exp(Rparameters[3])
	oneMatrix = J(ni,ni,1) 
	p_Rdot = J(3,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO eta 
	p_Rdot[1] = &(makesymmetric( ///
					(tau^2/(2*(aLpha^3))):*(3:*(oneMatrix - exp(-aLpha:*timeVari_s) - exp(-aLpha:*timeVari_t) + exp(-aLpha:*abs(timeVari_t-timeVari_s))) /// 
					+ aLpha:*(-exp(-aLpha:*timeVari_s):*timeVari_s - exp(-aLpha:*timeVari_t):*timeVari_t + exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s) - 4:*minMatrix))
				))

	// DIFFERENTIATE WITH RESPECT TO kappa = lntau
	p_Rdot[2] = &(makesymmetric( ///
					(tau^2/aLpha^3):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s)))
				))
				
				
	// DIFFERENTIATE WITH RESPECT TO lnsigma
	p_Rdot[3] = &(makesymmetric( ///
					2*(sigma^2):*I(ni)			
				))
				
} // END OF FUNCTION Rdot_ek()

void Rdotdot_ek(real scalar ni, real rowvector Rparameters, ///
                real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
				pointer(real matrix) colvector p_Rdotdot) 
{
	real scalar aLpha, tau, sigma
	real matrix oneMatrix
	
	aLpha = exp(Rparameters[1])
	tau = exp(Rparameters[2])
	sigma = exp(Rparameters[3])
	oneMatrix = J(ni,ni,1) 
	p_Rdotdot = J(6,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO eta AND eta
	p_Rdotdot[1] = &(makesymmetric( ///
						(tau^2/(2*(aLpha)^3)):*(9:*(-oneMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - exp(-aLpha:*abs(timeVari_t-timeVari_s))) ///
						+ 5*aLpha:*(exp(-aLpha:*timeVari_s):*timeVari_s + exp(-aLpha:*timeVari_t):*timeVari_t - exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s)) ///
						+ aLpha^2:*(exp(-aLpha:*timeVari_s):*timeVari_s:*timeVari_s + exp(-aLpha:*timeVari_t):*timeVari_t:*timeVari_t - exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s):*abs(timeVari_t-timeVari_s)) ///
						+ 8*aLpha:*minMatrix)	
				   ))
					
	// DIFFERENTIATE WITH RESPECT TO eta AND kappa 
	p_Rdotdot[2] = &(makesymmetric( ///
						(tau^2/aLpha^3):*(3:*(oneMatrix - exp(-aLpha:*timeVari_s) - exp(-aLpha:*timeVari_t) + exp(-aLpha:*abs(timeVari_t-timeVari_s))) /// 
						+ aLpha:*(-exp(-aLpha:*timeVari_s):*timeVari_s - exp(-aLpha:*timeVari_t):*timeVari_t + exp(-aLpha:*abs(timeVari_t-timeVari_s)):*abs(timeVari_t-timeVari_s) - 4:*minMatrix))		
					))
	// DIFFERENTIATE WITH RESPECT TO eta AND lnsigma 
	p_Rdotdot[3] = &(J(ni,ni,0))

	// DIFFERENTIATE WITH RESPECT TO kappa AND kappa 
	p_Rdotdot[4] = &(makesymmetric( ///
						(2*tau^2/aLpha^3):*(2*aLpha:*minMatrix + exp(-aLpha:*timeVari_s) + exp(-aLpha:*timeVari_t) - oneMatrix - exp(-aLpha:*abs(timeVari_t-timeVari_s)))
					))
	
	// DIFFERENTIATE WITH RESPECT TO kappa AND lnsigma 
	p_Rdotdot[5] = &(J(ni,ni,0))
	
	
	// DIFFERENTIATE WITH RESPECT TO lnsigma AND lnsigma 
	p_Rdotdot[6] = &(makesymmetric( ///
						4*(sigma^2):*I(ni)
					))
} // END OF FUNCTION Rdotdot_ek()

void Rdot_phi(real scalar ni, real rowvector Rparameters, ///
              real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			  pointer(real matrix) colvector p_Rdot) 
{
	p_Rdot = J(1,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO phi 
	p_Rdot[1] = &(minMatrix)

} // END OF FUNCTION Rdot_phi()

void Rdotdot_phi(real scalar ni, real rowvector Rparameters, ///
                 real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			     pointer(real matrix) colvector p_Rdotdot) 
{
	p_Rdotdot = J(1,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO phi AND phi
	p_Rdotdot[1] = &(J(ni,ni,0)) 

} // END OF FUNCTION Rdotdot_phi()

void Rdot_lnphi(real scalar ni, real rowvector Rparameters, ///
                real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
			    pointer(real matrix) colvector p_Rdot) 
{
	real scalar phi, sigma
	real matrix oneMatrix
	
	phi = exp(Rparameters[1])
	sigma = exp(Rparameters[2])
	oneMatrix = J(ni,ni,1) 
	p_Rdot = J(2,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO ln(phi) 
	p_Rdot[1] = &(makesymmetric(phi:*minMatrix))

	// DIFFERENTIATE WITH RESPECT TO lnsigma
	p_Rdot[2] = &(makesymmetric( ///
					2*(sigma^2):*I(ni)			
				))
				
} // END OF FUNCTION Rdot_lnphi()

void Rdotdot_lnphi(real scalar ni, real rowvector Rparameters, ///
                   real matrix timeVari_s, real matrix timeVari_t, real matrix minMatrix, ///
				   pointer(real matrix) colvector p_Rdotdot) 
{
	real scalar phi, tau, sigma
	real matrix oneMatrix
	
	phi = exp(Rparameters[1])
	sigma = exp(Rparameters[2])
	oneMatrix = J(ni,ni,1) 
	p_Rdotdot = J(3,1,NULL)
	
	// DIFFERENTIATE WITH RESPECT TO lnphi AND lnphi
	p_Rdotdot[1] = &(makesymmetric(phi:*minMatrix))
					
	// DIFFERENTIATE WITH RESPECT TO lnphi AND lnsigma 
	p_Rdotdot[2] = &(J(ni,ni,0))
	
	// DIFFERENTIATE WITH RESPECT TO lnsigma AND lnsigma 
	p_Rdotdot[3] = &(makesymmetric( ///
						4*(sigma^2):*I(ni)
					))
} // END OF FUNCTION Rdotdot_lnphi()

void Rconversion(real scalar inputRstyle, real scalar inputIOU1, real scalar inputIOU2, ///
                 real scalar outputRstyle, real scalar outputIOU1, real scalar outputIOU2)
{
	real scalar aLpha, tau
	
	// CONVERT inputIOU1 -> aLpha 
	if(inputRstyle==3 | inputRstyle==4 | inputRstyle==7) { // eta -> alpha  
		aLpha = exp(inputIOU1)
	}
	else if (inputRstyle==5 | inputRstyle==6) { // iota -> alpha
		aLpha = sqrt(1/inputIOU1)
	}
	else { 
		aLpha = inputIOU1	
	}
	
	// CONVERT inputIOU2 -> tau
	if (inputRstyle==2 | inputRstyle==4 | inputRstyle==6) { // omega -> tau
		tau = sqrt((aLpha^2)*inputIOU2)
	}
	else if(inputRstyle==7) { // kappa -> tau
		tau = exp(inputIOU2)
	}
	else {
		tau = inputIOU2
	}
		
	// CONVERT aLpha -> outputIOU1 
	if (outputRstyle==3 | outputRstyle==4 | outputRstyle==7) { // alpha -> eta
		outputIOU1 = ln(aLpha)
	}
	else if (outputRstyle==5 | outputRstyle==6) { // aLpha -> iota
		outputIOU1 = 1/(aLpha^2)
	}
	else { 
		outputIOU1 = aLpha
	}
	
	// CONVERT tau -> outputIOU2
	if (outputRstyle==2 | outputRstyle==4 | outputRstyle==6) { // tau -> omega 
		outputIOU2 = (tau/aLpha)^2
	}
	else if (outputRstyle==7) { // tau -> kappa
		outputIOU2 = ln(tau)
	}
	else {
		outputIOU2 = tau
	}
} // END OF FUNCTION Rconversion()

// SEE "xtIOU/do files/tests delta method for sigma and sigmaSquared.do" FOR CHECKING OF MY IMPLEMENTATION OF THE DELTA METHOD
void tabTheta_sigmaSq(real rowvector transParameters, real matrix transVariance, ///
                      real scalar colsZ, real scalar numberOfGparas, ///
                      real matrix table_theta) 
{
	real scalar numberOfParameters, fnpara, fnrow, fncol, dpara, drow, dcol
	real matrix variance, fnderiv, positions

	numberOfParameters = cols(transParameters)
	
	positions = invvech(range(1, numberOfGparas, 1))
	
	table_theta = J(numberOfParameters,4,.)
	table_theta[|1,2 \ numberOfParameters,2|] = sqrt(diagonal(transVariance))	// Std Err FOR TRANSFORMED PARAMETERS
	
	fnderiv = J(numberOfParameters,numberOfParameters,0)

	fncol = 1
	fnrow = 0
	for(fnpara=1; fnpara<=numberOfGparas; fnpara++) {
		fnrow = fnrow + 1
		if(fnrow > colsZ) {
			fncol = fncol + 1
			fnrow = fncol
		}
		
		// CALCULATES CONFIDENCE INTERVALS FOR VARIANCE PARAMETERS (i.e. DIAGONAL ENTRIES) OF MATRIX G
		if(fnrow==fncol) {
			table_theta[fnpara,1] = exp(2*transParameters[fnpara])
			table_theta[fnpara,3] = exp(2*(transParameters[fnpara] - 1.96*table_theta[fnpara,2]))
			table_theta[fnpara,4] = exp(2*(transParameters[fnpara] + 1.96*table_theta[fnpara,2]))			
		}
		else {
			table_theta[fnpara,1] = tanh(transParameters[fnpara])*exp(transParameters[positions[fnrow,fnrow]])*exp(transParameters[positions[fncol,fncol]])
		}
		
		// CALCULATES DERIVATIVE OF TRANSFORMATION FUNCTION (transParameters -> theta) FOR THE PARAMETERS OF MATRIX G
		dcol = 1
		drow = 0
		for(dpara=1; dpara<=numberOfGparas; dpara++) {
			drow = drow + 1
			if(drow > colsZ) {
				dcol = dcol + 1
				drow = dcol
			}
			
			if(fnpara==dpara) {
				if(fnrow==fncol) {
					fnderiv[fnpara,fnpara] = 2*exp(2*transParameters[fnpara])		
				}
				else {
					fnderiv[fnpara,fnpara] = (1/cosh(transParameters[fnpara]))^2*exp(transParameters[positions[fnrow,fnrow]])*exp(transParameters[positions[fncol,fncol]])
				}
			}
			else {
				if((fncol==drow & drow==dcol) | (fnrow==drow & drow==dcol)) {
					fnderiv[fnpara,dpara] = tanh(transParameters[fnpara])*exp(transParameters[positions[fnrow,fnrow]])*exp(transParameters[positions[fncol,fncol]])
				}
				// ELSE A ZERO VALUE
			}			
		} // END OF dpara FOR-LOOP
	} // END OF fnpara FOR-LOOP
	
	// CALCULATES DERIVATIVE OF TRANSFORMATION FUNCTION FOR THE PARAMETERS OF MATRIX W
	// CALCULATES STANDARD ERRORS AND CONFIDENCE INTERVALS FOR THE PARAMETERS OF MATRIX W
	for(fnpara=numberOfGparas+1; fnpara<=numberOfParameters-1; fnpara++) {
		fnderiv[fnpara,fnpara] = exp(transParameters[fnpara])	// e.g. DERIVATIVE WHEN CONVERTING FROM lnalpha TO aLpha
		table_theta[fnpara,1] = exp(transParameters[fnpara])
		table_theta[fnpara,3] = exp(transParameters[fnpara] - 1.96*table_theta[fnpara,2])
		table_theta[fnpara,4] = exp(transParameters[fnpara] + 1.96*table_theta[fnpara,2])
	}
	
	// CALCULATE DERIVATIVE OF TRANSFORMATION FUNCTION FOR lnsigma -> sigmaSquared
	// CALCULATES STANDARD ERRORS AND CONFIDENCE INTERVALS FOR sigmaSquared
	fnderiv[numberOfParameters,numberOfParameters] = 2*exp(2*transParameters[numberOfParameters])	
	table_theta[numberOfParameters,1] = exp(2*transParameters[numberOfParameters])
	table_theta[numberOfParameters,3] = exp(2*(transParameters[numberOfParameters] - 1.96*table_theta[numberOfParameters,2]))
	table_theta[numberOfParameters,4] = exp(2*(transParameters[numberOfParameters] + 1.96*table_theta[numberOfParameters,2]))

	// COVARIANCE MATRIX OF UNTRANSFORMED PARAMETERS
	variance = fnderiv*transVariance*fnderiv'
	table_theta[|1,2 \ numberOfParameters,2|] = sqrt(diagonal(variance))	// Std Err FOR UNTRANSFORMED PARAMETERS

	// CALCULATES CONFIDENCE INTERVALS FOR THE COVARIANCES (i.e. OFF-DIAGONAL ELEMENTS) OF MATRIX G
	for(fnpara=1; fnpara<=numberOfGparas; fnpara++) {
		if(table_theta[fnpara,3]==.) {				
			table_theta[fnpara,3] = table_theta[fnpara,1] - 1.96*table_theta[fnpara,2] 
			table_theta[fnpara,4] = table_theta[fnpara,1] + 1.96*table_theta[fnpara,2] 
		}
	}
} // END OF tabTheta_sigmaSq

//  INPUT: ESTIMATES WITH CORRESPONDING COVARIANCE MATRIX
//         IF ZSCORES AND PVALUES ARE REQUIRED THEN SET style TO 1
// OUTPUT: MATRIX CONTAINING ESTIMATES, SEs, [ZSCORES, PVALUES], LCIs, UCIs
void tabulatingBeta(real colvector vec_estimates, real matrix mat_covariance, real matrix table_beta)
{
	real colvector blank
	
	blank = J(rows(vec_estimates),1,0)
	
	// COEFFICIENTS AND STANDARD ERRORS
	table_beta = vec_estimates
	table_beta = table_beta, sqrt(diagonal(mat_covariance))

	// Z-SCORES AND P-VALUES
	table_beta = table_beta, blank
	table_beta[,3] = table_beta[,1] :/ table_beta[,2]
	table_beta = table_beta, blank
	table_beta[,4] = 2*(1 :- normal(abs(table_beta[,3])))		
		
	// ADD lci
	table_beta = table_beta, blank
	table_beta[,5] = table_beta[,1] :-  invnormal(0.975):*table_beta[,2]
	
	// ADD uci
	table_beta = table_beta, blank
	table_beta[,6] = table_beta[,1] :+  invnormal(0.975):*table_beta[,2]
	
} // END OF FUNCTION tabulating()
end	
