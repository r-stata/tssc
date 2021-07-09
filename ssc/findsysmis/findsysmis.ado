*! version 1.0.1 28May2015 Malte Kaukal
*************************************************************************************************************
* Title: findsysmis.ado																					    *
* Description: Ado to find system missing values in a list of variables									    *
* Author: Malte Kaukal, GESIS Leibniz Institute for the Social Sciences										*
* Version: 1.0.1																						    *
*************************************************************************************************************


program findsysmis, rclass 
		version 11
		syntax varlist [if] [in] [, STRinclude List QUIetly] 
		
		if `"`if'"'!="" | `"`in'"'!="" {		// Checking for restrictions
			preserve
			qui keep `in' `if'
		}
		
		*Defining locals I
		local number1=0
		local number2=0		
		
		*Counting and saving variables with sysmis
		foreach var of varlist `varlist' {
			capture confirm numeric variable `var'
			if !_rc {
				local number1=`number1'+1
				qui sum `var' 
				if r(N)!=c(N) {										// checks if sysmis exist
					if "`sysmisvar'"=="" {
						local sysmisvar "`var'"
					}
					if "`sysmisvar'"!="" & "`sysmisvar'"!="`var'" {
						local sysmisvar "`sysmisvar' `var'"
					}
				}	
			}
			if _rc!=0 & `"`strinclude'"'!="" {
				local number2=`number2'+1
				tempvar strtest
				qui gen `strtest'=.
				qui replace `strtest'=1 if `var'==""
				qui sum `strtest'
				if r(N)!=0 {										// checks if sysmis exist
					if "`sysmisvar2'"=="" {
						local sysmisvar2 "`var'"
					}
					if "`sysmisvar2'"!="" & "`sysmisvar2'"!="`var'" {
						local sysmisvar2 "`sysmisvar2' `var'"
					}
				}
			}				
		}
				
		*Preparation for output/ defining locals II
		local wordn : word count `sysmisvar'
		local y2=8
		forval z=1/`wordn' {
			local y1=length("`:word `z' of `sysmisvar''")		// Checking length of variables
			if `y1'>`y2' {
				local y2=`y1'
			}
		}
		local wordn_str : word count `sysmisvar2'
		local y2_str=8
		forval z=1/`wordn_str' {
			local y1_str=length("`:word `z' of `sysmisvar2''")		
			if `y1_str'>`y2_str' {
				local y2_str=`y1_str'
			}
		}
		local ncol=floor(c(linesize)/(`y2'+2))						// Locals needed for table output
		local ncol_str=floor(c(linesize)/(`y2_str'+2))
		local ctrl=1
		local ctrl_str=1				
		local hlpcount=0
		local hlpcount_str=0
		local wordn2=ceil(`wordn'/`ncol')
		local wordn2_str=ceil(`wordn_str'/`ncol_str')
		local hlich1=(`y2'+2)*`wordn'
		local hlich1_str=(`y2_str'+2)*`wordn_str'
		local hlich2=(`y2'+2)*`ncol'
		local hlich2_str=(`y2_str'+2)*`ncol_str'
		
		*Output
		if `number1'==0 & `number2'==0 & `"`strinclude'"'=="" {
			display as error "Only string variables in varlist found. Use option strinclude to check for sysmis."
			exit
		}
		
		if (`wordn'+`wordn_str'==`number1'+`number2') & ((`"`strinclude'"'=="" & `number1'>0) | (`"`strinclude'"'!="" & `number1'>0) | (`"`strinclude'"'!="" & `number2'>0)) {
				display as error "All these variables contain system missing values!"
				exit
			}		
			if "`sysmisvar'"=="" & "`sysmisvar2'"==""  {
				display "{text} There are no system missing values in these variables"
				exit
			}
		
		if "`quietly'"=="" {
			if `"`list'"'!="" & `"`strinclude'"'=="" {
				display ""
				display "{text} {bind:Variables with sysmis}" 
				display "{hline 23}"
				forval x=1/`wordn' {
					display "{result}`:word `x' of `sysmisvar''"
				}
				display ""
				display "{text} `wordn' of `number1' numeric variables contain system missing values"
			}
			if `"`list'"'!="" & `"`strinclude'"'!="" {
				display ""
				display "{text} {bind:Variables with sysmis}" 
				display "{hline 23}"
				forval x=1/`wordn' {
					display "{result}`:word `x' of `sysmisvar''"
				}
				display ""
				display "{text} `wordn' of `number1' numeric variables contain system missing values"
				display "{hline 59}"
				forval x=1/`wordn_str' {
					display "{result}`:word `x' of `sysmisvar2''"
				}
				display ""
				display "{text} `wordn_str' of `number2' string variables contain system missing values"				
			}			
			if  `"`list'"'=="" {			
				display ""
				if `"`strinclude'"'=="" {
					display "{text} Variables with sysmis (`wordn' of `number1' {ul:numeric} variables)"
				}
				else {
					display "{text} {bind:Variables with sysmis}"
					if `hlich1_str'>23 & `wordn_str'<`ncol_str' & `wordn'<`wordn_str'{
						display "{hline `hlich1_str'}"
						local control=1
					}
					if `hlich2_str'>23 & `wordn_str'>`ncol_str' & `wordn'<`wordn_str' {
						display "{hline `hlich2_str'}"
						local control=2
					}
						if `hlich1'>23 & `wordn'<`ncol' & `wordn'>`wordn_str'{
						display "{hline `hlich1'}"
						local control=3
					}
					if `hlich2'>23 & `wordn'>`ncol' & `wordn'>`wordn_str' {
						display "{hline `hlich2'}"
						local control=4
					}
					if c(linesize)<24 {
						display "{hline `c(linesize)'}"
						local control=5
					}
					if "`control'"=="" {
						display "{hline 22}"
					}
					display "{ul:Numeric variables (`wordn' of `number1'):}"
				}				
				if `wordn'<`ncol' & `hlich1'>54 & `"`strinclude'"'=="" {
					display "{hline `hlich1'}"
				} 
				if `wordn'>`ncol' & `hlich2'>54 & `"`strinclude'"'=="" { 	
					display "{hline `hlich2'}"
				}
				if  (`hlich1'<54 | `hlich2'<54) & `"`strinclude'"'=="" { 
					display "{hline 54}"
				}
				
				while `ctrl'<=`wordn2' & `hlpcount'<=`wordn' {
					local col=1
					local hlpcol=1
					while `col'<=`ncol' & `hlpcount'<=`wordn' {
						local hlpcount=`hlpcount'+1
						display "{result}{col `hlpcol'} {bind: `:word `hlpcount' of `sysmisvar''}" _continue
						local hlpcol=`hlpcol'+`y2'+2
						local col=`col'+1
					}
					display _newline _continue
					local ctrl=`ctrl'+1	
				}
				if `"`strinclude'"'!="" {
					display _newline
					display "{text}{ul:String variables (`wordn_str' of `number2'):}"
					while `ctrl_str'<=`wordn2_str' & `hlpcount_str'<=`wordn_str' {
						local col_str=1
						local hlpcol_str=1
						while `col_str'<=`ncol_str' & `hlpcount_str'<=`wordn_str' {
							local hlpcount_str=`hlpcount_str'+1
							display "{result}{col `hlpcol_str'} {bind: `:word `hlpcount_str' of `sysmisvar2''}" _continue
							local hlpcol_str=`hlpcol_str'+`y2_str'+2
							local col_str=`col_str'+1
						}
						display _newline _continue
						local ctrl_str=`ctrl_str'+1	
					}
				}
				
			}
		}
		
		*Surpressed Output
		if `"`quietly'"'!="" & `"`strinclude'"'==""  {
			display ""
			display "{text} {bind:Variables with sysmis}" 
			display "{hline 23}"
			display "{text} Numeric variables: {result}`wordn' of `number1'"
		}
		if `"`quietly'"'!="" & `"`strinclude'"'!=""  {
			display ""
			display "{text} {bind:Variables with sysmis}" 
			display "{hline 23}"
			display "{text} Numeric variables: {result}`wordn' of `number1'"
			display "{text} String variables: {result}`wordn_str' of `number2'"
		}
		
		*Storing results
		return local numvar "`sysmisvar'"
		return local strvar "`sysmisvar2'"
		return local var "`sysmisvar' `sysmisvar2'"
		
		*Clean up
		if `"`if'"'!="" | `"`in'"'!="" {
			restore
		}
		
end
