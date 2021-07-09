*! version 2.0.3 5jul2019
// added routine for mean rather than upper and lower bins [bin_mean] (k = 2 arguments)
// added switch in bin_mid (k = 3) for grand mean option 
// added a nolist option for results display
// error check for string "by" variable -> encode to real and drop original
program define rpme, nclass byable(recall) sortpreserve
version 13.0 
// check for necessary utilities
capture findfile _ggini.ado

if "`r(fn)'" == "" {
         di as txt "user-written package egen_inequal needs to be installed first;"
         di as txt "use -ssc install egen_inequal- to do that"
         exit 498
      }

syntax varlist (min=2 max=3 numeric) [if] [in]  ///
		[,	SAVing(string asis) ///
			ALPHA_min(real 2.0) ///
			PARETO_stat(string) ///
			BY(varlist) ///
			GRAND_mean(varlist) ///
			NOList]


// check to make sure that BY variable is numeric
foreach v of varlist `by' {
//
capture confirm numeric variable `v'
                if _rc { 

//  			  local varlab : var lab `v'
//                encode   `v', generate(`v'1)
// 				  drop     `v'
// 				  gen      `v' = `v'1
// 				  drop     `v'1
//				  lab var  `v' "`varlab'"
                  di as txt "Note:  `v' is a string variable please encode it to numeric prior to calling rpme" 
				  exit 498
          }

   }             
// 
if "`pareto_stat'" == "" local pareto_stat "harmonic"

marksample touse, novarlist

if "`saving'" !=""{
 di "generated data will saved to `saving'"
}

local k : word count `varlist'

///////     k = 3 branch

if `k'==3 {
 
	if "`pareto_stat'"!="median" & "`pareto_stat'"!="arithmetic" & "`pareto_stat'"!="geometric" & "`pareto_stat'"!="harmonic" {
		di as txt "Error in pareto_stat() argument. Possible values are median, arithmetic, geometric, harmonic."
		exit 498
			}
	if `alpha_min'<=0  {
		di as txt "Error in alpha_min() argument. alpha_min must be positive."
		exit 498
			}

	if `alpha_min'<=1 & "`pareto_stat'"=="arithmetic"  {
		di as txt "Error in alpha_min() argument. The arithmetic mean is undefined unless alpha_min > 1."
		exit 498
			}

	tokenize `varlist'
	local n `1'
	local l `2'
	local u `3'

	qui drop if `n'==0 & `touse'
	qui count if ( `l' > `u')  & `touse'
		if r(N) > 0 {
			di as txt "`r(N)' observations `l' > `u', please check input"
			exit 498
			}

	if "`by'"!=""{
		qui sort `by' `l' 
			}
	else {
		qui sort `l' 
		}

	preserve

	tempvar bin_mid n_lag l_lag alpha c 
		qui egen  `bin_mid' = rowmean(`l' `u') if `touse'
		qui replace `bin_mid' = . if `u' == . & `touse'
		qui gen  `n_lag' = `n'[_n-1] if `touse'
		qui gen  `l_lag' = `l'[_n-1] if `touse'
		qui gen  `alpha' = (log(`n'+`n_lag') - log(`n')) / (log(`l') - log(`l_lag')) if `touse'
		qui replace `alpha' = max(`alpha_min',`alpha') if `touse'
		qui replace `alpha' = . if `u' != . & `touse'

	if "`pareto_stat'" == "arithmetic" { 
		qui gen      `c' = `alpha' / (`alpha' - 1) 
		} 
	else if "`pareto_stat'" == "harmonic"   { 
		qui gen      `c' =  (1+1/`alpha')         
		} 
	else if "`pareto_stat'" == "geometric"  { 
		qui gen      `c' = exp(1/`alpha')          
		} 
	else if "`pareto_stat'" == "median"     { 
		qui gen      `c' =  2^(1/`alpha')  
		} 

	qui replace `bin_mid' = `c' * `l' if `u' ==. & `touse'

	// handle grand_mean option 

		if "`grand_mean'" !=""{
			capture findfile _gwtmean.ado
				if "`r(fn)'" == "" {
				di as txt "user-written package _gwtmean needs to be installed first;"
				di as txt "use -ssc install _gwtmean- to do that"
				exit 498
				}

			tempvar mlb cab clb mab 
				qui replace `bin_mid' = (`l'+`u')/2 if `touse'
				qui egen `mlb' = wtmean(`bin_mid') if `touse', by(`by') weight(`n')
				qui egen `cab' = sum(`n') if `touse', by(`by')
				qui gen  `clb' = `cab' - `n' if missing(`u') & `touse'
				qui replace `bin_mid' = (`grand_mean' * `cab' - `clb' * `mlb')/`n' if missing(`u') & `touse'
				qui egen `mab' = wtmean(`bin_mid') if `touse', by(`by') weight(`n')
				qui replace `bin_mid' = `bin_mid' * (`grand_mean' / `mab')
		}

		local inequality rmd cov sdl gini mehran piesch kakwani theil mld entropy half
			if "`by'" != "" {
				foreach stat in  `inequality' {
				qui egen `stat'=`stat'(`bin_mid') if `touse', by(`by') weight(`n')
				}
			}

			else {
				foreach stat in  `inequality' {
				qui egen `stat'=`stat'(`bin_mid') if `touse',  weight(`n')
				}
			}

		if "`grand_mean'" !=""{
			di  "The grand mean has been used to calculate the top bin mean."
			di  "Pareto approximation for the top bin is not used."
			// remaining vars will be saved
			if "`by'" != "" {
				collapse (mean) mean=`bin_mid' (median) median=`bin_mid' (sd) sd=`bin_mid' (mean) `inequality'  [fw=`n'] if `touse', by(`by')  
				}
			else {
				collapse (mean) mean=`bin_mid' (median) median=`bin_mid' (sd) sd=`bin_mid' (mean) `inequality'  [fw=`n'] if `touse'
				}
		qui drop cov
		qui gen cv = sd / mean
		label variable mean 		"Mean"
		label variable median 		"Median"
		label variable sd 			"Standard deviation"
		label variable cv 			"Coefficient of variation"
		label variable rmd 			"Relative mean deviation"
		label variable sdl 			"Standard deviation of logs"
		label variable gini 		"Gini index"
		label variable mehran     	"Mehran index"
		label variable piesch     	"Piesch index"
		label variable kakwani    	"Kakwani index"
		label variable theil      	"Theil index"
		label variable mld        	"Mean log deviation"
		label variable entropy    	"Generalized entropy measure (GE -1)"
	
		format entropy-cv %9.2g 
		list if "`nolist'" == "", compress table clean
//  save it to designated file if specified
		if "`saving'" != ""{
			save `saving', replace
			di "saving results to `saving'"
			}
		drop _all
		} // done with k=3 w grand_mean option

	else if "`grand_mean'" ==""{

			gen pareto_stat = "`pareto_stat'" 
			gen alpha_min = `alpha_min'
			di "min and max bin values will be used"
			di "alpha_min set to `alpha_min'"
			di "pareto_stat set to `pareto_stat'"			
			// remaining vars will be saved
			if "`by'" != "" {
				collapse (mean) alpha = `alpha' (mean) mean=`bin_mid' (median) median=`bin_mid' (sd) sd=`bin_mid' (mean) `inequality'  [fw=`n'] if `touse', by(`by' pareto_stat alpha_min)  
				}
			else {
				collapse (mean) alpha = `alpha' (mean) mean=`bin_mid' (median) median=`bin_mid' (sd) sd=`bin_mid' (mean) `inequality'  [fw=`n'] if `touse', by(pareto_stat alpha_min)
				}
		qui drop cov
		qui gen cv = sd / mean
		label variable mean 		"Mean"
		label variable median 		"Median"
		label variable sd 			"Standard deviation"
		label variable cv 			"Coefficient of variation"
		label variable rmd 			"Relative mean deviation"
		label variable sdl 			"Standard deviation of logs"
		label variable gini 		"Gini index"
		label variable mehran     	"Mehran index"
		label variable piesch     	"Piesch index"
		label variable kakwani    	"Kakwani index"
		label variable theil      	"Theil index"
		label variable mld        	"Mean log deviation"
		label variable entropy    	"Generalized entropy measure (GE -1)"
		label variable alpha      	"estimated alpha"

		format alpha-cv %9.2g 
		list if "`nolist'" == "", compress table clean
//  save it to designated file if specified
		if "`saving'" != ""{
			save `saving', replace
			di "saving results to `saving'"
			}
	drop _all
	} // done with k=3 (w/o grand_mean option)
} // done with k==3 branch
///////     k = 2 branch

