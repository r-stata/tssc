*! version 1.0.0  //  Ariel Linden 10may2019 

program define svalue, rclass
version 11.0

	syntax anything ,				///
		[							///
		FIGure   FIGure2(str asis)	/// allow figure options
		SAVing(string asis) * 		/// save the file
		]

		quietly {
	
			numlist "`anything'", max(1)
			local pval = `anything'
		
			preserve
			clear
		
			// * set obs to fit data * //
			local obs = 1 + ceil((1 - 0)/ 0.0001)
			set obs `obs'

			// * Generate P-value range from 1 to 0.0001 * //
			gen plev = 0.0001 + (_n - 1) * 0.0001
			label var plev "P-values"
			drop if (plev > 1)
				
			// * Generate S-values * //
			gen sval = -log( plev)/log(2)
			label var sval "S-values"
	
			// * retrieve sval for the specified p-value * //
			sum sval if float(plev) == float(`pval'), meanonly
			local S = round(r(mean), 0.01)
		
			// * set position of marker label * //
			if inrange(`pval', 0.80,0.94) {
				local pos (12)
			}
			else if `pval' > 0.94 { 
				local pos (11)
			}	
			else local pos (2)
		
			tw(line sval plev )(scatteri `S' `pval' `pos' "S-value: (`S')", mlabgap(*3)), ylabel(0(2)14) xlabel(0(.1)1.0, format("%4.2f")) ///
			ytitle(S-value) xtitle(P-value) legend(off) `figure2'

			// * Saving file * //  
			if `"`saving'"'!="" {
				save `saving'
			}
						
		} // end quietly	
end		
