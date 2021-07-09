*! version 1.0.2 Sam Brilleman 13oct2011
capture program drop devr2
program define devr2, rclass
	version 11.1

	estimates store mod_estimates
	
	if `"`e(cmd)'"' == "glm" {

		local devm `e(deviance)'
		local depv `e(depvar)'
		local cmdline `e(cmdline)'

		if `e(nbml)' == 1 {
			local cmdline : subinstr local cmdline "ml)" "`e(a)')"	
		}
			
		gettoken left opts : cmdline , parse(",")

		quietly glm `depv' if e(sample) `opts'
			local dev0 `e(deviance)'

		local r2 = 1-(`devm'/`dev0')

		di as text "{hline 43}{c TT}{hline 25}"	
		di as text "                                           {c |}   Cameron & Windmeijer's "
		di as text "   Deviance(model)      Deviance(null)     {c |}      R-squared  value    "
		di as text "{hline 43}{c +}{hline 25}"
		di as text "      " %12.3f `devm' "        " %12.3f `dev0' ///
		"     {c |}                " as result %5.4f `r2'
		di as text "{hline 43}{c BT}{hline 25}"
	
		return scalar dev_model = `devm'
		return scalar dev_null = `dev0'	
		return scalar devr2 = `r2'

	}

	else {

		di as err "previous estimation command was not glm" 
		exit

	}

	quietly estimates restore mod_estimates

end
