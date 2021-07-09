*! version 1            <03oct2013>         Oscar Barriga Cabanillas
*! version 2            <05Nov2013>         Oscar Barriga Cabanillas
	*Changes in the name and in correction on the if option
*! version 3            <05MAY2014>         Oscar Barriga Cabanillas
	*Changes name and adds option OVER
*! version 3.1            <20MAY2014>         Oscar Barriga Cabanillas
	*Verifies variable in period is numerical
*! version 4           <27MAY2014>         Oscar Barriga Cabanillas
	*Changes display options
*! version 5           <21JUL2014>         Oscar Barriga Cabanillas
	*Display option improved
*! version 5.1           <01OCT2014>         Oscar Barriga Cabanillas
	*Disaggregate options updated	
	
program define prosperity, rclass

tempname R7325
tempname X700
tempname GB

version 10.0


	syntax varlist(numeric)					///
		[aweight fweight pweight]			///
		[if]  [,				        ///             	
		PERiod(string)						///
		OVER(string)						///
		BOTTom(string)						///
		DISaggregate(string)				///
		varpl(string)						///
		line(string)						///
		INDEPENDENTLY						///
		EXPort(string)						///
		FILename(string)					///
		FORmat(string)						///
		SHOWWHO								///
		]
		
// Verifies necessary commands are installed

cap which apoverty
loc error_c = _rc 

if `error_c' != 0 {

	qui: cap ssc install apoverty
	loc error_i = _rc
	
	if `error_i' == 0 {
	
		noi di in y "apoverty command added to the library"
	}
	else {
		noi di in y "apoverty command is needed but could not be automatically installed"
	}
	
}

cap which quantiles
loc error_c = _rc 

if `error_c' != 0 {

	qui: cap ssc install quantiles
	loc error_i = _rc
	
	if `error_i' == 0 {
	
		noi di in y "quantiles command added to the library"
	}
	else {
		noi di in y "quantiles command is needed but could not be automatically installed"
	}
	
}


tempvar sirve										// Defines observations to be used

