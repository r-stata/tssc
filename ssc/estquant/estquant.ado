/*******************************************************************************
** (C) KEISUKE KONDO
** 
** Release Date: November 15, 2016
** Update Date: December 06, 2017
** Version: 1.10
** 
** [Reference]
** Combes, P.P., Duranton, G., Gobillon, L., Puga, D., and Roux, S., (2012) 
** "The Productivity Advantages of Large Cities: Distinguishing Agglomeration
** From Firm Selection," Econometrica 80(6), pp. 2543-2594
** 
** [Contact]
** Email: kondo-keisuke@rieti.go.jp
** URL: https://sites.google.com/site/keisukekondokk/
*********************************************************************************/
** Version: 1.10
** Added INITR() option 
** Version: 1.04
** Improved program code
** Version: 1.03
** Bug fix (Delete "mata mlib create")
** Version: 1.02
** Integrated program code into one ado file
** Version: 1.01
** Improved program code
** 
** 

** Mata library lquantilef
clear mata

/*---------- START Class quantilef ----------*/
version 12
mata:
class quantilef {
	/* Member Variables */
	real scalar truncation, shift, dilation
	real scalar cref1, cref2, nrange
	real scalar maxIt, eps1, eps2
	real matrix mP
	real vector vbeta, beta0, betaf
	real scalar pgammf
	real vector y1, y2
	real scalar mean_y1, mean_y2, mean_y
	real scalar sd_y1, sd_y2, sd_y
	real matrix y
	real scalar Cr, Ct1, Ct2
	real scalar nobs, nobs_c1, nobs_c2
	real scalar myn1, myn2, sdyn
	
	/* Member Functions */
	void new()
	void init_setting_range(), init_setting_data(), init_setting_category(), /*
		*/ init_setting_spec(), init_setting_params(), init_setting_conv()
	real matrix zb(), dzb_b(), zb_1(), dzb_1_b()
	real matrix zb0(), zb0_1()
	real scalar dzb_u()
	real scalar gammapp(), gammapp_1()
	real matrix tg(), dtg_g(), tg_1(), dtg_u()
	real matrix weight1(), weight2()
	real matrix quant()
	real scalar init()
	void critb()
	void critbisf()
	real scalar critb0(), critbisf0()
	real matrix BlGart()
	real scalar calctest()
}
/* =====================================
  Member Functions
===================================== */
/* void */
void quantilef::new()
{
}
/* Initial Setting Range */
void quantilef::init_setting_range( real scalar vRange )
{
	nrange = vRange
}
/* Initial Setting Data */
void quantilef::init_setting_data( real vector vY1, real vector vY2 )
{
	y1 = vY1
	y2 = vY2
	mean_y1 = mean(y1)
	mean_y2 = mean(y2)
	mean_y = mean(y1 \ y2)
	sd_y1 = sqrt(variance(y1))
	sd_y2 = sqrt(variance(y2))
	sd_y = sqrt(variance(y1 \ y2))
	nobs_c1 = rows(y1)
	nobs_c2 = rows(y2)
	nobs = nobs_c1 + nobs_c2
}
/* Initial Setting Category */
void quantilef::init_setting_category( numeric vector vCat )
{
	cref1 = vCat[1]
	cref2 = vCat[2]
}
/* Initial Setting Specification */
void quantilef::init_setting_spec( numeric vector vSpec )
{
	truncation = vSpec[1]
	shift = vSpec[2]
	dilation = vSpec[3]
}
/* Initial Setting Parameter */
void quantilef::init_setting_params( real rowvector vBeta )
{
	/* vbeta = (D, A) */
	beta0 = vBeta
	betaf = vBeta
	vbeta = J(1,2,1)
	vbeta[1] = 1
	vbeta[2] = 0
}
/* Initial Setting for Convergnece */
void quantilef::init_setting_conv( real scalar maxIt, real scalar eps1, real scalar eps2 )
{
	maxIt = maxIt
	eps1 = eps1
	eps2 = eps2
}
/* ====================================================
** 1. Specify Parametric Functions of Value
 ==================================================== */ 
/* Value Transformation Function */
real matrix quantilef::zb(real vector u, real vector beta)
{
	real matrix zb
	if( dilation == 1 & shift == 0 ){
		zb = beta :* u
	}
	else if( dilation == 0 & shift == 1 ){
		zb = u :+ beta
	}
	else if( dilation == 1 & shift == 1 ){
		zb = beta[1] :* u :+ beta[2]
	}
	else if( dilation == 0 & shift == 0 ){
		zb = u
	}
	return(zb)
}
real matrix quantilef::zb0(real vector u)
{
	/* (D, A) = (1,0) */
	real matrix zb0
	zb0 = u
	return(zb0)
}
/* Partial Derivative of zb() wrt beta */
real matrix quantilef::dzb_b(real vector u, real vector beta)
{
	real matrix dzb
	if( dilation == 1 & shift == 0 ){
		dzb = u
	}
	else if( dilation == 0 & shift == 1 ){
		dzb = J(rows(u),1,1)
	}
	else if( dilation == 1 & shift == 1 ){
		dzb = ( u, J(rows(u),1,1) )
	}
	return(dzb)
}
/* Partial Derivative of zb() wrt u */
real scalar quantilef::dzb_u(real vector u, real vector beta)
{
	real scalar dzb
	if( dilation == 1 & shift == 0 ){
		dzb = beta
	}
	else if( dilation == 0 & shift == 1 ){
		dzb = 1
	}
	else if( dilation == 1 & shift == 1 ) {
		dzb = beta[1]
	}
	return(dzb)
}
/* Inverse of zb(), Holding beta Constant */
real matrix quantilef::zb_1(real vector x, real vector beta)
{
	real matrix zb_1
	if( dilation == 1 & shift == 0 ){
		zb_1 = x :/ beta
	}
	else if( dilation == 0 & shift == 1 ){
		zb_1 = x :- beta
	}
	else if( dilation == 1 & shift == 1 ) {
		zb_1 = ( x :- beta[2] ) :/ beta[1]
	}
	else if( dilation == 0 & shift == 0 ) {
		zb_1 = x
	}
	return(zb_1)
}
real matrix quantilef::zb0_1(real vector x)
{
	/* (D, A) = (1,0) */
	real matrix zb0_1
	zb0_1 = x
	return(zb0_1)
}
/* Derivative of zb_1() wrt beta */
real matrix quantilef::dzb_1_b(real vector x, real vector beta)
{
	real matrix dzb
	if( dilation == 1 & shift == 0 ){
		dzb = - x :/ (beta^2)
	}
	else if( dilation == 0 & shift == 1 ){
		dzb = - J(rows(x),1,1)
	}
	else if( dilation == 1 & shift == 1 ){
		dzb = ( -(x:-beta[2]):/(beta[1]^2), -(1:/beta[1]):*J(rows(x),1,1) )
	}
	return(dzb)
}
/* ====================================================
** 2. Specify Functions of Rank Transformation or Selection
 ==================================================== */ 
