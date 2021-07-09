*! version 2.1.8 (JCG, JBC, PR) 20may2013
* For history, see end of this file
program define mim
	// PR 15may2013. Ensure that estcmds are run under caller's version of Stata, not version 9.2.
	global VV : di "version " string(_caller()) ", missing:"
	version 9.2

	CheckDataStyle

	// FIRST CHECK FOR REPLAY OF LAST ESTIMATES
	capture _on_colon_parse `0'					// split command line at first colon
	local mimcmdline `s(before)'
	local statacmd `s(after)'
	if substr(`"`statacmd'"', 1, 8) == "stepwise" {
		mim`statacmd'
		exit
	}
	if ( c(rc) | `"`s(after)'"' == "" ) {			// if no colon in cmd line, or no cmd after colon
		if ( `"`e(MIM_prefix2)'"' != "mim" ) error 301	// if last mim estimates not found
		local cmd `"`e(MIM_cmd)'"'
		local inbV `"`e(MIM_inbV)'"'				// -1 == none, 0 == combined, >1 == indivdual

		syntax [, ///
				j(integer -2) 	/// User must specify j>=1 to replay estimates for individual dataset
				STorebv 		/// MI estimates are placed in e(b), e(V); not valid with j option 
				CLearbv 		/// MI estimates are cleared from e(b), e(V); not valid with j option
				noclear		/// Undocumented; instructs mim not to clear existing e() values prior
							/// to reposting e(b), e(V) etc. Not valid with clearbv option.
				LRR			/// Undocumented; instructs mim to use LRR method for constructing
							/// var/covar matrix
				MCerror		/// reports Monte Carlo error via B/m for coeffs and jackknifing for rest
				* 			/// This is for reporting options
		]

		if `"`se'"'!="" & `"`est'"'=="" {
			display as error "se() requires also specifying est()"
			exit 198
		}
		if "`mcerror'"!="" {
			local storebv storebv	// to force storebv, if not already in place
		}
		if ( `j' != -2 & `j' < 1 ) {
			display as error "j option must be positive"
			exit 198
		}
		if ( "`clear'" == "noclear" & `"`clearbv'"' != "" ) {
			display as error "noclear and clearbv options may not be combined"
			exit 198
		}
		if ( `"`clearbv'"' != "" & `"`storebv'"' != "" ) {
			display as error "clearbv and storebv options may not be combined"
			exit 198
		}
		if ( `"`clearbv'"' != "" & `j' >= 1 ) {
			display as error "clearbv and j options may not be combined"
			exit 198
		}
		if ( `"`storebv'"' != "" & `j' >= 1 ) {
			display as error "storebv and j options may not be combined"
			exit 198
		}
		if ( `"`clearbv'"' != "" ) local j = -1
		if ( `"`storebv'"' != "" ) local j = 0
		if ( "`lrr'" != "" ) local lrr "lrr"

		parsereportopts, cmd(`cmd') `options'
		local eformstr `"`s(eformstr)'"'
		local eformopt `"eformopt(`s(eformopt)')"'
		local level `"`s(level)'"'
		local options `"`s(options)'"'
		if ( `"`options'"' != "" ) {
			display as error `"`options' not allowed"'
			exit 198
		}

		// reshuffle mim results in e(), if necessary
		if ( `j' > -2 ) & (`j' != `inbV') {
			fit_handlebV, j(`j') `clear'
			local inbV `j'
		}

		if "`mcerror'"!="" {
			mim_jackknife
			tempname jackse
			matrix `jackse' = r(jackse)
			local jackknife jackknife(`jackse')
		}

		// display results
		if ( `inbV' <= 0 ) fit_display, cmd(`cmd') `level' `eformstr' `lrr' `jackknife'
		else fit_display_indiv, j(`inbV') cmd(`cmd') `level' `eformstr' `eformopt'
		exit 0
	}

	// OTHERWISE INTERCEPT PREFIXES LYING BETWEEN MIM AND CMD
	local version "vers versi versio version"
	local allow "svy `version'"
	local disallow "cap capt captu captur capture"	
	local disallow "`disallow' qui quie quiet quietl quietly"
	local disallow "`disallow' n no noi nois noisi noisil noisily"
	local disallow "`disallow' by bys byso bysor bysort bootstrap jacknife jknife"
	local disallow "`disallow' nestreg permute rolling simulate stepwise sw statsby"
	local moreprefs "T"
	while ( "`moreprefs'" == "T" ) {
		gettoken pref rest : statacmd, parse(" :,")
		if ( `"`pref'"' == "xi" ) {
			display as error `"xi not supported after mim; run xi: mim: ... instead"
			exit 198
		}
		local pos : list posof `"`pref'"' in disallow	// check for unsupported prefixes
		if ( `pos' > 0 ) {
			display as error `"prefix `pref' not allowed after mim"'
			exit 198
		}
		local pos : list posof `"`pref'"' in allow	// check for supported prefixes
		if ( `pos' > 0 ) {
			capture _on_colon_parse `statacmd'		// split remaining command line at colon
			local nextpref `"`s(before)'"'
			local statacmd `"`s(after)'"'
			local prefixes `"`prefixes' `nextpref':"'
			if ( `"`pref'"' == "svy" ) local svy "svy"
			else local ver "version"
		}
		else local moreprefs "F"
	}
	local prefixes : list retokenize prefixes

	// THEN DETERMINE THE CATEGORY THAT CMD BELONGS TO
	gettoken cmd cmdl : statacmd, parse(" ,")
	local 0 `"`mimcmdline'"'
	syntax [, CATegory(string) NOIsily * ]
	local cat `"`category'"'
	if ( `"`noisily'"' != "" ) local detail "detail"
	local othermimopts `"`options'"'
	if ( `"`cat'"' != "" ) {
		if ( "`cat'"' != "fit" & `"`cat'"' != "manip" & `"`cat'"' != "desc" & `"`cat'"' != "combine" ) {
			display as error "invalid category `cat'"
			exit 198
		}
	}
	else {
		local regress "reg regr regre regres regress"
		local logit "logi logit"
		local ologit "olog ologi ologit"
		local mlogit "mlog mlogi mlogit"
		local probit "prob probi probit"
		local oprobit "oprob oprobi oprobit"
		local fitcmds "`regress' `logit' `ologit' `mlogit' `probit' `oprobit'"
		local fitcmds "`fitcmds' mean proportion ratio"
		local fitcmds "`fitcmds' cnreg mvreg rreg"
		local fitcmds "`fitcmds' qreg iqreg sqreg bsqreg"
		local fitcmds "`fitcmds' logistic blogit clogit"
		local fitcmds "`fitcmds' glm binreg nbreg gnbreg poisson"
		local fitcmds "`fitcmds' stcox streg stpm"
		local fitcmds "`fitcmds' xtgee xtreg xtlogit xtnbreg xtpoisson xtmixed"
		local posofcmd : list posof "`cmd'" in fitcmds
		if ( `posofcmd' > 0 ) { // estimation command
			local cat "fit"
			local pos1 : list posof "`cmd'" in regress
			local pos2 : list posof "`cmd'" in logit
			local pos3 : list posof "`cmd'" in ologit
			local pos4 : list posof "`cmd'" in mlogit
			local pos5 : list posof "`cmd'" in probit
			local pos6 : list posof "`cmd'" in oprobit
			if ( `pos1' > 0 ) local cmd "regress"
			if ( `pos2' > 0 ) local cmd "logit"
			if ( `pos3' > 0 ) local cmd "ologit"
			if ( `pos4' > 0 ) local cmd "mlogit"
			if ( `pos5' > 0 ) local cmd "probit"
			if ( `pos6' > 0 ) local cmd "oprobit"
		}
		else if ( /// inbuilt utility command
			`"`cmd'"' == "check" | ///
			`"`cmd'"' == "genmiss" | ///
			`"`cmd'"' == "rubin" ///
		) local cat "util"
		else if ( /// post estimation command
			`"`cmd'"' == "predict" | ///
			`"`cmd'"' == "lincom" | ///
			`"`cmd'"' == "testparm" ///
		) local cat "pe"
		else if ( /// manipulation command
			`"`cmd'"' == "app" | ///
			`"`cmd'"' == "appe" | ///
			`"`cmd'"' == "appen" | ///
			`"`cmd'"' == "append" | ///
			`"`cmd'"' == "mer" | ///
			`"`cmd'"' == "merg" | ///
			`"`cmd'"' == "merge" | ///
			`"`cmd'"' == "reshape" ///
		) local cat "manip"
		else if ( /// descriptive command
			`"`cmd'"' == "ta" | ///
			`"`cmd'"' == "tab" | ///
			`"`cmd'"' == "tabu" | ///
			`"`cmd'"' == "tabul" | ///
			`"`cmd'"' == "tabula" | ///
			`"`cmd'"' == "tabulat" | ///
			`"`cmd'"' == "tabulate" ///
		) local cat "desc"
		else { // unrecognised command
			display as error "command `cmd' not recognised by mim; try specifying category option"
			exit 198
		}
	}

	// BLOCK SVY PREFIX IF COMMAND IS NON-ESTIMATION, AND BLOCK VERSION
	// PREFIX IF COMMAND IS A UTILITY COMMAND OR COMMAND IS TESTPARM
	if ("`svy'" != "" & "`cat'" != "fit" ) {
		display as error "svy prefix not allowed with `cmd'"
		exit 198
	}
	if ( "`ver'" != "" & ("`cat'" == "util" | "`cmd'" == "testparm") ) {
		display as error "version prefix not allowed with `cmd'"
		exit 198
	}

	// PROCESS REMAINING MIM OPTIONS
	if ( `"`othermimopts'"' != "" ) local 0 `", `othermimopts'"'
	else local 0 ""
	if ( `"`cat'"' == "fit" ) {
		local syntaxform "[, DOTs STorebv noclear LRR from(integer 1) to(integer 9999999) ]"
	}
	else if ( `"`cat'"' == "manip" & `"`cmd'"' != "append" & `"`cmd'"' != "reshape" ) {
		local syntaxform ", SOrtorder(passthru)"
	}
	else if ( `"`cat'"' == "combine" ) {
		local syntaxform ", est(string) [ se(string) BYVar ]"
	}
	else local syntaxform "[, _a_very_unlikely_mim_option]" // option improves error message
	syntax `syntaxform'

	if ( "`lrr'" != "" ) local lrr "lrr"

	// EXTRACT REPORTING OPTIONS FROM STATACMD (IF CMD IS A FIT OR POST ESTIMATION COMMAND)
	if ( "`cat'" == "fit" | "`cat'" == "pe" ) {
		gettoken first remaining : cmdl, parse(",")
		local newcmdline `"`first'"'
		while ( `"`remaining'"' != "" ) {
			local newcmdline `"`newcmdline' `next'"'
			gettoken next remaining : remaining, parse(",")
		}
		parsereportopts, cmd(`cmd') `next'
		local eformstr `"`s(eformstr)'"'
		local eformopt `"`s(eformopt)'"'
		local level `"`s(level)'"'
		local options `"`s(options)'"'

		// Remove eform options from cmdline, if necessary
		if ( `"`cmd'"' == "lincom" ) {
			local cmdl `"`newcmdline' `level' `options'"'
		}
	}

	// RUN CMD
	if ( "`cat'" == "util" ) `cmd' `cmdl'
	else if ( "`cat'" == "desc" ) desc, cmd(`"`cmd'"') cmdl(`"`cmdl'"') pr(`"`prefixes'"')
	else if ( "`cat'" == "manip" ) manip, cmd(`"`cmd'"') cmdl(`"`cmdl'"') pr(`"`prefixes'"') `sortorder' `detail'
	else if ( "`cat'" == "fit" ) {
		capture estimates drop _mim_ests*
*noi di in red `"fit, cmd(`cmd') cmdl(`"`cmdl'"') pr(`"`prefixes'"') `detail' `lrr' `dots' `clear' from(`from') to(`to')"'
		fit, cmd(`cmd') cmdl(`"`cmdl'"') pr(`"`prefixes'"') `detail' `lrr' `dots' `clear' from(`from') to(`to')
		if ( `"`storebv'"' != "" ) fit_handlebV, j(0) `clear'		// reshuffle into e(b), e(V)
		fit_display, cmd(`cmd') `level' `eformstr' `lrr'	// display combined estimates
	}
	else if ( "`cat'" == "pe" ) {
		if ( "`e(MIM_prefix2)'" != "mim" ) {
			display as error "last mim estimates not found"
			exit 301
		}
		if ( "`cmd'" == "lincom" ) milincom, cmdl(`"`cmdl'"') pr(`"`prefixes'"') `detail' `level' `eformopt'
		if ( "`cmd'" == "testparm" ) mitestparm, cmdl(`"`cmdl'"')
		if ( "`cmd'" == "predict" ) mipredict, cmdl(`"`cmdl'"') pr(`"`prefixes'"')
	}
	else if ( "`cat'" == "combine" ) {
		preserve
		qui keep if $S_MJ > 0
		if "`byvar'"=="" local engine statsby
		else local engine byvar
		display as txt _n "Applying Rubin's rules, using `engine' for analysis:"
		if "`byvar'"=="" {	// uses -statsby-
			if ( "`detail'" != "" ) local noisily "noisily"
			if `"`se'"' != "" {
				local statsby statsby est = (`est') se = (`se'), `noisily' by($S_MJ) nodots clear : `cmd' `cmdl'
				noi di as txt _n `"-> `statsby'"'
				`statsby'
				rubin_univariate est se, name(`est')
			}
			else {
				statsby est=`est', `noisily' by($S_MJ) nodots clear : `cmd' `cmdl'
				rubin_univariate est, name(`est')
			}
		}
		else {	// uses -byvar-
			if ( "`detail'" == "" ) local quietly "quietly"
			local letter1 = upper(substr("`est'", 1, 1))
			if `"`se'"' != "" {
				local letter2 = upper(substr("`se'", 1, 1))
				if "`letter1'" == "`letter2'" {
					local sesave `se'
					// parse and concatenate b(), r(), e() or se() inputs from est() and se()
					local 0 , `est'
					syntax [, b(string) se(string) e(string) r(string) ]
					foreach thing in b se e r {
						if "``thing''" != "" {
							local bseer `thing'
							local est ``thing''
							continue, break
						}
					}
					local bseersave `bseer'
					local 0 , `sesave'
					syntax , `bseer'(string)	// `bseer' is one of b, se, e or r
					local se ``bseer''
					local byvar byvar $S_MJ, `bseersave'(`est' `se') unique generate : `cmd' `cmdl'
					noi di as txt _n `"-> `byvar'"'
					`quietly' `byvar'
					local estvar `r(`letter1'_1)'
					local sevar `r(`letter1'_2)'
				}
				else {
					local byvar byvar $S_MJ, `est' `se' unique generate : `cmd' `cmdl'
					noi di as txt _n `"-> `byvar'"'
					`quietly' `byvar'
					local estvar `r(`letter1'_1)'
					local sevar `r(`letter2'_1)'
				}
				rubin_univariate `estvar' `sevar', name(`est')
			}
			else {
				`quietly' byvar $S_MJ, `est' unique generate : `cmd' `cmdl'
				local estvar `r(`letter1'_1)'
				rubin_univariate `estvar', name(`est')
			}
		}
		restore
	}
	// AND FINALLY CLEAR ANY S-MACROS SET BY MIM OR ITS SUBCOMMANDS
	sreturn clear
end
*--------------------------------------------------------------------------------------------------------
* subprogram parsereportopts
*--------------------------------------------------------------------------------------------------------
program define parsereportopts, sclass

	version 9.2

//	!! PR: note that -streg- reporting options are not yet handled correctly.

	syntax, cmd(string) [ * ]

	local 0 `", `options'"'
	if ( `"`cmd'"' == "glm" ) local levelform "LEvel(passthru)"
	else if ( `"`cmd'"' == "xtgee" ) local levelform "LEVel(passthru)"
	else local levelform "Level(passthru)"

	if ( `"`cmd'"' == "stcox" | `"`cmd'"' == "streg" ) {
		syntax [, `levelform' EFormstr(string) EForm noHR IRr or RRr rd COEFficients tr * ]
	}
	else {
		syntax [, `levelform' EFormstr(string) EForm hr IRr or RRr rd COEFficients * ]
	}
	if ( `"`coefficients'"' != "" ) local coef "coef"

	local eformopt `"`efromstr' `eform' `hr' `irr' `or' `rrr' `coef' `nohr' `tr'"'
	local wc : word count `eformopt'
	if ( `wc' > 1 ) {
		local eformopts : list retokenize eformopt
		display as error "`eformopts' not allowed together"
		exit 198
	}
	else if ( `"`eformstr'"' != "" ) local eformstr `"eformstr(`eformstr')"'
	else if ( `"`eform'"' != "" ) local eformstr `"eformstr("    exp(b)")"'
	else if ( `"`irr'"' != "" ) local eformstr `"eformstr("       IRR")"'
	else if ( `"`rrr'"' != "" ) local eformstr `"eformstr("       RRR")"'
	else if ( `"`rd'"' != "" )  local eformstr `"eformstr(" Risk Dif.")"'
	else if ( `"`tr'"' != "" )  local eformstr `"eformstr("Tim. ratio")"'
	else if ( `"`hr'"' == "hr" & `"`cmd'"' == "binreg" ) ///
		local eformstr `"eformstr("        HR")"'
	else if ( `"`hr'"' == "hr" | ( (`"`cmd'"' == "stcox" | `"`cmd'"' == "streg") & `"`hr'"' != "nohr" ) ) ///
		local eformstr `"eformstr(" Haz. Rat.")"'
	else if ( `"`or'"' != "" | ( `"`cmd'"' == "logistic" & `"`coef'"' == "" ) ) ///
		local eformstr `"eformstr(" Odds Rat.")"'
	else if ( `"`coef'"' != "" ) local eformstr

	sreturn local level `"`level'"'
	sreturn local eformopt `"`eformopt'"'
	sreturn local eformstr `"`eformstr'"'
	sreturn local options `"`options'"'
end
*--------------------------------------------------------------------------------------------------------
* subprogram chkvars
*--------------------------------------------------------------------------------------------------------
program define chkvars

	version 9.2

	capture confirm numeric variable $S_MJ
	if c(rc) {
		display as error "imputation identifier variable $S_MJ is either missing or not numeric"
		exit 498
	}
	capture confirm numeric variable $S_MI
	if c(rc) {
		display as error "observation identifier variable $S_MI is either missing or not numeric"
		exit 498
	}
end
*--------------------------------------------------------------------------------------------------------
* subprogram check
*--------------------------------------------------------------------------------------------------------
program define check

	version 9.2

	chkvars

	syntax [varlist]

	tempvar t1 t2
	foreach var of varlist `varlist' {
		local ffive = substr(`"`var'"',1,5)
		if ( `"`var'"' != "$S_MI" & `"`var'"' != "$S_MJ" & `"`ffive'"' != "_mim_" ) {
			display as text "." _cont
			capture drop _mim_`var'
			capture genmiss `var'
			if c(rc) {
				display // carriage return
				genmiss `var'
			}
			capture drop `t1'
			rename _mim_`var' `t1'
			sort $S_MI $S_MJ
			capture drop `t2'
			generate byte `t2' = 0
			quietly replace `t2' = ( `var'[_n-1] != `var'[_n] ) if $S_MJ != 0
			capture assert ( `t2' == 0 | `t1' == 1 )
			if c(rc) {
				display as error _n "non-imputed values in `var' differ across imputed datasets"
				exit 498
			}
		}
	}
	sort $S_MJ $S_MI
	display as text _n "PASS"
end
*--------------------------------------------------------------------------------------------------------
* subprogram genmiss
*--------------------------------------------------------------------------------------------------------
program define genmiss

	version 9.2

	syntax varname
	local var "`varlist'"

	// CHECK ID VARS AND EXISTENCE OF ORIGINAL DATA
	chkvars
	quietly levelsof $S_MJ, local(levels)
	local pos : list posof "0" in levels
	if ( `pos' == 0 ) {
		display as error "the current mim dataset does not contain the original data with missing values"
		exit 498
	}

	// CHECK THAT SPECIFIED VAR IS NOT COMPLETE
	quietly count if `var' >= .
	if ( r(N) == 0 ) {
		display as text "(`var' has no missing values)"
		quietly generate byte _mim_`var' = 0
		exit 0
	}
	
	// GENERATE MISSING INDICATOR VARIABLE
	tempvar tvar
	sort $S_MI
	quietly by $S_MI : egen `tvar' = count(`var')
	sort $S_MJ $S_MI
	quietly levelsof `tvar', local(levels)
	local wc : word count `levels'
	local min : word 1 of `levels'
	if ( `wc' == 2 ) {
		local max : word 2 of `levels'
		capture assert `max' - `min' == 1
		if c(rc) local err "error"
	}
	else local err "error"
	if ( "`err'" != "" ) {
		display as error "there is a problem with your mim dataset; possible causes are "
		display as error " - imputed copies of `var' still contain missing values"
		display as error " - imputed datasets contain differing numbers of observations"
		exit 498
	}
	quietly replace `tvar' = 1 if `tvar' == `min'
	quietly replace `tvar' = 0 if `tvar' == `max'
	recast byte `tvar'
	capture drop _mim_`var'
	rename `tvar' _mim_`var'
end
*--------------------------------------------------------------------------------------------------------
* subprogram desc
*--------------------------------------------------------------------------------------------------------
program define desc

	version 9.2

	syntax, ///
		CMD1(string)	/// descriptive command to apply
		[ ///
		CMDLine(string)	/// contents of command line following `cmd1'
		PRefixes(string)	/// contents of command line between mim: and `cmd1'
		]

	// CHECK ID VARS
	chkvars
	quietly levelsof $S_MJ, local(levels)

	// CHECK SYNTAX OF STATA COMMAND, AND EXTRACT USING FILENAME
	local 0 `"`cmdline'"'
	capture syntax [anything(equalok)] [if/] [in] [fw aw pw iw] [, *]
	if c(rc) {
		display as error "unsupported command syntax"
		exit 198
	}
	if ( `"`if'"' != "" ) local andif "& `if'"
	if ( `"`weight'"' != "" ) local weight `"[`weight' `exp']"'
	if ( `"`options'"' != "" ) local cmdopts `", `options'"'

	// APPLY CMD TO INDIVIDUAL DATASETS
	local remaining "`levels'"
	while ( "`remaining'" != "" ) {
		gettoken j remaining : remaining

		// DO CMD
		local docmd `"`prefixes' `cmd1' `anything' if $S_MJ==`j' `andif' `in' `weight' `cmdopts'"'
		local docmd : list retokenize docmd
		display as input `"-> `docmd'"'
		`docmd'
		display _n
	}
end
*--------------------------------------------------------------------------------------------------------
* subprogram manip
*--------------------------------------------------------------------------------------------------------
program define manip

	version 9.2

	syntax, ///
		CMD1(string)	/// manipulation command to apply
		[ ///
		CMDLine(string)	/// contents of command line following cmd
		PRefixes(string)	/// contents of command line between mim: and cmd
		Detail		/// display output of cmd at each iteration
		SOrtorder(string)	/// variables that uniquely identify the observations in
					/// each dataset POST manipulation of the mim dataset(s)
		]

	if ( "`detail'" != "" ) local noisily "noisily"

	// CHECK ID VARS
	chkvars
	quietly levelsof $S_MJ, local(levels)
	local m : word count `levels'

	// CHECK SYNTAX OF STATA COMMAND, AND EXTRACT USING FILENAME
	local 0 `"`cmdline'"'
	capture noisily syntax [anything(equalok)] [if] [in] [fw aw pw iw] [using/] [, *]
	if c(rc) {
		display as error "possibly unsupported manipulation command syntax"
		exit 198
	}
	if ( `"`weight'"' != "" ) local weight `"[`weight' `exp']"'
	if ( `"`using'"' != "" ) local mimusing `"`using'"'
	if ( `"`options'"' != "" ) local cmdopts `", `options'"'
	local cmdline `"`anything' `if' `in' `weight'"'

	// TEMPORARILY SAVE CURRENT DATASET, SO THAT INDIVIDUAL DATASETS CAN BE LOADED ONE AT A TIME
	tempfile mimmaster
	quietly save `"`mimmaster'"'

	// RATHER THAN PRESERVING CURRENT DATASET, MASTER WILL BE RELOADED MANUALLY If ERROR OCCURS
	capture noisily {

	// APPLY CMD TO INDIVIDUAL DATASETS
	gettoken cmd2 cmdline : cmdline, parse(" ,:")		// extract 2nd token for display purposes
	local cmd = trim("`cmd1' `cmd2'")				// eg. "reshape wide"
	local remaining "`levels'"
	while ( "`remaining'" != "" ) {
		gettoken j remaining : remaining

		// DECLARE NEXT TEMPORARY FILE AND EXTRACT NEXT USING DATASET, IF NECESSARY
		* tempfile tfile`j'
		local tfile`j' _mim_`j'
		if ( `j' == 0 ) {
			local dfile `"`tfile`j''"'
			local m = `m' - 1
		}
		else local ifiles `"`ifiles' `tfile`j''"'
		local N2 = -1
		if ( `"`mimusing'"' != "" ) {
			quietly use _all if $S_MJ == `j' using `"`mimusing'"'
			quietly count
			local N2 = r(N)
			if ( `"`cmd1'"' == "merge"  & `"`anything'"' != "" ) quietly sort `anything'
			else quietly sort $S_MI
			quietly drop $S_MJ $S_MI
			quietly save `"`tfile`j''"', replace
			local using `"using `tfile`j''"'
		}
		local usingdisplay "using $S_MJ == `j'"

		// EXTRACT NEXT MASTER DATASET
		quietly use _all if $S_MJ == `j' using `"`mimmaster'"'
		quietly count
		local N1 = r(N)
		if ( `"`cmd1'"' == "merge"  & `"`anything'"' != "" ) quietly sort `anything'
		else quietly sort $S_MI
		quietly drop $S_MJ $S_MI

		// DO CMD
		local statacmdtodisplay `"`prefixes' `cmd' `cmdline' `usingdisplay' `cmdopts'"'
		local statacmdtodisplay : list retokenize statacmdtodisplay
		capture `noisily' display as input `"-> `statacmdtodisplay'"'
		if ( `N1' == 0 ) display as error "(warning, master dataset has no observations for $S_MJ == `j')"
		if ( `N2' == 0 ) display as error "(warning, using dataset has no observations for $S_MJ == `j')"
		local statacmd `"`prefixes' `cmd' `cmdline' `using' `cmdopts'"'
		capture `noisily' `statacmd'
		if c(rc) {
			local rc = c(rc)
			if ( "`noisily'" == "" ) {
				display as input `"-> `statacmdtodisplay'"'
				capture noisily `statacmd'
			}
			exit `rc'
		}
		capture `noisily' display _n

		if ( `"`cmd1'"' == "append" | `"`estimates'"' != "" ) {
			quietly generate byte $S_MI = .
			quietly replace $S_MI = _n
		}

		// TEMPORARILY SAVE RESULT
		quietly save `"`tfile`j''"', replace
	}

	// STACK THE RESULTING TEMPORARY DATASETS INTO A NEW MIM DATASET
	if ( `"`cmd'"' == "append" | `"`estimates'"' != "" ) local sortorder "$S_MI"
	if ( `"`cmd'"' == "reshape long" ) local sortorder `"`_dta[ReS_i]' `_dta[ReS_j]'"'
	if ( `"`cmd'"' == "reshape wide" ) local sortorder `"`_dta[ReS_i]'"'
	if ( `"`dfile'"' != "" ) {
		local ifiles `"`dfile' `ifiles'"'
		local nomj0 ""
	}
	else local nomj0 "nomj0"
	mimstack, m(`m') `nomj0' ifiles(`"`ifiles'"') sortorder(`"`sortorder'"')

	// TIDY TEMPORARY DATA FILES
	local remaining "`levels'"
	while ( "`remaining'" != "" ) {
		gettoken j remaining : remaining
		cap erase `tfile`j''.dta
	}

	} // END OF CAPTURE NOISILY
	if c(rc) {
		local rc = c(rc)
		quietly use `"`mimmaster'"', clear 
		exit `rc'
	}
end
*--------------------------------------------------------------------------------------------------------
* subprogram fit, eclass
*--------------------------------------------------------------------------------------------------------
program define fit, eclass

	version 9.2

	syntax, ///
		CMD1(string)		/// estimation command to fit
		[ ///
		CMDLine(string)		/// contents of command line following cmd
		PRefixes(string)		/// prefixes between mim: and cmd
		LRR			/// instructs mim to use LRR method for constructing var/covar matrix
		FRom(integer 1)		/// fit from $S_MJ == `from'
		to(integer 9999999)	/// fit to $S_MJ == `to'
		Detail			/// display estimates from individual models
		DOTs				/// display dots during execution
		noclear			/// suppresses issue of ereturn clear
		]

	if ( `from' <= 0 | `to' <= 0 ) {
		display as error "from and to options must both be positive"
		exit 198
	}
	if ( "`detail'" != "" ) local noisily "noisily"
	if ( "`dots'" == "" ) local nodots "nodots"
	local cmd `"`cmd1'"'

	// CHECK ID VARS, AND DETERMINE LEVELS TO FIT
	chkvars
	quietly levelsof $S_MJ, local(temp)
	while ( `"`temp'"' != "" ) {
		gettoken next temp : temp
		if ( `next' >= `from' & `next' <= `to' ) local levels "`levels' `next'"
		if ( `next' >= `to' ) continue, break
	}
	// !! PR: note that setting `to' greater than the max value of $S_MJ does not raise an error - ignored
	local m : word count `levels'
	if ( `m' <= 1 ) {
		if ( `m' == 0 ) local s "s"
		if ( `to' != 9999999 ) local inrange `"in the range $S_MJ = `from' to $S_MJ = `to'"'
		display as error `"fitting a model to a mim dataset requires at least 2 imputations"'
		display as error `"your dataset has `m' imputation`s' `inrange'"'
		exit 198
	}

	// TEMPORARILY SAVE CURRENT DATASET, SO THAT INDIVIDUAL DATASETS CAN BE LOADED ONE AT A TIME
	sort $S_MJ $S_MI
	tempfile mimmaster
	quietly save `"`mimmaster'"'

	// RATHER THAN PRESERVING CURRENT DATASET, MASTER WILL BE RELOADED MANUALLY AT THE END
	capture noisily {

	// FIT INDIVIDUAL MODELS
	local eb
	local eV
	gettoken first : levels
	local remaining `"`levels'"'
	if c(stata_version) >= 10 {
		local tmpdir `c(tmpdir)'
		local dirsep `c(dirsep)'
		// Check last character of tmpdir - should be dirsep, if not, append.
		if substr("`tmpdir'", -1, 1) != "`dirsep'" local tmpdir `tmpdir'`dirsep'
	}
	while ( "`remaining'" != "" ) {
		gettoken j remaining : remaining
		quietly use _all if $S_MJ == `j' using `"`mimmaster'"', clear
		if ( `"`detail'"' == "" & "`nodots'" == "" ) {
			display as input "." _cont
			local cr "_n"
		}
		local estcmd `"$VV `prefixes' `cmd1' `cmdline'"'
		local estcmd : list retokenize estcmd
		capture `noisily' display as input "-> $S_MJ==`j'"
		capture `noisily' display as input "-> `estcmd'"
		capture `noisily' `estcmd'
		if c(rc) {
			local rc = c(rc)
			if ( "`noisily'" == "" ) {
				display as input `cr' `"-> $S_MJ==`j'"'
				display as input `"-> `estcmd'"'
				capture noisily `estcmd'
			}
			exit `rc'
		}
		capture `noisily' display _n

		// Capture data for combined results
		* tempfile tfile`j'
		local tfile`j' _mim_`j'
		tempname b`j' V`j'
		matrix `b`j'' = e(b)
		matrix `V`j'' = e(V)
		matrix _mim_b`j' = `b`j''
		matrix _mim_V`j' = `V`j''
		local colnames : colnames `b`j''
		local eb `eb' `b`j''		// list of names of matrices containing the e(b)'s
		local eV `eV' `V`j''		// list of names of matrices containing the e(V)'s
		local N = e(N)
		if ( `j' == `first' ) {
			local firstcolnames `"`colnames'"'
			local Nmin = `N'
			local Nmax = `N'
			local prefix "`e(prefix)'"
			local depvar "`e(depvar)'"
			local properties "`e(properties)'"
			local title "`e(title)'"
			local eform "`e(eform)'"
			local nucom "`e(df_r)'"		// complete-data residual degrees of freedom
			if ( `"`nucom'"' == "" ) local nucom = -1
		}
		else {
			local test : list colnames == firstcolnames
			if ( `test' == 0 ) {
				display as error `"covariates in analysis of imputed dataset `j' do not match those of imputed dataset `first'"'
				exit 498
			}
			if ( `Nmin' > `N' ) local Nmin = `N'
			if ( `Nmax' < `N' ) local Nmax = `N'
		}

		// Capture changes to this dataset by the estimation cmd, and generate _mim_e
		capture drop _mim_e
		quietly generate byte _mim_e = e(sample)

		// Store individual estimates and datasets
		if (c(stata_version) >= 10) & ("`:char _dta[mim_ests]'" != "memory") {
			local estfile `tmpdir'_mim_ests`j'.ster
			capture erase `"`estfile'"'
			quietly estimates save `"`estfile'"'
		}
		else {
			local estname _mim_ests`j' 
			quietly estimates store `estname'
		}
		quietly save `"`tfile`j''"', replace
	}
	// Add changes to fitted datasets back to original MIM dataset
	local remaining `"`levels'"'
	gettoken j remaining : remaining
	quietly use `"`tfile`j''"', clear
	while ( `"`remaining'"' != "" ) {
		gettoken j remaining : remaining
		quietly append using `"`tfile`j''"'
		capture erase `"`tfile`j''.dta"'
	}
	sort $S_MJ $S_MI
	capture drop _mim_merge
	quietly merge $S_MJ $S_MI using `"`mimmaster'"', _merge(_mim_merge)
	quietly drop _mim_merge
	sort $S_MJ $S_MI
	label variable _mim_e "MIM Tools variable : estimation subsample indicator"

	// CALCULATE COMBINED ESTIMATES
	tempname Q W B T dfvec dfmin dfmax TLRR r lambda r1 nu1 sumb sumV
	capture fit_combine, beta(`eb') v(`eV') b(`B') t(`T') q(`Q') w(`W') dfvec(`dfvec') min(`dfmin') max(`dfmax') ///
		tlrr(`TLRR') r(`r') lambda(`lambda') r1(`r1') nu1(`nu1') nucom(`nucom')
	local rc = c(rc)
	if `rc' != 0 {
		di as err "cannot combine estimates - maybe the requested model has no effective predictors"
		exit `rc'
	}

	// RETURN RESULTS
	if ( "`clear'" != "noclear" ) ereturn clear

	// combined results
	local inbV = -1
	local prefix2 "mim"
	local cscalars "r1 nu1 Nmin Nmax dfmin dfmax"
	local cmatrices "lambda r TLRR dfvec Q W B T"
	local cmacros "inbV m levels eform title properties depvar prefix2 prefix cmd"
	foreach scal of local cscalars {
		ereturn scalar MIM_`scal' = ``scal''
	}
	foreach mat of local cmatrices {
		ereturn matrix MIM_`mat' = ``mat'', copy
	}
	if ( `"`lrr'"' != "" ) {
			ereturn matrix MIM_V = `TLRR'
		}
		else {
			ereturn matrix MIM_V = `T'
	}
	local cmatrices "`cmatrices' V"
	ereturn local MIM_cscalars `"`cscalars'"'
	ereturn local MIM_cmatrices `"`cmatrices'"'
	ereturn local MIM_cmacros `"`cmacros'"'
	foreach mac of local cmacros {
		ereturn local MIM_`mac' `"``mac''"'
	}

	} // END OF CAPTURE NOISILY
	if c(rc) {
		local rc = c(rc)
		quietly use `"`mimmaster'"', clear
	}
	exit `rc'
end
*--------------------------------------------------------------------------------------------------------
* subprogram fit_combine
* Calculates combined estimates and degrees of freedom.
*--------------------------------------------------------------------------------------------------------
program define fit_combine

	version 9.2

	syntax, ///
		beta(string)	/// list of names of matrices containing the e(b)'s
		v(string)		/// list of names of matrices containing the e(V)'s
		q(string)		/// name of matrix to contain average of the e(b)'s 
		w(string)		/// name of matrix to contain average of the e(V)'s
		t(string)		/// name of matrix to contain total covariance estimate
		b(string)		/// name of matrix to contain between imputation covariance estimate
		dfvec(string)	/// name of matrix to contain estimated degrees of freedom
		min(string)		/// name of scalar to contain minimum of dfvec
		max(string)		/// name of scalar to contain maximum of dfvec
		tlrr(string)	/// name of matrix to contain LRR total covariance estimate
		r(string)		/// name of matrix to contain r
		lambda(string)	/// name of matrix to contain lambda
		r1(string)		/// name of scalar to contain r1
		nu1(string)		/// name of scalar to contain nu1
		[ nucom(integer -1) ///
		  remove(integer 0) /// jackknife mode: remove `remove'th imputation
		]
	// store col names and eqn names
	gettoken first : beta
	local cols : colnames `first'
	local eqns : coleq `first', quoted
	local eqns : subinstr local eqns "." "_", all	// replaces periods with underscores

	// Combine estimates and return various quantities
	if `remove'==0 {
		mata: combcalc("`beta'", "`v'", `nucom')
	}
	else {
		mata: combcalc("`beta'", "`v'", `nucom', "e(MIM_Q)", "e(MIM_W)", `remove')
	}
	matrix `dfvec' = r(dfvec)
	scalar `min' = r(min)
	scalar `max' = r(max)
	matrix `b' = r(b)
	matrix `q' = r(q)
	matrix `r' = r(r)
	matrix `t' = r(t)
	matrix `w' = r(w)
	matrix `lambda' = r(lambda)
	scalar `r1' = r(r1)
	scalar `nu1' = r(nu1)
	matrix `tlrr' = r(tlrr)

	// set matrix row and column names	
	matrix colnames `r' = `cols'
	matrix colnames `lambda' = `cols'
	matrix colnames `dfvec' = `cols'

	matrix colnames `q' = `cols'
	matrix rownames `t' = `cols'
	matrix colnames `t' = `cols'
	matrix rownames `b' = `cols'
	matrix colnames `b' = `cols'
	matrix rownames `w' = `cols'
	matrix colnames `w' = `cols'
	matrix rownames `tlrr' = `cols'
	matrix colnames `tlrr' = `cols'

	matrix coleq `q' = `eqns'
	matrix roweq `t' = `eqns'
	matrix coleq `t' = `eqns'
	matrix roweq `b' = `eqns'
	matrix coleq `b' = `eqns'
	matrix roweq `w' = `eqns'
	matrix coleq `w' = `eqns'
	matrix roweq `tlrr' = `eqns'
	matrix coleq `tlrr' = `eqns'
end
*--------------------------------------------------------------------------------------------------------
* subprogram fit_display_indiv
* This utility program displays the coefficient table when replaying individual estimates with mim.
*--------------------------------------------------------------------------------------------------------
program define fit_display_indiv

	version 9.2

	syntax, j(integer) CMD(string) [ level(passthru) eformstr(string) eformopt(string) ]

	if ( `j' <= 0 ) {
		display as error "j option must be positive"
		exit 198
	}
	local cmdstr = substr( `"`cmd'"', 1, 20 )
/*
	local cmdstr `"`cmd'"'
	if ( `"`e(MIM_1_prefix)'"' != "" ) local cmdstr `"`e(MIM_1_prefix)': `cmdstr'"'
	local cmdstr = substr( `"`cmdstr'"', 1, 20 )
*/
	if ( `"`eformstr'"' != "" ) local eformstr `"eform(`eformstr')"'
	if ( `"`level'"' != "" | `"`eformstr'"' != "" | `"`eformopt'"' != "" ) local comma ","

	display as text _n "Estimates (" as result `"`cmdstr'"' as text ") " _cont
	display as text "for imputed dataset $S_MJ = " as result `j'
	capture `cmd' `comma' `level' `eformopt'
	if ( _rc == 0 ) `cmd' `comma' `level' `eformopt'
	else {
		_coef_table_header
		_coef_table `comma' `level' `eformstr'
	}
	display _n
end
*--------------------------------------------------------------------------------------------------------
* subprogram fit_display
* This utility program displays the coefficient table for the combined estimates including the table
* preamble (note that the fit_display_table subprogram is used to display the table itself). The
* program asssumes that the combined estimates are currently in e().
*--------------------------------------------------------------------------------------------------------
program define fit_display

	version 9.2

	syntax, CMD(string) [ eformstr(string) level(passthru) LRR JAckknife(passthru) ]

	if ( `"`eformstr'"' != "" ) {
		local eform "eform"
		local tt `"`eformstr'"'
	}
	else local tt "     Coef."

	tempname Q vars df fmi
	local cmdstr `"`cmd'"'
	if ( `"`e(MIM_prefix)'"' != "" ) local cmdstr `"`e(MIM_prefix)': `cmdstr'"'
	local cmdstr = substr( `"`cmdstr'"', 1, 23 )
	local title `"`e(MIM_title)'"'
	local m = "`e(MIM_m)'"
	local depvar "`e(MIM_depvar)'"
	local Nmin = e(MIM_Nmin)
	local dfmin = e(MIM_dfmin)
	if ( `"`lrr'"' != "" ) {
		matrix `vars' = vecdiag( e(MIM_TLRR) )
		local lrrstr "Using Li-Raghunathan-Rubin estimate of VCE matrix"
	}
	else {
		matrix `vars' = vecdiag( e(MIM_T) )
		*local lrrstr "Using standard Rubin estimate of VCE matrix"
	}
	matrix `Q' = e(MIM_Q)
	matrix `df' = e(MIM_dfvec)
	matrix `fmi' = e(MIM_lambda)

	// DISPLAY HEADER
*	if "`jackknife'"=="" {
		display ///
		   as text _n "Multiple-imputation estimates (" as result `"`cmdstr'"' as text ")" ///
		  _col(58) as text "Imputations = " as result %7.0g `m'
		display ///
		  as text `"`title'"' ///
		  _col(58) as text "Minimum obs = " as result %7.0g `Nmin'
		display ///
		  as text `"`lrrstr'"' ///
		  _col(58) as text "Minimum dof = " as result %7.1f `dfmin' _n
*	}
*	else {
	if "`jackknife'"!="" display as text ///
	 "[Values displayed beneath estimates are Monte Carlo jackknife standard errors]"

	// DISPLAY COEFFICIENT TABLE
	fit_display_table, cmd(`cmd') q(`Q') vars(`vars') dof(`df') fmi(`fmi') tt(`tt') ///
	  depvar(`depvar') `level' `eform' `multi' `jackknife'
end
*--------------------------------------------------------------------------------------------------------
* subprogram fit_display_table
* This utility program provides an ereturn display function for combined estimation results. The names
* for the matrices containing the vector of point estimates, variances and dof are passed in the q, vars
* and dof options. The name of the estimation command used by fit is passed in the cmd1 option, with
* the corresponding depvar name in the depvar option. The level option works in the usual way, and the
* eform option selects exponentiated coefficients. The title to use for the coefficient column is passed
* in the tt option, and the multi option selects multiple equation model display.
*--------------------------------------------------------------------------------------------------------
program define fit_display_table

	version 9.2

	syntax, ///
		CMD1(string)			/// Stata command
		q(string)				/// MI estimates
		vars(string)			/// Vars in model
		dof(string)				/// MI degrees of freedom
		fmi(string)				/// fraction of missing information
		tt(string)				/// title for coefficient column
		[ ///
		depvar(string)			/// some Stata 9 commands (eg. proportion) do not return this
		Level(integer `c(level)')	///
		eform					///
		multi					/// use multiple equation display mode
		jackknife(string)		/// string contains matrix of jackknife MC errors from mim_jackknife
		]

	if ( `level'<10 | `level'>99 ) {
		display as error "level must be between 10 and 99 inclusive"
		exit 198
	}

	// DISPLAY COEFFICIENT TABLE HEADER
	local t0 = abbrev("`depvar'",12)
	display as text "{hline 13}{c TT}{hline 64}"
	#delimit ;
	display as text
	%12s "`t0'" _col(14)"{c |}" %10s "`tt'" "  Std. Err.     t    P>|t|    [`level'% Conf. Int.]     FMI"
	_n "{hline 13}{c +}{hline 64}" ;
	#delimit cr

	// CALCULATE AND DISPLAY RESULTS FOR COEFFICIENT TABLE
	tempname df mn se t p invt l u FMI
	if "`jackknife'"!="" tempname mnj sej lj uj


	// extract display information from matrix of point estimates
	local k = colsof(`q')
	local xs : colnames `q'
	local xeqs : coleq `q', quoted
	local feq : word 1 of `xeqs'					// first equation name

	// check if model has multiple equations			// this does not overide multi option
	forvalues i=1/`k' {
		local eq : word `i' of `xeqs'
		local var : word `i' of `xs'
		if ( `"`eq'"' != `"`feq'"' & `"`var'"' != "_cons" ) local multi "multi"
	}

	// display table
	forvalues i=1/`k' {

		// get next var and eq names
		if ( `i' != 1 ) local lvar `"`var'"'		// previous var name
		else local lvar : word 1 of `xs'
		local var : word `i' of `xs'				// next var name 
		if ( `i' != 1 ) local leq `"`eq'"'			// previous equation name
		else local leq `"`feq'"'
		local eq : word `i' of `xeqs'				// next equation name

		// determine name to display for next var
		if ( `"`multi'"' == "" & `"`eq'"' != `"`leq'"' ) local vname `"/`eq'"'
		else local vname `"`var'"'

		// display row separator, if necessary
		// this occurs upon change of equation name for multiple equation models,
		// and on first change in equation name otherwise
		if ( ///
			( `"`eq'"' != `"`leq'"' & `"`multi'"' != "" ) | ///
			( `"`eq'"' != `"`leq'"' & `"`leq'"' == `"`feq'"' ) ///
		) display as text "{hline 13}{c +}{hline 64}"

		// display equation name, if multiple equation model
		if ( `"`multi'"' != "" & ( `"`eq'"' != `"`leq'"' | `i' == 1 ) ) {
			display as result %-12s abbrev(`"`eq'"', 12) as text _col(14)"{c |}" 
		}

		// display next coefficient row, if necessary
		// this occurs provided that var is not "_cons", or
		// var is "_cons" but eform is not selected, or
		// var is "_cons" and eform is selected, but model is not multi equation and current eq is not the same as the first
		if ( `"`var'"' != "_cons" | `"`eform'"' == "" | ( `"`multi'"' == "" & `"`eq'"' != `"`feq'"' ) ) {

			// calculate p-value and CI for this coefficient
			scalar `df' =`dof'[1,`i']
			scalar `FMI' = `fmi'[1,`i']
			scalar `mn' = `q'[1,`i']
			scalar `se' = sqrt(`vars'[1,`i'])
			scalar `t' = `mn'/`se'
/*
	!! PR 17may2013: fix up `df' bug; if too large, `p' and CI are missing.
*/
*			scalar `p' = 2* ttail(min(`df', 2e17), abs(`t'))
			scalar `p' = 2* ttail(`df', abs(`t'))
*			scalar `invt' = invttail(min(`df', 2e17), (1-`level'/100)/2)
			scalar `invt' = invttail(`df', (1-`level'/100)/2)
			scalar `l' = `mn' - `invt'*`se'
			scalar `u' = `mn' + `invt'*`se'

			// transform to exp values, if necessary
			if ( `"`eform'"' != "" ) {
				scalar `mn' = exp(`mn')
				scalar `se' = `mn'*`se'
				scalar `l' = exp(`l')
				scalar `u' = exp(`u')
	 		}

			// sort out display format for coefficient variable type
			capture confirm variable `var'
			if ( _rc == 0 & "`var'" != "_cons" ) {
				local fmt : format `var'
				if ( substr("`fmt'",-1,1) == "f" ) local fmt = "%8."+substr("`fmt'",-2,2)
				else if ( substr("`fmt'",-2,2) == "fc" ) local fmt = "%8."+substr("`fmt'",-3,3)
				else local fmt "%8.0g"
				local fmt`i' `fmt'
			}
			else local fmt "%8.0g"

			// display next line
			if ( "`jackknife'" != "" ) & ( `i' > 1 ) display _col(14) as text "{c |}"

			local tp `"_col(36) %7.2f `t' _col(44) %7.3f `p'"'
			if ( `"`cmd1'"' == "ologit" & `"`var'"' == "_cons" ) local tp
			if ( `"`cmd1'"' == "oprobit" & `"`var'"' == "_cons" ) local tp
			if ( `"`cmd1'"' == "cnreg" & `"`var'"' == "_cons" & `"`eq'"' != `"`feq'"' ) local tp
			if ( `"`cmd1'"' == "nbreg" & `"`var'"' == "_cons" & `"`eq'"' != `"`feq'"' ) local tp
			if ( `"`cmd1'"' == "gnbreg" & `"`var'"' == "_cons" & `"`eq'"' != `"`feq'"' ) local tp
			if ( `"`cmd1'"' == "xtreg" & `"`var'"' == "_cons" & `"`eq'"' != `"`feq'"' ) local tp
			if ( `"`cmd1'"' == "xtlogit" & `"`var'"' == "_cons" & `"`eq'"' != `"`feq'"' ) local tp
			if ( `"`cmd1'"' == "xtnbreg" & `"`var'"' == "_cons" & `"`eq'"' != `"`feq'"' ) local tp
			if ( `"`cmd1'"' == "xtpoisson" & `"`var'"' == "_cons" & `"`eq'"' != `"`feq'"' ) local tp
			if ( `"`cmd1'"' == "xtmixed" & `"`var'"' == "_cons" & `"`eq'"' != `"`feq'"' ) local tp
			display ///
			   as text %12s abbrev("`vname'",12) ///
			  _col(14) "{c |}" ///
			  _col(17) as result `fmt' `mn' ///
			  _col(27) `fmt'   `se' ///
			  `tp' ///
			  _col(54) `fmt'   `l' ///
			  _col(63) `fmt'   `u' ///
			  _col(72) %7.3f `FMI'

			if "`jackknife'"!="" {
				scalar `mnj' = `jackknife'[1,`i']
				scalar `sej' = `jackknife'[2,`i']
				scalar `t'   = `jackknife'[3,`i']
				scalar `p'   = `jackknife'[4,`i']
				scalar `lj'  = `jackknife'[5,`i']
				scalar `uj'  = `jackknife'[6,`i']
				scalar `FMI' = `jackknife'[7,`i']

				// transform to exp values, if necessary
				if ( `"`eform'"' != "" ) {
					scalar `mnj' = `mnj' * `mn'
					scalar `sej' = `jackknife'[8,`i']
					scalar `lj' = `lj' * `l'
					scalar `uj' = `uj' * `u'
		 		}
				if `"`tp'"'!="" local tp `"_col(36) %7.2f `t' _col(45) %6.0g `p'"'
				display ///
				  _col(14) as text "{c |}" ///
				  _col(17) as result `fmt' `mnj' ///
				  _col(27) `fmt'   `sej' ///
				  `tp' ///
				  _col(54) `fmt'   `lj' ///
				  _col(63) `fmt'   `uj' ///
				  _col(72) %7.3f `FMI'
			}
		}
	}

	* DISPLAY COEFFICIENT TABLE FOOTER
	display as text "{hline 13}{c BT}{hline 64}"
	display as text ""
end
*--------------------------------------------------------------------------------------------------------
* subprogram fit_handlebV
* This utility program handles placing mim estimates into e(b), e(V) and clearing them. The other e()
* results returned by mim.fit are left intact. If j == -1, then e(b), e(V) are cleared. If j == 0, then
* combined estimates are placed into e(b), e(V). Otherwise estimates from jth imputed dataset are placed
* in e(b), e(V).
*--------------------------------------------------------------------------------------------------------
program define fit_handlebV, eclass
	version 9.2
	syntax, j(integer) [ noclear noprefix ]
	local levels  `"`e(MIM_levels)'"'
	local posofj : list posof "`j'" in levels
	if ( `j' > 0 & `posofj' == 0 ) {
		display as error "j must be one of `e(MIM_levels)'"
		exit 198
	}
	if ( `j' == `e(MIM_inbV)' ) exit 0				// nothing to do

	// TEMPORARILY HOLD EXISTING COMBINED ESTIMATES
	local cscalars `"`e(MIM_cscalars)'"'
	local cmatrices `"`e(MIM_cmatrices)'"'
	local cmacros `"`e(MIM_cmacros)'"'
	foreach scal of local cscalars {
		tempname MIM_`scal'
		scalar `MIM_`scal'' = e(MIM_`scal')
	}
	foreach mat of local cmatrices {
		tempname MIM_`mat'
		matrix `MIM_`mat'' = e(MIM_`mat')
	}
	foreach mac of local cmacros {
		local MIM_`mac' `"`e(MIM_`mac')'"'
	}

	// CLEAR PREVIOUS ESTIMATES
	if ( "`clear'" != "noclear" ) ereturn clear

	// POST RESULTS INTO e(b) AND e(V)
	tempname b V
	gettoken first : levels
	if c(stata_version) >= 10 {
		local tmpdir `c(tmpdir)'
		local dirsep `c(dirsep)'
		// Check last character of tmpdir - should be dirsep, if not, append.
		if substr("`tmpdir'", -1, 1) != "`dirsep'" local tmpdir `tmpdir'`dirsep'
	}
	if ( `j' == 0 ) {
		// post combined estimates into e(b), e(V)
		matrix `b' = `MIM_Q'
		matrix `V' = `MIM_V'
		local depname `"`MIM_depvar'"'
		local N = `MIM_Nmin'
		local df_r = `MIM_dfmin'
		local dof "dof(`df_r')"
		local properties `"`MIM_properties'"'
		// !! PR: saving _mim_e to e(sample)
		tempvar touse
		confirm var _mim_e
		gen byte `touse' = cond(missing(_mim_e), 0, _mim_e)
		ereturn post `b' `V', depname(`"`depname'"') obs(`N') `dof' properties(`properties') `clear' ///
		 esample(`touse')
		ereturn local title `"`MIM_title'"'
		ereturn local properties `"`MIM_properties'"'
		ereturn local depvar `"`MIM_depvar'"'
		ereturn local prefix2 "mim"
		ereturn local prefix `"`MIM_prefix'"'
	}
	if ( `j' > 0 ) {
		if (c(stata_version) >= 10) & ("`:char _dta[mim_ests]'" != "memory")  {
			local estfile `tmpdir'_mim_ests`j'.ster
			estimates use `"`estfile'"'
			estimates esample: if $S_MJ == `j'
		}
		else {
			local estname _mim_ests`j'
			qui estimates restore `estname'
		}
	}

	// UPDATE INDICATOR OF WHICH RESULTS ARE IN e(b), e(V)
	local MIM_inbV `"`j'"'

	// RETURN COMBINED ESTIMATES IN THEIR DEFAULT LOCATION
	foreach scal of local cscalars {
		ereturn scalar MIM_`scal' = `MIM_`scal''
	}
	foreach mat of local cmatrices {
		ereturn matrix MIM_`mat' = `MIM_`mat''
	}
	ereturn local MIM_cscalars `"`cscalars'"'
	ereturn local MIM_cmatrices `"`cmatrices'"'
	ereturn local MIM_cmacros `"`cmacros'"'
	foreach mac of local cmacros {
		ereturn local MIM_`mac' `"`MIM_`mac''"'
	}

	// FINALLY, RETURN CMD
	if ( `j' == 0 ) ereturn local cmd `"`MIM_cmd'"'
	if "`prefix'" == "noprefix" {
		ereturn local prefix
		if c(stata_version) >= 10 {
			estimates esample: if _mim_e == 1
		}
	}
	else ereturn local prefix "mim"
end
*--------------------------------------------------------------------------------------------------------
* subprogram milincom, rclass
* This program implements an mi version of lincom.
*--------------------------------------------------------------------------------------------------------
program define milincom, rclass
	version 9.2
	// GET DETAILS FROM MIM ESTIMATES
	local levels `"`e(MIM_levels)'"'
	local m : word count `levels'
	local cmd `"`e(MIM_cmd)'"'
	local depvar `"`e(MIM_depvar)'"'
	local inbV `"`e(MIM_inbV)'"'
/*
	lincom following logistic is not correct due to anomalous way
	Stata handles it. Must go via logit then lincom, or.
*/
	if "`cmd'" == "logistic" {
		noi di as error "lincom after logistic is not supported. To obtain lincom on odds ratio scale,"
		noi di as error "estimate model using " as input "mim: logit ... , or" ///
		 as error " and then run " as input "mim: lincom <exp>, or" as  error
		exit 198
	}

	syntax [, CMDLine(string) PRefixes(string) Detail Level(passthru) EForm or hr IRr RRr ]

	if ( `"`detail'"' != "" ) local noisily "noisily"
	local wc : word count `eform' `or' `hr' `irr' `rrr'
	if ( `wc' > 1 ) {
		local options `"`eform' `or' `hr' `irr' `rrr'"'
		local options : list retokenize options
		display as error "options `options' not allowed together"
		exit 198
	}
	else if ( `wc' == 1 | `"`cmd'"' == "logistic" )  {
		if ( "`eform'" != "" ) local tt "    exp(b)"
		if ( "`or'" != "" ) local tt " Odds Rat."
		if ( "`hr'" != "" ) local tt " Haz. Rat."
		if ( "`irr'" != "" ) local tt "       IRR"
		if ( "`rrr'" != "" ) local tt "       RRR"
		local eform "eform"
	}
	else local tt "    Coeff."

	gettoken token rest : cmdline, parse(",= ")
 	while ( `"`token'"' != "" & `"`token'"' != "," ) {
		if ( `"`token'"' == "=" ) {
			display as error _quote "=" _quote " not allowed in expression"
			exit 198
		}
		local lc `"`lc'`token'"'				// note, lc is used for display of results
		gettoken token rest : rest, parse(",= ")
	}

	// TAKE LINEAR COMBINATIONS FOR INDIVIDUAL MODELS
	tempname b se
	local eb
	local eV
	gettoken first : levels
	local remaining `"`levels'"'
	while ( `"`remaining'"' != "" ) {
		gettoken j remaining : remaining
		tempname Q`j'				// to hold coefficient estimate for jth lincom
		tempname V`j'				// to hold variance of Q`j'
		local eb `eb' `Q`j''			// list of names of matrices holding coeff estimates
		local eV `eV' `V`j''			// list of names of matrices holding covar estimates
		capture `noisily' display as input `"-> mim, j(`j')"'
		fit_handlebV, j(`j') 			// put individual estimates in e(b) eV) etc.
		capture `noisily' display as input `"-> `prefixes' lincom `cmdline'"'
		capture `noisily' `prefixes' lincom `cmdline'
		if c(rc) {
			local rc = c(rc)
			if ( `"`noisily'"' == "" ) {
				capture noisily display as input `"-> mim, j(`j')"'
				capture noisily display as input `"-> `prefixes' lincom `pecmd'"'
				capture noisily `prefixes' lincom `cmdline'
			}
			fit_handlebV, j(`inbV') 	// restore estimates
			exit `rc'
		}
		scalar `b' = r(estimate)
		scalar `se' = r(se)
		matrix `Q`j'' = J( 1, 1, `b' )
		matrix rownames `Q`j'' = (1)
		matrix colnames `Q`j'' = (1)
		matrix `V`j'' = J( 1, 1, `se'^2 )
		matrix rownames `V`j'' = (1)
		matrix colnames `V`j'' = (1)
	}

	// CALCULATE COMBINED RESULTS
	tempname Q W B T dfvec dfmin dfmax TLRR r lambda r1 nu1
	fit_combine, beta(`eb') v(`eV') b(`B') t(`T') q(`Q') w(`W') dfvec(`dfvec') min(`dfmin') max(`dfmax') ///
		tlrr(`TLRR') r(`r') lambda(`lambda') r1(`r1') nu1(`nu1')

	// DISPLAY RESULTS
	local pos = 79 - length("Imputations = `m'")
	display ///
		as text _n "Multiple-imputation estimates for lincom" ///
		as text _col(`pos') "Imputations = " as result `m'
	test `lc' = 0, notest
	display // blank line
	// !! PR bug fix 22/6/09: fmi stoed in `lambda' not in `r'
*	fit_display_table, q(`Q') vars(`T') dof(`dfvec') fmi(`r') cmd(`cmd') tt("`tt'") depvar(`depvar') `level' `eform'
	fit_display_table, q(`Q') vars(`T') dof(`dfvec') fmi(`lambda') cmd(`cmd') tt("`tt'") depvar(`depvar') `level' `eform'
	// RESTORE ESTIMATES
	fit_handlebV, j(`inbV')

	// RETURN RESULTS
	tempname df
	scalar `b' = `Q'[1,1]
	scalar `se' = sqrt(`T'[1,1])
	scalar `df' = `dfvec'[1,1]
	return matrix MIM_Q = `Q'
	return matrix MIM_T = `T'
	return matrix MIM_B = `B'
	return matrix MIM_W = `W'
	return matrix MIM_dfvec = `dfvec'
	return scalar df = `df'
	return scalar se = `se'
	return scalar estimate = `b'
	global S_1 = `b'
	global S_2 = `se'
	global S_3 = `df'
end
*--------------------------------------------------------------------------------------------------------
* subprogram mitestparm, rclass
* This program implements an mi version of testparm. It performs an approximate F-test (Li, Raghunathan
* and Rubin 1991) to test the hypothesis that the specified coefficients are all equal to zero, analogous
* to the standard Wald test. The test statistic, p-value and approximate degrees of freedom are returned
* in r().
*--------------------------------------------------------------------------------------------------------
program define mitestparm, rclass
	version 9.2

	syntax [, CMDLine(string) ]
	local 0 `"`cmdline'"'
	syntax varlist

	// GET DETAILS FROM LAST MIM ESTIMATES
	local levels `"`e(MIM_levels)'"'
	local m : word count `levels'
	local remaining `"`levels'"'
	while ( `"`remaining'"' != "" ) {
		gettoken j remaining : remaining
		local bind`j' _mim_b`j'
        local Vind`j' _mim_V`j'
	}

	// EXTRACT COLUMN NUMBERS AND NAMES FOR VARS IN VARLIST INCLUDED IN FITTED MODEL
	local first : word 1 of `levels'
	local k = 0
	local colnames
	foreach var of varlist `varlist' {
		if ( colnumb(`bind`first'', "`var'") < . ) {	// if `var' was included in fitted model
			local k = `k' + 1
			local var`k' = colnumb(`bind`first'',"`var'")
			local colnames "`colnames' `var'"
		}
	}
	if ( `k' == 0 ) {
		display as error "varlist does not contain any covariates from the last fitted model"
		exit 198
	}

	// EXTRACT COEFFICIENT SUBVECTORS
	local rownames : rownames `bind`first''
	local remaining `"`levels'"'
	while ( `"`remaining'"' != "" ) {
		gettoken j remaining : remaining
		tempname b`j'
		matrix `b`j'' = J(1,`k',0)				// 1-by-`k' matrix of all zeros 
		forvalues c = 1/`k' {
			matrix `b`j''[1,`c'] = `bind`j''[1,`var`c'']
		}
		matrix rownames `b`j'' = `rownames'
		matrix colnames `b`j'' = `colnames'
	}

	// EXTRACT COVARIANCE SUBMATRICES
	local remaining `"`levels'"'
	while ( `"`remaining'"' != "" ) {
		gettoken j remaining : remaining
		tempname V`j'
		matrix `V`j'' = J(`k',`k',0)
		forvalues r = 1/`k' {
			forvalues c = 1/`k' {
				matrix `V`j''[`r',`c'] = `Vind`j''[`var`r'',`var`c'']
			}
		}
		matrix rownames `V`j'' = `colnames'			// not an error; it should equal `colnames'
		matrix colnames `V`j'' = `colnames'
	}

	// CALCULATE AVERAGE OF COEFFICIENT SUBVECTORS
	tempname matsum Qbar
	matrix `matsum' = J(1,`k',0)					// set `matsum' to 1xk zero matrix 
	local remaining `"`levels'"'
	while ( `"`remaining'"' != "" ) {
		gettoken j remaining : remaining
		matrix `matsum' = `matsum' + `b`j''
	}
	matrix `Qbar' = 1/`m'*`matsum'
	matrix rownames `Qbar' = `rownames'
	matrix colnames `Qbar' = `colnames'

	// CALCULATE SUBMATRIX WITHIN IMPUTATION VARIANCE
	tempname Ubar
	matrix `matsum' = J(`k',`k',0) 				// set `matsum' to kxk zero matrix
	local remaining `"`levels'"'
	while ( `"`remaining'"' != "" ) {
		gettoken j remaining : remaining
		matrix `matsum' = `matsum' + `V`j''
	}
	matrix `Ubar' = 1/`m'*`matsum'

	// CALCULATE SUBMATRIX BETWEEN IMPUTATION VARIANCE
	tempname B
	matrix `matsum' = J(`k',`k',0) 				// Set `matsum' to kxk zero matrix
	local remaining `"`levels'"'
	while ( `"`remaining'"' != "" ) {
		gettoken j remaining : remaining
		matrix `matsum' = `matsum' + (`b`j'' - `Qbar')'*(`b`j'' - `Qbar')
	}
	matrix `B' = 1/(`m'-1)*`matsum'

	// CALCULATE TOTAL SUBMATRIX VARIANCE ESTIMATE
	tempname Ubarinv BUbarinv Ttilde
	matrix `Ubarinv' = inv(`Ubar')
	matrix `BUbarinv' = `B'*`Ubarinv'
	local r = (1+(1/`m'))*trace(`BUbarinv')/`k'
	matrix `Ttilde' = (1+`r')*`Ubar'

	// CALCULATE TEST STATISTIC
	tempname Q0 Qdiff Ttildeinv D
	matrix `Q0' = J(1,`k',0)
	matrix `Qdiff' = `Qbar' - `Q0'
	matrix `Ttildeinv' = inv(`Ttilde')
	matrix `D' = `Qdiff'*`Ttildeinv'*`Qdiff''/`k'		// `D' is 1-by-1 matrix, not a scalar
	local dee = `D'[1,1]
*	if ( `dee' >= 1000 ) local dee 1000			// upper limit on F-statistic

	// CALCULATE APPROXIMATE DEGREES OF FREEDOM
	local a = `k'*(`m'-1)
	if ( `a' > 4 ) local df = 4 + (`a'-4)*(1+(1- 2/`a')/`r')^2
	else local df = `a'*(1+1/`k')*(1+1/`r')^2/2
*	if ( `df' >= 1000 ) local df = 1000				// upper limit on degrees of freedom
	local df = min(`df', 2e17)

	// CALCULATE P-VALUE FROM F DISTRIBUTION
	local p = Ftail(`k', `df', `dee')
*noi di in red "k=" `k' " df=" `df'

	// DISPLAY RESULTS
	display // blank line
	local k 0
	foreach var of varlist `colnames' {
		local ++k
		display as text " ( `k')" as result "  `var' = 0"
	}
	display // blankline
	display as text "       F(" %3.0f `k' "," %6.1f `df' ") =" as result %8.2f `dee'
	display as text _col(13) "Prob > F =" as result %10.4f `p'

	// RETURN RESULTS
	return scalar p = `p'
	return scalar df = `k'
	return scalar F = `dee'
	return scalar df_r = `df'
end
*--------------------------------------------------------------------------------------------------------
* subprogram mipredict
* This program implements a simple mi version of predict.
*--------------------------------------------------------------------------------------------------------
program define mipredict
	version 9.2

	syntax [, CMDLine(string) PRefixes(string) ]

	local 0 `"`cmdline'"'
	syntax newvarlist(min=1 max=1) [, stdp EQuation(passthru) *]
	local var : word 1 of `varlist'

	chkvars
	quietly levelsof $S_MJ, local(all)
	local pos : list posof "0" in all
	if ( `pos' == 0 ) {
		display as error "original dataset ($S_MJ==0) is required for prediction with mim"
		exit 498
	}

	tempvar t1_ind t1_all
	quietly generate `t1_all' = .
	if ( `"`stdp'"' != "" ) {
		tempvar t2_ind t2_all
		quietly generate `t2_all' = .
	}
	local inbV `"`e(MIM_inbV)'"'
	local levels `"`e(MIM_levels)'"'
	local remaining `"`levels'"'

	tempname esthold
	// need to ensure have e(b), e(V) else _estimates hold fails
	if `inbV' == -1 quietly mim, storebv
	_estimates hold `esthold'
	if c(stata_version) >= 10 {
		local tmpdir `c(tmpdir)'
		local dirsep `c(dirsep)'
		// Check last character of tmpdir - should be dirsep, if not, append.
		if substr("`tmpdir'", -1, 1) != "`dirsep'" local tmpdir `tmpdir'`dirsep'
	}
	while ( "`remaining'" != "" ) {
		gettoken j remaining : remaining
		if (c(stata_version) >= 10) & ("`:char _dta[mim_ests]'" != "memory")  {
			local estfile `tmpdir'_mim_ests`j'.ster
			estimates use `"`estfile'"'
			estimates esample: if $S_MJ == `j'
		}
		else {
			local estname _mim_ests`j'
			qui estimates restore `estname'
		}
		capture drop `t1_ind'
		quietly `prefixes' predict `t1_ind' if $S_MJ == `j', `equation' `options'
		quietly replace `t1_all' = `t1_ind' if $S_MJ == `j'
		if ( `"`stdp'"' != "" ) {
			capture drop `t2_ind'
			quietly `prefixes' predict `t2_ind' if $S_MJ == `j', stdp `equation' `options'
			quietly replace `t2_all' = `t2_ind' if $S_MJ == `j'
		}
	}
	_estimates unhold `esthold'			// restore estimates
	if `inbV' == -1 quietly mim, clearbv

	// calculate predicted values for original data by combining predicted values
	// for imputed datasets using Rubin's rules
	rubin `t1_all' `t2_all'
	
	// clean up
	if ( `"`stdp'"' == "" ) rename `t1_all' `var'
	else rename `t2_all' `var'
end
*--------------------------------------------------------------------------------------------------------
* subprogram rubin
* This program implements a scalar version of rubin's rules for an existing variable
* in the dataset. The variable values are combined on an observation-by-observation basis
* and each combined result is stored against the corresponding observation in the $S_MJ==0
* dataset.
*--------------------------------------------------------------------------------------------------------
program define rubin
	version 9.2

	syntax varlist(min=1 max=2)
	local var : word 1 of `varlist'
	local varse : word 2 of `varlist'
	if ( "`varse'" != "" ) local stdp "stdp"

	quietly levelsof $S_MJ, local(all)
	local pos : list posof "0" in all
	if ( `pos' == 0 ) {
		display as error "original dataset ($S_MJ==0) is required with rubin"
		exit 498
	}
	local mj0 "0"
	local levels : list all - mj0

	tempname q qsum w b m1 m2
	local m : word count `levels'
	local from : word 1 of `levels'
	local to : word `m' of `levels'
	scalar `m1' = 1/(`m'-1)
	scalar `m2' = 1 + 1/`m'
	// Mark Lunt speed improvements to prediction
	tempvar q b w temp
	qui gen `temp' = .
	sort $S_MI $S_MJ
	quietly {
		by $S_MI: egen `q' = mean(`var') if $S_MJ >= `from' & $S_MJ <= `to'
		by $S_MI: replace `var' = `q'[_N] if $S_MJ == 0
		if ( `"`stdp'"' != "" ) {
			by $S_MI: egen `w' = mean(`varse') if $S_MJ >= `from' & $S_MJ <= `to'
			by $S_MI: replace `temp' = (`var' - `q')^2 if $S_MJ >= `from' & $S_MJ <= `to'
			by $S_MI: egen `b' = total(`temp')
			replace `b' = `m1'*`b'
			by $S_MI: replace `varse' = `w'[_N] + `m2'*`b'[_N] if $S_MJ == 0
		}
	}
	sort $S_MJ $S_MI
end

* PR/IRW 19may2008
program define mim_jackknife, rclass

version 9.2

/*
	Based on jackrubin2.ado, 19may2008.

	Jackknife SE of regression quanities in MI, to assess Monte Carlo error (Ian White).
*/

// GET IMPUTATIONS USED IN LAST MIM estimates
local levels `e(MIM_levels)'
local m : word count `levels'

// THE FOLLOWING STATS ARE JACKKNIFED:
local stats b se t p ll ul fmi se_eform
tokenize `stats'
local nstat 0
while "`1'"!="" {
	local ++nstat
	local stat`nstat' `1'
	mac shift
}

tempname b0 V0 dfvec0 se0 se_eform0 p0 t0 ll0 ul0 fmi0 pv meanpv sepv tmult
local first : word 1 of `levels'
local last = `first' + `m' - 1
quietly {
	matrix `b0' = _mim_b`first'
	matrix `V0' = _mim_V`first'
	matrix `dfvec0' = e(MIM_dfvec)	// MI d.f. used in table of results
	matrix `fmi0' = e(MIM_lambda)	// FMI used in table of results
	local k = colsof(`b0')
	local cols: colnames `b0'
	local eqs: coleq `b0', quoted
	local eqs : subinstr local eqs "." "_", all	// replaces periods with underscores
	if !missing(e(df_r)) local nucom = e(df_r)
	else local nucom -1
	foreach thing in se se_eform p t ll ul fmi {
		matrix ``thing'0' = J(1, `k', 0)
	}
	forvalues i=1/`k' {
		matrix `se0'[1, `i'] = sqrt(`V0'[`i', `i'])
		matrix `se_eform0'[1, `i'] = exp(`b0'[1, `i'])*`se0'[1, `i']
		matrix `t0'[1, `i'] = `b0'[1, `i']/`se0'[1, `i']
*		matrix `p0'[1, `i'] = Ftail(1, min(`dfvec0'[1, `i'],2e17), (`t0'[1, `i'])^2)
		matrix `p0'[1, `i'] = Ftail(1, `dfvec0'[1, `i'], (`t0'[1, `i'])^2)
		scalar `tmult' = invttail(`dfvec0'[1, `i'], 0.025)	// for 95% CI, could generalise
		matrix `ll0'[1, `i'] = `b0'[1, `i']-`tmult'*`se0'[1, `i']
		matrix `ul0'[1, `i'] = `b0'[1, `i']+`tmult'*`se0'[1, `i']
	}

	// Store individual-fit e(b) and e(V) matrices; get sum of e(V)'s for -mim- fit_combine
	local bind
	local Vind
	forvalues j = `first' / `last' {
		// Load parameter estimates for this imputation
		local bind `bind' _mim_b`j'
		local Vind `Vind' _mim_V`j'
	}
/*
	Work through each imputation, get fit_combine to perform
	Rubin's rules excluding jth imputation, in "remove" mode.
*/
	tempname B T Q W dfvec dfmin dfmax TLRR r lambda r1 nu1 jackse
	forvalues i = `first' / `last' {
		local j = `i' - `first' + 1
		tempname b`j' se`j' se_eform`j' t`j' ll`j' ul`j' p`j' fmi`j'
		fit_combine, beta(`bind') v(`Vind') b(`B') t(`T') q(`b`j'') w(`W') ///
		 dfvec(`dfvec') min(`dfmin') max(`dfmax') tlrr(`TLRR') r(`r') ///
		 lambda(`fmi`j'') r1(`r1') nu1(`nu1') nucom(`nucom') remove(`j')
		// The following quantities are returned by combcalc()
		matrix `se`j'' = r(sej)
		matrix `se_eform`j'' = r(se_eformj)
		matrix `t`j'' = r(tj)
		matrix `p`j'' = r(pj)
		matrix `ll`j'' = r(llj)
		matrix `ul`j'' = r(ulj)
	}
	// Mean and SE of pseudovalues for each stat
	matrix `jackse' = J(`nstat', `k', 0)
	forvalues s=1/`nstat' {
		local thing `stat`s''
		matrix `meanpv' = J(1, `k', 0)
		matrix `sepv' = J(1, `k', 0)
		forvalues i = `first' / `last' {
			local j = `i' - `first' + 1
			matrix `pv' = `m'*``thing'0' - (`m'-1)*``thing'`j''
			matrix `meanpv' = `meanpv' + `pv'/`m'
			matrix `sepv' = `sepv' + hadamard(`pv', `pv')
		}
		// Jackknife SE of stats
		matrix `sepv' = (`sepv' - `m' * hadamard(`meanpv', `meanpv'))/((`m'-1)*`m')
		forvalues i=1/`k' {
			matrix `jackse'[`s', `i'] = sqrt(`sepv'[1, `i'])
		}
	}
}
matrix colnames `jackse' = `cols'
matrix coleq `jackse' = `eqs'
matrix rownames `jackse' = `stats'
return scalar df_m = `k'		// model d.f.
return scalar df_r = `nucom'	// residual d.f.
return matrix jackse = `jackse'
end

* based on rubin.ado version 1.0.2 PR 13nov2007
program define rubin_univariate, rclass
version 9.2

syntax varlist(min=1 max=2 numeric) [if] [in] [, Level(cilevel) Name(string) ]

quietly {
	gettoken Q u: varlist	// estimate and its SE
	tempname m Qhat B W T se nu r lambda t lb ub
	tempvar V
	marksample touse
	count if `touse'
	scalar `m' = r(N)
	sum `Q' if `touse'
	scalar `Qhat' = r(mean)
	scalar `B' = r(Var)
}
cap gen `V' = `u'^2 if `touse'
if _rc==0 {
	qui sum `V' if `touse'
	scalar `W' = r(mean)
	scalar `T' = `W'+`B' * (1 + 1 / `m')
	scalar `se' = sqrt(`T')
	if `B' > 1e-20 {
		scalar `r' = (1 + 1 / `m') * `B' / `W'
		scalar `nu' = (`m' - 1) * (1 + 1 / `r') ^2
		scalar `lambda' = (`r' + 2 / (`nu' + 3)) / (`r' + 1)
		scalar `nu' = (`m' - 1) * ((1 + `W' / (`B' * (1 + 1 / `m'))) ^2)
		scalar `t' = invttail(`nu', (100 - `level') / 200)
	}
	else {	// B <= 1e-20 treated as B = 0
		scalar `r' = 0
		scalar `nu' = -1
		scalar `lambda' = 0
		scalar `t' = invnormal((100 - `level') / 200)
	}
	scalar `lb' = `Qhat' - `t' * `se'
	scalar `ub' = `Qhat' + `t' * `se'

