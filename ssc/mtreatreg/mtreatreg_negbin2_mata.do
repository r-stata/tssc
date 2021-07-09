*! version 2.0.0 09jul2009
*! author: Partha Deb
* version 1.1.0 25feb2009
* version 1.0.0 04feb2009

************************************************
*** mata function for joint mmlogit & negbin2***
************************************************

clear all
version 10.1
local mydir "."

capture mata drop mtreatreg_negbin2_lf

mata:
void mtreatreg_negbin2_lf(
	string scalar lnL, string scalar G, string scalar H
	, string scalar xbTnames, string scalar xbOname
	, string scalar alphaname, string scalar lamnames
	, string scalar neq, string scalar neqall, string scalar nobs, string scalar sim
	, real matrix yT, real matrix yO, real matrix rmat)

{ // begin function
	K = st_numscalar(neq)
	Ka = st_numscalar(neqall)
	N = st_numscalar(nobs)
	S = st_numscalar(sim)

	st_view(xbT, ., tokens(xbTnames))
	st_view(xbO, ., xbOname)
	st_view(vlnL, ., lnL)
	st_view(vg, ., tokens(G))
	st_view(vH, ., tokens(H))

	st_view(alpha, ., alphaname)
	st_view(lam, ., tokens(lamnames))

	exb = J(N,S*K,.)
	pmml = J(N,S*K,.)
	den = J(N,S,1)
	for (j=1; j<=K; j++) {
		exb[,((j-1)*S+1)..(j*S)] = exp(xbT[,j]:+rmat[,((j-1)*S+1)..(j*S)])
		den = den + exb[,((j-1)*S+1)..(j*S)]
	}

	mml = (1:-rowsum(yT)):/den
	for (j=1; j<=K; j++) {
		pmml[,((j-1)*S+1)..(j*S)] = exb[,((j-1)*S+1)..(j*S)]:/den
		mml = mml :+ yT[,j]:*pmml[,((j-1)*S+1)..(j*S)]
	}

	psi = 1:/alpha

	xbOmat = J(N,S,0)
	for (j=1; j<=S; j++) {
		xbOmat[,j] = xbO[,]
	}
	for (j=1; j<=K; j++) {
		xbOmat = xbOmat + lam[,j]:*rmat[,((j-1)*S+1)..(j*S)]
	}
	mu = exp(xbOmat)
	yOmmu = yO:-mu
	muppsi = mu:+psi
	psidmuppsi = psi:/muppsi
	lpalphamu = 1:+alpha:*mu
	nb2 = exp(lngamma(yO:+psi) :- lngamma(psi) :-  lngamma(yO:+1)  ///
							:+ psi:*ln(psidmuppsi) :+ yO:*ln(mu:/(muppsi)) )

	mmlnb2 = mml :* nb2
	L = (rowsum(mmlnb2))/S
	L=rowmax((L , J(N,1,smallestdouble())))
	vlnL[,] = ln(L)


	gmml = J(N,S*K,.)
	for (j=1; j<=K; j++) {
		gmml[,((j-1)*S+1)..(j*S)] = yT[,j] :- pmml[,((j-1)*S+1)..(j*S)]
		vg[,j] = (1:/L):*rowsum(mmlnb2:*gmml[,((j-1)*S+1)..(j*S)])/S
	}
	gnbb = yOmmu:/lpalphamu
	gnba =  -(digamma(yO:+psi) :- digamma(psi) :+ log(psidmuppsi) ///
					:+ 1 :- (yO:+psi):/muppsi):*psi
	vg[,K+1] = (1:/L):*rowsum(mmlnb2:*gnbb)/S
	vg[,K+2] = (1:/L):*rowsum(mmlnb2:*gnba)/S
	for (k=K+3; k<=Ka; k++) {
		vg[,k] = (1:/L):*rowsum(mmlnb2:*gnbb:*rmat[,((k-K-3)*S+1)..((k-K-2)*S)])/S
	}



	for (k=1; k<=K; k++) {
		for (j=k; j<=K; j++) {
			hmml = -pmml[,((j-1)*S+1)..(j*S)] ///
						:*((j==k):-pmml[,((k-1)*S+1)..(k*S)])
			h = (-vg[,j]:*vg[,k] + (1:/L):*rowsum(mmlnb2 ///
			:*gmml[,((j-1)*S+1)..(j*S)]:*gmml[,((k-1)*S+1)..(k*S)])/S ///
					:+ (1:/L):*rowsum(mmlnb2:*hmml)/S)
			ss = Ka*(k-1) - (k-2)*(k-1)/2 + (j-k) + 1
			vH[,ss] = h
		}
	}

	hnbbb = -mu:*(1:+alpha:*yO):/(lpalphamu:^2)
	hnbba = -yOmmu:/(lpalphamu:^2):*mu:*alpha
	hnbaa = gnba :+ (psi:^2) :*(trigamma(yO:+psi) :- trigamma(psi) ///
						:+ 1:/psi :- 2:/muppsi :+ psidmuppsi:/muppsi :+ yO:/(muppsi:^2))
	h = (-vg[,K+1]:*vg[,K+1] + (1:/L):*rowsum(mmlnb2:*gnbb:*gnbb)/S ///
			+ (1:/L):*rowsum(mmlnb2:*hnbbb)/S)
	ss = Ka*((K+1)-1) - ((K+1)-2)*((K+1)-1)/2 + 1
	vH[,ss] = h

	for (k=1; k<=K; k++) {
		h = (-vg[,K+1]:*vg[,k] + (1:/L):*rowsum(mmlnb2 ///
		:*gnbb:*gmml[,((k-1)*S+1)..(k*S)])/S)
		ss = Ka*(k-1) - (k-2)*(k-1)/2 + ((K+1)-k) + 1
		vH[,ss] = h
	}

	h = (-vg[,K+2]:*vg[,K+1] + (1:/L):*rowsum(mmlnb2:*gnba:*gnbb)/S ///
			+ (1:/L):*rowsum(mmlnb2:*hnbba)/S)
	ss = Ka*((K+1)-1) - ((K+1)-2)*((K+1)-1)/2 + 1 + 1
	vH[,ss] = h

	for (k=1; k<=K; k++) {
		h = (-vg[,K+2]:*vg[,k] + (1:/L):*rowsum(mmlnb2 ///
		:*gnba:*gmml[,((k-1)*S+1)..(k*S)])/S)
		ss = Ka*(k-1) - (k-2)*(k-1)/2 + (K+2-k) + 1
		vH[,ss] = h
	}

	for (j=K+3; j<=Ka; j++) {
		h = -vg[,j]:*vg[,K+1] ///
			+ (1:/L):*rowsum(mmlnb2:*gnbb:*gnbb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S ///
			+ (1:/L):*rowsum(mmlnb2:*hnbbb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S
		ss = Ka*((K+1)-1) - ((K+1)-2)*((K+1)-1)/2 + (j-K-1) + 1
		vH[,ss] = h
		for (k=1; k<=K; k++) {
			h = -vg[,j]:*vg[,k] ///
			+ (1:/L):*rowsum(mmlnb2:*gmml[,((k-1)*S+1)..(k*S)] ///
				:*gnbb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S
			ss = Ka*(k-1) - (k-2)*(k-1)/2 + (j-k) + 1
			vH[,ss] = h
		}
	}

	h = -vg[,K+2]:*vg[,K+2] + (1:/L):*rowsum(mmlnb2:*gnba:*gnba)/S ///
			+ (1:/L):*rowsum(mmlnb2:*hnbaa)/S
	ss = Ka*((K+2)-1) - ((K+2)-2)*((K+2)-1)/2 + 1
	vH[,ss] = h

	for (j=K+3; j<=Ka; j++) {
		h = -vg[,j]:*vg[,K+2] ///
			+ (1:/L):*rowsum(mmlnb2:*gnbb:*gnba:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S ///
			+ (1:/L):*rowsum(mmlnb2:*hnbba:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S
		ss = Ka*((K+2)-1) - ((K+2)-2)*((K+2)-1)/2 + (j-K-2) + 1
		vH[,ss] = h
	}

	for (k=K+3; k<=Ka; k++) {
		for (j=k; j<=Ka; j++) {
			h = -vg[,j]:*vg[,k] ///
				+ (1:/L):*rowsum(mmlnb2:*gnbb:*gnbb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)] ///
				:*rmat[,((k-K-3)*S+1)..((k-K-2)*S)])/S ///
				:+ (1:/L):*rowsum(mmlnb2:*hnbbb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)] ///
				:*rmat[,((k-K-3)*S+1)..((k-K-2)*S)])/S
		ss = Ka*(k-1) - (k-2)*(k-1)/2 + (j-k) + 1
		vH[,ss] = h
		}
	}

} // end function

mata mosave mtreatreg_negbin2_lf(), dir(`mydir') replace

end

