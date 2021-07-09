*! version 2.0.0 28jun2018 daniel klein
program kappaetc , byable(onecall)
	version 11.2
	
	if (replay()) {
		if (_by()) {
			error 190
		}
		kappaetc_display `0'
		exit 0
	}
	
	if (_by()) {
		local BY by `_byvars' `_byrc0' :
	}
	
	`BY' kappaetc_parse_cmd2 `0'
	`BY' kappaetc_cmd_`cmd2' `0'
end

/* ---------------------------------------------------------------------------
	command switcher
--------------------------------------------------------------------------- */

program kappaetc_parse_cmd2 , byable(onecall) // noby
	version 11.2
	
	local zero : copy local 0 // copy cmdline
	gettoken anything 0 : 0 , parse(",") bind
	syntax 						///
	[ , 						///
		TTEST 			/// ignored
		SPECific 				///
		DICE /// alias for specific
		ICC(passthru) 			///
		LOA95 					///
		LOA(passthru) 			///
		REPLAY 					/// not documented
		RESTORE 				/// not documented
		* 			/// any options
	]
	
	_kappaetc_strip_internal_opts , `options'
	
	if (mi(`"`specific'`dice'`icc'`loa95'`loa'"')) {
		// one of cac, ttest, replay, or restore
		local 0 : copy local zero
		gettoken name1 0 : 0 , parse(" =")
		gettoken equal 0 : 0 , parse(" =")
		if (!inlist(`"`equal'"', "=", "==") & mi("`replay'`restore'")) {
			local cmd2 cac // default
		}
		else if (_by()) {
			error 190
		}
		else if (inlist(`"`equal'"', "=", "==")) {
			local zero `name1' `0'
			local cmd2 ttest
		}
		else if ("`replay'`restore'" != "") {
			local cmd2 replay
		}
		else {
			_kappaetc_internal_error parse_cmd2
			// NotReached
		}
	}
	else if ("`specific'`dice'" != "") {
		local cmd2 dice
	}
	else if (`"`icc'"' != "") {
		local cmd2 icc
	}
	else if (`"`loa95'`loa'"' != "") {
		local cmd2 loa
	}
	else {
		_kappaetc_internal_error parse_cmd2
		// NotReached
	}
	
	c_local 0 		: copy local zero
	c_local cmd2 	: copy local cmd2
end

/* ---------------------------------------------------------------------------
	display results
--------------------------------------------------------------------------- */

