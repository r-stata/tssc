*! Reshape a World Development Indicators (WDI) dataset for panel,
*! seemingly unrelated regression, or cross-sectional analysis
*! Author: P. Wilner Jeanty
*! version 1.0 Born: December 2006
*! version 1.1 Updated: November 2007
*! Version 1.2 May 2009: Allows two syntaxes and makes options sercode() and ctycode() required 
*! version 1.3 November 2009: Allows for quotes in the WDI series descriptors
program define wdireshape
	version 9.2
	gettoken usersup:0
	if "`usersup'"=="," _wdireshape1 `0'
	else _wdireshape2 `0'
end
program define _wdireshape1
	version 9.2
	syntax, SERName(varname)
	qui levelsof `sername', local(allsers)
	local numbv : word count `allsers'
	di
	di in y " The current dataset contains `numbv' variables in the following order:"
	di
	forv i=1/`numbv' {
		local lab`i': word `i' of `allsers'
		di " `i') "`"`lab`i''"'"" // Quotes in the series descriptors properly handled
	}
end
program define _wdireshape2
	version 9.2	
	syntax newvarlist, PREPend(string) CTYName(varname) ///
				 SERName(varname) SERCode(varname) ///
				 CTYCode(varname) [BYPer(string) ///
				 STARTyr(string) ENDyr(string) BYVar ///
				 SUR CROS NString(string)]
	tempvar varid
* Check the prepending letter(s)
	local nlet: length local prepend
	local err_let=0
	local err_j=0
	local err_s=0
	local s=0
	local j=0
	forvalue i=97/122 {
		if char(`i')==substr("`prepend'",1,1) local j=`j'+1
		if `nlet'==2 {
			if char(`i')==substr("`prepend'",2,1) local s=`s'+1
		}			
	}
	if `nlet'<1 | `nlet'>2 local err_let=`err_let'+1
	if `j'!=1 local err_j=`err_j'+1
	if `nlet'==2 & `s'!=1 local err_s=`err_s'+1
	if `err_let'==1 | `err_j'==1 | `err_s'==1 {
		di
		di as err "The years must be prepended by one or two letters from a to z" 
		di
		exit 198
	}
	
* Take care of the double dots(..) if present, since they cause numeric variables to be string
	if "`nstring'"!="" {
		local nstring=real("`nstring'")
		unab vars:_all
		local j=1
		foreach var of local vars {
			local vlab: word `j' of `vars' 
			local var`j' `vlab'
			if `j'>`nstring' {		
				qui gen double mvar`j'=real(`var')
				drop `var'
				ren mvar`j' `var`j''
			}
			local ++j
		}
	}
