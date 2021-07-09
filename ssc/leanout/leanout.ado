*! version 1.0.0  06nov2009
program define leanout
	version 11

					// Handle callers version

	local callver : di "version " string(_caller()) ", missing:"

					// Handle <my_stuff> : <command>
	_on_colon_parse `0'

	local preopts `"`s(before)'"'
	local 0 `"`s(after)'"'

					// Allow my display options in <command>

	local myopts NOOMITted vsquish NOEMPTYcells  BASElevels		///
		     ALLBASElevels FORMAT(string) 

	syntax [anything(everything)] [ , `myopts' Level(real 95)	///
		VARWidth(integer 16) * ]

	foreach opt of local myopts {
		gettoken opt : opt , parse("(")
		local opt = lower("`opt'")
		local `opt'_h `"``opt''"'
	}
	local level_h `level'
	local varwidth_h `varwidth'
	local options_h `"`options'"'


					// Parse my display options

	local 0 `"`preopts'"'
	syntax [ , `myopts' Level(real 95) VARWidth(integer 16) ]

					// Handle my options from <command>
	foreach opt of local myopts {
		gettoken opt : opt , parse("(")
		local opt = lower("`opt'")
		if `"``opt''"' == `""' {
			local `opt' `"``opt'_h'"'
		}
	}
	if `level' == 95 {
		local level `level_h'
	}
	if `varwidth' == 16 {
		local varwidth `varwidth_h'
	}

	if `varwidth' < 8 {
		di as error "varwidth() must be at least 8"
		exit 198
	}


					// Run command
	if `"`options_h'"' != `""' {
		local options `", `options_h'"'
	}
	`callver' capture `anything' `options'
	if _rc {
		`callver' `anything' `options'
	}

					// Adjust spacing for width of format
	parsefmt format width : `format'
	if `width' <= 5 {
		local lnspace = 5 - `width'
		local hdspace = 0
		local hllen = 31 + `varwidth'
	}
	else {
		local lnspace = 0
		local hdspace = `width' - 5
		local hllen = 31 + `varwidth' + 3 * (`hdspace'+1)
	}
	local notefmt "%`width's"

					// Collect factor-variable options

	local msopts `"`noomitted' `noemptycells'"'
	local msopts `" `msopts' `baselevels' `allbaselevels'"'

					// Handle CI level
	if "`e(df_r)'" != "" {
		local type t
		local ci_mult = -invttail(e(df_r), 1-(1-`level'/100)/2)
	}
	else {
		local type z
		local ci_mult = invnormal(1-(1-`level'/100)/2)
	}

					// Display results
	di " "
	di in smcl "{text}Dependent variable: `e(depvar)'" _newline

	
	local vwspace = `varwidth' - 6
	di in smcl "{text}{space `vwspace'}Variable    {space `hdspace'}Coef     {space `hdspace'}SE      {space `hdspace'}" %2.0f `level' "%  CI"

	tempname b V
	matrix `b' = e(b)
	matrix `V' = e(V)

					// Use FV tools in case covariates
					// include factor variables
	local eqs   : coleq `b'
	_ms_eq_info, matrix(`b')
	local neq = r(k_eq)
	forvalues eq = 1/`neq' {
		local k`eq' = r(k`eq')
		local eqname`eq' `"`r(eq`eq')'"'
	}
	local neq = `neq' - 0`e(k_aux)'

					// Loop over equations
	local vsquish_h `vsquish'
	local i 1
	forvalues eq = 1/`neq' {
		di in smcl "{text}  {hline `hllen'}
		if `"`eqname`eq''"' != `"model"'      &			///
		   `"`eqname`eq''"' != `"_"'          &			///
		   `"`eqname`eq''"' != `"`e(depvar)'"' {
		    di in smcl "  {result}{lalign `varwidth':`eqname`eq''}"
		}

					// Loop over covariates in equations
					// and display
		local vsquish "vsquish"
		forvalues k = 1/`k`eq'' {
			local zt = `b'[1,`i'] / sqrt(`V'[`i',`i'])
			if "`type'" == "z" {
				local P  =  2*normal(-abs(`zt'))
			}
			else	local P = 2*ttail(e(df_r), abs(`zt'))

			_ms_display, eq(#`eq') el(`k') width(`varwidth') ///
				     novbar nov1bar indent(2) `first' 	 ///
				     `vsquish' `msopts'
			local note `"`r(note)'"'

			if r(output) {
			    if `"`note'"' == `""' {
				local bi `b'[1,`i']
				local se = sqrt(`V'[`i',`i'])

				di in smcl "{result}"			 ///
				   " {space `lnspace'}"   `format' `bi'	 ///
				   "  {space `lnspace'}" `format' `se'	 ///
				   "{text}   {space `lnspace'}({result}" ///
				   `format' (`bi' - `ci_mult'*`se')	 ///
				   ","					 ///
				   `format' (`bi' + `ci_mult'*`se')	 ///
				   "{text})"
			    }
			    else {
				di in smcl "{result}"			///
				   " {space `lnspace'}" `notefmt' `"`note'"'
			    }

			    local first
			    local vsquish `vsquish_h'
			}
			else {
			    if r(first) {
				 local first first
			    }
			}

			local ++i
		}

	}

	di in smcl "{text}  {hline `hllen'}

					// Loop over auxilary parameters
	forvalues aux = 1/0`e(k_aux)' {
		local eq = `neq' + `aux'

		local bi `b'[1,`i']
		local se = sqrt(`V'[`i',`i'])

		di in smcl "{text}  {ralign `varwidth':\\`eqname`eq''}  " _c

		di in smcl "{result}"			 ///
		   " {space `lnspace'}"   `format' `bi'	 ///
		   "  {space `lnspace'}" `format' `se'	 ///
		   "{text}   {space `lnspace'}({result}" ///
		   `format' (`bi' - `ci_mult'*`se')	 ///
		   ","					 ///
		   `format' (`bi' + `ci_mult'*`se')	 ///
		   "{text})"

		local ++i
	}

	if 0`e(k_aux)' > 0 {
		di in smcl "{text}  {hline `hllen'}
	}

					// Footer
	di "{text}Number of observations = `e(N)'"
	if "`e(rmse)'" != "" {
		di "Root Mean Squared Error = "`format' `e(rmse)'
	}

end

					// Parse format
program parsefmt


	gettoken fmtmac 0 : 0
	gettoken widmac 0 : 0
	gettoken colon  0 : 0

	local 0 `0'
	if `"`0'"' == `""' {
		local 0 "%5.1f"
	}

	gettoken pct fmt : 0 , parse("%")
	if `"`pct'"' == `""' {
		local fmt `pct'
	}

	gettoken wid : fmt , parse(".")
	capture confirm integer number `wid'
	if _rc {
		di as error "invalid %format"
		exit 120
	}

	local fmt `"%`fmt'"'

	capture noisily quietly di `fmt' 2

	c_local `fmtmac' `"`fmt'"'
	c_local `widmac' `wid'

end
