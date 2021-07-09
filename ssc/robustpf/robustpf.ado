////////////////////////////////////////////////////////////////////////////////
// STATA FOR Hu, Y., Huang, G., & Sasaki, Y. (2020): Estimating Production 
//           Functions with Robustness Against Errors in the Proxy Variables. //           Journal of Econometrics 215 (2), pp. 375-398.
//
// Use this code for estimation of production functions with robustness against
// errors in the proxy variables.
////////////////////////////////////////////////////////////////////////////////
 program define robustpf, eclass
    version 14.2
 
    syntax varlist(min=3 numeric) [if] [in] [, proxy(varname numeric) m1(varname numeric) m2(varname numeric) m3(varname numeric) m4(varname numeric) m5(varname numeric) init_k(real 0) init_l(real 0) init_m(real 0.5)]
    marksample touse
 
	qui xtset
	local panelid   = r(panelvar)
	local timeid  = r(timevar)

    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'

	tempvar m1var m2var m3var m4var m5var xvar
	local m1in = 0 
	if "`m1'" != "" {
	    local m1in = 1
		gen `m1var' = `m1'
	}
	local m2in = 0 
	if "`m2'" != "" {
	    local m2in = 1
		gen `m2var' = `m2'
	}
	local m3in = 0 
	if "`m3'" != "" {
	    local m3in = 1
		gen `m3var' = `m3'
	}
	local m4in = 0 
	if "`m4'" != "" {
	    local m4in = 1
		gen `m4var' = `m4'
	}
	local m5in = 0 
	if "`m5'" != "" {
	    local m5in = 1
		gen `m5var' = `m5'
	}
	
	if "`proxy'" == "" {
	    di "{hline 41}"
	    di "Error: the proxy() option must be called."
	    di "{hline 41}"
	}
	
	if "`proxy'" != "" {
		gen `xvar' = `proxy'

		tempname b V N
		mata: estimation("`depvar'", "`cnames'", "`xvar'", ///
						 "`panelid'", "`timeid'", ///
						 "`m1var'", `m1in', ///
						 "`m2var'", `m2in', ///
						 "`m3var'", `m3in', ///
						 "`m4var'", `m4in', ///
						 "`m5var'", `m5in', ///
						 `init_k', `init_l', `init_m', ///
						 "`touse'", "`b'", "`V'", "`N'") 
	 
		local cnames `cnames' Intermediate
	 
		matrix colnames `b' = `cnames'
		matrix colnames `V' = `cnames'
		matrix rownames `V' = `cnames'

		ereturn post `b' `V', esample(`touse') buildfvinfo
		ereturn scalar N    = `N'
		ereturn local  cmd  "robustpf"
	 
		ereturn display
	}
end
////////////////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////////////// 
mata:
//////////////////////////////////////////////////////////////////////////////// 
// Function for the GMM Criterion
void GMMc(todo, para, NT, numlmumm, yearlist, yearyk, l, m, x, z, W, crit, g, H){
	N = NT[1,1]
	T = NT[1,2]
	numl = numlmumm[1,1]
	numm = numlmumm[1,2]
	
	a_x0 = para[1] // J(1,1,0)
	a_xk = para[2] // J(1,1,0)
	a_xomega = para[3] // J(1,1,0)
	b_k = para[4] // J(1,1,0)
	b_l = para[5..(4+numl)]' // J(numl,1,0)
	b_m = para[(5+numl)..(4+numl+numm)]' // J(numm,1,0.5)
	phi1 = para[5+numl+numm] // J(1,1,1)

	year = yearyk[.,1]
	y    = yearyk[.,2]
	k    = yearyk[.,3]

	ytilde = y :- k * b_k :- l * b_l :- m * b_m
	xtilde = x :- a_x0 :- k * a_xk
	ytilde_tplus1 = ytilde
	xtilde_tplus1 = xtilde
    for( idx = 1 ; idx <= rows(y) ; idx++ ){
	    if( year[idx] == min(yearlist) ){
		    ytilde_tplus1[idx] = 0
		    xtilde_tplus1[idx] = 0
		}else{
		    ytilde_tplus1[idx] = ytilde[idx-1]
		    xtilde_tplus1[idx] = xtilde[idx-1]
		}
	}
	//xtilde_tplus1,xtilde
	
	moments = J(cols(z)*2,1,0)
	for( idx = 1 ; idx <= cols(z) ; idx++ ){
		moments[2*(idx-1)+1] = sum( z[.,idx] :* (ytilde_tplus1 :- (a_xomega*phi1) :* ytilde) )
		moments[2*(idx-1)+2] = sum( z[.,idx] :* (xtilde_tplus1 :- phi1 :* ytilde) )
	}
	moments = moments :/ (N * (T-1))

    crit = moments' * W * moments
}
//////////////////////////////////////////////////////////////////////////////// 
// Function for the GMM Variance
void GMMv(para, NT, numlmumm, yearlist, yearyk, l, m, x, z, variance){
	N = NT[1,1]
	T = NT[1,2]
	numl = numlmumm[1,1]
	numm = numlmumm[1,2]
	
	a_x0 = para[1] // J(1,1,0)
	a_xk = para[2] // J(1,1,0)
	a_xomega = para[3] // J(1,1,0)
	b_k = para[4] // J(1,1,0)
	b_l = para[5..(4+numl)]' // J(numl,1,0)
	b_m = para[(5+numl)..(4+numl+numm)]' // J(numm,1,0.5)
	phi1 = para[5+numl+numm] // J(1,1,1)

	year = yearyk[.,1]
	y    = yearyk[.,2]
	k    = yearyk[.,3]

	ytilde = y :- k * b_k :- l * b_l :- m * b_m
	xtilde = x :- a_x0 :- k * a_xk
	ytilde_tplus1 = ytilde
	xtilde_tplus1 = xtilde
    for( idx = 1 ; idx <= rows(y) ; idx++ ){
	    if( year[idx] == min(yearlist) ){
		    ytilde_tplus1[idx] = 0
		    xtilde_tplus1[idx] = 0
		}else{
		    ytilde_tplus1[idx] = ytilde[idx-1]
		    xtilde_tplus1[idx] = xtilde[idx-1]
		}
	}
	//xtilde_tplus1,xtilde
	
	moments = J(cols(z)*2,N*(T-1),0)
	for( idx = 1 ; idx <= cols(z) ; idx++ ){
	    index = 1
	    for( jdx = 1 ; jdx <= N*T ; jdx++ ){
		    if( year[jdx] != min(yearlist) ){
				moments[2*(idx-1)+1,index] = sum( z[jdx,idx] :* (ytilde_tplus1[jdx] :- (a_xomega*phi1) :* ytilde[jdx]) )
				moments[2*(idx-1)+2,index] = sum( z[jdx,idx] :* (xtilde_tplus1[jdx] :- phi1 :* ytilde[jdx]) )
				index++
			}
		}
	}
	
	variance = moments * moments' :/ (N*(T-1)) :- (moments :/ (N*(T-1))) * (moments :/ (N*(T-1)))'
}
//////////////////////////////////////////////////////////////////////////////// 
// Function for the GMM moments
void GMMm(para, NT, numlmumm, yearlist, yearyk, l, m, x, z, moments){
	N = NT[1,1]
	T = NT[1,2]
	numl = numlmumm[1,1]
	numm = numlmumm[1,2]
	
	a_x0 = para[1] // J(1,1,0)
	a_xk = para[2] // J(1,1,0)
	a_xomega = para[3] // J(1,1,0)
	b_k = para[4] // J(1,1,0)
	b_l = para[5..(4+numl)]' // J(numl,1,0)
	b_m = para[(5+numl)..(4+numl+numm)]' // J(numm,1,0.5)
	phi1 = para[5+numl+numm] // J(1,1,1)

	year = yearyk[.,1]
	y    = yearyk[.,2]
	k    = yearyk[.,3]

	ytilde = y :- k * b_k :- l * b_l :- m * b_m
	xtilde = x :- a_x0 :- k * a_xk
	ytilde_tplus1 = ytilde
	xtilde_tplus1 = xtilde
    for( idx = 1 ; idx <= rows(y) ; idx++ ){
	    if( year[idx] == min(yearlist) ){
		    ytilde_tplus1[idx] = 0
		    xtilde_tplus1[idx] = 0
		}else{
		    ytilde_tplus1[idx] = ytilde[idx-1]
		    xtilde_tplus1[idx] = xtilde[idx-1]
		}
	}
	//xtilde_tplus1,xtilde
	
	moments = J(cols(z)*2,1,0)
	for( idx = 1 ; idx <= cols(z) ; idx++ ){
		moments[2*(idx-1)+1] = sum( z[.,idx] :* (ytilde_tplus1 :- (a_xomega*phi1) :* ytilde) )
		moments[2*(idx-1)+2] = sum( z[.,idx] :* (xtilde_tplus1 :- phi1 :* ytilde) )
	}
	moments = moments :/ (N * (T-1))
}
//////////////////////////////////////////////////////////////////////////////// 
// Function for the GMM gradients
void GMMg(para, NT, numlmumm, yearlist, yearyk, l, m, x, z, gradients){
    real matrix moments
	GMMm(para, NT, numlmumm, yearlist, yearyk, l, m, x, z, moments)

	gradients = J(length(moments),length(para),0)
	
	real matrix delta_moments
	delta = 0.001

	for( idx = 1 ; idx <= length(para) ; idx++ ){
		delta_para = para
		delta_para[idx] = delta_para[idx] + delta
		GMMm(delta_para, NT, numlmumm, yearlist, yearyk, l, m, x, z, delta_moments)
		
		gradients[.,idx] = (delta_moments - moments ) :/ delta
	}
}
////////////////////////////////////////////////////////////////////////////////
// Main Estimation Function
void estimation( string scalar depvar,  string scalar indepvar,  
				 string scalar xvar,
				 string scalar panelid, string scalar timeid,  
				 string scalar m1var,	real scalar m1in,
				 string scalar m2var,	real scalar m2in,
				 string scalar m3var,	real scalar m3in,
				 string scalar m4var,	real scalar m4in,
				 string scalar m5var,	real scalar m5in,
				 real scalar init_k,	real scalar init_l, real scalar init_m,
				 string scalar touse,   string scalar bname,   
				 string scalar Vname,   string scalar nname) 
{
	printf("{hline 78}\n")
	printf("Executing:  Hu, Y., Huang, G., & Sasaki, Y. (2020): Estimating Production     \n")
	printf("            Functions with Robustness Against Errors in the Proxy Variables.  \n")
	printf("            Journal of Econometrics 215 (2), pp. 375-398.                     \n")
	printf("{hline 78}\n")
 
 	////////////////////////////////////////////////////////////////////////////
	// depvar ==> y, first row of indepvar ==> k, the last row of indepvar ==> x
    y    = st_data(., depvar, touse)
    kl  = st_data(., indepvar, touse)
	k    = kl[., 1]
	l    = kl[., 2..(cols(kl))]
	numl = cols(l)
	x    = st_data(., xvar, touse)
    m    = J(rows(y),(m1in+m2in+m3in+m4in+m5in),0)
	index = 1
	if( m1in ){
	    m[.,index++] = st_data(., m1var, touse)
	}
	if( m2in ){
	    m[.,index++] = st_data(., m2var, touse)
	}
	if( m3in ){
	    m[.,index++] = st_data(., m3var, touse)
	}
	if( m4in ){
	    m[.,index++] = st_data(., m4var, touse)
	}
	if( m5in ){
	    m[.,index++] = st_data(., m5var, touse)
	}
	numm = cols(m)
    year = st_data(., timeid, touse)
	id   = st_data(., panelid, touse)

	////////////////////////////////////////////////////////////////////////////
	// Get the list of ids
	idlist = id :* 0
	idlist[1] = id[1]
	index = 1
	for( idx = 2 ; idx <= length(id) ; idx++ ){
		if( sum( id[idx] :== idlist[1..index] ) == 0 ){
			index++
			idlist[index] = id[idx]
		}
	}
	idlist = idlist[1..index]
	idlist = sort(idlist,1)
	N = length(idlist)

	////////////////////////////////////////////////////////////////////////////
	// Get the list of years
	yearlist = year :* 0
	yearlist[1] = year[1]
	index = 1
	for( idx = 2 ; idx <= length(year) ; idx++ ){
		if( sum( year[idx] :== yearlist[1..index] ) == 0 ){
			index++
			yearlist[index] = year[idx]
		}
	}
	yearlist = yearlist[1..index]
	yearlist = sort(yearlist,1)
	T = length(yearlist)
	
	////////////////////////////////////////////////////////////////////////////
	// Get balanced panel
	balanceidlist = 0
	for( idx = 1 ; idx <= length(idlist) ; idx++ ){		
		if( length( select( year, idlist[idx] :== id ) ) == length( yearlist ) ){
		    balanceidlist = balanceidlist, idlist[idx]
		}
	}
	balanceidlist = balanceidlist[2..(length(balanceidlist))]
	N = length(balanceidlist)
	
	balanceindices = y :* 0
	index = 1
	for( idx = 1 ; idx <= rows(y) ; idx++ ){
		if( sum( id[idx] :== balanceidlist ) == 1 ){
			balanceindices[index++] = idx
		}
	}
	balanceindices = balanceindices[1..(index-1)]

	for( idx = 1 ; idx <= length(balanceindices) ; idx++ ){
	id[idx,.] = id[balanceindices[idx],.]
	year[idx,.] = year[balanceindices[idx],.]
	y[idx,.] = y[balanceindices[idx],.]
	k[idx,.] = k[balanceindices[idx],.]
	l[idx,.] = l[balanceindices[idx],.]
	x[idx,.] = x[balanceindices[idx],.]
	m[idx,.] = m[balanceindices[idx],.]
	}
	id = id[1..(idx-1),.]
	year = year[1..(idx-1),.]
	y = y[1..(idx-1),.]
	k = k[1..(idx-1),.]
	l = l[1..(idx-1),.]
	x = x[1..(idx-1),.]
	m = m[1..(idx-1),.]
	
	//id,year
	
	////////////////////////////////////////////////////////////////////////////
	// Form instruments - first if x is a part of m, then take the lag of that m
	z = m, l, k, J(rows(m),1,1)
	m_proxy_index = 0
	for( idx = 1 ; idx <= numm ; idx++ ){
	    if( sum( m[.,idx] :!= x )  :== 0 ){
		    m_proxy_index = idx
		}
	}
	if( m_proxy_index > 0 ){
	    for( idx = 1 ; idx <= rows(z) ; idx++ ){
		    if( year[idx] == min(yearlist) ){
			    z[idx,.] = J(1,cols(z),0)
			}else{
			    z[idx,m_proxy_index] = m[idx-1,m_proxy_index]
			}
		}
	}
	//m,z

	////////////////////////////////////////////////////////////////////////////
	// 1st Step GMM Estimation
	printf("{hline 32}\n    GMM: 1st Step Estimation\n{hline 32}\n")
	W = diag(J(cols(z)*2,1,1))
	
	a_x0 = J(1,1,0.0)
	a_xk = J(1,1,0.0)
	a_xomega = J(1,1,0)
	b_k = J(1,1,init_k)
	b_l = J(numl,1,init_l)
	b_m = J(numm,1,init_m)
	phi1 = J(1,1,1)
	init = ( a_x0, a_xk, a_xomega, b_k, b_l', b_m', phi1 )
	S = optimize_init()
	optimize_init_evaluator(S,&GMMc())
	optimize_init_which(S,"min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_technique(S,"nr")
	optimize_init_singularHmethod(S,"hybrid") 
	optimize_init_argument(S,1,(N,T))
	optimize_init_argument(S,2,(numl,numm))
	optimize_init_argument(S,3,yearlist)
	optimize_init_argument(S,4,(year,y,k))
	optimize_init_argument(S,5,l) 
	optimize_init_argument(S,6,m)
	optimize_init_argument(S,7,x)
	optimize_init_argument(S,8,z)
	optimize_init_argument(S,9,W)
	optimize_init_params(S, init)
	//optimize_init_conv_maxiter(S, 200)
	est=optimize(S)	
	//est

	////////////////////////////////////////////////////////////////////////////
	// Estimate 1st GMM variance
	real matrix variance
	GMMv(est, (N,T), (numl,numm), yearlist, (year,y,k), l, m, x, z, variance)
	//variance
	
	////////////////////////////////////////////////////////////////////////////
	// 2nd Step GMM Estimation
	printf("{hline 32}\n    GMM: 2nd Step Estimation\n{hline 32}\n")
	W = luinv(variance)
	
	S = optimize_init()
	optimize_init_evaluator(S,&GMMc())
	optimize_init_which(S,"min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_technique(S,"nr")
	optimize_init_singularHmethod(S,"hybrid") 
	optimize_init_argument(S,1,(N,T))
	optimize_init_argument(S,2,(numl,numm))
	optimize_init_argument(S,3,yearlist)
	optimize_init_argument(S,4,(year,y,k))
	optimize_init_argument(S,5,l) 
	optimize_init_argument(S,6,m)
	optimize_init_argument(S,7,x)
	optimize_init_argument(S,8,z)
	optimize_init_argument(S,9,W)
	optimize_init_params(S, init)
	//optimize_init_conv_maxiter(S, 200)
	est=optimize(S)	
	//est
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate 2nd GMM variance
	GMMv(est, (N,T), (numl,numm), yearlist, (year,y,k), l, m, x, z, variance)
	//variance
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate 2nd GMM gradients
	real matrix graidents
	GMMg(est, (N,T), (numl,numm), yearlist, (year,y,k), l, m, x, z, gradients)
	
	//gradients' * luinv(variance) * gradients / (N*(T-1))
	
	b = est[1,4..(length(est)-1)]'
	V = ( gradients' * luinv(variance) * gradients / (N*(T-1)) )[4..(length(est)-1),4..(length(est)-1)]

    st_matrix(bname, b')
    st_matrix(Vname, V)
    st_numscalar(nname, N)
	
	RTS = J(1,length(b),1) * b
	V_RTS = J(1,length(b),1) * V * J(1,length(b),1)'
	SE_RTS = V_RTS^0.5
	
	printf("\n")
	printf("{hline 78}\n")
	printf("Number of cross-sectional observations in the balanced subsample:     N=%6.0f\n", N)
	printf("Number of time periods in the balanced subsample:                     T=%6.0f\n", T)
	printf("                                                                   minT=%6.0f\n",min(year))
	printf("                                                                   maxT=%6.0f\n",max(year))
	printf("{hline 78}\n")
	printf("Returns to Scale (Std. Err.) = %f (%f)\n",RTS,SE_RTS)
}

end
////////////////////////////////////////////////////////////////////////////////

