
mata: mata clear
version 10.1
mata: mata set matastrict on
mata:
//  m_myomega 1.0.0 MES/CFB 11aug2008
real matrix m_myomega(real rowvector beta,
                      real colvector Y, 
                      real matrix X, 
                      real matrix Z, 
                      string scalar robust)
{
        real matrix QZZ, omega
        real vector e, e2
        real scalar N, sigma2
       
// Calculate residuals from the coefficient estimates
		N = rows(Z)
		e = Y - X * beta'
		
		if (robust=="") {
// Compute classical, non-robust covariance matrix
		    QZZ = 1/N * quadcross(Z, Z)
		    sigma2 = 1/N * quadcross(e, e)
		    omega = sigma2 * QZZ
		}
		else {
// Compute heteroskedasticity-consistent covariance matrix
		    e2 = e:^2
		    omega = 1/N * quadcross(Z, e2, Z)
		}
		_makesymmetric(omega)
		return (omega)
}
end

mata: mata mosave m_myomega(), dir(PERSONAL) replace

