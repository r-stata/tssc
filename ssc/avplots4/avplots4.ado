*! version 1.0.0 22apr2005 Ben Jann
*! based on avplots.ado version 2.3.7 18feb2004 by StataCorp
program define avplots4
	version 6.0
	if _caller() < 8 {
		avplots4_7 `0'
		exit
	}
	local vv : display "version " string(_caller()) ":"

	_isfit cons
	syntax [varlist(default=none)] [, altshrink * ]

	_get_gropts , graphopts(`options') getcombine getallowed(plot)
	local options `"`s(graphopts)'"'
	local gcopts `"`s(combineopts)'"'
	if `"`s(plot)'"' != "" {
		di in red "option plot() not allowed"
		exit 198
	}

	if "`varlist'"=="" {
		_getrhs varlist
	}
	tokenize `varlist'

	while "`1'"!="" {
		tempname tname
		local base `names'
		local names `names' `tname'
		capture n `vv' avplot `1', name(`tname') nodraw `options'
		if _rc {
			if _rc!=399 {
				exit _rc
			}
			local names `base'
		}
		mac shift
	}

	version 8: graph combine `names' , `gcopts' `altshrink'
	version 8: graph drop `names'
end
