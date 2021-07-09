*! version 2.0.5, Ben Jann, 20may2008
version 9.2
mata:


real colvector kdens(
/*1*/  real colvector x,
/*2*/  real colvector w,
/*3*/  real colvector g,
/*4*/  | real scalar h, // may be replaced if too small
/*5*/    string scalar kernel,
/*6*/    real scalar adaptive,
/*7*/    real scalar lb,
/*8*/    real scalar ub,
/*9*/    real scalar btype,
/*10*/   l,   // will be replaced by local bw factors
/*11*/   gc,  // will be replaced by grid counts (undocumented)
/*12*/   real scalar q, // quietly (undocumented)
/*13*/   pointer(real colvector function) scalar lbwf) // lbwf function (undocumented)
{
    real scalar     hmin, kdel0, i
    real colvector  d

    if (args()<7)  lb = 0
    if (args()<8)  ub = 0
    if (args()<6)  adaptive = 0
    if (args()<4)  h = kdens_bw(x, w, "silverman", kernel)
    if (args()<12) q = 0
    if (args()<13) lbwf = &kdens_lbwf()

    if (min(x)<g[1] | max(x)>g[rows(g)]) _error("data out of grid range")

    if (h>=.) return(J(rows(g),1,.))
    kdel0 = (*_mm_findkdel0(kernel))()
    hmin = (g[rows(g)]-g[1])/(rows(g)-1) / 2 *
           kdel0 / mm_kdel0_rectangle()
    if (h<hmin) {
        if (q==0) printf("{txt}(bandwidth too small;" +
         "reset to {res}%g{txt})\n", hmin)
        h = hmin
    }
    gc = mm_fastlinbin(x, w, g)
    d = kdens_bin(g, gc, h, kernel, lb, ub, btype)
    l = 1
    for (i=1; i<=adaptive; i++) {
        l = (*lbwf)(g, gc, g, d)
        d = kdens_bin(g, gc, h*l, kernel, lb, ub, btype)
    }
    return(d)
}


real colvector _kdens(
/*1*/  real colvector x,
/*2*/  real colvector w,
/*3*/  real colvector g,
/*4*/  | real scalar h,
/*5*/    string scalar kernel,
/*6*/    real scalar adaptive,
/*7*/    real scalar ll,
/*8*/    real scalar ul,
/*9*/    real scalar btype,
/*10*/   l,             // will be replaced by local bw factors
/*11*/   pointer(real colvector function) scalar lbwf) // lbwf function (undocumented)
{
    real scalar     i
    real colvector  d

    if (args()<6)  adaptive = 0
    if (args()<4)  h = kdens_bw(x, w, "silverman", kernel)
    if (args()<11) lbwf = &kdens_lbwf()

    if (h>=.) return(J(rows(g),1,.))
    d = kdens_gen(x, w, g, h, kernel, ll, ul, btype)
    l = 1
    for (i=1; i<=adaptive; i++) {
        l = (*lbwf)(x, w, g, d)
        d = kdens_gen(x, w, g, h*l, kernel, ll, ul, btype)
    }
    return(d)
}


real colvector kdens_var(
/*1*/  real colvector d,
/*2*/  real colvector x,
/*3*/  real colvector w,
/*4*/  real colvector g,
/*5*/  | real scalar h,
/*6*/    string scalar kernel,
/*7*/    real scalar pw, // !=0 pweights
/*8*/    real scalar lb,
/*9*/    real scalar ub,
/*10*/   real scalar btype,
/*11*/   real colvector l,
/*12*/   real colvector gc) // provide grid counts (undocumented)
{
    real colvector gcsq
    real scalar    ll, ul

    if (args()<5)          h = kdens_bw(x, w, "silverman", kernel)
    if (args()<7)          pw = 0
    if (args()<8)          lb = 0
    if (args()<9)          ub = 0
    if (args()<11)         l = 1
    if (args()<12 & pw==0) gc = mm_fastlinbin(x, w, g)

    if (lb) ll = g[1]
    if (ub) ul = g[rows(g)]

    if (pw | btype==1 | btype==2) {
        if (pw==0) return(kdens_evar(g, gc, g, h*l, d, kernel, 0,
         ll, ul, btype))
        gcsq = sqrt(mm_fastlinbin(x, w:^2, g)) // assuming sum(w) = rows(x)
        return(colsum(gcsq)^2/rows(x)^2 *
         kdens_evar(g, gcsq, g, h*l, d, kernel, 1, ll, ul, btype))
    }
    return(kdens_avar(g, gc, g, h*l, d, kernel, 0, ll, ul))
}


