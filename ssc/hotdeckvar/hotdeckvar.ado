program define hotdeckvar, sortpreserve byable(recall)
*! 1.0.3  Feb  6, 2003 Matthias Schonlau 
*! 1.0.4  May 13, 2003 adding "by" option
*! 1.0.5  Jan 19, 2005 in case of duplicates a stable sort was required to ensure that the seed works properly
*! 1.0.6  Feb  9, 2006 Multivariate imputation, i.e. miss values in one obs are always impute from the same donor obs
*! 1.0.7  Feb 17, 2008 ignore option
*! 1.1.0  Apr  6, 2016 updated to version 14.0 ("set seed" no longer functioned with uniform() under version 7) 
	version 14.0
	syntax [varlist] [if] [in] ,  [ SUffix(str) ignore ]

	/* replaces missing values by random values from the same variable and from 
	observations allowed by if and in */
	

	* observations to use , keep missing value
	marksample touse , novarlist
	qui count if `touse' 
	if r(N) == 0 { 
		error 2000 
	} 
	local n_touse=r(N)
	*display "n_touse `n_touse' " 
	local k : word count `varlist'
	tokenize "`varlist'"

	if (`k'==0) {
		di as err "Need at least one variable"
		error 11
	}

	if (length("`suffix'")==0) {
		local suffix "_i"
	}
	tempname z  
	tempvar temp_sort   
	* for stable sorting 
	qui gen `temp_sort'=.


	tempvar nmiss impute_pool bstr nmiss_i 
	forval i = 1 / `k' { 
		local z`i'="``i''" 
		*display "z= `z`i''"
	}


	* separate data to impute from dis-allowed data
	gen `impute_pool'= 1
	qui replace `impute_pool'=0 if !`touse'
	forval i = 1 / `k' { 
		qui replace `impute_pool'=0 if  `z`i''==.  
	}

	qui sum `impute_pool'
	local sum1 =r(sum) 
	di as res  "Number of observations without missing values:" `sum1'
	local   nmiss= `n_touse' - `sum1'
	display as res  "Number of observations with    missing values:" `nmiss' 
	if (`n_touse'==`nmiss') { 
		if (!_by()) {
			di as error  "Error: There are missing values in each observation."
			di as error  "The variables cannot be imputed with a multivariate hotdeck."
			if ("`ignore'"=="") {
				error 10
			}
		}
		else  {
			di as error "Error: This by-group has missing values for each observation and cannot be imputed."
			if ("`ignore'"=="") {
				error 10
			}
		}	
	}
	if (`sum1'<`nmiss') { 
		di as error  "Warning: More missing values than observations without missing values."	
	}

	forval i = 1 / `k' { 
		local z_`i'="`z`i''`suffix'" 
		if ( (!_by() & `nmiss'>0) | ( _by() & _byindex()==1) ) {
			* if _by() we need to generate variable 
			* in case first group doesn't have missing values but later group does
			qui gen `z_`i''=``i''  /* copy entire variable, including not `touse'*/
			local g : value label ``i''
			label values `z_`i'' `g'
			local gg : variable label ``i''
			label variable `z_`i'' "`gg'"
		}
	}


	if (`nmiss'>0) { 
			* sort values that may be used for to replace missing values to the end of the data set
			* gsort -`impute_pool' substitute gsort with a stable sort 
			sort `impute_pool', stable
			qui replace `temp_sort'= _n
			gsort - `temp_sort'

			qui sum `impute_pool'
			local n_impute_pool=r(sum) 
			*display " n_impute_pool = `n_impute_pool' " 
			* impute using observatiosns  from 1.. n_impute_pool 
			qui gen long `bstr' = int(runiform()* `n_impute_pool') +1 
			forval i = 1 / `k' { 
				disp as result "Imputing `z_`i''"
				* replace from the same observation, but only replace is actually missing
				replace `z_`i''=`z`i''[`bstr'] if `z`i''==. & `touse'  /* only impute `touse' missing values*/		
				qui egen `nmiss_i'=sum(`z_`i''==. & `touse') /* possible error only for `touse' values'*/
				if (`nmiss_i'>0 & `nmiss_i'!=.) { 
					display as error "Number of missing in imputed variable `z_`i'' = " `nmiss_i'
					di as error "Imputed variable still has missing values"
					if (`ignore'=="") {
						error 9
					}
				}
				drop `nmiss_i'
			}

			* get rid of imputed varialbes where there were no missing data
			if (_bylastcall()) {
				forval i = 1 / `k' { 
					qui count if missing(`z`i'')
					if r(N)==0 {
						drop  `z_`i''
					} 
				}
			}



	}
	else {
			if (!_by()) {
				di as res "There are no missing values."
			}
			else  {
				di as res "This by-group has no missing values."
			}
		
	}

	
 
end 

