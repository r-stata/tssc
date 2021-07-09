*! ivactest 1.0.6 CFB/MES 28Dec2012
* Cumby-Huizinga general specification test of serial correlation after IV estimation
* Econometrica, 60:1, 1992, 185-195
* 1.0.0: 27Jan2007 
* 1.0.1: 31Jan2007 switch to Bartlett weights if Psi not p.d.;
*        allow for N=0 (regress without robust vce)
* 1.0.2: 02Feb2007 Fold in ivsc logic for i.i.d. errors
* 1.0.3: 04Feb2007 correct handling of A, disallow cluster
* 1.0.4: 14jul2007 guard against multiple panels, corrgram under if
* 1.0.5: 19Aug2007 Added trap for partialling-out by ivreg2
* 1.0.6: 28Dec2012 Added support for ivreg29, bug fix (wrong saved matrix used after ivreg2)

program define ivactest, rclass
	version 9.2
	syntax [, q(integer 0) s(integer 1) ]

* C-H stat apparently not-invariant to partialling-out, so not supported
	if "`e(fwlcons)'" != ""  | (e(partial_ct)>0 & e(partial_ct)<.) {
di in r "ivactest not allowed after ivreg2 with partialling-out option"
		error 499
	}

	tempvar touse
	gen byte `touse'=e(sample)

* validate onepanel
	qui tsset
	if "`r(panelvar)'" ~= "" {
		su `r(panelvar)' if `touse', meanonly
		if `r(min)' ~= `r(max)' {
			di as err "Sample may not include multiple panels."
			error 198
		}
	}
			
	if "`e(cmd)'" ~= "ivreg2" & "`e(cmd)'" ~= "ivreg28" & "`e(cmd)'" ~= "ivreg29" & 	///
		"`e(cmd)'" ~= "ivreg" & "`e(cmd)'" ~= "regress" & 								///
		 "`e(cmd)'" ~= "newey" & "`e(cmd)'" ~= "newey2" {
		di as err "`e(cmd)' not supported by ivactest"
		exit 198
	}
	local cmd `e(cmd)'

	tempvar uhat
	qui predict double `uhat' if `touse', resid
	
* number of ACs to be tested 
	if `s' < 1 {
		di as err "s invalid"
		exit 198
	}
* offset: start testing at lag q+1
	if `q' < 0 {
		di as err "q=`q' invalid"
		exit 198
	}
* generate required lags of residual vector
	local llo = `q' + 1
	local lhi = `q' + `s' 
	forvalues i = `llo'/`lhi' {
		tempvar uq
		qui gen double `uq'=L`i'.`uhat' if `touse'
		qui replace `uq'=0 if `uq'==. & `uhat'<. & `touse'
		local capuhat "`capuhat' `uq'"
	}
* calculate ACs up to lhi for specified sample
	qui corrgram `uhat' if `touse', lags(`lhi')
	tempname ac
	mat `ac' = r(AC)

	local x : colnames(e(b))
	local x : subinstr local x "_cons" "", count(local cons)
	
* was previous estimate robust, cluster, AC or HAC?
	local noniid 0
	if "`e(vcetype)'" == "Robust" | "`e(kernel)'" ~= "" {
		local noniid 1
	}
* was previous estimate cluster? disallow
	if "`e(clustvar)'" != "" {
		di as err "ivactest cannot handle cluster-robust VCE."
		exit 198
	}
* was previous estimate Newey-West?
	if "`e(vcetype)'" == "Newey-West" {
		local noniid 1
		local bw `e(lag)'+1
	}
* if previous estimate iid, disallow q>0
	if !`noniid' & `q'>0 {
		di as err "ivactest only supports q>0 for non-i.i.d. vce estimates."
		exit 198
	}
* define the z matrix
	if "`e(cmd)'" == "ivreg2" | "`e(cmd)'" == "ivreg" {
		local z "`e(insts)'"
	}
	else if "`e(cmd)'" == "regress" | "`e(cmd)'" == "newey" | "`e(cmd)'" == "newey2" {
		local z "`x'"
	}
	else {
		di as err "ivactest error"
		exit 198
	}

* add constant to both x and z if present in reglist	
	if `cons'==1 {
		tempvar one
		qui gen byte `one'=1 if `touse'
		local x "`x' `one'"
		local z "`z' `one'"
	}

	tsrevar `x'
	local x "`r(varlist)'"
	tsrevar `z'
	local z "`r(varlist)'"

//  N: limit on terms entering Psi
//  re choice of N, see Cumby/Huizinga, NBER TWP 92 (1990) and
//  Anderson, 1971, Statistical Analysis of Time Series
	
