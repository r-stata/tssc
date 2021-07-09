*! couliari 1.00 03jan2010
* Define program
program define couliari, rclass byable(recall, noheader)
		version 9.2

	* Syntax requires: variables, start and end points, and stub to name new variables		
	syntax varlist(ts) [if] [in], S(string) E(string) STUB(string)
	
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
		di in red "sample may not contain gaps"
		exit
	}
		* Allow the user to use periods when calling the subroutine
	if `s'>=2 {
		local s1=`e'
		local e=2/`s'
		local s=2/`s1'
	}
	* Check end point larger than starting point
	if `s'>`e' {
		di in red "Starting point must be smaller than ending point"
		error 198
	}
	if `s'<=0 | `e'<=0 | `e'>1 {
		di in red "Invalid e or s"
		error 198
	}
	* validate each new varname defined by stub()
	local kk: word count `varlist'
	local varlist2: subinstr local varlist "." "_", all   
	local suf = _byindex()
	qui forval i = 1/`kk' {
			local v: word `i' of `varlist2'
			confirm new var `stub'_`v'_`suf'
			confirm new var `stub'_`v'_sm_`suf'
			gen double `stub'_`v'_`suf' = .
			gen double `stub'_`v'_sm_`suf' = .
			local varlist3 "`varlist3' `stub'_`v'_`suf'"
			local varlist4 "`varlist4' `stub'_`v'_sm_`suf'"
	}
	* create temp vars for any ts operators in the varlist
	* pass the resulting varlist1 to Mata fn
	tsrevar `varlist'
	local varlist1 `r(varlist)'
	
	mata: idbp("`varlist1'","`varlist3'","`varlist4'","`touse'",`s',`e')
	
	return local rawvars "`varlist'"
    return local filtvars "`varlist3'"
	return local smvars "`varlist4'"
    return local s "`s'"  
    return local e "`e'"
end

mata
	
	/* Function to compute Fourier transform */
	complex matrix dft( transmorphic matrix x)
	{	
		real matrix yr, yi, dftr, dfti, range
		real scalar n, c, i, ae
		complex matrix df
		
		yr=Re(C(x))
		yi=Im(C(x))
		n=rows(x)
		c=cols(x)
		dftr=J(n,c,.)
		dfti=J(n,c,.)
		range=range(1,n,1)
		ae=-2*pi()/n
		for (i=0; i<=n-1; i++) {	
			dftr[i+1,.]=colsum(yr:*cos((range:-1):*ae:*i)-yi:*sin((range:-1):*ae:*i))
			dfti[i+1,.]=colsum(yr:*sin((range:-1):*ae:*i)+yi:*cos((range:-1):*ae:*i))
		}
		df=C(dftr,dfti)
		return(df/n)
	} 
	
	/* Function to compute the inverse of Fourier transform */	
	complex matrix inv_dft(complex matrix x) 
	{
		complex matrix df
		real matrix dftr, dfti, dftinvr, dftinvi, range
		real scalar n, c, ae, i
		
		n=rows(x)
		c=cols(x)
		dftr=Re(x)
		dfti=Im(x)
		dftinvr=J(n,c,.)
		dftinvi=J(n,c,.)
		range=range(1,n,1)
		ae=2*pi()/n
		for (i=0; i<=n-1; i++) {	
			dftinvr[i+1,.]=colsum(dftr:*cos((range:-1):*ae:*i)-dfti:*sin((range:-1):*ae:*i))
			dftinvi[i+1,.]=colsum(dftr:*sin((range:-1):*ae:*i)+dfti:*cos((range:-1):*ae:*i))
		}
		df=C(dftinvr,dftinvi)
		return(df)
	}
	
	/* Function to extract the relevant frequencies */
	real matrix dfte(transmorphic matrix x, real scalar s, real scalar e) 
	{
		real matrix dftr, dfti
		real scalar n,m, j, c, k
		complex matrix df, dfte
		
		n=rows(x)
		c=cols(x)
		df=dft(C(x))
		dftr=Re(df)
		dfti=Im(df)
		m=(n+mod(n,2))/2
		for (j=1; j<=m; j++) {
			k=j/m
			if (k<s|k>e) {
				if (j==1) {
					dftr[j,.]=J(1,c,0)
					dfti[j,.]=J(1,c,0)
				}	
				else {
					dftr[j,.]=J(1,c,0)
					dftr[n-(j-2),.]=J(1,c,0)
					dfti[j,.]=J(1,c,0)
					dfti[n-(j-2),.]=J(1,c,0)
				}
			}
		}
		if (s>0) {
			dftr[1,.]=J(1,c,0)
			dfti[1,.]=J(1,c,0)
		}
		if (mod(n,2)==0 & e<1) {
			dftr[m+1,.]=J(1,c,0)
			dfti[m+1,.]=J(1,c,0)
		}
		dfte=Re(inv_dft(C(dftr,dfti)))
		return(dfte)
	}
	
	void idbp(string scalar vname,
			  string scalar vname3,
			  string scalar vname4,
			  string scalar touse,
			  real scalar s, 
			  real scalar e)	
	{
		real matrix trend, t, dfftx, M, X, Y, Z
		string rowvector vars, vars3, vars4
		string scalar v,v3,v4
		real scalar i
		
       	vars = tokens(vname)
       	v = vars[|1,.|]
        X=st_data(.,	v,touse)
		
        vars3 = tokens(vname3)
        v3 = vars3[|1,.|]
        st_view(Y,.,v3,touse)
		
		vars4 = tokens(vname4)
		v4 = vars4[|1,.|]
		st_view(Z,.,v4,touse)
		
		trend=range(1,rows(X),1)/rows(X)
		t=dfte(trend,s,e)
		dfftx=dfte(X,s,e)
		M=I(rows(X),rows(X))-t*invsym(t'*t)*t'
		for (i=1; i<=cols(X); i++) {
			Y[.,i]=M*dfftx[.,i]
		}
		Z[.,.]=X-Y
	}
	
end
	