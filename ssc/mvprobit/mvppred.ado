*! version 1.0.0   15jan2003 Cappellari & Jenkins 
*! predict program to accompany -mvprobit- for multivariate probit estimation


program define mvppred
	version 7.0

	if "`e(cmd)'" != "mvprobit" { 
		di in red  "mvprobit was not the last estimation command"
		exit 301
	}

	syntax anything(name=pref id="variable name prefix") [if] [in] /*
		*/  [, XB STDP PMarg PAll ]

	local nopt = ("`xb'"!="")  + ("`stdp'"!="") + ("`pmarg'"!="") + ("`pall'"!="") 
	if `nopt' > 1 { 
		disp in re "only one of the following options allowed: xb, stdp, pmarg, pall"
		exit 198 
	} 
	local var
	if `nopt'==0 { 
		local xb "xb" 
	}

	set seed `e(seed)'
	capture macro drop S_MLE_z*

	marksample touse, novarlist	/* novarlist because new vars generated */
	qui count if `touse'
	if r(N) < 1 {
		di in red "no observations"
		exit 2000
	}

	if "`xb'" != "" {
		di in gr "(xb will be stored in variables `pref'i, i = 1,...,#eqs)"
		forval i = 1/`e(neqs)' {
			confirm new var `pref'`i'
			_predict `pref'`i' if `touse', xb equation(#`i')
		}

	}

	if "`stdp'" != "" {
		di in gr "(stdp will be stored in variables `pref'i, i = 1,...,#eqs)"
		forval i = 1/`e(neqs)' {
			confirm new var `pref'`i'
			_predict `pref'`i' if `touse', stdp equation(#`i')
		}

	}

	if "`pmarg'" != "" {
		di in gr "(pmarg will be stored in variables `pref'i, i = 1,...,#eqs)"
		forval i = 1/`e(neqs)' {
			confirm new var `pref'`i'
			tempvar xb`i'
			_predict `xb`i'' if `touse', xb equation(#`i')
			quietly gen `pref'`i' = normprob(`xb`i'') if `touse'
		}
	}


	if "`pall'" != "" {
		di in gr "(Pr(all zeros), Pr(all ones) will be stored in variables `pref'0s, `pref'1s)"
		confirm new var `pref'1s
		confirm new var `pref'0s
						/* now derive simulated probabilities */
		tempname A C
		mat `A' = I(`e(neqs)')  
		forval i = 1/`e(neqs)' {
			tempvar xb`i'
			_predict `xb`i'' if `touse', xb equation(#`i')

			local jj = `i'+1
			forval j = `jj'/`e(neqs)' {
				mat `A'[`j',`i'] = (`e(rho`j'`i')')
				mat `A'[`i',`j'] = (`e(rho`j'`i')')
			}	
		}
		mat `C' = cholesky(`A')	
		forval i = 2/`e(neqs)' {
			forval j = 1/`i' {
				tempname c`i'`j'
				scalar `c`i'`j'' = `C'[`i',`j']
			}
		}

		tempname c11 sp10 sp00
		scalar `c11' = 1
		scalar `sp10' = 1
		scalar `sp00' = 1

		tempvar pr0 pr1
		quietly {
			gen `pr0' = 0
			gen `pr1' = 0
			forval d = 1/`e(draws)' {
				forval i = 1/`e(neqs)' {

					tempvar d1`i' d0`i' sp1`i' sp0`i' arg1`i' arg0`i' z

					Draws `z' `touse'
					global S_MLE_z`i'`d' "`z'"
						/* "if `touse'" used below as need to restrict
						    to selected subsample  (cf. ml evaluation 
						    program where no need)
						*/
					gen double `d1`i'' = 0 if `touse'
					gen double `d0`i'' = 0 if `touse'
					gen double `sp1`i'' = 0 if `touse'
					gen double `sp0`i'' = 0 if `touse'
					gen double `arg1`i'' = 0 if `touse'
					gen double `arg0`i'' = 0 if `touse'
					replace `arg1`i'' = `xb`i'' if `touse'
					replace `arg0`i'' = `xb`i'' if `touse'
					if `i' > 1 {
						local jjj = `i'-1
						forval j = `jjj'(-1)1 {
							replace `arg1`i'' = `arg1`i''-`d1`j''*`c`i'`j'' if `touse'
							replace `arg0`i'' = `arg0`i''-`d0`j''*`c`i'`j'' if `touse'
						}
					}
					replace `d1`i'' = invnorm(${S_MLE_z`i'`d'}*normprob((`arg1`i'')/`c`i'`i'')) if `touse'
					replace `d0`i'' = -invnorm(${S_MLE_z`i'`d'}*normprob((-`arg0`i'')/`c`i'`i'')) if `touse'
					local j = `i'-1
					replace `sp1`i'' = normprob((`arg1`i'')/`c`i'`i'')*`sp1`j'' if `touse'
					replace `sp0`i'' = normprob((-`arg0`i'')/`c`i'`i'')*`sp0`j'' if `touse'
				}
				replace `pr1' = `pr1' + `sp1`e(neqs)''/`e(draws)' if `touse'
				replace `pr0' = `pr0' + `sp0`e(neqs)''/`e(draws)' if `touse'
			}
				gen `pref'1s = `pr1' if `touse'
				gen `pref'0s = `pr0' if `touse'
		}

	}

	capture macro drop S_MLE_z*
end


program define Draws
	quietly gen `1' = uniform() if `2'
end




