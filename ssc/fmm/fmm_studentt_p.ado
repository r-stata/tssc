*! version 2.1.0 12feb2012
*! author: Partha Deb
* version 1.1.0 12jul2007
* version 1.0.0 12jul2007

program fmm_studentt_p
	version 9.2

	syntax anything(id="newvarname") [if] [in] [, MEan PRior POsterior EQuation(string) ]

	syntax newvarname [if] [in] [, * ]

	if "`equation'" != "" & "`prior'" == "" & "`posterior'" == "" {
		_predict `typlist' `varlist' `if' `in', equation(`equation')
		label variable `varlist' "predicted mean: `equation'"
		exit
	}

	if "`equation'" == "" | "`prior'" == "prior" | "`posterior'" == "posterior" {

		forvalues i=1/$fmm_components {
			local L_xb `"`L_xb' xb`i'"'
			local L_pr `"`L_pr' pr`i'"'
			local L_lod `"`L_lod' lnsigma`i'"'
			local L_od `"`L_od' sigma`i'"'
		}
		forvalues i=1/`=$fmm_components-1' {
			local L_lpr `"`L_lpr' lpr`i'"'
		}

		tempvar `L_xb' `L_lpr' `L_pr' `L_lod' `L_od' den

		forvalues i=1/$fmm_components {
			qui _predict `typlist' `xb`i'' `if' `in', equation(component`i')
			qui _predict `typlist' `lnsigma`i'' `if' `in', equation(lnsigma`i')
			qui gen double `sigma`i'' = exp(`lnsigma`i'')
		}

		qui gen double `den' = 1
		forvalues i=1/`=$fmm_components-1' {
			qui _predict `typlist' `lpr`i'' `if' `in', equation(imlogitpi`i')
			qui replace `den' = `den' + exp(`lpr`i'')
		}

		forvalues i=1/`=$fmm_components-1' {
			qui gen double `pr`i'' = exp(`lpr`i'')/`den'
		}

		qui gen double `pr$fmm_components' = 1
		forvalues i=1/`=$fmm_components-1' {
			qui replace `pr$fmm_components' = `pr$fmm_components' - `pr`i''
		}
	}

	if "`prior'" == "" & "`posterior'" == "" {
		gen `typlist' `varlist' `if' `in' = 0
		forvalues i=1/$fmm_components {
			qui replace `varlist' = `varlist' + `pr`i'' * `xb`i''
		}
		label variable `varlist' "predicted mean"
		exit
	}

	if "`prior'" == "prior" {
		local i = substr("`equation'",-1,1)
		gen `typlist' `varlist' = `pr`i'' `if' `in'
		label variable `varlist' "prior probability: `equation'"
		exit
	}


	if "`posterior'" == "posterior" {
		tempvar prob probcomponent

		local fmm_y = e(depvar)
		qui gen double `prob' = 0
		forvalues i=1/$fmm_components {
			qui replace `prob' = `prob' + `pr`i'' ///
												* tden($fmm_tdf,(`fmm_y'-`xb`i'')/`sigma`i'')/`sigma`i'' 
			if "`equation'"=="component`i'" {
				qui gen double `probcomponent' = `pr`i'' ///
												* tden($fmm_tdf,(`fmm_y'-`xb`i'')/`sigma`i'')/`sigma`i'' 
			}
		}
		gen `typlist' `varlist' = `probcomponent' / `prob'
		label variable `varlist' "posterior probability: `equation'"
		exit
	}

end

