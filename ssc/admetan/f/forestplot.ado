* Program to generate forestplots -- used by ipdmetan etc. but can also be run by itself
* April 2013
*   Forked from main ipdmetan code
* September 2013
*   Following UK Stata Users Meeting, reworked the plotid() option as recommended by Vince Wiggins

* version 1.0  David Fisher  31jan2014

* version 1.01  David Fisher  07feb2014
* Reason: fixed bug - random-effects note being overlaid on x-axis labels

* version 1.02  David Fisher  20feb2014
* Reason: allow user to affect null line options

* version 1.03  David Fisher  23jul2014
* Reason: implented a couple of suggestions from Phil Jones
* Weighting is now consistent across plotid groups
* Tidying up some code that unnecessarily restricted where user-defined lcols/rcols could be plotted
* Minor bug fixes and code simplification
* New (improved?) textsize and aspect ratio algorithm

* version 1.04  David Fisher 29jun2015
// Reason: Major update to coincide with publication of Stata Journal article

* Aug 2014: fixed issue with _labels
* updated SpreadTitle to accept null strings
* added 'noBOX' option

* Oct 2014: added "newwt" option to "dataid" to reset weights

* Jan 2015: re-written leftWD/rightWD sections to use variable formats and manually-calculated indents
* rather than using char(160), since this isn't necessarily mapped to "non-breaking space" on all machines

* May 2015: Fixed issue with "clipping" long column headings
* May 2015: Option to save parameters (aspect ratio, text size, positioning of text columns relative to x-axis tickmarks)
* in a matrix, to be used by a subsequent -forestplot- call to maintain consistency

* October 2015: Minor fixes to agree with new ipdmetan/admetan versions

* July 2016: added rfdist

* 30th Sep 2016: added "range(min max)" option so that range = min(_LCI) to max(_UCI)

* Coding of _USE:
* _USE == 0  subgroup labels (headings)
* _USE == 1  successfully estimated trial-level effects
* _USE == 2  unsuccessfully estimated trial-level effects ("Insufficient data")
* _USE == 3  subgroup effects
* _USE == 4  between-subgroup heterogeneity info
* _USE == 5  overall effect
* _USE == 6  blank lines/anything else
* _USE == 9  titles

* version 2.0  David Fisher  11may2017
// Not updated nearly as much as -admetan-, -ipdmetan- and -ipdover-
// but up-versioned to match

* version 2.1  David Fisher  14sep2017
// various bug fixes
// improvements to range() and cirange()
// improvements to rfopts

// - N.B. cannot override "interaction" option with pointopts(msymbol(square)) -- is this a bug or a feature?
// for next version:  include addplot() option ?

* version 3.0  David Fisher  08nov2018

* version 3.1  David Fisher  03dec2018
// only implement lalign() if c(stata_version)>=15
// corrected order of `graphopts' and `fpuseopts' so that -useopts- works as intended
// -forestplot- now consistently honours blank varlabels in lcols/rcols (whether string or numeric)

*! version 3.2  David Fisher  28jan2019
// corrected error which caused first help-file example to fail
// some text in help file is updated
// improved counting of rows in titles containing compound quotes


