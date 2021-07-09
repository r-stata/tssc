*! version 1.2.2 15Feb2012 MLB
*  version 1.2.1 11Dec2011 MLB
*  version 1.2.0 13Dec2011 MLB
program define marg_parsamp, eclass sortpreserve
	syntax , bname(name) v(name)             ///
	       [                             ///
		   rmse(numlist min=1 max=1 >=0) ///
		   sd(numlist min=1 max=1 >=0)   ///
		   cf(numlist min=1 max=1 >=0)   ///
		   n(numlist min=1 max=1 >=0)   ///
		   ]
		   
	tempname b
	matrix `b' = `bname'
	local cmd "`e(cmd)'"
	local pred "`e(predict)'"
	local title "`e(title)'"
	if inlist("`e(cmd)'", "zip", "zinb") {
		local infl "`e(inflate)'"
	}
	if "`e(cmd)'" == "nbreg" {
		local dispers  "`e(dispers)'" 
	}
	if "`e(cmd)'" == "regress" {
		tempname se nrmse 
		
		// get the maximum likelihood var-cov matrix
		matrix `v' = `cf'*`v'

		// sample sigma, which is independent from the other parameters
		// for stability the samples are drawn for the distribution of ln(rmse/sd)
		scalar `nrmse' = `rmse'*`cf'  // get the maximum likelihood solution
		scalar `nrmse' = `nrmse'/`sd' // standardize the dependent variable
		scalar `se' = `nrmse'^3/`n'  // standard error of ln(s/sd) via delta method
		scalar `nrmse' = exp(rnormal(ln(`nrmse'), `se'))*`sd'
	}
	
	mata: marg_parsamp("`b'", "`v'")
	ereturn post `b'
	
	if inlist("`cmd'", "zip", "zinb") {
		ereturn local inflate `infl'
	}
	if "`cmd'" == "nbreg" {
		ereturn local dispers `dispers'
	}
	if "`cmd'" == "regress" {
		ereturn scalar rmse = `nrmse'
	}
	ereturn local predict `pred'
	ereturn local title `title'
	ereturn local cmd `cmd'
end

mata 
void marg_parsamp(string scalar bname, string scalar Vname) {
	real matrix V
	real vector b, b2
	
	b = st_matrix(bname)'
	V = st_matrix(Vname)
	V = marg_svddecomp(V)
	b2 = rnormal(rows(b),1,0,1)
	b2 = ( b + V*b2 )'
	st_replacematrix(bname, b2)
}

real matrix marg_svddecomp(real matrix V) {
	real matrix U, Vt, A
	real vector s
	
	U=s=Vt=.
	
	svd(V,U,s,Vt)
	
	// make the matrix of interest
	A = U*diag(sqrt(s))
	return(A)
}
end

