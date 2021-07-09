*! version 2.0.0 09jul2009
*! author: Partha Deb
* version 1.1.0 25feb2009
* version 1.0.0 04feb2009

************************************************
*** mata function for joint mmlogit & gamma  ***
************************************************

clear all
version 10.1
local mydir "."

capture mata drop mtreatreg_gamma_lf

mata:
void mtreatreg_gamma_lf(
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

	xbOmat = J(N,S,0)
	for (j=1; j<=S; j++) {
		xbOmat[,j] = xbO[,]
	}
	for (j=1; j<=K; j++) {
		xbOmat = xbOmat + lam[,j]:*rmat[,((j-1)*S+1)..(j*S)]
	}
	mu = exp(xbOmat)
	gamma = gammaden(alpha,mu,0,yO) 

	mmlgamma = mml :* gamma
	L = (rowsum(mmlgamma))/S
	L=rowmax((L , J(N,1,smallestdouble())))
	vlnL[,] = ln(L)


	gmml = J(N,S*K,.)
	for (j=1; j<=K; j++) {
		gmml[,((j-1)*S+1)..(j*S)] = yT[,j] :- pmml[,((j-1)*S+1)..(j*S)]
		vg[,j] = (1:/L):*rowsum(mmlgamma:*gmml[,((j-1)*S+1)..(j*S)])/S
	}
	ggb = -alpha :+ yO:/mu
	gga =  (-digamma(alpha) :- xbOmat :+ log(yO)):*alpha
	vg[,K+1] = (1:/L):*rowsum(mmlgamma:*ggb)/S
	vg[,K+2] = (1:/L):*rowsum(mmlgamma:*gga)/S
	for (k=K+3; k<=Ka; k++) {
		vg[,k] = (1:/L):*rowsum(mmlgamma:*ggb:*rmat[,((k-K-3)*S+1)..((k-K-2)*S)])/S
	}



	for (k=1; k<=K; k++) {
		for (j=k; j<=K; j++) {
			hmml = -pmml[,((j-1)*S+1)..(j*S)] ///
						:*((j==k):-pmml[,((k-1)*S+1)..(k*S)])
			h = (-vg[,j]:*vg[,k] + (1:/L):*rowsum(mmlgamma ///
			:*gmml[,((j-1)*S+1)..(j*S)]:*gmml[,((k-1)*S+1)..(k*S)])/S ///
					:+ (1:/L):*rowsum(mmlgamma:*hmml)/S)
			ss = Ka*(k-1) - (k-2)*(k-1)/2 + (j-k) + 1
			vH[,ss] = h
		}
	}

	hgbb = - yO:/mu
	hgba = -alpha
	hgaa = (-digamma(alpha) :- xbOmat :+ log(yO) ///
			:- trigamma(alpha):*alpha):*alpha
	h = (-vg[,K+1]:*vg[,K+1] + (1:/L):*rowsum(mmlgamma:*ggb:*ggb)/S ///
			+ (1:/L):*rowsum(mmlgamma:*hgbb)/S)
	ss = Ka*((K+1)-1) - ((K+1)-2)*((K+1)-1)/2 + 1
	vH[,ss] = h

	for (k=1; k<=K; k++) {
		h = (-vg[,K+1]:*vg[,k] + (1:/L):*rowsum(mmlgamma ///
		:*ggb:*gmml[,((k-1)*S+1)..(k*S)])/S)
		ss = Ka*(k-1) - (k-2)*(k-1)/2 + ((K+1)-k) + 1
		vH[,ss] = h
	}

	h = (-vg[,K+2]:*vg[,K+1] + (1:/L):*rowsum(mmlgamma:*gga:*ggb)/S ///
			+ (1:/L):*rowsum(mmlgamma:*hgba)/S)
	ss = Ka*((K+1)-1) - ((K+1)-2)*((K+1)-1)/2 + 1 + 1
	vH[,ss] = h

	for (k=1; k<=K; k++) {
		h = (-vg[,K+2]:*vg[,k] + (1:/L):*rowsum(mmlgamma ///
		:*gga:*gmml[,((k-1)*S+1)..(k*S)])/S)
		ss = Ka*(k-1) - (k-2)*(k-1)/2 + (K+2-k) + 1
		vH[,ss] = h
	}

	for (j=K+3; j<=Ka; j++) {
		h = -vg[,j]:*vg[,K+1] ///
			+ (1:/L):*rowsum(mmlgamma:*ggb:*ggb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S ///
			+ (1:/L):*rowsum(mmlgamma:*hgbb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S
		ss = Ka*((K+1)-1) - ((K+1)-2)*((K+1)-1)/2 + (j-K-1) + 1
		vH[,ss] = h
		for (k=1; k<=K; k++) {
			h = -vg[,j]:*vg[,k] ///
			+ (1:/L):*rowsum(mmlgamma:*gmml[,((k-1)*S+1)..(k*S)] ///
				:*ggb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S
			ss = Ka*(k-1) - (k-2)*(k-1)/2 + (j-k) + 1
			vH[,ss] = h
		}
	}

	h = -vg[,K+2]:*vg[,K+2] + (1:/L):*rowsum(mmlgamma:*gga:*gga)/S ///
			+ (1:/L):*rowsum(mmlgamma:*hgaa)/S
	ss = Ka*((K+2)-1) - ((K+2)-2)*((K+2)-1)/2 + 1
	vH[,ss] = h

	for (j=K+3; j<=Ka; j++) {
		h = -vg[,j]:*vg[,K+2] ///
			+ (1:/L):*rowsum(mmlgamma:*ggb:*gga:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S ///
			+ (1:/L):*rowsum(mmlgamma:*hgba:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)])/S
		ss = Ka*((K+2)-1) - ((K+2)-2)*((K+2)-1)/2 + (j-K-2) + 1
		vH[,ss] = h
	}

	for (k=K+3; k<=Ka; k++) {
		for (j=k; j<=Ka; j++) {
			h = -vg[,j]:*vg[,k] ///
				+ (1:/L):*rowsum(mmlgamma:*ggb:*ggb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)] ///
				:*rmat[,((k-K-3)*S+1)..((k-K-2)*S)])/S ///
				:+ (1:/L):*rowsum(mmlgamma:*hgbb:*rmat[,((j-K-3)*S+1)..((j-K-2)*S)] ///
				:*rmat[,((k-K-3)*S+1)..((k-K-2)*S)])/S
		ss = Ka*(k-1) - (k-2)*(k-1)/2 + (j-k) + 1
		vH[,ss] = h
		}
	}

} // end function

mata mosave mtreatreg_gamma_lf(), dir(`mydir') replace

end

