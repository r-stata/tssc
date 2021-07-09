*! xtspecialreg  cfb 25aug2016 cloned from sspecialreg.ado 1.1.7 

/*
Per Arthur's msg 16sep2015: must do special regression transformation of depvar, then run
standard panel estimator on (within-)transformed data.
Apply that transformation to depvar separately for each time period before invoking
within estimator.
Create _xtspecialreg.ado along same lines as this routine.
*/

capt prog drop xtspecialreg 
program define xtspecialreg, eclass
version 11.0
syntax varlist(numeric min=2 max=2)  [if] [in], ENDOG(string) IV(string) ///
              [EXOG(string) HETERO HETV(string) KDENS WINSOR TRIM(real 2.5) BS BSREPS(integer 10)] 

// require panel
	capt xtset
	if _rc != 0 {
		di as err _n "xtspecialreg requires data defined as panel"
		error 198
	}
// check for _kdens
	capt which _kdens
	if _rc != 0 {
		di as err _n "You must install the kdens package, via ssc install kdens"
		error 198
	}
// require endog and iv lists
// unabbreviate lists to deal with hyphens
	marksample touse
	unab endog: `endog'
	unab iv: `iv'
	if "`exog'" != "" {
		unab exog: `exog'
	}
	if "`hetv'" != "" {
		unab hetv: `hetv'
	}
	markout `touse' `endog' `iv' `exog' `hetv'
	loc D: word 1 of `varlist'
	loc V: word 2 of `varlist'
	su `D' if `touse', mean
	if (r(N) == 0) {
		error 2000
	}
	if (r(max) - r(min) == 0) {
		di as err _n "No variance in D!"
		error 198
	}
// use of hetv() implies hetero
	if "`hetv'" != "" {
		loc hetero hetero
	}
// validate trim option; default 2.5 pc
	if `trim' != 2.5 {
		if `trim' < 0 | `trim' > 99 {
		di as err "Invalid trim value: must be a percentage to be trimmed"
		error 198
		}
	}
// validate winsor option
	if "`winsor'" == "winsor" & `trim' == 0 {
		di as err "winsor option can only be used with trim > 0"
		error 198
	}
// logic for bs option
	if "`bs'" == "bs" {
		if `bsreps' <= 1 | `bsreps' > 250 {
			di as err "Invalid value for bsreps: must be 2-250"
			error 198
		}		
		loc nelt: word count `exog' `endog' 
		loc nelt = `nelt' + 2 // allow for V and constant
		loc bscalc
		forv i=1/`nelt' {
			loc bscalc "`bscalc' mfx`i'=r(mfx`i')"
		}
		tempname b Vee
		tempvar idclu
		loc het = cond("`hetero'" == "hetero", "hetero", "homo")
		loc kd = cond("`kdens'" == "kdens", "kdens", "nokdens")
		loc hv = cond("`hetv'" == "", "nohetv", "`hetv'")
		di as text _n "Computing bootstrap standard errors for marginal effects, `bsreps' bootstrap samples"
		qui xtset
		loc pv `r(panelvar)'
		loc tv `r(timevar)'
// Apr2018: generate as double to allow for large ID values
		qui g double `idclu' = `pv' 
// per Bryce Durgin @StataCorp, must xtset by the idcluster variable to deal with multiple copies of a panel
		qui xtset `idclu' `tv'
		qui bootstrap `bscalc', reps(`bsreps') cluster(`pv') idcluster(`idclu') dots: ///
		_xtspecialreg `varlist', touse(`touse') endog(`endog') iv(`iv') exog(`exog') ///
		 hetero(`het') hetv(`hv') kdens(`kd') trim(`trim') winsor(`winsor')
		mat `Vee' = e(V)  
// restore original xtset
		qui xtset `pv' `tv'
	}
// end bs logic

	tempvar vee uhat uhat2 sc sigmau duhat fuhat T dxb sigma h kd dk m num tlim ttrm mu uuhat fuuhat ssc
	tempname dxb0 em mfx bee 

