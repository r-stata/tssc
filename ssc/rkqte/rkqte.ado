////////////////////////////////////////////////////////////////////////////////
// STATA FOR Chen, H., Chiang, H.D., & Sasaki, Y. (2020): Quantile Treatment 
//           Effects in Regression Kink Designs. Econometric Theory 36 (6), 1167
//           -1191.
//
// Use it when you consider a regression kink design and you are interested in 
// analyzing heterogeneous causal effects of a binary treatment.
////////////////////////////////////////////////////////////////////////////////
program define rkqte, eclass
    version 14.2
 
    syntax varlist(numeric min=3 max=3) [if] [in] [, k(real 0) cover(real 0.95) ql(real 0.25) qh(real 0.75) qn(real 3) bw(real -1)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname b V N cb
	
	mata: estimate("`depvar'", "`cnames'", ///
				   `k', `ql', `qh', ///
			       `qn', `bw', "`touse'", ///
				   "`b'", "`V'", "`N'", ///
				   `cover', "`cb'")
	
	loc lbl	
	forv i=1/`nq' {	
		sca _elt = _qq[1,`i']
		loc lbl "`lbl' QTE`=string(_elt)'"
	}
	matrix colnames `b' = `lbl'
	matrix colnames `V' = `lbl'
	matrix rownames `V' = `lbl'
	
    ereturn post `b' `V', esample(`touse') buildfvinfo
    ereturn scalar N    = `N'
	ereturn matrix Q = _qq
    ereturn local  cmd  "rkqte"
end
		
mata:
//////////////////////////////////////////////////////////////////////////////// 
// Kernel Function
void kernel(u, kout){
	kout = 0.75 :* ( 1 :- (u:^2) ) :* ( -1 :< u ) :* ( u :< 1 )
}
//////////////////////////////////////////////////////////////////////////////// 
// Estimation of QTE in the Fuzzy Design
void estimate( string scalar yv,       string scalar dxv,
			   real scalar cut, 	   real scalar q_low, 	   real scalar q_high, 	 
	  		   real scalar q_num, 	   real scalar b_w,	       string scalar touse,   
			   string scalar bname,    string scalar Vname,    string scalar nname,
			   real scalar cover,	   string scalar cbname) 
{
	printf("\n{hline 78}\n")
	printf("Executing:    Chen, H., Chiang, H.D., & Sasaki, Y. (2020): Quantile Treatment \n")
	printf("              Effects in Regression Kink Designs. Econometric Theory 36 (6),  \n")
	printf("              1167-1191.                                                      \n")
	printf("{hline 78}\n")
    real vector y, d, x, qlist
    real scalar n
 
    y      = st_data(., yv, touse)
	dx     = st_data(., dxv, touse)
	d      = dx[.,1]
    x      = dx[.,2] :- cut
    n      = rows(y)
	// List of quantiles at which to evaluate causal effects
	qlist = (q_high - q_low) :* (0..(q_num-1)) :/ (q_num-1) :+ q_low
	// Grid of y values at which the Wald ratio is ccomputed
	y_num = min((n/2,1000)')
	ylist = (sort(y,1)[trunc(n*0.95)] - sort(y,1)[trunc(n*0.05)]) :* (0..(y_num-1)) :/ (y_num-1) :+ sort(y,1)[trunc(n*0.05)]
	// Bandwidth
	h = b_w
	if( b_w <= 0 ){
		h = 10^(4/7) * variance(x)^0.5 / n^(1/7)
	}

	printf("\nEstimating QTE\n")

	////////////////////////////////////////////////////////////////////////////
	// Compute GAMMAplus GAMMAminus
	real matrix kout
	ulist = (-100..100 )' :/ 100
	ulistinterval = ulist[2] - ulist[1]
	uvec = J(length(ulist),1,1), ulist, ulist:^2, ulist:^3
	kernel( ulist, kout )

	GAMMAplus = ( uvec' * diag(kout :* (ulist :> 0)) * uvec ) :* ulistinterval
	GAMMAminus = ( uvec' * diag(kout :* (ulist :< 0)) * uvec ) :* ulistinterval
	
	
	////////////////////////////////////////////////////////////////////////////
	// Step 2
	mu1d0plus = J(3,length(ylist),0)
	mu1d0minus = J(3,length(ylist),0)
	mu2d0plus = J(3,1,0)
	mu2d0minus = J(3,1,0)
	mu1d1plus = J(3,length(ylist),0)
	mu1d1minus = J(3,length(ylist),0)
	mu2d1plus = J(3,1,0)
	mu2d1minus = J(3,1,0)
	kernel(x:/h, kout)
	reg = diag( 0.05 :* (n/h) :* (1 \ variance(x)^0.5 \ variance(x)) ) // diag(J(3,1,0.1*n/h))
	
	xplus = (x :> 0)
	indep_plus = kout:^0.5 :* xplus, (x:/h) :* kout:^0.5 :* xplus, (x:/h):^2 :* kout:^0.5 :* xplus
	xminus = (x :<= 0)
	indep_minus = kout:^0.5 :* xminus, (x:/h) :* kout:^0.5 :* xminus, (x:/h):^2 :* kout:^0.5 :* xminus
	
	dval = 0	
	for( idx = 1 ; idx <= length(ylist) ; idx++ ){
		yval = ylist[idx]
		dep_plus = ( y :<= yval ) :* ( d :== dval ) :* kout:^0.5 :* xplus
		mu1d0plus[.,idx] = luinv( indep_plus' * indep_plus :+ reg ) * indep_plus' * dep_plus
		mu1d0plus[.,idx] = mu1d0plus[.,idx] :* (1 \ 1 \ 2)
		dep_minus = ( y :<= yval ) :* ( d :== dval ) :* kout:^0.5 :* xminus
		mu1d0minus[.,idx] = luinv( indep_minus' * indep_minus :+ reg ) * indep_minus' * dep_minus
		mu1d0minus[.,idx] = mu1d0minus[.,idx] :* (1 \ 1 \ 2)
	}	
	dep_plus = ( d :== dval ) :* kout:^0.5 :* xplus
	mu2d0plus[.,1] = luinv( indep_plus' * indep_plus :+ reg ) * indep_plus' * dep_plus
	mu2d0plus[.,1] = mu2d0plus[.,1] :* (1 \ 1 \ 2)
	dep_minus = ( d :== dval ) :* kout:^0.5 :* xminus
	mu2d0minus[.,1] = luinv( indep_minus' * indep_minus :+ reg ) * indep_minus' * dep_minus
	mu2d0minus[.,1] = mu2d0minus[.,1] :* (1 \ 1 \ 2)
	
	dval = 1	
	for( idx = 1 ; idx <= length(ylist) ; idx++ ){
		yval = ylist[idx]
		dep_plus = ( y :<= yval ) :* ( d :== dval ) :* kout:^0.5 :* xplus
		mu1d1plus[.,idx] = luinv( indep_plus' * indep_plus :+ reg ) * indep_plus' * dep_plus
		mu1d1plus[.,idx] = mu1d1plus[.,idx] :* (1 \ 1 \ 2)
		dep_minus = ( y :<= yval ) :* ( d :== dval ) :* kout:^0.5 :* xminus
		mu1d1minus[.,idx] = luinv( indep_minus' * indep_minus :+ reg ) * indep_minus' * dep_minus
		mu1d1minus[.,idx] = mu1d1minus[.,idx] :* (1 \ 1 \ 2)
	}	
	dep_plus = ( d :== dval ) :* kout:^0.5 :* xplus
	mu2d1plus[.,1] = luinv( indep_plus' * indep_plus :+ reg ) * indep_plus' * dep_plus
	mu2d1plus[.,1] = mu2d1plus[.,1] :* (1 \ 1 \ 2)
	dep_minus = ( d :== dval ) :* kout:^0.5 :* xminus
	mu2d1minus[.,1] = luinv( indep_minus' * indep_minus :+ reg ) * indep_minus' * dep_minus
	mu2d1minus[.,1] = mu2d1minus[.,1] :* (1 \ 1 \ 2)
	
	////////////////////////////////////////////////////////////////////////////
	// Step 3
	FY0 = ( mu1d0plus[2,.] :- mu1d0minus[2,.] ) :/ ( mu2d0plus[2,1] - mu2d0minus[2,1] )
	FY0 = ( FY0 :< 0 ) :* 0 :+ ( FY0 :>= 0 :& FY0 :<= 1 ) :* FY0 :+ ( FY0 :>1 ) :* 1
	FY0 = sort(FY0',1)'
	FY1 = ( mu1d1plus[2,.] :- mu1d1minus[2,.] ) :/ ( mu2d1plus[2,1] - mu2d1minus[2,1] )
	FY1 = ( FY1 :< 0 ) :* 1 :+ ( FY1 :>= 0 :& FY1 :<= 1 ) :* FY1 :+ ( FY1 :>1 ) :* 1
	FY1 = sort(FY1',1)'
	
	//FY0',FY1'
	
	////////////////////////////////////////////////////////////////////////////
	// Step 4
	QY0 = qlist :* 0
	QY1 = qlist :* 0
	
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		theta = qlist[idx]
		QY0[idx] = min( select(ylist, FY0 :>= theta) )
		QY1[idx] = min( select(ylist, FY1 :>= theta) )
	}
	
	//qlist',QY0',QY1'
	
	////////////////////////////////////////////////////////////////////////////
	// Step 5
	tau = QY1 :- QY0
	
	//qlist',tau'
	
	printf("\nEstimating Variance\n")
	
	////////////////////////////////////////////////////////////////////////////
	// Step 6
	indep_plus = 1 :* xplus, (x:/h) :* xplus, (x:/h):^2 :* xplus
	indep_minus = 1 :* xminus, (x:/h) :* xminus, (x:/h):^2 :* xminus
	mu1tilded0 = indep_plus * mu1d0plus :- indep_minus * mu1d0minus
	mu1tilded1 = indep_plus * mu1d1plus :- indep_minus * mu1d0minus
	mu2tilded0 = indep_plus * mu2d0plus :- indep_minus * mu2d0minus
	mu2tilded1 = indep_plus * mu2d1plus :- indep_minus * mu2d0minus
	
	////////////////////////////////////////////////////////////////////////////
	// Step 7
	muud0plus = J(3,length(ylist),0)
	muud0minus = J(3,length(ylist),0)
	muud1plus = J(3,length(ylist),0)
	muud1minus = J(3,length(ylist),0)
	bn = 1.06 * variance(y)^0.5 / n^0.2
	
	dval = 0	
	for( idx = 1 ; idx <= length(ylist) ; idx++ ){
		yval = ylist[idx]
		kernel((y:-yval):/bn, kout)
		dep_plus = kout:/bn :* ( d :== dval ) :* kout:^0.5 :* xplus
		muud0plus[.,idx] = luinv( indep_plus' * indep_plus :+ reg ) * indep_plus' * dep_plus
		muud0plus[.,idx] = muud0plus[.,idx] :* (1 \ 1 \ 2)
		dep_minus = kout:/bn :* ( d :== dval ) :* kout:^0.5 :* xminus
		muud0minus[.,idx] = luinv( indep_minus' * indep_minus :+ reg ) * indep_minus' * dep_minus
		muud0minus[.,idx] = muud0minus[.,idx] :* (1 \ 1 \ 2)
	}	
	
	dval = 1	
	for( idx = 1 ; idx <= length(ylist) ; idx++ ){
		yval = ylist[idx]
		kernel((y:-yval):/bn, kout)
		dep_plus = kout:/bn :* ( d :== dval ) :* kout:^0.5 :* xplus
		muud1plus[.,idx] = luinv( indep_plus' * indep_plus :+ reg ) * indep_plus' * dep_plus
		muud1plus[.,idx] = muud1plus[.,idx] :* (1 \ 1 \ 2)
		dep_minus = kout:/bn :* ( d :== dval ) :* kout:^0.5 :* xminus
		muud1minus[.,idx] = luinv( indep_minus' * indep_minus :+ reg ) * indep_minus' * dep_minus
		muud1minus[.,idx] = muud1minus[.,idx] :* (1 \ 1 \ 2)
	}	
	
	////////////////////////////////////////////////////////////////////////////
	// Step 8
	kernel(x :/ ( 1.06 * variance(x)^0.5 / n^0.2 ), kout)
	fX = sum( kout ) / ( n * 1.06 * variance(x)^0.5 / n^0.2 )
	
	////////////////////////////////////////////////////////////////////////////
	// Step 9
	threshold = 0.01 / variance(select(y, abs(x):<variance(x)^0.5))^0.5
	fY0VX = ( muud0plus[2,.] :- muud0minus[2,.] ) :/ ( mu2d0plus[2,1] - mu2d0minus[2,1] )
	fY0VX = ( fY0VX :< threshold ) :* threshold :+ ( fY0VX :>= threshold ) :* fY0VX
	fY1VX = ( muud1plus[2,.] :- muud1minus[2,.] ) :/ ( mu2d1plus[2,1] - mu2d1minus[2,1] )
	fY1VX = ( fY1VX :< threshold ) :* threshold :+ ( fY1VX :>= threshold ) :* fY1VX
	
	//fY0VX',fY1VX'
	
	////////////////////////////////////////////////////////////////////////////
	// Steps 10-13
	////////////////////////////////////////////////////////////////////////////
	// First compute the influence functions
	inf1d0plus = J(n,length(ylist),0)
	inf1d0minus = J(n,length(ylist),0)
	inf2d0plus = J(n,1,0)
	inf2d0minus = J(n,1,0)
	inf1d1plus = J(n,length(ylist),0)
	inf1d1minus = J(n,length(ylist),0)
	inf2d1plus = J(n,1,0)
	inf2d1minus = J(n,1,0)
	kernel( x:/h, kout )
	r3 = J(n,1,1), (x:/h), (x:/h):^2, (x:/h):^3
	
	dval = 0
	for( idx = 1 ; idx <= length(ylist) ; idx++ ){
		yval = y[idx]
		inf1d0plus[.,idx] = (r3 * GAMMAplus)[.,2] :* ( ( y :<= yval ) :* ( d :== dval ) :- mu1tilded0[.,idx] ) :* kout :* xplus :/ ( (n*h)^0.5 * fX )
		inf1d0minus[.,idx] = (r3 * GAMMAminus)[.,2] :* ( ( y :<= yval ) :* ( d :== dval ) :- mu1tilded0[.,idx] ) :* kout :* xminus :/ ( (n*h)^0.5 * fX )
	}
	inf2d0plus[.,1] = (r3 * GAMMAplus)[.,2] :* ( ( d :== dval ) :- mu2tilded0[.,1] ) :* kout :* xplus :/ ( (n*h)^0.5 * fX )
	inf2d0minus[.,1] = (r3 * GAMMAminus)[.,2] :* ( ( d :== dval ) :- mu2tilded0[.,1] ) :* kout :* xminus :/ ( (n*h)^0.5 * fX )
	
	dval = 1
	for( idx = 1 ; idx <= length(ylist) ; idx++ ){
		yval = y[idx]
		inf1d1plus[.,idx] = (r3 * GAMMAplus)[.,2] :* ( ( y :<= yval ) :* ( d :== dval ) :- mu1tilded1[.,idx] ) :* kout :* xplus :/ ( (n*h)^0.5 * fX )
		inf1d1minus[.,idx] = (r3 * GAMMAminus)[.,2] :* ( ( y :<= yval ) :* ( d :== dval ) :- mu1tilded1[.,idx] ) :* kout :* xminus :/ ( (n*h)^0.5 * fX )
	}
	inf2d1plus[.,1] = (r3 * GAMMAplus)[.,2] :* ( ( d :== dval ) :- mu2tilded1[.,1] ) :* kout :* xplus :/ ( (n*h)^0.5 * fX )
	inf2d1minus[.,1] = (r3 * GAMMAminus)[.,2] :* ( ( d :== dval ) :- mu2tilded1[.,1] ) :* kout :* xminus :/ ( (n*h)^0.5 * fX )
	
	////////////////////////////////////////////////////////////////////////////
	// Second multiplier bootstrap
	num_boot = 500
	XI = J(length(qlist),num_boot,1)
	
	for( boot_iter = 1 ; boot_iter <= num_boot ; boot_iter++ ){
		xi = invnormal(uniform(n,1))
		
		nu1d0plus = xi' * inf1d0plus
		nu1d0minus = xi' * inf1d0minus
		nu1d1plus = xi' * inf1d1plus
		nu1d1minus = xi' * inf1d1minus
		nu2d0plus = xi' * inf2d0plus
		nu2d0minus = xi' * inf2d0minus
		nu2d1plus = xi' * inf2d1plus
		nu2d1minus = xi' * inf2d1minus
		
		Zd0 = ( mu2d0plus[2,.] :- mu2d0minus[2,.] ) :* ( nu1d0plus :- nu1d0minus ) :/ ( mu2d0plus[2,.] :- mu2d0minus[2,.] ):^2 :- ( mu1d0plus[2,.] :- mu1d0minus[2,.] ) :* ( nu2d0plus :- nu2d0minus ) :/ ( mu2d0plus[2,.] :- mu2d0minus[2,.] ):^2
		Zd1 = ( mu2d1plus[2,.] :- mu2d1minus[2,.] ) :* ( nu1d1plus :- nu1d1minus ) :/ ( mu2d1plus[2,.] :- mu2d1minus[2,.] ):^2 :- ( mu1d1plus[2,.] :- mu1d1minus[2,.] ) :* ( nu2d1plus :- nu2d1minus ) :/ ( mu2d1plus[2,.] :- mu2d1minus[2,.] ):^2
		
		for( idx = 1 ; idx <= length(qlist) ; idx++ ){
			QY0idx = length( select(ylist, (ylist :> QY0[idx]) :== 0 ) )
			QY1idx = length( select(ylist, (ylist :> QY1[idx]) :== 0 ) )
			
			XI[idx,boot_iter] = -1 * (Zd1[QY1idx] / fY1VX[QY1idx] - Zd0[QY0idx] / fY0VX[QY0idx] )
		}
	}
	
	for( idx = 1 ; idx <= rows(XI) ; idx++ ){
		lowXI = sort(XI[idx,.]',1)[trunc(0.005*num_boot)+1]
		highXI = sort(XI[idx,.]',1)[trunc(0.995*num_boot)]
		XI[idx,.] = (XI[idx,.] :< lowXI) :* lowXI :+ (lowXI :<= XI[idx,.] :& XI[idx,.] :<= highXI) :* XI[idx,.] :+ (highXI :< XI[idx,.]) :* highXI
	}
	
	//XI :/ (n*h^3)^0.5

	////////////////////////////////////////////////////////////////////////////
	// Hypothesis Testing
	WS = (n*h^1)^0.5 * max(abs(tau))
	WH = (n*h^1)^0.5 * max(abs( tau :- mean(tau) ))
	
	WSboot = J(num_boot,1,0)
	WHboot = J(num_boot,1,0)
	for( idx = 1 ; idx <= num_boot ; idx++ ){
	    WSboot[idx] = max(abs( XI[.,idx]))
		WHboot[idx] = max(abs( XI[.,idx] :- mean(XI[.,idx]) ))
	}
	pvalueWS = mean( 1 * (WSboot :> WS) )
	pvalueWH = mean( 1 * (WHboot :> WH) )
	
	////////////////////////////////////////////////////////////////////////////
	// Uniform confidence band
	maxXI = J(1,num_boot,0)
	for( idx = 1 ; idx <= num_boot ; idx++ ){
		maxXI[idx] = max( abs(XI[,idx]) )
	}
	halfwidth = sort(maxXI',1)[trunc(cover*num_boot)]
	b = tau
	bu = tau :+ halfwidth :/ (n*h^3)^0.5
	bl = tau :- halfwidth :/ (n*h^3)^0.5
	
	////////////////////////////////////////////////////////////////////////////
	// Estimation Results
	b = tau
	V = (XI * XI') :/ num_boot :- ((XI * J(num_boot,1,1)) :/ num_boot) * ((XI * J(num_boot,1,1)) :/ num_boot)'

    st_matrix(bname, b)
    st_matrix(Vname, V)
    st_numscalar(nname, n)
	st_local("nq",strofreal(length(qlist)))
	st_matrix("_qq",qlist:*100)

	////////////////////////////////////////////////////////////////////////////
	// Console output
	printf("\n{hline 78}\n")
	printf(  "Fuzzy Regression Kink Design\n")
	printf(  "Number of observations:                                        n = %f\n", n)
	printf(  "The kink location of the running variable:                     k = %f\n", cut)
	printf(  "{hline 78}\n")
	printf(  "Quantile          QTE     [%2.0f%% Unif. Conf. Band]\n",100*cover)
	printf(  "{hline 48}\n")
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
	    printf("   %5.3f   %10.5f   %10.5f   %10.5f\n",qlist[idx],b[idx],bl[idx],bu[idx])
	}
	printf(  "{hline 78}\n")
	printf(  "Test of the hypothesis that QTE=0 for all quantiles:           p-value = %4.3f\n", pvalueWS)
	printf(  "Test of the hypothesis that QTE is constant across quantiles:  p-value = %4.3f\n", pvalueWH)
	printf(  "{hline 78}\n")
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
