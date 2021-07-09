*! ghansen 1.02 29sep2013
* 02sep2011 Fix bug causing crash in Stata 9 and 10, optimize forvalues code
* 29sep2013 Fix bug caused by minindex returning a matrix instead of a scalar when ic were positive
program define ghansen, rclass byable(recall, noheader)
	version 9.2
	syntax varlist(ts)  [if] [in], break(string) lagmethod(string) [maxlags(numlist min=1 max=1 >0 integer) trim(real 0.15) level(real 0.95)]
	
	* Mark the sample to use
	marksample touse
	* Verify that data have been tsset
	_ts timevar panelvar if `touse', sort onepanel
	* Exclude observations if time variable is missing
	markout `touse' `timevar'
	* Check for gaps
	tsreport if `touse', report
	* Error message is sample contains gaps
	if r(N_gaps) {
		di as error "sample may not contain gaps".
		exit 198
	}
	gettoken lhs rhs : varlist
	local m: word count `rhs'
	if `m'>4 {
		di as error "more than 4 right hand side variables not supported"
		exit 198
	}
	tempvar count
	qui gen `count'= sum(`touse')
    local nobs= `count'[_N]
    

	
	if `trim' ~= . {
        if `trim' > =0 & `trim' < 0.25 {
                local fraction = `trim'
                }
        else {
                di as err "Trim must be a positive real number greater than 0 and less than 0.25"
                exit 198
                }
    }
	
	if ("`break'"!="" & "`break'"!="level" & "`break'"!="trend" & "`break'"!="regime" & "`break'"!="regimetrend") {
		di as err "break must be level, trend, regime or regimetrend"
		exit 198
	}
	
	if ("`lagmethod'"!="" & "`lagmethod'"!="aic" & "`lagmethod'"!="bic" & "`lagmethod'"!="downt" & "`lagmethod'"!="fixed") {
		di as err "lagmethod must be fixed, aic, bic or downt "
		exit 198
	}
	
	if ("`lagmethod'"!="fixed" & "`maxlags'"=="" ) {
		local maxlags=int(`nobs'^0.25)
	}
	
	if ("`lagmethod'"=="fixed" & "`maxlags'"=="" ) {
		di as err "maxlags is required if lagmethod is fixed"
		exit 198
	}	
	
	
	
	
	qui tsset
	local rts="`r(tsfmt)'"
	local brtype="`break'"
	mata: main("`lhs'","`rhs'","`brtype'","`lagmethod'",`maxlags',"`touse'",`trim',`level')
	
	local tstat=tstat
	local breakptadf=breakptadf
	local badfdate = string(`timevar'[`breakptadf'],"`rts'")
	local lag=lag
	local za=za
	local breakptza=breakptza
	local bzadate = string(`timevar'[`breakptza'],"`rts'")
	local zt=zt
	local breakptzt=breakptzt
	local bztdate = string(`timevar'[`breakptzt'],"`rts'")
	local obs=obs
	
	
	noi di as text _n "Gregory-Hansen Test for Cointegration with Regime Shifts"
	if "`break'"=="level" local mm="Change in Level" 
	if "`break'"=="trend" local mm="Change in Level and Trend"
	if "`break'"=="regime" local mm="Change in Regime"
	if "`break'"=="regimetrend" local mm="Change in Regime and Trend"
	noi di as text "Model: `mm'" _col(52) "Number of obs   = " as result %9.0g `obs'
	if "`lagmethod'"=="aic" local cc="Akaike criterion"
	if "`lagmethod'"=="bic" local cc="Bayesian criterion"
	if "`lagmethod'"=="downt" local cc="downward t-statistics"
	if "`lagmethod'"=="fixed" local cc="user"
	noi di as text "Lags  =  " as result `lag' as text "  chosen by `cc'"  _col(52) "Maximum Lags    = " as result %9.0g `maxlags'
	crit `break' `m'
	noi di as text _n _col(15) "Test" _col(26) "Breakpoint" _col(39) "Date" _col(51) "Asymptotic Critical Values"
	noi di as text _col(13) "Statistic" _col(50) "1%" _col(63) "5%" _col(75) "10%"
	di as text in smcl "{hline 78}"
	di as text _col(4) "ADF" as result _col(9) %10.2f `tstat'  _col(29) %10.0f "`breakptadf'" _col(38) "`badfdate'" _col(43) %10.2f `r(a1)' _col(56) %10.2f  `r(a2)' _col(68) %10.2f  `r(a3)'
	di as text _col(4) "Zt" as result _col(9) %10.2f `zt'  _col(29) %10.0f "`breakptza'" _col(38) "`bzadate'" _col(43) %10.2f `r(a1)' _col(56) %10.2f  `r(a2)' _col(68) %10.2f  `r(a3)'
	di as text _col(4) "Za" as result _col(9) %10.2f `za'  _col(29) %10.0f "`breakptza'" _col(38) "`bzadate'" _col(43) %10.2f `r(z1)' _col(56) %10.2f  `r(z2)' _col(68) %10.2f  `r(z3)'	
	di in gr in smcl "{hline 78}"
	
	return scalar tstat=tstat
	return scalar lag=lag
	return scalar breakptadf=breakptadf
	return scalar za=za
	return scalar breakptza=breakptza
	return scalar zt=zt
	return scalar breakptzt=breakptzt 
	return local break="`break'"
	return local badfdate="`badfdate'"
	return local bzadate="`bzadate'"
	return local bztdate="`bztdate'"
end

program define crit, rclass
	args break m
	mat alevel=(-5.13,-4.61,-4.34\-5.44,-4.92,-4.69\-5.77,-5.28,-5.02\-6.05,-5.56,-5.31)
	mat atrend=(-5.45,-4.99,-4.72\-5.80,-5.29,-5.03\-6.05,-5.57,-5.33\-6.36,-5.83,-5.59)
	mat aregime=(-5.47,-4.95,-4.68\-5.97,-5.50,-5.23\-6.51,-6.00,-5.75\-6.92,-6.41,-6.17)
	mat aregimetrend=(-6.02,-5.50,-5.24\-6.45,-5.96,-5.72\-6.89,-6.32,-6.16\-7.31,-6.84,-6.58)
	mat zlevel=(-50.07,-40.48,-36.19\-57.01,-46.98,-42.49\-63.64,-53.58,-48.65\-70.18,-59.40,-54.38)
	mat ztrend=(-57.28,-47.96,-43.22\-64.77,-53.92,-48.94\-70.27,-59.76,-54.94\-76.95,-65.44,-60.12)
	mat zregime=(-57.17,-47.04,-41.85\-68.21,-58.33,-52.85\-80.15,-68.94,-63.42\-90.35,-78.52,-75.56)
	mat zregimetrend=(-69.37,-58.58,-53.31\-79.65,-68.43,-63.10\-90.84,-78.87,-72.75\-100.69,-88.47,-82.30)
	forv i=1(1)3 {
		return local a`i' = a`break'[`m',`i']
        return local z`i' = z`break'[`m',`i']
	}
end

mata

	void main(string scalar Y,
			  string scalar X,
			  string scalar brtype,
			  string scalar lagmethod,
			  real scalar k,
			  string scalar touse,
			  real scalar trim,
			  real scalar level)
	{
		real scalar n, begin, final, lag, za, zt, breakptza, breakptzt
		real matrix y,x, temp1, temp2, temp3, temp4, dummy, x1, lags, breakptzas, breakptzts
		
		y=st_data(.,Y,touse)
		x=st_data(.,tokens(X),touse)
		
		n=rows(y)
		/* these are the default trimming values, could allow the user to change them */		 
		begin=round(trim*n)
		final=round((1-trim)*n)
		temp1=J(final-begin+1,1,0)
		temp2=temp1
		temp3=temp1
		temp4=temp1
		for (i=begin; i<=final; i++) {
			/* adjust regressors for different models */
			dummy=(J(i,1,0)\J(n-i,1,1))
			if (brtype=="trend") x1=(J(n,1,1),dummy,range(1,n,1),x)
			if (brtype=="regime") x1=(J(n,1,1),dummy,x,dummy*J(1,cols(x),1):*x)
			if (brtype=="level") x1=(J(n,1,1),dummy,x)
			if (brtype=="regimetrend") x1=(J(n,1,1),dummy,range(1,n,1),range(1,n,1):*dummy,x,dummy*J(1,cols(x),1):*x)
			/* compute ADF for each i */
			adf(y,x1,k,lagmethod,tstat=.,lag=.,b=.,level)
			temp1[i-begin+1]=tstat
			temp2[i-begin+1]=lag
		
			/* compute Za or Zt for each i */
			phillips(y,x1,za=.,zt=.)
			temp3[i-begin+1]=za
			temp4[i-begin+1]=zt
			
			st_numscalar("tstat",min(temp1))
			minindex(temp1,1,lags,w=.)
			lag=lags[1]
			st_numscalar("breakptadf",(lag+begin-1))
			st_numscalar("lag",temp2[lag])		
			
			st_numscalar("za",min(temp3))
			minindex(temp3,1,breakptzas,w=.)
			breakptza=breakptzas[1]
			st_numscalar("breakptza",(breakptza+begin-1))
			
			st_numscalar("zt",min(temp4))
			minindex(temp4,1,breakptzts,w=.)
			breakptzt=breakptzts[1]
			st_numscalar("breakptzt",(breakptzt+begin-1))
			st_numscalar("obs",n)
			
		}
	}

	function adf(real matrix y,
					real matrix x,
					real scalar kmax,
					string scalar lagmethod,
					real scalar tstat,
					real scalar lag,
					real matrix b,
					real scalar level)
	{
		real scalar n, ic, k, n1, j, aic, bic, w
		real matrix de, yde, xe, e1,temp1,temp2, lags
		
		n=rows(y)
		estimate(y,x,b=.,e=.,sig2=.,se=.,df=.)
		de=e[2..n]-e[1..n-1]
		ic=0
		k=kmax
		temp1=J(kmax+1,1,0)
		temp2=J(kmax+1,1,0)
		while (k>=0) {
			yde=de[1+k..n-1]
			n1=rows(yde)
			xe=e[k+1..n-1]
			j=1
			while (j<=k) {
				xe=(xe,de[k+1-j..n-1-j])
				j=j+1				
			}
			estimate(yde,xe,b=.,e1=.,sig2=.,se=.,df=.)
			if (lagmethod=="fixed") {				
				temp1[k+1]=-1000
				temp2[k+1]=b[1]/se[1]
				break
			}
			if (lagmethod=="aic") {
				aic=log((e1'*e1)/n1)+2*(k+2)/n1
				ic=aic
			}
			if (lagmethod=="bic") {
				bic=log((e1'*e1)/n1)+(k+2)*log(n1)/n1
				ic=bic
			}
			if (lagmethod=="downt") {
				if (ttail(df,abs(b[k+1]/se[k+1]))<((1-level)/2) | k==0 ) {
					temp1[k+1]=-1000
					temp2[k+1]=b[1]/se[1]
					break
				}
			}
			temp1[k+1]=ic
			temp2[k+1]=b[1]/se[1]
			k=k-1
		}
		minindex(temp1,1,lags,w=.)
		lag=lags[1]
		tstat=temp2[lag]
		lag=lag-1
	}

	function phillips(real matrix y,
					  real matrix x,
					  real scalar za,
					  real scalar zt)
	{
		real scalar n,nu,su,be,bu,a2,bw,m,j,lambda,c,w,gamma,p,sigma2,s
		real matrix b,e,ue,uu
		
		n=rows(y)
		b=qrsolve(x,y)
		e=y-x*b
		
		be=qrsolve(e[1..n-1],e[2..n])
		ue=e[2..n]-e[1..n-1]*be
		
		nu=rows(ue)
		bu=qrsolve(ue[1..nu-1],ue[2..nu])
		uu=ue[2..nu]-ue[1..nu-1]*bu
		su=mean(uu:^2)
		a2=(4*bu^2*su/(1-bu)^8)/(su/(1-bu)^4)
		bw=1.3221*((a2*nu)^0.2)
		
		m=bw
		j=1
		lambda=0
		while (j<=m) {
			gamma=(ue[1..nu-j]'*ue[j+1..nu])/nu
			c=j/m
			w=(75/(6*pi()*c)^2)*(sin(1.2*pi()*c)/(1.2*pi()*c)-cos(1.2*pi()*c))
			lambda=lambda+w*gamma
			j=j+1
		}
		
		p=sum(e[1..n-1]:*e[2..n]:-lambda)/sum(e[1..n-1]:^2)
		za=n*(p-1)
		sigma2=(2*lambda+ue'*ue)/nu
		s=sigma2/(e[1..n-1]'*e[1..n-1])
		zt=(p-1)/sqrt(s)
	}
		
	function estimate(real matrix y,
					  real matrix x,
					  real matrix b,
					  real matrix e,
					  real matrix sig2,
					  real matrix se,
					  real scalar df)
	{
		real matrix m
		m=cholinv(x'*x)
		b=m*x'*y
		e=y-x*b
		sig2=(e'*e):/(rows(y)-cols(x))
		se=sqrt(diagonal(m):*sig2)
		df=rows(y)-cols(x)
	}
	
end
   