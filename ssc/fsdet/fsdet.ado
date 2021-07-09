*!fsdet version 1.0
*!Written 10March2015
*!Written by Mehmet Mehmetoglu
capture program drop fsdet
program fsdet
version 13.1
//set trace on
di ""	
	di in yellow "  Factor Determinacy Coefficient"
	di as smcl as txt  "{c TLC}{hline 36}{c TRC}"
	di in yellow "  {bf:Factor}{dup 10: }{c |}{bf:    Coefficient} "
	di as smcl as txt  "{c BLC}{hline 36}{c BRC}"
		//the below computes fsdet coef the context of CFA
		//sem
		//ereturn list
local cmd e(cmd)
		if `cmd' == "sem" {
			qui estat framework,stand fitted    
						/*after the user has typed sem, we need to obtain the different 
						matrices from return list after estat framework*/
				//qui return list 
			mat phi = r(Phi) //gives the factor co/variance matrix 
				//mat list phi
			mat gamma = r(Gamma) //gives the factor loading matrix
				//mat list gamma
			mat sigma1 = r(Sigma) //gives the reproduced indicator and factor co/variance matrix
				//mat list sigma1
			tempname nobsvars
			scalar `nobsvars'=wordcount("`e(oyvars)'") //finds out the number of indicators
				//di `nobsvars'
			mat sigma2 = sigma1[1..`nobsvars', 1..`nobsvars'] 
						/*sigma1 matrix includes both the indicator and factor covariances, 
						as we only need the indicator covariance matrix to the formula below
						we create a new matrix going from 1 to 6 coloumns of the sigma1 matrix*/
				//mat list sigma2
			mat A = phi*gamma'*inv(sigma2)*gamma*phi //we apply the first section of the formula
				//mat list A
				//ereturn list /*ereturn after sem estimation*/
			local nlvars wordcount("`e(lxvars)'") //finds out how many latent variables used
				//di `nlvars'
			local i=1
			tokenize "`e(lxvars)'" 
						/*using tokenize we divide lxvars line into single words, F1... and later
						in the loop below with local n and macro shift we shift from F1 to next etc...*/
			foreach n of local nlvars {
				tempname sc
				scalar `sc' = sqrt(A[`i', `i']) //takes the square root of matrix A, this is the second section of the formula
						//after tokenize, the below is run, tokenize is put just before the loop
				local n `1'  
				macro shift   
				local ++i
						//present the results
					if `sc' >= 0.9 {
						di in green "  " %-12s abbrev("`n'",12) "{dup 4: }{c |}"%9.3f `sc' "" 
						            }
					else {
						di in red "  " %-12s abbrev("`n'",12) "{dup 4: }{c |}"%9.3f `sc' "" 
			             }
									  }
					   }
		//the below computes fsdet coef the context of EFA
		//factor	
		//ereturn list
local cmd e(cmd)
		if `cmd' == "factor" {
						//return list /*after factor, this gives the macro r(rtext) indicating the type of rotation used*/
			local rotation r(rtext)
				if `rotation' == " (unrotated)" {	//if unrotated solution is used!
						//qui ereturn list
					mat phi = e(Phi) //gives the factor covariance matrix
						//mat list phi
					mat gamma = e(L) //gives the factor loading matrix
						//mat list gamma
					mat sigma = e(C) //gives the indicator covariance matrix directly in EFA
						//mat list sigma1
					mat A = phi*gamma'*inv(sigma)*gamma*phi //the first section of the formula
						//mat list A
					local nlvars e(f) //finds out how many latent variables are used
						//di `nlvars'
					local i=1
					forvalues n = 1/`e(f)' {
						tempname sc
						scalar `sc' = sqrt(A[`i', `i']) //takes the square root of matrix A, this is the second section of the formula
						local ++i
							if `sc' >= 0.9 {
								di in green "  " %-12s abbrev("F`n'",12) "{dup 4: }{c |}"%9.3f `sc' "" 
										   }
							else {
								di in red "  " %-12s abbrev("F`n'",12) "{dup 4: }{c |}"%9.3f `sc' "" 
								 }
							                 }
							                     }
				if `rotation' != " (unrotated)" {	//if rotated solution is used!
						//qui ereturn list
					mat phi = e(r_Phi) //gives the factor covariance matrix
						//mat list phi
					mat gamma = e(r_L) //gives the factor loading matrix
						//mat list gamma
					mat sigma = e(C) //gives the indicator covariance matrix directly in EFA
						//mat list sigma1
					mat A = phi*gamma'*inv(sigma)*gamma*phi //the first section of the formula
						//mat list A
					local nlvars e(r_f) //finds out how many latent variables are used
						//di `nlvars'
					local i=1
					forvalues n = 1/`e(r_f)' {
						tempname sc
						scalar `sc' = sqrt(A[`i', `i']) //takes the square root of matrix A, this is the second section of the formula
												local ++i
							if `sc' >= 0.9 {
								di in green "  " %-12s abbrev("F`n'",12) "{dup 4: }{c |}"%9.3f `sc' "" 
										   }
							else {
								di in red "  " %-12s abbrev("F`n'",12) "{dup 4: }{c |}"%9.3f `sc' "" 
								 }
							                 }
							                     }
							}
	di as smcl as txt  "{c BLC}{hline 36}{c BRC}"
	di in yellow "  Note: We seek coefficients >= 0.9"
end				
	