* Begin serious stuff
	local user `prepend'
	local xxs `ctycode' `ctyname' `sercode' `sername'
	
	* Capture the number of variables or series
	qui levelsof `sername', local(wdi_lab)   
	local maxvar: list sizeof wdi_lab
	  	
	* Now check whether the right number of variable names is supplied in varlist	
	if `maxvar'!= `:word count `varlist'' {
		di
 		noi di as err " Incorrect number of variable names"
		di
		exit 198
	}
 	
	* Now put the WDI labels in individual fabulous macros for later use
	forv i=1/`maxvar' { 
  		local lab`i' :word `i' of `wdi_lab'
	} 
	egen `varid'=group(`sername') 
	gl wrap reshape
	local mytxt "Reshaping your dataset"
	if `"`byvar'"'=="" {
		if (`"`byper'"' !="" & (`"`startyr'"'=="" | `"`endyr'"'=="")) | ///
	   		(`"`startyr'"'!="" & (`"`byper'"' =="" |`"`endyr'"'=="")) | ///
	   		(`"`endyr'"'!="" & (`"`byper'"' =="" |`"`startyr'"'=="")) {
			di
			di as err "Options {bf:byper()}, {bf:startyr()}, and {bf:endyr()} must be combined" 
			di
			exit 198
		}
	}	
	if `"`byvar'"'!="" & (`"`byper'"' != "" | `"`startyr'"'!="" | `"`endyr'"' !="") {
		di
		di as err "Option {bf:byvar} may not be combined with either {bf:byper()}, {bf:startyr()}, or {bf:endyr()}"
		di
		exit 198
	} 
	if `"`cros'"'!="" & `"`sur'"'!="" {
		di
		di as err "Option {bf:cros} may not be combined with {bf:sur}"
		exit 198
	}
	if (`"`byvar'"'=="" & `"`byper'"'=="" & `"'startyr'"'=="" & `"`endyr'"' == "") {  // if these not specified then try the default: everything at once
		di
		noi di as txt "`mytxt' (everything at once), please wait"
		di
		capture _resh `varid', prep(`user') sern(`sername') ctyn(`ctyname') serc(`sercode') 

		// Check whether there is sufficient memory to reshape everything at once
		if c(rc) {
             	if 900 <= c(rc) & c(rc) <= 903 {
                        di as err "Insufficient memory to reshape everything at once, use either {bf:byvar}  or {bf:byper()} option."
				di as err "Or, increase the amount of memory allocated to Stata. See {help memory}.
				di
				exit 901
               	}                		
        	} 
	}
	if `"`byvar'"'!="" {
		di
		noi di as txt "`mytxt' one variable at a time, please wait" _c
		di
		qui {
			forv i = 1/`maxvar' {
  				tempfile var`i'
				preserve
 				keep if `varid'==`i'
				if `"`sercode'"'!="" drop `sercode' `sername'
				else drop `sername'
  				$wrap long `user', i(`ctyname') j(year)  
  				rename `user' `user'`i'		
  				so `ctyname' year      
  				save `var`i''
 				restore
			}
			use `var1', clear
			forv i = 2/`maxvar' {
  				merge `ctyname' year using `var`i''   
  				drop _merge
  				so `ctyname' year 
			}
		}
	}
	if (`"`byper'"' !="" & `"`startyr'"'!="" & `"`endyr'"'!="") {	
		local yr1 = real("`startyr'") 
		local yrn = real("`endyr'")
		local nbyr=`yrn'-`yr1'+1
		local ny=real("`byper'")	
		if `ny'!=1 &`ny'!=5 & `ny'!=10 {
			di
			di as err "Option {bf:byper()} takes one of 1, 5, and 10."
			di
			exit 198
		}
		if `ny'==1 {				
			di
			noi di as txt "`mytxt' one year at a time, please wait"	
			di		
			forv j=`yr1'/`yrn' {
				tempfile var`j'
				preserve
				keep `varid' `xxs' `user'`j'
				_resh `varid', prep(`user') sern(`sername') ctyn(`ctyname') serc(`sercode')
				qui save `var`j''
				restore
			}
			use `var`yr1'', clear
			local yr2=`yr1' +1
			forv i=`yr2'/`yrn' {
				append using `var`i''
			}
			so `ctyname' year
		}		
		else {
			if `nbyr'<5 & `ny'==5 { 
				di
				di as err "Cannot reshape five years at a time"
				di
				exit 198
			}
			if `nbyr'<10 & `ny'==10 {
				di
				di as err "Cannot reshape 10 years at a time"
				di
				exit 198
			}
			di
			noi di as txt "`mytxt' `ny' years at a time" _c
			di
			local n=`ny'
			local endp= cond(mod(`nbyr',`n')<=1,`yr1'+(int(`nbyr'/`n')*`n')-`n',`yr1'+`n'*int(`nbyr'/`n'))				
			forv i=`yr1'(`n')`endp' {
				tempfile var`i'
				local j=`n'-1
				if mod(`nbyr',`n')==1 & `i'==`endp' { 
					local j=`n' 
				}
				if mod(`nbyr',`n')>=2 & `i'==`endp' {
				 	local j=mod(`nbyr',`n')-1 
				}						
				local s=`i'+`j'
				di "Now reshaping period ",`i', "-", `s'
				preserve
				keep `varid' `xxs' `user'`i'-`user'`s'
				capture _resh `varid', prep(`user') sern(`sername') ctyn(`ctyname') serc(`sercode')

	* Need to check first whether there is sufficient memory to reshape 5 or 10 years at a time
				if c(rc) {
             			if 900 <= c(rc) & c(rc) <= 903 {
                        		di as err ///
						"Insufficient memory to reshape `n' years at a time, set # to a lower value or use {bf:byvar} option."
						di as err "Or, increase the memory size. See {help memory}.
						di
						exit 901
               			}                		
        			} 				
				qui save `var`i''				
				restore
			}
			use `var`yr1'', clear
			local r=`yr1'+`n'
			forv i=`r'(`n')`endp' {
				append using `var`i''
			}
			so `ctyname' year
		}
	}
	
	* Now rename the variables with the user-supplied variable names
	local i=1 
	foreach v of  local varlist {
		ren `user'`i' `v'		
		local ++i
	}
	if `"`byvar'"' != "" keep `ctyname' `ctycode' year `varlist'	
	la var `ctyname' "Country name"
	if `"`sur'"' == "" {
		local ord "order `ctycode'"
		local labc "la var `ctycode' "Country code""
	}
	if `"`sur'"' == "" & `"`cros'"' == "" {
		`ord'
		`labc'
		egen cid=group(`ctyname')
		la var cid "Country ID"
		local i=1 
		foreach v of  local varlist {			
			qui la var `v' "`lab`i''"
			local ++i
		}
		order cid
		qui xtset cid year
		di
		noi di in y "Your dataset has been reshaped and is ready for panel data analysis"			
	}
	else if `"`sur'"' != "" {
		qui levelsof `ctyname', local(cty_id)   
		egen cy=group(`ctyname')
		gen str c="c"+string(cy)
		drop cy `ctyname' `ctycode'
		qui $wrap wide `varlist', i(year) j(c) string 
		local i=1
		foreach v of  local varlist {
			forv j=1/`:list sizeof cty_id' {
				local myr :word `j' of `cty_id'
  				local c`j' "`myr'"
				qui la var `v'c`j' "`c`j'' - `lab`i''"
			}			
			local ++i
		}
		qui tsset year
		di
		noi di in y "Your dataset has been reshaped and is ready for SUR analysis"
	}
	else if `"`cros'"' !="" {
		tempvar ci
		egen `ci'=group(`ctyname')
		sum year if `ci'==1, meanonly
		local nt=r(n)
		local yr1=r(min)				
		local yrn=r(max)
		qui levelsof year, local(yr_id)   
		qui $wrap wide `varlist', i(`ctyname') j(year)			
		local i=1 
		foreach v of  local varlist {
			if `nt'==`yrn'-`yr1'+1 { // meaning there are no gaps in the time series
				forv j=`yr1'/`yrn' {
					qui la var `v'`j' "`j' - `lab`i''" 
				}
			}
			else { // in case there are gaps
				forv j=1/`:list sizeof yr_id' {
  					local yr_`j' "`:word `j' of `yr_id''"
					qui la var `v'`yr_`j'' "`yr_`j'' - `lab`i''"
				}
			}
			local ++i
		}
		`ord'
		`labc'
		di
		noi di in y "Your dataset has been reshaped and is ready for cross sectional or change analysis"
	}
end
program define _resh
	version 9.2
	syntax varlist(max=1), prep(string) sern(varname) ctyn(varname) serc(varname)
	qui {
		$wrap long `prep', i(`ctyn' `varlist') j(year)
		drop  `serc' `sern'
	 	$wrap wide `prep', i(`ctyn' year) j(`varlist')
	}
end
