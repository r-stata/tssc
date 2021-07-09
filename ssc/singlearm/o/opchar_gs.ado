*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define opchar_gs, rclass
version 11.0
syntax, [J(integer 2) n(numlist) a(numlist miss) r(numlist miss) k(numlist) ///
         pi(numlist) SUMmary(integer 0) PLot(string) *]

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

///// Compute and Output ///////////////////////////////////////////////////////

mata: OpcharGS(`j', "`method'", `summary', "`plot'", `"`xopt'"')
matrix colnames pmf = pi s m k "f(s,m|pi)"
return mat pmf = pmf
if (`j' == 2) {
  matrix colnames opchar = pi "P(pi)" "ESS(pi)" "VSS(pi)" "Med(pi)" "A1(pi)" "A2(pi)" "R1(pi)" "R2(pi)" "S1(pi)" "S2(pi)" "cum(S1(pi))" "cum(S2(pi))" "max(N)"
}
else {
  matrix colnames opchar = pi "P(pi)" "ESS(pi)" "VSS(pi)" "Med(pi)" "A1(pi)" "A2(pi)" "R1(pi)" "R2(pi)" "S1(pi)" "S2(pi)" "cum(S1(pi))" "cum(S2(pi))" "max(N)"
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

void OpcharGS(J, method, summary, plot, xopt)
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

  terminal = terminal_states_gs(J, a, r, n, k)
  pmf = J(rows(terminal)*length(pi), 5, 0)
  for (i = 1; i <= length(pi); i++) {
	pmf[(1 + (i - 1)*rows(terminal))::(i*rows(terminal)), ] = pmf_gs(pi[i], J, a, r, n, k)
  }
  opchar = J(length(pi), (J == 2 ? 14 : 18), 0)
  for (i = 1; i <= length(pi); i++) {
	pmf_i = select(pmf, pmf[, 1] :== pi[i])
	opchar[i, ] = int_opchar_gs(pi[i], J, a, r, n, runningsum(n), k, pmf_i)
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

// Function for determining operating characteristics of group sequential design
real rowvector int_opchar_gs(real scalar pi, real scalar J,
                             real rowvector a, real rowvector r,
							 real rowvector n, real rowvector N,
							 real rowvector k,| real matrix pmf_pi)
{
  if (args() < 8) {
    pmf_pi = pmf_gs(pi, J, a, r, n, k)
  }
  A      = J(1, J, 0)
  R      = J(1, J, 0)
  for (j = 1; j <= J; j++) {
    A[j] = sum(select(pmf_pi, pmf_pi[, 2] :<= a[j] :& pmf_pi[, 4] :== j)[, 5])
    R[j] = sum(select(pmf_pi, pmf_pi[, 2] :>= r[j] :& pmf_pi[, 4] :== j)[, 5])
  }
  S      = A + R
  cum_S  = runningsum(S)
  if (any(cum_S :== 0.5)) {
    Med  = 0.5*(N[mm_which(cum_S :== 0.5)] + N[mm_which(cum_S :== 0.5) + 1])
  }
  else {
    Med  = N[mm_which(cum_S :> 0.5)[1]]
  }
  return((pi, sum(R), sum(N:*S), sum(N:^2:*S) - sum(N:*S)^2, Med, A, R, S, cum_S, sum(n)))
}

end
