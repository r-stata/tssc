* admetan.ado
* "Aggregate-data" meta-analysis, including two-stage IPDMA if called from ipdmetan.ado

* originally written by David Fisher, June 2013

* version 1.0  David Fisher  31jan2014

* version 2.0  David Fisher  11may2017
* Major update to extend functionality beyond estimation commands; now has most of the functionality of -metan-
//  - Reworked so that ipdmetan.ado does command processing and looping, and admetan.ado does RE estimation (including -metan- functionality)
//  - Hence, ipdover calls ipdmetan (but never admetan); ipdmetan calls admetan (if not called by ipdover); admetan can be run alone.
//      Any of the three may call forestplot, which of course can also be run alone.


* Notes on version 2.0:
// (revised March 2018 for version 2.2 and again Oct 2018 for v3.0)

* On the logic of "summstat", "method" and "model":

// (1) `summstat' = name summary statistic, e.g. OR, RR, RD, HR, WMD, SMD
//  - If _ES and _seES/_LCI/_UCI are supplied by user, `summstat' is undefined
//    (resulting in a generic "Effect" heading in the output) unless specified by user
//  - If raw count data, default is RR
//  - If raw mean data, default is (Cohen) SMD

// (2) `method' = method for *constructing* _ES and _seES from the raw data
//  - If _ES and _seES/_LCI/_UCI are supplied by user, `method' defaults to "iv"
//  - If raw count data, `summstat' is constructed in the standard way (even if "mh")
//  - If raw mean (continuous) data, default is Cohen SMD
// Options are:
//  - `peto' = Peto OR (count data only)
//       (N.B.  Peto OR is only way in which *individual study* ORs may differ from default "ad/bc")
//       (N.B.2 "Peto heterogeneity statistic" is actually mathematically equivalent to standard,
//          although its defining formula is often presented differently ... and of course the individual ORs *are* different)
//  - `mh' = calculate M-H heterogeneity statistic, regardless of `model'
//       (N.B. *individual* ORs/RRs/RDs are unchanged, but the M-H *pooled* estimate is different)
//  - `wmd'/`glass'/`hedges' = override Cohen SMD (cts data only)
//  - `logrank' = interpret 2-element varlist as O-E and V; construct logHR = log(O-E/V)

// (3a) `model' = method of *pooling*
//  - Mantel-Haenszel ("mh")
//  - Fixed-effect inverse-variance ("fe")
//  - Additive random-effects inverse-variance (various; default="dl" for DerSimonian-Laird)
//  - Hybrid models involving "within-model" corrections to weights, variances, test distribution ("gamma", "hc")
//  - Multiplicative heterogeneity ("mu") ... 
//  - IVHet ("ivhet")

// (3b) additional options, as follows:
//  - `hksj' = HKSJ "post-hoc" variance correction (to any additive re model; usually dl or reml)
//  - `bartlett' = Bartlett correction to "pl" model
//  - qe(`varname) = Quality effects model (based around dl tausq estimate)

// Note that if "`method'"=="mh" but "`model'"!="mh", then:
//  - the M-H heterogeneity statistic will be reported
//    (since this quantity assumes fixed-effects ==> independent of analysis model),
//  - but otherwise the analysis will proceed using whatever `model' is specified.


* So, valid combinations of options are as follows (with separate `breslow' and `logrank' options):
//																				`summstat'		`method'			`model'
// If M-H, then M-H heterogeneity and no RE (i.e. M-H pooling)					or/rr/rd		mh					mh
// If random-effects and count data (peto only if OR):							or/rr/rd		mh/iv/peto			re
// But if specifically FE I-V then cannot be M-H het							or/rr/rd		iv/peto				fe
// If Peto/logrank, then Peto heterogeneity but can also have RE				hr				iv/peto (+logrank)	fe/re
// If Cohen/Glass/Hedges, then Cochran heterogeneity but can also have RE		wmd/smd			cohen etc.			fe/re


* version 2.1  David Fisher  14sep2017
// various bug fixes
// Note: for harmonisation with metan/metaan, Isq input and output is now in the range 0 to 100, rather than 0 to 1.

// Corrected error whereby tausq could not be found by iterative methods if >> 0
//  due to assumptions based on me mostly using ratio statistics, where tausq < 1, and not mean differences where tausq can be any magnitude.


* version 3.0  David Fisher  08nov2018
// IPD+AD code now moved to ipdmetan.ado
//   so that admetan is completely self-contained, with minimal reference to -ipdmetan-
// various bug fixes and minor improvements
// implemented -useopts- facility and _EFFECT variable

* version 3.1  David Fisher  04dec2018
// Allow `oev' with Peto ORs
// Specify default format & title for numeric vars in results sets, so that they display nicely in forestplot
// Fixed bug which meant "HKSJ method" was not displayed on screen (although the method itself was used)
// `hksj' and `bartlett' are returned (if applicable) in r(vce_model)

*! version 3.2  David Fisher  28jan2019
// Do not allow `study' and `by' to have the same name
// Added SJ Robust ("sandwich-like") variance estimator (Sidik & Jonkman CompStatDataAnalysis 2006)
// Added Skovgaard's correction to the signed likelihood statistic (Guolo Stat Med 2012)
// Corrected returned statistics for `chi2opts' and Henmi-Copas model
// Corrected bug when specifying npts(varname) with "generic" effect measures
// Generalised the two-step estimators (Sidik-Jonkman and DerSimonian-Kacker)
// `hksj', `bartlett', `skovgaard' and `robust' are returned (if applicable) as part of r(model)
// Some text in help file has been changed/updated


program define admetan, rclass

	version 11.0
	local version : di "version " string(_caller()) ":"

	syntax varlist(numeric min=2 max=6) [if] [in] [, ///
		STUDY(string) LABEL(string) BY(string)       /// label() is included solely for backward-compatibility with metan.ado
		FORESTplot(passthru)                         /// forestplot (ultimately -twoway-) options
		noKEEPVars noRSample                         /// whether to leave behind study-estimate variables
		LEVEL(passthru) * ]
	
	local opts_adm `"`macval(options)'"'
	marksample touse, novarlist		// `novarlist' option so that entirely missing/nonexistent studies/subgroups may be included
	local invlist `varlist'			// list of "original" vars passed by the user to the program 

	if "`keepvars'"!="" & "`rsample'"!="" {
		disp as err `"only one of {bf:nokeepvars} or {bf:norsample} is allowed"'
		exit 198
	}
	local keepvars = cond(`"`rsample'"'!=`""', `"nokeepvars"', `"`keepvars'"')			// noRSample implies noKEEPVars
	
	
	*****************
	* Extra parsing *
	*****************
	
	** -admetan- called by -ipdmetan-
	// If -admetan- was not called directly, but from within -ipdmetan-,
	//   then the following extra options are needed now (other extra options are parsed later e.g. by BuildResultsSet):
	// `ipdmetan' :  calling program was -ipdmetan-
	// `interaction' :  -ipdmetan- fitted an interaction model (needed for ParseFPlotOpts)
	// `preserve' :  implies that data is already under -preserve- (set by ipdmetan)
	// `_USE' may already be defined by -ipdmetan-;  if not, we generate _USE==1 and alter later if necessary
	// Other options passed from -ipdmetan- are stored in `opts_ipdm' for later parsing (e.g. when displaying results text on-screen)
	
	local preserve preserve			// default is to preserve data later, if forestplot/saving
	
	local 0 `", `opts_adm'"'
	syntax [, IPDMETAN(string) * ]
	if trim(`"`ipdmetan'"') != `""' {
		
		// Parse options passed through from -ipdmetan-
		local opts_adm `"`macval(options)'"'
		local 0 `", `ipdmetan'"'
		syntax, [USE(varname numeric) SOURCE(varname numeric) STORED(namelist) PRESERVE * ]
		local _USE `use'
		local opts_ipdm `"`options' source(`source') ipdmetan"'		// `source' is needed both by main -admetan- routine and by BuildResultsSet
																	// (N.B. `options' and `ipdmetan' are needed by PrintDesc but *not* necessarily by BuildResultsSet)
		local orbyad `"(or {bf:byad}) "'							// for warning/error text later
	}
	
	
	** Next, parse -forestplot- options to extract those relevant to -admetan-
	// N.B. Certain options may be supplied EITHER to admetan directly, OR as sub-options to forestplot()
	//  with "forestplot options" prioritised over "admetan options" in the event of a clash.
	
	// These options are:
	// effect options parsed by CheckOpts (e.g. `rr', `rd', `md', `smd', `wmd', `log')
	// nograph, nohet, nooverall, nosubgroup, nowarning, nowt, nostats
	// effect, hetstat, lcols, rcols, plotid, ovwt, sgwt, sgweight
	// cumulative, efficacy, influence, interaction
	// counts, group1, group2 (for compatibility with metan.ado)
	// rfdist, rflevel (for compatibility with metan.ado)

	// N.B. some of this may already have been done within -ipdmetan-
	
	cap nois ParseFPlotOpts, cmdname(`cmdname') mainprog(admetan) options(`opts_adm') `forestplot'
	if _rc {
		if `"`err'"'==`""' {
			if _rc==1 nois disp as err `"User break in {bf:admetan.ParseFPlotOpts}"'
			else nois disp as err `"Error in {bf:admetan.ParseFPlotOpts}"'
		}
		c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan}"
		exit _rc
	}
	
	local eform    `s(eform)'
	local log      `s(log)'
	local summstat `s(summstat)'
	local effect     `"`s(effect)'"'
	local opts_adm   `"`s(opts_parsed)' `s(options)'"'		// options as listed above, plus other options supplied directly to admetan
	local opts_fplot `"`s(opts_fplot)'"'					// other options supplied as sub-options to forestplot() 
	
	
	
	**************************
	* Parse `study' and `by' *
	**************************

	** Parse `by'
	// N.B. do this before `study' in case `by' is string and contains missings.
	// Stata sorts string missings to be *first* rather than last.
	if `"`by'"'!=`""' {
		local 0 `"`by'"'
		syntax name [, Missing]		// only a single (var)name is allowed

		cap confirm var `namelist'
		if _rc {
			nois disp as err `"variable {bf:`namelist'} not found"'
			exit 111
		}
		local _BY `namelist'		// `"`_BY'"'!=`""' is a marker of `by' being present in the current data
		if `"`missing'"'==`""' markout `touse' `_BY', strok
	}
	
	** Now, parse `study'
	// label([namevar=namevar], [yearvar=yearvar]) is only for compatibility with metan.ado
	// and is not documented as part of the idpmetan/admetan package
	// [hence e.g. won't work with ad(); and is converted to usual syntax for passing to -forestplot-]
	if `"`label'"'!=`""' {
		if `"`study'"'!=`""' {
			disp as err `"Cannot specify both {bf:label()} and {bf:study()}; please choose just one"'
			exit 198
		}
		
		// while loop taken directly from metan.ado by Ross Harris:
		tokenize "`label'", parse("=,")
		while "`1'"!="" {
			cap assert inlist(`"`1'"', "namevar", "yearvar")
			if _rc local rc = _rc
			else {
				cap confirm var `3'
				if _rc & `: word count `3''==1 {
					disp as err `"Variable {bf:`3'} not found in option {bf:label()}"'
					exit _rc
				}
				local rc = _rc
			}
			if `rc' {
				disp as err `"Syntax of option {bf:label()} is {bf:label(}[{bf:namevar}={it:namevar}]{bf:,} [{bf:yearvar}={it:yearvar}]{bf:)}"'
				exit _rc
			}
			local `1' "`3'"
			mac shift 4
		}
		
		// put name/year variables into appropriate macros
		if `: word count `namevar' `yearvar''==1 local study `namevar' `yearvar'
		else {
			tempvar study
			cap confirm string var `namevar'
			if !_rc local namestr `namevar'
			else {
				tempvar namestr
				cap decode `namevar', gen(`namestr')
				if _rc==182 qui gen `namestr' = string(`namevar')	// no value label
			}
			cap confirm string var `yearvar'
			if !_rc local yearstr `yearvar'
			else {
				tempvar yearstr
				cap decode `yearvar', gen(`yearstr')
				if _rc==182 qui gen `yearstr' = string(`yearvar')	// no value label
			}

			qui gen `study' = `namestr' + " (" + `yearstr' + ")"
			label variable `study' `"`: variable label `namevar'' (`: variable label `yearvar'')"'
			if "`namestr'"!="" & "`namestr'"!="`namevar'" {
				qui drop `namestr'		// tidy up
			}
			if "`yearstr'"!="" & "`yearstr'"!="`yearvar'" {
				qui drop `yearstr'		// tidy up
			}
		}
		local _STUDY `study'

	}	// end if `"`label'"'!=`""'

	// Amended May 2018 and again October 2018
	// If `study' not supplied:
	// First, look at `lcols' as per -metan- syntax proposed in Harris et al, SJ 2008
	local sfmtlen = 0						// initialise [added 12th June 2018]
	if `"`study'"'==`""' {
		local 0 `", `opts_adm'"'
		syntax [, LCols(namelist) * ]
		gettoken _STUDY lcols : lcols		// remove _STUDY from lcols

		if `"`_STUDY'"'!=`""' {
			cap confirm var `_STUDY'
			if _rc {
				disp as err `"option {bf:study()} not supplied, and variable {bf:`_STUDY'} (in option {bf:lcols()} not found"'
				exit _rc
			}
			markout `touse' `_STUDY', strok
			local slcol slcol				// [16th May 2018] mark as being actually lcols() rather than study(); used in ProcessLabels for error message
		}
	
		// Else, start by assuming entire dataset is to be used
		//  and remove any observations with no (i.e. missing) data in `invlist'.
		// (code fragment taken from _grownonmiss.ado)
		else {
			tokenize `invlist'
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
			
			local sfmtlen = 5					// set format to %-5s to be able to display the word "Study"
		}

		if `"`lcols'"'!=`""' {
			local opts_adm `"`macval(options)' lcols(`lcols')"'		// put `opts_adm' back together again
		}
	}
	
	// If study is supplied directly
	else {
		local 0 `"`study'"'
		syntax varname [, Missing]			// only a single (var)name is allowed,
		local _STUDY `varlist'				// and it must exist in the data currently in memory
		if `"`missing'"'==`""' markout `touse' `_STUDY', strok
	}
	
	// Moved May 2018
	local svarlab "Study"
	if `"`_STUDY'"'!=`""' {
		local studylab : value label `_STUDY'			// if `study' exists, use its value label (N.B. will be empty if string)
		local svarlab : variable label `_STUDY'			// and *original* variable label...
		// local svarlab = cond(`"`svarlab'"'!=`""', `"`svarlab'"', `"`_STUDY'"')
		if `"`svarlab'"'==`""' local svarlab `_STUDY'	// amended Feb 2018 due to local x = "" issue with version <13
														// ...but if r(newstudy) was returned, use new labels in preference
														
		// If study is string, save format length to apply to _LABELS later
		cap confirm numeric var `_STUDY'
		if _rc {
			local f : format `_STUDY'
			tokenize `"`f'"', parse("%s")
			confirm number `2'
			local sfmtlen = `2'
		}
	}

	
	** ProcessLabels subroutine checks for problems with `study' and `by'
	//  and, amongst other things, converts them from string to numeric if necessary
	tempname newstudylab newbylab
	tempvar  newstudy    newby
	cap nois ProcessLabels if `touse', `slcol' ///
		study(`_STUDY') newstudy(`newstudy') newstudylab(`newstudylab') ///
		by(`_BY')       newby(`newby')       newbylab(`newbylab')
	
	if _rc {
		if _rc==1 nois disp as err `"User break in {bf:admetan.ProcessLabels}"'
		else nois disp as err `"Error in {bf:admetan.ProcessLabels}"'
		c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan}"
		exit _rc
	}

	// if r(newstudy) was returned, use it if applicable
	// Amended May 2018
	if `"`_STUDY'"'!=`"`r(newstudy)'"' & `"`r(newstudy)'"'!=`""' {
		local _STUDY `r(newstudy)'
		// local studylab = cond(`"`r(newstudylab)'"'!=`""', `"`r(newstudylab)'"', `"`studylab'"')
		if `"`r(newstudylab)'"'!=`""' local studylab `"`r(newstudylab)'"'	// amended Feb 2018 due to local x = "" issue with version <13
		label values `_STUDY' `studylab'				// apply labels to *new* study var
	}
	if `"`_STUDY'"'!=`""' {
		confirm numeric variable `_STUDY'
	}
	
	// same logic now applies to `by'
	if "`_BY'"!=`""' {
		local bylab : value label `_BY'					// if `by' exists, use its value label (N.B. will be empty if string)
		local byvarlab : variable label `_BY'			// and variable label...
		// local byvarlab = cond(`"`byvarlab'"'!=`""', `"`byvarlab'"', `"`_BY'"')
		if `"`byvarlab'"'==`""' local byvarlab `_BY'	// amended Feb 2018 due to local x = "" issue with version <13
	}													// ...but if r(newby) was returned, use new labels in preference
	if `"`_BY'"'!=`"`r(newby)'"' & `"`r(newby)'"'!=`""' {
		local _BY `r(newby)'
		// local bylab = cond(`"`r(newbylab)'"'!=`""', `"`r(newbylab)'"', `"`bylab'"')
		if `"`r(newbylab)'"'!=`""' local bylab `"`r(newbylab)'"'	// amended Feb 2018 due to local x = "" issue with version <13
		label values `_BY' `bylab'						// apply labels to *new* by var
	}
	if "`_BY'"!=`""' {
		confirm numeric variable `_BY'
	}

	// `_STUDY' and `_BY' are the "working" variables from now on; guaranteed numeric.
	//  `study' and  `by' retain the original contents of those options.
	
	// Dec 2018: Check that `_STUDY' and `_BY' are not identical
	if `"`_STUDY'"'!=`""' {
		cap assert `"`_STUDY'"'!=`"`_BY'"'
		if _rc {
			disp as err `"the same variable cannot be used in both {bf:study()} and {bf:by()}"'
			exit 198
		}
	}
	
	
	
	*************************************************
	* Identify summary statistic and pooling method *
	*************************************************	

	// Unless called by -ipdmetan- (see above), need to generate `_USE'
	if `"`_USE'"'==`""' {
		tempvar _USE							// Note that `_USE' is defined if-and-only-if `touse'
		qui gen byte `_USE' = 1 if `touse'		// i.e.  !missing(`_USE') <==> `touse'
	}
	
	// Process `invlist' to identify `method' (of constructing _ES and _seES) and finalise `summstat'
	// (and also detect observations with insufficient data; _USE==2)
	cap nois ProcessInputVarlist `_USE' `invlist' if `touse', ///
		summstat(`summstat') `eform' `log' `opts_adm'

	if _rc {
		if _rc==2000 nois disp as err "No studies found with sufficient data to be analysed"
		else if _rc==1 nois disp as err `"User break in {bf:admetan.ProcessInputVarlist}"'
		else nois disp as err `"Error in {bf:admetan.ProcessInputVarlist}"'
		c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan}"
		exit _rc
	}

	// corrected options list; now also contains `eform' `logrank'
	// plus the following, which will be placed into opts_model by ParseModel:
	//  `breslow' `chi2opt' `randomi' `fixedi' `fixed'
	local opts_adm `"`s(options)'"'
	
	if `"`effect'"'==`""' local effect `"`s(effect)'"'	// don't override user-specified value
	local summstat    `s(summstat)'
	local method      `s(method)'
	local mh          `s(mh)'		// if `mh' was explicitly user-specified (rather than a default imposed by -admetan-; for later error-checking)
	local eform = cond(`"`s(eform)'"'!=`""', `"`s(eform)'"', `"`eform'"')
	local log         `s(log)'
	local citype      `s(citype)'
	if inlist(`"`citype'"', `""', `"z"') local citype normal
	local ccopt `"`s(ccopt)'"'		// if a continuity correction is to be applied (i.e. needs tempvar)

	return local citype `citype'						// citype is now established
	if "`summstat'"!="" {								// summstat is now established (can be missing)
		local usummstat = upper("`summstat'")
		return local measure `"`log'`usummstat'"'
	}	

	
	** Parse meta-analysis modelling options
	// (random-effects, test & het stats, etc.)
	cap nois ParseModel, `opts_adm'
	if _rc {
		if `"`err'"'==`""' {
			if _rc==1 nois disp as err `"User break in {bf:admetan.ParseModel}"'
			else nois disp as err `"Error in {bf:admetan.ParseModel}"'
		}
		c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan}"
		exit _rc
	}	
	
	local model        `s(model)'
	local opts_model `"`s(opts_model)'"'	// options to pass to PerformMetaAnalysis
	local opts_adm   `"`s(options)'"'		// all other options (rationalised)
	
	
	// Finalise method of *pooling* (M-H; fixed IV; random IV)
	//  (N.B. those are the only three possibilities, since Peto, logrank, SMD/WMD are all IV.)
	// If M-H method and `model' *not* set, set `model' to M-H; otherwise, default to I-V fixed-effects.
	if "`model'"=="" local model = cond("`method'"=="mh", "mh", "fe")	
	else {
		
		// M-H not compatible with random effects
		if "`mh'"!="" {
			nois disp as err "Cannot specify both Mantel-Haenszel and random-effects"
			exit 198
		}
		
		// sensitivity analysis
		if "`model'"=="sa" & "`by'"!="" {
			nois disp as err `"Sensitivity analysis cannot be used with {bf:by()}"'
			exit 198
		}
	}
	
	// `method' and `model' are now established
	return local method `method'
	if `"`s(model2)'"'!=`""' return local model `"`model', `s(model2)'"'
	else return local model `model'
	

	
	****************************************************
	* Prepare for, and run, the meta-analysis model(s) *
	****************************************************

	// Extract options relevant to PerformMetaAnalysis
	local 0 `", `opts_adm'"'
	syntax [, CUmulative INFluence RFDist RFLEVEL(passthru) SORTBY(varname) ///
		noOVerall noSUbgroup SUMMARYONLY INTERaction OVWt SGWt ALTWt WGT(varname numeric) ///
		LOGRank NPTS(string) noINTeger KEEPOrder KEEPAll noTABle noGRaph noHET SAVING(passthru) * ]

	local opts_adm `"`macval(options)'"'	// remaining options
											// [note that npts(string) is NOT now part of `opts_adm'; it stands alone]
		
	** Other option validity checks

	// Added Jan 2019 for v3.2
	// prediction intervals can only be used with "vanilla" random-effects models
	// (i.e. those which simply estimate tau-squared and use it in the standard way)
	if "`rfdist'"!="" {
		cap assert !inlist("`model'", "mh", "fe", "kr", "gamma", "hc", "ivhet", "qe", "mu", "pl")
		if _rc {
			nois disp as err `"Note: prediction interval cannot be estimated under the specified model; {bf:rfdist} will be ignored"'
			local rfdist
		}
	}
	
	// User-defined weights
	if `"`wgt'"'!=`""' {
	
		// inverse-variance only...
		cap assert "`method'"=="iv"
		if _rc {
			nois disp as err "User-defined weights can only be used with inverse-variance method"
			exit _rc
		}
		
		// March 2018: removed similar restriction for random-effects
		// Oct 2018: ... but only "vanilla" random-effects models are compatible
		// (i.e. those which simply estimate tau-squared and use it in the standard way)
		cap assert !inlist("`model'", "kr", "gamma", "hc", "ivhet", "qe", "mu", "pl")
		if _rc {
			nois disp as err "User-defined weights can only be used with either the standard random-effects model"
			nois disp as err "  or the Hartung-Knapp-Sidik-Jonkman variance correction"
			exit _rc
		}		
	}	
	
	// cumulative and influence
	// if `by', cumulative *must* be done by subgroup and not overall ==> nooverall is "compulsory"
	if `"`cumulative'"'!=`""' & `"`influence'"'!=`""' {
		disp as err `"Cannot specify both {bf:cumulative} and {bf:influence}; please choose just one"'
		exit 198
	}
	if `"`cumulative'"'!=`""' {
		if `"`subgroup'"'!=`""' {
			disp as err `"Note: {bf:nosubgroup} is not compatible with {bf:cumulative} and will be ignored"'
			local subgroup
		}
		if `"`summaryonly'"'!=`""' {
			disp as err `"Options {bf:cumulative} and {bf:summaryonly} are not compatible"'
			exit 198
		}
		
		// 22nd March 2018: remove references to `notable'
		if `"`by'"'==`""' {
			if `"`overall'"'!=`""' {
				// disp as err `"Note: {bf:nooverall} is not compatible with {bf:cumulative}, but will be re-interpreted as {bf:notable}"'
				disp as err `"Note: {bf:nooverall} is not compatible with {bf:cumulative} (unless with {bf:by()}) and will be ignored"'
				local overall
				// local table "notable"
			}
		}
		else {
			if `"`overall'"'!=`""' {
				// disp as err `"Note: {bf:nooverall} is compulsory with {bf:cumulative} and {bf:by()}; will be re-interpreted as {bf:notable}"'
				disp as err `"Note: {bf:nooverall} is compulsory with {bf:cumulative} and {bf:by()}"'
				// local table "notable"
			}
		}
	}
	else if `"`influence'"'!=`""' & `"`summaryonly'"'!=`""' {
		disp as err `"Note: {bf:influence} is not compatible with {bf:summaryonly} and will be ignored"'
		local influence
	}
	
	// Compatibility tests for ovwt, sgwt, altwt
	if `"`by'"'==`""' {
		if `"`subgroup'"'!=`""' {
			nois disp as err `"Note: {bf:nosubgroup} cannot be specified without {bf:by()} `orbyad'and will be ignored"' 
			local subgroup
		}
	
		if `"`sgwt'"'!=`""' {
			disp as err `"Note: {bf:sgwt} is not applicable without {bf:by()} `orbyad'and will be ignored"'
			local sgwt
		}
		local ovwt ovwt
	}
	else {
		if `"`cumulative'"'!=`""' {
			if `"`ovwt'"'!=`""' disp as err `"Note: {bf:ovwt} is not compatible with {bf:cumulative} and {bf:by()}, and will be ignored"'
			local ovwt
			local sgwt sgwt
		}

		// Added 22nd March 2018
		if `"`influence'"'!=`""' & `"`overall'"'==`""' & `"`sgwt'"'==`""' {
			disp as err `"Note: {bf:influence} with {bf:by()} implies {bf:nosubgroup}, unless option {bf:sgwt} also supplied"'
			local subgroup nosubgroup
		}
	}

	/*	// Removed 22nd March 2018
	if `"`cumulative'`influence'"'!=`""' {
		if `"`ovwt'"'!=`""' disp as err `"Note: {bf:ovwt} is not compatible with {bf:`cumulative'`influence'} and {bf:by()}, and will be ignored"'
		local ovwt
		local sgwt "sgwt"
	}
	*/	
	
	if `"`ovwt'"'!=`""' & `"`sgwt'"'!=`""' {
		disp as err `"Cannot specify both {bf:ovwt} and {bf:sgwt}; please choose just one"'
		exit 198
	}
	if `"`altwt'"'!=`""' & `"`cumulative'`influence'"'==`""' {
		disp as err `"Note: {bf:altwt} is not applicable without {bf:cumulative} or {bf:influence}, and will be ignored"'
		local altwt
	}	

	// set ovwt/sgwt defaults
	if `"`ovwt'`sgwt'"'==`""' {
		if `"`by'"'!=`""' & `"`overall'"'!=`""' & `"`subgroup'"'==`""' local sgwt sgwt
		else local ovwt ovwt
	}
		

	
	** Initialise rownames of matrices to hold overall/subgroup pooling results
	// (c.f. r(table) after regression)
	InitRownames, method(`method') model(`model') `logrank' `rfdist' `opts_model'
	local rownames `s(rownames)'
	
	
	** Setup tempvars
	// The "core" elements of `outvlist' are _ES, _seES, _LCI, _UCI, _WT and _NN
	// By default, these will be left behind in the dataset upon completion of -admetan-
	// `tvlist' = list of elements of `outvlist' that need to be generated as *tempvars* (i.e. do not already exist)
	//  (whilst ensuring that any overlapping elements in `invlist' and `outvlist' point to the same actual variables)
	tokenize `invlist'
	local params : word count `invlist'
	
	// Process "npts(varname)": only permitted with 2- or 3-element varlist AD;
	// that is, "ES, seES", "ES, LCI, UCI", or "OE, V"
	if `"`npts'"'!=`""' {
		if `params' > 3 {
			nois disp as err `"{bf:npts(}{it:varname}{bf:)} syntax only valid with generic inverse-variance model or with logrank (O-E & V) HR"'
			exit 198
		}
		
		local old_integer `integer'
		local 0 `"`npts'"'
		syntax varname(numeric) [, noPlot noINTeger]
		local _NN `varlist'													// the varname which was stored in npts(varname) will now be stored in _NN
		if `"`integer'"'==`""' local integer `old_integer'
		
		if `"`integer'"'==`""' {
			cap assert int(`_NN')==`_NN' if `touse'
			if _rc {
				nois disp as err `"Non-integer counts found in {bf:npts()} option"'
				exit _rc
			}
		}
		if `"`plot'"'==`""' local opts_adm `"`macval(opts_adm)' npts"'		// send simple on/off option to BuildResultsSet (e.g. for forestplot)
	}
	
	if `params'==2 & "`logrank'"=="" {
		args _ES _seES						// `_ES' and `_seES' supplied
		local tvlist _LCI _UCI				// `_LCI', `_UCI' need to be created (at 95%)
	}
	else if `params'==3 {
		args _ES _LCI _UCI					// `_ES', `_LCI' and `_UCI' supplied (assumed 95% CI)
		
		local tvlist _seES						// `_seES' needs to be created
		if `"`level'"'!=`""' {					// but if level() option supplied, requesting coverage othr than 95%
			local tvlist `tvlist' _LCI _UCI		// then tempvars for _LCI, _UCI are needed too
		}
	}
	else {
		local tvlist _ES _seES _LCI _UCI						// need to create everything
		if `"`logrank'"'==`""' local tvlist `tvlist' _NN		// including _NN unless `logrank' (as that uses optional `npts')
	}
	
	// Finally, _WT always needs to be generated as tempvar
	local tvlist `tvlist' _WT
	
	// Create tempvars based on `tvlist'
	//   and finally create `outvlist' = list of "standard" vars (_ES, _seES, _LCI, _UCI, _WT, _NN; see above).
	foreach tv of local tvlist {
		tempvar `tv'
		qui gen double ``tv'' = .
	}
	local outvlist `_ES' `_seES' `_LCI' `_UCI' `_WT' `_NN'
	

	// If cumulative or influence, need to generate additional tempvars.
	// `xoutvlist' ("extra" outvlist) contains results of each individual analysis
	//   to be printed to screen, displayed in forestplot and stored in saved dataset.
	//   (plus Q, tausq, sigmasq, df from each analysis.)
	// Meanwhile `outvlist' contains effect sizes etc. for each individual *study*, as usual,
	//   which will be left behind in the current dataset.
	if `"`cumulative'`influence'"'!=`""' {
		tempvar use3
		qui gen byte `use3' = 0		// identifier of last estimate, for placement of dotted line in forestplot
		local use3opt `"use3(`use3')"'
		
		local nt = `: word count `rownames''
		forvalues i = 1 / `nt' {
			tempvar tv`i'
			qui gen double `tv`i'' = .
			local xoutvlist `xoutvlist' `tv`i''
		}
	}
	// N.B. `xoutvlist' now contains the tempvars which will hold the relevant returned stats...
	//  - with the same contents as the elements of `rownames'
	//  - but *without* npts (as _NN is handled separately)
	//  - and with the addition of a separate weight variable (`_WT2') ... so the total is `nt' - 1 + 1 = `nt'.	
	
	
	// Jan 2019: If continuity correction, generate an additional tempvar denoting whether a correction was applied
	if `"`ccopt'"'!=`""' {
		tempvar ccvar
		local ccopt `"`ccopt' ccvar(`ccvar')"'
	}
	
	
	** Run the actual meta-analysis modelling
	
	// Generate stable ordering to pass to subroutines... (PerformMetaAnalysis, DrawTableAD, BuildResultsSet)
	// (so sortby() is always specified for these subroutines)
	tempvar obs
	qui gen long `obs' = _n

	cap nois PerformMetaAnalysis `_USE' `invlist' if `touse', sortby(`sortby' `obs') by(`_BY') ///
		method(`method') model(`model') summstat(`summstat') citype(`citype') ///
		outvlist(`outvlist') xoutvlist(`xoutvlist') rownames(`rownames') ///
		`cumulative' `influence' `overall' `subgroup' `rfdist' `rflevel' ///
		`ovwt' `sgwt' `altwt' wgt(`wgt') `use3opt' `ccopt' ///
		`logrank' `level' `opts_model'
	
	if _rc {
		if `"`err'"'==`""' {
			if _rc==1 nois disp as err `"User break in {bf:admetan.PerformMetaAnalysis}"'
			else nois disp as err `"Error in {bf:admetan.PerformMetaAnalysis}"'
		}
		c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan}"
		exit _rc
	}

	if !missing(`"`r(bystats)'"') {
		tempname bystats
		mat `bystats' = r(bystats)
		return matrix bystats = `bystats', copy
	}
	if !missing(`"`r(ovstats)'"') {
		tempname ovstats
		mat `ovstats' = r(ovstats)
		return matrix ovstats = `ovstats', copy
	}
	
	// If neither matrix exists, there has been no pooling
	if `"`ovstats'`bystats'"'==`""' local het nohet
	
	// Collect numbers of studies and patients
	tempname k totnpts
	scalar `k' = r(k)
	scalar `totnpts' = r(n)
	return scalar k = r(k)
	return scalar n = r(n)

	// Subgroup statistics
	if `"`by'"'!=`""' & `"`subgroup'`overall'"'==`""' {
		tempname Q_ov Qdf_ov Qsum Qdiff Fstat nby
		scalar `Q_ov'   = `ovstats'[rownumb(`ovstats', "Q"), 1]
		scalar `Qdf_ov' = `ovstats'[rownumb(`ovstats', "Qdf"), 1]
		scalar `Qsum'  = r(Qsum)
		scalar `Qdiff' = `Q_ov' - `Qsum'			// between-subgroup heterogeneity (Qsum = within-subgroup het.)
		scalar `nby' = colsof(`bystats')
		scalar `Fstat' = (`Qdiff'/(`nby' - 1)) / (`Qsum'/(`Qdf_ov' - `nby' + 1))		// corrected 17th March 2017
		
		return scalar Qdiff = `Qdiff'
		return scalar Qsum  = `Qsum'
		return scalar F = `Fstat'
		return scalar nby = `nby'
	}

	// Return other scalars
	//  some of which are also saved in r(ovstats)
	return scalar eff    = r(eff)
	return scalar se_eff = r(se_eff)
	return scalar Q    = r(Q)
	return scalar Isq  = r(Isq)
	return scalar HsqM = r(HsqM)
	
	if `params'==4 {
		return scalar tger = r(tger)
		return scalar cger = r(cger)
		if !missing(r(RR)) return scalar RR = r(RR)
		if !missing(r(OR)) return scalar OR = r(OR)
	}
	
	if `"`ovstats'"'!=`""' {
		if !missing(rownumb(`ovstats', "tausq")) {
			return scalar Qr = r(Qr)
			return scalar tausq   = r(tausq)
			return scalar sigmasq = r(sigmasq)
		}
		
		if !missing(rownumb(`ovstats', "tausq_lci")) {
			return scalar tsq_var    = r(tsq_var)
			return scalar rc_eff_lci = r(rc_eff_lci)
			return scalar rc_eff_uci = r(rc_eff_uci)
			return scalar rc_tausq   = r(rc_tausq)
			return scalar rc_tsq_lci = r(rc_tsq_lci)
			return scalar rc_tsq_uci = r(rc_tsq_uci)
		}
	}
	
	/*
	// return scalars for AD & IPD separately if "byad"
	if `"`byad'"'!=`""' {
		forvalues i=1/2 {
			local K`i'       = `bystats'[`i', `=colnumb(`bystats', "k")'] 
			local totnpts`i' = `bystats'[`i', `=colnumb(`bystats', "_NN")']
		}
		foreach x in K1 K2 totnpts1 totnpts2 eff1 eff2 se_eff1 se_eff2 {
			if `"``x''"'==`""' local `x'=.
		}

		if `"`overall'"'!=`""' {
			return scalar k1=`K1'
			return scalar k2=`K2'
			return scalar n1=`totnpts1'
			return scalar n2=`totnpts2'
			return scalar eff1=`eff1'
			return scalar eff2=`eff2'
			return scalar se_eff1=`se_eff1'
			return scalar se_eff2=`se_eff2'
		}
	}
	*/
	// Oct 2018:  These scalars are now returned within r(bystats) instead
	
	
	// 27th Sep 2018:
	// Now switch functions of `outvlist' and `xoutvlist',
	//  so that the cumul/infl versions of _ES, _seES etc. are stored in `outvlist' (so overwriting the "standard" _ES, _seES etc.)
	//  for display onscreen, in forest plot and in saved dataset.
	// Then `xoutvlist' just contains the remaining "extra" tempvars _Q, _Qdf, _tausq etc.
	if `"`xoutvlist'"'!=`""' {
	
		// Firstly, tidy up: If nokeepvars *and* altwt not specified, then we can drop
		//   any members of `outvlist' that didn't already exist in the dataset
		if `"`keepvars'"'!=`""' & `"`altwt'"'==`""' {
			foreach v of local outvlist {
				if `: list v in tvlist' {		// i.e. if `v' was created by either -ipdmetan- or -admetan-
					drop ``v''
				}
			}
		}

		// Now reset `outvlist'
		local npts npts
		local rownames : list rownames - npts
		tokenize `xoutvlist'
		args `rownames' _WT2
		
		local outvlist `eff' `se_eff' `eff_lci' `eff_uci' `_WT2' `_NN'
		local xoutvlist : list xoutvlist - outvlist
		
		tokenize `outvlist'
		args _ES _seES _LCI _UCI _WT _NN
	}

	
	
	
	********************************
	* Print summary info to screen *
	********************************

	* Print number of studies/participants to screen
	//  (NB nos. actually analysed as opposed to the number supplied in original data)

	// If passed from -ipdmetan- with option ad(), need to print non-standard text:
	if `"`source'"'!=`""' {
		tempname KIPD totnptsIPD
		qui count if `touse' & inlist(`_USE', 1, 2) & `source'==1
		scalar `KIPD' = r(N)
		if r(N) {
			if "`_NN'"!="" {
				summ `_NN' if `touse' & inlist(`_USE', 1, 2) & `source'==1, meanonly
				scalar `totnptsIPD' = cond(r(N), r(sum), .)			// if KIPD>0 but no _NN, set to missing
			}
			else scalar `totnptsIPD' = .
		}
		else scalar `totnptsIPD' = 0

		tempname KAD totnptsAD
		qui count if `touse' & inlist(`_USE', 1, 2) & `source'==2
		scalar `KAD' = r(N)
		if r(N) {
			if "`_NN'"!="" {
				summ `_NN' if `touse' & inlist(`_USE', 1, 2) & `source'==2, meanonly
				scalar `totnptsAD' = cond(r(N), r(sum), .)			// if KAD>0 but no _NN, set to missing
			}
			else scalar `totnptsAD' = .
		}
		else scalar `totnptsAD' = 0

		disp as text _n "Studies included from IPD: " as res `KIPD'
		if "`keepall'"!="" {
			qui count if `touse' & `_USE'==2 & `source'==1
			assert r(N) <= `KIPD'
			if r(N) {
				local plural = cond(r(N)==1, "study", "studies")
				disp as text "  plus " as res `r(N)' as text " `plural' with insufficient data"
			}
		}		
		local dispnpts = cond(missing(`totnptsIPD'), "Unknown", string(`totnptsIPD'))
		disp as text "Participants included from IPD: " as res "`dispnpts'"
		if "`keepall'"!="" & !missing(`totnptsIPD') {
			summ `_NN' if `touse' & `_USE'==2 & `source'==1, meanonly
			assert r(sum) <= `totnptsIPD'
			if r(sum) {
				local s = cond(r(sum)>1, "s", "")
				disp as text "  plus " as res `r(sum)' as text " participant`s' with insufficient data"
			}
		}
		
		disp as text _n "Studies included from aggregate data: " as res `KAD'
		if "`keepall'"!="" {
			qui count if `touse' & `_USE'==2 & `source'==2
			assert r(N) <= `KAD'
			if r(N) {
				local plural = cond(r(N)==1, "study", "studies")
				disp as text "  plus " as res `r(N)' as text " `plural' with insufficient data"
			}
		}
		local dispnpts = cond(missing(`totnptsAD'), "Unknown", string(`totnptsAD'))
		disp as text "Participants included from aggregate data: " as res "`dispnpts'"
		if "`keepall'"!="" & !missing(`totnptsAD') {
			summ `_NN' if `touse' & `_USE'==2 & `source'==2, meanonly
			assert r(sum) <= `totnptsAD'
			if r(sum) {
				local s = cond(r(sum)>1, "s", "")
				disp as text "  plus " as res `r(sum)' as text " participant`s' with insufficient data"
			}
		}
	}		// end if `"`source'"'
		
	// Standard -admetan- summary text:
	else {
		disp _n _c
		disp as text "Studies included: " as res `k'
		if "`keepall'"!="" {
			qui count if `touse' & `_USE'==2
			if r(N) {
				local plural = cond(r(N)==1, "study", "studies")
				disp as text "  plus " as res `r(N)' as text " `plural' with insufficient data"
			}
		}
		local dispnpts = cond(missing(`totnpts'), "Unknown", string(`totnpts'))
		disp as text "Participants included: " as res "`dispnpts'"
		if "`keepall'"!="" & !missing(`totnpts') {
			summ `_NN' if `touse' & `_USE'==2, meanonly
			if r(sum) {
				local s = cond(r(sum)>1, "s", "")
				disp as text "  plus " as res `r(sum)' as text " participant`s' with insufficient data"
			}
		}
	}	
	
	
	** Full descriptions of `summstat', `method' and `model' options, for printing to screen	
	// Involves `opts_model', so pass to a subroutine
	PrintDesc, summstat(`summstat') method(`method') model(`model') ///
		bystats(`bystats') ovstats(`ovstats') wgt(`wgt') `ccopt' ///
		`log' `logrank' `cumulative' `influence' `summaryonly' `table' `opts_model' `opts_ipdm'
	
	local fpnote     `"`s(fpnote)'"'
	local opts_table `"`s(opts_table)'"'	// for DrawTableAD (contains: `breslow' `chi2opt' `t' `qprofile')
	local tsqlevel   `"`s(tsqlevel)'"'		// `tsqlevel' is needed for BuildResultsSet, so returned separately
	local opts_ipdm  `"`s(opts_ipdm)'"'		// now contains: `byad' `source' `lrvlist' `ipdxline'
	


	*********************************
	* Print results table to screen *
	*********************************
		
	// Unless no table AND no graph AND no saving, store study value labels in new var "_LABELS"
	if !(`"`table'"'!=`""' & `"`graph'"'!=`""' & `"`saving'"'==`""') {

		tempvar _LABELS
		cap decode `_STUDY' if `touse', gen(`_LABELS')					// if value label
		if _rc qui gen `_LABELS' = string(`_STUDY') if `touse'			// if no value label

		// missing values of `_STUDY'
		// string() works with ".a" etc. but not "." -- contrary to documentation??
		qui replace `_LABELS' = "." if `touse' & missing(`_LABELS') & !missing(`_STUDY')
	}
	
	// Now remove studies with insufficient data if appropriate
	if `"`keeporder'"'!=`""' local keepall keepall					// `keeporder' implies `keepall'
	if `"`keepall'"'==`""' qui replace `touse' = 0 if `_USE'==2

	// Titles
	if `"`_BY'"'!=`""' local bytitle `"`byvarlab' and "'
	if `"`summaryonly'"'!=`""' local svarlab
	local stitle `"`bytitle'`svarlab'"'
	if `"`influence'"'!=`""' local stitle `"`stitle' omitted"'

	// Moved Sep 2018
	if `"`effect'"'==`""'      local effect "Effect"
	if `"`log'"'!=`""'         local effect `"log `effect'"'
	if `"`interaction'"'!=`""' local effect `"Interact. `effect'"'	

	cap nois DrawTableAD `_USE' `outvlist' if `touse' & inlist(`_USE', 1, 2), ///
		method(`method') model(`model') sortby(`sortby' `obs') ///
		`cumulative' `influence' `overall' `subgroup' `summaryonly' ///
		labels(`_LABELS') stitle(`stitle') etitle(`effect') `ccopt' ///
		study(`_STUDY') by(`_BY') bystats(`bystats') ovstats(`ovstats') ///
		`ovwt' `sgwt' wgt(`wgt') `eform' `table' `het' `keepvars' `keeporder' `level' `opts_table'

	if _rc {
		nois disp as err `"Error in {bf:admetan.DrawTableAD}"'
		c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan}"
		exit _rc
	}		
	
	if `"`r(coeffs)'"'!=`""' {
		tempname coeffs
		mat `coeffs' = r(coeffs)
		return matrix coeffs = `coeffs'
	}
	

	
	********************************
	* Build forestplot results set *
	********************************
	
	* 1. Create the results-set structure
	//  (including some tempvars; hence the subroutine)
	* 2. Send the data to -forestplot- to create the forest plot
	* 3. Save the results-set (in Stata "dta" format)
	//  (after renaming tempvars to permanent names)
	//   and with characteristics set so that "forestplot, useopts" can be called.
	
	// Store contents of existing characteristics
	//  with same names as those to be used by BuildResultsSet
	local char_fpuseopts  `"`char _dta[FPUseOpts]'"'
	local char_fpusevlist `"`char _dta[FPUseVarlist]'"'
	
	if `"`saving'"'!=`""' | `"`graph'"'==`""' {

		`preserve'		// preserve original data (unless passed from ipdmetan already under -preserve-; see earlier)

		if `"`_STUDY'"'!=`""' {
			label variable `_STUDY' `"`svarlab'"'
		}
		if `"`_BY'"'!=`""' {
			label variable `_BY' `"`byvarlab'"'
		}
		
		cap nois BuildResultsSet `_USE' `invlist' if `touse', labels(`_LABELS') ///
			method(`method') model(`model') summstat(`summstat') ///
			sortby(`sortby' `obs') study(`_STUDY') by(`_BY') bystats(`bystats') ovstats(`ovstats') ///
			`cumulative' `influence' `subgroup' `overall' `het' `summaryonly' `rfdist' `rflevel' ///
			`ovwt' `sgwt' `altwt' wgt(`wgt') effect(`effect') `eform' `logrank' `ccopt' ///
			outvlist(`outvlist') xoutvlist(`xoutvlist') use3(`use3') sfmtlen(`sfmtlen') ///
			forestplot(`opts_fplot' `interaction') fpnote(`fpnote') `graph' `saving' ///
			`keepall' `keeporder' `level' `tsqlevel' `opts_adm' `opts_ipdm'
		
		if _rc {
			if `"`err'"'==`""' {
				if _rc==1 nois disp as err `"User break in {bf:admetan.BuildResultsSet}"'
				else nois disp as err `"Error in {bf:admetan.BuildResultsSet}"'
				nois disp as err `"(Note: meta-analysis model was fitted successfully)"'	// added Sep 2018
			}
			c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan}"
			local rc = _rc
			
			// in case *not* under -preserve- (e.g. if _rsample required)
			summ `_USE', meanonly
			if r(N) & r(max) > 9 {
				qui replace `_USE' = `_USE' / 10	// Sep 2018: in case break was while _USE was scaled up -- see latter part of BuildResultsSet
			}
			qui drop if `touse' & !inlist(`_USE', 1, 2)
			
			// clear/restore characteristics
			char _dta[FPUseOpts]    `char_fpuseopts'
			char _dta[FPUseVarlist] `char_fpusevlist'
			exit `rc'
		}
		
		// Restore original data; but preserve it again temporarily while "stored" variables are processed
		//   if all goes well, this -preserve- will be cancelled later with -restore, not- ...
		if `"`preserve'"'!=`""' {
			restore, preserve
		}
			
	}		// end if `"`saving'"'!=`""' | `"`graph'"'==`""'
	
	// ... else, preserve it *now* (temporarily) while "stored" variables are processed
	//   if all goes well, this -preserve- will be cancelled later with -restore, not-
	else {
	
		// trap any invalid options in `opts_adm'
		local 0 `", `opts_adm'"'
		cap nois syntax [, LCols(namelist) RCols(namelist) COUNTS(string asis) EFFIcacy OEV NPTS ///
			noEXTRALine HETStat(string) OVStat(string) noHET noWT noSTATs ///
			KEEPAll KEEPOrder noWARNing PLOTID(passthru) ]

		if _rc {
			if `"`err'"'==`""' {
				nois disp as err `"Error in {bf:admetan}"'
				nois disp as err `"(Note: meta-analysis model was fitted successfully)"'	// added Sep 2018
			}
			c_local err noerr		// tell ipdmetan not to also report an "error in {bf:admetan}"
		}	
			
		`preserve'
	}

	// August 2018: exit early if called from -ipdmetan- under -preserve-
	if `"`preserve'"' == `""' exit
		

	** Stored (left behind) variables
	// Unless -noKEEPVars- (i.e. "`keepvars'"!=""), leave behind _ES, _seES etc. in the original dataset
	// List of these "permanent" names = _ES _seES _LCI _UCI _WT _NN ... plus _CC if applicable
	//   (as opposed to `outvlist', which contains the *temporary* names `_ES', `_seES', etc.)
	//   (N.B. this code applies whether or not cumulative/influence options are present)	
	if `"`keepvars'"'==`""' {

		local tostore _ES _seES _LCI _UCI _WT _NN _CC	// _CC added Jan 2019 for v3.2
		
		foreach v of local tostore {
			if `"``v''"'!=`""' {
				if `"``v''"'!=`"`v'"' {		// If pre-existing var has the same name (i.e. was named _ES etc.), nothing needs to be done.
					cap drop `v'			// Else, first drop any existing var named _ES (e.g. left over from previous analysis)
				
					// If in `tvlist', we can directly rename
					if `: list v in tvlist' {
						qui rename ``v'' `v'
					}
					
					// Otherwise, ``v'' is a pre-existing var which needs to be retained at program termination
					// so, use -clonevar-
					else qui clonevar `v' = ``v'' if `touse'
				}
				local `v' `v'				// for use with subsequent code (local _ES now contains "_ES", etc.)
			}
		}
		qui compress `tvlist'
		order `_ES' `_seES' `_LCI' `_UCI' `_WT' `_NN' `_CC' `_rsample', last
		
		// September 2018: variable labels
		if inlist("`summstat'", "or", "rr", "hr") {
			label variable `_ES' "Effect size (interval scale)"
		}
		else label variable `_ES' "Effect size"
		label variable `_seES' "Standard error of effect size"
		label variable `_WT' "% Weight"
		format `_WT' %6.2f
		if `"`_NN'"'!=`""' {
			label variable `_NN' "No. pts"
		}
		if `"`_CC'"'!=`""' {
			label variable `_CC' "Continuity correction applied?"
		}
		if `"`_rsample'"'==`""' {
			cap drop _rsample
			qui gen byte _rsample = `_USE'==1		// this shows which observations were used
			label variable _rsample "Sample included in most recent model"
		}
		
		// Obtain `level' for labelling LCI/UCI
		local 0 `", `level'"'
		syntax [, LEVEL(real 95)]
		label variable `_LCI' "`level'% lower confidence limit"
		label variable `_UCI' "`level'% upper confidence limit"
		char define `_LCI'[Level] `level'
		char define `_UCI'[Level] `level'
	}	
	
	// else (if -noKEEPVars- specified), check for existence of pre-existing vars named _ES, _seES etc. and give warning if found
	else {
	
		// added Jan 2019 for v3.2
		cap confirm numeric var `ccvar'
		if !_rc {
			local _CC _CC
			local ortext `", {bf:_NN} or {bf:_CC})"'
		}
		else local ortext `" or {bf:_NN}"'
		
		// If -noKEEPVars- but not -noRSample-, need to create _rsample as above
		if "`rsample'"=="" {

			// create _rsample
			cap drop _rsample
			qui gen byte _rsample = `_USE'==1		// this shows which observations were used
			label variable _rsample "Sample included in most recent model"
			
			local warnlist
			local rc = 111
			foreach v in _ES _seES _LCI _UCI _WT _NN `_CC' {
				cap confirm var `v'
				if !_rc local warnlist `"`warnlist' {bf:`v'}"'
				local rc = min(`rc', _rc)
			}
			if !`rc' {
				disp as err _n `"Warning: option {bf:nokeepvars} specified, but the following "stored" variables already exist:"'
				disp as err `"`warnlist'"'
				disp as err `"Note that these variables are therefore no longer associated with the most recent analysis"'
				disp as err `"(although {bf:_rsample} {ul:is})."'
			}
		}
				
		// -noKEEPVars- *and* -noRSample-
		else {

			// give warning if variable named _rsample already existed
			cap confirm var _rsample
			if !_rc {
				disp as err _n `"Warning: option {bf:norsample} specified, but "stored" variable {bf:_rsample} already exists"'
			}
			// 16th October 2017 for v2.2: take rsrc outside of the !_rc brackets
			local rsrc = _rc

			local warnlist
			local rc = 111
			foreach v in _ES _seES _LCI _UCI _WT _NN _CC {
				cap confirm var `v'
				if !_rc & !`: list v in stored' {
					local warnlist `"`warnlist' {bf:`v'}"'
					local rc = 0
				}
			}
			if !`rc' {
				if !`rsrc' disp as err `"as do the following "stored" variables:"'
				else disp as err _n `"Warning: option {bf:norsample} specified, but the following "stored" variables already exist:"'
				disp as err `"`warnlist'"'			
			}
			local plural = cond(!`rc', "these variables are", "this variable is")
			if !`rsrc' | !`rc' disp as err `"Note that `plural' therefore NOT associated with the most recent analysis."'
		}
	}		
		
	// Clear/restore characteristics
	char _dta[FPUseOpts]    `char_fpuseopts'
	char _dta[FPUseVarlist] `char_fpusevlist'
	
	// Finally, cancel -preserve-
	restore, not
	
