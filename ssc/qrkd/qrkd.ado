////////////////////////////////////////////////////////////////////////////////
// STATA FOR  Chiang, H.D. & Sasaki, Y. (2019): Causal Inference by Quantile
//            Regression Kink Designs. Journal of Econometrics 210 (2), 405-433.
//
// Use it when you consider a regression kink design and you are interested in 
// analyzing heterogeneous causal effects (e.g., heterogeneous effects of 
// unemployment insurance on unemployment duration).
////////////////////////////////////////////////////////////////////////////////
program define qrkd, rclass
    version 14.2
 
    syntax varlist(numeric) [if] [in] [, k(real 0) bpl(real 0) bpr(real 1) cover(real 0.95) ql(real 0.25) qh(real 0.75) qn(real 3) bw(real -1)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname b V N cb

	mata: estimate_qrkd("`depvar'", "`cnames'", ///
						`k', `bpr', `bpl', ///
						`ql', `qh', `qn', ///
						`bw', "`touse'", ///
						"`b'", "`V'", "`N'", ///
						`cover', "`cb'") 

	//matrix colnames `b' = QRKD
	//matrix colnames `V' = QRKD
	//matrix rownames `V' = QRKD
	
    //ereturn post `b' `V', esample(`touse') buildfvinfo
    //ereturn scalar N    = `N'
    //ereturn local  cmd  "qrkd"
end

		
		
		
		
mata:
//////////////////////////////////////////////////////////////////////////////// 
// Kernel Function
void kernel(u, kout){
	kout = (70/81) :* (1 :- (u:^2):^(3/2) ):^3 :* ( -1 :< u ) :* ( u :< 1 )
}
//////////////////////////////////////////////////////////////////////////////// 
// Smoothed Check Function
void check(u, tau, smooth, checkout){
	ch1 = (u :- smooth) :* (tau :- (u :- smooth :< 0) )
	ch2 = (u :- smooth:/2) :* (tau :- (u :- smooth:/2 :< 0) )
    ch3 = (u) :* (tau :- (u :< 0) )
    ch4 = (u :+ smooth:/2) :* (tau :- (u :+ smooth:/2 :< 0) )
	ch5 = (u :+ smooth) :* (tau :- (u :+ smooth :< 0) )
	checkout = ch1 :/ 5 + ch2 :/ 5 + ch3 :/ 5 + ch4 :/ 5 + ch5 :/ 5
}
//////////////////////////////////////////////////////////////////////////////// 
// Function for the Criterion
void qcrit(todo, para, y, x, h, tau, crit, g, H){
	alph = para[1]
	beta1plus = para[2]
	beta1minus = para[3]
	beta2plus = para[4]
	beta2minus = para[5]
	
	real matrix checkout
	real matrix kout
	
	smooth = variance(x)^0.5 / 1000
	check(y :- alph :- beta1plus :* x :* (x :> 0) :- beta1minus :* x :* (x :< 0) :- beta2plus :* x:^2 :* (x :> 0) :/ 2 :- beta2minus :* x:^2 :* (x :< 0) :/ 2, tau, smooth, checkout)

	kernel(x:/h, kout)
	
	crit = sum( kout :* checkout ) + rows(y) * 0.001 * sum( beta2plus^2 + beta2minus^2 )
}
//////////////////////////////////////////////////////////////////////////////// 
// Estimation of QRKD
void estimate_qrkd( string scalar yv,      string scalar xv,
					real scalar cut, 	   real scalar bpright, 	real scalar bpleft,
					real scalar q_low, 	   real scalar q_high, 	   	real scalar q_num,
					real scalar b_w,	   string scalar touse,   
					string scalar bname,   string scalar Vname,     string scalar nname,
					real scalar cover, 	   string scalar cbname) 
{
	printf("\n{hline 78}\n")
	printf("Executing:  Chiang, H.D. & Sasaki, Y. (2019): Causal Inference by Quantile\n")
	printf("            Regression Kink Designs. Journal of Econometrics 210 (2), 405-433.\n")
	printf("{hline 78}\n")
    real vector y, x, beta1plus_hat, beta1minus_hat, qrkd_hat   
    real scalar cutoff, n
 
    y      = st_data(., yv, touse)
    x      = st_data(., xv, touse) :- cut
    n      = rows(y)
	// List of quantiles at which to evaluate causal effects
	qlist = (q_high - q_low) :* (0..(q_num-1)) :/ (q_num-1) :+ q_low
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate QRKD
	init_alpha = J(length(qlist),1,0)
	alph_hat = J(length(qlist),1,0)
	beta1plus_hat = J(length(qlist),1,0)
	beta1minus_hat = J(length(qlist),1,0)
	qrkd_hat = J(length(qlist),1,0)
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
	    printf("Iteration %f/%f: Estimating QRKD at the %f-th quantile\n", idx, length(qlist)+1, qlist[idx])
		
		h = b_w
		if( b_w <= 0 ){
			h = 10 * variance(x)^0.5 * variance(y)^0.5 / n^0.2
		}

		tau = qlist[idx]

		////////////////////////////////////////////////////////////////////////
		// Set initial parameter values
		xleft = select(x, x :<= 0)
		xleft = J(rows(xleft),1,1), xleft
		xright = select(x, x :> 0)
		xright = J(rows(xright),1,1), xright
		yleft = select(y, x :<= 0)
		yright = select(y, x :> 0)
		yclose = select(y, -variance(x):^0.5:/2 :<= x :& x :<= variance(x):^0.5:/2)
		init_alpha[idx] = sort(yclose,1)[trunc(rows(yclose)*tau)]
		beta1plus = (luinv(xright'*xright)*xright'*yright)[2,1]
		beta1minus = (luinv(xleft'*xleft)*xleft'*yleft)[2,1]
		beta2plus = 0
		beta2minus = 0
		initpara = (init_alpha[idx], beta1plus, beta1minus, beta2plus, beta2minus)
	
		////////////////////////////////////////////////////////////////////////
		// Optimization routine
		S = optimize_init()
		optimize_init_evaluator(S,&qcrit())
		optimize_init_which(S,"min")
		optimize_init_evaluatortype(S, "d0")
		optimize_init_technique(S,"nr")
		optimize_init_singularHmethod(S,"hybrid") 
		optimize_init_argument(S,1,y)
		optimize_init_argument(S,2,x)
		optimize_init_argument(S,3,h)
		optimize_init_argument(S,4,tau)
		optimize_init_tracelevel(S, "none")
		optimize_init_conv_warning(S, "off")
		optimize_init_params(S, initpara)
		est=optimize(S)	
		alph_hat[idx] = est[1]
		beta1plus_hat[idx] = est[2]
		beta1minus_hat[idx] = est[3]
		qrkd_hat[idx] = (beta1plus_hat[idx] - beta1minus_hat[idx]) / (bpright - bpleft)  
	}

	////////////////////////////////////////////////////////////////////////////
	// Compute K_{in\tau} and z_{in\tau}
	real matrix Kintau, zintau
	kernel(x:/h, Kintau)
	Kintau = Kintau, Kintau, Kintau, Kintau, Kintau
	zintau = J(n,1,1), x :/ h :* (x :> 0), x :/ h :* (x :<= 0), (x :/ h):^2 :* (x :> 0), (x :/ h):^2 :* (x :<= 0)
	
	////////////////////////////////////////////////////////////////////////////
	// Compute the N matrix
	Nmatrix = J(5,5,0)
	ulist = (-100..100) :/ 100
	ulistinterval = ulist[1] - ulist[2]
	real matrix kernelulist
	kernel(ulist, kernelulist)
	for( idx = 1 ; idx <= length(ulist) ; idx++ ){
	    u = ulist[idx]
		ubar = 1 \ u * (u > 0) \ u * (u <= 0) \ u^2 * (u > 0) \ u^2 * (u <= 0)
		Nmatrix = Nmatrix + ( (ubar * ubar') :* (ulistinterval * kernelulist[idx]) )
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Compute other auxiliary objects for variance estimation
	i2minusi3 = (0 \ 1 \ -1 \ 0 \ 0)
	corr_xy = mean( x :* y ) - mean(x) * mean(y)
	corr_xy = corr_xy / (variance(x) * variance(y))^0.5
	hx = variance(x)^0.5 / n^(1/5)
	hxx = 5 * variance(x)^(1.5/2) * variance(y)^(1/2) / n^(1/6) // 10 * variance(x)^0.5 / n^(1/6)
	real matrix kxlist, kxxlist
	kernel(x:/hx, kxlist)
	kernel(x:/hxx, kxxlist)
	fx = mean(kxlist)/hx
	hy = hxx / variance(x)^(1/2) //10 * variance(y)^0.5 / n^(1/6)
	fyx = J(length(qlist),1,1)
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){		
		real matrix kylist
		kernel((y :- alph_hat[idx]):/hy, kylist)
		fyx[idx] = ( mean(kxxlist :* kylist) / (hxx * hy) ) / ( mean(kxxlist) / hxx )
	}

	////////////////////////////////////////////////////////////////////////////
	// Pivotal approach to variance estimation
	printf("Iteration %f/%f: Variance Estimation\n", length(qlist)+1, length(qlist)+1)
	num_bootstrap = 4000
	Ylist = J(length(qlist),num_bootstrap,0)
	
	for( idx = 1 ; idx <= num_bootstrap ; idx++ ){
		unif = uniform(n,1)
		unif = unif, unif, unif, unif, unif
		
		for( jdx = 1 ; jdx <= length(qlist) ; jdx++ ){
			numerator = i2minusi3' * luinv(Nmatrix) * ( zintau :* Kintau :* (qlist[jdx] :- 1:*(unif :<= qlist[jdx])) )' * J(n,1,1)
			denominator = (bpright - bpleft) * (n*h)^0.5 * fx * fyx[jdx]
			Ylist[jdx,idx] = numerator / denominator
		}
	}
	
	sigma = ( diagonal(Ylist * Ylist' :/ num_bootstrap - (Ylist :/ num_bootstrap) * (Ylist :/ num_bootstrap)')  :/ (n*h^3) ):^0.5
	
	////////////////////////////////////////////////////////////////////////////
	// Standardized pivotal approach
	Ystdlist = J(length(qlist),num_bootstrap,0)
	
	for( idx = 1 ; idx <= num_bootstrap ; idx++ ){
		unif = uniform(n,1)
		unif = unif, unif, unif, unif, unif
		
		for( jdx = 1 ; jdx <= length(qlist) ; jdx++ ){
			numerator = i2minusi3' * luinv(Nmatrix) * ( zintau :* Kintau :* (qlist[jdx] :- 1:*(unif :<= qlist[jdx])) )' * J(n,1,1)
			denominator = (bpright - bpleft) * (n*h)^0.5 * fx * fyx[jdx]
			Ystdlist[jdx,idx] = numerator / denominator / sigma[jdx]
		}
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Hypothesis testing
	WS = (n*h^3)^0.5 * max(abs(qrkd_hat))
	WH = (n*h^3)^0.5 * max(abs( qrkd_hat :- mean(qrkd_hat) ))
	
	WSboot = J(num_bootstrap,1,0)
	WHboot = J(num_bootstrap,1,0)
	for( idx = 1 ; idx <= num_bootstrap ; idx++ ){
	    WSboot[idx] = max(abs(Ylist[.,idx]))
		WHboot[idx] = max(abs( Ylist[.,idx] :- mean(Ylist[.,idx]) ))
	}
	pvalueWS = mean( 1 * (WSboot :> WS) )
	pvalueWH = mean( 1 * (WHboot :> WH) )
	
	////////////////////////////////////////////////////////////////////////////
	// Uniform confidence band
	WSbootStd = J(num_bootstrap,1,0)
	for( idx = 1 ; idx <= num_bootstrap ; idx++ ){
	    WSbootStd[idx] = max(abs(Ystdlist[.,idx]))
	}
	halfbandlength = ( sort(WSbootStd,1)[trunc(cover * num_bootstrap)] / (n*h^3)^0.5 ) :* sigma

	////////////////////////////////////////////////////////////////////////////
	// Set b, V, n and cb
	b = qrkd_hat'
	V = Ylist * Ylist' :/ num_bootstrap - (Ylist :/ num_bootstrap) * (Ylist :/ num_bootstrap)'
	V = V :/ (n*h^3)
	bu = qrkd_hat' :+ halfbandlength'
	bl = qrkd_hat' :- halfbandlength'
	
	revb = J(1,length(qlist),1)
	revqlist = J(1,length(qlist),1)
	for( idx = 1 ; idx <= length(qlist); idx++ ){
	    revb[idx] = b[length(qlist)+1-idx]
	    revqlist[idx] = qlist[length(qlist)+1-idx]
	}
	
	bbb95 = b[1] \ bu' \ revb' \ bl' \ b[length(qlist)]
	qqq95 = qlist[1] \ qlist' \ revqlist' \ qlist' \ qlist[length(qlist)]
    st_matrix(bname, b)
    st_matrix(Vname, V)
    st_numscalar(nname, n)
    st_matrix(cbname, (bbb95,qqq95))
	
	////////////////////////////////////////////////////////////////////////////
	// Console output
	printf("\n{hline 78}\n")
	printf(  "Number of observations:                                        n = %f\n", n)
	printf(  "The kink location of the running variable:                     k = %f\n", cut)
	printf(  "The derivative of policy function on the left:            b'(k-) = %f\n", bpleft)
	printf(  "The derivative of policy function on the right:           b'(k+) = %f\n", bpright)
	printf(  "{hline 78}\n")
	printf(  "Quantile         QRKD     [%2.0f%% Unif. Conf. Band]\n",100*cover)
	printf(  "{hline 48}\n")
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
	    printf("   %5.3f   %10.5f   %10.5f   %10.5f\n",qlist[idx],b[idx],bl[idx],bu[idx])
	}
	printf(  "{hline 78}\n")
	printf(  "Test of the hypothesis that QRKD=0 for all quantiles:          p-value = %4.3f\n", pvalueWS)
	printf(  "Test of the hypothesis that QRKD is constant across quantiles: p-value = %4.3f\n", pvalueWH)
	printf(  "{hline 78}\n")
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
