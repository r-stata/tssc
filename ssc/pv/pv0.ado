/*

	This file is used to run commands that have instead of known values for their dependent variable, unknown ones,

	such as plausible values.



	Syntax:

		pv [indepvars] [if] [in] [weight], pv(plausible values) options

	To run this for PISA

		pv [indepvars] [if] [in] [weight], pv(plausible values) cmd("cmd") brr rw(replicate weights) fays(0.5)

	To run this for timss / PIRLS	

		pv [indepvars] [if] [in] [weight], pv(plausible values) cmd("cmd")  jrr jkzone(jackknife zone) jkrep(jackknife rep) timss


	* the timss option calculates the std error a little differently (compare PISA versus timss / PIRLS technical reports)



	This file contains four programs:

		1. pv

		2. _jrr

		3. _brr

		4. _bs_shell



*/



/* 1. pv: like stata's jackknife program it estimates accounting for plausible value dependent variables */

	program define pv0, eclass

		version 9.0

		syntax [varlist(numeric default=none)] [pweight fweight aweight iweight] [if] [in], pv(varlist numeric) [cmd(string) cmdops(string) jkzone(varname numeric) jkrep(varname numeric) jrr brr rw(varlist numeric) fays(real 0) timss pirls pisa bs bsops(string)]

	/* 1. Setup */

		if "`cmd'" == "" {

			local cmd = "reg"

		}

		if "`jrr'" != "" {

			if "`jkzone'" == "" | "`jkrep'" == "" {

				di in re "pv: jkzone and jkrep must be specified with jrr."

				break

			}

		}

		if "`brr'" != "" {

			if "`rw'" == "" & `fays'==0 {

				di in re "pv: replicate weights and fays adjustment must be specified with brr."

				break

			}

		}

		if "`brr'" != "" & "`jrr'" != "" {

			di in re "pv: brr and jrr can not both be specified"

		}

		if "`brr'" != "" & "`bs'" != "" {

			di in re "pv: brr and bs can not both be specified"

		}

		if "`jrr'" != "" & "`bs'" != "" {

			di in re "pv: jrr and bs can not both be specified"

		}

		tempname def

		if "`brr'" == "" & "`jrr'" == "" & "`bs'" == "" {

			local `def' = "default"			

		}

	/* 2. For each plausible value, calculate estimates and VCE */

		tempname pv_ v df obs

		local `pv_' = 0

		foreach `v' in `pv' {

			/* if the command is mean and there is more than one plausible value then use a temp name */

			local `pv_' = ``pv_'' + 1

			if "`cmd'" == "mean" & ``pv_'' > 1 {

				tempname pv_rep pv_old

				tempvar `pv_rep'

				qui gen ``pv_rep'' = ``v'' 

				local `pv_old' = "``v''"

				tempvar `v'

				qui gen ``v'' = ``pv_rep''

				tempname mean_pv

				local `mean_pv' = "``v''"

			}


			if "`brr'" != "" {

				qui _brr ``v'' `varlist'[`weight'`exp'] `if' `in', rw(`rw') fays(`fays') cmd("`cmd'") cmdops("`cmdops'")

			}

			if "`jrr'" != "" {

				qui _jrr ``v'' `varlist' [`weight'`exp'] `if' `in', jkzone(`jkzone') jkrep(`jkrep') cmd("`cmd'") cmdops("`cmdops'")

			}

			if "``def''" != "" {

				qui `cmd' ``v'' `varlist' [`weight'`exp'] `if' `in', `cmdops'

			}

			if "`bs'" != "" {

				qui _bs_shell "bootstrap, force `bsops': `cmd' ``v'' `varlist' [`weight'`exp']"

			}

			tempname b``pv_'' V``pv_'' r2``pv_''

			mat `b``pv_''' = e(b)

			mat `V``pv_''' = e(V)

			local `df' = e(df_r)

			local `obs' = e(N)

			local `r2``pv_''' = e(r2)

			if ``pv_'' > 1 {

				if colsof(`b`=``pv_''-1'') != colsof(`b``pv_''') {

					di in re "Estimates for ``v'' yields different number of coefficients than the previous."

					break

				}

			}

			if "`cmd'" == "mean" & ``pv_'' > 1 {
				
				local `v' = "``pv_old''"

			}			

			di in gr "Estimates for ``v'' complete"

		}

	/* 3. Calculate mean estimate and vce */

		tempname b V r2 i

		mat `b' = `b1' * 0

		mat `V' = `V1' * 0

		local `r2' = 0

		forvalues `i' = 1 (1) ``pv_'' {

			mat `b' = `b' + (1 / ``pv_'') * `b``i'''

			mat `V' = `V' + (1 / ``pv_'') * `V``i'''

			local `r2' = ``r2'' + (1 / ``pv_'') * ``r2``i''''

		}

		if "`pirls'" != "" | "`timss'" != "" {

			mat `V' = `V1'

		}

	/* 4. Calculate Imputation Variance */

		tempname B

		mat `B' = `V' * 0

		if ``pv_'' > 1 {

			forvalues `i' = 1 (1) ``pv_'' {

				mat `B' = `B' + 1 / (``pv_'' - 1) * (`b``i''' - `b')' * (`b``i''' - `b')

			}		
		
		} 

	/* 5. Calculate Total VCE */

		tempname U

		mat `U' = `V' + (1 + 1 / ``pv_'') * `B'

	/* 6. Prepare Output */

		tempname O o o_

		mat `O' = J(1, 5, 0)

		mat `O' = `b'' * `O'

		mat colnames `O' = "Coef" "Std Err" "t" "t Param" "P>|t|"

		local `o_' = rowsof(`O')

		tempname vpdv fm dofpv

		forvalues `o' = 1 (1) ``o_'' {

			scalar `vpdv' = `U'[``o'', ``o'']

			scalar `fm' = (1 + (1/``pv_'')) * `B'[``o'',``o''] / `vpdv'

			scalar `dofpv' = 1 / ((`fm'^2/(``pv_''-1)) + (((1 - `fm')^2)/(``df'')))

			if `dofpv' == . {

				scalar `dofpv' = ``df''

			}

			mat `O'[``o'', 1] = `b'[1, ``o'']

			mat `O'[``o'', 2] = sqrt(`U'[``o'', ``o''])

			mat `O'[``o'', 3] = `b'[1, ``o''] / sqrt(`U'[``o'', ``o''])

			mat `O'[``o'', 4] = `dofpv'

			mat `O'[``o'', 5] = 2*ttail(`dofpv', abs(`O'[``o'', 3]))

		}

	/* 7. Display Output */

		di

		di in gr "Number of observations: " in ye "``obs''"

		di in gr "Average R-Squared: " in ye "``r2''"

		di

		di in gr "Plausible Values: " in ye "`pv'"

		di

		mat list `O', noheader

		if "`cmd'" == "mean" & ``pv_'' > 1 {

			di

			di in gr "Note: " in ye "``mean_pv''" in gr " is the mean of the plausible values."

		}

	/* 8. Post Results */

		marksample touse

		ereturn post `b' `U', esample(`touse')

		ereturn matrix B = `B'

		ereturn scalar df_p = ``df''

		ereturn scalar pv_n = ``pv_''

		eret local cmd "pv"

		

	end

	
/* 2. _jrr: This program is for running programs with e(b) as output with Jackknife Repeated Replicates. */


	program define _jrr, eclass

		syntax [varlist(numeric default=none)] [pweight fweight aweight iweight] [if] [in], [cmd(string) cmdops(string)] jkzone(varname numeric) jkrep(varname numeric)

		if "`exp'" == "" {

			di in re "JRR: weights required."

			break

		}

		if "`cmd'" == "" {

			local cmd = "reg"

		}

	/* 1. Caculate maximum jackknife zone */

		qui sum `jkzone'

		tempname maxzone

		local `maxzone' = r(max)

	/* 2. Run the command once to get the full sample estimate */

		qui `cmd' `varlist' [`weight' `exp'] `if' `in', `cmdops'

		tempname obs r2 b V

		local `obs' = e(N)

		local `r2' = e(r2)

		mat `b' = e(b)

		mat `V' = `b'' * `b' * 0

	/* 3. Accumulate Jackknife replicated VCE */

		tempname w_ z

		local `w_' = 0

		forvalues `z' = 0 (1) ``maxzone'' {

			qui count if `jkzone' == ``z''

			if r(N) > 0 {

				local `w_' = ``w_'' + 1

				tempvar w

				qui gen `w' `exp' if `jkzone' != ``z''

				qui replace `w' `exp' * `jkrep' * 2 if `jkzone' == ``z''

				qui `cmd' `varlist' [`weight' = `w'] `if' `in', `cmdops'

				mat `V' = `V' + (e(b) - `b')' * (e(b) - `b')

			}

		}

	/* 4. Post Estimates */

		ereturn post `b' `V'

		ereturn scalar N = ``obs''

		ereturn scalar df_r = ``w_''

		ereturn scalar r2 = ``r2''

	end



