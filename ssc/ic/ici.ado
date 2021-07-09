*! version 0.1.2  2017-04-20
*! Bug when using stcox and icp fixed
* version 0.1.0  02dec2014
version 11


program define addition_mean_variance, rclass
	args est covar
	
	tempname est1 var est2 deriv_reri deriv_ap deriv_ln_s var2
	
	matrix `est1' = `est'
	matrix `var' = `covar'
	
	forvalues row = 1/3 {
		matrix `est'[`row', 1] = exp(`est1'[`row', 1]) 
	}
	
	matrix `est2' = `est'[3,1] + 1 - `est'[2,1] - `est'[1,1]
	matrix `est2' = `est2' \ (`est'[3,1] + 1 - `est'[2,1] - `est'[1,1]) / `est'[3,1]
	* Actually it is ln(S), not S
	matrix `est2' = `est2' \ ln(`est'[3,1] - 1) - ln(`est'[2,1] + `est'[1,1] - 2)
	matrix rownames `est2' = RERI AP S

	matrix `deriv_reri' = -`est'[1,1] \ -`est'[2,1] \ `est'[3,1]
	matrix `deriv_ap' = -`est'[1,1] / `est'[3,1] 
	matrix `deriv_ap' = `deriv_ap' \ -`est'[2,1] / `est'[3,1]
	matrix `deriv_ap' = `deriv_ap' \ (`est'[1,1] + `est'[2,1] - 1) / `est'[3,1]
	matrix `deriv_ln_s' = -`est'[1,1] / (`est'[1,1] + `est'[2,1] - 2)
	matrix `deriv_ln_s' = `deriv_ln_s' \ -`est'[2,1] / (`est'[1,1] + `est'[2,1] - 2)
	matrix `deriv_ln_s' = `deriv_ln_s' \ `est'[3,1] / (`est'[3,1] - 1)
	matrix `est' = `est1' \ `est2'

	matrix `var2' = `deriv_reri'' * `var' * `deriv_reri'
	matrix `var2' = `var2' \ `deriv_ap'' * `var' * `deriv_ap'
	matrix `var2' = `var2' \ `deriv_ln_s'' * `var' * `deriv_ln_s'
	matrix rownames `var2' = RERI AP S
	matrix `var' = vecdiag(`var')'
	matrix `var' = `var' \ `var2'
	
	return matrix est = `est'
	return matrix var = `var'
end


program define ci_table, rclass
	args est var
	
	tempname ub lb p sd b k

	scalar `k' = invnorm(.975)
	forvalues row = 1/6 {
		scalar `b' = `est'[`row', 1]
		scalar `sd' = sqrt(`var'[`row', 1])
		scalar `p' = 2 * (1 - normal(abs(`b') / `sd'))
		scalar `lb' = `b' - `k' * `sd'
		scalar `ub' = `b' + `k' * `sd'
		
		if inlist(`row', 1 ,2, 3, 6) {
			scalar `lb' = exp( `b' - `k' * `sd')
			scalar `ub' = exp( `b' + `k' * `sd')
			scalar `b' = exp(`b')
		}
	matrix output = nullmat(output) \ (`b', `sd', `p', `lb', `ub')
	}
	matrix colnames output = "Estimates" "SD" "P-value" "Lower bound" "Upper bound"
	matrix rownames output = `:rownames `est''
	return matrix output = output
end


program define ici, rclass
	args est var labels
	
	tempname b v output
	tempname rownbr colnbr
	
	*capture matrix drop output
	if "`labels'" == "" {
		local labels "A_NOT_B B_NOT_A A_AND_B"
	}
	matrix `b' = `est'
	scalar `rownbr' = rowsof(`b')
	scalar `colnbr' = colsof(`b')
	if `rownbr' < `colnbr' {
		matrix `b' = `b''
		scalar `rownbr' = rowsof(`b')
		scalar `colnbr' = colsof(`b')
	}
	if `colnbr' != 1 {
		display as error "First argument is not one row or one column"
	}
	matrix rownames `b' = `labels'
	matrix `v' = `var'
	matrix rownames `v' = `labels'
	matrix colnames `v' = `labels'

	addition_mean_variance "`b'" "`v'"	
	matrix `b' = r(est)
	matrix `v' = r(var)

	ci_table "`b'" "`v'"
	matrix `output' = r(output)
	matrix `output' = `output'[1..6, 1], `output'[1..6, 3..5]
	matlist `output', rowtitle(Summary measures) ///
		cspec(| %27s | %9.4f & %9.4f & %11.4f & %11.4f |) ///
		rspec(--&&-&&-)
	display "{center 80: Interaction exists if RERI != 0 or AP != 0 or S != 1}" 
	return matrix output = `output'
end
