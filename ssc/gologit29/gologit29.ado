*! version 2.1.7 29sep2014  Richard Williams, rwilliam@nd.edu

* 2.0.0 - Initial release of gologit2.ado
* 2.0.1 - bugs with autofix, v1 and by fixed; Wald test for final model added
* 2.0.2 - bug in v1 option fixed
* 2.0.3 - minor changes in the output, help file, & version numbering
* 2.0.4 - works with files svyset under Stata 9; minor bug fixes
* 2.0.5 - Fixed bug that could make the d.f. wrong when running Stata 8.2
* 2.1.0 - Support for logit, probit, cloglog, loglog links added;
*		works with Stata 8.2 & with many Stata 9 prefixes
* 2.1.1 - Support for cauchit link added
* 2.1.2 - Diagnostic check for negative predicted values
* 2.1.3 - Eq Labels modified so that spaces get changed to underscores; g2b added;
*	  gologit2_p rewritten so that mfx now works ok
* 2.1.4 - Fixed problem with pweights resulting in incorrect pseudo R^2.
*	  pweights are now rescaled.
*	  Minor bug fix in auofit; improvements in documentation.
* 2.1.5 - Fixed esoteric problems caused by some value labels
* 2.1.6 - For predict, if you do not specify outcome(), 
*         pr (with one new variable specified), xb, and stdp assume outcome(#1).  
*         You must specify outcome() with the stddp option.
* 2.1.7 - Renamed gologit29. The new gologit2 supports factor variables.

capture program gologit29, eclass byable(recall) sortpreserve ///
        properties(swml or rrr irr hr eform)
        if `c(stata_version)' < 9 program gologit29, eclass byable(recall) sortpreserve
        
	if `c(stata_version)' < 9 {
		version 8.2
	}
	else {
		version 9
	}

// Replay results if that is all that is requested. 

	// e(cmd2) is non-missing if the v1 option was specified, i.e. it tells
	// you that gologit29 generated the results even if e(cmd) = gologit.
	// This makes it possible to replay results when v1 has been specified.

	if replay() {
		if "`e(cmd)'" != "gologit29" & "`e(cmd2)'" != "gologit29"  {
			display as error "gologit29 was not the last estimation command"
			exit 301
		}
		if _by() {
			display as error "You cannot use the by command " ///
				"when replaying gologit29 results"
			exit 190
		}
		Replay `0'
		exit
	}
	else {

// This not a replay, so estimate the model.  

	// The bysample code identifies the cases currently selected by by.
	// Cases not in the by sample will later be marked out.
		tempvar bysample
		quietly generate byte `bysample' = 1
		quietly if _by() replace `bysample' = . if `_byindex'!=_byindex()
		global gologit_bysample `bysample'
		Estimate `0'
	}
	// The bysample global var is no longer needed so drop it
	macro drop gologit_bysample

end

************************
program Estimate, eclass
	local oktype = cond(`c(stata_version)' < 9, ///
		"integer `c(level)'", "cilevel")
	syntax [varlist(default=none)] [if] [in]	/// Standard Stata
		[pweight fweight iweight]  [, 		///
		ROBust CLuster(varname) 		///
		Constraints(string) 			///
		SCore(passthru) 			///
		Level(`oktype')				/// display options
		or rrr irr hr EForm LOG  		///
		Pl Pl2(varlist) NPl NPl2(varlist) 	/// parallel lines constraints
		AUTOfit AUTOfit2(string)		/// automated model fitting
		NOLabel V1 Gamma Gamma2(name)		/// Alternative outputs
		LRForce STOre(name) 	 		/// special gologit29 options
		LINK(string)				/// Link fncs, e.g. logit, probit
		MLStart					/// Slow but sure start values
		force					/// Override some otherwise fatal errors
		NOPLAY					/// Used by autofit to not show intermediate results
		svy  *   				/// -ml_options & svyopts- options
		]

// Syntax checks, special gologit29 options

	// Can only specify one of pl, pl(), npl, npl(), autofit, autofit()
	local pl_options = 0
	foreach opt in pl npl pl2 npl2 autofit autofit2 {
		if "``opt''"!="" local pl_options = `pl_options' + 1
	}
	// npl is the default if nothing specified.
	if `pl_options' == 0 {
		local npl "npl"
	}
	else if `pl_options' > 1 {
		di in red "only one of pl, pl(), npl, npl(), " ///
			"autofit, autofit() can be specified"
		exit 198
	}

	// Can only specify one eform option
	local eform `or' `rrr' `irr' `hr' `eform'
	local ef_options: word count `eform'
	if `ef_options' > 1 {
		di in red "Only one of or, rrr, irr, hr, eform " ///
			"can be specified"
		exit 198
	}
	
	
	// nolog is the default unless log is specified
	if "`log'"=="" local nolog "nolog"

        // if force is specified, some otherwise fatal exit commands become warnings only
        if "`force'"!="" {
        	local comment "* "
        	local warning "Warning! "
        }
        
        if "`gamma2'"!="" local gamma gamma

