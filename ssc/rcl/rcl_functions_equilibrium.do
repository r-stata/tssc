
******************************************
* Mata funcitons: equilibrium calculations
******************************************

mata:

mata clear


// equilibrium: random coefficient logit model (all markets)
// combining objective I. and II. based optimizations
pointer matrix equilibrium_blp(real colvector p_start,
								real colvector market,
								real colvector firm,
								real matrix xd0,
								real colvector ksi,
								real colvector mc,
								real colvector vat,
								real matrix rc,
								real colvector msize,
								real colvector xb,
								real matrix simdraws,
								real rowvector params,
								real colvector beta,
								real scalar _is_rc_on_p,
								string scalar nodisplay0)
{

	timer_clear(2)
	timer_on(2)
	
	// declarations
	
	// index of observations
	obs=runningsum(J(rows(market),1,1))

	// convergence error tolerance
	lim_foc=0.027
	
	// first try of equilibrium calculations
	timer_clear(3)
	timer_on(3)
	rseed(1)
	eq_data=equilibrium_blp_inner(p_start,market,firm,xd0,ksi,mc,vat,rc,msize,xb,simdraws,params,beta,_is_rc_on_p,nodisplay0)
	timer_off(3)
	timer=timer_value(3)
	p=eq_data[.,1]
	s=eq_data[.,2]
	foc=eq_data[.,3]
	e=eq_data[.,4]

	// second and third try (if necessary)
	pobs=(abs(foc):>lim_foc) :+ (p:<0)
	pobs=(pobs:!=0)
	if (sum(pobs)>0) {
		p_0=p
		s_0=s
		foc_0=foc
		e_0=e
		p_01=p
		s_01=s
		foc_01=foc
		e_01=e
		maf_01=max(abs(foc))
		npo_01=sum(pobs)
		npm_01=rows(uniqrows(select(market,pobs:==1)))
		if (nodisplay0=="") {
			" 1st try"+", probl. obs.: "+strofreal(sum(pobs))+"/"+strofreal(rows(market))+", probl. markets: "+strofreal(rows(uniqrows(select(market,pobs:==1))))+"/"+strofreal(rows(uniqrows(market)))+", max-abs-foc: "+strofreal(max(abs(foc)))+", ("+strofreal(timer[1,1])+"s)"
		}
		indent=rows(uniqrows(market))-rows(uniqrows(select(market,pobs:==1)))
		p_2=p:*(pobs:==0) :+ mean(select(p,pobs:==0)):*(pobs:==1)
		pmarkets=uniqrows(select(market,pobs:!=0))
		pmarkets=sort(pmarkets,1)
		pmarket=J(rows(market),1,0)
		for (ii=1; ii<=rows(pmarkets); ii++) {
			pmarket=pmarket :+ (market:==pmarkets[ii])
		}
		obs_p=select(obs,pmarket:==1)
		market_p0=select(market,pmarket:==1)
		firm_p=select(firm,pmarket:==1)
		xd0_p=select(xd0,pmarket:==1)
		ksi_p=select(ksi,pmarket:==1)
		mc_p=select(mc,pmarket:==1)
		vat_p=select(vat,pmarket:==1)
		rc_p=select(rc,pmarket:==1)
		msize_p=select(msize,pmarket:==1)
		xb_p=select(xb,pmarket:==1)
		p_2_p=select(p_2,pmarket:==1)
		market_p=reindex(market_p0)
		timer_clear(3)
		timer_on(3)
		rseed(1)
		eq_data_p=equilibrium_blp_inner(p_2_p,market_p,firm_p,xd0_p,ksi_p,mc_p,vat_p,rc_p,msize_p,xb_p,simdraws,params,beta,_is_rc_on_p,nodisplay0)
		timer_off(3)
		timer=timer_value(3)
		p_0[obs_p]=eq_data_p[.,1]
		s_0[obs_p]=eq_data_p[.,2]
		foc_0[obs_p]=eq_data_p[.,3]
		e_0[obs_p]=eq_data_p[.,4]
		p=p_0
		s=s_0
		foc=foc_0
		e=e_0
		pobs=(abs(foc):>lim_foc) :+ (p:<0)
		pobs=(pobs:!=0)
		if ( rows(uniqrows(select(market,pobs:==1)))<npm_01 | ( (rows(uniqrows(select(market,pobs:==1)))==npm_01) & (max(abs(foc))<maf_01) ) ) {
			p_01=p_0
			s_01=s_0
			foc_01=foc_0
			e_01=e_0
			maf_01=max(abs(foc_01))
			npo_01=sum(sum(pobs))
			npm_01=rows(uniqrows(select(market,pobs:==1)))
		}
		if (nodisplay0=="") {
			indent*" " + " 2nd try"+", probl. obs.: "+strofreal(sum(pobs))+"/"+strofreal(rows(market))+", probl. markets: "+strofreal(rows(uniqrows(select(market,pobs:==1))))+"/"+strofreal(rows(uniqrows(market)))+", max-abs-foc: "+strofreal(max(abs(foc)))+", ("+strofreal(timer[1,1])+"s)"
		}
		indent=rows(uniqrows(market))-rows(uniqrows(select(market,pobs:==1)))
		if (sum(pobs)>0) {
			p_2=p:*(pobs:==0) :+ mean(select(p,pobs:==0)):*(pobs:==1)
			pmarkets=uniqrows(select(market,pobs:!=0))
			pmarkets=sort(pmarkets,1)
			pmarket=J(rows(market),1,0)
			for (ii=1; ii<=rows(pmarkets); ii++) {
				pmarket=pmarket :+ (market:==pmarkets[ii])
			}
			obs_p=select(obs,pmarket:==1)
			market_p0=select(market,pmarket:==1)
			firm_p=select(firm,pmarket:==1)
			xd0_p=select(xd0,pmarket:==1)
			ksi_p=select(ksi,pmarket:==1)
			mc_p=select(mc,pmarket:==1)
			vat_p=select(vat,pmarket:==1)
			rc_p=select(rc,pmarket:==1)
			msize_p=select(msize,pmarket:==1)
			xb_p=select(xb,pmarket:==1)
			p_2_p=select(p_2,pmarket:==1)
			market_p=reindex(market_p0)
			timer_clear(3)
			timer_on(3)
			rseed(1)
			eq_data_p=equilibrium_blp_inner(p_2_p,market_p,firm_p,xd0_p,ksi_p,mc_p,vat_p,rc_p,msize_p,xb_p,simdraws,params,beta,_is_rc_on_p,nodisplay0)
			timer_off(3)
			timer=timer_value(3)
			p_0[obs_p]=eq_data_p[.,1]
			s_0[obs_p]=eq_data_p[.,2]
			foc_0[obs_p]=eq_data_p[.,3]
			e_0[obs_p]=eq_data_p[.,4]
			p=p_0
			s=s_0
			foc=foc_0
			e=e_0
			pobs=(abs(foc):>lim_foc) :+ (p:<0)
			pobs=(pobs:!=0)
			if ( rows(uniqrows(select(market,pobs:==1)))<npm_01 | ( (rows(uniqrows(select(market,pobs:==1)))==npm_01) & (max(abs(foc))<maf_01) ) ) {
				p_01=p_0
				s_01=s_0
				foc_01=foc_0
				e_01=e_0
				maf_01=max(abs(foc_01))
				npo_01=sum(sum(pobs))
				npm_01=rows(uniqrows(select(market,pobs:==1)))
			}
			if (nodisplay0=="") {
				indent*" " + " 3rd try"+", probl. obs.: "+strofreal(sum(pobs))+"/"+strofreal(rows(market))+", probl. markets: "+strofreal(rows(uniqrows(select(market,pobs:==1))))+"/"+strofreal(rows(uniqrows(market)))+", max-abs-foc: "+strofreal(max(abs(foc)))+", ("+strofreal(timer[1,1])+"s)"
			}
		}
		p=p_01
		s=s_01
		foc=foc_01
		e=e_01
	}
	eq_data=p,s,foc,e
	timer_off(2)
	timer=timer_value(2)
	if (nodisplay0=="") {
		"(rcl equilibrium)"+", probl. obs.: "+strofreal(sum(pobs))+"/"+strofreal(rows(market))+", probl. markets: "+strofreal(rows(uniqrows(select(market,pobs:==1))))+"/"+strofreal(rows(uniqrows(market)))+", max-abs-foc: "+strofreal(max(abs(foc)))+", ("+strofreal(timer[1,1])+"s)"
	}
	
	return(eq_data)

}	// end of equilibrium_blp function
mata mlib add lrcl equilibrium_blp()


