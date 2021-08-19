// PROGRAM: Display tensensitivity results
// DESCRIPTION: Main program to display tesensitivity cpi estimation results
//              in stata console. [see help file]

// IMPLEMENTATION NOTES:
//   - handles tables in 4 major formats: treatment effect statistic intervals
//     and scalar tables of c-scale output and multiple breakdown points. 
//     They are handled by _display_interval_data, _display_cscale_table, and
//     _display_breakdown_table respectively
//   - _write_header_cpi and _write_interval_data display the two parts of the
//     the table. _interval_format determines the widths of columns and numbers
//     formatting for a given set of results.
//   - _write_header_cscale and _write_scalar_data display the two parts of the
//     cscale table.
//   - _write_header_cpi and _write_scalar_data are used by _display_breakdown_table

program _tesen_display
		
	syntax [anything], [cscale breakdown first]
	
	tempvar cmax cqtls breakdown_table
	
	di _newline(1)

	// =========================================================================	
	// 1. c-scale table	
	// =========================================================================
	if "`cscale'" != ""{	
		
		capture matrix `cmax' = r(cmax)
		local err = _rc
		if `err' != 0 {
			local cmax .
		}
		else if `cmax'[1,1] == . {
			local cmax .
		}
		
		capture matrix `cqtls' = r(cquantiles)
		local err = _rc
		if `err' != 0 {
			local cqtls .
		}
		else if `cqtls'[1,1] == . {
			local cqtls .
		}
			
		_display_cscale_table `cmax' `cqtls'
		
	}
	// =========================================================================
	// 2. breakdown point table
	// =========================================================================
	else if "`breakdown'" != "" {
	
		if "`first'" == "" {
			local first .
		}
	
		if "`anything'" != ""{
		
			local nresults : word count `anything' 
			matrix `breakdown_table' = J(1, `nresults', .)
		
			local iresult = 1
			foreach result of local anything {
				qui estimates restore `result'
				matrix `breakdown_table'[1, `iresult'] = `e(c_breakdown)'
				local stats `"`stats' `result'"'
				local iresult = `iresult' + 1
			}
			matrix colnames `breakdown_table' = `stats'
			matrix rownames `breakdown_table' = `"stat_>_`=e(y_breakdown)'"'
		}
		
		_display_breakdown_table `breakdown_table' `first'
	
	}
	// =========================================================================
	// 3. interval data table
	// =========================================================================
	else {

		tempvar c_table
	
		if "`anything'" != ""{
			gettoken result anything : anything
			qui estimates restore `result'
			matrix `c_table' = e(c_table)
			local stats `"`stats' `result'"'
			
			foreach result of local anything {
				qui estimates restore `result'
				mata: merge_matrices("`c_table'", "e(c_table)", "`c_table'", 1, 1)
				local stats `"`stats' `result'"'
			}
			local c_breakdown = .
			local y_breakdown = .
			local nobs = .
		}
		else {
			matrix `c_table' = e(c_table)
			local c_breakdown = e(c_breakdown)
			local y_breakdown = e(y_breakdown)
			local nobs = e(N)
			local stats `e(stat)'
		}
		
// 		mata: sort_st_matrix("`c_table'", 1)
		
		_display_interval_data `c_table' `c_breakdown' `y_breakdown' `nobs' `"`stats'"'

	}

end