// Let autofit take over if it has been specified.  It will re-call gologit29
// with the necessary parameters and hence will also make syntax checks
	if "`autofit'"!="" | "`autofit2'"!="" {
		gologit29_autofit `0'
		Replay, level(`level') `eform' `gamma' store(`store') gamma2(`gamma2') `options' 
		// Under some conditions, predicted probabilities can be negative.  We check for that
		// and issue a warning message
		prediction_check

		exit
	}
	
// Mark the estimation sample.  More marking to come.
	marksample touse

// Syntax checks, normal Stata options

	// svy-related options
	// svy Code in Gould ml book does not always work right anymore because of
	// changes in s(subpop), so we have to improvise a bit.
	if "`svy'" != "" {
		// First confirm file is svyset
		quietly version `c(stata_version)': svyset
		if substr("`r(settings)'", 1, 7) == ", clear" {
			display as error "svy option requires the data to be svyset"
			exit 198
		}

		svymarkout `touse'
		local wvar `r(weight)'		// remember weight var
		svyopts svy_options display_options options , `options'
		// Check to see if subpop specified and handle accordingly
		subpop_check, `svy_options'
		if "`s(subpop_options)'"!="" {
			local subpop_options `s(subpop_options)'
			local subpop_selection `s(subpop_selection)'
			local subpop_var `s(subpop_var)'
		}
		local meff `s(meff)'
	}

	// display and maximization options
	local display_options `display_options' level(`level') `eform'
	mlopts ml_options, `options'
	
	// Routine checks for cluster, weight
	if "`cluster'" != "" {
		local clopt cluster(`cluster')
	}
	if "`weight'" != "" {
                local wgt "[`weight'`exp']"
	}
	
	// Stata commands are inconsistent in accepting colons as an alternative to /.
	// Comma as an alternative to space sometimes works, sometimes does not.
	// We therefore change colons to / and commas to spaces, which always work.
	local constraints: subinstr local constraints ":" "/", all
	local constraints: subinstr local constraints "," " ", all

// Sample selection variables touse and subtouse; make sure we have cases!
// Markout other missing values from the estimation sample
	markout `touse' `wvar' `offset' `exposure' `subpop_var'
	markout `touse' `cluster', strok
	// limit to bysample
	markout `touse' $gologit_bysample
	if "`subpop_selection'" != "" {
		// restrict initial value calculations to
		// observations within the svy subpopulation
		local subtouse `touse' & `subpop_selection'
	}
	else	local subtouse `touse'
 
	quietly count if `subtouse' !=0
	if r(N) == 0 {
		display as error "There are no observations left!"
		display as error "Double-check your sample selection."
		exit 2000
	}

