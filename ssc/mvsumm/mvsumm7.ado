program def mvsumm7, rclass
*! CFB 1.0.10 15 Oct 2005
*! NJC 1.0.9 23 Sept 2004
*! CFB 1.0.8 30 June 2004
*! NJC 1.0.7 23 June 2004
*! CFB 1.0.6 10 April 2003
*! NJC 1.0.5 23 July 2002 
*! CFB 1.0.4 23 July 2002
*! NJC 1.0.3 23 July 2002 
*! CFB 1.0.2 22 July 2002 
*! CFB 1.0.1 17 July 2002 from statsmat.ado
* NJC 2.1.0 6 February 2002 
* NJC/CFB 2.0.0 3 October 2001 
* CFB 1.0.0 1 October 2001
*      1.0.1 : deal with missing values properly
*      1.0.2 : disallow gaps within timeseries
*      1.0.3 : NJC clean-up
*      1.0.4 : even window: end, odd window: middle, override with end
*      1.0.5 : NJC obsessive tidy; check for multiple statistics call 
*      1.0.6 : change levels to levels7 so will work under v8
*      1.0.7 : cut out levels use to allow large # panels 
*      1.0.8 : remove extraneous use of if clause in panel code
*      1.0.9 : correction to properly align results after if or in 
*      1.0.10: add force option to produce result when window not full
        version 7.0
        syntax varname [if] [in] [aweight fweight] /* 
	*/ , Generate(str) Stat(str) [ /* BY(varname) */ Window(int 3) /*  
	*/ /* MISSing Mid */ End FORCE]

	* check -generate()- 
	local gen "`generate'" 
	if "`gen'" != "" {
        	confirm new variable `gen'
		qui gen `gen' = .
	}
	else {
        	di as err "generate() not specified"
		exit 198
	}

	* what data to use 
	marksample touse, novarlist  

	* ensure that we have a calendar; check for panel var
        qui tsset 
	* if panelvar is defined, call that the by option
    	local by `r(panelvar)'
 	local timevar `r(timevar)'
        markout `touse' `timevar'
        tsreport if `touse', report panel
        if r(N_gaps) {
                di as err "sample may not contain gaps"
                exit 198 
        }
        
	* from movsumm
	if `window' < 2 {
        	di as err "window length must be at least 2"
		exit 198
	}

	* from movsumm
	local jaybase = `window'
        local jlast = _N
	* check for odd-length window
	if mod(`window',2) != 0 & "`end'" != "end" { 
		local shift = int(`window'/2) 
	}
	* di as txt "shift is " as res  "`shift'"

	if "`by'" != "" { markout `touse' `by', strok } 
	qui count if `touse'
	if r(N) == 0 { error 2000 }

	return local N = r(N)
	
	local nstats : word count `stat'
	* must assure that only one stat is selected here, 
	* unless generate() can be made into a list of new vars
	if `nstats' > 1 { 
		di as txt "sorry: multiple statistics not (yet) supported" 
		exit 0 
	} 	

	* which statistic? 
	local monly  "meanonly" 
	
        foreach st of local stat {
                if "`st'" == "n" | "`st'" == "N" | "`st'" == "count" {
                        local s "N" 
                }
                else if "`st'" == "sum" | "`st'" == "sum_w" { 
                        local s "`st'"
                }
                else if "`st'" == "mean" {
                        local s "mean"
		}	
                else if "`st'" == "min" | "`st'" == "max" {
                        local s "`st'"
                } 
		else if "`st'" == "range" { 
			local s "range"
		}
                else if "`st'" == "var" | "`st'" == "Var" {
			local monly  
                        local s "Var"
                }
                else if "`st'" == "SD" | "`st'" == "sd" {
			local monly  
                        local s "sd"
                }
		
/* do not allow mult stats at this point (would require a stub
   option to generate multiple result vars)
   			else if "`st'" == "p" { 
			local monly  
			local detail "detail" 
			local s "p1 p5 p10 p25 p50 p75 p90 p95 p99" 
			local st "`s'" 
			} 
		else if "`st'" == "q" { 
			local monly  
			local detail "detail"
			local s "p25 p50 p75"
			local st "`s'" 
			} 	
*/

	        else if "`st'" == "p1" | "`st'" == "p5" {
       			local monly  
			local detail "detail" 
	        	local s "`st'"
	        }
        	else if "`st'" == "p10" | "`st'" == "p25" {
			local monly  
			local detail "detail" 
            		local s "`st'" 
            	}
	        else if "`st'" == "p50" /* 
		*/ | "`st'" == "med" | "`st'" == "median" {
		 	local monly  
			local detail "detail" 
            		local s "p50" 
            	}
         	else if "`st'" == "p75" | "`st'" == "p90" {
			local monly  
			local detail "detail" 
            		local s "`st'" 
            	}
         	else if "`st'" == "p95" | "`st'" == "p99" {
			local monly  
			local detail "detail" 
            		local s "`st'" 
            	}
	        else if "`st'" == "skewness" | "`st'" == "skew" {
			local monly  
			local detail "detail" 
            		local s "skewness"
            	}
         	else if "`st'" == "kurtosis" | "`st'" == "kurt" {
			local monly  
			local detail "detail" 
            		local s "kurtosis" 
            	}
         	else if "`st'" == "se" | "`st'" == "SE" | "`st'" == "semean" {
			local monly  
			local detail "detail" 
            		local s "se"
            	}
		else if "`st'" == "iqr" | "`st'" == "IQR" { 
			local monly  
			local detail "detail" 
			local s "iqr" 
		}
		else if "`st'" == "zero" | "`st'" == "0" { 
			local s "0"
		}	
        	else {
        		di as err "stat() option invalid"
		        exit 198
	        }
        	local cnames "`cnames' `st'"
		local stats "`stats' `s'" 
        } /* end of -foreach st of local stat */ 

	tempname result
	
	* in panel context, get distinct values of panelvar 
	* and hit with -foreach-
	qui   if "`by'" != "" {
		tempvar group 
		egen `group' = group(`by') /* if `touse' */ 
		su `group', meanonly 
		local max = `r(max)' 
		local start 0
		local fin 0
		forval i = 1 / `max' { 
			local jay = `jaybase'
  			count if `group' == `i'
  			local enn = r(N)
  			local jlast = `enn' + `fin'
			* logic from movsumm
			local eye = 1 + `start'
			local kay = `window' + `start'
			while `jay' <= `jlast' {
 * correction	    su `varlist' in `eye'/`kay' /* 
 *			*/ if `group' == `i' [`weight' `exp'], `detail' `monly'
		                su `varlist' in `eye'/`kay' [`weight' `exp'], `detail' `monly'			
		                local na = r(N)
                		foreach s of local stats { 
					if "`s'" == "0" { 
						scalar `result' = 0 
					}	
		            		else if "`s'" == "se" {
                				scalar `result' = r(sd) / sqrt(r(N))  
 			                }
					else if "`s'" == "iqr" { 
						scalar `result' = r(p75) - r(p25)  
					} 	
					else if "`s'" == "range" { 
						scalar `result' = r(max) - r(min)  
					}
		            		else scalar `result' = r(`s') 
            			}            
				if "`force'" == "" {
					replace `gen' = `result' in `jay' if `na' == `window'
            	          }
            	     else {
            	     	     replace `gen' = `result' in `jay'
            	     	}
               	          local eye = `eye' + 1
                  		local jay = `jay' + 1
		       		local kay = `kay' + 1
                	}
	            	local start = `start' + `enn'
       	    		local fin = `fin' + `enn'
            		local jaybase = `jaybase' + `enn' 
	        }
	} /* end of code for panels */ 
	
	* single timeseries, no loop over panel var
	else { 
		* logic from movsumm
		local eye = 1
		local kay = `window'
		local jay = `jaybase'
		qui while `jay' <= `jlast' {
        		su `varlist' in `eye'/`kay' /* if `touse' */ /* 
			*/ [`weight' `exp'], `detail' `monly'
		        local na = r(N)
            		foreach s of local stats { 
				if "`s'" == "0" { 
					scalar `result' = 0 
				}	
           			else if "`s'" == "se" {
		                	scalar `result' = r(sd) / sqrt(r(N))  
            			}
				else if "`s'" == "iqr" { 
					scalar `result' = r(p75) - r(p25)  
				} 	
				else if "`s'" == "range" { 
					scalar `result' = r(max) - r(min)  
				}
		            	else scalar `result' = r(`s') 
            		}       
            	if "`force'" == "" {     
				replace `gen' = `result' in `jay' if `na' == `window'  
		        }
		     else {
		     		replace `gen' = `result' in `jay' 
		     }  
		   		local eye = `eye' + 1
            		local jay = `jay' + 1
            		local kay = `kay' + 1
		}     	
	} /* end of code for no panels */ 
	
	qui if "`shift'" != "" {
		replace `gen' = F`shift'.`gen'
	} 

	qui replace `gen' = . if !`touse' 
end 

 
