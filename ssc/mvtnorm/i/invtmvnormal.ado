*! Date    : 03 Jan 2019
*! Version : 1.1
*! Authors : Michael J Grayling & Adrian P Mander

/*
  30/10/17 v1.0 Basic version complete.
  03/01/19 v1.1 Minor changes for speed. Converted mean and sigma to be 
                optional with internal defaults.
*/

program define invtmvnormal, rclass
version 15.0
syntax , p(real) LOWERTruncation(numlist miss) UPPERTruncation(numlist miss) ///
         [MEan(numlist) Sigma(string) Tail(string) MAX_iter(integer 1000000) ///
		 TOLerance(real 0.000001) INTegrator(string) SHIfts(integer 12) ///
		 SAMples(integer 1000)]
		 
///// Check input variables ////////////////////////////////////////////////////

if ("`tail'" == "") {
  local tail "lower"
}
if ("`integrator'" == "") {
  local integrator "pmvnormal"
}
if ((`p' < 0) | (`p' > 1)) {
  di "{error}Probability (p) must be between 0 and 1."
} 
local lenlowert:list sizeof lowertruncation
local lenuppert:list sizeof uppertruncation
local lenmean:list   sizeof mean
if (`lenlowert' != `lenuppert') {
  di "{error}Vector of lower truncation limits (lowertruncation) and vector of upper truncation limits (uppertruncation) must be of equal length."
  exit(198)
}
if (`lenlowert' > 100) {
  di "{error}Only truncated multivariate normal distributions of dimension up to 100 are supported."
  exit(198)
}
forvalues i = 1/`lenlowert' {
  local lowerti:word `i' of `lowertruncation'
  local upperti:word `i' of `uppertruncation'
  if ((`lowerti' != .) & (`upperti' != .)) {
    if (`lowerti' >= `upperti') {
      di "{error}Each lower truncation limit (in lowertruncation) must be strictly less than the corresponding upper truncation limit (in uppertruncation)."
      exit(198)
    }
  }
}
if ((`lenmean' != 0) & (`lenlowert' != `lenmean')) {
  di "{error}Mean vector (mean) and vector of lower truncation limits (lowertruncation) must be of equal length."
  exit(198)
}
if ("`sigma'" != "") {
  if (colsof(`sigma') != rowsof(`sigma')) {
    di "{error}Covariance matrix Sigma (sigma) must be square."
    exit(198)
  }
  if (`lenlowert' != colsof(`sigma')) {
    di "{error}Vector of lower truncation limits (lowertruncation) must be the same length as the dimension of covariance matrix Sigma (sigma)."
    exit(198)
  }
  cap mat chol = cholesky(`sigma')
  if (_rc > 0) {
    di "{error}Covariance matrix Sigma (sigma) must be symmetric positive-definite."
    exit(198)
  }
  mat sigma    = (`sigma')
}
else {
  mat sigma    = I(`lenlowert')
}
if (("`tail'" != "lower") & ("`tail'" != "upper") & ("`tail'" != "both")) {
  di "{error}tail must be set to one of lower, upper, or both."
  exit(198)
}
if (`shifts' < 1) {
  di "{error}Number of shifts of the Quasi-Monte-Carlo integration algorithm to use (shifts) must be a strictly positive integer."
  exit(198)
}
if (`samples' < 1) {
  di "{error}Number of samples to use in each shift of the Quasi-Monte-Carlo integration algorithm (samples) must be a strictly positive integer."
  exit(198)
}
if (`max_iter' < 1) {
  di "{error}Number of allowed iterations in the quantile (root-)finding algorithm (max_iter) must be a strictly positive integer."
  exit(198)
}
if (`tolerance' < 0) {
  di "{error}The tolerance in the quantile (root-)finding algorithm (tolerance) must be strictly positive."
  exit(198)
}
if (("`integrator'" != "mvnormal") & ("`integrator'" != "pmvnormal")) {
  di "{error}Choice of integrator (integrator) must be mvnormal or pmvnormal."
  exit(198)
}

///// Perform main computations ////////////////////////////////////////////////

local matalowert ""
foreach l of local lowertruncation {
  if "`matalowert'" == "" local matalowert "`l'"
  else local matalowert "`matalowert',`l'"
}
mat lowert = (`matalowert')
local matauppert ""
foreach l of local uppertruncation {
  if "`matauppert'" == "" local matauppert "`l'"
  else local matauppert "`matauppert',`l'"
}
mat uppert = (`matauppert')
if (`lenmean' != 0) {
  local matamean ""
  foreach l of local mean {
    if "`matamean'" == "" local matamean "`l'"
    else local matamean "`matamean',`l'"
  }
  mat mean = (`matamean')
}
else {
  mat mean = J(1, `lenlowert', 0)
}
mata: invtmvnormal_void(`p', "`tail'", `max_iter', `tolerance', "`integrator'", `shifts', `samples')

///// Output ///////////////////////////////////////////////////////////////////

mat returns              = returns
return scalar iterations = returns[5, 1]
return scalar fquantile  = returns[4, 1]
return scalar flag       = returns[3, 1]
return scalar error      = returns[2, 1]
return scalar quantile   = returns[1, 1]
di "{txt}quantile   = {res}" returns[1, 1] "{txt}"
di "{txt}error      = {res}" returns[2, 1] "{txt}"
di "{txt}flag       = {res}" returns[3, 1] "{txt}"
di "{txt}fquantile  = {res}" returns[4, 1] "{txt}"
di "{txt}iterations = {res}" returns[5, 1] "{txt}"
end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void invtmvnormal_void(p, tail, max_iter, tolerance, integrator, shifts, samples) {
  lowert  = st_matrix("lowert")
  uppert  = st_matrix("uppert")
  mean    = st_matrix("mean")
  Sigma   = st_matrix("sigma")
  st_matrix("returns", invtmvnormal_mata(p, lowert, uppert, mean, Sigma, tail,
                                         max_iter, tolerance, integrator,
										 shifts, samples)) 
}	

real colvector invtmvnormal_mata(real scalar p, real vector lowert,
                                 real vector uppert, real vector mean,
                                 real matrix Sigma, string tail,
								 real scalar max_iter, real scalar tolerance,
								 string integrator, real scalar shifts,
								 real scalar samples) {		
					
  if (p == 0) {
    return((min(lowert) \ 0 \ 0 \ 0 \ 0))
  }
  else if (p == 1) {
    return((max(uppert) \ 0 \ 0 \ 0 \ 0))
  }
  else {
    k               = rows(Sigma)
	if (integrator != "mvnormal") {
	  denominator   = pmvnormal_mata(lowert, uppert, mean, Sigma, shifts,
	                                 samples, 3)[1]
	}
	else {
	  for (i = 1; i <= k; i++) {
	    if (lowert[i] == .) {
	      lowert[i] = -8e307
	    }
	    if (uppert[i] == .) {
	      uppert[i] = 8e307
	    }
	  }
	  denominator   = mvnormalcv(a, b, mean, vech(Sigma)')
	}
	a               = min(lowert)
	if (a == .) {
	  a             = -8e307
	}
	b               = max(uppert)
	if (b == .) {
	  b             = 8e307
	}
	fa              = invtmvnormal_mata_int(a, p, lowert, uppert, mean, Sigma,
	                                        tail, integrator, shifts, samples,
											denominator)
    fb              = invtmvnormal_mata_int(b, p, lowert, uppert, mean, Sigma,
	                                        tail, integrator, shifts, samples,
											denominator)
	if (((fa < 0) & (fb > 0)) | ((fa > 0) & (fb < 0))) {
      half_tol    = 0.5*tolerance
      c           = b
      fc          = fb
      for (iter = 1; iter <= max_iter; iter++) {
        if (((fb > 0) & (fc > 0)) | ((fb < 0) & (fc < 0))) {
          c       = a
	      fc      = fa
	      d       = b - a
	      e       = d
	    }
	    if (abs(fc) < abs(fb)) {
	      a       = b
	      b       = c
	      c       = a
	      fa      = fb
	      fb      = fc
	      fc      = fa
	    }
	    tol1      = 6e-8*abs(b) + half_tol
	    xm        = 0.5*(c - b)
		if ((abs(xm) <= tol1) | (fb == 0)) {
	      return((b \ abs(0.5*(b - a)) \ 0 \ fb \ iter))
	    }
	    if ((abs(e) >= tol1) & (abs(fa) > abs(fb))) {
	      s       = fb/fa
	      if (a == c) {
	        pi    = 2*xm*s
		    q     = 1 - s
	      }
	      else {
	        q     = fa/fc
		    r     = fb/fc
		    pi    = s*(2*xm*q*(q - r) - (b - a)*(r - 1))
            q     = (q - 1)*(r - 1)*(s - 1)
	      }
	      if (pi > 0) {
	        q     = -q
	      }
	      pi      = abs(pi)
	      if (2*pi < min((3*xm*q - abs(tol1*q), abs(e*q)))) {
	        e     = d
		    d     = pi/q
	      }
	      else {
	        e     = d = xm
	      }
	    }
	    else {
	      e       = d = xm
	    }
	    a         = b
	    fa        = fb
		if (abs(d) > tol1) {
	      b       = b + d
	    }
	    else {
	      b       = b + tol1*sign(xm)
	    }
	    fb        = invtmvnormal_mata_int(b, p, lowert, uppert, mean, Sigma,
		                                  tail, integrator, shifts, samples,
										  denominator)
      }
      return((b \ abs(0.5*(b - a)) \ 1 \ fb \ iter))
	}
	else {
	  return((. \ . \ 2 \ . \ .))
	}
  }
}

real scalar invtmvnormal_mata_int(real scalar q, real scalar p,
                                  real vector lowert, real vector uppert,
								  real vector mean, real matrix Sigma,
								  string tail, string integrator,
								  real scalar shifts, real scalar samples, 
								  real scalar denominator) {
  
  k             = rows(Sigma)
  if (tail == "lower") {
    a           = J(1, k, .)
    b           = J(1, k, q)
  }
  else if (tail == "upper") {
    a           = J(1, k, q)
    b           = J(1, k, .)
  }
  else {
    a           = J(1, k, -q)
    b           = J(1, k, q)
  }
  aact          = J(1, k, 0)
  bact          = J(1, k, 0)
  for (i = 1; i <= k; i++) {
    aact[i]     = max((a[i], lowert[i]))
	bact[i]     = min((b[i], uppert[i]))
  }
  if (integrator != "mvnormal") {
    return(pmvnormal_mata(aact, bact, mean, Sigma, shifts, samples,
	                      3)[1]/denominator - p)
  }
  else {
    for (i = 1; i <= k; i++) {
	  if (aact[i] == .) {
	    aact[i] = -8e307
	  }
	  if (b[i] == .) {
	    bact[i] = 8e307
	  }
	}
	return(mvnormalcv(aact, bact, mean, vech(Sigma)')/denominator - p)
  }
}

real colvector pmvnormal_mata(real vector lower, real vector upper, 
                              real vector mean, real matrix Sigma,
							  real scalar shifts, real scalar samples,
							  real scalar alpha) {
  k                             = rows(Sigma)
  if (k == 1) {
    if ((lower == .) & (upper == .)) {
	  I                         = 1
	}
	else if ((lower != .) & (upper == .)) {
	  I                         = 1 - normal((lower - mean)/sqrt(Sigma))
	}
	else if ((lower == .) & (upper != .)) {
	  I                         = normal((upper - mean)/sqrt(Sigma))
	}
	else {
	  sqrt_Sigma                = sqrt(Sigma)
      I                         = normal((upper - mean)/sqrt_Sigma) -
	                                normal((lower - mean)/sqrt_Sigma)
	}
	E                           = 0
  }
  else if (k == 2) {
    if (lower[1] == .) lower[1] = -8e307
	if (lower[2] == .) lower[2] = -8e307
	if (upper[1] == .) upper[1] = 8e307
	if (upper[2] == .) upper[2] = 8e307
	sqrt_Sigma                  = sqrt((Sigma[1, 1], Sigma[2, 2]))
	a                           = (lower - mean):/(sqrt_Sigma[1], sqrt_Sigma[2])
	b                           = (upper - mean):/(sqrt_Sigma[1], sqrt_Sigma[2])
	r                           = Sigma[1, 2]/(sqrt_Sigma[1]*sqrt_Sigma[2])
	I                           =
	  binormal(b[1], b[2], r) + binormal(a[1], a[2], r) -
	    binormal(b[1], a[2], r) - binormal(a[1], b[2], r)
	E                           = 0
  }
  else {
    a                           = lower - mean
    b                           = upper - mean
	C         = J(k, k, 0)
    zero_k_min_2                = J(1, k - 2, 0)
	zero_k_min_1                = (zero_k_min_2, 0)
    y                           = zero_k_min_1
    atilde                      = (a[1], zero_k_min_2)
    btilde                      = (b[1], zero_k_min_2)
	sqrt_Sigma11                = sqrt(Sigma[1, 1])
    args                        = J(1, k, 1)
	for (j = 1; j <= k; j++) {
      if ((a[j] != .) & (b[j] != .)) {
        args[j]                 = normal(b[j]/sqrt_Sigma11) -
			                        normal(a[j]/sqrt_Sigma11) 
      }
      else if ((a[j] == .) & (b[j] != .)) {
        args[j]                 = normal(b[j]/sqrt_Sigma11)
      }
      else if ((b[j] == .) & (a[j] != .)) {
        args[j]                 = 1 - normal(a[j]/sqrt_Sigma11)
      }
    }
	ii                          = ww = .
    minindex(args, 1, ii, ww)
    if (ii[1] != 1) {
	  tempa                     = a
      tempb                     = b
      tempa[1]                  = a[ii[1]]
      tempa[ii[1]]              = a[1]
      a                         = tempa
      tempb[1]                  = b[ii[1]]
      tempb[ii[1]]              = b[1]
      b                         = tempb
      tempSigma                 = Sigma
      tempSigma[1, ]            = Sigma[ii[1], ]
      tempSigma[ii[1], ]        = Sigma[1, ]
      Sigma                     = tempSigma
      Sigma[, 1]                = tempSigma[, ii[1]]
      Sigma[, ii[1]]            = tempSigma[, 1]
	  C[1, 1]                   = sqrt(Sigma[1, 1])
	  C[2::k, 1]                = Sigma[2::k, 1]/C[1, 1]
	}
	else {
	  C[, 1]                     = (sqrt_Sigma11 \ Sigma[2::k, 1]/sqrt_Sigma11)
	}
    if (atilde[1] != btilde[1]) {
	  y[1]                      = (normalden(atilde[1]) - normalden(btilde[1]))/
                                    (normal(btilde[1]) - normal(atilde[1]))
	}
	for (i = 2; i <= k - 1; i++) {
      args                      = J(1, k - i + 1, 1)
	  i_vec                     = 1::(i - 1)
      for (j = 1; j <= k - i + 1; j++) {
        s                       = j + i - 1
		if ((a[s] != .) & (b[s] != .)) {
		    Cy                  = sum(C[s, i_vec]:*y[i_vec])
		    denom               = sqrt(Sigma[s, s] - sum(C[s, i_vec]:^2))
			args[j]             = normal((b[s] - Cy)/denom) -
                                    normal((a[s] - Cy)/denom)
          }
          else if ((a[s] == .) & (b[s] != .)) {
	        args[j]             =
			  normal((b[s] - sum(C[s, i_vec]:*y[i_vec]))/
			           sqrt(Sigma[s, s] - sum(C[s, i_vec]:^2))) 
          }
          else if ((b[s] == .) & (a[s] != .)) {
  	        args[j]             =
			  1 - normal((a[s] - sum(C[s, i_vec]:*y[i_vec]))/
			               sqrt(Sigma[s, s] - sum(C[s, i_vec]:^2)))
          }
      }
	  ii                        = ww = .
      minindex(args, 1, ii, ww)
      m                         = i - 1 + ii[1]
	  if (i != m) {
	    tempa                   = a
        tempb                   = b
        tempa[i]                = a[m]
        tempa[m]                = a[i]
        a                       = tempa
        tempb[i]                = b[m]
        tempb[m]                = b[i]
        b                       = tempb
        tempSigma               = Sigma
        tempSigma[i, ]          = Sigma[m, ]
        tempSigma[m, ]          = Sigma[i, ]
        Sigma                   = tempSigma
        Sigma[, i]              = tempSigma[, m]
        Sigma[, m]              = tempSigma[, i]
		tempC                   = C
        tempC[i, ]              = C[m, ]
        tempC[m, ]              = C[i, ]
        C                       = tempC
        C[, i]                  = tempC[, m]
        C[, m]                  = tempC[, i]
	  }
      C[i, i]                   = sqrt(Sigma[i, i] - sum(C[i, i_vec]:^2))
      i_vec2                    = (i + 1)::k
	  C[i_vec2, i]              =
	    (Sigma[i_vec2, i] - rowsum(J(k - i, 1, C[i, i_vec]):*C[i_vec2, i_vec]))/
		  C[i, i]
	  Cy                        = sum(C[i, i_vec]:*y[i_vec])
      atilde[i]                 = (a[i] - Cy)/C[i, i]
      btilde[i]                 = (b[i] - Cy)/C[i, i]
	  if (atilde[i] != btilde[i]) {
	    y[i]                    = (normalden(atilde[i]) - normalden(btilde[i]))/
                                    (normal(btilde[i]) - normal(atilde[i]))
	  }
    }
    C[k, k] = sqrt(Sigma[k, k] - sum(C[k, 1::(k - 1)]:^2))
	C
    I                           = V = 0
    if (a[1] != .) {
      d                         = J(samples, 1, (normal(a[1]/C[1, 1]), J(1, k - 1, 0)))
    }
	else {
	  d                         = J(samples, k, 0)
	}
    if (b[1] != .) {
      e                         = J(samples, 1, (normal(b[1]/C[1, 1]), J(1, k - 1, 1)))
    }
	else {
	  e                         = J(samples, 1, J(1, k, 1))
	}
    f                           = (e[, 1] - d[, 1], J(samples, k - 1, 0))
	y = J(samples, k - 1, 0)
	Delta                       = runiform(shifts, k - 1)
	samples_sqrt_primes         =
	  (1::samples)*sqrt((2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47,
	                     53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107,
						 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167,
						 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229,
						 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283,
						 293, 307, 311, 313, 317, 331, 337, 347, 349, 353, 359,
						 367, 373, 379, 383, 389, 397, 401, 409, 419, 421, 431,
						 433, 439, 443, 449, 457, 461, 463, 467, 479, 487, 491,
						 499, 503, 509, 521, 523, 541)[1::(k - 1)])
	Ii                          = J(1, shifts, 0)
	"h"
	for (i = 1; i <= shifts; i++) {
	  for (l = 2; l <= k; l++) {
		l_vec                 = 1::(l - 1)
		y[, l - 1]            =
		  invnormal(d[, l - 1] + abs(2*mod(samples_sqrt_primes[, l - 1] :+
       				                     Delta[i, l - 1], 1) :- 1):*
								   (e[, l - 1] - d[, l - 1]))
		if ((a[l] != .) & (b[l] != .)) {
		  Cy                  = rowsum(J(samples, 1, C[l, l_vec]):*y[, l_vec])
		  d[, l]                = normal((a[l] :- Cy)/C[l, l])
	      e[, l]                = normal((b[l] :- Cy)/C[l, l])
		  f[, l]                = (e[, l] :- d[, l]):*f[, l - 1]
		}
		else if ((a[l] != .) & (b[l] == .)) {
          d[, l]                =
	        normal((a[l] :- rowsum(J(samples, 1, C[l, l_vec]):*y[, l_vec]))/C[l, l])
		  f[, l]                = (1 :- d[, l]):*f[, l - 1]
		}
        else if ((a[l] == .) & (b[l] != .)) {
          e[, l]                =
	        normal((b[l] :- rowsum(J(samples, 1, C[l, l_vec]):*y[, l_vec]))/C[l, l])
		  f[, l]                = e[, l]:*f[, l - 1]
        }
		else {
		  f[, l]                = f[, l - 1]
		}
      }
	  for (j = 1; j <= samples; j++) {
	    Ii[i]                   = Ii[i] + (f[j, k] - Ii[i])/j
	  }
	  del                       = (Ii[i] - I)/i
	  I                         = I + del
	  V                         = (i - 2)*V/i + del^2
      E                         = alpha*sqrt(V)
	}
  }
  return((I \ E))
}

end