end







********************************************************************************

**********************************************
* Stata subroutines called from main routine *  (and its "minor" subroutines)
**********************************************


* Program to process `study' and `by' labels
// (based on ProcessAD.ado but altered quite a bit)
// (called directly by admetan.ado)

program define ProcessLabels, rclass sortpreserve

	syntax [if] [in], NEWSTUDY(name) NEWSTUDYLAB(name) NEWBY(name) NEWBYLAB(name) ///
		[ STUDY(name) BY(name) SLCOL ]
			 
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
			if `"`slcol'"'!=`""' {
				local errtext `"in first {bf:lcols()} variable"'
			}
			else local errtext `"in {bf:study()} variable"'
			if `"`by'"'!=`""' local errtext `"`errtext' or "'
		}
		if `"`by'"'!=`""' local errtext `"`errtext'in {bf:by()} variable"'
		nois disp as err `"no valid observations `errtext'"'
		exit 2000
	}	
	local ns = r(N)
	
	tempvar obs
	qui gen long `obs' = _n

	
	** Subgroup (`by') labelling (if applicable)
	// N.B. do this first, in case `by' is string and contains missings. Stata sorts string missings to be *first* rather than last.
	if `"`by'"'!=`""' {
		cap confirm numeric variable `by'
		if _rc {
			qui encode `by' if `touse', gen(`newby') label(`newbylab')
			return local newby `newby'
			return local newbylab `newbylab'
			local by `newby'
		}
	}
	
	
	** Study label
	cap confirm numeric var `study'
	if _rc {
		qui gen long `newstudy' = .
		qui bysort `touse' (`by' `obs') : replace `newstudy' = _n if `touse'
		sort `newstudy'				// studies of interest should now be the first `ns' observations
		return local newstudy `newstudy'

		// Now generate new label
		forvalues i=1/`ns' {
		
			// if `study' not present, create "dummy" label consisting of `si_new' values
			if `"`study'"'==`""' {
				label define `newstudylab' `i' `"`i'"', add
			}
			
			// else if `study' is string, put `study' strings into `newstudylab' values
			else {
				qui replace `obs' = _n
				summ `obs' if `touse', meanonly
				local offset = r(min)			
				local si = `study'[`=`i' + `offset' - 1']
				label define `newstudylab' `i' `"`si'"', add
			}
		}
		return local newstudylab `newstudylab'
	}
	
end




***************************************************

** Routine to parse main options and forestplot options together, and:
//  a. Parse some general options, such as -eform- options and counts()
//  b. Check for conflicts between main options and forestplot() suboptions.
// (called directly by admetan.ado)

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
		HETStat(passthru) PLOTID(passthru) LCols(passthru) RCols(passthru) ///
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
	local optlist3 lcols rcols /*switch*/											// options which cannot conflict
	
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
			HETStat(passthru) PLOTID(passthru) LCols(passthru) RCols(passthru) /*SWitch(passthru)*/ ///
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
// This program is used by -ipdmetan-, -admetan- and -forestplot-
// Not all aspects are relevant to all programs,
//   but easier to maintain just a single subroutine!

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




*********************************************************************

* Program to parse inputted varlist structure and
// - identify studies with insufficient data (`_USE'==2)
// - check for validity
// (called directly by admetan.ado)

/*
Syntax:
a) binary data (4 vars):
		admetan #events_research #nonevents_research #events_control #nonevents_control , ...
b) cts data (6 vars):     
		admetan #N_research mean_research sd_research  #N_control mean_control sd_control , ...
c) logrank survival (OE & V) (2 vars): 
		admetan theta oe v, [NPTS(varname numeric] ...
d) generic inverse-variance (2 vars): 
		admetan theta se_theta , [NPTS(varname numeric] ...
e) generic inverse-variance with CI instead of SE (3 vars): 
		admetan theta lowerlimit upperlimit , [NPTS(varname numeric] ...
*/