// PROGRAM: display interval data
// DESCRIPTION: Display table of interval bounds for each statistic included
//              for set of c-dependence values
// INPUT:
//    - c_table: matrix, column 1 - c-dependence values, 
//                       additional columns - pairs of lower, upper bounds
//    - c_breakdown: scalar, breakdown point. Only used for a set estimates.
//                           "." to exclude from header.
//    - y_breakdown: scalar, conclusion threshold for breakdown point 
//                           (e.g, ate > `y_breakdown'), "." to exclude from header
//    - nobs: scalar, number of observations
//    - stats: string, list of statistic names (used in column headers)
// IMPLEMENTATION NOTES:
//    - Currently no customizable formatting options
//    - TODO: currently must have same c-dependence values for multiple estimates
program _display_interval_data

	// process input
	args c_table c_breakdown y_breakdown nobs stats
	local nestimates : word count `stats'
	
	// =========================================================================
	// 1. set display options
	// =========================================================================
	
	// global default display settings
	local left_colon = 18 // placement of colon in left column of header
	local right_col  = 48 // start of right column
	local equal_col  = 63 // placement of = in right column
	local right_bord = 80 // total width of table
	
	local labels_width 20 // width of left column with c-dependence values		
	local n_dig 3         // number of decimal points for c-dependence values

	// header information
	if `nestimates' == 1 {
		local analysis cond. partial independence
		local tmodel `e(tmodel)'
		local omodel `e(omodel)'
		local depvar `e(depvar)'
		local stat `stats'
	}
	else {
		local analysis conditional partial independence, multiple results
		local tmodel .
		local omodel .
		local depvar .
		local stat .
	}
	
	// =========================================================================
	// 2. write header
	// =========================================================================
	_write_header_cpi `nobs' `c_breakdown' `y_breakdown' `n_dig'         ///
					  `left_colon' `right_col' `equal_col' `right_bord'  ///
					  "`analysis'" "`tmodel'" "`omodel'" `depvar' `stat'
	
	// =========================================================================
	// 3.1 determine formatting specification for intervals
	// =========================================================================
	// NOTES:
	//   - table consists of a left column for c-dependence values, and
	//     one column for each estimates included. Have to determines
	//     the formatting and width of the column for each estimate.
	//   - _interval_format returns the width and formatting
	//   - formats heading for the table itself (i.e., "c | ate qte" etc.)
	//   - formats the horizontal lines forming the table  
	
	// starting values for location of first statistic
	local stat_start = 2 + `labels_width' // starting display column for interval data
	local stat_num 2 // column number of c_table where the first stat starts
	
	// interval table header up to start of statistic labels (these are the 
	// labels for the table itself, not the text above the table)
	local tbl_header `"as text  _col(`=`labels_width' - 2') "c" "' 
	
	// horizontal bars making table up to start of first statistic
	local hbar_top `"{hline `=`labels_width' - 2'}"'
	local hbar_mid `"{hline `=`labels_width' - 2'}"'
	local hbar_bot `"{hline `=`labels_width' - 2'}"'
	
	// determine widths and formatting of columns for each stat
	foreach stat in `stats'{
		matrix int_tbl = `c_table'[1...,`stat_num'..`=`stat_num' + 1'] 
		_interval_format int_tbl // interval width + fmt for current stat
		local interval_width `s(int_width)'
		local int_formats `int_formats' `s(int_format)'
		local int_widths `int_widths' `interval_width'
		
		// update starting location for next statistic
		local stat_start = `stat_start' + `interval_width' - strlen("`stat'")
		local hbar_len = 1 + `interval_width'
		
		// update header and table bars
		local tbl_header `"`tbl_header' " {c |}" _col(`stat_start') as text "`stat'""'
		local hbar_top `"`hbar_top'{hline 1}{c TT}{hline `hbar_len'}"'
		local hbar_mid `"`hbar_mid'{hline 1}{c +}{hline `hbar_len'}"'
		local hbar_bot `"`hbar_bot'{hline 1}{c BT}{hline `hbar_len'}"'
		
		// update display column and column in c_table for the next stat
		local stat_start = `stat_start' + strlen("`stat'") + 3
		local stat_num = `stat_num' + 2
	}
	
	// =========================================================================
	// 3.2 Write interval data
	// =========================================================================
	di as text "`hbar_top'"
	di `tbl_header'
	di as text "`hbar_mid'"
	_write_interval_data `"`int_formats'"' `"`int_widths'"' `labels_width' `n_dig' `c_table'
	di as text "`hbar_bot'"

