*! version 1.0.1 PR 31oct2012
program define xfracpoly, eclass
	local VV : di "version " string(_caller()) ":"
	version 11.0
	local cmdline : copy local 0
	mata: _parse_colon("hascolon", "rhscmd")	// _parse_colon() is stored in _parse_colon.mo
	if (`hascolon') {
		`VV' newfracpoly `"`0'"' `"`rhscmd'"'
	}
	else {
		`VV' xfracpoly_10 `0'
	}
	// ereturn cmdline overwrites e(cmdline) from fracpoly_10
	ereturn local cmdline `"fracpoly `cmdline'"'
end

program define newfracpoly
	local VV : di "version " string(_caller()) ":"
	version 11.0
	args 0 statacmd

	// Extract fracpoly options
	syntax, [*]
	local fracpolyopts `options'

/*
	It is important that the fracpoly options precede the Stata command options.
	To ensure this, must extract the Stata options and reconstruct the command
	before presenting it to fracpoly_10.
*/
	local 0 `statacmd'
	syntax [anything] [if] [in] [aw fw pw iw], [*]
	if `"`weight'"' != "" local wgt [`weight'`exp']

	`VV' xfracpoly_10 `anything' `if' `in' `wgt', `fracpolyopts' `options'
end

program define xfracpoly_10, eclass
	local VV : di "version " string(_caller()) ":"
	version 11.0
	if replay() {
		`VV' xfrac_154 `0'
		di as txt "Deviance:" as res %9.2f e(fp_dev) as txt "."
		exit
	}
	if !(_caller() < 12) {
		quietly ssd query
		if (r(isSSD)) {
			di as err "fracpoly not possible with summary statistic data"
			exit 111
		}
	}
	local cmdline : copy local 0
	gettoken cmd 0 : 0
	xfrac_chk `cmd' 
	if `s(bad)' {
		di as err "invalid or unrecognized command, `cmd'"
		exit 198
	}
	local dist `s(dist)'

	syntax [anything(name=xlist)] [if] [in] [aw fw pw iw] [, * ]
	if `"`weight'"' != "" local wgt [`weight'`exp']
	if `dist' != 7 {
		ChkDepvar lhs xlist : `"`xlist'"'
		if `dist' == 8 {
			local y1 `lhs'
			ChkDepvar y2 xlist : `"`xlist'"'
			local lhs `y1' `y2'
		}
	}
	if (`"`xlist'"'=="") {
		error 102
	}
	local 0 `xlist'
	/*
		Look for predictors and associated powers
	*/
	local pwrs
	local rhs
	local nx 0
	local lastnv 0
	parse "`*'", parse(" ,[")

	gettoken next : 0, parse(" ,[")
	while "`next'"!= ""  & "`next'"!="," & "`next'"!="if" & /*
	*/    "`next'"!="in" & "`next'"!="[" { 
		gettoken next 0 : 0, parse(" ,[")	/* make real */
		cap fvunab next : `next'
		if _rc == 0 { 		/* found a new xvarlist */
			local varl `next'
			local nv : word count `varl'
			if `nx'>0 {	/* have a previous xvarlist */
				if "`pwrs'"=="" & `nx'>1 {
					local pwrs 1
				}
				/*
					Flush powers
				*/
				local j=`nx'-`lastnv'+1
				while `j'<=`nx' {
					local p`j' `pwrs'
					local j=`j'+1
				}
				local pwrs
			}
			else {		/* this is first xvarlist */
				if `nv'>1 { 
					di as err /*
*/ "`next' ambiguous---xvar [#] required before covariate model is specified"
					exit 198
				}
				fvexpand `rhs'
				if "`r(fvops)'" == "true" {
					di as err "factor variables not allowed in this context"
					exit 198
				}
			}
			/*
				Store current xvarlist names and 
				update variable count
			*/
			forvalues j=1/`nv' {
				local ++nx
				local v`nx': word `j' of `varl'
				local rhs `rhs' `v`nx''
			}
			local lastnv `nv'
		}
		else {			/* got power(s) */
			if `nx'==0 {
				di as err "invalid `next', not a varlist"
				exit 198
			}
			CheckFVTS `next'
			cap confirm num `next'
			if _rc { 
				di as err ///
`""`next'" found where number or varlist expected"'
				exit 7
			}
			local pwrs `pwrs' `next'
		}
		gettoken next : 0, parse(" ,[")
	}
	if `nx'==0 {
		di as err "no xvar found"
		exit 198
	}

	/*
		Flush powers
	*/
	if "`pwrs'"=="" & `nx'>1 local pwrs 1
	local j=`nx'-`lastnv'+1
	while `j'<=`nx' {
		local p`j' `pwrs'
		local ++j
	}
	local 0 `"`lhs' `if' `in' `wgt', `options'"'
	if `dist' == 8 		local vv varlist(min=2 max=2)
	else if `dist' != 7	local vv varname
	syntax `vv' [if] [in] [aw fw pw iw] [, /* 
		*/ ADjust(str) CENTer(str) ALL DEAD(varname) EXPx(str) ZERo(varlist) /*
		*/ CATZero(varlist) ORIgin(str) REPort(numlist) noSCAling * ]

	if ("`adjust'"=="") {
		local adjust "`center'"
	}
	else if ("`center'"!="") {
		di as err "may not specify both adjust() and center()"
		exit 198
	}

	tempvar touse
	mark `touse' [`weight' `exp'] `if' `in'
	if `dist' == 8 {
		quietly replace `touse' = 0 if `y1'>=. & `y2'>=.
		markout `touse' `rhs' `dead' `zero' `catzero'
	}
	else markout `touse' `lhs' `rhs' `dead' `zero' `catzero'
