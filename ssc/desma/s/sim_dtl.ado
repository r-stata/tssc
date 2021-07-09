*! Author(s) : Michael J Grayling
*! Date      : 31 Jan 2019
*! Version   : 0.9

/* Version history:
   31/01/19 v0.9 Initial version complete.
*/

/* To do:
   - Add option for plotting.
*/

program define sim_dtl, rclass
version 15.0
syntax , [Kv(numlist) u(real 1.98) n(integer 34) tau(numlist) sd(real 1) ///
          RATio(real 1) REPlicates(integer 100000)]

preserve

///// Check input variables ////////////////////////////////////////////////////

local lenkv:list  sizeof kv
local lentau:list sizeof tau
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
	di "containing only positive integers."
	exit(198)
  }
  forvalues i = 2/`lenkv' {
    local kvinew:word `i' of `kv'
    if ((`kvinew' <= 0) | (`kvinew' >= `kviold') | (mod(`kvinew', 1) != 0)) {
      di "{error}The number of experimental treatments in each stage (kv) must "
	  di "be a strictly monotonically decreasing numlist of length greater than"
	  di " 1, containing only positive integers."
      exit(198)
    }
	local kviold `kvinew'
  }
}
if (`n' < 1) {
  di "{error}The stage-wise group size in the control arm (n) must be an "
  di "integer greater than or equal to 1."
  exit(198)
}
if (`lentau' > 0) {
  if ((`lentau' != 3) & (`lenkv' == 0)) {
    di "{error}The treatment effects (tau) must be a numlist of length equal to"
	di " the initial number of experimental treatments, given by the first "
	di "element of kv."
    exit(198)
  }
  if (`lenkv' > 0) {
    local k:word 1 of `kv'
	if (`k' != `lentau') {
      di "{error}The treatment effects (tau) must be a numlist of length equal "
	  di "to the initial number of experimental treatments, given by the first "
	  di "element of kv."
	  exit(198)
    }
  }
}
if (`sd' <= 0) {
  di "{error}The true value of the standard deviation of the responses (sd) "
  di "must be a real strictly greater than 0."
  exit(198)
}
if (`ratio' <= 0) {
  di "{error}The allocation ratio between the experimental arms and the control"
  di " arm (ratio) must be a real strictly greater than 0."
  exit(198)
}

else if (mod(`ratio'*`n', 1) != 0) {
  di "{error}The product of the allocation ratio between the experimental arms "
  di " and the control arm (ratio) and the stage-wise group size in the control"
  di " arm (n) must be an integer greater than or equal to 1."
  exit(198)
}
if (`replicates' < 1) {
  di "{error}The number of replicate simulations to conduct (replicates) must "
  di "be an integer greater than or equal to 1."
  exit(198)
}

///// Perform main computations ////////////////////////////////////////////////

if (`lenkv' > 0) {
  local matakv ""
  foreach i of local kv {
    if "`matakv'" == "" local matakv "`i'"
    else local matakv "`matakv',`i'"
  }
  mat kv    = (`matakv')
}
else {
  mat kv    = (3, 1)
}
if (`lentau' > 0) {
  local matatau ""
  foreach l of local tau {
    if "`matatau'" == "" local matatau "`l'"
    else local matatau "`matatau',`l'"
  }
  mat tau   = (`matatau')
}
else {
  if (`lenkv' == 0) {
    mat tau = J(1, 3, 0)
  }
  else {
    local k:word 1 of `kv'
    mat tau = J(1, `k', 0)
  }
}
mata: sim_dtl_void(`u', `n', `sd', `ratio', `replicates')

///// Output ///////////////////////////////////////////////////////////////////

return scalar P_H1 = opchar[1, 2]
return scalar P_HA = opchar[1, 1]

restore

end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void sim_dtl_void(real scalar u, real scalar n, real scalar sd,
                  real scalar ratio, real scalar replicates) {
  Kv    = st_matrix("kv")
  tau   = st_matrix("tau")
  J     = length(Kv)
  printf("{txt}{dup 53:{c -}}\n")
  printf("{inp}%g{txt}-stage {inp}%g{txt}-experimental treatment DTL trial ",
         J, Kv[1])
  printf("simulation\n")
  printf("{dup 53:{c -}}\n")
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
  printf("The stage-wise group size in the control arm, n, will be: ")
  printf("{inp}%g{txt}.\n\n", n)
  printf("The stage-wise allocation ratio between the (remaining) experimental")
  printf(" arms and\nthe shared control arm, ratio, will be: {inp}%g{txt}.\n\n",
         ratio)
  printf("The final-stage rejection boundary, u, will be: ")
  printf("{inp}%g{txt}.\n\n", u)
  printf("The trial will be simulated under the scenario where:\n\n")
  if (Kv[1] == 1) {
    printf("   τ = τ{inp}1{txt} = {inp}%g{txt}.\n\n", tau)
  }
  else if (Kv[1] == 2) {
    printf("   τ = (τ1, τ{inp}2{txt}) = {inp}(%g, %g){txt}.\n\n",
	       tau[1], tau[2])
  }
  else {
    printf("   τ = (")
	for (k = 1; k <= Kv[1] - 1; k++) {
	  printf("τ%g, ", k)
	}
	printf("τ{inp}%g{txt}) = {inp}(", Kv[1])
	for (k = 1; k <= Kv[1] - 1; k++) {
	  printf("%g, ", tau[k])
	}
	printf("%g){txt}.\n\n", tau[Kv[1]])
  }
  printf("Beginning the required simulations.\n\n")
  opchar = sim_dtl_mata(Kv, n, u, tau, sd, ratio, replicates, J)
  printf("Completed the required simulations.\n\n")
  printf("The estimated operating characteristics of the trial are:\n\n")
  printf("   r()  | Variable\n")
  printf("   {dup 4:{c -}}   {dup 8:{c -}}\n")
  printf("   P_HA | P_HA(τ) = {res}%g{txt},\n", round(opchar[1], .001))
  printf("   P_H1 | P_H1(τ) = {res}%g{txt}.\n", round(opchar[2], .001))
  st_matrix("opchar", opchar)
}

real vector sim_dtl_mata(real vector Kv, real scalar n, real scalar u,
                         real vector tau, real scalar sd, real scalar ratio,
						 real scalar replicates, real scalar J) {
  seq_J             = 1::J
  seq_K             = 1::Kv[1]
  r0n               = seq_J*n
  r0n_diff          = r0n :- (0 \ r0n[1::(J - 1)])
  sd_sqrt_r0n_diff  = sd*sqrt(r0n_diff)
  r                 = seq_J*ratio
  rn                = r*n
  rn_mat            = J(1, Kv[1], rn)
  rn_diff           = r0n_diff*ratio
  sd_sqrt_rn_diff   = J(1, Kv[1], sd*sqrt(rn_diff))
  rn_diff_tau       = rn_diff*tau
  denominator       = (sd*sqrt((J(1, Kv[1], r) :+ J(1, Kv[1], seq_J)):/
                                 (J(1, Kv[1], rn):*J(1, Kv[1], seq_J))))
  one_1K            = J(1, Kv[1], 1)
  rej_any           = rej_one = 0
  for (i = 1; i <= replicates; i++) {
	hat_mu_k        = rnormal(J, Kv[1], 0, 1):*sd_sqrt_rn_diff :+ rn_diff_tau
    for (k = 1; k <= Kv[1]; k++) {
	  hat_mu_k[, k] = runningsum(hat_mu_k[, k])
    }
	Z_jk            =
	  (hat_mu_k:/rn_mat :-
	     J(1, Kv[1], runningsum(rnormal(1, 1, 0, sd_sqrt_r0n_diff)):/r0n)):/
	    denominator
	remaining       = seq_K
	for (j = 1; j <= J - 1; j++) {
	  remaining     =
	    remaining[revorder(order(Z_jk[j, remaining]', 1))[1::Kv[j + 1]]]
	}
	for (k = 1; k <= Kv[J]; k++) {
	  if (Z_jk[J, remaining[k]] > u) {
	    rej_any     = rej_any + 1
		if (remaining[k] == 1) {
		  rej_one   = rej_one + 1
		}
	  }
	}
  }
  return((rej_any, rej_one)/replicates)
}

end
