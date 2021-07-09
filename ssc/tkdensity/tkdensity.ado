*! 1.0.1 NJC 9 August 2012 
*! 1.0.0 NJC 3 July 2012 
program tkdensity, rclass 
	version 8.2 
	syntax varname [if] [in] [, * GRAPHopts(str asis) Trans(str) Generate(string) ]
	
	marksample touse 
	quietly {
		count if `touse' 
		if r(N) == 0 error 2000

		if "`trans'" == "" local trans "ln"  
	
		tempvar y x d
		tempname bwidth 

		if substr("`trans'", 1, 4) == "loga" | "`trans'" == "ln" { 
			count if `varlist' <= 0 & `touse' 
			if r(N) { 
				di as err "{p}logarithmic transformation not applicable: all values should be positive{p_end}" 
				exit 498 
			} 
			gen double `y' = ln(`varlist') if `touse' 
			local tr "ln" 
		}
		else if substr("`trans'", 1, 4) == "cube" { 
			gen double `y' = cond(`varlist' >= 0, `varlist'^(1/3), -(abs(`varlist')^(1/3))) if `touse' 
			local tr "cube root" 
		} 
		else if "`trans'" == "root" | substr("`trans'", 1, 6) == "square" { 
			count if `varlist' < 0 & `touse' 
			if r(N) { 
				di as err "{p}square root transformation not applicable: all values should be zero or positive{p_end}" 
				exit 498 
			} 
			gen double `y' = sqrt(`varlist') if `touse'  
			local tr "square root" 
		} 
		else if substr("`trans'", 1, 3) == "rec" { 
			count if `varlist' <= 0 & `touse' 
			if r(N) { 
				di as err "{p}reciprocal transformation not applicable: all values should be positive{p_end}" 
				exit 498 
			} 
			gen double `y' = 1/`varlist' if `touse' 
			local tr "reciprocal" 
		} 
		else if "`trans'" == "logit" { 
			count if `varlist' <= 0 | `varlist' >= 1 & `touse' 
			if r(N) { 
				di as err "{p}logit transformation not applicable: all values should be within (0, 1){p_end}" 
				exit 498 
			} 
			gen double `y' = logit(`varlist') if `touse' 
			local tr "logit" 
		} 
		else { 
			di as err "invalid transformation" 
			exit 498
		} 

		kdensity `y' , gen(`x' `d') `options' nograph 
		local kernel "`r(kernel)'" 
		scalar `bwidth' = cond(r(bwidth) < ., r(bwidth), r(width)) 
		local bw = cond(r(bwidth) < ., r(bwidth), r(width)) 

		if "`tr'" == "ln" { 
			replace `x' = exp(`x') 
			replace `d' = `d' / `x' 
		}
		else if "`tr'" == "cube root" { 
			replace `x' = `x'^3 
			replace `d' = (1/3) * `d' / `x'^(2/3) 
		} 
		else if "`tr'" == "square root" { 
			replace `x' = `x'^2 
			replace `d' = (1/2) * `d' / sqrt(`x') 
		} 
		else if "`tr'" == "reciprocal" { 
			replace `x' = 1/`x' 
			replace `d' = `d' / `x'^2 
		} 
		else if "`tr'" == "logit" { 
			replace `x' = invlogit(`x') 
			replace `d' = `d' / (`x' * (1 - `x')) 
		} 

		label var `d' "Density" 
		_crcslbl `x' `varlist' 
	} 

	line `d' `x' , note(`kernel' on `tr' scale `bw') `graphopts' 

	qui if "`generate'" != "" { 
		tokenize "`generate'" 
		args newx newd garbage 
		capture confirm new var `generate' 
		if _rc | "`newd'" == "" | "`garbage'" != "" { 
			di as err "generate() option invalid: specify two new variable names" 
			exit 198 
		} 
		clonevar `newd' = `d' 
		clonevar `newx' = `x' 
	} 

	return local kernel "`r(kernel)'"
	return scalar bwidth = `bwidth'  
end 
	
