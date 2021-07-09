*! NJC 1.1.0 24 October 2004
* NJC 1.0.0 3 April 2003
program racplot
	// residual acf plot 
	version 8
	syntax [, Anscombe Deviance Likelihood Pearson Residuals ///
	RESPonse RSTAndard RSTUdent Score Working RSCale(str)    ///
	YTItle(str asis) plot(passthru) * ]

	// error message if not -tsset- 
	qui tsset 

	// -rscale()- option
	if "`rscale'" != "" & !index("`rscale'","X") { 
		di as err "rscale() does not contain X"
		exit 198 
	} 	

	// choice of type of residual 
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

	// calculation of residual 
	tempvar resid 
	quietly predict `resid' if e(sample), `opts' 
	
	// label residual variable  
	if "`opts'" == "rstudent"       local opt "Studentized"
	else if "`opts'" == "rstandard" local opt "Standardized" 
	else local opt = upper(substr("`opts'",1,1)) + substr("`opts'",2,.)
		
	if "`opts'" != "residuals" label var `resid' "`opt' residuals" 
	
	// change residual scale? 
	qui if "`rscale'" != "" {
		local lbl : variable label `resid' 
		local lbl : subinstr local rscale "X" `"`lbl'"', all 
		label var `resid' `"`lbl'"' 
		local rscale : subinstr local rscale "X" "`resid'", all  
		replace `resid' = `rscale' 
	}	

	// autocorrelation calculation and graph 
	if `"`ytitle'"' == "" { 
		local ytitle : variable label `resid' 
		local ytitle `"Autocorrelations of `ytitle'"' 
	} 
	
	ac `resid', yti(`"`ytitle'"') `options' `plot'  
end
