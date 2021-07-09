*! ver 1.9; 2020-05-21 
*  ver 1.8; 2020-05-07 
* ver 1.7; 2020-04-24 
* ver 1.6; 2020-01-16
* ver 1.5; 2020-01-04
* ver 1.4; 2019-12-25
* ver 1.3; 2019-12-19
* ver 1.2; 2019-12-18
* ver 1.1; 2019-12-12
* ver 1.0; 2019-12-06

program define bunchbounds, sortpreserve rclass
        version 14
		syntax varname(numeric) [if] [in] [fw] ///
		,  Kink(real) M(real) tax0(real) tax1(real) ///
		[ NOPIC SAVING(string asis) ]
		
		********************************************************************************************
		*1. SETUP
		********************************************************************************************
		* 1. observations to use
		marksample touse
        qui count if `touse'
        if r(N) == 0 error 2000
		
		* 2. input values are correct
		if `m' <= 0 | `m' == . {
				di as err "Strictly positive value for {bf:m} is required to run the code"
				exit 198
		}
		if `tax0' >= `tax1' {
				di as err "Value of {bf:tax1} must be bigger that {bf:tax0}"
				exit 198
		}		

		* 3. -saving()- specified, file exists, -replace- omitted
		CheckSaveOpt `saving'
		local saving `s(filename)'
		local replace_opt `s(replace)'
		if `"`saving'"' != "" & `"`replace_opt'"' == "" {
			
			* confirm file ezists with file extension (un)specified (.dta)
			local ext = substr("`saving'", strpos("`saving'", ".") + 1, 3)

			if "`ext'" == "" | "`ext'" == "`saving'" {
				cap confirm file "`saving'.dta"
			}
			else {
				cap confirm file "`saving'"
			}
			
			* raise an error in case a file exists
			if !_rc {
				di as err "file `saving' already exists. Use " `"""' "replace" `"""' " option to overwrite the file"
				exit 602
			}
		}
	
		* 4. -lpdensity- installed
		capture which lpdensity 
			if _rc==111 {
			di `"""'
				local packname "lpdensity"

				di as err "You need to install the Stata package " `"""' "lpdensity" `"""' " before proceeding."
				di ""
				di as text "References:"
				di ""
				di as text "Cattaneo, Jansson and Ma (2019): Simple Local Polynomial Density Estimators, Journal of the American Statistical Association, forthcoming."
				di ""
				di as text "sites.google.com/site/nppackages/lpdensity"
				di ""
				di as text "To install in Stata try:"
				local http = "https://sites.google.com/site/nppackages/lpdensity/stata"
				display as input `"{stata "net install lpdensity, from(`http') replace"}"'
				exit 199
			}
	
	
		** work with a sample described with [in] [if]
		preserve
		qui keep if `touse'
	
        * 5. setup variables
		tokenize `varlist'
		** variables:
        * bunch = bunching mass
        * right = prob of being the right side of the kink
		* left = prob of being the left side of the kink
		* gridvar = grids upon which to estimate the density
		* tot = frequency weights (w)
		* pw = prob. weights (pw)
		* case = categorical variable for three cases of interval
		qui {
                * variables
				tempvar bunch left right gridvar case emin emax cdf_y cdf_y_hat pdf_y dpdf_y gridM gridy
				* scalars & matrices
				tempname s0 s1 B_hat temp M_hat M_min_hat fyminus_hat fyplus_hat 
				tempname e_trap emin_mhat emax_mhat emin_mmax emax_mmax 
				tempname M_data_min M_data_max M_min_hat M_hat
 				tempname gridM_mat emin_mat emax_mat
		}

		********************************************************************************************
		* 2. Estimate bunching mass and side limits of PDF of y_i 
		********************************************************************************************
		* the log of one minus the tax rates 
		scalar `s0' = ln(1 - `tax0') 
		scalar `s1' = ln(1 - `tax1') 

		* bunching mass 
		qui gen `bunch' = (`1' == `kink')
		qui sum `bunch' [`weight'`exp']
		scalar `B_hat' = r(mean)
		if `=scalar(`B_hat')' == 0 {
				di as err "Estimated bunching mass is zero. Possible reasons for this:"
				di as err   "(1) The data are clean but there are numerical approximation issues. Does " `"""' "count if y==kink" `"""' " give the right number? Is y type double?"
				di as err   "(2) The data are clean and the elasticity is zero."
				di as err   "(3) The data are not clean: the bunching mass is dispersed in a neighborhood around the kink point because of friction errors and data need filtering. Type " `"{stata "help bunchfilter"}"' "."
				exit 198
		}

		* prob. being either side of the kink
		qui gen `left' = (`1' < `kink')
		qui sum `left' [`weight'`exp']
		local pleft_hat = r(mean)
		 
		qui gen `right' = (`1' > `kink')
		qui sum `right' [`weight'`exp']
		local pright_hat = r(mean)

		* define grids upon which to estimate the density
		qui gen `gridvar' = . 
		qui replace `gridvar' = `kink' if _n==1

		* generate prob. weights (pw) from frequency weights (w)
		if "`weight'`exp'" != "" {
			tempvar tot pw
			local weight_var = substr("`exp'", 2, .)
			qui egen `tot' = total(`weight_var')
			qui gen `pw' = `weight_var' / `tot'
		}
		
		* estimate side limits of empirical density*
		** added a weights option
		** scale option ensures the density integrated over 0 to kink equals pleft_hat
		qui lpdensity `1' if `1' < `kink' , grid(`gridvar') scale(`pleft_hat') pweights(`pw')
		mat `temp' = e(result)
		scalar `fyminus_hat' = `temp'[1,5]

		** scale option ensures the density integrated over kink to infinity equals pright_hat
		qui lpdensity `1' if `1' > `kink' , grid(`gridvar') scale(`pright_hat') pweights(`pw')
		mat `temp' = e(result)
		scalar `fyplus_hat' = `temp'[1,5]

		if !(`=scalar(`fyplus_hat')' > 0 & `=scalar(`fyminus_hat')' > 0) {
				di as err "We cannot proceed because at least one of the estimated side limits of the PDF at the kink is zero"
				exit 198
		}


		********************************************************************************************
		* 3.  Estimate M_hat and M_min_hat
		********************************************************************************************
		* value of M after which the interval becomes unbounded 
		* when M is bigger than M_hat, it is possible to have a PDF of n* without full support 
		scalar `M_hat' = ((`=scalar(`fyplus_hat')'^2 + `=scalar(`fyminus_hat')'^2) / (2* `=scalar(`B_hat')')) * (1 - 1/1000)

		* value of M before which the interval becomes empty
		** multiply by "(1+1/1000)" to fix missing e_trap in small samples
		scalar `M_min_hat' = ( abs(`=scalar(`fyplus_hat')' - `=scalar(`fyminus_hat')') * (`=scalar(`fyplus_hat')' + `=scalar(`fyminus_hat')') / (2*`=scalar(`B_hat')') ) * (1 + 1/1000)
		
		
		********************************************************************************************
		* 4. Give the user an idea of reasonable constant values M
		********************************************************************************************
		qui sum `1' [`weight'`exp']
		local binwidth = 0.5*(r(max)-r(min))/(min(sqrt(r(N)), 10*ln(r(N))/ln(10)))
		qui twoway__histogram_gen `1' [`weight'`exp'], gen(`pdf_y' `gridy') density width(`binwidth')
		qui gen `dpdf_y' = abs((`pdf_y'-`pdf_y'[_n-1])/(`gridy'-`gridy'[_n-1]))
		qui replace `dpdf_y' = . if (`gridy'<`kink'+`binwidth' & `gridy'>`kink'-`binwidth') | (`gridy'[_n-1]<`kink'+`binwidth' & `gridy'[_n-1]>`kink'-`binwidth') & `gridy'!=.
		qui replace `dpdf_y' = . if `pdf_y'==0 | `pdf_y'[_n-1]==0

		qui sum `dpdf_y'
		scalar `M_data_min' = r(min)
		scalar `M_data_max' = r(max)
	

		* display on the screen major results to give the user ideas if the code stops with errors
		* create local macros with pre-formatted values
		local vallist m M_data_min M_data_max M_min_hat M_hat
		foreach val of local vallist {
			local disp_name = "`val'_disp"
			if `=scalar(``val'')' == . {
				local `disp_name' = "+Inf"
			}
			else {
				local `disp_name' : display %8.4f `=scalar(``val'')'
			}
		}
		di ""
		di "Your choice of M:"
		di ustrtrim("`m_disp'")
		di ""
		di "Sample values of slope magnitude M"
		di " minimum value M in the data (continuous part of the PDF): "
		di "  " ustrtrim("`M_data_min_disp'")
		di " maximum value M in the data (continuous part of the PDF): " 
		di "  " ustrtrim("`M_data_max_disp'") 
		di " maximum choice of M for finite upper bound: " 
		di "  " ustrtrim("`M_hat_disp'")
		di " minimum choice of M for existence of bounds: " 
		di "  " ustrtrim("`M_min_hat_disp'")
		di ""
	
	
		********************************************************************************************
		* 5. Compare user choice M to M_hat and M_min_hat
		********************************************************************************************
		if `m' < `=scalar(`M_min_hat')' {
				di as err "Choice of M is too small. The partially identified set is empty"
				exit 198
		}


		********************************************************************************************
		* 6. estimate bounds for grid values of M
		********************************************************************************************
		* grid of values of M
		** make sure M_hat appears in the grid in case M_max > M_hat
		qui range `gridM' `=scalar(`M_min_hat')' `m' 1000
		if `m' >= `=scalar(`M_hat')' {
			qui replace `gridM' = `=scalar(`M_hat')' if _n == 50
		}

		* categorical variable for three cases of interval
		qui {
			gen     `case' = 1 if (`=scalar(`B_hat')' < abs(`=scalar(`fyplus_hat')' - `=scalar(`fyminus_hat')') * (`=scalar(`fyplus_hat')' + `=scalar(`fyminus_hat')')/(2 * `gridM')) & (`gridM' != .) 
			replace `case' = 2 if (abs(`=scalar(`fyplus_hat')' - `=scalar(`fyminus_hat')') * (`=scalar(`fyplus_hat')' + `=scalar(`fyminus_hat')') / (2 * `gridM') <= `=scalar(`B_hat')') ///
				& (`=scalar(`B_hat')' <= (`=scalar(`fyplus_hat')'^2 + `=scalar(`fyminus_hat')'^2)/(2 * `gridM')) ///
				& (`gridM' != .) 
			replace `case' = 3 if ( (`=scalar(`fyplus_hat')'^2 + `=scalar(`fyminus_hat')'^2)/(2*`gridM') < `=scalar(`B_hat')') & (`gridM' != .) 

			gen `emin' = ( 2*sqrt((`=scalar(`fyplus_hat')'^2)/2 + (`=scalar(`fyminus_hat')'^2)/2 + `gridM' * `=scalar(`B_hat')') - (`=scalar(`fyplus_hat')' + `=scalar(`fyminus_hat')')) / (`gridM'*(`=scalar(`s0')' - `=scalar(`s1')')) if (`case'==2)|(`case'==3) 
						
			gen `emax' = (-2*sqrt((`=scalar(`fyplus_hat')'^2)/2 + (`=scalar(`fyminus_hat')'^2)/2 - `gridM' * `=scalar(`B_hat')') + (`=scalar(`fyplus_hat')' + `=scalar(`fyminus_hat')')) / (`gridM'*(`=scalar(`s0')' - `=scalar(`s1')')) if  `case'==2 
		}


		* point estimate elasticity using trapezoidal approximation
		scalar `e_trap' = `emin'[1]
		
		* bound estimates at Mhat
		scalar `emin_mhat' = `emin'[50]
		scalar `emax_mhat' = `emax'[50]

		* bound estimates at M supplied by user 
		scalar `emin_mmax' = `emin'[1000]
		scalar `emax_mmax' = `emax'[1000]

		
		********************************************************************************************
		* 7. Graph the partially identified set against the maximum slope (M) choices
		********************************************************************************************
		sort `gridM'

		* the range of y should automatically adjust to the range of values of emin emax
		* the range of x should be a function of M_hat
		if missing("`nopic'") { 
						
			* graph preparations
			
			* set scales on the graph for better-looking 
			** define min/max
			qui sum `emax'
			local ymax = r(max)
			qui sum `emin'
			local ymin = r(min)
			local xmin = 0
			local xmax = `m'
			** set margins 
			local margin_x = (1/5) * (`xmax' - `xmin')/9
			local margin_y = (1/5) * (`ymax' - `ymin')/9
			** define last values on axes
			local yscalemax = `ymax' + `margin_y'
			local xscalemax = `xmax' + `margin_x'

			* set better displaying format with 2 digits in the decimal part
			local M_hat_disp : display %4.2f `=scalar(`M_hat')'
			local M_min_hat_disp : display %4.2f `=scalar(`M_min_hat')'
			* set a gap between lines
			local incry = (`ymax' - `ymin') / 9
			local incrx = (`xmax' - `xmin') / 9
			
			* if M_max >= M_min_hat but M_max < M_hat, then display only the first vertical line corresponding to M_min_hat
			if `m' >= `=scalar(`M_min_hat')' & `m' < `=scalar(`M_hat')' {
				local xline_prop = `=scalar(`M_min_hat')'
				local xlabel_prop = `M_min_hat_disp'
			}
			else {
				local xline_prop = "`=scalar(`M_min_hat')' `=scalar(`M_hat')'"
				local xlabel_prop = "`M_min_hat_disp' `M_hat_disp'"
			}

		
			** plot
			# delimit ;
			twoway 
			(
				line `emax' `gridM', lwidth(thick) clcolor(black) clpattern(dash) 
			) 
			(
				line `emin' `gridM', xaxis(1 2) lwidth(thick) clcolor(black) clpattern(solid) 
				xline(`xline_prop', lwidth(thin) lcolor(black)) 
				xlabel(`xlabel_prop', axis(1) labsize(medium)) 
				xlabel(`xmin' (`incrx') `xmax', 
					axis(2) format(%9.3gc) labsize(large))
				xscale(range(`xmin' `xscalemax'))
				yscale(range(`ymin' `yscalemax'))
				ylabel(`ymin' (`incry') `ymax', 
					axis(1) format(%9.3gc) labsize(large) angle(horizontal) glwidth(thin) glcolor(black) glpattern(dot)) 
				legend(ring(0)pos(2) label(1 "Upper") label(2 "Lower") cols(1) order(1 2) symysize(*1) symxsize(*1)  size(large))
			),
			graphregion(margin(right) style(none) color(gs16))
			xtitle("", axis(1))
			xtitle("Maximum slope of the unobserved density", axis(2) size(vlarge))
			ytitle("Elasticity estimate", axis(1) size(large))
			name(bunchbounds, replace)
			title("Bunching - Bounds"); 
			// graph export bmsbound.pdf, replace;
			# delimit cr
		}
		
		
		** export the data used for the graph 
		if "`saving'" != "" {
			ren `gridM' __gridM
			ren `emax'  __emax
			ren `emin'  __emin
			ren `case'  __case
			
			savesome __case __gridM __emin __emax using "`saving'" if __gridM != . , `replace_opt'
		}
		
		restore
		
		
		
		********************************************************************************************
		* 8. OUTPUT
		********************************************************************************************
		* display on the screen major results
		* create local macros with pre-formatted values
		local vallist e_trap emin_mmax emax_mmax emin_mhat emax_mhat
		foreach val of local vallist {
			local disp_name = "`val'_disp"
			if `=scalar(``val'')' == . {
				local `disp_name' = "+Inf"
			}
			else {
				local `disp_name' : display %8.4f `=scalar(``val'')'
			}
		}
	
		di "Elasticity Estimates"
		di " Point id., trapezoidal approx.: " 
		di "  " ustrtrim("`e_trap_disp'")
		di " Partial id., M = " ustrtrim("`m_disp'") " :"
		di "  [" ustrtrim("`emin_mmax_disp'") " , " ustrtrim("`emax_mmax_disp'") "]"

		
		* return scalars 
		return scalar bounds_e_trap = `e_trap'
		return scalar bounds_emin_mmax = `emin_mmax'
		return scalar bounds_emax_mmax = `emax_mmax'
		
		*** if user's choice of M is bigger than or equal M_hat, then also display:
		if `m' >= `M_hat' {
			return scalar bounds_emin_mhat = `emin_mhat'
			return scalar bounds_emax_mhat = `emax_mhat'
			
			di " Partial id., M = " ustrtrim("`M_hat_disp'") " :"
			di "  [" ustrtrim("`emin_mhat_disp'") " , " ustrtrim("`emax_mhat_disp'") "]"
			di ""
		}
		
		return scalar bounds_M_data_min = `M_data_min'
		return scalar bounds_M_data_max = `M_data_max'
		return scalar bounds_M_min_hat = `M_min_hat'
		return scalar bounds_M_hat = `M_hat'
end

program CheckSaveOpt, sclass
/* parse the contents of the -saving- option:
 * saving(filename [, replace])
 */

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

*! 1.1.0 NJC 23 February 2015 
*! 1.0.1 NJC 9 August 2011 
*! 1.0.0 NJC 25 April 2001 
program def savesome
	version 7.0 
	syntax [varlist] [if] [in] using/ [ , old * ] 
	preserve
	quietly { 
		if `"`if'`in'"' != "" { keep `if' `in' } 
		keep `varlist' 
	} 

	if "`old'" != "" { 
		capture which saveold 
		if `"`r(fn)'"' != "" { 
			saveold `"`using'"', `options' 
		}
		else save `"`using'"', old `options' 
	}
	else save `"`using'"', `options' 
end 	