program define forestplot, sortpreserve rclass

	version 10		// metan is v9 and this doesn't use any more recent commands/syntaxes; v10 used only for sake of help file extension

	// June 2018 [updated Oct 2018]: check for "useopts", which recreates previous admetan/ipdmetan/ipdover call
	syntax [varlist(numeric max=5 default=none)] [if] [in] [, USEOPTs *]
	local graphopts `"`options'"'

	local usevlist `varlist'
	local useifin  `if' `in'
	
	if `"`useopts'"'!=`""' {
		local orig_gropts : copy local graphopts
	
		local fpusevlist : char _dta[FPUseVarlist]
		local fpuseifin  : char _dta[FPUseIfIn]
		local fpuseopts  : char _dta[FPUseOpts]

		if `"`fpusevlist'`fpuseifin'`fpuseopts'"'==`""' {
			disp as err `"No stored {bf:forestplot} options found"'
			exit 198
		}
	
		// varlist and if/in:  if supplied directly, overwrite characteristics
		if `"`usevlist'"'==`""' local usevlist `fpusevlist'
		if `"`useifin'"'==`""'  local useifin  `fpuseifin'

		nois disp as text `"Full command line as defined by {bf:useopts} is as follows:"'
		nois disp as res `"  forestplot `usevlist' `if' `in', `fpuseopts' `graphopts'"'
		nois disp as text `"(Note: only the rightmost of any repeated options will be honoured"'
		nois disp as text `"  with the exception of built in Stata graph options; see {help repeated_options}"'
	}

	// Nov 2018: note that -syntax- is *leftmost*, not rightmost; so `graphopts' must come first to overrule `fpuseopts'
	local 0 `"`usevlist' `useifin', `graphopts' `fpuseopts'"'
	
	// June 2018: main parse
	syntax [varlist(numeric max=5 default=none)] [if] [in] [, WGT(string) USE(varname numeric) ///
		///
		/// /* General user-specified -forestplot- options */
		BY(varname) EFORM EFFect(string) LABels(varname string) DP(integer 2) KEEPAll USESTRICT /*(undocumented)*/ ///
		INTERaction LCols(namelist) RCols(namelist) LEFTJustify COLSONLY RFDIST(varlist numeric min=2 max=2) ///
		NULLOFF noNAmes noNULL NULL2(string) noKEEPVars noOVerall noSUbgroup noSTATs noWT noHET LEVEL(real 95) ///
		XTItle(passthru) FAVours(passthru) /// /* N.B. -xtitle- is parsed here so that a blank title can be inserted if necessary */
		CUmulative /// /* undocumented; passed through from -admetan-; only needed in order to switch _USE==3 back to _USE==1
		///
		/// /* Sub-plot identifier for applying different appearance options, and dataset identifier to separate plots */
		PLOTID(string) DATAID(string) ///
		///
		/// /* "fine-tuning" options */
		SAVEDIms(name) USEDIms(name) ASText(real -9) noADJust ///
		FP(string) /// 		/*(deprecated; now a favours() suboption)*/
		KEEPXLabs * ] /// 	/*(undocumented; colsonly option)*/
	
	marksample touse, novarlist				// do this immediately, so that -syntax- can be used again
	local graphopts `"`options'"'			// "graph region" options (also includes plotopts for now)		
	local _USE `use'
			
	tokenize `varlist'
	local _ES  `1'
	local _LCI `2'
	local _UCI `3'	

	
	** N.B. Parts of this early setup may repeat work already done by -admetan- or -ipdover-
	//  but hopefully the extra overhead is negligible

	// Set up variable names
	if `"`varlist'"'==`""' {		// if not specified, assume "standard" varnames			
		local _ES  _ES
		local _LCI _LCI
		local _UCI _UCI
		nois disp as text `"Note: no {it:varlist} specified; using default {it:varlist}"' as res `" {bf:_ES _LCI _UCI}"'
	}
	else if `"`4'"'!=`""' {
		nois disp as err `"Syntax has changed as of ipdmetan v2.0 09may2017"'
		nois disp as err `"{bf:_WT} and {bf:_USE} should now be specified using options {bf:wgt()} and {bf:use()}"'
		exit 198
	}
	foreach x in _ES _LCI _UCI {
		confirm numeric var ``x''
	}		

	// Set up data sample to use
	if `"`_USE'"'==`""' {
		capture confirm numeric var _USE
		if !_rc {
			nois disp as text `"Note: option {bf:use(}{it:varname}{bf:)} not specified; using default {it:varname}"' as res `" {bf:_USE}"'
			local _USE _USE
		}
		else {
			if _rc!=7 {			// if _USE does not exist
				tempvar _USE
				qui gen byte `_USE' = cond(missing(`_ES', `_LCI', `_UCI'), 2, 1)
				nois disp as text `"Note: default variable"' as res `" {bf:_USE} "' as text `"not found; all included observations will be assumed to contain study estimates"'
			}
			else {
				nois disp as err `"Default variable {bf:_USE} exists but is not numeric"'
				exit 198
			}
		}
	}
	markout `touse' `_USE'		// observations for which _USE is missing
	qui replace `touse' = 0 if `_USE' == 3 & `"`subgroup'"'!=`""'
	qui replace `touse' = 0 if `_USE' == 4 & `"`het'"'!=`""'
	qui replace `touse' = 0 if inlist(`_USE', 4, 5) & `"`overall'"'!=`""'
	qui replace `touse' = 0 if inlist(`_USE', 3, 5) & missing(`_ES') & `"`stats'"'!=`""' & `"`rfdist'"'!=`""'	
	if "`keepall'"=="" qui replace `touse' = 0 if `_USE'==2		// "keepall" option (see ipdmetan)
	
	qui count if `touse'
	if !r(N) {
		nois disp as err "no observations"
		exit 2000
	}
	return scalar obs = r(N)
	
	// Check that UCI is greater than LCI
	qui count if `touse' & `_UCI' < `_LCI' & !missing(`_LCI')
	if r(N) {
		nois disp as err "Error in confidence interval data"
		exit 198
	}		

	// Weighting variable
	if `"`wgt'"'==`""' {
		capture confirm numeric var _WT
		if !_rc {
			nois disp as text `"Note: option {bf:wgt(}{it:varname}{bf:)} not specified; using default {it:varname}"' as res `" {bf:_WT}"'
			local wgt _WT
		}
		else {
			if _rc!=7 {			// if _WT does not exist
				tempvar wgt
				qui gen byte `wgt' = 1 if `touse' & inlist(`_USE', 1, 3, 5)		// generate as constant if doesn't exist
				nois disp as text `"Note: default variable"' as res `" {bf:_WT} "' as text `"not found; all observations will have equal weights"'
				local wt nowt						// don't display as text column
			}
			else {
				nois disp as err `"Default variable {bf:_WT} exists but is not numeric"'
				exit 198
			}
		}
	}

	// Check existence of `labels' (string) and `by' (should really be numeric but doesn't actually matter)
	foreach x in labels by {
		if `"``x''"'==`""' {
			local X = upper("`x'")
			cap confirm var _`X'
			if !_rc {
				local `x' "_`X'"			// use default varnames if they exist and option not explicitly given
				if "`x'"=="labels" {		// don't print message r.e. `by' as it is only used in a minor way by -forestplot-
					confirm string var `labels'
					nois disp as text `"Note: option {bf:labels(}{it:varname}{bf:)} not specified; using default {it:varname}"' as res `" {bf:_LABELS}"'
				}
			}
			
			// Jan 2019
			else if "`x'"=="labels" {
				nois disp as text `"Note: option {bf:labels(}{it:varname}{bf:)} not specified and default {it:varname} {bf:_LABELS} not found; observations will be unlabelled"'
				local names nonames
			}
		}
	}

	// Check validity of `_USE' (already sorted out existence)
	//  if `usestrict'; otherwise responsibility is with user
	if `"`usestrict'"'!=`""' {
		tempvar flag
		qui gen byte `flag' =      `touse' & `_USE'==1 &  missing(`_ES', `_LCI', `_UCI', `wgt')
		qui replace  `flag' = 1 if `touse' & `_USE'==2 & !missing(`_ES', `_LCI', `_UCI')
		if `"`names'"'==`""' {		// Jan 2019
			qui replace  `flag' = 1 if `touse' & `_USE'==6 & !missing(`labels')
		}
		qui replace  `flag' = 1 if `touse' & inlist(`_USE', 2, 6) & !missing(`wgt') & `"`wt'"'==`""'
		qui replace  `flag' = 1 if `touse' & `_USE' >6 & !missing(`_USE')
		qui count if `flag'
		if r(N) {
			nois disp as err `"The following observations are inconsistent with {bf:_USE}:"'
			nois list `_USE' `labels' `_ES' `_LCI' `_UCI' `wgt' if `flag'
			exit 198
		}
		qui drop `flag'
	}
	
	// Parse eform option and finalise "effect" text
	cap nois CheckOpts, soptions opts(`graphopts' `eform')
	if _rc {
		if _rc==1 nois disp as err "User break"
		else nois disp as err `"Error in {bf:forestplot.CheckOpts}"'
		c_local err noerr		// tell calling subroutine not to also report an error
		exit _rc
	}
	local eform `"`s(eform)'"'			// either "eform" or nothing
	local graphopts `"`s(options)'"'

	if `"`effect'"'==`""' {
		// amended Feb 2018 due to local x = "" issue with version <13
		// local effect = cond(`"`r(effect)'"'=="", "Effect", `"`r(effect)'"')
		local effect `"`s(effect)'"'
		if `"`effect'"'==`""'      local effect "Effect"
		if `"`interaction'"'!=`""' local effect `"Interact. `effect'"'
	}
	
	
	* Default placing of labels, effect sizes and weights:
	// unless noSTATS and/or noWT, effect sizes and weights are first two elements of `rcols'
	if `"`eform'"'!=`""' local xexp exp
	if `"`stats'"'==`""' {
	
		// determine format
		summ `_UCI' if `touse', meanonly
		local fmtx = max(1, ceil(log10(abs(`xexp'(r(max)))))) + 1 + `dp'
	
		if `"`keepvars'"'!=`""' tempvar _EFFECT
		else {
			cap drop _EFFECT
			local _EFFECT _EFFECT
		}
		qui gen str `_EFFECT' = string(`xexp'(`_ES'), `"%`fmtx'.`dp'f"') if !missing(`_ES')
		qui replace `_EFFECT' = `_EFFECT' + " " if !missing(`_EFFECT')
		qui replace `_EFFECT' = `_EFFECT' + "(" + string(`xexp'(`_LCI'), `"%`fmtx'.`dp'f"') + ", " + string(`xexp'(`_UCI'), `"%`fmtx'.`dp'f"') + ")"
		qui replace `_EFFECT' = `""' if !(`touse' & inlist(`_USE', 1, 3, 5))
		qui replace `_EFFECT' = "(Insufficient data)" if `touse' & `_USE' == 2

		local f: format `_EFFECT'
		tokenize `"`f'"', parse("%s")
		confirm number `2'
		format `_EFFECT' %-`2's		// left-justify
		
		// variable label
		if `"`effect'"' == `""' {
			local effect = cond("`interaction'"!="", "Interaction effect", "Effect")
		}
		local llevel : char `_LCI'[Level]
		local ulevel : char `_UCI'[Level]
		if `"`llevel'"'!=`""' & `"`ulevel'"'!=`""' & `"`llevel'"'!=`"`ulevel'"' {
			nois disp as err "Conflicting confidence limit coverages"
			exit 198
		}
		local cilevel `llevel'
		if `"`cilevel'"'==`""' local cilevel `ulevel'
		if `"`cilevel'"'==`""' local cilevel `level'
		label var `_EFFECT' `"`effect' (`cilevel'% CI)"'
	}
	if `"`names'"'==`""' local lcols `labels' `lcols'		// unless noNAMES specified, add `labels' to `lcols'
	if "`wt'" == "" local rcols `wgt' `rcols'				// unless noWT specified, add `wgt' to `rcols'
	local rcols `_EFFECT' `rcols'							// unless noSTATS specified, add `_EFFECT' to `rcols'			
	
	// finalise lcols and rcols
	foreach x of local lcols {
		cap confirm var `x' 
		if _rc {
			nois disp as err `"variable {bf:`x'} not found in option {bf:lcols()}"'
			exit _rc
		}
	}
	foreach x of local rcols {
		cap confirm var `x' 
		if _rc {
			nois disp as err `"variable {bf:`x'} not found in option {bf:rcols()}"'
			exit _rc
		}
	}
	local lcolsN : word count `lcols'
	local rcolsN : word count `rcols'

	// if no columns AND colsonly supplied, exit with error
	if !`lcolsN' & !`rcolsN' & `"`colsonly'"'!=`""' {
		disp as err `"Option {bf:colsonly} supplied with no columns of data; nothing to plot"'
		exit 2000
	}

	
	** Generate ordering variable (reverse sequential, since y axis runs bottom to top)
	tempvar touse2 allobs obs id
	qui gen long `allobs' = _n
	qui bysort `touse' (`allobs') : gen long `obs' = _n if `touse'
	qui drop `allobs'
	qui bysort `touse' (`obs') : gen long `id' = _N - _n + 1 if `touse'	
		
	// Sort out `dataid' and `plotid'
	local nd=1
	local 0 `dataid'
	syntax [varname(default=none)] [, NEWwt]
	if `"`varlist'"'!=`""' {
		cap tab `varlist' if `touse', m
		if _rc {
			nois disp as err `"error in option {bf:dataid()}"'
			qui tab `varlist' if `touse', m
		}

		if `"`newwt'"'==`""' local dataid `varlist'
		else {
			local dataid
			tempvar dtobs dataid					// create ordinal version of dataid
			qui bysort `touse' `varlist' (`obs') : gen long `dtobs' = `obs'[1] if `touse'
			qui bysort `touse' `dtobs' : gen long `dataid' = (_n==1) if `touse'
			qui replace `dataid' = sum(`dataid')
			local nd = `dataid'[_N]					// number of `dataid' levels
			label var `dataid' "dataid"
		}
	}
	
	if `"`plotid'"'==`""' {
		tempvar plotid
		qui gen byte `plotid' = 1 if `touse'	// create plotid as constant if not specified
		local np = 1
	}
	else {
		disp _n _c								// spacing, in case following on from ipdmetan (etc.)
		cap confirm var _OVER
		local over = cond(_rc, "", "_OVER")
		
		local 0 `plotid'
		syntax name(name=plname id="plotid") [, List noGRaph]
		local plotid		// clear macro; will want to define a tempvar named plotid

		if "`plname'"!="_n" {
			confirm var `plname'
			cap tab `plname' if `touse', m
			if _rc {
				nois disp as err `"error in option {bf:plotid()}"'
				qui tab `plname' if `touse', m
			}
			if `"`over'"'==`""' {
				qui count if `touse' & inlist(`_USE', 1, 2) & missing(`plname')
				if r(N) {
					nois disp as err `"Warning: variable {bf:`plname'} (in option {bf:plotid()}) contains missing values"'
					nois disp as err `"{bf:plotid()} groups and/or allocated numeric codes may not be as expected"'
					if "`list'"=="" nois disp as err `"This may be checked using the {bf:list} suboption to {bf:plotid()}"'
				}
			}
		}
		
		* Create ordinal version of plotid...
		qui gen byte `touse2' = `touse' * inlist(`_USE', 1, 2, 3, 5)
		local plvar `plname'

		// ...extra tweaking if passed through from admetan/ipdover (i.e. _STUDY, and possibly _OVER, exists)
		if inlist("`plname'", "_STUDY", "_n", "_LEVEL", "_OVER") {
			cap confirm var _STUDY
			local study = cond(_rc, "_LEVEL", "_STUDY")
			tempvar smiss
			qui gen byte `smiss' = missing(`study')
			
			if inlist("`plname'", "_STUDY", "_n") {
				tempvar plvar
				qui bysort `touse2' `smiss' (`over' `study') : gen long `plvar' = _n if `touse2' & !`smiss'
			}
			else if "`plname'"=="_LEVEL" {
				tempvar plvar
				qui bysort `touse2' `smiss' `by' (`over' `study') : gen long `plvar' = _n if `touse2' & !`smiss'
			}
		}
		tempvar plobs plotid
		qui bysort `touse2' `smiss' `plvar' (`obs') : gen long `plobs' = `obs'[1] if `touse2'
		qui bysort `touse2' `smiss' `plobs' : gen long `plotid' = (_n==1) if `touse2'
		qui replace `plotid' = sum(`plotid')
		local np = `plotid'[_N]					// number of `plotid' levels
		label var `plotid' "plotid"
		
		* Optionally list observations contained within each plotid group
		if "`list'" != "" {
			sort `obs'
			nois disp as text _n "plotid: observations marked by " as res "`plname'" as text ":"
			forvalues p=1/`np' {
				nois disp as text _n "-> plotid = " as res `p' as text ":"
				nois list `dataid' `_USE' `by' `over' `labels' if `touse2' & `plotid'==`p', table noobs sep(0)
			}
			if `"`graph'"'!=`""' exit
		}
		qui drop `touse2' `plobs' `smiss'
	}
	qui drop `obs'
	
	
	** GET MIN AND MAX DISPLAY
	// [comments from _dispgby subroutine of metan.ado follow]
	// SORT OUT TICKS- CODE PINCHED FROM MIKE AND FIDDLED. TURNS OUT I'VE BEEN USING SIMILAR NAMES...
	// AS SUGGESTED BY JS JUST ACCEPT ANYTHING AS TICKS AND RESPONSIBILITY IS TO USER!
	
	// N.B. `DXmin', `DXmax' are the left and right co-ords of the graph part
	// These are NOT NECESSARILY the same as the limits of xlabels, xticks etc.
	// e.g. if range() was specified with values outside the limits of xlabels, xticks etc., then DXmin, DXmax == range.
	
	// First, sort out null-line
	local h0 = 0							// default
	
	if `"`null2'"'!=`""' local nullopt `"null(`null2')"'
	opts_exclusive `"`nulloff' `null' `nullopt'"'

	if `"`nulloff'"'!=`""' local null nonull
	// "nulloff" and "nonull" are permitted alternatives to null(none|off), for compatability with -metan-
	
	else if `"`null2'"'!=`""' {
		if inlist("`null2'", "none", "off") local null nonull
		else {
			cap nois numlist "`null2'", min(1) max(1)
			if _rc {
				disp as err "error in {bf:null()} option"
				exit _rc
			}
			local h0 = `null2'
			local null
		}
	}
	// N.B. `null' now either contains nothing, or "nonull"
	//  and `h0' contains a number (defaulting to 0), denoting where the null-line will be placed if "`null'"==""

	
	// Now find DXmin, DXmax; xticklist, xlablist, xlablim1
	summ `_LCI' if `touse', meanonly
	local DXmin = r(min)				// minimum confidence limit
	summ `_UCI' if `touse', meanonly
	local DXmax = r(max)				// maximum confidence limit

	if `"`rfdist'"'!=`""' {
		tokenize `rfdist'
		args _rfLCI _rfUCI
		cap {
			assert `_rfLCI' <= `_LCI' if `touse' & !missing(`_rfLCI', `_LCI')
			assert `_rfUCI' >= `_UCI' if `touse' & !missing(`_rfUCI', `_UCI')
		}
		if _rc {
			nois disp as err "Error in prediction interval data"
			exit 198
		}
	
		summ `_rfLCI' if `touse', meanonly		// N.B. unnecessary if passed thru from -admetan-, since included in `_LCI'/`_UCI'
		local DXmin = min(`DXmin', r(min))		//  but need to do it anyway 
		summ `_rfUCI' if `touse', meanonly
		local DXmax = max(`DXmax', r(max))
		
		if `"`stats'"'==`""' {
			// Generate `rfdindent' to send to ProcessXLabs
			// strwid is width of "_ES[_n-1]" as formatted by "%`fmtx'.`dp'f" so it lines up
			tempvar rfindent
			qui gen `rfindent' = cond(`touse' * missing(`_ES') * !missing(`_rfLCI', `_rfUCI'), ///
				string(`xexp'(`_ES'[_n-1]), `"%`fmtx'.`dp'f"'), `""')
				
			// Find which column effect sizes (including predictive distribution limits) should appear in, to apply rfindent
			local rfcol=1
			while `"`: word `rfcol' of `rcols''"'!=`"_EFFECT"' & `rfcol' <= `rcolsN' {
				local ++rfcol
			}
			
			local rfopts `"rfindent(`rfindent') rfcol(`rfcol')"'
		}
		else {
			disp as err "Note: options {bf:rfdist} and {bf:nostats} specified together;"
			disp as err " predictive intervals will be presented graphically but will not appear in text columns"
		}
	}
	
	cap nois ProcessXLabs `DXmin' `DXmax', `eform' h0(`h0') `null' `graphopts'
	if _rc {
		if _rc==1 nois disp as err `"User break in {bf:forestplot.ProcessXLabs}"'
		nois disp as err `"Error in {bf:forestplot.ProcessXLabs}"'
		c_local err noerr		// tell calling program (admetan or ipdover) not to also report an error
		exit _rc
	}
	local CXmin = r(CXmin)		// limits of data plotting (i.e. off-scale arrows)... = DX by default
	local CXmax = r(CXmax)
	local DXmin = r(DXmin)		// limits of data plot region
	local DXmax = r(DXmax)
	local XLmin = r(XLmin)		// limits of x-axis labelled values
	local XLmax = r(XLmax)

	return local range `"`DXmin' `DXmax'"'
	
	// local xtitleval = r(xtitleval)	// position of xtitle
	
	local xlablist `"`r(xlablist)'"'
	local xlabcmd  `"`r(xlabcmd)'"'
	local xlabopts `"`r(xlabopts)'"'

	local xmlablist `"`r(xmlablist)'"'
	local xmlabcmd  `"`r(xmlabcmd)'"'
	local xmlabopts `"`r(xmlabopts)'"'
	
	local xticklist  `"`r(xticklist)'"'
	local xtickopts  `"`r(xtickopts)'"'
	local xmticklist `"`r(xmticklist)'"'
	local xmtickopts `"`r(xmtickopts)'"'

	// Nov 2017
	local null      `"`r(null)'"'
	local xlabfmt   `"`r(xlabfmt)'"'
	local xmlabfmt  `"`r(xmlabfmt)'"'
	local graphopts `"`r(options)'"'
	
	local rowsxlab  = r(rowsxlab)
	local rowsxmlab = r(rowsxmlab)
	
	local adjust = cond(`"`colsonly'"'==`""', `"`adjust'"', `"noadjust"')

	// END OF TICKS AND LABELS

	
	
	** Need to make changes to pre-existing data now
	// e.g. adding new obs to the dataset to contain multi-line column headings
	//  so use -preserve-
	preserve

	// [added Nov 2018]
	// Make data obey the conventions of _USE
	qui replace `_USE' = 6 if `_USE'>6 & `touse'
	qui replace `_ES' = .  if `touse' & `_USE'==2
	qui replace `_LCI' = . if `touse' & `_USE'==2
	qui replace `_UCI' = . if `touse' & `_USE'==2
	if `"`names'"'==`""' {
		qui replace `labels' = "" if `touse' & `_USE'==6
	}
	qui replace `wgt' = . if `touse' & inlist(`_USE', 2, 6) & `"`wt'"'==`""'
	
		
	************************
	* LEFT & RIGHT COLUMNS * -- begin measuring/generating text columns from namelists given in `lcols'/`rcols'
	************************
	
	// Setup: generate tempvars to send to ProcessColumns
	foreach xx in left right {
		local x = substr("`xx'", 1, 1)		// extract "l" from "left" and "r" from "right"

		forvalues i=1/``x'colsN' {		// N.B. if `lcolsN' or `rcolsN'==0, this loop will be skipped
			tempvar `xx'`i'
			local `x'vallist ``x'vallist' ``xx'`i''			// store x-axis positions of columns
				
			local `x'coli : word `i' of ``x'cols'
			local f: format ``x'coli'
			tokenize `"`f'"', parse("%s.,")
			confirm number `2'								// (temporary?) error trap
			local flen = `2'
			
			capture confirm string var ``x'coli'
			if !_rc local `xx'LB`i' : copy local `x'coli	// if string
			else {											// if numeric
				tempvar `xx'LB`i'
				if `"`: value label ``x'coli''"'!=`""' {	// if labelled (10th July 2017)
					qui decode ``x'coli', gen(``xx'LB`i'')
				}
				else qui gen str ``xx'LB`i'' = string(``x'coli', "`f'")
				qui replace ``xx'LB`i'' = "" if ``xx'LB`i'' == "."
				
				local colName : variable label ``x'coli'
				// Removed v3.0.1 for consistency with string variables
				// Now -forestplot- consistently honours *blank* varlabels
				// if `"`colName'"' == "" & `"``x'coli'"' !=`"`labels'"' local colName = `"``x'coli'"'
				label var ``xx'LB`i'' `"`colName'"'
			}
			
			if `"`leftjustify'"'!=`""' local flen = -abs(`flen')
			local `x'lablist ``x'lablist' ``xx'LB`i''	// store contents (text/numbers) of columns
			local `x'fmtlist ``x'fmtlist' `flen'		// desired max no. of characters based on format
		}
		
		if !`lcolsN' {
			tempvar left1
			local lvallist `left1'
		}
	}

	// find `lcimin' = left-most confidence limit among the "diamonds" (including prediction intervals)
	tempvar lci2
	qui gen `lci2' = cond(`"`null'"'==`""', cond(`_LCI'>`h0', `h0', ///
		cond(`_LCI'>`CXmin', `_LCI', `CXmin')), cond(`_LCI'>`CXmin', `_LCI', `CXmin'))
		
	if `"`rfdist'"'!=`""' {			// unecessary if passed thru from -admetan-, but do it anyway
		qui replace `lci2' = cond(`"`null'"'==`""', cond(`_rfLCI'>`h0', `h0', ///
			cond(`_rfLCI'>`CXmin', `_rfLCI', `CXmin')), cond(`_rfLCI'>`CXmin', `_rfLCI', `CXmin'))
	}
		
	summ `lci2' if `touse' & inlist(`_USE', 3, 5), meanonly
	local lcimin = cond(r(N), r(min), cond(`"`null'"'==`""', `h0', `CXmin'))		// modified 28th June 2017
	drop `lci2'


	// Moved Nov 2017 for v2.2 beta
	* Unpack `usedims'
	local DXwidthChars = -9			// initialize
	if `"`usedims'"'!=`""' {
		local DXwidthChars = `usedims'[1, `=colnumb(`usedims', "cdw")']
		// local DXwidthChars = cond(`"`colsonly'"'!=`""' & (`lcolsN'*`rcolsN'==0), 0, `DXwidthChars')		// added Feb 2018		
		confirm number `DXwidthChars'
		assert `DXwidthChars' >= 0
		local dxwidcopt `"dxwidthchars(`DXwidthChars')"'

		local oldLCImin = `usedims'[1, `=colnumb(`usedims', "lcimin")']			// added 18th Sep 2017 for v2.2 beta
		confirm number `oldLCImin'		// can be <0
		
		// added 18th Sep 2017 for v2.2 beta
		if `"`usedims'"'!=`""' {
			local lcimin = min(`lcimin', `oldLCImin')
		}
	}

	// astext or dxwidth
	if `"`usedims'"'!=`""' & `astext'==-9 {
		local astextopt `"dxwidthchars(`DXwidthChars')"'
	}
	else {
		local astext = cond(`astext'==-9, 50, `astext')
		assert `astext' >= 0
		local astextopt `"astext(`astext')"'
	}
	
	// niche case:  possible that user-specified `_USE' already contains values of 9 for some reason
	// if so, change them to 99 (doesn't matter what value they are as long as not 0 to 6, or 9)
	qui replace `_USE' = 99 if `touse' & `_USE'==9
	
	local oldN = _N
	cap nois ProcessColumns `_USE' if `touse', lrcolsn(`lcolsN' `rcolsN') lcimin(`lcimin') dx(`DXmin' `DXmax') ///
		lvallist(`lvallist') llablist(`llablist') lfmtlist(`lfmtlist') ///
		rvallist(`rvallist') rlablist(`rlablist') rfmtlist(`rfmtlist') `rfopts' ///
		`astextopt' `adjust' `graphopts'
	
	if _rc {
		if _rc==1 nois disp as err `"User break in {bf:forestplot.ProcessColumns}"'
		else nois disp as err `"Error in {bf:forestplot.ProcessColumns}"'
		c_local err noerr		// tell calling program (admetan or ipdover) not to also report an error
		exit _rc
	}
	
	local leftWDtot = r(leftWDtot)
	local rightWDtot = r(rightWDtot)
	local AXmin = r(AXmin)
	local AXmax = r(AXmax)
	local astext = r(astext)

	local graphopts `"`r(graphopts)'"'

	// Column headings
	qui count if _n > `oldN'
	if r(N) {	
		assert missing(`touse') & `_USE'==9 if _n > `oldN'				// `_USE'==9 identifies these extra obs
		qui replace `touse' = 1 if _n > `oldN'
	}

	summ `id', meanonly			// `id' is only defined if `touse', but may not yet exist if title-rows have been created
	local maxid = r(max)
	qui replace `id' = `maxid' + _n - `oldN' + 1 if _n > `oldN'		// "+1" leaves a one-line gap between titles & main data	
	local borderline = r(max) + 1 - 0.25
	
	
	*** FIND OPTIMAL TEXT SIZE AND ASPECT RATIOS (given user input)
	// We already have an estimate of the height taken up by x-axis labelling (this is `rowsxlab' from ProcessXLabs)
	// Next, find basic height (in terms of number of observations) to send to GetAspectRatio
	qui count if `touse'
	local height = r(N)
	qui count if `touse' & `_USE'==9
	local height = cond(r(N), `height' + 1, `height')	// add 1 to height if titles (to take account of gap)		
	
	local usedimsopt = cond(`"`usedims'"'==`""', `""', `"usedims(`usedims')"')
	local colWDtot = `leftWDtot' + `rightWDtot'

	// height of "xmlabel" text is assumed to be ~60% of "xlabel" text ... unless favours which uses xmlabel differently!
	local rowsxlabval = cond(`"`favours'"'!=`""', `rowsxlab', max(`rowsxlab', .6*`rowsxmlab'))
	
	GetAspectRatio, astext(`astext') colwdtot(`colWDtot') height(`height') rowsxlab(`rowsxlabval') ///
		`xtitle' `favours' `graphopts' `usedimsopt' `dxwidcopt' `colsonly'

	local graphopts `"`r(graphopts)'"'

	local leftfav  `"`r(leftfav)'"'
	local rightfav `"`r(rightfav)'"'
	local favopt   `"`r(favopt)'"'
	local rowsfav = r(rowsfav)

	local xsize = r(xsize)
	local ysize = r(ysize)
	local fxsize = r(fxsize)
	local fysize = r(fysize)
	local yheight = r(yheight)
	local spacing = r(spacing)
	local textSize = r(textsize)
	local approxChars = r(approxchars)
	local graphAspect = r(graphaspect)
	local plotAspect = r(plotaspect)
	local DXwidthChars = cond(`"`usedims'"'!=`""', `DXwidthChars', `colWDtot'*((100/`astext') - 1))

	* If specified, store in a matrix the quantities needed to recreate proportions in subsequent forestplot(s)
	// [`lcimin' added 18th Sep 2017, and `height' added 2nd Nov 2017, for v2.2 beta]
	if `"`savedims'"'!=`""' {
		mat `savedims' = `DXwidthChars', `spacing', `plotAspect', `ysize', `xsize', `textSize', `height', `yheight', `lcimin'
		mat colnames `savedims' = cdw spacing aspect ysize xsize textsize height yheight lcimin
	}

	* Extra work on x-labels and aspect ratio, only needed if `colsonly'
	if `"`colsonly'"'!=`""' {
	
		if `lcolsN' & !`rcolsN' {
			// local plotAspect = `plotAspect' * `approxChars'/`leftWDtot'
			// local xsize = `xsize' * `leftWDtot'/`approxChars' 			// Nov 2017: do this or not?
			local AXmax = `DXmin'
		}
		else if !`lcolsN' & `rcolsN' {
			// local plotAspect = `plotAspect' * `approxChars'/`rightWDtot'
			// local xsize = `xsize' * `rightWDtot'/`approxChars' 			// Nov 2017: do this or not?
			local AXmin = `DXmax'
		}
		
		ExtraColsOnly,   xlablist(`xlablist')    xmlablist(`xmlablist') ///
			   xlabopt(`xlabcmd', `xlabopts')    xmlabopt(`xmlabcmd', `xmlabopts') ///
			xtickopt(`xticklist', `xtickopt') xmtickopt(`xmticklist', `xmtickopt') ///
			ax(`AXmin' `AXmax') rowsxlab(`rowsxlab' `rowsxmlab' `rowsfav') `keepxlabs' 	// Feb 2018: removed `graphopts'

		// xlabel:  insert `textSize'
		local xlabopt `"xlabel(`s(xlabcmd)', labsize(`textSize') `s(xlabopts)')"'

		// xmlabel: insert `textSize' if `favours', otherwise default to 0.6*`textSize'
		local labsizeopt = cond(`"`favours'"'!=`""', `"labsize(`textSize')"', `"labsize(`=.6*`textSize'')"')
		local xmlabopt = cond(trim(`"`s(xmlabcmd)'`s(xmlabopts)'"')==`""', `""', ///
			`"xmlabel(`s(xmlabcmd)', `labsizeopt' `s(xmlabopts)')"')
		
		// xtick and xmtick: simply use returned options from ExtraColsOnly
		local xtickopt  `"`s(xtickopt)'"'
		local xmtickopt `"`s(xmtickopt)'"'
	}

	// Else, just need to insert labsize(`textSize') into existing `xlabopt'
	else {
		local xlabopt `"xlabel(`xlabcmd', labsize(`textSize') `xlabopts')"'

		// If `favours', text size of xmlabel defaults to `textSize'; otherwise to 0.6*`textSize';  similarly for lapgap
		local labsizeopt = cond(`"`favours'"'!=`""', `"labsize(`textSize')"', `"labsize(`=.6*`textSize'')"')
		local labgapopt  = cond(`"`favours'"'!=`""', `"labgap(5)"', `""')
		local xmlabopt = cond(trim(`"`xmlabcmd'`xmlabopts'"')==`""', `""', ///
			`"xmlabel(`xmlabcmd', `labsizeopt' `labgapopt' `xmlabopts')"')
			
		local xtickopt = cond(trim(`"`xticklist'`xtickopts'"')==`""', `""', ///
			`"xtick(`xticklist', `xtickopts')"')
		local xmtickopt = cond(trim(`"`xmticklist'`xmtickopts'"')==`""', `""', ///
			`"xmtick(`xmticklist', `xmtickopts')"')
	}
	

	// Nov 2017 for v2.2 beta
	// local graphopts `"xsize(`xsize') ysize(`ysize') fxsize(`fxsize') fysize(`fysize') aspect(`plotAspect') `graphopts'"'
	// Jan 2018: f{x|y}size only if usedims/savedims
	local graphopts `"xsize(`xsize') ysize(`ysize') aspect(`plotAspect') `graphopts'"'
	if trim(`"`savedims'`usedims'"')!=`""' local graphopts `"fxsize(`fxsize') fysize(`fysize') `graphopts'"'
		
	// Return useful quantities
	return scalar aspect = `plotAspect'
	return scalar astext = `astext'
	return scalar ldw = `leftWDtot'			// display width of left-hand side
	return scalar rdw = `rightWDtot'		// display width of right-hand side
	// local DXwidthChars = cond(`"`usedims'"'!=`""', `DXwidthChars', `colWDtot'*((100/`astext') - 1))
	return scalar cdw = `DXwidthChars'		// display width of centre (i.e. the "data" part of the plot)
	return scalar height = `height'
	return scalar spacing = `spacing'
	return scalar ysize = `ysize'
	return scalar xsize = `xsize'
	return scalar textsize = `textSize'
	if trim(`"`savedims'`usedims'"')!=`""' {
		return scalar fysize = `fysize'
		return scalar fxsize = `fxsize'
	}


	** FAVOURS (part 2)
	// now check for inappropriate options
	if `"`favours'"' != `""' {
	
		// continue to allow fp as a main option, but deprecate it in documentation
		// documented way is to specify fp() as a suboption to favours()
		local oldfp `fp'
		local 0 `", `favopt'"'
		syntax [, FP(string) FORMAT(string) ANGLE(string) LABGAP(string) LABSTYLE(string) LABSize(string) LABColor(string) noSYMmetric * ]
		if `"`options'"' != `""' {
			nois disp as err `"inappropriate suboptions found in {bf:favours()}"'
			exit 198
		}
		local fp = cond(`"`fp'"'==`""' & `"`oldfp'"'!=`""', `"`oldfp'"', `"`fp'"')

		local labsizeopt = cond(`"`labsize'"'!=`""', `"labsize(`labsize')"', `"labsize(`textSize')"')
		local labgapopt  = cond(`"`labgap'"'!=`""',  `"labgap(`labgap')"',   `"labgap(5)"')
		local favopt `"`labsizeopt' `labgapopt'"'
		foreach opt in format angle labstyle labcolor {
			if `"``opt''"'!=`""' local favopt `"`favopt' `opt'(``opt'')"'
		}
		
		// modified Jan 30th 2018, and again May 21st 2018
		if `"`fp'"'==`""' local fp = .
		numlist `"`fp'"', miss max(1)
		local fp = cond(`"`eform'"'!=`""', ln(`fp'), `fp')		// fp() should be given on same scale as xlabels
		local fpmin = min(`DXmin', `XLmin')
		local fpmax = max(`DXmax', `XLmax')
		
		if !missing(`fp') {
			local leftfp  = cond(`fpmin' <= -abs(`fp') & `"`leftfav'"'!=`""', `"`=-abs(`fp')' `"`leftfav'"'"',  `""')
			local rightfp = cond(abs(`fp') <= `fpmax'  & `"`rightfav'"'!=`""', `"`=abs(`fp')' `"`rightfav'"'"', `""')
		}
		else {
			// August 2018: default is...
			// May 2018: use smaller of distances from h0 to min(DXmin, XLmin) or max(DXmax, XLmax)
			if `"`symmetric'"'==`""' {
				local fp =  min(cond(`fpmin' <= `h0' & `"`leftfav'"'!=`""',  (`h0' - `fpmin')/2, .), ///
								cond(`fpmax' >= `h0' & `"`rightfav'"'!=`""', (`fpmax' - `h0')/2, .))
				local leftfp  = cond(`fpmin' <= `h0' & `"`leftfav'"'!=`""',  `"`=`h0' - `fp'' `"`leftfav'"'"',  `""')
				local rightfp = cond(`fpmax' >= `h0' & `"`rightfav'"'!=`""', `"`=`h0' + `fp'' `"`rightfav'"'"', `""')
			}
			
			// ...but may be overruled with option `nosymmetric', e.g. if distances are extremely unbalanced
			else {
				local leftfp  = cond(`fpmin' <= `h0' & `"`leftfav'"'!=`""',  `"`=(`h0' + `fpmin')/2' `"`leftfav'"'"',  `""')
				local rightfp = cond(`fpmax' >= `h0' & `"`rightfav'"'!=`""', `"`=(`h0' + `fpmax')/2' `"`rightfav'"'"', `""')
			}
		}

		// Nov 2017 [modified Feb 2018]
		// local favopt = cond(trim(`"`leftfp'`rightfp'"')=="", "", `"xmlabel(`leftfp' `rightfp', noticks labels norescale `favopts')"')
		if trim(`"`leftfp'`rightfp'"')==`""' local favopt
		else {
			local addopt = cond(`"`xmlabopt'"'==`""', "", "add")		// if xmlabel is also used elsewhere
			local favopt `"xmlabel(`leftfp' `rightfp', noticks norescale `favopt' `addopt')"'
		}
	}		// end if trim(`"`leftfav'`rightfav'"') != `""'
	
	

	************************************
	* Build plot commands from options *
	************************************

	// Nov 2017: TEMPVARS NOT NEEDED IF COLSONLY
	if `"`colsonly'"'==`""' {
	
		** Prepare tempvars...		
		// ...for diamonds
		tempvar DiamX DiamY1 DiamY2
		local diamlist `DiamX' `DiamY1' `DiamY2'

		// ...for "overall effect" lines
		tempvar ovLine ovMin ovMax
		local ovlist `ovLine' `ovMin' `ovMax'		
		
		// ...for off-scale arrows
		tempvar offscaleL offscaleR
		local offsclist `offscaleL' `offscaleR'
		
		if `"`rfdist'"'!=`""' {
			tempvar rfLoffscaleL rfLoffscaleR rfRoffscaleL rfRoffscaleR
			local rfoffsclist `rfLoffscaleL' `rfLoffscaleR' `rfRoffscaleL' `rfRoffscaleR'
		}
		
		// ...for multiple plotids
		tempvar toused
		
		local tvopts `"diamlist(`diamlist') ovlist(`ovlist') offsclist(`offsclist') rfoffsclist(`rfoffsclist') toused(`toused')"'
	}

	// August 2018: N.B. unusually, have to pass `touse' as an option here (rather than using marksample)
	// since we need to have the same tempname appearing in the created plot commands
	cap nois BuildPlotCmds `_USE' `_ES' `_LCI' `_UCI', touse(`touse') id(`id') ///
		plotid(`plotid') dataid(`dataid') nd(`nd') np(`np') ///
		`colsonly' `cumulative' `interaction' `graphopts' h0(`h0') `null' ///
		wgt(`wgt') `newwt' rfdist(`_rfLCI' `_rfUCI') cxlist(`CXmin' `CXmax') `tvopts'
	
	if _rc {
		if _rc==1 disp as err "User break"
		else disp as err `"Error in {bf:forestplot.BuildPlotCmds}"'
		c_local err noerr		// tell calling subroutine not to also report an error
		exit _rc
	}

	local olinePlot   `"`s(olineplot)'"'
	local nullCommand `"`s(nullcommand)'"'
	local scPlot      `"`s(scplot)'"'
	local CIPlot      `"`s(ciplot)'"'
	local RFPlot      `"`s(rfplot)'"'
	local PCIPlot     `"`s(pciplot)'"'
	local diamPlot    `"`s(diamplot)'"'
	local pointPlot   `"`s(pointplot)'"'
	local ppointPlot  `"`s(ppointplot)'"'
	local graphopts   `"`s(options)'"'

	// Commands for plotting columns of text (lcols/rcols)
	forvalues i = 1/`lcolsN' {
		local lcolCommands `"`macval(lcolCommands)' scatter `id' `left`i'' if `touse', msymbol(none) mlabel(`leftLB`i'') mlabcolor(black) mlabpos(3) mlabgap(0) mlabsize(`textSize') ||"'
	}
	forvalues i = 1/`rcolsN' {
		local rcolCommands `"`macval(rcolCommands)' scatter `id' `right`i'' if `touse', msymbol(none) mlabel(`rightLB`i'') mlabcolor(black) mlabpos(3) mlabgap(0) mlabsize(`textSize') ||"'
	}
		
	
	
	***************************
	***     DRAW GRAPH      ***
	***************************

	// First, if `useopts' and `graphopts' both supplied, check for repeated (non-Stata graph) options in `graphopts' which would cause -twoway- to fail
	//  (otherwise, onus is on user as usual)
	if `"`useopts'"'!=`""' & `"`orig_gropts'"'!=`""'{
		local 0 `", `graphopts'"'
		syntax [, BY(varname) EFORM EFFect(string) LABels(varname string) DP(integer 2) KEEPALL ///
			INTERaction LCols(namelist) RCols(namelist) LEFTJustify COLSONLY RFDIST(varlist numeric min=2 max=2) ///
			NULLOFF noNAmes noNULL NULL2(string) noKEEPVars noOVerall noSTATs noSUbgroup noWT LEVEL(real 95) ///
			XTItle(passthru) FAVours(passthru) /// /* N.B. -xtitle- is parsed here so that a blank title can be inserted if necessary */
			CUmulative /// /* only needed in order to switch _USE==3 back to _USE==1
			/// /* Sub-plot identifier for applying different appearance options, and dataset identifier to separate plots */
			PLOTID(string) DATAID(string) ///
			/// /* "fine-tuning" options */
			SAVEDIms(name) USEDIms(name) ASText(real -9) noADJust ///
			FP(string) /// 		/*(deprecated; now a favours() suboption)*/
			KEEPXLabs /// 	/*(undocumented; colsonly option)*/
			RAnge(string) CIRAnge(string) /// /* from ProcessXLabs*/
			DXWIDTHChars(real -9) LBUFfer(real 0) RBUFfer(real 1) /// /* from ProcessColumns */
			noADJust noLCOLSCHeck TArget(integer 0) MAXWidth(integer 0) MAXLines(integer 0) noTRUNCate ///
			ADDHeight(real 0) /// /* from GetAspectRatio */
			CLASSIC noDIAmonds WGT(varname numeric) NEWwt BOXscale(real 100.0) noBOX /// /* from BuildPlotCmds */
			/// /* standard options */
			BOXOPts(string asis) DIAMOPts(string asis) POINTOPts(string asis) CIOPts(string asis) OLINEOPts(string asis) NLINEOPts(string asis) ///
			/// /* non-diamond and prediction interval options */
			PPOINTOPts(string asis) PCIOPts(string asis) RFOPts(string asis) * ]
		
		local graphopts `"`macval(options)'"'
	}
	
	local xtitleopt = cond(`"`xtitle'"'==`""', `"xtitle("")"', `"`xtitle'"')		// to prevent tempvar name being printed as xtitle
	
	summ `id', meanonly
	local DYmin = r(min)-1
	local DYmax = r(max)+1

	// Re-ordered 28th June 2017 so that all twoway options are given together at the end	
	#delimit ;

	twoway

	/* Nov 2017: order was: columns, overall, weighted, diamonds */
	
	/* WEIGHTED SCATTERPLOT BOXES (plus plot-specific options) */ 
	/*  and CONFIDENCE INTERVALS (incl. "offscale" if necessary) */
		`scPlot' `CIPlot'
	
	/* OVERALL AND NULL LINES (plus plot-specific options) */ 
		`olinePlot' `nullCommand'
	
	/* DIAMONDS (or markers+CIs if appropriate) FOR SUMMARY ESTIMATES */
	/* (and Prediction Intervals if appropriate; plus plot-specific options) */
	/*  then last of all PLOT EFFECT MARKERS to clarify */
		`RFPlot' `PCIPlot' `diamPlot' `pointPlot' `ppointPlot' 
	
	/* COLUMN VARIBLES (including effect sizes and weights on RHS by default) */
		`lcolCommands' `rcolCommands'

	/* FAVOURS OR XTITLE */
	/* do these first, so that their options may be overwritten by the user */
		, `favopt' `xtitleopt'
	
	/* Y-AXIS OPTIONS */
		yscale(range(`DYmin' `DYmax') noline) ylabel(none) ytitle("")
			yline(`borderline', lwidth(thin) lcolor(gs12))
	
	/* X-AXIS OPTIONS */
		xscale(range(`AXmin' `AXmax')) `xlabopt' `xmlabopt' `xtickopt' `xmtickopt' legend(off)

	/* OTHER TWOWAY OPTIONS (`graphopts' = user-specified) */
		`graphopts' plotregion(margin(zero)) ;

	#delimit cr

end





program define getWidth, sortpreserve
version 9.0

//	ROSS HARRIS, 13TH JULY 2006
//	TEXT SIZES VARY DEPENDING ON CHARACTER
//	THIS PROGRAM GENERATES APPROXIMATE DISPLAY WIDTH OF A STRING
//  (in terms of the current graphics font)
//	FIRST ARG IS STRING TO MEASURE, SECOND THE NEW VARIABLE

//	PREVIOUS CODE DROPPED COMPLETELY AND REPLACED WITH SUGGESTION
//	FROM Jeff Pitblado

// Updated August 2016 by David Fisher (added "touse" and "replace" functionality)

syntax anything [if] [in] [, REPLACE]

assert `: word count `anything''==2
tokenize `anything'
marksample touse

if `"`replace'"'==`""' {		// assume `2' is newvar
	confirm new variable `2'
	qui gen `2' = 0 if `touse'
}
else {
	confirm numeric variable `2'
	qui replace `2' = 0 if `touse'
}

qui {
	count if `touse'
	local N = r(N)
	tempvar obs
	bys `touse' : gen int `obs' = _n if `touse'
	sort `obs'
	forvalues i = 1/`N'{
		local this = `1'[`i']
		local width: _length `"`this'"'
		replace `2' =  `width' /*+1*/ in `i'	// "+1" blanked out by DF; add back on at point of use if necessary
	}
} // end qui

end



* exit

//	METAN UPDATE
//	ROSS HARRIS, DEC 2006
//	MAIN UPDATE IS GRAPHICS IN THE _dispgby PROGRAM
//	ADDITIONAL OPTIONS ARE lcols AND rcols
//	THESE AFFECT DISPLAY ONLY AND ALLOW USER TO SPECIFY
//	VARIABLES AS A FORM OF TABLE. THIS EXTENDS THE label(namevar yearvar)
//	SYNTAX, ALLOWING AS MANY LEFT COLUMNS AS REQUIRED (WELL, LIMIT IS 10)
//	IF rcols IS OMMITTED DEFAULT IS THE STUDY EFFECT (95% CI) AND WEIGHT
//	AS BEFORE- THESE ARE ALWAYS IN UNLESS OMITTED USING OPTIONS
//	ANYTHING ADDED TO rcols COMES AFTER THIS.


********************
** May 2007 fixes **
********************

//	"nostandard" had disappeared from help file- back in
//	I sq. in return list
//	sorted out the extra top line that appears in column labels
//	fixed when using aspect ratio using xsize and ysize so inner bit matches graph area- i.e., get rid of spaces for long/wide graphs
//	variable display format preserved for lcols and rcols
//	abbreviated varlist now allowed
//	between groups het. only available with fixed
//	warnings if any heterogeneity with fixed (for between group het if any sub group has het, overall est if any het)
// 	nulloff option to get rid of line




******************
* DF subroutines *
******************


* CheckOpts
// Based on the built-in _check_eformopt.ado,
//   but expanded from -eform- to general effect specifications.
// This program is used by -ipdmetan-, -admetan- and -forestplot-
// Not all aspects are relevant to all programs,
//   but easier to maintain just a single subroutine!

program define CheckOpts, sclass

	syntax [name(name=cmdname)] [, soptions OPts(string asis) ESTVAR(name) ]
	
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

	if "`estvar'"=="_cons" {			// if constant model, make use of eform_cons_ti if available
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
		if trim(`"`md'`wmd'"')!=`""' {		// MD and WMD are synonyms
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
	local log = cond(trim(`"`coef'`logopt'"')!=`""', "log", "`log'")					// `coef' is a synonym for `log'; `logopt' was defined earlier
	if `"`log'"'!=`""' {
		if inlist("`summstat'", "rd", "smd", "wmd") {
			nois disp as err "Log option only appropriate with ratio statistics"
			exit 198
		}
		local eform
	}
	
	sreturn clear
	sreturn local logopt = trim(`"`coef'`logopt'"')		// "original" log option
	sreturn local log      `"`log'"'					// either "log" or nothing
	sreturn local eform    `"`eform'"'					// either "eform" or nothing
	sreturn local summstat `"`summstat'"'				// if `eform', original eform option
	sreturn local effect   `"`effect'"'
	sreturn local options  `"`macval(options)'"'

end




*********************************************************************************

* Subroutine to sort out labels and ticks for x-axis, and find DXmin/DXmax (and CXmin/CXmax if different)
* Created August 2016
* Last modified Jan 2018 for v2.2

program define ProcessXLabs, rclass

	syntax anything [, XLabel(string asis) XMLabel(string asis) XTICk(string) XMTick(string) ///
		RAnge(string) CIRAnge(string) EFORM H0(real 0) noNULL * ]
	local graphopts `"`options'"'
	tokenize `anything'
	args DXmin DXmax
	

	* Parse `range' and `cirange'
	// in both cases, "min" and "max" refer to range of data in terms of LCI, UCI
	// (that is, initial values of `DXmin', `DXmax')
	if "`range'" != `""' {
		tokenize `range'
		cap {
			assert `"`2'"'!=`""'
			assert `"`3'"'==`""'
		}
		if _rc {
			disp as err `"option {bf:range()} must contain exactly two elements"'
			exit 198
		}
		
		if inlist(`"`1'"', "min", "max") | inlist(`"`2'"', "min", "max") {
			if `"`eform'"'!=`""' {
				forvalues i=1/2 {
					cap confirm number ``i''
					if !_rc local `i' = ln(``i'')
				}
			}
			local range `"`1' `2'"'
			local range = subinstr(`"`range'"', `"min"', `"`DXmin'"', .)
			local range = subinstr(`"`range'"', `"max"', `"`DXmax'"', .)
			numlist "`range'", min(2) max(2) sort
			local range = r(numlist)
			tokenize "`range'"
			args RXmin RXmax
		}	
		
		else {
			if `"`eform'"'!=`""' {
				numlist "`range'", min(2) max(2) range(>0) sort
				local range `"`=ln(`1')' `=ln(`2')'"'
			}
			else {
				numlist "`range'", min(2) max(2) sort
				local range = r(numlist)
			}
			tokenize "`range'"
			args RXmin RXmax
		}
	}
	
	if "`cirange'" != `""' {
		tokenize `cirange'
		cap {
			assert `"`2'"'!=`""'
			assert `"`3'"'==`""'
		}
		if _rc {
			disp as err "option {bf:cirange()} must contain exactly two elements"
			exit 198
		}
		
		// if "min", "max" used
		if inlist(`"`1'"', "min", "max") | inlist(`"`2'"', "min", "max") {
			if `"`eform'"'!=`""' {
				forvalues i=1/2 {
					cap confirm number ``i''
					if !_rc local `i' = ln(``i'')
				}
			}
			local cirange `"`1' `2'"'
			local cirange = subinstr(`"`cirange'"', `"min"', `"`DXmin'"', .)
			local cirange = subinstr(`"`cirange'"', `"max"', `"`DXmax'"', .)
			numlist "`cirange'", min(2) max(2) sort
			local cirange = r(numlist)
			tokenize "`cirange'"
			args CXmin CXmax
		}	

		else {
			if `"`eform'"'!=`""' {
				numlist "`cirange'", min(2) max(2) range(>0) sort
				local cirange `"`=ln(`1')' `=ln(`2')'"'
			}
			else {
				numlist "`cirange'", min(2) max(2) sort
				local cirange = r(numlist)
			}
			tokenize "`cirange'"
			args CXmin CXmax
		}
	}
	
	
	* Parse x[m]label if supplied by user
	local rowsxmlab = 0
	local rowsxlab = 0
	foreach xl in xlab xmlab {
		
		local 0 `"``xl'el'"'		// xlabel, xmlabel
		syntax [anything(name=`xl'cmd)] , [FORCE FORMAT(string) * ]
		local forceopt = cond(`"`xl'"'==`"xlab"', `"`force'"', `"`forceopt'"')		// "force" option only applies to xlab, not xmlab
		local `xl'opts `"`options'"'
		
		// Parse x[m]lablist and obtain numlist (Nov 2017)
		if `"``xl'cmd'"'!=`""' {
			local rows`xl' = 1
			
			local lbl
			local lbl2
			local qed
			local rest : copy local `xl'cmd
			while `"`rest'"'!=`""' | `"`lbl'"'!=`""' {			// Feb 2018: added the second part of this stmt
				if `"`lbl'"'!=`""' local lbl2 `"`lbl'"'			// Nov 2017: user-specified labels need to go round the loop once, before being applied
				local lbl
				
				gettoken tok rest : rest, qed(qed)
				if `"`tok'"'!=`""' {
				
					// if text label found, check for embedded quotes (i.e. multiple lines)
					if `qed' {
						local rest2 `"`"`tok'"'"'
						gettoken el : rest2, quotes qed(qed2)
						if !`qed2' {
							disp as err `"invalid label specifier, : ``xl'list':"'
							exit 198
						}
						local new`xl'cmd `"`new`xl'cmd' `rest2'"'
						while `"`rest2'"'!=`""' {
							gettoken el rest3 : rest2, quotes
							if `"`el'"'==`"`""'"' {
								local newlist : list rest2 - el	// modified Feb 2018; check
								continue, break
							}
							local newlist `"`newlist' `el'"'
							local rest2 `"`rest3'"'
						}
						local rows`xl' = max(`rows`xl'', `: word count `newlist'')
						local lbl2				
					}	// end if `qed'
					
					// else, check if valid numlist
					else {
						cap numlist `"`tok'"'
						if _rc {
							if substr(`"`tok'"', 1, 1)==`"#"' {
								disp as err `"Cannot use the {bf:#} syntax in the {bf:`xl'el()} option of {bf:forestplot}; please use a {it:numlist} instead"'
							}
							else numlist `"`tok'"'
						}
						if `"`eform'"'!=`""' {
							cap numlist `"`tok'"', range(>0)
							if _rc {
								disp as err `"option {bf:eform} specified, but {bf:`xl'el()} contains non-positive values"'
								exit 198
							}
						
							// if eform, need to expand numlist and take logs
							local nl = r(numlist)
							local N : word count `nl'
							forvalues i=1/`N' {
								local el : word `i' of `nl'
								local `xl'list `"``xl'list' `=ln(`el')'"'
								local new`xl'i `"`=ln(`el')'"'
								
								local lbl = cond("`format'"=="", string(`el'), string(`el', "`format'"))
								if `i'==1 & `"`lbl2'"'!=`""' local new`xl'i `"`"`lbl2'"' `new`xl'i'"'
								if `i'<`N'                   local new`xl'i `"`new`xl'i' `"`lbl'"'"'
								local lbl2
								// don't add the last label yet, in case user has specified their own label
								
								local new`xl'cmd `"`new`xl'cmd' `new`xl'i'"'
							}
						}
						
						// else, can simply add unexpanded numlist
						else {
							local `xl'list `"``xl'list' `tok'"'
							local new`xl'cmd `"`new`xl'cmd' `tok'"'
							local lbl2
						}
					}		// end else
				}		// end if `"`tok'"'!=`""'
					
				// if lbl, add it now
				if `"`lbl2'"'!=`""' {
					local new`xl'cmd `"`new`xl'cmd' `"`lbl2'"'"'
					local lbl
					local lbl2
				}

			}	// while loop
			
			local `xl'list = trim(`"``xl'list'"')
			local `xl'cmd  = trim(`"`new`xl'cmd'"')
		}

		cap assert `"``xl'cmd'"'==`""' if `"``xl'list'"'==`""'
		if _rc {
			disp as err "Error in {bf:`xl'el()}"
			exit 198
		}
		
		local `xl'fmt : copy local format		// added 1st May 2018
	}
	
	if `"`xlablist'"' != `""' {
		if "`forceopt'"!=`""' {
			if "`cirange'"!="" {
				disp as err `"Note: both {bf:cirange()} and {bf:xlabel(, force)} were specifed; {bf:cirange()} takes precedence"'
			}
			else {
				numlist "`xlablist'", sort
				local n : word count `r(numlist)'
				
				// added Sep 2017 for v2.1
				if `"`range'"'==`""' {
					local RXmin : word 1 of `r(numlist)'		// if `range' not specified, default to "forced" xlab limits
					local RXmax : word `n' of `r(numlist)'
				}
				else {
					local CXmin : word 1 of `r(numlist)'		// otherwise, set `cirange' instead
					local CXmax : word `n' of `r(numlist)'
				}
			}
		}		
	}

	
	* Parse ticks
	// JUN 2015 -- for future: is there any call for allowing FORCE, or similar, for ticks??
	foreach tick in xtick xmtick {
		if `"``tick''"' != "" {
			local 0 `"``tick''"'
			syntax [anything(name=`tick'list)] , [ * ]	
			local `tick'opts `"`options'"'	
		
			if `"``tick'list'"' != `""' {
				cap numlist `"``tick'list'"'
				if _rc {
					disp as err `"invalid label specifier, : ``tick'list'"'
					exit 198
				}
				if `"`eform'"'!=`""' {							// assume given on exponentiated scale if "eform" specified, so need to take logs
					cap numlist "``tick'list'", range(>0)		// ...in which case, all values must be greater than zero
					if _rc {
						disp as err `"with {bf:eform} option, {bf:`tick'()} values are expected to be on the exponentiated scale"'
						disp as err `"and therefore strictly greater than zero"'
						exit 198
					}
					local e`tick'list ``tick'list'
					local `tick'list
					foreach xi of numlist `e`tick'list' {
						local `tick'list `"``tick'list' `=ln(`xi')'"'
					}
				}
			}
		}
	}
	
	* Check validity of user-defined values
	if `"`range'"'!=`""' & `"`cirange'"'!=`""' {
		cap {
			assert `RXmin' <= `CXmin'
			assert `RXmax' >= `CXmax'
		}
		if _rc {
			disp as err "interval defined by {opt cirange()} (or {bf:xlabel(, force)}) must lie within that defined by {opt range()}"
			exit 198
		}
	}

	// changed Sep 2017 for v2.1
	else if `"`cirange'"'==`""' & `"`range'"'!=`""' {
		local CXmin = max(`RXmin', `DXmin')
		local CXmax = min(`RXmax', `DXmax')
	}
	
	// Jan 2018: Now re-set DXmin/DXmax if RXmin/RXmax are defined
	// CHECK CONSEQUENCES OF THIS CAREFULLY
	if `"`RXmin'`RXmax'"'!=`""' {
		local DXmin = `RXmin'
		local DXmax = `RXmax'
	}
	
	// remove null line if lies outside range of x values to be plotted
	if "`null'"=="" & trim("`cirange'`range'`forceopt'")!="" {
		local removeNull = 0
		if `"`cirange'"'!=`""' {
			local removeNull = (`h0' < `CXmin' | `h0' > `CXmax')
		}
		else local removeNull = (`h0' < `RXmin' | `h0' > `RXmax')

		if `removeNull' {
			nois disp as err "null line lies outside of user-specified x-axis range and will be suppressed"
			local null nonull
		}
	}
	return local null `null'

	
	* If xlabel not supplied by user, need to choose sensible values
	// Default is for symmetrical limits, with 3 labelled values including null
	// N.B. First modified from original -metan- code by DF, March 2013
	//  with further improvements by DF, January 2015
	// Last modifed by DF April 2017 to avoid interminable looping if [base]^`mag' = missing

	local xlablim1=0		// init
	if `"`xlablist'"' == `""' {
	
		// If null line, choose values based around `h0'
		// (i.e. `xlabinit1' = `h0'... but `h0' is automatically selected anyway so no need to explicitly define `xlabinit1')
		if "`null'" == "" {
			local xlabinit2 = max(abs(`DXmin' - `h0'), abs(`DXmax' - `h0'))
			local xlabinit "`xlabinit2'"
		}
		
		// if `nulloff', choose values in two stages: firstly based on the midpoint between CXmin and CXmax (`xlab[init|lim]1')
		//  and then based on the difference between CXmin/CXmax and the midpoint (`xlab[init|lim]2')
		else {
			local xlabinit1 = (`DXmax' + `DXmin')/2
			local xlabinit2 = abs(`DXmax' - `xlabinit1')		// N.B. same as abs(`CXmin' - `xlabinit1')
			if float(`xlabinit1') != 0 {
				local xlabinit "`=abs(`xlabinit1')' `xlabinit2'"
			}
			else local xlabinit `xlabinit2'
		}
		assert "`xlabinit'"!=""
		assert "`xlabinit2'"!=""
		assert `: word count `xlabinit'' == ("`null'"!="")*(float(`DXmax')!=-float(`DXmin')) + 1		// should be >= 1
		
		local counter=1
		foreach xval of numlist `xlabinit' {
		
			if `"`eform'"'==`""' {						// linear scale
				local mag = floor(log10(`xval'))
				local xdiff = abs(`xval'-`mag')
				foreach i of numlist 1 2 5 10 {
					local ii = `i' * 10^`mag'
					if missing(`ii') {
						local ii = `=`i'-1' * 10^`mag'
						local xdiff = abs(float(`xval' - `ii'))
						local xlablim = `ii'
						continue, break
					}
					else if abs(float(`xval' - `ii')) <= float(`xdiff') {
						local xdiff = abs(float(`xval' - `ii'))
						local xlablim = `ii'
					}
				}
			}
			else {										// log scale
				local mag = round(`xval'/ln(2))
				local xdiff = abs(`xval' - ln(2))
				forvalues i=1/`mag' {
					local ii = ln(2^`i')
					if missing(`ii') {
						local ii = ln(2^`=`i'-1')
						local xdiff = abs(float(`xval' - `ii'))
						local xlablim = `ii'
						continue, break
					}
					else if abs(float(`xval' - `ii')) <= float(`xdiff') {
						local xdiff = abs(float(`xval' - `ii'))
						local xlablim = `ii'
					}
				}
				
				// if effect is small, use 1.5, 1.33, 1.25 or 1.11 instead, as appropriate
				foreach i of numlist 1.5 `=1/0.75' 1.25 `=1/0.9' {
					local ii = ln(`i')
					if abs(float(`xval' - `ii')) <= float(`xdiff') {
						local xdiff = abs(float(`xval' - `ii'))
						local xlablim = `ii'
					}
				}	
			}
			
			// if nonull, center limits around `xlablim1', which should have been optimized by the above code
			if "`null'" != "" {		// nonull
				if `counter'==1 {
					local xlablim1 = `xlablim'*sign(`xlabinit1')
				}
				if `counter'>1 | `: word count `xlabinit''==1 {
					local xlablim2 = `xlablim'
					local xlablims `"`=`xlablim1'+`xlablim2'' `=`xlablim1'-`xlablim2''"'
				}
			}
			else local xlablims `"`xlablims' `xlablim'"'
			local ++counter

		}	// end foreach xval of numlist `xlabinit'
			
		// if nulloff, don't recalculate CXmin/CXmax
		if "`null'" != "" numlist `"`xlablim1' `xlablims'"'
		else {
			numlist `"`=`h0' - `xlablims'' `h0' `=`h0' + `xlablims''"', sort	// default: limits symmetrical about `h0'
			tokenize `"`r(numlist)'"'

			// if data are "too far" from null (`h0'), take one limit (but not the other) plus null
			//   where "too far" ==> abs(`CXmin' - `h0') > `CXmax' - `CXmin'
			//   (this works whether data are "too far" to the left OR right, since our limits are symmetrical about `h0')
			if abs(`DXmin' - `h0') > `DXmax' - `DXmin' {
				if `3' > `DXmax'      numlist `"`1' `h0'"'
				else if `1' < `DXmin' numlist `"`h0' `3'"'
			}
			else if trim("`range'`cirange'`forceopt'")=="" {		// "standard" situation
				numlist `"`1' `h0' `3'"'
				local DXmin = `h0' - `xlabinit2'
				local DXmax = `h0' + `xlabinit2'
			}
		}
		local xlablist=r(numlist)
		
		// if log scale, label with exponentiated values
		if `"`eform'"'!=`""' {
			local xlabcmd
			foreach xi of numlist `xlablist' {
				local lbl = cond("`xlabfmt'"=="", string(exp(`xi')), string(exp(`xi'), "`xlabfmt'"))
				local xlabcmd `"`xlabcmd' `xi' `"`lbl'"'"'				
			}
			// return local xlabfmt `"`xlabfmt'"'	// Nov 2017: in case of colsonly + eform
		}
		else {
			local xlabcmd `"`xlablist'"'
		
			// If formatting not used here (for string labelling), return it alongside other `xlabopts' to pass to -twoway-
			// if `"`format'"'!=`""' local xlabopts `"`xlabopts' format(`format')"'
		}
		
		// Added Feb 2018: If automatic labelling, set rows to 1 (rowsxmlab remains at 0)
		local rowsxlab = 1
		
	}		// end if "`xlablist'" == ""
	
	if `"`xlabfmt'"'!=`""'  local xlabopts   `"`xlabopts' format(`xlabfmt')"'
	if `"`xmlabfmt'"'!=`""' local xmlabopts `"`xmlabopts' format(`xmlabfmt')"'

	numlist `"`xlablist' `xticklist' `xmticklist'"', sort
	local n : word count `r(numlist)' 
	local XLmin : word 1 of `r(numlist)'
	local XLmax : word `n' of `r(numlist)'
	
	
	* Use symmetrical plot area (around `h0'), unless data "too far" from null
	if trim(`"`range'`cirange'`forceopt'"')==`""' {

		// if "too far", adjust `CXmin' and/or `CXmax' to reflect this
		//   where "too far" ==> max(abs(`CXmin'-`h0'), abs(`CXmax'-`h0')) > `CXmax' - `CXmin'
		local TooFar = 0
		if "`null'"=="" {		
			if `h0' - `DXmax' > `DXmax' - `DXmin' {						// data "too far" to the left
				local DXmax = max(`h0' + .5*(`DXmax'-`DXmin'), `XLmax')	// clip the right-hand side
				local TooFar = 1
			}	
			if `DXmin' - `h0' > `DXmax' - `DXmin' {						// data "too far" to the right
				local DXmin = min(`h0' - .5*(`DXmax'-`DXmin'), `XLmin')	// clip the left-hand side
				local TooFar = 1
			}
			// local toofar "toofar"
		}
	
		// if `"`toofar'"'==`""' {		// modified Jan 2018
		if `TooFar' {
			local DXmin = -max(abs(`DXmin'), abs(`DXmax'))
			local DXmax =  max(abs(`DXmin'), abs(`DXmax'))
		}
	}
	
	* Final calculation of DXmin, DXmax
	if trim(`"`RXmin'`RXmax'"')!=`""' {
		numlist `"`RXmin' `RXmax'"', sort
	}
	else {
		numlist `"`DXmin' `DXmax' `XLmin' `XLmax'"', sort
	}
	local n : word count `r(numlist)' 
	local DXmin : word 1 of `r(numlist)'
	local DXmax : word `n' of `r(numlist)'
	
	if trim(`"`CXmin'`CXmax'"')==`""' {
		local CXmin = `DXmin'
		local CXmax = `DXmax'
	}	
	
	// Position of xtitle
	local xtitleval = cond("`xlablist'"=="", `xlablim1', .5*(`CXmin' + `CXmax'))
	return scalar xtitleval = `xtitleval'	
	
	// Return scalars
	return scalar CXmin = `CXmin'
	return scalar CXmax = `CXmax'
	return scalar DXmin = `DXmin'
	return scalar DXmax = `DXmax'
	return scalar XLmin = `XLmin'
	return scalar XLmax = `XLmax'
	
	// moved Feb 2018; modified Oct 2018
	return scalar rowsxlab = `rowsxlab'
	return scalar rowsxmlab = `rowsxmlab'
	
	return local xlablist   `"`xlablist'"'
	return local xlabcmd    `"`xlabcmd'"'
	return local xlabopts   `"`xlabopts'"'

	return local xmlablist  `"`xmlablist'"'
	return local xmlabcmd   `"`xmlabcmd'"'
	return local xmlabopts  `"`xmlabopts'"'

	return local xticklist  `"`xticklist'"'
	return local xtickopts  `"`xtickopts'"'

	return local xmticklist `"`xmticklist'"'
	return local xmtickopts `"`xmtickopts'"'

	return local options    `"`graphopts'"'

end




*********************************************************************************

* Subroutine to do extra work sorting out labels/ticks ONLY IF COLSONLY
// Created Nov 2017
program define ExtraColsOnly, sclass

	syntax [, XLABLIST(numlist) XMLABLIST(numlist) ///
		XLABOPT(string asis) XMLABOPT(string asis) XTICKOPT(string asis) XMTICKOPT(string asis) ///
		AX(numlist) ROWSXLAB(numlist >=0) KEEPXLabs ]		// Feb 2018: blanked out * and added xmlablist/opt

	tokenize `ax'
	args AXmin AXmax
	
	tokenize `rowsxlab'
	args rowsxlab rowsxmlab rowsfav
	local rowsxmlab = max(`rowsfav', `rowsxmlab')
		
	// adjust xticklist and xlablist if needed
	// NOV 2017: NEEDS RE-DOING:  (Oct 2018: include in next version, v3.1 ?)
	// INCLUDE XMTICK
	// BUT ALSO, NEED TO TAKE ACCOUNT OF TEXT LABELS IN XLABLIST (BELOW) -- see revised code of ProcessXLabs
	local lt = cond(`"`keepxlabs'"'==`""', `"<="', `"<"')
	local gt = cond(`"`keepxlabs'"'==`""', `">="', `">"')
	
	// Ticklists: these are easy since no labels, so can use subinstr()
	foreach tick in xtick xmtick {
		local 0 `"``tick'opt'"'
		syntax [anything(name=`tick'list)] [, *]
		local `tick'opts `"`options'"'
	
		local old`tick' = 0
		if `"``tick'list'"'!=`""' {
			local old`tick' = 1
			numlist `"``tick'list'"'
			local `tick'list = r(numlist)		
			foreach xi of numlist ``tick'list' {
				if `xi' `lt' `AXmin' | `xi' `gt' `AXmax' {
					local `tick'list = subinstr(`" ``tick'list' "', `" `xi' "', `" "', .)
				}
			}
			local `tick'list = trim(itrim(`"``tick'list'"'))
		}
	}

	// Process xlabcmd and xmlabcmd
	foreach xl in xlab xmlab {
		local 0 `"``xl'opt'"'
		syntax [anything(name=`xl'cmd)] [, FORMAT(string) *]
		local `xl'fmt `"`format'"'
		local `xl'opts `"`options'"'
		
		// technique for xlablist:  first, find which values need to be removed
		// then (assuming there are any) find them within `xlabcmd'
		// and remove them AND any associated label.
		if `"``xl'list'"'!=`""' {
			numlist `"``xl'list'"'
			local `xl'list = r(numlist)		
			foreach xi of numlist ``xl'list' {
				if `xi' `lt' `AXmin' | `xi' `gt' `AXmax' {
					local remove `"`remove' `xi'"'
				}
			}
			if `: word count `remove'' {
				local `xl'list : list `xl'list - remove
				
				local rest : copy local `xl'cmd
				local `xl'cmd
				local flag = 0
				while `"`rest'"'!=`""' {
					gettoken el rest : rest, quotes qed(qed)
					if !`qed' local flag=0
					if `: list el in remove' local flag=1
					
					if `flag'!=1 {
						local `xl'cmd `"``xl'cmd' `el'"'
						if `qed' local flag=0
					}
				}
			}
		}
		
		if `"``xl'list'"'!=`""' {
			if `"`eform'"'!=`""' {
				local `xl'cmd
				foreach xi of numlist ``xl'list' {
					local lbl = cond("``xl'fmt'"=="", string(exp(`xi')), string(exp(`xi'), "``xl'fmt'"))
					local `xl'cmd `"``xl'cmd' `xi' `"`lbl'"'"'
				}
			}
			else local `xl'cmd `"``xl'list'"'
			local `xl'cmd = trim(`"``xl'cmd'"')
		}
		
		// If xlablist has been entirely removed, use blank lines to use up the same space as labels would
		else if `"`xl'"'==`"xlab"' & `rowsxlab' {
			forvalues i=1/`rowsxlab' {
				local xlabtxt `"`xlabtxt' `" "'"'
			}
			if `rowsxlab' > 1 local xlabtxt `"`"`xlabtxt'"'"'
			local xlabcmd `"`AXmin' `xlabtxt'"'
			local xlabopts `"`xlabopts' tlc(none)"'
		}
		
		// same for xmlablist/favours
		else if `"`xl'"'==`"xmlab"' & `rowsxmlab' {
			forvalues i=1/`rowsxmlab' {
				local xmlabtxt `"`xmlabtxt' `" "'"'
			}
			if `rowsxmlab' > 1 local xmlabtxt `"`"`xmlabtxt'"'"'
			local xmlabcmd `"`AXmin' `xmlabtxt'"'
			local xmlabopts `"`xmlabopts' tlc(none)"'
		}
	}
	
	// Process ticklists: these are easier as no labels (see above)
	foreach tick in xtick xmtick {
		if `old`tick'' {
			local `tick'list `AXmin'
			local `tick'opts `"``tick'opts' tlc(none)"'
		}
	}
	
	// Oct 2018: CONSIDERATIONS FOR NEXT VERSION (v3.1 ?)
	// local xlabopt = cond(`"`xlabcmd'"'==`""', `"xlabel(none)"', `"xlabel(`xlabcmd', labsize(`textSize') `xlabopts')"')
	// local xtickopt = cond(`"`xticklist'"'==`""', `"xtick(none)"', `"xtick(`xticklist', `xtickopts')"')
	// Nov 2017: what about mtick?? also NEED TO USE BLANK LINES TO USE UP SAME SPACE AS LABELS WOULD.  also at the moment user-defined labvalues are not appearing
	// amend ProcessXLabs so that xlabel "labels" are extracted and tested for number of lines
	// revisit use of xmlabel in favour of xtitle??  any reason for this now?  YES because plot might not be centered

	sreturn local xlablist   `"`xlablist'"'
	sreturn local xlabcmd    `"`xlabcmd'"'
	sreturn local xlabopts   `"`xlabopts'"'

	sreturn local xmlablist  `"`xmlablist'"'
	sreturn local xmlabcmd   `"`xmlabcmd'"'
	sreturn local xmlabopts  `"`xmlabopts'"'

	if trim(`"`xticklist'`xtickopts'"')!=`""' {
		sreturn local xtickopt `"`xticklist', `xtickopts'"'
	}
	if trim(`"`xmticklist'`xmtickopts'"')!=`""' {
		sreturn local xmtickopt `"`xmticklist', `xmtickopts'"'
	}

	sreturn local options    `"`graphopts'"'
	
end



	
*********************************************************************************

* Process left and right columns -- obtain co-ordinates etc.
program define ProcessColumns, rclass

	syntax varname [if] [in], LRCOLSN(numlist integer >=0) LCIMIN(real) DX(numlist) ///
		[LVALlist(namelist) LLABlist(varlist) LFMTLIST(numlist integer) ///
		 RVALlist(namelist) RLABlist(varlist) RFMTLIST(numlist integer) RFINDENT(varname) RFCOL(integer 1) ///
		 DXWIDTHChars(real -9) ASText(integer -9) LBUFfer(real 0) RBUFfer(real 1) ///
		 noADJust noLCOLSCHeck TArget(integer 0) MAXWidth(integer 0) MAXLines(integer 0) noTRUNCate * ]
	
	local graphopts `"`options'"'
	
	marksample touse
	
	// rename locals for clarity
	local _USE         : copy local varlist
	local DXwidthChars : copy local dxwidthchars

	// unpack `lrcolsn' and `dx'
	tokenize `lrcolsn'
	args lcolsN rcolsN
	local rcolsN = cond(`"`rcolsN'"'==`""', 0, `rcolsN')
	
	tokenize `dx'
	args DXmin DXmax
	
	tempvar strlen strwid
	local digitwid : _length 0		// width of a digit (e.g. "0") in current graphics font = roughly average non-space character width
	local spacewid : _length " "	// width of a space in current graphics font

	quietly {
	
		** Left columns
		local leftWDtot = 0
		local nlines = 0
		forvalues i=1/`lcolsN' {
			local leftLB`i' : word `i' of `llablist'
			
			gen long `strlen' = length(`leftLB`i'')
			summ `strlen' if `touse', meanonly
			local maxlen = r(max)		// max length of existing text

			getWidth `leftLB`i'' `strwid'
			summ `strwid' if `touse', meanonly
			local maxwid = r(max)		// max width of existing text
				
			local fmtlen : word `i' of `lfmtlist'
			local leftWD`i' = cond(abs(`fmtlen') <= `maxlen', `maxwid', ///		// exact width of `maxlen' string
				abs(`fmtlen')*`digitwid')										// approx. max width (based on `digitwid')


			** Check whether title string is longer than the data itself
			// If so, potentially allow spread over a suitable number of lines
			// [DF JAN 2015: Future work might be to re-write (incl. SpreadTitle) to use width rather than length??]

			// If more than one lcol, restrict to width of "data only" (i.e. _USE==1, 2).
			// Otherwise, title may be as long as the max string length in the column.
			// [Note that, as the title isn't stored as data (yet), the max string length does NOT account for the title string itself.]
			if `lcolsN'>1 local anduse `"& inlist(`_USE', 1, 2)"'
			summ `strlen' if `touse' `anduse', meanonly
			local maxlen = r(max)
	
			local colName : variable label `leftLB`i''
			if `"`colName'"'!=`""' {
				
				if `target' local target_opt = `target'
				else {
					if `maxwidth' local target_opt = `maxwidth'
					else local target_opt = max(abs(`fmtlen'), `maxlen')
				}
				local maxwidth_opt = cond(`maxwidth', `maxwidth', `=2*`target_opt'')
				SpreadTitle `"`colName'"', target(`target_opt') maxwidth(`maxwidth_opt') maxlines(`maxlines') `truncate'
				
				if `r(nlines)' > `nlines' {
					local oldN = _N
					set obs `=`oldN' + `r(nlines)' - `nlines''
					local nlines = r(nlines) 
				}
				local l = `nlines' - `r(nlines)'
				forvalues j = `r(nlines)'(-1)1 {
					local k = _N - (`j' + `l') + 1
					replace `leftLB`i'' = `"`r(title`j')'"' in `k'
					replace `_USE' = 9 in `k'
					replace `touse' = 1 in `k'
				}
				
				getWidth `leftLB`i'' `strwid', replace			// re-calculate `strwid' to include titles

				summ `strwid' if `touse', meanonly
				local maxwid = r(max)
				local leftWD`i' = max(`leftWD`i'', `maxwid')	// in case title is necessarily longer than the variable, even after SpreadTitle
			}
			
			tempvar lindent`i' 													// for right-justifying text
			gen `lindent`i'' = cond(`fmtlen'>0, `leftWD`i'' - `strwid', 0)		// indent if right-justified
			
			local leftWD`i' = `leftWD`i'' + (2 - (`i'==`lcolsN'))*`digitwid'	// having calculated the indent, add a buffer (2x except for last col)
			local leftWDtot = `leftWDtot' + `leftWD`i''							// running calculation of total width (including titles)

			drop `strlen' `strwid'
		}		// end of forvalues i=1/`lcolsN'
		
			
		** Right columns
		local rightWDtot = 0
		forvalues i=1/`rcolsN' {		// if `rcolsN'==0, loop will be skipped
			local rightLB`i' : word `i' of `rlablist'

			gen long `strlen' = length(`rightLB`i'')
			summ `strlen' if `touse', meanonly
			local maxlen = r(max)		// max length of existing text

			getWidth `rightLB`i'' `strwid'
			summ `strwid' if `touse', meanonly		
			local maxwid = r(max)		// max width of existing text

			local fmtlen : word `i' of `rfmtlist'
			local rightWD`i' = cond(abs(`fmtlen') <= `maxlen', `maxwid', ///	// exact width of `maxlen' string
				abs(`fmtlen')*`digitwid')										// approx. max width (based on `digitwid')


			** Check whether title string is longer than the data itself
			// If so, spread it over a suitable number of lines
			// [DF JAN 2015: Future work might be to re-write (incl. SpreadTitle) to use width rather than length??]
			local colName : variable label `rightLB`i''
			if `"`colName'"'!=`""' {
				
				if `target' local target_opt = `target'
				else {
					if `maxwidth' local target_opt = `maxwidth'
					else local target_opt = max(abs(`fmtlen'), `maxlen')
				}
				local maxwidth_opt = cond(`maxwidth', `maxwidth', `=2*`target_opt'')
				SpreadTitle `"`colName'"', target(`target_opt') maxwidth(`maxwidth_opt') maxlines(`maxlines') `truncate'

				if `r(nlines)' > `nlines' {
					local oldN = _N
					set obs `=`oldN' + `r(nlines)' - `nlines''
					local nlines = r(nlines) 
				}
				local l = `nlines' - `r(nlines)'
				forvalues j = `r(nlines)'(-1)1 {
					local k = _N - (`j' + `l') + 1
					replace `rightLB`i'' = `"`r(title`j')'"' in `k'
					replace `_USE' = 9 in `k'
					replace `touse' = 1 in `k'
				}
				getWidth `rightLB`i'' `strwid', replace			// re-calculate `strwid' to include titles
					
				summ `strwid' if `touse', meanonly
				local maxwid = r(max)
				local rightWD`i' = max(`rightWD`i'', `maxwid')		// in case title is necessarily longer than the variable, even after SpreadTitle
			}
			
			tempvar rindent`i'			// for right-justifying text
			gen `rindent`i'' = .
			
			// rfdist: strwid is width of "_ES[_n-1]" as formatted by "%`fmtx'.`dp'f" so it lines up
			// rfcol = column in which rfdist info is stored
			if `"`rfindent'"'!=`""' & `i'==`rfcol' {
				getWidth `rfindent' `rindent`i'' if `touse' & !missing(`rfindent'), replace
				replace `rindent`i'' = `rindent`i'' + `spacewid' if `touse' & !missing(`rfindent')
			}
			replace `rindent`i'' = cond(`fmtlen'>0, `rightWD`i'' - `strwid', 0) if `touse' & missing(`rindent`i'')		// indent if right-justified
			
			local rightWD`i' = `rightWD`i'' + (2 - (`i'==`rcolsN'))*`digitwid'		// having calculated the indent, add a buffer (2x except for last col)
			local rightWDtot = `rightWDtot' + `rightWD`i''							// running calculation of total width (incl. buffer)
			drop `strlen' `strwid'
		}								// end of forvalues i=1/`rcols'

		local rightWDtot = `rightWDtot' + (1 + `rbuffer')*`digitwid'	// default: 1x buffer before first RHS column and after last, but can be overwritten
		local rightWDtot = max(`rightWDtot', `digitwid')				// in case of no `rcols'

		
		** "Adjust" routine
		
		*  Notes:
		// Unless we're dealing with a very non-standard user-specific case,
		//   effect sizes corresponding to pooled diamonds (_USE==3, 5) will usually be much tighter around the null value than individual effects (_USE==1, 2).
		// The longest strings of text are also likely to be found in _USE==0, 3, 4, 5, since these contain subgroup headings and heterogeneity info.
		// Therefore, we may be able to improve the aesthetics of the plot by:
		//  (1) allowing text in LH columns for _USE==3, 5 to overlap text in LH columns for _USE==1, 2;
		//  (2) allowing text in LH columns for _USE==3, 5 to extend into the central plot area, beyond the default limit of `DXmin' but without overwriting plot elements.
		
		*  However, there are some considerations:
		// - LH text columns for _USE==1, 2 must *never* extend beyond `DXmin' (o/w long study labels and long CI limits might be overwritten)
		// - Column titles (i.e. variable labels; _USE==9) may only be extended for the last (i.e. right-most) left-hand column
		// - LH text columns for _USE==0, 3, 4, 5 may only be extended if there is no data in the remaining LH columns (if any) to their right
		// - In particular, if data exists in LH columns to the right, default behaviour is for "heterogeneity info" to be placed on a new line (_USE==4)
		//     rather than at the end of the "pooled overall/subgroup" text (_USE==3, 5).
		//     This may be overruled using `noextraline' with -admetan- which implies `nolcolcheck' with -forestplot-
		// - _USE==6 represents a blank line, so these rows are irrelevant to the calculations.  The user may place text in such rows at their own discretion; it may get overwritten.
		
		*  Hence, the strategy is:
		// - Recalculate column widths (`leftWD`i'') restricting to _USE==1, 2, 9 (except last column, for which exclude _USE==9)
		// - BUT if a subsequent LH column has data in _USE==0, 3, 5 then previous adjustments are cancelled (unless `nolcolcheck')
		// - In this way, build up a recalculated total width (`leftWDtotNoTi').  If this is less than the original total (`leftWDtot'), then there is scope for "adjustment" (see below).

		if "`adjust'" == "" {

			// initialise locals
			local leftWDtotTi = 0
			local leftWDtotNoTi = 0
			// local adjustTot = 0
			// local adjustNew = 0
			
			// May 2018
			// If `nocolscheck', any lengthy text will be in _USE==4 rather than 3 or 5;  and such text should only exist in the first column so may be ignored

			// June 2018: this section re-written
			// Re-calculate widths of `lcols' for study estimates only (i.e. _USE==1, 2; this is `leftWD`i'NoTi')
			local lastcol = 1
			forvalues i=1/`lcolsN' {

				tempvar lindent`i'NoTi					// for right-justifying text (study-name rows only)
				gen `lindent`i'NoTi' = `lindent`i''			
			
				// Check for data in observations *other* than study estimates (i.e. _USE==0, 3, 5)
				// if there is, this becomes `lastcol'
				gen long `strlen' = length(`leftLB`i'')
				summ `strlen' if `touse' & inlist(`_USE', 0, 3, 5), meanonly
				if r(N) & r(max) local lastcol = `i'

				// Now compare "total width" with "width for study estimates only" for current column only
				// (including titles, UNLESS last column of all (`lcolsN'); so that, if multiple columns, adjusted width of first column includes title
				//   and hence, second column doesn't obscure it)
				summ `strlen' if `touse' & (inlist(`_USE', 1, 2) | (`i'<`lcolsN' & `_USE'==9)), meanonly
				if !r(N) local leftWD`i'NoTi = 0		// if summary diamonds only (added Sep 2017 for v2.1)
				else {
					local maxlen = r(max)				// max length of text for study estimates only
					
					getWidth `leftLB`i'' `strwid'
					summ `strwid' if `touse' & (inlist(`_USE', 1, 2) | (`i'<`lcolsN' & `_USE'==9)), meanonly
					local maxwid = r(max)				// max width of text for study estimates only
					
					local fmtlen : word `i' of `lfmtlist'	// desired max no. of characters based on format -- also shows whether left- or right-justified
					local leftWD`i'NoTi = cond(abs(`fmtlen') <= `maxlen', `maxwid', ///		// exact width of `maxlen' string
						abs(`fmtlen')*`digitwid')											// approx. max width (based on `digitwid')
					
					replace `lindent`i'NoTi' = cond(`fmtlen'>0, `leftWD`i'NoTi' - `strwid', 0)	// indent if right-justified
					drop `strwid'
				}
				local leftWD`i'NoTi = `leftWD`i'NoTi' + (2 - (`i'==`lcolsN'))*`digitwid'	// having calculated the indent, add a buffer (2x except for last col)
				
				drop `strlen'
			}
			
			// Finally, iterate `leftWDtotTi' ("unadjusted" widths up to and including `lastcol')
			//  and `leftWDtotNoTi' ("unadjusted" widths up to `lastcol', then "adjusted" widths)
			// Plus, if appropriate, cancel previous *single* adjustments
			//  (the above code only handles the running totals)
			if `"`lcolscheck'"'!=`""' local lastcol = 1
			forvalues i=1/`lcolsN' {
				if `i' < `lastcol' {
					local leftWD`i'NoTi = `leftWD`i''
					replace `lindent`i'NoTi' = `lindent`i''
					local leftWDtotTi = `leftWDtotTi' + `leftWD`i''
				}
				else if `i' == `lastcol' {
					local leftWDtotTi = `leftWDtotTi' + `leftWD`i''
				}
				local leftWDtotNoTi = `leftWDtotNoTi' + `leftWD`i'NoTi'
				
			}
			
			// If appropriate, allow _USE=0,3,4,5 to extend into main plot by a factor of (lcimin-DXmin)/DXwidth
			//  where `lcimin' is the left-most confidence limit among the "diamonds" (including prediction intervals)
			// i.e. 1 + ((`lcimin'-`DXmin')/`DXwidth') * ((100-`astext')/`astext')) is the percentage increase
			// to apply to `leftWDtot'+`rightWDtot' in order to obtain `newleftWDtot'+`rightWDtot'.
			// Then rearrange to find `newleftWDtot'.
			if `leftWDtotNoTi' < `leftWDtot' {
			
				// June 2018:
				// Firstly, reset `leftWDtot'
				local leftWDtot = max(`leftWDtotTi', `leftWDtotNoTi')

				// sort out astext... need to do this now, but will be recalculated later (line 890)
				if `DXwidthChars'!=-9 & `astext'==-9 {
					local astext2 = (`leftWDtot' + `rightWDtot')/`DXwidthChars'
					local astext = 100 * `astext2'/(1 + `astext2')
				}
				else {
					local astext = cond(`astext'==-9, 50, `astext')
					assert `astext' >= 0
					local astext2 = `astext'/(100 - `astext')
				}
				
				// define some additional locals to make final formula clearer
				local totWD = `leftWDtot' + `rightWDtot'
				local lciWD = (`lcimin' - `DXmin')/(`DXmax' - `DXmin')
				local newleftWDtot = cond(`DXwidthChars'==-9, ///
					(`totWD' / ((`lciWD'/`astext2') + 1)) - `rightWDtot', ///
					`leftWDtot' - `lciWD'*`DXwidthChars')
					
				// Finally, reset `leftWDtot' once more
				// BUT don't make it any less than `leftWDtotNoTi', *unless* there are no obs with inlist(`_USE', 1, 2)
				// o/w longest study labels might overwrite longest CIs.
				count if `touse' & inlist(`_USE', 1, 2)
				local leftWDtot = cond(r(N), max(`leftWDtotNoTi', `newleftWDtot'), `newleftWDtot')
				
				// ...and similarly replace individual column widths
				forvalues i=1/`lcolsN' {
					local leftWD`i' = `leftWD`i'NoTi'
					replace `lindent`i'' = `lindent`i'NoTi'
				}
			}
		}		// end if "`adjust'" == ""

		local leftWDtot = `leftWDtot' + `lbuffer'		// LHS buffer; default is zero
		
		// Calculate `textWD', using `astext' (% of graph width taken by text)
		//  to relate the width of plot area in "plot units" to the width of the columns in "text units"
		// [modified sep 2017... for latest beta??]
		if `DXwidthChars'!=-9 & (`astext'==-9 | `"`newleftWDtot'"'!=`""') {
			local astext2 = (`leftWDtot' + `rightWDtot')/`DXwidthChars'
			local astext = 100 * `astext2'/(1 + `astext2')
			// local astext = cond(`DXwidthChars'>0, 100 * `astext2'/(1 + `astext2'), 100)		// added Feb 2018
		}
		else {
			local astext = cond(`astext'==-9, 50, `astext')
			assert `astext' >= 0
			local astext2 = `astext'/(100 - `astext')
		}
		local textWD = `astext2' * (`DXmax' - `DXmin')/(`leftWDtot' + `rightWDtot')

		// Generate positions of columns, in terms of "plot co-ordinates"
		// (N.B. although the "starting positions", `leftWD`i'' and `rightWD`i'', are constants, there will be indents if right-justified
		//      and anyway, all will need to be stored in variables for use with -twoway-)
		local leftWDruntot = 0
		forvalues i = 1/`lcolsN' {
			local left`i' : word `i' of `lvallist'
			gen double `left`i'' = `DXmin' - (`leftWDtot' - `leftWDruntot' - `lindent`i'')*`textWD'
			local leftWDruntot = `leftWDruntot' + `leftWD`i''
		}
		if !`lcolsN' {		// Added July 2015
			local left1 : word 1 of `lvallist'
			gen `left1' = `DXmin' - 2*`digitwid'*`textWD'
		}
		local rightWDruntot = `digitwid'		// initial 1x buffer
		forvalues i = 1/`rcolsN' {				// if `rcolsN'=0 then loop will be skipped
			local right`i' : word `i' of `rvallist'
			gen double `right`i'' = `DXmax' + (`rightWDruntot' + `rindent`i'')*`textWD'
			local rightWDruntot = `rightWDruntot' + `rightWD`i''
		}		
	}		// end quietly

	// AXmin AXmax ARE THE OVERALL LEFT AND RIGHT COORDS
	summ `left1' if `touse', meanonly
	local AXmin = r(min)
	local AXmax = `DXmax' + `rightWDtot'*`textWD'
	
	return scalar leftWDtot = `leftWDtot'
	return scalar rightWDtot = `rightWDtot'
	return scalar AXmin = `AXmin'
	return scalar AXmax = `AXmax'
	return scalar astext = `astext'
	
	return local graphopts `"`graphopts'"'

