
**********************************************
* Mata funcitons for the BLP equilibrium model
**********************************************

mata:

mata clear

// estimation of the BLP equilibrium model (demand and pricing equations as a simulataneous system)
void estimation_blp_eq(
	string scalar share0,
	string scalar iexog0,
	string scalar xp0,
	string scalar endog0,
	string scalar exexog0,
	string scalar pexexog0,
	string scalar prexexog0,
	string scalar rc0,
	string scalar market0,
	string scalar demog_mean0,
	string scalar demog_cov0,
	string scalar demog_xvars0,
	string scalar msize0,
	string scalar firm0,
	string scalar vat0,
	string scalar estimator,
	string scalar optimal,
	string scalar integrationmethod,
	string scalar accuracy,
	string scalar draws,
	string scalar itol0,
	string scalar imaxiter0,
	string scalar startparams,
	string scalar delta00,
	string scalar robust,
	string scalar cluster0,
	string scalar touse,
	string scalar elvar0,
	string scalar prices0,
	string scalar rc_prices0,
	real scalar _is_rc_on_p0,
	string scalar nodisplay0
	)
{

	// declarations
	external real matrix endog,zd00,zp00,zpr00,rc,msumm,market_rows,xd,xp,xd0,xd00,zd,zp,wd,wp,w,pxdz,pxdz0,pxpz,simdraws,simdrawsw,wd0,demog_cov,dx,ds,ctmp,prices,rc_prices,dksi,domega
	external real colvector s,market,msize,obs,lns,s0,lnss0,p,delta0,delta_final,beta,gamma,elvar,firm,firm1,vat,product,demog_mean,delta_hat,vv,cluster,xb0,xb,ksi,omega,shat,mc,mrkp
	external real rowvector params0,params,eparams
	external real scalar ndvars,jj,tol,itol,imaxiter,dparams,ddelta,dwd,nsteps,kconv,ddelta0,dparams0,correction_last,corrections,w_update,klastconv,kk0,kk,value0,value,iterations,converged,r2,Fdf1,Fdf2,Fp,_is_rc_on_p,obj

	// load data
	st_view(s, .,share0,touse)
	st_view(xd0, .,tokens(iexog0),touse)
	st_view(xp, .,tokens(xp0),touse)
	if (endog0!="") {
		st_view(endog, .,tokens(endog0),touse)
	}
	if (exexog0!="") {
		st_view(zd00, .,tokens(exexog0),touse)
	}
	if (pexexog0!="") {
		st_view(zp00, .,tokens(pexexog0),touse)
	}
	if (prexexog0!="") {
		st_view(zpr00, .,tokens(prexexog0),touse)
	}
	st_view(rc, .,tokens(rc0),touse)
	st_view(market, .,tokens(market0),touse)
	if (demog_xvars0!="") {
		st_view(dx, .,tokens(demog_xvars0),touse)
		demog_mean=st_matrix(demog_mean0)
		demog_cov=st_matrix(demog_cov0)
	}
	st_view(msize, .,tokens(msize0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(vat, .,tokens(vat0),touse)
	if (delta00!="") {
		st_view(delta, .,tokens(delta00),touse)
	}
	cluster=runningsum(J(rows(market),1,1))
	if (cluster0!="") {
		st_view(cluster, .,tokens(cluster0),touse)
	}
	if (elvar0!="") {
		st_view(elvar, .,tokens(elvar0),touse)
	}
	if (prices0!="") {
		st_view(prices, .,tokens(prices0),touse)
	}
	if (rc_prices0!="") {
		st_view(rc_prices, .,tokens(rc_prices0),touse)
	}
	params0=abs(st_matrix(startparams))
	params0[1,cols(params0)]=-abs(params0[1,cols(params0)])
	params00=params0[1,1..cols(params0)-1]
	_is_rc_on_p=_is_rc_on_p0
	rseed(1)

	// index of observations
	obs=runningsum(J(rows(market),1,1))

	// reindexing (categorical variables should start from 1 and increment by 1)
	market=reindex(market)
	firm=reindex(firm)
	cluster=reindex(cluster)

	// summation matrix to calculate market specific sums
	for (mm=colmin(market); mm<=colmax(market); mm++) {
		if (mm==colmin(market)) {
			msumm=(market:==mm)
		}
		if (mm>colmin(market)) {
			msumm=msumm,(market:==mm)
		}
	}

	// log market shares, and outside good's share
	lns=ln(s)
	s0=rowsum((1:-(s'*msumm)):*msumm)
	lnss0=lns:-ln(s0)

	// price
	if (prices0=="") {
		if (endog0!="") {
			p=endog[.,1]
		}
		if (endog0=="") {
			p=xd0[.,1]
		}
	}
	if (prices0!="") {
		p=rowsum(prices)
	}

	// panel structure
	market_rows=panelsetup(market,1)
	if (rows(market_rows)<rows(market)) {
		market_rows=market_rows\J(rows(market)-rows(market_rows),cols(market_rows),0)
	}
	market_rows=select(market_rows,market_rows[.,1]:!=0)

	// linear regressors
	if (endog0!="") {
		xd=endog,xd0
	}
	if (endog0=="") {
		xd=xd0
	}
	xd00=xd[.,2..cols(xd)]

	// instruments
	if (exexog0!="") {
		zd=zd00,xd0
	}
	if (exexog0=="") {
		zd=xd
	}
	if (pexexog0!="") {
		zp=zp00,xp
	}
	if (pexexog0=="") {
		zp=xp
	}
	
	// initial weighting matrix
	wd=invsym(zd'*zd)
	wp=invsym(zp'*zp)
	w=wd,J(rows(wd),cols(wp),0)
	w=w\(J(rows(wp),cols(wd),0),wp)
	
	// linear IV estimator matrix
	pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
	if (endog0!="" & cols(endog)>1) {
		pxdz0=invsym(xd00'*zd*wd*zd'*xd00)*xd00'*zd*wd*zd'
	}
	else {
		pxdz0=invsym(xd00'*xd00)*xd00'
	}
	pxpz=invsym(xp'*xp)*xp'

	// number of demographic variables
	ndvars=0
	if (demog_xvars0!="") {
		ndvars=rows(demog_mean)
	}

	// matrix of taste shocks
	// columns correspond to "consumers"
	// rows correspond to variables with random coefficient
	// last row contains the weights of each "consumer"
	if (integrationmethod=="sparsegrid") {	// (Sparse Grid Integraion)
		simdraws=nwspgr("KPN", cols(rc)+ndvars, strtoreal(accuracy))
		simdraws=simdraws'
	}
	if (integrationmethod=="mc") {	// (Monte Carlo Integraion)
		rseed(1)
		rseed("X8baa4f2deba11618b2169652cd28c9a6000400c8")
		simdraws=rnormal(cols(rc)+ndvars,strtoreal(draws),0,1)
		simdraws=simdraws\J(1,cols(simdraws),1/cols(simdraws))
	}

	// transforming demographic variables' draws to have the (user given) distribution
	if (demog_xvars0!="") {
		simdrawsw=simdraws[rows(simdraws),.]
		ds=simdraws[cols(rc)+1..cols(rc)+rows(demog_mean),.]'
		ds=ds*((cholesky(demog_cov)')*qrinv(cholesky(variance(ds))'))
		ds=ds :+ demog_mean'
		simdraws=simdraws[1..cols(rc),.]
		for (jj=1; jj<=rows(demog_mean); jj++) {
			// adding taste shocks associated with demographics to the matrix of taste shocks
			simdraws=simdraws\((ds[.,jj]:*J(rows(ds),cols(dx),1))')
			// adding characteristics to be correlated with demographics (dx) to the matrix of variables-with-random-coefficient (rc)
			rc=rc,dx
		}
		simdraws=simdraws\simdrawsw
	}

	// starting values of mean utilities (simple logit)
	shat=s
	if (delta00=="") {
		delta0=blp_inner_loop(params00,lnss0,imaxiter,itol)
	}
	if (delta00!="") {
		delta0=delta
	}

	// tolerance
	tol=0.000001																		// tolerance bound for convergence of the sequence of ABLP estimators (k-loop)

	// tolerance and iteration limit for BLP inner loop
	itol=strtoreal(itol0)
	imaxiter=strtoreal(imaxiter0)

	// updating weighting matrix based on starting parameter vector and delta
	wd=wd(xd,zd,pxdz,delta0,robust,cluster)
	pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
	alpha=-params0[1,cols(params0)]
	alphai=(_is_rc_on_p==1)*(alpha:-(params0[1,1]*simdraws[1,.]))
	alphai=alphai :+ (_is_rc_on_p==0)*(alpha:*J(1,cols(simdraws),1))
	mc0=marginal_cost_blp(market,p,msize,vat,rc,delta0,firm,params00,simdraws,alpha,alphai)
	wp=wd(xp,zp,pxpz,mc0,robust,cluster)
	delta1=delta0:+(alpha*p)
	beta=pxdz0*delta1
	xb0=xd00*beta
	ksi=delta1-xb0
	gamma=pxpz*mc0
	xg=xp*gamma
	omega=mc0-xg
	w=w_blp_eq(xd,zd,pxdz,xp,zp,pxpz,delta0,mc0,robust,cluster,estimator)
	wd=w[1..cols(zd),1..cols(zd)]
	wp=w[cols(zd)+1..cols(zd)+cols(zp),cols(zd)+1..cols(zd)+cols(zp)]
	pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
	if (endog0!="" & cols(endog)>1) {
		pxdz0=invsym(xd00'*zd*wd*zd'*xd00)*xd00'*zd*wd*zd'
	}
	else {
		pxdz0=invsym(xd00'*xd00)*xd00'
	}
	pxpz=invsym(xp'*xp)*xp'
	delta=delta0
	delta_final=delta0
	params=params0

	// NFP estimation (BLP algorithm)
	rseed(1)
	params0=ln(params0[1,1..cols(params0)-1]),params0[1,cols(params0)]
	S=optimize_init()
	optimize_init_evaluator(S, &obj_blp_eq())
	optimize_init_evaluatortype(S, "d0")
	optimize_init_verbose(S, 0)
	if (nodisplay0!="") {
		optimize_init_tracelevel(S, "none")
	}
	optimize_init_params(S, params0)
	optimize_init_which(S, "min")
	optimize_init_technique(S, "nr")
	optimize_init_conv_maxiter(S, 150)
	optimize_init_conv_ignorenrtol(S, "on")
	dparams=1000																		// objective #1: max. abs. change in parameters
	ddelta=1000																			// objective #2: max. abs. change in mean utiltities
	dwd=1000																			// objective #3: max. abs. change in demand weighting matrix
	nsteps=1																			// 2SLS: 1 step of optimization (with initial weighting matrix)
	if (estimator=="gmm2s") {															// Two-step GMM: 2 steps of optimization (one update of weighting matrix)	
		nsteps=2
	}
	if (estimator=="igmm") {															// Iterated GMM: several steps of optimization until convergence of weighting matrix (max 100 rounds)
		nsteps=15
	}
	kconv=0
	correction_last=0
	corrections=0
	w0=w
	wd00=wd
	wp00=wp
	kk=0
	while (kk<nsteps & kconv==0) {	// GMM steps

		kk=kk+1

		// estimation (step kk)
		rseed(1)
		params=_optimize(S)
		params=optimize_result_params(S)
		value0=optimize_result_value0(S)
		value=optimize_result_value(S)
		iterations=optimize_result_iterations(S)
		converged=optimize_result_converged(S)

		// delta, marginal costs and linear parameters at the final parameter vector (delta, marginal costs and linear parameters ("delta_final", "mc", "beta", "gamma") are calculated by the "obj_blp_eq" function)
		eparams=exp(params[1,1..cols(params)-1])
		obj_blp_eq(0,params,0,0,0)
		delta=delta_final
		if (value!=. & colmissing(delta)==0) {
			correction_last=0
		}
		if (value==. | colmissing(delta)>0) {
			corrections=corrections+1
			if (correction_last==0) {
				"CORRECTION "+strofreal(corrections)+" (kk="+strofreal(kk)+")"
			}
			if (correction_last!=0) {
				rseed(kk)
				params=runiform(1,cols(params))
				"CORRECTION "+strofreal(corrections)+" (kk="+strofreal(kk)+")"+" PARAMS RESET"
			}
			delta=lnss0
			eparams=exp(params[1,1..cols(params)-1])
			delta=blp_inner_loop(eparams,delta0,imaxiter,itol)
			if (estimator=="gmm2s" | estimator=="igmm") {
				pxdz=invsym(xd'*zd*wd00*zd'*xd)*xd'*zd*wd00*zd'
				if (endog0!="" & cols(endog)>1) {
					pxdz0=invsym(xd00'*zd*wd00*zd'*xd00)*xd00'*zd*wd00*zd'
				}
				else {
					pxdz0=invsym(xd00'*xd00)*xd00'
				}
				pxpz=invsym(xp'*xp)*xp'
				w=w_blp_eq(xd,zd,pxdz,xp,zp,pxpz,delta,mc,robust,cluster,estimator)
				wd=w[1..cols(zd),1..cols(zd)]
				wp=w[cols(zd)+1..cols(zd)+cols(zp),cols(zd)+1..cols(zd)+cols(zp)]
				pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
				if (endog0!="" & cols(endog)>1) {
					pxdz0=invsym(xd00'*zd*wd*zd'*xd00)*xd00'*zd*wd*zd'
				}
				else {
					pxdz0=invsym(xd00'*xd00)*xd00'
				}
				pxpz=invsym(xp'*xp)*xp'
			}
			if (colmissing(delta)>0) {
				delta=lnss0
			}
			correction_last=1
		}
		
		// updating weighting matrix based on step-k parameter vector
		if (estimator=="gmm2s" | estimator=="igmm" | robust!="" | cluster0!="") {
			w=w_blp_eq(xd,zd,pxdz,xp,zp,pxpz,delta,mc,robust,cluster,estimator)
			wd=w[1..cols(zd),1..cols(zd)]
			wp=w[cols(zd)+1..cols(zd)+cols(zp),cols(zd)+1..cols(zd)+cols(zp)]
			pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
			if (endog0!="" & cols(endog)>1) {
				pxdz0=invsym(xd00'*zd*wd*zd'*xd00)*xd00'*zd*wd*zd'
			}
			else {
				pxdz0=invsym(xd00'*xd00)*xd00'
			}
			pxpz=invsym(xp'*xp)*xp'
		}

		// convergence criteria for step-k
		dparams=rowmax(abs(abs(params):-abs(params0)))
		ddelta=colmax(abs(delta:-delta0))
		dw=max(abs(w:-w0))
		if (dparams<=tol & dw<0.0005 & estimator=="igmm") {
			kconv=1
		}
		
		// storing
		params0=params																	// storing starting parameters
		delta0=delta																	// storing starting delta
		w0=w																			// storing weighting matrix
		kk0=kk

		// updating
		optimize_init_params(S, params)													// updating starting parameters
		delta=delta0																	// updating starting delta
		w=w0																			// updating weighting matrix
		
	}	// end of loop of GMM steps

	// estimated non-linear parameters
	params=exp(params[1,1..cols(params)-1]),params[1,cols(params)]

	// variance-covariance matrix
	V=V_blp_eq(params,w,robust,cluster)

	// full row vector of coefficients
	b=(params,beta',gamma')
	for (i=1; i<=cols(b); i++) {
		if (b[1,i]==.) {
			b[1,i]=0
		}
		if (missing(V[.,i])>0 | missing(V[i,.])>0) {
			V[.,i]=J(rows(V),1,0)
			V[i,.]=J(1,cols(V),0)
		}
	}
	for (i=1; i<=cols(params); i++) {
		if (params[1,i]==.) {
			params[1,i]=0
		}
	}
	for (i=1; i<=cols(beta); i++) {
		if (beta[1,i]==.) {
			beta[1,i]=0
		}
	}

	// Hansen's J-test value, p-value and degrees of freedom
	lparams=ln(params[1,1..cols(params)-1]),params[1,cols(params)]
	obj_blp_eq(0,lparams,obj,0,0)
	j=obj
	jdf=cols(zd)+cols(zp)-cols(xd)-cols(xp)-cols(rc)
	jp=chi2tail(jdf,j)
	
	// pseudo R2 (fit of delta)
	xb0=xd00*beta																		// non-price specific mean observed utility component
	rss_d=quadcross(ksi,ksi)
	yyc_d=quadcrossdev(delta,mean(delta),delta,mean(delta))
	rss_p=quadcross(omega,omega)
	yyc_p=quadcrossdev(p,mean(p),p,mean(p))
	r2=1-rss_d/yyc_d
	r2_d=1-rss_d/yyc_d
	r2_p=1-rss_p/yyc_p
	r2_a=1-(rss_d/yyc_d)*(rows(delta)-1)/(rows(delta)-cols(params)-cols(beta'))
	r2_a_d=1-(rss_d/yyc_d)*(rows(delta)-1)/(rows(delta)-cols(params)-cols(beta'))
	r2_a_p=1-(rss_p/yyc_p)*(rows(delta)-1)/(rows(delta)-cols(params)-cols(gamma'))

	// F-test
	vv=diagonal(V)
	F=sum( (b[1,1..cols(b)-1]:^2) :/ (vv[1..cols(b)-1,1]') )/( cols(b)-1 )
	Fdf1=cols(b)-1
	Fdf2=rows(uniqrows(cluster))-cols(b)
	Fp=Ftail(Fdf1,Fdf2,F)

	// elasticities and diversion ratios
	if (elvar0!="") {
		elasticities_rcl(params[1,cols(params)],params[1,1..cols(params)-1],delta,elvar)
	}

	// calculating the optimal instruments
	if (optimal!="" & exexog0!="" & pexexog0!="" & prexexog0!="") {
			params_alt=params
			params_alt00=params[1,1..cols(params)-1]
			delta_alt=delta
			params_alt00=((abs(params_alt00):>0.00001):*params_alt00) :+ ((abs(params_alt00):<=0.00001)*0.1)
			delta_alt=blp_inner_loop(params_alt00,delta,imaxiter,itol)
			params_alt=params_alt00,params[1,cols(params)]
		opti=opti_blp_eq(params_alt,delta_alt,mc,ksi,omega)
		odksi=opti[.,1..cols(rc)]
		op_hat=opti[.,cols(rc)+1]
		odomega=opti[.,cols(rc)+2..cols(opti)]
	}

	// exporting results into Stata
	rcnames=tokens(rc0)
	if (demog_xvars0!="") {
		dvarnames=st_matrixrowstripe(demog_mean0)
		dvarnames=dvarnames[.,2]
		dxvarnames=tokens(demog_xvars0)'
		for (jj=1; jj<=rows(demog_mean); jj++) {
			rcnames=rcnames,(dvarnames[jj] :+ " " :+ dxvarnames)'
		}
	}
	colnames=(J(cols(rc),1,"sigmas")\J(cols(endog),1,"endogenous")\J(cols(xd0),1,"demand")\J(cols(xp),1,"pricing")),((rcnames,tokens(endog0),tokens(iexog0),tokens(xp0))')
	st_matrix("b", b)
	st_matrixcolstripe("b", colnames)
	st_matrix("V", V)
	st_matrixrowstripe("V", colnames)
	st_matrixcolstripe("V", colnames)
	st_numscalar("j", j)
	st_numscalar("jp", jp)
	st_numscalar("jdf", jdf)
	st_numscalar("r2", r2)
	st_numscalar("r2_d", r2_d)
	st_numscalar("r2_p", r2_p)
	st_numscalar("r2_a", r2_a)
	st_numscalar("r2_a_d", r2_a_d)
	st_numscalar("r2_a_p", r2_a_p)
	st_numscalar("F", F)
	st_numscalar("Fp", Fp)
	st_numscalar("Fdf1", Fdf1)
	st_numscalar("Fdf2", Fdf2)
	stata("capture drop __xb0")
	stata("quietly generate __xb0=.")
	st_store( .,"__xb0",touse,xb0)
	stata("capture drop __ksi")
	stata("quietly generate __ksi=.")
	st_store( .,"__ksi",touse,ksi)
	stata("capture drop __delta")
	stata("quietly generate __delta=.")
	st_store( .,"__delta",touse,delta)
	stata("capture drop __shat")
	stata("quietly generate __shat=.")
	st_store( .,"__shat",touse,shat)
	stata("capture drop __mc")
	stata("quietly generate __mc=.")
	st_store( .,"__mc",touse,mc)
	stata("capture drop __mrkp")
	stata("quietly generate __mrkp=.")
	st_store( .,"__mrkp",touse,mrkp)
	stata("capture drop __omega")
	stata("quietly generate __omega=.")
	st_store( .,"__omega",touse,omega)
	if (optimal!="" & exexog0!="" & pexexog0!="" & prexexog0!="") {
		stata("capture drop __optiek*")
		for (i=1; i<=cols(odksi); i++) {
			name = sprintf("%s%g", "__optiek", i)
			st_store(., st_addvar("double", name),touse, odksi[.,i])
		}
		stata("capture drop __optiep*")
		st_store(., st_addvar("double", "__optiep"),touse, op_hat)
		stata("capture drop __optieo*")
		for (i=1; i<=cols(odomega); i++) {
			if (i<cols(odomega)) {
				name = sprintf("%s%g", "__optieo", i)
				st_store(., st_addvar("double", name),touse, odomega[.,i])
			}
			if (i==cols(odomega)) {
				name = "__optieop"
				st_store(., st_addvar("double", name),touse, odomega[.,i])
			}
		}
	}

}	// end of estimation_blp_eq function
mata mlib add lrcl estimation_blp_eq()


// function generating the optimal instruments (equiblirium BLP model)
real matrix opti_blp_eq(
	real rowvector params0,
	real colvector delta0,
	real colvector mc0,
	real colvector ksi0,
	real colvector omega0
	)
{

	// declarations
	external real matrix rc,msumm,market_rows,simdraws,xd0,xd,xp,zd00,zpr00,pxdz0,pxdz,pxpz,endog
	external real colvector market,firm,vat
	external real scalar _is_rc_on_p
	real matrix mu,xpr,pxpxp,p_hat,xd_hat,rc_hat,shati,dmc,shatim,rcm,dsdsigma,ddelta,dsddelta,dxb,dksi,dshatidsigma,eji,seji,deji,dseji,msumf,ashatim,ashatimw,dsdp,dsdpmsumf,idsdpmsumf,dshatidsigmakm,dsashatim,ddsdp,ddsdpmsumf,didsdpmsumf,dxg,domega
	real colvector sigmas,delta1,delta,beta,shat,shatm,firmm,vatm,pm,productm,sashatim
	real rowvector alphai
	real scalar alpha

	// variance-covariance matrix of first-step demand and supply residuals
	ohm=quadvariance((ksi0,omega0))
	iohm=invsym(ohm)

	// parameters
	sigmas=params0[1,1..cols(rc)]'															// vector of random coefficient parameters
	alpha=-params0[1,cols(params0)]															// alpha: negative of coefficient on price in the mean utility
	alphai=(_is_rc_on_p==1)*(alpha:-(sigmas[1,1]*simdraws[1,.]))							// individual price coefficients (if there is random coefficient on price)
	alphai=alphai :+ (_is_rc_on_p==0)*(alpha:*J(1,cols(simdraws),1))						// individual price coefficients (if there is no random coefficient on price)

	// I. predicted endogenous variables of the mean utility (conditional expectation of the derivative of the error term (ksi) wrt. the mean utility's respective coefficient; typically this means only the price variable and its coefficient)
	// this reduced form price prediction is the preferred solution of Reynaert and Verboven [Improving the Performance of Random Coefficients Demand Models: the Role of Optimal Instruments, Journal of Econometrics, 2014 (April 2012), 179(1), 83-98.]
	xpr=zpr00,xd0
	pxpxp=invsym(xpr'*xpr)*xpr'
	p_hat=xpr*(pxpxp*endog)

	// predicted mean utilities (assuming ksi=0)
	delta1=delta0:+(alpha*endog[.,1])														// mean utility without the price component
	beta=pxdz0*delta1																		// linear parameters (on rhs variables other than price)
 	beta=(-alpha)\beta																		// linear parameters
	xd_hat=xd																				// predicted mean utility variables (price is replaced with its prediction)
	xd_hat[.,1..cols(p_hat)]=p_hat
	delta=xd_hat*beta																		// predicted mean utilities

	// matrix of observed consumer heterogeneity (separate column for each consumer)
	rc_hat=rc
	if (_is_rc_on_p==1) {																	// replace price with predicted price (from I.) in list of variables with random coefficient, if relevant
		rc_hat[.,1]=p_hat
	}
	mu=rc_hat*(sigmas:*simdraws[1..rows(simdraws)-1,.])

	// predicted individual choice probabilities and market shares
	shati=exp(delta:+mu)
	shati=shati:/(1:+msumm*((shati'*msumm)'))
	shat=shati*simdraws[rows(simdraws),.]'
	
	// derivative of predicted mean utilities wrt. random coefficients
	dsdsigma=J(rows(delta),cols(rc),0)														// derivative of predicted market shares wrt. random coefficients (to be filled up)
	ddelta=J(rows(delta),cols(rc),0)														// derivative of mean utilities wrt. random coefficients (to be filled up)
	dmc=J(rows(delta),cols(rc),0)															// derivative of implied marginal costs wrt. random coefficients (to be filled up)
	for (mm=1; mm<=rows(market_rows); mm++) {												// calculations by market
		// observations of the selected market
		shatim=panelsubmatrix(shati,mm,market_rows)
		rcm=panelsubmatrix(rc_hat,mm,market_rows)
		// derivative of predicted market shares wrt. random coefficients
		dsdsigmam= ( rcm:*((shatim:*(simdraws[rows(simdraws),.]))*(simdraws[1..rows(simdraws)-1,.]')) ) :- (shatim:*(simdraws[rows(simdraws),.]))*( (simdraws[1..rows(simdraws)-1,.]:*(rcm'*shatim))' )
		dsdsigma[market_rows[mm,1]..market_rows[mm,2],.]=dsdsigmam
		// derivative of predicted market shares wrt. mean utilities
		_diag( dsddelta=-(shatim:*(simdraws[rows(simdraws),.]))*shatim', diagonal( (shatim:*(simdraws[rows(simdraws),.]))*( 1:-(shatim') ) ) )
		// filling up: derivative of mean utilities wrt. random coefficients
		ddelta[market_rows[mm,1]..market_rows[mm,2],.]=luinv(dsddelta)*dsdsigmam
	}

	// derivative of predicted individual choice probabilities and market shares wrt. random coefficients and mean price coefficient
	dshatidsigma=J(rows(delta),cols(rc)*cols(simdraws),0)
	eji=exp(delta:+mu)
	seji=(1:+msumm*((eji'*msumm)'))
	for (kk=1; kk<=cols(rc); kk++) {
		xv=rc_hat[.,kk]*simdraws[kk,.]
		deji=xv:*eji
		dseji=msumm*(msumm'*(xv:*eji))
		dshatidsigma[.,1+(kk-1)*cols(simdraws)..kk*cols(simdraws)]=( (deji:/seji) :- (eji:/seji):*(dseji:/seji) )
	}
	dshatidalpha=J(rows(delta),cols(simdraws),0)
	dsdalpha=J(rows(delta),1,0)
	deji=-p_hat:*eji
	dseji=-msumm*(msumm'*(p_hat:*eji))
	dshatidalpha[.,1..cols(simdraws)]=( (deji:/seji) :- (eji:/seji):*(dseji:/seji) )
	dsdalpha[.,1]=( (deji:/seji) :- (eji:/seji):*(dseji:/seji) )*simdraws[rows(simdraws),.]'

	// derivative of implied marginal costs wrt. random coefficients and mean price coefficient
	dmcalpha=J(rows(delta),1,0)																// derivative of implied marginal costs wrt. alpha (to be filled up)
	for (mm=1; mm<=rows(market_rows); mm++) {												// calculations by market

		// observations of the selected market
		shatim=panelsubmatrix(shati,mm,market_rows)
		shatm=panelsubmatrix(shat,mm,market_rows)
		firmm=panelsubmatrix(firm,mm,market_rows)
		vatm=panelsubmatrix(vat,mm,market_rows)
		pm=panelsubmatrix(endog[.,1],mm,market_rows)
		productm=runningsum(J(rows(shatm),1,1))
		msumf=amsumf(productm,firmm)
		ashatim=alphai:*shatim
		ashatimw=(ashatim):*simdraws[rows(simdraws),.]
		sashatim=(ashatim)*simdraws[rows(simdraws),.]'
		dsdp=(ashatim:*(simdraws[rows(simdraws),.]))*(shatim') :- diag(sashatim)			// matrix of price derivatives
		dsdpmsumf=dsdp':*msumf

		// inverse of the block-diagonal matrix dsdpmsumf (inverting by blocks)
		idsdpmsumf=J(rows(dsdpmsumf),rows(dsdpmsumf),0)
		for (ff=colmin(firmm); ff<=colmax(firmm); ff++) {
			idsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)]=qrinv(dsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)])
		}

		// filling up derivative of implied marginal costs wrt. random coefficients and mean price coefficient
		for (kk=1; kk<=cols(rc); kk++) {
			dshatidsigmakm=dshatidsigma[market_rows[mm,1]..market_rows[mm,2],1+(kk-1)*cols(simdraws)..kk*cols(simdraws)]
			dsashatim=((alphai:*dshatidsigmakm)*simdraws[rows(simdraws),.]')
			ddsdp=(dshatidsigmakm*ashatimw') :+ (ashatimw*dshatidsigmakm')
			if (kk==1 & _is_rc_on_p==1) {													// adding terms to the derivatives wrt. the random coefficient on price
				dsashatim=dsashatim :-  ((simdraws[kk,.]:*shatim)*simdraws[rows(simdraws),.]')
				ddsdp=ddsdp :- (simdraws[kk,.]:*(simdraws[rows(simdraws),.]):*(shatim))*(shatim')
			}
			ddsdp=ddsdp :- diag(dsashatim)
			ddsdpmsumf=(ddsdp'):*msumf
			didsdpmsumf=-(idsdpmsumf')*ddsdpmsumf*idsdpmsumf
			dmc[market_rows[mm,1]..market_rows[mm,2],kk]=-( (didsdpmsumf)*(shatm:/(1:+vatm)) :+ (idsdpmsumf)*(dsdsigma[market_rows[mm,1]..market_rows[mm,2],kk]:/(1:+vatm)) )
		}
		dshatidalpham=dshatidalpha[market_rows[mm,1]..market_rows[mm,2],.]
		dsashatima=(shatim :+ alphai:*dshatidalpham)*simdraws[rows(simdraws),.]'
		ddsdpa=((shatim :+ alphai:*dshatidalpham):*simdraws[rows(simdraws),.])*(shatim') :+ ((ashatim:*simdraws[rows(simdraws),.])*dshatidalpham')
		ddsdpa=ddsdpa :- diag(dsashatima)
		ddsdpamsumf=(ddsdpa'):*msumf
		didsdpamsumf=-(idsdpmsumf')*ddsdpamsumf*idsdpmsumf
		dmcalpha[market_rows[mm,1]..market_rows[mm,2],1]=(didsdpamsumf)*(shatm:/(1:+vatm)) :+ (idsdpmsumf)*(dsdalpha[market_rows[mm,1]..market_rows[mm,2],1]:/(1:+vatm))

	}

	// II. conditional expectation of the derivative of the demand error term (ksi) wrt. random coefficients
	dxb=xd_hat[.,2..cols(xd_hat)]*(pxdz0*ddelta)
	dksi=ddelta-dxb

	// III. conditional expectation of the derivative of the price error term (omega) wrt. random coefficients and mean price coefficient
	dmc=dmc,(-dmcalpha)
	dxg=xp*(pxpz*dmc)
	domega=dmc-dxg
	domegads=domega[.,1..cols(rc)]
	domegada=domega[.,cols(domega)]
	
	// IV. weighting by the inverse of the variance-covariance matrix of first-step demand-supply residuals
	da=(p_hat,domegada)*iohm
	p_hat=da[.,1]
	domegada=da[.,2]
	for (kk=1; kk<=cols(rc); kk++) {
		ds=(dksi[.,kk],domegads[.,kk])*iohm
		dksi[.,kk]=ds[.,1]
		domegads[.,kk]=ds[.,2]
	}
	domega=domegads,domegada

	// optimal instruments
	opti=dksi,p_hat,domega
	return(opti)

}	// end of opti_blp_eq function
mata mlib add lrcl opti_blp_eq()


// pointer generating the GMM objective (equilibrium BLP model, BLP algorithm)
void obj_blp_eq(todo,params,obj,grad,H)
{

	// declarations
	external real matrix rc,xd,xd00,xp,zd,zp,msumm,market_rows,simdraws,pxdz,pxdz0,pxpz,wd,wp,w,dksi,domega
	external real colvector market,obs,lns,delta0,delta_final,firm,firm1,vat,p,ksi,omega,mc,mrkp,beta,gamma
	external real scalar itol,imaxiter,obj,_is_rc_on_p
	real matrix mu,emu,emum,msummm,shati,shatim,rcm,dsdsigma,ddelta,dsddelta,dxb,msumf,ashatim,ashatimw,sashatim,dsdp,dsdpmsumf,idsdpmsumf
	real colvector sigmas,delta,delta1,shat,lnsm,sm,wm,shatm,deltam,xb,firmm,firm1m,vatm,pm,xg
	real scalar iitol,i,dif,ff

	// parameters
	alpha=-params[1,cols(params)]															// alpha: negative of coefficient on price in the mean utility
	sigmas=exp(params[1,1..cols(rc)]')														// vector of random coefficient parameters
	mu=rc*(sigmas:*simdraws[1..rows(simdraws)-1,.])											// matrix of observed consumer heterogeneity (separate column for each consumer)
	emu=exp(mu)

	// mean utilities (inner loop of BLP algorithm: market share inversion)
	delta=delta0
	dsdsigma=J(rows(delta),cols(rc),0)														// derivative of predicted market shares wrt. random coefficients (to be filled up)
	ddelta=J(rows(delta),cols(rc),0)														// derivative of mean utilities wrt. random coefficients (to be filled up)
	dmc=J(rows(delta),cols(rc),0)															// derivative of implied marginal costs wrt. random coefficients (to be filled up)
	dmcalpha=J(rows(delta),1,0)																// derivative of implied marginal costs wrt. alpha (to be filled up)
	shati=J(rows(delta),cols(simdraws),0)
	shat=J(rows(delta),1,0)
	mdif=0
	for (mm=1; mm<=rows(market_rows); mm++) {												// calculations by market

		lnsm=panelsubmatrix(lns,mm,market_rows)
		sm=exp(lnsm)
		emum=panelsubmatrix(emu,mm,market_rows)
		msummm=panelsubmatrix(msumm[.,mm],mm,market_rows)
		wm=exp(panelsubmatrix(delta,mm,market_rows))
		shatim=wm:*emum																		// predicted individual choice probabilities
		shatim=shatim:/(1:+msummm*((shatim'*msummm)'))
		shatm=shatim*simdraws[rows(simdraws),.]'											// predicted market shares
		iitol=itol
		i=0
		while(mreldif(ln(shatm),ln(sm))>iitol & i<imaxiter) {
			i=i+1
			wm=wm:*(sm:/shatm)
			shatim=wm:*emum																	// predicted individual choice probabilities
			shatim=shatim:/(1:+msummm*((shatim'*msummm)'))
			shatm=shatim*simdraws[rows(simdraws),.]'										// predicted market shares
			dif=mreldif(ln(shatm),ln(sm))
			//mm,i,dif
		}
		if (mreldif(ln(shatm),ln(sm))>mdif) mdif=mreldif(ln(shatm),ln(sm))
		//mm,i,mreldif(ln(shatm),ln(sm))
		deltam=wm

		// gradient I./IV.: derivative of mean utilities wrt. random coefficients
		if (todo>=1) {
			// derivative of predicted market shares wrt. random coefficients
			rcm=panelsubmatrix(rc,mm,market_rows)
			dsdsigmam= ( rcm:*((shatim:*(simdraws[rows(simdraws),.]))*(simdraws[1..rows(simdraws)-1,.]')) ) :- (shatim:*(simdraws[rows(simdraws),.]))*( (simdraws[1..rows(simdraws)-1,.]:*(rcm'*shatim))' )
			dsdsigmam=dsdsigmam*(diag(sigmas))
			dsdsigma[market_rows[mm,1]..market_rows[mm,2],.]=dsdsigmam
			// derivative of predicted market shares wrt. mean utilities
			_diag( dsddelta=-(shatim:*(simdraws[rows(simdraws),.]))*shatim', diagonal( (shatim:*(simdraws[rows(simdraws),.]))*( 1:-(shatim') ) ) )
			// filling up: derivative of mean utilities wrt. random coefficients
			ddelta[market_rows[mm,1]..market_rows[mm,2],.]=luinv(dsddelta)*dsdsigmam
		}
		
		// filling up: mean utilities, individual choice probabilities, market shares
		delta[market_rows[mm,1]..market_rows[mm,2],.]=deltam
		shati[market_rows[mm,1]..market_rows[mm,2],.]=shatim
		shat[market_rows[mm,1]..market_rows[mm,2],.]=shatm

	}
	delta=ln(delta)
	if (colmissing(delta)>0) {
		delta=delta0
	}
	if (mdif<=iitol) {
		delta_final=delta
	}

	// demand error term and linear demand parameters
	delta1=delta:+(alpha*p)																	// mean utility without the price component
	beta=pxdz0*delta1																		// linear parameters (on rhs variables other than price)
	xb0=xd00*beta																			// linear predictions (from rhs variables other than price)
	ksi=delta1-xb0																			// error term (unobserved product characteristics)

	// gradient II./IV.: derivative of predicted individual choice probabilities and market shares wrt. random coefficients and mean price coefficient
	if (todo>=1) {
		dshatidsigma=J(rows(delta),cols(rc)*cols(simdraws),0)
		dsdsigma=J(rows(delta),cols(rc),0)
		eji=exp(delta:+mu)
		seji=(1:+msumm*((eji'*msumm)'))
		for (kk=1; kk<=cols(rc); kk++) {
			xv=rc[.,kk]*simdraws[kk,.]
			deji=xv:*eji
			dseji=msumm*(msumm'*(xv:*eji))
			dshatidsigma[.,1+(kk-1)*cols(simdraws)..kk*cols(simdraws)]=( (deji:/seji) :- (eji:/seji):*(dseji:/seji) )
			dsdsigma[.,kk]=( (deji:/seji) :- (eji:/seji):*(dseji:/seji) )*simdraws[rows(simdraws),.]'
		}
		dshatidalpha=J(rows(delta),cols(simdraws),0)
		dsdalpha=J(rows(delta),1,0)
		deji=-p:*eji
		dseji=-msumm*(msumm'*(p:*eji))
		dshatidalpha[.,1..cols(simdraws)]=( (deji:/seji) :- (eji:/seji):*(dseji:/seji) )
		dsdalpha[.,1]=( (deji:/seji) :- (eji:/seji):*(dseji:/seji) )*simdraws[rows(simdraws),.]'
	}

	// price equation
	alphai=(_is_rc_on_p==1)*(alpha:-(sigmas[1,1]*simdraws[1,.]))							// individual price coefficients (if there is random coefficient on price)
	alphai=alphai :+ (_is_rc_on_p==0)*(alpha:*J(1,cols(simdraws),1))						// individual price coefficients (if there is no random coefficient on price)
	mc=J(rows(delta),1,0)																	// implied marginal costs (to be filled up)
	mrkp=J(rows(delta),1,0)																	// implied markups (to be filled up)
	for (mm=1; mm<=rows(market_rows); mm++) {												// calculations by market

		// auxiliary variables
		shatim=panelsubmatrix(shati,mm,market_rows)
		shatm=panelsubmatrix(shat,mm,market_rows)
		firmm=panelsubmatrix(firm,mm,market_rows)
		vatm=panelsubmatrix(vat,mm,market_rows)
		pm=panelsubmatrix(p,mm,market_rows)
		productm=runningsum(J(rows(shatm),1,1))
		msumf=amsumf(productm,firmm)
		ashatim=alphai:*shatim
		ashatimw=(ashatim):*simdraws[rows(simdraws),.]
		sashatim=(ashatim)*simdraws[rows(simdraws),.]'
		dsdp=(ashatim:*(simdraws[rows(simdraws),.]))*(shatim') :- diag(sashatim)			// matrix of price derivatives
		dsdpmsumf=dsdp':*msumf

		// inverse of the block-diagonal matrix dsdpmsumf (inverting by blocks)
		idsdpmsumf=J(rows(dsdpmsumf),rows(dsdpmsumf),0)
		for (ff=colmin(firmm); ff<=colmax(firmm); ff++) {
			idsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)]=qrinv(dsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)])
		}

		// filling up implied marginal costs and markups
		mc[market_rows[mm,1]..market_rows[mm,2],.]=(pm:/(1:+vatm)) :+ (idsdpmsumf)*(shatm:/(1:+vatm))
		mrkp[market_rows[mm,1]..market_rows[mm,2],.]=-(idsdpmsumf)*(shatm:/(1:+vatm))

		// gradient III./IV.: filling up derivative of implied marginal costs wrt. random coefficients
		if (todo>=1) {
			for (kk=1; kk<=cols(rc); kk++) {
				dshatidsigmakm=dshatidsigma[market_rows[mm,1]..market_rows[mm,2],1+(kk-1)*cols(simdraws)..kk*cols(simdraws)]
				dsashatim=((alphai:*dshatidsigmakm)*simdraws[rows(simdraws),.]')
				ddsdp=(dshatidsigmakm*ashatimw') :+ (ashatimw*dshatidsigmakm')
				if (kk==1 & _is_rc_on_p==1) {												// adding terms to the derivatives wrt. the random coefficient on price
					dsashatim=dsashatim :-  ((simdraws[kk,.]:*shatim)*simdraws[rows(simdraws),.]')
					ddsdp=ddsdp :- (simdraws[kk,.]:*(simdraws[rows(simdraws),.]):*(shatim))*(shatim')
				}
				ddsdp=ddsdp :- diag(dsashatim)
				ddsdpmsumf=(ddsdp'):*msumf
				didsdpmsumf=-(idsdpmsumf')*ddsdpmsumf*idsdpmsumf
				dmc[market_rows[mm,1]..market_rows[mm,2],kk]=(didsdpmsumf)*(shatm:/(1:+vatm)) :+ (idsdpmsumf)*(dsdsigma[market_rows[mm,1]..market_rows[mm,2],kk]:/(1:+vatm))
				dmc[market_rows[mm,1]..market_rows[mm,2],kk]=dmc[market_rows[mm,1]..market_rows[mm,2],kk]*sigmas[kk]
			}
			dshatidalpham=dshatidalpha[market_rows[mm,1]..market_rows[mm,2],.]
			dsashatima=(shatim :+ alphai:*dshatidalpham)*simdraws[rows(simdraws),.]'
			ddsdpa=((shatim :+ alphai:*dshatidalpham):*simdraws[rows(simdraws),.])*(shatim') :+ ((ashatim:*simdraws[rows(simdraws),.])*dshatidalpham')
			ddsdpa=ddsdpa :- diag(dsashatima)
			ddsdpamsumf=(ddsdpa'):*msumf
			didsdpamsumf=-(idsdpmsumf')*ddsdpamsumf*idsdpmsumf
			dmcalpha[market_rows[mm,1]..market_rows[mm,2],1]=(didsdpamsumf)*(shatm:/(1:+vatm)) :+ (idsdpmsumf)*(dsdalpha[market_rows[mm,1]..market_rows[mm,2],1]:/(1:+vatm))
		}

	}

	// price error term and linear parameters of the price equation
	gamma=pxpz*mc																			// linear parameters of the price equation
	xg=xp*gamma																				// linear predictions of the marginal costs
	omega=mc-xg																				// price error term (unobserved marginal cost shocks)

	// objective
	q=(zd'*ksi)\(zp'*omega)																	// stacked vector of empirical moments
	obj=q'*w*q/rows(market)																	// GMM objective: quadratic form of moments

	// gradient IV./IV.: 
	if (todo>=1) {
		// derivative of error term (ksi) wrt. random coefficients
		ddelta1=ddelta,p
		dxb0=xd00*(pxdz0*ddelta1)
		dksi=ddelta1-dxb0
		// derivative of price equation error term (omega) wrt. random coefficients
		dmc=dmc,(-dmcalpha)
		dxg=xp*(pxpz*dmc)
		domega=dmc-dxg
		domega=-domega
		// derivative of stacked moment vector wrt. random coefficients
		dq=(zd'*dksi)\(zp'*domega)
		// gradient
		grad=-2*q'*w*dq/rows(market)
	}
	
}	// end of GMM demand objective pointer (BLP algorithm)
mata mlib add lrcl obj_blp_eq()


// weigthing matrix
pointer matrix w_blp_eq(
	real matrix xd,
	real matrix zd,
	real matrix pxdz,
	real matrix xp,
	real matrix zp,
	real matrix pxpz,
	real colvector delta,
	real colvector mc,
	string scalar robust,
	real colvector cluster,
	string scalar estimator)
{

	// declarations
	external real colvector market,ksi,omega
	real matrix sd,sp,sdp,iw,w,wd,wp,ze,lambda,sums,zec
	real colvector beta,xb,gamma,xg
	real rowvector uc
	real scalar sd2,sp2,sdp2

	// weighting matrix
	if (robust=="") {																	// non-robust case
		sd2=ksi'*ksi/rows(market)
		sd=(sd2/rows(market))*(zd'*zd)
		sp2=omega'*omega/rows(market)
		sp=(sp2/rows(market))*(zp'*zp)
		sdp2=ksi'*omega/rows(market)
		sdp=(sdp2/rows(market))*(zd'*zp)
		if (estimator=="2sls") {
			iw=(sd,J(cols(zd),cols(zp),0))\(J(cols(zp),cols(zd),0),sp)
		}
		if (estimator!="2sls") {
			iw=(sd,sdp)\(sdp',sp)
		}
		w=invsym(iw)
		wd=w[1..rows(sd),1..cols(sd)]
		wp=w[rows(sd)+1..rows(sd)+rows(sp),cols(sd)+1..cols(sd)+cols(sp)]
	}
	uc=uniqrows(cluster)'
	if (robust!="" | (cols(uc)!=rows(cluster))) {										// robust and/or cluster robust case
		ze=(zd:*ksi),(zp:*omega)
		lambda=quadcross(ze,ze)/rows(market)
		if (cols(uc)!=rows(cluster)) {													// cluster robust case
			lambda=J(cols(ze),cols(ze),0)
			for (c=1; c<=rowmax(uc); c++) {
				zec=select(ze,cluster:==c)
				lambda=lambda :+ quadcross(zec,zec)/cols(uc)
			}
			lambda=lambda*(cols(uc)/rows(market))
		}
		if (estimator=="2sls") {
			lambda=(lambda[1..cols(zd),1..cols(zd)],J(cols(zd),cols(zp),0))\(J(cols(zp),cols(zd),0),lambda[cols(zd)+1..cols(zd)+cols(zp),cols(zd)+1..cols(zd)+cols(zp)])
		}
		w=invsym(lambda)
		wd=w[1..cols(zd),1..cols(zd)]
		wp=w[cols(zd)+1..cols(zd)+cols(zp),cols(zd)+1..cols(zd)+cols(zp)]
	}
	return(w)

}	// end of w_blp_eq function
mata mlib add lrcl w_blp_eq()


// variance-covariance matrix of the equilibrium BLP parameter estimates
pointer matrix V_blp_eq(
	real rowvector params,
	real matrix w,
	string scalar robust,
	real colvector cluster)
{
	external real matrix zd,zp,xd00,xp,dksi,domega,wd,wp
	external real colvector market,ksi,omega
	real matrix grad,V
	real colvector q
	real rowvector uc,epsilon,lparams,paramsi
	real scalar epsiloni

	// derivatives of estimated error terms (dksi, domega) evaluated at the parameter vector
	lparams=ln(params[1,1..cols(params)-1]),params[1,cols(params)]
	obj_blp_eq(1,lparams,0,0,0)																// getting error terms (ksi and omega)
	q=(zd'*ksi)\(zp'*omega)																	// stacked vector of empirical moments
	dksi=J(rows(market),cols(params),0)														// derivatives of demand equation's error term wrt. parameters (to be filled up)
	domega=J(rows(market),cols(params),0)													// derivatives of price equation's error term wrt. parameters (to be filled up)
	epsilon=J(1,cols(params),0.0000001)
	for (i=1; i<=cols(params); i++) {														// numerical derivatives for non-linear parameters
		epsiloni=epsilon[1,i]
		paramsi=params
		paramsi[1,i]=paramsi[1,i]+epsiloni
		lparams=ln(paramsi[1,1..cols(paramsi)-1]),paramsi[1,cols(paramsi)]
		obj_blp_eq(0,lparams,0,0,0)
		dksi[.,i]=ksi
		domega[.,i]=omega
		paramsi=params
		paramsi[1,i]=paramsi[1,i]-epsiloni
		lparams=ln(paramsi[1,1..cols(paramsi)-1]),paramsi[1,cols(paramsi)]
		obj_blp_eq(0,lparams,0,0,0)
		dksi[.,i]=(dksi[.,i]:-ksi)/(2*epsiloni)
		domega[.,i]=(domega[.,i]:-omega)/(2*epsiloni)
	}
	dksi=(dksi, -xd00, J(rows(dksi),cols(xp),0))											// adding terms for linear parameters
	domega=(domega, J(rows(domega),cols(xd00),0), -xp)										// adding terms for linear parameters

	// gradient
	grad=(zd'*dksi)\(zp'*domega)															// gradient of moment conditions

	// variance-covariance matrix
	V=invsym(grad'*w*grad/rows(market))

	// degrees of freedom adjustment
	if (robust=="" & rows(uniqrows(cluster))==rows(market)) {
		V=(rows(market)/(rows(market)-cols(params)-cols(xd00)-cols(xp)))*V
	}
	if (robust!="" | rows(uniqrows(cluster))!=rows(market)) {
		V=((rows(market)-1)/(rows(market)-cols(params)-cols(xd00)-cols(xp)))*(rows(uniqrows(cluster))/(rows(uniqrows(cluster))-1))*V
	}

	return(V)

}	// end of V_blp_eq function
mata mlib add lrcl V_blp_eq()


// pointer generating the GMM moment conditions (equilibrium BLP model, BLP algorithm)
void mm_blp_eq(params,qq)
{

	// declarations
	external real matrix rc,xd,xd00,xp,zd,zp,msumm,market_rows,simdraws,pxdz,pxdz0,pxpz
	external real colvector market,obs,lns,delta0,firm,firm1,vat,p
	external real scalar itol,imaxiter,_is_rc_on_p
	real matrix mu,emu,emum,msummm,shati,shatim,rcm,msumf,ashatim,sashatim,dsdp,dsdpmsumf,idsdpmsumf
	real colvector sigmas,delta,delta1,shat,lnsm,sm,wm,shatm,deltam,xb,firmm,firm1m,vatm,pm,xg,ksi,omega,mc,mrkp,beta,gamma
	real scalar iitol,i,dif,ff,mdif

	// parameters
	alpha=-params[1,cols(params)]															// alpha: negative of coefficient on price in the mean utility
	sigmas=params[1,1..cols(rc)]'															// vector of random coefficient parameters
	mu=rc*(sigmas:*simdraws[1..rows(simdraws)-1,.])											// matrix of observed consumer heterogeneity (separate column for each consumer)
	emu=exp(mu)

	// mean utilities (inner loop of BLP algorithm: market share inversion)
	delta=delta0
	shati=J(rows(delta),cols(simdraws),0)
	shat=J(rows(delta),1,0)
	mdif=0
	for (mm=1; mm<=rows(market_rows); mm++) {												// calculations by market

		lnsm=panelsubmatrix(lns,mm,market_rows)
		sm=exp(lnsm)
		emum=panelsubmatrix(emu,mm,market_rows)
		msummm=panelsubmatrix(msumm[.,mm],mm,market_rows)
		wm=exp(panelsubmatrix(delta,mm,market_rows))
		shatim=wm:*emum																		// predicted individual choice probabilities
		shatim=shatim:/(1:+msummm*((shatim'*msummm)'))
		shatm=shatim*simdraws[rows(simdraws),.]'											// predicted market shares
		iitol=itol
		i=0
		while(mreldif(ln(shatm),ln(sm))>iitol & i<imaxiter) {
			i=i+1
			wm=wm:*(sm:/shatm)
			shatim=wm:*emum																	// predicted individual choice probabilities
			shatim=shatim:/(1:+msummm*((shatim'*msummm)'))
			shatm=shatim*simdraws[rows(simdraws),.]'										// predicted market shares
			dif=mreldif(ln(shatm),ln(sm))
			//mm,i,dif
		}
		if (mreldif(ln(shatm),ln(sm))>mdif) mdif=mreldif(ln(shatm),ln(sm))
		//mm,i,mreldif(ln(shatm),ln(sm))
		deltam=wm

		// filling up: mean utilities, individual choice probabilities, market shares
		delta[market_rows[mm,1]..market_rows[mm,2],.]=deltam
		shati[market_rows[mm,1]..market_rows[mm,2],.]=shatim
		shat[market_rows[mm,1]..market_rows[mm,2],.]=shatm

	}
	delta=ln(delta)
	if (colmissing(delta)>0) {
		delta=delta0
	}

	// demand error term and linear demand parameters
	delta1=delta:+(alpha*p)																	// mean utility without the price component
	beta=pxdz0*delta1																		// linear parameters (on rhs variables other than price)
	xb0=xd00*beta																			// linear predictions (from rhs variables other than price)
	ksi=delta1-xb0																			// error term (unobserved product characteristics)

	// price equation
	alphai=(_is_rc_on_p==1)*(alpha:-(sigmas[1,1]*simdraws[1,.]))							// individual price coefficients (if there is random coefficient on price)
	alphai=alphai :+ (_is_rc_on_p==0)*(alpha:*J(1,cols(simdraws),1))						// individual price coefficients (if there is no random coefficient on price)
	mc=J(rows(delta),1,0)																	// implied marginal costs (to be filled up)
	mrkp=J(rows(delta),1,0)																	// implied markups (to be filled up)
	for (mm=1; mm<=rows(market_rows); mm++) {												// calculations by market

		// auxiliary variables
		shatim=panelsubmatrix(shati,mm,market_rows)
		shatm=panelsubmatrix(shat,mm,market_rows)
		firmm=panelsubmatrix(firm,mm,market_rows)
		vatm=panelsubmatrix(vat,mm,market_rows)
		pm=panelsubmatrix(p,mm,market_rows)
		productm=runningsum(J(rows(shatm),1,1))
		msumf=amsumf(productm,firmm)
		ashatim=alphai:*shatim
		sashatim=(ashatim)*simdraws[rows(simdraws),.]'
		dsdp=(ashatim:*(simdraws[rows(simdraws),.]))*(shatim') :- diag(sashatim)			// matrix of price derivatives
		dsdpmsumf=dsdp':*msumf

		// inverse of the block-diagonal matrix dsdpmsumf (inverting by blocks)
		idsdpmsumf=J(rows(dsdpmsumf),rows(dsdpmsumf),0)
		for (ff=colmin(firmm); ff<=colmax(firmm); ff++) {
			idsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)]=qrinv(dsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)])
		}

		// filling up implied marginal costs and markups
		mc[market_rows[mm,1]..market_rows[mm,2],.]=(pm:/(1:+vatm)) :+ (idsdpmsumf)*(shatm:/(1:+vatm))
		mrkp[market_rows[mm,1]..market_rows[mm,2],.]=-(idsdpmsumf)*(shatm:/(1:+vatm))

	}

	// price error term and linear parameters of the price equation
	gamma=pxpz*mc																			// linear parameters of the price equation
	xg=xp*gamma																				// linear predictions of the marginal costs
	omega=mc-xg																				// price error term (unobserved marginal cost shocks)

	// moments
	qq=((zd'*ksi)\(zp'*omega))'																	// stacked vector of empirical moments

}	// end of GMM moment conditions (BLP equilibrium model)
mata mlib add lrcl mm_blp_eq()


end
