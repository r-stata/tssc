*! 1.0.0 NJC 27 Sept 2007 
program bkrosenblatt, rclass  
	version 9.2 
	syntax varlist(min=2 max=2 numeric) [if] [in] 
	marksample touse 
	qui count if `touse' 
	if r(N) == 0 error 2000 

	tokenize `varlist' 
	mata : bkr("`1'", "`2'", "`touse'") 

	di _n as txt "n       = " as res r(n)            ///
	   _n as txt "n B_n   = " as res %5.4f r(n_B_n)  ///
	   _n as txt "z-score = " as res %5.4f r(z)      ///
           _n as txt "P-value = " as res %5.4f r(P_n_B_n) 

	if "`crit'" != "" { 
		tokenize `crit' 
		di as txt "N.B. critical values at P = 0.05: " as res "`1'" ///
                _n as txt "                        P = 0.01: " as res "`2'"
	}  
		
	return scalar P_n_B_n = r(P_n_B_n) 
	return scalar z       = r(z) 
	return scalar n_B_n   = r(n_B_n) 
	return scalar n       = r(n) 
end 

mata : 

void bkr(string scalar xname, string scalar yname, 
        |string scalar tousename) 
{ 
	real matrix x 
	scalar n, i, n_B_n, b
	real colvector N1, N2, N3, N4

	if (args() == 3) x = st_data(., (xname, yname), tousename)
	else x = st_data(., (xname, yname)) 
	x = select(x, rowmissing(x) :== 0) 
	n = rows(x) 
	N1 = N2 = N3 = N4 = J(n, 1, .)

	for (i = 1 ; i <= n; i++) {
		N1[i] = sum(x[,1] :<= x[i,1] :& x[,2] :<= x[i,2])
		N2[i] = sum(x[,1] :>  x[i,1] :& x[,2] :<= x[i,2])
		N3[i] = sum(x[,1] :<= x[i,1] :& x[,2] :>  x[i,2])
		N4[i] = sum(x[,1] :>  x[i,1] :& x[,2] :>  x[i,2])
	}

	n_B_n = sum((N1 :* N4 :- N2 :* N3):^2) / n^4 
	st_numscalar("r(n)", n)
	st_numscalar("r(n_B_n)", n_B_n)

	// note that as the transformation power h_n is negative, 
	// the transformation reverses high and low values; hence 
	// we negate the z-score from bkr_z() 
	z = -bkr_z(n_B_n, n) 
	st_numscalar("r(z)", z)
	st_numscalar("r(P_n_B_n)", normal(-z))

	if (n < 15) { 
		if (n == 5)       st_local("crit", "0.0976 0.1408")
		else if (n == 6)  st_local("crit", "0.0872 0.1435")
		else if (n == 7)  st_local("crit", "0.0875 0.1312")
		else if (n == 8)  st_local("crit", "0.0842 0.1274")
		else if (n == 9)  st_local("crit", "0.0820 0.1250")
		else if (n == 10) st_local("crit", "0.0802 0.1218")
		else if (n == 11) st_local("crit", "0.0783 0.1195")
		else if (n == 12) st_local("crit", "0.0771 0.1172")
		else if (n == 13) st_local("crit", "0.0762 0.1163")
		else if (n == 14) st_local("crit", "0.0750 0.1137")
	}
}

real scalar bkr_z(real scalar n_B_n, real scalar n) 
{ 
	real scalar mu, sigma, h_n, z 

	if (n < 15) return(.) 
	else { 
		mu = n < 25 ? 4.663 - 1 / (0.2137 + 0.00448 * n) : 
			3.823 - 1 / (0.193 + 0.01662 * n^0.8481) 
		sigma = 0.614 - 1 / (1.187 + 0.0328 * n) 
		h_n = -0.36 + 2.866 * n^(-0.775) - 0.683 * exp(-0.244 * n) 
		z = (n_B_n^h_n - mu) / sigma 
		return(z) 
	} 
}
                 
end 
