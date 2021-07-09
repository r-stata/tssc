*! version 1.00 copyright Richard J. Atkins 2005
*! version 1.01 March 2006 - Modified syntax processing slightly
*! version 1.02 May 2005 - Fixed problem with brace interpretation in version 8 of Stata
program define zerouse

	version 8.0
	syntax [varlist] [, PATtern(real 9.9) BY(varlist max=1) GENerate(namelist min=1 max=1) DIgit(string) *]

*
* pattern is a float in the form 3.2 representing number of digits to the
* left (3) and right (2) of the decimal place.
*

	tempvar asstring
	tempvar binpat

	local zero="0"
	if ("`digit'"!="") { 
		local zero="`digit'" 
	}
	local leftplaces=int(`pattern')
	local rightplaces=int(`pattern'*10)-10*`leftplaces'
	local hasdp=0
	if (0<`rightplaces') { 
		local hasdp=1 
	}
	local strchars = `leftplaces'+`rightplaces'+`hasdp'
	local useformat = "%0" + string(`strchars') + "." + string(`rightplaces') + "f"
	qui gen str`strchars' `asstring' = ""
	qui replace `asstring'=string(`varlist', "`useformat'") if(.!=`varlist')
	qui replace `asstring'=substr(`asstring',-`strchars',.)

	qui gen str`strchars' `binpat' = ""
	forvalues loop=`leftplaces'(-1)-`rightplaces' {
		local index=`leftplaces'-`loop'+1
		local offset=`leftplaces'-`loop'
		if (`loop'<0) { 
			local offset=`offset'-1 
		}
		if (`loop'!=0) {
			qui replace `binpat'=`binpat'+"`zero'" if(substr(`asstring',`index',1)=="`zero'")
			qui replace `binpat'=`binpat'+"#" if(substr(`asstring',`index',1)!="`zero'")
		}
		if (`loop'==0) { 
			qui replace `binpat'=`binpat'+"." 
		}
	}
	qui replace `binpat'="" if (`varlist'==.)
	lab var `binpat' "Digit pattern"
	tab `by' `binpat', `options'
	if ("`generate'"!="") { 
		gen str`strchars' `generate' = `binpat'	
	}
end

