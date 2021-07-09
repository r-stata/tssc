*! This program automatically manages datasets obtained from databases providing 
*! variable definitions on the second row.
*! Author: P. Wilner Jeanty
*! Born: February 2009
*! Update: September-October 2009
*! Option saving() added: June 2010
program define labcenswdi
	version 9.2
	gettoken usertype:0
	if "`usertype'"=="" _labcens1 `0'
	else _labcens2 `0'
end
program define _labcens1
	version 9.2
	syntax
	unab vars:_all 
	local i=1
	foreach var of local vars {
		local vlab: word `i' of `vars' 
		local var`i' `vlab'
		local lab`i' `"`=`vlab'[1]'"'
		local ++i
	}
	local nvars: word count `vars' 
	di
	di in y " The current dataset contains `nvars' variables defined as follows:"
	di
	forv i=1/`nvars' {
		di "`i') `var`i'': `lab`i''"
	}
end
program define _labcens2
	version 9.2
	syntax [newvarlist(default=none)], nstr(str) [TRUNCby(str asis) TRUNCWith(str asis) REPdes(str asis) force comma saving(str)]
		unab varxx:_all
	if "`saving'"!="" {
		tokenize "`saving'", parse(",")
		args nameof_file secxx sav_opt
		capture confirm new file `nameof_file'
		if !_rc & "`sav_opt'" != "" &  "`sav_opt'" != "replace" {
			di as err "The suboption for {bf:saving()} must be {bf:replace}"
			exit 198
		}
		else if _rc & "`sav_opt'"=="" confirm new file `nameof_file'
		else if _rc & "`sav_opt'"!="" &  "`sav_opt'" != "replace" {
			di as err "The suboption for {bf:saving()} must be {bf:replace}"
			exit 198
		}		
		tempname myhandle		
		local ecr_fichier file write `myhandle'
		local ouv_fichier file open `myhandle'
		local i=1
		foreach var of local varxx {
			local vlab: word `i' of `varxx' 
			local oldlab`i' `"`=`vlab'[1]'"'
			local ++i
		}			
	}			
	local nvars: word count `varxx'
	if `"`repdes'"'!="" {
		local getval
		local gettext
		local getrep `repdes' // because gettoken will destroy `repdes' needed for later use
		local y=0
		while `"`getrep'"'!="" {
			gettoken nnfel getrep : getrep, parse("(") match(paren) quotes			
			local uval : word 1 of `nnfel'
			if `uval'>`nvars' {
				di as err "Value, `uval', specified with the {bf:repdes()} option greater than the number of variables in the dataset"
				exit 198
			}
			local getval `getval' `uval' /* Record the values user enters */
			local ++y
			local utxt`y' : word 2 of `nnfel'
			if `y'>=2 {
				forv j=1/`=`y'-1' { // `=expression' implies evaluating the expression first
					if `"`utxt`j''"'==`"`utxt`y''"' { // comparing the current token with all the previous ones
						di as err "Quoted texts specified with option {bf:repdes()} must be unique"
						exit 198
					}
				}
			}
		}
		if `y'>0 {
			capture numlist "`getval'", integer ascending // to check whether the values are entered properly
			if _rc {
				di as err "Values specified for the {bf:repdes()} option are incorrect or incorrectly entered"
				exit 198
			}
		}
		if `y'>`nvars' {
			di as err "Too many new variable descriptions specified"
			exit 198
		}
		else if `y'==`nvars' di as txt "Warning: you are replacing all the variable descriptions"
	}
	if `"`truncwith'"' !="" & `"`truncby'"'=="" {
		di as err "Option {bf:truncby()} required when {bf:truncwith()} is specified"
		exit 198
	}
	local flag=0
	local i=1
	if `"`macval(truncby)'"'!="" {
		local ntruncb `truncby'
		local G=0
		local ntb "" // useful to compare the current token with the previous one
		while `"`ntruncb'"'!="" {
			gettoken nntruncb ntruncb : ntruncb, parse("(") match(paren) quotes			
			if "`ntb'"==`nntruncb' local flag=1  // flag me if the current token equals the previous one
			local ntb  `nntruncb'
			local ++G
			local trunc`G' `ntb'
		}
		if `G'>2 {
			di as err "At most two elements can be specified with option {bf:truncby()}"
			exit 198
		}
		if `"`truncwith'"' !="" {
			local ntruncw `truncwith'
			local W=0
			local ntw "" // useful to compare the current token with the previous one
			while `"`ntruncw'"'!="" {
				gettoken nntruncw ntruncw : ntruncw, parse("(") match(paren) quotes			
				if "`ntw'"==`nntruncw' local flag=2  // flag me if the current token equals the previous one
				local ntw  `nntruncw'
				local ++W
				local truncw`W' `ntw'
			}
			if `W'>2 {
				di as err "No more than two sets of characters are allowed with option {bf:truncwith()}"
				exit 198
			}
			if (`G'==1 & `W'==1) & (`"`trunc1'"'==`"`truncw1'"')  local flag=3
			else if (`G'==2 & `W'==2) {
				if (`"`trunc1'"'==`"`truncw1'"')  local flag=3
				if (`"`trunc1'"'==`"`truncw2'"')  local flag=4
				if (`"`trunc2'"'==`"`truncw1'"')  local flag=5
				if (`"`trunc2'"'==`"`truncw2'"')  local flag=6
			}
			if inlist(`flag',1,2,3,4,5,6) {
				di as err "Quoted texts specified with options {bf:truncby()} and {bf:truncwith()} must be unique"
				exit 198
			}
			if `W' !=`G' {
				di as err "Options {bf:truncby()} and {bf:truncwith()} must have the number of elements (quoted texts)"
				exit 198
			}
		}
		local chktrunc1=0
		local chktrunc2=0
		foreach var of local varxx {
			local vlab: word `i' of `varxx' 
			local var`i' `vlab'
			local lab`i' `"`=`vlab'[1]'"'
			local textpos=strpos(`"`lab`i''"', `"`trunc1'"')
			if strpos(`"`lab`i''"', `"`trunc1'"')!=0  {
				local trunclab`i'=regexr(`"`lab`i''"',`"`trunc1'"',`"`truncw1'"')
				local chktrunc1=1
			}
			else local trunclab`i' `lab`i''
			if `G'==2 {
				if strpos(`"`lab`i''"', `"`trunc2'"')!=0  {
					local trunclab`i' =regexr("`trunclab`i''",`"`trunc2'"',`"`truncw2'"')
					local chktrunc2=1
				}
				else local trunclab`i' `trunclab`i''
			}
			local ++i
		}
		if `chktrunc1'==0 {
			di as err "Text: "`""`trunc1'""'" not found"
			exit 198
		}
		if `G'==2 & `chktrunc2'==0 {
			di as err "Text: "`""`trunc2'""'" not found"
			exit 198
		}
	}	
	else {
		foreach var of local varxx {
			local vlab: word `i' of `varxx' 
			local var`i' `vlab'
			local lab`i' `"`=`vlab'[1]'"'
			local ++i
		}
	}
	if `"`macval(repdes)'"'!="" {
		while `"`repdes'"'!="" {
			gettoken nnfel repdes : repdes, parse("(") match(paren)
			local lab`:word 1 of `nnfel'' `:word 2 of `nnfel''
			if `"`macval(truncby)'"'!="" {
				local trunclab`:word 1 of `nnfel''  `lab`:word 1 of `nnfel''' 
			}
		}
	}
	if "`varlist'"!="" {		
		if `:word count `varlist'' != `nvars' {
			di
			di as err "Incorrect number of variable names"
			exit 198
		}
		local t=1
		foreach x of local varxx {
			local xv`t': word `t' of `varxx'
			local ++t
		}
		local i=1
		foreach s of local varlist {
			ren `xv`i'' `s'
			local ++i
		}
	}
	qui drop if _n==1
	local trunc ""
	if `"`macval(truncby)'"'!="" local trunc trunc  
	local nidv=real("`nstr'")
	if "`varlist'"=="" local vartowork `varxx'
	else local vartowork `varlist'
	local j=1
	foreach var of local vartowork {
		if `j'<=`nidv' qui compress `var'
		if `j'>`nidv' {
			if "`comma'"!="" {
				if strpos(`var', `","')!=0 qui replace `var' = subinstr(`var', `","', "", .)
			}
			else if "`comma'"=="" & strpos(`var', `","')!=0 {
				di
				di as txt "Variable `var' takes on values with 1000-separator commas, thus not converted to numeric."				 
			}
			qui count if `var' != "" & real(`var')>=. // trap values with non-numeric characters except blanks
			if r(N)>0 & "`force'"=="" {
				di
                  	di as txt "Non-numeric characters present, variable `var' not converted to numeric"
      		}
 			else { 
				qui gen double m`var'=real(`var')
				qui compress m`var'
				drop `var'
				ren m`var' `var'
			}
		}
		label var `var' "``trunc'lab`j''"
		local ++j
	}
	if "`saving'"!="" {		
		`ouv_fichier' using `nameof_file'.txt, write text `sav_opt' 
		set more off
		`ecr_fichier' "Order" _col(8) "Type" _col(15) "Name" _col(28) "Description" _n
		local j=1
		foreach var of local vartowork {
			`ecr_fichier' (`j') ")" _col(8) "`:type `var''" _col(15) "`var'" _col(28) `"`oldlab`j''"' _n
			local ++j
		}
		file close `myhandle'
		set more on
	}	
	di
	di in y "Labeling, renaming, and/or conversion of variables done successfully"
	di
	if "`saving'" != "" di as txt ///
	"Note: For future reference, original variable descriptions saved to text file: {stata type `nameof_file'.txt:`c(pwd)'`c(dirsep)'`nameof_file'.txt}"  	
end

