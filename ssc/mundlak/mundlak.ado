* *! Version 1.1.0 by Francisco Perales 04-February-2013 
* Requires Stata version 8.0 or higher

program define mundlak, rclass
version 8.0
syntax varlist(min=2) [if] [in] [, Use(string) PERCentage(integer 0) NOCOMParison HYBrid Full Keep STats(string) se t p]

marksample touse
quietly count if `touse'
if `r(N)' == 0{
	error 2000
}

capture quietly xtset
local id "`r(panelvar)'"
if "`r(panelvar)'" == ""{
	disp in red "You must xtset your data before using mundlak."
	exit
}
gettoken depvar indvars : varlist

quietly xtreg `depvar' if `touse'
local within_dep "floor((1-`e(rho)')*100)"
	if `within_dep' == 0{
	disp in red "The dependent variable (`depvar') does not vary within groups."
	exit
}

if "`nocomparison'" == ""{
	local comp "RE"
}

local used_variables "`indvars'"

if "`use'" != ""{
	local used_variables "`use'"
	local text2 "specified in the option 'use()' "
}

foreach var of varlist `used_variables'{
	quietly xtreg `var' if `touse'
	local within "floor((1-`e(rho)')*100)"				
		if `within' != 0 & `within'>`percentage'{
			quietly{
				bysort `id': egen mean__`var' = mean(`var') if `touse'
				lab var mean__`var' "Group-mean for variable `var'"
				if "`hybrid'" != ""{
					gen diff__`var' = `var' - mean__`var' if `touse'
					lab var diff__`var' "Group-mean deviation for variable `var'"
				}

			}
		}
				
		if `within' == 0 | `within'<`percentage'{
			disp in red _newline(1) "The variable `var' does not vary sufficiently within groups and will not be used to create additional regressors."
			disp in red `within' "% of the total variance in `var' is within groups."
			local invariant_vars "`invariant_vars' `var'"
		}
}

capture quietly xtreg `depvar' `indvars' if `touse', re
quietly est store RE

capture quietly des mean__*, varlist
local new_vars "`r(varlist)'"
local text "Group-mean"
local model "Mundlak"

if "`hybrid'" != ""{
	capture quietly des diff__*, varlist
	local new_vars "`r(varlist)'  `new_vars'"
	local indvars "`invariant_vars'"
	local text "Group-means and mean-differenced"
	local model "Hybrid"
}

capture quietly xtreg `depvar' `indvars' `new_vars' if `touse', re
quietly est store `model'

if "`stats'" == "" {
local stats "N N_g g_min g_avg g_max rho rmse chi2 p df_m sigma sigma_u sigma_e r2_w r2_o r2_b"
}

if "`full'" == ""{
	est tab `comp' `model', stat(`stats') b(%10.3f) stf(%10.3f) `se' `p' `t' style(columns) varwidth(20)
}

if "`full'" != ""{
	est rep `comp' `model'
}	

if "`new_vars'" == ""{
	disp in red _newline(1) "None of the independent variables `text2'varies within groups."
	disp in red "`text' variables were not added to the random-effects model."
}

if "`keep'" == ""{
	capture quietly drop mean__*
	capture quietly drop diff__*
}

capture quietly drop _est_`comp'
capture quietly drop _est_`model'
end
