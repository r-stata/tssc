
*******************************************************
* Mata funcitons for the nested logit equilibrium model
*******************************************************

mata:

mata clear

// function generating the optimal instruments (simple and nested logit models with pricing equation)
real matrix  opti_nlogit_eq(
	real rowvector params0,
	string scalar g0,
	string scalar h0,
	string scalar k0
	)
{

	// declarations
	external real matrix zpr00,xd0,xp,endog,pxdz0,pxpz,msumm,msummf,msummg,msummfg,msummhg,msummfhg,msummkhg,msummfkhg
	external real colvector market,msize,obs,one,vat,d0,nmsummg,nmsummhg,nmsummkhg,nmsummfg,nmsummfhg,nmsummfkhg,lnss0,p,s,firm
	real matrix xpr,pxpxp,xd_hat,dsjgds,dsgds,dsdsigma,ddelta,dsdsigmam,msummgm,msummhgm,msummkhgm,dsddelta,dxb,dksi,qg,qhg,qkhg,qfg,qfhg,qfkhg
	real colvector alpha,sigmag,p_hat,lnss01,beta,delta,ej,dg,dgoms,d,sjg,sg,s_hat,wdeltag,eg,we,dm,pbs,onem,sigmagm,sjgm

	// parameters
	alpha=J(rows(market),1,abs(params0[1,1]))											// alpha: negative of coefficient on price in the mean utility
	if (g0!="") {
		sigmag=J(rows(market),1,params0[1,2])											// sigma of nest
		sigmag=(0.0000002*(sigmag:<0)) :+ sigmag:*(sigmag:>=0)
		sigmag=(.9*(sigmag:>=1)) :+ sigmag:*(sigmag:<1)
		if (h0!="") {
			sigmah=J(rows(market),1,params0[1,3])										// sigma of subnest
			sigmah=(0.0000002*(sigmah:<0)) :+ sigmah:*(sigmah:>=0)
			sigmah=(.9*(sigmah:>=1)) :+ sigmah:*(sigmah:<1)
			sigmah=(sigmag:*(sigmah:<sigmag)) :+ sigmah:*(sigmah:>=sigmag)
			if (k0!="") {
				sigmak=J(rows(market),1,params0[1,4])									// sigma of sub-subnest
				sigmak=(0.0000002*(sigmak:<0)) :+ sigmak:*(sigmak:>=0)
				sigmak=(.9*(sigmak:>=1)) :+ sigmak:*(sigmak:<1)
				sigmak=(sigmah:*(sigmak:<sigmah)) :+ sigmak:*(sigmak:>=sigmah)
			}
		}
	}

	// I. predicted price (this reduced form price prediction is the preferred solution of Reynaert and Verboven [Improving the Performance of Random Coefficients Demand Models: the Role of Optimal Instruments, Journal of Econometrics, 2014 (April 2012), 179(1), 83-98.])
	xpr=zpr00,xd0
	pxpxp=invsym(xpr'*xpr)*xpr'
	p_hat=xpr*(pxpxp*p)

	// predicted mean utilities (assuming ksi=0, where ksi is the error term of the demand equation)
	// "observed" mean utility without the price component
	lnss01=lnss0:+(alpha:*p)
	lnss01[select(obs,rowmissing(lnss01))]=min(lnss01):*(select(obs,rowmissing(lnss01)):!=0)		// treat missing values
	if (g0!="") {
		lnss01=lnss01:-(sigmag:*endog[.,2])
		if (h0!="") {
			lnss01=lnss01:-(sigmah:*endog[.,3])
			if (k0!="") {
				lnss01=lnss01:-(sigmak:*endog[.,4])
			}
		}
	}
	beta=pxdz0*lnss01																	// linear parameters (on rhs variables other than "endogenous" regressors)
 	beta=(-alpha[1,1])\beta																// linear parameters (on rhs variables other than the within share variables)
	xd_hat=p_hat,xd0																	// product characteristics with predicted price
	delta=xd_hat*beta																	// predicted mean utilities
	xb0_hat=xd0*beta[2..rows(beta)]														// predicted mean utilities without the price component

	// derivatives of mean utility wrt. sigma parameters (nested logit models only)
	if (cols(endog)>1) {
		ddelta=J(rows(market),cols(endog)-1,0)											// derivative of mean utilities wrt. sigma parameters
		epsilon=J(1,cols(endog)-1,0.0000001)											// difference in the parameter value for numerical derivatives
		for (mm=1; mm<=colmax(market); mm++) {											// calculations by market
			obsm=select(obs,market:==mm)
			onem=one[obsm]
			p_hatm=p_hat[obsm]
			xb0_hatm=xb0_hat[obsm]
			ksim=J(rows(obsm),1,0)
			alpham=alpha[obsm]
			// one-level nested logit model
			if (cols(endog)==2) {
				msummgm=msummg[obsm,obsm]
				// (numerical) derivative of predicted market shares wrt. sigma parameters
				for (ii=1; ii<=2; ii++) {
					// sigma parameters
					if (ii==1) {
						sigmagm=sigmag[obsm]:+J(rows(obsm),1,epsilon[1,1])
					}
					if (ii==2) {
						sigmagm=sigmag[obsm]:-J(rows(obsm),1,epsilon[1,1])
					}
					// market shares
					sm=shatm_nlogit(p_hatm,xb0_hatm,ksim,alpham,sigmagm,msummgm)
					// derivative
					if (ii==1) {
						dsdsigmam=sm
					}
					if (ii==2) {
						dsdsigmam=(dsdsigmam:-sm)/(2*epsilon[1,1])
					}
				}
				// predicted market shares
				sigmagm=sigmag[obsm]
				sm=shatm_nlogit(p_hatm,xb0_hatm,ksim,alpham,sigmagm,msummgm)
				sjgm=(sm):/(msummgm*sm)
				// derivative of predicted market shares wrt. mean utilities
				dsddelta=-sm*(sm)'
				dsddelta=dsddelta:-(sm*((sigmagm:/(onem:-sigmagm)):*sjgm)'):*msummgm
				dsddelta=dsddelta:+diag(sm:/(onem:-sigmagm))
				// filling up: derivative of mean utilities wrt. sigma parameters
				ddelta[obsm,1]=luinv(dsddelta)*dsdsigmam
			}
			// two-level nested logit model
			if (cols(endog)==3) {
				msummgm=msummg[obsm,obsm]
				msummhgm=msummhg[obsm,obsm]
				// (numerical) derivative of predicted market shares wrt. sigma parameters
				for (i=1; i<=cols(endog)-1; i++) {
					sigmagm=sigmag[obsm]
					sigmahm=sigmah[obsm]
					sigmas0m=sigmagm,sigmahm
					sigmasm=sigmas0m
					for (ii=1; ii<=2; ii++) {
						// sigma parameters
						if (ii==1) {
							sigmasm[.,i]=sigmas0m[.,i]:+J(rows(obsm),1,epsilon[1,i])
						}
						if (ii==2) {
							sigmasm[.,i]=sigmas0m[.,i]:-J(rows(obsm),1,epsilon[1,i])
						}
						sigmagm=sigmasm[.,1]
						sigmahm=sigmasm[.,2]
						// market shares
						sm=shatm_nlogit2(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,msummgm,msummhgm)
						// derivative
						if (ii==1) {
							dsdsigmam=sm
						}
						if (ii==2) {
							dsdsigmam=(dsdsigmam:-sm)/(2*epsilon[1,i])
						}
					}
					// predicted market shares
					sigmagm=sigmas0m[.,1]
					sigmahm=sigmas0m[.,2]
					sm=shatm_nlogit2(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,msummgm,msummhgm)
					sjgm=(sm):/(msummgm*sm)
					sjhm=(sm):/(msummhgm*sm)
					// derivative of predicted market shares wrt. mean utilities
					dsddelta=-sm*(sm)'
					dsddelta=dsddelta:-(sm*((sigmagm:/(onem:-sigmagm)):*sjgm)'):*msummgm
					dsddelta=dsddelta:-(sm*(( (onem:/(onem:-sigmahm)):-(onem:/(onem:-sigmagm)) ):*sjhm)'):*msummhgm
					dsddelta=dsddelta:+diag(sm:/(onem:-sigmahm))
					// filling up: derivative of mean utilities wrt. sigma parameters
					ddelta[obsm,i]=luinv(dsddelta)*dsdsigmam
				}
			}
			// three-level nested logit model
			if (cols(endog)==4) {
				msummgm=msummg[obsm,obsm]
				msummhgm=msummhg[obsm,obsm]
				msummkhgm=msummkhg[obsm,obsm]
				// (numerical) derivative of predicted market shares wrt. sigma parameters
				for (i=1; i<=cols(endog)-1; i++) {
					sigmagm=sigmag[obsm]
					sigmahm=sigmah[obsm]
					sigmakm=sigmak[obsm]
					sigmas0m=sigmagm,sigmahm,sigmakm
					sigmasm=sigmas0m
					for (ii=1; ii<=2; ii++) {
						// sigma parameters
						if (ii==1) {
							sigmasm[.,i]=sigmas0m[.,i]:+J(rows(obsm),1,epsilon[1,i])
						}
						if (ii==2) {
							sigmasm[.,i]=sigmas0m[.,i]:-J(rows(obsm),1,epsilon[1,i])
						}
						sigmagm=sigmasm[.,1]
						sigmahm=sigmasm[.,2]
						sigmakm=sigmasm[.,3]
						// market shares
						sm=shatm_nlogit3(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,sigmakm,msummgm,msummhgm,msummkhgm)
						// derivative
						if (ii==1) {
							dsdsigmam=sm
						}
						if (ii==2) {
							dsdsigmam=(dsdsigmam:-sm)/(2*epsilon[1,i])
						}
					}
					// predicted market shares
					sigmagm=sigmas0m[.,1]
					sigmahm=sigmas0m[.,2]
					sigmakm=sigmas0m[.,3]
					sm=shatm_nlogit3(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,sigmakm,msummgm,msummhgm,msummkhgm)
					sjgm=(sm):/(msummgm*sm)
					sjhm=(sm):/(msummhgm*sm)
					sjkm=(sm):/(msummkhgm*sm)
					// derivative of predicted market shares wrt. mean utilities
					dsddelta=-sm*(sm)'
					dsddelta=dsddelta:-(sm*((sigmagm:/(onem:-sigmagm)):*sjgm)'):*msummgm
					dsddelta=dsddelta:-(sm*(( (onem:/(onem:-sigmahm)):-(onem:/(onem:-sigmagm)) ):*sjhm)'):*msummhgm
					dsddelta=dsddelta:-(sm*(( (onem:/(onem:-sigmakm)):-(onem:/(onem:-sigmahm)) ):*sjkm)'):*msummkhgm
					dsddelta=dsddelta:+diag(sm:/(onem:-sigmakm))
					// filling up: derivative of mean utilities wrt. sigma parameters
					ddelta[obsm,i]=luinv(dsddelta)*dsdsigmam
				}
			}
		}
		for (i=1; i<=cols(endog)-1; i++) {
			ddelta[select(obs,rowmissing(ddelta[.,i])),i]=0:*(select(obs,rowmissing(ddelta[.,i])):!=0)	// treat missing values
		}
	}

	// II. conditional expectation of the derivative of the demand error term (ksi) wrt. sigma parameters
	dxb=xd_hat[.,2..cols(xd_hat)]*(pxdz0*ddelta)
	dksi=ddelta-dxb

	// III. conditional expectation of the derivative of price equation error term (omega) wrt. sigma parameters
	// "observed" marginal costs
	mc=J(rows(market),1,0)
	for (mm=1; mm<=colmax(market); mm++) {												// calculations by market
		obsm=select(obs,market:==mm)
		onem=one[obsm]
		pm=p[obsm]
		sm=s[obsm]
		alpham=alpha[obsm]
		msizem=msize[obsm]
		vatm=vat[obsm]
		// one-level nested logit model
		if (cols(endog)==2) {
			msummfm=msummf[obsm,obsm]
			msummgm=msummg[obsm,obsm]
			msummfgm=msummfg[obsm,obsm]
			nmsummfgm=nmsummfg[obsm]
			sigmagm=sigmag[obsm]
			mcm=marginal_cost_nlogit(sm,pm,msizem,vatm,alpham,sigmagm,msummfm,msummgm,msummfgm,nmsummfgm)
		}
		// two-level nested logit model
		if (cols(endog)==3) {
			msummfm=msummf[obsm,obsm]
			msummgm=msummg[obsm,obsm]
			msummhgm=msummhg[obsm,obsm]
			msummfgm=msummfg[obsm,obsm]
			msummfhgm=msummfhg[obsm,obsm]
			nmsummfgm=nmsummfg[obsm]
			nmsummfhgm=nmsummfhg[obsm]
			sigmagm=sigmag[obsm]
			sigmahm=sigmah[obsm]
			mcm=marginal_cost_nlogit2(sm,p_hatm,msizem,vatm,alpham,sigmagm,sigmahm,msummfm,msummgm,msummhgm,msummfgm,msummfhgm,nmsummfgm,nmsummfhgm)
		}
		// three-level nested logit model
		if (cols(endog)==4) {
			msummfm=msummf[obsm,obsm]
			msummgm=msummg[obsm,obsm]
			msummhgm=msummhg[obsm,obsm]
			msummkhgm=msummkhg[obsm,obsm]
			msummfgm=msummfg[obsm,obsm]
			msummfhgm=msummfhg[obsm,obsm]
			msummfkhgm=msummfkhg[obsm,obsm]
			nmsummfgm=nmsummfg[obsm]
			nmsummfhgm=nmsummfhg[obsm]
			nmsummfkhgm=nmsummfkhg[obsm]
			sigmagm=sigmag[obsm]
			sigmahm=sigmah[obsm]
			sigmakm=sigmak[obsm]
			mcm=marginal_cost_nlogit3(sm,p_hatm,msizem,vatm,alpham,sigmagm,sigmahm,sigmakm,msummfm,msummgm,msummhgm,msummkhgm,msummfgm,msummfhgm,msummfkhgm,nmsummfgm,nmsummfhgm,nmsummfkhgm)
		}
		mc[obsm]=mcm
	}
	gamma=pxpz*mc																		// linear parameters of the price equation
	xg=xp*gamma																			// linear predictions of the marginal costs
	domega=J(rows(market),cols(endog)-1,0)												// derivative of price equation error term (omega) wrt. sigma parameters
	epsilon=J(1,cols(endog)-1,0.0000001)												// difference in the parameter value for numerical derivatives
	for (mm=1; mm<=colmax(market); mm++) {												// calculations by market
		obsm=select(obs,market:==mm)
		onem=one[obsm]
		p_hatm=p_hat[obsm]
		xb0_hatm=xb0_hat[obsm]
		ksim=J(rows(obsm),1,0)
		alpham=alpha[obsm]
		msizem=msize[obsm]
		vatm=vat[obsm]
		pxpzm=pxpz[.,obsm]
		xgm=xg[obsm,.]
		// one-level nested logit model
		if (cols(endog)==2) {
			msummfm=msummf[obsm,obsm]
			msummgm=msummg[obsm,obsm]
			msummfgm=msummfg[obsm,obsm]
			nmsummfgm=nmsummfg[obsm]
			// (numerical) derivative of predicted market shares wrt. sigma parameters
			for (ii=1; ii<=2; ii++) {
				// sigma parameter
				if (ii==1) {
					sigmagm=sigmag[obsm]:+J(rows(obsm),1,epsilon[1,1])
				}
				if (ii==2) {
					sigmagm=sigmag[obsm]:-J(rows(obsm),1,epsilon[1,1])
				}
				// market shares and implied marginal costs
				sm=shatm_nlogit(p_hatm,xb0_hatm,ksim,alpham,sigmagm,msummgm)
				mcm=marginal_cost_nlogit(sm,p_hatm,msizem,vatm,alpham,sigmagm,msummfm,msummgm,msummfgm,nmsummfgm)
				// price error term (unobserved marginal cost shocks)
				omegam=mcm-xgm
				// derivative
				if (ii==1) {
					domega[obsm,1]=omegam
				}
				if (ii==2) {
					domega[obsm,1]=(domega[obsm,1]:-omegam)/(2*epsilon[1,1])
				}
			}
		}
		// two-level nested logit model
		if (cols(endog)==3) {
			msummfm=msummf[obsm,obsm]
			msummgm=msummg[obsm,obsm]
			msummhgm=msummhg[obsm,obsm]
			msummfgm=msummfg[obsm,obsm]
			msummfhgm=msummfhg[obsm,obsm]
			nmsummfgm=nmsummfg[obsm]
			nmsummfhgm=nmsummfhg[obsm]
			// (numerical) derivative of predicted market shares wrt. sigma parameters
			for (i=1; i<=cols(endog)-1; i++) {
				sigmagm=sigmag[obsm]
				sigmahm=sigmah[obsm]
				sigmas0m=sigmagm,sigmahm
				sigmasm=sigmas0m
				for (ii=1; ii<=2; ii++) {
					// sigma parameters
					if (ii==1) {
						sigmasm[.,i]=sigmas0m[.,i]:+J(rows(obsm),1,epsilon[1,i])
					}
					if (ii==2) {
						sigmasm[.,i]=sigmas0m[.,i]:-J(rows(obsm),1,epsilon[1,i])
					}
					sigmagm=sigmasm[.,1]
					sigmahm=sigmasm[.,2]
					// market shares and implied marginal costs
					sm=shatm_nlogit2(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,msummgm,msummhgm)
					mcm=marginal_cost_nlogit2(sm,p_hatm,msizem,vatm,alpham,sigmagm,sigmahm,msummfm,msummgm,msummhgm,msummfgm,msummfhgm,nmsummfgm,nmsummfhgm)
					// price error term (unobserved marginal cost shocks)
					omegam=mcm-xgm
					// derivative
					if (ii==1) {
						domega[obsm,i]=omegam
					}
					if (ii==2) {
						domega[obsm,i]=(domega[obsm,i]:-omegam)/(2*epsilon[1,i])
					}
				}

			}
		}
		// three-level nested logit model
		if (cols(endog)==4) {
			msummfm=msummf[obsm,obsm]
			msummgm=msummg[obsm,obsm]
			msummhgm=msummhg[obsm,obsm]
			msummkhgm=msummkhg[obsm,obsm]
			msummfgm=msummfg[obsm,obsm]
			msummfhgm=msummfhg[obsm,obsm]
			nmsummfgm=nmsummfg[obsm]
			nmsummfhgm=nmsummfhg[obsm]
			nmsummfkhgm=nmsummfkhg[obsm]
			// (numerical) derivative of predicted market shares wrt. sigma parameters
			for (i=1; i<=cols(endog)-1; i++) {
				sigmagm=sigmag[obsm]
				sigmahm=sigmah[obsm]
				sigmakm=sigmak[obsm]
				sigmas0m=sigmagm,sigmahm,sigmakm
				sigmasm=sigmas0m
				for (ii=1; ii<=2; ii++) {
					// sigma parameters
					if (ii==1) {
						sigmasm[.,i]=sigmas0m[.,i]:+J(rows(obsm),1,epsilon[1,i])
					}
					if (ii==2) {
						sigmasm[.,i]=sigmas0m[.,i]:-J(rows(obsm),1,epsilon[1,i])
					}
					sigmagm=sigmasm[.,1]
					sigmahm=sigmasm[.,2]
					sigmakm=sigmasm[.,3]
					// market shares and implied marginal costs
					sm=shatm_nlogit3(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,sigmakm,msummgm,msummhgm,msummkhgm)
					mcm=marginal_cost_nlogit3(sm,p_hatm,msizem,vatm,alpham,sigmagm,sigmahm,sigmakm,msummfm,msummgm,msummhgm,msummkhgm,msummfgm,msummfhgm,msummfkhgm,nmsummfgm,nmsummfhgm,nmsummfkhgm)
					// price error term (unobserved marginal cost shocks)
					omegam=mcm-xgm
					// derivative
					if (ii==1) {
						domega[obsm,i]=omegam
					}
					if (ii==2) {
						domega[obsm,i]=(domega[obsm,i]:-omegam)/(2*epsilon[1,i])
					}
				}

			}
		}
	}

	// optimal instruments
	opti=dksi,p_hat,domega
	return(opti)

}	// end of opti_nlogit_eq function
mata mlib add lrcl opti_nlogit_eq()


// estimation of the nested logit equilibrium model (demand and pricing equations as a simulataneous system)
void estimation_nlogit_eq(
	string scalar share0,
	string scalar iexog0,
	string scalar xp0,
	string scalar endog0,
	string scalar exexog0,
	string scalar pexexog0,
	string scalar prexexog0,
	string scalar g0,
	string scalar h0,
	string scalar k0,
	string scalar market0,
	string scalar msize0,
	string scalar firm0,
	string scalar vat0,
	string scalar params00,
	string scalar estimator,
	string scalar optimal,
	string scalar robust,
	string scalar cluster0,
	string scalar touse,
	string scalar nodisplay0
	)
{

	// declarations
	external real matrix x0,endog,z00,rc,msumm,msummf,msummg,msummfg,msummhg,msummfhg,msummkhg,msummfkhg,market_rows,xd,xp,xd0,zd,zp,wd,wp,w,pxdz0,pxpz,dksi,domega,zpr00
	external real colvector s,g,market,vat,msize,d0,obs,q,qg,qhg,qkhg,qf,qfg,qfhg,qfkhg,nmsummg,nmsummhg,nmsummkhg,nmsummfg,nmsummfhg,nmsummfkhg,lns,s0,lnss0,p,delta0,firm,cluster,xb0,xb,ksi,omega,beta,gamma,one,mc,mrkp
	external real rowvector params0,params,eparams
	external real scalar ndvars,jj,tol,itol,imaxiter,dparams,ddelta,dwd,nsteps,kconv,ddelta0,dparams0,correction_last,corrections,w_update,klastconv,kk0,kk,value0,value,iterations,converged,r2,Fdf1,Fdf2,Fp

	// load data
	st_view(s, .,share0,touse)
	st_view(xd0, .,tokens(iexog0),touse)
	st_view(xp, .,tokens(xp0),touse)
	st_view(endog, .,tokens(endog0),touse)
	if (exexog0!="") {
		st_view(zd00, .,tokens(exexog0),touse)
	}
	if (pexexog0!="") {
		st_view(zp00, .,tokens(pexexog0),touse)
	}
	if (prexexog0!="") {
		st_view(zpr00, .,tokens(prexexog0),touse)
	}
	if (g0!="") {
		st_view(g, .,tokens(g0),touse)
		if (h0!="") {
			st_view(h, .,tokens(h0),touse)
			if (k0!="") {
				st_view(k, .,tokens(k0),touse)
			}
		}
	}
	st_view(market, .,tokens(market0),touse)
	st_view(msize, .,tokens(msize0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(vat, .,tokens(vat0),touse)
	if (params00!="") {
		params0=abs(st_matrix(params00))
		params0[1,1]=abs(params0[1,1])
	}
	cluster=runningsum(J(rows(market),1,1))
	if (cluster0!="") {
		st_view(cluster, .,tokens(cluster0),touse)
	}

	// index of observations and constant
	obs=runningsum(J(rows(market),1,1))
	one=J(rows(market),1,1)

	// reindexing (categorical variables should start from 1 and increment by 1)
	market=reindex(market)
	firm=reindex(firm)
	cluster=reindex(cluster)
	if (g0!="") {
		g=reindex(g)
		if (h0!="") {
			h=reindex(h)
			if (k0!="") {
				k=reindex(k)
			}
		}
	}

	// price and quantity
	p=endog[.,1]
	q=s:*msize

	// summation matrices, sums of quantities
	msumm=amsumf(obs,market)
	msummf=msumm:*amsumf(obs,firm)
	qf=msummf*q
	if (g0!="") {
		msummg=msumm:*amsumf(obs,g)
		qg=msummg*q
		nmsummg=msummg*J(rows(market),1,1)
		msummfg=msummf:*msummg
		qfg=msummfg*q
		nmsummfg=msummfg*J(rows(market),1,1)
		if (h0!="") {
			msummhg=msummg:*amsumf(obs,h)
			qhg=msummhg*q
			nmsummhg=msummhg*J(rows(market),1,1)
			msummfhg=msummf:*msummhg
			qfhg=msummfhg*q
			nmsummfhg=msummfhg*J(rows(market),1,1)
			if (k0!="") {
				msummkhg=msummhg:*amsumf(obs,k)
				qkhg=msummkhg*q
				nmsummkhg=msummkhg*J(rows(market),1,1)
				msummfkhg=msummf:*msummkhg
				qfkhg=msummfkhg*q
				nmsummfkhg=msummfkhg*J(rows(market),1,1)
			}
		}
	}

	// log market shares, and outside good's share
	lns=ln(s)
	lns[select(obs,rowmissing(lns))]=min(lns):*(select(obs,rowmissing(lns)):!=0)		// treat missing values
	s0=1:-(msumm*s)
	lnss0=lns:-ln(s0)
	d0=J(rows(market),1,1):/msize

	// treat missing values
	for (i=1; i<=cols(endog); i++) {
		endog[select(obs,rowmissing(endog[.,i])),i]=min(endog[.,i]):*(select(obs,rowmissing(endog[.,i])):!=0)
	}
	for (i=1; i<=cols(xd0); i++) {
		xd0[select(obs,rowmissing(xd0[.,i])),i]=min(xd0[.,i]):*(select(obs,rowmissing(xd0[.,i])):!=0)
	}
	if (exexog0!="") {
		for (i=1; i<=cols(zd00); i++) {
			zd00[select(obs,rowmissing(zd00[.,i])),i]=min(zd00[.,i]):*(select(obs,rowmissing(zd00[.,i])):!=0)
		}
	}
	if (pexexog0!="") {
		for (i=1; i<=cols(zp00); i++) {
			zp00[select(obs,rowmissing(zp00[.,i])),i]=min(zp00[.,i]):*(select(obs,rowmissing(zp00[.,i])):!=0)
		}
	}

	// panel structure
	market_rows=panelsetup(market,1)
	if (rows(market_rows)<rows(market)) {
		market_rows=market_rows\J(rows(market)-rows(market_rows),cols(market_rows),0)
	}
	market_rows=select(market_rows,market_rows[.,1]:!=0)

	// linear regressors
	xd=endog,xd0
	
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
		pxdz0=invsym(xd0'*zd*wd*zd'*xd0)*xd0'*zd*wd*zd'
	}
	else {
		pxdz0=invsym(xd0'*xd0)*xd0'
	}
	pxpz=invsym(xp'*xp)*xp'

	// tolerance
	tol=0.000001																		// tolerance bound for convergence of the sequence of ABLP estimators (k-loop)

	// starting parameter vector, weigthing matrices and projector matrices
	// starting parameter vector (row vector params0): first element: alpha (negative of the coefficient on price), subsequent elements: nest sigmas
	if (params00=="") {
		params0=pxdz*lnss0
		params0=params0[1..cols(endog)]'
		params0[1,1]=-params0[1,1]
	}
	// consistency of sigma starting parameters (0<=sigmag<=sigmah<=sigmak<1)
	if (g0!="") {
		params0[1,2]=(0.0000002*(params0[1,2]:<0)) :+ params0[1,2]:*(params0[1,2]:>=0)
		params0[1,2]=(.9*(params0[1,2]:>=1)) :+ params0[1,2]:*(params0[1,2]:<1)
		if (h0!="") {
			params0[1,3]=(0.0000002*(params0[1,3]:<0)) :+ params0[1,3]:*(params0[1,3]:>=0)
			params0[1,3]=(.9*(params0[1,3]:>=1)) :+ params0[1,3]:*(params0[1,3]:<1)
			params0[1,3]=(params0[1,2]:*(params0[1,3]:<params0[1,2])) :+ params0[1,3]:*(params0[1,3]:>=params0[1,2])
			if (k0!="") {
				params0[1,4]=(0.0000002*(params0[1,4]:<0)) :+ params0[1,4]:*(params0[1,4]:>=0)
				params0[1,4]=(.9*(params0[1,4]:>=1)) :+ params0[1,4]:*(params0[1,4]:<1)
				params0[1,4]=(params0[1,3]:*(params0[1,4]:<params0[1,3])) :+ params0[1,4]:*(params0[1,4]:>=params0[1,3])
			}
		}
	}
	params=params0
	w=w_nlogit_eq(zd,zp,params,g0,h0,k0,robust,cluster,estimator)
	wd=w[1..cols(zd),1..cols(zd)]
	wp=w[cols(zd)+1..cols(zd)+cols(zp),cols(zd)+1..cols(zd)+cols(zp)]
	pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
	if (endog0!="" & cols(endog)>1) {
		pxdz0=invsym(xd0'*zd*wd*zd'*xd0)*xd0'*zd*wd*zd'
	}
	else {
		pxdz0=invsym(xd0'*xd0)*xd0'
	}
	pxpz=invsym(xp'*xp)*xp'

	// estimation
	S=optimize_init()
	if (g0=="" & h0=="" & k0=="") {
		optimize_init_evaluator(S, &obj_logit_eq())
	}
	if (g0!="" & h0=="" & k0=="") {
		optimize_init_evaluator(S, &obj_nlogit_eq())
	}
	if (g0!="" & h0!="" & k0=="") {
		optimize_init_evaluator(S, &obj_nlogit2_eq())
	}
	if (g0!="" & h0!="" & k0!="") {
		optimize_init_evaluator(S, &obj_nlogit3_eq())
	}
	optimize_init_evaluatortype(S, "d0")
	optimize_init_evaluatortype(S, "d1")
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
	dw=1000																				// objective #3: max. abs. change in demand weighting matrix
	nsteps=1																			// 2SLS: 1 step of optimization (with initial weighting matrix)
	if (estimator=="gmm2s") {															// Two-step GMM: 2 steps of optimization (one update of weighting matrix)	
		nsteps=2
	}
	if (estimator=="igmm") {															// Iterated GMM: several steps of optimization until convergence of weighting matrix (max 100 rounds)
		nsteps=15
	}
	kconv=0
	w0=w
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

		// updating weighting matrix based on step-k parameter vector
		if (estimator=="gmm2s" | estimator=="igmm") {
			w=w_nlogit_eq(zd,zp,params,g0,h0,k0,robust,cluster,estimator)
			wd=w[1..cols(zd),1..cols(zd)]
			wp=w[cols(zd)+1..cols(zd)+cols(zp),cols(zd)+1..cols(zd)+cols(zp)]
			pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
			if (endog0!="" & cols(endog)>1) {
				pxdz0=invsym(xd0'*zd*wd*zd'*xd0)*xd0'*zd*wd*zd'
			}
			else {
				pxdz0=invsym(xd0'*xd0)*xd0'
			}
			pxpz=invsym(xp'*xp)*xp'
		}

		// convergence criteria for step-k
		dparams=rowmax(abs(abs(params):-abs(params0)))
		dw=max(abs(w:-w0))
		if (dparams<=tol & dw<0.0005 & estimator=="igmm") {
			kconv=1
		}

		// storing
		params0=params																	// storing starting parameters
		w0=w																			// storing weighting matrix

		// updating
		optimize_init_params(S, params)													// updating starting parameters
		w=w0																			// updating weighting matrix

	}	// end of loop of GMM steps

	// variance-covariance matrix
	V=V_nlogit_eq(params,w,g0,h0,k0,robust,cluster)
	
	// full column vector of coefficients
	if (g0=="" & h0=="" & k0=="") {
		obj_logit_eq(0,params,0,0,0)
	}
	if (g0!="" & h0=="" & k0=="") {
		obj_nlogit_eq(0,params,0,0,0)
	}
	if (g0!="" & h0!="" & k0=="") {
		obj_nlogit2_eq(0,params,0,0,0)
	}
	if (g0!="" & h0!="" & k0!="") {
		obj_nlogit3_eq(0,params,0,0,0)
	}
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
	b[1,1]=-b[1,1]

	// Hansen's J-test value, p-value and degrees of freedom
	j=optimize_result_value(S)
	jdf=cols(zd)+cols(zp)-cols(xd)-cols(xp)
	jp=chi2tail(jdf,j)

	// R2
	xb0=xd0*beta																		// non-price-, non-within-segment-share specific mean observed utility component
	rss_d=quadcross(ksi,ksi)
	yyc_d=quadcrossdev(lnss0,mean(lnss0),lnss0,mean(lnss0))
	rss_p=quadcross(omega,omega)
	yyc_p=quadcrossdev(p,mean(p),p,mean(p))
	r2=1-rss_d/yyc_d
	r2_d=1-rss_d/yyc_d
	r2_p=1-rss_p/yyc_p
	r2_a=1-(rss_d/yyc_d)*(rows(lnss0)-1)/(rows(lnss0)-cols(params)-cols(beta'))
	r2_a_d=1-(rss_d/yyc_d)*(rows(lnss0)-1)/(rows(lnss0)-cols(params)-cols(beta'))
	r2_a_p=1-(rss_p/yyc_p)*(rows(lnss0)-1)/(rows(lnss0)-cols(params)-cols(gamma'))

	// F-test
	vv=diagonal(V)
	F=sum( (b[1,1..cols(b)-1]:^2) :/ (vv[1..cols(b)-1,1]') )/( cols(b)-1 )
	Fdf1=cols(b)-1
	Fdf2=rows(uniqrows(cluster))-cols(b)
	Fp=Ftail(Fdf1,Fdf2,F)

	// calculating the optimal instruments
	if (optimal!="" & exexog0!="" & pexexog0!="" & prexexog0!="") {
		opti=opti_nlogit_eq(params,g0,h0,k0)
		odksi=opti[.,1..cols(endog)-1]
		op_hat=opti[.,cols(endog)]
		odomega=opti[.,cols(endog)+1..cols(opti)]
	}

	// exporting results into Stata
	colnames=(J(cols(params),1,"main")\J(cols(xd0),1,"demand")\J(cols(xp),1,"pricing")),((tokens(endog0),tokens(iexog0),tokens(xp0))')
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
	stata("capture drop __mc")
	stata("quietly generate __mc=.")
	st_store( .,"__mc",touse,mc)
	stata("capture drop __mrkp")
	stata("quietly generate __mrkp=.")
	st_store( .,"__mrkp",touse,mrkp)
	if (optimal!="" & exexog0!="" & pexexog0!="" & prexexog0!="") {
		stata("capture drop __optie*")
		for (i=1; i<=cols(dksi); i++) {
			if (g0!="") {
				stata("capture drop __optieksg")
				st_store(., st_addvar("double", "__optieksg"),touse, odksi[.,1])
				if (h0!="") {
					stata("capture drop __optieksh")
					st_store(., st_addvar("double", "__optieksh"),touse, odksi[.,2])
					if (k0!="") {
						stata("capture drop __optieksk")
						st_store(., st_addvar("double", "__optieksk"),touse, odksi[.,3])
					}
				}
			}
		}
		stata("capture drop __optiep*")
		st_store(., st_addvar("double", "__optiep"),touse, op_hat)
		stata("capture drop __optieo*")
		for (i=1; i<=cols(odomega); i++) {
			if (g0!="") {
				stata("capture drop __optieosg")
				st_store(., st_addvar("double", "__optieosg"),touse, odomega[.,1])
				if (h0!="") {
					stata("capture drop __optieosh")
					st_store(., st_addvar("double", "__optieosh"),touse, odomega[.,2])
					if (k0!="") {
						stata("capture drop __optieosk")
						st_store(., st_addvar("double", "__optieosk"),touse, odomega[.,3])
					}
				}
			}
		}
	}

}	// end of estimation_nlogit_eq function
mata mlib add lrcl estimation_nlogit_eq()


// pointer generating the GMM objective (simple logit model)
void obj_logit_eq(todo,params,obj,grad,H)
{

	// declarations
	external real matrix endog,xd,xp,xd0,zd,zp,market_rows,pxdz0,pxpz,w,msummf,wd,wp,dksi,domega
	external real colvector market,vat,obs,lnss0,p,d0,g,qf,qg,qfg,nmsummfg,ksi,omega,beta,gamma,one,mc,mrkp
	real matrix dxb0
	real colvector sigmas,lnsm,sm,wm,xb,im,gm,lnss01
	real scalar iitol,i,dif,sigmag,kk

	// parameters
	alpha=J(rows(market),1,params[1,1])													// alpha: negative of coefficient on price in the mean utility

	// demand side
	lnss01=lnss0:+(alpha:*p)															// mean utility without the price component
	beta=pxdz0*lnss01																	// linear parameters (on rhs variables other than "endogenous" regressors)
	xb0=xd0*beta																		// linear predictions (from rhs variables other than "endogenous" regressors)
	ksi=lnss01-xb0																		// error term (unobserved product characteristics)

	// price equation
	summa0=qf:/((one:-(d0:*qf)):*(alpha:*(1:+vat)))
	mrkp=( (one:/(alpha:*(1:+vat))) :+(d0:*summa0) )
	mc=(p:/(1:+vat)):-mrkp

	// price error term and linear parameters of the price equation
	gamma=pxpz*mc																		// linear parameters of the price equation
	xg=xp*gamma																			// linear predictions of the marginal costs
	omega=mc-xg																			// price error term (unobserved marginal cost shocks)

	// objective
	q=(zd'*ksi)\(zp'*omega)																// stacked vector of empirical moments
	obj=q'*w*q/rows(market)																// GMM objective: quadratic form of moments

	// gradient
	if (todo>=1) {
		// derivative of demand error term (ksi)
		dlnss01=endog[.,1]
		dxb0=xd0*(pxdz0*dlnss01)
		dksi=dlnss01-dxb0
		// derivative of price equation error term (omega)
		dsumma0=(-one:/(alpha:^2)):*(qf:/(one:-(d0:*qf))):/(1:+vat)
		dmc=-( -(one:/((alpha:^2):*(1:+vat))) :+ d0:*dsumma0 )
		dxg=xp*(pxpz*dmc)
		domega=dmc-dxg
		// derivative of stacked moment vector
		dq=(zd'*dksi)\(zp'*domega)
		// gradient
		grad=2*q'*w*dq/rows(market)
	}

}	// end of GMM objective pointer (simple logit equilibirum model)
mata mlib add lrcl obj_logit_eq()



// pointer generating the GMM objective (equilibrium one-level nested logit model)
void obj_nlogit_eq(todo,params,obj,grad,H)
{

	// declarations
	external real matrix endog,xd,xp,xd0,zd,zp,market_rows,pxdz0,pxpz,w,msummf,wd,wp,dksi,domega
	external real colvector market,vat,obs,lnss0,p,d0,g,qg,qfg,nmsummfg,ksi,omega,beta,gamma,one,mc,mrkp
	real matrix dxb0
	real colvector sigmas,lnsm,sm,wm,xb,im,gm,lnss01
	real scalar iitol,i,dif,sigmag,kk

	// parameters
	alpha=J(rows(market),1,params[1,1])													// alpha: negative of coefficient on price in the mean utility
	sigmag=J(rows(market),cols(endog)-1,params[1,2..cols(endog)])						// sigma of nest

	// demand side
	lnss01=lnss0:+(alpha:*p):-(sigmag:*endog[.,2..1+cols(sigmag)])						// mean utility without the price component
	beta=pxdz0*lnss01																	// linear parameters (on rhs variables other than "endogenous" regressors)
	xb0=xd0*beta																		// linear predictions (from rhs variables other than "endogenous" regressors)
	ksi=lnss01-xb0																		// error term (unobserved product characteristics)

	// price equation
	dg=((sigmag:/(one:-sigmag)):/qg)
	gammag=(one:-sigmag):*qfg
	lambdag=gammag:/(one:-(dg:*gammag))
	gamma0=msummf*lambdag:/nmsummfg
	summa0=gamma0:/((one:-(d0:*gamma0)):*(alpha:*(1:+vat)))
	summag=(lambdag:/(alpha:*(1:+vat))):+(lambdag:*d0:*summa0)
	mrkp=(one:-sigmag):*( (one:/(alpha:*(1:+vat))) :+ (dg:*summag) :+(d0:*summa0) )
	mc=(p:/(1:+vat)):-mrkp

	// price error term and linear parameters of the price equation
	gamma=pxpz*mc																		// linear parameters of the price equation
	xg=xp*gamma																			// linear predictions of the marginal costs
	omega=mc-xg																			// price error term (unobserved marginal cost shocks)

	// objective
	q=(zd'*ksi)\(zp'*omega)																// stacked vector of empirical moments
	obj=q'*w*q/rows(market)																// GMM objective: quadratic form of moments

	// gradient
	if (todo>=1) {
		// derivative of demand error term (ksi)
		dlnss01=endog[.,1],-endog[.,2..1+cols(sigmag)]
		dxb0=xd0*(pxdz0*dlnss01)
		dksi=dlnss01-dxb0
		// derivative of price equation error term (omega)
		ddg=( one:/((one:-sigmag):^2) ):/qg
		dgammag=-qfg
		dlambdag=dgammag:*( one:-(dg:*gammag) ) :- gammag:*( -(dg:*dgammag) :- (ddg:*gammag) )
		dlambdag=dlambdag:/( (one:-(dg:*gammag)):^2 )
		dgamma0=msummf*dlambdag:/nmsummfg
		dsumma0=dgamma0:*((one:-(d0:*gamma0))) :- (gamma0:*(-d0:*dgamma0))
		dsumma0=dsumma0:/( (one:-(d0:*gamma0)):^2 )
		dsumma0=dsumma0:/( alpha:*(1:+vat) )
		dsumma0=(-one:/(alpha:^2)):*(gamma0:/(one:-(d0:*gamma0))):/(1:+vat),dsumma0
		dsummag=(dlambdag:/(alpha:*(1:+vat))) :+ (dlambdag:*d0:*summa0 :+ lambdag:*d0:*dsumma0[.,2..1+cols(sigmag)])
		dsummag=(-one:/(alpha:^2)):*lambdag:/(1:+vat) :+ (lambdag:*d0:*dsumma0[.,1]),dsummag
		dmc=( (one:/(alpha:*(1:+vat))) :+ (dg:*summag) :+(d0:*summa0) )
		dmc=dmc :- (one:-sigmag):*( (ddg:*summag :+ dg:*dsummag) :+(d0:*dsumma0) )
		dmc[.,1]=-(one:-sigmag):*( -(one:/((alpha:^2):*(1:+vat))) :+ dg:*dsummag[.,1] :+ d0:*dsumma0[.,1] )
		dxg=xp*(pxpz*dmc)
		domega=dmc-dxg
		// derivative of stacked moment vector
		dq=(zd'*dksi)\(zp'*domega)
		// gradient
		grad=2*q'*w*dq/rows(market)
	}

}	// end of GMM objective pointer (one-level nested logit equilibirum model)
mata mlib add lrcl obj_nlogit_eq()



// pointer generating the GMM objective (equilibrium two-level nested logit model)
void obj_nlogit2_eq(todo,params,obj,grad,H)
{

	// declarations
	external real matrix endog,xd,xp,xd0,zd,zp,market_rows,pxdz0,pxpz,w,msummf,msummfg,wd,wp,dksi,domega
	external real colvector market,vat,obs,lnss0,p,d0,g,h,qg,qhg,qfhg,nmsummfg,nmsummfhg,ksi,omega,beta,gamma,one,mc,mrkp
	real matrix dxb0
	real colvector sigmas,lnsm,sm,wm,xb,im,gm,lnss01,dg,dhg,gammahg,lambdahg,gammag,lamdag,gamma0,summa0,summag,summahg
	real scalar iitol,i,dif,sigmag,sigmah,kk

	// parameters
	alpha=J(rows(market),1,params[1,1])													// alpha: negative of coefficient on price in the mean utility
	sigmag=J(rows(market),1,params[1,2])												// sigma of nest
	sigmah=J(rows(market),1,params[1,3])												// sigma of subnest

	// demand side
	lnss01=lnss0:+(alpha:*p):-(sigmag:*endog[.,2]):-(sigmah:*endog[.,3])				// mean utility without the price component
	beta=pxdz0*lnss01																	// linear parameters (on rhs variables other than "endogenous" regressors)
	xb0=xd0*beta																		// linear predictions (from rhs variables other than "endogenous" regressors)
	ksi=lnss01-xb0																		// error term (unobserved product characteristics)

	// price equation
	dg=((sigmag:/(one:-sigmag)):/qg)
	dhg=( (one:/(one:-sigmah)):-(one:/(one:-sigmag)) ):/qhg
	gammahg=(one:-sigmah):*qfhg
	lambdahg=gammahg:/(one:-(dhg:*gammahg))
	gammag=msummfg*lambdahg:/nmsummfhg
	lambdag=gammag:/(one:-(dg:*gammag))
	gamma0=msummf*lambdag:/nmsummfg
	summa0=gamma0:/((one:-(d0:*gamma0)):*(alpha:*(1:+vat)))
	summag=(lambdag:/(alpha:*(1:+vat))):+(lambdag:*d0:*summa0)
	summahg=(lambdahg:/(alpha:*(1:+vat))):+(lambdahg:*dg:*summag):+(lambdahg:*d0:*summa0)
	mrkp=(one:-sigmah):*( (one:/(alpha:*(1:+vat))) :+ (dhg:*summahg) :+ (dg:*summag) :+(d0:*summa0) )
	mc=(p:/(1:+vat)):-mrkp

	// price error term and linear parameters of the price equation
	gamma=pxpz*mc																		// linear parameters of the price equation
	xg=xp*gamma																			// linear predictions of the marginal costs
	omega=mc-xg																			// price error term (unobserved marginal cost shocks)

	// objective
	q=(zd'*ksi)\(zp'*omega)																// stacked vector of empirical moments
	obj=q'*w*q/rows(market)																// GMM objective: quadratic form of moments

	// gradient
	if (todo>=1) {
		// derivative of demand error term (ksi)
		dlnss01=endog[.,1],-endog[.,2..3]
		dxb0=xd0*(pxdz0*dlnss01)
		dksi=dlnss01-dxb0
		// derivative of price equation error term (omega)
		dmc=J(rows(market),3,0)
		// wrt. sigmag
		ddhg=( -one:/((one:-sigmag):^2) ):/qhg
		ddg=( one:/((one:-sigmag):^2) ):/qg
		dlambdahg=(ddhg:*(gammahg:^2)):/((one:-(dhg:*gammahg)):^2)
		dgammag=msummfg*dlambdahg:/nmsummfhg
		dlambdag=dgammag:*( one:-(dg:*gammag) ) :- gammag:*( -(dg:*dgammag) :- (ddg:*gammag) )
		dlambdag=dlambdag:/( (one:-(dg:*gammag)):^2 )
		dgamma0=msummf*dlambdag:/nmsummfg
		dsumma0=dgamma0:*((one:-(d0:*gamma0))) :- (gamma0:*(-d0:*dgamma0))
		dsumma0=dsumma0:/( (one:-(d0:*gamma0)):^2 )
		dsumma0=dsumma0:/( alpha:*(1:+vat) )
		dsummag=(dlambdag:/(alpha:*(1:+vat))) :+ (dlambdag:*d0:*summa0 :+ lambdag:*d0:*dsumma0)
		dsummahg=(dlambdahg:/(alpha:*(1:+vat))) :+ (dlambdahg:*(dg:*summag) :+ lambdahg:*(ddg:*summag :+ dg:*dsummag)) :+ (dlambdahg:*d0:*summa0 :+ lambdahg:*d0:*dsumma0)
		dmc[.,3]=-(one:-sigmah):*( (ddhg:*summahg :+ dhg:*dsummahg) :+ (ddg:*summag :+ dg:*dsummag) :+ (d0:*dsumma0) )
		// wrt. sigmah
		ddhg=( one:/((one:-sigmah):^2) ):/qhg
		ddg=J(rows(market),1,0)
		dgammahg=-qfhg
		dlambdahg=dgammahg:*( one:-(dhg:*gammahg) ) :- gammahg:*( -(dhg:*dgammahg) :- (ddhg:*gammahg) )
		dlambdahg=dlambdahg:/( (one:-(dhg:*gammahg)):^2 )
		dgammag=msummfg*dlambdahg:/nmsummfhg
		dlambdag=dgammag:*( one:-(dg:*gammag) ) :- gammag:*( -(dg:*dgammag) :- (ddg:*gammag) )
		dlambdag=dlambdag:/( (one:-(dg:*gammag)):^2 )
		dgamma0=msummf*dlambdag:/nmsummfg
		dsumma0=dgamma0:*((one:-(d0:*gamma0))) :- (gamma0:*(-d0:*dgamma0))
		dsumma0=dsumma0:/( (one:-(d0:*gamma0)):^2 )
		dsumma0=dsumma0:/( alpha:*(1:+vat) )
		dsummag=(dlambdag:/(alpha:*(1:+vat))) :+ (dlambdag:*d0:*summa0 :+ lambdag:*d0:*dsumma0)
		dsummahg=(dlambdahg:/(alpha:*(1:+vat))) :+ (dlambdahg:*(dg:*summag) :+ lambdahg:*(ddg:*summag :+ dg:*dsummag)) :+ (dlambdahg:*d0:*summa0 :+ lambdahg:*d0:*dsumma0)
		dmc[.,2]=( (one:/(alpha:*(1:+vat))) :+ (dhg:*summahg) :+ (dg:*summag) :+(d0:*summa0) )
		dmc[.,2]=dmc[.,2] :- (one:-sigmah):*( (ddhg:*summahg :+ dhg:*dsummahg) :+ (dg:*dsummag) :+ (d0:*dsumma0) )
		// wrt. alpha
		dsumma0=(-one:/(alpha:^2)):*(gamma0:/(one:-(d0:*gamma0))):/(1:+vat)
		dsummag=(-one:/(alpha:^2)):*lambdag:/(1:+vat) :+ (lambdag:*d0:*dsumma0)
		dsummahg=(-one:/(alpha:^2)):*lambdahg:/(1:+vat) :+ (lambdahg:*dg:*dsummag) :+ (lambdahg:*d0:*dsumma0)
		dmc[.,1]=-(one:-sigmah):*( -(one:/((alpha:^2):*(1:+vat))) :+ dhg:*dsummahg :+ dg:*dsummag :+ d0:*dsumma0 )
		dxg=xp*(pxpz*dmc)
		domega=dmc-dxg
		// derivative of stacked moment vector
		dq=(zd'*dksi)\(zp'*domega)
		// gradient
		grad=2*q'*w*dq/rows(market)
	}

}	// end of GMM objective pointer (two-level nested logit equilibirum model)
mata mlib add lrcl obj_nlogit2_eq()


// pointer generating the GMM objective (equilibrium three-level nested logit model)
void obj_nlogit3_eq(todo,params,obj,grad,H)
{

	// declarations
	external real matrix endog,xd,xp,xd0,zd,zp,market_rows,pxdz0,pxpz,w,msummf,msummfg,msummfhg,wd,wp,dksi,domega
	external real colvector market,vat,obs,lnss0,p,d0,g,h,k,qg,qhg,qkhg,qfkhg,nmsummfg,nmsummfhg,nmsummfkhg,ksi,omega,beta,gamma,one,mc,mrkp
	real matrix dxb0
	real colvector sigmas,lnsm,sm,wm,xb,im,gm,lnss01,dg,dhg,dkhg,gammakhg,lambdakhg,gammahg,lambdahg,gammag,lamdag,gamma0,summa0,summag,summahg,summakhg
	real scalar iitol,i,dif,sigmag,sigmah,sigmak,kk

	// parameters
	alpha=J(rows(market),1,params[1,1])													// alpha: negative of coefficient on price in the mean utility
	sigmag=J(rows(market),1,params[1,2])												// sigma of nest
	sigmah=J(rows(market),1,params[1,3])												// sigma of subnest
	sigmak=J(rows(market),1,params[1,4])												// sigma of sub-subnest

	// demand side
	lnss01=lnss0:+(alpha:*p):-(sigmag:*endog[.,2]):-(sigmah:*endog[.,3]):-(sigmak:*endog[.,4])				// mean utility without the price component
	beta=pxdz0*lnss01																	// linear parameters (on rhs variables other than "endogenous" regressors)
	xb0=xd0*beta																		// linear predictions (from rhs variables other than "endogenous" regressors)
	ksi=lnss01-xb0																		// error term (unobserved product characteristics)

	// price equation
	dg=((sigmag:/(one:-sigmag)):/qg)
	dhg=( (one:/(one:-sigmah)):-(one:/(one:-sigmag)) ):/qhg
	dkhg=( (one:/(one:-sigmak)):-(one:/(one:-sigmah)) ):/qkhg
	gammakhg=(one:-sigmak):*qfkhg
	lambdakhg=gammakhg:/(one:-(dkhg:*gammakhg))
	gammahg=msummfhg*lambdakhg:/nmsummfkhg
	lambdahg=gammahg:/(one:-(dhg:*gammahg))
	gammag=msummfg*lambdahg:/nmsummfhg
	lambdag=gammag:/(one:-(dg:*gammag))
	gamma0=msummf*lambdag:/nmsummfg
	summa0=gamma0:/((one:-(d0:*gamma0)):*(alpha:*(1:+vat)))
	summag=(lambdag:/(alpha:*(1:+vat))):+(lambdag:*d0:*summa0)
	summahg=(lambdahg:/(alpha:*(1:+vat))):+(lambdahg:*dg:*summag):+(lambdahg:*d0:*summa0)
	summakhg=(lambdakhg:/(alpha:*(1:+vat))):+(lambdakhg:*dhg:*summahg):+(lambdakhg:*dg:*summag):+(lambdakhg:*d0:*summa0)
	mrkp=(one:-sigmak):*( (one:/(alpha:*(1:+vat))) :+ (dkhg:*summakhg) :+ (dhg:*summahg) :+ (dg:*summag) :+(d0:*summa0) )
	mc=(p:/(1:+vat)):-mrkp

	// price error term and linear parameters of the price equation
	gamma=pxpz*mc																		// linear parameters of the price equation
	xg=xp*gamma																			// linear predictions of the marginal costs
	omega=mc-xg																			// price error term (unobserved marginal cost shocks)

	// objective
	q=(zd'*ksi)\(zp'*omega)																// stacked vector of empirical moments
	obj=q'*w*q/rows(market)																// GMM objective: quadratic form of moments

	// gradient
	if (todo>=1) {
		// derivative of demand error term (ksi)
		dlnss01=endog[.,1],-endog[.,2..4]
		dxb0=xd0*(pxdz0*dlnss01)
		dksi=dlnss01-dxb0
		// derivative of price equation error term (omega)
		dmc=J(rows(market),4,0)
		// wrt. sigmag
		ddkhg=J(rows(market),1,0)
		ddhg=( -one:/((one:-sigmag):^2) ):/qhg
		ddg=( one:/((one:-sigmag):^2) ):/qg
		dgammakhg=J(rows(market),1,0)
		dlambdakhg=J(rows(market),1,0)
		dgammahg=J(rows(market),1,0)
		dlambdahg=(ddhg:*(gammahg:^2)):/((one:-(dhg:*gammahg)):^2)
		dgammag=msummfg*dlambdahg:/nmsummfhg
		dlambdag=dgammag:*( one:-(dg:*gammag) ) :- gammag:*( -(dg:*dgammag) :- (ddg:*gammag) )
		dlambdag=dlambdag:/( (one:-(dg:*gammag)):^2 )
		dgamma0=msummf*dlambdag:/nmsummfg
		dsumma0=dgamma0:*((one:-(d0:*gamma0))) :- (gamma0:*(-d0:*dgamma0))
		dsumma0=dsumma0:/( (one:-(d0:*gamma0)):^2 )
		dsumma0=dsumma0:/( alpha:*(1:+vat) )
		dsummag=(dlambdag:/(alpha:*(1:+vat))) :+ (dlambdag:*d0:*summa0 :+ lambdag:*d0:*dsumma0)
		dsummahg=(dlambdahg:/(alpha:*(1:+vat))) :+ (dlambdahg:*(dg:*summag) :+ lambdahg:*(ddg:*summag :+ dg:*dsummag)) :+ (dlambdahg:*d0:*summa0 :+ lambdahg:*d0:*dsumma0)
		dsummakhg=(dlambdakhg:/(alpha:*(1:+vat))) :+ (dlambdakhg:*(dhg:*summahg) :+ lambdakhg:*(ddhg:*summahg :+ dhg:*dsummahg)) :+ (dlambdakhg:*(dg:*summag) :+ lambdakhg:*(ddg:*summag :+ dg:*dsummag)) :+ (dlambdakhg:*d0:*summa0 :+ lambdakhg:*d0:*dsumma0)
		dmc[.,4]=-(one:-sigmak):*( (ddkhg:*summakhg :+ dkhg:*dsummakhg) :+ (ddhg:*summahg :+ dhg:*dsummahg) :+ (ddg:*summag :+ dg:*dsummag) :+ (d0:*dsumma0) )
		// wrt. sigmah
		ddkhg=( -one:/((one:-sigmah):^2) ):/qkhg
		ddhg=( one:/((one:-sigmah):^2) ):/qhg
		ddg=J(rows(market),1,0)
		dgammakhg=J(rows(market),1,0)
		dlambdakhg=(ddkhg:*(gammakhg:^2)):/((one:-(dkhg:*gammakhg)):^2)
		dgammahg=msummfhg*dlambdakhg:/nmsummfkhg
		dlambdahg=dgammahg:*( one:-(dhg:*gammahg) ) :- gammahg:*( -(dhg:*dgammahg) :- (ddhg:*gammahg) )
		dlambdahg=dlambdahg:/( (one:-(dhg:*gammahg)):^2 )
		dgammag=msummfg*dlambdahg:/nmsummfhg
		dlambdag=dgammag:*( one:-(dg:*gammag) ) :- gammag:*( -(dg:*dgammag) :- (ddg:*gammag) )
		dlambdag=dlambdag:/( (one:-(dg:*gammag)):^2 )
		dgamma0=msummf*dlambdag:/nmsummfg
		dsumma0=dgamma0:*((one:-(d0:*gamma0))) :- (gamma0:*(-d0:*dgamma0))
		dsumma0=dsumma0:/( (one:-(d0:*gamma0)):^2 )
		dsumma0=dsumma0:/( alpha:*(1:+vat) )
		dsummag=(dlambdag:/(alpha:*(1:+vat))) :+ (dlambdag:*d0:*summa0 :+ lambdag:*d0:*dsumma0)
		dsummahg=(dlambdahg:/(alpha:*(1:+vat))) :+ (dlambdahg:*(dg:*summag) :+ lambdahg:*(ddg:*summag :+ dg:*dsummag)) :+ (dlambdahg:*d0:*summa0 :+ lambdahg:*d0:*dsumma0)
		dsummakhg=(dlambdakhg:/(alpha:*(1:+vat))) :+ (dlambdakhg:*(dhg:*summahg) :+ lambdakhg:*(ddhg:*summahg :+ dhg:*dsummahg)) :+ (dlambdakhg:*(dg:*summag) :+ lambdakhg:*(ddg:*summag :+ dg:*dsummag)) :+ (dlambdakhg:*d0:*summa0 :+ lambdakhg:*d0:*dsumma0)
		dmc[.,3]=-(one:-sigmak):*( (ddkhg:*summakhg :+ dkhg:*dsummakhg) :+ (ddhg:*summahg :+ dhg:*dsummahg) :+ (ddg:*summag :+ dg:*dsummag) :+ (d0:*dsumma0) )
		// wrt. sigmak
		ddkhg=( one:/((one:-sigmak):^2) ):/qkhg
		ddhg=J(rows(market),1,0)
		ddg=J(rows(market),1,0)
		dgammakhg=-qfkhg
		dlambdakhg=dgammakhg:*( one:-(dkhg:*gammakhg) ) :- gammakhg:*( -(dkhg:*dgammakhg) :- (ddkhg:*gammakhg) )
		dlambdakhg=dlambdakhg:/( (one:-(dkhg:*gammakhg)):^2 )
		dgammahg=msummfhg*dlambdakhg:/nmsummfkhg
		dlambdahg=dgammahg:*( one:-(dhg:*gammahg) ) :- gammahg:*( -(dhg:*dgammahg) :- (ddhg:*gammahg) )
		dlambdahg=dlambdahg:/( (one:-(dhg:*gammahg)):^2 )
		dgammag=msummfg*dlambdahg:/nmsummfhg
		dlambdag=dgammag:*( one:-(dg:*gammag) ) :- gammag:*( -(dg:*dgammag) :- (ddg:*gammag) )
		dlambdag=dlambdag:/( (one:-(dg:*gammag)):^2 )
		dgamma0=msummf*dlambdag:/nmsummfg
		dsumma0=dgamma0:*((one:-(d0:*gamma0))) :- (gamma0:*(-d0:*dgamma0))
		dsumma0=dsumma0:/( (one:-(d0:*gamma0)):^2 )
		dsumma0=dsumma0:/( alpha:*(1:+vat) )
		dsummag=(dlambdag:/(alpha:*(1:+vat))) :+ (dlambdag:*d0:*summa0 :+ lambdag:*d0:*dsumma0)
		dsummahg=(dlambdahg:/(alpha:*(1:+vat))) :+ (dlambdahg:*(dg:*summag) :+ lambdahg:*(ddg:*summag :+ dg:*dsummag)) :+ (dlambdahg:*d0:*summa0 :+ lambdahg:*d0:*dsumma0)
		dsummakhg=(dlambdakhg:/(alpha:*(1:+vat))) :+ (dlambdakhg:*(dhg:*summahg) :+ lambdakhg:*(ddhg:*summahg :+ dhg:*dsummahg)) :+ (dlambdakhg:*(dg:*summag) :+ lambdakhg:*(ddg:*summag :+ dg:*dsummag)) :+ (dlambdakhg:*d0:*summa0 :+ lambdakhg:*d0:*dsumma0)
		dmc[.,2]=( (one:/(alpha:*(1:+vat))) :+ (dkhg:*summakhg) :+ (dhg:*summahg) :+ (dg:*summag) :+(d0:*summa0) )
		dmc[.,2]=dmc[.,2] :- (one:-sigmak):*( (ddkhg:*summakhg :+ dkhg:*dsummakhg) :+ (dhg:*dsummahg) :+ (dg:*dsummag) :+ (d0:*dsumma0) )
		// wrt. alpha
		dsumma0=(-one:/(alpha:^2)):*(gamma0:/(one:-(d0:*gamma0))):/(1:+vat)
		dsummag=(-one:/(alpha:^2)):*lambdag:/(1:+vat) :+ (lambdag:*d0:*dsumma0)
		dsummahg=(-one:/(alpha:^2)):*lambdahg:/(1:+vat) :+ (lambdahg:*dg:*dsummag) :+ (lambdahg:*d0:*dsumma0)
		dsummakhg=(-one:/(alpha:^2)):*lambdakhg:/(1:+vat) :+ (lambdakhg:*dhg:*dsummahg) :+ (lambdakhg:*dg:*dsummag) :+ (lambdakhg:*d0:*dsumma0)
		dmc[.,1]=-(one:-sigmak):*( -(one:/((alpha:^2):*(1:+vat))) :+ dkhg:*dsummakhg :+ dhg:*dsummahg :+ dg:*dsummag :+ d0:*dsumma0 )
		dxg=xp*(pxpz*dmc)
		domega=dmc-dxg
		// derivative of stacked moment vector
		dq=(zd'*dksi)\(zp'*domega)
		// gradient
		grad=2*q'*w*dq/rows(market)
	}

}	// end of GMM objective pointer (three-level nested logit equilibirum model)
mata mlib add lrcl obj_nlogit3_eq()


// weigthing matrix
pointer matrix w_nlogit_eq(
	real matrix zd,
	real matrix zp,
	real rowvector params,
	string scalar g,
	string scalar h,
	string scalar k,
	string scalar robust,
	real colvector cluster,
	string scalar estimator)
{

	// declarations
	external real colvector market,ksi,omega
	real matrix sd,sp,sdp,iw,w,wd,wp,ze,lambda,sums,zec
	real rowvector uc
	real scalar sd2,sp2,sdp2

	// estimated error terms (ksi, omega)
	if (g=="" & h=="" & k=="") {
		obj_logit_eq(0,params,0,0,0)
	}
	if (g!="" & h=="" & k=="") {
		obj_nlogit_eq(0,params,0,0,0)
	}
	if (g!="" & h!="" & k=="") {
		obj_nlogit2_eq(0,params,0,0,0)
	}
	if (g!="" & h!="" & k!="") {
		obj_nlogit3_eq(0,params,0,0,0)
	}

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

}	// end of w_nlogit_eq function
mata mlib add lrcl w_nlogit_eq()


// variance-covariance matrix of equilibrium nested logit parameter estimates
pointer matrix V_nlogit_eq(
	real rowvector params,
	real matrix w,
	string scalar g,
	string scalar h,
	string scalar k,
	string scalar robust,
	real colvector cluster)
{
	external real matrix zd,zp,xd0,xp,dksi,domega
	external real colvector market,ksi,omega
	real matrix grad,V

	// estimated error terms (ksi, omega) and their derivatives (dksi, domega)
	if (g=="" & h=="" & k=="") {
		obj_logit_eq(1,params,0,0,0)
	}
	if (g!="" & h=="" & k=="") {
		obj_nlogit_eq(1,params,0,0,0)
	}
	if (g!="" & h!="" & k=="") {
		obj_nlogit2_eq(1,params,0,0,0)
	}
	if (g!="" & h!="" & k!="") {
		obj_nlogit3_eq(1,params,0,0,0)
	}
	dksi=(dksi, -xd0, J(rows(dksi),cols(xp),0))											// derivatives of demand equation's error term wrt. parameters
	domega=(domega, J(rows(domega),cols(xd0),0), -xp)									// derivatives of price equation's error term wrt. parameters

	// gradient
	grad=(zd'*dksi)\(zp'*domega)														// gradient of moment conditions

	// variance-covariance matrix
	V=invsym(grad'*w*grad/rows(market))

	// degrees of freedom adjustment
	if (robust=="" & rows(uniqrows(cluster))==rows(market)) {
		V=(rows(market)/(rows(market)-cols(params)-cols(xd0)-cols(xp)))*V
	}
	if (robust!="" | rows(uniqrows(cluster))!=rows(market)) {
		V=((rows(market)-1)/(rows(market)-cols(params)-cols(xd0)-cols(xp)))*(rows(uniqrows(cluster))/(rows(uniqrows(cluster))-1))*V
	}

	return(V)

}	// end of V_nlogit_eq function
mata mlib add lrcl V_nlogit_eq()


// function generating the optimal instruments (simple and nested logit models without pricing equation)
void opti_nlogit(
	string scalar share0,
	string scalar iexog0,
	string scalar endog0,
	string scalar exexog0,
	string scalar prexexog0,
	string scalar g0,
	string scalar h0,
	string scalar k0,
	string scalar market0,
	string scalar msize0,
	string scalar estimator,
	string scalar robust,
	string scalar cluster0,
	string scalar touse
	)
{

	// declarations
	external real matrix zpr00,xd00,msumm,msummg,pxdz0
	external real colvector market,one,nmsummg
	real matrix xpr,pxpxp,xd_hat,dsjgds,dsgds,dsdsigma,ddelta,dsdsigmam,msummgm,dsddelta,dxb,dksi
	real colvector alpha,sigmag,p,p_hat,lnss01,beta,delta,ej,dg,dgoms,d,sjg,sg,s_hat,wdeltag,eg,we,dm,pbs,onem,sigmagm,sjgm
	real scalar i

	// load data
	st_view(s, .,share0,touse)
	st_view(xd0, .,tokens(iexog0),touse)
	st_view(endog, .,tokens(endog0),touse)
	st_view(zd00, .,tokens(exexog0),touse)
	st_view(zpr00, .,tokens(prexexog0),touse)
	if (g0!="") {
		st_view(g, .,tokens(g0),touse)
		if (h0!="") {
			st_view(h, .,tokens(h0),touse)
			if (k0!="") {
				st_view(k, .,tokens(k0),touse)
			}
		}
	}
	st_view(market, .,tokens(market0),touse)
	st_view(msize, .,tokens(msize0),touse)
	cluster=runningsum(J(rows(market),1,1))
	if (cluster0!="") {
		st_view(cluster, .,tokens(cluster0),touse)
	}

	// index of observations and constant
	obs=runningsum(J(rows(market),1,1))
	one=J(rows(market),1,1)

	// reindexing (categorical variables should start from 1 and increment by 1)
	market=reindex(market)
	cluster=reindex(cluster)
	if (g0!="") {
		g=reindex(g)
		if (h0!="") {
			h=reindex(h)
			if (k0!="") {
				k=reindex(k)
			}
		}
	}

	// price and quantity
	p=endog[.,1]
	q=s:*msize

	// summation matrices, sums of quantities
	msumm=amsumf(obs,market)
	if (g0!="") {
		msummg=msumm:*amsumf(obs,g)
		nmsummg=msummg*J(rows(market),1,1)
		qg=msummg*q
		if (h0!="") {
			msummhg=msummg:*amsumf(obs,h)
			nmsummhg=msummhg*J(rows(market),1,1)
			qhg=msummhg*q
			if (k0!="") {
				msummkhg=msummhg:*amsumf(obs,k)
				nmsummkhg=msummkhg*J(rows(market),1,1)
				qkhg=msummkhg*q
			}
		}
	}

	// log market shares, and outside good's share
	lns=ln(s)
	lns[select(obs,rowmissing(lns))]=min(lns):*(select(obs,rowmissing(lns)):!=0)		// treat missing values
	s0=1:-(msumm*s)
	lnss0=lns:-ln(s0)
	d0=J(rows(market),1,1):/msize

	// treat missing values
	for (i=1; i<=cols(endog); i++) {
		endog[select(obs,rowmissing(endog[.,i])),i]=min(endog[.,i]):*(select(obs,rowmissing(endog[.,i])):!=0)
	}
	for (i=1; i<=cols(xd0); i++) {
		xd0[select(obs,rowmissing(xd0[.,i])),i]=min(xd0[.,i]):*(select(obs,rowmissing(xd0[.,i])):!=0)
	}
	for (i=1; i<=cols(zd00); i++) {
		zd00[select(obs,rowmissing(zd00[.,i])),i]=min(zd00[.,i]):*(select(obs,rowmissing(zd00[.,i])):!=0)
	}

	// linear regressors
	xd=endog,xd0

	// instruments
	zd=zd00,xd0
	
	// initial weighting matrix
	wd=invsym(zd'*zd)

	// linear IV estimator matrix
	pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'
	pxdz0=invsym(xd0'*xd0)*xd0'

	// updating weigthing matrices and projector matrices
	wd=wd(xd,zd,pxdz,lnss0,robust,cluster)
	pxdz=invsym(xd'*zd*wd*zd'*xd)*xd'*zd*wd*zd'

	// parameter vector (row vector params0): first element: alpha (negative of the coefficient on price), subsequent elements: nest sigmas
	params0=pxdz*lnss0
	params0=params0[1..cols(endog)]'
	params0[1,1]=-params0[1,1]

	// parameters
	alpha=J(rows(market),1,abs(params0[1,1]))											// alpha: negative of coefficient on price in the mean utility
	if (g0!="") {
		sigmag=J(rows(market),1,params0[1,2])											// sigma of nest
		sigmag=(0.0000002*(sigmag:<0)) :+ sigmag:*(sigmag:>=0)
		sigmag=(.9*(sigmag:>=1)) :+ sigmag:*(sigmag:<1)
		if (h0!="") {
			sigmah=J(rows(market),1,params0[1,3])										// sigma of subnest
			sigmah=(0.0000002*(sigmah:<0)) :+ sigmah:*(sigmah:>=0)
			sigmah=(.9*(sigmah:>=1)) :+ sigmah:*(sigmah:<1)
			sigmah=(sigmag:*(sigmah:<sigmag)) :+ sigmah:*(sigmah:>=sigmag)
			if (k0!="") {
				sigmak=J(rows(market),1,params0[1,4])									// sigma of sub-subnest
				sigmak=(0.0000002*(sigmak:<0)) :+ sigmak:*(sigmak:>=0)
				sigmak=(.9*(sigmak:>=1)) :+ sigmak:*(sigmak:<1)
				sigmak=(sigmah:*(sigmak:<sigmah)) :+ sigmak:*(sigmak:>=sigmah)
			}
		}
	}

	// I. predicted price (this reduced form price prediction is the preferred solution of Reynaert and Verboven [Improving the Performance of Random Coefficients Demand Models: the Role of Optimal Instruments, Journal of Econometrics, 2014 (April 2012), 179(1), 83-98.])
	p=endog[.,1]
	xpr=zpr00,xd0
	pxpxp=invsym(xpr'*xpr)*xpr'
	p_hat=xpr*(pxpxp*p)

	// predicted mean utilities (assuming ksi=0, where ksi is the error term of the demand equation)
	// "observed" mean utility without the price component
	lnss01=lnss0:+(alpha:*p)
	if (g0!="") {
		lnss01=lnss01:-(sigmag:*endog[.,2])
		if (h0!="") {
			lnss01=lnss01:-(sigmah:*endog[.,3])
			if (k0!="") {
				lnss01=lnss01:-(sigmak:*endog[.,4])
			}
		}
	}
	beta=pxdz0*lnss01																	// linear parameters (on rhs variables other than "endogenous" regressors)
 	beta=(-alpha[1,1])\beta																// linear parameters (on rhs variables other than the within share variables)
	xd_hat=p_hat,xd0																	// product characteristics with predicted price
	xb0_hat=xd0*beta[2..rows(beta)]														// predicted mean utilities without the price component

	// derivatives of mean utility wrt. sigma parameters (nested logit models only)
	if (cols(endog)>1) {
		ddelta=J(rows(market),cols(endog)-1,0)											// derivative of mean utilities wrt. sigma parameters
		epsilon=J(1,cols(endog)-1,0.0000001)											// difference in the parameter value for numerical derivatives
		for (mm=1; mm<=colmax(market); mm++) {											// calculations by market
			obsm=select(obs,market:==mm)
			onem=one[obsm]
			p_hatm=p_hat[obsm]
			xb0_hatm=xb0_hat[obsm]
			ksim=J(rows(obsm),1,0)
			alpham=alpha[obsm]
			// one-level nested logit model
			if (cols(endog)==2) {
				msummgm=msummg[obsm,obsm]
				// (numerical) derivative of predicted market shares wrt. sigma parameter
				for (ii=1; ii<=2; ii++) {
					// sigma parameter
					if (ii==1) {
						sigmagm=sigmag[obsm]:+J(rows(obsm),1,epsilon[1,1])
					}
					if (ii==2) {
						sigmagm=sigmag[obsm]:-J(rows(obsm),1,epsilon[1,1])
					}
					// market shares
					sm=shatm_nlogit(p_hatm,xb0_hatm,ksim,alpham,sigmagm,msummgm)
					// derivative
					if (ii==1) {
						dsdsigmam=sm
					}
					if (ii==2) {
						dsdsigmam=(dsdsigmam:-sm)/(2*epsilon[1,1])
					}
				}
				// predicted market shares
				sigmagm=sigmag[obsm]
				sm=shatm_nlogit(p_hatm,xb0_hatm,ksim,alpham,sigmagm,msummgm)
				sjgm=(sm):/(msummgm*sm)
				// derivative of predicted market shares wrt. mean utilities
				dsddelta=-sm*(sm)'
				dsddelta=dsddelta:-(sm*((sigmagm:/(onem:-sigmagm)):*sjgm)'):*msummgm
				dsddelta=dsddelta:+diag(sm:/(onem:-sigmagm))
				// filling up: derivative of mean utilities wrt. sigma parameters
				ddelta[obsm,1]=luinv(dsddelta)*dsdsigmam
			}
			// two-level nested logit model
			if (cols(endog)==3) {
				msummgm=msummg[obsm,obsm]
				msummhgm=msummhg[obsm,obsm]
				// (numerical) derivative of predicted market shares wrt. sigma parameters
				for (i=1; i<=cols(endog)-1; i++) {
					sigmagm=sigmag[obsm]
					sigmahm=sigmah[obsm]
					sigmas0m=sigmagm,sigmahm
					sigmasm=sigmas0m
					for (ii=1; ii<=2; ii++) {
						// sigma parameters
						if (ii==1) {
							sigmasm[.,i]=sigmas0m[.,i]:+J(rows(obsm),1,epsilon[1,i])
						}
						if (ii==2) {
							sigmasm[.,i]=sigmas0m[.,i]:-J(rows(obsm),1,epsilon[1,i])
						}
						sigmagm=sigmasm[.,1]
						sigmahm=sigmasm[.,2]
						// market shares
						sm=shatm_nlogit2(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,msummgm,msummhgm)
						// derivative
						if (ii==1) {
							dsdsigmam=sm
						}
						if (ii==2) {
							dsdsigmam=(dsdsigmam:-sm)/(2*epsilon[1,i])
						}
					}
					// predicted market shares
					sigmagm=sigmas0m[.,1]
					sigmahm=sigmas0m[.,2]
					sm=shatm_nlogit2(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,msummgm,msummhgm)
					sjgm=(sm):/(msummgm*sm)
					sjhm=(sm):/(msummhgm*sm)
					// derivative of predicted market shares wrt. mean utilities
					dsddelta=-sm*(sm)'
					dsddelta=dsddelta:-(sm*((sigmagm:/(onem:-sigmagm)):*sjgm)'):*msummgm
					dsddelta=dsddelta:-(sm*(( (onem:/(onem:-sigmahm)):-(onem:/(onem:-sigmagm)) ):*sjhm)'):*msummhgm
					dsddelta=dsddelta:+diag(sm:/(onem:-sigmahm))
					// filling up: derivative of mean utilities wrt. sigma parameters
					ddelta[obsm,i]=luinv(dsddelta)*dsdsigmam
				}
			}
			// three-level nested logit model
			if (cols(endog)==4) {
				msummgm=msummg[obsm,obsm]
				msummhgm=msummhg[obsm,obsm]
				msummkhgm=msummkhg[obsm,obsm]
				// (numerical) derivative of predicted market shares wrt. sigma parameters
				for (i=1; i<=cols(endog)-1; i++) {
					sigmagm=sigmag[obsm]
					sigmahm=sigmah[obsm]
					sigmakm=sigmak[obsm]
					sigmas0m=sigmagm,sigmahm,sigmakm
					sigmasm=sigmas0m
					for (ii=1; ii<=2; ii++) {
						// sigma parameters
						if (ii==1) {
							sigmasm[.,i]=sigmas0m[.,i]:+J(rows(obsm),1,epsilon[1,i])
						}
						if (ii==2) {
							sigmasm[.,i]=sigmas0m[.,i]:-J(rows(obsm),1,epsilon[1,i])
						}
						sigmagm=sigmasm[.,1]
						sigmahm=sigmasm[.,2]
						sigmakm=sigmasm[.,3]
						// market shares
						sm=shatm_nlogit3(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,sigmakm,msummgm,msummhgm,msummkhgm)
						// derivative
						if (ii==1) {
							dsdsigmam=sm
						}
						if (ii==2) {
							dsdsigmam=(dsdsigmam:-sm)/(2*epsilon[1,i])
						}
					}
					// predicted market shares
					sigmagm=sigmas0m[.,1]
					sigmahm=sigmas0m[.,2]
					sigmakm=sigmas0m[.,3]
					sm=shatm_nlogit3(p_hatm,xb0_hatm,ksim,alpham,sigmagm,sigmahm,sigmakm,msummgm,msummhgm,msummkhgm)
					sjgm=(sm):/(msummgm*sm)
					sjhm=(sm):/(msummhgm*sm)
					sjkm=(sm):/(msummkhgm*sm)
					// derivative of predicted market shares wrt. mean utilities
					dsddelta=-sm*(sm)'
					dsddelta=dsddelta:-(sm*((sigmagm:/(onem:-sigmagm)):*sjgm)'):*msummgm
					dsddelta=dsddelta:-(sm*(( (onem:/(onem:-sigmahm)):-(onem:/(onem:-sigmagm)) ):*sjhm)'):*msummhgm
					dsddelta=dsddelta:-(sm*(( (onem:/(onem:-sigmakm)):-(onem:/(onem:-sigmahm)) ):*sjkm)'):*msummkhgm
					dsddelta=dsddelta:+diag(sm:/(onem:-sigmakm))
					// filling up: derivative of mean utilities wrt. sigma parameters
					ddelta[obsm,i]=luinv(dsddelta)*dsdsigmam
				}
			}
		}
		for (i=1; i<=cols(endog)-1; i++) {
			ddelta[select(obs,rowmissing(ddelta[.,i])),i]=0:*(select(obs,rowmissing(ddelta[.,i])):!=0)	// treat missing values
		}
	}

	// II. conditional expectation of the derivative of the demand error term (ksi) wrt. sigma parameters
	dxb=xd_hat[.,2..cols(xd_hat)]*(pxdz0*ddelta)
	dksi=ddelta-dxb

	// exporting results into Stata
	if (g0!="") {
		stata("capture drop __optiksg")
		st_store(., st_addvar("double", "__optiksg"),touse, dksi[.,1])
		if (h0!="") {
			stata("capture drop __optiksh")
			st_store(., st_addvar("double", "__optiksh"),touse, dksi[.,2])
			if (k0!="") {
				stata("capture drop __optiksk")
				st_store(., st_addvar("double", "__optiksk"),touse, dksi[.,3])
			}
		}
	}
	stata("capture drop __optika*")
	st_store(., st_addvar("double", "__optika"),touse, p_hat)

}	// end of opti_nlogit function
mata mlib add lrcl opti_nlogit()


end
