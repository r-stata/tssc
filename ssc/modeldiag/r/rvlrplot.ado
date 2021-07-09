*! 2.1.0 NJC 28 October 2004
* 2.0.0 NJC 3 April 2003   
* 1.0.0 NJC 13 Sept 2002   
program rvlrplot, sort 
        version 8
	
	// error if not set as time series 
	qui tsset 	
	
	syntax [, Anscombe Deviance Likelihood Pearson Residuals ///
	RESPonse RSTAndard RSTUdent Score Working                ///
	STAndardized STUdentized MODified ADJusted  * PLOT(str asis)] 
	
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

	local mod `standardized' `studentized' `modified' `adjusted'  

	tempvar resid lresid 
	qui { 
		predict `resid' if e(sample), `opts' `mod' 
		local lbl : variable label `resid' 
		gen `lresid' = L.`resid'
	}	
	
	if "`opts'" == "rstudent"       local opt "Studentized"
	else if "`opts'" == "rstandard" local opt "Standardized" 
	else if "`mod'" != ""  	        local opt "`=proper("`mod'")' `opts'"
	else                            local opt "`=proper("`opts'")'" 
		
	if "`opts'" != "residuals" label var `resid' "`opt' residuals" 
	
	twoway scatter `resid' `lresid',  xti(`"lag 1 `lbl'"') `options' /// 
	|| `plot' ///
	// blank 
	
	qui corr `resid' `lresid' 
end