real colvector _kdens_var(
/*1*/  real colvector d,
/*2*/  real colvector x,
/*3*/  real colvector w,
/*4*/  real colvector g,
/*5*/  | real scalar h,
/*6*/    string scalar kernel,
/*7*/    real scalar pw, // !=0 pweights
/*8*/    real scalar ll,
/*9*/    real scalar ul,
/*10*/   real scalar btype,
/*11*/   real colvector l)
{
    real colvector gcsq

    if (args()<5)          h = kdens_bw(x, w, "silverman", kernel)
    if (args()<7)          pw = 0
    if (args()<11)         l = 1

    if (pw | btype==1 | btype==2)
        return(kdens_evar(x, w, g, h*l, d, kernel, pw, ll, ul, btype))
    return(kdens_avar(x, w, g, h*l, d, kernel, 0, ll, ul))
}


real scalar kdens_bw(
 real colvector x,         // data points
 | real colvector w,       // weights
   string scalar type,     // type of bandwith estimate
   string scalar kernel,   // kernel
   real scalar m,          // number of evaluation points
   real scalar ll,         // lower bound
   real scalar ul,         // upper bound
   real scalar dpi)        // number of levels for dpi
{
	real scalar kdel0

	if (args()==1) w = 1
	kdel0 = (*_mm_findkdel0(kernel))()
	if (type=="sjpi")
	 return(kdel0 * kdens_bw_sjpi(x, w, m, "minim", ll, ul))
	if (type=="dpi")
	 return(kdel0 * kdens_bw_dpi(x, w, m, "minim", ll, ul, dpi))
	return(kdel0 * kdens_bw_simple(x, w, type,
	 (type=="oversmoothed" ? "stddev" : "minim")))
}


real colvector kdens_grid(
 real colvector x,
 | real colvector w,
   real scalar h,           // may be replaced if too small
   string scalar kernel,
   real scalar m,           // number of evaluation points
   real scalar min,
   real scalar max)
{
	real scalar ltau, utau, L, U, hmin, kdel0

	if (args()==1) w = 1
	if (args()<5)  m = 512
	if (args()<3)  h = kdens_bw(x, w, "silverman", kernel)

	ltau = utau = (kernel=="epanechnikov" ? sqrt(5) :
	 (kernel=="cosine" ? .5 : (kernel=="gaussian" ? 3 : 1)))
	L = min(x)
	if (min<. & min<=L) {; L = min; ltau = 0; }
	U = max(x)
	if (max<. & max>=U) {; U = max; utau = 0; }

	 // the following formula determines the minimal h given the grid size;
	 // it takes into account that there is a feedback effect of h on the
	 // distance between grid points (because the grid support depends on h)
	kdel0 = (*_mm_findkdel0(kernel))()
	hmin = (U - L)*kdel0 / (2*(m-1)*mm_kdel0_rectangle() - (ltau+utau)*kdel0)
	if (h<hmin) {
		printf("{txt}(bandwidth too small; reset to {res}%g{txt})\n", hmin)
		h = hmin
	}
	return(rangen(L - ltau*h, U + utau*h, m))
}


