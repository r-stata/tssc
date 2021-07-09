
program define ivgravity, eclass

    * Gravity Fixed-effects estimators
    * By Vincenzo Verardi FNRS-UNamur and Koen Jochmans, University of Cambridge

version 13.0
	local n 0
	gettoken lhs 0 : 0, parse(" ,[") match(paren)
	IsStop `lhs'
	if `s(stop)' { 
		error 198 
	}  
	while `s(stop)'==0 {
		if "`paren'"=="(" {
			local n = `n' + 1
			if `n'>1 {
				capture noi error 198
di as error `"syntax is "(all instrumented variables = instrument variables)""'
				exit 198
			}
			gettoken p lhs : lhs, parse(" =")
			while "`p'"!="=" {
				if "`p'"=="" {
					capture noi error 198
di as error `"syntax is "(all instrumented variables = instrument variables)""'
di as error `"the equal sign "=" is required"'
					exit 198
				}
				local end`n' `end`n'' `p'
				gettoken p lhs : lhs, parse(" =")
			}
			tsunab end`n' : `end`n''
			tsunab exog`n' : `lhs'
		}
		else {
			local exog `exog' `lhs'
		}
		gettoken lhs 0 : 0, parse(" ,[") match(paren)
		IsStop `lhs'
	}
	local 0 `"`lhs' `0'"'

	tsunab exog : `exog'
	version 6: _rmcoll `exog'
	version 6: local exog=r(varlist)
	tokenize `exog'
	local lhs "`1'"
	local 1 " "
	local exog `*'

	
	// Eliminate vars from `exog1' that are in `exog'
	Subtract inst : "`exog1'" "`exog'"
	
	// `lhs' contains depvar, 
	// `exog' contains RHS exogenous variables, 
	// `end1' contains RHS endogenous variables, and
	// `inst' contains the additional instruments

	// Now parse the remaining syntax

version 6: _rmcoll `inst'
version 6: local inst=r(varlist)

cap mata: mata drop myVar()
    cap mata: mata drop QuadratifFunction()
    cap mata: mata set matafavor speed

    if replay()& "`e(cmd)'"=="twivgravity" {
        ereturn  display
        exit
    }

syntax [anything(name=0)], indm(varlist) indn(varlist) [Nose INITial(string) level(real 95)]

set level `level'
Subtract exog : "`exog'" "`end1'"
local varlist= "`lhs' `exog' `end1'"

local instruments= "`exog' `inst'"

local ninst: word count `inst'
local ninstd: word count `end1'
local df=`ninst'-`ninstd'

