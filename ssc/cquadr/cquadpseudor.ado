cap program drop cquadpseudor
*program drop cquadpseudor
program cquadpseudor, rclass
	version 12.0

	syntax varlist [if] [in]
	
	// Make sure the user is having rcall installed and running
	// =========================================================================
        capture which rcall_check
         if _rc != 0{
         display "Please Install Haghish' rcall package"
         error 198
        }	
	// Syntax processing
	// =========================================================================
	tokenize `varlist'
    local first `1'
    macro shift
    local rest `*'
    local rest : subinstr local rest " " "+", all	
	
	marksample touse
	preserve
	quietly keep if `touse'
	quietly keep `varlist' 
	
	// Run R function
	// =========================================================================
	rcall vanilla: 										///
	library(cquad);                                     ///
	///attach(read.csv("`RData'")); 					/// load temporary data
	A = as.matrix(st.data()); print(head(A)); 						/// load temporary data
	out = cquad_pseudo(A[,1],A[,ncol(A)],A[,-c(1,ncol(A))],Ttol=5);      ///
	coefficients = as.matrix(out\$coefficients); summary(out); 	/// return coef
	vcov_ps = as.matrix(out\$vcov);			 	/// return variance-covariance matrix
	He_ps = as.matrix(out\$J);			 				/// return Hessian of the lk function
	ser_ps = as.matrix(out\$se);			 				/// return standard errors
	serr_ps = as.matrix(out\$ser);					 /// return robust s.e.
	rm(out);											/// erase stored results
	rm(A); 
	
	// restore the data
	restore
	
	// Return scalars and matrices to Stata.
	// =========================================================================
	return add
end

