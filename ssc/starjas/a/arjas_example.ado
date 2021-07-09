*! version 1.0.1  10may2007
program arjas_example
	if (_caller() < 8) {
		di as err "This example requires version 8"
		exit 198
	}
	if (_caller() < 8.2)  version 8
	else		      version 8.2
	gettoken dsn 0 : 0, parse(" :")
	gettoken null 0 : 0, parse(" :")
	di as txt "-> " as res "preserve"
	preserve
	di
	cap findfile BMT.dta
	if _rc {
		di as err "file BMT.dta not found"
		exit 601 
	}
	local fileful `"`r(fn)'"'
	cap use `"`fileful'"',clear
	if _rc>900 { 
		window stopbox stop ///   
		"Dataset used in this example" ///
		"too large for Small Stata"
		exit _rc 
	}
	di 
	di as txt "-> " as res "Example Arjas Plot" 
	di as txt "-> " as res "use `dsn', clear"
	de
	di
	di as txt "-> " as res "From the original data file Z1-Z7cat variables are created to reproduce the example 11.1 in K. & M."
	di as txt "-> " as res "replace Z1=Z1-28"
	di as txt "-> " as res "replace Z2=Z2-28"
	di as txt "-> " as res "replace Z3 = Z1*Z2"
	di as txt "-> " as res "replace Z4 = Disease == 2"
	di as txt "-> " as res "replace Z5 = Disease == 3"
	di as txt "-> " as res "replace Z6 = FAB"
	di as txt "-> " as res "replace Z7 = Z7/30 - 9"
	di as txt "-> " as res "replace Z7 = Z7/30 - 9"
	di as txt "-> " as res "egen Z7cat = cut(Z7), at(-100 -4.999 -3.059 0.01 300) icodes"
	qui {
		replace Z1=Z1-28
		replace Z2=Z2-28
		replace Z3 = Z1*Z2
		replace Z4 = Disease == 2
		replace Z5 = Disease == 3
		replace Z6 = FAB
		replace Z7 = Z7/30 - 9
		egen Z7cat = cut(Z7), at(-100 -4.999 -3.059 0.01 300) icodes
	}
	di
	di as txt "-> " as res "stset Time2,f(DeathRelapse)"
	stset Time2,f(DeathRelapse)
	di 
	di as txt "-> " as res "starjas MTX, legend(pos(5) ring(0)) lw(medthick)"
	starjas MTX, legend(pos(5) ring(0)) lw(medthick)
	di 
	more
	di as txt "-> " as res "starjas Z7cat, adjust(MTX Z1-Z6) legend(pos(5) ring(0)) lc(green navy red brown)"
	starjas Z7cat, adjust(MTX Z1-Z6) legend(pos(5) ring(0)) lc(green navy red brown)
	di 
	di as txt "-> " as res `"restore"'
end
