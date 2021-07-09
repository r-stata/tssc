*! version 1.0.1
*! Conversion Finder 
*! for the Command xtendothresdpd 
*! Diallo Ibrahima Amadou
*! All comments are welcome, 15Apr2020



capture program drop xtendothresdpdconv
program xtendothresdpdconv, rclass sortpreserve
            version 16.0
			quietly tsset
			syntax varlist(numeric ts) [if] [in] [, REScale REPLACE ]
            tempvar touse
            mark `touse' `if' `in'
			quietly tsset
			local panelvar = r(panelvar)
			local timevar  = r(timevar)	
			local bypanel ", by(`panelvar')"
			quietly {
					local mylisty
					foreach xvz of varlist `varlist' {
									capture confirm new var `xvz'_fodv
									if _rc == 110 & "`replace'" != "" {
																	drop `xvz'_fodv
									}
									egen double `xvz'_fodv = xtendothresdpdfod(`xvz') if `touse' `bypanel' `rescale'
									local mylisty  `"`mylisty' `xvz'_fodv"'
					}
			}
			return local origvarlist   "`varlist'"
			return local convervarlist "`mylisty'"

end