/*
	Note that code from fit_combine uses `nucom' (complete-cases residual df)
	and gives slightly higher MI df than that used by rubin_univariate.

	scalar `t1' = `B'			// between-imputation variance
	if ( `t1' <= 0 ) scalar `t1' = 0.000001		// `t1' could be zero
	matrix `gamma'[1,`i'] = (1+1/`m')*`t1'/`t'[`i',`i']
	matrix `nuobs'[1,`i'] = ((`nucom'+1)/(`nucom'+3))*`nucom'*(1-`gamma'[1,`i'])
	matrix `num'[1,`i'] = (`m'-1)*`gamma'[1,`i']^-2
	scalar `df' = 1/((1/`num'[1,`i']+1/`nuobs'[1,`i']))
	if ( `df' >= 1000 ) scalar `df' = 1000		// upper limit on degrees of freedom
*/

// display from ci.ado
	local cil `=string(`level')'
	local cil `=length("`cil'")'
	local spaces ""
	if `cil' == 2 {
		local spaces "   "
	}
	else if `cil' == 4 {
		local spaces " "
	}
	#delimit ;
	display as txt _n 
`"Combined estimate  {c |}       Mean     Std. Err.   `spaces'[`=strsubdp("`level'")'% Conf. Interval]    FMI"'
	_n "{hline 19}{c +}{hline 58}" ;
	#delimit cr

	local ofmt "%9.0g"
	display as txt %-18s abbrev(`"`name'"', 18) _col(20) "{c |}" ///
	 _col(23) as res `ofmt' `Qhat' ///
	 _col(36) `ofmt' sqrt(`T') ///
	 _col(51) `ofmt' `lb' ///
	 _col(63) `ofmt' `ub' ///
	 _col(74) %5.3f `lambda'

	return scalar Q = `Qhat'
	return scalar W = `W'
	return scalar B = `B'
	return scalar T = `T'
	return scalar se = `se'
	return scalar nu = `nu'
	return scalar r = `r'
	return scalar lambda = `lambda'
	return scalar lb = `lb'
	return scalar ub = `ub'
	return scalar m = `m'
}
else {
	display as txt _n "Combined estimate = " as res `ofmt' `Qhat' as txt " (standard errors not supplied)"
	return scalar Q = `Qhat'
}
end

program define CheckDataStyle
version 9.2
	// CHECK IF DATA HAVE OLD-STYLE INDICATOR VARIABLES
	capture confirm var _mi
	if c(rc) == 0	capture confirm var _mj
	if c(rc) == 0 {
		di as txt "[note: using ice-style format variables _mi and _mj]"
		global S_MI _mi
		global S_MJ _mj
	}
	else if c(stata_version) >= 11 {
		// CHECK IF DATA ARE mi set AND IN FLONG STYLE
		quietly mi query
		local style `r(style)'
		if missing("`style'") {
			di as err "data are not in a recognized mi style"
			exit 198
		}
		if "`style'" != "flong" {
			di as text "[converting data to style flong]"
			quietly mi convert flong, clear
		}
		di as txt "[note: using mi-style format variables _mi_id and _mi_m]"
		global S_MI _mi_id
		global S_MJ _mi_m
	}
	else {
		di as err "data are not in a recognized MI data format"
		exit 198
	}
