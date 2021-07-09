*! Date    : 03 Jan 2019
*! Version : 1.2
*! Authors : Michael J Grayling & Adrian P Mander

/*
  16/04/15 v1.0 Basic version complete.
  08/09/17 v1.1 Added method option.
  03/01/19 v1.2 Converted mean and sigma to be optional with internal defaults.
                Removed method option for simplicity.
*/

program define rmvnormal, rclass
version 15.0
syntax , [n(integer 1) MEan(numlist) Sigma(string)]

///// Check input variables ////////////////////////////////////////////////////

local lenmean:list sizeof mean
if (`n' < 1) {
  di "{error}Number of random vectors to generate (n) must be a strictly positive integer."
  exit(198)
}
if ("`sigma'" != "") {
  if (colsof(`sigma') != rowsof(`sigma')) {
    di "{error}Covariance matrix Sigma (sigma) must be square."
    exit(198)
  }
  if ((`lenmean' != 0) & (`lenmean' != colsof(`sigma'))) {
    di "{error}Mean vector (mean) must be the same length as the dimension of covariance matrix Sigma (sigma)."
    exit(198)
  }
  cap mat chol = cholesky(`sigma')
  if (_rc > 0) {
    di "{error}Covariance matrix Sigma (sigma) must be symmetric positive-definite."
    exit(198)
  }
}
else {
  if (`lenmean' != 0) {
    mat chol   = I(`lenmean')
  }
  else {
    mat chol   = I(2)
  }
}

///// Perform main computations ////////////////////////////////////////////////

if (`lenmean' != 0) {
  local matamean ""
  foreach l of local mean {
    if "`matamean'" == "" local matamean "`l'"
    else local matamean "`matamean',`l'"
  }
  mat mean     = (`matamean')
}
else if ("`sigma'" != "") {
  mat mean     = J(1, colsof(`sigma'), 0)
}
else {
  mat mean     = J(1, 2, 0)
}
mata: rmvnormal_void(`n')

///// Output ///////////////////////////////////////////////////////////////////

return mat rmvnormal = rmatrix
end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void rmvnormal_void(n) {
  mean = st_matrix("mean")
  C    = st_matrix("chol")
  st_matrix("rmatrix", rmvnormal_mata(n, mean, ., C))
}

real matrix rmvnormal_mata(real scalar n, real vector mean,
                           real matrix Sigma,| real matrix C) {
  if (args() < 3) {
    C = cholesky(Sigma)
  }
  return((C*rnormal(rows(C), n, 0, 1))' + J(n, 1, mean))
}

end
