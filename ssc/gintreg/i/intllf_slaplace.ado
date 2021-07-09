/*This ado file gives the log likelihood function used in interval regressions
for the Skewed Laplace distribution.
It works with gintreg.ado
v 1.1
Author--Bryan Chia
Update--9/7/2017*/


program intllf_slaplace
version 13
		args lnf mu lambda 
		tempvar Fu Fl zu zl 
		qui gen double `Fu' = .
		qui gen double `Fl' = .
		qui gen double `zu' = . 
		qui gen double `zl' = .
		
		*Point data
			tempvar x 
			qui gen double `x' = $ML_y1 - (`mu') if $ML_y1 != . & $ML_y2 != . ///
												& $ML_y1 == $ML_y2
												
			*Change this log pdf later
																					
			qui replace `lnf' = log(`x') if $ML_y1 != . & $ML_y2 != . & ///
								$ML_y1 == $ML_y2 
		
		
		*Interval data
			qui replace `zu' = (abs($ML_y2 - `mu'))/( ///
								(1+`lambda'*sign($ML_y2 -`mu'))) ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `Fu' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y2- ///
								`mu'))*sign($ML_y2 - `mu')*(1 - exp(-`zu')) ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `zl' = (abs($ML_y1 - `mu'))/( ///
								(1+`lambda'*sign($ML_y1 -`mu'))) ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `Fl' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y1- ///
								`mu'))*sign($ML_y1 - `mu')*(1 - exp(-`zl'))  ///
								if $ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
								
			qui replace `lnf' = log(`Fu' -`Fl') if $ML_y1 != . & $ML_y2 != . &  ///
														$ML_y1 != $ML_y2
		
		*Bottom coded data
			qui replace `zl' = (abs($ML_y1 - `mu'))/( ///
								(1+`lambda'*sign($ML_y1 -`mu'))) ///
								if $ML_y1 != . & $ML_y2 == .
								
			qui replace `Fl' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y1- ///
								`mu'))*sign($ML_y1 - `mu')*(1 - exp(-`zl'))  ///
								if $ML_y1 != . & $ML_y2 == .
								
			qui replace `lnf' = log(1-`Fl') if $ML_y1 != . & $ML_y2 == .
		
		*Top coded data
			qui replace `zu' = (abs($ML_y2 - `mu'))/( ///
								(1+`lambda'*sign($ML_y2 -`mu'))) ///
								if $ML_y2 != . & $ML_y1 == .
								
			qui replace `Fu' = .5*(1-`lambda') + .5*(1+`lambda'*sign($ML_y2- ///
								`mu'))*sign($ML_y2 - `mu')*(1 - exp(-`zu')) ///
								if $ML_y2 != . & $ML_y1 == .
								
			qui replace `lnf' = log(`Fu') if $ML_y2 != . & $ML_y1 == .
		
		*Missing values
			qui replace `lnf' = 0 if $ML_y2 == . & $ML_y1 == .
		
		
		
end		
