*! version 2.0.0 09jul2009
*! author: Partha Deb
* version 1.1.0 25feb2009
* version 1.0.0 04feb2009

************************************************
*** mata function for mixed logit            ***
************************************************

clear all
version 10.1
local mydir "."


capture mata drop mtreatreg_mmlogit_lf

mata:
void mtreatreg_mmlogit_lf(
	string scalar lnL, string scalar G, string scalar H
	, string scalar xbTnames, string scalar neq, string scalar nobs, string scalar sim
	, real matrix yT, real matrix rmat)

{ // begin function
	K = st_numscalar(neq)
	N = st_numscalar(nobs)
	S = st_numscalar(sim)

	st_view(xbT, ., tokens(xbTnames))
	st_view(vlnL, ., lnL)
	st_view(vg, ., tokens(G))
	st_view(vH, ., tokens(H))

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

	L = (rowsum(mml))/S
	L=rowmax((L , J(N,1,smallestdouble())))
	vlnL[,] = ln(L)


	gmml = J(N,S*K,.)
	for (j=1; j<=K; j++) {
		gmml[,((j-1)*S+1)..(j*S)] = yT[,j] :- pmml[,((j-1)*S+1)..(j*S)]
		vg[,j] = (1:/L):*rowsum(mml:*gmml[,((j-1)*S+1)..(j*S)])/S
	}


	for (k=1; k<=K; k++) {
		for (j=k; j<=K; j++) {
			hmml = -pmml[,((j-1)*S+1)..(j*S)] ///
						:*((j==k):-pmml[,((k-1)*S+1)..(k*S)])
			h = (-vg[,j]:*vg[,k] + (1:/L):*rowsum(mml ///
			:*gmml[,((j-1)*S+1)..(j*S)]:*gmml[,((k-1)*S+1)..(k*S)])/S ///
					:+ (1:/L):*rowsum(mml:*hmml)/S)
			ss = K*(k-1) - (k-2)*(k-1)/2 + (j-k) + 1
			vH[,ss] = h
		}
	}

} // end function

mata mosave mtreatreg_mmlogit_lf(), dir(`mydir') replace

end
