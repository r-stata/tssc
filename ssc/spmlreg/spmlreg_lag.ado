*!Author: PWJ
*!Date: December 18, 2009
program define spmlreg_lag
	version 11.0
	args lnf theta0 rho sigma
	tempvar grho splv
	qui gen double `grho'=`rho'*spmlreg_eigv
	qui gen double `splv'=`rho'*wy_`e(depvar)'
	qui replace `lnf'= ln(1-`grho') - 0.5*ln(2*_pi) - 0.5*ln(`sigma'^2) - ///
	                   (0.5/(`sigma'^2))*(($ML_y1 - `splv' - `theta0')^2) if $ML_samp==1

end






