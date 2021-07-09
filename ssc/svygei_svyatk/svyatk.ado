*! version 2.0.1  30Jun2017 P. Poppitz 
*! update to versions >10
*! version 2.0.0  13May2005 Biewen & Jenkins 
*! Update to version 8.2, with minor other cosmetic changes
*! version 1.1.1  1april2003  Biewen & Jenkins 
*! Estimation of Atkinson inequality indices from complex survey data

program define svyatk, eclass
	version 10
	if replay() {
		if "`e(cmd)'" != "svyatk" {
			noi di in red "results for svyatk not found"
			exit 301
		}
		Display `0'
		exit `rc'
	}
	else	Estimate `0'
end

program define Estimate, eclass 

	syntax varname [if] [in] [, SUBpop(varname) Epsilon(real 2.5) Level(passthru) ]

	marksample touse
	markout `touse' `varlist' `subpop'

		/* Check whether zero or negative incomes, and omit from calculations */
	quietly {
		count if `touse'
		if r(N) == 0 {
			di as error "no valid observations"
			error 2000
		}
		count if `varlist' < 0 & `touse'
		local ct = r(N)
		if `ct' > 0 {
			noi di " "
			noi di as txt "Warning: `varlist' has `ct' values < 0." _c
			noi di as txt " Not used in calculations"
		}
		count if `varlist' == 0 & `touse'
		local ct = r(N)
		if `ct' > 0 {
			noi di " "
			noi di as txt "Warning: `varlist' has `ct' values = 0." _c
			noi di as txt " Not used in calculations"
		}
		tempvar badinc
		ge `badinc' = 0
		replace `badinc' =. if `varlist' <= 0
	}

	markout `touse'  `badinc'

	if (`epsilon') <= 0 {
		di as error "epsilon must be greater than zero"
		exit 198
	}

	if (`epsilon') == .5 | (`epsilon') == 1 | (`epsilon') == 1.5 | (`epsilon') == 2 {
		local epsilon = 2.5
	}

	if "`subpop'" != "" {
		local opt "subpop(`subpop')"
	}


	tempvar one vu1me vu05 vum05 vum1 vt0
	quietly {


				/* check that >1 PSU per stratum */

		capture svy: mean `varlist' if `touse'
			if _rc {
				local rc = _rc
				if `rc' == 460 {
					di as error "stratum with only one psu detected"
					di as error "locate using -svy: des-"
					exit 460
				}
			}

				/* generate auxiliary variables  */
		gen double `one' = 1 if `touse'
		gen double `vu1me' = `varlist'^(1-(`epsilon')) if `touse'
		gen double `vu05' = `varlist'^(1-0.5) if `touse'
		gen double `vum05' = `varlist'^(1-1.5) if `touse'
		gen double `vum1' = `varlist'^(1-2) if `touse'
		gen double `vt0' = log(`varlist') if `touse'

			/* estimate totals */
		 svy: total `one' `varlist' `vu1me' `vu05' `vum05' `vum1' `vt0' if `touse', `opt' 
	}

	tempname totals u0 u1 u1me u05 um05 um1 t0

	matrix `totals' = get(_b)

	scalar `u0' = `totals'[1,1]
	scalar `u1' = `totals'[1,2]
	scalar `u1me' = `totals'[1,3]
	scalar `u05' = `totals'[1,4]
	scalar `um05' = `totals'[1,5]
	scalar `um1' = `totals'[1,6]
	scalar `t0' = `totals'[1,7]


	/* calculate indices */

	tempname atk05 atk1 atk15 atk2 atkeps

	scalar `atk05' = 1 - `u0'^(-0.5/(1-0.5)) * `u1'^(-1) * `u05'^(1/(1-0.5))
	scalar `atk1' = 1 - `u0' * `u1'^(-1) * exp(`t0'/`u0')
	scalar `atk15' = 1 - `u0'^(-1.5/(1-1.5)) * `u1'^(-1) * `um05'^(1/(1-1.5))
	scalar `atk2' = 1 - `u0'^(-2/(1-2)) * `u1'^(-1) * `um1'^(1/(1-2))
	scalar `atkeps' = 1 - `u0'^(-(`epsilon')/(1-(`epsilon'))) * `u1'^(-1) * `u1me'^(1/(1-(`epsilon')))


	/* calculate residuals */

	tempvar ratk05 ratk1 ratk15 ratk2 ratkeps

	quietly {
		gen double `ratk05' = (0.5/(1-0.5))*`u1'^(-1)*`u05'^(1/(1-0.5))*`u0'^(-1/(1-0.5)) /*
			*/ + `u0'^(-0.5/(1-0.5))*`u05'^(1/(1-0.5))*`u1'^(-2)*`varlist' /*
			*/ - (1/(1-0.5))*`u0'^(-0.5/(1-0.5))*`u1'^(-1)*`u05'^(0.5/(1-0.5))*`varlist'^(1-0.5)  if `touse'
		gen double `ratk1' = (`atk1'-1)*`u0'^(-1)*(1-`u0'^(-1)*`t0') /*
			*/ + (1-`atk1')*`u1'^(-1)*`varlist' + (`atk1'-1)*`u0'^(-1)*log(`varlist') if `touse'
		gen double `ratk15' = (1.5/(1-1.5))*`u1'^(-1)*`um05'^(1/(1-1.5))*`u0'^(-1/(1-1.5)) /*
			*/ + `u0'^(-1.5/(1-1.5))*`um05'^(1/(1-1.5))*`u1'^(-2)*`varlist' /*
			*/ - (1/(1-1.5))*`u0'^(-1.5/(1-1.5))*`u1'^(-1)*`um05'^(1.5/(1-1.5))*`varlist'^(1-1.5) if `touse'
		gen double `ratk2' = (2/(1-2))*`u1'^(-1)*`um1'^(1/(1-2))*`u0'^(-1/(1-2)) /*
			*/ + `u0'^(-2/(1-2))*`um1'^(1/(1-2))*`u1'^(-2)*`varlist' /*
			*/ - (1/(1-2))*`u0'^(-2/(1-2))*`u1'^(-1)*`um1'^(2/(1-2))*`varlist'^(1-2) if `touse'
		gen double `ratkeps' = ((`epsilon')/(1-(`epsilon')))*`u1'^(-1)*`u1me'^(1/(1-(`epsilon')))*`u0'^(-1/(1-(`epsilon'))) /*
			*/ + `u0'^(-(`epsilon')/(1-(`epsilon')))*`u1me'^(1/(1-(`epsilon')))*`u1'^(-2)*`varlist' /*
			*/ - (1/(1-(`epsilon')))*`u0'^(-(`epsilon')/(1-(`epsilon')))*`u1'^(-1)*`u1me'^((`epsilon')/(1-(`epsilon')))*`varlist'^(1-(`epsilon')) if `touse'

			/* calculate standard errors */
		svy: total `ratk05' `ratk1' `ratk15' `ratk2' `ratkeps' if `touse', `opt'
	}

	tempname cov satk05 satk1 satk15 satk2 satkeps

	matrix `cov' = get(VCE)

	scalar `satk05' = sqrt(`cov'[1,1])
	scalar `satk1' = sqrt(`cov'[2,2])
	scalar `satk15' = sqrt(`cov'[3,3])
	scalar `satk2' = sqrt(`cov'[4,4])
	scalar `satkeps' = sqrt(`cov'[5,5])

	eret scalar atk05 = `atk05' 
	eret scalar atk1 = `atk1' 
	eret scalar atk15 = `atk15'  
	eret scalar atk2 = `atk2'  
	eret scalar atkeps = `atkeps'

	eret scalar epsilon = `epsilon'

	eret scalar se_atk05 = `satk05'
	eret scalar se_atk1 = `satk1'
	eret scalar se_atk15 = `satk15'
	eret scalar se_atk2 = `satk2' 
	eret scalar se_atkeps = `satkeps'

	eret local cmd  "svyatk"
	eret local var "`varlist'"
	if "`e(wexp)'" ~= "" {
		eret local wvar = subinstr("`e(wexp)'", "= ", "", 1)
	}

	if "`subpop'" != "" {
		tempname n
		mat `n' = e(_N_subp)
		eret scalar N_subpop = `n'[1,1]
	}


	Display, `level'

end


	
prog define Display

	syntax [, Level(int $S_level) ]

	di _newline
	di as text "Complex survey estimates of Atkinson inequality indices"   
	di " "

	if "`e(wvar)'" ~= "" {
		di as text "pweight: " "`e(wvar)'" _col(48) "Number of obs    = " as result e(N)
	}
	if "`e(wvar)'" == ""  {
		di as text "pweight: <none>" _col(48) "Number of obs    = " as result e(N)
	}
	if "`e(strata)'" ~= "" {
		di as text "Strata: " "`e(strata)'" _col(48) "Number of strata = " as result e(N_strata)
	}
	if "`e(strata)'" == "" {
		di as text "Strata: <one>"  _col(48) "Number of strata = " as result e(N_strata)
	}
	if "`e(psu)'" ~= "" {
		di as text "PSU: " "`e(psu)'" _col(48) "Number of PSUs   = " as result e(N_psu)
	}
	if "`e(psu)'" == "" {
		di as text "PSU: <observations>"  _col(48) "Number of PSUs   = " as result e(N_psu)
	}
	di as text _col(48) "Population size  = " as result e(N_pop)
	if "`e(subpop)'" ~= "" {
		di as text "Subpop: " as res "`e(subexp)'"   _c
		di as text ", subpop. size = " as result e(N_subpop)
	}

	di as text "{hline 9}{c TT}{hline 65}"
	di as text "Index  " _col(10) "{c |}  Estimate " _c
	di as text _col(24)  "Std. Err." _col(39) "z"  _c
	di as text _col(46) "P>|z|"  _col(56) "[`level'% Conf. Interval]"
	di as text "{hline 9}{c +}{hline 65}"

	di as text "A(0.5)" _col(10) "{c |} " %9.0g as result e(atk05) _c 
	di as result _col(24) e(se_atk05) _col(31)  _c
	di %9.2f as result e(atk05)/e(se_atk05) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(atk05)'/`e(se_atk05)')) _c
	di _col(56) %9.0g as result e(atk05)+invnormal((100-`level')/200)*e(se_atk05) _c
	di _col(67) %9.0g as result e(atk05)-invnormal((100-`level')/200)*e(se_atk05) 

	di as text "A(1)" _col(10) "{c |} " %9.0g as result e(atk1) _c
	di as result _col(24) e(se_atk1) _col(31)  _c
	di %9.2f as result e(atk1)/e(se_atk1) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(atk1)'/`e(se_atk1)')) _c
	di _col(56) %9.0g as result e(atk1)+invnormal((100-`level')/200)*e(se_atk1) _c
	di _col(67) %9.0g as result e(atk1)-invnormal((100-`level')/200)*e(se_atk1) 

	di as text "A(1.5)" _col(10) "{c |} " %9.0g as result e(atk15) _c
	di as result _col(24) e(se_atk15) _col(31)  _c
	di %9.2f as result e(atk15)/e(se_atk15) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(atk15)'/`e(se_atk15)')) _c
	di _col(56) %9.0g as result e(atk15)+invnormal((100-`level')/200)*e(se_atk15) _c
	di _col(67) %9.0g as result e(atk15)-invnormal((100-`level')/200)*e(se_atk15) 

	di as text "A(2)" _col(10) "{c |} " %9.0g as result e(atk2) _c
	di as result _col(24) e(se_atk2) _col(31)  _c
	di %9.2f as result e(atk2)/e(se_atk2) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(atk2)'/`e(se_atk2)')) _c
	di _col(56) %9.0g as result e(atk2)+invnormal((100-`level')/200)*e(se_atk2) _c
	di _col(67) %9.0g as result e(atk2)-invnormal((100-`level')/200)*e(se_atk2)
 
	di as text "A(`e(epsilon)')" _col(10) "{c |} " %9.0g as result e(atkeps) _c
	di as result _col(24) e(se_atkeps) _col(31)  _c
	di %9.2f as result e(atkeps)/e(se_atkeps) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(atkeps)'/`e(se_atkeps)')) _c
	di _col(56) %9.0g as result e(atkeps)+invnormal((100-`level')/200)*e(se_atkeps) _c
	di _col(67) %9.0g as result e(atkeps)-invnormal((100-`level')/200)*e(se_atkeps)

	di as text "{hline 9}{c BT}{hline 65}"

end
