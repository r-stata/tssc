*! bfmsvycorr v0.0.0.9000 Thomas Blanchet, Ignacio Flores, Marc Morgan

program bfmcorr, eclass
	version 11
	syntax using/, Weight(varname) INCome(varname) HOUseholds(varname) TAXUnit(string) ///
		[TAXINCome(varname) ///
		HOLDMARgins(varlist) VARMARgins(varlist) FREQMARgins(numlist >0 <1) ///
		INCOMECOMPosition(string) INCOMEPOPulation(string) ///
		TRUSTstart(string) MERGingpoint(string) ///
		TAXPerc(name) TAXThr(name) TAXAvg(name) THETALIMit(real 5) MINBracket(real 10) ///
		NOREPlace Knn(real 10) SAMPletop(real 0.1) ///
		SLope(real -1) PEnalization(real 20)]
	
	// ---------------------------------------------------------------------- //
	// Check validity of the input data and arguments
	// ---------------------------------------------------------------------- //
	
	// Tax data file exists
	confirm file "`using'"
	if ("`incomecomposition'" != "") {
		confirm file "`incomecomposition'"
	}
	if ("`incomepopulation'" != "") {
		confirm file "`incomepopulation'"
	}
	
	// No weights missing
	capture assert !missing(`weight')
	if (_rc) {
		display as error "weights must be nonmissing"
		exit 416
	}
	
	// No weights below one
	capture assert (`weight' >= 1)
	if (_rc) {
		display as error "weights must be greater or equal to one", _continue
		display as error "(they should sum to the population size)"
		exit 498
	}
	
	// The tax unit is either individuals or households
	if !inlist(substr("`taxunit'", 1, 1), "i", "h") {
		display as error "option 'taxunit' incorrectly specified:", _continue
		display as error "must start with 'i' (for individuals) or 'h' (for households)"
		exit 198
	}
	
	// We have a value for all the new margins
	if ("`varmargins'" != "") {
		foreach v of varlist `varmargins' {
			quietly levelsof `v', local(values) clean
			if ("`values'" != "0 1") {
				display as error "the option varmargins(...) only supports", _continue
				display as error "dummy variables (equal to 0 or 1) and must", _continue
				display as error "take both values at least once"
				exit 450
			}
		}
		local nb_varmargins: word count `varmargins'
		local nb_freqmargins: word count `freqmargins'
		if (`nb_varmargins' != `nb_freqmargins') {
			display as error "the options varmargins(...) and", _continue
			display as error "freqmargins(...) must have the same size"
			exit 198
		}
	}
	
	// Tax unit is valid
	if (substr("`taxunit'", 1, 1) == "i") {
		local taxunit "i"
	}
	else if (substr("`taxunit'", 1, 1) == "h") {
		local taxunit "h"
	}
	else {
		display as error "option taxunit(...) incorrectly specified:", _continue
		display as error "must start with 'i' (for individals) or 'h' (for households)"
		exit 198
	}
	
	// Weights and income variables are consistent with the statistical unit
	sort `households' `weight'
	tempvar nvals_weight
	quietly by `households' `weight': generate `nvals_weight' = (_n == 1)
    quietly by `households': replace `nvals_weight' = sum(`nvals_weight')
    quietly by `households': replace `nvals_weight' = `nvals_weight'[_N]
	
	capture assert `nvals_weight' == 1
	if (_rc != 0) {
		display as error "weights not constant within households"
		exit 407
	}
	if ("`taxunit'" == "h") {
		sort `households' `income'
		tempvar nvals_income
		quietly by `households' `income': generate `nvals_income' = (_n == 1)
		quietly by `households': replace `nvals_income' = sum(`nvals_income')
		quietly by `households': replace `nvals_income' = `nvals_income'[_N]
		capture assert `nvals_income' == 1
		if (_rc != 0) {
			display as error "you specified the option taxunit(h), yet `income'", _continue
			display as error "is not constant within households"
			exit 459
		}
		drop `nvals_income'
		
		if ("`taxincome'" != "") {
			sort `households' `taxincome'
			tempvar nvals_income
			quietly by `households' `taxincome': generate `nvals_income' = (_n == 1)
			quietly by `households': replace `nvals_income' = sum(`nvals_income')
			quietly by `households': replace `nvals_income' = `nvals_income'[_N]
			capture assert `nvals_income' == 1
			if (_rc != 0) {
				display as error "you specified the option taxunit(h), yet `taxincome'", _continue
				display as error "is not constant within households"
				exit 459
			}
			drop `nvals_income'
		}
	}
	
	// Use income as tax income if taxincome() not specified
	if ("`taxincome'" == "") {
		local taxincome `income'
	}
	
	// Trust region and merging point
	if ("`mergingpoint'" == "" | "`mergingpoint'" == "_auto") {
		if ("`truststart'" == "") {
			display as error "you must either specify the trust region of your tax data", _continue
			display as error "or specify the merging point directly"
			exit 198
		}
		
		confirm number `truststart'
		if (_rc != 0) {
			display as error "option truststart(...) must be a number"
			exit 198
		}
		
		if (`truststart' <= 0 | `truststart' >= 1) {
			display as error "option trustregion(...) incorrectly specified:", _continue
			display as error "must be between zero and one (excluded)"
			exit 198
		}
	}
	else {
		capture confirm number `mergingpoint'
		if (_rc != 0) {
			display as error "option mergingpoint(...) must be a number"
			exit 198
		}
		
		if (`mergingpoint' <= 0 | `mergingpoint' >= 1) {
			display as error "option mergingpoint(...) incorrectly specified:", _continue
			display as error "must be between zero and one (excluded)"
			exit 198
		}
		local truststart `mergingpoint'
	}
	
	// ---------------------------------------------------------------------- //
	// Check that variables to be added do not already exist
	// ---------------------------------------------------------------------- //
	
	foreach v in _correction _weight _pid _hid _factor {
		capture confirm `v'
		if (_rc == 0) {
			display as error "variable {bf:`v'} already defined"
			exit 110
		}
	}
	
	// ---------------------------------------------------------------------- //
	// Store data for initial Lorenz (cf. postestimation commands)
	// ---------------------------------------------------------------------- //

	preserve
	
		tempvar freq_old F_old fy_old cumfy_old L_old poptot ftile_old
		sort `income'
		
		quietly sum `weight', meanonly
		
		quietly	gen	`freq_old' = `weight'/r(sum)
		quietly	gen `F_old' = sum(`freq_old')	
		quietly	gen `fy_old' = `freq_old'*`income'
		quietly	gen `cumfy_old' = sum(`fy_old')
		
		quietly sum `cumfy_old'
		local cumfy_max = r(max)
		
		quietly	gen `L_old' = `cumfy_old'/`cumfy_max'
		quietly egen `ftile_old' = cut(`F_old'), at(0.00(0.01)0.99 0.991(0.001)0.999 0.9991(0.0001)1) 	
		
		quietly collapse (min) `L_old', by(`ftile_old')
		
		tempname mat_lorenz_old
		mkmat `ftile_old' `L_old', matrix(`mat_lorenz_old') 			
		mat	colnames `mat_lorenz_old' = "ftile_old" "L_old"
	
	restore
	
	// ---------------------------------------------------------------------- //
	// Store data for summarizing initial data (cf. postestimation commands)
	// ---------------------------------------------------------------------- //
	
	preserve
	
		tempvar freq F fy cumfy L d_eq bckt_size trunc_avg ftile wy
		
		// Total average
		sort `income'
		quietly sum `income' [w=`weight'], meanonly
		local old_avg = r(mean) 
		local y_max_old=r(max)
		
		//Gini
		quietly sum `weight', meanonly
		local poptot = r(sum)
		
		quietly gen `freq'  = `weight'/`poptot'
		quietly gen `F'     = sum(`freq') 
		quietly gen `fy'    = `freq'*`income'
		quietly gen `cumfy' = sum(`fy')
		
		quietly sum `cumfy', meanonly
		local cumfy_max = r(max)
		
		quietly gen `L'    = `cumfy'/`cumfy_max'
		quietly gen `d_eq' = (`F'-`L')*`weight'/`poptot'
		
		quietly sum `d_eq', meanonly
		local d_eq_tot = r(sum)
		local gini = `d_eq_tot'*2
		
		// Classify obs in 127 g-percentiles
		quietly egen `ftile' = cut(`F'), at(0(0.01)0.99 0.991(0.001)0.999 0.9991(0.0001)0.9999 0.99991(0.00001)0.99999 1)
		
		// Top average 
		gsort -`F'
		quietly gen `wy'       = `income'*`weight'
		quietly gen topavg_old = sum(`wy')/sum(`weight')
		sort `F'
		
		// Interval thresholds
		quietly collapse (min) thr_old = `income' (mean) bckt_avg_old = `income' (min) topavg_old [w=`weight'], by (`ftile')
		sort `ftile'
		quietly gen ftile = `ftile'
		
		// Generate 127 percentiles from scratch
		tempfile collapsed_sum
		quietly save "`collapsed_sum'"
		clear
		quietly set obs 127
		quietly gen ftile = (_n - 1)/100 in 1/100
		quietly replace ftile = (99 + (_n - 100)/10)/100 in 101/109
		quietly replace ftile = (99.9 + (_n - 109)/100)/100 in 110/118
		quietly replace ftile = (99.99 + (_n - 118)/1000)/100 in 119/127
		quietly merge n:1 ftile using "`collapsed_sum'"
		
		// Interpolate missing info
		quietly ipolate bckt_avg_old ftile, gen(bckt_avg2_old)      
		quietly ipolate thr_old ftile, gen(thr2_old)
		quietly ipolate topavg_old ftile, gen(topavg2_old)
		
		sort ftile
		drop bckt_avg_old thr_old topavg_old
		quietly rename bckt_avg2_old bckt_avg_old
		quietly rename thr2_old thr_old
		quietly rename topavg2_old topavg_old
		quietly sum bckt_avg_old, meanonly
		quietly replace bckt_avg_old = r(max) if missing(bckt_avg_old)
		quietly sum thr_old, meanonly
		quietly replace thr_old = r(max) if missing(thr_old) 
		quietly sum topavg_old, meanonly
		quietly replace topavg_old = r(max) if missing(topavg_old)
		
		// Top shares  
		quietly replace ftile = round(ftile, 0.00001)
		quietly gen topshare_old = (topavg_old/`old_avg')*(1 - ftile)  
		
		// Total average  
		quietly gen average_old = .
		quietly replace average_old = `old_avg' in 1
		
		// Inverted beta coefficient
		quietly gen b_old = topavg_old/thr_old
		
		// Fractile
		quietly gen p_old = round(ftile, 0.00001) 
		
		// Gini 
		quietly gen gini_old = `gini'
		
		//Order and save
		order gini_old p_old thr_old average_old bckt_avg_old topavg_old topshare_old b_old
		keep gini_old p_old thr_old average_old bckt_avg_old topavg_old topshare_old b_old
		tempname mat_sum_old
		mkmat gini_old average_old p_old thr_old bckt_avg_old topavg_old topshare_old b_old, matrix(`mat_sum_old')
	
	restore
 
	// ---------------------------------------------------------------------- //
	// Import and store the tax data
	// ---------------------------------------------------------------------- //
	
	// Get population size as the sum of weights
	quietly summarize `weight', meanonly
	local ind_popsize = r(sum)
	
	sort `households'
	tempvar hhmemno
	quietly by `households': generate `hhmemno' = _n
	quietly summarize `weight' if (`hhmemno' == 1), meanonly
	local hh_popsize = r(sum)
	drop `hhmemno'
	
	if ("`taxunit'" == "i") {
		local popsize = `ind_popsize' 
	}
	else {
		local popsize = `hh_popsize'
	}
	
	// Get the name of the variables in the tax data
	if ("`taxperc'" == "") {
		local taxperc "p"
	}
	if ("`taxthr'" == "") {
		local taxthr "thr"
	}
	if ("`taxavg'" == "") {
		local taxavg "bracketavg"
	}
	
	tempfile rawdata rawtaxdata taxdata
	quietly save "`rawdata'"
	clear
	
	// Identify the format of the tax data
	if (substr("`using'", -4, .) == ".xls" | substr("`using'", -5, .) == ".xlsx") {
		// Excel format
		quietly import excel using "`using'", firstrow
		keep `taxperc' `taxthr' `taxavg'
	}
	else if (substr("`using'", -4, .) == ".csv") {
		// CSV format
		quietly import delimited using "`using'", varnames(1)
		keep `taxperc' `taxthr' `taxavg'
	}
	else {
		// Stata format
		quietly use `taxperc' `taxthr' `taxavg' using "`using'"
	}
	// Rename tax data variables to avoid conflicts
	tempvar new_taxperc new_taxthr new_taxavg
	rename `taxperc' `new_taxperc'
	rename `taxthr' `new_taxthr'
	rename `taxavg' `new_taxavg'
	local taxperc `new_taxperc'
	local taxthr `new_taxthr'
	local taxavg `new_taxavg'
	// Drop values missing or below trust region
	quietly drop if missing(`taxperc') | missing(`taxthr')
	quietly drop if (`taxperc' < `truststart')
	quietly save "`rawtaxdata'", replace
	keep `taxperc' `taxthr'
	// Check that there are some tax data left
	quietly count
	local nbrackets = r(N)
	if (`nbrackets' == 0) {
		display as error "no tax data within trust region"
		quietly use "`rawdata'", clear
		exit 2000
	}
	// Check that the tax data is valid
	sort `taxperc'
	capture assert (`taxthr'[_n + 1] > `taxthr') if (_n < _N)
	if (_rc) {
		display as error "tax thresholds must be increasing"
		use "`rawdata'", clear
		exit 498
	}
	
	// Store the list of fractiles and thresholds for later
	quietly levelsof `taxperc', local(list_taxperc)
	quietly levelsof `taxthr', local(list_taxthr)
	// Calculate population in each bracket
	tempvar bracketsize
	generate `bracketsize' = `popsize'*(cond(missing(`taxperc'[_n + 1]), 1, `taxperc'[_n + 1]) - `taxperc')
	// Create index for brackets
	tempvar bracket_index
	generate `bracket_index' = _n - 1
	// Keep highest bracket in memory
	quietly summarize `taxthr', meanonly
	local max_taxthr = r(max)
	quietly summarize `bracket_index', meanonly
	local max_taxindex = r(max)
	// Save the tax data
	quietly save "`taxdata'"
	
	// ---------------------------------------------------------------------- //
	// Match survey data with tax brackets
	// ---------------------------------------------------------------------- //
	
	display as text "Matching survey observations with tax brackets..."
	
	// Import the survey data back
	use "`rawdata'", clear
	// If households are the tax unit, collapse the data to get that proper unit
	if ("`taxunit'" == "h") {
		if ("`income'" != "`taxincome'") {
			collapse (firstnm) `weight' (firstnm) `taxincome' (firstnm) `income', by(`households')
		}
		else {
			collapse (firstnm) `weight' (firstnm) `income', by(`households')
		}
	}
	tempfile data_collapsed
	quietly save "`data_collapsed'"
	
	// Calculate the survey CDF
	gsort -`taxincome'
	tempvar surveycdf
	quietly generate `surveycdf' = 1 - sum(`weight')/`popsize'
	sort `taxincome'
	
	quietly egen `bracket_index' = cut(`taxincome'), at(`list_taxthr') icodes
	// We need to deal separately with survey observations in the last bracket
	quietly replace `bracket_index' = `max_taxindex' if (`taxincome' >= `max_taxthr')
	tempfile rawdata_collapsed
	quietly save "`rawdata_collapsed'"
	quietly drop if missing(`bracket_index')
	quietly count
	if (r(N) <= 5) {
		display as error "not enough survey observations matching tax data trust region"
		exit 459
	} 
	// Calculate population in each bracket
	tempvar svybsize svynobs taxnobs
	collapse (sum) `svybsize' = `weight' (min) `surveycdf' = `surveycdf' (count) `taxnobs' = `taxincome' (count) `svynobs' = `income', by(`bracket_index')
	// Merge with the tax data
	quietly merge n:1 `bracket_index' using "`taxdata'", nogenerate keep(match using) keepusing(`bracketsize' `taxperc' `taxthr')
	quietly replace `taxnobs' = 0 if missing(`taxnobs')
	quietly replace `svynobs' = 0 if missing(`svynobs')
	quietly replace `svybsize' = 0 if missing(`svybsize')
	quietly replace `surveycdf' = 1 if missing(`surveycdf')
	
	quietly save "`taxdata'", replace

	// ---------------------------------------------------------------------- //
	// Determine merging point
	// ---------------------------------------------------------------------- //
	
	if ("`mergingpoint'" == ""| "`mergingpoint'" == "auto") {
		di as txt "Searching merging point..."
		
		quietly use "`taxdata'"
		// Calculate (small) theta coefficient
		tempvar small_theta
		quietly generate `small_theta' = `svybsize'/`bracketsize'
		// Calculate (big) theta coefficient
		tempvar big_theta
		quietly generate `big_theta' = `surveycdf'/`taxperc'
		tempvar small_theta_smooth
		quietly generate `small_theta_smooth' = .
		sort `taxperc'
		tempvar iso_wgt
		quietly generate `iso_wgt' = cond(missing(`taxperc'[_n + 1]), 1, `taxperc'[_n + 1]) - `taxperc'
		mata: a = .
		mata: w = .
		mata: st_view(a, ., st_local("small_theta"))
		mata: st_view(w, ., st_local("iso_wgt"))
		mata: y = isotonic_pava(w, a, 1)
		mata: st_store(., st_local("small_theta_smooth"), y)
		
		// Find merging point
		gsort -`taxperc'
		tempvar region
		quietly generate `region' = (sum(`small_theta_smooth' > `big_theta') == 0)
		sort `taxperc'
		
		quietly count if `region'
		if (r(N) == 0) {
			display as error "relative bias is greater than one at the top: nothing to correct"
			exit 459
		}
	
		quietly count if !`region'
		if (r(N) > 0) {
			// If `small_theta_smooth' is constant and >= 1 over an interval, use the value corresponding
			// to the highest percentile
			summarize `small_theta_smooth' if `region', meanonly
			summarize `taxperc' if (`small_theta_smooth' == r(max)), meanonly
			quietly replace `region' = 0 if (`taxperc' < r(max)) & (`small_theta_smooth' >= 1)
		
			quietly summarize `taxperc' if `region'
			local mergingpoint = r(min)
			quietly summarize `bracket_index' if `region'
			local mergingindex = r(min)
			quietly summarize `taxthr' if `region'
			local mergingthr = r(min)
			
			// Store for potential postestimation command
			tempvar extrapol
			quietly generate `extrapol' = 0
			tempname theta
			mkmat `taxperc' `big_theta' `small_theta' `small_theta_smooth' `extrapol' `taxthr', matrix(`theta')
			matrix colnames `theta' = "p" "big_theta" "small_theta" "small_theta_iso" "extrapol" "thr"
			
			display as text "Merging point found within trust region: p =", _continue
			display as text round(`mergingpoint', 1e-5) ",", _continue
			display as text "`taxincome' = " round(`mergingthr', 1)
		}
		else {
			display as text "Merging point not found within trust region. Extrapolating..."
			// Store the points at which the tabulation starts
			quietly summarize `taxperc', meanonly
			local min_taxperc = r(min)
			quietly summarize `taxthr', meanonly
			local min_taxthr = r(min)
			
			quietly save "`taxdata'", replace
			
			// Regroup brackets to make sure there is at least one observation in each of them
			quietly count if (`taxnobs' == 0)
			while (r(N) > 0) {
				gsort -`taxperc'
				tempvar newbracket queue
				quietly generate `queue' = sum(`taxnobs' == 0)
				// We choose to group the bracket with the one just below
				quietly generate `newbracket' = `bracket_index'[_n + 1] if (`taxnobs' == 0)
				// We have to make an exception for the last bracket, which we group with the one just above
				quietly replace `newbracket' = `bracket_index'[_n - 1] if (`taxnobs' == 0) & (_n == _N)
				quietly replace `bracket_index' = `newbracket' if (`queue' == 1) & (`taxnobs' == 0)
				collapse (sum) `svybsize' (min) `surveycdf' (sum) `taxnobs' ///
					(sum) `bracketsize' (min) `taxperc' (min) `taxthr', by(`bracket_index')
				quietly count if (`taxnobs' == 0)
			}
			sort `taxperc'
			
			tempvar log_small_theta log_thr extrapol_wgt
			quietly generate `log_small_theta' = log(`svybsize'/`bracketsize')
			quietly generate `log_thr' = log(`taxthr')
			quietly generate `extrapol_wgt' = cond(_n == _N, 1, `taxperc'[_n + 1]) - `taxperc'
			// Perform the ridge regression
			mata: y = .
			mata: st_view(y, ., st_local("log_small_theta"))
			mata: x = .
			mata: st_view(x, ., st_local("log_thr"))
			mata: w = .
			mata: st_view(w, ., st_local("extrapol_wgt"))
			mata: b = ridge_regression(y, x, w, strtoreal(st_local("slope")), strtoreal(st_local("penalization")))
			mata: sigma = mean((y :- b[1] :- x:*b[2]):^2, w)
			mata: st_local("sigma", strofreal(sigma))
			tempname beta_ridge
			mata: st_matrix(st_local("beta_ridge"), b)
			display as text "Elasticity of bias: " %4.0g `beta_ridge'[2, 1]
			if (`beta_ridge'[2, 1] >= 0) {
				display as error "invalid (nonnegative) elasticity estimated; check your data and try increasing penalization"
				exit 322
			}
			
			// Extrapolate theta based on the results of the regression
			quietly use "`rawdata_collapsed'", clear
			tempvar fitted_theta log_income
			quietly generate `log_income' = log(`taxincome')
			quietly generate `fitted_theta' = .
			mata: new_x = .
			mata: st_view(new_x, ., st_local("log_income"))
			mata: st_store(., st_local("fitted_theta"), exp(b[1] :+ new_x:*b[2] :+ sigma/2))
			
			// Merge with the tax data
			quietly merge n:1 `bracket_index' using "`taxdata'", nogenerate keepusing(`svybsize' `bracketsize' `taxperc' `taxthr')
			// For the observations above the trustable span, we use the observed value of theta
			quietly generate `small_theta' = `svybsize'/`bracketsize' if !missing(`bracket_index')
			quietly replace `small_theta' = `fitted_theta' if missing(`bracket_index')
			
			// Calculate corrected survey CDF
			tempvar fitted_weight fitted_cdf
			gsort -`taxincome'
			quietly generate `fitted_weight' = `weight'/`small_theta'
			quietly generate `fitted_cdf' = 1 - sum(`fitted_weight')/`popsize'
			// We only need the data below the trustable span for the extrapolation
			quietly drop if !missing(`bracket_index')
			// Create pseudo tax brackets based on the corrected survey
			tempvar pseudobracket
			quietly egen `pseudobracket' = cut(`fitted_cdf'), ///
				at(0(0.01)0.99 0.991(0.001)0.999 0.9991(0.0001)0.9999 0.99991(0.00001)0.99999)
			
			collapse (sum) `fitted_weight' (sum) `weight' (min) `surveycdf' (min) `taxincome' (count) `taxnobs' = `taxincome' (count) `svynobs' = `income', by(`pseudobracket')
			// Group again in case of identical thresholds
			collapse (sum) `fitted_weight' (sum) `weight' (min) `surveycdf' (min) `pseudobracket' (sum) `taxnobs' (sum) `svynobs', by(`taxincome')
			
			quietly drop if (`pseudobracket' >= `truststart')
			
			quietly generate `small_theta' = `weight'/`fitted_weight'
			quietly generate `small_theta_smooth' = `weight'/`fitted_weight'
			quietly generate `big_theta' = `surveycdf'/`pseudobracket'
			
			// Add the tax data for trustable span
			rename `pseudobracket' `taxperc'
			rename `taxincome' `taxthr'
			rename `fitted_weight' `bracketsize'
			rename `weight' `svybsize'
			append using "`taxdata'"
			sort `taxperc'
			
			// Store for potential postestimation command
			tempvar extrapol
			quietly generate `extrapol' = (`taxperc' < `truststart')
			tempname theta
			mkmat `taxperc' `big_theta' `small_theta' `small_theta_smooth' `extrapol' `taxthr', matrix(`theta')
			matrix colnames `theta' = "p" "big_theta" "small_theta" "small_theta_iso" "extrapol" "thr"
			// Find merging point
			tempvar region
			quietly generate `region' = (`small_theta_smooth' <= `big_theta')
			quietly count if `region'
			if (r(N) == 0) {
				display as error "relative bias is greater than one at the top: nothing to correct"
				exit 459
			}
			quietly count if `region'
			if (r(N) > 0) {
				quietly summarize `taxperc' if `region'
				local mergingpoint = r(min)
				quietly summarize `bracket_index' if `region'
				local mergingindex = r(min)
				quietly summarize `taxthr' if `region'
				local mergingthr = r(min)
				
				display as text "Merging point found by extrapolation: p =", _continue
				display as text round(`mergingpoint', 1e-5) ",", _continue
				display as text "`taxincome' = " `mergingthr'
				
				quietly keep if `region'
				sort `taxperc'
				quietly replace `bracket_index' = _n - 1
				quietly save "`taxdata'", replace
			}
		}
	}
	else {
		quietly use "`taxdata'"
		
		// Calculate (small) theta coefficient
		tempvar small_theta
		quietly generate `small_theta' = `svybsize'/`bracketsize'
		// Calculate (big) theta coefficient
		tempvar big_theta
		quietly generate `big_theta' = `surveycdf'/`taxperc'
		tempvar small_theta_smooth
		quietly generate `small_theta_smooth' = .
		sort `taxperc'
		mata: a = .
		mata: w = .
		mata: st_view(a, ., st_local("small_theta"))
		mata: st_view(w, ., st_local("svynobs"))
		mata: y = isotonic_pava(w, a, 1)
		mata: st_store(., st_local("small_theta_smooth"), y)
		
		// Store for potential postestimation command
		tempvar extrapol
		quietly generate `extrapol' = 0
		tempname theta
		mkmat `taxperc' `big_theta' `small_theta' `small_theta_smooth' `extrapol' `taxthr', matrix(`theta')
		matrix colnames `theta' = "p" "big_theta" "small_theta" "small_theta_iso" "extrapol" "thr"
		
		tempvar region
		quietly generate `region' = (`taxperc' >= `mergingpoint')
		
		quietly summarize `taxperc' if `region'
		local mergingpoint = r(min)
		quietly summarize `bracket_index' if `region'
		local mergingindex = r(min)
		quietly summarize `taxthr' if `region'
		local mergingthr = r(min)
			
		display as text "Using user-specified merging point: p =", _continue
		display as text round(`mergingpoint', 1e-5) ",", _continue
		display as text "`taxincome' = " `mergingthr'
	}
	
	// ---------------------------------------------------------------------- //
	// Regroup tax brackets for calibration
	// ---------------------------------------------------------------------- //
	
	quietly use "`taxdata'", clear
	quietly keep if (`taxperc' >= `mergingpoint')
	
	quietly count
	local nbrackets = r(N)
	
	// Regroup brackets to make sure we dont multiply weights by more than `thetalimit'
	tempvar s_theta cns_violated
	quietly generate `s_theta' = `svybsize'/`bracketsize'
	quietly generate `cns_violated' = (1/`s_theta' > `thetalimit' | `s_theta' < 1/`thetalimit' | `svynobs' < `minbracket')
	quietly count if `cns_violated'
	while (r(N) > 0) {
		gsort -`taxperc'
		tempvar newbracket queue
		quietly generate `queue' = sum(`cns_violated')
		// We choose to group the bracket with the one just below
		quietly generate `newbracket' = `bracket_index'[_n + 1] if `cns_violated'
		// We have to make an exception for the last bracket, which we group with the one just above
		quietly replace `newbracket' = `bracket_index'[_n - 1] if (`cns_violated') & (_n == _N)
		quietly replace `bracket_index' = `newbracket' if (`queue' == 1) & (`cns_violated')
		collapse (sum) `svybsize' (min) `surveycdf' (sum) `taxnobs' (sum) `svynobs' ///
			(sum) `bracketsize' (min) `taxperc' (min) `taxthr', by(`bracket_index')
		quietly generate `s_theta' = `svynobs'/`taxnobs'
		quietly generate `cns_violated' = (1/`s_theta' > `thetalimit' | `s_theta' < 1/`thetalimit' | `svynobs' < `minbracket')
		quietly count if `cns_violated'
	}
	
	// Check if there is enough density in survey to respect `thetalimit' constraint
	quietly sum `svynobs'
	local totsvynobs = r(sum)
	quietly sum `taxnobs'
	local totataxnobs = r(sum)
	if (`totsvynobs'/`totataxnobs' < 1/`thetalimit') {
		di "The constraint for the maximum value of 1/theta is unsuited for the survey data"
		exit 459
	}
	
	sort `taxperc'
	quietly replace `bracket_index' = _n - 1
	quietly save "`taxdata'", replace
			
	quietly levelsof `taxthr', local(list_taxthr)
	quietly levelsof `bracket_index', local(list_bracketindex)
	quietly summarize `bracket_index', meanonly
	local max_taxindex = r(max)
	
	// Keep highest bracket in memory
	quietly summarize `taxthr', meanonly
	local max_taxthr = r(max)
	quietly summarize `bracket_index', meanonly
	local max_taxindex = r(max)
	// Get the new list of tax brackets
	sort `taxperc'
	local list_taxperc ""
	local list_taxthr ""
	forvalues j = 1/`=_N' {
		local list_taxperc `list_taxperc' `=`taxperc'[`j']'
		local list_taxthr `list_taxthr' `=`taxthr'[`j']'
		local list_svynobs `list_svynobs' `=`taxnobs'[`j']'
	}
	quietly count
	local newnbrackets = r(N)
	
	// Display a summary of the tax data
	display ""
	display as text _column(4) "Tax and survey data summary"
	display as text _column(4) "{hline 60}"
	display as text _column(15) "Fractile", _continue
	display as text _column(35) "Threshold", _continue
	display as text _column(59) "# obs"
	display as text _column(4) "{hline 60}"
	if (`newnbrackets' > 10) {
		forvalues i = 1/5 {
			local dip: word `i' of `list_taxperc'
			local dithr: word `i' of `list_taxthr'
			local diobs: word `i' of `list_svynobs'
			display as res _column(3) %20.5g `dip', _continue
			display as res  %20.5gc `dithr', _continue
			display as res  %19.5gc `diobs'
			
		}
		display as text _column(20) "..." _column(41) "..." _column(61) "..."
		forvalues i = 5(-1)1 {
			local j = `newnbrackets' - `i' + 1
			local dip: word `j' of `list_taxperc'
			local dithr: word `j' of `list_taxthr'
			local diobs: word `j' of `list_svynobs'
			display as res _column(3) %20.5g `dip', _continue
			display as res  %20.5gc `dithr', _continue
			display as res  %19.5gc `diobs'
		}
		
	}
	else {
		forvalues i = 1/`newnbrackets' {
			local dip: word `i' of `list_taxperc'
			local dithr: word `i' of `list_taxthr'
			local diobs: word `i' of `list_svynobs'
			display as res _column(3) %20.5g `dip', _continue
			display as res  %20.5gc `dithr', _continue
			display as res  %19.5gc `diobs'
			
		}
	}
	display as text _column(4) "{hline 60}"
	display as text _column(4) "Number of brackets =", _continue
	display as res _column(55) %9.0f `newnbrackets'
	display as text _column(4) "{hline 60}"
	local regrouped = `nbrackets' - `newnbrackets'
	display as text _column(4) "`regrouped' bracket(s) grouped", _continue
	display as text "to avoid expanding weights more than `thetalimit' times per bracket."
	
	// Store population over merging point in survey (e.g. post-estimation)
	quietly use "`rawdata'", clear
	quietly sum `weight' if `income' > `mergingthr'
	local above_MP_svy = r(sum)/`popsize'
	// Use the new brackets for the survey data
	tempvar bracket_index_svy
	quietly egen `bracket_index' = cut(`taxincome'), at(`list_taxthr') icodes
	quietly egen `bracket_index_svy' = cut(`income'), at(`list_taxthr') icodes
	// We need to deal separately with survey observations in the last bracket
	quietly replace `bracket_index' = `max_taxindex' if (`taxincome' >= `max_taxthr')
	quietly replace `bracket_index_svy' = `max_taxindex' if (`income' >= `max_taxthr')
	quietly save "`rawdata'", replace
	
	// ---------------------------------------------------------------------- //
	// Import data for calibration on income composition, if any
	// ---------------------------------------------------------------------- //
	
	local usecomp 0
	if ("`incomecomposition'" != "") {
		// Identify the format of the tax data
		if (substr("`incomecomposition'", -4, .) == ".xls" | substr("`incomecomposition'", -5, .) == ".xlsx") {
			// Excel format
			quietly import excel using "`incomecomposition'", firstrow clear
		}
		else if (substr("`incomecomposition'", -4, .) == ".csv") {
			// CSV format
			quietly import delimited using "`incomecomposition'", varnames(1) clear
		}
		else {
			// Stata format
			quietly use "`incomecomposition'", clear
		}
		
		capture confirm variable thr
		if (_rc) {
			display as error "variable 'thr' missing from file `incomecomposition'"
			exit 111
		}
		
		// Only keep the tax data above the merging point
		quietly keep if (thr >= `mergingthr')
		
		quietly count
		if (r(N) == 0) {
			display as error "no income composition data above merging point; ignored"
		}
		else {
			// Store the thresholds and shares to calibrate on
			tempname compthr
			mkmat thr, matrix(`compthr')
			quietly ds thr, not
			local compvars = r(varlist)
			if ("`compvars'" == "") {
				display as error "covariates missing from file `incomecomposition'"
				exit 111
			}
			tempname compshares
			mkmat `compvars', matrix(`compshares')
			local usecomp 1
		}
	}
	
	// ---------------------------------------------------------------------- //
	// Import data for calibration on population composition by income
	// ---------------------------------------------------------------------- //
	
	local usepop 0
	if ("`incomepopulation'" != "") {
		// Identify the format of the tax data
		if (substr("`incomepopulation'", -4, .) == ".xls" | substr("`incomepopulation'", -5, .) == ".xlsx") {
			// Excel format
			quietly import excel using "`incomepopulation'", firstrow clear
		}
		else if (substr("`incomepopulation'", -4, .) == ".csv") {
			// CSV format
			quietly import delimited using "`incomepopulation'", varnames(1) clear
		}
		else {
			// Stata format
			quietly use "`incomepopulation'", clear
		}
		
		capture confirm variable thr
		if (_rc) {
			display as error "variable 'thr' missing from file `incomepopulation'"
			exit 111
		}
		capture confirm variable p
		if (_rc) {
			display as error "variable 'p' missing from file `incomepopulation'"
			exit 111
		}
		
		// Only keep the tax data above the merging point
		quietly keep if (thr >= `mergingthr')
		
		quietly count
		if (r(N) == 0) {
			display as error "no population composition data above merging point; ignored"
		}
		else {
			// Store the thresholds and shares to calibrate on
			tempname popthr popperc
			mkmat thr, matrix(`popthr')
			mkmat p, matrix(`popperc')
			quietly ds thr p, not
			local popvars = r(varlist)
			if ("`popvars'" == "") {
				display as error "covariates missing from file `incomepopulation'"
				exit 111
			}
			tempname popfreq
			mkmat `popvars', matrix(`popfreq')
			local usepop 1
		}
	}
	
	// ---------------------------------------------------------------------- //
	// Perform linear calibration
	// ---------------------------------------------------------------------- //
	
	display as text ""
	display as text "Calibration"
	
	use "`rawdata'", clear
	// Create dummy variables for margins
	tempvar constant
	generate `constant' = 1
	// We always have at least this margin for the sum of weights
	local dummies_margins `constant'
	if ("`holdmargins'" != "") {
		foreach v of varlist `holdmargins' {
			tempvar dummies_`v'
			quietly tabulate `v', generate(`dummies_`v'')
			local nvals_`v' = r(r)
			if (r(r) > 20) {
				display as error "warning: variable `v' has more than 20 different values,", _continue
				display as error "you should probably regroup them into fewer categories"
			}
			quietly levelsof `v', local(values_`v')
			unab new_dummies: `dummies_`v''*
			foreach u of varlist `new_dummies' {
				quietly replace `u' = 0 if missing(`u')
			}
			local dummies_margins `dummies_margins' `new_dummies'
			local values_margins `values_margins' `values_`v''
			local nvals_margins `nvals_margins' `nvals_`v''
		}
	}
	
	// Get value of margins
	tempvar margins_target
	quietly total `dummies_margins' [pw=`weight']
	matrix define `margins_target' = e(b)
	// Add new margins to impose
	if ("`varmargins'" != "") {
		foreach v of varlist `varmargins' {
			tempvar newmargin`v'
			quietly generate `newmargin`v'' = cond(`v' == 1, 1, 0)
			local dummies_margins `dummies_margins' `newmargin`v''
			local values_margins `values_margins' 1
			local nvals_margins `nvals_margins' 1
		}
		foreach a of numlist `freqmargins' {
			local b = `ind_popsize'*`a'
			matrix define `margins_target' = (`margins_target', `b')
		}
	}
	
	// Store bracket size margin values separately
	quietly save "`rawdata'", replace
	quietly merge n:1 `bracket_index' using "`taxdata'", nogenerate keep(master match) keepusing(`bracketsize')
	keep `bracket_index' `bracketsize'
	quietly drop if missing(`bracket_index')
	quietly duplicates drop
	sort `bracket_index'
	tempname margins_income
	mkmat `bracketsize', matrix(`margins_income')
	
	quietly use "`rawdata'", clear
	// Create dummy variables for survey income tax bracket
	tempvar dummies_income_svy
	quietly tabulate `bracket_index_svy', generate(`dummies_income_svy')
	unab dummies_income_svy: `dummies_income_svy'*
	foreach v of varlist `dummies_income_svy' {
		quietly replace `v' = 0 if missing(`v')
	}
	local dummies_margins_svy `dummies_margins' `dummies_income_svy'
	// Create dummy variables for income tax bracket
	tempvar dummies_income
	quietly tabulate `bracket_index', generate(`dummies_income')
	unab dummies_income: `dummies_income'*
	foreach v of varlist `dummies_income' {
		quietly replace `v' = 0 if missing(`v')
	}
	local dummies_margins `dummies_margins' `dummies_income'
	// Add margins from the tax data to the margins
	matrix define `margins_target' = (`margins_target', (`margins_income')')
	local values_margins `values_margins' `list_taxthr'
	local margins `holdmargins' `varmargins' `income'
	local nb_dummies_income: list sizeof dummies_income
	local nvals_margins `nvals_margins' `nb_dummies_income'
	
	// Create variables for income composition
	if (`usecomp') {
		local n = rowsof(`compshares')
		
		foreach v in `compvars' {
			capture confirm variable `v'
			if (_rc) {
				display as error "income composition variable `v' not found in the survey; ignored"
				continue
			}
			local j = colnumb(`compshares', "`v'")
			forvalue i = 1/`n' {
				local s = `compshares'[`i', `j']
				if (`i' < `n') {
					tempvar share`v'`i'
					quietly generate `share`v'`i'' = (`taxincome' >= `compthr'[`i', 1] & `taxincome' < `compthr'[`i' + 1, 1])*(`v' - `s'*`taxincome')/`compthr'[`i', 1]
					quietly replace `share`v'`i'' = 0 if missing(`v')
				}
				else {
					tempvar share`v'`i'
					quietly generate `share`v'`i'' = (`taxincome' >= `compthr'[`i', 1])*(`v' - `s'*`taxincome')/`compthr'[`i', 1]
					quietly replace `share`v'`i'' = 0 if missing(`v')
				}
				local var_margins_comp `var_margins_comp' `share`v'`i''
				matrix define `margins_target' = (`margins_target', 0)
				local val = `compthr'[`i', 1]
				local values_margins `values_margins' `val'
			}
			local nvars = `nvars' + 1
			local margins `margins' "__comp_`v'"
			local nvals_margins `nvals_margins' `n'
		}
	}
	
	// Create variables for population composition by income
	if (`usepop') {
		local n = rowsof(`popfreq')
		
		foreach v in `popvars' {
			capture confirm variable `v'
			if (_rc) {
				display as error "population composition variable `v' not found in the survey; ignored"
				continue
			}
			capture assert inlist(`v', 0, 1) | missing(`v')
			if (_rc) {
				display as error "population composition variable `v' is not a dummy; ignored"
			}
			local j = colnumb(`popfreq', "`v'")
			forvalue i = 1/`n' {
				local s = `popfreq'[`i', `j']
				if (`i' < `n') {
					tempvar pop`v'`i'
					quietly generate `pop`v'`i'' = (`taxincome' >= `popthr'[`i', 1] & `taxincome' < `popthr'[`i' + 1, 1])*`v'
					quietly replace `pop`v'`i'' = 0 if missing(`v')
					matrix define `margins_target' = (`margins_target', `popsize'*`s'*(`popperc'[`i' + 1, 1] - `popperc'[`i', 1]))
				}
				else {
					tempvar pop`v'`i'
					quietly generate `pop`v'`i'' = (`taxincome' >= `popthr'[`i', 1])*`v'
					quietly replace `pop`v'`i'' = 0 if missing(`v')
					matrix define `margins_target' = (`margins_target', `popsize'*`s'*(1 - `popperc'[`i', 1]))
				}
				local var_margins_comp `var_margins_comp' `pop`v'`i''
				local val = `popthr'[`i', 1]
				local values_margins `values_margins' `val'
			}
			local nvars = `nvars' + 1
			local margins `margins' "__pop_`v'"
			local nvals_margins `nvals_margins' `n'
		}
		
	}
	
	
	// Collapse by household to enforce equal weights within household
	tempfile data_nocollapse
	quietly save "`data_nocollapse'"
	if ("`var_margins_comp'" == "") {
		collapse (mean) `weight' (sum) `dummies_margins' (sum) `dummies_income_svy', by(`households')
	}
	else {
		collapse (mean) `weight' (sum) `dummies_margins' (sum) `dummies_income_svy' (sum) `var_margins_comp', by(`households')
	}
	
	// If the unit is households, then the income dummies must refer to that unit.
	// Either the collpased income dummy is zero, meaning that the household isn't in the bracket
	// therefore we leave it, or it is equal to the household size (>= 1) and we set it to one
	if ("`taxunit'" == "h") {
		foreach v of varlist `dummies_income' {
			quietly replace `v' = 1 if (`v' >= 1)
		}
		foreach v of varlist `dummies_income_svy' {
			quietly replace `v' = 1 if (`v' >= 1)
		}
	}
	
	local dummies_margins `dummies_margins' `var_margins_comp'
	local dummies_margins_svy `dummies_margins_svy' `var_margins_comp'
	
	// Get corresponding view matrices
	mata: X = 0
	mata: Z = 0
	mata: d = 0
	mata: st_view(Z, ., st_local("dummies_margins"))
	mata: st_view(X, ., st_local("dummies_margins_svy"))
	mata: st_view(d, ., st_local("weight"))
	// Get the target value of the margins
	mata: M = st_matrix(st_local("margins_target"))'
	// Get calibration results
	tempname coefs
	mata: results = calibrate(d, X, Z, M)
	if (`success' == 1) {
		display as text "convergence achieved"
	}
	else {
		display as error "convergence not achieved"
		exit 430
	}
	tempvar calweight calfactor
	quietly generate `calweight' = .
	mata: st_store(., st_local("calweight"), results)
	quietly generate `calfactor' = `calweight'/`weight'
	
	// Save the new weights
	tempfile new_weights
	quietly save "`new_weights'"
	
	// Re-import non-collapsed dataset
	quietly merge 1:n `households' using "`data_nocollapse'", nogenerate assert(match)
	
	// ---------------------------------------------------------------------- //
	// Store calibration factors
	// ---------------------------------------------------------------------- //
	
	tempname adjfactors rfactors
	
	local i = 1
	local nvars: list sizeof margins
	forvalues j = 1/`nvars' {
		local var: word `j' of `margins'
		local nvals: word `j' of `nvals_margins'
		forvalues k = 1/`nvals' {
			local val: word `i' of `values_margins'
			
			if ("`var'" == "`income'") {
				local index: word `k' of `list_bracketindex'
				quietly summarize `calfactor' if (`bracket_index' == `index'), de
				
				matrix `rfactors' = (`coefs'[`i' + 1, 1], r(mean), r(min), r(p50), r(max))
				matrix rownames `rfactors' = "`var':`val'"
				
				matrix define `adjfactors' = (nullmat(`adjfactors') \ `rfactors')
			}
			else if (substr("`var'", 1, 7) == "__comp_") {
				local var2 = substr("`var'", 8, .)
				if (`k' < `nvals') {
					quietly summarize `calfactor' if (`taxincome' >= `compthr'[`k', 1]) & (`taxincome' < `compthr'[`k' + 1, 1] & `var2' != 0), de
				}
				else {
					quietly summarize `calfactor' if (`taxincome' >= `compthr'[`k', 1] & `var2' != 0), de
				}
				
				matrix `rfactors' = (`coefs'[`i' + 1, 1], r(mean), r(min), r(p50), r(max))
				matrix rownames `rfactors' = "`taxincome'#`var2':`val'"
				
				matrix define `adjfactors' = (nullmat(`adjfactors') \ `rfactors')
			}
			else if (substr("`var'", 1, 6) == "__pop_") {
				local var2 = substr("`var'", 7, .)
				if (`k' < `nvals') {
					quietly summarize `calfactor' if (`taxincome' >= `popthr'[`k', 1]) & (`taxincome' < `popthr'[`k' + 1, 1] & `var2' == 1), de
				}
				else {
					quietly summarize `calfactor' if (`taxincome' >= `popthr'[`k', 1] & `var2' == 1), de
				}
				
				matrix `rfactors' = (`coefs'[`i' + 1, 1], r(mean), r(min), r(p50), r(max))
				matrix rownames `rfactors' = "`taxincome'#`var2':`val'"
				
				matrix define `adjfactors' = (nullmat(`adjfactors') \ `rfactors')
			}
			else {
				quietly summarize `calfactor' if (`var' == `val'), de
				
				matrix `rfactors' = (`coefs'[`i' + 1, 1], r(mean), r(min), r(p50), r(max))
				matrix rownames `rfactors' = "`var':`val'"
				
				matrix define `adjfactors' = (nullmat(`adjfactors') \ `rfactors')
			}
			local i = `i' + 1
		}
	}
	quietly summarize `calfactor', de
	matrix `rfactors' = (`coefs'[1, 1], r(mean), r(min), r(p50), r(max))
	matrix rownames `rfactors' = "_cons"
	matrix define `adjfactors' = (nullmat(`adjfactors') \ `rfactors')
	
	matrix colnames `adjfactors' = "coef" "mean" "min" "median" "max"
	
	// ---------------------------------------------------------------------- //
	// Perform replacing & imputing
	// ---------------------------------------------------------------------- //
	
	if ("`noreplace'" == "") {
		display as text ""
		display as text "Replacing", _continue
		
		// Identify the point where replacing starts: it can be above the
		// merging if extrapolation was involved
		local replacepoint = max(`mergingpoint', `truststart')
		quietly use "`taxdata'", clear
		tempvar replace_region
		generate `replace_region' = (`taxperc' >= `replacepoint')
		quietly summarize `taxthr' if `replace_region', meanonly
		local replacethr = r(min)
		quietly summarize `taxperc' if `replace_region', meanonly
		local replacepoint = r(min)
		
		display as text "for p >= " round(`replacepoint', 0.001) ", `taxincome' >= " round(`replacethr')
		
		// Truncate sampletop to make sure there's not more observations in the
		// survey than in the real population
		if (`sampletop' > 1) {
			local sampletop = 1
		}
	
		// Store the full tax data in Mata
		use "`rawtaxdata'", clear
		quietly keep if (`taxperc' >= `replacepoint')
		mata: p = st_data(., st_local("taxperc"))
		mata: thr = st_data(., st_local("taxthr"))
		mata: avg = st_data(., st_local("taxavg"))
		
		if ("`taxunit'" == "i") {
			// Import the original data
			quietly use "`rawdata'", clear
			
			// Add new weights
			quietly merge n:1 `households' using "`new_weights'", keepusing(`calweight') nogenerate
			
			// Define a numeric household id
			tempvar hid
			egen `hid' = group(`households')
			// Define a numeric personal id
			tempvar pid
			generate `pid' = _n
			// Separate households with some individuals above merging point (to be replaced),
			// and all individuals below the merging point (to preserve)
			tempfile hh_all hh_below hh_above
			sort `pid' `hid'
			
			quietly save "`hh_all'"
			
			tempvar nhhmem_above
			quietly egen `nhhmem_above' = total(`taxincome' >= `replacethr'), by(`hid')
			quietly keep if (`nhhmem_above' == 0)
			quietly drop `nhhmem_above'
			quietly save "`hh_below'"
			
			quietly use "`hh_all'"
			quietly egen `nhhmem_above' = total(`taxincome' >= `replacethr'), by(`hid')
			quietly keep if (`nhhmem_above' > 0)
			quietly drop `nhhmem_above'
			quietly save "`hh_above'"
			
			quietly count
			local n_before = r(N)
		
			// Break down observations into small ones
			keep `hid' `calweight'
			quietly duplicates drop `hid', force
			tempvar nexpand
			quietly generate `nexpand' = `sampletop'*`calweight'
			// Pseudo-random rounding to preserve sum using a halton sequence
			tempvar halton_unif
			quietly generate `halton_unif' = .
			mata: st_store(., st_varindex(st_local("halton_unif")), halton(st_nobs(), 1))
			quietly replace `nexpand' = floor(`nexpand') + (`halton_unif' < (`nexpand' - floor(`nexpand')))
			drop `halton_unif'
			// Make sure that all observations are used at least once (no loss of information)
			quietly replace `nexpand' = 1 if (`nexpand' < 1)
			// Adjust weights based on the number of observations to expand
			quietly replace `calweight' = `calweight'/`nexpand'
			quietly expand `nexpand'
			drop `nexpand'
			tempvar new_hid
			quietly generate `new_hid' = _n
						
			// Re-merge original households to get all the covariates
			tempvar _merge
			joinby `hid' using "`hh_above'", _merge(`_merge')
			drop `_merge'
			
			quietly count
			display as text "`n_before' => " r(N) " observations (×" round(r(N)/`n_before', 0.01) ")"
			
			// Scramble people's ranks above replace point
			preserve
			quietly keep if (`taxincome' >= `replacethr')
			gsort -`taxincome'
			tempvar idx
			quietly generate `idx' = _n
			tempvar idxstart idxend
			collapse (min) `idxstart'=`idx' (max) `idxend'=`idx', by(`hid' `pid')
			sort `idxstart'
			tempvar idxmin idxmax
			quietly generate `idxmin' = `idxstart'[max(1, _n - `knn')]
			quietly generate `idxmax' = `idxend'[min(_N, _n + `knn')]
			drop `idxstart' `idxend'
			tempfile list_idx
			quietly save "`list_idx'", replace
			restore
			
			quietly merge n:1 `hid' `pid' using "`list_idx'", nogenerate
			gsort -`taxincome'
			quietly replace `idxmin' = _n if missing(`idxmin')
			quietly replace `idxmax' = _n if missing(`idxmax')
			tempvar halton_unif
			quietly generate `halton_unif' = .
			mata: st_store(., st_varindex(st_local("halton_unif")), halton(st_nobs(), 1))
			tempvar idx
			quietly generate `idx' = `idxmin' + (`idxmax' - `idxmin')*`halton_unif'
			sort `idx'
			quietly drop `halton_unif' `idx' `idxmin' `idxmax'
			
			// Determine a new rank in the individual distribution for people above the threshold
			gsort -`taxincome'
			tempvar to_replace rank
			quietly generate `to_replace' = (`taxincome' >= `replacethr')
			quietly generate double `rank' = 1 - sum(`calweight')/`ind_popsize' if `to_replace'
			
			// Attribute an income to each observation using the optimal transport map
			tempvar new_income
			quietly generate `new_income' = .
			mata: s = .
			mata: st_view(s, ., st_local("rank"), st_local("to_replace"))
			mata: st_store(., st_varindex(st_local("new_income")), st_local("to_replace"), ot_income(p, thr, avg, s))
			
			// Compute a adjustment factors
			tempvar coef
			quietly generate `coef' = `new_income'/`taxincome'
			quietly replace `coef' = 1 if missing(`coef')
			
			// Add other households
			tempvar below
			quietly generate `below' = 0
			append using "`hh_below'"
			quietly replace `below' = 1 if missing(`below')
			quietly replace `coef' = 1 if `below'
			
			// Generate variables
			quietly generate _correction = cond(`below', 1, 2)
			label define _correction 1 "reweighted" 2 "replaced"
			label values _correction _correction
			quietly generate _weight = `calweight'
			quietly generate _factor = `coef'
			quietly replace `taxincome' = _factor*`taxincome'
			if ("`taxincome'" != "`income'") {
				quietly replace `income' = _factor*`income'
			}
			quietly replace `weight' = . if _correction == 2
			
			// Generate the new household and personal IDs
			sort `taxincome'
			quietly egen _hid = group(`hid' `new_hid'), missing
			gsort _hid `pid'
			quietly by _hid: generate _pid = _n
		}
		else {
			// Import the original data
			quietly use "`rawdata'", clear
			// Define a numeric household id
			tempvar hid
			egen `hid' = group(`households')
			sort `taxincome'
			
			// Add new weights
			quietly merge n:1 `households' using "`new_weights'", keepusing(`calweight') nogenerate
			
			// Separate households with above merging point (to be replaced),
			// and all individuals below the merging point (to preserve)
			tempfile hh_all hh_above hh_below
			quietly save "`hh_all'"
			
			quietly drop if (`taxincome' > `replacethr')
			quietly save "`hh_below'"
			
			quietly use "`hh_all'"
			quietly drop if (`taxincome' <= `replacethr')
			quietly save "`hh_above'"
			
			quietly count
			local n_before = r(N)
		
			// Break down observations into small ones
			keep `hid' `calweight' `taxincome'
			quietly duplicates drop `hid', force
			tempvar nexpand
			quietly generate `nexpand' = `sampletop'*`calweight'
			// Pseudo-random rounding to preserve sum using a halton sequence
			tempvar halton_unif
			quietly generate `halton_unif' = .
			mata: st_store(., st_varindex(st_local("halton_unif")), halton(st_nobs(), 1))
			quietly replace `nexpand' = floor(`nexpand') + (`halton_unif' < (`nexpand' - floor(`nexpand')))
			drop `halton_unif'
			// Make sure that all observations are used at least once (no loss of information)
			quietly replace `nexpand' = 1 if (`nexpand' < 1)
			// Adjust weights based on the number of observations to expand
			quietly replace `calweight' = `calweight'/`nexpand'
			quietly expand `nexpand'
			drop `nexpand'
			tempvar new_hid
			quietly generate `new_hid' = _n
			
			quietly count
			display as text "`n_before' => " r(N) " observations (×" round(r(N)/`n_before', 0.01) ")"
			
			// Scramble households' ranks
			preserve
			gsort -`taxincome'
			tempvar idx
			quietly generate `idx' = _n
			tempvar idxstart idxend
			collapse (min) `idxstart'=`idx' (max) `idxend'=`idx', by(`hid')
			sort `idxstart'
			tempvar idxmin idxmax
			quietly generate `idxmin' = `idxstart'[max(1, _n - `knn')]
			quietly generate `idxmax' = `idxend'[min(_N, _n + `knn')]
			drop `idxstart' `idxend'
			tempfile list_idx
			quietly save "`list_idx'", replace
			restore
			
			quietly merge n:1 `hid' `pid' using "`list_idx'", nogenerate
			gsort -`taxincome'
			quietly replace `idxmin' = _n if missing(`idxmin')
			quietly replace `idxmax' = _n if missing(`idxmax')
			tempvar halton_unif
			quietly generate `halton_unif' = .
			mata: st_store(., st_varindex(st_local("halton_unif")), halton(st_nobs(), 1))
			tempvar idx
			quietly generate `idx' = `idxmin' + (`idxmax' - `idxmin')*`halton_unif'
			sort `idx'
			quietly drop `halton_unif' `idx' `idxmin' `idxmax'
			
			// Determine a new rank in the individual distribution for people above the threshold
			tempvar rank
			quietly generate double `rank' = 1 - sum(`calweight')/`hh_popsize'
			
			// Attribute an income to each observation using the optimal transport map
			tempvar new_income
			quietly generate `new_income' = .
			mata: s = .
			mata: st_view(s, ., st_local("rank"))
			mata: st_store(., st_varindex(st_local("new_income")), ot_income(p, thr, avg, s))
			
			// Merge full households with covariates
			tempvar _merge
			joinby `hid' using "`hh_above'", _merge(`_merge')
			drop `_merge'
			
			// Compute a adjustment factors
			tempvar coef
			quietly generate `coef' = `new_income'/`taxincome'
			quietly replace `coef' = 1 if missing(`coef')
			
			// Add other households
			tempvar below
			quietly generate `below' = 0
			append using "`hh_below'"
			quietly replace `below' = 1 if missing(`below')
			quietly replace `coef' = 1 if `below'
			
			// Generate variables
			quietly generate _correction = cond(`below', 1, 2)
			label define _correction 1 "reweighted" 2 "replaced"
			label values _correction _correction
			quietly generate _weight = `calweight'
			quietly generate _factor = `coef'
			quietly replace `taxincome' = _factor*`taxincome'
			if ("`taxincome'" != "`income'") {
				quietly replace `income' = _factor*`income'
			}
			quietly replace `weight' = . if _correction == 2
			
			// Generate the new household and personal IDs
			sort `taxincome'
			quietly egen _hid = group(`hid' `new_hid'), missing
			gsort _hid `pid'
			quietly by _hid: generate _pid = _n
			
			/*
			// Add other households
			tempvar below
			quietly generate `below' = 0
			append using "`hh_below'"
			quietly replace `below' = 1 if missing(`below')
			quietly replace `new_income' = `taxincome' if missing(`new_income')
			
			// Generate variables
			quietly generate _correction = cond(`below', 1, 2)
			label define _correction 1 "reweighted" 2 "replaced"
			label values _correction _correction
			quietly generate _weight = `calweight'
			quietly generate _factor = cond(`new_income' == `taxincome', 1, `new_income'/`taxincome')
			quietly replace `taxincome' = `new_income'
			quietly replace `weight' = . if _correction == 2
			
			// Generate the new household and personal IDs
			sort `taxincome'
			quietly egen _hid = group(`hid' `new_hid'), missing
			gsort _hid `pid'
			quietly by _hid: generate _pid = _n
			*/
		}
	}
	else {
		use "`rawdata'", clear
		
		// Add new weights
		quietly merge n:1 `households' using "`new_weights'", keepusing(`calweight') nogenerate
		
		quietly generate _correction = 1
		label define _correction 1 "reweighted" 2 "replaced"
		label values _correction _correction
		quietly generate _weight = `calweight'
		quietly generate _factor = 1
		quietly egen _hid = group(`households')
		gsort _hid `pid'
		quietly by _hid: generate _pid = _n
	}
	
	label variable _correction "type of correction applied"
	label variable _weight "corrected survey weight"
	label variable _factor "income adjustment factor"
	label variable _hid "household ID"
	label variable _pid "personal ID"
	display as text ""
	display as text  "The following variables were created (see {help bfmcorr} for details):"
	display as text  _col(4) "{bf:_correction} type of correction applied"
	display as text  _col(4) "{bf:_weight} corrected survey weight"
	display as text  _col(4) "{bf:_factor} income adjustment factor"
	display as text  _col(4) "{bf:_hid} household ID"
	display as text  _col(4) "{bf:_pid} personal ID"
	display as text  ""
	display as text  "See {help postbfm} for postestimation commands."
	
	// ---------------------------------------------------------------------- //
	// Return some data, mostly for postestimation commands
	// ---------------------------------------------------------------------- //
	
	// Define locals with structure of missing population
	quietly sum _weight if `income'>`y_max_old'
	local unobs_pop=r(sum)/`popsize'
	local above_MP_tax=1-`mergingpoint'
	local corrected_pop=`above_MP_tax'-`above_MP_svy'
	local unobs_sh=`unobs_pop'/(abs(`corrected_pop'))
	local other_pop=`corrected_pop' - `unobs_pop'
	local other_sh=(`other_pop'/`corrected_pop')
	
	// Scalars
	ereturn scalar truststart = `truststart'
	ereturn scalar mergingpoint = `mergingpoint'
	ereturn scalar y_max_old=`y_max_old'
	ereturn scalar above_MP_svy=`above_MP_svy'
	ereturn scalar unobs_pop=`unobs_pop'
	ereturn scalar above_MP_tax=`above_MP_tax'
	ereturn scalar corrected_pop=`corrected_pop'
	ereturn scalar unobs_sh=`unobs_sh'
	ereturn scalar other_sh=`other_sh'
	if ("`sigma'" != "") {
		ereturn scalar var_res=`sigma'
	}
	
	// Macros
	ereturn local  income_var "`income'"
	
	// Matrices
	if ("`theta'" != "") {
		ereturn matrix theta = `theta'
	}
	if ("`beta_ridge'" != "") {
		ereturn matrix beta_ridge = `beta_ridge'
	}
	ereturn matrix mat_lorenz_old = `mat_lorenz_old'
	ereturn matrix mat_sum_old = `mat_sum_old'
	ereturn matrix adj_factors = `adjfactors'
end

// -------------------------------------------------------------------------- //
// Mata code performing the main matrix operations
// -------------------------------------------------------------------------- //

mata:
mata set matastrict on

// Perform one-dimensional ridge regression
real vector ridge_regression(real vector y, real vector x, real vector w,
                             real scalar beta, real scalar lambda) {

	real matrix Q, X, b0
	real scalar n
	
	// Number of observations
	n = length(y)
	
	// Normalize weights
	w = w/quadsum(w)*n
	
	// Penalization matrix
	Q = (0, 0 \ 0, lambda)
	
	// Prior values for the parameter
	b0 = (0 \ beta)
	
	// Add an intervept to idenpendent variables
	X = (J(n, 1, 1), x)
	
	return(qrsolve(quadcross(X, w, X) + Q, quadcross(X, w, y) + Q*b0))
}

// Perform isotonic regression using Pool Adjacent Violators Algorithm
// (see http://stat.wikia.com/wiki/Isotonic_regression)
real vector isotonic_pava(real vector w, real vector a, real scalar reverse) {
	real vector y, a_prime, w_prime, S
	real scalar n, j
	
	if (reverse) {
		a = -a
	}
	
	n = length(a)
	y = J(n, 1, .)
	
	j = 1
	
	S = J(n, 1, .)
	S[1] = 0
	S[2] = 1
	
	a_prime = J(n, 1, .)
	a_prime[1] = a[1]

	w_prime = J(n, 1, .)
	w_prime[1] = w[1]
	
	for (i = 2; i <= n; i++) {
		j = j + 1
		a_prime[j] = a[i]
		w_prime[j] = w[i]
		while (1) {
			if (j <= 1) {
				break
			}
			if (a_prime[j] >= a_prime[j - 1]) {
				break
			}
			a_prime[j - 1] = (w_prime[j]*a_prime[j] + w_prime[j - 1]*a_prime[j - 1])/(w_prime[j] + w_prime[j - 1])
			w_prime[j - 1] = w_prime[j] + w_prime[j - 1]
			j = j - 1
		}
		S[j + 1] = i
	}
	for (k = 1; k <= j; k++) {
		for (l = S[k] + 1; l <= S[k + 1]; l++) {
			y[l] = a_prime[k]
		}
	}
	
	if (reverse) {
		y = -y
	}
	
	return(y)
}

// Give the result of a linear calibration problem with the constraint that
// weights are greater than one
real vector calibrate(real vector d, real matrix X, real matrix Z, real vector M) {
	real matrix inv_sigma, X_free, X_cns, Z_free, Z_cns, d_free
	real vector w, free, m, M_cns, below_one, too_high, too_low
	real scalar rank, N, i, thetalimit
	
	thetalimit = strtoreal(st_local("thetalimit"))
	
	// All weights are intially free. We will progressively constrain those that
	// fall below one or when the calibration exceed the limits
	w = d
	free = J(rows(d), 1, 1)
	
	i = 1
	while (1) {
		display("{text:iteration " + strofreal(i) + ": " + strofreal(sum(!free)) + " weight(s) constrained}")
		
		st_select(X_free, X, free)
		st_select(X_cns, X, !free)
		st_select(Z_free, Z, free)
		st_select(Z_cns, Z, !free)
		st_select(d_free, d, free)
		
		// Remove constrained observations from the margins
		M_cns = M :- quadcolsum(Z_cns)'
		// Calculate population size
		N = quadsum(d_free)
		// Calculate survey margins
		m = quadcolsum(Z_free :* d_free)'
		// Calculate the new weights
		H = svsolve(quadcross(Z_free, d_free, X_free), M_cns - m, rank, 1e-16)
		// Only update free weights
		w[selectindex(free)] = d_free :* (1 :+ (X_free * H))
		// Check if there are invalid weights
		below_one = (w :<= 1)
		too_low = (w:/d :< 1/thetalimit)
		too_high = (w:/d :> thetalimit)
		if (sum((below_one :| too_low :| too_high) :& free) == 0) {
			// Algorithm converged
			st_matrix(st_local("coefs"), H)
			st_local("success", "1")
			
			return(w)
		}
		
		if (sum(below_one) >= 0.5*rows(w)) {
			// Algorithm did not converge
			st_local("success", "0")
			return(w)
		}
		
		// Constrain all the weights that violate the constraints
		free[selectindex(too_low :| below_one)] = J(sum(too_low :| below_one), 1, 0)
		w[selectindex(too_low :| below_one)] = rowmax((
			J(sum(too_low :| below_one), 1, 1),
			d[selectindex(too_low :| below_one)]/thetalimit
		))
		
		free[selectindex(too_high)] = J(sum(too_high), 1, 0)
		w[selectindex(too_high)] = d[selectindex(too_high)]*thetalimit
		
		i = i + 1
	}
}

real vector ot_income(real vector p, real vector thr, real vector avg, real vector s) {
	// Size of the tabulation
	k = length(p)
	// Number of observations to attribute income to
	n = length(s)
	
	y = J(n, 1, .)
	
	// Parameters of the Pareto distribution at the top
	mu = thr[k]
	beta = avg[k]/thr[k]
	alpha = beta/(beta - 1)
	// Parameters of the uniform distributions (mean-split histogram)
	a = J(2*(k - 1), 1, .)
	b = J(2*(k - 1), 1, .)
	q = J(2*(k - 1), 1, .)
	for (i = 1; i < k; i++) {
		a[2*i - 1, 1] = thr[i]
		b[2*i - 1, 1] = avg[i]
		q[2*i - 1, 1] = (p[i + 1] - p[i])*(thr[i + 1] - avg[i])/(thr[i + 1] - thr[i])
		
		a[2*i, 1] = avg[i]
		b[2*i, 1] = thr[i + 1]
		q[2*i, 1] = (p[i + 1] - p[i])*(avg[i] - thr[i])/(thr[i + 1] - thr[i])
	}
	q = (p[1] \ p[1] :+ runningsum(q))[1..(2*(k - 1))]
	
	// We start from the top, where we assume a Pareto distribution
	p0 = p[k]
	y[1] = thr[k]*beta*((1 - s[1])/(1 - p[k]))^(-1/alpha)
	i = 2
	while (s[i] > p[k]) {
		p1 = s[i - 1]
		p2 = s[i]
		y[i] = ((-(alpha*(-1 + p1)*(1 - p2)^(1/alpha)) + alpha*(1 - p1)^(1/alpha)*(-1 + p2))*
			((1 - p0)/((-1 + p1)*(-1 + p2)))^(1/alpha)*thr[k])/((-1 + alpha)*(-p1 + p2))
		i = i + 1
	}
	
	// Observation covering both brackets
	p1 = s[i - 1]
	p2 = p[k]
	y1 = ((-(alpha*(-1 + p1)*(1 - p2)^(1/alpha)) + alpha*(1 - p1)^(1/alpha)*(-1 + p2))*
		((1 - p0)/((-1 + p1)*(-1 + p2)))^(1/alpha)*thr[k])/((-1 + alpha)*(-p1 + p2))
	
	p0 = q[2*(k - 1)]
	p1 = p[k]
	p2 = s[i]
	p3 = p[k]
	y2 = (b[2*(k - 1)]*(2*p0 - p1 - p2) + a[2*(k - 1)]*(p1 + p2 - 2*p3))/(2*(p0 - p3))
	
	y[i] = y1*(p[k] - s[i - 1])/(s[i] - s[i - 1]) + y2*(s[i] - p[k])/(s[i] - s[i - 1])
	
	i = i + 1
	
	// Next observations, covered by the mean-split histogram
	l = 2*(k - 1)
	while (i <= n) {
		if (s[i] <= p0 & l > 1) {
			l = l - 1
			p0 = q[l]
			p3 = q[l + 1]
		}
		p1 = s[i]
		p2 = s[i - 1]
		y[i] = (b[l]*(2*p0 - p1 - p2) + a[l]*(p1 + p2 - 2*p3))/(2*(p0 - p3))
		i = i + 1
	}
	
	return(y)
}

end