real colvector kdens_gen(
 real colvector x,          // data points
 real colvector w,          // weights
 real colvector g,          // grid points ("at" values)
 real colvector h,          // bandwidth
 | string scalar kernel,    // kernel
   real scalar ll,          // lower bound
   real scalar ul,          // upper bound
   real scalar btype)       // 0=renorm, 1=reflection, 2=linear correction
{
    real scalar     i
    real colvector  d
    pointer scalar  k, K

// find kernel function and set up results vector
    k = _mm_findkern(kernel)
    d = J(rows(g),1,.)

// standard estimator (unbounded)
    if (ll>=. & ul>=.) {
        for (i=1; i<=rows(g); i++) {
            d[i] = colsum( w:/h :* (*k)((g[i]:-x):/h) )
        }
        return( d / mm_nobs(x, w) )
    }

// boundary estimators
    if ( (ll<. & min(x)<ll) | (ul<. & max(x)>ul) )
        _error("data out of range")
    if (btype!=1) K = _mm_findkint(kernel)
    for (i=1; i<=rows(g); i++) {
        if ((ll<. & g[i]<ll) | g[i]>ul) {
            d[i] = 0
            continue
        }
        if (btype==1) d[i] = colsum( w:/h :*
         _kdens_bkern_refl(x, g[i], h, k, ll, ul) )    // reflection
        else if (btype==2) d[i] = colsum( w:/h :*
         _kdens_bkern_lc(x, g[i], h, k, K, ll, ul) )   // linear correction
        else d[i] = colsum( w:/h :*
         _kdens_bkern_norm(x, g[i], h, k, K, ll, ul) ) // renormalization
    }
    return( d / mm_nobs(x, w) )
}

real colvector _kdens_bkern_refl( // reflection estimator
 real colvector x,
 real scalar gi,
 real colvector h,
 pointer(real matrix function) scalar k,
 real scalar ll,
 real scalar ul)
{
    real colvector arg

    arg = (*k)((gi:-x):/h)
    if (ll<.) arg = arg + (*k)((gi-2*ll:+x):/h)
    if (ul<.) arg = arg + (*k)((gi-2*ul:+x):/h)
    return(arg)
}

real colvector _kdens_bkern_lc( // linear correction estimator
 real colvector x,
 real scalar gi,
 real colvector h,
 pointer(real matrix function) scalar k,
 pointer(real matrix function) scalar K,
 real scalar ll,
 real scalar ul)
{
    real colvector a0, a1, a2, uli, lli, xi

    if (ul<.) {
        uli = (ul-gi):/h
        a0 = (*K)(1, uli)
        a1 = -(*K)(3, uli)
        a2 = (*K)(4, uli)
        if (ll<.) {
            lli = (ll-gi):/h
            a0 = a0 :- (*K)(1, lli)
            a1 = a1 :+ (*K)(3, lli)
            a2 = a2 :- (*K)(4, lli)
        }
    }
    else if (ll<.) {
        lli = (gi-ll):/h
        a0 = (*K)(1, lli)
        a1 = (*K)(3, lli)
        a2 = (*K)(4, lli)
    }
    else /*no correction*/ {
        a0 = 1; a1 = 0; a2 = (*K)(4)
    }
    xi = (gi:-x):/h
    return((a2 :- a1:*xi):/(a0:*a2-a1:^2) :* (*k)(xi))
}

real colvector _kdens_bkern_norm( // renormalization estimator
 real colvector x,
 real scalar gi,
 real colvector h,
 pointer(real matrix function) scalar k,
 pointer(real matrix function) scalar K,
 real scalar ll,
 real scalar ul)
{
    real colvector arg

    if (ll<. & ul<.) arg = (*K)(1, (ul-gi):/h) - (*K)(1, (ll-gi):/h)
    else if (ll<.)   arg = (*K)(1, (gi-ll):/h)
    else if (ul<.)   arg = (*K)(1, (ul-gi):/h)
    else             arg = 1
    return( (*k)((gi:-x):/h) :/ arg )
}


real colvector kdens_bin(
 real colvector g,        // grid points
 real colvector gc,       // grid counts
 real colvector h,        // bandwidth
 | string scalar kernel,  // kernel
   real scalar lb,        // lower bounded
   real scalar ub,        // upper bounded
   real scalar btype)     // 0=renorm, 1=reflection, 2=linear correction
{
	if (args()<5) lb = 0
	if (args()<6) ub = 0
	if (rows(g)!=rows(gc)) _error(3200)
	if (rows(h)!=1 | (btype==2&(lb|ub))) // adaptive kernel or linear correction
	 return(_kdens_bin(g, gc, h, kernel, lb, ub, btype))
	return(_kdens_bin_fft(g, gc, h, kernel, lb, ub, btype))
}