// loop over time periods to produce transformed depvar
	qui xtset
	loc st = r(tmin)
	loc nd = r(tmax)
	loc del = r(tdelta)
	loc tvar = r(timevar)
	qui g double `vee' = .
	qui g double `uhat' = .
	qui g double `fuhat' = .
	qui g double `sc' = .
	forv t =`st'(`del')`nd' {
//	di as err "`t'"
// demean special regressor for each time period
	su `V' if `touse' & `tvar' == `t', mean
	qui replace `vee' = `V' - r(mean) if `touse' & `tvar' == `t' 

// regress demeaned special regressor on endog, exog, iv for each time period
	qui reg `vee' `exog' `endog' `iv' if `touse' & `tvar' == `t' 
	capt drop `uuhat'
	qui predict double `uuhat' if `touse' & `tvar' == `t', resid 
	qui replace `uhat' = `uuhat' if `touse' & `tvar' == `t'
//	su `uuhat' `uhat'

// create uhat depending on hetero option
	if "`hetero'" == "hetero" {
		capt drop `uhat2'
		qui gen double `uhat2'=`uhat'^2 if `touse'  & `tvar' == `t'
		qui reg `uhat2'  `endog' `exog' `iv' `hetv' if `touse'  & `tvar' == `t'
		capt drop `ssc'
		qui predict double `ssc' if `touse' & `tvar' == `t', xb
		qui replace `sc' = `ssc' if `touse' & `tvar' == `t'
		qui replace `uhat' = `uhat'/sqrt(abs(`sc')) if `sc' != 0 & `tvar' == `t'
	di as err "hetero"
	su `uhat'
	}
	
// compute kernel density estimator via Jann's _kdens if KDENS; otherwise use sorted data density
// estimator (Ben Jann's translation) per SimpleStata2010
	capt drop `fuuhat'
	if "`kdens'" == "kdens" {
		qui _kdens `uhat' if `touse' & `tvar' == `t', kernel(epanechnikov) at(`uhat') gen(`fuuhat') 
	} 
	else {
	qui ssortedfm `uhat' if `touse' & `tvar' == `t', gen(`fuuhat')	
	}
// zrnd inline
	quietly replace `fuhat' = ((abs(`fuuhat')>10^(-20))*`fuuhat')+ ///
	((1-(abs(`fuuhat')>10^(-20)))*10^(-20)*((2*(`fuuhat'>0))-1))  if `touse' & `tvar' == `t'

// end loop over time periods
}
// create T variable: this should be able to be done over all panels

	if "`hetero'" != "hetero" {
		qui gen `T' = (`D' - ( `vee' >= 0)) / `fuhat' if `touse'
		}
	else {  
		qui gen `T' =(`D' - ( `vee' >= 0)) / `fuhat' * sqrt(abs(`sc')) if `touse' 
	}

// apply trimming / winsorizing
	loc ptrim = 100 - `trim'
	qui egen `tlim' = pctile(abs(`T')), p(`ptrim')
	qui gen byte `ttrm' = cond((abs(`T') > `tlim'), ., 1) 
	if "`winsor'" != "winsor" {
		markout `touse' `ttrm'
		qui count if mi(`ttrm')	
		loc delta = r(N)
	} 
	else {
		qui replace `T' = cond(`T' > `tlim', `tlim', cond(`T' < -1*`tlim', -1*`tlim', `T'))
		qui count if abs(`T') == `tlim'
		loc delta = r(N)
	}
// end of mods to T
	 
	qui	su `T' if `touse'
	loc extreme = max(abs(r(min)), r(max))/r(sd)
	qui su `V' if `touse', detail
	di as text _n "Kurtosis of special regressor `V' = " %9.4f `r(kurtosis)' // " for N = " `r(N)' 
	if `r(kurtosis)' < 3 {
		di as err "Warning: kurtosis below that of N(0,1) = 3.0 may weaken validity of results"
	}
	loc action = cond("`winsor'"=="winsor", "winsorized", "trimmed")
	di as text _n "`delta' observations `action': max abs value of transformed variable = " %5.2f `extreme' " sigma" _n
	loc qq "qui"
//	loc qq = cond("`bs'" == "bs", "qui", "noi")

// special regression transformed depvar
// di as err _n "transformed:"
// su `T' if `touse'

