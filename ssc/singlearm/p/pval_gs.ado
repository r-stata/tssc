*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define pval_gs, rclass
version 11.0
syntax, [J(integer 2) n(numlist) a(numlist miss) r(numlist miss) k(numlist) ///
         pi0(real 0.1) pi(numlist) method(string) SUMmary(integer 0) PLot *]

local xopt `"`options'"'		 
preserve

if ("`method'" == "") {
  local method "all"
}

///// Perform checks on input variables ////////////////////////////////////////

if (`j' <= 1) {
  di "{error} J must be an integer greater than or equal to one."
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
if ((`pi0' <= 0) | (`pi0' >= 1)) {
  di "{error} pi0 must be a real strictly between 0 and 1."
  exit(198)
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
if ("`method'" ~= "all" & "`method'" ~= "conditional" & "`method'" ~= "mle" & "`method'" ~= "naive" & "`method'" ~= "umvue") {
  di "{error} method must be one of: all, conditional, mle, naive, or umvue."
  exit(198)
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

///// Compute and Output ///////////////////////////////////////////////////////

mata: PvalGS(`j', `pi0', "`method'", `summary', "`plot'", `"`xopt'"')
matrix colnames pval = s m k Method "p(s,m)"
return mat pval = pval
matrix colnames perf = pi Method "E(p|pi)" "Var(p|pi)"
return mat perf = perf
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

void PvalGS(J, pi0, method, summary, plot, xopt)
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

  ///// Print Summary //////////////////////////////////////////////////////////

  
  
  ///// Main Computations //////////////////////////////////////////////////////
  
  if (method == "all") {
    int_method = 1::4
  }
  else if (method == "conditional") {
    int_method = 1
  }
  else if (method == "mle") {
    int_method = 2
  }
  else if (method == "naive") {
    int_method = 3
  }
  else {
    int_method = 4
  }
  terminal = terminal_states_gs(J, a, r, n, k)
  pval = (vec(J(length(int_method), 1, terminal[, 1]')), vec(J(length(int_method), 1, terminal[, 2]')), vec(J(length(int_method), 1, terminal[, 3]')), J(rows(terminal), 1, int_method), J(length(int_method)*rows(terminal), 1, 0))
  for (i = 1; i <= rows(pval); i++) {
    if (pval[i, 4] == 1) {
	  pval[i, 5] = pval_gs_cond(pi0, pval[i, 1], pval[i, 2], pval[i, 3], J, a, r, n)
	}
	else if (pval[i, 4] == 2) {
	  pval[i, 5] = pval_gs_mle(pi0, pval[i, 1], pval[i, 2], J, a, r, n)
	}
	else if (pval[i, 4] == 3) {
	  pval[i, 5] = pval_fixed_exact(pval[i, 1], pval[i, 2], pi0)
	}
	else  {
	  pval[i, 5] = pval_gs_umvue(pi0, pval[i, 1], pval[i, 2], pval[i, 3], J, a, r, n)
	}
	if (summary == 1 & mod(i, 100) == 0) {
	  printf("{txt}...{res}%g{txt} p-values determined...\n", i)
	}
  }
  pmf = J(rows(terminal)*length(pi), 5, 0)
  for (i = 1; i <= length(pi); i++) {
    pmf[(1 + (i - 1)*rows(terminal))::(i*rows(terminal)), ] = pmf_gs(pi[i], J, a, r, n, k)
  }
  perf = (J(length(int_method), 1, pi), vec(J(length(pi), 1, int_method')), J(length(pi)*length(int_method), 2, 0))
  for (i = 1; i <= rows(perf); i++) {
	pmf_i      = select(pmf, pmf[, 1] :== perf[i, 1])
	pval_i     = select(pval, pval[, 4] :== perf[i, 2])
	perf[i, 3] = sum(pmf_i[, 5]:*pval_i[, 5])
	perf[i, 4] = sum(pmf_i[, 5]:*(pval_i[, 5]:^2)) - perf[i, 3]^2
	if (summary == 1 & mod(i, 100) == 0) {
	  printf("{txt}...performance for {res}%g{txt} elements of pi evaluated...\n", i)
	}
  }
  if (plot ~= "") {
    if (method ~= "all") {
	  st_matrix("perf", perf)
	  stata("qui svmat perf")
	  stata(`"twoway line perf3 perf1, xtitle({&pi}) ytitle(E({it:p}|{&pi}))"'+ xopt)
	}
	else {
	  perf1 = select(perf, perf[, 2] :== 1)
	  perf2 = select(perf, perf[, 2] :== 2)
	  perf3 = select(perf, perf[, 2] :== 3)
	  perf4 = select(perf, perf[, 2] :== 4)
	  st_matrix("perf1", perf1)
      st_matrix("perf2", perf2)
	  st_matrix("perf3", perf3)
	  st_matrix("perf4", perf4)
      stata("qui svmat perf1")
	  stata("qui svmat perf2")
	  stata("qui svmat perf3")
	  stata("qui svmat perf4")
	  stata(`"twoway (line perf13 perf11, color(black)) (line perf23 perf21, color(red)) (line perf33 perf31, color(blue)) (line perf43 perf41, color(green)), xtitle({&pi}) ytitle(E({it:p}|{&pi})) legend(lab(1 "Conditional") lab(2 "MLE") lab(3 "Naive") lab(4 "UMVUE"))"'+ xopt)
	}
  }

  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting.")
  }
  
  st_matrix("pval", pval)
  st_matrix("perf", perf)
  st_matrix("J", J)
  st_matrix("n", n)
  st_matrix("a", a)
  st_matrix("r", r)
  st_matrix("k", k)
  st_matrix("pi0", pi0)
  st_matrix("pi", pi')
  st_matrix("summary", summary)
}

// Function for finding p-value, using the exact method, in a fixed design
real scalar pval_fixed_exact(real scalar s, real scalar m, real scalar pi0)
{
  return(binomialtail(m, s, pi0))
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

// Function for determining pmf of group sequential design
real matrix pmf_gs(real scalar pi, real scalar J, real rowvector a,
                   real rowvector r, real rowvector n, real rowvector k,| real colvector dbinom_pi)
{
  a[mm_which(a :== .)] = J(1, length(mm_which(a :== .)), -1)
  r[mm_which(r :== .)] = J(1, length(mm_which(r :== .)), sum(n) + 1)
  if (args() < 7) {
    dbinom_pi                     = J(max(n) + 1, J, 0)
    for (j = 1; j <= J; j++) {
      dbinom_pi[1::(n[j] + 1), j] = binomialp(n[j], 0::n[j], pi)
    }
  }
  pmf_mat                   = J(sum(n) + 1, J, 0)
  pmf_mat[1::(n[1] + 1), 1] = dbinom_pi[1::(n[1] + 1), 1]
  cont                      = (max((0, a[1] + 1)), min((r[1] - 1, n[1])))
  for (j = 1; j <= J - 1; j++) {
    for (i = cont[1]; i <= cont[2]; i++) {
      pmf_mat[(i + 1)::(i + 1 + n[j + 1]), j + 1] = pmf_mat[(i + 1)::(i + 1 + n[j + 1]), j + 1] :+ pmf_mat[i + 1, j]*dbinom_pi[1::(n[j + 1] + 1), j + 1]
    }
    pmf_mat[(cont[1] + 1)::(cont[2] + 1), j] = J(cont[2] - cont[1] + 1, 1, 0)
    upd                                      = cont[1]::(cont[2] + n[j + 1])
    cont                                     = (min(select(upd, upd :> a[j + 1])), max(select(upd, upd :< r[j + 1])))
  }
  if (length(k) < J) {
    for (stage = 1; stage <= J; stage++) {
	  if (!any(stage :== k)) {
	    pmf_mat[, stage] = J(sum(n) + 1, 1, 0)
	  }
	}
	pmf_mat             = pmf_mat/sum(pmf_mat)
  }
  terminal   = terminal_states_gs(J, a, r, n, k)
  if (sum(pmf_mat :> 0) > 1) {
    f   = .
	for (j = 1; j <= J; j++) {
	  f = (f \ select(pmf_mat[, j], pmf_mat[, j] :> 0))
	}
    pmf = (J(rows(terminal), 1, pi), terminal[, 1], terminal[, 2], terminal[, 3], f[2::length(f)])
  }
  else {
    pmf      = (J(rows(terminal), 1, pi), terminal[, 1], terminal[, 2], terminal[, 3], J(rows(terminal), 1, 0))
    non_zero = (mm_which(rowsum(pmf_mat) :> 0) - 1, mm_which(colsum(pmf_mat :> 0)))
	pmf[mm_which(pmf[, 2] :== non_zero[1] :& pmf[, 4] :== non_zero[2]), 5] = 1
  }
  return(pmf)
}

// Function for finding p-value, based on MLE ordering, in a group sequential
// design
real scalar pval_gs_mle(real scalar pi, real scalar s, real scalar m,
                        real scalar J, real rowvector a, real rowvector r,
						real rowvector n,| real matrix dbinom_pi) {
  if (args() < 8) {
    pmf = pmf_gs(pi, J, a, r, n, (1::J)')
  }
  else {
    pmf = pmf_gs(pi, J, a, r, n, (1::J)', dbinom_pi)
  }
  return(sum(select(pmf, pmf[, 2]:/pmf[, 3] :>= s/m)[, 5]))
}

// Function for finding p-value, based on UMVUE ordering, in a group sequential
// design
real scalar pval_gs_umvue(real scalar pi, real scalar s, real scalar m,
                          real scalar k, real scalar J, real rowvector a,
						  real rowvector r,
						  real rowvector n,| real matrix dbinom_pi)
{
  if (args() < 9) {
    pmf         = pmf_gs(pi, J, a, r, n, (1::J)')
  }
  else {
    pmf         = pmf_gs(pi, J, a, r, n, (1::J)', dbinom_pi)
  }
  umvues      = J(rows(pmf), 1, 0)
  for (i = 1; i <= rows(pmf); i++) {
    umvues[i] = est_gs_umvue(pmf[i, 2], pmf[i, 3], pmf[i, 4], a, r, n)
  }
  umvue_sm    = est_gs_umvue(s, m, k, a, r, n)
  return(sum(pmf[mm_which(umvues :>= umvue_sm), 5]))
}

// Function for finding conditional p-value in a group sequential design
real scalar pval_gs_cond(real scalar pi, real scalar s, real scalar m,
                         real scalar k, real scalar J, real rowvector a,
						 real rowvector r,
						 real rowvector n,| real matrix dbinom_pi)
{
  if (k == 1) {
    return(binomialtail(n[1], s, pi))
  }
  else {
    if (args() < 9) {
	  pmf = pmf_gs(pi, J, a[1::k], r[1::k], n[1::k], (1::k)')
	}
	else {
	  pmf = pmf_gs(pi, J, a[1::k], r[1::k], n[1::k], (1::k)', dbinom_pi)
	}
    pmf = select(pmf, pmf[, 4] :== k)
	return(sum(select(pmf, pmf[, 2] :>= s)[, 5])/sum(pmf[, 5]))
  }
}

// Function for finding UMVUE in a group sequential design
real scalar est_gs_umvue(real scalar s, real scalar m, real scalar k,
                         real rowvector a, real rowvector r, real rowvector n)
{
  if (k == 1) {
    return(s/m)
  }
  else if (k == 2) {
    s1 = max((a[1] + 1, s - n[2], 0))::min((s, r[1] - 1, n[1]))
    return(sum((comb(n[1] - 1, s1 :- 1):*comb(n[2], s :- s1)))/sum((comb(n[1], s1):*comb(n[2], s :- s1))))
  }
  else {
    R_ms        = permutations(0::s, k)
	for (j = 1; j <= k - 1; j++) {
      cum_R_ms  = rowsum(R_ms[, 1::j])
      R_ms      = select(R_ms, cum_R_ms :> a[j] :& cum_R_ms :< r[j])
    }
	R_ms        = select(R_ms, rowsum(R_ms) :== s)
	sum_num     = 0
    sum_denom   = 0
    for (i = 1; i <= rows(R_ms); i++) {
      sum_num   = sum_num + exp(sum(log(comb(n[1::k] - (1, J(1, k - 1, 0)), R_ms[i, ] - (1, J(1, k - 1, 0))))))
      sum_denom = sum_denom + exp(sum(log(comb(n[1::k], R_ms[i, ]))))
    }
	return(sum_num/sum_denom)
  }
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

end
