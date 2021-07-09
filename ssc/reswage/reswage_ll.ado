*version 1.0  30sept2004 kcf
*version 1.1 7oct2004 - added dummy variable as option, changed syntax

program define reswage_ll
	version 8.0

	args lnf theta1 theta2 theta3 theta4
		* theta1 = xi'beta
		* theta2 = sigma_u
		* theta3 = wi'alpha
		* theta4 = sigma_e

		* From the reswage.ado file, remember _obs_y (z) must be a variable that is a dummy variable so the correct eq gets applied
		* _obs_y = 1 - Dependent variable is observed (took a job, in wage reservation example)
		* _obs_y = 0 - Dependent variable is not observed

		*Create temporary variables to substitute into function
	tempvar var_u var_e sigma a b c d

	quietly gen double `var_u' = `theta2'^2
	quietly gen double `var_e' = `theta4'^2
	quietly gen double `sigma' = (`var_u' + `var_e')^.5

		* Terms of the first equation (z=1 case)

	quietly gen double `a' = ln(1/((2*_pi*`var_u')^.5))
	quietly gen double `b' = -(1/(2*`var_u'))*(($ML_y1-`theta1')^2)
	quietly gen double `c' = ln(norm((1/`var_e')*($ML_y1-`theta3')))
	
		* Terms of the second equation (z=0 case)

	quietly gen double `d' = ln(norm((`theta3' - `theta1')/`sigma'))

		* Equations rewritten with temp variables

	quietly replace `lnf' = `a' + `b' + `c' if _obs_y==1
	quietly replace `lnf' = `d' if _obs_y==0
	
end
