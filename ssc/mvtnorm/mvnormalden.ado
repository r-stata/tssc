*! Date    : 03 Jan 2019
*! Version : 1.3
*! Authors : Michael J Grayling & Adrian P Mander

/*
  16/04/15 v1.0 Basic version complete.
  02/10/15 v1.1 Changed method for computing density for better stability.
  08/09/17 v1.2 Added logdensity option.
  03/01/19 v1.3 Converted mean and sigma to be optional with internal defaults.
*/

program define mvnormalden, rclass
version 15.0
syntax , x(numlist) [MEan(numlist) Sigma(string) LOGdensity]

///// Check input variables ////////////////////////////////////////////////////

local lenx:list    sizeof x
local lenmean:list sizeof mean
if ((`lenmean' != 0) & (`lenx' != `lenmean')) {
  di "{error}Vector of quantiles (x) and mean vector (mean) must be of equal length."
  exit(198)
}
if ("`sigma'" != "") {
  if (colsof(`sigma') != rowsof(`sigma')) {
    di "{error}Covariance matrix Sigma (sigma) must be square."
    exit(198)
  }
  if (`lenx' != colsof(`sigma')) {
    di "{error}Vector of quantiles (x) must be the same length as the dimension of covariance matrix Sigma (sigma)."
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

///// Perform main computations ////////////////////////////////////////////////

local matax ""
foreach l of local x {
  if "`matax'" == "" local matax "`l'"
  else local matax "`matax',`l'"
}
mat x      = (`matax')
if (`lenmean' != 0) {
  local matamean ""
  foreach l of local mean {
    if "`matamean'" == "" local matamean "`l'"
    else local matamean "`matamean',`l'"
  }
  mat mean = (`matamean')
}
else {
  mat mean = J(1, `lenx', 0)
}
mata: mvnormalden_void()

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

void mvnormalden_void() {
  x    = st_matrix("x")
  mean = st_matrix("mean")
  C    = st_matrix("chol")
  st_matrix("ret_density", mvnormalden_mata(x, mean, ., C))
}

real colvector mvnormalden_mata(real vector x, real vector mean,
                                real matrix Sigma,| real matrix C) {
  if (args() < 4) {
    C         = cholesky(Sigma)
  }
  log_density = -sum(log(diagonal(C))) -
                  0.5*(rows(C)*log(2*pi()) + colsum(lusolve(C, (x - mean)'):^2))
  return((exp(log_density) \ log_density))
}

end
