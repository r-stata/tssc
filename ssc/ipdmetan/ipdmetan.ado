* ipdmetan.ado
* Individual Patient Data (IPD) meta-analysis of main effects or interactions

* Originally written by David Fisher, July 2008

* November 2011/February 2012
* Major updates:
// Screen output coded within -ipdmetan- rather than using -metan- external command
//   to enable specific results to be presented

* September 2012
* Aggregate data and IPD able to be pooled in same meta-analysis

* November 2012
* Forest-plot output coded within -ipdmetan- using code modified from metan v9 (SJ9-2: sbe24_3)
//  Acknowledgements and thanks to the authors of this code.

* November 2012
//  "over()" functionality added

* January 2013
//  Changed to "prefix" -style syntax, following discussion with Patrick Royston

* March 2013
* Functionality of -ipdmetan- and -ipdover- completely separated.
//    -ipdmetan- now ONLY does pooled meta-analysis
//  Anything else, e.g. non trial-level subgroups, over(), general forest plots etc., must be done via -ipdover-
//    and will not use pooling, inverse-variance weights, etc.
//    (although I-V weights still used in forest plots as a visual aid)

* June 2013
* Discussion with Ross Harris
//  Improved ability to analyse aggregate data alone using separate program -admetan-
//     together with some rearrangement of syntax, options & naming conventions

* September 2013
* Presented at UK Stata Users Meeting
//  Reworked the plotid() option as recommended by Vince Wiggins

* version 1.0  David Fisher  31jan2014
* First released on SSC

* version 1.01  David Fisher  07feb2014
* Reason: fixed bug - Mata main routine contained mm_root, so failed at compile even if mm_root wasn't actually called/needed

* version 1.02  David Fisher  10feb2014
* Reason:
//  - fixed bug with _rsample
//  - fixed bug causing syntax errors with "ipdmetan : svy : command" syntax

* version 1.03  David Fisher  02apr2014
* Reason:
//  - return F statistic for subgroups
//  - correct error in `touse' when passed from admetan
//  - correct error in behaviour of stacklabel under certain conditions (line 2307)

* version 1.04  David Fisher  09apr2014
* Reason:
//  - fixed bug with DerSimonian & Laird random-effects
//  - fixed bug which failed to drop tempvar containing held estimates
//  - fixed bug in output table title when using ipdover
//  - _rsample now returned for admetan too
//  - added ovwt/sgwt options

* version 1.05  David Fisher 05jun2014
* Submitted to Stata Journal
//  - added Kontopantelis's bootstrap DL method and Isq sensitivity analysis
//      and Rukhin's Bayesian tausq estimators
//  - revisited syntax for Hartung-Knapp t-based variance estimator (and removed "t" option)
//  - changes to names of some saved results, e.g. mu_hat/se_mu_hat are now eff/se_eff
//      also "study" is preferred to "trial" throughout, except for ipdover
//  - improved parsing of prefix/mixed-effects models (i.e. those containing one or more colons)
//      also improved management of non-convergence and user breaking

* version 1.06  David Fisher 23jul2014
* Reason:
//  - Corrected AD filename bug (line 437)
//  - ipdover now uses subgroup sample size as default weight, rather than inverse-variance
//      (as suggested by Phil Jones, and as seems to be standard practice in literature)

* version 1.07  David Fisher, 29jun2015
* Major update to coincide with publication of Stata Journal article
//  - Corrected "Cochrane Q" to "Cochran Q"
//  - Improved behaviour of "nohet" and "notab"
//  - Added cumulative MA option(cf metacum) (done Dec 2014)
//  - Added Kenward-Roger variance estimator (using expected information, not observed) (done Feb 2015)
//  - Generally deals better with sitations where only one estimate (or zero estimates for specific subgroups)
//  - Work-around for bug in _prefix_command which fails with "if varname="label":lblname" syntax (done May 2015)
//  - Corrected implementation of empirical Bayes random-effects model (done June 2015)
//  - Fixed bugs in forestplot.ado:
//      lcols/rcols varnames without varlabels (the "must specify at least one of target or maxwidth" error)
//      use of char(160) to represent non-breaking spaces (the "dagger" error)

* version 2.0  David Fisher  11may2017
* Major update to extend functionality beyond estimation commands; now has most of the functionality of -metan-
//  - Reworked so that ipdmetan.ado does command processing and looping, and admetan.ado does RE estimation (including -metan- functionality)
//  - Hence, ipdover calls ipdmetan (but never admetan); ipdmetan calls admetan (if not called by ipdover); admetan can be run alone.
//      Any of the three may call forestplot, which of course can also be run alone.
//  - See admetan.ado for further notes

* version 2.1  David Fisher  14sep2017
// various bug fixes; improvements to wgt() option

* version 3.0  David Fisher  08nov2018
// various bug fixes and minor improvements
// now includes IPD+AD code previously within admetan.ado
//   so that admetan is completely self-contained

// For future version:
//  - allow by() AND byad??  (with the effect that studies are stratified by both "by" and "source")
//  - see statalist post re weights with -teffects-

* version 3.1  David Fisher  04dec2018
// only pass straight to admetan_setup if one obs per study *AND* "`cmdstruc'"=="specific"
// minor correction/clarification to options `admopts' passed to -admetan-

*! version 3.2  David Fisher  28jan2019
// GetNewname adds an extra underscore where `newname' matches _[A-Z] (and hence would o/w be caught by "badnames")
// Fixed bugs preventing help file examples from running



