*! grouplabs v1.0 31may2014
*! by Sergiy Radyakin
*! bcf4d570-5cd1-4720-8887-50f9e85d41a9

program define grouplabs

    version 9.0
	
    capture syntax varlist, Groupvar(varname) ///
	       [VALues LName(string) EMPTYLabel(string) SEParator(string)]
    
	if _rc {

	  syntax varlist, Groupvar(string) ///
	       [VALues LName(string) EMPTYLabel(string) SEParator(string)]
	  
	  confirm new variable `groupvar', exact
	  
	  egen `groupvar'=group(`varlist')
	}
	
	if missing(`"`lname'"') local lname "`groupvar'"
	if missing(`"`emptylabel'"') local emptylabel "---"
	if missing(`"`separator'"') local separator " "

	summarize `groupvar', meanonly
	local maxx=r(max)

	forval i=1/`maxx' {
	  
	  local l ""
	  foreach v in `varlist' {
	  
		local vl `"`:var label `v''"'
		if missing(`"`vl'"') local vl `"`v'"'
		
		capture confirm numeric variable `v'
		if _rc {
			tempvar indxvar
			generate long `indxvar'=_n
			summarize `indxvar' if `groupvar'==`i', meanonly
			local pi=r(min)
			local vvl `"`=`v'[`pi']'"'		  
			drop `indxvar'
			local ln `"`vvl'"'		  
		}
		else {
			summarize `v' if (`groupvar'==`i'), meanonly
			
			local vv=r(mean)
			if !missing(r(max)) {
				if (abs(r(max)-r(min))>0.0000001) {
				  display as error "Inconsistent input " r(max) " " r(min)
				  error 999
				}
			}
			
			local ql ""
			
			if !missing("`values'") {
			    if (!missing(`vv')) {
					local vvl `"`: value label `v''"'
					if !missing(`"`vvl'"') {
					  local ql `"`: label `vvl' `vv''"'
					}
				}
			}
			
			local ln `"`ql'"'
			
			if missing(`"`ql'"') {
				local ln ""
					if !missing(`vv') {
					  if `vv' local ln `"`vl'"'
					}
					else {
					  local ln `"[`vl']"'
					}
			}
		}
		if !missing(`"`ln'"') {
		  if !missing(`"`l'"') local l `"`l'`separator'`ln'"'
		  else local l `"`ln'"'
		}
	  }
	  
	  if missing(`"`l'"') local l `"`emptylabel'"'
	  
	  label define `lname' `i' `"`l'"', modify
	}

	label values `groupvar' `lname'

end
// end of file
