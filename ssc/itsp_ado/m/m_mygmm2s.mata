mata:mata clear
version 10.1
mata: mata set matastrict on
mata:
// m_mygmm2s 1.0.0 MES/CFB 11aug2008
void m_mygmm2s(string scalar yname, 
               string scalar endognames, 
               string scalar inexognames, 
               string scalar exexognames, 
               string scalar touse, 
               string scalar robust)

{
	real matrix Y, X1, X2, Z1, X, Z, QZZ, QZX, W, omega, V
	real vector cons, beta_iv, beta_gmm, e, gbar
	real scalar K, L, N, j
	
// Use st_tsrevar in case any variables use Stata's time-series operators.

	st_view(Y, ., st_tsrevar(tokens(yname)), touse)
	st_view(X1, ., st_tsrevar(tokens(endognames)), touse)
	st_view(X2, ., st_tsrevar(tokens(inexognames)), touse)
	st_view(Z1, ., st_tsrevar(tokens(exexognames)), touse)

// Our convention is that regressors are [endog   included exog]
// and instruments are                   [excluded exog  included exog]
// Constant is added by default and is the last column.
	cons = J(rows(X2), 1, 1)
	X2 = X2, cons
	X = X1, X2
	Z = Z1, X2

	K = cols(X)
	L = cols(Z)
	N = rows(Y)

	QZZ = 1/N * quadcross(Z, Z)
	QZX = 1/N * quadcross(Z, X)
		
// First step of 2-step feasible efficient GMM: IV (2SLS).  Weighting matrix
// is inv of Z'Z (or QZZ).
	W = invsym(QZZ)
	beta_iv = (invsym(X'Z * W * Z'X) * X'Z * W * Z'Y)
// By convention, Stata parameter vectors are row vectors
	beta_iv = beta_iv'
// Use first-step residuals to calculate optimal weighting matrix for 2-step FEGMM
	omega = m_myomega(beta_iv, Y, X, Z, robust)
// Second step of 2-step feasible efficient GMM: IV (2SLS).  Weighting matrix
// is inv of Z'Z (or QZZ).
	W = invsym(omega)
	beta_gmm = (invsym(X'Z * W * Z'X) * X'Z * W * Z'Y)
// By convention, Stata parameter vectors are row vectors
	beta_gmm = beta_gmm'

// Sargan-Hansen J statistic: first we calculate the second-step residuals
	e = Y - X * beta_gmm'
// Calculate gbar = 1/N * Z'*e
	gbar = 1/N * quadcross(Z, e)
	j = N * gbar' * W * gbar

// Sandwich var-cov matrix (no finite-sample correction)
// Reduces to classical var-cov matrix if Omega is not robust form.
// But the GMM estimator is "root-N consistent", and technically we do
// inference on sqrt(N)*beta.  By convention we work with beta, so we adjust
// the var-cov matrix instead:
	V = 1/N * invsym(QZX' * W * QZX)

// Easiest way of returning results to Stata: as r-class macros.
	st_matrix("r(beta)", beta_gmm)
	st_matrix("r(V)", V)
	st_matrix("r(omega)", omega)
	st_numscalar("r(j)", j)
	st_numscalar("r(N)", N)
	st_numscalar("r(L)", L)
	st_numscalar("r(K)", K)
}
end

mata: mata mosave m_mygmm2s(), dir(PERSONAL) replace
