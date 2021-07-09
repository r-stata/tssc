*! wyoung 1.0.2 14may2018 by Julian Reif
* 1.0.2: cluster bootstrap now required when clustered standard errors are present; force option added
* 1.0.1: cluster bootstrap option added

program define wyoung, rclass

	version 12

	* Syntax 1: one model with multiple outcomes 
	syntax [varlist(default=none)], cmd(string) familyp(varname) BOOTstraps(int) [weights(varlist) noRESAMPling seed(string) strata(varlist) cluster(varlist) force detail SINGLEstep replace]
	
	local outcome_vars "`varlist'"
	
	* Syntax 2: varying models with multiple outcomes/subgroups. 
	if "`outcome_vars'"=="" {
	
		* Perform a full trim to remove leading and trailing spaces from the cmd() option
		mata: st_local("cmd",strtrim(st_local("cmd")))
	
		* If user did NOT use compound double quotes in cmd(), pass through the string asis. This ensures the -tokenize- command below works properly.
		mata: if( substr(st_local("cmd"),1,1)!=char(96) ) stata("syntax, cmd(string asis) *");;
	}
	
	local user_cmd "wyoung `0'"
	
	tempfile bs
	tempname mat

	* N = number of bootstraps
	local N = `bootstraps'
	capture assert `N' > 0
	if _rc {
		di as err "bootstrap size must be greater than zero"
		exit 198
	}	
	
	* Seed option
	if !mi("`seed'") {
		cap set seed `seed'
		if _rc {
			di as error "invalid syntax for option {cmd:seed()}"
			set seed `seed'
		}
	}
	
	* Strata option
	local bs_strata ""
	if !mi("`strata'") {
		local bs_strata "strata(`strata')"
	}
	
	* Cluster option
	if !mi("`cluster'") {
		tempname id_cluster
		local bs_cluster "cluster(`cluster') idcluster(`id_cluster')"
	}	

	******
	* Syntax 1: user specifies varlist that will replace "OUTCOMEVAR"
	******
	if "`outcome_vars'"!="" {

		* K = number of outcomes in this family
		local K : word count `outcome_vars'

		* Ensure that "OUTCOMEVAR" is present in the command
		if !strpos("`cmd'"," OUTCOMEVAR ") {
			di as error "did not specify {it:OUTCOMEVAR} in option {cmd:cmd()}"
			exit 198
		}
		
		
		* If weights are specified, ensure there is one weight variable for each regression
		if "`weights'"!="" {
			
			local num_weightvars : word count `weights'
			if "`num_weightvars'"!="`K'" {
				di as error "number of weight vars = `num_weightvars' != `K' = number of regressions"
				exit 198
			}
			
			forval k = 1/`num_weightvars' {
				tokenize `weights'
				local weightvar_`k' ``k''
			}
		}

		* Define the K regressions
		forval k = 1/`K' {

			tokenize `outcome_vars'
			local y ``k''
			local outcomevar_`k' "`y'"
			
			* Baseline regression
			local tmp_`k':     subinstr local cmd     "OUTCOMEVAR" "`y'", word
			local cmdline_`k': subinstr local tmp_`k' "WEIGHTVAR"  "`weightvar_`k''"			
		}
	}
	
	******
	* Syntax 2: user specifies each individual model
	******
	else {

		* Split out the different models
		tokenize `"`cmd'"'

		local k = 0
		while `"`1'"' != "" {
			local k = `k'+1

			* Perform a full trim to remove leading and trailing spaces
			mata: st_local("1",strtrim(st_local("1")))

			* Strip leading and trailing quotes, if present (occurs when user specifies compound double quotes)
			mata: if( substr(st_local("1"),1,1)==char(34) & substr(st_local("1"),-1,1)==char(34) ) st_local(  "1", substr(st_local("1"), 2, strlen(st_local("1"))-2)  );;

			local cmdline_`k' `"`1'"'
			macro shift
		}
		
		* K = number of outcomes in this family
		local K = `k'
	}
	
	******
	* Step 1: Estimate the initial, unadjusted models
	******
	di as text "Estimating the family-wise {it:p}-values for " as result "`familyp'" as text " in the following set of regressions:"
	forval k = 1/`K' {
		di in yellow `"`cmdline_`k''"'
		if !strpos("`cmdline_`k''","`familyp'") {
			di as error "variable {bf:`familyp'} not listed as regressor in regression model above"
			exit 111
		}
	}

	qui forval k = 1/`K' {
	
		tempname p_`k' ystar_`k'
		
		* Obtain initial values for coefficient ("beta"), stderr, and p-value
		`cmdline_`k''
		
		local beta_`k' = _b[`familyp']
		local stderr_`k' = _se[`familyp']
		local N_`k' = e(N)
		if !mi("`e(depvar)'") local outcomevar_`k' "`e(depvar)'"
		
		matrix `mat' = r(table)
		scalar `p_`k'' = `mat'[rownumb(`mat',"pvalue"),colnumb(`mat',"`familyp'")]
		matrix drop `mat'
				
		if `p_`k''==. {
			di as error "p-value not obtainable from matrix r(table)"
			exit 504
		}

		if "`e(vce)'"=="cluster" local vce_cluster 1
	}

	* Issue error if user is estimating a model with clustered standard errors AND did not specify a bootstrap cluster (unless force option specified)
	if "`vce_cluster'"=="1" & mi("`cluster'") & mi("`force'") {
			di as error "estimating model with clustered standard errors, but {bf:cluster()} option was not specified"
			exit 198
	}

	preserve
	
	******
	* Use bootstrapping to resample the data, and calculated Westfall-Young adjusted p-vals
	******	
	if "`resampling'"!="noresampling" {

		***
		* Step 2(a). Loop over each bootstrap i and calculate pstar's
		***
		qui forval i = 1/`N' {

			* Draw a (possibly stratified, possibly clustered) random sample with replacement
			bsample, `bs_strata' `bs_cluster'
			if "`bs_cluster'"!="" {
				drop `cluster'
				ren `id_cluster' `cluster'
			}

			* Calculate pstar for each model
			qui forval k = 1/`K' {

				`cmdline_`k''				
				test _b[`familyp']=`beta_`k''
				local pstar_`k' = r(p)	
				
				local Ni_`k' = e(N)
			}
			
			* Store results from each model k
			drop _all
			set obs `K'
			gen i = `i'
			gen k = _n
			gen pstar = .
			gen p = .
			if !mi("`detail'") gen N = .
			qui forval k = 1/`K' {
				replace pstar = `pstar_`k'' in `k'
				replace p  = `p_`k'' in `k'
				if !mi("`detail'") replace N = `Ni_`k'' in `k'
			}
			
			if `i'>1 append using "`bs'"
			save "`bs'", replace
			
			restore, preserve
		}

		***
		* Calculate Westfall-Young adjusted p-vals
		***
		use "`bs'", clear

		* Step 2(b). Enforce monotonicity with successive minima to produce step-down p-values. Include k in the sort to break ties.
		gsort i -p k	
		qui by i: gen qstar = pstar if _n==1
		qui by i: replace qstar = min(qstar[_n-1],pstar) if _n>1
		
		* Define minimum for single-step p-value
		qui by i: egen qstar1 = min(pstar)
		
		if !mi("`detail'") local Nstats "(mean) Navg=N (min) Nmin=N (max) Nmax=N"

		* Steps 3 and 4. Calculate step-down and single-step Westfall-Young adjusted p-value
		qui gen counter  = qstar <=p
		qui gen counter1 = qstar1<=p
		collapse (sum) counter* `Nstats', by(k) fast
		qui gen pwyoung  = counter /`N'
		qui gen pwyoung1 = counter1/`N'
		drop counter*
		
		assert pwyoung<=pwyoung1
	}
	qui else {
		drop *
		set obs `K'
		gen k = _n
	}
	
	******
	* Enforce monotonicity, format results, and calculate some additional adjustments
	******	
	
	* Fill in descriptive information
	qui gen model=""
	qui gen outcome=""
	qui gen double coef = .
	qui gen double stderr = .
	qui gen double p = .
	if !mi("`detail'") qui gen N = .

	qui forval k = 1/`K' {
		replace model = `"`cmdline_`k''"'      if k==`k'
		replace outcome = "`outcomevar_`k''"   if k==`k'
		replace coef = `beta_`k''              if k==`k'
		replace stderr = `stderr_`k''          if k==`k'
		replace p  = `p_`k''                   if k==`k'
		if !mi("`detail'") replace N = `N_`k'' if k==`k'
	}	
	
	* Step 5. Enforce monotonicity using successive maximization.  Include k in the sort to break ties.
	sort p k
	qui cap replace pwyoung  = max(pwyoung[_n-1]  ,pwyoung)   if _n>1
	qui cap replace pwyoung1 = max(pwyoung1[_n-1] ,pwyoung1)  if _n>1

	* Calculate Holm-Bonferroni and Holm-Sedak step-down corrections
	tempname j
	qui gen `j' = _N-_n+1
	
	qui gen double pbonf = min(p*`j',1) if _n==1
	qui replace    pbonf = min(max(p*`j',pbonf[_n-1]),1) if _n>1

	qui gen double psidak = min((1-(1-p)^(`j')),1) if _n==1
	qui replace    psidak = min(max((1-(1-p)^(`j')),psidak[_n-1]),1) if _n>1
	
	if !mi("`detail'") local Ns "N Navg Nmin Nmax"
	
	label var pbonf "Bonferroni-Holm p-value"
	label var psidak "Sidak-Holm p-value"
	label var stderr "Unadjusted standard error"
	label var p  "Unadjusted p-value"
	cap label var pwyoung   "Westfall-Young adjusted p-value"
	cap label var pwyoung1 "Westfall-Young adjusted p-value (single-step)"
	cap label var N "Number of obs"
	cap label var Navg "Average number of obs (bootstraps)"
	cap label var Nmin "Min number of obs (bootstraps)"
	cap label var Nmax "Max number of obs (bootstraps)"
	
	assert psidak<=pbonf+0.00000000001
	foreach v of varlist p* {
		assert `v'<=1
	}
	
	* Single-step values
	if !mi("`singlestep'")  {
		gen double pbonf1 = min(`K'*p,1)
		gen double psidak1 = 1-((1-p)^`K')
		label var pbonf1 "Bonferroni p-value (single-step)"
		label var psidak1 "Sidak p-value (single-step)"
	}
	else cap drop pwyoung1
	
	sort k
	drop `j'
	qui gen regressor = "`familyp'"
	order k model outcome regressor coef stderr p `Ns'
	list
	
	mkmat coef stderr p*, matrix(`mat')
	
	if "`replace'"=="replace" restore, not
	
	******
	* Return values
	******
	return matrix table `mat'
	
	return local cmdline `user_cmd'
	return local cmd wyoung
end

** EOF

