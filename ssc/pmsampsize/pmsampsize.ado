**************************************************
*												 *
*  PROGRAM TO CALCULATE SAMPLE SIZE FOR MODEL    * 
*	DEVELOPMENT BASED ON EXPECTED SHRINKAGE		 *
*  13/06/18 									 *
*  Updated: 01/08/19							 *
*	implemented correction to SiM paper (eq.13)	 *
*  Updated: 13/11/19							 *
*	implemented correction to SiM paper (eq.13)	 *
*	for survival outcomes, removing the effect	 *
*	of time units								 *
*  1.0.2 J. Ensor								 *
**************************************************

*! 1.0.2 J.Ensor 13Nov2019


program define pmsampsize, rclass

version 12.1

/* Syntax
	TYPE = define type of outcome model to calculate development sample size for
	RSQUARED = R-sq adjusted
	PARAMETERS = number of parameters to be estimated in model
	SHRINKAGE = required shrinkage of development model
	PREVALENCE = prevalence of outcome
	RATE = overall event rate (for survival models)
	TIMEPOINT = timepoint of interest for prediction (for survival models)
	MEANFUP = mean follow-up in previous prediction model study
	INTERCEPT = the anticipated mean outcome value (e.g. mean blood pressure
					in the target population
	SD = population (null model) standard deviation i.e. sigma(null) (e.g. SD 
				in the mean blood pressure in the target population
	MMOE = set MMOE threshold for acceptable precision of intercept 95% CI
				
*/

syntax ,  RSQuared(real) PARameters(int) TYPE(string) ///
			[Shrinkage(real 0.9) RATE(real 0) MEANFup(real 0) ///
			TIMEpoint(real 0) INTercept(real 0) SD(real 0) ///
			PREValence(real 0) MMOE(real 1.1)]


***********************************************