end

// PROGRAM: Write header for conditional partial independence analysis
// DESCRIPTION: Writes a header above the table which includes the information
//              included in the teffects output as well as the breakdown
//              conclusion and breakdown point
// INPUT:
//    - nobs: scalar, number of observations
//    - breakdown: scalar, breakdown point (c-dependence), "." to exclude
//    - y_breakdown: scalar, breakdown conclusion, "." to exclude
//    - bd_dig: scalar, number of decimal points for breakdown point
//    - left_colon: scalar, display column for colon in left column
//    - right_col: scalar, display column for start of right column
//    - equal_col: scalar, display column for equal sign in right columns
//    - right_bord: scalar, display column for total width of table
//    - analysis: string, name of analysis
//    - tmodel: string, treatment model
//    - omodel: string, outcome model
//    - depvar: string, dependent variable
//    - stat: string, name of statistic used in analysis (only for single estimate), 
//                    "." to exclude
//    - first: string, when multiple tables are displays this controls which
//                     table includes that overall title. "first" to include
//                     title, "." to exclude (not first)
// IMPLEMENTATION NOTES:
program _write_header_cpi
	
	args nobs breakdown y_breakdown bd_dig left_colon right_col equal_col right_bord ///
	     analysis tmodel omodel depvar stat first
	
	// =========================================================================
	// 1. Calculate formatting paramters
	// =========================================================================
	local right_col_width = `right_bord' - `equal_col' - 1
	local conject_width = `right_bord' - `equal_col' - strlen("`stat'") - 3 - 1
	local y_breakdown = strofreal(`y_breakdown', "%`conject_width'.0gc")
	
	// =========================================================================
	// 2. Form header elements
	// =========================================================================
	
	// left column elements
	local lc_head `"as text "Treatment effects sensitivity""'
	local lc_analysis `"as text "Analysis" _col(`left_colon') as result ": `analysis'""'

	local lc_outcome_mod `"as text "Outcome model" _col(`left_colon') as result ": `omodel'""'
	local lc_treat_mod `"as text "Treatment model" _col(`left_colon') as result ": `tmodel'""'
	local lc_depvar `"as text "Outcome variable" _col(`left_colon') as result ": `depvar'""'
	
	
	// right column - number observations
	if "`nobs'" != ""{
		local obs_l1 `"_col(`right_col') as text "Number of obs" _col(`equal_col') "=""'
		local obs_l2 `"as result %`right_col_width'.0f `nobs'"'
		local rc_obs `"`obs_l1' `obs_l2'"'
	}
	
	// right columne - breakdown point
	if "`y_breakdown'" != "." {
		local bd_l1 `"_col(`right_col') as text "Breakdown" _col(`equal_col') "=""'
		local bd_l2 `" as result %`right_col_width'.`bd_dig'f `breakdown'"'
		local rc_bd `"`bd_l1' `bd_l2'"'
		
		local conject_l1 `"_col(`right_col') as text "Conclusion" _col(`equal_col') "=""'
	    local conject_l2 `"as result %`right_col_width's "`stat' > `y_breakdown'""'
		local rc_conject `"`conject_l1' `conject_l2'"'
	}

	// =========================================================================
	// 3. Write the header
	// =========================================================================
	if "`first'" != "." {
		di `lc_head' 
	}
	// if a statistic is specified, this is a table for a single estimates:
	// include the full header
	if "`stat'" != "." {
		di `lc_analysis' `rc_obs' _newline /*
		*/`lc_outcome_mod' `rc_bd' _newline /*
		*/`lc_treat_mod' `rc_conject' _newline /*
		*/`lc_depvar'
	}
	// if no statistic is specified, this is table combining estimates: 
	// include a shortened header (most of the information is specific to
	// a single estimate so can't include it)
	else {
		di `lc_analysis'
	}
end

