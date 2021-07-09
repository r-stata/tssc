// This do-file does all the examples in 
//    Cattaneo, Drukker and Holland (2012)
// Estimation of Multivalued Treatment Effects under Conditional Independence
// http://www-personal.umich.edu/~cattaneo/papers/Cattaneo-Drukker-Holland_2012_STATA.pdf
//    but it takes a long time to run
version 12.1

clear all
set more off
mata: mata mlib index


// Example ex0
use spmdata
bfit logit w pindex eindex, corder(3) base(0) sort(aic)


// Example ex1
mlogit


// Example ex2
predict double (phat0 phat1 phat2), pr
sort w
by w: summarize phat0 phat1 phat2


// overlap plot
// Example ex3
kdensity phat0 if w==0, generate(xp00 den00) nograph n(5000) kernel(triangle)
kdensity phat0 if w==1, generate(xp01 den01) nograph n(5000) kernel(triangle)
kdensity phat0 if w==2, generate(xp02 den02) nograph n(5000) kernel(triangle)
twoway line den00 xp00 || line den01 xp01 || line den02 xp02 , 	///
	legend(label(1 "w==0") label(2 "w==1") label(3 "w==2"))	///
	title("Conditional densities for probability of treatment level 0") ///
	name(pw0)

graph export pw0.eps, replace

// Example ex4
kdensity phat1 if w==0, generate(xp10 den10) nograph n(5000) kernel(triangle)
kdensity phat1 if w==1, generate(xp11 den11) nograph n(5000) kernel(triangle)
kdensity phat1 if w==2, generate(xp12 den12) nograph n(5000) kernel(triangle)

kdensity phat2 if w==0, generate(xp20 den20) nograph n(5000) kernel(triangle)
kdensity phat2 if w==1, generate(xp21 den21) nograph n(5000) kernel(triangle)
kdensity phat2 if w==2, generate(xp22 den22) nograph n(5000) kernel(triangle)


// Example ex5
twoway line den10 xp10 || line den11 xp11 || line den12 xp12 , 	///
	legend(label(1 "w==0") label(2 "w==1") label(3 "w==2"))	///
	title("Conditional densities for probability of treatment level 1") ///
	name(pw1)
twoway line den20 xp20 || line den21 xp21 || line den22 xp22 , 	///
	legend(label(1 "w==0") label(2 "w==1") label(3 "w==2"))	///
	title("Conditional densities for probability of treatment level 2") ///
	name(pw2)

graph export pw1.eps , name(pw1) replace
graph export pw2.eps , name(pw2) replace

// Example ex6
bfit regress spmeasure pindex eindex, corder(3) 


// Example ex7
regress


// Example ex8
poparms (w c.(pindex eindex)##c.(pindex eindex)) 	///
	(spmeasure c.(pindex eindex)##c.(pindex eindex)) 	


// Example ex9
poparms  , coeflegend
contrast ar.w, nowald


// Example ex10
contrast r.w, nowald


// Example ex11
margins i.w, pwcompare
marginsplot, unique plotopts(connect(none))

graph export mpw.eps , replace

// use spmdata
// Example ex12
set seed 12345671
poparms (w c.(pindex eindex)##c.(pindex eindex)) 	        ///
	(spmeasure c.(pindex eindex)##c.(pindex eindex)) ,      ///
	quantile(.25 .5 .75) 


// Example ex13
margins i.w , pwcompare predict(equation(#2))


// Example ex13a
margins i.w , pwcompare predict(equation(#3))


// Example ex14
margins i.w , pwcompare predict(equation(#4))



// Joint inference
// Example ex15
test (_b[mean:0.w] = _b[mean:1.w] = _b[mean:2.w])	///
     (_b[q25:0.w] = _b[q25:1.w] = _b[q25:2.w])		///
     (_b[q50:0.w] = _b[q50:1.w] = _b[q50:2.w])		///
     (_b[q75:0.w] = _b[q75:1.w] = _b[q75:2.w])



// Example ex16
test (_b[mean:1.w] - _b[mean:0.w] = _b[mean:2.w] - _b[mean:1.w] )	///
     (_b[q25:1.w] - _b[q25:0.w] = _b[q25:2.w] - _b[q25:1.w] )		///
     (_b[q50:1.w] - _b[q50:0.w] = _b[q50:2.w] - _b[q50:1.w] )		///
     (_b[q75:1.w] - _b[q75:0.w] = _b[q75:2.w] - _b[q75:1.w] )	


// Example ex16a
test _b[mean:1.w] - _b[mean:0.w] = _b[mean:2.w] - _b[mean:1.w] 


// Example ex16b
test _b[q50:1.w] - _b[q50:0.w] = _b[q50:2.w] - _b[q50:1.w] 	

     

// Example ex17
test (_b[mean:0.w] = _b[q50:0.w])	///
     (_b[mean:1.w] = _b[q50:1.w])	///
     (_b[mean:2.w] = _b[q50:2.w])


generate ivalues  = .
label variable ivalues "Treatment level"

local eqn mean q25 q50 q75
local lpl solid dash dot dash_dot
local eqi 1
foreach eq of local eqn {
	generate bvalues_`eq'  = .
	generate ci_low_`eq'   = .
	generate ci_high_`eq'  = .

	local lpat : word `eqi' of `lpl'
	forvalues i=0/2 {
		local ip1 = `i' + 1
		if "`eq'" == "mean" {
			replace ivalues = `i' in `ip1'
		}

		replace bvalues_`eq' = _b[`eq':`i'.w] in `ip1'
		replace ci_low_`eq'  = bvalues_`eq' - invnormal(.975)*_se[`eq':`i'.w] in `ip1'
		replace ci_high_`eq' = bvalues_`eq' + invnormal(.975)*_se[`eq':`i'.w] in `ip1'
	}
	local eq1 " (connected bvalues_`eq' ivalues in 1/3, lpattern(`lpat') msize(*.5) ) "
	local eq2 " (rcap ci_low_`eq' ci_high_`eq' ivalues in 1/3, lcolor(black)) "
	local gcmd "`gcmd' `eq1' `eq2' "
	local ++eqi
}
display `"graph twoway `gcmd' "'
graph twoway `gcmd' , legend(order(1 3 5 7 8))	///
	legend(label( 1 "Mean"))		///
	legend(label( 3 "25th quantile"))	///
	legend(label( 5 "Median"))		///
	legend(label( 7 "75th quantile"))	///
	legend(label( 8 "95% confidence intervals"))	///
	xlabel(0(1)2) ytitle("Parameter estimate")

graph export effects.eps, replace

