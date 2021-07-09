/*This ado file gives the log likelihood function used in interval regressions
for the SGED distribution.
It works with gintreg.ado
v 1.1
Author--Jacob Orchard
Update--6/13/2016*/


program intllf_sged_group
version 13
		args lnf mu sigma p a 
		tempvar Fu Fl zu zl 
		qui gen double `Fu' = .
		qui gen double `Fl' = .
		qui gen double `zu' = . 
		qui gen double `zl' = .
		
		tempvar lambda
		qui gen `lambda' = (exp(`a') - 1) / (exp(`a') + 1)
		
		*Point data
			tempvar x s l 
			qui gen double `x' = $ML_y1 - (`mu') if $ML_y1 != . & $ML_y2 != . ///
												& $ML_y1 == $ML_y2
												
			qui gen double `s' = log(`p') - (abs(`x')^`p'/(`sigma'*(1+`lambda'*sign(`x')))^`p') ///
								if $ML_y1 != . & $ML_y2 != .  & $ML_y1 == $ML_y2
												
			qui gen double `l' = log(2) + log(`sigma') + lngamma((1/`p')) ///
								if $ML_y1 != . & $ML_y2 != . & $ML_y1 == $ML_y2
																					
			qui replace `lnf' = `s' - `l' if $ML_y1 != . & $ML_y2 != . & ///
								$ML_y1 == $ML_y2
		
		
		*Interval data
			qui replace `zu' = (abs($ML_y2 - `mu')^`p')/( ///
								(exp(`sigma')^`p')*(1+`lambda'*sign($ML_y2 -`mu'))^`p') ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `Fu' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y2- ///
								`mu'))*sign($ML_y2 - `mu')*gammap( (1/`p'),`zu') ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `zl' = (abs($ML_y1 - `mu')^`p')/( ///
								(exp(`sigma')^`p')*(1+`lambda'*sign($ML_y1 -`mu'))^`p') ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `Fl' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y1- ///
								`mu'))*sign($ML_y1 - `mu')*gammap((1/`p'),`zl')  ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `lnf' = log(`Fu' -`Fl') if $ML_y1 != . & $ML_y2 != . &  ///
														$ML_y1 != $ML_y2
		
		*Bottom coded data
			qui replace `zl' = (abs($ML_y1 - `mu')^`p')/( ///
								(exp(`sigma')^`p')*(1+`lambda'*sign($ML_y1 -`mu'))^`p') ///
								if $ML_y1 != . & $ML_y2 == .
								
			qui replace `Fl' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y1- ///
								`mu'))*sign($ML_y1 - `mu')*gammap((1/`p'),`zl') ///
								if $ML_y1 != . & $ML_y2 == .
								
			qui replace `lnf' = log(1-`Fl') if $ML_y1 != . & $ML_y2 == .
		
		*Top coded data
			qui replace `zu' = (abs($ML_y2 - `mu')^`p')/( ///
								(exp(`sigma')^`p')*(1+`lambda'*sign($ML_y2 -`mu'))^`p') ///
								if $ML_y2 != . & $ML_y1 == .
								
			qui replace `Fu' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y2- ///
								`mu'))*sign($ML_y2 - `mu')*gammap((1/`p'),`zu') ///
								if $ML_y2 != . & $ML_y1 == .
								
			qui replace `lnf' = log(`Fu') if $ML_y2 != . & $ML_y1 == .
		
		*Missing values
			qui replace `lnf' = 0 if $ML_y2 == . & $ML_y1 == .
		
		*Group frequency
		 qui replace `lnf' = `lnf'*$group_per
		
end		
