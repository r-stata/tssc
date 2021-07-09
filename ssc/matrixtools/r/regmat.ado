*! Part of package matrixtools v. 0.24
*! Support: Niels Henrik Bruun, nhbr@ph.au.dk
*! 2018-12-16 > Changed to manual eform
*! 2018-12-03 > Handling mixed regression
*! 2018-12-03 > Fixed: keep b implies selecting se(b) BUG!
* 2018-06-05 > Created
* TODO: Enter adjustments variables at a level, force certain adjustment variables
* TODO: Option summary (sumat) of outcome by values of exposure
program define regmat, rclass
	version 12.1

	if `c(version)' >= 13 set prefix regmat

	sreturn clear
	_prefix_clear

	capture _on_colon_parse `0'
	
	local 0 `s(before)'
	syntax [using], /*
		*/Outcomes(varlist min=1) /*
		*/Exposures(varlist min=1 fv) /*
		*/[ /*
		*/Adjustments(string asis) /*
		*/noQuietly /*
		*/Labels /*
		*/BAse /*
		*/Keep(string) /*
		*/DRop(string) /*
		*/EForm /*
		matprint options
		*/Style(passthru)/*
		*/Decimals(passthru)/*
		*/TItle(passthru)/*
		*/TOp(passthru)/*
		*/Undertop(passthru)/*
		*/Bottom(passthru)/*
		*/Replace(passthru)/*
		*/]

	if `"`adjustments'"' == "" local adjustments  `""""'
		
	if "`quietly'" != "" {
		mata _showcode = 1
		mata _addquietly = 0
	}
	else {
		mata _showcode = 0
		mata _addquietly = 1	
	}
	
	mata _keep = 1
	if "`drop'" != "" {
		local _str_colnames "`drop'"
		mata _keep = 0
	}
	if "`keep'" != "" {
		local _str_colnames "`keep'"
		mata _keep = 1
	}
	local _str_colnames = strlower(`"`_str_colnames'"')
	local _str_colnames : list uniq _str_colnames
	local values b se ci p
	if ! `:list _str_colnames in values' {
		local _str_colnames = ""
		mata _keep = 1
	}
	mata: _str_slct = invtokens(tokens(st_local("_str_colnames")), "|")
	mata: _str_slct = regexm(_str_slct, "^b") ? "^" + _str_slct : _str_slct // keep b implies selecting se(b) BUG!
	mata: _str_slct = subinstr(_str_slct, "|b", "|^b")						// keep b implies selecting se(b) BUG!
	mata: _str_slct = subinstr(_str_slct, "ci", "CI")
	mata: _str_slct = subinstr(_str_slct, "p", "P")
	
	_prefix_command regmat: `s(after)'
	local _cmd `s(cmdname)'
	*local _postcmd = subinstr(`"`s(command)'"', `"`_cmd'"', "", 1)	// 2018-12-03
	local _postcmd `"`s(anything0)'"'	// 2018-12-03
	if "`s(options)'" != "" local _options ", `s(options)'" // 2018-12-07
	*local eform = ("`s(efopt)'" != "") // 2018-12-16
	local eform = ("`eform'" != "") // 2018-12-16

	mata _regressions = J(0,length(tokens(`"`adjustments'"')),"")
	foreach outcome in `outcomes' {
		foreach exposure in `exposures' {
			mata _row = J(1,0,"")
			foreach adj in `adjustments' {
				mata _row = _row, `"`_cmd' `outcome' `exposure' `adj' `_postcmd' `_options'"'
			}
			mata _regressions = _regressions \ _row
		}
	}
	mata regmattbl = run_regressions(_regressions, "`base'" == "", `eform', ///
		_showcode, _addquietly)
	mata: st_rclear()
	mata: st_eclear()
	local adjnbr = 1
	foreach adj in `adjustments' {
		if "`adj'" == "" return local Adjustment_`adjnbr' = "Crude"
		else return local Adjustment_`adjnbr++' = "`adj'"
	}
	mata: regmattbl = tolabels(regmattbl, "`labels'" != "")
	mata: regmattbl = regmattbl.regex_select(_str_slct, _keep, 1, 0)
	mata: regmattbl.to_matrix("r(regmat)")

	*** matprint ***************************************************************
	matprint r(regmat) `using',	`style' `decimals' `title' `top' `undertop' `bottom' `replace'
	****************************************************************************
	
	return add
	mata mata drop _*
end

mata 
	class nhb_mt_labelmatrix scalar run_regressions(
		string matrix regs,
		| real scalar nobase,
		real scalar eform,
		real scalar _showcode, 
		real scalar _addquietly)
	{
		real scalar r, c, R, C, rc
		string scalar exposure
		colvector eq, nm
		class nhb_mt_labelmatrix scalar tmp, column, out
	
		R = rows(regs)
		C = cols(regs)
		for(c=1;c<=C;c++) {
			column.clear()
			for(r=1;r<=R;r++) {
				if ( regexm(tokens(regs[r,c])[3], "^(.+)\.(.+)$") ) {
					exposure = regexs(2)
				} else {
					exposure = tokens(regs[r,c])[3]
				}
				rc = nhb_sae_logstatacode(regs[r,c], _showcode, _addquietly)
				tmp = nhb_mc_post_ci_table(eform, st_numscalar("c(level)"))
				if ( nobase ) tmp = tmp.regex_select(exposure).regex_select("b\.",0)	//drop base
				tmp = tmp.regex_select(exposure).regex_select("o\.",0)	//drop omitted
				if ( column.empty() ) column = tmp
				else column.append(tmp)
			}
			column.column_equations(sprintf("Adjustment %f", c))
			if ( c == 1 ) out = column
			else {
				eq = out.column_equations()
				nm = out.column_names()
				out.values( (out.values(), column.values()) )
				out.column_equations( (eq \ column.column_equations()) )
				out.column_names( (nm \ column.column_names()) )
			}
		}
		return(out)
	}
 
 class nhb_mt_labelmatrix tolabels(	class nhb_mt_labelmatrix mat_tbl,
									|real scalar uselbl,
									real scalar userows)
	{
		real scalar c, C
		string scalar varnametxt, varvaluetxt
		string colvector eq, nms

		if ( userows) {
			eq = mat_tbl.row_equations()
			nms = mat_tbl.row_names()
		} else {
			eq = mat_tbl.column_equations()
			nms = mat_tbl.column_names()
		}
		C = rows(eq)
		if ( uselbl ) for(c=1;c<=C;c++) eq[c] = st_varlabel(eq[c])
		for(c=1;c<=C;c++) {
			if ( regexm(nms[c], "([0-9]+)b?\.(.+)$") ) {
				if ( uselbl ) {
					varnametxt = st_varlabel(regexs(2))
					if ( st_varvaluelabel(regexs(2)) != "" ) {
						varvaluetxt = nhb_sae_labelsof(regexs(2), 
														strtoreal(regexs(1)))
					} else {
						varvaluetxt = regexs(1)
					}
				} else {
					varnametxt = regexs(2)
					varvaluetxt = regexs(1)
				}
				nms[c] = sprintf("%s (%s)", varnametxt, varvaluetxt)
			} else {
				if ( uselbl ) nms[c] = st_varlabel(nms[c])
			}
		}
		mat_tbl.row_equations(eq)
		mat_tbl.row_names(nms)
		return(mat_tbl)
	}
end