real colvector _kdens_bin_fft(
 real colvector g,
 real colvector gc,
 real scalar h,
 string scalar kernel,
 real scalar lb,
 real scalar ub,
 real scalar btype)
{
	real scalar    n, tau, L, M, a, b, first, last
	real colvector kappa, bc, gc0
	pointer scalar k, K, gcp

	k = _mm_findkern(kernel)

//compute kappa
	a = colmin(g)
	b = colminmax(g,1)[2,.] //b=. if missing(g)>.
	M = rows(g)
	n = colsum(gc)
	if (kernel=="gaussian") L = M-1 +
	 (M-1)*(lb & btype==1) + (M-1)*(ub & btype==1)
	else {
		if (kernel=="cosine")            tau = .5
		else if (kernel=="epanechnikov") tau = sqrt(5)
		else                             tau = 1
		L = min((floor(tau*h*(M-1)/(b-a)), M-1 +
		    (M-1)*(lb & btype==1) + (M-1)*(ub & btype==1)))
		if (L<1) L = 1
	}
	kappa = (*k)( (0::L) * (b-a) / (h*(M-1)) )

//prepare gc for reflection estimator
	first = (lb & btype==1 ? M : 1)
	last = first + (M-1)
	if ((lb | ub) & btype==1) {
		if (isfleeting(gc)) gcp = &gc
		else gcp = &gc0
		*gcp = (lb ? gc[M::2] : J(0,1,.)) \ gc \
		       (ub ? gc[M-1::1] : J(0,1,.))
		if (lb) (*gcp)[first] = 2 * (*gcp)[first]
		if (ub) (*gcp)[last]  = 2 * (*gcp)[last]
	}
	else gcp = &gc

//determine boundary correction factors
	if ((lb==0 & ub==0) | btype==1) bc = 1
	else {
		K = _mm_findkint(kernel)
		if (lb & ub)
		  bc = (*K)(1, (g[rows(g)]:-g)/h) - (*K)(1, (g[1]:-g)/h)
		else if (lb)
		  bc = (*K)(1, (g:-g[1])/h)
		else //if (ub)
		  bc = (*K)(1, (g[rows(g)]:-g)/h)
	}

	return( convolve( (kappa[L+1::1] \ kappa[|2 \ L+1|]),
	 *gcp)[|L+first \ L+last|] :/ (n * h * bc) )
}

real colvector _kdens_bin(
 real colvector g,
 real colvector gc,
 real colvector h,
 string scalar kernel,
 real scalar lb,
 real scalar ub,
 real scalar btype)
{
	real scalar    n, m, mi, i, lo, up, b, e, delta, tau, ll, ul
	real colvector d
	pointer scalar k, K, hi

	if (kernel=="gaussian")
	 return(kdens_gen(g, gc, g, h, kernel, lb, ub, btype))

	k = _mm_findkern(kernel)
	if ((lb | ub) & btype!=1) K = _mm_findkint(kernel)
	if (rows(h)==1) hi = &1
	else hi = &i
	n = rows(g)
	d = J(n,1,0)
	delta = (g[n]-g[1])/(n-1) // equally spaced grid assumed
	if (kernel=="cosine")            tau = .5
	else if (kernel=="epanechnikov") tau = sqrt(5)
//	else if (kernel=="gaussian")     tau = 1000
	else                             tau = 1
	if ( lb==0 & ub==0 ) { // unbounded support
		for (i=1; i<=n; i++) {
			if (gc[i]==0) continue
			m  = h[*hi] / delta
			mi = trunc(m*tau)
			lo = max((1-i, -mi))
			up = min((n-i, mi))
			b = i+lo
			e = i+up
			d[|b \ e|] = d[|b \ e|] + gc[i] / h[*hi] * (*k)((lo::up)/m)
		}
		return(d/colsum(gc))
	}
	for (i=1; i<=n; i++) {
		if (gc[i]==0) continue
		m  = h[*hi] / delta
		mi = trunc(m*tau)
		lo = max((1-i, -mi))
		up = min((n-i, mi))
		b = i+lo
		e = i+up
		ll = lb ? 1-i : .
		ul = ub ? n-i : .
		if ( (m*tau)<(lo-ll) & (m*tau)<(ul-up) )
		 d[|b \ e|] = d[|b \ e|] + gc[i] / h[*hi] * (*k)((lo::up)/m)
		else
		 d[|b \ e|] = d[|b \ e|] + gc[i] / h[*hi] *
		  (btype==1 ? _kdens_bin_refl(lo::up, m, k, ll, ul) :
		  (btype==2 ? _kdens_bin_lc(lo::up, m, k, K, ll, ul) :
		              _kdens_bin_norm(lo::up, m, k, K, ll, ul)))
	}
	return(d/colsum(gc))
}

