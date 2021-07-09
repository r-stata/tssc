*! Date    : 03 Jan 2019
*! Version : 1.4
*! Authors : Michael J Grayling & Adrian P Mander

/*
  16/04/15 v1.0 Basic version complete.
  02/10/15 v1.1 Changed method for computing density for better stability.
  08/09/17 v1.2 Added logdensity option and support for non-integer df.
  09/09/17 v1.3 Changed so df = 0 or df = . corresponds to mvnormalden.
  03/01/19 v1.4 Converted delta and sigma to be optional with internal defaults.
*/

program define mvtden, rclass
version 15.0
syntax , x(numlist) [DELta(numlist) Sigma(string) df(real 1) LOGdensity]

///// Check input variables ////////////////////////////////////////////////////

local lenx:list     sizeof x
local lendelta:list sizeof delta
if ((`lendelta' != 0) & (`lenx' != `lendelta')) {
  di "{error}Vector of quantiles (x) and vector of non-centrality parameters (delta) must be of equal length."
  exit(198)
}
if ("`sigma'" != "") {
  if (colsof(`sigma') != rowsof(`sigma')) {
    di "{error}Scale matrix Sigma (sigma) must be square."
    exit(198)
  }
  if (`lenx' != colsof(`sigma')) {
    di "{error}Vector of quantiles (x) must be the same length as the dimension of scale matrix Sigma (sigma)."
    exit(198)
  }
  cap mat chol = cholesky(`sigma')
  if (_rc > 0) {
    di "{error}Covariance matrix Sigma (sigma) must be symmetric positive-definite."
    exit(198)
  }
}
else {
  mat chol     = I(`lenx')
}
if (`df' < 0) {
  di "{error}Degrees of freedom (df) must be greater than or equal to zero."
  exit(198)
}

///// Perform main computations ////////////////////////////////////////////////

local matax ""
foreach l of local x {
  if "`matax'" == "" local matax "`l'"
  else local matax "`matax',`l'"
}
mat x       = (`matax')
if (`lendelta' != 0) {
  local matadelta ""
  foreach l of local delta {
    if "`matadelta'" == "" local matadelta "`l'"
    else local matadelta "`matadelta',`l'"
  }
  mat delta = (`matadelta')
}
else {
  mat delta = J(1, `lenx', 0)
}
mata: mvtden_void(`df')

///// Output ///////////////////////////////////////////////////////////////////

return scalar log_density = ret_density[2, 1]
return scalar density     = ret_density[1, 1]
if ("`logdensity'" == "") {
  di "{txt}density = {res}" ret_density[1, 1] "{txt}"
}
else {
  di "{txt}log(density) = {res}" ret_density[2, 1] "{txt}"
}
end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void mvtden_void(df) {
  x     = st_matrix("x")
  delta = st_matrix("delta")
  C     = st_matrix("chol")
  st_matrix("ret_density", mvtden_mata(x, delta, ., df,  C))
}

real colvector mvtden_mata(real vector x, real vector delta, real matrix Sigma,
                           real scalar df,| real matrix C) {
  if (args() < 5) {
    C           = cholesky(Sigma)
  }
  if ((df == 0) | (df == .)) {
    log_density = -sum(log(diagonal(C))) -
                    0.5*(rows(C)*log(2*pi()) +
					       colsum(lusolve(C, (x - delta)'):^2))
  }
  else {
    k           = rows(C)
    log_density = lngamma((df + k)/2) -
	                (lngamma(df/2) + sum(log(diagonal(C))) +
                      (k/2)*log(pi()*df)) -
					0.5*(df + k)*
					  log(1 + (colsum(lusolve(C, (x - delta)'):^2)/df))
  }
  return((exp(log_density) \ log_density))
}

end
