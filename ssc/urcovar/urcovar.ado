program drop _all
mata: mata clear

*! urcovar 1.0.0  29apr2007 CFBaum
*! from G. Elliott and M. Jansson, Testing for unit roots with 
*! stationary covariates, J. Econometrics 115, 75-89, 2003.
*! 1.0.1: 21jul2007 use tempnames for scalars, fix ts handling, add returns

program urcovar, rclass
	version 9.2
	syntax varlist(min=2 ts) [if] [in], [MAXLag(int 1) CASE(int 1) FIRSTobs]

	marksample touse
	_ts timevar panelvar `if' `in', sort onepanel
    markout `touse' `timevar'

// case 1: no deterministic terms (noconstant)
// cases 2,3: constants
// cases 4,5: constants and time trends

	local con
	local trend
	tempname cbar rho lambda cvint r2
	scalar `lambda' = .
	scalar `cvint' = .
	scalar `r2' = .
	
	if(`case'==1) {
		local con "noco"
	}
	if(`case'<=3) {
		scalar `cbar' = -7
	}
	else {
		scalar `cbar' = -13.5
		tempvar t
		qui gen `t' = _n
		local trend " exog(`t')"
	}	
	
	local tsvarlist `varlist'
	tsrevar `tsvarlist'
	local varlist `r(varlist)'
	
	qui {
	var `varlist' if `touse', `con' `trend' lags(1/`maxlag')
	local T = e(N)