program kappaetc_display
	version 11.2
	
	if ("`r(cmd)'" != "kappaetc") {
		display as err "last command not kappaetc"
		exit 301
	}
	
	local cmd2 = cond(mi("`r(cmd2)'"), "cac", "`r(cmd2)'")
	if (!inlist("`cmd2'", "cac", "ttest", "icc", "loa", "dice")) {
		display as err "last command not kappaetc"
		exit 301
	}
	
	syntax [ , * ]
	_kappaetc_strip_internal_opts , `options'
	kappaetc_get_diopts `cmd2' , `options' setclocals fmtnoisily
	
	if ("`cmd2'" == "loa") {
		display as txt "nothing to replay"
		exit 0
	}
	
	mata : kappaetc_ado_rtable()
	
	if (!c(noisily)) {
		exit 0
	}
	
	if (("`cmd2'" == "ttest") & ("`replay'" != "")) {
		kappaetc_cmd_replay `r(results1)' `r(results2)' , `options'
	}
	
	if (mi("`noheader'")) {
		kappaetc_display_header_`cmd2'
	}
	
	if (mi("`notable'")) {
		kappaetc_display_table_`cmd2' , `options'
	}
	
	if (("`showscale'" != "") & ("`benchmark_method'" != "")) {
		kappaetc_display_showbenchmark `cformat' ///
		(`benchmark_scale') (`benchmark_label')
	}
	
	if ("`showweights'" != "") {
		display
		display as txt "Weighting matrix (`r(wgt)' weights)" _continue
		matlist r(W) , format(%5.4f) nonames nohalf left(2)
	}
	
	if ("`conditionalmat'`vsmat'" != "") {
		if ("`conditionalmat'" != "") {
			display
			display as txt "Conditional probability table"
			display as txt "(Pr[column|row])"
			matlist r(b_conditional) , format(`cformat') left(2) twidth(18)
		}
		if ("`vsmat'" != "") {
			display
			display as txt "Specific agreement"
			display as txt "(row vs. column)"
			matlist r(b_vs) , format(`cformat') left(2) twidth(18)
		}
	}
end

// ------------------------------------- header
program kappaetc_display_header_cac // _dice
	version 11.2
	
	display
	display as txt "Interrater agreement" _continue
	display as txt %47s "Number of subjects"  				" = " 	///
		as res %7.0g r(N)
	if (inlist("`r(cmd2)'", "", "cac")) {
		if ("`r(wgt)'" != "identity") {
			local line2 "weighted"
		}
		if ("`r(acm)'" != "") {
			local line2 "`line2' ACM"
		}
		if ("`line2'" != "") {
			local line2 "(`line2' analysis)"
		}
		display as txt "`line2'" _continue
	}
	else if ("`r(cmd2)'" == "dice") {
		local line2 "(Specific agreement)"
		display as txt "`line2'" _continue
		if ("`r(setype)'" != "nose") {
			local line2 // void
			display as txt %47s "Replications" 				" = " 	///
				as res %7.0g r(reps)
		}
	}
	local pos = 67 - strlen("`line2'")
	if (r(r_min) != r(r_max)) {
		local cmin ": min"
		local rval r(r_min)
	}
	else {
		local rval r(r_max)
	}
	display as txt %`pos's "Ratings per subject`cmin'" 		" = " 	///
		as res %7.0g `rval'
	if (r(r_min) != r(r_max)) {
		display as txt %67s "avg" 							" = " 	///
			as res %7.0g r(r_avg)
		display as txt %67s "max" 							" = " 	///
			as res %7.0g r(r_max)
	}
	display as txt %67s "Number of rating categories" 		" = " 	///
		as res %7.0f `= rowsof(r(categories))'
end

program kappaetc_display_header_ttest
	version 11.2
	
	local name1 = abbrev(r(results1), 30)
	local name2 = abbrev(r(results2), 30)
	local len12 = strlen("`name1'`name2'")
	local cdiff = min(58, (78 - (16 + `len12')))
	
	local name1 {stata kappaetc `r(results1)' , replay:{res:`name1'}}
	local name2 {stata kappaetc `r(results2)' , replay:{res:`name2'}}
	
	display
	display as txt "Paired t tests of agreement coefficients" _continue
	display as txt %27s "Number of subjects"  				" = " 	///
		as res %7.0g r(N)
	display as txt _col(`cdiff') "Differences " 					///
		_skip(`= 4 - `len12'') 										///
		as txt "(" as res "`name1'" as txt ")" 						///
		as txt "-" 													///
		as txt "(" as res "`name2'" as txt ")"
end

program kappaetc_display_header_dice
	version 11.2
	kappaetc_display_header_cac
end

program kappaetc_display_header_icc
	version 11.2
	
	if ("`r(model_number)'" == "1B") {
		local Inter Intra
	}
	else if (("`r(model_number)'" != "1") & (r(m_max) > 1)) {
		local Inter Inter/Intra
	}
	else {
		local Inter Inter
	}
	local pos = 50 - strlen("`Inter'")
	
	local model "`r(model)'"
	if ("`model'" == "oneway") {
		local Xway 	One-way
		local model random
	}
	else {
		local Xway 	Two-way
	}
	
	display
	display as txt "`Inter'rater reliability" _continue
	display as txt %`pos's "Number of subjects" 			" = " 	///
		as res %7.0g r(N)
	display as txt "`Xway' `model'-effects model" _continue
	local pos = 39 + ("`model'" == "mixed")
	if (r(r_min) != r(r_max)) {
		local rmin ": min"
		local rval r(r_min)
	}
	else {
		local rval r(r_max)
	}
	display as txt %`pos's "Ratings per subject`rmin'" 		" = " 	///
		as res %7.0g `rval'
	if (r(r_min) != r(r_max)) {
		display as txt %67s "avg" 							" = " 	///
			as res %7.0g r(r_avg)
		display as txt %67s "max" 							" = " 	///
			as res %7.0g r(r_max)
	}
	if (r(m_max) == 1) {
		exit 0
	}
	if (r(m_min) != r(m_max)) {
		local mmin ": min"
		local rval r(m_min)
	}
	else {
		local rval r(m_max)
	}
	display as txt %67s "Replicates per subject`mmin'" 		" = " 	///
		as res %7.0g `rval'
	if (r(m_min) != r(m_max)) {
		display as txt %67s "avg" 							" = " 	///
			as res %7.0g r(m_avg)
		display as txt %67s "max" 							" = " 	///
			as res %7.0g r(m_max)
	}
end

// ------------------------------------- tables
program kappaetc_display_table_cac // _ttest _dice
	version 11.2
	
	syntax [ , * ]
	kappaetc_get_diopts `r(cmd2)' , `options' setclocals
	
	if ("`benchmark_method'" != "") {
		kappaetc_display_table_benchmark , `options'
		exit 0
	}
	
	if ("`r(cmd2)'" == "ttest") {
		local Coef Diff.
	}
	else {
		local Coef Coef.
	}
	
	if ("`r(cmd2)'" == "dice") {
		local seplastline seplastline
	}
	
	capture noisily confirm matrix r(table)
	if (_rc) {
		_kappaetc_internal_error display_table_cac
		// NotReached
	}
	
	local rownames : rownames r(table)
	local t_name : word 3 of `rownames'
	if (mi("`relop'")) {
		local title_pcol 	51
		local absbar 		"|"
	}
	else {
		local title_pcol 	52
		local absbar 		// void
	}
	local invrelop 	= cond(("`relop'" == ">"), "<", ">")
	local P 		P`invrelop'`absbar'`t_name'`absbar'
	
	local title_cicol = (61 - strlen("`: display r(level)'"))
	
	display as txt "{hline 21}{c TT}{hline 56}"
	if ( 																///
		inlist("`r(cmd2)'", "", "cac", "dice") 							///
		& ( 															///
	inlist("`r(setype)'", "jackknife", "unconditional", "bootstrap") 	///
		| ("`r(seconditional)'" == "subjects") ) 						///
	) {
		display as txt _col(22) "{c |}" _continue
		local title2_secol 31
		local title2_citype 63
		if (inlist("`r(setype)'", "jackknife", "bootstrap")) {
			local title2_secol = (`title2_secol' + 2)
			if ("`r(setype)'" == "bootstrap") {
				if (inlist("`citype'", "", "normal")) {
					local CItype "Normal-based"
				}
				else if ("`citype'" == "percentile") {
					local CItype "Percentile"
					local title2_citype 64
				}
				else if ("`citype'" == "bc") {
					local CItype "Bias-corrected"
					local title2_citype 62
				}
			}
		}
		local setype_txt = strproper("`r(setype)'")
		if ("`r(seconditional)'" == "subjects") {
			local setype_txt "Subject Cond."
		}
		display 														///
			as txt _col(`title2_secol') "`setype_txt'" 			 		///
			as txt _col(`title2_citype') "`CItype'"
	}
	display 															///
		as txt _col(22) "{c |}" 										///
		as txt _col(26) "`Coef'" 										///
		as txt _col(33) "Std. Err." 									///
		as txt _col(46) "`t_name'" 										///
		as txt _col(`title_pcol') "`P'" 								///
		as txt _col(`title_cicol') "[" r(level) "% Conf. Interval]"
	display as txt "{hline 21}{c +}{hline 56}"
	
	kappaetc_display_table_rows r(table) 								///
	, cformat(`cformat') sformat(`sformat') pformat(`pformat') `seplastline'
	
	display as txt "{hline 21}{c BT}{hline 56}"
	
	if ("`r(cmd2)'" == "ttest") {
		exit 0
	}
	
	if ((`testvalue') | ("`relop'" != "")) {
		if (mi("`relop'")) {
			local invrelop "!="
		}
		local col = (3 - strlen("`relop'"))
		display as txt %20s "`t_name' test Ho: Coef. `relop'=" 		///
			_col(23) `cformat' `testvalue' 							///
			_col(33) "Ha: Coef. `invrelop' " `cformat' `testvalue'
	}
	
	mata : kappaetc_ado_rtable_ciclipped()
	
	if ( 																///
	inlist("`r(setype)'", "jackknife", "unconditional", "bootstrap") 	///
	| ("`r(seconditional)'" == "subjects") 								///
	) {
		local setype jackknife
		local pre jk
		if ("`r(setype)'" == "bootstrap") {
			local setype bootstrap
			local pre bs
		}
		if (r(`pre'_miss) > 0) {
			if (r(`pre'_miss) > 1) {
				local s s
			}
			display as txt "Note: `r(`pre'_miss)' coefficient`s' " 		///
			"could not be estimated in `setype' replications."
		}
	}
end

program kappaetc_display_table_benchmark
	version 11.2
	
	syntax [ , * ]
	kappaetc_get_diopts `r(cmd2)' , `options' setclocals
	
	if ("`benchmark_method'" == "probabilistic") {
		local _method _prob
		if (strlen("`: display r(level)'") < 3) {
			local space " "
		}
		local P : display "`space'>" r(level) "%"
	}
	else if ("`benchmark_method'" == "deterministic") {
		local _method _det
		local P "P cum."
	}
	else {
		_kappaetc_internal_error display_table_benchmark
		// NotReached
	}
	
	display as txt "{hline 21}{c TT}{hline 56}"
	display as txt _col(22) "{c |}" _continue
	
	if ( 																///
	inlist("`r(setype)'", "jackknife", "unconditional", "bootstrap") 	///
		| ("`r(seconditional)'" == "subjects") 							///
	) {
		local title2_secol = 31
		if (inlist("`r(setype)'", "jackknife", "bootstrap")) {
			local title2_secol = (`title2_secol' + 2)
		}
		local setype_txt = strproper("`r(setype)'")
		if ("`r(seconditional)'" == "subjects") {
			local setype_txt "Subject Cond."
		}
		display as txt _col(`title2_secol') "`setype_txt'" _continue
	}
	if ("`benchmark_method'" == "probabilistic") {
		display as txt _col(51) "P cum." _continue
	}
	display as txt _col(62) strproper("`benchmark_method'")
	display 													///
		as txt _col(22) "{c |}" 								///
		as txt _col(26) "Coef." 								///
		as txt _col(33) "Std. Err." 							///
		as txt _col(44) "P in." 								///
		as txt _col(51) "`P'" 									///
		as txt _col(59) "[Benchmark Interval]"
	display as txt "{hline 21}{c +}{hline 56}"
	
	kappaetc_display_table_rows r(table_benchmark`_method') 	///
	, cformat(`cformat') sformat(`sformat') pformat(`pformat')
	
	display as txt "{hline 21}{c BT}{hline 56}"
end

program kappaetc_display_table_ttest
	version 11.2
	kappaetc_display_table_cac `0'
end

program kappaetc_display_table_dice
	version 11.2
	kappaetc_display_table_cac `0'
end

program kappaetc_display_table_icc
	version 11.2
	
	syntax [ , * ]
	kappaetc_get_diopts `r(cmd2)' , `options' setclocals
	
	if (mi("`variance'")) {
		local sqrt sqrt
	}
	else {
		local sq 2
	}
	
	tempname table
	kappaetc_display_table_get_table `table' r(table) names cols 
	
	local c1 _col(17)
	local c2 _col(26)
	local c3 _col(35)
	local c4 _col(43)
	local c5 _col(52)
	local c6 _col(59)
	
	local title_cicol = (61 - strlen("`: display r(level)'"))
	
	display as txt "{hline 15}{c TT}{hline 62}"
	display 														///
		as txt _col(16) "{c |}" 									///
		as txt _col(20) "Coef." 									///
		as txt _col(30) "F" 										///
		as txt _col(36) "df1" 										///
		as txt _col(44) "df2" 										///
		as txt _col(53) "P>F" 										///
		as txt _col(`title_cicol') "[" r(level) "% Conf. Interval]"
	display as txt "{hline 15}{c +}{hline 62}"
	forvalues j = 1/`cols' {
		gettoken name names : names , parse(";")
		gettoken semi names : names , parse(";")
		local name "`name'(`r(model_number)',1)"
		local ul : display `cformat' `table'[6, `j']
		local c7 = (72 - strlen("`ul'") + 6)
		local c7 _col(`c7')
		display 													///
			as txt %14s "`name'" _col(16) "{c |}" 					///
			as res `c1' `cformat' `table'[1, `j'] 					///
			as res `c2' `sformat' `table'[2, `j'] 					///
			as res `c3' `sformat' `table'[3, `j'] 					///
			as res `c4' `sformat' `table'[4, `j']					///
			as res `c5' `pformat' `table'[5, `j'] 					///
			as res `c6' `cformat' `table'[6, `j'] 					///
			as res `c7' `cformat' `table'[7, `j']
	}
	display as txt "{hline 15}{c +}{hline 62}"
	if ("`r(model_number)'" == "1B") {
		local sigma_list r
	}
	else {
		local sigma_list s
	}
	if ("`r(model_number)'" == "2") {
		local sigma_list `sigma_list' r
	}
	if (r(has_sr)) {
		local sigma_list `sigma_list' sr
	}
	local sigma_list `sigma_list' e 
	foreach x of local sigma_list {
		if (r(sigma2_`x') < 0) {
			local rval 0
			local note " (replaced)"
		}
		else {
			local rval r(sigma2_`x')
			local note // void
		}
		display as txt %14s "sigma`sq'_`x'" _col(16) "{c |}" 		///
			as res `c1' `cformat' `sqrt'(`rval') as txt "`note'"
	}
	display as txt "{hline 15}{c BT}{hline 62}"
	
	if (`testvalue') {
		display as txt _col(2) "F test"
		display as txt %14s "Ho: Coef. <=" 							///
			_col(17) `cformat' `testvalue' 							///
			_col(30) "Ha: Coef. > " `cformat' `testvalue'
	}
	
	mata : kappaetc_ado_rtable_ciclipped()
	
	if (r(M_missing)) {
		display as txt "Note: F test and confidence intervals " 	///
			"are based on methods for complete data."
	}
end

program kappaetc_display_table_rows
	version 11.2
	
	syntax anything 												///
	, 																///
		CFORMAT(string) 											///
		SFORMAT(string) 											///
		PFORMAT(string) 											///
	[																///
		SEPLASTLINE 												///
	]
	
	local c1 _col(23)
	local c2 _col(33)
	local c3 _col(42)
	local c4 _col(51)
	local c5 _col(59)
	
	tempname table
	kappaetc_display_table_get_table `table' `anything' names cols
	
	forvalues j = 1/`cols' {
		gettoken name names : names , parse(";")
		gettoken semi names : names , parse(";")
		if (!el(r(estimable), 1, `j')) {
			continue
		}
		local ul : display `cformat' `table'[6, `j']
		local c6 = (72 - strlen("`ul'") + 6)
		local c6 _col(`c6')
		display 													///
			as txt %20s "`name'" _col(22) "{c |}" 					///
			as res `c1' `cformat' `table'[1, `j'] 					///
			as res `c2' `cformat' `table'[2, `j'] 					///
			as res `c3' `sformat' `table'[3, `j'] 					///
			as res `c4' `pformat' `table'[4, `j']					///
			as res `c5' `cformat' `table'[5, `j'] 					///
			as res `c6' `cformat' `table'[6, `j']
		if (("`seplastline'" != "") & (`j' == (`cols'-1))) {
			display as txt "{hline 21}{c +}{hline 56}"
		}
	}
end

program kappaetc_display_table_get_table
	version 11.2
	
	args tmptable rtable colnames ncols
	
	confirm matrix `rtable'
	matrix `tmptable' = `rtable'
	
	mata : st_local("`colnames'", 							///
		invtokens(st_matrixcolstripe("`tmptable'")[, 2]' :+ ";"))
	
	c_local `colnames' 	: copy local `colnames'
	c_local `ncols' 	= colsof(`tmptable')
end

program kappaetc_display_showbenchmark
	version 11.2
	
	gettoken cformat 		 0 : 0
	gettoken benchmark_scale 0 : 0 , match(par)
	gettoken benchmark_label 0 : 0 , match(par)
	
	local lcformat : copy local cformat
	local rcformat : subinstr local cformat "%" "%-"
	
	display
	display as txt %20s "Benchmark scale"
	
	display
	local J  : word count `benchmark_scale'
	local ul : word 1 of `benchmark_scale'
	local ul : display `rcformat' `ul'
	mata : st_local("ll", char(32)*strlen(st_local("ul")))
	local label : word 1 of `benchmark_label'
	display as txt %11s "`ll'" "<" "`ul'" _col(25) `"`label'"'
	forvalues j = 1/`--J' {
		local ll : word `j' of `benchmark_scale'
		local ul : word `= `j'+1' of `benchmark_scale'
		local ll : display `lcformat' `ll'
		local ul : display `rcformat' `ul'
		local label : word `= `j' + 1' of `benchmark_label'
		display as txt %11s "`ll'" "-" "`ul'" _col(25) `"`label'"'
	}
end

// ------------------------------------- parse display options
program kappaetc_get_diopts
	version 11.2
	
	syntax [ name(name = cmd2) ] 	///
	[ , 							///
		SETCLOCALS 	/// internal option
		FMTNOISILY 	/// internal option
		* 			/// display options
	]
	
	if (inlist("`cmd2'", "", "cac", "ttest", "dice", "icc")) {
		local DIOPTS 				///
			Level(cilevel) 			///
			noHeader 				///
			noTABle 				///
			CFORMAT(passthru) 		///
			PFORMAT(passthru) 		///
			SFORMAT(passthru)
	}
	
	if (inlist("`cmd2'", "", "cac", "dice", "icc")) {
		local DIOPTS `DIOPTS' 		///
			TESTVALue(passthru) 	///
			noCICLIPped
	}
	
	if (inlist("`cmd2'", "", "cac")) {
		local DIOPTS `DIOPTS' 		///
			CAC 			/// ignored
			SHOWWeights 			///
			BENCHmark42 			///
			BENCHmark(string asis) 	///
			SHOWScale 				///
			LARGESAMPLE
	}
	else if ("`cmd2'" == "ttest") {
		local DIOPTS `DIOPTS'		///
			TTEST 			/// ignored
			REPLAY
			
	}
	else if ("`cmd2'" == "dice") {
		local DIOPTS `DIOPTS' 		///
			SPECific 		/// ignored
			DICE 			/// ignored
			CONDitionalmat 			///
			VSmat 					///
			CItype(string asis) 	///
			LABelcategories(name)
	}
	else if ("`cmd2'" == "icc") {
		local DIOPTS `DIOPTS'		///
			ICC 			/// ignored
			STDDEViations 			///
			VARiance
	}
	else if ("`cmd2'" == "loa") {
		local DIOPTS `DIOPTS' 		///
			LOA95 			/// ignored
			LOA(cilevel) 			///
			CFORMAT(passthru)
	}
	else {
		_kappaetc_internal_error get_diopts
		// NotReached
	}
	
	local 0 , `options'
	syntax [ , `DIOPTS' ]
	
	kappaetc_get_diopts_fmt_opts , `cformat' `pformat' `sformat' `fmtnoisily'
	
	if (`"`benchmark42'`benchmark'"' != "") {
		kappaetc_get_diopts_bench_opt `benchmark'
	}
	
	if (`"`citype'"' != "") {
		if (`"`r(setype)'"' != "bootstrap") {
			display as err "option citype() not allowed"
			exit 198
		}
		kappaetc_get_diopts_citype_opt `citype'
	}
	
	kappaetc_get_diopts_testval `cmd2' , `testvalue'
	
	if ("`labelcategories'" != "") {
		mata : st_local("vlok", strofreal(st_vlexists("`labelcategories'")))
		if (!`vlok') {
			local newlabelcategories : value label `labelcategories'
			if (mi("`newlabelcategories'")) {
				display as err "value label `labelcategories' not found"
				exit 111
			}
			local labelcategories : copy local newlabelcategories
		}
	}
	
	if (("`stddeviations'" != "") & ("`variance'" != "")) {
		display as err "only one of " 					/// 
			"stddeviations or variance may be specified"
		exit 198
	}
	
	if (mi("`setclocals'")) {
		exit 0
	}
	
	c_local level 				: copy local level
	c_local noheader 			: copy local header
	c_local notable 			: copy local table
	c_local cformat 			: copy local cformat
	c_local pformat 			: copy local pformat
	c_local sformat 			: copy local sformat
	c_local showweights 		: copy local showweights
	c_local benchmark_method 	: copy local benchmark_method
	c_local benchmark_scale 	: copy local benchmark_scale
	c_local benchmark_label 	: copy local benchmark_label
	c_local showscale 			: copy local showscale
	c_local largesample 		: copy local largesample
	c_local testvalue 			: copy local testvalue
	c_local relop 				: copy local relop
	c_local ciclipped 			: copy local ciclipped
	c_local citype 				: copy local citype
	c_local conditionalmat 		: copy local conditionalmat
	c_local vsmat 				: copy local vsmat
	c_local labelcategories 	: copy local labelcategories
	c_local variance 			: copy local variance
	c_local replay 				: copy local replay
	c_local loa 				: copy local loa
end

program kappaetc_get_diopts_fmt_opts
	version 11.2
	
	syntax 							///
	[ , 							///
		CFORMAT(string) 			///
		PFORMAT(string) 			///
		SFORMAT(string) 			///
		FMTNOISILY 	/// internal option
	]
	
	local cfmt %8.4f
	local pfmt %5.3f
	local sfmt %6.2f
	
	foreach fmt in c p s {
		if mi("``fmt'format'") {
			local `fmt'format ``fmt'fmt'
		}
		else {
			capture noisily confirm numeric format ``fmt'format'
			if (_rc) {
				exit 198
			}
			local `fmt'format : subinstr local `fmt'format "-" ""
			if ("`fmt'" == "c") {
				local fmtwidth : display ``fmt'format' 0.123456789
				local fmtwidth = strlen("`fmtwidth'")
			}
			else {
				local fmtwidth = fmtwidth("``fmt'format'")
			}
			if (`fmtwidth' > fmtwidth("``fmt'fmt'")) {
				if ("`fmtnoisily'" != "") {
					display as txt ///
						"note: invalid `fmt'format(), using default"
				}
				local `fmt'format ``fmt'fmt'
			}
		}
	}
	
	c_local cformat : copy local cformat
	c_local pformat : copy local pformat
	c_local sformat : copy local sformat
end

program kappaetc_get_diopts_bench_opt
	version 11.2
	
	/*
		map old syntax 
			
			benchmark([ <method> ] [ <options> ]) 
			
		to new syntax
		
			benchmark([ <method> ][ , <options> ])
	*/
	
	syntax [ anything(id = "benchmark method") ] [ , * ]
	if (`"`anything'"' != "") {
		local newopts : copy local options
		local 0 , `anything'
		syntax 				///
		[ , 				///
			Probabilistic 	///
			Deterministic 	///
			* 				///
		]
		local 0 , `newopts' `options'
	}
	
	capture noisily syntax 	///
	[ , 					///
		Scale(string) 		///
		LABEL(string asis) 	/// not documented
	]
	
	if (_rc) {
		display as err "option benchmark() invalid"
		exit 198
	}
	
	if mi("`probabilistic'`deterministic'") {
		local probabilistic probabilistic
	}
	else if (("`probabilistic'" != "") & ("`deterministic'" != "")) {
		display as err "option benchmark() invalid; " ///
		"only one of probabilistic or deterministic is allowed"
		exit 198
	}
	
	if mi("`scale'") {
		local scale landis koch
	}
	
	local 0 , `scale'
	capture syntax 	///
	[ , 			///
		LANDIS 		///
		KOCH 		///
		FLEISS 		///
		ALTMAN 		///
	]
	
	if (!_rc) {
		local n : word count `landis'`koch' `fleiss' `altman'
		if (`n' > 1) {
			display as err "option benchmark() invalid; " 	///
			"only one of landis/koch, fleiss or altman allowed"
			exit 198
		}
		if ("`landis'`koch'" != "") {
			local scale 0 .2 .4 .6 .8 1
			local scalelabel 								///
			`"Poor Slight Fair Moderate Substantial "Almost Perfect""'
		}
		else if ("`fleiss'" != "") {
			local scale .4 .75 1
			local scalelabel `"Poor "Intermediate to Good" Excellent"'
		}
		else if ("`altman'" != "") {
			local scale .2 .4 .6 .8 1
			local scalelabel `"Poor Fair Moderate Good "Very Good""'
		}
		else {
			_kappaetc_internal_error get_diopts_bench_opt
			// NotReached
		}	
	}
	else {
		local 0 , scale(`scale')
		capture noisily syntax , scale(numlist ascending >=0 <=1)
		local rc = _rc
		if (!`rc') {
			local nscale : word count `scale'
			if (`: word `nscale' of `scale'' < 1) {
				local scale `scale' 1
				local ++nscale
			}
			if (`nscale' < 2) {
				local rc 122
			}
		}
		if (`rc') {
			display as err "option benchmark() invalid"
			exit `rc'
		}
	}
	
	if (`"`label'"' != "") {
		if ((`: word count `label'') != (`: word count `scale'')) {
			display as err "option benchmark() invalid; " ///
			"number of labels does not match number of benchmarks"
			exit 198
		}
		local scalelabel : copy local label
	}
	
	c_local benchmark_method 	`probabilistic'`deterministic'
	c_local benchmark_scale 	: copy local scale
	c_local benchmark_label 	: copy local scalelabel
end

program kappaetc_get_diopts_citype_opt
	version 11.2
	
	gettoken citype void : 0 , qed(syntaxerr)
	if ((`"`void'"' != "") | (`syntaxerr')) {
		display as err "option {bf:ci()} invalid"
		exit 198
	}
	
	local 0 , `citype'
	syntax 			///
	[ , 			///
		NORmal 		///
		Percentile 	///
		BC 			///
		* 	/// unknown
	]
	
	if (`"`options'"' != "") {
		display as err "option {bf:ci()} invalid"
		display as err "unkonwn {it:citype} `options'"
		exit 198
	}
	
	c_local citype `normal' `percentile' `bc'
end

program kappaetc_get_diopts_testval
	version 11.2
	
	capture syntax [ name(name = cmd2) ] [ , TESTVALUE(real 0) ]
	if (_rc) {
		if (inlist("`cmd2'", "", "cac", "dice")) {
			local OPTARG string asis
		}
		else {
			local OPTARG real 0
		}
		syntax [ name(name = cmd2) ] [ , TESTVALUE(`OPTARG') ]
		gettoken relop testvalue : testvalue , parse("><=") qed(syntaxerr)
		if ((`syntaxerr') | ///
			!inlist(`"`relop'"', ">", "<", "=", ">=", "<=", "==")) {
			display as err "option testvalue() incorrectly specified"
			exit 198
		}
		gettoken relop : relop , parse("=")
		local 0 , testvalue(`testvalue')
		syntax , TESTVALUE(numlist max=1 >=0 <=1)
		if inlist("`relop'", "=", "==") {
			local relop // void
		}
	}
	else if (!inrange(`testvalue', 0, 1)) {
		display as err "testvalue() invalid -- " _continue
		error 125
	}
	
	c_local testvalue 	: copy local testvalue
	c_local relop 		: copy local relop
end

/* ---------------------------------------------------------------------------
		Stata main routines and subroutines
--------------------------------------------------------------------------- */

/* ---------------------------------------------------------------------------
	chance-corrected agreement coefficients (cac)
--------------------------------------------------------------------------- */

program kappaetc_cmd_cac , byable(recall)
	version 11.2
	
	syntax varlist(min = 2 numeric) 					///
	[ if ] [ in ] [ fweight aweight iweight ] 			/// 
						/// aweights are not yet documented
	[ , 												///
		Wgt(string asis) 								///
		SE(passthru) 									///
		NOSE 											///
		LISTwise 										///
		CASEwise 			/// retain synonym for listwise
		FREquency 										///
		CATegories(passthru) 							///
		ACM(varname numeric) 							/// not documented
		DFmat(name) 									/// not documented
		NSUBJECTS(numlist integer missingok max = 1 >0) ///
		NRATERS(numlist integer missingok max = 1 >0) 	///
		STOre(string asis) 								///
		RETURNMORE 					/// additional results; not documented
		* 								/// display options
	]
	
	kappaetc_get_store_opt `store' , by(`= _by()') byindex(`= _byindex()')
	
	local varlist : list uniq varlist
	local varlist : list varlist - acm
	if (`: word count `varlist'' < 2) {
		error 102
	}
	
	kappaetc_get_diopts cac , `options'
	
	kappaetc_get_wgt_opt `wgt'
	
	kappaetc_get_se_opt cac , `se' `nose' 			///
		wtype("`weight'") byindex(`= _byindex()') 	///
		`frequency' `krippendorff'
	
	kappaetc_get_cat_opt `varlist' , `categories' `frequency'
	
	kappaetc_get_df_opt `dfmat' , `largesample'
	
	if ("`casewise'" != "") {
		local listwise listwise
	}
	
	if (mi("`listwise'") | ("`frequency'" != "")) {
		local novarlist novarlist
	}
	marksample touse , `novarlist'
	
	kappaetc_get_acm_opt `acm' if `touse'
	
	if ("`weight'" != "") {
		tempvar weightvar
		quietly generate double `weightvar' `exp'
	}
	
	mata : kappaetc_cac_ado()
	
	kappaetc_display , `options'
	
	if ("`store'" != "") {
		nobreak {
			capture _return drop `store'
			_return hold `store'
			_return restore `store' , hold
		}
	}
end

program kappaetc_get_store_opt
	version 11.2
	
	syntax [ anything(name = store) ] , BY(integer) BYINDEX(integer)
	
	if (mi("`store'")) {
		exit 0
	}
	
	gettoken stub star : store , parse(" *") quotes
	capture noisily confirm name `stub'
	if (_rc) {
		display as err "option store() invalid"
		exit 198
	}
	if (`by') {
		if (`"`star'"' != "*") {
			display as err "{it:stub{bf:*}} incorrectly specified"
			exit 198
		}
		local store `stub'`byindex'
	}
	else if (`"`star'"' != "") {
		display as err `"`store' invalid name"'
		exit 198
	}
	
	c_local store : copy local store
end

program kappaetc_get_wgt_opt
	version 11.2
	
	/*
		map new syntax 
			
			wgt(circular [{pi|180|#}])
			wgt(power #)
			
		to old syntax
		
			wgt(circular [ , sine({pi|180}) u(#)])
			wgt(power(#))
	*/
	
	syntax [ anything(everything) ] [ , KAPwgt MATrix * ]
	local suboptions : copy local options
	
	gettoken wgt1 anything 	: anything , qed(syntaxerr1) bind
	gettoken wgt2 void 		: anything , qed(syntaxerr2)
	
	if ((`syntaxerr1') | (`syntaxerr2') | (`"`void'"' != "")) {
		display as err "option wgt() invalid"
		if (`"`void'"' != "") {
			gettoken bad : void
			display as err `"`bad' not allowed"'
		}
		exit 198
	}
	
	if ("`kapwgt'`matrix'" != "") {
		if (("`kapwgt'" != "") & ("`matrix'" != "")) {
			local errmsg _newline "only one of kapwgt or matrix is allowed"
		}
		else if (`"`wgt2'"' != "") {
			local errmsg _newline `"`wgt2' not allowed"'
		}
		if (mi(`"`wgt1'"') | ("`errmsg'" != "")) {
			display as err "option wgt() invalid" `errmsg'
			exit 198
		}
		local userwgt : copy local wgt1
	}
	else {
		if (mi(`"`wgt1'"')) {
			local wgt1 identity // default
		}
		
		local 0 , `wgt1'
		syntax 							///
		[ , 							///
			Identity 					///
			Ordinal 					///
			Linear 						///
			Quadratic 					///
			RADical 					///
			Ratio 						///
			Circular 					///
			Bipolar 					///
			Power42 					///
			Power(passthru) /// old syntax; no longer documented
			W 		/// linear , noabsolute
			W2 	 /// quadratic , noabsolute
			* 				/// user customized weights 
		]
		local userwgt : copy local options
		
		if (`"`wgt2'`power42'"' != "") {
			if (mi("`circular'`power42'")) {
				display as err "option wgt() invalid"
				display as err `"`wgt2' not allowed"'
				exit 198
			}
			local rc 0
			if ("`circular'" != "") {
				if (inlist(`"`wgt2'"', "pi", "180")) {
					local suboptions `suboptions' sine(`wgt2')
				}
				else {
					local suboptions `suboptions' u(`wgt2')
					capture assert (`wgt2' >= 0) & (`wgt2' <= 1)
					local rc = _rc
				}
			}
			else {
				capture assert (`wgt2' >= 0) & (`wgt2' < .)
				local rc = _rc
				local power = cond(`rc', "power", "power(`wgt2')")
			}
			if (`rc') {
				display as err "option wgt() invalid"
				display as err `"invalid `circular'`power' `wgt2'"'
				exit 121
			}
		}
		
		if (`"`power'"' != "") {
			local 0 , `power'
			capture syntax , POWER(numlist max = 1 >=0)
			if (_rc) {
				display as err "option wgt() invalid"
				exit 198
			}
			local wgtpower : copy local power
			local power power
		}
		
		local wgt 		///
			`identity' 	///
			`ordinal' 	///
			`linear' 	///
			`quadratic' ///
			`radical' 	///
			`ratio' 	///
			`circular' 	///
			`bipolar' 	///
			`power' 	///
			`w' 		///
			`w2' 		///
			`userwgt'
		
		if (inlist(`"`wgt'"', "w", "w2")) {
			if (`"`wgt'"' == "w") {
				local wgt linear
			}
			else {
				local wgt quadratic
			}
			local suboptions `suboptions' noabsolute
		}
		
		if ("`wgt'" == "ordinal") {
			local WGTOPTS KRIPPENdorff
		}
		else if (inlist("`wgt'", 	///
			"linear", 				///
			"quadratic", 			///
			"radical", 				///
			"ratio", 				///
			"circular", 			///
			"power")) {
			local WGTOPTS noAbsolute
		}
		
		if ("`wgt'" == "circular") {
			local WGTOPTS `WGTOPTS' ///
				SINE(string) 		///
				U(numlist max = 1 >= 0 <= 1)
		}
	}
	
	if ("`userwgt'" != "") {
		local WGTOPTS 										///
			Indices(numlist ascending integer min = 2 > 0) 	///
			FORCEwgt
	}
	
	if (`"`suboptions'"' != "") {
		local 0 , `suboptions'
		capture noisily syntax 	[ , `WGTOPTS' ]
		local rc = _rc
		
		if (!`rc') {
			local rc 198
			if (`"`sine'"' != "") {
				if (!inlist(`"`sine'"', "pi", "180")) {
					display as err `"`invalid `sine''"'
				}
				else if ("`u'" != "") {
					display as err "only one of sine() or u() allowed"
				}
				else {
					local rc 0
				}
			}
			else if (("`u'" != "") & mi("`absolute'")) {
				display as err "suboption noabsolute required"
			}
			else {
				local rc 0
			}
		}
		
		if (`rc') {
			display as err "invalid suboption in option wgt()"
			exit 198
		}
		
		if (("`indices'" != "") & mi("`forcewgt'")) {
			kappaetc_get_wgt_opt_indices
			exit 198
		}
	}
	
	if ("`userwgt'" != "") {
		kappaetc_get_wgt_opt_user `userwgt' , `kapwgt' `matrix'
	}
	
	c_local wgt 			: copy local wgt
	c_local wgttype 		: copy local wgttype
	c_local wgtkrippendorff : copy local krippendorff
	c_local wgtabsolute 	: copy local absolute
	c_local wgtsine 		: copy local sine
	c_local wgtcircular 	: copy local u
	c_local wgtpower 		: copy local wgtpower
	c_local wgtindices 		: copy local indices
end

program kappaetc_get_wgt_opt_indices
	version 11.2
	display as err "suboption indices() is no longer allowed"
	display as err "invalid suboption in option wgt()"
	display as err _newline "{p 4 4 2}"
	display as err  														///
	"You probably specified indices() because not all predetermined rating" ///
	" categories were observed in the data. Note that the weighting matrix" ///
	" that is based on the observed ratings yields incorrect coefficients " ///
	" when the expected proportion of agreement is based on the number of " ///
	"rating categories. To get correct results, specify all predetermined " ///
	"rating categories in option {help kappaetc##opt_cat:{bf:categories()}}."
	display as err "{p_end}"
	display as err _newline "{p 4 4 2}"
	display as err 															///
	"If you had another reason for specifying suboption indices() and you " ///
	"really want a submatrix of `userwgt', you may continue by specifying " ///
	"{bf:wgt(`userwgt' , `kapwgt'`matrix' indices(`indices') force)}"
	display as err "{p_end}"
end

program kappaetc_get_wgt_opt_user
	version 11.2
	
	syntax anything(name = wgt everything) [ , KAPWGT MATRIX ]
	
	if (mi("`matrix'")) {
		capture local w : copy global `wgt'
		gettoken KAPWGT w : w
		if ("`KAPWGT'" == "kapwgt") {
			gettoken dim w : w
			if (`: word count `w'' != `dim'*(`dim'+1)/2) {
				display as err "`wgt' not `dim' x `dim'"
				exit 498
			}
			local wgttype kapwgt
		}
		else {
			if ("`kapwgt'" != "") {
				display as err "kapwgt `wgt' not found"
				exit 111
			}
			local matrix matrix
		}
	}
	
	if ("`matrix'" != "") {
		confirm matrix `wgt'
		local wgttype matrix
	}
	
	c_local wgt 	: copy local wgt
	c_local wgttype : copy local wgttype
end

	/* ---------------------------------------
		parse se(<se_type> [ , <se_options)>])
		----------------------------------- */
	
program kappaetc_get_se_opt
	version 11.2
	
	capture syntax name(name = cmd2) 	///
	[ , 								///
		SE(string asis) 				///
		NOSE 							///
						/// used internally
		WTYPE(string)  					///
		BYINDEX(integer 0) 				///
		FREQUENCY 						///
		KRIPPENDORFF 					///
	]
	if ((_rc) | (!inlist("`cmd2'", "cac", "dice")) | (!(`byindex'))) {
		_kappaetc_internal_error _get_se_opt
		// NotReached
	}
	
	if (mi("`wtype'")) {
		local wtype noweight
	}
	
	local 0 : copy local se
	capture syntax [ anything(name = sespec) ] [ , * ]
	if (_rc) {
		display as err "option se() invalid"
		exit 198
	}
	local se_options : copy local options
	
	gettoken setype sespec : sespec , qed(syntaxerr)
	if (mi("`setype'") & ("`nose'" != "")) {
		local setype nose
	}
	else {
		kappaetc_get_se_opt_setype `cmd2' `wtype' , `setype'
		if (("`nose'" != "") & ("`setype'" != "nose")) {
			display as err "only one of se() or nose allowed"
			exit 198
		}
		// !! jackknife, bootstrap, and nose not currently supported for cac //
			if (("`cmd2'" == "cac") ///
				& inlist("`setype'", "nose", "bootstrap", "jackknife")) {
					display as err "`setype' standard " ///
					"errors are currently not supported"
					if ("`setype'" == "jackknife") {
						display as err _newline _col(3) 			///
						"specify {bf:se(conditional subjects)} to" 	///
						" estimate standard errors conditional on" 	///
						" the sample of subjects; see option" 		///
						" {help kappaetc##opt_se:{bf:se()}}" _newline
					}
					exit 498
			}
		// // // // // // // // // // // // // // // // // // // // // // // //
	}
	
	if ( ("`krippendorff'" != "") ///
	& inlist("`setype'", "conditional", "unconditional") ) {
		if (`"`se'"' != "") {
			display as err "`setype' standard errors are " ///
			"not appropriate for Krippendorff's ordinal weights"
			exit 198
		}
		local setype nose
	}
	
	if ("`setype'" == "conditional") {
		local 0 , `sespec'
		capture syntax [ , Raters Subjects * ]
		if (_rc) {
			display as err "option se() invalid"
			exit 198
		}
		local sespec : copy local options // error below
		
		local seconditional `raters' `subjects'
		if (mi(`"`seconditional'"')) {
			local seconditional raters
		}
		else if ("`seconditional'" == "raters subjects") {
			local setype 		unconditional
			local seconditional // void
		}
	}
	
	if ("`frequency'" != "") {
		if ( ("`setype'" == "unconditional") ///
		| ("`seconditional'" == "subjects") ) {
			display as err "standard errors conditonal on the " ///
			"sample of subjects cannot be computed from rating" ///
			" frequencies"
			exit 498
		}
	}
	
	if (`"`sespec'"' != "") {
		gettoken bad : sespec
		display as err "option se() invalid"
		display as err `"`bad' not allowed"'
		exit 198
	}
	
	kappaetc_get_se_opt_se_options `setype' `wtype' `byindex' , `se_options'
		
	c_local setype 			: copy local setype
	c_local seconditional 	: copy local seconditional
	c_local sedots 			: copy local dots
	c_local sereps 			: copy local reps
	c_local seseed 			: copy local seed
end

program kappaetc_get_se_opt_setype
	version 11.2
	
	gettoken cmd2  0 : 0
	gettoken wtype 0 : 0
	
	if ("`cmd2'" == "cac") {
		local TYPE 		///
			CONDitional ///
			UNCONDitional
	}
	
	capture syntax 						///
	[ , 								///
		`TYPE' 							///
		NOSE 							///
		NONE 		/// is synonym for nose 
		BOOTstrap 						///
		JACKknife 						///
		JKNIFE /// is synonym for jackknife
		* 						/// unknown
	]
	if ((_rc) | (`"`options'"' != "")) {
		display as err "option se() invalid"
		if (`"`options'"' != "") {
			display as err `"`options' not allowed"'
		}
		exit 198
	}
	
	if ("`none'" != "") {
		local nose nose
	}
	if ("`jknife'" != "") {
		local jackknife jackknife
	}
	
	local setype 		///
		`conditional' 	///
		`unconditional' ///
		`nose' 			///
		`bootstrap' 	///
		`jackknife'
	
	if (mi("`setype'")) {
		if ("`cmd2'" == "cac") {
			local setype conditional
		}
		else if (mi("`wtype'")) {
			local setype bootstrap
		}
		else {
			local setype jackknife
		}
	}
	
	c_local setype : copy local setype
end

program kappaetc_get_se_opt_se_options
	version 11.2
	
	gettoken setype  0 : 0
	gettoken wtype   0 : 0
	gettoken byindex 0 : 0
	
	if (inlist("`setype'" , "bootstrap", "jackknife")) {
		local SE_OPTS 						///
			NODOTS 							///
			DOTS(numlist integer max = 1 >= 0)
		
		if ("`setype'" == "bootstrap") {
			local SE_OPTS `SE_OPTS' 		///
				Reps(integer 50) 			///
				SEED(numlist max = 1)
		}
	}
	
	capture syntax [ , `SE_OPTS' * ]
	if ((_rc) | (`"`options'"' != "")) {
		display as err "option se() invalid"
		if (`"`options'"' != "") {
			gettoken bad : options
			display as err `"`bad' not allowed"'
		}
		exit 198
	}
	
	if (!inlist("`setype'", "bootstrap", "jackknife")) {
		exit 0
	}
	
	if ("`nodots'" != "") {
		if ("`dots'" != "") {
			display as err "only one of nodots or dots() allowed"
			exit 198
		}
		local dots 0
	}
	else if (mi("`dots'")) {
		local dots 1
	}
	
	if ("`setype'" == "bootstrap") {
		if (`reps' < 2) {
			display as err "reps() must be an integer greater than 1"
			exit 198
		}
		if (`byindex' > 1) {
			local seed // void; set seed only once
		}
		else if ("`wtype'" != "noweight") { // first call
			if (inlist("`wtype'", "fweight", "aweight")) {
				local fweight frequency
				local aweight analytic
				display as err "bootstrap standard " ///
				"errors are not allowed with ``wtype'' weights"
				exit 198
			}
			// else; iweight
			capture mata : mata which mm_upswr()
			if (_rc) {
				display as err 									///
				"option {bf:se(bootstrap)} with weighted data " ///
				"requires {stata findit moremata.mlib:{bf:moremata}}"
				exit _rc
			}
		}
	}
	
	c_local dots 	: copy local dots
	c_local reps 	: copy local reps
	c_local seed 	: copy local seed
end

	/* ----------------------------
		parse categories(<numlist>)
		------------------------ */
	
program kappaetc_get_cat_opt
	version 11.2
	
	syntax varlist 				///
	[ , 						///
		CATEGORIES(passthru) 	///
		FREQUENCY 				///
	]
	
	local nv : word count `varlist'
	
	local 0 , `categories'
	capture syntax [ , CATEGORIES(numlist missingokay) ]
	if (_rc) {
		if (mi("`frequency'")) {
			syntax , CATEGORIES(string asis)
			gettoken float : categories , parse("(") quotes
			if (`"`float'"' == "float") {
				gettoken float categories : categories , parse("(")
				gettoken categories void : categories , match(opar)
				if (mi(`"`categories'"') | (strtrim(`"`void'"') != "")) {
					local categories INVALID
				}
				local 0 , categories(`categories')
			}
		}
		// else { NotReached; error below }
		syntax , CATEGORIES(numlist missingokay)
	}
	
	if ("`categories'" != "") {
		local dup : list dups categories
		if ("`dup'" != "") {
			display as err "categories() invalid " ///
			"-- invalid numlist has repeated values"
			exit 121
		}
		
		if ("`frequency'" != "") {
			local nc : word count `categories'
			if (`nc' != `nv') {
				local rc = 122 + (`nc' > `nv')
				display as err "categories() invalid -- " _continue
				error `rc'
			}
		}
	}
	
	c_local categories 	: copy local categories
	c_local catfloat 	: copy local float
end

	/* --------------------
		parse df(<matname>)
		---------------- */
	
program kappaetc_get_df_opt
	version 11.2
	
	syntax [ name(name = dfmat) ] [ , LARGESAMPLE ]
	
	if (mi("`dfmat'")) {
		exit 0
	}
	else if ("`largesample'" != "") {
		display as err "option df() may not be combined with largesample"
		exit 198
	}
	
	capture noisily confirm matrix `dfmat'
	if (_rc) {
		display as err "option df() invalid"
		exit 198
	}
	
	local rows = rowsof(`dfmat')
	local cols = colsof(`dfmat')
	
	if ((`rows' != 1) | (`cols' != 6)) {
		if ((`rows' != 6) | (`cols' != 1)) {
			display as err "option df() " ///
			"invalid -- 1 x 6 or 6 x 1 vector required"
			display as err "`dfmat' is `rows' x `cols'"
			err 498
		}
	}
	
	local bad = 504 * matmissing(`dfmat')
	if (!`bad') {
		mata : st_local("bad", strofreal(any(st_matrix("`dfmat'") :< 1)))
		local bad = `bad' * 498
	}
	
	if (`bad') {
		display as err "option df() " ///
		"invalid -- `dfmat' has invalid values"
		exit `bad'
	}
	
	c_local dfmat `dfmat'
end

	/* ---------------------
		parse acm(<varname>)
		----------------- */
	
program kappaetc_get_acm_opt
	version 11.2
	
	syntax [ varlist(default = none) ] if
	
	if (mi("`varlist'")) {
		exit 0
	}
	
	if (c(stata_version) > 11.2) {
		local fast fast
	}
	capture assert (!mi(`varlist')) `if' , `fast'
	if (_rc) {
		display as err "option acm() invalid" ///
		" -- absolute category cannot be missing"
		exit 416
	}
end

/* ---------------------------------------------------------------------------
	Specific agreement (dice)
--------------------------------------------------------------------------- */

program kappaetc_cmd_dice , by(recall)
	version 11.2
	
	syntax varlist(min = 2 numeric) 			///
	[ if ] [ in ] [ fweight iweight ] 			///
	[ , 										///
		DICE 		/// used internally by kappaetc
		SPECIFIC 	/// documented in place of dice
		SE(passthru) 							///
		NOSE 									///
		Level(cilevel) 	/// used here for bootstrap
		LISTwise 								///
		CASEwise /// retained synonym for listwise; not documented
		FREquency 								///
		CATegories(passthru) 					///
		TOLERANCE(real 1e-14) 					/// not documented
		RETURNMORE 			/// additional results; not documented
		* 						/// display options
	]
	
	local options `options' level(`level')
	
	local varlist : list uniq varlist
	if (`: word count `varlist'' < 2) {
		error 102
	}
	
	kappaetc_get_diopts dice , `options'
	
	kappaetc_get_se_opt dice , `se' `nose' ///
		wtype("`weight'") byindex(`= _byindex()')
	
	kappaetc_get_cat_opt `varlist' , `categories' `frequency'
	
	if ("`casewise'" != "") {
		local listwise listwise
	}
	
	if (mi("`listwise'") | ("`frequency'" != "")) {
		local novarlist novarlist
	}
	marksample touse , `novarlist'
	
	tempvar weightvar
	if (mi("`weight'")) {
		local exp "= 1"
	}
	quietly generate double `weightvar' `exp'
	
	mata : kappaetc_dice_ado()
	
	kappaetc_display , `options'
end

/* ---------------------------------------------------------------------------
	paired t-tests (ttest)
--------------------------------------------------------------------------- */

program kappaetc_cmd_ttest
	version 11.2
	
	syntax namelist(min = 2 max = 2) 	///
	[ , 								///
		TTEST 					/// ignored
		FORCEttest 						/// not documented
		TOLERANCE(real 1e-14) 			/// not documented
		RETURNMORE 						/// not documented
		* 				/// display options
	]
	
	gettoken name1 namelist : namelist
	gettoken name2 namelist : namelist
	
	kappaetc_get_diopts ttest , `options'
	
	forvalues j = 1/2 {
		_kappaetc_rpreserve : ///
		kappaetc_ttest_assert_results `name`j'' , `forcettest'
	}
	
	tempname rresults
	_return hold `rresults'
	capture noisily mata : kappaetc_ttest_ado()
	if (_rc) {
		_return restore `rresults'
		exit _rc
	}
	else {
		_return drop `rresults'
	}
	
	kappaetc_display , `options'
end

program kappaetc_ttest_assert_results
	version 11.2
	
	syntax name [ , FORCETTEST ]
	
	quietly kappaetc_cmd_replay `namelist' , restore
	
	if ("`r(dfmat)'" != "") {
		local errmsg "user defined degrees of freedom"
	}
	else if ("`r(wtype)'" == "aweight") {
		local errmsg "aweights"
	}
	else if ( ///
		((!inlist("`r(setype)'", "nose", "conditional")) 	| 	///
		("`r(seconditional)'" == "subjects")) 				& 	///
		mi("`forcettest'") 										///
	) {
		if ("`r(seconditional)'" != "subjects") {
			local stderr " `r(setype)'"
		}
		else {
			local errmsg " conditional on the sample of subjects"
		}
		local errmsg "`stderr' standard errors`errmsg'"
	}
	else {
		exit 0 // results OK
	}
	
	display as err "ttest not allowed with`errmsg'"
	exit 498
end

/* ---------------------------------------------------------------------------
	intraclass correlation coefficients (icc)
--------------------------------------------------------------------------- */

program kappaetc_cmd_icc , byable(recall)
	version 11.2
	
	syntax varlist(numeric min = 2) 			///
	[ if ] [ in ] 								///
	, ICC(string asis) 			/// required option
	[ 											///
		Id(varname numeric) 					///
		LISTwise 								///
		CASEwise 	/// retain synonym for listwise
		BALanced 								///
		RETURNMORE 			/// additional results; not documented
		* 						display options ///
	]
	
	local varlist : list uniq varlist
	if (`: word count `varlist'' < 2) {
		error 102
	}
	
	kappaetc_get_diopts icc , `options'
	
	kappaetc_icc_get_model_opt `icc'
	
	if ("`casewise'" != "") {
		local listwise listwise
	}
	
	if (mi("`listwise'")) {
		local novarlist novarlist
	}
	marksample touse , `novarlist'
	
	kappaetc_icc_get_i_opt `varlist' if `touse' , id(`id') `balanced'
	
	mata : kappaetc_icc_ado()
	
	kappaetc_display , `options'
end

program kappaetc_icc_get_model_opt
	version 11.2
	
	capture syntax anything(id = "model") [ , * ]
	local rc = _rc
	if (!`rc') {
		gettoken model void : anything , qed(syntaxerr)
		local rc = ((`syntaxerr') | (`"`void'"' != ""))
	}
	if (`rc') {
		display as err "option icc() invalid"
		exit 198
	}
	
	local model_opts : copy local options
	
	if (inlist(strlower("`model'"), "1a", "1b")) {
		if (strlower("`model'") == "1b") {
			local model_opts `model_opts' b
		}
		local model 1
	}
	
	if (inlist("`model'", "1", "2", "3")) {
		local model : word `model' of oneway random mixed 
	}
	
	local 0 , `model'
	capture syntax 	///
	[ , 			///
		ONEway 		///
		RANDom 		///
		MIXED 		///
		* 	/// invalid
	]
	if ((_rc) | (`"`options'"' != "")) {
		display as err "option icc() invalid"
		if (`"`options'"' != "") {
			display as err `"unknown model `options'"'
		}
		exit 198
	}
	
	local model `oneway' `random' `mixed'
	
	if ("`model'" == "oneway") {
		local MODELOPTS B
	}
	else if (inlist("`model'", "random", "mixed")) {
		local MODELOPTS BLEND
	}
	
	local 0 , `model_opts'
	capture noisily syntax [ , `MODELOPTS' ]
	if (_rc) {
		display as err "invalid suboption in option icc()"
		exit 198
	}
	
	c_local model 	: copy local model
	c_local oneB 	: copy local b
	c_local blend 	: copy local blend
end

program kappaetc_icc_get_i_opt
	version 11.2
	
	syntax varlist [ if ] [ , ID(varname) BALANCED ]
	
	if (mi("`id'")) {
		if (mi("`balanced'")) {
			exit 0
		}
		display as err "option balanced not allowed"
		exit 198
	}
	
	local rc : list id in varlist
	local rc = (`rc'*198)
	if (!`rc') {
		if (c(stata_version) > 11.2) {
			local fast fast
		}
		capture assert (!mi(`id')) `if' , `fast'
		if (_rc) {
			local rc 416
		}
	}
	if (`rc') {
		display as err "option id() invalid"
	}
	
	exit `rc'
end

/* ---------------------------------------------------------------------------
	limits of agreement (loa)
	bland-altman plot
--------------------------------------------------------------------------- */

program kappaetc_cmd_loa , byable(onecall)
	version 11.2
	
	if (_by()) {
		local BY by `_byvars' `_byrc0' :
	}
	
	tempname rresults
	
	nobreak {
		_return hold `rresults'
		capture noisily break `BY' kappaetc_loa `0'
		local rc = _rc
		if ((`rc') | mi("`return'")) {
			_return restore `rresults'
		}
		capture _return drop `rresults'
	}
	
	exit `rc'
end

program kappaetc_loa , rclass byable(recall)
	version 11.2
	
	syntax varlist(min = 2 max = 2 numeric) ///
	[ if ] [ in ] [ fweight iweight ] 		///
	[ , 									///
		RETURN 								///
		RETURNONLY 							///
		KEEP 								///
		noVARLabel 							///
		LINEopts(string asis)				///
		SCATTERopts(string asis) 			///
		TWOWAYopts(string asis) 			///
		SHOWGRAPHCMD 						/// not documented
		* /// display options; including loa(#)
	]
	
	gettoken varn1 varlist : varlist
	gettoken varn2 varlist : varlist
	if ("`varn1'" == "`varn2'") {
		error 102
	}
	
	if ("`keep'" != "") {
		if (_by()) {
			display as err "option keep may not be combined with by"
			exit 190
		}
		confirm new variable 	///
			_pairmean 			///
			_pairdiff 			///
			_meandiff 			///
			_lowerloa 			///
			_upperloa
	}
	
	kappaetc_get_diopts loa , `options' setclocals fmtnoisily
	
	marksample touse
	quietly count if `touse'
	if (r(N) < 2) {
		error 2000 + r(N)
	}
	
	if ("`weight'" != "") {
		local weight [ `weight' `exp' ]
	}
	
	tempvar 	mean diff dbar ll ul
	tempname 	sc_dbar sc_sd sc_zs sc_ll sc_ul
	
	quietly {
		generate double `mean' 	= (`varn1' + `varn2')/2 if `touse'
		generate double `diff' 	= (`varn1' - `varn2') if `touse'
		summarize `diff' if `touse' `weight'
		scalar `sc_dbar' 		= r(mean)
		scalar `sc_sd' 			= r(sd)
		scalar `sc_zs' 			= abs(invnormal((1-`loa'/100)/2)*`sc_sd')
		scalar `sc_ll' 			= `sc_dbar' - `sc_zs'
		scalar `sc_ul' 			= `sc_dbar' + `sc_zs'
		foreach sc in dbar ll ul {
			local `sc'l : display `cformat' `sc_`sc''
			generate double ``sc'' = `sc_`sc'' if `touse'
		}
		
		return local cmd2 		"loa"
		return local cmd 		"kappaetc"
		
		return scalar loa_level = `loa'
		return scalar loa_ul 	= `sc_ul'
		return scalar loa_ll 	= `sc_ll'
		return scalar sd_diff 	= `sc_sd'
		return scalar mean_diff = `sc_dbar'
		return scalar N 		= r(N)
	}
	
	if (mi("`returnonly'")) {
		if (mi("`varlabel'")) {
			local varl1 : variable label `varn1'
			local varl2 : variable label `varn2'
		}
		forvalues j = 1/2 {
			if (mi(`"`macval(varl`j')'"')) {
				local varl`j' `varn`j''
			}
		}
		
		local lineopts 		sort lstyle(p1 p2 p2) `lineopts'
		local scatteropts 	mstyle(p1) `scatteropts'
		local twowayopts 												///
			xtitle(`"Average of `macval(varl1)' and `macval(varl2)'"') 	///
			ytitle(`"Difference (`macval(varl1)'-`macval(varl2)')"') 	///
			xlabel(minmax) 												///
			ylabel(`dbarl' `lll' `ull' , alternate) 					///
			yscale(range(`= `sc_ll'-`sc_sd'' `= `sc_ul'+`sc_sd'')) 		///
			legend(order(	1 "Average agreement"						///
							2 "`loa'% lower and upper limit"))			///
			`twowayopts'
		
		if ("`showgraphcmd'" != "") {
			display as inp _n ". graph twoway line " 					///
			`"_meandiff _lowerloa _upperloa _pairmean , `lineopts' "' 	/// 							///
			`"|| scatter _pairdiff _pairmean , `scatteropts' "' 		/// 						///
			`"|| , `twowayopts'"'
		}
		
		graph twoway 										///
			line `dbar' `ll' `ul' `mean' , `lineopts' 	|| 	///
			scatter `diff' `mean' , `scatteropts' 		|| 	///
			if `touse' , `twowayopts'
	}
	else {
		local return return
	}
	
	if ("`keep'" != "") {
		nobreak {
			rename `mean' 	_pairmean
			rename `diff' 	_pairdiff
			rename `dbar' 	_meandiff
			rename `ll' 	_lowerloa
			rename `ul' 	_upperloa			
			label variable 	_pairmean ///
				`"Average of `macval(varl1)' and `macval(varl2)'"'
			label variable 	_pairdiff ///
				`"Difference (`macval(varl1)'-`macval(varl2)')"'
			label variable 	_meandiff ///
				"Mean difference"
			label variable 	_lowerloa ///
				"`loa'% lower limit of agreement"
			label variable 	_upperloa ///
				"`loa'% upper limit of agreement"
		}
	}
	
	c_local return : copy local return
end

/* ---------------------------------------------------------------------------
	replay or restore results
--------------------------------------------------------------------------- */

program kappaetc_cmd_replay
	version 11.2
	
	syntax namelist 	///
	[ , 				///
		REPLAY 	/// ignored
		RESTORE 		///
		* 	/// any options
	]
	
	if ("`restore'" != "") {
		if (`: word count `namelist'' > 1) {
			display as err "too many names specified"
			exit 103
		}
	}
	
	foreach name of local namelist {
		_kappaetc_rpreserve : ///
		kappaetc_replay_rresults `name' , `restore' `options'
	}
	
	if (mi("`restore'")) {
		exit 0
	}
	
	_return restore `namelist' , hold
	display as txt "(results {stata kappaetc:`namelist'} are active now)"
end

program kappaetc_replay_rresults
	version 11.2
	
	syntax name [ , RESTORE * ]
	
	capture _return restore `namelist' , hold
	if ((_rc) | ("`r(cmd)'" != "kappaetc")) {
		display as err "results `namelist' not found"
		exit 111
	}
	
	if (mi("`restore'")) {
		display as txt "{hline 78}"
		display as txt "Results " as res "`namelist'" 
		display as txt "{hline 78}"
		kappaetc_display , `options'
	}
end

/* ---------------------------------------------------------------------------
		strip internal options
--------------------------------------------------------------------------- */

program _kappaetc_strip_internal_opts
	version 11.2
	syntax [ , SETCLOCALS FMTNOISILY * ]
	local 0 , options `setclocals' `fmtnoisily'
	syntax , OPTIONS
end

/* ---------------------------------------------------------------------------
		preserve contents in r()
--------------------------------------------------------------------------- */

program _kappaetc_rpreserve
	version 11.2
	
	gettoken 0 cmd : 0 , parse(":")
	if (`"`0'"' != ":") {
		syntax [ , REPLACE ]
		gettoken colon cmd : cmd , parse(":")
		if (`"`colon'"' != ":") {
			error 198
		}
	}
	
	tempname rresults
	nobreak {
		_return hold `rresults'
		_return restore `rresults' , hold
		capture noisily break `cmd'
		local rc = _rc
		if ((`rc') | mi("`replace'")) {
			_return restore `rresults'
		}
		else {
			_return drop `rresults'
		}
	}
	
	exit `rc'
end

/* ---------------------------------------------------------------------------
		internal error message
--------------------------------------------------------------------------- */

program _kappaetc_internal_error
	version 11.2
	mata : _kappaetc_internal_error(st_local("0"), 0)
end

/* ---------------------------------------------------------------------------
	Mata
--------------------------------------------------------------------------- */

version 11.2

// ------------------------------------- variable types
local S scalar
local R rowvector
local C colvector
local M matrix

local SS string `S'
local SR string `R'
local SC string `C'
local SM string `M'

local RS real `S'
local RR real `R'
local RC real `C'
local RM real `M'

local Boolean `RS'
local True 		1
local False 	0

/* ---------------------------------------------------------------------------
	chance-corrected agreement coefficients (cac)
--------------------------------------------------------------------------- */

local stInfoAdo struct_kappaetc_infoado_def
local stInfoAdoS struct `stInfoAdo' `S'

local stResults struct_kappaetc_results_def
local stResultsS struct `stResults' `S'

local clAgreeStat class_kappaetc_agreestat_def
local clAgreeStatS class `clAgreeStat' `S'

local clAgreeCoef class_kappaetc_agreecoef_def
local clAgreeCoefR class `clAgreeCoef' `R'
local clAgreeCoefS class `clAgreeCoef' `S'

mata :

struct `stInfoAdo' {
	`SR' varlist
	`SS' touse
	`SS' weight
	`SS' exp
	`SS' weightvar
	`SS' wgt
	`SS' wgttype
	`RS' wgtkrippendorff
	`RS' wgtabsolute
	`RS' wgtsine
	`RS' wgtcircular
	`RS' wgtpower
	`RR' wgtindices
	`SS' setype
	`SS' seconditional
	`RS' listwise
	`RS' store
	`RS' frequency
	`RC' categories
	`RS' catfloat
	`SS' acm
	`SS' dfmat
	`RS' nsubjects
	`RS' nraters
	`RS' returnmore
}

struct `stResults' {
	`RR' b
	`RR' se
	`RR' df
	`RM' K_g
	`RR' se_jknife
	`RR' se_conditional
	`RM' b_istar
}

class `clAgreeStat' {
	static `stInfoAdoS' info
	`stResultsS' 		results
	`RM' 				raw
	`RM' 				w_i
	static `RR' 		acm
	static `RC' 		cat
	static `RS' 		q
	`RC' 				r_i
	`RS' 				r
	`RS' 				n
	`RS' 				f
	`RS' 				g_r
	`RM' 				r_ik
	`RM' 				n_gk
	`RM' 				e_ik
	`RC' 				n_g
	`RM' 				p_gk
	`RR' 				pi_k
	`RR' 				p_k
	`RC' 				more2
	`RS' 				nprime
	`RS' 				rbar_m2
	static `RM' 		w_kl
	`clAgreeCoefR' 		K
}

class `clAgreeCoef' extends `clAgreeStat' {
	`SS' name
	`RS' eps_n
	`RC' p_ai
	`RC' p_ei
	`RS' p_a
	`RS' p_e
	`RS' b()
	`RC' b_istar()
	`RS' bprime()
	`RS' V()
	`RS' estOK
}

`RS' `clAgreeCoef'::b()
{
	return(((1-eps_n)*(1/nprime)*quadcolsum(w_i:*p_ai)+eps_n-p_e)/(1-p_e))
}

`RC' `clAgreeCoef'::b_istar()
{
	`RC' b_i
	b_i = ((n/nprime)*(p_ai:-p_e)/(1-p_e)):*more2
	return(b_i:-2*(1-bprime())*((p_ei:-p_e)/(1-p_e)):*!(!more2*eps_n))
}

`RS' `clAgreeCoef'::bprime()
{
	return((p_a-p_e)/(1-p_e))
}

`RS' `clAgreeCoef'::V()
{
	return((1-f)/(n*(n-1))* ///
		quadcolsum(w_i:*(b_istar():-bprime()):^2:*!(!more2*eps_n), 1))
}

void kappaetc_cac_ado()
{
	`clAgreeStatS' A
	
	kappaetc_get_infoado(A)
	kappaetc_get_rawdata(A)
	
	kappaetc_get_allmats(A)
	kappaetc_get_weights(A)
	
	kappaetc_set_basicsK(A)
	
	kappaetc_get_propobs(A)
	kappaetc_get_propexp(A)
	
	kappaetc_get_results(A)
	kappaetc_set_results(A)
}

void kappaetc_get_infoado(`clAgreeStatS' A)
{
	A.info.varlist 			= tokens(st_local("varlist"))
	A.info.touse 			= st_local("touse")
	A.info.weight 			= st_local("weight")
	A.info.exp 				= st_local("exp")
	A.info.weightvar 		= st_local("weightvar")
	A.info.wgt 				= st_local("wgt")
	A.info.wgttype 			= st_local("wgttype")
	A.info.wgtkrippendorff 	= (st_local("wgtkrippendorff") != "")
	A.info.wgtabsolute 		= (st_local("wgtabsolute") != "noabsolute")
	A.info.wgtsine 			= (st_local("wgtsine") == "180") ? 180 : c("pi")
	A.info.wgtcircular 		= strtoreal(st_local("wgtcircular"))
	A.info.wgtpower 		= strtoreal(st_local("wgtpower"))
	A.info.wgtindices 		= strtoreal(tokens(st_local("wgtindices")))
	A.info.setype 			= st_local("setype")
	A.info.seconditional 	= st_local("seconditional")
	A.info.listwise 		= (st_local("listwise") != "")
	A.info.store 			= (st_local("store") != "")
	A.info.frequency 		= (st_local("frequency") != "")
	A.info.categories 		= strtoreal(tokens(st_local("categories")))'
	A.info.catfloat 		= (st_local("catfloat") != "")
	A.info.acm 				= st_local("acm")
	A.info.dfmat 			= st_local("dfmat")
	A.info.nsubjects 		= strtoreal(st_local("nsubjects"))
	A.info.nraters 			= strtoreal(st_local("nraters"))
	A.info.returnmore 		= (st_local("returnmore") != "")
}

void kappaetc_get_rawdata(`clAgreeStatS' A)
{
	A.raw = st_data(., A.info.varlist, A.info.touse)
	
	A.w_i = (A.info.weight != "") ? 
		st_data(., A.info.weightvar, A.info.touse) : J(rows(A.raw), 1, 1)
	
	if (A.info.acm != "") {
		A.acm = st_data(., A.info.acm, A.info.touse)
	}
	else {
		A.acm = J(rows(A.raw), 1, .z)
	}
	
	if (!A.info.frequency) {
		kappaetc_get_rawdata_raw(A)
	}
	else {
		kappaetc_get_rawdata_freq(A)
	}
	
	kappaetc_get_rawdata_sufficient(A)
	
	A.q 	= rows(A.cat)
	A.w_i 	= (A.w_i, A.w_i) // w_i[, 2] for Krippendorff's alpha
}

void kappaetc_get_rawdata_raw(`clAgreeStatS' A)
{
	A.w_i = select(A.w_i, (rowmissing(A.raw) :< cols(A.raw)))
	A.acm = select(A.acm, (rowmissing(A.raw) :< cols(A.raw)))
	A.raw = select(A.raw, (rowmissing(A.raw) :< cols(A.raw)))
	A.raw = select(A.raw, (colmissing(A.raw) :< rows(A.raw)))
	
	if (
		( (A.info.setype != "conditional")
		| (A.info.seconditional == "subjects") ) 
		& (cols(A.raw) < 3) 
	) {
		errprintf("insufficient number of raters to calculate")
		if (A.info.seconditional == "subjects") {
			errprintf(" standard errors conditional")
			errprintf("on the sample of subjects \n")
		}
		else {
			errprintf(" %s standard errors\n", A.info.setype)
		}
		exit(459)
	}
	
	A.cat = uniqrows(vec(A.raw))
	A.cat = select(A.cat, (rownonmissing(A.cat)))
	
	if (rows(A.info.categories) & (rows(A.cat) > 1)) {
		if (A.info.catfloat) {
			A.info.categories = floatround(A.info.categories)
		}
		for (i = 1; i <= rows(A.cat); ++i) {
			if (!anyof(A.info.categories, A.cat[i])) {
				errprintf("categories() invalid -- ")
				errprintf("value " + strofreal(A.cat[i]) + " not")
				errprintf(" specified but observed in the data\n")
				exit(198)
			}
		}
		A.cat = sort(A.info.categories, 1)
		A.cat = select(A.cat, (rownonmissing(A.cat)))
	}
}

void kappaetc_get_rawdata_freq(`clAgreeStatS' A)
{
	`RC' order
	
	if (any(A.raw :< 0) | hasmissing(A.raw) | any(A.raw :!= trunc(A.raw))) {
		errprintf("negative, missing or noninteger ")
		errprintf("rating frequencies encountered\n")
		exit(459)
	}
	
	A.cat = (1::cols(A.raw))
	if (rowsum(colsum(A.raw):>0) < 2) {
		A.cat = select(A.cat, colsum(A.raw)')
	}
	
	if (rows(A.info.categories) & (rows(A.cat) > 1)) {
		order = sort((A.info.categories, A.cat), 1)[, 2]	
		A.raw = A.raw[, order]
		A.cat = A.info.categories[order]
		A.raw = select(A.raw, (rownonmissing(A.cat)'))
	}
	
	A.r_i 		= rowsum(A.raw)
	A.r  		= colmax(A.r_i)
	A.w_i 		= select(A.w_i, (A.r_i :> 0))
	A.acm 		= select(A.acm, (A.r_i :> 0))
	A.raw 		= select(A.raw, (A.r_i :> 0))
	A.r_i 		= select(A.r_i, (A.r_i :> 0))
	if (A.info.listwise) {
		A.w_i 	= select(A.w_i, (A.r_i :== A.r))
		A.acm 	= select(A.w_i, (A.r_i :== A.r))
		A.raw 	= select(A.raw, (A.r_i :== A.r))
		A.r_i 	= select(A.r_i, (A.r_i :== A.r))
	}
}

void kappaetc_get_rawdata_sufficient(`clAgreeStatS' A)
{
	`RS' w, n, r
	
	if (A.info.weight == "aweight") {
		w = rows(A.w_i)*A.w_i/quadcolsum(A.w_i)
	}
	else {
		w = A.w_i
	}
	
	n = quadcolsum(w)
	r = A.info.frequency ? A.r : cols(A.raw)
	
	if ((r < 2) | (n < 1)) {
		exit(error(2001))
	}
	
	if (rows(A.cat) < 2) {
		errprintf("ratings do not vary\n")
		exit(459)
	}
}

void kappaetc_get_allmats(`clAgreeStatS' A)
{
	if (A.info.weight == "aweight") {
		// do not use rows(A.w_i); jackknife routine sets A.w_i = 0
		A.w_i[, 1] = ///
			colsum((A.w_i[, 1]:!=0))*A.w_i[, 1]/quadcolsum(A.w_i[, 1])
	}
	A.n = quadcolsum(A.w_i[, 1])
	
	if (!A.info.frequency) {
		A.r_ik 	= J(rows(A.raw), A.q, .)
		A.n_gk 	= J(cols(A.raw), A.q, .)
		for (k 	= 1; k <= A.q; ++k) {
			A.r_ik[, k] = rowsum((A.raw :== A.cat[k]))
			A.n_gk[, k] = (A.w_i[, 1]'*(A.raw :== A.cat[k]))'
		}
		A.n_g 	= quadrowsum(A.n_gk)
		A.p_gk 	= A.n_gk:/A.n_g
		A.r_i 	= rowsum(A.r_ik)
		A.r 	= cols(A.raw)
	}
	else {
		A.r_ik 	= A.raw
	}
	
	A.pi_k 		= (1/A.n)*quadcolsum(A.w_i[, 1]:*(A.r_ik:/A.r_i))
	
		// validity coefficients
	if (missing(A.acm)) {
		A.e_ik 	= J(rows(A.r_ik), rows(A.cat), 1)
	}
	else {
		A.e_ik 	= (J(rows(A.r_ik), 1, A.cat') :== A.acm)
	}
	A.p_k 		= (1/A.n):*colsum(A.w_i[, 1]:*A.e_ik)
	
		// for Krippendorff's alpha
	A.more2 = (A.r_i :> 1)
	A.w_i[, 2] = A.w_i[, 2]:*A.more2
	if (A.info.weight == "aweight") {
		A.w_i[, 2] = ///
			colsum((A.w_i[, 2]:!=0))*A.w_i[, 2]/quadcolsum(A.w_i[, 2])
	}
	A.nprime 	= quadcolsum(A.w_i[, 2])
	A.rbar_m2 	= (1/A.nprime)*quadcolsum(A.w_i[, 2]:*A.r_i)	
}

void kappaetc_get_weights(`clAgreeStatS' A)
{
	`RM' k, l
	`RS' min, max
	
	if (A.info.wgttype != "") {
		kappaetc_get_weights_user(A)
		return
	}
	
	if (A.info.wgt == "identity") {
		A.w_kl = !I(A.q)
	}
	else if (A.info.wgt == "ordinal") {
		if (!A.info.wgtkrippendorff) {
			// Gwet 2014, p. 91 (3.5.1) and (3.5.2)
			k = J(1, A.q, (1::A.q))
			l = J(A.q, 1, (1..A.q))
			A.w_kl = comb((abs(k-l):+1), 2):/comb(A.q, 2)
		}
		else {
			// Krippendorff 2013, p. 6
			A.w_kl = select(A.r_ik, A.more2):*select(A.w_i[, 2], A.more2)
			k = J(1, A.q, quadcolsum(A.w_kl)')
			l = J(A.q, 1, quadcolsum(A.w_kl))
			A.w_kl = lowertriangle(k)
			for (i = 1; i < A.q; ++i) {
				A.w_kl[, i] = quadrunningsum(A.w_kl[, i])
			}
			A.w_kl = makesymmetric((A.w_kl-(k+l)/2):^2)
			A.w_kl = A.w_kl/max(A.w_kl)
		}
	}
	else {
		if (A.info.wgtabsolute) {
			k = J(1, rows(A.cat), A.cat)
			l = J(rows(A.cat), 1, A.cat')
			min = A.cat[1]
			max = A.cat[rows(A.cat)]
		}
		else {
			k = J(1, A.q, (1::A.q))
			l = J(A.q, 1, (1..A.q))
			min = 1
			max = A.q
		}
		if (A.info.wgt == "linear") {
			// Gwet 2014, p. 92 (3.5.3)
			A.w_kl = abs(k-l)/abs(max-min)
		}
		else if (A.info.wgt == "quadratic") {
			// Gwet 2014, p. 79 (3.2.5)
			A.w_kl = ((k-l):^2)/((max-min)^2)
		}
		else if (A.info.wgt == "radical") {
			// Gwet 2014, p. 93 (3.5.4)
			A.w_kl = sqrt(abs(k-l))/sqrt(abs(max-min))
		}
		else if (A.info.wgt == "ratio") {
			// Gwet 2014, p. 93 (3.5.5)
			A.w_kl = (((k-l):/(k+l)):^2)/(((max-min)/(max+min)):^2)
		}
		else if (A.info.wgt == "circular") {
			if (A.info.wgtcircular == .) {
				// Gwet 2014, p. 94 (3.5.6) and (3.5.7)
				A.w_kl = sin(A.info.wgtsine*(k-l)/((max-min)+1)):^2
				A.w_kl = A.w_kl/max(A.w_kl)
			}
			else {
				// Warrens and Pratiwi 2016, p. 513 (7)
				A.w_kl = ((abs(k-l):==1):|(abs(k-l):==(max-min)))
				A.w_kl = 1:-A.w_kl:*A.info.wgtcircular
			}
		}
		else if (A.info.wgt == "bipolar") {
			// Gwet 2014, p. 94 (3.5.8)
			A.w_kl = ((k-l):^2):/((k+l:-2*min):*(2*max:-k:-l))
			A.w_kl = A.w_kl/max(A.w_kl)
		}
		else if (A.info.wgt == "power") {
			// Warrens 2014, p. 2 (3)
			A.w_kl = (abs(k-l):^A.info.wgtpower)/
				(abs(max-min):^A.info.wgtpower)
		}
		else {
			_kappaetc_internal_error("get_weights")
		}
	}
	_diag(A.w_kl, 0)
	A.w_kl = 1:-A.w_kl
	
	kappaetc_get_weights_ok(A)
}

void kappaetc_get_weights_user(`clAgreeStatS' A)
{
	`RR' w
	`RS' dim, l
	
	if (A.info.wgttype == "kapwgt") {
		w = strtoreal(tokens(st_global(A.info.wgt)))
		dim = w[2]
		w = w[3..cols(w)]
		A.w_kl = I(dim)
		l = 1
		for (k = 2; k <= dim; ++k) {
			l = (l+k-1)
			A.w_kl[k, ]= w[l..(l+k-1)], J(1, (dim-k), 0)
		}
		A.w_kl = makesymmetric(A.w_kl)
	}
	else if (A.info.wgttype == "matrix") {
		A.w_kl = st_matrix(A.info.wgt)
	}
	else {
		_kappaetc_internal_error("get_weights_user")
	}
	
	if (cols(A.info.wgtindices)) {
		dim = rows(A.w_kl)
		if (A.info.wgtindices[cols(A.info.wgtindices)] > dim) {
			errprintf("suboption indices() invalid;")
			errprintf(" weighting matrix %s is only ", A.info.wgt)
			errprintf("%s x %s\n", strofreal(dim), strofreal(dim))
			exit(498)
		}
		A.w_kl = A.w_kl[A.info.wgtindices', A.info.wgtindices]
	}
	
	kappaetc_get_weights_ok(A)
}

void kappaetc_get_weights_ok(`clAgreeStatS' A)
{
	`RS' err
	`SS' msg
	
	err = 0
	msg = ""
	if (missing(A.w_kl)) {
		err = 504
		msg = "matrix has missing values"
	}
	else if (!issymmetric(A.w_kl)) {
		err = 505
		msg = "matrix not symmetric"
	}
	else if (any(diagonal(A.w_kl):!=1)) {
		err = 498
		msg = "diagonal elements must be 1"
	}
	else if (any((A.w_kl :< 0):|(A.w_kl :> 1))) {
		err = 498
		msg = "elemnts must be between 0 and 1"
	}
	else if (rows(A.w_kl) != A.q) {
		err = 498
		msg = strofreal(A.q)
		msg = "not " + msg + " x " + msg
	}
	
	if (!err) {
		return
	}
	
	errprintf("invalid weighting matrix %s\n", A.info.wgt)
	errprintf("%s\n", msg)
	
	if (A.info.wgttype == "") {
		if (err == 504) {
			errprintf("\n{p 4 4 2}")
			errprintf("The definition of %s weights results in ", A.info.wgt)
			errprintf("missing values when applied to the observed ratings.")
			errprintf(" Perhaps %s weights are not appropriate ", A.info.wgt)
			errprintf("for the data at hand. Consider specifying different ")
			errprintf("weights. See {helpb kappaetc##opt_wgt:kappaetc} for ")
			errprintf("a list of alternative weights for partial agreement.")
			errprintf("{p_end}")
		}
		else {
			_kappaetc_internal_error("get_weights_ok")
		}
	}
	
	exit(err)
}

void kappaetc_set_basicsK(`clAgreeStatS' A)
{
	A.K = `clAgreeCoef'(6)
	
	A.K[1].name = "Percent Agreement"
	A.K[2].name = "Brennan and Prediger"
	A.K[3].name = "Cohen/Conger's Kappa"
	A.K[4].name = "Scott/Fleiss' " + ((A.r > 2) ? "Kappa" : "Pi")
	A.K[5].name = "Gwet's AC"
	A.K[6].name = "Krippendorff's Alpha"
	
	for (i = 1; i <= length(A.K); ++i) {
		A.K[i].w_i 		= (i < 6) ? A.w_i[, 1] : A.w_i[, 2]
		A.K[i].n 		= (i < 6) ? A.n : A.nprime
		A.K[i].nprime 	= (i < 6) ? quadcolsum(A.w_i[, 1]:*A.more2) : A.nprime
		A.K[i].more2 	= A.more2
		A.K[i].f		= missing(A.info.nsubjects) ? 0 : A.n/A.info.nsubjects
		A.K[i].g_r 		= missing(A.info.nraters) ? 0 : A.r/A.info.nraters
		A.K[i].eps_n 	= (i < 6) ? 0 : 1/(A.K[i].n*A.rbar_m2)
		A.K[i].estOK 	= 1
	}
	
	if (A.info.frequency) {
		A.K[3].estOK = 0
	}
	if (A.info.acm != "") {
		A.K[3].estOK = 0
		A.K[4].estOK = 0
		A.K[6].estOK = 0
	}
}

void kappaetc_get_propobs(`clAgreeStatS' A)
{
	// Percent agreement
		// Gwet 2014, p. 147 (5.3.22)
	A.K[1].p_ai = ///
	quadrowsum(A.e_ik:*A.r_ik:*((A.w_kl*A.r_ik')':-1):/(A.r_i:*(A.r_i:-1)))
		
	// Brennan and Prediger, Cohen/Conger, Fleiss, Gwet [, Krippendorff ]
		// Gwet 2014, p. 147 (5.3.22)
	for (i = 1; i <= length(A.K); ++i) {
		A.K[i].p_ai = A.K[i].estOK ? A.K[1].p_ai : J(rows(A.raw), 1, .)
		kappaetc_get_propobs_pa(A.K[i])
	}
	
	if (!A.K[6].estOK) {
		return
	}
	// else replace Krippendorff
	
	// Krippendorff's alpha
		// Gwet 2014, p. 149; p. 88 (3.4.8); also error page and email
	A.K[6].p_ai = ///
	(A.e_ik:*A.r_ik:*((A.w_kl*A.r_ik')':-1):/(A.rbar_m2:*(A.r_i:-1)))
	kappaetc_get_propobs_pa(A.K[6])
	A.K[6].p_ai = (quadrowsum(A.K[6].p_ai) ///
				:- A.K[6].p_a*(A.r_i:-A.rbar_m2)/A.rbar_m2):*A.more2
}

void kappaetc_get_propobs_pa(`clAgreeCoefS' K)
{
	if (colmissing(K.p_ai) == rows(K.p_ai)) {
		K.p_a = .
	}
	else {
		K.p_a = (1/K.nprime)*quadsum(K.w_i:*K.p_ai)
	}
}

void kappaetc_get_propexp(`clAgreeStatS' A)
{
	`RS' Tw
	`RM' eps_g, delta
	`RR' pi_k_m2
	
	// Percent agreement
	A.K[1].p_ei = J(rows(A.r_ik), 1, 0)
	kappaetc_get_propexp_pe(A.K[1])
	
	Tw = missing(A.acm) ? quadsum(A.w_kl) : 2*quadcolsum(A.w_kl)*A.p_k'-1
	
	// Brennan-Prediger (equivalent to PABAK, cf. p. 69)
		// Gwet 2014, p. 87 (3.4.5)
	A.K[2].p_ei = J(rows(A.r_ik), 1, Tw/A.q^2)
	kappaetc_get_propexp_pe(A.K[2])
		// Gwet 2014, p. 329 (11.3.8)
	A.K[2].p_ei = /// p_ei = u_i [ + p_e ]
				quadrowsum((quadcolsum(A.w_kl):-1):*(A.e_ik:-A.p_k)/A.q^2) ///
				:+ (A.K[2].p_e) // add p_e because V() removes it later
				
	// Cohen/Conger kappa
		// Gwet 2014, p. 149; error page
	if (A.K[3].estOK) {
		eps_g = (A.raw':<missingof(A.raw))
		A.K[3].p_ei = J(A.r*A.q, rows(A.r_ik), 0)
		for (l = 1; l <= A.q; ++l) {
			delta = (A.raw':==A.cat[l])
			A.K[3].p_ei = A.K[3].p_ei + ///
				A.w_kl[, l]#(delta:-A.p_gk[, l]:*(eps_g:-A.n_g/A.K[3].n))
		}
		A.K[3].p_ei = J(A.q, 1, A.K[3].n:/(A.n_g)):*A.K[3].p_ei
		A.K[3].p_ei = quadcolsum(A.K[3].p_ei:*vec(A.r*mean(A.p_gk):-A.p_gk))	
		A.K[3].p_ei = 1/(A.r*(A.r-1)):*A.K[3].p_ei'
	}
	else {
			// not possible with frequency data or ACM
		A.K[3].p_ei = J(rows(A.raw), 1, .)
	}
	kappaetc_get_propexp_pe(A.K[3])
	
	// Fleiss kappa
		// Gwet 2014, p. 148 (5.3.24)
	if (A.K[4].estOK) {
		A.K[4].p_ei = quadcolsum((A.w_kl:*A.pi_k':+(A.w_kl:*A.pi_k)'):/2)
		A.K[4].p_ei = quadrowsum(A.K[4].p_ei:*(A.r_ik:/A.r_i))
	}
	else {
			// should be possible with ACM but formulas are probably wrong
		A.K[4].p_ei = J(rows(A.raw), 1, .)
	}
	kappaetc_get_propexp_pe(A.K[4])
	
	// Gwet AC
		// Gwet 2014, p. 148 (5.3.23)
	A.K[5].p_ei = Tw/(A.q*(A.q-1))*((A.r_ik:/A.r_i)*(1:-A.pi_k)')
		// Gwet 2014, p. 327 (11.3.1, 11.3.2, 11.3.4)
	kappaetc_get_propexp_pe(A.K[5])
	A.K[5].p_ei = Tw/(A.q*(A.q-1))*quadrowsum((A.r_ik:/A.r_i):*(1:-A.pi_k) ///
				+ (quadcolsum(A.w_kl):-1):*(A.e_ik:-A.p_k):*A.K[5].p_e/Tw)
				
	// Krippendorff's alpha
		// Gwet 2014, p. 149
	if (A.K[6].estOK) {
		pi_k_m2 = quadcolsum((1/A.K[6].n)*A.K[6].w_i:*(A.r_ik:/A.rbar_m2))
		A.K[6].p_ei = quadcolsum((A.w_kl:*pi_k_m2':+(A.w_kl:*pi_k_m2)'):/2)
		A.K[6].p_ei = quadrowsum(A.K[6].p_ei:*(A.r_ik:/A.rbar_m2))
		kappaetc_get_propexp_pe(A.K[6])
		A.K[6].p_ei = A.K[6].p_ei:-A.K[6].p_e:*(A.r_i:-A.rbar_m2)/A.rbar_m2
		A.K[6].p_ei = A.K[6].p_ei:*A.more2
	}	
	else {
			// not possible with ACM
		A.K[6].p_ei = J(rows(A.raw), 1, .)
		kappaetc_get_propexp_pe(A.K[6])
	}	
}

void kappaetc_get_propexp_pe(`clAgreeCoefS' K)
{
	if (colmissing(K.p_ei) == rows(K.p_ei)) {
		K.p_e = .
	}
	else {
		K.p_e = (1/K.n)*quadcolsum(K.w_i:*K.p_ei)
	}
}

void kappaetc_get_results(`clAgreeStatS' A)
{
	A.results.b = A.results.se = A.results.df = J(1, length(A.K), .)
	
	if ((A.info.store) | (A.info.returnmore)) {
		A.results.b_istar = J(rows(A.w_i), length(A.K), .)
	}
	
	for (i = 1; i <= length(A.K); ++i) {
		A.results.b[i] = A.K[i].b()
		if ((A.info.seconditional != "subjects") & (!A.info.wgtkrippendorff)) {
			A.results.se[i] = A.K[i].V()
		}
		if (A.info.dfmat != "") {
			A.results.df[i] = st_matrix(A.info.dfmat)[i]
		}
		else {
			A.results.df[i] = A.K[i].n-1
		}
		if ((A.info.store) | (A.info.returnmore)) {
			A.results.b_istar[, i] = ///
				((1-A.K[i].eps_n):*A.K[i].b_istar():+A.K[i].eps_n)
			A.results.b_istar[, i] = ///
				(1:/(!(!A.K[i].more2*A.K[i].eps_n))):*A.results.b_istar[, i]
		}
	}
	
	if (A.info.seconditional != "raters") {
		kappaetc_get_results_jknife(A)
		A.results.se_conditional = A.results.se
	}
	
	if (A.info.seconditional == "subjects") {
		A.results.se = A.results.se_jknife
	}
	else if (A.info.setype == "unconditional") {
		// Gwet 2014, p. 156 (5.4.4)
		A.results.se = A.results.se_conditional + A.results.se_jknife
		A.results.se_conditional 	= sqrt(A.results.se_conditional)
		A.results.se_jknife 		= sqrt(A.results.se_jknife)
	}
	
	A.results.se = sqrt(A.results.se)
}

void kappaetc_get_results_jknife(`clAgreeStatS' A)
{
	`clAgreeStatS' Ajknife
	
	A.results.K_g = J(A.r, length(A.K), .)
	for (g = 1; g <= A.r; ++g) {
		Ajknife.raw = select(A.raw, ((1..cols(A.raw)):!=g))
		Ajknife.w_i = A.w_i:*(rowmissing(Ajknife.raw):<cols(Ajknife.raw))	
		kappaetc_get_allmats(Ajknife)
		kappaetc_set_basicsK(Ajknife)
		kappaetc_get_propobs(Ajknife)
		kappaetc_get_propexp(Ajknife)		
		for (i = 1; i <= length(A.K); ++i) {
			A.results.K_g[g, i] = Ajknife.K[i].b()
		}
	}
	
	A.results.se_jknife = ///
		(1:/colnonmissing(A.results.K_g)):*quadcolsum(A.results.K_g)
	A.results.se_jknife = ///
		quadcolsum((A.results.K_g:-A.results.se_jknife):^2, 1)
	A.results.se_jknife = ///
		((1-A.K[1].g_r)*(A.r-1)/A.r)*A.results.se_jknife	
}

void kappaetc_set_results(`clAgreeStatS' A)
{
	`SC' names
	`RM' tmp
	
	st_rclear()
	
	st_numscalar("r(N)", A.n)
	st_numscalar("r(r)", A.r)
	st_numscalar("r(r_min)", colmin(A.r_i))
	st_numscalar("r(r_avg)", (1/A.n)*quadcolsum(A.w_i[, 1]:*A.r_i))
	st_numscalar("r(r_max)", colmax(A.r_i))
	if (A.info.seconditional != "raters") {
		tmp = J(1, length(A.K), .) 
		for (i = 1; i <= length(A.K); ++i) {
			tmp[i] = A.K[i].estOK
		}
		st_numscalar("r(jk_miss)", missing(select(A.results.K_g, tmp)))
	}
	
	st_global("r(dfmat)", A.info.dfmat)
	st_global("r(acm)", A.info.acm)
	if (A.info.weight != "") {
		st_global("r(wexp)", A.info.exp)
		st_global("r(wtype)", A.info.weight)
	}
	st_global("r(seconditional)", A.info.seconditional)
	st_global("r(setype)", A.info.setype)
	st_global("r(userwgt)", A.info.wgttype)
	st_global("r(wgt)", A.info.wgt)
	st_global("r(cmd)", "kappaetc")
	
	names = J(length(A.K), 2, "")
	for (i = 1; i <= length(A.K); ++i) {
		names[i, 2] = A.K[i].name
	}
	
	tmp = J(1, length(A.K), .)
	for (i = 1; i <= length(A.K); ++i) {
		tmp[i] = A.K[i].estOK
	}
	st_matrix("r(estimable)", tmp)
	st_matrixcolstripe("r(estimable)", names)
	
	if ((A.info.store) | (A.info.returnmore)) {
		if (A.info.weight != "") {
			if (A.info.weight != "aweight") {
				st_matrix("r(weight_i)", A.w_i[, 1])
			}
			else {
				st_matrix("r(weight_i)", A.w_i)
			}
		}
		st_matrix("r(b_istar)", A.results.b_istar)
		st_matrixcolstripe("r(b_istar)", names)
	}
	
	st_matrix("r(categories)", A.cat)
	
	st_matrix("r(W)", A.w_kl)
	
	tmp = J(2, length(A.K), .)
	for (i = 1; i <= length(A.K); ++i) {
		tmp[1, i] = A.K[i].p_e
		tmp[2, i] = (1-A.K[i].eps_n)*A.K[i].p_a+A.K[i].eps_n
	}
	
	st_matrix("r(prop_e)", tmp[1, ])
	st_matrixcolstripe("r(prop_e)", names)
	st_matrix("r(prop_o)", tmp[2, ])
	st_matrixcolstripe("r(prop_o)", names)
	
	st_matrix("r(df)", A.results.df)
	st_matrixcolstripe("r(df)", names)
	
	if (A.info.seconditional != "raters") {
		if (A.info.setype == "unconditional") {
			st_matrix("r(se_cond_raters)", A.results.se_conditional)
			st_matrixcolstripe("r(se_cond_raters)", names)
			st_matrix("r(se_cond_subjects)", A.results.se_jknife)
			st_matrixcolstripe("r(se_cond_subjects)", names)
		}
		st_matrix("r(b_jknife)", A.results.K_g)
		st_matrixcolstripe("r(b_jknife)", names)
	}
	
	st_matrix("r(se)", A.results.se)
	st_matrixcolstripe("r(se)", names)
	
	st_matrix("r(b)", A.results.b)
	st_matrixcolstripe("r(b)", names)
	
	if (!A.info.returnmore) {
		return
	}
	
	st_numscalar("r(eps_n)", A.K[6].eps_n)
	
	st_matrix("r(prop_o_i)", A.K[1].p_ai)
	st_matrix("r(prop_e_i)", A.K[1].p_ei)
	for (i = 2; i<= length(A.K); ++i) {
		st_matrix("r(prop_o_i)", (st_matrix("r(prop_o_i)"), A.K[i].p_ai))
		st_matrix("r(prop_e_i)", (st_matrix("r(prop_e_i)"), A.K[i].p_ei))
	}
	st_matrixcolstripe("r(prop_o_i)", st_matrixcolstripe("r(prop_o)"))
	st_matrixcolstripe("r(prop_e_i)", st_matrixcolstripe("r(prop_e)"))
}

end

/* ---------------------------------------------------------------------------
	Specific agreement (dice)
--------------------------------------------------------------------------- */

local stDiceInfo struct_kappaetc_dice_def
local stDiceInfoS struct `stDiceInfo' `S'

local stDiceCoef struct_kappaetc_dice_coef_def
local stDiceCoefS struct `stDiceCoef' `S'

local clDice class_kappaetc_dice_def
local clDiceS class `clDice' `S'

mata :

struct `stDiceInfo' {
	`SR' varlist
	`SS' touse
	`SS' weight
	`SS' exp
	`SS' weightvar
	`RS' listwise
	`RS' is_freq
	`RC' category
	`RS' is_float
	`RS' level
	`SS' setype
	`RS' dots
	`RS' reps
	`RS' seed
	`RS' tolerance
	`RS' returnmore
}

struct `stDiceCoef' {
	`RM' b
	`RM' se
	`RM' b_i
	`RM' z0
	`RM' ci_pctile
	`RM' ci_bc
}

class `clDice' {
	static `stDiceInfoS' 	info
	`RM' 					raw
	`RC' 					w_i
	static `RC' 			cat
	static `RS' 			q
	`RM' 					r_ik
	`RC' 					r_i
	`RS' 					n
	`stDiceCoefS' 			s_j
	`stDiceCoefS' 			_vs
	`stDiceCoefS' 			_pr
	`stDiceCoefS' 			p_o
}

void kappaetc_dice_ado()
{
	`clDiceS' D
	
	kappaetc_dice_get_info(D)
	kappaetc_dice_get_data(D)
	kappaetc_dice_estimate(D)
	kappaetc_dice_stderror(D)
	kappaetc_dice_rresults(D)
}

void kappaetc_dice_get_info(`clDiceS' D)
{
	D.info.varlist 		= tokens(st_local("varlist"))
	D.info.touse 		= st_local("touse")
	D.info.weight 		= st_local("weight")
	D.info.exp 			= st_local("exp")
	D.info.weightvar 	= st_local("weightvar")
	D.info.listwise 	= (st_local("listwise") != "")
	D.info.is_freq 		= (st_local("frequency") != "")
	D.info.category 	= strtoreal(tokens(st_local("categories")))'
	D.info.is_float 	= (st_local("catfloat") != "")
	D.info.level 		= strtoreal(st_local("level"))
	D.info.setype 		= st_local("setype")
	D.info.dots 		= strtoreal(st_local("sedots"))
	D.info.reps 		= strtoreal(st_local("sereps"))
	D.info.seed 		= strtoreal(st_local("seseed"))
	D.info.tolerance 	= strtoreal(st_local("tolerance"))
	D.info.returnmore 	= (st_local("returnmore") != "")
}

void kappaetc_dice_get_data(`clDiceS' D)
{
	D.raw = st_data(., D.info.varlist, D.info.touse)
	D.w_i = (D.info.weight != "") ? 
		st_data(., D.info.weightvar, D.info.touse) : J(rows(D.raw), 1, 1)
	
	if (D.info.is_freq) {
		kappaetc_dice_get_data_freq(D)
	}
	else {
		kappaetc_dice_get_data_rate(D)
	}
	
	if (D.q < 2) {
		errprintf("ratings do not vary\n")
		exit(459)
	}
	
	D.r_i 	= rowsum(D.r_ik)
	D.r_ik  = select(D.r_ik, 	(D.r_i :> 1))
	D.w_i 	= select(D.w_i, 	(D.r_i :> 1))
	
	if ((D.info.is_freq) & (D.info.listwise)) {
		D.r_ik 	= select(D.r_ik, 	(D.r_i :== colmax(D.r_i)))
		D.w_i 	= select(D.w_i, 	(D.r_i :== colmax(D.r_i)))
		D.r_i 	= select(D.r_i, 	(D.r_i :== colmax(D.r_i)))
	}
	D.r_i = select(D.r_i, (D.r_i :> 1))
	
	if ((rows(D.r_ik) < 1) | (colmax(D.r_i) < 2)) {
		exit(error(2001))
	}
}

void kappaetc_dice_get_data_freq(`clDiceS' D)
{
	`RC' order
	
	if (any(D.raw:<0) | hasmissing(D.raw) | any(D.raw:!=trunc(D.raw))) {
		errprintf("negative, missing or noninteger ")
		errprintf("rating frequencies encountered\n")
		exit(459)
	}
	
	D.cat = (1::cols(D.raw))
	if (rowsum(colsum(D.raw):>0) < 2) {
		D.cat = select(D.cat, colsum(D.raw)')
	}
	
	if (rows(D.info.category) & (rows(D.cat) > 1)) {
		order = sort((D.info.category, D.cat), 1)[, 2]
		D.raw = D.raw[, order]
		D.cat = D.info.category[order]
		D.raw = select(D.raw, (rownonmissing(D.cat)'))
	}
	
	D.q 	= rows(D.cat)
	D.r_ik 	= D.raw
}

void kappaetc_dice_get_data_rate(`clDiceS' D)
{
	D.cat = uniqrows(vec(D.raw))
	D.cat = select(D.cat, (rownonmissing(D.cat)))

	if (rows(D.info.category) & (rows(D.cat) > 1)) {
		if (D.info.is_float) {
			D.info.category = floatround(D.info.category)
		}
		for (i = 1; i <= rows(D.cat); ++i) {
			if (!anyof(D.info.category, D.cat[i])) {
				errprintf("categories() invalid -- ")
				errprintf("value " + strofreal(D.cat[i]) + " not")
				errprintf(" specified but observed in the data\n")
				exit(198)
			}
		}
		D.cat = sort(D.info.category, 1)
		D.cat = select(D.cat, (rownonmissing(D.cat)))
	}
	
	D.q 	= rows(D.cat)
	D.r_ik 	= J(rows(D.raw), D.q, .)
	for (k = 1; k <= D.q; ++k) {
		D.r_ik[, k] = rowsum((D.raw :== D.cat[k]))
	}
}

void kappaetc_dice_estimate(`clDiceS' D)
{
	`RR' s_j, pos
	`RM' wr_ik
	
	D.n = colsum(D.w_i)
	s_j = colsum(D.w_i:*(D.r_ik:*(D.r_ik:-1)))
	pos = colsum(D.w_i:*(D.r_ik:*(D.r_i:-1)))
	
	D.s_j.b = s_j:/colsum(D.w_i:*(D.r_ik:*(D.r_i:-1)))
	D._vs.b = D._pr.b = J(D.q, D.q, .)
	
	for (k = 1; k <= D.q; ++k) {
		wr_ik 			= I(D.q)
		wr_ik[, k] 		= J(D.q, 1, 1)
		wr_ik 			= colsum(D.w_i:*(D.r_ik[, k]:*(D.r_ik*wr_ik':-1)))
		D._vs.b[k, ] 	= s_j[k]:/wr_ik
		D._pr.b[k, ] 	= ((wr_ik:/2):-(wr_ik:/2)[k]):/(pos:/2)
	}
	_diag(D._vs.b, D.s_j.b)
	_diag(D._pr.b, D.s_j.b)
	
	D.p_o.b = quadrowsum(s_j):/colsum(D.w_i:*(D.r_i:*(D.r_i:-1)))
}

void kappaetc_dice_stderror(`clDiceS' D)
{
	`clDiceS' D2
	
	if (D.info.setype == "nose") {
		D.s_j.se = J(1, D.q, .)
		D._vs.se = J(D.q, D.q, .)
		D._pr.se = J(D.q, D.q, .)
		D.p_o.se = .
		return
	}
	
	if (D.info.setype == "jackknife") {
		D.info.reps = rows(D.r_ik)
	}
	
	D.s_j.b_i = J(D.info.reps, D.q, .)
	D._vs.b_i = J(D.info.reps, D.q^2, .)
	D._pr.b_i = J(D.info.reps, D.q^2, .)
	D.p_o.b_i = J(D.info.reps, 1, .)
	
	D2.r_ik = D.r_ik
	D2.r_i 	= D.r_i
	D2.w_i 	= D.w_i
	
	kappaetc_dice_stderror_reps(D)
	
	if (D.info.setype == "bootstrap") {
		kappaetc_dice_stderror_boot(D, D2)
		kappaetc_dice_stderror_ci(D)
	}
	else if (D.info.setype == "jackknife") {
		kappaetc_dice_stderror_jack(D, D2)
	}
	else {
		_kappaetc_internal_error("dice_stderror")
	}
	
	D.s_j.se = kappaetc_dice_stderror_se(D.s_j.b_i, D)
	D._vs.se = kappaetc_dice_stderror_se(D._vs.b_i, D, D.s_j.se)
	D._pr.se = kappaetc_dice_stderror_se(D._pr.b_i, D, D.s_j.se)
	D.p_o.se = kappaetc_dice_stderror_se(D.p_o.b_i, D)
}

void kappaetc_dice_stderror_reps(`clDiceS' D)
{
	if (D.info.dots) {
		printf("\n{txt}%s replications ", strproper(D.info.setype))
		printf("({res}%s{txt})\n{hline 1}", strofreal(D.info.reps))
		for (i = 1; i <= 5; ++i) {
			printf("{txt}{hline 3}{c +}{hline 3} ")
			printf("{txt}%1.0f ", i)
		}
		printf("\n")
	}
	else if (D.info.reps >= 1000) {
		printf("{txt}(estimating %s standard errors)\n", D.info.setype)
		displayflush()
	}
}

void kappaetc_dice_stderror_boot(`clDiceS' D, `clDiceS' D2)
{
	`RM' draws
	
	if (!missing(D.info.seed)) {
		rseed(D.info.seed)
	}
	
	if (D.info.weight == "") {
		draws = floor(rows(D.r_ik):*runiform(D.info.reps, rows(D.r_ik))':+1)
		for (i = 1; i <= D.info.reps; ++i) {
			D2.r_ik = D.r_ik[draws[, i], ]
			D2.r_i 	= D.r_i[draws[, i], ]
			D2.w_i 	= D.w_i[draws[, i], ]
			kappaetc_dice_estimate(D2)
			D.s_j.b_i[i, ] 	= D2.s_j.b
			D._vs.b_i[i, ] 	= rowshape(D2._vs.b, 1)
			D._pr.b_i[i, ] 	= rowshape(D2._pr.b, 1)
			D.p_o.b_i[i] 	= D2.p_o.b
			kappaetc_dice_stderror_dots(i, D2)
		}
	}
	else {
		D2.r_ik = D.r_ik
		D2.r_i 	= D.r_i
		for (i = 1; i <= D.info.reps; ++i) {
			D2.w_i 	= mm_upswr(D.n, D.w_i, 1)
			kappaetc_dice_estimate(D2)
			D.s_j.b_i[i, ] = D2.s_j.b
			D._vs.b_i[i, ] = rowshape(D2._vs.b, 1)
			D._pr.b_i[i, ] = rowshape(D2._pr.b, 1)
			D.p_o.b_i[i] 	= D2.p_o.b
			kappaetc_dice_stderror_dots(i, D2)
		}
	}
}

void kappaetc_dice_stderror_jack(`clDiceS' D, `clDiceS' D2)
{
	for (j = 1; j <= D.info.reps; ++j) {
		D2.w_i[j] 		= D2.w_i[j]-1
		kappaetc_dice_estimate(D2)
		D.s_j.b_i[j, ] 	= D2.s_j.b
		D._vs.b_i[j, ] 	= rowshape(D2._vs.b, 1)
		D._pr.b_i[j, ] 	= rowshape(D2._pr.b, 1)
		D.p_o.b_i[j] 	= D2.p_o.b
		D2.w_i[j] 		= D2.w_i[j]+1
		kappaetc_dice_stderror_dots(j, D2)
	}
	D.s_j.b_i = D.s_j.b_i :+ D.n:*(D.s_j.b:-D.s_j.b_i)
	D._vs.b_i = D._vs.b_i :+ D.n:*(rowshape(D._vs.b, 1):-D._vs.b_i)
	D._pr.b_i = D._pr.b_i :+ D.n:*(rowshape(D._pr.b, 1):-D._pr.b_i)
	D.p_o.b_i = D.p_o.b_i :+ D.n:*(D.p_o.b:-D.p_o.b_i)
}

void kappaetc_dice_stderror_dots(`RS' i, `clDiceS' D2)
{
	if (!D2.info.dots) {
		return
	}
	
	if (!mod(i, D2.info.dots)) {
		if ( missing(D2.s_j.b\ D2._vs.b\ D2._pr.b) | missing(D2.p_o.b) ) {
			printf("{err}%s{sf}", "x")
		}
		else {
			printf("{txt}%s", ".")
		}
	}
	
	if (!mod(i/D2.info.dots, 50)) {
		printf("{txt}%6.0f\n", i)
	}
	
	if (i == D2.info.reps) {
		printf("\n")
	}
	displayflush()
}

void kappaetc_dice_stderror_ci(`clDiceS' D)
{
	`RM' p
	`RR' K
	
	p = D.info.level/100
	p = ((1-p)/2, 1-(1-p)/2)'
	
	D.s_j.ci_pctile = kappaetc_boot_pctile(D.s_j.b_i, p)
	D.p_o.ci_pctile = kappaetc_boot_pctile(D.p_o.b_i, p)
	
	K = colnonmissing(D.s_j.b_i)
	D.s_j.z0 = invnormal(colsum(editmissing(D.s_j.b_i, .z):<=D.s_j.b):/K)
	D.s_j.ci_bc = kappaetc_dice_stderror_ci_bc(D.s_j.b_i, D.s_j.z0, p[2])
	K = colnonmissing(D.p_o.b_i)
	D.p_o.z0 = invnormal(colsum(editmissing(D.p_o.b_i, .z):<=D.p_o.b):/K)
	D.p_o.ci_bc = kappaetc_dice_stderror_ci_bc(D.p_o.b_i, D.p_o.z0, p[2])
}

`RM' kappaetc_dice_stderror_ci_bc(`RM' b_i, `RR' z0, `RS' p)
{
	`RC' pp
	
	pp = (normal(z0:+z0:-invnormal(p))\ normal(z0:+z0:+invnormal(p)))
	return(kappaetc_boot_pctile(b_i, pp))
}

`RM' kappaetc_dice_stderror_se(`RM' b_i, `clDiceS' D, | `RM' diag)
{
	`RR' N
	`RM' b, se
	
	if (D.info.setype == "bootstrap") {
		N 	= colnonmissing(b_i)
		b 	= (1:/N):*quadcolsum(b_i)
		se 	= sqrt((1:/(N:-1)):*quadcolsum((b_i:-b):^2))
	}
	else if (D.info.setype == "jackknife") {
		N 	= colsum(D.w_i:*(b_i:<.))
		b 	= (1:/N):*quadcolsum(D.w_i:*b_i)
		se 	= sqrt((1:/(N:*(N:-1))):*quadcolsum(D.w_i:*(b_i:-b):^2))
	}
	else {
		_kappaetc_internal_error("dice_stderror_r_se")
	}
	
	se 	= (cols(se)>D.q) ? colshape(se, D.q) : se
	se 	= se:/(reldif(se, J(rows(se), cols(se), 0)):>D.info.tolerance)
	
	if (args() == 3) {
		_diag(se, diag)
	}
	
	return(se)
}

void kappaetc_dice_rresults(`clDiceS' D)
{
	`SS' strng
	`SM' names
	
	st_rclear()
	
	st_numscalar("r(N)", D.n)
	st_numscalar("r(r)", colmax(D.r_i))
	st_numscalar("r(r_min)", colmin(D.r_i))
	st_numscalar("r(r_avg)", mean(D.r_i))
	st_numscalar("r(r_max)", colmax(D.r_i))
	st_numscalar("r(prop_o)", D.p_o.b)
	st_numscalar("r(se_prop_o)", D.p_o.se)
	if (D.info.setype == "bootstrap") {
		st_numscalar("r(prop_o_z0)", D.p_o.z0)
	}
	
	if (D.info.setype != "nose") {
		if (D.info.setype == "bootstrap") {
			strng = "bs_miss"
			if (!missing(D.info.seed)) {
				st_numscalar("r(seed)", D.info.seed)
			}
			st_numscalar("r(cilevel)", D.info.level)
		}
		else if (D.info.setype == "jackknife") {
			strng = "jk_miss"
		}
		else {
			_kappaetc_internal_error("dice_rresults")
		}
		st_numscalar("r(reps)", D.info.reps)
		st_numscalar("r(" + strng + ")", missing(D.s_j.b_i))
		st_numscalar("r(conditional_" + strng + ")", missing(D._pr.b_i))
		st_numscalar("r(vs_" + strng + ")", missing(D._vs.b_i))
		st_numscalar("r(prop_o_" + strng + ")", missing(D.p_o.b_i))
	}
	
	if (D.info.weight != "") {
		st_global("r(wexp)", D.info.exp)
		st_global("r(wtype)", D.info.weight)
	}
	st_global("r(setype)", D.info.setype)
	st_global("r(cmd2)", "dice")
	st_global("r(cmd)", "kappaetc")
	
	st_matrix("r(estimable)", J(1, D.q, 1))
	st_matrix("r(categories)", D.cat)
	if (D.info.setype == "bootstrap") {
		st_matrix("r(prop_o_ci_bc)", D.p_o.ci_bc)
		st_matrix("r(ci_bc)", D.s_j.ci_bc)
		st_matrix("r(prop_o_ci_percentile)", D.p_o.ci_pctile)
		st_matrix("r(ci_percentile)", D.s_j.ci_pctile)
		st_matrix("r(z0)", D.s_j.z0)
	}
	st_matrix("r(se_vs)", D._vs.se)
	st_matrix("r(se_conditional)", D._pr.se')
	st_matrix("r(se)", D.s_j.se)
	st_matrix("r(b_vs)", D._vs.b)
	st_matrix("r(b_conditional)", D._pr.b')
	st_matrix("r(b)", D.s_j.b)
	
	names = ("Category " :+ strofreal((1::D.q)))
	names = (J(D.q, 1, ""), names)
	
	st_matrixcolstripe("r(estimable)", names)
	
	st_matrixcolstripe("r(b)", names)
	st_matrixcolstripe("r(b_conditional)", names)
	st_matrixrowstripe("r(b_conditional)", names)
	st_matrixcolstripe("r(b_vs)", names)
	st_matrixrowstripe("r(b_vs)", names)
	
	st_matrixcolstripe("r(se)", names)
	st_matrixcolstripe("r(se_conditional)", names)
	st_matrixrowstripe("r(se_conditional)", names)
	st_matrixcolstripe("r(se_vs)", names)
	st_matrixrowstripe("r(se_vs)", names)
	
	if (D.info.setype == "bootstrap") {
		st_matrixcolstripe("r(ci_percentile)", names)
		st_matrixrowstripe("r(ci_percentile)", ("", "ll"\ "", "ul"))
		st_matrixcolstripe("r(ci_bc)", names)
		st_matrixrowstripe("r(ci_bc)", ("", "ll"\ "", "ul"))
		st_matrixcolstripe("r(z0)", names)
	}
	
	if (!D.info.returnmore) {
		return
	}
	
	if (D.info.setype == "nose") {
		return
	}
	
	if (D.info.setype == "bootstrap") {
		strng = "_bs"
	}
	else if (D.info.setype == "jackknife") {
		strng = "_jk"
	}
	else {
		_kappaetc_internal_error("dice_rresults")
	}
	st_matrix("r(prop_o" + strng + ")", D.p_o.b_i)
	st_matrix("r(b_vs" + strng + ")", D._vs.b_i)
	st_matrix("r(b_conditional" + strng + ")", D._pr.b_i)
	st_matrix("r(b" + strng + ")", D.s_j.b_i)
	
	st_matrixcolstripe("r(b" + strng +")", names)
	st_matrixcolstripe("r(b_conditional" + strng + ")", J(D.q, 1, names))
	st_matrixcolstripe("r(b_vs" + strng + ")", J(D.q, 1, names))
}

`RM' kappaetc_boot_pctile(`RM' X, `RM' P)
{
	`RS' colsX, colsP, rowsP, k
	`RM' _P, Pct, j
	`RC' x_i, g
	
	colsX = cols(X)
	colsP = cols((_P=P))
	if (colsP == 1) {
		_P = J(1, colsX, _P)
	}
	else if (colsP != colsX) {
		kappaetc_internal_error("boot_pctile")
	}
	
	rowsP = rows(P)
	Pct = J(rowsP, colsX, .)
	
	for (i = 1; i <= colsX; ++i) {
		x_i = sort(X[, i], 1)
		x_i = select(x_i, (x_i:<.))
		k 	= rows(x_i)	
		if ((k > 2) & (!missing(_P[, i]))) {
			j = floor(_P[, i]:*k)
			g = ((_P[, i]:*k):-j)
			g = (g:>0):+(g:<=0)/2
			j = j, j:+1
			j = j:*(j:>=1):+(j:<1) 		// minimum 1
			j = j:*(j:<=k):+(j:>k):*k 	// maximum k	
			Pct[, i] = (1:-g):*x_i[j[, 1]]:+g:*x_i[j[, 2]]
		}
		else {
			Pct[, i] = J(rowsP, 1, (((k<1) | missing(_P[, i])) ? . : x_i))
		}
	}
	
	return(Pct)
}

end

/* ---------------------------------------------------------------------------
	paired t-tests (ttest)
--------------------------------------------------------------------------- */

local clTtest class_kappaetc_ttest_def_

mata :

class `clTtest' {
	public :
		void 				setup()
		
		`RR' 				b()
		`RR' 				se()
		`RM' 				d_i()
		`RR' 				n()
		`RR' 				estimable()
		`SM' 				colnames()
		
	private :
		void 				get_info()
		void 				verify_coef()
		void 				verify_info()
		void 				error459()
		`RC' 				w_i()
		
		`SR' 				name
		`RS' 				tolerance
		`Boolean' 			forcettest			
		`SM' 				colnames
		
		pointer(`RM') `R' 	b_istar
		pointer(`RC') `R' 	w_i
		pointer(`RR') `R' 	df
		pointer(`RR') `R' 	rb
		pointer(`RM') `R' 	W
		pointer(`RC') `R' 	cat
		pointer(`RR') `R' 	estimable
		
		`RR' 				b
		`RR' 				se
		`RM' 				d_i
}

// ------------------------------------- public functions
void `clTtest'::setup(`SS' caller_name1, `SS' caller_name2)
{
	name 		= (caller_name1, caller_name2)
	b_istar 	= J(1, 2, NULL)
	w_i 		= J(1, 2, NULL)
	df 			= J(1, 2, NULL)
	rb 			= J(1, 2, NULL)
	W 			= J(1, 2, NULL)
	cat 		= J(1, 2, NULL)
	estimable 	= J(1, 2, NULL)
	
	b 			= .z
	se 			= .z
	d_i 		= .z
	
	get_info()
	verify_info()
}

`RR' `clTtest'::b() 
{
	if (b == .z) {
		b = (1:/n()):*quadcolsum(w_i():*d_i())
	}
	return(b)
}

`RR' `clTtest'::se()
{
	if (se == .z) {
		se = sqrt((1:/(n():*(n():-1))):*quadcolsum(w_i():*(d_i():-b()):^2))
	}
	return(se)
}

`RM' `clTtest'::d_i()
{
	if (d_i == .z) {
		d_i = ((*b_istar[1]):-(*b_istar[2]))
	}
	return(d_i)
}

`RR' `clTtest'::n(| `RS' i)
{
	if (!args()) i = 1
	return((*df[i]):+1)
}

`RR' `clTtest'::estimable(| `RS' i)
{
	if(!args()) i = 1
	return((*estimable[i]))
}

`SM' `clTtest'::colnames() return(colnames)

// ------------------------------------- private functions
void `clTtest'::get_info()
{
	`RS' i
	
	tolerance 	= strtoreal(st_local("tolerance"))
	forcettest 	= (st_local("forcettest") != "")
	
	for (i = 1; i <= 2; ++i) {
		(void) _stata("_return restore " + name[i] + " , hold", .)
		b_istar[i] 		= &st_matrix("r(b_istar)")
		w_i[i] 			= length(st_matrix("r(weight_i)")) ? 
						&st_matrix("r(weight_i)") : &1
		df[i] 			= &st_matrix("r(df)")
		rb[i] 			= &st_matrix("r(b)")
		W[i] 			= &st_matrix("r(W)")
		cat[i] 			= &st_matrix("r(categories)")
		estimable[i] 	= &st_matrix("r(estimable)")
		
		verify_coef(i)
	}
	
	colnames = st_matrixcolstripe("r(b)")
}

void `clTtest'::verify_coef(`RS' i)
{
	`RM' coef
	`RS' diff
	
	coef = (1:/((*df[i]):+1)):*quadcolsum((*w_i[i]):*(*b_istar[i]))
	diff = mreldif(select(coef, (*estimable[i])), 
		select((*rb[i]), (*estimable[i])))
	
	if (diff > tolerance) {
		errprintf("kappaetc results %s invalid\n", name[i])
		errprintf("subject-level coefficients do not ")
		errprintf("average to estimated coefficients\n")
		errprintf("relative difference is %-18.0g\n", diff)
		exit(499)
	}
}

void `clTtest'::verify_info()
{
	`RS' diff
	
	if (
		(mreldif((*df[1]), (*df[2])) > tolerance) |
		(rows((*b_istar[1])) != rows((*b_istar[2]))) |
		(rows((*w_i[1])) != rows((*w_i[2])))
	) {
		error459("number of subjects")
		// NotReached
	}
	
	if (mreldif((*w_i[1]), (*w_i[2])) > tolerance) {
		error459("subject-level weights")
		// NotReached
	}
	
	if (any((*estimable[1]) :!= (*estimable[2]))) {
		error459("agreement coefficients")
		// NotReached
	}
	
	if (!forcettest) {
		if (
			(cols((*W[1])) != cols((*W[2]))) | 
			(cols((*cat[1])) != cols((*cat[2])))
		) {
			error459("number of rating categories")
			// NotReached
		}
		if (mreldif((*cat[1]), (*cat[2])) > tolerance) {
			error459("weights for partial agreement")
			// NotReached
		}
	}
	
		// call only when difference can be computed
	diff = mreldif(select(b(), estimable()), 
		select(((*rb[1]):-(*rb[2])), estimable())) 
	if (diff > tolerance) {
		errprintf("subject-level differences do not average ")
		errprintf("to differences of estimated coefficients\n")
		errprintf("relative difference is %-18.0g\n", diff)
		exit(499)
	}
}

void `clTtest'::error459(`SS' msg)
{
	errprintf("kappaetc results not based on the same %s\n", msg)
	errprintf("cannot perform paired t test\n")
	exit(459)
}

`RC' `clTtest'::w_i(| `RS' i)
{
	if (!args()) i = 1
	return((*w_i[i]))
}

// ------------------------------------- main
void kappaetc_ttest_ado()
{
	class `clTtest' `S' T
	
	T.setup(st_local("name1"), st_local("name2"))
	
	st_rclear()
	
	st_numscalar("r(N)", rowmax(T.n()))
	
	st_global("r(results2)", st_local("name2"))
	st_global("r(results1)", st_local("name1"))
	st_global("r(cmd2)", "ttest")
	st_global("r(cmd)", "kappaetc")
	
	st_matrix("r(estimable)", T.estimable())
	st_matrixcolstripe("r(estimable)", T.colnames())
	st_matrix("r(df)", T.n():-1)
	st_matrixcolstripe("r(df)", T.colnames())
	st_matrix("r(se)", T.se():/T.estimable())
	st_matrixcolstripe("r(se)", T.colnames())
	st_matrix("r(b)", T.b():/T.estimable())
	st_matrixcolstripe("r(b)", T.colnames())
	
	if (st_local("returnmore") != "") {
		st_matrix("r(d_i)", T.d_i())
		st_matrixcolstripe("r(d_i)", T.colnames())
	}
}

end

/* ---------------------------------------------------------------------------
	intraclass correlation coefficients (icc) 
	----------------------------------------------------------------------- */
	
local stICC struct_kappaetc_icc_def
local stICCS struct `stICC' `S'

local stICC_info struct_kappaetc_icc_info_def
local stICC_infoS struct `stICC_info' `S'

mata :

struct `stICC_info' {
	`SR' varlist
	`SS' touse
	`SS' id
	`SS' model
	`RS' oneB
	`RS' blend
	`RS' balanced
	`RS' returnmore
}

struct `stICC' {
	`stICC_infoS' 	info
	`RR' 			id
	`RM' 			y_ijk
	`RM' 			data
	`RS' 			n
	`RS' 			r
	`RC' 			m
	`RS' 			M
	`RC' 			y_i
	`RR' 			y_j
	`RC' 			m_i
	`RC' 			m_j
	`RM' 			m_ij
	`RM' 			y_ij
	`RS' 			ybar
	`RC' 			ybar_i
	`RR' 			ybar_j
	`RM' 			ybar_ij
	`RM' 			ybar_ik
	`RM' 			ybar_ijk
	`RS' 			T_y
	`RS' 			T_2y
	`RS' 			T_2s
	`RS' 			T_2r
	`RS' 			T_2sr
	`RS' 			T_2mu
	`RR' 			k
	`RS' 			lambda_0
	`RS' 			lambda_1
	`RS' 			lambda_2
	`RC' 			lambda_i
	`RS' 			RSS
	`RS' 			h_6
	`RS' 			MSS
	`RS' 			MSR
	`RS' 			MSI
	`RS' 			MSE
	`RS' 			icc
	`RS' 			icc_a
	`RS' 			sigma2_s
	`RS' 			sigma2_r
	`RS' 			sigma2_sr
	`RS' 			sigma2_e
	`RS' 			sigma2_s0
	`RS' 			sigma2_r0
	`RS' 			sigma2_sr0
	`RS' 			sigma2_e0
}

void kappaetc_icc_ado()
{
	`stICCS' I
	
	kappaetc_icc_get_info(I)
	kappaetc_icc_get_data(I)
	kappaetc_icc_get_stat(I)
	kappaetc_icc_estimate(I)
	kappaetc_icc_rresults(I)
}

void kappaetc_icc_get_info(`stICCS' I)
{
	I.info.varlist 		= tokens(st_local("varlist"))
	I.info.touse 		= st_local("touse")
	I.info.id 			= st_local("id")
	I.info.model 		= st_local("model")
	I.info.oneB 		= (st_local("oneB") != "")
	I.info.blend 		= (st_local("blend") != "")
	I.info.balanced 	= (st_local("balanced") != "")
	I.info.returnmore 	= (st_local("returnmore") != "")
}

void kappaetc_icc_get_data(`stICCS' I)
{
	I.y_ijk = st_data(., I.info.varlist, I.info.touse)
	if (I.info.id != "") {
		I.id = st_data(., I.info.id, I.info.touse)
	}
	else {
		I.id = (1::rows(I.y_ijk))
	}
	
	I.id 	= select(I.id, (rowmissing(I.y_ijk) :< cols(I.y_ijk)))
	I.y_ijk = select(I.y_ijk, (rowmissing(I.y_ijk) :< cols(I.y_ijk)))
	I.y_ijk = select(I.y_ijk, (colmissing(I.y_ijk) :< rows(I.y_ijk)))
	if ((rows(I.y_ijk) < 2) | (cols(I.y_ijk) < 2)) {
		exit(error(2001))
	}
	
	// !! sort by id
	tmp 	= sort((I.id, I.y_ijk), 1)
	I.id 	= tmp[., 1]
	I.y_ijk = tmp[., (2..cols(tmp))]
	// // // // // // // // // // // //
	
	I.data = panelsetup((I.id, I.y_ijk), 1)
	
	if (I.info.balanced) {
		I.data = panelsetup((I.id, I.y_ijk), 1, panelstats(I.data)[4])
	}
	
	I.n = rows(I.data)
	I.r = cols(I.y_ijk)
	I.m = (I.data[, 2]:-I.data[, 1]:+1)
	
	if (I.n < 2) {
		exit(error(2001))
	}
}

void kappaetc_icc_get_stat(`stICCS' I)
{
	`RM' sub, ybar_ijk, ybar_ik
	
	I.m_ij = I.y_ij	= J(I.n, I.r, .)
	for (i = 1; i <= I.n; ++i) {
		sub 			= panelsubmatrix(I.y_ijk, i, I.data)
		I.y_ij[i, ] 	= quadcolsum(sub)
		I.m_ij[i, ] 	= colnonmissing(sub)
		ybar_ijk 		= J(rows(sub), 1, (I.y_ij[i, ]:/I.m_ij[i, ]))
		ybar_ik 		= J(rows(sub), 1, (quadsum(sub)/nonmissing(sub)))
		if (i == 1) {
			I.ybar_ijk 	= ybar_ijk
			I.ybar_ik 	= ybar_ik 
		}
		else {
			I.ybar_ijk 	= I.ybar_ijk\ ybar_ijk
			I.ybar_ik 	= I.ybar_ik\  ybar_ik
		}
	}
	_editmissing(I.ybar_ijk, 0)
	
	I.y_i 		= quadrowsum(I.y_ij) // same as sqrt(y2_i)
	I.y_j 		= quadcolsum(I.y_ij) // same as sqrt(y2_j)
	
	I.m_i 		= rowsum(I.m_ij)
	I.m_j 		= colsum(I.m_ij)
	
	I.M 		= sum(I.m_ij)
	
	I.ybar 		= quadsum(I.y_ij)/I.M
	I.ybar_i 	= quadrowsum(I.y_ij):/I.m_i
	I.ybar_j 	= quadcolsum(I.y_ij):/I.m_j
	I.ybar_ij 	= editmissing((I.y_ij:/I.m_ij), 0)
	
	kappaetc_icc_get_stat_T(I)
	kappaetc_icc_get_stat_k(I)
	kappaetc_icc_get_stat_lambda(I)
}

void kappaetc_icc_get_stat_T(`stICCS' I)
{
	I.T_y 	= quadsum(I.y_ijk)
	I.T_2y 	= quadsum(I.y_ijk:^2)
	I.T_2s 	= quadsum(I.y_i:^2:/I.m_i)
	I.T_2r 	= quadsum(I.y_j:^2:/I.m_j)	
	I.T_2sr = quadsum(I.y_ij:^2:/I.m_ij)
	I.T_2mu = I.M*(I.T_y/I.M):^2
}

void kappaetc_icc_get_stat_k(`stICCS' I)
{
	I.k 	= J(5, 1, .)
	I.k[1] 	= quadsum(I.m_i:^2)
	I.k[2] 	= quadsum(I.m_j:^2)
	I.k[3] 	= quadsum(I.m_ij:^2:/I.m_i) // same as k_1 model 1b
	I.k[4] 	= quadsum(I.m_ij:^2:/I.m_j) // same as k_0 model 1a
	I.k[5] 	= quadsum(I.m_ij:^2)
}

void kappaetc_icc_get_stat_lambda(`stICCS' I)
{	
	I.lambda_0 = sum(I.m_ij :> 0)
	I.lambda_1 = (I.M - I.k[1]/I.M)/(I.M - I.k[4])
	I.lambda_2 = (I.M - I.k[2]/I.M)/(I.M - I.k[3])
	I.lambda_i = quadrowsum(I.m_ij:^2:/I.m_i)
}

void kappaetc_icc_get_RSS_h_6(`stICCS' I)
{
	`RM' F, C
	`RS' jj
	`RR' b
	
		// Gwet 2014, pp. 302
	F = C = J(I.r, I.r, .)
	for (j = 1; j < I.r; ++j) {
		jj = (I.m_ij[, j]:*I.m_ij[, (j+1...)]):/I.m_i
		C[(j...), j] = ((-1)*quadcolsum(jj))'
		jj = jj:*(I.lambda_i:-I.m_ij[, j]:-I.m_ij[, (j+1...)])
		F[(j...), j] = quadcolsum(jj)'
	}
	_diag(F, quadcolsum((I.m_ij:^2:/I.m_i):*((I.lambda_i+I.m_i):-2*I.m_ij)))
	_makesymmetric(F)
	_diag(C, (I.m_j:-quadcolsum(I.m_ij:^2:/I.m_i)))
	_makesymmetric(C)	
	
	b = I.y_j - quadcolsum((I.m_ij:*I.y_i):/I.m_i)	
	F = F[|1, 1 \ I.r-1, I.r-1|]
	C = C[|1, 1 \ I.r-1, I.r-1|]
	b = b[(1..I.r-1)]
	
	I.RSS = I.T_2s + b*cholinv(C)*b'
	I.h_6 = I.M - (quadcolsum(I.lambda_i) + trace(cholinv(C)*F))	
}

void kappaetc_icc_estimate(`stICCS' I)
{
		// Gwet 2014, pp. 207
	I.MSS = quadsum(I.m_i:*(I.ybar_i:-I.ybar):^2)/(I.n-1)
		// Gwet 2014, pp. 218
	I.MSR = quadsum(I.m_j:*(I.ybar_j:-I.ybar):^2)/(I.r-1)
	
		// Gwet 2014, pp. 238
	I.MSI = quadsum(I.m_ij:*(I.ybar_ij:-I.ybar_i:-I.ybar_j:+I.ybar):^2)
	I.MSI = I.MSI/((I.r-1)*(I.n-1))
	
	if (I.info.model == "oneway") {
		kappaetc_icc_estimate_oneway(I)
	}
	else if (I.info.model == "random") {
		kappaetc_icc_estimate_random(I)
	}
	else if (I.info.model == "mixed") {
		kappaetc_icc_estimate_mixed(I)
	}
	else {
		_kappaetc_internal_error("icc_estimate")
	}
}

void kappaetc_icc_estimate_oneway(`stICCS' I)
{
	if (!I.info.oneB) {
			// model 1A (oneway)
			// Gwet 2014, pp. 197
		I.sigma2_e 	= (I.T_2y-I.T_2s)/(I.M-I.n)
		I.sigma2_s 	= (I.T_2s-I.T_y^2/I.M-(I.n-1)*I.sigma2_e)/(I.M-I.k[4])
		
		I.sigma2_e0 = max((I.sigma2_e, 0))
		I.sigma2_s0 = max((I.sigma2_s, 0))
		
			// ICC(1,1)
		I.icc = I.sigma2_s0/(I.sigma2_s0+I.sigma2_e0)
			
			// Gwet 2014, pp. 207
		I.MSE = quadsum((I.y_ijk:-I.ybar_ik):^2)/(I.M-I.n)
	}
	else {
			// model 1B (oneway)
			// Gwet 2014, pp. 203
		I.sigma2_e 	= (I.T_2y-I.T_2r)/(I.M-I.r)
		I.sigma2_r 	= (I.T_2r-I.T_y^2/I.M - (I.r-1)*I.sigma2_e)/(I.M-I.k[3])
		
		I.sigma2_e0 = max((I.sigma2_e, 0))
		I.sigma2_r0 = max((I.sigma2_r, 0))
		
			// ICC_a(1,1)
		I.icc_a = I.sigma2_r0/(I.sigma2_r0+I.sigma2_e0)
		
			// Gwet 2014, pp. 218
		I.MSE = quadsum((I.ybar_ijk:-I.ybar_j):^2)/(I.M-I.r)
	}
}

void kappaetc_icc_estimate_random(`stICCS' I)
{
	`RM' delta_r, delta_s, kprime
	
		// model 2 (random)
		// Gwet 2014, pp. 231
	if (any(I.m_ij:>1) & (!I.info.blend)) {
			// with interaction
		I.sigma2_e = (I.T_2y-I.T_2sr)/(I.M-I.lambda_0)
		
		delta_r = (I.T_2sr-I.T_2r-(I.lambda_0-I.r)*I.sigma2_e)/(I.M-I.k[4])
		delta_s = (I.T_2sr-I.T_2s-(I.lambda_0-I.n)*I.sigma2_e)/(I.M-I.k[3])
		
		kprime 	= I.k:/I.M
		
		I.sigma2_sr = (I.M-kprime[1])*delta_r+(I.k[3]-kprime[2])*delta_s ///
					- (I.T_2s-(I.T_y:^2/I.M)-(I.n-1)*I.sigma2_e)
		I.sigma2_sr = I.sigma2_sr/(I.M-kprime[1]-kprime[2]+kprime[5])
		I.sigma2_r 	= delta_s-I.sigma2_sr
		I.sigma2_s 	= delta_r-I.sigma2_sr
		
		I.sigma2_e0 	= max((I.sigma2_e, 0))
		I.sigma2_sr0 	= max((I.sigma2_sr, 0))
		I.sigma2_r0 	= max((I.sigma2_r, 0))
		I.sigma2_s0 	= max((I.sigma2_s, 0))
		
			// ICC(2,1)
		I.icc 	= I.sigma2_s0 ///
				/(I.sigma2_s0+I.sigma2_r0+I.sigma2_sr0+I.sigma2_e0)
		
			// ICC_a(2,1)
		I.icc_a = (I.sigma2_s0+I.sigma2_r0+I.sigma2_sr0) ///
				/ (I.sigma2_r0+I.sigma2_s0+I.sigma2_sr0+I.sigma2_e0)
		
			// Gwet 2014, pp. 239
		I.MSE = quadsum((I.y_ijk:-I.ybar_ijk):^2)/(I.M-I.r*I.n)
	}
	else {
			// Gwet 2014, pp. 256
			// no interaction
		I.sigma2_e 	= I.lambda_2*(I.T_2y-I.T_2s) ///
					+ I.lambda_1*(I.T_2y-I.T_2r) - (I.T_2y-I.T_2mu)
		I.sigma2_e 	= I.sigma2_e ///
					/ (I.lambda_2*(I.M-I.n) + I.lambda_1*(I.M-I.r) - (I.M-1))
		I.sigma2_s 	= (I.T_2y - I.T_2r - (I.M-I.r)*I.sigma2_e)/(I.M-I.k[4])
		I.sigma2_r 	= (I.T_2y - I.T_2s - (I.M-I.n)*I.sigma2_e)/(I.M-I.k[3])
		
		I.sigma2_e0 = max((I.sigma2_e, 0))
		I.sigma2_r0 = max((I.sigma2_r, 0))
		I.sigma2_s0 = max((I.sigma2_s, 0))
		
			// ICC(2,1)
		I.icc = I.sigma2_s0/(I.sigma2_s0+I.sigma2_r0+I.sigma2_e0)
		
			// ICC_a(2,1)
		if (any(I.m_ij:>1)) {
			I.icc_a = (I.sigma2_s0+I.sigma2_r0) ///
					/ (I.sigma2_s0+I.sigma2_r0+I.sigma2_e0)
		}
			// Gwet 2014, pp. 259
		I.MSE = quadsum((I.y_ijk:-I.ybar_ik:-I.ybar_j:+I.ybar):^2)
		I.MSE = I.MSE/(I.M-I.r-I.n+1)
	}
}

void kappaetc_icc_estimate_mixed(`stICCS' I)
{
		// model 3 (mixed)  
		// Gwet 2014, pp. 279, error page
	kappaetc_icc_get_RSS_h_6(I)
	
	if (any(I.m_ij:>1) & (!I.info.blend)) {
			// m>1; interaction
		I.sigma2_e 	= (I.T_2y-I.T_2sr)/(I.M-I.lambda_0)
		I.sigma2_sr = (I.T_2sr-I.RSS-(I.lambda_0-I.n-I.r+1)*I.sigma2_e)/I.h_6
		I.sigma2_s 	= (I.T_2sr-I.T_2r - (I.lambda_0-I.r)*I.sigma2_e) ///
					/ (I.M-I.k[4]) - (I.r-1)*I.sigma2_sr/I.r
		
		I.sigma2_e0 	= max((I.sigma2_e, 0))
		I.sigma2_sr0	= max((I.sigma2_sr, 0))
		I.sigma2_s0 	= max((I.sigma2_s, 0))
		
			// ICC(3,1)
		I.icc 	= (I.sigma2_s0-I.sigma2_sr0/(I.r-1)) ///
				/ (I.sigma2_s0+I.sigma2_sr0+I.sigma2_e0)
		
			// ICC_a(3,1)
		I.icc_a = (I.sigma2_s0+I.sigma2_sr0) ///
				/ (I.sigma2_s0+I.sigma2_sr0+I.sigma2_e0)
		
		I.MSE = quadsum((I.y_ijk:-I.ybar_ijk):^2)/(I.M-I.r*I.n)
	}
	else {
			// m = 1; no interaction
		I.sigma2_e 	= (I.T_2y-I.RSS)/(I.M-I.n-I.r+1)
		I.sigma2_s 	= (I.RSS-I.T_2r - (I.n-1)*I.sigma2_e)/(I.M-I.k[4])
		
		I.sigma2_e0 = max((I.sigma2_e, 0))
		I.sigma2_s0	= max((I.sigma2_s, 0))
		
			// ICC(3,1)
		I.icc = I.sigma2_s0/(I.sigma2_s0 + I.sigma2_e0)
		
			// ICC_a(3,1)
		if (any(I.m_ij:>1)) {
			I.icc_a = I.sigma2_s0/(I.sigma2_s0+I.sigma2_e0)
		}
		
		I.MSE = quadsum(I.m_ij:*(I.ybar_ij:-I.ybar_i:-I.ybar_j:+I.ybar):^2)
		I.MSE = I.MSE/((I.r-1)*(I.n-1))
	}
}

void kappaetc_icc_rresults(`stICCS' I)
{
	`SS' model_number
	
	st_rclear()
	
	st_numscalar("r(N)", I.n)
	st_numscalar("r(r)", I.r)
	st_numscalar("r(r_min)", min(I.m_i))
	st_numscalar("r(r_avg)", (1/I.n)*quadcolsum(I.m_i))
	st_numscalar("r(r_max)", max(I.m_i))
	st_numscalar("r(M)", I.M)
	st_numscalar("r(M_missing)", missing(I.y_ijk))
	st_numscalar("r(m_min)", min(I.m))
	st_numscalar("r(m_avg)", (1/I.n)*quadcolsum(I.m))
	st_numscalar("r(m_max)", max(I.m))
	
	st_numscalar("r(icc)", I.icc)
	st_numscalar("r(icc_a)", I.icc_a)
	
	st_numscalar("r(sigma2_s)", I.sigma2_s)
	st_numscalar("r(sigma2_r)", I.sigma2_r)
	st_numscalar("r(sigma2_sr)", I.sigma2_sr)
	st_numscalar("r(sigma2_e)", I.sigma2_e)
	
	st_numscalar("r(MSS)", I.MSS)
	st_numscalar("r(MSR)", I.MSR)
	st_numscalar("r(MSI)", I.MSI)
	st_numscalar("r(MSE)", I.MSE)
	
	st_numscalar("r(has_sr)", ///	
		((I.info.model != "oneway") & (max(I.m) > 1) & (!I.info.blend)))
	
	if (I.info.model == "oneway") {
		if (!I.info.oneB) {
			model_number = "1"
		}
		else {
			model_number = "1B"
		}
	}
	else if (I.info.model == "random") {
		model_number = "2"
	}
	else if (I.info.model == "mixed") {
		model_number = "3"
	}
	st_global("r(model_number)", model_number)
	st_global("r(model)", I.info.model)
	st_global("r(cmd2)", "icc")
	st_global("r(cmd)", "kappaetc")
	
	if (!I.info.returnmore) {
		return
	}
	
	st_numscalar("r(T_y)", I.T_y)
	st_numscalar("r(T_2y)", I.T_2y)
	st_numscalar("r(T_2s)", I.T_2s)
	st_numscalar("r(T_2r)", I.T_2r)
	st_numscalar("r(T_2sr)", I.T_2sr)
	st_numscalar("r(T_2mu)", I.T_2mu)
	st_numscalar("r(lambda_0)", I.lambda_0)
	st_numscalar("r(lambda_1)", I.lambda_1)
	st_numscalar("r(lambda_2)", I.lambda_2)
	st_numscalar("r(RSS)", I.RSS)
	st_numscalar("r(h_6)", I.h_6)
	st_matrix("r(lambda_i)", I.lambda_i)
	st_matrix("r(k)", I.k)
	st_matrix("r(kprime)", I.k:/I.M)
	st_matrix("r(m_i)", I.m_i)
	st_matrix("r(m_j)", I.m_j)
	st_matrix("r(m_ij)", I.m_ij)
	st_matrix("r(m)", I.m)
}

end

/* ---------------------------------------------------------------------------
	ado tables 
	----------------------------------------------------------------------- */

local stAdoT struct_ado_rtable_def
local stAdoTS struct `stAdoT' `S'

mata :

struct `stAdoT' {
	`SS' cmd2
	`RS' level
	`RS' benchmark
	`SS' citype
	`RS' testvalue
	`RS' ciclipped
	`RS' largesample
	`RM' rtable
	`SM' rownames
	`SM' colnames
}

void kappaetc_ado_rtable()
{
	`stAdoTS' T
	
	T.cmd2 				= st_global("r(cmd2)")
	T.level 			= strtoreal(st_local("level"))
	T.benchmark 		= (st_local("benchmark_scale") != "")
	T.citype 			= (st_local("citype"))
	T.testvalue 		= strtoreal(st_local("testvalue"))
	T.ciclipped 		= (st_local("ciclipped") == "")
	T.largesample 		= (st_local("largesample") != "")
	
	if (T.cmd2 == "") {
		T.cmd2 = "cac"
	}
	
	if (anyof(("cac", "dice", "ttest"), T.cmd2)) {
		kappaetc_ado_rtable_default(T)
		kappaetc_ado_rtable_citype(T)
	}
	else if (T.cmd2 == "icc") {
		kappaetc_ado_rtable_icc(T)
	}
	else {
		_kappaetc_internal_error("ado_rtable")
	}
	
	kappaetc_ado_rtable_benchmark(T)
		
	st_numscalar("r(level)", T.level)
	st_matrix("r(table)", T.rtable)
	st_matrixrowstripe("r(table)", T.rownames)
	st_matrixcolstripe("r(table)", T.colnames)
}

void kappaetc_ado_rtable_default(`stAdoTS' T)
{
	`RM' b, se, df, t, pvalue, crit, ll, ul
	`RR' signt
	`SS' relop, sname
	`SM' labels
	
	b 		= st_matrix("r(b)")
	se 		= st_matrix("r(se)")
	df 		= st_matrix("r(df)")
	
	if ((T.cmd2 == "cac") & (st_global("r(seconditional)") == "subjects")) {
		if (st_global("r(dfmat)") == "") {
			df = J(1, cols(b), st_numscalar("r(r)") - 1)
		}
	}
	
	if (T.cmd2 == "dice") {
		b 	= b, st_numscalar("r(prop_o)")
		se 	= se, st_numscalar("r(se_prop_o)")
		df 	= J(1, cols(b), (st_numscalar("r(N)")-1))
	}
	
	t 		= (b:-T.testvalue):/se
	signt 	= sign(t)
	relop 	= st_local("relop")
	
	if ((st_local("largesample") == "") 							& 	///
	( 												/// anyof the following
	(st_global("r(dfmat)") != "") | (T.cmd2 == "ttest") 			| 	///
	(T.cmd2 == "cac") & (st_global("r(setype)") == "conditional") 	| 	///
	(T.cmd2 == "dice") & (st_global("r(setype)") == "jackknife") 	)) 	///
	{
		pvalue 	= 2*ttail(df, abs(t))
		sname 	= "t"
		crit 	= invttail(df, (1-T.level/100)/2)
	}
	else {
		df 		= J(1, cols(b), .)
		pvalue 	= 2*normal(-abs(t))
		sname 	= "z"
		crit 	= J(1, cols(b), (-1)*invnormal((1-T.level/100)/2))
	}
	
	if (relop == "<") {
		pvalue = abs((signt:<0):-(pvalue/2))
	}
	else if (relop == ">") {
		pvalue = abs((signt:>0):-(pvalue/2))
	}
	
	ll 		= b-crit:*se
	ul 		= b+crit:*se
	
	kappaetc_ado_rtable_clipci(T, ll, ul)
	
	T.rtable 	= (b\ se\ t\ pvalue\ ll\ ul\ df\ crit)
	T.rownames 	= ("b", "se", sname, "pvalue", "ll", "ul", "df", "crit")
	T.rownames 	= (J(8, 1, ""), T.rownames')
	T.colnames 	= st_matrixcolstripe("r(b)")
	if (T.cmd2 == "dice") {
		if (st_local("labelcategories") != "") {
			labels = st_vlmap(st_local("labelcategories"), ///
				st_matrix("r(categories)"))
			for (k = 1; k <= rows(labels); ++k) {
				if (labels[k] != "") {
					T.colnames[k, 2] = abbrev(labels[k], 20)
				}
				T.colnames = subinstr(T.colnames, ":", " ")
				T.colnames = subinstr(T.colnames, ".", " ")
			}
		}
		st_matrixcolstripe("r(b_conditional)", T.colnames)
		st_matrixrowstripe("r(b_conditional)", T.colnames)
		st_matrixcolstripe("r(b_vs)", T.colnames)
		st_matrixrowstripe("r(b_vs)", T.colnames)
		st_matrixcolstripe("r(se_conditional)", T.colnames)
		st_matrixrowstripe("r(se_conditional)", T.colnames)
		st_matrixcolstripe("r(se_vs)", T.colnames)
		st_matrixrowstripe("r(se_vs)", T.colnames)
		T.colnames = T.colnames\ ("", "Overall Agreement")
	}
}

void kappaetc_ado_rtable_citype(`stAdoTS' T)
{
	`RM' ci
	
	if (anyof(("", "normal"), T.citype)) {
		return
	}
	
	if (T.level != st_numscalar("r(cilevel)")) {
		printf("{txt}note: confidence level set to level")
		printf("(%s)\n{sf}", strofreal(st_numscalar("r(cilevel)")))
		T.level = st_numscalar("r(cilevel)")
	}
	
	if (T.citype == "percentile") {
		ci = st_matrix("r(ci_percentile)")
		ci = ci, st_matrix("r(prop_o_ci_percentile)")
	}
	else if (T.citype == "bc") {
		ci = st_matrix("r(ci_bc)")
		ci = ci, st_matrix("r(prop_o_ci_bc)")
	}
	else {
		_kappaetc_internal_error("ado_rtable_citype")
	}
	
	T.rtable[5, ] = ci[1, ]
	T.rtable[6, ] = ci[2, ]
}

void kappaetc_ado_rtable_benchmark(`stAdoTS' T)
{
	`RM' bm, b, imp, p_cum, idx, table_prob, table_det
	`RR' z
	
	if (!T.benchmark) {
		st_matrix("r(table_benchmark_prob)", J(0, 0, .))
		st_matrix("r(table_benchmark_det)", J(0, 0, .))
		st_matrix("r(benchmarks)", J(0, 0, .))
		st_matrix("r(imp)", J(0, 0, .))
		st_matrix("r(p_cum)", J(0, 0, .))
		return
	}
	
	bm 	= strtoreal(tokens(st_local("benchmark_scale")))
	bm 	= J(1, 6, bm[cols(bm)..1]')
	b 	= st_matrix("r(b)")
	z 	= (b:-bm):/st_matrix("r(se)")
	
	if ((T.largesample) | (st_global("r(setype)") == "unconditional")) {
		imp = normal(z)
	}
	else {
		if ((st_global("r(seconditional)") == "subjects") & 
			(st_global("r(dfmat)") == "")) {
			imp = (1:-ttail(J(1, cols(b), st_numscalar("r(r)") - 1), z))
		}
		else imp = (1:-ttail(st_matrix("r(df)"), z))
	}
	
	p_cum 	= imp
	if (rows(imp) > 1) {
		for (i = 1; i <= rows(imp); ++i) {
			if (i < rows(imp)) {
				imp[i, ] 	= imp[(i+1), ]:-imp[i, ]
			}
			p_cum[i, ]		= quadcolsum(imp[(1::i), ])
		}
	}	
	p_cum = p_cum:/(p_cum:*(p_cum:>1)+(p_cum:<=1))
	
	table_prob = table_det = J(6, 6, .)
	table_prob[(1::2), ] = table_det[(1::2), ] = T.rtable[(1::2), ]
	
	for (i = 1; i <= cols(table_prob); ++i) {
		idx = ((p_cum[, i] :> (T.level/100)), (b[i] :<= bm[, i]))
		idx = (colmin(select((1::rows(bm)), idx[, 1])), ///
			colmax(select((1::rows(bm)), idx[, 2])))
		table_prob[3, i] 	= missing(idx[1]) ? idx[1] : imp[idx[1], i]
		table_det[3, i] 	= missing(idx[2]) ? idx[2] : imp[idx[2], i]
		table_prob[4, i] 	= missing(idx[1]) ? idx[1] : p_cum[idx[1], i]
		table_det[4, i] 	= missing(idx[2]) ? idx[2] : p_cum[idx[2], i]
		table_prob[5, i] 	= (idx[1] < rows(bm)) ? bm[(idx[1]+1), i] : .
		table_det[5, i] 	= (idx[2] < rows(bm)) ? bm[(idx[2]+1), i] : .
		table_prob[6, i] 	= missing(idx[1]) ? idx[1] : bm[idx[1], i]
		table_det[6, i] 	= missing(idx[2]) ? idx[2] : bm[idx[2], i]
	}
	
	st_matrix("r(p_cum)", p_cum)
	st_matrixcolstripe("r(p_cum)", st_matrixcolstripe("r(b)"))
	st_matrix("r(imp)", imp)
	st_matrixcolstripe("r(imp)", st_matrixcolstripe("r(b)"))
	st_matrix("r(benchmarks)", bm[, 1])
	st_matrixcolstripe("r(benchmarks)", ("", "Benchmarks"))
	st_matrix("r(table_benchmark_det)", table_det)
	st_matrixrowstripe("r(table_benchmark_det)", ///
		(J(cols(b), 1, ""), ("b"\ "se"\ "imp"\ "p_cum"\ "ll"\ "ul")))
	st_matrixcolstripe("r(table_benchmark_det)", st_matrixcolstripe("r(b)"))
	st_matrix("r(table_benchmark_prob)", table_prob)
	st_matrixrowstripe("r(table_benchmark_prob)", ///
		st_matrixrowstripe("r(table_benchmark_det)"))
	st_matrixcolstripe("r(table_benchmark_prob)", ///
		st_matrixcolstripe("r(table_benchmark_det)"))
}

void kappaetc_ado_rtable_icc(`stAdoTS' T)
{
	`SS' model
	`RS' n, r, m, M, MSS, MSR, MSI, MSE, has_sr
	`RS' a, b, c, F_L, F_U, A
	`RR' icc, F, df1, df2, nu1, nu2, crit, pvalue, ll, ul
	
	model 	= st_global("r(model_number)")
	
	n 		= st_numscalar("r(N)")
	r 		= st_numscalar("r(r)")
	m 		= st_numscalar("r(m_max)")
	M 		= st_numscalar("r(M)")
	has_sr 	= st_numscalar("r(has_sr)")
	
	MSS 	= st_numscalar("r(MSS)")
	MSR 	= st_numscalar("r(MSR)")
	MSI 	= st_numscalar("r(MSI)")
	MSE 	= st_numscalar("r(MSE)")
	
	icc 	= kappaetc_ado_rtable_icc_set(model, m)
	
	df1 = df2 = nu1 = nu2 = F = ll = ul = J(1, cols(icc), .)
	
	if (model == "1") {
			// Gwet 2014, pp. 207
		df1 = (n-1)
		df2 = (M-n)
		F 	= MSS/(MSE*(1+M*T.testvalue/(n*(1-T.testvalue))))
		
		F_L = (MSS/MSE)/invF(df1, df2, 1-(1-T.level/100)/2)
		F_U = (MSS/MSE)*invF(df2, df1, 1-(1-T.level/100)/2)
		ll 	= (F_L-1)/(F_L + M/n-1)
		ul 	= (F_U-1)/(F_U + M/n-1)
	}
	else if (model == "1B") {
			// Gwet 2014, pp. 218
		df1 = (r-1)
		df2 = (M-r)
		F 	= MSR/(MSE*(1+M*T.testvalue/(r*(1-T.testvalue))))
		
		F_L = (MSR/MSE)/invF(df1, df2, 1-(1-T.level/100)/2)
		F_U = (MSR/MSE)*invF(df2, df1, 1-(1-T.level/100)/2)
		ll 	= (F_L-1)/(F_L + M/r-1)
		ul 	= (F_U-1)/(F_U + M/r-1)
	}
	else if (model == "2") {
		if (has_sr) {
				// Gwet 2014, pp. 238
			a 		= (r*T.testvalue)/(n*(1-T.testvalue))
			b 		= 1 + (r*(n-1)*T.testvalue)/(n*(1-T.testvalue))
			c 		= (M/n-r)*(T.testvalue/(1-T.testvalue))
			
			df1[1] 	= (n-1)
			df2[1] 	= (a*MSR + b*MSI + c*MSE)^2/((a*MSR)^2/(r-1)+(b*MSI)^2 ///
					/((r-1)*(n-1))+(c*MSE)^2/(M-r*n))
			F[1] 	= MSS/(a*MSR + b*MSI + c*MSE)
			
			a 		= (r*icc[1])/(n*(1-icc[1]))
			b 		= 1 + (r*(n-1)*icc[1])/(n*(1-icc[1]))
			c 		= (M/n-r)*(icc[1]/(1-icc[1]))
			
			nu1[1] 	= df1[1]
			nu2[1] 	= (a*MSR + b*MSI + c*MSE)^2/((a*MSR)^2/(r-1)+(b*MSI)^2 ///
					/((r-1)*(n-1))+(c*MSE)^2/(M-r*n))
			F_L 	= invF(nu1[1], nu2[1], 1-(1-T.level/100)/2)
			F_U 	= invF(nu2[1], nu1[1], 1-(1-T.level/100)/2)
			ll[1] 	= n*(MSS-F_L*MSI) ///
					/(n*MSS+F_L*(r*MSR+(r*n-r-n)*MSI+(M-r*n)*MSE))
			ul[1] 	= n*(F_U*MSS-MSI) ///
					/(n*F_U*MSS+r*MSR+(r*n-r-n)*MSI+(M-r*n)*MSE)
					
			if (m > 1) {
					// intra-rater reliability
				a 		= 1/(r + M*T.testvalue/(n*(1-T.testvalue)))
				b 		= 1/(n + M*T.testvalue/(r*(1-T.testvalue)))
				c 		= (r*n-n-r)/(r*n+M*T.testvalue/(1-T.testvalue))
				
				df1[2] 	= (a*MSS + b*MSR + c*MSI)^2 ///
						/((a*MSS)^2/(n-1)+(b*MSR)^2 ///
						/(r-1)+(c*MSI)^2/((r-1)*(n-1)))
				df2[2] 	= (M - r*n)
				F[2] 	= (a*MSS + b*MSR + c*MSI)/MSE
				
				A 		= n*MSS + r*MSR + (r*n-n-r)*MSI
				a 		= 1/(r + M*icc[2]/(n*(1-icc[2])))
				b 		= 1/(n + M*icc[2]/(r*(1-icc[2])))
				c 		= (r*n-n-r)/(r*n+M*icc[2]/(1-icc[2]))
				nu1[2] 	= (a*MSS + b*MSR + c*MSI)^2 ///
						/((a*MSS)^2/(n-1)+(b*MSR)^2 ///
						/(r-1)+(c*MSI)^2/((r-1)*(n-1)))
				nu2[2] 	= df2[2]
				F_L 	= invF(nu1[2], nu2[2], (1-T.level/100)/2)
				F_U 	= invF(nu1[2], nu2[2], 1-(1-T.level/100)/2)
				ll[2] 	= (A - r*n*F_U*MSE)/(A + (M-r*n)*F_U*MSE)
				ul[2] 	= (A - r*n*F_L*MSE)/(A + (M-r*n)*F_L*MSE)
			}
		}
		else {
				// Gwet 2014, pp. 256
			a 		= (r*T.testvalue)/(n*(1-T.testvalue))
			b 		= 1 + ((M-r)*T.testvalue)/(n*(1-T.testvalue))
			
			df1[1] 	= (n-1)
			df2[1] 	= (a*MSR + b*MSE)^2/((a*MSR)^2/(r-1)+(b*MSE)^2/(M-r-n+1))
			F[1] 	= MSS/(a*MSR+b*MSE)
			
			a 		= r*icc[1]/(n*(1-icc[1]))
			b 		= 1 + ((M-r)*icc[1])/(n*(1-icc[1]))
			
			nu1[1] 	= df1[1]
			nu2[1] 	= (a*MSR + b*MSE)^2/((a*MSR)^2/(r-1)+(b*MSE)^2/(M-r-n+1))
			F_L 	= invF(nu1[1], nu2[1], 1-(1-T.level/100)/2)
			F_U 	= invF(nu1[1], nu2[1], (1-T.level/100)/2)	
			ll[1] 	= n*(MSS-F_L*MSE)/(n*MSS + F_L*(r*MSR + (M-n-r)*MSE))
			ul[1] 	= n*(MSS-F_U*MSE)/(n*MSS + F_U*(r*MSR + (M-n-r)*MSE))
			
			if (m > 1) {
					// intra-rater reliability
				a 		= n/(n+r+M*T.testvalue/(1-T.testvalue))
				b 		= r/(n+r+M*T.testvalue/(1-T.testvalue))
				
				df1[2] 	= (a*MSS+b*MSR)^2/((a*MSS)^2/(n-1)+(b*MSR)^2/(r-1))
				df2[2] 	= (M-n-r+1)
				F[2] 	= (a*MSS+b*MSR)/MSE
				
				a 		= n/(n+r+M*icc[2]/(1-icc[2]))
				b 		= r/(n+r+M*icc[2]/(1-icc[2]))
				
				nu1[2]	= (a*MSS+b*MSR)^2/((a*MSS)^2/(n-1)+(b*MSR)^2/(r-1))
				nu2[2] 	= df2[2]
				F_L 	= invF(nu1[2], nu2[2], 1-(1-T.level/100)/2)
				F_U 	= invF(nu1[2], nu2[2], (1-T.level/100)/2)
				ll[2] 	= (n*MSS+r*MSR-(r+n)*F_L*MSE) ///
						/(n*MSS+r*MSR+(M-n-r)*F_L*MSE)
				ul[2] 	= (n*MSS+r*MSR-(r+n)*F_U*MSE) ///
						/(n*MSS+r*MSR+(M-n-r)*F_U*MSE)
			}
		}
	}
	else if (model == "3") {
			// Gwet 201, pp. 276
		if (has_sr) {
			a 		= (1+(r-1)*T.testvalue)/(1-T.testvalue)
			b 		= (M/n-r)*(T.testvalue/(1-T.testvalue))
			
			df1[1] 	= (n-1)
			df2[1] 	= (a*MSI+b*MSE)^2 ///
					/((a*MSI)^2/((r-1)*(n-1))+((b*MSE)^2/(M-r*n)))
			F[1] 	= MSS/(a*MSI+b*MSE)
			
			a 		= (1+(r-1)*icc[1])/(1-icc[1])
			b 		= (M/n-r)*(icc[1]/(1-icc[1]))
			
			nu1[1] 	= df1[1]
			nu2[1] 	= (a*MSI+b*MSE)^2 ///
					/((a*MSI)^2/((r-1)*(n-1))+((b*MSE)^2/(M-r*n)))
			F_L 	= invF(nu1[1], nu2[1], 1-(1-T.level/100)/2)
			F_U 	= invF(nu1[1], nu2[1], (1-T.level/100)/2)
			ll[1] 	= (MSS - F_L*MSI)/(MSS + F_L*((r-1)*MSI + (M/n-r)*MSE))
			ul[1] 	= (MSS - F_U*MSI)/(MSS + F_U*((r-1)*MSI + (M/n-r)*MSE))		
			
			if  (m > 1) {
					// intra-rater reliability
				a 		= 1/((r+1)+M*T.testvalue/(n*(1-T.testvalue)))
				b 		= r/((r+1)+M*T.testvalue/(n*(1-T.testvalue)))
				
				df1[2] 	= (a*MSS+b*MSI)^2 ///
						/(((a*MSS)^2/(n-1))+((b*MSI)^2/((r-1)*(n-1))))
				df2[2] 	= (M-r*n)
				F[2] 	= (a*MSS+b*MSI)/MSE
				
				a 		= 1/((r+1)+M*icc[2]/(n*(1-icc[2])))
				b 		= r/((r+1)+M*icc[2]/(n*(1-icc[2])))
				
				nu1[2] 	= (a*MSS+b*MSI)^2 ///
						/(((a*MSS)^2/(n-1))+((b*MSI)^2/((r-1)*(n-1))))
				nu2[2] 	= df2[2]
				F_L 	= invF(nu1[2], nu2[2], 1-(1-T.level/100)/2)
				F_U 	= invF(nu1[2], nu2[2], (1-T.level/100)/2)
				
				ll[2] 	= (MSS+r*MSI-(r+1)*F_L*MSE) ///
						/ (MSS+r*MSI+(M/n-r-1)*F_L*MSE)
				ul[2] 	= (MSS+r*MSI-(r+1)*F_U*MSE) ///
						/ (MSS+r*MSI+(M/n-r-1)*F_U*MSE)
			}
		}
		else {
				// m=1
			df1[1] 	= (n-1)
			df2[1]  = (r-1)*(n-1)
			F[1] 	= (MSS/MSE)*((1-T.testvalue)/(1+(r-1)*T.testvalue))
			
			F_L 	= (MSS/MSE)/invF(df1[1], df2[1], 1-(1-T.level/100)/2)
			F_U 	= (MSS/MSE)/invF(df1[1], df2[1], (1-T.level/100)/2)
			ll[1] 	= (F_L-1)/(F_L+(r-1))
			ul[1] 	= (F_U-1)/(F_U+(r-1))
			
			if (m > 1) {
				df1[2] 	= df1[1]
				df2[2] 	= df2[1]
				F[2] 	= F[1]
				ll[2] 	= ll[1]
				ul[2] 	= ul[1]
			}
		}
	}
	else {
		_kappaetc_internal_error("kappaetc_ado_rtable_icc")
	}
	
	crit 		= invFtail(df1, df2, 1-T.level/100)
	pvalue 		= 1:-F(df1, df2, F)
	
	kappaetc_ado_rtable_clipci(T, ll, ul)
	
	T.rtable 	= (icc\ F\ df1\ df2\ pvalue\ ll\ ul\ crit)
	T.rownames 	= ("b", "F", "df1", "df2", "pvalue", "ll", "ul", "crit")
	T.rownames 	= (J(8, 1, ""), T.rownames')	
	
	if (model == "1B") {
		T.colnames = ("", "ICC_a")
		st_numscalar("r(icc_a_F)", F)
		st_numscalar("r(icc_a_df1)", df1)
		st_numscalar("r(icc_a_df2)", df2)
	}
	else {
		if ((model != "1") & (m > 1)) {
			T.colnames = (J(2, 1, ""), ("ICC"\ "ICC_a"))
			st_numscalar("r(icc_a_F)", F[2])
			st_numscalar("r(icc_a_df1)", df1[2])
			st_numscalar("r(icc_a_df2)", df2[2])
		}
		else {
			T.colnames = ("", "ICC")
		}
		st_numscalar("r(icc_F)", F[1])
		st_numscalar("r(icc_df1)", df1[1])
		st_numscalar("r(icc_df2)", df2[1])
	}
}

`RR' kappaetc_ado_rtable_icc_set(`SS' model, `RS' m)
{
	if (model == "1B") {
		return(st_numscalar("r(icc_a)"))
	}
	else if ((model != "1") & (m > 1)) {
		return((st_numscalar("r(icc)"), st_numscalar("r(icc_a)")))
	}
	else {
		return(st_numscalar("r(icc)"))
	}
}

void kappaetc_ado_rtable_clipci(`stAdoTS' T, `RM' ll, `RM' ul)
{
	if (!T.ciclipped) {
		return
	}
	
	ll = ll:/abs(ll:*(abs(ll):>1):+(abs(ll):<=1))
	ul = ul:/abs(ul:*(abs(ul):>1):+(abs(ul):<=1))
	if (anyof(("dice", "icc"), T.cmd2)) {
		ll = ll:*(ll:>0)
		ul = ul:*(ul:>0)
	}
}

void kappaetc_ado_rtable_ciclipped()
{
	`RM' T
	
	T = st_matrix("r(table)")
	
	if (anyof(("", "cac"), st_global("r(cmd2)"))) {
		T = rowsum(T[(5\6), ] :== J(1, cols(T), (-1\1)))
	}
	else if (st_global("r(cmd2)") == "dice") {
		T = rowsum(T[(5\6), ] :== J(1, cols(T), (0\1)))
	}
	else if (st_global("r(cmd2)") == "icc") {
		T = rowsum(T[(6\7), ] :== J(1, cols(T), (0\1)))
	}
	else {
		_kappaetc_internal_error("ado_table_ciclipped")
	}
	
	if (!any(T)) {
		return
	}
	
	printf("{txt}Confidence interval" 								+ ///
	(colsum(T) > 1 ? "s are" : " is") + " clipped at the " 			+ ///
	(all(T) ? "lower and upper " : (T[1] ? "lower " : "upper ")) 	+ ///
	"limit" + (all(T) ? "s" : "") + ".\n")
}

end

/* ---------------------------------------------------------------------------
	internal error message
	----------------------------------------------------------------------- */
	
mata : 

void _kappaetc_internal_error(`SS' where, | `RS' par)
{	
	if (par) {
		where = where + "()"
	}
	
	errprintf("{col 3}unexpected error in")
	errprintf(" {bf:kappaetc_%s}\n", where)
	errprintf("Please contact the author ")
	errprintf("(klein.daniel.81@gmail.com)\n")
	exit(3498)
}

end
exit

2.0.0	28jun2018	bug fix incorrect icc() when not sorted on id()
					new syntax for se() option; jackknife no longer allowed
					CI for subject cond. se now based on t(r-1) distribution
					new syntax for circular weights; old syntax still works 
					new syntax for power weights; old syntax still works
					new option forcettest (not documented)
					new option returnmore in ttest (not documented)
					option store() allows stub* and may be used with by
					option df() no longer documented
					remove options version and transpose
					varous changes to r() results
					slightly changed output table
					rewrite parts of code
1.7.0	24feb2018	bug fix ttest did not work with frequency data
					new option specific estimates specific agreement
					new option acm() specifies gold standard (not documented)
					additional returned result r(estimable) in cac and ttest
					kappaetc , version now returns s(kappaetc_version)
					changed output omit non-estimated coefficients
					better note for clipped CI
					new utility programs
					certified but never released
1.6.0	30jan2018	bug fix error if ratings do not vary with frequency data
					bug fix benchmark scale with one number when number != 1
					bug fix user wgtid may be named using, if, or in
					bug fix option notable no longer supresses show* options
					bug fix suppress CI clipped message for benchmark table
					minimum number of required subjects reduced to 1
					new option icc() estimates intraclass correlations
					add support for aweights (only cac; not documented)
					option testvalue() must be >= 0
					new option version (not documented)
					new option transpose (not documented)
					new option returnmore (not documented)
					new option returnonly for loa()
					slightly modified output (shorter table, Scott's Pi)
					code polish; rewrite and rearrange routines
1.5.0	18dec2017	bug fix error unrated subjects (r_i = 0) in frequency data 
					bug fix add bind option to parser in command switcher
					bug fix exit with error if ratings do not vary
					bug fix option se() may not be specified with krippendorff
					bug fix option testvalue() must be between -1 and 1
					bug fix display N as %7.0g not %7.0f
					bug fix output for cformat > %7.x
					new option loa produces Bland-Altman plot
					rename option casewise listwise (keep casewise as synonym)
					new syntax for benchmark() (old syntax continues to work)
					new option nociclipped does not clip CI at -1 and 1
					slightly changed output coefficient names right-aligned
					new message below table when CI outside [-1, 1]
					invalid format no longer an error but reset to default
					code polish marksample handles invalid weights
					new command kappaetcssi (separate ado-file)
					submitted to SJ
1.4.0 	16jun2017	bug fix variance Krippendorff's alpha with missing ratings
					suboption scale() adds 1 as upper limit if not specified
					new wgt_option u(#) for circular weights
					new wgtid power(#)
					new reporting option testvalue()
					new reporting option largesample
1.3.0	20may2017	bug fix ttest did not work (correctly) with weights
					bug fix finite sample correction incorrect in 1.2.0
					modified r(b_istar) now unweighted
					new r(weight_i)
					default tolerance in ttest 1e-14 (was 1e-15)
					option ttest now optional
					option df() now accepts both row and column vector
					suboption scale() requires at least two upper limits
					never released on SSC
1.2.0	06may2017	bug fix revised variance formula for Krippendorff's alpha
					bug fix incorrect jacknife se with missing replicates
					bug fix see kappaetci 1.1.0
					bug fix ignored option df()
					bug fix wgt_options kapwgt and matrix evoked error
					option indices() no longer allowed (dubious results)
					new wgt_option force[wgt] (not documented)
					new option store()
					new r() b_istar
					new option ttest implements paired t tests
					new option categories() specifies predetermined ratings
					new options replay and restore (not documented)
					slightly changed output (removed blank line before table)
					code polish new classes and structs
1.1.0	17jan2017	bug fix incorrect Cohen/Conger's kappa for missing ratings
					bug fix incorrect jackknife se with missing ratings
					bug fix extended missing values treated as valid ratings
					bug fix incorrect ratio weights with zero (0) ratings
					CIs now truncated to [-1<=ll<=ul<=1]
					new options benchmark and showscale
					new r() table_benchmark_{prob & det} benchmarks imp p_cum
					new option frequency
					new wgt_option indices()
					implement fweights into formulas (no longer expand)
					add support for iweights
					add checks of weighting matrix
					new output label ratings per subject
					new output add number of rating categories
					new command kappaetci (separate ado-file)
1.0.0	13dec2016	release on SSC
