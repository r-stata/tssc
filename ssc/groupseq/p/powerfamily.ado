*! Date    : 24 March 2017
*! Version : 1.0

/*
 24/03/17 v1.0 Initial version complete
*/

program define powerFamily, rclass
version 11.0
syntax , [l(integer 3) Delta(real 0.2) Alpha(real 0.05) Beta(real 0.2) ///
          Sigma(numlist) Ratio(real 1) OMega(real 0.25) PERFormance *]

local xopt `"`options'"'

preserve

// Perform checks on input variables
if (`l' < 2) {
  di "{error} L must be a single integer greater than or equal to 2."
  exit(198)
}
if (`delta' <= 0) {
  di "{error} delta must be a single number greater than 0."
  exit(198)
}
if ((`alpha' <= 0) | (`alpha' >= 1)) {
  di "{error} alpha must be a single number strictly between 0 and 1."
  exit(198)
}
if ((`beta' <= 0) | (`beta' >= 1)) {
  di "{error} beta must be a single number strictly between 0 and 1."
  exit(198)
}
local lensigma:list sizeof sigma
if ((`lensigma' ~= 1) & (`lensigma' ~= 2)) {
  di "{error} sigma must be a numlist of length 1 or 2, containing only finite numbers strictly greater than 0."
  exit(198)
}
forvalues i = 1/`lensigma' {
  local sigmai:word `i' of `sigma'
  if (`sigmai' <= 0) {
    di "{error} sigma must be a numlist of length 1 or 2, containing only finite numbers strictly greater than 0."
    exit(198)
  }
}
if (`ratio' <= 0) {
  di "{error} ratio must be a single finite number greater than 0."
  exit(198)
}
if (`omega' > 0.5) {
  di "{error} omega must be less than 0.5."
  exit(198)
}

// Set up matrices to pass to mata
local matasigma ""
foreach i of local sigma{
  if "`matasigma'" == "" local matasigma "`i'"
  else local matasigma "`matasigma',`i'"
}
mat sigma = (`matasigma')

// Compute the design in mata and return the results
mata: findPowerFamilyDesign(`l', `delta', `alpha', `beta', `ratio', `omega', "`performance'", `"`xopt'"')
return mat e = e
return mat f = f
return mat n = n
return mat I = I
return mat Lambda = Lambda
return mat performance = performance

restore

end

// Start of mata
mata:

void findPowerFamilyDesign(L, delta, alpha, beta, ratio, Omega, performance, xopt)
{
  printf("\n{txt}{res}%g{txt}-stage Group Sequential Trial Design\n", L)
  printf("{dup 37:{c -}}\n")
  printf("The hypotheses to be tested are as follows:\n\n")
  printf("{txt}  H0: tau <= 0")
  printf("{txt}  H1: tau > 0,\n\n")
  printf("{txt}with the following error constraints:\n\n")
  printf("{txt}  P(Reject H0 | tau = 0)  = {res}%g,\n", alpha)
  printf("{txt}  P(Reject H0 | tau = {res}%g{txt}) = 1 - {res}%g{txt}.\n\n", delta, beta)
  if (performance ~= "") {
    printf("{txt}   Power family boundaries selected with Omega = {res}%g{txt}.........................\n", Omega)
  }
  else {
    printf("{txt}   Power family boundaries selected with Omega = {res}%g{txt}...\n", Omega)
  }
  // Transfer across required variables from stata
  sigma   = st_matrix("sigma")
  sigma   = sigma'
  if (length(sigma) == 1) {
    sigma = J(2, 1, sigma)
  }
  if (performance ~= "") {
    printf("...now determining design....................................................\n")
    printf("...output from optimize() to follow..........................................\n")
  }
  else {
    printf("...now determining design..............................\n")
    printf("...output from optimize() to follow....................\n")
  }
  n      = ((invnormal(1 - alpha)*sigma[1]*sqrt(1 + 1/ratio) +
               invnormal(1 - beta)*sqrt(sigma[1]^2 + 
                                          sigma[2]^2/ratio))/delta)^2
  Lambda   = covariance(L, 1::L)
  // Determine exact Ce and Cf to control type-I error rates
  arguments = (L \ alpha \ Omega \ vech(Lambda))
  Csearch   = optimize_init()
  optimize_init_evaluator(Csearch, &powerFamilyEF())
  optimize_init_which(Csearch, "min")
  optimize_init_params(Csearch, J(1, 2, delta*sqrt(n/(sigma[1]^2 + sigma[2]^2/ratio))/2))
  optimize_init_argument(Csearch, 1, L)
  optimize_init_argument(Csearch, 2, delta)
  optimize_init_argument(Csearch, 3, alpha)
  optimize_init_argument(Csearch, 4, beta)
  optimize_init_argument(Csearch, 5, Omega)
  optimize_init_argument(Csearch, 6, Lambda)
  optimize_init_nmsimplexdeltas(Csearch, (1, 1))
  optimize_init_technique(Csearch, "nm")
  C        = optimize(Csearch)
  Cf       = C[1]
  Ce       = C[2]
  I1       = (((Cf + Ce)/delta)^2)/L
  // n0_exact is the exact required sample size for group 1 in stage 1 of our
  // sequential design
  n        = I1*(sigma[1]^2 + sigma[2]^2/ratio)
  I        = information(n, L, sigma, ratio, (1::L)/L)
  n_vec    = (n + n*ratio)*(1::L)
  inffrac     = (1::L)/L
  e           = Ce*inffrac:^(Omega - 0.5)
  f           = delta*sqrt(I) - Cf*inffrac:^(Omega - 0.5)
  perf_H0     = perfEF(0, L, e, f, I, n_vec, Lambda)
  perf_H1     = perfEF(delta, L, e, f, I, n_vec, Lambda)
  arguments   = (L \ f \ e \ I \ n_vec \ vech(Lambda))
  maxEN       = brent_min(&maximumENEF(), 0.5*delta, 0, delta, "max", 1000, 1e-4, arguments)[2]
  perf        = (perf_H0 \ perf_H1 \ maxEN \ n_vec[L])
  // Plot power and expected sample size curves
  if (performance ~= "") {
    printf("...design determined. Now determining performance of the design across tau...\n")
    pts      = 101
    tau      = J(pts, 1, 0)
    for (i = 1; i <= pts; i++){
      tau[i] = -3*delta + ((3*delta - (-3*delta))/pts)*(i - 1)
    }
    P_curve  = J(pts, 1, 0)
    EN_curve = J(pts, 1, 0)
    for (i = 1; i <= pts; i++) {
      perf_tau    = perfEF(tau[i], L, e, f, I, n_vec, Lambda)
      P_curve[i]  = perf_tau[1]
      EN_curve[i] = perf_tau[2]
    }
    st_matrix("data", (P_curve, EN_curve, tau))
    stata("qui svmat data")
    stata(`"twoway (line data1 data3, yaxis(1))(line data2 data3, yaxis(2)), xtitle({&tau}) ytitle(P(Reject H{subscript:0}|{&tau})) ytitle(E(N|{&tau}),axis(2)) legend(lab(1 "P(Reject H{subscript:0}|{&tau})") lab(2 "E(N|{&tau})")) "'+ xopt)
  }
  // Return results to Stata
  if (performance ~= "") {
    printf("{txt}...returning the results.....................................................\n")
  }
  else {
    printf("...design determined. Returning the results............\n")
  }
  printf("...Exact required group size n determined to be:\n\n  {res}%g{txt}.\n\n", round(n, .1))
  printf("...Efficacy boundaries e determined to be:\n\n")
  for (l = 1; l <= L; l++) {
    if (l == 1) {
      printf("  {res}(%g,", round(e[l], .01))
    }
    else if ((l > 1) & (l < L)) {
      printf("%g,", round(e[l], .01))
    }
    else {
      printf("%g).{txt}\n\n", round(e[l], .01))
    }
  }
  printf("...Futility boundaries f determined to be:\n\n")
  for (l = 1; l <= L; l++) {
    if (l == 1) {
      printf("  {res}(%g,", round(f[l], .01))
    }
    else if ((l > 1) & (l < L)) {
      printf("%g,", round(f[l], .01))
    }
    else {
      printf("%g).{txt}\n\n", round(f[l], .01))
    }
  }
  printf("...Operating characteristics of the design are:\n\n")
  printf("{txt}  P(Reject H0 | tau = 0)  = {res}%g{txt},\n", round(perf[1], .0001))
  printf("{txt}  P(Reject H0 | tau = {res}%g{txt}) = {res}%g{txt}{txt},\n", delta, round(perf[3], .0001))
  printf("{txt}  E(N | tau = 0)          = {res}%g{txt},\n", round(perf[2], .1))
  printf("{txt}  E(N | tau = {res}%g{txt})         = {res}%g{txt},\n", delta, round(perf[4], .1))
  printf("{txt}  max_tau E(N | tau)      = {res}%g{txt},\n", round(perf[5], .1))
  printf("{txt}  max N                   = {res}%g{txt}.", round(perf[6], .1))
  st_matrix("e", e)
  st_matrix("f", f)
  st_matrix("n", n)
  st_matrix("I", I)
  st_matrix("Lambda", Lambda)
  st_matrix("performance", perf)
}

// Function to return covariance matrix of test statistics
real matrix covariance(real scalar L, real colvector I)
{
  Sigma = J(L, L, 1)
  for (l1 = 2; l1 <= L; l1++) {
    for (l2 = 1; l2 <= l1 - 1; l2++) {
	  Sigma[l1, l2] = sqrt(I[l2]/I[l1])
	  Sigma[l2, l1] = Sigma[l1, l2]
	}
  }
  return(Sigma)
}

// Function to return information level at each stage
real colvector information(real scalar n0, real scalar L, real colvector sigma, real scalar ratio, real colvector timing)
{
  return(timing*(sigma[1]^2/(n0*L) + sigma[2]^2/(ratio*n0*L))^-1)
}

// Function to return operating characteristics of a particular scenario
real colvector perfEF(real scalar theta, real scalar L, real vector e, real vector f, real vector I, real vector n_vec, real matrix Sigma)
{
  PE = J(L, 1, 0)
  PF = J(L, 1, 0)
  for (l = 1; l <= L; l++) {
    if (l == 1) {
	  PF[l] = mvnormal_mata(., f[l], theta*sqrt(I[l]), Sigma[l, l], 12, 1000, 3)[1]
	  PE[l] = mvnormal_mata(e[l], ., theta*sqrt(I[l]), Sigma[l, l], 12, 1000, 3)[1]
	}
	else {
	  PF[l] = mvnormal_mata((f[1::(l - 1)] \ .), (e[1::(l - 1)] \ f[l]), theta*sqrt(I[1::l]), Sigma[1::l, 1::l], 12, 1000, 3)[1]
	  PE[l] = mvnormal_mata((f[1::(l - 1)] \ e[l]), (e[1::(l - 1)] \ .), theta*sqrt(I[1::l]), Sigma[1::l, 1::l], 12, 1000, 3)[1]
	}
  }
  PR = sum(PE)
  EN = sum(n_vec:*(PE :+ PF))
  return((PR \ EN))
}

// Function to optimize over in order to find maximum expected sample size
real scalar maximumENEF(real scalar theta, real colvector arguments)
{
  L        = arguments[1]
  f        = arguments[2::(L + 1)]
  e        = arguments[(L + 2)::(2*L + 1)]
  I        = arguments[(2*L + 2)::(3*L + 1)]
  n_vec    = arguments[(3*L + 2)::(4*L + 1)]
  Sigma    = invvech(arguments[(4*L + 2)::(4*L + 1 + 0.5*L*(L + 1))])
  EN_theta = perfEF(theta, L, e, f, I, n_vec, Sigma)[2]
  return(EN_theta)
}

function powerFamilyEF(todo, C, L, delta, alpha, beta, Omega, Sigma, Score, g, H)
{
  inffrac = (1::L)/L
  I       = inffrac*((C[1] + C[2])/delta)^2
  e       = C[2]*inffrac:^(Omega - 0.5)
  f       = delta*sqrt(I) :- C[1]*inffrac:^(Omega - 0.5)
  PEH0    = J(L, 1, 0)
  PFH1    = J(L, 1, 0)
  for (l = 1; l <= L; l++) {
    if (l == 1) {
	  PEH0[l] = mvnormal_mata(e[l], ., 0, 1, 12, 1000, 3)[1]
	  PFH1[l] = mvnormal_mata(., f[l], delta*sqrt(I[l]), 1, 12, 1000, 3)[1]
	} else {
	  PEH0[l] = mvnormal_mata((f[1::(l - 1)] \ e[l]), (e[1::(l - 1)] \ .), J(l, 1, 0), Sigma[1::l, 1::l], 12, 1000, 3)[1]
      PFH1[l] = mvnormal_mata((f[1::(l - 1)] \ .), (e[1::(l - 1)] \ f[l]), delta*sqrt(I[1::l]), Sigma[1::l, 1::l], 12, 1000, 3)[1]
    }
  }
  Score = (alpha - sum(PEH0))^2 + (beta - sum(PFH1))^2
}

// Function to return multivariate normal probabilities
real vector mvnormal_mata(real colvector lower, real colvector upper, real colvector mean, real matrix Sigma, real scalar M, real scalar N, real scalar alpha)
{
  // Initialise all required variables
  k = rows(Sigma)
  // If we're dealing with the univariate or bivariate normal case use the
  // standard functions
  if (k == 1) {
    if (lower == .) {
	  lower = -8e+307
	}
	if (upper == .) {
	  upper = 8e+307
	}
    I = normal((upper - mean)/sqrt(Sigma)) - normal((lower - mean)/sqrt(Sigma))
    E = 0
  }
  else if (k == 2) {
    for (i = 1; i <= 2; i++) {
	  if (lower[i] == .) {
	    lower[i] = -8e+307
	  }
	  if (upper[i] == .) {
	    upper[i] = 8e+307
	  }
	}
	I = binormal((upper[1] - mean[1])/sqrt(Sigma[1, 1]),
	             (upper[2] - mean[2])/sqrt(Sigma[2, 2]),
	             Sigma[1,2]/sqrt(Sigma[1,1]*Sigma[2,2])) +
		  binormal((lower[1] - mean[1])/sqrt(Sigma[1, 1]),
				   (lower[2] - mean[2])/sqrt(Sigma[2, 2]),
				   Sigma[1,2]/sqrt(Sigma[1,1]*Sigma[2,2])) -
		    binormal((upper[1] - mean[1])/sqrt(Sigma[1, 1]),
			  	     (lower[2] - mean[2])/sqrt(Sigma[2, 2]),
				     Sigma[1,2]/sqrt(Sigma[1,1]*Sigma[2,2])) -
			  binormal((lower[1] - mean[1])/sqrt(Sigma[1, 1]),
				       (upper[2] - mean[2])/sqrt(Sigma[2, 2]),
				       Sigma[1,2]/sqrt(Sigma[1,1]*Sigma[2,2]))	   
	E = 0
  }
  // If we're dealing with an actual multivariate case then use the
  // Quasi-Monte-Carlo Randomised-Lattice Separation-Of-Variables method
  else if (k > 2) {
    // Algorithm is for the case with 0 means, so adjust lower and upper
    // and then re-order variables for maximum efficiency
    a         = lower - mean
    b         = upper - mean
    C         = J(k, k, 0)
    y         = J(1, k - 1, 0)  
    atilde    = J(1, k - 1, 0)
    btilde    = J(1, k - 1, 0)
    atilde[1] = a[1]
    btilde[1] = b[1]
    // Loop over each column of Sigma
    for (i = 1; i <= k - 1; i++) {
      // Determine variate with minimum expectation
	  args = J(1, k - i + 1, 0)
      for (j = 1; j <= k - i + 1; j++){
        s = j + i - 1
	    if (i > 1) {
	      if ((a[s] ~= .) & (b[s] ~= .)) {
		    args[j] = normal((b[s] - sum(C[s, 1::(i - 1)]:*y[1::(i - 1)]))/
                               sqrt(Sigma[s, s] - sum(C[s, 1::(i - 1)]:^2))) -
                        normal((a[s] - sum(C[s, 1::(i - 1)]:*y[1::(i - 1)]))/
                                 sqrt(Sigma[s, s] - sum(C[s, 1::(i - 1)]:^2)))
          }
          else if ((a[s] == .) & (b[s] ~= .)) {
	        args[j] = normal((b[s] - sum(C[s, 1::(i - 1)]:*y[1::(i - 1)]))/
                               sqrt(Sigma[s, s] - sum(C[s, 1::(i - 1)]:^2))) 
          }
          else if ((b[s] == .) & (a[s] ~= .)) {
  	        args[j] = 1 - normal((a[s] - sum(C[s, 1::(i - 1)]:*y[1::(i - 1)]))/
                                   sqrt(Sigma[s, s] - sum(C[s, 1::(i - 1)]:^2)))
          }
          else if ((a[s] == .) & (b[s] == .)) {
	        args[j] = 1
          }
        } 
        else {
          if ((a[s] ~= .) & (b[s] ~= .)) {
            args[j] = normal(b[s]/sqrt(Sigma[1, 1])) -
                        normal(a[s]/sqrt(Sigma[1, 1])) 
          }
          else if ((a[s] == .) & (b[s] ~= .)) {
            args[j] = normal(b[s]/sqrt(Sigma[1, 1])) 
          }
          else if ((b[s] == .) & (a[s] ~= .)) {
            args[j] = 1 - normal(a[s]/sqrt(Sigma[1, 1])) 
          }
          else if ((a[s] == .) & (b[s] == .)) {
            args[j] = 1
          }
        }
      }
      minindex(args, 1, ii, ww)
      m = i - 1 + ii[1]
      // Change elements m and i of a, b, Sigma and C
      tempa    = a
      tempb    = b
      tempa[i] = a[m]
      tempa[m] = a[i]
      a        = tempa
      tempb[i] = b[m]
      tempb[m] = b[i]
      b        = tempb
      tempSigma          = Sigma
      tempSigma[i, 1::k] = Sigma[m, 1::k]
      tempSigma[m, 1::k] = Sigma[i, 1::k]
      Sigma              = tempSigma
      Sigma[1::k, i]     = tempSigma[1::k, m]
      Sigma[1::k, m]     = tempSigma[1::k, i]
      if (i > 1){
        tempC          = C
        tempC[i, 1::k] = C[m, 1::k]
        tempC[m, 1::k] = C[i, 1::k]
        C              = tempC
        C[1::k, i]     = tempC[1::k, m]
        C[1::k, m]     = tempC[1::k, i]
        // Compute next column of C and next value of atilda and btilda
        C[i, i]        = sqrt(Sigma[i, i] - sum(C[i, 1::(i - 1)]:^2))
        for (s = i + 1; s <= k; s++){
          C[s, i]      = (Sigma[s, i] - sum(C[i, 1::(i - 1)]:*C[s, 1::(i - 1)]))/
                           C[i, i]
        }
        atilde[i]      = (a[i] - sum(C[i, 1::(i - 1)]:*y[1::(i - 1)]))/C[i, i]
        btilde[i]      = (b[i] - sum(C[i, 1::(i - 1)]:*y[1::(i - 1)]))/C[i, i]
      } else {
        C[i, i]        = sqrt(Sigma[i, i])
        C[2::k, i]     = Sigma[2::k, i]/C[i, i]
      }
      // Compute next value of y using integrate
      y[i]  = (normalden(atilde[i]) - normalden(btilde[i]))/
                (normal(btilde[i]) - normal(atilde[i]))
    }
    // Set the final element of C
    C[k, k] = sqrt(Sigma[k, k] - sum(C[k, 1::(k - 1)]:^2))
    // List of the first 100 primes to use in the integration algorithm
    p = (2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67,
         71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139,
         149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223,
         227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293,
         307, 311, 313, 317, 331, 337, 347, 349, 353, 359, 367, 373, 379, 383,
         389, 397, 401, 409, 419, 421, 431, 433, 439, 443, 449, 457, 461, 463,
         467, 479, 487, 491, 499, 503, 509, 521, 523, 541)
    // Initialise all required variables
    I   = 0
    V   = 0 
    sqp = p[1::(k - 1)]:^0.5
    d   = J(1, k, 0)
    e   = J(1, k, 1)
    f   = J(1, k, 0)
    // First elements of d, e and f are always the same
    if (a[1] ~= .) {
      d[1] = normal(a[1]/C[1, 1])
    }
    if (b[1] ~= .) {
      e[1] = normal(b[1]/C[1, 1])
    }
    f[1] = e[1] - d[1]
    // Perform M shifts of the Quasi-Monte-Carlo integration algorithm
    for (i = 1; i <= M; i++) {
      Ii = 0
      // We require k - 1 random uniform numbers
      Delta = runiform(1, k - 1)
      // Use N samples in each shift
      for (j = 1; j <= N; j++) {
        // Loop to compute other values of d, e and f
        for (l = 2; l <= k; l++) {
          y[l - 1] = invnormal(d[l - 1] +
                       abs(2*(mod(j*sqp[l - 1] + Delta[l - 1], 1)) - 1)*
                         (e[l - 1] - d[l - 1]))
          if (a[l] ~= .) {
            d[l]   = normal((a[l] - sum(C[l, 1::(l - 1)]:*y[1::(l - 1)]))/C[l, l])
          }
          if (b[l] ~= .) {
            e[l]   = normal((b[l] - sum(C[l, 1::(l - 1)]:*y[1::(l - 1)]))/C[l, l])
          }
          f[l]     = (e[l] - d[l])*f[l - 1]
        }
        Ii         = Ii + (f[k] - Ii)/j
      }
      // Update the values of the variables
      delta = (Ii - I)/i
      I     = I + delta
      V     = (i - 2)*V/i + delta^2
      E     = alpha*sqrt(V)
    }
  }
  // Return result
  return((I, E))
}

// Function for one dimensional optimization
real colvector brent_min(pointer scalar func, real scalar init, real scalar lower,
                         real scalar upper,| string objective, real scalar max_iter,
                         real scalar sqrt_dbl_epsilon, transmorphic arguments)
{
  if (args() == 4) {
    objective        = "min"
    max_iter         = 100
    sqrt_dbl_epsilon = 1e-4
  }
  else if (args() == 5) {
    max_iter         = 100
    sqrt_dbl_epsilon = 1e-4
  }
  else if (args() == 6) {
    sqrt_dbl_epsilon = 1e-4
  }
  
  if (objective == "min") {
    factor = 1
  }
  else {
    factor = -1
  }
  
  golden  = 0.3819660 /* golden = (3 - sqrt(5))/2 */
  
  x_lower = lower
  x_upper = upper
  
  v       = x_lower + golden*(x_upper - x_lower)
  w       = v
  if (args() < 8) {
    f_vw  = factor*(*func)(v)
  }
  else {
    f_vw  = factor*(*func)(v, arguments)
  }
  f_v     = f_vw
  f_w     = f_vw
  
  x_left  = min((x_lower, x_upper))
  x_right = max((x_lower, x_upper))
  
  z     = init
  if (args() < 8) {
    f_z = factor*(*func)(z)
  }
  else {
    f_z = factor*(*func)(z, arguments)
  }
  
  w_lower = z - x_left
  w_upper = x_right - z
  
  e = 0
  p = 0
  q = 0
  r = 0
  
  iter = 0
  
  while (iter < max_iter) {
    
    tolerance = sqrt_dbl_epsilon*abs(z)
    midpoint  = 0.5*(x_left + x_right)
    if (abs(z - midpoint) <= 2*tolerance - 0.5*(x_right - x_left)) {
      min   = z
      f_min = (factor == 1 ? f_z : -f_z)
      flag  = 0
      return((min \ f_min \ flag \ iter))
    }

    if (abs(e) > tolerance) {
      r = (z - w)*(f_z - f_v)
      q = (z - v)*(f_z - f_w)
      p = (z - v)*q - (z - w)*r
      q = 2*(q - r)
      if (q > 0) {
        p = -p
      }
      else {
        q = -q
      }
      r = e
      e = d
    }
    if ((abs(p) < abs(0.5*q*r)) & (p < q*w_lower) & (p < q*w_upper)) {
      t2 = 2*tolerance
      d  = p/q
      u  = z + d
      if ((u - x_left < t2) | (x_right - u < t2)) {
        d = (z < midpoint ? tolerance : -tolerance)
      }
    }
    else {
      e = (z < midpoint ? x_right - z : -(z - x_left))
      d = golden*e
    }
    if (abs(d) >= tolerance) {
      u = z + d
    }
    else {
      u = z + (d > 0 ? tolerance : -tolerance)
    }
    if (args() < 8) {
      f_u = factor*(*func)(u)
    }
    else {
      f_u = factor*(*func)(u, arguments)
    }
    if (f_u <= f_z) {
      if (u < z){
        x_right = z
      }
      else {
        x_left = z
      }
      v   = w
      f_v = f_w
      w   = z
      f_w = f_z
      z   = u
      f_z = f_u
    }
    else {
      if (u < z) {
        x_left = u
      }
      else {
        x_right = u
      }
      
      if ((f_u <= f_w) | (w == z)) {
        v   = w
        f_v = f_w
        w   = u
        f_w = f_u
      }
      else if ((f_u <= f_v) | (v == z) | (v == w)) {
        v   = u
        f_v = f_u
      }
    }
    
    w_lower = z - x_left
    w_upper = x_right - z
  
    iter = iter + 1
    
  } 
  
  min   = z
  f_min = (factor == 1 ? f_z : -f_z)
  flag  = 1
  return((min \ f_min \ flag \ iter))
}

end // End of mata
