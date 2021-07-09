*! version 1.0.2  08mar2019 
program define estudy
        version 13

syntax  anything(id="varlist" equalok) , /// 
		DATevar(varlist max=1) ///
		EVDate(str) ///
		DATEFormat(str) ///
        LB1(numlist max=1 integer) UB1(numlist max=1 integer) ///
		[LB2(numlist max=1 integer) UB2(numlist max=1 integer) ///
		LB3(numlist max=1 integer) UB3(numlist max=1 integer) ///
		LB4(numlist max=1 integer) UB4(numlist max=1 integer) ///
		LB5(numlist max=1 integer) UB5(numlist max=1 integer) ///
		LB6(numlist max=1 integer) UB6(numlist max=1 integer) ///
		INDexlist(varlist) ///
		DIAGNosticsstat(namelist max=1) ///
		ESWLBound(numlist max=1 integer) ///
		ESWUBound(numlist max=1 integer) ///
		MODType(namelist max=1) /// 
		DECimal(numlist max=1 integer) ///
		OUTPutfile(string) ///
		SUPPress(namelist max=1) ///
		SHOWPvalues ///
		NOStar ///
		MYDataset(string) ///
		]

tempvar obsn
qui gen `obsn' = _n /* Generate the ascending tempvar (1, 2, 3... N) obsn */
	 
local p 0
tokenize `anything', parse("()")
forvalues i=1/1000000000 {
	if "``i''" == ""  {
		continue, break
	}
	if "``i''" != "("  { /* Tokenize the specified varlists */
		if "``i''" != ")" {
			if "``i''" != "" {
				local ++p
				local varlist_n_`p' ``i''
			}
		}
	}
}
*

/* Check if the specified date variable has a date format */
qui ds `datevar', has(format %t*)
tempvar date_check_1
tempvar date_check_2
qui gen `date_check_1' = r(varlist)
tokenize `date_check_1'
qui gen `date_check_2' = `1' 

capture confirm str variable `date_check_2'
if _rc != 0 {
	disp as err "The specified Datevar is not in date format"
	exit 451 /* Invalid values for time variable */
}
*
if "`suppress'" != "" {
	if "`suppress'" != "group" {
		if "`suppress'" != "ind" { 
			disp as err "Option Suppress misspecified"
			exit 198 /* Option incorrectly specified */
		}
	}
}
if strlen("`dateformat'") == 3 {
	if "`dateformat'" != "DMY" { 
		if "`dateformat'" != "MDY" {
			if "`dateformat'" != "YMD" {
				disp as err "The specified date format is not allowed"
				exit 198 /* Option incorrectly specified */
			}
		}
	}
}
else {
	disp as err "The specified date format is too long: only DMY, MDY, and YMD are allowed"
	exit 198 /* Option incorrectly specified */
}
if strlen("`evdate'") !=8 {
	disp as err "The event date must be 8 characters long"
	exit 198 /* Option incorrectly specified */
}
*
local zzz 1
forvalues z=1/`p' {
	local varlist `varlist_n_`z''
	local nind : word count `indexlist' /* nind is the index/indexes used to compute the normal returns */
	local nvars : word count `varlist' /* nvars is the number of rows in the final table */
	if `nvars' > 1 {
		tempvar portfolio_model 
		qui egen `portfolio_model' = rowmean(`varlist')
		label var `portfolio_model' "Ptf CARs n `z' (`nvars' securities)"
	}
	if "`suppress'" == "ind" & `nvars' == 1 { /* Condition to hide CARs. Only CAARs are shown*/
		disp as error "Suppress cannot be used with only 1 variable specified in varlist"
		exit 198 /* Option incorrectly specified */
	}
	local day = dow(date("`evdate'","`dateformat'"))
	if `day' != 0 & `day' != 6 { /* Check if the specified date is missing (holiday) */
		qui count if `datevar' == date("`evdate'","`dateformat'")
		if r(N) == 0 {
			disp as err "The specified date is missing in the database: check whether it is a holiday or the dateformat is not adequate to the evdate"
			exit 416 /* Missing values encountered */
		}
	}
	if "`decimal'" != "" {  /* Use the number of decimal specified by the user */
		local n_dec = "`decimal'"
	}
	else {
		local n_dec = 2
	}
	if `n_dec' > 7 {  /* Return an error message if the number of decimals is greater than the maximum (7) */
		disp as err "The number of decimals must be maximum 7"
		exit 198 /* Option incorrectly specified */
	}
	if date("`evdate'","`dateformat'") < `datevar' in 1 {  /* Check if the date is before the sample period */
		disp as err "The specified event date is before the sample period"
		exit 198 /* Option incorrectly specified */ 
	}
	else if date("`evdate'","`dateformat'") > `datevar'[_N] { /* Check if the date if after the sample period */
		disp as err "The specified event date is after the sample period"
		exit 198 /* Option incorrectly specified */ 
	}
	local nn=1 
	while `nn'<7 {
		if "`lb`nn''" != "" & "`ub`nn''" != "" { /* Count the number of specified event windows */
			local num_ev_wdws = `nn'
			local nn=`nn'+1
		}
		else if ("`lb`nn''" != "" & "`ub`nn''" == "") | ("`lb`nn''" == "" & "`ub`nn''" != "") { /* Check if both bounds of the event windows are specified are specified */
			disp as err "Both upper and lower bound must be specified"
			exit 198 /* Option incorrectly specified */
		}
		else {
			forvalues mm=`nn'/6 {
				if ("`lb`mm''" != "" | "`ub`mm''" != "") | ("`lb`mm''" != "" & "`ub`mm''" != "") { /* Check if event windows are specified in ascenging order */
					disp as err "Event windows must be specified in ascending order: 1, 2, 3..."
					exit 198 /* Option incorrectly specified */
				}
			}
			local nn=7
		}
	}
	forvalues i=1/`num_ev_wdws' { /* Allocate the specified event windows */
		local evlbound_`i' = "`lb`i''"
		local evubound_`i' = "`ub`i''"
	}
	tempvar event
	if `day' == 0 { /* Check if the event date falls on sunday and adjust the event windows accordingly */
		if `z'==1 {
			disp as err "The event date falls on a Sunday" as text ""
		}
		local date_aux = date("`evdate'","`dateformat'")
		local date_aux = `date_aux'+1
		qui count if `datevar' == `date_aux' 
		if r(N) == 0 {
			disp as err "The first Monday after the event date is missing"
			exit 416 /* Missing values encountered */
		}
		qui gen `event'=0 if `datevar'==`date_aux'
		qui levelsof `obsn' if `event'==0 , local(levels)
		foreach l of local levels {
			qui replace `event'=`obsn'-`l'
		}
		qui replace `event'=`event' + 1 if `event'>= 0 /* Generate the ascending tempvar event equal to zero in the event date (...-2, -1, 1, 2, ... since the event date falls on sunday) */
	}
	else if `day' == 6 { /* Check if the event date falls on saturday and adjust the event windows accordingly */
		if `z' == 1 {
			disp as err "The event date falls on a Saturday" as text ""
		}
		local date_aux = date("`evdate'","`dateformat'")
		local date_aux = `date_aux'+2
		qui count if `datevar' == `date_aux' 
		if r(N) == 0 {
			disp as err "The first Monday after the event date is missing"
			exit 416 /* Missing values encountered */
		}
		qui gen `event'=0 if `datevar'==`date_aux'
		qui levelsof `obsn' if `event'==0 , local(levels)
		foreach l of local levels {
			qui replace `event'=`obsn'-`l'
		}
		qui replace `event'=`event' + 1 if `event'>= 0 /* Generate the ascending tempvar event equal to zero in the event date (...-2, -1, 1, 2, ... since the event date falls on saturday) */
	}
	else { /* Generate the ascending tempvar equal to zero in the event date (...-2, -1, 0, 1, 2, ...) */
		qui gen `event'=0 if `datevar'==date("`evdate'","`dateformat'")
		qui levelsof `obsn' if `event'==0 , local(levels)
		foreach l of local levels {
			qui replace `event'=`obsn'-`l'
		}
	}
	local upp_bound = "`eswubound'" /* Allocate the specified upper bound of the estimation window */
	local low_bound = "`eswlbound'" /* Allocate the specified lower bound of the estimation window */
	if "`upp_bound'" == "" { /* Set the upper bound of the event window equal to -30 if not specified */
		local upp_bound = -30
		if `z' == 1 {
			disp as err "By default the upper bound of the estimation window has been set to (-30)" as text ""
		}
	}
	if `upp_bound' > -2 { /* Check if the estimation window is too close or after the event date */
		disp as err "The estimation window is either too close or after the event date" 
		exit 198 /* Option incorrectly specified */ 
	}
	if "`low_bound'" == "" { /* Set the lower bound of the estimation window equal to the first available value */
		local low_bound = `event' in 1
	}
	if `low_bound' < `event' in 1 { /* Check if the specified lower bound of the estimation window pertains to the sample */
		disp as err "The specified lower bound is outside the sample extension"
		exit 198 /* Option incorrectly specified */ 
	}
	if `low_bound' >= `upp_bound' { /* Check if the boundaries of the estimation window are correctly specified */
		disp as err "The lower bound of the estimation window exceeds the upper bound"
		exit 198 /* Option incorrectly specified */ 
	}
	else if `upp_bound' - `low_bound' < 25 { /* Check if the estimation window is too small */
		if `z' == 1 {
			disp as err "Warning: the length of the specified estimation window is shorter than 25 trading days" as text ""
		}
	}
	forvalues i=1/`num_ev_wdws' {
		if `evlbound_`i'' < `upp_bound' { /* Check if estimation and events windows overlap */
			disp as error "The lower bound of the event window n. `i' overlaps the estimation window"
			exit 198 /* Option incorrectly specified */ 
		}
		else if `evlbound_`i'' == `upp_bound' { /* Check if estimation and event windows overlap */
			if `z' == 1 {
				disp as error "The lower bound of the event window n. `i' corresponds to upper bound of the estimation window" as text ""
			}
		}
	}
	forvalues i=1/`num_ev_wdws' { /* Check if the boundaries of the event windows are correctly specified */
		if `evlbound_`i'' > `evubound_`i'' {
			disp as error "The lower bound of the event window n. `i' exceeds the upper bound" 
			exit 198 /* Option incorrectly specified */ 
		}
		if `evubound_`i'' > `event'[_N] {
			disp as err "The upper bound of the event window n. `i' is outside the sample extension"
			exit 198 /* Option incorrectly specified */ 
		}
	}
	*Models can be: SIM (Single Index Model, default); MFM (Market Model) HMM (Historical Mean); MAM (Market Adjusted)
	if "`modtype'" == "" | "`modtype'" == "SIM" { /* Compute ARs according to the market model */
		if "`indexlist'" == "" {
			disp as err "Indexlist must be specified"
			exit 102 /* Too few variables specified */ 
		}
		if `nind'>1 {
			disp as err "Single Index Model requires only 1 index"
			exit 103 /* Too many variables specified */
		}
		tokenize "`varlist'" 
		forvalues i = 1/`nvars' {
			qui regress ``i'' `indexlist' if `event'<=`upp_bound' & `event'>=`low_bound'
			tempvar ar_`i'
			qui predict `ar_`i'' , resid
			_crcslbl `ar_`i'' ``i'' 
		}
		if `nvars' > 1 { /* Compute the portfolio ARs */
			local nvars=`nvars' + 1 
			qui regress `portfolio_model' `indexlist' if `event'<=`upp_bound' & `event'>=`low_bound' 
			tempvar ar_`nvars' 
			qui predict `ar_`nvars'', resid 
			_crcslbl `ar_`nvars'' `portfolio_model'
		}
	}
	else if "`modtype'" == "MFM" { /* Compute ARs according to the market model */
		if "`indexlist'" == "" {
			disp as err "Indexlist must be specified"
			exit 100 /* Varlist required */
		}
		tokenize "`varlist'" 
		forvalues i = 1/`nvars' {
			qui regress ``i'' `indexlist' if `event'<=`upp_bound' & `event'>=`low_bound'
			tempvar ar_`i'
			qui predict `ar_`i'' , resid
			_crcslbl `ar_`i'' ``i'' 
		}
		if `nvars' > 1 { /* Compute the portfolio ARs */ 
			local nvars=`nvars' + 1 
			qui regress `portfolio_model' `indexlist' if `event'<=`upp_bound' & `event'>=`low_bound' 
			tempvar ar_`nvars' 
			qui predict `ar_`nvars'', resid 
			_crcslbl `ar_`nvars'' `portfolio_model'
		}
	}
	else if "`modtype'" == "HMM" { /* Compute ARs according to the historical mean model */
		tokenize "`varlist'" 
		forvalues i = 1/`nvars' {
			qui sum ``i'' if `event' <= `upp_bound' & `event' >= `low_bound'
			local hist_avg = r(mean)
			tempvar ar_`i'
			qui generate `ar_`i'' = ``i'' - `hist_avg'
			_crcslbl `ar_`i'' ``i'' 
		}
		if `nvars' > 1 { /* Compute the portfolio ARs */
			local nvars=`nvars' + 1 
			qui sum `portfolio_model' if `event'<=`upp_bound' & `event'>=`low_bound'
			local hist_avg = r(mean)
			tempvar ar_`nvars' 
			qui generate `ar_`nvars'' = `portfolio_model' - `hist_avg'
			_crcslbl `ar_`nvars'' `portfolio_model'
		}
	}
	else if "`modtype'" == "MAM" { /* Compute ARs according to the market adjusted model */
		if `nind' > 1 {
			disp as error "Only 1 index must be specified to adopt the Market Adjusted Model (MAM)"
			exit 103 /* Too many variables specified */
		}
		tokenize "`varlist'" 
		forvalues i = 1/`nvars' {
			tempvar ar_`i'
			qui generate `ar_`i'' = ``i'' - `indexlist'
			_crcslbl `ar_`i'' ``i'' 
		}
		if `nvars' > 1 { /* Compute the portfolio ARs */ 
			local nvars=`nvars' + 1 
			tempvar ar_`nvars' 
			qui generate `ar_`nvars'' = `portfolio_model' - `indexlist'
			_crcslbl `ar_`nvars'' `portfolio_model'
		}
	}
	else if "`modtype'" != "" { /* Check if the model is misspecified */
		disp as err "Model misspecified"
		exit 198 /* Option incorrectly specified */ 
	}
	
	forvalues i = 1/`nvars' {
		qui sum `ar_`i'' if `event' <= `upp_bound' & `event' >= `low_bound'
		scalar variance = r(Var) 
		scalar variance_`i'=variance 
		scalar m_ret_`i' = r(N)

		forvalues j=1/`num_ev_wdws' {
			qui sum `ar_`i'' if (`event' >= `evlbound_`j'' & `event' <= `evubound_`j'') 
			scalar car = r(sum)
			scalar num = r(N)
			scalar carvariance_`i'_`j' = num*variance
			if "`modtype'" == "" | "`modtype'" == "SIM" {
				qui sum `indexlist' if `event' <= `upp_bound' & `event' >= `low_bound'
				scalar mean_mkt_ret = r(mean)
				scalar var_mkt_ret = r(Var)
				scalar n_mkt_ret = r(N)
				scalar corr_fac_den = var_mkt_ret*n_mkt_ret
				tempvar mean_resid
				qui gen `mean_resid' = `indexlist' - mean_mkt_ret 
				qui sum `mean_resid' if `event' >= `evlbound_`j'' & `event' <= `evubound_`j''
				scalar corr_fac_num = r(sum)
				scalar corr_fac_num = corr_fac_num^2
				scalar carvariance_`i'_`j' = variance_`i' * (num + (num^2/m_ret_`i') + (corr_fac_num/corr_fac_den))
			}
			else if "`modtype'" == "HMM" {
				scalar carvariance_`i'_`j' = carvariance_`i'_`j' * (1 + num/m_ret_`i')
			}
			scalar sd = sqrt(carvariance_`i'_`j')	
			qui scalar zstat = car/sd
			qui scalar pval=2*(1-normal(abs(zstat)))
			scalar car_`i'_`j'=string(100 * car, "%12.`n_dec'f")
			scalar carvalue_`i'_`j' = car
			scalar pval_`i'_`j'=pval
			if "`nostar'" == "" {
				if pval<0.01 {
					scalar star_`i'_`j' = "%***"
				}
				else if pval<0.05 {
					scalar star_`i'_`j' = "%**"
				}
				else if pval<0.1 {
					scalar star_`i'_`j' = "%*"
				}
				else {
					scalar star_`i'_`j' = "%"
				}
			}
			else {
				scalar star_`i'_`j' = "%"
			}
		}
	}
	if `nvars' > 1 { /* Compute AARs and their variance under the Normality Hypothesis */ 
		local spec_vars = `nvars' - 1
		local nvars = `nvars'+1
		tempvar ar_`nvars'
		qui gen `ar_`nvars'' = .
		label var `ar_`nvars'' "CAAR group `z'  (`spec_vars' securities)"
		tempvar avgabret
		qui egen `avgabret' = rowmean(`ar_1'-`ar_`spec_vars'')
		
		qui sum `avgabret' if `event' <= `upp_bound' & `event' >= `low_bound'
		scalar m_ret_`nvars' = r(N)
		
		local num_err 0 
		scalar few_obs_err = 0
		forvalues i = 1/`nvars' {
			if m_ret_`i'<25{
				local ++num_err 
				if few_obs_err == 0 {
					local lab_err_`num_err' = `"`: var label `ar_`i'''"'
					scalar few_obs_err = 1
				}
				else {
					local lab_err_`num_err' = `"`: var label `ar_`i'''"'
				}
			}	
		}
		
		if few_obs_err == 1 {
			if `z' == 1 {
				disp as err "Less than 25 non-missing observations in the estimation window for the following variable(s):" as text
			}
			forvalues n_err=1/`num_err' {
				disp as input "Varlist n.`z' - `lab_err_`n_err''" as text
			}
		}
		
		forvalues j=1/`num_ev_wdws' {
			qui sum `avgabret' if (`event' >= `evlbound_`j'' & `event' <= `evubound_`j'') 
			scalar car = r(sum)
			scalar varsumcar_0_`j'=0
			forvalues k = 1/`spec_vars' {
				local kk = `k' - 1
				if carvariance_`k'_`j' == . {
					scalar varsumcar_`k'_`j' = varsumcar_`kk'_`j'
				}
				else {
					scalar varsumcar_`k'_`j' = varsumcar_`kk'_`j' + carvariance_`k'_`j'
				}
			}
			scalar car_`nvars'_`j'=string(100 * car, "%12.`n_dec'f")
			scalar carvalue_`nvars'_`j' = car
			scalar varcaar = varsumcar_`spec_vars'_`j'/(`spec_vars'^2)
			
			if "`diagnosticsstat'" == "" | "`diagnosticsstat'" == "Norm" { /* Diagnostic under the Normality Hypothesis */
				qui scalar zstat = car/sqrt(varcaar)
				qui scalar pval=2*(1-normal(abs(zstat)))
				qui scalar pval_`nvars'_`j'=pval
				if "`nostar'" == "" {
					if pval<0.01 {
						scalar star_`nvars'_`j' = "%***"
					}
					else if pval<0.05 {
						scalar star_`nvars'_`j' = "%**"
					}
					else if pval<0.1 {
						scalar star_`nvars'_`j' = "%*"
					}
					else {
						scalar star_`nvars'_`j' = "%"
					}
				}
				else {
					scalar star_`nvars'_`j' = "%"
				}
			}

			else if "`diagnosticsstat'" == "Patell" | "`diagnosticsstat'" == "ADJPatell" { /* Perform the Patell test */
				forvalues i=1/`spec_vars' {
					local ii = `i' - 1
					tempvar sar_`i' 
					qui sum `ar_`i'' if `event' >= `evlbound_`j'' & `event' <= `evubound_`j''
					scalar l2_`j'=r(N)
					qui gen `sar_`i''=`ar_`i''/sqrt(variance_`i'*l2_`j')
					qui sum `sar_`i'' if `event' >= `evlbound_`j'' & `event' <= `evubound_`j''
					scalar csar_`i'_`j'=r(sum)
					scalar sumcsar_0_`j' = 0
					if csar_`i'_`j' == . {
						scalar sumcsar_`i'_`j' = sumcsar_`ii'_`j'
					}
					else {
						scalar sumcsar_`i'_`j' = sumcsar_`ii'_`j' + csar_`i'_`j' 
					}
					local exp_vars = 1
					if "`modtype'" == "MFM" { 
						local exp_vars = `nind'
					}
					scalar var_csar_`i' = (m_ret_`i' - `exp_vars' - 1)/(m_ret_`i' - `exp_vars' - 3)
					scalar sum_var_csar_0 = 0
					if var_csar_`i' == . {
						scalar sum_var_csar_`i' = sum_var_csar_`ii'
					}
					else {
						scalar sum_var_csar_`i' = sum_var_csar_`ii' + var_csar_`i'
					}
				}
				scalar zpatell = sumcsar_`spec_vars'_`j' / sqrt(sum_var_csar_`spec_vars')
				if "`diagnosticsstat'" == "ADJPatell" { /* Perform the Adjusted Patell test */
					mata: C = J(`spec_vars', `spec_vars',.)
					forvalues ppp = 1/`=`spec_vars'-1' {
						forvalues kkk = `=`ppp'+1'/`spec_vars' { 
							qui corr `ar_`ppp'' `ar_`kkk'' if (`event' <= `upp_bound' & `event' >= `low_bound')
							mata: C[`kkk',`ppp'] = `r(rho)'
						}
					}
					mata : st_numscalar("rho_Kolari", mean(select(vech(C), vech(C) :< 1)))		
					scalar zpatell = zpatell/sqrt(1+(`spec_vars'-1)*rho_Kolari)
				}
				qui scalar pval=2*(1-normal(abs(zpatell)))
				qui scalar pval_`nvars'_`j'=pval
				if "`nostar'" == "" {
					if pval<0.01 {
						scalar star_`nvars'_`j' = "%***"
					}
					else if pval<0.05 {
						scalar star_`nvars'_`j' = "%**"
					}
					else if pval<0.1 {
						scalar star_`nvars'_`j' = "%*"
					}
					else {
						scalar star_`nvars'_`j' = "%"
					}
				}
				else {
					scalar star_`nvars'_`j' = "%"
				}
			}
			
			else if "`diagnosticsstat'" == "BMP" | "`diagnosticsstat'" == "KP" { /* Perform the Boehmer Musumeci Paulsen test */
				scalar sum_std_car_0_`j' = 0
				forvalues i=1/`spec_vars' {
					scalar std_car_`i'_`j' = carvalue_`i'_`j'/sqrt(carvariance_`i'_`j')
					local ii = `i' - 1
					if std_car_`i'_`j' == . {
						scalar sum_std_car_`i'_`j' = sum_std_car_`ii'_`j'
					}
					else {
						scalar sum_std_car_`i'_`j' = sum_std_car_`ii'_`j' + std_car_`i'_`j'
					}
				}
				scalar lined_scar_`j'=sum_std_car_`spec_vars'_`j'/`spec_vars'
				scalar sum_sq_dif_scar_0_`j' = 0
				forvalues i=1/`spec_vars' {
					scalar sq_dif_scar_`i'_`j' = (std_car_`i'_`j' - lined_scar_`j')^2
					local ii = `i' - 1
					if sq_dif_scar_`i'_`j' == . {
						scalar sum_sq_dif_scar_`i'_`j' = sum_sq_dif_scar_`ii'_`j'
					}
					else {
						scalar sum_sq_dif_scar_`i'_`j' = sum_sq_dif_scar_`ii'_`j' + sq_dif_scar_`i'_`j'
					}
				}
				scalar s_lined_scar_`j' = sqrt(sum_sq_dif_scar_`spec_vars'_`j'/(`spec_vars'-1))
				scalar zbmp = sqrt(`spec_vars')*(lined_scar_`j' / s_lined_scar_`j') 
			
				if "`diagnosticsstat'" == "KP" { /* Perform the Kolari and Pynnonen test */
					mata: C = J(`spec_vars', `spec_vars',.)
					forvalues ppp = 1/`=`spec_vars'-1' {
						forvalues kkk = `=`ppp'+1'/`spec_vars' { 
							qui corr `ar_`ppp'' `ar_`kkk'' if (`event' <= `upp_bound' & `event' >= `low_bound')
							mata: C[`kkk',`ppp'] = `r(rho)'
						}
					}
					mata : st_numscalar("rho_Kolari", mean(select(vech(C), vech(C) :< 1)))
					scalar zbmp = zbmp * sqrt((1-rho_Kolari)/(1+(`spec_vars'-1)*rho_Kolari)) 
				}
				qui scalar pval=2*(1-normal(abs(zbmp)))
				qui scalar pval_`nvars'_`j'=pval
				if "`nostar'" == "" {
					if pval<0.01 {
						scalar star_`nvars'_`j' = "%***"
					}
					else if pval<0.05 {
						scalar star_`nvars'_`j' = "%**"
					}
					else if pval<0.1 {
						scalar star_`nvars'_`j' = "%*"
					}
					else {
						scalar star_`nvars'_`j' = "%"
					}
				}
				else {
					scalar star_`nvars'_`j' = "%"
				}
			}
		
			else if "`diagnosticsstat'" == "GRANK" { /* Perform the Generalized RANK test */
				scalar sum_std_car_0_`j' = 0
				scalar sum_sq_dif_scar_0_`j' = 0
				forvalues i=1/`spec_vars' {
					tempvar stdar_`i'_`j'
					qui gen `stdar_`i'_`j'' = .
					qui replace `stdar_`i'_`j'' = `ar_`i''/sqrt(variance_`i') if (`event' <= `upp_bound' & `event' >= `low_bound')
					qui scalar std_car_`i'_`j' = carvalue_`i'_`j'/sqrt(carvariance_`i'_`j')	
					local ii = `i' - 1
					if std_car_`i'_`j' == . {
						scalar sum_std_car_`i'_`j' = sum_std_car_`ii'_`j'
					}
					else {
						scalar sum_std_car_`i'_`j' = sum_std_car_`ii'_`j' + std_car_`i'_`j'
					}
				}
				scalar lined_scar_`j'=sum_std_car_`spec_vars'_`j'/`spec_vars'
				scalar sum_sq_dif_scar_0_`j' = 0
				forvalues i=1/`spec_vars' {
					scalar sq_dif_scar_`i'_`j' = (std_car_`i'_`j' - lined_scar_`j')^2
					local ii = `i' - 1
					if sq_dif_scar_`i'_`j' == . {
						scalar sum_sq_dif_scar_`i'_`j' = sum_sq_dif_scar_`ii'_`j'
					}
					else {
						scalar sum_sq_dif_scar_`i'_`j' = sum_sq_dif_scar_`ii'_`j' + sq_dif_scar_`i'_`j'
					}
				}
				scalar csec_sd_scar_`j' = sqrt(sum_sq_dif_scar_`spec_vars'_`j'/(`spec_vars'-1))
				forvalues i=1/`spec_vars' {
					qui replace `stdar_`i'_`j'' = std_car_`i'_`j'/csec_sd_scar_`j' if `event' == `=`upp_bound'+1'
					qui tempvar u_`i'_`j'	
					qui egen `u_`i'_`j'' = rank(`stdar_`i'_`j'')
					qui replace `u_`i'_`j'' = `u_`i'_`j''/(`upp_bound'-`low_bound'+2) - 0.5
				}
				tempvar lined_u_`j'
				tempvar num_lined_u_`j'
				tempvar den_lined_u_`j'
				tempvar sq_lined_u_`j'
				qui egen `num_lined_u_`j'' = rowtotal(`u_1_`j''-`u_`spec_vars'_`j'')
				qui egen `den_lined_u_`j'' = rownonmiss(`u_1_`j''-`u_`spec_vars'_`j'')
				qui gen `lined_u_`j'' = `num_lined_u_`j'' / `den_lined_u_`j''
				qui egen `sq_lined_u_`j'' = rownonmiss(`u_1_`j''-`u_`spec_vars'_`j'')
				qui replace `sq_lined_u_`j'' = `sq_lined_u_`j'' /`spec_vars' * `lined_u_`j''^2
				qui sum `sq_lined_u_`j''
				scalar s_u_lined_`j' = sqrt(r(sum)/(`upp_bound'-`low_bound'+1))
				qui sum `lined_u_`j'' if `event' == `=`upp_bound'+1'
				scalar u_lined_0_`j' = r(mean)
				scalar z_`j' = u_lined_0_`j'/s_u_lined_`j' 
				scalar t_grank_`j' = z_`j'*sqrt((`upp_bound'-`low_bound'-1)/(`upp_bound'-`low_bound'-z_`j'^2))
				scalar t_grank_dof_`j' = `upp_bound'-`low_bound' + 1 - 2
				qui scalar pval=2*ttail(t_grank_dof_`j',abs(t_grank_`j'))
				qui scalar pval_`nvars'_`j'=pval
				if "`nostar'" == "" {
					if pval<0.01 {
						scalar star_`nvars'_`j' = "%***"
					}
					else if pval<0.05 {
						scalar star_`nvars'_`j' = "%**"
					}
					else if pval<0.1 {
						scalar star_`nvars'_`j' = "%*"
					}
					else {
						scalar star_`nvars'_`j' = "%"
					}
				}
				else {
					scalar star_`nvars'_`j' = "%"
				}
			}
		
			else if "`diagnosticsstat'" == "Wilcoxon" { /* Perform the Wilcoxon test */
				tempvar wilcox_`j'
				forvalues i=1/`spec_vars' {
					tempvar abs_ar_`i'_`j'
					tempvar stdar_`i'_`j'
					tempvar rank_`i'_`j'
					qui gen `stdar_`i'_`j'' =.
					qui replace `stdar_`i'_`j'' = `ar_`i'' if (`event' <= `upp_bound' & `event' >= `low_bound')
					qui replace `stdar_`i'_`j'' = carvalue_`i'_`j' if `event' == `=`upp_bound'+1'
					qui gen `abs_ar_`i'_`j'' = abs(`stdar_`i'_`j'')
					qui egen `rank_`i'_`j'' = rank(`abs_ar_`i'_`j'')
					qui replace `rank_`i'_`j'' = . if `stdar_`i'_`j'' < 0
				}
				qui egen `wilcox_`j'' = rowtotal(`rank_1_`j''-`rank_`spec_vars'_`j'')
				qui sum `wilcox_`j'' if `event' == `=`upp_bound'+1'
				scalar wilcoxon_`j' = r(sum)
				scalar z_wilcoxon_`j' = (wilcoxon_`j'-`spec_vars'*(`spec_vars'+1)/4)/sqrt(`spec_vars'*(`spec_vars'+1)*(2*`spec_vars'+1)/24)
				qui scalar pval=2*(1-normal(abs(z_wilcoxon_`j')))
				qui scalar pval_`nvars'_`j'=pval
				if "`nostar'" == "" {
					if pval<0.01 {
						scalar star_`nvars'_`j' = "%***"
					}
					else if pval<0.05 {
						scalar star_`nvars'_`j' = "%**"
					}
					else if pval<0.1 {
						scalar star_`nvars'_`j' = "%*"
					}
					else {
						scalar star_`nvars'_`j' = "%"
					}
				}
				else {
					scalar star_`nvars'_`j' = "%"
				}
			}
		
			else if "`diagnosticsstat'" != "" { /* Check if the diagnostic stats is incorrectly specified */
				disp as error "Diagnosticstat is incorrectly specified" as text ""
				exit 198 /* Option incorrectly specified */ 
			}
		}
	}
	tempvar dim_label /* Compute the length of the longest label of the varlist */
	qui gen `dim_label' =.
	local i=1
	forvalues num = 1/`nvars' {
		tokenize "`varlist'" 
		local div_label : variable label `ar_`num''
		if strpos(`"`div_label'"', ".") > 0 {
			disp as err "The label of the variable ``num'' contains the invalid character '.'"
			exit 198 /* Option incorrectly specified */ 
		}
		
		local len_label : length local div_label
		if "`outputfile'" != "" | "`mydataset'" != "" {
			local max_lab_len 32
		}
		else {
			local max_lab_len 45
		}
		if `len_label' > `max_lab_len' {
			disp as err "Note: label of variable ``num'' truncated to `max_lab_len' characters" as text
			local div_label = substr(`"`div_label'"',1,`max_lab_len')
			label var `ar_`num'' `"`div_label'"'
			local len_label : length local div_label
		}
		qui capture set obs `num'
		qui replace `dim_label' = `len_label' in `num'
				
		if "`suppress'" == "group" {
			if `=`nvars'-`num'' > 1 {
				local otp_r_label_`zzz' : variable label `ar_`num'' /* Store variable labels for excel output except for groups */
				local ++zzz /* zzz is the number of variables to export */ 
			}
		}
		else if "`suppress'" == "ind" {
			if `=`nvars'-`num'' < 2 {
				local otp_r_label_`zzz' : variable label `ar_`num''  /* Store variable labels of groups only for excel output */
				local ++zzz 
			}
		}
		else {
			local otp_r_label_`zzz' : variable label `ar_`num'' /* Store all variable labels for excel output  */
			local ++zzz 
		}
	}
	local space = 3 /* Compute the minimum length of the column between the column label and the column content */
	local dist_1=`n_dec' + 9 + `space'
	local dist_2=14 + `space'
	if `dist_1' > `dist_2' {
		local dist = `dist_1'
	}
	else{
		local dist = `dist_2'
	}
	forvalues name=1/`num_ev_wdws'{ /* Construct the column labels */
		scalar namecol_`name' = "CAAR[`lb`name'',`ub`name'']"
		local namecol_`name' = "CAAR[`lb`name'',`ub`name'']"
		local opt_c_label_`name' = "CAAR(`lb`name'',`ub`name'')" /* Store col labels */ 
	}
	local num_cols = `num_ev_wdws' + 1 /* Set the column length according to the preeceding code */
	qui sum `dim_label'
	local cols1_`z' = r(max) + `space'
	local dist3 = `n_dec' + 4
	local dist4 = `dist' - 10
	local start_nvars = 1
	if "`suppress'" == "ind" { /* Condition to hide single CARs */
		local start_nvars = `nvars'-1
	}
	else if "`suppress'" == "group" { 
		local nvars = `nvars' - 2
	}
	if "`diagnosticsstat'" == "" | "`diagnosticsstat'" == "Norm" {
		local str_diagn = "under the Normality assumption"
	}
	else if "`diagnosticsstat'" == "Patell" {
		local str_diagn = "using the Patell test"
	}
	else if "`diagnosticsstat'" == "ADPatell" {
		local str_diagn = "using the Patell test, with the Kolari and Pynnonen adjustment"
	}
	else if "`diagnosticsstat'" == "BMP" {
		local str_diagn = "using the Boehmer, Musumeci, Poulsen test"
	}
	else if "`diagnosticsstat'" == "KP" {
		local str_diagn = "using the Boehmer, Musumeci, Poulsen test, with the Kolari and Pynnonen adjustment"
	}
	else if "`diagnosticsstat'" == "Wilcoxon" {
		local str_diagn = "using the Generalised SIGN test by Wilcoxon"
	}
	else if "`diagnosticsstat'" == "GRANK" {
		local str_diagn = "using the Generalised Rank test by Kolari and Pynnonen"
	}
	local nvars_`z' = `nvars'
	local start_nvars_`z' = `start_nvars'
	forvalues i=1/`nvars' {
		tempvar ar_`z'_`i'
		rename `ar_`i'' `ar_`z'_`i'' 
		forvalues j = 1/`num_ev_wdws' {
			scalar car_`z'_`i'_`j' = car_`i'_`j'
			scalar star_`z'_`i'_`j' = star_`i'_`j'
			scalar pval_`z'_`i'_`j' = "(" + string(pval_`i'_`j' , "%5.4f") + ")" 
			scalar pval_value_`z'_`i'_`j' = pval_`i'_`j'
			if "`outputfile'" != "" | "`mydataset'" != "" {
				local car_`i'_`j' = carvalue_`i'_`j'
				local pval_`i'_`j' = pval_`i'_`j'
				
			}
		}
	}
	if "`outputfile'" != "" | "`mydataset'" != "" {
		mata: CAR_`z' = J(`=`nvars'-`start_nvars'+1', `num_ev_wdws',.)
		mata: PVAL_`z' = J(`=`nvars'-`start_nvars'+1',`num_ev_wdws',.)
		forvalues iii = 1/`=`nvars'-`start_nvars'+1' {
			forvalues jjj=1/`num_ev_wdws' {
				mata: CAR_`z'[`iii',`jjj'] = `car_`=`iii' + `start_nvars' -1'_`jjj''
				mata: PVAL_`z'[`iii',`jjj'] = `pval_`=`iii'+`start_nvars'-1'_`jjj''
			}
		}
		if `z' == 1{
			mata: CAR = CAR_`z'
			mata: PVAL = PVAL_`z'
		}
		else{
			mata: CAR = (CAR\CAR_`z')
			mata: PVAL = (PVAL\PVAL_`z')
		}
	}
}
*
local cols1_0 = 0
forvalues z=1/`p' {
	local zz = `z' - 1
	if `cols1_`z'' > `cols1_`zz'' {
		local cols1 = `cols1_`z''
	}
	else {
		local cols1 = `cols1_`zz''
	}
}
if "`suppress'" == "ind" { 
	local cols1 = 35 /* Length of first column when suppress "ind" is specified */
}
forvalues n=2/`num_cols' {
	local m=`n'-1
	local cols`n' = `cols`m'' + `dist'
} 
*
local width = `cols1' + (`num_cols')*(`dist' - `space')
forvalues z = 1/`p' {
	if `z'==1 {
		disp as text "Event date: " as result %td date("`evdate'","`dateformat'") as text ", with " ///
		as result `num_ev_wdws' as text " event windows specified, `str_diagn'"
		noisily display _column(1)  "SECURITY" _continue
		forvalues k=1/`num_ev_wdws' {
			if `k' != `num_ev_wdws' {
				noisily display _column(`cols`k'') %`dist4's namecol_`k' _column(`cols`k'') _continue
			}
			else {
				noisily display _column(`cols`k'') %`dist4's namecol_`k' _column(`cols`k'')
			}
		}
	}
	forvalues num = `start_nvars_`z''/`nvars_`z'' {
		local div_label : variable label `ar_`z'_`num''
		local names_col_`z'_`num' : variable label `ar_`z'_`num''
		noisily display _column(1)   "`div_label' " _continue
		forvalues kk=1/`num_ev_wdws' {
			if `kk' != `num_ev_wdws' {
				noisily display _column(`cols`kk'')  %`dist3's scalar(car_`z'_`num'_`kk') _column(`cols`kk'') scalar(star_`z'_`num'_`kk') _continue
			}
			else {
				noisily display _column(`cols`kk'')  %`dist3's scalar(car_`z'_`num'_`kk') _column(`cols`kk'') scalar(star_`z'_`num'_`kk')
			}
		}
		if "`showpvalues'" != "" {
			forvalues kk=1/`num_ev_wdws' {
				if `kk' != `num_ev_wdws' {
					noisily display _column(`cols`kk'')  %~12s pval_`z'_`num'_`kk' _continue
				}
				else {
					noisily display _column(`cols`kk'')  %~12s pval_`z'_`num'_`kk'
				}
			}
		}
	}
	di as text "{hline `width'}"
}
if "`nostar'" == "" {
	disp as text "*** p-value < .01, ** p-value <.05, * p-value <.1"
}
if "`showpvalues'" != "" {
	disp as text "p-values in parentheses"
}
*

