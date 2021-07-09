prog drop _all
*! denton  1.2.1   sh/cfb 16jul2014
*! 1.2.1: correct definition of orimin
program define denton
	version 11.1
	syntax varname(numeric ts) using/ [if] [in], INTerp(string) from(string) GENerate(string) [stock old] 
	di " "
	preserve	
	
* Validate datasets: new dataset and high frequency dataset.
	capture confirm file `using'
	if !_rc {
		di as error "`using' is an existing file."
		exit 602
	}
	capture confirm file `from'
	if _rc {
		di as error "`from' could not be found."
		exit _rc
	}

* Validate new variable does not exist.
	capture confirm new v `generate'
	if _rc {
		di as error "`generate' already exists in the current dataset."
		exit _rc
	}


*** Validate lower frequency file ***
* Verify data set is tsset
	capture tsset
	if _rc {
		di as error "Current data are not tsset."
		exit _rc
	}
	
* Capture the return of tsset: l_var -> refers to low frequency locals/variables.
	local l_curfreq `r(unit1)' 
	local l_timevar `r(timevar)'
	local l_unit	`r(unit)'
	local l_format	`r(tsfmt)'

// 1.2.0 validate l_curfreq
	if inlist("`l_curfreq'", "y", "q") == 0 {
		di as error "Low frequency dataset must be tsset as yearly or quarterly."
		exit 198
	}

* Constrain the sample from if/in statements.
	marksample touse, novarlist
	_ts timevar panelvar `if' `in', sort onepanel 
	markout `touse' `timevar'

* Verify there are no gaps in the time series selected. E.g.: 2001-2003 and 2008-2010. 
	tsreport if `touse' 
	if `r(N_gaps)' == 1 {
		di as error "There are gaps in the time series selected."
		exit 198
	}	
	
* Transform the timevar into daily format and create l_dformat.  
	tempvar l_dformat
	* Local l_dof takes values of : dofy or dofq: depending on the frequency of the data. 
	local l_dof dof`l_curfreq'
	qui gen `l_dformat' = `l_dof'(`l_timevar')	
		
	** Validate there are no missing values in the marked sample in `varlist' **
	qui sum `varlist' if `touse', meanonly

	local l_range `r(N)'
	if `l_range' == 0 {
		di as error "There are no observations in the selected sample."
		error 2000
	}
	qui sum `touse', meanonly
	if `r(sum)' != `l_range' {
		di as error "`varlist' has missing values in the selected sample."
		exit 416
 	}
	
	* orimin is used with stock data. Keeps the value of the first obs in the marked sample.    
	// following line does not do that unless first obs == min!
	//	local orimin `r(min)'
	qui tsset
	loc rt `r(timevar)'
	sum `rt' if `touse', meanonly
	loc rfirst `r(min)'
// di "*** `rfirst' `rt'"
	su `varlist' if `rt' == `rfirst' & `touse', mean
	loc orimin `r(mean)'
	
	qui sum `l_dformat' if `touse', meanonly
	local l_maxdate `r(max)'
	local l_mindate `r(min)'	
	
*** Validate higher frequency file *****

	qui use `from', clear	

* Verify that the indicator is a numeric variable
	capture confirm numeric variable `interp'
	if _rc {
		di as error "`interp' must be an existing numeric variable in `from'"
		exit _rc
	}

* Verify that the high frequency data is tsset.
	capture tsset
	if _rc {
		di as error "Data in `from' are not tsset."
		exit _rc
	}
	
* Capture the return of tsset: h_var -> refers to high frequency locals/variables.
	local h_curfreq `r(unit1)' 
	local h_maxdate `r(tmax)'
	local h_mindate `r(tmin)'
	local h_timevar `r(timevar)'
	local h_unit	`r(unit)'
	local h_format	`r(tsfmt)'	

* Verify high frequency data is not a panel - Needs testing with a panel. 
	if "`r(panelvar)'" != "" {
		di as error "`from' contains panel data."
		exit 198
	}
	
// 1.2.0 validate h_curfreq
	if inlist("`h_curfreq'", "q", "m") == 0 {
		di as error "High frequency dataset must be tsset as quarterly or monthly."
		exit 322
	}
	
	* mult - a scalar taking the value of 4 (Y to Q), 3 (Q to M), or 12 (Y to M). used in mata fn.
	tempname mult
	* h_dformat hold the tranformed timevar into daily format. 
	tempvar h_dformat
	
	* h_dof takes the value of dofq or dofm. Used when trasforming time formats.
	local h_dof dof`h_curfreq'
	* h_ofd takes the value of qofd or mofd.
	local h_ofd `h_curfreq'ofd
	
	* Generate a daily format variable.
	qui gen `h_dformat' = `h_dof'(`h_timevar')	
	