// Additional checks on the varlist and pl & npl specfications

	// Get Y and X variables
	gettoken y x: varlist
	// get rid of collinear explanatory variables
	_rmcoll `x'
	local x "$S_1"
	local Numx: word count `x'
	
	// Check to make sure pl() and npl() varlists are legit
	if "`npl2'"!="" {
		local nplchek: list local(npl2) - local(x)
		if "`nplchek'"!="" {
			display ""
			display as error ///
				"`warning'npl{yellow}(`nplchek'){red} is not a subset of the X variables: {yellow} `x'"
			display as error "The -force- option sometimes lets you proceed anyway"
			display ""
			`comment' exit 198
		}
	}
	else if "`pl2'"!="" {
		local plchek: list local(pl2) - local(x)
		if "`plchek'"!="" {
			display ""
			display as error ///
				"`warning'pl{yellow}(`plchek'){red} is not a subset of the X variables: {yellow} `x'"
			display as error "The -force- option sometimes lets you proceed anyway"
			display ""
			`comment'exit 198
		}
	}
	
// Link functions

	// logit is the default link if none has been specified. This
	// could be changed if someone preferred a different default. 
	if "`link'"=="" local link "logit"

	// logit link
	if "`link'"=="logit" | "`link'"=="l" {
		local link "logit"
		local link_title "Generalized Ordered Logit Estimates"
	}
	// probit is also supported
	else if "`link'"=="probit" | "`link'"=="p" | {
		local link "probit"
		local link_title "Generalized Ordered Probit Estimates"
	}
	// cloglog - SPSS calls this nloglog
	else if "`link'"=="cloglog" | "`link'"=="c" |  {
		local link "cloglog"
		local link_title "Generalized Ordered Cloglog Estimates"
	}
	// loglog - SPSS calls this cloglog
	else if "`link'"=="loglog" | "`link'"=="ll"  {
		local link "loglog"
		local link_title "Generalized Ordered Loglog Estimates"
	}
	// cauchit
	else if "`link'"=="cauchit" | "`link'"=="ca" | "`link'"=="cau"  {
		local link "cauchit"
		local link_title "Generalized Ordered Cauchit Estimates"
	}
	// non-supported link
	else {
		display ""
		display as error ///
			"{yellow}`link'{red} is not a legal link function"
		display ""
		exit 198
	}
	
	if "`link'"!="logit" & "`v1'"!="" {
		di
		di as error "Option v1 is not supported with link `link'"
		di
		exit 198
	}
	
	global Link `link'

		
// Generate all the new things we will need for the models

	// Get Y values from tab
	tempname Y_Values   /* Vector containing the values of the DV */
	quietly tab `y' if `subtouse', matrow(`Y_Values')
	local M = r(r)
	if `M' > 20 {
		di 
		di as error "`warning'`y' has `M' categories - a maximum of 20 is normally allowed"
		di as error "Make sure you are using an ordinal dependent variable"
		di as error "The -force- option sometimes lets you proceed anyway"
		di
		`comment'exit 149
	}
	matrix `Y_Values' = `Y_Values''  /* Transpose the matrix */
	local  Numeqs = `M' - 1
	local lastcat = `Y_Values'[1, `M']   /* last category will be base category */
	
	// ll program will use these values to determing 1rst, 2nd, 3rd, etc. values of Y
	macro drop dv_*
	forval i = 1/`M' {
		global dv_`i' = `Y_Values'[1, `i']
	}

	// Build equations for constant-only model.
	local eqsx (eq1:`y'=)
	local eqnamesx "eq1"
	forval i = 2/`Numeqs' {
		local eqsx "`eqsx' (eq`i':)"
		local eqnamesx "`eqnamesx' eq`i'"
	}

	// Build equations for full model to be estimated.
	local eqs (eq1:`y'=`x')
	local eqnames "eq1"
	forval i = 2/`Numeqs' {
		local eqs "`eqs' (eq`i':`x')"
		local eqnames "`eqnames' eq`i'"
	}

	// Create constraints for parallel lines if they have been requested
	parallel_lines, numeqs(`Numeqs') x(`x') `pl' pl2(`pl2') `npl' npl2(`npl2')
	local plconstraints  `e(plconstraints)'
	local constraints `constraints' `plconstraints'
	local plvars `e(plvars)'
	local nplvars: list local(x) - local(plvars)
	
	
// Start values for each type of link will be in matrix b0
// The Start_Values subroutine will generate the start values
	tempname b0

// Fit the mis-specified model if meff has been requested - svy only
	if "`meff'" != ""  {
		Start_Values `y',  /// 
			touse(`touse') `robust' clopt(`clopt') ///
			numeqs(`Numeqs') b0(`b0') link(`link') /// 
			subtouse(`subtouse') `mlstart' eqsx(`eqsx') ///
			constraints(`constraints')   ///
			ml_options(`ml_options')
			
		local initopt `s(initopt)'
		
		quietly ml model lf gologit29_ll `eqs' if `subtouse', ///
			constraints(`constraints')   ///
			collinear missing maximize nocnsnotes ///
			waldtest(-`Numeqs') `nolog'  `ml_options' ///
			`initopt' search(off)
		// covariance matrix from the misspecified model fit
		tempname Vmsp
		matrix `Vmsp' = e(V)
	}

// Estimate the constant-only model 
	Start_Values `y', `svy' subpop_options(`subpop_options') /// 
		wgt(`wgt') touse(`touse') `robust' clopt(`clopt') ///
		numeqs(`Numeqs') b0(`b0') subtouse(`subtouse') ///
		link(`link') eqsx(`eqsx') `mlstart' constraints(`constraints') ///
		svy_options(`svy_options') ml_options(`ml_options')
		
	local initopt `s(initopt)'
	if "`s(LL0)'"!="" local LL0 = `s(LL0)'

// Estimate the final model; and add some stats
	ml model lf gologit29_ll `eqs' `wgt' if `touse', 		///
		constraints(`constraints') `robust'  `clopt' `svy' 	///
		waldtest(-`Numeqs') `initopt' title(`link_title') 	///
		collinear missing maximize nocnsnotes 			///
		`score'	`nolog' `svy_options' `ml_options' search(off)
		
		
	if "`Vmsp'" != "" {
		// compute misspecification effects and save them to e()
		_svy_mkmeff `Vmsp'
	}

	if "`LL0'"!="" ereturn scalar ll_0 = `LL0'

	// Compute McFadden's Pseudo R^2 if necessary info exists, i.e. it won't 
	// be possible after using svy because svy does not return it.
	// Also, Stata ml does not rescale pweights, but gologit29 will
	if (e(ll) < . & e(ll_0) < .) {
		if "`weight'" == "pweight" {
			local wgtvar: word 2 of `=e(wexp)'
			quietly sum `wgtvar' if e(sample)
			ereturn scalar ll = e(ll)/ r(mean)
			// if mlstart used ll_0 needs rescaling too
			if "`mlstart'" !="" ereturn scalar ll_0 = e(ll_0)/ r(mean)
		}
		ereturn scalar r2_p = 1 - (e(ll) / e(ll_0) )
	}

	// Stata reports a Wald rather than LR test whenever constraints have been imposed.
	// The lrforce parameter makes Stata report a LR test instead, provided
	// crittype is log likelihood.  Use this at your own risk; it appears to
	// be ok when pl or npl is used but other constraints may invalidate an
	// LR test.
	local crittype = e(crittype)
	local chi2type = e(chi2type)
	if "`lrforce'"!="" & "`crittype'"=="log likelihood" & "`chi2type'"!="LR" {
		ereturn local chi2type "LR"
		ereturn scalar chi2 = -2 * (e(ll_0) - e(ll))
		ereturn scalar p = chi2tail(e(df_m),e(chi2))
	}

// Return assorted values
	ereturn local plvars `plvars'
	ereturn local nplvars `nplvars'
	ereturn local xvars `x'
	ereturn scalar k_cat = `M'
	ereturn scalar basecat = `lastcat'
	ereturn scalar ibasecat = `M'
	ereturn local eqnames `eqnames'
	ereturn matrix cat = `Y_Values'
	ereturn local subpop `subpop_options'
	ereturn scalar k_eform = `Numeqs'
	ereturn scalar k_eq_model = e(k_eform)
	ereturn local link `link'

	
// Use Y value labels if requested
	if "`nolabel'"=="" Use_Value_Labels

// Final cleanup

	constraint drop `plconstraints'
	macro drop dv_*
	macro drop Link

	// If v1 option is specified, reformat returned results in gologit 1.0 format
	// Some post-estimation commands are designed for gologit 1.0 and 
	// may not work correctly with gologit29.  Specifying v1 can zap programs
	// designed to work with gologit29.
	// e(cmd2) indicates that gologit29 generated the results rather than gologit.
	if "`v1'"=="v1" {
		v1_format
		ereturn local cmd2 "gologit29"
		ereturn local cmd "gologit"
	}
	else {
		ereturn local predict "gologit29_p"
		ereturn local cmd "gologit29"
	}
	
// display the results

	Replay, `display_options' `gamma' store(`store') gamma2(`gamma2') `noplay'
	
// Under some conditions, predicted probabilities can be negative.  We check for that
// and issue a warning message.  If using autofit, message will only appear after the
// final model
	if "`noplay'"=="" prediction_check

end

************************
program parallel_lines, eclass
	syntax [, numeqs(int 1) ///
		x(varlist) pl pl2(varlist) npl npl2(varlist)  ]
	local Numeqs `numeqs'
	local NumConstraints = `Numeqs' - 1
	local x "`x'"

	// Create the parallel lines constraints if they have been requested.
	// This can be done via either the pl or npl options.
	
	* 1. If npl is specified without parameters,
	* no X vars effects are constrained to be the same across equations 
	
	if "`npl'"!="" {
		ereturn local plvars ""
		ereturn local plconstraints  ""
		exit
	}
	
	// 2. If pl is specified without parameters, All X vars are constrained
	// to meet the proportional odds/ parallel lines assumption.
	
	else if "`pl'"!="" {
	
		forval j = 1/`NumConstraints' {
			local k = `j' + 1
			constraint free
			constraint `r(free)' [#`j'=#`k']
			local plconstraints `plconstraints' `r(free)'
		}
		ereturn local plvars "`x'"
		ereturn local plconstraints  "`plconstraints'"
		exit

	}
	
	// pl() and npl() are left 
	
	// 3. Any vars specified in pl() will be constrained to be equal across
	// equations.  No further action is needed until constraints generated.

	// 4. Vars specified in npl() will not be constrained; those not
	// specified will be
	if "`npl2'"!="" local pl2: list local(x) - local(npl2) 

	local Numpl: word count `pl2'
	if `Numpl' > 0 {
		forval j = 1/`NumConstraints' {
			local k = `j' + 1
			constraint free
			constraint `r(free)' [#`j'=#`k']:`pl2'
			local plconstraints `plconstraints' `r(free)'
		}

	}
	ereturn local plvars "`pl2'"
	ereturn local plconstraints  "`plconstraints'"
end

************************

program Start_Values, sclass
* Gets the start values (i.e. the values of the constant-only model)
	syntax varname , 	///
		[svy subpop_options(string) robust clopt(string) ///
		wgt(string) touse(varname) b0(name) numeqs(integer -1) ///
		subtouse(string) link(string) mlstart eqsx(string) ///
		svy_options(string) constraints(string) ///
		ml_options(string) ]
	local Numeqs = `numeqs'
	local M = `Numeqs' + 1
	local y `varlist'
	
// If mlstart has been specified, we will use our own program to get the
// start values.  This will be slower but perhaps surer.  This option
// shouldn't be necessary but it can be used if having trouble or if
// you want to confirm that the program is working correctly. mlstart
// is automatically used if pweights have been specified since otherwise
// the calculation of Pseudo R^2 is wrong.

	if "`mlstart'"!="" {
		if "`svy'"=="" {
			quietly ml model lf gologit29_ll `eqsx' `wgt' if `subtouse', 		///
				`robust'  `clopt'  	///
				waldtest(-`Numeqs')  	///
				title(Start Values for `link')	///
				collinear missing maximize nocnsnotes 	///
				`ml_options'
			local LL0 = e(ll)
		}
		else if "`svy'"=="svy" {
			quietly ml model lf gologit29_ll `eqsx' `wgt' if `touse', 		///
			`robust'  `clopt' `svy' 	///
			waldtest(-`Numeqs')  	///
			title(Start Values for `link')	///
			collinear missing maximize nocnsnotes 	///
			`svy_options' `ml_options'
		}
		
		mat `b0' = e(b)

		// Stata 8.2 has a bug that results in faulty Wald tests if you 
		// specify both lf0 and constraints.  This is a workaround.
		if ("`constraints'"=="" | `c(stata_version)' >= 9) {
			local initopt init(`b0') lf0(`Numeqs' `LL0')
		}
		else local initopt init(`b0')

		sreturn local initopt `initopt'
		if "`LL0'"!="" sreturn local LL0 `LL0'

		exit
	}

	
// Now is the quicker default method for start values
// Matrix b0 will contain the cumulative probabilities for each category
// LL0 will contain the log likelihood 0 for non-svy models

	// First we'll get start values if using Stata 8.2
	if `c(stata_version)' < 9 {
		if "`svy'"=="" {
			quietly ologit `y' `wgt' if `subtouse', `robust'  `clopt' 
			local LL0 = e(ll)
		}
		else if "`svy'"=="svy" {
			quietly svyologit `y' if `touse', `subpop_options'
		}
		mat `b0' = e(b)
		forval j = 1/`Numeqs' {
			mat `b0'[1, `j'] = invlogit(`b0'[1,`j'])
		}

	}
	// Next we'll use features available if using Stata 9
	// The LL0 formula is the sum over j of Nj * ln(Pj)
	// = sum over j of N * Pj * ln(Pj)
	else {
		if "`svy'"=="" {
			quietly proportion `y' `wgt' if `subtouse' , `clopt' nolabel
			mat `b0' = e(b)
			forval j = 1/`M' {
				local LL0 = `LL0' + `e(N)' * `b0'[1, `j'] * ln(`b0'[1,`j'])
			}
			
		}
		else if "`svy'"=="svy" {
			quietly svy, `subpop_options': proportion `y' if `touse', nolabel
			mat `b0' = e(b)
		}
		// Now we convert the b's to cumulative percentages
		mat `b0' = `b0'[1, 1..`Numeqs']
		forval j = 2/`Numeqs' {
			local i = `j' - 1
			mat `b0'[1, `j'] = `b0'[1, `j'] + `b0'[1, `i']
		}
	}

		
// Convert as needed for the link function used. Remembers signs  are
// the opposite of oglm
	if "`link'"=="" | "`link'"=="logit" {
		forval j = 1/`Numeqs' {
			mat `b0'[1,`j'] = -logit(`b0'[1,`j'])
		}
	}
	else if "`link'"=="probit" {
		forval j = 1/`Numeqs' {
			mat `b0'[1,`j'] = -invnorm(`b0'[1,`j'])
		}
	}
	else if "`link'"=="cloglog" {
		forval j = 1/`Numeqs' {
			mat `b0'[1,`j'] = cloglog(1-`b0'[1,`j'])
		}
	}
	else if "`link'"=="loglog" {
		forval j = 1/`Numeqs' {
			mat `b0'[1,`j'] = -cloglog(`b0'[1,`j'])
		}
	}
	else if "`link'"=="cauchit" {
		forval j = 1/`Numeqs' {
			mat `b0'[1,`j'] = -tan(_pi * (`b0'[1,`j'] - .5))
		}
	}

	forval i = 1/`Numeqs' {
		local columnames `columnames' eq`i':_cons
	}
	matrix colnames `b0' = `columnames'

	// Stata 8.2 has a bug that results in faulty Wald tests if you 
	// specify both lf0 and constraints.  This is a workaround.
	if ("`constraints'"=="" | `c(stata_version)' >= 9) {
		local initopt init(`b0') lf0(`Numeqs' `LL0')
	}
	else local initopt init(`b0')

	sreturn local initopt `initopt'
	if "`LL0'"!="" sreturn local LL0 `LL0'

end

************************************************

program v1_format, eclass
	local xvars `e(xvars)'
	local Numx: word count `xvars'
	local M = e(k_cat)
	local Numeqs = `M' - 1
	// Numx2 counts the constant as an X
	local Numx2 = `Numx' + 1

/*	
If v1 option is used, restructure saved results to be consistent with gologit 1.0
This will allow the use of post-estimation commands that
have code specifically designed for gologit 1.0 but might zap compatibility
with gologit29.
*/

	// Equations will be renamed mleq1, mleq2, etc.
	// Some versions of the -spostado- routines specifically
	// look for these equation names.
	local eqnames
	forval i = 1/`Numeqs' {
		forval j = 1/`Numx2' {
			local eqnames `eqnames' mleq`i'
		}
	}

	tempname bmat vmat
	matrix `bmat' = e(b)
	matrix `vmat' = e(V)
	matrix coleq `bmat' = `eqnames'
	matrix coleq `vmat' = `eqnames'
	matrix roweq `vmat' = `eqnames'
	ereturn repost b = `bmat' V = `vmat', rename

	* Set up same global vars used by gologit 1.0	
	global S_eqnum = `Numeqs' - 1
	global S_E_cmd = "gologit"
	global S_E_pr2 = e(r2_p)
	global S_E_ll0 = e(ll_0)
	global S_E_ll = e(ll)
	global S_E_mdf = e(df_m)
	global S_E_chi2 = e(chi2)
	global S_E_nobs = e(N)
	global S_E_depv = e(depvar)
	global S_E_ttl = "Generalized Ordered Logit Estimates"
	global S_E_tdf = .
	global S_3 mleq`Numeqs'
	global S_1 = "`xvars'"
	global S_2 = ", depv(1) constant(111) from(__000002)"
	global S_golog `M'
	
end

************************

program subpop_check
	// Check to see if subpop option was used
	syntax [, subpop(string) *]
	if "`subpop'"!="" subpop_returns `subpop'
end

************************

program subpop_returns, sclass
	// Return subpop-related info
	syntax [varlist(default=none max=1 numeric)] [if/] [in] [, SRSsubpop ]
	local subpop_selection `s(subpop)'
	sreturn local subpop_options subpop(`0') 
	sreturn local subpop_selection `subpop_selection'
	sreturn local subpop_var `varlist'
end

************************
program Use_Value_Labels, eclass

	// Use Y value labels if user has requested them
	local y `e(depvar)'
	local Numx: word count `e(xvars)'
	local M = e(k_cat)
	local Numeqs = `M' - 1
	tempname Y_Values
	matrix `Y_Values' = e(cat)
	local eqnames `e(eqnames)'
	// Numx2 counts the constant as an X
	local Numx2 = `Numx' + 1
	
	// Retrieve the Y value labels, turn into equation names
	forval i = 1/`M' {
		local j = `Y_Values'[1,`i']
		local vlabel: label(`y') `j' 32
		// Replace characters that cause problems
		local vlabel: subinstr local vlabel "." "_", all
		local vlabel: subinstr local vlabel ":" "_", all
		local vlabel: subinstr local vlabel "$" "_", all
		local vlabel: subinstr local vlabel " " "_", all
		local vlabel: subinstr local vlabel "[" "{", all
		local vlabel: subinstr local vlabel "]" "}", all
		local vlabel: subinstr local vlabel "(" "{", all
		local vlabel: subinstr local vlabel ")" "}", all
		// base category (i.e. highest Y value) is separate 
		// from the equation names
		if `i'==1 {
			local new_eqnames `"`"`vlabel'"'"'
		}
		else if `i'!=`M' {
			local new_eqnames `"`new_eqnames' `"`vlabel'"'"'
		}
		else local baselab `"`"`vlabel'"'"'
	}
	// Duplicate names screw up the printout
	local testnames: list dups new_eqnames
	if "`testnames'"!="" {
		display as error "When using value labels, each " ///
			"value label for the DV must be unique. "
		display as error "Equations will instead be " ///
			"labeled eq1, eq2, etc."
		exit
	}
			
	// Have to repeat equation name for every x, including constant
	forval i = 1/`Numeqs' {
		local vlabel: word `i' of `new_eqnames'
		forval j = 1/`Numx2' {
			local vlabels `"`vlabels' `"`vlabel'"'"'
		}
	}
	// Replace the current b, V, and eqnames matrices
	tempname bmat vmat
	matrix `bmat' = e(b)
	matrix `vmat' = e(V)
	capture matrix coleq `bmat' = `vlabels'
		if _rc !=0 {
		display as error "There is a problem with your value labels."
		display as error "Equations will instead be labeled eq1, eq2, etc."
		exit
	}
	matrix coleq `vmat' = `vlabels'
	matrix roweq `vmat' = `vlabels'
	ereturn repost b = `bmat' V = `vmat', rename
	ereturn local eqnames `"`new_eqnames'"'
	ereturn local baselab `"`baselab'"'

end

************************

program gamma_parameterization, eclass
	// This routine presents The Peterson-Harrell parameterization
	local oktype = cond(`c(stata_version)' < 9, ///
		"integer `c(level)'", "cilevel")
	syntax [, level(`oktype') or irr rrr hr eform]
	
	// Get right label for eform option if one is requested
	if "`or'"!="" {
		local eform_option "eform(Odds Ratio)"
	}
	else if "`rrr'"!="" {
		local eform_option "eform(RRR)"
	}
	else if "`irr'"!="" {
		local eform_option "eform(IRR)"
	}
	else if "`hr'" !="" {
		local eform_option "eform(Haz. Ratio)"
	}
	else if "`eform'"!="" {
		local eform_option "eform(exp(b))"
	}
	
	local y `e(depvar)'
	local plvars `e(plvars)'
	local nplvars `e(nplvars)'
	local xvars `e(xvars)'
	local Numeqs = e(k_cat)-1
	local Numx: word count `xvars'
	local Numx2 = `Numx' + 1   /* Count constant as an X */
	local Numnpl: word count `nplvars'
	if "`e(df_r)'"!="" local dof dof(`e(df_r)')
	
	// Number of coefficients to be output
	local Numbetas = `Numx'
	local Numgammas = (`Numeqs' - 1) * `Numnpl'
	local Numcuts = `Numeqs'
	local Numcoefs = `Numbetas' + `Numgammas' + `Numcuts'
	
	// Number of panels/ equations depends on whether or not an eform
	// option is specified and also whether or not there are any gammas.
	// If no gammas, only print out Betas and Alphas.
	// If eform option is specified, don't print out alphas.
	if "`Numgammas'"=="0" {
		local Npanels = 2
	}
	else local Npanels = `Numeqs' + 1
	if "`eform_option'"!="" local Npanels = `Npanels' - 1
	
	// Change header depending on the link function
	if "`e(link)'"== "" | "`e(link)'"== "logit"   {
		local link_header "Gammas are deviations from proportionality"
	}
	else {
		local link_header "Gammas are deviations from parallel lines"
	}	

	// Get our matrices set up
	tempname bcopy vcopy b2 v2 matsize 
	mat `bcopy' = e(b)
	mat `vcopy' = e(V)
	matrix `b2' = J(1, `Numcoefs', 0)
	matrix `v2' = I(`Numcoefs')
	
	// Get the Beta coefficients
	forval i = 1/`Numx' {
		matrix `b2'[1, `i'] = `bcopy'[1, `i']
		matrix `v2'[`i', `i'] = `vcopy'[`i', `i']
		local xvar: word `i' of `xvars'
		local eqnames `eqnames' Beta:`xvar'
	}
	
	// Get the Gamma coefficients
	// For some annoying reason, lincom behaves differently 
	// depending on whether or not svy is specified.  No svy, 
	// results are returned in r(estimate).  With svy, results get
	// returned in r(est).  So, our code adapts for that.
	local eqnum = `Numx'
	forval i = 2/`Numeqs' {
		forval j = 1/`Numx' {
			local xvar: word `j' of `xvars'
			local nplcheck: list local(xvar) in local(nplvars)
			* Only compute Gammas for Xs free to vary
			if `nplcheck' !=0 {
				quietly lincom [#`i']`xvar' - [#1]`xvar'
				local eqnum = `eqnum' + 1
				if "`r(est)'"!="" {
					local lincom_estimate "r(est)"
				}
				else {
					local lincom_estimate "r(estimate)"
				}
				matrix `b2'[1,`eqnum'] = `lincom_estimate'
				matrix `v2'[`eqnum',`eqnum'] = r(se)^2
				local eqnames `eqnames' Gamma_`i':`xvar'
			}
		}
	}
	// Get the Alpha (Intercept) coefficients
	forval i = 1/`Numeqs' {
		local eqnum = `eqnum' + 1
		local cutlocation = `i' * `Numx2'
		matrix `b2'[1, `eqnum'] = `bcopy'[1, `cutlocation']
		matrix `v2'[`eqnum', `eqnum'] = `vcopy'[`cutlocation', `cutlocation']
		local eqnames `eqnames' Alpha:_cons_`i'
	}

	matrix coleq `b2' = `eqnames'
	matrix coleq `v2' = `eqnames'
	matrix roweq `v2' = `eqnames'
	
	tempname gamma_b gamma_se
	matrix `gamma_b' = `b2'
	matrix `gamma_se' = vecdiag(`v2')
	forval i = 1/`Numcoefs' {
		matrix `gamma_se'[1, `i'] = `gamma_se'[1, `i'] ^ .5
	}

	
	// Temporarily create new e(b), e(V)
	tempname results
	_estimates hold `results', restore
	ereturn post `b2' `v2', depname(`y') `dof'
	
	// Display results
	display ""
	display ""
	display "Alternative parameterization: `link_header'"
	ereturn display, level(`level') `eform_option' neq(`Npanels')
	
	// Restore original e(b), e(V), and add Gamma values
	_estimates unhold `results'
	ereturn matrix gamma_b `gamma_b'
	ereturn matrix gamma_se `gamma_se'

end
************************

program g2b, eclass

	* Reformat gamma output to use with estout & outreg2.  Don't try to
	* use other post-estimation commands, e.g. predict, with the
	* reformatted matrices!
	
	version 8.2
	syntax , gamma2(name)
	
	// Restructure b & V for gamma results
	matrix b = e(gamma_b)
	matrix V = diag(e(gamma_se))
	matrix V = V*V'
	local ngamma = colsof(V)
	
	* Save stuff we will want to post.  We copy all the old stuff
	* returned in e, then ereturn it again later.  This is probably overkill, but
	* hopefully whatever anyone wants is here!
	
	local scalars: e(scalars)
	local macros: e(macros)
	local matrices: e(matrices)
	
	* Equation Labels are dropped because equations will be different
	* Also drop cmd, command, predict, as they can cause
	* post-estimation problems
	local macrodrop "baselab eqnames command cmd predict"
	local macros: list macros - macrodrop
	* b & V need special handling
	local Vb "b V"
	local matrices: list matrices - Vb
	
	foreach scalar of local scalars {
		tempname x`scalar'
		scalar `x`scalar'' = e(`scalar')
	}
	
	foreach macro of local macros {
		local x`macro' `"`e(`macro')'"'
	}
	
	foreach matrix of local matrices {
		tempname x`matrix'
		matrix `x`matrix'' = e(`matrix')
	}
	tempname gologit_b gologit_V
	matrix `gologit_b' = e(b)
	matrix `gologit_V' = e(V)
	
	tempvar touse
	quietly gen byte `touse' = e(sample)

	* Save current estimates
	tempname results
	_estimates hold `results', restore
	* Post reformatted matrices
	ereturn post b V, esample(`touse')
	
	* ereturn other stuff estout might want

	foreach scalar of local scalars {
		ereturn scalar `scalar' = `x`scalar''
	}
	
	foreach macro of local macros {
		ereturn local `macro' `"`x`macro''"'
	}

	foreach matrix of local matrices {
		ereturn matrix `matrix' = `x`matrix''
	}
	ereturn matrix gologit_b = `gologit_b'
	ereturn matrix gologit_V = `gologit_V'

	* Gamma will have different # of equations than default parameterization
	ereturn scalar gologit_k_eq = e(k_eq)
	ereturn scalar gologit_k_eform = e(k_eform)
	local eqnames: coleq e(b)
	local eqnames: list uniq eqnames
	local k_eq: list sizeof eqnames
	ereturn scalar k_eq = `k_eq'
	ereturn scalar k_eform = e(k_eq) - 1
	ereturn local eqnames `eqnames'
	ereturn local title Gamma: `e(title)'
	
	ereturn local cmd ml display
	capture estimates drop `gamma'
	estimates store `gamma2'
	
	_estimates unhold `results'

end

************************
program prediction_check
	* check for negative predicted probabilities
	local M = e(k_cat)
	forval i = 1/`M' {
		local pvars `pvars' p`i'
	}
	tempvar `pvars' 
	local pvars2 `p1'
	local pvars3 `p1'
	forval i = 2/`M' {
		local pvars2 `pvars2' `p`i''
		local pvars3 `pvars3', `p`i''
	}
	quietly gologit29_p `pvars2' if e(sample)
	quietly count if min(`pvars3') < 0 & e(sample)
	if `=r(N)' {
		local cl `"{stata whelp gologit29:gologit29 help}"'
		display
		display as error "WARNING! " as yellow "`=r(N)' in-sample cases" as error " have an outcome with a predicted probability that is"
		display as error "less than 0. See the `cl' section on Warning Messages for more information."
	}
	quietly count if max(`pvars3') > 1 & e(sample)
	if `=r(N)' {
		display
		display as error "WARNING! " as yellow "`=r(N)' in-sample cases" as error " have an outcome with a predicted probability that is"
		display as error "greater than 1. See the `cl' section on Warning Messages for more information."
	}

end
	
	
************************

program Replay
	local oktype = cond(`c(stata_version)' < 9, ///
		"integer `c(level)'", "cilevel")
	syntax [,				///
	Level(`oktype')			 	///
	or irr rrr hr EForm 			///
	Gamma Gamma2(name) STOre(name) NOPLAY	///
	* ]
	
	if "`gamma2'"!="" local gamma gamma
	
	// use svyopts to get display options
	svyopts noopts display_options options, `options'
	local display_options `display_options' level(`level') `or' `rrr' `irr' `hr' `eform'
	if "`noplay'"=="" ml display , `display_options'
	
	
	// display alternative gamma format if requested.  But, we will get
	// gamma results regardless.
	
	if "`gamma'"!="" & "`noplay'"=="" {
		gamma_parameterization , level(`level') `or' `irr' `rrr' `hr' `eform'
	}
	else {
		quietly gamma_parameterization , level(`level') `or' `irr' `rrr' `hr' `eform'
	}

	// Store results if requested
	if "`store'"!="" est store `store'
	
	// Store gamma estimates if so requested
	if "`gamma2'"!="" g2b, gamma2(`gamma2')

end
