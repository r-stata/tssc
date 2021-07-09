*! version 1.0.0 September 18, 2007 @ 18:18:50
*! dumps a do-file which can regenerate the proper characteristics
program define ckvardo
version 9
	syntax [varlist] using/  [, STUBs(str) replace]
	if "`varlist'"=="" {
		error 3
		}
	if `"`stubs'"'=="" {
		local stubs "valid"
		}
	_getfilename `"`using'"'
	if !strpos(`"`r(filename)'"',".") {
		local using `"`using'.do"'
		}
	
	tempname fhandle

	file open `fhandle' using `"`using'"', write `replace'

	foreach stub of local stubs {
		foreach var of local varlist {
			local chars : char `var'[]
			foreach char of local chars {
				if strpos(`"`char'"',"`stub'_")==1 {
					file write `fhandle' `"char `var'[`char'] "'
					local theChar : char `var'[`char']
					local theChar : subinstr local theChar "`" "\\`", all
					tokenize `"`macval(theChar)'"', parse(";")
					local cnt 1
					local goeson 0
					while `"``cnt''"'!="" {
						if `"``cnt''"'!=";" {
							local eraseme : subinstr local `cnt' "///" "///", count(local goeson)
							if `goeson' {
								local continue " _n"
								}
							else {
								local continue
								}
							file write `fhandle' `"`macval(`cnt')'"'`continue'
							}
						else {
							if !`goeson' {
								file write `fhandle' ";"
								}
							}
						local ++cnt
						}
					file write `fhandle' _n
					}
				}
			}
		}
	file close `fhandle'
end
