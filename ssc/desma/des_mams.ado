*! Author(s) : Michael J Grayling
*! Date      : 31 Jan 2019
*! Version   : 0.9

/* Version history:
   31/01/19 v0.9 Complete.
*/

/* To do:

   - Add option for plotting.
   - Add option for quantile substitution.
   - Add option for unequal spacing of interim analyses and different ratios in
     each stage.
   - Allow different sd in each arm.
 
*/

program define des_mams, rclass
version 15.0
syntax , [k(integer 3) j(integer 2) ALPha(real 0.05) beta(real 0.2) ///
          DELta(real 0.5) delta0(real 0) sd(real 1) RATio(real 1) ///
		  LSHape(string) USHape(string) lfix(real 0) ufix(real 2) SEParate ///
		  NO_sample_size n_start(integer 1) n_stop(integer -1)]

preserve

///// Check input variables ////////////////////////////////////////////////////

if ("`lshape'" == "") {
  local lshape "pocock"
}
if ("`ushape'" == "") {
  local ushape "`lshape'"
}
if (`k' < 1) {
  di "{error}The number of experimental arms (k) must be an integer greater "
  di "than or equal to 1."
  exit(198)
}
if (`j' < 2) {
  di "{error}The maximum number of allowed stages (j) must be an integer "
  di "greater than or equal to 2."
  exit(198)
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
if (("`lshape'" != "fixed") & ("`lshape'" != "obf") & ///
      ("`lshape'" != "pocock") & ("`lshape'" != "triangular")) {
  di "{error}The lower stopping boundary shape (lshape) must be one of fixed, "
  di "obf, pocock, or triangular."
  exit(198)
}
if (("`ushape'" != "fixed") & ("`ushape'" != "obf") & ///
      ("`ushape'" != "pocock") & ("`ushape'" != "triangular")) {
  di "{error}The upper stopping boundary shape (ushape) must be one of fixed, "
  di "obf, pocock, or triangular."
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
if (("`lshape'" == "fixed") & ("`ushape'" == "fixed") & (`ufix' <= `lfix')) {
  di "{error}The fixed upper stopping boundary value (ufix) must be strictly "
  di "greater than the fixed lower stopping boundary value (lfix) when both "
  di "boundary shapes are fixed (lshape and ushape)."
  exit(198)
}
if ((`delta0' >= `delta') & ("`separate'" == "")) {
  di "WARNING: For designs with a simultaneous stopping rule, the uninteresting"
  di "treatment effect (delta0) should in general be strictly smaller than the "
  di "interesting treatment effect (delta)."
}
if (("`lshape'" != "fixed") & (`lfix' != 0)) {
  di "WARNING: lfix has been changed from default but this will have no effect "
  di "given the choice of lshape."
}
if (("`ushape'" != "fixed") & (`ufix' != 2)) {
  di "WARNING: ufix has been changed from default but this will have no effect "
  di "given the choice of ushape."
}
if (("`separate'" != "") & (`delta0' != 0)) {
  di "WARNING: delta0 has been changed from default but this will have no "
  di "effect given the choice of separate."
}
if ((`k' == 1) & (`delta0' != 0)) {
  di "WARNING: delta0 has been changed from default but this will have no "
  di "effect given the choice of k."
}
if ((`k' == 1) & ("`separate'" != "")) {
  di "WARNING: separate has been changed from default but this will have no "
  di "effect given the choice of k."
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

mata: des_mams_void(`k', `j', `alpha', `beta', `delta', `delta0', `sd', ///
                    `ratio', "`lshape'", "`ushape'", `lfix', `ufix', ///
					"`separate'", "`no_sample_size'", `n_start', `n_stop')

///// Output ///////////////////////////////////////////////////////////////////

return mat    u        = u
return mat    l        = l
return scalar max_N    = opchar[1, 10]
return scalar min_N    = opchar[1, 9]
return scalar MSS_LFC  = opchar[1, 8]
return scalar MSS_HG   = opchar[1, 7]
return scalar SDSS_LFC = opchar[1, 6]
return scalar SDSS_HG  = opchar[1, 5]
return scalar ESS_LFC  = opchar[1, 4]
return scalar ESS_HG   = opchar[1, 3]
return scalar P_LFC    = opchar[1, 2]
return scalar P_HG     = opchar[1, 1]
return scalar n        = n[1, 1]

restore

end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void des_mams_void(real scalar K, real scalar J, real scalar alpha,
                   real scalar beta, real scalar delta, real scalar delta0,
			       real scalar sd, real scalar ratio, string lshape,
				   string ushape, real scalar lfix, real scalar ufix,
				   string separate, string no_sample_size, real scalar n_start,
				   real scalar n_stop) {
  printf("{txt}{dup 50:{c -}}\n")
  printf("{inp}%g{txt}-stage {inp}%g{txt}-experimental treatment MAMS ", J, K)
  printf("trial design\n")
  printf("{dup 50:{c -}}\n")
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
  printf("The stopping boundaries will be determined to control the ")
  printf("familywise error-rate\nunder the global null hypothesis, HG, ")
  printf("given by:\n\n")
  if (K == 1) {
    printf("   HG: τ{inp}1{txt} = 0.\n\n")
  }
  else if (K == 2) {
    printf("   HG: τ1 = τ{inp}2{txt} = 0.\n\n")
  }
  else if (K == 3) {
    printf("   HG: τ1 = τ2 = τ{inp}3{txt} = 0.\n\n")
  }
  else {
    printf("   HG: τ1 = ... = τ{inp}%g{txt} = 0.\n\n", K)
  }
  printf("Specifically, if P_HA() is the power function for rejecting any null")
  printf(" hypothesis,\nthe stopping boundaries will be chosen such that:\n\n")
  printf("{txt}   P_HA(HG) ≤ α = {inp}%g{txt}.\n\n", alpha)
  if (no_sample_size == "") {
    printf("The required sample size will be determined to control the type-II")
	printf(" error-rate\nunder the least favourable configuration, LFC, given ")
	printf("by:\n\n")
	if (K == 1) {
      printf("   LFC: τ{inp}1{txt} = δ = %g.\n\n", delta)
    }
    else if (K == 2) {
      printf("   LFC: τ1 = δ = {inp}%g{txt}, τ{inp}2{txt} = δ0 = ", delta)
	  printf("{inp}%g{txt}.\n\n", delta0)
    }
    else if (K == 3) {
      printf("   LFC: τ1 = δ = {inp}%g{txt}, τ2 = τ{inp}3{txt} = δ0 = ", delta)
	  printf("{inp}%g{txt}.\n\n", delta0)
    }
    else {
      printf("   LFC: τ1 = δ = {inp}%g{txt}, τ2 = ... = τ{inp}%g{txt} = ",
	         delta, K)
      printf("δ0 = {inp}%g{txt}.\n\n", delta0)
    }
	printf("Specifically, if P_H1() is the power function for rejecting H1, ")
	printf("the sample size\nwill be chosen such that:\n\n")
	printf("   P_H1(LFC) ≥ 1 - β = 1 - {inp}%g{txt}.\n\n", beta)
  }
  else {
    printf("The required sample size {inp}will not{txt} be determined.\n\n")
  }
  printf("The stage-wise allocation ratio between the (remaining) experimental")
  printf(" arms and\nthe shared control arm, ratio, will be: {inp}%g{txt}:1.",
         ratio)
  printf("\n\n")
  if (lshape == "fixed") {
    printf("The lower stopping boundary shape will be: ")
	printf("{inp}fixed{txt}.\n\n")
  }
  else if (lshape == "obf") {
    printf("The lower stopping boundary shape will be: ")
	printf("{inp}O'Brien-Fleming{txt}.\n\n")
  }
  else if (lshape == "pocock") {
    printf("The lower stopping boundary shape will be: ")
	printf("{inp}Pocock{txt}.\n\n")
  }
  else {
    printf("The lower stopping boundary shape will be: ")
	printf("{inp}triangular{txt}.\n\n")
  }
  if (ushape == "fixed") {
    printf("The upper stopping boundary shape will be:")
	printf("{inp}fixed{txt}.\n\n")
  }
  else if (ushape == "obf") {
    printf("The upper stopping boundary shape will be: ")
	printf("{inp}O'Brien-Fleming{txt}.\n\n")
  }
  else if (ushape == "pocock") {
    printf("The upper stopping boundary shape will be: ")
	printf("{inp}Pocock{txt}.\n\n")
  }
  else {
    printf("The upper stopping boundary shape will be: ")
	printf("{inp}triangular{txt}.\n\n")
  }
  if (separate != "") {
    printf("The stopping rule will be: {inp}separate{txt}.\n\n")
  }
  else {
    printf("The stopping rule will be: {inp}simultaneous{txt}.\n\n")
  }
  printf("Now determining the stopping boundaries.\n\n")
  a                                  = b = c = 1
  if (separate != "") {
    d                                = K
  }
  else {
    d                                = 1
  }
  delta_1                            = delta
  delta_0                            = delta0
  seq_K                              = 1::K
  if (J == K) {
    seq_J                            = seq_K
  } else {
    seq_J                            = 1::J
  }
  if (c == K) {
    seq_c                            = seq_K
  } else if (c == J) {
    seq_c                            = seq_J
  } else {
    seq_c                            = 1::c
  }
  if (K - c == J) {
    seq_K_min_c                      = seq_J
  } else if (K - c == c) {
    seq_K_min_c                      = seq_c
  } else {
    seq_K_min_c                      = 1::(K - c)
  }
  cardinality_xi                     = J(2, 1, 0)
  xi_HG                              = perm_combs(1::(2*J), K, 0, 1)
  cardinality_xi[1]                  = rows(xi_HG)
  psi_HG                             = (mod(xi_HG, 2) :== 0)
  omega_HG                           = ceil(0.5*xi_HG)
  if (d < K) {
    retain                           = J(cardinality_xi[1], 1, 1)
    for (i = 1; i <= cardinality_xi[1]; i++) {
      for (j = 1; j <= J; j++) {
        le                           = which_condition(omega_HG[i, seq_K], "le",
		                                               j)
        g                            = which_condition(omega_HG[i, seq_K], "g",
		                                               j)
	    if ((length(le) > 0) & (length(g) > 0)) {
	      if (sum(psi_HG[i, le]) >= d) {
	        retain[i]                = 0
		    break
	      }
	    }
      }
    }
    rows_keep                        = which_condition(retain, "e", 1)
    xi_HG                            = xi_HG[rows_keep, ]
    psi_HG                           = psi_HG[rows_keep, ]
    omega_HG                         = omega_HG[rows_keep, ]
    cardinality_xi[1]                = rows(xi_HG)
  }
  deg_xi_HG                          = deg_a_fwer_xi_HG = J(cardinality_xi[1],
                                                            1, 0)
  for (i = 1; i <= cardinality_xi[1]; i++) {
    deg_xi_HG[i]                     = rows(perm_combs(xi_HG[i, ]', K, 1, 0))
  }
  a_fwer_indices                     =
    which_condition(rowsum(mod(xi_HG, 2) :== 0), "ge", a)
  deg_a_fwer_xi_HG[a_fwer_indices]   = deg_xi_HG[a_fwer_indices]
  xi_HG                              = (psi_HG, omega_HG, deg_xi_HG,
                                        deg_a_fwer_xi_HG,
	  								    ratio*rowsum(omega_HG) +
					                      rowmax(omega_HG),
					                    J(cardinality_xi[1], 1, 0))
  xi_LFC_eff                         = perm_combs(1::(2*J), c, 0, 1)
  psi_LFC_eff                        = (mod(xi_LFC_eff, 2) :== 0)
  omega_LFC_eff                      = ceil(0.5*xi_LFC_eff)
  cardinality_xi[2]                  = rows(xi_LFC_eff)
  if (c > d) {
    retain                           = J(cardinality_xi[2], 1, 1)
    for (i = 1; i <= cardinality_xi[2]; i++) {
      for (j = 1; j <= J; j++) {
        le                           = which_condition(omega_LFC_eff[i, seq_c],
		                                               "le", j)
        g                            = which_condition(omega_LFC_eff[i, seq_c],
		                                               "g", j)
	    if ((length(le) > 0) & (length(g) > 0)) {
	      if (sum(psi_LFC_eff[i, le]) >= d) {
	        retain[i]                = 0
		    break
	      }
	    }
      }
    }
    xi_LFC_eff                       =
	  xi_LFC_eff[which_condition(retain, "e", 1), ]
    cardinality_xi[2]                = rows(xi_LFC_eff)
  }
  deg_xi_LFC_eff                     = deg_bc_power_xi_LFC_eff =
    J(cardinality_xi[2], 1, 0)
  for (i = 1; i <= cardinality_xi[2]; i++) {
    deg_xi_LFC_eff[i]                = rows(perm_combs(xi_LFC_eff[i, ]', c, 1,
	                                                   0))
  }
  bc_power_indices                   =
    which_condition(rowsum(mod(xi_LFC_eff, 2) :== 0), "ge", b)
  deg_bc_power_xi_LFC_eff[bc_power_indices] = deg_xi_LFC_eff[bc_power_indices]
  if (c < K) {
    xi_LFC_fut                       = perm_combs(1::(2*J), K - c, 0, 1)
    psi_LFC_fut                      = (mod(xi_LFC_fut, 2) :== 0)
    omega_LFC_fut                    = ceil(0.5*xi_LFC_fut)
    cardinality_xi_LFC_fut           = rows(xi_LFC_fut)
    if (K - c > d) {
      retain                         = J(cardinality_xi_LFC_fut, 1, 1)
      for (i = 1; i <= cardinality_xi_LFC_fut; i++) {
        for (j = 1; j <= J; j++) {
          le                         =
		    which_condition(omega_LFC_fut[i, seq_K_min_c], "le", j)
          g                          =
		    which_condition(omega_LFC_fut[i, seq_K_min_c], "g", j)
	      if ((length(le) > 0) & (length(g) > 0)) {
	        if (sum(psi_LFC_fut[i, le]) >= d) {
	          retain[i]              = 0
			  break
	        }
	      }
        }
      }
	  xi_LFC_fut                     =
	    xi_LFC_fut[which_condition(retain, "e", 1), ]
      cardinality_xi_LFC_fut         = rows(xi_LFC_fut)
    }
    deg_xi_LFC_fut                   = J(cardinality_xi_LFC_fut, 1, 0)
    for (i = 1; i <= cardinality_xi_LFC_fut; i++) {
      deg_xi_LFC_fut[i]              = rows(perm_combs(xi_LFC_fut[i, ]', K - c,
	                                                   1, 0))
    }
    cardinality_xi_LFC_eff           = cardinality_xi[2]
    cardinality_xi[2]                = cardinality_xi[2]*cardinality_xi_LFC_fut
    xi_LFC                           = J(cardinality_xi[2], K, 0)
    for (i = 1; i <= cardinality_xi_LFC_eff; i++) {
      index_range                    =
	    (1 + (i - 1)*cardinality_xi_LFC_fut)::(i*cardinality_xi_LFC_fut)
	  xi_LFC[index_range, ]          = (J(cardinality_xi_LFC_fut, 1,
	                                      xi_LFC_eff[i, ]), xi_LFC_fut)
    }
    omega_LFC                        = ceil(0.5*xi_LFC)
	xi_LFC                           =
      (mod(xi_LFC, 2) :== 0, omega_LFC,
	   vec(J(cardinality_xi_LFC_fut, 1, deg_xi_LFC_eff)'):*
         vec(J(cardinality_xi_LFC_eff, 1, deg_xi_LFC_fut)'),
	   vec(J(1, cardinality_xi_LFC_fut, deg_bc_power_xi_LFC_eff)'):*
         vec(J(cardinality_xi_LFC_eff, 1, deg_xi_LFC_fut)'),
       ratio*rowsum(omega_LFC) + rowmax(omega_LFC), J(cardinality_xi[2], 1, 0))
    if (d < K) {
      retain                         = J(cardinality_xi[2], 1, 1)
      for (i = 1; i <= cardinality_xi[2]; i++) {
        for (j = 1; j <= J; j++) {
          le                         = which_condition(xi_LFC[i, K :+ seq_K],
		                                               "le", j)
          g                          = which_condition(xi_LFC[i, K :+ seq_K],
		                                               "g", j)
	      if ((length(le) > 0) & (length(g) > 0)) {
	        if (sum(xi_LFC[i, le]) >= d) {
	          retain[i]              = 0
			  break
	        }
	      }
        }
      }
	  xi_LFC                         = xi_LFC[which_condition(retain, "e", 1), ]
      cardinality_xi[2]              = rows(xi_LFC)
    }
  }
  else {
    omega_LFC                        = ceil(0.5*xi_LFC_eff)
    xi_LFC                           =
      (mod(xi_LFC_eff, 2) :== 0, omega_LFC, deg_xi_LFC_eff,
       deg_bc_power_xi_LFC_eff, ratio*rowsum(omega_LFC) + rowmax(omega_LFC),
	   J(cardinality_xi[2], 1, 0))
  }
  Lambda                             = J(K*J, K*J, 0)
  add                                = ratio/(ratio + 1)
  minus                              = 1 - add
  Lambda_j                           = J(K, K, add) + I(K)*minus
  for (j = 1; j <= J; j++) {
    index_range                      = (1 + (j - 1)*K)::(j*K)
    Lambda[index_range, index_range] = Lambda_j
  }
  if (J > 1) {
    for (j1 = 1; j1 <= J; j1++) {
      for (j2 = 1; j2 <= j1 - 1; j2++) {
	    range_j1                     = (1 + (j1 - 1)*K)::(j1*K)
        range_j2                     = (1 + (j2 - 1)*K)::(j2*K)
	    Lambda[range_j2, range_j1]   = Lambda[range_j1, range_j2] =
		  sqrt(j2/j1)*Lambda_j
	  }
    }
  }
  sqrt_I_div_n                            =
    vec(J(K, 1, sqrt((1/(sd^2 + sd^2/ratio))*seq_J')))
  means_HG                           = J(cardinality_xi[1], 1, 0)
  l_indices_HG                       = u_indices_HG = Lambdas_HG =
    J(cardinality_xi[1], J*K, 0)
  for (i = 1; i <= cardinality_xi[1]; i++) {
	relevant_indices                 = .
    psi                              = xi_HG[i, seq_K]
    omega                            = xi_HG[i, K :+ seq_K]
    max_omega                        = max(omega)
    sum_omega                        = sum(omega)
	vec_omega                        = 1::sum_omega
    l_i                              = u_i = J(1, J*K, 0)
    for (k = 1; k <= K; k++) {
	  indices_k                      = range(k, k + (omega[k] - 1)*K, K)'
	  relevant_indices               = (relevant_indices, indices_k)
	  l_i_k                          = u_i_k = J(1, omega[k], 0)
	  for (j = 1; j <= omega[k]; j++) {
	    if (omega[k] > j) {
	      l_i_k[j]                   = j
	    }
	    else if ((psi[k] == 0) & (omega[k] == j)) {
	      l_i_k[j]                   = 2*J + 1
	    }
	    else {
	      l_i_k[j]                   = J + j
	    }
		if ((psi[k] == 1) & (omega[k] == j)) {
	      u_i_k[j]                   = 2*J + 2
	    }
	    else if ((omega[k] > j) |
		           ((psi[k] == 0) & (omega[k] == j) & (max_omega == j) &
			  		  (length(which_condition(psi, "e", 1)) >= d))) {
	      u_i_k[j]                   = J + j
	    }
		else {
		  u_i_k[j]                   = j
		}
	  }
	  l_i[indices_k]                 = l_i_k
	  u_i[indices_k]                 = u_i_k
    }
    sort_indices                     =
      sort(relevant_indices[vec_omega :+ 1]', 1)'
    means_HG[i]                      = sum_omega
    l_indices_HG[i, vec_omega]       = l_i[sort_indices]
    u_indices_HG[i, vec_omega]       = u_i[sort_indices]
    Lambdas_HG[i, vec_omega]         = sort_indices
  }
  delta_LFC                          = J(1, J, (J(1, c, delta_1),
                                                J(1, K - c, delta_0)))
  dim_LFC                            = J(rows(xi_LFC), 1, 0)
  means_div_sqrt_n_LFC               = l_indices_LFC = u_indices_LFC =
    Lambdas_LFC                      = J(rows(xi_LFC), J*K, 0)
  for (i = 1; i <= rows(xi_LFC); i++) {
	relevant_indices                 = .
    psi                              = xi_LFC[i, seq_K]
    omega                            = xi_LFC[i, K :+ seq_K]
    max_omega                        = max(omega)
    sum_omega                        = sum(omega)
	vec_omega                        = 1::sum_omega
    l_i                              = u_i = J(1, J*K, 0)
    for (k = 1; k <= K; k++) {
      indices_k                      = range(k, k + (omega[k] - 1)*K, K)'
	  relevant_indices               = (relevant_indices, indices_k)
	  l_i_k                          = u_i_k = J(1, omega[k], 0)
	  for (j = 1; j <= omega[k]; j++) {
	    if (omega[k] > j) {
	      l_i_k[j]                   = j
	    }
	    else if ((psi[k] == 0) & (omega[k] == j)) {
	      l_i_k[j]                   = 2*J + 1
	    }
	    else {
	      l_i_k[j]                   = J + j
	    }
	    if ((psi[k] == 1) & (omega[k] == j)) {
	      u_i_k[j]                   = 2*J + 2
	    }
	    else if ((omega[k] > j) |
		           ((psi[k] == 0) & (omega[k] == j) & (max_omega == j) &
			  		  (length(which_condition(psi, "e", 1)) >= d))) {
	      u_i_k[j]                   = J + j
	    }
		else {
		  u_i_k[j]                   = j
		}
	  }
	  l_i[indices_k]                 = l_i_k
	  u_i[indices_k]                 = u_i_k
    }
    dim_LFC[i]                       = sum_omega
	sort_indices                     =
      sort(relevant_indices[vec_omega :+ 1]', 1)'
    means_div_sqrt_n_LFC[i, vec_omega] = delta_LFC[sort_indices]:*
                                           (sqrt_I_div_n[sort_indices]')
    l_indices_LFC[i, vec_omega]      = l_i[sort_indices]
    u_indices_LFC[i, vec_omega]      = u_i[sort_indices]
    Lambdas_LFC[i, vec_omega]        = sort_indices
  }
  xi_HG_all                          = xi_HG
  means_HG_all                       = means_HG
  l_indices_HG_all                   = l_indices_HG
  u_indices_HG_all                   = u_indices_HG
  Lambdas_HG_all                     = Lambdas_HG
  xi_LFC_all                         = xi_LFC
  means_div_sqrt_n_LFC_all           = means_div_sqrt_n_LFC
  l_indices_LFC_all                  = l_indices_LFC
  u_indices_LFC_all                  = u_indices_LFC
  Lambdas_LFC_all                    = Lambdas_LFC
  dim_LFC_all                        = dim_LFC
  cardinality_xi_all                 = (rows(xi_HG_all), rows(xi_LFC_all))
  keep_HG                            = which_condition(xi_HG[, 2*K + 2], "g", 0)
  xi_HG                              = xi_HG[keep_HG, ]
  means_HG                           = means_HG[keep_HG]
  l_indices_HG                       = l_indices_HG[keep_HG, ]
  u_indices_HG                       = u_indices_HG[keep_HG, ]
  Lambdas_HG                         = Lambdas_HG[keep_HG, ]
  keep_LFC                           = which_condition(xi_LFC[, 2*K + 2], "g",
                                                       0)
  xi_LFC                             = xi_LFC[keep_LFC, ]
  means_div_sqrt_n_LFC               = means_div_sqrt_n_LFC[keep_LFC, ]
  l_indices_LFC                      = l_indices_LFC[keep_LFC, ]
  u_indices_LFC                      = u_indices_LFC[keep_LFC, ]
  Lambdas_LFC                        = Lambdas_LFC[keep_LFC, ]
  dim_LFC                            = dim_LFC[keep_LFC]
  cardinality_xi                     = (rows(xi_HG), rows(xi_LFC))
  C                                  =
    brent_root_C(K, J, alpha, ratio, lshape, ushape, lfix, ufix, Lambda, xi_HG,
	             means_HG, l_indices_HG, u_indices_HG, Lambdas_HG,
				 cardinality_xi)[1]
  if (ushape == "obf") {
    u                                = C*sqrt(J:/seq_J)
  }
  else if (ushape == "pocock") {
    u                                = J(J, 1, C)
  }
  else if (ushape == "fixed") {
    u                                = (J(J - 1, 1, ufix) \ C)
  }
  else if (ushape == "triangular") {
    u                                = C*(1 :+ seq_J/J):/sqrt(ratio*seq_J)
  }
  if (lshape == "obf") {
    l                                = (-C*sqrt(J:/(1::(J - 1))) \ u[J])
  }
  else if (lshape == "pocock") {
    l                                = (J(J - 1, 1, -C) \ u[J])
  }
  else if (lshape == "fixed") {
    l                                = (J(J - 1, 1, lfix) \ u[J])
  }
  else if (lshape == "triangular") {
    if (ushape == "triangular") {
	  l                              = -C*(1 :- 3*seq_J/J):/sqrt(ratio*seq_J)
	}
	else {
	  l                              =
	  -C*((1 :- 3*seq_J/J):/sqrt(ratio*seq_J))/(2/sqrt(J))
	}
  }
  printf("Lower stopping boundaries, l, determined to be: ")
  for (j = 1; j <= J; j++) {
    if (j == 1) {
      printf("{res}(%g, ", round(l[j], .01))
    }
    else if ((j > 1) & (j < J)) {
      printf("%g, ", round(l[j], .01))
    }
    else {
      printf("%g){txt}.\n\n", round(l[j], .01))
    }
  }
  printf("Upper stopping boundaries, u, determined to be: ")
  for (j = 1; j <= J; j++) {
    if (j == 1) {
      printf("{res}(%g, ", round(u[j], .01))
    }
    else if ((j > 1) & (j < J)) {
      printf("%g, ", round(u[j], .01))
    }
    else {
      printf("%g){txt}.\n\n", round(u[j], .01))
    }
  }
  if (no_sample_size == "") {
    printf("Now determining the required sample size.\n\n")
    bounds                           = (l \ u \ . \ .)
	if (n_stop == -1) {
	  q                              = invmvnormal_mata(1 - alpha, J(1, K, 0),
	                                                    Lambda_j, "lower", 100,
	                                                    1e-4, "pmvnormal", 12,
									  		  	        1000)[1]												   
	  n_stop                         =
	    ceil((sd*(q*sqrt(1 + 1/ratio) +
		            invnormal(1 - beta)*sqrt(1 + 1/ratio))/delta)^2)
	  while (mod(ratio*n_stop, 1) != 0) {
	    n_stop                       = n_stop + 1
	  }
	}
	if (n_stop < n_start) {
	  printf("{err}Computed value of n_stop is smaller than the specified ")
	  printf("value of n_start.\n")
      exit(198)
    }
	power_check                      = 0
	n                                = n_start
	while (mod(ratio*n, 1) != 0) {
	  n                              = n + 1
	}
	if (separate != "") {
	  means_div_sqrt_n               =
		delta*sqrt(seq_J*(1 + 1/ratio)^-1)/sd
      Lambda1                        = I(J)
      for (j1 = 2; j1 <= J; j1++) {
        for (j2 = 1; j2 <= j1 - 1; j2++) {
	      Lambda1[j2, j1]            = Lambda1[j1, j2] = sqrt(j2/j1)
	    }
      }
      while ((power_check == 0) & (n <= n_stop)) {
	    power_check                  =
		  (mams_find_n_sep(n, J, beta, l, u, means_div_sqrt_n, Lambda1) < 0)
		n                            = n + 1
		while (mod(ratio*n, 1) != 0) {
	      n                          = n + 1
	    }
	  }
	}
	else {
	  while ((power_check == 0) & (n <= n_stop)) {
	    power_check                  =
		  (mams_find_n_sim(n, bounds, K, J, beta, Lambda, xi_LFC,
			               means_div_sqrt_n_LFC, l_indices_LFC, u_indices_LFC,
						   Lambdas_LFC, dim_LFC, cardinality_xi) < 0)
		n                            = n + 1
		while (mod(ratio*n, 1) != 0) {
	      n                          = n + 1
	    }
	  }
	}
	if (n > n_stop) {
	  printf("{err}The group size was limited by n_stop. Consider increasing ")
      printf("its value and re-running des_mams.")
      exit(198)
	}
	if (n == n_start) {
	  printf("WARNING: The required power was met with n_start. Consider ")
      printf("decreasing its value and re-running des_mams.")
	}
	n                                = n - 1
	while (mod(ratio*n, 1) != 0) {
	  n                              = n - 1
	}
	printf("Required stage-wise group size in the control arm, n, determined ")
	printf("to be: {res}%g{txt}.\n\n", n)
	opchar                           =
	  (mams_opchar(n, bounds, K, J, Lambda, xi_HG_all, xi_LFC_all, means_HG_all,
	               l_indices_HG_all, u_indices_HG_all, Lambdas_HG_all,
				   means_div_sqrt_n_LFC_all, l_indices_LFC_all,
				   u_indices_LFC_all, Lambdas_LFC_all, dim_LFC_all,
				   cardinality_xi_all), n*(1 + ratio*K), n*J*(1 + ratio*K))
	printf("The operating characteristics of the design are:\n\n")
	printf("   r()      | Variable\n")
	printf("   {dup 8:{c -}}   {dup 8:{c -}}\n")
    printf("   P_HG     | P_HA(HG)  = {res}%g{txt},\n", round(opchar[1], .001))
    printf("   P_LFC    | P_H1(LFC) = {res}%g{txt},\n", round(opchar[2], .001))
	printf("   ESS_HG   | ESS(HG)   = {res}%g{txt},\n", round(opchar[3], .01))
    printf("   ESS_LFC  | ESS(LFC)  = {res}%g{txt},\n", round(opchar[4], .01))
	printf("   SDSS_HG  | SDSS(HG)  = {res}%g{txt},\n", round(opchar[5], .01))
    printf("   SDSS_LFC | SDSS(LFC) = {res}%g{txt},\n", round(opchar[6], .01))
	printf("   MSS_HG   | MSS(HG)   = {res}%g{txt},\n", round(opchar[7], .01))
    printf("   MSS_LFC  | MSS(LFC)  = {res}%g{txt},\n", round(opchar[8], .01))
	printf("   min_N    | min N     = {res}%g{txt},\n", opchar[9])
	printf("   max_N    | max N     = {res}%g{txt}.", opchar[10])
  }
  else {
    n                                = .
	opchar                           = J(1, 9, .)
  }
  st_matrix("n", n)
  st_matrix("l", l)
  st_matrix("u", u)
  st_matrix("opchar", opchar)
}

real colvector brent_root_C(real scalar K, real scalar J, real scalar alpha,
                            real scalar ratio, string lshape, string ushape,
							real lfix, real ufix, real matrix Lambda,
							real matrix xi_HG, real vector means_HG,
							real matrix l_indices_HG, real matrix u_indices_HG,
							real matrix Lambdas_HG,
							real vector cardinality_xi) {
  max_iter   = 100
  half_tol   = 5e-5
  a          = invnormal(1 - alpha)/2
  b          = 5
  fa         = mams_find_C(a, K, J, alpha, ratio, lshape, ushape, lfix, ufix,
                           Lambda, xi_HG, means_HG, l_indices_HG, u_indices_HG,
						   Lambdas_HG, cardinality_xi)
  fb         = mams_find_C(b, K, J, alpha, ratio, lshape, ushape, lfix, ufix,
                           Lambda, xi_HG, means_HG, l_indices_HG, u_indices_HG,
						   Lambdas_HG, cardinality_xi)
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
	fb       = mams_find_C(b, K, J, alpha, ratio, lshape, ushape, lfix, ufix,
	                       Lambda, xi_HG, means_HG, l_indices_HG, u_indices_HG,
						   Lambdas_HG, cardinality_xi)
  }
  return((b \ fb \ 1 \ max_iter))
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

real scalar mams_find_C(real scalar C, real scalar K, real scalar J,
                        real scalar alpha, real scalar ratio, string lshape,
						string ushape, real lfix, real ufix, real matrix Lambda,
						real matrix xi_HG, real vector means_HG,
						real matrix l_indices_HG, real matrix u_indices_HG,
						real matrix Lambdas_HG, real vector cardinality_xi) {
  if (ushape == "obf") {
    u                 = C*sqrt(J:/(1::J))
  }
  else if (ushape == "pocock") {
    u                 = J(J, 1, C)
  }
  else if (ushape == "fixed") {
    u                 = (J(J - 1, 1, upper_fix) \ C)
  }
  else if (ushape == "triangular") {
    u                 = C*(1 :+ (1::J)/J):/sqrt(ratio*(1::J))
  }
  if (lshape == "obf") {
    l                 = (-C*sqrt(J:/(1::(J - 1))) \ u[J])
  }
  else if (lshape == "pocock") {
    l                 = (J(J - 1, 1, -C) \ u[J])
  }
  else if (lshape == "fixed") {
    l                 = (J(J - 1, 1, lower_fix) \ u[J])
  }
  else if (lshape == "triangular") {
    if (upper_shape == "triangular") {
	  l               = -C*(1 :- 3*(1::J)/J):/sqrt(ratio*(1::J))
	}
	else {
	  l               =
	  -C*((1 :- 3*(1::J)/J):/sqrt(ratio*(1::J)))/(-1*(1 - 3)/sqrt(J))
	}
  }
  bounds              = (l \ u \ . \ .)
  for (i = 1; i <= cardinality_xi[1]; i++) {
    xi_HG[i, 2*K + 4] = pmvnormal_mata(bounds[l_indices_HG[i, 1::means_HG[i]]]',
	                                   bounds[u_indices_HG[i, 1::means_HG[i]]]',
						 			   J(1, means_HG[i], 0),
						 			   Lambda[Lambdas_HG[i, 1::means_HG[i]],
								     		  Lambdas_HG[i, 1::means_HG[i]]],
									   12, 1000, 3)[1]
  }
  return(alpha - sum(xi_HG[, 2*K + 2]:*xi_HG[, 2*K + 4]))
}

real scalar mams_find_n_sep(real scalar n, real scalar J, real scalar beta,
                            real vector l, real vector u,
							real vector means_div_sqrt_n, real matrix Lambda) {
  delta_sqrt_I = sqrt(n)*means_div_sqrt_n
  pi           = 1 - normal(u[1] - delta_sqrt_I[1])
  if (J > 1) {
    for (j = 2; j <= J; j++) {
      pi       = pi + pmvnormal_mata((l[1::(j - 1)] \ u[j])',
		                             (u[1::(j - 1)] \ .)', delta_sqrt_I[1::j]',
									 Lambda[1::j, 1::j], 12, 1000, 3)[1]
    }
  }
  return(1 - beta - pi)
}

real scalar mams_find_n_sim(real scalar n, real colvector bounds, real scalar K,
                            real scalar J, real scalar beta, real matrix Lambda,
						    real matrix xi_LFC,
							real matrix means_div_sqrt_n_LFC,
						    real matrix l_indices_LFC,
							real matrix u_indices_LFC, real matrix Lambdas_LFC,
							real vector dim_LFC, real vector cardinality_xi) {
  for (i = 1; i <= cardinality_xi[2]; i++) {
    xi_LFC[i, 2*K + 4] =
	  pmvnormal_mata(bounds[l_indices_LFC[i, 1::dim_LFC[i]]]',
	                 bounds[u_indices_LFC[i, 1::dim_LFC[i]]]',
					 sqrt(n)*means_div_sqrt_n_LFC[i, 1::dim_LFC[i]],
					 Lambda[Lambdas_LFC[i, 1::dim_LFC[i]],
							Lambdas_LFC[i, 1::dim_LFC[i]]],
					 12, 1000, 3)[1]
  }
  return(1 - beta - sum(xi_LFC[, 2*K + 2]:*xi_LFC[, 2*K + 4]))
}

real vector mams_opchar(real scalar n, real colvector bounds, real scalar K,
                        real scalar J, real matrix Lambda, real matrix xi_HG,
						real matrix xi_LFC, real vector means_HG,
						real matrix l_indices_HG, real matrix u_indices_HG,
						real matrix Lambdas_HG,
						real matrix means_div_sqrt_n_LFC,
						real matrix l_indices_LFC, real matrix u_indices_LFC,
						real matrix Lambdas_LFC, real vector dim_LFC,
						real vector cardinality_xi) {
  for (i = 1; i <= cardinality_xi[1]; i++) {
    xi_HG[i, 2*K + 4]  =
	  pmvnormal_mata(bounds[l_indices_HG[i, 1::means_HG[i]]]',
	                 bounds[u_indices_HG[i, 1::means_HG[i]]]',
					 J(1, means_HG[i], 0),
					 Lambda[Lambdas_HG[i, 1::means_HG[i]],
							Lambdas_HG[i, 1::means_HG[i]]],
					 12, 1000, 3)[1]
  }
  unique_n_HG          = sort(uniqrows(xi_HG[, 2*K + 3]), 1)
  prob_n_HG            = J(length(unique_n_HG), 1, 0)
  for (i = 1; i <= length(unique_n_HG); i++) {
    which_i            = which_condition(xi_HG[, 2*K + 3], "e", unique_n_HG[i])
    prob_n_HG[i]       = sum(xi_HG[which_i, 2*K + 1]:*xi_HG[which_i, 2*K + 4])
  }
  unique_n_HG          = n*unique_n_HG
  running_prob_n_HG    = runningsum(prob_n_HG)
  if (any(running_prob_n_HG :== 0.5)) {
    which_0_5          = which_condition(running_prob_n_HG, "e", 0.5)[1]
    mss_HG             = 0.5*(unique_n_HG[which_0_5] +
	                            unique_n_HG[which_0_5 + 1])
  }
  else {
    mss_HG             = unique_n_HG[which_condition(running_prob_n_HG, "g",
	                                                 0.5)[1]]
  }
  ess_HG               = n*sum(xi_HG[, 2*K + 1]:*xi_HG[, 2*K + 3]:*
                                 xi_HG[, 2*K + 4])
  sdss_HG             = sqrt(sum(unique_n_HG:^2 :* prob_n_HG) :- ess_HG^2)
  for (i = 1; i <= cardinality_xi[2]; i++) {
    xi_LFC[i, 2*K + 4] =
	  pmvnormal_mata(bounds[l_indices_LFC[i, 1::dim_LFC[i]]]',
	                 bounds[u_indices_LFC[i, 1::dim_LFC[i]]]',
					 sqrt(n)*means_div_sqrt_n_LFC[i, 1::dim_LFC[i]],
					 Lambda[Lambdas_LFC[i, 1::dim_LFC[i]],
							Lambdas_LFC[i, 1::dim_LFC[i]]],
					 12, 1000, 3)[1]
  }
  unique_n_LFC         = sort(uniqrows(xi_LFC[, 2*K + 3]), 1)
  prob_n_LFC           = J(length(unique_n_LFC), 1, 0)
  prob_n_LFC           = prob_n_LFC[order(unique_n_LFC, 1)]
  for (i = 1; i <= length(unique_n_LFC); i++) {
    which_i            = which_condition(xi_LFC[, 2*K + 3], "e",
	                                     unique_n_LFC[i])
    prob_n_LFC[i]      = sum(xi_LFC[which_i, 2*K + 1]:*xi_LFC[which_i, 2*K + 4])
  }
  unique_n_LFC         = n*unique_n_LFC
  running_prob_n_LFC   = runningsum(prob_n_LFC)
  if (any(running_prob_n_LFC :== 0.5)) {
    which_0_5          = which_condition(running_prob_n_LFC, "e", 0.5)[1]
    mss_LFC            = 0.5*(unique_n_LFC[which_0_5] +
	                            unique_n_LFC[which_0_5 + 1])
  }
  else {
    mss_LFC            = unique_n_LFC[which_condition(running_prob_n_LFC, "g",
	                                                  0.5)[1]]
  }
  ess_LFC              = n*sum(xi_LFC[, 2*K + 1]:*xi_LFC[, 2*K + 3]:*
                                 xi_LFC[, 2*K + 4])
  sdss_LFC             = sqrt(sum(unique_n_LFC:^2 :* prob_n_LFC) :- ess_LFC^2)
  return((sum(xi_HG[, 2*K + 2]:*xi_HG[, 2*K + 4]),
          sum(xi_LFC[, 2*K + 2]:*xi_LFC[, 2*K + 4]), ess_HG, ess_LFC, sdss_HG,
		  sdss_LFC, mss_HG, mss_LFC))
}

real matrix perm_combs(real colvector n, real scalar k, real scalar ordered,
                       real scalar replace) {
  if (k == 1) {
    return(n)
  }
  ln                            = length(n)
  if (ln == 1) {
    return(J(1, k, n))
  }
  l                             = ln^k
  allperms                      = J(l, k, 0)
  d                             = n[2::ln] :- n[1::(ln - 1)]
  vl                            = (-sum(d) \ d)
  ln_pow_k_min_1                = l/ln
  allperms[1::l, k]             = J(ln_pow_k_min_1, 1, vl)
  elts                          = count = 1
  while (elts[count] + ln_pow_k_min_1 <= l) {
    elts                        = (elts \ elts[count] + ln_pow_k_min_1)
    count                       = count + 1
  }
  allperms[elts, 1]             = vl
  if (k > 2) {
    for (i = 2; i <= k - 1; i++) {
      elts                      = count = 1
	  ln_pow_i_min_1            = ln^(i - 1)
      while (elts[count] + ln_pow_i_min_1 <= l) {
        elts                    = (elts \ elts[count] + ln_pow_i_min_1)
        count                   = count + 1
      }
      allperms[elts, k - i + 1] = J(count/ln, 1, vl)
    }
  }
  allperms[1, 1::k]             = J(1, k, n[1])
  origallperms                  = allperms
  for (i = 2; i <= l; i++) {
    for (j = 1; j <=k; j++) {
      allperms[i, j]            = sum(origallperms[1::i, j])
    }
  }
  if (ordered == 0) {
    keep                        = J(l, 1, 1)
	for (i = 1; i <= l; i++) {
	  for (j = 2; j <= k; j++) {
	    if (allperms[i, j] < allperms[i, j - 1]) {
		  keep[i]               = 0
		  break
		}
	  }
	}
	allperms                    = allperms[which_condition(keep, "e", 1), ]
  }
  if (replace == 0) {
    if (ordered == 0) {
	  rows_allperms             = rows(allperms)
	} else {
	  rows_allperms             = l
	}
    keep                        = J(rows_allperms, 1, 1)
	for (i = 1; i <= rows_allperms; i++) {
	  for (j = 1; j <= ln; j++) {
	    if (length(which_condition(allperms[i, ], "e", n[j])) >
		      length(which_condition(n, "e", n[j]))) {
		  keep[i]               = 0
		  break
		}
	  }
	}
	allperms                    = allperms[which_condition(keep, "e", 1), ]
  }
  return(uniqrows(allperms))
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
