
*! version 5.0  19nov2018  Mattia Chiapello


*** Main caller ***

cap program drop balancetable
program define balancetable
	version 14.0
	syntax anything(equalok) using [if] [in] [fweight aweight iweight], [stddiff] [observationscolumn] [*]

	* Check if parentheses in main argument and call simple/complex subprogram
	if strpos(`"`anything'"', "(")==0 {
		gettoken mainvar depvarlist: anything
		if "`stddiff'" != "" local stddiff_col "stddiff_col"	// the syntax command cannot accept both 'stddiff' and 'stddiff(string asis)' options
		balancetable_complex (mean if `mainvar'==0) (mean if `mainvar'==1) (diff `mainvar') `depvarlist' `using' `if' `in' [`weight' `exp'], ///
			`stddiff_col' `observationscolumn' `options'
	}
	else if strpos(`"`anything'"', "(")==1 {
		if "`stddiff'" != "" {
			dis as error "Error: option {bf:stddiff} cannot be used with the complex syntax"
			error 197
		}
		if "`observationscolumn'" != "" {
			dis as error "Error: option {bf:observationscolumn} cannot be used with the complex syntax"
			error 197
		}
		balancetable_complex `anything' `using' `if' `in' [`weight' `exp'], `options'
	}
	else {
		dis as error "Error: parenthesized rules should be placed at the beginning"
		error 197
	}
end


*** Complex syntax ***

cap program drop balancetable_complex
program define balancetable_complex
	syntax anything using/ [if] [in] [fweight aweight iweight], ///
		[PVALues] [vce(passthru)] [FE(varname)] [COVariates(varlist fv ts)] ///
		[STDDIFF_col] [observationscolumn] ///
		[NOSTARS STARLevels(string) staraux] ///
		[ONELine ONELinesubopt(string) wide WIDEsubopt(string)] ///
		[groups(string asis)] ///
		[CTItles(string asis) LEFTCTItle(string) LEFTCOBServations(string)] ///
		[NOLInes NOHEAD NOFOOT] ///
		[VARLAbels] [VARNAmes] [wrap WRAPsubopt(string)] ///
		[NONUMbers] [NOOBServations] ///
		[format(passthru) DISPLAYFormat] [NOPAR PARsubopt(string)] ///
		[mean(string asis) sd(string asis) diff(string asis) se(string asis) pval(string asis) STDDIFF(string asis) obs(string asis)] ///
		[VARWIdth(numlist integer max=1)] [tabulary TABULARYwidth(string)] [LONGtable] [BOOKTabs] ///
		[prehead(string asis) posthead(string asis) prefoot(string asis) postfoot(string asis)] ///
		[REPLACE APPEND MODIFY sheet(string) cell(passthru) NOMATA]


	* Process syntax
	marksample touse, strok
	balancetable_parsing `anything'
	tokenize `"`ctitles'"'

	* Check presence of 'listtab' command
	cap which listtab
	if _rc ssc install listtab

	* Check correct extension of filename
	if ustrright(`"`using'"',4) == ".tex" local filetype "latex"
	else if ustrright(`"`using'"',4) == ".xls" | ustrright(`"`using'"',5) == ".xlsx" local filetype "excel"
	else {
		dis as error "Error: the filename must have extesions .tex, .xls or .xlsx"
		exit
	}

	* Check that if conditions do not create columns with no observations
	forvalues i = 1/`par_nr' {
		qui count if (`touse') `par`i'_if'
		if r(N) == 0 {
			dis as error "Error: no observations in column `i'"
			error 2000
		}
	}

	* Check star options
	if "`nostars'" == "" stars_subopt `starlevels'

	* Set local marking wide table options
	if "`oneline'" != "" | "`onelinesubopt'" != "" | "`wide'" != "" | "`widesubopt'" != "" {
		local widetable 1
		local oneline_obs 0 										// if showing se/pval, this column must show obs count, which is normally in diff column
	}
	else local widetable 0
	* Check the oneline option
	if ("`oneline'" != "" | "`onelinesubopt'" != "") & ("`wide'" != "" | "`widesubopt'" != "") {
		dis as error "Error: {bf:oneline} and {bf:wide} are alternative options and may not be used together"
		error 184
	}
	if "`onelinesubopt'" != "" local widesubopt "`onelinesubopt'"
	else if "`oneline'" != "" local widesubopt "mean diff"
	* Check and parse the wide option (its wrapok suboption)
	if "`widesubopt'" != "" {
		gettoken wide_statlist wide_opt: widesubopt, parse(,)
		local wide_statlist = strtrim(subinstr("`wide_statlist'",",","",.))				// remove comma and blanks from statlist (comma is stored here if the statlist is empty)
		if "`onelinesubopt'" != "" {
			if !inlist("`wide_statlist'","se","pval","") {			// se and pval (or nothing) are the only allowed options of oneline
				dis as error "Error: {bf:`wide_statlist'} is not a valid option of {bf:oneline}"
				error 197
			}
			else if inlist("`wide_statlist'","se","pval") {
				local wide_statlist "mean `wide_statlist'"			// add mean and diff to oneline
				local oneline_obs 1									// if showing se/pval, this column must show obs count, which is normally in diff column
			}
			else if "`wide_statlist'" == "" local wide_statlist "mean diff"
		}
		local wide_opt = strtrim(subinstr("`wide_opt'",",","",.))						// remove comma and blanks from suboption
		if "`wide_opt'" != "" & "`wide_opt'" != "wrapok" {
			dis as error "Error: {bf:`wide_opt'} is not a valid suboption of {bf:wide}"
			error 197
		}
	}

	* Parentheses options
	par_subopt `parsubopt', `nopar'
	* Format option
	if "`format'" == "" local formatting "format(%10.3fc)"									// set default format
	else if "`format'" != "" local formatting "`format'"
	* Suboptions for parentheses and formatting by statistic types
	if `"`se'"' != "" & "`pvalues'" != "" {													// Do not allow 'se()' with 'pvalues'
		dis as error "Error: {bf:se()} cannot be used with the {bf:pvalues} option"
		error 197
	}
	if `"`pval'"' != "" & "`pvalues'" == "" {												// Do not allow 'pval()' without 'pvalues'
		dis as error "Error: {bf:pval()} cannot be used without the {bf:pvalues} option"
		error 197
	}
	foreach stat in mean sd diff se pval stddiff obs {
		if `"``stat''"' != "" stattype_subopt `stat', ``stat''
		else {
			local `stat'_customfmt 0
			local `stat'_custompar 0
		}
	}
	* Set default observations format
	if "`obs_fmt'" == "" local obs_fmt "%20.0gc"

	* Fixed Effects option
	if "`fe'" != "" local fe "i.`fe'"

	* Tabularywidth option
	if "`tabularywidth'" != "" local tabulary "tabulary"

	* Output/destination file
	if "`filetype'" == "latex" {
		if "`replace'" != "" & "`append'" != "" {
			dis as error "Error: {bf:replace} and {bf:append} are alternative options and may not be used together"
			error 184
		}
		else if "`replace'" == "" & "`append'" != "" {
			local appendfile `"appendto("`using'")"'
			local using ""
		}
		else local using `"using `"`using'"'"'				// use compound quotes because file names may contain "
	}
	* Destination sheet (add sheet() around sheet name for putexcel and export excel)
	else if "`filetype'" == "excel" & `"`sheet'"' != "" {
		if regexm(`"`sheet'"',`"""') {
			dis as error "Error: sheet names cannot contain quotes"
			dis as error "(the option {bf:sheet()} of {bf:putexcel} always strips quotes away, which creates issues)"
			exit 198
		}
		local tosheet `"sheet("`sheet'")"'
	}

	* Nomata option
	if "`nomata'" == "" local mataok 1
	else local mataok 0

	* Build the variables column (Column 0)
	tempname postBalanceVar
	tempfile balance_var
	qui postfile `postBalanceVar' Line str10 DisplayFormat str100 Variable using `balance_var', replace
	foreach x of varlist `depvarlist' {

		* Save text to go in the left column
		if "`varlabels'" != "" & "`varnames'" != "" {
			display as error "Error: {bf:varlabels} and {bf:varnames} are alternative options and may not be used together"
			error 184
		}
		else if "`varlabels'" != "" {
			local variable: var label `x'
			if `"`variable'"' == "" local variable `x'
			if "`filetype'" == "latex" local variable: subinstr local variable "_" "\_", all
		}
		else {
			if "`filetype'" == "latex" local variable: subinstr local x "_" "\_", all
			else if "`filetype'" == "excel" local variable `x'
		}
		* Wrap option (with respective suboptions)
		if "`wrap'" != "" | "`wrapsubopt'" != "" {
			local maxvarwidth 32
			wrap_subopt `wrapsubopt', wrap_varwidth(`varwidth')
			local variable_pt2: piece 2 `maxvarwidth' of `"`variable'"', nobreak
			local variable: piece 1 `maxvarwidth' of `"`variable'"', nobreak
			if "`indent'" != "" & "`filetype'" == "latex" local indent "\quad "
			else if "`indent'" != "" & "`filetype'" == "excel" local indent "   "
			local variable_pt2 `"`indent'`variable_pt2'"'
		}
		* Varwidth option
		if "`varwidth'" != "" & "`filetype'" == "latex" {
			local variable `"`variable'\rule{`=`varwidth'-`:udstrlen local variable''ex}{0pt}"'
			if `"`variable_pt2'"' != "" local variable_pt2 `"`variable_pt2'\rule{`=`varwidth'-`:udstrlen local variable_pt2''ex}{0pt}"'
		}

		* Store display format
		local dis_fmt: format `x'

		* Post variable name and format
		post `postBalanceVar' (1) ("`dis_fmt'") (`"`variable'"')
		post `postBalanceVar' (2) ("`dis_fmt'") (`"`variable_pt2'"')
	}
	* Close postfile
	postclose `postBalanceVar'

	* Observationscolumn option (create postfile for observations)
	if "`observationscolumn'" != "" {
		tempname postBalanceObs
		tempfile balance_obs
		qui postfile `postBalanceObs' Line str25 Observations using `balance_obs', replace
	}

	* Build remaining columns with results (Column 1 ... Column N)
	forvalues i = 1/`par_nr' {
		tempname postBalanceCol`i'
		tempfile balance_col`i'
		qui postfile `postBalanceCol`i'' Line Col`i' str10 Stars`i' using `balance_col`i'', replace

		* Compute statistics for "mean" type of column
		if "`par`i'_type'" == "mean" {
			foreach x of varlist `depvarlist' {
				qui summ `x' if (`touse') `par`i'_if' [`weight' `exp']
				post `postBalanceCol`i'' (1) (r(mean)) ("")		
				post `postBalanceCol`i'' (2) (r(sd)) ("")
			}
		}

		* Compute statistics for "diff" type of column
		else if "`par`i'_type'" == "diff" {
			* Check correct values of mainvar
			qui levelsof `par`i'_mainvar' if (`touse') `par`i'_if', local(values)
			if "`values'" == "1" | "`values'" == "0" {
				dis as error "Warning: variable {bf:`par`i'_mainvar'} always takes value `values' in column `i'"
			}
			else if "`values'" != "0 1" {
				display as error "Error: variable {bf:`par`i'_mainvar'} can only take values 0 and 1"
				exit 450
			}
			foreach x of varlist `depvarlist' {
				* Regression
				qui reg `x' `par`i'_mainvar' `fe' `covariates' if (`touse') `par`i'_if' [`weight' `exp'], `vce'
				qui test `par`i'_mainvar'		
				* Significance stars
				local stars ""
				if "`nostars'" == "" {
					forvalues j = 1/`nr_starlevels' {
						if r(p) < `s`j'_thr' local stars "`s`j'_sym'"
						else continue, break
					}
				}
				* Post coefficient and SE or p-values
				post `postBalanceCol`i'' (1) (_b[`par`i'_mainvar']) ("`stars'")
				if "`pvalues'" != "" post `postBalanceCol`i'' (2) (r(p)) ("")
				else post `postBalanceCol`i'' (2) (_se[`par`i'_mainvar']) ("")
				* Post observations used in regression (observationscolumn option)
				if "`observationscolumn'" != "" {
					local reg_obs = "`obs_lpar'" + strtrim("`: dis `obs_fmt' e(N)'") + "`obs_rpar'"
					post `postBalanceObs' (1) ("`reg_obs'")
					post `postBalanceObs' (2) ("")
				}
			}
		}

		* Calculate observations in subsample
		qui count if (`touse') `par`i'_if'
		local col`i'_obs = "`obs_lpar'" + strtrim("`: dis `obs_fmt' r(N)'") + "`obs_rpar'"

		* Close postfiles
		postclose `postBalanceCol`i''
		if "`observationscolumn'" != "" & "`par`i'_type'" == "diff" postclose `postBalanceObs'		// close after diff (3rd) col (only with simple syntax)
	}

	* Stddiff option (create postfile for stddiff)
	if "`stddiff_col'" != "" {
		tempname postBalanceStddiff
		tempfile balance_stddiff
		qui postfile `postBalanceStddiff' Line StdDiff using `balance_stddiff', replace
		foreach x of varlist `depvarlist' {
			* Mean and SD of group1
			qui sum `x' if (`touse') `par1_if'
			local group1mean = r(mean)
			local group1sd = r(sd)
			* Mean and SD of group2
			qui sum `x' if (`touse') `par2_if'
			local group2mean = r(mean)
			local group2sd = r(sd)
			* Compute standardized difference
			local std_diff = (`group2mean'-`group1mean')/(sqrt(`group2sd'^2+`group1sd'^2))
			* Post standardized difference
			post `postBalanceStddiff' (1) (`std_diff')
			post `postBalanceStddiff' (2) (.)
		}
		postclose `postBalanceStddiff'
	}

	* Merge postfiles and edit "dataset"
	preserve
	use `balance_var', clear
	forvalues i = 1/`par_nr' {

		* Merge together all the individual datasets for each parenthesis
		merge 1:1 _n using `balance_col`i'', nogen noreport

		* Convert variables to string
		qui tostring Col`i', gen(strCol`i') force `formatting'
		* Displayformat option
		if "`displayformat'" != "" qui replace strCol`i' = strofreal(Col`i',DisplayFormat) if !("`par`i'_type'" == "diff" & "`pvalues'" != "" & Line == 2)
		* Apply custom format
		if "`par`i'_type'" == "mean" {
			if `mean_customfmt' qui replace strCol`i' = strofreal(Col`i',"`mean_fmt'") if Line == 1
			if `sd_customfmt' qui replace strCol`i' = strofreal(Col`i',"`sd_fmt'") if Line == 2
		}
		else if "`par`i'_type'" == "diff" {
			if `diff_customfmt' qui replace strCol`i' = strofreal(Col`i',"`diff_fmt'") if Line == 1
			if `se_customfmt' qui replace strCol`i' = strofreal(Col`i',"`se_fmt'") if Line == 2
			else if `pval_customfmt' qui replace strCol`i' = strofreal(Col`i',"`pval_fmt'") if Line == 2
		}
		* Replace dots for missing values
		qui replace strCol`i' = "" if strCol`i' == "."

		* Add parentheses
		if "`par`i'_type'" == "mean" {
			if `mean_custompar' qui replace strCol`i' = "`mean_lpar'" + strCol`i' + "`mean_rpar'" if Line == 1
			if `sd_custompar' qui replace strCol`i' = "`sd_lpar'" + strCol`i' + "`sd_rpar'" if Line == 2
			else qui replace strCol`i' = "`lpar'" + strCol`i' + "`rpar'" if Line == 2								// apply default parentheses to 2nd line
		}
		else if "`par`i'_type'" == "diff" {
			if `diff_custompar' qui replace strCol`i' = "`diff_lpar'" + strCol`i' + "`diff_rpar'" if Line == 1
			if `se_custompar' qui replace strCol`i' = "`se_lpar'" + strCol`i' + "`se_rpar'" if Line == 2			// se_custompar and pval_custompar are never BOTH defined at the same type (stattype_subopt allows either one, depending on the 'pvalues' option)
			else if `pval_custompar' qui replace strCol`i' = "`pval_lpar'" + strCol`i' + "`pval_rpar'" if Line == 2
			else qui replace strCol`i' = "`lpar'" + strCol`i' + "`rpar'" if Line == 2								// apply default parentheses to 2nd line
		}

		* Staraux option
		if "`staraux'" != "" {
			qui replace Stars`i' = Stars`i'[_n-1] if Line == 2
			qui replace Stars`i' = "" if Line == 1
		}
		* Add significance stars
		qui replace strCol`i' = strCol`i' + Stars`i'

		* Drop numeric variable and stars variable
		drop Col`i' Stars`i'
	}

	* Stddiff option (merge postfile for stddiff and apply the same edits as for main columns)
	if "`stddiff_col'" != "" {
		merge 1:1 _n using `balance_stddiff', nogen noreport
		qui tostring StdDiff, gen(strStdDiff) force `formatting'
		if "`displayformat'" != "" qui replace strStdDiff = strofreal(StdDiff,DisplayFormat) if Line == 1
		if `stddiff_customfmt' qui replace strStdDiff = strofreal(StdDiff,"`stddiff_fmt'") if Line == 1
		qui replace strStdDiff = "" if strStdDiff == "."
		if `stddiff_custompar' qui replace strStdDiff = "`stddiff_lpar'" + strStdDiff + "`stddiff_rpar'" if Line == 1
		drop StdDiff
	}
	* Observationscolumn option (merge postfile for observations)
	if "`observationscolumn'" != "" merge 1:1 _n using `balance_obs', nogen noreport

	* Wide and widesubopt options
	if `widetable' {

		* Check compatibility with wrap options
		if ("`wrap'" != "" | "`wrapsubopt'" != "") & "`wide_opt'" != "wrapok" {
			dis as error "Error: options {bf:wide} and {bf:oneline} cannot be combined with {bf:wrap}"
			error 184
		}
		else qui replace Variable = Variable[_n-1] if Line == 2			// line 2 must be equal to line 1 for reshape
		
		* Stddiff option (prepare for reshape)
		if "`stddiff_col'" != "" {
			qui replace strStdDiff = strStdDiff[_n-1] if Line == 2		// line 2 must be equal to line 1 for reshape
			local strStdDiff "strStdDiff"								// store name of variable to use with keep only if the variable is in the dataset
		}
		* Observationscolumn (prepare for reshape)
		if "`observationscolumn'" != "" {
			qui replace Observations = Observations[_n-1] if Line == 2	// line 2 must be equal to line 1 for reshape
			local Observations "Observations"							// store name of variable to use with keep only if the variable is in the dataset
		}

		* Reshape and restore correct order
		gen sort_order = int(_n/2+.5)						// create variable storing the initial order and such that line 1 and 2 are equal for reshape
		qui reshape wide strCol*, i(Variable) j(Line)
		order strCol*, alphabetic after(Variable)			// restore correct order of variables/columns
		sort sort_order										// restore correct order of variables in the table
		drop sort_order

		* Rename columns
		forvalues i = 1/`par_nr' {
			if "`par`i'_type'" == "mean" {
				rename strCol`i'1 mean`i'
				rename strCol`i'2 sd`i'
			}
			else if "`par`i'_type'" == "diff" {
				rename strCol`i'1 diff`i'
				if "`pvalues'" == "" rename strCol`i'2 se`i'
				else rename strCol`i'2 pval`i'
			}
		}
		* Keep only statistics specified in widesubopt
		if "`wide_statlist'" != "" {
			* Keep all columns of a certain stat type
			foreach stat in mean sd diff se pval {
				local wide_statlist: subinstr local wide_statlist "`stat'" "`stat'*", all word
			}
			keep Variable `wide_statlist' `strStdDiff' `Observations'
		}
		* Keep all statistics if nothing specified in widesubopt
		else drop DisplayFormat								// drop extra variables so that dataset is equal to table to print
	}

	* Process dataset if long: keep all statistics
	else if !`widetable' drop Line DisplayFormat			// drop extra variables so that dataset is equal to table to print

	* Count columns (excluding Column 0)
	local col_nr = c(k)-1
	* Count columns (including Column 0)
	local tot_nr = c(k)
	* Count rows (excluding row Observations)
	local row_nr = _N


	* LaTeX file
	if "`filetype'" == "latex" {

		* Booktabs option
		if "`booktabs'" == "" {
			local top_line `""\hline\hline""'
			local mid_line `""\hline""'
			local btm_line `""\hline\hline""'
		}
		else if "`booktabs'" != "" {
			local top_line `""\toprule""'
			local mid_line `""\midrule""'
			local btm_line `""\bottomrule""'
		}
		* Nolines option
		if "`nolines'" != "" {
			local top_line ""
			local mid_line ""
			local btm_line ""
		}

		* Set header and footer (for tabulary and longtable options too)
		if "`tabulary'" == "" & "`longtable'" == "" {								// default tabular
			if `"`prehead'"' == "" & "`nohead'" == "" local prehead `""\begin{tabular}{l*{`col_nr'}c}" `top_line'"'
			if `"`posthead'"' == "" & "`nohead'" == "" local posthead `"`mid_line'"'
			if `"`postfoot'"' == "" & "`nofoot'" == "" local postfoot `"`btm_line' "\end{tabular}""'
		}
		else if "`tabulary'" != "" & "`longtable'" == "" {							// tabulary
			if "`tabularywidth'" == "" local tabularywidth "\textwidth"				// set text width as default
			if `"`prehead'"' == "" & "`nohead'" == "" local prehead `""\begin{tabulary}{`tabularywidth'}{l*{`col_nr'}C}" `top_line'"'
			if `"`posthead'"' == "" & "`nohead'" == "" local posthead `"`mid_line'"'
			if `"`postfoot'"' == "" & "`nofoot'" == "" local postfoot `"`btm_line' "\end{tabulary}""'
		}
		else if "`tabulary'" == "" & "`longtable'" != "" {							// longtable
			if `"`prehead'"' == "" & "`nohead'" == "" local prehead `""\begin{longtable}{l*{`col_nr'}c}" `top_line'"'
			if `"`posthead'"' == "" & "`nohead'" == "" {
				local posthead `"`mid_line' "\endfirsthead" `mid_line' "\endhead""'
				local end_foot `"`mid_line' "\endfoot" `btm_line' "\endlastfoot""'
			}
			if `"`postfoot'"' == "" & "`nofoot'" == "" local postfoot `""\end{longtable}""'
		}
		else {
			display as error "Error: {bf:tabulary} and {bf:longtable} are alternative options and may not be used together"
			error 184
		}
		if `"`prefoot'"' == "" & "`nofoot'" == "" & "`noobservations'" == "" local prefoot `"`mid_line'"'

		* Replace placeholders in header and footer
		local prehead: subinstr local prehead "@col" "`col_nr'", all
		local prehead: subinstr local prehead "@tot" "`tot_nr'", all
		local posthead: subinstr local posthead "@col" "`col_nr'", all
		local posthead: subinstr local posthead "@tot" "`tot_nr'", all
		local prefoot: subinstr local prefoot "@col" "`col_nr'", all
		local prefoot: subinstr local prefoot "@tot" "`tot_nr'", all
		local postfoot: subinstr local postfoot "@col" "`col_nr'", all
		local postfoot: subinstr local postfoot "@tot" "`tot_nr'", all

		* Header (nonumbers, ctitles, leftctitle options)
		if "`nohead'" == "" {												// with nohead, numbers, titles and groups are removed, so the local won't be stored
			if `"`leftctitle'"' == "" & `"`leftctitle'"' != "none" local leftctitle "Variable"
			else if `"`leftctitle'"' == "none" local leftctitle ""
			forvalues i = 1/`col_nr' {
				if "`nonumbers'" == "" local numbers_list "`numbers_list' & (`i')"
				if `"`ctitles'"' != "" local titles_list `"`titles_list' & ``i''"'
			}
			if "`nonumbers'" == "" local mnumbers `""`numbers_list' \\""'
			if `"`groups'"' != "" groups_subopt_latex `col_nr' `groups'
			if `"`ctitles'"' != "" local title1 `"`"`leftctitle'`titles_list' \\"'"'	// add compund quotes "
		}

		* Footer (noobservations, lectcobservations options)
		if "`nofoot'" == "" {
			if `"`leftcobservations'"' == "" local leftcobservations "Observations"
			if "`noobservations'" == "" {
				* Add observations for wide table
				if `widetable' {
					forvalues i = 1/`par_nr' {
						if "`par`i'_type'" == "mean" {
							cap confirm variable mean`i'
							if !_rc local obs_row "`obs_row' & `col`i'_obs'"
							cap confirm variable sd`i'
							if !_rc local obs_row "`obs_row' &"
						}
						else if "`par`i'_type'" == "diff" {
							cap confirm variable diff`i'
							if !_rc | `oneline_obs' local obs_row "`obs_row' & `col`i'_obs'"	// with oneline, print obs count in column showing se/pval
							cap confirm variable se`i'
							if !_rc & !`oneline_obs' local obs_row "`obs_row' &"
							cap confirm variable pval`i'
							if !_rc & !`oneline_obs' local obs_row "`obs_row' &"
						}
					}
				}
				* Add observations for long table
				else if !`widetable' {
					forvalues i = 1/`par_nr' {
						local obs_row "`obs_row' & `col`i'_obs'"
					}
				}
				* Add observations for stddiff and/or observationscolumn and letf column
				if "`stddiff_col'" != "" local obs_row "`obs_row' &"
				if "`observationscolumn'" != "" local obs_row "`obs_row' &"
				local obs_row `"`"`leftcobservations'`obs_row' \\"'"'			// use compund quotes because leftcobs may contain "
			}
		}

		* Print table
		listtab `using', ///
			rstyle(tabular) `replace' `appendfile' ///
			head(`prehead' ///
			`mnumbers' ///
			`group_row' ///
			`title1' ///
			`posthead' ///
			`end_foot') ///
			foot(`prefoot' ///
			`obs_row' ///
			`postfoot')
	}


	* Excel file
	else if "`filetype'" == "excel" {

		* General putexcel settings
		qui putexcel set "`using'", `replace' `modify' `tosheet'

		* Define area to print (first and last column, active line)
		find_printarea `col_nr', `cell' mataok(`mataok')

		* Select column (1) for alignment
		if `mataok' mata: st_local("col1", numtobase26(`first_col_n'+1))		// select column (1) with mata
		else local col1: word `=`first_col_n'+1' of `c(ALPHA)'					// select column (1) without mata

		* Header (nolines, nonumbers, ctitles, leftctitle options)
		if "`nohead'" == "" {
			if "`nolines'" == "" qui putexcel `first_col'`active_line':`last_col'`active_line' = border("top", "medium")
			if "`nonumbers'" == "" {
				forvalues i = 1/`col_nr' {
					if `mataok' mata: st_local("active_col", numtobase26(`first_col_n'+`i'))	// select active column with mata
					else local active_col: word `=`first_col_n'+`i'' of `c(ALPHA)'				// select active column without mata
					qui putexcel `active_col'`active_line' = ("(`i')")							// print column number
				}
				qui putexcel `first_col'`active_line' = halign("left") `col1'`active_line':`last_col'`active_line' = halign("center")
				local ++active_line
			}
			if `"`groups'"' != "" {
				if `"`sheet'"' == "" local sheet "_no_target_sheet_defined"
				groups_subopt_excel `first_col' `first_col_n' `active_line' `col_nr' `tot_nr' `mataok' `"`using'"' `"`sheet'"' `groups'
				local ++active_line
			}
			if `"`ctitles'"' != "" {
				if `"`leftctitle'"' == "" & `"`leftctitle'"' != "none" local leftctitle "Variable"
				else if `"`leftctitle'"' == "none" local leftctitle ""
				qui putexcel `first_col'`active_line' = (`"`leftctitle'"')
				forvalues i = 1/`col_nr' {
					if `mataok' mata: st_local("active_col", numtobase26(`first_col_n'+`i'))	// select active column with mata
					else local active_col: word `=`first_col_n'+`i'' of `c(ALPHA)'				// select active column without mata
					qui putexcel `active_col'`active_line' = (`"``i''"')
				}
				qui putexcel `first_col'`active_line' = halign("left") `col1'`active_line':`last_col'`active_line' = halign("center")
				local ++active_line
			}
			if "`nolines'" == "" qui putexcel `first_col'`active_line':`last_col'`active_line' = border("top", "thin")
		}

		* Save space for results and make active line skip to footer
		local results_line = `active_line'
		local active_line = `active_line'+`row_nr'-1

		* Footer (nolines, noobservations, leftcobservations option)
		if "`nofoot'" == "" {
			if "`noobservations'" == "" {
				local ++active_line
				if "`nolines'" == "" qui putexcel `first_col'`active_line':`last_col'`active_line' = border("top", "thin")
				if `"`leftcobservations'"' == "" local leftcobservations "Observations"
				qui putexcel `first_col'`active_line' = (`"`leftcobservations'"')
				* Add observations for wide table
				if `widetable' {
					local active_col_n = `first_col_n'+1
					forvalues i = 1/`par_nr' {
						if "`par`i'_type'" == "mean" {
							cap confirm variable mean`i'
							if !_rc {
								if `mataok' mata: st_local("active_col", numtobase26(`active_col_n'))	// select active column with mata
								else local active_col: word `active_col_n' of `c(ALPHA)'				// select active column without mata
								qui putexcel `active_col'`active_line' = ("`col`i'_obs'")
								local ++active_col_n
							}
							cap confirm variable sd`i'
							if !_rc local ++active_col_n
						}
						else if "`par`i'_type'" == "diff" {
							cap confirm variable diff`i'
							if !_rc | `oneline_obs' {					// with oneline, print obs count in column showing se/pval, instead of diff col
								if `mataok' mata: st_local("active_col", numtobase26(`active_col_n'))	// select active column with mata
								else local active_col: word `active_col_n' of `c(ALPHA)'				// select active column without mata
								qui putexcel `active_col'`active_line' = ("`col`i'_obs'")
								local ++active_col_n
							}
							cap confirm variable se`i'
							if !_rc & !`oneline_obs' local ++active_col_n
							cap confirm variable pval`i'
							if !_rc & !`oneline_obs' local ++active_col_n
						}
					}
				}
				* Add observations for long table
				else if !`widetable' {
					forvalues i = 1/`par_nr' {
						if `mataok' mata: st_local("active_col", numtobase26(`first_col_n'+`i'))	// select active column with mata
						else local active_col: word `=`first_col_n'+`i'' of `c(ALPHA)'				// select active column without mata			
						qui putexcel `active_col'`active_line' = ("`col`i'_obs'")
					}
				}
			}
			if "`nolines'" == "" qui putexcel `first_col'`active_line':`last_col'`active_line' = border("bottom", "medium")
		}

		* Set cell alignment for results and footer
		qui putexcel `first_col'`results_line':`first_col'`active_line' = halign("left") `col1'`results_line':`last_col'`active_line' = halign("center")

		* Close putexcel
		qui putexcel clear

		* Export actual results
		qui export excel using `"`using'"', `tosheet' cell(`first_col'`results_line') sheetmodify
	}

	* Restore user's dataset
	restore