end


	

* Subroutine to "spread" titles out over multiple lines if appropriate
// Updated July 2014
// August 2016: identical program now used here, in admetan.ado, and in ipdover.ado
// May 2017: updated to accept substrings delineated by quotes (c.f. multi-line axis titles)
// August 2017: updated for better handling of maxlines()
// March 2018: updated to receive text in quotes, hence both avoiding parsing problems with commas, and maintaining spacing
// May 2018 and Nov 2018: updated truncation procedure

// subroutine of ProcessColumns

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




*********************************************************************************

*** FIND OPTIMAL TEXT SIZE AND ASPECT RATIOS (given user input)

// Notes:  (David Fisher, July 2014)
	
// Let X, Y be dimensions of graphregion (controlled by xsize(), ysize()); x, y be dimensions of plotregion (controlled by aspect()).
// `approxChars' is the approximate width of the plot, in "character units" (i.e. width of [LHS text + RHS text] divided by `astext')
	
// Note that a "character unit" is the width of a character relative to its height; 
//  hence `height' is the approximate height of the plot, in terms of both rows of text (with zero gap between rows) AND "character units".
	
// If Y/X = `graphAspect'<1, `textSize' is the height of a row of text relative to Y; otherwise it is height relative to X.
// (Note that the default `graphAspect' = 4/5.5 = 0.73 < 1)
// We then let `approxChars' = x, and manipulate to find the optimum text size for the plot layout.

