*! version 1.1.2  30may2015  Robert Picard, Picard@netbox.com & NJC
*! cloned from egen version 3.4.1  05jun2013; modified to accept tsvarlists
program define tsegen, sortpreserve

	version 10

	local cvers = _caller()

	gettoken type 0 : 0, parse(" =(")
	gettoken name 0 : 0, parse(" =(")

	if `"`name'"'=="=" {
		local name `"`type'"'
		local type : set type
	}
	else {
		gettoken eqsign 0 : 0, parse(" =(")
		if `"`eqsign'"' != "=" {
			error 198
		}
	}

	confirm new variable `name'

	gettoken fcn 0 : 0, parse(" =(")
	
	// separate the args from the optional minimum count
	gettoken allargs 0 : 0, match(par)
	gettoken args rest : allargs, parse(",")
	if "`rest'" != "" {
		gettoken comma minimum : rest, parse(",")
		confirm integer number `minimum'
	}
	else local minimum 0
	
	capture qui findfile _g`fcn'.ado
	if (`"`r(fn)'"' == "") {
		di as error "unknown egen function `fcn'()"
		exit 133
	}
	
	if `"`par'"' != "(" { 
		exit 198 
	}
	
	cap tsrevar `args'
	if !_rc local tsargs `r(varlist)'
	else {
		while "`args'" != "" {
			gettoken item args : args, bind
			if regexm("`item'","\((.+)\)") local numlist = regexs(1)
			else local numlist
			if "`numlist'" != "" {
				numlist "`numlist'"
				foreach n in `r(numlist)' {
					local op : subinstr local item "`numlist'" "`n'"
					tsrevar `op'
					local tsargs `tsargs' `r(varlist)'
				}
			}
			else {
				tsrevar `item'
				local tsargs `tsargs' `r(varlist)'
			}
		}
	}

	syntax [if] [in] [, *]
	if `"`options'"' != "" { 
		local cma ","
	}
	
	tempvar dummy
	global EGEN_Varname `name'
	global EGEN_SVarname `_sortindex'
	capture noisily _g`fcn' `type' `dummy' = (`tsargs') `if' `in' `cma' `options'
	global EGEN_SVarname
	global EGEN_Varname
	
	if _rc { 
		exit _rc 
	}
	
	if `minimum' > 0 {	
		tempvar n
		egen `n' = rownonmiss(`tsargs')
		qui replace `dummy' = . if `n' < `minimum'
	}
	
	quietly count if missing(`dummy')
	if r(N) { 
		local s = cond(r(N)>1,"s","")
		di in bl "(" r(N) " missing value`s' generated)"
	}
	rename `dummy' `name'
end
exit
/*
	syntax is:
		egen type varname = xxx(something) if exp in exp, options
		passed to xxx is
			<type> <varname> = (something) if exp in exp, options

		If xxx expects varlist, 
			gettoken type 0 : 0
			gettoken vn   0 : 0
			gettoken eqs  0 : 0    /* known to be = */
			syntax varlist ...

		If xxx expects exp
			syntax newvarname =exp ...

	Note, the utility routine should not present unnecessary messages
	and must return nonzero if there is a problem.  The new variable 
	can be left created or not; it will be automatically dropped.
	If the return code is zero, a count of missing values is automatically
	presented.
*/
	
