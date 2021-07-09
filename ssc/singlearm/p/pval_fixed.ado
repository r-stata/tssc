*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define pval_fixed, rclass
version 11.0
syntax, [n(integer 25) pi0(real 0.1) pi(numlist) method(string) ///
         SUMmary(integer 0) PLot *]

local xopt `"`options'"'		 
preserve

if ("`method'" == "") {
  local method "all"
}

///// Perform checks on input variables ////////////////////////////////////////

if (`n' <= 0) {
  di "{error} n must be an integer in (0,Inf)."
  exit(198)
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
if ("`method'" ~= "all" & "`method'" ~= "exact" & "`method'" ~= "normal") {
  di "{error} method must be one of: all, exact, or normal."
  exit(198)
}
// Set up matrices to pass to mata
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

mata: PvalFixed(`n', `pi0', "`method'", `summary', "`plot'", `"`xopt'"')
matrix colnames pval = s m Method "p(s,m)"
return mat pval = pval
matrix colnames perf = pi Method "E(p|pi)" "Var(p|pi)"
return mat perf = perf
return mat n = n
return mat pi0 = pi0
return mat pi = pi
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void PvalFixed(n, pi0, method, summary, plot, xopt)
{

  pi = st_matrix("pi")
  if (pi == .) {
    pi = 0.01*(0::100)
  }

  ///// Print Summary //////////////////////////////////////////////////////////

  
  
  ///// Main Computations //////////////////////////////////////////////////////
  
  if (method == "all") {
    int_method = (1 \ 2)
  }
  else if (method == "exact") {
    int_method = 1
  }
  else {
    int_method = 2
  }
  s    = 0::n
  n    = J(n + 1, 1, n)
  pval = (vec(J(length(int_method), 1, s')), vec(J(length(int_method), 1, n')), J(n[1] + 1, 1, int_method), J(length(int_method)*(n[1] + 1), 1, 0))
  for (i = 1; i <= rows(pval); i++) {
    if (pval[i, 3] == 1) {
	  pval[i, 4] = pval_fixed_exact(pval[i, 1], pval[i, 2], pi0)
	}
	else {
	  pval[i, 4] = pval_fixed_normal(pval[i, 1], pval[i, 2], pi0)
	}
	if (summary == 1 & mod(i, 100) == 0) {
	  printf("{txt}...{res}%g{txt} p-values determined...\n", i)
	}
  }
  dbinomial_pi = J(n[1] + 1, length(pi), 0)
  for (i = 1; i <= length(pi); i++) {
    dbinomial_pi[, i] = binomialp(n[1], 0::n[1], pi[i])
  }
  perf = (J(length(int_method), 1, pi), vec(J(length(pi), 1, int_method')), J(length(pi)*length(int_method), 2, 0))
  for (i = 1; i <= rows(perf); i++) {
    pval_i     = select(pval, pval[, 3] :== perf[i, 2])
	pi_index   = mm_which(pi :== perf[i, 1])
	perf[i, 3] = sum(dbinomial_pi[, pi_index]:*pval_i[, 4])
	perf[i, 4] = sum(dbinomial_pi[, pi_index]:*(pval_i[, 4]:^2)) - perf[i, 3]^2
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
	  st_matrix("perf1", perf1)
      st_matrix("perf2", perf2)
      stata("qui svmat perf1")
	  stata("qui svmat perf2")
	  stata(`"twoway (line perf13 perf11, color(blue)) (line perf23 perf21, color(red)), xtitle({&pi}) ytitle(E({it:p}|{&pi})) legend(lab(1 "Exact") lab(2 "Normal"))"'+ xopt)
	}
  }

  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting.")
  }
  
  st_matrix("pval", pval)
  st_matrix("perf", perf)
  st_matrix("n", n[1])
  st_matrix("pi0", pi0)
  st_matrix("pi", pi')
  st_matrix("summary", summary)
}

// Function for finding p-value, using the exact method, in a fixed design
real scalar pval_fixed_exact(real scalar s, real scalar m, real scalar pi0)
{
  return(binomialtail(m, s, pi0))
}

// Function for finding p-value, using the normal method, in a fixed design
real scalar pval_fixed_normal(real scalar s, real scalar m, real scalar pi0)
{
  return(1 - normal((s/m - pi0)/sqrt(pi0*(1 - pi0)/m)))
}

end