** Validate transformations and assign locals	**
* Assign values to mult
* Assign values to local num : used to create l_date (see below)
* Assign values to local qm : used to update l_maxdate to reflect the last date (update needed because of dayly transformation) 
* Assign values to h_extract (quarter or month): used in displaying dates.

	* Yearly to Quarterly interpolation
	if "`l_curfreq'" == "y" {
		if "`h_curfreq'" == "q" {
			scalar `mult' = 4
			local num = 4
			local qm = 4
			local h_extract quarter	
		}
	* Yearly to Monthly interpolation
		else if "`h_curfreq'" == "m" {
			scalar `mult' = 12
			local num = 12
			local qm = 12
			local h_extract month	
		}
	* Error if high freq is not quarterly or monthly
		else {
			di as error " `interp' should be either a monthly or quarterly variable"
			exit 322
		}
	}
	
	* Quarterly to Monthly interpolation.
	else if "`l_curfreq'" == "q" {
		if "`h_curfreq'" != "m"{
			di as error " `interp' should be a monthly variable"
			exit 322
		}
		scalar `mult' = 3	
		local num = quarter(`l_mindate')*3
		local qm = month(`l_maxdate') + 2
		local h_extract month
	}
	else{
		di "denton currently requires low-frequency data to be yearly or quarterly."
		exit 322
	}
	
	* y_max and y_min: capture the first and last year of the sample.
	local y_max = year(`l_maxdate')
	local y_min = year(`l_mindate')
	
	* l_date: used to create a new timevar in low freq data: e.g. tq(2001q4), where 2001 is y_min; or tm(2001m12) if Y->M.
	local l_date t`h_curfreq'(`y_min'`h_curfreq'`num')	
	
	* Update l_maxdate; e.g. for Y->Q update from l_maxdate = 1/Jan/2010 to 1/Oct/2010. Needed for range checks.  
	local l_maxdate = dof`h_curfreq'(t`h_curfreq'(`y_max'`h_curfreq'`qm'))
	
* Verify there are no gaps in high freq dataset
	tsreport if `h_dformat' >=`l_mindate' & `h_dformat' <= `l_maxdate'
	if `r(N_gaps)' == 1{
		di as error "There are gaps in the selected `h_unit' time series."
		exit 198
	}
		
* Check high frequency data is a superset of the low freq selected sample
	qui sum `h_dformat', meanonly 
	if `r(min)' > `l_mindate' | `r(max)' <`l_maxdate' {
		di as error "`interp' must be available for entire selected sample."
		exit 198
	}
	
	
* Check for empty values in the high freq data.

	* Note:	local l_range `r(N)', assigned before.
	local h_range = `mult'*`l_range'
	qui sum `interp' if `h_dformat' >=`l_mindate' & `h_dformat' <= `l_maxdate'
	if `r(N)' != `h_range'{	
		di as error "`interp' has missing values in the selected sample."
		exit 416
 	}
	
*** Reload original dataset ***
	
	restore
	preserve

	* iv = indicator corrected for negative values;
	* vlist = Differenced `varlist'; used with stock option; 
	* stock1 = Differenced `interp'; used with stock option; 
	tempvar iv vlist stock1
	
	* skip - equal to 0 with flow data, and equal to `mult' with stock data. used in mata routine. 
	tempname skip
	

	marksample touse, novarlist
	_ts timevar panelval `if' `in', sort onepanel 
	markout `touse' `timevar'
	
* keep only `touse' values.	
	qui keep if `touse'
	
	scalar `skip' = 0
	
* vlist is the same as varlist if we have flow data; to be passed to mata.
	qui gen `vlist' =`varlist'

* If stock : Change low freq data from stock to flow; update vlist with differenced data.	
	if "`stock'" == "stock"{
		qui replace `vlist' = D.`varlist'
		scalar `skip' = `mult'		
	}

* Generate new merge variable (same as the timevar in high freq data set);
*  e.g. Y->Q: h_timevar will now be: 2001q4, 2002q4, etc.
	qui gen float `h_timevar' = `l_date' + (_n-1)*`mult'
	format `h_format' `h_timevar'

	
