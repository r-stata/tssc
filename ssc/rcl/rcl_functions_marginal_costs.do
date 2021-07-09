
*********************************
* Mata funcitons: marginal costs
*********************************

mata:

mata clear


// implied marginal costs: simple logit model (one market)
real colvector marginal_cost_logit(real colvector sm,
									real colvector pm,
									real colvector msizem,
									real colvector vatm,
									real colvector alpham,
									real matrix msumf)
{

	// declarations
	real colvector qm,qfm,d0m,summa0m,mrkpm,mcm

	// quantity variables
	qm=sm:*msizem																// quantity
	qfm=msumf*qm																// firms' sum of quantities

	// implied marginal cost
	d0m=J(rows(sm),1,1):/msizem
	summa0m=qfm:/((J(rows(sm),1,1):-(d0m:*qfm)):*(alpham:*(1:+vatm)))
	mrkpm=( (J(rows(sm),1,1):/(alpham:*(1:+vatm))) :+(d0m:*summa0m) )
	mcm=(pm:/(1:+vatm)):-mrkpm

	return(mcm)
}					// end of marginal_cost_logit function
mata mlib add lrcl marginal_cost_logit()


// implied marginal costs: one-level nested logit model (one market)
real colvector marginal_cost_nlogit(real colvector sm,
									real colvector pm,
									real colvector msizem,
									real colvector vatm,
									real colvector alpham,
									real colvector sigmagm,
									real matrix msumf,
									real matrix msumg,
									real matrix msumfg,
									real colvector nmsumfg)
{

	// declarations
	real colvector qm,qgm,qfgm,d0m,dgm,gammagm,lambdagm,gamma0m,summa0m,summagm,mrkpm,mcm
	
	// quantity variables
	qm=sm:*msizem																// quantity
	qgm=msumg*qm																// sum of quantities in groups
	qfgm=msumfg*qm																// firms' sum of quantities in groups

	// implied marginal cost
	d0m=J(rows(sm),1,1):/msizem
	dgm=((sigmagm:/(J(rows(sm),1,1):-sigmagm)):/qgm)
	gammagm=(J(rows(sm),1,1):-sigmagm):*qfgm
	lambdagm=gammagm:/(J(rows(sm),1,1):-(dgm:*gammagm))
	gamma0m=msumf*lambdagm:/nmsumfg
	summa0m=gamma0m:/((J(rows(sm),1,1):-(d0m:*gamma0m)):*(alpham:*(1:+vatm)))
	summagm=(lambdagm:/(alpham:*(1:+vatm))):+(lambdagm:*d0m:*summa0m)
	mrkpm=(J(rows(sm),1,1):-sigmagm):*( (J(rows(sm),1,1):/(alpham:*(1:+vatm))) :+ (dgm:*summagm) :+(d0m:*summa0m) )
	mcm=(pm:/(1:+vatm)):-mrkpm

	return(mcm)
}					// end of marginal_cost_nlogit function
mata mlib add lrcl marginal_cost_nlogit()


// implied marginal costs: two-level nested logit model (one market)
real colvector marginal_cost_nlogit2(real colvector sm,
									real colvector pm,
									real colvector msizem,
									real colvector vatm,
									real colvector alpham,
									real colvector sigmagm,
									real colvector sigmahm,
									real matrix msumf,
									real matrix msumg,
									real matrix msumhg,
									real matrix msumfg,
									real matrix msumfhg,
									real colvector nmsumfg,
									real colvector nmsumfhg)
{

	// declarations
	real colvector qm,qgm,qhgm,qfhgm,d0m,dgm,dhgm,gammaghm,lambdahgm,gammagm,lambdagm,gamma0m,summa0m,summagm,summahgm,mrkpm,mcm
	
	// quantity variables
	qm=sm:*msizem																// quantity
	qgm=msumg*qm																// sum of quantities in groups
	qhgm=msumhg*qm																// sum of quantities in subgroups
	qfhgm=msumfhg*qm															// firms' sum of quantities in subgroups

	// implied marginal cost
	d0m=J(rows(sm),1,1):/msizem
	dgm=((sigmagm:/(J(rows(sm),1,1):-sigmagm)):/qgm)
	dhgm=(((J(rows(sigmahm),1,1):/(J(rows(sigmahm),1,1)-sigmahm)):-(J(rows(sigmagm),1,1):/(J(rows(sigmagm),1,1)-sigmagm))):/qhgm)
	gammahgm=(J(rows(sm),1,1):-sigmahm):*qfhgm
	lambdahgm=gammahgm:/(J(rows(sm),1,1):-(dhgm:*gammahgm))
	gammagm=msumfg*lambdahgm:/nmsumfhg
	lambdagm=gammagm:/(J(rows(sm),1,1):-(dgm:*gammagm))
	gamma0m=msumf*lambdagm:/nmsumfg
	summa0m=gamma0m:/((J(rows(sm),1,1):-(d0m:*gamma0m)):*(alpham:*(1:+vatm)))
	summagm=(lambdagm:/(alpham:*(1:+vatm))):+(lambdagm:*d0m:*summa0m)
	summahgm=(lambdahgm:/(alpham:*(1:+vatm))):+(lambdahgm:*dgm:*summagm):+(lambdahgm:*d0m:*summa0m)
	mrkpm=(J(rows(sm),1,1):-sigmahm):*( (J(rows(sm),1,1):/(alpham:*(1:+vatm))) :+ (dhgm:*summahgm) :+ (dgm:*summagm) :+(d0m:*summa0m) )
	mcm=(pm:/(1:+vatm)):-mrkpm

	return(mcm)
}					// end of marginal_cost_nlogit2 function
mata mlib add lrcl marginal_cost_nlogit2()


