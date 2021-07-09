*! version 1.0.2 September 17, 2007 @ 17:22:22
*! splits up a statement based on sets and rewrites it as a command Stata can understand
program define _set2logic, rclass
version 9.2
	/* 1.0.2 - bugfix to glaring error in compound ranges */
	/* 1.0.1 - syntax fixed to allow any name */
	/* 1.0.0 - does not understand grouping, since these are supposed to be relatively simple statements */
	/* syntax: <valid Stata name to use> <set expression> */
	/*         use . for infinity (ugly) */
	
	/* peel off name to be used */
	tokenize `"`*'"'
	local theName `1'
	mac shift
	tokenize `"`*'"', parse("&|")

	if `"`2'"' == "" {
		/* have a single expression or a not */
		tokenize `"`*'"', parse("~!")
		local cnt 1
		while `"``cnt''"' == "~" | `"``cnt''"'== "!" {
			local nots "`nots'``cnt''"
			local cnt = `cnt' + 1
			}
		local item `"``cnt''"' 				 /* to make life easier */
		/* first try to use first item as numlist */
		capture _stata2logic, values(`item')
		if !_rc {
			local chunk "inlist(`theName',`r(theList)')"
			}
		else {
			tokenize `"`item'"', parse("{}")
			if `"`1'"'=="{" {
				if `"`3'"'!="}" {
					ERROR `"`item'"'
					}
				local chunk "inlist(`theName',`2')"
				}
			else {
				tokenize `"`item'"', parse("([,])")
				if `"`3'"'=="," & (`"`1'"'=="(" | `"`1'"'=="[") & (`"`5'"'==")" | `"`5'"'=="]") {
					local chunk "inrange(`theName',`2',`4')"
					if "`1'"=="(" & "`2'"!="-." {
						local chunk "`chunk' & `theName'!=`2'"
						local parenflag "true"
						}
					if "`5'"==")" & "`4'"!="." {
						local chunk "`chunk' & `theName'!=`4'"
						local parenflag "true"
						}
					}
				else {
					ERROR `item'
					}
				}
			}
		if "`parenflag'"!="" {
			local chunk "(`chunk')"
			}
		if "`nots'"!="" {
			local chunk (`nots' `chunk')
			}
		return local logic `chunk'
		}	/* end test for single expression */
	else {
		_set2logic `theName' `1'
		local left `r(logic)'
		local conj `2'
		macro shift 2
		_set2logic `theName' `*'
		return local logic "`left' `conj' `r(logic)'"
		}

end
		
program define ERROR
	display as error `"found bad token: `*'"'
	exit 119 // odd error number better for testing
end
