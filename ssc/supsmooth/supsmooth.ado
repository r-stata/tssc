*! version 1.0.1  16june2015
program define supsmooth, rclass sortpreserve

	version 11

	syntax varlist(min=2 max=2 numeric) ///
		[if] [in] [aw] , 				///
		[ 								///
		BWcv(numlist sort)				///
		alpha(real 0)					///
		ALGorithm(string)				///
		TRIcube							///
		GENerate(string)				///
		noGRaph							///
		noSCatter 						///
		midbw(real 0.2) 				///
		finalbw(real 0.05) 				///
		* 								///
		]

	_get_gropts , 	graphopts(`options') gettwoway	///
					getallowed(LINEOPts addplot)
	local options `"`s(graphopts)'"'
	local twopts `"`s(twowayopts)'"'
    local lineopts `"`s(lineopts)'"'
	local addplot `"`s(addplot)'"'
	_check4gropts lineopts, opt(`lineopts')
	if "`algorithm'" == "" {
		local algorithm update
	}
	if "`algorithm'" != "update" & "`algorithm'" != "wfit" {
		di as err 	"{p}check option {cmd:algorithm}; " ///
					"`algorithm' not allowed{p_end}"
		exit 499			
	}
	if "`algorithm'" == "update" & "`tricube'" != "" {
		di as err 	"{p}local weighting not allowed with " ///
					" updating algorithm{p_end}"
		exit 499
	}
	if `"`weight'"' != "" & "`tricube'" != "" {
		di as err 	"{p}option {cmd:tricube} may not be specified" ///
					" in combination with weights{p_end}"
		exit 499			
	}
	if `alpha' < 0 | `alpha' > 10 {
		di as err	"{p}option {cmd:alpha}: value has to be " ///
					"in the range [0,10]{p_end}"
		exit 499
	}
	marksample touse
	if `"`weight'"' != "" {
		tempvar wt
		qui gen double `wt' `exp' if `touse'
		local wgt wgt
		local wexp "`exp'"
	}
	else local wgt nowgt
	if "`tricube'" != "" local wgt tricube
	markout `touse' `varlist' `wt'
	qui count if `touse'
	local N = r(N)
	qui cap assert `N' > 5
	if _rc { 
		if `N' == 0 {
			di as err "no observations"
			exit 2000
		}
		else {
			di as err "insufficient observations; N > 5 required"
			exit 2001
		}
	}
	if "`bwcv'" == "" local bwcv 0.05 0.2 0.5
	local nbw: list sizeof bwcv
	if `:word 1 of `bwcv'' <= 0 | `:word `nbw' of `bwcv'' >= 1 {
		di as err 	"{p}option {cmd:bwcv()}: bandwidths " ///
					"must be in the range (0,1){p_end}"
		exit 499
	}
	if `midbw' <= 0 | `midbw' >= 1 {
		di as err 	"{p}option {cmd:midbw()}: bandwidth " ///
					"must be in the range (0,1){p_end}"
		exit 499	
	}
	if `finalbw' <= 0 | `finalbw' >= 1 {
		di as err 	"{p}option {cmd:finalbw()}: bandwidth " ///
					"must be in the range (0,1){p_end}"
		exit 499	
	}	
	tempname bw
	forval i = 1/`nbw' {
		if `i'>1 local c ,
		local bw`i': word `i' of `bwcv'
		local bwi "`bwi' `c' `bw`i''"
	}
	mat `bw' = (`bwi')
	if "`algorithm'" == "update" local alg 1
	else local alg 0
	tempvar yvar xvar
	local yvar : word 1 of `varlist'
	local xvar : word 2 of `varlist'
	sum `xvar', mean
	if (r(min) == r(max)) {
		di as err "{p}`xvar' is constant{p_end}"
		exit 499
	}
	tempvar stouse
	gen byte `stouse' = 1-`touse'
	sort `stouse' `xvar', stable 
	tempvar ys
	local 0 `generate'	
	if "`0'" != "" {
		syntax namelist(max=1) [ , replace ]
		if "`replace'" == "" {
			confirm new var `namelist'
		}
		else {
			cap drop `namelist'
		}
	}

	mata : supsm_wrk("`yvar' `xvar' `wt'","`touse'","`bw'","`wgt'", ///
					 `alpha',`alg',`midbw',`finalbw')

	if "`generate'" != "" {
		qui gen double `namelist' = `ys'
		local ylab : var lab `yvar'
		local lab = cond("`ylab'" != "", "`ylab'", "`yvar'")
		lab var `namelist' "supsmooth: `lab'"
	}
	return scalar alpha = `alpha'
	return scalar N = `N'
	if "`wgt'" == "wgt" {
		return local wexp = "`wexp'"
	}
	return local algorithm = "`algorithm'"
	return local wgt = "`wgt'"
	return local indepvar = "`xvar'"
	return local depvar = "`yvar'"
	return matrix bw = `bw'
	
	if "`graph'" == "" {
		local yttl : var lab `yvar'
		local xttl : var lab `xvar'
		if "`yttl'" == "" {
			local yttl `yvar'
		}
		if "`xttl'" == "" {
			local xttl `xvar'
		}
		if `nbw' > 1 {
			local note note(Note: cross-validated bandwidths `bwcv'; 
			local note `note' N=`N', pos(7))
		}
		else {
			local note note(Note: fixed bandwidth `bwcv'; N=`N', pos(7))	 
		}
		if "`tricube'" != "" {
			local ttl Adaptive bandwidth lowess smoother
		}
		else {
			if `nbw' > 1 {
				local ttl Friedman's super smoother
			}
			else {
				local ttl Local linear regression smoother
			}
		}
		if "`scatter'" == "" {
			local sca scatter `yvar' `xvar' if `touse', `options' ||
		}
		`sca'									///
		line `ys' `xvar' if `touse', sort 		///
		title(`"`ttl'"')						///
		legend(nodraw) 							///
		`lineopts' `note'						///
		ytitle(`"`yttl'"') xtitle(`"`xttl'"')	///
		|| `addplot' || , `twopts'
	}
end

version 11
mata:

function supsm_wrk(	string scalar vars, 	/*
*/					string scalar touse, 	/*
*/					string scalar bw, 		/*
*/					string scalar wgt, 		/*
*/					real scalar alpha, 		/*
*/					real scalar alg, 		/*
*/					real scalar mbw, 		/*
*/					real scalar fbw)
{
	string rowvector v
	real colvector y
	real colvector x
	string scalar _y
	string scalar _x
	real scalar N
	real scalar nbw
	real colvector fsm
	string scalar ys
	real scalar in
	
	v = tokens(vars)
	_y  = v[1]
	_x  = v[2]
	st_view(y , ., _y , touse)
	st_view(x , ., _x , touse)	
	if (length(v) == 3) {
		real colvector wt
		string scalar _wt
		_wt = v[3]
		st_view(wt, ., _wt, touse)
	}
	N = rows(x)
	bw = st_matrix(st_local("bw"))
	if (wgt == "nowgt") {
		wt = 1
	}
	nbw = length(bw)
	if (nbw > 1) {
		fsm = supsm(x,y,bw,N,alpha,alg,wgt,mbw,fbw,wt)
	}
	else {
		fsm = smo(bw[1],x,y,N,0,alg,wgt,wt)
	}
	in = st_addvar("double", ys = st_tempname())
	st_store((1,N),in,fsm)
	st_local("ys",ys)
}

function supsm(	real colvector x, 		/*
*/ 				real colvector y, 		/*
*/ 				real rowvector bw, 	 	/*
*/ 				real scalar N, 		 	/*
*/ 				real scalar alpha, 	 	/*
*/ 				real scalar alg, 	 	/*
*/ 				string scalar wgt, 	 	/*
*/ 				real scalar midbw, 		/*
*/ 				real scalar fbw, 	 	/*
*/ 				| real colvector wt)
{
	real scalar nbw
	real matrix msmy
	real matrix msme
	real matrix i
	real colvector smy
	real colvector ar
	real colvector sme
	real matrix mbw
	real matrix w
	real colvector mbwopt
	real scalar u
	real scalar jw
	real colvector R
	real colvector smoptbw 
	real colvector sm1
	real colvector sm2
	real colvector bw1
	real colvector bw2
	real matrix a
	real colvector ixl
	real colvector ixh
	real matrix apos
	real colvector ixbw0
	real matrix ixbw
	real scalar j
	real colvector fsm

	nbw = length(bw)
	mbw = J(N,1,bw)
	sm1 = J(N,1,.)
	sm2 = J(N,1,.)
	bw1 = J(N,1,.)
	bw2 = J(N,1,.)
	w = J(1,1,.)
	mbwopt = J(N,1,.)
	msmy = J(N,0,.)
	msme = J(N,0,.)
	for (i = 1; i <= nbw; i++) {
		smy = smo(bw[i],x,y,N,1,alg,wgt,wt)
		ar = smy[.,2]
		sme = smo(midbw,x,ar,N,0,alg,wgt,wt)
		msmy = msmy,smy[.,1]
		msme = msme,sme
	}
	for (u = 1; u <= N; u++) {
		minindex(msme[u,.], 1, i, w)
		mbwopt[u] = bw[i[1]]
	}
	if (alpha > 0) {
		jw = bw[nbw]
		R = rowmin(msme):/msme[.,nbw]
		mbwopt = mbwopt:+(jw:-mbwopt):*R:^(10-alpha)
	}
	smoptbw = smo(midbw,x,mbwopt,N,0,alg,wgt,wt)
	a = (smoptbw:-mbw)
	ixl = smoptbw :< bw[1] 
	ixh = smoptbw :> bw[nbw] 
	smoptbw = (1:-ixl):*smoptbw:+ixl:*bw[1] 
	smoptbw = (1:-ixh):*smoptbw:+ixh:*bw[nbw] 
	apos = a:>0
	ixbw0 = rowsum(apos)
	ixbw = (ixbw0,ixbw0:+1):+(ixbw0:<=0):-(ixbw0:>=nbw)
	for (j = 1; j <= N; j++) {
		sm1[j] = msmy[j,ixbw[j,1]]
		sm2[j] = msmy[j,ixbw[j,2]]
		bw1[j] = bw[ixbw[j,1]]
		bw2[j] = bw[ixbw[j,2]]
	}
	fsm = ((sm1-sm2):/(bw1-bw2):*(smoptbw-bw2)+sm2)
	fsm = smo(fbw,x,fsm,N,0,alg,wgt,wt)
	return(fsm)
}

function rcv0(	real colvector y, 		/*
*/ 				real colvector ys, 		/*
*/ 				real colvector x, 		/*
*/ 				real scalar f, 			/*
*/ 				real scalar t, 			/*
*/ 				real scalar J, 			/*
*/ 				string scalar wgt, 		/*
*/				| real scalar k,		/*
*/ 				  real colvector my,	/*
*/ 				  real colvector wt)
{
	real scalar mx
	real colvector d
	real scalar V
	real colvector E
	real colvector r
	real colvector nw
	real colvector H
	real scalar swt
	real colvector ym_loo

	if (wgt != "wgt" & wgt != "tricube") {
		mx = mean(x)
		d = (x:-mx):^2
		V = quadsum(d)
		if (V > 1e-10) {
			E = abs(y-ys)		
			if (f == t) {
				r = E:/(1-1/J:-(d[k]):/V)
			}
			else {
				r = E:/(1-1/J:-(d[f..t]):/V)
			}
		}
		else {
			my = mean(my)		
			r = abs(y:-(J*my:-y):/(J-1))
		}
	}
	else {
		nw = wt:/mean(wt)
		mx = quadsum(x:*nw)/J
		if (f == t) {
			d = nw[k]*(x[k]-mx)^2/J
			V = quadsum((x:-mx):^2:*nw)/J
			if (V > 1e-10) {
				E = abs(y-ys)
				H = 1-nw[k]/J-d/V
				r = E/H
			}
			else {
				swt = quadsum(nw)
				my = quadsum(my:*nw):/swt
				nw = nw[k]
				ym_loo = (swt*my-nw*y)/(swt-nw)
				r = abs(y-ym_loo)
			}
		}
		else {
			d = nw:*(x:-mx):^2:/J
			V = quadsum((x:-mx):^2:*nw)/J
			if (V > 1e-10) {
				E = abs(y-ys)
				H = 1:-nw/J:-d:/V
				r = E:/H[f..t]
			}
			else {
				swt = quadsum(nw)
				my = quadsum(my:*nw):/swt	
				nw = nw[f..t]
				ym_loo = (swt*my:-nw:*y):/(swt:-nw)
				r = abs(y:-ym_loo)			
			}
		}
	}
	return(r)
}

function rcv(	real colvector yi, 		/*
*/ 				real colvector ysi, 	/*
*/ 				real colvector xi, 		/*
*/ 				real scalar mx, 		/*
*/ 				real scalar V, 			/*
*/ 				real scalar J, 			/*
*/ 				real scalar f, 			/*
*/ 				real scalar t, 			/*
*/ 				string scalar wgt, 		/*
*/ 				| real scalar my, 		/*
*/ 				  real colvector wt, 	/*
*/ 				  real scalar mwt)
{
	real colvector nw
	real colvector E
	real colvector d
	real colvector H
	real colvector r
	real scalar swt
	real colvector ym_loo
	
	if (wgt == "wgt") {
		if (V > 1e-10) {
			nw = wt[f..t]:/mwt
			E = abs(yi:-ysi)
			d = nw:*(xi:-mx):^2/J
			H = 1:-nw/J:-d:/V
			r = E:/H
		}
		else {
			nw = wt:/mwt
			swt = quadsum(nw)
			nw = nw[f..t]
			ym_loo = (swt*my:-nw:*yi):/(swt:-nw)
			r = abs(yi:-ym_loo)
		}
	}
	else {
		if (V > 1e-10) {
			r = abs(yi:-ysi):/(1:-1/J:-(xi:-mx):^2:/V)
		}
		else {
			my = mean(my)		
			r = abs(yi:-(J*my:-yi):/(J-1))
		}
	}
	return(r)
}

function ysm0(	real colvector x, 		/*
*/ 				real colvector y, 		/*
*/ 				real scalar f, 			/*
*/ 				real scalar t, 			/*
*/ 				real scalar J, 			/*
*/ 				string scalar wgt, 		/*
*/				| real scalar k,		/*
*/ 				  real colvector wt)
{
	real colvector c
	real matrix xxi
	real matrix b
	real matrix w
	real matrix xw
	real matrix xwxi
	real matrix xwy
	real colvector ys

	c = J(J,1,1)
	x = x,c
	if (wgt != "wgt" & wgt != "tricube") {
		xxi = invsym(quadcross(x,x))
		b = quadcross(xxi',quadcross(x,y))
	}
	else {
		w = diag(wt)
		xw = quadcross(x,w)'
		xwxi = pinv(quadcross(xw,x))
		xwy = quadcross(xw,y)
		b = quadcross(xwxi,xwy)
	}
	if (f == t) {
		x = x[k,.]
		ys = quadcross(x',b)
	}
	else {
		x = x[f..t,.]
		ys = quadcross(x',b)	
	}
	return(ys)
}

function ysm(	real scalar C, 	/*
*/ 				real scalar V, 	/*
*/ 				real scalar my, /*
*/ 				real scalar mx,	/*
*/ 				real colvector x)
{
	real scalar b
	real scalar a
	real colvector ys
	real scalar n

	if (V > 1e-10) {
		b = C/V
		a = my-b*mx
		ys = a:+b:*x
	}
	else {
		n = length(x)	
		ys = J(n,1,my)
	}
	return(ys)
}

function upd(	real scalar J, 			/*
*/ 				real scalar C,			/*
*/ 				real scalar V,			/*
*/ 				real scalar my, 		/*
*/ 				real scalar mx,			/*
*/ 				real scalar x, 			/*
*/ 				real scalar y, 			/*
*/ 				real scalar u, 			/*
*/ 				string scalar wgt,		/*
*/ 				| real scalar wo, 		/*
*/ 				  real scalar wn, 		/*
*/ 				  real scalar wt)
{
	real matrix uout

	uout = J(1,4,.)
	if (wgt != "wgt") {
		if (u == 1) {
			uout[4] = (J*mx+x)/(J+1)
			uout[3] = (J*my+y)/(J+1)
			uout[1] = C+(J+1)/J*(x-uout[4])*(y-uout[3])
			uout[2] = V+(J+1)/J*(x-uout[4])^2
		}
		else if (u == 2) {
			uout[4] = ((J+1)*mx-x)/J
			uout[3] = ((J+1)*my-y)/J
			uout[1] = C-J/(J+1)*(x-uout[4])*(y-uout[3])
			uout[2] = V-J/(J+1)*(x-uout[4])^2
		}
	}
	else {
		if (u == 1) {
			uout[4] = (wo*mx+wt*x)/wn
			uout[3] = (wo*my+wt*y)/wn
			uout[1] = (wo*C+wn/wo*wt*(x-uout[4])*(y-uout[3]))/wn
			uout[2] = (wo*V+wn/wo*(x-uout[4])^2*wt)/wn
		}
		else if (u == 2) {
			uout[4] = (wo*mx-wt*x)/wn
			uout[3] = (wo*my-wt*y)/wn
			uout[1] = (wo*C-wn/wo*wt*(x-uout[4])*(y-uout[3]))/wn
			uout[2] = (wo*V-wn/wo*(x-uout[4])^2*wt)/wn
		}
	}
	return(uout) 
}

function smo(	real scalar bw, 	/*
*/ 				real matrix x, 		/*
*/ 				real matrix y, 		/*
*/ 				real scalar N, 		/*
*/ 				real scalar cv, 	/*
*/ 				real scalar alg, 	/*
*/ 				string scalar wgt, 	/*
*/ 				| real colvector wt)
{
	real colvector ys
	real colvector r_cv
	real rowvector up
	real scalar k
	real scalar J
	real scalar imk
	real scalar ipk
	real scalar a
	real scalar b
	real scalar delta
	real scalar sw1
	real colvector nw
	real scalar i
	real scalar sw0
	real scalar x0
	real scalar mis
	real scalar misr
	real scalar mwt
	real matrix smout
	
	ys = J(N,1,.)
	r_cv = J(N,1,.)
	up = J(1,4,.)	
	k = floor(0.5*bw*N+0.5)
	if (k < 2) k = 2
	J = k*2+1
	imk = 1
	ipk = J
	if (alg == 0) {
		if (wgt == "tricube") {
			wt = J(N,1,.)
			a = x[ipk]-x[k+1]
			b = x[k+1]-x[imk]
			if (a < 1e-15 & b < 1e-15 ) {
				wt[imk..ipk] = J(J,1,1)
			}
			else {
				delta = 1.001*max((a,b))
				wt[imk..ipk] = (1:-(abs(x[imk..ipk]:-x[k+1]):/delta):^3):^3
			}
			ys[imk..k+1] = 	ysm0(x[imk..ipk],y[imk..ipk], 					  /*
			*/				imk,k+1,J,wgt,1,wt[imk..ipk])
			if (cv == 1) {
				r_cv[imk..k+1] = 	rcv0(y[imk..k+1],ys[imk..k+1], 			  /*
				*/					x[imk..ipk],imk,k+1,J,wgt,1,y[imk..ipk],  /*
				*/					wt[imk..ipk])
			}	
		}
		else if (wgt == "wgt") {
			ys[imk..k+1] = 	ysm0(x[imk..ipk],y[imk..ipk],imk,k+1,J, 		  /*
			*/				wgt,1,wt[imk..ipk])
			if (cv == 1) {
				r_cv[imk..k+1] = 	rcv0(y[imk..k+1],ys[imk..k+1], 			  /*
				*/					x[imk..ipk],imk,k+1,J,wgt,1,y[imk..ipk],  /*
				*/					wt[imk..ipk])
			}
		}
		else {
			ys[imk..k+1] = 	ysm0(x[imk..ipk],y[imk..ipk], /*
			*/				imk,k+1,J,wgt)
			if (cv == 1) {
				r_cv[imk..k+1] = 	rcv0(y[imk..k+1],ys[imk..k+1], /*
				*/					x[imk..ipk],imk,k+1,J,wgt,1,y[imk..ipk])
			}
		}
	}
	else if (alg == 1) {
		if (wgt == "wgt") {	
			sw1 = quadsum(wt[imk..ipk])
			mwt = mean(wt[imk..ipk])
			nw = wt[imk..ipk]:/mwt
			up[4] = quadsum(x[imk..ipk]:*nw)/J
			up[3] = quadsum(y[imk..ipk]:*nw)/J
			up[1] = quadsum((x[imk..ipk]:-up[4]):*(y[imk..ipk]:-up[3]):*nw)/J
			up[2] = quadsum((x[imk..ipk]:-up[4]):^2:*nw)/J
		}
		else {
			up[4] = mean(x[imk..ipk])
			up[3] = mean(y[imk..ipk])
			up[1] = quadsum((x[imk..ipk]:-up[4]):*(y[imk..ipk]:-up[3]))
			up[2] = quadsum((x[imk..ipk]:-up[4]):^2)
		}
		ys[imk..k+1] = ysm(up[1],up[2],up[3],up[4],x[imk..k+1])
		if (cv == 1) {
			if (wgt == "wgt") {
				r_cv[imk..k+1] = 	rcv(y[imk..k+1],ys[imk..k+1],x[imk..k+1], /*
				*/					up[4],up[2],J,imk,k+1,wgt,up[3],    	  /*
				*/					wt[imk..ipk],mwt)
			}
			else {
				r_cv[imk..k+1] = 	rcv(y[imk..k+1],ys[imk..k+1],x[imk..k+1], /*
				*/					up[4],up[2],J,imk,k+1,wgt,up[3])
			}
		}
	}
	for (i=k+2; i <= N-k; i++) {
		imk = i-k
		ipk = imk+J-1
		if (alg == 0) {
			if (i < N-k) {
				if (wgt == "tricube") {	
					a = x[ipk]-x[i]
					b = x[i]-x[imk]
					if (a < 1e-15 & b < 1e-15 ) {
						wt[imk..ipk] = J(J,1,1)
					}
					else {
						delta = 1.001*max((a,b))
						wt[imk..ipk] = (1:-(abs(x[imk..ipk]:-x[i]):/ 		  /*
						*/				delta):^3):^3
					}
					ys[i] = ysm0(x[imk..ipk],y[imk..ipk],i,i,J,wgt,k+1,       /*
					*/			 wt[imk..ipk])
					if (cv == 1) {
						r_cv[i] = rcv0(y[i],ys[i],x[imk..ipk],i,i,J,wgt,k+1,  /*
						*/			   y[imk..ipk],wt[imk..ipk])
					}
				}	
				else if (wgt == "wgt") {
					ys[i] = ysm0(x[imk..ipk],y[imk..ipk],i,i,J,wgt,k+1,       /*
					*/			 wt[imk..ipk])
					if (cv == 1) {
						r_cv[i] = rcv0(y[i],ys[i],x[imk..ipk],i,i,J,wgt,      /*
						*/			   k+1,y[imk..ipk],wt[imk..ipk])
					}
				}
				else {
					ys[i] = ysm0(x[imk..ipk],y[imk..ipk],i,i,J,wgt,k+1)
					if (cv == 1) {
						r_cv[i] = rcv0(y[i],ys[i],x[imk..ipk],i,i,J,wgt, 	  /*
						*/		  k+1,y[imk..ipk])
					}
				}
			}
			else {
				if (wgt == "tricube") {		
					a = x[ipk]-x[imk+k]
					b = x[imk+k]-x[imk]
					if (a < 1e-15 & b < 1e-15 ) {
						wt[imk..ipk] = J(J,1,1)
					}
					else {
						delta = 1.001*max((a,b))
						wt[imk..ipk] = (1:-(abs(x[imk..ipk]:-x[imk+k]):/ 	  /*
						*/			   delta):^3):^3
					}
					ys[imk+k..ipk] = ysm0(x[imk..ipk],y[imk..ipk],k+1,J,J,    /*
					*/				 wgt,1,wt[imk..ipk])
					if (cv == 1) {
						r_cv[imk+k..ipk] = rcv0(y[imk+k..ipk],ys[imk+k..ipk], /*
						*/			   	   x[imk..ipk],k+1,J,J,wgt,1, 		  /*
						*/			   	   y[imk..ipk],wt[imk..ipk])
					}
				}
				else if (wgt == "wgt") {
					ys[imk+k..ipk] = ysm0(x[imk..ipk],y[imk..ipk],k+1,J,J, 	  /*
					*/					  wgt,1,wt[imk..ipk])
					if (cv == 1) {
						r_cv[imk+k..ipk] = rcv0(y[imk+k..ipk],ys[imk+k..ipk], /*
						*/				   x[imk..ipk],k+1,J,J,wgt,1, 		  /*
						*/				   y[imk..ipk],wt[imk..ipk])
					}
				}
				else {
					ys[imk+k..ipk] = ysm0(x[imk..ipk],y[imk..ipk],k+1,J,J,wgt)
					if (cv == 1) {
						r_cv[imk+k..ipk] = rcv0(y[imk+k..ipk],ys[imk+k..ipk], /*
						*/				   x[imk..ipk],k+1,J,J,wgt,1, 		  /*
						*/				   y[imk..ipk])
					}
				}				
			}
		}
		else if (alg == 1) {
			if (wgt == "wgt") {
				sw0 = sw1
				sw1 = sw1 + wt[ipk]
				up = upd(J,up[1],up[2],up[3],up[4],x[ipk], /*
				*/	 y[ipk],1,wgt,sw0,sw1,wt[ipk])
				sw0 = sw1
				sw1 = sw1 - wt[imk-1]
				up = upd(J,up[1],up[2],up[3],up[4],x[imk-1], /*
				*/	 y[imk-1],2,wgt,sw0,sw1,wt[imk-1])
				if (i < N-k) {
					x0 = x[i]
					ys[i] = ysm(up[1],up[2],up[3],up[4],x0)	
					if (cv == 1) {
						mwt = sw1/J	
						r_cv[i] = 	rcv(y[i],ys[i],x[i], 		/*
						*/			up[4],up[2],J,k+1,k+1,wgt, 	/*
						*/			up[3],wt[imk..ipk],mwt)
					}
				}
				else {
					ys[imk+k..ipk] = ysm(up[1],up[2],up[3],up[4],x[imk+k..ipk])
					if (cv == 1) {
						mwt = mean(wt[imk..ipk])					
						r_cv[imk+k..ipk] = 	rcv(y[imk+k..ipk],ys[imk+k..ipk], /*
						*/					x[imk+k..ipk],up[4],up[2],J,k+1,  /*
						*/					J,wgt,up[3],wt[imk..ipk],mwt)
					}
				}
			}
			else {
				up = upd(J,up[1],up[2],up[3],up[4],x[ipk],y[ipk],1,wgt)
				up = upd(J,up[1],up[2],up[3],up[4],x[imk-1],y[imk-1],2,wgt)
				if (i < N-k) {
					x0 = x[i]
					ys[i] = ysm(up[1],up[2],up[3],up[4],x0)	
					if (cv == 1) {
						r_cv[i] = 	rcv(y[i],ys[i],x[i], /*
						*/			up[4],up[2],J,k+1,k+1,wgt,up[3])
					}	
				}			
				else {
					ys[imk+k..ipk] = ysm(up[1],up[2],up[3],up[4],x[imk+k..ipk])
					if (cv == 1) {
						r_cv[imk+k..ipk] = rcv(y[imk+k..ipk],ys[imk+k..ipk], /*
						*/				   x[imk+k..ipk], /*
						*/				   up[4],up[2],J,k+1,J,wgt,up[3])
					}
				}				
			}
		}
	}
	mis = colmissing(ys)
	if (mis > 0) {
		printf("{err}missing values encountered among smoothed values\n")
		exit(499)
	}
	if (cv == 1) {
		misr = colmissing(r_cv)
		if (misr>0) {
			printf("{err}missing values encountered among smoothed values\n")
			exit(499)
		}			
	}
	if (cv == 1) {
		smout = ys,r_cv
	}
	else smout = ys
	return(smout)
}

end
