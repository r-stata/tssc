*! ver 1.8 2020-05-21
*  ver 1.7 2020-05-08
*  ver 1.6 2020-04-24


program define bunchtobit, sortpreserve rclass 
        version 14
		syntax varlist(min=1) [if] [in] [fw] ///
		,  Kink(real) tax0(real) tax1(real) ///
		[ Grid(numlist min=1 max=99 sort) ///
		Numiter(integer 500) VERBOSE NOPIC SAVING(string asis) BINWidth(real 9999425) ]

		********************************************************************************************
		* 0. SETUP
		********************************************************************************************
		* 1. observations to use
		marksample touse
        qui count if `touse'
        if r(N) == 0 error 2000

		* setup variables to use
		tokenize `varlist'
		local y_i `1'
		macro shift
		local covariates `*'
		
		
		* 2. check input pararmteres
		if `tax0' >= `tax1' {
				di as err "Value of {bf:tax1} must be bigger than {bf:tax0}" 
				exit 198
		}
		if `numiter' <= 0 {
				di as err "option {bf:numiter()} incorrectly specified"
				exit 198
		}
		qui count if `y_i' == `kink' & `touse'
		if r(N) <= 1 {
				di as err "Estimated bunching mass is zero. Possible reasons for this:"
				di as err   "(1) The data are clean but there are numerical approximation issues. Does " `"""' "count if y==kink" `"""' " give the right number? Is y type double?"
				di as err   "(2) The data are clean and the elasticity is zero."
				di as err   "(3) The data are not clean: the bunching mass is dispersed in a neighborhood around the kink point because of friction errors and data need filtering. Type " `"{stata "help bunchfilter"}"' "."
				exit    198
		}
		if `binwidth' <= 0  {
				di as err "option {bf:binwidth()} incorrectly specified: must be strictly bigger than 0"
				exit 198
		}
		
		
		* 3. -saving()- specified, file exists, -replace- omitted
		CheckSaveOpt `saving'
		local saving `s(filename)'
		local replace_opt `s(replace)'
		if `"`saving'"' != "" & `"`replace_opt'"' == "" {
			* find the file in the location specified
			local extpos = strpos("`saving'", ".dta")
			if (`extpos' == 0) local saving = "`saving'.dta"
			cap confirm file "`saving'"
			* raise an error in case a file exists
			if !_rc {
				di as err "file {bf:`saving'} already exists. Use " `"""' "replace" `"""' " option to overwrite the file"
				exit 602
			}
		}
	

		* 4. default grid size: 10(10)90
		if missing("`grid'") {
			forvalues t = 10 (10) 90 {
				local grid `grid' `t'
			}
		}
		
	
		* 5. verbouse mode, default - off (when option is not specified)
		if missing("`verbose'") {
			local qui_v = "qui"
		}
		else {
			local noi_v = "noisily"
		}

		
		** work with a sample described with [in] [if]
		preserve
		`qui_v' keep if `touse'
		
		
		********************************************************************************************
		* 1. CALCULATE
		********************************************************************************************
		* calculate variables
		* the log of one minus the tax rates 
		tempname s0 s1 
		scalar `s0' = ln(1 - `tax0') 
		scalar `s1' = ln(1 - `tax1') 

		* keep freq weight variables for normalizing likelihood function
		if "`weight'`exp'" != "" {
			local weight_var = substr("`exp'", 2, .)
		}
		else {
			tempvar w
			gen `w' = 1
			local weight_var = "`w'"
		}
				
		
		*graph the filtered data
		tempvar den_y_i gridy 
		tempname max_den_y_i 
		** get a binwidth if it's not specified by the user
		tempname bin_n
		if `binwidth' == 9999425 {
			qui sum `y_i' [`weight'`exp']
			local binwidth = 0.5*(r(max)-r(min))/(min(sqrt(r(N)), 10*ln(r(N))/ln(10)))
		}
		qui twoway__histogram_gen `y_i' [`weight'`exp'], gen(`den_y_i' `gridy') density width(`binwidth')
		** get a number of bins to draw on final twoway graphs
		scalar `bin_n' = r(bin)
		** a confition for final twoway graphs below 100
		qui sum `den_y_i' 
		scalar `max_den_y_i' = r(max)

		
		* to run all percentiles
		**i. set number of truncations and the biggest and smallest window size around kink
		tempname ngrid_p max_p min_p bin_p
		*** number of grid points
		scalar `ngrid_p' = wordcount("`grid'")
		
		*** biggest window size around kink uses max_p percentage of the data
		scalar `max_p' = word("`grid'", -1) 
		*** minimum window size around kink uses min_p percentage of the data
		scalar `min_p' = word("`grid'",  1)  
		*build a grid of window sizes around `kink'
		scalar `bin_p' = (`=scalar(`max_p')' - `=scalar(`min_p')') / (`=scalar(`ngrid_p')' - 1)
		* case of 1 grid point (e.g. grid(90))
		if wordcount("`grid'") == 1 {
		    scalar `bin_p' = 10
		}

		tempvar temp 
		tempname m perc_obs grid_h large_grid_h
		matrix `perc_obs' = J(`=scalar(`ngrid_p')', 1, 0)
		matrix `grid_h'   = J(`=scalar(`ngrid_p')', 1, 0)
		qui gen `temp'    = abs(`y_i' - `kink') 
		forval i = 1/`=scalar(`ngrid_p')' {
			scalar `m' = `=scalar(`ngrid_p')' - (`i' - 1)
			matrix `perc_obs'[`=scalar(`m')', 1] = round(`=scalar(`min_p')' + `=scalar(`bin_p')' * (`i'-1), 1)	
			_pctile `temp' [`weight'`exp'], percentiles(`=`perc_obs'[`=scalar(`m')',1]')
			matrix `grid_h'[`=scalar(`m')', 1] = `r(r1)'
		}

		*very large number for grid_h 
		qui sum `temp' [`weight'`exp']
		scalar `large_grid_h' = 10 * r(max)
		
		*add full sample to matrices perc_obs (i.e. 100%) and grid_h (i.e. very large number)
		matrix `perc_obs' = 100 \ `perc_obs'
		matrix `grid_h' = (`=scalar(`large_grid_h')') \ `grid_h'
		scalar `ngrid_p' = `=scalar(`ngrid_p')' + 1
		
		* fix row names for perc_obs (after adding "100" two "r1" were present)
		numlist "1/`=scalar(`ngrid_p')'"
		matrix rownames `perc_obs' = `r(numlist)'	

		
		*choose the variables you want to include in the estimation
		*the local namecov is a string list the variables (e.g. " x1 x2 x3 " ) OR a varlist object (e.g. x*)
		*number of covariates excluding the intercept
		tempname h ncovar
		scalar `ncovar' = wordcount("`covariates'")

		
		********************************************************************************************
		* 2.  Initial Values from Two-sided Tobit
		********************************************************************************************
		di as text "Obtaining initial values for ML optimization."
		
		cap ereturn clear 
		
		* tobit censored on the left, data on the RIGHT side of kink, save estimates
		cap `noi_v' tobit `y_i' `covariates' [`weight'`exp'], ll(`=scalar(`kink')') iterate(`numiter')
		
		* only look at the estimated variances of the intercept and sigma
		tempname vartest_r 
		cap matrix `vartest_r' = e(V)
		cap matrix `vartest_r' = `vartest_r'[`=scalar(`ncovar')'+1..., `=scalar(`ncovar')'+1...]

		* diagonal elements of "vartest_r" are either zero or not defined (e.g., ".")
		mata: st_local("zeroes", strofreal(diagcnt(st_matrix("vartest_r"))))

		* on error
		if e(converged) == 0 | e(converged) == . | _rc != 0 | `zeroes' == 1  {
			di as err "Tobit with data on the right of kink did not run!"
			exit 430
		}

		* get estimates 
		tempname estimates_r varcov_r init_cons_r init_sigma_r
		matrix `estimates_r'  = e(b)
		matrix `varcov_r'     = e(V)
		scalar `init_cons_r'  = _b[model:_cons]
		scalar `init_sigma_r' = _b[sigma:_cons]
		
		cap ereturn clear

		*tobit censored on the right, data on the LEFT side of kink, save estimates
		cap `noi_v' tobit `y_i' `covariates' [`weight'`exp'], ul(`=scalar(`kink')') iterate(`numiter')
		
		* only look at the estimated variances of the intercept and sigma
		tempname vartest_l
		cap matrix `vartest_l' = e(V)
		cap matrix `vartest_l' = `vartest_l'[`=scalar(`ncovar')'+1..., `=scalar(`ncovar')'+1...]

		* diagonal elements of "vartest_l" are either zero or not defined (e.g., ".")
		mata: st_local("zeroes", strofreal(diagcnt(st_matrix("vartest_l"))))

		* on error
		if e(converged) == 0 | e(converged) == . | _rc != 0 | `zeroes' == 1  {
			di as err "Tobit with data on the left of kink did not run!"
			exit 430
		}
		

		* get estimates 
		tempname estimates_l varcov_l init_cons_l init_sigma_l
		matrix `estimates_l'  = e(b)
		matrix `varcov_l'     = e(V)
		scalar `init_cons_l'  = _b[model:_cons]
		scalar `init_sigma_l' = _b[sigma:_cons]

	
		*save beta estimates of included variables
		tempname init_beta_l init_beta_r
		if `=scalar(`ncovar')' > 0 {
			matrix `init_beta_l' = J(1, `=scalar(`ncovar')', 0)
			matrix `init_beta_r' = J(1, `=scalar(`ncovar')', 0)		    
		}


		
		*create updated list of included variables for next step
		tempname ncovar2 var_left var_right init_beta init_sigma 
		
		local namecov2   = " " 
		scalar `ncovar2' = 0

		if `=scalar(`ncovar')' > 0 {
			forval j = 1/ `=scalar(`ncovar')' {
				*Stata sets variance to zero of coefficients of omitted variables 
				*use that to check which variables are omitted 
				scalar `var_left' = `varcov_l'[`j',`j'] 	
				scalar `var_right' = `varcov_r'[`j',`j']	


				*if j-th variable is omitted
				** let the user know
				** don't keep that variable in the next estimation
				if `=scalar(`var_left')*scalar(`var_right')' == 0 | `=scalar(`var_left')'== . | `=scalar(`var_right')'== .  { 			
					di as text "variable `=word("`covariates'", `j')' omitted because of collinearity"
				}
				*if j-th variable is not omitted
				** keep that variable in the next estimation
				** save the coefficients on that variable
				else {
					scalar `ncovar2' = `ncovar2' + 1
					local namecov2 = "`namecov2' " + word(" `covariates'", `j')
					matrix `init_beta_l'[1, `=scalar(`ncovar2')'] = `estimates_l'[1,`j']
					matrix `init_beta_r'[1, `=scalar(`ncovar2')'] = `estimates_r'[1,`j']
				}
			}
		}
		
		if `=scalar(`ncovar2')' > 0 {
			*update the dimension of init_beta_l and init_beta_r
			matrix `init_beta_l' = `init_beta_l'[1, 1..`=scalar(`ncovar2')']
			matrix `init_beta_r' = `init_beta_r'[1, 1..`=scalar(`ncovar2')']
			*initial guess is an avg of left and right betas and sigmas
			matrix `init_beta' = 0.5*(`init_beta_l' + `init_beta_r')
		}
		scalar `init_sigma' = 0.5*(`init_sigma_l' + `init_sigma_r')
		
		
		********************************************************************************************
		* 3.  Estimate Mid-Censored Tobit with covariates
		********************************************************************************************
		*3.2 Setup the ML estimation 
		********************************************************************************************
		*clear any previous ML definitions
		ml clear

		* matrices to store estimates from different truncation windows
		tempname theta_l_hat theta_r_hat
		tempname sigma_hat eps_hat se_hat covcol flag

		* intercept of the left model
		matrix `theta_l_hat' = J(`=scalar(`ngrid_p')', 1, .)
		matrix `theta_l_hat' = J(`=scalar(`ngrid_p')', 1, .)
		** intercept of the right model
		matrix `theta_r_hat' = J(`=scalar(`ngrid_p')', 1, .)
		** std error of the model
		matrix `sigma_hat'   = J(`=scalar(`ngrid_p')', 1, .)
		** elasticity
		matrix `eps_hat'     = J(`=scalar(`ngrid_p')', 1, .)
		** s.e. of elasticity estimator
		matrix `se_hat'      = J(`=scalar(`ngrid_p')', 1, .)
		** number of covariates that were omitted or had their coefficient restricted because of collinearity
		matrix `covcol'      = J(`=scalar(`ngrid_p')', 1, .)
		** flag=1 indicates failure of ML estimation to converge
		matrix `flag'        = J(`=scalar(`ngrid_p')', 1, .)


		**combines all of the initial values in one vector and re-scale them
		tempname init_delta_slope init_delta_l_cons init_delta_r_cons init_lngamma init_fullvec
		tempname covar_i
		tempvar pdf
		
		scalar `init_delta_l_cons' = `init_cons_l' / `=scalar(`init_sigma')' 
		scalar `init_delta_r_cons' = `init_cons_r' / `=scalar(`init_sigma')' 
		scalar `init_lngamma'      = -ln(`=scalar(`init_sigma')' )

		if `=scalar(`ncovar2')' > 0 {
		matrix `init_delta_slope'  = `init_beta'   / `=scalar(`init_sigma')' 
		matrix `init_fullvec'      = (`init_delta_slope', `=scalar(`init_delta_l_cons')', ///
									  `init_delta_slope', `=scalar(`init_delta_r_cons')', `=scalar(`init_lngamma')' )
		}
		else {
		matrix `init_fullvec'      = (`=scalar(`init_delta_l_cons')', /// 
									  `=scalar(`init_delta_r_cons')', `=scalar(`init_lngamma')' )
		}
				
				


		*generate variable (pdf--for graph)
		qui gen `pdf' = .

		if `=scalar(`ncovar2')' > 0 {
			*constrain coefficients on covariates to be the same above and below kink
			scalar `covar_i' = 0
			foreach name of local namecov2 {
				scalar `covar_i' = `=scalar(`covar_i')' + 1
				constraint `=scalar(`covar_i')' [eq_l]:`name' = [eq_r]:`name'
			}    
		}
		
		

		********************************************************************************************
		*3.3 Implement the ML estimation and loop over truncation windows
		********************************************************************************************
		* drop all previous graphs
		if missing("`nopic'") { 
			cap graph drop bunchtobit_distr_* 
			cap graph drop bunchtobit_elast
		}
		
		*set graphing font to times new roman;
		graph set window fontface "Times New Roman"

		* create a lable for X-axis: if label length is greater than 50 symbols --> wrap the lines by an empty space " "
		local varlabel : variable label `y_i'
		if length("`varlabel'") > 50 {
			local pos = ustrrpos("`varlabel'"," ", 25)
			local part1 = usubstr("`varlabel'", 1, `pos')
			local part2 = usubstr("`varlabel'", `pos' + 1, .)
			local varlabel = `" `part1' " " `part2' "'
		}
		
		* graph scaling and labels
		
		
		
		*loop over truncations defined by the grid grid_h
		tempname mat_est mat_V convg
		tempname beta_hat sterr
		tempvar beta_hat_cov ngridy temp_dens
		tempname covar_i
		tempvar obs
		tempname obs_num denom 
		
		forval i = 1 / `=scalar(`ngrid_p')' {

			di as text "Truncation window number `i' out of `=scalar(`ngrid_p')', `=`perc_obs'[`i',1]'% of data."

			*h gives the window on either side of the kink 
			scalar `h' = `grid_h'[`i',1]
			
			*compute # of  obs in the truncated sample
			**use this to re-scale bunchtobit_tloglike so it provides the average likelihood
			qui egen `obs' = total(`weight_var') if `y_i' <= `kink' + `=scalar(`h')'  & `y_i' >= `kink' - `=scalar(`h')'
			qui sum `obs'
			global obs_num_g = r(mean)
			drop `obs'

			* for bunchtobit_tloglike
			scalar ___kink = `kink'
			scalar ___h = `grid_h'[`i',1]
			scalar `denom' = `=scalar(`s1')' - `=scalar(`s0')'
			

			**sets up the model
			***in case x's are collinear:
			****if you do not use the "collinear" option in "ml model" there will be an error with redundant constraints
			****if you do use the "collinear" option in "ml model" there won't be an error with constraints but ml will choose one variable and set its
			*****coefficient to a fixed number (missing s.e.); it is not the same as omitting
			local constr_opt = "constraint(1 / `=scalar(`ncovar2')')"
			if `=scalar(`ncovar2')' == 0 local constr_opt = ""
			
			`qui_v' ml model lf bunchtobit_tloglike (eq_l:`y_i' = `namecov2') (eq_r:`y_i' = `namecov2') /// 
				(lngamma:) [`weight'`exp'] if `y_i' <= `kink' + `=scalar(`h')' & `y_i' >= `kink' - `=scalar(`h')' ///
				, collinear vce(r) tech(nr bhhh dfp bfgs) `constr_opt' /// 
				  diparm(lngamma, f(exp(-@)) d(-exp(@)) label(sigma)) /// 
				  diparm(eq_l lngamma, f(@1*exp(-@2)) d(exp(@2) -@1*exp(-@2)) label(cons_l)) /// 
				  diparm(eq_r lngamma, f(@1*exp(-@2)) d(exp(@2) -@1*exp(-@2)) label(cons_r)) /// 
				  diparm(eq_l eq_r lngamma, f((@2 - @1)*exp(-@3)/(`=scalar(`denom')')) /// 
				    d(-exp(-@3)/(`=scalar(`denom')')  exp(-@3)/(`=scalar(`denom')') -(@2-@1)*exp(-@3)/(`=scalar(`denom')')) /// 
					label(eps))
			

			*sets initial values for parameters
			** if this is the first iteration window, initial estimates come from 2-sided tobit
			** if this is the second or higher iteration window, then estimates come from the last trunc window with estimates that have converged
			** copy option below says to fill initial values by position of the vector rather than name of coefficients
			`qui_v' ml init `init_fullvec', copy
			

			*optimize 
			cap `noi_v' ml maximize, iter(`numiter')
			*store estimates
			cap matrix `mat_est' = r(table)
			cap matrix `mat_V'   = e(V)
			*store the standard error 
			scalar `sterr'       = `mat_est'[2, 2*(1 + `=scalar(`ncovar2')') + 5]
			*display return code in a verbose mode after running command and continue with next loop if we got an error
			if (_rc != 0 | e(converged) == 0 | `sterr' == 0 | `sterr' == .) {
				`qui_v' di as text "The return code is: " _rc
				scalar `convg' = 0
				//continue
			}
			else {
				scalar `convg' = 1
			}


			 *if ml converged, 
			 *** A) warn user if there was collinearity and store estimates 
			 *** B) set initial values for next iteration
			 *** C) graph the predicted distribution and empirical distribution 

			 if `=scalar(`convg')' == 1 {
				* A) warn user if there was collinearity and store estimates 
				** store estimates for coefficients that are not slope coefficients 
				matrix `sigma_hat'[`i',1]    = `mat_est'[1, 2*(1 + `=scalar(`ncovar2')') + 2]   
				matrix `eps_hat'[`i',1]      = `mat_est'[1, 2*(1 + `=scalar(`ncovar2')') + 5]
				matrix `se_hat'[`i',1]       = `mat_est'[2, 2*(1 + `=scalar(`ncovar2')') + 5]
				*left intercept
				matrix `theta_l_hat'[`i',1]  = `mat_est'[1, 2*(1 + `=scalar(`ncovar2')') + 3]
				*right intercept
				matrix `theta_r_hat'[`i',1]  = `mat_est'[1, 2*(1 + `=scalar(`ncovar2')') + 4]
				
				
				* covcol equals at least the covariates that were dropped in initial 2-sided tobit stage 
				matrix `covcol'[`i', 1] = `=scalar(`ncovar')' - `=scalar(`ncovar2')'

				*flag=0 indicating convergence
				matrix `flag'[`i', 1]        =  0

				if `=scalar(`ncovar2')' > 0 {
					forval j = 1 / `=scalar(`ncovar2')' {
						* Stata sets variance to zero of constrained coefficients of collinear variables 
						*** use that to identify the variables
						tempname var_j
						scalar `var_j' = `mat_V'[`j',`j']

						*if j-th variable is omitted
						** let the user know
						if `=scalar(`var_j')' == 0 | `=scalar(`var_j')' == . {
							di as text "  coefficient on variable `=word("`namecov2'", `j')' is constrained because of collinearity"				
							matrix `covcol'[`i', 1] = `covcol'[`i', 1] + 1
						}
					}
					*slope coefficients for PDF construction 
					matrix `beta_hat' = `mat_est'[1, 1..`=scalar(`ncovar2')'] * `sigma_hat'[`i',1]
				}
				

				*B) estimates converged in this trunc window, so update initial values for the next trunc window
				scalar `init_delta_l_cons' = `mat_est'[1, `=scalar(`ncovar2')' + 1]
				scalar `init_delta_r_cons' = `mat_est'[1, 2*(`=scalar(`ncovar2')' + 1)]
				scalar `init_lngamma'      = `mat_est'[1, 2*(`=scalar(`ncovar2')' + 1) + 1]
				
				if `=scalar(`ncovar2')' > 0 {
					matrix `init_delta_slope'  = `mat_est'[1, 1..`=scalar(`ncovar2')']    
					matrix `init_fullvec'      = (`init_delta_slope', `=scalar(`init_delta_l_cons')', /// 
												  `init_delta_slope', `=scalar(`init_delta_r_cons')', `=scalar(`init_lngamma')')
					}
				else {
					matrix `init_fullvec'      = (`=scalar(`init_delta_l_cons')', /// 
												  `=scalar(`init_delta_r_cons')', `=scalar(`init_lngamma')' )
				}
				
				
				********************************************************************************************
				*3.4 graphs of best fit distributions for each truncation window
				********************************************************************************************				
				*C) Graph predicted and actual distribution
				*generate X'beta 
				qui gen `beta_hat_cov' = 0 
				scalar `covar_i' = 0
				if `=scalar(`ncovar2')' > 0 {
					foreach name of local namecov2 {
						scalar `covar_i' = `=scalar(`covar_i')' + 1
						qui replace `beta_hat_cov' = `beta_hat_cov' + `beta_hat'[1,`=scalar(`covar_i')']*`name'
					}
				}

				
				*define best fit pdf
				qui replace `pdf' = .
				*loop through values of the grid
				sort `gridy'
				qui sum `gridy' 
				scalar `ngridy' = r(N)
				forvalues k = 1 / `=scalar(`ngridy')' {
					local yval = `gridy'[`k']
					*Need to take average across covariate values, separately for values below and above the kink
					if `yval' < `kink' & `yval' > `kink' - `=scalar(`h')' {
						qui gen `temp_dens' = normalden(`yval' - `theta_l_hat'[`i',1], `beta_hat_cov', `sigma_hat'[`i',1]) / ///
											(normal((`kink' + `=scalar(`h')' - `theta_r_hat'[`i',1] - `beta_hat_cov') / `sigma_hat'[`i',1]) ///
											 - normal((`kink' - `=scalar(`h')' - `theta_l_hat'[`i',1] - `beta_hat_cov')/`sigma_hat'[`i',1]) ///
											 )  
						qui sum `temp_dens' [`weight'`exp'] if `y_i' <= `kink' + `=scalar(`h')' & `y_i' >= `kink' - `=scalar(`h')' 
						qui replace `pdf' = r(mean) if _n == `k' 
						drop `temp_dens'
					}
					else if `yval' < `kink' + `=scalar(`h')' & `yval' > `kink' {
						qui gen `temp_dens' = normalden(`yval' - `theta_r_hat'[`i',1], `beta_hat_cov', `sigma_hat'[`i',1]) / /// 
											(normal((`kink' + `=scalar(`h')' - `theta_r_hat'[`i',1] - `beta_hat_cov') / `sigma_hat'[`i',1]) /// 
											 - normal((`kink' - `=scalar(`h')' - `theta_l_hat'[`i',1] - `beta_hat_cov')/`sigma_hat'[`i',1]) ///
											 ) 
						qui sum `temp_dens' [`weight'`exp'] if `y_i' <= `kink' + `=scalar(`h')' & `y_i' >= `kink' - `=scalar(`h')'
						qui replace `pdf' = r(mean) if _n == `k' 
						drop `temp_dens'
					}
				} 

				
				*rescales predicted pdf to account for truncation
				qui replace `pdf' = `pdf' * `perc_obs'[`i', 1]/100 
				
				if missing("`nopic'") { 
					* set scales on the graph for better-looking 
					** define y-axis
					qui sum `den_y_i', nomean
					qui sum `den_y_i' if `den_y_i' != r(max), nomean
					local ymax = r(max)  
					local ymin = 0
					local margin_y = (1/5) * (`ymax' - `ymin')/9
					** define last values on axes
					local yscalemin = `ymin'
					local yscalemax = `ymax' + `margin_y'


					** define x-axis
					quietly su `gridy' , d
					local xmax = r(p99) 
					local xmin = r(p1) 
					local margin_x = (1/5) * (`xmax' - `xmin')/9
					local xscalemin = `xmin' - `margin_x'
					local xscalemax = `xmax' + `margin_x'

					
					* legend and graph options
					if `perc_obs'[`i',1] == 100 {		
						*local 2ndline_cond = ""  
						local legend_opt = "on ring(0) pos(2) label(1 Data) label(2 Tobit model) cols(1) order(1 2) symysize(*1) symxsize(*1) size(large)" 
						*local 2ndline_cond = "& `pdf' <= `=scalar(`max_den_y_i')'" 
					}
					else if `perc_obs'[`i',1] < 100 {		
					    *local 2ndline_cond = "& `pdf' <= `=scalar(`max_den_y_i')'" 
						local legend_opt = "off"
					}

					* part of a graph name
					local pic_n = `perc_obs'[`i', 1]
					
					*graph empirical and predicted distributions
					# delimit ; 
					twoway 
					(
						bar `den_y_i' `gridy' if `gridy' >= `xscalemin' & `gridy' <= `xscalemax', bstyle(histogram) barwidth(`binwidth')  title("", ring(1) pos(11) size(medlarge)) 
					)
					(
						line `pdf' `gridy' if `gridy' < `kink' & `gridy' >= `xscalemin' & `gridy' <= `xscalemax' & `pdf' <= `=scalar(`max_den_y_i')' , sort(`gridy') color(black)  
					)
					(
						line `pdf' `gridy' if `gridy' > `kink' & `gridy' >= `xscalemin' & `gridy' <= `xscalemax' & `pdf' <= `=scalar(`max_den_y_i')', sort(`gridy') color(black)
					) ,
					title("Bunching - Tobit")

					xscale(range(`xscalemin' `xscalemax'))
					xlabel(#10, labsize(large))
					xtitle("`varlabel'", size(vlarge)) xline(`kink')
					
					yscale(range(`yscalemin' `yscalemax'))
					ylabel(#7, angle(horizontal) format(%12.2f) labsize(large) glwidth(thin) glcolor(black) glpattern(dot)) 
					ytitle("Density (`=scalar(`bin_n')' bins)", size(large))
					
					legend(`legend_opt')
					
					graphregion(margin(right) style(none) color(gs16))
					name(bunchtobit_distr_`pic_n', replace);
					# delimit cr
				}
				
				drop `beta_hat_cov'
			 }
			 
			 *if ml did not converge.
			 ***notify that it did not converge, set estimates to missing, and set flag to 1
			 else {
				di as err "  ML did not run. Estimates do not exist."
				matrix `theta_l_hat'[`i',1] = .
				matrix `theta_r_hat'[`i',1] = .
				matrix `sigma_hat'[`i',1]   = .
				matrix `eps_hat'[`i',1]     = .
				matrix `se_hat'[`i',1]      = .
				matrix `covcol'[`i',1]      = .
				matrix `flag'[`i',1]        = 1
			 }

		 } 
		 **end i loop
		scalar drop ___h ___kink
 		cap drop _MLtua1 _MLw1
		restore
		
		 
		********************************************************************************************
		* 4. OUTPUT
		********************************************************************************************
		*copy matrices into variables in your dataset
		tempfile bmstobit
		preserve
			clear
			qui set obs `=scalar(`ngrid_p')'
			matrix colname `theta_l_hat' = theta_l_hat
			matrix colname `theta_r_hat' = theta_r_hat
			matrix colname `sigma_hat'   = sigma_hat 
			matrix colname `perc_obs'    = perc_obs
			matrix colname `eps_hat'     = eps_hat
			matrix colname `se_hat'      = se_hat
			matrix colname `covcol'      = covcol
			matrix colname `flag'        = flag

			qui svmat `theta_l_hat' , names(col)
			qui svmat `theta_r_hat' , names(col)
			qui svmat `sigma_hat'   , names(col)
			qui svmat `perc_obs'    , names(col)
			qui svmat `eps_hat'     , names(col)
			qui svmat `se_hat'      , names(col)
			qui svmat `covcol'      , names(col)
			qui svmat `flag'        , names(col)
			* save in any case as a temp file to plot elasticities
			qui save "`bmstobit'", replace
			* but in case -saving- is specified, use given name to save dta
			if "`saving'" != "" {
				qui save "`saving'", `replace_opt'
			}
		restore
		

		* table
		tempname  out1
		mat def  `out1' = (`perc_obs' , `eps_hat' , `se_hat' , `covcol' , `flag')
		mat coln `out1' = "data %" "elasticity" "std err" "# coll cov" "flag"
		mat bunchtobit_out = `out1'
		mat li   bunchtobit_out
		
		 
		*r(class)
 		return matrix tobit_theta_l_hat = `theta_l_hat'
		return matrix tobit_theta_r_hat = `theta_r_hat'
		return matrix tobit_sigma_hat   = `sigma_hat'
		return matrix tobit_perc_obs    = `perc_obs'
		return matrix tobit_eps_hat     = `eps_hat'
		return matrix tobit_se_hat      = `se_hat'
		return matrix tobit_covcol      = `covcol'
		return matrix tobit_flag        = `flag'
		return scalar binwidth    = `binwidth'
		return scalar tobit_bin_n       = `bin_n'

		

	 
		********************************************************************************************
		*4 Graph elasticity estimate over truncation windows
		********************************************************************************************
		if missing("`nopic'") { 
		preserve
			use "`bmstobit'", clear

			*if you want to add the 100 percent point estimate by hand
			/*
			local new = _N + 1
			set obs `new'
			replace perc_obs = 100 if _n == `new'
			replace eps_hat = 1.011958 if perc_obs == 100
			replace se_hat = 0.000583 if perc_obs == 100
			gsort -perc_obs 
			*/
			qui {
				*the log file says only estimates past 7 percent are good
				gen graph = 0
				replace graph = 1 if flag    == 0
				replace graph = 0 if eps_hat == .

				*prep for graphing
				gen ci97p5 = eps_hat + 1.96 * se_hat
				gen ci2p5  = eps_hat - 1.96 * se_hat
			
				* set scales on the graph for better-looking 
				** define min/max
				qui sum ci97p5, nomean
				local ymax = r(max)
				local ymin = 0
// 				qui sum ci2p5, nomean
// 				local ymin = r(min)

				local xmin = 0
				local xmax = 100
				** set margins 
				local margin_x = (1/5) * (`xmax' - `xmin')/9
				local margin_y = (1/5) * (`ymax' - `ymin')/9
				** define last values on axes
				local yscalemax = `ymax' + `margin_y'
				local xscalemax = `xmax' + `margin_x'
				** define a gap between label
				local incry = (`ymax' - `ymin') / 9
				local incrx = (`xmax' - `xmin') / 10
			
				graph set window fontface "Times New Roman"
				# delimit ;
				twoway rarea ci97p5 ci2p5 perc_obs if eps_hat < 999
					, lwidth(vthin) lcolor(gs11) fcolor(gs11) 
					  graphregion(margin(right) style(none) color(gs16)) bgcolor(white)

				|| line eps_hat perc_obs if eps_hat < 999
					, lwidth(vthin) clcolor(black) clpattern(solid) legend(off) 
				xlabel(`xmin' (`incrx') `xmax', axis(1) format(%9.0fc) labsize(large) angle(horizontal)) 
				xtitle("Percent of data used for estimation", axis(1) size(vlarge)) 
				yscale(range(`ymin' `yscalemax')) 
				ylabel(#10, 
						axis(1) format(%9.3gc) labsize(large) angle(horizontal) glwidth(thin) glcolor(black) glpattern(dot)) 
				ytitle("Elasticity estimate" "95 p. confidence intervals", axis(1) size(vlarge)) 
				graphregion(margin(right) style(none) color(gs16)) 
				bgcolor(white)
				name(bunchtobit_elast, replace)
				title("Bunching - Tobit");
				# delimit cr
			}
		restore
		}
end


program CheckSaveOpt, sclass
/* parse the contents of the -saving- option:
 * saving(filename [, replace])
 */
	version 10
	syntax [anything] [, replace ]
	
	if `"`replace'`anything'"' != "" {
		if 0`:word count `anything'' > 2 {
			di as err "option saving() incorrectly specified"
			exit 198
		}
	}
	sreturn clear
	sreturn local filename `anything'
	sreturn local replace `replace'
end


mata:
/*
count zero or missing values in a e(V) diagonal
 flag if any diagonal values are either 0 or .
 sum up both cases
 if sum is greater than zero -> flag = 1
*/

real scalar diagcnt(real matrix X)
{
	real scalar     n
	real scalar     i
	real scalar     cnt_0
	real scalar     cnt_m
	real scalar     cnt
	real scalar     flag
                                                                                
	if ((n=rows(X)) != cols(X)) _error(3205)
	
	cnt_0 = 0
	cnt_m = 0
	for (i=1; i<=n; i++) {
		if (X[i,i] == 0) cnt_0++
		if (X[i,i] == .) cnt_m++
	}
	cnt = cnt_0 + cnt_m
	
	flag = 0
	if (cnt > 0) flag = 1
	return(flag)
}

end

