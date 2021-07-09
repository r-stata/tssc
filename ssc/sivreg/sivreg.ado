*!version 1.1 Helmut Farbmacher (July 2018)
* 
***********************************************

prog sivreg, eclass
version 10

syntax varlist [if] [in], endog(varlist) exog(varlist) [adaptive c(real 0.1)]
marksample touse
markout `touse' `exog' `endog'
gettoken lhs varlist : varlist
qui sum `lhs' if `touse'
tempname obs
sca `obs'=r(N)
//remove collinearity
local coll `s(collinear)'
	_rmcoll `varlist' if `touse', ///
		`constan' `coll' 
	local varlist `r(varlist)'
local coll `s(collinear)'
	_rmcoll `exog' if `touse', ///
		`constan' `coll' 
	local exog `r(varlist)'
local coll `s(collinear)'
	_rmcoll `endog' if `touse', ///
		`constan' `coll' 
	local endog `r(varlist)'

//Not more than one endogenous x is allowed
tempname nu_endog
scalar `nu_endog'=`:word count `endog''
if `nu_endog'>1 {
	dis in red "Only one endogenous regressor is allowed."
	exit 103
}

//User must state for all variable whether they are endogenous or exogenous
loc all: list varlist | exog
tempname nu_all nu_endog nu_exog
scalar `nu_all'=`:word count `all''
scalar `nu_endog'=`:word count `endog''
scalar `nu_exog'=`:word count `exog''
if (`nu_endog'+`nu_exog')!=`nu_all' {
	dis in red "Each variable in `varlist' must be either in option endog() or exog()"
	exit 499
}

loc exog_xs: list varlist & exog
loc all_exog: list all-endog

//remove collinearity
local coll `s(collinear)'
	_rmcoll `all_exog' if `touse', ///
		`constan' `coll' 
	local all_exog `r(varlist)'

loc ivs: list all_exog-exog_xs

//remove collinearity
local coll `s(collinear)'
	_rmcoll `ivs' if `touse', ///
		`constan' `coll' 
	local ivs `r(varlist)'

mat b=J(1,`:word count `ivs'',0)
matname b `ivs',c(.)
tempname nu_moments nu_ivs nu_rhs
scalar `nu_moments'=`:word count `all_exog''
scalar `nu_ivs'=`:word count `ivs''
scalar `nu_rhs'=`:word count `varlist''

//Model is not identified
if `nu_rhs'>`nu_moments' {
	dis in red "There are more parameters than potential instruments. Model is not at all identified."
	exit 481
}

mat c_cons123=`c'

//hybrid
mat adaptive123=0
if "`adaptive'"!="" {
	mat adaptive123=1
}

//FWL to get rid of exog_xs
tempvar lhs_fwl endog_fwl
qui reg `lhs' `exog_xs'
qui predict `lhs_fwl', resid
qui reg `endog' `exog_xs'
qui predict `endog_fwl', resid
foreach var of varlist `ivs' {
	tempvar `var'_fwl
	qui reg `var' `exog_xs'
	qui predict ``var'_fwl', resid
	local ivs_fwl `"`ivs_fwl' ``var'_fwl'"'
}

tempname nuoverid
scalar `nuoverid'=`nu_ivs'-1

//stop if Hansen test does not reject in the first stage
qui ivregress gmm `lhs_fwl' (`endog_fwl'=`ivs_fwl')
qui scalar tau=1-`c'/ln(`obs')
if e(J)<invchi2(`nuoverid',scalar(tau)) {
	dis in red "Hansen test does not reject in the first place. No evidence for invalid instruments."
	exit 499
}

if "`adaptive'"!="" {
	dis ""
	dis "{txt}------------------------------------"
	dis "{txt}Adaptive Lasso with some invalid IVs"
	dis "{txt}------------------------------------"
}
else {
	dis ""
	dis "{txt}---------------------------"
	dis "{txt}Lasso with some invalid IVs"
	dis "{txt}---------------------------"
}

qui putmata yabc=`lhs_fwl' xabc=`endog_fwl' Zabc=(`ivs_fwl'), replace