real colvector _kdens_bin_refl( // reflection estimator
 real colvector x,
 real scalar h,
 pointer(real matrix function) scalar k,
 real scalar ll,
 real scalar ul)
{
	real colvector arg

	arg = (*k)(x/h)
	if (ll<.) arg = arg + (*k)((x:-2*ll)/h)
	if (ul<.) arg = arg + (*k)((x:-2*ul)/h)
	return(arg)
}

real colvector _kdens_bin_lc( // linear correction estimator
 real colvector x,
 real scalar h,
 pointer(real matrix function) scalar k,
 pointer(real matrix function) scalar K,
 real scalar ll,
 real scalar ul)
{
	real colvector a0, a1, a2, uli, lli, xi

	if (ul<.) {
		uli = (ul:-x)/h
		a0 = (*K)(1, uli)
		a1 = -(*K)(3, uli)
		a2 = (*K)(4, uli)
		if (ll<.) {
			lli = (ll:-x)/h
			a0 = a0 :- (*K)(1, lli)
			a1 = a1 :+ (*K)(3, lli)
			a2 = a2 :- (*K)(4, lli)
		}
	}
	else if (ll<.) {
		lli = (x:-ll)/h
		a0 = (*K)(1, lli)
		a1 = (*K)(3, lli)
		a2 = (*K)(4, lli)
	}
	else /*no correction*/ {
		a0 = 1; a1 = 0; a2 = (*K)(4)
	}
	xi = x/h
	return((a2 :- a1:*xi):/(a0:*a2-a1:^2) :* (*k)(xi))
}

real colvector _kdens_bin_norm( // renormalization estimator
 real colvector x,
 real scalar h,
 pointer(real matrix function) scalar k,
 pointer(real matrix function) scalar K,
 real scalar ll,
 real scalar ul)
{
	real colvector arg

	if (ll<. & ul<.) arg = (*K)(1, (ul:-x)/h) - (*K)(1, (ll:-x)/h)
	else if (ll<.)   arg = (*K)(1, (x:-ll)/h)
	else if (ul<.)   arg = (*K)(1, (ul:-x):/h)
	else             arg = 1
	return( (*k)(x/h) :/ arg )
}


