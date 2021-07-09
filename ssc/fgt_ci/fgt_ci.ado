capture program drop FGT_CI
program define FGT_CI, eclass properties(svyb)

	version 13.1

	syntax varlist(min=1 numeric fv) [if] [in] [pweight iweight], rankvar(varname numeric) [method(string) cutoff(real 0) power(real 0) modpart1(string) modpart2(string) boot_reps(integer 250) boot_seed(integer 852015) strata(varname) psu(varname) bsw_average(integer 10) noboot noresults table(string) table_opt(string)]
	
	* The first variable in varlist must be the health-related variable one wants to compute the CI
	* The following variables in varlist are the covariates to decompose the health-related variable
		* Note that factor variables are being allowed
		* Non-factor variables are treated as continuous covariates
		* Factor variables are treated as discrete covariates
		
	* OPTIONS	
	
	* method indicates which concentration index to compute and decompose. 
		* "standard" refers to the concentration index of the untransformed dependent varialbe
		* "threshold" refers to the FGT transformation defined above a cutoff value (e.g. body mass index above 30)
		* "ceiling" referes to the FGT transformation defined below a cutoff value (e.g. body mass index below 18.5)
	* ceiling sets the cutoff value under which differences are counted. This option cannot be specified simulateneously with threshold.
	* thresold indicates whether the cutoff value is a threshold (if 1) or a ceiling (if 0). Default is 1 (threshold).
	* power indicates which FGT power to use. Default is zero (status).
	
	* rankvar specifies the ranking variable for the CI calculation
	
	* modpart1 specifies the model used in the first part of the model. Default is logit.
	* modpart2 specifies the model used in the first part of the model. Default is reg.
		* For both parts, follow the specification of twopm.ado.

	* Bootstap options (boostrapping is mandatory as standard errors reported with a single estimate are incorrect)
		* boot_reps: is for the number of bootstrap repetitions, default value is 250
		* boot_seed: sets the seed for the bootstrap, default value is 852015
		* strata: indicates the strata variable (optional)
		* psu: indicates the primary sampling unit variable (optional)
		* bsw_average: is for the number of weights that are averaged in the mean bootstrap. Default value is 10.
		* noboot: indicates whether no boostrap is going on. Do not let the user setting this value, this is set internally to avoid an infinite number of bootstraps
	
	* Results options
		* noresults supresses the estimation results.
		* table(string) displays an aggregate result table and saves it under the name imputed as a string.
			* If string is "nosave" the option only displays the table without saving it.
			* If string is "", the table is neither displayed or saved.
			* Default value is "".
		* table_opt(string) options for esttab command.


	*** Body of the function ***
	
	* 0) Initialization
	
	marksample touse
	qui su `touse'
	local nobs = r(sum)
		
	* Prepare the weight variable for the concentration index
	if ("`weight'" != "") {
		local CIweight "aweight"
	}
	
	* Prepare the weight variable for the bootstrap
	local boot_wt "`exp'"
	local boot_wt: subinstr local boot_wt "=" ""
	tempvar boot_weight
	if ("`boot_wt'" == "") {
		gen `boot_weight' = 1
	} 
	else {
		gen `boot_weight' = `boot_wt'
	}
	qui replace `boot_weight' = 0 if !`touse'
	local boot_wt "`boot_weight'"
	
	* Retrieve the function's arguments without weights for svy bootstrap
	local arguments "`0'"
	gettoken arg_part1 arguments: arguments, parse("[") 
	gettoken weights arg_part2: arguments, parse(",") 
	
	* Check arguments
	
	* Separate dependent variable from covariates
	gettoken y covariates: varlist
	
	qui su `y' if `touse'
	if (r(min)<0) {
		di as error "warning: depend variable `y' contains negative values." 
	}
	qui su `y' if `touse'
	if (r(min)<0) {
		di as error "warning: depend variable `y' contains negative values." 
	}
	
	qui su `rankvar' if `touse'
	if (r(min)<0) {
		di as error "warning: rankvar contains negative values." 
	}
	
	* Options
	if ("`method'" == "") {
		local method "standard"
	}
	else {
		if (!("`method'" == "standard" | "`method'" == "threshold" | "`method'" == "ceiling")) {
			di as error "Option method must be either "standard", "threshold", or "ceiling."
			exit
		}
	}
	
	if (`power'<0) {
		di as error "Option power must be non-negative."
		exit
	}
	
	if ("`modpart1'"=="") {
		local modpart1 "logit"
		local modpart1_method "logit"
	}
	else {
		gettoken modpart1_method modpart1_options: modpart1, parse(",") 
	}
	
	if ("`modpart2'"=="") {
		local modpart2 "regress"
		local modpart2_method "regress"
	}
	else {
		gettoken modpart2_method modpart2_options: modpart2, parse(",") 
	}
	
	if (`boot_reps'<3) {
		di as error "Option boot_reps must be at least 3."
		exit
	}
	
	if (`boot_seed'<=0) {
		di as error "Option boot_seed must be non-negative."
		exit
	}
	
	if (`bsw_average'<=0) {
		di as error "Option bsw_average must be non-negative."
		exit
	}
	
	if ("`results'" == "noresults") {
		local results "quietly"
	}

	
	* 1) Create all indicator variables
	local covarnames ""	// list of covariate names stripped of the leading "i."
	local nonfactnames ""	// list of quantitative and binary variables
	local factnames ""	// list of factor variable names stripped of the leading "i."
	local modvars "" // list of covariate names including indicators for factor variables
	local nbfactvars = 0 // number of factor variables specified by the user
	foreach var of local covariates {
		gettoken pref v: var, parse(".")
		gettoken period v: v, parse(".")
		if ("`pref'" == "i") {
			local ++nbfactvars
			local covarnames "`covarnames' `v'"
			local factnames "`factnames' `v'"
			qui tab `v', gen(__I`v'_)
			forvalues cat = 2/`r(r)' {
				local modvars "`modvars' __I`v'_`cat'"
			}
		} 
		else {
			local covarnames "`covarnames' `var'"
			local nonfactnames "`nonfactnames' `var'"
			local modvars "`modvars' `var'"
		}
	}
	
	
	* 2) Create the FGT variable
	tempname FGTy 
	
	if ("`method'" == "standard") {
		gen `FGTy' = `y'
	}
	else {
		gen `FGTy' = 0
		if ("`method'" == "threshold") {
			qui replace `FGTy' = (`y'-(`cutoff'))^(`power') if `y' >= `cutoff'
		}
		else {
			* method == "ceiling"
			qui replace `FGTy' = (`cutoff'-(`y'))^(`power') if `y' <= `cutoff'
		}
	}
	
	* 3) Calculate the overal FGT-CI
	tempname CFGTy 
	
	qui concindc `FGTy' if `touse' [`CIweight' `exp'], welfarevar(`rankvar')
	matrix `CFGTy' = (r(concindex))
	matrix colnames `CFGTy' = total
	matrix coleq `CFGTy' = CIy


	* 4) If indepvars have been specified, decompose the total CI
	if ("`covariates'" != "") {

		* 4.1) Estimation

		if ("`method'" == "standard") {
			if ( "`modpart2_options'" == "") {
				local comma ","
			}
			`results' `modpart2_method' `FGTy' `modvars' if `touse' [`weight' `exp'] `modpart2_options' `comma'
		}
		else {
			if (`power'==0) {
				if ( "`modpart1_options'" == "") {
					local comma ","
				}
				`results' `modpart1_method' `FGTy' `modvars' if `touse' [`weight' `exp'] `modpart1_options' `comma'
			}
			else {
				`results' twopm `FGTy' `modvars' if `touse' [`weight' `exp'], firstpart(`modpart1') secondpart(`modpart2')
			}
		}

		
		* 4.2) Calculate the elasticities
		tempname elast eyex
		qui margins if `touse' [`weight' `exp'], eyex(*) post
		matrix `elast' = e(b)
		
		matrix `eyex' = `elast'[1,1...]
		matrix drop `elast'
		matrix coleq `eyex' = eyex

		
		* 4.3) Calculate the concentration index for each covariate and their contribution to the overall CI
		tempname CIk // concentration index for each covariate
		matrix `CIk' = `eyex'
		matrix coleq `CIk' = CIk

		tempname CIy // contribution of each covariate to the overall CI
		matrix `CIy' = `eyex'
		matrix coleq `CIy' = CIy

		local i = 1
		foreach var of local modvars {
			qui concindc `var' if `touse' [`CIweight' `exp'], welfarevar(`rankvar')
			matrix  `CIk'[1,`i'] = r(concindex)
			matrix `CIy'[1,`i'] = `eyex'[1,`i'] * r(concindex)
			local ++i
		}


		* 4.4) Aggregate the contributions of the factor variables, if any, and total contribution of all variables
			
		tempname CIy_tot
		if ("`factnames'" != "") {
			tempname CIy_fact
			matrix `CIy_fact' = J(1,`nbfactvars',0)
			matrix colnames `CIy_fact' = `factnames'
			matrix coleq `CIy_fact' = CIy_factvar
		}
	
		local fact = 0
		matrix `CIy_tot' = (0)
		foreach var of local covariates {
			gettoken pref v: var, parse(".")
			gettoken period v: v, parse(".")
			if ("`pref'" == "i") {
				local ++fact
				qui tab `v'
				forvalues cat = 2/`r(r)' {
					matrix `CIy_fact'[1,`fact'] = `CIy_fact'[1,`fact'] + `CIy'[1,"CIy:__I`v'_`cat'"]
					matrix `CIy_tot' = `CIy_tot' + `CIy'[1,"CIy:__I`v'_`cat'"]
				}
			} 
			else {	
				matrix `CIy_tot' = `CIy_tot' + `CIy'[1,"CIy:`var'"]	
			}
		}	
		

		* 4.5) Calculation of the regression residuals
		tempname residual
		
		matrix `residual' = `CFGTy' - `CIy_tot'
		matrix colnames `residual' = residual
		matrix coleq `residual' = CIy

		capture drop __I*
	}
	
	
	* 5) Bootstrap (only do it when option noboot is not specified, that is when macro boot is empty and does not contain "noboot"
	if ("`boot'" == "") {
	
		* Set the survey
		if ("`psu'" == "") {
			tempvar psu
			gen `psu' = _n
		}
		
		if ("`strata'" == "") {
			tempvar strata
			gen `strata' = 1
		}

		quietly svyset `psu' [pweight=`boot_wt'], strata(`strata')

		* Compute the bootstrap replication weights
		* Check bsweights

		bsweights ___bsw, reps(`boot_reps') n(-1) balanced double average(`bsw_average') seed(`boot_seed') dots replace	

		quietly svyset [pweight=`boot_wt'], bsrweight(___bsw*) bsn(`bsw_average')
		
		`results' svy bootstrap: FGT_CI `arg_part1' `arg_part2' noboot
		drop ___bsw*	
	}

	* 6) Return the results
	tempname b V

	if ("`boot'" == "") {
		* For final results
	
		* Take the boostrapped variance-covariance matrix
		matrix `b' = e(b)
		matrix `V' = e(V)
		
		* Display an aggregate table of results
		if ("`covariates'" != "") {
			if ("`table'"=="nosave") {
				esttab, b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05) order(`modvars' residual total) unstack label nonumbers nodepvars `table_opt'
			}
			else if ("`table'"!="") {
				esttab using "`table'", b(%9.3f) se(%9.3f) star(* 0.1 ** 0.05) order(`modvars' residual total) unstack label nonumbers nodepvars `table_opt'
			}
		}
	}
	else {
		* For boostrap iterations
		
		if ("`covariates'" != "") {
			if ("`factnames'" != "") {
				matrix `b' = (`CIk', `eyex', `CIy', `residual', `CFGTy', `CIy_fact')
			}	
			else {
				matrix `b' = (`CIk', `eyex', `CIy', `residual', `CFGTy')
			}
		}
		else {
			matrix `b' = (`CFGTy')
		}

		* Create fake variance-covariance matrix for individual bootstrap replications
		local colnames: colfullnames `b'
		matrix `V' = I(colsof(`b'))
		matrix colnames `V' = `colnames'
		matrix rownames `V' = `colnames'
	}

	ereturn post `b' `V', depname(`y') obs(`nobs') esample(`touse')
	ereturn local cmd "FGT_CI"
	
end
