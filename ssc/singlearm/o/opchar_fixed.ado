*! Date    : 08 May 2018
*! Version : 1.0

/*
 08/05/18 v1.0 Initial version complete
*/

program define opchar_fixed, rclass
version 11.0
syntax, [n(integer 25) a(integer 5) pi(numlist) SUMmary(integer 0) PLot *]

local xopt `"`options'"'		 
preserve

///// Perform checks on input variables ////////////////////////////////////////

if (`n' <= 0) {
  di "{error} n must be an integer in (0,Inf)."
  exit(198)
}
if ((`a' < 0) | (`a' >= `n')) {
  di "{error} a must be an integer in [0,n)."
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

mata: OpcharFixed(`a', `n', `summary', "`plot'", `"`xopt'"')
matrix colnames pmf = pi s m "f(s,m|pi)"
return mat pmf = pmf
matrix colnames opchar = pi "P(pi)" "ESS(pi)" "VSS(pi)" "Med(pi)" "A1(pi)" "R1(pi)" "S1(pi)" 
return mat opchar = opchar
return mat n = n
return mat a = a
return mat pi = pi
return mat summary = summary

restore

end

///// Mata  ////////////////////////////////////////////////////////////////////

mata:

void OpcharFixed(a, n, summary, plot, xopt)
{

  pi = st_matrix("pi")
  if (pi == .) {
    pi = 0.01*(0::100)
  }

  ///// Print Summary //////////////////////////////////////////////////////////

  
  
  ///// Main Computations //////////////////////////////////////////////////////
  
  s   = 0::n
  pmf = J((n + 1)*length(pi), 4, 0)
  for (i = 1; i <= length(pi); i++) {
    pmf[(1 + (i - 1)*(n + 1))::(i*(n + 1)), ] = (J(n + 1, 1, pi[i]), s, J(n + 1, 1, n), binomialp(n, s, pi[i]))
  }
  opchar = J(length(pi), 9, 0)
  for (i = 1; i <= length(pi); i++) {
    P           = sum(select(pmf, pmf[, 1] :== pi[i] :& pmf[, 2] :>= a + 1)[, 4])
	opchar[i, ] = (pi[i], P, n, 0, n, 1 - P, P, 1, 1)
	if (summary == 1 & mod(i, 100) == 0) {
	  printf("{txt}...performance for {res}%g{txt} elements of pi evaluated...\n", i)
	}
  }
  if (plot ~= "") {
    st_matrix("opchar", opchar)
	stata("qui svmat opchar")
	stata(`"twoway line opchar2 opchar1, xtitle({&pi}) ytitle(P({&pi}))"'+ xopt)
  }
  
  ///// Return /////////////////////////////////////////////////////////////////
  
  if (summary == 1) {
    printf("...outputting.")
  }
  st_matrix("pmf", pmf)
  st_matrix("opchar", opchar)
  st_matrix("n", n)
  st_matrix("a", a)
  st_matrix("pi", pi')
  st_matrix("summary", summary)
}

end