/* 3. _brr: This program is for running programs with e(b) as output with Balanced Repeated Replicates. */


	program define _brr, eclass

		syntax [varlist(numeric default=none)] [pweight fweight aweight iweight] [if] [in], [cmd(string) cmdops(string)] rw(varlist numeric) fays(real)

		if "`cmd'" == "" {

			local cmd = "reg"

		}

	/* 1. Run the command once to get the full sample estimate */

		qui `cmd' `varlist' [`weight' `exp'] `if' `in', `cmdops'

		tempname obs r2 b V

		local `obs' = e(N)

		local `r2' = e(r2)

		mat `b' = e(b)

		mat `V' = `b'' * `b' * 0



	/* 2. Accumulate BRR VCE */

		tempname w_ w

		local `w_' = 0

		foreach `w' in `rw' {

			local `w_' = ``w_'' + 1

			qui `cmd' `varlist' [`weight' = ``w''] `if' `in', `cmdops'

			mat `V' = `V' + (e(b) - `b')' * (e(b) - `b')

		}

		mat `V' = (1 / (``w_'' * (1 - `fays')^2)) * `V'

	/* 3. Post Estimates */

		ereturn post `b' `V'

		ereturn scalar N = ``obs''

		ereturn scalar df_r = ``w_''

		ereturn scalar r2 = ``r2''

	end

/* 4. _bs_shell - uses reps as the degrees of freedom */

	program define _bs_shell, eclass

		args bs_cmd

		`bs_cmd'

		tempname b V N df_r

		mat `b' = e(b)

		mat `V' = e(V)

		local `N' = e(N)

		local `df_r' = e(N_reps)

		ereturn post `b' `V'

		ereturn scalar N = ``N''

		ereturn scalar df_r = ``df_r''		

	end



 
