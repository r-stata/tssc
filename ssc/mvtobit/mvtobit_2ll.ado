cap program drop mvtobit_2ll
program define mvtobit_2ll

quietly {	
   version 8.2
   args lnf $X_MVT_i $X_MVT_std $X_MVT_atrho
		

	tempname rho es1 es2

	forval i=1/$X_MVT_NOEQ {
		summ `lnsigma`i'', meanonly
		scalar `es`i''=exp(r(mean))
	}

	summ `atrho12', meanonly
	scalar `rho' = tanh(r(mean))

	/* Generate normalized errors */
	forval i = 1/$X_MVT_NOEQ {
		tempvar e`i'
		gen double `e`i'' = (${ML_y`i'} - `xb`i'')/`es`i''
	}

	replace `lnf' = ln( binorm(`e1',`e2',`rho') ) if ${ML_y1}==0 & ${ML_y2}==0
	  
	replace `lnf' = ln( (1/`es1') * (1/`es2') * 1/(2*_pi*sqrt(1-`rho'^2)) * exp( -1/(2*(1-`rho'^2)) ///
							* (`e1'^2 - 2*`rho'*`e1'*`e2' + `e2'^2) ) ) if ${ML_y1}>0 & ${ML_y2}>0
 
	replace `lnf' = ln( (1/`es2') * normden(`e2') * norm((`e1'-`rho'*`e2')/(sqrt(1-`rho'^2))) ) 	///
						if ${ML_y1}==0 & ${ML_y2}>0
					
	replace `lnf' = ln( (1/`es1') * normden(`e1') * norm((`e2'-`rho'*`e1')/(sqrt(1-`rho'^2))) ) 	///
	  						if ${ML_y1}>0 & ${ML_y2}==0


	* End quietly and evaluator			
	 }
end
