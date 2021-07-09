
*****************
* Mata funcitons
*****************

mata:

mata clear

// replace in a matrix x elements whose value is y with value z
matrix replace_matrix(real matrix x, real scalar y, real scalar z)
{
	real matrix xr
	real colvector missing_index
	real scalar c
	xr=x
	for (c=1; c<=cols(x); c++) {
		missing_index=(x[.,c]:==y):*runningsum(J(rows(x),1,1))
		missing_index=select(missing_index,missing_index:>0)
		xr[missing_index,c]=J(rows(missing_index),1,z)
	}
	return(xr)
}					// end of replace_matrix function
mata mlib add lrcl replace_matrix()


// calculate product ownership matrix (amsumf)
matrix amsumf(real matrix product, real colvector firm)
{
	real matrix u,amsumf,uproduct
	real colvector ufirm
	real scalar ff
	u=product,firm
	u=uniqrows(u)
	uproduct=u[.,1..cols(product)]
	ufirm=u[.,cols(product)+1]
	amsumf=J(rows(uproduct),rows(uproduct),0)
	for (ff=colmin(ufirm); ff<=colmax(ufirm); ff++) {
		amsumf=amsumf+(ufirm:==ff)*(ufirm:==ff)'
	}
	return(amsumf)
}					// end of product ownership matrix calculator
mata mlib add lrcl amsumf()


// reindexing a vector (distinct elements will start from 1 and increase by one)
pointer vector reindex(real colvector x)
{
	real colvector xs,x1
	real scalar ii
	xs=uniqrows(x)
	xs=sort(xs,1)
	x1=J(rows(x),1,0)
	for (ii=1; ii<=rows(xs); ii++) {
		x1=x1 :+ ii*(x:==xs[ii])
	}
	return(x1)
}	// end of reindex function
mata mlib add lrcl reindex()