real colvector  kdens_dd(
 real colvector g,       // grid points
 real colvector gc,      // grid counts
 real scalar h,          // bandwidth
 real scalar drv,        // derivative
 | real scalar lb,       // lower bounded
   real scalar ub)       // upper bounded
{
	real scalar n, L, M, a, b, i, first, last
	real colvector kappam, arg, hmold0, hmold1, hmnew, gc0
	pointer scalar gcp

	if (args()<5) lb = 0
	if (args()<6) ub = 0

// compute kappam
	if (drv>=.) _error(3351)
	if (drv<0) _error(3498, "drv must be nonegative")
	a   = min(g)
	b   = colminmax(g,1)[2,.] //b=. if missing(g)>.
	M   = rows(g)
	n   = colsum(gc)
	L   = min( (floor((4+2*drv)*h*(M-1)/(b-a)), M-1 +
	      (M-1)*(lb) + (M-1)*(ub)) )
	if (L<1) L = 1
	arg = (0::L) * (b-a) / (h*(M-1))
	kappam = normalden(arg)
	hmold0 = 1
	hmold1 = arg
	hmnew  = 1
	for (i=2; i<=2*drv; i++) { // compute mth degree Hermite polynomial
		hmnew  = arg:*hmold1 :- (i-1)*hmold0
		hmold0 = hmold1
		hmold1 = hmnew
	}
	kappam = hmnew:*kappam

//prepare gc (reflection)
	first = (lb ? M : 1)
	last = first + (M-1)
	if (lb | ub) {
		if (isfleeting(gc)) gcp = &gc
		else gcp = &gc0
		*gcp = (lb ? gc[M::2] : J(0,1,.)) \ gc \
		       (ub ? gc[M-1::1] : J(0,1,.))
		if (lb) (*gcp)[first] = 2 * (*gcp)[first]
		if (ub) (*gcp)[last]  = 2 * (*gcp)[last]
	}
	else gcp = &gc

// compute estimate
	return( convolve((kappam[L+1::1] \ kappam[|2 \ L+1|]),
	 *gcp)[|L+first \ L+last|] / (n*h^(2*drv+1)) )
}


real colvector  kdens_df(
 real colvector g,       // grid points
 real colvector gc,      // grid counts
 real scalar h,          // bandwidth
 real scalar drv,        // derivative
 | real scalar lb,       // lower bounded
   real scalar ub)       // upper bounded
{
	if (args()<5) lb = 0
	if (args()<6) ub = 0
	return( (-1)^drv *
	 colsum( gc :* kdens_dd(g, gc, h, drv, lb, ub) ) / colsum(gc) )
}


real colvector kdens_avar(
 real colvector x,          // data points
 real colvector w,          // weights
 real colvector g,          // grid points ("at" values)
 real colvector h,          // bandwidth
 real colvector d,          // density estimate
 | string scalar kernel,   // kernel
   real scalar pw,          // !=0 pweights
   real scalar ll,          // lower bound
   real scalar ul)          // upper bound
{
    real scalar     Nfrac
    real colvector  hg, Ri
    pointer scalar  hp, K

    if (args()<7) pw = 0
    K = _mm_findkint(kernel)

// weights
    if (pw) {
        if (rows(w)==1) Nfrac = 1 / rows(x)
        else Nfrac = colsum(w:^2) / colsum(w)^2
    }
    else Nfrac = 1 / mm_nobs(x, w)

// variance estimate (fixed h and unbounded support)
    if (rows(h)==1 & ll>=. & ul>=.)
     return( Nfrac * ( (*K)(2)/h * d - d:^2 ) )

// interpolate h for grid points
    if (rows(h)!=1 & x!=g) {
        if (isfleeting(h)) hp = &h
        else hp = &hg
        *hp = mm_ipolate(x, h, g, 1)
    }
    else hp = &h

// variance estimate (variable h and unbounded support)
    if (ll>=. & ul>=.)
     return( Nfrac * ( (*K)(2) * d :/ (*hp) - d:^2 ) )

// boundary corrected variance estimate
    if ( (ll<. & min(x)<ll) | (ul<. & max(x)>ul) )
        _error("data out of range")
    if (ll<. & ul<.)
     Ri = ( (*K)(2, (ul:-g):/(*hp)) -
            (*K)(2, (ll:-g):/(*hp)) ) :/
          ( (*K)(1, (ul:-g):/(*hp)) -
            (*K)(1, (ll:-g):/(*hp)) ):^2
    else if (ll<.)
     Ri = ( (*K)(2, (g:-ll):/(*hp)) ) :/
          ( (*K)(1, (g:-ll):/(*hp)) ):^2
    else //if (ul<.)
     Ri = ( (*K)(2, (ul:-g):/(*hp)) ) :/
          ( (*K)(1, (ul:-g):/(*hp)) ):^2
    return( Nfrac * ( d :* Ri :/ (*hp) - d:^2 ) )
}


