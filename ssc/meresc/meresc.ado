*! version 1.0.2 January 21, 2012 @ 12:30:00 DE
*! Rescale results from xtmelogit (and others)

// Main Program
// ------------

program define meresc, eclass
version 11.1
	syntax [, Verbose]

	quietly {

		// Intro
		// -----

		if "`verbose'" != "" local noisily noisily

		// Check user input
		if "`e(cmd)'"=="" {
			noi display "{err}last estimates not found"
			exit 301
		}
		if "`e(cmd)'" == "meresc" {
			noi display "{err}Model already rescaled"
			exit 198
		}

		if !inlist("`e(cmd)'","xtmelogit","xtlogit","xtprobit") {
			noi display "{err}meresc does not work with `e(cmd)'"
			exit 198
		}

		// Declarations
		tempname Var_u Var_ur Var_R Var_u0 Var_Flevel1 usermodel VSF Var_Fresc retyp  ///
		         R2_MZ
		tempvar Xb_ori Xb Xb_resc Busermodel

		// Get some information from user command
		matrix `Busermodel' = e(b)
		local eq1name: colfullnames e(b)
		gettoken eq1name:eq1name, parse(":")

		local cmdline `e(cmdline)'
		gettoken cmd userspec: cmdline

		InspectUserCommand `userspec'
		local fe_indepvarlist `r(fe_indepvarlist)'
		local fe_weight `r(fe_weight)'
		local fe_options `r(options)'

		if "`e(cmd)'" == "xtmelogit" {
			local ivars `e(ivars)'
			local noheader noheader
			forv i=1/`:word count `ivars'' {
				local re`i'_indepvarlist `r(re`i'_indepvarlist)'
				local re`i'_options `r(re`i'_options)'
				local last `i'
				scalar `retyp' = 1
			}
		}
		else if inlist("`e(cmd)'","xtlogit","xtprobit") {
			local ivars `e(ivar)'
			scalar `retyp' = 2
		}

		GetReportingOptions, `fe_options' `re`last'_options'
		local reporting `r(reporting)'

		// Lowest level residual variance
		// ------------------------------

		if inlist("`e(cmd)'","xtmelogit","xtlogit") scalar `Var_R' = _pi^2/3
		else if "`e(cmd)'" == "xtprobit" scalar `Var_R' = 1

		// Random effects variance (for McKelvey-Zavoina R2)
		// -------------------------------------------------

		tempname Var_ut
		mata: meresc_var_u()
		predict double `Xb_ori', xb
		sum `Xb_ori'
		drop `Xb_ori'
		scalar `R2_MZ' = r(Var)/(`Var_ut' + `Var_R' + r(Var))


		// Second level intercept variance of Null Model
		// ---------------------------------------------

		estimates store `usermodel'

		// xtmelogit
		if inlist("`e(cmd)'","xtmelogit","xtmepoisson") {
			local i 1
			foreach var of local ivars {
				local rcpart `rcpart' || `var': , `re`i++'_options'
			}
			`noisily' `e(cmd)' `e(depvar)' if e(sample) `rcpart' // from(`Busermodel', skip)
			scalar `Var_u0' = exp(`=_b[lns1_1_1:_cons]')^2
		}

		// xtlogit/xtprobit
		else if inlist("`e(cmd)'","xtlogit","xtprobit") {
			if "`options'" == "" local iis i(`ivars')
			`noisily' `e(cmd)' `e(depvar)' if e(sample) `weight'  ///
			  , `options' `iis' // from(`Busermodel', skip)
			scalar `Var_u0' = exp(_b[/lnsig2u]/2)^2
		}
		estimates restore `usermodel'

		// Systematic variance of model with level-1 vars only
		// ---------------------------------------------------

		// Find level 1 variables
		if "`fe_indepvarlist'" != "" {
			CheckVars `fe_indepvarlist' if e(sample), ivars(`ivars')
			local fe_level1vars `r(level1vars)'
		}
		macro drop _rcpart
		local i 1
		foreach var of local ivars {
			CheckVars `re`i'_indepvars' if e(sample), ivars(`var')
			local rcpart `rcpart' || `var': `r(level1vars)', `re`i++'_options'
			local re_level1vars `re_level1vars' `r(level1vars)'
		}
		local level1_vars `fe_level1vars' `re_level1vars'
		local level1_vars: list uniq level1_vars

		// xtmelogit
		if inlist("`e(cmd)'","xtmelogit","xtmepoisson") {
			`noisily' `e(cmd)' `e(depvar)' `fe_level1vars' if e(sample)  ///
			  , `fe_options' ///
			  `rcpart' from(`Busermodel', skip)
		}

		// xtlogit/xtprobit
		else if inlist("`e(cmd)'","xtlogit","xtprobit") {
			if "`options'" == "" local iis i(`ivars')
			`noisily' `e(cmd)' `e(depvar)' `fe_level1vars'  ///
			  if e(sample), `fe_options' `iis' from(`Busermodel', skip)
		}

		// Systematic model variance
		tempvar Xb
		predict double `Xb', xb
		sum `Xb'
		scalar `Var_Flevel1' = r(Var)
		estimates restore `usermodel'

		// Rescale (Call Mata Function)
		// ----------------------------

		mata: meresc(`=sqrt((`Var_u0'+`Var_R')/(`Var_u0'+`Var_R'+`Var_Flevel1'))')

		ereturn repost b=_b V=_V

	}

	// Output
	// ------

	// Header
	di _n "{txt}Rescaled results for {res}`e(cmd)'" ///
	  _n _col(31) ///
	  "{txt}{ralign 17:McKelvey & Zavoina's R2                =}{res}" ///
	  %8.0g `R2_MZ'   ///
	  _n _col(31) ///
	  "{txt}{ralign 17:Total Variance of intercept only model =}{res}" ///
	  %8.0g `=`Var_R' + `Var_u0'' ///
	  _n _col(31) ///
	  "{txt}{ralign 17:1st level linar predictor variance     =}{res}" ///
	  %8.0g `=`Var_Flevel1'' ///
	  _n _col(31) ///
	  "{txt}{ralign 17:1st level residual variance (rescaled) =}{res}" ///
	  %8.0g `=  `Var_R' * (`Var_u0'+`Var_R')/(`Var_u0'+`Var_R'+`Var_Flevel1')' ///
	  _n _col(31) ///
	  "{txt}{ralign 17:Scale correction factor                =}{res}" ///
	  %8.0g `=sqrt((`Var_u0'+`Var_R')/(`Var_u0'+`Var_R'+`Var_Flevel1'))'

	// Table of coefficients
	`e(cmd)', `noheader' `reporting'


	// Return results
	// --------------

	ereturn scalar SCF =sqrt((`Var_u0'+`Var_R')/(`Var_u0'+`Var_R'+`Var_Flevel1'))
	ereturn scalar VCF =(`Var_u0'+`Var_R')/(`Var_u0'+`Var_R'+`Var_Flevel1')
	ereturn scalar Var_Flevel1 = `Var_Flevel1'

	// Variance of Random effects
	forv i = 1/`:word count `ivars'' {
		ereturn scalar Var_u`i' = `Var_u'[1,`i']
	}

	ereturn scalar Var_R = `Var_R'
	ereturn scalar Var_u0 = `Var_u0'

	// Rescaled Variance of Random effects
	forv i = 1/`:word count `ivars'' {
		ereturn scalar Var_u`i'resc = `Var_ur'[1,`i']
	}

	ereturn scalar Var_Rresc 			///
	  = `Var_R' * (`Var_u0'+`Var_R')/(`Var_u0'+`Var_R'+`Var_Flevel1')

	ereturn scalar r2_mz = `R2_MZ'
	ereturn scalar deviance = -2*e(ll)

	ereturn local title Rescaled results for `e(cmd)'
	ereturn local cmd meresc
	ereturn local _estimates_name ""

end

// Make list of level-1 variables
// ------------------------------

program define CheckVars, rclass
version 11.1
	syntax [varlist(default=none fv)] [if], [ivars(varlist)]
	marksample touse

	quietly {
		tempvar diff
		gen byte `diff' = .
		foreach var in `varlist' {
			local intind = strpos("`var'","#") > 0
			if `intind'==1 {
				fvrevar `var', list
				local termvars `r(varlist)'
				local terms = 0
				local level1terms = 0
				foreach tvar in `termvars' {
					local terms = `terms' + 1
					bysort `touse' `ivars' (`tvar'): ///
					  replace `diff' = `tvar'[1] - `tvar'[_N] if `touse'
					summarize `diff' if `touse', meanonly
					if r(mean) != 0 local level1terms = `level1terms' + 1
				}
				if `terms'==`level1terms' local level1vars `level1vars' `var'
			}
			else {
				fvrevar `var', list
				local usevar `r(varlist)'
				bysort `touse' `ivars' (`usevar'): 	///
				  replace `diff' = `usevar'[1] - `usevar'[_N] if `touse'
				summarize `diff' if `touse', meanonly
				if r(mean) != 0 local level1vars `level1vars' `var'
			}
		}
		return local level1vars `level1vars'
	}
end


// Break UserCommand into bits and pieces
// --------------------------------------

program define InspectUserCommand, rclass
version 11.1
	gettoken fe_part rest: 0, parse("||")
	TraceCommand `fe_part'

	local fe_varlist `r(varlist)'
	local depvar `e(depvar)'
	local fe_indepvarlist: list fe_varlist - depvar
	return local fe_indepvarlist `fe_indepvarlist'
	return local fe_if `r(if)'
	return local fe_in `r(in)'
	return local fe_weight `r(weight)'
	return local fe_options `r(options)'

	local i 1
	while "`rest'" != "" {
		gettoken re_part rest: rest, parse(":")
		gettoken re_part rest: rest, parse("||")
		local re_part: subinstr local re_part ":" ""
		if "`re_part'" != "" {
			TraceCommand `re_part'
			return local re`i'_indepvarlist `r(varlist)'
			return local re`i'_options `r(options)'
			return local relast_options `r(options)'
			local i = `i'+1
		}
	}
end

// A little helper for InspectUserCommand
// --------------------------------------

program define TraceCommand, rclass
version 11.1
	syntax [varlist(default=none fv ts)]  ///
	  [if] [in] [fweight pweight aweight iweight] [, *]
	return local varlist `varlist'
	return local if `if'
	return local in `in'
	return local weight [`weight'`wexp']
	return local options `options'
end


// Get Reporting Options from User Command
// ---------------------------------------

program define GetReportingOptions, rclass
	syntax [ , Level(cilevel) or VARiance NOREetable NOFEtable ESTMetric  ///
	  NOHEADer NOGRoup NOLRtest NOOMITted vsquish NOEMPTYcells BASElevels  ///
	  ALLBASElevels	* ]


	local reporting 					///
	  level(`level') `or' `variance' `noretable' `nofetable' `estmetric'  ///
	  `nogroup' `nolrtest' `noomitted' `vsquish' `noemptycells' 	///
	  `baselevels' `allbaselevels' // noheader is ignored!

	return local reporting `reporting'
end
