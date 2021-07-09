*! version 2.3.0 30aug2016  Richard Williams, rwilliam@nd.edu

* 1.0.0 - Initial release 
* 1.0.1 - BETA experimental log link added
* 1.0.2 - BETA hetero/scale options added
* 1.0.3 - BETA Bug fixes
* 1.0.4 - BETA flip option added
* 1.0.5 - BETA Cauchit (Inverse Cauchy) link added
* 1.1.0 - 2nd official release
* 1.1.1 - Minor release - showeqns option added to ml display; version changed to 9.2
* 1.1.2 - Fixed problem with pweights resulting in incorrect pseudo R^2.
*	  pweights are now rescaled. (Feb 1, 2007)
* 1.1.3 - Added svyb and svyj as supported properties (May 6, 2007)
* 1.1.4 - Fixed esoteric bug with value labels.  Help revised to indicate
*         better citations & references.
* 2.0.0 - Updated for Stata 11. Supports factor variables and the margins
*         command. Those with Stata 9 or 10 should use oglm9 instead.
* 2.0.1 - Predict option tweaked to default to outcome #1 if
*         no outcome specified for pr or score. This helps the routine to 
*         work with the spost13 commands.
* 2.1.0 - Added support for more Stata display options. Added check program
*         for when svy: is used. svy option dropped; use svy: prefix instead.
* 2.1.1 - Fixed bug in or option. Undocumented Collinear option added. 
*         Added by request. Not recommended, use at your own risk.
*         Help file updated.
* 2.1.2 - Fixed a problem of perfect collinearity with rmcoll when using subsamples
*         Fixed problem with ml options not working correctly
*         renamed mlopts and diopts to be consistent with other Stata commands
* 2.2.0 - ereturns marginsdefault. In Stata 14+, this will cause the margins command 
*         to default to using all the outcomes rather than just the first.
* 2.3.0 - Added modifications provided by Ben Shear, Stanford, to specify 
*         initial values via the STARTVALS option

program oglm, eclass byable(recall) sortpreserve properties(swml svyr svyb svyj or irr rrr hr eform mi fvaddcons)
	version 11.2
	macro drop oglmby oglmx oglmh Link dv_*

// Replay results if that is all that is requested. 

	if replay() {
		if "`e(cmd)'" != "oglm"  {
			display as error "oglm was not the last estimation command"
			exit 301
		}
		if _by() {
			display as error "You cannot use the by command " ///
				"when replaying oglm results"
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
		global oglmby `bysample'
		Estimate `0'
	}
	// Drop global vars
	macro drop oglmby oglmx oglmh Link dv_*

end

************************
program Estimate, eclass
	version 11.1
	syntax [varlist(default=none fv)] [if] [in]		/// Standard Stata
		[pweight fweight iweight]  [, 			///
		ROBust CLuster(varname) 			///
		Constraints(string) 				///
		SCore(passthru) 				///
		Level(cilevel)					/// display options
		or rrr irr hr EForm LOG  			///
		LRForce STOre(name) 				/// special oglm options
		LInk(string)					/// Link fncs, e.g. logit, probit
		HETero(varlist fv) SCALE(varlist fv) eq2(varlist fv)	/// Synonyms, use one only
		flip						/// Reverse location & scale equations
		HC LS						/// Affects equation labeling
		TRUstme	FORCE					/// Override some otherwise fatal errors
		COLlinear					/// Don't check for collinearity. Affects both equations
		STARTVALS(name)					/// Name of matrix containing desired initial values; ben shear
		*   						/// ml options
		]

// Syntax checks, special oglm options

	// nolog is the default unless log is specified
	if "`log'"=="" local nolog "nolog"
	
	// make sure only one eform specified.  If so, it will
	// be local macro eform
	local eform `or' `irr' `rrr' `hr' `eform'
	if `:list sizeof eform' > 1 {
		opts_exclusive "`eform'"
	}

	// Only one of hc or ls may be specified.  If so, it will
	// be local macro eqlabel
	local eqlabel `hc' `ls'
	if `:list sizeof eqlabel' > 1 {
		opts_exclusive "`eqlabel'"
	}

	
	// if trustme/force is specified, some otherwise fatal exit commands become warnings only
	if "`trustme'"!="" | "`force'"!="" {
		local comment "* "
		local warning "Warning! "
	}