real colvector kdens_evar(
 real colvector x,          // data points
 real colvector w,          // weights
 real colvector g,          // grid points ("at" values)
 real colvector h,          // bandwidth
 real colvector d,          // density estimate
 | string scalar kernel,    // kernel
   real scalar pw,          // !=0 pweights
   real scalar ll,          // lower bound
   real scalar ul,          // upper bound
   real scalar btype)       // 0=renorm, 1=reflection, 2=linear correction
{
    real scalar     i, W
    real colvector  V, arg
    pointer scalar  k, K

    if (args()<7) pw = 0

// find kernel function and set up results vector
    k = _mm_findkern(kernel)
    W = mm_nobs(x, w)
    V = J(rows(g),1,.)

// standard estimator (unbounded)
    if (ll<. & ul<.) {
        for (i=1; i<=rows(g); i++) {
            arg = (*k)((g[i]:-x):/h)
            if (pw) V[i] = colsum( w:^2 :* (arg:/h :- d[i]):^2 ) / W
            else    V[i] = colsum( w:/h:^2 :* arg:^2 ) / W - d[i]^2
        }
        return(V/W)
    }

// boundary estimators
    if ( (ll<. & min(x)<ll) | (ul<. & max(x)>ul) )
        _error("data out of range")
    if (btype!=1) K = _mm_findkint(kernel)
    for (i=1; i<=rows(g); i++) {
        if ((ll<. & g[i]<ll) | g[i]>ul) {
            V[i] = 0
            continue
        }
        if (btype==1)      arg = _kdens_bkern_refl(x, g[i], h, k, ll, ul)
        else if (btype==2) arg = _kdens_bkern_lc(x, g[i], h, k, K, ll, ul)
        else               arg = _kdens_bkern_norm(x, g[i], h, k, K, ll, ul)
        if (pw) V[i] = colsum( w:^2 :* (arg:/h :- d[i]):^2 ) / W
        else    V[i] = colsum( w:/h:^2 :* arg:^2 ) / W - d[i]^2
    }
    return(V/W)
}


