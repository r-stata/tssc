*! Author Attaullah Shah :  attaullah.shah@imsciences.edu.pk
*! Dec 28, 2017
*! Version 2.0
*! Adding option of log returns

cap prog drop ascol
prog define ascol
version 10
syntax varlist, 	[		///
	   Returns(string)		///
	   Prices 				///
	   TOWeek 				///
	   TOMonth				///
	   TOQuarter			///
	   TOYear 				///
	   Timevar(varname) 	///
	   Panelvar(varname)	///
	   KEEP(string)			///
	   GENerate(string)		///
	   ]
	cap qui findfile asrol.ado
	if _rc {
		display as txt "asrol package not found!"
		display as txt "Now installaing it from SSC ..."
		display as txt "Please wait, it will take a minute or less ..."
		cap noi ssc install asrol, replace
		if _rc {
			display as error "Installation of asrol failed!"
			display as txt "Please check your internet connection"
			exit
		}
	else display "Now working on your ascol command"
	}
	if "`returns'"~=""{
		if "`returns'"~="simple" & "`returns'"~="log" {
			dis as error "Error in the option return!"
			display as txt "With option {opt r:eturn()}, either simple or log are allowed!"
			dis as txt "For example {opt r:eturns(simple)}, or {opt r:eturns(log)}, "
			exit
		}
	}
	cap qui tsset
	if _rc {
		if "`timevar'"=="" {
			display as error "Data is not declared as panel or time series!"
			dis as txt "If your data is not time series or panel, you can use the"
			dis as smcl "option {opt t:imevar(varname)} and {opt p:anelvar(varname)} to tell the program about"
			dis as smcl "the time variable and panel variable in your data set."
			dis as smcl "See {help ascol##tsset:this entry} in the help file for more details."
			exit
		}
		
	}
	else {
		loc panelvar `r(panelvar)'
		loc timevar `r(timevar)'
	}
	if "`keep'"!= "" {
		if "`keep'"!= "vars" & "`keep'"!= "all" {
			display as error "option keep incorrectly specified!"
			dis as txt "only {opt keep(variables)} or {opt keep(all)} are allowed"
			exit
		}
	}
	if "`returns'"=="" & "`prices'"==""{
		dis as error "Either prices or returns option has to be specified"
		dis as txt " For example {opt ascol ri, returns tomonth}"
		exit
	}
	if "`returns'"!="" & "`prices'"~=""{
		dis as error "You have specified both prices and returns option"
		dis as txt " Only one option is allowed at a time"
		exit
	}
	
	if "`toweek'" =="" & "`tomonth'" =="" & "`toquarter'" =="" & "`toyear'" ==""{
		dis as error " toweek, tomonth, toquarter, or toyear option not specified"
		dis as txt "One of these options have to be specified"
		dis as txt " For example, ascol ri, toweek returns"
		exit
	}
	if "`toweek'"!="" & "`tomonth'"!="" {
		dis as error "Weekly and monthly frequency cannot be specified at the same time"
		exit
	}
	
		if "`toweek'"!="" & "`toquarter'"!="" {
		dis as error "Weekly and quarterly frequency cannot be specified at the same time"
		exit
	}
	if "`toweek'"!="" & "`toyear'"!="" {
		dis as error "Weekly and year frequency cannot be specified at the same time"
		exit
	}
	if "`toquarter'"!="" & "`tomonth'"!="" {
		dis as error "Quarterly and monthly frequency cannot be specified at the same time"
		exit
	}
	if "`toyear'"!="" & "`tomonth'"!="" {
		dis as error "Yearly and monthly frequency cannot be specified at the same time"
		exit
	}

		if "`toyear'"!="" & "`toquarter'"!="" {
		dis as error "Weekly and monthly frequency cannot be specified at the same time"
		exit
	}

	if "`toweek'"!		= "" {
		loc pid		 	= "week"
		loc pf 			= "wofd"
		loc fmt			= "%tw"
	}
	else if "`tomonth'"!= "" {
		loc pid		 	= "month"
		loc pf 			= "mofd"
		loc fmt			= "%tm"
	}
	else if "`toquarter'"!="" {
		loc pid		 	= "quarter"
		loc pf 			= "qofd"
		loc fmt			= "%tq"
	}
	else if "`toyear'"!	= "" {
		loc pid		 	= "year"
		loc pf 			= "year"
		loc fmt			= "%ty"
	}
		
	cap confirm variable `pid'_id
	if _rc!=0 loc period_id `pid'_id
	else loc period_id `pid'_id_000
	qui gen `period_id' = `pf'(`timevar')
	format `fmt' `period_id'
	if "`generate'" == "" loc generate `pid'_`varlist'
	
	if "`returns'"!= "" {
	if "`returns'" == "log" bys `panelvar' `period_id' : asrol `varlist', gen(`generate') stat(sum)
	else 			        bys `panelvar' `period_id' : asrol `varlist', gen(`generate') stat(product) add(1)
	
	}
	if "`prices'"!="" {
		                    bys `panelvar' `period_id' : asrol `varlist', gen(`generate') stat(last)
	}
	if "`keep'"~ = "" {
		if "`keep'" == "vars" 	qui bys `panelvar' `period_id' : keep if _n == _N
	}
	else { 
		qui keep `panelvar' `period_id' `generate'
		qui bys `panelvar' `period_id' : keep if _n == _N
	}
	end
