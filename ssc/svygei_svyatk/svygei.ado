*! version 2.0.1  30Jun2017 P. Poppitz 
*! update to versions >10
*! version 2.0.0  13May2005 Biewen & Jenkins 
*! Update to version 8.2, with minor other cosmetic changes
*! version 1.1.1  1april2003  Biewen & Jenkins 
*! Estimation of GE inequality indices from complex survey data

program define svygei, eclass
	version 10
	if replay() {
		if "`e(cmd)'" != "svygei" {
			noi di in red "results for svygei not found"
			exit 301
		}
		Display `0'
		exit `rc'
	}
	else	Estimate `0'
end

program define Estimate, eclass 

	syntax varname [if] [in] [, SUBpop(varname) Alpha(real 3) Level(passthru) ]

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



	if (`alpha')==0 | (`alpha')==1  | (`alpha')== -1  | (`alpha')==2 {
		local alpha = 3
	}


	if "`subpop'" != "" {
		local opt "subpop(`subpop')"
	}




	tempvar one vua vum1 vu2 vt0 vt1
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
		gen double `vua' = `varlist'^(`alpha') if `touse'
		gen double `vum1' = `varlist'^(-1) if `touse'
		gen double `vu2' = `varlist'^(2) if `touse'
		gen double `vt0' = log(`varlist') if `touse'
		gen double `vt1' = `varlist' * log(`varlist') if `touse'

			/* estimate totals */

		svy: total `one' `varlist' `vua' `vum1' `vu2' `vt0' `vt1' if `touse',  `opt'  

	}

	tempname totals u0 u1 ua um1 u2 t0 t1

	matrix `totals' = get(_b)

	scalar `u0' = `totals'[1,1]
	scalar `u1' = `totals'[1,2]
	scalar `ua' = `totals'[1,3]
	scalar `um1' = `totals'[1,4]
	scalar `u2' = `totals'[1,5]
	scalar `t0' = `totals'[1,6]
	scalar `t1' = `totals'[1,7]


		/* calculate indices */

	tempname gem1 ge0 ge1 ge2 gea

	scalar `gem1' = ((-1)*(-1-1))^(-1)*(`u0'^(-1-1)*`u1'^(-(-1))*`um1'-1)
	scalar `ge0' = -`t0'/`u0'+log(`u1'/`u0')
	scalar `ge1' = `t1'/`u1'-log(`u1'/`u0')
	scalar `ge2' = (2*(2-1))^(-1)*(`u0'^(2-1)*`u1'^(-2)*`u2'-1)
	scalar `gea' = ((`alpha')*((`alpha')-1))^(-1)*(`u0'^((`alpha')-1)*`u1'^(-(`alpha'))*`ua'-1)
	
		/* calculate residuals */

	tempvar rgem1 rge0 rge1 rge2 rgea

	quietly {
		gen double `rgem1' = (-1)^(-1)*`um1'*`u1'^(-(-1))*`u0'^((-1)-2) /*
			*/ - ((-1)-1)^(-1)*`um1'*`u1'^(-(-1)-1)*`u0'^((-1)-1)*`varlist' /*
			*/ + ((-1)^2-(-1))^(-1)*`u0'^((-1)-1)*`u1'^(-(-1))*`varlist'^(-1) if `touse'
		gen double `rge0' = -`u0'^(-1)*log(`varlist') + `u1'^(-1)*`varlist' /*
			*/ + `u0'^(-1)*(`t0'*`u0'^(-1)-1) if `touse'
		gen double `rge1' = `u1'^(-1)*`varlist'*log(`varlist') /*
			*/ - `u1'^(-1)*(`t1'*`u1'^(-1)+1)*`varlist' + `u0'^(-1) if `touse'
		gen double `rge2' = 2^(-1)*`u2'*`u1'^(-2)*`u0'^(2-2) /*
			*/ - (2-1)^(-1)*`u2'*`u1'^(-2-1)*`u0'^(2-1)*`varlist' /*
			*/ + (2^2-2)^(-1)*`u0'^(2-1)*`u1'^(-2)*`varlist'^2 if `touse'
		gen double `rgea' = (`alpha')^(-1)*`ua'*`u1'^(-(`alpha'))*`u0'^((`alpha')-2) /*
			*/ - ((`alpha')-1)^(-1)*`ua'*`u1'^(-(`alpha')-1)*`u0'^((`alpha')-1)*`varlist' /*
			*/ + ((`alpha')^2-(`alpha'))^(-1)*`u0'^((`alpha')-1)*`u1'^(-(`alpha'))*`varlist'^(`alpha') if `touse'

			/* calculate standard errors */
		svy: total `rgem1' `rge0' `rge1' `rge2' `rgea' if `touse', `opt' 
	}

	tempname cov sgem1 sge0 sge1 sge2 sgea

	matrix `cov' = get(VCE)

	scalar `sgem1' = sqrt(`cov'[1,1])
	scalar `sge0' = sqrt(`cov'[2,2])
	scalar `sge1' = sqrt(`cov'[3,3])
	scalar `sge2' = sqrt(`cov'[4,4])
	scalar `sgea' = sqrt(`cov'[5,5])

	eret scalar gem1 = `gem1' 
	eret scalar ge0 = `ge0' 
	eret scalar ge1 = `ge1'  
	eret scalar ge2 = `ge2'  
	eret scalar gea = `gea'

	eret scalar alpha = `alpha'

	eret scalar se_gem1 = `sgem1'
	eret scalar se_ge0 = `sge0'
	eret scalar se_ge1 = `sge1'
	eret scalar se_ge2 = `sge2' 
	eret scalar se_gea = `sgea'

	eret local cmd  "svygei"
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



program define Display

	syntax [, Level(int $S_level) ]

	di _newline
	di as text "Complex survey estimates of Generalized Entropy inequality indices"   
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

	di as text "GE(-1)" _col(10) "{c |} " %9.0g as result e(gem1) _c 
	di as result _col(24) e(se_gem1) _col(31)  _c
	di %9.2f as result e(gem1)/e(se_gem1) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(gem1)'/`e(se_gem1)')) _c
	di _col(56) %9.0g as result e(gem1)+invnormal((100-`level')/200)*e(se_gem1) _c
	di _col(67) %9.0g as result e(gem1)-invnormal((100-`level')/200)*e(se_gem1) 

	di as text "MLD" _col(10) "{c |} " %9.0g as result e(ge0) _c
	di as result _col(24) e(se_ge0) _col(31)  _c
	di %9.2f as result e(ge0)/e(se_ge0) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(ge0)'/`e(se_ge0)')) _c
	di _col(56) %9.0g as result e(ge0)+invnormal((100-`level')/200)*e(se_ge0) _c
	di _col(67) %9.0g as result e(ge0)-invnormal((100-`level')/200)*e(se_ge0) 

	di as text "Theil" _col(10) "{c |} " %9.0g as result e(ge1) _c
	di as result _col(24) e(se_ge1) _col(31)  _c
	di %9.2f as result e(ge1)/e(se_ge1) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(ge1)'/`e(se_ge1)')) _c
	di _col(56) %9.0g as result e(ge1)+invnormal((100-`level')/200)*e(se_ge1) _c
	di _col(67) %9.0g as result e(ge1)-invnormal((100-`level')/200)*e(se_ge1) 

	di as text "GE(2)" _col(10) "{c |} " %9.0g as result e(ge2) _c
	di as result _col(24) e(se_ge2) _col(31)  _c
	di %9.2f as result e(ge2)/e(se_ge2) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(ge2)'/`e(se_ge2)')) _c
	di _col(56) %9.0g as result e(ge2)+invnormal((100-`level')/200)*e(se_ge2) _c
	di _col(67) %9.0g as result e(ge2)-invnormal((100-`level')/200)*e(se_ge2)
 
	di as text "GE(`e(alpha)')" _col(10) "{c |} " %9.0g as result e(gea) _c
	di as result _col(24) e(se_gea) _col(31)  _c
	di %9.2f as result e(gea)/e(se_gea) _col(40) _c
	di %9.3f as result 2*(1-normal(`e(gea)'/`e(se_gea)')) _c
	di _col(56) %9.0g as result e(gea)+invnormal((100-`level')/200)*e(se_gea) _c
	di _col(67) %9.0g as result e(gea)-invnormal((100-`level')/200)*e(se_gea)

	di as text "{hline 9}{c BT}{hline 65}"



end