/* Selection */
real scalar quantilef::gammapp(real scalar pgamm)
{
	real scalar gamm
	gamm = ( exp(pgamm)-5 ) / ( 5+exp(pgamm) )
	gam = gamm
	if( gam == 1 ){
		printf("{err}S = 1")
		gam = gamm - (1e-6)
	}
	return(gam)
}
/* Selection */
real scalar quantilef::gammapp_1(real scalar gamm)
{
	real scalar pgamm
	gam = gamm
	if( gam == 1 ){
		printf("{err}S = 1")
		gam = gamm - (1e-6)
	}
	pgamm = log( (1+gam)/(1-gam) ) + log(5)
	return(pgamm)
}
/* Selection */
real matrix quantilef::tg(real vector u, real scalar gamma)
{
	real matrix tg
	gam = gamma
	if( gam == 1 ){
		printf("{err}S = 1")
		gam = gamma - (1e-6)
	}
	tg = gam :+ (1-gam):*u
	return(tg)
}
/* Selection */
real matrix quantilef::dtg_g(real vector u, real scalar gamma)
{
	real matrix dtg
	dtg = 1 :- u
	return(dtg)
}
/* Selection */
real matrix quantilef::dtg_u(real vector u, real scalar gamma)
{
	real matrix dtg
	gam = gamma
	if( gam == 1 ){
		printf("{err}S = 1")
		gam = gamma - (1e-6)
	}
	dtg = J(rows(u),1,(1-gam))
	return(dtg)
}
/* Selection */
real matrix quantilef::tg_1(real vector x, real scalar gamma)
{
	real matrix tg_1
	gam = gamma
	if( gam == 1 ){
		printf("{err}S = 1")
		gam = gamma - (1e-6)
	}
	tg_1 = ( x :- gam ) :/ ( 1 - gam )
	return(tg_1)
}
/* ====================================================
  Weight and Quantile 
 ==================================================== */ 
/* Weight 1 */
real matrix quantilef::weight1(real vector x)
{
	real matrix w
	w = J(rows(x),cols(x),1)
	return(w)
}
/* Weight 2 */
real matrix quantilef::weight2(real vector x)
{
	real matrix w
	w = J(rows(x),cols(x),1)
	return(w)
}
/* Procedure estimating quantiles of rank (rang2) from the distribution of values in y1 using linear interpolation */
real matrix quantilef::quant(real vector vy1, real vector rang2)
{
	real matrix qy1
	nobs1 = rows(vy1)
	nobs2 = rows(rang2)
	intb = trunc( nobs1 :* rang2 )
	intb = intb :+ (intb:==J(nobs2,1,0))
	intu = trunc( nobs1:*rang2 ) :+ 1
	intu = intu :- (intu:>J(nobs2,1,nobs1))
	qy1b = vy1[intb]
	qy1u = vy1[intu]
	qy1 = ( ((nobs1:*rang2):-intb):*(qy1u:-qy1b) ) :+ qy1b
	return(qy1)
}
/* ====================================================
** Optimize Criteria wrt Beta (not Gamma)
 ==================================================== */ 
/* Optimizing the Criteria wrt beta (and not gamma) */
real scalar quantilef::init(class quantilef Q)
{
	if( dilation == 1 & shift == 0 ){
		vbeta[1] = sdyn
		vbeta[2] = 0
		beta0 = vbeta[1]
	}
	else if( dilation == 0 & shift == 1 ) {
		vbeta[1] = 1
		vbeta[2] = myn2 - myn1
		beta0 = vbeta[2]
	}
	else {
		vbeta[1] = sdyn
		vbeta[2] = myn2 - myn1*sdyn
		beta0 = vbeta
	}
	
	/* Optimization */
	Sb = optimize_init()
	optimize_init_which(Sb, "min")
	optimize_init_evaluator(Sb, &eval_critb())
	optimize_init_evaluatortype(Sb, "d1")
	optimize_init_argument(Sb, 1, Q)
	optimize_init_technique(Sb, "nr")
	optimize_init_params(Sb, beta0)
	optimize_init_tracelevel(Sb, "none")
	optimize_init_conv_maxiter(Sb, maxIt)
	optimize_init_conv_ptol(Sb, 1e-20)
	optimize_init_conv_vtol(Sb, eps1)
	optimize_init_conv_nrtol(Sb, eps2)
	betaf = optimize(Sb)
	cr = optimize_result_value(Sb)
	return(cr)
}
/* ====================================================
  Estimating Parameters for the considered transformation
 ==================================================== */ 
