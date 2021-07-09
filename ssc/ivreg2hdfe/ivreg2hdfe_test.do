clear all
set more off
eststo clear 

capt cd "~/Desktop/ivreg2hdfe/"

// qui do ivreg2hdfe.do
set seed 1

set obs 5000
foreach v in a b c d e y {
	g `v' = uniform()
}
g id = int(100*(uniform()+1))-99
sort id
bys id: egen t = seq()
xtset id t
 
g cons = 1

xi i.t

eststo: xtivreg2 y (b c = d e)  _It* if a<0.3, fe i(id) cluster(id)
matrix x = e(V)
di sqrt(x[1,1])

which ivreg2hdfe

eststo: ivreg2hdfe if a<0.3, de(y) en(b c) iv(d e) id1(id) id2(t) cluster(id) gmm2s

matrix x = e(V)
di sqrt(x[1,1])

esttab, cells(b t) keep(b c)
