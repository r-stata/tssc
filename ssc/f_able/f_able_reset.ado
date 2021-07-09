program f_able_reset, eclass
	if "`e(predict_old)'"!="" {
		ereturn local predict `e(predict_old  )'
		ereturn local predict_old  
	}
	
	foreach i of varlist `e(nldepvar)' {
		ereturn hidden local _`i' 
	}
	ereturn local nldepvar 
end