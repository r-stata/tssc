*! Author(s) : Michael J Grayling
*! Date      : 31 Jan 2019
*! Version   : 0.9

/* Version history:

   31/01/19 v0.9 Initial version complete.

*/

/* To do:

   - Add option for plotting.

*/

program define sim_ma, rclass
version 15.0
syntax , [n(integer 68) tau(numlist) sd(real 1) RATio(real 1) ///
          ALPha(real 0.05) CORrection(string) REPlicates(integer 100000)]

preserve

///// Check input variables ////////////////////////////////////////////////////

local lentau:list sizeof tau
if ("`correction'" == "") {
  local correction "dunnett"
}
if (`n' < 1) {
  di "{error}The group size in the control arm (n) must be an integer greater "
  di "than or equal to 1."
  exit(198)
}
if (`sd' <= 0) {
  di "{error}The true value of the standard deviation of the responses (sd) "
  di "must be a real strictly greater than 0."
  exit(198)
}
if (`ratio' <= 0) {
  di "{error}The allocation ratio between the experimental and control arms "
  di "(ratio) must be a real strictly greater than 0."
  exit(198)
}
else if (mod(`ratio'*`n', 1) != 0) {
  di "{error}The product of the allocation ratio between the experimental and "
  di "control arms (ratio) and the stage-wise group size in the control arm (n)"
  di " must be an integer greater than or equal to 1."
  exit(198)
}
if (("`correction'" != "benjamini") & ("`correction'" != "bonferroni") & ///
      ("`correction'" != "dunnett") & ("`correction'" != "holm") & ///
	  ("`correction'" != "none") & ("`correction'" != "sidak") & ///
	  ("`correction'" != "step_down_dunnett")) {
  di "{error}The multiple comparison correction must be one of benjamini, "
  di "bonferroni, dunnett, holm, none, sidak, or step_down_dunnett."
  exit(198)
}
if ((`alpha' <= 0) | (`alpha' >= 1)) {
  di "{error}The desired familywise error-rate (alpha) must be a real strictly "
  di "between 0 and 1."
  exit(198)
}
if (`replicates' < 1) {
  di "{error}The number of replicate simulations to conduct (replicates) must "
  di "be an integer greater than or equal to 1."
  exit(198)
}

///// Perform main computations ////////////////////////////////////////////////

if (`lentau' > 0) {
  local matatau ""
  foreach l of local tau {
    if "`matatau'" == "" local matatau "`l'"
    else local matatau "`matatau',`l'"
  }
  mat tau = (`matatau')
}
else {
  mat tau = J(1, 3, 0)
}
mata: sim_ma_void(`n', `sd', `ratio', "`correction'", `alpha', `replicates')

///// Output ///////////////////////////////////////////////////////////////////

return scalar FDR  = opchar[1, 3]
return scalar P_H1 = opchar[1, 2]
return scalar P_HA = opchar[1, 1]

restore

end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void sim_ma_void(real scalar n, real scalar sd, real scalar ratio,
                 string correction, real scalar alpha, real scalar replicates) {
  tau   = st_matrix("tau")
  K     = length(tau)
  printf("{txt}{dup 57:{c -}}\n")
  printf("Single-stage {inp}%g{txt}-experimental treatment MA trial ", K)
  printf("simulation\n")
  printf("{dup 57:{c -}}\n")
  printf("The hypotheses to be tested will be:\n\n")
  if (K == 1) {
    printf("{txt}   H1: τ{inp}1{txt} = μ1 - μ0 ≤ 0.\n\n")
  }
  else if (K == 2) {
    printf("{txt}   Hk: τk = μk - μ0 ≤ 0, k = 1, {inp}2{txt}.\n\n")
  }
  else if (K == 3) {
    printf("{txt}   Hk: τk = μk - μ0 ≤ 0, k = 1, 2, {inp}3{txt}.\n\n")
  }
  else {
    printf("{txt}   Hk: τk = μk - μ0 ≤ 0, k = 1, ..., {inp}%g{txt}.\n\n", K)
  }
  if (correction == "none") {
    printf("{inp}No multiplicity correction will be applied{txt} in order to ")
	printf("control the familywise\nerror-rate or false discovery rate. Each ")
	printf("hypothesis will be tested at significance level\nα = {inp}%g{txt}.",
	       alpha)
    printf("\n\n")
  }
  else if (correction == "benjamini") {
    printf("{txt}The false discovery-rate will be controlled to level α = ")
	printf("{inp}%g{txt} using the\n{inp}Benjamini-Hochberg{txt} procedure.",
	       alpha)
    printf("\n\n")
  }
  else {
    printf("{txt}The familywise error-rate will be controlled under the global")
    printf(" null hypothesis,\nHG, given by:\n\n")
	if (K == 1) {
      printf("{txt}   HG: τ{inp}1{txt} = 0.\n\n")
    }
    else if (K == 2) {
      printf("{txt}   HG: τ1 = τ{inp}2{txt} = 0.\n\n")
    }
    else if (K == 3) {
      printf("{txt}   HG: τ1 = τ2 = τ{inp}3{txt} = 0.\n\n")
    }
    else {
      printf("{txt}   HG: τ1 = ... = τ{inp}%g{txt} = 0.\n\n", K)
    }
	printf("If P_HA() is the power function for rejecting any null hypothesis,")
	if (correction == "bonferroni") {
	  printf(" the\n{inp}Bonferroni{txt} correction ")
	}
	else if (correction == "dunnett") {
	  printf(" the\n{inp}Dunnett{txt} correction ")
	}
	else if (correction == "holm") {
	  printf(" the\n{inp}Bonferroni-Holm{txt} correction ")
	}
	else if (correction == "sidak") {
	  printf(" the\n{inp}Sidak{txt} correction ")
	}
	else if (correction == "step_down_dunnett") {
	  printf(" the\n{inp}step-down Dunnett{txt} correction ")
	}
    printf("will be used to ensure that:\n\n")
    printf("{txt}   P_HA(HG) ≤ α = {inp}%g{txt}.\n\n", alpha)
  }
  printf("The group size in the control arm will be: n = {inp}%g{txt}.\n\n", n)
  printf("The allocation ratio between the experimental arms and the shared ")
  printf("control arm,\nratio, will be: {inp}%g{txt}:1.\n\n", ratio)

  printf("{txt}The trial will be simulated under the scenario where:\n\n")
  if (K == 1) {
    printf("{txt} tau = tau_{inp}1{txt} = {inp}%g{txt}.\n\n", tau)
  }
  else if (K == 2) {
    printf("{txt} tau = (tau_1, tau_{inp}2{txt}) = {inp}(%g, %g){txt}.\n\n",
	       tau[1], tau[2])
  }
  else {
    printf("{txt} tau = (")
	for (k = 1; k <= K - 1; k++) {
	  printf("{txt}tau_%g, ", k)
	}
	printf("{txt}tau_{inp}%g{txt}) = {inp}(", K)
	for (k = 1; k <= K - 1; k++) {
	  printf("%g, ", tau[k])
	}
	printf("%g){txt}.\n\n", tau[K])
  }
  printf("Beginning the required simulations.\n\n")
  rho        = ratio/(ratio + 1)
  Lambda     = J(K, K, rho) + (1 - rho)*I(K)
  p          = p_O = .
  if ((correction == "benjamini") | (correction == "holm")) {
    p_O      = alpha:/(K::1)
  }
  else if (correction == "bonferroni") {
    p        = alpha/K
  }
  else if (correction == "dunnett") {
	p        = 1 - normal(invmvnormal_mata(1 - alpha, J(1, K, 0), Lambda,
	                                       "lower", 1000000, 0.0000001,
										   "pmvnormal", 12, 10000)[1])
  }
  else if (correction == "none") {
    p        = alpha
  }
  else if (correction == "sidak") {
    p        = 1 - (1 - alpha)^(1/K)
  }
  else if (correction == "step_down_dunnett") {
    rho      = ratio/(ratio + 1)
    p_O      = J(K, 1, 0)
	for (k = 1; k <= K; k++) {
	  p_O[k] =
	    1 - normal(invmvnormal_mata(1 - alpha, J(1, K - (k - 1), 0),
		                            J(K - (k - 1), K - (k - 1), rho) +
			  					      (1 - rho)*I(K - (k - 1)), "lower", 100000,
									0.000001, "pmvnormal", 12, 1000)[1])	
	}
  }
  opchar     = sim_ma_mata(n, tau', sd, ratio, correction, p, p_O, K,
                           replicates)'
  printf("Completed the required simulations.\n\n")
  printf("The estimated operating characteristics of the trial are:\n\n")
  printf("   r()  | Variable\n")
  printf("   {dup 4:{c -}}   {dup 8:{c -}}\n")
  printf("   P_HA | P_HA(tau) = {res}%g{txt},\n", round(opchar[1], .0001))
  printf("   P_H1 | P_H1(tau) = {res}%g{txt},\n", round(opchar[3], .0001))
  printf("   FDR  | FDR(tau)  = {res}%g{txt}.\n", round(opchar[2], .0001))
  st_matrix("opchar", opchar)
}

real colvector invmvnormal_mata(real scalar p, real vector mean,
                                real matrix Sigma, string tail,
								real scalar max_iter, real scalar tolerance,
								string integrator, real scalar shifts,
								real scalar samples) {		
					
  if ((p == 0) | (p == 1)) {
    return((. \ 0 \ 0 \ 0 \ 0))
  }
  else {
    if (rows(Sigma) == 1) {
      if (tail == "upper") {
        p          = 1 - p
      }
      else if (tail == "both") {
        p          = 0.5 + 0.5*p
      }
      return((invnormal(p) + mean \ 0 \ 0 \ 0 \ 0))
    }
    else {
	  if (tail == "both") {
	    a          = 10^-6
	  }
	  else {
	    a          = -10
	  }
	  b            = 10
	  fa           = invmvnormal_mata_int(a, p, mean, Sigma, tail, integrator,
	                                      shifts, samples)
	  if (fa == 0) {
	    return((a \ 0 \ 0 \ 0 \ 0))
	  }
	  fb           = invmvnormal_mata_int(b, p, mean, Sigma, tail, integrator,
	                                      shifts, samples)
	  if (fb == 0) {
	    return((b \ 0 \ 0 \ 0 \ 0))
	  }
	  if (tail == "both") {
	    while ((fa > 0) & (a >= 10^-20)) {
	      a        = a/2
	      fa       = invmvnormal_mata_int(a, p, mean, Sigma, tail, integrator,
	                                      shifts, samples)
	    }
	    while ((fb < 0) & (b <= 10^6)) {
	      b        = 2*b
	      fb       = invmvnormal_mata_int(b, p, mean, Sigma, tail, integrator,
	                                      shifts, samples)
	    }
	  }
	  else {
	    while ((((fa > 0) & (fb > 0)) | ((fa < 0) & (fb < 0))) & (a >= -10^6)) {
	      a        = 2*a
	      b        = 2*b
	      fa       = invmvnormal_mata_int(a, p, mean, Sigma, tail, integrator,
	                                      shifts, samples)
	      fb       = invmvnormal_mata_int(b, p, mean, Sigma, tail, integrator,
	                                      shifts, samples)
	    }
	  }
	  if (fa == 0) {
	    return((a \ 0 \ 0 \ 0 \ 0))
	  }
	  else if (fb == 0) {
	    return((b \ 0 \ 0 \ 0 \ 0))
	  }
	  else if (((fa < 0) & (fb > 0)) | ((fa > 0) & (fb < 0))) {
        half_tol   = 0.5*tolerance
		c          = b
        fc         = fb
        for (iter = 1; iter <= max_iter; iter++) {
          if (((fb > 0) & (fc > 0)) | ((fb < 0) & (fc < 0))) {
            c      = a
	        fc     = fa
	        d      = b - a
	        e      = d
	      }
	      if (abs(fc) < abs(fb)) {
	        a      = b
	        b      = c
	        c      = a
	        fa     = fb
	        fb     = fc
	        fc     = fa
	      }
	      tol1     = 6e-8*abs(b) + half_tol
	      xm       = 0.5*(c - b)
		  if ((abs(xm) <= tol1) | (fb == 0)) {
	        return((b \ abs(0.5*(b - a)) \ 0 \ fb \ iter))
	      }
	      if ((abs(e) >= tol1) & (abs(fa) > abs(fb))) {
	        s      = fb/fa
	        if (a == c) {
	          pi   = 2*xm*s
		      q    = 1 - s
	        }
	        else {
	          q    = fa/fc
		      r    = fb/fc
		      pi   = s*(2*xm*q*(q - r) - (b - a)*(r - 1))
              q    = (q - 1)*(r - 1)*(s - 1)
	        }
	        if (pi > 0) {
	          q    = -q
	        }
	        pi     = abs(pi)
	        if (2*pi < min((3*xm*q - abs(tol1*q), abs(e*q)))) {
	          e    = d
		      d    = pi/q
	        }
	        else {
	          e    = d = xm
	        }
	      }
	      else {
	        e      = d = xm
	      }
	      a        = b
	      fa       = fb
		  if (abs(d) > tol1) {
	        b      = b + d
	      }
	      else {
	        b      = b + tol1*sign(xm)
	      }
	      fb       = invmvnormal_mata_int(b, p, mean, Sigma, tail, integrator,
	                                      shifts, samples)
        }
		return((b \ abs(0.5*(b - a)) \ 1 \ fb \ iter))
	  }
	  else {
	    return((. \ . \ 2 \ . \ .))
	  }
    }
  }
}

real scalar invmvnormal_mata_int(real scalar q, real scalar p, real vector mean,
                                 real matrix Sigma, string tail,
								 string integrator, real scalar shifts,
								 real scalar samples) {
  k          = rows(Sigma)
  if (tail == "lower") {
    a        = J(1, k, .)
    b        = J(1, k, q)
  }
  else if (tail == "upper") {
    a        = J(1, k, q)
    b        = J(1, k, .)
  }
  else {
    a        = J(1, k, -q)
    b        = J(1, k, q)
  }
  if (integrator != "mvnormal") {
    return(pmvnormal_mata(a, b, mean, Sigma, shifts, samples, 3)[1] - p)
  }
  else {
    for (i = 1; i <= k; i++) {
	  if (a[i] == .) {
	    a[i] = -8e307
	  }
	  if (b[i] == .) {
	    b[i] = 8e307
	  }
	}
	return(mvnormalcv(a, b, mean, vech(Sigma)') - p)
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
    I                           = V = 0
    if (a[1] != .) {
      d                         = J(samples, 1, (normal(a[1]/C[1, 1]),
	                                             J(1, k - 1, 0)))
    }
	else {
	  d                         = J(samples, k, 0)
	}
    if (b[1] != .) {
      e                         = J(samples, 1, (normal(b[1]/C[1, 1]),
	                                             J(1, k - 1, 1)))
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
	        normal((a[l] :- rowsum(J(samples, 1, C[l, l_vec]):*y[, l_vec]))/
			                         C[l, l])
		  f[, l]                = (1 :- d[, l]):*f[, l - 1]
		}
        else if ((a[l] == .) & (b[l] != .)) {
          e[, l]                =
	        normal((b[l] :- rowsum(J(samples, 1, C[l, l_vec]):*y[, l_vec]))/
			                         C[l, l])
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

real colvector sim_ma_mata(real scalar n, real vector tau, real scalar sd,
                           real scalar ratio, string correction, real scalar p,
						   real vector p_O, real scalar K,
						   real scalar replicates) {
  sd_sqrt_n                          = sd*sqrt(n)
  rn                                 = ratio*n
  sd_sqrt_rn                         = sd*sqrt(rn)
  rn_tau                             = rn*tau
  denominator                        = sd*sqrt((ratio + 1)/rn)
  rej_any                            = 0
  rej_vec                            = J(K, replicates, 0)
  rej_corr                           = rej_incorr = J(1, replicates, 0)
  for (i = 1; i <= replicates; i++) {
	pvals                            =
	  1 :- normal(((rnormal(K, 1, 0, 1)*sd_sqrt_rn :+ rn_tau)/rn -
	                  J(K, 1, rnormal(1, 1, 0, sd_sqrt_n)/n))/denominator)
	if ((correction == "bonferroni") | (correction == "dunnett") |
	      (correction == "none") | (correction == "sidak")) {
      rej_any                        = rej_any + (min(pvals) < p)
	  rej_vec[, i]                   = (pvals :< p)
	}
	else if ((correction == "holm") | (correction == "step_down_dunnett")) {
	  order_pvals = order(pvals, 1)
      k                              = 1
	  check                          = 0
	  while ((k <= K) & (check == 0)) {
		if (pvals[order_pvals[k]] < p_O[k]) {
		  rej_vec[order_pvals[k], i] = rej_vec[order_pvals[k], i] + 1
		  k                          = k + 1
		}
		else {
		  check                      = 1
		}
      }
      rej_any                        = rej_any + sum(rej_vec[, i])
	}
	else if (correction == "benjamini") {
	  order_pvals                    = order(pvals, 1)
	  for (k = K; k >= 1; k--) {
        if (pvals[order_pvals[k]] < p_O[k]) {
	      rej_vec[1::k, i]           = J(k, 1, 1)
	      break
	    }
      }
	}
  }
  discoveries                        = colsum(rej_vec)
  false_discoveries                  = colsum(rej_vec:*J(1, replicates,
                                                         (tau :<= 0)))
  which_discoveries_0                = which_condition(discoveries, "e", 0)
  discoveries[which_discoveries_0]   = J(1, length(which_discoveries_0), 1)
  return((rej_any/replicates \ mean((false_discoveries:/discoveries)') \
          rowsum(rej_vec)/replicates))
}

function which_condition(real vector check, string type, real scalar value) {
  match       = .
  for (i = 1; i <= length(check); i++) {
    if (type == "ge") {
	  if (check[i] >= value) {
	    match = (match, i)
	  }
	}
	else if (type == "g") {
	  if (check[i] > value) {
	    match = (match, i)
	  }
	}
	else if (type == "le") {
	  if (check[i] <= value) {
	    match = (match, i)
	  }
	}
	else if (type == "l") {
	  if (check[i] < value) {
	    match = (match, i)
	  }
	}
	else if (type == "e") {
	  if (check[i] == value) {
	    match = (match, i)
	  }
	}
  }
  if (length(match) > 1) {
    match     = match[2::length(match)]
    if (rows(check) > 1) {
	  return(match')
	}
	else {
	  return(match)
	}
  }
  else {
    return(J(0, 0, .))
  }
}

end