// implied marginal costs: three-level nested logit model (one market)
real colvector marginal_cost_nlogit3(real colvector sm,
									real colvector pm,
									real colvector msizem,
									real colvector vatm,
									real colvector alpham,
									real colvector sigmagm,
									real colvector sigmahm,
									real colvector sigmakm,
									real matrix msumf,
									real matrix msumg,
									real matrix msumhg,
									real matrix msumkhg,
									real matrix msumfg,
									real matrix msumfhg,
									real matrix msumfkhg,
									real colvector nmsumfg,
									real colvector nmsumfhg,
									real colvector nmsumfkhg)
{

	// declarations
	real colvector qm,qgm,qhgm,qkhgm,qfkhgm,d0m,dgm,dhgm,dkhgm,gammagkhm,lambdakhgm,gammaghm,lambdahgm,gammagm,lambdagm,gamma0m,summa0m,summagm,summahgm,summakhgm,mrkpm,mcm

	// quantity variables
	qm=sm:*msizem																	// quantity
	qgm=msumg*qm																	// sum of quantities in groups
	qhgm=msumhg*qm																	// sum of quantities in subgroups
	qkhgm=msumkhg*qm																// sum of quantities in sub-subgroups
	qfkhgm=msumfkhg*qm																// firms' sum of quantities in sub-subgroups

	// implied marginal cost
	d0m=J(rows(sm),1,1):/msizem
	dgm=((sigmagm:/(J(rows(sm),1,1):-sigmagm)):/qgm)
	dhgm=(((J(rows(sigmahm),1,1):/(J(rows(sigmahm),1,1)-sigmahm)):-(J(rows(sigmagm),1,1):/(J(rows(sigmagm),1,1)-sigmagm))):/qhgm)
	dkhgm=(((J(rows(sigmakm),1,1):/(J(rows(sigmakm),1,1)-sigmakm)):-(J(rows(sigmahm),1,1):/(J(rows(sigmahm),1,1)-sigmahm))):/qkhgm)
	gammakhgm=(J(rows(sm),1,1):-sigmakm):*qfkhgm
	lambdakhgm=gammakhgm:/(J(rows(sm),1,1):-(dkhgm:*gammakhgm))
	gammahgm=msumfhg*lambdakhgm:/nmsumfkhg
	lambdahgm=gammahgm:/(J(rows(sm),1,1):-(dhgm:*gammahgm))
	gammagm=msumfg*lambdahgm:/nmsumfhg
	lambdagm=gammagm:/(J(rows(sm),1,1):-(dgm:*gammagm))
	gamma0m=msumf*lambdagm:/nmsumfg
	summa0m=gamma0m:/((J(rows(sm),1,1):-(d0m:*gamma0m)):*(alpham:*(1:+vatm)))
	summagm=(lambdagm:/(alpham:*(1:+vatm))):+(lambdagm:*d0m:*summa0m)
	summahgm=(lambdahgm:/(alpham:*(1:+vatm))):+(lambdahgm:*dgm:*summagm):+(lambdahgm:*d0m:*summa0m)
	summakhgm=(lambdakhgm:/(alpham:*(1:+vatm))):+(lambdakhgm:*dhgm:*summahgm):+(lambdakhgm:*dgm:*summagm):+(lambdakhgm:*d0m:*summa0m)
	mrkpm=(J(rows(sm),1,1):-sigmakm):*( (J(rows(sm),1,1):/(alpham:*(1:+vatm))) :+ (dkhgm:*summakhgm) :+ (dhgm:*summahgm) :+ (dgm:*summagm) :+(d0m:*summa0m) )
	mcm=(pm:/(1:+vatm)):-mrkpm

	return(mcm)
}					// end of marginal_cost_nlogit3 function
mata mlib add lrcl marginal_cost_nlogit3()


