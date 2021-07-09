*! version 1.0.0 August 24, 2007 @ 08:49:23
*! looks at a char to see if it is of the form -like varname-
program define _ck4like, rclass
version 9
	local myname "_ck4like"
	return scalar islike = 0
	syntax varname, evalchar(str) [caller(str)]
	if `"`caller'"'!="" {
		local caller `"`caller': "'
		}
	local evchar : char `varlist'[`evalchar']
	local like: word 1 of `evchar'
	if lower(`"`like'"')=="like" {
		local like: word count `evchar'
		if `like' > 2 {
			display as error "`caller'Bad usage of " as result "like" as error " for `varlist': " as result `"`evchar'"'
			display as error " The usage for " as result "like" as error " when checking variables is " as result "like {it:varname}"
			exit 198
			}
		local like : word 2 of `evchar'
		/* need to remove the trailing semicolon, if need be */
		local like : subinstr local like ";" ""
		return scalar islike = 1
      return local like "`like'"
		}
end
