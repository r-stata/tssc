*! version 0.0.1 17february2016 Johannes N. Blumenberg

program def trimlabs
version 11 
syntax varlist [, LENgth(numlist)]
	
	local variables `varlist'
	local length = "`length'"

if "`length'"!="" {
	local laenge = `length'
} 
else {
	local laenge = 80
}

foreach var of varlist `variables' {
	local labelold: variable label `var'
	local labelnew = substr("`labelold'", 1, `laenge')
	la var `var' "`labelnew'"
}

end
exit