mata {	
	n=rows(Zabc)
	m=cols(Zabc)
	c_cons=st_matrix("c_cons123")
	adaptive=st_matrix("adaptive123")
	
	//normalization
	Zabc=Zabc:-mean(Zabc)
	sZabc=sqrt(diagonal(Zabc'Zabc)/n)
	Zabc=Zabc:/sZabc'
	xabc=xabc:-mean(xabc)
	yabc=yabc:-mean(yabc)
	
	izz=luinv(Zabc'Zabc)
	pihat=izz*Zabc'xabc
	redform=izz*Zabc'yabc
										
	xhat=Zabc*pihat
	Zeta=luinv(xhat'xhat)*xhat'Zabc
	Zt=Zabc-xhat*Zeta
	
	//calculate 2SLS and 2GMM for initial Hansen statistic
	b2sls=luinv(xabc'Zabc*izz*Zabc'xabc)*(xabc'Zabc*izz*Zabc'yabc)
	u2sls=yabc-xabc*b2sls
	Zu=Zabc:*u2sls
	Wgmm=luinv(Zu'Zu)
	bgmm=luinv(xabc'Zabc*Wgmm*Zabc'xabc)*(xabc'Zabc*Wgmm*Zabc'yabc)
	
	ghat=Zabc'(yabc-xabc*bgmm)
	J=ghat'Wgmm*ghat
	Jinitial=J
	
	if (adaptive==1) {
		//median estimator to get a consistent estimate for alpha
		ratio=redform:/pihat
		betamed=mm_median(ratio)
		alphamed=redform-pihat*betamed
		vau=1
		W=diag(abs(alphamed):^vau)
	}
	else {
		W=I(m)
	}
	
	Zt=Zt*W					
	
	tau=1-c_cons/ln(n)
	if (tau<0) {
		"Note: Your choice of c leads to a negative tau; replaced by default (c=0.1)"
		tau=1-0.1/ln(n)
	}
	
	//LARS:
	kx=1
	alpha=J(m-1,m,0)
	beta=J(m-1,1,0)
	A=J(1,m,0)
	mu=J(n,1,0)
	ssval=J(1,m,1)
	steps=1	
	mR=m
	while (J>invchi2(mR-1,tau)) {
	
		cmu=Zt'(yabc-mu)/n
		
		if (kx<2) {
			c=colmaxabs(cmu)
			threshold=c/1000
			ss=(abs(round(cmu,threshold)):==round(c,threshold))'
			A=ss
			j=select((1..cols(ss)), (abs(ss) :== max(abs(ss))))
			Aset=j
		}
		else {	
			c=colmaxabs(select(cmu,ssval'))
			threshold=c/1000
			cmax=c*J(m,1,1)
			ss=(abs(reldif(cmax,abs(cmu))):<threshold)'-A
			A=(abs(reldif(cmax,abs(cmu))):<threshold)'
			j=select((1..cols(ss)), (abs(ss) :== max(abs(ss))))
			Aset=(Aset, j)
		}
		
		sign=sign(cmu)
		signA=select(sign',A)
		SA=diag(signA)
		XA=select(Zt,A)
		XA=XA*SA
		G=XA'XA/n
		iG=luinv(G)
		iota=J(cols(XA),1,1)
		B=1/sqrt(iota'iG*iota)
		w=B*iG*iota	
		u=XA*w
		b=Zt'u/n
		
		Aset_ordered=sort(Aset',1)'	
		dhat=(signA'):*w
		Dhat=J(m,1,0)
		for(j=1;j<=cols(Aset_ordered);j++) {
			jnew=Aset_ordered[j]
			Dhat[jnew]=dhat[j]	
		}
		
		//check for drops (Lasso modification) and get gammatilde
		gammatilde=.
		if (kx>1) {
			gam=alpha[max((kx-1,1)),.]:/(Dhat')
			drops = gam:<0
			if (drops!=J(1,m,0)) {
				gammatilde=rowmin(abs(select(gam,drops)))			//jump at most to where the first variable crosses zero (this is minimum absolue value of the negative numbers in length)
				if (gammatilde!=.) {
					gamtildej=select((1..m), (abs(gam) :== gammatilde))		//drop minj from selected set A
				}
			}
		}
	
		//get gammatilde
		ccm=((c:-cmu):/(B:-b))
		ccp=((c:+cmu):/(B:+b))
		ssval=J(1,cols(A),1)-A
		ccm=select(ccm',ssval)'
		ccp=select(ccp',ssval)'
		ccm=abs(ccm)+(ccm:<0)*1000000
		ccp=abs(ccp)+(ccp:<0)*1000000
		ccm=ccm+(ccm:==0)*1000000
		ccp=ccp+(ccp:==0)*1000000
		gammahat=rowmin(colmin((ccm,ccp)))	
				
		//decision rule b/w gammahat and gammatilde
		if (gammatilde<gammahat) {							//Lasso step
			steps=steps-1
			alpha=(alpha \ J(1,cols(alpha),0))
			beta=(beta \ 0)
			mu=mu+gammatilde*u
			alpha[max((kx,1)),.]=alpha[max((kx-1,1)),.]+gammatilde*Dhat'
			A[.,gamtildej]=0
			ssval[.,gamtildej]=1
			deletej=Aset:-(gamtildej:*J(1,cols(Aset),1))
			Aset=select(Aset,deletej)
		}
		else {												//LARS step
			mu=mu+gammahat*u
			alpha[max((kx,1)),.]=alpha[max((kx-1,1)),.]+gammahat*Dhat'
		}		
		
		//retrieve alpha's if adaptive lasso (Note: W=I(n) if standard (non-adaptive) Lasso)
		alpha[max((kx,1)),.]=alpha[max((kx,1)),.]*W
		
		Zcontrol_abc=select(Zabc,A)
		beta_iv=xhat'(yabc-Zabc*alpha[kx,.]')/(xhat'xhat)
		beta[kx,1]=beta_iv

		lambda_final=c
				
		kx=kx+1
		steps=steps+1
		
		//re-calculate 2SLS and 2GMM for Hansen statistic
		RX=(xabc,Zcontrol_abc)
		b2sls=luinv(RX'Zabc*izz*Zabc'RX)*RX'Zabc*izz*Zabc'yabc
		u2sls=yabc-RX*b2sls
		Zu=Zabc:*u2sls
		
		Wgmm=luinv(Zu'Zu)
		bgmm=luinv(RX'Zabc*Wgmm*Zabc'RX)*(RX'Zabc*Wgmm*Zabc'yabc)
		ghat=Zabc'(yabc-RX*bgmm)
		J=ghat'Wgmm*ghat
		mR=mR-1
		//b2sls and bgmm is already the post-Lasso estimator
		ZuuZ=Zu'Zu
		v2sls=luinv(RX'Zabc*izz*Zabc'RX)*RX'Zabc*izz*ZuuZ*izz*Zabc'RX*luinv(RX'Zabc*izz*Zabc'RX)
		
	}
blasso=(beta[kx-1],alpha[kx-1,.])

//send results to stata
vce=v2sls
st_replacematrix("b",abs(sign(blasso[|1,2 \ 1,.|])))
st_numscalar("betamed",betamed)
st_numscalar("Jinitial",Jinitial)
st_numscalar("Jdf_initial",m-1)
st_numscalar("Jp_initial",1-chi2(m-1,Jinitial))
st_numscalar("Jfinal",J)
st_numscalar("Jdf_final",mR-1)
st_numscalar("Jp_final",1-chi2(mR-1,J))
st_numscalar("lambda",lambda_final)
}

//display Lasso results
eret post b, e(`touse') depname(`lhs')
mat blasso=e(b)
dis "{txt}Lasso-based IV selection (Variables with zero coefficients are used as IVs)"
eret di

//display Post-Lasso results
dis "2SLS-Post-Lasso results - suppressing the coeff. of the invalid instruments"

tempvar touse
gen `touse'=e(sample)
eret clear
mat b=J(1,`:word count `endog'',0)
matname b `endog',c(.)
mat V=J(`:word count `endog'',`:word count `endog'',0)
matname V `endog',c(.)
matname V `endog',r(.)
mata: st_replacematrix("b",b2sls[1])
mata: st_replacematrix("V",vce[1,1])
	
eret post b V, e(`touse') depname(`lhs')
mat postlasso=e(b)
eret scalar N = `obs'
eret scalar par = `nu_rhs'
eret scalar instruments = `nu_moments'
eret scalar Jinitial = scalar(Jinitial)
eret scalar Jdf_initial = scalar(Jdf_initial)
eret scalar Jp_initial = scalar(Jp_initial)
eret scalar Jfinal = scalar(Jfinal)
eret scalar Jdf_final = scalar(Jdf_final)
eret scalar Jp_final = scalar(Jp_final)
eret scalar selected=Jdf_initial-Jdf_final
eret scalar lambda = scalar(lambda)
eret scalar postlasso=postlasso[1,1]
if "`adaptive'"!="" {
	eret scalar betamed = scalar(betamed)
}
ereturn local cmd "sivreg"
ereturn local vcetype Robust
eret di

dis "{txt}Potential instruments{txt}: {res}`ivs'"
dis "{txt}Number of obs{txt} = " as result e(N)
dis "{txt}User-specified exogenous regressors are partialled out: {res}`exog_xs' _cons"
dis "{txt}------------------------------------------------------------------------------"
dis "{txt}Hansen test of the entire set of instruments:"
dis "{txt}J(" as res e(Jdf_initial) "{txt}) = " as res %5.4f e(Jinitial) as txt " (p = " as res %5.4f e(Jp_initial) "{txt})"
dis "{txt}Hansen test of the remaining set of instruments (after Lasso selection):"
dis "{txt}J(" as res e(Jdf_final) "{txt}) = " as res %5.4f e(Jfinal) as txt " (p = " as res %5.4f e(Jp_final) "{txt})"
dis "{txt}------------------------------------------------------------------------------"
if "`adaptive'"!="" {
	dis "{txt}The median estimator is {res}" round(scalar(betamed),0.0000001)
}

end