// define appropriate rho(bar) for this case and sample
	scalar `rho' = 1 + `cbar'/`T'
	tempname tousevar obsnr touse2
	gen byte `tousevar' = e(sample)
	gen byte `obsnr' = sum(`tousevar')
	local j 0
	foreach v in `varlist' {
		tempvar eps_`v'
		predict `eps_`v'' if e(sample), equation(#`++j') resid
		local epslist "`epslist' `eps_`v''"
		tempvar qd_`v'
// treat first quasi-diff obs as zero unless firstobs selected
		g double `qd_`v'' = 0
		if "`firstobs'" == "firstobs" {
			replace `qd_`v'' =`v' if `obsnr' == 1
		}	
		replace `qd_`v'' = `v' - `rho' * L.`v' if `obsnr'>1
		local qdlist "`qdlist' `qd_`v''"
		tempvar ut1_`v' utrho_`v'
		gen double `ut1_`v'' = .
		gen double `utrho_`v'' = .
		local ut1list "`ut1list' `ut1_`v''"
		local utrholist "`utrholist' `utrho_`v''"
	}
	}

	mata: m_urcovar(`T',"`epslist'","`varlist'","`qdlist'","`ut1list'","`utrholist'","`tousevar'",`case',"`rho'","`r2'")
	
	local depvar: word 1 of `tsvarlist'
	local covarlist: subinstr local tsvarlist "`depvar'" "", word
	qui tsset
	local tfmt `r(tsfmt)'
	su `timevar' if `touse', meanonly
	local tmin = string(`r(min)',"`tfmt'")
	local tmax = string(`r(max)',"`tfmt'")
	di as txt _n "Elliott-Jansson unit root test for " as res "`depvar'" ///
	_col(50) as txt "`tmin' - `tmax'" _n "Number of obs: " _col(22) as res %5.0f `T'
	di as txt "Stationary covariates:" as res "`covarlist'"
	di as txt "Deterministic model:   " as res "Case `case'"
	di as txt "Maximum lag order: " _col(24) as res "`maxlag'"
	di as txt _n "Estimated R-squared: " _col(20) as res %5.4f `r2'
	
// STEP (C)
	qui {
	var `ut1list', `con' `trend' lags(1/`maxlag')
	gen byte `touse2' = e(sample)
	local j 0
    foreach v in `ut1list' {
    	tempvar etilde1_`v'
    	predict `etilde1_`v'' if e(sample), equation(#`++j') resid
    	local etilde1list "`etilde1list' `etilde1_`v''"
    }
    var `utrholist', `con' `trend' lags(1/`maxlag')
	local j 0
    foreach v in `utrholist' {
    	tempvar etilderho_`v'
    	predict `etilderho_`v'' if e(sample), equation(#`++j') resid
    	local etilderholist "`etilderholist' `etilderho_`v''"
    }
 	}   

    mata: m_urcovar2(`T',"`etilde1list'","`etilderholist'","`touse2'","`rho'","`lambda'")
    di as res "H0:" as txt " rho = 1 [ `depvar' is I(1) ]"
    di as res "H1:" as txt " rho < 1 [ `depvar' is I(0) ]"
    di as res "Reject H0 if Lambda < critical value" _n
    di as txt "Lambda: " _col(19) as res %9.4f `lambda'
    mata: m_urcovarcv(`case',"`cvint'","`r2'")
    di as txt "5% critical value:" _col(19) as res %9.4f `cvint'
    
    return local cmdname "urcovar"
    return local N `r(N)'
    return local depvar "`depvar'"
    return local xvar "`covarlist'"
    return scalar case = `case'
    return scalar maxlag = `maxlag'
    return scalar r2 = `r2'
    return scalar lambda = `lambda'
    return scalar crit5 = `cvint'
    
	end


	
	mata:	
	void m_urcovar(
					real scalar T,
		            string scalar epslist,
		            string scalar zlist,
		            string scalar qdlist,
		            string scalar ut1list,
		            string scalar utrholist,
		            string scalar touse,
		            real scalar ncase,
		            string scalar srho,
		            string scalar sr2)	
	{      
		real matrix eps, Shat, b, b2, A1, omegahat, omegainv
		string rowvector vars, vars2, vars3, vars4, vars5
		string scalar v, v2, v3, v4, v5

// STEP (A)
// sigma-hat matrix from VAR residuals: dimension is #eqns x #eqns	               
	    vars = tokens(epslist)
        v = vars[|1,.|]
        st_view(eps=.,.,v,touse)
        Shat = 1/T * ( eps' * eps)
        neq = cols(Shat)

// for case = 2,3, remove constant elements (neq+1, 2(neq+1), ...) 
// for case = 4,5, remove constant+trend elements [(neq+1, neq+2),
//                 (2(neq+1)+1, 2(neq+1)+2), ...]

// reformat coefficients into A(1), A(2).. matrices
        fullb=st_matrix("e(b)")
        sel = J(1,cols(fullb),1)
        if(ncase==2 | ncase==3) {
        	nbeq = cols(fullb)/neq
        	for(i=neq+1;i<=cols(fullb);i=i+nbeq) {
        		sel[1,i] = 0
        	}
        }
        if(ncase==4 | ncase==5) {
        	nbeq = cols(fullb)/neq
        	for(i=neq+1;i<=cols(fullb);i=i+nbeq) {
        		sel[1,i] = 0
        		sel[1,i+1] = 0
        	}
        }
        b = select(fullb,sel)
        nlag=st_numscalar("e(mlag)")
// number of eqns in VAR: cols of b2 correspond to lags
		b2 = colshape(b,nlag)

// gen A() matrix for each lag
		A1 = I(rows(Shat))
		pointer(real matrix) rowvector ap
		ap = J(1,nlag,NULL)
		for(i=1;i<=nlag;i++) {
			ap[i] = &(colshape(b2[.,i],neq))
			A1 = A1 + *ap[i]
		}
		
// form omegahat = inv(A1) sigmahat inv(A1)', same dim as Shat
		omegahat = luinv(A1) * Shat * luinv(A1)'
		omegainv = invsym(omegahat)	
		omegayy = omegahat[1,1]
		omegayx = omegahat[|1,2\1,neq|]
		omegaxx = omegahat[|2,2\neq,neq|]
//		sigmaxx = Shat[|2,2\neq,neq|]
		r2hat = invsym(omegayy) * omegayx * invsym(omegaxx) * omegayx'
		st_numscalar(sr2,r2hat)

// STEP (B)
		rho = st_numscalar(srho)
// retrieve z matrix
		vars2 = tokens(zlist)
        v2 = vars2[|1,.|]
        st_view(z=.,.,v2,touse)
// retrieve quasi-differenced z matrix
        vars3 = tokens(qdlist)
        v3 = vars3[|1,.|]
        st_view(zqd=.,.,v3,touse)

// number of stationary covariates
		m = cols(z)-1

// S(1): null		
		S = J(2*(m+1),2*(m+1),0)
// S(2): (1,1) element nonzero
		if(ncase==2) {
			S[1,1] = 1
		}
// S(3): I(m+1)
		if(ncase==3) {
			S[|1,1\m+1,m+1|] = I(m+1)
		}
// S(4): I(m+2)
		if(ncase==4) {
			S[|1,1\m+2,m+2|] = I(m+2)
		}
		if(ncase==5) {
// S(5): I(2(m+1))
			S = I(2*(m+1))
		}

		bsum1 = J(2*(m+1),2*(m+1),0)
		bsumrho = J(2*(m+1),2*(m+1),0)
		bsumz1 = J(2*(m+1),1,0)
		bsumzrho = J(2*(m+1),1,0)
		pointer(real matrix) rowvector d1p
		pointer(real matrix) rowvector drhop
		d1p = J(1,T,NULL)
		drhop = J(1,T,NULL)
		d1p[1] = &(1,J(1,m,0),1,J(1,m,0) \ J(m,1,0),I(m),J(m,1,0),I(m))
		bsum1 = *d1p[1]' * omegainv * *d1p[1]
		bsumz1 = *d1p[1]' * omegainv * z[1,.]'
		drhop[1] = &(1,J(1,m,0),1,J(1,m,0) \ J(m,1,0),I(m),J(m,1,0),I(m))
		bsumrho = *drhop[1]' * omegainv * *drhop[1]
		bsumzrho = *drhop[1]' * omegainv * zqd[1,.]'
		for(t=2;t<=T;t++) {
			d1p[t] = &(0,J(1,m,0),1,J(1,m,0) \ J(m,1,0),I(m),J(m,1,0),t*I(m))
			bsum1 = bsum1 + *d1p[t]' * omegainv * *d1p[t]
			bsumz1 = bsumz1 + *d1p[t]' * omegainv * z[t,.]'
			drhop[t] = &(1-rho,J(1,m,0),t-rho*(t-1),J(1,m,0) \ J(m,1,0),I(m),J(m,1,0),t*I(m))
			bsumrho = bsumrho + *drhop[t]' * omegainv * *drhop[t]	
			bsumzrho = bsumzrho + *drhop[t]' * omegainv * zqd[t,.]'	
		}
		btilde1 = qrinv( S * bsum1 * S ) * ( S * bsumz1)
		btilderho = qrinv( S * bsumrho * S ) * (S * bsumzrho)

// utilde1, utilderho
		vars4 = tokens(ut1list)
        v4 = vars4[|1,.|]
        st_view(utilde1=.,.,v4,touse)
        vars5 = tokens(utrholist)
        v5 = vars5[|1,.|]
        st_view(utilderho=.,.,v5,touse)
		tutilde1 = J(m+1,T,0)
		tutilderho = J(m+1,T,0)
		for(t=1;t<=T;t++) {
			tutilde1[.,t] = z[t,.]' - *d1p[t] * btilde1
			tutilderho[.,t] = zqd[t,.]' - *drhop[t] * btilderho
		}
		utilde1[.,.] = tutilde1'
		utilderho[.,.] = tutilderho'
	}
	
	
	
		void m_urcovar2(
				  	real scalar T,
		            string scalar etilde1list,	            
		            string scalar etilderholist,	            
		            string scalar touse, 
		            string scalar srho, 
		            string scalar slambda)
	
	{	                    
		real matrix etilde1, etilderho	                    
		string rowvector vars6, vars7
		string scalar v6, v7
		
// STEP (C)
// sigma-tilde1 matrix from utilde1 residuals
	    vars6 = tokens(etilde1list)
        v6 = vars6[|1,.|]
        st_view(etilde1=.,.,v6,touse)
        Stilde1 = 1/T * ( etilde1' * etilde1)
        
// sigma-tilderho matrix from utilderho residuals
	    vars7 = tokens(etilderholist)
        v7 = vars7[|1,.|]
        st_view(etilderho=.,.,v7,touse)
        Stilderho = 1/T * ( etilderho' * etilderho)
        
// STEP (D)
		rho = st_numscalar(srho)
		m = cols(Stilde1) - 1
		lambda = T * (trace(invsym(Stilde1) * Stilderho) - ( m + rho))
		st_numscalar(slambda,lambda)
	}		



	void m_urcovarcv(real scalar ncase,
	                 string scalar scvint,
	                 string scalar r2)
	{
		real matrix cval
		
		cval=(3.34,3.41,3.54,3.76,4.15,4.79,5.88,7.84,12.12,25.69 \ 
		   	3.34,3.41,3.54,3.76,4.15,4.79,5.88,7.84,12.12,25.69 \ 
		    3.34,3.41,3.54,3.70,3.96,4.41,5.12,6.37,9.17,17.99 \ 
		    5.70,5.79,5.98,6.38,6.99,7.97,9.63,12.60,19.03,39.62 \ 
		    5.70,5.77,6.00,6.40,7.07,8.15,10.00,13.36,20.35,41.87)
// interpolate between critical values for R2: (0,0.1,...0.9)		    
		r2pc=10*st_numscalar(r2)
		cell = min((max((trunc(r2pc)+1,1)),10))
		cell1 = min((cell+1,10))
		frac=r2pc-trunc(r2pc)
		cvint = cval[ncase,cell] + frac*(cval[ncase,cell1]-cval[ncase,cell])
		st_numscalar(scvint,cvint)
	}
	end
	