* Merge the two datasets 
 
	 capture merge 1:m `h_timevar' using `from', keepusing(`h_timevar' `interp') 	

* Verify merge was successful
	if _rc {
		di in r "Error while merging datasets."
		exit _rc
	}
	
	qui tsset `h_timevar', `h_unit'	

* If stock : Change high freq data from stock to flow;	
	if "`stock'" == "stock" {
       qui gen `stock1' = D.`interp'
       qui replace `interp' = `stock1'
   }
	
	qui keep if `h_timevar' >= `h_ofd'(`l_mindate') & `h_timevar' <= `h_ofd'(`l_maxdate')
	qui keep `varlist' `interp' `h_timevar' `touse' `l_timevar' `vlist'
	
* Deal with negative values in interp: generate iv.

	qui sum `interp', meanonly
	local iadj 0 
	if `r(min)' <=0 {
		local iadj = abs(`r(min)') + 1
		}
	qui gen double `iv' = `interp' + `iadj' 

* Generate the new variable	
	qui gen double `generate' = .

* Send to interplor: 
* vlist: flow or differenced values of `varlist'
* iv: non-negative `interp'
* generate: new variable
* mult: equal to 4, 12, or 3 depening on data
* skip: equal to 0 with flow data, or equal to 4, 12, 3 with stock data. 

* pass as numeric scalars
	mata : interplor("`vlist'","`iv'", "`generate'", `=`mult'', `=`skip'') 
	

* mata returns the interpolated series in generate
	keep `varlist' `h_timevar' `generate'
	
* If stock: convert the series back to stock; 
	if "`stock'" == "stock" {
		qui replace `generate' = `orimin' if _n==`mult'
		qui replace `generate' = sum(`generate') if !mi(`generate')
	}
	
	qui save`old' `using'

* Message display
	di as result "`generate' is interpolated from the `l_unit' series `varlist' using the `h_unit' series `interp'"
	if "`stock'" == "stock"{
		di as result "`generate' is saved in `using' for the period: " year(`l_mindate') "`h_curfreq'" `num' " to " year(`l_maxdate') "`h_curfreq'" `h_extract'(`l_maxdate')  
	}
	else{
 		di as result "`generate' is saved in `using' for the period: " year(`l_mindate') "`h_curfreq'" `h_extract'(`l_mindate') " to " year(`l_maxdate') "`h_curfreq'" `h_extract'(`l_maxdate')  
	}
	restore	
end

version 11.1
mata:
//interplor does the interpolation; The new variable is st_view (RX,., newvar).
void interplor(
		string scalar lfdata, 
		string scalar indic, 
		string scalar newvar, 
		numeric scalar mult,
		numeric scalar skip)
		
{	

	real matrix I, A, X, RX
	numeric scalar dim, rn
	
	st_view(Y1,.,lfdata)
	st_view(Y2,., indic)
	st_view(RX,., newvar)
		
	rn = st_nobs() - skip
	dim = (mult+1)*(rn/mult)
	
	
//Set up matrices
	X = J(dim ,1,0)
	A = J(dim,1,0)
	I = J(dim, dim,0)
//Constraint borders
	 
	fnp1 = rn +1
	j = 0
	for (i= fnp1; i<=dim; i++){
		for (k=1; k<=mult; k++){
			I[ i, k+j ] = 1
			I[ k+j, i ] = 1
		}
		j = j + mult
		A [ i, 1 ] = Y1[j + skip, 1]
	}
	
//First and last rows
	I[1,1] = 1/(Y2[1+skip,1])^2
	I[1,2] = -1/(Y2[1+skip,1]*Y2[2+skip,1])
	I[rn,rn] = 1/(Y2[rn+skip,1])^2
	I[rn,rn-1] = -1/(Y2[rn-1+skip,1]*Y2[rn+skip,1])
	
//Intermediate rows
	for (i=2; i<=(rn-1); i++){
	I[i, i -1] = -1/ (Y2[i-1+skip, 1]*Y2[i+skip, 1])
	I[i, i] = 2/Y2[i+skip, 1]^2
	I[i, i+1] = -1/ (Y2[i+skip, 1]*Y2[i+1+skip,1])
	}	

//Solving	
	X = lusolve(I, A)
	if (skip == 0){
		RX[.,.] = X[1..rn, 1]
	}
	else {
		RX[.,.] = (J(skip,1,.)\X[1..rn, 1])
	}

}

end

exit

