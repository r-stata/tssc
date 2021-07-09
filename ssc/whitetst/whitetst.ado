*! whitetst 1.2.3 CFB/NJC  17 Feb 2002 add fitted option for special form of test
* whitetst 1.2.2 CFB/NJC 16 Feb 2002 correction to gen prod quietly, as double
* whitetst 1.2.1 CFB/NJC 22 Feb 2000 rev to allow cnsreg
* whitetst 1.2.0 CFB/NJC 11 Oct 1999 rev for _rmcoll
* whitetst 1.1.0 CFB/NJC 2O Sept 1999
* whitetst V1.00   C F Baum/Nick Cox 9920
program define whitetst, rclass
	version 6.0
	syntax [if] [in] [, noSample Fitted ] 
	if "`e(cmd)'" != "regress" & "`e(cmd)'" !="cnsreg" {
		error 301
	}
	tempname res res2 b one regest yh yh2
	
	/* get regressorlist from previous regression */
        mat `b' = e(b)
        local rvarlst : colnames `b'
        local rvarlst : subinstr local rvarlst "_cons" "", word count(local hascons)
     
	marksample touse
	if "`sample'" == "" { qui replace `touse' = 0 if !e(sample) }

	/* fetch residuals and generate their squares */
	qui predict double `res' if `touse', res
	qui gen double `res2' = `res' * `res'

	if "`fitted'" == "" {
		local test "general"
		gen `one' = 1
		local rlist "`one' `rvarlst'" 
		tokenize `rlist' 
		local nrvars : word count `rlist' 

		/* generate all products of pairs from `one' and `rvarlst' */ 
	        local i = 1
        	while `i' <= `nrvars' {
	        	local j = `i' 
		        while `j' <= `nrvars' {
			        tempvar prod 
        		        qui gen double `prod' = ``i'' * ``j''
		        	local plist "`plist' `prod'" 
	                	local j = `j' + 1
		        }
        		local i = `i' + 1
	        }
	
		estimates hold `regest'
		tokenize `plist'
		mac shift /* ignore first such variable */ 
		qui _rmcoll `*' ,noconstant
		local xmtx  `r(varlist)'
		
		/* regress resids on all product variables; 
		constant included since first ignored */
		qui regress `res2' `xmtx' 
	}
	else {
	* alternate form of test (Wooldridge, 2000, p260): use only yhat, yhat^2
		local test "special"
		qui predict double `yh' if `touse', xb
		qui gen double `yh2' = `yh'^2
		estimates hold `regest'
		qui regress `res2' `yh' `yh2'
	}

	return scalar N = e(N)	
	return scalar white = e(N) * e(r2)
	return scalar df = e(df_m)
	return scalar p  = chiprob(return(df),return(white))
	
	estimates unhold `regest'
	
	di _n in g "White's `test' test statistic : "   /*
	*/ in y %9.0g return(white) /* 
	*/ in g "  Chi-sq(" %2.0f return(df)  ")  P-value = " /*
	*/ in y %6.0g return(p)
end

