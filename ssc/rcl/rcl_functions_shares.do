
**********************************
* Mata funcitons: predicted shares
**********************************

mata:

mata clear

// predicted market shares: simple logit model (one market)
pointer vector shatm_logit(
	real colvector pm0,
	real colvector xbm0,
	real colvector ksim0,
	real colvector alpham0)
{

	// declarations
	real colvector deltam,shatm

	// predicted market shares
	deltam=(-alpham0:*pm0):+(xbm0):+(ksim0)										// mean utility
	shatm=exp(deltam)
	shatm=shatm:/(1:+colsum(shatm))												// predicted choice probabilities

	return(shatm)

}	// end of shatm_logit function
mata mlib add lrcl shatm_logit()


// predicted market shares: one-level nested logit model (one market)
pointer vector shatm_nlogit(
	real colvector pm0,
	real colvector xbm0,
	real colvector ksim0,
	real colvector alpham0,
	real colvector sigmagm0,
	real matrix msumg)
{

	// declarations
	real colvector deltam,shatm,shatgm,shatjgm,dgm,dgms

	// predicted market shares
	deltam=(-alpham0:*pm0):+(xbm0):+(ksim0)										// mean utility
	shatjgm=exp((deltam):/(1:-sigmagm0))										// predicted within nest choice probabilities
	dgm=msumg*shatjgm
	shatjgm=shatjgm:/dgm
	dgms=dgm:^(1:-sigmagm0)
	shatgm=dgms:/(1:+colsum(uniqrows(dgms)))									// predicted nest choice probabilities
	shatm=shatjgm:*shatgm														// predicted choice probabilities

	return(shatm)

}	// end of shatm_nlogit function
mata mlib add lrcl shatm_nlogit()


// predicted market shares: two-level nested logit model (one market)
pointer vector shatm_nlogit2(
	real colvector pm0,
	real colvector xbm0,
	real colvector ksim0,
	real colvector alpham0,
	real colvector sigmagm0,
	real colvector sigmahm0,
	real matrix msumg,
	real matrix msumhg)
{

	// declarations
	real colvector deltam,shatm,shatgm,shathgm,shatjhm,dhgm,dhgms,dgm,dgms

	// predicted market shares
	deltam=(-alpham0:*pm0):+(xbm0):+(ksim0)										// mean utility
	shatjhm=exp((deltam):/(1:-sigmahm0))										// predicted within subnest choice probabilities
	dhgm=msumhg*shatjhm
	shatjhm=shatjhm:/dhgm
	dhgms=dhgm:^( (1:-sigmahm0):/(1:-sigmagm0) )
	dgm=uniqrows((msumg,dhgms))
	dgm=dgm[.,1..cols(msumg)]'*dgm[.,cols(msumg)+1..cols(dgm)]
	shathgm=dhgms:/dgm															// predicted subnest choice probabilities
	dgms=dgm:^(1:-sigmagm0)
	shatgm=dgms:/(1:+colsum(uniqrows(dgms)))									// predicted nest choice probabilities
	shatjgm=shatjhm:*shathgm													// predicted within nest choice probabilities
	shatm=shatjhm:*shathgm:*shatgm												// predicted choice probabilities

	return(shatm)

}	// end of shatm_nlogit2 function
mata mlib add lrcl shatm_nlogit2()


// predicted market shares: three-level nested logit model (one market)
pointer vector shatm_nlogit3(
	real colvector pm0,
	real colvector xbm0,
	real colvector ksim0,
	real colvector alpham0,
	real colvector sigmagm0,
	real colvector sigmahm0,
	real colvector sigmakm0,
	real matrix msumg,
	real matrix msumhg,
	real matrix msumkhg)
{

	// declarations
	real colvector deltam,shatm,shatgm,shathgm,shatjhm,dhgm,dhgms,dgm,dgms

	// predicted market shares
	deltam=(-alpham0:*pm0):+(xbm0):+(ksim0)										// mean utility
	shatjkm=exp((deltam):/(1:-sigmakm0))										// predicted within sub-subnest choice probabilities
	dkhgm=msumkhg*shatjkm
	shatjkm=shatjkm:/dkhgm
	dkhgms=dkhgm:^( (1:-sigmakm0):/(1:-sigmahm0) )
	dhgm=uniqrows((msumhg,dkhgms))
	dhgm=dhgm[.,1..cols(msumhg)]'*dhgm[.,cols(msumhg)+1..cols(dhgm)]
	shatkhgm=dkhgms:/dhgm														// predicted sub-subnest choice probabilities
	dhgms=dhgm:^( (1:-sigmahm0):/(1:-sigmagm0) )
	dgm=uniqrows((msumg,dhgms))
	dgm=dgm[.,1..cols(msumg)]'*dgm[.,cols(msumg)+1..cols(dgm)]
	shathgm=dhgms:/dgm															// predicted subnest choice probabilities
	dgms=dgm:^(1:-sigmagm0)
	shatgm=dgms:/(1:+colsum(uniqrows(dgms)))									// predicted nest choice probabilities
	shatm=shatjkm:*shatkhgm:*shathgm:*shatgm									// predicted choice probabilities

	return(shatm)

}	// end of shatm_nlogit3 function
mata mlib add lrcl shatm_nlogit3()


// predicted market shares: random coefficient logit (BLP) model (one market)
pointer vector shatm_blp(
	real colvector pm,
	real matrix xd0m,
	real colvector ksim,
	real matrix rcm,
	real matrix simdraws,
	real rowvector params,
	real colvector beta,
	real scalar _is_rc_on_p)
{

	// declarations
	real matrix mum,shatim
	real colvector sigmas,shatm,im,deltam
	real scalar alpha

	// parameters
	sigmas=params[1,1..cols(rcm)]'													// vector of random coefficient parameters
	alpha=-beta[1,1]																// (negative of) coefficient on price
	if (_is_rc_on_p==1) {
		alphai=alpha:-(params[1,1]*simdraws[1,.])									// individual price coefficients (if there is random coefficient on price)
	}
	if (_is_rc_on_p==0) {
		alphai=alpha:*J(1,cols(simdraws),1)											// individual price coefficients (if there is no random coefficient on price)
	}

	// predicted market shares
	if (_is_rc_on_p==1) {
		rcm[.,1]=pm																	// updating random coefficient variables (replacing the first column with prices of the current iteration)
	}
	mum=rcm*((sigmas):*simdraws[1..rows(simdraws)-1,.])								// matrix of observed consumer heterogeneity (separate column for each consumer)
	deltam=(pm,xd0m)*(beta):+ksim													// mean utilities
	shatim=exp(deltam:+mum)															// predicted individual within nest choice probabilities
	shatim=replace_matrix(shatim,.,exp(709))										// treating numerical overflow
	shatim=shatim:/(1:+colsum(shatim))												// predicted individual choice probabilities
	shatm=shatim*simdraws[rows(simdraws),.]'										// predicted market shares

	return(shatm)

}	// end of shatm_blp function
mata mlib add lrcl shatm_blp()

end
