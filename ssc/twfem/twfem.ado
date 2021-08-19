*!version 1, Paulo Somaini 12sept2020
capture program drop twfem

findfile twload.ado
findfile twest.ado

include "`r(fn)'"

program define twfem, eclass sortpreserve
version 11
syntax anything [if] [in] , [, using(string) ABSorb(varlist min=2 max=3) GENerate(namelist) NOPROJ] [, NEWVars(name) REPLACE] [, VCE(namelist)]
local anything `anything'

local anything= subinstr("`anything'","=", " = ",.) 
local anything= subinstr("`anything'","-", " - ",.)
local anything= subinstr("`anything'","(", " ( ",.)
local anything= subinstr("`anything'",")", " ) ",.)
local anything= subinstr("`anything'",",", " , ",.)

local anythingout 
local isvarlist
local projvarlist
*create a varlist to project them-separate the variables from the commands and notation
foreach x of local anything {
	local  isvarlist = 0

	capture {
	    confirm variable `x'
	}
	if !_rc{
			local isvarlist = 1
		}

	if strpos("`x'" ,"*") | strpos("`x'","?") | strpos("`x'",".") {
		local isvarlist = 1 
	} 
	
	if ("`x'"=="-"){
		local isvarlist=1
	}
	
	if ("`x'"==","){
		local isvarlist=1
	}
	
	if "`isvarlist'"=="0" {
	   	local anythingout= "`anythingout' `x'"
	} 
	else {
	    if("`x'"=="-"){
		    local projvarlist= "`projvarlist' `x'"
			local anythingout= "`anythingout' `x'"
			}
		else if("`x'"==","){
			local anythingout= "`anythingout' `x'"
			}
		else{
			local projvarlist= "`projvarlist' `x'"
			local anythingout= "`anythingout' `newvars'`x'"
			}
		}
	}
local projvarlist=stritrim("`projvarlist'")	
local projvarlist= subinstr("`projvarlist'"," - ", "-",.) 	
local projvarlist : list uniq projvarlist

	qui{
	*tempvar to use if and in and delete missings observation of analysis
	tempvar touse_wrap
	mark `touse_wrap' `if' `in'
	markout `touse_wrap' `projvarlist'
	}

	if ("`noproj'"==""){
    capt assert inlist( "`generate'", "")
	if !_rc { 
	capt assert inlist( "`using'", "")
	if !_rc { 
	*make the whole regression without creating new fixed effects
	twset `absorb' if `touse_wrap'
	gettoken twoway_id twoway_t : absorb
	if ("`NEWVars(`name')'"=="`newvars(`name')'" & "`replace'"==""){
		capture confirm variable `newvars'
		if !_rc {
                 di "{err} There is at least one variable with the same prefix chosen, please change the prefix or drop the variable"
				}
        else {
			twres `projvarlist', p(`newvars')
			twest `anythingout', vce(`vce') 
		  }
				
	}
		
		
	else if ("`NEWVars(`name')'"=="" & "`replace'"=="replace" ){
		twres `projvarlist', replace
		twest `anything' , vce(`vce') 
			
	}
	}
	else{
		*make the whole regression without creating new fixed effects
		twset `absorb' if `touse_wrap' using "`using'"
		gettoken twoway_id twoway_t : absorb
		if ("`NEWVars(`name')'"=="`newvars(`name')'" & "`replace'"==""){
			capture confirm variable `newvars'
			if !_rc {
					 di "{err} There is at least one variable with the same prefix chosen, please change the prefix or drop the variable"
					}
			else {
				  	twres `projvarlist' using "`using'", p(`newvars')
					twest `anythingout', vce(`vce') 
				  }
					
		}
		else if ("`NEWVars(`name')'"=="" & "`replace'"=="replace" ){
		     twres `projvarlist' using "`using'", replace
			 twest `anything' , vce(`vce') 
			
	}
		
	}

	}
	else{
	capt assert inlist( "`using/'", "")
	if !_rc {
	*make the whole regression creating new fixed effects
	twset `absorb' if `touse_wrap' , gen(`generate')
	gettoken twoway_new_id twoway_new_t : generate

	 if ("`NEWVars(`name')'"=="`newvars(`name')'" & "`replace'"==""){
		capture confirm variable `newvars'
		if !_rc {
                 di "{err} There is at least one variable with the same prefix chosen, please change the prefix or drop the variable"
				}
        else {
			twres `projvarlist', p(`newvars')
			twest `anythingout', vce(`vce') 
			  }
				
	}
		
		
	else if ("`NEWVars(`name')'"=="" & "`replace'"=="replace" ){
		twres `projvarlist', replace
		twest `anything' , vce(`vce') 		
	}
	}
	else{
		twset `absorb' if `touse_wrap' using "`using'", gen(`generate')
		gettoken twoway_new_id twoway_new_t : generate

		 if ("`NEWVars(`name')'"=="`newvars(`name')'" & "`replace'"==""){
			capture confirm variable `newvars'
			if !_rc {
					 di "{err} There is at least one variable with the same prefix chosen, please change the prefix or drop the variable"
					}
			else {
					twres `projvarlist' using "`using'", p(`newvars')
					twest `anythingout', vce(`vce') 
				}
					
		}
			
			
		else if ("`NEWVars(`name')'"=="" & "`replace'"=="replace" ){
		     twres `projvarlist' using "`using'", replace
			 twest `anything' , vce(`vce') 
			
	}
		
	}
}	
}
else if ("`noproj'"=="noproj"){
	*option just to make the regression without setting the fixed effects or projecting varlist
	twest `anything', vce(`vce') 
}




end

** End of twowayreg.ado