program define ipdmetan, rclass

	version 11.0
	local version : di "version " string(_caller()) ":"
	* NOTE: mata requires v9.x
	* factor variable syntax requires 11.0

	
	*******************************
	* Determine command structure *
	*******************************

	** Test for which command structure is being used
	// "generic" effect measure / Syntax 1  ==> ipdmetan [exp_list] .... : [command] [if] [in] ...
	// (calculations based on an estimation model fitted within each study)
	
	// "specific" effect measure / Syntax 2 ==> ipdmetan varlist [if] [in] ...  **no colon**
	// (raw event counts or means (SDs) within each study using some variation on -collapse-)
	
	cap _on_colon_parse `0'
	local rc = _rc
	if !_rc {
		local before `"`s(before)'"'
		local 0      `"`s(before)'"'
		local after  `"`s(after)'"'
	}
	
	// Quick parse to extract options needed in early part of the code
	syntax [anything(name=exp_list equalok)] [if] [in] [fw aw pw iw] , [ ///
		Level(passthru)           /// needed for _prefix_command
		STUDY(string) BY(string)  ///
		SORTBY(string)            /// optional sorting varlist
		IPDOVER(string)           /// options passed through from ipdover (see ipdover.ado & help file)
		AD(string)                /// optionally incorporate aggregate-data (mainly used within admetan_setup subroutine)
		FORESTplot(passthru)      /// options to pass through to forestplot
		* ]                       // remaining options will be parsed later		
	
	local bif `"`if'"'				// "before" if
	local bin `"`in'"'				// "before" in
	if `"`weight'"' != `""' local bweight `"[`weight'`exp']"'
	local opts_ipdm `"`macval(options)'"'
	
	if !`rc' {
		local cmdstruc generic		// "generic" effect measure, i.e. Syntax 1; "command"-based syntax (see help file)
	
		cap confirm var `exp_list'
		local rc = cond(_rc, 0, 101)			// give error if _rc is ZERO, i.e. if `exp_list' is a varlist
		cap {
			assert trim(itrim(`"`bif'`bin'"'))==`""'	// [if] [in] cannot be specified before the colon under this structure
			assert trim(itrim(`"`bweight'"'))==`""'		// ...and nor can weights
		}
		local rc = cond(`rc', `rc', _rc)	

		cap nois ProcessCommand `after'
		if _rc {
			if _rc==1 nois disp as err `"User break in {bf:ipdmetan.ProcessCommand}"'
			else nois disp as err `"Error in {bf:ipdmetan.ProcessCommand}"'
			c_local err noerr		// tell ipdover not to also report an "error in {bf:ipdmetan}"
			exit _rc
		}
		local cmdname `s(cmdname)'
		local cmdbefore `"`s(cmdbefore)'"'
		local cmdafter  `"`s(cmdafter)'"'
		local cmdifin   `"`s(cmdifin)'"'
		local efopt     `"`s(efopt)'"'
		if `"`s(level)'"'!=`""' local level `"level(`s(level)')"'
		
		* Re-assemble full command line and return
		// (do this now to allow for user error-checking with "return list")
		local finalcmd = trim(itrim(`"`cmdbefore' `cmdifin' `cmdafter'"'))
		return local command `"`finalcmd'"'
		return local cmdname `"`cmdname'"'
	}

	else {
		local cmdstruc specific		// "specific" effect measure, i.e. Syntax 2; "collapse"-based syntax (see help file)

		cap confirm var `exp_list'
		local rc = _rc							// give error if _rc is NONZERO, i.e. if `exp_list' is *not* a valid varlist
		local invlist : copy local exp_list
		local exp_list				// clear macro
		
		local cmdifin `"`bif' `bin'"'
		local cmdwt `"`bweight'"'
	}
	
	if `rc' {
		local cmdtxt = cond(`"`ipdover'"'!=`""', "ipdover", "ipdmetan")
		nois disp as err `"Invalid {bf:`cmdtxt'} syntax.  One and only one of the following syntaxes is valid:"'
		nois disp as err `"{bf:1.} "' as text `"{bf:`cmdtxt'} ... : {it:command} ... [{it:if}] [{it:in}] ..."'
		nois disp as err `"or {bf:2.} "' as text `"{bf:`cmdtxt'} {it:varlist} [{it:if}] [{it:in}], ... "'
		
		if "`cmdstruc'" == "generic" {
			disp as err `"Syntax {bf:1.} detected, "' _c
			if `rc'==101 disp as err `"so {it:varlist} cannot be given before the colon."'
			else disp as err `"so [{it:if}] [{it:in}] cannot be given before the colon."'
		}
		else if "`cmdstruc'" == "specific" {
			nois disp as err `"Syntax {bf:2.} detected, "' _c
			if trim(itrim(`"`invlist'"'))==`""' disp as err `"but {it:varlist} has not been supplied."'
			else {
				nois disp as err `"but one or more elements of {it:varlist} were not found."' _n
				cap nois confirm variable `invlist'
			}
		}
		exit `rc'
	}
	
	

	************************************
	* Setup of data currenly in memory * 
	************************************

	local 0 `"`invlist' `cmdifin'"'
	syntax [varlist(numeric max=6 default=none)] [if] [in]
	marksample touse
		
	// Quickly extract `study' varname from option
	local studyopt `study'							// full option (including `missing' if supplied), for ProcessAD
	local 0 `study'
	syntax [varlist(default=none)] [, Missing]
	local smissing `missing'
	local study `varlist'
	
	local overlen: word count `study'
	cap confirm var `study'
	if `"`ipdover'"'==`""' {
		if _rc {
			nois disp as err `"{bf:study()} is required with {bf:ipdmetan}"'
			exit 198
		}
		if `overlen'>1 {
			disp as err "{bf:study()} should only contain a single variable name"
			exit 198
		}	
		qui count if `touse'
		if !r(N) {
			nois disp as err "no valid observations in {bf:study()}"
			exit 2000
		}
	}
		
	// Quickly extract `by' varname from option (N.B. this will be parsed properly later)
	local byopt `by'						// full option (including `missing' if supplied), for ProcessAD
	local 0 `by'
	syntax [name(name=by)] [, Missing]		// only a single (var)name is allowed
	local bymissing `missing'

	local by_rc = 0
	if `"`by'"'!=`""' {
		cap confirm var `by'
		if _rc {
			if `"`ad'"'==`""' {															// `by' may only NOT exist in memory
				nois disp as err `"variable {bf:`by'} not found in option {bf:by()}"'	// if an external aggregate-data file is specified.
				exit 111																// (and even then, it must exist there! - tested for later)
			}
		}
		else if `"`bymissing'"'==`""' markout `touse' `by', strok
		local by_rc = _rc
		
		qui count if `touse'
		if !r(N) {
			nois disp as err `"No non-missing observations in variable {bf:`by'} (in option {bf:by()})"'
			nois disp as err `"Please use the {bf:missing} suboption to {bf:by()} if appropriate"'
			exit 2000
		}
	}
	
	// Process `sortby' option
	if `"`sortby'"'!=`""' {
		if `"`ipdover'"'!=`""' {
			nois disp as err `"{bf:sortby()} may not be used with {bf:ipdover}"'
			exit 198
		}
		else {
			cap confirm var `sortby'
			if _rc & `"`sortby'"'!="_n" {
				if `"`ad'"'==`""' {
					nois disp as err `"variable {bf:`sortby'} not found in option {bf:sortby()}"'
					exit _rc
				}
				local ad `"`ad' adsortby(`sortby')"'	// if not found in IPD, add to ad() option to check in AD data
				local sortby							// don't need anymore in -ipdmetan-
			}
		}
	}

		
	** If necessary, parse forestplot options to extract those relevant to ipdmetan
	// N.B. Certain options may be supplied EITHER to ipdmetan directly, OR as sub-options to forestplot()
	//      (e.g. if relevant whether or not a forestplot is requested).
	
	* "Forestplot options" are prioritised over "ipdmetan options" in the event of a clash.
	// These options are:
	// nograph, nohet, nooverall, nosubgroup, nowarning, nowt
	// effect, hetstat, lcols, rcols, plotid, ovwt, sgwt, sgweight
	// cumulative, efficacy, influence, interaction
	// counts, group1, group2 (for compatibility with metan.ado)
	// rfdist, rflevel (for compatibility with metan.ado)	

	// For estimation commands, -eform- options (plus extra stuff parsed by CheckOpts e.g. `rr', `rd', `md', `smd', `wmd', `log')
	//   behave the same way.
	// However, for "raw data", these options may only "clash" (i.e. be subject to prioritisation) in terms of whether on/off,
	//   not in terms of the actual statistic used (that would be a "true" clash, resulting in an exit with error).
	
	// N.B. At this stage we also want to isolate the effect MEASURE, to be sent to admetan.ado in the summstat() option.
	// (METHODs of analysis are not dealt with here, but in admetan.ado.)
	
	cap nois ParseFPlotOpts, cmdname(`cmdname') mainprog(ipdmetan) options(`opts_ipdm') `forestplot'
		
	if _rc {
		if _rc==1 nois disp as err `"User break in {bf:ipdmetan.ParseFPlotOpts}"'
		else nois disp as err `"Error in {bf:ipdmetan.ParseFPlotOpts}"'
		c_local err noerr		// tell ipdover not to also report an "error in {bf:ipdmetan}"
		exit _rc
	}
	
	local eform    `s(eform)'
	local log      `s(log)'
	local summstat `s(summstat)'
	local effect     `"`s(effect)'"'
	local opts_ipdm  `"`s(opts_parsed)' `s(options)'"'		// options as listed above, plus other options supplied directly to admetan
	local opts_fplot `"`s(opts_fplot)'"'					// other options supplied as sub-options to forestplot() 	

	
	** Now, if one observation per study, pass directly to -admetan- ...
	if `"`ipdover'"'==`""' {
		qui tab `study' if `touse', `smissing'
		// if r(r)==r(N) {		
		// Dec 2018: added "`cmdstruc'"=="specific"
		if r(r)==r(N) & "`cmdstruc'"=="specific" {
			if `"`smissing'"'==`""' {
				markout `touse' `study', strok		// can't do this in main routine due to possibility of `study' as a varlist (if ipdover)
				qui count if `touse'
				if !r(N) {
					nois disp as err "no valid observations in {bf:study()}"
					exit 2000
				}
			}
			
			local sortby = cond("`sortby'"=="_n", "", "`sortby'")
			cap nois admetan_setup `invlist' if `touse', study(`studyopt') by(`byopt') ///
				sortby(`sortby') ad(`ad') forestplot(`opts_fplot') ///
				effect(`effect') summstat(`summstat') `eform' `log' `opts_ipdm'

			if _rc {
				if `"`err'"'==`""' {
					if _rc==1 nois disp as err `"User break in {bf:ipdmetan.admetan_setup}"'
					else nois disp as err `"Error in {bf:ipdmetan.admetan_setup}"'
				}
				exit _rc
			}
						
			return add
			exit
		}
		
		// If not sending directly to -admetan-, default sorting is `study'
		local sortby = cond("`sortby'"=="_n", "", cond("`sortby'"!="", "`sortby'", "`study'"))
	}

	
	
	** Sort out whether parsed options go into `fplotopts' or not
	// ...and also parse any options that will be needed in ipdmetan.ado but have not yet been parsed
	local 0 `", `opts_ipdm'"'
	syntax [, ///	
		/// General options
		CItype(string)            /// CIs for individual studies (NOT for pooled results)
		/*EFFect(string)*/            /// user-defined effect label
		SAVING(string)            /// specify filename in which to save results set
		noRSample                 /// don't leave behind "_rsample" [analog of e(sample), used here as ipdmetan.ado is not e-class]
		SGWt SGWEIGHT             /// if `by', weight by subgroup rather than overall
		WGT(string)               /// specify weights, via a (numeric) varname or a returned statistic
		noOVerall noSUbgroup      /// suppress reporting of by-sugbroup or overall pooled effects
		/// Options relevant to particular subroutines
		INTERaction noTOTal       /// mainly relevant to CommandLoop but also needed beforehand
		MEssages                  /// only relevant to CommandLoop
		POOLvar(string)           /// mainly relevant to CommandLoop but also needed beforehand (N.B. "string" as may include equation names)
		STrata(varlist) noSHow    /// only relevant to LogRankHR
		Over(string)              /// for error-trapping only
		/// Options mostly relevant to forestplot, but also needed beforehand
		LCols(string asis) RCols(string asis) PLOTID(string) COUNTS(passthru) ///
		/*CUmulative INFluence RFDist EFFIcacy OEV COUNTS(passthru)*/ /// for "badnames"
		noGRaph noHET noWT noEXTRALine ///
		/// Undocumented options
		ZTOL(passthru)            /// ztol = tolerance for z-score (abs(ES/seES))
		* ]                       // Remaining options will be passed through to admetan.ado

	local extraline = cond("`extraline'"!="", "no", "")			// for clarity later
	local sgwt = cond("`sgweight'"!="", "sgwt", "`sgwt'")		// sgweight is a synonym (for compatibility with metan.ado)
	local opts_ipdm = trim(`"`macval(options)' `counts' `sgwt'"')

	
	// if ipdover, return `wt' separately; otherwise, add to `fplotopts'
	if "`ipdover'"!="" cap return local wt `wt'
	else local opts_fplot = trim(`"`macval(opts_fplot)' `wt'"')		// add straight to fplotopts; not needed any more by ipdmetan

	
	** Option compatibility tests relevant to -ipdover- and "generic" vs "specific" effect measure
	// (N.B. leave more specific MA-related compatibility tests to admetan.ado)
	if `"`exp_list'"'!=`""' & `"`interaction'"'!=`""' {
		nois disp as err `"{it:exp_list} and {bf:interaction} may not be combined"'
		exit 184
	}
	if `"`exp_list'"'!=`""' & `"`poolvar'"'!=`""' {
		nois disp as err `"{it:exp_list} and {bf:poolvar()} may not be combined"'
		exit 184
	}
	if `"`command'"'!=`""' & `"`total'"'!=`""' {
		if `"`exp_list'"'==`""' & `"`poolvar'"'==`""' {
			nois disp as err `"Cannot specify {bf:nototal} without one of {it:exp_list} or {bf:poolvar()}"'
			exit 198
		}
		if `"`ipdover'"'!=`""' local overall "nooverall"
	}
	if `"`over'"'!=`""' {
		nois disp as err `"Cannot specify {bf:over()} with {bf:ipdmetan}; please use {bf:ipdover} instead"'
		exit 198
	}
	if `"`cmdstruc'"'==`"generic"' {
		local 0 `", `opts_ipdm'"'
		syntax [, MH PETO LOGRank COHen HEDges GLAss noSTANdard * ]		// N.B. `counts' has already been parsed [May 2018: ...and `group1', `group2' removed]
		if trim(`"`mh'`peto'`logrank'`cohen'`hedges'`glass'`standard'`counts'"') != `""' {
			local erropt : word 1 of `mh' `peto' `logrank' `cohen' `hedges' `glass' `standard' `counts'
			nois disp as err `"option {bf:`erropt'} is incompatible with {it:command}-based syntax (Syntax 1)"'
			exit 198
		}
		local opts_ipdm `"`macval(options)'"'
	}

	// Check for options supplied to ipdover which should only be supplied to the ad() option of ipdmetan
	if `"`ipdover'"'!=`""' {
		local 0 `", `opts_ipdm'"'
		syntax [, NPTS(string) BYAD VARS(string) * ]
		if trim(`"`ad'`npts'`byad'`vars'"') != `""' {
			local erropt = cond("`ad'"!="", "ad()", "")
			local erropt = cond("`erropt'"=="", "`: word 1 of `npts' `byad' `vars''", "`erropt'")
			nois disp as err `"option {bf:`erropt'} is an invalid option with {bf:ipdover}"'
			exit 198
		}
		local opts_ipdm `"`macval(options)'"'
	}


	** Sort out subgroup identifier (BY) and labels
	// (N.B. `by' might only exist in an external (aggregate) dataset)
	local bystr=0
	if `"`by'"'!=`""' & !`by_rc' {				// if `by' is present in the current dataset -- this much has already been established
		local byvarlab : variable label `by'
		if `"`byvarlab'"'==`""' local byvarlab `"`by'"'

		// Now see if `by' is numeric or string
		tempname bylab
		cap confirm numeric var `by'
		assert inlist(_rc, 0, 7)
		local bystr = _rc	// var exists but is string, not numeric (save in local so that -capture- can be used again)

		if !`bystr' {		// if numeric
			tempname bymat
			local matrowopt `"matrow(`bymat')"'
		}
			
		cap tab `by' if `touse', /*`bymissing'*/ `matrowopt'
			if _rc {
			nois disp as err `"variable {bf:`by'} in option {bf:by()} has too many levels"'
			exit 134
		}

		if `bystr' {
			tempvar bytemp
			qui encode `by' if `touse', gen(`bytemp') lab(`bylab')		// save label
			local _BY `bytemp'											// refer to new variable
		}
		else {
			cap assert `by'==round(`by')
			if _rc {
				nois disp as err `"variable {bf:`by'} in option {bf:by()} must be integer-valued or string"'
				exit 198
			}
			
			// form temp value label from bymat
			forvalues i=1/`r(r)' {
				local byi = `bymat'[`i', 1]
				if `byi'!=. {
					local labname : label (`by') `byi'
					label define `bylab' `byi' "`labname'", add
				}
			}
			local _BY `by'		// `_BY' is now a guaranteed-numeric version of `by'
		}
			
		// save "by" value label
		cap lab list `bylab'
		if !_rc {
			tempfile bylabfile
			qui label save `bylab' using `bylabfile'
		}
	}		// end if `"`by'"'!=`""'

	else {
		// Unless ad(), test for `subgroup' without `by'
		if `"`subgroup'"'!=`""' & `"`ad'"'==`""' {
			nois disp as err `"Note: {bf:nosubgroup} cannot be specified without {bf:by()} and will be ignored"'
			local subgroup
		}
	}
	

	*******************
	* Define Study ID * (or `over' vars)
	*******************
	
	// If "`ipdover'"=="", `StudyID' is an ordinal identifier based on requested sort order,
	//   and will be needed throughout the code (regardless of `cmdstruc')
	
	// If "`ipdover'"!="", `StudyID' will still be used within CommandLoop to identify over() groups (and simplify coding)
	//   but is not strictly necessary and can be dropped as soon as `ipdfile' is loaded.
	// In thisc case, not needed for "`cmdstruc'"=="specific" at all.
	if `"`ipdover'"'==`""' {
		tempvar StudyID
		tempfile ipdfile labfile
		
		// If `study' is string, it will be processed by ProcessIDs and assigned varname `tv1' with value label `vallab1'
		// Otherwise (if already numeric), make a temp copy of existing *value label* (the *varname* is not important)
		cap confirm numeric variable `study'
		if !_rc {
			if `"`: value label `study''"'!=`""' {
				tempname studylab
				label copy `: value label `study'' `studylab'
			}
		}
		
		// If IPD+AD, we may also need to know if `study' was originally (i.e. in IPD) string: this is `ipdstr'
		else local ipdstr ipdstr
	}

	else {
		local 0 `", `ipdover'"'
		syntax [, IPDFILE(string) LABFILE(string) OUTVLIST(namelist) LRVLIST(namelist)]
		local ipdover ipdover
	}
	tempvar obs

	// declare a tempvar name for each element in `study', in case any string vars need to be decoded
	forvalues h=1/`overlen' {
		tempvar tv`h'
		local tvlist `"`tvlist' `tv`h''"'		// tvlist = "temp varlist"
		tempname vallab`h'
		local tnlist `"`tnlist' `vallab`h''"'	// tnlist = "temp namelist" (to store value labels)
	}
	
	// - if IPD/AD meta-analysis (i.e. not ipdover), create subgroup ID based on order of first occurrence
	// - decode any string variables (including if ipdover)
	cap nois ProcessIDs if `touse', study(`studyopt') studyid(`StudyID') by(`_BY') obs(`obs') ///
		tvlist(`tvlist') tnlist(`tnlist') labfile(`labfile') ///
		sortby(`sortby') cmdstruc(`cmdstruc') plname(`plname') `ipdover'
	
	if _rc {
		if _rc==1 nois disp as err `"User break in {bf:ipdmetan.ProcessIDs}"'
		else nois disp as err `"Error in {bf:ipdmetan.ProcessIDs}"'
		c_local err noerr		// tell ipdover not to also report an "error in {bf:ipdmetan}"
		exit _rc
	}

	if `"`ipdover'"'!=`""' {
		local overtype `r(overtype)'	// int, float or double
		forvalues h=1/`overlen' {
			return local varlab`h' `"`r(varlab`h')'"'
		}
	}
	else local svarlab `"`r(varlab1)'"'
	/*
		{
		// If IPD+AD, we may also need to know if `study' was originally (i.e. in IPD) string: this is `ipdstr'
		if `"`ad'"'!=`""' {
			local ipdstr = cond(trim(`"`study'"') == trim(`"`r(study)'"'), "", "ipdstr")
			local ad `"`ad' `ipdstr'"'
		}
		local svarlab `"`r(varlab1)'"'
	}
	// OCT 2018: Do we need to know `ipdstr' at all??
	
	*/	
	local studylist `r(study)'			// contains de-coded string vars if present (`study' still contains original varname)
	local _STUDY = cond(`"`ipdover'"'!=`""', "_LEVEL", "_STUDY")


	
	*******************
	* lcols and rcols *
	*******************
	
	foreach x in na nc ncs nr nrn nrs ni {
		local `x'=0		// initialise
	}
	
	local het = cond(`"`ipdover'"'==`""', `"`het'"', `"nohet"')
	
	if trim(`"`lcols'`rcols'"')==`""' | (`"`saving'"'==`""' & `"`graph'"'!=`""' & `"`citype'"'==`"normal"') {
		// if lcols/rcols will not be used,
		// (either because not specified, or because no savefile and no graph and no need for _df)  JULY 2017 citype here???
		// clear the macros
		local lcols
		local rcols
	}
	
	else {
		cap nois ParseCols `lcols' : `rcols'
		if _rc {
			if _rc==1 nois disp as err `"User break in {bf:ipdmetan.ParseCols}"'
			else nois disp as err `"Error in {bf:ipdmetan.ParseCols}"'
			c_local err noerr		// tell ipdover not to also report an "error in {bf:ipdmetan}"
			exit _rc
		}
		
		local lcols								// clear macro
		local rcols								// clear macro

		local itypes     `"`s(itypes)'"'		// item types ("itypes")
		local fmts       `"`s(fmts)'"'			// formats
		local cclist = trim(`"`cclist' `s(cclist)'"')	// clist of expressions for -collapse- (may already contain `"(firstnm) `plname'"')
		local statsr     `"`s(rstatlist)'"'		// list of "as-is" returned stats		
		local sidelist   `"`s(sidelist)'"'		// list of "sides"; temp=0; left=1, right=2
		local csoldnames = trim(`"`csoldnames' `s(csoldnames)'"')	// list of original varnames for strings    (may already contain `plname')
		local coldnames  = trim(`"`coldnames'  `s(coldnames)'"')	// list of original varnames for -collapse- (may already contain `plname')
		local lrcols     `"`s(newnames)'"'		// item names (valid Stata names)
	
		* Get total number of "items" and loop, perfoming housekeeping tasks for each item
		local ni : word count `itypes'
		forvalues i=1/`ni' {
			local coli : word `i' of `lrcols'
		
			// form new `lcols' and `rcols', just containing new varnames (to pass to forestplot via admetan/ipdover)
			// also retrieve `tempcols'
			local side : word `i' of `sidelist'
			if !`side' local lcols `lcols' `coli'
			else       local rcols `rcols' `coli'
	
			// separate lists of names for the different itypes
			local itype : word `i' of `itypes'
			if "`itype'"=="a" {								// a: AD-only vars, not currently in memory
				local ++na
				local namesa `namesa' `coli'				// AD varlist, to be passed on to -admetan-
			}
			else if "`itype'"=="c" {						// c: Numeric vars to collapse
				local ++nc
				local namesc `namesc' `coli'
				local nclab`nc' `"`s(cvarlab`nc')'"'
			}
			else if "`itype'"=="cs" {						// cs: String vars to "collapse"
				local ++ncs
				local svars `svars' `coli'
				local ncslab`ncs' `"`s(csvarlab`ncs')'"'
			}
			else if "`itype'"=="r" {						// r: Returned stats (e-class or r-class)
				local ++nr									// (validity to be tested later)
				local namesr `namesr' `coli'
				local nrlab`nr' `"`s(rvarlab`nr')'"'
			}
			
			// if "c" or "r" in "lcols" then a new line will be needed for forestplots (for het etc.)
			// Modified 23rd May 2018
			if `"`het'"'==`""' & inlist("`itype'", "c", "r") & !`side' {
				local extraline = cond("`extraline'"=="", "yes", "`extraline'")
			}
		}		// end forvalues i=1/`ni'
		
		if `"`namesa'"'!=`""' {
			if `"`ad'"'==`""' {
				nois disp as err `"variable {bf:`: word 1 of `namesa''} not found in {bf:lcols()} or {bf:rcols()}"'
				exit 111
			}
			local ad `"`ad' adcolvars(`namesa'))"'
		}

		* Test validity of names -- cannot be any of the names ipdmetan uses for other things
		// To keep things simple, forbid any varnames:
		//  - beginning with a single underscore followed by a capital letter
		//  - beginning with "_counts" 
		// (Oct 2018: N.B. was `badnames')
		local lrcols `lcols' `rcols'
		if trim(`"`lrcols'"') != `""' {
			local cALPHA `c(ALPHA)'
			foreach el of local lrcols {
				local el2 = substr(`"`el'"', 2, 1)
				if substr(`"`el'"', 1, 1)==`"_"' & `: list el2 in cALPHA' {
					nois disp as err `"Variable names such as {bf:`el'} in {bf:lcols()} or {bf:rcols()}, beginning with an underscore followed by a capital letter,"'
					nois disp as err `" are reserved for use by {bf:ipdmetan}, {bf:ipdover} and {bf:forestplot}."'
					nois disp as err `"Please choose an alternative {it:target_varname} for this variable (see {help collapse})"'
					exit 101
				}
				else if substr(`"`el'"', 1, 7)==`"_counts"' {
					nois disp as err `"Variable names beginning {bf:_counts} are reserved for use by {bf:ipdmetan}, {bf:ipdover} and {bf:forestplot}."'
					nois disp as err `"Please choose an alternative {it:target_varname} for this variable (see {help collapse})"'
					exit 101
				}
			}
		}
	}		// end else (i.e. if not trim(`"`lcols'`rcols'"')==`""' | (`"`saving'"'==`""' & `"`graph'"'!=`""'))

	
	** In addition to user-defined columns (to be displayed on the forestplot and/or saved in the dataset),
	// we may find it useful to define additional "columns" e.g. for calculation purposes,
	// which may or may not appear on the forestplot or in the saved dataset.
	
	// N.B. Content of a "column" is uniquely defined by:
	// [if returned stat] - the rstat name alone
	// [if clist element] - the (stat) name plus the variable in memory to apply it to.
	
	
	* (1) If citype is other than normal, or if cumulative and using dlt/KR, will need a column for df
	//  sort out citype here, as that requires the returned stat e(df_r).
	//  we will sort out dlt/KR later on.
	local citype = cond(inlist(`"`citype'"', `""', `"z"'), `"normal"', `"`citype'"')	// default is citype(normal)
	if `"`citype'"'!=`"normal"' {
		local pos : list posof `"(e(df_r))"' in `statsr'
		if `pos' {
			local _df : word `pos' of `namesr'
		}
		else {
			tempvar _df
			local statsr `"`statsr' e(df_r)"' 
			local namesr `"`namesr' `_df'"'
		}
	}
	
	// 11th June 2017
	* (2) User-defined weights
	if `"`wgt'"'!=`""' {
	
		// Syntax 1:  a collapse-style `clist'
		if "`cmdstruc'"=="specific" {
			GetOpStat stat wgtvar : "mean" `"`wgt'"'
			cap confirm numeric variable `wgtvar'
			if _rc {
				disp as err "Error in option {bf:wgt()}"
				confirm numeric variable `wgtvar'
			}
			local cclist `"`cclist' (`stat') `wgtvar'"'		// `wgt' is a numeric variable; pass to -collapse-
		}

		// Syntax 2:  an expression involving a returned statistic
		else {
			// first, check that it is enclosed in brackets, or _prefix_expand will complain
			gettoken wgt : wgt, bind match(par)
			local wgttitle `"`wgt'"'						// create variable label from "unbracketed" expression
			local wgt = "(" + trim(`"`wgt'"') + ")"			// re-bracket
			
			tempvar wgtvar
			local statsr `"`statsr' `wgt'"'
			local namesr `"`namesr' `wgtvar'"'
		}
	}
	
	// Moved downwards 17th July 2017
	* (3) Parse `plotid'
	// (but keep original contents to pass to forestplot for later re-parsing)
	//  - allow "_LEVEL", "_BY", "_OVER" with ipdover (because data manipulation means can't specify a single current varname)
	//  - else allow "_BYAD" in case of byad, but otherwise must be a variable in memory (in either IPD or AD, if relevant)
	local 0 `plotid'
	syntax [name(name=plname)] [, *]
	local plotidopts = cond(trim(`"`options'"')==`""', `""', `", `options'"')
	
	if `"`ipdover'"'!=`""' {
		if "`plname'" != "" {
			if !inlist("`plname'", "_BY", "_OVER", "_LEVEL", "_n") {
				nois disp as err `"{bf:plotid()} with {bf:ipdover} must contain one of {bf:_BY}, {bf:_OVER}, {bf:_LEVEL} or {bf:_n}"'
				exit 198
			}
			if "`plname'"=="_BY" & "`by'"=="" {
				nois disp as err `"Note: {bf:plotid(_BY)} cannot be specified without {bf:by()} and will be ignored"'
				local plotid		// remove entire `plotid' option
			}
			local plname		// ...but in any case, don't need plname further in -ipdmetan-
		}
	}
	else {
		if "`plname'"=="_BYAD" | ("`plname'"=="`by'" & "`by'"!="" & `by_rc') {		// either _BYAD, or `by' in AD only
			if "`plname'"=="_BYAD" & "`ad'"=="" {
				nois disp as err `"Note: {bf:plotid(_BYAD)} cannot be specified without aggregate data and will be ignored"'
				local plotid
			}
			local plname		// i.e. don't use further in -ipdmetan- (but plotid() will be used in -admetan-)
		}
		else if "`plname'"=="`by'" & "`by'"!="" & !`by_rc' local plotid `"_BY`plotidopts'"'
		else if "`plname'"=="`study'" local plotid `"_STUDY`plotidopts'"'
		else if "`plname'"!="" {
			cap confirm var `plname'				// if `plname' contains a variable name other than _STUDY/_BY
			if _rc {								// check to see if it is in current memory
				if "`ad'"=="" {
					nois disp as err `"variable {bf:`plname'} not found in option {bf:plotid()}"'
					exit _rc
				}
				local ad `"`ad' adplotvar(`plname')"'		// if not found in IPD, add to ad() option to check in AD data
				local plname								// don't need anymore in -ipdmetan-
			}
			else {
				local cclist `"`cclist' (firstnm) `plname'"'		// for -collapse-
				
				cap confirm numeric var `plname'
				if !_rc local coldnames `"`coldnames' `plname'"'	// for LogRankHR, if numeric...
				else local csoldnames  `"`csoldnames' `plname'"'	// ...else if string
			}
		}
	}
	if `"`plotid'"'!=`""' {																	// `plotid' not needed anymore in -ipdmetan- ...
		if `"`ipdover'"'==`""' local opts_ipdm  `"`macval(opts_ipdm)'  plotid(`plotid')"'	// if passing to `admetan', add to `opts_ipdm'...
		else                   local opts_fplot `"`macval(opts_fplot)' plotid(`plotid')"'	// ... else, add to `opts_fplot'
	}

	
	
	**********
	* Branch * - depending on whether we've got an estimation command or raw count data
	**********

	tempvar touse2 tempuse		// touse2 will have various uses later on; tempuse is for comparing with _USE after merging.
								// declare these *before* -preserve- to ensure no clashes with vars originally in the dataset.
	
	if "`rsample'" != "" {
		cap confirm var _rsample
		if !_rc {
			nois disp as err _n `"Warning: option {bf:norsample} specified, but "stored" variable {bf:_rsample} already exists"'
			nois disp as err  "Note that this variable is therefore NOT associated with the most recent analysis."
		}
	}
	qui count
	local origN = r(N)
	
	
	* "command"-based syntax (Syntax 1, see help file)
	if "`cmdstruc'"=="generic" {
		
		// if ad(), record "overall" (_USE==5) anyway, regardless of `overall' macro (unless `nototal' of course!)
		//  (may be removed again later)
		local overallopt = cond(`"`ad'"'!=`""', `""', `"`overall'"')
		local strata_opt = cond(`"`strata'"'==`""', `""', `"strata(`strata')"')		// for error-trapping (Aug 2016)

		// if "`ipdover'"!="", need to pass something to CommandLoop's studyid() option (as a convenience only)
		//  but we don't want to confuse this with `StudyID' as declared for "`ipdover'"=="" (as that will actually be needed).
		//  so use a different tempvar name.
		if `"`ipdover'"'!=`""' tempvar OverID
		local studyidopt = cond(`"`ipdover'"'!=`""', `"`OverID'"', `"`StudyID'"')
		
		cap nois `version' CommandLoop `exp_list' if `touse', ///
			cmdname(`cmdname') cmdbefore(`cmdbefore') cmdafter(`cmdafter') ///
			sortby(`obs') study(`studylist', `smissing') studyid(`studyidopt') ipdfile(`ipdfile') poolvar(`poolvar') ///
			by(`_BY') `ipdover' `interaction' `overallopt' `subgroup' `total' `rsample' ///
			overlen(`overlen') statsr(`statsr') namesr(`namesr') `level' `messages' `ztol' `strata_opt'
			
		if _rc {
			if _rc==1 nois disp as err `"User break in {bf:ipdmetan.CommandLoop}"'
			else nois disp as err `"Error in {bf:ipdmetan.CommandLoop}"'
			c_local err noerr		// tell ipdover not to also report an "error in {bf:ipdmetan}"
			exit _rc
		}

		local n = r(n)
		local estexp `r(estexp)'
		return local estexp `estexp'

		local outvlist _ES _seES		
		preserve
		
	}		// end if "`cmdstruc'"=="generic"

	
	* "Specific" effect measures; "collapse"-based syntax
	else {
		cap assert !`nr'
		if _rc {
			nois disp as err "Cannot specify returned statistics to lcols/rcols without an estimation command"
			exit _rc
		}
		
		
		** For this syntax, how the data is converted from IPD to AD depends on what sort of data it is,
		// i.e. what the summary statistic (`summstat') is.
		// (This isn't as crucial if already AD, as by then it is more obvious what sort of data it is.)
		
		// CheckOpts will have stored the following in summstat():
		// or, hr, shr, irr, rr, rrr, rd, smd or wmd (N.B. md is assumed to be a synonym for wmd)

		// If `summstat' does not yet exist, check remaining options for iv, mh, peto, logrank, cohen, hedges, glass, (no)standard
		//   If no `summstat' yet, use this info to generate a default value for `summstat'
		//   Otherwise, check for conflicts between these options and existing value of `summstat'
		// (N.B. A full parse of `method' will be done by admetan.ado)
		
		local 0 `", `opts_ipdm'"'
		syntax [, IV MH PETO LOGRank COHen HEDges GLAss noSTANdard NPTS(string) BYAD VARS(string) * ]
		local opts_ipdm `options'

		
		// First, take opportunity to check for options supplied to -ipdmetan-
		//  which should only be supplied to the ad() option
		if `"`byad'"'!=`""' {
			nois disp as err `"option {bf:byad} may only be supplied to {bf:ad()}"'
			exit 198
		}
		foreach opt in vars npts {
			if `"``opt''"'!=`""' {
				nois disp as err `"option {bf:`opt'()} may only be supplied to {bf:ad()}"'
				exit 198
			}
		}

		// Now continue with `summstat' processing
		if `"`summstat'"'!=`""' {
			cap {
				if trim(`"`cohen'`glass'`hedges'"')!=`""' assert `"`summstat'"'==`"smd"'
				if `"`standard'"'!=`""' assert `"`summstat'"'==`"wmd"'
				if `"`peto'"'!=`""'     assert `"`summstat'"'==`"or"'
				if `"`logrank'"'!=`""'  assert inlist(`"`summstat'"', "hr", "shr")
				if `"`mh'"'!=`""'       assert inlist(`"`summstat'"', "or", "rr", "irr", "rrr", "rd") 
			}
			if _rc {
				nois disp as err "Conflicting summary statistic options supplied"
				exit 198
			}					// 18th July 2018: revisit, possibly more detailed error messages?
		}
		else {
			if `"`logrank'"'!=`""' {
				local summstat hr
				local seffect = cond(`"`effect'"'==`""', `"Haz. Ratio"', `"`effect'"')
				local log = cond(`"`log'"'!=`""', "log", cond(`"`eform'"'==`""', "log", ""))	// if no other influences, logrank ==> log 
			}
			else if `"`peto'"'!=`""' {
				local summstat or
				local seffect = cond(`"`effect'"'==`""', `"Odds Ratio"', `"`effect'"')
			}
			else if `"`mh'"'!=`""' {
				local summstat rr
				local seffect = cond(`"`effect'"'==`""', `"Risk Ratio"', `"`effect'"')
			}
			else if trim(`"`cohen'`glass'`hedges'"')!=`""' {
				local summstat smd
				local seffect = cond(`"`effect'"'==`""', `"SMD"', `"`effect'"')
			}
			else if `"`standard'"'!=`""' {
				local summstat wmd
				local seffect = cond(`"`effect'"'==`""', `"WMD"', `"`effect'"')
			}
		}
		
		if "`summstat'"=="" {
			nois disp as err `"Must specify an outcome measure (summary statistic) if no estimation command"'
			exit 198
		}
		
		local logrank = cond(inlist("`summstat'", "hr", "shr"), "logrank", "")
		local opts_ipdm = trim(`"`macval(opts_ipdm)' `iv' `mh' `peto' `logrank' `cohen' `hedges' `glass' `standard'"')
		// now logrank has potentially been altered, put all these options back into `opts_ipdm' for passing to -admetan-
		
		local invlen : word count `invlist'		
		local expect = cond("`logrank'"!="", "one", "two")
		if `invlen' > 2 - ("`logrank'"!="") {
			nois disp as err "Too many variables supplied; was expecting `expect'"
			exit 198
		}
		if `invlen' < 2 - ("`logrank'"!="") {											// this should only trigger if "`logrank'"==""
			nois disp as err "Too few variables supplied; was expecting `expect'"		//  since `invlen'>0 has already been tested for
			if "`peto'"!="" nois disp as err `"(N.B. {bf:peto} option implies Odds Ratios; use {bf:logrank} option for Hazard Ratios)"'
			exit 198
		}
		
		* Preserve, and limit to necessary data only
		// N.B. data will now be preserved in any case (i.e. regardless of `cmdstruc')
		preserve
		qui keep if `touse'
		if `"`logrank'"'!=`""' local stvars _st _d _t0 _t

		keep `touse' `studylist' `StudyID' `invlist' `_BY' `stvars' `strata' `coldnames' `wgtvar'

		
		* Setup `outvlist' ("output" varlist, to become the *input* into -admetan-, or to be returned to -ipdover-)
		// (as opposed to `invlist' which is the varlist *inputted by the user* into -ipdmetan- or -ipdover- !)
		// ... and `cclist' (to pass to -collapse-)
		tokenize `invlist'
		if "`2'"=="" {
			assert "`logrank'"!=""
			args trt
		}
		else args outcome trt

		summ `trt' if `touse', meanonly
		local trtok = `r(min)'==0 & `r(max)'==1
		qui tab `trt' if `touse'
		local trtok = `trtok' * (`r(r)'==2)
		if !`trtok' {
			di as err `"Treatment variable should be coded 0 = control, 1 = research"'
			exit 450
		}

		* Continuous data; word count = 6
		if inlist("`summstat'", "smd", "wmd") {
			if `"`ipdover'"'==`""' tempvar n1 mean1 sd1 n0 mean0 sd0
			else {
				tokenize `outvlist'
				args n1 mean1 sd1 n0 mean0 sd0
			}			
			local outvlist `n1' `mean1' `sd1' `n0' `mean0' `sd0'
			
			tempvar tv1 tv2
			local tvlist `tv1' `tv2'
		}
		
		* Raw count (2x2) data; word count = 4
		else if inlist("`summstat'", "or", "rr", "irr", "rrr", "rd") {
			summ `outcome' if `touse', meanonly
			local outok = `r(min)'==0 & `r(max)'==1
			qui tab `outcome' if `touse'
			local outok = `outok' * (`r(r)'==2)
			if !`outok' {
				nois disp as err `"Outcome variable should be coded 0 = no event, 1 = event"'
				exit 450
			}
		
			if `"`ipdover'"'==`""' tempvar e1 f1 e0 f0
			else {
				tokenize `outvlist'
				args e1 f1 e0 f0
			}
			local outvlist `e1' `f1' `e0' `f0'
			
			tempvar tv1 tv2
			local tvlist `tv1' `tv2'
		}
			
		* logrank HR; word count = 2
		else if "`logrank'"!="" {
			if `"`ipdover'"'==`""' {
				tempvar oe v n1 n0
				if `"`counts'"'!=`""' {
					tempvar e1 e0						// `lrvlist' is an extra tvlist for LogRankHR (and then -collapse-)
				}										// If no `counts', it contains only `n1', `n0' (total pts. by arm);
				local lrvlist `n1' `n0' `e1' `e0'		//  o/w, it also contains `e1' `e0' (no. events by arm)
			}											// (N.B. `e1', `e0' will be referred to as `di1', `di0' within LogRankHR)
			else {
				tokenize `outvlist'
				args oe v

				tokenize `lrvlist'
				if `"`counts'"'!=`""' args n1 n0 e1 e0
				else {
					args n1 n0
					local lrvlist `n1' `n0'
				}
			}
			local outvlist `oe' `v'	
		}
	}			// end else (i.e. if "`cmdstruc'"=="specific")


	// Finalise "ipdmetan" options to send to admetan_setup
	local lrvlist = cond(`"`logrank'"'==`""', `""', `"`lrvlist'"')		// in case `lrvlist' passed from -ipdover-
	local admopts `"estexp(`estexp') explist(`exp_list') `interaction' ipdxline(`extraline') lrvlist(`lrvlist')"'
	// explist(`exp_list') added Dec 2018 for v3.0.1
	

	*** Perform -collapse- on `cclist' supplied to lcols/rcols, plus processing of raw data

	// Notes:
	// For estimation commands, `ipdfile' exists but is not currently in memory.
	// Otherwise (i.e. if "collapse"-type syntax), nothing permanent has been done to the data yet.
	// If Peto logrank, at the study (or `overh') level run LogRankHR *once*,
	//   to obtain processed data (O-E & V at unique times).
	// This process also retains any original varnames (`coldnames') from lcols/rcols needed for -collapse-.

	if `"`cmdstruc'"'==`"specific"' | trim(`"`cclist'`svars'"') != `""' {

		if `"`cmdstruc'"'==`"specific"' | trim(`"`cclist'"') != `""' {		// i.e. all except if `svars' alone
			forvalues h=1/`overlen' {
				local overh : word `h' of `studylist'
				gen byte `touse2' = `touse'
				if `"`smissing'"'==`""' markout `touse2' `overh', strok
				tempfile extra1_`h'

				local show = cond(`h'==1, "`show'", "noshow")
				if `"`cmdstruc'"'==`"specific"' {
					cap nois ProcessRawData `invlist' if `touse', ///
						study(`overh') by(`_BY') outvlist(`outvlist') tvlist(`tvlist') ///
						lrvlist(`lrvlist') coldnames(`coldnames') strata(`strata') `show'

					if _rc {
						if _rc==1 nois disp as err `"User break in {bf:ipdmetan.ProcessRawData}"'
						else nois disp as err `"Error in {bf:ipdmetan.ProcessRawData}"'
						c_local err noerr		// tell ipdover not to also report an "error in {bf:ipdmetan}"
						exit _rc
					}
				}
								
				qui collapse `cclist' `r(cclist)' if `touse2' `cmdwt' `r(cmdwt)', fast by(`_BY' `overh' `StudyID')
				qui gen byte `tempuse' = 1
				qui save `extra1_`h''
				restore, preserve
			}
			
			// Now do lcols/rcols only by subgroup and overall
			if `"`ipdover'"'!=`""' local lrvlist2 : copy local lrvlist		// so that `lrvlist' is *only* used if `ipdover'
			
			if `"`_BY'"'!=`""' & "`subgroup'"==`""' {
				if `"`cmdstruc'"'==`"specific"' {
					cap nois ProcessRawData `invlist' if `touse', ///
						study(`_BY') outvlist(`outvlist') tvlist(`tvlist') ///
						lrvlist(`lrvlist2') coldnames(`coldnames') strata(`strata') noshow

					if _rc {
						if _rc==1 nois disp as err `"User break in {bf:ipdmetan.ProcessRawData}"'
						else nois disp as err `"Error in {bf:ipdmetan.ProcessRawData}"'
						c_local err noerr		// tell ipdover not to also report an "error in {bf:ipdmetan}"
						exit _rc
					}
				}
				if trim(`"`cclist'`r(cclist)'"')!=`""' {
					tempfile extra1_by
					qui collapse `cclist' `r(cclist)' if `touse' `cmdwt' `r(cmdwt)', fast by(`_BY')		// by-level
					qui gen byte `tempuse' = 3
					qui save `extra1_by'
				}
				restore, preserve
			}
				
			if `"`overall'"'==`""' {
				if `"`cmdstruc'"'==`"specific"' {
					tempvar cons
					gen byte `cons' = 1
					cap nois ProcessRawData `invlist' if `touse', ///
						study(`cons') outvlist(`outvlist') tvlist(`tvlist') ///
						lrvlist(`lrvlist2') coldnames(`coldnames') strata(`strata') noshow

					if _rc {
						if _rc==1 nois disp as err `"User break in {bf:ipdmetan.ProcessRawData}"'
						else nois disp as err `"Error in {bf:ipdmetan.ProcessRawData}"'
						c_local err noerr		// tell ipdover not to also report an "error in {bf:ipdmetan}"
						exit _rc
					}
				}
				if trim(`"`cclist'`r(cclist)'"')!=`""' {
					tempfile extra1_tot
					qui collapse `cclist' `r(cclist)' if `touse' `cmdwt' `r(cmdwt)', fast 		// overall
					qui gen byte `tempuse' = 5													// (or "subgroup" level for byad...
					qui save `extra1_tot'														//   ...this will be changed within admetan.ProcessAD)
				}
				restore, preserve
			}
		}		// end if `"`cmdstruc'"'==`"specific"' | trim(`"`cclist'"') != `""' (i.e. all except if `svars' alone)
		
	
		* Perform manual "collapse" of any string vars in "over" files
		//  this could take a bit of to-ing and fro-ing, but it's a niche case
		if `"`svars'"' != `""' {
			assert `ncs' == `: word count `csoldnames''
			forvalues i=1/`ncs' {
				if `"`: word `i' of `csoldnames''"'!=`"`: word `i' of `svars''"' {
					rename `: word `i' of `csoldnames'' `: word `i' of `svars''
				}
			}
			forvalues h=1/`overlen' {
				local overh : word `h' of `studylist'
				gen byte `touse2' = `touse'
				if `"`smissing'"'==`""' markout `touse2' `overh', strok
				qui bysort `touse2' `_BY' `overh': keep if _n==_N & `touse2'
				keep `_BY' `overh' `svars' /*`bystudyopt'*/
				
				if `"`extra1_`h''"' != `""' {				// if file(s) already created above
					qui merge 1:1 `_BY' `overh' using `extra1_`h'', nogen assert(match)
					qui save `extra1_`h'', replace
				}
				else {										// if file(s) not yet created
					qui gen byte `tempuse' = 1
					tempfile extra1_`h'
					qui save `extra1_`h''
				}

				restore, preserve
			}
		}
	
		* Append files to form a single "extra" file
		qui use `extra1_1', clear
		if `overlen'>1 {								// if "over", append files
			qui gen _OVER=1
			forvalues h=2/`overlen' {
				local prevoverh : word `=`h'-1' of `studylist'
				local overh : word `h' of `studylist'
				rename `prevoverh' `overh'				// rename study var to match with next dataset
				qui append using `extra1_`h''
				qui replace _OVER=`h' if missing(_OVER)
			}
		}		
		if `"`extra1_by'"' != `""' {					// if file exists
			qui append using `extra1_by'
		}
		if `"`extra1_tot'"' != `""' {					// if file exists
			qui append using `extra1_tot'
		}

		* Apply variable labels to "collapse" vars
		forvalues i=1/`nc' {
			label var `: word `i' of `namesc'' `"`nclab`i''"'
		}
		if `"`svars'"'!=`""' {			// ...and "string" collapse vars
			forvalues i=1/`ncs' {
				label var `: word `i' of `svars'' `"`ncslab`i''"'
			}
		}
		
		// `overh' now contains the last (numeric) element of `studylist',
		// but the variable itself contains observations from all elements stacked together (see preceding code)
		// Therefore, rename to either "_STUDY" or "_LEVEL" as appropriate
		if `"`overh'"' != `"`_STUDY'"' {
			rename `overh' `_STUDY'		// if "`ipdover'"=="", now named _STUDY
		}
		local _OVER = cond(`overlen'>1, "_OVER", "")
		// N.B. although `_OVER' implies `ipdover', the converse is not true, as `overlen' might be 1.

		if `"`_BY'"'!=`"_BY"' & `"`_BY'"'!=`""' {
			rename `_BY' _BY			// avoid using "capture" in case of genuine error
			local _BY _BY
		}
		
		if `"`cmdstruc'"'==`"generic"' {
			tempvar merge
			qui merge 1:1 `_BY' `_OVER' `_STUDY' using `ipdfile', assert(match using) gen(`merge')
			qui assert inlist(_USE, 1, 2) if `merge'==3 & `tempuse'==1
			qui assert _USE==`tempuse' if `merge'==3 & `tempuse'!=1
			qui assert inlist(_USE, 3, 5) if `merge'==2		// N.B. only applies if no cclist (subgroup/overall not applicable for svars alone)
			qui drop `tempuse' `merge'
		}
		else qui rename `tempuse' _USE
		
	}	// end if `"`cmdstruc'"'==`"specific"' | trim(`"`cclist'`svars'"') != `""'

	else {	// load saved results from estimation command
		assert `"`cmdstruc'"'==`"generic"'
		use `ipdfile', clear
	}
		
	// apply variable labels to lcols/rcols "returned data"
	if `"`namesr'"'!=`""' {
		qui compress `namesr'		// compress first, but then apply formatting if applicable
		forvalues i=1/`nr' {
			local temp : word `i' of `namesr'
			label var `temp' `"`nrlab`i''"'
		}
	}
	if `"`wgttitle'"'!=`""' label var `wgtvar' `"`wgttitle'"'
		
	// apply formats to lcols/rcols
	if `"`fmts'"'!=`""' {
		forvalues i=1/`ni' {
			local temp : word `i' of `lrcols'
			local fmti : word `i' of `fmts'
			if `"`fmti'"'!=`"null"' {
				format `temp' `fmti'
			}
		}
	}
	
	// Apply variable and value labels to _BY
	if `"`_BY'"'!=`""' {
		confirm numeric var _BY
		label var _BY `"`byvarlab'"'

		if `"`bylabfile'"'!=`""' {
			qui do `bylabfile'
			cap label drop _BY
			label copy `bylab' _BY
			label values _BY _BY
		}
	}
	
	
	** Raw data post-"collapse" tidying:
	if `"`cmdstruc'"'==`"specific"' {

		// check sort order
		sort _USE `StudyID'
	
		// non-events for 2x2 raw count data
		// (N.B. `f1' and `f0' have already been declared as part of `outvlist')
		if inlist("`summstat'", "or", "rr", "irr", "rrr", "rd") {
			tokenize `tvlist'
			args n1 n0
			qui gen long `f1' = `n1' - `e1'
			qui gen long `f0' = `n0' - `e0'
		}

		// _NN for logrank
		else if "`logrank'"!="" {
			qui gen long _NN = `n0' + `n1'		// total numbers of patients by study
		}										// N.B. (logrank) HR now implies existence of _NN (if Syntax 2)
	}

	
	
	*******************************
	* Pass to admetan for pooling *  -- or prepare to return data to ipdover
	*******************************

	// Load study/over value labels
	qui do `labfile'
	
	// Sort out effect text
	local effect = cond(`"`effect'"'!=`""', `"`effect'"', ///
		cond(`"`seffect'"'!=`""', `"`seffect'"', "Effect"))
	
	// Branch by admetan or ipdover 
	if `"`ipdover'"'==`""' {
	
		if `"`StudyID'"'!=`"_STUDY"' qui drop `StudyID'
		confirm numeric var _STUDY
		// cap label drop _STUDY
		// label copy `vallab1' _STUDY				// standardise value label name
		// label values _STUDY _STUDY
		label values  _STUDY `vallab1'
		label variable _STUDY `"`svarlab'"'
		// 3rd July 2018: but what if IPD "is AD"? (i.e. is original data)
		//  - this is why a separate subroutine, "admetan_setup", is needed

		cap nois admetan_setup `outvlist', study(`studyopt') by(`byopt') citype(`citype') `interaction' ///
			effect(`effect') df(`_df') wgt(`wgtvar') `eform' `log' ///
			`graph' `overall' `subgroup' `keepall' `keeporder' `het' ///
			forestplot(`opts_fplot') lcols(`lcols') rcols(`rcols') saving(`saving') `ztol' `level' ///
			admopts(`admopts') cmdstruc(`cmdstruc') summstat(`summstat') ad(`ad') nokeepvars `opts_ipdm'
		
		if _rc {
			if `"`err'"'==`""' {
				if _rc==1 nois disp as err `"User break in {bf:ipdmetan.admetan_setup}"'
				else nois disp as err `"Error in {bf:ipdmetan.admetan_setup}"'
			}
			exit _rc
		}

		return add

		// POST ANALYSIS
		// August 2018:
		// merge m:1 is done on `touse' and `study' in case more than one study with same name (but assumed only one within `touse'!)
		
		// Sort out _rsample (already done if "estimation")
		if `"`cmdstruc'"'==`"specific"' & "`rsample'"=="" {
			qui keep if _USE==1
			qui keep _STUDY _USE
			qui rename _STUDY `study'
			qui rename _USE `touse'
			qui save `ipdfile', replace

			restore, preserve

			qui gen long `tempuse' = _n
			qui merge m:1 `touse' `study' using `ipdfile', assert(match master) gen(`touse2')
			sort `tempuse'
			
			cap drop _rsample
			qui gen byte _rsample = `touse' * (`touse2'==3)
			
			qui count
			cap assert r(N) == `origN'
			if _rc {
				disp as err _n `"Error in {bf:ipdmetan}: failed to add {bf:_rsample} to original data"'
				disp as err `"Original data has been restored, but analysis output should be checked carefully (and probably discarded)"'
				exit 198
			}
			else {
				drop `touse' `touse2' `tempuse'
				restore, not
			}
		}
	}
		
		
		
	*** -ipdover- stuff ***
	
	// Else, more processing is required to obtain _ES, _seES, _LCI and _UCI before passing back to ipdover.ado
	// (N.B. these are mostly processes otherwise done by admetan.ado)
	else {

		// Store "over" value labels in new var "_LABELS"
		tempvar labelh
		qui gen _LABELS=""
		forvalues h=1/`overlen' {
			local overh : word `h' of `study'
			if `"`vallab`h''"'!=`""' {				// use value labels loaded from `labfile'
				label values _LEVEL `vallab`h''
				qui decode _LEVEL, gen(`labelh')
				if `overlen'>1 {
					qui replace _LABELS=`labelh' if _OVER==`h'
				}
				else qui replace _LABELS=`labelh'
				drop `labelh'	
			}
			else {
				if `overlen'>1 {
					qui replace _LABELS=string(_LEVEL) if _OVER==`h'
				}
				else qui replace _LABELS=string(_LEVEL)
			}
		}
		label values _LEVEL		// finally, remove labels from _LEVEL

		// Generate _NN for "specific" `cmdstruc' (already done for logrank)
		if `"`cmdstruc'"'==`"specific"' & "`logrank'"=="" {
			qui gen long _NN = `n0' + `n1'
			if inlist("`summstat'", "or", "rr", "irr", "rrr", "rd") qui drop `n1' `n0'		// to minimize transfer of tempvars back to -ipdover- 
		}

		cap drop `OverID'							// remove `OverID' [`StudyID']
		if `"`wgtvar'"'!=`""' rename `wgtvar' _WT	// user-defined weights (Jan 30th 2018)

		if `"`log'"'!=`""'         local effect `"log `effect'"'
		if `"`interaction'"'!=`""' local effect `"Interact. `effect'"'
		
		qui save `ipdfile', replace
		
		// Return "universal" info to ipdover
		return local cmdstruc `cmdstruc'
		return local logrank  `logrank'
		return local eform    `eform'
		return local citype   `citype'

		return local effect `"`effect'"'
		return local opts_fplot `"`opts_fplot'"'
		return local lcols  `"`lcols'"'
		return local rcols  `"`rcols'"'
		// plus: `wt' (already done)

		// Overall number of participants for ipdover.ado
		// (this is otherwise handled by admetan.ado)
		qui gen long `obs' = _n				// tempvar has already been declared
		summ `obs' if _USE==5, meanonly
		if r(N) {
			assert r(N)==1
			return scalar n = _NN[`r(min)']
		}
		
		// return statistics for to "specific" effect measures (Syntax 2)
		if `"`cmdstruc'"'==`"specific"' {
			return local lrvlist  `lrvlist'
			return local invlist  `outvlist'				// N.B. `outvlist' becomes `invlist' for clearer comparison with admetan.ado code
			return local summstat `summstat'
			return local log      `log'
		}
		// N.B. if estimation, `estexp' already returned
		
		// return everything else in `options'
		return local options `"`macval(opts_ipdm)' `overall' `subgroup' `graph' saving(`saving')"'

	}
	
end


	
	
	
******************************************************************



*********************
* Stata subroutines *
*********************


* Initial parsing of "command"-based syntax

* PROBLEM: Main ipdmetan loop needs to add "if `touse' & `StudyID'==`i'" to the command syntax in an appropriate place

* POTENTIAL ISSUES:
// (a) prefix commands, e.g. svy; these can mostly be left alone, but strip off to identify the actual *estimation* command
// (b) multilevel models; to be compatible with ipdmetan these can only have one if/in condition.
//      so use _parse expand to extract if/in conditions, otherwise continue as normal
// (c) _prefix_command does not like the syntax  if varname=="[label]":[lblname]  so will need to remove `if' before using it.

* STRATEGY:
// 1. Use "_parse expand" to isolate fe_equation
// 2. Strip off `if' (and `in', `weights' and `options', for simplicity) and save separately
// 3. Run _prefix_command repeatedly to separate off any prefixes and to isolate estimation command
// 5. Re-assemble command and continue (any remaining syntax errors will be found when the command is first run)

* Use "_parse expand" to isolate fe_equation, and to identify first `if' and `in'

// Assume `if', `in', `wt', `opts' are *global* in terms of ipdmetan
// This in turn implies that multiple `if', `in' or `wt' should not be allowed; therefore test for this here.
// We can't wait until running the command itself, since the options will have been shuffled around by then, possibly obscuring the error.

program define ProcessCommand, sclass

	version 11.0
	local version : di "version " string(_caller()) ":"
	
	// syntax , COMMAND(string asis) [*]
	// local efopt `options'			// contains `efopt' `logopt' (from _get_eformopts applied to *command options*, not -ipdmetan- options)
	
	// _parse expand lcstub lgstub : command, gweight
	_parse expand lcstub lgstub : 0, gweight
	forvalues i=1/`lcstub_n' {
		local 0 `lcstub_`i''
		syntax [anything] [if] [in] [fw aw pw iw] [, *]

		// code fragment taken from _mixed_parseifin (with modifications)
		if `"`if'"' != `""' {
			if `"`cmdif'"' != `""' {
				di as error "multiple {bf:if} conditions not allowed"
				exit 198
			}
			local cmdif `"`if'"'
		}
		if `"`in'"' != `""' {
			if `"`cmdin'"' != `""' {
				di as error "multiple {bf:in} ranges not allowed"
				exit 198
			}
			local cmdin `"`in'"'
		}
		
		local stubopts
		if `"`weight'"' != `""' local stubopts `"[`weight'`exp']"'
		if `"`options'"' != `""' local stubopts `"`stubopts', `macval(options)'"'	// we can put these two together as they will always appear adjacent
		
		if `i'==1 {
			local command `"`anything'"'
			local cmdopts `"`stubopts'"'
		}
		else local cmdrest `"`macval(cmdrest)' || (`anything' `stubopts')"'
	}
	
	// "Global" if/in conditions
	// code fragment taken from _mixed_parseifin (with modifications)
	if `"`lgstub_if'"' != `""' {
		if `"`cmdif'"' != `""' {
			di as error "multiple {bf:if} conditions not allowed"
			exit 198
		}
		local cmdif `"`lgstub_if'"'
	}
	if `"`lgstub_in'"' != `""' {
		if `"`cmdin'"' != `""' {
			di as error "multiple {bf:in} ranges not allowed"
			exit 198
		}
		local cmdin `"`lgstub_in'"'
	}
	local glob_opts `"`lgstub_wt', `macval(lgstub_op)'"'									// we can put these two (weights and options)
	local glob_opts = cond(trim(`"`glob_opts'"')==`","', `""', trim(`"`glob_opts'"'))		//   together as they will always appear adjacent...
	local checkopts `"`cmdopts' `macval(lgstub_op)'"'		// ... but we also need the options separately, for the final check using _prefix_command
	

	* Prefixes should be the only instances of colons outside quotes now
	//  so we can run _prefix_command repeatedly to identify the estimation command
	//  (i.e. the command following the last colon)
	local pcommand
	local before before
	while `"`before'"'!=`""' {
		cap _on_colon_parse `command'
		if !_rc {							// if colon found
			local before `"`s(before)'"' 
			local after  `"`s(after)'"' 
			`version' _prefix_command ipdmetan, `level' : `before'
			local cmdname `"`s(cmdname)'"'						// current prefix command
			local pcommand `"`s(command)' : `pcommand'"'		// all prefix commands
			local command `"`after'"'							// estimation command
		}
		else continue, break
	}
	
	* Final parse of estimation command (and global options) only
	`version' _prefix_command ipdmetan, `level' : `command' `checkopts'	
	local cmdname `"`s(cmdname)'"'
	local cmdargs `"`s(anything)'"'
	local efopt = cond(`"`s(efopt)'"'=="",`"`s(eform)'"',`"`s(efopt)'"')
	local level = cond(`"`s(level)'"'!=`""', `"`s(level)'"', `"`c(level)'"')
	
	* Return relevant parts of command	
	sreturn clear
	sreturn local cmdname `cmdname'
	sreturn local cmdbefore `"`pcommand' `cmdname' `cmdargs'"'
	sreturn local cmdafter  `"`cmdopts' `cmdrest' `glob_opts'"'
	sreturn local cmdifin   `"`cmdif' `cmdin'"'
	sreturn local efopt     `"`efopt'"'
	sreturn local level     `"`level'"'
	
end




****************************************************************

* Sort out study ID (or 'over' vars)
//  if IPD/AD meta-analysis (i.e. not ipdover), create subgroup ID based on order of first occurrence
//  so that -preserve- is not needed, and hence can be done *after* `ni0', `ni1' are generated (by LogRankHR).
// That way, we can restore and preserve, and keep `ni0', `ni1' in memory.

program define ProcessIDs, rclass sortpreserve

	syntax [if] [in], STUDY(string) CMDSTRUC(string) LABFILE(string) OBS(name) TVLIST(namelist) TNLIST(namelist) ///
		[BY(varname) SORTBY(varname) PLNAME(varname) IPDOVER STUDYID(name) ]
	
	marksample touse

	// parse `study' (could be a varlist if ipdover) and extract `missing'
	local 0 `"`study'"'
	syntax varlist [, Missing]
	local study `varlist'
	
	// Generate tempvar `obs', containing a unique observation ID
	// to be generated after sorting on `sortby' *within this subroutine* (with -sortpreserve-)
	// Hence, since `obs' is passed from the main routine, it will be retained AND the original sorting preserved.
	if `"`sortby'"'!=`""' sort `sortby'
	qui gen long `obs' = _n

	* Sort out study ID (or 'over' vars)
	//  if IPD/AD meta-analysis (i.e. not ipdover), create subgroup ID based on order of first occurrence
	//  (overh will be a single var, =study, so keep StudyID and stouse for later)
	local overtype int				// default
	tempvar stouse
	
	local overlen: word count `study'
	forvalues h=1/`overlen' {
		local overh : word `h' of `study'
		
		cap drop `stouse'
		qui gen byte `stouse' = `touse'
		if `"`missing'"'==`""' markout `stouse' `overh', strok
		
		if `"`ipdover'"'==`""' {
			tempvar sobs
			qui bysort `stouse' `overh' (`obs') : gen long `sobs' = `obs'[1]
			qui bysort `stouse' `by' `sobs' : gen long `studyid' = (_n==1)*`stouse'
			qui replace `studyid' = sum(`studyid')
			local ns = `studyid'[_N]					// number of studies, equal to max(`sgroup')
			qui drop `sobs'
		
			// test to see if subgroup variable varies within studies; if it does, exit with error
			if `"`cmdstruc'"'==`"generic"' {

				qui tab `overh' if `stouse', m
				if r(r) != `ns' {					// N.B. `ns' is already stratified by `by'
					nois disp as err "Data is not suitable for meta-analysis"
					nois disp as err " as variable {bf:`by'} (in option {bf:by()}) is not constant within studies."
					nois disp as err "Use alternative command {bf:ipdover} if appropriate."
					exit 198
				}
					
				// also test plname in the same way (if exists)
				if `"`plname'"'!=`""' {
					tempvar tempgp
					qui bysort `stouse' `plname' `overh' : gen long `tempgp' = (_n==1)*`stouse'
					qui replace `tempgp' = sum(`tempgp')
					summ `tempgp', meanonly
					local ntg = r(max)
					drop `tempgp'
					
					qui tab `overh' if `stouse', m
					if r(r) != `ntg' {
						nois disp as err `"variable {bf:`plname'} in option {bf:plotid()} is not constant within studies"'
						exit 198
					}
				}
			}		// end if `"`cmdstruc'"'==`"generic"'
		}		// end if `"`ipdover'"'==`""'
		
		* Store variable label
		local varlab`h' : variable label `overh'
		if `"`varlab`h''"'==`""' local varlab`h' `"`overh'"'
		return local varlab`h' `varlab`h''

		// numeric type
		if `"`overtype'"'=="int" & inlist(`"`: type `overh''"', "long", "float", "double") {
			local overtype : type `overh'		// "upgrade" if more precision needed
		}
		
		* If any string variables, "decode" them
		//   and replace string var with numeric var in list "study"
		// If numeric, make a copy of each (original) value label value-by-value
		//   to avoid unlabelled values being displayed as blanks
		//   (also, for `study' with IPD+AD it needs to be added to)
		//   then store value label
		local vallab`h' : word `h' of `tnlist'
		cap confirm string var `overh'
		if !_rc {
			local overtemp : word `h' of `tvlist'
			qui encode `overh' if `stouse', gen(`overtemp') label(`vallab`h'')
			local study : subinstr local study `"`overh'"' `"`overtemp'"', all word
			local lablist `"`lablist' `vallab`h''"'
		}
		else {
			cap assert `overh'==round(`overh')
			if _rc {
				if `"`ipdover'"'!=`""' local errtext `"variables in {bf:over()}"'
				else local errtext `"variable {bf:`study'} in option {bf:study()}"'
				nois disp as err `"`errtext' must be integer-valued or string"'
				exit 198
			}
			
			qui levelsof `overh' if `stouse', `missing' local(levels)
			if `"`levels'"'!=`""' {
				local countx = 0
				foreach x of local levels {
					if `x' != . {				// cannot label "."
						local labname : label (`overh') `x'
						label define `vallab`h'' `x' `"`labname'"', add
						local ++countx
					}
				}
				if `countx' local lablist `"`lablist' `vallab`h''"'
			}
		}

	}	// end forvalues h=1/`overlen'

	if `"`lablist'"'!=`""' {
		qui label save `lablist' using `labfile'		// save "study"/"over" value labels
	}

	return local overtype `overtype'
	return local study `study'				// if `ipdover', contains a list; o/w a single varname
	