real scalar kdens_bw_simple(
 real colvector x,        // data points
 | real colvector w,      // weights
   string scalar rule0,   // silverman (default), normalscale, oversmoothed
   string scalar scale)   // minim (default), stddev, iqr
{
	string scalar rule
	real scalar r

	if (args()==1) w = 1
	rule = ( rule0!="" ? rule0 : "silverman")
	if (rule=="silverman")         r = 0.9 / mm_kdel0_gaussian()
	else if (rule=="normalscale")  r = (8*sqrt(pi())/3)^.2
	else if (rule=="oversmoothed") r = (243/35)^.2
	else _error(3498, `"""' + rule + `"" invalid"')
	return( r * _kdens_bw_scale(x, w, scale) / mm_nobs(x, w)^.20 )
}

real scalar _kdens_bw_scale(
 real colvector x,       // data points
 | real colvector w,     // weights
   string scalar scale0) // minim (default), stddev, iqr
{
	string scalar scale
	real scalar s

	if (args()==1) w = 1
	scale = ( scale0!="" ? scale0 : "minim")
	if (scale=="minim")
	  s = min((sqrt(variance(x, w)), mm_iqrange(x, w) / 1.349))
	else if (scale=="stddev")
	  s = sqrt(variance(x, w))
	else if (scale=="iqr")
	  s = mm_iqrange(x, w) / 1.349
	else _error(3498, `"""' + scale + `"" invalid"')
	if (s<=0) s = sqrt(variance(x, w)) //rarely happens
	return(s)
}


real scalar kdens_bw_dpi(
 real colvector x,        // data points
 | real colvector w,      // weights
   real scalar m,         // number of bins
   string scalar scale,   // scale estimate: minim (default), stddev, iqr,
   real scalar ll,        // lower bound
   real scalar ul,        // upper bound
   real scalar level0)    // number of levels
{
    real scalar n, s, psi, alpha, level, i
    real colvector g, gc

    if (args()==1) w = 1
    level = (level0<. ? level0 : 2)
    if (level<0 | trunc(level)!=level)
      _error(3498, "level should be a positive integer")

//grid
    g = mm_makegrid(x, m, 0, ll, ul)
    if (min(x)<g[1] | max(x)>g[rows(g)]) _error("data out of grid range")
    gc = mm_fastlinbin(x, w, g)
    n = colsum(gc)
    s = _kdens_bw_scale(x, w, scale)

//Plug-in steps
    if (level==0) {
        psi = 3/(8*sqrt(pi())*s^5)
    }
    else {
        alpha = (2*(sqrt(2)*s)^(3+2*(level+1)) /
                ((1+2*(level+1))*n))^(1/(3+2*(level+1)))
        for (i=level; i>=1; i--) {
            psi = kdens_df(g, gc, alpha, i+1, ll<., ul<.)
            if (i>1) alpha = ( factorial(i*2)/(2^i*factorial(i)) *
             sqrt(2/pi())/(psi*n) )^(1/(3+2*(i)))
        }
    }

    return( (1/(psi*n))^(1/5) )
}


real scalar kdens_bw_sjpi(
 real colvector   x,      // data points
 | real colvector w,      // weights
   real scalar    m,      // number of bins
   string scalar  scale0, // scale estimate: minim (d), stddev, iqr
   real scalar    ll,     // lower bound
   real scalar    ul)     // upper bound
{
    real scalar    n, s, lambda, hmin, ax, bx, rc
    real colvector g, gc
    real rowvector h
    string scalar  scale

    if (args()==1) w = 1

//grid
    g     = mm_makegrid(x, m, 0, ll, ul)
    if (min(x)<g[1] | max(x)>g[rows(g)]) _error("data out of grid range")
    gc    = mm_fastlinbin(x, w, g)
    n     = colsum(gc)
    s     = sqrt(variance(x, w))
    scale = ( scale0!="" ? scale0 : "minim")
    if      (scale=="minim")  lambda = min((s, mm_iqrange(x, w) / 1.349))
    else if (scale=="stddev") lambda = s
    else if (scale=="iqr")    lambda = mm_iqrange(x, w) / 1.349
    else _error(3498, `"""' + scale + `"" invalid"')
    if      (lambda<=0)       lambda = s

//root finding
    hmin = (g[rows(g)]-g[1])/(rows(g)-1) / 2 *
      mm_kdel0_gaussian() / mm_kdel0_rectangle()
    bx = s * (243/(35*n))^.2 * mm_kdel0_gaussian()    // h_oversmoothed
    while (1) {
        if (hmin>=bx) return(.)
        ax = max((hmin, bx*0.1))
        rc = mm_root(h=., &_kdens_bw_sjpi(), ax, bx, ax*0.1, 100,
          g, gc, lambda, ll<., ul<.)
        if ( rc==2 ) bx = ax        // continue if solution < ax
        else return(h / mm_kdel0_gaussian())
    }
}

real scalar _kdens_bw_sjpi(
 real scalar h,
 real colvector g,
 real colvector gc,
 real scalar lambda,
 real scalar lb,
 real scalar ub)
{
    real scalar n, a, b, tdb, sda, alpha2, sdalpha2

    n         = colsum(gc)
    a         = 1.241 * lambda * n^(-1/7)
    b         = 1.230 * lambda * n^(-1/9)
    tdb       = kdens_df(g, gc, b, 3, lb, ub)
    sda       = kdens_df(g, gc, a, 2, lb, ub)
    alpha2    = 1.357 * (sda/tdb)^(1/7) * h^(5/7)
    sdalpha2  = kdens_df(g, gc, alpha2, 2, lb, ub)
    return((mm_kint_gaussian(2)/(n * sdalpha2))^0.2 - h)
}


real colvector kdens_lbwf(
 real colvector x,          // data points
 real colvector w,          // weights
 real colvector g,          // grid points ("at" values)
 real colvector d)          // initial density estimates
{
	real colvector l

	if (x==g) l = d
	else l = mm_ipolate(g, d, x)
	l = sqrt( exp(mean(log(l), w)) :/ l)
	_editmissing(l, 1)
	return(l)
} // note: exp(mean(log(l), w)) = geometric mean

end