end



*** Label wrapping ***

cap program drop wrap_subopt
program define wrap_subopt
	syntax [anything], [wrap_varwidth(numlist missingokay)]
	
	if ustrregexm("`anything'","indent") {
		c_local indent indent
		local anything = subinstr("`anything'","indent","",.)
	}
	if "`anything'" != "" {
		confirm number `anything'
		c_local maxvarwidth `anything'
		if "`wrap_varwidth'" != "" {
			cap assert `anything' <= `wrap_varwidth'
			if _rc {
				dis as error "Error: the number indicated in the {bf:wrap()} option cannot exceed the one indicated in the {bf:varwidth()} option"
				error 121
			}
		 }
	}

end



*** Processing of content inside parentheses (complex syntax) ***

cap program drop balancetable_parsing
program define balancetable_parsing
	version 14.0
	syntax anything(equalok name=to_parse)

	* Separate parenthesis and depvars
	local par_nr 0
	while strpos("`to_parse'", "(") > 0 {
		local ++par_nr
		gettoken par`par_nr'_all to_parse: to_parse, match(mattia)
	}
	c_local par_nr `par_nr'
	c_local depvarlist "`to_parse'"

	* Check parenthesis type
	forvalues i = 1/`par_nr' {
		if ustrregexm(`"`par`i'_all'"',"^(mean)[ ]*(if[ ]+(.*))?$") {
			c_local par`i'_type = ustrregexs(1)
			if ustrregexs(2) != "" c_local par`i'_if = "& (" + ustrregexs(3) + ")"		// this makes it compatible with marksample touse
		}
		else if ustrregexm(`"`par`i'_all'"',"^(diff)[ ]+([a-zA-z0-9_]+)[ ]*(if[ ]+(.*))?$") {
			c_local par`i'_type = ustrregexs(1)
			c_local par`i'_mainvar = ustrregexs(2)
			if ustrregexs(3) != "" c_local par`i'_if = "& (" + ustrregexs(4) + ")"		// this makes it compatible with marksample touse
		}
		else {
			dis as error "Error: syntax in parenthesis `i' is not allowed"
			error 197
		}
	}