// PROGRAM: Write interval data
// DESCRIPTION: Writes the intervals data given formatting information. If
//              reference c-depednence values were included, writes the name of the
//              covariates in the left column
// INPUT:
//   - fmts: string, list of formats for each estimate
//   - widths: string, list of widths for each interval_width
//   - lab_width: scalar, end display column of left column with c-values
//   - c_digits: scalar, number of decimals for c-dependence values
//   - c_table: matrix, column 1 - c-dependence values, 
//                       additional columns - pairs of lower, upper bounds
// IMPLEMENTATION NOTES:
//   - number formatting is consistent for each statistic
//   - reference c-dependence values in the c_table have the name of the
//     corresponding covariate in the rowname of the matrix. The rowname
//     of c-depedence values that are part of the grid are just called
//     grid#
program _write_interval_data
	
	args fmts widths lab_width c_digits c_table 
	tempname cval
	
	// =========================================================================
	// 1. Determine formatting parameters
	// =========================================================================
	local nrows = rowsof(`c_table')
	local ncols = (colsof(`c_table') - 1) / 2 // number of display columns (not columns in c_table)
	local rnames : rownames(`c_table') 
	local c_start = `lab_width' - `c_digits' - 3 // display column of c values
	local cov_width = `lab_width' - `c_digits' - 5 // width for ref c vals
	
	// =========================================================================
	// 2. Write table lines
	// =========================================================================
	// - outer loop - rows, inner loop - columns
	forvalues row = 1/`nrows' {
	
		// clear macro that will have row text
		local covname
		local intervals
		
		// get covariate name if reference c-dependence value 
		local rname : word `row' of `rnames'
		if !strmatch("`rname'", "grid*") {
			local covname `"as result %-`cov_width's abbrev("`rname'", `cov_width')"'
		}

		// get c-dependence value
		scalar `cval' = `c_table'[`row', 1]
		
		// inner loop: add text to row text macro for one stat at a time
		forvalues col = 1/`ncols'{
			
			local f : word `col' of `fmts' // format for interval data
			local lower_col = 2 + (2 * `=`col'-1') // c_table column for lw bd 
			local upper_col = `lower_col' + 1 // c_table column for up bd
			local lval = `c_table'[`row', `lower_col'] // lw bd value
			local uval = `c_table'[`row', `upper_col'] // up bd value
			// add stat interval text
			local intervals `"`intervals' as text " [" as result `f' `lval' as text ", " as result `f' `uval' as text "]" "' 
			// if last column add vertical line
			if `col' < `ncols'{
				local intervals `"`intervals' " {c |}""'
			}
		
		}
	
		// write the row
		di `covname' _col(`c_start') as text %`=1 + `c_digits''.`c_digits'f `cval' " {c |}" `intervals'

	}
	
end

