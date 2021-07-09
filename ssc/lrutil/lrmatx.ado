capture program drop lrmatx
program define lrmatx, rclass
*! 1.0.0 6 June 2000 Jan Brogger
	version 6.0
	tempname or
	tempname beta
	tempname stderr
	tempname cov
	tempname wald
	tempname pwald
	tempname ci
	tempname ci1
	tempname ci2
	tempname modinfo
	tempname all

	if index("logistic logit svylogit","`e(cmd'") == 0 {
		di in red "Command not supported: `e(cmd)'"
		error 999
	}
	

	matrix `beta' = e(b)'
	/* drop constant term */
	local nocons = rowsof(`beta')-1
	matrix `beta' = `beta'[1..`nocons',1]
	matrix colnames `beta'=Beta
	
	matrix `or' = `beta'
	matrix colnames `or'="OR"

	local i = 1
	while `i' <= rowsof(`or') {
		local j = 1
		while `j' <= colsof(`or') {
			matrix `or'[`i',`j'] = exp(`or'[`i',`j'])
			local j=`j'+1
		}
		local i=`i'+1
	}

	/* get std. errors */

	matrix `cov' = e(V)
	matrix `stderr' = vecdiag(`cov')'
	matrix colnames `stderr'="SE"

	local i = 1
	while `i' <= rowsof(`stderr') {
		local j = 1
		while `j' <= colsof(`stderr') {
			matrix `stderr'[`i',`j'] = sqrt(`stderr'[`i',`j'])
			local j=`j'+1
		}
		local i=`i'+1
	}

	/* get the wald statistics */

	matrix `wald'=`beta'
	matrix colnames `wald'="Wald"

	local i = 1
	while `i' <= rowsof(`beta') {
		local j = 1
		while `j' <= colsof(`beta') {
			matrix `wald'[`i',`j'] = `beta'[`i',`j'] / `stderr'[`i',`j']
			local j=`j'+1
		}
		local i=`i'+1
	}

	/* compute p-values for Wald */

	matrix `pwald' = `wald'
	matrix colnames `pwald'="p"

	local i = 1
	while `i' <= rowsof(`wald') {
		local j = 1
		while `j' <= colsof(`wald') {
			matrix `pwald'[`i',`j'] = (1-normprob(abs(`wald'[`i',`j'])))*2
			local j=`j'+1
		}
		local i=`i'+1
	}

	/* compute the confidence intervals */

	matrix `ci1' = `beta'
	matrix `ci2' = `beta'
	local i = 1
	while `i' <= rowsof(`ci1') {
		local j = 1
		while `j' <= colsof(`ci1') {
			matrix `ci1'[`i',`j'] = `beta'[`i',`j']-(`stderr'[`i',`j']*invnorm(0.975))
			matrix `ci2'[`i',`j'] = `beta'[`i',`j']+(`stderr'[`i',`j']*invnorm(0.975))
			local j=`j'+1
		}
		local i=`i'+1
	}

	matrix `ci' = `ci1',`ci2'
	matrix colnames `ci'="CI1" "CI2"

	local i = 1
	while `i' <= rowsof(`ci') {
		local j = 1
		while `j' <= colsof(`ci') {
			matrix `ci'[`i',`j'] = exp(`ci'[`i',`j'])
			local j=`j'+1
		}
		local i=`i'+1
	}

	matrix `all' = `or',`ci',`pwald'

	/* get some model statistics */

	if "`e(cmd)'"=="logistic" | "`e(cmd)'"=="logit" {
		local infos "N ll_0 ll df_m chi2 r2_p"
	}
	if "`e(cmd)'"=="svylogit" {
		local infos "N_pop N N_strata N_psu df_r df_m F"
	}

	local n : word count `infos'
	matrix `modinfo' = J(`n',1,0)

	tokenize "`infos'"
	local i 1
	while "`1'" ~= "" {
		matrix `modinfo'[`i',1] = `e(`1')'
		matname `modinfo' `1', row(`i') explicit
		macro shift 1
		local i = `i'+1
	}
	*local i = `i' - 1
	*matrix `modinfo' = `modinfo'[1..`i',1]

	/* return it all */

	return matrix or `or'
	return matrix ci `ci'
	return matrix beta `beta'
	return matrix stderr `stderr'
	return matrix pwald `pwald'
	return matrix lrmatx `all'
	return matrix modinfo `modinfo'
end
