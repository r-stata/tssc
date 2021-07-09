*! corrsvy v1.0  NJGW 9-28-2001 
*! survey correlation estimates, with significance levels
*

prog define corr_svy, rclass
	version 7

	syntax varlist [pweight/] [if] [in] , [ pw 					/*
			*/ Obs sig Print(real 100) STar(real -1) 			/*
			*/ STRata(varname) PSU(varname) FPC(varname numeric) 	/*
			*/ SUBpop(varname numeric) ]


/* Get weights. */


	if `"`exp'"'=="" {
		svy_get pweight, optional
		local exp `s(varname)'
	}
	else if "`weight'"=="pweight" { 		/* try to varset pweight variable */
		capture confirm variable `exp'
		if _rc==0 {
			svy_get pweight `exp'
			local exp `s(varname)'
		}
	}
	if "`exp'"!="" {
		local awt [aw=`exp']
		local wt [pw=`exp']
	}
	if `print'>1 {
		local print=`print'/100
		if `print'>1 {
			di as err "Print() out of range"
			error 198
		}
	}
	if `star'>1 {
		local star=`star'/100
	}
	if `star'>1 {
		di as err "Star() out of range"
		error 198
	}

/* Get strata, psu, and fpc. */

	svy_get strata `strata', optional
	local str `s(varname)'
	if "`str'"!="" {
		local svyopt "`svyopt' strata(`str')"
	}

	svy_get psu `psu', optional
	local psu `s(varname)'
	if "`str'"!="" { 
		local svyopt "`svyopt' psu(`psu')"
	}

	svy_get fpc `fpc', optional
	local fpc `s(varname)'
	if "`fpc'"!="" { 
		local svyopt "`svyopt' fpc(`fpc')"
	}

	if "`subpop'"!="" {
		local svyopt "`svyopt' subpop(`subpop')"
	}

/* Mark/markout. */

	tempvar touse svyuse
	mark `touse' `wt' `if' `in', zeroweight
	mark `svyuse' `wt' `if' `in', zeroweight

	if "`pw'"=="" {
		markout `touse' `varlist'
		markout `svyuse' `varlist'				/* need to deal with this regarding subpop... */
	}
	markout `touse' `str' `psu' `fpc'  , strok
	if "`subpop'"!="" {
		qui replace `touse' = 0 if `subpop'==0 | `subpop'==.
	}


/* Compute total #obs. */

	qui count if `touse'
	local N = r(N)
	if `N' == 0 { error 2000 }

	if "`wt'"!="" {
		qui count if `touse' & (`exp')!=0
		if r(N) == 0 {
			di in blu "all observations have zero weights"
			exit 2000
		}
	}

/* HERE WE GO */

	if "`sig'`obs'"!="" {
		local space `"di "{txt}{dup 13: }{c |}""'
	}

	local nvar : word count `varlist'


* DO TITLE LINES

	di
	di "{txt}Survey Correlation"
	di
	di "pweight:  " cond("`exp'"=="","<none>","`exp'")
	di "Strata:   " cond("`str'"=="","<one>","`str'")
	di "PSU:      " cond("`psu'"=="","<observations>","`psu'")
	if "`fpc'"!="" {
		di "FPC:      `fpc'"
	}

	di

	if "`pw'"=="" {
		di "{txt}Number of observations: {res}`N'{txt}"
	}
	di


	di "{txt}             {c |}" _c
	forval i=1/`nvar' {
		local v`i' : word `i' of `varlist'
		di "{txt}{ralign 12:`v`i''}" _c
	}
	di
	di "{hline 13}{c +}{dup `nvar':{hline 12}}"


*CYCLE THROUGH VARIABLES

	tempname r_main t1 t2 tmin p 

	forval i=1/`nvar' {
		di "{txt}{ralign 12:`v`i''} {c |} " _c
		forval j=1/`i' {						/* only doing lower quadrant */
			if `i'==`j' {
				di "{res}" %11.4f 1.0
				qui count if `v`i''!=. & `touse'
				local n`i'=`r(N)'
			}
			else {
				qui corr `v`i'' `v`j'' `awt' if `touse'
				local n`j' = `r(N)'
				local N = `r(N)'
				scalar `r_main'=r(rho)
				qui svyreg `v`i'' `v`j'' `wt' if `svyuse' , `svyopt'
				scalar `t1' = abs(_b[`v`j'']/_se[`v`j''])
				qui svyreg `v`j'' `v`i'' `wt' if `svyuse', `svyopt'
				scalar `t2' = abs(_b[`v`i'']/_se[`v`i''])
				scalar `tmin' = min(`t1',`t2')
				scalar `p' = (ttail(e(N_psu)-e(N_strata),`tmin'))*2
				local p_`j' : di %5.4f `p'
				if `p'<(`star') {
					local s_`j' "*"
				}
				else {
					local s_`j' " "
				}

				if `p'>`print' {
					local r_print
					local p_`j'
					local s_`j' " "
					local n`j'
				}
				else {
					local r_print : di %11.4f `r_main'
				}

				di  "{res}{ralign 11:`r_print'}`s_`j''" _c
			}
		}


		if "`obs'"=="obs" {
			di "{txt}             {c |}" _c
			forval j=1/`i' {
				di "{res}{ralign 12:`n`j''}" _c
			}
			di
		}

		if "`sig'"=="sig" {
			di "{txt}             {c |}" _c
			forval j=1/`i' {
				di "{res}{ralign 12:`p_`j''}" _c
			}
			di
		}

		if `i'<`nvar' {
			`space'
		}
	}


	if `"`space'"'!="" | `star'!=-1 {
		di "{txt}{hline 13}{c BT}{dup `nvar':{hline 12}}"
	}
	if `"`space'"'!="" {
		di "Key: " _c
		di "Estimated Correlation"
		di "     " _c
		if "`obs'"=="obs" { 
			di "Number of observations"
			di "     " _c
		}
		if "`sig'"=="sig" { 
			di "Significance Level" 
			di "     " _c
		}
	}
	if "`star'"!="-1" { 
		di "* indicates p<" %4.3f `star'
	}

	return scalar N = `N'
	return scalar p = `p'
	return scalar rho = `r_main'
	
end

