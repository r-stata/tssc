/* Stata function for 
Ryo Okui and Takahide Yanagi. Panel Data Analysis with Heterogeneous 
   Dynamics. 2019. Journal of Econometrics*/
   
/*
Note : 
    1. Data should be xtset.
    2. Data should be strongly balanced.

Contents :
    1. Empirical CDF Estimaton    : phecdf
	2. Moment Estimation          : phmoment
	3. Kernel Density Estimation  : phkd

*/

/// 1. Empirical CDF Estimation

capture prog drop phecdf
program define phecdf, eclass
    version 14.0
	syntax varlist(numeric) [if] [in] [, method(string) acov_order(integer 0) acor_order(integer 1) boot(integer 200) ci(string) graph(string)]
	
	capture drop mean_ecdf
	capture drop acov_ecdf
	capture drop acor_ecdf
	capture drop mean_grid
	capture drop acov_grid
	capture drop acor_grid
	capture drop mean_UCI
	capture drop acov_UCI
	capture drop acor_UCI
	capture drop mean_LCI
	capture drop acov_LCI
	capture drop acor_LCI
	capture graph drop meanecdf
	capture graph drop varecdf
	capture graph drop acovecdf
	capture graph drop acorecdf
	
	local obs = _N
	
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
	
	if ("`ci'"==""){
	    local ci "on"
	}
	if (("`ci'"!="on")&("`ci'"!="off")){
	    display as error "error: ci should be defined as "on" or "off"
	}
	
	if ("`graph'" == ""){
	    local graph "mean acov acor"
	}
	
	mata: data = st_data(., "`varlist'")
	mata: T = (`r(tmax)' - `r(tmin)')/`r(tdelta)' + 1
	mata: data = colshape(data, T)
	mata: acov_order = `acov_order'
	mata: acor_order = `acor_order'
	mata: B = `boot'
	
	if ("`method'" == "hpj"){
	    mata: m_hpjecdf(data, acov_order, acor_order, B)
	}
	else if ("`method'" == "toj"){
	    mata: m_tojecdf(data, acov_order, acor_order, B)
	}
	else if ("`method'" == "naive"){
	    mata: m_neecdf(data, acov_order, acor_order, B)
	}
	else{
	    display as error "error: The name of method is not correctly specified."
		exit
	}
	
	foreach i in `graph'{
	    if ("`i'" == "mean"){
		    if("`ci'" == "on"){
			    graph twoway rarea mean_UCI mean_LCI mean_grid, color(gs14) || line mean_ecdf mean_grid, ytitle("Cumulative Distribution") ///
	                              xtitle("Mean") title("Empirical CDF Estimation for Mean") xlabel(minmax)  ///
								  legend(cols(2) order(2 "point estimate" 1 "95% C.I." ))
	            graph rename meanecdf
			
			}
			else{
			    graph twoway line mean_ecdf mean_grid, ytitle("Cumulative Distribution") ///
	                              xtitle("Mean") xlabel(minmax) title("Empirical CDF Estimation for Mean")
	            graph rename meanecdf
			}
	    }
		
		if ("`i'" == "acov"){
	        if (`acov_order' == 0){
			    if("`ci'" == "on"){
			        graph twoway rarea acov_UCI acov_LCI acov_grid, color(gs14) || line acov_ecdf acov_grid, ytitle("Cumulative Distribution") ///
	                              xtitle("Variance") xlabel(minmax) title("Empirical CDF Estimation for Variance") legend(cols(2) order(2 "point estimate" 1 "95% C.I." ))
	                graph rename varecdf
			    }
			    else{
			        graph twoway line acov_ecdf acov_grid, ytitle("Cumulative Distribution") ///
	                              xtitle("Variance") xlabel(minmax) title("Empirical CDF Estimation for Variance")
	                graph rename varecdf
			    }
	        }
	        else{
			    if("`ci'" == "on"){
			        graph twoway rarea acov_UCI acov_LCI acov_grid, color(gs14) || line acov_ecdf acov_grid, ytitle("Cumulative Distribution") ///
	                              xtitle("Autocovariance") xlabel(minmax) title("Empirical CDF Estimation for Autocovariance of order `acov_order'") legend(cols(2) order(2 "point estimate" 1 "95% C.I." ))
	                graph rename acovecdf
			    }
			    else{
			        graph twoway line acov_ecdf acov_grid, ytitle("Cumulative Distribution") ///
	                              xtitle("Autocovariance") xlabel(minmax) title("Empirical CDF Estimation for Autocovariance of order `acov_order'")
	                graph rename acovecdf
			    }
	        }
		}
		
		if ("`i'" == "acor"){
			if("`ci'" == "on"){
			    graph twoway rarea acor_UCI acor_LCI acor_grid, color(gs14) || line acor_ecdf acor_grid, ytitle("Cumulative Distribution") ///
	                              xtitle("Autocorrelation") xlabel(minmax) title("Empirical CDF Estimation for Autocorrelation of order `acor_order'") legend(cols(2) order(2 "point estimate" 1 "95% C.I." ))
	            graph rename acorecdf
			
			}
			else{
			    graph twoway line acor_ecdf acor_grid, ytitle("Cumulative Distribution") ///
	                              xtitle("Autocorrelation") xlabel(minmax) title("Empirical CDF Estimation for Autocorrelation of order `acor_order'")
	            graph rename acorecdf
			}
	    }
	}
	
	drop mean_ecdf acov_ecdf acor_ecdf mean_grid acov_grid acor_grid
	drop mean_UCI acov_UCI acor_UCI mean_LCI acov_LCI acor_LCI
    quietly keep in 1/`obs'
	
end
