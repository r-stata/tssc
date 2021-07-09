*! version 3.0  05sep2002 NJGW
* version 1.2.1  16Nov2001
program define svrcorr, byable(recall) rclass

	version 7

	syntax [varlist(min=2)] [if] [in] [ ,			/*
				*/  pw 							/*   pairwise
				*/ Obs CI SIG Print(real -1) STar(real -1) 	/*   display options
				*/ SIDak Bonferroni Level(int $S_level) ]


*ADMINISTRATION FOR WEIGHTS, BRRWEIGHTS, FAY ADJUSTMENT, ETC...

	svr_get
	local exp `r(pw)'
	local mainweight `exp'

	local svrweight `r(rw)'
	local svrwspec "`svrweight'"
	local svrw `svrweight'
	local nsvrw `r(n_rw)'

	local fay `r(fay)'
	local dof `r(dof)'

	local method `r(meth)'
	local psusizes `r(psun)'


	tempvar touse

	if "`pw'"=="pw" {
		marksample touse, novarlist				/* pairwise calculations */
	}
	else {
		marksample touse
		qui count if `touse'
		local N=`r(N)'
	}

	tokenize `varlist'

	local i 1
	while "``i''" != "" {
		capture confirm str var ``i''
		if _rc==0 {
			di in gr "(``i'' ignored because string variable)"
			local `i' " "
		}
		local i = `i' + 1
	}
	local varlist `*'
	tokenize `varlist'
	local nvar : word count `varlist'
	if `nvar' < 2 { error 102 }

	local ci_tval = invttail(`dof',(100-`level')/200)	/* crit t-value for conf interval */

	local weight "[aw=`exp']"

	local adj 1
	if "`bonferroni'"!="" | "`sidak'"!="" {
		if "`bonferroni'"!="" & "`sidak'"!="" { error 198 }
		local nrho=(`nvar'*(`nvar'-1))/2
		if "`bonferroni'"!="" { local adj `nrho' }
	}


	if (`star'>=1) {
		local star = `star'/100
		if `star'>=1 {
			di in red "star() out of range"
			exit 198
		}
	}
	if (`print'>=1) {
		local print = `print'/100
		if `print'>=1 {
			di in red "print() out of range"
			exit 198
		}

	}


	di
	di "{txt}Correlation estimates with replication-based (`method') significance calculations"
	di
	di "{txt}Analysis weight:      `mainweight'"
	local ri : set linesize
	local ri=`ri'-78
	di "{txt}{p 0 22 `ri'}Replicate weights:{bind:    }`svrwspec'{p_end}"


	di "{txt}Number of replicates: `nsvrw'"
	di "{txt}Degrees of freedom:   `dof'"

	if "`method'"=="brr" {
		di "{txt}k (Fay's method):     " %4.3f `fay'
	}


	tempname pvalue lastr lastn lastp

	local j0 1
	while (`j0'<=`nvar') {
		di
		local j1=min(`j0'+6,`nvar')
		local j `j0'
		di in smcl in gr _skip(13) "{c |}" _c
		while (`j'<=`j1') {
			di in gr %9s abbrev("``j''",8) _c
			local j=`j'+1
		}
		local l=9*(`j1'-`j0'+1)
		di in smcl in gr _n "{hline 13}{c +}{hline `l'}"

		local i `j0'
		while `i'<=`nvar' {
			di in smcl in gr %12s abbrev("``i''",12) " {c |} " _c
			local j `j0'
			while (`j'<=min(`j1',`i')) {
				cap corr ``i'' ``j'' if `touse' `weight'
				if _rc == 2000 {
					local c`j' = .
					local p`j' = .
					local n`j'=r(N)
				}
				else {
					local n`j'=r(N)
					local c`j'=r(rho)
					GetP "``i''" "``j''" "`c`j''" "`touse'" "`svrw'" "`nsvrw'" "`fay'" "`dof'" "`pvalue'"  "`method'" "`psusizes'"
					local p`j'=min(`adj'*`pvalue',1)
					if `i'!=`j' {
						scalar `lastr' = `c`j''
						scalar `lastn' = `n`j''
						scalar `lastp' = `p`j''
					}
				}


				if "`sidak'"!="" {
					local p`j'=min(1,1-(1-`p`j'')^`nrho')
				}
				local j=`j'+1
			}
			local j `j0'
			while (`j'<=min(`j1',`i')) {
				if `p`j''<=`star' & `i'!=`j' {
					local ast "*"
				}
				else local ast " "
				if `p`j''<=`print' | `print'==-1 |`i'==`j' {
					di "{res} " %7.4f `c`j'' "`ast'" _c
				}
				else 	di _skip(9) _c
				local j=`j'+1
			}
			di
			if "`sig'"!="" {
				di in smcl in gr _skip(13) "{c |}" _c
				local j `j0'
				while (`j'<=min(`j1',`i'-1)) {
					if `p`j''<=`print' | `print'==-1 {
						di "{res}  " %7.4f `p`j'' _c
					}
					else	di _skip(9) _c
					local j=`j'+1
				}
				di
			}
			if "`obs'"!="" {
				di in smcl in gr _skip(13) "{c |}" _c
				local j `j0'
				while (`j'<=min(`j1',`i')) {
					if `p`j''<=`print' | `print'==-1 /*
					*/ |`i'==`j' {
						di "{res}  " %7.0g `n`j'' _c
					}
					else	di _skip(9) _c
					local j=`j'+1
				}
				di
			}
			if "`obs'"!="" | "`sig'"!="" {
				di in smcl in gr _skip(13) "{c |}"
			}
			local i=`i'+1
		}
		local j0=`j0'+7
	}

	return scalar N   = `lastn'
	return scalar p   = `lastp'
	return scalar rho = `lastr'
end

program define GetP
	args i j corr touse svrw nsvrw fay dof pval method psusz

	tempname r_rep z_rep se z_corr t_level

	scalar `z_corr'= 0.5*ln((1+(`corr'))/(1-(`corr')))			/* Fisher Z transformation */

	scalar `se'=0
	local rfac 1
	forval rep=1/`nsvrw' {
		local curw : word `rep' of `svrw'
		qui corr `i' `j' [aw=`curw'] if `touse'				/* repeated estimates */
		scalar `z_rep'= 0.5*ln((1+(`r(rho)'))/(1-(`r(rho)')))		/* Fisher Z transformation */
		if "`method'"=="jkn" {
			local rfac : word `rep' of `psusz'
			local rfac = (`rfac'-1)/(`rfac')
		}
		scalar `se' = `se' + (`rfac')* ((`z_rep')-(`z_corr'))^2
	}

	tempname scalefac
	if "`method'"=="brr" {
		scalar `scalefac' = 1 / (`nsvrw' * (1-`fay')^2 )
	}
	else if "`method'"=="jk1" {
		scalar `scalefac' = (`nsvrw'-1)/`nsvrw'
	}
	else if "`method'"=="jk2" {
		scalar `scalefac' = 1
	}
	else if "`method'"=="jkn" {
		scalar `scalefac' = 1
	}

	scalar `se' = sqrt((`se') * `scalefac')

	scalar `t_level' = abs((`z_corr') / (`se'))			/* estimate / std error */
	scalar `pval' = ttail(`dof',`t_level')*2

end