// Mark the estimation sample.  More marking to come.
	marksample touse

// Syntax checks, normal Stata options

	// display and maximization options
	_get_diopts diopts options, `options'
	local diopts `diopts' `eform' level(`level')
	mlopts mlopts, `options'

	
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

// Markout other missing values from the estimation sample
// Make sure we have cases!
	markout `touse' `offset' `exposure'
	markout `touse' `cluster', strok
	// limit to bysample
	markout `touse' $oglmby
 
	quietly count if `touse' !=0
	if r(N) == 0 {
		display as error "There are no observations left!"
		display as error "Double-check your sample selection."
		exit 2000
	}

// Additional checks on the varlist specfications

	// Get Y and X variables
	gettoken y x: varlist
	// get rid of collinear explanatory variables
	_rmcoll `x' if `touse', expand `collinear'
	local x `"`r(varlist)'"'
	_fv_check_depvar `y'
	
// Link functions

	// logit is the default link if none has been specified. This
	// could be changed if someone preferred a different default. 
	if "`link'"=="" local link "logit"

	// logit link
	if "`link'"=="logit" | "`link'"=="l" {
		local link "logit"
		local link_title "Ordered Logistic Regression"
	}
	// probit is also supported
	else if "`link'"=="probit" | "`link'"=="p" | {
		local link "probit"
		local link_title "Ordered Probit Regression"
	}
	// cloglog - SPSS calls this nloglog
	else if "`link'"=="cloglog" | "`link'"=="c" |  {
		local link "cloglog"
		local link_title "Ordered Cloglog Regression"
	}
	// loglog - SPSS calls this cloglog
	else if "`link'"=="loglog" | "`link'"=="ll"  {
		local link "loglog"
		local link_title "Ordered Loglog Regression"
	}
	// cauchit
	else if "`link'"=="cauchit" | "`link'"=="ca" | "`link'"=="cau"  {
		local link "cauchit"
		local link_title "Ordered Cauchit Regression"
	}
	// log - This link is experimental, may not work right
	else if "`link'"=="log"   {
		local link "log"
		local link_title "Ordered Log Regression"
	}
	// non-supported link
	else {
		display ""
		display as error ///
			"{yellow}`link'{red} is not a legal link function"
		display ""
		exit 198
	}
	global Link `link'


// heteroskedasticity/ scale/ eq2 option

	// Can only specify one of hetero, scale, eq2
	local het_options = 0
	foreach opt in hetero scale eq2 {
		if "``opt''"!="" local het_options = `het_options' + 1
	}
	if `het_options' > 1 {
		display as error "hetero, scale & eq2 are synonyms - use only one of them"
		exit 198
	}
	
	local hetero `scale' `hetero' `eq2'

	if "`hetero'" !="" {
		_rmcoll `hetero' if `touse', expand `collinear'
		local hetero `r(varlist)'
	}
	
	// Flip the 2 equations if so requested.  This is mainly useful
	// if using the sw or nestreg prefixes.
	if "`flip'"!="" {
		local vhetero `x'
		local vx `hetero'
		local hetero `vhetero'
		local x `vx'
	}

	// oglmx = 1 if there are X vars, 0 otherwise
	local Numx: word count `x'
	global oglmx = "`x'" != ""

	// oglmh = 1 if there are hetero vars, 0 otherwise
	local Numh: word count `hetero'
	global oglmh = "`hetero'" != ""

	// labeling of equations & model
	if $oglmh {
		local link_title Heteroskedastic `link_title'
		markout `touse' `hetero'
	}
	if "`eqlabel'"=="" {
		local eq1label `y'
		local eq2label lnsigma
	}
	else if "`eqlabel'"=="hc" {
		local eq1label choice
		local eq2label variance
	}
	else if "`eqlabel'"=="ls" {
		local eq1label location
		local eq2label scale
	}

	
