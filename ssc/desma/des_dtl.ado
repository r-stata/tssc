*! Author(s) : Michael J Grayling
*! Date      : 31 Jan 2019
*! Version   : 0.9

/* Version history:

   31/01/19 v0.9 Initial version complete.

*/

/* To do list:

   - Add option for plotting.

*/

program define des_dtl, rclass
version 15.0
syntax , [Kv(numlist) ALPha(real 0.05) Beta(real 0.2) DELta(real 0.5) ///
          delta0(real 0) sd(real 1) RATio(real 1) NO_sample_size ///
		  n_start(integer 1) n_stop(integer -1)]

preserve

///// Check input variables ////////////////////////////////////////////////////

local lenkv:list sizeof kv
if (`lenkv' == 1) {
  di "{error}The number of experimental treatments in each stage (kv) must be a"
  di " numlist of length greater than 1."
  exit(198)
}
else if (`lenkv' > 0) {
  local kviold:word 1 of `kv'
  if ((`kviold' <= 1) | (mod(`kviold', 1) != 0)) {
    di "{error}The number of experimental treatments in each stage (kv) must be"
	di " a strictly monotonically decreasing numlist of length greater than 1, "
	di "containing only positive integers, with final element equal to 1."
	exit(198)
  }
  forvalues i = 2/`lenkv' {
    local kvinew:word `i' of `kv'
    if ((`kvinew' <= 0) | (`kvinew' >= `kviold') | (mod(`kvinew', 1) != 0)) {
      di "{error}The number of experimental treatments in each stage (kv) must "
	  di "be a strictly monotonically decreasing numlist of length greater than"
	  di " 1, containing only positive integers, with final element equal to 1."
      exit(198)
    }
	local kviold `kvinew'
  }
  if (`kviold' != 1) {
    di "{error}The number of experimental treatments in each stage (kv) must be"
	di " a strictly monotonically decreasing numlist of length greater than 1, "
	di "containing only positive integers, with final element equal to 1."
	exit(198)
  }
}
if ((`alpha' <= 0) | (`alpha' >= 1)) {
  di "{error}The desired familywise error-rate (alpha) must be a real strictly "
  di "between 0 and 1."
  exit(198)
}
if ((`beta' <= 0) | (`beta' >= 1)) {
  di "{error}The desired type-II error-rate (beta) must be a real strictly "
  di "between 0 and 1."
  exit(198)
}
if (`delta' <= 0) {
  di "{error}The interesting treatment effect (delta) must be a real strictly"
  di " greater than 0."
  exit(198)
}
if (`sd' <= 0) {
  di "{error}The assumed value of the standard deviation of the responses (sd) "
  di "must be a real strictly greater than 0."
  exit(198)
}
if (`ratio' <= 0) {
  di "{error}The allocation ratio between the experimental arms and the control"
  di "arm (ratio) must be a real strictly greater than 0."
  exit(198)
}
if (`n_start' < 1) {
  di "{error}The starting value in the search for the required stage-wise group"
  di " size (n_start) must be an integer greater than or equal to 1."
  exit(198)
}
if ((`n_stop' != -1) & (`n_stop' < `n_start')) {
  di "{error}The stopping value in the search for the required stage-wise group"
  di " size (n_stop) must either be equal to -1 or be an integer greater than "
  di "or equal to n_start."
  exit(198)
}
if (`delta0' >= `delta') {
  di "WARNING: The uninteresting treatment effect (delta0) should in general be"
  di "strictly smaller than the interesting treatment effect (delta)."
}
if ("`no_sample_size'" != "") {
  if (`beta' != 0.2) {
    di "WARNING: beta has been changed from default but this will have no "
	di "effect given the choice of no_sample_size."
  }
  if (`delta' != 0.5) {
    di "WARNING: delta has been changed from default but this will have no "
	di "effect given the choice of no_sample_size."
  }
  if (`delta0' != 0) {
    di "WARNING: delta0 has been changed from default but this will have no "
	di "effect given the choice of no_sample_size."
  }
  if ("`separate'" != "") {
    di "WARNING: separate has been changed from default but this will have no "
	di "effect given the choice of no_sample_size."
  }
  if (`n_start' != 1) {
    di "WARNING: n_start has been changed from default but this will have no "
	di "effect given the choice of no_sample_size."
  }
  if (`n_stop' != -1) {
    di "WARNING: n_stop has been changed from default but this will have no "
	di "effect given the choice of no_sample_size."
  }
}

///// Perform main computations ////////////////////////////////////////////////

if (`lenkv' > 0) {
  local matakv ""
  foreach i of local kv {
    if "`matakv'" == "" local matakv "`i'"
    else local matakv "`matakv',`i'"
  }
  mat kv = (`matakv')
}
else {
  mat kv = (3, 1)
}
mata: des_dtl_void(`alpha', `beta', `delta', `delta0', `sd', `ratio', ///
                   "`no_sample_size'", `n_start', `n_stop')

///// Output ///////////////////////////////////////////////////////////////////

return scalar N     = opchar[1, 3]
return scalar P_LFC = opchar[1, 2]
return scalar P_HG  = opchar[1, 1]
return scalar n     = n[1, 1]
return scalar u     = u[1, 1]

restore

end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void des_dtl_void(real scalar alpha, real scalar beta, real scalar delta,
                  real scalar delta0, real scalar sd, real scalar ratio,
			      string no_sample_size, real scalar n_start,
				  real scalar n_stop) {
  Kv                                 = st_matrix("kv")
  J                                  = length(Kv)
  printf("{txt}{dup 43:{c -}}\n")
  printf("{inp}%g{txt}-stage {inp}%g{txt}-experimental treatment DTL design", J,
         Kv[1])
  printf("\n{dup 43:{c -}}\n")
  printf("The hypotheses to be tested will be:\n\n")
  if (Kv[1] == 1) {
    printf("   H1: τ{inp}1{txt} = μ1 - μ0 ≤ 0.\n\n")
  }
  else if (Kv[1] == 2) {
    printf("   Hk: τk = μk - μ0 ≤ 0, k = 1, {inp}2{txt}.\n\n")
  }
  else if (Kv[1] == 3) {
    printf("   Hk: τk = μk - μ0 ≤ 0, k = 1, 2, {inp}3{txt}.\n\n")
  }
  else {
    printf("   Hk: τk = μk - μ0 ≤ 0, k = 1, ..., {inp}%g{txt}.\n\n",
	       Kv[1])
  }
  printf("The stopping boundaries will be determined to control the ")
  printf("familywise error-rate\nunder the global null hypothesis, HG, ")
  printf("given by:\n\n")
  if (Kv[1] == 1) {
    printf("   HG: τ{inp}1{txt} = 0.\n\n")
  }
  else if (Kv[1] == 2) {
    printf("   HG: τ1 = τ{inp}2{txt} = 0.\n\n")
  }
  else if (Kv[1] == 3) {
    printf("   HG: τ1 = τ2 = τ{inp}3{txt} = 0.\n\n")
  }
  else {
    printf("   HG: τ1 = ... = τ{inp}%g{txt} = 0.\n\n", Kv[1])
  }
  printf("Specifically, if P_HA() is the power function for rejecting any null")
  printf(" hypothesis,\nthe stopping boundaries will be chosen such that:\n\n")
  printf("   P_HA(HG) ≤ α = {inp}%g{txt}.\n\n", alpha)
  if (no_sample_size == "") {
    printf("The required sample size will be determined to control the type-II")
	printf(" error-rate\nunder the least favourable configuration, LFC, given ")
	printf("by:\n\n")
	if (Kv[1] == 1) {
      printf("   LFC: τ{inp}1{txt} = δ = %g.\n\n", delta)
    }
    else if (Kv[1] == 2) {
      printf("   LFC: τ1 = δ = {inp}%g{txt}, τ{inp}2{txt} = δ0 = ", delta)
	  printf("{inp}%g{txt}.\n\n", delta0)
    }
    else if (Kv[1] == 3) {
      printf("   LFC: τ1 = δ = {inp}%g{txt}, τ2 = τ{inp}3{txt} = δ0 = ", delta)
	  printf("{inp}%g{txt}.\n\n", delta0)
    }
    else {
      printf("   LFC: τ1 = δ = {inp}%g{txt}, τ2 = ... = τ{inp}%g{txt} = ",
	         delta, Kv[1])
      printf("δ0 = {inp}%g{txt}.\n\n", delta0)
    }
	printf("Specifically, if P_H1() is the power function for rejecting H1, ")
	printf("the sample size\nwill be chosen such that:\n\n")
	printf("   P_H1(LFC) ≥ 1 - β = 1 - {inp}%g{txt}.\n\n", beta)
  }
  else {
    printf("The required sample size will not be determined.\n\n")
  }
  printf("The stage-wise allocation ratio between the (remaining) experimental")
  printf(" arms and\nthe shared control arm, ratio, will be: {inp}%g{txt}.\n\n",
         ratio)
  printf("The number of experimental treatments present in stages 1 through ")
  printf("{inp}%g{txt} will be:\n\n", J)
  for (j = 1; j <= J; j++) {
    if (j == 1) {
      printf("{inp}(%g, ", Kv[j])
    }
    else if ((j > 1) & (j < J)) {
      printf("%g, ", Kv[j])
    }
    else {
      printf("%g){txt}.\n\n", Kv[j])
    }
  }
  printf("Now determining the final-stage rejection boundary.\n\n")
  JK                                 = J*Kv[1]
  Lambda                             = J(JK, JK, 0)
  add                                = ratio/(ratio + 1)
  minus                              = 1 - add
  I_K                                = I(Kv[1])
  Lambda_j                           = J(Kv[1], Kv[1], add) + I_K*minus
  for (j = 1; j <= J; j++) {
    index_range                      = (1 + (j - 1)*Kv[1])::(j*Kv[1])
    Lambda[index_range, index_range] = Lambda_j
  }
  for (j1 = 1; j1 <= J; j1++) {
    for (j2 = 1; j2 <= j1 - 1; j2++) {
	  range_j1                       = (1 + (j1 - 1)*Kv[1])::(j1*Kv[1])
      range_j2                       = (1 + (j2 - 1)*Kv[1])::(j2*Kv[1])
	  Lambda[range_j2, range_j1]     = Lambda[range_j1, range_j2] =
		sqrt(j2/j1)*Lambda_j
    }
  }
  rej                                = lowertriangle(J(Kv[J], Kv[J], 1), .)
  outcomes                           = (J(Kv[J], 1, (1::Kv[1])'), rej,
                                        J(Kv[J], 2, 0))
  conditions                         = sum(Kv[1::(J - 1)]) - (J - 1) + Kv[J] +
                                         (Kv[J] > 1)*(Kv[J] - 1)
  A                                  = J(conditions, JK, 0)
  counter                            = 1
  for (j = 1; j <= J - 1; j++) {
    dropped                          = Kv[j]::(Kv[j + 1] + 1)
    if (length(dropped) > 1) {
      for (cond = 1; cond <= Kv[j] - Kv[j + 1] - 1; cond++) {
	    A[counter,
		  Kv[1]*(j - 1) +
		  	which_condition(outcomes[1, 1::Kv[1]], "e", dropped[cond + 1])] = 1
	    A[counter,
		  Kv[1]*(j - 1) +
		  	which_condition(outcomes[1, 1::Kv[1]], "e", dropped[cond])]     = -1
	    counter                      = counter + 1
	  }
    }
    continued                        = Kv[j + 1]::1
    for (cond = 1; cond <= Kv[j + 1]; cond++) {
       A[counter,
	     Kv[1]*(j - 1) +
	  	   which_condition(outcomes[1, 1::Kv[1]], "e", continued[cond])]    = 1
       A[counter,
	     Kv[1]*(j - 1) +
		   which_condition(outcomes[1, 1::Kv[1]], "e",
		                   dropped[length(dropped)])]                       = -1
	   counter                       = counter + 1
    }
  }
  if (Kv[J] > 1) {
    for (cond = 1; cond <= Kv[J] - 1; cond++) {
      A[counter,
	    Kv[1]*(J - 1) +
		  which_condition(outcomes[1, 1::Kv[1]], "e", Kv[J] - cond)]        = 1
      A[counter,
	    Kv[1]*(J - 1) + which_condition(outcomes[1, 1::Kv[1]], "e",
	                                    Kv[J] - cond + 1)]                  = -1
      counter                        = counter + 1
    }
  }
  for (k = 1; k <= Kv[J]; k++) {
    A[counter,
	  (J - 1)*Kv[1] + which_condition(outcomes[1, 1::Kv[1]], "e", k)]       = 1
    counter                          = counter + 1
  }
  means_HG                           = lowers = J(conditions, 1, 0)
  means_LFC                          =
    A*(vec(J(J, 1, (delta \ J(Kv[1] - 1, 1, delta0)))):*
         sqrt(vec(J(1, Kv[1], (1/(sd^2 + sd^2/ratio))*(1::J))')))
  Lambda                             = A*Lambda*(A')
  uppers                             = J(conditions, 1, .)
  u                                  =
    brent_root_u(Kv, alpha, J, outcomes, lowers', uppers', means_HG', Lambda,
	             conditions)[1]
  printf("Final-stage rejection boundary, u, determined to be: ")
  printf("{res}%g{txt}.\n\n", round(u, 0.01))
  if (no_sample_size == "") {
    printf("Now determining the required sample size.\n\n")
    if (n_stop = -1) {
	  q                              = invmvnormal_mata(1 - alpha,
	                                                    J(1, Kv[1], 0),
	                                                    Lambda_j, "lower", 100,
	                                                    1e-4, "pmvnormal", 12,
									  		  	        1000)[1]												   
	  n_stop                         =
	    ceil((sd*(q*sqrt(1 + 1/ratio) +
		            invnormal(1 - beta)*sqrt(1 + 1/ratio))/delta)^2)
	  while (mod(ratio*n_stop, 1) != 0) {
	    n_stop                       = n_stop + 1
	  }
	  if (n_stop < n_start) {
		printf("{err}Computed value of n_stop is smaller than the specified ")
		printf("value of n_start.\n")
		exit(198)
	  }
	}
	power_check                      = 0
	n                                = n_start
	while (mod(ratio*n, 1) != 0) {
	  n                              = n + 1
	}
	while ((power_check == 0) & (n <= n_stop)) {
	  power_check                    =
		(dtl_find_n(n, Kv, beta, J, outcomes, lowers, uppers, means_LFC,
		            Lambda, conditions, u) < 0)
	  n                              = n + 1
	  while (mod(ratio*n, 1) != 0) {
	    n                            = n + 1
	  }
	}
	if (n > n_stop) {
	  printf("{err}The group size was limited by n_stop. Consider increasing")
	  printf(" its value and re-running des_mams.")
      exit(198)
	}
	if (n == n_start) {
	  printf("WARNING: The required power was met with n_start. Considering ")
	  printf("decreasing its value and re-running des_dtl.")
	}
	n                                = n - 1
	while (mod(ratio*n, 1) != 0) {
	  n                              = n - 1
	}
	printf("Required stage-wise group size in the control arm, n, determined ")
	printf("to be: {res}%g{txt}.\n\n", n)
	opchar                           =
	  (dtl_opchar(n, Kv, J, outcomes, lowers, uppers, means_HG, means_LFC,
	             Lambda, conditions, u), n*(J + sum(Kv)))
	printf("The operating characteristics of the design are:\n\n")
    printf("   r()   | Variable\n")
	printf("   {dup 5:{c -}}   {dup 8:{c -}}\n")
	printf("   P_HG  | P_HA(HG)  = {res}%g{txt},\n", round(opchar[1], .001))
    printf("   P_LFC | P_H1(LFC) = {res}%g{txt},\n", round(opchar[2], .001))
	printf("   N     | N         = {res}%g{txt}.\n", opchar[3])
  }
  else {
    n                                = .
	opchar                           = J(1, 3, .)
  }
  st_matrix("n", n)
  st_matrix("u", u)
  st_matrix("opchar", opchar)
}

real colvector brent_root_u(real vector Kv, real scalar alpha,
                            real scalar J, real matrix outcomes,
							real vector lowers, real vector uppers,
							real vector means_HG, real matrix Lambda,
							real scalar conditions) {
  max_iter   = 100
  half_tol   = 5e-5
  a          = 0
  b          = 5
  fa         = dtl_find_u(a, Kv, alpha, J, outcomes, lowers, uppers, means_HG,
                          Lambda, conditions)
  fb         = dtl_find_u(b, Kv, alpha, J, outcomes, lowers, uppers, means_HG,
                          Lambda, conditions)
  if (((fa > 0) & (fb > 0)) | ((fa < 0) & (fb < 0))) {
    return((. \ . \ 2 \ 0))
  }
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
	  return((b \ fb \ 0 \ iter))
	}
	if ((abs(e) >= tol1) & (abs(fa) > abs(fb))) {
	  s      = fb/fa
	  if (a == c) {
	    p    = 2*xm*s
		q    = 1 - s
	  }
	  else {
	    q    = fa/fc
		r    = fb/fc
		p    = s*(2*xm*q*(q - r) - (b - a)*(r - 1))
        q    = (q - 1)*(r - 1)*(s - 1)
	  }
	  if (p > 0) {
	    q    = -q
	  }
	  p      = abs(p)
	  if (2*p < min((3*xm*q - abs(tol1*q), abs(e*q)))) {
	    e    = d
		d    = p/q
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
	fb       = dtl_find_u(b, Kv, alpha, J, outcomes, lowers, uppers, means_HG,
	                      Lambda, conditions)
  }
  return((b \ fb \ 1 \ max_iter))
}

real scalar dtl_find_u(real scalar u, real vector Kv, real scalar alpha,
                       real scalar J, real matrix outcomes, real vector lowers,
					   real vector uppers, real vector means_HG,
					   real matrix Lambda, real scalar conditions) {
  Lambda_old                             = Lambda
  for (i = 1; i <= Kv[J]; i++) {
    lowers_i                             = lowers
	uppers_i                             = uppers
	for (k = 1; k <= Kv[J]; k++) {
	  if (outcomes[i, Kv[1] + k] == 1) {
	    lowers_i[conditions - Kv[J] + k] = u
	  }
	  else {
	    lowers_i[conditions - Kv[J] + k] = .
		uppers_i[conditions - Kv[J] + k] = u
	  }
	}
	outcomes[i, Kv[1] + Kv[J] + 1]       =
	  pmvnormal_mata(lowers_i, uppers_i, means_HG,
	                 Lambda[1::conditions, 1::conditions], 12, 1000, 3)[1]
	Lambda                               = Lambda_old
  }
  return(alpha - factorial(Kv[1])*sum(outcomes[, Kv[1] + Kv[J] + 1]))
}
 
real scalar dtl_find_n(real scalar n, real vector Kv, real scalar beta,
                       real scalar J, real matrix outcomes, real matrix lowers,
					   real matrix uppers, real vector means_LFC,
					   real matrix Lambda, real scalar conditions,
					   real scalar u) {
  Lambda_old                             = Lambda
  for (i = 1; i <= Kv[J]; i++) {
    lowers_i                             = lowers
	uppers_i                             = uppers
	for (k = 1; k <= Kv[J]; k++) {
	  if (outcomes[i, Kv[1] + k] == 1) {
	    lowers_i[conditions - Kv[J] + k] = u
	  }
	  else {
	    lowers_i[conditions - Kv[J] + k] = .
		uppers_i[conditions - Kv[J] + k] = u
	  }
	}
	outcomes[i, Kv[1] + Kv[J] + 2]       =
	  pmvnormal_mata(lowers_i, uppers_i, sqrt(n)*means_LFC,
	                 Lambda[1::conditions, 1::conditions], 12, 1000, 3)[1]
	Lambda                               = Lambda_old
  }
  return((1 - beta) - factorial(Kv[1] - 1)*sum(outcomes[, Kv[1] + Kv[J] + 2]))
}

real vector dtl_opchar(real scalar n, real vector Kv, real scalar J,
                       real matrix outcomes, real matrix lowers,
					   real matrix uppers, real vector means_HG,
					   real vector means_LFC, real matrix Lambda,
					   real scalar conditions, real scalar u) {
  Lambda_old                             = Lambda
  for (i = 1; i <= Kv[J]; i++) {
    lowers_i                             = lowers
	uppers_i                             = uppers
	for (k = 1; k <= Kv[J]; k++) {
	  if (outcomes[i, Kv[1] + k] == 1) {
	    lowers_i[conditions - Kv[J] + k] = u
	  }
	  else {
	    lowers_i[conditions - Kv[J] + k] = .
		uppers_i[conditions - Kv[J] + k] = u
	  }
	}
	lowers_i_old                         = lowers_i
	uppers_i_old                         = uppers_i
	Lambda                               = Lambda_old
	outcomes[i, Kv[1] + Kv[J] + 1]       =
	  pmvnormal_mata(lowers_i, uppers_i, means_HG,
	                 Lambda[1::conditions, 1::conditions], 12, 1000, 3)[1]
	Lambda                               = Lambda_old
	lowers_i                             = lowers_i_old
	uppers_i                             = uppers_i_old
	outcomes[i, Kv[1] + Kv[J] + 2]       =
	  pmvnormal_mata(lowers_i, uppers_i, sqrt(n)*means_LFC,
	                 Lambda[1::conditions, 1::conditions], 12, 1000, 3)[1]
  }
  Lambda                                 = Lambda_old
  return((factorial(Kv[1])*sum(outcomes[, Kv[1] + Kv[J] + 1]),
          factorial(Kv[1] - 1)*sum(outcomes[, Kv[1] + Kv[J] + 2])))
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
    return(pmvnormal_mata(a, b, mean, Sigma[1::k, 1::k], shifts, samples,
	                      3)[1] - p)
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
