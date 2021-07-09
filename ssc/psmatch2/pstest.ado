*! version 4.2.2 25apr2017 E. Leuven, B. Sianesi
program define pstest
	version 11.0
	#delimit ;
	syntax [varlist(default=none fv)] [if] [in] [,
	Treated(varname)
	BOTH
	RAW
	SUPport(varname)
	MWeight(varname)
	DENSity
	BOX
	OUTlier
	NOTable
	DISt
	LABel
	ONLYsig
	GRaph
	HIST
	SCatter
	RUBin
	ATU
	*
	];
	#delimit cr

	marksample touse, novarlist

	if "`varlist'"=="" & "`r(exog)'"!="" {
		local varlist = "`r(exog)'"
	}

	if "`varlist'"=="" & "`r(exog)'"=="" {
		di as error "Error: specify covariates"
		exit 198
	}

	if ("`density'"!="" & "`box'"!="") {
		di as error "Error: choose between " as input "density " as error "and " as input "box"
		exit 198
	}

	if ("`both'"!="" & "`raw'"!="") {
		di as error "Error: choose between " as input "both " as error "and " as input "raw"
		exit 198
	}

	if ("`graph'"!="" & "`hist'"!="") {
		di as error "Error: choose between " as input "dot graph " as error "and " as input "histogram"
		exit 198
	}

	if ("`graph'"!="" & "`scatter'"!="") {
		di as error "Error: choose between " as input "dot graph " as error "and " as input "scatter"
		exit 198
	}

	if ("`scatter'"!="" & "`hist'"!="") {
		di as error "Error: choose between " as input "scatter " as error "and " as input "histogram"
		exit 198
	}

	
	capture confirm var _treated
	if (_rc & "`treated'"=="") | ("`raw'"!="" & "`treated'"=="") {
		di as error "Error: provide treatment indicator variable"
		exit 198
	}
	else if (!_rc & "`treated'"=="") {
		tempvar treated
		qui g double `treated' = _treated
	}

	tempvar weight
	if ("`mweight'"=="") {
		if ("`raw'"!="") qui g double `weight' = 1
		else {
			capture confirm var _weight
			if (!_rc) qui g double `weight' = _weight
			else di as error "Error: provide weight"
		}
	}
	else g double `weight' = `mweight'
	
	if ("`support'"=="") {
		tempvar support
		capture confirm var _support
		if (_rc | "`raw'"!="") qui g byte `support' = 1
		else qui g byte `support'= _support
	}

	qui replace  `weight' = `support' if cond("`atu'" == "", `treated'==1, `treated'==0)

	if ("`density'"=="" & "`box'"=="" & "`both'"!="") {
		breduc  `varlist' , touse(`touse') mw(`weight') tr(`treated') sup(`support') `notable' `dist' `label' `graph' `hist' `scatter' options("`options'") `rubin'
	}
	if ("`density'"=="" & "`box'"=="" & "`both'"=="") {
		breduc1 `varlist' , touse(`touse') mw(`weight') tr(`treated') sup(`support') `notable' `dist' `label' `graph' `hist' `scatter' options("`options'") `rubin' `onlysig' `raw'
	}
	if ("`density'"!="" | "`box'"!="") {
		plotvar `varlist' , touse(`touse') `raw' `both' mw(`weight') tr(`treated') sup(`support') `density' `box' `outlier' options("`options'") 
	}
	
end


