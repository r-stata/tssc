*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define opchar_curtailed, rclass
version 11.0
syntax, [J(integer 2) pi1(real 0.3) n(numlist) a(numlist miss) ///
         r(numlist miss) thetaf(numlist) thetae(numlist) k(numlist) ///
		 pi(numlist) SUMmary(integer 0) PLot(string) *]

local xopt `"`options'"'		 
preserve

if ("`method'" == "") {
  local method "all"
}

///// Perform checks on input variables ////////////////////////////////////////

if (`j' <= 0) {
  di "{error} J must be an integer greater than or equal to one."
  exit(198)
}
if ((`pi1' <= 0) | (`pi1' >= 1)) {
  di "{error} pi1 must be a real strictly between 0 and 1."
  exit(198)
}
if ("`n'" ~= "") {
  local lenn:list sizeof n
  if (`lenn' ~= `j') {
    di "{error} n must be a numlist of length J, containing integer elements."
    exit(198)
  }
  forvalues i = 1/`lenn' {
    local ni:word `i' of `n'
    if (`ni' <= 0 | mod(`ni', 1) ~= 0) {
      di "{error} n must be a numlist of length J, containing integer elements."
      exit(198)
    }
  }
}
if ("`a'" ~= "") {
  local lena:list sizeof a
  if (`lena' ~= `j') {
    di "{error} a must be a numlist of length J, containing integer elements."
    exit(198)
  }
  forvalues i = 1/`lena' {
    local ai:word `i' of `a'
    if (`ai' ~= .) {
	  if (`ai' < 0 | mod(`ai', 1) ~= 0) {
        di "{error} a must be a numlist of length J, containing integer elements."
        exit(198)
      }
	}
  }
}
if ("`r'" ~= "") {
  local lenr:list sizeof r
  if (`lenr' ~= `j') {
    di "{error} r must be a numlist of length J, containing integer elements."
    exit(198)
  }
  forvalues i = 1/`lenr' {
    local ri:word `i' of `r'
	if (`ri' ~= .) {
	  if (`ri' <= 0 | mod(`ri', 1) ~= 0) {
        di "{error} r must be a numlist of length J, containing integer elements."
        exit(198)
      }
	}
  }
}
if ("`a'" ~= "" & "`r'" ~= "") {
  forvalues i = 1/`lena' {
    local ai:word `i' of `a'
	local ri:word `i' of `r'
    if (`ai' >= `ri') {
      di "{error} Elements in a must be strictly less than their corresponding element in r."
      exit(198)
    }
  }
}
if ("`thetaf'" ~= "") {
  local lenthetaf:list sizeof thetaf
  if (`lenthetaf' ~= `j') {
    di "{error} thetaf must be a numlist of length J."
    exit(198)
  }
  if ("`thetae'" == "") {
    forvalues i = 1/`lenthetaf' {
      local thetafi:word `i' of `thetaf'
      if (`thetafi' > 1) {
        di "{error} Elements in thetaf must be less than or equal to 1."
        exit(198)
      }
    }
  }
}
if ("`thetae'" ~= "") {
  local lenthetae:list sizeof thetae
  if (`lenthetae' ~= `j') {
    di "{error} thetae must be a numlist of length J."
    exit(198)
  }
  if ("`thetaf'" == "") {
    forvalues i = 1/`lenthetae' {
      local thetaei:word `i' of `thetae'
      if (`thetaei' < 0) {
        di "{error} Elements in thetae must be greater than or equal to 0."
        exit(198)
      }
    }
  }
}
if ("`thetaf'" ~= "" & "`thetae'" ~= "") {
  forvalues i = 1/`lenthetaf' {
    local thetafi:word `i' of `thetaf'
    local thetaei:word `i' of `thetae'
    if (`thetafi' > `thetaei') {
      di "{error} Elements in thetaf must be less than or equal to their corresponding element in thetae."
      exit(198)
    }
  }
}
if ("`k'" ~= "") {
  local lenk:list sizeof k
  if (`lenk' >= `j') {
    di "{error} k must be a numlist of length at most J, containing integer elements."
    exit(198)
  }
  forvalues i = 1/`lenk' {
    local ki:word `i' of `k'
    if (`ki' <= 0 | mod(`ki', 1) ~= 0) {
      di "{error} k must be a numlist of length at most J, containing integer elements."
      exit(198)
    }
  }
}
if ("`pi'" ~= "") {
  local lenpi:list sizeof pi
  forvalues i = 1/`lenpi' {
    local pii:word `i' of `pi'
    if (`pii' > 1 | `pii' < 0) {
      di "{error} Elements in pi must belong to [0,1]."
      exit(198)
    }
  }
}
if (`j' ~= 2 & ("`n'" == "" | "`a'" == "" | "`r'" == "")) {
  di "{error} For J not equal to 2, n, a, and r must be specified"
  exit(198)
}
// Set up matrices to pass to mata
if ("`n'" ~= "") {
  local matan ""
  foreach i of local n{
    if "`matan'" == "" local matan "`i'"
    else local matan "`matan',`i'"
  }
  mat n = (`matan')
}
else {
  mat n = .
}
if ("`a'" ~= "") {
  local mataa ""
  foreach i of local a{
    if "`mataa'" == "" local mataa "`i'"
    else local mataa "`mataa',`i'"
  }
  mat a = (`mataa')
}
else {
  mat a = .
}
if ("`r'" ~= "") {
  local matar ""
  foreach i of local r{
    if "`matar'" == "" local matar "`i'"
    else local matar "`matar',`i'"
  }
  mat r = (`matar')
}
else {
  mat r = .
}
if ("`k'" ~= "") {
  local matak ""
  foreach i of local k{
    if "`matak'" == "" local matak "`i'"
    else local matak "`matak',`i'"
  }
  mat k = (`matak')
}
else {
  mat k = .
}
if ("`pi'" ~= "") {
  local matapi ""
  foreach i of local pi{
    if "`matapi'" == "" local matapi "`i'"
    else local matapi "`matapi',`i'"
  }
  mat pi = (`matapi')
}
else {
  mat pi = .
}
if ("`plot'" ~= "") {
  if ("`plot'" ~= "power" & "`plot'" ~= "ess") {
    di "{error} plot must be one of: power and ess."
    exit(198)
  }
}
if ("`thetaf'" ~= "") {
  local matathetaf ""
  foreach i of local thetaf{
    if "`matathetaf'" == "" local matathetaf "`i'"
    else local matathetaf "`matathetaf',`i'"
  }
  mat thetaf = (`matathetaf')
}
else {
  mat thetaf = .
}
if ("`thetae'" ~= "") {
  local matathetae ""
  foreach i of local thetae{
    if "`matathetae'" == "" local matathetae "`i'"
    else local matathetae "`matathetae',`i'"
  }
  mat thetae = (`matathetae')
}
else {
  mat thetae = .
}

///// Compute and Output ///////////////////////////////////////////////////////

mata: OpcharCurtailed(`j', `pi1', "`method'", `summary', "`plot'", `"`xopt'"')
matrix colnames pmf = pi s m k "f(s,m|pi)"
return mat pmf = pmf
if (`j' == 2) {
  matrix colnames opchar = pi "P(pi)" "ESS(pi)" "VSS(pi)" "Med(pi)" "A1(pi)" "A2(pi)" "R1(pi)" "R2(pi)" "S1(pi)" "S2(pi)" "cum(S1(pi))" "cum(S2(pi))" "max(N)"
}
else {
  matrix colnames opchar = pi "P(pi)" "ESS(pi)" "VSS(pi)" "Med(pi)" "A1(pi)" "R1(pi)" "S1(pi)" "cum(S1(pi))" "max(N)"
}
return mat opchar = opchar
return mat J = J
return mat n = n
return mat a = a
return mat r = r
return mat k = k
return mat pi = pi
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void OpcharCurtailed(J, pi1, method, summary, plot, xopt)
{
  n = st_matrix("n")
  if (n == .) {
    n = (10, 19)
  }
  a = st_matrix("a")
  if (a == .) {
    a = (1, 5)
  }
  r = st_matrix("r")
  if (r == .) {
    r = (., 6)
  }
  k = st_matrix("k")
  if (k == .) {
    k = (1::J)'
  }
  pi = st_matrix("pi")
  if (pi == .) {
    pi = 0.01*(0::100)
  }
  thetaF = st_matrix("thetaf")
  thetaE = st_matrix("thetae")
  if (thetaF == .) {
    thetaF = J(1, J, 0)
  }
  if (thetaE == .) {
    thetaE = J(1, J, 1)
  }

  ///// Print Summary //////////////////////////////////////////////////////////

  
  ///// Main Computations //////////////////////////////////////////////////////

  cp_mat = J(sum(n) + 1, sum(n), 0)
  for (m = 1; m <= sum(n); m++) {
	for (s = 0; s <= m; s++) {
	  cp_mat[s + 1, m] = cr_gs(pi1, s, m, J, a, r, n)
	}
  }
  a_curt = J(1, sum(n), .)
  r_curt = J(1, sum(n), .)
  n_curt = J(1, sum(n), 1)
  for (i = 1; i <= sum(n); i++) {
	j = min(mm_which(i :<= runningsum(n)))
	if (any(cp_mat[1::(i + 1), i] :<= thetaF[j])) {
	  a_curt[i] = max(mm_which(cp_mat[1::(i + 1), i] :<= thetaF[j])) - 1
	}
	if (any(cp_mat[, i] :>= thetaE[j])) {
	  r_curt[i] = min(mm_which(cp_mat[, i] :>= thetaE[j])) - 1
	}
  }
  a_curt[mm_which(a_curt :== -1)] = J(1, length(mm_which(a_curt :== -1)), .)
  r_curt[mm_which(r_curt :== sum(n) + 1)] = J(1, length(mm_which(r_curt :== sum(n) + 1)), .)
  J_curt   = sum(n)
  full_k   = 0
  N        = (0, runningsum(n))
  for (i = 1; i <= length(k); i++) {
    full_k = (full_k, ((N[k[i]] + 1)::N[k[i] + 1])')
  }
  full_k   = full_k[2::length(full_k)]
  terminal = terminal_states_gs(J_curt, a_curt, r_curt, n_curt, full_k)
  pmf = J(rows(terminal)*length(pi), 5, 0)
  for (i = 1; i <= length(pi); i++) {
	pmf[(1 + (i - 1)*rows(terminal))::(i*rows(terminal)), ] = pmf_curtailed(pi[i], J, J_curt, a_curt, r_curt, n, n_curt, k)
  }
  opchar = J(length(pi), (J == 2 ? 14 : 10), 0)
  for (i = 1; i <= length(pi); i++) {
	pmf_i = select(pmf, pmf[, 1] :== pi[i])
	opchar[i, ] = int_opchar_curtailed(pi[i], J, J_curt, a_curt, r_curt, n, n_curt, runningsum(n), runningsum(n_curt), k, pmf_i)
	if (summary == 1 & mod(i, 100) == 0) {
	  printf("{txt}...performance for {res}%g{txt} elements of pi evaluated...\n", i)
	}
  }
  if (plot == "power") {
    st_matrix("opchar", opchar)
	stata("qui svmat opchar")
	stata(`"twoway line opchar2 opchar1, xtitle({&pi}) ytitle(P({&pi}))"'+ xopt)
  }
  else if (plot == "ess"){
    st_matrix("opchar", opchar)
	stata("qui svmat opchar")
	stata(`"twoway line opchar3 opchar1, xtitle({&pi}) ytitle({it:ESS}({&pi}))"'+ xopt)
  }

  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting.")
  }
  
  st_matrix("pmf", pmf)
  st_matrix("opchar", opchar)
  st_matrix("J", J)
  st_matrix("n", n)
  st_matrix("a", a)
  st_matrix("r", r)
  st_matrix("k", k)
  st_matrix("pi", pi')
  st_matrix("summary", summary)
}

// Function to return conditional rejection probability in a group sequential
// design
real scalar cr_gs(real scalar pi, real scalar s, real scalar m, real scalar J,
                  real rowvector a, real rowvector r, real rowvector n)
{
  if (J > 1) {
    a[mm_which(a :== .)] = J(1, length(mm_which(a :== .)), -1)
    r[mm_which(r :== .)] = J(1, length(mm_which(r :== .)), sum(n) + 1)
  }
  if (J == 1) {
    cr              = binomialtail(n - m, r - s, pi)
  }
  else {
    if (m <= n[1]) {
      if (s >= r[1]) {
        cr          = 1
      }
	  else {
        poss_s      = permutations(uniqrows(s :+ 0::(n[1] - m) \ 0::n[2]), 2)
		poss_s      = select(poss_s, poss_s[, 1] :>= s :& poss_s[, 1] :<= s + n[1] - m :& poss_s[, 2] :>= 0 :& poss_s[, 2] :<= n[2])
		poss_s      = select(poss_s, poss_s[, 1] :>= r[1] :| (poss_s[, 1] :>= max((0, a[1] + 1)) :& poss_s[, 1] :<= min((n[1], r[1] - 1)) :& (poss_s[, 1] + poss_s[, 2] :>= r[2])))
		if (rows(poss_s) > 0) {
		  if (m < n[1]) {
		    prob_poss_s = (binomialp(n[1] - m, poss_s[, 1] :- s, pi), binomialp(n[2], poss_s[, 2], pi))
		  }
		  else {
		    prob_poss_s = (J(rows(poss_s), 1, 1), binomialp(n[2], poss_s[, 2], pi))
		  }
		  cr          = sum(prob_poss_s[, 1]:*prob_poss_s[, 2])
		}
		else {
		  cr = 0
		}
      }
    }
	else {
      cr            = binomialtail(sum(n) - m, r[2] - s, pi)
    }
  }
  return(cr)
}

// Function for determining pmf of group sequential design
real matrix pmf_curtailed(real scalar pi, real scalar J, real scalar J_curt,
                          real rowvector a_curt, real rowvector r_curt,
				          real rowvector n, real rowvector n_curt,
				          real rowvector k,| real colvector dbinom_pi)
{
  a_curt[mm_which(a_curt :== .)] = J(1, length(mm_which(a_curt :== .)), -1)
  r_curt[mm_which(r_curt :== .)] = J(1, length(mm_which(r_curt :== .)), sum(n) + 1)
  if (args() < 9) {
    dbinom_pi                     = J(max(n_curt) + 1, J_curt, 0)
    for (j = 1; j <= J_curt; j++) {
      dbinom_pi[1::(n_curt[j] + 1), j] = binomialp(n_curt[j], 0::n_curt[j], pi)
    }
  }
  pmf_mat                        = J(sum(n) + 1, J_curt, 0)
  pmf_mat[1::(n_curt[1] + 1), 1] = dbinom_pi[1::(n_curt[1] + 1), 1]
  cont                           = (max((0, a_curt[1] + 1)), min((r_curt[1] - 1, n_curt[1])))
  for (j = 1; j <= J_curt - 1; j++) {
    for (i = cont[1]; i <= cont[2]; i++) {
      pmf_mat[(i + 1)::(i + 1 + n_curt[j + 1]), j + 1] = pmf_mat[(i + 1)::(i + 1 + n_curt[j + 1]), j + 1] :+ pmf_mat[i + 1, j]*dbinom_pi[1::(n_curt[j + 1] + 1), j + 1]
    }
    pmf_mat[(cont[1] + 1)::(cont[2] + 1), j] = J(cont[2] - cont[1] + 1, 1, 0)
    upd                                      = cont[1]::(cont[2] + n_curt[j + 1])
    cont                                     = (min(select(upd, upd :> a_curt[j + 1])), max(select(upd, upd :< r_curt[j + 1])))
  }
  N        = (0, runningsum(n))
  full_k   = 0
  for (i = 1; i <= length(k); i++) {
    full_k = (full_k \ (N[k[i]] + 1)::N[k[i] + 1])
  }
  full_k   = full_k[2::length(full_k)]
  if (length(full_k) < J_curt) {
    for (stage = 1; stage <= J_curt; stage++) {
	  if (!any(stage :== full_k)) {
	    pmf_mat[, stage] = J(sum(n) + 1, 1, 0)
	  }
	}
	pmf_mat              = pmf_mat/sum(pmf_mat)
  }
  terminal = terminal_states_gs(J_curt, a_curt, r_curt, n_curt, full_k')
  if (sum(pmf_mat :> 0) > 1) {
    true_k = J(rows(terminal), 1, 0)
	for (i = 1; i <= rows(terminal); i++) {
	  true_k[i] = min(mm_which(N :>= terminal[i, 2])) - 1
	}
	f   = .
	for (j = 1; j <= J_curt; j++) {
	  f = (f \ select(pmf_mat[, j], pmf_mat[, j] :> 0))
	}
    pmf = (J(rows(terminal), 1, pi), terminal[, 1], terminal[, 2], true_k, f[2::length(f)])
  }
  else {
    true_k = J(rows(terminal), 1, 0)
	for (i = 1; i <= rows(terminal); i++) {
	  true_k[i] = min(mm_which(N :>= terminal[i, 3])) - 1
	}
    pmf      = (J(rows(terminal), 1, pi), terminal[, 1], terminal[, 2], terminal[, 3], J(rows(terminal), 1, 0))
    non_zero = (mm_which(rowsum(pmf_mat) :> 0) - 1, mm_which(colsum(pmf_mat :> 0)))
	pmf[mm_which(pmf[, 2] :== non_zero[1] :& pmf[, 4] :== non_zero[2]), 5] = 1
  }
  return(pmf)
}

// Function for determining operating characteristics of group sequential design
real rowvector int_opchar_curtailed(real scalar pi, real scalar J,
                                    real scalar J_curt, real rowvector a_curt,
									real rowvector r_curt, real rowvector n,
									real rowvector n_curt, real rowvector N,
									real rowvector N_curt,
							        real rowvector k,| real matrix pmf_pi)
{
  a_curt[mm_which(a_curt :== .)] = J(1, length(mm_which(a_curt :== .)), -1)
  r_curt[mm_which(r_curt :== .)] = J(1, length(mm_which(r_curt :== .)), sum(n) + 1)
  if (args() < 11) {
    pmf_pi = pmf_curtailed(pi, J, J_curt, a_curt, r_curt, n, n_curt, k)
  }
  A      = J(1, J_curt, 0)
  R      = J(1, J_curt, 0)
  for (j = 1; j <= J_curt; j++) {
    A[j] = sum(select(pmf_pi, pmf_pi[, 2] :<= a_curt[j] :& pmf_pi[, 3] :== j)[, 5])
    R[j] = sum(select(pmf_pi, pmf_pi[, 2] :>= r_curt[j] :& pmf_pi[, 3] :== j)[, 5])
  }
  S      = A + R
  cum_S  = runningsum(S)
  N      = (0, N)
  Atilde = J(1, J, 0)
  Rtilde = J(1, J, 0)
  for (j = 1; j <= J; j++) {
    Atilde[j] = sum(A[(1 + N[j])::N[j + 1]])
    Rtilde[j] = sum(R[(1 + N[j])::N[j + 1]])
  }
  N      = N[2::length(N)]
  Stilde = Atilde + Rtilde
  cum_Stilde = runningsum(Stilde)
  if (any(cum_S :== 0.5)) {
    Med  = 0.5*(N_curt[mm_which(cum_S :== 0.5)[1]] + N_curt[mm_which(cum_S :> 0.5)[1]])
  }
  else {
    Med  = N_curt[mm_which(cum_S :> 0.5)[1]]
  }
  return((pi, sum(R), sum(N_curt:*S), sum(N_curt:^2:*S) - sum(N_curt:*S)^2, Med, Atilde, Rtilde, Stilde, cum_Stilde, sum(n)))
}

// Function to determine all permutations of length q from a vector vec with
// replacement
real matrix permutations(real colvector vec, real scalar q)
{
  if (q == 1) {
    return(vec)
  }
  lvec = length(vec)
  if (lvec == 1) {
    return(J(1, q, vec))
  }
  l                 = lvec^q
  allperms          = J(l, q, 0)
  d                 = vec[2::lvec] :- vec[1::(lvec - 1)]
  ld                = length(d)
  vl                = (-sum(d) \ d)
  tmp               = J(1, l/lvec, vl)
  allperms[1::l, q] = vec(tmp)
  elts    = 1
  count   = 1
  while (elts[count] + lvec^(q - 1) <= l) {
    elts  = (elts \ elts[count] + lvec^(q - 1))
    count = count + 1
  }
  allperms[elts, 1] = vl
  if (q > 2) {
    for (i = 2; i <= q - 1; i++) {
      elts    = 1
      count   = 1
      while (elts[count] + lvec^(i - 1) <= l) {
        elts  = (elts \ elts[count] + lvec^(i - 1))
        count = count + 1
      }
      tmp = J(1, length(elts)/(ld + 1), vl)
      allperms[elts, q - i + 1] = vec(tmp)
    }
  }
  allperms[1, 1::q] = J(1, q, vec[1])
  origallperms      = allperms
  for (i = 2; i <= l; i++) {
    for (j = 1; j <= q; j++) {
      allperms[i, j] = sum(origallperms[1::i, j])
    }
  }
  return(allperms)
}

// Function to determine terminal states in a group sequential design
real matrix terminal_states_gs(real scalar J, real rowvector a,
                               real rowvector r, real rowvector n,
							   real rowvector k)
{
  a[mm_which(a :== .)] = J(1, length(mm_which(a :== .)), -1)
  r[mm_which(r :== .)] = J(1, length(mm_which(r :== .)), sum(n) + 1)
  terminal      = J(1, 3, 0)
  if (a[1] >= 0) {
    s1          = 0::a[1]
    terminal    = (terminal \ (s1, J(a[1] + 1, 1, n[1]), J(a[1] + 1, 1, 1)))
  }
  if (r[1] <= n[1]) {
    s1          = r[1]::n[1]
    terminal    = (terminal \ (s1, J(n[1] - r[1] + 1, 1, n[1]), J(n[1] - r[1] + 1, 1, 1)))
  }
  cont          = (max((0, a[1] + 1)), min((r[1] - 1, n[1])))
  if (J >= 3) {
    for (j = 1; j <= J - 2; j++) {
	  num_rows  = cont[2] + n[j + 1] - cont[1] + 1
      vals      = cont[1]::(cont[2] + n[j + 1])
	  upd       = (vals, J(num_rows, 1, sum(n[1::(j + 1)])), J(num_rows, 1, j + 1))
      terminal  = (terminal \ select(upd, upd[, 1] :<= a[j + 1] :| upd[, 1] :>= r[j + 1]))
	  cont      = (min(select(upd, upd[, 1] :> a[j + 1])[, 1]), max(select(upd, upd[, 1] :< r[j + 1])[, 1]))
    }
  }
  num_rows      = cont[2] + n[J] - cont[1] + 1
  vals          = cont[1]::(cont[2] + n[J])
  terminal      = (terminal \ (vals, J(num_rows, 1, sum(n)), J(num_rows, 1, J)))
  keep_rows     = mm_which(terminal[, 3] :== k[1])
  if (length(k) > 1) {
    for (els = 2; els <= length(k); els++) {
	  keep_rows = (keep_rows \ mm_which(terminal[, 3] :== k[els]))
	}
  }
  terminal      = terminal[keep_rows, ]
  return(terminal)
}

end
