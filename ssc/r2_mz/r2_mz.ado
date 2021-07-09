*! version 1.0.1 January 04, 2012 @ 12:30:00 DE
*! Compute McKelvey & Zavoina's R2

// Main Program
// ------------

cap program drop r2_mz
program define r2_mz, eclass
version 11.1

	quietly {

		// Intro
		// -----

		if "`verbose'" != "" local noisily noisily

		// Check user input
		if "`e(cmd)'"=="" {
			noi display "{err}last estimates not found"
			exit 301
		}

		if !inlist("`e(cmd)'","xtmelogit","xtlogit","xtprobit","logit","logistic","probit") {
			noi display "{err}-r2_mz- does not work with `e(cmd)'"
			exit 198
		}

		// Declarations
		tempname Var_u Var_ut R2_MZ retyp Var_R
                  tempvar Xb_ori

		// Get some information from user command
		local eq1name: colfullnames e(b)
		gettoken eq1name:eq1name, parse(":")

		if inlist("`e(cmd)'","xtmelogit") {
			scalar `retyp' = 1
			local ivars `e(ivars)'
		}
		else if inlist("`e(cmd)'","xtlogit","xtprobit") {
			scalar `retyp' = 2
			local ivars `e(ivar)'
		}

		if inlist("`e(cmd)'","logit","logistic","xtlogit","xtmelogit") {
			scalar `Var_R' = _pi^2/3
		}
		else if inlist("`e(cmd)'","probit","xtprobit") {
			scalar `Var_R' = 1
		}


		// Random effects variance (for McKelvey-Zavoina R2)
		// -------------------------------------------------

                  if inlist("`e(cmd)'","xtmelogit","xtlogit","xtprobit") {
		         mata: r2_mz_var_u()
	         }
	         else {
	                  sca `Var_ut' = 0
	         }
		predict double `Xb_ori', xb
		sum `Xb_ori'
		drop `Xb_ori'
		scalar `R2_MZ' = r(Var)/(`Var_ut' + `Var_R' + r(Var))

                  }

	// Output
	// ------

	// Header
	di "{txt}{ralign 28:McKelvey & Zavoina's R2 = }{res}" %6.0g `R2_MZ'

	// Return results
	// --------------

	ereturn scalar r2_mz = `R2_MZ'
         ereturn scalar deviance = -2*e(ll)

  	// Variance of Random effects
         if inlist("`e(cmd)'","xtmelogit","xtlogit","xtprobit") {
         	ereturn scalar Var_u = `Var_ut'
                  if inlist("`e(cmd)'","xtmelogit") {
	                  forv i = 1/`:word count `ivars'' {
		                  ereturn scalar Var_u`i' = `Var_u'[1,`i']
         	         }
         	}
         }
end
