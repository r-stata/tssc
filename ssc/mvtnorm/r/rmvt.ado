*! Date    : 03 Jan 2019
*! Version : 1.3
*! Authors : Michael J Grayling & Adrian P Mander

/*
  16/04/15 v1.0 Basic version complete.
  08/09/17 v1.1 Added method option.
  09/09/17 v1.2 Changed so df = 0 or df = . corresponds to mvnormalden. Added
                support for non-integer df.
  03/01/19 v1.3 Converted delta and sigma to be optional with internal defaults.
                Removed method option for simplicity.
*/

program define rmvt, rclass
version 15.0
syntax , [n(integer 1) DELta(numlist) Sigma(string) df(real 1)]

///// Check input variables ////////////////////////////////////////////////////

local lendelta:list sizeof delta
if (`n' < 1) {
  di "{error}Number of random vectors to generate (n) must be a strictly positive integer."
  exit(198)
}
if ("`sigma'" != "") {
  if (colsof(`sigma') != rowsof(`sigma')) {
    di "{error}Scale matrix Sigma (sigma) must be square."
    exit(198)
  }
  if ((`lendelta' != 0) & (`lendelta' != colsof(`sigma'))) {
    di "{error}Vector of non-centrality parameters (delta) must be the same length as the dimension of scale matrix Sigma (sigma)."
    exit(198)
  }
  cap mat chol = cholesky(`sigma')
  if (_rc > 0) {
    di "{error}Scale matrix Sigma (sigma) must be symmetric positive-definite."
    exit(198)
  }
}
else {
  if (`lendelta' != 0) {
    mat chol   = I(`lendelta')
  }
  else {
    mat chol   = I(2)
  }
}

///// Perform main computations ////////////////////////////////////////////////

if (`lendelta' != 0) {
  local matadelta ""
  foreach l of local delta {
    if "`matadelta'" == "" local matadelta "`l'"
    else local matadelta "`matadelta',`l'"
  }
  mat delta = (`matadelta')
}
else if ("`sigma'" != "") {
  mat delta = J(1, colsof(`sigma'), 0)
}
else {
  mat delta = J(1, 2, 0)
}
mata: rmvt_void(`n', `df')

///// Output ///////////////////////////////////////////////////////////////////

return mat rmvt = rmatrix
end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void rmvt_void(n, df) {
  delta = st_matrix("delta")
  C     = st_matrix("chol")
  st_matrix("rmatrix", rmvt_mata(n, delta, ., df, C))
}

real matrix rmvt_mata(real scalar n, real vector delta, real matrix Sigma,
                      real scalar df, | real matrix C) {
  if (args() < 5) {
    C = cholesky(Sigma)
  }
  if ((df == 0) | (df == .)) {
    return((C*rnormal(rows(C), n, 0, 1))' + J(n, 1, delta))
  }
  else {
    return((C*rnormal(rows(C), n, 0, 1))':/sqrt(rchi2(n, 1, df)/df) +
			 J(n, 1, delta))
  }
}

end