if "`outputfile'" != "" | "`mydataset'" != "" {
	mata: st_matrix("S_CAR", CAR)
	mata: st_matrix("P_VAL", PVAL)
	forvalues i=1/`=rowsof(S_CAR)' {
		local rnames `"`rnames'"`otp_r_label_`i''" "'
	}
	mat rownames S_CAR=`rnames'
	mat rownames P_VAL=`rnames'
	forvalues ii=1/`=colsof(S_CAR)' {
		local cnames `"`cnames'"`opt_c_label_`ii''" "'
	}
	mat colnames S_CAR=`cnames'
	mat colnames P_VAL=`cnames'
	
	if "`outputfile'" != "" {
		qui putexcel A1=matrix(S_CAR, names) using "`outputfile'", sheet("CAR") replace
		qui putexcel A1=matrix(P_VAL, names) using "`outputfile'", sheet("PVALUES") modify
	}
	
	if "`mydataset'" != "" {
		tempvar security_name
		qui gen `security_name' = ""
		forvalues i=1/`=`zzz'-1' {
			qui capture set obs `i'
			qui replace `security_name' = "`otp_r_label_`i''" in `i'
		}
	
		tempvar event_window_
		svmat S_CAR, names(`event_window_')
		preserve
		qui keep `security_name' `event_window_'*
		qui gen security_name=`security_name'
		label var security_name "Security Name"
		forvalues i=1/`num_ev_wdws'{
			capture qui gen event_wdw_`i' = `event_window_'`i'
			capture label var event_wdw_`i' "`namecol_`i''"
		}
		drop `security_name' `event_window_'*
		qui keep in 1/`=`zzz'-1'
		save "`mydataset'", replace
		restore
	}
}
*

qui gsort+ `obsn'
qui capture drop if `obsn' == .
qui mata: mata clear
qui scalar drop _all
clear results
end
exit
