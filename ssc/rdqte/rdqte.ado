////////////////////////////////////////////////////////////////////////////////
// STATA FOR        Chiang, H.D., Hsu, Y.-C. & Sasaki, Y. (2019): Robust Uniform 
// Inference for Quantile Treatment Effects in Regression Discontinuity Designs. 
// Journal of Econometrics 211 (2), 589-618.
//
// Use it when you consider a regression discontinuity design and you are 
// interested in analyzing heterogeneous causal effects.
////////////////////////////////////////////////////////////////////////////////
program define rdqte, eclass
    version 14.2
 
    syntax varlist(numeric) [if] [in] [, c(real 0) fuzzy(varname numeric) cover(real 0.95) ql(real 0.25) qh(real 0.75) qn(real 3) bw(real -1)]
    marksample touse
 
    gettoken depvar indepvars : varlist
    _fv_check_depvar `depvar'
    fvexpand `indepvars' 
    local cnames `r(varlist)'
 
    tempname b V N cb

	// Case of Sharp Design ////////////////////////////////////////////////////
	if "`fuzzy'" == "" {
		mata: estimate_sharpqte("`depvar'", "`cnames'", ///
							    `c', `ql', `qh', ///
						        `qn', `bw', "`touse'", ///
						        "`b'", "`V'", "`N'", ///
						        `cover', "`cb'")
   	} //END IF SHARP////////////////////////////////////////////////////////////
	
	// Case of Fuzzy Design ////////////////////////////////////////////////////
	if "`fuzzy'" != "" {
		tempvar treat
		gen `treat' = `fuzzy'
		mata: estimate_fuzzyqte("`depvar'", "`cnames'", "`treat'", ///
							    `c', `ql', `qh', ///
						        `qn', `bw', "`touse'", ///
						        "`b'", "`V'", "`N'", ///
						        `cover', "`cb'")
   	} //END IF FUZZY////////////////////////////////////////////////////////////
	
	matrix colnames `b' = QTE
	matrix colnames `V' = QTE
	matrix rownames `V' = QTE
	
    ereturn post `b' `V', esample(`touse') buildfvinfo
    ereturn scalar N    = `N'
    ereturn local  cmd  "rdqte"
end

		
			
		
mata:
//////////////////////////////////////////////////////////////////////////////// 
// Kernel Function
void kernel(u, kout){
	kout = 0.75 :* ( 1 :- (u:^2) ) :* ( -1 :< u ) :* ( u :< 1 )
	// kout = (70/81) :* (1 :- (u:^2):^(3/2) ):^3 :* ( -1 :< u ) :* ( u :< 1 )
}
//////////////////////////////////////////////////////////////////////////////// 
// Estimation of QTE in the Sharp Design
void estimate_sharpqte( string scalar yv,      string scalar xv,	
						real scalar cut, 	   real scalar q_low, 	   real scalar q_high, 	  
						real scalar q_num, 	   real scalar b_w,	       string scalar touse,   
						string scalar bname,   string scalar Vname,    string scalar nname,
						real scalar cover, 	   string scalar cbname) 
{
	printf("\n{hline 78}\n")
	printf("Executing:    Chiang, H.D., Hsu, Y.-C. & Sasaki, Y. (2019): Robust Uniform    \n")
	printf("              Inference for Quantile Treatment Effects in Regression          \n")
	printf("              Discontinuity Designs. Journal of Econometrics 211 (2), 589-618.\n")
	printf("{hline 78}\n")
    real vector y, d, x, qlist
    real scalar n
 
    y      = st_data(., yv, touse)
    x      = st_data(., xv, touse) :- cut
	d      = x :> 0
    n      = rows(y)
	// List of quantiles at which to evaluate causal effects
	qlist = (q_high - q_low) :* (0..(q_num-1)) :/ (q_num-1) :+ q_low
	// Grid of y values at which the Wald ratio is ccomputed
	y_num = 5000
	ylist = (sort(y,1)[trunc(n*0.99)] - sort(y,1)[trunc(n*0.01)]) :* (0..(y_num-1)) :/ (y_num-1) :+ sort(y,1)[trunc(n*0.01)]
	// Bandwidth
	h = b_w
	if( b_w <= 0 ){
		h = variance(x)^0.5 / n^0.2
	}

	////////////////////////////////////////////////////////////////////////////
	// Estimate Wald Ratios
	real vector kout
	kernel(x :/ h, kout)
	wald_d0 = J(length(ylist),1,0)
	wald_d1 = J(length(ylist),1,0)
	mu1d0plus = J(length(ylist),1,0)
	mu1d0minus = J(length(ylist),1,0)
	mu1d1plus = J(length(ylist),1,0)
	mu1d1minus = J(length(ylist),1,0)
	reg = diag((0.05*n/h) :* (1 \ variance(x)^0.5 \ variance(x)))
	
	Xplus = kout:^0.5, x :* kout:^0.5, x:^2 :/ 2 :* kout:^0.5 :* (x :> 0)
	Xminus = kout:^0.5, x :* kout:^0.5, x:^2 :/ 2 :* kout:^0.5 :* (x :<= 0)
	
	dval = 0
	Dplus = (d :== dval) :* kout:^0.5 :* (x :> 0)
	Dminus = (d :== dval) :* kout:^0.5 :* (x :<= 0)
	mu2plus = luinv( Xplus' * Xplus :+ reg ) * Xplus' * Dplus
	mu2minus = luinv( Xminus' * Xminus :+ reg ) * Xminus' * Dminus
	mu2d0plus = mu2plus[1]
	mu2d0minus = mu2minus[1]
	for( idx = 1 ; idx <= y_num ; idx++ ){
		yval = ylist[idx]
		YDplus = (y :<= yval) :* (d :== dval) :* kout:^0.5 :* (x :> 0)
		YDminus = (y :<= yval) :* (d :== dval) :* kout:^0.5 :* (x :<= 0)
		mu1plus = luinv( Xplus' * Xplus :+ reg ) * Xplus' * YDplus
		mu1minus = luinv( Xminus' * Xminus :+ reg ) * Xminus' * YDminus
		mu1d0plus[idx] = mu1plus[1]
		mu1d0minus[idx] = mu1minus[1]
		wald_d0[idx] = (mu1plus[1] - mu1minus[1]) / (mu2plus[1] - mu2minus[1])
		wald_d0[idx] = (wald_d0[idx] < 0)*0 + (wald_d0[idx] >= 0)*wald_d0[idx]
		wald_d0[idx] = (wald_d0[idx] > 1)*1 + (wald_d0[idx] <= 1)*wald_d0[idx]
	}
	wald_d0 = sort(wald_d0,1)
	
	dval = 1
	Dplus = (d :== dval) :* kout:^0.5 :* (x :> 0)
	Dminus = (d :== dval) :* kout:^0.5 :* (x :<= 0)
	mu2plus = luinv( Xplus' * Xplus :+ reg ) * Xplus' * Dplus
	mu2minus = luinv( Xminus' * Xminus :+ reg ) * Xminus' * Dminus	
	mu2d1plus = mu2plus[1]
	mu2d1minus = mu2minus[1]
	for( idx = 1 ; idx <= y_num ; idx++ ){
		yval = ylist[idx]
		YDplus = (y :<= yval) :* (d :== dval) :* kout:^0.5 :* (x :> 0)
		YDminus = (y :<= yval) :* (d :== dval) :* kout:^0.5 :* (x :<= 0)
		mu1plus = luinv( Xplus' * Xplus :+ reg ) * Xplus' * YDplus
		mu1minus = luinv( Xminus' * Xminus :+ reg ) * Xminus' * YDminus
		mu1d1plus[idx] = mu1plus[1]
		mu1d1minus[idx] = mu1minus[1]
		wald_d1[idx] = (mu1plus[1] - mu1minus[1]) / (mu2plus[1] - mu2minus[1])
		wald_d1[idx] = (wald_d1[idx] < 0)*0 + (wald_d1[idx] >= 0)*wald_d1[idx]
		wald_d1[idx] = (wald_d1[idx] > 1)*1 + (wald_d1[idx] <= 1)*wald_d1[idx]
	}
	wald_d1 = sort(wald_d1,1)
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate QTE
	QY0list = qlist
	QY1list = qlist
	QTElist = qlist

	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		q = qlist[idx]
		QY0 = min( select( ylist', wald_d0 :>= q) )
		QY1 = min( select( ylist', wald_d1 :>= q) )
		QY0list[idx] = QY0
		QY1list[idx] = QY1
		QTElist[idx] = QY1 - QY0
	}
	//QTElist
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate Densities in Preparation for Variance Estimation
	hay = variance(y)^0.5 / n^(1/6)
	ha = variance(x)^0.5 / n^(1/6)
	hb = variance(x)^0.5 / n^0.2
	hc = variance(x)^0.5 / n^0.2
	real vector kyout, kouta, koutb
	kernel(x :/ ha, kouta)
	kernel(x :/ hb, koutb)
	kernel(x :/ hc, koutc)
	fx = mean( koutb :/ hb )
	fy0 = J(1,length(qlist),0)
	fy1 = J(1,length(qlist),0)
	
	
	dval = 0
	pd_plus = sum( koutc :* (d :== dval) :* (x :> 0) ) / sum( koutc :* (x :> 0) )
	pd_minus = sum( koutc :* (d :== dval) :* (x :<= 0) ) / sum( koutc :* (x :<= 0) )
	
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		yval = QY0list[idx]
		kernel((y :- yval) :/ hay, kyout)
		fyxd_plus = sum( kouta :* kyout :* (d :== dval) :* (x :> 0) :/ (n*ha*hay) ) / sum( kouta :* (d :== dval) :* (x :> 0) :/ (n*ha) :+ 0.000000001)
		fyxd_minus = sum( kouta :* kyout :* (d :== dval) :* (x :<= 0) :/ (n*ha*hay) ) / sum( kouta :* (d :== dval) :* (x :<= 0) :/ (n*ha) :+ 0.000000001 )
		
		fy0[idx] = ( fyxd_plus * pd_plus - fyxd_minus * pd_minus ) / (mu2d0plus - mu2d0minus)
	}

	dval = 1
	pd_plus = sum( koutc :* (d :== dval) :* (x :> 0) ) / sum( koutc :* (x :> 0) )
	pd_minus = sum( koutc :* (d :== dval) :* (x :<= 0) ) / sum( koutc :* (x :<= 0) )
	
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		yval = QY1list[idx]
		kernel((y :- yval) :/ hay, kyout)
		fyxd_plus = mean( kouta :* kyout :* (d :== dval) :* (x :> 0) :/ (n*ha*hay) ) / mean( kouta :* (d :== dval) :* (x :> 0) :/ (n*ha) :+ 0.000000001)
		fyxd_minus = mean( kouta :* kyout :* (d :== dval) :* (x :<= 0) :/ (n*ha*hay) ) / mean( kouta :* (d :== dval) :* (x :<= 0) :/ (n*ha) :+ 0.000000001 )
		
		fy1[idx] = ( fyxd_plus * pd_plus - fyxd_minus * pd_minus ) / (mu2d1plus - mu2d1minus)
	}

	////////////////////////////////////////////////////////////////////////////
	// Prepare Other Auxiliary Objects for Variance Estimation
	real scalar ku
	Gammaplus = J(3,3,0)
	ulist = (0..100) :/ 100
	for( idx = 1 ; idx <= length(ulist) ; idx++ ){
		u = ulist[idx]
		kernel(u,ku)
		Gammaplus = Gammaplus + ( (1 \ u \ u^2) * (ku) * (1, u, u^2) ) :* (ulist[2]-ulist[1])
	}
	
	Gammaminus = J(3,3,0)
	ulist = (-100..0) :/ 100
	for( idx = 1 ; idx <= length(ulist) ; idx++ ){
		u = ulist[idx]
		kernel(u,ku)
		Gammaminus = Gammaminus + ( (1 \ u \ u^2) * (ku) * (1, u, u^2) ) :* (ulist[2]-ulist[1])
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Influence Functions
	IF1d0plus = J(n,length(qlist),0)
	IF1d0minus = J(n,length(qlist),0)
	IF1d1plus = J(n,length(qlist),0)
	IF1d1minus = J(n,length(qlist),0)
	IF2d0plus = J(n,1,0)
	IF2d0minus = J(n,1,0)
	IF2d1plus = J(n,1,0)
	IF2d1minus = J(n,1,0)

	dval = 0
	IF2d0plus = kout :* ( (d :== dval) :- mu2d0plus ) :* (x :> 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaplus))[1,.]'
	IF2d0plus = IF2d0plus :/ (fx * (n*h)^0.5)
	IF2d0minus = kout :* ( (d :== dval) :- mu2d0minus ) :* (x :<= 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaminus))[1,.]'
	IF2d0minus = IF2d0minus :/ (fx * (n*h)^0.5)
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		yval = QY0list[idx]
		ylistidx = length( select(ylist, ylist :<= yval) )
		IF1d0plus[.,idx] = kout :* ( (y :<= yval) :* (d :== dval) :- mu1d0plus[ylistidx] ) :* (x :> 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaplus))[1,.]'
		IF1d0plus[.,idx] = IF1d0plus[.,idx] :/ (fx * (n*h)^0.5)
		IF1d0minus[.,idx] = kout :* ( (y :<= yval) :* (d :== dval) :- mu1d0minus[ylistidx] ) :* (x :<= 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaminus))[1,.]'
		IF1d0minus[.,idx] = IF1d0minus[.,idx] :/ (fx * (n*h)^0.5)
	}
	
	dval = 1
	IF2d1plus = kout :* ( (d :== dval) :- mu2d1plus ) :* (x :> 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaplus))[1,.]'
	IF2d1plus = IF2d1plus :/ (fx * (n*h)^0.5)
	IF2d1minus = kout :* ( (d :== dval) :- mu2d1minus ) :* (x :<= 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaminus))[1,.]'
	IF2d1minus = IF2d1minus :/ (fx * (n*h)^0.5)
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		yval = QY1list[idx]
		ylistidx = length( select(ylist, ylist :<= yval) )
		IF1d1plus[.,idx] = kout :* ( (y :<= yval) :* (d :== dval) :- mu1d1plus[ylistidx] ) :* (x :> 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaplus))[1,.]'
		IF1d1plus[.,idx] = IF1d1plus[.,idx] :/ (fx * (n*h)^0.5)
		IF1d1minus[.,idx] = kout :* ( (y :<= yval) :* (d :== dval) :- mu1d1minus[ylistidx] ) :* (x :<= 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaminus))[1,.]'
		IF1d1minus[.,idx] = IF1d1minus[.,idx] :/ (fx * (n*h)^0.5)
	}

	////////////////////////////////////////////////////////////////////////////
	// Multiplier Bootstrap
	num_bootstrap = 2500
	Glist = J(length(qlist),num_bootstrap,0)
	maxGlist = J(1,num_bootstrap,0)
	heteroGlist = J(1,num_bootstrap,0)
	
	for( jdx = 1 ; jdx <= num_bootstrap ; jdx++ ){
		xi = invnormal(uniform(n,1))
		
		for( idx = 1 ; idx <= length(qlist) ; idx++ ){
			yval = QY1list[idx]
			ylistidx = length( select(ylist, ylist :<= yval) )
			G = 
			( sum( xi :* IF1d1plus[.,idx] ) - sum( xi :* IF1d1minus[.,idx] ) ) * (mu2d1plus - mu2d1minus) / fy1[idx] / (mu2d1plus - mu2d1minus)^2 -
			( sum( xi :* IF2d1plus ) - sum( xi :* IF2d1minus ) ) * ( mu1d1plus[ylistidx] - mu1d1minus[ylistidx] ) / fy1[idx] / (mu2d1plus - mu2d1minus)^2 -
			( sum( xi :* IF1d0plus[.,idx] ) - sum( xi :* IF1d0minus[.,idx] ) ) * (mu2d0plus - mu2d0minus) / fy0[idx] / (mu2d0plus - mu2d0minus)^2 +
			( sum( xi :* IF2d0plus ) - sum( xi :* IF2d0minus ) ) * ( mu1d0plus[ylistidx] - mu1d0minus[ylistidx] ) / fy0[idx] / (mu2d0plus - mu2d0minus)^2
			Glist[idx,jdx] = G
		}
		maxGlist[jdx] = max(abs(Glist[.,jdx]))
		heteroGlist[jdx] = max(abs(Glist[.,jdx] :- mean( Glist[.,jdx] )))
	}
	
	// 99.5%-Winsorize Glist
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){		
		Glist995 = sort( abs(Glist[idx,.]), 1 )[trunc(0.995*num_bootstrap)]
		temp = Glist[idx,.]
		temp = -abs(Glist995):*( Glist[idx,.] :< -abs(Glist995) ) + temp:*( Glist[idx,.] :<= -abs(Glist995) )
		temp = abs(Glist995):*( Glist[idx,.] :> abs(Glist995) ) + temp:*( Glist[idx,.] :<= abs(Glist995) )
		Glist[idx,.] = temp
	}

	////////////////////////////////////////////////////////////////////////////
	// Uniform Confidence Band and Hypothesis Testing
	half_band_length = sort(maxGlist,1)[trunc(cover*num_bootstrap)] / (n*h)^0.5
	bl = QTElist :- half_band_length
	bu = QTElist :+ half_band_length
	pval_nullity = mean(( (n*h)^0.5 :* max(abs(QTElist)) :<= maxGlist )')
	pval_homogeneity = mean(( (n*h)^0.5 :* max(abs(QTElist :- mean(QTElist'))) :<= heteroGlist )')
	
	////////////////////////////////////////////////////////////////////////////
	// Estimation Results
	b = QTElist
	V = V = Glist * Glist' :/ num_bootstrap - (Glist :/ num_bootstrap) * (Glist :/ num_bootstrap)'
	V = V :/ (n*h)

    st_matrix(bname, b)
    st_matrix(Vname, V)
    st_numscalar(nname, n)

	////////////////////////////////////////////////////////////////////////////
	// Console output
	printf("\n{hline 78}\n")
	printf(  "Sharp Regression Discontinuity Design\n")
	printf(  "Number of observations:                                        n = %f\n", n)
	printf(  "The discontinuity location of the running variable:            c = %f\n", cut)
	printf(  "{hline 78}\n")
	printf(  "Quantile         QRKD     [%2.0f%% Unif. Conf. Band]\n",100*cover)
	printf(  "{hline 48}\n")
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
	    printf("   %5.3f   %10.5f   %10.5f   %10.5f\n",qlist[idx],b[idx],bl[idx],bu[idx])
	}
	printf(  "{hline 78}\n")
	printf(  "Test of the hypothesis that QTE=0 for all quantiles:           p-value = %4.3f\n", pval_nullity)
	printf(  "Test of the hypothesis that QTE is constant across quantiles:  p-value = %4.3f\n", pval_homogeneity)
	printf(  "{hline 78}\n")
}
//////////////////////////////////////////////////////////////////////////////// 
// Estimation of QTE in the Fuzzy Design
void estimate_fuzzyqte( string scalar yv,      string scalar xv,	   string scalar dv,
						real scalar cut, 	   real scalar q_low, 	   real scalar q_high, 	 
						real scalar q_num, 	   real scalar b_w,	       string scalar touse,   
						string scalar bname,   string scalar Vname,    string scalar nname,
						real scalar cover,	   string scalar cbname) 
{
	printf("\n{hline 78}\n")
	printf("Executing:    Chiang, H.D., Hsu, Y.-C. & Sasaki, Y. (2019): Robust Uniform    \n")
	printf("              Inference for Quantile Treatment Effects in Regression          \n")
	printf("              Discontinuity Designs. Journal of Econometrics 211 (2), 589-618.\n")
	printf("{hline 78}\n")
    real vector y, d, x, qlist
    real scalar n
 
    y      = st_data(., yv, touse)
	d      = st_data(., dv, touse)
    x      = st_data(., xv, touse) :- cut
    n      = rows(y)
	// List of quantiles at which to evaluate causal effects
	qlist = (q_high - q_low) :* (0..(q_num-1)) :/ (q_num-1) :+ q_low
	// Grid of y values at which the Wald ratio is ccomputed
	y_num = 5000
	ylist = (sort(y,1)[trunc(n*0.99)] - sort(y,1)[trunc(n*0.01)]) :* (0..(y_num-1)) :/ (y_num-1) :+ sort(y,1)[trunc(n*0.01)]
	// Bandwidth
	h = b_w
	if( b_w <= 0 ){
		h = variance(x)^0.5 / n^0.2
	}

	////////////////////////////////////////////////////////////////////////////
	// Estimate Wald Ratios
	real vector kout
	kernel(x :/ h, kout)
	wald_d0 = J(length(ylist),1,0)
	wald_d1 = J(length(ylist),1,0)
	mu1d0plus = J(length(ylist),1,0)
	mu1d0minus = J(length(ylist),1,0)
	mu1d1plus = J(length(ylist),1,0)
	mu1d1minus = J(length(ylist),1,0)
	reg = diag((0.05*n/h) :* (1 \ variance(x)^0.5 \ variance(x)))
	
	Xplus = kout:^0.5, x :* kout:^0.5, x:^2 :/ 2 :* kout:^0.5 :* (x :> 0)
	Xminus = kout:^0.5, x :* kout:^0.5, x:^2 :/ 2 :* kout:^0.5 :* (x :<= 0)
	
	dval = 0
	Dplus = (d :== dval) :* kout:^0.5 :* (x :> 0)
	Dminus = (d :== dval) :* kout:^0.5 :* (x :<= 0)
	mu2plus = luinv( Xplus' * Xplus :+ reg ) * Xplus' * Dplus
	mu2minus = luinv( Xminus' * Xminus :+ reg ) * Xminus' * Dminus
	mu2d0plus = mu2plus[1]
	mu2d0minus = mu2minus[1]
	for( idx = 1 ; idx <= y_num ; idx++ ){
		yval = ylist[idx]
		YDplus = (y :<= yval) :* (d :== dval) :* kout:^0.5 :* (x :> 0)
		YDminus = (y :<= yval) :* (d :== dval) :* kout:^0.5 :* (x :<= 0)
		mu1plus = luinv( Xplus' * Xplus :+ reg ) * Xplus' * YDplus
		mu1minus = luinv( Xminus' * Xminus :+ reg ) * Xminus' * YDminus
		mu1d0plus[idx] = mu1plus[1]
		mu1d0minus[idx] = mu1minus[1]
		wald_d0[idx] = (mu1plus[1] - mu1minus[1]) / (mu2plus[1] - mu2minus[1])
		wald_d0[idx] = (wald_d0[idx] < 0)*0 + (wald_d0[idx] >= 0)*wald_d0[idx]
		wald_d0[idx] = (wald_d0[idx] > 1)*1 + (wald_d0[idx] <= 1)*wald_d0[idx]
	}
	wald_d0 = sort(wald_d0,1)
	
	dval = 1
	Dplus = (d :== dval) :* kout:^0.5 :* (x :> 0)
	Dminus = (d :== dval) :* kout:^0.5 :* (x :<= 0)
	mu2plus = luinv( Xplus' * Xplus :+ reg ) * Xplus' * Dplus
	mu2minus = luinv( Xminus' * Xminus :+ reg ) * Xminus' * Dminus	
	mu2d1plus = mu2plus[1]
	mu2d1minus = mu2minus[1]
	for( idx = 1 ; idx <= y_num ; idx++ ){
		yval = ylist[idx]
		YDplus = (y :<= yval) :* (d :== dval) :* kout:^0.5 :* (x :> 0)
		YDminus = (y :<= yval) :* (d :== dval) :* kout:^0.5 :* (x :<= 0)
		mu1plus = luinv( Xplus' * Xplus :+ reg ) * Xplus' * YDplus
		mu1minus = luinv( Xminus' * Xminus :+ reg ) * Xminus' * YDminus
		mu1d1plus[idx] = mu1plus[1]
		mu1d1minus[idx] = mu1minus[1]
		wald_d1[idx] = (mu1plus[1] - mu1minus[1]) / (mu2plus[1] - mu2minus[1])
		wald_d1[idx] = (wald_d1[idx] < 0)*0 + (wald_d1[idx] >= 0)*wald_d1[idx]
		wald_d1[idx] = (wald_d1[idx] > 1)*1 + (wald_d1[idx] <= 1)*wald_d1[idx]
	}
	wald_d1 = sort(wald_d1,1)
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate QTE
	QY0list = qlist
	QY1list = qlist
	QTElist = qlist

	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		q = qlist[idx]
		QY0 = min( select( ylist', wald_d0 :>= q) )
		QY1 = min( select( ylist', wald_d1 :>= q) )
		QY0list[idx] = QY0
		QY1list[idx] = QY1
		QTElist[idx] = QY1 - QY0
	}
	//QTElist
	
	////////////////////////////////////////////////////////////////////////////
	// Estimate Densities in Preparation for Variance Estimation
	hay = variance(y)^0.5 / n^(1/6)
	ha = variance(x)^0.5 / n^(1/6)
	hb = variance(x)^0.5 / n^0.2
	hc = variance(x)^0.5 / n^0.2
	real vector kyout, kouta, koutb
	kernel(x :/ ha, kouta)
	kernel(x :/ hb, koutb)
	kernel(x :/ hc, koutc)
	fx = mean( koutb :/ hb )
	fy0 = J(1,length(qlist),0)
	fy1 = J(1,length(qlist),0)
	
	
	dval = 0
	pd_plus = sum( koutc :* (d :== dval) :* (x :> 0) ) / sum( koutc :* (x :> 0) )
	pd_minus = sum( koutc :* (d :== dval) :* (x :<= 0) ) / sum( koutc :* (x :<= 0) )
	
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		yval = QY0list[idx]
		kernel((y :- yval) :/ hay, kyout)
		fyxd_plus = sum( kouta :* kyout :* (d :== dval) :* (x :> 0) :/ (n*ha*hay) ) / sum( kouta :* (d :== dval) :* (x :> 0) :/ (n*ha) :+ 0.000000001)
		fyxd_minus = sum( kouta :* kyout :* (d :== dval) :* (x :<= 0) :/ (n*ha*hay) ) / sum( kouta :* (d :== dval) :* (x :<= 0) :/ (n*ha) :+ 0.000000001 )
		
		fy0[idx] = ( fyxd_plus * pd_plus - fyxd_minus * pd_minus ) / (mu2d0plus - mu2d0minus)
	}

	dval = 1
	pd_plus = sum( koutc :* (d :== dval) :* (x :> 0) ) / sum( koutc :* (x :> 0) )
	pd_minus = sum( koutc :* (d :== dval) :* (x :<= 0) ) / sum( koutc :* (x :<= 0) )
	
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		yval = QY1list[idx]
		kernel((y :- yval) :/ hay, kyout)
		fyxd_plus = mean( kouta :* kyout :* (d :== dval) :* (x :> 0) :/ (n*ha*hay) ) / mean( kouta :* (d :== dval) :* (x :> 0) :/ (n*ha) :+ 0.000000001)
		fyxd_minus = mean( kouta :* kyout :* (d :== dval) :* (x :<= 0) :/ (n*ha*hay) ) / mean( kouta :* (d :== dval) :* (x :<= 0) :/ (n*ha) :+ 0.000000001 )
		
		fy1[idx] = ( fyxd_plus * pd_plus - fyxd_minus * pd_minus ) / (mu2d1plus - mu2d1minus)
	}

	////////////////////////////////////////////////////////////////////////////
	// Prepare Other Auxiliary Objects for Variance Estimation
	real scalar ku
	Gammaplus = J(3,3,0)
	ulist = (0..100) :/ 100
	for( idx = 1 ; idx <= length(ulist) ; idx++ ){
		u = ulist[idx]
		kernel(u,ku)
		Gammaplus = Gammaplus + ( (1 \ u \ u^2) * (ku) * (1, u, u^2) ) :* (ulist[2]-ulist[1])
	}
	
	Gammaminus = J(3,3,0)
	ulist = (-100..0) :/ 100
	for( idx = 1 ; idx <= length(ulist) ; idx++ ){
		u = ulist[idx]
		kernel(u,ku)
		Gammaminus = Gammaminus + ( (1 \ u \ u^2) * (ku) * (1, u, u^2) ) :* (ulist[2]-ulist[1])
	}
	
	////////////////////////////////////////////////////////////////////////////
	// Influence Functions
	IF1d0plus = J(n,length(qlist),0)
	IF1d0minus = J(n,length(qlist),0)
	IF1d1plus = J(n,length(qlist),0)
	IF1d1minus = J(n,length(qlist),0)
	IF2d0plus = J(n,1,0)
	IF2d0minus = J(n,1,0)
	IF2d1plus = J(n,1,0)
	IF2d1minus = J(n,1,0)

	dval = 0
	IF2d0plus = kout :* ( (d :== dval) :- mu2d0plus ) :* (x :> 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaplus))[1,.]'
	IF2d0plus = IF2d0plus :/ (fx * (n*h)^0.5)
	IF2d0minus = kout :* ( (d :== dval) :- mu2d0minus ) :* (x :<= 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaminus))[1,.]'
	IF2d0minus = IF2d0minus :/ (fx * (n*h)^0.5)
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		yval = QY0list[idx]
		ylistidx = length( select(ylist, ylist :<= yval) )
		IF1d0plus[.,idx] = kout :* ( (y :<= yval) :* (d :== dval) :- mu1d0plus[ylistidx] ) :* (x :> 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaplus))[1,.]'
		IF1d0plus[.,idx] = IF1d0plus[.,idx] :/ (fx * (n*h)^0.5)
		IF1d0minus[.,idx] = kout :* ( (y :<= yval) :* (d :== dval) :- mu1d0minus[ylistidx] ) :* (x :<= 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaminus))[1,.]'
		IF1d0minus[.,idx] = IF1d0minus[.,idx] :/ (fx * (n*h)^0.5)
	}
	
	dval = 1
	IF2d1plus = kout :* ( (d :== dval) :- mu2d1plus ) :* (x :> 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaplus))[1,.]'
	IF2d1plus = IF2d1plus :/ (fx * (n*h)^0.5)
	IF2d1minus = kout :* ( (d :== dval) :- mu2d1minus ) :* (x :<= 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaminus))[1,.]'
	IF2d1minus = IF2d1minus :/ (fx * (n*h)^0.5)
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
		yval = QY1list[idx]
		ylistidx = length( select(ylist, ylist :<= yval) )
		IF1d1plus[.,idx] = kout :* ( (y :<= yval) :* (d :== dval) :- mu1d1plus[ylistidx] ) :* (x :> 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaplus))[1,.]'
		IF1d1plus[.,idx] = IF1d1plus[.,idx] :/ (fx * (n*h)^0.5)
		IF1d1minus[.,idx] = kout :* ( (y :<= yval) :* (d :== dval) :- mu1d1minus[ylistidx] ) :* (x :<= 0) :* (J(n,1,1), x:/h, (x:/h):^2) * (luinv(Gammaminus))[1,.]'
		IF1d1minus[.,idx] = IF1d1minus[.,idx] :/ (fx * (n*h)^0.5)
	}

	////////////////////////////////////////////////////////////////////////////
	// Multiplier Bootstrap
	num_bootstrap = 2500
	Glist = J(length(qlist),num_bootstrap,0)
	maxGlist = J(1,num_bootstrap,0)
	heteroGlist = J(1,num_bootstrap,0)
	
	for( jdx = 1 ; jdx <= num_bootstrap ; jdx++ ){
		xi = invnormal(uniform(n,1))
		
		for( idx = 1 ; idx <= length(qlist) ; idx++ ){
			yval = QY1list[idx]
			ylistidx = length( select(ylist, ylist :<= yval) )
			G = 
			( sum( xi :* IF1d1plus[.,idx] ) - sum( xi :* IF1d1minus[.,idx] ) ) * (mu2d1plus - mu2d1minus) / fy1[idx] / (mu2d1plus - mu2d1minus)^2 -
			( sum( xi :* IF2d1plus ) - sum( xi :* IF2d1minus ) ) * ( mu1d1plus[ylistidx] - mu1d1minus[ylistidx] ) / fy1[idx] / (mu2d1plus - mu2d1minus)^2 -
			( sum( xi :* IF1d0plus[.,idx] ) - sum( xi :* IF1d0minus[.,idx] ) ) * (mu2d0plus - mu2d0minus) / fy0[idx] / (mu2d0plus - mu2d0minus)^2 +
			( sum( xi :* IF2d0plus ) - sum( xi :* IF2d0minus ) ) * ( mu1d0plus[ylistidx] - mu1d0minus[ylistidx] ) / fy0[idx] / (mu2d0plus - mu2d0minus)^2
			Glist[idx,jdx] = G
		}
		maxGlist[jdx] = max(abs(Glist[.,jdx]))
		heteroGlist[jdx] = max(abs(Glist[.,jdx] :- mean( Glist[.,jdx] )))
	}
	
	// 99.5%-Winsorize Glist
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){		
		Glist995 = sort( abs(Glist[idx,.]), 1 )[trunc(0.995*num_bootstrap)]
		temp = Glist[idx,.]
		temp = -abs(Glist995):*( Glist[idx,.] :< -abs(Glist995) ) + temp:*( Glist[idx,.] :<= -abs(Glist995) )
		temp = abs(Glist995):*( Glist[idx,.] :> abs(Glist995) ) + temp:*( Glist[idx,.] :<= abs(Glist995) )
		Glist[idx,.] = temp
	}

	////////////////////////////////////////////////////////////////////////////
	// Uniform Confidence Band and Hypothesis Testing
	half_band_length = sort(maxGlist,1)[trunc(cover*num_bootstrap)] / (n*h)^0.5
	bl = QTElist :- half_band_length
	bu = QTElist :+ half_band_length
	pval_nullity = mean(( (n*h)^0.5 :* max(abs(QTElist)) :<= maxGlist )')
	pval_homogeneity = mean(( (n*h)^0.5 :* max(abs(QTElist :- mean(QTElist'))) :<= heteroGlist )')
	
	////////////////////////////////////////////////////////////////////////////
	// Estimation Results
	b = QTElist
	V = V = Glist * Glist' :/ num_bootstrap - (Glist :/ num_bootstrap) * (Glist :/ num_bootstrap)'
	V = V :/ (n*h)

    st_matrix(bname, b)
    st_matrix(Vname, V)
    st_numscalar(nname, n)

	////////////////////////////////////////////////////////////////////////////
	// Console output
	printf("\n{hline 78}\n")
	printf(  "Fuzzy Regression Discontinuity Design\n")
	printf(  "Number of observations:                                        n = %f\n", n)
	printf(  "The discontinuity location of the running variable:            c = %f\n", cut)
	printf(  "{hline 78}\n")
	printf(  "Quantile         QRKD     [%2.0f%% Unif. Conf. Band]\n",100*cover)
	printf(  "{hline 48}\n")
	for( idx = 1 ; idx <= length(qlist) ; idx++ ){
	    printf("   %5.3f   %10.5f   %10.5f   %10.5f\n",qlist[idx],b[idx],bl[idx],bu[idx])
	}
	printf(  "{hline 78}\n")
	printf(  "Test of the hypothesis that QTE=0 for all quantiles:           p-value = %4.3f\n", pval_nullity)
	printf(  "Test of the hypothesis that QTE is constant across quantiles:  p-value = %4.3f\n", pval_homogeneity)
	printf(  "{hline 78}\n")
}
end
////////////////////////////////////////////////////////////////////////////////


		
		
		
		
		
		
		
		
		
		
				
