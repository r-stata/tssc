*! version 2.0.1  23May2012
program define bfit, rclass sortpreserve
	version 12.1

	syntax [ namelist ] [if] [in] 			///
		, [ 					///
		corder(numlist integer >=1 <=7)		///
		sort(string) 				///
		Verbose					///
		*					///
		]   	

	gettoken subcmd varlist:namelist

	if `"`subcmd'"' == "" {
		if "`if'" != "" {
			display "{err:if restriction invalid}"
			display "You may not specify an if "	///
				"restriction without a subcommand."
			exit 498
		}


		if "`in'" != "" {
			display "{err:in restriction invalid}"
			display "You may not specify an if "	///
				"restriction without a subcommand."
			exit 498
		}

		if "`corder'" != "" {
			display "{err}{cmd:corder(`corder')} invalid"
			display "You may not specify option "		///
				"{cmd:corder()} without a subcommand."
			exit 498
		}

		if `"`options'"' != "" {
			display "{err}{cmd:`options'} invalid"
			display "You may not specify estimation "	///
				"options without a subcommand."
			exit 498
		}

		// _BFIT_SortParse() parses local macro sort, fills in 
		// 	local macro scol with col #, and fills in local
		//	local macro sort with sort statistic
		mata: _BFIT_SortParse("sort", "scol")	

		tempname S 
		matrix `S' = r(S)
		if (colsof(`S') != 6)  {
			display "{err}No {cmd:bfit} results found"
			exit 498
		}

	}
	else {
		if "`varlist'" == "" {
			display "{err}varlist not specified"
			display "You must specify a {it:varlist} " ///
				"when a subcommand is specified."
			exit 198
		}
		confirm numeric variable `varlist'

		if "`corder'" == "" {
			local corder 2
		}
		
		if "`verbose'" == "" {
			local quietly quietly
		}

		// _BFIT_SortParse() parses sort, fills in 
		// 	local macro scol with col #, and fills in local
		//	local macro sort with sort statistic
		mata: _BFIT_SortParse("sort", "scol")	

		marksample touse

		qui count if `touse'
		if (!r(N)) error(2000)

		gettoken depvar indeps:varlist 	

		// check for clean depvar
		_fv_check_depvar `depvar'

		tempvar cats
		quietly generate long `cats' = .
		foreach v of local indeps {
			sort `touse' `v'
			quietly replace `cats' = (`v' != `v'[_n-1] & `touse')
			quietly replace `cats' = sum(`cats')
			if (`cats'[_N]>10) {
				local cvlist `cvlist' `v'
			}
			else {
				local dvlist `dvlist' `v'
			}
		}

		if `"`subcmd'"' == "regress" {
			local scmd "regress"
		} 
		else if `"`subcmd'"' == "logit" {
			local scmd "mlogit"
		}
		else if `"`subcmd'"' == "poisson" {
			local scmd "poisson"
		}
		else {
			display "{err}subcommand {cmd:`cmd'} invalid"
			display "{err}{cmd:bfit} only supports {cmd:regress} " ///
				"and {cmd:logit}"
			exit 198
		}

		local bcvlist c.(`cvlist')
		forvalues i=2/`corder' {
			local bcvlist `bcvlist'##c.(`cvlist')
		}

		quietly fvexpand `bcvlist' if `touse'
		local cterms `r(varlist)'
	//!! deal with possible error from fvexpand

		tempname asarray
		mata: __BFIT_aa = asarray_create()
		local i = 1
		foreach cterm of local cterms {
			local ctlist `ctlist' `cterm'

			mata: asarray(__BFIT_aa, "_bfit_`i'", "`ctlist'")
			`quietly' `scmd' `depvar' `ctlist'	///
				if `touse' , `options'
			estimates store _bfit_`i'
			local mlist `mlist' _bfit_`i'
			local ++i

			// Add intercepts for each factor
			local dvwlist 
			foreach dvar of local dvlist {
				local dvwlist `dvwlist' `dvar'

				mata: asarray(__BFIT_aa, "_bfit_`i'",	///
					"i.(`dvwlist') `ctlist'") 
				`quietly' `scmd' `depvar' i.(`dvwlist')	///
					`ctlist' if `touse' , `options'
				estimates store _bfit_`i'
				local mlist `mlist' _bfit_`i'
				local ++i
			}

			// Add full interactions for each factor
			local dvwlist 
			foreach dvar of local dvlist {
				local dvwlist `dvwlist' `dvar'

				mata: asarray(__BFIT_aa, "_bfit_`i'",	///
					"i.(`dvwlist')##c.(`ctlist')") 
				`quietly' `scmd' `depvar'		///
					i.(`dvwlist')##c.(`ctlist')	/// 
					if `touse' , `options'
				estimates store _bfit_`i'
				local mlist `mlist' _bfit_`i'
				local ++i
			}
		}

		quietly estimates stats `mlist'

		tempname S 
		matrix `S' = r(S)
	}

	mata: _BFIT_SortResults("`S'", `scol')

	_BFIT_Display `S' `subcmd' `sort'
	local names : rownames `S'
	gettoken bfit : names

	estimates restore `bfit'

	mata: st_local("bvlist_aa", asarray(__BFIT_aa, "`bfit'"))
	return matrix S = `S'
	return local subcmd  `"`subcmd'"'
	return local  bmodel `"`bfit'"'
	return local  bvlist `"`bvlist_aa'"'
	return local  sortby "`sort'"
	
end

program define _BFIT_Display
	args S subcmd sort

	di _n as txt "bfit `subcmd' results sorted by `sort'"
	di as txt "{hline 13}{c TT}{hline 63}"
        di as txt "       Model {c |}    Obs    ll(null)   ll(model) " ///
                  "    df          AIC         BIC"
        di as txt "{hline 13}{c +}{hline 63}"

	local names : rownames `S'
        local is 0
        foreach name of local names {
                local ++is
                if "`name'" != "." {
                        local abname = abbrev("`name'",12)
                        local click "{stata estimates replay `name':`abname'}"
                }
                else {
                        local click .
                }
                di as txt "{ralign 12:`click'}"         ///
                          _col(14) "{c |}"              ///
                   as res _col(17)  %5.0f  `S'[`is',1]  ///
                          _col(25)  %9.0g  `S'[`is',2]  ///
                          _col(37)  %9.0g  `S'[`is',3]  ///
                          _col(48)  %5.0f  `S'[`is',4]  ///
                          _col(57)  %9.0g  `S'[`is',5]  ///
                          _col(69)  %9.0g  `S'[`is',6]
        }
	di as txt "{hline 13}{c BT}{hline 63}"
        if "`n'" == "e(N)" {
                local n Obs
                local see "; see {helpb bic_note:[R] BIC note}"
        }
        di as txt "{p 15 22 2}"
        di as txt `"Note:  N=`n' used in calculating BIC`see'"'
        di as txt "{p_end}"
	

