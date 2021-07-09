*! grvar: Applies a non-constant growth rate to a variable
*! Version 1.0.0 June 28, 2020
*! Author: Daniel Pailañir Vargas
*! daniel.pailanir@gmail.com
 
cap program drop grvar
program grvar
	version 13.0
	
	#delimit ;
	syntax varlist(min=2 max=2 numeric)
	, GENerate(string)
	[
	  REPLACE
	]
	;
	
	#delimit cr
	*-------------------------------------------------------*
	*- Check if the dataset is tsset and create panel local-*
    *-------------------------------------------------------*
	qui tsset
	if "`r(panelvar)'"!="" local pvar `r(panelvar)'
	*------------------------------*
	*- Temporal variables & names -*
	*------------------------------*
	tokenize `varlist'
	tempvar	 t
	tempname N
	*----------------------------*
	*- Time var for the formula -*
	*----------------------------*	
	if "`pvar'"!="" bys `pvar': gen `t' = _n // if is a panel data
	else gen `t' = _n 						 // if is a time serie
	*--------------------------------------*
	*- Create or replace the new variable -*
	*--------------------------------------*	
	qui {
		if "`replace'"=="replace" {
			drop `generate'
			gen `generate' = .
		}
		else gen `generate' = .
		* If is panel data
		if "`pvar'"!="" {
			levelsof `pvar', local(lvl)
			foreach g of local lvl {
				sum `2' if `t'==1 & `pvar'==`g'
				scalar P`g' = r(min)
				sum `t' if `pvar'==`g', meanonly
				forvalues i = `r(min)'/`r(max)' {
					if `i'==1 replace `generate' = P`g' if (`t'==`i' & `pvar'==`g')
					else 	  replace `generate' = L.`generate'*(1+`1') if (`t'==`i' & `pvar'==`g')
				}
			}
		}
		* If is time serie
		else {
			sum `2' if `t'==1 
			scalar `N' = r(min)
			sum `t', meanonly
			forvalues i = `r(min)'/`r(max)' {
				if `i'==1 replace `generate' = `N'
				else 	  replace `generate' = L.`generate'*(1+`1') if `t'==`i'
			}
		}
	}
end