if "`type'"=="b" {
	binary_samp_size, rsq(`rsquared') par(`parameters') prev(`prevalence') ///
		s(`shrinkage')
	
	// return list
	return scalar final_shrinkage = r(final_shrinkage)
	return scalar sample_size = r(sample_size)
	return scalar parameters = r(parameters)
	return scalar r2 = r(r2a)
	return scalar max_r2 = r(max_r2a)
	return scalar events = r(events)
	return scalar EPP = r(EPP)
	return scalar prevalence = r(prevalence)
	
	mat def binary_samp_size_results = r(results)
	return mat results = binary_samp_size_results
	}
	else if "`type'"=="c" {
		
***********************************************


	continuous_samp_size , rsq(`rsquared') par(`parameters') int(`intercept') ///
		sd(`sd') s(`shrinkage') mmoe(`mmoe')
	
	return scalar final_shrinkage = r(final_shrinkage)
	return scalar sample_size = r(sample_size)
	return scalar parameters = r(parameters)
	return scalar r2 = r(r2a)
	return scalar SPP = r(SPP)
	return scalar int_mmoe = r(int_mmoe)
	return scalar var_mmoe = r(var_mmoe)
	
	mat def continuous_samp_size_results = r(results)
	return mat results = continuous_samp_size_results
	}
	else if "`type'"=="s" {
		
***********************************************


	survival_samp_size , rsq(`rsquared') par(`parameters') rate(`rate') ///
		time(`timepoint') meanfup(`meanfup') s(`shrinkage') 
	
	// return list
	return scalar final_shrinkage = r(final_shrinkage)
	return scalar sample_size = r(sample_size)
	return scalar parameters = r(parameters)
	return scalar r2 = r(r2a)
	return scalar max_r2 = r(max_r2a)
	return scalar events = r(events)
	return scalar EPP = r(EPP)
	return scalar rate = r(rate)
	return scalar int_uci = r(int_uci)
	return scalar int_lci = r(int_lci)
	return scalar int_cuminc = r(int_cuminc)
	
	mat def survival_samp_size_results = r(results)
	return mat results = survival_samp_size_results
	}
	else {
		di as err "Model type must be either b, s or c (binary, survival, continuous)"
		error 499
		}
	
***********************************************
		
end

******* start of binary
program define binary_samp_size, rclass

version 12.1

/* Syntax
	RSQUARED = R-sq adjusted
	PARAMETERS = number of parameters to be estimated in model
	PREVALENCE = prevalence of outcome 
	SHRINKAGE = required shrinkage of development model
*/

syntax ,  RSQuared(real) PARameters(int) ///
			PREValence(real) [Shrinkage(real 0.9)] 

local r2a = `rsquared'
local n1 = `parameters'
local n2 = `parameters'
local n3 = `parameters'

	// criteria 1 - shrinkage
	local n1 = ceil((`parameters'/((`shrinkage'-1)*(ln(1-(`r2a'/`shrinkage'))))))
	local shrinkage_1 = `shrinkage'
	local E1 = `n1'*`prevalence'
	local epp1 = `E1'/`parameters'
	local EPP_1 = round(`epp1',.01)
	
	// criteria 2 - small absolute difference in r-sq adj
	local lnLnull = (`E1'*(ln(`E1'/`n1')))+((`n1'-`E1')*(ln(1-(`E1'/`n1'))))
	local max_r2a = round((1- exp((2*`lnLnull')/`n1')),.01)
	
	if `max_r2a'<`r2a' {
		di as err "User specified R-squared adjusted is larger than the maximum possible R-squared (=`max_r2a') as defined by equation 23 (Riley et al. 2018)"
		error 499
		}
	
	local s_4_small_diff = round((`r2a'/(`r2a'+(0.05*`max_r2a'))),.001)

		local n2 = ceil((`parameters'/((`s_4_small_diff'-1)*(ln(1-(`r2a'/`s_4_small_diff'))))))
		local shrinkage_2 = `s_4_small_diff'
		
		
		local E2 = `n2'*`prevalence'
		local epp2 = `E2'/`parameters'
		local EPP_2 = round(`epp2',.01)

		
	// criteria 3 - precise estimation of the intercept
	local n3 = ceil((((1.96/0.05)^2)*(`prevalence'*(1-`prevalence'))))
	
	local E3 = `n3'*`prevalence'
	local epp3 = `E3'/`parameters'
	local EPP_3 = round(`epp3',.01)
	
	if `shrinkage_2'> `shrinkage' {
		local shrinkage_3 = `shrinkage_2'
		}
		else {
			local shrinkage_3 = `shrinkage'
			}
		
// minimum n 
local nfinal = max(`n1',`n2',`n3')
local shrinkage_final = `shrinkage_3'
local E_final = `nfinal'*`prevalence'
local epp_final = `E_final'/`parameters'
local EPP_final = round(`epp_final',.01)

// return list
return scalar final_shrinkage = `shrinkage_final'
return scalar sample_size = `nfinal'
return scalar parameters = `parameters'
return scalar r2a = `r2a'
return scalar max_r2a = `max_r2a'
return scalar events = `E_final'
return scalar EPP = `EPP_final'
return scalar prevalence = `prevalence'

// output table & assumptions
di as txt "NB: Assuming 0.05 acceptable difference in apparent & adjusted R-squared"
di as txt "NB: Assuming 0.05 margin of error in estimation of intercept"
di as txt "NB: Events per Predictor Parameter (EPP) assumes prevalence = `prevalence'"
local res 1 2 3 final 
matrix Results = J(4,6,.)
local i=0
foreach r of local res {
	local ++i
	matrix Results[`i',1] = `n`r''
	matrix Results[`i',2] = `shrinkage_`r''
	matrix Results[`i',3] = `parameters'
	matrix Results[`i',4] = `r2a'
	matrix Results[`i',5] = `max_r2a'
	matrix Results[`i',6] = `EPP_`r''
	}
	mat colnames Results = "Samp_size" "Shrinkage" "Parameter" "Rsq" "Max_Rsq" "EPP"
	mat rownames Results = "Criteria 1" "Criteria 2" "Criteria 3" "Final"

matlist Results, lines(rowtotal)

return mat results = Results

local di_E_final = ceil(`E_final')
di _n "Minimum sample size required for new model development based on user inputs = `nfinal',"
di "with `di_E_final' events (assuming an outcome prevalence = `prevalence'), and an EPP = `EPP_final'"

end 	

******* end of binary

******* start of continuous
program define continuous_samp_size, rclass

version 12.1

/* Syntax
	RSQUARED = do not produce the onscreen output of performance stats
	PARAMETERS = number of parameters to be estimated in model
	SHRINKAGE = required shrinkage of development model
	INTERCEPT = the anticipated mean outcome value (e.g. mean blood pressure
					in the target population
	SD = population (null model) variance i.e. sigma(null) (e.g. variance 
				in the mean blood pressure in the target population
	
*/

syntax , RSQuared(real) PARameters(int) INTercept(real) SD(real) ///
			[Shrinkage(real 0.9) MMOE(real 1.1)] 

local r2a = `rsquared'
local n = `parameters'+2
local n1 = `parameters'+2

	// criteria 1
	local es = 1 + ((`parameters'-2)/(`n1'*(ln(1-((`r2a'*(`n1'-`parameters'-1))+`parameters')/(`n1'-1)))))

	while `es' < `shrinkage' { 
		local ++n1
		local es = 1 + ((`parameters'-2)/(`n1'*(ln(1-((`r2a'*(`n1'-`parameters'-1))+`parameters')/(`n1'-1)))))
		
		if `es'!=. & `es'>=`shrinkage' { 
			local shrinkage_1 = round(`es',.001)
			local n1 = `n1'
			local spp_1 = `n1'/`parameters'
			local SPP_1 = round(`spp_1',.01)
			continue, break
			}
		}
		
	// criteria 2 - small absolute difference in r-sq adj & r-sq app
	local n2 = 1+((`parameters'*(1-`r2a'))/0.05)
	local shrinkage_2 = `shrinkage'
	local spp_2 = `n2'/`parameters'
	local SPP_2 = round(`spp_2',.01)
		
	// criteria 3 - precise estimate of residual variance
	local n3 = 234
	local df = `n3'-`parameters'-1
	local chilow = `df'/(invchi2(`df',0.025))
	local chiupp = (invchi2(`df',0.975))/`df'
	local max = max(`chilow',`chiupp')
	local resvar_mmoe = `max'^.5
	if `resvar_mmoe'>`mmoe' {
		while `resvar_mmoe'>`mmoe' {
			local ++n3
			local df = `n3'-`parameters'-1
			local chilow = `df'/(invchi2(`df',0.025))
			local chiupp = (invchi2(`df',0.975))/`df'
			local max = max(`chilow',`chiupp')
			local resvar_mmoe = `max'^.5
			
				if `resvar_mmoe'<=`mmoe' { 
					local n3 = `n3'
					local shrinkage_3 = `shrinkage'
					local spp_3 = `n3'/`parameters'
					local SPP_3 = round(`spp_3',.01)
					continue, break
					}
			}
		}
		else {
			local n3 = `n3'
			local shrinkage_3 = `shrinkage'
			local spp_3 = `n3'/`parameters'
			local SPP_3 = round(`spp_3',.01)
			}
	
	// criteria 4 - precise estimation of intercept
	local n4 = max(`n1',`n2',`n3')
	local df = `n4'-`parameters'-1
	local uci = `intercept'+((((`sd'*(1-`r2a'))/`n4')^.5)*(invttail(`df',0.025)))
	local lci = `intercept'-((((`sd'*(1-`r2a'))/`n4')^.5)*(invttail(`df',0.025)))
	local int_mmoe = `uci'/`intercept'
	if `int_mmoe'>`mmoe' {
		while `int_mmoe'>`mmoe' {
			local ++n4
			local df = `n4'-`parameters'-1
			local uci = `intercept'+((((`sd'*(1-`r2a'))/`n4')^.5)*(invttail(`df',0.025)))
			local lci = `intercept'-((((`sd'*(1-`r2a'))/`n4')^.5)*(invttail(`df',0.025)))
			local int_mmoe = `uci'/`intercept'
			
				if `int_mmoe'<=`mmoe' { 
					local n4 = `n4'
					local shrinkage_4 = `shrinkage'
					local spp_4 = `n4'/`parameters'
					local SPP_4 = round(`spp_4',.01)
					local int_uci = round(`uci',.01)
					local int_lci = round(`lci',.01)
					continue, break
					}
			}
		}
		else {
			local n4 = `n4'
			local shrinkage_4 = `shrinkage'
			local spp_4 = `n4'/`parameters'
			local SPP_4 = round(`spp_4',.01)
			local int_uci = round(`uci',.01)
			local int_lci = round(`lci',.01)
			}
			
// minimum n 
local nfinal = max(`n1',`n2',`n3',`n4')	
local spp_final = `nfinal'/`parameters'
local SPP_final = round(`spp_final',.01)
if `n1'>=`n4' {
	local shrinkage_final = `shrinkage_1' 
	}
	else {
		local shrinkage_final = `shrinkage' 
		}
		
// return list
return scalar final_shrinkage = `shrinkage_final'
return scalar sample_size = `nfinal'
return scalar parameters = `parameters'
return scalar r2a = `r2a'
return scalar SPP = `SPP_final'
return scalar int_mmoe = `int_mmoe'
return scalar var_mmoe = `resvar_mmoe'

// output table & assumptions
di as txt "NB: Assuming 0.05 acceptable difference in apparent & adjusted R-squared"
di as txt "NB: Assuming MMOE<=`mmoe' in estimation of intercept & residual standard deviation"
di as txt "SPP - Subjects per Predictor Parameter"
local res 1 2 3 4 final 
matrix Results = J(5,5,.)
local i=0
foreach r of local res {
	local ++i
	matrix Results[`i',1] = `n`r''
	matrix Results[`i',2] = `shrinkage_`r''
	matrix Results[`i',3] = `parameters'
	matrix Results[`i',4] = `r2a'
	matrix Results[`i',5] = `SPP_`r''
	}
	mat colnames Results = "Samp_size" "Shrinkage" "Parameter" "Rsq" "SPP"
	mat rownames Results = "Criteria 1" "Criteria 2" "Criteria 3" "Criteria 4 *" "Final"

matlist Results, lines(rowtotal)

return mat results = Results

di _n "Minimum sample size required for new model development based on user inputs = `nfinal'"
di _n "* 95% CI for intercept = (`int_lci', `int_uci'), for sample size n=`n4'"
end 	

******* end of continuous


******* start of survival
program define survival_samp_size, rclass

version 12.1

/* Syntax
	RSQUARED = R-sq adjusted
	PARAMETERS = number of parameters to be estimated in model
	RATE = overall event rate in previous prediction model study
	TIMEPOINT = timepoint of interest for prediction
	MEANFUP = mean follow-up in previous prediction model study
	SHRINKAGE = required shrinkage of development model
*/

syntax ,  RSQuared(real) PARameters(int) ///
			RATE(real) MEANFup(real) TIMEpoint(real) [Shrinkage(real 0.9)] 

local n = 10000 // arbitrary value for n from original study for e.g.
local r2a = `rsquared'
local n1 = `parameters'
local n2 = `parameters'
local n3 = `parameters'
local tot_per_yrs = `meanfup'*`n'
local events = ceil(`rate'*`tot_per_yrs')

	// criteria 1 - shrinkage
	local n1 = ceil((`parameters'/((`shrinkage'-1)*(ln(1-(`r2a'/`shrinkage'))))))
	local shrinkage_1 = `shrinkage'
	local E1 = `n1'*`rate'*`meanfup'
	local epp1 = `E1'/`parameters'
	local EPP_1 = round(`epp1',.01)
	
	// criteria 2 - small absolute difference in r-sq adj
	local lnLnull = (`events'*(ln(`events'/`n')))-`events'
	local max_r2a = round((1- exp((2*`lnLnull')/`n')),.01)
	
	if `max_r2a'<`r2a' {
		di as err "User specified R-squared adjusted is larger than the maximum possible R-squared (=`max_r2a') as defined by equation 23 (Riley et al. 2018)"
		error 499
		}
	
	local s_4_small_diff = round((`r2a'/(`r2a'+(0.05*`max_r2a'))),.001)

		local n2 = ceil((`parameters'/((`s_4_small_diff'-1)*(ln(1-(`r2a'/`s_4_small_diff'))))))
		local shrinkage_2 = `s_4_small_diff'
		
		
		local E2 = `n2'*`rate'*`meanfup'
		local epp2 = `E2'/`parameters'
		local EPP_2 = round(`epp2',.01)

		
	// criteria 3 - precise estimation of the intercept
	local n3 = max(`n1',`n2')
	local tot_per_yrs = round(`meanfup'*`n3',.1)
	local uci = 1-(exp(-(`rate'+(1.96*((`rate'/(`tot_per_yrs'))^.5)))*`timepoint'))
	local lci = 1-(exp(-(`rate'-(1.96*((`rate'/(`tot_per_yrs'))^.5)))*`timepoint'))
	local cuminc = 1-(exp(`timepoint'*(`rate'*-1)))
	local risk_mmoe = `uci'-`cuminc'
	
	local n3 = `n3'
	local E3 = `n3'*`rate'*`meanfup'
	local epp3 = `E3'/`parameters'
	local EPP_3 = round(`epp3',.01)
	local int_uci = round(`uci',.001)
	local int_lci = round(`lci',.001)
	local int_cuminc = round(`cuminc',.001)
	
	if `shrinkage_2'> `shrinkage' {
		local shrinkage_3 = `shrinkage_2'
		}
		else {
			local shrinkage_3 = `shrinkage'
			}
		
// minimum n 
local nfinal = max(`n1',`n2',`n3')
local shrinkage_final = `shrinkage_3'
local E_final = `nfinal'*`rate'*`meanfup'
local epp_final = `E_final'/`parameters'
local EPP_final = round(`epp_final',.01)
local tot_per_yrs_final = round(`meanfup'*`nfinal',.1)

// return list
return scalar final_shrinkage = `shrinkage_final'
return scalar sample_size = `nfinal'
return scalar parameters = `parameters'
return scalar r2a = `r2a'
return scalar max_r2a = `max_r2a'
return scalar events = `E_final'
return scalar EPP = `EPP_final'
return scalar rate = `rate'
return scalar int_uci = `int_uci'
return scalar int_lci = `int_lci'
return scalar int_cuminc = `int_cuminc'

// output table & assumptions
di as txt "NB: Assuming 0.05 acceptable difference in apparent & adjusted R-squared"
di as txt "NB: Assuming 0.05 margin of error in estimation of overall risk at time point = `timepoint'"
di as txt "NB: Events per Predictor Parameter (EPP) assumes overall event rate = `rate'"
local res 1 2 3 final 
matrix Results = J(4,6,.)
local i=0
foreach r of local res {
	local ++i
	matrix Results[`i',1] = `n`r''
	matrix Results[`i',2] = `shrinkage_`r''
	matrix Results[`i',3] = `parameters'
	matrix Results[`i',4] = `r2a'
	matrix Results[`i',5] = `max_r2a'
	matrix Results[`i',6] = `EPP_`r''
	}
	mat colnames Results = "Samp_size" "Shrinkage" "Parameter" "Rsq" "Max_Rsq" "EPP"
	mat rownames Results = "Criteria 1" "Criteria 2" "Criteria 3 *" "Final"

matlist Results, lines(rowtotal)

return mat results = Results

local di_E_final = ceil(`E_final')
di _n "Minimum sample size required for new model development based on user inputs = `nfinal',"
di "corresponding to `tot_per_yrs_final' person-time** of follow-up, with `di_E_final' outcome events"
di "assuming an overall event rate = `rate', and therefore an EPP = `EPP_final'"
di _n "* 95% CI for overall risk = (`int_lci', `int_uci'), for true value of `int_cuminc' and sample size n=`n3'"
di _n "(**where time is in the units mean follow-up time was specified in)"
end 	

******* end of survival


