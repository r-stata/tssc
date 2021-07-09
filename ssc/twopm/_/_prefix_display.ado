*! version 1.3.2.1 10apr2014 - This version is -twopm- compatible
*! version 1.3.2  22sep2010
program _prefix_display, sclass
	version 9
	if !c(noisily) {
		exit
	}
	is_svysum `e(cmd)'
	local is_sum = r(is_svysum)

	// only allow 'eform' options if NOT svy summary commands
	local eform 0
	if ! `is_sum' {
		local regopts NEQ(integer -1) First PLus SHOWEQns
		local eform 1
	}
	else	local neq -1
	local has_rules = inlist("`e(cmd)'", "logistic", "logit", "probit")
	if `has_rules' {
		local altopt "noRULES"
	}
	local is_logistic = "`e(cmd)'" == "logistic"
	if `is_logistic' {
		local altopt "`altopt' COEF OR"
		local eform 0
	}
	local is_st = substr("`e(cmd2)'",1,2) == "st"
	if `is_st' {
		if "`e(frm2)'" == "hazard" | "`e(cmd2)'" == "stcox" {
			local altopt "NOHR"
		}
		else	local altopt "TR"
		local eform 0
	}
	syntax [,				///
		Level(cilevel)			///
		noHeader			///
		noLegend			///
		Verbose				///
		TItle(passthru)			///
		notable				/// not documented
		`regopts'			/// _coef_table options
		SVY				/// ignored
		noFOOTnote			///
		`altopt'			///
		*				///
	]

	if `eform' {
		_get_diopts diopts options, `options'
	}
	else {
		_get_diopts ignore
		_get_diopts diopts, `options'
		local diopts : list diopts - ignore
		local options
	}

	if `is_sum' & "`e(novariance)'" != "" {
		exit
	}

	if "`first'" != "" & `"`showeqns'"' == "" {
		local neq 1
	}
	if `neq' > 0 {
		local neqopt neq(`neq')
	}
	else	local neq

	// verify only valid -eform- option specified
	if `is_st' {
		local cmdname = e(cmd2)
	}
	else	local cmdname = e(cmd)
	_check_eformopt `cmdname', eformopts(`options') soptions

	// check for total number of equations
	local k_eq 0
	Chk4PosInt k_eq
	if `k_eq' == 0 {
		local k_eq : coleq e(b), quote
		local k_eq : list clean k_eq
		local k_eq : word count `k_eq'
	}
	// check for auxiliary parameters
	local k_aux 0
	Chk4PosInt k_aux
	// check for extra equations
	local k_extra 0
	Chk4PosInt k_extra

	local blank
	if "`header'" == "" {
		_coef_table_header, `title' `rules'
		if "`legend'" == "" {
			if "`e(vce)'" != "" ///
			& ("`e(cmd)'" != "`e(cmdname)'" | "`verbose'" != "") {
				_prefix_legend `e(vce)', `verbose'
				if "`e(vce)'" == "jackknife" ///
				 & "`e(jkrweight)'" == "" ///
				 & "`e(wtype)'" != "iweight" ///
				 & ("`e(k_extra)'`verbose'" != "0" ///
				 |  "`e(k_eexp)'" == "0") {
					_jk_nlegend `s(col1)' ///
						`"`e(nfunction)'"'
					local blank blank
				}
			}
			if `is_sum' {
				_svy_summarize_legend `blank'
				local blank `s(blank)'
			}
		}
		sreturn local blank `blank'
	}

	// check to exit early
	if ("`table'" != "") exit

	if "`header'`blank'" == "" {
		di
	}

	// display the table of coefficients
	if inlist("`e(vce)'","jackknife","brr") {
		local nodiparm nodiparm
	}
	if `is_sum' {
		_sum_table, level(`level') `diopts'
		local lsizeopt linesize(`s(width)')
	}
	else {
		if `is_logistic' & "`coef'" == "" {
			local options or
		}
		if `is_st' {
			if `"`e(frm2)'`e(noeform)'`nohr'"' == "hazard" | ///
			   `"`e(cmd2)'`nohr'"' == "stcox" {
				local options hr
			}
			else if `"`tr'`e(noeform)'"' == "tr" {
				local options tr
			}
		}
		// This allows a correct display for the -twopm- command in the -svy- case
		if "`e(cmd)'" != "twopm"  _coef_table, level(`level') `neqopt' `first' `plus' ///
			`nodiparm' `showeqns' `diopts' `options'
		else _svy_twopm_display,  level(`level') `diopts' `options'
	}
	if "`plus'`footnote'" == "" {
		_prefix_footnote, `tr' `lsizeopt'
	}
end

program Chk4PosInt
	args ename
	if `"`e(`ename')'"' != "" {
		capture confirm integer number `e(`ename')'
		if !c(rc) {
			if `e(`ename')' > 0 {
				c_local `ename' `e(`ename')'
			}
		}
		capture 
	}
end

exit