// Generate all the new things we will need for the models

	// Get Y values from tab
	tempname Y_Values   /* Vector containing the values of the DV */
	quietly tab `y' if `touse', matrow(`Y_Values')
	local M = r(r)
	if `M' > 20 {
		di 
		di as error "`warning'`y' has `M' categories - a maximum of 20 is normally allowed"
		di as error "Make sure you are using an ordinal dependent variable"
		di
		`comment'exit 149
	}
	matrix `Y_Values' = `Y_Values''  /* Transpose the matrix */

	local  numcuts = `M' - 1
	local lastcat = `Y_Values'[1, `M']   /* last category will be base category */
	
	// ll program will use these values to determine 1rst, 2nd, 3rd, etc. values of Y
	macro drop dv_*
	forval i = 1/`M' {
		global dv_`i' = `Y_Values'[1, `i']
	}

// Build equations for full model to be estimated. There are 4 possible
// types of models, depending on whether or not Xs and hetero are specified.
	// First do for models with X's & hetero
	if $oglmx & $oglmh {
		local eqs (`eq1label': `y'=`x', noconstant) (`eq2label': `hetero', noconstant)
		forval i = 1/`numcuts' {
			local eqs "`eqs' (cut`i':)"
		}
	}
	// Next do Xs but no hetero
	else if $oglmx & !$oglmh {
		local eqs (`eq1label': `y'=`x', noconstant)
		forval i = 1/`numcuts' {
			local eqs "`eqs' (cut`i':)"
		}
	}

	// Next do hetero only, no Xs
	else if !$oglmx & $oglmh {
		local eqs (`eq2label': `y' = `hetero', noconstant)
		forval i = 1/`numcuts' {
			local eqs "`eqs' (cut`i':)"
		}
	}
	// Finally, no Xs & no hetero, i.e. cutpoints only
	else if !$oglmx & !$oglmh {
		local eqs (cut1: `y'=)
		forval i = 2/`numcuts' {
			local eqs "`eqs' (cut`i':)"
		}
	}

// Start values for each type of link will be in matrix b0
// The Start_Values subroutine will generate the start values
	tempname b0

// Estimate the constant-only model 
	Start_Values `y',  /// 
		wgt(`wgt') touse(`touse') `robust' clopt(`clopt') ///
		numcuts(`numcuts') b0(`b0')  ///
		link(`link') eqsx(`eqsx')  ///
		constraints(`constraints') ///
		mlopts(`mlopts') 
		
	local initopt `s(initopt)'
	if "`s(LL0)'"!="" local LL0 = `s(LL0)'
	
	if "`startvals'" != "" mat `b0' = `startvals'	// ben shear added this

// Estimate the final model; and add some stats

	ml model lf oglm_ll `eqs' `wgt' if `touse', 		///
		constraints(`constraints') `robust'  `clopt' 	 	///
		waldtest(-`numcuts') `initopt' title(`link_title') 	///
		collinear missing maximize nocnsnotes 			///
		`score' `nolog' `mlopts'

	ereturn repost, buildfvinfo ADDCONS
		
	// e(k_aux) tells Stata how many cutpoints there are.  If you don't
	// have this, everything gets printed out as separate equations.
	local numcuts2 `numcuts'
	ereturn scalar k_aux = `numcuts'
	ereturn scalar k_exp = `numcuts2'
		
	if "`LL0'"!="" ereturn scalar ll_0 = `LL0'

	// Compute McFadden's Pseudo R^2 if necessary info exists, i.e. it won't 
	// be possible after using svy because svy does not return it.
	// Also, Stata ml does not rescale pweights, but oglm will
	if (e(ll) < . & e(ll_0) < .) {
		if "`weight'" == "pweight" {
			local wgtvar: word 2 of `=e(wexp)'
			quietly sum `wgtvar' if e(sample)
			ereturn scalar ll = e(ll)/ r(mean)
		}
		ereturn scalar r2_p = 1 - (e(ll) / e(ll_0) )
	}

	// Stata reports a Wald rather than LR test whenever constraints have been imposed.
	// The lrforce parameter makes Stata report a LR test instead, provided
	// crittype is log likelihood.  Use this at your own risk
	local crittype = e(crittype)
	local chi2type = e(chi2type)
	if "`lrforce'"!="" & "`crittype'"=="log likelihood" & "`chi2type'"!="LR" {
		ereturn local chi2type "LR"
		ereturn scalar chi2 = -2 * (e(ll_0) - e(ll))
		ereturn scalar p = chi2tail(e(df_m),e(chi2))
	}

// Adapted from ologit.ado Stata 14 -- additional margins support for V 14
// I use some different names than ologit because I created equivalents 
// of them earlier, e.g. M instead of ncat
	forval i = 1/`M' {
			local j = `Y_Values'[1,`i']
			local mdflt `mdflt' predict(pr outcome(`j'))
	}
	ereturn local marginsdefault `"`mdflt'"'

// Return assorted values
	ereturn local xvars `x'
	ereturn local hetero `hetero'
	ereturn scalar k_cat = `M'
	ereturn scalar basecat = `lastcat'
	ereturn scalar ibasecat = `M'
	ereturn matrix cat = `Y_Values'
	ereturn scalar k_eform = 1
	ereturn scalar k_eq_model = e(k_eq) - e(k_aux)
	ereturn local link `link'

	

// Final cleanup

	macro drop oglmx oglmh Link dv_*

	ereturn local predict "oglm_p"
	ereturn local cmd "oglm"

	ereturn local marginsprop addcons
	ereturn local marginsok pr xb
	ereturn local marginsnotok sigma stdp

// display the results

	Replay, `diopts' store(`store')
	
end


************************

program Start_Values, sclass
* Gets the start values (i.e. the values of the cutpoints-only model)
	version 11.1
	syntax varname , 	///
		[robust clopt(string) ///
		wgt(string) touse(varname) b0(name) numcuts(integer -1) ///
		link(string) eqsx(string) ///
		constraints(string) ///
		mlopts(string) ]
	local numcuts = `numcuts'
	local M = `numcuts' + 1
	local y `varlist'
	
// Matrix b0 will contain the cumulative probabilities for each category
// LL0 will contain the log likelihood 0 for non-svy models
	quietly proportion `y' `wgt' if `touse' , `clopt' nolabel
	mat `b0' = e(b)
	forval j = 1/`M' {
		local LL0 = `LL0' + `e(N)' * `b0'[1, `j'] * ln(`b0'[1,`j'])
	}
	mat `b0' = `b0'[1, 1..`numcuts']
			
	// Now we convert the b's to cumulative percentages
	forval j = 2/`numcuts' {
		local i = `j' - 1
			mat `b0'[1, `j'] = `b0'[1, `j'] + `b0'[1, `i']
	}


