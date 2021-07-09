*! version 1.0.1, Ben Jann, 29may2007
*! also see: "Stata tip 44: Get a handle on your sample", The Stata Journal 7(2)

program define marktouse, rclass
	version 8
	gettoken markvar 0 : 0
	if `"`markvar'"'=="" {
		di as error "markvar required"
		exit 100
	}
	confirm new var `markvar'
	syntax [varlist(default=none ts)] [if] [in] [aw fw iw pw] /*
	 */ [, ZEROweight Label(str) ]
	marksample touse, strok `zeroweight'
	rename `touse' `markvar'
	label variable `markvar' `"`label'"'
	qui count if `markvar'
	di "{txt}({res}" r(N) "{txt} observations marked)"
	ret local markvar "`markvar'"
	ret scalar N = r(N)
end
