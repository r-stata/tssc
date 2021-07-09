*! version 1.0.0 15dec2009 E. Leuven, B. Sianesi
program define pstest2
version 10.0
syntax varlist(min=1) [, Treated(varname) SUPport(varname) MWeight(varname) SUMmary QUIetly GRaph]
	
	capture confirm var _treated
	if _rc & "`treated'"=="" {
		di as error "Error: provide treatment indicator variable"
		exit 198
	}
	else if !_rc & "`treated'"=="" {
		tempvar treated
		qui g double `treated' = _treated
	}

	
	capture confirm var _weight
	if _rc & "`mweight'"=="" {
		di as error "Error: provide weight"
	}
	else if !_rc &  "`mweight'"=="" {
		local mweight _weight
	}
	
	if ("`support'"=="") {
		tempvar support
		capture confirm var _support
		if _rc {
			qui g byte `support' = 1
		}
		else qui g byte `support'= _support
	}

	capture confirm var _pscore
	if _rc & "`pscore'"=="" & "`hotel'"!="" {
		di as error "Error: provide propensity score"
		exit 198
	}
	else if !_rc & "`pscore'"=="" & "`hotel'"!=""  {
		tempvar pscore
		qui g double `pscore' = _pscore
	}

	breduc `varlist' , mw(`mweight') tr(`treated') sup(`support') `summary' `quietly' `graph'
end

program define breduc, rclass
syntax varlist(min=1) , MWeight(varname) TReated(varname) SUPport(varname) [summary quietly graph]

	tempvar sumbias sumbias0 _bias0 _biasm xvar
	
	qui g `_bias0' = .
	qui g `_biasm' = .
	qui g str12 `xvar' = ""
	qui g `sumbias' = .
	qui g `sumbias0' = .

	/* construct header */
	`quietly' di
	`quietly' di as text "{hline 24}{c TT}{hline 34}{c TT}{hline 16}"
	`quietly' di as text "                        {c |}       Mean               %reduct {c |}     t-test"  
	`quietly' di as text "    Variable     Sample {c |} Treated Control    %bias  |bias| {c |}    t    p>|t|"
	`quietly' di as text "{hline 24}{c +}{hline 34}{c +}{hline 16}"

	/* calculate stats for varlist */
	tempname m1u m0u v1u v0u m1m m0m bias biasm absreduc tbef taft pbef paft r2bef r2aft chibef chiaft pchibef pchiaft
	local i 0
	foreach v of varlist `varlist' {
		local i = `i' + 1
		qui sum `v' if `treated'==1
		scalar `m1u' = r(mean)
		scalar `v1u' = r(Var)

		qui sum `v' if `treated'==0
		scalar `m0u' = r(mean)
		scalar `v0u' = r(Var)

		qui sum `v' if `treated'==1 & `support'==1
		scalar `m1m' = r(mean)

		qui sum `v' [iw=`mweight'] if `treated'==0 & `support'==1
		scalar `m0m' = r(mean)

		qui replace `xvar' = "`v'" in `i'
		
		/* standardised % bias before matching */
		scalar `bias' = 100*(`m1u' - `m0u')/sqrt((`v1u' + `v0u')/2)
		qui replace `_bias0' = `bias' in `i'
		qui replace `sumbias0' = abs(`bias') in `i'
		/* standardised % bias after matching */
		scalar `biasm' = 100*(`m1m' - `m0m')/sqrt((`v1u' + `v0u')/2)
		qui replace `_biasm' = `biasm' in `i'
		qui replace `sumbias' = abs(`biasm') in `i'
		/* % reduction in absolute bias */
		scalar `absreduc' = -100*(abs(`biasm') - abs(`bias'))/abs(`bias')

		/* t-tests before matching */
		qui regress `v' `treated' 
		scalar `tbef' = _b[`treated']/_se[`treated']
		scalar `pbef' = 2*ttail(e(df_r),abs(`tbef'))
		/* t-tests after matching */
		qui regress `v' `treated' [iw=`mweight'] if `support'==1
		scalar `taft' = _b[`treated']/_se[`treated']
		scalar `paft' = 2*ttail(e(df_r),abs(`taft'))

		`quietly' di as text %12s abbrev("`v'",12) "  Unmatched {c |}" as result %7.0g `m1u' "  " %7.0g `m0u' "  " %7.1f `bias'   _s(8)           as text " {c |}"  as res %7.2f `tbef'  _s(2) as res	 %05.3f `pbef'
		`quietly' di as text              _col(13) "    Matched {c |}" as result %7.0g `m1m' "  " %7.0g `m0m' "  " %7.1f `biasm' %8.1f `absreduc' as text " {c |}" as result %7.2f `taft'  _s(2) as res  %05.3f `paft'
		`quietly' di as text              _col(13) "            {c |}" as text _s(31) "   {c |}" 
	}
	`quietly' di as text "{hline 24}{c BT}{hline 34}{c BT}{hline 16}"

	if "`summary'"!="" {
		di as text "{hline 61}"
		di as text _col(10) "Summary of the distribution of the abs(bias)"
		di as text "{hline 61}"
		label var `sumbias0' "BEFORE MATCHING"
		sum `sumbias0', detail
		return scalar meanbiasbef = r(mean)
		return scalar medbiasbef  = r(p50)		
		di as text "{hline 61}"
		label var `sumbias' "AFTER MATCHING"
		sum `sumbias', detail
		return scalar meanbiasaft = r(mean)
		return scalar medbiasaft  = r(p50)		
		di as text "{hline 61}"

		qui probit `treated' `varlist'
		scalar `r2bef' = e(r2_p)
		scalar `chibef' = e(chi2)
		scalar `pchibef' = chi2tail(e(df_m), e(chi2))
		return scalar r2bef = e(r2_p)
		return scalar chiprobbef = chi2tail(e(df_m), e(chi2))

		qui probit `treated' `varlist' [iw=`mweight'] if `support'==1
		scalar `r2aft' = e(r2_p)
		scalar `chiaft' = e(chi2)
		scalar `pchiaft' = chi2tail(e(df_m), e(chi2))
		return scalar r2aft = e(r2_p)
		return scalar chiprobaft = chi2tail(e(df_m), e(chi2)) 

		di
		di as text "{hline 12}{c TT}{hline 49}"
		di as text "     Sample {c |}    Pseudo R2      LR chi2        p>chi2"
		di as text "{hline 12}{c +}{hline 49}"
		di as text "  Unmatched {c |}"  _s(4) as res %9.3f `r2bef' _s(4) as res %9.2f `chibef' _s(5) as res %9.3f `pchibef'
		di as text "    Matched {c |}"  _s(4) as res %9.3f `r2aft' _s(4) as res %9.2f `chiaft' _s(5) as res %9.3f `pchiaft'
		di as text "{hline 62}"
	}

	if "`graph'"!="" {
		graph dot `_bias0' `_biasm', over(`xvar', sort(1) descending) legend(label(1 "Unmatched") label(2 "Matched")) yline(0, lcolor(gs10)) marker(1, mcolor(black)  msymbol(O)) marker(2, mcolor(black)  msymbol(X))
	}
	
end
