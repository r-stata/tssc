*! 2.0.2 NJC 21 October 2004 
* 2.0.1 NJC 22 June 2004 
* 2.0.0 NJC 27 Feb 2003 
* 1.1.0 NJC 12 Sept 2002 
* 1.0.0 NJC 10 Sept 2002 
program rvpplot2 
	// residual vs predictor 
	version 8
	syntax varname [, Anscombe Deviance Likelihood Pearson Residuals ///
	RESPonse RSTAndard RSTUdent Score Working PLOT(str asis) ///
	RSCale(str) FORCE LOWESS(str asis) LOWESS2 YTItle(str asis) * ] 
	
	if "`e(cmd)'" == "" error 301 

	if `: word count `e(depvar)'' > 1 { 
		di as err "rvpplot2 not allowed after `e(cmd)'" 
		exit 498 
	} 	
	
	if "`rscale'" != "" & !index("`rscale'","X") { 
		di as err "rscale() does not contain X"
		exit 198 
	} 	

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
		if "`e(cmd)'" == "glm" local opts "response" 
		else local opts "residuals" 
	}

	// -force- allows predictors not in model to be used 
	if "`force'" == "" { 
		if "`e(cmd)'" == "anova" {
			anova_terms
			local aterms `r(rhs)'
			if !`: list varlist in aterms' { 
				di as err "`varlist' is not in the model"
				exit 398
			}
		}
		else { 
		// regress-type command 
			capture local beta = _b[`varlist']
			if _rc {
				di as err "`varlist' is not in the model"
				exit 398
			}
		}
	}

	tempvar resid 
	quietly predict `resid' if e(sample), `opts' 
	
	if "`opts'" == "rstudent"       local opt "Studentized"
	else if "`opts'" == "rstandard" local opt "Standardized" 
	else local opt = upper(substr("`opts'",1,1)) + substr("`opts'",2,.)

	if "`opts'" != "residuals" label var `resid' "`opt' residuals" 
	
	qui if "`rscale'" != "" {
		local lbl : variable label `resid' 
		local lbl : subinstr local rscale "X" `"`lbl'"', all 
		label var `resid' `"`lbl'"' 
		local rscale : subinstr local rscale "X" "`resid'", all  
		replace `resid' = `rscale' 
	}
	
	if `"`ytitle'"' == "" { 
		if `"`lbl'"' != "" local ytitle `"`lbl'"' 
		else local ytitle : variable label `resid' 
	}	
	
	if `"`lowess'`lowess2'"' != "" {
		tempname results 
		_estimates hold `results'
		local what "lowess `lowess'"
		
		twoway lowess `resid' `varlist', ///
		`lowess'                     /// 
		|| scatter `resid' `varlist',    ///
		legend(order(2 1 "`what'")) yti(`ytitle') `options' ///
		|| `plot'			///
	        // blank
		
		_estimates unhold `results' 
	} 
	else { 
		twoway scatter `resid' `varlist', yti(`ytitle') `options' ///
		|| `plot'			///
		// blank
	}
end
		