program define breduc, rclass
syntax varlist(min=1 fv), MWeight(varname) TReated(varname) SUPport(varname) [touse(varname) NOTable DISt LABel GRaph HIST SCatter options(string) RUBin]

	tempvar sumbias sumbias0 _bias0 _biasm xvar meanbiasbef medbiasbef meanbiasaft medbiasaft _vratio_bef _vratio_aft
	tempname Flowu Fhighu Flowm Fhighm

	qui count if `treated'==1 & `touse'
	scalar `Flowu'  = invF(r(N)-1, r(N)-1, 0.025)
	scalar `Fhighu' = invF(r(N)-1, r(N)-1, 0.975)

	qui count if `treated'==1 & `support'==1 & `touse'
	scalar `Flowm'  = invF(r(N)-1, r(N)-1, 0.025)
	scalar `Fhighm' = invF(r(N)-1, r(N)-1, 0.975)

	qui g `_bias0' = .
	qui g `_biasm' = .
	qui g str12 `xvar' = ""
	qui g `sumbias' = .
	qui g `sumbias0' = .

	qui g `_vratio_bef' = .
	qui g `_vratio_aft' = .

	if "`notable'"!="" {
		local quietly "quietly"
	}

	fvexpand `varlist'	
	local hasfactorvars = ("`=r(fvops)'" == "true")
	local vnames `r(varlist)'
	local vlength 22
	foreach v of local vnames {
		local vlength = max(`vlength', length("`v'"))
	}
	
	/* construct header */
	local c = `vlength' + 4
	local s = `vlength' - 22
	if ("`rubin'"!="" | "`scatter'"!="") {
		local add "_e"
	}
	`quietly' di
	`quietly' di as text "{hline `c'}{c TT}{hline 34}{c TT}{hline 15}{c TT}{hline 10}"
	`quietly' di as text "              " _s(`s') "  Unmatched {c |}       Mean               %reduct {c |}     t-test    {c |}  V`add'(T)/"
	`quietly' di as text "Variable      " _s(`s') "    Matched {c |} Treated Control    %bias  |bias| {c |}    t    p>|t| {c |}  V`add'(C)" 
	`quietly' di as text "{hline `c'}{c +}{hline 34}{c +}{hline 15}{c +}{hline 10}"
	
	/* get linear index and some overall stats for later*/
	tempvar index0 indexm
	tempname r2bef r2aft chibef chiaft pchibef pchiaft
	
	qui probit `treated' `varlist' if `touse'
	qui predict double `index0' if e(sample), xb
	scalar `r2bef' = e(r2_p)
	scalar `chibef' = e(chi2)
	scalar `pchibef' = chi2tail(e(df_m), e(chi2))
	return scalar r2bef = e(r2_p)
	return scalar chiprobbef = chi2tail(e(df_m), e(chi2))

	qui probit `treated' `varlist' [iw=`mweight'] if `support'==1 & `touse'
	qui predict double `indexm' if e(sample), xb
	scalar `r2aft' = e(r2_p)
	scalar `chiaft' = e(chi2)
	scalar `pchiaft' = chi2tail(e(df_m), e(chi2))
	return scalar r2aft = e(r2_p)
	return scalar chiprobaft = chi2tail(e(df_m), e(chi2)) 

	
	/* calculate stats for varlist */
	tempname m1u m0u v1u v0u m1m m0m bias biasm absreduc tbef taft pbef paft 
	tempname v1m v0m v_ratiobef v_ratioaft v_e_1
	tempvar resid0 resid1
	local cnt_concbef = 0  /* counting vars with ratio of concern - rubin */
	local cnt_concaft = 0  	
	local cnt_badbef  = 0  /* counting vars with bad ratio - rubin */
	local cnt_badaft  = 0
	local cont_cnt = 0     /* counting continuous vars */
	local cont_varbef = 0  /* counting continuous vars w/ excessive var ratio*/
	local cont_varaft = 0  
	local i 0
	fvrevar `varlist'
	foreach v in `r(varlist)' {
		local ++i 
		local xlab : word `i' of `vnames'
		if (regexm("`xlab'", ".*b[\\.].*") == 1) continue

		if (`hasfactorvars'==0 & "`label'" != "") {
			local xlab : var label `v'
			if ("`xlab'" == "") local xlab `v'
		}

		qui sum `v' if `treated'==1 & `touse'
		scalar `m1u' = r(mean)
		scalar `v1u' = r(Var)

		qui sum `v' if `treated'==0 & `touse'
		scalar `m0u' = r(mean)
		scalar `v0u' = r(Var)

		qui sum `v' [iw=`mweight'] if `treated'==1 & `support'==1 & `touse'
		scalar `m1m' = r(mean)
		scalar `v1m' = r(Var)

		qui sum `v' [iw=`mweight'] if `treated'==0 & `support'==1 & `touse'
		scalar `m0m' = r(mean)
 		scalar `v0m' = r(Var)

		
		scalar `v_ratiobef' = .
		scalar `v_ratioaft' = .
		local starbef ""
		local staraft ""
		
		if ("`rubin'"=="" & "`scatter'"=="") {
			capture assert `v'==0 | `v'==1 | `v'==., fast
			if (_rc) {
				local cont_cnt = `cont_cnt' +1
				/* get Var ratio*/
				scalar `v_ratiobef' = `v1u'/`v0u' 
				if `v_ratiobef'>`Fhighu'  | `v_ratiobef'<`Flowu' {
					local cont_varbef = `cont_varbef' +1
					local starbef "*"
				}
				scalar `v_ratioaft' = `v1m'/`v0m' 
				if `v_ratioaft'>`Fhighm'  | `v_ratioaft'<`Flowm' {
					local cont_varaft = `cont_varaft' +1
					local staraft "*"
				}
			}
		}
		
		if ("`rubin'"!="" | "`scatter'"!="") {
			cap drop `resid1'
			cap drop `resid0'
			qui regress `v' `index0' if `treated'==1  & `touse'  
			qui predict double `resid1' if e(sample), resid
			qui regress `v' `index0' if `treated'==0 & `touse' 
			qui predict double `resid0' if e(sample), resid
			qui sum `resid1' 
			scalar `v_e_1' = r(Var)
			qui sum `resid0'  
			scalar `v_ratiobef' = `v_e_1'/r(Var)
			qui replace `_vratio_bef' = `v_ratiobef' in `i'
			if (`v_ratiobef'>1.25 & `v_ratiobef'<=2) | (`v_ratiobef'<0.8 & `v_ratiobef'>=0.5) {	  
				local cnt_concbef = `cnt_concbef' +1
				local starbef "*"
			}
			if (`v_ratiobef'>2 & `v_ratiobef'<.) | `v_ratiobef'<0.5 {	 
				local cnt_badbef = `cnt_badbef' +1
				local starbef "**"
			}
			drop `resid1'
			drop `resid0'
			qui regress `v' `indexm' [iw=`mweight'] if `treated'==1 & `support'==1 & `touse'
			qui predict double `resid1' if e(sample), resid
			qui regress `v' `indexm' [iw=`mweight'] if `treated'==0 & `support'==1 & `touse' 
			qui predict double `resid0' if e(sample), resid
			qui sum `resid1' [iw=`mweight'] 
			scalar `v_e_1' = r(Var)
			qui sum `resid0' [iw=`mweight'] 
			scalar `v_ratioaft' = `v_e_1'/r(Var)
			qui replace `_vratio_aft' = `v_ratioaft' in `i'
			if (`v_ratioaft'>1.25 & `v_ratioaft'<=2) | (`v_ratioaft'<0.8 & `v_ratioaft'>=0.5) {	  
				local cnt_concaft = `cnt_concaft' +1
				local staraft "*"
			}
			if (`v_ratioaft'>2 & `v_ratioaft'<.) | `v_ratioaft'<0.5 {	 
				local cnt_badaft = `cnt_badaft' +1
				local staraft "**"
			}
		}

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
		qui regress `v' `treated' if `touse' 
		scalar `tbef' = _b[`treated']/_se[`treated']
		scalar `pbef' = 2*ttail(e(df_r),abs(`tbef'))
		/* t-tests after matching */
		qui regress `v' `treated' [iw=`mweight'] if `support'==1 & `touse'
		scalar `taft' = _b[`treated']/_se[`treated']
		scalar `paft' = 2*ttail(e(df_r),abs(`taft'))

		`quietly' di as text  %-`vlength's abbrev("`xlab'",`vlength') _col(`=`c'-2') "U  {c |}" as result %7.0g `m1u' "  " %7.0g `m0u' "  " %7.1f `bias'   _s(8)           as text " {c |}"  as res %7.2f `tbef'  _s(2) as res	%05.3f `pbef' " {c |}"  as res %6.2f `v_ratiobef' "`starbef'"
		`quietly' di as text                                          _col(`=`c'-2') "M  {c |}" as result %7.0g `m1m' "  " %7.0g `m0m' "  " %7.1f `biasm' %8.1f `absreduc' as text " {c |}"  as res %7.2f `taft'  _s(2) as res  %05.3f `paft' " {c |}"  as res %6.2f `v_ratioaft' "`staraft'"
		`quietly' di as text                                          _col(`=`c'-2') "   {c |}" as text _s(31) "   {c |}" as text _s(12) "   {c |}" 
	}
	`quietly' di as text "{hline `c'}{c BT}{hline 34}{c BT}{hline 15}{c BT}{hline 10}"
	if ("`rubin'"=="" & "`scatter'"=="") {
		`quietly' di as text "* if variance ratio outside [" %4.2f `Flowu' "; " %4.2f `Fhighu' "] for U and ["  %4.2f `Flowm' "; " %4.2f `Fhighm' "] for M"
	}
	if ("`rubin'"!="" | "`scatter'"!="") {
		`quietly' di as text "*  if 'of concern', i.e. variance ratio in [0.5, 0.8) or (1.25, 2]"
		`quietly' di "** if 'bad', i.e. variance ratio <0.5 or >2 "
	}
	di ""

	local quietly ""
	if "`dist'"=="" {
		local quietly "quietly"
	}
	`quietly' di as text "{hline 61}"
	`quietly' di as text _col(10) "Summary of the distribution of the abs(bias)"
	`quietly' di as text "{hline 61}"
	label var `sumbias0' "BEFORE MATCHING"
	`quietly' sum `sumbias0', detail
	scalar `meanbiasbef' = r(mean)
	scalar `medbiasbef'  = r(p50)
	return scalar meanbiasbef = r(mean)
	return scalar medbiasbef  = r(p50)		
	`quietly' di as text "{hline 61}"
	label var `sumbias' "AFTER MATCHING"
	`quietly' sum `sumbias', detail
	scalar `meanbiasaft' = r(mean)
	scalar `medbiasaft'  = r(p50)
	return scalar meanbiasaft = r(mean)
	return scalar medbiasaft  = r(p50)		
	`quietly' di as text "{hline 61}"
	`quietly' di 

	// Rubin's stats:
	// Rubin's B = absolute standardized differences of means of the linear index of the propensity score  
	// Rubin's R = ratio of treated to non-treated variance of the propensity score index
	tempname mi1 vi1 mi0 vi0 iratiobef ibiasbef iratioaft ibiasaft 
	qui sum `index0' if `treated'==1 & `touse'
	scalar `mi1' = r(mean)
	scalar `vi1' = r(Var)
	qui sum `index0' if `treated'==0 & `touse'
	scalar `mi0' = r(mean)
	scalar `vi0' = r(Var)
	scalar `ibiasbef' = 100*(`mi1' - `mi0')/sqrt((`vi1' + `vi0')/2)
	scalar `iratiobef' = `vi1'/`vi0'
	return scalar Bbef = `ibiasbef'
	return scalar Rbef = `iratiobef'
	if (`ibiasbef'>=25) local starBbef "*"
	if !inrange(`iratiobef', 0.5, 2) local starRbef "*"

	qui sum `indexm' [iw=`mweight'] if `treated'==1 & `support'==1 & `touse'
	scalar `mi1' = r(mean)
	scalar `vi1' = r(Var)
	qui sum `indexm' [iw=`mweight'] if `treated'==0 & `support'==1 & `touse'
	scalar `mi0' = r(mean)
	scalar `vi0' = r(Var)
	scalar `ibiasaft'  = 100*(`mi1' - `mi0')/sqrt((`vi1' + `vi0')/2)
	scalar `iratioaft' = `vi1'/`vi0'
	return scalar Baft = `ibiasaft'
	return scalar Raft = `iratioaft'
	if (`ibiasaft'>=25) local starBaft "*"
	if !inrange(`iratioaft', 0.5, 2) local starRaft "*"

	if ("`rubin'"=="" & "`scatter'"=="") {
		di as text "{hline 11}{c TT}{hline 71}"
		di as text " Sample    {c |} Ps R2   LR chi2   p>chi2   MeanBias   MedBias      B      R     %Var"
		di as text "{hline 11}{c +}{hline 71}"
		di as text " Unmatched {c | }" as res %6.3f `r2bef' _s(1) as res %9.2f `chibef' _s(1) as res %8.3f `pchibef' _s(3) as res %6.1f `meanbiasbef' _s(4) as res %6.1f `medbiasbef' _s(4) as res %6.1f `ibiasbef' "`starBbef'" _col(70) as res %5.2f `iratiobef' "`starRbef'" _col(79) as res %3.0f 100*`cont_varbef'/`cont_cnt' 
		di as text " Matched   {c | }" as res %6.3f `r2aft' _s(1) as res %9.2f `chiaft' _s(1) as res %8.3f `pchiaft' _s(3) as res %6.1f `meanbiasaft' _s(4) as res %6.1f `medbiasaft' _s(4) as res %6.1f `ibiasaft' "`starBaft'" _col(70) as res %5.2f `iratioaft' "`starRaft'" _col(79) as res %3.0f 100*`cont_varaft'/`cont_cnt'
		di as text "{hline 11}{c BT}{hline 71}"
		di as text "* if B>25%, R outside [0.5; 2]"
	}

	if ("`rubin'"!="" | "`scatter'"!="") {
		di as text "{hline 11}{c TT}{hline 81}"
		di as text " Sample    {c |} Ps R2   LR chi2   p>chi2   MeanBias   MedBias      B       R    %concern  %bad"
		di as text "{hline 11}{c +}{hline 81}"
		di as text " Unmatched {c | }" as res %6.3f `r2bef' _s(1) as res %9.2f `chibef' _s(1) as res %8.3f `pchibef' _s(3) as res %6.1f `meanbiasbef' _s(4) as res %6.1f `medbiasbef' _s(4) as res %6.1f `ibiasbef' "`starBbef'" _col(70) as res %5.2f `iratiobef' "`starRbef'" _col(80) as res %3.0f 100*`cnt_concbef'/`i' _s(6) as res %3.0f 100*`cnt_badbef'/`i'  
		di as text " Matched   {c | }" as res %6.3f `r2aft' _s(1) as res %9.2f `chiaft' _s(1) as res %8.3f `pchiaft' _s(3) as res %6.1f `meanbiasaft' _s(4) as res %6.1f `medbiasaft' _s(4) as res %6.1f `ibiasaft' "`starBaft'" _col(70) as res %5.2f `iratioaft' "`starRaft'" _col(80) as res %3.0f 100*`cnt_concaft'/`i' _s(6) as res %3.0f 100*`cnt_badaft'/`i' 
		di as text "{hline 11}{c BT}{hline 81}"
		di as text "* if B>25%, R outside [0.5; 2]"
	}

	
	if ("`graph'"!="") {
		qui count if `xvar'!=""
		if r(N) > 30 {
			local nolabelx "label(nolabel)"
		}
		graph dot `_bias0' `_biasm', over(`xvar', sort(1) descending `nolabelx') legend(pos(5) ring(0) col(1) lab(1 "Unmatched") lab(2 "Matched")) yline(0, lcolor(gs10)) marker(1, mcolor(black)  msymbol(O)) marker(2, mcolor(black)  msymbol(X))  ytitle("Standardized % bias across covariates") `options'
	}

	if "`hist'"!="" {
		tempname grbef graft
		qui sum `_bias0'
		local bnd = round(max(-r(min), r(max)), 4)
		local stp = `bnd'/4
		qui histogram `_bias0', xlab(-`bnd'(`stp')`bnd') xtitle("Standardized % bias across covariates") title("Unmatched") `options'  saving(`grbef'.gph , replace) nodraw
		qui histogram `_biasm', xlab(-`bnd'(`stp')`bnd') xtitle("Standardized % bias across covariates") title("Matched")   `options'  saving(`graft'.gph , replace) nodraw  
		qui graph combine `grbef'.gph `graft'.gph, xsize(6) ysize(7) col(1) scheme(s1mono) ycommon
		qui erase `grbef'.gph
		qui erase `graft'.gph
	}

	if ("`scatter'"!="") {
		tempname grbef graft
		qui sum `_bias0'
		local bnd = round(max(-r(min), r(max)), 4)
		local stp = `bnd'/4
		qui scatter `_vratio_bef' `_bias0', xline(0, lw(medthick) lc(gs5)) yline(1, lw(medthick) lc(gs5)) yline(0.8 1.25, lp(dash) lw(medium) lc(gs5))  yline(0.5 2, lp(dot) lw(medium) lc(gs5)) xlab(-`bnd'(`stp')`bnd') ylab(0(0.5)2) ytitle("Variance ratio of residuals") xtitle("Standardized % bias") title("Unmatched") `options'  saving(`grbef'.gph , replace) nodraw
		qui scatter `_vratio_aft' `_biasm', xline(0, lw(medthick) lc(gs5)) yline(1, lw(medthick) lc(gs5)) yline(0.8 1.25, lp(dash) lw(medium) lc(gs5))  yline(0.5 2, lp(dot) lw(medium) lc(gs5)) xlab(-`bnd'(`stp')`bnd') ylab(0(0.5)2) ytitle("Variance ratio of residuals") xtitle("Standardized % bias") title("Matched")   `options'  saving(`graft'.gph , replace) nodraw
		qui graph combine `grbef'.gph `graft'.gph, xsize(6) ysize(7) col(1) scheme(s1mono) ycommon
		qui erase `grbef'.gph
		qui erase `graft'.gph
	}

	return local exog = "`varlist'"

	
end

/* ************************************************************************************************************************************* */

program define breduc1, rclass
syntax varlist(min=1 fv) , [ RAW MWeight(varname) TReated(varname) SUPport(varname) touse(varname) NOTable DISt LABel ONLYsig GRaph HIST SCatter options(string) RUBin]

	tempvar sumbias _bias xvar _vratio 
	tempname Flow Fhigh

	qui count if `treated'==1 & `support'==1 & `touse'
	scalar `Flow'  = invF(r(N)-1, r(N)-1, 0.025)
	scalar `Fhigh' = invF(r(N)-1, r(N)-1, 0.975)
	
	qui g `_bias' = .
	qui g str12 `xvar' = ""
	qui g `sumbias' = .
	qui g `_vratio' =.

	if "`notable'"!="" {
		local quietly "quietly"
	}
	
	fvexpand `varlist'	
	local hasfactorvars = ("`=r(fvops)'" == "true")
	local vnames `r(varlist)'
	local vlength 22
	foreach v of local vnames {
		local vlength = max(`vlength', length("`v'"))
	}
	
	/* construct header */
	local c = `vlength' + 2
	if ("`rubin'"!="" | "`scatter'"!="") {
		local add "_e"
	}
	
	`quietly' di
	`quietly' di as text "{hline `c'}{c TT}{hline 26}{c TT}{hline 15}{c TT}{hline 10}"
	`quietly' di as text "        " _col(`c') " {c |}       Mean               {c |}     t-test    {c |}  V`add'(T)/"  
	`quietly' di as text "Variable" _col(`c') " {c |} Treated Control    %bias {c |}    t    p>|t| {c |}  V`add'(C)"
	`quietly' di as text "{hline `c'}{c +}{hline 26}{c +}{hline 15}{c +}{hline 10}"

	/* get linear index and some overall stats for later*/
	tempvar index
	tempname r2 chi pchi 
	qui probit `treated' `varlist' [iw=`mweight'] if `support'==1 & `touse'
	qui predict double `index' if e(sample), xb
	scalar `r2' = e(r2_p)
	scalar `chi' = e(chi2)
	scalar `pchi' = chi2tail(e(df_m), e(chi2))
	return scalar r2 = e(r2_p)
	return scalar chiprob = chi2tail(e(df_m), e(chi2)) 

	/* calculate stats for varlist */
	tempname m1m m0m v1u v0u biasm t p meanbias medbias var1 var0 v_ratio v_e_1
	tempvar resid0 resid1
	local cnt_conc = 0  /* counting vars with ratio of concern - rubin */
	local cnt_bad  = 0  /* counting vars with bad ratio - rubin */
	local cont_cnt = 0  /* counting continuous vars */
	local cont_var = 0  /* counting continuous vars w/ excessive var ratio*/
	local i 0
	fvrevar `varlist'
	foreach v in `r(varlist)' {
		local ++i 
		local xlab : word `i' of `vnames'
		if (regexm("`xlab'", ".*b[\\.].*") == 1) continue

		if (`hasfactorvars'==0 & "`label'" != "") {
			local xlab : var label `v'
			if ("`xlab'" == "") local xlab `v'
		}

		qui sum `v' if `treated'==1 & `touse'
		scalar `v1u' = r(Var)

		qui sum `v' if `treated'==0 & `touse'
		scalar `v0u' = r(Var)

		qui sum `v' [iw=`mweight'] if `treated'==1 & `support'==1 & `touse'
		scalar `m1m' = r(mean)
		scalar `var1' = r(Var)
		
		qui sum `v' [iw=`mweight'] if `treated'==0 & `support'==1 & `touse'
		scalar `m0m' = r(mean)
		scalar `var0' = r(Var)
		
		scalar `v_ratio' = .
		local star ""
		
		if ("`rubin'"=="" & "`scatter'"=="") {
			capture assert `v'==0 | `v'==1 | `v'==., fast
			if (_rc) {
				local cont_cnt = `cont_cnt' +1
				/* get Var ratio */
				scalar `v_ratio' = `var1'/`var0' 
				if `v_ratio'>`Fhigh'  | `v_ratio'<`Flow' {
					local cont_var = `cont_var' +1
					local star "*"
				}
			}
		}
		
		if ("`rubin'"!="" | "`scatter'"!="") {
			cap drop `resid1'
			cap drop `resid0'
			qui regress `v' `index' [iw=`mweight'] if `treated'==1 & `support'==1 & `touse'
			qui predict double `resid1' if e(sample), resid
			qui regress `v' `index' [iw=`mweight'] if `treated'==0 & `support'==1 & `touse' 
			qui predict double `resid0' if e(sample), resid
			qui sum `resid1' [iw=`mweight'] 
			scalar `v_e_1' = r(Var)
			qui sum `resid0' [iw=`mweight'] 
			scalar `v_ratio' = `v_e_1'/r(Var)
			qui replace `_vratio' = `v_ratio' in `i'
			if (`v_ratio'>1.25 & `v_ratio'<=2) | (`v_ratio'<0.8 & `v_ratio'>=0.5) {	  
				local cnt_conc = `cnt_conc' +1
				local star "*"
			}
			if (`v_ratio'>2 & `v_ratio'<.) | `v_ratio'<0.5 {	 
				local cnt_bad = `cnt_bad' +1
				local star "**"
			}
		}
		
		qui replace `xvar' = "`v'" in `i'
		
		/* standardised % bias after matching */
		scalar `biasm' = 100*(`m1m' - `m0m')/sqrt((`v1u' + `v0u')/2)
		qui replace `_bias' = `biasm' in `i'
		qui replace `sumbias' = abs(`biasm') in `i'

		/* t-tests after matching */
		qui regress `v' `treated' [iw=`mweight'] if `support'==1 & `touse'
		scalar `t' = _b[`treated']/_se[`treated']
		scalar `p' = 2*ttail(e(df_r), abs(`t'))

		if ("`onlysig'" != "" & `p' >= 0.10) continue
		local c = `vlength' + 2
		`quietly' di as text %-`vlength's substr("`xlab'",1, `vlength') _col(`c') " {c |}" as result %7.0g `m1m' "  " %7.0g `m0m' "  " %7.1f `biasm' as text " {c |}"  as res %7.2f `t'  _s(2) as res %05.3f `p' as text " {c |}"  as res %6.2f `v_ratio' "`star'"
		
	}
	`quietly' di as text "{hline `c'}{c BT}{hline 26}{c BT}{hline 15}{c BT}{hline 10}"
	if ("`rubin'"=="" & "`scatter'"=="") {
		`quietly' di as text "* if variance ratio outside [" %4.2f `Flow' "; " %4.2f `Fhigh' "]"
	}
	if ("`rubin'"!="" | "`scatter'"!="") {
		`quietly' di as text "*  if 'of concern', i.e. variance ratio in [0.5, 0.8) or (1.25, 2]"
		`quietly' di "** if 'bad', i.e. variance ratio <0.5 or >2 "
	}
	di ""
	
	local quietly ""
	if "`dist'"=="" {
		local quietly "quietly"
	}
	`quietly' di as text "{hline 61}"
	label var `sumbias' "Summary of the distribution of |bias|"
	`quietly' sum `sumbias', detail
	scalar `meanbias' = r(mean)
	scalar `medbias'  = r(p50)
	return scalar meanbias = r(mean)
	return scalar medbias  = r(p50)		
	`quietly' di as text "{hline 61}"
	`quietly' di 

	// Rubin's stats
	// Rubin's B = absolute standardized differences of means of the linear index of the propensity score  
	tempname mi1 vi1 mi0 vi0 iratio ibias 
	qui sum `index' [iw=`mweight'] if `treated'==1 & `support'==1 & `touse'
	scalar `mi1' = r(mean)
	scalar `vi1' = r(Var)
	qui sum `index' [iw=`mweight'] if `treated'==0 & `support'==1 & `touse'
	scalar `mi0' = r(mean)
	scalar `vi0' = r(Var)
	scalar `ibias' = 100*(`mi1' - `mi0')/sqrt((`vi1' + `vi0')/2)
	// Rubin's R = ratio of treated to non-treated variance of the propensity score index
	scalar `iratio' = `vi1'/`vi0'
	return scalar B = `ibias'
	return scalar R = `iratio'
	if (`ibias'>=25) local starB "*"
	if !inrange(`iratio', 0.5, 2) local starR "*"

	
	if ("`rubin'"=="" & "`scatter'"=="") {
		di as text "{hline 70}"
		di as text "Ps R2   LR chi2   p>chi2   MeanBias   MedBias      B       R     %Var "
		di as text "{hline 70}"
		di as text as res %5.3f `r2' _s(1) as res %9.2f `chi' _s(1) as res %8.3f `pchi' _s(3) as res %6.1f `meanbias' _s(4) as res %6.1f `medbias'  _s(4) as res %6.1f `ibias' "`starB'" _s(3) as res %5.2f `iratio' "`starR'" _col(67) as res %3.0f 100*`cont_var'/`cont_cnt' 
		di as text "{hline 70}"
		di as text "* if B>25%, R outside [0.5; 2]"
	}

	if ("`rubin'"!="" | "`scatter'"!="") {
		di as text "{hline 81}"
		di as text "Ps R2   LR chi2   p>chi2   MeanBias   MedBias      B       R    %concern   %bad"
		di as text "{hline 81}"
		di as text as res %5.3f `r2' _s(1) as res %9.2f `chi' _s(1) as res %8.3f `pchi' _s(3) as res %6.1f `meanbias' _s(4) as res %6.1f `medbias'  _s(4) as res %6.1f `ibias' "`starB'" _s(3) as res %5.2f `iratio' "`starR'" _col(68) as res %3.0f 100*`cnt_conc'/`i'  _s(6) as res %3.0f 100*`cnt_bad'/`i' 
		di as text "{hline 81}"
		di as text "* if B>25%, R outside [0.5; 2]"
	}

	
	if "`graph'"!="" {
		qui count if `xvar'!=""
		if r(N) > 30 {
			local nolabelx "label(nolabel)"
		}
		graph dot `_bias', over(`xvar', sort(1) descending `nolabelx')  yline(0, lcolor(gs10)) marker(1, mcolor(black)  msymbol(O)) ytitle("Standardized % bias across covariates") `options'
	}

	if "`hist'"!="" {
		qui histogram `_bias', xtitle("Standardized % bias across covariates") `options'  
	}

	if ("`scatter'"!="") {
		qui scatter `_vratio' `_bias', xline(0, lw(medthick) lc(gs5)) yline(1, lw(medthick) lc(gs5)) yline(0.8 1.25, lp(dash) lw(medium) lc(gs5))  yline(0.5 2, lp(dot) lw(medium) lc(gs5)) ylab(0(0.5)2) ytitle("Variance ratio of residuals") xtitle("Standardized % bias")  `options'  
	}

	return local exog = "`varlist'"

end



program define plotvar
syntax varname, [RAW BOTH MWeight(varname) TReated(varname) SUPport(varname) touse(varname) DENSity BOX OUTlier options(string) ]

	capture assert `varlist'==0 | `varlist'==1 | `varlist'==., fast
	if (!_rc) {
		di as error "Error: you can't specify a dummy variable to be plotted with options " as input "density " as error "or " as input "box"
		exit 198
	}
	
	local Ytitle : var label `varlist'
	if ("`Ytitle'" == "")  local Ytitle `varlist'

	if ("`outlier'" == "") local nooutsides "nooutsides"
	
			
	if ("`density'"!="") {
		tempname grbef graft
		if ("`raw'"=="" & "`both'"=="")  {
			qui twoway (kdensity `varlist' if `touse' & `treated'==1 [aw=`mweight'], clwid(thick)) (kdensity `varlist' if `touse' & `treated'==0 [aw=`mweight'], clwid(thin) clcolor(black)), xlab(#6) xti("") yti("")  title("`Ytitle'") subtitle("Matched samples") legend(order(1 "Treated" 2 "Untreated")) graphregion(color(gs16))  `options' 
		}
		if ("`raw'"!="")  {
			qui twoway (kdensity `varlist' if `touse' & `treated'==1, clwid(thick)) (kdensity `varlist' if `touse' & `treated'==0, clwid(thin) clcolor(black)), xlab(#6) xti("") yti("")  title("`Ytitle'") legend(order(1 "`treated'==1" 2 "`treated'==0")) graphregion(color(gs16))  `options'  
		}
		if ("`both'"!="")  {
			qui twoway (kdensity `varlist' if `touse' & `treated'==1, clwid(thick)) (kdensity `varlist' if `touse' & `treated'==0, clwid(thin) clcolor(black)),  title("Unmatched") xlab(#6) ytitle("")  xtitle("") legend(off) saving(`grbef'.gph , replace) graphregion(color(gs16)) nodraw 
			qui twoway (kdensity `varlist' if `touse' & `treated'==1 [aw=`mweight'], clwid(thick)) (kdensity `varlist' if `touse' & `treated'==0 [aw=`mweight'], clwid(thin) clcolor(black)), title("Matched") xlab(#6) ytitle("")  xtitle("") legend(order(1 "Treated" 2 "Untreated")) saving(`graft'.gph , replace) graphregion(color(gs16)) nodraw  
	 		qui graph combine `grbef'.gph `graft'.gph, xsize(6) ysize(7) title("`Ytitle'") scheme(s1mono) col(1) xcommon `options'
			qui erase `grbef'.gph
			qui erase `graft'.gph
		}
	}
			
	if ("`box'"!="") {
		tempname grbef graft
		if ("`raw'"=="" & "`both'"=="")  {
			qui graph box `varlist' if `touse' [aw=`mweight'], over(`treated', sort(`treated') descending relabel(1 "Untreated" 2 "Treated")) `nooutsides' note("") yti("") title("`Ytitle'") subtitle("Matched samples") `options'
		}
		if ("`raw'"!="")  {
			qui graph box `varlist' if `touse', over(`treated', sort(`treated') descending relabel(1 "Untreated" 2 "Treated")) `nooutsides' note("") yti("") title("`Ytitle'")  `options'
		}
		if ("`both'"!="")  {
			qui graph box `varlist' if `touse', over(`treated', sort(`treated') descending relabel(1 "Untreated" 2 "Treated")) `nooutsides' note("") yti("") title("Unmatched") saving(`grbef'.gph , replace) nodraw 
			qui graph box `varlist' if `touse' [aw=`mweight'], over(`treated', sort(`treated') descending relabel(1 "Untreated" 2 "Treated")) `nooutsides' note("") yti("") title("Matched") saving(`graft'.gph , replace) nodraw 
	 		qui graph combine `grbef'.gph `graft'.gph, xsize(6) ysize(7) title("`Ytitle'") scheme(s1mono) col(1) xcommon `options'
			qui erase `grbef'.gph
			qui erase `graft'.gph
		}
	}

	
end


		
