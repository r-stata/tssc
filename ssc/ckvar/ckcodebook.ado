*! version 1.0.0 August 24, 2007 @ 10:34:18
*! lists rules for each of the variables
program define ckcodebook
version 9
	local indent 6
	local hang 2
	local rmargin 2
	syntax [varlist], [stubs(str)]
	if "`stubs'"=="" {
		local stubs "valid"
		}

	foreach stub of local stubs {
		if "`stub'"=="valid" {
			local header "Validation Rule"
			}
		else {
			if "`stub'"=="score" {
				local header "Scoring"
				}
			else {
				local header "Stub `stub'"
				}
			}
		foreach var of local varlist {
			local liketag
			local theLab: var label `var' 
			display as text "{.-}"
			display as result "`var'{right:`theLab'}"
			display as text "{.-}"
			local theChar : char `var'[`stub'_rule]
			display as text "{col `indent'}`header': " _cont
			if length(`"`macval(theChar)'"') {
				if strpos(`"`macval(theChar)'"',";") {
					display // end the _cont from above
					local xindent = `indent' + `hang'
					tokenize `"`macval(theChar)'"', parse(";")
					local cnt 1
					while `"``cnt''"'!="" {
						if `"``cnt''"'!=";" {
							local hindent = `xindent' + (2*`hang')
							display as result "{p `xindent' `hindent' `rmargin'}" `"`macval(`cnt')'"' "{p_end}"
							if strpos(`"`macval(`cnt')'"',"{") {
								local xindent = `xindent' + `hang'
								}
							if strpos(`"`macval(`cnt')'"',"}") {
								local xindent = `xindent' - `hang'
								}
							}
						local ++cnt
						}
					}
				else {
					local like: word 1 of `theChar'
					if lower("`like'")=="like" {
						local like : word count `theChar'
						if `like' > 2 {
							display as error `"`macval(theChar)'"'
							}
						else {
							display as result `"`theChar'"'
							/* to be used if like eventually rules all chars */
							local liketag " (uses like)"
							}
						}
					else {
						display as result `"`theChar'"'
						}
					}
				}
			else {
				display as text "none"
				}

			local theChar : char `var'[`stub'_required]
			if "`theChar'"!="" & (("`theChar'" == "1") | strpos("true",lower("`theChar'")) | strpos("yes",lower("`theChar'"))) {
				local theChar "yes"
				local misval : char `var'[`stub'_missing_value]
				if "`misval'"=="" {
					local misval -1
					}
				}
			else {
				local theChar "no"
				local misval "N/A"
				}
			display as text "{col `indent'}Is Required: " as result "`theChar'" // as text "`liketag'"
			display as text "{col `indent'}Missing Value: " as result "`misval'" // as text "`liketag'"
			local theChar : char `var'[`stub'_other_vars_needed]
			if "`theChar'"=="" {
				local theChar "none"
				}
			
			display as text "{col `indent'}Other Variables Needed: " as result "`theChar'" as text "`liketag'"
			}	/* end varlist loop */
		}		/* end of stub loop */

	

end
