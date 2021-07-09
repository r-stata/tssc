*! renamed 26 February 2003 
*! NJC 1.0.0 15 Apr 2002
program define rdplot7, sort /* residual distribution plot */
	version 7
	syntax [, * Anscombe Deviance Likelihood Pearson Residuals /* 
	*/ RESPonse RSTAndard RSTUdent Score Working SCale(str) /*
	*/ HIstogram Box * BY(varname) /* 
	*/ AT(numlist min=1 sort) Group(numlist int >0 max=1) ]

	* -scale()- option
	if "`scale'" != "" & !index("`scale'","X") { 
		di as err "scale() does not contain X"
		exit 198 
	} 	

	* -histogram-, -box- or -dotplot- 
	if "`histogram'" != "" & "`box'" != "" { 
		di as err "must choose between histogram and box options"
		exit 198 
	} 
	local gcmd = cond("`histogram'`box'" != "", "graph", "dotplot") 

	* -egen, cut()- options, or plain -by()-  
	if "`group'" != "" & "`at'" != "" { 
		di as err "must choose between group() and at() options"
		exit 198 
	} 
	if "`group'" != "" { 
		if "`by'" == "" { 
			local by : word 1 of `e(varnames)' 
			if "`by'" == "" { 
				tempname b 
				mat `b' = e(b) 
				local cnames : colnames `b' 
				local by : word 1 of `cnames' 
				if "`by'" == "" { 
					di as err "no covariate names stored"
					exit 198 
				} 	
			} 	
		}
		tempvar g
		egen `g' = cut(`by') if e(sample), gr(`group') label
		_crcslbl `g' `by' 
	} 
	else if "`at'" != "" { 
		if "`by'" == "" {
			local by : word 1 of `e(varnames)' 
			if "`by'" == "" {
				tempname b 
				mat `b' = e(b) 
				local cnames : colnames `b' 
				local by : word 1 of `cnames' 
				if "`by'" == "" { 
					di as err "no covariate names stored"
					exit 198 
				} 	
			} 	
		}
		tempvar g 
		egen `g' = cut(`by') if e(sample), at(`at') label 
		_crcslbl `g' `by' 
	} 
	else if "`by'" != "" { 
		local g "`by'" 
	} 
	if "`g'" != "" { 
		sort `g' 
		local byby "by(`g')" 
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

	* graph 
	`gcmd' `resid', `options' `byby' `histogram' `box' 
end
