*! Date    : 03 Jan 2019
*! Version : 1.1
*! Authors : Michael J Grayling & Adrian P Mander

/*
  30/10/17 v1.0 Basic version complete.
  03/01/19 v1.1 Minor changes for speed. Converted delta and sigma to be 
                optional with internal defaults. Removed the method option for
				simplicity.
*/

program define rtmvt, rclass
version 15.0
syntax , LOWERTruncation(numlist miss) UPPERTruncation(numlist miss) ///
         [n(integer 1) DELta(numlist) Sigma(string) df(real 1)]

///// Check input variables ////////////////////////////////////////////////////
		 
local lendelta:list  sizeof delta
local lenlowert:list sizeof lowertruncation
local lenuppert:list sizeof uppertruncation
if (`lenlowert' != `lenuppert') {
  di "{error}Lower truncation vector (lowertruncation) and upper truncation vector (uppertruncation) must be of equal length."
  exit(198)
}
forvalues i = 1/`lenlowert' {
  local lowerti:word `i' of `lowertruncation'
  local upperti:word `i' of `uppertruncation'
  if ((`lowerti' != .) & (`upperti' != .)) {
    if (`lowerti' >= `upperti') {
      di "{error}Each lower truncation limit (in lowertruncation) must be strictly less than the corresponding upper truncation limit (in uppertruncation)."
      exit(198)
    }
  }
}
if (`n' < 1) {
  di "{error}Number of random vectors to generate (n) must be a strictly positive integer."
  exit(198)
}
if ((`lendelta' != 0) & (`lenlowert' != `lendelta')) {
  di "{error}Vector of non-centrality parameters (delta) and lower truncation vector (lowertruncation) must be of equal length."
  exit(198)
}
if ("`sigma'" != "") {
  if (colsof(`sigma') != rowsof(`sigma')) {
    di "{error}Scale matrix Sigma (sigma) must be square."
    exit(198)
  }
  if (`lenlowert' != colsof(`sigma')) {
    di "{error}Lower truncation vector (lowertruncation) must be the same length as the dimension of scale matrix Sigma (sigma)."
    exit(198)
  }
  cap mat chol = cholesky(`sigma')
  if (_rc > 0) {
    di "{error}Scale matrix Sigma (sigma) must be symmetric positive-definite."
    exit(198)
  }
  mat sigma    = (`sigma')
}
else {
  mat sigma    = I(`lenlowert')
  mat chol     = I(`lenlowert')
}
if (`df' < 0) {
  di "{error}Degrees of freedom (df) must be greater than or equal to zero."
  exit(198)
}

///// Perform main computations ////////////////////////////////////////////////

local matalowert ""
foreach l of local lowertruncation {
  if "`matalowert'" == "" local matalowert "`l'"
  else local matalowert "`matalowert',`l'"
}
mat lowert  = (`matalowert')
local matauppert ""
foreach l of local uppertruncation {
  if "`matauppert'" == "" local matauppert "`l'"
  else local matauppert "`matauppert',`l'"
}
mat uppert  = (`matauppert')
if (`lendelta' != 0) {
  local matadelta ""
  foreach l of local delta {
    if "`matadelta'" == "" local matadelta "`l'"
    else local matadelta "`matadelta',`l'"
  }
  mat delta = (`matadelta')
}
else {
  mat delta = J(1, `lenlowert', 0)
}
mata: rtmvt_void(`n', `df')

///// Output ///////////////////////////////////////////////////////////////////

return mat rtmvt = rmatrix
end

///// Mata /////////////////////////////////////////////////////////////////////

mata:

void rtmvt_void(n, df) {
  lowert = st_matrix("lowert")
  uppert = st_matrix("uppert")
  delta  = st_matrix("delta")
  C      = st_matrix("chol")
  st_matrix("rmatrix", rtmvt_mata(n, lowert, uppert, delta, ., df, C))
}

real matrix rtmvt_mata(real scalar n, real vector lowert, real vector uppert,
                       real vector delta, real matrix Sigma,
					   real scalar df,| real matrix C) {
  if (args() < 7) {
    C              = cholesky(Sigma)
  }
  k                = rows(C)
  rmatrix          = J(n, k, 0)
  i                = 1
  while (i <= n) {
    if ((df > 0) & (df != .)) {
      gensample    = (C*rnormal(k, 1, 0, 1))':/sqrt(rchi2(1, 1, df)) + delta
	}
	else {
	  gensample    = (C*rnormal(k, 1, 0, 1))' + delta
	}
    check          = 1
	for (j = 1; j <= k; j++) {
	  if ((gensample[j] < lowert[j]) | (gensample[j] > uppert[j])) {
	    check      = 0
		break
	  }
	}
	if (check == 1) {
	  rmatrix[i, ] = gensample
	  i            = i + 1
	}
  }
  return(rmatrix)
}

end
