/*

	this is a revised version

	the original is included as pv0

	the new pv syntax can either be the original one or

		pv3, options: cmd		where @pv is where the plausible values from pv should go, !@pv for pv1, etc

						where @w is where the replicate weights would go for rw, @1w for rw1, etc

		- or -

		pv3, options: cmd1 ||| cmd2 ||| cmd3 ...


	using mata do deal with long command names based on Dan Blanchette's lstrfun.ado mata code



*/

/* 1. pv: estimation with plausible values */

	program define pv, eclass

		version 11

		di

	/* 1. Setup */

		/* 1.1 check which version of the syntax */

			mata: mstrpos(`"`0'"', "@pv")

			if `mstrpos' == 0 {

				pv0 `0'

				exit 0

			}

			mata: mstrpos(`"`0'"', ":")

			if `mstrpos' == 0 {

				di in re "invalid syntax:  ':' missing"

				exit 100

			}

			mata: mstrpos(`"`0'"', "@pv1")

			local checkat = `mstrpos'

			mata: mstrpos(`"`0'"', "@pv2")

			if `mstrpos' != 0 | `checkat' != 0 {

				di in re "Location of plausible values should be specified as @1pv or @2pv rather than @pv1 or @pv2.  See examples in help pv"

				exit 100

			}

		/* 1.2 parse the command line */

			_pvparse `0'

		/* 1.3 load options and commands as macros */

			tempname o cmds

			foreach `o' in pv pv1 pv2 mdd mdd1 cmd cmdops jkzone jkrep jrr brr rw fays timss pirls pisa bs bsops jackknife jk rclass matrix weight jrrt2 {

				local ``o'' `r(``o'')'

				if "```o'''" == "." local ``o'' = ""

			}

			local `cmds' = r(cmds)

			if "`brr'" != "" | "`jrr'" != "" | "`jackknife'" != "" {

				di in gr "command(s) run for each plausible value and replicate weight:"

			}

			if "`brr'" == "" & "`jrr'" == "" & "`jackknife'" == "" {

				di in gr "command(s) run for each plausible value:"

			}

			di in gr

			forvalues `o' = 1 (1) ``cmds'' {

				local cmd``o'' `r(cmd``o'')'

				di in gr `"     `cmd``o'''"'

			}

			di in gr

			local commands `"`r(commands)'"'

			local options `"`r(options)'"'

		/* 1.4 check for inconsistancies */

			if "`jrr'" != "" {

				if "`rw'" == "" & ("`jkzone'" == "" | "`jkrep'" == "") {

					di in re "pv: jkzone and jkrep must be specified with jrr if replicate weights are not specified."

					break

				}

			}

			if "`brr'" != "" {

				if "`rw'" == "" & `fays'==0 {

					di in re "pv: replicate weights and fays adjustment must be specified with brr."

					exit 100

				}

			}

			if "`jrr'" != "" & "`jkzone'" == "" & "`jkrep'" == "" {

				if "`rw'" == ""  {

					di in re "pv: rw needs to be specified with jrr or jkzone and jkrep need to specified"

					exit 100
	
				}

			}

			if "`brr'" != "" & "`jrr'" != "" {

				di in re "pv: brr and jrr can not both be specified"

				exit 100

			}

			if "`brr'" != "" & "`bs'" != "" {

				di in re "pv: brr and bs can not both be specified"

				exit 100

			}

			if "`jrr'" != "" & "`bs'" != "" {

				di in re "pv: jrr and bs can not both be specified"

				exit 100

			}

			if "`mdd'" != "" & "`mdd1'" != "" {

				di in re "pv: mdd and mdd1 can not both be specified"

				exit 100

			}

			if "`jackknife'" != "" & ("`jrr'" != "" | "`brr'" != "" | "`bs'" != "") {

				di in re "pv: jrr, brr and bs can not be specified with jackknife"

				exit 100

			}		

			tempname def

			if "`brr'" == "" & "`jrr'" == "" & "`jrrt2'" == "" {

				local `def' = "default"			

			}

	/* 2. For each plausible value, calculate estimates and VCE */

		/* 2.1 setup plauible values */

			/* 2.1.1 count the number of plausible values */

				tempname pv_ pv0_ pv1_ pv2_ v v0 v1 v2 df obs i j k

				local `pv0_' = wordcount("`pv'")

				local `pv1_' = wordcount("`pv1'")

				local `pv2_' = wordcount("`pv2'")

				if ``pv1_'' == 0 local `pv1_' = 1

				if ``pv2_'' == 0 local `pv2_' = 1

			/* 2.1.2 check for valid specification of plausible values */

				if "`mdd'" != "" {

					if !((``pv0_'' == ``pv1_''  & ``pv1_'' == ``pv2_'') | ``pv2_'' == 1) | !(``pv0_'' == ``pv1_'')  {

						di "``pv0_'' == ``pv1_''  & ``pv1_'' == ``pv2_'' & ``pv2_'' > 1"

						di in re "If mdd option is specified, the number of plausible values needs to be the same for each specified group."

						di in gr "pv, ``pv0_'' variables: `pv'"

						di in gr "pv1: ``pv1_'' variables: `pv1'"

						local `pv2_' = wordcount("`pv2'")

						if "`pv2'" != "" di in gr "pv2: ``pv2_'' variables: `pv2'"

						exit 100

					}

					local `pv1_' = 1
	
					local `pv2_' = 1

				}

				if "`mdd1'" != "" {

					if !(``pv1_'' == ``pv2_'') {

						di in re "pv1 and pv2 need to have the same number of variables if mdd option is specified."

						di in gr "pv1: ``pv1_'' variables: `pv1'"

						local `pv2_' = wordcount("`pv2'")

						di in gr "pv2: ``pv2_'' variables: `pv2'"

						exit 100

					}

					local `pv2_' = 1

				}

		/* 2.2 for each combination of plausible values */

			local `pv_' = 0

			forvalues `i' = 1 (1) ``pv0_'' {

				forvalues `j' = 1 (1) ``pv1_'' {

					forvalues `k' = 1 (1) ``pv2_'' {

					/* 2.2.1 define plausible values */

						if "`mdd'" == "" & "`mdd1'" == "" {

							local `v0' = word("`pv'", ``i'')

							local `v1' = word("`pv1'", ``j'')

							local `v2' = word("`pv2'", ``k'')

						}

						if "`mdd'" != "" {
	
							local `v0' = word("`pv'", ``i'')

							local `v1' = word("`pv1'", ``i'')

							local `v2' = word("`pv2'", ``i'')

						}

						if "`mdd1'" != "" {

							local `v0' = word("`pv'", ``i'')

							local `v1' = word("`pv1'", ``j'')

							local `v2' = word("`pv2'", ``j'')

						}

					/* 2.2.2 replace @pv with pv's */

						tempname cmd_all cmd_n

						mata: msubinstr(`"`commands'"', "@pv", "``v0''", .)

						local `cmd_all' `"`msubinstr'"'

						mata: msubinstr(`"``cmd_all''"', "@1pv", "``v1''", .)

						local `cmd_all' `"`msubinstr'"'

						mata: msubinstr(`"``cmd_all''"', "@2pv", "``v2''", .)

						local `cmd_all' `"`msubinstr'"'

						forvalues `cmd_n' = 1 (1) ``cmds'' {

							tempname cmd_``cmd_n''

							mata: msubinstr(`"`cmd``cmd_n'''"', "@pv", "``v0''", .)

							local `cmd_``cmd_n''' `"`msubinstr'"'

							mata: msubinstr(`"``cmd_``cmd_n''''"', "@1pv", "``v1''", .)

							local `cmd_``cmd_n''' `"`msubinstr'"'

							mata: msubinstr(`"``cmd_``cmd_n''''"', "@2pv", "``v2''", .)

							local `cmd_``cmd_n''' `"`msubinstr'"'							
						}

					/* 2.2.3 calculate statistic */

						local `pv_' = ``pv_'' + 1

						if "`brr'" != "" | ("`jrr'" != "" & "`rw'" != "") {

							qui _brr `options': ``cmd_all''

						}

						if "`jrr'" != "" & "`rw'" == "" {

							// if "`jrrt2'" == "" {

								qui _jrr  `options': ``cmd_all''

							// }

						}

						if "`jrrt2'" != "" & "`rw'" == "" {

							// else {

								qui _jrrt2  `options': ``cmd_all''

							// }

						}

						if "``def''" != "" {

							forvalues `cmd_n' = 1 (1) ``cmds'' {

								qui ``cmd_``cmd_n''''

							}

						}

					/* 2.2.4 save results */

						tempname b``pv_'' V``pv_'' r2``pv_'' e_b e_V

						local `e_b' = "e(b)"

						local `e_V' = "e(V)"

						local `df' = e(df_r)
	
						if "`rclass'" != "" {

							local `e_b' = "r(b)"

							local `e_V' = "r(V)"

							local `df' = "r(df_r)"
							
						}

						mat `b``pv_''' = ``e_b''

						mat `V``pv_''' = ``e_V''

						
						local `obs' = e(N)

						local `r2``pv_''' = e(r2)

						if ``pv_'' > 1 {

							if colsof(`b`=``pv_''-1'') != colsof(`b``pv_''') {

								di in re "Estimates for ``v'' yields different number of coefficients than the previous."

								exit 100

							}

						}

						di in gr "Estimates for ``v0'' ``v1'' ``v2'' complete"

					} // end of k

				} // end of j

			} // end of i

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

		// rename plausible values to the macro //

		tempname names pv_n pv1_n pv2_n

		local `names' = ""

		forvalues `i' = 1 (1) `=rowsof(`O')' {

			mata: o_n = st_matrixrowstripe("`O'")

			mata: st_local("n", o_n[``i'',2])

			local `names' "``names'' `n'"

		}

		local `pv_n' = word("`pv'", wordcount("`pv'"))

		local `pv1_n' = word("`pv1'", wordcount("`pv1'"))

		local `pv2_n' = word("`pv2'", wordcount("`pv2'"))

		if ``pv_n'' > 1 {

			// local `names' = subinstr("``names''", "``pv_n''", "pv", 1)

			mata: msubinstr(`"``names''"', "``pv_n''", "pv", 1)

			local `names' `"`msubinstr'"'

			capture confirm variable pv

			if _rc != 0 qui gen pv = .
			
		}

		if "`pv1'" != "" {

			// local `names' = subinstr("``names''", "``pv1_n''", "pv1", 1)

			mata: msubinstr(`"``names''"', "``pv1_n''", "pv1", 1)

			local `names' `"`msubinstr'"'

			capture confirm variable pv1

			if _rc != 0 qui gen pv1 = .

		}

		if "`pv2'" != "" {

			// local `names' = subinstr("``names''", "``pv2_n''", "pv2", 1)

			mata: msubinstr(`"``names''"', "``pv2_n''", "pv2", 1)

			local `names' `"`msubinstr'"'

			capture confirm variable pv2

			if _rc != 0 qui gen pv2 = .

		}

		matrix rownames `O' = ``names'' 

		matrix colnames `b' = ``names''

		matrix colnames `U' = ``names''

		matrix rownames `U' = ``names''

		matrix colnames `U' = ``names''

		matrix rownames `U' = ``names''

		di

		di in gr "Number of observations: " in ye "``obs''"

		di in gr "Average R-Squared: " in ye "``r2''"

		// di

		// di in gr "Plausible Values: " in ye "`pv'"

		di

		mat list `O', noheader

	/* 8. Post Results */

		// marksample touse - genertes an error, not sure how to fix it

		ereturn post `b' `U' // , esample(`touse')

		ereturn matrix B = `B'

		ereturn scalar df_p = ``df''

		ereturn scalar pv_n = ``pv_''

		ereturn scalar N = ``obs''

		ereturn scalar r2 = ``r2''

		ereturn local cmd "pv"

	end



// =================================================================================================================================================================

/* 2. _brr: This program is for running programs with e(b) as output with Balanced Repeated Replicates. */

	program define _brr, eclass

	/* 0. setup */

		/* 0.1 parse the command line */

			qui _pvparse `0'

		/* 0.2 load options and commands as macros */

			tempname o cmds

			foreach `o' in pv pv1 pv2 mdd mdd1 cmd cmdops jkzone jkrep jrr brr rw fays timss pirls pisa bs bsops jackknife jk rclass matrix weight {

				local ``o'' `r(``o'')'

				if "```o'''" == "." local ``o'' = ""

			}

			local `cmds' = r(cmds)

			forvalues `o' = 1 (1) ``cmds'' {

				local cmd``o'' `"`r(cmd``o'')'"'

			}

			local commands `"`r(commands)'"'

			local optsions `"`r(options)'"'

		/* 0.3 check for errors in option specification */

			if "`weight'" == "" | "`rw'" == "" {

				di in re "weight and rw options must be specified with brr.  See --help pv-- for examples."

				exit 100

			}

			if strpos("`0'", "@w") == 0 {

				di in re "@w required with brr and jrr. See --help pv-- for examples."

				exit 100

			}

	/* 1. Run the command once to get the full sample estimate */

		/* 1.1 replace @rw with weight */

			tempname cmd_n

			forvalues `cmd_n' = 1 (1) ``cmds'' {

				tempname cmd_``cmd_n''

				// local `cmd_``cmd_n''' = subinstr("`cmd``cmd_n'''", "@w", "`weight'", .)

				mata: msubinstr(`"`cmd``cmd_n'''"', "@w", "`weight'", .)

				local `cmd_``cmd_n''' `"`msubinstr'"'				

				// local `cmd_``cmd_n''' = subinstr("``cmd_``cmd_n''''", "@1w", "``weight1''", .)

				mata: msubinstr(`"``cmd_``cmd_n''''"', "@1w", "``weight1''", .)

				local `cmd_``cmd_n''' `"`msubinstr'"'				
							
			}

		/* 1.2 do the command */

			forvalues `cmd_n' = 1 (1) ``cmds'' {

				qui ``cmd_``cmd_n''''

			}		

		/* 1.3 record data */

			tempname obs r2 b V

			local `obs' = e(N)

			local `r2' = e(r2)

			tempname e_b

			local `e_b' = "e(b)"

			if "`rclass'" != "" {

				local `e_b' = "r(b)"
						
			}

			if "`matrix'" != "" {

				local `e_b' = "`matrix'"
			}

			mat `b' = ``e_b''

			mat `V' = `b'' * `b' * 0

	/* 2. Accumulate BRR VCE */

		/* 2.1 define rw macros */

			tempname rw_

			local `rw_' = 0

			foreach `o' of varlist `rw' {

				local `rw_' = ``rw_'' + 1

				tempname rw``rw_''

				local `rw``rw_''' = "``o''"

			}

		/* 2.2 loop for each replicate weight */

			tempname w_ w

			local `w_' = 0

			tempname v0 v1

			forvalues `w_' = 1 (1) ``rw_'' {

			/* 2.2.1 replace @rw with rw */

				local `v0' = "``rw``w_''''"

				if "``rw1''" != "" {

					// not active yet

				}

				tempname cmd_all cmd_n

				forvalues `cmd_n' = 1 (1) ``cmds'' {

					tempname cmd_``cmd_n''

					// local `cmd_``cmd_n''' = subinstr("`cmd``cmd_n'''", "@w", "``v0''", .)

					mata: msubinstr(`"`cmd``cmd_n'''"', "@w", "``v0''", .)

					local `cmd_``cmd_n''' `"`msubinstr'"'

					// local `cmd_``cmd_n''' = subinstr("``cmd_``cmd_n''''", "@1w", "``v1''", .)

					mata: msubinstr(`"``cmd_``cmd_n''''"', "@1w", "``v1''", .)

					local `cmd_``cmd_n''' `"`msubinstr'"'

				}

			/* 2.2.2 run the commands */

				forvalues `cmd_n' = 1 (1) ``cmds'' {

					qui ``cmd_``cmd_n''''

				}		

			/* 2.2.3 record results */

				mat `V' = `V' + (``e_b'' - `b')' * (``e_b'' - `b')

			}

	/* 3. adjust variance */

		/* 3.1 if BRR adjust by fays */

		if "`brr'" != "" {

			mat `V' = (1 / (``rw_'' * (1 - `fays')^2)) * `V'

		}

		/* 3.2 if jackknife per Pokropek and Jakubowski 2013 */

		if `jk' == 1 & "`jrr'" != "" {

			 mat `V' = ((``rw_'' - 1) / (``rw_'')) * `V'

		}

	/* 4. Post Estimates */

		ereturn post `b' `V'

		ereturn scalar N = ``obs''

		ereturn scalar df_r = ``rw_''

		ereturn scalar r2 = ``r2''

	end