if `df'<0 {
di in r "The model is underidentified; more excluded instruments are needed"
exit 498
}

    capt mata mata which mm_which()
    if _rc {
        di as error "-moremata- is required; type -ssc install moremata- to obtain it"
        exit 499
    }

    capt which vlookup

    if _rc {
        di as error "vlookup is required; type -findit placevar- to obtain it"
        exit 499
    }

    tempvar gid eid touse both indn2 indm2

    mark `touse' `if' `in'
    markout `touse' `varlist'

    local dv: word 1 of `varlist'
    local exp: list varlist -dv
	local nvar: word count `exp'
	local ninst: word count `inst'

    preserve


	if "`initial'"=="" {
		tempname initial
		matrix init_MM=J(`nvar',1,0)
	}

	else {
		if rowsof(`initial')!=`nvar'&colsof(`initial')!=1 {
			noi di ""
			noi di in r "Dimension of `initial' should be `nvar'x1" 
			exit(148)
		}
		matrix init_MM=`initial'
	}

	*qui keep if `touse'
	qui gen `both'=`indm'==`indn'
	qui sum `both'
	local sl=r(sum)

	egen `indn2'=group(`indn')
	egen `indm2'=group(`indm')

	qui replace `indn'=`indn2'
	qui replace `indm'=`indm2'

	capture drop _fillin
    fillin `indm' `indn'
    capture drop _fillin
    fillin `indn'  `indm'

    egen `gid'=group(`indn')
    vlookup `indm', generate(`eid') key(`indn') value(`gid')

    qui sum `minval'

    qui reg `varlist', noc level(`level')
	local N=e(N)
    matrix b=e(b)
    matrix V=e(V)

    ereturn post b V , depname(`dv')

tempvar nose1
gen `nose1'=1

if "`nose'"!="" {
qui replace `nose1'=0
}


if `sl'==0 {
mata: reshape("`varlist'","`instruments'","`gid'","`eid'","`nose1'","`touse'")
matrix B=B'
local sargan=sargan[1,1]
noi di 

ereturn repost b=B V=V1
di in green ""
di in green "{col 55} Number of obs =" in yellow %8.0f `N'
di ""

ereturn display
local ninst: word count `inst'
local ninstd: word count `end1'
local df=`ninst'-`ninstd'

if `df'>=1 {
di "Sargan statistic (overidentification test of all instruments):        " %8.3f `sargan' 
di _col(60) "Chi-sq(`df')= " %8.3f invchi2(`df',`level'/100)
di _col(62) "P-value= " %8.3f 1-chi2(`df',`sargan')
}

if `df'==0 {
di in y "Model is just identified; no overidentifying restrictions"
}

di in smcl in gr "{hline 78}"
di "Instrumented: `end1'"
di "Included instruments: `exog'"
di "Excluded instruments: `inst'"
di in smcl in gr "{hline 78}"

if `df'>=1 {
ereturn scalar sargan=`sargan'
ereturn scalar psargan=1-chi2(`df',`sargan')
}
}

else {
di in r "Self-links are not allowed"
}

end

mata

void reshape(string scalar varlist, string scalar instruments, string scalar gid, string scalar eid, string scalar nose1, string scalar touse)
{
st_view(exp=.,.,tokens(varlist),touse)
st_view(importer=.,.,tokens(gid),touse)
st_view(exporter=.,.,tokens(eid),touse)
st_view(nose=.,.,tokens(nose1),touse)
st_view(inst=.,.,tokens(instruments),touse)
exp=(exp[,2..cols(exp)],exp[,1])
n1=max(exporter)
n2=max(importer)
n=max((n1,n2))
nvar=cols(exp)
q=cols(inst)

dX=asarray_create("real",1)
dZ=asarray_create("real",1)
for (v=1;v<=nvar;v++) {
X1=J(n,n,0)

for (i=1;i<=rows(exp);i++) {
k=exporter[i]
j=importer[i]
if (k==j) {
X1[k,j]=0
}
else {
X1[k,j]=exp[i,v]
}
}

if (v<nvar) {
X1=X1:-mean(mean(X1)')
}

X1=X1-diag(diagonal(X1))
asarray(dX,v,X1)
}

Y=asarray(dX,nvar)
asarray_remove(dX,nvar)

for (v=1;v<=q;v++) {
Z1=J(n,n,0)

for (i=1;i<=rows(inst);i++) {
k=exporter[i]
j=importer[i]
if (k==j) {
Z1[k,j]=0
}
else {
Z1[k,j]=inst[i,v]
}
}
///if (v<=q) {
///Z1=Z1:-mean(mean(Z1)')
///}

///Z1=Z1-diag(diagonal(Z1))
asarray(dZ,v,Z1)
}

psi=J(nvar-1,1,0)

///x: initial value

x=st_matrix("init_MM")
x0=x
tol=1e-5
maxit=100
smalleststep=0.5^20
it=1
condition=1
improvement=1
k=length(x)

///evaluate function

V=I(q)
Z=QuadraticForm(dX,Y,dZ,V,x)

f=asarray(Z,"criterion")
g=asarray(Z,"score")
H=asarray(Z,"Hessian")
J=asarray(Z,"H")


while (it<=maxit & condition==1 & improvement==1) {
s1=rows(H)
s2=cols(H)
if (s1==s2&s2>1) {
d=-luinv(H)*g
}

else {
d=-g:/H
}


step=1
improvement=0

while (step>=smalleststep & improvement==0) {
bounded=0

Z=QuadraticForm(dX,Y,dZ,V,x:+step*d)

ff=asarray(Z,"criterion")
gg=asarray(Z,"score")
HH=asarray(Z,"Hessian")
JJ=asarray(Z,"H")
M=asarray(Z,"S")

f0=(ff-f)/abs(f)
bounded=(missing(HH)==0)

if (f0>=-1e-5&bounded==1) {
improvement=1
condition=(sqrt(step*step*(d'*d))>tol)
condition=condition*((ff-f)>tol)
x=x+step*d
f=ff
g=gg
H=HH
J=JJ
M=asarray(Z,"S")
}

else {
step=step/2
}
it=it+1

}

}
it=it-1

V=myVar(dX,Y,dZ,x)

x=st_matrix("init_MM")
x0=x
tol=1e-5
maxit=100
smalleststep=0.5^20
it=1
condition=1
improvement=1
Z=QuadraticForm(dX,Y,dZ,V,x)

f=asarray(Z,"criterion")
g=asarray(Z,"score")
H=asarray(Z,"Hessian")
J=asarray(Z,"H")


while (it<=maxit & condition==1 & improvement==1) {
s1=rows(H)
s2=cols(H)
if (s1==s2&s2>1) {
d=-luinv(H)*g
}

else {
d=-g:/H
}


step=1
improvement=0

while (step>=smalleststep & improvement==0) {
bounded=0

Z=QuadraticForm(dX,Y,dZ,V,x:+step*d)

ff=asarray(Z,"criterion")
gg=asarray(Z,"score")
HH=asarray(Z,"Hessian")
JJ=asarray(Z,"H")
M=asarray(Z,"S")

f0=(ff-f)/abs(f)
bounded=(missing(HH)==0)

if (f0>=-1e-5&bounded==1) {
improvement=1
condition=(sqrt(step*step*(d'*d))>tol)
condition=condition*((ff-f)>tol)
x=x+step*d
f=ff
g=gg
H=HH
J=JJ
M=asarray(Z,"S")
}

else {
step=step/2
}
it=it+1

}

}
it=it-1


nn=exp(lnfactorial(rows(Y)) - (lnfactorial(2) + lnfactorial(rows(Y)-2)))
mm=exp(lnfactorial(rows(Y)-2) - (lnfactorial(2) + lnfactorial(rows(Y)-4)))
rho=nn*mm
V=myVar(dX,Y,dZ,x)
sargan = ((n*M:/rho)'*luinv(V)*(n*M:/rho))

if (sum(nose)>0) {

J=(J/rho)
Upsilon=luinv(J'*luinv(V)*J)
Upsilon=Upsilon/(n*(n-1))
se = sqrt(diagonal(Upsilon))
}

else {
Upsilon=J(k,k,0)
}

if (missing(Upsilon)>0)  {
Upsilon=J(k,k,0)
stata(`"noi di in r "Warning: Asymptotic variance could not be calculated""')
}

st_matrix("V1",Upsilon)
st_matrix("B",x)
st_matrix("sargan",sargan)
}

function QuadraticForm(dX,Y,dZ,V,psi) {
n=length(Y[,1])
m=length(Y[1,])
d=rows(psi)
q=asarray_elements(dZ)
index = J(n,n,0)

for(k=1;k<=d;k++) {
index=index+asarray(dX,k)*psi[k]
}

phi=exp(index)
error=Y:/phi

error_i=rowsum(error)
error_j=colsum(error)
m_error=colsum(rowsum(error))
d_error=asarray_create("real",1)
d_error_i=asarray_create("real",1)
d_error_j=asarray_create("real",1)
m_derror=asarray_create("real",1)

for(k=1;k<=d;k++) {
d_error_k=error:*asarray(dX,k)
asarray(d_error,k,d_error_k)

d_error_i_k=rowsum(d_error_k)
asarray(d_error_i,k,d_error_i_k)

d_error_j_k=colsum(d_error_k)
asarray(d_error_j,k,d_error_j_k)

m_derror_k=colsum(rowsum(d_error_k))
asarray(m_derror,k,m_derror_k)
}

S=J(q,1,0)

for(k=1;k<=q;k++) {
S[k] = colsum(rowsum(error:*asarray(dZ,k)))*colsum(rowsum(error)) - colsum(rowsum((error_i*error_j):*asarray(dZ,k)))
}

c_error = error*error

for(k=1;k<=q;k++) {
A = colsum(rowsum(asarray(dZ,k):*(error:*error'+c_error)))-colsum(error_j':*rowsum(asarray(dZ,k):*error))-rowsum(error_i':*colsum(asarray(dZ,k):*error))
S[k] = S[k]+ A
}

H=J(q,d,0)

for(k=1;k<=q;k++) {
for(j=1;j<=d;j++) {
H[k,j] = colsum(rowsum(asarray(dZ,k):*error:*(asarray(dX,j)*m_error:+asarray(m_derror,j)) - asarray(dZ,k):*(error_i*asarray(d_error_j,j)+asarray(d_error_i,j)*error_j)))
}
}
H = -H

c_derror=asarray_create("real",1)
for(k=1;k<=d;k++) {
c_derror_k=(error:*asarray(dX,k))*error + error*(error:*asarray(dX,k))
///c_derror_k=(error:*asarray(dX,k)):*error + error:*(error:*asarray(dX,k))
asarray(c_derror,k,c_derror_k)
}

for(k=1;k<=q;k++) {
for(j=1;j<=d;j++) {
A1 = - colsum(rowsum(asarray(dZ,k):*(error:*error'):*(asarray(dX,j)+asarray(dX,j)') + asarray(dZ,k):*asarray(c_derror,j)))
A2 = colsum(rowsum(asarray(dZ,k):*asarray(dX,j):*error):*error_j')+ rowsum(colsum(asarray(dZ,k):*asarray(dX,j):*error):*error_i')
A3 = colsum(rowsum(asarray(dZ,k):*error):*colsum(asarray(d_error,j))')+rowsum(colsum(asarray(dZ,k):*error):*rowsum(asarray(d_error,j))')
H[k,j] = H[k,j] + A1 + A2 + A3
}
}
invV=invsym(V)
criterion = -  S'*invV*S
score     = -2*H'*invV*S
Hessian   = -2*H'*invV*H
res=asarray_create()
asarray(res,"H",H)
asarray(res,"criterion",criterion)
asarray(res,"score",score)
asarray(res,"Hessian",Hessian)
asarray(res,"S",S)
return(res)
}

function myVar(dX,Y,dZ,psi) {

n=length(Y[,1])
m=length(Y[1,])
d=rows(psi)
q=asarray_elements(dZ)

index = J(n,m,0)
for(k=1;k<=d;k++) {
Xk=asarray(dX,k)
index=index+Xk*psi[k]
}

phi=exp(index)
error=Y:/phi


uXu = asarray_create("real",1)
xu = asarray_create("real",1)
xu_i= asarray_create("real",1)
xu_j= asarray_create("real",1)
xuu_j= asarray_create("real",1)
xuu_i= asarray_create("real",1)
xu_ij= asarray_create("real",1)
xu_ji= asarray_create("real",1)
uxu_ij= asarray_create("real",1)
uxu_ji= asarray_create("real",1)

u   = rowsum(colsum(error))
u_i = rowsum(error)
u_j = colsum(error)

for(k=1;k<=q;k++) {
xerror_k=error:*asarray(dZ,k)

uXu_k=error*asarray(dZ,k)'*error
asarray(uXu,k,uXu_k)

xu_k=colsum(rowsum(xerror_k))
asarray(xu,k,xu_k)

xu_i_k = rowsum(xerror_k)
asarray(xu_i,k,xu_i_k)

xu_j_k = colsum(xerror_k)
asarray(xu_j,k,xu_j_k)

xuu_j_k = colsum(asarray(dZ,k):*(u_i*J(1,m,1)))
asarray(xuu_j,k,xuu_j_k)

xuu_i_k = rowsum(asarray(dZ,k):*(J(n,1,1)*u_j))
asarray(xuu_i,k,xuu_i_k)

///xu_ij_k = asarray(dZ,k)*error'
xu_ij_k = asarray(dZ,k)*error'
asarray(xu_ij,k,xu_ij_k)

xu_ji_k = (asarray(dZ,k)'*error)'
asarray(xu_ji,k,xu_ji_k)

///uxu_ij_k = error*(asarray(dZ,k):*error)
uxu_ij_k = (error:*asarray(dZ,k))*error
asarray(uxu_ij,k,uxu_ij_k)

///uxu_ji_k = (error:*asarray(dZ,k))*error
uxu_ji_k = error*(asarray(dZ,k):*error)
asarray(uxu_ji,k,uxu_ji_k)

}

xi= asarray_create("real",1)
for(k=1;k<=q;k++) {
fullterm = error:*(asarray(dZ,k)*u:+asarray(xu,k))-(asarray(dZ,k):*(u_i*u_j)+asarray(uXu,k)) + (asarray(xu_i,k)*u_j+u_i*asarray(xu_j,k)) - error:*(asarray(xuu_i,k)*J(1,m,1)+J(n,1,1)*asarray(xuu_j,k))

A1 = asarray(dZ,k):*error:*(error'-(J(n,1,1)*u_j)'-(u_i*J(1,n,1))')
A2 = asarray(dZ,k):*(error*error)+asarray(dZ,k)':*(error:*error')
A3 = -error:*((J(n,1,1)*asarray(xu_j,k))'+(asarray(xu_i,k)*J(1,n,1))')
A4 = error:*(asarray(xu_ij,k)+asarray(xu_ji,k))
A5 = -(asarray(uxu_ij,k)+ asarray(uxu_ji,k))
A = A1+A2+A3+A4+A5
xi_k = fullterm + A
xi_k = 4*xi_k/((n-2)*(n-3))
xi_k = xi_k - diag(diag(xi_k))
asarray(xi,k,xi_k)
}

mVar=J(q,q,.)
for(k=1;k<=q;k++) {
for(j=1;j<=q;j++) {
mVar[k,j] = mean(mean(asarray(xi,k):*asarray(xi,j))')
}
}

return(mVar)
}

end


// Borrowed from ivreg.ado	
program define IsStop, sclass

	if `"`0'"' == "[" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else {
		sret local stop 0
	}

end

// Borrowed from ivreg.ado	
program define Subtract   /* <cleaned> : <full> <dirt> */

	args        cleaned     /*  macro name to hold cleaned list
		*/  colon       /*  ":"
		*/  full        /*  list to be cleaned
		*/  dirt        /*  tokens to be cleaned from full */

	tokenize `dirt'
	local i 1
	while "``i''" != "" {
		local full : subinstr local full "``i''" "", word all
		local i = `i' + 1
	}

	tokenize `full'                 /* cleans up extra spaces */
	c_local `cleaned' `*'

end
exit

