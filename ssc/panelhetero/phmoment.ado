/* Stata function for 
Ryo Okui and Takahide Yanagi. Panel Data Analysis with Heterogeneous 
   Dynamics. 2019. Journal of Econometrics */
   
/*
Note : 
    1. Data should be xtset.
    2. Data should be strongly balanced.

Contents :
    1. Empirical CDF Estimaton    : phecdf
	2. Moment Estimation          : phmoment
	3. Kernel Density Estimation  : phkd

*/

/// 2. Moment Estimation

capture prog drop phmoment
program define phmoment, eclass
    version 14.0
	syntax varlist(numeric) [if] [in] [, method(string) boot(integer 200) acov_order(integer 0) acor_order(integer 1) ]
	
	quietly xtset
	marksample touse
	
	if ("`r(balanced)'" != "strongly balanced"){
	    display as error "error: The given data is not xtset or strongly balanced."
	    exit
	}
	
	capture mata: mm_kern("e",0)
	if (_rc != 0) {
		display as error "error: Cannot find the package MOREMATA." _newline `"The package can be installed with the command "ssc install moremata"."'
	    exit
	}
	
	mata: data = st_data(., "`varlist'")
	mata: T = (`r(tmax)' - `r(tmin)')/`r(tdelta)' + 1
	mata: data = colshape(data, T)
	mata: acov_order = `acov_order'
	mata: acor_order = `acor_order'
	mata: B = `boot'
	
	if ("`method'" == "hpj"){
	    mata: m_hpjmoment(data, acov_order, acor_order, B)
	}
	else if ("`method'" == "toj"){
	    mata: m_tojmoment(data, acov_order, acor_order, B)
	}
	else if ("`method'" == "naive"){
	    mata: m_nemoment(data, acov_order, acor_order, B)
	}
	else{
	    display as error "error: The name of method is not correctly specified."
		exit
	}
	
	ereturn matrix ci = ci
	ereturn matrix se = se
	ereturn matrix est = est

end