end

mata:


void _BFIT_SortParse(string scalar sort_n, string scalar scol) {

	sort = st_local(sort_n)
	if (sort == "") {
		sort = "bic"
	}
	else {
		sn = cols(tokens(sort))

		if (sn > 1) {
			printf("{err}sort(%s) invalid\n", sort)
			printf("{p 4}Sort on one statistic{p_end}\n")
			exit(error(498))
		}
	}

	st_local(sort_n, sort)

	if (sort == "bic") {
		st_local(scol, "7")
	}
	else if (sort == "aic") {
		st_local(scol, "6")
	}
	else if (sort == "df") {
		st_local(scol, "5")
	}
	else if (sort == "ll") {
		st_local(scol, "4")
	}
	else {
		printf("{err}sort(%s) invalid\n", sort)
printf("{p 4}Statistic %s must be either {cmd:bic}, {cmd:aic}, {cmd:df}, or {cmd:ll}{p_end}\n", sort)
		exit(error(498))
	}
}

void _bfit_work2(string scalar bvlist) {
	string vector vlist

	vlist = tokens(bvlist)
	if (vlist[cols(vlist)] == "_cons") {
		st_local("bfit_bvlist", 	///
			invtokens(vlist[|1,1 \ 1,(cols(vlist)-1)|]))
	}
	else {
		st_local("bfit_bvlist", invtokens(vlist))
	}

}

void _BFIT_SortResults(string scalar Sname, real scalar scol) {

	real   matrix S
	string matrix Srnames, Scnames

	S       = st_matrix(Sname)
	Srnames = st_matrixrowstripe(Sname)
	Scnames = st_matrixcolstripe(Sname)
	S       = (1::rows(S)), S
	_sort(S, scol)
	st_matrix(Sname, S[|1,2 \ .,.|])
	st_matrixrowstripe(Sname,Srnames[S[.,1], .])
	st_matrixcolstripe(Sname,Scnames)
	Scnames = st_matrixcolstripe(Sname)
}

end
