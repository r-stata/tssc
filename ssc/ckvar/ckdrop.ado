*! version 1.0.0 September 14, 2007 @ 17:16:32
*! runs a drop, but ensures that no needed variables are dropped
program define ckdrop
version 9
	syntax varlist, [stubs(passthru) listonly]
	local dropper "`varlist'"
	unab allvars: *

	local keeper: list allvars - dropper
	if "`keeper'"!="" {
		ckkeep `keeper', `stubs' `listonly' caller(ckdrop)
		}
	else {
		drop _all
		}
end
