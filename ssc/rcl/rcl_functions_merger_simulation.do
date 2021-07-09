
************************************
* Mata funcitons: merger simulation
************************************

mata:

mata clear


// BLP merger simulation
void merger_simulation_blp(
	string scalar b0,
	string scalar market0,
	string scalar firm0,
	string scalar firm_post0,
	string scalar p0,
	string scalar share0,
	string scalar iexog0,
	string scalar xb00,
	string scalar ksi0,
	string scalar delta0,
	string scalar rc0,
	string scalar demog_mean0,
	string scalar demog_cov0,
	string scalar demog_xvars0,
	string scalar msize0,
	string scalar mc0,
	string scalar vat0,
	string scalar segment0,
	string scalar integrationmethod,
	string scalar accuracy,
	string scalar draws,
	string scalar onlymc0,
	string scalar nodisplay0,
	string scalar cmce0,
	string scalar touse,
	real scalar _is_rc_on_p0)
{

	// declarations
	real matrix rc,market_rows,simdrawsw,demog_cov,dx,msumf,msumf_post
	real colvector beta,market,firm,firm_post,p,s,xb0,ksi,delta,msize,vat,demog_mean,obs,alphav,mc/*
		*/,productm,firmm,firm_postm,pm,sm,deltam,alpham/*
		*/,mcm,mrkp,s0m,ksim_logit,mcm_logit,pm_start,mce
	real rowvector params
	real scalar mm,m,ndvars,alpha

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(firm_post, .,tokens(firm_post0),touse)
	st_view(p, .,p0,touse)
	st_view(s, .,share0,touse)
	st_view(xd0, .,tokens(iexog0),touse)
	st_view(xb, .,tokens(xb00),touse)
	st_view(ksi, .,tokens(ksi0),touse)
	st_view(delta, .,tokens(delta0),touse)
	st_view(rc, .,tokens(rc0),touse)
	if (demog_xvars0!="") {
		st_view(dx, .,tokens(demog_xvars0),touse)
		demog_mean=st_matrix(demog_mean0)
		demog_cov=st_matrix(demog_cov0)
	}
	st_view(msize, .,tokens(msize0),touse)
	if (mc0!="") {
		st_view(mc, .,tokens(mc0),touse)
	}
	st_view(vat, .,tokens(vat0),touse)
	if (segment0!="") {
		st_view(segment, .,tokens(segment0),touse)
	}
	b=st_matrix(b0)
	_is_rc_on_p=_is_rc_on_p0
	rseed(1)

	// reindexing (categorical variables should start from 1 and increment by 1)
	market=reindex(market)

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

	// parameters
	beta=b[1,cols(rc)+1..cols(rc)+1+cols(xd0)]'										// mean utility coefficients
	params=b[.,1..cols(rc)]															// non-linear parameters ("the sigmas")
	alpha=-b[1,cols(rc)+1]															// (negative of) mean price coefficient
	if (_is_rc_on_p==1) {
		alphai=alpha:-(params[1,1]*simdraws[1,.])									// individual price coefficients (if there is random coefficient on price)
	}
	if (_is_rc_on_p==0) {
		alphai=alpha:*J(1,cols(simdraws),1)											// individual price coefficients (if there is no random coefficient on price)
	}
	alphai2=alphai:*alphai
	alphav=J(rows(market),1,alpha)

	// implied marginal cost and margin
	if (mc0=="") {
		mc=marginal_cost_blp(market,p,msize,vat,rc,delta,firm,params,simdraws,alpha,alphai)
		mrkp=(p:/(1:+vat)):-mc
	}
	
	// compensating marginal cost
	if (cmce0!="") {
		mce=marginal_cost_blp(market,p,msize,vat,rc,delta,firm_post,params,simdraws,alpha,alphai)
	}

	// solving for the new equilibrium shares and prices
	if (onlymc0=="") {
		rseed(1)
		eq_data=equilibrium_blp(p,market,firm_post,xd0,ksi,mc,vat,rc,msize,xb,simdraws,params,beta,_is_rc_on_p,nodisplay0)
		p_post=eq_data[.,1]
		s_post=eq_data[.,2]
		foc_post=eq_data[.,3]
		e_post=eq_data[.,4]
	}

	// SSNIP-tests
	if (segment0!="") {
		g=J(rows(market),1,0)
		h=J(rows(market),1,0)
		k=J(rows(market),1,0)
		ssnip_rcl(market,firm,segment,p,s,msize,xd0,ksi,mc,vat,rc,g,h,k,simdraws,params,beta,_is_rc_on_p)
	}

	// exporting results into Stata
	if (mc0=="") {
		stata("capture drop __mc")
		stata("quietly generate __mc=.")
		st_store( .,"__mc",touse,mc)
		stata("capture drop __mrkp")
		stata("quietly generate __mrkp=.")
		st_store( .,"__mrkp",touse,mrkp)
	}
	if (cmce0!="") {
		stata("capture drop __mce")
		stata("quietly generate __mce=.")
		st_store( .,"__mce",touse,mce)
	}
	if (onlymc0=="") {
		stata("capture drop __p_post")
		stata("quietly generate __p_post=.")
		st_store( .,"__p_post",touse,p_post)
		stata("capture drop __s_post")
		stata("quietly generate __s_post=.")
		st_store( .,"__s_post",touse,s_post)
		stata("capture drop __foc_post")
		stata("quietly generate __foc_post=.")
		st_store( .,"__foc_post",touse,foc_post)
	}
	
}	// end of merger_simulation_blp
mata mlib add lrcl merger_simulation_blp()


