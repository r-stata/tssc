*! version 2.1 of 5 January 2009
*! Modified regression test for funnel plot asymmetry in 2x2 tables
*! based on statistics of score test instead of Wald test.
*! Author: roger.harbord@bristol.ac.uk
*! Peters test (effect size on 1/N) added
*! updates added by Ross Harris


program define metabias, rclass byable(recall)
version 9.2
	syntax varlist(min=2 max=4 numeric) [if] [in] ///
	  [, Level(integer $S_level) z(name) v(name) noFit or rr EGGer BEGg PETers HARbord Graph * ]
	tokenize `varlist'

	// RJH check variables given and assign data_type
	if "`2'" == "" | ("`3'" != "" & "`4'" == ""){
		di as err "Must specify variables as either theta se_theta or binary data"
		exit 198
	}
	if "`4'" == ""{
		local theta `1'
		local se_theta `2'
		di ""
		di in gr "Note: data input format " _c
		di in ye "theta se_theta" _c
		di in gr " assumed."
		local data_type = "est"
	}
	if "`4'" != ""{
	/*                                 Args in same order as -metan-, i.e.:  */
		local se `1'								 /* Treatment group events */
		local fe `2'								 /* Treatment group failures */
		local sc `3'								 /* Control group events */
		local fc `4'								 /* Control group failures */
		di ""
		di in gr "Note: data input format " _c
		di in ye "tcases tnoncases ccases cnoncases" _c
		di in gr " assumed."
		local data_type = "bin"
	}
	// RJH end

	tempvar n V rootV Z ZoverrootV
	tempname pbias
	marksample touse

	// RJH error traps for method and data combinations
	if "`data_type'" == "bin" & "`or'" == "" & "`rr'" == ""{
		di in gr "Note: odds ratios assumed as effect estimate of interest"
		local or or
	}
	if "`or'" != "" & "`rr'" != ""{
		di as err "options or and rr cannot both be specified"
		exit 198
		}
	// check 1 test specified and only 1
	local numtest = 0
	foreach test in "`egger'" "`begg'" "`harbord'" "`peters'"{
		if "`test'" != ""{
			local numtest = `numtest'+1
		}
	}
	if `numtest' == 0 & "`data_type'" == "bin"{
		di as err "Must specify test: egger, begg, peters or harbord"
		exit 198
	}
	if `numtest' == 0 & "`data_type'" == "est"{
		di as err "Only Egger or Begg tests can be used with two input variables theta se_theta"
		exit 198
	}
	if `numtest' > 1{
		di as err "Can only specify one test (egger, begg, peters or harbord)"
		exit 198
	}

	// Galbraith plot not appropriate with Peters or Begg tests - does not match method
	if ("`peters'" != "" | "`begg'" != "") & "`graph'" != ""{
		di as err "graph option cannot be used with Peters and Begg tests"
		exit 198
	}
	// Z and V only with Harbord test
	if "`harbord'" == "" & ("`z'" != "" | "`v'" != ""){
		di as err "Options z() and v() only used for Harbord test"
		exit 198
	}

	if ("`egger'" != "" | "`begg'" != "") & "`data_type'" == "bin" {
		di in gr "Note: Peters or Harbord tests generally recommended for binary data"
		// change to theta se_theta
		tempvar theta se_theta
		// Below changed by RMH in v2.1 to call -metan- to ensure consistent handling of zero cells
		capture which metan
		if _rc != 0 {
			di as error "User-written package -metan- required but not found -"
			di as error "Please install, e.g. by typing -ssc install metan-"
			exit 111  // something not found - a command in this case 
		}
		qui metan `se' `fe' `sc' `fc' if `touse', `or' `rr' nograph notable
		qui gen `theta' = ln(_ES) if `touse'
		qui gen `se_theta' = _selogES if `touse'
		qui drop _SS _ES _selogES _LCI _UCI _WT
	}
	
	if "`egger'" == "" & "`begg'" == "" & "`data_type'" == "est" {
		di as err "Peters and Harbord tests cannot be used with data format theta se_theta"
		di as err "-egger test recommended"
		exit 198
	}
	// RJH end

	if "`graph'" == "" & "`options'" != "" {
		di as err "option `options' not allowed"
		exit 198
	}
	
	if "`graph'" != "" & _by() {
		di as err "option graph may not be combined with the by: prefix"
		exit 198
	}
	
	/* Check syntax */
	if `level' < 10 | `level' > 99 {
		di as error "level() must be between 10 and 99"
		exit 198
	}
	
	/// RJH
	if "`data_type'" == "bin" {
		capture assert `se'>=0 & `sc' >=0 & `fe'>=0 & `fc'>=0 if `touse'
		if _rc~=0 {
			di as error "All cell counts must be >=0"
			exit 459 // something that should be true of your data is not
		}
		/* Added by RMH in v2.1 */
		qui count if  ( `se'+`sc'==0 | `fe'+`fc'==0 | `se'+`fe'==0 | `sc'+`fc'==0 ) & `touse'
		if r(N) != 0 {
			local ies "ies"
			if r(N) == 1 local ies "y"
			di as txt "Note: excluding " as res r(N) /*
			*/ as text " non-informative stud`ies' with a zero marginal total"
		}

	}
	
	/* don't allow RR with Peters as unsure of weights */
	if "`rr'" != "" & "`peters'" != ""{
		di as error "Cannot use Peters test for risk ratios - appropriate weights not known"
		exit 198
	}
	/// RJH end


*********** TESTS ***********

*****************************************
	// Begin Harbord test
*****************************************
	if "`harbord'" != ""{
	
	display as text _n ///
	  "Harbord's modified test for small-study effects: "
	di as text "Regress Z/sqrt(V) on sqrt(V) where " /*
	*/   "Z is efficient score and V is score variance" _n

	qui gen `n'=`se'+`fe'+`sc'+`fc' if `touse'
	
	quietly {
		// RJH added rr, use or as default (checked previously that not both)

		if "`rr'" != ""{
			gen `V'= ((`sc'+`fc')*(`se'+`fe')*(`se'+`sc')) / (`n'*(`fe'+`fc')) if `touse'
			gen `Z'= (`se'*`n'-(`se'+`sc')*(`se'+`fe')) / (`fe'+`fc') if `touse'
		}
		else{
			gen `V'=(`se'+`fe')*(`sc'+`fc')*(`se'+`sc')*(`fe'+`fc') /*
			*/  / ( (`n')^2*(`n'-1) ) if `touse'
			gen `Z'=(`se'*`fc'-`sc'*`fe')/`n' if `touse'
		}
		gen `rootV'=sqrt(`V') if `touse'
		gen `ZoverrootV' = `Z'/`rootV' if `touse'
	}


	qui regress  `ZoverrootV' `rootV' if `touse', level(`level')
	scalar `pbias' = 2*ttail( e(df_r), abs(_b[_cons]/_se[_cons]) )
	return scalar rmse = e(rmse)
	return scalar p_bias = `pbias'
	return scalar se_bias = _se[_cons]
	return scalar bias = _b[_cons]
	return scalar df_r = e(df_r)
	return scalar N = e(N)

	matrix define vcov = e(V)
	matrix define b = e(b)
	matrix colnames vcov = sqrt(V) bias
	matrix rownames vcov = sqrt(V) bias
	matrix colnames b = sqrt(V) bias
	ereturn post b vcov, dep("Z/sqrt(V)") dof(`e(df_r)') obs(`e(N)')
	/* maybe prefer z-test?  In which case don't post dof. */
	di as txt "Number of studies = ", as res e(N) _c
	di as txt _col(55) " Root MSE      = ", as res %6.0g return(rmse)
	ereturn display, level(`level')

	di as text _n  "Test of H0: no small-study effects" /*
	*/  _col(45) "P = " as res %5.3f `pbias'


	if "`graph'" != "" {
preserve
		tempvar fitted lci uci obs1
		tempname cihw
		scalar `cihw' = _se[bias] * invttail( e(df_r), (1-`level'/100)/2 )
		if "`fit'" != "nofit" {
			nobreak {
				qui {
					set obs `= _N + 1'
					gen `obs1' = (_n == _N)
					replace `rootV' = 0 if `obs1'
					gen `lci' = _b[bias] - `cihw' if `obs1' 
					gen `uci' = _b[bias] + `cihw' if `obs1'
					gen `fitted' = _b[bias]+_b[sqrt(V)]*`rootV' if `touse'
					}
				twoway ///
				  ( scatter `ZoverrootV' `rootV',  ///
				  ytitle("Z / sqrt(V)") xtitle("sqrt(V)")  ///
				  yline(0, lc(fg)) ///
				  yla(-2 0 2) ///
				  `options'  ///
				  ) ///
				  ( line `fitted' `rootV', sort clsty(p2) ) ///
				  ( rcap `lci' `uci' `rootV', msize(*2) blsty(p2) ) ///
				  , legend( ///
				  label(1 "Study")  ///
				  label(2 "regression line") ///
				  label(3 "`level'% CI for intercept")  ///
				  order(1 2  - " " 3)  ///
				  )
				qui drop if `obs1'
				}
			}
		else {  // nofit
			twoway scatter `ZoverrootV' `rootV', yline(0, lc(fg)) ///
			  ytitle("Z/sqrt(V)") xtitle("sqrt(V)") `options'
			}
restore
		}
	
	/* output Z & V if requested */
	if "`z'"~="" & _bylastcall() {
		qui gen `z'=`Z' if `touse'
		label variable `z' "Efficient score"
		}
	if "`v'"~=""  & _bylastcall() {
		qui gen `v'=`V' if `touse'
		label variable `v' "Fisher's information"
		}

	} 	// end Harbord test


*****************************************
	// RJH added- Peter's test
*****************************************
	if "`peters'" != ""{

	tempvar theta ovN wgt prec_lnodds
	if "`rr'" != ""{
		di in gr "Note: test is formulated in terms of odds ratios" _n ///
			   "      but should give valid results for risk ratios"
		qui gen `theta' = ln( (`se'/(`se'+`fe')) / (`sc'/(`sc'+`fc')) ) if `touse'
	}
	else{
		qui gen `theta' = ln( (`se'/`fe') / (`sc'/`fc') ) if `touse'
	}
	gen `ovN' = 1/(`se'+`fe'+`sc'+`fc') if `touse'
	gen `wgt' = (`se'+`sc')*(`fe'+`fc')/(`se'+`sc'+`fe'+`fc')
// from http://www.rss.org.uk/pdf/Jaime%20Peters%20Presentation.pdf
// weight is the same- should weight be different for RR?
*	gen `prec_lnodds'= 1/(1/(`se'+`sc') + 1/(`fe'+`fc'))
	di _n "Peter's test for small-study effects:"
	di "Regress intervention effect estimate on 1/Ntot, with weights S×F/Ntot" _n

	qui regress `theta' `ovN' [aweight=`wgt'], noheader
	capture matrix b = get(_b)
	scalar `pbias' = 2*ttail( e(df_r), abs(_b[`ovN']/_se[`ovN']) )
	return scalar rmse = e(rmse)
	return scalar p_bias = `pbias'
	return scalar se_bias = _se[`ovN']
	return scalar bias = _b[`ovN']
	return scalar df_r = e(df_r)
	return scalar N = e(N)

	matrix V = get(VCE)
	local obs = e(N)
	local df = `obs' - 2
	matrix colnames b = bias constant
	matrix rownames V = bias constant
	matrix colnames V = bias constant
	matrix post b V, dep(Std_Eff) dof(`df') obs(`obs')
	di as txt "Number of studies = ", as res e(N) _c
	di as txt _col(55) " Root MSE      = ", as res %6.0g return(rmse)	
	matrix mlout, level(`level')

	di as text _n  "Test of H0: no small-study effects" /*
	*/  _col(45) "P = " as res %5.3f `pbias'

	}	// end Peters test


*****************************************
	// RJH added- original Egger test
*****************************************
	if "`egger'" != ""{

	di in gr _n "Egger's test for small-study effects:"
	di "Regress standard normal deviate of intervention"
	di "effect estimate against its standard error" _n
	
	tempvar prec snd
	qui gen `prec'= 1 / `se_theta'
	qui gen `snd' = `theta' / `se_theta'
	qui regr `snd' `prec' if `touse'
	capture matrix b = get(_b)
	scalar `pbias' = 2*ttail( e(df_r), abs(_b[_cons]/_se[_cons]) )
	return scalar rmse = e(rmse)
	return scalar p_bias = `pbias'
	return scalar se_bias = _se[_cons]
	return scalar bias = _b[_cons]
	return scalar df_r = e(df_r)
	return scalar N = e(N)

	matrix V = get(VCE)
	local obs = e(N)
	local df = `obs' - 2
	matrix colnames b = slope bias
	matrix rownames V = slope bias
	matrix colnames V = slope bias
	matrix post b V, dep(Std_Eff) dof(`df') obs(`obs')
	di as txt "Number of studies = ", as res e(N) _c
	di as txt _col(55) " Root MSE      = ", as res %6.0g return(rmse)
	matrix mlout, level(`level')

	di as text _n  "Test of H0: no small-study effects" /*
	*/  _col(45) "P = " as res %5.3f `pbias'

	if "`graph'" != "" {
preserve
		tempvar fitted lci uci obs1
		tempname cihw
		scalar `cihw' = _se[bias] * invttail( e(df_r), (1-`level'/100)/2 )
		if "`fit'" != "nofit" {
			nobreak {
				qui {
					set obs `= _N + 1'
					gen `obs1' = (_n == _N)
					replace `prec' = 0 if `obs1'
					gen `lci' = _b[bias] - `cihw' if `obs1' 
					gen `uci' = _b[bias] + `cihw' if `obs1'
					gen `fitted' = _b[bias]+_b[slope]*`prec' if `touse'
					}
				twoway ///
				  ( scatter `snd' `prec',  ///
				  ytitle("SND of effect estimate") xtitle("Precision") ///
				  yline(0, lc(fg)) ///
				  yla(-2 0 2) ///
				  `options'  ///
				  ) ///
				  ( line `fitted' `prec', sort clsty(p2) ) ///
				  ( rcap `lci' `uci' `prec', msize(*2) blsty(p2) ) ///
				  , legend( ///
				  label(1 "Study")  ///
				  label(2 "regression line") ///
				  label(3 "`level'% CI for intercept")  ///
				  order(1 2  - " " 3)  ///
				  )
				qui drop if `obs1'
				}
			}
		else {  // nofit
			twoway scatter `snd' `prec' , yline(0, lc(fg)) ///
			  ytitle("SND of effect estimate") xtitle("Precision") `options'
		}
restore
	}


	}	// end Egger test




*****************************************
	// RJH added- Begg test
*****************************************
	if "`begg'" != ""{


  qui {

tempname k ks sdks p zu pcc zcc c sks svks sk oe sbv sv
tempvar var w sw vt wtheta swtheta Ts wl swl RRm oe
    gen  `var'     = `se_theta'^2 if `touse'
    gen  `w'       = 1/`var' if `touse'
    egen `sw'      = sum(`w') if `touse'
    gen  `vt'      = `var' - 1 / `sw' if `touse'
    gen  `wtheta'  = `w' * `theta' if `touse'
    egen `swtheta' = sum(`wtheta') if `touse'
    gen  `Ts'      = (`theta' - `swtheta' / `sw') / sqrt(`vt') if `touse'
    gen  `wl'      = `w' * `theta' if `touse'
    egen `swl'     = sum(`wl') if `touse'
    gen  `RRm'     = `swl' / `sw' if `touse'
    scalar `oe'    = `RRm'

    } 	// end quietly

  qui capture ktau2 `var' `Ts' if `touse'
  if _rc == 0 {
    scalar `k'    = $S_1
    scalar `ks'   = $S_4
    scalar `sdks' = $S_5
    scalar `p'    = $S_6
    scalar `zu'   = $S_7
    scalar `pcc'  = $S_8
    scalar `zcc'  = $S_9
    scalar `c'    = $S_10
    }
  else if _rc == 2001 {
    scalar `k'    = `data'
    scalar `ks'   = .
    scalar `sdks' = .
    scalar `p'    = .
    scalar `zu'   = .
    scalar `pcc'  = .
    scalar `zcc'  = .
    scalar `c'    = .
    }
  else { 
    di in re "error " _rc " in call to ktau2" 
    exit 
  }

    di _n in gr "Begg's test for small-study effects:"
    di "Rank correlation between standardized intervention effect and its standard error"
    di " "
    di    in gr "  adj. Kendall's Score (P-Q) = " in ye %7.0f `ks'
    di _c in gr "          Std. Dev. of Score = " in ye %7.2f `sdks'
    if `c' == 1 { 
	di in gr " (corrected for ties)" 
	}
    else {
		di " "
	}
    di    in gr "           Number of Studies = " in ye %7.0f `k'
    di    in gr "                          z  = " in ye %7.2f `zu'
    di    in gr "                    Pr > |z| = " in ye %7.3f `p'
    di _c in gr "                          z  = " in ye %7.2f `zcc'
    di    in gr " (continuity corrected)"
    di _c in gr "                    Pr > |z| = " in ye %7.3f `pcc'
    di    in gr " (continuity corrected)"

return scalar p_bias_ncc   = `p'
return scalar p_bias = `pcc'
return scalar score_sd = `sdks'
return scalar score    = `ks'
return scalar N        = `k'


	}	// end Begg test


end




****************************************************
* 	ktau program from original metabias -RJH	   *
****************************************************

*! version 4.1.0  26sep97 TJS
*  modification of ktau to allow N==2, un-continuity-corrected
*  z and p values, and to pass more parameters
program define ktau2
	version 4.0
     local varlist "req ex min(2) max(2)"
     local if "opt"
     local in "opt"
     parse "`*'"
	parse "`varlist'", parse(" ")
     local x "`1'"
     local y "`2'"
	tempname k N NN pval score se tau_a tau_b
	tempname xt xt2 xt3 yt yt2 yt3
	tempvar doit nobs order work
	mark `doit' `in' `if'
	markout `doit' `x' `y'
	quietly count if `doit'
	scalar `N' = _result(1)
     if `N' < 2 { error 2001 } 
	local Nmac = `N'
	quietly {
		gen long `order' = _n  /* restore ordering at end */
		replace `doit' = -`doit'
		sort `doit'  /* put obs for computation first */
		gen double `work' = 0  /* using type double is fastest */
          scalar `k' = 2
          while (`k' <= `N') {
			local kk = `k' - 1
			#delimit ;
			replace `work' = `work'
				+ sign((`x' - `x'[`k'])*(`y' - `y'[`k']))
				in 1/`kk' ;  /* using "in" is fastest */
			#delimit cr
                       	scalar `k' = `k' + 1
                }
		replace `work' = sum(`work') in 1/`Nmac'
		scalar `score' = `work'[`N']
	/* Calculate ties on `x' */
		egen long `nobs' = count(`x') in 1/`Nmac', by(`x')
          tempvar nobsxm
          egen `nobsxm' = max(`nobs')
	/* Calculate correction term for ties on `x' */
		replace `work' = sum((`nobs' - 1)*(2*`nobs' + 5)) in 1/`Nmac'
		scalar `xt' = `work'[`N']
	/* Calculate correction term for pairs of ties on `x' */
		replace `work' = sum(`nobs' - 1) in 1/`Nmac'
		scalar `xt2' = `work'[`N']
	/* Calculate correction term for triplets of ties on `x' */
		replace `work' = sum((`nobs' - 1)*(`nobs' - 2)) in 1/`Nmac'
		scalar `xt3' = `work'[`N']
	/* Calculate ties on `y' */
		drop `nobs' 
		egen long `nobs' = count(`y') in 1/`Nmac', by(`y')
          tempvar nobsym
          egen `nobsym' = max(`nobs')
	/* Calculate correction term for ties on `y' */
		replace `work' = sum((`nobs' - 1)*(2*`nobs' + 5)) in 1/`Nmac'
		scalar `yt' = `work'[`N']
	/* Calculate correction term for pairs of ties on `y' */
		replace `work' = sum(`nobs' - 1) in 1/`Nmac'
		scalar `yt2' = `work'[`N']
	/* Calculate correction term for triplets of ties on `y' */
		replace `work' = sum((`nobs' - 1)*(`nobs' - 2)) in 1/`Nmac'
		scalar `yt3' = `work'[`N']
	/* Compute Kendall's tau-a, tau-b, s.e. of score, and pval */
		scalar `NN'    = `N'*(`N' - 1)
		scalar `tau_a' = 2*`score'/`NN'
		scalar `tau_b' = 2*`score'/sqrt((`NN' - `xt2')*(`NN' - `yt2'))
		#delimit ;
          scalar `se' = `NN'*(2*`N' + 5);
          tempname tmax;
          scalar `tmax' = max(`nobsxm', `nobsym');
          if `tmax' > 1 { scalar `se' = `se' 
                          - (`xt' - `yt')
                          + `xt3'*`yt3'/(9*`NN'*(`N' - 2))
                          + `xt2'*`yt2'/(2*`NN') } ;
          scalar `se' = sqrt((1/18)*`se');
		#delimit cr
		local zcc = (abs(`score') - 1) / `se'
          local z = `score '/ `se'
          tempname pvalcc
		if `score' == 0 {
             scalar `pval' = 1
             scalar `pvalcc' = 1 
          }
		else scalar `pvalcc' = 2*(1 - normprob((abs(`score') - 1)/`se'))
		else scalar `pval' = 2*(1 - normprob(abs(`score')/`se'))
	/* Restore original ordering of data set */
		sort `order'
	}
/* Print results */
	#delimit ;
       	di _n
		in gr "  Number of obs = " in ye  %7.0f `N' _n
        	in gr "Kendall's tau-a = " in ye %12.4f `tau_a' _n
        	in gr "Kendall's tau-b = " in ye %12.4f `tau_b' _n
        	in gr "Kendall's score = " in ye  %7.0f `score' _n 
        	in gr "    SE of score = " in ye %11.3f `se' _c ;
	if `xt2' > 0 | `yt2' > 0 { di in gr "   (corrected for ties)" _c } ;
       	di _n(2)
		in gr "Test of Ho: `x' and `y' independent" _n
          in gr "             z  = " in ye %12.2f `z' _n
       	in gr "       Pr > |z| = " in ye %12.4f = `pval' _n(2)
          in gr "             z  = " in ye %12.2f sign(`score')*`zcc' _n
       	in gr "       Pr > |z| = " in ye %12.4f = `pvalcc'
		in gr "  (continuity corrected)" ;
	#delimit cr
     local c = 0
     if `xt2' > 0 | `yt2' > 0 {
		local c = 1
	}
	global S_1 = `N'
	global S_2 = `tau_a'
	global S_3 = `tau_b'
	global S_4 = `score'
	global S_5 = `se'
	global S_6 = `pval'
	global S_7 = `z'
     global S_8 = `pvalcc'
     global S_9 = `zcc'
     global S_10 = `c'


end


exit


