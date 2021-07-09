*! Author(s) : Michael J Grayling
*! Date      : 31 Jan 2019
*! Version   : 0.9

/* Version history:
   31/01/19 v0.9 Initial version complete.
*/

/* To do:
   - Add option for plotting.
*/

program define sim_mams, rclass
version 15.0
syntax , l(numlist miss) u(numlist miss) [n(integer 39) tau(numlist) ///
         sd(real 1) RATio(real 1) SEParate REPlicates(integer 100000)]

preserve

///// Check input variables ////////////////////////////////////////////////////

local lentau:list sizeof tau
local lenl:list sizeof l
local lenu:list sizeof u
if (`lenl' != `lenu') {
  di "{error}The lower and upper stopping boundaries (l and u) must be numlists"
  di " of the same length."
  exit(198)
}
forvalues i = 1/`lenl' {
  local li:word `i' of `l'
  local ui:word `i' of `u'
  if (`i' < `lenl') {
    if ((`li' != .) & (`ui' != .)) {
      if (`li' >= `ui') {
        di "{error}Each lower interim stopping boundary (in l) must be "
		di "strictly less than the corresponding upper interim stopping "
		di "boundary (in u)."
        exit(198)
      }
    }
  }
  else {
    if (`li' != `ui') {
      di "{error}The final lower stopping boundary (in l) must be equal to the "
	  di "final upper stopping boundary (in u)."
      exit(198)
    }
  }
}
if (`n' < 1) {
  di "{error}The stage-wise group size in the control arm (n) must be an "
  di "integer greater than or equal to 1."
  exit(198)
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

if (`lentau' > 0) {
  local matatau ""
  foreach i of local tau {
    if "`matatau'" == "" local matatau "`i'"
    else local matatau "`matatau',`i'"
  }
  mat tau = (`matatau')
}
else {
  mat tau = J(1, 3, 0)
}
local matal ""
foreach i of local l {
  if "`matal'" == "" local matal "`i'"
  else local matal "`matal',`i'"
}
mat l     = (`matal')
local matau ""
foreach i of local u {
  if "`matau'" == "" local matau "`i'"
  else local matau "`matau',`i'"
}
mat u     = (`matau')
mata: sim_mams_void(`n', `sd', `ratio', "`separate'", `replicates')

///// Output ///////////////////////////////////////////////////////////////////

return scalar max_N = opchar[1, 7]
return scalar min_N = opchar[1, 6]
return scalar MSS   = opchar[1, 5]
return scalar SDSS  = opchar[1, 4]
return scalar ESS   = opchar[1, 3]
return scalar P_H1  = opchar[1, 2]
return scalar P_HA  = opchar[1, 1]

restore

end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void sim_mams_void(real scalar n, real scalar sd, real scalar ratio,
                   string separate, real scalar replicates) {
  tau   = st_matrix("tau")
  l     = st_matrix("l")
  u     = st_matrix("u")
  K     = length(tau)
  J     = length(l)
  printf("{txt}{dup 54:{c -}}\n")
  printf("{inp}%g{txt}-stage {inp}%g{txt}-experimental treatment MAMS trial ",
         J, K)
  printf("simulation\n")
  printf("{dup 54:{c -}}\n")
  printf("The hypotheses to be tested will be:\n\n")
  if (K == 1) {
    printf("   H1: τ{inp}1{txt} = μ1 - μ0 ≤ 0.\n\n")
  }
  else if (K == 2) {
    printf("   Hk: τk = μk - μ0 ≤ 0, k = 1, {inp}2{txt}.\n\n")
  }
  else if (K == 3) {
    printf("   Hk: τk = μk - μ0 ≤ 0, k = 1, 2, {inp}3{txt}.\n\n")
  }
  else {
    printf("   Hk: τk = μk - μ0 ≤ 0, k = 1, ..., {inp}%g{txt}.\n\n", K)
  }
  printf("The stage-wise group size in the control arm, n, will be: ")
  printf("{inp}%g{txt}.\n\n", n)
  printf("The stage-wise allocation ratio between the (remaining) experimental")
  printf(" arms and\nthe shared control arm, ratio, will be: {inp}%g{txt}.\n\n",
         ratio)
  printf("The lower stopping boundaries, l, will be: ")
  for (j = 1; j <= J; j++) {
    if (j == 1) {
      printf("{inp}(%g, ", round(l[j], .01))
    }
    else if ((j > 1) & (j < J)) {
      printf("%g, ", round(l[j], .01))
    }
    else {
      printf("%g){txt}.\n\n", round(l[j], .01))
    }
  }
  printf("The upper stopping boundaries, u, will be: ")
  for (j = 1; j <= J; j++) {
    if (j == 1) {
      printf("{inp}(%g, ", round(u[j], .01))
    }
    else if ((j > 1) & (j < J)) {
      printf("%g, ", round(u[j], .01))
    }
    else {
      printf("%g){txt}.\n\n", round(u[j], .01))
    }
  }
  printf("The trial will be simulated under the scenario where:\n\n")
  if (K == 1) {
    printf("   τ = τ{inp}1{txt} = {inp}%g{txt}.\n\n", tau)
  }
  else if (K == 2) {
    printf("   τ = (τ1, τ{inp}2{txt}) = {inp}(%g, %g){txt}.\n\n",
	       tau[1], tau[2])
  }
  else {
    printf("   τ = (")
	for (k = 1; k <= K - 1; k++) {
	  printf("τ%g, ", k)
	}
	printf("τ{inp}%g{txt}) = {inp}(", K)
	for (k = 1; k <= K - 1; k++) {
	  printf("%g, ", tau[k])
	}
	printf("%g){txt}.\n\n", tau[K])
  }
  printf("Beginning the required simulations.\n\n")
  opchar = sim_mams_mata(tau, n, l, u, sd, ratio, separate, replicates, K, J)
  printf("Completed the required simulations.\n\n")
  printf("The estimated operating characteristics of the trial are:\n\n")
  printf("   r()   | Variable\n")
  printf("   {dup 5:{c -}}   {dup 8:{c -}}\n")
  printf("   P_HA  | P_HA(tau) = {res}%g{txt},\n", round(opchar[1], .0001))
  printf("   P_H1  | P_H1(tau) = {res}%g{txt},\n", round(opchar[2], .0001))
  printf("   ESS   | ESS(tau)  = {res}%g{txt},\n", round(opchar[3], .01))
  printf("   SDSS  | SDSS(tau) = {res}%g{txt},\n", round(opchar[4], .01))
  printf("   MSS   | MSS(tau)  = {res}%g{txt},\n", round(opchar[5], .01))
  printf("   min_N | min N     = {res}%g{txt},\n", opchar[6])
  printf("   max_N | max N     = {res}%g{txt}.", opchar[7])
  st_matrix("opchar", opchar)
}

real vector sim_mams_mata(real vector tau, real scalar n, real vector l,
                          real vector u, real scalar sd, real scalar ratio,
						  string separate, real scalar replicates,
					      real scalar K, real scalar J) {
  seq_J                     = 1::J
  seq_K                     = 1::K
  r0n                       = seq_J*n
  r0n_diff                  = r0n :- (0 \ r0n[1::(J - 1)])
  sd_sqrt_r0n_diff          = sd*sqrt(r0n_diff)
  r                         = seq_J*ratio
  rn                        = r*n
  rn_mat                    = J(1, K, rn)
  rn_diff                   = r0n_diff*ratio
  sd_sqrt_rn_diff           = J(1, K, sd*sqrt(rn_diff))
  rn_diff_tau               = rn_diff*tau
  denominator               = (sd*sqrt((J(1, K, r) :+ J(1, K, seq_J)):/
                                         (J(1, K, rn):*J(1, K, seq_J))))
  one_1K                    = J(1, K, 1)
  rej_any                   = rej_one = 0
  sample_size               = J(replicates, 1, 0)
  if (separate == "") {
    for (i = 1; i <= replicates; i++) {
	  hat_mu_k              = rnormal(J, K, 0, 1):*sd_sqrt_rn_diff :+  
                                rn_diff_tau
      for (k = 1; k <= K; k++) {
	    hat_mu_k[, k]       = runningsum(hat_mu_k[, k])
      }
	  Z_jk                  =
	    (hat_mu_k:/rn_mat :-
		   J(1, K, runningsum(rnormal(1, 1, 0, sd_sqrt_r0n_diff)):/r0n)):/
	      denominator
	  remaining             = seq_K
	  remaining_num         = K
	  remaining_logical     = one_1K
	  for (j = 1; j <= J; j++) {
	    sample_size[i]      = sample_size[i] + r0n_diff[j] +
		                        remaining_num*rn_diff[j]
		if (max(Z_jk[j, remaining]) > u[j]) {
		  rej_any           = rej_any + 1
		  rej_one           = rej_one + ((remaining_logical[1] == 1) &
		                                    (Z_jk[j, 1] > u[j]))
		  break
		}
		else if (max(Z_jk[j, remaining]) <= l[j]) {
		  break
		}
		else if (j < J) {
		  remaining_logical = ((Z_jk[j, ] :> l[j]) :& (remaining_logical))
		  remaining         = which_condition(remaining_logical, "e", 1)
		  remaining_num     = sum(remaining_logical)
		}
	  }
    }
  }
  else {
    zero_JK                 = J(J, K, 0)
    for (i = 1; i <= replicates; i++) {
	  rej_mat               = zero_JK
      hat_mu_k              = rnormal(J, K, 0, 1):*sd_sqrt_rn_diff :+  
                                rn_diff_tau
      for (k = 1; k <= K; k++) {
	    hat_mu_k[, k]  = runningsum(hat_mu_k[, k])
      }
	  Z_jk                  =
	    (hat_mu_k:/rn_mat :-
		   J(1, K, runningsum(rnormal(1, 1, 0, sd_sqrt_r0n_diff)):/r0n)):/
	      denominator
	  remaining             = seq_K
	  remaining_num         = K
	  remaining_logical     = one_1K
	  for (j = 1; j <= J; j++) {
		sample_size[i]      = sample_size[i] + r0n_diff[j] +
		                        remaining_num*rn_diff[j]
		for (k = 1; k <= remaining_num; k++) {
		  if (Z_jk[j, remaining[k]] > u[j]) {
		    rej_mat[j, remaining[k]] = 1
		  }
		}
		if ((j == J) | all((Z_jk[j, remaining] :> u[j]) :|
		                     (Z_jk[j, remaining] :<= l[j]))) {
		  rej_any           = rej_any + (sum(rej_mat) > 0)
		  rej_one           = rej_one + (sum(rej_mat[, 1]) > 0)
		  break
		}
		else {
		  remaining_logical = ((Z_jk[j, ] :> l[j]) :& (Z_jk[j, ] :<= u[j]) :&
								 (remaining_logical))
		  remaining         = which_condition(remaining_logical, "e", 1)
		  remaining_num     = sum(remaining_logical)
		}
	  }
    }
  }
  ess                       = mean(sample_size)
  sort_sample_size          = sort(sample_size, 1)
  unique_sample_size        = uniqrows(sample_size)
  prob_unique_sample_size   = J(length(unique_sample_size), 1, 0)
  return((rej_any/replicates, rej_one/replicates, mean(sample_size),
          sqrt(sum((sample_size :- ess):^2)/(replicates - 1)),
		  0.5*(sort_sample_size[ceil(0.5*replicates)] +
		         sort_sample_size[ceil(0.5*replicates + 1)]), min(sample_size),
		  max(sample_size)))
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
