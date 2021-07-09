*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define des_gehan, rclass
version 11.0
syntax, [pi1(real 0.3) Beta1(real 0.1) Gamma(real 0.05) Alpha(real 1) ///
         SUMmary(integer 0) PLot *]

local xopt `"`options'"'		 
preserve

///// Perform checks on input variables ////////////////////////////////////////

if ((`pi1' <= 0) | (`pi1' >= 1)) {
  di "{error} pi1 must be a real strictly between 0 and 1."
  exit(198)
}
if ((`beta1' <= 0) | (`beta1' >= 1)) {
  di "{error} beta1 must be a real strictly between 0 and 1."
  exit(198)
}
if ((`gamma' <= 0) | (`gamma' >= 1)) {
  di "{error} gamma must be a real strictly between 0 and 1."
  exit(198)
}
if ((`alpha' < 0) | (`alpha' > 1)) {
  di "{error} alpha must be a real between 0 and 1 (inclusive)."
  exit(198)
}

///// Compute and Output ///////////////////////////////////////////////////////

mata: DesGehan(`pi1', `beta1', `gamma', `alpha', `summary', "`plot'", `"`xopt'"')
return mat des = des
matrix colnames opchar = pi1 "ESS(pi1)" "VSS(pi1)" "Med(pi1)" "S1(pi1)" "S2(pi1)" "cum(S1(pi1))" "cum(S2(pi1))"
return mat opchar = opchar
return mat n1 = n1
return mat n2 = n2
return mat a1 = a1
return mat r1 = r1
return mat pi1 = pi1
return mat beta1 = beta1
return mat gamma = gamma
return mat alpha = alpha
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void DesGehan(pi1, beta1, gamma, alpha, summary, plot, xopt)
{

  ///// Print Summary //////////////////////////////////////////////////////////

  
  
  ///// Main Computations //////////////////////////////////////////////////////
  
  n1          = 1
  rej_error   = binomialp(n1, 0, pi1)
  while (rej_error > beta1) {
    n1        = n1 + 1
	rej_error = binomialp(n1, 0, pi1)
  }
  s1            = (0::n1)'
  n2            = J(1, n1 + 1, 0)
  for (s1 = 1; s1 <= n1; s1++) {
    poss_pi_hat = (ci_fixed_wald(s1, n1, alpha), s1/n1)
	pi_hat      = poss_pi_hat[order(poss_pi_hat' :- 0.5, 1)[1]]
	while (sqrt(pi_hat*(1 - pi_hat)/(n1 + n2[s1 + 1])) > gamma) {
	  n2[s1 + 1] = n2[s1 + 1] + 1
	}
  }
  a1 = max(mm_which(runningsum(n2) :== 0)) - 1
  if (n2[n1 + 1] == 0) {
    r1 = max(mm_which(n2 :> 0))
  }
  else {
    r1 = n1 + 1
  }
  
  opchar = int_opchar_gehan(pi1, a1, r1, n1, n2, (1::2)')
  if (r1 == n1 + 1) {
    r1 = .
  }
  des = (n1, n2, a1, r1, opchar)
  
  if (plot ~= "") {
    st_matrix("sizes", ((0::n1), n2'))
	stata("qui svmat sizes")
	stata(`"twoway (line sizes2 sizes1, color(black)) (scatter sizes2 sizes1, color(black)), xtitle({it:s}{subscript:1}) ytitle({it:n}{subscript:2}({it:s}{subscript:1})) legend(off)"'+ xopt)
  }

  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting")
  }
  
  st_matrix("des", des)
  st_matrix("opchar", opchar)
  st_matrix("n1", n1)
  st_matrix("n2", n2)
  st_matrix("a1", a1)
  st_matrix("r1", r1)
  st_matrix("pi1", pi1)
  st_matrix("beta1", beta1)
  st_matrix("gamma", gamma)
  st_matrix("alpha", alpha)
  st_matrix("summary", summary)
}

// Function for determining Wald CI in a fixed design
real rowvector ci_fixed_wald(real scalar s, real scalar m, real scalar alpha)
{
  pi_hat  = s/m
  if (s == 0){
    piL   = 0
    piU   = 0
  } else if (s == m){
    piL   = 1
    piU   = 1
  } else {
    piL   = pi_hat - invnormal(1 - alpha/2)*sqrt(pi_hat*(1 - pi_hat)/m)
    piU   = pi_hat + invnormal(1 - alpha/2)*sqrt(pi_hat*(1 - pi_hat)/m)
    if (piL < 0) {
      piL = 0
    } else if (piL > 1) {
      piL = 1
    }
    if (piU < 0) {
      piU = 0
    } else if (piU > 1) {
      piU = 1
    }
  }
  return((piL, piU))
}

// Function for determining pmf of an adaptive design
real matrix pmf_gehan(real scalar pi, real scalar a1, real scalar r1,
                      real scalar n1, real rowvector n2,
					  real rowvector k,| real matrix dbinom_pi)
{
  if (r1 == .) {
    r1 = n1 + 1
  }
  if (args() < 7) {
    dbinom_pi = J(max((n1, n2)) + 1, max((n1, n2)), 0)
    dbinom_pi[1::(n1 + 1), n1] = binomialp(n1, 0::n1, pi)
	for (i = 1; i <= n1 + 1; i++) {
	  if (n2[i] > 0) {
	    dbinom_pi[1::(n2[i] + 1), n2[i]] = binomialp(n2[i], 0::n2[i], pi)
	  }
    }
  }
  terminal = terminal_states_adaptive(a1, r1, ., ., n1, n2, k)
  f = 0
  if (any(k :== 1)) {
    if (a1 >= 0) {
      f = (f \ dbinom_pi[1::(a1 + 1), n1])
    }
    if (r1 ~= .) {
      f = (f \ dbinom_pi[(r1 + 1)::(n1 + 1), n1])
    }
  }
  if (any(k :== 2)) {
    if (a1 < r1 & a1 < n1) {
	  for (s1 = a1 + 1; s1 <= min((n1, r1 - 1)); s1++) {
        f = (f \ dbinom_pi[s1 + 1, n1]*dbinom_pi[1::(1 + n2[s1 + 1]), n2[s1 + 1]])
      }
	}
  }
  f   = f/sum(f)
  f   = f[2::length(f)]
  pmf = (J(rows(terminal), 1, pi), terminal[, 1], terminal[, 2], terminal[, 3], terminal[, 4], f)
  return(pmf)
}

// Function for determining operating characteristics of an adaptive design
real rowvector int_opchar_gehan(real scalar pi, real scalar a1, real scalar r1,
                                real scalar n1, real rowvector n2,
								real rowvector k,| real matrix pmf_pi)
{
  if (r1 == .) {
    r1 = n1 + 1
  }
  if (args() < 7) {
    pmf_pi = pmf_gehan(pi, a1, r1, n1, n2, k)
  }
  S      = J(1, 2, 0)
  S[1]   = sum(select(pmf_pi, pmf_pi[, 3] :<= a1 :& pmf_pi[, 5] :== 1)[, 6]) + sum(select(pmf_pi, pmf_pi[, 3] :>= r1 :& pmf_pi[, 5] :== 1)[, 6])
  S[2]   = 1 - S[1]
  poss_n = uniqrows(pmf_pi[, 4])'
  prob_n = J(1, length(poss_n), 0)
  for (i = 1; i <= length(poss_n); i++) {
    prob_n[i] = sum(select(pmf_pi, pmf_pi[, 4] :== poss_n[i])[, 6])
  }
  cum_prob_n  = runningsum(prob_n)
  if (any(cum_prob_n :== 0.5)) {
    Med       = 0.5*(poss_n[mm_which(cum_prob_n :== 0.5)] + poss_n[mm_which(cum_prob_n :== 0.5) + 1])
  }
  else {
    Med       = poss_n[mm_which(cum_prob_n :> 0.5)[1]]
  }
  return((pi, sum(poss_n:*prob_n), sum(poss_n:^2:*prob_n) - sum(poss_n:*prob_n)^2, Med, S, runningsum(S)))
}

// Function to determine terminal states in an adaptive design
real matrix terminal_states_adaptive(real scalar a1, real scalar r1,
                                     real rowvector a2, real rowvector r2,
									 real scalar n1, real rowvector n2,
									 real rowvector k)
{
  if (a1 == .) {
    a1 = -1
  }
  if (r1 == .) {
    r1 = n1 + 1
  }
  terminal   = J(1, 4, 0)
  if (a1 >= 0) {
    s1       = 0::a1
    terminal = (terminal \ (s1, s1, J(a1 + 1, 1, n1), J(a1 + 1, 1, 1)))
  }
  if (r1 ~= .) {
    s1       = r1::n1
    terminal = (terminal \ (s1, s1, J(n1 - r1 + 1, 1, n1), J(n1 - r1 + 1, 1, 1)))
  }
  if (a1 < r1 & a1 < n1) {
    for (s1 = max((0, a1 + 1)); s1 <= min((r1 - 1, n1)); s1++) {
      vals     = s1 :+ (0::n2[s1 + 1])
	  terminal = (terminal \ (J(n2[s1 + 1] + 1, 1, s1), vals, J(n2[s1 + 1] + 1, 1, n1 + n2[s1 + 1]), J(n2[s1 + 1] + 1, 1, 2)))
    }
  }
  keep_rows     = mm_which(terminal[, 4] :== k[1])
  if (length(k) > 1) {
    for (els = 2; els <= length(k); els++) {
	  keep_rows = (keep_rows \ mm_which(terminal[, 4] :== k[els]))
	}
  }
  terminal      = terminal[keep_rows, ]
  return(terminal)
}

end