//  set N to T^0.25 if noniid
	qui count if `touse'
	local N = cond(`noniid',ceil(r(N)^0.25),0)

	mata: ivacstat("`x'", "`z'", `q', `s', "`uhat'", "`capuhat'", "`cmd'", "`touse'", `N')

	tempname lqs lqsp kernwt bw
	scalar `lqs'=r(lqs)
	scalar `lqsp'=chiprob(`s',`lqs')
	local kernwt "`r(kernwt)'"
	scalar `bw'=r(bw)
	
	di _n
	di _c "Cumby-Huizinga test with H0: errors nonautocorrelated at order `llo'"
	if `lhi'>`llo' {
		di ".." `lhi'
	}
	else {
		di
	}

	di "Test statistic:  " `lqs'
	di "Under H0, Chi-sq(`s') with p-value:  " `lqsp' 
	return scalar chi2=`lqs'
	return scalar p=`lqsp'
	return scalar df=`s'
	return scalar minlag=`llo'
	return scalar maxlag=`lhi'
	return local kernwt = "`kernwt'"
	return scalar bw=`bw'
end

mata:
void ivacstat(string scalar xvars, 
				string scalar zvars,
				real scalar q, 
				real scalar s, 
				string scalar uvars, 
				string scalar capuvars, 
				string scalar cmd, 
				string scalar touse,
				real scalar N)
{
	xv=tokens(xvars)
	vx= xv[|1,.|]
	zv=tokens(zvars)
	vz= zv[|1,.|]
	uv=tokens(uvars)
	vu= uv[|1,.|]
	capuv=tokens(capuvars)
	vg= capuv[|1,.|]

	st_view(X=.,.,vx,touse)
	st_view(Z=.,.,vz,touse)
	st_view(uhat=.,.,vu,touse)
	st_view(capuhat=.,.,vg,touse)

	T=rows(uhat)
	h=cols(Z)
	
	if (N==0) {
// branch on N=0 (iid errors)
// code from MES ivsc.ado 1.0.01 24Jan2007
	zz=Z'Z
	pz=Z*invsym(zz)*Z'
	xhat=pz*X
	xhxhinv=invsym(xhat'xhat)
	Q = I(T) - X*xhxhinv*xhat' - xhat*xhxhinv*X' + X*xhxhinv*X'
	uQu=capuhat'*Q*capuhat
	sigma2=uhat'uhat/T
	sc = uhat'*capuhat*invsym(uQu)*capuhat'*uhat / sigma2
	st_numscalar("r(lqs)", sc)
	st_numscalar("r(bw)", N)
	}
	else {

		allr = st_matrix(st_local("ac"))
		qmax = q + s

// (9)
		r = allr[|(q+1)\qmax|]'

// (22)
		sigma2 = uhat' uhat / T	

// (23) depends on capuhat
		bhat = - (capuhat' X / T) / sigma2 

// (5) construct A: e(W) for ivreg2 
		if (cmd=="ivreg2" | cmd=="ivreg28" | cmd=="ivreg29") {
			A = st_matrix("e(S)")
		}

// X'X/T for regress
		else if (cmd=="regress") {
			A = X'X/T
		}
// Z'Z/T for ivreg
		else {
			A = Z'Z/T
		}
		Ainv = invsym(A)

// (24)
		dhat = T * invsym(X' Z * Ainv * Z' X) * X' Z * Ainv

// (19)
		ul = bhat * dhat
		ur = J(s,s,0)
		ll = J(s,h,0)
		lr = I(s) / sigma2
		phi = (ul, ur \ ll, lr)

// (25)
		eta1 = uhat :* Z
		eta2 = uhat :* capuhat
		eta = (eta1, eta2)'

// (26) Gaussian weight = 1 for n = 0
		R0 = J((s+h),(s+h),0)
		for(t=1;t<T;t++) {
			R0 = R0 + eta[,t]*eta[,t]'
		}
		R0 = R0 :/ T
		psi = R0
		pointer(real matrix) rowvector pvecp
		pointer(real matrix) rowvector pvecm
		pvecp = J(1,N,NULL)
		pvecm = J(1,N,NULL)
	
		for(i=1;i<=N;i++) {
			RP = J((s+h),(s+h),0)
			RM = J((s+h),(s+h),0)
			for(t=i+1;t<T;t++) {
				RP = RP + eta[,t]*eta[,(t-i)]'
			}
			pvecp[i] = &(RP :/ T)
			for(t=1;t<=(T-i);t++) {
				RM = RM + eta[,t]*eta[,(t+i)]'
			}
			pvecm[i] = &(RM :/ T)	
		}

// (27) apply Gaussian weights (fn 15)
		tnsq = 2*N^2

		for(i=1;i<=N;i++) {
			psi = psi + exp(-i^2/tnsq) * (*pvecp[i] + *pvecm[i])
		}
//  check psi for p.d.; on failure recalc with Bartlett weights
//  per NBER TWP 92, p.16
		if (det(psi) <= 0) {
			psi = R0
			for(i=1;i<=N;i++) {
				psi = psi + (N-i+1)/(N+1) * (*pvecp[i] + *pvecm[i])
			}
			st_global("r(kernel)","Bartlett")
		}
		else {
			st_global("r(kernel)","Gaussian")
		}
		st_numscalar("r(bw)",N)

// (20)
		ppp = phi * psi * phi'

//  extract s x s submatrices from this matrix and form the test stat
		vr = ppp[|(s+1,s+1)\(2*s,2*s)|]
		bvb = ppp[|(1,1)\(s,s)|]
		bdc = ppp[|(1,s+1)\(s,2*s)|]
		cdb = bdc'

// prop 2 test stat
		pr2inv = invsym(vr + bvb + cdb + bdc)
		T = rows(X)
		lqs = T * r' * pr2inv * r
		st_numscalar("r(lqs)",lqs)
	}
}
end

