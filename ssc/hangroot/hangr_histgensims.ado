*! version 1.5.0 MLB 06Sept2011
* version 1.0.1 MLB 28May2010
// based on offical Stata's -twoway__histogram_gen- version 1.1.14  02aug2006
// generate heights and bin centers for a histogram
program hangr_histgensims, rclass sortpreserve
        version 8.0

        syntax varname(numeric) [fw] [if] [in] , ///
		sims(varlist)                            ///
		hi(string)                               ///
        [                                        ///
                DISCrete                         ///
                BIN(passthru)                    /// number of bins
                Width(passthru)                  /// width of bins
                START(passthru)                  /// first bin position
                RETurn                           /// save results in r()
                GENerate(string asis)            /// generate(y x [, replace])
                display                          /// display a note
				xwx(string)                      /// extra x-variable for after models with covariates
				ninter(integer 5)                /// number of points between bin-mids
				inflate(numlist integer max=2 ascending)  /// taking care of the inflation part of zip, zinb, and zoib				
		]

	if `"`weight'"' != "" {
        local wght [`weight'`exp']
    }
	
	marksample touse
	if "`inflate'" != "" {
		local inflopt "inflate(`inflate')"
		tokenize `inflate'
		if "`2'" == "" {
			local ifinfl "& `varlist' != `1'"
		}
		else {
			local ifinfl "& !inlist(`varlist', `1', `2')"
		}
	}
	
	sum `varlist' if `touse' `ifinfl' `wght', meanonly
	local min = r(min)
	local max = r(max)
	local n = r(N)
	
	foreach var of local sims {
		sum `var' if `touse' `ifinfl' `wght', meanonly
		local min = min(`min', r(min))
		local max = max(`max', r(max))
	}
	if "`bin'`width'`discrete'" == "" {
		local bin =  ceil(min(sqrt(`n'), 10*ln(`n')/ln(10)))
		local bin "bin(`bin')"
	}
	if "`start'" == "" {
			local start "start(`min')"
	}
	if "`discrete'" != "" & `"`width'"' == "" {
		tempvar diff v2 io tousei
		tempname h
		qui gen `io' = _n       // restore sort order later
		qui gen byte `tousei' = `touse' `ifinfl'
		sort `tousei' `varlist', stable
		qui gen `v2' = `varlist' if `tousei'
		qui gen `diff' = `v2'-`v2'[_n-1] if `tousei'
		sum `diff' if `diff'>0, meanonly
		scalar `h' = cond(missing(r(min)), 1, r(min))
		sort `io', stable
		drop `v2' `diff'
		foreach v of varlist `sims'{
			if "`inflate'" != "" {
				tokenize `inflate'
				if "`2'" == "" {
					local ifinfl2 "& `v' != `1'"
				}
				else {
					local ifinfl2 "& !inlist(`v', `1', `2')"
				}
			}
			qui replace `tousei' = `touse' `ifinfl2'
			sort `tousei' `v', stable
			qui gen `v2' = `v' if `tousei'
			qui gen `diff' = `v2'-`v2'[_n-1] if `tousei'
			sum `diff' if `diff'>0, meanonly
			scalar `h' = min(`h', cond(missing(r(min)), 1, r(min)))
			sort `io', stable
			drop `v2' `diff'
		}
		drop `io'
		local width "width(`=`h'')"
	}
	
	if `"`xwx'"' != "" {
		local xwxopt "xwx(`xwx')"
		local ninteropt "ninter(`ninter')"
	}
	hangr_histgen `varlist' if `touse' `wght', ///
		gen(`generate') display `bin' `width' `start' ///
		`discrete' `xwxopt' `ninteropt' tmax(`max') `inflopt'
	
	tempname tobedropped
	local i = 1
	foreach var of local sims {
		qui hangr_histgen `var' if `touse' `wght', ///
			gen(`: word `i' of `hi'' `tobedropped') ///
			`bin' `width' `start' `discrete' tmax(`max') `inflopt'
		local i = `i' + 1
		capture assert `tobedropped' == `: word 2 of `generate''
		if _rc {
			di as err "You should never see this error"
			di as err "If you do than contact the author"
			di as err "and say that something went wrong in hangr_histgensims.ado"
			di as err "a (toy) dataset that replicates that error would be extremely helpful"
			list `: word 2 of `generate'' `tobedropped'
			exit 198
		}
		drop `tobedropped'
	}
	return scalar width = r(width)
	return scalar min   = r(min)
	return scalar max   = r(max)
	return scalar N     = r(N)
	return scalar bin   = r(bin)
	
end


