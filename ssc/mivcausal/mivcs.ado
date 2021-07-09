*! version 1.0.0 13Jul2020
//-----------------------------------------------------------------------------
//
//	mivcausal - Testing the hypothesis about the signs of the 2SLS weights
//	Test by Cox and Shi (2019)
//
//-----------------------------------------------------------------------------

capt program drop mivcs

program mivcs, rclass
	
	version 10.0
	syntax [anything] [if] [in]
	
	// Step 1 - Solving the quadratic program
	* Obtain the matrix inverse
	mat sigmainv = inv(Zcov)
	
	* Solve the quadratic program by calling the Mata function
	mat thetahat = thetaols[1..1,.]'
	mata: x = cskkt("sigmainv", "thetahat")
	
	* Retrieve the results
	scalar cstest_temp = r(obj)
	scalar csdf = r(thetazero)
	if string(csdf) == "Error" {
		exit 498
	}
	
	* Compute the test statistic from the minimized value
	scalar cstest = NN * cstest_temp

	// Step 2 - Compute the p-value
	if chi2(csdf, cstest) == . {
		scalar pvtemp = 0
	}
	else {
		scalar pvtemp = chi2(csdf, cstest)
	}
	
	// Step 3 - Return the p-value
	return scalar pval_cs = 1 - pvtemp

end

//-----------------------------------
// Mata function
//-----------------------------------

version 10.0
mata: mata clear

// Mata function 1: To solve the linear program that resulted from the KKT
// conditions of the quadratic program
mata:
void cskkt(string scalar sigmainvmat, string scalar thetamat) {

	// Step 1 - Make matrix
	sigmainv = st_matrix(sigmainvmat)
	theta = st_matrix(thetamat)
	
	// Step 2 - Extract the matrix information
	s11 = sigmainv[1,1]
	s12 = sigmainv[1,2]
	s22 = sigmainv[2,2]
	theta1 = theta[1,1]
	theta2 = theta[2,1]
	
	// Step 3 - Solve the quadratic program
	// Case 1: s1 > 0 and s2 > 0
	if (theta1 >= 0 & theta2 >= 0) {
		s1 = theta1
		s2 = theta2
		nk = 0
	}
	else {
		// Case 2: s1 > 0 and s2 = 0
		lambda2 = -2 * (s22 - (s12^2/s11)) * theta2
		s1 = theta1 + (s12/s11) * theta2
		if (lambda2 >= 0 & s1 > 0) {
			s2 = 0
			nk = 1
		}
		else {
			// Case 3: s1 = 0 and s2 > 0
			lambda1 = -2 * (s11 - (s12^2/s22)) * theta1
			s2 = theta2 + (s12/s22) * theta1
			if (lambda1 >= 0 & s2 > 0) {
				s1 = 0
				nk = 1
			}
			else {
				// Case 4: s1 = 0 and s2 = 0
				lambda1 = -(2 * s11 * theta1 + 2 * s12 * theta2)
				lambda2 = -(2 * s22 * theta2 + 2 * s12 * theta1)
				if (lambda1 >= 0 & lambda2 >= 0) {
					s1 = 0
					s2 = 0
					nk = 2
				}
				else {
					nk = "Error"
				}
			}
		}
	}
	
	// Step 4 - Solve the optimal value
	// Assign t matrix that is resulted from the optimization problem
	t1 = - s1
	t2 = - s2
	tstar = (t1 \ t2)
	
	// Step 5 - Compute the objective value
	pt = theta + tstar
	objval = pt' * sigmainv * pt
	
	// Step 6 - Return results
	st_numscalar("r(obj)", objval)
	st_numscalar("r(thetazero)", nk)
}	
end
