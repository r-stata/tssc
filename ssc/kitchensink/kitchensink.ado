* *! Version 1.1.0 by Francisco Perales 26-April-2013 
* Requires Stata version 11.0 or higher
* Requires user-written command 'tuples'

program define kitchensink, rclass
version 11
quietly{
	syntax varlist(min=3 max=11 numeric) [if] [in] [, LEVel(real 90) LOGit aic]
	version 11
	marksample touse
	count if `touse'
	if `r(N)' == 0{
		error 2000
	}
		local command regress
		if "`logit'" != "" {
			local command logit
		}
		local t = invnormal((`level'/100)+(((1-(`level'/100))/2)))
		gettoken depvar indvars : varlist
		quietly tuples `indvars'
		local best_combo 0
		local best_aic = 9999999999
		foreach num of numlist 1/`ntuples'{
			`command' `depvar' `tuple`num''
			local aic`num' = -2*e(ll)+2*e(rank)
			local ns_tuple`num' 0
			foreach var in `tuple`num''{
					if abs(_b[`var']/_se[`var'])>`t' & (_b[`var']!=0 & _se[`var']!=0){
						local ns_tuple`num' = `ns_tuple`num''+1 
					}
				}
			if `ns_tuple`num'' > `best_combo'{
				local best_combo `ns_tuple`num''
				local best_model `tuple`num''
			}
			if `aic`num'' < `best_aic'{
				local best_model_aic `tuple`num''
				local best_aic `aic`num''
			}
		}
}
disp in green _newline(1) "The combination of regressors ** `best_model' ** gives the highest number of significant variables: `best_combo'"
disp in green _newline(1) "`command' `depvar' `best_model'"
`command' `depvar' `best_model'
if "`aic'" != "" {
	if "`best_model'" == "`best_model_aic'"{
		disp in green _newline(1) "This model has also the best AIC: " in yellow %14.5f `best_aic'
		exit
		}
	disp in green _newline(1) "The best AIC is for a model containing regressors ** `best_model_aic' ** . AIC = :" %14.5f in yellow `best_aic'
	disp in green _newline(1) "`command' `depvar' `best_model'"
	`command' `depvar' `best_model_aic'
exit
}
end
