*! version 1.0.1 September 12, 2007 @ 18:44:42
*! takes a numlist and preps it for an -inlist()-
program define _stata2logic, rclass
	/* 1.0.1 - split out from dochar.ado */
	syntax, values(numlist)
	local foo : subinstr local values " " ",", all
	return local theList `foo'
end