// simple logit merger simulation
void merger_simulation_logit(
	string scalar market0,
	string scalar firm0,
	string scalar firm_post0,
	string scalar msize0,
	string scalar p0,
	string scalar share0,
	string scalar xb0,
	string scalar ksi0,
	string scalar alpha0,
	string scalar obs0,
	string scalar mc0,
	string scalar vat0,
	string scalar onlymc0,
	string scalar nodisplay0,
	string scalar cmce0,
	string scalar touse)
{

	// declarations
	real colvector market,firm,firm_post,msize,p,s,xb,ksi,alpha,obs,vat/*
		*/,marketm,productm,firmm,firm_postm,msizem,pm,sm,xbm,ksim,alpham,obsm,vatm/*
		*/,qm,qfgm/*
		*/,d0m,summa0m,mcm/*
		*/,pm0,pm1,pm00,sm0,sm1,s0m,difm,mce00,mcem,mrkpm0,focm
	real matrix amsumf,amsumf_post,msumf,msumf_post
	real scalar m,i,dif,tol,maxiter

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(firm_post, .,tokens(firm_post0),touse)
	st_view(msize, .,tokens(msize0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(xb, .,tokens(xb0),touse)
	st_view(ksi, .,tokens(ksi0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(obs, .,tokens(obs0),touse)
	if (mc0!="") {
		st_view(mc, .,tokens(mc0),touse)
	}
	st_view(vat, .,tokens(vat0),touse)

	// reindexing group variables (categorical variables should start from 1 and increment by 1; reindexig doesn't change the sort order of the data)
	market=reindex(market)

	// prices and shares (to be filled up)
	if (onlymc0=="") {
		p00=J(rows(market),1,.)
		s00=J(rows(market),1,.)
		dif00=J(rows(market),1,.)
	}
	if (mc0=="") {
		mc00=J(rows(market),1,.)
		mrkp00=J(rows(market),1,.)
	}
	if (cmce0!="") {
		mce00=J(rows(market),1,.)
	}

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		if (nodisplay0=="" & onlymc0=="") {
			printf("|")
			displayflush()
		}

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		firm_postm=select(firm_post,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p,market:==m)
		sm=select(s,market:==m)
		xbm=select(xb,market:==m)
		ksim=select(ksi,market:==m)
		alpham=select(alpha,market:==m)
		obsm=select(obs,market:==m)
		vatm=select(vat,market:==m)
		d0m=J(rows(sm),1,1):/msizem
		productm=runningsum(J(rows(marketm),1,1))

		// matrices for summations
		msumf=amsumf(productm,firmm)													// pre-merger product ownership matrix
		msumf_post=amsumf(productm,firm_postm)											// post-merger product ownership matrix

		// compensating marginal cost
		if (cmce0!="") {
			mcem=marginal_cost_logit(sm,pm,msizem,vatm,alpham,msumf_post)
			mce00[obsm]=mcem
		}

		// implied marginal cost
		if (mc0=="") {
			mcm=marginal_cost_logit(sm,pm,msizem,vatm,alpham,msumf)
			mc00[obsm]=mcm
			mrkp00[obsm]=(pm:/(1:+vatm)):-mcm											// pre-merger implied markup
		}
		if (mc0!="") {
			mcm=select(mc,market:==m)
		}

		if (onlymc0=="") {

			// initial shares and prices
			sm0=sm
			pm0=pm

			// solving for the new equilibrium shares and prices
			i=0
			dif=1000
			tol=0.00005
			maxiter=1000
			damp=0.0001
			damp_switch=0
			while (dif>tol & i<maxiter) {
				i=i+1

				// demand prediction given initial shares and prices
				s0m=(1-colsum(sm0))*J(rows(sm),1,1)										// share of outside good
				sm1=(-alpham:*pm0):+(xbm):+(ksim):+(ln(s0m))
				sm1=exp(sm1)															// predicted shares given initial shares and prices
				if ((1-colsum(sm1))>0 & damp_switch==0) {
					sm0=sm1																// updating initial shares
				}
				if ((1-colsum(sm1))<=0 | damp_switch==1) {
					damp_switch=1														// switch to dampening
					sm0=(1-damp)*sm0 :+ damp*sm1										// updating initial shares (avoiding exploding outside good share)
					if ((1-colsum(sm1))>0) {
						damp=damp+1/(rows(sm)*10)
						if (damp>1) {
							damp=1
						}
					}
				}

				// quantity variables
				qm=sm0:*msizem															// quantity
				qfm=msumf_post*qm														// firms' sum of quantities

				// price prediction given demand prediction: marginal cost plus updated margin (implied by initial prices and updated shares)
				summa0m=qfm:/((J(rows(sm),1,1):-(d0m:*qfm)):*(alpham:*(1:+vatm)))
				pm1=mcm:+( (J(rows(sm),1,1):/(alpham:*(1:+vatm))) :+(d0m:*summa0m) )
				pm1=pm1:*(1:+vatm)
				mrkpm0=(pm0:/(1:+vatm)):-mcm											// net markup
				focm=(sm0)																// vector of implied first order conditions
				focm=focm :- (alpham:*(1:+vatm)):*sm0:*mrkpm0
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*d0m):*summa0m
				dif=max(abs(focm))														// objective: (abs) norm of FOC vector
				//dif=colmax(abs(100*(pm1:-pm0):/pm0))									// percent change in prices relative to initial prices
				pm00=pm0
				pm0=pm1																	// updating initial prices

				// price change
				//dpm=colsum(100*((pm1:-pm):/pm):*(sm:*msizem))/colsum(sm:*msizem)
				//m,i,dif,dpm

			}	// end of i while loop (equilibrium fixed point)

			dif00[obsm]=focm

			// price change
			dpm=colsum(100*((pm1:-pm):/pm):*(sm:*msizem))/colsum(sm:*msizem)
			//m,i,dif,dpm

			// prices and shares
			p00[obsm]=pm0
			s00[obsm]=sm0

		}	// end of simulation if condition

	}	// end of m (markets) loop 
	
	// exporting results into Stata
	if (mc0=="") {
		stata("capture drop __mc")
		stata("quietly generate __mc=.")
		st_store( .,"__mc",touse,mc00)
		stata("capture drop __mrkp")
		stata("quietly generate __mrkp=.")
		st_store( .,"__mrkp",touse,mrkp00)
	}
	if (onlymc0=="") {
		stata("capture drop __p_post")
		stata("quietly generate __p_post=.")
		st_store( .,"__p_post",touse,p00)
		stata("capture drop __s_post")
		stata("quietly generate __s_post=.")
		st_store( .,"__s_post",touse,s00)
		stata("capture drop __dif")
		stata("quietly generate __dif=.")
		st_store( .,"__dif",touse,dif00)
		stata("capture drop __foc_post")
		stata("quietly generate __foc_post=.")
		st_store( .,"__foc_post",touse,dif00)
	}
	if (cmce0!="") {
		stata("capture drop __mce")
		stata("quietly generate __mce=.")
		st_store( .,"__mce",touse,mce00)
	}

}	// end of merger_simulation_logit function
mata mlib add lrcl merger_simulation_logit()


// one-level nested logit merger simulation
void merger_simulation_nlogit(
	string scalar market0,
	string scalar firm0,
	string scalar firm_post0,
	string scalar msize0,
	string scalar p0,
	string scalar share0,
	string scalar xb0,
	string scalar ksi0,
	string scalar g0,
	string scalar alpha0,
	string scalar sigmag0,
	string scalar obs0,
	string scalar mc0,
	string scalar vat0,
	string scalar onlymc0,
	string scalar nodisplay0,
	string scalar cmce0,
	string scalar touse)
{

	// declarations
	real colvector market,firm,firm_post,msize,p,s,xb,ksi,g,alpha,sigmag,obs,vat/*
		*/,marketm,productm,firmm,firm_postm,msizem,pm,sm,xbm,ksim,gm,alpham,sigmagm,obsm,vatm/*
		*/,nmsumfg,nmsumfg_post,qm,qgm,qfgm/*
		*/,d0m,dgm,gammagm,lambdagm,gamma0m,summa0m,summagm,mcm/*
		*/,pm0,pm1,pm00,sm0,sm1,s0m,sjgm,difm,mrkpm0,focm
	real matrix amsumf,amsumf_post,amsumg,amsumfg,amsumfg_post,msumf,msumf_post,msumg,msumfg,msumfg_post
	real scalar m,i,dif,tol,maxiter

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(firm_post, .,tokens(firm_post0),touse)
	st_view(msize, .,tokens(msize0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(xb, .,tokens(xb0),touse)
	st_view(ksi, .,tokens(ksi0),touse)
	st_view(g, .,tokens(g0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(sigmag, .,tokens(sigmag0),touse)
	st_view(obs, .,tokens(obs0),touse)
	if (mc0!="") {
		st_view(mc, .,tokens(mc0),touse)
	}
	st_view(vat, .,tokens(vat0),touse)

	// reindexing group variables (categorical variables should start from 1 and increment by 1; reindexig doesn't change the sort order of the data)
	market=reindex(market)
	g=reindex(g)

	// prices and shares (to be filled up)
	if (onlymc0=="") {
		p00=J(rows(market),1,.)
		s00=J(rows(market),1,.)
		dif00=J(rows(market),1,.)
	}
	if (mc0=="") {
		mc00=J(rows(market),1,.)
		mrkp00=J(rows(market),1,.)
	}
	if (cmce0!="") {
		mce00=J(rows(market),1,.)
	}

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		if (nodisplay0=="" & onlymc0=="") {
			printf("|")
			displayflush()
		}

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		firm_postm=select(firm_post,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p,market:==m)
		sm=select(s,market:==m)
		xbm=select(xb,market:==m)
		ksim=select(ksi,market:==m)
		gm=select(g,market:==m)
		alpham=select(alpha,market:==m)
		sigmagm=select(sigmag,market:==m)
		obsm=select(obs,market:==m)
		vatm=select(vat,market:==m)
		d0m=J(rows(sm),1,1):/msizem
		productm=runningsum(J(rows(marketm),1,1))
		
		// matrices for summations
		msumf=amsumf(productm,firmm)													// pre-merger product ownership matrix
		msumf_post=amsumf(productm,firm_postm)											// post-merger product ownership matrix
		msumg=amsumf(productm,gm)
		msumfg=msumg:*msumf
		nmsumfg=msumfg*J(rows(productm),1,1)
		msumfg_post=msumg:*msumf_post
		nmsumfg_post=msumfg_post*J(rows(productm),1,1)

		// compensating marginal cost
		if (cmce0!="") {
			mcem=marginal_cost_nlogit(sm,pm,msizem,vatm,alpham,sigmagm,msumf_post,msumg,msumfg_post,nmsumfg_post)
			mce00[obsm]=mcem
		}

		// implied marginal cost
		if (mc0=="") {
			mcm=marginal_cost_nlogit(sm,pm,msizem,vatm,alpham,sigmagm,msumf,msumg,msumfg,nmsumfg)
			mc00[obsm]=mcm
			mrkp00[obsm]=(pm:/(1:+vatm)):-mcm											// pre-merger implied markup
		}
		if (mc0!="") {
			mcm=select(mc,market:==m)
		}

		if (onlymc0=="") {

			// initial shares and prices
			sm0=sm
			pm0=pm

			// solving for the new equilibrium shares and prices
			i=0
			dif=1000
			tol=0.0005
			maxiter=1000
			damp=0.0001
			damp_switch=0
			while (dif>tol & i<maxiter) {
				i=i+1

				// demand prediction given initial shares and prices
				s0m=(1-colsum(sm0))*J(rows(sm),1,1)										// share of outside good
				sgm=msumg*sm0															// group shares
				sjgm=sm0:/sgm															// products' share in their group
				sm1=(-alpham:*pm0):+(sigmagm:*(ln(sjgm))):+(xbm):+(ksim):+(ln(s0m))
				sm1=exp(sm1)															// predicted shares given initial shares and prices
				if ((1-colsum(sm1))>0 & damp_switch==0) {
					sm0=sm1																// updating initial shares
				}
				if ((1-colsum(sm1))<=0 | damp_switch==1) {
					sm0=(1-damp)*sm0 :+ damp*sm1										// updating initial shares (avoiding exploding outside good share)
					if ((1-colsum(sm1))>0) {
						damp=damp+1/(rows(sm)*10)
						if (damp>1) {
							damp=1
						}
					}
					if ((1-colsum(sm1))<0 & damp_switch==1 & damp>0.01) {
						damp=damp/2
					}
					damp_switch=1														// switch to dampening
				}

				// quantity variables
				qm=sm0:*msizem															// quantity
				qgm=msumg*qm															// sum of quantities in groups
				qfgm=msumfg_post*qm														// firms' sum of quantities in groups

				// price prediction given demand prediction: marginal cost plus updated margin (implied by initial prices and updated shares)
				dgm=((sigmagm:/(J(rows(sm),1,1):-sigmagm)):/qgm)
				gammagm=(J(rows(sm),1,1):-sigmagm):*qfgm
				lambdagm=gammagm:/(J(rows(sm),1,1):-(dgm:*gammagm))
				gamma0m=msumf_post*lambdagm:/nmsumfg_post
				summa0m=gamma0m:/((J(rows(sm),1,1):-(d0m:*gamma0m)):*(alpham:*(1:+vatm)))
				summagm=(lambdagm:/(alpham:*(1:+vatm))):+(lambdagm:*d0m:*summa0m)
				pm1=mcm:+(J(rows(sm),1,1):-sigmagm):*( (J(rows(sm),1,1):/(alpham:*(1:+vatm))) :+ (dgm:*summagm) :+(d0m:*summa0m) )
				pm1=pm1:*(1:+vatm)
				mrkpm0=(pm0:/(1:+vatm)):-mcm											// net markup
				focm=(sm0)																// vector of implied first order conditions
				focm=focm :- ((alpham:*(1:+vatm)):/(J(rows(sm0),1,1):-sigmagm)):*sm0:*mrkpm0
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*dgm):*summagm
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*d0m):*summa0m
				dif=max(abs(focm))														// objective: (abs) norm of FOC vector
				pm00=pm0
				pm0=pm1																	// updating initial prices
				
				// price change
				//dpm=colsum(100*((pm1:-pm):/pm):*(sm:*msizem))/colsum(sm:*msizem)
				//m,i,dif,dpm,colsum(sm0),damp,damp_switch

			}	// end of i while loop (equilibrium fixed point)

			// price change
			dpm=colsum(100*((pm1:-pm):/pm):*(sm:*msizem))/colsum(sm:*msizem)
			//m,i,dif,dpm,damp

			// prices and shares
			p00[obsm]=pm0
			s00[obsm]=sm0
			dif00[obsm]=focm

		}	// end of simulation if condition

	}	// end of m (markets) loop 
	
	// exporting results into Stata
	if (mc0=="") {
		stata("capture drop __mc")
		stata("quietly generate __mc=.")
		st_store( .,"__mc",touse,mc00)
		stata("capture drop __mrkp")
		stata("quietly generate __mrkp=.")
		st_store( .,"__mrkp",touse,mrkp00)
	}
	if (onlymc0=="") {
		stata("capture drop __p_post")
		stata("quietly generate __p_post=.")
		st_store( .,"__p_post",touse,p00)
		stata("capture drop __s_post")
		stata("quietly generate __s_post=.")
		st_store( .,"__s_post",touse,s00)
		stata("capture drop __dif")
		stata("quietly generate __dif=.")
		st_store( .,"__dif",touse,dif00)
		stata("capture drop __foc_post")
		stata("quietly generate __foc_post=.")
		st_store( .,"__foc_post",touse,dif00)
	}
	if (cmce0!="") {
		stata("capture drop __mce")
		stata("quietly generate __mce=.")
		st_store( .,"__mce",touse,mce00)
	}

}	// end of merger_simulation_nlogit function
mata mlib add lrcl merger_simulation_nlogit()


// two-level nested logit merger simulation
void merger_simulation_nlogit2(
	string scalar market0,
	string scalar firm0,
	string scalar firm_post0,
	string scalar msize0,
	string scalar p0,
	string scalar share0,
	string scalar xb0,
	string scalar ksi0,
	string scalar g0,
	string scalar h0,
	string scalar alpha0,
	string scalar sigmag0,
	string scalar sigmah0,
	string scalar obs0,
	string scalar mc0,
	string scalar vat0,
	string scalar onlymc0,
	string scalar nodisplay0,
	string scalar cmce0,
	string scalar touse)
{

	// declarations
	real colvector market,firm,firm_post,msize,p,s,xb,ksi,g,h,alpha,sigmag,sigmah,obs,vat/*
		*/,marketm,productm,firmm,firm_postm,msizem,pm,sm,xbm,ksim,gm,hm,alpham,sigmagm,sigmahm,obsm,vatm/*
		*/,nmsumfg,nmsumfhg,nmsumfg_post,nmsumfhg_post,qm,qgm,qhgm,qfhgm/*
		*/,d0m,dgm,dhgm,gammagm,gammahgm,gamma0m,lambdahgm,lambdagm,summa0m,summagm,summahgm,mcm/*
		*/,pm0,pm1,pm00,sm0,sm1,s0m,sgm,shm,shgm,sjhm,difm,mrkpm0,focm
	real matrix amsumf,amsumf_post,amsumg,amsumh,amsumfg,amsumfhg,amsumfg_post,amsumfhg_post,msumf,msumf_post,msumg,msumhg,msumfg,msumfhg,msumfg_post,msumfhg_post
	real scalar m,i,dif,tol,maxiter

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(firm_post, .,tokens(firm_post0),touse)
	st_view(msize, .,tokens(msize0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(xb, .,tokens(xb0),touse)
	st_view(ksi, .,tokens(ksi0),touse)
	st_view(g, .,tokens(g0),touse)
	st_view(h, .,tokens(h0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(sigmag, .,tokens(sigmag0),touse)
	st_view(sigmah, .,tokens(sigmah0),touse)
	st_view(obs, .,tokens(obs0),touse)
	if (mc0!="") {
		st_view(mc, .,tokens(mc0),touse)
	}
	st_view(vat, .,tokens(vat0),touse)

	// reindexing group variables (categorical variables should start from 1 and increment by 1; reindexig doesn't change the sort order of the data)
	market=reindex(market)
	g=reindex(g)
	h=reindex(h)

	// prices and shares (to be filled up)
	if (onlymc0=="") {
		p00=J(rows(market),1,.)
		s00=J(rows(market),1,.)
		dif00=J(rows(market),1,.)
	}
	if (mc0=="") {
		mc00=J(rows(market),1,.)
		mrkp00=J(rows(market),1,.)
	}
	if (cmce0!="") {
		mce00=J(rows(market),1,.)
	}

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		if (nodisplay0=="" & onlymc0=="") {
			printf("|")
			displayflush()
		}

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		firm_postm=select(firm_post,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p,market:==m)
		sm=select(s,market:==m)
		xbm=select(xb,market:==m)
		ksim=select(ksi,market:==m)
		gm=select(g,market:==m)
		hm=select(h,market:==m)
		alpham=select(alpha,market:==m)
		sigmagm=select(sigmag,market:==m)
		sigmahm=select(sigmah,market:==m)
		obsm=select(obs,market:==m)
		vatm=select(vat,market:==m)
		d0m=J(rows(sm),1,1):/msizem
		productm=runningsum(J(rows(marketm),1,1))

		// matrices for summations
		msumf=amsumf(productm,firmm)													// pre-merger product ownership matrix
		msumf_post=amsumf(productm,firm_postm)											// post-merger product ownership matrix
		msumg=amsumf(productm,gm)
		msumh=amsumf(productm,hm)
		msumhg=msumh:*msumg
		msumfg=msumg:*msumf
		msumfhg=msumh:*msumg:*msumf
		nmsumfg=msumfg*J(rows(productm),1,1)
		nmsumfhg=msumfhg*J(rows(productm),1,1)
		msumfg_post=msumg:*msumf_post	
		msumfhg_post=msumh:*msumg:*msumf_post
		nmsumfg_post=msumfg_post*J(rows(productm),1,1)
		nmsumfhg_post=msumfhg_post*J(rows(productm),1,1)

		// compensating marginal cost
		if (cmce0!="") {
			mcem=marginal_cost_nlogit2(sm,pm,msizem,vatm,alpham,sigmagm,sigmahm,msumf_post,msumg,msumhg,msumfg_post,msumfhg_post,nmsumfg_post,nmsumfhg_post)
			mce00[obsm]=mcem
		}

		// implied marginal cost
		if (mc0=="") {
			mcm=marginal_cost_nlogit2(sm,pm,msizem,vatm,alpham,sigmagm,sigmahm,msumf,msumg,msumhg,msumfg,msumfhg,nmsumfg,nmsumfhg)
			mc00[obsm]=mcm
			mrkp00[obsm]=(pm:/(1:+vatm)):-mcm											// pre-merger implied markup
		}
		if (mc0!="") {
			mcm=select(mc,market:==m)
		}

		if (onlymc0=="") {

			// initial shares and prices
			sm0=sm
			pm0=pm

			// solving for the new equilibrium shares and prices
			i=0
			dif=1000
			tol=0.0005
			maxiter=100
			damp=0.0001
			damp_switch=0
			while (dif>tol & i<maxiter) {
				i=i+1

				// demand prediction given initial shares and prices
				s0m=(1-colsum(sm0))*J(rows(sm),1,1)										// share of outside good
				sgm=msumg*sm0															// group shares
				shm=msumhg*sm0															// subgroup shares
				sjhm=sm0:/shm															// products' share in their subgroup
				shgm=shm:/sgm															// subgroups' share in their group
				sm1=(-alpham:*pm0):+(sigmahm:*(ln(sjhm))):+(sigmagm:*(ln(shgm))):+(xbm):+(ksim):+(ln(s0m))
				sm1=exp(sm1)															// predicted shares given initial shares and prices
				if ((1-colsum(sm1))>0 & damp_switch==0) {
					sm0=sm1																// updating initial shares
				}
				if ((1-colsum(sm1))<=0 | damp_switch==1) {
					damp_switch=1														// switch to dampening
					sm0=(1-damp)*sm0 :+ damp*sm1										// updating initial shares (avoiding exploding outside good share)
					if ((1-colsum(sm1))>0) {
						damp=damp+1/(rows(sm)*10)
						if (damp>1) {
							damp=1
						}
					}
				}

				// quantity variables
				qm=sm0:*msizem															// quantity
				qgm=msumg*qm															// sum of quantities in groups
				qhgm=msumhg*qm															// sum of quantities in subgroups
				qfhgm=msumfhg_post*qm													// firms' sum of quantities in subgroups

				// price prediction given demand prediction: marginal cost plus updated margin (implied by initial prices and updated shares)
				dgm=((sigmagm:/(J(rows(sm),1,1):-sigmagm)):/qgm)
				dhgm=(((J(rows(sigmahm),1,1):/(J(rows(sigmahm),1,1)-sigmahm)):-(J(rows(sigmagm),1,1):/(J(rows(sigmagm),1,1)-sigmagm))):/qhgm)
				gammahgm=(J(rows(sm),1,1):-sigmahm):*qfhgm
				lambdahgm=gammahgm:/(J(rows(sm),1,1):-(dhgm:*gammahgm))
				gammagm=msumfg_post*lambdahgm:/nmsumfhg_post
				lambdagm=gammagm:/(J(rows(sm),1,1):-(dgm:*gammagm))
				gamma0m=msumf_post*lambdagm:/nmsumfg_post
				summa0m=gamma0m:/((J(rows(sm),1,1):-(d0m:*gamma0m)):*(alpham:*(1:+vatm)))
				summagm=(lambdagm:/(alpham:*(1:+vatm))):+(lambdagm:*d0m:*summa0m)
				summahgm=(lambdahgm:/(alpham:*(1:+vatm))):+(lambdahgm:*dgm:*summagm):+(lambdahgm:*d0m:*summa0m)
				pm1=mcm:+(J(rows(sm),1,1):-sigmahm):*( (J(rows(sm),1,1):/(alpham:*(1:+vatm))) :+ (dhgm:*summahgm) :+ (dgm:*summagm) :+(d0m:*summa0m) )
				pm1=pm1:*(1:+vatm)
				mrkpm0=(pm0:/(1:+vatm)):-mcm											// net markup
				focm=(sm0)																// vector of implied first order conditions
				focm=focm :- ((alpham:*(1:+vatm)):/(J(rows(sm0),1,1):-sigmahm)):*sm0:*mrkpm0
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*dhgm):*summahgm
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*dgm):*summagm
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*d0m):*summa0m
				dif=max(abs(focm))														// objective: (abs) norm of FOC vector
				pm00=pm0
				pm0=pm1																	// updating initial prices
				
				// price change
				//dpm=colsum(100*((pm1:-pm):/pm):*(sm:*msizem))/colsum(sm:*msizem)
				//m,i,dif

			}	// end of i while loop (equilibrium fixed point)
			
			// price change
			dpm=colsum(100*((pm1:-pm):/pm):*(sm:*msizem))/colsum(sm:*msizem)
			//m,i,dif,dpm,damp

			// prices and shares
			p00[obsm]=pm0
			s00[obsm]=sm0
			dif00[obsm]=focm

		}	// end of simulation if condition

	}	// end of m (markets) loop 

	// exporting results into Stata
	if (mc0=="") {
		stata("capture drop __mc")
		stata("quietly generate __mc=.")
		st_store( .,"__mc",touse,mc00)
		stata("capture drop __mrkp")
		stata("quietly generate __mrkp=.")
		st_store( .,"__mrkp",touse,mrkp00)
	}
	if (onlymc0=="") {
		stata("capture drop __p_post")
		stata("quietly generate __p_post=.")
		st_store( .,"__p_post",touse,p00)
		stata("capture drop __s_post")
		stata("quietly generate __s_post=.")
		st_store( .,"__s_post",touse,s00)
		stata("capture drop __dif")
		stata("quietly generate __dif=.")
		st_store( .,"__dif",touse,dif00)
		stata("capture drop __foc_post")
		stata("quietly generate __foc_post=.")
		st_store( .,"__foc_post",touse,dif00)
	}
	if (cmce0!="") {
		stata("capture drop __mce")
		stata("quietly generate __mce=.")
		st_store( .,"__mce",touse,mce00)
	}

}	// end of merger_simulation_nlogit2 function
mata mlib add lrcl merger_simulation_nlogit2()


// three-level nested logit merger simulation
void merger_simulation_nlogit3(
	string scalar market0,
	string scalar firm0,
	string scalar firm_post0,
	string scalar msize0,
	string scalar p0,
	string scalar share0,
	string scalar xb0,
	string scalar ksi0,
	string scalar g0,
	string scalar h0,
	string scalar k0,
	string scalar alpha0,
	string scalar sigmag0,
	string scalar sigmah0,
	string scalar sigmak0,
	string scalar obs0,
	string scalar mc0,
	string scalar vat0,
	string scalar onlymc0,
	string scalar nodisplay0,
	string scalar cmce0,
	string scalar touse)
{

	// declarations
	real colvector market,firm,firm_post,msize,p,s,xb,ksi,g,h,k,alpha,sigmag,sigmah,sigmak,obs,vat/*
		*/,marketm,productm,firmm,firm_postm,msizem,pm,sm,xbm,ksim,gm,hm,km,alpham,sigmagm,sigmahm,sigmakm,obsm,vatm/*
		*/,nmsumfg,nmsumfhg,nmsumfkhg,nmsumfg_post,nmsumfhg_post,nmsumfkhg_post,qm,qgm,qhgm,qkhgm,qfkhgm/*
		*/,d0m,dgm,dhgm,dkhgm,gamma0m,gammagm,gammahgm,gammakhgm,lambdakhgm,lambdahgm,lambdagm,summa0m,summagm,summahgm,summakhgm,mcm/*
		*/,pm0,pm1,pm00,sm0,sm1,s0m,sgm,shm,skm,shgm,skhm,sjkm,difm,mrkpm0,focm
	real matrix amsumf,amsumf_post,amsumg,amsumh,amsumk,amsumfg,amsumfhg,amsumfkhg,amsumfg_post,amsumfhg_post,amsumfkhg_post,msumf,msumf_post,msumg,msumhg,msumkhg,msumfg,msumfhg,msumfkhg,msumfg_post,msumfhg_post,msumfkhg_post
	real scalar m,i,dif,tol,maxiter

	// load data
	st_view(market, .,tokens(market0),touse)
	st_view(firm, .,tokens(firm0),touse)
	st_view(firm_post, .,tokens(firm_post0),touse)
	st_view(msize, .,tokens(msize0),touse)
	st_view(p, .,tokens(p0),touse)
	st_view(s, .,tokens(share0),touse)
	st_view(xb, .,tokens(xb0),touse)
	st_view(ksi, .,tokens(ksi0),touse)
	st_view(g, .,tokens(g0),touse)
	st_view(h, .,tokens(h0),touse)
	st_view(k, .,tokens(k0),touse)
	st_view(alpha, .,tokens(alpha0),touse)
	st_view(sigmag, .,tokens(sigmag0),touse)
	st_view(sigmah, .,tokens(sigmah0),touse)
	st_view(sigmak, .,tokens(sigmak0),touse)
	st_view(obs, .,tokens(obs0),touse)
	if (mc0!="") {
		st_view(mc, .,tokens(mc0),touse)
	}
	st_view(vat, .,tokens(vat0),touse)

	// reindexing group variables (categorical variables should start from 1 and increment by 1; reindexig doesn't change the sort order of the data)
	market=reindex(market)
	g=reindex(g)
	h=reindex(h)
	k=reindex(k)

	// prices and shares (to be filled up)
	if (onlymc0=="") {
		p00=J(rows(market),1,.)
		s00=J(rows(market),1,.)
		dif00=J(rows(market),1,.)
	}
	if (mc0=="") {
		mc00=J(rows(market),1,.)
		mrkp00=J(rows(market),1,.)
	}
	if (cmce0!="") {
		mce00=J(rows(market),1,.)
	}

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		if (nodisplay0=="" & onlymc0=="") {
			printf("|")
			displayflush()
		}

		// variables for market m
		marketm=select(market,market:==m)
		firmm=select(firm,market:==m)
		firm_postm=select(firm_post,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p,market:==m)
		sm=select(s,market:==m)
		xbm=select(xb,market:==m)
		ksim=select(ksi,market:==m)
		gm=select(g,market:==m)
		hm=select(h,market:==m)
		km=select(k,market:==m)
		alpham=select(alpha,market:==m)
		sigmagm=select(sigmag,market:==m)
		sigmahm=select(sigmah,market:==m)
		sigmakm=select(sigmak,market:==m)
		obsm=select(obs,market:==m)
		vatm=select(vat,market:==m)
		d0m=J(rows(sm),1,1):/msizem
		productm=runningsum(J(rows(marketm),1,1))

		// matrices for summations
		msumf=amsumf(productm,firmm)													// pre-merger product ownership matrix
		msumf_post=amsumf(productm,firm_postm)											// post-merger product ownership matrix
		msumg=amsumf(productm,gm)
		msumh=amsumf(productm,hm)
		msumk=amsumf(productm,km)
		msumhg=msumh:*msumg
		msumkhg=msumk:*msumhg
		msumfg=msumg:*msumf
		msumfhg=msumhg:*msumf
		msumfkhg=msumkhg:*msumf
		nmsumfg=msumfg*J(rows(productm),1,1)
		nmsumfhg=msumfhg*J(rows(productm),1,1)
		nmsumfkhg=msumfkhg*J(rows(productm),1,1)
		msumfg_post=msumg:*msumf_post	
		msumfhg_post=msumhg:*msumf_post
		msumfkhg_post=msumkhg:*msumf_post
		nmsumfg_post=msumfg_post*J(rows(productm),1,1)
		nmsumfhg_post=msumfhg_post*J(rows(productm),1,1)
		nmsumfkhg_post=msumfkhg_post*J(rows(productm),1,1)

		// compensating marginal cost
		if (cmce0!="") {
			mcem=marginal_cost_nlogit3(sm,pm,msizem,vatm,alpham,sigmagm,sigmahm,sigmakm,msumf_post,msumg,msumhg,msumkhg,msumfg_post,msumfhg_post,msumfkhg_post,nmsumfg_post,nmsumfhg_post,nmsumfkhg_post)
			mce00[obsm]=mcem
		}

		// implied marginal cost
		if (mc0=="") {
			mcm=marginal_cost_nlogit3(sm,pm,msizem,vatm,alpham,sigmagm,sigmahm,sigmakm,msumf,msumg,msumhg,msumkhg,msumfg,msumfhg,msumfkhg,nmsumfg,nmsumfhg,nmsumfkhg)
			mc00[obsm]=mcm
			mrkp00[obsm]=(pm:/(1:+vatm)):-mcm											// pre-merger implied markup
		}
		if (mc0!="") {
			mcm=select(mc,market:==m)
		}

		if (onlymc0=="") {

			// initial shares and prices
			sm0=sm
			pm0=pm

			// solving for the new equilibrium shares and prices
			i=0
			dif=1000
			tol=0.0005
			maxiter=1000
			damp=0.0001
			damp_switch=0
			while (dif>tol & i<maxiter) {
				i=i+1

				// demand prediction given initial shares and prices
				s0m=(1-colsum(sm0))*J(rows(sm),1,1)										// share of outside good
				sgm=msumg*sm0															// group shares
				shm=msumhg*sm0															// subgroup shares
				skm=msumkhg*sm0															// sub-subgroup shares
				sjkm=sm0:/skm															// products' share in their sub-subgroup
				skhm=skm:/shm															// sub-subgroup' share in their subgroup
				shgm=shm:/sgm															// subgroups' share in their group
				sm1=(-alpham:*pm0):+(sigmakm:*(ln(sjkm))):+(sigmahm:*(ln(skhm))):+(sigmagm:*(ln(shgm))):+(xbm):+(ksim):+(ln(s0m))
				sm1=exp(sm1)															// predicted shares given initial shares and prices
				if ((1-colsum(sm1))>0 & damp_switch==0) {
					sm0=sm1																// updating initial shares
				}
				if ((1-colsum(sm1))<=0 | damp_switch==1) {
					damp_switch=1														// switch to dampening
					sm0=(1-damp)*sm0 :+ damp*sm1										// updating initial shares (avoiding exploding outside good share)
					if ((1-colsum(sm1))>0) {
						damp=damp+1/(rows(sm)*10)
						if (damp>1) {
							damp=1
						}
					}
				}

				// quantity variables
				qm=sm0:*msizem															// quantity
				qgm=msumg*qm															// sum of quantities in groups
				qhgm=msumhg*qm															// sum of quantities in subgroups
				qkhgm=msumkhg*qm														// sum of quantities in sub-subgroups
				qfkhgm=msumfkhg_post*qm													// firms' sum of quantities in sub-subgroups

				// price prediction given demand prediction: marginal cost plus updated margin (implied by initial prices and updated shares)
				dgm=((sigmagm:/(J(rows(sm),1,1):-sigmagm)):/qgm)
				dhgm=(((J(rows(sigmahm),1,1):/(J(rows(sigmahm),1,1)-sigmahm)):-(J(rows(sigmagm),1,1):/(J(rows(sigmagm),1,1)-sigmagm))):/qhgm)
				dkhgm=(((J(rows(sigmakm),1,1):/(J(rows(sigmakm),1,1)-sigmakm)):-(J(rows(sigmahm),1,1):/(J(rows(sigmahm),1,1)-sigmahm))):/qkhgm)
				gammakhgm=(J(rows(sm),1,1):-sigmakm):*qfkhgm
				lambdakhgm=gammakhgm:/(J(rows(sm),1,1):-(dkhgm:*gammakhgm))
				gammahgm=msumfhg_post*lambdakhgm:/nmsumfkhg_post
				lambdahgm=gammahgm:/(J(rows(sm),1,1):-(dhgm:*gammahgm))
				gammagm=msumfg_post*lambdahgm:/nmsumfhg_post
				lambdagm=gammagm:/(J(rows(sm),1,1):-(dgm:*gammagm))
				gamma0m=msumf_post*lambdagm:/nmsumfg_post
				summa0m=gamma0m:/((J(rows(sm),1,1):-(d0m:*gamma0m)):*(alpham:*(1:+vatm)))
				summagm=(lambdagm:/(alpham:*(1:+vatm))):+(lambdagm:*d0m:*summa0m)
				summahgm=(lambdahgm:/(alpham:*(1:+vatm))):+(lambdahgm:*dgm:*summagm):+(lambdahgm:*d0m:*summa0m)
				summakhgm=(lambdakhgm:/(alpham:*(1:+vatm))):+(lambdakhgm:*dhgm:*summahgm):+(lambdakhgm:*dgm:*summagm):+(lambdakhgm:*d0m:*summa0m)
				pm1=mcm:+(J(rows(sm),1,1):-sigmakm):*( (J(rows(sm),1,1):/(alpham:*(1:+vatm))) :+ (dkhgm:*summakhgm) :+ (dhgm:*summahgm) :+ (dgm:*summagm) :+(d0m:*summa0m) )
				pm1=pm1:*(1:+vatm)
				mrkpm0=(pm0:/(1:+vatm)):-mcm											// net markup
				focm=(sm0)																// vector of implied first order conditions
				focm=focm :- ((alpham:*(1:+vatm)):/(J(rows(sm0),1,1):-sigmakm)):*sm0:*mrkpm0
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*dkhgm):*summakhgm
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*dhgm):*summahgm
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*dgm):*summagm
				focm=focm :+ ((alpham:*(1:+vatm)):*sm0:*d0m):*summa0m
				dif=max(abs(focm))														// objective: (abs) norm of FOC vector
				pm00=pm0
				pm0=pm1																	// updating initial prices

				// price change
				//dpm=colsum(100*((pm1:-pm):/pm):*(sm:*msizem))/colsum(sm:*msizem)
				//m,i,dif,dpm

			}	// end of i while loop (equilibrium fixed point)
			
			// price change
			dpm=colsum(100*((pm1:-pm):/pm):*(sm:*msizem))/colsum(sm:*msizem)
			//m,i,dif,dpm,damp

			// prices and shares
			p00[obsm]=pm0
			s00[obsm]=sm0
			dif00[obsm]=focm

		}	// end of simulation if condition

	}	// end of m (markets) loop 

	// exporting results into Stata
	if (mc0=="") {
		stata("capture drop __mc")
		stata("quietly generate __mc=.")
		st_store( .,"__mc",touse,mc00)
		stata("capture drop __mrkp")
		stata("quietly generate __mrkp=.")
		st_store( .,"__mrkp",touse,mrkp00)
	}
	if (onlymc0=="") {
		stata("capture drop __p_post")
		stata("quietly generate __p_post=.")
		st_store( .,"__p_post",touse,p00)
		stata("capture drop __s_post")
		stata("quietly generate __s_post=.")
		st_store( .,"__s_post",touse,s00)
		stata("capture drop __dif")
		stata("quietly generate __dif=.")
		st_store( .,"__dif",touse,dif00)
		stata("capture drop __foc_post")
		stata("quietly generate __foc_post=.")
		st_store( .,"__foc_post",touse,dif00)
	}
	if (cmce0!="") {
		stata("capture drop __mce")
		stata("quietly generate __mce=.")
		st_store( .,"__mce",touse,mce00)
	}

}	// end of merger_simulation_nlogit3 function
mata mlib add lrcl merger_simulation_nlogit3()

end
