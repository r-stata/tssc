*version 1.0  30sept2004 kcf
*version 1.1  10october2004 kcf changed syntax to parse variables and make dummy selector optional
*version 1.2  15october 2004 kcf changed to drop _obs_y if exists at beginning of program

* Usage:
*   reswage <depvar> <dep_predvars>, SELect(<obs_predvars>) [dummy(<obs_y_var>)]
*
* Example:
* . reswage lwage educ exper, select(nwifeinc kidslt6 kidsge6 age educ)
* . reswage lwage educ exper, select(nwifeinc kidslt6 kidsge6 age educ) dummy(inlf)


program define reswage, eclass
	version 8.0
	syntax varlist(min=2) , SELect(varlist) [dummy(varname)]

		* first variable = dependent, rest of variables = independent

	tokenize `varlist'						/* Break list into separate variables, parsed by space */
	local depvar = "`1'"	        				/* The first varname is the dependent variable */
	local predvars = "`2'"	       		 			/* Next Variables that predict Y - min=2 */
	foreach varname in `varlist' {					/* Go through each word on the command line... */
		if "`varname'"!="`depvar'" {				/* After the first variable (the dependent variable), */
			local predvars = "`predvars' `ferest()'"	/* add subsequent variables onto end of predvars list */
			continue, break
		}
	}

	capture drop _obs_y
	
		* Display which variables were assigned to which group (in green!)
	display in green _n "Dependent variable (Y) = `depvar'"
	display in green _n "Predictors of Y = `predvars'"
	display in green _n "Predictors that Y is observed = `select'"

      	if "`dummy'" == "" {	/* If the user didn't supply their own dummy variable, then... */
	capture drop _obs_y
	capture estimates clear

		* Generate a dummy variable called _obs_y telling whether the dependent variable was observed
	display in green _n "Creating temporary dummy variable _obs_y and assigning 1 if Y is observed"
	egen _obs_y = robs(`depvar')
	} 
	else {			/* If they supplied a dummy, then just use it. */
		display in green _n "Copying user defined dummy variable `dummy' to tempvar _obs_y and assigning 1 if Y is observed"
		gen _obs_y = `dummy'	/* Copy the dummy variable to _obs_y to pass it into reswage_ll */
	}
	tab _obs_y	/* Tabulate the dummy variable */

		*Regress on dependent variable to store saved estimate values (OLS underestimations)
	display in green _n "Regress dependent variable on predictors"
	regress `depvar' `predvars'
		
	quietly ereturn list
	
	estimates store OLS_est

	matrix b0=e(b)

		* Apply ml reswage model as defined in the reswage_ll.ado file
	ml model lf reswage_ll (`depvar' = `predvars') () (`select') (), title(Reservation Wage Model) missing

	ml init b0

	display in green _n "Maximize . . ."

	ml maximize, difficult

	display in yellow "eq1 = `depvar'"
	display in yellow "eq2 = sigma_u"
	display in yellow "eq3 = reservation wage"
	display in yellow "eq4 = sigma_e" _continue

		*Drop variables created by this file
	drop _obs_y _est_OLS_est
	program drop _all

end

exit