// =================================================================================================================================================================

/* 3. _jrr: This program is for running programs with e(b) as output with Jackknife Repeated Replicates. */

	program define _jrr, eclass

	/* 0. setup */

		/* 0.1 parse the command line */

			qui _pvparse `0'

		/* 0.2 load options and commands as macros */

			tempname o cmds

			foreach `o' in pv pv1 pv2 mdd mdd1 cmd cmdops jkzone jkrep jrr brr rw fays timss pirls pisa bs bsops jackknife jk rclass matrix weight {

				local ``o'' `r(``o'')'

				if "```o'''" == "." local ``o'' = ""

			}

			local `cmds' = r(cmds)

			forvalues `o' = 1 (1) ``cmds'' {

				local cmd``o'' `"`r(cmd``o'')'"'

			}

			local commands `"`r(commands)'"'

			local optsions `"`r(options)'"'

		/* 0.3 check for errors in option specification */

			if "`weight'" == "" {

				di in re "weight option must be specified. Type --help pv-- for examples."

				exit 100

			}

			if "`jkzone'" == "" | "`jkrep'" == "" {

				di in re "jkzone and jkrep options must be specified.  Type --help pv-- for examples."

				exit 100				

			}

			if strpos("`0'", "@w") == 0 {

				di in re "@w required with brr and jrr. See --help pv-- for examples."

				exit 100

			}

		/* 0.4 Caculate maximum jackknife zone */

			qui sum `jkzone'

			tempname maxzone

			local `maxzone' = r(max)

	/* 1. Run the command once to get the full sample estimate */

		/* 1.1 replace @w with weight */

			tempname cmd_n

			forvalues `cmd_n' = 1 (1) ``cmds'' {

				tempname cmd_``cmd_n''

				mata: msubinstr(`"`cmd``cmd_n'''"', "@w", "`weight'", .)

				local `cmd_``cmd_n''' `"`msubinstr'"'

				mata: msubinstr(`"``cmd_``cmd_n''''"', "@1w", "``weight1''", .)

				local `cmd_``cmd_n''' `"`msubinstr'"'
							
			}

		/* 1.2 do the command */

			forvalues `cmd_n' = 1 (1) ``cmds'' {

				qui ``cmd_``cmd_n''''

			}		

		/* 1.3 record data */

			tempname obs r2 b V

			local `obs' = e(N)

			local `r2' = e(r2)

			tempname e_b

			local `e_b' = "e(b)"

			if "`rclass'" != "" {

				local `e_b' = "r(b)"
						
			}

			if "`matrix'" != "" {

				local `e_b' = "`matrix'"
			}

			mat `b' = ``e_b''

			mat `V' = `b'' * `b' * 0

	/* 3. Accumulate Jackknife replicated VCE */

		tempname w_ z repsperzone varname

		local `w_' = 0

		forvalues `z' = 0 (1) ``maxzone'' {

			qui count if `jkzone' == ``z''

			if r(N) > 0 {

				local `w_' = ``w_'' + 1

				tempvar w

				qui gen `w' = `weight' if `jkzone' != ``z''

				qui replace `w' = `weight' * `jkrep' * 2 if `jkzone' == ``z''

				local `varname' = "`w'"

			/* 3.1 replace @w with weight */

				tempname cmd_n

				forvalues `cmd_n' = 1 (1) ``cmds'' {

					tempname cmd_``cmd_n''

					// local `cmd_``cmd_n''' = subinstr("`cmd``cmd_n'''", "@w", "``varname''", .)

					mata: msubinstr(`"`cmd``cmd_n'''"', "@w", "``varname''", .)

					local `cmd_``cmd_n''' `"`msubinstr'"'

					// local `cmd_``cmd_n''' = subinstr("``cmd_``cmd_n''''", "@1w", "``weight1''", .)

					mata: msubinstr(`"``cmd_``cmd_n''''"', "@1w", "``weight1''", .)

					local `cmd_``cmd_n''' `"`msubinstr'"'
							
				}

			/* 3.2 do the command */

				forvalues `cmd_n' = 1 (1) ``cmds'' {

					qui ``cmd_``cmd_n''''

				}		

			/* 3.3 record results */

				mat `V' = `V' + (``e_b'' - `b')' * (``e_b'' - `b')

			}

		}

	/* 4. Post Estimates */

		ereturn post `b' `V'

		ereturn scalar N = ``obs''

		ereturn scalar df_r = ``w_''

		ereturn scalar r2 = ``r2''

	end


