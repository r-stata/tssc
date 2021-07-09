* renamed 28 February 2003   
*! 1.0.0 NJC 13 Sept 2002   
program define rvlrplot7, sort 
        version 7.0
	qui tsset /* error if not set as time series */
	syntax [, B2title(str) by(varname) * ] 
	
	tempvar resid lresid 
	qui { 
		predict `resid' if e(sample), res
		local lbl : variable label `resid' 
		gen `lresid' = L.`resid'
	}	
		
	if `"`b2title'"' == "" { 
		local b2title "lag 1 `lbl'" 
	} 

	if "`by'" != "" { 
		sort `by' 
		local byby "by(`by')" 
	}
	
	gra `resid' `lresid', `options'  b2(`"`b2title'"') `byby'
	qui corr `resid' `lresid' 
end

