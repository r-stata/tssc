*! levenshtein 1.0.1 05aug2010 by Julian Reif
* 1.0.1: Added ability to retrieve edit distances for two string vectors

program define levenshtein, rclass 

	* We are using version 2.0 of Stata's plugin interface, which requires Stata 9
	version 9.2
	return clear
		
	*************
	* Usage one *
	*************
	cap syntax varlist(min=2 max=2) [if] [in], GENerate(string)
	if !_rc {
		
		* Error check the inputs
		local string_vars `varlist'
		confirm string var `string_vars'
		marksample touse, strok novarlist
		local 0 "`generate'"
        cap syntax newvarlist 
        if _rc { 
                di as err "generate(newvarlist) invalid" 
                exit _rc 
        }

		* Call plugin
		qui gen `generate' = .
		cap noi plugin call strgroup_plugin `string_vars' `generate' if `touse', 0
		if _rc {
			di as error "Plugin error " _rc
			exit 198
		}		
	}
	
	*************
	* Usage two *
	*************
	else {
		
		* Error check the inputs
		args string1 string2 the_rest
		if `"`the_rest'"'!="" {
			di as error "Syntax is: {cmd:levenshtein} {it:string1} {it:string2}"
			exit 198
		}

		* The plugin returns the edit distance
		cap noi plugin call strgroup_plugin, "`string1'" "`string2'" 0	
		if(_rc>=0) {
			di in yellow _rc
			return scalar distance = _rc
		}

		* If the returned value is negative, an error occured.
		else {
			di as error "Plugin error " _rc
			exit 198
		}
	}
	
end

program strgroup_plugin, plugin using( "strgroup.plugin" )

**EOF