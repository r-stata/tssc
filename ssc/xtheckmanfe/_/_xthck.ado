** ad on for xtheckfe
program define _xthck, eclass
syntax [if], y1(str) y2(str)  x1(str) x1m(str) z1(str) z1m(str) time(str)  bpi(str)
	marksample touse
	tempname bp br Vr
	** Probit uses ALL exogenous variables
	** x1 are for main equation only
	** z1 are instruments for Selection
 	
	probit `y2' i.`time'#c.(`x1' `x1m' `z1' `z1m') i.`time' if `touse', from(`bpi', skip)
	matrix `bp'=e(b)
	capture drop _sel_imr
	predict double _sel_imr, score
	reg `y1' `x1' `x1m' `z1m' i.`time' i.`time'#c.(_sel_imr) if `y2'==1 & `touse'
	matrix `br'=e(b)
	matrix `Vr'=e(V)
	matrix coleq `bp'= selection
	matrix coleq `br' = `y1'
	matrix b=`br' ,`bp'
	ereturn post b , esample(`touse')
end