// =================================================================================================================================================================

/* 4. program for parsing the command */

	program define _pvparse, rclass

		tempname o_ options commands cmds exit i o comsave opssave

		local `o_' = strpos("`0'", ":")

		mata: msubstr(`"`0'"', 1,`=``o_''-1')

		local `options' `"`msubstr'"'

		mata: msubstr(`"`0'"', `=``o_''+1', .)

		local `commands' `"`msubstr'"'

		local `comsave' `"``commands''"'

		local `opssave' `"``options''"'

		local `cmds' = 1

		local `exit' = 0

		while ``exit'' == 0 {

			tempname cmd``cmds''

			mata: mstrpos(`"``commands''"', "|||")

			local `o_' = `mstrpos'

			if ``o_'' > 0 {

				mata: msubstr(`"``commands''"', 1, `=``o_''-1')

				local `cmd``cmds''' `"`msubstr'"'

				mata: msubstr(`"``commands''"', `=``o_''+3', .)

				local `commands' `"`msubstr'"'

				local `cmds' = ``cmds'' + 1

			}

			if ``o_'' == 0 {

				local `cmd``cmds''' `"``commands''"'

				local `exit' = 1

			}

		}

		_pvopsparse ``options''

		foreach `o' in pv pv1 pv2 mdd mdd1 cmd cmdops jkzone jkrep jrr brr rw fays timss pirls pisa bs bsops jackknife jk rclass matrix weight jrrt2 {

			tempname ``o''

			local ```o''' `"`r(``o'')'"'

		}

		return clear

		forvalues `i' = 1 (1) ``cmds'' {

		 	return local cmd``i'' `"``cmd``i''''"'

		}

		return scalar cmds = ``cmds''

		foreach `o' in pv pv1 pv2 mdd mdd1 cmd cmdops jkzone jkrep jrr brr rw fays timss pirls pisa bs bsops jackknife jk rclass matrix weight jrrt2 {

			return local ``o'' `"````o''''"'

		}

		return local commands = `"``comsave''"'

		return local options = `"``opssave''"'

	end

// =================================================================================================================================================================

/* 6. Program for dealing with options */

	program define _pvopsparse, rclass

		syntax [varlist(numeric default=none)] [pweight fweight aweight iweight] [if] [in], [pv(varlist numeric) pv1(varlist numeric) pv2(varlist numeric) mdd mdd1 cmd(string) cmdops(string) jkzone(varname numeric) jkrep(varname numeric) jrr brr rw(varlist numeric) fays(real 0) timss pirls pisa bs bsops(string) jackknife jk(real 0) rclass matrix weight(varname) jrrt2]

		tempname o i

		foreach `o' in pv pv1 pv2 mdd mdd1 cmd cmdops jkzone jkrep jrr brr fays timss pirls pisa bs bsops jackknife jk rclass matrix weight rw jrrt2 {

			return local ``o'' "```o'''"

		}
			
	end


// =================================================================================================================================================================

/* 7. Mata programs for long strings */

	// 

/*

  mata: long__substr("asdf", 1, 2)

  c_local output`"`substr'"'


*/


mata:

void msubstr(string scalar s, real scalar start, real scalar length)
{
	string scalar m_var 

	m_var= substr(s,start,length) 

	st_local("msubstr",m_var) 
}

void msubinstr(string scalar s, string scalar target, string scalar replacement, real scalar count)
{
	string scalar m_var 

	m_var= subinstr(s,target,replacement,count) 

	st_local("msubinstr",m_var) 

}

void mstrpos(string scalar s, string scalar target)
{
	string scalar m_var 

	real scalar nm_var 

	nm_var= strpos(s,target) 

	m_var= strofreal(nm_var) 

	st_local("mstrpos",m_var) 
}

end

// =================================================================================================================================================================

/* 8. _jrrt2: This program is for the TIMSS PIRLS updated jackknife estimation */

	program define _jrrt2, eclass

	/* 0. setup */

		/* 0.1 parse the command line */

			qui _pvparse `0'

		/* 0.2 load options and commands as macros */

			tempname o cmds

			foreach `o' in pv pv1 pv2 mdd mdd1 cmd cmdops jkzone jkrep jrr brr rw fays timss pirls pisa bs bsops jackknife jk rclass matrix weight {

				local ``o'' `r(``o'')'

				if "```o'''" == "." local ``o'' = ""

			}

			local `cmds' = r(cmds)

			forvalues `o' = 1 (1) ``cmds'' {

				local cmd``o'' `"`r(cmd``o'')'"'

			}

			local commands `"`r(commands)'"'

			local optsions `"`r(options)'"'

		/* 0.3 check for errors in option specification */

			if "`weight'" == "" {

				di in re "weight option must be specified. Type --help pv-- for examples."

				exit 100

			}

			if "`jkzone'" == "" | "`jkrep'" == "" {

				di in re "jkzone and jkrep options must be specified.  Type --help pv-- for examples."

				exit 100				

			}

			if strpos("`0'", "@w") == 0 {

				di in re "@w required with brr and jrr. See --help pv-- for examples."

				exit 100

			}

		/* 0.4 Caculate maximum jackknife zone */

			qui sum `jkzone'

			tempname maxzone

			local `maxzone' = r(max)

	/* 1. Run the command once to get the full sample estimate */

		/* 1.1 replace @w with weight */

			tempname cmd_n

			forvalues `cmd_n' = 1 (1) ``cmds'' {

				tempname cmd_``cmd_n''

				mata: msubinstr(`"`cmd``cmd_n'''"', "@w", "`weight'", .)

				local `cmd_``cmd_n''' `"`msubinstr'"'

				mata: msubinstr(`"``cmd_``cmd_n''''"', "@1w", "``weight1''", .)

				local `cmd_``cmd_n''' `"`msubinstr'"'
							
			}

		/* 1.2 do the command */

			forvalues `cmd_n' = 1 (1) ``cmds'' {

				qui ``cmd_``cmd_n''''

			}		

		/* 1.3 record data */

			tempname obs r2 b V V2 V20

			local `obs' = e(N)

			local `r2' = e(r2)

			tempname e_b

			local `e_b' = "e(b)"

			if "`rclass'" != "" {

				local `e_b' = "r(b)"
						
			}

			if "`matrix'" != "" {

				local `e_b' = "`matrix'"
			}

			mat `b' = ``e_b''

			mat `V' = `b'' * `b' * 0

			mat `V20' = `V'

	/* 3. Accumulate Jackknife replicated VCE */

		tempname w_ w2_ z z2 repsperzone varname

		local `w_' = 0

		forvalues `z' = 0 (1) ``maxzone'' {

			qui count if `jkzone' == ``z''

			if r(N) > 0 {

				local `w_' = ``w_'' + 1

				local `w2_' = 0

				mat `V2' = `V20'

				forvalues `z2' = 0 (1) 1 {

					qui count if `jkrep' == ``z2'' & `jkzone' == ``z''

					if r(N) > 0 {

						local ++`w2_'

						tempvar w

						qui gen `w' = `weight' if `jkzone' != ``z''

						qui replace `w' = `weight' *  2 if `jkzone' == ``z'' & `jkrep' == ``z2''

						qui replace `w' = 0 if `jkzone' == ``z'' & `jkrep' == `=1-``z2'''

						local `varname' = "`w'"

					/* 3.1 replace @w with weight */

						tempname cmd_n

						forvalues `cmd_n' = 1 (1) ``cmds'' {

							tempname cmd_``cmd_n''

							// local `cmd_``cmd_n''' = subinstr("`cmd``cmd_n'''", "@w", "``varname''", .)

							mata: msubinstr(`"`cmd``cmd_n'''"', "@w", "``varname''", .)

							local `cmd_``cmd_n''' `"`msubinstr'"'

							// local `cmd_``cmd_n''' = subinstr("``cmd_``cmd_n''''", "@1w", "``weight1''", .)
	
							mata: msubinstr(`"``cmd_``cmd_n''''"', "@1w", "``weight1''", .)

							local `cmd_``cmd_n''' `"`msubinstr'"'
							
						}
	
					/* 3.2 do the command */

						forvalues `cmd_n' = 1 (1) ``cmds'' {

							qui ``cmd_``cmd_n''''

						}		

					/* 3.3 record results */

						mat `V2' = `V2' + (``e_b'' - `b')' * (``e_b'' - `b')

					}

				}

				mat `V' = `V' + `V2' / ``w2_''

			}

		}

	/* 4. Post Estimates */

		ereturn post `b' `V'

		ereturn scalar N = ``obs''

		ereturn scalar df_r = ``w_''

		ereturn scalar r2 = ``r2''

	end