// equilibrium: random coefficient logit model ("first try", all markets)
// combining objective I. and II. based optimizations
pointer matrix equilibrium_blp_inner(real colvector p_start,
								real colvector market,
								real colvector firm,
								real matrix xd0,
								real colvector ksi,
								real colvector mc,
								real colvector vat,
								real matrix rc,
								real colvector msize,
								real colvector xb,
								real matrix simdraws,
								real rowvector params,
								real colvector beta,
								real scalar _is_rc_on_p,
								string scalar nodisplay0)
{

	// declarations
	real colvector p1,s1,foc,e
	real matrix eq_data

	// index of observations
	obs1=runningsum(J(rows(market),1,1))

	// prices, shares, first order conditions
	p1=J(rows(market),1,.)
	s1=J(rows(market),1,.)
	foc=J(rows(market),1,.)
	e=J(rows(market),1,.)

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets
	
		if (nodisplay0=="") {
			printf("|")
			displayflush()
		}

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p_start,market:==m)
		xd0m=select(xd0,market:==m)
		xbm=select(xb,market:==m)
		ksim=select(ksi,market:==m)
		rcm=select(rc,market:==m)
		vatm=select(vat,market:==m)
		obsm=select(obs1,market:==m)
		mcm=select(mc,market:==m)
		focm=J(rows(marketm),1,.)
		em=J(rows(marketm),1,.)

		// price equilibrium
		rseed(1)
		eq_datam=equilibrium_blp_innerm(pm,marketm,firmm,xd0m,ksim,mcm,vatm,rcm,msizem,xbm,simdraws,params,beta,focm,em,_is_rc_on_p)
		pm1=eq_datam[.,1]
		sm1=eq_datam[.,2]
		focm=eq_datam[.,3]
		em=eq_datam[.,4]
		p1[obsm]=eq_datam[.,1]
		s1[obsm]=eq_datam[.,2]
		foc[obsm]=eq_datam[.,3]
		e[obsm]=eq_datam[.,4]
		//m,mean(100*pm1:/pm:-100),min(pm1),max(abs(focm)),max(abs(em))

	}	// end of m (markets) loop
	
	eq_data=p1,s1,foc,e
	
	return(eq_data)

}			// end of equilibrium_blp_inner function
mata mlib add lrcl equilibrium_blp_inner()

