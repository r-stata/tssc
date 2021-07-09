/*This ado file gives the log likelihood function used in interval regressions
for the lognormal distribution.
It works with gintreg.ado
v 2
Author--Jacob Orchard
Update--8/10/2016*/



program intllf_ln
version 13
		args lnf mu sigma
		tempvar Fu Fl  
		qui gen double `Fu' = .
		qui gen double `Fl' = .
		
		*Point data
		
		qui replace `lnf' = log(normalden(log($ML_y1 ),`mu',exp(`sigma')))*(1/$ML_y1 ) ///
							if $ML_y1 != . & $ML_y2 != . & $ML_y1 == $ML_y2
				
		*Interval data
		 qui replace `Fu' = normal((log($ML_y2 )-`mu')/exp(`sigma')) if ///
							$ML_y1 != . & $ML_y2 != . &  $ML_y1 != $ML_y2
							
		 qui replace `Fl' = normal((log($ML_y1 )-`mu')/exp(`sigma')) if $ML_y1 != . ///
							& $ML_y2 != . &  $ML_y1 != $ML_y2
							
		 qui replace `lnf' = log(`Fu' -`Fl') if $ML_y1 != . & $ML_y2 != . &  ///
							$ML_y1 != $ML_y2
		
		
		*Bottom coded data
			
		 qui replace `Fl' = normal((log($ML_y1)-`mu')/exp(`sigma'))  if $ML_y1 != . & $ML_y2 == .
		 qui replace `lnf' = log(1-`Fl') if $ML_y1 != . & $ML_y2 == .
	
		
		*Top coded data
			
		 qui replace `Fu' = normal((log($ML_y2)-`mu')/exp(`sigma')) if $ML_y2 != . & $ML_y1 == .
		 qui replace `lnf' = log(`Fu') if $ML_y2 != . & $ML_y1 == .
	
		*Missing Values			 
		 qui replace `lnf' = 0 if $ML_y2 == . & $ML_y1 == .
		 
end		