// Convert as needed for the link function used. Remembers signs  are
// the opposite of gologit2
	if "`link'"=="logit" {
		forval j = 1/`numcuts' {
			mat `b0'[1,`j'] = logit(`b0'[1,`j'])
		}
	}
	else if "`link'"=="probit" {
		forval j = 1/`numcuts' {
			mat `b0'[1,`j'] = invnormal(`b0'[1,`j'])
		}
	}
	else if "`link'"=="cloglog" {
		forval j = 1/`numcuts' {
			mat `b0'[1,`j'] = -cloglog(1-`b0'[1,`j'])
		}
	}
	else if "`link'"=="loglog" {
		forval j = 1/`numcuts' {
			mat `b0'[1,`j'] = cloglog(`b0'[1,`j'])
		}
	}
	else if "`link'"=="cauchit" {
		forval j = 1/`numcuts' {
			mat `b0'[1,`j'] = tan(_pi * (`b0'[1,`j'] - .5))
		}
	}
	else if "`link'"=="log" {
		forval j = 1/`numcuts' {
			mat `b0'[1,`j'] = -ln(1-`b0'[1,`j'])
		}
	}


	forval i = 1/`numcuts' {
		local columnames `columnames' cut`i':_cons
	}
	matrix colnames `b0' = `columnames'

	// Below, Ben Shear added the " , skip" option which has no impact on default functioning of -oglm-
	local initopt init(`b0' , skip) lf0(`numcuts' `LL0')	
	sreturn local initopt `initopt'
	if "`LL0'"!="" sreturn local LL0 `LL0'

end

************************

program Replay, eclass
	version 11.1
	syntax [,				///
	Level(cilevel)			 	///
	or irr rrr hr EForm 			///
	STOre(name)				///
	* ]
	
	// make sure only one eform specified.  If so, it will
	// be local macro eform
	local eform `or' `irr' `rrr' `hr' `eform'
	if `:list sizeof eform' > 1 {
		opts_exclusive "`eform'"
	}

	
	// Make sure equation names show if hetero equation is being used
	if "`e(hetero)'" !="" local showeqns showeqns
	
	_get_diopts diopts , `options' 
	local diopts `diopts' `eform' level(`level') `showeqns'
	ml display , `diopts'
	
	
	// Store results if requested
	if "`store'"!="" estimates store `store'

end