// now apply within estimator to transformed depvar
	
    `qq'  xtivreg `T' `exog' (`endog' = `iv') if `touse', fe
	ereturn local depvar "`D'"
	if "`bs'" != "bs" {
		di as text _n "Panel instrumental variables regression" _col(52) "Number of obs = " as res %11.0f e(N)
		di as text _col(52) "Number of groups = " as res %8.0f e(N_g)
		loc wdf = e(df_m) - e(N_g)
		di as text _col(52) "Wald chi2(`wdf')  = " as res %11.2f e(chi2)
		di as text _col(52) "Prob > chi2   = " as res %11.4f chi2tail(`wdf', e(chi2))
//		di as text _col(55) "Root MSE      = " as res %8.3f e(rmse)
		ereturn display
		di as text "Instrumented : `e(instd)'"
		di as text "Instruments:   `e(insts)'"
	}
	qui predict double `dxb' if e(sample), xb
	qui replace `dxb' =`dxb' + `vee' if e(sample)

	qui su `dxb'
	loc k2 = r(N)
	qui g double `h' = 0.9 * r(sd) * r(N)^(-1/5)
	qui g double `m' = .
	mata: indfn("`dxb'", "`D'", "`h'", "`m'", "`touse'")
//	di _n "Mata indfn()"
	su `m' if `touse', mean
	
//  following rewritten in Mata indfn
/* 
//	forv j = 1/`k2' {
//		scalar `dxb0' = `dxb' in `j'
//		qui gen double `kd' = 0.75 * ( 1 - ((`dxb' - `dxb0') / `h' )^2) * (abs(( `dxb' - `dxb0') / `h' ) < 1 )
//		su `kd', mean
//		loc sumkd = r(sum)
//		qui g double `dk' = `D' * `kd'
//		su `dk', mean
//		qui sca `em' = r(sum) / `sumkd'
//	// should be 0.75 * 2 * Zt, not 0.75 * (1 + 2 Zt)
//	//	qui g double `num' = (`D' - `em') * ( 0.75 * (1 + 2 * (`dxb' - `dxb0') / `h') ) * (abs((`dxb' - `dxb0') / `h' ) < 1 )
//		qui g double `num' = (`D' - `em') * ( 0.75 * (2 * (`dxb' - `dxb0') / `h') ) * (abs((`dxb' - `dxb0') / `h' ) < 1 )
//		su `num', mean
//		qui replace `m' = r(sum) / (`h' * `sumkd') in `j'
//		cap drop `kd' `dk' `num' 
//	}
//	di _n "ado"
//	sum `m' // , mean
*/

	loc enn = r(N)
	matrix `mfx' = r(mean) * [ 1, e(b) ]'
	matrix colnames `mfx' = `D'
	loc en : colnames e(b)
	matrix rownames `mfx' = `V' `en'

	if "`bs'" == "bs" {
		mat `bee' = (`mfx')'
		matrix rownames `Vee' = `V' `en'
		matrix colnames `Vee' = `V' `en'
    	eret post `bee' `Vee', depname(`D') esample(`touse')
    	di "Average marginal effects from average index function"
    	eret display  
	}
	else {
		di as text _n "Average marginal effects from average index function"
		mat li `mfx', noheader
		eret matrix aif = `mfx'
	}
	eret local cmdname = "xtspecialreg"
	eret scalar N = `enn'
	eret local depvar `D'
	eret local endog `endog'
	eret local exog `exog'
	eret local iv `iv'
	eret scalar trim = `trim'
	eret local stat_cmd
	 
end

	version 11
	mata:
	void indfn(string scalar sdxb,
			   string scalar sd,
	           string scalar sh,
	           string scalar sm,
	           string scalar touse)
	{
		real scalar k2, j, zt, skd
		real colvector kd, em, num
		st_view(dxb, ., sdxb, touse)
		st_view(D, ., sd, touse)
		st_view(h, ., sh, touse)
		st_view(m, ., sm, touse)
		
		k2 = rows(dxb)
		kd = J(k2, 1, .)
		for(j=1; j<=k2; j++) {
			zt = (dxb :- dxb[j, 1]) :/ h
			kd =  0.75 :* ( 1 :- zt :^2) :* (abs(zt) :< 1 )
			skd = sum(kd)
			em = D :- sum(kd :* D) / skd
// correction: should be 0.75 * 2 Zt, not 0.75 * (1 + 2 Zt)
//			num = em :* ( 0.75 :* (1 :+ 2 :* zt) ) :* (abs(zt) :< 1 )
			num = em :* ( 1.5 :* zt) :* (abs(zt) :< 1 )
			m[j, 1] = sum(num) :/ (h[j, 1] :* skd ) 
		}
	}
	end
	exit