// equilibrium: random coefficient logit model (one market)
// combining objective I. and II. based optimizations
pointer matrix equilibrium_blp_innerm(real colvector pm_start,
								real colvector marketm,
								real colvector firmm,
								real matrix xd0m,
								real colvector ksim,
								real colvector mcm,
								real colvector vatm,
								real matrix rcm,
								real colvector msizem,
								real colvector xbm,
								real matrix simdraws,
								real rowvector params,
								real colvector beta,
								real rowvector focm,
								real rowvector em,
								real scalar _is_rc_on_p)
{

	// declarations
	external real colvector focm,em
	real matrix pm0_logit,eq_datam,rcm1
	real colvector i,obsmm,firm1m,edelta_logitm,sm0_logit,alpham,pm0,deltam,shatim,mum,sm0
	real scalar ff

	// matrices for summations
	productm=runningsum(J(rows(marketm),1,1))
	msumf=amsumf(productm,firmm)

	// identifier of single product firms on a given market
	firm1m=J(rows(firmm),1,0)
	obsmm=runningsum(J(rows(firmm),1,1))
	for (ff=colmin(firmm); ff<=colmax(firmm); ff++) {
		i=(firmm:==ff)
		if (sum(i[select(obsmm,i:==1),1])==1) {
			firm1m=firm1m:+i
		}
	}
	
	// starting price vector
	pm0=(mcm:*(1:+vatm))
	
	// simple logit price equilibrium
	if (hasmissing(pm_start)==1) {
		edelta_logitm=exp(xbm:+ksim)													// (exp of) mean utilities
		sm0_logit=edelta_logitm:/(1:+colsum(edelta_logitm))								// predicted shares
		alpham=J(rows(ksim),1,-beta[1,1])
		rseed(1)
		pm0_logit=equilibrium_logit(sm0_logit,pm0,msizem,vatm,alpham,xbm,ksim,mcm,msumf)
		pm0_logit=pm0_logit[.,1]
	}

	// random coefficient logit price equilibrium
	if (hasmissing(pm_start)==0) {
		pm0=pm_start
	}
	if (hasmissing(pm_start)==1) {
		if (hasmissing(pm0_logit)==0) {
			pm0=pm0_logit
		}
	}
	datam=xd0m,rcm,firmm,firm1m,mcm,ksim,vatm,focm,em									// data matrix
		rseed(1)
		pm0=eq_pp_rclm(pm0,datam,simdraws,beta,params,msumf,_is_rc_on_p)
		if (_is_rc_on_p==1) {
			datam[.,rows(beta)]=pm0														// updating random coefficient variables (replacing the first column with prices of the current iteration)
		}
		if (max(abs(em:*em))>0.000001) {
			rseed(1)
			pm0=eq_pp_rclm(pm0,datam,simdraws,beta,params,msumf,_is_rc_on_p)
			if (_is_rc_on_p==1) {
				datam[.,rows(beta)]=pm0													// updating random coefficient variables (replacing the first column with prices of the current iteration)
			}
			if (max(abs(em:*em))>0.000001) {
				pm0_pp_rcl=pm0
				rseed(1)
				pm0=eq_foc_rclm(pm0,datam,simdraws,beta,params,msumf,_is_rc_on_p)
				if (_is_rc_on_p==1) {
					datam[.,rows(beta)]=pm0												// updating random coefficient variables (replacing the first column with prices of the current iteration)
				}
				if (min(pm0)<=0) {
					pm0=pm0_pp_rcl
				}
				rseed(1)
				pm0=eq_pp_rclm(pm0,datam,simdraws,beta,params,msumf,_is_rc_on_p)
				if (_is_rc_on_p==1) {
					datam[.,rows(beta)]=pm0												// updating random coefficient variables (replacing the first column with prices of the current iteration)
				}
				if (max(abs(em:*em))>0.000001) {
					rseed(1)
					pm0=eq_pp_rclm(pm0,datam,simdraws,beta,params,msumf,_is_rc_on_p)
					if (_is_rc_on_p==1) {
						datam[.,rows(beta)]=pm0											// updating random coefficient variables (replacing the first column with prices of the current iteration)
					}
					pm0_pp=pm0
					focm_pp=datam[.,rows(beta)+cols(params)+5]
					em_pp=datam[.,rows(beta)+cols(params)+6]
					rseed(1)
					pm0_fp=eq_fp_rclm(pm0,datam,simdraws,beta,params,msumf,_is_rc_on_p)
					focm_fp=datam[.,rows(beta)+cols(params)+5]
					if (min(pm0_fp)>0 & hasmissing(pm0_fp)==0 & hasmissing(focm_fp)==0 & max(abs(focm_fp))<max(abs(focm_pp))) {
						pm0=pm0_fp
					}
					if (min(pm0_fp)<=0 | hasmissing(pm0_fp)==1 | hasmissing(focm_fp)==1 | max(abs(focm_fp))>=max(abs(focm_pp))) {
						pm0=pm0_pp
						datam[.,rows(beta)+cols(params)+5]=focm_pp
						datam[.,rows(beta)+cols(params)+6]=em_pp
					}
				}
			}
		}
	
	// first order conditions, prediction errors
	focm=datam[.,rows(beta)+cols(params)+5]
	em=datam[.,rows(beta)+cols(params)+6]

	// shares given prices
	if (_is_rc_on_p==1) {											// if there is random coefficient on price
		if (cols(rcm)==1) {
			rcm1=pm0												// updating random coefficient variables (replacing the first column with prices of the current iteration)
		}
		if (cols(rcm)>1) {
			rcm1=pm0,rcm[.,2..cols(rcm)]							// updating random coefficient variables (replacing the first column with prices of the current iteration)
		}
	}
	if (_is_rc_on_p==0) {											// if there is no random coefficient on price (no update)
		rcm1=rcm
	}
	mum=rcm1*((params'):*simdraws[1..rows(simdraws)-1,.])			// matrix of observed consumer heterogeneity (separate column for each consumer)
	deltam=(pm0,xd0m)*(beta):+ksim									// mean utilities
	shatim=exp(deltam:+mum)											// predicted individual choice probabilities
		shatim=shatim:/(1:+colsum(shatim))
	sm0=shatim*simdraws[rows(simdraws),.]'							// predicted shares

	eq_datam=pm0,sm0,focm,em
	
	return(eq_datam)

}			// end of equilibrium_blp_innerm function
mata mlib add lrcl equilibrium_blp_innerm()


// random coefficients logit model equilibrium for one market: fixed point algorithm
pointer vector eq_fp_rclm(real colvector pm0,
							real matrix datam,
							real matrix simdraws,
							real colvector beta,
							real rowvector params,
							real matrix msumf,
							real scalar _is_rc_on_p)
{
	// declarations
	real matrix dif
	real scalar i,conv,error

	// variables
	pm00=pm0
	xd0m=datam[.,1..rows(beta)-1]
	rcm=datam[.,rows(beta)..rows(beta)+cols(params)-1]
	firmm=datam[.,rows(beta)+cols(params)]
	firm1m=datam[.,rows(beta)+cols(params)+1]
	mcm=datam[.,rows(beta)+cols(params)+2]
	ksim=datam[.,rows(beta)+cols(params)+3]
	vatm=datam[.,rows(beta)+cols(params)+4]
	focm=datam[.,rows(beta)+cols(params)+5]
	em=datam[.,rows(beta)+cols(params)+6]
	
	// parameters
	sigmas=params[1,1..cols(rcm)]'													// vector of random coefficient parameters
	alpha=-beta[1,1]																// (negative of) coefficient on price
	if (_is_rc_on_p==1) {
		alphai=alpha:-(params[1,1]*simdraws[1,.])									// individual price coefficients (if there is random coefficient on price)
	}
	if (_is_rc_on_p==0) {
		alphai=alpha:*J(1,cols(simdraws),1)											// individual price coefficients (if there is no random coefficient on price)
	}

	// initial shares and prices
	if (_is_rc_on_p==1) {
		rcm[.,1]=pm0																// updating random coefficient variables (replacing the first column with prices of the current iteration)
	}
	mum=rcm*((sigmas):*simdraws[1..rows(simdraws)-1,.])								// matrix of observed consumer heterogeneity (separate column for each consumer)
	deltam=(pm0,xd0m)*(beta):+ksim													// mean utilities
	shatim=exp(deltam:+mum)															// predicted individual choice probabilities
	shatim=shatim:/(1:+colsum(shatim))
	shatm=shatim*simdraws[rows(simdraws),.]'										// predicted market shares
	shatim0=shatim
	shatm0=shatm
	pm0=pm00

	// solving for the new equilibrium shares and prices
	i=0
	dif=10000
	dif0=dif
	tol=0.001
	tol=0.00001
	maxiter=15000
	maxiter=5*rows(pm0)
	damp=0.001
	damp_switch=1
	ccf=0
	while (dif>tol & i<maxiter) {
		i=i+1

		// demand prediction given initial prices
		if (_is_rc_on_p==1) {
			rcm[.,1]=pm0																// updating random coefficient variables (replacing the first column with prices of the current iteration)
		}
		mum=rcm*((sigmas):*simdraws[1..rows(simdraws)-1,.])								// matrix of observed consumer heterogeneity (separate column for each consumer)
		deltam=(pm0,xd0m)*(beta):+ksim													// mean utilities
		dm=(deltam:+mum)
		dm=dm :- (dm:*(dm:>709)) :+ (709*(dm:>709))										// treating numerical overflow (the argument of the exp function cannot be larger than 709)
		shatim1=exp(dm)																	// predicted individual choice probabilities
		cf=(shatim1:>=8e307):/(1:+10*colsum(shatim1:>=8e307))							// correction factor to treat numerical overflow
		ccf=ccf+sum(shatim1:>=8e307)
		cf=cf:+(shatim1:<=8e307)
		shatim1=shatim1:*cf
		cf=(shatim1:>=7e307):/(1:+10*colsum(shatim1:>=7e307))							// correction factor to treat numerical overflow
		ccf=ccf+sum(shatim1:>=7e307)
		cf=cf:+(shatim1:<=7e307)
		shatim1=shatim1:*cf
		shatim1=shatim1:/(1:+colsum(shatim1))
		shatm1=shatim1*simdraws[rows(simdraws),.]'										// predicted market shares
		if ((1-colsum(shatm1))>0 & damp_switch==0) {									// updating initial shares
			shatim0=shatim1
			shatm0=shatm1
		}
		if ((1-colsum(shatm1))<=0 | damp_switch==1) {									// updating initial shares (avoiding exploding outside good share)
			shatim0=(1-damp)*shatim0 :+ damp*shatim1
			shatm0=(1-damp)*shatm0 :+ damp*shatm1
			if ((1-colsum(shatm1))>0) {
				damp=damp+1/(rows(shatm)*10)
				if (damp>1) {
					damp=1
				}
			}
			if ( ((1-colsum(shatm1))<0 | dif>dif0) & damp_switch==1 & damp>0.01) {
				damp=damp/2
			}
			damp_switch=1															// switch to dampening
		}
		dif0=dif

		// auxiliary variables
		ashatim=alphai:*shatim0
		sashatim=(ashatim)*simdraws[rows(simdraws),.]'
		dsdp=(ashatim:*(simdraws[rows(simdraws),.]))*(shatim0') :- diag(sashatim)	// matrix of price derivatives
		dsdpmsumf=dsdp':*msumf
			// inverse of the block-diagonal matrix dsdpmsumf (inverting by blocks)
			idsdpmsumf=J(rows(dsdpmsumf),rows(dsdpmsumf),0)
			for (ff=colmin(firmm); ff<=colmax(firmm); ff++) {
				sf=sum(firmm:==ff)
				if (sf>1) {															// inverse of non-scalar blocks
					idsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)]=qrinv(dsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)])
				}
			}
			idsdpmsumf=idsdpmsumf :+ diag(firm1m:/diagonal(dsdpmsumf))				// inverse of scalar blocks

		// vector of implied first order conditions
		focm=(shatm0:/(1:+vatm)) :+ ( dsdpmsumf*((pm0:/(1:+vatm)):-mcm) )
		datam[.,rows(beta)+cols(params)+5]=focm

		// price prediction given demand prediction: marginal cost plus updated margin (implied by initial prices and updated shares)
		mrkpm=(-idsdpmsumf)*(shatm0:/(1:+vatm))
		pm1=(mrkpm:+mcm):*(1:+vatm)
		datam[.,rows(beta)+cols(params)+6]=pm0:-pm1									// error of price prediction
		
		// objective
		dif=max(abs(focm))														// objective: maximum norm of the first order condition vector
		pm0=pm1																		// updating initial prices

		// price change
		dpm=colsum( 100*((pm1:-pm00):/pm00):*shatm )/colsum(shatm)
		//i,colsum(abs(focm:*shatm))/colsum(shatm),max(abs(focm)),dpm,colsum(shatm0),damp,damp_switch,ccf

	}	// end of i while loop (equilibrium fixed point)

	//i,colsum(abs(focm:*shatm))/colsum(shatm),max(abs(focm)),dpm,colsum(shatm0),damp,damp_switch,ccf,min(pm0)
	return(pm0)
	
}	// end of eq_fp_rclm function
mata mlib add lrcl eq_fp_rclm()


