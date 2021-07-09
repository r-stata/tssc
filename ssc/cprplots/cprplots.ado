*! version 1.0.0 24apr2005 Ben Jann
program define cprplots
	version 8.2

	_isfit cons anovaok
	syntax [varlist(default=none)] [, altshrink * ]

	_get_gropts , graphopts(`options') getcombine getallowed(plot)
	local options `"`s(graphopts)'"'
	local gcopts `"`s(combineopts)'"'
	if `"`s(plot)'"' != "" {
		di in red "option plot() not allowed"
		exit 198
	}

	if "`varlist'"=="" {
		if "`e(cmd)'" == "anova" {
			anova_terms
			local varlist `r(continuous)'
		}
		else _getrhs varlist
	}

	foreach var of local varlist {
		tempname tname
		cprplot `var', name(`tname') nodraw `options'
		capt graph describe `tname'
		if _rc di as txt "`var': graph dropped"
		else local names `names' `tname'
	}

	if "`names'"!="" {
		graph combine `names' , `gcopts' `altshrink'
		graph drop `names'
	}
end
