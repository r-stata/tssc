*! version 1.2.0 03oct2014  Richard Williams, rwilliam@nd.edu
* Simplify computing marginal effects after multiple outcome commands.
* Saves mfx output from any command in format easily usable by 
* post-estimation table formatting commands like outreg2 and estout.
* 1.0.0 - Original release - April 26, 2006
* 1.1.0 - Now works with the varlist option of mfx - June 18, 2007
* 1.2.0 - gologit29 added to the multiple outcome list


program define mfx2, eclass
	version 8.2
	local oktype = cond(`c(stata_version)' < 9, ///
		"integer `c(level)'", "cilevel")
	syntax [if] [in] [, Level(`oktype') Replace NOLabel NOSe ///
		stub(name) PREDict(string) NOLOG /// 
		Multiple Single trustme * ]
	
	// trustme lets the user override what the program thinks is correct.
	// If the user is wrong though, fatal errors or incorrect results
	// may follow.
	if "`trustme'"=="" {
		local trust 0
	}
	else {
		local trust 1
	}
	
	local cmd `e(cmd)'
	if "`cmd'"=="" & !`trust' {
		display as error "last estimates not found"
		exit 301
	}
	
	if "`multiple'"!="" & "`single'" != "" {
		display as error "You cannot specify both single and multiple"
		exit 198
	}
	
	// These are programs that do not work with mfx2
	local cursed asmprobit anova clogit nlogit gologit
	local banned: list cmd & cursed
	if "`banned'"!="" & !`trust' {
		display as error "Sorry. " as yellow "`cmd'" as error " is not currently supported by mfx2."
		display as error "Check the help for " as yellow "`cmd'" as error " to see if there are other alternatives."
		display as error "Or, use the " as yellow "trustme " as error "option if you want to try anyway."
		exit 198
		display
	}
	
	// Play or Replay the results.  The use of estimates replay
	// makes the program call itself for the replay.
	if replay() & "`e(cmd)'"=="mfx2" {
		Replay , level(`level') 
		exit
	}
		

	// Classify programs as multiple-outcome or single/binary/count outcome.
	// Add to this list as more programs get classified
	local multprog ologit oprobit mlogit mprobit slogit
	local multprog `multprog' oglm gologit2 goprobit gologit29
	
	// Classify programs as multinomial or single outcomes
	local multicmd: list cmd & multprog
	if "`multicmd'"!="" {
		local multinomial 1
	}
	else {
		local multinomial 0
	}
	
	// User can override
	if "`multiple'"!="" local multinomial 1
	// Determine if a command not specified above produces multiple outcomes
	if "`single'"!="" local multinomial 0
	
	if "`stub'"=="" {
		local stub `e(cmd)'
	}
	if "`nolog'" =="" {
		local quietly "noisily"
	}
	else {
		local quietly "quietly"
	}
	
	tempname coef 
	_estimates hold `coef', restore copy
	
	* Save scalars
	local scalars : e(scalars)
	foreach el in `scalars' {
		tempname s`el'
		scalar `s`el'' = e(`el')
	}
	
	local y `e(depvar)'
	local xcmd `e(cmd)'


	tempname cat mfx_b mfx_se mfx_V mfx_X xmfx semfx mfx_se2 mfxx

	`quietly' {
		// For multinomial, get the categories of the DV; transpose matrix
		if `multinomial' {
			display
			display as yellow "Frequencies for `y'..."
			display
			tab `y' if e(sample), matrow(`cat')
			matrix `cat' = `cat''
			local numcat = r(r)
		}
		
		if `multinomial' {
			local endcat `numcat'
		}
		else {
			local endcat 1
		}
		

		// Compute marginal effects
		forval i = 1/`endcat' {
			if `multinomial' {
				local xcat = `cat'[1,`i']
				display
				display as yellow "Computing marginal effects after `cmd' for `y' == `xcat'..."
				display
				mfx compute `if' `in', predict(`predict' o(`xcat')) level(`level') `options' `nose'
			}
			else {
				display
				display as yellow "Computing marginal effects after `cmd' for `y'..."
				display
				mfx compute `if' `in', predict(`predict') level(`level') `options' `nose'
			}
			local mfxtype `=e(Xmfx_type)'
			matrix `xmfx' = e(Xmfx_`mfxtype')
			matrix `mfxx' = e(Xmfx_X)
			if "`nose'"=="" {
				matrix `semfx' = e(Xmfx_se_`mfxtype')
			}
			else {
				matrix `semfx' = `xmfx' * 0
			}

			if `multinomial' {
				matrix coleq `xmfx' = eq`i'
				matrix coleq `semfx' = eq`i'
			}
			
			matrix `mfx_b' = nullmat(`mfx_b'), `xmfx'
			matrix `mfx_se' = nullmat(`mfx_se'), `semfx'
			matrix `mfx_X' = nullmat(`mfx_X'), `mfxx'
		}
		display
		display as yellow "Preparing final results..."
		display
	}
	// Use Y value labels if requested for multiple-outcome commands
	if `multinomial' & "`nolabel'"=="" Use_Value_Labels, b(`mfx_b') se(`mfx_se') x(`mfx_X') cat(`cat') y(`y')
	
	// This code added in version 1.1 of mfx2
	// Special code needed if some elements are missing, e.g. varlist option has been used
	if matmissing(`mfx_b') {
		tempname b_temp se_temp x_temp
		local ncols = colsof(`mfx_b')
		local names : colfullnames `mfx_b'
		forval i = 1/`ncols' {
			if !missing(el(`mfx_b', 1, `i')) {
				matrix `b_temp' = nullmat(`b_temp'), `mfx_b'[1, `i']
				matrix `se_temp' = nullmat(`se_temp'), `mfx_se'[1, `i']
				matrix `x_temp' = nullmat(`x_temp'), `mfx_X'[1, `i']
				local xname: word `i' of `names'
				local xnames `xnames' `xname'
			}
		}
		matrix colnames `b_temp' = `xnames'
		matrix colnames `se_temp' = `xnames'
		matrix colnames `x_temp' = `xnames'
		matrix `mfx_b' = `b_temp'
		matrix `mfx_se' = `se_temp'
		matrix `mfx_X' = `x_temp'
	}
	// End of special code added in version 1.1


	// Create V matrix.  Note that only the variances are right. Missing elements will be
	// replaced by 0.
	tempname se2
	matrix `se2' = `mfx_se'
	local missing = matmissing(`se2')
	if `missing' {
		forval i = 1/`=colsof(`se2')' {
			if `se2'[1,`i'] >= . matrix `se2'[1,`i'] = 0
		}
	}
	matrix `mfx_V' = diag(`se2')' * diag(`se2')
	
	// Temporarily create new e(b), e(V)
	tempname b V x
	matrix `b' = `mfx_b'
	matrix `V' = `mfx_V'
	matrix `x' = `mfx_X'


	tempvar touse
	gen `touse' = e(sample)
	ereturn post `b' `V', esample(`touse')
	* Restore scalars
	foreach el in `scalars' {
		eret scalar `el' = `s`el''
	}
	if `multinomial' ereturn matrix cat = `cat'
	ereturn local depvar `y'
	local title Marginal effects after `xcmd'
	ereturn matrix mfx_X `x'
	ereturn local cmd "mfx2"
	capture estimates drop `stub'_mfx
	estimates store `stub'_mfx, title(`title')
	
	
	_estimates unhold `coef'
	// Add mfx values
	ereturn matrix mfx_b_`mfxtype' `mfx_b'
	ereturn matrix mfx_se_`mfxtype' `mfx_se'
	ereturn matrix mfx_X `mfx_X'

	capture estimates drop `stub'_coef
	estimates store `stub'_coef
	
	if "`replace'"=="replace" {
		quietly estimates restore `stub'_mfx
		display
		display as yellow "mfx results are now active.  Original results are stored as `stub'_coef."
	}
	else {
		display
		display as yellow "Original results are now active. mfx results are stored as `stub'_mfx."
	}
	
	// Print out results
	estimates replay `stub'_mfx, level(`level')
	
end

************************

program Replay
	syntax, level(string)
	ereturn display , level(`level')
end

************************
program Use_Value_Labels, eclass
	// Adapted from gologit2

	syntax, b(name) se(name) x(name) cat(name) y(varname)

	// Use Y value labels if user has requested them
	
	local M = colsof(`cat')
	local Numeqs = `M'
	tempname Y_Values
	matrix `Y_Values' = `cat'
	*local eqnames `e(eqnames)'
	// Numx2 is same as Numx for marginal effects
	local Numx2 = colsof(`b')/ `M'
	
	// Retrieve the Y value labels, turn into equation names
	forval i = 1/`M' {
		local j = `Y_Values'[1,`i']
		local vlabel: label(`y') `j' 32
		// Replace characters that cause problems
		local vlabel: subinstr local vlabel "." "_", all
		local vlabel: subinstr local vlabel ":" "_", all
		local vlabel: subinstr local vlabel "$" "_", all
		local vlabel: subinstr local vlabel " " "_", all

		// base category (i.e. highest Y value) is separate 
		// from the equation names
		if `i'==1 {
			local new_eqnames `"`"`vlabel'"'"'
		}
		else  {
			local new_eqnames `"`new_eqnames' `"`vlabel'"'"'
		}
	}
	// Duplicate names screw up the printout
	local testnames: list dups new_eqnames
	if "`testnames'"!="" {
		display as error "When using value labels, each " ///
			"value label for the DV must be unique. "
		display as error "Equations will instead be " ///
			"labeled eq1, eq2, etc."
		exit
	}
			
	// Have to repeat equation name for every x
	forval i = 1/`Numeqs' {
		local vlabel: word `i' of `new_eqnames'
		forval j = 1/`Numx2' {
			local vlabels `"`vlabels' `"`vlabel'"'"'
		}
	}
	// Replace the current b, se matrices
	capture matrix coleq `b' = `vlabels'
		if _rc !=0 {
		display as error "There is a problem with your value labels."
		display as error "Equations will instead be labeled eq1, eq2, etc."
		exit
	}
	matrix coleq `se' = `vlabels'
	matrix coleq `x' = `vlabels'

end
		