end



*** Parsing of significance stars options ***

cap program drop stars_subopt
program define stars_subopt
	version 14.0
	syntax [anything(name=starlevels)]

	* Set defaults significance levels
	if "`starlevels'" == "" local starlevels "* 0.10 ** 0.05 *** 0.01"
	* Check starlevels match
	local nr_words: word count `starlevels'
	local nr_starlevels = `nr_words'/2
	cap confirm integer number `nr_starlevels'
	if _rc {
		dis as error "Error: significance thresholds and symbols do not match"
		error 197
	}
	* Check star thresholds and store them with symbols
	local max 1
	forvalues i = 1/`nr_starlevels' {
		local s`i'_thr: word `=`i'*2' of `starlevels'
		confirm number `s`i'_thr'
		if `s`i'_thr' > `max' | `s`i'_thr' <=0 {
			dis as error "Error: significance thresholds must be specified in descending order and must be in the (0,1] range"
			error 197
		}
		local max `s`i'_thr'
		c_local s`i'_thr: word `=`i'*2' of `starlevels'
		c_local s`i'_sym: word `=`i'*2-1' of `starlevels'
	}
	c_local nr_starlevels `nr_starlevels'
end



*** Oneline subroutine (obsolete) ***

cap program drop oneline_check
program define oneline_check
	version 14.0
	syntax anything(name=onelinesubopt), [se PVAL] [pvalues] [wrapok wrap wrapsubopt(string)]

	* Check that se and pval are not both specified at the same time
	if "`se'" != "" & "`pval'" != "" {
		dis as error "Error: {bf:oneline} should specify either {bf:se} or {bf:pval}, not both"
		error 184
	}
	* Check that se/pval are not specified/specified with the pvalues option
	if "`se'" != "" & "`pvalues'" != "" {
		dis as error "Error: you cannot specify {bf:oneline(se)} if the balance table should report pvalues"
		error 197
	}
	else if "`pval'" != "" & "`pvalues'" == "" {
		dis as error "Error: you cannot specify {bf:oneline(pval)} if the balance table should report standard errors"
		error 197
	}
	* Check that it is not specified with wrap
	if ("`wrap'" != "" | "`wrapsubopt'" != "") & "`wrapok'" == "" {
		dis as error "Error: the {bf:oneline} option is incompatible with {bf:wrap}"
		error 197
	}