/*
	With `all', estimation is restricted to `touse' subsample,
	but transformation is computed on all available values
*/
	if "`all'"!="" {
		local restrict restrict(`touse')
		local fracgen_touse 1
	}
	else	local fracgen_touse `touse'
	frac_cox "`dead'" `dist'
	if "`dead'"!="" local dead dead(`dead')

	/*
		vars to be adjusted, taking number of unique values 
		into account.
	*/
	xfrac_adj "`adjust'" "`rhs'" `touse'
	local i 0
	while `i'<`nx' {
		local ++i
		local a `r(adj`i')'
		if "`a'"!="" {
			local adj`i'=cond(`i'==1, "`a'", "adjust(`a')" )
		}
	}
	/*
		vars with expx option
	*/
	if "`expx'"!="" {
		xfrac_dis "`expx'" expx "`rhs'"
		local j 0
		while `j'<`nx' {
			local ++j
			if "${S_`j'}"!="" {
				local exp`j' expx(${S_`j'})
			}
		}
	}
	/*
		vars with origin option
	*/
	if "`origin'"!="" {
		xfrac_dis "`origin'" origin "`rhs'"
		local j 0
		while `j'<`nx' {
			local ++j
			if "${S_`j'}"!="" {
				local ori`j' origin(${S_`j'})
			}
		}
	}
	/*
		Vars with zero option
	*/
	if "`zero'"!="" {
		tokenize `zero'
		while "`1'"!="" {
			frac_in `1' "`rhs'"
			local zer`s(k)' "zero"
			mac shift
		}
	}
	/*
		Vars with catzero option
	*/
	if "`catzero'"!="" {
		tokenize `catzero'
		while "`1'"!="" {
			frac_in `1' "`rhs'"
			local cat`s(k)' "catzero"
			local zer`s(k)' "zero"	/* catzero implies zero */
			mac shift
		}
	}
	/*
		Construct fracpoly command to go to frac_154.
		First, remove old I* variables.
	*/
	forvalues i=1/`nx' {
		frac_mun `v`i'' purge
	}
	local base
	forvalues i=1/`nx' {
		local create= /*
		*/ ("`p`i''"!="1" | "`zer`i''`ori`i''`exp`i''`adj`i''"!="")
		if `create' {		/* garner unique name stub */
			frac_mun `v`i''
			local vn `s(name)'
			if `i'==1 {
				qui gen byte `vn'_1=. /*reserves name `vn'_1*/
				local n name(`vn')    /*force name in frac_154*/
			}
			else {
				fracgen `v`i'' `p`i'' if `fracgen_touse', /*
				*/ `restrict' sayesamp name(`vn') /*
				*/ `adj`i'' `exp`i'' /*
				*/ `zer`i'' `cat`i'' `ori`i'' `scaling'
				local base `base' `r(names)'
				local n`i' `r(names)'
			}
		}
		else {
			if `i'>1 {
				local base `base' `v`i''
				local n`i' `v`i''
			}
		}
	}

	if "`adj1'"=="" local adj adjust(no)
	else local adj adjust(`adj1')

	* Report effect sizes (differences on FP curve) at values in report.
	quietly if "`report'"!="" {
		local all all
		local nrep: word count `report'
		local n1=_N+1
		local nplus=_N+`nrep'
		set obs `nplus'
		local j 1
		forvalues i=`n1'/`nplus' {
			local X: word `j' of `report'
			replace `v1'=`X' in `i'
			local ++j
		}
	}
	`VV' ///
	xfrac_154 `cmd' `lhs' `v1' `p1' `base' if `fracgen_touse' [`weight' `exp'], /*
	*/ `restrict' `n' `adj' `exp1' `zer1' `cat1' `ori1' `scaling' /*
	*/ `dead' `options'

	version 10: ereturn local cmdline `"fracpoly `cmdline'"'

	* Compute effect sizes and SEs
	if "`report'"!="" {
		di as txt _n "{hline 17}{c TT}{hline 47}" ///
		 _n %12s abbrev("`v1'", 16) ///
		 _col(18)"{c |}  Difference   Std. Err.   [$S_level% Conf. Interval]" ///
		 _n "{hline 17}{c +}{hline 47}"
		tempname b V diff var se l u X Diff Se
		matrix `b'=e(b)
		matrix `V'=e(V)
		local nrow=`nrep'-1
		matrix `X'=J(`nrow',2,0)
		matrix `Diff'=J(`nrow',1,0)
		matrix `Se'=J(`nrow',1,0)
		local catz=e(fp_catz)
		local m=wordcount("`e(fp_xp)'")-`catz'
		local tail=(1-$S_level/100)/2
		if e(fp_dist)==0 local t=invttail(e(df_r),`tail')
		else local t=invnorm(1-`tail')
		* Store FP(x) values in first additional row
		local row=`nplus'-`nrep'+1
		forvalues i=1/`m' {
			local I=`i'+`catz'
			local fpx: word `I' of `e(fp_xp)'
			tempname x1`i' x2`i'
			scalar `x1`i''=`fpx'[`row']
		}
		local ++row
		local extra 1			// counts the points at which evaluation is required
		forvalues j=`row'/`nplus' {
			scalar `diff'=0
			scalar `var'=0
			forvalues i=1/`m' {
				local I=`i'+`catz'
				local fpx: word `I' of `e(fp_xp)'
				scalar `x2`i''=`fpx'[`j']
				scalar `diff'=`diff'+`b'[1, `I']*(`x2`i''-`x1`i'')
				scalar `var'=`var'+`V'[`I', `I']*(`x2`i''-`x1`i'')^2
			}
			if `m'>1 {
				forvalues i=1/`m' {
					local i1=`i'+1
					local I=`i'+`catz'
					forvalues k=`i1'/`m' {
						local K=`k'+`catz'
						scalar `var'=`var'+2*`V'[`I', `K']* ///
						 (`x2`i''-`x1`i'')*(`x2`k''-`x1`k'')
					}
				}
			}
			scalar `se'=sqrt(`var')
			scalar `l'=`diff'-`t'*`se'
			scalar `u'=`diff'+`t'*`se'
			local ix `extra'
			local X1: word `extra' of `report'
			local ++extra
			local X2: word `extra' of `report'
			matrix `X'[`ix',1]=`X1'
			matrix `X'[`ix',2]=`X2'
			matrix `Diff'[`ix',1]=`diff'
			matrix `Se'[`ix',1]=`se'
			di as text /*
			*/  %8.0g `X1' "-" %-8.0g `X2' _col(18) "{c |}" /*
			*/ _col(21)  as res %9.0g `diff'	  /*
			*/ _col(33)  as res %9.0g `se'	  /*
			*/ _col(47)  %9.0g `l' /*
			*/ _col(57)  %9.0g `u'
			forvalues i=1/`m' {
				scalar `x1`i''=`x2`i''
			}
		}
		di as txt "{hline 17}{c BT}{hline 47}"
		local row=`nplus'-`nrep'+1
		qui drop in `row'/l
		ereturn matrix repx=`X'
		ereturn matrix repdiff=`Diff'
		ereturn matrix repse=`Se'
	}

	/*
		Store covariate names and their (fixed) powers, if any.
		Also, note presence of catzero variables in e(fp_c`i').
	*/
	if e(fp_catz) ereturn local fp_c1 1
	ereturn local fp_n1 `e(fp_xp)'
	forvalues i=2/`nx' {
		ereturn local fp_x`i' `v`i''
		ereturn local fp_k`i' `p`i''
		ereturn local fp_n`i' `n`i''
		if "`cat`i''"!="" ereturn local fp_c`i' 1
	}
	ereturn scalar fp_nx = `nx' 
end

program CheckFVTS
	version 11
	capture syntax [varlist(fv ts)]
	if c(rc) exit
	syntax varlist
end

program define ChkDepvar
	args dv xlist colon spec

	gettoken depvar spec : spec, parse(",")
	if (`"`depvar'"'=="") {
		error 102
	}
	cap unab depvar : `depvar'
	gettoken depvar rest : depvar
	if _rc {
		unab depvar : `depvar'
		gettoken depvar rest2 : depvar
	}
	c_local `dv' `depvar'
	c_local `xlist' `rest2' `rest' `spec'
end
