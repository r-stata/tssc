*! version 1.0.0  //  Ariel Linden 30apr2019 

program define cifunction, rclass
version 11.0

	syntax anything ,				///
		SE(numlist min=1 >0)		/// std err
		[							///
		DF(numlist max=1)			/// degrees of freedom for -regress-
		eform						/// exponentiated coefficient
		FIGure   FIGure2(str asis)	/// allow figure options
		SAVing(string asis) * ]

	quietly {
	
		numlist "`anything'", min(1)
		tokenize `anything', parse(" ")
		local kb : list sizeof anything
		local kse : list sizeof se

		// Error checking //
		if `kb' != `kse' {
			di as err "the specified number of coefficients and standard errors must be the same" 
			exit 198
		}

		preserve
		clear
	
		// * Generate CI range from 0 to 99.999 (10,000 values) * //
		local obs = 1 + ceil((99.99 - 0)/ 0.01)
		set obs `obs'
		gen cilev = 0 + (_n - 1) * 0.01
		label var cilev "CI sequence from 0 to 99.99"
		drop if (cilev > 99.99)

		// * Generate P-value range from 1 to 0.0001 * //
		gen plev = 1 - (_n - 1) * .0001
		label var plev "P-value sequence from 0.0001 to 1.0"
		
		// * Generate S-value * //
		gen sval = -log( plev)/log(2)
		label var sval "S-values for respective -plev- value"
		
		// * set up CIs * //
		forvalues i = 1/`kb' {
			gen lcl`i' = .
			label var lcl`i' "lower confidence limits for estimate `i'"
			gen ucl`i' = .
			label var ucl`i' "upper confidence limits for estimate `i'"
		}

		local n = 1

		levelsof cilev, local(levels)
		
		// * Loop over user-specified b and se * //
		forvalues e = 1/`kb' { 
			local b : word `e' of `anything'
			local s : word `e' of `se'
				
			// * Loop over lcl/ucl levels (ranging from 0 to 99.99) * //
			foreach i of local levels {
	
				if `n' > _N local n = 1
				
				local levelci = cilev[`n'] * 0.005 + 0.50
				local mlevelci = 1 - `levelci'

				// * linear model * //
				if "`eform'"  == "" {
					// * t-distribution * //
					if "`df'" != "" {
						local lclF = `b' - invttail(`df',`mlevelci') * `s'
						local uclF = `b' + invttail(`df',`mlevelci') * `s'
					}
					// * z-distribution * //
					else if "`df'" == "" {
						local lclF = `b' - invnorm(`levelci') * `s'
						local uclF = `b' + invnorm(`levelci') * `s'
					}
				} // end eform == !	
				// * exponentiated coefficients * //
				else if "`eform'"  != "" {
					// * t-distribution * //
					if "`df'" != "" {
						local linse = `s' / `b'
						local lclF = exp(ln(`b') - invttail(`df',`mlevelci') * `linse')
						local uclF = exp(ln(`b') + invttail(`df',`mlevelci') * `linse')
					}
					// * z-distribution * //
					else if "`df'" == "" {
						local linse = `s' / `b'
						local lclF = exp(ln(`b') - invnorm(`levelci') * `linse')
						local uclF = exp(ln(`b') + invnorm(`levelci') * `linse')
					}	
				} // end eform != ""
			
				replace lcl`e' = `lclF' in `n'
				replace ucl`e' = `uclF' in `n'
				local n = `n' + 1	
			} // end local levels
		} // end foreach effect

		// * Set-up for plots * //
		
		if "`eform'"  == "" local xl = 0
		else local xl = 1	
		
		// * Single estimate * //
		if `kb' == 1 {
			tw(rarea lcl1 ucl1 cilev, horizontal color(%50))(rarea lcl1 ucl1 plev, yaxis(2) horizontal color(%50)), xline(`xl',lstyle(foreground)) xtitle("") ///
			ytitle(Confidence Level) ylabel(0(10)100, angle(0) axis(1)) ytitle(P-value, axis(2)) yscale(reverse) ///
			ylabel(1(0.10)0, axis(2) format("%4.2f") angle(0)) legend(off) `figure2'
		}
		
		// * Multiple estimates * //
		else if `kb' > 1 {
			forvalues i = 2/`kb' {
				local gx`i' "(rarea lcl`i' ucl`i' plev, horizontal color(%20) yaxis(2))"
				local g `g' `gx`i''
			}	
			tw(rarea lcl1 ucl1 cilev, horizontal color(%20)) `g' , xline(`xl', lstyle(foreground)) xtitle("") ///
			ytitle(Confidence Level) yscale(reverse) ylabel(0(10)100, angle(0))  ytitle(P-value, axis(2)) yscale(reverse) ///
			ylabel(1(0.10)0, axis(2) format("%4.2f") angle(0)) ///
			legend(size(small) symxsize(9) symysize(3) position(4) cols(1) region(fcolor(none) lwidth(none))) `figure2'

			
		} // end `kb' > 1

		// * Saving file * //  
		if `"`saving'"'!="" {
			save `saving'
        }


	} // end quietly
	
end