else if `k'==2 {
	di "Mean bin value will be used"
	tokenize `varlist'
	local n `1'
	local m `2'

	qui drop if `n'==0 & `touse'
	
	if "`by'"!=""{
		qui sort `by' `m' 
		}
	else {
		qui sort `m' 
	}

	preserve

	tempvar bin_mean  
	qui gen  `bin_mean' = `m' if  `touse'

	local inequality rmd cov sdl gini mehran piesch kakwani theil mld entropy half
	if "`by'" != "" {
		foreach stat in  `inequality' {
		qui egen `stat'=`stat'(`bin_mean') if `touse', by(`by') weight(`n')
		}
	}

	else {
		foreach stat in  `inequality' {
		qui egen `stat'=`stat'(`bin_mean') if `touse',  weight(`n')
		}
	}

// remaining vars will be saved
	if "`by'" != "" {
		collapse  (mean) mean=`bin_mean' (median) median=`bin_mean' (sd) sd=`bin_mean' (mean) `inequality'  [fw=`n'] if `touse', by(`by')  
			}
	else {
		collapse  (mean) mean=`bin_mean' (median) median=`bin_mean' (sd) sd=`bin_mean' (mean) `inequality'  [fw=`n'] if `touse'
		}

	qui drop cov
	qui gen cv = sd / mean
	label variable mean 	"Mean"
	label variable median 	"Median"
	label variable sd 		"Standard deviation"
	label variable cv 		"Coefficient of variation"
	label variable rmd 		"Relative mean deviation"
	label variable sdl 		"Standard deviation of logs"
	label variable gini 	"Gini index"
	label variable mehran   "Mehran index"
	label variable piesch   "Piesch index"
	label variable kakwani  "Kakwani index"
	label variable theil    "Theil index"
	label variable mld      "Mean log deviation"
	label variable entropy  "Generalized entropy measure (GE -1)"

	format entropy-cv %9.2g 
	list if "`nolist'" == "", compress table clean
//  save it to designated file if specified
		if "`saving'" != ""{
			save `saving', replace
			di "saving results to `saving'"
		}
	drop _all
} // done with k=2

// this should never happen...
else {
	di as txt "2 or 3 arguments must be specified, please check input"
    exit 498
}
 
end