end

version 9.2

mata:

void combcalc(string scalar beta, string scalar v, real scalar nucom, 
 | string scalar Q, string scalar W, real scalar remove)
{
	nargs = args()
	bs = tokens(beta)	// bs is a rowvector containing m things like __000001, each of which is an 1 x p e(b) matrix
	vs = tokens(v)	// vs is a rowvector containing m things like __000001, each of which is a  p x p e(V) matrix
	m = cols(bs)	// total number of imputations
	if (nargs == 3) {
		// sum e(b)'s and e(V)'s
		q = st_matrix(bs[1])
		w = st_matrix(vs[1])
		p = cols(q)
		for(i=2; i<=m; i++) {
			q = q + st_matrix(bs[i])
			w = w + st_matrix(vs[i])
		}

		// Return sum of e(b) and sum of e(V)
		st_matrix("r(sumb)", q)
		st_matrix("r(sumV)", w)

		q = q/m
		w = w/m

		// Calculate between-imputation variance, b, and total variance, t
		QQ = st_matrix(bs[1]) - q
		b = QQ' * QQ
		for(i=2; i<=m; i++) {
			QQ = st_matrix(bs[i]) - q
			b = b + QQ' * QQ
		}
		b = b / (m-1)
		t = w + (1 + 1/m) * b
	}
	else {
		// Jackknife mode: Q is (sum of beta's)/m and W is (sum of V's)/m.
		// remove is the index of a beta and a V to be removed.
		// remove = st_numscalar(jremove)
		m1 = m - 1

		q = ( st_matrix(Q) * m - st_matrix(bs[remove]) )/m1
		w = ( st_matrix(W) * m - st_matrix(vs[remove]) )/m1

		// Calculate between-imputation variance, b, and total variance, t for m-1 imputations
		p = cols(st_matrix(bs[remove]))
		b = J(p, p, 0)
		for(i=1; i<=m; i++) {
			if (i!=remove) {
				QQ = st_matrix(bs[i]) - q
				b = b + QQ' * QQ
			}
		}
		b = b / (m1-1)
		t = w + (1 + 1/m1) * b
		m = m1
	}

	// calculate additional quantities for consistency with micombine
	r = (1+1/m) :* (diagonal(b)' :/ diagonal(w)')
	a = 1 * (m - 1)
	if (nucom != -1) {
		// Next statment allows smallest diagonal element of B to be 1e-20 (not .0000001 as before)
		t1 = colmax(diagonal(b)' \ J(1, p, 1e-20))
		gamma = (1 + 1/m) * (t1 :/ diagonal(t)')
		nuobs = ((nucom + 1)/(nucom + 3)) * nucom * (1 :- gamma)
		num = (m :- 1) :* (gamma :^ (-2))
		dfvec = 1:/((1:/num + 1:/nuobs))
	}
	else {
		// Improved version of nu: Li, Raghunathan & Rubin (1991) eqn. (1.8) with p = 1 predictor
		if (a > 4) {
			dfvec = 4 :+ (a - 4) :* (1 :+ (1 :- 2 :/ a) :/ r):^2
		}
		else {
			dfvec = a :* (1 :+ 1 :/ r):^2
		}
	}
	// !! PR 20may2013: cope with case of "infinite" df (no imputed data)
	// Upper limit of valid d.f. for Ftail(), ttail(), invttail() etc. is 2e17.
	// If df for first predictor is missing or "infinite", assume no imputed data.
	if ( dfvec[1, 1] > 2e17 | missing(dfvec[1, 1]) ) dfvec = J(1, p, 2e17)
	lambda = (r :+ 2 :/ (dfvec :+ 3)) :/ (r :+ 1)
	min = min(dfvec)
	max = max(dfvec)
	// Li, Raghunathan & Rubin (1991) estimates of T and nu1
	// for F test of all params=0 on k,nu1 degrees of freedom
	r1 = trace(b * invsym(w)) * (1 + 1 / m) / p
	tlrr = w * (1 + r1)
	a = p * (m - 1)
	if (a > 4) nu1 = 4 + (a - 4) * (1 + (1 - 2 / a) / r1) ^2
	else (nu1 = 0.5 * a * (1 + 1 / p) * (1 + 1 / r1) ^2)
	if (nargs > 3) {
		// Additional quantities needed for jackknifing
		sej = sqrt(diagonal(t))'	// diagonal() returns a column vector, hence must transpose
		se_eformj = exp(q :* sej)
		tj = q :/ sej
		pj = Ftail(1, dfvec, tj:^2)
		tmult = invttail(dfvec, 0.025)	// for 95% CI, could generalise
		llj = q - tmult :* sej
		ulj = q + tmult :* sej
		st_matrix("r(sej)", sej)
		st_matrix("r(se_eformj)", se_eformj)
		st_matrix("r(tj)", tj)
		st_matrix("r(pj)", pj)
		st_matrix("r(llj)", llj)
		st_matrix("r(ulj)", ulj)
	}
	st_numscalar("r(min)",min)
	st_numscalar("r(max)",max)
	st_matrix("r(dfvec)", dfvec)
	st_matrix("r(b)", b)
	st_matrix("r(q)", q)
	st_matrix("r(r)", r)
	st_matrix("r(t)", t)
	st_matrix("r(w)", w)
	st_matrix("r(lambda)", lambda)
	st_numscalar("r(r1)",r1)
	st_numscalar("r(nu1)",nu1)
	st_matrix("r(tlrr)", tlrr)
}
end
exit

History

v2.1.8 	(PR) Fixed df bug too large - invalidates invtt and invttail when no missing data in fitted model.
v2.1.7 	(PR) Fixed bug in that est commands were run under version 9.2, not current. May need further checking.
v2.1.6 	(PR) Fixed bug in -byvar- option with -category(combine)-
v2.1.5 	(PR) Fixed bug caused by temporary file names with blanks in
v2.1.4 	(PR) Fixed bug truncating long Stata command, including list of variables in a model
v2.1.1 	(PR) Fixed bug incorrectly recognising Stata version
v2.0.0 	(PR) Version of mim which works with data in Stata 11 MI format or in ice format
v1.2.8 	(PR) Tidied up calculation of df for variables to agree with mi estimate v1.2.7
v1.2.7 	(PR) Fixed bug in setting temporary directory name - did not work with Unix (and presumably Mac)
v1.2.6 	(PR) Fixed bug in using estimates - caused predict to fail when depended on e(sample) being set
v1.2.5 	(PR) lincom following logistic has problems, no longer supported. Go via logit, or and lincom, or
		(PR) Fixed bug in estimation of FMI for mim: lincom
v1.2.4	(PR) bug in v1.2.3 causing mim: predict and mim, j() to fail is fixed
v1.2.3	(PR) bug in routine handle_BV fixed
v1.2.2	(PR) bug in mim with Stata 9.2 version fixed - estimates command
v1.2.1	(PR) Fixed inadvertent error in predict: "mim2a" when should be "mim"
v1.2.0	(PR) Improved functionality of mim: predict
		(PR) Improved speed of mim, mcerror and mim: predict, mim: lincom, mim: testparm
 		(PR) Changed the way the per-imputation estimation results are stored
v1.1.10	(PR) Fixed bug: crashed if score label(s) in response variable included spaces or periods
v1.1.9	(PR) Fixed bug: crashed if _merge variable already exists in imputed dataset
v1.1.8	(PR) Fixed bug in mim: lincom following mim: logistic
v1.1.7	(PR) Fixed problem that occurred when name of temporary folder has spaces.
v1.1.6	(PR) Improvements in speed of mim, mcerror using Mata
		(PR) Improvements in output for category(combine)
		(PR) Fix -noclear- bug
v1.1.5	(PR) mim:predict extended to allow predict options
		(PR) mim, mcerror updated with improved output and to support reporting_options
		(PR) -sortpreserve- removed from program define mim since disturbs mim:reshape
v1.1.4	(PR) mim:predict extended to allow predict options
		(PR) mim, category(combine) option added to allow Rubin's rules for scalars
 		(PR, IRW) mim, mcerror re-implemented using jackknife
v1.1.3	(PR) -sortpreserve- added to avoid observations ending up seeming arbitrarily sorted
		(PR) removed "set more off" at start of mim - unStata-ish
		(PR) Bug fixed in determining Rubin's rules estimate of SE of linear predictor
 		(PR, IRW) added mim, mcerror option
		(PR) implemented to(), from() options for model fitting
		(PR) added time ratio display to streg, dist(gamma)
v1.1.2	(PR) added code to create e(sample) if storebv used
		(PR) mim:testparm returns standard r() scalar statistics (compatibility with -mimsw-)
v1.1.1	(JBC) changed nolrr option to lrr, so default does not use this; 
 		 - made behaviour of -storebv- option consistent with this
v1.1.0	Added rubin subcommand
 		bug fix: made display of results default to using LRR covariance matrix and
 		added undocumented nolrr option
v1.0.3	(03aug2007) Removed seed option from -mim fit-
v1.0.2	(27jul2007) Mark Lunt speed improvements to prediction
v1.0.1	bug fix: fixed "ereturn local depvar" statement in case j>0 of fit_handlebv routine
		bug fix: replaced use of `from' with `first' in fit routine when capturing e() scalars and macros
		added undocumented noclear option to allow suppression of mim issuing -ereturn clear-
		changed method of replay of individual estimates to trying `cmd' first, and if this fails
			then using the generic -ereturn display- routines
		restricted use of storebv option to apply only when fitting/replaying combined estimates
 		(previously this option would have been ignored when replaying individual estimates)
