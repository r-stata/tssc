*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define ci_fixed, rclass
version 11.0
syntax, [n(integer 25) pi(numlist) alpha(real 0.05) method(string) ///
         SUMmary(integer 0) PLot(string) *]

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
if ((`alpha' <= 0) | (`alpha' >= 1)) {
  di "{error} alpha must be a real strictly between 0 and 1."
  exit(198)
}
if ("`method'" ~= "all" & "`method'" ~= "agresti_coull" & "`method'" ~= "clopper_pearson" & "`method'" ~= "jeffreys" & "`method'" ~= "mid_p" & "`method'" ~= "wald" & "`method'" ~= "wilson") {
  di "{error} method must be one of: all, agresti_coull, clopper_pearson, jeffreys, mid_p, wald, or wilson."
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
if ("`plot'" ~= "" ) {
  if ("`plot'" ~= "coverage" & "`plot'" ~= "length") {
    di "{error} plot must be one of: coverage and length."
    exit(198)
  }
}

///// Compute and Output ///////////////////////////////////////////////////////

mata: CIFixed(`n', `alpha', "`method'", `summary', "`plot'", `"`xopt'"')
matrix colnames ci = s m Method "clow(s,m)" "cupp(s,m)" "l(s,m)"
return mat ci = ci
matrix colnames perf = pi Method "bar(L)" "max(L)" "E(L|pi)" "Var(L|pi)" "Cover(C|pi)"
return mat perf = perf
return mat n = n
return mat pi = pi
return mat alpha = alpha
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void CIFixed(n, alpha, method, summary, plot, xopt)
{

  pi = st_matrix("pi")
  if (pi == .) {
    pi = 0.01*(0::100)
  }

  ///// Print Summary //////////////////////////////////////////////////////////

  
  
  ///// Main Computations //////////////////////////////////////////////////////

  if (method == "all") {
    int_method = 1::6
  }
  else if (method == "agresti_coull") {
    int_method = 1
  }
  else if (method == "clopper_pearson") {
    int_method = 2
  }
  else if (method == "jeffreys") {
    int_method = 3
  }
  else if (method == "mid_p") {
    int_method = 4
  }
  else if (method == "wald") {
    int_method = 5
  }
  else {
    int_method = 6
  }
  s  = 0::n
  n  = J(n + 1, 1, n)
  ci = (vec(J(length(int_method), 1, s')), vec(J(length(int_method), 1, n')), J(n[1] + 1, 1, int_method), J(length(int_method)*(n[1] + 1), 2, 0))
  for (i = 1; i <= rows(ci); i++) {
	if (ci[i, 3] == 1) {
	  ci[i, 4::5] = ci_fixed_agresti_coull(ci[i, 1], ci[i, 2], alpha)
	}
	else if (ci[i, 3] == 2) {
	  ci[i, 4::5] = ci_fixed_clopper_pearson(ci[i, 1], ci[i, 2], alpha)
	}
	else if (ci[i, 3] == 3) {
	  ci[i, 4::5] = ci_fixed_jeffreys(ci[i, 1], ci[i, 2], alpha)
	}
	else if (ci[i, 3] == 4) {
	  ci[i, 4::5] = ci_fixed_mid_p(ci[i, 1], ci[i, 2], alpha)
	}
	else if (ci[i, 3] == 5) {
	  ci[i, 4::5] = ci_fixed_wald(ci[i, 1], ci[i, 2], alpha)
	}
	else if (ci[i, 3] == 6) {
	  ci[i, 4::5] = ci_fixed_wilson(ci[i, 1], ci[i, 2], alpha)
	}
	if (summary == 1 & mod(i, 100) == 0) {
	  printf("{txt}...{res}%g{txt} confidence intervals determined...\n", i)
	}
  }
  ci = (ci, ci[, 5] - ci[, 4])
  dbinomial_pi = J(n[1] + 1, length(pi), 0)
  for (i = 1; i <= length(pi); i++) {
    dbinomial_pi[, i] = binomialp(n[1], 0::n[1], pi[i])
  }
  perf = (J(length(int_method), 1, pi), vec(J(length(pi), 1, int_method')), J(length(pi)*length(int_method), 5, 0))
  for (i = 1; i <= rows(perf); i++) {
    ci_i     = select(ci, ci[, 3] :== perf[i, 2])
	pi_index   = mm_which(pi :== perf[i, 1])
	perf[i, 3] = sum(dbinomial_pi[, pi_index]:*ci_i[, 6])
	perf[i, 4] = sum(dbinomial_pi[, pi_index]:*(ci_i[, 6]:^2)) - perf[i, 3]^2
	perf[i, 5] = mean(ci_i[, 6])
	perf[i, 6] = max(ci_i[, 6])
	coverage   = select(ci_i, ci_i[, 4] :<= perf[i, 1] :& ci_i[, 5] :>= perf[i, 1])
	perf[i, 7] = sum(dbinomial_pi[coverage[, 1] :+ 1, pi_index])
	if (summary == 1 & mod(i, 100) == 0) {
	  printf("{txt}...performance for {res}%g{txt} elements of pi evaluated...\n", i)
	}
  }
  if (plot == "length") {
	if (method ~= "all") {
	  st_matrix("perf", perf)
	  stata("qui svmat perf")
	  stata(`"twoway line perf3 perf1, xtitle({&pi}) ytitle(E({it:L}|{&pi}))"'+ xopt)
	}
	else {
	  perf1 = select(perf, perf[, 2] :== 1)
	  perf2 = select(perf, perf[, 2] :== 2)
	  perf3 = select(perf, perf[, 2] :== 3)
	  perf4 = select(perf, perf[, 2] :== 4)
	  perf5 = select(perf, perf[, 2] :== 5)
	  perf6 = select(perf, perf[, 2] :== 6)
      st_matrix("perf1", perf1)
      st_matrix("perf2", perf2)
      st_matrix("perf3", perf3)
      st_matrix("perf4", perf4)
      st_matrix("perf5", perf5)
	  st_matrix("perf6", perf6)
	  stata("qui svmat perf1")
	  stata("qui svmat perf2")
	  stata("qui svmat perf3")
	  stata("qui svmat perf4")
	  stata("qui svmat perf5")
	  stata("qui svmat perf6")
	  stata(`"twoway (line perf13 perf11, color(black)) (line perf23 perf21, color(blue)) (line perf33 perf31, color(red)) (line perf43 perf41, color(green)) (line perf53 perf51, color(yellow)) (line perf63 perf61, color(orange)), xtitle({&pi}) ytitle(E({it:L}|{&pi})) legend(lab(1 "Agresti-Coull") lab(2 "Clopper-Pearson") lab(3 "Jeffreys") lab(4 "Mid-p") lab(5 "Wald") lab(6 "Wilson"))"'+ xopt)
	}
  }
  else if (plot == "coverage") {
    if (method ~= "all") {
	  st_matrix("perf", perf)
	  stata("qui svmat perf")
	  stata(`"twoway line perf7 perf1, xtitle({&pi}) ytitle(E({it:L}|{&pi}))"'+ xopt)
	}
	else {
	  perf1 = select(perf, perf[, 2] :== 1)
	  perf2 = select(perf, perf[, 2] :== 2)
	  perf3 = select(perf, perf[, 2] :== 3)
	  perf4 = select(perf, perf[, 2] :== 4)
	  perf5 = select(perf, perf[, 2] :== 5)
	  perf6 = select(perf, perf[, 2] :== 6)
      st_matrix("perf1", perf1)
      st_matrix("perf2", perf2)
      st_matrix("perf3", perf3)
      st_matrix("perf4", perf4)
      st_matrix("perf5", perf5)
	  st_matrix("perf6", perf6)
	  stata("qui svmat perf1")
	  stata("qui svmat perf2")
	  stata("qui svmat perf3")
	  stata("qui svmat perf4")
	  stata("qui svmat perf5")
	  stata("qui svmat perf6")
	  stata(`"twoway (line perf17 perf11, color(black)) (line perf27 perf21, color(blue)) (line perf37 perf31, color(red)) (line perf47 perf41, color(green)) (line perf57 perf51, color(yellow)) (line perf67 perf61, color(orange)), xtitle({&pi}) ytitle({it:Cover}({it:C}|{&pi})) legend(lab(1 "Agresti-Coull") lab(2 "Clopper-Pearson") lab(3 "Jeffreys") lab(4 "Mid-p") lab(5 "Wald") lab(6 "Wilson"))"'+ xopt)
	}
  }

  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting.")
  }
  
  st_matrix("ci", ci)
  st_matrix("perf", perf)
  st_matrix("n", n[1])
  st_matrix("pi", pi')
  st_matrix("alpha", alpha)
  st_matrix("summary", summary)
}

// Function for determining Agresti-Coull CI in a fixed design
real rowvector ci_fixed_agresti_coull(real scalar s, real scalar m,
                                      real scalar alpha)
{
  if (s == 0) {
    m_tilde  = m + invnormal(alpha)^2
    pi_tilde = (s + 0.5*invnormal(alpha)^2)/m_tilde
    piL      = 0
    piU      = pi_tilde - invnormal(alpha)*sqrt(pi_tilde*(1 - pi_tilde)/m_tilde)
    if (piU < 0) {
      piU    = 0
    }
	else if (piU > 1) {
      piU    = 1
    }
  }
  else if (s == m) {
    m_tilde  = m + invnormal(alpha)^2
    pi_tilde = (s + 0.5*invnormal(alpha)^2)/m_tilde
    piL      = pi_tilde + invnormal(alpha)*sqrt(pi_tilde*(1 - pi_tilde)/m_tilde)
    piU      = 1
    if (piL < 0) {
      piL    = 0
    }
	else if (piL > 1) {
      piL    = 1
    }
  }
  else {
    m_tilde  = m + invnormal(alpha/2)^2
    pi_tilde = (s + 0.5*invnormal(alpha/2)^2)/m_tilde
    piL      = pi_tilde + invnormal(alpha/2)*sqrt(pi_tilde*(1 - pi_tilde)/m_tilde)
    piU      = pi_tilde - invnormal(alpha/2)*sqrt(pi_tilde*(1 - pi_tilde)/m_tilde)
    if (piL < 0) {
      piL    = 0
    }
	else if (piL > 1) {
      piL    = 1
    }
    if (piU < 0) {
      piU    = 0
    }
	else if (piU > 1) {
      piU    = 1
    }
  }
  return((piL, piU))
}

// Function for determining Clopper-Pearson CI in a fixed design
real rowvector ci_fixed_clopper_pearson(real scalar s, real scalar m,
                                        real scalar alpha)
{
  if (s == 0) {
    piL = 0
    piU = 1 - (alpha/2)^(1/m)
  }
  else if (s == m) {
    piL = (alpha/2)^(1/m)
    piU = 1
  }
  else {
    piL = invibeta(s, m - s + 1, alpha/2)
	piU = invibeta(s + 1, m - s, 1 - alpha/2)
  }
  return((piL, piU))
}

// Function for determining Jeffreys CI in a fixed design
real rowvector ci_fixed_jeffreys(real scalar s, real scalar m,
                                 real scalar alpha)
{
  if (s == 0) {
    piL = 0
    piU = invibeta(s + 0.5, m - s + 0.5, 1 - alpha)
  } else if (s == m) {
    piL = invibeta(s + 0.5, m - s + 0.5, alpha)
    piU = 1
  } else {
    piL = invibeta(s + 0.5, m - s + 0.5, alpha/2)
    piU = invibeta(s + 0.5, m - s + 0.5, 1 - alpha/2)
  }
  return((piL, piU))
}

real scalar lower_lim(real scalar pi, real scalar s, real scalar m,
                      real scalar alpha)
{
    return(0.5*binomialp(m, s, pi) + binomialtail(m, s + 1, pi) - alpha/2)
}

real scalar upper_lim(real scalar pi, real scalar s, real scalar m,
                      real scalar alpha)
{
    return(0.5*binomialp(m, s, pi) + binomial(m, s - 1, pi) - alpha/2)
}

// Function for determining mid-p CI in a fixed design
real rowvector ci_fixed_mid_p(real scalar s, real scalar m, real scalar alpha)
{
  if (s == 0) {
    piL   = 0
    piU   = 1 - alpha^(1/m)
  }
  else if (s == m) {
    piL   = alpha^(1/m)
    piU   = 1
  }
  else {
    output = mm_root(piL = ., &lower_lim(), 0, s/m, 0, 1000, s, m, alpha)
	if (output ~= 0) {
	  error("Root finding algorithm did not converge")
	}
	output = mm_root(piU = ., &upper_lim(), s/m, 1, 0, 1000, s, m, alpha)
    if (output ~= 0) {
	  error("Root finding algorithm did not converge")
	}
	if (piL < 0) {
      piL = 0
    }
	else if (piL > 1) {
      piL = 1
    }
    if (piU < 0) {
      piU = 0
    }
	else if (piU > 1) {
      piU = 1
    }
  }
  return((piL, piU))
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

// Function for determining Wilson CI in a fixed design
real rowvector ci_fixed_wilson(real scalar s, real scalar m, real scalar alpha)
{
  pi_hat  = s/m
  if (s == 0){
    z     = invnormal(1 - alpha)
    z2    = z^2
    piL   = 0
    piU   = (pi_hat + z2/(2*m) + z*sqrt(pi_hat*(1 - pi_hat)/m + z2/(4*m^2)))/(1 + z2/m)
    if (piU < 0) {
      piU = 0
    } else if (piU > 1) {
      piU = 1
    }
  } else if (s == m){
    z     = invnormal(1 - alpha)
    z2    = invnormal(1 - alpha)^2
    piL   = (pi_hat + z2/(2*m) - z*sqrt(pi_hat*(1 - pi_hat)/m + z2/(4*m^2)))/(1 + z2/m)
    piU   = 1
    if (piL < 0) {
      piL = 0
    } else if (piL > 1) {
      piL = 1
    }
  } else {
    z     = -invnormal(alpha/2)
    z2    = z^2
    piL   = (pi_hat + z2/(2*m) - z*sqrt(pi_hat*(1 - pi_hat)/m + z2/(4*m^2)))/(1 + z2/m)
    piU   = (pi_hat + z2/(2*m) + z*sqrt(pi_hat*(1 - pi_hat)/m + z2/(4*m^2)))/(1 + z2/m)
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

end
