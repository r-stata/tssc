*! Date    : 03 Jan 2019
*! Version : 1.7
*! Authors : Michael J Grayling & Adrian P Mander

/*
  16/04/15 v1.0 Basic version complete.
  01/06/15 v1.1 Extended to use variable re-ordering.
  16/09/15 v1.3 Changed to use binormal() for 2-dimensional case.
  20/09/15 v1.4 Removed dependency on integrate() being pre-installed and
                tailored integration to our particular requirements.
  21/09/15 v1.5 Removed all dependency on numerical integration and made small
                changes for improved efficiency.      
  08/09/17 v1.6 Minor changes for speed. Name change to compensate for new Stata
                command.
  03/01/19 v1.7 Additional minor changes for speed - including vectorising the
                'shifts' loop (i.e., to remove the 'samples' loop). Converted
				mean and sigma to be optional with internal defaults.
*/

program define pmvnormal, rclass
version 15.0
syntax , LOWer(numlist miss) UPPer(numlist miss) [MEan(numlist) ///
         Sigma(string) SHIfts(integer 12) SAMples(integer 1000) ALPha(real 3)]

///// Check input variables ////////////////////////////////////////////////////

local lenlower:list sizeof lower
local lenupper:list sizeof upper
local lenmean:list  sizeof mean
if (`lenlower' > 100) {
  di "{error}Only multivariate normal distributions of dimension up to 100 are supported."
  exit(198)
}
if (`lenlower' != `lenupper') {
  di "{error}Vector of lower limits (lower) and vector of upper limits (upper) must be of equal length."
  exit(198)
}
forvalues i = 1/`lenlower' {
  local loweri:word `i' of `lower'
  local upperi:word `i' of `upper'
  if ((`loweri' != .) & (`upperi' != .)) {
    if (`loweri' >= `upperi') {
      di "{error}Each lower integration limit (in lower) must be strictly less than the corresponding upper limit (in upper)."
      exit(198)
    }
  }
}
if ((`lenmean' != 0) & (`lenlower' != `lenmean')) {
  di "{error}Vector of lower limits (lower) and mean vector (mean) must be of equal length."
  exit(198)
}
if ("`sigma'" != "") {
  if (colsof(`sigma') != rowsof(`sigma')) {
    di "{error}Covariance matrix Sigma (sigma) must be square."
    exit(198)
  }
  if (`lenlower' != colsof(`sigma')) {
    di "{error}Vector of lower limits (lower) must be the same length as the dimension of covariance matrix Sigma (sigma)."
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
  mat sigma    = I(`lenlower')
}
if (`shifts' < 1) {
  di "{error}Number of shifts of the Quasi-Monte-Carlo integration algorithm to use (shifts) must be a strictly positive integer."
  exit(198)
}
if (`samples' < 1) {
  di "{error}Number of samples to use in each shift of the Quasi-Monte-Carlo integration algorithm (samples) must be a strictly positive integer."
  exit(198)
}
if (`alpha' <= 0) {
  di "{error}Chosen Monte-Carlo confidence factor (alpha) must be strictly positive."
  exit(198)
}

///// Perform main computations ////////////////////////////////////////////////

local matalower ""
foreach l of local lower {
  if "`matalower'" == "" local matalower "`l'"
  else local matalower "`matalower',`l'"
}
mat lower      = (`matalower')
local mataupper ""
foreach l of local upper {
  if "`mataupper'" == "" local mataupper "`l'"
  else local mataupper "`mataupper',`l'"
}
mat upper      = (`mataupper')
if (`lenmean' != 0) {
  local matamean ""
  foreach l of local mean {
    if "`matamean'" == "" local matamean "`l'"
    else local matamean "`matamean',`l'"
  }
  mat mean     = (`matamean')
}
else {
  mat mean     = J(1, `lenlower', 0)
}
mata: pmvnormal_void(`shifts', `samples', `alpha')

///// Output ///////////////////////////////////////////////////////////////////

mat returns            = returns
return scalar error    = returns[2, 1]
return scalar integral = returns[1, 1]
di "{txt}integral = {res}" returns[1, 1] "{txt}"
di "{txt}error    = {res}" returns[2, 1] "{txt}"
end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void pmvnormal_void(shifts, samples, alpha) {
  lower   = st_matrix("lower")
  upper   = st_matrix("upper")
  mean    = st_matrix("mean")
  Sigma   = st_matrix("sigma")
  st_matrix("returns", pmvnormal_mata(lower, upper, mean, Sigma, shifts,
                                      samples, alpha))
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
