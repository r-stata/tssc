*! NJC 2.1.2 7 November 2005 
*! NJC 2.1.1 12 December 2004
*! NJC 2.1.0 6 February 2002 
*! NJC/CFB 2.0.0 3 October 2001 
* CFB 1.0.0 1 October 2001
program def statsmat, rclass
        version 7.0
        syntax varlist(min=1) [if] [in] [aweight fweight] /* 
	*/ [ , Matrix(str) Stat(str) noHeader BY(varname) XPose /*  
	*/ MISSing LISTWISE MAGIC(numlist max=1) * ] 

	* version 7: missings not allowed, so apply magic 
	* otherwise: no magic 
	if "`magic'" == "" { 
		if "`c(version)'" == "" | _caller() <= 7 {
			local magic "1e+300"
			local nomagic "*" 
		}
		else { 
			local applymagic "*" 
		}
	} 
	
	* what data to use 
	if "`listwise'" == "" { 
		marksample touse 
	}
	else { 
		tempvar touse 
		mark `touse' `if' `in' 
	} 

	if "`by'" != "" & "`missing'" == "" { markout `touse' `by', strok } 
	qui count if `touse'
	if r(N) == 0 { error 2000 }
	
	if "`listwise'" == "" { 
		return local N = r(N) 
	}
	
	* syntax checking: { varlist | varname, by(byvar) } 
	local nvars : word count `varlist'
	
	if "`by'" != "" { 
		if `nvars' > 1 { 
			di in r "by() option only allowed with single varname" 
			exit 198 
		}
	}

	* which statistics? 
        if "`stat'" == "" { local stat "min q max mean sd" }
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
		else if "`st'" == "extra" | "`st'" == "." {
			if "`c(version)'" == "" | _caller() <= 7 { 
				noi di as txt "stat(extra) not allowed in Stata 7"
				local s 
				local st 
			} 
			else { 
				local s "extra" 
				local st "extra" 
			}	
		}	
                else {
                        di in r "stat() option invalid"
                        exit 198
                }

                local cnames "`cnames' `st'"
		local stats "`stats' `s'" 
        }
	
	* if by(), separate variables 
	qui if "`by'" != "" {
		tempname sep 
		separate `varlist' if `touse', by(`by') gen(`sep') `missing' 
		local origvar "`varlist'"  
		unab varlist : `sep'* 
		local nvars : word count `varlist'
	}	

	* set up matrix 
        if "`matrix'" == "" {
                local header "noheader"
                tempname matrix
        }
	local nstats : word count `stats' 
	mat `matrix' = J(`nvars',`nstats',0)

	* calculation loop and fill in matrix
	tempname result
	local i = 1 
        foreach v of local varlist { 
                qui su `v' if `touse' [`weight' `exp'], `detail' `monly'
		local j = 1 
                foreach s of local stats { 
			if "`s'" == "0" { 
				scalar `result' = 0 
			}	
			else if "`s'" == "extra" {
				scalar `result' = .
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
			
`applymagic'	mat `matrix'[`i',`j'] = cond(`result' < ., `result', `magic')
`nomagic'       mat `matrix'[`i',`j'] = `result' 

			local j = `j' + 1 
                }
		local i = `i' + 1 
        }

	* matrix row and column names 
	if "`by'" == "" { 
		mat rownames `matrix' = `varlist'
	} 
	else {
		tempvar order
		gen long `order' = _n 
		local vallbl : value label `by'
		local fmt: format `by' 
		capture confirm string var `by' 
		local isstr = _rc == 0
		
		foreach v of local varlist {
			su `order' if `v' < ., meanonly 
			* numeric value or string value 
			local val = `by'[`r(min)']

			* value label 
			if "`vallbl'" != "" { 
				local val : label `vallbl' `val' 
				* first word only 
				local val : word 1 of `val'
			} 
			* apply format, but no leading or trailing spaces 
			else { 
				if `isstr' { local val : di `fmt' "`val'" } 
				else local val : di `fmt' `val' 
				local val = trim("`val'") 
			} 
			
			* missings or spaces or . in strings 
			if "`val'" == "." | "`val'" == "" { 
				local val "missing" 
			}
			else if trim("`val'") == "" { 
				local val "space(s)"
			}
			else local val : subinstr local val "." ",", all
			
			local rownames "`rownames' `val'" 
		}
		mat rownames `matrix' = `rownames' 
	}	
	
        mat colnames `matrix' = `cnames'
	
	* output matrix 
	if "`xpose'" == "xpose" { mat `matrix' = (`matrix')' } 
        mat li `matrix', `options' `header'

end 
