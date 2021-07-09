* *! Version 1.2.0 by Francisco Perales & Reinhard Schunck 01-April-2020
* Version 1.1.0: Corrects issues which emerged when the names of existing user variables begun with certain prefixes
* Version 1.2.0: Adds the option 'keepvars' to retain newly created variables into the data

program define xthybrid, rclass
syntax varlist(min=2) [if] [in] , Clusterid(varname) [Family(string) Link(string) cre Nonlinearities(string) RANDOMslope(varlist) Use(string) PERCentage(integer 0) TEst Full STats(string) vce(string) se t p star iterations MEGLMopts(string) KEEPvars]

version 12
if "`keepvars'"=="" preserve

foreach badprefix in W__ D__ B__ R__ mEaN__ dIfF__{
	capture quietly des `badprefix'*
	if !_rc {
		di in red "Your dataset contains one or more variables with names beginning with W__, D__, B__, R__ mEaN__ or dIfF__"
		di in red "Please rename these variables prior to executing xthybrid"
		exit 9999
	}
}

marksample touse
markout `touse' `varlist'
quietly count if `touse'
if `r(N)' == 0 	error 2000

if "`meglmopts'" != "" display in red "Please note that certain 'meglm' options will not work and 'meglm' error messages may not be displayed."

if "`family'" == "" local family "gaussian"
if "`family'"!="gaussian" & "`family'"!="bernoulli" & "`family'"!="binomial" & "`family'"!="gamma" & "`family'"!="nbinomial" & "`family'"!="ordinal" & "`family'"!="poisson"{
	disp in red "The option 'family' supports the following: gaussian, bernoulli, binomial, gamma, nbinomial, ordinal, poisson."
	exit
}

if "`link'" == "" local link "identity"
if "`link'"!="identity" & "`link'"!="log" & "`link'"!="logit" & "`link'"!="probit" & "`link'"!="cloglog"{
		disp in red "The option 'link' supports the following: identity, log, logit, probit, cloglog."
	exit
}

if "`nonlinearities'"!="" & ("`nonlinearities'"!="quadratic"&"`nonlinearities'"!="cubic"&"`nonlinearities'"!="quartic"){
	disp in red "The option 'nonlinearities' supports the following: quadratic, cubic, quartic."
	exit
}

display ""
gettoken depvar indvars : varlist

quietly xtreg `depvar' if `touse', i(`clusterid')
local within_dep "floor((1-`e(rho)')*100)"
	if `within_dep' == 0{
		disp in red "The dependent variable (`depvar') does not vary within clusters."
	exit
}

local used_variables "`indvars'"

if "`use'" != ""{
	local used_variables "`use'"
	local text "specified in the option 'use()' "
}

foreach var of varlist `used_variables'{
	quietly xtreg `var' if `touse'
	local within "floor((1-`e(rho)')*100)"				
		if `within' != 0 & `within'>`percentage'{
			quietly{
				bysort `clusterid': egen mEaN__`var' = mean(`var') if `touse'
				gen dIfF__`var' = `var' - mEaN__`var' 
				if "`nonlinearities!'"=="quadratic" gen mEaN__`var'_2 =  mEaN__`var'^2 
				if "`nonlinearities!'"=="cubic"{
					gen mEaN__`var'_2 =  mEaN__`var'^2 
					gen mEaN__`var'_3 =  mEaN__`var'^3 
				}
				if "`nonlinearities!'"=="quartic"{
					gen mEaN__`var'_2 =  mEaN__`var'^2 
					gen mEaN__`var'_3 =  mEaN__`var'^3
					gen mEaN__`var'_4 =  mEaN__`var'^4
				}
			}
		}
				
		if `within' == 0 | `within'<`percentage'{
			disp in green "The variable '`var'' does not vary sufficiently within clusters"
			disp in green "and will not be used to create additional regressors."
			disp in yellow "[~" `within' "% of the total variance in '`var'' is within clusters]"
			local invariant_vars "`invariant_vars' `var'"
		}
}

capture quietly des mEaN__* dIfF__*, varlist
local new_vars "`r(varlist)'"

if "`cre'" != ""{
	rename mEaN__* D__*
	foreach variable in `indvars'{
		capture des D__`variable', varlist
		if !_rc rename `variable' W__`variable'
		if _rc rename `variable' R__`variable'
	}	
	capture rename D__*_2 B__*_2
	capture rename D__*_3 B__*_3
	capture rename D__*_4 B__*_4
	local model_name "Correlated random effects model. Family: `family'. Link: `link'."
}

if "`cre'" == ""{
	rename mEaN__* B__*
	rename dIfF__* W__*
	foreach variable in `indvars'{
		capture des B__`variable', varlist
		if _rc gen R__`variable' = `variable' 
	}
	local model_name "Hybrid model. Family: `family'. Link: `link'."
}



foreach var_group in R__* W__* B__* D__*{
	capture des `var_group', varlist
	if !_rc local final_vars "`final_vars' `r(varlist)'"
}

if "`vce'"!="" local vce_option vce(`vce')

if "`randomslope'"!=""{
	foreach random_variable in "`randomslope'"{
		capture des W__`random_variable', varlist
		if !_rc local random_vars "`random_vars' `r(varlist)'"
		capture des R__`random_variable', varlist
		if !_rc local random_vars "`random_vars' `r(varlist)'"
	}
}

if "`iterations'"==""{
	/*capture*/ quietly meglm `depvar' `final_vars' if `touse' || `clusterid': `random_vars', family("`family'") link("`link'") `vce_option' `meglmopts'
}

if "`iterations'"!=""{
	/*capture*/ meglm `depvar' `final_vars' if `touse' || `clusterid': `random_vars', family("`family'") link("`link'") `vce_option' `meglmopts'
}

if _rc & "`meglmopts'"!=""{
	display in red _newline(1) "The 'meglm' option that you choose is incorrectly specified or not compatible with 'xthybrid'."
	exit
}

est store model

if "`star'" != "" {
	local stars = "star(0.05 0.01 0.001)"
	local se = ""
	local p = ""
	local se = ""
}

if "`stats'" == "" local stats "ll chi2 p aic bic"

if "`full'" == "" & "`iterations'"==""{
	matrix N_g = e(N_g)
	local N_clust = N_g[1,1]
	est tab model, stat(`stats') b(%10.4f) stf(%10.4f) `se' `p' `t' `stars' style(columns) varwidth(20) ti(`model_name')
	display in green "Level 1: " in yellow `e(N)' in green " units. Level 2: " in yellow `N_clust' in green " units."
}

if "`full'" != "" est rep model

if "`new_vars'" == ""{
	display in red "None of the independent variables `text'varies within clusters."
	display in red "Neither cluster-mean nor mean-differenced variables were added to the mixed-effects model."
}

if "`test'"!=""{
	display _newline(1) "Tests of the random effects assumption:"
	foreach regressor in `used_variables'{
		if "`cre'" == ""{
			capture quietly test _b[B__`regressor']=_b[W__`regressor']
			if !_rc display in yellow "  _b[B__`regressor'] = _b[W__`regressor']; p-value: " %6.4f `r(p)'
		}
		if "`cre'" != ""{
			capture quietly test _b[D__`regressor']=0
			if !_rc display in yellow "  _b[D__`regressor'] = 0; p-value: " %6.4f `r(p)'
		}
	}
}
if "`keepvars'"!=""{
	display in yellow "Please remember to remove any variables beginning with the prefix B__, W__ or R__ from the data before executing xthybrid again"
}
if "`keepvars'"=="" restore
end
