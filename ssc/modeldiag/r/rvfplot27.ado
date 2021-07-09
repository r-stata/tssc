*! renamed 24 February 2003 
*! NJC 1.2.0 8 Oct 2002
*! NJC 1.1.0 7 Aug 2002
*! NJC 1.0.0 15 Oct 2001
program define rvfplot27	/* residual vs. fitted */
	version 7
	syntax [, * Anscombe Deviance Likelihood Pearson Residuals /*
	*/ FSCale(str) /* 
	*/ RESPonse RSTAndard RSTUdent Score Working SCale(str) KSM(str asis)] 

	if "`scale'" != "" & !index("`scale'","X") { 
		di as err "scale() does not contain X"
		exit 198 
	} 	
	
	if "`fscale'" != "" & !index("`fscale'","X") { 
		di as err "fscale() does not contain X"
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
		if "`e(cmd)'" == "glm" { local opts "response" }
		else local opts "residuals" 
	}	

	tempvar resid hat
	quietly predict `resid' if e(sample), `opts' 
	quietly predict `hat' if e(sample)
	
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
	label var `hat' "Fitted values"
	
	qui if "`scale'" != "" {
		local lbl : variable label `resid' 
		local lbl : subinstr local scale "X" `"`lbl'"', all 
		label var `resid' `"`lbl'"' 
		local scale : subinstr local scale "X" "`resid'", all  
		replace `resid' = `scale' 
	}
	
	qui if "`fscale'" != "" {
		local lbl : variable label `hat' 
		local lbl : subinstr local fscale "X" `"`lbl'"', all
		label var `hat' `"`lbl'"' 
		local fscale : subinstr local fscale "X" "`hat'", all  
		replace `hat' = `fscale' 
	}	

	if "`ksm'" != "" {
		tempname results 
		estimates hold `results'
		ksm `resid' `hat', `ksm' `options' 
		estimates unhold `results' 
	} 
	else gr `resid' `hat', `options'
end
