*! version 3.0.1  11sep2002 NJGW
* 3.0.1 fixed display of rep weights bug
program define svr_disp  /* display results */
	version 6
	syntax [, Level(int $S_level) CI DEFF DEFT MEFF MEFT OBS SIZE ]

	if `level' < 10 | `level' > 99 {
		di in red "level() must be between 10 and 99 inclusive"
		exit 198
	}
	if "`ci'`deff'`deft'`meff'`meft'`obs'`size'"=="" {
		local ci   "ci"
		local deff "deff"
	}


/* Get estimates. */

	tempname b V error t

	matrix `b' = e(est)
	matrix `V' = e(V_db)
	matrix `error' = e(error)
	local dim = colsof(`b')

	if "`e(complete)'"=="complete" {
		matrix `V' = vecdiag(`V')
		scalar `t' = invt(e(N_psu) - e(N_strata), `level'/100)
	}
	else	matrix `t' = e(_N_psu) - e(_N_str)

	if "`deff'"!="" {
		tempname Deff
		matrix `Deff' = e(deff)
	}
	if "`deft'"!="" {
		tempname Deft
		matrix `Deft' = e(deft)
	}
	if "`meff'`meft'"!="" {
		tempname Meft
		matrix `Meft' = e(meft)
	}
	if "`obs'"!="" {
		tempname Obs
		matrix `Obs' = e(_N)
	}
	if "`size'"!="" {
		tempname Size
		matrix `Size' = e(_N_subp)
	}

/* Set up switches (" " or "*") for display of items. */

	local count 2

	if "`ci'"!="" {
		local CI " "
		local count 4
	}
	else local CI "*"
	if "`deff'"!="" {
		local DEFF " "
		local count = `count' + 1
	}
	else local DEFF "*"
	if "`deft'"!="" & `count' < 5 {
		local deft
		local DEFT " "
		local count = `count' + 1
	}
	else local DEFT "*"
	if "`meff'"!="" & `count' < 5 {
		local meff
		local MEFF " "
		local count = `count' + 1
	}
	else local MEFF "*"
	if "`meft'"!="" & `count' < 5 {
		local meft
		local MEFT " "
		local count = `count' + 1
	}
	else local MEFT "*"
	if "`obs'"!="" & `count' < 5 {
		local obs
		local OBS " "
		local count = `count' + 1
	}
	else local OBS "*"
	if "`size'"!="" & `count' < 5 {
		local size
		local SIZE " "
		local count = `count' + 1
	}
	else local SIZE "*"

/* Print out header. */

	Header

/* Print out column headers of table 1. */

	LeftCol
	DashLine $S_1 top
	Colhead `level' " " "`CI'" "`DEFF'" "`DEFT'" /*
	*/	"`MEFF'" "`MEFT'" "`OBS'" "`SIZE'"

/* Print out body of table 1. */

	local i 1
	while `i' <= `dim' {
		LeftBody `i' `b'
		Body `i' `b' `V' `error' `t' "`Deff'" "`Deft'" "`Meft'"  /*
		*/ "`Obs'" "`Size'" `level' " " "`CI'" "`DEFF'" "`DEFT'" /*
		*/ "`MEFF'" "`MEFT'" "`OBS'" "`SIZE'"
		local i = `i' + 1
	}

	DashLine $S_1 bot

/* See if there is more to print out. */

	if "`deft'`meff'`meft'`obs'`size'"=="" {
		FootNote `"`Deff'"' `"`varerr'"'
		exit
	}

/* If here, we need to print out another table. */

	if "`deft'"!="" { local DEFT " " }
	else local DEFT "*"
	if "`meff'"!="" { local MEFF " " }
	else local MEFF "*"
	if "`meft'"!="" { local MEFT " " }
	else local MEFT "*"
	if "`obs'"!=""  { local OBS " " }
	else local OBS "*"
	if "`size'"!="" { local SIZE " " }
	else local SIZE "*"

/* Print out column headers of table 2. */

	di
	DashLine $S_1 top
	Colhead `level' * * * "`DEFT'" "`MEFF'" "`MEFT'" "`OBS'" "`SIZE'"

/* Print out body of table 2. */

	local i 1
	while `i' <= `dim' {
		LeftBody `i' `b'
		Body `i' `b' `V' `error' `t' "`Deff'" "`Deft'" "`Meft'" /*
		*/ "`Obs'" "`Size'" `level' * * * "`DEFT'" "`MEFF'" "`MEFT'" /*
		*/ "`OBS'" "`SIZE'"
		local i = `i' + 1
	}

	DashLine $S_1 bot
	FootNote `"`Deff'"' `"`varerr'"'
end

program define DashLine
	args col type
	local dash1 = `col' - 1
	local dash2 = 78 - `col'
	if "`type'"=="top" {
		local mid "{c TT}"
* local mid "T"
	}
	else if "`type'"=="bot" {
		local mid "{c BT}"
* local mid "V"
	}
	else if "`type'"=="foot" {
		local mid "{c -}"
	}
	else	local mid "{c +}"
	di in smcl in gr "{hline `dash1'}`mid'{hline `dash2'}"
end

program define FootNote
	args deff varerr

	if "`e(fpc)'"!="" { /* print FPC note */
		di in gr "Finite population correction (FPC) assumes " /*
		*/ "simple random sampling without " _n /*
		*/ "replacement of PSUs within each stratum with no " /*
		*/ "subsampling within PSUs."

		if "`deff'"!="" {
			di in gr "Weights must represent population " /*
			*/ "totals for deff to be correct when" _n /*
			*/ "using an FPC.  Note: deft is invariant " /*
			*/ "to the scale of weights."

		}
	}
	if "`e(missing)'"!="" {
		di in gr "(*) Some variables contain missing values."
	}
	if `"`varerr'"'!="" {
		di `varerr'
	}

end

program define Header /* display header */
	version 7
	local wgt    `e(wtype)'
	if `"`e(wexp)'"'!="" {
		local exp = substr(`"`e(wexp)'"',3,.)
	}
	*local strata `e(strata)'
	*local psu    `e(psu)'
	*if "`wgt'"    == "" { local wgt    "pweight"        }
	if `"`exp'"'  == "" { local exp    "<none>"         }
	*if "`strata'" == "" { local strata "<one>"          }
	*if "`psu'"    == "" { local psu    "<observations>" }

	local cmd=substr("`e(cmd)'",7,.)
	di _n in gr "Survey `cmd' estimation, replication (`e(method)') variance method" _n

	if "`e(missing)'"!="" { local fnote "(*)" }

	di in gr "Analysis weight:" _col(23) `"`exp'"' /*
			*/ in gr _col(48) "Number of obs`fnote'" _col(68) "= " /*
			*/ in ye %9.0f `e(N)'

	if length(`"`e(svr_wspec)'"')<=24 {
		di "{txt}Replicate weights:" _col(23) "`e(svr_wspec)'" _c
		di in gr _col(48)  "Population size" _col(68) "=" in ye %10.0g `e(N_pop)'
	}
	else {
		local part : word 1 of `e(svr_wspec)'
		di "{txt}Replicate weights:" _col(23) `"{stata svrset list rw:`part'...}"' _c
		di in gr _col(48)  "Population size" _col(68) "=" in ye %10.0g `e(N_pop)'
	}

	di in gr "Number of replicates:" _col(23) `"`e(N_reps)'"' /*
		*/ 	in gr _col(48)  "Degrees of freedom" _col(68) "=" /*
		*/	in ye %10.0g `e(N_psu)'-`e(N_strata)'

	if "`e(method)'"=="brr" {
		di in gr "k (Fay's method):" _col(23) %4.3f `e(fay)'
	}

	di

end

program define Colhead
	args level
	macro shift
	LeftCol
	local head "$S_2 {c |}"
	global S_2  /* erase macro */

	`1' local head "`head'   Estimate"
	`1' local head "`head'    Std. Err."
	`2' local head "`head'`s'   [`level'% Conf. Interval]"
	`2' local s " "
	`3' local head "`head'`s'       Deff"
	`3' local s " "
	`4' local head "`head'`s'       Deft"
	`4' local s " "
	`5' local head "`head'`s'       Meff"
	`5' local s " "
	`6' local head "`head'`s'       Meft"
	`6' local s " "
	`7' local head "`head'`s'        Obs"
	`7' local s " "
	`8' local head "`head'`s'  Pop. Size"
	di in smcl in gr "`head'"
end

program define LeftCol
	if "`e(by)'"=="" {
		global S_1 10  /* column of vertical line */
		if "`e(cmd)'"=="svysvrmean" {
			global S_2 "    Mean"
			exit
		}
		if "`e(cmd)'"=="svysvrtotal" {
			global S_2 "   Total"
			exit
		}
		if "`e(cmd)'"=="svysvrratio" {
			global S_1 19
			global S_2 "      Ratio      "
			exit
		}
	}

/* If here, we have subpops. */

	if "`e(cmd)'"=="svysvrmean" { local name "Mean" }
	else if "`e(cmd)'"=="svysvrtotal" { local name "Total" }
	else if "`e(cmd)'"=="svysvrratio" { local name "Ratio" }

	local nbyvar : word count `e(by)'

	if ("`e(label)'"!="" & `nbyvar' == 2) | "`e(cmd)'"=="svysvrratio" {
		global S_1 19
	}
	else global S_1 16

	local col = $S_1 - 8

	global S_2 : di "`name'" _col(`col') "Subpop."
end

program define Body
	args i b V error t Deff Deft Meft Obs Size level
	macro shift 11
	local s 2

	if `error'[1,`i'] >=1 {
		if `error'[1,`i']==1      {
			di in ye " (no observations)"
		}
		else if `error'[1,`i']==2 {
			di in ye " (stratum with 1 PSU detected)"
		}
		else if `error'[1,`i']==3 {
			di in ye " (sum of weights equals zero)"
		}
		else if `error'[1,`i']==4 {
			di in ye " (denominator estimate equals zero)"
		}
		exit
	}

	if "`e(complete)'"=="available" {
		tempname tt
		scalar `tt' = invt(`t'[1,`i'],`level'/100)
		local t `tt'
	}


	if (!(`error'[1,`i']>0 & `error'[1,`i']<1)) {

		if "`1'"!="*" {
			if `b'[1,`i'] < 1e7 {
				local body : di _s(2) %9.0g `b'[1,`i'] /*
				*/		_s(3) %9.0g sqrt(`V'[1,`i'])
			}
			else {
				local body : di _s(1) %10.0g `b'[1,`i'] /*
				*/		_s(3) %9.0g sqrt(`V'[1,`i'])
			}
			local s 3
		}

		if "`2'"!="*" {
			local x : di _s(3) %9.0g `b'[1,`i']-`t'*sqrt(`V'[1,`i']) _s(3) %9.0g `b'[1,`i']+`t'*sqrt(`V'[1,`i'])
			local body "`body'`x'"
		}

		if "`3'"!="*" {
			local x : di _s(3) %9.0g cond(`Deff'[1,`i']!=0,`Deff'[1,`i'],.)
			local body "`body'`x'"
		}

		if "`4'"!="*" {
			local x : di _s(`s') %9.0g cond(`Deft'[1,`i']!=0,`Deft'[1,`i'],.)
			local body "`body'`x'"
			local s 3
		}

		if "`5'"!="*" {
			local x : di _s(`s') %9.0g cond(`Meft'[1,`i']!=0,`Meft'[1,`i']^2,.)
			local body "`body'`x'"
			local s 3
		}

		if "`6'"!="*" {
			local x : di _s(`s') %9.0g cond(`Meft'[1,`i']!=0,`Meft'[1,`i'],.)
			local body "`body'`x'"
			local s 3
		}

		if "`7'"!="*" {
			local x : di _s(`s') %9.0g `Obs'[1,`i']
			local body "`body'`x'"
			local s 3
		}

		if "`8'"!="*" {
			if `Size'[1,`i'] < 1e7 {
				local x : di _s(`s') %9.0g `Size'[1,`i']
			}
			else {
				local s = `s' - 1
				local x : di _s(`s') %10.0g `Size'[1,`i']
			}
			local body "`body'`x'"
		}
	}
	else {	/* VARIANCE ERROR FOR THIS VARIABLE */

		c_local varerr `"in gr "(" in ye "***" in gr ") Unable to calculate estimates in 1 or more" _n _col(7) "replicates.  Standard error not calculated.""'

		if "`1'"!="*" {
			if `b'[1,`i'] < 1e7 {
				local body : di _s(2) %9.0g `b'[1,`i'] /*
				*/		_s(3) %9s "***"
			}
			else {
				local body : di _s(1) %10.0g `b'[1,`i'] /*
				*/		_s(3) %9s "***"
			}
			local s 3
		}

		if "`2'"!="*" {
			local x : di _s(3) %9.0g . _s(3) %9.0g .
			local body "`body'`x'"
		}

		if "`3'"!="*" {
			local x : di _s(3) %9.0g .
			local body "`body'`x'"
		}

		if "`4'"!="*" {
			local x : di _s(`s') %9.0g .
			local body "`body'`x'"
			local s 3
		}

		if "`5'"!="*" {
			local x : di _s(`s') %9.0g .
			local body "`body'`x'"
			local s 3
		}

		if "`6'"!="*" {
			local x : di _s(`s') %9.0g .
			local body "`body'`x'"
			local s 3
		}

		if "`7'"!="*" {
			local x : di _s(`s') %9.0g `Obs'[1,`i']
			local body "`body'`x'"
			local s 3
		}

		if "`8'"!="*" {
			if `Size'[1,`i'] < 1e7 {
				local x : di _s(`s') %9.0g `Size'[1,`i']
			}
			else {
				local s = `s' - 1
				local x : di _s(`s') %10.0g `Size'[1,`i']
			}
			local body "`body'`x'"
		}

	}

	di in ye "`body'"
end

program define LeftBody
	args i b
	local colname : colnames(`b')
	local coli : word `i' of `colname'
	if "`e(by)'"=="" {
		if `i'==1 { DashLine $S_1 mid }
		local coli = abbrev(`"`coli'"',8)
		if "`e(cmd)'"!="svysvrratio" {
			local col = $S_1 - 1 - length(`"`coli'"')
			di in gr in smcl _col(`col') `"`coli' {c |}"' _c
			exit
		}
		local eqname : coleq(`b')
		local eqi : word `i' of `eqname'
		local eqi = abbrev(`"`eqi'"', 8)
		local col = 9 - length(`"`eqi'"')
		di in gr in smcl /*
			*/ _col(`col') `"`eqi'/`coli'"' _col($S_1) "{c |}" _c
		exit
	}

/* If here, we have subpops. */

	if mod(`i'-1, `e(n_by)') == 0 { /* print line, then varname */
		DashLine $S_1 mid
		if "`e(cmd)'"=="svysvrratio" {
			local k = 2*int((`i'-1)/`e(n_by)') + 1
			local numi : word `k' of `e(list)'
			local k = `k' + 1
			local deni : word `k' of `e(list)'
			di in ye in smcl /*
				*/ `"`numi'/`deni'"' _col($S_1) in gr "{c |}"
		}
		else {
			local eqname : coleq(`b')
			local eqi : word `i' of `eqname'
			di in smcl in ye `"`eqi'"' _col($S_1) in gr "{c |}"
		}
	}

	local nbyvar : word count `e(by)'
	if "`e(label)'"!="" & `nbyvar'==2 { /* two labels */
		local j = 2*mod(`i'-1, `e(n_by)') + 1
		local word1 : word `j' of `e(label)'
		local col1 = $S_1 - 10 - length(`"`word1'"')
		local j = `j' + 1
		local word2 : word `j' of `e(label)'
		local col2 = $S_1 - 1 - length(`"`word2'"')
		di in gr in smcl _col(`col1') `"`word1'"' /*
		*/ _col(`col2') `"`word2' {c |}"' _c
		exit
	}
	if "`e(label)'"=="" & `nbyvar'==1 {
		local coli "`e(by)'==`coli'"
	}
	local col = $S_1 - 1 - length(`"`coli'"')
	di in smcl in gr _col(`col') `"`coli' {c |}"' _c
end
