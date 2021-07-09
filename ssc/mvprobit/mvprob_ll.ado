*! version 1.0.0  15jan2003 Cappellari & Jenkins 
*! Multivariate probit by method of SML. 

program define mvprob_ll
	version 7.0
	args lnf $S_MLE_I $S_MLE_atrho
	tempvar $S_MLE_tvar sp0
	tokenize $ML_y 

	quietly {
		forval i = 1/$S_MLE_M {  
			gen double `d`i'' = 0
			gen double `sp`i'' = 0
			gen double `arg`i'' = 0
			gen double `k`i'' = 2*``i''-1
		}

		gen double `sp0' = 1
		replace `lnf' = 0
	}

	tempname A 
	mat `A' = I($S_MLE_M)                             

	forval i = 1/$S_MLE_M {  
		local jj = `i'+1
		forval j = `jj'/$S_MLE_M {

				/* atrho`j'`i' is a variable with constant
				   values; we need to get this constant
				   and save it as a scalar. Use -summ-
			           since vble may have some missing values
				   if -if- has been used.
				*/
			summ `atrho`j'`i'', meanonly
			tempname newatrho`j'`i'
			scalar `newatrho`j'`i'' = r(mean)

				/* this part is to prevent the estimate
				   from going too far in the optimization 
				   process.  When atrho -> +inf, rho is 1;
				   when atrho -> -inf, rho is -1.
				*/
			if `newatrho`j'`i'' > 14  {
				scalar `newatrho`j'`i'' = 14
			}
			if `newatrho`j'`i'' < -14 {
				scalar `newatrho`j'`i'' = -14
			}

			tempname rho`j'`i'
			scalar `rho`j'`i'' = (exp(2*`newatrho`j'`i'')-1)  /*
				*/         / (exp(2*`newatrho`j'`i'')+1)

			mat `A'[`j',`i'] = (`rho`j'`i'')
			mat `A'[`i',`j'] = (`rho`j'`i'')
		}
	}
			/* -capture- used so that if A<0, then the program
			   simply uses the value of C from the last iteration.
			   This can help difficult maximizations to `recover'.
			*/
	capture mat $S_MLE_C = cholesky(`A')
	if _rc != 0 {
		di "Warning: cannot do Cholesky factorization of rho matrix"
	}

	forval i = 2/$S_MLE_M {
		forval j = 1/`i' {
			tempname c`i'`j'
			scalar `c`i'`j'' = $S_MLE_C[`i',`j']
		}
	}

	tempname c11
	scalar `c11' = 1

	quietly {
		forval d = 1/$S_MLE_D {
			forval i = 1/$S_MLE_M {
				replace `arg`i'' = `k`i''*`S_MLE_I`i''
				if `i' > 1 {
					local jjj = `i'-1
					forval j = `jjj'(-1)1 {
						replace `arg`i'' = `arg`i''-`k`i''*`k`j''*`d`j''*`c`i'`j''
					}
				}
				replace `d`i'' = invnorm(${S_MLE_z`i'`d'}*normprob((`arg`i'')/`c`i'`i''))
				local j = `i'-1
				replace `sp`i'' = normprob((`arg`i'')/`c`i'`i'')*`sp`j''
			}
			replace `lnf' = `lnf' + `sp$S_MLE_M'/$S_MLE_D  
		}
		replace `lnf' =ln(`lnf')                 
	}

end


