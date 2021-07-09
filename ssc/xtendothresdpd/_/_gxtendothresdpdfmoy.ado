*! version 1.0.1
*! Forward Mean Finder 
*! for the Command xtendothresdpd 
*! Diallo Ibrahima Amadou
*! All comments are welcome, 15Apr2020



capture program drop _gxtendothresdpdfmoy
program _gxtendothresdpdfmoy
            version 16.0
			syntax newvarname =/exp [if] [in] [, BY(varlist) REScale]
			tempvar touse nobs
			quietly {
				mark `touse' `if' `in'
                sort `touse' `by', stable
                by `touse' `by': egen `typlist' `varlist' = total(`exp') if `touse'
                by `touse' `by': egen `typlist' `nobs' = count(`exp') if `touse'
                if "`rescale'" == "" {
								by `touse' `by': replace `varlist' = (`varlist' - sum(`exp')) / (`nobs' - sum((`exp') < .)) if `touse'
                }
                else {
								by `touse' `by': replace `varlist' = (`varlist' - sum(`exp')) / sqrt(`nobs' - sum((`exp') < .)) if `touse'
                }
			}
end


		