// random coefficients logit model for one market: minimizing the objective (II.)
// objective: squared normalized first order condition of price equilibrium
// the minimized objective corresponds to the price equilibrium
pointer vector eq_foc_rclm(real colvector pm0,
							real matrix datam,
							real matrix simdraws,
							real colvector beta,
							real rowvector params,
							real matrix msumf,
							real scalar _is_rc_on_p)
{
	// declarations
	real matrix dif
	real scalar i,conv,error
	rseed(1)
	pm0=pm0'
	Z=optimize_init()
	optimize_init_evaluator(Z, &obj_eq_foc_rclm())
	optimize_init_evaluatortype(Z, "v1")
	optimize_init_evaluatortype(Z, "v0")
	optimize_init_verbose(Z, 0)
	optimize_init_tracelevel(Z, "none")
	optimize_init_which(Z, "min")
	optimize_init_technique(Z, "bfgs")
	optimize_init_conv_maxiter(Z, 2000)
	optimize_init_params(Z, pm0)
	optimize_init_argument(Z, 1, datam)
	optimize_init_argument(Z, 2, simdraws)
	optimize_init_argument(Z, 3, beta)
	optimize_init_argument(Z, 4, params)
	optimize_init_argument(Z, 5, msumf)
	optimize_init_argument(Z, 6, _is_rc_on_p)
	optimize_init_conv_ignorenrtol(Z, "on")
	pm0=_optimize(Z)
	pm0=optimize_result_params(Z)
	pm0=pm0'
	dif=optimize_result_value(Z)
	i=optimize_result_iterations(Z)
	conv=optimize_result_converged(Z)
	error=optimize_result_errorcode(Z)
	return(pm0)
}	// end of eq_foc_rclm function
mata mlib add lrcl eq_foc_rclm()