// implied marginal costs: BLP model (one market)
real colvector marginal_costm_blp(real colvector pm,
								real colvector msizem,
								real colvector vatm,
								real matrix rcm,
								real colvector deltam,
								real colvector firmm,
								real rowvector params,
								real matrix simdraws,
								real scalar alpha,
								real rowvector alphai,
								real matrix msumf)
{

	// declarations
	real matrix mum,shatim,ashatim,sashatim,dsdp,dsdpmsumf,idsdpmsumf
	real colvector shatm,mcm,mrkpm,firm1m,i,obsmm
	real scalar ff,sf

	// identifier of single product firms on a given market
	firm1m=J(rows(firmm),1,0)
	obsmm=runningsum(J(rows(firmm),1,1))
	for (ff=colmin(firmm); ff<=colmax(firmm); ff++) {
		i=(firmm:==ff)
		if (sum(i[select(obsmm,i:==1),1])==1) {
			firm1m=firm1m:+i
		}
	}

	// predicted market shares
	mum=rcm*((params'):*simdraws[1..rows(simdraws)-1,.])							// matrix of observed consumer heterogeneity (separate column for each consumer)
	shatim=exp(deltam:+mum)															// predicted individual choice probabilities
		shatim=shatim:/(1:+colsum(shatim))
	shatm=shatim*simdraws[rows(simdraws),.]'										// predicted market shares

	mcm=J(rows(deltam),1,0)															// implied marginal costs (to be filled up)
	mrkpm=J(rows(deltam),1,0)														// implied markups (to be filled up)
	// auxiliary variables
	ashatim=alphai:*shatim
	sashatim=(ashatim)*simdraws[rows(simdraws),.]'
	dsdp=(ashatim:*(simdraws[rows(simdraws),.]))*(shatim') :- diag(sashatim)	// matrix of price derivatives
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
	// markup (given intial prices)
	mrkpm=(-idsdpmsumf)*(shatm:/(1:+vatm))
	mcm=(pm:/(1:+vatm)):-mrkpm

	return(mcm)

}	// end of marginal_costm_blp function
mata mlib add lrcl marginal_costm_blp()


// implied marginal costs: BLP model (all markets)
real colvector marginal_cost_blp(real colvector market,
								real colvector p,
								real colvector msize,
								real colvector vat,
								real matrix rc,
								real colvector delta,
								real colvector firm,
								real rowvector params,
								real matrix simdraws,
								real scalar alpha,
								real rowvector alphai)
{

	// declarations
	real matrix msumf,mum,shatim,ashatim,sashatim,dsdp,dsdpmsumf,idsdpmsumf
	real colvector shatm,mcm,mrkpm,firm1m,i,obsmm,firmm,msizem,pm,deltam,rcm,obsm,obs,mc
	real scalar m,ff,sf
	
	// index of observations
	obs=runningsum(J(rows(market),1,1))
	
	// marginal costs
	mc=J(rows(market),1,.)															// implied marginal costs (to be filled up)

	for (m=colmin(market); m<=colmax(market); m++) {								// calcualtions by markets

		// variables for market m
		firmm=select(firm,market:==m)
		msizem=select(msize,market:==m)
		pm=select(p,market:==m)
		deltam=select(delta,market:==m)
		rcm=select(rc,market:==m)
		vatm=select(vat,market:==m)
		obsm=select(obs,market:==m)
		productm=runningsum(J(rows(firmm),1,1))

		// product ownership matrix
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

		// predicted market shares
		mum=rcm*((params'):*simdraws[1..rows(simdraws)-1,.])							// matrix of observed consumer heterogeneity (separate column for each consumer)
		shatim=exp(deltam:+mum)															// predicted individual choice probabilities
			shatim=shatim:/(1:+colsum(shatim))
		shatm=shatim*simdraws[rows(simdraws),.]'										// predicted market shares

		// auxiliary variables
		ashatim=alphai:*shatim
		sashatim=(ashatim)*simdraws[rows(simdraws),.]'
		dsdp=(ashatim:*(simdraws[rows(simdraws),.]))*(shatim') :- diag(sashatim)	// matrix of price derivatives
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
		// markup (given intial prices)
		mrkpm=(-idsdpmsumf)*(shatm:/(1:+vatm))
		mcm=(pm:/(1:+vatm)):-mrkpm
		mc[obsm]=mcm

	}

	return(mc)

}	// end of marginal_cost_blp function
mata mlib add lrcl marginal_cost_blp()

end
