/* Tim Simcoe : this version 9/15/2008 */

/*   This program caculates a "Robust" Covariance Matrix for the 
Poisson QML model with conditional fixed effects. Formulas were
obtained from Wooldridge (1999), Journal of Econometrics  */

program define xtpqml, eclass byable(recall) sort
version 8.0

syntax varlist(numeric) [if] [in], [I(varname num) FE IRr CLuster(varname)]
marksample touse

** Make sure user specifies a Group Variable (i)
if length("`i'") == 0 {	
	local i = "`_dta[iis]'"
	if length("`i'") == 0 {
		di in red "you must specify a group variable for the panel"
		exit 198
	}
}

** Check to see that Groups (i) are nested within Clusters
if length("`cluster'") > 0 { 
	quietly {
		bysort `i' : gen flag = `cluster'!=`cluster'[_n-1] & _n>1
		sum flag
		drop flag
	}
	if r(mean)>0 {
		di in red "group variable (i) must be nested within clusters"
		exit 198
	}
}

xtpoisson `varlist' if `touse', fe i(`i')

display "Calculating Robust Standard Errors..."
quietly {
	/******* Creating Matrices for Outer Product ********/
	matrix A_hat = e(V)			
	matrix b = e(b)
	local nobs = e(N)
	local logl = e(ll)
	local grps = e(N_g)
	local dofm = e(df_m)
	local varlist : colnames b
	
	bysort `cluster' `i' : egen n_i = sum(`e(depvar)') if e(sample)	    
	predict xb_hat_it, xb
	gen mu_hat_it = exp(xb_hat_it) if e(sample)       	     
	by `cluster' `i': egen sum_mu_i = sum(mu_hat_it) if e(sample)
	
	gen p_it =  mu_hat_it / sum_mu_i if e(sample)			      
	gen u_it = `e(depvar)' - p_it*n_i if e(sample)                    
					              		      

	/* Calculate Derivatives of m_hat_it */	
	foreach v of var `varlist' {
		by `cluster' `i': egen wt_sum_`v' = sum(`v'*mu_hat_it) if e(sample)
		gen del_m_`v' = n_i*p_it*(`v' - (wt_sum_`v'/sum_mu_i)) if e(sample)
		drop wt_sum_`v'
	}
	
	gen v_inv_u_hat = u_it/(n_i*p_it) if e(sample)
	
	if length("`cluster'") > 0 {
		matrix opaccum B_hat = del_m_* if e(sample), op(v_inv_u_hat) group(`cluster') nocons
	}
	if length("`cluster'") == 0 {
		matrix opaccum B_hat = del_m_* if e(sample), op(v_inv_u_hat) group(`i') nocons
	}
		
	drop n_i xb_hat_it mu_hat_it sum_mu_i p_it u_it v_inv_u_hat del_m_*
	
	mat coef = e(b)
	mat Vnew = A_hat*B_hat*A_hat
	
	/* Calculate Wald Chi2 Statistic */
	local dof = colsof(coef)
	mat chi = coef * inv(Vnew) * coef'
	local chi2 = trace(chi)
	local pval = chi2tail(`dof',`chi2')	

	ereturn repost V = Vnew	
	ereturn scalar chi2 = `chi2'
	ereturn scalar p = `pval'
	ereturn local cmd "xtpqml"
	ereturn local cmdline "xtpqml `varlist'" 
}

if "`irr'" == "irr" {
	ereturn display, eform(IRR)
}

if "`irr'" != "irr" {
	ereturn display
}

di in green "Wald chi2(" in yellow `dof' in green ") = " in yellow %8.2f `chi2' /*
*/ "                                " in green "Prob > chi2 = " in yellow %8.4f `pval'

end

