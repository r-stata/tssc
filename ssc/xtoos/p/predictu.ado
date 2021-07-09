*program drop predictu
qui program predictu
syntax newvarname(gen)

cap xtset
loc panvar=r(panelvar)

tempvar x_cm y ymi
loc allvars : colfullnames e(b)
loc c _cons
loc allvars : list allvars-c
loc y=e(depvar)
fvrevar `y'
loc y=r(varlist)
egen `ymi'=mean(`y') if e(sample), by (`panvar') 
qui replace `varlist'=0
gen `x_cm'=0

foreach x of loc allvars {
	fvrevar `x'
	loc z=r(varlist)
	tempvar `z'mi
	qui egen ``z'mi'=mean(`z') if e(sample), by (`panvar')
	qui replace ``z'mi'=l.``z'mi' if ``z'mi'==.
	qui replace `x_cm'=`x_cm'+_b[`x']*``z'mi'
}
qui replace `varlist'=`ymi'-`x_cm'-_b[_cons]

end 
