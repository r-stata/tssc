cap program drop cquadextr
*program drop cquadextr
program cquadextr, rclass
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
		A = as.matrix(st.data()); ///head(A);  						/// load temporary data
		out = cquad_ext(A[,1],A[,ncol(A)],as.matrix(A[,-c(1,ncol(A))]),Ttol=5); ///
		coefficients= as.matrix(out\$coefficients); summary(out);   	/// return coef
		vcov = as.matrix(out\$vcov); /// return variance-covariance matrix
		He = as.matrix(out\$J);			 				/// return Hessian of the lk function
		ser = as.matrix(out\$se);			 				/// return standard errors
		serr = as.matrix(out\$ser);					 /// return robust s.e.
		rm(out);                                                             /// erase stored results
		rm(A); 
		///rm(tmp);
	// restore the data
	restore

	// Return scalars and matrices to Stata.
	// =========================================================================
	return add
end



//--------------------------------------------------------------------
