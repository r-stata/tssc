*! version 1.0.4 December 9, 2003 @ 22:28:23
*! parses one word off the front of a string variable, just as gettoken does with macros
program define vgettoken
version 8.2
	/* 1.0.3 - updated to version 8, changed syntax to be more like gettoken */
	/* 1.0.2 - updated to version 7, changed name from _nextwrd */
	/* 1.0.1 - allows gen option for generating a new variable */
	local me vgettoken
	syntax anything(id="variable names") [if] [in] [, Parse(str) noSPACE REPLACERESUlt REPLACERESt noDELIMiters]

	if "`parse'"=="" & "`space'"!="" {
		display as error "[`me']: You need to parse on something! Either give a character in the parse option,"
		display as error "  or specify the space option!"
		exit 198
		}

	/* fixing stata's troubles with substr(" ",1,1) being "" */
	/*   need to strip spaces from the parse string */
	local pspace = index("`parse'"," ")
	if `pspace' {
		if "`space'"!="" {
			display as error "[`me']: You specified no spaces, but put a space in the parse string! I'm lost."
			exit 198
			}
		local parse = subinstr("`parse'"," ","",.)
		}


	if "`delimiters'"=="" {
		local dlength 0
		}
	else {
		local dlength 1
		}
	
	tokenize `"`anything'"', parse(" :")

	if `"`3'"' == "" GenlSyntaxError `me'

	local result `"`1'"'
	capture confirm new var `result'
	local rc = _rc
	if `rc' {
		if `rc' == 110 {
			if "`replaceresult'"=="" {
				display as error "[`me']: the result variable " as result "`result'" as error "already exists, and " as text "replaceresult" as error " was not specified!"
				exit 110
				}
			tempname oldresult
			}
		else {
			display as error `"[`me']: had trouble with result variable `result'"'
			error `rc'
			}
		}	/* end error check for result */
	/* if 2nd token is colon, then just taking first word, and chucking rest */
	if "`2'"!=":" {
		if "`3'"!=":" {
			GenlSyntaxError `me'
			}
		local rest `"`2'"'
		capture confirm new var `rest'
			local rc = _rc
		if `rc' {
			if `rc' == 110 {
				if "`replacerest'"=="" {
					display as error "[`me']: the rest variable " as result "`rest'" as error "already exists, and " as text "replacerest" as error " was not specified!"
					exit 110
					}
				tempname oldrest
				}
			else {
				display as error `"[`me']: had trouble with result variable `rest'"'
				error `rc'
				}
			}	/* end error check for rest */
		local source `"`4'"'
		}
	else {
		local source `"`3'"'
		}
	capture confirm variable `source'
	if _rc {
		display as error `"[`me']: Had trouble with the source variable `source'"'
		exit 198
		}

	/* error checking finished */
	
	marksample useme, strok
	quietly sum `useme'
	if r(max)==0 {
		display as result "[`me']: no observations chosen... nothing generated"
		exit
		}
	quietly {
		if "`space'"=="" {
			tempvar atspace
			gen int `atspace' = index(`source'," ") if `useme'
			replace `atspace' = . if `atspace'==0
			}
		else {
			local atspace .
			}
		
		local plength = length("`parse'")
		if `plength' {
			tempvar atdelim whereat
			forvalues cnt = 1/`plength' {
				local theDelim = substr("`parse'",`cnt',1)
				gen int `whereat' = index(`source',"`theDelim'") if `useme'
				if `cnt' == 1 {
					gen int `atdelim' = `whereat'
					}
				else {
					replace `atdelim' = `whereat' if `whereat' & (`whereat'<`atdelim') & `useme'
					}
				drop `whereat'
				local cnt = `cnt' + 1
				}
			replace `atdelim' = . if `atdelim'==0
			}
		else {
			local atdelim .
			}

*set trace on
		tempvar take 
		gen int `take' = min(`atspace',`atdelim')-1 if `useme'
*set trace off
*pause fooey
		if `plength' & ("`delimiters'"=="") {
			replace `take' = 1 if (`take'==0) & (`atdelim'<.) & `useme'
			}
*pause fooey2

		GenRep `result', what(str)
		`r(genrep)' `result' = substr(`source',1,`take') if `useme'

		if "`rest'"!="" {
			GenRep `rest', what(str)
			`r(genrep)' `rest' = trim(substr(`source',`take'+`dlength'+1,.)) if `useme'
			}
		}
end

program define GenlSyntaxError

		args me
				display as error "[`me']: the primary syntax is either "
		display as text " nextword " as result "result : source" as error " or"
		display as text " nextword " as result "result rest : source"
		exit 198

end


program define GenRep , rclass
	local me "GenRep"
	syntax anything(id="variable") [, what(str)]
	capture confirm new var `anything'
	local rc = _rc
	if `rc' {
		if `rc'== 110 {
			return local genrep "replace"
			}
		else {
			display as error "[`me']: had trouble with variable name `anything'"
			error `rc'
			}
		}
	else {
		return local genrep "gen `what'"
		}
end