end



*** Parsing of parentheses options ***

cap program drop par_subopt
program define par_subopt
	version 14.0
	syntax , [parstring(string asis) NOPAR]

	* Set default parentheses
	if `"`parstring'"' == "" & "`nopar'" == "" {
		local lpar "("
		local rpar ")"
	}
	* Nopar option
	else if `"`parstring'"' == "" & "`nopar'" != "" {
		local lpar ""
		local rpar ""
	}
	* Check that the par option takes only two arguments
	else if `: word count `parstring'' != 2 {
		dis as error "Error: {bf:par()} requires two arguments"
		error 197
	}
	else {
		tokenize `"`parstring'"'
		local lpar "`1'"
		local rpar "`2'"
	}
	* Pass arguments to main program
	c_local lpar "`lpar'"
	c_local rpar "`rpar'"
end



*** Parsing of extra options for statistic types (e.g. mean, sd, diff...) ***

cap program drop stattype_subopt
program define stattype_subopt
	version 14.0
	syntax name(name=stat), [fmt(string)] [par(string asis) NOPAR]

	* Check format and pass to main program
	if "`fmt'" != "" {
		confirm numeric format `fmt'
		c_local `stat'_fmt `fmt'
		c_local `stat'_customfmt 1
	}
	else c_local `stat'_customfmt 0

	* Check parentheses and pass to main program
	if `"`par'"' != "" | "`nopar'" != "" {
		par_subopt, parstring(`par') `nopar'
		c_local `stat'_lpar `lpar'
		c_local `stat'_rpar `rpar'
		c_local `stat'_custompar 1
	}
	else c_local `stat'_custompar 0
end



*** Manage groups suboptions (latex) ***

cap program drop groups_subopt_latex
program define groups_subopt_latex
	version 14.0
	syntax anything, ///
	[pattern(string)] ///
	[prefix(string) suffix(string)] ///
	[begin(string) end(string)] ///
	[leftc(string)]

	* Parse syntax (separate column number and title list and tokenize labels)
	gettoken col_nr group_labels: anything
	tokenize `"`group_labels'"'

	* Set defaults (prefix and suffix for LaTeX table, pattern if not specified)
	if "`pattern'" == "" local pattern 1
	if `"`prefix'"' == "" local prefix "\multicolumn{@span}{c}{"
	if `"`suffix'"' == "" local suffix "}"

	* Loop over columns
	local j 1											// label counter
	forvalues i = 1/`col_nr' {
		* Store locals with label and pattern
		local num: word `i' of `pattern'
		* Error for starting with 0
		if `i' == 1 & "`num'" == "0" {
			dis as error "Error: {bf:pattern()} cannot start with 0"
			error 124
		}
		* Start a new group 
		if "`num'" == "1" {
			if `i' != 1 {								// replace span for previous group (if not the first one)
				local group_row: subinstr local group_row "@span" "`span'", all
			}
			local group_row `"`group_row' & `prefix'``j''`suffix'"'
			local span 1								// spanned column counter
			local ++j
		}
		* Continue existing group
		else if "`num'" == "0" | "`num'" == "" local ++span
		* Error for invalid number
		else {
			dis as error "Error: only 0 or 1 are allowed in {bf:pattern(), {bf:`num'} is not a valid number}"
			error 125
		}
	}

	* Final changes
	local group_row: subinstr local group_row "@span" "`span'", all			// replace span for last column
	local group_row `"`begin'`leftc'`group_row'\\ `end'"'					// add left stub, begin, end, \\
	local group_row: subinstr local group_row "@col" "`col_nr'", all		// replace number of columns
	local group_row: subinstr local group_row "@tot" "`tot_nr'", all		// replace tot. number of columns
	c_local group_row `"`"`group_row'"'"'									// add compound quotes and send to main program "
end



*** Manage groups suboptions (excel) ***

cap program drop groups_subopt_excel
program define groups_subopt_excel
	version 14.0
	syntax anything(everything), ///
	[pattern(string)] ///
	[prefix(string) suffix(string)] ///
	[leftc(string)] ///
	[NOMERGE]
	args first_col first_col_n active_line col_nr tot_nr mataok using sheet
	tokenize `"`anything'"'
	macro shift 8					// the first 8 macros (`1', `2', etc.) are filled by args, so shift macro content

	* Nomata option (automatically triggers nomerge)
	if !`mataok' local nomerge "nomerge"

	* Set defaults (pattern if not specified)
	if "`pattern'" == "" local pattern 1

	* Set mata (to merge cells)
	if "`nomerge'" == "" {						// to actually merge cells, use mata (otherwise putexcel just centers the text, but does not merge)
		mata: b = xl()
		mata: b.load_book(`"`using'"')
		if `"`sheet'"' == "_no_target_sheet_defined" {		// print to first sheet by default (if no sheet() specified)
			mata: sheets_list = b.get_sheets()				// store list of sheets in Excel
			mata: st_local("sheet", sheets_list[1])			// get first sheet name and save to a local
		}
	}

	* Label left column
	if `"`leftc'"' != "" qui putexcel `first_col'`active_line' = (`"`leftc'"')

	* Loop over columns
	local j 1											// label counter
	local active_col `first_col_n'
	forvalues i = 1/`col_nr' {
		* Store local with pattern
		local num: word `i' of `pattern'
		* Error for starting with 0
		if `i' == 1 & "`num'" == "0" {
			dis as error "Error: {bf:pattern()} cannot start with 0"
			error 124
		}
		* Start a new group 
		if "`num'" == "1" {
			if `i' != 1 {								// replace span and tot for previous group (if not the first one)
				local group_text: subinstr local group_text "@span" "`span'", all
				local group_text: subinstr local group_text "@col" "`col_nr'", all
				local group_text: subinstr local group_text "@tot" "`tot_nr'", all
				local end_n `active_col'
				if `mataok' mata: st_local("end_l", numtobase26(`end_n'))
				else local end_l: word `end_n' of `c(ALPHA)'
				qui putexcel `start_l'`active_line' = (`"`group_text'"')
				qui putexcel `start_l'`active_line':`end_l'`active_line' = halign("merge")
				if "`nomerge'" == "" mata: b.set_sheet_merge(`"`sheet'"', (`active_line',`active_line'), (`start_n',`end_n'))	// merge cells with mata
			}
			local group_text `"`prefix'``j''`suffix'"'
			local span 1								// spanned column counter
			local ++j
			local ++active_col
			local start_n `active_col'
			if `mataok' mata: st_local("start_l", numtobase26(`start_n'))
			else local start_l: word `start_n' of `c(ALPHA)'
		}
		* Continue existing group
		else if "`num'" == "0" | "`num'" == "" {
			local ++span
			local ++active_col
		}
		* Error for invalid number
		else {
			dis as error "Error: only 0 or 1 are allowed in {bf:pattern(), {bf:`num'} is not a valid number}"
			error 125
		}
	}

	* Final changes
	local group_text: subinstr local group_text "@span" "`span'", all
	local group_text: subinstr local group_text "@col" "`col_nr'", all
	local group_text: subinstr local group_text "@tot" "`tot_nr'", all
	local end_n `active_col'
	if `mataok' mata: st_local("end_l", numtobase26(`end_n'))
	else local end_l: word `end_n' of `c(ALPHA)'
	qui putexcel `start_l'`active_line' = (`"`group_text'"')
	qui putexcel `start_l'`active_line':`end_l'`active_line' = halign("merge")
	if "`nomerge'" == "" mata: b.set_sheet_merge(`"`sheet'"', (`active_line',`active_line'), (`start_n',`end_n'))
