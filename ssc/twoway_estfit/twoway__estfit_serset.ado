*! version 1.0.0  13oct2002
program twoway__estfit_serset

	// Creates a serset for a fit view.  Runs from an immediate log.
// edited version of lfit, allows specifying any fit command thru estcmd() option
// works with twoway_estcmd_parse.class

	syntax , SERSETNAME(string) X(string) Y(string) TOUSE(string)	///
		 [ PREDOPTS(string) REGOPTS(string) ATOBS(integer 0)	///
		 POINTS(integer 2) MIN(string) MAX(string)		///
		 XTRANS(string) MOREVARS(string) WEIGHT(string)		///
		 LEVEL(real `c(level)') STD(string)  ESTCMD(string) ]

	tempname esthold
	_estimates hold `esthold' , nullok restore

	if `"`xtrans'"' != `""' {
		tempvar regx
		VarTrans `x' `regx' `"`xtrans'"'
	}
	else {
		local regx `x'
	}

	if "`estcmd'"=="" local estcmd "reg"

	qui `estcmd' `y' `regx' [`weight'] if `touse' , `regopts'

	tempname touse2
	gen byte `touse2' = `touse' & e(sample)

	capture noisily {

		if ! `atobs' {
			tempvar holdx
			local realN `c(N)'
			preserve ,  changed
			_gs_x_create , points(`points') x(`x')		///
				       min(`"`min'"') max(`"`max'"')	///
				       holdx(`holdx') touse(`touse2')
			local touse2 _n <= `points'
			if `"`xtrans'"' != `""' {
				capture drop `regx'
				VarTrans `x' `regx' `"`xtrans'"'
			}
		}

		tempvar yhat
		qui predict `yhat' if `touse2' , `predopts'
		label var `yhat' "Fitted Values (`estcmd')"
		local ylist `yhat'

		if "`std'" != "" {
			tempvar se lcl ucl
			qui predict `se' if `touse2' , `std'
			qui gen `lcl' = `yhat' -			///
				invttail(e(df_r), ((100-`level')/200)) * `se'
			qui gen `ucl' = `yhat' +			///
				invttail(e(df_r), ((100-`level')/200)) * `se'
			label variable `lcl' "`level'% CI"
			label variable `ucl' "`level'% CI"

			local ylist `ylist' `lcl' `ucl'
		}

		.`sersetname' = .serset.new `ylist' `x' `morevars'	///
			if `touse2', `.omitmethod' `options'

		if "`std'" != "" {
			.`sersetname'.sers[2].name = "lower_limit"
			.`sersetname'.sers[3].name = "upper_limit"
		}

	}
	local rc = _rc

	if ! 0`atobs' {
		capture {
			if `realN' < c(N) {
				qui drop in `=`realN'+1'/l
			}
			qui drop `x' `ylist'
			rename `holdx' `x'
			restore
		}
		local rc = cond(`rc' , `rc' , _rc)
	}

	if `rc' {
		exit `rc'
	}

	.`sersetname'.sort `x'
	.`sersetname'.sers[1].name = "`y'"

end


program VarTrans
	args v vtmp trans

	local trans : subinstr local trans "X" "`v'" , all
	qui gen double `vtmp' = `trans'
end