// estimation of the BLP model
void estimation_blp(
	string scalar share0,
	string scalar iexog0,
	string scalar endog0,
	string scalar exexog0,
	string scalar prexexog0,
	string scalar rc0,
	string scalar market0,
	string scalar demog_mean0,
	string scalar demog_cov0,
	string scalar demog_xvars0,
	string scalar msize0,
	string scalar estimator,
	string scalar optimal,
	string scalar integrationmethod,
	string scalar accuracy,
	string scalar draws,
	string scalar itol0,
	string scalar imaxiter0,
	string scalar startparams,
	real scalar alpha,
	string scalar aelast0,
	string scalar xb00,
	string scalar ksi0,
	string scalar robust,
	string scalar cluster0,
	string scalar touse,
	string scalar elvar0,
	string scalar prices0,
	string scalar rc_prices0,
	real scalar _is_rc_on_p0,
	string scalar noestimation0,
	string scalar nodisplay0
	)
{

	// declarations
	external real matrix xd0,endog,zd00,zpr00,rc,msumm,market_rows,xd,zd,wd,pxdz,simdraws,simdrawsw,wd0,demog_cov,dx,ds,ctmp,prices,rc_prices,dksi
	external real colvector s,market,msize,obs,lns,s0,lnss0,p,delta0,beta,elvar,firm,firm_post,product,demog_mean,delta_hat,vv,cluster,xb0,xb,ksi,shat
	external real rowvector params0,params,eparams
	external real scalar ndvars,jj,tol,itol,imaxiter,dparams,ddelta,dwd,nsteps,kconv,ddelta0,dparams0,correction_last,corrections,w_update,klastconv,kk0,kk,value0,value,iterations,converged,r2,/*F,*/Fdf1,Fdf2,Fp,_is_rc_on_p,obj

	// load data
	st_view(s, .,share0,touse)
	st_view(xd0, .,tokens(iexog0),touse)
	if (endog0!="") {
		st_view(endog, .,tokens(endog0),touse)
	}
	if (exexog0!="") {
		st_view(zd00, .,tokens(exexog0),touse)
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
	_is_rc_on_p=_is_rc_on_p0
	rseed(1)

	// index of observations
	obs=runningsum(J(rows(market),1,1))

	// reindexing (categorical variables should start from 1 and increment by 1)
	market=reindex(market)
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
	
	// instruments
	if (exexog0!="") {
		zd=zd00,xd0
	}
	if (exexog0=="") {
		//zd=diag(J(rows(xd0),1,1))
		zd=xd
	}
	
	// initial weighting matrix
	wd=invsym(zd'*zd)
	
	// linear IV estimator matrix
	pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'

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
	delta0=lnss0
	
	// tolerance
	tol=0.000001																		// tolerance bound for convergence of the sequence of ABLP estimators (k-loop)

	// tolerance and iteration limit for BLP inner loop
	itol=strtoreal(itol0)
	imaxiter=strtoreal(imaxiter0)

	// setting market size and shares consistent with pre-defined aggregate elasticity (only in no-estimation mode when the aelast option is specified)
	if (noestimation0!="" & aelast0!="") {
		shat=J(rows(delta0),1,.)
		delta0=blp_inner_loop(params0,delta0,imaxiter,itol)
		q=s:*msize
		aelast=-abs(strtoreal(aelast0))
		// market size
		msize=msize_blp(msize,aelast,params0,alpha,q,p,rc,simdraws,msumm,delta0,imaxiter,itol,_is_rc_on_p)
		// shares
		s=q:/msize
		lns=ln(s)
		s0=rowsum((1:-(s'*msumm)):*msumm)
		lnss0=lns:-ln(s0)
	}

	// updating weighting matrix based on starting parameter vector and delta
	wd=wd(xd,zd,pxdz,delta0,"",runningsum(J(rows(market),1,1)))							// updating demand weighting matrix
	pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'											// updating demand linear IV estimator matrix
	shat=J(rows(delta0),1,.)
	delta0=blp_inner_loop(params0,delta0,imaxiter,itol)									// setting initial delta by BLP contraction
	delta=delta0
	params=params0

	if (noestimation0=="") {

		// NFP estimation (BLP algorithm)
		rseed(1)
		params0=ln(params0)
		S=optimize_init()
		optimize_init_evaluator(S, &obj_blp())
		optimize_init_evaluatortype(S, "d1")
		optimize_init_verbose(S, 0)
		if (nodisplay0!="") {
			optimize_init_tracelevel(S, "none")
		}
		optimize_init_params(S, params0)
		optimize_init_which(S, "min")
		optimize_init_technique(S, "nr")
		optimize_init_conv_maxiter(S, 50)
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
		wd0=wd
		wd00=wd
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

			// delta at the final parameter vector (BLP inversion)
			eparams=exp(params)
			delta=blp_inner_loop(eparams,delta0,imaxiter,itol)
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
				eparams=exp(params)
				delta=blp_inner_loop(eparams,delta0,imaxiter,itol)
				if (estimator=="gmm2s" | estimator=="igmm") {
					wd=wd00
					pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
					wd=wd(xd,zd,pxdz,delta,robust,cluster)
					pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
				}
				if (colmissing(delta)>0) {
					delta=lnss0
				}
				correction_last=1
			}

			// estimated linear parameters
			beta=pxdz*delta

			// updating weighting matrix based on step-k parameter vector (if multi-step estimator, or robust/cluster standard errors specified)
			if (nsteps>1 | robust!="" | cluster0!="") {
				wd=wd(xd,zd,pxdz,delta,robust,cluster)											// updating demand weighting matrix
				pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'										// updating demand linear IV estimator matrix
			}

			// convergence criteria for step-k
			dparams=rowmax(abs(abs(params):-abs(params0)))
			ddelta=colmax(abs(delta:-delta0))
			dwd=max(abs(wd:-wd0))
			if (dparams<=tol & dwd<0.0005 & estimator=="igmm") {
				kconv=1
			}
			
			// storing
			params0=params									// storing starting parameters
			delta0=delta									// storing starting delta
			wd0=wd											// storing weighting matrix

			// updating
			optimize_init_params(S, params)					// updating starting parameters
			delta=delta0									// updating starting delta
			wd=wd0											// updating weighting matrix

		}	// end of loop of GMM steps
		params=exp(params)

		// variance-covariance matrix
		V=V_blp(params,wd,robust,cluster)
		
		// full row vector of coefficients
		b=(params,beta')
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
		obj_blp(0,ln(params),obj,0,0)
		j=obj
		jdf=cols(zd)-cols(xd)-cols(rc)
		jp=chi2tail(jdf,j)
		
		// pseudo R2 (fit of delta)
		if (endog0!="") {
			if (cols(endog)==1) {
				xb0=xd0*beta[2..rows(beta)]
			}
			if (cols(endog)>1) {
				xb0=(endog[.,2..cols(endog)],xd0)*beta[2..rows(beta)]
			}
		}
		if (endog0=="") {
			xb0=xd0[.,2..rows(beta)]*beta[2..rows(beta)]
		}
		xb=xd*beta														// linear predictions
		ksi=delta-xb													// error term (unobserved product characteristics)
		rss=quadcross(ksi,ksi)
		yyc=quadcrossdev(delta,mean(delta),delta,mean(delta))
		r2=1-rss/yyc
		r2_a=1-(rss/yyc)*(rows(delta)-1)/(rows(delta)-cols(b))

		// F-test
		vv=diagonal(V)
		F=sum( (b[1,1..cols(b)-1]:^2) :/ (vv[1..cols(b)-1,1]') )/( cols(b)-1 )
		Fdf1=cols(b)-1
		Fdf2=rows(uniqrows(cluster))-cols(b)
		Fp=Ftail(Fdf1,Fdf2,F)

		// calculating the optimal instruments
		if (optimal!="" & exexog0!="") {
			params_alt=params
			delta_alt=delta
			params_alt=((abs(params):>0.00001):*params) :+ ((abs(params):<=0.00001)*0.1)
			delta_alt=blp_inner_loop(params_alt,delta,imaxiter,itol)
			opti=opti_blp(params_alt,delta_alt)
			odksi=opti[.,1..cols(rc)]
			op_hat=opti[.,cols(rc)+1]
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
		colnames=(J(cols(rc),1,"sigmas")\J(cols(endog),1,"endogenous")\J(cols(xd0),1,"exogenous")),((rcnames,tokens(endog0),tokens(iexog0))')
		st_matrix("b", b)
		st_matrixcolstripe("b", colnames)
		st_matrix("V", V)
		st_matrixrowstripe("V", colnames)
		st_matrixcolstripe("V", colnames)
		st_numscalar("j", j)
		st_numscalar("jp", jp)
		st_numscalar("jdf", jdf)
		st_numscalar("r2", r2)
		st_numscalar("r2_a", r2_a)
		st_numscalar("F", F)
		st_numscalar("Fp", Fp)
		st_numscalar("Fdf1", Fdf1)
		st_numscalar("Fdf2", Fdf2)
	}	// end of noestimation0=="" if condition (i.e., when estimation is performed)
	
	// auxiliary variables
	if (noestimation0!="") {
		if (alpha==.) {
			wd=wd(xd,zd,pxdz,delta,robust,cluster)
			pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
			beta=pxdz*delta
			alpha=-beta[1,1]
			st_numscalar("alpha", alpha)
		}
		if (ksi0!="") {
			st_view(ksi, .,tokens(ksi0),touse)
			ksi=ksi
		}
		if (ksi0=="") {
			ksi=J(rows(delta),1,0)
		}
		if (xb00!="") {
			st_view(xb0, .,tokens(xb00),touse)
			xb0=xb0
			if (ksi0!="") {
				delta=-alpha*p:+xb0:+ksi
			}
		}
		if (xb00=="") {
			xb0=delta:+alpha*p:-ksi
		}
	}

	// elasticities and diversion ratios
	if (elvar0!="") {
		if (noestimation0!="") {
			beta=-alpha
		}
		elasticities_rcl(beta,params,delta,elvar)
	}

	// exporting further results into Stata
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
	if (aelast0!="" & noestimation0!="") {
		stata("capture drop __msize")
		stata("quietly generate __msize=.")
		st_store( .,"__msize",touse,msize)
		stata("capture drop ___s")
		stata("quietly generate ___s=.")
		st_store( .,"___s",touse,s)
		stata("capture rename ___s __s")
	}
	if (optimal!="" & exexog0!="") {
		stata("capture drop __optik*")
		for (i=1; i<=cols(odksi); i++) {
			name = sprintf("%s%g", "__optik", i)
			st_store(., st_addvar("double", name),touse, odksi[.,i])
		}
		stata("capture drop __optip*")
		st_store(., st_addvar("double", "__optip"),touse, op_hat)
	}

}	// end of estimation_blp function
mata mlib add lrcl estimation_blp()


// function generating the optimal instruments (BLP model without pricing equation)
matrix opti_blp(
	real rowvector params0,
	real colvector delta0
	)
{

	// declarations
	external real matrix rc,msumm,market_rows,simdraws,xd0,xd,zd00,zpr00,pxdz,endog
	external real colvector market
	external real scalar _is_rc_on_p
	real matrix mu,xpr,pxpxp,p_hat,xd_hat,rc_hat,shatim,rcm,dsdsigma,ddelta,dsddelta,dxb,dksi
	real colvector sigmas,delta,beta

	// I. predicted endogenous variables of the mean utility (conditional expectation of the derivative of the error term (ksi) wrt. the mean utility's respective coefficient; typically this means only the price variable and its coefficient)
	// this reduced form price prediction is the preferred solution of Reynaert and Verboven [Improving the Performance of Random Coefficients Demand Models: the Role of Optimal Instruments, Journal of Econometrics, 2014 (April 2012), 179(1), 83-98.]
	xpr=zpr00,xd0
	pxpxp=invsym(xpr'*xpr)*xpr'
	p_hat=xpr*(pxpxp*endog)

	// predicted mean utilities (assuming ksi=0)
 	beta=pxdz*delta0												// linear parameters
	xd_hat=xd														// predicted mean utility variables (price is replaced with its prediction)
	xd_hat[.,1..cols(p_hat)]=p_hat
	delta=xd_hat*beta												// predicted mean utilities

	// parameters
	sigmas=params0[1,1..cols(rc)]'									// vector of random coefficient parameters

	// matrix of observed consumer heterogeneity (separate column for each consumer)
	rc_hat=rc
	if (_is_rc_on_p==1) {											// replace price with predicted price (from I.) in list of variables with random coefficient, if relevant
		rc_hat[.,1]=p_hat
	}
	mu=rc_hat*(sigmas:*simdraws[1..rows(simdraws)-1,.])

	// predicted individual choice probabilities
	shati=exp(delta:+mu)
	shati=shati:/(1:+msumm*((shati'*msumm)'))
	
	// derivative of predicted mean utilities wrt. random coefficients
	ddelta=J(rows(delta),cols(rc),0)
	for (mm=1; mm<=rows(market_rows); mm++) {						// calculations by market

		// observations of the selected market
		shatim=panelsubmatrix(shati,mm,market_rows)
		rcm=panelsubmatrix(rc_hat,mm,market_rows)
		// derivative of predicted market shares wrt. random coefficients
		dsdsigma= ( rcm:*((shatim:*(simdraws[rows(simdraws),.]))*(simdraws[1..rows(simdraws)-1,.]')) ) :- (shatim:*(simdraws[rows(simdraws),.]))*( (simdraws[1..rows(simdraws)-1,.]:*(rcm'*shatim))' )
		// derivative of predicted market shares wrt. mean utilities
		_diag( dsddelta=-(shatim:*(simdraws[rows(simdraws),.]))*shatim', diagonal( (shatim:*(simdraws[rows(simdraws),.]))*( 1:-(shatim') ) ) )
		// filling up: derivative of mean utilities wrt. random coefficients
		ddelta[market_rows[mm,1]..market_rows[mm,2],.]=luinv(dsddelta)*dsdsigma

	}

	// II. conditional expectation of the derivative of the demand error term (ksi) wrt. random coefficients
	dxb=xd_hat*(pxdz*ddelta)
	dksi=ddelta-dxb
	
	// optimal instruments
	opti=dksi,p_hat
	return(opti)
	
}	// end of opti_blp function
mata mlib add lrcl opti_blp()


// function calculating market size as a function of the aggregate elasticity (BLP model)
pointer vector msize_blp(
	real colvector msize00,
	real scalar agg_elast,
	real rowvector params,
	real scalar alpha,
	real colvector q,
	real colvector p,
	real matrix rc,
	real matrix simdraws,
	real matrix msumm,
	real colvector delta00,
	real scalar imaxiter,
	real scalar itol,
	real scalar _is_rc_on_p)
{

	// declarations
	external real colvector lns,s
	real matrix mu,shati,shati0
	real colvector tq,ap,sigmas,msize0,msize1,delta0,delta1,as
	real rowvector alphai
	real scalar dif,dif_delta,iitol,iimaxiter,i

	// parameters
	if (_is_rc_on_p==1) {
		alphai=alpha:-(params[1,1]*simdraws[1,.])									// individual price coefficients (if there is random coefficient on price)
	}
	if (_is_rc_on_p==0) {
		alphai=alpha:*J(1,cols(simdraws),1)											// individual price coefficients (if there is no random coefficient on price)
	}
	tq=msumm'*q																		// total quantity
	//ap=(msumm'*p):/(colsum(msumm)')													// average price
	ap=((msumm:*q)'*p):/(colsum((msumm:*q))')										// weighted average price
	sigmas=params[1,1..cols(rc)]'													// vector of random coefficient parameters
	mu=rc*(sigmas:*simdraws[1..rows(simdraws)-1,.])									// matrix of observed consumer heterogeneity (separate column for each consumer)
	msize0=msize00
	msize1=msize00
	delta0=delta00

	// solving for the market size as a fixed-point problem ( msize=f(msize,aggregate_elasticity,data) )
	dif=1000
	dif_delta=1000
	iitol=0.0000001
	iimaxiter=10000
	i=0
	while((dif>iitol | dif_delta>iitol) & i<iimaxiter) {
		i=i+1
		// iteration
		delta1=blp_inner_loop(params,delta0,imaxiter,itol)							// mean utility vector
		shati=exp(delta1:+mu)														// predicted individual choice probabilities
		shati=shati:/(1:+msumm*((shati'*msumm)'))
		shati0=1:-(msumm'*shati)													// individual probablities of choosing the outside good
		as=(alphai:*shati0:*(1:-shati0))*simdraws[rows(simdraws),.]'
		msize1=-agg_elast*(tq:/ap):/as
		msize1=msumm*msize1
		dif=mreldif(msize0,msize1)
		dif_delta=mreldif(delta0,delta1)
		//i,dif,dif_delta,mean(uniqrows( (1:-shati0)*simdraws[rows(simdraws),.]' )),mean(msize1:/msize00),mean(ae)
		// updating
		delta0=delta1
		msize0=0.9*msize0 :+ 0.1*msize1
		s=q:/msize0
		lns=ln(s)
	}
	//i,dif,dif_delta,mean(msize00),mean(msize0),mean(shati0*simdraws[rows(simdraws),.]')
	delta00=delta1

	return(msize0)

}	// end of msize_blp function
mata mlib add lrcl msize_blp()



// function executing the BLP inversion (BLP inner loop contraction of mean utilities)
pointer vector blp_inner_loop(
	real rowvector params,
	real colvector delta0,
	real scalar imaxiter,
	real scalar itol)
{

	// declarations
	external real matrix rc,msumm,market_rows,simdraws
	external real colvector market,obs,lns,lnss0,shat
	real matrix mu,emu,emum,msummm,shatim
	real colvector sigmas,delta,lnsm,sm,wm,shatm,deltam
	real scalar mm,i,dif

	// parameters
	//sigmas=exp(params[1,1..cols(rc)]')				// vector of random coefficient parameters
	sigmas=params[1,1..cols(rc)]'						// vector of random coefficient parameters
	mu=rc*(sigmas:*simdraws[1..rows(simdraws)-1,.])		// matrix of observed consumer heterogeneity (separate column for each consumer)
	emu=exp(mu)

	// mean utilities (inner loop of BLP algorithm: market share inversion)
	delta=delta0
	for (mm=1; mm<=rows(market_rows); mm++) {						// calculations by market
	
		lnsm=panelsubmatrix(lns,mm,market_rows)
		sm=exp(lnsm)
		emum=panelsubmatrix(emu,mm,market_rows)
		msummm=panelsubmatrix(msumm[.,mm],mm,market_rows)
		wm=exp(panelsubmatrix(delta,mm,market_rows))
		shatim=wm:*emum											// predicted individual choice probabilities
		shatim=shatim:/(1:+msummm*((shatim'*msummm)'))
		shatm=shatim*simdraws[rows(simdraws),.]'				// predicted market shares
		i=0
		while(mreldif(ln(shatm),ln(sm))>itol & i<imaxiter) {
			i=i+1
			wm=wm:*(sm:/shatm)
			shatim=wm:*emum											// predicted individual choice probabilities
			shatim=shatim:/(1:+msummm*((shatim'*msummm)'))
			shatm=shatim*simdraws[rows(simdraws),.]'				// predicted market shares
			//mm,i,mreldif(ln(shatm),ln(sm)),max(abs(wm))
		}
		deltam=wm
		shat[market_rows[mm,1]..market_rows[mm,2],.]=shatm
		//mm,i,mreldif(ln(shatm),ln(sm)),max(abs(wm)),max(100*abs(shatm:-sm):/sm)

		// filling up: mean utilities
		delta[market_rows[mm,1]..market_rows[mm,2],.]=deltam

	}
	delta=ln(delta)
	if (colmissing(delta)>0) {
		delta=lnss0
	}

	return(delta)

}	// end of blp_inner_loop function
mata mlib add lrcl blp_inner_loop()


// pointer generating the GMM objective (BLP model, BLP algorithm)
void obj_blp(todo,params,obj,grad,H)
{

	// declarations
	external real matrix rc,xd,zd,msumm,market_rows,simdraws,pxdz,wd,dksi
	external real colvector market,obs,lns,delta0
	external real scalar itol,imaxiter,obj
	real matrix mu,emu,emum,msummm,shatim,rcm,dsdsigma,ddelta,dsddelta,dxb
	real colvector sigmas,delta,lnsm,sm,wm,shatm,deltam,beta,xb,ksi
	real scalar iitol,i,dif

	// parameters
	sigmas=exp(params[1,1..cols(rc)]')								// vector of random coefficient parameters
	mu=rc*(sigmas:*simdraws[1..rows(simdraws)-1,.])					// matrix of observed consumer heterogeneity (separate column for each consumer)
	emu=exp(mu)

	// mean utilities (inner loop of BLP algorithm: market share inversion)
	delta=delta0
	ddelta=J(rows(delta),cols(rc),0)
	mdif=0
	for (mm=1; mm<=rows(market_rows); mm++) {						// calculations by market

		lnsm=panelsubmatrix(lns,mm,market_rows)
		sm=exp(lnsm)
		emum=panelsubmatrix(emu,mm,market_rows)
		msummm=panelsubmatrix(msumm[.,mm],mm,market_rows)
		wm=exp(panelsubmatrix(delta,mm,market_rows))
		shatim=wm:*emum												// predicted individual choice probabilities
		shatim=shatim:/(1:+msummm*((shatim'*msummm)'))
		shatm=shatim*simdraws[rows(simdraws),.]'					// predicted market shares
		iitol=itol
		i=0
		while(mreldif(ln(shatm),ln(sm))>iitol & i<imaxiter) {
			i=i+1
			wm=wm:*(sm:/shatm)
			shatim=wm:*emum											// predicted individual choice probabilities
			shatim=shatim:/(1:+msummm*((shatim'*msummm)'))
			shatm=shatim*simdraws[rows(simdraws),.]'				// predicted market shares
			dif=mreldif(ln(shatm),ln(sm))
			//mm,i,dif
		}
		if (mreldif(ln(shatm),ln(sm))>mdif) mdif=mreldif(ln(shatm),ln(sm))
		//mm,i,mreldif(ln(shatm),ln(sm))
		deltam=wm

		// derivative of mean utilities wrt. random coefficients
		if (todo>=1) {
			// derivative of predicted market shares wrt. random coefficients
			rcm=panelsubmatrix(rc,mm,market_rows)
			dsdsigma= ( rcm:*((shatim:*(simdraws[rows(simdraws),.]))*(simdraws[1..rows(simdraws)-1,.]')) ) :- (shatim:*(simdraws[rows(simdraws),.]))*( (simdraws[1..rows(simdraws)-1,.]:*(rcm'*shatim))' )
			dsdsigma=dsdsigma*(diag(sigmas))
			// derivative of predicted market shares wrt. mean utilities
			_diag( dsddelta=-(shatim:*(simdraws[rows(simdraws),.]))*shatim', diagonal( (shatim:*(simdraws[rows(simdraws),.]))*( 1:-(shatim') ) ) )
			// filling up: derivative of mean utilities wrt. random coefficients
			ddelta[market_rows[mm,1]..market_rows[mm,2],.]=luinv(dsddelta)*dsdsigma
		}
		
		// filling up: mean utilities
		delta[market_rows[mm,1]..market_rows[mm,2],.]=deltam

	}
	delta=ln(delta)
	if (colmissing(delta)>0) {
		delta=delta0
	}
	if (mdif<=iitol) {
		delta0=delta
	}

	// objective
	beta=pxdz*delta													// linear parameters
	xb=xd*beta														// linear predictions
	ksi=delta-xb													// error term (unobserved product characteristics)
	q=(zd'*ksi)														// vector of empirical moments
	obj=q'*wd*q/rows(market)										// GMM objective

	// gradient
	if (todo>=1) {
		// derivative of error term (ksi) wrt. random coefficients
		dxb=xd*(pxdz*ddelta)
		dksi=ddelta-dxb
		// gradient
		dq=(zd'*dksi)
		grad=-2*q'*wd*dq/rows(market)
	}
	
}	// end of GMM demand objective pointer (BLP algorithm)
mata mlib add lrcl obj_blp()

// weigthing matrix
pointer matrix wd(
	real matrix xd,
	real matrix zd,
	real matrix pxdz,
	real colvector delta,
	string scalar robust,
	real colvector cluster)
{

	// declarations
	external real matrix market
	real matrix lambda,wd,zu,zdc,zuc,sd
	real colvector beta,xb,ksi,ksic
	real rowvector uc
	real scalar sd2,c

	// estimated error term (ksi)
	beta=pxdz*delta																		// linear parameters of the utility function
	xb=xd*beta																			// linear predictions of mean utility (includes price)
	ksi=delta-xb																		// demand error term (unobserved product characteristics)

	// weighting matrix
	uc=uniqrows(cluster)'																// clusters
	if (robust=="" & cols(uc)==rows(cluster)) {											// non-robust case
		sd2=ksi'*ksi/rows(market)
		sd=(sd2/rows(market))*(zd'*zd)
		wd=invsym(sd)																	// updating demand weighting matrix
	}
	if (robust!="" | (cols(uc)!=rows(cluster))) {										// robust and/or cluster robust case
		zu=zd:*ksi
		if (cols(uc)==rows(cluster)) {													// no clustering
			lambda=quadcross(zu,zu)/rows(market)
		}
		else {																			// clustering by cluster
			lambda=J(cols(zd),cols(zd),0)
			for (c=1; c<=rowmax(uc); c++) {
				zdc=select(zd,cluster:==c)
				ksic=select(ksi,cluster:==c)
				zuc=zdc:*ksic
				lambda=lambda :+ quadcross(zuc,zuc)/cols(uc)
			}
			lambda=lambda*(cols(uc)/rows(market))
		}
		wd=invsym(lambda)																// updating demand weighting matrix
	}
	return(wd)

}	// end of wd function
mata mlib add lrcl wd()

// variance-covariance matrix of BLP parameter estimates
matrix V_blp(
	real rowvector params,
	real matrix wd,
	string scalar robust,
	real colvector cluster)
{

	// declarations
	external real matrix xd,zd,dksi
	external real colvector market
	real matrix grad,V

	// derivatives of estimated error terms (dksi)
	obj_blp(1,ln(params),0,0,0)
	dksi=dksi:/params																	// transformation (the derivatives from obj_blp are wrt. the nat.log of the random coefficients)
	dksi=(dksi, -xd)																	// derivatives of demand equation's error term wrt. parameters

	// gradient
	grad=(zd'*dksi)																		// gradient of moment conditions

	// variance-covariance matrix
	V=invsym(grad'*wd*grad/rows(market))

	// degrees of freedom adjustment
	if (robust=="" & rows(uniqrows(cluster))==rows(market)) {
		V=(rows(market)/(rows(market)-cols(params)-cols(xd)))*V
	}
	if (robust!="" | rows(uniqrows(cluster))==rows(market)) {
		V=((rows(market)-1)/(rows(market)-cols(params)-cols(xd)))*(rows(uniqrows(cluster))/(rows(uniqrows(cluster))-1))*V
	}

	return(V)

}	// end of V_blp function (variance-covariance matrix of BLP parameter estimates)
mata mlib add lrcl V_blp()


// common cross-products (from ivreg2)
void s_crossprods(	string scalar yname,
					string scalar X1names,
					string scalar X2names,
					string scalar Z1names,
					string scalar touse,
					string scalar weight,
					string scalar wvarname,
					scalar wf,
					scalar N)				

{

	//  y = dep var
	// X1 = endog regressors
	// X2 = exog regressors = included IVs
	// Z1 = excluded instruments
	// Z2 = included IVs = X2

	ytoken=tokens(yname)
	X1tokens=tokens(X1names)
	X2tokens=tokens(X2names)
	Z1tokens=tokens(Z1names)

	Xtokens = (X1tokens, X2tokens)
	Ztokens = (Z1tokens, X2tokens)

	K1=cols(X1tokens)
	K2=cols(X2tokens)
	K=K1+K2
	L1=cols(Z1tokens)
	L2=cols(X2tokens)
	L=L1+L2

	st_view(wvar, ., st_tsrevar(wvarname), touse)
	st_view(A, ., st_tsrevar((ytoken, Xtokens, Z1tokens)), touse)

	AA = quadcross(A, wf*wvar, A)

	XX = AA[(2::K+1),(2..K+1)]
	if (K1>0) {
		X1X1 = AA[(2::K1+1),(2..K1+1)]
	}

	Xy  = AA[(2::K+1),1]

	if (L1 > 0) {
		Z1Z1 = AA[(K+2::rows(AA)),(K+2..rows(AA))]
	}

	if (L2 > 0) {
		Z2Z2 = AA[(K1+2::K+1), (K1+2::K+1)]
		Z2y  = AA[(K1+2::K+1), 1]
	}

	if ((L1>0) & (L2>0)) {
		Z2Z1 = AA[(K1+2::K+1), (K+2::rows(AA))]
		ZZ2 = Z2Z1, Z2Z2
		ZZ1 = Z1Z1, Z2Z1'
		ZZ = ZZ1 \ ZZ2
	}
	else if (L1>0) {
		ZZ = Z1Z1
	}
	else {
		ZZ = Z2Z2
	}

	// K1>0 => L1>0 (order condition for identification)
	if (K1>0) {
		X1Z1 = AA[(2::K1+1), (K+2::rows(AA))]
	}

	if ((K1>0) & (L2>0)) {
		X1Z2 = AA[(2::K1+1), (K1+2::K+1)]
		X1Z = X1Z1, X1Z2
		XZ = X1Z \ ZZ2
	}
	else if (K1>0) {
		XZ = X1Z1
		X1Z= X1Z1
	}
	else if (L1>0) {
		XZ = AA[(2::K+1),(K+2..rows(AA))], AA[(2::K+1),(2..K+1)]
	}
	else {
		XZ = ZZ
	}

	if ((L1>0) & (L2>0)) {
		Zy = AA[(K+2::rows(AA)), 1] \ AA[(K1+2::K+1), 1]
		ZY = AA[(K+2::rows(AA)), (1..K1+1)] \ AA[(K1+2::K+1), (1..K1+1)]
		Z2Y = AA[(K1+2::K+1), (1..K1+1)]
	}
	else if (L1>0) {
		Zy = AA[(K+2::rows(AA)), 1]
		ZY = AA[(K+2::rows(AA)), (1..K1+1)]
	}
	else {
		Zy = AA[(K1+2::K+1), 1]
		ZY = AA[(K1+2::K+1), (1..K1+1)]
		Z2Y = ZY
	}

	YY  = AA[(1::K1+1), (1..K1+1)]
	yy  = AA[1,1]
	st_subview(y, A, ., 1)
	ym    = sum(wf*wvar:*y)/N
	yyc   = quadcrossdev(y, ym, wf*wvar, y, ym)

	XXinv = invsym(XX)
	if (Xtokens==Ztokens) {
		ZZinv = XXinv
		XPZXinv = XXinv
	}
	else {
		ZZinv = invsym(ZZ)
		XPZX  = makesymmetric(XZ*ZZinv*XZ')
		XPZXinv=invsym(XPZX)
	}

	st_matrix("r(XX)", XX)
	st_matrix("r(X1X1)", X1X1)
	st_matrix("r(X1Z)", X1Z)
	st_matrix("r(ZZ)", ZZ)
	st_matrix("r(Z2Z2)", Z2Z2)
	st_matrix("r(Z1Z2)", Z2Z1')
	st_matrix("r(Z2y)",Z2y)
	st_matrix("r(XZ)", XZ)
	st_matrix("r(Xy)", Xy)
	st_matrix("r(Zy)", Zy)
	st_numscalar("r(yy)", yy)
	st_numscalar("r(yyc)", yyc)
	st_matrix("r(YY)", YY)
	st_matrix("r(ZY)", ZY)
	st_matrix("r(Z2Y)", Z2Y)
	st_matrix("r(XXinv)", XXinv)
	st_matrix("r(ZZinv)", ZZinv)
	st_matrix("r(XPZXinv)", XPZXinv)

}	// end program s_crossprods
mata mlib add lrcl s_crossprods()


// canonical correlations utility for collinearity check (from ivreg2)
void s_cccollin(	string scalar ZZmatrix,
					string scalar X1X1matrix,
					string scalar X1Zmatrix,
					string scalar ZZinvmatrix,
					string scalar X1names)				

{
	X1tokens=tokens(X1names)

	ZZ       = st_matrix(ZZmatrix)
	X1X1     = st_matrix(X1X1matrix)
	X1Z      = st_matrix(X1Zmatrix)
	X1X1inv  = invsym(X1X1)
	ZZinv    = st_matrix(ZZinvmatrix)
	X1PZX1   = makesymmetric(X1Z*ZZinv*X1Z')
	X1PZX1inv= invsym(X1PZX1)

	ccmat = X1X1inv*X1PZX1
	st_matrix("r(ccmat)", ccmat)

}	// end program s_cccollin
mata mlib add lrcl s_cccollin()


end

