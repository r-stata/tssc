/*This ado file gives the log likelihood function used in interval regressions
for the normal distribution.
It works with gintreg.ado
v 1
Author--Jacob Orchard
Update--5/24/2016*/


capture program drop intllf_normal

program intllf_normal
version 13
		args lnf mu sigma
		tempvar Fu Fl  
		qui gen double `Fu' = .
		qui gen double `Fl' = .
		
		*Point data
		 qui replace `lnf' = log(normalden($ML_y1,`mu', exp(`sigma'))) if $ML_y1 != . ///
							& $ML_y2 != . & $ML_y1 == $ML_y2
				
		*Interval data
		 qui replace `Fu' = normal(($ML_y2-`mu')/exp(`sigma')) if $ML_y1 != . & ///
							$ML_y2 != . &  $ML_y1 != $ML_y2
							
		 qui replace `Fl' = normal(($ML_y1-`mu')/exp(`sigma')) if $ML_y1 != . & ///
							$ML_y2 != . &  $ML_y1 != $ML_y2
							
		 qui replace `lnf' = log(`Fu' -`Fl') if $ML_y1 != . & $ML_y2 != . & ///
							$ML_y1 != $ML_y2
		
		*Bottom coded data
			
		 qui replace `Fl' = normal(($ML_y1-`mu')/exp(`sigma')) 
		 qui replace `lnf' = log(1-`Fl') if $ML_y1 != . & $ML_y2 == .
		 
		 *describe `lnf'
		 *sum `lnf'
	
		*Top coded data
			
		 qui replace `Fu' = normal(($ML_y2-`mu')/exp(`sigma')) if $ML_y2 != . & $ML_y1 == .
		 qui replace `lnf' = log(`Fu') if $ML_y2 != . & $ML_y1 == .
		
		*describe `lnf'
		*sum `lnf'
		*inspect `lnf'
		*list `lnf'
	
		*Missing Values			 
		qui replace `lnf' = 0 if $ML_y2 == . & $ML_y1 == .
				
		
end		


