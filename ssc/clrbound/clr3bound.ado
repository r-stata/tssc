capt program drop clr3bound
program define clr3bound, eclass

version 12.0

syntax anything [if] [in] [, METhod(string) STEPsize(real 0.01) LEVel(real 0.95) noAIS noRSEED SEED(integer 0) *]

ereturn clear


	
if "`rseed'" != "norseed" {
	set seed `seed' 
}

local det = 0


local int_level = 100 * `level' 
while (int(`int_level') != `int_level') {
	local int_level = `int_level' * 10
}



quietly clr2bound `anything' `if' `in' , met(`method') notest lev(`level') norseed `ais' `options'


local lbd = `e(lbd`int_level')'
local ubd = `e(ubd`int_level')'

while `det' == 0 {
	quietly clr2bound `anything' `if' `in' , met(`method') null(`lbd') lev(`level') norseed `ais' `options' 

	local det = `e(t_det`int_level')'
	local lbd = `lbd' + `stepsize'	
}


local det = 0




while `det' == 0 {
	quietly clr2bound `anything' `if' `in' , met(`method') null(`ubd') lev(`level') norseed `ais' `options' 
	local det = `e(t_det`int_level')'
	local ubd = `ubd' - `stepsize'
}




quietly clr2bound `anything' `if' `in' , met(`method') notest lev(`level') norseed `ais' `options'

ereturn local title = "CLR Intersection Bounds: Test inversion bounds"
ereturn local cmd = "clr3bound" 
ereturn scalar level = `level'
ereturn scalar stepsize = `stepsize'
ereturn scalar lbd = `lbd' 
ereturn scalar ubd = `ubd'

display as text _newline e(title) _col(59) "Number of obs : " as result e(N)

if "`method'" == "series" {
	ereturn local method = "Series estimation"
	display as text "Method : " e(method) " (" e(smoothing) ")" _col(63) "Step size : " as result e(stepsize)
}
else if "`method'" == "local" {
	ereturn local method = "Local linear estimation"
    display as text "Method : " e(method) " (" e(smoothing) ")" _col(63) "Step size : " as result e(stepsize)
}
else {
	ereturn local method = "Parametric estimation" 
	display as text "Method : " e(method) _col(63) "Step size : " as result e(stepsize)
}

if "`ais'" != "noais" {
	display as text "AIS(adaptive inequality selection) is applied" 
}
else { 
	display as text "AIS(adaptive inequality selection) is not applied" 
}

if `e(lbd`int_level')' > `e(ubd`int_level')' {
	display as text _newline 100*`level' "% Bonferroni bounds is empty." 
}
else display as text _newline 100*`level' "% Bonferroni bounds:     (" as result %9.7f `e(lbd`int_level')' as text " , " as result %9.7f `e(ubd`int_level')' as text ")" 

if `lbd' > `ubd' {
	display as text 100*`level' "% Test inversion bounds is empty."
}	
else display as text 100*`level' "% Test inversion bounds: (" as result %9.7f `lbd' as text " , " as result %9.7f `ubd' as text ")"
	
end
