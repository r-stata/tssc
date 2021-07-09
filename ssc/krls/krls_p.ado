*! version 1.01  Jeremy Ferwerda

program krls_p
version 11
	syntax name(name=newvarname) [if] [, Se, Fitted, Residuals]
	
	if ("`e(cmd)'" != "krls") error 301

	tempvar kpredictif trainingset testset training_exclude
		
	mark `kpredictif' `if'	
	confirm new var `newvarname'

	// Handle possible resorting between runs
	tempvar originalsort
	gen `originalsort' = _n
	sort `e(depvar)' 
		
	// Display Settings
	if ("`se'" == "se") local seflag = "1"
	else local seflag = "0" // default fitted
	
	// Data management
	qui: gen `testset' = 0 
	qui: gen `trainingset' = 1 
	qui: gen `training_exclude' = 0
		
	qui: replace `trainingset' = 0 if e(sample) != 1 
	qui: replace `testset' = 1     if e(sample) != 1 & `kpredictif' == 1 
	qui: replace `training_exclude' = 1 if `trainingset' == 1 & `kpredictif' != 1 

	// Adjust for factors
	local fvops = "`s(fvops)'" == "true" 
    	if `fvops' { 
    	  fvrevar `e(indvar)'
          local varlist `r(varlist)'
          qui: _rmcoll `varlist', forcedrop
          local regs `r(varlist)'
    	}
	
	mata: m_krls_predict("`trainingset'","`testset'","`newvarname'","`seflag'","`training_exclude'","`regs'")
		
	if ("`residuals'" == "residuals"){
			tempvar krlsstep
            gen `krlsstep' =  `e(depvar)' - `newvarname'
            drop `newvarname'
            rename `krlsstep' `newvarname'
	}
	sort `originalsort'	
end


version 11
mata:
mata set matastrict on
mata set matafavor speed

// KRLS Predict Function 
void m_krls_predict(string scalar trainingset, ///
                                                string scalar testset, ///
                                                string scalar newvarname, ///
                                                string scalar saveseflag, ///
                                                string scalar trainingexclude, ///
                                                string scalar fvadjust){
                                                             
        	real matrix X, X2, T, Z, pYfit_new, pSEfit_new, KM, KMnew, nonmissingrows, Sdx
       		real scalar i,subset

 			 // If training indicator passed, appends test data to training data. Otherwise, uses entire dataset
			if (fvadjust == ""){
				fvadjust = st_global("e(indvar)")
			}
			X  = st_data(.,  tokens(fvadjust), trainingset)
          	X2 = st_data(.,  tokens(fvadjust), testset) 						
            Sdx =  sqrt(diagonal(quadmeanvariance(X)[|2,1 \ .,.|])')

            // Throw non-fatal warning. KRLS requires original observations to calculate the appropriate distance matrix. 
            if (hasmissing(X) == 1 | (quadmeanvariance(X)[1,.] != st_matrix("e(meanx)"))){
            	"Warning: Modified observations detected in the original sample. Please maintain all original data rows for accurate predictions."
            }
		    X = (X2 \ X)
		
            // Rescale 
            X[ ., . ] = (X :- st_matrix("e(meanx)")) :/ Sdx  
            KM = exp((-1*m_euclidian_distance(X,rows(X),cols(X)):^2)/st_numscalar("e(sigma)"))

			(void) st_addvar("double",newvarname)
			st_view(T, ., newvarname, trainingset)
        	st_view(Z, ., newvarname, testset)
          
			// Test set predictions (new observations)
        	if (rows(X2) > 0){
 				  subset = rows(X2) 
          		  KMnew = KM[1::subset,(subset+1)::cols(KM)]    
				  KM =  KM[(subset+1)::rows(KM),(subset+1)::cols(KM)] 

        		  if (saveseflag == "1"){
        		  		pSEfit_new = sqrt(diagonal(cross((KMnew * (st_matrix("e(Vcov_c)") :* (1/(st_numscalar("e(sdy)")^2))))',KMnew') :* st_numscalar("e(sdy)")^2)) 
        		   }  else {
        		  		pYfit_new = cross(KMnew',st_numscalar("e(sdy)"),st_matrix("e(Coeffs)")) :+ st_numscalar("e(meany)")
        		   }
      		    } 

            if (rows(X2) > 0){
              	// Remove incomplete rows
                nonmissingrows = rownonmissing(X2)

                for (i=1;i<=rows(X2);i++){
                       if (nonmissingrows[i,1] == cols(X2)){
                           if (saveseflag == "1"){
                         		Z[i,1] = pSEfit_new[i]
                   		   } else {
                         		Z[i,1] = pYfit_new[i]
                   		   }                                            
                       }
                  }
           }
                      
		   // Training set predictions (old observations)
           if (saveseflag == "1"){
                T[.,.]  = sqrt(diagonal(cross((KM * (st_matrix("e(Vcov_c)") :* (1/(st_numscalar("e(sdy)")^2))))',KM') :* st_numscalar("e(sdy)")^2))    
		   } else {
       		   	T[.,.] = cross(KM',st_numscalar("e(sdy)"),st_matrix("e(Coeffs)")) :+ st_numscalar("e(meany)")
		   }
           
           // Avoid returning training set entries excluded by 'if' (can't be exluded from KM; more efficient than looping)
           st_view(T, ., newvarname, trainingexclude)
           T[.,.] = J(rows(T),1,.) 
}                               
                               
                           
// Euclidean Distance
matrix m_euclidian_distance(real matrix X, real scalar n, real scalar d){

		real matrix D
		real scalar i,j
		D=J(n, n, .)
		
		for (i=n; i>0; i--){
 		   		for (j=1; j<=i; j++){
       	   				D[i,j] = sqrt(sum((X[i,]-X[j,]):^2))
       	   				D[j,i] = D[i,j]
   		    	}
			}
		return(D)	
}
end
