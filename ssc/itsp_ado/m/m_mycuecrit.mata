mata: mata clear
version 10.1
mata: mata set matastrict on
mata:

// GMM-CUE evaluator function.
// Handles only d0-type optimization; todo, g and H are just ignored.
// beta is the parameter set over which we optimize, and 
// j is the objective function to minimize.

// m_mycuecrit 1.0.0 MES/CFB 11aug2008
void m_mycuecrit(todo, beta, j, g, H)
{
	external Y, X, Z, e, omega, robustflag
	real matrix W
	real vector gbar
	real scalar N

	omega = m_myomega(beta, Y, X, Z, robustflag)
	W = invsym(omega)
	N = rows(Z)
	e = Y - X * beta'

// Calculate gbar=Z'*e/N
	gbar = 1/N * quadcross(Z,e)
	j = N * gbar' * W * gbar
}
end

mata: mata mosave m_mycuecrit(), dir(PERSONAL) replace

