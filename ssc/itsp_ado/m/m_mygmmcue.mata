mata: mata clear
version 10.1
mata: mata set matastrict on
mata:
//  m_mygmmcue 1.0.0 MES/CFB 11aug2008
void m_mygmmcue(string scalar yname, 
                string scalar endognames, 
                string scalar inexognames, 
                string scalar exexognames, 
                string scalar touse, 
                string scalar robust)

{
	real matrix X1, X2, Z1, QZZ, QZX, W, V
	real vector cons, beta_iv, beta_cue
	real scalar K, L, N, S, j
	
// In order for the optimization objective function to find various variables
// and data they have to be set as externals.  This means subroutines can
// find them without having to have them passed to the subroutines as arguments.
// robustflag is the robust argument recreated as an external Mata scalar.

	external Y, X, Z, e, omega, robustflag
	robustflag = robust

	st_view(Y, ., st_tsrevar(tokens(yname)), touse)
	st_view(X1, ., st_tsrevar(tokens(endognames)), touse)
	st_view(X2, ., st_tsrevar(tokens(inexognames)), touse)
	st_view(Z1, ., st_tsrevar(tokens(exexognames)), touse)

// Our convention is that regressors are [endog          included exog]
// and instruments are                   [excluded exog  included exog]
// The constant is added by default and is the last column.
	cons = J(rows(X2), 1, 1)
	X2 = X2, cons
	X = X1, X2
	Z = Z1, X2

	K = cols(X)
	L = cols(Z)
	N = rows(Y)

	QZZ = 1/N * quadcross(Z, Z)
	QZX = 1/N * quadcross(Z, X)
		
// First step of CUE GMM: IV (2SLS).  Use beta_iv as the initial values for
// the numerical optimization.
	W = invsym(QZZ)
	beta_iv = invsym(X'Z * W *Z'X) * X'Z * W * Z'Y
// Stata convention is that parameter vectors are row vectors, and optimizers
// require this, so must conform to this in what follows.
	beta_iv = beta_iv'

// What follows is how to set out an optimization in Stata.  First, initialize
// the optimization structure in the variable S.  Then tell Mata where the
// objective function is, that it's a minimization, that it's a "d0" type of
// objective function (no analytical derivatives or Hessians), and that the
// initial values for the parameter vector are in beta_iv.  Finally, optimize.
	S = optimize_init()
	optimize_init_evaluator(S, &m_mycuecrit())
	optimize_init_which(S, "min")
	optimize_init_evaluatortype(S, "d0")
	optimize_init_params(S, beta_iv)
	beta_cue = optimize(S)

// The last omega is the CUE omega, and the last evaluation of the GMM
// objective function is J.
	W = invsym(omega)
	j = optimize_result_value(S)

	V = 1/N * invsym(QZX' * W * QZX)

	st_matrix("r(beta)", beta_cue)
	st_matrix("r(V)", V)
	st_matrix("r(omega)", omega)
	st_numscalar("r(j)", j)
	st_numscalar("r(N)", N)
	st_numscalar("r(L)", L)
	st_numscalar("r(K)", K)
}
end

mata: mata mosave m_mygmmcue(), dir(PERSONAL) replace


