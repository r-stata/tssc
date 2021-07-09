*! 1.0.0 Alvaro Carril 27nov2015
program define nrow
version 10

syntax [anything(name=firstrow id="#row")] [, Keep Varlist(varlist)]

if missing("`varlist'") {
	local varlist _all
}

if missing("`firstrow'") {
	local firstrow 1
}
confirm integer number `firstrow'
if `firstrow' > _N {
	display as error "#row is out of range"
	exit 198
}
foreach v of varlist `varlist' {
	local l `"`=`v'[`firstrow']'"'
	capture rename `v' `l'
	if _rc == 198 {
		local l = strtoname("`l'",1)
		capture rename `v' `l'
	}
}
if missing("`keep'") {
	drop in 1/`firstrow'
}
end
