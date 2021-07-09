/* Stata function for 
Ryo Okui and Takahide Yanagi. Kernel Estimation for Panel Data       
   with Heterogeneous Dynamics. 2019. The Econometrics Journal.
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

/// 3. Kernel Density Estimation

capture prog drop phkd
program define phkd, eclass
    version 14.0
	syntax varlist(numeric) [if] [in] [, method(string) acov_order(integer 0) acor_order(integer 1) ci(string) graph(string)]
	
	capture drop mean_dest
	capture drop acov_dest
	capture drop acor_dest
	capture drop mean_grid
	capture drop acov_grid
	capture drop acor_grid
	capture drop mean_UCI
	capture drop acov_UCI
	capture drop acor_UCI
	capture drop mean_LCI
	capture drop acov_LCI
	capture drop acor_LCI
	capture graph drop meandest
	capture graph drop vardest
	capture graph drop acovdest
	capture graph drop acordest
	
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
	
	capture mata: kdens_bw_dpi(runiform(10,1), level = 2)
	if (_rc != 0) {
		display as error "error: Cannot find the package KDENS." _newline `"The package can be installed with the command "net "describe kdens, from(http://fmwww.bc.edu/repec/bocode/k/)":ssc describe kdens"."'
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
	
	if ("`method'" == "hpj"){
	    mata: m_hpjkd(data, acov_order, acor_order)
	}
	else if ("`method'" == "toj"){
	    mata: m_tojkd(data, acov_order, acor_order)
	}
	else if ("`method'" == "naive"){
	    mata: m_nekd(data, acov_order, acor_order)
	}
	else{
	    display as error "error: The name of method is not correctly specified."
		exit
	}
	
	
	foreach i in `graph'{
	    if ("`i'" == "mean"){
		    if("`ci'" == "on"){
			    graph twoway rarea mean_UCI mean_LCI mean_grid, color(gs14) || line mean_dest mean_grid, ytitle("Density") ///
	                              xtitle("Mean") title("Kernel Density Estimation for Mean") xlabel(minmax)  ///
								  legend(cols(2) order(2 "point estimate" 1 "95% C.I." ))
	            graph rename meandest
			
			}
			else{
			    graph twoway line mean_dest mean_grid, ytitle("Density") ///
	                              xtitle("Mean") xlabel(minmax) title("Kernel Density Estimation for Mean")
	            graph rename meandest
			}
	    }
		
		if ("`i'" == "acov"){
	        if (`acov_order' == 0){
			    if("`ci'" == "on"){
			        graph twoway rarea acov_UCI acov_LCI acov_grid, color(gs14) || line acov_dest acov_grid, ytitle("Density") ///
	                              xtitle("Variance") xlabel(minmax) title("Kernel Density Estimation for Variance") legend(cols(2) order(2 "point estimate" 1 "95% C.I." ))
	                graph rename vardest
			    }
			    else{
			        graph twoway line acov_dest acov_grid, ytitle("Density") ///
	                              xtitle("Variance") xlabel(minmax) title("Kernel Density Estimation for Variance")
	                graph rename vardest
			    }
	        }
	        else{
			    if("`ci'" == "on"){
			        graph twoway rarea acov_UCI acov_LCI acov_grid, color(gs14) || line acov_dest acov_grid, ytitle("Density") ///
	                              xtitle("Autocovariance") xlabel(minmax) title("Kernel Density Estimation for Autocovariance of order `acov_order'") legend(cols(2) order(2 "point estimate" 1 "95% C.I." ))
	                graph rename acovdest
			    }
			    else{
			        graph twoway line acov_dest acov_grid, ytitle("Density") ///
	                              xtitle("Autocovariance") xlabel(minmax) title("Kernel Density Estimation for Autocovariance of order `acov_order'")
	                graph rename acovdest
			    }
	        }
		}
		
		if ("`i'" == "acor"){
			if("`ci'" == "on"){
			    graph twoway rarea acor_UCI acor_LCI acor_grid, color(gs14) || line acor_dest acor_grid, ytitle("Density") ///
	                              xtitle("Autocorrelation") xlabel(minmax) title("Kernel Density Estimation for Autocorrelation of order `acor_order'") legend(cols(2) order(2 "point estimate" 1 "95% C.I." ))
	            graph rename acordest
			
			}
			else{
			    graph twoway line acor_dest acor_grid, ytitle("Density") ///
	                              xtitle("Autocorrelation") xlabel(minmax) title("Kernel Density Estimation for Autocorrelation of order `acor_order'")
	            graph rename acordest
			}
	    }
	}
	
	drop mean_dest acov_dest acor_dest mean_grid acov_grid acor_grid
	drop mean_UCI acov_UCI acor_UCI mean_LCI acov_LCI acor_LCI
	quietly keep in 1/`obs'
	
end
