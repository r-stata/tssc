/*This ado file gives the log likelihood function used in interval regressions
for the SGT distribution.
It works with gintreg.ado
v 1.1
Author--Jacob Orchard
Update--5/26/2016*/


program intllf_sgt
version 13
		args lnf mu lambda sigma p q
		tempvar Fu Fl zu zl 
		qui gen double `Fu' = .
		qui gen double `Fl' = .
		qui gen double `zu' = . 
		qui gen double `zl' = .
		
		di as txt "mu"
		di `mu'
		di as txt "lamda"
		di `lambda'
		di as txt "sigma"
		di `sigma' 
		di as txt "p"
		di `p'
		di as txt "q"
		di `q'
		
		*Point data
			tempvar x s l y
			qui gen double `x' = $ML_y1 - (`mu') if $ML_y1 != . & $ML_y2 != . ///
												& $ML_y1 == $ML_y2
												
			qui gen double `s' = exp(`sigma') if $ML_y1 != . & $ML_y2 != .  ///
												& $ML_y1 == $ML_y2
												
			qui gen double `l' = (exp(`lambda')-1)/(exp(`lambda')+1) if $ML_y1 ///
										!= . & $ML_y2 != . & $ML_y1 == $ML_y2
										
			qui gen double `y' = (2 * `s' * `l' * `q'^(1/`p') * exp(lngamma(2/`p') ///
								+ lngamma(`q' - 1/`p') - lngamma(1/`p' +  ///
								`q')))/exp(lngamma(1/`p') + lngamma(`q') - ///
								lngamma(1/`p' + `q')) if $ML_y1 != . & ///
											$ML_y2 != . & $ML_y1 == $ML_y2
											
			qui replace `lnf' = ln(`p') - ln(2) - `sigma' - (ln(`q')/`p') -  ///
								(lngamma(1/`p') + lngamma(`q') - lngamma(1/`p' ///
								+ `q')) - (1/`p' + `q') * ln(1 + abs(`x' + ///
								`y')^`p'/(`q' * `s'^`p' * (1 + `l' * sign(`x' + ///
								`y'))^`p')) if $ML_y1 != . & $ML_y2 != . & ///
								$ML_y1 == $ML_y2
		
		*Interval data
			qui replace `zu' = abs($ML_y2 - `mu')^`p'/(abs($ML_y2 - `mu')^`p' + ///
								`q'*`sigma'^`p'*(1+`lambda'*sign($ML_y2 -`mu'))^`p') ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `Fu' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y2- ///
								`mu'))*sign($ML_y2 - `mu')*ibeta(1/`p',`q',`zu') ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `zl' = abs($ML_y1 - `mu')^`p'/(abs($ML_y1 - `mu')^`p' + ///
								`q'*`sigma'^`p'*(1+`lambda'*sign($ML_y1 -`mu'))^`p') ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `Fl' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y1- ///
								`mu'))*sign($ML_y1 - `mu')*ibeta(1/`p',`q',`zl') ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
			
			
								
			qui replace `lnf' = log(`Fu' -`Fl') if $ML_y1 != . & $ML_y2 != . &  ///
														$ML_y1 != $ML_y2
														
		
		*Bottom coded data
			qui replace `zl' = abs($ML_y1 - `mu')^`p'/(abs($ML_y1 - `mu')^`p' + ///
								`q'*`sigma'^`p'*(1+`lambda'*sign($ML_y1 -`mu'))^`p') ///
								if $ML_y1 != . & $ML_y2 == .
								
			qui replace `Fl' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y1- ///
								`mu'))*sign($ML_y1 - `mu')*ibeta(1/`p',`q',`zl') ///
								if $ML_y1 != . & $ML_y2 == .
								
			qui replace `lnf' = log(1-`Fl') if $ML_y1 != . & $ML_y2 == .

		
		*Top coded data
			qui replace `zu' = abs($ML_y2 - `mu')^`p'/(abs($ML_y2 - `mu')^`p' + ///
								`q'*`sigma'^`p'*(1+`lambda'*sign($ML_y2 -`mu'))^`p') ///
								if $ML_y2 != . & $ML_y1 == .
								
			qui replace `Fu' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y2- ///
								`mu'))*sign($ML_y2 - `mu')*ibeta(1/`p',`q',`zu') ///
								if $ML_y2 != . & $ML_y1 == .
								
								
			qui replace `lnf' = log(`Fu') if $ML_y2 != . & $ML_y1 == .
			
		
		*Missing values
			qui replace `lnf' = 0 if $ML_y2 == . & $ML_y1 == . 
			
			
			di as txt "Fu"
			inspect `Fu'
			sum `Fu'
			
			di as txt "Fl"
			inspect `Fl'
			sum `Fl'
			
		
			di as txt "lnf"
			inspect `lnf'
			sum `lnf'
		
		
end		