end





************************************************************************

** Routine to parse main options and forestplot options together, and:
*   a. Parse some general options, such as -eform- options and counts()
*   b. Check for conflicts between main options and forestplot() suboptions.

* Notes:
// N.B. This program is used by both -ipdmetan- and -admetan-.
// Certain options may be supplied EITHER to ipdmetan/admetan directly, OR as sub-options to forestplot()
//   with "forestplot options" prioritised over "main options" in the event of a clash.
// These options are:
// - effect/eform options parsed by CheckOpts (e.g. `rr', `rd', `md', `smd', `wmd', `log')
// - nograph, nohet, nooverall, nosubgroup, nowarning, nowt
// - effect, hetstat, lcols, rcols, plotid, ovwt, sgwt, sgweight
// - cumulative, efficacy, influence, interaction
// - counts, group1, group2 (for compatibility with metan.ado)
// - rfdist, rflevel (for compatibility with metan.ado)

program define ParseFPlotOpts, sclass

	** Parse top-level summary info and option lists
	syntax [, CMDNAME(string) MAINPROG(string) OPTIONS(string asis) FORESTplot(string asis)]

		
	** Parse "main options" (i.e. options supplied directly to -ipdmetan- or -admetan-)
	local 0 `", `options'"'
	syntax [, noGRaph noHET noOVerall noSUbgroup noWARNing noWT noSTATs ///
		EFFect(string asis) COUNTS(string asis) ///
		HETStat(passthru) PLOTID(passthru) LCols(passthru) RCols(passthru) SWitch(passthru) ///
		OVWt SGWt SGWEIGHT CUmulative INFluence INTERaction EFFIcacy RFDist RFLevel(passthru) ///
		COUNTS2 GROUP1(passthru) GROUP2(passthru) * ]

	local opts_main `"`macval(options)'"'
	local sgwt = cond("`sgweight'"!="", "sgwt", "`sgwt'")		// sgweight is a synonym (for compatibility with metan.ado)
	local sgweight

	// May 2018
	// Process -counts- options
	if `"`counts'"' != `""' {
		local group1_main : copy local group1
		local group2_main : copy local group2
		local 0 `", `counts'"'
		syntax [, GROUP1(passthru) GROUP2(passthru) ]
		foreach opt in group1 group2 {
			if `"``opt''"'!=`""' & `"``opt'_main'"'!=`""' & `"``opt''"'!=`"``opt'_main'"' {
				nois disp as err `"Note: Conflicting option {bf:`opt'()}; {bf:counts()} suboption will take priority"' 
			}
			if `"``opt''"'==`""' & `"``opt'_main'"'!=`""' local `opt' : copy local `opt'_main
			local `opt'_main
		}
	}
	else local counts : copy local counts2
	if `"`counts'"'!=`""' local counts `"counts(counts `group1' `group2')"'		// counts(counts...) so that contents are never null
	local group1
	local group2

	// Process -eform- options
	cap nois CheckOpts, soptions opts(`opts_main')
	if _rc {
		if _rc==1 disp as err `"User break in {bf:`mainprog'.CheckOpts}"'
		else disp as err `"Error in {bf:`mainprog'.CheckOpts}"'
		c_local err noerr		// tell main program not to also report an error in ParseFPlotOpts
		exit _rc
	}

	local opts_main `"`s(options)'"'
	local eform     `"`s(eform)'"'
	local log       `"`s(log)'"'
	local summstat  `"`s(summstat)'"'
	if `"`effect'"'==`""' local effect `"`s(effect)'"'
	// N.B. `s(effect)' contains automatic effect text from -eform-; `effect' contains user-specified text

	sreturn clear
		

	** Now parse "forestplot options" if applicable
	local optlist1 graph het overall subgroup warning wt stats ovwt sgwt
	local optlist1 `optlist1' cumulative efficacy influence interaction rfdist		// "stand-alone" options
	local optlist2 /*effect*/ plotid hetstat rflevel counts							// options requiring content within brackets
	local optlist3 lcols rcols switch												// options which cannot conflict
	
	if `"`forestplot'"'!=`""' {
	
		// Need to temp rename options which may be supplied as either "main options" or "forestplot options"
		//  (N.B. `effect' should be part of `optlist2', but needs to be treated slightly differently)
		local optlist `optlist1' `optlist2' `optlist3' effect
		foreach opt of local optlist {
			local `opt'_main : copy local `opt'
		}
		
		// (Note 23rd May 2018: noextraline is a forestplot() suboption only,
		//   but is unique in that it is needed *only* by -admetan.BuildResultsSet- and *not* by -forestplot-)
		local 0 `", `forestplot'"'
		syntax [, noGRaph noHET noOVerall noSUbgroup noWARNing noWT noSTATs ///
			EFFect(string asis) COUNTS(string asis) ///
			HETStat(passthru) PLOTID(passthru) LCols(passthru) RCols(passthru) SWitch(passthru) ///
			OVWt SGWt SGWEIGHT CUmulative INFluence INTERaction EFFIcacy RFDist RFLevel(passthru) ///
			COUNTS2 GROUP1(passthru) GROUP2(passthru) noEXTRALine * ]

		local opts_fplot `"`macval(options)'"'
		local sgwt = cond("`sgweight'"!="", "sgwt", "`sgwt'")		// sgweight is a synonym (for compatibility with metan.ado)
		local sgweight
		
		// May 2018
		// counts, group1, group2
		if `"`counts'"' != `""' {
			local group1_main : copy local group1
			local group2_main : copy local group2
			local 0 `", `counts'"'
			syntax [, GROUP1(passthru) GROUP2(passthru) ]
			foreach opt in group1 group2 {
				if `"``opt''"'!=`""' & `"``opt'_main'"'!=`""' & `"``opt''"'!=`"``opt'_main'"' {
					nois disp as err `"Note: Conflicting option {bf:`opt'()}; {bf:counts()} suboption will take priority"' 
				}
				if `"``opt''"'==`""' & `"``opt'_main'"'!=`""' local `opt' : copy local `opt'_main
				local `opt'_main
			}
		}
		else local counts : copy local counts2
		if `"`counts'"'!=`""' local counts `"counts(counts `group1' `group2')"'		// counts(counts...) so that contents are never null
		local group1
		local group2
		
		// Process -eform- for forestplot, and check for clashes/prioritisation
		cap nois CheckOpts `cmdname', soptions opts(`opts_fplot')
		if _rc {
			if _rc==1 disp as err `"User break in {bf:`mainprog'.CheckOpts}"'
			else disp as err `"Error in {bf:`mainprog'.CheckOpts}"'
			c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan.ParseFPlotOpts}"
			exit _rc
		}
		local opts_fplot `"`s(options)'"'
		
		if `"`summstat'"'!=`""' & `"`s(summstat)'"'!=`""' & `"`summstat'"'!=`"`s(summstat)'"' {
			nois disp as err `"Conflicting summary statistics supplied to {bf:`mainprog'} and to {bf:forestplot()}"'
			exit 198
		}
	}
	
	
	** Finalise locals & scalars as appropriate; forestplot options take priority
	local eform = cond(`"`s(eform)'"'!=`""', `"`s(eform)'"', cond(trim(`"`log'`s(log)'"')!=`""', `""', `"`eform'"'))
	local log = cond(`"`s(log)'"'!=`""', `"`s(log)'"', `"`log'"')
	local summstat = cond(`"`s(summstat)'"'!=`""', `"`s(summstat)'"', `"`summstat'"')
	if `"`effect'"'==`""' local effect `"`s(effect)'"'
	// N.B. `s(effect)' contains automatic effect text from -eform-; `effect' contains user-specified text

	
	// `optlist1' and `optlist2':  allowed to conflict, but forestplot will take priority
	foreach opt of local optlist1 {
		if `"``opt''"'==`""' & `"``opt'_main'"'!=`""' local `opt' : copy local `opt'_main
		if `"``opt''"'!=`""' {
			local opts_parsed `"`macval(opts_parsed)' ``opt''"'
		}
	}
	
	// Display warning for options requiring content within brackets (`optlist2')
	foreach opt in `optlist2' effect {
		if `"``opt'_main'"'!=`""' {
			if `"``opt''"'!=`""' {
				if `"``opt''"'!=`"``opt'_main'"' {
					nois disp as err `"Note: Conflicting option {bf:`opt'()}; {bf:forestplot()} suboption will take priority"' 
				}
			}
			else local `opt' : copy local `opt'_main
		}
		
		// Don't add `effect' to opts_parsed; needed separately in main routine
		if `"``opt''"'!=`""' & "`opt'"!="effect" {
			local opts_parsed = `"`macval(opts_parsed)' ``opt''"'
		}
	}

	// `optlist3':  these *cannot* conflict
	foreach opt in `optlist3' {
		if `"``opt'_main'"'!=`""' {
			if `"``opt''"'!=`""' {
				cap assert `"``opt''"'==`"``opt'_main'"'
				if _rc {
					nois disp as err `"Conflicting option {bf:`opt'} supplied to {bf:`mainprog'} and to {bf:forestplot()}"'
					exit 198
				}
				local `opt'
			}
		}
		if `"``opt'_main'``opt''"'!=`""' {
			local opts_parsed `"`macval(opts_parsed)' ``opt'_main'``opt''"'
		}
	}
	
	// Return locals
	sreturn clear
	sreturn local effect `"`effect'"'
	sreturn local eform    `eform'
	sreturn local log      `log'
	sreturn local summstat `summstat'

	sreturn local options     `"`macval(opts_main)'"'
	sreturn local opts_fplot  `"`macval(opts_fplot)'"'
	sreturn local opts_parsed `"`macval(opts_parsed)' `extraline'"'
	