// FEB 2015: `textscale' is deprecated, since it causes problems with spilling on the RHS.
// Instead, using `spacing' to fine-tune the aspect ratio (and hence the text size)
//   or use `aspect' to completely user-define the aspect ratio.
	
//  - Note that this code has been changed considerably from the original -metan- code.

// Moved into separate subroutine Nov 2017 for v2.2 beta
// GetAspectRatio, astext(`astext') colwdtot(`colWDtot') height(`height') rowsxlab(`rowsxlab') `graphopts' `usedimsopt'
// Jan 2018: double check that NOT returning graphopts doesn't cause any problems

program define GetAspectRatio, rclass

	syntax [, ASTEXT(real 50) COLWDTOT(real 0) HEIGHT(real 0) USEDIMS(name) ///
		ASPECT(real -9) SPacing(real -9) XSIZe(real -9) YSIZe(real -9) FXSIZe(real -9) FYSIZe(real -9) ///
		TItle(string asis) SUBtitle(string asis) CAPTION(string asis) NOTE2(string asis) noNOTE noWARNing ///
		XTItle(string asis) FAVours(string asis) ADDHeight(real 0) /*(undocumented)*/ ///
		ROWSXLAB(real 0) DXWIDTHChars(real -9) COLSONLY * ]
	
	local graphopts `"`options'"'
	
	* Unpack `usedims'
	local DXwidthChars : copy local dxwidthchars		// added Feb 2018: clarity
	// local DXwidthChars = -9		// initialize
	local oldTextSize = -9			// initialize
	if `"`usedims'"'!=`""' {
		// local DXwidthChars = `usedims'[1, `=colnumb(`usedims', "cdw")']
		local spacing = cond(`spacing'==-9, `usedims'[1, `=colnumb(`usedims', "spacing")'], `spacing')
		// local oldPlotAspect = cond(`aspect'==-9, `usedims'[1, `=colnumb(`usedims', "aspect")'], `aspect')
		// local xsize = cond(`xsize'==-9, `usedims'[1, `=colnumb(`usedims', "xsize")'], `xsize')
		// local ysize = cond(`ysize'==-9, `usedims'[1, `=colnumb(`usedims', "ysize")'], `ysize')
		local oldPlotAspect = `usedims'[1, `=colnumb(`usedims', "aspect")']		// modified 2nd Nov 2017 for v2.2 beta
		local oldXSize = `usedims'[1, `=colnumb(`usedims', "xsize")']
		local oldYSize = `usedims'[1, `=colnumb(`usedims', "ysize")']
		local oldTextSize = `usedims'[1, `=colnumb(`usedims', "textsize")']
		local oldHeight = `usedims'[1, `=colnumb(`usedims', "height")']			// added 18th Sep 2017 for v2.2 beta
		local oldYheight = `usedims'[1, `=colnumb(`usedims', "yheight")']		// added 18th Sep 2017 for v2.2 beta
		
		numlist "`DXwidthChars' `spacing' `oldPlotAspect' `oldXSize' `oldYSize' `oldTextSize' `oldHeight' `oldYheight'", min(8) max(8) range(>=0)
	}


	* Obtain number of rows within each title element
	// (see help title_options)
	// [modified Nov 2017 for v2.2 beta]
	// (N.B. favours will be done separately)
	// [modified Feb 2018]
	// [Jan 2019: converted to subroutine for better parsing of compound quotes]
	foreach opt in title subtitle caption note xtitle {
		GetRows ``opt''
		local rows`opt' = r(rows)
	}
	

	* Do the same for `favours'
	// (N.B. syntax is more complicated so need to do separately)
	local rowsfav = 0
	if `"`favours'"' != `""' {
		local 0 `"`favours'"'
		syntax [anything(everything)] [, * ]
		
		* Parse text, and count how many rows of text there are (i.e. separated with pairs of quotes)
		local rowsleftfav = 0
		local rowsrightfav = 0
		gettoken leftfav rest : anything, parse("#") quotes
		if `"`leftfav'"'!=`"#"' {
			while `"`rest'"'!=`""' {
				local ++rowsleftfav
				gettoken next rest : rest, parse("#") quotes
				if `"`next'"'==`"#"' continue, break
				local leftfav `"`leftfav' `next'"'
			}
		}
		else local leftfav `""'
		local rightfav = trim(`"`rest'"')
		if `"`rightfav'"'!=`""' {
			while `"`rest'"'!=`""' {
				local ++rowsrightfav
				gettoken next rest : rest, quotes
			}
		}
		local rowsfav = max(1, `rowsleftfav', `rowsrightfav')
		
		return local leftfav  `"`leftfav'"'
		return local rightfav `"`rightfav'"'
		return local favopt   `"`options'"'
	}	
	return scalar rowsfav = `rowsfav'

	local condtitle = 2*`rowstitle' + 1.5*`rowssubtitle' + 1.25*`rowscaption' + 1.25*`rowsnote'	// approximate multipliers for different text sizes + gaps
	local condtitle = `condtitle' + (`"`title'"'!=`""' & `"`subtitle'"'!=`""')					// additional gap between title and subtitle, if *both* specified
	local condtitle = `condtitle' + 2 + `addheight'												// add 2 for graphregion(margin())

	// Now derive small amounts `xdelta', `ydelta', to take account of the space taken up by titles etc.
	// Assume that, if plot is "full-width", then X = x * xdelta
	//  and that, if plot is "full-height", then Y = y * ydelta	
	// local ydelta = (`height' + `condtitle' + (`"`xlablist'"'!=`""') + `rowsfav' + `rowsxtitle')/`height'
	local ydelta = (`height' + `condtitle' + `rowsxlab' + `rowsfav' + `rowsxtitle')/`height'			// Nov 2017
	local xdelta = (`height' + `condtitle')/`height'		// Oct 2016: check logic of this, why difference in what is added??
	// Notes Feb 2015:
	// - could maybe be improved, but for now `addheight' option (undocumented) allows user to tweak
	// - also think about line widths (thicknesses), can we keep them constant-ish??
	// May 2016: yes, should be quite easy -- choose a reasonable value based on the height, then amend it in the same way as textsize	

	
	* Derive `approxChars', `spacing' and `plotAspect'
	// (possibly using saved "dimensions")
	// (for future: investigate using margins to "centre on DXwidth" within graphregion??)
	if `"`usedims'"'==`""' {
		local approxChars = 100*`colwdtot'/`astext'
		
		if `aspect' != -9 {					// user-specified aspect of plotregion
			local spacing = cond(`spacing' == -9, `aspect' * `approxChars' / `height', `spacing')	// [modified 2nd Nov 2017 for v2.2]
			local plotAspect = `aspect'
		}
		else {								// if not user-specified
			local spacing = cond(`spacing' == -9, cond(`height'/`approxChars' <= .5, 2, 1.5), `spacing')
			// if "natural aspect" (`height'/`approxChars') is 2x1 or wider, use double spacing; else use 1.5-spacing
			// (unless user-specified, in which case use that)
			local plotAspect = `spacing' * `height' / `approxChars'
		}
	}
	else {	// if `usedims' supplied
		local approxChars = `colwdtot' + cond(`"`colsonly'"'!=`""' /*& (`lcolsN'*`rcolsN'==0)*/, 0, `DXwidthChars')		// modified Feb 2018
		local plotAspect = cond(`aspect'==-9, `spacing'*`height'/`approxChars', `aspect')
		// `spacing' here is from `usedims' unless over-ridden by user
	}
	numlist "`plotAspect' `spacing'", range(>=0)
		
	
	* Derive graphAspect = Y/X (defaults to 4/5.5  = 0.727 unless specified)
	// [modified 2nd Nov 2017 for v2.2 beta]
	if `"`usedims'"'==`""' {
		local oldYSize = 4
		local oldXSize = 5.5
	}
	local graphAspect = cond(`ysize'==-9, `oldYSize', `ysize') ///
		/ cond(`xsize'==-9, `oldXSize', `xsize')
	
	// July 2015
	* Standard approach is now to use `graphAspect' and `plotAspect' to determine `textSize'.
	if `"`usedims'"'==`""' {
		
		// (1) If y/x < Y/X < 1 (i.e. plot takes up full width of "wide" graph) then X = x * xdelta
		//     ==> `textSize' = 100/Y = 100/(X * `graphAspect') = 100/(`xdelta' * `approxChars' * `graphAspect')
		if `graphAspect' <= 1 & `plotAspect' <= `graphAspect' {
			local textSize = 100 / (`xdelta' * `approxChars' * `graphAspect')
		}
		
		// (2) If Y/X < 1 and y/x > Y/X (i.e. plot is less wide than "wide" graph) then Y = y * ydelta
		//     ==> `textSize' = 100/Y = 100/(ydelta * x * `plotAspect') = 100 / (`ydelta' * `approxChars' * `plotAspect')
		else if `graphAspect' <= 1 & `plotAspect' > `graphAspect' {
			local textSize = 100 / (`ydelta' * `approxChars' * `plotAspect')
		}
			
		// (3) If y/x > Y/X > 1 (i.e. plot takes up full height of "tall" graph) then Y = y * ydelta
		//     ==> `textSize' = 100/X = 100 * `graphAspect'/(y * ydelta) = 100 * `graphAspect' / (`ydelta' * `approxChars' * `plotAspect')
		else if `graphAspect' > 1 & `plotAspect' > `graphAspect' {
			local textSize = (100 * `graphAspect') / (`ydelta' * `approxChars' * `plotAspect')
		}
			
		// (4) If Y/X > 1 and y/x < Y/X (i.e. plot is less tall than "tall" graph) then X = x * xdelta
		//     ==> `textSize' = 100/X = 100 / (`xdelta' * `approxChars')
		else if `graphAspect' > 1 & `plotAspect' <= `graphAspect' {
			local textSize = 100 / (`xdelta' * `approxChars')
		}
		
		// [added 1st Nov 2017 for v2.2 beta]
		// If Y/X = `graphAspect' <= 1 ("wide"), set fysize to 100; else ("tall") set fxsize to 100
		// in other words, min dimension is always 100; the other is >100
		local fxsize = cond(`fxsize' == -9, cond(`graphAspect' <= 1, 100/`graphAspect', 100), `fxsize')
		local fysize = cond(`fysize' == -9, cond(`graphAspect' <= 1, 100, 100*`graphAspect'), `fysize')
		// local fxsize = cond(`fxsize' == -9, 100, `fxsize')
		// local fysize = cond(`fysize' == -9, 100, `fysize')
		// local fsizeopt `"fxsize(`fxsize') fysize(`fysize')"'
		// return scalar fxsize = `fxsize'
		// return scalar fysize = `fysize'
	}

	* Else if `usedims' supplied:
	* oldGraphAspect and oldPlotAspect would have been derived using the rules above
	* we immediately know the new plotAspect = `spacing'*`height'/`approxChars' (using new `approxChars')
	* (assuming the height is the same -- come back to this point maybe)
	* So:
	// (1) old y/x < Y/X < 1 ==> plot takes up full width
	// (a) if newplotAspect is wider still (new y/x < old y/x) then it will have to "shrink" (i.e. lose height)
	//     ==> widen newgraphAspect by the same amount?? (minus delta, because that will be constant)
	//     But, since in all cases Y is less than X, `textSize' is based on Y, so should still be correct.
	// (b) if newplotAspect is less wide (new y/x > old y/x) it will fit fine, so again `textSize' will be fine.
		
	// (2) old Y/X < 1, old y/x > Y/X (i.e. old plot is less wide than "wide" graph)
	// (a) if newplotAspect is wider, then everything is fine UNLESS new y/x ends up <Y/X.
	//     However, we're then in case (1)(a) so once newgraphAspect is widened, `textSize' should be fine.
	// (b) if newplotAspect is less wide, it will fit fine, so again `textSize' will be fine.
		
	// (3) If y/x > Y/X > 1 (i.e. plot takes up full height of "tall" graph)
	// (a) if newplotAspect is wider, then everything is fine UNLESS new y/x ends up <Y/X.
	//     ==> need to widen newgraphAspect (minus delta, because that will be constant)
	//     Then if newgraphAspect is still > 1, we're in case (1)(a) again
	//     BUT if newgraphAspect is now < 1, then we'll need to amend `textSize'.
	// (b) if newplotAspect is less wide, it will fit fine, so again `textSize' will be fine.
		
	// (4) If Y/X > 1 and y/x < Y/X (i.e. plot is less tall than "tall" graph) 
	// (a) if newplotAspect is wider, newgraphAspect will ALWAYS need to be widened to avoid "shrinkage"
	//     Then if newgraphAspect is still > 1, we're in case (1)(a) again
	//     BUT if newgraphAspect is now < 1, then we'll need to amend `textSize'.
	// (b) if newplotAspect is less wide, it will have to "expand" (i.e. gain height)	
	//     ==> *reduce* width of newgraphAspect	by the same amount
	//     But, since in all cases X is less than Y, `textSize' is based on X, so should still be correct.
		
	* So, scenarios in which to take action are:
	// (1)(a): increase width of newgraphAspect;
	//         no change to `textSize'
	// (2)(a): check new y/x: if y/x < Y/X then increase width of newgraphAspect;
	//         no change to `textSize'
	// (3)(a): check new y/x: if y/x < Y/X then increase width of newgraphAspect;
	//         then check new Y/X: if <1 then need to amend `textSize'
	// (4)(a): increase width of newgraphAspect;
	//         check new Y/X: if <1 then need to amend `textSize'
	// (4)(b): reduce width of newgraphAspect;
	//         no change to `textSize'		
	
	else {
		local textSize = `oldTextSize'				// tidy this up
			
		// 1a & 2a
		if `graphAspect' <= 1 & `plotAspect' <= `graphAspect' {
		
			if `xsize'==-9 | `ysize'==-9 {
				local graphAspect = `graphAspect' * `plotAspect' / `oldPlotAspect'

				// [modified 2nd Nov 2017 for v2.2 beta]
				if `xsize'==-9 & `ysize'==-9 local xsize = `oldYSize' / `graphAspect'
				else {
					if `xsize'==-9 local xsize = `ysize' / `graphAspect'
					else           local ysize = `xsize' * `graphAspect'
				}
				// local xsize = `ysize' / `graphAspect'
			}
		}
			
		// 3a, 4a, 4b
		else if `graphAspect' > 1 & ///
			((`oldPlotAspect' > `graphAspect' & `plotAspect' <= `graphAspect') ///
			| (`oldPlotAspect' <= `graphAspect')) {

			if `xsize'==-9 | `ysize'==-9 {
				local oldGraphAspect = `graphAspect'
				local graphAspect = `oldGraphAspect' * `plotAspect' / `oldPlotAspect'

				// [modified 2nd Nov 2017 for v2.2 beta]
				if `xsize'==-9 & `ysize'==-9 local xsize = `oldYSize' / `graphAspect'
				else {
					if `xsize'==-9 local xsize = `ysize' / `graphAspect'
					else           local ysize = `xsize' * `graphAspect'
				}
				// local xsize = `ysize' / `graphAspect'

				// 3a, 4a
				if `graphAspect' <= 1 {
					local textSize = `textSize' / `oldGraphAspect'
				}
			}
		}
		
		// [added 1st Nov 2017 for v2.2 beta]
		// local fxsize = cond(`fxsize'==-9, 100*(`oldPlotAspect'/`plotAspect')*(`height'/`oldHeight'), `fxsize')
		// local fysize = cond(`fysize'==-9, 100*`ydelta'*`height'/`oldYheight', `fysize')
		
		// Revised Feb 2018
		local fxsize = cond(`fxsize'==-9, 100*(`oldPlotAspect'/`plotAspect')*(`height'/`oldHeight')*(`oldXSize'/`oldYSize'), `fxsize')
		local fysize = cond(`fysize'==-9, 100*`ydelta'*`height'/`oldYheight', `fysize')
		
		// local fsizeopt `"fxsize(`fxsize') fysize(`fysize')"'
		// return scalar fxsize = `fxsize'
		// return scalar fysize = `fysize'
	}
	
	* Notes: for random-effects analyses, sample-size weights, or user-defined (will overwrite the first two)
	if `"`note2'"'!=`""' {
		local 0 `"`note2'"'
		syntax [anything(name=notetxt everything)] [, SIze(string) * ]
		if "`size'"=="" local size = `textSize'*.75			// use 75% of text size used for rest of plot
		if "`colsonly'"!="" local notetxt `"`" "'"'			// added Feb 2018
		
		// May 2018: Having parsed the note, now suppress it if noWARNing or noNOTE
		if `"`warning'`note'"'==`""' local noteopt `"note(`notetxt', size(`size') `options')"'
	}
	
	// collect options relevant to GetAspectRatio which also need ultimately to be passed to -twoway-
	// N.B. *not* favours; instead returned as `leftfav' and 'rightfav'
	// [Feb 2018] Also *not* xtitle, as already parsed at beginning of code
	foreach opt in /*xtitle*/ title subtitle caption {
		if trim(`"``opt''"')!=`""' {
			local graphopts `"`graphopts' `opt'(``opt'')"'
		}
	}
	return local graphopts `"`graphopts' `noteopt'"'


	* Return scalars
	return scalar xsize = cond(`xsize'==-9, 5.5, `xsize')		// [added 2nd Nov for v2.2 beta]
	return scalar ysize = cond(`ysize'==-9, 4, `ysize')			// [added 2nd Nov for v2.2 beta]
	return scalar fxsize = `fxsize'
	return scalar fysize = `fysize'
	return scalar yheight = `ydelta'*`height'
	return scalar textsize = `textSize'
	return scalar spacing = `spacing'
	return scalar approxchars = `approxChars'
	return scalar graphaspect = `graphAspect'
	return scalar plotaspect = `plotAspect'
		
end
		

* GetRows: subroutine of GetAspectRatio
// added Jan 2019
program define GetRows, rclass
	syntax [anything(id="text string")] [, *]
	local rows = 0
	if `"`anything'"'!=`""' {
		// March 2018
		// word count has trouble with apostrophes (but not double-quotes)
		// so replace them with "a" for the purposes of word-counting
		/*
		local rest : subinstr local anything `"'"' `"a"', all
		gettoken foo bar : rest, qed(q) quotes
		local rows = cond(`q', `: word count `rest'', 1)
		*/

		// Jan 2019: if title() etc. finds "" or `""' at the start, the title is set to nothing
		if substr(trim(`"`anything'"'), 1, 2)==`""""' | substr(trim(`"`anything'"'), 1, 4)==`"`""'"' {
			return scalar rows = 0
			exit
		}
		
		// Jan 2019: else, remove quotes using gettoken
		gettoken foo bar : anything, qed(q) quotes
		local rows = cond(`q', `: word count `anything'', 1)
	}
	return scalar rows = `rows'
end
		
		

*********************************************************************************

** Program to build plot commands for the different elements
// from plotopts and plot`p'opts

// August 2018: removed "sortpreserve" (since we are adding new obs).
// Instead, repect sort order (of `touse' `id') "manually".
// (N.B. no further sorting takes place in main routine hereafter.)

program define BuildPlotCmds, sclass

	syntax varlist(numeric min=4 max=4 default=none), TOUSE(varname numeric) ID(varname numeric) ///
		CXLIST(numlist min=2 max=2) ///
		[PLOTID(varname numeric) DATAID(varname numeric) ND(real 0) NP(real 0) ///
		CLASSIC noDIAmonds INTERaction COLSONLY CUMULATIVE H0(real 0) noNULL ///
		WGT(varname numeric) NEWwt RFDIST(varlist numeric) BOXscale(real 100.0) noBOX ///
		DIAMLIST(namelist) OVLIST(namelist) OFFSCLIST(namelist) RFOFFSCLIST(namelist) TOUSED(name) * ]

	tokenize `varlist'
	args _USE _ES _LCI _UCI
	
	tokenize `cxlist'
	args CXmin CXmax
	
	local _WT `wgt'
	local awweight `"[aw= `_WT']"'		// moved here 30th Jan 2018
	
	if "`box'"!="" local oldbox nobox		// allow "global" option `nobox' for compatibility with -metan-
											// N.B. can't be used with plotid; instead box`p'opts(msymbol(none)) can be used

	** "Global" options (includes null line)
	local 0 `", `options'"'
	syntax [, ///
		/// /* standard options */
		BOXOPts(string asis) DIAMOPts(string asis) POINTOPts(string asis) CIOPts(string asis) OLINEOPts(string asis) NLINEOPts(string asis) ///
		/// /* non-diamond and prediction interval options */
		PPOINTOPts(string asis) PCIOPts(string asis) RFOPts(string asis) * ]

	local rest `"`options'"'

	
	** Some initial setup (not needed if `colsonly')
	
	if `"`colsonly'"'==`""' {

		
		** "OVERALL EFFECT" LINES
		tokenize `ovlist'
		args ovLine ovMin ovMax
		
		tempvar useno
		qui gen byte `useno' = `_USE' * inlist(`_USE', 3, 5) if `touse'

		cap confirm var `dataid'
		if _rc {
			tempvar dataid
			qui gen byte `dataid'=1 if `touse'
		}
		sort `touse' `dataid' `id'
		qui replace `useno' = `useno'[_n-1] if `useno'<=`useno'[_n-1] & `dataid'==`dataid'[_n-1]	// find the largest value (from 3 & 5) "so far"

		// flag obs through which the line should be drawn
		qui gen `ovLine'=.
		summ `useno' if `touse', meanonly
		if r(N) & r(max) {
			tempvar olinegroup check /*ovMin ovMax*/
			qui gen int `olinegroup' = (`_USE'==`useno') * (`useno'>0)
			qui bysort `touse' `dataid' (`id') : replace `olinegroup' = sum(`olinegroup') if inlist(`_USE', 1, 2, 3, 5)		// study obs & pooled results

			* Store min and max values for later plotting
			qui gen byte `check' = inlist(`_USE', 1, 2)
			qui bysort `touse' `dataid' `olinegroup' (`check') : replace `check' = `check'[_N]	// only draw oline if there are study obs in the same olinegroup
			qui replace `ovLine' = `_ES' if `touse' & `check' & `_USE'==`useno' & `useno'>0 & !(`_ES' > `CXmax' | `_ES' < `CXmin')

			sort `touse' `dataid' `olinegroup' `id'
			qui by `touse' `dataid' `olinegroup' : gen float `ovMin' = `id'[1]  - 0.5 if `touse' & `_USE'==`useno' & `useno'>0 & !missing(`ovLine')
			qui by `touse' `dataid' `olinegroup' : gen float `ovMax' = `id'[_N] + 0.5 if `touse' & `_USE'==`useno' & `useno'>0 & !missing(`ovLine')
			// drop `useno' `olinegroup' `check'
		}

		// Bit ugly, but this needs to be done (a) after "overall effect" line setup; but (b) before any actual *drawing* is done:
		if `"`cumulative'"'!=`""' qui replace `_USE' = 1 if `_USE' == 3

			
		** IF MULTIPLE PLOTIDs, or if dataid(varname, newwt) specified,
		// create dummy obs with global min & max weights, to maintain correct weighting throughout
		if (`np' > 1 | `"`newwt'"'!=`""') {		// Amended June 2015

			// create new `touse', including new dummy obs
			qui gen byte `toused' = `touse'
			
			// find global min & max weights, to maintain consistency across subgroups
			if `"`newwt'"'==`""' {		// weight consistent across dataid, so just use locals
				summ `_WT' if `touse' & inlist(`_USE', 1, 2), meanonly	
				local minwt = r(min)
				local maxwt = r(max)
			}
			else {						// multiple min/max weights required, so use tempvars
				tempvar minwt maxwt
				sort `touse' `dataid' `_WT'
				qui by `touse' `dataid' : gen double `minwt' = `_WT'[1] if `touse'
				qui by `touse' `dataid' : gen double `maxwt' = `_WT'[_N] if `touse'
			}
			local oldN = _N
			local newN = `oldN' + 2*`nd'*`np'	// N.B. `nd' indexes `dataid'; `np' indexes `plotid'
			qui set obs `newN'
			forvalues i=1/`nd' {
				forvalues j=1/`np' {
					local k = `oldN' + (`i'-1)*2*`np' + 2*`j'
					qui replace `plotid' = `j' in `=`k'-1' / `k'
					qui replace `_WT' = `minwt' in `=`k'-1'
					qui replace `_WT' = `maxwt' in `k'
				}
			}
			qui replace `_USE'   = 1 in `=`oldN' + 1' / `newN'
			qui replace `touse'  = 0 in `=`oldN' + 1' / `newN'
			qui replace `toused' = 1 in `=`oldN' + 1' / `newN'
		}
		// these dummy obs are identifiable by "`_USE'==1 & `toused' & !`touse'"

		else {
			qui count if `touse' & inlist(`_USE', 3, 5)
			if r(N) qui gen byte `toused' = `touse'
			else local toused `touse'		// if neither multiple plotids NOR diamonds, no need for separate variable `toused'
		}

		
		* SETUP OFF-SCALE ARROWS -- fairly straightforward
		// (include use==3, 5 in case of pciopts/rfopts)
		tokenize `offsclist'
		args offscaleL offscaleR
		qui gen byte `offscaleL' = `touse' * inlist(`_USE', 1, 3, 5) * (float(`_LCI') < float(`CXmin'))
		qui gen byte `offscaleR' = `touse' * inlist(`_USE', 1, 3, 5) * (float(`_UCI') > float(`CXmax') & !missing(`_UCI'))

		// rfdist: only applies to use==3, 5
		// BUT may need up to four tempvars in niche cases (e.g. only part of the rfCI is visible)
		// ==> to save on tempvars, only use them if more than one; o/w use local macros
		if `"`rfdist'"'!=`""' {
			tokenize `rfdist'
			args _rfLCI _rfUCI
		
			tokenize `rfoffsclist'
			args tv1 tv2 tv3 tv4		// don't name them yet, as they may not all be needed

			local touse3 `"`touse' & inlist(`_USE', 3, 5)"'
			qui count if `touse3'
			if r(N) > 1 {
				gen byte `tv1' = `touse3' * (float(`_rfLCI') < float(`CXmin'))
				gen byte `tv2' = `touse3' * (float(`_rfUCI') > float(`CXmax') & !missing(`_rfUCI'))
				local rfLoffscaleL `tv1'
				local rfRoffscaleR `tv2'
				
				qui count if `touse3' & float(`_UCI') < float(`CXmin')
				if r(N) {
					gen byte `tv3' = `touse3' * (float(`_UCI') < float(`CXmin'))
					local rfRoffscaleL `tv3'
				}
				else local rfRoffscaleL `"(`touse3' & float(`_LCI') > float(`CXmax') & !missing(`_LCI'))"'
				
				qui count if `touse3' & float(`_LCI') > float(`CXmax') & !missing(`_LCI')
				if r(N) {
					gen byte `tv4' = `touse3' * (float(`_LCI') > float(`CXmax') & !missing(`_LCI'))
					local rfLoffscaleR `tv4'
				}
				else local rfLoffscaleR `"(`touse3' & float(`_UCI') < float(`CXmin'))"'
			}
			else if r(N) {
				local rfLoffscaleL `"(`touse3' & float(`_rfLCI') < float(`CXmin'))"'
				local rfRoffscaleR `"(`touse3' & float(`_rfUCI') > float(`CXmax') & !missing(`_rfUCI'))"'
				local rfRoffscaleL `"(`touse3' & float(`_LCI') > float(`CXmax') & !missing(`_LCI'))"'
				local rfLoffscaleR `"(`touse3' & float(`_UCI') < float(`CXmin'))"'
			}
		}

		
		// August 2018
		// DRAW DIAMONDS AS POLYGONS USING -twoway rarea-
		// SO THAT THEY MAY BE FILLED IN (also requires fewer variables)

		// David Fisher, August 2016:
		// Check in advance for whether "diamonds" are to be used; if not, don't need to generate their coordinates
		if trim(`"`diamonds'`interaction'`pciopts'`ppointopts'"') == `""' {
			local diamchk = 0
			forvalues p = 1/`np' {
				local 0 `", `rest'"'
				syntax [, PPOINT`p'opts(string asis) PCI`p'opts(string asis) * ]
				local diamchk = max(`diamchk', trim(`"`ppoint`p'opts'`pci`p'opts'"') == `""')
			}
		}
		else local diamchk = 1
		
		if `diamchk' {
			tokenize `diamlist'
			args DiamX DiamY1 DiamY2

			tempvar touseDiam
			qui {
				local touse2 `"`toused' * inlist(`_USE', 3, 5)"'
				expand 4 if `touse2'
				bysort `touse' `id' : replace `toused' = `toused' * _n
				
				// x-coords
				gen float `DiamX' = cond(`offscaleL', `CXmin', `_LCI') if `toused'==1 & float(`_ES') >= float(`CXmin')
				replace   `DiamX' = `_ES' if `toused'==2
				replace   `DiamX' = `CXmin' if `toused'==2 & float(`_ES') < `CXmin'
				replace   `DiamX' = `CXmax' if `toused'==2 & float(`_ES') > `CXmax'
				replace   `DiamX' = . if `toused'==2 & (float(`_UCI') < `CXmin' | float(`_LCI') > `CXmax')
				replace   `DiamX' = cond(`offscaleR', `CXmax', `_UCI') if `toused'==3 & float(`_ES') <= float(`CXmax')
				replace   `DiamX' = . if `toused'==4
				
				// upper y-coords
				gen float `DiamY1' = cond(`offscaleL', `id' + 0.4*( abs((`CXmin'-`_LCI')/(`_ES'-`_LCI')) ), `id') if `toused'==1 & float(`_ES') >= float(`CXmin')
				replace   `DiamY1' = `id' + 0.4 if `toused'==2
				replace   `DiamY1' = `id' + 0.4*( abs((`_UCI'-`CXmin')/(`_UCI'-`_ES')) ) if `toused'==2 & float(`_ES') < float(`CXmin')
				replace   `DiamY1' = `id' + 0.4*( abs((`CXmax'-`_LCI')/(`_ES'-`_LCI')) ) if `toused'==2 & float(`_ES') > float(`CXmax')
				replace   `DiamY1' = cond(`offscaleR', `id' + 0.4*( abs((`_UCI'-`CXmax')/(`_UCI'-`_ES')) ), `id') if `toused'==3 & float(`_ES') <= float(`CXmax')
				replace   `DiamY1' = . if `toused'==4
				
				// lower y-coords
				gen float `DiamY2' = cond(`offscaleL', `id' - 0.4*( abs((`CXmin'-`_LCI')/(`_ES'-`_LCI')) ), `id') if `toused'==1 & float(`_ES') >= float(`CXmin')
				replace   `DiamY2' = `id' - 0.4 if `toused'==2
				replace   `DiamY2' = `id' - 0.4*( abs((`_UCI'-`CXmin')/(`_UCI'-`_ES')) ) if `toused'==2 & float(`_ES') < float(`CXmin')
				replace   `DiamY2' = `id' - 0.4*( abs((`CXmax'-`_LCI')/(`_ES'-`_LCI')) ) if `toused'==2 & float(`_ES') > float(`CXmax')
				replace   `DiamY2' = cond(`offscaleR', `id' - 0.4*( abs((`_UCI'-`CXmax')/(`_UCI'-`_ES')) ), `id') if `toused'==3 & float(`_ES') <= float(`CXmax')
				replace   `DiamY2' = . if `toused'==4
				
				replace `touse'  = 0 if `toused' > 1
				replace `toused' = 1 if `toused' > 1
				// these dummy obs are identifiable by "inlist(`_USE', 3, 5) & `toused'>1 & !`touse'"
			}
		}
		
		* Now truncate CIs at CXmin/CXmax
		qui {
			local touse2 `"`touse' * inlist(`_USE', 1, 3, 5)"'

			replace `_LCI' = `CXmin' if `offscaleL'
			replace `_UCI' = `CXmax' if `offscaleR'
			replace `_LCI' = . if `touse2' & float(`_UCI') < float(`CXmin')
			replace `_UCI' = . if `touse2' & float(`_LCI') > float(`CXmax')
			replace `_ES'  = . if `touse2' & float(`_ES')  < float(`CXmin')
			replace `_ES'  = . if `touse2' & float(`_ES')  > float(`CXmax')

			if `"`rfdist'"'!=`""' {
				
				// Standard case:
				tempvar rflci2
				clonevar `rflci2' = `_rfLCI'
				replace `_rfLCI' = . if `touse2' & (`offscaleL' | float(`_rfLCI') < float(`CXmin'))
				replace `_rfUCI' = . if `touse2' & (`offscaleR' | (float(`rflci2') > float(`CXmax') & !missing(`rflci2')))
				drop `rflci2'
				
				replace `_rfLCI' = `CXmin' if `rfLoffscaleL'
				replace `_rfUCI' = `CXmax' if `rfRoffscaleR'
			
				// Niche case:
				// If one end of both CI and rfCI are offscale in same direction,
				// and the other end of the CI is *also* outside the CXmin/CXmax limits (albeit not marked as offscale)
				// (i.e. the only visible piece will be *part of one end* of the rfCI)
				// then that piece of the rfCI needs an arrow pointing *towards* _ES.
				// (This will need checking for again when it comes to constructing the rfplot)
				cap confirm numeric var `rfRoffscaleL'
				if !_rc {
					replace `_rfLCI' = `CXmin' if `touse2' & `rfRoffscaleL'
					replace `_UCI'   = `CXmin' if `touse2' & `rfRoffscaleL'
				}
				else local rfRoffscaleL = 0
				
				cap confirm numeric var `rfLoffscaleR'
				if !_rc {
					replace `_rfUCI' = `CXmax' if `touse2' & `rfLoffscaleR'
					replace `_LCI'   = `CXmax' if `touse2' & `rfLoffscaleR'
				}
				else local rfLoffscaleR = 0
			}
		}
	}			// end if `"`colsonly'"'==`""'
	
	
	** DEFAULTS
	
	* Default options for simple graph elements
	cap assert `boxscale' >=0
	if _rc == 9 {
		disp as err `"value of {bf:boxscale()} must be >= 0"'
		exit 125
	}
	else if _rc {
		disp as err `"error in {bf:boxscale()} option"'
		exit _rc
	}
	local boxSize = `boxscale'/150	
	
	local defShape = cond("`interaction'"!="", "circle", "square")
	local defColor = cond("`classic'"!="", "black", "180 180 180")
	local defBoxOpts = `"mcolor("`defColor'") msymbol(`defShape') msize(`boxSize')"'
	if `"`oldbox'"'!=`""' local defBoxOpts `"msymbol(none)"'	// -metan- "nobox" option
	local defCIOpts `"lcolor(black) mcolor(black)"'				// includes "mcolor" for arrows (doesn't affect rspike/rcap)
	local defPointOpts `"msymbol(diamond) mcolor(black) msize(vsmall)"'
	local defOlineOpts `"lwidth(thin) lcolor(maroon) lpattern(shortdash)"'
	local defNlineOpts `"lwidth(thin) lcolor(black)"'
	
	// ...and for "pooled" estimates
	local defShape = cond("`interaction'"!="", "circle", "diamond")
	local defColor "0 0 100"
	// local defDiamOpts `"lcolor("`defColor'") lalign(center) fcolor("none")"'
	local defDiamOpts `"lcolor("`defColor'") fcolor("none")"'
	if c(stata_version)>=15 local defDiamOpts `"`defDiamOpts' lalign(center)"'			// v3.0.1: lalign() only valid for Stata 15+
	local defPPointOpts `"msymbol("`defShape'") mlcolor("`defColor'") mfcolor("none")"'	// "pooled" point options (alternative to diamond)
	local defPCIOpts `"lcolor("`defColor'") mcolor("`defColor'")"'						// "pooled" CI options (alternative to diamond)
	local defRFOpts `"`defPCIOpts'"'													// prediction interval options (includes "mcolor" for arrows)

	
	* Default options for graph elements that may be plotted in more than one way
	// (plus, may as well parse some other options too, including disallowed ones)
	
	* Confidence intervals
	// since capped lines require a different -twoway- command (-rcap- vs -rspike-)
	if `"`rfdist'"'==`""' & `"`rfopts'"'!=`""' {
		nois disp as err `"prediction interval not specified; relevant options will be ignored"'
		local rfopts
	}

	// Same routine applies to study CIs, "pooled" CIs (alternative to diamond), and to prediction intervals:
	foreach plot in ci pci rf {
		local 0 `", ``plot'opts'"'
		syntax [, LColor(string) MColor(string) LWidth(string) MLWidth(string) ///
			RCAP OVerlay HORizontal VERTical * ]
		
		// disallowed options
		if `"`horizontal'"'!=`""' | `"`vertical'"'!=`""' {
			nois disp as err `"suboptions {bf:horizontal} and {bf:vertical} not allowed in option {bf:`plot'opts()}"'
			exit 198
		}			
		if `"`overlay'"'!=`""' & "`plot'"!="rf" {
			nois disp as err `"suboption {bf:overlay} not allowed in option {bf:`plot'opts()}"'
			exit 198
		}

		// rebuild the option list
		if `"`lcolor'"'!=`""' & `"`mcolor'"'==`""'  local mcolor  `lcolor'		// for pc(b)arrow
		if `"`lwidth'"'!=`""' & `"`mlwidth'"'==`""' local mlwidth `lwidth'		// for pc(b)arrow
		local `plot'opts
		foreach opt in mcolor lcolor mlwidth lwidth {
			if `"``opt''"'!=`""' {
				local `plot'opts `"``plot'opts' `opt'(``opt'')"'
			}
		}
		local `plot'opts `"``plot'opts' `options'"'
		local g_overlay "`overlay'"		// "global" overlay option
		
		local uplot = upper("`plot'")
		local `uplot'PlotType = cond("`rcap'"=="", "rspike", "rcap")
	}
	
	* Diamonds
	// since if truncated (offscale), line options are removed from -rarea- and drawn separately
	local 0 `", `diamopts'"'
	syntax [, Color(string) LColor(string) ///
		HORizontal VERTical CMISsing(string) SORT * ]

	// disallowed options
	if `"`horizontal'"'!=`""' | `"`vertical'"'!=`""' {
		nois disp as err `"suboptions {bf:horizontal} and {bf:vertical} not allowed in option {bf:diamopts()}"'
		exit 198
	}			
	if `"`cmissing'"'!=`""' {
		nois disp as err `"suboption {bf:cmissing()} not allowed in option {bf:diamopts()}"'
		exit 198
	}
	if `"`sort'"'!=`""' {
		nois disp as err `"suboption {bf:sort} not allowed in option {bf:diamopts()}"'
		exit 198
	}
	
	// rebuild the option list
	if `"`color'"'!=`""' & `"`lcolor'"'==`""' local lcolor `color'			// convert `color' -rarea- option to `lcolor' -line- option
	local diamopts
	foreach opt in color lcolor {
		if `"``opt''"'!=`""' {
			local diamopts `"`diamopts' `opt'(``opt'')"'
		}
	}
	local diamopts `"`diamopts' `options'"'	
	
	

	** PARSE PLOT#OPTS
	
	// Loop over possible values of `plotid' and test for plot#opts relating specifically to each value
	numlist "1/`np'"
	local plvals=r(numlist)			// need both of these as explicit numlists,
	local pplvals `plvals'			//    for later macro manipulations to remove specific values if necessary
	forvalues p = 1/`np' {

		local 0 `", `rest'"'
		syntax [, ///
			/// /* standard options */
			BOX`p'opts(string asis) DIAM`p'opts(string asis) POINT`p'opts(string asis) CI`p'opts(string asis) OLINE`p'opts(string asis) ///
			/// /* non-diamond and prediction interval options */
			PPOINT`p'opts(string asis) PCI`p'opts(string asis) RF`p'opts(string asis) * ]

		local rest `"`options'"'

		* Check if any options were found specifically for this value of `p'
		if trim(`"`box`p'opts'`diam`p'opts'`point`p'opts'`ci`p'opts'`oline`p'opts'`ppoint`p'opts'`pci`p'opts'`rf`p'opts'"') != `""' {
			
			local pplvals : list pplvals - p			// remove from list of "default" plotids
			
			* OVERALL LINE(S) (if appropriate)
			summ `ovLine' if `plotid'==`p', meanonly
			if r(N) {
				local olinePlot `"`macval(olinePlot)' rspike `ovMin' `ovMax' `ovLine' if `touse' & `plotid'==`p', `defOlineOpts' `olineopts' `oline`p'opts' ||"'
			}
			
			* INDIVIDUAL STUDY MARKERS
			local touse2 `"`touse' & `_USE'==1 & `plotid'==`p'"'		// use local, not tempvar, so conditions are copied into plot commands
			qui count if `touse2'
			if r(N) {
			
				* WEIGHTED SCATTER PLOT
				local 0 `", `box`p'opts'"'
				syntax [, MLABEL(string) MSIZe(string) * ]			// check for disallowed options
				if `"`mlabel'"' != `""' {
					nois disp as err `"suboption {bf:mlabel()} not allowed in option {bf:box`p'opts()}"'
					exit 198
				}
				if `"`msize'"' != `""' {
					nois disp as err `"suboption {bf:msize()} not allowed in option {bf:box`p'opts()}"'
					exit 198
				}
				local scPlotOpts `"`defBoxOpts' `boxopts' `box`p'opts'"'
				summ `_WT' if `touse2', meanonly
				if !r(N) nois disp as err `"No weights found for {bf:plotid}==`p'"'
				else if `nd'==1 local scPlot `"`macval(scPlot)' scatter `id' `_ES' `awweight' if `toused' & `_USE'==1 & `plotid'==`p', `macval(scPlotOpts)' ||"'
				else {
					forvalues d=1/`nd' {
						local scPlot `"`macval(scPlot)' scatter `id' `_ES' `awweight' if `toused' & `_USE'==1 & `plotid'==`p' & `dataid'==`d', `macval(scPlotOpts)' ||"'
					}
				}		// N.B. scatter if `toused' <-- "dummy obs" for consistent weighting
				
				* CONFIDENCE INTERVAL PLOT
				local 0 `", `ci`p'opts'"'
				syntax [, LColor(string) MColor(string) LWidth(string) MLWidth(string) ///
					RCAP HORizontal VERTical Connect(string) * ]								// check for disallowed options + rcap
				
				// disallowed options
				if `"`horizontal'"'!=`""' | `"`vertical'"'!=`""' {
					nois disp as err `"suboptions {bf:horizontal} and {bf:vertical} not allowed in option {bf:ci`p'opts()}"'
					exit 198
				}			
				if `"`connect'"'!=`""' {
					nois disp as err `"suboption {bf:connect()} not allowed in option {bf:ci`p'opts()}"'
					exit 198
				}
				
				// rebuild option list
				if `"`lcolor'"'!=`""' & `"`mcolor'"'==`""'  local mcolor  `lcolor'		// for pc(b)arrow
				if `"`lwidth'"'!=`""' & `"`mlwidth'"'==`""' local mlwidth `lwidth'		// for pc(b)arrow
				local CIPlot`p'Opts
				foreach opt in mcolor lcolor mlwidth lwidth {
					if `"``opt''"'!=`""' {
						local CIPlot`p'Opts `"`CIPlot`p'Opts' `opt'(``opt'')"'
					}
				}
				local CIPlot`p'Opts `"`defCIOpts' `ciopts' `CIPlot`p'Opts' `options'"'		// main options first, then options specific to plot `p'
				local CIPlot`p'Type = cond("`rcap'"=="", "`CIPlotType'", "rcap")
				
				// default: both ends within scale (i.e. no arrows)
				local CIPlot `"`macval(CIPlot)' `CIPlot`p'Type' `_LCI' `_UCI' `id' if `touse2' & !`offscaleL' & !`offscaleR', hor `macval(CIPlot`p'Opts)' ||"'

				// if arrows required
				if `"`colsonly'"'==`""' {
					qui count if `touse2' & `offscaleL' & `offscaleR'
					if r(N) {													// both ends off scale
						local CIPlot `"`macval(CIPlot)' pcbarrow `id' `_LCI' `id' `_UCI' if `touse2' & `offscaleL' & `offscaleR', `macval(CIPlot`p'Opts)' ||"'
					}
					qui count if `touse2' & `offscaleL' & !`offscaleR'
					if r(N) {													// only left off scale
						local CIPlot `"`macval(CIPlot)' pcarrow `id' `_UCI' `id' `_LCI' if `touse2' & `offscaleL' & !`offscaleR', `macval(CIPlot`p'Opts)' ||"'
						if "`CIPlot`p'Type'" == "rcap" {			// add cap to other end if appropriate
							local CIPlot `"`macval(CIPlot)' rcap `_UCI' `_UCI' `id' if `touse2' & `offscaleL' & !`offscaleR', hor `macval(CIPlot`p'Opts)' ||"'
						}
					}
					qui count if `touse2' & !`offscaleL' & `offscaleR'
					if r(N) {													// only right off scale
						local CIPlot `"`macval(CIPlot)' pcarrow `id' `_LCI' `id' `_UCI' if `touse2' & !`offscaleL' & `offscaleR', `macval(CIPlot`p'Opts)' ||"'
						if "`CIPlot`p'Type'" == "rcap" {			// add cap to other end if appropriate
							local CIPlot `"`macval(CIPlot)' rcap `_LCI' `_LCI' `id' if `touse2' & !`offscaleL' & `offscaleR', hor `macval(CIPlot`p'Opts)' ||"'
						}
					}
				}

				* POINT PLOT (point estimates -- except if "classic")
				if "`classic'" == "" {
					local pointPlot `"`macval(pointPlot)' scatter `id' `_ES' if `touse2', `defPointOpts' `pointopts' `point`p'opts' ||"'
				}
			}			// end if r(N) [i.e. if any obs with _USE==1 & plotid==`p']

			
			* POOLED EFFECT MARKERS
			local touse2 `"`toused' & inlist(`_USE', 3, 5) & `plotid'==`p'"'		// use local, not tempvar, so conditions are copied into plot commands
			qui count if `touse2'
			if r(N) {
			
				* DIAMONDS:  DRAW POLYGONS WITH -twoway rarea-
				* Assume diamond if no "pooled point/CI" options, and no "interaction" option
				if trim(`"`ppointopts'`ppoint`p'opts'`pciopts'`pci`p'opts'`interaction'`diamonds'"') == `""' {
				
					local 0 `", `diam`p'opts'"'
					syntax [, Color(string) LColor(string) ///
						HORizontal VERTical CMISsing(string) SORT * ]

					// disallowed options
					if `"`horizontal'"'!=`""' | `"`vertical'"'!=`""' {
						nois disp as err `"suboptions {bf:horizontal} and {bf:vertical} not allowed in option {bf:diamopts()}"'
						exit 198
					}			
					if `"`cmissing'"'!=`""' {
						nois disp as err `"suboption {bf:cmissing()} not allowed in option {bf:diamopts()}"'
						exit 198
					}
					if `"`sort'"'!=`""' {
						nois disp as err `"suboption {bf:sort} not allowed in option {bf:diamopts()}"'
						exit 198
					}
					
					// rebuild option list
					if `"`color'"'!=`""' & `"`lcolor'"'==`""' local lcolor `color'			// convert `color' -rarea- option to `lcolor' -line- option
					local diamPlot`p'Opts
					foreach opt in color lcolor {
						if `"``opt''"'!=`""' {
							local diamPlot`p'Opts `"`diamPlot`p'Opts' `opt'(``opt'')"'
						}
					}
					local diamPlot`p'Opts `"`defDiamOpts' `diamopts' `diamPlot`p'Opts' `options'"'		// main options first, then options specific to plot `p'
					
					// Now check whether any diamonds are offscale (niche case -- see also comments on ppoint below)
					// If so, will need to draw round the edges of the polygon, excepting the "offscale edges"
					//   and switch off the line options to -twoway rarea-
					// (draw these lines *after* drawing the area, though, so that the lines appear on top)
					qui count if `touse2' & (`offscaleL' | `offscaleR')
					if r(N) {
						local diam`p'Line `"line `DiamY1' `DiamX' if `touse2', `macval(diamPlot`p'Opts)' cmissing(n) ||"'
						local diam`p'Line `"`macval(diam`p'Line)' line `DiamY2' `DiamX' if `touse2', `macval(diamPlot`p'Opts)' cmissing(n) ||"'
						local diam`p'LWidth `"lwidth(none)"'
					}
					local diamPlot `"`macval(diamPlot)' rarea `DiamY1' `DiamY2' `DiamX' if `touse2', `macval(diamPlot`p'Opts)' `diam`p'LWidth' cmissing(n) || `diam`p'Line' "'
				}
				
				* POOLED EFFECTS - PPOINT/PCI
				else {
					if trim(`"`diam`p'opts'"') != `""' {
						nois disp as err `"Note: suboptions for both diamond and pooled point/CI specified for {bf:plotid}==`p';"'
						nois disp as err `"      diamond suboptions will be ignored"'
					}	
				
					// shouldn't need to bother with arrows etc. here, as pooled effect should always be narrower than individual estimates
					// but do it anyway, just in case of non-obvious use case
					local 0 `", `pci`p'opts'"'
					syntax [, LColor(string) MColor(string) LWidth(string) MLWidth(string) ///
						RCAP HORizontal VERTical Connect(string) * ]											// check for disallowed options + rcap
					
					// disallowed options
					if `"`horizontal'"'!=`""' | `"`vertical'"'!=`""' {
						nois disp as err `"suboptions {bf:horizontal} and {bf:vertical} not allowed in option{bf:pci`p'opts()}"'
						exit 198
					}			
					if `"`connect'"' != `""' {
						nois disp as err `"suboption {bf:connect()} not allowed in option {bf:pci`p'opts}"'
						exit 198
					}
					
					// rebuild option list
					if `"`lcolor'"'!=`""' & `"`mcolor'"'==`""'  local mcolor  `lcolor'			// for pc(b)arrow
					if `"`lwidth'"'!=`""' & `"`mlwidth'"'==`""' local mlwidth `lwidth'			// for pc(b)arrow
					local PCIPlot`p'Opts
					foreach opt in mcolor lcolor mlwidth lwidth {
						if `"``opt''"'!=`""' {
							local PCIPlot`p'Opts `"`PCIPlot`p'Opts' `opt'(``opt'')"'
						}
					}
					local PCIPlot`p'Opts `"`defPCIOpts' `pciopts' `PCIPlot`p'Opts' `options'"'		// main options first, then options specific to plot `p'
					local PCIPlot`p'Type = cond("`rcap'"=="", "`PCIPlotType'", "rcap")
					
					// default: both ends within scale (i.e. no arrows)
					local PCIPlot `"`macval(PCIPlot)' `PCIPlot`p'Type' `_LCI' `_UCI' `id' if `touse2' & !`offscaleL' & !`offscaleR', hor `macval(PCIPlot`p'Opts)' ||"'

					// if arrows are required
					if `"`colsonly'"'==`""' {
						qui count if `touse2' & `offscaleL' & `offscaleR'
						if r(N) {													// both ends off scale
							local PCIPlot `"`macval(PCIPlot)' pcbarrow `id' `_LCI' `id' `_UCI' if `touse2' & `offscaleL' & `offscaleR', `macval(PCIPlot`p'Opts)' ||"'
						}
						qui count if `touse2' & `offscaleL' & !`offscaleR'
						if r(N) {													// only left off scale
							local PCIPlot `"`macval(PCIPlot)' pcarrow `id' `_UCI' `id' `_LCI' if `touse2' & `offscaleL' & !`offscaleR', `macval(PCIPlot`p'Opts)' ||"'
							if "`PCIPlot`p'Type'" == "rcap" {			// add cap to other end if appropriate
								local PCIPlot `"`macval(PCIPlot)' rcap `_UCI' `_UCI' `id' if `touse2' & `offscaleL' & !`offscaleR', hor `macval(PCIPlot`p'Opts)' ||"'
							}
						}
						qui count if `touse2' & !`offscaleL' & `offscaleR'
						if r(N) {													// only right off scale
							local PCIPlot `"`macval(PCIPlot)' pcarrow `id' `_LCI' `id' `_UCI' if `touse2' & !`offscaleL' & `offscaleR', `macval(PCIPlot`p'Opts)' ||"'
							if "`PCIPlot`p'Type'" == "rcap" {			// add cap to other end if appropriate
								local PCIPlot `"`macval(PCIPlot)' rcap `_LCI' `_LCI' `id' if `touse2' & !`offscaleL' & `offscaleR', hor `macval(PCIPlot`p'Opts)' ||"'
							}
						}				
						local ppointPlot `"`macval(ppointPlot)' scatter `id' `_ES' if `touse2', `defPPointOpts' `ppointopts' `ppoint`p'opts' ||"'
					}
				}
				
				* PREDICTION INTERVAL
				if `"`rfdist'"'==`""' {
					if trim(`"`rf`p'opts'"') != `""' {
						nois disp as err `"prediction interval not specified; relevant suboptions for {bf:plotid==`p'} will be ignored"'
					}
				}
				else {
					local 0 `", `rf`p'opts'"'
					syntax [, LColor(string) MColor(string) LWidth(string) MLWidth(string) ///
						RCAP OVerlay HORizontal VERTical Connect(string) * ]									// check for disallowed options + rcap, plus additional option -overlay-
					
					// disallowed options
					if `"`horizontal'"'!=`""' | `"`vertical'"'!=`""' {
						nois disp as err `"suboptions {bf:horizontal} and {bf:vertical} not allowed in option {bf:rf`p'opts}"'
						exit 198
					}			
					if `"`connect'"' != `""' {
						nois disp as err `"suboption {bf:connect()} not allowed in option {bf:rf`p'opts()}"'
						exit 198
					}
					
					// rebuild option list
					if `"`lcolor'"'!=`""' & `"`mcolor'"'==`""'  local mcolor  `lcolor'			// for pc(b)arrow
					if `"`lwidth'"'!=`""' & `"`mlwidth'"'==`""' local mlwidth `lwidth'			// for pc(b)arrow
					local RFPlot`p'Opts
					foreach opt in mcolor lcolor mlwidth lwidth {
						if `"``opt''"'!=`""' {
							local RFPlot`p'Opts `"`RFPlot`p'Opts' `opt'(``opt'')"'
						}
					}
					local RFPlot`p'Opts `"`defRFOpts' `rfopts' `RFPlot`p'Opts' `options'"'		// main options first, then options specific to plot `p'
					local RFPlot`p'Type = cond("`rcap'"=="", "`RFPlotType'", "rcap")
				
					// if overlay, use same approach as for CI/PCI
					if trim(`"`overlay'`g_overlay'"') != `""' {
						local touse_add `"float(`_rfUCI')>=float(`CXmin') & float(`_rfLCI')<=float(`CXmax') & float(`_rfLCI')!=float(`_rfUCI')"'
				
						// default: both ends within scale (i.e. no arrows)
						local touse3 `"`touse2' & !`rfLoffscaleL' & !`rfRoffscaleR' & `touse_add'"'
						local RFPlot `"`macval(RFPlot)' `RFPlot`p'Type' `_rfLCI' `_rfUCI' `id' if `touse3', hor `macval(RFPlot`p'Opts)' ||"'

						// if arrows required
						local touse3 `"`touse2' & `rfLoffscaleL' & `rfRoffscaleR' & `touse_add'"'
						qui count if `touse3'
						if r(N) {													// both ends off scale
							local RFPlot `"`macval(RFPlot)' pcbarrow `id' `_rfLCI' `id' `_rfUCI' if `touse3', `macval(RFPlot`p'Opts)' ||"'
						}
						local touse3 `"`touse2' & `rfLoffscaleL' & !`rfRoffscaleR' & `touse_add'"'
						qui count if `touse3'
						if r(N) {													// only left off scale
							local RFPlot `"`macval(RFPlot)' pcarrow `id' `_rfUCI' `id' `_rfLCI' if `touse3', `macval(RFPlot`p'Opts)' ||"'
							if "`RFPlotType'" == "rcap" {			// add cap to other end if appropriate
								local RFPlot `"`macval(RFPlot)' rcap `_rfUCI' `_rfUCI' `id' if `touse3', hor `macval(RFPlot`p'Opts)' ||"'
							}
						}
						local touse3 `"`touse2' & !`rfLoffscaleL' & `rfRoffscaleR' & `touse_add'"'
						qui count if `touse3'
						if r(N) {													// only right off scale
							local RFPlot `"`macval(RFPlot)' pcarrow `id' `_rfLCI' `id' `_rfUCI' if `touse3', `macval(RFPlot`p'Opts)' ||"'
							if "`RFPlotType'" == "rcap" {			// add cap to other end if appropriate
								local RFPlot `"`macval(RFPlot)' rcap `_rfLCI' `_rfLCI' `id' if `touse3', hor `macval(RFPlot`p'Opts)' ||"'
							}
						}
					}
					
					// otherwise, need to do it slightly differently, as we are dealing with two separate (left/right) lines
					else {
					
						// identify special cases where only one line required, with two arrows
						local touse3 `"`touse2' & (`rfLoffscaleL' & `rfLoffscaleR') | (`rfRoffscaleL' & `rfRoffscaleR')"'
						qui count if `touse3'
						if r(N) {
							local RFPlot `"`macval(RFPlot)' pcbarrow `id' `_rfLCI' `id' `_rfUCI' if `touse3', `macval(RFPlot`p'Opts)' ||"'
						}
						
						// left-hand line
						local touse_add `"float(`_rfLCI')<=float(`CXmax') & float(`_rfLCI')!=float(`_LCI')"'

						local touse3 `"`touse2' & !`rfLoffscaleL' & !`rfLoffscaleR' & !`offscaleL' & `touse_add'"'
						local RFPlot `"`macval(RFPlot)' `RFPlot`p'Type' `_LCI' `_rfLCI' `id' if `touse3', hor `macval(RFPlot`p'Opts)' ||"'
						
						local touse3 `"`touse2' & `rfLoffscaleL' & !`rfLoffscaleR' & !`offscaleL' & `touse_add'"'
						qui count if `touse3'
						if r(N) {										// left-hand end off scale
							local RFPlot `"`macval(RFPlot)' pcarrow `id' `_LCI' `id' `_rfLCI' if `touse3', `macval(RFPlot`p'Opts)' ||"'
						}

						local touse3 `"`touse2' & !`rfLoffscaleL' & `rfLoffscaleR' & !`offscaleL' & `touse_add'"'
						qui count if `touse3'
						if r(N) {										// right-hand end off scale
							local RFPlot `"`macval(RFPlot)' pcarrow `id' `_rfLCI' `id' `_LCI' if `touse3', `macval(RFPlot`p'Opts)' ||"'
						}

						// right-hand line
						local touse_add `"float(`_rfUCI')>=float(`CXmin') & float(`_rfUCI')!=float(`_UCI')"'
						
						local touse3 `"`touse2' & !`rfRoffscaleL' & !`rfRoffscaleR' & !`offscaleR' & `touse_add'"'
						local RFPlot `"`macval(RFPlot)' `RFPlot`p'Type' `_UCI' `_rfUCI' `id' if `touse3', hor `macval(RFPlot`p'Opts)' ||"'
						
						local touse3 `"`touse2' & `rfRoffscaleL' & !`rfRoffscaleR' & !`offscaleR' & `touse_add'"'
						qui count if `touse3'
						if r(N) {										// left-hand end off scale
							local RFPlot `"`macval(RFPlot)' pcarrow `id' `_rfUCI' `id' `_UCI' if `touse3', `macval(RFPlot`p'Opts)' ||"'
						}

						local touse3 `"`touse2' & !`rfRoffscaleL' & `rfRoffscaleR' & !`offscaleR' & `touse_add'"'
						qui count if `touse3'
						if r(N) {										// right-hand end off scale
							local RFPlot `"`macval(RFPlot)' pcarrow `id' `_UCI' `id' `_rfUCI' if `touse3', `macval(RFPlot`p'Opts)' ||"'
						}
					}
				}			// end else [i.e. if rfdist]
			}			// end if r(N) [i.e. if any obs with _USE==3,5 & plotid==`p']
		}		// end if trim(`"`box`p'opts'`diam`p'opts'`point`p'opts'`ci`p'opts'`oline`p'opts'`ppoint`p'opts'`pci`p'opts'"') != `""'
	}		// end forvalues p = 1/`np'

	
	* Find invalid/repeated options
	// any such options would generate a suitable error message at the plotting stage
	// so just exit here with error, to save the user's time
	if regexm(`"`rest'"', "(box|diam|point|ci|oline|ppoint|pci|rf)([0-9]+)opt") {
		local badopt = regexs(1)
		local badp = regexs(2)
		
		if `: list badp in plvals' nois disp as err `"option {bf:`badopt'`badp'opts} supplied multiple times; should only be supplied once"'
		else nois disp as err `"`badp' is not a valid {bf:plotid} value"'
		exit 198
	}

	sreturn local options `"`rest'"'	// This is now *just* the standard "twoway" options
										//   i.e. the specialist "forestplot" options have been filtered out
	if `"`colsonly'"'!=`""' exit		// Now we have returned `s(options)', rest of program is irrelevant if `colsonly'
	
	
	* FORM "DEFAULT" TWOWAY PLOT COMMAND (if appropriate)
	// Changed so that FOR WEIGHTED SCATTER each pplval is plotted separately (otherwise weights get messed up)
	// Other (nonweighted) plots can continue to be plotted as before
	if `"`pplvals'"'!=`""' {

		local pplvals2 : copy local pplvals						// copy; only needed for weighted scatter plots
		local pplvals : subinstr local pplvals " " ",", all		// so that "inlist" may be used

		* OVERALL LINE(S) (if appropriate)
		summ `ovLine' if inlist(`plotid', `pplvals'), meanonly
		if r(N) {
			local olinePlot `"`macval(olinePlot)' rspike `ovMin' `ovMax' `ovLine' if `touse' & inlist(`plotid', `pplvals'), `defOlineOpts' `olineopts' ||"'
		}
		
		* INDIVIDUAL STUDY MARKERS
		local touse2 `"`touse' & `_USE'==1 & inlist(`plotid', `pplvals')"'		// use local, not tempvar, so conditions are copied into plot commands
		qui count if `touse2'
		if r(N) {
		
			* WEIGHTED SCATTER PLOT
			local 0 `", `boxopts'"'
			syntax [, MLABEL(string) MSIZe(string) * ]	// check for disallowed options
			if `"`mlabel'"' != `""' {
				disp as err "boxopts: option mlabel() not allowed"
				exit 198
			}
			if `"`msize'"' != `""' {
				disp as err "boxopts: option msize() not allowed"
				exit 198
			}
			local scPlotOpts `"`defBoxOpts' `boxopts'"'
			
			if `"`pplvals'"'==`"`plvals'"' {		// if no plot#opts specified, can plot all plotid groups at once
				summ `_WT' if `touse2', meanonly
				if r(N) {
					if `nd'==1 local scPlot `"`macval(scPlot)' scatter `id' `_ES' `awweight' if `toused' & `_USE'==1 & inlist(`plotid', `pplvals'), `macval(scPlotOpts)' ||"'
					else {
						forvalues d=1/`nd' {
							local scPlot `"`macval(scPlot)' scatter `id' `_ES' `awweight' if `toused' & `_USE'==1 & inlist(`plotid', `pplvals') & `dataid'==`d', `macval(scPlotOpts)' ||"'
						}
					}
				}
			}
			else {		// else, need to plot each group separately to maintain correct weighting (July 2014)
				foreach p of local pplvals2 {
					summ `_WT' if `touse' & `_USE'==1 & `plotid'==`p', meanonly
					if r(N) {
						if `nd'==1 local scPlot `"`macval(scPlot)' scatter `id' `_ES' `awweight' if `toused' & `_USE'==1 & `plotid'==`p', `macval(scPlotOpts)' ||"'
						else {
							forvalues d=1/`nd' {
								local scPlot `"`macval(scPlot)' scatter `id' `_ES' `awweight' if `toused' & `_USE'==1 & `plotid'==`p' & `dataid'==`d', `macval(scPlotOpts)' ||"'
							}
						}
					}
				}
			}		// N.B. scatter if `toused' <-- "dummy obs" for consistent weighting
			
			
			* CONFIDENCE INTERVAL PLOT
			// N.B. options already processed
			local CIPlotOpts `"`defCIOpts' `ciopts'"'
			
			// default: both ends within scale (i.e. no arrows)
			local CIPlot `"`macval(CIPlot)' `CIPlotType' `_LCI' `_UCI' `id' if `touse2' & !`offscaleL' & !`offscaleR', hor `macval(CIPlotOpts)' ||"'

			// if arrows required
			qui count if `touse2' & `offscaleL' & `offscaleR'
			if r(N) {													// both ends off scale
				local CIPlot `"`macval(CIPlot)' pcbarrow `id' `_LCI' `id' `_UCI' if `touse2' & `offscaleL' & `offscaleR', `macval(CIPlotOpts)' ||"'
			}
			qui count if `touse2' & `offscaleL' & !`offscaleR'
			if r(N) {													// only left off scale
				local CIPlot `"`macval(CIPlot)' pcarrow `id' `_UCI' `id' `_LCI' if `touse2' & `offscaleL' & !`offscaleR', `macval(CIPlotOpts)' ||"'
				if "`CIPlotType'" == "rcap" {			// add cap to other end if appropriate
					local CIPlot `"`macval(CIPlot)' rcap `_UCI' `_UCI' `id' if `touse2' & `offscaleL' & !`offscaleR', hor `macval(CIPlotOpts)' ||"'
				}
			}
			qui count if `touse2' & !`offscaleL' & `offscaleR'
			if r(N) {													// only right off scale
				local CIPlot `"`macval(CIPlot)' pcarrow `id' `_LCI' `id' `_UCI' if `touse2' & !`offscaleL' & `offscaleR', `macval(CIPlotOpts)' ||"'
				if "`CIPlotType'" == "rcap" {			// add cap to other end if appropriate
					local CIPlot `"`macval(CIPlot)' rcap `_LCI' `_LCI' `id' if `touse2' & !`offscaleL' & `offscaleR', hor `macval(CIPlotOpts)' ||"'
				}
			}

			
			* POINT PLOT (point estimates -- except if "classic")
			if "`classic'" == "" {
				local pointPlot `"`macval(pointPlot)' scatter `id' `_ES' if `touse2', `defPointOpts' `pointopts' ||"'
			}
		}			// end if r(N) [i.e. if any obs with _USE==1 & plotid==`ppvals']
		
		
		* POOLED EFFECT MARKERS
		local touse2 `"`toused' & inlist(`_USE', 3, 5) & inlist(`plotid', `pplvals')"'		// use local, not tempvar, so conditions are copied into plot commands
		qui count if `touse2'			
		if r(N) {

			* DIAMONDS - DRAW POLYGONS WITH -twoway rarea-
			* Assume diamond if no "pooled point/CI" options, and no "interaction" option
			if trim(`"`ppointopts'`pciopts'`interaction'`diamonds'"') == `""' {
				local diamPlotOpts `"`defDiamOpts' `diamopts'"'
				
				// Now check whether any diamonds are offscale (niche case!)
				// If so, will need to draw round the edges of the polygon, excepting the "offscale edges"
				//   and switch off the line options to -twoway rarea-
				// (draw these lines *after* drawing the area, though, so that the lines appear on top)
				qui count if `touse2' & (`offscaleL' | `offscaleR')
				if r(N) {
					local diamLine `"line `DiamY1' `DiamX' if `touse2', `macval(diamPlotOpts)' cmissing(n) ||"'
					local diamLine `"`macval(diamLine)' line `DiamY2' `DiamX' if `touse2', `macval(diamPlotOpts)' cmissing(n) ||"'
					local diamLWidth `"lwidth(none)"'
				}
				local diamPlot `"`macval(diamPlot)' rarea `DiamY1' `DiamY2' `DiamX' if `touse2', `macval(diamPlotOpts)' `diamLWidth' cmissing(n) || `diamLine' "'
			}
		
		
			* POOLED EFFECT - PPOINT/PCI
			else {
				if trim(`"`diamopts'"') != `""' {
					nois disp as err `"Note: suboptions for both diamond and pooled point/CI specified;"'
					nois disp as err `"      diamond suboptions will be ignored"'
				}	

				// N.B. options already processed
				local PCIPlotOpts `"`defPCIOpts' `pciopts'"'
				
				// default: both ends within scale (i.e. no arrows)
				local PCIPlot `"`macval(PCIPlot)' `PCIPlotType' `_LCI' `_UCI' `id' if `touse2' & !`offscaleL' & !`offscaleR', hor `macval(PCIPlotOpts)' ||"'

				// if arrows are required
				// if `"`colsonly'"'==`""' {
					qui count if `touse2' & `offscaleL' & `offscaleR'
					if r(N) {													// both ends off scale
						local PCIPlot `"`macval(PCIPlot)' pcbarrow `id' `_LCI' `id' `_UCI' if `touse2' & `offscaleL' & `offscaleR', `macval(PCIPlotOpts)' ||"'
					}
					qui count if `touse2' & `offscaleL' & !`offscaleR'
					if r(N) {													// only left off scale
						local PCIPlot `"`macval(PCIPlot)' pcarrow `id' `_UCI' `id' `_LCI' if `touse2' & `offscaleL' & !`offscaleR', `macval(PCIPlotOpts)' ||"'
						if "`PCIPlotType'" == "rcap" {			// add cap to other end if appropriate
							local PCIPlot `"`macval(PCIPlot)' rcap `_UCI' `_UCI' `id' if `touse2' & `offscaleL' & !`offscaleR', hor `macval(PCIPlotOpts)' ||"'
						}
					}
					qui count if `touse2' & !`offscaleL' & `offscaleR'
					if r(N) {													// only right off scale
						local PCIPlot `"`macval(PCIPlot)' pcarrow `id' `_LCI' `id' `_UCI' if `touse2' & !`offscaleL' & `offscaleR', `macval(PCIPlotOpts)' ||"'
						if "`PCIPlotType'" == "rcap" {			// add cap to other end if appropriate
							local PCIPlot `"`macval(PCIPlot)' rcap `_LCI' `_LCI' `id' if `touse2' & !`offscaleL' & `offscaleR', hor `macval(PCIPlotOpts)' ||"'
						}
					}				
					local ppointPlot `"`macval(ppointPlot)' scatter `id' `_ES' if `touse2', `defPPointOpts' `ppointopts' ||"'
				// }
			}
		
		
			* PREDICTION INTERVAL		
			if `"`rfdist'"'==`""' {
				if trim(`"`rfopts'"') != `""' {
					nois disp as err `"prediction interval not specified; relevant suboptions will be ignored"'
				}
			}
			
			else {
			
				// N.B. options already processed
				local RFPlotOpts `"`defRFOpts' `rfopts'"'
			
				// if overlay, use same approach as for CI/PCI
				if `"`g_overlay'"'!=`""' {
					local touse_add `"float(`_rfUCI')>=float(`CXmin') & float(`_rfLCI')<=float(`CXmax') & float(`_rfLCI')!=float(`_rfUCI')"'
			
					// default: both ends within scale (i.e. no arrows)
					local touse3 `"`touse2' & !`rfLoffscaleL' & !`rfRoffscaleR' & `touse_add'"'
					local RFPlot `"`macval(RFPlot)' `RFPlotType' `_rfLCI' `_rfUCI' `id' if `touse3', hor `macval(RFPlotOpts)' ||"'

					// if arrows required
					local touse3 `"`touse2' & `rfLoffscaleL' & `rfRoffscaleR' & `touse_add'"'
					qui count if `touse3'
					if r(N) {													// both ends off scale
						local RFPlot `"`macval(RFPlot)' pcbarrow `id' `_rfLCI' `id' `_rfUCI' if `touse3', `macval(RFPlotOpts)' ||"'
					}
					local touse3 `"`touse2' & `rfLoffscaleL' & !`rfRoffscaleR' & `touse_add'"'
					qui count if `touse3'
					if r(N) {													// only left off scale
						local RFPlot `"`macval(RFPlot)' pcarrow `id' `_rfUCI' `id' `_rfLCI' if `touse3', `macval(RFPlotOpts)' ||"'
						if "`RFPlotType'" == "rcap" {			// add cap to other end if appropriate
							local RFPlot `"`macval(RFPlot)' rcap `_rfUCI' `_rfUCI' `id' if `touse3', hor `macval(RFPlotOpts)' ||"'
						}
					}
					local touse3 `"`touse2' & !`rfLoffscaleL' & `rfRoffscaleR' & `touse_add'"'
					qui count if `touse3'
					if r(N) {													// only right off scale
						local RFPlot `"`macval(RFPlot)' pcarrow `id' `_rfLCI' `id' `_rfUCI' if `touse3', `macval(RFPlotOpts)' ||"'
						if "`RFPlotType'" == "rcap" {			// add cap to other end if appropriate
							local RFPlot `"`macval(RFPlot)' rcap `_rfLCI' `_rfLCI' `id' if `touse3', hor `macval(RFPlotOpts)' ||"'
						}
					}
				}
				
				// otherwise, need to do it slightly differently, as we are dealing with two separate (left/right) lines
				else {
				
					// identify special cases where only one line required, with two arrows
					local touse3 `"`touse2' & (`rfLoffscaleL' & `rfLoffscaleR') | (`rfRoffscaleL' & `rfRoffscaleR')"'
					qui count if `touse3'
					if r(N) {
						local RFPlot `"`macval(RFPlot)' pcbarrow `id' `_rfLCI' `id' `_rfUCI' if `touse3', `macval(RFPlotOpts)' ||"'
					}
					
					// left-hand line
					local touse_add `"float(`_rfLCI')<=float(`CXmax') & float(`_rfLCI')!=float(`_LCI')"'

					local touse3 `"`touse2' & !`rfLoffscaleL' & !`rfLoffscaleR' & !`offscaleL' & `touse_add'"'
					local RFPlot `"`macval(RFPlot)' `RFPlotType' `_LCI' `_rfLCI' `id' if `touse3', hor `macval(RFPlotOpts)' ||"'
					
					local touse3 `"`touse2' & `rfLoffscaleL' & !`rfLoffscaleR' & !`offscaleL' & `touse_add'"'
					qui count if `touse3'
					if r(N) {										// left-hand end off scale
						local RFPlot `"`macval(RFPlot)' pcarrow `id' `_LCI' `id' `_rfLCI' if `touse3', `macval(RFPlotOpts)' ||"'
					}

					local touse3 `"`touse2' & !`rfLoffscaleL' & `rfLoffscaleR' & !`offscaleL' & `touse_add'"'
					qui count if `touse3'
					if r(N) {										// right-hand end off scale
						local RFPlot `"`macval(RFPlot)' pcarrow `id' `_rfLCI' `id' `_LCI' if `touse3', `macval(RFPlotOpts)' ||"'
					}

					// right-hand line
					local touse_add `"float(`_rfUCI')>=float(`CXmin') & float(`_rfUCI')!=float(`_UCI')"'
					
					local touse3 `"`touse2' & !`rfRoffscaleL' & !`rfRoffscaleR' & !`offscaleR' & `touse_add'"'
					local RFPlot `"`macval(RFPlot)' `RFPlotType' `_UCI' `_rfUCI' `id' if `touse3', hor `macval(RFPlotOpts)' ||"'
					
					local touse3 `"`touse2' & `rfRoffscaleL' & !`rfRoffscaleR' & !`offscaleR' & `touse_add'"'
					qui count if `touse3'
					if r(N) {										// left-hand end off scale
						local RFPlot `"`macval(RFPlot)' pcarrow `id' `_rfUCI' `id' `_UCI' if `touse3', `macval(RFPlotOpts)' ||"'
					}

					local touse3 `"`touse2' & !`rfRoffscaleL' & `rfRoffscaleR' & !`offscaleR' & `touse_add'"'
					qui count if `touse3'
					if r(N) {										// right-hand end off scale
						local RFPlot `"`macval(RFPlot)' pcarrow `id' `_UCI' `id' `_rfUCI' if `touse3', `macval(RFPlotOpts)' ||"'
					}
				}
			}		// end if `"`rfdist'"'!=`""'
		}		// end if r(N) [i.e. if any obs with _USE==3,5 & plotid==`ppvals']
	}		// end if `"`pplvals'"'!=`""'
		
	// END GRAPH OPTS
	
	
	// DF: modified to use added line approach instead of pcspike (less complex & poss. more efficient as fewer vars)
	// null line (unless switched off)
	if "`null'" == "" {
		local 0 `", `nlineopts'"'
		syntax [, HORizontal VERTical Connect(string) * ]
		if `"`horizontal'"'!=`""' | `"`vertical'"'!=`""' {
			nois disp as err `"suboptions {bf:horizontal} and {bf:vertical} not allowed in option {bf:nlineopts()}"'
			exit 198
		}			
		if `"`connect'"' != `""' {
			nois disp as err `"suboption {bf:connect()} not allowed in option {bf:nlineopts()}"'
			exit 198
		}
		
		summ `id', meanonly
		local DYmin = r(min)-1
		
		summ `id' if `_USE'!=9, meanonly
		local borderline = r(max) + 1 - 0.25
		local nullCommand `" function y=`h0', horiz range(`DYmin' `borderline') n(2) `defNlineOpts' `options' ||"'
	}
	
	// Return plot commands
	sreturn local olineplot   `"`olinePlot'"'
	sreturn local nullcommand `"`nullCommand'"'
	sreturn local scplot      `"`scPlot'"'
	sreturn local ciplot      `"`CIPlot'"'
	sreturn local rfplot      `"`RFPlot'"'
	sreturn local pciplot     `"`PCIPlot'"'
	sreturn local diamplot    `"`diamPlot'"'
	sreturn local pointplot   `"`pointPlot'"'
	sreturn local ppointplot  `"`ppointPlot'"'
	
end	
	

