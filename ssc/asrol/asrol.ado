*! Attaullah Shah 4.6 May 22, 2019
*! Email: attaullah.shah@imsciences.edu.pk
*! Version 4.6 Improves the calculation of gmean for large numbers
*! Version 4.5 Gmean improvement
*! Version 4.4 10May2018: product fuction improvement
*! Support website: www.OpenDoors.Pk
*! This version supports multiple variables and multiple statistics
cap prog drop asrol
prog asrol, byable(onecall) sortpreserve
	version 11
	syntax                    	    ///
	    varlist(numeric)    	   ///
		[in] [if],          	  ///
		Stat(str) 		   		 ///
		[Generate(str)    	    ///
		Window(string)   	   ///
		Perc(str)			  ///
		MINimum(real 0) 	 ///
		by(varlist)    	    ///
		XFocal(string) 	   ///
		ADD (real 0)      ///
		IGnorezero       ///
		] 
	preserve
	marksample touse, nov
	local Z : word count `stat'
	local V : word count `varlist'
	loc mult = `Z' * `V'
	if "`generate'"! = "" & `mult'> 1 {
		display as error "Option {opt g:en} is not allowed with multiple variables or statistics"
		exit
	}

	foreach  z of local stat {
		if "`z'"~="mean" & "`z'"~ = "gmean" & "`z'"~="sd"        ///
			& "`z'"~="sum" & "`z'"~="product" & "`z'"~="median"  ///
			& "`z'"~="count" & "`z'"~="min" & "`z'"~="max"       ///
			& "`z'"~="first" & "`z'"~="last" & "`z'"~="missing" { 
			display as error " Incorrect statistics specified!"
			display as text "You have entered {cmd: `z'} in the {cmd: stat option}. However, only the following staticts are allowed with {help asrol}"
			dis as res "mean, gmean, sd, sum, product, median, count, min, max, first, last, missing"
			exit
		}
		if "`z'"!="median" & "`perc'"!="" dis as error "option {cmd: perc()} is used only when finding {cmd: percentiles with option median}, see help file {help asrol}"
		if "`z'"=="median" {
			if "`perc'"==""{
				global Q = .5
			}
			else {
				confirm number `perc'
				global Q = `perc'
			}
		}
	}
	if "`xfocal'"=="" {
		local XF = 1
	}
	else{ 
		cap confirm numeric variable `xfocal'
		if _rc==0 {
			local varfocal "yes"
		}
		if "`xfocal'"~="focal" & "`varfocal'"!="yes"{
			display as error " Option xfocal either accepts the word focal or name of an existing numeric variable"
			display as text "For example, you can specify xfocal option as {cmd: xfocal(focal)} or {cmd: xfocal(year)}"
			exit
		}
		if "`xfocal'"=="focal" { 
			local XF = 2
		}
		else{ 
			local XF = 3
		}
	}
	global addtofunc = `add'
	global ignorezero `ignorezero'
	if "`XF'" != "1" global XF 1
	else global XF 0

	if "`window'"!=""{
		local nwindow : word count `window'
		if `nwindow'!=2 {
			dis ""
			display as error "Option window must have two arguments: rangevar and length of the rolling window"
			display as text " e.g, If your range variable is year, then the syntax would be {opt window(year 10)}"
			exit
		}
		else if `nwindow'==2 {
			tokenize `window'
			gettoken    rangevar window : window
			gettoken  rollwindow window : window
		}
		confirm number `rollwindow'
		confirm numeric variable `rangevar'
		if `rollwindow' <=1 {
			dis ""
			display as error "Length of the rolling window should be at least 1"
			display as res " Alternatively, If you are interested in statistics over a grouping variable, you should omit the {opt w:indow} otpion"
			exit
		}
		if "`_byvars'"!="" {
			local by "`_byvars'"
		}
		if "`by'"=="" {
			tempvar by
			qui gen `by' = 1
		}
		local cversion =`c(version)'
		tempvar __GByVars __000first __0dIf
		qui bysort `by' (`rangevar'): gen  `__000first' = _n == 1
		qui gen `__GByVars'=sum(`__000first')
		qui drop `__000first' 
		qui by `by' : gen `__0dIf' = `rangevar' - `rangevar'[_n-1]

		if  `mult'<=1 {
			if "`stat'"=="median" {
				if "`perc'"==""{
					global Q = .5
				}
				else {
					confirm number `perc'
					global Q = `perc'
				}
			}

			if "`generate'" == "" local generate "`stat'`rollwindow'_`varlist'"
			mata: asrolw(				      ///
				"`varlist'", 		         ///
				"`__GByVars'" ,	    		///
				"`generate'" , 	  		   ///
				`rollwindow',			  /// 
				"`stat'", 	    		 ///
				"`minimum'", 	   		///
				"`rangevar'",	  	   /// 
				`XF' ,    			  ///
				"`__0dIf'" ,		 ///
				`cversion',	        ///
				"`touse'" 		      )
			cap qui label var `generate' "`stat' of `varlist' in a `rollwindow'-periods rol. wind."
		}
		else {
			foreach v of varlist `varlist'  {
				foreach z  of  local    stat    {
					local generate "`z'`rollwindow'_`v'"
					mata: asrolw(				      ///
						"`v'", 		                 ///
						"`__GByVars'" ,	    		///
						"`generate'" , 	  		   ///
						`rollwindow',			  /// 
						"`z'", 	    		     ///
						"`minimum'", 	   		///
						"`rangevar'",	  	   /// 
						`XF' ,    			  ///
						"`__0dIf'" ,		 ///
						`cversion',	        ///
						"`touse'" 		      )
					cap qui label variable `generate' "`z' of `v' in a `rollwindow'-periods rol. wind."
				}
			}
		}
	}

	else { 
		local rollwindow = 0
		tempvar GByVars dup first n  dif
		if "`_byvars'"!="" {
			local by "`_byvars'"
		}
		if "`by'"!="" {
			if `XF'==3 { 
				local rangevar "`xfocal'"
			}

			gen `n'=_n
			bysort `by' (`rangevar' `n'): gen  `first' = _n == 1
			qui gen `GByVars'=sum(`first')
			drop `first' `n'
		}
		if "`by'"=="" {
			tempvar GByVars
			qui gen `GByVars' = 1
			if `XF'==3{
				local rangevar "`xfocal'"
				sort `GByVars' `rangevar'
			}
		}

		if  `mult' <= 1 {
			if   "`generate'" == ""  local    generate   "`stat'_`varlist'"
			mata: asrolnw(		 		     ///
				"`varlist'", 	   	 	    ///
				"`GByVars'" ,	           ///
				"`generate'" ,       	  ///
				"`stat'", 	    		 ///
				`minimum',        		///
				"`rangevar'", 		   /// 
				`XF' ,   	 	      ///
				"`touse'"   	     ///
				                       )
capture    quietly       label    variable  `generate' "`stat' of `varlist'"
		
		}
	    else{
			foreach v of varlist `varlist' {
				foreach z of local stat       {
					local generate "`z'_`v'"
					mata: asrolnw(		 		   ///
						"`v'", 	  	    	 	  ///
						"`GByVars'" ,	         ///
						"`generate'" ,          ///
						"`z'", 	       		   ///
						`minimum',            ///
						"`rangevar'", 	     /// 
						`XF' ,   	 		///
						"`touse'"          ///
						                     )
capture  quietly  label  variable  `generate'   "`z' of `v'"
				}
			}
		}
	}
	restore, not
end
