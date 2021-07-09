*** version 2.1.2 5August2019
*** contact information: plus1@sogang.ac.kr

program nscale
	version 10
	syntax varlist [, GENerate(namelist) PREfix(name) Missing(numlist max=1) UP DOWN Reverse Tab noPOSTfix]

quietly {

	if "`postfix'" == "nopostfix" {

		if "`generate'" != "" | "`prefix'" != "" {

			noisily Error 198 "option generate or prefix may not be combined with nopostfix"

		}
		else {
		* gen(namelist) and pre(name): off
			if "`missing'" != "" {

				foreach var in `varlist' {
					if "`up'" != "" & "`down'" != "" {
						noisily Error 198 "option up may not be combined with down"
					}
					else if "`up'" != "" & "`down'" == "" {
						summarize `var' if `var' < `missing'
						replace `var' = (`var' - r(min))/(r(max) - r(min)) if `var' < `missing'
						replace `var' = . if `var' >= `missing'
					}
					else if "`up'" == "" & "`down'" != "" {
						summarize `var' if `var' > `missing'
						replace `var' = (`var' - r(min))/(r(max) - r(min)) if `var' > `missing'
						replace `var' = . if `var' <= `missing'
					}
					else {
						summarize `var' if `var' != `missing'
						replace `var' = (`var' - r(min))/(r(max) - r(min)) if `var' != `missing'		
						replace `var' = . if `var' == `missing'
					}
					if "`reverse'" != "" {
						replace `var' = 1 - `var'
					}
				}

			}
			else {
			* m(#): off
				if "`up'" != "" | "`down'" != "" {
					noisily Error 198 "option up or down requires option missing to be set"
				}
				else {
					foreach var in `varlist' {
						summarize `var'
						replace `var' = (`var' - r(min))/(r(max) - r(min))
						if "`reverse'" != "" {
							replace `var' = 1 - `var'
						}
					}
				}

			}

			foreach var in `varlist' {
					label values `var' .
			}

			if "`tab'" != "" {
				noisily tab1 `varlist'
			}

		}

	}
	else {

		if "`generate'" != "" & "`prefix'" != "" {

			noisily Error 198 "option generate may not be combined with prefix"

		}
		else if "`generate'" != "" & "`prefix'" == "" {

			local n_vars : word count `varlist'
			if `n_vars' < `: word count `generate'' {
				noisily Error 103 "option generate():	too many names specified"
			}
			else if `n_vars' > `: word count `generate'' {
				noisily Error 103 "option generate():	too few names specified"
			}
			forval i = 1/`n_vars' {
				local ovar : word `i' of `varlist'
				local nvar : word `i' of `generate'
				clonevar `nvar' = `ovar'
				label values `nvar' .
			}

			if "`missing'" != "" {

				foreach var in `generate' {
					if "`up'" != "" & "`down'" != "" {
						noisily Error 198 "option up may not be combined with down"
					}
					else if "`up'" != "" & "`down'" == "" {
						summarize `var' if `var' < `missing'
						replace `var' = (`var' - r(min))/(r(max) - r(min)) if `var' < `missing'
						replace `var' = . if `var' >= `missing'
					}
					else if "`up'" == "" & "`down'" != "" {
						summarize `var' if `var' > `missing'
						replace `var' = (`var' - r(min))/(r(max) - r(min)) if `var' > `missing'
						replace `var' = . if `var' <= `missing'
					}
					else {
						summarize `var' if `var' != `missing'
						replace `var' = (`var' - r(min))/(r(max) - r(min)) if `var' != `missing'
						replace `var' = . if `var' == `missing'
					}
					if "`reverse'" != "" {
						replace `var' = 1 - `var'
					}
				}

			}
			else {
			* m(#): off
				if "`up'" != "" | "`down'" != "" {
					noisily Error 198 "option up or down requires option missing to be set"
				}
				else {
					foreach var in `generate' {
						summarize `var'
						replace `var' = (`var' - r(min))/(r(max) - r(min))
						if "`reverse'" != "" {
							replace `var' = 1 - `var'
						}
					}
				}

			}

			if "`tab'" != "" {
				noisily tab1 `generate'
			}

		}
		else if "`generate'" == "" & "`prefix'" != "" {

			local n_vars : word count `varlist'
			forval i = 1/`n_vars' {
				local ovar : word `i' of `varlist'
				clonevar `prefix'`ovar' = `ovar'
				label values `prefix'`ovar' .
			}

			if "`missing'" != "" {

				foreach var in `varlist' {
					if "`up'" != "" & "`down'" != "" {
						noisily Error 198 "option up may not be combined with down"
					}
					else if "`up'" != "" & "`down'" == "" {
						summarize `var' if `var' < `missing'
						replace `prefix'`var' = (`var' - r(min))/(r(max) - r(min)) if `var' < `missing'
						replace `prefix'`var' = . if `var' >= `missing'
					}
					else if "`up'" == "" & "`down'" != "" {
						summarize `var' if `var' > `missing'
						replace `prefix'`var' = (`var' - r(min))/(r(max) - r(min)) if `var' > `missing'
						replace `prefix'`var' = . if `var' <= `missing'
					}
					else {
						summarize `var' if `var' != `missing'
						replace `prefix'`var' = (`var' - r(min))/(r(max) - r(min)) if `var' != `missing'
						replace `prefix'`var' = . if `var' == `missing'
					}
					if "`reverse'" != "" {
						replace `prefix'`var' = 1 - `prefix'`var'
					}
				}

			}
			else {
			* m(#): off
				if "`up'" != "" | "`down'" != "" {
					noisily Error 198 "option up or down requires option missing to be set"
				}
				else {
					foreach var in `varlist' {
						summarize `var'
						replace `prefix'`var' = (`var' - r(min))/(r(max) - r(min))
						if "`reverse'" != "" {
							replace `prefix'`var' = 1 - `prefix'`var'
						}
					}
				}

			}

			if "`tab'" != "" {
				local n_vars : word count `varlist'
				local s_var : word 1 of `varlist'
				local e_var : word `n_vars' of `varlist'
				noisily tab1 `prefix'`s_var'-`prefix'`e_var'
			}

		}
		else {
		* no, gen(namelist) and pre(name): off
			if "`missing'" != "" {

				foreach var in `varlist' {
					clonevar `var'_01 = `var'
					if "`up'" != "" & "`down'" != "" {
						noisily Error 198 "option up may not be combined with down"
						drop `var'_01
					}
					else if "`up'" != "" & "`down'" == "" {
						summarize `var' if `var' < `missing'
						replace `var'_01 = (`var' - r(min))/(r(max) - r(min)) if `var' < `missing'
						replace `var'_01 = . if `var' >= `missing'
					}
					else if "`up'" == "" & "`down'" != "" {
						summarize `var' if `var' > `missing'
						replace `var'_01 = (`var' - r(min))/(r(max) - r(min)) if `var' > `missing'
						replace `var'_01 = . if `var' <= `missing'
					}
					else {
						summarize `var' if `var' != `missing'
						replace `var'_01 = (`var' - r(min))/(r(max) - r(min)) if `var' != `missing'		
						replace `var'_01 = . if `var' == `missing'
					}
					if "`reverse'" != "" {
						replace `var'_01 = 1 - `var'_01
					}
				}

			}
			else {
			* m(#): off
				if "`up'" != "" | "`down'" != "" {
					noisily Error 198 "option up or down requires option missing to be set"
				}
				else {
					foreach var in `varlist' {
						summarize `var'
						clonevar `var'_01 = `var'
						replace `var'_01 = (`var' - r(min))/(r(max) - r(min))
						if "`reverse'" != "" {
							replace `var'_01 = 1 - `var'_01
						}
					}
				}

			}

			foreach var in `varlist' {
					label values `var'_01 .
			}

			if "`tab'" != "" {
				local n_vars : word count `varlist'
				local s_var : word 1 of `varlist'
				local e_var : word `n_vars' of `varlist'
				noisily tab1 `s_var'_01-`e_var'_01
			}

		}

	}

}

end

program define Error
	version 10
	args nr txt

	dis as err `"{p}`txt'{p_end}"'
	exit `nr'
end