/* Computation of the Criterium to Minimize, as a function of beta only */
void quantilef::critb(todo, beta, v, g, H)
{
	posb = range(1,(rows(y)-1),1)
	posu = range(2,rows(y),1)
	ys = sort(y,3)
	w1 = ys[.,5]
	yt1 = ys[.,1]
	yt2 = ys[.,2]
	rgt1 = ys[.,3]
	It1 = (w1:*(zb(yt1,beta):-yt2)):^2
	Ct1 = ( (It1[posu]:+It1[posb])'*(rgt1[posu] :- rgt1[posb]) ) / (rgt1[rows(y)]-rgt1[1]) / 2
	dIt1 = 2 :* ( J(1,length(beta),1)#(w1:*(zb(yt1,beta):-yt2)) ) :* dzb_b(yt1,beta)
	dCt1 = ( (dIt1[posu,.]:+dIt1[posb,.])'*(rgt1[posu] :- rgt1[posb]) ) / (rgt1[rows(y)]-rgt1[1]) / 2
	ys = sort(y,4)
	w2 = ys[.,6]
	yt1 = ys[.,1]
	yt2 = ys[.,2]
	rgt2 = ys[.,4]
	It2 = (w2:*(yt1:-zb_1(yt2,beta))):^2
	Ct2 = ( (It2[posu]:+It2[posb])'*(rgt2[posu] :- rgt2[posb]) ) / (rgt2[rows(y)]-rgt2[1]) / 2
	dIt2 = -2 :* ( J(1,length(beta),1)#(w2:*(yt1:-zb_1(yt2,beta))) ) :* dzb_1_b(yt2,beta)
	dCt2 = ( (dIt2[posu,.]:+dIt2[posb,.])'*(rgt2[posu] :- rgt2[posb]) ) / (rgt2[rows(y)]-rgt2[1]) / 2
	v = Ct1 + Ct2
	/* Derivative of the Criterium */
	if( todo >= 1 ){
		g = (dCt1 :+ dCt2)'
	}
}
/* Computation of the Criterium as a Function of pgamm */
void quantilef::critbisf(todo, p, Q, v, g, H)
{
	/* Get Gamma */
	pgamm = p
	gamm = gammapp(pgamm)
	if( truncation == 0 ){
		gamm = 0
	}

	/* common support condition */
	umin1 = max( (0,tg_1(0,gamm)) )
	umax1 = min( (1,tg_1(1,gamm)) )
	umin2 = max( (0,tg(0,gamm)) )
	umax2 = min( (1,tg(1,gamm)) )

	/* rank transformation */
	n1t = trunc( rows(y1):*(umax1-umin1) )
	n2t = trunc( rows(y2):*(umax2-umin2) )
	
	/* computation of threshold ranks */
	rangn1 = umin1 :+ ((range(0,nrange,1)):/nrange) :* (umax1 :- umin1)
	tgrangn1 = tg( rangn1, gamm )
	rangn2 = umin2 :+ ((range(0,nrange,1)):/nrange) :* (umax2 :- umin2)
	tg_rangn2 = tg_1( rangn2, gamm )
	w1 = weight1( rangn1 \ tg_rangn2 )
	w2 = weight2( tgrangn1 \ rangn2 )
	yn1 = quant( y1, rangn1 )
	qy2 = quant( y2, tgrangn1 )
	yn2 = quant( y2, rangn2 )
	qy1 = quant( y1, tg_rangn2 )
	y = ((yn1, qy2, rangn1, tgrangn1) \ (qy1, yn2, tg_rangn2, rangn2)), /*
		*/ ( w1, w2, (J(rows(yn1),1,cref1) \ J(rows(yn2),1,cref2)) )
	
	/* Optimization wrt beta (given gamma) */
	if( dilation == 0 & shift == 0 ){
		Cr = critb0()
	}
	else if( dilation == 1 | shift == 1 ){
		/* Calculate Initial Values for Optimization */
		myn1 = mean(yn1)
		myn2 = mean(yn2)
		vyn1 = variance(yn1)
		vyn2 = variance(yn2)
		sdyn = 1
		if( vyn1 > 0 ){
			sdyn = sqrt( vyn2/vyn1 )
		}
		/* Optimization wrt beta (given gamma) */
		Cr = init(Q)
	}
	
	/* Criterium */
	v = Cr
}
/* Computation of the Criterium for R2 */
real scalar quantilef::critb0()
{
	posb = range(1,(rows(y)-1),1)
	posu = range(2,rows(y),1)
	ys = sort(y,3)
	w1 = ys[.,5]
	yt1 = ys[.,1]
	yt2 = ys[.,2]
	rgt1 = ys[.,3]
	It1 = (w1:*(zb0(yt1):-yt2)):^2
	Ct1 = ( (It1[posu]:+It1[posb])'*(rgt1[posu] :- rgt1[posb]) ) / (rgt1[rows(y)]-rgt1[1]) / 2
	ys = sort(y,4)
	w2 = ys[.,6]
	yt1 = ys[.,1]
	yt2 = ys[.,2]
	rgt2 = ys[.,4]
	It2 = (w2:*(yt1:-zb0_1(yt2))):^2
	Ct2 = ( (It2[posu]:+It2[posb])'*(rgt2[posu] :- rgt2[posb]) ) / (rgt2[rows(y)]-rgt2[1]) / 2
	cr = Ct1 + Ct2
	return(cr)
}
/* Computation of the Baseline Criterium for R2 */
real scalar quantilef::critbisf0()
{
	/* Get Gamma */
	gamm = 0
	
	/* common support condition */
	umin1 = max( (0,tg_1(0,gamm)) )
	umax1 = min( (1,tg_1(1,gamm)) )
	umin2 = max( (0,tg(0,gamm)) )
	umax2 = min( (1,tg(1,gamm)) )
	
	/* rank transformation */
	n1t = trunc( rows(y1):*(umax1-umin1) )
	n2t = trunc( rows(y2):*(umax2-umin2) )
	
	/* computation of threshold ranks */
	rangn1 = umin1 :+ ((range(0,nrange,1)):/nrange) :* (umax1 :- umin1)
	tgrangn1 = tg( rangn1, gamm )
	rangn2 = umin2 :+ ((range(0,nrange,1)):/nrange) :* (umax2 :- umin2)
	tg_rangn2 = tg_1( rangn2, gamm )
	w1 = weight1( rangn1 \ tg_rangn2 )
	w2 = weight2( tgrangn1 \ rangn2 )
	yn1 = quant( y1, rangn1 )
	qy2 = quant( y2, tgrangn1 )
	yn2 = quant( y2, rangn2 )
	qy1 = quant( y1, tg_rangn2 )
	y = ((yn1, qy2, rangn1, tgrangn1) \ (qy1, yn2, tg_rangn2, rangn2)), /*
		*/ ( w1, w2, (J(rows(yn1),1,cref1) \ J(rows(yn2),1,cref2)) )
	
	/* Calculate Criteria */
	Cr = critb0()
	
	/* Criterium */
	return(Cr)
}
/* ====================================================
  Misc
 ==================================================== */ 
/* Non-Parametric Computation of Quantile Derivatives, used for the test statistics */
real matrix quantilef::BlGart(real vector p, real vector yv)
{
	real matrix lambdp
	np = rows(p)
	n = rows(yv)
	m = trunc(sqrt(n))
	vk1 = (trunc(n:*p):+m) :* ((n:*p):<=J(np,1,n-m)) :+ n:*((n:*p):>J(np,1,n-m))
	vk0 = (trunc(n:*p):-m) :* ((n:*p):>=J(np,1,1+m)) :+ 1:*((n:*p):<J(np,1,1+m))
	lambdp = ( (yv[vk1]:-yv[vk0]) ) :/  ( n:*(vk1:-vk0) )
	return(lambdp)
}
/* Computation of the Test Statistics */
real scalar quantilef::calctest(beta,gamm)
{
	real scalar stat
	umin1 = max( (0,tg_1(0,gamm)) )
	umax1 = min( (1,tg_1(1,gamm)) )
	umin2 = max( (0,tg(0,gamm)) )
	umax2 = min( (1,tg(1,gamm)) )
	rang1 = range(1,rows(y1),1) :/ rows(y1)
	rang2 = range(1,rows(y2),1) :/ rows(y2)
	tg_rang2 = tg_1(rang2, gamm)
	tgrang1 = tg(rang1, gamm)
	l1t = ( range(1,rows(y1),1), (umin1:<=rang1):*(rang1:<=umax1) )
	l2t = ( range(1,rows(y2),1), (umin2:<=rang2):*(rang2:<=umax2) )
	l1 = select( l1t, l1t[.,2] :!= 0 )
	l2 = select( l2t, l2t[.,2] :!= 0 )
	l1 = l1[.,1]
	l2 = l2[.,1]
	yn1 = y1[l1]
	yn2 = y2[l2]
	n1t = rows(yn1)
	n2t = rows(yn2)
	
	rangn1 = rang1[l1]
	tg_rangn2 = tg_rang2[l2]
	tgrangn1 = tgrang1[l1]
	rangn2 = rang2[l2]
	qy1 = quant(y1,tg_rangn2)
	qy2 = quant(y2,tgrangn1)
	y = ( (yn1,qy2,rangn1,tgrangn1) \ (qy1,yn2,tg_rangn2,rangn2) )
	((yn1,qy2)\(qy1,yn2))
	(rangn1,tgrangn1)\(tg_rangn2,rangn2)
	
	mu1 = 0.5 :* ( y[.,2] :+ zb(y[,1],beta) )
	mu2 = 0.5 :* ( zb_1(y[.,2],beta) :+ y[.,1] )

	dlambd1 = BlGart( y[.,3], y1 )
	dlambd2 = BlGart( y[.,4], y2 )
	dmu1 = 0.5 :* ( dzb_u(y[1,1],beta):*dlambd1:*(umax1-umin1) :+ dtg_u(y[1,4],gamm):*dlambd2:*(umax2-umin2) )
	
	eps = 1e-8
	correc = ((umax2-umin2)/(umax1-umin1)) / ( (dzb_u(y[1,2],beta)^2)/(dtg_u(y[1,4],gamm)+eps) )
	vw1 = (1 :/ (dmu1:^2)) :/ (1+correc)
	vw2 = vw1
	
	y = ( y, vw1, vw2, (J(rows(yn1),1,cref1)\J(rows(yn1),1,cref2)) )
	
	cr = critb0(beta)
	stat = cr / ( (1/rows(yn1))+(1/rows(yn2)) )
	return(stat)
}
end
/*---------- END Class quantilef ----------*/


/* ====================================================
** Wrap-Arround Function for Optimization within Class
** 
 ==================================================== */ 
version 12
mata:
/* wrt Beta */
void eval_critb(real scalar todo, real rowvector beta, class quantilef Q, real scalar v, real rowvector g, real matrix H)
{
	Q.critb(todo, beta, v, g, H)
}
/* wrt Gamma */
void eval_critbisf(real scalar todo, real rowvector beta, class quantilef Q, real scalar v, real rowvector g, real matrix H)
{
	Q.critbisf(todo, beta, Q, v, g, H)
}
end




/*---------- START Command estquant ----------*/
*! version 1.05  06 December 2017
capture program drop estquant
program define estquant, sortpreserve eclass
	version 12
	syntax varlist [if] [in], /*
		*/ CATegory(varname) /*
		*/ [ /*
		*/ TRuncation /*
		*/ SHift /*
		*/ DIlation /*
		*/ INITR(real 0) /*
		*/ QRANGE(real 1000) /*
		*/ BVARiable(string) /*
		*/ BREPlication(real 50) /*
		*/ BSAMpling(real 100) /*
		*/ STRATA /*
		*/ MAXITeration(real 1e+3) /*
		*/ EPS1(real 1e-6) /*
		*/ EPS2(real 1e-6) /*
		*/ CI(string) /*
		*/ Level(real 95) /*
		*/ ]

	/* Variables */
	local vY `varlist'
	marksample touse
	markout `touse' `varlist' `category'
	tempname b V
	
	/* Check and Define Category */
	qui: tab `category'
	if( r(r) != 2 ){
		display as error "More than two categories are specified."
		exit 198
	}
	if( r(r) == 2 ){
		qui: sum `category'
		scalar cat1 = r(min)
		scalar cat2 = r(max)
	}
	
	/* Check Variable */
	if( strpos("`vY'"," ") > 0 ){
		display as error "Multiple variables are not allowed."
		exit 103
	}
	
	/* Check Missing Values of Variable */
	qui: count if `vY' != . & `category' == cat1
	local cnt1_missing = r(N)
	qui: count if `vY' != . & `category' == cat2
	local cnt2_missing = r(N)
	if( `cnt1_missing' == 0 | `cnt2_missing' == 0 ){
		display as error "`vY' has no values."
		exit 198
	}
	
	/* Option: Truncation (Default Off) */
	local trnc = 0
	if( "`truncation'" != "" ){
		local trnc = 1
	}
	
	/* Option: Shift (Default Off) */
	local shft = 0
	if( "`shift'" != "" ){
		local shft = 1
	}
	
	/* Option: Dilation (Default Off) */
	local dltn = 0
	if( "`dilation'" != "" ){
		local dltn = 1
	}
	
	/* Option: Specify Initial Value of Truncation (Default Off) */
	local initrnc = 0
	scalar inivaltr = `initr'
	if( `initr' != 0 ){
		if( `initr' >= 0.5 ){
			display as error "Initial value of S in initr() must be lower than 0.5."
			exit 198
		}
		local initrnc = 1
	}

	/* Option: Confidence Interval */
	if( "`ci'" == "" ){
		/* Default: Normal-Based */
		local confi = "normal"
	}
	else if( "`ci'" != "" ){
		local confi = "`ci'"
	}
	if( "`confi'" != "bootstrap" & "`confi'" != "normal" ){
		display as error "Either bootstrap or normal must be specified in ci()."
		exit 198
	}
	
	/* Option: Confidence Interval Level */
	scalar cilevel = `level'
	if( ceil( (cilevel*10-trunc(cilevel*10)) ) > 0 ){
		display as error "level() can have at most one digit after the decimal point"
		exit 198
	}
	
	/* Range */
	scalar nrange = `qrange'
	
	/* Bootstrap Option */
	local bstrata = 0
	if( "`strata'" != "" ){
		/*bsample with strata option*/
		local bstrata = 1
	}
	if( "`bvariable'" == "" ){
		local bvar = "off"
	}
	else if( "`bvariable'" != "" ){
		local bvar = "`bvariable'"
	}
	if( "`bvar'" != "on" & "`bvar'" != "off" ){
		display as error "bvariable() requires either on or off."
		exit 198
	}
	if( `bstrata' == 1 & "`bvar'" == "on" ){
		display as txt "note: strata option is ignored in the case of bvariable(on)."
	}
	local nbrep = `breplication'
	scalar nbsample = `bsampling'
	
	/* Convegence */
	scalar maxIt = `maxiteration'
	scalar eps1 = `eps1'
	scalar eps2 = `eps2'
	
	/* Bootstrap Option: Error Check */
	if( "`bvar'" == "on" ){
		forvalues i = 1(1)`nbrep' {
			capture confirm new variable `vY'`i', exact
			if( _rc == 0 ){
				display as error "bvariable() requires variables named in a sequential order."
				exit 198
			}
			capture confirm new variable `category'`i', exact
			if( _rc == 0 ){
				display as error "bvariable() requires variables named in a sequential order."
				exit 198
			}
		}
	}
	
	/* Display Results: OFF */
	local disp = 0
	
	/* Bootstrap Replications */
	if( `nbrep' == 0 ){
		display "Bootstrap replications skipped."
		/* Dummy Matrix for Bootstrap Replications */
		scalar nbsample = .
		matrix mP = J(1,3,0)
		matrix colnames mP = A D S
	}
	else if( `nbrep' == 1 ){
		display as error "Bootstrap requires 2 replications or more."
		exit 198
	}
	else if( `nbrep' >= 2 ){
		matrix mP = J(`nbrep',3,0)
		matrix colnames mP = A D S
		display "Bootstrap replications (`nbrep')"
		if( `trnc' == 1 | `shft' == 1 | `dltn' == 1 ){
			/* Bootstrap: bvariable option off */
			if( "`bvar'" == "off" ){
				forvalues i = 1(1)`nbrep' {
					preserve
					local bcnt = 0
					local bconv = 0
					while `bconv' == 0 {
						if( `bstrata' == 0 ){
							bsample round((nbsample/100)*_N)
						}
						else if( `bstrata' == 1 ){
							bsample round((nbsample/100)*_N), strata(`category')
						}
						mata: estquant("`vY'", "`category'", `trnc', `shft', `dltn', `initrnc', "`touse'", "`b'", "`V'", st_matrix("mP"), "`confi'", `disp')
						local bconv = converged
						local bcnt = `bcnt' + 1
						if( `bcnt' > 100 ){
							/* Break loop if convergence not achieved */
							disp "{c |}Conv. NA at "%3.0f `i'"{c |}"
							break
						}
					}
					matrix vP = vp
					matrix mP[`i',1] = vP[1,1]
					matrix mP[`i',2] = vP[1,2]
					matrix mP[`i',3] = vP[1,3]
					restore
					
					/* Display Iteration Process */
					if( `i' == 1 ){
						disp as text "{c TT}{hline 15}{c TT}"
					}
					if( `i' == trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  10%{c |}"
					}
					else if( `i' == 2*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  20%{c |}"
					}
					else if( `i' == 3*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  30%{c |}"
					}
					else if( `i' == 4*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  40%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) ){
						disp as text "{c |}Completed:  50%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) + trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  60%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) + 2*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  70%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) + 3*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  80%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) + 4*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  90%{c |}"
					}
					else if( `i' == `nbrep' ){
						disp as text "{c |}Completed: 100%{c |}"
						disp as text "{c BT}{hline 15}{c BT}"
					}
				}
			}
			/* Bootstrap: bvariable option on */
			if( "`bvar'" == "on" ){
				forvalues i = 1(1)`nbrep' {
					local bcnt = 0
					local bconv = 0
					scalar nbsample = .
					while `bconv' == 0 {
						mata: estquant("`vY'`i'", "`category'`i'", `trnc', `shft', `dltn', `initrnc', "`touse'", "`b'", "`V'", st_matrix("mP"), "`confi'", `disp')
						local bconv = converged
						local bcnt = `bcnt' + 1
						if( `bcnt' > 100 ){
							/* Break loop if convergence not achieved */
							disp "{c |}Conv. NA at "%3.0f `i'"{c |}"
							break
						}
					}
					matrix vP = vp
					matrix mP[`i',1] = vP[1,1]
					matrix mP[`i',2] = vP[1,2]
					matrix mP[`i',3] = vP[1,3]
					
					/* Display Iteration Process */
					if( `i' == 1 ){
						disp as text "{c TT}{hline 15}{c TT}"
					}
					if( `i' == trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  10%{c |}"
					}
					else if( `i' == 2*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  20%{c |}"
					}
					else if( `i' == 3*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  30%{c |}"
					}
					else if( `i' == 4*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  40%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) ){
						disp as text "{c |}Completed:  50%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) + trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  60%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) + 2*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  70%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) + 3*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  80%{c |}"
					}
					else if( `i' == trunc(`nbrep'/2) + 4*trunc(`nbrep'/10) ){
						disp as text "{c |}Completed:  90%{c |}"
					}
					else if( `i' == `nbrep' ){
						disp as text "{c |}Completed: 100%{c |}"
						disp as text "{c BT}{hline 15}{c BT}"
					}
				}
			}
		}
	}
	
	/* Display Results: ON */
	local disp = 1
	
	/* Mata Main Program for Estimation */
	mata: estquant("`vY'", "`category'", `trnc', `shft', `dltn', `initrnc', "`touse'", "`b'", "`V'", st_matrix("mP"), "`confi'", `disp')
	
	/* ereturn in Stata */
	matrix colnames `b' = "Shift A" "Dilation D" "Truncation S"
	matrix colnames `V' = "Shift A" "Dilation D" "Truncation S"
	matrix rownames `V' = "Shift A" "Dilation D" "Truncation S"
	ereturn clear
	ereturn post `b' `V', esample(`touse')
	ereturn matrix B mP
	ereturn scalar N = nobs
	ereturn scalar N1 = nobs_c1
	ereturn scalar N2 = nobs_c2
	ereturn scalar qrange = nrange
	ereturn scalar brep = nbrep
	ereturn scalar bsample = nbsample
	ereturn scalar r2 = r2
	ereturn scalar cri = cri
	ereturn scalar cr1 = cr1
	ereturn scalar cr2 = cr2
	ereturn scalar mean_y = meany
	ereturn scalar mean_y1 = meany1
	ereturn scalar mean_y2 = meany2
	ereturn scalar sd_y = sdy
	ereturn scalar sd_y1 = sdy1
	ereturn scalar sd_y2 = sdy2
	ereturn local varname "`vY'"
	ereturn local cmd "estquant"
	

	/* Drop Variables and Scalars */
	scalar drop cat1 cat2 nrange nobs nobs_c1 nobs_c2 meany meany1 meany2 sdy sdy1 sdy2 
	scalar drop nbrep nbsample converged maxIt eps1 eps2 inivaltr
end


/* ==========================
** Mata Main Program
** Call quantdist Class
========================== */
version 12
mata:
void estquant(vY, category, trnc, shft, dltn, initrnc, touse, bname, Vname, mP, ci, disp)
{
	/* Load Class (Mata Library) */
	class quantilef scalar Q

	/* Get Values */
	cref1 = st_numscalar("cat1")
	cref2 = st_numscalar("cat2")
	nrange = st_numscalar("nrange")
	nbrep = rows(mP)
	nbsample = st_numscalar("nbsample")
	cilevel = st_numscalar("cilevel")
	maxIt = st_numscalar("maxIt")
	eps1 = st_numscalar("eps1")
	eps2 = st_numscalar("eps2")
	inivaltr = st_numscalar("inivaltr")
	
	/* Make Two Variables for Each Category */
	svarlist = category + " " + vY
	st_view(mY, ., svarlist, touse)
	mY1 = select(mY, mY[.,1]:==cref1)
	mY2 = select(mY, mY[.,1]:==cref2)
	y1 = sort( mY1[.,2], 1 )
	y2 = sort( mY2[.,2], 1 )
	y1 = select( y1, y1 :!= . )
	y2 = select( y2, y2 :!= . )
	
	/* Set Parameter: beta = (D,A) */
	beta_ini = J(1,(dltn+shft),0)
	if( dltn == 1 ){
		beta_ini[1] = 1
	}
	
	/* Initial Setting */
	Q.init_setting_range( nrange )
	Q.init_setting_data( y1, y2 )
	Q.init_setting_category( (cref1,cref2) )
	Q.init_setting_spec( (trnc,shft,dltn) )
	Q.init_setting_params( beta_ini )
	Q.init_setting_conv( maxIt, eps1, eps2 )
	
	/* Baseline Criteria: (S,D,A) = (0,1,0) */
	pgammf = Q.gammapp_1(0)
	Cr0 = Q.critbisf0()
	
	/* Estimation of Gamma and Beta */
	if( Q.truncation == 1 ){
		/* Auto-Sepecified Initial Value */
		if( initrnc == 0 ){
			pgammi = -2.0
			pgamm0 = pgammi
			Q.critbisf(0,pgammi,Q,voirs,g,H)
			for(i=1; i<=10; i++){
				pgammi = pgammi+0.5
				Q.critbisf(0,pgammi,Q,voiri,g,H)
				if( voiri < voirs ){
					pgamm0 = pgammi
					voirs = voiri
				}
			}
		}
		/* Pre-Specified Initial Value */
		if( initrnc == 1 ){
			gammi = inivaltr/(inivaltr-1)
			pgammi = Q.gammapp_1(gammi)
			pgamm0 = pgammi
			Q.critbisf(0,pgammi,Q,voirs,g,H)
		}
		/* Optimization wrt gamma and beta */
		for(i=1; i<=5; i++){
			Sg = optimize_init()
			optimize_init_which(Sg, "min")
			optimize_init_evaluator(Sg, &eval_critbisf())
			optimize_init_evaluatortype(Sg, "d0")
			optimize_init_technique(Sg, "nr")
			optimize_init_argument(Sg, 1, Q)
			optimize_init_params(Sg, pgamm0)
			optimize_init_tracelevel(Sg, "none")
			optimize_init_conv_ptol(Sg, 1e-20)
			optimize_init_conv_vtol(Sg, eps1)
			optimize_init_conv_nrtol(Sg, eps2)
			if( disp == 0 ){
				/* For Bootstrap Replication: Max 100 replications */
				optimize_init_conv_maxiter(Sg, 100)
				optimize_init_conv_warning(Sg, "off")
			}
			else if( disp == 1 ){
				/* For Estimation */
				optimize_init_conv_maxiter(Sg, maxIt)
			}
			pgammi = optimize(Sg)
			voiri = optimize_result_value(Sg)
			bconv = optimize_result_converged(Sg)
			st_numscalar("converged", bconv)
			if( voiri < voirs ){
				pgamm0 = pgammi
				voirs = voiri
			}
		}
		pgammf = pgamm0
		/* Store beta and gamma*/
		if( Q.dilation == 1 | Q.shift == 1 ){
			betaf = Q.betaf
		}
		gammf = Q.gammapp(pgammf)
	}
	else if( Q.truncation == 0 ){
		/* Optimization wrt beta */
		pgammf = Q.gammapp_1(0)
		Q.critbisf(0,pgammf,Q,Cr,g,H)
		st_numscalar("converged", 1)
		/* Store beta and gamma*/
		if( Q.dilation == 1 | Q.shift == 1 ){
			betaf = Q.betaf
		}
		gammf = 0
	}
	
	/* Store Criterium */
	Cr1 = Q.Ct1
	Cr2 = Q.Ct2
	Cri = Q.Cr
	
	/* Computation of the Test Statistics */
/*	
	stat1 = Q.calctest(betaf,gammf)
	stat1
*/
	
	/* Parameters */
	beta = J(2,1,0)
	gamm_e = - gammf / (1-gammf)

	/* Results Table */
	if( Q.shift == 1 & Q.dilation == 1 ){
		beta[1] = betaf[1]
		beta[2] = betaf[2]
	}
	else if( Q.shift == 0 & Q.dilation == 1 ){
		beta[1] = betaf
		beta[2] = 0
	}
	else if( Q.shift == 1 & Q.dilation == 0 ){
		beta[1] = 1
		beta[2] = betaf
	}
	else {
		beta[1] = 1
		beta[2] = 0
	}
	vp = (beta[2], beta[1], gamm_e)
	sPName = ("Shift A", "Dilation D", "Truncation S")
	vA = sort(mP[.,1],1)
	vD = sort(mP[.,2],1)
	vS = sort(mP[.,3],1)
	sdA = sqrt(variance(vA))
	sdD = sqrt(variance(vD))
	sdS = sqrt(variance(vS))
	zA = vp[1] / sdA
	zD = (vp[2]-1) / sdD
	zS = vp[3] / sdS
	pA = 2*(1-normal(abs(zA)))
	pD = 2*(1-normal(abs(zD)))
	pS = 2*(1-normal(abs(zS)))
	alphaL = 0.5*((100-cilevel)/100)
	alphaU = 1 - 0.5*((100-cilevel)/100)
	lposu = ceil(nbrep*alphaL)
	lposb = floor(nbrep*alphaL)
	uposu = ceil(nbrep*alphaU)
	uposb = floor(nbrep*alphaU)
	if( lposb == 0 ){
		lposb = 1
	}
	if( ci == "bootstrap" ){
		cilA = 0.5 * (vA[lposu]+vA[lposb])
		cilD = 0.5 * (vD[lposu]+vD[lposb])
		cilS = 0.5 * (vS[lposu]+vS[lposb])
		ciuA = 0.5 * (vA[uposu]+vA[uposb])
		ciuD = 0.5 * (vD[uposu]+vD[uposb])
		ciuS = 0.5 * (vS[uposu]+vS[uposb])
	}
	else if( ci == "normal" ){
		cilA = vp[1] + sdA * invnormal(alphaL)
		cilD = vp[2] + sdD * invnormal(alphaL)
		cilS = vp[3] + sdS * invnormal(alphaL)
		ciuA = vp[1] + sdA * invnormal(alphaU)
		ciuD = vp[2] + sdD * invnormal(alphaU)
		ciuS = vp[3] + sdS * invnormal(alphaU)
	}
	b = vp
	V = diag((variance(vA),variance(vD),variance(vS)))
	mStat = (vp[1], sdA, zA, pA, cilA, ciuA ) \ /*
		*/ (vp[2], sdD, zD, pD, cilD, ciuD ) \ /* 
		*/ (vp[3], sdS, zS, pS, cilS, ciuS )
	r2 = 1 - (Cri/Cr0)
	
	/* For Skipped Bootstrap Procedure */
	if( nbrep == 1 ){
		nbrep = 0
		V = J(3,3,0)
	}
	
	/* ereturn for Stata */
	st_matrix(bname, b)
	st_matrix(Vname, V)
	st_matrix("vp", vp)
	st_numscalar("nobs", Q.nobs)
	st_numscalar("nobs_c1", Q.nobs_c1)
	st_numscalar("nobs_c2", Q.nobs_c2)
	st_numscalar("meany", Q.mean_y)
	st_numscalar("meany1", Q.mean_y1)
	st_numscalar("meany2", Q.mean_y2)
	st_numscalar("sdy", Q.sd_y)
	st_numscalar("sdy1", Q.sd_y1)
	st_numscalar("sdy2", Q.sd_y2)
	st_numscalar("r2", r2)
	st_numscalar("nrange", nrange)
	st_numscalar("nbrep", nbrep)
	st_numscalar("nbsample", nbsample)
	st_numscalar("cr1", Cr1)
	st_numscalar("cr2", Cr2)
	st_numscalar("cri", Cri)
	
	/* Variable Name: Category Variable */
	sVarLen1 = strlen(category)
	if( sVarLen1 > 12 ){
		scategory = substr(category,1,10) + "~" + substr(category,sVarLen1,1)
	}
	else{
		scategory = category
	}
	
	/* Variable Name: Distribution Variable */
	sVarLen2 = strlen(vY)
	if( sVarLen2 > 12 ){
		sY = substr(vY,1,10) + "~" + substr(vY,sVarLen2,1)
	}
	else{
		sY = vY
	}
	
	/* Display Results */
	if( disp == 1 ){
		/* Summary Statistics */
		printf("\n\n")
		printf("{txt}%12s {c |}{space 5}Obs. {space 6}Mean {space 6}S.D. {space 7} Number of obs = {res}%8.0f \n", scategory, Q.nobs)
		printf("{hline 13}{c +}{hline 31} {txt}{space 7} Replications  = {res}%8.0f \n", nbrep)
		printf("{txt}%12.0f {c |}{res} %8.0f %11.4g %9.4g {space 8}{txt}BS Sample (%%) = {res}%8.4g \n", cref1, Q.nobs_c1, Q.mean_y1, Q.sd_y1, nbsample)
		printf("{txt}%12.0f {c |}{res} %8.0f %11.4g %9.4g {space 8}{txt}Pseudo R2     = {res}%8.4f \n", cref2, Q.nobs_c2, Q.mean_y2, Q.sd_y2, r2)
		printf("{hline 13}{c +}{hline 31} \n")
		printf("{txt}{space 7}Total {c |}{res} %8.0f %11.4g %9.4g \n", Q.nobs, Q.mean_y, Q.sd_y)
		printf("\n")
		printf("{hline 13}{c TT}{hline 64} \n")
		if( ci == "bootstrap" ){
			printf("{txt}{space 12} {c |}{space 3}Observed{space 3}Bootstrap{space 23}Bootstrap-based \n")
		}
		else if( ci == "normal" ){
			printf("{txt}{space 12} {c |}{space 3}Observed{space 3}Bootstrap{space 25}Normal-based \n")
		}
		printf("{txt}%12s {c |}{space 6}Coef.{space 3}Std. Err.{space 6}z{space 4}P>|z|{space 3}[%3.1f%% Conf. Interval]\n", sY, cilevel)
		printf("{hline 13}{c +}{hline 64} \n")
		if( Q.shift == 1 & Q.dilation == 1 & Q.truncation == 1 ){
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.6g %11.6g\n", 
				sPName[1],mStat[1,1],mStat[1,2],mStat[1,3],mStat[1,4],mStat[1,5],mStat[1,6] )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.6g %11.6g\n", 
				sPName[2],mStat[2,1],mStat[2,2],mStat[2,3],mStat[2,4],mStat[2,5],mStat[2,6] )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.6g %11.6g\n", 
				sPName[3],mStat[3,1],mStat[3,2],mStat[3,3],mStat[3,4],mStat[3,5],mStat[3,6] )
			printf("{hline 13}{c BT}{hline 64} \n")
			printf("{txt}Constrained parameters: {res}nothing \n")
			printf("{hline 78} \n")
		}
		else if( Q.shift == 1 & Q.dilation == 1 & Q.truncation == 0 ){
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.6g %11.6g\n", 
				sPName[1],mStat[1,1],mStat[1,2],mStat[1,3],mStat[1,4],mStat[1,5],mStat[1,6] )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.6g %11.6g\n", 
				sPName[2],mStat[2,1],mStat[2,2],mStat[2,3],mStat[2,4],mStat[2,5],mStat[2,6] )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.6g %11.6g\n", 
				sPName[3],mStat[3,1],.,.,.,.,. )
			printf("{hline 13}{c BT}{hline 64} \n")
			printf("{txt}Constrained parameters: {res}S = 0 \n")
			printf("{hline 78} \n")
		}
		else if( Q.shift == 0 & Q.dilation == 1 & Q.truncation == 1 ){
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[1],mStat[1,1],.,.,.,.,. )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[2],mStat[2,1],mStat[2,2],mStat[2,3],mStat[2,4],mStat[2,5],mStat[2,6] )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[3],mStat[3,1],mStat[3,2],mStat[3,3],mStat[3,4],mStat[3,5],mStat[3,6] )
			printf("{hline 13}{c BT}{hline 64} \n")
			printf("{txt}Constrained parameters: {res}A = 0 \n")
			printf("{hline 78} \n")
		}
		else if( Q.shift == 1 & Q.dilation == 0 & Q.truncation == 1 ){
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[1],mStat[1,1],mStat[1,2],mStat[1,3],mStat[1,4],mStat[1,5],mStat[1,6] )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[2],mStat[2,1],.,.,.,.,. )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[3],mStat[3,1],mStat[3,2],mStat[3,3],mStat[3,4],mStat[3,5],mStat[3,6] )
			printf("{hline 13}{c BT}{hline 64} \n")
			printf("{txt}Constrained parameters: {res}D = 1 \n")
			printf("{hline 78} \n")
		}
		else if( Q.shift == 1 & Q.dilation == 0 & Q.truncation == 0 ){
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[1],mStat[1,1],mStat[1,2],mStat[1,3],mStat[1,4],mStat[1,5],mStat[1,6] )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[2],mStat[2,1],.,.,.,.,. )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[3],mStat[3,1],.,.,.,.,. )
			printf("{hline 13}{c BT}{hline 64} \n")
			printf("{txt}Constrained parameters: {res}D = 1, S = 0 \n")
			printf("{hline 78} \n")
		}
		else if( Q.shift == 0 & Q.dilation == 1 & Q.truncation == 0 ){
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[1],mStat[1,1],.,.,.,.,. )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[2],mStat[2,1],mStat[2,2],mStat[2,3],mStat[2,4],mStat[2,5],mStat[2,6] )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[3],mStat[3,1],.,.,.,.,. )
			printf("{hline 13}{c BT}{hline 64} \n")
			printf("{txt}Constrained parameters: {res}A = 0, S = 0 \n")
			printf("{hline 78} \n")
		}
		else if( Q.shift == 0 & Q.dilation == 0 & Q.truncation == 1 ){
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[1],mStat[1,1],.,.,.,.,. )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[2],mStat[2,1],.,.,.,.,. )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[3],mStat[3,1],mStat[3,2],mStat[3,3],mStat[3,4],mStat[3,5],mStat[3,6] )
			printf("{hline 13}{c BT}{hline 64} \n")
			printf("{txt}Constrained parameters: {res}A = 0, D = 1 \n")
			printf("{hline 78} \n")
		}
		else if( Q.shift == 0 & Q.dilation == 0 & Q.truncation == 0 ){
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[1],mStat[1,1],.,.,.,.,. )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[2],mStat[2,1],.,.,.,.,. )
			printf("{txt}%12s {c |}{res}%11.7g %10.5g   %6.2f %7.3f %12.7g %11.7g\n", 
				sPName[3],mStat[3,1],.,.,.,.,. )
			printf("{hline 13}{c BT}{hline 64} \n")
			printf("{txt}Constrained parameters: {res}A = 0, D = 1, S = 0 \n")
			printf("{hline 78} \n")
		}
	}
}
end
/*---------- END Command estquant ----------*/

