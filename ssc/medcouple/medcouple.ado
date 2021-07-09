
*Wouter Gelade, Vincenzo Verardi and Catherine Vermandele
*Version 1.1

cap program drop medcouple
program define medcouple, eclass


* Medcouple


version 10.0


if replay()& "`e(cmd)'"=="medcouple" {
	ereturn  display
exit
}

syntax varlist [if] [in], [lmc rmc NOmc]
marksample touse
tempvar touse2 touse3
tempname m b V b2 V2
pause on

di ""
di ""
di "MEDCOUPLE"
di "---------"

qui sum `varlist' if `touse', detail
if r(min) == r(p50) {
	di in r "Median equal to minimum; no medcouple computed"
	exit 498
} 
else if r(max) == r(p50) {
	di in r "Median equal to maximum; no medcouple computed"
	exit 498
}
ereturn clear

qui count if `touse'
local N=r(N)

else {
*ereturn post, esample(`touse')

if "`nomc'"=="" {
mata: _mc("`varlist'","`touse'")
di ""
di "The medcouple is: " `m'
local mc=`m'

ereturn scalar mc=`mc'

}

if "`lmc'"!="" {

qui sum `varlist' if `touse', det
gen `touse2'=`touse'*(`varlist'<r(p50))
qui sum `touse2'
mata: _mc("`varlist'","`touse2'")
local lmc=-`m'
di ""
di "The left medcouple is: " `lmc'
ereturn scalar lmc =`lmc'

}

if "`rmc'"!="" {
qui sum `varlist' if `touse', det
gen `touse3'=`touse'*(`varlist'>r(p50))
qui sum `touse3'
mata: _mc("`varlist'","`touse3'")
local rmc=`m'
di ""
di "The right medcouple is: " `rmc'
*ereturn post, esample(`touse')
ereturn scalar rmc =`rmc'

}

ereturn scalar N=`N'
}


end

mata:
void _mc(string scalar varlist,string scalar touse)
{
real vector Z, L, R, P, Q, M, W, PT, QT, Mp, BiggerVals
real scalar i, d, nz, n, q, diff, C, j, Zplus, Zminus, M0, r1, r2, posm, V, bigger	

st_view(X=.,.,tokens(varlist),touse)
Z=sort(X:-mm_median(X),-1)

i=.
d=.
maxindex((Z:<0), 1, i, d)
Zminus=Z[i]
maxindex((Z:>0), 1, i, d)
Zplus=Z[i]

maxindex((Z:==0), 1, i, d)
nz=sum((Z:==0))

n=rows(Zplus)+nz
q=rows(Zminus)+nz

L=J(n,1,1)
R=J(n,1,q)

P=J(n,1,.)
Q=J(n,1,.)

M=L
W=J(n,1,1)

diff=1
C=n^2

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
		M[i]= At(Zplus,Zminus,nz,i,j)
		}
		else {
		M[i]= (At(Zplus, Zminus,nz,i,j)+At(Zplus, Zminus,nz,i,j+1))/2
		}
		}
	}
}

//(L,R,M,W)
m=mm_median(M,W)
	for (i=1;i<=n;i++) {
		Z=PQ(L[i],R[i],m,i,Zplus,Zminus,nz)
		Q[i]=Z[1,1]	
		P[i]=Z[1,2]
	}

PT=sum(P)
QT=sum(-Q:+q+1)


	if (n*q/2<=PT) {
		if (mreldif(R,P)==0) {
			diff=0
		}
		R=P
		if (n*q/2==PT) {
			for (i=1;i<=n;i++){
				if (R[i]<q){
					if (At(Zplus,Zminus,nz,i,R[i]+1)==m){
					R[i]=P[i]+1
					}
				}
			}
		}
	}
	
	else if (n*q/2<=QT) {
		if (mreldif(L,Q)==0) {
			diff=0
		}
		L=Q
		if (n*q/2==QT) {
			for (i=1;i<=n;i++){
				if (L[i]>1){
					if (At(Zplus,Zminus,nz,i,L[i]-1)==m){
					L[i]=Q[i]-1
					}
				}
			}
		}
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
		M0=At(Zplus, Zminus,nz,i,j)
		Mp=(Mp\M0)
		}
	}
}

Mp=Mp[2..rows(Mp),1]
m=max(Mp)
	for (i=1;i<=n;i++) {
		Z=PQ(L[i],R[i],m,i,Zplus,Zminus,nz)
		Q[i]=Z[1,1]	
		P[i]=Z[1,2]
	}
Mp=sort(Mp,-1)
maxindex(Mp,1,r1,r2)
PT=sum(Q:-1)-rows(r1)

if (n*q/2==round(n*q/2)) {
	posm = (n*q/2)-PT
	if (posm > 0 & posm < rows(Mp)){
		m=(Mp[posm]+Mp[posm+1])/2
	}
	else if (posm == rows(Mp)){ //Look for the biggest element smaller than the smallest in Mp
		//("Boundary case at end of final candidates")
		m=min(Mp)
		for (i=1;i<=n;i++) {
			Z=PQ(L[i],R[i],m,i,Zplus,Zminus,nz)
			Q[i]=Z[1,1]	
			P[i]=Z[1,2]
		}
		BiggerVals=0
		for (i=1;i<=n;i++){
			if(Q[i] <= q){
				V=At(Zplus,Zminus,nz,i,Q[i])
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
				V=At(Zplus, Zminus,nz,i,P[i])
				BiggerVals=(BiggerVals\V)
			}
		}
		BiggerVals=BiggerVals[2..rows(BiggerVals),1]
		bigger=min(BiggerVals)
		m = (Mp[posm]+bigger)/2
	}
}

else {
m=Mp[ceil(n*q/2)-PT]
}

st_local("m",strofreal(m))
}
end

mata:
//Do the binary search to find the bounds for the median
real matrix PQ(real scalar L, real scalar R, real scalar m, real scalar i, real matrix Zplus, real matrix Zminus, real scalar nz) 
{
real scalar P, Q, A1, An, k, Ak

P=0
Q=0


A1=At(Zplus, Zminus,nz,i,1)
An=At(Zplus, Zminus,nz,i,rows(Zminus)+nz)


if (A1<=m) {
P=0
}
else {
	L=1
	R=rows(Zminus)+nz
	while (R>L+1) {
		k=floor(L+(R-L)/2)
		Ak=At(Zplus,Zminus,nz,i,k)

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
	Q=rows(Zminus)+nz+1
		if(An>m){
		P=Q-1
		}
	}
else if (A1 < m) {
	Q = 1
}
else {
	L=1
	R=rows(Zminus)+nz
		while (R>L+1) {
		k=floor(L+(R-L)/2)
		Ak=At(Zplus,Zminus,nz,i,k)

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
real scalar At(matrix Zplus, matrix Zminus, scalar nz, scalar i, scalar j) 
{
real scalar A
			if ((i<=rows(Zplus))&(j<=nz)) {
			A=1
			}
			if ((i>rows(Zplus))&(j>nz)) {
			A=-1
			}
			if ((i>rows(Zplus))&(j<=nz)) {
			A=(i+j-1<rows(Zplus)+nz)+(i+j-1>rows(Zplus)+nz)*(-1)
			}	
			if ((i<=rows(Zplus))&(j>nz)) {
			A=(Zplus[i]+Zminus[j-nz])/(Zplus[i]-Zminus[j-nz])
			}
return(A)
}

end


