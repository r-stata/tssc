*! version 3.0.2  11sep2002 NJGW
* svrest version 1.0  Nicholas Winter  16aug2002
* 3.0.1 added diparm() option
* 3.0.2 fixed display of rep weights bug

program define svrest, eclass
	version 7

	if replay() {
		Display `0'
	}
	else {

		syntax anything(id="command and expressions") [if] [in] , [  /*
				*/ Matrices(string) Level(passthru) NOISILY or LIststats diparm(passthru) ]

	* DEAL WITH SVR-SURVEY OPTIONS

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


	* PARSE THE COMMAND AND EXPRESSION LIST

		local version : di "version " _caller() ":"
		gettoken command anything : anything
		gettoken explist anything : anything
		if `"`anything'"'!= "" {
			di as error `"must enclose command in quotes and list of statistics in quotes"'
			error 198
		}


		* make sure user didn't specify weight, split command at comma
		local 0 `command'
		cap syntax [anything] [if] [in] [aw fw pw iw] , *
		if "`exp'"!="" {
			di as err "do not specify weight in command; specify with {help svrset}"
			exit 198
		}
		local cmd1 `anything' `if' `in'
		local cmd2 `options'


	*RUN THE FULL-SAMPLE COMMAND TO GET overall b-hat (and to make sure it runs w/o error!)

		tempname totb repb accumV r2 moreb

		capture `version' `cmd1' [aw=`mainweight'] , `cmd2'
		if _rc {
			if _rc==1 { error 1 }
			di in red `"error when command executed on original dataset"'
			error _rc
		}

	/* Check list of statistics. */

	*FIRST, any MATRICES

		tempname x y
		local nmatcol 0
		if "`matrices'"!="" {
			local nmat : word count `matrices'
			forval i=1/`nmat' {
				local curmat : word `i' of `matrices'
				capture matrix `x' = `curmat'
				if _rc {
					di as error "error with matrix: `curmat'"
					exit 198
				}
				local ncol = colsof(matrix(`x'))
				local nmatcol = `nmatcol'+`ncol'

				local cn : coleq `x'				/* Give equation name if none, so each */
				local check : di _dup(`ncol') "_ "		/* matrix is displayed separately */
				if "`cn'"==trim("`check'") {
					mat coleq `x' = mat`i'
				}

				mat `totb' = nullmat(`totb'),`x'
			}
			local vl : colnames `totb'
			local labs : colnames `totb'
			local labseq : coleq `totb'
		}

	*NOW, Statistics

		local nstat : word count `explist'
		local totstat = `nstat' + `nmatcol'

		if `nstat'>0 {
			mat `moreb'=J(1,`nstat',0)
		}
		mat `totb'=nullmat(`totb'),nullmat(`moreb')
		mat `accumV'=J(`totstat',`totstat',0)


		tokenize `"`explist'"'

		if trim(`"`cmd2'"')!="" { 
			local c "," 
		}

		local thecommand `"`cmd1'`c' `cmd2'"'
		
		local i 1
		while `"``i''"'!=`""' {
			local vl     `"`vl' stat`i'"'			/* change names to make clearer! */
			local labs  `"`labs' ``i''"'
			local labseq `"`labseq' stats"'
			local stats  `"`stats' (``i'')"'

			Dollar ``i''
			capture scalar `x' = `s(mac)'
			if _rc {
				sret clear
				di in red `"error in statistic: ``i''"'
				exit 198
			}
			else {
				local pos = `i'+`nmatcol'
				mat `totb'[1,`pos']=`x'
			}
			local i = `i' + 1
		}
		sret clear

										* CREATE SHORTER VERSIONS, OR LIST KEY, OR SOMETHING!
		mat colnames `totb'=`vl'
		mat coleq    `totb'=`labseq'
		mat colnames `accumV'=`vl'
		mat coleq    `accumV'=`labseq'

		mat rownames `accumV'=`vl'
		mat roweq    `accumV'=`labseq'

	*DO REPLICATES
		local rfac 1
		forval rep = 1/`nsvrw' {
			local curw : word `rep' of `svrw'
			local command `cmd1' [aw=`curw'] , `cmd2'

			if "`noisily'"!="" {
				di as inp `". `command'"'
			}
			capture `noisily' `version' `command'		/* run command */


			if "`matrices'"!="" {
				forval i=1/`nmat' {
					local curmat : word `i' of `matrices'
					capture matrix `x' = `curmat'
					if _rc {
						di as error "error with matrix: `curmat'"
						exit 198
					}

					mat `repb' = nullmat(`repb'),`x'
				}
			}

			local k 1
			while `k' <= `nstat' {
				local curstat : word `k' of `stats'
				SubMacro `curstat'
				tempname x
				capture scalar `x' = `s(stat)'
				if _rc {
					if _rc == 1 { error 1 }
					di as error "error in replicate `rep'
					error _rc
				}
				mat `y'=(`x')
				mat `repb' = nullmat(`repb'),`y'
				local k = `k' + 1
			}


			if "$S_bs_noi"!="" { di /* blank line */ }

			matrix `repb'=`repb'-`totb'						/* turn into deviation */
			if "`method'"=="jkn" {
				local rfac : word `rep' of `psusizes'
				local rfac = ((`rfac'-1)/`rfac')
			}
			matrix `accumV' = `accumV' + (`rfac')*((`repb'')*(`repb'))	 /* add this one:  (b_k - b_tot)'(b_k - b_tot) */
													/* NOTE: Stata stores b as ROW vector, so b'b is  */
													/*       OUTER product, not inner				*/
			mat drop `repb'
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

		matrix `accumV'=`accumV' * `scalefac'


	*POST RESULTS!

		estimates post `totb' `accumV' , dof(`dof') 

		est scalar N_reps=`nsvrw'
		est scalar N_psu=`dof'*2			/* cludge to get svytest to work appropriately */
		est scalar N_strata=`dof'			/* ditto */

		est local command `"`thecommand'"'
		est local svr_wspec "`svrwspec'"
		est local pweight "`mainweight'"
		est local method "`method'"
		est local cmd "svysvrest"		/* svy at beginning to get svytest to accept results */
		est local labels `"`vl'"'
		est local statistics `"`labs'"'

		Display , `or' `diparm' `level' `liststats'
	}

end

program define Display

	syntax , [ or diparm(string) level(int $S_level) LISTstats ]

	if !inrange(`level',10,99) {
		di as err "level() must be between 10 and 99 inclusive"
		exit 198
	}
	if "`or'"=="or" {
		local eform "eform(Odds Ratio)"
	}

	
*DISPLAY RESULTS

	if "`e(cmd)'"!="svysvrest" {
		error 301
	}

	di
	di "{txt}Estimates with replication (`e(method)') based standard errors"
	di
	di "{txt}{p 0 22}Command:{space 14}`e(command)'{p_end}"
	di "{txt}Analysis weight:      `e(pweight)'"

	if length(`"`e(svr_wspec)'"')<=24 {
		di "{txt}Replicate weights:" _col(23) "`e(svr_wspec)'"
	}
	else {
		local part : word 1 of `e(svr_wspec)'
		di "{txt}Replicate weights:" _col(23) `"{stata svrset list rw:`part'...}"'
	}


	di "{txt}Number of replicates: `e(N_reps)'" _c
	di "{txt}{col 48}Degrees of freedom{col 68}={res}{ralign 10:`e(df_r)'}"


	if "`method'"=="brr" {
		di "{txt}k (Fay's method):     " %4.3f `fay'
	}

	di

	local plus = cond("`diparm'"!="","plus","")
	estimates display, level(`level') `eform' `plus'

	while "`diparm'"!="" {
		gettoken parm diparm : diparm , parse("\")
		gettoken slash diparm : diparm , parse("\")	/* get rid of \ if there */
		tokenize `parm'
		_diparm `1' , `2' label(`3') `4'
	}
	if "`plus'"=="plus" {
		di "{txt}{hline 13}{c BT}{hline 64}"
	}


	if "`liststats'"!="" {
		local labs  `e(labels)'
		local stats `e(statistics)'

		local nstat : word count `labs'

		di "{txt}Key: " _c
		forval i=1/`nstat' {
			local curlab : word `i' of `labs'
			local curstat : word `i' of `stats'
			di _col(6) "`curlab'" _col(14) `"`curstat'"'
		}
	}


end


program define Dollar, sclass /* put $ in front of any S_ */
	args mac
	sret clear
	local i = index(`"`mac'"',`"S_"')
	local n = length(`"`mac'"')
	local j 1
	while `i' != 0 & `j' <= `n' {
		local front = substr(`"`mac'"',1,`i'-1)
		local back  = substr(`"`mac'"',`i',.)
		local mac `"`front'$`back'"'
		local i = index(`"`mac'"',`"S_"')
		local j = `j' + 1 /* prevents infinite loop if error */
	}
	sret local mac `"`mac'"'
end



program define SubMacro, sclass
	sret clear
	local i = index(`"`0'"',`"S_"')
	local n = length(`"`0'"')
	local j 1
	while `i' != 0 & `j' <= `n' {
		local front = substr(`"`0'"',1,`i'-1)
		local back  = substr(`"`0'"',`i',.)
		local 0 `"`front'$`back'"'
		local i = index(`"`0'"',`"S_"')
		local j = `j' + 1 /* prevents infinite loop if error */
	}
	sret local stat `0'
end