program define ProcessInputVarlist, sclass
	
	syntax varlist(numeric min=2 max=8 default=none) [if] [in], [SUMMSTAT(string) ///
		RANDOMI FIXEDI FIXED FE IV MH PETO COHen GLAss HEDges noSTANdard COCHranq IVQ ///
		CORnfield EXact WOolf CItype(string) ///
		EFORM LOG LOGRank BREslow CHI2 CC(string) noCC2 noINTeger ZTOL(real 1e-6) * ]
	
	local invlist `varlist'
	local opts_adm `"`macval(options)'"'

	// Old -metan- options
	opts_exclusive `"`randomi' `fixedi' `fixed'"' `""' 184
	if `"`randomi'"'!=`""' local iv iv
	if `"`fixedi'"'!=`""'  local iv iv
	if `"`fixed'"'!=`""'   local mh mh
	
	// Parse explicitly-specified `method' options
	if trim(`"`fe'`ivq'`cochranq'"') != `""' local iv iv			// synonyms
	opts_exclusive `"`iv' `mh' `peto' `cohen' `glass' `hedges' `standard'"' `""' 184
	local method `iv'`mh'`peto'`cohen'`glass'`hedges'`standard'
	
	// Return user-specified options which might clash with options yet to be parsed (e.g. random-effects)
	// (N.B. `chi2' is not *added* as an option by -admetan-, so don't need to know whether it was explicitly user-specified)
	sreturn local mh `mh'
	
	// Parse explicitly-specified `citype' options
	// [N.B. cornfield, exact, woolf were main options to -metan- so are also allowed here
	//  however the preferred -admetan- syntax is "citype()" ]
	opts_exclusive `"`cornfield' `exact' `woolf'"' `""' 184
	local cimainopt `cornfield'`exact'`woolf'					// marker as whether supplied as a "main" option (cf -metan-)
	local 0 `", `citype'"'										// now parse preferred "citype()" syntax
	syntax [, CORnfield EXact WOolf * ]
	cap assert `: word count `cimainopt' `cornfield' `exact' `woolf' `options'' <= 1
	if _rc {
		disp as err `"Conflict between options {bf:citype(`citype')} and {bf:`cimainopt'}"'
		exit _rc
	}
	local citype `citype'`cimainopt'

	
	** Now begin parsing `invlist'
	marksample touse
	
	gettoken _USE invlist : invlist
	tokenize `invlist'
	
	cap assert "`7'" == ""
    if _rc {
		nois disp as err "Too many variables specified"
		exit _rc
	}

	if "`6'"=="" {

		// input is generic inverse-variance (2 or 3 vars) or HR logrank (2 vars)
		if "`4'"=="" {
			
			// input is HR logrank (2 vars: OE & V)
			if "`logrank'" != "" {
				assert "`3'"=="" & "`2'"!=""
				
				// Default method is Peto; can also be I-V (Cochran heterogeneity)
				if "`method'"=="mh" {
					nois disp as err "Mantel-Haenszel methods are incompatible with log-rank hazard ratios"
					exit 184
				}
				else if !inlist("`method'", "", "peto", "iv") {
					nois disp as err "Specified method is incompatible with the data"
					exit 184
				}
				
				local summstat hr
				local effect `"Haz. Ratio"'
				if "`method'"=="" local method peto
				local chi2 chi2
			}

			// input is _ES, _seES or _ES, _LCI, _UCI
			// method can only be I-V
			else {
				if !inlist("`method'", "iv", "") {
					nois disp as err `"Specified method is incompatible with the data"'
					exit 184
				}
				if "`method'"=="" local method iv
			}
			
			// switch off incompatible options
			foreach opt in breslow cc {
				cap assert `"``opt''"' == `""'
				if _rc {
					nois disp as err `"Note: Option {bf:`opt'} is not appropriate without 2x2 count data and will be ignored"' 
					local `opt'
				}
			}
			if `"`logrank'"'==`""' {
				cap assert `"`chi2'"' == `""'
				if _rc {
					nois disp as err `"Note: Option {bf:chi2} is not appropriate without 2x2 count data and will be ignored"' 
					local chi2
				}
			}
	
			// citype
			cap assert !inlist("`citype'", "cornfield", "exact", "woolf")
			if _rc {
				if `"`cimainopt'"'!=`""' {
					nois disp as err `"Option {bf:`citype'} is not appropriate without 2x2 count data and will be ignored"'
				}
				else nois disp as err `"Note: {bf:citype(`citype')} is not appropriate without 2x2 count data and will be ignored"'
				local citype
			}	
			
			// Identify studies with insufficient data (`_USE'==2)
			if "`3'"=="" { 	// input is ES + SE
				args _ES _seES
				qui replace `_USE' = 2 if `touse' & `_USE'==1 & missing(`_ES', `_seES')
				qui replace `_USE' = 2 if `touse' & `_USE'==1 & `_seES'==0
				
				// if logrank, `_seES' actually contains (hypergeometric) `v', so 1/se becomes sqrt(v)
				if "`logrank'"=="" qui replace `_USE' = 2 if `touse' & `_USE'==1 & 1/`_seES' < `ztol'
				else qui replace `_USE' = 2 if `touse' & `_USE'==1 & sqrt(`_seES') < `ztol'
			}

			else { 	// input is ES + CI
				args _ES _LCI _UCI
				qui replace `_USE' = 2 if `touse' & `_USE'==1 & missing(`_LCI', `_UCI')
				qui replace `_USE' = 2 if `touse' & `_USE'==1 & float(`_LCI')==float(`_UCI')
				cap assert `_UCI'>=`_ES' & `_ES'>=`_LCI' if `touse' & `_USE'==1
				if _rc {
					nois disp as err "Effect size and/or confidence interval limits invalid;"
					nois disp as err `"order should be {it:effect_size} {it:lower_limit} {it:upper_limit}"'
					exit _rc
				}
				qui replace `_USE' = 2 if `touse' & `_USE'==1 & 2*invnormal(.975)/(`_UCI' - `_LCI') < `ztol'
			}
			qui count if `touse' & `_USE'==1
			if !r(N) exit 2000			
			
		}       // end of inverse-variance setup

		// input is 2x2 tables
		else {
			cap assert "`5'"==""
			if _rc {
				nois disp as err "Invalid number of variables specified" 
				exit _rc
			}
			args e1 f1 e0 f0	// events, non-events in trt group; events, non-events in ctrl group (a.k.a. a b c d)
			
			if "`integer'"=="" {
				cap {
					assert int(`e1')==`e1' if `touse'
					assert int(`f1')==`f1' if `touse'
					assert int(`e0')==`e0' if `touse'
					assert int(`f0')==`f0' if `touse'
				}
				if _rc {
					di as err "Non integer cell counts found" 
					exit _rc
				}
			}
			cap assert `e1'>=0 & `f1'>=0 & `e0'>=0 & `f0'>=0 if `touse'
			if _rc {
				di as err "Non-positive cell counts found" 
				exit _rc
			}

			// -cc- and -nocc-
			if `"`cc'"'!=`""' {
				local 0 `"`cc'"'
				syntax [anything(name=ccval)] [, OPPosite EMPirical]
				if `"`ccval'"'!=`""' {
					confirm number `ccval'
				}
				else local ccval = 0.5
				
				if `"`cc2'"'!=`""' & `ccval' != 0 {
					disp as err `"Cannot specify both {bf:cc()} and {bf:nocc}; please choose one or the other"'
					exit 198
				}
		
				// Empirical CC valid with odds ratio only
				if `"`empirical'"'!=`""' {
					if !inlist("`summstat'", "or", "") {
						nois disp as err "Empirical continuity correction only valid with odds ratios"
						exit 198
					}
					else if "`summstat'"=="" {
						nois disp as err `"Note: Empirical continuity correction specified; odds ratios assumed"' 
						local summstat or
						local effect `"Odds Ratio"'
					}
				}
		
				// ensure continuity correction is valid
				if "`method'"=="peto" {
					nois disp as err "Note: continuity correction is incompatible with Peto method and will be ignored"
					local cc
				}
				else {
					cap assert `ccval'>=0 & `ccval'<1
					if _rc {
						nois disp as err "Invalid continuity correction: must be in range [0,1)"
						exit _rc
					}
				}
			}
			else local ccval = cond(`"`cc2'"'!=`""' | "`method'"=="peto", 0, 0.5)		// default
			if `ccval' > 0 {	// Jan 2019: sreturn local confirms that correction *is* to be made if appropriate
				sreturn local ccopt `"cc(`ccval', `opposite' `empirical')"'
			}
			
			if "`chi2'"!="" {
				if !inlist("`summstat'", "or", "") & !(inlist("`summstat'", "hr", "") & "`logrank'"!="") {
					nois disp as err `"Note: {bf:chi2} is only compatible with odds ratios; option will be ignored"' 
					local chi2
				}
				else if "`summstat'"=="" {
					nois disp as err `"Note: Chi-squared option specified; odds ratios assumed"' 
					local summstat or
					local effect `"Odds Ratio"'
				}
			}
			
			// citype
			cap assert !inlist("`citype'", "cornfield", "exact", "woolf")
			if _rc {			
				if !inlist("`summstat'", "or", "") {
					if `"`cimainopt'"'!=`""' {
						nois disp as err `"Note: {bf:`citype'} is only compatible with odds ratios; option will be ignored"'
					}
					else nois disp as err `"Note: {bf:citype(`citype')} is only compatible with odds ratios; option will be ignored"' 
					local citype
				}
				else if "`summstat'"=="" {
					if "`citype'"=="cornfield" {
						nois disp as err `"Note: Cornfield-type confidence intervals specified; odds ratios assumed"'
					}
					else if "`citype'"=="exact" {
						nois disp as err `"Note: Exact confidence intervals specified; odds ratios assumed"'
					}
					else nois disp as err `"Note: Woolf-type confidence intervals specified; odds ratios assumed"'
					local summstat or
					local effect `"Odds Ratio"'
				}
			}
			
			// Breslow-Day homogeneity test is only valid for OR M-H (c.f. SAS PROC FREQ documentation)
			if "`breslow'"!="" {
				if !inlist("`summstat'", "or", "") | !inlist("`method'", "mh", "") {
					nois disp as err `"{bf:breslow} is only compatible with M-H odds ratios; option will be ignored"' 
					local breslow
				}
				else if "`summstat'"=="" | "`method'"=="" {
					local warntxt = cond("`summstat'"!="", "Mantel-Haenszel method", ///
						cond("`method'"=="", "Mantel-Haenszel odds ratios", "odds ratios"))
					nois disp as err `"Breslow-Day homogeneity test specified; `warntxt' assumed"' 
					
					if "`summstat'"=="" {
						local summstat or
						local effect `"Odds Ratio"'
					}
					if "`method'"=="" local method mh
				}
			}
			
			if inlist("`method'", "cohen", "glass", "hedges", "nostandard") {
				nois disp as err `"Specified method {bf:`method'} is incompatible with the data"'
				exit 184
			}
			if inlist("`summstat'", "hr", "shr", "tr") {
				nois disp as err "Time-to-event outcome types are incompatible with count data"
				exit 184
			}
			if inlist("`summstat'", "wmd", "smd") {
				nois disp as err "Continuous outcome types are incompatible with count data"
				exit 184
			}
			if "`method'"=="peto" {
				if !inlist("`summstat'", "or", "") {
					nois disp as err "Peto method option can only be used with odds ratios"
					exit 184
				}
				else if "`summstat'"=="" {
					nois disp as err `"Note: Peto method specified; odds ratios assumed"' 
					local summstat or
					local effect `"Odds Ratio"'
				}
				local chi2 chi2
			}
			
			if "`summstat'"=="" {
				local summstat rr
				local effect `"Risk Ratio"'
			}
			if "`method'"=="" local method mh		// default pooling method is Mantel-Haenszel

			// Find studies with insufficient data (`_USE'==2)			
			qui replace `_USE' = 2 if `touse' & `_USE'==1 & (`e1' + `f1')*(`e0' + `f0')==0
			if "`summstat'"!="rd" {
				qui replace `_USE' = 2 if `touse' & `_USE'==1 & (`e1' + `e0')*(`f1' + `f0')==0
			}
			qui count if `touse' & `_USE'==1
			if !r(N) exit 2000			
						
		}	// end of binary variable setup

		// log only allowed if OR, RR, IRR, RRR, HR, SHR, TR
		if "`log'"!="" & !inlist("`summstat'", "or", "rr", "irr", "rrr", "hr", "shr", "tr") {
			nois disp as err `"{bf:log} may only be specified with 2x2 count data or log-rank HR; option will be ignored"'
			local log
		}			
		
	} // end of all non-6 variable setup

	if "`6'"!="" {
		
		// log not allowed
		if "`log'"!="" {
			nois disp as err `"{bf:log} may only be specified with 2x2 count data or log-rank HR; option will be ignored"'
			local log
		}			

		args n1 mean1 sd1 n0 mean0 sd0

        // input is form N mean SD for continuous data
		if "`integer'"=="" {
			cap assert int(`n1')==`n1' & int(`n0')==`n0' if `touse'
			if _rc {
				nois disp as err "Non integer sample sizes found"
				exit _rc
			}
		}
        cap assert `n1'>0 & `n0'>0 if `touse'
		if _rc {
			nois disp as err "Non positive sample sizes found" 
			exit _rc
		}

		foreach opt in breslow cc chi2 {
			cap assert `"``opt''"' == `""'
			if _rc {
				nois disp as err `"Note: Option {bf:`opt'} is not appropriate without 2x2 count data and will be ignored"' 
				local `opt'
			}
		}

		// citype
		cap assert !inlist("`citype'", "cornfield", "exact", "woolf")
		if _rc {
			if `"`cimainopt'"'!=`""' {
				nois disp as err `"Option {bf:`citype'} is not appropriate without 2x2 count data and will be ignored"'
			}
			else nois disp as err `"Note: {bf:citype(`citype')} is not appropriate without 2x2 count data and will be ignored"' 
			local citype
		}

		if "`method'"=="nostandard" & "`summstat'"=="smd" {
			nois disp as err `"Cannot specify both SMD and the {bf:nostandard} option"'
			exit 184
		}
		if inlist("`method'", "cohen", "glass", "hedges") & "`summstat'"=="wmd" {
			nois disp as err `"Cannot specify both WMD and the {bf:`mdmethod'} option"'
			exit 184
		}
		if inlist("`method'", "mh", "peto") | "`logrank'"!="" {
			nois disp as err `"Specified method {bf:`method'} is incompatible with the `aggregate'data"'
			exit 184
		}
		cap assert inlist("`summstat'", "", "wmd", "smd")
		if _rc {
			nois disp as err "Invalid specifications for combining trials"
			exit 184
		}

		if "`summstat'"=="" {
			if "`method'"=="nostandard" {		// "nostandard" is a synonym for "wmd"
				local summstat wmd
				local effect `"WMD"'
			}
			else {
				local summstat smd			// default is standardized mean differences...
				local effect `"SMD"'
			}
		}
		if inlist("`method'", "", "iv") local method cohen		//   ...by the method of Cohen

		// Find studies with insufficient data (`_USE'==2)
		qui replace `_USE' = 2 if `touse' & `_USE'==1 & missing(`n1', `mean1', `sd1', `n0', `mean0', `sd0')
		qui replace `_USE' = 2 if `touse' & `_USE'==1 & `n1' < 2  | `n0' < 2
		qui replace `_USE' = 2 if `touse' & `_USE'==1 & `sd1'<=0  | `sd0'<=0
		qui count if `touse' & `_USE'==1
		if !r(N) exit 2000

	} // end of 6-var set-up
	
	// If `params'==4, default to eform unless Risk Diff.
	if "`4'"!="" & "`5'"=="" & `"`summstat'"'!=`"rd"' &  `"`log'"'==`""' {
		local eform eform
	}
	
	// Similarly: if `logrank', default to log
	else if "`logrank'"!="" {
		local log = cond(`"`log'"'!=`""', "log", cond(`"`eform'"'==`""', "log", ""))
	}
	
	assert `"`method'"'!=`""'	// `method' must now be defined (but `summstat' may not be)
	
	// return options
	// if "`cc'"!=""   local ccopt `"cc(`cc')"'
	if "`chi2'"!="" local chi2opt chi2opt			// use `chi2opt' to avoid confusion with later-defined scalar `chi2', containing the statistic itself
	sreturn local options `"`macval(opts_adm)' `logrank' `breslow' `chi2opt' `randomi' `fixedi' `fixed'"'
	sreturn local effect `"`effect'"'
	sreturn local summstat `summstat'
	sreturn local method   `method'
	sreturn local citype   `citype'
	sreturn local eform    `eform'
	sreturn local log      `log'
	
end





*****************************************************************

* Parse meta-analysis modelling options (incl. random-effects)
// compatibility, error checking
// (called directly by admetan.ado)

program define ParseModel, sclass

	syntax [, RAndom1 RAndom(string) RE1 RE(string) MODel(string) ///
		RANDOMI FIXEDI FIXED ///				// for compatibility with metan.ado
		T IVHet QE(varname numeric) ///			// needed in this subroutine, but will also be stored in `opts_model'
		BREslow CHI2opt DF(passthru) ///		// not needed here, but store in `opts_model' for passing to PerformMetaAnalysis
		/*RFDist*/ * ]							// non-modelling options, to store in `opts_adm'
		
	opts_exclusive `"`randomi' `fixedi' `fixed'"' `""' 184
	if `"`randomi'"'!=`""' local re re

	if `"`random'"'!=`""' local rabr `"()"'
	if `"`re'"'!=`""'     local rebr `"()"'

	if `"`random1'"'!=`""' & `"`random'"'==`""' local random random
	if `"`re1'"'!=`""'     & `"`re'"'==`""'     local re re

	if `"`re'"'!=`""' {
		if `"`random'"'!=`""' {
			nois disp as err `"Cannot specify both {bf:re`rebr'} and {bf:random`rabr'}; please choose just one"'
			exit 198
		}
		if `"`model'"'!=`""' {
			nois disp as err `"Cannot specify both {bf:re`rebr'} and {bf:model()}; please choose just one"'
			exit 198
		}
		local model : copy local re			// `re' is a synonym for `model'; use the latter
		local model_orig re`rebr'			// but store actual supplied option for error displays
	}
	else if `"`random'"'!=`""' {
		if `"`model'"'!=`""' {
			nois disp as err `"Cannot specify both {bf:random`rabr'} and {bf:model()}; please choose just one"'
			exit 198
		}
		local model : copy local random		// `random' is a synonym for `model'; use the latter
		local model_orig random`rabr'		// but store actual supplied option for error displays
	}
	else local model_orig model
	
	// re() and fixed/fixedi
	if `"`fixed'`fixedi'"'!=`""' & !inlist("`model'", "fe", "") {
		disp as err `"only one of {bf:`fixed'`fixedi'} and {bf:`model_orig'} is allowed"'
		exit 184
	}	
	
	if `"`qe'"'!=`""' {
		if `"`model'"'!=`""' {
			nois disp as err `"Cannot specify both {bf:qe} and {bf:`model_orig'}"'
			exit 198
		}
		local model qe
		local qe_opt `"qe(`qe')"'		
		
		// Removed August 2018 on advice of Suhail Doi
		// (rescaling is done within PerformPooling, so no need for restriction here)
		/*
		summ `qe', meanonly
		cap {
			assert r(min)>=0
			assert r(max)<=1
		}
		if _rc {
			disp as err "Quality scores must be between zero and one"
			exit 198
		}
		*/
	}
	if `"`ivhet'"'!=`""' {
		if `"`model'"'!=`""' {
			nois disp as err `"Cannot specify both {bf:ivhet} and {bf:`model_orig'}"'
			exit 198
		}
		local model ivhet
	}	

	// If no random-effects model, exit early
	sreturn clear
	sreturn local options `"`macval(options)'"'					// Return non-model options	
	if `"`model'"'==`""' {
		sreturn local opts_model `"`breslow' `chi2opt' `t'"'	// Options for PerformMetaAnalysis
		exit
	}
	
		// Moved to main routine Jan 2019 for v3.2 [was within the -if `"`model'"'==`""' {}- clause]
		/*
		// cannot use prediction intervals
		if "`rfdist'"!="" {
			nois disp as err `"Note: prediction interval cannot be estimated under the specified model; {bf:rfdist} will be ignored"' 
		}
		*/
	
	// Parse RE models and synonyms
	local t_old `t'
	local 0 `model'
	syntax [name(name=model id="meta-analysis model")] ///
		[, HKsj BArtlett RObust SKovgaard EIM OIM T Z QProfile INIT(string) TSQLEVEL(passthru) ///
		ITOL(passthru) MAXTausq(passthru) REPS(passthru) MAXITer(passthru) QUADPTS(passthru) ISQ(string) TAUSQ(string) noTRUNCate ]
	// tausq() option added 24th July 2017
	// bartlett and z (i.e. "not LR" options) added 5th March 2018; "z" returns signed LR statistic (as opposed to Wald-type) as of Jan 2019
	// robust option added 13th Dec 2018
	// skovgaard option added 5th Jan 2019
	
	// DerSimonian-Laird is default
	if inlist("`model'", "", "r", "random", "rand", "re", "dl") local model dl

	// Other tausq estimators (with synonyms)
	if inlist("`model'", "f", "fe", "fixed") local model fe					// Fixed-effects inverse-variance
	else if inlist("`model'", "bdl", "dlb") local model dlb					// Bootstrap DerSimonian-Laird (Kontopantelis)
	else if inlist("`model'", "mp", "pm", "q", "gq", "genq", "vb", "eb") local model mp	// Mandel-Paule aka Generalised Q aka Empirical Bayes
	else if inlist("`model'", "vc", "ca", "he") local model vc				// Variance-component aka Cochran's ANOVA-type aka Hedges
	else if inlist("`model'", "sj2", "sj2s") local model sj2s				// Sidik-Jonkman two-step (default init=vc)
	else if inlist("`model'", "dk2", "dk2s") local model dk2s				// DerSimonian-Kacker two-step (default init=vc)
	else if inlist("`model'", "sens", "sa") local model sa					// Sensitivity analysis (at fixed Isq) as suggested by Kontopantelis
	
	// Other model types (with synonyms)
	else if inlist("`model'", "g", "ga", "gam", "gamm", "gamma", "bt", "bs") local model gamma		// Biggerstaff-Tweedie
	else if inlist("`model'", "mu", "mul", "mult", "fv") local model mu								// Multiplicative heterogeneity
	else if inlist("`model'", "ivh", "ivhe", "ivhet") local model ivhet								// Doi's IVHet
	
	// Hartung-Knapp-Sidik-Jonkman variance correction
	if "`hksj'"!="" {
		if inlist("`model'", "dlt", "hk", "hks", "hksj", "kh") local model dl
		else if inlist("`model'", "mu", "gamma", "kr", "hc", "ivhet", "qe", "pl") {
			nois disp as err `"Specified random-effects model is incompatible with Hartung-Knapp-Sidik-Jonkman variance estimator"'
			exit 198
		}
	}
	else if inlist("`model'", "dlt", "hk", "hks", "hksj", "kh") {
		local model dl		// DL is default tausq estimator
		local hksj hksj
	}
			
	// Kenward-Roger variance correction: allow "reml, kr" as an alternative
	if "`kr'"!="" {
		if !inlist("`model'", "", "kr", "reml" {
			nois disp as err "Kenward-Roger variance estimator may only be combined"
			nois disp as err " with the REML estimator of tau{c 178}"
			exit 198
		}
		local model kr
	}
	
	// Sidik-Jonkman robust ("sandwich-like") variance estimator
	if "`robust'"!="" {
		if inlist("`model'", "mu", "gamma", "kr", "hc", "ivhet", "qe", "pl") {
			nois disp as err `"Specified random-effects model is incompatible with Sidik-Jonkman robust variance estimator"'
			exit 198
		}
	}
	
	// Two-step models
	if "`init'"!=`""' {
		if !inlist("`model'", "sj2s", "dk2s") {
			nois disp as err `"Option {bf:init()} is only valid with two-step estimators of tausq"'
			exit 198
		}
	}
	if inlist("`model'", "sj2s", "dk2s") {
		if "`init'"=="" local init vc				// default initial estimate is Hedges/Cochran/Variance-component
		if "`model'"=="dk2s" {						// DerSimonian-Kacker two-step is valid for MM estimators only
			if !(inlist("`init'", "vc", "dl") | substr(trim(`"`init'"'), 1, 2)==`"sa"') {
				nois disp as err `"Option {bf:init()} must be {bf:vc}, {bf:dl} or {bf:sa} with DerSimonian-Kacker two-step estimator"'
				exit 198
			}
		}
		else {
			if !(inlist("`init'", "vc", "dl", "dlb", "ev", "hm") | inlist("`init'", "b0", "bp", "mp", "ml", "reml") | substr("`init'",1,2)=="sa") {
				nois disp as err `"Invalid {bf:init()} option with Sidik-Jonkman two-step estimator"'
				exit 198
			}
		}
		local init_opt `"init(`init')"'
	}	
		
	// final check for valid random-effects models:
	if !inlist("`model'", "fe", "dl", "dlb", "ev", "vc", "hm", "b0", "bp") ///			// simple tsq estimators (non-iterative)
		& !inlist("`model'", "mp", "ml", "reml") ///									// simple tsq estimators (iterative)
		& !inlist("`model'", "sj2s", "dk2s", "sa") ///									// two-step estimators; sensitivity analysis at fixed tsq/Isq
		& !inlist("`model'", "pl", "kr", "gamma", "hc", "mu", "qe", "ivhet") {			// complex models
		nois disp as err "Invalid random-effects model"
		nois disp as err "Please see {help admetan:help admetan} for a list of valid model names"
		exit 198
	}

	// conflicting options
	opts_exclusive `"`hksj' `bartlett' `skovgaard' `robust'"' `"`model_orig'"' 184	

	// Bartlett and Skovgaard likelihood corrections: profile likelihood only
	if `"`bartlett'`skovgaard'"'!=`""' {
		cap assert "`model'"=="pl"
		if _rc {
			local errtext = cond(`"`bartlett'"'!=`""', `"Bartlett's"', `"Skovgaard's"')
			nois disp as err `"`errtext' correction is only valid with Profile Likelihood"'
			exit 198
		}
		if `"`bartlett'"'!=`""' local chi2opt chi2opt
		else local z z
	}
	
	// dependencies
	if inlist("`model'", "mp", "ml", "pl", "reml", "gamma", "hc") | "`qprofile'"!="" {
		capture mata mata which mm_root()
		if _rc {
			nois disp as err `"Iterative tau-squared calculations require the Mata functions {bf:mm_root()} from {bf:moremata}"'
			nois disp as err `"Type {stata ssc describe moremata:ssc install moremata} to install it"'
			exit 499
		}
		if inlist("`model'", "gamma", "hc") {
			capture mata mata which integrate()
			if _rc {
				if "`model'"=="gamma" nois disp as err `"Biggerstaff-Tweedie method requires the mata function {bf:integrate()}"'
				else nois disp as err `"Henmi-Copas method requires the mata function {bf:integrate()}"'
				nois disp as err `"Type {stata ssc describe integrate:ssc install integrate} to install it"'
				exit 499
			}
		}
	}
	if "`model'"=="dlb" {
		capture mata mata which mm_bs()
		local rc1 = _rc
		capture mata mata which mm_jk()
		if _rc | `rc1' {
			nois disp as err `"Bootstrap DerSimonian-Laird method requires the Mata functions {bf:mm_bs()} and {bf:mm_jk()} from {bf:moremata}"'
			nois disp as err `"Type {stata ssc describe moremata:ssc install moremata} to install it"'
			exit 499
		}
	}
	
	// sensitivity analysis
	if "`model'"=="sa" {
		/*
		if `"`hksj'"'!=`""' {
			disp as err `"Cannot use the {bf:hksj} option with sensitivity analysis"'
			exit 198
		}
		*/
		if `"`tausq'"'!=`""' {
			cap confirm number `tausq'
			if _rc {
				disp as err `"Error in {bf:tausq()} suboption to {bf:sa()}; a single number was expected"'
				exit _rc
			}
			if `tausq'<0 {
				nois disp as err `"tau{c 178} value for sensitivity analysis cannot be negative"'
				exit 198
			}
			local tsqsa_opt `"tsqsa(`tausq')"'
		}
		else {
			if `"`isq'"'==`""' local isq = 80
			else {
				cap confirm number `isq'
				if _rc {
					disp as err `"Error in {bf:isq()} suboption to {bf:sa()}; a single number was expected"'
					exit _rc
				}
				if `isq'<0 | `isq'>=100 {
					nois disp as err `"I{c 178} value for sensitivity analysis must be at least 0% and less than 100%"'
					exit 198
				}
			}
			local isqsa_opt `"isqsa(`isq')"'
		}
		
		if `: word count `tsqsa' `isqsa'' >=2 {
			nois disp as err `"Only one of {bf:isq()} or {bf:tausq()} may be supplied as suboptions to {bf:sa()}"'
			exit 184
		}
	}
	
	// if NOT sensitivity analysis
	else {
		if `"`isq'"'!=`""' {
			nois disp as err `"{bf:isq()} may only be specified when requesting a sensitivity analysis model"'
			exit 198
		}
		if `"`tausq'"'!=`""' {
			nois disp as err `"{bf:tausq()} may only be specified when requesting a sensitivity analysis model"'
			exit 198
		}
	}
	
	// observed/expected information matrix for Kenward-Roger
	if `"`eim'`oim'"'!=`""' {
		if "`model'"!="kr" {
			nois disp as err `"Note: Options {bf:eim} and {bf:oim} are only relevant to the Kenward-Roger variance estimator and will be ignored"' 
		}
		else {
			cap assert `: word count `eim' `oim'' == 1
			if _rc {
				nois disp as err `"May only specify one of {bf:eim} or {bf:oim}, not both"'
				exit _rc
			}
		}
	}
	else if "`model'"=="kr" local eim eim		// default

	// t-distribution and chi2:
	// PL uses chi2 as default; HKSJ and Robust methods use t as default.
	// All three can be overridden with "z" option.
	// (Note that PL with "z" uses signed likelihood statistic.)
	if `"`t_old'"'!=`""' local t t
	if "`z'"=="" {
		if (`"`hksj'`robust'"'!=`""' | "`model'"=="kr") local t t
		if "`model'"=="pl" local chi2opt chi2opt
	}
	if "`chi2opt'"!="" & "`model'"!="pl" {
		nois disp as err "Chi-squared test is not compatible with specified random-effects model"
		exit 198
	}
	
	// other return options
	sreturn local model  `model'
	sreturn local model2 `hksj'`bartlett'`skovgaard'`robust'		// Extra details to return as string within r(model)
	
	local opts_model `"`breslow' `chi2opt' `t'"'
	local opts_model `"`opts_model' `z' `qprofile' `hksj' `bartlett' `skovgaard' `robust'"'
	local opts_model `"`opts_model' `tsqlevel' `isqsa_opt' `tsqsa_opt' `qe_opt' `init_opt'"'
	local opts_model `"`opts_model' `itol' `maxtausq' `reps' `maxiter' `quadpts' `eim' `oim' `truncate'"'
	sreturn local opts_model `"`opts_model'"'						// Additional model options for PerformPooling
	
end




********************************************************************************

* Subroutine to initialise rownames for matrices `ovstats' and `bystats'
// where outputs from PerformPooling are stored

program define InitRownames, sclass

	syntax, METHOD(string) MODEL(string) [BREslow CHI2opt LOGRank QProfile RFDist BArtlett * ]

	local rownames eff se_eff eff_lci eff_uci npts crit					// effect size; std. err.; conf. limits; no. pts.; critical value
	if `"`model'"'==`"pl"' {
		if `"`chi2opt'`bartlett'"'!=`""' local rownames `rownames' lr_chi2		// LR chi2 statistic (PL +/- Bartlett)
		else local rownames `rownames' lr_z								 // Signed LR statistic (PL +/- Skovgaard) [added Jan 2019]
	}
	else if `"`model'"'=="hc" local rownames `rownames' u				// u statistic (Henmi-Copas only)
	else if `"`model'"'=="kr" local rownames `rownames' df_kr			// effect-size df (Kenward-Roger only)
	else if `"`chi2opt'"'!=`""' local rownames `rownames' chi2			// chi2 statistic (OR and logrank only)
	local rownames `rownames' pvalue									// p-value	
	if `"`logrank'"'!=`""' | "`method'"=="peto" ///
		local rownames `rownames' oe v									// logrank and Peto OR only
	local rownames `rownames' Q Qdf Isq HsqM							// standard heterogeneity stats
	if "`model'"!="mh" & !("`model'"=="fe" & ("`method'"=="peto" | "`breslow'"!="")) ///
		local rownames `rownames' sigmasq tausq							// sigmasq, tausq (not applicable if Cochran's Q not used)
	if inlist("`model'", "dlb", "mp", "ml", "pl", "reml", "gamma", "kr") | "`qprofile'"!="" ///
		local rownames `rownames' tsq_lci tsq_uci						// tsq_lci, tsq_uci	(either using Q-profiling, or with certain iterative models)
	if `"`rfdist'"'!="" local rownames `rownames' rflci rfuci			// if predictive distribution

	sreturn clear
	sreturn local rownames `rownames'
	
end




********************************************************************************

* PerformMetaAnalysis
// Create list of "pooling" variables
// Run meta-analysis on whole dataset ("overall") and, if requested, by subgroup
// If cumul/influence, subroutine "CumInfLoop" is run first, to handle the intermediate steps
// Then (in any case), subroutine "PerformPooling" is run.
// (called directly by admetan.ado)

// N.B. [Sep 2018] takes bits of old (v2.2) MainRoutine and PerformMetaAnalysis subroutines

program define PerformMetaAnalysis, rclass sortpreserve

	syntax varlist(numeric min=3 max=7) [if] [in], SORTBY(varlist) ///
		METHOD(string) MODEL(string) CItype(passthru) [BY(string) SUMMSTAT(string) ///
		OUTVLIST(varlist numeric min=5 max=8) XOUTVLIST(varlist numeric) ROWNAMES(namelist) ///
		CUmulative INFluence noOVerall noSUbgroup OVWt SGWt ALTWt WGT(varname numeric) ///
		LOGRank LEVEL(passthru) RFDist RFLEVEL(passthru) USE3(passthru) CCVAR(passthru) ///
		BREslow CHI2opt CC(passthru) DF(passthru) ///		// from `opts_model'; needed in main routine
		* ]													// from `opts_model'; needed in PerformPooling only
	
	local opts_model `"`macval(options)'"'
	
	marksample touse, novarlist		// -novarlist- option prevents -marksample- from setting `touse' to zero if any missing values in `varlist'
									// we want to control this behaviour ourselves, e.g. by using KEEPALL option
	tokenize `outvlist'
	args _ES _seES _LCI _UCI _WT _NN
	gettoken _USE invlist : varlist


	* Create list of "pooling" tempvars to pass to ProcessPoolingVarlist
	// and thereby create final generic list of "pooling" vars to use within MetaAnalysisLoop
	// (i.e. tempvars that are only needed within this subroutine)
	
	// Logic:
	// If M-H pooling, then M-H heterogeneity
	// If Peto pooling, then Peto heterogeneity
	// If generic I-V with 2x2 count data, then either Cochran or M-H heterogeneity (or Breslow-Day, but only if OR)
	
	// So:
	// M-H heterogeneity if (a) M-H pooling or (b) generic I-V (fe, re) with 2x2 count data and cochran/breslow not specified (M-H is default in this situation)
	// Peto heterogeneity if (a) Peto pooling or (b) generic I-V (fe, re) with 2x2 count data and cochran/breslow not specified AND OR/HR ONLY
	// Breslow-Day heterogeneity only if OR and user-specified
	// Cochran heterogeneity only if generic I-V (and user-specified if necessary)
	
	// So:
	// If OR + M-H then het can be only be M-H
	// If OR + Peto then het can only be Peto
	// If OR + RE I-V then het can be M-H (default), Peto, Breslow or Cochran -- the only situation where "peto" option can be combined
	// If OR + FE I-V then het can be Cochran (default) or Breslow

	// If HR + Peto then het can only be Peto
	// If HR + RE I-V then het can be Peto (default) or Cochran
	
	// If RR/RD + M-H then het can only be M-H
	// If RR/RD + RE I-V then het can be M-H (default) or Cochran
	
	// If anything else + FE I-V then het can only be Cochran
	
	local params : word count `invlist'
	if `params' > 3 | "`logrank'"!="" {			// all except generic inverse-variance input

		if `params' == 4 {		// Binary outcome (OR, Peto, RR, RD)

			if "`summstat'"=="or" {
				if "`method'"=="mh" {							// extra tempvars for Mantel-Haenszel OR and/or het
					tempvar r s pr ps qr qs
					local tvlist `r' `s' `pr' `ps' `qr' `qs'
				}
				if "`chi2opt'"!="" {							// extra tempvars for chi-squared test (incl. Peto OR)
					tempvar oe va
					local tvlist `tvlist' `oe' `va'
				}
			}
			
			else if inlist("`summstat'", "rr", "irr", "rrr") {	// RR/IRR/RRR
				tempvar r s
				local tvlist `r' `s'
				
				if "`method'"=="mh" {
					tempvar p
					local tvlist `tvlist' `p'
				}
			}
			
			else if "`summstat'" == "rd" & "`method'"=="mh" {	// RD
				tempvar rdwt rdnum vnum
				local tvlist `rdwt' `rdnum' `vnum'
			}
		}
		
		else if "`logrank'"!="" {		// logrank HR (O-E & V -- already supplied in `invlist')
			assert `params'==2
		}

		//  Generate study-level effect size variables `_ES' and `_seES',
		//  plus variables used to generate overall/subgroup statistics
		cap nois ProcessPoolingVarlist `_USE' `invlist' if `touse', ///
			outvlist(`outvlist') summstat(`summstat') method(`method') model(`model') ///
			tvlist(`tvlist') `breslow' `logrank' `cc' `ccvar' `chi2opt'
		
		if _rc {
			nois disp as err `"Error in {bf:admetan.ProcessPoolingVarlist}"'
			c_local err noerr		// tell admetan not to also report an "error in PerformMetaAnalysis"
			exit _rc
		}
		
		local qvlist `_ES' `_seES'			// "heterogeneity" varlist : if `pvlist' doesn't contain `_ES' & `_seES' then these need to be referenced separately
		local chi2vars `"`r(chi2vars)'"'	// varlist for chi2 test (if applicable)

	}	// end if `params' > 3 | "`logrank'"!=""
	
	local pvlist = cond(`"`r(pvlist)'"'!=`""', `"`r(pvlist)'"', `"`_ES' `_seES'"')		// "pooling" varlist


	// Special case:  need to generate `_seES' if ES + CI were provided; assume normal distribution and 95% coverage
	if `params'==3 {
		if `"`level'"'!=`""' {
			tokenize `invlist'			// if level() option supplied, requesting coverage other than 95%,
			args _ES_ _LCI_ _UCI_		// need to derive _seES from the *original* confidence limits supplied in `invlist' (assumed to be 95% !!)
		}
		else {
			local _LCI_ `_LCI'
			local _UCI_ `_UCI'
		}
		qui replace `_seES' = (`_UCI_' - `_LCI_') / (2*invnormal(.5 + 95/200)) if `touse' & `_USE'==1
	}

	// We should now have _ES and _seES defined throughout.
	// Quick double-check that studies with insufficient data are identified ("`_USE'==2")
	// (should already have been done by either -ipdmetan- or -ProcessInputVarlist-)
	// (but in special cases, e.g. if `nocc', may still be some missings)
	qui replace `_USE' = 2 if `touse' & `_USE'==1 & missing(`_ES', `_seES')
	qui count if `_USE'==1
	if !r(N) exit 2000	
		
	// if B0 estimator, must have _NN for all studies with an effect size (i.e. `_USE'==1)
	if "`model'"=="b0" {
		cap {
			confirm numeric var `_NN'
			assert `_NN'>=0 & !missing(`_NN') if `_USE'==1
		}
		if _rc {
			nois disp as err `"Participant numbers not available for all studies; cannot calculate tau{c 178} estimator B0"'
			exit 198
		}
		local npts `_NN'	// to send to PerformPooling / CumInfLoop
	}						// N.B. `npts' is otherwise undefined in this subroutine
	
	
	// setup for subgroups and/or cumulative MA
	tempname Q Qsum k n
	scalar `Q'    = 0
	scalar `Qsum' = 0
	scalar `k'    = .
	scalar `n'    = .
	
	
	********************
	* Overall analysis *
	********************

	local nrfd = 0		// initialize marker of "subgroup has < 3 studies" (only for rfdist with cumul/influence)
	local nmiss = 0		// initialize marker of "pt. numbers are missing in one or more trials"

	// if `"`overall'"'==`""' | (`"`ovwt'"'!=`""' & `"`by'"'!=`""') {
	if `"`overall'"'==`""' | `"`ovwt'"'!=`""'  {

		// if ovwt, pass `_WT' to PerformPooling to be filled in
		// otherwise, PerformPooling will generate a tempvar, and `_WT' will remain empty
		local wtvar = cond(`"`ovwt'"'!=`""', `"`_WT'"', `""')
	

		** Cumulative/influence analysis
		// Run extra loop to store results of each iteration within the currrent dataset (`xoutvlist')
		if `"`cumulative'`influence'"' != `""' {

			cap nois CumInfLoop `_USE' `pvlist' if `touse' & `_USE'==1, sortby(`sortby') ///
				method(`method') model(`model') xoutvlist(`xoutvlist') altvlist(`_ES' `_seES') ///
				summstat(`summstat') wgt(`wgt') wtvar(`wtvar') ///
				chi2vars(`chi2vars') qvlist(`qvlist') rownames(`rownames') npts(`npts') `use3' ///
				`breslow' `cumulative' `influence' `ovwt' `level' `rfdist' `rflevel' `opts_model'
			
			if _rc {
				if `"`err'"'==`""' {
					if _rc==1 nois disp as err `"User break in {bf:admetan.CumInfLoop}"'
					else nois disp as err `"Error in {bf:admetan.CumInfLoop}"'
				}
				c_local err noerr		// tell admetan not to also report an "error in PerformMetaAnalysis"
				exit _rc
			}

			local xwt `r(xwt)'			// extract _WT2 from `xoutvlist'
		}
		
		
		** Main meta-analysis
		// If `cumulative', the last iteration of the loop above is equivalent to a standard "overall" pooling;
		//   hence, no need to run PerformPooling again.
		// If `influence', this is not the case.
		if `"`cumulative'"'==`""' {

			// If only one study, display warning message if appropriate
			// (the actual change in method is handled by PerformPooling)
			qui count if `touse' & `_USE'==1
			if r(N)==1 {
				if !inlist("`model'", "fe", "mh") {
					nois disp as err "Note: Only one estimate found; random-effects model not used"
				}
			}
		
			cap nois PerformPooling `pvlist' if `touse' & `_USE'==1, ///
				method(`method') model(`model') summstat(`summstat') ///
				qvlist(`qvlist') invlist(`invlist') npts(`npts') wtvar(`wtvar') wgt(`wgt') ///
				chi2vars(`chi2vars') `breslow' `logrank' `level' `rfdist' `rflevel' `opts_model'
			
			if _rc {
				if _rc==1 nois disp as err `"User break in {bf:admetan.PerformPooling}"'
				else nois disp as err `"Error in {bf:admetan.PerformPooling}"'
				c_local err noerr		// tell admetan not to also report an "error in MetaAnalysisLoop"
				exit _rc
			}
			
			// pooling failed (may not have caused an actual error)
			if missing(r(eff), r(se_eff)) exit 2002
		}

	
		** Save statistics in matrix
		tempname ovstats
		matrix define   `ovstats' = J(`: word count `rownames'', 1, .)
		matrix rownames `ovstats' = `rownames'
		
		foreach el in `rownames' {
			local rownumb = rownumb(`ovstats', "`el'")
			if !missing(`rownumb') {
				mat `ovstats'[`rownumb', 1] = r(`el')
			}
		}
		scalar `k' = r(k)			// overall number of studies

		
		// Warning messages & error codes r.e. confidence limits for iterative tausq
		if !missing(rownumb(`ovstats', "tsq_lci")) {
			
			local maxtausq2 = r(maxtausq)		// take maxtausq from PerformPooling (10* D+L estimate)
			local 0 `", `iteropts'"'
			syntax [, ITOL(real 1e-8) MAXTausq(real -9) REPS(real 1000) MAXITer(real 1000) QUADPTS(real 100)]

			if !inlist("`model'", "dlb", "gamma") {
				if r(rc_tausq)==1 nois disp as err `"Note: tau{c 178} point estimate failed to converge within `maxiter' iterations"'
				else if r(rc_tausq)==3 {
					if `maxtausq'==-9 nois disp as err `"Note: tau{c 178} greater than default value {bf:maxtausq(}`maxtausq2'{bf:)}; try increasing it"'
					else nois disp as err `"Note: tau{c 178} greater than `maxtausq'; try increasing {bf:maxtausq()}"'
				}
				else if missing(r(tausq)) {
					nois disp as err `"Note: tau{c 178} point estimate could not be found; possible discontinuity in search interval"'
					exit 498
				}
				return scalar rc_tausq = r(rc_tausq)		// whether tausq point estimate converged
			}
			
			if "`model'"!="dlb" {
				if r(rc_tsq_lci)==1 nois disp as err `"Note: Lower confidence limit of tau{c 178} failed to converge within `maxiter' iterations; try increasing {bf:maxiter()}"'
				else if missing(r(tsq_lci)) {
					nois disp as err `"Note: Lower confidence limit of tau{c 178} could not be found; possible discontinuity in search interval"'
				}
					
				if r(rc_tsq_uci)==1 nois disp as err `"Note: Upper confidence limit of tau{c 178} failed to converge within `maxiter' iterations; try increasing {bf:maxiter()}"'
				else if r(rc_tsq_uci)==3 {
					if `maxtausq'==-9 nois disp as err `"Note: Upper confidence limit of tau{c 178} greater than default value {bf:maxtausq(}`maxtausq2'{bf:)}; try increasing it"'
					else nois disp as err `"Note: Upper confidence limit of tau{c 178} greater than `maxtausq'; try increasing {bf:maxtausq()}"'
				}
				else if missing(r(tsq_uci)) {
					nois disp as err `"Note: Upper confidence limit of tau{c 178} could not be found; possible discontinuity in search interval"'
				}
				return scalar rc_tsq_lci = r(rc_tsq_lci)		// whether tausq lower confidence limit converged
				return scalar rc_tsq_uci = r(rc_tsq_uci)		// whether tausq upper confidence limit converged
			}

			if "`model'"=="pl" {
				if r(rc_eff_lci)==1 nois disp as err `"Note: Lower confidence limit of effect size failed to converge within `maxiter' iterations; try increasing {bf:maxiter()}"'
				else if r(rc_eff_lci)>1 | missing(`r(eff_lci)') {
					nois disp as err `"Note: Lower confidence limit of effect size could not be found; possible discontinuity in search interval"'
				}
				if r(rc_eff_uci)==1 nois disp as err `"Note: Upper confidence limit of effect size failed to converge within `maxiter' iterations; try increasing {bf:maxiter()}"'
				else if r(rc_eff_uci)>1 | missing(`r(eff_uci)') {
					nois disp as err `"Note: Upper confidence limit of effect size could not be found; possible discontinuity in search interval"'
				}				
				return scalar rc_eff_lci = r(rc_eff_lci)		// whether ES lower confidence limit converged
				return scalar rc_eff_uci = r(rc_eff_uci)		// whether ES upper confidence limit converged					
			}
		}

		return add					// add anything else returned by PerformPooling to return list of PerformMetaAnalysis
									// e.g. r(OR), r(RR); tsq-related stuff; chi2
		
		// Normalise weights overall (if `ovwt')
		if `"`ovwt'"'!=`""' {
			local _WT2 = cond(`"`xwt'"'!=`""', `"`xwt'"', `"`_WT'"')			// use _WT2 from `xoutvlist' if applicable
			summ `_WT' if `touse', meanonly
			qui replace `_WT2' = 100*cond(`"`altwt'"'!=`""', `_WT', `_WT2') / r(sum) ///
				if `touse' & `_USE'==1		// use *original* weights (_WT) rather than cumul/infl weights (_WT2) if `altwt'
		}

		// Find and store number of participants
		if `"`_NN'"'!=`""' {
			summ `_NN' if `touse' & `_USE'==1, meanonly
			mat `ovstats'[rownumb(`ovstats', "npts"), 1] = r(sum)
			scalar `n' = r(sum)
		}
		
	}		// end if "`overall'"==""

	
	
	******************************************
	* Analysis within study subgroups (`by') *
	******************************************
	
	if (`"`by'"'!=`""' & `"`subgroup'"'==`""') | `"`sgwt'"'!=`""' {
	
		// Initialize markers of subgroup-related errors
		// (plus Mata iterative functions failed to converge etc ... this is done on-the-fly for `overall')
		foreach el in nrc2000 nrc2002 nsg ntausq ntsqlci ntsquci nefflci neffuci {
			local `el' = 0
		}

		// Initialize counts of studies and of pts., in case not already counted by `overall'
		tempname kOV nOV
		scalar `kOV' = 0
		scalar `nOV' = .
		
		// Initialise matrix to hold subgroup stats (matrix bystats)
		qui levelsof `by' if `touse' & inlist(`_USE', 1, 2), missing local(bylist)	// "missing" since `touse' should already be appropriate for missing yes/no
		local nby : word count `bylist'
		
		tempname bystats
		matrix define   `bystats' = J(`: word count `rownames'', `nby', .)
		matrix rownames `bystats' = `rownames'
		matrix colnames `bystats' = `bylist'

		
		// if sgwt, pass `_WT' to PerformPooling to be filled in
		// otherwise, PerformPooling will generate a tempvar, and `_WT' will remain empty
		local wtvar = cond(`"`sgwt'"'!=`""', `"`_WT'"', `""')
		
		local i = 0
		foreach byi of local bylist {
		
			** Cumulative/influence analysis
			// Run extra loop to store results of each iteration within the currrent dataset (`xoutvlist')
			if `"`cumulative'`influence'"' != `""' {
			
				cap nois CumInfLoop `_USE' `pvlist' if `touse' & `_USE'==1 & `by'==`byi', sortby(`sortby') ///
					method(`method') model(`model') xoutvlist(`xoutvlist') altvlist(`_ES' `_seES') ///
					summstat(`summstat') wgt(`wgt') wtvar(`wtvar') ///
					chi2vars(`chi2vars') qvlist(`qvlist') rownames(`rownames') npts(`npts') `use3' ///
					`breslow' `cumulative' `influence' `sgwt' `level' `rfdist' `rflevel' `opts_model'

				if _rc {
					if _rc==1 {
						nois disp as err "User break in {bf:admetan.CumInfLoop}"
						c_local err noerr		// tell admetan not to also report an "error in PerformMetaAnalysis"
						exit _rc
					}
					else if !inlist(_rc, 2000, 2002) {
						if `"`err'"'==`""' nois disp as err `"Error in {bf:admetan.CumInfLoop}"'
						c_local err noerr		// tell admetan not to also report an "error in PerformMetaAnalysis"
						exit _rc
					}
					else if _rc==2000 local nrc2000 = 2000
					else if _rc==2002 local nrc2002 = 2002
				}
				else {
					if `"`r(nsg)'"'!=`""' local nsg = 1
					if !inlist(r(rc_tausq), 0, .)   local ntausq = 1
					if !inlist(r(rc_tsq_lci), 0, .) local ntsqlci = 1
					if !inlist(r(rc_tsq_uci), 0, .) local ntsquci = 1
					if !inlist(r(rc_eff_lci), 0, .) local nefflci = 1
					if !inlist(r(rc_eff_uci), 0, .) local neffuci = 1
				}
				
				local xwt `r(xwt)'			// extract _WT2 from `xoutvlist'
			}

			
			** Main subgroup meta-analysis
			// If `cumulative', the last iteration of the loop above is equivalent to a standard "overall" pooling;
			//   hence, no need to run PerformPooling again.
			// If `influence', this is not the case.
			cap nois PerformPooling `pvlist' if `touse' & `_USE'==1 & `by'==`byi', ///
				method(`method') model(`model') summstat(`summstat') ///
				qvlist(`qvlist') invlist(`invlist') npts(`npts') wtvar(`wtvar') wgt(`wgt') ///
				chi2vars(`chi2vars') `breslow' `logrank' `level' `rfdist' `rflevel' `opts_model'

			if _rc {
				if _rc==1 {
					nois disp as err "User break in {bf:admetan.PerformPooling}"
					c_local err noerr		// tell admetan not to also report an "error in PerformMetaAnalysis"
					exit _rc
				}
				else if !inlist(_rc, 2000, 2002) {
					if `"`err'"'==`""' nois disp as err `"Error in {bf:admetan.PerformPooling}"'
					c_local err noerr		// tell admetan not to also report an "error in PerformMetaAnalysis"
					exit _rc
				}
				else if _rc==2000 local nrc2000 = 2000
				else if _rc==2002 local nrc2002 = 2002
			}
			else {
				if `"`r(nsg)'"'!=`""' local nsg = 1
				if !inlist(r(rc_tausq), 0, .)   local ntausq = 1
				if !inlist(r(rc_tsq_lci), 0, .) local ntsqlci = 1
				if !inlist(r(rc_tsq_uci), 0, .) local ntsquci = 1
				if !inlist(r(rc_eff_lci), 0, .) local nefflci = 1
				if !inlist(r(rc_eff_uci), 0, .) local neffuci = 1
			}
			
			// Display warning messages
			// (only brief messages here, compared to the "full" messages reported following the overall pooling; see above)
			if `nrc2000' nois disp as err "Note: insufficient data in one or more subgroups"
			if `nrc2002' nois disp as err "Note: pooling failed in one or more subgroups"
			if `nsg'     nois disp as err "Note: one or more subgroups contain only a single valid estimate"
			if `ntausq'  nois disp as err "Note: tau{c 178} point estimate not successfully estimated in one or more subgroups"
			if `ntsqlci' nois disp as err "Note: tau{c 178} lower confidence limit not successfully estimated in one or more subgroups"
			if `ntsquci' nois disp as err "Note: tau{c 178} upper confidence limit not successfully estimated in one or more subgroups"
			if `nefflci' nois disp as err "Note: lower confidence limit of effect size not successfully estimated in one or more subgroups"
			if `neffuci' nois disp as err "Note: upper confidence limit of effect size not successfully estimated in one or more subgroups"
	
			
			// update `bystats' matrix and return subgroup stats (if PerformPooling ran successfully)
			local ++i
			
			if !_rc {

				// update `bystats' matrix
				foreach el in `rownames' {
					local rownumb = rownumb(`bystats', "`el'")
					if !missing(`rownumb') {
						mat `bystats'[rownumb(`bystats', "`el'"), `i'] = r(`el')
					}
				}

				// update running sums
				scalar `Qsum' = `Qsum' + r(Q)
				scalar `kOV'  = `kOV'  + r(k)
				if `"`_NN'"'!=`""' {
					summ `_NN' if `touse' & `_USE'==1 & `by'==`byi', meanonly
					mat `bystats'[rownumb(`bystats', "npts"), `i'] = r(sum)
					scalar `nOV' = cond(missing(`nOV'), 0, `nOV') + r(sum)
				}
				
				// Normalise weights by subgroup (if `sgwt')
				if `"`sgwt'"'!=`""' {
					local _WT2 = cond(`"`xwt'"'!=`""', `"`xwt'"', `"`_WT'"')		// use _WT2 from `xoutvlist' if applicable
					summ `_WT' if `touse' & `_USE'==1 & `by'==`byi', meanonly
					qui replace `_WT2' = 100*cond(`"`altwt'"'!=`""', `_WT', `_WT2') / r(sum) ///
						if `touse' & `_USE'==1 & `by'==`byi'		// use *original* weights (_WT) rather than cumul/infl weights (_WT2) if `altwt'
				}
			}
			
		}	// end foreach byi of local bylist

		if (`"`overall'"'==`""' | `"`ovwt'"'!=`""') {
			assert `kOV' == `k'		// check that sum of subgroup `k's = previously-calculated overall `k'
			assert `nOV' == `n'		// check that sum of subgroup `n's = previously-calculated overall `n'
		}
		else {
			scalar `k' = `kOV'		// if no previously-calculated overall `k', *define* it to be sum of subgroup `k's
			scalar `n' = `nOV'		// if no previously-calculated overall `n', *define* it to be sum of subgroup `n's
		}

		// Return `Qsum'
		return scalar Qsum  = `Qsum'
		
		// Return `bystats' matrix
		return matrix bystats = `bystats'

	}	// end if `"`by'"'!=`""'
	
	if `"`overall'"'==`""' {
		return matrix ovstats = `ovstats'
	}
	
	// Error message re prediction intervals with < 3 studies
	if `nrfd' {
		disp as err "Note: Prediction intervals are undefined if less than three studies"
	}
	

	** Generate study-level CIs (unless pre-specified)
	cap nois GenConfInts `invlist' if `touse' & `_USE'==1, ///
		`citype' `df' outvlist(`outvlist') `level'
	if _rc {
		nois disp as err `"Error in {bf:admetan.GenConfInts}"'
		c_local err noerr		// tell admetan not to also report an "error in PerformMetaAnalysis"
		exit _rc
	}

	
	** Finalise numbers of participants
	//   and return k and n (totnpts)
	if `"`_NN'"'!=`""' {
		summ `_NN' if `touse' & `_USE'==1, meanonly
	
		// If pooling was performed, `r(sum)' should exist (stored in `ovstats' or `bystats')
		if `"`ovstats'`bystats'"'!=`""' {
		
			cap assert r(sum)>0 & !missing(r(sum))
			if _rc {
				disp as err "Note: Patient numbers not found"
				c_local _NN				// clear macro _NN, so that by-trial patient numbers are no longer available
			}

			else {
				// Also check if we have same number of values for _NN as there are trials
				// if not, some _NN values must be missing; display warning
				cap assert `r(N)'==`k'
				if _rc {
					if `"`by'"'!=`""' & `"`subgroup'"'==`""' {
						cap assert !`nmiss'
						if !_rc disp as err "Note: Patient numbers are missing in one or more trials"
					}
					if `"`xoutvlist'"'!=`""' {
						disp as err "      " + upper(`cumulative'`influence') + " patient numbers cannot be returned"
						c_local _NN				// clear macro _NN, so that by-trial patient numbers are no longer available
					}
				}
			}
		}		
		else scalar `n' = r(sum)
		return scalar n = cond(`n'==0, ., `n')
	}

	return scalar k = `k'
	
end
	
	
	

	
**********************************************************************

* PrintDesc
// Print descriptive text to screen, above table

program define PrintDesc, sclass
	
	syntax, METHOD(string) MODEL(string) [SUMMSTAT(string) ///
		BYSTATS(name) OVSTATS(name) WGT(varname numeric) LOG LOGRank CUmulative INFluence INTERaction SUMMARYONLY noTABle ///
		BREslow CHI2opt CC(string) CCVAR(name) T TSQLEVEL(passthru) QProfile ISQSA(real 80) TSQSA(real -99) INIT(string) ///
		BYAD SOURCE(passthru) LRVLIST(passthru) ESTEXP(string) EXPLIST(passthru) IPDXLINE(passthru) IPDMETAN ///
		BArtlett HKsj RObust SKovgaard noTRUNCate * ]

	// Build up description of effect estimate type (interaction, cumulative etc.)
	local pooltext = cond(`"`cumulative'"'!=`""', "Cumulative meta-analysis of", ///
		cond(`"`influence'"'!=`""', "Influence meta-analysis of", ///
		cond(`"`ovstats'`bystats'"'!=`""', "Meta-analysis pooling of", "Presented effect estimates are")))
	
	// Again, if passed from -ipdmetan- with "generic" effect measure,
	//   print non-standard text including `estexp':
	if "`estexp'"!="" {
		if `"`interaction'"'!=`""' local pooltext "`pooltext' interaction effect estimate"
		else if `"`explist'"'!=`""' local pooltext "`pooltext' user-specified effect estimate"
		else local pooltext "`pooltext' main (treatment) effect estimate"
		di _n as text "`pooltext'" as res " `estexp'"
	}	

	// Standard -admetan- text:
	else if `"`summstat'"'==`""' {
		if `"`ovstats'`bystats'`ipdmetan'"'!=`""' di _n as text "`pooltext' aggregate data"
	}
	else {
		local logtext = cond(`"`log'"'!=`""', `"log "', `""')		// add a space if `log'
		if "`summstat'"=="rr" local efftext `"`logtext'Risk Ratios"'
		else if "`summstat'"=="irr" local efftext `"`logtext'Incidence Rate Ratios"'
		else if "`summstat'"=="rrr" local efftext `"`logtext'Relative Risk Ratios"'
		else if "`summstat'"=="or"  local efftext `"`logtext'Odds Ratios"'
		else if "`summstat'"=="rd"  local efftext `" Risk Differences"'
		else if "`summstat'"=="hr"  local efftext `"`logtext'Hazard Ratios"'
		else if "`summstat'"=="shr" local efftext `"`logtext'Sub-hazard Ratios"'
		else if "`summstat'"=="tr"  local efftext `"`logtext'Time Ratios"'
		else if "`summstat'"=="wmd" local efftext `" Weighted Mean Differences"'
		else if "`summstat'"=="smd" {
			local efftext " Standardised Mean Differences"
			if "`method'"=="cohen"       local efftextf `" as text " by the method of " as res "Cohen""'
			else if "`method'"=="glass"  local efftextf `" as text " by the method of " as res "Glass""'
			else if "`method'"=="hedges" local efftextf `" as text " by the method of " as res "Hedges""'
		}
			
		// Study-level effect derivation method
		if "`logrank'"!="" local efftext "Peto (logrank) `efftext'"
		else if "`model'"=="fe" & "`method'"=="peto" local efftext "Peto `efftext'"
		di _n as text "`pooltext'" as res " `efftext'" `efftextf' `continue'
	}
	
	if `"`ovstats'`bystats'"'!=`""' {
	
		// fpnote = "NOTE: Weights are from Mantel-Haenszel model"
		// or "NOTE: Weights are from random-effects model"
		// or "NOTE: Weights are user-defined"
		
		// Pooling method (Mantel-Haenszel; fixed-effect; random-effects)
		if "`model'"=="mh" {
			disp as text "using the " as res "Mantel-Haenszel" as text " method"
			local fpnote "NOTE: Weights are from Mantel-Haenszel model"								// for forestplot
		}
		else if !inlist("`model'", "ivhet", "qe") {
			if "`model'"=="fe" local modeltext "fixed-effect inverse-variance"
			else {	
				local modeltext "random-effects inverse-variance"
				if "`model'"!="sa" local fpnote "NOTE: Weights are from random-effects model"		// for forestplot
			}
			local the = cond("`model'"=="qe", "", "the ")		
			disp as text `"using `the'"' as res `"`modeltext'"' as text " model"
		}
		
		// Doi's IVHet and Quality Effects models
		else {
			local modeltext = cond("`model'"=="ivhet", "Doi's IVHet", "Doi's Quality Effects")
			disp as text "using " as res `"`modeltext'"' as text " model"
			local fpnote `"NOTE: Weights are from `modeltext' model"'								// for forestplot
		}	
		
		// Profile likelihood
		if "`model'"=="pl" {
			local continue = cond(`"`bartlett'`skovgaard'"'!=`""', "_c", "")
			disp as text `"estimated using "' as res "Profile Likelihood" `continue'
			if "`bartlett'"!="" disp as text " with " as res `"Bartlett's correction"'
			else if "`skovgaard'"!="" disp as text " with " as res `"Skovgaard's correction"'
		}	
			
		// Gamma alternative weighting
		else if "`model'"=="gamma" {
			disp as text `"with "' as res "Biggerstaff-Tweedie approximate Gamma" as text `" weighting"'
		}

		// HKSJ and SJ Robust variance estimators
		else if `"`hksj'`robust'"'!=`""' {
			if "`hksj'"!="" {
				if "`truncate'"!="" local vcetext "(untruncated) "
				local vcetext "`vcetext'Hartung-Knapp-Sidik-Jonkman"
			}
			else local vcetext "Sidik-Jonkman robust"
			disp as text "with the " as res "`vcetext'" as text " variance estimator"
		}
		
		// Kenward-Roger variance correction
		else if "`model'"=="kr" {
			disp as text "with " as res "Kenward-Roger" as text " variance correction"
		}		
			
		// Henmi-Copas
		else if "`model'"=="hc" {
			disp as text "estimated using " as res `"Henmi and Copas's approximate exact distribution"'
		}
		
		// Multiplicative heterogeneity model
		else if "`model'"=="mu" {
			disp as text "with " as res `"multiplicative heterogeneity"'
		}
		
		// Two-step estimators
		else if "`model'"=="sj2s" {
			disp as text "with the " as res `"Sidik-Jonkman two-step tau{c 178} estimator"'
		}
		else if "`model'"=="dk2s" {
			disp as text "with the " as res `"DerSimonian-Kacker two-step tau{c 178} estimator"'
		}

		// Estimators of tausq
		if !inlist("`model'", "mh", "fe", "mu") {
			if inlist("`model'", "dl", "gamma", "ivhet", "qe", "hc") local tsqtext "DerSimonian-Laird"
			else if "`model'"=="dlb"  local tsqtext "Bootstrap DerSimonian-Laird"
			else if "`model'"=="mp"   local tsqtext "Mandel-Paule"
			else if "`model'"=="vc"   local tsqtext `"Cochran's ANOVA-type (Hedges')"'
			else if "`model'"=="ev"   local tsqtext "Empirical variance"
			else if "`model'"=="hm"   local tsqtext "Hartung-Makambi"
			else if inlist("`model'", "ml",   "pl") local tsqtext "ML"
			else if inlist("`model'", "reml", "kr") local tsqtext "REML"
			else if "`model'"=="bp"   local tsqtext "Rukhin's BP"
			else if "`model'"=="b0"   local tsqtext "Rukhin's B0"
		
			local linktext = cond(`"`hksj'`robust'"'!=`""' | inlist("`model'", "pl", "gamma", "ivhet", "qe", "kr", "hc"), "based on", "with")
			
			// Sensitivity analysis
			if "`model'"=="sa" {
				disp as text "Sensitivity analysis with user-defined " _c
				if `tsqsa'==-99 {
					disp "I{c 178} = " as res "`isqsa'%"
					local fpnote `"Sensitivity analysis with user-defined I{c 178}"'
				}
				else {
					disp "tau{c 178} = " as res "`tsqsa'"
					local fpnote `"Sensitivity analysis with user-defined tau{c 178}"'
				}
			}
			
			// Two-step estimators
			else if inlist("`model'", "sj2s", "dk2s") {
				disp as text `"with "' as res upper(`"`init'"') as text `" initial estimate of tau{c 178}"'
			}
			
			// Default
			else disp as text `"`linktext' "' as res `"`tsqtext'"' as text `" estimate of tau{c 178}"'
		}
	}		// end if `"`ovstats'`bystats'"'!=`""' 
	
	// User-defined weights
	if "`wgt'" != "" {
		local wgttitle : variable label `wgt'
		if `"`wgttitle'"'==`""' local wgttitle `wgt'
		
		if `"`ovstats'`bystats'"'!=`""' {
			disp as text "and with user-defined weights " as res `"`wgttitle'"'
		}
		else disp as text "Weights " as res `"`wgttitle'"' as text " are user-defined"
		
		if `"`fpnote'"'!=`""' local fpnote `"`fpnote' and with user-defined weights"'
		else local fpnote `"NOTE: Weights are user-defined"'
	}
		
	// Jan 2019: Continuity correction
	// (also user-defined weights even if no ovstats/bystats??)
	cap confirm numeric var `ccvar'
	if !_rc {
		local 0 `cc'
		syntax [anything(id="value supplied to {bf:cc()}")] [, OPPosite EMPirical]
		local ccval = `anything'
		
		if `"`opposite'"'!=`""' disp as text _n "Opposite-arm continuity correction" _c
		else if `"`empirical'"'!=`""' disp as text _n "Empirical continuity correction" _c
		else disp as text _n "Continuity correction of " as res %4.2f `ccval' _c
		disp as text " applied to studies with zero cells"
		if `"`summaryonly'`table'"'==`""' {
			disp as text "(marked with " as res "*" as text ")"
		}
		
		if `"`fpnote'"'!=`""' local fpnote `"`fpnote'; continuity correction applied to studies with zero cells"'
		else local fpnote `"NOTE: Continuity correction applied to studies with zero cells"'
	}	
	
	sreturn local fpnote `"`fpnote'"'
	
	// Finally: simplify the contents of `opts_model' and `opts_ipdm' in the main -admetan- routine
	//   removing options which are no longer needed.
	// Needs to be done here, since neither DrawTable nor BuildResultsSet will necessarily be run.
	sreturn local opts_table `"`breslow' `chi2opt' `t' `z' `tsqlevel' `qprofile'"'
	sreturn local opts_ipdm  `"`byad' `source' `lrvlist' `ipdxline'"'
	sreturn local tsqlevel   `"`tsqlevel'"'		// needed by BuildResultsSet, so return separately
	
end




*******************************************************

* Routine to draw output table (admetan.ado version)
// Could be done using "tabdisp", but doing it myself means it can be tailored to the situation
// therefore looks better (I hope!)

program define DrawTableAD, rclass sortpreserve

	// N.B. no max in varlist() since xoutvlist may contain extra vars e.g. tausq/sigmasq, which are not relevant here
	syntax varlist(numeric min=6 /*max=7*/) [if] [in], METHOD(string) MODEL(string) SORTBY(varlist) ///
		[CUmulative INFluence noOVerall noSUbgroup SUMMARYONLY OVWt SGWt WGT(varname numeric) ///
		LABELS(varname string) STITLE(string asis) ETITLE(string asis) CC(string) CCVAR(name) ///
		STUDY(varname numeric) BY(varname numeric) BYSTATS(name) OVSTATS(name) ///
		EFORM T BREslow CHI2opt QProfile noTABle noHET noKEEPVars KEEPOrder LEVEL(real 95) TSQLEVEL(real 95)]
		
	marksample touse, novarlist		// -novarlist- option prevents -marksample- from setting `touse' to zero if any missing values in `varlist'

	// unpack varlist
	tokenize `varlist'
	args _USE _ES _seES _LCI _UCI _WT _NN
	
	// Maintain original order if requested
	if `"`keeporder'"'!=`""' {
		tempvar tempuse
		qui gen byte `tempuse' = `_USE'
		qui replace `tempuse' = 1 if `_USE'==2		// keep "insufficient data" studies in original study order (default is to move to end)
	}
	else local tempuse `_USE'
	
	
	** Now, if `nokeepvars' specified (including if called by -ipdmetan-)
	//  re-create `obs', sorting by `sortby', and create matrix of coefficients
	// (N.B. not done earlier as want to take account of `keepall' & `keeporder')
	tempvar obs	
	if `"`keepvars'"'!=`""' {
		qui count if `touse'
		if r(N) > c(matsize) {
			disp as err `"matsize too small to store matrix of study coefficients; this step will be skipped"'
			disp as err `"  (see {bf:help matsize})"'
			sort `touse' `by' `tempuse' `sortby'			
		}
		
		else {
			// create `study' if missing
			if `"`study'"'==`""' {
				tempvar study
				qui gen long `obs' = _n
				qui bysort `touse' (`obs'): gen long `study' = _n if `touse'
				drop `obs'
			}
			sort `touse' `by' `tempuse' `sortby'
			
			tempname coeffs
			mkmat `by' `study' `_ES' `_seES' `_NN' `_WT' if `touse', matrix(`coeffs')

			local _BYexist = cond( `"`by'"'!=`""', "_BY", "")
			local _NNexist = cond(`"`_NN'"'!=`""', "_NN", "")
			local _WTexist = cond(`"`_WT'"'!=`""', "_WT", "")
			matrix colnames `coeffs' = `_BYexist' _STUDY _ES _seES `_NNexist' `_WTexist'
			return matrix coeffs = `coeffs'
		}
	}
	else sort `touse' `by' `tempuse' `sortby'			// to avoid sorting twice
	qui gen long `obs' = _n

	
	** Create table of results
	
	// do this beforehand in case of `"`table'"'==`""'
	if `"`by'"'!=`""' {
		qui levelsof `by' if `touse', missing local(bylist)		// "missing" since `touse' should already be appropriate for missing yes/no
		local bylab : value label `by'
	}
	local nby = max(1, `: word count `bylist'')
	
	local swidth = 21				// define `swidth' in case noTAB
	tempname _ES_ _seES_			// will need these two regardless of `table'
	if `"`table'"'==`""' {

		* Find maximum length of labels in LHS column
		tempvar vlablen
		qui gen long `vlablen' = length(`labels')
		
		cap confirm numeric var `ccvar'
		if !_rc {
			qui replace `vlablen' = `vlablen' + 2 if `ccvar'	// for a space and asterisk if cc
		}
		if `"`by'"'!=`""' {
			tempvar bylabels
			cap decode `by', gen(`bylabels')
			if _rc local bylabels `"string(`by')"'
			qui replace `vlablen' = max(`vlablen', length(`bylabels'))
			cap drop `bylabels'
		}
		summ `vlablen' if `touse', meanonly
		local lablen=r(max)
		drop `vlablen'
	
		* Find maximum length of study title and effect title
		//  Allow them to spread over several lines, but only up to a maximum number of chars
		//  If a single line must be more than 32 chars, truncate and stop
		local uselen = 20										// default (minimum); max is 32
		if `lablen'>20 local uselen = min(`lablen', 31)
		SpreadTitle `"`stitle'"', target(`uselen') maxwidth(31)		// study (+ subgroup) title
		local swidth = 1 + max(`uselen', `r(maxwidth)')
		local slines = r(nlines)
		forvalues i=1/`slines' {
			local stitle`i' `"`r(title`i')'"'
		}
		SpreadTitle `"`etitle'"', target(10) maxwidth(15)		// effect title (i.e. "Odds ratio" etc.)
		local ewidth = 1 + max(10, `r(maxwidth)')
		local elines = r(nlines)
		local diff = `elines' - `slines'
		if `diff'<=0 {
			forvalues i=1/`slines' {
				local etitle`i' `"`r(title`=`i'+`diff'')'"'		// stitle uses most lines (or equal): line up etitle with stitle
			}
		}
		else {
			forvalues i=`elines'(-1)1 {					// run backwards, otherwise macros are deleted by the time they're needed
				local etitle`i' `"`r(title`i')'"'
				local stitle`i' = cond(`i'>=`diff', `"`stitle`=`i'-`diff'''"', `""')	// etitle uses most lines: line up stitle with etitle
			}
		}
		
		* Now display the title lines, starting with the "extra" lines and ending with the row including CI & weight
		local wwidth = 11
		
		di as text _n `"{hline `swidth'}{c TT}{hline `=`ewidth'+24+`wwidth''}"'
		local nl = max(`elines', `slines')
		if `nl' > 1 {
			forvalues i=1/`=`nl'-1' {
				di as text `"`stitle`i''{col `=`swidth'+1'}{c |} "' %~`ewidth's `"`etitle`i''"'
			}
		}
		di as text `"`stitle`nl''{col `=`swidth'+1'}{c |} "' ///
			%~10s `"`etitle`nl''"' `"{col `=`swidth'+`ewidth'+4'}[`level'% Conf. Interval]{col `=`swidth'+`ewidth'+27'}% Weight"'


		** Loop over studies, and subgroups if appropriate
	
		tempvar touse2
		gen byte `touse2' = `touse'
		
		tempname _LCI_ _UCI_ _WT_ critval
		local xexp = cond("`eform'"!="", "exp", "")

		forvalues i=1/`nby' {				// this will be 1/1 if no subgroups

			di as text `"{hline `swidth'}{c +}{hline `=`ewidth'+24+`wwidth''}"'

			if `"`by'"'!=`""' {
				local byi : word `i' of `bylist'
				qui replace `touse2' = `touse' * (`by'==`byi')
				
				if `"`bylab'"'!=`""' {
					local bylabi : label `bylab' `byi'
				}
				else local bylabi `"`byi'"'
				
				if `"`bystats'"'!=`""' {
					if missing(`bystats'[rownumb(`bystats', "Qdf"), `i']) {
						local nodata `"{col `=`swidth'+4'} (No subgroup data)"'
					}
				}
				di as text substr(`"`bylabi'"', 1, `swidth'-1) + `"{col `=`swidth'+1'}{c |}`nodata'"'
				local nodata	// clear macro
			}

			summ `obs' if `touse2' & inlist(`_USE', 1, 2), meanonly
			if r(N) & `"`summaryonly'"'==`""' {
				forvalues k = `r(min)' / `r(max)' {
					if missing(`_ES'[`k']) {
						di as text substr(`labels'[`k'], 1, 32) `"{col `=`swidth'+1'}{c |}{col `=`swidth'+4'} (Insufficient data)"'
					}
					else {
						scalar `_ES_'  = `_ES'[`k']
						scalar `_LCI_' = `_LCI'[`k']
						scalar `_UCI_' = `_UCI'[`k']
						scalar `_WT_'  = `_WT'[`k']
						
						local _labels_ = `labels'[`k']
						local _cc_
						
						local lwidth = 32
						cap confirm numeric var `ccvar'
						if !_rc {
							if `ccvar'[`k'] local _cc_ `" *"'
							local lwidth = 30
						}
						di as text substr(`"`_labels_'"', 1, `lwidth') as res `"`_cc_'"' ///
							as text `"{col `=`swidth'+1'}{c |}{col `=`swidth'+`ewidth'-6'}"' ///
							as res %7.3f `xexp'(`_ES_') `"{col `=`swidth'+`ewidth'+5'}"' ///
							as res %7.3f `xexp'(`_LCI_') `"{col `=`swidth'+`ewidth'+15'}"' ///
							as res %7.3f `xexp'(`_UCI_') `"{col `=`swidth'+`ewidth'+26'}"' ///
							as res %7.2f `_WT_'
					}
				}
			}

			* Subgroup effects
			if `"`by'"'!=`""' & `"`subgroup'"'==`""' & `"`cumulative'"'==`""' {
				di as text `"{col `=`swidth'+1'}{c |}"'
				
				scalar `_ES_' = `bystats'[rownumb(`bystats', "eff"), `i']
				if missing(`_ES_') {
					di as text `"Subgroup effect{col `=`swidth'+1'}{c |}{col `=`swidth'+4'} (Insufficient data)"'
				}
				else {
					scalar `_LCI_' = `bystats'[rownumb(`bystats', "eff_lci"), `i']
					scalar `_UCI_' = `bystats'[rownumb(`bystats', "eff_uci"), `i']
					
					// subgroup sum of (normalised) weights: will be 1 unless `ovwt'
					if `"`ovwt'"'!=`""' {
						local byi: word `i' of `bylist'	
						summ `_WT' if `touse' & `_USE'==1 & `by'==`byi', meanonly
						scalar `_WT_' = r(sum)
					}
					else scalar `_WT_' = 100

					di as text `"Subgroup effect{col `=`swidth'+1'}{c |}{col `=`swidth'+`ewidth'-6'}"' ///
						as res %7.3f `xexp'(`_ES_') `"{col `=`swidth'+`ewidth'+5'}"' ///
						as res %7.3f `xexp'(`_LCI_') `"{col `=`swidth'+`ewidth'+15'}"' ///
						as res %7.3f `xexp'(`_UCI_') `"{col `=`swidth'+`ewidth'+26'}"' %7.2f `_WT_'
				}
			}
		}		// end forvalues i=1/`nby'
		
		drop `touse2'	// tidy up
			

		* Overall effect
		
		if `"`overall'"'==`""' & `"`cumulative'"'==`""' {
			if !(`"`summaryonly'"'!=`""' & `nby'==1) {
				di as text `"{hline `swidth'}{c +}{hline `=`ewidth'+24+`wwidth''}"'
			}
		
			scalar `_ES_' = `ovstats'[rownumb(`ovstats', "eff"), 1]
			if missing(`_ES_') {
				di as text `"Overall effect{col `=`swidth'+1'}{c |}{col `=`swidth'+4'} (Insufficient data)"'
			}
			else {
				scalar `_LCI_' = `ovstats'[rownumb(`ovstats', "eff_lci"), 1]
				scalar `_UCI_' = `ovstats'[rownumb(`ovstats', "eff_uci"), 1]
				
				// N.B. sum of (normalised) weights: will be 1 unless `sgwt'
				scalar `_WT_' = cond(`"`sgwt'"'!=`""', ., 100)
				di as text %-20s `"Overall effect{col `=`swidth'+1'}{c |}{col `=`swidth'+`ewidth'-6'}"' ///
					as res %7.3f `xexp'(`_ES_') `"{col `=`swidth'+`ewidth'+5'}"' ///
					as res %7.3f `xexp'(`_LCI_') `"{col `=`swidth'+`ewidth'+15'}"' ///
					as res %7.3f `xexp'(`_UCI_') `"{col `=`swidth'+`ewidth'+26'}"' %7.2f `_WT_'
			}
		}
		di as text `"{hline `swidth'}{c BT}{hline `=`ewidth'+24+`wwidth''}"'
	
	}	// end if `"`table'"'==`""'

	
	** Test statistics and p-values

	local xtext = cond(`"`cumulative'"'!=`""', `"cumulative "', `""')		// n/a for influence
	local null = (`"`eform'"'!=`""')										// test of pooled effect equal to zero

	tempname testStat tdf pvalue
	
	// display by subgroup [Oct 2018: modified to take values from matrix `ovstats']
	if `"`by'"'!=`""' & `"`subgroup'"'==`""' {
		di as text _n `"Tests of `xtext'effect size = "' as res `null' as text ":"

		forvalues i=1/`nby' {
			local byi: word `i' of `bylist'
			if `"`bylab'"'!=`""' {
				local bylabi : label `bylab' `byi'
			}
			else local bylabi `byi'

			scalar `_ES_'   = `bystats'[rownumb(`bystats', "eff"), `i']
			scalar `_seES_' = `bystats'[rownumb(`bystats', "se_eff"), `i']				
			
			* Test statistic and p-value
			scalar `testStat' = `_ES_' / `_seES_'					// default			
			if "`chi2opt'"!="" scalar `testStat' = `bystats'[rownumb(`bystats', "chi2"), `i']
			else if "`model'"=="hc" scalar `testStat' = `bystats'[rownumb(`bystats', "u"), `i']
			if "`model'"=="kr" {
				scalar `tdf' = `bystats'[rownumb(`bystats', "df_kr"), `i']
			}
			else scalar `tdf' = `bystats'[rownumb(`bystats', "Qdf"), `i']			
			scalar `pvalue' = `bystats'[rownumb(`bystats', "pvalue"), `i']				
			
			// Text to display: chisq distribution
			if "`chi2opt'"!="" {
				if "`model'"=="pl" local lrtext "LR "
				local testDist "`lrtext'chi{c 178}"
				local testStat_text `"%6.2f `testStat'"'
				local df_text `"" on " as res 1 as text " df,""'
			}			

			// t distribution
			else if "`t'"!="" & `tdf'>0 & !missing(`tdf') {
				local testDist t
				local testStat_text `"%7.3f `testStat'"'
				local df_fmt = cond("`model'"=="kr", "%6.2f", "%3.0f")
				local df_text `"" on " as res `df_fmt' `tdf' as text " df,""'
			}
			
			// Henmi & Copas distribution
			else if "`model'"=="hc" {
				local testDist u
				local testStat_text `"%7.3f `testStat'"'
			}

			// normal (z) distribution
			else {
				local testDist z
				local testStat_text `"%7.3f `testStat'"'
				if "`t'"!="" {		// if other subgroups use t, leave gap so as to line up
					local df_fmt = cond("`model'"=="kr", "%6.2f", "%3.0f")
					local df_text `"`"`: disp _dup(`=8 + cond("`model'"=="kr", 6, 3)') " "'"'"'
				}
			}

			if missing(`testStat') {
				di as text substr("`bylabi'", 1, `swidth'-1) `"{col `=`swidth'+1'}(Insufficient data)"'
			}
			else {
				di as text substr("`bylabi'", 1, `swidth'-1) `"{col `=`swidth'+1'}"' as res "`testDist'" as text " = " as res `testStat_text' as text `df_text' "  p = " as res %5.3f `pvalue'
			}
		}
	}
	
	// display overall [Oct 2018: modified to take values from matrix `ovstats']
	if `"`overall'"'==`""' {
	
		scalar `_ES_'   = `ovstats'[rownumb(`ovstats', "eff"), 1]
		scalar `_seES_' = `ovstats'[rownumb(`ovstats', "se_eff"), 1]	
		
		* Test statistic and p-value
		scalar `testStat' = `_ES_' / `_seES_'			// default			
		if "`chi2opt'"!="" scalar `testStat' = `ovstats'[rownumb(`ovstats', "chi2"), 1]
		else if "`model'"=="hc" scalar `testStat' = `ovstats'[rownumb(`ovstats', "u"), 1]
		if "`model'"=="kr" {
			scalar `tdf' = `ovstats'[rownumb(`ovstats', "df_kr"), 1]
		}
		else scalar `tdf' = `ovstats'[rownumb(`ovstats', "Qdf"), 1]
		scalar `pvalue' = `ovstats'[rownumb(`ovstats', "pvalue"), 1]

		// Text to display: chisq distribution
		if !missing(rownumb(`ovstats', "chi2")) {
			scalar `testStat' = `ovstats'[rownumb(`ovstats', "chi2"), 1]
			local testDist "`lrtext'chi{c 178}"
			local testStat_text `"%6.2f `testStat'"'
			local df_text `"" on " as res 1 as text " df,""'
		}
		
		// Likelihood ratio statistic
		else if !missing(rownumb(`ovstats', "lr_chi2")) {
			scalar `testStat' = `ovstats'[rownumb(`ovstats', "lr_chi2"), 1]
			local testDist "LR chi{c 178}"
			local testStat_text `"%6.2f `testStat'"'
			local df_text `"" on " as res 1 as text " df,""'
		}

		// Signed log-likelihood statistic
		else if !missing(rownumb(`ovstats', "lr_z")) {
			scalar `testStat' = `ovstats'[rownumb(`ovstats', "lr_z"), 1]
			local testDist "Signed log-lik."
			local testStat_text `"%7.3f `testStat'"'
		}

		// t distribution
		else if "`t'"!="" & `tdf'>0 & !missing(`tdf') {
			local testDist t
			local testStat_text `"%7.3f `testStat'"'
			local df_fmt = cond("`model'"=="kr", "%6.2f", "%3.0f")
			local df_text `"" on " as res `df_fmt' `tdf' as text " df,""'
		}
		
		// Henmi & Copas distribution
		else if "`model'"=="hc" {
			local testDist u
			local testStat_text `"%7.3f `testStat'"'
		}

		// normal (z) distribution
		else {
			local testDist z
			local testStat_text `"%7.3f `testStat'"'
		}

		if missing(`testStat') {
			di as text `"Overall{col `=`swidth'+1'}(Insufficient data)"'
		}
		else {
			if `"`by'"'!=`""' & `"`subgroup'"'==`""' {
				di as text `"Overall{col `=`swidth'+1'}"' as res "`testDist'" as text " = " as res `testStat_text' as text `df_text' "  p = " as res %5.3f `pvalue'
			}
			else { 
				di as text _n `"Test of overall `xtext'effect = "' as res `null' as text ":  " as res "`testDist'" as text " = " ///
					as res `testStat_text' as text `df_text' "  p = " as res %5.3f `pvalue'			
			}
		}
	}

	
	** Heterogeneity statistics
	
	summ `_ES' if `touse' & `_USE'==1, meanonly
	local het = cond(`r(N)'==1, "nohet", "`het'")		// don't present overall het stats if only one estimate

	if `"`het'"'==`""' {

		if "`model'"=="sa" {
			local hetextra `"(user-defined"'
			if "`wgt'"!="" local hetextra `"; based on standard inverse-variance weights"'
			local hetextra `"`hetextra')"'
		}
		else {
			if "`model'"=="mu" local hetextra `"(based on DerSimonian-Laird heterogeneity estimator"'
			else {
				local statsmat = cond(`"`ovstats'"'!=`""', `"`ovstats'"', `"`bystats'"')
				if missing(rownumb(`statsmat', "tausq")) {
					local stattxt = cond("`method'"=="mh", "Mantel-Haenszel Q", ///
						cond("`method'"=="peto", "Peto Q", "Cochran's Q"))
					local hetextra `"(based on `stattxt'"'
				}
			}
			if "`wgt'"!="" local hetextra `" and on standard inverse-variance weights"'
			if "`hetextra'"!="" local hetextra `"`hetextra')"'
		}

		
		* Heterogeneity measures box: no subgroups
		if `"`overall'"'==`""' {

			tempname Q_ov Qdf_ov Qpval_ov
			scalar `Q_ov' =   `ovstats'[rownumb(`ovstats', "Q"), 1]
			scalar `Qdf_ov' = `ovstats'[rownumb(`ovstats', "Qdf"), 1]
			scalar `Qpval_ov' = chi2tail(`Qdf_ov', `Q_ov')

			tempname Isq HsqM
			scalar `Isq' =  `ovstats'[rownumb(`ovstats', "Isq"), 1]
			scalar `HsqM' = `ovstats'[rownumb(`ovstats', "HsqM"), 1]
			
			if !missing(rownumb(`ovstats', "tausq")) {
				tempname tausq sigmasq
				scalar `tausq'   = `ovstats'[rownumb(`ovstats', "tausq"), 1]
				scalar `sigmasq' = `ovstats'[rownumb(`ovstats', "sigmasq"), 1]
			}
			
			if !(`"`by'"'!=`""' & `"`subgroup'"'==`""') {
				di as text _n(2) `"Heterogeneity Measures `hetextra'"'

				local stattxt = cond("`breslow'"!="", "Breslow-Day test", ///
					cond("`method'"=="mh", "Mantel-Haenszel Q", ///
					cond("`method'"=="peto", "Peto Q", "Cochran's Q")))
				
				// Sensitivity analysis: only one column
				if "`model'"=="sa" {
					di as text "{hline `swidth'}{c TT}{hline 13}"
					di as text `"{col `=`swidth'+1'}{c |}{col `=`swidth'+7'}Value"'
					di as text "{hline `swidth'}{c +}{hline 13}"
					
					di as text `"I{c 178} (%) {col `=`swidth'+1'}{c |}{col `=`swidth'+4'}"' as res %7.1f `Isq' "%"
					di as text `"Modified H{c 178} {col `=`swidth'+1'}{c |}{col `=`swidth'+5'}"' as res %7.3f `HsqM'
					di as text `"tau{c 178} {col `=`swidth'+1'}{c |}{col `=`swidth'+4'}"' as res %8.4f `tausq'
					
					di as text `"{hline `swidth'}{c BT}{hline 13}"'
				}
				
				// Single table; no tau-squared confidence intervals
				else if missing(rownumb(`ovstats', "tsq_lci")) {
				
					local hetwidth = cond("`model'"=="sa", 13, 35)
					di as text `"{hline `swidth'}{c TT}{hline `hetwidth'}"'
					di as text `"{col `=`swidth'+1'}{c |}{col `=`swidth'+7'}Value{col `=`swidth'+18'}df{col `=`swidth'+25'}p-value"'
					di as text `"{hline `swidth'}{c +}{hline `hetwidth'}"'
					
					di as text `"`stattxt' {col `=`swidth'+1'}{c |}{col `=`swidth'+5'}"' ///
						as res %7.2f `Q_ov' `"{col `=`swidth'+16'}"' %3.0f `Qdf_ov' `"{col `=`swidth'+23'}"' %7.3f `Qpval_ov'			
					
					// di as text "I{c 178} (%) {col `=`swidth'+1'}{c |}{col `=`swidth'+4'}" as res %7.1f 100*`isq' "%"		// altered Sep 2017 for v2.1 to match with metan/metaan behaviour
					di as text `"I{c 178} (%) {col `=`swidth'+1'}{c |}{col `=`swidth'+4'}"' as res %7.1f `Isq' "%"
					di as text `"Modified H{c 178} {col `=`swidth'+1'}{c |}{col `=`swidth'+5'}"' as res %7.3f `HsqM'
					
					if !missing(rownumb(`ovstats', "tausq")) {
						di as text `"tau{c 178} {col `=`swidth'+1'}{c |}{col `=`swidth'+4'}"' as res %8.4f `tausq'
					}
				}
				
				// Tau-squared confidence intervals: separate table for Q
				else {
					di as text `"{hline `swidth'}{c TT}{hline 35}"'
					di as text `"{col `=`swidth'+1'}{c |}{col `=`swidth'+7'}chi2{col `=`swidth'+18'}df{col `=`swidth'+25'}p-value"'				
					di as text `"{hline `swidth'}{c +}{hline 35}"'
					di as text `"`stattxt' {col `=`swidth'+1'}{c |}{col `=`swidth'+5'}"' ///
						as res %7.2f `Q_ov' `"{col `=`swidth'+16'}"' %3.0f `Qdf_ov' `"{col `=`swidth'+23'}"' %7.3f `Qpval_ov'
					di as text `"{hline `swidth'}{c BT}{hline 35}"'
					
					// March 2018: describe method for generating tausq confidence interval
					if "`model'"=="mp" | "`qprofile'"!="" local tsqci "Q profile"
					else if "`model'"=="dlb" local tsqci "Bootstrap"
					else if inlist("`model'", "ml", "pl", "reml") local tsqci "Profile Likelihood"
					else if "`model'"=="gamma" local tsqci "Approximate Gamma"
					
					di as text _n `"Confidence Intervals generated using "' as res "`tsqci'" as text " method"
					di as text `"{hline `swidth'}{c TT}{hline 35}"'
					di as text `"{col `=`swidth'+1'}{c |}{col `=`swidth'+7'}Value{col `=`swidth'+15'}[`tsqlevel'% Conf. Interval]"'
					di as text `"{hline `swidth'}{c +}{hline 35}"'

					// altered Sep 2018 to take values from matrix `ovstats'
					tempname tsq_lci tsq_uci Isq_lci Isq_uci HsqM_lci HsqM_uci
					scalar `tsq_lci' = `ovstats'[rownumb(`ovstats', "tsq_lci"), 1]
					scalar `tsq_uci' = `ovstats'[rownumb(`ovstats', "tsq_uci"), 1]
					scalar `Isq_lci'  = 100*`tsq_lci'/(`tsq_lci' + `sigmasq')
					scalar `Isq_uci'  = 100*`tsq_uci'/(`tsq_uci' + `sigmasq')
					scalar `HsqM_lci' = `tsq_lci'/`sigmasq'
					scalar `HsqM_uci' = `tsq_uci'/`sigmasq'
					
					di as text `"I{c 178} (%) {col `=`swidth'+1'}{c |}{col `=`swidth'+4'}"' ///
						as res %7.1f `Isq' `"%{col `=`swidth'+14'}"' ///
						as res %7.1f `Isq_lci' `"%{col `=`swidth'+24'}"' %7.1f `Isq_uci' "%"
					
					di as text `"Modified H{c 178} {col `=`swidth'+1'}{c |}{col `=`swidth'+5'}"' ///
						as res %7.3f `HsqM' `"{col `=`swidth'+15'}"' ///
						as res %7.3f `HsqM_lci' `"{col `=`swidth'+25'}"' %7.3f `HsqM_uci'
					
					di as text `"tau{c 178} {col `=`swidth'+1'}{c |}{col `=`swidth'+4'}"' ///
						as res %8.4f `tausq' `"{col `=`swidth'+14'}"' ///
						as res %8.4f `tsq_lci' `"{col `=`swidth'+24'}"' %8.4f `tsq_uci'
				}
				
				if "`model'"!="sa" di as text `"{hline `swidth'}{c BT}{hline 35}"'
					
				// Display explanations
				if !missing(rownumb(`ovstats', "tausq")) {
					di as text _n `"I{c 178} = between-study variance (tau{c 178}) as a percentage of total variance"'
					di as text `"Modified H{c 178} = ratio of tau{c 178} to typical within-study variance"'
				}
			}		// end if !(`"`by'"'!=`""' & `"`subgroup'"'==`""')
		}		// end if `"`overall'"'==`""'

		
		* Heterogeneity measures box: subgroups (just present Q statistics)
		if `"`by'"'!=`""' & `"`subgroup'"'==`""' {

			local stattxt = cond("`breslow'"!="", "Breslow-Day homogeneity statistics", ///
				cond("`method'"=="mh", "Mantel-Haenszel Q", ///
				cond("`method'"=="peto", "Peto Q", "Cochran Q")))
			if "`breslow'"=="" local stattxt "`stattxt' statistics for heterogeneity"
			
			di as text _n(2) "`stattxt'"
			di as text `"{hline `swidth'}{c TT}{hline 35}"'
			di as text `"{col `=`swidth'+1'}{c |}{col `=`swidth'+7'}Value{col `=`swidth'+17'}df{col `=`swidth'+24'}p-value"'
			di as text `"{hline `swidth'}{c +}{hline 35}"'

			tempname Qsum Qi Qdfi Qpvali
			scalar `Qsum' = 0
			forvalues i=1/`nby' {
				local byi : word `i' of `bylist'
				if `"`bylab'"'!=`""' {
					local bylabi : label `bylab' `byi'
				}
				else local bylabi `"`byi'"'
				if `"`bylabi'"'!="." local bylabi = substr(`"`bylabi'"', 1, `swidth'-1)

				scalar `Qi'   = `bystats'[rownumb(`bystats', "Q"), `i']
				scalar `Qdfi' = `bystats'[rownumb(`bystats', "Qdf"), `i']
				if !missing(`Qi') {
					scalar `Qpvali' = chi2tail(`Qdfi', `Qi')
					local dfcol = cond(`"`overall'"'==`""', 18, 16)
					di as text `"`bylabi'{col `=`swidth'+1'}{c |}{col `=`swidth'+5'}"' ///
						as res %7.2f `Qi' `"{col `=`swidth'+`dfcol''}"' %3.0f `Qdfi' `"{col `=`swidth'+23'}"' %7.3f `Qpvali'
				}
				else di as text `"`bylabi'{col `=`swidth'+1'}{c |}{col `=`swidth'+5'}(Insufficient data)"'
				
				scalar `Qsum' = `Qsum' + `Qi'
			}	// end forvalues i=1/`nby'
				
			if `"`overall'"'==`""' {
				tempname Qdiff Fstat
				scalar `Qdiff' = `Q_ov' - `Qsum'		// between-subgroup heterogeneity (Qsum = within-subgroup het.)
				scalar `Fstat' = (`Qdiff'/(`nby' - 1)) / (`Qsum'/(`Qdf_ov' - `nby' + 1))		// corrected 17th March 2017
				
				di as text `"Overall{col `=`swidth'+1'}{c |}{col `=`swidth'+5'}"' ///
					as res %7.2f `Q_ov' `"{col `=`swidth'+18'}"' %3.0f `Qdf_ov' `"{col `=`swidth'+23'}"' %7.3f `Qpval_ov'

				local Qdiffpval = chi2tail(`nby'-1, `Qdiff')
				di as text `"Between{col `=`swidth'+1'}{c |}{col `=`swidth'+5'}"' ///
					as res %7.2f `Qdiff' `"{col `=`swidth'+18'}"' %3.0f `nby'-1 `"{col `=`swidth'+23'}"' %7.3f `Qdiffpval'
					
				local Fpval = Ftail(`nby' - 1, `Qdf_ov' - `nby' + 1, `Fstat')
				di as text `"Between:Within (F){col `=`swidth'+1'}{c |}{col `=`swidth'+5'}"' ///
					as res %7.2f `Fstat' `"{col `=`swidth'+14'}"' %3.0f `nby' - 1 as text "," as res %3.0f `Qdf_ov' - `nby' + 1 `"{col `=`swidth'+23'}"' %7.3f `Fpval'
			}
			di as text `"{hline `swidth'}{c BT}{hline 35}"'
		}
	}	// end if `"`het'"'==`""'

end




**************************

* Subroutine to "spread" titles out over multiple lines if appropriate
// Updated July 2014
// Copied directly to updated version of admetan.ado September 2015 without modification
// August 2016: identical program now used here, in forestplot.ado, and in ipdover.ado 
// May 2017: updated to accept substrings delineated by quotes (c.f. multi-line axis titles)
// August 2017: updated for better handling of maxlines()
// March 2018: updated to receive text in quotes, hence both avoiding parsing problems with commas, and maintaining spacing
// May 2018 and Nov 2018: updated truncation procedure

// subroutine of DrawTableAD

program define SpreadTitle, rclass

	syntax [anything(name=title id="title string")] [, TArget(integer 0) MAXWidth(integer 0) MAXLines(integer 0) noTRUNCate noUPDATE ]
	* Target = aim for this width, but allow expansion if alternative is wrapping "too early" (i.e before line is adequately filled)
	//         (may be replaced by `titlelen'/`maxlines' if `maxlines' and `notruncate' are also specified)
	* Maxwidth = absolute maximum width ... but will be increased if a "long" string is encountered before the last line
	* Maxlines = maximum no. lines (default 3)
	* noTruncate = don't truncate final line if "too long" (even if greater than `maxwidth')
	* noUpdate = don't update `target' if `maxwidth' is increased (see above)
	
	tokenize `title'
	if `"`1'"'==`""' {
		return scalar nlines = 0
		return scalar maxwidth = 0
		exit
	}
	
	if `maxwidth' & !`maxlines' {
		cap assert `maxwidth'>=`target'
		if _rc {
			nois disp as err `"{bf:maxwidth()} must be greater than or equal to {bf:target()}"'
			exit 198
		}
	}


	** Find length of title string, or maximum length of multi-line title string
	// First run: strip off outer quotes if necessary, but watch out for initial/final spaces!
	gettoken tok : title, qed(qed)
	cap assert `"`tok'"'==`"`1'"'
	if _rc {
		gettoken tok rest : tok, qed(qed)
		assert `"`tok'"'==`"`1'"'
		local title1 title1				// specifies that title is not multi-line
	}
	local currentlen = length(`"`1'"')
	local titlelen   = length(`"`1'"')
	
	// Subsequent runs: successive calls to -gettoken-, monitoring quotes with the qed() option
	macro shift
	while `"`1'"'!=`""' {
		local oldqed = `qed'
		gettoken tok rest : rest, qed(qed)
		assert `"`tok'"'==`"`1'"'
		if !`oldqed' & !`qed' local currentlen = `currentlen' + 1 + length(`"`1'"')
		else {
			local titlelen = max(`titlelen', `currentlen')
			local currentlen = length(`"`1'"')
		}
		macro shift
	}
	local titlelen = max(`titlelen', `currentlen')
	
	// Save user-specified parameter values separately
	local target_orig = `target'
	local maxwidth_orig = `maxwidth'
	local maxlines_orig = `maxlines'
	
	// Now finalise `target' and calculate `spread'
	local maxlines = cond(`maxlines_orig', `maxlines_orig', 3)	// use a default value for `maxlines' of 3 in these calculations
	local target = cond(`target_orig', `target_orig', ///
		cond(`maxwidth_orig', min(`maxwidth_orig', `titlelen'/`maxlines'), `titlelen'/`maxlines'))
	local spread = min(int(`titlelen'/`target') + 1, `maxlines')
	local crit = cond(`maxwidth_orig', min(`maxwidth_orig', `titlelen'/`spread'), `titlelen'/`spread')


	** If substrings are present, delineated by quotes, treat this as a line-break
	// Hence, need to first process each substring separately and obtain parameters,
	// then select the most appropriate overall parameters given the user-specified options,
	// and finally create the final line-by-line output strings.
	tokenize `title'
	local line = 1
	local title`line' : copy local 1				// i.e. `"`title`line''"'==`"`1'"'
	local newwidth = length(`"`title`line''"')

	// if first "word" is by itself longer than `maxwidth' ...
	if `maxwidth' & !(`maxlines' & (`line'==`maxlines')) {
	
		// ... reset parameters and start over
		while length(`"`1'"') > `maxwidth' {
			local maxwidth = length(`"`1'"')
			local target = cond(`target_orig', cond(`"`update'"'!=`""', `target_orig', `target_orig' + `maxwidth' - `maxwidth_orig'), ///
				cond(`maxwidth', min(`maxwidth', `titlelen'/`maxlines'), `titlelen'/`maxlines'))
			local spread = min(int(`titlelen'/`target') + 1, `maxlines')
			local crit = cond(`maxwidth', min(`maxwidth', `titlelen'/`spread'), `titlelen'/`spread')
		}
	}
	
	macro shift
	local next : copy local 1		// i.e. `"`next'"'==`"`1'"' (was `"`2'"' before macro shift!)
	while `"`1'"' != `""' {
		// local check = `"`title`line''"' + `" "' + `"`next'"'			// (potential) next iteration of `title`line''
		local check `"`title`line'' `next'"'							// (amended Apr 2018 due to local x = "" issue with version <13)
		if length(`"`check'"') > `crit' {								// if longer than ideal...
																		// ...and further from target than before, or greater than maxwidth
			if abs(length(`"`check'"') - `crit') > abs(length(`"`title`line''"') - `crit') ///
					| (`maxwidth' & (length(`"`check'"') > `maxwidth')) {
				if `maxlines' & (`line'==`maxlines') {					// if reached max no. of lines
					local title`line' : copy local check				//   - use next iteration anyway (to be truncated)

					macro shift
					local next : copy local 1
					local newwidth = max(`newwidth', length(`"`title`line''"'))		// update `newwidth'					
					continue, break
				}
				else {										// otherwise:
					local ++line							//  - new line
					
					// if first "word" of new line (i.e. `next') is by itself longer than `maxwidth' ...
					if `maxwidth' & (length(`"`next'"') > `maxwidth') {
					
						// ... if we're on the last line or last token, continue as normal ...
						if !((`maxlines' & (`line'==`maxlines')) | `"`2'"'==`""') {
						
							// ... but otherwise, reset parameters and start over
							local maxwidth = length(`"`next'"')
							local target = cond(`target_orig', cond(`"`update'"'!=`""', `target_orig', `target_orig' + `maxwidth' - `maxwidth_orig'), ///
								cond(`maxwidth', min(`maxwidth', `titlelen'/`maxlines'), `titlelen'/`maxlines'))
							local spread = min(int(`titlelen'/`target') + 1, `maxlines')
							local crit = cond(`maxwidth', min(`maxwidth', `titlelen'/`spread'), `titlelen'/`spread')
							
							// restart loop
							tokenize `title'
							local tok = 1
							local line = 1
							local title`line' : copy local 1				// i.e. `"`title`line''"'==`"`1'"'
							local newwidth = length(`"`title`line''"')
							macro shift
							local next : copy local 1		// i.e. `"`next'"'==`"`1'"' (was `"`2'"' before macro shift!)
							continue
						}
					}
					
					local title`line' : copy local next		//  - begin new line with next word
				}
			}
			else local title`line' : copy local check		// else use next iteration
			
		}
		else local title`line' : copy local check			// else use next iteration

		macro shift
		local next : copy local 1
		local newwidth = max(`newwidth', length(`"`title`line''"'))		// update `newwidth'
	}																	// (N.B. won't be done if reached max no. of lines, as loop broken)


	* Return strings
	forvalues i=1/`line' {
	
		// truncate if appropriate (last line only)
		if `i'==`line' & "`truncate'"=="" & `maxwidth' {
			local title`i' = substr(`"`title`i''"', 1, `maxwidth')
		}
		return local title`i' `"`title`i''"'
	}
	
	* Return values
	return scalar nlines = `line'
	return scalar maxwidth = min(`newwidth', `maxwidth')
	return scalar target = `target'
	
end





************************************************

** BuildResultsSet

// Having performed the meta-analysis (see PerformMetaAnalysis subroutine)
// ... and displayed results on-screen (see DrawTableAD subroutine)
// ... optionally prepare "results set" for either saving, or for constructing the forest plot (using forestplot.ado).
// The saving and/or running of -forestplot- is done from within this subroutine, due to tempvars being created.
// Note that meta-analysis is now complete, with stats returned in r(); if error in BuildResultsSet, error message explains this.

// (called directly by admetan.ado)

// [N.B. mostly end part of old (v2.2) MainRoutine subroutine]

program define BuildResultsSet, rclass sortpreserve

	syntax varlist(numeric min=3 max=7) [if] [in], LABELS(varname) OUTVLIST(varlist numeric min=5 max=8) ///
		METHOD(string) MODEL(string) SORTBY(varlist) ///
		[SUMMSTAT(string) STUDY(varname numeric) BY(varname numeric) BYSTATS(name) OVSTATS(name) ///
		CUmulative INFluence noOVerall noSUbgroup SUMMARYONLY OVWt SGWt ALTWt WGT(varname numeric) ///
		EFORM EFFect(string asis) LOGRank CC(string) CCVAR(name) ///
		LCols(varlist) RCols(varlist) COUNTS(string asis) EFFIcacy OEV NPTS ///
		XOUTVLIST(varlist numeric) RFDist RFLEVEL(real 95) LEVEL(real 95) TSQLEVEL(real 95) ///
		noEXTRALine HETStat(string) OVStat(string) noHET noWT noSTATs ///
		KEEPAll KEEPOrder noGRaph noWARNing SAVING(string) FORESTplot(string asis) FPNOTE(string asis) ///
		SFMTLEN(integer 0) USE3(varname numeric) PLOTID(passthru) ///
		BYAD SOURCE(varname numeric) LRVLIST(varlist numeric) IPDXLINE(string) ] 	/* IPD+AD options */
																					/* Note that additional options are not allowed! */
	// Extra line for heterogeneity in forest plot:
	//  either specified here, or previously via -ipdmetan- using `ipdxline' option
	local extraline = cond(`"`extraline'"'!=`""', `"no"', `"`ipdxline'"')
	
	marksample touse, novarlist	// -novarlist- option prevents -marksample- from setting `touse' to zero if any missing values in `varlist'
								// we want to control this behaviour ourselves, e.g. by using KEEPALL option
	
	gettoken _USE invlist : varlist
	local params : word count `invlist'
	
	tokenize `outvlist'
	args _ES _seES _LCI _UCI _WT _NN

	if `"`npts'"'!=`""' {
		cap confirm numeric var `_NN'
		if _rc {
			nois disp as err _n "cannot use {bf:npts} option; no patient numbers available"
			exit 198
		}
		local npts npts(`_NN')
		local nptsvar `_NN'			// added Jan 2019 for v3.2
	}
	
	// rename locals for consistency with rest of admetan.ado
	local _BY     `by' 
	local _STUDY  `study'
	local _LABELS `labels'
	local _SOURCE `source'
	
	cap confirm numeric var `ccvar'
	if !_rc local _CC `ccvar'		// added Jan 2019 for v3.2


	** Test validity of lcols/rcols -- cannot be any of the names -admetan- (or -ipdmetan- etc.) uses for other things
	// To keep things simple, forbid any varnames:
	//  - beginning with a single underscore followed by a capital letter
	//  - beginning with "_counts" 
	// (Oct 2018: N.B. was `badnames')
	local lrcols `lcols' `rcols'
	local check = 0	
	if trim(`"`lrcols'"') != `""' {
		local cALPHA `c(ALPHA)'

		foreach el of local lrcols {
			local el2 = substr(`"`el'"', 2, 1)
			if substr(`"`el'"', 1, 1)==`"_"' & `: list el2 in cALPHA' {
				nois disp as err _n `"Error in option {bf:lcols()} or {bf:rcols()}:  Variable names such as {bf:`el'}, beginning with an underscore followed by a capital letter,"'
				nois disp as err `" are reserved for use by {bf:ipdmetan}, {bf:ipdover} and {bf:forestplot}."'
				nois disp as err `"In order to save the results set, please rename this variable or use {bf:{help clonevar}}."'
				exit 101
			}
			else if substr(`"`el'"', 1, 7)==`"_counts"' {
				nois disp as err _n `"Error in option {bf:lcols()} or {bf:rcols()}:  Variable names beginning {bf:_counts} are reserved for use by {bf:ipdmetan}, {bf:ipdover} and {bf:forestplot}."'
				nois disp as err `"In order to save the results set, please rename this variable or use {bf:{help clonevar}}."'
				exit 101
			}
		
			// `saving' only:
			// Test validity of (value) *label* names: just _BY, _STUDY, _SOURCE as applicable
			// [modified Dec 2018 for v3.0.1]
			// Value labels are unique within datasets. Hence, not a problem for a var in lcols/rcols to have same value label as the by() or study() variable.
			// However, a var in lcols/rcols **cannot** use the label name _BY or _STUDY **unless** the by() or study() variable is already sharing that label name.
			// (Also, cannot use _SOURCE as a value label if `"`_SOURCE'"'!=`""')
			if `"`saving'"' != `""' {
				local lrlab : value label `el'
				if `"`lrlab'"'==`"_BY"' {
					if `"`_BY'"'==`""' local check = 1
					else {
						if `"`: value label `_BY''"'!=`"_BY"' local check = 1
					}
				}
				if `"`lrlab'"'==`"_STUDY"' {
					if `"`_STUDY'"'==`""' local check = 1
					else {
						if `"`: value label `_STUDY''"'!=`"_STUDY"' local check = 1
					}
				}
				if `"`lrlab'"'==`"_SOURCE"' {
					if `"`_SOURCE'"'==`""' local check = 1
					else {
						if `"`: value label `_SOURCE''"'!=`"_SOURCE"' local check = 1
					}
				}
				if `check' {
					disp as err _n `"Error in option {bf:lcols()} or {bf:rcols()}:  Label name {bf:`lrlab'} attached to variable {bf:`el'}"'
					disp as err `"  is reserved for use by {bf:ipdmetan}, {bf:admetan} and {bf:forestplot}."'
					disp as err `"In order to save the results set, please rename the label attached to this variable (e.g. using {bf:{help label copy}})."'
					exit 101
				}
			}		// end if `"`saving'"' != `""'
		}		// end foreach el of local lrcols
	}		// end if trim(`"`lrcols'"') != `""'		
	
	
	** Create new observations to hold subgroup & overall effects (_USE==3, 5)
	//   (these can simply be removed again to restore the original data.)
	
	// N.B. Such observations may already have been created if passed through from -ipdmetan-
	//   but in any case, cover all bases by checking for (if applicable) a _USE==3 corresponding to each `by'-value,
	//   plus a single overall _USE==5.
	
	// If `saving', need to -preserve- at this point
	//  (also take the opportunity to test validity of filename)
	if `"`saving'"' != `""' {
	
		// use modified version of _prefix_saving.ado to handle `stacklabel' option
		my_prefix_savingAD `saving'
		local saving `"`s(filename)'"'
		local 0 `", `s(options)'"'
		syntax [, STACKlabel * ]
		local saveopts `"`options'"'
		
		// (N.B. if _rsample!="", i.e. no saved vars: already preserved)
		if `"`rsample'"'==`""' preserve
		
		// keep `touse' itself for now to make subsequent coding easier
		qui keep if `touse'

	}		// end if `"`saving'"'!=`""'	

	if `"`_BY'"'!=`""' {
		qui levelsof `_BY' if `touse' & inlist(`_USE', 1, 2), missing local(bylist)
		local nby : word count `bylist'
	}
	
	// if cumulative, don't need _USE==3, 5; remove (e.g. if created by -ipdmetan-)
	if `"`cumulative'"'!=`""' {
		qui drop if `touse' & inlist(`_USE', 3, 5)
	}
	
	else {
		tempvar obs
		qui gen long `obs' = _n
	
		// if rfdist, obtain appropriate varnames
		if `"`rfdist'"'!=`""' {
			
			if `"`xoutvlist'"'!=`""' {
				local nx : word count `xoutvlist'
				local _rfUCI : word `nx' of `xoutvlist'
				local --nx
				local _rfLCI : word `nx' of `xoutvlist'
			}
			else {
				tempvar _rfLCI _rfUCI
				qui gen double `_rfLCI' = .
				qui gen double `_rfUCI' = .
			}
		}
	
		// Now setup "translation" from ovstats/bystats matrix rownames to stored varnames
		local vnames _ES  _seES    _LCI    _UCI _rfLCI _rfUCI
		local rnames eff se_eff eff_lci eff_uci  rflci  rfuci
	
		// subgroup effects (`_USE'==3)
		if `"`_BY'"'!=`""' & `"`subgroup'"'==`""' {
			local i = 1
			foreach byi of local bylist {
			
				summ `obs' if `touse' & `_USE'==3 & `_BY'==`byi', meanonly
				if !r(N) {
					local newN = _N + 1
					qui set obs `newN'
					qui replace `_BY' = `byi' in `newN'
					qui replace `_USE' = 3 in `newN'
					qui replace `touse' = 1 in `newN'
				}
				else local newN = r(min)
				
				// insert statistics from `bystats'
				forvalues j = 1/6 {
					local v  : word `j' of `vnames'
					local el : word `j' of `rnames'
					
					local rownumb = rownumb(`bystats', "`el'")
					if !missing(`rownumb') {
						qui replace ``v'' = `bystats'[`rownumb', `i'] in `newN'
					}
				}
				if `"`sgwt'"'!=`""' qui replace `_WT' = 100 in `newN'
				else {
					summ `_WT' if `touse' & `_USE'==1 & `_BY'==`byi', meanonly
					qui replace `_WT' = r(sum) in `newN'
				}

				local ++i
				
			}	// end foreach byi of local bylist
		}	// end if `"`_BY'"'!=`""' & `"`subgroup'"'==`""'
		
		
		// overall effect (`_USE'==5)
		if `"`overall'"'==`""' {
			summ `obs' if `_USE'==5 & `touse', meanonly
			if !r(N) {		
				local newN = _N + 1
				qui set obs `newN'
				qui replace `_USE' = 5 in `newN'
				qui replace `touse' = 1 in `newN'
			}
			else local newN = r(min)
				
			// insert statistics from `ovstats'
			forvalues j = 1/6 {
				local v  : word `j' of `vnames'
				local el : word `j' of `rnames'
				
				local rownumb = rownumb(`ovstats', "`el'")
				if !missing(`rownumb') {
					qui replace ``v'' = `ovstats'[`rownumb', 1] in `newN'
				}
			}
			if `"`ovwt'"'!=`""' qui replace `_WT' = 100 in `newN'

		}		// end if `"`overall'"'==`""'
	}		// end else (i.e. if `"`cumulative'"'==`""')


	** Fill down counts, npts, oev
	
	// Setup `counts' and `oev' options
	if `"`counts'"'!=`""' | `"`oev'"'!=`""' {
		tokenize `invlist'
		local params : word count `invlist'

		if `"`counts'"'!=`""' {
			if `params' == 6 args n1 mean1 sd1 n0 mean0 sd0			// `invlist'
			else {
				tempvar sum_e1 sum_e0
			
				// Log-rank (Peto) HR from -ipdmetan-
				// counts = "events/total in research arm; events/total in control arm"
				if `"`lrvlist'"'!=`""' {
					cap assert `params'==2 & "`logrank'"!=""
					if _rc {
						nois disp as err _n `"Error in communication between {bf:ipdmetan} and {bf:admetan}"'
						exit 198
					}
					tokenize `lrvlist'
					args n1 n0 e1 e0
				}

				// Binary outcome (OR, Peto, RR, RD)
				// counts = "events/total in research arm; events/total in control arm"
				else if `params'==4 {
					args e1 f1 e0 f0		// `invlist'
					tempvar n1 n0
					qui gen long `n1' = `e1' + `f1'
					qui gen long `n0' = `e0' + `f0'
				}
				
				else {
					nois disp as err _n `"Note: {bf:counts} is only valid with 2x2 count data or continuous data, so will be ignored"'
					local counts
				}	
			}
		}
		
		if `"`oev'"'!=`""' {
		
			// modified 28nov2018 for v3.0.1
			if "`logrank'"!="" {
				tokenize `invlist'
				args _OE _V
			}
			else if "`method'"=="peto" {
				tempvar _OE _V
				qui gen double `_OE' = `_ES' / `_seES'^2
				qui gen double `_V'  =    1  / `_seES'^2
			}
			else {
				disp as err _n `"Note: {bf:oev} is not applicable without log-rank data or Peto ORs, so will be ignored"'
				local oev
			}
		}
		if `"`oev'"'!=`""' {
			label variable `_OE' `"O-E(o)"'
			label variable `_V'  `"V(o)"'
			format `_OE' %6.2f
			format `_V' %6.2f
		}
	}			// end if `"`counts'"'!=`""' | `"`oev'"'!=`""'

	// Create `sumvlist' containing list of vars to fill down
	if `"`counts'"'!=`""' {
		local sumvlist n1 n0 
		if inlist(`params', 2, 4) {
			local sumvlist `sumvlist' e1 e0 
		}
		tempvar _counts1 _counts0
	}
	else if `"`oev'"'!=`""' local sumvlist _OE _V
	if "`_NN'"!="" local sumvlist `sumvlist' _NN
	
	if `"`cumulative'`influence'"'!=`""' & `"`altwt'"'==`""' {
		foreach x of local sumvlist {
			tempvar sum_`x'
		}
	}
	
	// 21st March 2018
	// Now do the actual "filling down".
	// If `cumulative' or `influence', keep *both* versions: the original (to be stored in the current dataset, unless `nokeepvars')
	//   and the "filled down" (for the forestplot and/or saved dataset)...
	//   ...unless `altwt', in which case just keep the original.
	sort `touse' `use5' `_BY' `_USE' `_SOURCE' `sortby'
	tempvar tempsum
	
	// subgroup totals
	if `"`_BY'"'!=`""' & `"`subgroup'"'==`""' {
		foreach x of local sumvlist {
			qui by `touse' `use5' `_BY' : gen long `tempsum' = sum(``x'') if `touse'
			qui replace ``x'' = `tempsum' if `touse' & `_USE'==3

			if `"`cumulative'`influence'"'!=`""' & `"`altwt'"'==`""' {
				if `"`influence'"'!=`""' {
					qui gen long `sum_`x'' = `tempsum' if `touse' & `_USE'==3
					qui by `touse' `use5' `_BY' : replace `tempsum' = ``x''[_N]
					qui replace `sum_`x'' = `tempsum' - ``x'' if `touse' & `_USE'==1
				}
				else qui gen long `sum_`x'' = `tempsum'
			}
			drop `tempsum'
		}
	}

	// overall totals
	if `"`overall'"'==`""' {
		foreach x of local sumvlist {
			qui gen long `tempsum' = sum(``x'') if `touse' & `_USE'!=3
			qui replace ``x'' = `tempsum' if `touse' & `_USE'==5

			if `"`cumulative'`influence'"'!=`""' & `"`altwt'"'==`""' {
				if `"`influence'"'!=`""' {
					summ ``x'' if `touse' & `_USE'==5, meanonly
					
					if !(`"`_BY'"'!=`""' & `"`subgroup'"'==`""') {
						qui gen long `sum_`x'' = `tempsum' if `touse' & `_USE'==5
						qui replace `sum_`x'' = r(sum) - ``x'' if `touse' & `_USE'==1
					}
					else {
						qui replace `sum_`x'' = `tempsum' if `touse' & `_USE'==5
					}
				}
				else if `"`_BY'"'==`""' {
					qui gen long `sum_`x'' = `tempsum'
				}
			}
			drop `tempsum'
		}
	}

	// Reassign locals `x' to reference vars previously referenced by locals `sum_`x''
	// That is, "rename" our filled-down vars to their "original/natural" names.
	// (N.B. vars  n1, n0, e1, e0, _OE, _V are only relevant to *saved* datasets, not to the *original* dataset...
	//  ... but _NN needs to be treated differently)
	if `"`cumulative'`influence'"'!=`""' {
		if `"`altwt'"'==`""' {
			foreach x of local sumvlist {
				local `x' `sum_`x''
			}
		}
	}

	
	** Finally, create `counts' string for forestplot
	if `"`counts'"'!=`""' {

		// Added May 2018
		// option "counts" is guaranteed to be present (see ParseFPlotOpts); hence going forward local counts = "counts"
		local 0 `", `counts'"'
		syntax [, COUNTS GROUP1(string asis) GROUP2(string asis) ]
	
		// Titles
		// amended Feb 2018 due to local x = "" issue with version <13
		// local title1 = cond(`"`group2'"'!=`""', `"`group2'"', `"Treatment"')
		// local title0 = cond(`"`group1'"'!=`""', `"`group1'"', `"Control"')
		if `"`group2'"'!=`""' local title1 `"`group2'"'
		else local title1 "Treatment"
		if `"`group1'"'!=`""' local title0 `"`group1'"'
		else local title0 "Control"	
		
		// Binary data & logrank HR
		if inlist(`params', 2, 4) {
			qui gen `_counts1' = string(`e1') + "/" + string(`n1') if inlist(`_USE', 1, 2, 3, 5)
			qui gen `_counts0' = string(`e0') + "/" + string(`n0') if inlist(`_USE', 1, 2, 3, 5)
			label variable `_counts1' `"`title1' n/N"'
			label variable `_counts0' `"`title0' n/N"'
			drop `n1' `n0'							// tidy up
		}
		
		// N mean SD for continuous data
		// counts = "N, mean (SD) in research arm; N, mean (SD) events/total in control arm"
		else {
			tempvar _counts1msd _counts0msd

			qui gen long `_counts1' = `n1' if inlist(`_USE', 1, 2, 3, 5)
			qui gen `_counts1msd' = string(`mean1', "%7.2f") + " (" + string(`sd1', "%7.2f") + ")" if inlist(`_USE', 1, 2)
			label variable `_counts1' "N"
			label variable `_counts1msd' `"`title1' Mean (SD)"'
					
			qui gen long `_counts0' = `n0' if inlist(`_USE', 1, 2, 3, 5)
			qui gen `_counts0msd' = string(`mean0', "%7.2f") + " (" + string(`sd0', "%7.2f") + ")" if inlist(`_USE', 1, 2)
			label variable `_counts0' "N"
			label variable `_counts0msd' `"`title0' Mean (SD)"'
					
			// Find max number of digits in `_counts1', `_counts0'
			summ `_counts1', meanonly
			if r(N) {
				local fmtlen = floor(log10(`r(max)'))
				format `_counts1' %`fmtlen'.0f
			}
			summ `_counts0', meanonly
			if r(N) {
				local fmtlen = floor(log10(`r(max)'))
				format `_counts0' %`fmtlen'.0f
			}
		}
				
		// 26th March 2018:
		// If `saving', local countsvl contains *permanent* varnames rather than temp varnames
		// (although the pernament names are not yet in use!)
		local countsvl `_counts1' `_counts1msd' `_counts0' `_counts0msd'
		if `"`saving'"' != `""' {
			if `params'==6 local countsvl _counts1 _counts1msd _counts0 _counts0msd
			else local countsvl _counts1 _counts0
		}

	}	// end if `"`counts'"'!=`""'
	
	// end of "filling-down counts" section

	
	** Vaccine efficacy
	// (carried over from -metan- )
	tempvar strlen
	if `"`efficacy'"'!=`""' {

		// check: OR and RR only
		cap assert inlist("`summstat'", "or", "rr")
		if _rc {
			nois disp as err _n "Vaccine efficacy statistics only possible with odds ratios and risk ratios"
			exit _rc
		}
	
		if `"`saving'"' != `""' {
			cap drop _VE
			local _VE _VE
		}
		else tempvar _VE
		qui gen `_VE' = string(100*(1 - exp(`_ES')), "%4.0f") + " (" ///
			+ string(100*(1 - exp(`_LCI')), "%4.0f") + ", " ///
			+ string(100*(1 - exp(`_UCI')), "%4.0f") + ")" if inlist(`_USE', 1, 3, 5)
		
		label variable `_VE' "Vaccine efficacy (%)"
		
		qui gen `strlen' = length(`_VE')
		summ `strlen', meanonly
		format %`r(max)'s `_VE'
		qui compress `_VE'
		drop `strlen'
	}

	
	** If `saving', finish off renaming tempvars to permanent varnames
	// ...in order to store them in the *saved* dataset (NOT the data in memory)
	if `"`saving'"' != `""' {

		// Sep 2018:
		// Initialize varlists to save in Results Set:
		// `core':  "core" variables (N.B. *excluding* _NN)
		local core _ES _seES _LCI _UCI _WT	
		// tosave':  additional "internal" vars created by specific options
		// [may contain:  _NN;  _OE _V if `oev';  `countsvl' if `counts';  _VE if `efficacy';  _CC if `cc';  _rfLCI _rfUCI if `rfdist']
		if `"`_NN'"'!=`""' local tosave _NN
		if `"`oev'"'!=`""' local tosave `tosave' _OE _V
		if `"`counts'"'!=`""' local tosave `tosave' `countsvl'
		if `"`efficacy'"'!=`""' local tosave `tosave' _VE
		if `"`_CC'"'!=`""' local tosave `tosave' _CC
		if `"`rfdist'"'!=`""' local tosave `tosave' _rfLCI _rfUCI
		
		// Separately, `xoutvlist' contains the same elements as `rownames' (excluding the "core" variables),
		//  except _NN, and with the addition of _WT2.
		if `"`xoutvlist'"'!=`""' {
			local rownames
			cap local rownames : rownames `ovstats'
			if _rc cap local rownames : rownames `bystats'
		
			if `"`rownames'"'!=`""' {
				local rnfull  crit  chi2  df_kr pvalue  oe  v  Q  Qdf  Isq  HsqM  sigmasq  tausq  tsq_lci tsq_uci rflci  rfuci
				local vnfull _crit _chi2 _dfkr _pvalue _OE _V _Q _Qdf _Isq _HsqM _sigmasq _tausq _tsqlci _tsquci _rfLCI _rfUCI
				
				assert `: word count `rnfull'' == `: word count `vnfull''
				local j = 0
				forvalues i = 1 / `: word count `rnfull'' {
					local el : word `i' of `rnfull'
					if `: list el in rownames' {
						local xnames `xnames' `: word `i' of `vnfull''	// build list of relevant elements of `vnfull'
						local ++j
					}
				}
				
				tokenize `xoutvlist'
				args `xnames'
				local tosave : list tosave | xnames		// add these to our pre-existing list
			}
		}
		
		// "Labelling" variables: _USE, _STUDY, _BY etc.
		local labelvars _USE
		local _BY = cond(`"`byad'"'!=`""', `""', `"`_BY'"')
		if `"`_BY'"'!=`""'     local labelvars `labelvars' _BY
		if `"`_SOURCE'"'!=`""' local labelvars `labelvars' _SOURCE
		local labelvars `labelvars' _STUDY _LABELS

		local tocheck `labelvars' `core' `tosave'
		foreach v of local tocheck {
			if `"``v''"'!=`""' {						// N.B. xoutvlist is independent of [no]keepvars.
				confirm variable ``v''

				// For numeric _STUDY, _BY and _SOURCE,
				//   check if pre-existing var (``v'') has the "correct" value label name (`v').
				// If it does not, drop any existing value label `v', and copy current value label across to `v'.
				if inlist("`v'", "_STUDY", "_BY", "_SOURCE") {
					if `"`: value label ``v'''"' != `""' & `"`: value label ``v'''"' != `"`v'"' {
						cap label drop `v'
						label copy `: value label ``v''' `v'
						label values ``v'' `v'
					}
				}
			
				// Similar logic now applies to variable names:
				// Check if pre-existing var has the same name (i.e. was named _BY, _STUDY etc.)
				// If it does not, first drop any existing var named _BY, _STUDY (e.g. left over from previous -admetan- call), then rename.
				if `"``v''"'!=`"`v'"' {
					cap drop `v'
					
					// If ``v'' is in `lrcols', use -clonevar-, so as also to keep original name
					// [Added Nov 2018 for v3.0.1]
					if `: list `v' in lrcols' {
						qui clonevar `v' = ``v'' if `touse'
					}
					else qui rename ``v'' `v'
				}
				
				local `v' `v'				// for use with subsequent code

				// Added Jan 2019 [CHECK IF THERE IS A BETTER WAY TO HANDLE THIS]
				if "`v'"=="_NN" & `"`npts'"'!=`""' {
					local npts npts(_NN)
					local nptsvar _NN
				}				
			}
		}
		
		// if `byad' (-ipdmetan- option),
		//  `by' has been pointing to `source'. For saving, create a separate _BY variable. 
		if `"`byad'"'!=`""' {
			cap drop _BY
			cap label drop _BY
			qui gen byte _BY = _SOURCE
			label copy _SOURCE _BY
			label values _BY _BY
			local _BY _BY
		}			
				
		// September 2018 [modified Nov 2018 for v3.0.1]: labels and formats
		// Label variables with short-ish names for display on forest plots
		// Use characteristics to store longer, explanatory names
		label variable `_ES'  "ES"
		label variable `_seES' "seES"
		label variable `_LCI' "LCI"
		label variable `_UCI' "UCI"
		char define `_ES'[Desc]  "Effect size (interval scale)"
		char define `_seES'[Desc] "Standard error of effect size"
		char define `_LCI'[Desc] "`level'% lower confidence limit"
		char define `_UCI'[Desc] "`level'% upper confidence limit"
		char define `_LCI'[Level] `level'
		char define `_UCI'[Level] `level'
		format %6.3f `_ES' `_seES' `_LCI' `_UCI'
		
		if `"`rfdlist'"'!=`""' {
			label variable `_rfLCI' "rfLCI"
			label variable `_rfUCI' "rfUCI"
			char define `_rfLCI'[RFLevel] `rflevel'
			char define `_rfUCI'[RFLevel] `rflevel'
			char define `_rfLCI'[Desc] "`rflevel'% lower limit of predictive distribution"
			char define `_rfUCI'[Desc] "`rflevel'% upper limit of predictive distribution"
		}
		
		if `"`xoutvlist'"'!=`""' {
			if `"`_crit'"'!=`""' {
				label variable `_crit' "Crit. val."
				char define `_crit'[Desc] "Critical value"
				format %6.2f `_crit'
			}
			if `"`_chi2'"'!=`""' {
				label variable `_chi2' "chi2"
				char define `_chi2'[Desc] "Chi-square statistic"
				format %6.2f `_chi2'
			}
			if `"`_dfkr'"'!=`""' {
				label variable `_dfkr' "Kenward-Roger df"
				char define `_dfkr'[Desc] "Kenward-Roger degrees of freedom"
				format %6.2f `_dfkr'
			}
			if `"`_pvalue'"'!=`""' {
				label variable `_pvalue' "p"
				char define `_pvalue'[Desc] "p-value for effect size"
				format %05.3f `_pvalue'
			}
			if `"`_Q'"'!=`""' {
				label variable `_Q' "Q"
				char define `_Q'[Desc] "Cochran's Q heterogeneity statistic"
				format %6.2f `_Q'
			}
			if `"`_Qdf'"'!=`""' {
				label variable `_Qdf' "Q df"
				char define `_Qdf'[Desc] "Degrees of freedom for Cochran's Q"
				format %6.0f `_Qdf'
			}
			if `"`_Isq'"'!=`""' {
				label variable `_Isq' "I2"
				char define `_Isq'[Desc] "I-squared heterogeneity statistic"
				format %6.1f `_Isq'
			}
			if `"`_HsqM'"'!=`""' {
				label variable `_HsqM' "H2"
				char define `_HsqM'[Desc] "Modified H-squared heterogeneity statistic"
				format %6.2f `_HsqM'
			}
			if `"`_sigmasq'"'!=`""' {
				label variable `_sigmasq' "sigma2"
				char define `_sigmasq'[Desc] "Estimated average within-trial heterogeneity"
				format %6.3f `_sigmasq'
			}
			if `"`_tausq'"'!=`""' {
				label variable `_tausq' "tau2"
				char define `_tausq'[Desc] "Estimated between-trial heterogeneity"
				format %6.3f `_tausq'
			}
			if `"`_tsqlci'"'!=`""' {
				label variable `_tsqlci' "tau2 LCI"
				char define `_tsqlci'[Desc] "`tsqlevel'% lower confidence limit for tau-squared"
				format %6.3f `_tsqlci'
			}
			if `"`_tsquci'"'!=`""' {
				label variable `_tsquci' "tau2 UCI"
				char define `_tsquci'[Desc] "`tsqlevel'% upper confidence limit for tau-squared"
				format %6.3f `_tsquci'
			}
		}
	}		// end if `"`saving'"' != `""'
	
	// variable name (title) and format for "_NN" (if appropriate)
	if `"`_NN'"'!=`""' {
		if `"`: variable label `_NN''"'==`""' label variable `_NN' "No. pts"
		qui gen `strlen' = length(string(`_NN'))
		summ `strlen' if `touse', meanonly
		local fmtlen = max(`r(max)', 3)		// min of 3, otherwise title ("No. pts") won't fit
		format `_NN' %`fmtlen'.0f			// right-justified; fixed format (for integers)
		drop `strlen'

		if      `"`cumulative'"'!=`""' label variable `_NN' "Cumulative no. pts"
		else if `"`influence'"'!=`""'  label variable `_NN' "Remaining no. pts"
	}
	
				
	** Insert extra rows for headings, labels, spacings etc.
	//  Note: in the following routines, "half" values of _USE are used temporarily to get correct order
	//        and are then replaced with whole numbers at the end			

	isid `touse' `use5' `_BY' `_USE' `_SOURCE' `sortby', missok				

	// _BY will typically be missing for _USE==5, so need to be careful when sorting
	// Hence, generate marker of _USE==5 to sort on *before* _BY
	summ `_USE' if `touse', meanonly
	if r(max)==5 {
		tempvar use5
		qui gen byte `use5' = (`_USE'==5)
	}
	local notuse5 = cond("`use5'"=="", "", `"*(!`use5')"')

	// variable name (titles) for "_LABELS" or `stacklabel'
	if `"`_BY'"'!=`""' {
		local byvarlab : variable label `_BY'
	}
	if `"`summaryonly'"'!=`""' & `"`_BY'"'!=`""' local labtitle `"`byvarlab'"'
	else {
		if `"`_BY'"'!=`""' local bytitle `"`byvarlab' and "'
		if `"`_STUDY'"'!=`""' & `"`summaryonly'"'==`""' {
			local svarlab : variable label `_STUDY'
		}
		local stitle `"`bytitle'`svarlab'"'
		if `"`influence'"'!=`""' local stitle `"`stitle' omitted"'
		local labtitle `"`stitle'"'
	}
	if `"`stacklabel'"'==`""' label variable `_LABELS' `"`labtitle'"'
	else label variable `_LABELS'		// no title if `stacklabel'


	// If `npts', `counts' or `oev' requested for display on forest plot
	//   then heterogeneity stats will need to be on a new line (unless manually overruled with `noextraline')
	// [Modifed 17th May 2018, 24th May 2018, Nov 2018]
	if `"`het'`extraline'"'==`""' & `"`npts'`counts'`oev'`efficacy'"'!=`""' local extraline yes
	
	// June 2018:
	// Now temporarily multiply _USE by 10
	// to enable intermediate numberings for sorting the extra rows
	qui replace `_USE' = `_USE'	* 10
	tempvar expand
	
	* Subgroup headings
	// Idea is to expand for "all values of _BY", but leave the "overall" row(s) alone (_USE==5).
	// _BY is missing for _USE==5, but this won't work as "missing" could equally be a legitimate value for _BY!!
	// So, instead, we use `notuse5', where we have previously generated `use5' to mark those observations (_USE==5)
	//   where we don't want _BY groups to be expanded.
	if `"`_BY'"'!=`""' {
		if `"`summaryonly'"'==`""' {
			qui bysort `touse' `_BY' (`sortby') : gen byte `expand' = 1 + 2*`touse'*(_n==1)`notuse5'
			qui expand `expand'
			qui replace `expand' = !(`expand' > 1)							// `expand' is now 0 if expanded and 1 otherwise (for sorting)
			sort `touse' `_BY' `expand' `_USE' `_SOURCE' `sortby'
			qui by `touse' `_BY' : replace `_USE' = 0  if `touse' & !`expand' & _n==2	// row for headings (before)
			qui by `touse' `_BY' : replace `_USE' = 41 if `touse' & !`expand' & _n==3	// row for blank line (after)
		}
		else {
			summ `_BY' if `touse', meanonly
			qui bysort `touse' `_BY' (`sortby') : gen byte `expand' = 1 + `touse'*(`_BY'==`r(max)')*(_n==_N)`notuse5'
			qui expand `expand'
			qui replace `expand' = !(`expand' > 1)							// `expand' is now 0 if expanded and 1 otherwise (for sorting)
			sort `touse' `_BY' `expand' `_USE' `_SOURCE' `sortby'
			qui by `touse' `_BY' : replace `_USE' = 41 if `touse' & !`expand' & _n==2	// row for blank line (only after last subgroup)
		}
		drop `expand'
					
		// Subgroup spacings & heterogeneity
		if "`subgroup'"=="" & `"`extraline'"'==`"yes"' {
			qui bysort `touse' `_BY' (`sortby') : gen byte `expand' = 1 + `touse'*(_n==_N)`notuse5'
			qui expand `expand'
			qui replace `expand' = !(`expand' > 1)						// `expand' is now 0 if expanded and 1 otherwise (for sorting)
			sort `touse' `_BY' `expand' `_USE' `_SOURCE' `sortby'
			qui by `touse' `_BY' : replace `_USE' = 39 if `touse' & !`expand' & _n==2		// extra row for het if lcols
			
			// An extra subtlety if `cumulative':
			//  there are no overall diamonds; instead the final _USE==1 observation is marked with `use3'
			// But we *don't* want to mark expanded obs with `use3'.
			if "`use3'"!="" {
				qui by `touse' `_BY' : replace `use3' = 0 if `touse' & !`expand' & _n==2
			}

			drop `expand'
		}
	}

	// Prediction intervals [MOVED 19th March 2018]
	if `"`rfdist'"'!=`""' {
		local oldN = _N
		qui gen byte `expand' = 1 + `touse'*inlist(`_USE', 30, 50)
		qui expand `expand'
		drop `expand'
		qui replace `_USE' = 35 if `touse' & _n>`oldN' & `_USE'==30
		qui replace `_USE' = 55 if `touse' & _n>`oldN' & `_USE'==50
	}
	
	// Blank out effect sizes etc. in `expand'-ed rows
	// March 2018: can we generalise this to be "all except..." instead of "all these"
	// answer: no, because there might be other data in memory entirely irrelevant to admetan
	// Dec 2018: if `_BY' is also in `lrcols', exclude from this procedure
	local lrcols2 : copy local lrcols
	if `"`_BY'"'!=`""' & `"`lrcols'"'!=`""' {
		local lrcols2 : list lrcols - _BY
	}
	foreach x of varlist `_LABELS' `_ES' `_seES' `_LCI' `_UCI' `_WT' `_NN' `_Q' `_Qdf' `_tausq' `_sigmasq' `_counts1' `_counts1msd' `_counts0' `_counts0msd' `_OE' `_V' `lrcols2' {
		cap confirm numeric var `x'
		if !_rc qui replace `x' = .  if `touse' & !inlist(`_USE', 10, 20, 30, 50)
		else    qui replace `x' = "" if `touse' & !inlist(`_USE', 10, 20, 30, 50)
	}
	
	if `"`summaryonly'"'==`""' {
		if `"`_STUDY'"'!=`""' {
			qui replace `_STUDY' = . if `touse' & !inlist(`_USE', 10, 20)
		}
		
		// don't blank out `_SOURCE' if `byad' and not `saving'
		//  since in that case `_SOURCE' is doing the job of `_BY'
		if `"`_SOURCE'"'!=`""' & !(`"`byad'"'!=`""' & `"`saving'"'==`""') {
			qui replace `_SOURCE'=. if `touse' & !inlist(`_USE', 10, 20)
		}
	}
	
	// extra row to contain what would otherwise be the leftmost column heading if `stacklabel' specified
	// (i.e. so that heading can be used for forestplot stacking)
	if `"`stacklabel'"' != `""' {
		local newN = _N + 1
		qui set obs `newN'
		qui replace `touse' = 1  in `newN'
		qui replace `_USE' = -10 in `newN'
		if "`use5'"=="" {
			tempvar use5						// we need `use5' here, regardless of whether it's needed elsewhere 
			qui gen byte `use5' = 0 if `touse'
		}
		qui replace `use5' = -1 in `newN'
		qui replace `_LABELS' = `"`labtitle'"' in `newN'
	}

	
	** Now insert label info into new rows
	
	// "ovstat" is a synonym for "hetstat"
	local hetstat = cond(`"`hetstat'"'==`""', `"`ovstat'"', `"`hetstat'"')
	
	// Jan 2018 for v2.2
	local 0 `", `hetstat'"'
	syntax [, ISQ Q Pvalue]
	opts_exclusive `"`isq' `q'"' hetstat 184
	local hetstat `isq'`q'
	
	tempname Isq Q Qdf Qpval

	// tausq-related stuff (incl. Qr) is meaningless for M-H, and also for Peto or Breslow unless RE
	// (although this *does* include sensitivity analysis)
	// (also if user-defined weights, tausq-related stuff is meaningless *except* for Qr -- added Sep 2017 for v2.1)
	// local hetstat = cond("`wgt'"!="" | "`model'"=="mh" | ("`model'"=="fe" & ("`method'"=="peto" | "`breslow'"!="")), "q", "`hetstat'")
	// [blanked out Nov 2018; N.B. Jan 2019: `breslow' no longer needed by BuildResultsSet]
		
	// "overall" labels
	if `"`overall'"'==`""' {
		local ovlabel
		if `"`het'"'==`""' {
		
			// Feb 2018 for v2.2:  added back in the option to display heterogeneity p-value
			scalar `Isq' = `ovstats'[rownumb(`ovstats', "Isq"), 1]
			scalar `Q'   = `ovstats'[rownumb(`ovstats', "Q"), 1]
			scalar `Qdf' = `ovstats'[rownumb(`ovstats', "Qdf"), 1]
			scalar `Qpval' = chi2tail(`Qdf', `Q')

			local end
			if "`pvalue'"!=`""' {
				local end `", p = `=string(`Qpval', "%05.3f")'"'
			}
			local end `"`end')"'
			
			// tausq-related stuff (incl. Qr) is meaningless for M-H, and also for Peto or Breslow unless RE
			// (N.B. although this *does* include sensitivity analysis)
			if "`hetstat'"=="q" {
				local ovlabel `"(Q = "' + string(`Q', "%5.2f") + `" on `=`Qdf'' df`end'"'
			}
			else {
				// altered Sep 2017 for v2.1, to match with metan/metaan behaviour
				// local ovlabel "(I-squared = " + string(100*`Isq', "%5.1f")+ "%)"
				local ovlabel `"(I-squared = "' + string(`Isq', "%5.1f") + `"%`end'"'
			}
			
			// Overall heterogeneity - extra row if lcols
			if `"`extraline'"'==`"yes"' {
				local newN = _N + 1
				qui set obs `newN'
				qui replace `touse' = 1  in `newN'
				qui replace `_USE'  = 59 in `newN'
				if "`use5'"!="" {
					qui replace `use5' = 1 in `newN'
				}
				qui replace `_LABELS' = `"`ovlabel'"' if `_USE'==59
				local ovlabel				// ovlabel on line below so no conflict with lcols; then clear macro
			}
		}
		qui replace `_LABELS' = `"Overall `ovlabel'"' if `_USE'==50
	}

	// subgroup ("by") headings & labels
	if `"`_BY'"'!=`""' {
	
		local i = 1
		foreach byi of local bylist {
			
			// headings
			local bylabi : label (`_BY') `byi'
			if `"`summaryonly'"'==`""' {
				qui replace `_LABELS' = "`bylabi'" if `_USE'==0 & `_BY'==`byi'
			}
			
			// labels + heterogeneity
			if `"`subgroup'"'==`""' {
				
				// local sglabel = cond(`"`summaryonly'"'!=`""', `"`bylabi'"', `"Subgroup"')
				if `"`summaryonly'"'!=`""' local sglabel `"`bylabi'"'
				else local sglabel "Subgroup"		// amended Feb 2018 due to local x = ... issue with version <13
				local sghetlab
			
				if `"`het'"'==`""' {
				
					// Feb 2018 for v2.2:  added back in the option to display heterogeneity p-value
					scalar `Isq'   = `bystats'[rownumb(`bystats', "Isq"), `i']
					scalar `Q'     = `bystats'[rownumb(`bystats', "Q"),   `i']
					scalar `Qdf'   = `bystats'[rownumb(`bystats', "Qdf"), `i']
					scalar `Qpval' = chi2tail(`Qdf', `Q')
					local end
					if "`pvalue'"!=`""' {
						local end ", p = " + string(`Qpval', "%05.3f") + ""
					}
					local end "`end')"						
				
					// tausq-related stuff (incl. Qr) is meaningless for M-H, and also for Peto or Breslow unless RE
					// (N.B. although this *does* include sensitivity analysis)
					if "`hetstat'"=="q" {
						local sghetlab = "(Q = " + string(`Q', "%5.2f") + " on `=`Qdf'' df`end'"
					}
					else {
						// local sghetlab = "(I-squared = " + string(100*`Isqi', "%5.1f")+ "%)"		// altered Sep 2017 for v2.1 to match with metan/metaan behaviour
						local sghetlab = "(I-squared = " + string(`Isq', "%5.1f")+ "%`end'"
					}
					if `"`extraline'"'==`"yes"' {
						qui replace `_LABELS' = "`sghetlab'" if `_USE'==39 & `_BY'==`byi'
						local sghetlab			// sghetlab on line below so no conflict with lcols; then clear macro
					}
				}
				qui replace `_LABELS' = `"`sglabel' `sghetlab'"' if `_USE'==30 & `_BY'==`byi'
			}
			
			local ++i
			
		}		// end foreach byi of local bylist
		
		// add between-group heterogeneity info
		// (N.B. `overall' as o/w `Qdiff' not calculated; `subgroup' as o/w `Qsum' not calculated)
		if `"`overall'`subgroup'`het'"'==`""' {
			local newN = _N + 1
			qui set obs `newN'
			qui replace `touse' = 1  in `newN'
			qui replace `_USE'  = 49 in `newN'
			if "`use5'"!="" {
				qui replace `use5' = 0 in `newN'
			}
			
			tempname Q_ov Qsum Qdiff Qdiffp
			scalar `Q_ov' = `ovstats'[rownumb(`ovstats', "Q"), 1]
			scalar `Qsum' = 0
			forvalues i = 1 / `nby' {
				scalar `Qsum' = `Qsum' + `bystats'[rownumb(`bystats', "Q"), `i']
			}
			scalar `Qdiff' = `Q_ov' - `Qsum'			// between-subgroup heterogeneity (Qsum = within-subgroup het.)
			scalar `Qdiffp' = chi2tail(`nby'-1, `Qdiff')
			qui replace `_LABELS' = "Heterogeneity between groups: p = " + string(`Qdiffp', "%5.3f") in `newN'
		}
	}		// end if `"`_BY'"'!=`""'

	// Insert prediction interval data (will be checked later)
	if `"`rfdist'"'!=`""' {
		qui replace `_LABELS' = "with estimated prediction interval" if inlist(`_USE', 35, 55)
		qui replace `_LCI' = `_rfLCI' if inlist(`_USE', 35, 55)
		qui replace `_UCI' = `_rfUCI' if inlist(`_USE', 35, 55)
		qui drop if missing(`_LCI', `_UCI') & inlist(`_USE', 35, 55)		// if prediction interval was undefined
	}
	
	
	** Sort, and tidy up
	if `"`keeporder'"'!=`""' {
		tempvar tempuse
		qui gen byte `tempuse' = `_USE'
		qui replace `tempuse' = 10 if `_USE'==20		// keep "insufficient data" studies in original study order (default is to move to end)
	}
	else local tempuse `_USE'
	
	sort `touse' `use5' `_BY' `tempuse' `_SOURCE' `sortby'
	cap drop `use5'
	
	// Tidy up `_USE' (and scale back down by 10)
	quietly {
		replace `_USE' =  0 if `_USE' == -10
		replace `_USE' = 60 if `_USE' ==  41
		replace `_USE' = 30 if `_USE' ==  35
		replace `_USE' = 50 if `_USE' ==  55
		replace `_USE' = 40 if inlist(`_USE', 39, 49, 59)
		replace `_USE' = `_USE' / 10
	}	

	// Format and title weights
	label variable `_WT' "% Weight"
	format `_WT' %6.2f
	
	// Check prediction interval data (after sorting and finalising _USE)
	if `"`rfdist'"'!=`""' {
		cap {
			assert `_rfLCI' <= `_LCI'    if `touse' & !missing(`_rfLCI', `_LCI')
			assert `_rfUCI' >= `_UCI'    if `touse' & !missing(`_rfUCI', `_UCI')
			assert  missing(`_ES')       if `touse' & inlist(`_USE', 3, 5) & float(`_rfLCI')==float(`_LCI') & float(`_rfUCI')==float(`_UCI')
			assert !missing(`_ES'[_n-1]) if `touse' & inlist(`_USE', 3, 5) & float(`_rfLCI')==float(`_LCI') & float(`_rfUCI')==float(`_UCI')
		}
		if _rc {
			nois disp as err _n "Error in prediction interval data"
			exit _rc
		}
	}

	// Having added "overall", het. info etc., re-format _LABELS using study names only
	// (otherwise the "adjust" routine in forestplot.ProcessColumns can't have any effect)
	// [added Sep 2017 for v2.2 beta]
	if `sfmtlen'==0 {
		qui gen `strlen' = length(`_LABELS')
		if `"`summaryonly'"'==`""' local anduse `"& inlist(`_USE', 1, 2)"'
		// unless no study estimates (`summaryonly'), limit to _USE==1 or 2
		summ `strlen' if `touse' `anduse', meanonly
		local sfmtlen = r(max)
		drop `strlen'
		
		// May 2018
		// Format as left-justified; default length equal to longest study name
		// But, niche case: in case study names are very short, look at title as well
		// If user really wants ultra-short width, they can convert to string and specify %-s format
		tokenize `: variable label `_LABELS''
		while `"`1'"'!=`""' {
			local sfmtlen = max(`sfmtlen', length(`"`1'"'))
			macro shift
		}
	}
	else local sfmtlen = abs(`sfmtlen')
	format `_LABELS' %-`sfmtlen's		// left justify _LABELS

	// Oct 2018:
	// Generate effect-size column *here*,
	//  so that it exists immediately when results-set is opened (i.e. before running -forestplot-)
	//  for user editing e.g. adding p-values etc.
	// However, *if* it is edited, -forestplot- must be called as "forestplot, nostats rcols(_EFFECT)" otherwise it will be overwritten!
	//  (or use option `nokeepvars')
	if `"`saving'"'!=`""' {
		
		// need to peek into forestplot options to extract `dp'
		local 0 `", `forestplot'"'
		syntax [, DP(integer 2) * ]		
		if `"`eform'"'!=`""' local xexp exp
		summ `_UCI' if `touse', meanonly
		local fmtx = max(1, ceil(log10(abs(`xexp'(r(max)))))) + 1 + `dp'
			
		cap drop _EFFECT
		qui gen str _EFFECT = string(`xexp'(`_ES'), `"%`fmtx'.`dp'f"') if !missing(`_ES')
		qui replace _EFFECT = _EFFECT + " " if !missing(_EFFECT)
		qui replace _EFFECT = _EFFECT + "(" + string(`xexp'(`_LCI'), `"%`fmtx'.`dp'f"') + ", " + string(`xexp'(`_UCI'), `"%`fmtx'.`dp'f"') + ")"
		qui replace _EFFECT = `""' if !(`touse' & inlist(`_USE', 1, 3, 5))
		qui replace _EFFECT = "(Insufficient data)" if `touse' & `_USE' == 2

		local f: format _EFFECT
		tokenize `"`f'"', parse("%s")
		confirm number `2'
		format _EFFECT %-`2's		// left-justify
		label variable _EFFECT `"`effect' (`level'% CI)"'
		local _EFFECT _EFFECT		
	}


	** Finalise forestplot options
	// (do this whether or not `"`graph'"'==`""', so that options can be stored!)
	
	// `noextraline' becomes `nolcolscheck'
	// Logic here is:  `extraline' can be "yes", "no" or missing/undefined
	// If definitely "yes", suppress the check in -forestplot- for columns which might clash with heterogeneity info etc.
	// Hence, it is possible to suppress this check *even if* such columns actually exist, if we think they *don't* in fact clash.
	local lcolscheck = cond(`"`extraline'"'==`"yes"', `"nolcolscheck"', `""')

	// cumulative/influence notes
	// (N.B. all notes (`fpnote') are passed to -forestplot- regardless of `nowarning'; this is then implemented within forestplot.ado)
	if `"`fpnote'"'!=`""' & !inlist("`model'", "fe", "mh") & `"`altwt'"'!=`""' {
		if `"`cumulative'"'!=`""' {
			local fpnote `""`fpnote';" "changes in heterogeneity may mean that cumulative weights are not monotone increasing""'
		}
		else if `"`influence'"'!=`""' {
			local fpnote `""`fpnote'," "expressed relative to the total weight in the overall model""'
		}
	}
	
	
	** Save _dta characteristic containing all the options passed to -forestplot-
	// so that they may be called automatically using "forestplot, useopts"
	// (N.B. `_USE', `_LABELS' and `_WT' should always exist)
	local useopts `"use(`_USE') labels(`_LABELS') wgt(`_WT') `cumulative' `eform' effect(`effect') `keepall' `wt' `stats' `warning' `plotid' `forestplot'"'
	if `"`_BY'"'!=`""' local useopts `"`macval(useopts)' by(`_BY')"'
	if trim(`"`lcols' `nptsvar' `countsvl' `_OE' `_V'"') != `""' {
		local useopts `"`macval(useopts)' lcols(`lcols' `nptsvar' `countsvl' `_OE' `_V') `lcolscheck'"'
	}
	if trim(`"`_VE' `rcols'"') != `""' local useopts `"`macval(useopts)' rcols(`_VE' `rcols')"'
	if `"`rfdist'"'!=`""' local useopts `"`macval(useopts)' rfdist(`_rfLCI' `_rfUCI')"'
	if `"`fpnote'"'!=`""' local useopts `"`macval(useopts)' note(`fpnote')"'
	local useopts = trim(itrim(`"`useopts'"'))
	
	// Store data characteristics
	// NOTE: Only relevant if `saving' (but setup anyway; no harm done)
	char define _dta[FPUseOpts] `"`useopts'"'
	char define _dta[FPUseVarlist] `_ES' `_LCI' `_UCI'
	
	
	** Pass to forestplot
	if `"`graph'"'==`""' {
		if "`cumulative'"!="" {						// cumulative only; not influence
			qui replace `_USE' = 3 if `use3'==1		// ==1 in case new obs added, with `use3' missing
			drop `use3'
		}
		if "`summaryonly'"!="" {
			qui replace `touse' = 0 if inlist(`_USE', 1, 2)
		}
		
		cap nois forestplot `_ES' `_LCI' `_UCI' if `touse', `useopts'
		
		if _rc {
			if `"`err'"'==`""' {
				if _rc==1 nois disp as err _n `"User break in {bf:forestplot}"'
				else nois disp as err _n `"Error in {bf:forestplot}"'
			}
			c_local err noerr		// tell admetan not to also report an "error in BuildResultsSet"
			exit _rc
		}

		return add					// add scalars returned by -forestplot-
	}


	** Finally, save dataset
	if `"`saving'"'!=`""' {

		keep  `labelvars' `core' `tosave' `_EFFECT' `_WT' `lrcols'
		order `labelvars' `core' `tosave' `_EFFECT' `_WT' `lrcols'
		
		if `"`summaryonly'"'!=`""' qui drop if inlist(`_USE', 1, 2)
		
		// 21st May 2018
		local sourceprog = cond(`"`ipdmetan'"'!=`""', "ipdmetan", "admetan")
		label data `"Results set created by `sourceprog'"'
		
		qui compress
		qui save `"`saving'"', `saveopts'
	}	
	

end
	


* Modified version of _prefix_saving.ado
// [AD version] modified so as to include `stacklabel' option
// April 2018, for admetan v2.2

// subroutine of BuildResultsSet

program define my_prefix_savingAD, sclass
	 
	cap nois syntax anything(id="file name" name=fname) [, REPLACE * ]
	if !_rc {
		if "`replace'" == "" {
			local ss : subinstr local fname ".dta" ""
			confirm new file `"`ss'.dta"'
		}
	}
	else {
		di as err "invalid saving() option"
		exit _rc
	}
	
	sreturn clear
	sreturn local filename `"`fname'"'
	sreturn local options `"`replace' `options'"'

end






*******************************************************************************

***************************************************
* Stata subroutines called by PerformMetaAnalysis *  (and its subroutines)
***************************************************


* ProcessPoolingVarlist
// subroutine of PerformMetaAnalysis

// subroutine to processes (non-IV) input varlist to create appropriate varlist for the specified pooling method
// That is, generate study-level effect size variables,
// plus variables used to generate overall/subgroup statistics

program define ProcessPoolingVarlist, rclass

	syntax varlist(numeric min=3 max=7 default=none) [if] [in], ///
		OUTVLIST(varlist numeric min=5 max=8) SUMMSTAT(string) METHOD(string) MODEL(string) ///
		[TVLIST(namelist) BREslow CHI2opt LOGRank noINTeger CC(string) CCVAR(name) ]
	
	marksample touse, novarlist
	
	// unpack varlists
	tokenize `outvlist'
	args _ES _seES _LCI _UCI _WT _NN
	gettoken _USE invlist : varlist
	tokenize `invlist'
	local params : word count `invlist'
	
	
	** Setup for logrank HR (O-E & V)
	if "`logrank'"!="" {
		cap assert `params' == 2
		if _rc {
			disp as err `"Option {bf:logrank} supplied; {bf:admetan} expected a 2-element {it:varlist}"'
			exit 198
		}		
		
		args oe va
		qui replace `_ES'   = `oe'/`va'    if `touse' & `_USE'==1		// logHR
		qui replace `_seES' = 1/sqrt(`va') if `touse' & `_USE'==1		// selogHR
	}

	
	** Otherwise, expect `params' to be 4 or 6
	else {
	
		** Generate effect size vars
		// (N.B. gen as tempvars for now, to accommodate inverse-variance;
		//       but will be renamed to permanent variables later if appropriate)
		
		// Binary outcome (OR, RR, RD)
		if `params' == 4 {
			
			assert inlist("`summstat'", "or", "rr", "irr", "rrr", "rd")
			args e1 f1 e0 f0		// events & non-events in trt; events & non-events in control (aka a b c d)

			tempvar r1 r0
			local type = cond("`integer'"=="", "long", "double")
			qui gen `type' `r1' = `e1' + `f1' if `touse'		// total in trt arm (aka a + b)
			qui gen `type' `r0' = `e0' + `f0' if `touse'		// total in control arm (aka c + d)
			qui replace   `_NN' = `r1' + `r0' if `touse'		// overall total
			
			if `"`cc'"'!=`""' {			// if continuity correction is *possible* ...
			
				qui gen byte `ccvar' = `e1'*`f1'*`e0'*`f0'==0 if `touse' & `_USE'==1
				summ `ccvar', meanonly
				local nz = r(sum)
				if !`nz' {
					drop `ccvar'
					local cc
				}						// ... if continuity correction is *applicable*
				else {					// (N.B. from now on, -confirm numeric var `ccvar'- will be used to check if cc was applied)
					local 0 `cc'
					syntax [anything(id="value supplied to {bf:cc()}")] [, OPPosite EMPirical]
					local ccval = `anything'				
						
					label variable `ccvar' "CC applied?"
					char define `ccvar'[Desc] "Continuity correction applied?"
					char define `ccvar'[Value] `ccval'
					
					local cctype = cond(`"`opposite'`empirical'"'==`""', `"standard"', `"`opposite'`empirical'"')
					char define `ccvar'[Type] "`cctype'"
						
					// Sweeting's "opposite treatment arm" correction
					if `"`opposite'"'!=`""' {
						tempvar cc1 cc0
						qui gen `cc1' = 2*`ccval'*`r1'/(`r1' + `r0')
						qui gen `cc0' = 2*`ccval'*`r0'/(`r1' + `r0')
					}
					
					// Empirical correction
					// (fixed effects only; needs estimate of theta using trials without zero cells)
					// (14th May 2018)
					else if `"`empirical'"'!=`""' {
						
						// fixed effects only
						if !inlist("`model'", "fe", "mh") {
							nois disp as err "Empirical continuity correction only valid with fixed effects"
							exit 198
						}
												
						// more than one study without zero counts needed to estimate "prior"
						qui count if `touse' & `_USE'==1
						if r(N) == `nz' {
							nois disp as err "All studies have zero cells; empirical continuity correction cannot be calculated"
							exit 198
						}						

						tempvar R cc1 cc0
						qui admetan `e1' `f1' `e0' `f0' if `touse' & `_USE'==1, `method' `summstat' nograph nocc
						qui gen `R' = `r0'/`r1'
						qui gen `cc1' = 2*`ccval'*exp(r(eff))/(`R' + exp(r(eff)))
						qui gen `cc0' = 2*`ccval'*`R'        /(`R' + exp(r(eff)))
						drop `R'
					}
					else {
						local cc1 = `ccval'
						local cc0 = `ccval'
					}
				
					tempvar e1_cont f1_cont e0_cont f0_cont t_cont
					qui gen double `e1_cont' = cond(`ccvar', `e1' + `cc1', `e1') if `touse'
					qui gen double `f1_cont' = cond(`ccvar', `f1' + `cc1', `f1') if `touse'
					qui gen double `e0_cont' = cond(`ccvar', `e0' + `cc0', `e0') if `touse'
					qui gen double `f0_cont' = cond(`ccvar', `f0' + `cc0', `f0') if `touse'
						
					tempvar r1_cont r0_cont t_cont
					qui gen double `r1_cont' = `e1_cont' + `f1_cont'
					qui gen double `r0_cont' = `e0_cont' + `f0_cont'
					qui gen double  `t_cont' = `r1_cont' + `r0_cont'
					
					if trim(`"`opposite'`empirical'"') != `""' {
						drop `cc1' `cc0'		// tidy up
					}
				}
			}
			if `"`cc'"'==`""' {
				local e1_cont `e1'
				local f1_cont `f1'
				local e0_cont `e0'
				local f0_cont `f0'
				local r1_cont `r1'
				local r0_cont `r0'
				local t_cont `_NN'
			}
			
			
			** Now branch by outcome measure
			tokenize `tvlist'
			
			if "`summstat'"=="or" {
			
				if `: word count `tvlist'' == 2 args oe va		// i.e. chi2opt (incl. Peto), but *not* M-H
				else args r s pr ps qr qs oe va					// M-H, and optionally also chi2opt
			
				if `"`chi2opt'"'!=`""' {	// N.B. includes Peto OR; continuity correction not applicable here
					tempvar c1 c0 ea
					local a `e1'									// synonym; makes it easier to read code involving chi2
					qui gen `type' `c1' = `e1' + `e0'				// total events (aka a + c)
					qui gen `type' `c0' = `f1' + `f0'				// total non-events (aka b + d)
					qui gen double `ea' = (`r1'*`c1')/ `_NN'		// expected events in trt arm, i.e. E(a) where a = e1
					qui gen double `va' = `r1'*`r0'*`c1'*`c0'/( `_NN'*`_NN'*(`_NN' - 1))	// V(a) where a = e1
					qui gen double `oe' = `a' - `ea'										// O - E = a - E(a) where a = e1
					return local chi2vars `oe' `va'
				}
				
				// Peto method
				if "`method'"=="peto" {
					qui replace `_ES'   = `oe'/`va'    if `touse' & `_USE'==1		// log(Peto OR)
					qui replace `_seES' = 1/sqrt(`va') if `touse' & `_USE'==1		// selogOR
				}

				// M-H or I-V method
				else {
					tempvar v
					if "`method'"!="mh" {
						tempvar r s
					}

					// calculate individual ORs and variances using cc-adjusted counts
					// (on the linear scale, i.e. logOR)
					qui gen double `r' = `e1_cont'*`f0_cont' / `t_cont'
					qui gen double `s' = `f1_cont'*`e0_cont' / `t_cont'
					qui gen double `v' = 1/`e1_cont' + 1/`f1_cont' + 1/`e0_cont' + 1/`f0_cont'
					
					qui replace `_ES'   = ln(`r'/`s') if `touse' & `_USE'==1
					qui replace `_seES' = sqrt(`v')   if `touse' & `_USE'==1
			
					// setup for Mantel-Haenszel method
					if "`method'"=="mh" {
						tempvar p q
						qui gen double `p'  = (`e1_cont' + `f0_cont')/`t_cont'
						qui gen double `q'  = (`f1_cont' + `e0_cont')/`t_cont'
						qui gen double `pr' = `p'*`r'
						qui gen double `ps' = `p'*`s'
						qui gen double `qr' = `q'*`r'
						qui gen double `qs' = `q'*`s'

						local pvlist `r' `s' `pr' `ps' `qr' `qs'		// M-H pooling
					}
				}		/* end non-Peto OR*/
			} 		/* end OR */
			
			// setup for RR/IRR/RRR 
			else if inlist("`summstat'", "rr", "irr", "rrr") {
				args r s p
				tempvar v
				
				qui gen double `r' = `e1_cont'*`r0_cont' / `t_cont'
				qui gen double `s' = `e0_cont'*`r1_cont' / `t_cont'
				qui gen double `v' = 1/`e1_cont' + 1/`e0_cont' - 1/`r1_cont' - 1/`r0_cont'
				qui replace `_ES'   = ln(`r'/`s') if `touse' & `_USE'==1		// logRR 
				qui replace `_seES' = sqrt(`v')   if `touse' & `_USE'==1		// selogRR
				
				// setup for Mantel-Haenszel method
				if "`method'"=="mh" {
					qui gen double `p' = `r1_cont'*`r0_cont'*(`e1_cont' + `e0_cont')/(`t_cont'*`t_cont') - `e1_cont'*`e0_cont'/`t_cont'
					local pvlist `tvlist'							// M-H pooling
				}
			}
			
			// setup for RD
			else if "`summstat'" == "rd" {
				args rdwt rdnum vnum
				tempvar v
				
				// N.B. `_ES' is calculated *without* cc adjustment, to ensure 0/n1 vs 0/n2 really *is* RD=0
				qui gen double `v'  = `e1_cont'*`f1_cont'/(`r1_cont'^3) + `e0_cont'*`f0_cont'/(`r0_cont'^3)
				qui replace `_ES'   = `e1'/`r1' - `e0'/`r0' if `touse' & `_USE'==1
				qui replace `_seES' = sqrt(`v')             if `touse' & `_USE'==1

				// setup for Mantel-Haenszel method
				// N.B. `rdwt' and `rdnum' are calculated *without* cc adjustment, to ensure 0/n1 vs 0/n2 really *is* RD=0
				if "`method'"=="mh" {
					qui gen double `rdwt'  = `r1'*`r0'/ `_NN'
					qui gen double `rdnum' = (`e1'*`r0' - `e0'*`r1')/ `_NN'
					qui gen double `vnum'  = (`e1_cont'*`f1_cont'*(`r0_cont'^3) + `e0_cont'*`f0_cont'*(`r1_cont'^3)) /(`r1_cont'*`r0_cont'*`t_cont'*`t_cont')

					local pvlist `tvlist'					// M-H pooling
				}
			}		// end "rd"
		}		// end if `params' == 4
		
		else {
		
			cap assert `params' == 6
			if _rc {
				disp as err `"Invalid {it:varlist}"'
				exit 198
			}
		
			// N mean SD for continuous data
			assert inlist("`summstat'", "wmd", "smd")
			args n1 mean1 sd1 n0 mean0 sd0

			qui replace `_NN' = `n1' + `n0' if `touse'
				
			if "`summstat'" == "wmd" {
				qui replace `_ES'   = `mean1' - `mean0'                     if `touse' & `_USE'==1
				qui replace `_seES' = sqrt((`sd1'^2)/`n1' + (`sd0'^2)/`n0') if `touse' & `_USE'==1
			}
			else {				// summstat = SMD
				tempvar s
				qui gen double `s' = sqrt( ((`n1'-1)*(`sd1'^2) + (`n0'-1)*(`sd0'^2) )/( `_NN' - 2) )

				if "`method'" == "cohen" {
					qui replace `_ES'   = (`mean1' - `mean0')/`s'                                      if `touse' & `_USE'==1
					qui replace `_seES' = sqrt((`_NN' /(`n1'*`n0')) + (`_ES'*`_ES'/ (2*(`_NN' - 2)) )) if `touse' & `_USE'==1
				}
				else if "`method'" == "glass" {
					qui replace `_ES'   = (`mean1' - `mean0')/`sd0'                                    if `touse' & `_USE'==1
					qui replace `_seES' = sqrt(( `_NN' /(`n1'*`n0')) + (`_ES'*`_ES'/ (2*(`n0' - 1)) )) if `touse' & `_USE'==1
				}
				else if "`method'" == "hedges" {
					qui replace `_ES'   = (`mean1' - `mean0')*(1 - 3/(4*`_NN' - 9))/`s'                    if `touse' & `_USE'==1
					qui replace `_seES' = sqrt(( `_NN' /(`n1'*`n0')) + (`_ES'*`_ES'/ (2*(`_NN' - 3.94)) )) if `touse' & `_USE'==1
				}
			}
		}		// end else (i.e. if `params' == 6)
	}		// end if `params' > 3
	

	// assemble varlist to send to PerformPooling
	return local pvlist `pvlist'
	
end
	
	


***************************************************************

** Extra loop for cumulative/influence meta-analysis
// - If cumulative, loop over observations one by one
// - If influence, exclude observations one by one

program define CumInfLoop, rclass

	syntax varlist(numeric min=3 max=7) [if] [in], SORTBY(varlist) ///
		METHOD(string) MODEL(string) XOUTVLIST(varlist numeric) ALTVLIST(varlist numeric min=2 max=2) ///
		[CUmulative INFluence OVWt SGWt USE3(varname numeric) ROWNAMES(namelist) * ]
	
	marksample touse, novarlist
	gettoken _USE varlist : varlist
	
	qui count if `touse' & `_USE'==1
	if !r(N) exit 2000	
	
	local npts npts
	local rownames : list rownames - npts
	tokenize `xoutvlist'
	args `rownames' _WT2

	tempname critval
	tempvar obsj touse2
	qui bysort `touse' (`_USE' `sortby') : gen long `obsj' = _n if `touse'
	qui count if `touse'
	local jmax = r(N)
	local jmin = cond(`"`sgwt'`ovwt'"'!=`""', 1, `jmax')
	
	forvalues j = `jmin'/`jmax' {

		gen byte `touse2' = `touse' * (`_USE'==1)
	
		// Define `touse' for *input* (i.e. which obs to meta-analyse)
		if `"`cumulative'"'!=`""' qui replace `touse2' = `touse' * inrange(`obsj', 1, `j')		// cumulative: obs from 1 to `j'-1
		else                      qui replace `touse2' = `touse' * (`obsj' != `j')				// influence: all obs except `j'

		// If only one study, return `nsg' to prompt error message at the end of CumInfLoop
		// (N.B. first iteration of cumulative will *always* be a single study, so don't report error in that case)
		local pvlist `varlist'		// default
		qui count if `touse2'
		if r(N)==1 {
			if !(`"`cumulative'"'!=`""' & `j'==1 & `j'<`jmax') return local nsg nsg
		}
		else if "`method'"=="mh" & "`model'"!="mh" local pvlist `altvlist'		// if M-H but random-effects, switch to IV

		cap nois PerformPooling `pvlist' if `touse2', method(`method') model(`model') `options'

		if _rc {
			if _rc==1 nois disp as err `"User break in {bf:admetan.PerformPooling}"'
			else nois disp as err `"Error in {bf:admetan.PerformPooling}"'
			c_local err noerr		// tell admetan not to also report an "error in MetaAnalysisLoop"
			exit _rc
		}
		
		// pooling failed (may not have caused an actual error)
		if missing(r(eff), r(se_eff), r(totwt)) exit 2002
		
		
		** Store statistics returned by PerformPooling in the dataset
		// Same statistics as in `rownames', plus (non-normalised) weights
		
		// First, re-define `touse2' for *output* (i.e. where to store the results of the meta-analysis)
		qui replace `touse2' = `touse' * (`obsj'==`j')

		// Store (non-normalised) weight in the dataset
		qui replace `_WT2' = r(totwt) if `touse2'
		
		// Store other returned statistics in the dataset
		foreach el in `rownames' {
			qui replace ``el'' = r(`el') if `touse2'
		}
				
		drop `touse2'	// tidying up
		
	}		// end forvalues j=`jmin'/`jmax'

	// cumulative: identifier of last estimate, for placement of dotted line in forestplot
	if `"`cumulative'"'!=`""' {
		qui replace `use3' = 1 if `touse' & `obsj'==`jmax'
	}
	
	// Return stats from final run of PerformPooling
	local k = r(k)
	return add
	return local xwt `_WT2'		// return name of `_WT2' in `xoutvlist'
		
	// Check consistency of numbers of *studies*
	qui count if `touse' & `_USE'==1
	local n = r(N)
	if `"`influence'"'!=`""' local --n	// if influence, number of studies will be one less than true number, by definition!
	assert `n' == `k'

	
end





*******************************************************************
	
* PerformPooling
// subroutine of PerformMetaAnalysis

// This routine actually performs the pooling itself.
// non-IV calculations are done in Stata (partly using code taken from metan.ado by Ross Harris et al);
//   iterative IV analyses are done in Mata.

// N.B. study-level results _ES, _seES, _LCI, _UCI are assumed *always* to be on the linear scale (i.e. logOR etc.)
// as this makes building the forestplot easier, and keeps things simple in general.
// For non-IV 2x2 count data, however, the exponentiated effect size may also be returned, e.g. r(OR), r(RR).

program define PerformPooling, rclass

	syntax varlist(numeric min=2 max=8) [if] [in], ///
		METHOD(string) MODEL(string) [SUMMSTAT(string) ///
		DF(varname numeric) NPTS(varname numeric) WGT(varname numeric) WTVAR(varname numeric) ///
		QVLIST(varlist numeric min=2 max=2) INVLIST(varlist numeric min=2 max=6) ///
		CHI2vars(varlist numeric min=2 max=2) T Z BREslow HKsj BArtlett SKovgaard RObust LOGRank noINTeger ///
		ISQSA(real 80) TSQSA(real -99) QE(varname numeric) INIT(string) QProfile LEVEL(real 95) TSQLEVEL(real 95) RFDist RFLEVEL(real 95) ///
		ITOL(real 1e-8) MAXTausq(real -9) REPS(real 1000) MAXITer(real 1000) QUADPTS(real 100) noTRUNCate EIM OIM ]

	// notice no extra options allowed here!!
	marksample touse
	local pvlist `varlist'		// for clarity
	
	tempvar qhet
	tempname Q

	// if no wtvar, gen as tempvar
	if `"`wtvar'"'==`""' {
		local wtvar
		tempvar wtvar
		qui gen `wtvar' = .
	}	
	
	
	** Firstly, check whether only one study
	// if so, cancel random-effects and t-critval
	qui count if `touse'
	if r(N)==1 {
		local model = cond("`method'"=="mh", "mh", "fe")
		local t
	}
		
	
	** Average event rate (binary outcomes only)
	// (do this before any 0.5 adjustments or excluding 0-0 studies)
	local params : word count `invlist'
	if `params'==4 {
		tokenize `invlist'
		args e1 f1 e0 f0
	
		tempname e_sum tger cger
		summ `e1' if `touse', meanonly
		scalar `e_sum' = cond(r(N), r(sum), .)
		summ `f1' if `touse', meanonly
		scalar `tger' = cond(r(N), `e_sum'/(`e_sum' + `r(sum)'), .)
		return scalar tger = `tger'
		
		summ `e0' if `touse', meanonly
		scalar `e_sum' = cond(r(N), r(sum), .)
		summ `f0' if `touse', meanonly
		scalar `cger' = cond(r(N), `e_sum'/(`e_sum' + `r(sum)'), .)
		return scalar cger = `cger'
	}
	
	
	** Mantel-Haenszel methods (binary outcomes only)
	if "`method'"=="mh" {
		tokenize `pvlist'
	
		// Mantel-Haenszel OR
		if "`summstat'"=="or" {
			args r s pr ps qr qs
			
			tempname R S OR eff
			summ `r' if `touse', meanonly
			scalar `R' = cond(r(N), r(sum), .)
			summ `s' if `touse', meanonly
			scalar `S' = cond(r(N), r(sum), .)
			
			scalar `OR'  = `R'/`S'
			scalar `eff' = ln(`OR')
			
			if "`model'"=="mh" {
				tempname PR PS QR QS se_eff
				summ `pr' if `touse', meanonly
				scalar `PR' = cond(r(N), r(sum), .)
				summ `ps' if `touse', meanonly
				scalar `PS' = cond(r(N), r(sum), .)
				summ `qr' if `touse', meanonly
				scalar `QR' = cond(r(N), r(sum), .)
				summ `qs' if `touse', meanonly
				scalar `QS' = cond(r(N), r(sum), .)
				
				// selogOR
				scalar `se_eff' = sqrt( (`PR'/(`R'*`R') + (`PS'+`QR')/(`R'*`S') + `QS'/(`S'*`S')) /2 )

				// check for successful pooling
				if missing(`eff', `se_eff') exit 2002
				
				// return scalars
				return scalar OR = `OR'
				return scalar eff = `eff'
				return scalar se_eff = `se_eff'
				
				// weight
				qui replace `wtvar' = `s' if `touse'
			}
		}		// end M-H OR

		// Mantel-Haenszel RR/IRR/RRR
		else if inlist("`summstat'", "rr", "irr", "rrr") {
			args r s p

			tempname R S RR eff
			summ `r' if `touse', meanonly
			scalar `R' = cond(r(N), r(sum), .)
			summ `s' if `touse', meanonly
			scalar `S' = cond(r(N), r(sum), .)

			scalar `RR'  = `R'/`S'
			scalar `eff' = ln(`RR')

			if "`model'"=="mh" {
				tempname P se_eff
				summ `p' if `touse', meanonly
				scalar `P' = cond(r(N), r(sum), .)
				
				// selogRR
				scalar `se_eff' = sqrt(`P'/(`R'*`S'))
				
				// check for successful pooling
				if missing(`eff', `se_eff') exit 2002
				
				// return scalars
				return scalar RR = `RR'
				return scalar eff = `eff'
				return scalar se_eff = `se_eff'
				
				// weight
				qui replace `wtvar' = `s' if `touse'
			}
		}

		// Mantel-Haenszel RD
		else if "`summstat'"=="rd" {
			args rdwt rdnum vnum
			
			tempname W eff
			summ `rdwt' if `touse', meanonly
			scalar `W' = cond(r(N), r(sum), .)
			summ `rdnum' if `touse', meanonly
			scalar `eff' = r(sum)/`W'							// pooled RD

			if "`model'"=="mh" {
				tempname se_eff
				summ `vnum' if `touse', meanonly
				scalar `se_eff' = sqrt( r(sum) /(`W'*`W') )		// SE of pooled RD
				
				// check for successful pooling
				if missing(`eff', `se_eff') exit 2002

				// return scalars
				return scalar eff = `eff'
				return scalar se_eff = `se_eff'
				
				// weight
				qui replace `wtvar' = `rdwt' if `touse'
			}
		}
		
		// M-H heterogeneity
		tokenize `qvlist'
		args _ES _seES				// needed for heterogeneity calculations		
		
		qui gen double `qhet' = ((`_ES' - `eff') / `_seES') ^2
		summ `qhet' if `touse', meanonly
		scalar `Q' = cond(r(N), r(sum), .)
		drop `qhet'
		
	}	// end of M-H methods
	

	** Chi-squared test (OR only; includes Peto OR) or logrank HR
	if "`chi2vars'"!="" | "`logrank'"!="" {
	
		if "`logrank'"!="" tokenize `invlist'
		else tokenize `chi2vars'
		args oe va
	
		tempname OE VA chi2
		summ `oe' if `touse', meanonly
		scalar `OE' = cond(r(N), r(sum), .)
		summ `va' if `touse', meanonly
		scalar `VA' = cond(r(N), r(sum), .)
		
		scalar `chi2' = (`OE'^2 )/`VA'
		return scalar chi2 = `chi2'
		
		if "`method'"=="peto" | "`logrank'"!="" {
			return scalar oe = `OE'
			return scalar v = `VA'
		}
	}
	
	
	** Breslow-Day heterogeneity (OR only)
	// (Breslow NE, Day NE. Statistical Methods in Cancer Research: Vol. I - The Analysis of Case-Control Studies.
	//  Lyon: International Agency for Research on Cancer 1980)
	if "`breslow'"!="" {
	
		assert "`summstat'"=="or"
		assert `: word count `invlist'' == 4

		tokenize `invlist'
		args e1 f1 e0 f0

		tempvar r1 r0 c1 c0
		qui gen `type' `r1' = `e1' + `f1'		// total in research arm
		qui gen `type' `r0' = `e0' + `f0'		// total in control arm
		qui gen `type' `c1' = `e1' + `e0'		// total events (= a + c)
		qui gen `type' `c0' = `f1' + `f0'		// total non-events (= b + d)				
		
		tempvar afit bfit cfit dfit
		if abs(`OR' - 1) < 0.0001 {										// sep 2015: For future: allow user-defined tolerance?
			local type = cond("`integer'"=="", "long", "double")
			qui gen `type' `n' = `r1' + `r0'
			qui gen double afit = `r1'*`c1'/ `n'
			qui gen double bfit = `r1'*`c0'/ `n'
			qui gen double cfit = `r0'*`c1'/ `n'
			qui gen double dfit = `r0'*`c0'/ `n'
		}
		else {
			tempvar sterm cterm root1 root2
			tempname qterm
			scalar `qterm' = 1 - `OR'
			qui gen double `sterm' = `r0' - `c1' + `OR'*(`r1' + `c1')
			qui gen double `cterm' = -`OR'*`c1'*`r1'
			qui gen double `root1' = (-`sterm' + sqrt(`sterm'*`sterm' - 4*`qterm'*`cterm'))/(2*`qterm')
			qui gen double `root2' = (-`sterm' - sqrt(`sterm'*`sterm' - 4*`qterm'*`cterm'))/(2*`qterm')
			qui gen double `afit' = `root1' if `root2'<0
			qui replace `afit' = `root2' if `root1'<0
			qui replace `afit' = `root1' if (`root2'>`c1') | (`root2'>`r1')
			qui replace `afit' = `root2' if (`root1'>`c1') | (`root1'>`r1')
			qui gen double `bfit' = `r1' - `afit'
			qui gen double `cfit' = `c1' - `afit'
			qui gen double `dfit' = `r0' - `cfit'
		}
		qui gen double `qhet' = ((`e1' - `afit')^2) * ((1/`afit') + (1/`bfit') + (1/`cfit') + (1/`dfit'))
		summ `qhet' if `touse', meanonly
		scalar `Q' = cond(r(N), r(sum), .)
		drop `qhet'
	}
	

	** Generic inverse-variance methods and/or heterogeneity
	// N.B. if qmethod==cochran then method==I-V (but not necess. v.v.; could be RE I-V with M-H or Peto, or OR + Breslow)
	tempname k Qdf crit pvalue
	qui count if `touse'
	scalar `k' = r(N)
	scalar `Qdf' = `k' - 1
	
	if "`model'"!="mh" {

		if "`method'"=="mh" local pvlist `qvlist'		// if M-H but random-effects, switch to I-V (stored in `qvlist')
		assert `: word count `pvlist''==2
		tokenize `pvlist'
		args _ES _seES

		tempname eff se_eff
		qui replace `wtvar' = 1/`_seES'^2 if `touse'
		
		summ `_ES' [aw=`wtvar'] if `touse', meanonly
		scalar `eff' = r(mean)
		scalar `se_eff' = 1/sqrt(r(sum_w))		// fixed-effects SE

		// Derive Cochran's Q; will be returned as r(Qc), separately from "generic" r(Q) (which may contain e.g. Breslow-Day)
		tempname Qc
		qui gen double `qhet' = `wtvar'*((`_ES' - `eff')^2)
		summ `qhet' if `touse', meanonly
		scalar `Qc' = cond(r(N), r(sum), .)
		return scalar Qc = `Qc'
		
		// ... but actually, unless Breslow-Day, or if *method* is M-H, Q and Qc must be the same
		if "`breslow'"=="" & "`method'"!="mh" scalar `Q' = `Qc'
	
		tempname c sigmasq tausq Qwt
		summ `wtvar' [aw=`wtvar'] if `touse', meanonly
		scalar `c' = r(sum_w) - r(mean)
		scalar `sigmasq' = `Qdf'/`c'						// [general note: can this be generalised to other (non-IV) methods?]
		scalar `tausq' = max(0, (`Qc' - `Qdf')/`c')			// default: D+L estimator
		
		
		** Estimators of tausq
		
		// For two-stage estimators sj2s and dk2s, this forms the *initial* estimate of tsq
		if inlist("`model'", "sj2s", "dk2s") {
			local final `model'
			local model `"`init'"'
			
			if substr(trim(`"`model'"'), 1, 2)==`"sa"' {
				tempname tausq0
				scalar `tausq0' = `tausq'
			
				_parse comma model 0 : model
				syntax [, ISQ(string) TAUSQ(string)]
				
				if `"`tausq'"'!=`""' & `"`isq'"'==`""' {
					nois disp as err `"Only one of {bf:isq()} or {bf:tausq()} may be supplied as suboptions to {bf:sa()}"'
					exit 184
				}				
			
				else if `"`tausq'"'!=`""' {
					cap confirm number `tausq'
					if _rc {
						disp as err `"Error in {bf:tausq()} suboption to {bf:sa()}; a single number was expected"'
						exit _rc
					}
					if `tausq'<0 {
						nois disp as err `"tau{c 178} value for sensitivity analysis cannot be negative"'
						exit 198
					}
					local tsqsa = `tausq'
					local isqsa
				}
				else {
					if `"`isq'"'==`""' local isq = 80
					else {
						cap confirm number `isq'
						if _rc {
							disp as err `"Error in {bf:isq()} suboption to {bf:sa()}; a single number was expected"'
							exit _rc
						}
						if `isq'<0 | `isq'>=100 {
							nois disp as err `"I{c 178} value for sensitivity analysis must be at least 0% and less than 100%"'
							exit 198
						}
					}
					local isqsa = `isq'
					local tsqsa = -99
				}
				
				tempname tausq
				scalar `tausq' = `tausq0'
			}
		}		
		
		// Non-iterative
		if "`model'"=="hm" {										// Hartung-Makambi estimator (>0)
			scalar `tausq' = (`Qc'^2)/(`c'*(`Qc' + 2*`Qdf'))
		}
				
		// Non-iterative, making use of the sampling variance of _ES
		else if inlist("`model'", "ev", "vc", "b0", "bp") {
			tempvar residsq v
			tempname var_eff meanv
			
			qui summ `_ES' if `touse'
			qui gen double `residsq' = (`_ES' - r(mean))^2
			scalar `var_eff' = r(Var)
			
			qui gen double `v' = `_seES'^2
			summ `v' if `touse', meanonly
			scalar `meanv' = r(mean)
			
			// empirical variance (>0)
			if "`model'"=="ev" {
				summ `residsq', meanonly
				scalar `tausq' = r(sum)/r(N)
			}
			
			// "variance component" aka Cochran ANOVA-type estimator aka Hedges
			if "`model'"=="vc" scalar `tausq' = `var_eff' - `meanv'
			
			// Rukhin Bayes estimators
			else if inlist("`model'", "b0", "bp") {
				scalar `tausq' = `var_eff'*(`k' - 1)/(`k' + 1)
				if "`model'"=="b0" {
					summ `npts' if `touse', meanonly	
					scalar `tausq' = `tausq' - ( (`r(sum)' - `k')*`Qdf'*`meanv'/((`k' + 1)*(`r(sum)' - `k' + 2)) )
				}
			}
			scalar `tausq' = max(0, `tausq')			// truncate at zero
		}
		
		// Sensitivity analysis: use given Isq/tausq and sigmasq to generate tausq/Isq
		else if "`model'"=="sa" {
			if `tsqsa'==-99 scalar `tausq' = `isqsa'*`sigmasq'/(100 - `isqsa')
			else scalar `tausq' = `tsqsa'
		}
		
		// Check validity of iteropts
		cap assert (`maxtausq'>=0 & !missing(`maxtausq')) | `maxtausq'==-9
		if _rc {
			disp as err "maxtausq() cannot be negative"
			exit 198
		}			
		cap assert `itol'>=0 & !missing(`itol')
		if _rc {
			disp as err "itol() cannot be negative"
			exit 198
		}
		cap {
			assert (`maxiter'>0 & !missing(`maxiter'))
			assert round(`maxiter')==`maxiter'
		}
		if _rc {
			disp as err "maxiter() must be an integer greater than zero"
			exit 198
		}

		// maxtausq: use 10*`tausq' if not specified
		// (and 10 times that for uci -- done in Mata)
		local maxtausq = cond(`maxtausq'==-9, max(10*`tausq', 100), `maxtausq')
			
		// Iterative, using Mata
		if inlist("`model'", "dlb", "mp", "ml", "pl", "reml", "kr") {
		
			// Bootstrap D+L
			// (Kontopantelis PLoS ONE 2013)
			if "`model'"=="dlb" {
				cap {
					assert (`reps'>0 & !missing(`reps'))
					assert round(`reps')==`reps'
				}
				if _rc {
					disp as err "reps() must be an integer greater than zero"
					exit 198
				}
				cap nois mata: DLb("`_ES' `_seES'", "`touse'", `level', `reps')
			}
			
			// Mandel-Paule aka empirical Bayes
			// (DerSimonian and Kacker CCT 2007)				
			// N.B. Mata routine also performs the Viechtbauer Q-profiling routine for tausq CI
			// (Viechtbauer Stat Med 2007; 26: 37-52)
			else if "`model'"=="mp" {
				cap nois mata: GenQ("`_ES' `_seES'", "`touse'", `tsqlevel', (`maxtausq', `itol', `maxiter'))
			}
			
			// REML
			else if inlist("`model'", "reml", "kr") {
				cap nois mata: REML("`_ES' `_seES'", "`touse'", `tsqlevel', (`maxtausq', `itol', `maxiter'))
				return scalar tsq_var = r(tsq_var)
				return scalar ll = r(ll)
			}
			
			// ML, including Profile Likelihood
			// with optional Bartlett's (Huizenga Br J Math Stat Psychol 2011) or Skovgaard's (Guolo Stat Med 2012) correction to the likelihood
			else if inlist("`model'", "ml", "pl") {
				local mlpl `model'
				if "`bartlett'"!="" local mlpl plbart
				else if "`skovgaard'"!="" local mlpl plskov
				cap nois mata: MLPL("`_ES' `_seES'", "`touse'", (`level', `tsqlevel'), (`maxtausq', `itol', `maxiter'), "`mlpl'")
				return scalar tsq_var = r(tsq_var)

				if "`model'"=="pl" {
					return scalar eff_lci = r(eff_lci)
					return scalar eff_uci = r(eff_uci)
					return scalar rc_eff_lci = r(rc_eff_lci)
					return scalar rc_eff_uci = r(rc_eff_uci)
					
					// Need to store these as scalars, in order to calculate critical values
					tempname lr_chi2 lr_z
					scalar `lr_chi2' = r(lr)
					scalar `lr_z' = r(slr)
					
					return scalar lr_chi2 = r(lr)		// Bartlett; Added March 2018
					return scalar lr_z = r(slr)			// Skovgaard; added Jan 2019
					return scalar ll = r(ll)			// Log-likelihood
				}
			}
			
			if _rc {
				if _rc==1 exit _rc
				else if _rc>=3000 {
					nois disp as err "Mata compile-time or run-time error"
					exit _rc
				}
				else if _rc nois disp as err "Error(s) detected during running of Mata code; please check output"
			}

			scalar `tausq' = r(tausq)

			// check tausq limits and set to missing if necessary
			tempname tsq_lci tsq_uci
			scalar `tsq_lci' = r(tsq_lci)
			scalar `tsq_uci' = r(tsq_uci)
			if "`model'"!="dlb" {
				scalar `tsq_lci' = cond(r(rc_tsq_lci)>1 & r(tsq_lci)!=0, ., r(tsq_lci))
				scalar `tsq_uci' = cond(r(rc_tsq_uci)>1, ., r(tsq_uci))
			}
			
			// return extra scalars
			return scalar maxtausq = `maxtausq'
			return scalar tsq_lci  = `tsq_lci'
			return scalar tsq_uci  = `tsq_uci'
			return scalar rc_tausq   = r(rc_tausq)
			return scalar rc_tsq_lci = r(rc_tsq_lci)
			return scalar rc_tsq_uci = r(rc_tsq_uci)			
			
		}	// end if inlist("`model'", "dlb", "mp", "ml", "pl", "reml")
		
		// Viechtbauer Q-profiling routine for tausq CI, if *not* Mandel-Paule tsq estimator
		// (Viechtbauer Stat Med 2007; 26: 37-52)
		if "`qprofile'"!="" & "`model'"!="mp" {
			cap nois mata: GenQ("`_ES' `_seES'", "`touse'", `tsqlevel', (`maxtausq', `itol', `maxiter'))
			
			if _rc {
				if _rc==1 exit _rc
				else if _rc>=3000 {
					nois disp as err "Mata compile-time or run-time error"
					exit _rc
				}
				else if _rc nois disp as err "Error(s) detected during running of Mata code; please check output"
			}				
		
			tempname tsq_lci tsq_uci
			scalar `tsq_lci' = cond(r(rc_tsq_lci)>1 & r(tsq_lci)!=0, ., r(tsq_lci))
			scalar `tsq_uci' = cond(r(rc_tsq_uci)>1, ., r(tsq_uci))
			
			// return extra scalars
			return scalar tsq_lci  = `tsq_lci'
			return scalar tsq_uci  = `tsq_uci'
			return scalar rc_tsq_lci = r(rc_tsq_lci)
			return scalar rc_tsq_uci = r(rc_tsq_uci)
		}
		
		// end of "Iterative, using Mata" section

		
		** Models using alternative weighting schemes
		
		if `"`wgt'"'!=`""' | inlist("`model'", "ivhet", "qe", "gamma", "hc") {
			
			// User-defined weights
			if `"`wgt'"'!=`""' {
				qui replace `wtvar' = `wgt' if `touse'
			}
			
			// "IVhet" weights (i.e. fixed-effect weights applied to additive heterogeneity)
			// (Doi et al, Contemporary Clinical Trials 2015; 45: 130-8)
			// `wtvar' is already correct
			// (same for Henmi & Copas method)
			
			// Quality effects (QE) model (extension of IVHet to incorporate quality scores)
			// (Doi et al, Contemporary Clinical Trials 2015; 45: 123-9)
			else if "`model'"=="qe" {
				tempvar newqe tauqe
				
				// re-scale scores relative to highest value
				summ `qe' if `touse', meanonly
				qui gen double `newqe' = `qe'/r(max)

				// taui and tauhati
				qui gen double `tauqe' = (1 - `newqe')/(`_seES'*`_seES'*`Qdf')
				summ `tauqe' if `touse', meanonly
				local sumtauqe = r(sum)

				summ `newqe' if `touse', meanonly
				if r(min) < 1 {				// additional correction if any `newqe' are < 1, to avoid neg. weights
					tempvar newqe_adj
					qui gen double `newqe_adj' = `newqe' + r(sum)*`tauqe'/(`sumtauqe'*`Qdf')
					summ `newqe_adj' if `touse', meanonly
					qui replace `tauqe' = (`sumtauqe'*`k'*`newqe_adj'/r(sum)) - `tauqe'
				}
				else qui replace `tauqe' = (`sumtauqe'*`k'*`newqe'/r(sum)) - `tauqe'
				
				// Point estimate uses weights = qi/vi + tauhati
				qui replace `wtvar' = (`newqe'/(`_seES'^2)) + `tauqe' if `touse'
			}
			
			// Biggerstaff and Tweedie approximate Gamma-based weighting
			// (also derives a variance and confidence interval for tausq_DL)
			else if "`model'"=="gamma" {
				cap nois mata: Gamma("`_ES' `_seES'", "`touse'", "`wtvar'", `tsqlevel', (`maxtausq', `itol', `maxiter', `quadpts'))
				if _rc {
					if _rc==1 exit _rc
					else if _rc>=3000 {
						nois disp as err "Mata compile-time or run-time error"
						exit _rc
					}
					else if _rc nois disp as err "Error(s) detected during running of Mata code; please check output"
				}
				
				// check tausq limits and set to missing if necessary
				tempname tsq_lci tsq_uci
				scalar `tsq_lci' = r(tsq_lci)
				scalar `tsq_uci' = r(tsq_uci)
				scalar `tsq_lci' = cond(r(rc_tsq_lci)>1 & `tsq_lci'!=0, ., `tsq_lci')
				scalar `tsq_uci' = cond(r(rc_tsq_uci)>1, ., `tsq_uci')
			
				// return extra scalars
				return scalar maxtausq = `maxtausq'
				return scalar rc_tausq = r(rc_tausq)
				return scalar tsq_var = r(tsq_var)
				
				if "`qprofile'"=="" {
					return scalar tsq_lci  = `tsq_lci'
					return scalar tsq_uci  = `tsq_uci'
					return scalar rc_tsq_lci = r(rc_tsq_lci)
					return scalar rc_tsq_uci = r(rc_tsq_uci)
				}
			}
			
			
			** Generate pooled eff and se_eff

			// Specify underlying model: fixed-effects, or random-effects with additive heterogeneity
			// (N.B. if *multiplicative* heterogeneity, factor simply multiplies the final pooled variance)
			local vi = cond("`model'"=="fe", "`_seES'^2", "`_seES'^2 + `tausq'")
			
			// Apply weighting
			summ `_ES' [aw=`wtvar'] if `touse', meanonly
			scalar `eff' = r(mean)
			
			// corrected Aug 2017 for v2.1
			tempvar wtvce
			summ `wtvar' if `touse', meanonly
			qui gen double `wtvce' = (`vi') * `wtvar'^2 / r(sum)^2
			summ `wtvce' if `touse', meanonly
			scalar `se_eff' = sqrt(r(sum))
			
		}	// end if `"`wgt'"'!=`""' | inlist("`model'", "ivhet", "qe", "gamma", "hc")
			// (i.e. models using alternative weighting schemes)

		// Generate pooled eff and se_eff under standard weighting scheme
		else if !inlist("`model'", "fe", "mu") {							// corrected Dec 2018 for v3.0.2
		
			// First, finalise two-step estimators
			if inlist("`final'", "sj2s", "dk2s") {
				local model `final'
				
				tempname Qr0
				qui replace `qhet' = ((`_ES' - `eff')^2)/((`_seES'^2) + `tausq')
				summ `qhet' if `touse', meanonly
				scalar `Qr0' = r(sum)
				
				if "`final'"=="sj2s" {					// two-step Sidik-Jonkman
					// scalar `tausq' = cond(`tausq'==0, `sigmasq'/99, `tausq') * `Qr0'/`Qdf'		// March 2018: if tsq=0, use Isq=1%
					scalar `tausq' = `tausq' * `Qr0'/`Qdf'					
				}
				else if "`final'"=="dk2s" {				// two-step DerSimonian-Kacker (MM only)
					tempname wi1 wi2 wis1 wis2 
					summ `wtvar' if `touse', meanonly
					scalar `wi1' = r(sum)				// sum of weights
					summ `wtvar' [aw=`wtvar'] if `touse', meanonly
					scalar `wi2' = r(sum)				// sum of squared weights				
					summ `wtvar' [aw=`_seES'^2] if `touse', meanonly
					scalar `wis1' = r(sum)				// sum of weight * variance
					summ `wtvar' [aw=`wtvar' * (`_seES'^2)] if `touse', meanonly
					scalar `wis2' = r(sum)				// sum of squared weight * variance
					
					scalar `tausq' = (`Qr0' - (`wis1' - `wis2'/`wi1')) / (`wi1' - `wi2'/`wi1')
					scalar `tausq' = max(0, `tausq')	// truncate at zero
				}
			}
		
			// Now finalise wtvar, eff, se_eff
			qui replace `wtvar' = 1/(`_seES'^2 + `tausq') if `touse'
			summ `_ES' [aw=`wtvar'] if `touse', meanonly
			scalar `eff' = r(mean)
			scalar `se_eff' = 1/sqrt(r(sum_w))
		}		
		
		// "Generalised" (random-effects) version of Cochran's Q
		local Qr `Qc'
		if "`model'"!="fe" | "`wgt'"!="" {		// if fe, Qr = Qc			
			
			// August 2017 (for v2.1)
			// if user-defined weights then use approx. (inverse) variances back-derived from `wtvce'
			// [i.e. pooled variance `se_eff'^2 is multiplied by `wtvce', normalised by sum(`wtvce')=`se_eff'^2]
			local Qwt = cond("`wgt'"!="", `"(`wtvce' / `se_eff'^4)"', "`wtvar'")
			
			tempname Qr
			qui replace `qhet' = `wtvar'*((`_ES' - `eff')^2)
			summ `qhet' if `touse', meanonly
			scalar `Qr' = cond(r(N), r(sum), .)
			return scalar Qr = `Qr'
		}

		// Henmi and Copas method also fits here
		//  (Henmi and Copas, Stat Med 2010; DOI: 10.1002/sim.4029)
		// Begins along the same lines as IVHet; that is, a RE model with inv-variance weighting
		//   but goes on to estimate the distribution of pivotal quantity U using a Gamma distribution (c.f. Biggerstaff & Tweedie).
		if "`model'"=="hc" {
			cap nois mata: HC("`_ES' `_seES'", "`touse'", `level', (`itol', `maxiter', `quadpts'))
			if _rc {
				if _rc==1 exit _rc
				else if _rc>=3000 {
					nois disp as err "Mata compile-time or run-time error"
					exit _rc
				}
				else if _rc nois disp as err "Error(s) detected during running of Mata code; please check output"
			}
			
			return scalar u = r(u)
			scalar `crit'   = r(crit)
			scalar `pvalue' = r(p)
		}
		
		
		** Models that apply a post-hoc variance correction
		// i.e. either a true multiplicative heterogeneity model
		// or HKSJ, which applies a multiplicative variance correction to an additive heterogeneity model
		// or Kenward-Roger, which replaces the variance "wholesale" with an improved estimate.

		// Multiplicative heterogeneity (e.g. Thompson and Sharp, Stat Med 1999)
		// (equivalent to the "full variance" estimator suggested by Sandercock
		// (https://metasurv.wordpress.com/2013/04/26/
		//    fixed-or-random-effects-how-about-the-full-variance-model-resolving-a-decades-old-bunfight)
		else if "`model'"=="mu" scalar `se_eff' = `se_eff' * sqrt(`Qc'/`Qdf')

		// Hartung-Knapp-Sidik-Jonkman variance inflation method
		// (Roever et al, BMC Med Res Methodol 2015)
		else if "`hksj'"!="" {

			// Truncate at 1, i.e. don't use if *under* dispersion present (unless `notruncate' option)
			// (this is the recommended "modified" version of the HKSJ method -- see Roever 2015)
			tempname cf
			scalar `cf' = `Qr'/`Qdf'
			if "`truncate'"=="" scalar `cf' = max(1, `cf')
			scalar `se_eff' = `se_eff' * sqrt(`cf')
		}
		
		// Sidik-Jonkman robust ("sandwich-like") variance estimator
		// (Sidik and Jonkman, Comp Stat Data Analysis 2006)
		// (N.B. HKSJ estimator also described in the same paper)
		else if "`robust'"!="" {
			tempname sumwi
			tempvar vr_part
			summ `wtvar' if `touse', meanonly
			scalar `sumwi' = r(sum)
			qui gen double `vr_part' = `wtvar' * `wtvar' * ((`_ES' - `eff')^2) / (1 - (`wtvar'/`sumwi'))
			summ `vr_part', meanonly
			scalar `se_eff' = sqrt(r(sum))/`sumwi'
		}

		// Kenward-Roger variance inflation method
		// (Morris et al, Stat Med 2018)
		else if "`model'"=="kr" {
			tempname wi1 wi2 wi3 nwi2 nwi3
			summ `wtvar' if `touse', meanonly
			scalar `wi1' = r(sum)				// sum of weights
			summ `wtvar' [aw=`wtvar'] if `touse', meanonly
			scalar `wi2' = r(sum)				// sum of squared weights
			summ `wtvar' [aw=`wtvar'^2] if `touse', meanonly
			scalar `wi3' = r(sum)				// sum of cubed weights
			scalar `nwi2' = `wi2'/`wi1'			// "normalised" sum of squared weights [i.e. sum(wi:^2)/sum(wi)]
			scalar `nwi3' = `wi3'/`wi1'			// "normalised" sum of cubed weights [i.e. sum(wi:^3)/sum(wi)]		
				
			// expected information
			tempname I
			scalar `I' = `wi2'/2 - `nwi3' + (`nwi2'^2)/2
			
			// observed information
			if "`oim'"!="" {
				tempvar resid resid2
				tempname q2 q3
				
				qui gen double `resid' = `_ES' - `eff'
				summ `resid' [aw=`wtvar'^2] if `touse', meanonly
				scalar `q2' = r(sum)			// quadratic involving squared weights and residual
				
				qui gen double `resid2' = `resid'^2
				summ `resid2' [aw=`wtvar'^3] if `touse', meanonly
				scalar `q3' = r(sum)			// quadratic involving cubed weights and squared residual
				
				scalar `I' = max(0, (`q2'^2)/`wi1' + `q3' - `I')
			}
			
			// corrected se_eff [sqrt(Phi_A) in Kenward-Roger papers]
			tempname W V
			scalar `W' = 1/`I'		// approximation of var(tausq)
			scalar `V' = (1/`wi1') + 2*`W'*(`wi3' - (`wi2'^2)/`wi1')/(`wi1'^2)
			scalar `se_eff' = sqrt(`V')
			
			// denominator degrees of freedom
			tempname A df_kr
			scalar `A' = `W' * (`V'*`wi2')^2
			scalar `df_kr' = 2 / `A'
			return scalar df_kr = `df_kr'
		}
		
		// Prediction intervals
		// (uses k-2 df, c.f. Higgins & Thompson 2009; but also see e.g. http://www.metafor-project.org/doku.php/faq#for_random-effects_models_fitt)
		if "`rfdist'"!="" {
			if `k'<3 c_local nrfd = 1		// tell PerformMetaAnalysis to display error
			else {
				tempname rfcritval
				scalar `rfcritval' = invttail(`k'-2, .5 - `rflevel'/200)
				return scalar rflci = `eff' - `rfcritval' * sqrt(`tausq' + `se_eff'^2)
				return scalar rfuci = `eff' + `rfcritval' * sqrt(`tausq' + `se_eff'^2)
			}
		}
		
		
		** Finish off inverse-variance
		// check for successful pooling
		if missing(`eff', `se_eff') exit 2002
		
		// return scalars
		return scalar eff = `eff'
		return scalar se_eff = `se_eff'
		return scalar sigmasq = `sigmasq'
		return scalar tausq = `tausq'

	}	// end inverse-variance (i.e. if "`model'"!="mh")

	
	** Critical values and p-values
	if "`model'"=="pl" {				// N.B. PL confidence limits have already been calculated
		if "`skovgaard'`z'"!="" {
			scalar `crit' = invnormal(.5 + `level'/200)
			scalar `pvalue' = 2*normal(-abs(`lr_z'))
		}
		else {
			scalar `crit' = invchi2(1, `level'/100)
			scalar `pvalue' = chi2tail(1, `lr_chi2')
		}
	}
	else {
		if "`chi2vars'"!="" | "`logrank'"!="" {
			scalar `crit' = invchi2(1, `level'/100)
			scalar `pvalue' = chi2tail(1, `chi2')
		}
		else if "`model'"=="kr" {
			scalar `crit' = invttail(`df_kr', .5 - `level'/200)
			scalar `pvalue' = 2*ttail(`df_kr', abs(`eff'/`se_eff'))
		}
		else if `"`t'"'!=`""' {
			scalar `crit' = invttail(`Qdf', .5 - `level'/200)
			scalar `pvalue' = 2*ttail(`Qdf', abs(`eff'/`se_eff'))
		}
		else if "`model'"!="hc" {		// N.B. HC crit + p-value have already been calculated
			scalar `crit' = invnormal(.5 + `level'/200)
			scalar `pvalue' = 2*normal(-abs(`eff'/`se_eff'))
		}
		
		// Confidence intervals
		if "`chi2vars'"!="" | "`logrank'"!="" {		// crit.value is chi2, but CI is based on z
			return scalar eff_lci = `eff' - invnormal(.5 + `level'/200) * `se_eff'
			return scalar eff_uci = `eff' + invnormal(.5 + `level'/200) * `se_eff'
		}
		else {								// else we can use crit.value (z or t, or u if HC)
			return scalar eff_lci = `eff' - `crit' * `se_eff'
			return scalar eff_uci = `eff' + `crit' * `se_eff'
		}
	}
	return scalar crit = `crit'
	return scalar pvalue = `pvalue'
	
	
	** Derive, and return, I-squared and (modified) H-squared
	tempname Isqval HsqM
	
	// Sensitivity analysis
	if "`model'"=="sa" {
		if `tsqsa'==-99 {
			// scalar `Isq'  = `isqsa'/100				// altered Sep 2017 for v2.1 to align with metan/metaan behaviour
			scalar `Isqval'  = `isqsa'
			scalar `HsqM' = `isqsa'/(100 - `isqsa')
			return scalar Isq = `Isqval'
			return scalar HsqM = float(`HsqM')			// If user-defined I^2 is a round(ish) number, so should H^2 be
		}
		else {
			// scalar `Isq' = `tsqsa'/(`tsqsa' + r(sigmasq))		// altered Sep 2017 for v2.1 to align with metan/metaan behaviour
			scalar `Isqval' = 100*`tsqsa'/(`tsqsa' + `sigmasq')
			scalar `HsqM' = `tsqsa'/`sigmasq'
			return scalar Isq = `Isqval'
			return scalar HsqM = `HsqM'
		}
	}
	
	// Non inverse-variance model
	else if "`model'"=="mh" | ("`model'"=="fe" & ("`method'"=="peto" | "`breslow'"!="")) {
		/*
		scalar `Isq' = cond(missing(r(tausq)), (r(Qc)-`k'+1)/r(Qc), ///		// altered Sep 2017 for v2.1 to align with metan/metaan behaviour
			r(tausq)/(r(tausq) + r(sigmasq)))
		*/
		scalar `Isqval' = max(0, 100*(`Q' - `Qdf')/`Q')
		scalar `HsqM' = max(0, (`Q' - `Qdf')/`Qdf')
		return scalar Isq = `Isqval'
		return scalar HsqM = `HsqM'
	}
	
	// Inverse-variance model
	else {
		scalar `Isqval' = 100*`tausq'/(`tausq' + `sigmasq')
		scalar `HsqM' = `tausq'/`sigmasq'
		return scalar Isq = `Isqval'
		return scalar HsqM = `HsqM'
	}

	
	// Return other scalars
	return scalar k   = `k'		// k = number of studies (= count if `touse')
	return scalar Q   = `Q'		// generic heterogeneity statistic (incl. Peto, M-H, Breslow-Day)
	return scalar Qdf = `Qdf'	// Q degrees of freedom (= `k' - 1)

	// Return weights for CumInfLoop
	summ `wtvar' if `touse', meanonly
	return scalar totwt = cond(r(N), r(sum), .)		// sum of (non-normalised) weights

end





***********************************************************

* Program to generate confidence intervals for individual studies (NOT pooled estimates)
// subroutine of PerformMetaAnalysis

// identical subroutine also used in ipdover.ado

program define GenConfInts, rclass

	syntax varlist(numeric min=2 max=6 default=none) [if] [in], CItype(string) ///
		OUTVLIST(varlist numeric) [ DF(varname numeric) LEVEL(real 95) ]

	marksample touse, novarlist
	
	// if no data to process, exit without error
	return scalar level = `level'
	qui count if `touse'
	if !r(N) exit

	// Unpack varlists
	tokenize `outvlist'
	args _ES _seES _LCI _UCI _WT _NN
	local params : word count `varlist'		// `varlist' == `invlist'
		
	// Confidence limits need calculating if:
	//  - not supplied by user (i.e. `params'!=3); or
	//  - desired coverage is not 95%
	if `params'==3 & `level'==95 exit
	
	* Calculate confidence limits for original study estimates using specified `citype'
	// (unless limits supplied by user)
	if "`citype'"=="normal" {			// normal distribution - default
		tempname critval
		scalar `critval' = invnormal(.5 + `level'/200)
		qui replace `_LCI' = `_ES' - `critval'*`_seES' if `touse'
		qui replace `_UCI' = `_ES' + `critval'*`_seES' if `touse'
	}
		
	else if inlist("`citype'", "t", "logit") {		// t or logit distribution
	
		cap confirm numeric variable `df'
		if !_rc {
			summ `df' if `touse', meanonly			// use supplied df if available
			cap assert r(max) < .
			if _rc {
				nois disp as err `"Degrees-of-freedom variable {bf:`df'} contains missing values;"'
				nois disp as err `"  cannot use {bf:`citype'}-based confidence intervals for study estimates"'
				exit 198
			}
		}
		else {
			cap confirm numeric variable `_NN'
			if !_rc {
				summ `_NN' if `touse', meanonly			// otherwise try using npts
				cap assert r(max) < .
				if _rc {
					nois disp as err `"Participant numbers not available for all studies;"'
					nois disp as err `"  cannot use {bf:`citype'}-based confidence intervals for study estimates"'
					exit 198
				}
				tempvar df
				qui gen `: type `_NN'' `df' = `_NN' - 2			// use npts-2 as df for t distribution of df not explicitly given
				local disperr `"nois disp as err `"Note: Degrees of freedom for {bf:`citype'}-based confidence intervals not supplied; using {it:n-2} as default"'"'
				// delay error message until after checking _ES is between 0 and 1 for logit
			}
			else {
				nois disp as err `"Neither degrees-of-freedom nor participant numbers available;"'
				nois disp as err `"  cannot use {bf:`citype'}-based confidence intervals for study estimates"'
				exit 198
			}
		}
		
		tempvar critval
		qui gen double `critval' = invttail(`df', .5 - `level'/200)
		
		if "`citype'"=="t" {
			qui replace `_LCI' = `_ES' - `critval'*`_seES' if `touse'
			qui replace `_UCI' = `_ES' + `critval'*`_seES' if `touse'
		}
		else {								// logit, proportions only (for formula, see Stata manual for -proportion-)
			summ `_ES' if `touse', meanonly
				if r(min)<0 | r(max)>1 {
				nois disp as err "{bf:citype(logit)} may only be used with proportions"
				exit 198
			}
			qui replace `_LCI' = invlogit(logit(`_ES') - `critval'*`_seES'/(`_ES'*(1 - `_ES'))) if `touse'
			qui replace `_UCI' = invlogit(logit(`_ES') + `critval'*`_seES'/(`_ES'*(1 - `_ES'))) if `touse'
		}
	}
		
	else if inlist("`citype'", "cornfield", "exact", "woolf") {		// options to pass to -cci-; summstat==OR only
		tokenize `varlist'
		args a b c d		// events & non-events in trt; events & non-events in control (c.f. -metan- help file)

		// sort appropriately, then find observation number of first relevant obs
		tempvar obs
		qui bysort `touse' : gen long `obs' = _n if `touse'			// N.B. MetaAnalysisLoop uses -sortpreserve-
		sort `obs'													// so this sorting should not affect the original data
		summ `obs' if `touse', meanonly
		forvalues j = 1/`r(max)' {
			`version' qui cci `=`a'[`j']' `=`b'[`j']' `=`c'[`j']' `=`d'[`j']', `citype' level(`level')
			qui replace `_LCI' = log(`r(lb_or)') in `j'
			qui replace `_UCI' = log(`r(ub_or)') in `j'
		}
	}
	
	// Now display delayed error message if appropriate
	`disperr'

end






****************************************************************************



********************
* Mata subroutines *
********************

mata:


/* Kontopantelis's bootstrap DerSimonian-Laird estimator */
// (PLoS ONE 2013; 8(7): e69930, and also implemented in metaan)
// N.B. using originally estimated ES within the re-samples, as in Kontopantelis's paper */
void DLb(string scalar varlist, string scalar touse, real scalar level, real scalar reps)
{
	// setup
	real colvector yi, se, vi, wi
	varlist = tokens(varlist)
	st_view(yi=., ., varlist[1], touse)
	if(length(yi)==0) exit(error(111))
	st_view(se=., ., varlist[2], touse)
	vi = se:^2
	wi = 1:/vi

	// calculate FE eff
	real scalar eff
	eff = mean(yi, wi)	

	// carry out bootstrap procedure
	transmorphic B, J
	real colvector report
	B = mm_bs(&ftausq(), (yi, vi), 1, reps, 0, 1, ., ., ., eff)
	J = mm_jk(&ftausq(), (yi, vi), 1, 1, ., ., ., ., ., eff)
	report = mm_bs_report(B, ("mean", "bca"), level, 0, J)

	// truncate at zero
	report = report:*(report:>0)
	
	// return tausq and confidence limits
	real scalar tausq
	tausq = report[1]
	st_numscalar("r(tausq)", tausq)
	st_numscalar("r(tsq_lci)", report[2])
	st_numscalar("r(tsq_uci)", report[3])
}

real scalar ftausq(real matrix coeffs, real colvector weight, real scalar eff) {
	real colvector yi, vi, wi
	real scalar k, Q, c, tausq
	yi = select(coeffs[,1], weight)
	vi = select(coeffs[,2], weight)
	k = length(yi)
	wi = 1:/vi
	Q = crossdev(yi, eff, wi, yi, eff)
	c = sum(wi) - mean(wi, wi)
	tausq = max((0, (Q-(k-1))/c))
	return(tausq)
}



/* "Generalised Q" methods */
void GenQ(string scalar varlist, string scalar touse, real scalar tsqlevel, real rowvector iteropts)
{
	// setup
	real colvector yi, se, vi, wi
	varlist = tokens(varlist)
	st_view(yi=., ., varlist[1], touse)
	if(length(yi)==0) exit(error(111))
	st_view(se=., ., varlist[2], touse)
	vi = se:^2
	wi = 1:/vi

	real scalar maxtausq, itol, maxiter
	maxtausq = iteropts[1]
	itol = iteropts[2]
	maxiter = iteropts[3]
	
	real scalar k
	k = length(yi)
	
	/* Mandel-Paule estimator of tausq (J Res Natl Bur Stand 1982; 87: 377-85) */
	// (also DerSimonian & Kacker, Contemporary Clinical Trials 2007; 28: 105-114)
	// ... can be shown to be equivalent to the "empirical Bayes" estimator
	// (e.g. Sidik & Jonkman Stat Med 2007; 26: 1964-81)
	// and converges more quickly
	real scalar rc_tausq, tausq
	rc_tausq = mm_root(tausq=., &Q_crit(), 0, maxtausq, itol, maxiter, yi, vi, k, k-1)
	st_numscalar("r(tausq)", tausq)
	st_numscalar("r(rc_tausq)", rc_tausq)
	

	/* Confidence interval for tausq by generalised Q-profiling */
	// Viechtbauer Stat Med 2007; 26: 37-52
	// (N.B. most natural point estimate is Mandel-Paule, but any estimate will do)
	real scalar eff, Qmin, Qmax
	eff = mean(yi, wi)							// fixed-effects estimate
	Qmin = crossdev(yi, eff, wi, yi, eff)		// Q(0) = standard Cochran's Q heterogeneity statistic (when tausq=0)
	wi = 1:/(vi:+maxtausq)
	eff = mean(yi, wi)
	Qmax = crossdev(yi, eff, wi, yi, eff)
	
	// estimate tausq confidence limits
	real scalar Q_crit_hi, Q_crit_lo, tsq_lci, rc_tsq_lci, tsq_uci, rc_tsq_uci
	Q_crit_hi = invchi2(k-1, .5 + tsqlevel/200)		// higher critical value (0.975) to compare GenQ against (for *lower* bound of tausq)
	Q_crit_lo = invchi2(k-1, .5 - tsqlevel/200)		//  lower critical value (0.025) to compare GenQ against (for *upper* bound of tausq)
	
	if (Qmin < Q_crit_lo) {			// if Q(0) is less the lower critical value, interval is set to null
		rc_tsq_lci = 2
		rc_tsq_uci = 2
		tsq_lci = 0
		tsq_uci = 0
	}	
	else {
		if (Qmax > Q_crit_lo) {		// If Q(maxtausq) is larger than the lower critical value...
			rc_tsq_uci = 2
			tsq_uci = maxtausq		// ...upper bound for tausq is tausqmax
		}
		else {
			rc_tsq_uci = mm_root(tsq_uci=., &Q_crit(), 0, maxtausq, itol, maxiter, yi, vi, k, Q_crit_lo)
		}
	}
	if (Qmax > Q_crit_hi) {			// If Q(maxtausq) is larger than the higher critical value, interval is set to null
		rc_tsq_lci = 2
		rc_tsq_uci = 2
		tsq_lci = maxtausq
		tsq_uci = maxtausq
	}
	else {
		if (Qmin < Q_crit_hi) {		// If Q(0) is less than the higher critical value...
			rc_tsq_lci = 2
			tsq_lci = 0				// ...lower bound for tausq is 0
		}		
		else {
			rc_tsq_lci = mm_root(tsq_lci=., &Q_crit(), 0, maxtausq, itol, maxiter, yi, vi, k, Q_crit_hi)
		}
	}
	
	// return confidence limits and rc codes
	st_numscalar("r(tsq_lci)", tsq_lci)
	st_numscalar("r(tsq_uci)", tsq_uci)
	st_numscalar("r(rc_tsq_lci)", rc_tsq_lci)
	st_numscalar("r(rc_tsq_uci)", rc_tsq_uci)
}

real scalar Q_crit(real scalar tausq, real colvector yi, real colvector vi, real scalar k, real scalar crit) {
	real colvector wi
	real scalar eff, newtausq
	wi = 1:/(vi:+tausq)
	eff = mean(yi, wi)
	newtausq = (k/crit)*crossdev(yi, eff, wi, yi, eff)/sum(wi) - mean(vi, wi)	// corrected June 2015
	return(tausq - newtausq)
}



/* ML + optional PL (for likelihood profiling for ES CI) */
// (N.B. pass wi back-and-forth as it needs to be calculated anyway for tausq likelihood profiling)
void MLPL(string scalar varlist, string scalar touse, real rowvector levels, real rowvector iteropts, string scalar model)
{
	// setup
	real colvector yi, se, vi, wi, eff
	varlist = tokens(varlist)
	st_view(yi=., ., varlist[1], touse)
	if(length(yi)==0) exit(error(111))
	st_view(se=., ., varlist[2], touse)
	vi = se:^2

	real scalar maxtausq, itol, maxiter
	maxtausq = iteropts[1]
	itol = iteropts[2]
	maxiter = iteropts[3]
	
	real scalar level, tsqlevel
	level = levels[1]
	tsqlevel = levels[2]
	
	// Iterative point estimate for tausq using ML
	real scalar tausq, rc_tausq
	rc_tausq = mm_root(tausq=., &ML_est(), 0, maxtausq, itol, maxiter, yi, vi)
	st_numscalar("r(tausq)", tausq)
	st_numscalar("r(rc_tausq)", rc_tausq)
	
	// Point estimate for eff, using ML point estimate of tausq
	// (also, variance of tausq using inverse Fisher information)
	wi = 1:/(vi:+tausq)
	eff = mean(yi, wi)
	tsq_var = 2*sum(wi:^2)^-1
	st_numscalar("r(tsq_var)", tsq_var)	
	
	// Calculate ML log-likelihood value (ignoring constant term)
	// based on ML point estimates of eff and tausq
	// [NOTE: first term is *positive* since wi = 1/(vi+tausq).
	//  In the literature, likelihood is usually stated in terms of **vi**
	//  and hence the term is *negative*.]
	real scalar ll, crit, tsq_lci, rc_tsq_lci, tsq_uci, rc_tsq_uci
	ll = 0.5*sum(ln(wi)) - 0.5*crossdev(yi, eff, wi, yi, eff)
	
	// Confidence interval for tausq using likelihood profiling
	crit = ll - invchi2(1, tsqlevel/100)/2

	rc_tsq_lci = mm_root(tsq_lci=., &ML_profile_tausq(), 0, tausq - itol, itol, maxiter, yi, vi, crit)
	st_numscalar("r(tsq_lci)", tsq_lci)
	st_numscalar("r(rc_tsq_lci)", rc_tsq_lci)
	
	rc_tsq_uci = mm_root(tsq_uci=., &ML_profile_tausq(), tausq + itol, 10*maxtausq, itol, maxiter, yi, vi, crit)
	st_numscalar("r(tsq_uci)", tsq_uci)
	st_numscalar("r(rc_tsq_uci)", rc_tsq_uci)
	
	// Profile likelihood
	if (model!="ml") {
	
		// Bartlett's correction
		// (see e.g. Huizenga et al, Br J Math Stat Psychol 2011)
		real scalar BCFinv
		BCFinv = 1
		if (model=="plbart") {
			BCFinv = 1 + 2*mean(wi, wi:^2)/sum(wi) - 0.5*mean(wi, wi)/sum(wi)
			st_numscalar("r(BCF)", 1/BCFinv)
		}
				
		// Log-likelihood based test statistic
		// (evaluated at b = 0)
		real scalar ll0, lr
		crit = ll - invchi2(1, level/100)*BCFinv/2
		ll0 = ML_profile_eff(0, yi, vi, crit, iteropts)
		ll0 = ll0 + crit
		lr = 2*(ll - ll0) / BCFinv

		// Signed likelihood statistic
		// (evaluated at b = 0)
		real scalar slr
		if (lr==0) slr = 0
		else slr = sign(eff)*sqrt(lr)

		// Confidence interval for ES using likelihood profiling
		// (use ten times the ML lci and uci for search limits)
		real scalar llim, ulim, eff_lci, eff_uci, rc_eff_lci, rc_eff_uci
		llim = eff - 19.6/sqrt(sum(wi))
		ulim = eff + 19.6/sqrt(sum(wi))
		
		// Skovgaard's correction to the signed likelihood statistic
		if (model=="plskov") {
		
			// Collect ML values of eff, tausq, ll
			real rowvector params
			params = (eff, tausq, ll)

			//  can't directly correct the critical value, due to the square root (i.e. expression is non-linear)
			//  so instead need to pass the critical value to the iteration procedure, and correct afterwards
			crit = invnormal(.5 + level/200)
			slr = ML_skov(0, yi, vi, wi, params, crit, iteropts)
			slr = slr + crit
			
			rc_eff_lci = mm_root(eff_lci=., &ML_skov(), llim, eff-itol, itol, maxiter, yi, vi, wi, params,  crit, iteropts)
			rc_eff_uci = mm_root(eff_uci=., &ML_skov(), eff+itol, ulim, itol, maxiter, yi, vi, wi, params, -crit, iteropts)
			st_numscalar("r(eff_lci)", eff_lci)
			st_numscalar("r(eff_uci)", eff_uci)
			st_numscalar("r(rc_eff_lci)", rc_eff_lci)
			st_numscalar("r(rc_eff_uci)", rc_eff_uci)		
		}
		
		// Otherwise, use the (squared) likelihood statistic LR = SLR^2
		else {
			rc_eff_lci = mm_root(eff_lci=., &ML_profile_eff(), llim, eff, itol, maxiter, yi, vi, crit, iteropts)
			rc_eff_uci = mm_root(eff_uci=., &ML_profile_eff(), eff, ulim, itol, maxiter, yi, vi, crit, iteropts)
			st_numscalar("r(eff_lci)", eff_lci)
			st_numscalar("r(eff_uci)", eff_uci)
			st_numscalar("r(rc_eff_lci)", rc_eff_lci)
			st_numscalar("r(rc_eff_uci)", rc_eff_uci)
		}
		
		st_numscalar("r(ll)", ll)
		st_numscalar("r(lr)", lr)		
		st_numscalar("r(slr)", slr)
	}
}

real scalar ML_est(real scalar tausq, real colvector yi, real colvector vi, | real scalar eff) {
	real colvector wi
	real scalar newtausq
	wi = 1:/(vi:+tausq)
	if (eff==.) eff = mean(yi, wi)
	newtausq = crossdev(yi, eff, wi:^2, yi, eff)/sum(wi:^2) - mean(vi, wi:^2)
	return(tausq - newtausq)
}

real scalar ML_profile_tausq(real scalar tausq, real colvector yi, real colvector vi, real scalar crit) {
	real colvector wi
	real scalar eff, ll
	wi = 1:/(vi:+tausq)
	eff = mean(yi, wi)
	ll = 0.5*sum(ln(wi)) - 0.5*crossdev(yi, eff, wi, yi, eff)
	return(ll - crit)
}

real scalar ML_profile_eff(real scalar eff, real colvector yi, real colvector vi, real scalar crit, real rowvector iteropts) {
	real scalar maxtausq, itol, maxiter
	maxtausq = iteropts[1]
	itol = iteropts[2]
	maxiter = iteropts[3]

	real colvector wi
	real scalar tausq, rc, ll
	rc = mm_root(tausq=., &ML_est(), 0, maxtausq, itol, maxiter, yi, vi, eff)
	if(rc==2) tausq=0
	else if(rc > 0) exit(error(498))
	
	wi = 1:/(vi:+tausq)
	ll = 0.5*sum(ln(wi)) - 0.5*crossdev(yi, eff, wi, yi, eff)
	return(ll - crit)
}

real scalar ML_skov(real scalar b, real colvector yi, real colvector vi, real colvector wi, real rowvector params, real scalar crit, real rowvector iteropts) {

	// unpack iteropts and params
	real scalar maxtausq, itol, maxiter
	maxtausq = iteropts[1]
	itol = iteropts[2]
	maxiter = iteropts[3]
	
	// unpack params (ML values of eff, tausq, ll)
	real scalar eff, tausq, ll
	eff = params[1]
	tausq = params[2]
	ll = params[3]
	
	// find tausq for fixed b, and hence calculate LL
	real scalar rc, tausq_b
	rc = mm_root(tausq_b=., &ML_est(), 0, 10*maxtausq, itol, maxiter, yi, vi, b)	
	if(rc==2) tausq_b=0
	else if(rc > 0) exit(error(498))
	real colvector wi_b
	real scalar ll_b
	wi_b = 1:/(vi:+tausq_b)
	ll_b = 0.5*sum(ln(wi_b)) - 0.5*crossdev(yi, b, wi_b, yi, b)
	
	// signed likelihood statistic at b
	real scalar slr
	slr = sign(eff - b)*sqrt(2*(ll - ll_b))	
			
	// calculate u for Skovgaard correction
	u = U(yi, wi, wi_b, eff, b)
	
	// Improved (Skovgaard-corrected) signed likelihood statistic
	real scalar slr_new
	slr_new = slr + (1/slr)*log(abs(u/slr))
	
	// Compare slr_new with slr:
	// If slr was zero, slr_new will be undefined; reset to 0
	// If slr_new is (a) the opposite sign to slr; (b) has larger absolute value than slr
	//   then the correction has "failed"; reset to former slr value
	if (slr==0) slr_new = 0
	else if (sign(slr) != sign(slr_new)) slr_new = slr
	else if (abs(slr) < abs(slr_new)) slr_new = slr
	return(slr_new - crit)
}

real scalar U(real colvector yi, real colvector wi, real colvector wi_b, real scalar eff, real scalar b) {

	// Skovgaard components:
	real colvector wi2, wi3, wi_b2, wi_b3
	wi2 = wi:^2
	wi3 = wi:^3
	wi_b2 = wi_b:^2
	wi_b3 = wi_b:^3

	// Expected (I) & observed (J) information, evaluated at ML estimate
	real matrix Imat
	Imat = (sum(wi), 0 \ 0, .5*sum(wi2))
	
	real matrix Jmat
	Jmat = (sum(wi), sum(wi2:*(yi:-eff)) \ sum(wi2:*(yi:-eff)) , -.5*sum(wi2) + sum(wi3:*((yi:-eff):^2)))
	
	// Observed (J) information under constraint eff = b, corresponding to tausq
	real scalar Jtsq
	Jtsq = -.5*sum(wi_b2) + sum(wi_b3:*((yi:-b):^2))

	// S and q
	real matrix S, Sinvq
	real colvector q
	S = (sum(wi_b), (eff-b)*sum(wi_b2) \ 0, .5*sum(wi_b2))
	q = ((eff-b)*sum(wi_b) \ -.5*sum(wi - wi_b))
	Sinvq = luinv(S)*q
	
	real scalar u
	u = abs(Sinvq[1,1]) * sqrt(abs(det(Jmat))) * abs(det(S)) / (sqrt(abs(Jtsq)) * abs(det(Imat)))
	return(u)
}



/* REML */
// (N.B. pass wi back-and-forth as it needs to be calculated anyway for tausq likelihood profiling)
void REML(string scalar varlist, string scalar touse, real scalar tsqlevel, real rowvector iteropts)
{
	// setup
	real colvector yi, se, vi, wi, eff
	varlist = tokens(varlist)
	st_view(yi=., ., varlist[1], touse)
	if(length(yi)==0) exit(error(111))
	st_view(se=., ., varlist[2], touse)
	vi = se:^2
	
	real scalar maxtausq, itol, maxiter
	maxtausq = iteropts[1]
	itol = iteropts[2]
	maxiter = iteropts[3]
	
	// Iterative tau-squared using REML
	real scalar tausq, rc_tausq
	rc_tausq = mm_root(tausq=., &REML_est(), 0, maxtausq, itol, maxiter, yi, vi)
	st_numscalar("r(tausq)", tausq)
	st_numscalar("r(rc_tausq)", rc_tausq)

	// Variance of tausq (using inverse Fisher information)
	wi = 1:/(vi:+tausq)
	tsq_var = 2*(sum(wi:^2) - 2*mean(wi:^2, wi) + mean(wi, wi)^2)^-1
	st_numscalar("r(tsq_var)", tsq_var)
	
	// Calculate REML log-likelihood value (ignoring constant term)
	// [NOTE: first term is *positive* since wi = 1/(vi+tausq).
	//  In the literature, likelihood is usually stated in terms of **vi**
	//  and hence the term is *negative*.]	
	real scalar ll, tsq_lci, rc_tsq_lci, tsq_uci, rc_tsq_uci
	eff = mean(yi, wi)
	ll = 0.5*sum(ln(wi)) - 0.5*ln(sum(wi)) - 0.5*crossdev(yi, eff, wi, yi, eff)
	crit = ll - (invchi2(1, tsqlevel/100)/2)
	st_numscalar("r(ll)", ll)

	// Confidence interval for tausq using likelihood profiling
	rc_tsq_lci = mm_root(tsq_lci=., &REML_profile_tausq(), 0, tausq - itol, itol, maxiter, yi, vi, crit)
	st_numscalar("r(tsq_lci)", tsq_lci)
	st_numscalar("r(rc_tsq_lci)", rc_tsq_lci)

	rc_tsq_uci = mm_root(tsq_uci=., &REML_profile_tausq(), tausq + itol, 10*maxtausq, itol, maxiter, yi, vi, crit)
	st_numscalar("r(tsq_uci)", tsq_uci)
	st_numscalar("r(rc_tsq_uci)", rc_tsq_uci)
}

real scalar REML_est(real scalar tausq, real colvector yi, real colvector vi) {
	real colvector wi
	real scalar eff, newtausq
	wi = 1:/(vi:+tausq)
	eff = mean(yi, wi)
	newtausq = crossdev(yi, eff, wi:^2, yi, eff)/sum(wi:^2) - mean(vi, wi:^2) + (1/sum(wi))
	return(tausq - newtausq)
}

real scalar REML_profile_tausq(real scalar tausq, real colvector yi, real colvector vi, real scalar crit) {
	real colvector wi
	real scalar eff, ll
	wi = 1:/(vi:+tausq)
	eff = mean(yi, wi)
	ll = 0.5*sum(ln(wi)) - 0.5*ln(sum(wi)) - 0.5*crossdev(yi, eff, wi, yi, eff)
	return(ll - crit)
}


/* Confidence interval for tausq estimated using approximate Gamma distribution for Q */
/* based on paper by Biggerstaff and Tweedie (Stat Med 1997; 16: 753-768) */
// Point estimate of tausq is simply the D+L estimate
void Gamma(string scalar varlist, string scalar touse, string scalar wtvec, real scalar tsqlevel, real rowvector iteropts)
{
	// Setup
	real colvector yi, se, vi, wi
	varlist = tokens(varlist)
	st_view(yi=., ., varlist[1], touse)
	if(length(yi)==0) exit(error(111))
	st_view(se=., ., varlist[2], touse)
	vi = se:^2
	wi = 1:/vi

	real scalar maxtausq, itol, maxiter, quadpts
	maxtausq = iteropts[1]
	itol = iteropts[2]
	maxiter = iteropts[3]
	quadpts	= iteropts[4]

	// Estimate variance of tausq
	real scalar k, eff, Q, c, d, tausq_m, tausq, Q_var, tsq_var
	k = length(yi)
	eff = mean(yi, wi)					// fixed-effects estimate
	Q = crossdev(yi, eff, wi, yi, eff)	// standard Q heterogeneity statistic
	c = sum(wi) - mean(wi,wi)			// c = S1 - (S2/S1)
	d = cross(wi,wi) - 2*mean(wi:^2,wi) + (mean(wi,wi)^2)
	tausq_m = (Q - (k-1))/c				// untruncated D+L tausq

	// Variance of Q and tausq (based on untruncated tausq)
	Q_var = 2*(k-1) + 4*c*tausq_m + 2*d*(tausq_m^2)
	tsq_var = Q_var/(c^2)
	st_numscalar("r(tsq_var)", tsq_var)

	// Find confidence limits for tausq
	real scalar tsq_lci, rc_tsq_lci, tsq_uci, rc_tsq_uci
	rc_tsq_lci = mm_root(tsq_lci=., &Gamma_crit(), 0, maxtausq, itol, maxiter, tausq_m, k, c, d, .5 + tsqlevel/200)
	st_numscalar("r(tsq_lci)", tsq_lci)
	st_numscalar("r(rc_tsq_lci)", rc_tsq_lci)

	rc_tsq_uci = mm_root(tsq_uci=., &Gamma_crit(), tsq_lci + itol, 10*maxtausq, itol, maxiter, tausq_m, k, c, d, .5 - tsqlevel/200)
	st_numscalar("r(tsq_uci)", tsq_uci)
	st_numscalar("r(rc_tsq_uci)", rc_tsq_uci)
		
	// Find and return new weights
	real scalar EQ, VQ, lambda, r, se_eff
	EQ = (k-1) + c*tausq_m
	VQ = 2*(k-1) + 4*c*tausq_m + 2*d*(tausq_m^2)
	lambda = EQ/VQ
	r = lambda*EQ
	
	wsi = wi
	for(i=1; i<=k; i++) {
		params = (vi[i], lambda, r, c, k)
		wsi[i] = integrate(&BTIntgrnd(), 0, ., quadpts, params)
	}
	wi = wi*gammap(r, lambda*(k-1)) :+ wsi								// update weights
	st_store(st_viewobs(yi), wtvec, wi)									// write new weights to Stata
}

real scalar Gamma_crit(real scalar tausq, real scalar tausq_m, real scalar k, real scalar c, real scalar d, real scalar crit) {
	real scalar lambda, r, limit
	lambda = ((k-1) + c*tausq)/(2*(k-1) + 4*c*tausq + 2*d*(tausq^2))
	r = ((k-1) + c*tausq)*lambda
	limit = lambda*(c*tausq_m + (k-1))
	ans = gammap(r, limit) - crit
	return(ans)
}

real rowvector BTIntgrnd(real rowvector t, real rowvector params) {
	real scalar s, lambda, r, c, k, ans
	s = params[1,1]				// vi[i] > 0
	lambda = params[1,2]		// lambda = E(Q)/Var(Q) [N.B. the inverse of this is used in Henmi & Copas]
	r = params[1,3]				// r = [E(Q)^2]/Var(Q)
	c = params[1,4]				// c = f(weights)
	k = params[1,5]				// k = no. studies > 1
	ans = (c:/(s:+t)) :* gammaden(r, 1/lambda, 1-k, c*t)
	return(ans)
}


/* Henmi and Copas method */
// Point estimate of tausq is simply the D+L estimate
void HC(string scalar varlist, string scalar touse, real scalar level, real rowvector iteropts)
{
	// Setup
	real colvector yi, se, vi, wi
	varlist = tokens(varlist)
	st_view(yi=., ., varlist[1], touse)
	if(length(yi)==0) exit(error(111))
	st_view(se=., ., varlist[2], touse)
	vi = se:^2

	real scalar itol, maxiter, quadpts
	itol = iteropts[1]
	maxiter = iteropts[2]
	quadpts = iteropts[3]

	real scalar k, eff, Q, tausq, VR, SDR
	k = length(yi)
	wi = 1:/vi
	eff = mean(yi, wi)							// fixed-effects estimate
	Q = crossdev(yi, eff, wi, yi, eff)			// standard Q heterogeneity statistic
	W1 = sum(wi)
	W2 = mean(wi, wi)
	W3 = mean(wi:^2, wi)
	W4 = mean(wi:^3, wi)
	tausq = max((0, (Q - (k-1))/(W1 - W2)))		// truncated D+L
	VR = 1 + tausq*W2
	SDR = sqrt(VR)
	
	// Coefficients of 1 and (x^2) for the following functions:
	// EQ(x) = conditional mean of Q given R=x
	// VQ(x) = conditional variance of Q given R=x
	// finv(x) = inverse function of f(Q).
	// All three functions are linear combinations of 1 and (x^2),
	//   so all can be represented by a single function, f.
	real scalar aEQ, bEQ
	aEQ = (k - 1) + tausq*(W1 - W2) - (tausq^2)*(W3 - W2^2)/VR
	bEQ = (W3 - W2^2)*(tausq/VR)^2
	
	real scalar aVQ, bVQ
	aVQ = 2*(k - 1) + 4*tausq*(W1 - W2) + 2*(tausq^2)*(W1*W2 - 2*W3 + W2^2)
	aVQ = aVQ - 4*(tausq^2)*(W3 - W2^2)/VR
	aVQ = aVQ - 4*(tausq^3)*(W4 - 2*W2*W3 + W2^3)/VR
	aVQ = aVQ + 2*(tausq^4)*(1/VR^2)*(W3 - W2^2)^2
	
	bVQ = 4*(tausq^2)*((1/VR^2))*(W3 - W2^2)
	bVQ = bVQ + 4*(tausq^3)*(1/VR^2)*(W4 - 2*W2*W3 + W2^3)
	bVQ = bVQ - 2*(tausq^4)*2*(1/VR^3)*(W3 - W2^2)^2
	
	real scalar afinv, bfinv
	afinv = (k-1) - (W1/W2 - 1)
	bfinv = (W1/W2 - 1)

	real rowvector params
	params = (aEQ, bEQ, aVQ, bVQ, afinv, bfinv, SDR)
	
	// Find quantile of approximate distribution
	// (u_alpha/2 in Henmi & Copas)
	real scalar t, rc_t
	rc_t = mm_root(t=., &Eqn(), 0, 2, itol, maxiter, quadpts, level, params)
	if (rc_t > 0) exit(error(498))
	st_numscalar("r(crit)", SDR*t)
	
	// Find test statistic (u) and p-value
	real scalar u, p
	u = eff/sqrt((tausq*W2 + 1)/W1)
	p = 2*integrate(&HCIntgrnd(), abs(u)/SDR, 40, quadpts, (abs(u)/SDR, params))
	st_numscalar("r(p)", p)
	st_numscalar("r(u)", u)
}

// N.B. Integration is from x to 40, since the integrand's value is indistinguishable from zero at this point.
// To see this, note that the integrand is the product of a cumulative Gamma function ==> between 0 and 1
//  and a standard normal density which is indistinguishable from zero at ~40.
// (thanks to Ben Jann for pointing this out)
real scalar Eqn(real scalar x, real scalar quadpts, real scalar level, real rowvector params) {
	real scalar ans
	ans = integrate(&HCIntgrnd(), x, 40, quadpts, (x, params))
	return(ans - (.5 - level/200))
}

real rowvector HCIntgrnd(real rowvector r, real rowvector params) {
	real scalar t, aEQ, bEQ, aVQ, bVQ, afinv, bfinv, SDR
	t     = params[1]
	aEQ   = params[2]
	bEQ   = params[3]
	aVQ   = params[4]
	bVQ   = params[5]
	afinv = params[6]
	bfinv = params[7]
	SDR   = params[8]
	
	real rowvector ans
	ans = gammap((f(r*SDR, aEQ, bEQ):^2):/f(r*SDR, aVQ, bVQ), f(r/t, afinv, bfinv):/(f(r*SDR, aVQ, bVQ):/f(r*SDR, aEQ, bEQ))) :* normalden(r)
	if(t==0) ans = normalden(r)
	return(ans)
}

real rowvector f(real rowvector x, real scalar a, real scalar b) {
	return(a :+ b*(x:^2))
}

end

