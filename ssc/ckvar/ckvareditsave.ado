*! version 1.0.1 April 2, 2010 @ 14:59:54
*! saves user input from editcheckvar dialog
program define ckvareditsave
version 9
	/* 1.0.1 - squashed some bugs due to not quoting strings well enough */
	local myname "ckvareditsave"

	syntax varname, stub(str) req(str) rulechgflag(str) [rule(str) xvars(str) misval(str)]

	if `"`xvars'"'!="" {
		/* for testing if extra variables exist */
		unab xvarstest: `xvars', name("`myname'")
		char `varlist'[`stub'_other_vars_needed] `xvars'
		}

	if `"`misval'"'!="" {
		char `varlist'[`stub'_missing_value] `misval'
		}
	
   if `req' {
		char `varlist'[`stub'_required] yes
		}
	else {
		local theChar: char `varlist'[`stub'_required]
		if `"`theChar'"'!="" {
			char `varlist'[`stub'_required]
			}
		}
	if `rulechgflag' {
/* alas... this fails in this direction... */
/* 		char `varlist'[`stub'_rule] `"`macval(rule)'"' */
		if `"`rule'"'=="" {
			char `varlist'[`stub'_rule]
			}
		else {
			local first: word 1 of `rule'
			local char1 = substr(trim(`"`rule'"'),1,1)
			if lower(`"`first'"') == "in" | lower(`"`first'"') == "like" | `"`char1'"'=="<" | `"`char1'"'=="=" | `"`char1'"'==">" {
				char `varlist'[`stub'_rule] `"`rule'"'
				}
			else {
				display as text "`myname': did not save complex rule " as result `"`macval(rule)'"'
				}
			}
		}
   if !`c(changed)' {
		local theObs = _N + 1
		capture set obs `theObs'
		if _rc {
			display as result "`myname': be careful! Dataset not marked as changed!"
			exit
			}
		capture drop in l
	   if _rc {
			display as error "`myname': added an observation, but could not drop it! Last observation is fake!"
			exit 666
			}
	}	/* end check for changed */
end
