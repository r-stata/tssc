*! version 3.0.0 Stephen P. Jenkins, Oct 2007  (left truncation option)
*! version 2.0.0 Stephen P. Jenkins, 23 May 2006 (right censoring option)
*! version 1.2.0 Stephen P. Jenkins, April 2004
*! Fitting of GB2 distribution by ML
*! Called by gb2lfit.ado


program define gb2lfit_ll

	version 8.2
	args lnf ln_a ln_b ln_p ln_q

	quietly {

		tempname a b p q 
		scalar `a' = exp(`ln_a')
		scalar `b' = exp(`ln_b')
		scalar `p' = exp(`ln_p')
		scalar `q' = exp(`ln_q')
		
		if "$S_mlcens" == "" {
			replace `lnf' = ln(`a') + (`a'*`p'-1)*ln($S_mlinc) ///
				- `a'*`p'*ln(`b')   ///
				- lngamma(`p') - lngamma(`q') + lngamma(`p'+`q') ///
				- (`p'+`q')*ln(1+($S_mlinc/`b')^`a')  
		}

		if "$S_mlcens" != "" {

			tempvar lnd lnS
			
			ge double `lnd' = ln(`a') + (`a'*`p'-1)*ln($S_mlinc) ///
					- `a'*`p'*ln(`b')   ///
					- lngamma(`p') - lngamma(`q') + lngamma(`p'+`q') ///
					- (`p'+`q')*ln(1+($S_mlinc/`b')^`a')  

			ge double `lnS' = ln( 1 - ibeta(`p',`q', ($S_mlinc/`b')^`a'/(1+($S_mlinc/`b')^`a') ) )

			
			replace `lnf' = cond($S_mlcens, `lnS', `lnd', .)

		}

		if "$S_mlz" != "" {

		replace `lnf' = `lnf' - ln( 1 - ibeta(`p',`q', ($S_mlz/`b')^`a'/(1+($S_mlz/`b')^`a') ) )

		}

	}
end