end



* CheckOpts
// Based on the built-in _check_eformopt.ado,
//   but expanded from -eform- to general effect specifications.
// This program is used by both -ipdmetan- and -admetan-
//   and not all aspects are relevant to both.
// Easier to maintain just a single program, though.

// subroutine of ParseFPlotOpts

program define CheckOpts, sclass

	syntax [name(name=cmdname)] [, soptions OPts(string asis) ESTEXP(string) ]		// estexp(string), as could include equation term
	
	if "`cmdname'"!="" {
		_check_eformopt `cmdname', `soptions' eformopts(`opts')
	}
	else _get_eformopts, `soptions' eformopts(`opts') allowed(__all__)
	local summstat = cond(`"`s(opt)'"'==`"eform"', `""', `"`s(opt)'"')

	if "`summstat'"=="rrr" {
		local effect `"Risk Ratio"'		// Stata by default refers to this as a "Relative Risk Ratio" or "RRR"
		local summstat rr				//  ... but in MA context most users will expect "Risk Ratio"
	}
	else if "`summstat'"=="nohr" {		// nohr and noshr are accepted by _get_eformopts
		local effect `"Haz. Ratio"'		//  but are not assigned names; do this manually
		local summstat hr
		local logopt nohr
	}
	else if "`summstat'"=="noshr" {
		local effect `"SHR"'
		local summstat shr
		local logopt noshr
	}
	else local effect `"`s(str)'"'

	if "`estexp'"=="_cons" {			// if constant model, make use of eform_cons_ti if available
		local effect = cond(`"`s(eform_cons_ti)'"'!=`""', `"`s(eform_cons_ti)'"', `"`effect'"')
	}
	
	local 0 `", `s(eform)'"'
	syntax [, EFORM(string asis) * ]
	local eform = cond(`"`eform'"'!=`""', "eform", "")
	
	// Next, parse `s(options)' to extract anything that wouldn't usually be interpreted by _check_eformopt
	//  that is: mean differences (`smd', `wmd' with synonym `md'); `rd' (unless -binreg-);
	//  `coef'/`log' and `nohr'/`noshr' (which all imply `log')
	// (N.B. do this even if a valid option was found by _check_eformopt, since we still need to check for multiple options)
	local 0 `", `s(options)'"'
	syntax [, COEF LOG NOHR NOSHR RD SMD WMD MD * ]

	// identify multiple options; exit with error if found
	opts_exclusive "`coef' `log' `nohr' `noshr'"
	if `"`summstat'"'!=`""' {
		if trim(`"`md'`smd'`wmd'`rr'`rd'`nohr'`noshr'"')!=`""' {
			opts_exclusive "`summstat' `md' `smd' `wmd' `rr' `rd' `nohr' `noshr'"
		}
	}
	
	// if "nonstandard" effect option used
	else {
		if `"`md'`wmd'"'!=`""' {		// MD and WMD are synonyms
			local effect WMD
			local summstat wmd
		}
		else {
			local effect = cond("`smd'"!="", `"SMD"', ///
				cond("`rd'"!="", `"Risk Diff."', `"`effect'"'))
			local summstat = cond(`"`summstat'"'==`""', trim(`"`smd'`rd'"'), `"`summstat'"')
		}
		else if "`nohr'"!="" {
			local effect `"Haz. Ratio"'
			local summstat hr
			local logopt nohr
		}
		else if "`noshr'"!="" {
			local effect `"SHR"'
			local summstat shr
			local logopt noshr
		}		

		// now check against program properties and issue warning
		if "`cmdname'"!="" {
			local props : properties `cmdname'
			if "`cmdname'"=="binreg" local props `props' rd
			if !`:list summstat in props' {
				cap _get_eformopts, eformopts(`summstat')
				if _rc {
					disp as err `"Note: option {bf:`summstat'} does not appear in properties of command {bf:`cmdname'}"'
				}
			}
		}
	}
	
	// log always takes priority over eform
	// ==> cancel eform if appropriate
	local log = cond(`"`coef'`logopt'"'!=`""', "log", "`log'")					// `coef' is a synonym for `log'; `logopt' was defined earlier
	if `"`log'"'!=`""' {
		if inlist("`summstat'", "rd", "smd", "wmd") {
			nois disp as err "Log option only appropriate with ratio statistics"
			exit 198
		}
		local eform
	}
	
	sreturn clear
	sreturn local logopt   `coef'`logopt'			// "original" log option
	sreturn local log      `log'					// either "log" or nothing
	sreturn local eform    `eform'					// either "eform" or nothing
	sreturn local summstat `summstat'				// if `eform', original eform option
	sreturn local effect   `"`effect'"'
	sreturn local options  `"`macval(options)'"'

end






*********************************

* -ParseCols-
* by David Fisher, August 2013

* Parses a list of "items" and outputs local macros for other programs (e.g. ipdmetan or collapse)
* Written for specific use within -ipdmetan-
//   identifying & returning expressions (e.g. "returned values" from regression commands)
//   identifying & returning "collapse-style" items to pass to collapse
//   identifying & returning labels (within quotation marks) and formats (%fmt) for later use

* N.B. Originally written (by David Fisher) as -collapsemat- , November 2012
// This did both the parsing AND the "collapsing", including string vars and saving to matrix or file.
// The current program instead *prepares* the data and syntax so that the official -collapse- command can be used.

* Minor updates Oct 2016, Oct 2018

program define ParseCols, sclass
	version 11.0
	
	syntax anything(name=clist id=clist equalok)
	
	local clist: subinstr local clist "[]" "", all
	local na=0					// counter of vars not in IPD (i.e. in aggregate dataset only)
	local nc=0					// counter of "collapse" vars
	local ncs=0					// counter of "collapse" vars that are strings (cannot be processed by -collapse-)
	local nr=0					// counter of "returned" vars
	local stat null				// GetOpStat needs a "placeholder" stat at the very least. Gets changed later if appropriate
	local fmt null				// placeholder format
	local fmtnotnull=0			// marker of whether *any* formatting has been specified
	local flag=0				// marker of what stage in the process we are
	local rcols=0				// marker of whether we're currently in lcols or rcols
	
	sreturn clear
	
	* Each loop of "while" should process an "item group", defined as
	// [(stat)] [newname=]item [%fmt "label"]
	while `"`clist'"' != "" {
	
		gettoken next rest : clist, parse(`":"')
		if `"`next'"'==`":"' {
			local rcols = 1					// colon indicates partition from lcols to rcols
			local clist `"`rest'"'
			if `"`clist'"'==`""' {
				continue, break
			}
		}
		
		// Get statistic
		if !`flag' {
			GetOpStat stat clist : "`stat'" `"`clist'"'
			local flag=1
		}

		// Get newname and/or format
		// Get next two tokens -- first should be a (new)name, second might be "=" or a format (%...)
		else if inlist(`flag', 1, 2) {
			gettoken next rest : clist, parse(`" ="') bind qed(qed1)
			gettoken tok2 rest2 : rest, parse(`" ="') bind qed(qed2)
			if `qed1' {			// quotes around first element
				nois disp as err `"Error in {bf:lcols()} or {bf:rcols()}; check ordering/structure of elements"'
				exit 198
			}
			
			if `flag'==1 {
				if `"`tok2'"' == `"="' {
					gettoken newname rest : clist, parse(" =")		// extract `newname'
					gettoken equal clist : rest, parse(" =")		// ...and start loop again
					continue
				}
				local flag=2
			}
			
			if `flag'==2 {
				if substr(`"`tok2'"', 1, 1) == `"%"' {		// var followed by format
					confirm format `tok2'
					local fmt `"`tok2'"'
					local fmtnotnull = 1
					local clist : subinstr local clist `"`tok2'"' `""'	// remove (first instance of) tok2 from clist and start loop again
					continue
				}
				local flag=3
			}
		}
		
		// Prepare variable itself (possibly followed with label in quotes)
		else if `flag'==3 {
		
			if `qed2' {					// quotes around second element ==> var followed by "Label"
				gettoken lhs rest : clist, bind
				gettoken rhs clist : rest, bind
			}
			else {						// var not followed by "Label"
				gettoken lhs clist : clist, bind
			}
			
			// Test whether `lhs' is a possible Stata variable name
			// If it is, assume "collapse"; if not, assume "returned statistic"
			cap confirm name `lhs'
			if _rc {
			
				// assume "returned statistic", in which case should be an expression within parentheses
				gettoken tok rest : lhs, parse("()") bind match(par)
				if `"`par'"'==`""' {
					cap confirm name `lhs'
					if _rc==7 {
						nois disp as err `"invalid name or expression {bf:`lhs'} found in {bf:lcols()} or {bf:rcols()}"'
						nois disp as err `"check that expressions are enclosed in parentheses"'
						exit _rc
					}
					else if _rc confirm name `lhs'		// exit with error
				}
				else {
					local ++nr
					local rstatlist `"`rstatlist' `lhs'"'				// add expression "as-is" to overall ordered list
					if `"`rhs'"' != `""' {
						sreturn local rvarlab`nr'=trim(`"`rhs'"')		// return varlab
						local rhs
					}
					if `"`newname'"'==`""' GetNewname newname : `"`lhs'"' `"`newnames'"'
					else if `"`: list newnames & newname'"' != `""' {
						nois disp as err `"naming conflict in {bf:lcols()} or {bf:rcols()}"'
						exit 198
					}
					local sidelist `"`sidelist' `rcols'"'				// add to (overall, ordered) list of "sides" (l/r)
					local newnames `"`newnames' `newname'"'				// add to (overall, ordered) list of newnames
					local itypes `"`itypes' r"'							// add to (overall, ordered) list of "item types"
					local newfmts `"`newfmts' `fmt'"'					// add to (overall, ordered) list of formats
				}
			}
			
			// If "collapse", convert "ipdmetan"-style clist into "collapse"-style clist
			else {
				cap confirm var `lhs'			// this time test if it's an *existing* variable
				if _rc {
				
					// AD variable only; not present in IPD
					local ++na
					if trim(`"`newname'`rhs'"')!=`""' {
						nois disp as err `"variable {bf:`lhs'} not found in IPD dataset"'
						nois disp as err `"cannot specify {it:newname} or {it:variable label}"'
						exit 198
					}
					local sidelist `sidelist' `rcols'		// add to (overall, ordered) list of "sides" (l/r)
					local newnames `newnames' `lhs'			// add to (overall, ordered) list of newnames (but keep original name in this case)
					local itypes   `itypes' a				// add to (overall, ordered) list of "item types"
				}

				else {
					cap confirm string var `lhs'
					
					// String vars
					if !_rc {
						local ++ncs
						if `"`newname'"'==`""' GetNewname newname : `"`lhs'"' `"`newnames'"'
						else if `"`: list newnames & newname'"' != `""' {
							nois disp as err `"naming conflict in {bf:lcols()} or {bf:rcols()}"'
							exit 198
						}
						local sidelist `sidelist' `rcols'			// add to (overall, ordered) list of "sides" (l/r)
						local newnames `newnames' `newname'			// add to (overall, ordered) list of newnames
						local csoldnames `csoldnames' `lhs'			// add to sub-list of original string varnames
						local itypes `itypes' cs					// add to (overall, ordered) list of "item types"
						local newfmts `newfmts' `fmt'				// add to (overall, ordered) list of formats
						if `"`rhs'"' != `""' {
							local varlab = trim(`"`rhs'"')
							local rhs
						}
						else local varlab : var label `lhs'
						sreturn local csvarlab`ncs' = `"`varlab'"'	// return varlab
					}
					
					// Numeric vars: build "clist" expression for -collapse-
					else {
						local ++nc
						if `"`stat'"'==`"null"' {
							local stat mean							// otherwise default to "mean"
						}
						local keep `"`keep' `lhs'"'
						if `"`rhs'"' != `""' {
							local varlab = trim(`"`rhs'"')
							local rhs
						}
						else local varlab : var label `lhs'
						sreturn local cvarlab`nc' = `"`varlab'"'			// return varlab
						local stat=subinstr(`"`stat'"', `" "', `""', .)		// remove spaces from stat (e.g. p 50 --> p50)
						
						if `"`newname'"'==`""' GetNewname newname : `"`lhs'"' `"`newnames'"'
						else if `: list newname in newnames' {
							nois disp as err `"naming conflict in {bf:lcols()} or {bf:rcols()}"'
							exit 198
						}					
						if trim(`"`fmt'"')==`"null"' {
							local fmt : format `lhs'					// use format of original var if none specified
						}
						local sidelist `sidelist' `rcols'				// add to (overall, ordered) list of "sides" (l/r)
						local newnames `newnames' `newname'				// add to (overall, ordered) list of newnames
						local coldnames `coldnames' `lhs'				// add to sub-list of original varnames
						local itypes `itypes' c							// add to (overall, ordered) list of "item types"
						local newfmts `newfmts' `fmt'					// add to (overall, ordered) list of formats

						local cclist `"`cclist' (`stat') `newname'=`lhs'"'		// add to "collapse" clist

					}		// end  if !_rc (i.e. is `lhs' string or numeric)
				}		// end else (i.e. if `lhs' found in data currently in memory)
			}		// end else (i.e. if "collapse")

			local fmt null
			local newname
			local flag = 0
		}		// end else (i.e. "parse variable itself")
		
		else {
			nois disp as err `"Error in {bf:lcols()} or {bf:rcols()}; check ordering/structure of elements"'
			exit 198
		}
	}		// end "while" loop

	
	// Check length of macro lists
	local nnewnames : word count `newnames'
	local nitypes   : word count `itypes'
	local nsidelist : word count `sidelist'
	assert `nnewnames' == `nitypes'						// check newnames & itypes equal
	assert `nnewnames' == `nsidelist'					// check newnames & sidelist equal
	assert `nnewnames' == `na' + `nc' + `ncs' + `nr'	// ... and equal to total number of "items"
	
	if `fmtnotnull' {
		local nfmts : word count `newfmts'
		assert `nfmts' == `nnewnames'		// check fmts also equal, if appropriate
	}
	
	// Return macros & scalars
	sreturn local newnames `newnames'				// overall ordered list of newnames
	sreturn local itypes   `itypes'					// overall ordered list of "item types"
	sreturn local sidelist `sidelist'				// overall ordered list of "sides" (l/r)
	if `fmtnotnull' {
		sreturn local fmts `newfmts'				// overall ordered list of formats (if any specified)
	}
	if `nc' {
		sreturn local coldnames `coldnames'			// list of original varnames used in "collapse"
		sreturn local cclist  `"`cclist'"'			// "collapse" clist
	}
	if `ncs' {
		sreturn local csoldnames `csoldnames'		// list of original varnames for strings
	}
	if `nr' {
		sreturn local rstatlist `"`rstatlist'"'		// list of returned stats "as is"
	}
	
