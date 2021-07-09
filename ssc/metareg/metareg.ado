*! v2.6.1 Roger Harbord 4 Nov 2008
	
program define metareg, eclass byable(recall)
version 7
	if replay() {
		if "`e(cmd)'" !="metareg" {
			error 301 /* last estimates not found */
			}
		if _by() {
			error 190 /* request may not be combined with by */
			}
		Display `0'
		exit
		}

	syntax varlist(min=1 numeric) [if] [in] , [ /*
*/	  wsse(varname numeric) /*
*/   EForm                 /*
*/   NOCONStant            /*
*/   MM                    /*
*/   REML                  /*
*/   EB                    /*
*/   Knapphartung          /*
*/   z                     /* standard normal w/o K-H modification to variance
*/	  Level(passthru)       /*
*/	  PERMute(string)       /*
*/   Graph                 /* produce a bubble plot
*/   RAndomsize            /* marker size according to random-effects weights
*/   TAU2test              /* tests for tau2=0 residual het test
*/   LOg                   /* maximize_option
*/   TOLerance(real 1e-6)  /* maximize_option also used by eb method
*/   ITERate(integer 100)  /* maximize_option - default 16000 is too large!
*/   wsvar(varname numeric)/* undoc'd, for compat with v1 ( wsvar = wsse^2 )
*/   bsest(string)         /* undoc'd, for compat with v1
*/   tdist                 /* undoc'd, use t-distib w/o K-H variance mod'n
*/   ORIGinal              /* undoc'd, use version 1 (metareg_orig)
*/	  LRtau2                /* undoc'd, for compat with v.2.2 on SSC
*/   NOITer                /* passed through to metareg_orig
*/   NOTAUComp             /* no comparison of tau2 with constant-only model;
		                        for use by permute() option
*/   *                     /* other `options', parsed by -mlopts-
*/   ]

	marksample touse
	tokenize `varlist'
	local y `1'	/* study estimate */
	qui count if `touse'
	local nobs = r(N)
	if r(N) == 0 {
		error 2000  /* no observations */
		}
	if r(N) <= `: word count `*'' {
		error 2001 /* insufficient observations */
		}
	macro shift 1
	_rmcoll `*' if `touse', `noconstant'
	local xvars `r(varlist)'

	mlopts mlopts, `options' iterate(`iterate')  /* Parse  maximize_options */

	if "`wsse'"=="" & "`wsvar'"==""  {
		di as error "wsse() option required"
		exit 100
		}

	if "`wsse'"!="" & "`wsvar'"!="" {
		di as error "options wsse() and wsvar() cannot both be specified"
		exit 198
		}
	
	if "`wsse'"!="" {
		capture assert `wsse' > 0 if `touse'
		if _rc {
			di as error "zero or negative wsse() not allowed"
			exit 499
			}
		tempvar wsvar
		qui gen `wsvar' = `wsse'^2 if `touse'
		}

	if "`wsvar'"!="" { 
		capture assert `wsvar' > 0 if `touse'
		if _rc {
			di as error "zero or negative wsvar() not allowed"
			exit 499
			}
		}

	if "`noconstant'"!="" {
		/* 		local nvar : word count `varlist' */
		if `: word count `varlist'' == 1 {
			di as error "independent variables required with "  /*
*/			  "noconstant option"
			exit 102
			}
		}
	
	local wc : word count "`mm' `reml' `eb'"
	if `wc' > 1 {
		di as error "Only one of options mm, reml and eb can be specified"
		exit 198
		}
		
	local wc : word count "`mm' `reml' `eb' `bsest'"
	if `wc' > 1 {
		di as error "Option bsest() cannot be used with options  mm, reml or eb"
		exit 198
		}
		
	if "`bsest'"!="reml" & "`bsest'"!="ml" & "`bsest'"!="eb"  /*
*/	  & "`bsest'"!="mm" & "`bsest'"!="" {
		di as error "Between study variance estimation method invalid:"
		di as error  "should be either reml, ml, eb or mm"
		exit 198
		}

	if "`bsest'" == "" {
		if "`mm'" != ""  | "`permute'" != "" { /* MM is default with permute */
			local bsest "mm"
			}
		else if "`eb'" != "" {
			local bsest "eb"
			}
		else  {                               /* REML is default otherwise */
			local bsest "reml"
			}
		}

	if "`bsest'" =="ml" {
		di as text  /*
*/		  "Option bsest(ml) not supported by version 2 of metareg."
		di as text "Calling version 1.06 (sbe23):" _n(1)
		metareg_orig `0'
		exit
		}

	if "`knapphartung'" !="" & "`z'" != "" {
		di as error "Options knapphartung and z cannot both be specified"
		exit 198
		}

	if "`tdist'" != "" & ( "`z'" != "" | "`knapphartung'" !="" ) {
		di as error "Option t cannot be specified with options knapphartung or z"
		exit 198
		}

	if "`original'" =="original" {
		di as text "Calling metareg version 1.06 (sbe23):" _n(1)
		metareg_orig `0'
		exit
		}
	
	if "`log'"=="" { 
		local log "nolog"
		}

	if "`lrtau2'" != "" {
		local tau2test tau2test
		}
	
	if "`permute'" != ""  {
		if "`xvars'" == "" {
			di as error "Option permute() requires at least one covariate"
			exit 198
			}
		Permute, y(`y') xvars(`xvars') wsvar(`wsvar') permute(`permute') ///
		  nobs(`nobs') `noconstant'  ///
		  bsest(`bsest') `knapphartung' `z'  ///
		  level(`level') touse(`touse')
		exit
		}


	/*** begin main code ***/
	tempvar w hat v resid
	tempname remll_c remll sumw tau2 tau2mm b V Q df_Q tau2_0

	quietly {
		
		/** (get starting values using) method-of-moments **/
		gen `w'=1/`wsvar' if `touse'
		summ `w' if `touse', meanonly
		scalar `sumw'=r(sum)
		/* use regress not vwls so can predict hat */
		regress `y' `xvars'  [iw=`w'] if `touse', `noconstant'
		predict `hat' if `touse', hat
		/* H_ii where H = X(X'WX)^{-1}X', W=diag(w) */
		replace `hat'=`hat'*`w'^2  if `touse' /* Tr( WX(X'WX)^{-1}X'W ) */
		/* iweights mess up residual df so compute it  : */
		scalar `df_Q' = `nobs' - e(df_m) - ("`noconstant'" == "")
		scalar `Q' = e(rss)
		summ `hat' if `touse', meanonly
		scalar `tau2' = (`Q' - `df_Q') / ( `sumw' - r(sum))
		/* truncate at zero */
		scalar `tau2' = max(`tau2', 0)

		/* Fit constant-only model to compare tau2
		NB can't compare different fixed-effect models using REML log-L */
		if "`noconstant'" == "" & "`notaucomp'"=="" & "`xvars'" != "" {
			metareg `y' if `touse', wsvar(`wsvar') bsest(`bsest') notaucomp
			scalar `tau2_0' = e(tau2)
			}
		} /* end quietly */
	
	if "`bsest'" == "reml" {  /* *** REML start *** */
			
		global REML_x `xvars' /* betas not estimated by ml so pass X as global*/
		global REML_nocons `noconstant' /* have to pass as global too */

			/* fit comparison fixed-effect (tau2=0) model*/
			ml model d0 metareg_ll (`y' `wsvar' = ) /*
*/		     if `touse', maximize init(_cons=0) /*
*/		     search(off) iterate(0) nowarning nolog
			scalar `remll_c' = e(ll) /* log-L, comparison model */
		
		/* estimate tau2 using ml */
		local tau2mm = max(`tau2', 1e-4)  /* init doesn't work with scalar */
		ml model d0 metareg_ll (`y' `wsvar' = ) if `touse',/*
*/			  maximize  init(_cons=`tau2mm') search(off) nopreserve noscvars /*
*/			  `log' tolerance(`tolerance') `mlopts'

		if "`e(converged)'" != "1" {
			di as error "WARNING: REML estimation of tau2 failed to converge."
			di as error "Estimates may be wrong."
			di as error "Try adding mm option to use method-of-moments".
			}
		
		macro drop REML_x
		macro drop REML_nocons
		
		scalar `tau2' = max( _b[_cons], 0)
		if `tau2' > 0 {
			scalar `remll' = e(ll)
			}
		else {
			scalar `remll' = `remll_c'
			}
			
		}                   /*  REML end */
		
	if "`bsest'" == "eb" {  /* *** EB start *** */
		local oldtau2=-1
		local j=0

		while abs((`tau2'-`oldtau2')/(`oldtau2'+1e-8)) >= `tolerance' {
			local j = `j'+1
			tempvar wt ypred wtsq numi 
			local oldtau2=`tau2'
			qui {
				gen `wt'=(`wsvar'+`tau2')^-1 if `touse'
				regress `y' `xvars' [aw=`wt'] if `touse'
				predict `ypred' if `touse'
				gen `wtsq'=`wt'^2 if `touse'
				gen `numi'=(`wt')*(((e(N)/e(df_r))*((`y'-`ypred')^2))-`wsvar') if `touse'
				summ `numi' if `touse', meanonly
				local num=r(sum)
				summ `wt', meanonly
				local tau2=`num'/r(sum)
				}
			if "`log'" == "log" {
				di as txt  "Iteration " `j' ": tau^2 = " as res `tau2'
				}
			}
		local tau2 = max(`tau2',0)
		}                  /* EB end*/
	
	/** estimate final model by weighted LS **/
	quietly {
		gen `v' = `wsvar' + `tau2'
		regress `y' `xvars' [iw=1/`v'] if `touse', mse1 `noconstant'
		matrix `b' = e(b)
		matrix `V' = e(V)
		local df_m = e(df_m)

		/** knapp and hartung variance adjustment **/
		if "`z'" == "" & "`tdist'" == "" {
			tempname vkh
			predict `resid' if `touse', resid
			replace `resid' = `resid'*`resid' / `v' if `touse'
			summarize `resid' if `touse', meanonly
			local qkh =  r(sum) / `df_Q'
			matrix `V' = `V' * max(1, `qkh')
			}
		
		} /* end quietly */

	
	estimates post `b' `V', depname(`y') obs(`nobs') esample(`touse')
	estimates scalar tau2 = `tau2'
	estimates scalar df_m = `df_m'
	estimates scalar Q = `Q'
	estimates scalar df_Q = `df_Q'
	estimates scalar I2 = max( ( `Q' - `df_Q' ) / `Q', 0 )
	if "`z'" == ""  { /* post df_r so get t & F tests not z and chi2 */
		estimates scalar df_r = `df_Q'
		}
	if "`tdist'" =="" & "`z'" == "" {
		estimates scalar q_KH = `qkh'
		}
	if "`wsse'" == "" {
		estimates local wsvar "`wsvar'"
		}
	else {
		estimates local wsse "`wsse'"
		}

	if "`bsest'" == "mm" {
		estimates local method "Method of moments"
		}
	if "`bsest'" == "eb" {
		estimates local method "Empirical Bayes"
		}
	if "`bsest'" == "reml" {
		estimates local method "REML"
		/* return reml log-l in e(remll) NOT e(ll)
		to ensure can't do inappropriate lrtest of fixed effects */
		estimates scalar remll = `remll'
		if "`remll_c'" != "" {
			estimates scalar remll_c = `remll_c'
			if (e(remll) < e(remll_c)) | (`tau2' <= 0) {
				estimates scalar chi2_c = 0
				}
			else {
				estimates scalar chi2_c = 2*(e(remll)-e(remll_c))
				}
			}
		}

	if "`noconstant'" == "" & "`notaucomp'"=="" & "`xvars'" != "" {
		estimates scalar tau2_0 = `tau2_0'
		}

	/* overall F (or chi2) test */
	if "`xvars'" != "" {
		qui test `xvars'
		if "`r(chi2)'" != "" {
			estimates scalar chi2 = r(chi2)
			}
		else {
			estimates scalar F = r(F)
			}
		}
	
	estimates local predict "metareg_p"
	estimates local depvar "`y'"
	estimates local cmd "metareg"
	
	Display, `level' `eform' `tau2test'


	if "`graph'" != "" {
		if `: word count `xvars'' != 1 {
			di as error in smcl  ///
			  "graph option works only with a single {it:indepvar}"
			}
		else Graph `y' `xvars' `v' `w' `randomsize'
		}

end

program define Graph
	version 8.2
	args y xvars v w randomsize
	
	tempvar fit
	qui predict `fit'
	if "`randomsize'" == "" {
		local size `w'
		}
	else {
		local size 1/`v'
		}
	local yti : variable label `y'
	if "`yti'" == "" {
		local yti `y'
		}
	scatter `y' `xvars' [aw=`size'], msymbol(oh)  ///
	  || line `fit' `xvars', sort ///
	  ||, legend(off) ytitle( `yti')
	
end


program define Display
version 7
	syntax [, Level(int $S_level) EForm Tau2test q]
	tempname pval i2 
	if "`eform'" == "eform" {
		local eform eform(exp(b))
		}
	scalar `pval' = chi2tail(e(df_Q), e(Q))

	di as txt _n "Meta-regression"  /*
*/  _col(55) "Number of obs" _col(70) "= " as res %7.0f e(N)
	di as res "`e(method)'"  /*
*/	   as txt " estimate of between-study variance" /*
*/ _col(55) "tau2" _col(70) "=" as res %8.4g e(tau2)
	di as txt "% residual variation due to heterogeneity"  /*
*/	  _col(55) "I-squared_res" _col(70) "= "  as res %6.2f 100 * e(I2) "%" 


	if "`e(tau2_0)'" != "" {
		di as txt "Proportion of between-study variance explained" /*
*/    _col(55) "Adj R-squared "  _col(70) "= " _c
		di as res %6.2f 100 * ( 1 - e(tau2) / e(tau2_0)  ) "%"
		}
	
	/* Overall model fit */
	if e(df_m) > 1 {
		di as txt "Joint test for all covariates" _c
		if "`e(df_r)'" == "" {
			di as txt _col(55) "Model chi2(" as res e(df_m) as txt ")" /*
*/          _col(70) "= " as res %7.2f e(chi2)
			}
		else {
			di as txt _col(55) "Model F(" as res e(df_m) as txt "," /*
*/       as res e(df_r) as txt ")" _col(70) "= " /*
*/       as res %7.2f e(F)
			}
		}

	
	di  as res "With" _c
	if "`e(q_KH)'" == "" {
		di as res "out" _c
		}
	di as txt " Knapp-Hartung modification" _c

	if e(df_m) > 1 {
		if "`e(df_r)'" == "" {
			di as txt _col(55) "Prob > chi2" _col(70) "= " /*
*/			as res %7.4f chi2tail( e(df_m), e(chi2) )
			}
		else {
			di as txt _col(55) "Prob > F" _col(70) "= " /*
*/       as res %7.4f Ftail( e(df_m), e(df_r), e(F) )
			}
		}
	else {
		di /* end line */
		}
	

	estimates display, level(`level') `eform'

	if "`tau2test'" != "" {
		di as txt "Test for residual between-study variance (of tau2=0)"  /*
*/	    _col(55) "Q_res (" as res %1.0f e(df_Q) as txt " df)"  /*
*/	    _col(70) "= " as res %7.2f e(Q) 
		di as txt _col(55) "Prob > Q_res" _col(70) "= " as res %7.4f `pval'

		if "`e(method)'" == "REML"  {
			scalar `pval' =  chi2tail(1, e(chi2_c))*0.5
			if e(chi2_c) <=0 {
				scalar `pval'= 1
				}
			di in smcl as txt "Likelihood-ratio test of tau2=0: " /*
			*/ as txt "{help j_chibar:chibar2(01) =}" as res %6.2f e(chi2_c)  /*
			*/ as txt "  Prob > chibar2 = " as res %7.4f `pval'
			}

		}

end


program define Permute, rclass
version 7
	syntax, y(varname numeric) xvars(varlist numeric) wsvar(varname numeric) ///
	  permute(string) nobs(integer) [noconstant bsest(string) knapphartung z ///
	  level(passthru) touse(varname numeric)] 
	
	gettoken reps 0 : permute, parse(",")
	confirm integer number `reps'
	if `reps' < 1 {
		di as err "permute() must be a positive integer"
		exit 198
		}
		
	syntax [, Univariable  Detail Verbose  NOISily Joint(string) * ]

	if "`verbose'" != "" { /* verbose is undoc'd synonym for detail */
		local detail detail
		}

	if "`xvars'" == "" {
		di as error "permute() option not allowed when no covariates"
		exit 198
		}

	if "`joint'" != "" & "`univariable'" != "" {
		di as error "options univariable and joint() cannot both be specified"
		exit 198
		}
		
	if `:word count `xvars'' == 1 {
		local univariable /* ensure unset if only one xvar */
		}
	
	if "`univariable'" == "" {
		di as txt _n(1) "Monte Carlo permutation test for meta-regression"
		}
	else {
		di as txt _n(1) in smcl /*
*/			  "Monte Carlo permutation test for {it:single covariate} meta-regressions"
		}

	if "`bsest'" == "" {
		local bsest "mm" /* mm is default for permutation test */
		}
	if "`bsest'" == "mm" {
		di as res _n "Moment-based " _c 
		}
	else {
		di as res _n "REML " _c 
		}
	di as txt "estimate of between-study variance"

	if "`knapphartung'" == ""  {
		local z "z"  /* z is default for for permutation test  */
		di as res "Without " _c
		}
	else {
		di as res "With " _c
		}
	di as txt "Knapp & Hartung modification to standard errors"

		
	if "`noconstant'" != "" {
		di as error "Permutation test inappropriate with no constant"
		exit 198
		}

	local permopts `univariable' `noconstant' `bsest' `knapphartung' `z'
	
	preserve
	qui keep if `touse'

	foreach x of varlist `xvars' {
		local explist "`explist' `x'=r(z_`x')"
		local xlist "`xlist' `x'"
		}
		
	/* parse varlists in joint() option separated by \ / or | */
	local jt `joint'
	local nj 0
	while "`jt'" != "" {
		gettoken tmp jt : jt, parse("\/|")
		if strpos("\/|", "`tmp'")  {
			continue
			}
		local 0 `tmp'
		syntax varlist
		local nj = `nj' + 1
		local joint`nj' `varlist'
		di as txt "joint`nj' : " as res "`joint`nj''"
		local explistj "`explistj' joint`nj'=r(chi2`nj')"
		local jlist "`jlist' joint`nj'"
		}
		
	tempvar n
	qui gen `n' = _n if `touse'
		
	tempfile pm pmadj
	if "`noisily'" =="" {
		local quietly quietly
		/* quietly permute then replay (if detail specified)
		to suppress full -permute- header */
		}
	`quietly' permute `n' /* 
*/		  "metareg_pm `y' `wsvar' `n', xvars(`xvars') joint(`joint') `permopts'" /*
*/		  `explist' `explistj', /*
*/		reps(`reps') saving(`pm') replace `options'


	tempname R C P B
	matrix `R' = r(reps)
	matrix `C' = r(c)
	matrix `P' = `C' * inv(diag(`R'))

	local nx : word count `xvars'
	forvalues i = 1/`nx' {
		local minreps = min(`reps',`R'[1,`i'])
		}
	if `minreps' != `reps' {
		di as txt "WARNING: some permutations returned missing values" _c
		di as txt "See detail below:"
		local detail detail
		}

	/* to get adjusted p-values from -permute-,
		replace z-statistics by their largest absolute values
	for each permutation */
	quietly {
		use `pm', clear
		tempvar max
		gen `max' = 0
		foreach v of varlist `xlist' {
			replace `max' = abs(`v') if abs(`v') > `max'
			}
		foreach v of varlist `xlist' {
			replace `v' = `max'
			}
		drop `max'
		save `pmadj', replace
		permute `xlist' `jlist' using `pmadj', `level'
		} // end quietly

	matrix `B' = r(b)
	matrix `R' = `R' \ r(reps)
	matrix `C' = `C' \ r(c)
	matrix `P' = `P' \ r(c) * inv(diag(r(reps)))
	foreach M in `R' `C' `P' {
		matrix rownames `M' = unadj multadj
		if "`joint'" != "" {
			/* set matrix entries for adjusted joint tests (N/A) to missing */
			matrix `M'[2, colnumb(`M',"joint1")] = J(1,`nj',.)
			}
		}

	/* clear results from last permutation so not available to user */
	estimates clear
	restore
		
	/*** Display results of permutation test ****/

	if `nx' == 1 { /* only one xvar */
		local sep = sqrt(`P'[1,1]*(1-`P'[1,1])/`reps')
		if `sep' == 0 {
			local sep .
			}
		di as txt _n _col(9) "Number of obs =" as res %8.0f _N
		di as txt _col(9) "Permutations  =" as res %8.0f `reps'
		di in smcl as txt "{hline 13}{c TT}{hline 17}"
		di in smcl as txt  /*
*/			  %12s "`y'"  " {c |}" _s(1)  /*
*/			  %6s "p" _s(4) /*
*/			  %6s "SE(p)"
			
		di in smcl as txt "{hline 13}{c +}{hline 17}"
		di in smcl as txt /*
*/				  %12s abbrev(`"`xvars'"',10) /*
*/				  " {c |}" _s(2)  /*
*/				  as result %7.3f `P'[1,1] _s(1) /*
*/            as result %7.4f `sep'
		di in smcl as txt "{hline 13}{c BT}{hline 17}"
		}

	else {   /* more than one xvar */

		/* Table Head */
		di as txt _n "P-values unadjusted and adjusted for multiple testing"
		di as txt _n _col(14) "Number of obs =" as res %8.0f `nobs'
		di as txt _col(14) "Permutations  =" as res %8.0f `reps'
		di in smcl as txt "{hline 13}{c TT}{hline 22}"
		di in smcl as txt _s(13) "{c |}" _s(12) "P"
		di in smcl as txt  /*
*/			  %12s abbrev("`y'",10)  " {c |}"  /*
*/			  %11s "Unadjusted"  %11s "Adjusted"
		di in smcl as txt "{hline 13}{c +}{hline 22}"

		foreach x of local xvars {
			local i = `i' + 1
			di in smcl as txt /*
*/				  %12s abbrev(`"`x'"',10) /*
*/				  " {c |}" _s(4)  /*
*/				  as result %7.3f `P'[1,`i'] _s(4)  /*
*/				  %7.3f `P'[2,`i']
			}

		if "`joint'" != "" {
			di in smcl as txt "{hline 13}{c +}{hline 22}"
			forvalues j = 1/`nj' {
				di in smcl as txt /*
*/               %12s "joint`j'"  /*
*/				  " {c |}" _s(4)  /*
*/				  as result %7.3f `P'[1,`nx'+`j']
				}
			}
			
		/* Table Foot */
		di in smcl as txt "{hline 13}{c BT}{hline 22}"
		/* largest SE(p)  = sqrt( max( p(1-p)/n ) ) */
		local maxvarp 0
		forvalues i = 1/2 {
			forvalues j = 1/`=colsof(`P')'{
				local maxvarp = max( `maxvarp',  ///
				  `P'[`i',`j'] * (1 - `P'[`i',`j']) / `R'[`i',`j'] )
				}
			}
		if `maxvarp' == 0 {
			local maxvarp .
			}
		di as txt "largest Monte Carlo SE(P) ="  /*
*/			  as res %7.4f sqrt(`maxvarp')
		}

	/* Detailed results if requested, as displayed by -permute- */
	if "`detail'" != "" {
		di as txt in smcl _n(2)  "{title:Unadjusted}" 
		permute `xlist' `jlist' using `pm', `level'

		if `nx' > 1 {
			di as txt in smcl _n(2)  "{title:Adjusted for multiple testing}" 
			permute `xlist' using `pmadj', `level'
			}
		}
		
	di as txt _n "WARNING:"
	di as txt "Monte Carlo methods use random numbers, so results may differ between runs."
	di as txt "Ensure you specify enough permutations to obtain the desired precision."

	return scalar N = `nobs'
	return matrix reps = `R'
	return matrix c = `C'
	return matrix p = `P'
	return matrix b = `B'

end

	

program define metareg_orig
*! v1.06 copyright Stephen Sharp January 1998  STB-42 sbe23
version 5.0
	local varlist "req ex min(1)"
	local if "opt"
	local in "opt"
	local options "WSSe(string) WSVar(string) BSest(string) TOLeran(integer 4) Level(integer $S_level)"
	local options "`options' NOITer ORIGinal" /* original added by RMH */

	parse "`*'"
	if "`wsse'"=="" & "`wsvar'"=="" {
		di in re "Must specify a variable containing estimate of precision"
		di in re "within each trial, using either wsse() or wsvar() option"
		exit 198
		}
	if "`wsse'"~="" & "`wsvar'"~=""{
		confirm variable `wsse'
		confirm variable `wsvar'
		local i=1
		while `i'<=_N {
			if abs(`wsse[`i']'^2-`wsvar[`i']')>0.00001 {
				di in re "Within study variance should be square of within study standard error"
				exit 198
				}
			local i=`i'+1
			}
		}
	if "`wsvar'"~="" {
		confirm variable `wsvar'
		}	
	if "`wsse'"~="" {
		confirm variable `wsse'
		tempvar wsvar
		qui gen `wsvar'=`wsse'^2
		}	
	if "`bsest'"=="" {
		local bsest "reml"
		}
	if "`bsest'"~="reml" & "`bsest'"~="ml" & "`bsest'"~="eb" & "`bsest'"~="mm" & "`bsest'"~="" {
		di in re "Between study variance estimation method invalid:"
		di in re "should be either reml, ml, eb or mm"
		exit 198
		}
	if "`noiter'"~="" & "`bsest'"=="mm" {
		di in bl "Warning: mm is a non-iterative method, noiter option ignored"
		}	
	parse "`varlist'", parse(" ")

	local y "`1'"
	mac shift
	local xvars "`*'"

	tempvar touse
	preserve
	qui {
		mark `touse' `if' `in'
		markout `touse' `y' `xvars'
		keep if `touse'
		}

	qui regress `y' `xvars'
	local p=_result(3)
	local N=_result(1)

	if "`bsest'"=="mm" {
		tempvar wt ypred numi one
		qui {
			gen `wt'=`wsvar'^-1
			regress `y' `xvars' [aw=`wt']
			predict `ypred'
			gen `one'=1
			tempname X C Xt C1 XtC1 A A1 A1XtC1 C1X B
			mkmat `one' `xvars', matrix(`X')
			matrix `C'=J(`N',`N',0)
			local i=1
			while `i'<=_N {
				matrix `C'[`i',`i']=`wsvar'[`i']
				local i=`i'+1
				}
			mat `Xt'=`X''
			mat `C1'=inv(`C')
			mat `XtC1'=`Xt'*`C1'
			mat `A'=`XtC1'*`X'
			mat `A1'=inv(`A')
			mat `A1XtC1'=`A1'*`XtC1'
			mat `C1X'=`C1'*`X'
			mat `B'=`C1X'*`A1XtC1'
			local trB=trace(`B')
			summ `wt'
			local denom=_result(18)-`trB'
			gen `numi'=`wt'*((`y'-`ypred')^2)
			summ `numi'
			local num=max(_result(18)-(`N'-(`p'+1)),0)
			local newtsq=`num'/`denom'
			}	
		}

	if "`bsest'"~="mm" {

		local tsq=0.1
		local newtsq=0
		local j=1

		while abs(`tsq'-`newtsq')>=10^(-`toleran') {
			tempvar wt ypred wtsq numi 
			local tsq=`newtsq'
			if "`noiter'"=="" {
				di in gr  "Iteration " `j' ": tau^2 = " in ye `tsq'
				}
			qui {
				gen `wt'=(`wsvar'+`tsq')^-1
				regress `y' `xvars' [aw=`wt']
				predict `ypred'
				gen `wtsq'=`wt'^2
				}
			if "`bsest'"=="reml" {
				qui {
					gen `numi'=(`wtsq')*(((`N'/(`N'-(`p'+1)))*((`y'-`ypred')^2))-`wsvar')
					summ `numi'
					local num=max(_result(18),0)
					summ `wtsq'
					local denom=_result(18)
					local newtsq=`num'/`denom'
					}
				}

			if "`bsest'"=="ml" {
				qui {
					gen `numi'=(`wtsq')*(((`y'-`ypred')^2)-`wsvar')
					summ `numi'
					local num=max(_result(18),0)
					summ `wtsq'
					local denom=_result(18)
					local newtsq=`num'/`denom'
					}
				}

			if "`bsest'"=="eb" {
				qui {
					gen `numi'=(`wt')*(((`N'/(`N'-(`p'+1)))*((`y'-`ypred')^2))-`wsvar')
					summ `numi'
					local num=max(_result(18),0)
					summ `wt'
					local denom=_result(18)
					local newtsq=`num'/`denom'
					}
				}

			local j=`j'+1

			}
		}

	tempvar wt
	qui {
		gen `wt'=(`wsvar'+`newtsq')^-1
		summ `wt'
		}
	local sumwt=_result(18)

#delimit ;
	di _n
	  in gr "Meta-analysis regression"
	  _col(56) "No of studies =   " in ye  `N' _n
	  in gr _col(56) "tau^2 method      " in ye "`bsest'" _n
	  in gr _col(56) "tau^2 estimate = "  in ye %6.5g `newtsq' _n ; 
#delimit cr
	if "`bsest'"=="ml" | "`bsest'"=="reml" |  "`bsest'"=="eb" {
		di in bl "Successive values of tau^2 differ by less than 10^-"`toleran' " :convergence achieved"
		}

	qui regress `y' `xvars' [aw=`wt']

	local scpar=(`sumwt'*(_result(9)^2))/_result(1)
	local scpar1=(1/`scpar')

	matrix V=get(VCE)
	matrix b=get(_b)

	matrix v=`scpar1'*V


	mat post b v
	mat mlout, level(`level')

	global S_1 = `N'
	global S_2 = `newtsq'

	restore

end


	exit