end



*** Define area to print in Excel ***

cap program drop find_printarea
program define find_printarea
	version 14.0
	syntax anything(name=col_nr), ///
	[cell(string)] [mataok(numlist)]

	* Defaults without cell option (set first and last cell)
	if "`cell'" == "" {
		local active_line 1								// set first row as row 1
		local first_col_n 1								// set first column as number (column A)
		local first_col_l "A"							// set first column as letter (column A)
	}

	* Cell option (store first cell)
	else {
		* De-compose cell reference (first cell)
		if regexm("`cell'","^([A-Z]+)([0-9]+)$") {
			local active_line = regexs(2)
			local first_col_l = regexs(1)
		}
		* Error if invalid cell reference
		else {
			dis as error "Error: {bf:`cell'} is not a valid cell reference"
			error 197
		}
		* Convert first cell from letter to number with mata
		if `mataok' {
			local first_col_n 0
			while "`col_l'" != "`first_col_l'" {
				local ++first_col_n
				mata: st_local("col_l", numtobase26(`first_col_n'))
			}
		}
		* Convert first cell from letter to number without mata
		else {
			local first_col_n 0
			while "`col_l'" != "`first_col_l'" & `first_col_n' < 27 {
				local ++first_col_n
				local col_l: word `first_col_n' of `c(ALPHA)'
			}
			if `first_col_n' == 27 | `first_col_n' + `col_nr' > 26 {
				dis as error "Error: with the {bf:nomata} option, {bf:balancetable} cannot print beyond column Z"
				dis as error "(check the {bf:cell()} option or reduce the number of columns of the balance table)"
				exit 198
			}
		}
	}

	* Determine and store last cell
	local last_col_n = `first_col_n' + `col_nr'			// store last column as number
	* Convert last cell to letter with mata
	if `mataok' {
		mata: st_local("last_col_l", numtobase26(`last_col_n'))
	}
	* Convert last cell to letter without mata
	else {
		local last_col_l: word `last_col_n' of `c(ALPHA)'
	}

	* Pass references to main program
	c_local first_col `first_col_l'
	c_local first_col_n `first_col_n'
	c_local last_col `last_col_l'
	c_local last_col_n `last_col_n'
	c_local active_line `active_line'
end