end


* The following subroutine has a similar name and function to GetNewnameEq in the official "collapse.ado"
*  but has been re-written by David Fisher, Aug 2013
program GetNewname
	args mnewname colon oldname namelist
	
	local newname = strtoname(`"`oldname'"')		// matrix colname (valid Stata varname)
	
	// Jan 2019:  If newname begins _[A-Z], add an additional underscore
	// (so as not to clash with simplified `badnames' check)
	local cALPHA `c(ALPHA)'
	local el2 = substr(`"`newname'"', 2, 1)
	if substr(`"`newname'"', 1, 1)==`"_"' & `: list el2 in cALPHA' {
		local newname `"_`newname'"'
	}
				
	// Adjust newname if duplicates
	if `: list newname in namelist' {
		local j=2
		local newnewname `newname'
		while `: list newnewname in namelist' {
			local newnewname `newname'_`j'
			local ++j
		}
		local newname `newnewname'
	}
	
	c_local `mnewname' `newname'
end
				

* The following subroutine has been modified slightly from its equivalent in the official "collapse.ado"
* by David Fisher, Sep 2013
program GetOpStat 
	args mstat mrest colon stat line

	gettoken thing nline : line, parse("() ") match(parens)
	
	* If `thing' is a single word in parentheses, check if it matches a single "stat" word
	if "`parens'"!="" & `:word count `thing'' == 1 {
		local 0 `", `thing'"'
		cap syntax [, mean median sd SEMean SEBinomial SEPoisson ///
			sum rawsum count max min iqr first firstnm last lastnm null]
		
		// fix thing if abbreviated
		if "`semean'" != ""     local thing semean
		if "`sebinomial'" != "" local thing sebinomial
		if "`sepoisson'" != ""  local thing sepoisson

		// if syntax executed without error, simply update locals and exit
		if _rc == 0 {
			c_local `mstat' `thing'
			c_local `mrest' `"`nline'"'
			if ("`median'"!="") c_local `mstat' "p 50"
			exit
		}
		
		// if not, check for percentile stats
		local thing = trim("`thing'")
		if (substr("`thing'",1,1) == "p") {
			local thing = substr("`thing'",2,.)
			cap confirm integer number `thing'
			if _rc==0 { 
				if 1<=`thing' & `thing'<=99 {
					c_local `mstat' "p `thing'"
					c_local `mrest' `"`nline'"'
					exit
				}
			}
		}
	}
		
	* Otherwise, assume `thing' is an expression (this will be tested later by _prefix_explist)
	//  update locals and return to main loop
	c_local `mstat' `"`stat'"'
	c_local `mrest' `"`line'"'
		
end






*********************************************************************

* Identify `estexp' and run estimation command in a loop over trials
// N.B. `sortby' contains `obs', i.e. a unique observation ID

program define CommandLoop, rclass sortpreserve

	version 11.0
	local version : di "version " string(_caller()) ":"
	
	syntax [anything(name=exp_list equalok)] [if] [in] [fw aw pw iw], IPDFILE(string) CMDNAME(string) STUDY(string) STUDYID(name) ///
		[CMDBEFORE(string) CMDAFTER(string) noOVERALL noSUBGROUP noTOTAL noRSample ///
		BY(string) SORTBY(varname numeric) POOLVAR(string) INTERACTION STATSR(string) NAMESR(string) MESSAGES ///
		IPDOVER OVERLEN(integer 1) LEVEL(passthru) ZTOL(real 1e-6) EFORM ADopt ]
	
	// Save any existing estimation results, and clear return & ereturn
	tempname est_hold
	_estimates hold `est_hold', restore nullok
	_prefix_clear, e r

	// initialise macros
	local eclass=0
	local nosortpreserve=0
	local nr : word count `statsr'
	local nrn = 0
	local nrs = 0
		
	
	* Unless specified otherwise (`noTOTAL'), run command on entire dataset
	// (to test validity, and also to find default poolvar and/or store overall returned stats if appropriate)
	marksample touse
	if `"`total'"'==`""' {
		sort `sortby'
		cap `version' `cmdbefore' if `touse' `cmdafter'
		local rc = _rc
		if `rc' {
			_prefix_run_error `rc' ipdmetan `cmdname'
		}
		tempname obs
		qui gen long `obs'=_n
		cap assert `obs'==`sortby'
		local nosortpreserve = (_rc!=0)		// if running `cmdname' changes sort order, "sortpreserve" is not used, therefore must sort manually
		drop `obs'

		// check if modifies e(b)
		// (N.B. doesn't necessarily mean we're going to *use* e(b);
		//  an `exp_list' could have been supplied, e.g. if `pcommand' is an r-class wrapper for an e-class routine
		// cap mat list e(b)
		local eb b
		local props `"`e(properties)'"'
		if `: list eb in props' {
			
			// Note: If `exp_list' supplied by user, then we force set `eclass' to be zero
			//   i.e. e(b) will not need to be referenced,
			//   so we consider the command to be "non-eclass" (even if, strictly speaking, it is!)
			if `"`exp_list'"'==`""' {
				if `"`poolvar'"'!=`""' local exp_list `"(_b[`poolvar']) (_se[`poolvar'])"'		// N.B. e(N) will be added later
				local eclass=1
			}
			// Conversely, from now on `eclass'==1 implies either that
			//  - `exp_list' is explicitly defined (if `poolvar'; i.e. manual identification of `estexp'); or
			//  - e(b) is referenceable; i.e. *automated* identification of `estexp' (via FindEstExp).

		}
		else if `"`poolvar'"'!=`""' {
			nois disp as err `"cannot specify {bf:poolvar()} without an e-class command; please specify {it:exp_list} instead"'
			exit 198
		}

		// check for string-valued returned stats (`statsrs'), and separate them out
		forvalues j=1/`nr' {
			local statsrj : word `j' of `statsr'
			
			// "confirm number" returns r(7) if sysmiss (".") or extended miss (".a" etc.)
			// so first test if "`statsrj'" = ".", ".a", ...
			local val = `statsrj'				// evaluate statistic
			local miss = "`val'"=="."
			foreach el in `c(alpha)' {
				local miss = max(`miss', "`val'"==".`el'")
			}
			cap confirm number `val'
			if _rc & !`miss' {								// if string
				local namesrj : word `j' of `namesr'
				local namesrs `"`namesrs' `namesrj'"'		// list of string-valued varnames for postfile
				local statsrs `"`statsrs' `statsrj'"'		// list of string-valued stat (item) names
			}
		}
		if `"`statsrs'"'!=`""' {							// if there are any string-valued stats,
			local statsrn : list statsr - statsrs			// remove them from original list "statsr" to form new lists "statsrn" and "statsrs"
			local namesrn : list namesr - namesrs
			local nrn     : word count `statsrn'
			local nrs     : word count `statsrs'
		}
		else {												// otherwise, just rename "statsr" to "statsrn".
			local statsrn : copy local statsr
			local namesrn : copy local namesr
			local nrn = `nr'
		}

		// identify estexp
		// 30th Jan 2018: use sclass so as not to disturb any rclass results from running command on entire dataset
		cap nois FindEstExp `exp_list', eclass(`eclass') statsrn(`statsrn') nrn(`nrn') poolvar(`poolvar') `interaction'
		if _rc exit _rc
		local estvar   `"`s(estvar)'"'
		local estvareq `"`s(estvareq)'"'
		local estexp   `"`s(estexp)'"'
		
		// 30th Jan 2018
		// if ipdover, store *values* of beta, sebeta, nbeta and returned numeric status
		// so that, if rclass, the values are not lost before being posted
		local beta     `"`s(beta)'"'
		local beta_val = `beta'

		local sebeta   `"`s(sebeta)'"'
		local sebeta_val = `sebeta'

		local nbeta    `"`s(nbeta)'"'
		local nbeta_val = `nbeta'

		forvalues j=1/`nrn' {
			local us_`j' `"`s(us_`j')'"'
			local us_`j'_val = `us_`j''
		}

	}			// end if `"`total'"'==`""'
		
	else {		// i.e. if noTOTAL
		
		// Define expressions if noTOTAL
		if `"`poolvar'"'!=`""' {
			local exp_list `"(_b[`poolvar']) (_se[`poolvar']) (e(N))"'
			local estexp `poolvar'
		}
		else gettoken estexp : exp_list, match(par)
		
		local nexp : word count `exp_list'
		tokenize `exp_list'
		local beta `1'
		local sebeta `2'
		local nbeta = cond(`nexp'==3, `"`3'"', ".")		// July 2016: cond(`nexp'==3, `3', .)??  i.e. why use quotes?
		
		// cannot use returned stats if noTOTAL since they cannot be pre-checked with _prefix_expand
		if `nr' {
			nois disp as err `"Cannot collect returned statistics with {bf:nototal}"'
			exit 198
		}
	}

	return local estexp `"`estexp'"'	// return this asap in case of later problems
	
	
	** Set up postfile
	tempname postname
	local _STUDY = cond(`"`ipdover'"'!=`""', "_LEVEL", "_STUDY")
	
	// parse `by' and form `bylist'
	local by = cond(trim(`"`by'"')==`","', `""', trim(`"`by'"'))
	if `"`by'"'!=`""' {
		local 0 `"`by'"'
		syntax varlist [, Missing]
		local by `varlist'
		qui levelsof `by' if `touse', `missing' local(bylist)
		local byopt `"`: type `by'' _BY"'
	}
	
	// parse `study' (could be a varlist if ipdover) and extract `missing'
	local 0 `"`study'"'
	syntax varlist [, Missing]
	local study `varlist'
	local smissing `missing'

	local overlen : word count `study'
	local overopt = cond(`overlen'>1, `"int _OVER"', "")
	local namesrsopt = cond(`"`namesrs'"'!=`""', `"str20(`namesrs')"', "")			// use 20 as default string length;
																					// we can't know in advance what to choose, but -postfile- demands a length
																					// (N.B. `namesrn' will default to float, see help newvarlist)
	postfile `postname' long `studyid' `byopt' `overopt' `overtype' `_STUDY' byte _USE double(_ES _seES) long _NN `namesrn' `namesrsopt' using `ipdfile'
	
	// overall (non-pooled): post values or blanks, as appropriate
	if `"`overall'"'==`""' {
	
		// post "(.) (5)" if overall (will eventually be treated as subgroup if byad, and _USE changed to 3)
		local postreps : di _dup(3) `" (.)"'
		if `"`ipdover'"'!=`""' & `"`total'"'==`""' {
			local postexp `"(.) (5) (`beta_val') (`sebeta_val') (`nbeta_val')"'		// only post non-pooled overall stats if ipdover
			return scalar n = `nbeta'
		}
		else local postexp `"(.) (5) `postreps'"'						// total of five expressions
		if `overlen'>1 local postexp `"(.) `postexp'"'					// add a sixth if _OVER required
		if `"`by'"'!=`""' local postexp `"(.) `postexp'"'				// add a sixth/seventh if _BY required

		if `"`total'"'==`""' {
			forvalues j=1/`nrn' {						// returned numeric stats
				local postexp `"`postexp' (`us_`j'_val')"'
			}
			local postexp `"`postexp' `statsrs'"'		// returned strings
		}
		else {
			local postrepsn : di _dup(`nrn') `" (.)"'	// returned numeric stats
			local postrepss : di _dup(`nrs') `" ()"'	// returned strings
			local postexp `"`postexp' `postrepsn' `postrepss'"'
		}

		post `postname' (.) `postexp'

	}	// end if `"`overall'"'==`""'

	
	** Analysis loop
	if "`rsample'"=="" {
		cap drop _rsample
		qui gen byte _rsample=0		// this will show which observations were used
	}
	local userbreak=0				// initialise
	local noconverge=0				// initialise
	
	tempvar stouse
	forvalues h=1/`overlen' {		// if over() not specified this will be 1/1
									// else, make `StudyID' equal to (`h')th over variable
		local overh : word `h' of `study'

		// If ipdover, order studies "naturally", i.e. numerically/alphabetically
		// Otherwise, use existing `StudyID'
		if `"`ipdover'"'==`""' {
			confirm numeric var `studyid'
			summ `studyid' if `touse', meanonly
			local ns = r(max)
		}
		else {
			qui gen byte `stouse' = `touse'
			if `"`smissing'"'==`""' markout `stouse' `overh', strok
			
			cap drop `studyid'
			qui bysort `stouse' `by' `overh' : gen long `studyid' = (_n==1)*`stouse'
			qui replace `studyid' = sum(`studyid')
			local ns = `studyid'[_N]				// total number of studies (might be repeats if `by' is not study-level)
			drop `stouse'
		}
		sort `sortby'	// N.B. recall that `sortby' distinctly identifies observations
		
		* Loop over study IDs (or levels of `h'th "over" var)
		forvalues i=1/`ns' {
			summ `sortby' if `touse' & `studyid'==`i', meanonly
			
			// find value of by() for current study ID (as identified by r(min))
			if `"`by'"'!=`""' {
				local val = `by'[`r(min)']
				local postby `"(`val')"'
			}
			if `overlen' > 1 local postover `"(`h')"'			// add over() var ID
			
			* Create label containing original values or strings,
			//  then add (original) study ID (which might be the same as StudyID; that is, `i')
			local val = `overh'[`r(min)']
			local poststudy `"(`val')"'
			if `"`messages'"'!=`""' {
				local trlabi : label (`overh') `val'
				disp as text  "Fitting model for `overh' = `trlabi' ... " _c
			}
			_prefix_clear, e r		// 29th Jan 2018: Clear all stored results, to ensure that only results from this run of the command will be in memory
			cap `version' `cmdbefore' if `touse' & `studyid'==`i' `cmdafter'
			local rc = c(rc)
			
			if `rc' {	// if unsuccessful, insert blanks
				if `"`messages'"'!=`""' {
					nois disp as err "Error: " _c
					if `rc'==1 {
						nois disp as err "user break"
					}
					else cap noisily error _rc
				}
				local reps = 3 + `nrn'
				local postrepsn : di _dup(`reps') `" (.)"'			// returned numeric stats
				local postrepss : di _dup(`nrs') `" ()"'			// returned strings
				local postcoeffs `"(2) `postrepsn' `postrepss'"'	// N.B. "(2)" is for _USE ==> unsuccessful
			}														//  (to be kept/removed as specified by `keepall' option)
			else {
			
				// if model was fitted successfully but desired coefficient was not estimated
				if `eclass' {
					local colna : colnames e(b)
					local coleq : coleq e(b)
					if e(converged)==0 {
						local noconverge=1
						local nocvtext " (convergence not achieved)"
					}
				}
				
				if `eclass' & (!`: list estvar in colna' | (`"`estvareq'"'!=`""' & !`: list estvareq in coleq')) {
					if `"`messages'"'!=`""' nois disp as err "Coefficent could not be estimated"
					local postcoeffs `"(2) (.) (.) (`nbeta')"'
				}
				else if missing(`beta'/`sebeta') | (abs(`beta')>=`ztol' & abs(`beta'/`sebeta')<`ztol') {	// improved Mar 2017
					if `"`messages'"'!=`""' nois disp as err "Coefficent could not be estimated"
					local postcoeffs `"(2) (.) (.) (`nbeta')"'
				}
				
				// desired coefficient was estimated successfully
				else {
					local postcoeffs `"(1) (`beta') (`sebeta') (`nbeta')"'
					if `"`messages'"'!=`""' disp as res "Done`nocvtext'"
					if !`eclass' & `"`total'"'!=`""' {
						// cap mat list e(b)
						// local eclass = (!_rc)
						local eb b
						local props `"`e(properties)'"'
						local eclass = `: list eb in props'
					}
					if "`rsample'"=="" {
						if `eclass' qui replace _rsample=1 if e(sample)				// if e-class
						else qui replace _rsample=1 if `touse' & `studyid'==`i'		// if non e-class
					}
				}
				
				forvalues j=1/`nrn' {
					local postcoeffs `"`postcoeffs' (`us_`j'')"'
				}
				local postcoeffs `"`postcoeffs' `statsrs'"'

				local nocvtext		// clear macro
			}
			
			post `postname' (`i') `postby' `postover' `poststudy' `postcoeffs'
			local postby
			local postover
			local postcoeffs
			
			if `nosortpreserve' | `"`total'"'!=`""' {
				sort `sortby'		// if `cmdname' doesn't use sortpreserve (or noTOTAL), re-sort before continuing
			}
		}	// end forvalues i=1/`ns'
	}		// end forvalues h=1/`overlen'

	
	** If appropriate, generate blank subgroup observations
	//   and fill in with user-requested statistics (and, if ipdover, non-pooled effect estimates)
	if `"`by'"'!=`""' & `"`subgroup'"'==`""' {
		foreach byi of local bylist {
			local blank=0
			local postexp `"(.) (3) (.) (.) (.)"'	// missing study; _USE=3; beta; se; npts
			
			if (`"`ipdover'"'!=`""' | `nr') {
				if `"`ipdover'"'!=`""' & `"`messages'"'!=`""' {
					local bylabi : label (`by') `byi'
					disp as text  "Fitting model for `by' = `bylabi' ... " _c
				}
				
				_prefix_clear, e r		// 29th Jan 2018: Clear all stored results, to ensure that only results from this run of the command will be in memory
				cap `version' `cmdbefore' if `by'==`byi' & `touse' `cmdafter'
				local rc = c(rc)
				
				if `rc' {	// if unsuccessful, insert blanks
					if `"`ipdover'"'!=`""' & `"`messages'"'!=`""' {
						nois disp as err "Error: " _c
						if `rc'==1 {
							nois disp as err "user break"
						}
						else cap noisily error _rc
					}
					local blank=1
				}				
				
				else {
				
					// only post coefficients if ipdover
					if `"`ipdover'"'!=`""' {
				
						// if model was fitted successfully but desired coefficient was not estimated
						if `eclass' {
							local colna : colnames e(b)
							local coleq : coleq e(b)
							if e(converged)==0 {
								local noconverge=1
								local nocvtext " (convergence not achieved)"
							}
						}
						
						if `eclass' & (!`: list estvar in colna' | (`"`estvareq'"'!=`""' & !`: list estvareq in coleq')) {
							if `"`messages'"'!=`""' nois disp as err "Coefficent could not be estimated"
							local postexp `"(.) (3) (.) (.) (`nbeta')"'
						}
						else if missing(`beta'/`sebeta') | (abs(`beta')>=`ztol' & abs(`beta'/`sebeta')<`ztol') {	// improved Mar 2017
							if `"`messages'"'!=`""' nois disp as err "Coefficent could not be estimated"
							local postexp `"(.) (3) (.) (.) (`nbeta')"'
						}
						else {
							local postexp `"(.) (3) (`beta') (`sebeta') (`nbeta')"'
							if `"`messages'"'!=`""' disp as res "Done`nocvtext'"
							if !`eclass' & `"`total'"'!=`""' {
								// cap mat list e(b)
								// local eclass = (!_rc)
								local eb b
								local props `"`e(properties)'"'
								local eclass = `: list eb in props'
							}
							if "`rsample'"=="" {
								if `eclass' qui replace _rsample=1 if e(sample)				// if e-class
								else qui replace _rsample=1 if `touse' & `by'==`byi'		// if non e-class
							}
						}
					}			// end if `"`ipdover'"'!=`""'
						
					// post user-requested statistics
					if `nr' & `"`ad'"'==`""' {				// Aug 2017: why `ad'==""???
						forvalues j=1/`nrn' {
							local postexp `"`postexp' (`us_`j'')"'
						}
						local postexp `"`postexp' `statsrs'"'
					}

					local nocvtext		// clear macro
				}
			}
			else local blank=1
			
			if `blank' {
				local postrepsn : di _dup(`nrn') `" (.)"'			// returned numeric stats
				local postrepss : di _dup(`nrs') `" ()"'			// returned strings
				local postexp `"`postexp' `postrepsn' `postrepss'"'
			}
			
			if `overlen' > 1 local postexp `"(.) `postexp'"'
			local postexp `"(.) (`byi') `postexp'"'
			
			post `postname' `postexp'

		}		// end foreach byi of local bylist
	}		// end if `"`by'"'!=`""' & `"`subgroup'"'==`""'
	
	postclose `postname'


	// Warning messages
	if `"`total'"'!=`""' {
		nois disp as err _n "Caution: initial model fitting in full sample was suppressed"
	}
	if `"`pcommand'"'!=`""' {
		nois disp as err _n `"Caution: prefix command supplied to {bf:ipdmetan}. Please check estimates carefully"'
	}
	if `noconverge' {
		nois disp as err _n "Caution: model did not converge for one or more studies. Pooled estimate may not be accurate"
	}
	if `userbreak' {
		nois disp as err _n "Caution: model fitting for one or more studies was stopped by user. Pooled estimate may not be accurate"
	}
	
end
	

	

*****************************************************************************

* ProcessRawData

* Setup `outvlist' ("output" varlist, to become the *input* into -admetan-, or to be returned to -ipdover-)
// (as opposed to `invlist' which is the varlist *inputted by the user* into -ipdmetan- or -ipdover- !)
// ... and `cclist' (to pass to -collapse-)

* Then pass to LogRankHR if appropriate.

// N.B. This subroutine needs to be called at the study level, and then again at the by or overall level if necessary
//   since the tempvars created will be erased upon -restore, preserve-