// PROGRAM: Interval formatting
// DESCRIPTION: determines the width of each interval in the table and
//              formatting of the numbers
// INPUT: c_table: The table of intervals, column 1 - c values, columns 2,3
//                 lower and upper bounds
// RETURN: 
//   - s(int_format), formatting string for data in this estimate
//   - s(total width), total column width for this estimate
// NOTES:
//   - This can only handle one estimate at a time
//   - These are hard coded for now. For values between -10, 10,
//     shown with 4 decimals, for [10, 1000), 2 decimals, [1,000, 1,000,000)
//     no decimals and full numbers, for > 1,000,000 shown in scientific format
program _interval_format, sclass

	args c_table

	// get the number of integer digits
	mata: m1 = st_matrix("`c_table'")[,1]
	mata: m1 = abs(m1)
	mata: m2 = st_matrix("`c_table'")[,2]
	mata: m2 = abs(m2)
	mata: st_numscalar("minval", min((m1, m2)))
	mata: m = max((floor(colmax(m1)), floor(colmax(m2))))
	mata: nchar = floor(log10(m)) + 1
	mata: st_local("nchar", strofreal(nchar))
	mata: mata drop nchar m1 m2 m
	if `nchar' == . local nchar 0

	// Cases for different numbers of digits
	if `nchar' <= 1 & minval < 10 & minval >= .0001{
		local ndig = 4
		local num_len = 1 + `ndig' + 2
		local int_format "%`num_len'.`ndig'f"
		local int_width = (`num_len' * 2) + 4  
	}
	else if `nchar' <= 1 & minval < .0001{ 
		local ndig = 3
		local num_len = `ndig' + 6
		local int_format "%`num_len'.`ndig'e"
		local int_width = (`num_len' * 2) + 4 
	}
	else if `nchar' >= 2 & `nchar' <= 3{
		local ndig = 2
		local num_len = `nchar' + `ndig' + 2
		local int_format "%`num_len'.`ndig'fc"
		local int_width = (`num_len' * 2) + 4  
	}
	else if `nchar' >= 4 & `nchar' <= 6 {
		local num_len = `nchar' + 2
		local int_format "%`num_len'.0fc"
		local int_width = (`num_len' * 2) + 4  
	}
	else if `nchar' >= 7 & `nchar' <= 9  {
		local num_len = `nchar' + 3
		local int_format "%`num_len'.0fc"
		local int_width = (`num_len' * 2) + 4  
	}
	else if `nchar' >= 10{
		local ndig = 3
		local num_len = `ndig' + 6
		local int_format "%`num_len'.`ndig'e"
		local int_width = (`num_len' * 2) + 4  
	}
	
	sreturn local int_format `int_format'
	sreturn local int_width `int_width'
	
end

// PROGRAM: Display c-dependence scale table
// DESCRIPTION: Write table for output of tesensitivity cscale 
// INPUT:
//   - cmax, include the supremum of the distribution, "." to exclude
//   - quantiles, list of quantiles of the distribution
program _display_cscale_table

	args cmax quantiles

	// =========================================================================
	// 1. formatting paramteres
	// =========================================================================
	
	// global default display settings
	local left_colon = 18 // placement of colon in left column of header
	local right_col  = 55 // start of right column
	local equal_col  = 70 // placement of = in right column
	local right_bord = 80 // total width of table
	
	local lbl_width 14
	local ndig  = 3
	local colspace = 3	
	local max_width = `colspace' + 2 + `ndig'
	
	// start bars and column header
	local colnames `"as text %`lbl_width's "quantile""'
	local hbar_top `"{hline `lbl_width'}"'
	local hbar_mid `"{hline `lbl_width'}"'
	local hbar_bot `"{hline `lbl_width'}"'
	
	// =========================================================================
	// 2. determine formatting specification for each column 
	// =========================================================================
	if "`quantiles'" != "."{
	
		// load specificaiton of quantiles table
		local ncols = colsof(`quantiles') + 1
		local varnames : rownames(`quantiles')
		local qts : colnames(`quantiles')
		local colnames `"`colnames' as text " {c |}""'
		
		// form header of quantiles columns
		foreach qt of numlist `qts' {
			local colnames `"`colnames' as text %`=`ndig'+`colspace' + 2'.`ndig'f `qt'"'
		}
		local ncol : word count `qts'
		local hbar_len = ((`ndig' + `colspace' + 2) * `ncol')
		
		local stcol = 2 + `lbl_width' + `colspace' + (`ncol' * (2 + `ndig' + `colspace'))
		local hbar_top `"`hbar_top'{hline 1}{c TT}{hline `hbar_len'}"'
		local hbar_mid `"`hbar_mid'{hline 1}{c +}{hline `hbar_len'}"'
		local hbar_bot `"`hbar_bot'{hline 1}{c BT}{hline `hbar_len'}"'
		
	}
	
	if "`cmax'" != "." {
		local colname `"as text %`max_width's "max""'
		local colnames `"`colnames' " {c |}" `colname'"' 
		local hbar_top `"`hbar_top'{hline 1}{c TT}{hline `max_width'}"'
		local hbar_mid `"`hbar_mid'{hline 1}{c +}{hline `max_width'}"'
		local hbar_bot `"`hbar_bot'{hline 1}{c BT}{hline `max_width'}"'
	}
	
	_write_header_cscale `e(N)' `left_colon' `right_col' `equal_col' `right_bord' 
	di as text "`hbar_top'"
	di `colnames'
	di as text "`hbar_mid'"
	_write_scalar_data `lbl_width' `ndig' `colspace' `cmax' `quantiles'
	di as text "`hbar_bot'"
		
end

// PROGRAM: Write cscale header
// DESCRIPTION: Write header for output of tesensitivity cscale
// INPUT: 
//   - nobs, scalar: number of observations

program _write_header_cscale

	args nobs left_colon right_col equal_col right_bord 

	// input information
	local analysis leave one out prop. score diff.
	local tmodel logistic

	// alignment
	local right_col_width = `right_bord' - `equal_col' - 1
	
	di as text "Treatment-effects sensitivity analysis" 
	di as text "Analysis" _col(`left_colon') as result ": `analysis'" /*
	*/ _col(`right_col') as text "Number of obs" _col(`equal_col') "="/*
	*/ as result %`right_col_width'.0g `nobs'
	di as text "Treatment model" _col(`left_colon') as result ": `tmodel'" 
	
end

// PROGRAM: Write scalar data
// DESCRIPTION: write table of scalar data
// INPUT:
//   - st_width, scalar: width of left side labels
//   - ndig, scalar: number of decimals in numbers
//   - colspace, scalar: width between columns
//   - maxvals, matrix: right column 
//   - vals, matrix: middle columns 

program _write_scalar_data

	args st_width ndig colspace maxvals vals
	tempname val maxval
	
	// formatting specification 
	local max_width = `colspace' + 2 + `ndig'
	
	// load specification of table
	if "`vals'" != "."{
		local ncols = colsof(`vals')
		local nrows = rowsof(`vals')
		local lbls : rownames(`vals')
	}
	else if "`maxvals'" != "." {
		local ncols = 0
		local nrows = rowsof(`maxvals')
		local lbls : rownames(`maxvals')
	}
	else {
		di as err "tesensitivity display scalar table" ///
        "no data found"
        exit 301
	}
	
	// write table row by row 
	forvalues row = 1/`nrows' {
		
		// clear row input
		local valinput `"as text " {c |}""'
		
		// form inner table
		if "`vals'" != "." {
			forvalues col = 1/`ncols' {
				local val_`col' = `vals'[`row', `col']
				local col_loc = 2 + `st_width' + `colspace' + ((2 + `colspace' + `ndig') * (`col' - 1))
				local valinput `"`valinput' as result %`=2 + `ndig' + `colspace''.`ndig'f `val_`col'' "'
			}
			if "`maxvals'" != "."{ 
				local valinput `"`valinput' as text " {c |}""'
			}
		}
		// form right side table
		if "`maxvals'" != "."{
			scalar `maxval' = `maxvals'[`row', 1]
			local valinput `"`valinput' as result %`max_width'.`ndig'f `maxval' "'
			}
	
		// add line, including label
		local lbl1 : word `row' of `lbls'
		local lbl1 = subinstr("`lbl1'", "_", " ",.)
		di as text %`st_width's abbrev("`lbl1'", `st_width') `valinput'
	}

end

// PROGRAM: Display breakdown table
// DESCRIPTION: ...
program _display_breakdown_table

	args breakdown_tbl first

	// global display settings
	local labels_width 17	
	local ndig  = 3
	local colspace = 7
	local left_colon = 17
	local colwidth = 2 + `colspace' + `ndig'
	
	// header
	_write_header_cpi . . . . `left_colon' . . . `"breakdown point, multiple"' . . . . `first'         

	// start bars and column header
	local colnames `"as text %`labels_width's "conclusion""'
	local hbar_top `"{hline `labels_width'}"'
	local hbar_mid `"{hline `labels_width'}"'
	local hbar_bot `"{hline `labels_width'}"'
	
	// load specificaiton of breakdown table
	local ncols = colsof(`breakdown_tbl')
	local varnames : rownames(`breakdown_tbl')
	local qts : colnames(`breakdown_tbl')
	local colnames `"`colnames' as text " {c |}""'
	
	// form header of breakdown table 
	local col 0
	foreach qt in `qts' {
		local q`col' `qt'
		local colname `"as text %`colwidth's abbrev("`q`col''", `=`colwidth' - 1')"'
		local colnames `"`colnames' `colname'"'
		local col = `col' + 1
	}
	local hbar_len = `colwidth' * `ncols'
	local hbar_top `"`hbar_top'{hline 1}{c TT}{hline `hbar_len'}"'
	local hbar_mid `"`hbar_mid'{hline 1}{c +}{hline `hbar_len'}"'
	local hbar_bot `"`hbar_bot'{hline 1}{c BT}{hline `hbar_len'}"'
	
	di as text "`hbar_top'"
	di `colnames'
	di as text "`hbar_mid'"
	_write_scalar_data `labels_width' `ndig' `colspace' . `breakdown_tbl'
	di as text "`hbar_bot'"

end

program merge_matrix_rownames
	args mat1 mat2
	
end

mata:
  	// mata drop merge_matrices()
	// Adapted from https://theesspreckelsen.wordpress.com/2014/07/21/
	//             merge-for-mata-combining-two-matrices-using-a-column-of-id-values-stata-merge-for-mata/
	// FUNCTION: Merge Matrices
	
	function merge_matrices(string scalar matm, 
					        string scalar matu,
							string scalar matto,
							scalar posIDm, 
							scalar posIDu) 
	{
		m = st_matrix(matm) 
		u = st_matrix(matu) 
		m_name = st_matrixrowstripe(matm)
		u_name = st_matrixrowstripe(matu)
		
		idvalues = uniqrows(m[1..rows(m),posIDm]\u[1..rows(u),posIDu])
		
		fm = J(rows(idvalues),cols(m),.)
		fm_name = J(rows(idvalues), 2, "")
		for(i=1; i<=rows(idvalues); i++){
			for(j=1; j<=rows(m); j++){
				if (idvalues[i,1] == m[j,posIDm]) {
					fm[i,1..cols(m)] = m[j,]
					fm_name[i,] = m_name[j,]
					break
				}
			}
		}
		
		fu = J(rows(idvalues),cols(u),.)  //matrix collecting expanded mat.
		fu_name = J(rows(idvalues), 2, "")
		for(i=1; i<=rows(idvalues); i++){
			for(j=1; j<=rows(u); j++){
				if (idvalues[i,1] == u[j,posIDm]) {
					fu[i,1..cols(u)] = u[j,]
					fu_name[i,] = u_name[j,]
					break
				}
			}
		}
		// check and merge the column names
		
		fn = J(rows(idvalues), 2, "")
		for(i=1; i<=rows(fm_name); i++){
			s1 = fu_name[i,]
			s1ref = fu_name[i,1] == "cref"
			s2 = fm_name[i,]
			s2ref = fm_name[i,1] == "cref"
			
			if ((s1ref & !s2ref) | (s1ref & s2ref & (s1 == s2))) {
				fn[i,] = s1
			}
			else if (s2ref & !s1ref) {
				fn[i,] = s2
			}
			else {
				fn[i,] = ("grid", "grid`i'")
			}
		}
		
		f = idvalues,fm[,2..cols(fm)],fu[,2..cols(fm)] 
		
		st_matrix(matto,f)
		st_matrixrowstripe(matto, fn)
		
	} 
end

