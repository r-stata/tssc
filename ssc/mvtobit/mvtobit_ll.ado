cap program drop mvtobit_ll
program define mvtobit_ll

quietly {	
   version 8.2
   args lnf $X_MVT_i $X_MVT_std $X_MVT_atrho
		
	  	/* Generate error terms */
	  forvalues i = 1/$X_MVT_NOEQ {
		 tempvar e`i'
		 gen double `e`i'' = (${ML_y`i'} - `xb`i'')
	  }


	/*	Make covariance matrix for unsorted data - use Cholesky decomposition */
	 tempname Sig
	 matrix `Sig' = J($X_MVT_NOEQ,$X_MVT_NOEQ,0)

	forvalues i = 1/$X_MVT_NOEQ {
		summ `lnsigma`i'', meanonly
		matrix `Sig'[`i',`i'] = exp(r(mean))^2
	}
	forvalues i = 1/$X_MVT_NOEQ {
		 forvalues j = `=`i'+1'/$X_MVT_NOEQ {
			summ `atrho`i'`j'', meanonly
			if r(mean) > 14 {
				matrix `Sig'[`i',`j'] = sqrt(`Sig'[`i',`i']) * sqrt(`Sig'[`j',`j'])
			}
			else if r(mean) < -14 {
				matrix `Sig'[`i',`j'] = -sqrt(`Sig'[`i',`i']) * sqrt(`Sig'[`j',`j'])
			}
			else {
				matrix `Sig'[`i',`j'] = tanh(r(mean)) * sqrt(`Sig'[`i',`i']) * sqrt(`Sig'[`j',`j'])
			}
			matrix `Sig'[`j',`i'] = `Sig'[`i',`j']			
 		 }
	 }		 

	capture mat $X_MVT_C = cholesky(`Sig')
	if _rc != 0 {
		noi di "Warning: cannot do Cholesky factorization of covariance matrix"
		mat `Sig' = $X_MVT_C*$X_MVT_C'
	}

	 
	tempname iSig_a is tempm1 tempvar ip gtmp
	gen double `ip' = 0

	* Observations with ZERO equations censored
	foreach indeks of global indeks0 {
		
		local res = ""
		forvalues j = 1/$X_MVT_NOEQ {
			local res `res' `e`j''
		}
		 matrix `iSig_a' = syminv(`Sig')
		 replace `ip' = 0
		 forvalues i = 1/$X_MVT_NOEQ {
		 	tempvar g`i'
		 	matrix `is' = `iSig_a'[`i',1...]
			matrix colnames `is' = `res'
			matrix score `g`i'' = `is' if X_MVT_index == `indeks'
			replace `ip' = `ip' + `e`i'' * `g`i'' if X_MVT_index == `indeks'
		 }

	  tempvar logfe_1
	  gen double `logfe_1' = -$X_MVT_NOEQ/2 * log(2*_pi) - 1/2*log(det(`Sig')) - .5*`ip' ///
	  						if X_MVT_index == `indeks'

	  replace `lnf' = `logfe_1' if X_MVT_index == `indeks'
	  * End zero censoring				  
	 }
			  
			
	/* Observations with ONE equation censored */

	tempname Sig_11 Sig_tmp Sig_1 Sig_21 Sig_22 Sig_22_1 My_2_1

	foreach indeks of global indeks1 {

		* first the consumed goods
		* find covariance matrix from Sig

		* first reorganize columns
		* start with artifial column
		matrix `Sig_tmp' = `Sig'[1...,1]
		forvalues i = 1/`=$X_MVT_NOEQ-1' {
			matrix `Sig_tmp' = `Sig_tmp', `Sig'[1...,`=word("${ordstr`indeks'}",`i')']
		}
		* remove artificial column
		matrix `Sig_tmp' = `Sig_tmp'[1...,2...]
		* add non-use goods
		matrix `Sig_tmp' = `Sig_tmp', `Sig'[1...,`=word("${unordstr`indeks'}",1)']
	
		* then reorganize rows
		* artifial row to start with
		matrix `Sig_1' = `Sig_tmp'[1,1...]
		forvalues i = 1/`=$X_MVT_NOEQ-1' {
			matrix `Sig_1' = `Sig_1' \ `Sig_tmp'[`=word("${ordstr`indeks'}",`i')',1...]
		}
		* remove artificial row
		matrix `Sig_1' = `Sig_1'[2...,1...]
		* add non-use goods
		matrix `Sig_1' = `Sig_1' \ `Sig_tmp'[`=word("${unordstr`indeks'}",1)',1...]

		matrix `Sig_11' = `Sig_1'[1..`=$X_MVT_NOEQ-1', 1..`=$X_MVT_NOEQ-1']
		matrix `Sig_21' = `Sig_1'[$X_MVT_NOEQ, 1..`=$X_MVT_NOEQ-1']
		matrix `Sig_22' = `Sig_1'[$X_MVT_NOEQ, $X_MVT_NOEQ]
		matrix `Sig_22_1' = `Sig_22' - `Sig_21' * syminv(`Sig_11') * `Sig_21''
	
	
		local res = ""
		local or = ""

		forvalues i = 1/`=$X_MVT_NOEQ-1' {
			local res `res' `e`=word("${ordstr`indeks'}",`i')''
		}

		local or ${ordstr`indeks'}

			
		matrix `iSig_a' = syminv(`Sig_11')
		forvalues i = 1/`=$X_MVT_NOEQ-1' {
		 	tempvar g`i'
		 	matrix `is' = `iSig_a'[`i',1...]
			matrix colnames `is' = `res'
			matrix score `g`i'' = `is' if X_MVT_index == `indeks'
			replace `ip' = `ip' + `e`=word("`or'",`i')''*`g`i'' if X_MVT_index == `indeks'
		}

		tempvar logfe_1 loghe_1
			  						  
		gen double `logfe_1' = -($X_MVT_NOEQ-1)/2 * log(2*_pi) - 1/2*log(det(`Sig_11')) - .5*`ip' ///
								if X_MVT_index == `indeks'

		* Then censored equations
		tempvar my_1
		gen double `my_1' = 0 if X_MVT_index == `indeks'
		forvalues i = 1/`=$X_MVT_NOEQ-1' {
			replace `my_1' = `my_1' + `g`i'' * `Sig_21'[1,`i'] if X_MVT_index == `indeks'
		}

		gen double `loghe_1' = log( norm((-`xb`=word("${unordstr`indeks'}",1)'' - 		///
						`my_1')/sqrt(`Sig_22_1'[1,1])) ) if X_MVT_index == `indeks'

		replace `lnf' = `logfe_1' + `loghe_1' if X_MVT_index == `indeks'

	}


	/* Observations with TWO equations censored */
	
	foreach indeks of global indeks2 {

		* first non-censored euations
		* find covariance matrix from Sig
		* reorganize columns

		* start with artifial column
		matrix `Sig_tmp' = `Sig'[1...,1]
		forvalues i = 1/`=$X_MVT_NOEQ-2' {
			matrix `Sig_tmp' = `Sig_tmp',`Sig'[1...,`=word("${ordstr`indeks'}",`i')']
		}
		* remove artificial column
		matrix `Sig_tmp' = `Sig_tmp'[1...,2...]
		* add non-use goods
		forvalues i = 1/2 {
			matrix `Sig_tmp' = `Sig_tmp',`Sig'[1...,`=word("${unordstr`indeks'}",`i')']
		}
		
		* then reorganize rows
		* start with artifial row
		matrix `Sig_1' = `Sig_tmp'[1,1...]
		forvalues i = 1/`=$X_MVT_NOEQ-2' {
			matrix `Sig_1' = `Sig_1' \ `Sig_tmp'[`=word("${ordstr`indeks'}",`i')',1...]
		}
		* remove artificial row
		matrix `Sig_1' = `Sig_1'[2...,1...]
		* add non-use goods
		forvalues i = 1/2 {
			matrix `Sig_1'=`Sig_1' \ `Sig_tmp'[`=word("${unordstr`indeks'}",`i')',1...]
		}

		matrix `Sig_11'   = `Sig_1'[1..`=$X_MVT_NOEQ-2',1..`=$X_MVT_NOEQ-2']
		matrix `Sig_21'   = `Sig_1'[`=$X_MVT_NOEQ-1'...,1..`=$X_MVT_NOEQ-2']
		matrix `Sig_22'   = `Sig_1'[`=$X_MVT_NOEQ-1'...,`=$X_MVT_NOEQ-1'...]
		matrix `Sig_22_1' = `Sig_22'-`Sig_21'*syminv(`Sig_11')*`Sig_21''
		
		
		local res = ""
		local or = ""

		forvalues i=1/`=$X_MVT_NOEQ-2' {
			local res `res' `e`=word("${ordstr`indeks'}",`i')''
		}

		local or ${ordstr`indeks'}

		matrix `iSig_a' = syminv(`Sig_11')
		replace `ip' = 0
		forvalues i = 1/`=$X_MVT_NOEQ-2' {
		 	tempvar g`i'
		 	matrix `is' = `iSig_a'[`i',1...]
			matrix colnames `is' = `res'
			matrix score `g`i'' = `is' if X_MVT_index == `indeks'
			replace `ip' = `ip' + `e`=word("`or'",`i')'' * `g`i'' if X_MVT_index == `indeks'
		}

		tempvar logfe_1 loghe_1
				  						  
		gen double `logfe_1' = -($X_MVT_NOEQ-2)/2*log(2*_pi)-1/2*log(det(`Sig_11'))-.5*`ip'  ///
								if X_MVT_index == `indeks'

		* Then censored equations
		tempname Sig_21_11
			  
		matrix `Sig_21_11' = `Sig_21' * syminv(`Sig_11')
		tempvar my1 my2
		gen double `my1' = 0 if X_MVT_index == `indeks'
		gen double `my2' = 0 if X_MVT_index == `indeks'

		forvalues i=1/`=$X_MVT_NOEQ-2' {
				replace `my1' = `my1' + `Sig_21_11'[1,`i'] * `e`=word("${ordstr`indeks'}",`i')'' if X_MVT_index == `indeks'
				replace `my2' = `my2' + `Sig_21_11'[2,`i'] * `e`=word("${ordstr`indeks'}",`i')'' if X_MVT_index == `indeks'
		}

		gen double `loghe_1' = log( binorm( (-`xb`=word("${unordstr`indeks'}",1)''-`my1') / sqrt(`Sig_22_1'[1,1]),	///
						(-`xb`=word("${unordstr`indeks'}",2)''-`my2') / sqrt(`Sig_22_1'[2,2]), `Sig_22_1'[1,2]/		///
						sqrt(`Sig_22_1'[1,1])/sqrt(`Sig_22_1'[2,2]) ) ) if X_MVT_index == `indeks' 
	
		replace `lnf' = `logfe_1' + `loghe_1' if X_MVT_index == `indeks'

	* End Two censored equations
	}

	* gen variables for use with mvnp procedure with three or more censored equations
	forvalues z = 1/$X_MVT_NOEQ {
		tempvar u`z'
		gen double `u`z'' = .
	}

				
	* if # eq > 3	
	if $X_MVT_maxcen > 3 | ($X_MVT_maxcen == 3 & $X_MVT_NOEQ > 3) {

		* Observations with THREE or MORE censored equations
		forvalues y = 3/`=$X_MVT_NOEQ-1' {
			foreach indeks of global indeks`y' {
				
				* Same procedure as with 2 non-censored equations
				matrix `Sig_tmp' = `Sig'[1...,1]
				forvalues i = 1/`=$X_MVT_NOEQ-`y'' {
					matrix `Sig_tmp' = `Sig_tmp',`Sig'[1...,`=word("${ordstr`indeks'}",`i')']
				}
				* remove artificial column
				matrix `Sig_tmp' = `Sig_tmp'[1...,2...]
				* add non-use goods
				forvalues i = 1/`y' {
					matrix `Sig_tmp' = `Sig_tmp',`Sig'[1...,`=word("${unordstr`indeks'}",`i')']
				}
				
				* Rows
				matrix `Sig_1' = `Sig_tmp'[1,1...]
				forvalues i = 1/`=$X_MVT_NOEQ-`y'' {
					matrix `Sig_1' = `Sig_1' \ `Sig_tmp'[`=word("${ordstr`indeks'}",`i')',1...]
				}
				* remove artificial row
				matrix `Sig_1' = `Sig_1'[2...,1...]
				* add non-use goods
				forvalues i = 1/`y' {
					matrix `Sig_1' = `Sig_1' \ `Sig_tmp'[`=word("${unordstr`indeks'}",`i')',1...]
				}
	
				matrix `Sig_11'   = `Sig_1'[1..`=$X_MVT_NOEQ-`y'',1..`=$X_MVT_NOEQ-`y'']
				matrix `Sig_21'   = `Sig_1'[`=$X_MVT_NOEQ-`y'+1'...,1..`=$X_MVT_NOEQ-`y'']
				matrix `Sig_22'   = `Sig_1'[`=$X_MVT_NOEQ-`y'+1'...,`=$X_MVT_NOEQ-`y'+1'...]
				matrix `Sig_22_1' = `Sig_22'-`Sig_21'*syminv(`Sig_11')*`Sig_21''
					
				local res = ""
				local or = ""
	
				forvalues i = 1/`=$X_MVT_NOEQ-`y'' {
					local res `res' `e`=word("${ordstr`indeks'}",`i')''
				}
	
				local or ${ordstr`indeks'}

				matrix `iSig_a' = syminv(`Sig_11')
				replace `ip' = 0
				forvalues i = 1/`=$X_MVT_NOEQ-`y'' {
				 	tempvar g`i'
				 	matrix `is' = `iSig_a'[`i',1...]
					matrix colnames `is' = `res'
					matrix score `g`i'' = `is' if X_MVT_index == `indeks'
					replace `ip' = `ip' + `e`=word("`or'",`i')''*`g`i'' if X_MVT_index == `indeks'
				}
		
				tempvar logfe_1 loghe_1
				gen double `logfe_1' = -($X_MVT_NOEQ-`y')/2*log(2*_pi)-1/2*log(det(`Sig_11'))-.5*`ip' ///
				 					if X_MVT_index == `indeks'
						  
				* Then censored equations
				tempname Sig_21_11
				matrix `Sig_21_11' = `Sig_21'*syminv(`Sig_11')
				forvalues z = 1/`y' {
					 tempvar my`z'
					  gen double `my`z'' = 0 if X_MVT_index == `indeks'
				}
				  
				forvalues i = 1/`=$X_MVT_NOEQ-`y'' {
					forvalues z = 1/`y' {
				  		replace `my`z'' = `my`z'' + `Sig_21_11'[`z',`i'] * `e`=word("${ordstr`indeks'}",`i')'' ///
						if X_MVT_index == `indeks'
					}
				}

				* Make cholesky factorization of variance-covariance matrix
				tempname chol_3
				tempvar  prod

				forvalues z = 1/`y' {
					replace `u`z'' = (-`xb`=word("${unordstr`indeks'}",`z')''-`my`z'')   ///
					  				if X_MVT_index == `indeks'
				}
				  

				* make string for argument in mvpn procedure
				local mvpn_str=""
				forvalues z = 1/`y' {
					local mvpn_str = "`mvpn_str'" + "`" + "u`z'" + "' "
				}
				* trim before passing to mvnp
				local mvpn_str = trim("`mvpn_str'")

				matrix `chol_3' = cholesky(`Sig_22_1')
			  	egen `prod' = mvnp(`mvpn_str') if  X_MVT_index == `indeks', prefix("$X_MVT_prefix") draws($X_MVT_D) ///
							 chol(`chol_3') $X_MVT_adoonly
	
			  	gen double `loghe_1' = log(`prod')  if X_MVT_index == `indeks'
	
				replace `lnf' = `logfe_1' + `loghe_1' if X_MVT_index == `indeks'
			}
		}
	* End if # eq > 3
	}
				
	/* Observations with ALL equations censored */
	if $X_MVT_maxcen == $X_MVT_NOEQ {
		foreach indeks of global indeks${X_MVT_NOEQ} {
	 		* Make cholesky factorization of variance-covariance matrix
			tempname chol_3
			tempvar prod
			
			matrix `chol_3' = cholesky(`Sig')
			forvalues y = 1/$X_MVT_NOEQ {
		    	replace `u`y'' = (-`xb`=word("${unordstr`indeks'}",`y')'') if X_MVT_index == `indeks'
			}					  
	
			* make string for argument in mvpn procedure
			local mvpn_str = ""
			forvalues z = 1/$X_MVT_NOEQ {
				local mvpn_str = "`mvpn_str'" + "`" + "u`z'" + "' "
			}
	
			* trim before passing to mvnp
			local mvpn_str = trim("`mvpn_str'")
	
		    egen `prod' = mvnp(`mvpn_str') if  X_MVT_index == `indeks', prefix("$X_MVT_prefix")   ///
							draws($X_MVT_D) chol(`chol_3') $X_MVT_adoonly
	
		    tempvar loghe_1_15
			gen double `loghe_1_15' = log(`prod') if X_MVT_index == `indeks'
	
			replace `lnf' = `loghe_1_15' if X_MVT_index == `indeks'
	 	}
    * end all eq censored
	}


			
	* End quietly and evaluator			
	 }
end