program define ProcessRawData, rclass

	syntax varlist(min=1 max=2 default=none numeric fv) [if] [in], ///
		STUDY(varname numeric) OUTVLIST(namelist) [ BY(varname numeric) ///
		TVLIST(namelist) LRVLIST(namelist) COLDNAMES(varlist numeric) STRATA(varlist) noSHow ]

	tokenize `varlist'
	if "`2'"=="" args trt
	else {
		assert `"`lrvlist'"'==`""'
		args outcome trt
	}
	
	marksample touse	
	tokenize `outvlist'
	local params : word count `outvlist'
	
	* Continuous data; word count = 6
	if `params' == 6 {
		args n1 mean1 sd1 n0 mean0 sd0

		tokenize `tvlist'
		args outcome1 outcome0
		qui gen `outcome1' = `outcome' if `trt'==1 & `touse'
		qui gen `outcome0' = `outcome' if `trt'==0 & `touse'
		local cclist `"(count) `n1'=`outcome1' `n0'=`outcome0' (mean) `mean1'=`outcome1' `mean0'=`outcome0' (sd) `sd1'=`outcome1' `sd0'=`outcome0'"'
	}
		
	* Raw count (2x2) data; word count = 4
	else if `params' == 4 {
		args e1 f1 e0 f0
		
		tokenize `tvlist'
		args outcome1 outcome0
		qui gen byte `outcome1' = `outcome' if `trt'==1 & `touse'
		qui gen byte `outcome0' = `outcome' if `trt'==0 & `touse'
		local cclist `"(count) `outcome1' `outcome0' (sum) `e1'=`outcome1' `e0'=`outcome0'"'
	}
		
	* logrank HR; word count = 2 (but only if `lrvlist' is supplied)
	else if "`lrvlist'"!="" {
		args oe v

		tokenize `lrvlist'
		args n1 n0 e1 e0
		
		// LogRankHR
		// If no `ipdover' (i.e. no `lrvlist'), we *only* need to collapse `cclist' at the *study* level;
		//   we can then restore the *original* data for any subsequent lcols/rcols work.
		// However, if `ipdover' we need to collapse `cclist' at the subgroup and overall levels too.
		cap nois LogRankHR `trt' if `touse', study(`study') by(`by') strata(`strata') `show' ///
			outvlist(`outvlist') lrvlist(`lrvlist') coldnames(`coldnames')
			
		if _rc {
			if _rc==1 nois disp as err `"User break in {bf:ipdmetan.LogRankHR}"'
			else nois disp as err `"Error in {bf:ipdmetan.LogRankHR}"'
			c_local err noerr		// tell ipdover not to also report an "error in {bf:ipdmetan}"
			exit _rc
		}
			
		local cclist `"`r(cclist)'"'
		return local cmdwt `"`r(cmdwt)'"'
	}

	return local cclist `"`cclist'"'

end

	


*******************************************

* Program to carry out Peto/logrank collapsing to one-obs-per-study
* (based on peto_st.ado)

program define LogRankHR, rclass
	
	st_is 2 analysis
	local wt : char _dta[st_wt]
	if "`wt'"=="pweight" {
		nois disp as err `"Cannot specify pweights"'
		exit 198
	}
	
	syntax varname [if] [in], STUDY(varname) OUTVLIST(namelist) LRVLIST(namelist) ///
		[BY(varname) STrata(varlist) noSHow COLDNAMES(varlist numeric) ]
	
	tokenize `outvlist'
	args oe v						// use alternative names for a, b, c, d here
									// for ease of calculation (and partly for comparison with "sts test" code)
	tokenize `lrvlist'
	args ni1 ni0 di1 di0			// these are really: n1 n0 e1 e0 (total in trt; total in ctrl; events in trt; events in ctrl)
									// but use different names here to avoid confusion with e = expected
	local nocounts = (`: word count `lrvlist''==2)
	if `nocounts' tempvar di1 di0
	
	local arm `varlist'		// treatment arm
		
	st_show `show'
	tempvar touse
	st_smpl `touse' `"`if'"' "`in'"
	
	local w : char _dta[st_w]
	return local cmdwt `"`w'"'
	
	if `"`_dta[st_id]'"' != "" {
		local id `"id(`_dta[st_id]')"'
	}
	local t0 "_t0"
	local t1 "_t"
	local dead "_d"

	tempvar touse
	mark `touse' `if' `in' `w'
	markout `touse' `t1' `dead'
	markout `touse' `arm' `strata', strok
	
	if `"`t0'"'!=`""' & `"`id'"'!=`""' {
		local id
	}
	if `"`t0'"'==`""' & `"`id'"'==`""' {
		tempvar t0
		qui gen byte `t0' = 0
	}
	else if `"`t0'"' != `""' { 
		markout `touse' `t0'
	}
	else if `"`id'"'!=`""' {
		markout `touse' `id'
		quietly {
			sort `touse' `id' `t1'
			local ty : type `t1'
			by `touse' `id': gen `ty' `t0' = cond(_n==1, 0, `t1'[_n-1])
		}
		capture assert `t1'>`t0'
		if _rc {
			di as err `"repeated records at same `t1' within `id'"'
			exit 498
		}
		drop `id'
	}

	capture assert `t1'>0 if `touse'
	if _rc { 
		di as err `"survival time `t1' <= 0"'
		exit 498
	}
	capture assert `t0'>=0 if `touse'
	if _rc { 
		di as err `"entry time `t0' < 0"'
		exit 498
	}
	capture assert `t1'>`t0' if `touse'
	if _rc {
		di as err `"entry time `t0' >= survival time `t1'"'
		exit 498
	}
	capture assert `dead'==0 if `touse'
	if _rc==0 {
		di as err `"analysis not possible because there are no failures"'
		exit 2000
	}
	if `"`strata'"' != "" {
		tempvar isdead
		sort `strata'
		qui by `strata': gen long `isdead' = sum(`dead')
		qui by `strata': replace `isdead' = . if _n<_N
		qui count if `isdead' == 0 & `touse'
		local n_omit = r(N)
		if `n_omit' > 0 {
			if `n_omit' == 1 {
				local endng um
			}
			else {
				local endng a
			}
			local note `"Note: `n_omit' strat`endng' omitted because of no failures"'
		}
	}
	
	qui count if `touse'
	if !r(N) {
		nois disp as err "no observations"
		exit 2000
	}
		
	// store "treatment arm" variable label
	local gvarlab : variable label `arm'
	if `"`gvarlab'"'==`""' local gvarlab `"`arm'"'
	
	// weights
	if `"`weight'"' != `""' { 
		tempvar w 
		qui gen double `w' `exp' if `touse'
		local wv `"`w'"'
		local wntype "double"	// "gen double `n`i''" if weights
	}
	else {
		local w 1
		local wntype "long"		// "gen long `n`i''" if no weights (since in that case must be whole numbers)
	}
	tempvar op r d

	// Denominators
	//  (need to calculate these before limiting to unique times only)
	//  Only need to know denominators per study, per subgroup, and overall
	//  Strata are irrelevant as main calculations don't use denoms, & strata-specific stats are not presented
	forvalues i=0/1 {
		sort `by' `study' `arm' `t1'
		qui by `by' `study' : gen long `ni`i'' = sum(cond(`arm'==`i', 1, 0))
		sort `by' `study' `ni`i''
		qui by `by' `study' : replace `ni`i'' = `ni`i''[_N]
	}

	
	*** Begin manipulating data
	
	quietly {
	
		* Now re-define "bystr" for main calculations
		// This time "by" is irrelevant since it must be trial-level
		// but "strata" ARE relevant
		tempvar obs
		qui gen long `obs'=_n
		
		tempvar expand
		expand 2 if `touse', gen(`expand')
		gen byte `op' = cond(!`expand', 3, cond(`dead'==0,2/*cens*/,1/*death*/)) if `touse'
		replace `t1' = `t0' if `touse' & !`expand'

		sort `touse' `study' `strata' `t1' `op' `arm'
		by `touse' `study' `strata' :      gen `wntype' `r' = sum(cond(`op'==3, `w', -`w')) if `touse'
		by `touse' `study' `strata' `t1' : gen `wntype' `d' = sum(`w'*(`op'==1))            if `touse'

		* Numbers at risk, and observed number of events (failures)
		forvalues i=0/1 {
			tempvar ri`i'
			by `touse' `study' `strata' :      gen `wntype' `ri`i'' = sum(cond(`arm'==`i', cond(`op'==3,`w',-`w'), 0)) if `touse'
			by `touse' `study' `strata' `t1' : gen `wntype' `di`i'' = sum(cond(`arm'==`i', `w'*(`op'==1), 0))          if `touse'
			* N.B. `w' is not needed any more
		}

		// Again, if no `coldnames' we can simplify the dataset considerably
		tempvar touse2
		if `"`coldnames'"'==`""' {
			by `touse' `study' `strata' `t1': keep if _n==_N		// keep unique times only
			gen byte `touse2' = `touse'
		}	
		
		// Else: `touse'*`expand' preserves a copy of the original dataset in terms of auxiliary vars (lcols, rcols) to collapse
		// But we now need to work with unique times only, so define `touse2' for this -- a subset of `touse'*`expand'
		else {
			by `touse' `study' `strata' `t1' : gen byte `touse2' = `touse' * (_n==_N)
			// N.B. *sort* is not unique, but _n==_N keeps max(`r') within sort group
		}

		sort `touse2' `study' `strata' `t1' `op' `arm'	

		* Shift `r' up one place so it lines up
		tempvar newr
		by `touse2' `study' `strata' : gen `wntype' `newr' = `r'[_n-1] if `touse2'
		drop `r' 
		rename `newr' `r'
		
		* Shift each of the `ri's up one place so they line up
		forvalues i=0/1 {
			by `touse2' `study' `strata' : gen `wntype' `newr' = `ri`i''[_n-1] if _n>1 & `touse2'
			drop `ri`i''
			rename `newr' `ri`i''	
		}

		local todrop `"`t0' `t1' `arm' `dead' `strata'"'
		if `"`weight'"'!=`""' local todrop `"`todrop' `w'"'
		local todrop : list strata - coldnames
		if `"`todrop'"'!=`""' drop `todrop'				// don't need strata vars anymore (and there may be many of them)

		* Calculate:
		// E (expected number of events/failures)
		tempvar ei0 ei1
		gen double `ei0' = `ri0'*`d'/`r' if `touse2'
		gen double `ei1' = `ri1'*`d'/`r' if `touse2'

		tempvar zerocheck
		gen `zerocheck' = (`di1' - float(`ei1') == 0) | (float(`ei0') - `di0' == 0) if `touse2'
		assert float(`di1' - `ei1') == float(`ei0' - `di0') if !`zerocheck' & `touse2'				// arithmetic check
		assert float(1 + `di1' - `ei1') == float(1 + `ei0' - `di0') if `zerocheck' & `touse2'		// arithmetic check
		drop `zerocheck'
		
		// V (hypergeometric variance)
		assert float(`ri0' + `ri1') == float(`r') if `touse2'										// arithmetic check
		gen double `v' = `ri0'*`ri1'*`d'*(`r'-`d')/(`r'*`r'*(`r'-1)) if `touse2'
		drop `ri0' `ri1' `r' `d'

		// O - E
		gen double `oe' = `di1' - `ei1' if `touse2'													// use treatment arm
		
		* At this point we have one obs per unique failure time per arm per trial (`touse2').
		
		
		// Prepare and return `cclist'
		local sumvars `"`oe' `v'"'
		if !`nocounts' local sumvars `"`sumvars' `di0' `di1'"'

		if `"`coldnames'"'!=`""' {
			sort `obs' `expand'
			foreach x of local sumvars {
				by `obs' : replace `x' = sum(`x')
			}
			keep if `expand'		// N.B. this implies `touse'
		}

		local cclist `"(firstnm) `ni0' `ni1' (sum) `sumvars'"'
		return local cclist `"`cclist'"'
		
	}	// end quietly
	
end




*********************************

* Parse output of initial model fitted to entire dataset to identify "estexp" and associated info
program define FindEstExp, sclass

	syntax [anything(name=exp_list equalok)], [ECLASS(integer 0) STATSRN(string) NRN(integer 0) POOLVAR(string) INTERACTION]

	// Parse <exp_list>
	local nexp=0
	local neexp=0
	_prefix_explist `exp_list', stub(_df_) edefault
	if `"`exp_list'"'!=`""' {
		cap assert `s(k_eexp)'==0 & inlist(`s(k_exp)', 2, 3)	// if exp_list supplied, must be 2 or 3 exps, no eexps
		local nexp = `s(k_exp)'
	}
	else {
		cap assert `s(k_eexp)'==1 & `s(k_exp)'==0				// otherwise, must be a single eexp (_b) and no exps
		local neexp = `s(k_eexp)'
	}
	local rc = _rc
	
	local eqlist	`"`s(eqlist)'"'
	local idlist	`"`s(idlist)'"'
	local explist	`"`s(explist)'"'
	local eexplist	`"`s(eexplist)'"'

	// Expand <exp_list>
	tempname b
	cap _prefix_expand `b' `explist' `statsrn', stub(_df_) eexp(`eexplist') colna(`idlist') coleq(`eqlist') eqstub(_df)
	local rc  = cond(`rc', `rc', _rc)
	
	if `rc' {
		nois disp as err `"{it:explist} error. Possible reasons include:"'
		if `"`poolvar'"'!=`""' nois disp as err "- coefficient in {bf:poolvar()} not found in the model"
		if `"`statsrn'"'!=`""' nois disp as err "- an expression in {bf:lcols()} or {bf:rcols()} that evaluates to a string"
		nois disp as err "- an expression not enclosed in parentheses"
		exit `rc'
	}
	local nexp = cond(`neexp', `s(k_eexp)', `nexp')		// if eexps, update `neexp' and rename it to `nexp'

	// Form list of "returned statistic" expressions to post
	forvalues j=1/`nrn' {
		local i = `nexp' + `j'
		sreturn local us_`j' `"`s(exp`i')'"'
	}

	// Identify estexp
	if !`eclass' {							// not using e(b); i.e. either truly non-eclass *or* `exp_list' was supplied by user
		local beta `"`s(exp1)'"'
		local sebeta `"`s(exp2)'"'
		local nbeta = cond(`nexp'==3, `"`s(exp3)'"', ".")		// July 2016: cond(`nexp'==3, `3', .) ??  i.e. why use quotes?
		local estexp `"`s(exp1)'"'			// Oct 2018
		// if `exp_list' supplied by user, use first element of `exp_list' to display later
	}
	
	else {
		// If e-class, parse e(b) using _ms_parse_parts
		// Choose the first suitable coeff, then check for conflicts with other coeffs (e.g. interactions)
		// [Note: Can we also check for badly-fitted coeffs here?  i.e. v high/low b or se?]
		local ecolna `"`s(ecolna)'"'	// from _prefix_expand
		local ecoleq `"`s(ecoleq)'"'	// from _prefix_expand
		local colna : colnames e(b)		// from e(b)
		local coleq : coleq e(b)		// from e(b)

		// If not poolvar (i.e. basic syntax), results from _prefix_expand should match those from e(b)
		assert (`"`ecolna'"'!=`""') == (`"`poolvar'"'==`""')
		assert (`"`ecoleq'"'!=`""') == (`"`poolvar'"'==`""')

		if `"`poolvar'"'!=`""' {		// parse `poolvar' -- assume "estvareq:estvar" format
			local estexp `poolvar'
			cap _on_colon_parse `estexp'
			if _rc local estvar `"`estexp'"'	// no colon found
			else {
				local estvareq `"`s(before)'"'
				local estvar `"`s(after)'"'
			}
		}

		else {				// MAY 2014: only check for conflicts if poolvar *not* supplied
			assert `"`ecolna'"'==`"`colna'"'
			if substr(`"`coleq'"', 1, 1)!=`"_"' {
				assert `"`ecoleq'"'==`"`coleq'"'
			}
			local name1
			local name2

			forvalues i=1/`nexp' {
				local colnai : word `i' of `colna'
				local coleqi : word `i' of `coleq'

				_ms_parse_parts `colnai'
				if !r(omit) {

					// If estvar already exists, check for conflicts with subsequent coeffs
					// (cannot currently check for difference between, e.g. "arm" and "1.arm"
					//  - i.e. how to tell when a var is factor if not made explicit... is this a problem?)
					if `"`estvar'"'!=`""' {
						if `"`coleqi'"'==`"`estvareq'"' {			// can only be a conflict if same eq
							if `"`r(type)'"'=="interaction" {
								local rname1 = cond(`"`r(op1)'"'==`""', `"`r(name1)'"', `"`r(op1)'.`r(name1)'"')
								local rname2 = cond(`"`r(op2)'"'==`""', `"`r(name2)'"', `"`r(op2)'.`r(name2)'"')

								if (`"`interaction'"'!=`""' & ///
										( inlist(`"`name1'"',`"`rname1'"',`"`rname2'"') ///
										| inlist(`"`name2'"',`"`rname1'"',`"`rname2'"') )) ///
									| (`"`interaction'"'==`""' & inlist(`"`estvar'"',`"`rname1'"',`"`rname2'"')) {
									nois disp as err `"Automated identification of {it:estvar} failed; conflict detected in expanded factor-variable notation"'
									nois disp as err `"Please use either {bf:poolvar()} or {it:exp_list}"'
									exit 198
								}
							}
							else if inlist(`"`r(type)'"', "variable", "factor") {
								local rname = cond(`"`r(op)'"'==`""', `"`r(name)'"', `"`r(op)'.`r(name)'"')

								if (`"`interaction'"'!=`""' & inlist(`"`rname'"',`"`name1'"',`"`name2'"')) ///
									| (`"`interaction'"'==`""' & `"`rname'"'==`"`estvar'"') {
									nois disp as err `"Automated identification of {it:estvar} failed; conflict detected in expanded factor-variable notation"'
									nois disp as err `"Please use either {bf:poolvar()} or {it:exp_list}"'
									exit 198
								}
							}
						}
					}		// end if `"`estvar'"'!=`""'

					// Else define estvar
					else if `"`interaction'"'!=`""' {
						if `"`r(type)'"'=="interaction" {
							local estvar `colnai'
							local estvareq `coleqi'
							local name1 `"`r(name1)'"'
							local name2 `"`r(name2)'"'
						}
					}
					else {
						local estvar `colnai'
						local estvareq `coleqi'							
					}		// end else
				}		// end if !r(omit)
			}		// end forvalues i=1/`nexp'

			if `"`estvar'"'==`""' {
				nois disp as err `"Automated identification of {it:estvar} failed; no suitable variable could be found"'
				nois disp as err `"Please use either {bf:poolvar()} or {it:exp_list}"'
				exit 198
			}
			
			if inlist(`"`estvareq'"', "_", "") local estexp `"`estvar'"'
			else local estexp `"`estvareq':`estvar'"'

		}		// end else; i.e. if `"`poolvar'"'==`""'

		local beta `"_b[`estexp']"'
		local sebeta `"_se[`estexp']"'
		local nbeta `"e(N)"'

	}		// end else (i.e. if eclass)
	
	// Return macros
	sreturn local estvar   `"`estvar'"'
	sreturn local estvareq `"`estvareq'"'
	sreturn local estexp   `"`estexp'"'
	sreturn local beta     `"`beta'"'
	sreturn local sebeta   `"`sebeta'"'
	sreturn local nbeta    `"`nbeta'"'

end





***********************************

* Prepare data for sending to admetan
// including processing of ad() option

