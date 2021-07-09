*! version 1.0.1
*! Forward-Orthogonal Deviations Finder 
*! for the Command xtendothresdpd 
*! Diallo Ibrahima Amadou
*! All comments are welcome, 15Apr2020



capture program drop _gxtendothresdpdfod
program _gxtendothresdpdfod
            version 16.0
			syntax newvarname =/exp [if] [in] [, BY(varlist) REScale]
			tempvar touse
			quietly {
					mark `touse' `if' `in'
					sort `touse' `by', stable
					by `touse' `by': egen `typlist' `varlist' = xtendothresdpdfmoy(`exp') if `touse'
					replace `varlist' = (`exp') - `varlist' if `touse'
					if "`rescale'" != "" {
							tempvar nobs
							by `touse' `by': egen `typlist' `nobs' = count(`exp') if `touse'
							by `touse' `by': replace `varlist' = `varlist' * sqrt((`nobs' - sum((`exp') < .)) / (`nobs' - sum((`exp') < .) + 1)) if `touse'
					}
			}
end