if "`over'" != "" {
	loc over1 : word 1  of `over'
	loc over2 : word 2  of `over'
	
	if "`if'" == "" loc cond_i = "if"
	if "`if'" != "" loc cond_i = "&"	
	mark `sirve' `if' `cond_i' (`period' == `over1' | `period' == `over2')  // Defines observations to be used taking into account option over
	
}
else {
	mark `sirve' `if' 														// Defines observations to be used if option over IS NOT used
}
qui: tempvar count

qui: gen `count' = 1 if `sirve' 

loc income = "`varlist'"													// local with the information on the income variable
loc weight "`weight'`exp'"													// local with the information on the weights 
loc var `1'
local wvar : word 2 of `exp'


if "`bottom'" != "" & ("`varpl'" != "" | "`line'" != "") {
	noi di in red "Options bottom and poverty measures cannot be used simultaneously " 
	error
}
*

if "`varpl'" != "" & "`line'" != "" {

	noi di in red "poverty measures cannot be used simultaneously "
	error
}
*

if "`independently'" == "independently" & "`disaggregate'" == ""{
	
	noi di in red "independently option is meant to be used with disaggregate options"
	error
}
*

loc type_0 : type `period'											// the variable used in period must be numerical
loc type_1 = substr("`type_0'",1,3)
if  "`type_1'" == "str" {
	noi di in red "variable used in period must be numerical" 
	error
}
qui : su `period' if `count' == 1 & `sirve'  				// Defines the locals for the two periods of the calculation
loc y0 = r(min)
loc y1 = r(max)



if "`bottom'" == "" & ("`varpl'" == "" | "`line'" == "")  {
	loc bottom = 40 										// Default option is calculate the growth of the bottom 40
}
*

// Defines poverty rates when poverty options are used
if "`varpl'" != "" {

	qui: apoverty `income' [`weight'] if `period' == `y0' & `sirve'   , varpl(`varpl') 
	loc bottom = round(`r(head_1)',0.2)
}
*
if "`line'" != "" {

	qui: apoverty `income' [`weight'] if `period' == `y0' & `sirve'  , line(`line') 
	loc bottom = round(`r(head_1)',0.2)
}
*


if "`disaggregate'" != "" {
	qui: levelsof `disaggregate', loc(area)
	loc count_disag = wordcount("`area'")
}
else {
	loc area = "tot"
}
*


if "`period'" == "" {
	noi di in red "the years or the calculations have to be defined"
	error
} 
*

qui: ta `period' if `count' == 1 & `sirve'  

if r(r) > 2 {
	if wordcount("`over'") != . {
	noi di in red "only two different years accepted, option over() should be used"
	error
	}
	if wordcount("`over'") != 2 {
	noi di in red "only two different years can be used in over() option"
	error
	}
} 
if r(r) < 2 {
	noi di in red "only one year defined"
	error
} 
*

* Generate temporary file to save results

if "`export'" == "" & ("`filename'" != "" | "`format'" != "" ) { 

	noi di in red "When using filename or format options export must be used "
	error
}
*
if "`export'" != "" {

	qui: tempname p
	qui: tempfile fileaux
	
	if "`disaggregate'" != "" {
			
			postfile `p' str10(Year1 Year2 Mean_initial_Total Mean_initial_Bottom Mean_final_Total Mean_final_Bottom total_growth Bottom_growth disaggregation Bottom) using `fileaux', replace 
		}
		else {
			postfile `p' str10(Year1 Year2 Mean_initial_Total Mean_initial_Bottom Mean_final_Total Mean_final_Bottom total_growth Bottom_growth Bottom) using `fileaux', replace 
		}
	}
*



* For the overall sample
	
	loc list_var = "_pctile0 _pctile1 "
	foreach var of loc list_var {
		cap confirm variable `var'
		loc error = _rc
		
		if `error' == 0 {
			noi di in red "variable `var' already in the dataset"
			noi di in red "prosperity needs variable `var' to be renamed"
			error
		}
	}
	
	
	qui : quantiles `income' [`weight'] if `period' == `y0' & `sirve'   ,  nq(100) gen(_pctile0)
	qui : quantiles `income' [`weight'] if `period' == `y1' & `sirve' ,  nq(100) gen(_pctile1)
	
	qui :su `income' [`weight'] if `period' == `y0' & `sirve' 
	loc b0 =r(mean)

	qui :su `income' [`weight'] if `period' == `y0' & inrange(_pctile0,0,`bottom') & `sirve' 
	loc a0 =r(mean)			

	qui :su `income' [`weight'] if `period' == `y1' & `sirve' 
	loc b1 =r(mean)

	qui :su `income' [`weight'] if `period'== `y1' & inrange(_pctile1,0,`bottom') & `sirve' 
	loc a1 =r(mean)
	
	loc growth_tot = ((`b1'/`b0')^(1/(`y1'-`y0'))-1)*100
	loc growth_bottom = ((`a1'/`a0')^(1/(`y1'-`y0'))-1)*100
	
	if ("`disaggregate'" == "" ) {
		mat `R7325' = nullmat(`R7325'), `y0' , `y1' , `b0', `a0', `b1' , `a1' , `growth_tot' , `growth_bottom' , `bottom'

	}
	else {
		mat `R7325' = nullmat(`R7325'), `y0' , `y1' , `b0', `a0', `b1' , `a1' , `growth_tot' , `growth_bottom' , 999999, `bottom'
		
	}
	*
	
if "`export'" != "" {

	if "`disaggregate'" == "" {
	
			post `p' ("`y0'") ("`y1'") ("`b0'") ("`a0'") ("`b1'") ("`a1'") ("`growth_tot'") ("`growth_bottom'") ("`bottom'") //saving information 			
		}
		else {
			post `p' ("`y0'") ("`y1'") ("`b0'") ("`a0'") ("`b1'") ("`a1'") ("`growth_tot'") ("`growth_bottom'") ("999999") ("`bottom'") //saving information 			
		}
}	

*


* For disaggregate option

	if "`disaggregate'" != "" {
	
		foreach reg of loc area {
		
		loc ifo_r = " & `disaggregate' == `reg'" 
		
			if "`independently'"  != "" {
				
				if "`varpl'" != "" {

					qui: apoverty `income' [`weight'] if `period' == `y0' `ifo_r' & `sirve'   , varpl(`varpl') 
					loc bottom = r(head_1)
				}
				if "`line'" != "" {

					qui: apoverty `income' [`weight'] if `period' == `y0' `ifo_r' & `sirve'  , line(`line') 
					loc bottom = r(head_1)
				}
				
			}
				* test that disaggregate are in every year
			
				qui: su `count' if `disaggregate' == `reg' & `period' == `y0' & `sirve' 
				
				if `r(N)' == 0 {
					noi di in red "`disaggregate' in `reg' not defined in period `y0'"
					error
				}
				
				qui: su `count' if `disaggregate' == `reg' & `period' == `y1' & `sirve' 
				
				if `r(N)' == 0 {
					noi di in red "`disaggregate' in `reg' not defined in period `y1'"
					error
				}
				*
		
		loc list_var _pctile0_`reg' _pctile1_`reg'
		foreach var of loc list_var {
		
		cap confirm variable `var'
		loc error = _rc
		
			if `error' == 0 {
				noi di in red "variable `var' already in the dataset"
				noi di in red "prosperity needs variable `var' to be renamed"
				error
			}
		}
	
	
				
		qui : quantiles `income' [`weight'] if  `period' == `y0' `ifo_r' & `sirve' ,  nq(100) gen(_pctile0_`reg')
		qui : quantiles `income' [`weight'] if `period' == `y1' `ifo_r' & `sirve' ,  nq(100) gen(_pctile1_`reg')
		
		qui :su `income' [`weight'] if  `period' == `y0' `ifo_r' & `sirve' 
		loc b0 =r(mean)

		qui :su `income' [`weight'] if `period' == `y0' & inrange(_pctile0_`reg',0,`bottom') `ifo_r' & `sirve' 
		loc a0 =r(mean)			

		qui :su `income' [`weight'] if  `period' == `y1' `ifo_r' & `sirve' 
		loc b1 =r(mean)

		qui : su `income' [`weight'] if  `period' == `y1' & inrange(_pctile1_`reg',0,`bottom') `ifo_r' & `sirve' 
		loc a1 =r(mean)
		
			loc growth_tot = ((`b1'/`b0')^(1/(`y1'-`y0'))-1)*100
			loc growth_bottom = ((`a1'/`a0')^(1/(`y1'-`y0'))-1)*100
		
			
			mat `R7325' = nullmat(`R7325') \ (`y0' , `y1' , `b0', `a0', `b1' , `a1' , `growth_tot' , `growth_bottom' , `reg' , `bottom')
				
			if "`export'" != "" {
				post `p' ("`y0'") ("`y1'") ("`b0'") ("`a0'") ("`b1'") ("`a1'") ("`growth_tot'") ("`growth_bottom'") ("`reg'") ("`bottom'") //saving information 
			}
		}
	
	

	}
*	




mat `GB' = `R7325''

* Displays and export results if export option is used

preserve

noi di as txt _new "Shared Prosperity Indicator"
noi di as txt "Annualized growth rate for the bottom `bottom' of the population between `y0'-`y1'"

mat list `GB'
qui {
		
	
	
	drop _all
	svmat double `GB'
	
	tempvar n
	gen `n' =_n
	drop if `n' == 1
	drop if `n' == 2
	drop if `n' == 9
	cap drop if `n' == 10
		
	label define n 3  "Initial mean income" 4 "Final mean income" 5 "Initial mean income" 6 "Final mean income" 7 "Overall" 8 "Bottom `bottom'"
	label values `n' n
	gen groups = .
	replace groups = 1 if inlist(`n',3,5)
	replace groups = 2 if inlist(`n',4,6)
	replace groups = 3 if inrange(`n',7,8)

	label define groups 1 "Overall population:" 2 "Bottom `bottom':" 3 "Annualized growth rate"
	label values groups groups
	
	label var `n' "period"
	label var groups "Results by population"
		
	ren `GB'1 National
	
	if "`disaggregate'" == "" {
		noi tabdisp `n' , cellvar(National) by(groups) concise format(%10.2f)
	}
	else {
		* defines the number of tables to be used, taking into account they can only display up to 5 results at the time
		
		loc list_1 = "National"
		loc list_control = 1
		
		loc ++count_disag
		
		forvalues disg = 2(1)`count_disag' {
			
			loc C_`disg' = `disg'-1
			
			label var `GB'`disg' "Sublevel `C_`disg''"
	
			
			if wordcount("`list_`list_control''") >= 5 {
				loc ++list_control
			}
			
			loc list_`list_control' = "`list_`list_control'' `GB'`disg'"	
			
		}
		
		forvalues d = 1(1)`list_control' {

			noi tabdisp `n' , cellvar( `list_`d'' ) by(groups) concise format(%10.2f)
		
		}
	}
}

	if "`export'" != "" {

		postclose `p'
		qui :  use `fileaux', clear 

		qui: destring, replace

			if "`disaggregate'" != "" {
				qui: label define disaggregation 999999 "National aggregate"
				qui: label values disaggregation disaggregation
			}
			if "`filename'" == "" {
				loc filename = "Shared_prosperity"
			}
			
			if ("`format'" == "xls") | ("`format'" == "excel") | ("`format'" == "Excel") {
				qui : export excel using "`export'/`filename'.xlsx" , first(variable) replace 
			}
			else {
				qui : save "`export'/`filename'.dta", replace
			}
		


	}
	*
restore

if ("`showwho'" == "") {
	drop _pctile*

}

return matrix table = `GB'

return scalar year1 = `y0'
return scalar year2 = `y1'

return local Bottom = `bottom'




end

exit
