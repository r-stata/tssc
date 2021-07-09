*! version 2.1.3 September 19, 2007 @ 13:16:06
*! executes a characteristic as a command (with some twists)
program define dochar , rclass
version 9
	local myname "dochar"
	/* 2.1.2 - quiet now squelches error messages from fast method */
	/*       - added >=, >, ==, <, <= to initial expression for easier simple rules */
	/* 2.1.2 - added quiet option for use by ckvar */
	/* 2.1.1 - keeps a trail to keep a loop of likes from giving a cryptic error */
	/* 2.1.0 - allows slow option to use if statements --- executes tmp do file */
	/* 2.0.0 - Uses semicolons rather than separate characteristics to run multiple commands */
	/* 1.0.0 - An initial attempt to bury code in charactaristics */
	
	syntax anything, [self(str) loud TEMPnames(str) tmpfile slow trail(str) quiet]

	capture local doThis : char `anything'
	if _rc {
		display as error "`myname': could not use " as input `"`anything'"' as error " as varname[char] format!"
		error _rc
		}

	if "`quiet'"=="" | "`loud'"!="" {
		local noisily "noisily"
		}

	if `"`doThis'"'=="" {
		if "`noisily'"!="" {
			display as text  "Nothing to run for `anything'"
			}
		return local havechar "no"
		exit 0
		}

	if "`slow'"!="" {
		local tmpfile "tmpfile"
		display as text "The -slow- option is becoming obsolete, and could disappear. Please use the -tmpfile- option in its place in the future."
		}

	tokenize "`anything'", parse("[]")
	if `"`1'"'=="_dta" {
		local xvar "_dta"
		}
	else {
		unab xvar: `1', min(1) max(1) name(`myname': `1')
		}
	local char `"`3'"'
	
	/* pulling apart the extra options to allow temp variables to be passed in */
	/* if the `tmpfile' option is chosen, these should be at the top of the dummy do file */
	if `"`tempnames'"'!="" {
		tokenize "`tempnames'", parse(": ")
		local cnt 1
		while "``cnt''"!="" {
			local next = `cnt' + 1
			local value = `cnt' + 2
			if ("``cnt''"==":") | ("``next''"!=":") | ("``value''"==":") {
				display as error "`myname': could not figure out the lclname:value list"
				display as error "`options'"
				exit 198
				}
			local ``cnt'' "``value''"
			local cnt = `cnt' + 3
			}
		local passTempnames "tempnames(`tempnames')"
		}
	
	if "`self'"=="" {
		local self "`xvar'"
		}

	_ck4like `xvar', evalchar(`char') caller(dochar)
	if `r(islike)' {
		local likevar `r(like)'
		if "`loud'"!="" {
			display as text "doing it like " as result "`likevar'"
			}
		local looped: list likevar in trail
		if `looped' {
			local trail: subinstr local trail " " " -> "
			display as error "Uh oh, there is a loop of likes: " as result "`trail' -> `xvar' -> `likevar'"
			exit 459
			}
		dochar `likevar'[`char'], self(`self') `loud' `passTempnames' `tmpfile' trail(`trail' `xvar')
		local likeVarlist "`r(likeVarlist)' `likevar'"
		}
	else {
		local like: word 1 of `doThis'
		local char1 = substr(trim(`"`doThis'"'),1,1)
		local compare = (`"`char1'"'=="<") | (`"`char1'"'=="=") | (`"`char1'"'==">")
		/* check for -in- char --- awful hack */
		if `compare' | (`"`like'"'=="in") {
			/* if using an `in' clause, the first value in the lclname:value list is the new variable name */
			/* pull off possible closing ; from dofileedit */
			local doThis : subinstr local doThis ";" ""
			tokenize "`tempnames'", parse(": ")
			local gen `3'
			if `"`like'"'=="in" {
				local doThis : subinstr local doThis "in" ""
				capture _set2logic `self' `doThis'
				if _rc {
					capture _stata2logic, values(`doThis')
					if _rc {
						display as error "`myname': had trouble figuring out -in- clause for `self'[`char']" 
						exit 198
						}
					else {
						gen byte `gen' = inlist(`self',`r(theList)')
						}
					}
				else {
					gen byte `gen' = `r(logic)'
					}
				}
			/* have a compare */
			else {
				gen byte `gen' = `self' `doThis'
				}
			}
		else {
			/* this nice, clever solution won't work, because of the way that semicolons are evaluated... */
				/* #delimit ; */
				/* 		`doThis'; */
				/* #delimit cr */

			if "`tmpfile'"!="" {
				tempname localdo
				tempfile localdofile
				file open `localdo' using "`localdofile'", write text
				/* reparsing the temp names */
				if `"`tempnames'"'!="" {
					tokenize "`tempnames'", parse(": ")
					local cnt 1
					while "``cnt''"!="" {
						local next = `cnt' + 1
						local value = `cnt' + 2
						file write `localdo' `"local ``cnt'' "``value''""' _n
						local cnt = `cnt' + 3
						}
					}
				tokenize `"`macval(doThis)'"', parse(";")
				local cnt 1
				while `"``cnt''"'!="" {
					if `"``cnt''"'!=";" {
						file write `localdo' `"`macval(`cnt')'"' _n
						}
					local ++cnt
					}
				file close `localdo'
				if "`loud'"=="" {
					run `localdofile'
					}
				else {
					do `localdofile'
					}
				}
			else {
				tokenize `"`macval(doThis)'"', parse(";")
				local cnt 1
				while `"``cnt''"'!="" {
					if `"``cnt''"'!=";" {
						if "`loud'"!="" {
							display as text "Trying to execute " as result `"``cnt''"'
							}
						capture `noisily' ``cnt''
						local rc = _rc
						if `rc' {
							if "`quiet'"=="" {
								display as error "`myname': Had trouble executing " as input `"``cnt''"'
								}
							exit `rc'
							}
						}
					local ++cnt
					}
				}	/* end of slow split */
			} 	/* end of check for in */
		} /* end of check for like */
	return local havechar "yes"
	return local likeVarlist "`likeVarlist'"
end

program define like
	dochar `*'[$doCharChar], self($doVarVar) 
end