// rcl objective to be minimized (II.): price equilibrium of the random coefficients logit model for one market
// objective: squared normalized first order condition of price equilibrium
void obj_eq_foc_rclm(real scalar todo,
					real rowvector pm0,
					real matrix datam,
					real matrix simdraws,
					real colvector beta,
					real rowvector params,
					real matrix msumf,
					real scalar _is_rc_on_p,
					real matrix dif,
					real matrix grad,
					real matrix H)
{

	// declarations
	real matrix mum,shatim,ashatim,sashatim,dsdp,dsdpmsumf,a2shatim,ds,dfocm
	real colvector deltam,shatm,mrkpm

	// data
	pm0=pm0'
	xd0m=datam[.,1..rows(beta)-1]
	rcm=datam[.,rows(beta)..rows(beta)+cols(params)-1]
	firmm=datam[.,rows(beta)+cols(params)]
	firm1m=datam[.,rows(beta)+cols(params)+1]
	mcm=datam[.,rows(beta)+cols(params)+2]
	ksim=datam[.,rows(beta)+cols(params)+3]
	vatm=datam[.,rows(beta)+cols(params)+4]
	focm=datam[.,rows(beta)+cols(params)+5]

	// demand prediction given initial prices
	if (_is_rc_on_p==1) {
		rcm[.,1]=pm0															// updating random coefficient variables (replacing the first column with prices of the current iteration)
	}
	mum=rcm*((params'):*simdraws[1..rows(simdraws)-1,.])						// matrix of observed consumer heterogeneity (separate column for each consumer)
	deltam=(pm0,xd0m)*(beta):+ksim												// mean utilities
	shatim=exp(deltam:+mum)														// predicted individual choice probabilities
		shatim=shatim:/(1:+colsum(shatim))
	shatm=shatim*simdraws[rows(simdraws),.]'									// predicted shares
	
	// price prediction given demand prediction
	alpha=-beta[1,1]															// (negative of) coefficient on price
	if (_is_rc_on_p==1) {
		alphai=alpha:-(params[1,1]*simdraws[1,.])								// individual price coefficients (if there is random coefficient on price)
	}
	if (_is_rc_on_p==0) {
		alphai=alpha:*J(1,cols(simdraws),1)										// individual price coefficients (if there is no random coefficient on price)
	}
	ashatim=alphai:*shatim
	sashatim=(ashatim)*simdraws[rows(simdraws),.]'
	dsdp=(ashatim:*(simdraws[rows(simdraws),.]))*(shatim') :- diag(sashatim)	// matrix of price derivatives
	dsdpmsumf=dsdp':*msumf
	mrkpm=(pm0:/(1:+vatm)):-mcm													// markup calculations (given prices and shares)
	focm=shatm:/(1:+vatm) :+ (dsdpmsumf*mrkpm)									// first order condition of optimal prices
	datam[.,rows(beta)+cols(params)+5]=focm
	focm=focm:/shatm															// normalization
	dif=focm:*focm/rows(focm)													// objective: squared errors of price prediction

	// gradient
	if (todo>=1) {
		alphai2=alphai:*alphai
		a2shatim=alphai2:*shatim
		dfocm=(dsdp:/(1:+vatm))
		dfocm=dfocm :+ (((dsdp:/(1:+vatm))):*msumf)
		ds=J(rows(dfocm),cols(dfocm),0)
		for (r=1; r<=cols(simdraws); r++) {
			ds=ds :+ simdraws[rows(simdraws),r]*2*(a2shatim[.,r]*(shatim[.,r]')):*(msumf*(shatim[.,r]:*mrkpm))
			ds=ds :- simdraws[rows(simdraws),r]*( (a2shatim[.,r]*((shatim[.,r]:*mrkpm)')):*msumf )
			ds=ds :- simdraws[rows(simdraws),r]*(diag(a2shatim[.,r])):*(msumf*(shatim[.,r]:*mrkpm))
			ds=ds :- simdraws[rows(simdraws),r]*(a2shatim[.,r]:*mrkpm)*(shatim[.,r]')
			ds=ds :+ simdraws[rows(simdraws),r]*diag(a2shatim[.,r]:*mrkpm)
		}
		dfocm=dfocm :+ ds
		dfocm=(dfocm:*shatm) :- ((focm:*shatm):*dsdp)
		dfocm=dfocm:/(shatm:*shatm)
		grad=2*focm:*dfocm
	}

	pm0=pm0'

}	// end of random coefficients logit price (foc based) objective pointer
mata mlib add lrcl obj_eq_foc_rclm()


// random coefficients logit model for one market: minimizing the objective (I.)
// objective: squared price prediction
// the minimized objective corresponds to the price equilibrium
pointer vector eq_pp_rclm(real colvector pm0,
							real matrix datam,
							real matrix simdraws,
							real colvector beta,
							real rowvector params,
							real matrix msumf,
							real scalar _is_rc_on_p)
{
	// declarations
	real matrix dif
	real scalar i,conv,error
	rseed(1)
	pm0=pm0'
	Z=optimize_init()
	optimize_init_evaluator(Z, &obj_eq_pp_rclm())
	optimize_init_evaluatortype(Z, "v1")
	optimize_init_verbose(Z, 0)
	optimize_init_tracelevel(Z, "none")
	optimize_init_which(Z, "min")
	optimize_init_technique(Z, "bfgs")
	optimize_init_conv_maxiter(Z, 2000)
	optimize_init_params(Z, pm0)
	optimize_init_argument(Z, 1, datam)
	optimize_init_argument(Z, 2, simdraws)
	optimize_init_argument(Z, 3, beta)
	optimize_init_argument(Z, 4, params)
	optimize_init_argument(Z, 5, msumf)
	optimize_init_argument(Z, 6, _is_rc_on_p)
	optimize_init_conv_ignorenrtol(Z, "on")
	pm0=_optimize(Z)
	pm0=optimize_result_params(Z)
	pm0=pm0'
	dif=optimize_result_value(Z)
	i=optimize_result_iterations(Z)
	conv=optimize_result_converged(Z)
	error=optimize_result_errorcode(Z)
	return(pm0)
}	// end of eq_pp_rclm function
mata mlib add lrcl eq_pp_rclm()


// rcl objective to be minimized (I.): price equilibrium of the random coefficients logit model for one market
// objective: squared price prediction
void obj_eq_pp_rclm(real scalar todo,
					real rowvector pm0,
					real matrix datam,
					real matrix simdraws,
					real colvector beta,
					real rowvector params,
					real matrix msumf,
					real scalar _is_rc_on_p,
					real matrix dif,
					real matrix grad,
					real matrix H)
{

	// declarations
	real matrix mum,shatim,ashatim,sashatim,dsdp,dsdpmsumf,idsdpmsumf,a2shatim,ds,dphatm,dem
	real colvector deltam,shatm,mrkpm,phatm

	// data
	pm0=pm0'
	xd0m=datam[.,1..rows(beta)-1]
	rcm=datam[.,rows(beta)..rows(beta)+cols(params)-1]
	firmm=datam[.,rows(beta)+cols(params)]
	firm1m=datam[.,rows(beta)+cols(params)+1]
	mcm=datam[.,rows(beta)+cols(params)+2]
	ksim=datam[.,rows(beta)+cols(params)+3]
	vatm=datam[.,rows(beta)+cols(params)+4]
	focm=datam[.,rows(beta)+cols(params)+5]
	em=datam[.,rows(beta)+cols(params)+6]

	// demand prediction given initial prices
	if (_is_rc_on_p==1) {
		rcm[.,1]=pm0															// updating random coefficient variables (replacing the first column with prices of the current iteration)
	}
	mum=rcm*((params'):*simdraws[1..rows(simdraws)-1,.])						// matrix of observed consumer heterogeneity (separate column for each consumer)
	deltam=(pm0,xd0m)*(beta):+ksim												// mean utilities
	shatim=exp(deltam:+mum)														// predicted individual choice probabilities
		shatim=shatim:/(1:+colsum(shatim))
	shatm=shatim*simdraws[rows(simdraws),.]'									// predicted shares
	
	// price prediction given demand prediction
	// auxiliary variables
	alpha=-beta[1,1]															// (negative of) coefficient on price
	if (_is_rc_on_p==1) {
		alphai=alpha:-(params[1,1]*simdraws[1,.])								// individual price coefficients (if there is random coefficient on price)
	}
	if (_is_rc_on_p==0) {
		alphai=alpha:*J(1,cols(simdraws),1)										// individual price coefficients (if there is no random coefficient on price)
	}
	ashatim=alphai:*shatim
	sashatim=(ashatim)*simdraws[rows(simdraws),.]'
	dsdp=(ashatim:*(simdraws[rows(simdraws),.]))*(shatim') :- diag(sashatim)	// matrix of price derivatives
	dsdpmsumf=dsdp':*msumf
			// inverse of the block-diagonal matrix dsdpmsumf (inverting by blocks)
			idsdpmsumf=J(rows(dsdpmsumf),rows(dsdpmsumf),0)
			for (ff=colmin(firmm); ff<=colmax(firmm); ff++) {
				sf=sum(firmm:==ff)
				if (sf>1) {														// inverse of non-scalar blocks
					idsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)]=qrinv(dsdpmsumf[select(runningsum(J(rows(firmm),1,1)),firmm:==ff),select(runningsum(J(rows(firmm),1,1)),firmm:==ff)])
				}
			}
			idsdpmsumf=idsdpmsumf :+ diag(firm1m:/diagonal(dsdpmsumf))			// inverse of scalar blocks
		mrkpm=(pm0:/(1:+vatm)):-mcm												// markup calculations (given prices and shares)
		focm=shatm:/(1:+vatm) :+ ((dsdpmsumf)*mrkpm)							// first order condition of optimal prices
		datam[.,rows(beta)+cols(params)+5]=focm
	mrkpm=(-idsdpmsumf)*(shatm:/(1:+vatm))										// markup (given intial prices)
	phatm=(mcm:+mrkpm):*(1:+vatm)												// price prediction (given intial prices)
	em=pm0:-phatm																// error of price prediction
	datam[.,rows(beta)+cols(params)+6]=em
	dif=em:*em/rows(pm0)														// objective: squared errors of price prediction

	// gradient
	if (todo>=1) {
		alphai2=alphai:*alphai
		a2shatim=alphai2:*shatim
		ds=J(rows(pm0),cols(pm0),0)
		for (r=1; r<=cols(simdraws); r++) {
			ds=ds :+ simdraws[rows(simdraws),r]*2*(a2shatim[.,r]*(shatim[.,r]')):*(msumf*(shatim[.,r]))
			ds=ds :- simdraws[rows(simdraws),r]*( (a2shatim[.,r]*((shatim[.,r])')):*msumf )
			ds=ds :- simdraws[rows(simdraws),r]*(diag(a2shatim[.,r])):*(msumf*(shatim[.,r]))
			ds=ds :- simdraws[rows(simdraws),r]*(a2shatim[.,r])*(shatim[.,r]')
			ds=ds :+ simdraws[rows(simdraws),r]*diag(a2shatim[.,r])
		}
		dphatm=-( -(((idsdpmsumf'*idsdpmsumf)*ds):*(shatm)) :+ (idsdpmsumf:*(dsdp)) )
		dem=diag(J(rows(pm0),1,1)) :- dphatm
		grad=2*em:*dem/rows(pm0)
		grad=2*em:*dem
	}

	pm0=pm0'

}	// end of random coefficients logit price (inversion based) objective pointer
mata mlib add lrcl obj_eq_pp_rclm()


// equilibrium: simple logit model (one market)
real matrix equilibrium_logit(real colvector sm00,
							real colvector pm00,
							real colvector msizem,
							real colvector vatm,
							real colvector alpham,
							real colvector xbm,
							real colvector ksim,
							real colvector mcm,
							real matrix msumf)
{

	// declarations
	real colvector s0m,sm1,qm,qfm,d0m,summa0m,pm1
	real matrix eq_datam
	real scalar i,dif,tol,maxiter
	
	// initial shares and prices
	sm0=sm00
	pm0=pm00
	d0m=J(rows(msizem),1,1):/msizem

	// solving for the equilibrium shares and prices
	i=0
	dif=1000
	tol=0.000000005
	maxiter=1000
	while (dif>tol & i<maxiter) {
		i=i+1

		// demand prediction given initial shares and prices
		s0m=(1-colsum(sm0))*J(rows(sm00),1,1)									// share of outside good
		sm1=(-alpham:*pm0):+(xbm):+(ksim):+(ln(s0m))
		sm1=exp(sm1)															// predicted shares given initial shares and prices
		sm0=sm1																	// updating initial shares

		// quantity variables
		qm=sm0:*msizem															// quantity
		qfm=msumf*qm															// firms' sum of quantities

		// price prediction given demand prediction: marginal cost plus updated margin (implied by initial prices and updated shares)
		summa0m=qfm:/((J(rows(sm00),1,1):-(d0m:*qfm)):*(alpham:*(1:+vatm)))
		pm1=mcm:+( (J(rows(sm00),1,1):/(alpham:*(1:+vatm))) :+(d0m:*summa0m) )
			pm1=pm1:*(1:+vatm)
		dif=colmax(abs(100*(pm1:-pm0):/pm0))									// percent change in prices relative to initial prices
		pm0=pm1																	// updating initial prices

	}	// end of i while loop (equilibrium fixed point)

	eq_datam=pm0,sm0
	return(eq_datam)
	
}	// end of equilibrium_logit function
mata mlib add lrcl equilibrium_logit()

/* price equilibrium of the simple logit model for one market: pointer calculating the objective to be minimized */
/* objective: squared normalized first order condition of price equilibrium */
/* the minimized objective corresponds to the post-merger price equilibrium */
/* INPUTS
	pm0		- row vector of initial prices (1xJ)
	datam: matrix of variables (of J row length): 
		xbm		- colvector of the part of mean utility function related to the observed exogenous characteristics
		ksim	- vector of unobserved product characteristics
		mcm		- vector of marginal costs
		vatm	- vector with VAT rate (vector of 0s if not applicable)
		sm		- comformable real vector with arbitrary values: the function will fill it up with the implied market shares
		focm	- comformable real vector with arbitrary values: the function will fill it up with the values of the calculated first order conditions
		datam=xbm,ksim,mcm,vatm,sm,focm	(only datam has to be provided, the names of its components don't matter)
	alpha	- scalar, the negative of the coefficient on price
	msumf	- product ownership matrix (JxJ): (i,j) element is 1 if product i is produced by the same firm as product j, 0 otherwise
   OUTPUT
		pm0		- row vector of prices (1xJ)
		the last two columns of datam are modified: they are filled up with the implied market shares and evaluated first order conditions, respectively
*/
void obj_eq_logitm(todo,pm0,datam,alpha,msumf,dif,grad,H)
{

	// data
	pm00=pm0'
	xbm=datam[.,1]
	ksim=datam[.,2]
	mcm=datam[.,3]
	vatm=datam[.,4]

	// demand prediction given initial prices
	deltam=(-alpha:*pm00):+(xbm):+(ksim)						// mean utilities
	shatm=exp(deltam)											// predicted shares
		shatm=shatm/(1+colsum(shatm))
		datam[.,5]=shatm

	// price prediction given demand prediction
	dsdp=alpha*( shatm*(shatm'):-diag(shatm) )					// matrix of price derivatives
	mrkpm0=(pm00:/(1:+vatm)):-mcm								// markup
	foc=shatm:/(1:+vatm) :+ ((dsdp':*msumf)*mrkpm0)
		datam[.,6]=foc
	foc=foc:/shatm
	dif=foc:*foc/rows(foc)										// objective: squared normalized first order condition

	// gradient
	if (todo>=1) {
		dfoc=(dsdp:/(1:+vatm))
		dfoc=dfoc :+ (((dsdp:/(1:+vatm))):*msumf)
		dfoc=dfoc :+ (2*(alpha^2))*((msumf*(shatm:*mrkpm0)):*shatm)*(shatm')
		dfoc=dfoc :- (alpha^2)*((shatm*((mrkpm0:*shatm)')):*msumf)
		dfoc=dfoc :- (alpha^2)*diag((msumf*(shatm:*mrkpm0))*(shatm'))
		dfoc=dfoc :- (alpha^2)*((shatm:*mrkpm0)*(shatm'))
		dfoc=dfoc :+ (alpha^2)*diag(shatm:*mrkpm0)
		dfoc=(dfoc:*shatm) :- ((foc:*shatm):*dsdp)
		dfoc=dfoc:/(shatm:*shatm)
		grad=2*foc:*dfoc
	}
	
}	// end of simple logit price objective pointer
mata mlib add lrcl obj_eq_logitm()

/* price equilibrium of the simple logit model for one market: function minimizing the objective */
/* objective: squared normalized first order condition of price equilibrium */
/* the minimized objective corresponds to the post-merger price equilibrium */
/* INPUTS
	pm0		- column vector of initial prices (Jx1)
	datam: matrix of variables (of J row length): 
		xbm		- colvector of the part of mean utility function related to the observed exogenous characteristics
		ksim	- vector of unobserved product characteristics
		mcm		- vector of marginal costs
		vatm	- vector with VAT rate (vector of 0s if not applicable)
		sm		- comformable real vector with arbitrary values: the function will fill it up with the implied market shares
		focm	- comformable real vector with arbitrary values: the function will fill it up with the values of the calculated first order conditions
		datam=xbm,ksim,mcm,vatm,sm,focm	(only datam has to be provided, the names of its components don't matter)
	alpha	- scalar, the negative of the coefficient on price
	msumf	- product ownership matrix (JxJ): (i,j) element is 1 if product i is produced by the same firm as product j, 0 otherwise
	m		- index of the market, real scalar, can be any number, it does not affect the results of the calculations
   OUTPUT
		pm0		- column vector of equilibrium prices (Jx1)
		the last two columns of datam are modified: they are filled up with the implied market shares and evaluated first order conditions, respectively
*/
pointer vector eq_logitm(pm0,datam,alpha,msumf,m)
{
	rseed(1)
	pm00=pm0
	pm0=pm0'
	Z=optimize_init()
	optimize_init_evaluator(Z, &obj_eq_logitm())
	optimize_init_evaluatortype(Z, "v1")
	optimize_init_verbose(Z, 0)
	optimize_init_tracelevel(Z, "none")
	optimize_init_which(Z, "min")
	optimize_init_technique(Z, "bfgs")
	optimize_init_conv_maxiter(Z, 2000)
	optimize_init_params(Z, pm0)
	optimize_init_argument(Z, 1, datam)
	optimize_init_argument(Z, 2, alpha)
	optimize_init_argument(Z, 3, msumf)
	optimize_init_conv_ignorenrtol(Z, "on")
	pm0=_optimize(Z)
	pm0=optimize_result_params(Z)
	pm0=pm0'
	dif=optimize_result_value(Z)
	i=optimize_result_iterations(Z)
	conv=optimize_result_converged(Z)
	error=optimize_result_errorcode(Z)
	sm=datam[.,5]
	focm=datam[.,6]
	dpm=mean(pm0)/mean(pm00)
	return(pm0)
}
mata mlib add lrcl eq_logitm()

end
