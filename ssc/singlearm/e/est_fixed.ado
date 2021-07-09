*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define est_fixed, rclass
version 11.0
syntax, [n(integer 25) pi(numlist) SUMmary(integer 0) PLot *]

local xopt `"`options'"'		 
preserve

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

mata: EstFixed(`n', `summary', "`plot'", `"`xopt'"')
matrix colnames est = s m "hat(pi)(s,m)"
return mat est = est
matrix colnames perf = pi "E(hat(pi)|pi)" "Var(hat(pi)|pi)" "Bias(hat(pi)|pi)" "RMSE(hat(pi)|pi)"
return mat perf = perf
return mat n = n
return mat pi = pi
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void EstFixed(n, summary, plot, xopt)
{

  pi = st_matrix("pi")
  if (pi == .) {
    pi = 0.01*(0::100)
  }

  ///// Print Summary //////////////////////////////////////////////////////////

  
  
  ///// Main Computations //////////////////////////////////////////////////////
  
  s    = 0::n
  n    = J(n + 1, 1, n)
  est  = (s, n, s:/n)
  perf = (pi, pi, J(length(pi), 2, 0))
  for (i = 1; i <= rows(perf); i++) {
    perf[i, 3] = sum(binomialp(n, s, perf[i, 1]):*(est[, 3]:^2)) - perf[i, 2]^2
	if (summary == 1 & mod(i, 100) == 0) {
	  printf("{txt}...performance for {res}%g{txt} elements of pi evaluated...\n", i)
	}
  }
  perf = (perf, sqrt(perf[, 3]))

  if (plot ~= "") {
    st_matrix("perf", perf)
	stata("qui svmat perf")
	stata(`"twoway line perf5 perf1, xtitle({&pi}) ytitle({it:RMSE}(hat({&pi})|{&pi}))"'+ xopt)
  }
  
  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting.")
  }
  st_matrix("est", est)
  st_matrix("perf", perf)
  st_matrix("n", n)
  st_matrix("pi", pi')
  st_matrix("summary", summary)
}

end
