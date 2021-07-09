program f_able, eclass
	syntax, NLvar(varlist)
	_ms_dydx_parse `nlvar'
	if "`e(predict_old)'"=="" {
		ereturn local predict_old  `e(predict)'
		ereturn local predict  		f_able_p
	}
	foreach i of varlist `nlvar' {
		local fnc:variable label `i'
		if "`fnc'"=="" display in red "Variable `i' contains no information" _n "either label the variable or use " as text "fgen or frep" in red " to generate the variable"
		else if "`fnc'"!="See notes" ereturn hidden local _`i' `fnc'
		else {
		    local fnc: char `i'[note1]
			ereturn hidden local _`i' `fnc'
		}
	}
	ereturn local nldepvar `nlvar'
end