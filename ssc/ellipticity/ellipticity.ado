*Vincenzo Verardi and Catherine Vermandele
*Version 1.1

program define ellipticity, rclass


* Ellipticity test 


version 10.0


if replay()& "`e(cmd)'"=="ellipticity" {
	ereturn  display
exit
}

syntax varlist [if] [in], [level(real 0.95) Robust Sphericity]
tempvar touse
tempname S mu A
mark `touse' `if' `in'
markout `touse' `varlist' 

local nw: word count `varlist'
if `nw'<2 {
di in r "Error: At least two variables are needed for this test"
exit 198
}

if `level'>=1|`level'<=0 {
di in r "The level option should be between 0 and 1"
exit 198
}

_rmcoll `varlist' if  `touse'
local varlist =r(varlist)

if "`robust'"!=""&"`sphericity'"=="" {
di""
di "Test, H0: Robust Ellipticity"
di "----------------------------"
smultiv `varlist' if `touse'
matrix `S'=e(S)
matrix `mu'=e(mu)
mata: ellip("`varlist'","`touse'")
}

if "`robust'"!=""&"`sphericity'"!="" {
di""
di "Test, H0: Robust Sphericity"
di "---------------------------"
smultiv `varlist' if `touse'
matrix `S'=e(S)
matrix `S'=I(rowsof(`S'))
matrix `mu'=e(mu)
mata: spher("`varlist'","`touse'")
}

if "`robust'"==""&"`sphericity'"!="" {
di""
di "Test, H0: Sphericity"
di "--------------------"

qui matrix accum `S'=`varlist' if `touse', mean(`mu') noc
matrix `S'=I(colsof(`mu'))

mata: spher("`varlist'","`touse'")
}

if "`robust'"==""&"`sphericity'"=="" {
di""
di "Test, H0: Ellipticity"
di "---------------------"

qui matrix accum `S'=`varlist' if `touse', mean(`mu') noc
matrix `S'=I(colsof(`mu'))

mata: ellip("`varlist'","`touse'")
}


local p=chi2tail(`df',`Q')
return clear

return scalar p=`p'
return scalar df =`df'
return scalar crit =`crit'
return scalar Q =`Q'

di ""
di "Q=" round(`Q',.01)
di "chi2(" `df' ")=" round(`crit',.01)
di "p-value=" round(`p',.001)

end


mata:
void spher(string scalar varlist,string scalar touse)

{
st_view(X=.,.,tokens(varlist),touse)
level = strtoreal(st_local("level"))
a=strtoreal(st_local("a"))
k0=strtoreal(st_local("k0"))

sigma=st_matrix(st_local("S"))
mu=st_matrix(st_local("mu"))

n=rows(X)
k=cols(X)

U=(X:-mu)

st_matrix("U",U)
Z=U*U'

d=sqrt(diagonal(Z))

R=mm_ranks(d)

Q=J(n,n,0)


R=R/(rows(R)+1)
quant=invchi2(k,R)

	for (i=1;i<=n;i++) {
		for (j=i;j<=n;j++) {
		Q[i,j]=quant[i,1]*quant[j,1]*((Z[i,j]/(d[i,]*d[j,]))^2-(1/k))
		}
	}
	
Q=makesymmetric(Q')
Q=sum(Q)/(2*n)
df=(k*(k+1)/2)-1
crit=invchi2(df,level)

st_local("Q",strofreal(Q))
st_local("df",strofreal(df))
st_local("crit",strofreal(crit))
}

end

mata:
void ellip(string scalar varlist,string scalar touse)

{
st_view(X=.,.,tokens(varlist),touse)
level = strtoreal(st_local("level"))
a=strtoreal(st_local("a"))
k0=strtoreal(st_local("k0"))

sigma=st_matrix(st_local("S"))
mu=st_matrix(st_local("mu"))

n=rows(X)
k=cols(X)

ck1=4*exp(lngamma(k/2))
ck2=((k^2)-1)*sqrt(pi())*exp(lngamma((k-1)/2))
ck=ck1/ck2


Z=(matpowersym(sigma,-0.5)*(X:-mu)')'

df1init=df1(mu,sigma,X)
df3init=df3(mu,sigma,X)

crit=1
beta1=0
lc=1000
dcrit=0

jj=0
while(dcrit<=10) {
jj=jj+1
beta1=beta1+jj*lc
mupert=(mu':+(n^(-0.5)*beta1*k):*(sigma*df1init'))'
df1pert=df1(mupert,sigma,X)
crit=df1pert*sigma*df1init'
	if (crit<0) {
	crit=1
	beta1=beta1-jj*lc
	lc=lc/10
	dcrit=dcrit+1
	jj=0

	}
}


crit=1
beta2=0
lc=1000
dcrit=0

jj=0
while(dcrit<=10) {
jj=jj+1
beta2=beta2+jj*lc
mupert=(mu':-(n^(-0.5)*(beta2/ck)):*(matpowersym(sigma,0.5)*df3init'))'

df3pert=df3(mupert,sigma,X)
crit=df3pert*df3init'
if (crit<0) {
	crit=1
	beta2=beta2-jj*lc
	lc=lc/10
	dcrit=dcrit+1
	jj=0
	}

}


eta=beta1/beta2

Su=J(rows(X),cols(X),1)
d=Su[,1]
U=Su
		for (i=1; i<=n; i++) {
		d[i,]=norm(Z[i,])
		U[i,]=Z[i,]/(d[i,])
		}

Su=(U:^2):*sign(U)

R=mm_ranks(d)
R=R/(rows(R)+1)
quant=invchi2(k,R)

dphi=(1/sqrt(n))*colsum(quant:^(0.5):*(k*ck*eta:*U-quant:^(0.5):*Su))
r= J(1,1,1..n)'/(n+1)
quant2=invchi2(k,r)
gamma1=quant2:*(k*(ck^2)*(eta^2))
gamma2=quant2:*(2*k*(ck^2)*eta:*sqrt(quant2))
gamma3=quant2:*(3/(k*(k+2))):*quant2

gamma=(sum(gamma1-gamma2+gamma3)/n)*I(k)
Q=dphi*invsym(gamma)*dphi'

df=k
crit=invchi2(df,level)

st_local("Q",strofreal(Q))
st_local("df",strofreal(df))
st_local("crit",strofreal(crit))
}
end

mata:
real matrix df1(real matrix mu, real matrix sigma, real matrix X) {

Z=(matpowersym(sigma,-0.5)*(X:-mu)')'
Su=J(rows(X),cols(X),1)
d=Su[,1]
U=Su

	for (i=1; i<=rows(X); i++) {
	d[i,]=norm(Z[i,])
	U[i,]=Z[i,]/(d[i,])
	}

Su=(U:^2):*sign(U)

R=mm_ranks(d)
R=R/(rows(R)+1)
quant=invchi2(cols(X),R)
return(rows(X)^(-0.5)*colsum(sqrt(quant):*U))
}
end

mata:
real matrix df3(real matrix mu, real matrix sigma, real matrix X) {

Z=(matpowersym(sigma,-0.5)*(X:-mu)')'
Su=J(rows(X),cols(X),1)
d=Su[,1]
U=Su

	for (i=1; i<=rows(X); i++) {
	d[i,]=norm(Z[i,])
	U[i,]=Z[i,]/(d[i,])
	}

Su=(U:^2):*sign(U)

R=mm_ranks(d)
R=R/(rows(R)+1)
quant=invchi2(cols(X),R)
return(-rows(X)^(-0.5)*colsum(quant:*Su))
}
end

