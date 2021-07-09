*! version 1.0.0 16May2009 labup by roywada@hotmail.com
*! move up variables based on label contents

program define labup

version 7

* move to front
syntax anything [, QUIetly]

foreach topic in `anything' {
	foreach var of varlist _all {
		local temp: var label `var'
		if index("`temp'","`topic'")~=0 {
			order `var'
			`quietly' di in yel "`var'"
		}
	}
}

end
exit

