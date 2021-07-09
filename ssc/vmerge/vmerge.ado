/*
Verbose merge (vmerge): a wrapper for the Stata merge command that provides additional 
details regarding the results of the update and replace options
Author: 
    Joseph Canner
    Johns Hopkins University School of Medicine
    Department of Surgery
    Center for Surgical Trials and Outcomes Research
	jcanner1@jhmi.edu
Date: October 22, 2013
*/

program vmerge
version 12.1

// Get the merge type (1:1, m:1, 1:m, m:m)
gettoken mtype 0 : 0, parse(" ,")

// See if it is a 1:1 merge by observation
gettoken token : 0, parse(" ,")
if ("`token'"=="_n") {
	gettoken token 0 : 0, parse(" ,")
	local mtype="`mtype' _n"
}

syntax [varlist(default=none)] using/ [,	///
		  ASSERT(passthru)			///
		  DEBUG					///
		  GENerate(name)			///
		  FORCE					///
		  KEEP(passthru)				///
		  KEEPUSing(passthru)			///
		noLabel					///
		  NOGENerate			        ///
		noNOTEs					///
		  REPLACE				///
		noREPort				///	
		  SORTED				///
		  UPDATE       				///
		  VERBOSE  ///
		  CONSERVEmemory ///
		]

if ("`generate'"!="") {
  local generateoption="generate(`generate')"
}
else {
  local generate="_merge"
}

// Save list of original master variables for later use
unab masterlist: *
		
// conservememory option uses -cf- instead
if ("`conservememory'"!="") {
  preserve
  // Perform the merge without update/replace
  merge `mtype' `varlist' using `using', `assert' `debug' `generateoption' `force' `keep' `keepusing' `nogenerate' `sorted' noreport nolabel nonotes
  tempfile merge
  qui save `merge'
  // Perform the merge as intended
  restore
  merge `mtype' `varlist' using `using', `assert' `debug' `generateoption' `force' `keep' `keepusing' `nolabel' `nogenerate' `nonotes' `replace' `noreport' `sorted' `update'
  preserve     
  tempfile merge_ur
  qui save `merge_ur'
  use `merge', clear
  capture noisily cf `masterlist' using `merge_ur', `verbose' all
  restore
}
else {

foreach var of varlist * {
  tempvar `var'
  qui gen ``var''=`var'
  char ``var''[varname] "Original(`var')"
}

merge `mtype' `varlist' using `using', `assert' `debug' `generateoption' `force' `keep' `keepusing' `nolabel' `nogenerate' `nonotes' `replace' `noreport' `sorted' `update'

di _newline "Summary of results for records in master (`generate'==1, 3, 4, or 5):"
di "Variable" _col(35) "Updated" _col(45) "Replaced" _col(55) "Unchanged" _col(65) "Total"
foreach var of varlist `masterlist' {
     qui count if ``var''!=`var' & mi(``var'') & inlist(`generate',1,3,4,5)
	 local updated=r(N)
	 qui count if ``var''!=`var' & !mi(``var'') & inlist(`generate',1,3,4,5)
	 local replaced=r(N)
	 qui count if ``var''==`var' & inlist(`generate',1,3,4,5)
	 local unchanged=r(N)
	 local total=`updated'+`replaced'+`unchanged'
	 di "`var'" _col(35) as res %10.0fc "`updated'" _col(45) as res %10.0fc "`replaced'" _col(55) as res %10.0fc "`unchanged'" _col(65) as res %10.0fc "`total'"
}

if ("`verbose'"!="") {
  di _newline
  foreach var of varlist `masterlist' {
     qui count if ``var''!=`var' & inlist(`generate',1,3,4,5)
	 local changed=r(N)
	 if (`changed'>0) {
    	 di "Variable -`var'- details:"
		 qui count if ``var''!=`var' & mi(``var'') & `generate'==4
	     local updated=r(N)
		 if (`updated'>0) {
    	     di "Updated:"
	         list `varlist' ``var'' `var' if ``var''!=`var' & mi(``var'') & `generate'==4, subvarname abbreviate(18)
		 }
		 else {
		     di "Updated: none"
		 }
		 qui count if ``var''!=`var' & !mi(``var'')
	     local replaced=r(N)
		 if (`replaced'>0) {
	         di "Replaced:" 
  	         list `varlist' ``var'' `var' if ``var''!=`var' & !mi(``var''), subvarname abbreviate(20)
		 }
		 else {
		     di "Replaced: none"
		 }
	  }
	  else {
	     di "Variable -`var'-: No changes made"
	  }
  }
}
}	 
end
