
*Wouter Gelade and Vincenzo Verardi
*Version 1.1

cap program drop mhl
program define mhl, eclass


* Medcouple
version 10.0


if replay()& "`e(cmd)'"=="mhl" {
	ereturn  display
exit
}

syntax varlist [if] [in]
marksample touse
tempname  m b V b2 V2

qui count if `touse'
local N=r(N)

ereturn clear

di ""
di ""
di "HL"
di "--"

mata: _hl("`varlist'","`touse'")
di ""
di "The robust Hodges-Lehmann location estimator is: " `m'

ereturn post, esample(`touse')
ereturn scalar hl=`m'
ereturn scalar N=`N'


end

mata:
void _hl(string scalar varlist,string scalar touse)
{
real vector X, L, R, P, Q, M, W, Z, PQ, Mp, BiggerVals
real scalar diff, C, kw, i, j, m, PT, QT, M0, posm, V, bigger

st_view(X=.,.,tokens(varlist),touse)
X=sort(X,-1)

n=rows(X)

L=J(n,1,1)
R=J(n,1,n)

P=J(n,1,.)
Q=J(n,1,.)

M=L
W=J(n,1,1)

diff=1
C=n^2

kw=n^2-(n^2-n)/2+(n^2-n)/4

while ((C>n)&(diff>0)) {

	for (i=1; i<=n; i++) {
		j=floor(L[i]+(R[i]-L[i])/2)	
		
		if (L[i]>R[i]) {
		M[i]=0
		W[i]=0
		}
		
		else {
		W[i]= R[i] - L[i] + 1
		if (W[i]!=0){
		if (W[i]/2!=round(W[i]/2)) {
		M[i]= At(X,i,j)
		}
		else {
		M[i]= (At(X,i,j)+At(X,i,j+1))/2
		}
		}
		
	}

}



m=mm_median(M,W)
	for (i=1;i<=n;i++) {
		Z=PQ(L[i],R[i],m,i,X)
		Q[i]=Z[1,1]	
		P[i]=Z[1,2]
	}
PT=sum(P)
QT=sum(Q:-1)

	if (kw<=PT) {
		if (mreldif(R,P)==0) {
		diff=0
		}
	R=P 
	}

	else if (kw>QT) {
		if (mreldif(L,Q)==0) {
		diff=0
		}
	L=Q
	}

	else {
	diff=0
	}

C=sum(R-L:+1)

} 


//Create a vector of remaining candidates for the median
Mp=0

for (i=1;i<=n;i++) {
	if (W[i,1]:>0) {
		for (j=L[i];j<=R[i]; j++) {
		M0=At(X,i,j)
		Mp=(Mp\M0)
		}
	}
}


Mp=Mp[2..rows(Mp),1]
m=max(Mp)

	for (i=1;i<=n;i++) {
		Z=PQ(L[i],R[i],m,i,X)
		Q[i]=Z[1,1]	
		P[i]=Z[1,2]
	}
	
Mp=sort(Mp,-1)
maxindex(Mp,1,r1,r2)
PT=sum(Q:-1)-rows(r1)	
	
// PT=sum(P)
// Mp=sort(Mp,-1)
if(round(kw)!=kw){
	m=Mp[ceil(kw)-PT]
}

else{
	posm = kw-PT
	if (posm > 0 & posm < rows(Mp)){
		m=(Mp[posm]+Mp[posm+1])/2
	}
	else if (posm == rows(Mp)){ //Look for the biggest element smaller than the smallest in Mp
		//("Boundary case at end of final candidates")
		m=min(Mp)
		for (i=1;i<=n;i++) {
			Z=PQ(L[i],R[i],m,i,X)
			Q[i]=Z[1,1]	
			P[i]=Z[1,2]
		}
		BiggerVals=0
		for (i=1;i<=n;i++){
			if(Q[i] <= n){
				V=At(X,i,Q[i])
				BiggerVals=(BiggerVals\V)
			}
		}
		BiggerVals=BiggerVals[2..rows(BiggerVals),1]
		bigger = max(BiggerVals)
		m = (Mp[posm]+bigger)/2
		
	}
	else if (posm == 1){ //Look for the smallest element bigger than the biggest in Mp
		//("Boundary case at beginning of final candidates")
		BiggerVals=0
		for (i=1;i<=n;i++){
			if(P[i] >= 1){
				V=At(X,i,P[i])
				BiggerVals=(BiggerVals\V)
			}
		}
		BiggerVals=BiggerVals[2..rows(BiggerVals),1]
		bigger=min(BiggerVals)
		m = (Mp[posm]+bigger)/2
	}
}

st_local("m",strofreal(m))
}
end

mata:
//Do the binary search to find the bounds for the median
real matrix PQ(real scalar L, real scalar R, real scalar m, real scalar i, real matrix X) 
{
real scalar P, Q, A1, An, k, Ak

P=0
Q=0


A1=At(X,i,1)
An=At(X,i,rows(X))


if (A1<=m) {
P=0
}
else {
	L=1
	R=rows(X)
	while (R>L+1) {
		k=floor(L+(R-L)/2)
		Ak=At(X,i,k)

		if (Ak<=m) {
		R=k
		}
		
		else if (Ak>m) {
		L=k
		}
	}	
	P=L
}
	
if (An>=m) {
	Q=rows(X)+1
		if(An>m){
		P=Q-1
		}
	}
else if (A1 < m) {
	Q = 1
}
else {
	L=1
	R=rows(X)
		while (R>L+1) {
		k=floor(L+(R-L)/2)
		Ak=At(X,i,k)

		if (Ak<m) {
		R=k
		}
		
		else if (Ak>=m) {
		L=k
		}

		}	
	Q=R
}


	
return((Q,P))
}


mata:
// Implicitly create the MC matrix
real scalar At(matrix X, scalar i, scalar j) 
{
real scalar A
if (i<j) {
A=(X[i]+X[j])/2
}

else {
A=2*X[1]+1
}
return(A)
}

end