program define admetan_setup, rclass

	syntax varlist(min=2 max=6 numeric) [if] [in], STUDY(string) [BY(string) ///
		/// /* options for IPD +/- AD only */
		ADMOPTS(string asis) CMDSTRUC(string) IPDFILE(string) AD(passthru) PLOTID(string) ///
		/// /* options potentially modified by AD */
		EFORM LOG LOGRank EFFECT(string) METHOD(string) SUMMSTAT(string) NPTS(varname) NPTS2 noINTeger noKEEPVars noRSample * ]

	local opts_ipdm `"`macval(options)'"'
	local invlist `varlist'					// now we are dealing with admetan-related stuff, so use `invlist' (i.e. "into admetan") ...
											// ...	instead of `outvlist' ("out of/derived from IPD")
	
	marksample touse, novarlist		// `novarlist' option so that entirely missing/nonexistent studies/subgroups may be included
	
	if "`keepvars'"!="" & "`rsample'"!="" {
		disp as err `"only one of {bf:nokeepvars} or {bf:norsample} is allowed"'
		exit 198
	}	

	// Define tempvars and temp value label names for `study' and `by'
	//   for use in various ways e.g. if one is string, or if `by' only exists in AD
	tempvar newstudy newby
	tempname newstudylab newbylab	
	
	// If the data was IPD and has been processed by either CommandLoop or ProcessRawData
	// then vars will be named _USE, _STUDY with optional _BY, _NN (all numeric)
	// (Original `study' and `by' are stored in macros of those names, for passing to ProcessAD)
	if "`cmdstruc'"!="" {
		local _USE _USE
		local _STUDY _STUDY

		cap confirm numeric var _BY
		local _BY = cond(!_rc, "_BY", "")

		cap confirm numeric var _NN
		local _NN = cond(!_rc, "_NN", "")
		
		local plot = cond(`"`npts2'"'==`""', `"noplot"', `""')
	}
	
	// Otherwise, some or all of the original data in memory remains
	//   with user-defined (var)names (but e.g. _BY may not exist yet; only in AD)
	else {
		qui count
		local origN = r(N)
		local preserve preserve		// Oct 2018: to pass on to -admetan- ... want -admetan- to treat as if NOT preserved
		preserve					// ...so that "stored variables" are handled correctly

		local studyopt `study'		// full option (including `missing' if supplied), for ProcessAD
		local 0 `study'
		syntax name(name=study) [, Missing]
		
		local byopt `by'			// full option (including `missing' if supplied), for ProcessAD
		local 0 `by'
		syntax [name(name=by)] [, Missing]
		
		// define macros to match with if "`cmdstruc'"!="
		local _USE `touse'
		local _STUDY `study'
		local _BY `by'
		if `"`npts'"'!=`""' {
			local 0 `"`npts'"'
			syntax varname(numeric) [, noPlot noINTeger]
			local _NN `varlist'
		}		

		if `"`ad'"'!=`""' {		// within "`cmdstruc'"==""
		
			// If `study' or `by' *already* numeric, save orignal versions of their value labels
			// (N.B. this would be done anyway if "`cmdstruc'"!="", further into -ipdmetan- )
			if `"`: value label `study''"'!=`""' {
				local studylab : value label `study'
				tempfile labfile
				qui label save `studylab' using `labfile'
			}
			local svarlab : variable label `study'
			if `"`by'"'!=`""' {
				if `"`: value label `by''"'!=`""' {
					local bylab : value label `by'
					tempfile bylabfile
					qui label save `bylab' using `bylabfile'
				}
				local byvarlab : variable label `by'
			}
		
			// Convert `study' and `by' to numeric if necessary; this will make things easier for ProcessAD
			cap nois ProcessLabels if `touse', ///
				study(`study') newstudy(`newstudy') newstudylab(`newstudylab') ///
				   by(`by')       newby(`newby')       newbylab(`newbylab')
			if _rc {
				if _rc==1 nois disp as err `"User break in {bf:admetan.ProcessLabels} when applied to IPD"'
				else if _rc!=2000 nois disp as err `"Error in {bf:admetan.ProcessLabels} when applied to IPD"'
				exit _rc
			}
			
			if `"`r(newstudy)'"'!=`""' {
				local _STUDY `r(newstudy)'
				label values `_STUDY' `r(newstudylab)'
				label variable `_STUDY' `"`svarlab'"'
			}
			if `"`r(newby)'"'!=`""' {
				local _BY `r(newby)'
				label values `_BY' `r(newbylab)'
				label variable `_BY' `"`byvarlab'"'
			}
			// _STUDY is now guaranteed to (a) exist; (b) be numeric with a value label.
			
		}
	}		// end if "`cmdstruc'"==""
		
	if `"`ad'"'!=`""' {	

		// Jan 2019 for v3.2:  Keep track of "stored" varnames found in AD only, not in IPD
		foreach v in _ES _seES _LCI _UCI _WT _NN _CC {
			cap confirm var `v'
			if !_rc local ipdstored `ipdstored' `v'
		}
	
		// Declare tempvars `newstudy' and `newby' for use if string
		//   and `_SOURCE' (with label `sourcelab') to store source of data (IPD or AD).
		tempvar newstudy newby _SOURCE
		tempname sourcelab
		cap nois ProcessAD `invlist' if `touse', `ad' ipdfile(`ipdfile') ///
			uselist(`_USE' `_STUDY' `_BY') study(`study') by(`by') npts(`_NN') `integer' ///
			tvlist(`newstudy' `newby' `newbylab' `_SOURCE' `sourcelab') ///
			`eform' `log' `logrank' summstat(`summstat') `opts_ipdm'
		
		if _rc {
			if _rc==2000 {
				disp as err `"Note: No valid observations in aggregate dataset; {bf:ad()} will be ignored"'
				cap drop `_SOURCE'
				local _SOURCE
			}
			else {
				if `"`err'"'==`""' {
					if _rc==1 nois disp as err `"User break in {bf:ipdmetan.ProcessAD}"'
					else nois disp as err `"Error in {bf:ipdmetan.ProcessAD}"'
				}
				c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan_setup}"
				exit _rc
			}
		}
	}		// end if `"`ad'"'!=`""'

	
	// start again in case AD not found (error 2000; see above)
	if `"`_SOURCE'"'!=`""' {
	
		// these options are only overwritten in certain circumstances,
		// e.g. if the IPD was "generic"; see code of ProcessAD
		if `"`r(effect)'"'!=`""' local effect `"`r(effect)'"'
		if `"`method'"'==`""' local method `r(method)'
		if `"`summstat'"'==`""' local summstat `r(summstat)'
	
		local eform   `r(eform)'
		local logrank `r(logrank)'
		local invlist `r(invlist)'
		local _NN     `r(npts)'
		local _BY     `r(by)'				// N.B. contains _SOURCE if `byad'
		local byad    `r(byad)'
		local sourceopt `"source(`_SOURCE')"'
		
		// sort out plotid if byad
		// (oct 2018: moved from -admetan-)
		if `"`plotid'"'!=`""' {
			local 0 `plotid'
			syntax [name] [, *]
			if `"`namelist'"'==`"_BYAD"' local plotid `"`_SOURCE', `options'"'
		}
		
		// UP TO HERE 25th JAN
		// Jan 2019 for v3.2:  Keep track of "stored" varnames found in AD only, not in IPD
		foreach v in _ES _seES _LCI _UCI _WT _NN _CC {
			cap confirm var `v'
			if !_rc & !`: list v in ipdstored' local adstored `adstored' `v'
		}
		if `"`adstored'"'!=`""' local storedopt `"stored(`adstored')"'
		
	}
	if `"`_BY'"'!=`""' local byopt `"`_BY', m"'						// August 2018
	if `"`_NN'"'!=`""' local nptsopt `"`_NN', `plot' `integer'"'	// October 2018
	// (Note: `_STUDY' is guaranteed to exist, so don't need to worry about it being empty)

	// `bymissing' and `smissing' already dealt with;
	//  ==> assume ALL observations in `touse' are to be used, whether missing or not
	// hence use missing suboption to study() and by() here
	cap nois admetan `invlist' if `touse', study(`_STUDY', m) by(`byopt') npts(`nptsopt') ///
		effect(`effect') `eform' `logrank' `method' plotid(`plotid') `opts_ipdm' `rsample' `keepvars' ///
		///
		/// /* extra admetan options, only relevant to ipdmetan; e.g. to prompt suitable display text: */
		/// /*  [N.B. `admopts' also contains:  estexp(`estexp') explist(`explist') `interaction' ipdxline(`extraline') lrvlist(`lrvlist') ] */
		ipdmetan(`admopts' use(`_USE') `byad' `sourceopt' `storedopt' `preserve')
	
	// N.B. `summstat' and `log' are *not* passed to -admetan-
	//  as all the necessary info is already stored in `eform' and `effect'.
	
	if _rc {
		if `"`err'"'==`""' {
			if _rc==1 nois disp as err `"User break in {bf:admetan}"'
			else nois disp as err `"Error in {bf:admetan}"'
		}
		c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan_setup}"
		exit _rc
	}

	return add
	
	// drop extra obs from `ADfile' before returning to main ipdmetan.ado
	// [i.e. end of program if "`cmdstruc'"==""]
	if `"`_SOURCE'"'!=`""' {
		qui drop if `_SOURCE'==2
	}

	// Oct 2018
	if `"`cmdstruc'"'==`""' {
		qui count
		cap assert r(N) == `origN'
		if _rc {
			if "`rsample'"=="" local rstext "failed to add {bf:_rsample} to original data"
			disp as err _n `"Error in {bf:ipdmetan}: `rstext'"'
			disp as err `"Original data has been restored, but analysis output should be checked carefully (and probably discarded)"'
			exit 198
		}
		
		// restore original labels to `study' and `by'
		if `"`studylab'"'!=`""' {
			lab drop `studylab'
			qui do `labfile'
			label values `study' `studylab'
		}
		if `"`bylab'"'!=`""' {
			lab drop `bylab'
			qui do `bylabfile'
			label values `by' `bylab'
		}
		
		if "`rsample'"=="" restore, not		// cancel -preserve- if all is well
	}
	
end




* Process ad() option and compare with data already in memory
// (e.g. check study() and by() exist in both, string/numeric, etc.)

// Strategy: first, parse ad() option and quickly check for errors w.r.t the IPD data
// Load the AD file, process it as for IPD (e.g. study labels), reconfirm structure
// Append the IPD file, and harmonize variables if necessary.

// N.B. CheckOpts has already been run
//  so e.g. if "hr" was supplied, we have "eform" and "summstat(hr)"

// Also conflicting options e.g. wmd and cohen have been tested for
// and if e.g. cohen supplied alone, we have "summstat(smd)"

// subroutine of admetan_setup

program define ProcessAD, rclass

	syntax varlist(min=2 max=6 numeric) [if] [in], AD(string asis) ///
		Study(string asis) [BY(string asis) USELIST(varlist) TVLIST(namelist) ///
		IPDFILE(string) SORTBY(varname) NPTS(varname numeric) noINTeger WGT(varname numeric) ///
		EFORM LOG LOGRank LCols(namelist) RCols(namelist) SUMMSTAT(string) MH PETO * ]

	local invlist `varlist'	
	local params : word count `invlist'
	
	// obtain current variable & value labels from `_STUDY' and (optionally) `_BY'
	tokenize `uselist'
	args _USE _STUDY _BY
	
	// tempvars
	tokenize `tvlist'
	args newstudy newby newbylab _SOURCE sourcelab
	
	// First, create ipd_bylist and ipd_slist using `touse' as defined in IPD
	marksample touse
	if `"`_BY'"'!=`""' {	// if `by' exists in current (IPD) data
		qui levelsof `_BY' if `touse' & inlist(`_USE', 1, 2), local(ipd_bylist) missing		// assume "missing" within previously-defined `touse'
		local bylab : value label `_BY'
		local byvarlab : variable label `_BY'
		local by_in_IPD `_BY'						// clarify name, to compare with by_in_AD later
	}
	qui levelsof `_STUDY' if `touse' & inlist(`_USE', 1, 2), local(ipd_slist) missing		// assume "missing" within previously-defined `touse'
	local studylab : value label `_STUDY'
	local svarlab : variable label `_STUDY'

	// Temporarily rename IPD locals
	local ipdnpts    `npts'					// N.B. either contains `_NN' (if defined) or nothing
	local ipdlogrank `logrank'
	local ipd_iv = inlist(`params', 2, 3)  & "`logrank'"==""
	
	// Identify whether any -admetan- "stored variables" exist in the IPD
	foreach x in _ES _seES _LCI _UCI _WT _NN _rsample {
		cap confirm variable `x'
		if !_rc local ipd_svlist `ipd_svlist' `x'
	}

	
	
	***********************
	* Prepare and load AD *
	***********************
	
	* Now, test to see if `ADfile' has been supplied
	// (alternative is that the "AD" forms a part of the data already in memory)
	local rc = 0
	_parse comma lhs rhs : ad
	if `"`lhs'"'!=`""' {
		gettoken adfile lhs : lhs						// obtain `ADfile' as first word of `lhs'
		if `"`adfile'"'!=`""' {							// check that `ADfile' is valid
			my_prefix_savingIPD `adfile'				// Oct 2018: do this using a modified version of built-in _prefix_saving.ado
			local rc = _rc
			if `rc' local lhs `"`adfile' `lhs'"'		// if it isn't, put `lhs' back together again to apply -syntax- later
		}												// assume AD option (and -syntax-) is to be applied to data currently in memory
	}
	
	* If AD file exists, prepare data and load file
	if `"`adfile'"'!=`""' & !`rc' {

		// Save value labels of `_STUDY' and `_BY', and re-load them within AD file
		if `"`studylab'`bylab'"'!=`""' {
			tempfile adlabfile
			qui label save `studylab' `bylab' using `adlabfile'		// save these labels
		}		

		// Now save data to `ipdfile' so that AD file can be loaded
		local replace
		if `"`ipdfile'"'==`""' tempfile ipdfile
		else local replace replace
		qui save `ipdfile', `replace'		// recycle `ipdfile' as created by ipdmetan.ado if possible
		
		// load AD file, and re-load value labels (but don't apply them yet)
		qui use `"`adfile'"', clear
		if `"`adlabfile'"'!=`""' {
			qui do `adlabfile'
		}
	}
	
	// Now apply syntax
	local 0 `"`lhs' `rhs'"'
	cap syntax [if] [in] [, BYAD VARS(varlist numeric min=2 max=6) NPTS(varname numeric) LOGRank RELabel ///
		ADCOLVARS(namelist) ADPLOTVAR(name) ADSORTBY(name) IPDSTR ]		/* these latter have been added by -ipdmetan- */
			
	if _rc {
		if `rc' & !inlist(`"`adfile'"', "in", "if") & substr(`"`adfile'"', 1, 1)!="[" {
			use `"`adfile'"', clear				// this will (purposefully) result in error 601 "file not found" or "invalid file specification"
		}
		else syntax [if] [in] [, BYAD VARS(varlist numeric min=2 max=6) NPTS(varname numeric) LOGRank RELabel ///
		ADCOLVARS(namelist) ADPLOTVAR(name) ADSORTBY(name) IPDSTR ]	// if `ADfile' not detected, run -syntax- again to (purposefully) exit with error
	}
	else if `rc' local adfile					// clear `adfile' macro for later existence testing	
	
	marksample touse, novarlist		// include missing values
		
	qui count if `touse'
	if !r(N) exit 2000
	local ni=r(N)
	
	// rename locals to clarify which are associated with AD and which IPD
	// from now on, AD locals have prefix "ad"; IPD locals have no prefix
	local adinvlist `vars'
	local adparams : word count `adinvlist'
	local adnpts `npts'
	local adlogrank `logrank'
	local npts `ipdnpts'
	local logrank `ipdlogrank'

	// First, parse `by' (as specified in main option, i.e. with potential `missing') within AD file
	if trim(`"`by'"')==`","' local by
	if `"`by'"'!=`""' {
		if `"`byad'"'!=`""' {
			nois disp as err `"Note: Cannot specify both {bf:byad} and {bf:by()}; {bf:byad} will be ignored"' 
			local byad
		}
			
		local 0 `"`by'"'
		syntax name(name=by) [, Missing]		// only a single (var)name is allowed
		cap confirm var `by'

		// if doesn't exist in AD dataset; check it *does* exist in IPD dataset
		if _rc {
			if `"`by_in_IPD'"'==`""' {
				nois disp as err `"variable {bf:`by'} not found in either IPD or AD dataset"'
				exit 111
			}
		}
		else {
			local _BY = cond(`"`by_in_IPD'"'==`""', `"`newby'"', `"`_BY'"')
			
			if `"`missing'"'==`""' markout `touse' `by', strok
			local by_in_AD `by'			// marker of `by' variable being present in AD (N.B. `by_in_IPD' is marker of presence in *IPD*)
			if `"`bylab'"'==`""' local bylab `newbylab'		// define a tempname if `by' only exists in AD (i.e. by_in_AD)	
			
			// amended Feb 2018 due to local x = ... issue with version <13
			/*
			local byvarlab = cond(`"`byvarlab'"'!=`""', `"`byvarlab'"', ///
				cond(`"`: variable label `by_in_AD''"'!=`""', `"`: variable label `by_in_AD''"', `"`by_in_AD'"'))
			*/
			if `"`byvarlab'"'==`""' {
				local byvarlab `"`: variable label `by_in_AD''"'
				if `"`byvarlab'"'==`""' local byvarlab `by_in_AD'
			}
		}
	}

	// Try parsing `study' (as in main option) within AD file
	local 0 `"`study'"'
	syntax name(name=study) [, Missing]
	cap confirm var `study'
	if !_rc {
		if `"`missing'"'==`""' markout `touse' `study', strok
		
		// amended Feb 2018 due to local x = ... issue with version <13
		/*
		local svarlab = cond(`"`svarlab'"'!=`""', `"`svarlab'"', ///
			cond(`"`: variable label `study''"'!=`""', `"`: variable label `study''"', `"`study'"'))
		*/
		if `"`svarlab'"'==`""' {
			local svarlab `"`: variable label `study''"'
			if `"`svarlab'"'==`""' local svarlab `study'
		}			
	}
	else {
		disp as err `"Note: variable {bf:`study'} (in option {bf:study()}) not found in aggregate dataset;"'
		disp as err `"      all valid observations in the aggregate dataset will be included"' 
		local study
	}
	
	// If `study' not supplied or not found in AD file, assume entire dataset is to be used
	// remove any observations with no (i.e. missing) data in `invlist'.
	// (code fragment taken from _grownonmiss.ado)
	if `"`study'"'==`""' {
		tokenize `adinvlist'
		tempvar g
		qui gen byte `g' = (`1'<.) if `touse'
		mac shift
		while "`1'" != "" {
			qui replace `g' = `g' + (`1'<.) if `touse'
			mac shift
		}
		qui replace `g' = . if `g' == 0		// set to missing for benefit of markout
		markout `touse' `g'
		drop `g'
	}
	
	// `study' might be string in AD file (as indeed it might have originally been in the IPD);
	//   but if *numeric*, compare value labels and detect clashes
	cap confirm numeric var `study'
	if !_rc {
		qui levelsof `study' if `touse', local(ad_slist) missing
		local clash = cond(`"`: list ipd_slist & ad_slist'"'==`""', `""', "clash")		// clash in original IPD and AD study values; new label needed
				
		if "`clash'"!=`""' & `"`relabel'"'==`""' {
			if `"`ipdstr'"'==`""' {
				disp as err `"Study value label conflict between AD and IPD"'
				disp as err `"If appropriate, use the {bf:relabel} suboption of {bf:ad()} to force relabelling of both AD and IPD"'
			}
			else {
				disp as err `"Study value label conflict between AD and IPD, due to {bf:study()} being converted from string in IPD."'
				disp as err `"To avoid this conflict, supply a numeric (within IPD) variable to the {bf:study()} option;"'
				disp as err `"  or to over-ride it, use the {bf:relabel} suboption of {bf:ad()} to force relabelling of both AD and IPD."'
			}
			exit 180
		}
	}

	* Now, create common labels for `study' and `by' across IPD and AD datasets
	// (IPD is guaranteed numeric; AD may need to be converted from string) 

	// N.B. `studylab' contains IPD study labels so far, but ultimately will contain both.
	local ns  : word count `ipd_slist'		// number of IPD studies
	local nby : word count `ipd_bylist'		// number of IPD subgroups
	cap confirm numeric var `study'
	if _rc local smax = `ns'
	else local smax : word `: word count `ipd_slist'' of `ipd_slist'	// max IPD study value
	
	cap nois ProcessLabels if `touse', smax(`smax') nby(`nby') `relabel' ///
		study(`study') newstudy(`_STUDY') newstudylab(`studylab') ///
		by(`by_in_AD') newby(`_BY')       newbylab(`bylab')
	if _rc {
		if _rc==1 nois disp as err `"User break in {bf:admetan.ProcessLabels} when applied to AD"'
		else if _rc!=2000 nois disp as err `"Error in {bf:admetan.ProcessLabels} when applied to AD"'
		c_local err noerr			// tell admetan not to also report an "error in ProcessAD"
		exit _rc
	}
	
	// update `study' within AD; don't apply label just yet though
	if `"`r(newstudy)'"'==`""' {									// if r(newstudy) not returned, just use the original variable
		if `"`study'"'!=`"`_STUDY'"' qui rename `study' `_STUDY'	// (we can rename it since we are under -preserve-)
	}
	else if `"`r(newstudy)'"'!=`"`_STUDY'"' {	// if r(newstudy) *was* returned, use it
		cap drop `_STUDY'						// "capture" since `_STUDY' might not exist
		qui rename `r(newstudy)' `_STUDY'		// (N.B. can safely drop, since `_STUDY' can't be in lcols/rcols)
	}
	
	// amended Feb 2018 due to local x = ... issue with version <13
	// local adstudylab = cond(`"`r(newstudylab)'"'!=`""', `"`r(newstudylab)'"', `"`adstudylab'"')
	// if `"`r(newstudylab)'"'!=`""' local adstudylab `r(newstudylab)'
	// OCT 2018: not needed, as studylab was already guaranteed to exist
	
	// `by' is largely left alone except for converting from string if necessary
	if "`by_in_AD'"!=`""' {
		// amended Feb 2018 due to local x = ... issue with version <13
		// local adbylab  = cond(`"`r(newbylab)'"'!=`""', `"`r(newbylab)'"', `"`adbylab'"')
		// local by_in_AD = cond(`"`r(newby)'"'!=`""',    `"`r(newby)'"',    `"`by_in_AD'"')
		if `"`r(newbylab)'"'!=`""' local bylab `r(newbylab)'
		if `"`r(newby)'"'!=`""'    local by_in_AD `r(newby)'
		qui levelsof `by_in_AD', local(ad_bylist) missing		// for comparing with IPD
		if `"`by_in_AD'"'!=`"`_BY'"' & `"`_BY'"'!=`""' {
			cap drop `_BY'
			qui rename `by_in_AD' `_BY'
			local by_in_AD `_BY'
		}
		else if `"`_BY'"'==`""' local _BY `by_in_AD'
	}
	
	* Extra work specific to *separate* AD file
	if `"`adfile'"'!=`""' {
	
		// (re-) save labels
		qui label save `studylab' `bylab' using `adlabfile', replace

		// check for existence of wgt
		if `"`wgt'"'!=`""' {
			cap confirm numeric var `wgt'
			if _rc {
				disp as err `"Note: user-defined weights {bf:`wgt'} not found in aggregate dataset"'
				local wgt
			}
		}

		// same with sortby and plotvar (but with slightly different error message)
		foreach x in sortby plotvar {
			if "`ad`x''"!="" {
				cap confirm var `ad`x''
				if _rc {
					nois disp as err `"Variable {bf:``x''} in option {bf:`x'()} not found in either IPD or AD dataset"'
					exit 111
				}
			}
		}

		// lcols/rcols: if don't exist in IPD dataset, check they exist in AD dataset
		if `"`adcolvars'"'!=`""' {
			foreach x of local adcolvars {
				cap confirm var `x'
				if _rc {
					nois disp as err `"Variable {bf:`x'}, in {bf:lcols()} or {bf:rcols()}, not found in either IPD or AD dataset"'
					exit 111
				}
			}
		}
		
		// discard unwanted observations and variables from AD file, to save memory
		if `"`lrcols'"'!=`""' {
			qui ds
			local dslist = r(varlist)
			local lrcols : list lrcols & dslist		// identify vars in `lrcols' present in AD file
		}
		qui keep if `touse'
		cap sort `sortby'
		qui keep `touse' `_STUDY' `by_in_AD' `adinvlist' `adnpts' `wgt' `adplotvar' `adcolvars' `lrcols'
		qui gen byte `_USE' = 1
		
		// identify whether any -admetan- "stored variables" exist in the (processed) AD
		foreach x in _ES _seES _LCI _UCI _WT _NN _rsample {
			cap confirm variable `x'
			if !_rc local ad_svlist `ad_svlist' `x'
		}
		local ad_svlist : list ad_svlist - ipd_svlist		// only those elements *NOT* in the IPD dataset
		
	}	// end if `"`adfile'"'!=`""'
	
	else qui replace `_USE' = 1 if `touse'

	
	* Sort out `npts' in AD dataset;
	// only permitted with 2- or 3-element varlist; that is, "ES, seES", "ES, LCI, UCI", or "OE, V"
	if "`adnpts'"!="" {
		if `adparams'<=3 & "`integer'"=="" {
			cap assert int(`adnpts')==`adnpts' if `touse'
			if _rc {
				nois disp as err `"Non-integer counts found in {bf:npts()} suboption to {bf:ad()}"'
				exit _rc
			}
		}
		else if `adparams'>3 {
			nois disp as err `"Option {bf:npts()} only valid with generic inverse-variance model or with logrank (O-E & V) HR"'
			exit 198
		}
		
		if `"`npts'"'!=`""' & `"`adnpts'"'!=`"`npts'"' {
			local badnames `_STUDY' `by_in_AD' `adinvlist' `wgt' `adplotvar' `adcolvars' `lrcols'
			if `: list adnpts in badnames' {
				disp as err `"varname conflict in {bf:npts()} suboption to {bf:ad()}"'
				exit 198
			}
			qui rename `adnpts' `npts'
		}
		else local npts `adnpts'		// hence, `npts' now either contains `adnpts' (if no `npts' in IPD), or `npts' from IPD, or nothing
		return local npts `npts'		// (`adnpts' is not needed henceforth)
	}

	
	
	************************************
	* Compare AD & IPD data structures *
	************************************

	// Compatible structures:
	// any `ipdparams'==`adparams'; AD method/summstat/etc. is same as for IPD
	// assuming no obvious incompatibility (e.g. can't have IPD I-V, summstat="wmd" and `adparams'==4):
	//   IPD I-V (i.e. `params'==2 & !logrank);  AD method then also analysed as I-V
	//   AD  I-V (i.e. `params'==2 & !logrank); IPD method then also analysed as I-V -- ERROR IF NON-IV OPTIONS GIVEN
	
	// ad_iv = AD has IV structure; that is, 2 or 3 param varlist
	local ad_iv = inlist(`adparams', 2, 3) & "`adlogrank'"==""
	
	// Test for incompatible structures:
	if "`cmdstruc'"=="generic" {
	
		if inlist("`summstat'", "or", "hr", "shr", "irr", "rr", "rrr") {
			cap assert `adparams' != 6
			if _rc {
				disp as err "Aggregate data structure"
				disp as err "  detected as {it:n_treat mean_treat sd_treat n_ctrl mean_ctrl sd_ctrl}"
				disp as err "which is incompatible with IPD"
				exit 184
			}
		}

		else if inlist("`summstat'", "smd", "wmd", "md", "rd") {
			cap assert `adparams' != 4
			if _rc {
				disp as err "Aggregate data structure"
				disp as err "  detected as {it:event_treat noevent_treat event_ctrl noevent_ctrl}"
				disp as err "which is incompatible with IPD"
				exit 184
			}
		}
	}
	
	// cmdstruc = specific
	else {

		// IPD is `params'==4 or logrank HR; `adparams' cannot be 6
		// (N.B. IPD logrank HR, params==2, with `adparams'==4 *is* permitted
		//  so that HRs can be compared with ORs/RRs in niche cases; but give warning message)
		if `params'==4 | (`params'==2 & `"`logrank'"'!=`""') {
			cap assert `adparams' != 6
			if _rc {
				disp as err "Aggregate data structure"
				disp as err "  detected as {it:n_treat mean_treat sd_treat n_ctrl mean_ctrl sd_ctrl}"
				disp as err "which is incompatible with IPD"
				exit 184
			}
		}
		
		// ...and the reverse
		else if `params'==6 {
			cap assert !(`adparams'==4 | (`adparams'==2 & `"`adlogrank'"'!=`""'))
			if _rc {
				disp as err "Aggregate data structure"
				if `adparams'==4 disp as err `"  detected as {it:event_treat noevent_treat event_ctrl noevent_ctrl}"'
				else             disp as err `"  detected as log-rank {it:O-E V}"'
				disp as err "which is incompatible with IPD"
				exit 184
			}
		}
		
		// IPD is M-H or Peto; `adparams' must be 4
		else if `params'==4 & `"`mh'`peto'"'!=`""' {
			cap assert `adparams' == 4
			if _rc {
				local erropt : word 1 of `mh' `peto'
				disp as err "Aggregate data structure is incompatible with {bf:`erropt'} option"
				exit 184
			}
		}		
		
		// Catch any other combinations (18th July 2018: Is it actually possible to arrive here??)
		else if !`ipd_iv' & !`ad_iv' & !(`adparams'==`params' & "`adlogrank'"=="`logrank'") {
			nois disp as err "IPD and AD data files are incompatible."
			nois disp as err "Need to either analyse within each dataset separately,"
			nois disp as err " or first manipulate the data so that they are compatible."
			exit 198
		}
	}

	// For AD, if count data (`adparams'==4) or logrank HR (`adlogrank') and no further info
	// then default to *log* (rather than to *eform* as for IPD)
	if `adparams'==4 {
		if `"`summstat'"'==`""' {
			local logstr = cond(`"`eform'"'==`""', `"log "', `""')
			disp as err _n `"Note: Effects assumed to represent `logstr'Risk Ratios, due to 2x2 count data in {bf:ad()}"'
			local summstat rr
			local effect "`logstr'Risk Ratio"
		}
	}
	else if `"`adlogrank'"'!=`""' {
		if `"`logrank'"'==`""' {
			local logstr = cond(`"`eform'"'==`""', `"log "', `""')
			disp as err _n `"Note: Effects assumed to represent `logstr'Hazard Ratios, due to {bf:logrank} suboption in {bf:ad()}"' 
		}
		local summstat hr
		local effect "`logstr'Haz. Ratio"
	}
		
	// If data structures exactly match, simply rename advarlist to match with IPD
	if `adparams'==`params' & "`adlogrank'"=="`ipdlogrank'" {
		local rc = 0	// reset
		local i = 1
		foreach adv of varlist `adinvlist' {
			local ipdv : word `i' of `invlist'
			if `"`adv'"'!=`"`ipdv'"' cap rename `adv' `ipdv'
			local rc = `rc' + _rc
			local ++i
		}
		if `rc' {
			nois disp as err `"{it:varlist} name conflict between IPD and aggregate data; please check"'
			exit _rc
		}
		local adinvlist `invlist'
		
		if inlist(`"`summstat'"', "hr", "shr") & `"`adlogrank'"'==`""' & `adparams'==2 {
			disp as err `"Note: Aggregate data variables assumed to represent {it:logHR} and {it:selogHR}"'
			disp as err `"      If in fact they should represent {it:O-E} and {it:V}, please supply the {bf:logrank} suboption to {bf:ad()}"' 
		}
	}

	// Else if structures *nearly* match; i.e. both I-V...
	// ...but one uses _ES, _seES and the other _ES, _LCI, _UCI
	else if `ad_iv' & `ipd_iv' & ///
		((`params'==2 & `adparams'==3) | (`adparams'==2 & `params'==3)) {
		gettoken adword1 adrest : adinvlist
		gettoken   word1   rest :   invlist

		// 2nd variable onwards should be named differently
		// (since one is assumed to be _seES and the other _LCI _UCI)
		cap assert `"`: list rest & adrest'"'==`""'
		if _rc {
			nois disp as err `"{it:varlist} name conflict between IPD and aggregate data; please check"'
			exit _rc
		}
		
		// Similarly, first variables should both represent _ES
		//  hence, rename
		if `"`adword1'"'!=`"`word1'"' {
			cap nois rename `adword1' `word1'
			if _rc {
				nois disp as err `"{it:varlist} name conflict between IPD and aggregate data; please check"'
				exit _rc
			}
			local adinvlist `"`word1' `adrest'"'
		}
	}
	
	// If one uses _ES, _seES (i.e. presumably logHR, selogHR) but the other uses OE & V,
	//  display appropriate warning message r.e. confusion between whether AD input is really _ES, _seES or OE & V
	// (N.B. this may occur even if both are nominally I-V)
	else if `params'==2 & `"`logrank'"'!=`"`adlogrank'"' {
	
		if `"`logrank'"'==`""' {	// i.e & `"`adlogrank'"'!=`""' {
			disp as err `"Note: Aggregate data variables assumed to represent {it:O-E} and {it:V} due to {bf:logrank} suboption in {bf:ad()}"'
		}
		else {	// i.e. if `"`adlogrank'"'==`""' & `"`logrank'"'!=`""' {
			disp as err `"Note: Aggregate data variables assumed to represent {it:logHR} and {it:selogHR}"'
			disp as err `"      If in fact they should represent {it:O-E} and {it:V}, please supply the {bf:logrank} suboption to {bf:ad()}"' 
			disp as err `"     (that is, in addition to the {bf:logrank} main option to {bf:ipdmetan})"' 
		}
		local method iv
	}
	
	* Else one is I-V and the other is not (and structures are different)
	// then `invlist' and `adinvlist' should be disjoint: check this
	else if !(`adparams'==`params' & "`adlogrank'"=="`logrank'") {

		cap assert `"`: list invlist & adinvlist'"'==`""'
		if _rc {
			nois disp as err `"{it:varlist} name conflict between IPD and aggregate data; please check"'
			exit _rc
		}

		// Oct 2018: Can't have this AND the earlier "catch" of incompatible structures!
		// Use this as a sandbox but ultimately comment out
		/*
		local method iv		
		local ivdata = cond(`ad_iv', "AD", "IPD")
		local nonivdata = cond(!`ad_iv', "AD", "IPD")
		nois disp as err `"Note: `ivdata' has different variable structure to `nonivdata', but is assumed to be compatible using inverse-variance"'
		nois disp as err `"      please check stated outcome, method and results carefully"'
		*/
		
	}	// end else if `rc'

	
	*****************************
	* Re-load IPD and append AD *
	*****************************
	
	// N.B. more trouble this way (than simply appending AD)
	//  but better in the long term e.g. ordering of observations and file headers
	
	qui gen byte `_SOURCE' = 2 if `touse'
	if `"`adfile'"'!=`""' {
		tempfile tempadfile
		qui save `tempadfile'
		qui use `ipdfile', clear
		qui append using `tempadfile'
		qui do `adlabfile'
	}
	qui replace `_SOURCE' = 1 if missing(`_SOURCE') & `_USE'!=5
	
	label variable `_SOURCE' "Data source"			
	label define `sourcelab' 1 "IPD" 2 "Aggregate data"
	label values `_SOURCE' `sourcelab'


	* Next, determine whether -admetan- needs to be run on either IPD or AD
	//  ultimately to enable entire dataset to be analysed together.
	// In either case, store *all* (old + new) I-V data under the varnames used by the *existing* I-V data.
	// Then, set `invlist' to contain those varnames.
	
	// Case 0: Both are I-V, but one is _ES _seES (`params'==2) and the other is _ES _LCI _UCI (`params'==3)
	if `ipd_iv' & `ad_iv' & `params'!=`adparams' {
		if `adparams'==3 {
			tokenize `invlist'
			args ipd_ES ipd_seES
			tokenize `adinvlist'
			args ad_ES ad_LCI ad_UCI
			qui replace `ipd_seES' = (`ad_UCI' - `ad_LCI') / (2*invnormal(.5 + 95/200)) if `_SOURCE'==2 & `touse'
		}
		else {
			tokenize `adinvlist'
			args ad_ES ad_seES
			tokenize `invlist'
			args ipd_ES ipd_LCI ipd_UCI
			qui replace `ad_seES' = (`ipd_UCI' - `ipd_LCI') / (2*invnormal(.5 + 95/200)) if `_SOURCE'==1 & `_USE'==1
		}
	}
		
	// Case 1: IPD is I-V; AD is not.
	//  ==> run -admetan- on AD and copy results into `invlist'
	else if `ipd_iv' & !`ad_iv' {
		
		tokenize `invlist'
		if `params'==2 args old_ES old_seES
		else args old_ES old_LCI old_UCI
		
		// If any variables named _ES, _seES, _LCI, _UCI, _WT or _NN exist in the dataset (AD or IPD)
		// temp rename them to avoid being overwritten by -admetan-
		cap confirm variable _ES
		if !_rc {
			tempvar temp_ES
			qui rename _ES `temp_ES'
			local rnlist _ES
		}
		local new_ES = cond("`old_ES'"=="_ES", "`temp_ES'", "`old_ES'")
		local invlist2 `new_ES'
		
		cap confirm variable _seES
		if !_rc {
			tempvar temp_seES
			qui rename _seES `temp_seES'
			local rnlist `rnlist' _seES
		}
		local new_seES = cond("`old_seES'"=="_seES", "`temp_seES'", "`old_seES'")
		local invlist2 `invlist2' `new_seES'

		foreach x in _LCI _UCI {
			cap confirm variable `x'
			if !_rc {
				tempvar temp`x'
				qui rename `x' `temp`x''
				local rnlist `rnlist' `x'
			}
			local new`x' = cond(`"`old`x''"'==`"`x'"', `"`temp`x''"', `"`old`x''"')
			local invlist2 `invlist2' `new`x''
		}

		foreach x in _WT _rsample {	
			cap confirm variable `x'
			if !_rc {
				tempvar temp`x'
				qui rename `x' `temp`x''
				local rnlist `rnlist' `x'
			}
		}
		
		cap confirm variable _NN
		if !_rc {
			tempvar temp_NN
			qui rename _NN `temp_NN'
			local rnlist `rnlist' _NN
		}
		local npts = cond("`npts'"=="_NN", "`temp_NN'", "`npts'")
		local invlist2 `invlist2' `npts'
		
		cap admetan `adinvlist' if `_SOURCE'==2 & `touse', `adlogrank' npts(`npts') nogr noov nosu notab nohet
		if _rc {
			if _rc==1 nois disp as err `"User break in {bf:admetan}"' _c
			else nois disp as err `"Error in {bf:admetan}"' _c
			nois disp as err `" whilst converting aggregate data to inverse-variance format"'
			exit _rc
		}	
	
		// Copy newly-created data from _ES, _seES (or _LCI, _UCI) into IPD varnames (`invlist2')
		tokenize `invlist2'		
		qui replace `1' = _ES if `_SOURCE'==2 & `touse'
		if `params'==2 {
			qui replace `2' = _seES if `_SOURCE'==2 & `touse'
		}
		else {
			qui replace `2' = _LCI if `_SOURCE'==2 & `touse'
			qui replace `3' = _UCI if `_SOURCE'==2 & `touse'
		}
		if `"`npts'"'!=`""' {
			local ++params
			qui replace ``params'' = _NN if `_SOURCE'==2 & `touse'
		}
		
		// Now rename back from tempnames to original names
		//  *UNLESS* they only existed in the AD and not the IPD (in which case, let them be lost)
		qui drop _ES _seES _LCI _UCI _WT _rsample
		if `"`npts'"'!=`""' {
			qui drop _NN
		}
		local rnlist : list rnlist - ad_svlist
		foreach x of local rnlist {
			qui rename `temp`x'' `x'
		}
	}
	
	// Case 2: AD is I-V; IPD is not.
	//  ==> run -admetan- on IPD	
	else if `ad_iv' & !`ipd_iv' {

		tokenize `adinvlist'
		
		// If IPD is logrank, we want -admetan- to analyse OE & V
		//  so that it prints "log Haz. Ratio"; "Peto log-rank" etc. on-screen.
		// Hence, need to convert `adinvlist' to OE & V before passing on to -admetan- for final analysis.
		//  (Note that this didn't apply to the reverse procedure,
		//    since if `ipdlogrank' is NOT specified, the analysis is not presented as logrank.)
		if `"`logrank'"'!=`""' {
			if `adparams'==3 {
				args ad_ES ad_LCI ad_UCI
				tempvar ad_seES	
				qui gen double `ad_seES' = (`ad_UCI' - `ad_LCI') / (2*invnormal(.5 + 95/200)) if `_SOURCE'==2 & `touse'
			}
			else args ad_ES ad_seES
		
			tokenize `invlist'
			args oe v
			qui replace `v'  = 1 / `ad_seES'^2 if `_SOURCE'==2 & `touse'
			qui replace `oe' = `v' * `ad_ES'   if `_SOURCE'==2 & `touse'
		}
		
		// Otherwise, carry out similar procedure to Case 1
		else {
			if `adparams'==2 args old_ES old_seES
			else args old_ES old_LCI old_UCI
		
			// If any variables named _ES, _seES, _LCI, _UCI, _WT or _NN exist in the dataset (AD or IPD)
			// temp rename them to avoid being overwritten by -admetan-
			cap confirm variable _ES
			if !_rc {
				tempvar temp_ES
				qui rename _ES `temp_ES'
				local adrnlist _ES
			}
			local new_ES = cond("`old_ES'"=="_ES", "`temp_ES'", "`old_ES'")
			local adinvlist2 `new_ES'

			cap confirm variable _seES
			if !_rc {
				tempvar temp_seES
				qui rename _seES `temp_seES'
				local adrnlist `adrnlist' _seES
			}
			local new_seES = cond("`old_seES'"=="_seES", "`temp_seES'", "`old_seES'")
			if `adparams'==2 local adinvlist2 `adinvlist2' `new_seES'

			foreach x in _LCI _UCI {
				cap confirm variable `x'
				if !_rc {
					tempvar temp`x'
					qui rename `x' `temp`x''
					local adrnlist `adrnlist' `x'
				}	
				local new`x' = cond(`"`old`x''"'==`"`x'"', `"`temp`x''"', `"`old`x''"')
				if `adparams'==3 local adinvlist2 `adinvlist2' `new`x''
			}
			
			foreach x in _WT _rsample {	
				cap confirm variable `x'
				if !_rc {
					tempvar temp`x'
					qui rename `x' `temp`x''
					local adrnlist `adrnlist' `x'
				}
			}

			cap confirm variable _NN
			if !_rc {
				tempvar temp_NN
				qui rename _NN `temp_NN'
				local adrnlist `adrnlist' _NN
			}
			local npts = cond("`npts'"=="_NN", "`temp_NN'", "`npts'")
			local adinvlist2 `adinvlist2' `npts'

			cap admetan `invlist' if `_SOURCE'==1 & `_USE'==1, `logrank' npts(`npts') nogr noov nosu notab nohet
			if _rc {
				if _rc==1 nois disp as err `"User break in {bf:admetan}"' _c
				else nois disp as err `"Error in {bf:admetan}"' _c
				nois disp as err `" whilst converting IPD to inverse-variance format"'
				exit _rc
			}

			// Copy newly-created data from _ES, _seES (or _LCI, _UCI) into varnames (`adinvlist2')
			tokenize `adinvlist2'
			qui replace `1' = _ES if `_SOURCE'==1 & `_USE'==1
			if `params'==2 {
				qui replace `2' = _seES if `_SOURCE'==1 & `_USE'==1
			}
			else {
				qui replace `2' = _LCI if `_SOURCE'==1 & `_USE'==1
				qui replace `3' = _UCI if `_SOURCE'==1 & `_USE'==1
			}		
			if `"`npts'"'!=`""' {
				local ++params
				qui replace ``params'' = _NN if `_SOURCE'==1 & `_USE'==1
			}
		
			// Now rename back from tempnames to original names
			//  *UNLESS* they only existed in the AD and not the IPD (in which case, let them be lost)
			qui drop _ES _seES _LCI _UCI _WT _rsample
			if `"`npts'"'!=`""' {
				qui drop _NN
			}
			local adrnlist : list adrnlist - ad_svlist
			foreach x of local adrnlist {
				qui rename `temp`x'' `x'
			}
		}
		
		local invlist = cond(`"`logrank'"'!=`""', `"`oe' `v'"', `"`adinvlist'"')
	}
	
	
	** Sort out various permutations of _BY
	
	// If byad, replace _USE==5 with _USE==3 in IPD dataset
	if `"`byad'"'!=`""' {
		qui replace `_USE' = 3    if `_USE'==5 & missing(`_SOURCE')
		qui replace `_SOURCE' = 1 if `_USE'==3 & missing(`_SOURCE')
	}
			
	// If `by' only exists in one dataset or the other, but NOT both:
	//  - if `by' in IPD but not AD, set AD value to r(max) + 1
	else if `"`by_in_IPD'"'!=`""' & `"`by_in_AD'"'==`""' {
		summ `_BY' if `_SOURCE'==1, meanonly
		qui replace `_BY' = r(max) + 1 if `_SOURCE'==2
		label define `bylab' `=r(max) + 1' "Aggregate data", add				
	}			
			
	//  - if `by' in AD but not IPD, set IPD value to r(min) - 1
	else if `"`by_in_AD'"'!=`""' & `"`by_in_IPD'"'==`""' {
		summ `_BY' if `_SOURCE'==2, meanonly
		qui replace `_BY' = r(min) - 1 if `_SOURCE'==1
		label define `bylab' `=r(min) - 1' "IPD", add
	}
	
	// Finalise study and by labels
	label variable `_STUDY' `"`svarlab'"'
	label values `_STUDY' `studylab'
	
	if `"`_BY'"'!=`""' {
		label variable `_BY' `"`byvarlab'"'
		label values `_BY' `bylab'
	}
	else if `"`byad'"'!=`""' local _BY `_SOURCE'
	
	// Sort by source
	tempvar obs
	qui gen long `obs' = _n
	sort `_SOURCE' `_USE' `obs'

	// Return values
	return local invlist  `invlist'
	return local by       `_BY'
	return local byad     `byad'
	return local eform    `eform'
	return local effect   `"`effect'"'
	return local logrank  `logrank'
	return local method   `method'
	return local summstat `summstat'

end



* Modified version of _prefix_saving.ado
// [IPD version] simply tests whether AD file exists
// October 2018, for ipdmetan v3.0

// subroutine of ProcessAD

program define my_prefix_savingIPD
	 
	cap nois syntax anything(id="file name" name=fname)
	if !_rc {
		local rfname = reverse(`"`fname'"')
		local ss : subinstr local rfname "atd." ""
		local rss = reverse(`"`ss'"')
		confirm file `"`rss'.dta"'
	}

