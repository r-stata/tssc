*! 1.0.0 NJC 9 December 2008  
program eofplot
	version 9  
	syntax [, Components(numlist int >0) Factors(numlist int >0) Number ///
	noROTated * ] 

	if "`rotated'" != "norotated" & "`e(r_criterion)'" != "" { 
		if "`e(r_L)'" != "matrix" { 
			di as err "rotated loadings e(r_L) not found" 
			exit 498 
		}
		local which "r_" 
		local note note("`e(r_criterion)' rotation") 
	} 	
	else if "`e(L)'" != "matrix" {
		di as err "loadings e(L) not found"  
		exit 498 
	} 

	tempname loadings labels 
	matrix `loadings' = e(`which'L) 

	if "`factors'" != "" { 
		if "`components'" != "" { 
			if "`components'" != "`factors'" { 
				di as err ///
				"components() and factors() do not agree"  
				exit 498 
			} 
		} 
		local components "`factors'" 
	} 

	if "`components'" == "" { 
		local J = colsof(`loadings')
		local components "1/`J'"
	}

	local I = rowsof(`loadings') 
	local rows : rownames `loadings'
	local cols : colnames `loadings'

	qui foreach j of num `components' { 
		tempvar y
		if "`number'" != "" { 
			tempvar n 
			gen `n' = `j' 
			compress `n' 
			local N `N' `n' 
		} 
		gen `y' = . 
		label var `y' "`: word `j' of `cols''" 
		forval i = 1/`I' { 
			replace `y' = `loadings'[`i', `j'] in `i' 
		} 
		local Y `Y' `y' 
	} 

	quietly { 
		tempvar x 
		gen `x' = _n in 1/`I'  
		compress `x' 
	} 

	forval i = 1/`I' { 
		label def `labels' `i' "`: word `i' of `rows''", modify 
	} 
	label val `x' `labels' 

	if "`number'" != "" { 
		local NUMBER "ms(i ..) mla(`N') mlabpos(0 ..) legend(off)" 
	} 

	twoway connect `Y' `x' in 1/`I', ///
	ytitle("loadings") xtitle(" ") xla(1/`I', valuelabels) ///
	clw(thin ..) `NUMBER' `note' `options' 
end 
