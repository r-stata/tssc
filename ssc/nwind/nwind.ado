*!version 1.0 Helmut Farbmacher (January 2014) // Postestimation command for ivreg2

prog nwind, eclass
version 10

if "`e(cmd)'"!="ivreg2" {
	dis as error "You have to call 'ivreg2' first."
	exit 198
}

if "`e(model)'"!="cue" | "`e(vcetype)'"!="Robust" {
	dis as error "You have to use the options 'cue' and 'robust' in the ivreg2 command."
	exit 198
}

if "`e(cons)'"=="0" {
	nwind_calc `e(depvar)' `e(instd)' `e(inexog)', endog(`e(instd)') exog(`e(insts)') cluster(`e(clustvar)') noconstant
}
else {
	nwind_calc `e(depvar)' `e(instd)' `e(inexog)', endog(`e(instd)') exog(`e(insts)') cluster(`e(clustvar)')
}

end

prog nwind_calc, eclass
syntax varlist [if] [in], [endog(varlist) exog(varlist) cluster(varname) NOCONstant]
marksample touse
markout `touse' `exog' `endog'
gettoken lhs varlist : varlist
loc rhs: list varlist | endog
loc exog_xs: list varlist & exog
loc z: list varlist | exog
loc z: list z-endog
loc ivs: list exog - exog_xs
loc endog_x: list rhs - exog_xs

if "`noconstant'"!="" {
	mat b=J(1,`:word count `rhs'',0)
	mat V=J(`:word count `rhs'',`:word count `rhs'',0)
	matname b `rhs',c(.)
	matname V `rhs',c(.)
	matname V `rhs',r(.)
}
else {
	mat b=J(1,`:word count `rhs' _cons',0)
	mat V=J(`:word count `rhs' _cons',`:word count `rhs' _cons',0)
	matname b `rhs' _cons,c(.)
	matname V `rhs' _cons,c(.)
	matname V `rhs' _cons,r(.)
}

//nocons
mat nocons123=0
if "`noconstant'"!="" {
	mat nocons123=1
}

mat beta123=e(b)
	
dis ""
dis as text "Newey and Windmeijer's (2009) standard errors:"

if "`cluster'"=="" {
	tempvar cluster
	gen `cluster'=_n
	local nocluster="1"
}

mat numi=J(1,1,.)

tempvar touse
gen `touse'=e(sample)
mata: ivp2_nwind("`cluster'","`lhs'","`rhs'","`z'","`touse'")
	
//output
eret post b V, e(`touse') depname(`lhs')
eret di

if "`nocluster'"=="" {
	dis "Number of clusters = {res}" numi[1,1]
}

end

*** Mata ***
************

mata:
//calculate Newey and Windmeijer's (2009) SE
void ivp2_nwind(string scalar idvar,string scalar lhs,string scalar rhs,string scalar z, string scalar ok)
{
external y,X,Z,W

// id & panel setup
st_view(id,.,idvar,ok)
panel = panelsetup(id,1)
panelst = panelstats(panel)
numi = panelst[1]
st_replacematrix("numi",numi)

y=st_data(.,tokens(lhs),ok)
nocons=st_matrix("nocons123")
if (nocons==1) {
	X=st_data(.,tokens(rhs),ok)
	Z=st_data(.,tokens(z),ok)
}
if (nocons==0) {
	cons=J(rows(y),1,1)
	X=st_data(.,tokens(rhs),ok),cons
	Z=st_data(.,tokens(z),ok),cons
}

p=st_matrix("beta123")
par=cols(X)

mend=J(cols(Z),1,0)
Wend=J(cols(Z),cols(Z),0)
eps=y :- X*p'
m=quadcross(Z,eps)/rows(panel)
Zu_N=J(rows(panel),cols(Z),.)
for(i=1; i<=numi; i++) {
	epsi = eps[|panel[i,1],1 \ panel[i,2],1|]
	Zi = Z[|panel[i,1],1 \ panel[i,2],cols(Z)|]
	Zu_N[i,.]=quadcross(Zi,epsi)'
}
Wend = quadcross(Zu_N,Zu_N)		
W = luinv((1/rows(panel))*Wend)

//Hessian
G=quadcross(Z,-X)
H=quadcross(G,W)*G/rows(panel)

for (j=1; j<=par; j++) {
	
	lambdaj=J(cols(Z),cols(Z),0)
	for(i=1; i<=numi; i++) {
		epsi = eps[|panel[i,1],1 \ panel[i,2],1|]
		Xj = -X[|panel[i,1],j \ panel[i,2],j|]
		Zi = Z[|panel[i,1],1 \ panel[i,2],cols(Z)|]	
		lambdaj = lambdaj + quadcross(quadcross(quadcross(Zi,Xj)',epsi')',Zi)/rows(panel)		
	}
		
	for (k=1; k<=par; k++) {
		H[j,k] = H[j,k] - G[.,k]'*W*(lambdaj+lambdaj')*W*m
	}
	
	for (i=1; i<=numi; i++) {
		epsi = eps[|panel[i,1],1 \ panel[i,2],1|]
		Xi = X[|panel[i,1],1 \ panel[i,2],cols(X)|]
		Zi = Z[|panel[i,1],1 \ panel[i,2],cols(Z)|]
		
		for (k=1; k<=par; k++) {
			lambdak = -quadcross(quadcross(quadcross(Zi,Xi[.,k])',epsi')',Zi)/rows(panel)			
			dellambda_jk=quadcross(quadcross(quadcross(Zi,Xi[.,j])',Xi[.,k]')',Zi)/rows(panel)		
			
			H[j,k] = H[j,k] - G[.,j]'*W*(lambdak+lambdak')*W*m + rows(panel)*m'*W*(lambdak+lambdak')*W*(lambdaj+lambdaj')*W*m - rows(panel)*m'*W*dellambda_jk*W*m			
		}			
	}	
}

Hes=H/rows(panel)

S=J(cols(Z),par,.)		
for (j=1; j<=par; j++) {
	//fill S		
	s1=(1/rows(panel))*quadcross(Z,((-X[.,j])))		
	lambdaj=J(cols(Z),cols(Z),0)
	for(i=1; i<=numi; i++) {
		epsi = eps[|panel[i,1],1 \ panel[i,2],1|]
		Xj = -X[|panel[i,1],j \ panel[i,2],j|]
		Zi = Z[|panel[i,1],1 \ panel[i,2],cols(Z)|]	
		lambdaj = lambdaj + quadcross(quadcross(quadcross(Zi,Xj)',epsi')',Zi)/rows(panel)		
	}
	s2=quadcross(quadcross(lambdaj',W)',m)
	s=s1-s2
	S[.,j]=s
	}

middle=quadcross(quadcross(S,W)',S)	
vce=(1/rows(panel))*(quadcross(quadcross(luinv(Hes)',middle)',luinv(Hes)))
_makesymmetric(vce)

st_replacematrix("b",p)
st_replacematrix("V",vce)

}

end

