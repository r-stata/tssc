*! added-variable plots of all -xtreg- covariates in one image
*! version 1.0.0  13apr2019 by John Luke Gallup (jlgallup@pdx.edu)
program define xtavplots
	version 11
	syntax [, * ]

	_get_gropts , graphopts(`options') getcombine getallowed(plot addplot)
	local options `"`s(graphopts)'"'
	local gcopts `"`s(combineopts)'"'
	if `"`s(plot)'"' != "" {
		di in red "option plot() not allowed"
		exit 198
	}
	if `"`s(addplot)'"' != "" {
		di in red "option addplot() not allowed"
		exit 198
	}		

	_getrhs rhs
	tokenize `rhs'

	foreach v of local rhs  { 
		tempname tname
		local base `names'
		local names `names' `tname'
		capture xtavplot `v', name(`tname') nodraw `options'
		if _rc { 
			if _rc!=399 {
				exit _rc
			} 
			local names `base'
		}
	}

	graph combine `names' , `gcopts'
	graph drop `names'
end