end




***************************************************

* Program to process `study' and `by' labels
// based on earlier ProcessAD.ado but altered quite a bit
// (called from within ProcessAD subroutine)

// Two functions:

// 1. If `study' and/or `by' are string, and `newstudy' & `newstudylab' and/or `newby' & `newbylab' are undefined (except as tempnames/tempvars)
//   then convert to numeric using those tempnames/tempvars.

// 2. If `study' and/or `by' are numeric, and `newstudylab' and/or `newbylab' *are* defined already
//   then add values of `study' and `by' onto existing `newstudylab' and/or `newbylab' (exiting with error if not possible).

program define ProcessLabels, rclass sortpreserve

	syntax [if] [in], NEWSTUDY(name) [NEWSTUDYLAB(name) STUDY(name) SMAX(integer 0) ///
		NEWBY(name) NEWBYLAB(name) BY(name) NBY(integer 0) /*BYAD*/ RELabel]
			 
	// First, test for *existence* of `study' and `by' in current data
	cap confirm variable `study'
	if _rc local study
	cap confirm variable `by'
	if _rc local by
	
	// Next, mark sample and check that it is populated
	marksample touse
	qui count if `touse'
	if !r(N) {
		if `"`study'"'!=`""' {
			local errtext `"in {bf:study()} variable"'
			if `"`by'"'!=`""' local errtext `"`errtext' or "'
		}
		if `"`by'"'!=`""' local errtext `"`errtext'in {bf:by()} variable"'
		nois disp as err `"no valid observations `errtext'"'
		exit 2000
	}	
	local nsad = r(N)
	
	tempvar obs
	qui gen long `obs' = _n

	
	** Subgroup (`by') labelling (if applicable)
	// N.B. do this first, in case `by' is string and contains missings. Stata sorts string missings to be *first* rather than last.
	// If IPD alone, ProcessLabels will never be run.
	// If AD alone, no need for a new variable (`newby') unless `by' is string, but tempvar is set just in case
	// If IPD+AD, `by' contains the AD by-var and `newby' contains "_BY" (i.e. the name of the var used in IPD, with label `newbylab')
	if `"`by'"'!=`""' {
	
		cap confirm numeric variable `by'

		// If AD alone, or IPD+AD but `by' doesn't appear in IPD, no need to do anything (this is !`nby')
		// else, map AD values onto IPD label and check for conflicts
		if !_rc & `nby' {
			tempvar bygroup
			qui bysort `touse' `by' : gen long `bygroup' = (_n==1) if `touse'
			qui bysort `touse' : replace `bygroup' = sum(`bygroup') if `touse'
			local nby = `bygroup'[_N]		// this will be in `touse' since (a) we know at least one obs is `touse'; (b) `touse' is sorted so zeros come first.
			
			nois disp `nby'
			
			sort `obs'
			forvalues i=1/`nby' {
				summ `obs' if `touse' & `bygroup'==`i', meanonly
				local val = `by'[`r(min)']
						
				local bylabi    : label (`by') `val'					// AD label value (not "strict")
				local newbylabi : label `newbylab' `val', strict		// IPD label value ("strict")
				if `"`newbylabi'"'==`""' & `val'!=. {
					label define `newbylab' `val' "`bylabi'", add
				}					
				else {
					local bylabi : label (`by') `val', strict			// "strict" AD label value
					if `"`newbylabi'"'!=`"`bylabi'"' & `"`bylabi'"'!=`""' {
						nois disp as err `"Subgroup value label conflict at value `val'"'
						exit 180
					}
				}
			}
			local newby `by'
			return local newby    `by'			// use existing variable...
			return local newbylab `newbylab'	// ...but new (extended from IPD) value label
		}

		// string
		else if _rc {
			cap confirm var `newby'
			if !_rc {
				tempvar newby_temp
				qui encode `by' if `touse', gen(`newby_temp') label(`newbylab')		// order automatically if label not yet defined
				qui replace `newby' = `newby_temp' if `touse'						// if already exists, encode using newby_temp then copy across
			}
			else {
				qui encode `by' if `touse', gen(`newby') label(`newbylab')			// o/w, just use encode directly
			}
			
			label values `newby' `newbylab'
			return local newby    `newby'
			return local newbylab `newbylab'
		}
		
		// else, still need `newby' for subequent code
		else local newby `by'		
		
	}	// end if `"`by'"'!=`""'
	else local newby

	
	** Study label
	// If AD numeric, check for clash with IPD.
	//   If clash and `relabel' not specified, exit with error; create new AD var starting from [max IPD value] + 1
	//       i.e. take oldlabel value from oldAD[i] and map it to `i' + `smax' newlabel
	//   If no clash, loop over AD values and add to existing IPD label
	//       i.e. take oldlabel value from oldAD[i] and map it to oldAD[i] newlabel
	// If AD string, create numeric var starting starting from [max IPD value] + 1
	//       i.e. take oldstring and map it to `i' + `smax' newlabel
	// If AD doesn't have `study', create dummy var starting from [max IPD value] + 1
	//       (no labelling to be done; empty labels)

	// if `study' is numeric, labelled, and *not* IPD+AD (i.e. !`smax'), no need to do anything
	cap confirm numeric var `study'
	local rc = _rc
	local noloop = !`rc' & !`smax'
	if `"`study'"'!=`""' {
		local noloop = `noloop' * (`"`: value label `study''"'!=`""')
	}
	
	// else, need to loop over `study' values and define a new label
	if !`noloop' {

		// If AD is string/missing, or if IPD+AD and clash ==> AD relabelling, use/gen new AD variable `newstudy'
		if `rc' | `"`relabel'"'!=`""' {
			cap confirm variable `newstudy'
			if _rc qui gen long `newstudy' = .
			qui bysort `touse' (`newby' `obs') : replace `newstudy' = _n + `smax' if `touse'
			sort `newstudy'				// studies of interest should now be the first `nsad' observations
			return local newstudy `newstudy'
		}
		else local smax = 0				// if not generating new variable, don't offset
		
		// Before continuing, find the first obs (under current sort) where `touse'==1
		qui replace `obs' = _n
		summ `obs' if `touse', meanonly
		local offset = r(min)
		
		// Now either generate new AD label, or add AD values to existing IPD label (`newstudylab')
		forvalues i=1/`nsad' {
			
			local si_new = `i' + `smax'		// if string or missing
		
			// if `study' not present, create "dummy" label consisting of `si_new' values
			if `"`study'"'==`""' {
				label define `newstudylab' `si_new' `"`si_new'"', add
			}
			
			else {
				local si_old = `study'[`=`i' + `offset' - 1']
				if !`rc' {
					local si_new = cond(`smax', `i' + `smax', `si_old')		// numeric
				}
			
				// if `study' is numeric and labelled, copy `study' value labels across to `newstudylab'
				// (offset by `smax' if `relabel', o/w not)
				if !`rc' {
					cap assert `"`: label `newstudylab' `si_new''"'==`"`: label (`study') `si_old''"'	// if label is already defined correctly, don't attempt to re-label
					if _rc label define `newstudylab' `si_new' `"`: label (`study') `si_old''"', add
				}
				
				// if `study' is string, put `study' strings into `newstudylab' values (offset by `smax')
				else {
					cap assert `"`: label `newstudylab' `si_new''"'==`"`si_old'"'	// if label is already defined correctly, don't attempt to re-label
					if _rc label define `newstudylab' `si_new' `"`si_old'"', add
				}
			}
		}

		return local newstudylab `newstudylab'
	}
	
end

