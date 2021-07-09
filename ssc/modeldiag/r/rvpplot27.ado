*! renamed 27 Feb 2003 
*! 1.0.0 NJC 10 Sept 2002 
*! -rvpplot- version 3.0.7  05sep2001
program define rvpplot27, sort /* residual vs. predictor */
	version 7
	syntax varname [, Anscombe Deviance Likelihood Pearson Residuals /* 
	*/ RESPonse RSTAndard RSTUdent Score Working SCale(str) FORCE /*
	*/ KSM(str asis) BY(varname) * ]
	
	if "`e(cmd)'" == "" { 
		error 301 
	}

	local ndepvar : word count `e(depvar)' 
	if `ndepvar' > 1 { 
		di as err "rvpplot2 not allowed after `e(cmd)'" 
		exit 498 
	} 	

	* -force- allows predictors not in model to be used 
	if "`force'" == "" { 
		if "`e(cmd)'" == "anova" {
			anova_terms
			local aterms `r(rhs)'
			local found 0
			foreach trm of local aterms {
				if "`trm'" == "`varlist'" {
					local found 1
					continue, break
				}
			}
			if !`found' {
				di as err "`varlist' is not in the model"
				exit 398
			}
		}
		else { /* regress-type command */
			capture local beta = _b[`varlist']
			if _rc {
				di as err "`varlist' is not in the model"
				exit 398
			}
		}
	}	

	* -scale()- option
	if "`scale'" != "" & !index("`scale'","X") { 
		di as err "scale() does not contain X"
		exit 198 
	} 	

	* choice of type of residual 
	local opts "`anscombe' `deviance' `likelihood' `pearson'"  
	local opts "`opts' `residuals' `response' `rstandard' `rstudent'"
	local opts "`opts' `score' `working'" 
	local opts = trim("`opts'") 
	
	local nopts : word count `opts' 
	if `nopts' > 1 { 
		di as err "must specify at most one type of residual" 
		exit 198 
	}
	else if `nopts' == 0 {
		if "`e(cmd)'" == "glm" { local opts "response" }
		else local opts "residuals" 
	}	

	* calculation of residual 
	tempvar resid 
	quietly predict `resid' if e(sample), `opts' 
	
	* label residual variable  
	if "`opts'" == "rstudent" { 
		local opt "Studentized"
	}
	else if "`opts'" == "rstandard" { 
		local opt "Standardized" 
	}
	else {
		local opt = /* 
		*/ upper(substr("`opts'",1,1)) + substr("`opts'",2,.)
	}	
	if "`opts'" != "residuals" { label var `resid' "`opt' residuals" }
	
	* change residual scale? 
	qui if "`scale'" != "" {
		local lbl : variable label `resid' 
		local lbl : subinstr local scale "X" `"`lbl'"', all 
		label var `resid' `"`lbl'"' 
		local scale : subinstr local scale "X" "`resid'", all  
		replace `resid' = `scale' 
	}	

	if "`by'" != "" { 
		sort `by' 
		local byby "by(`by')" 
	} 

	if "`ksm'" != "" {
		tempname results 
		estimates hold `results'
		ksm `resid' `varlist', `ksm' `options' `byby' 
		estimates unhold `results' 
	} 
	else gr `resid' `varlist', `options' `byby' 
end
 
