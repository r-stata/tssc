// This do-file does some butn not all the examples in 
//    Cattaneo, Drukker and Holland (2012)
// Estimation of Multivalued Treatment Effects under Conditional Independence
// http://www-personal.umich.edu/~cattaneo/papers/Cattaneo-Drukker-Holland_2012_STATA.pdf
//    
// This version also uses only 50 repetitions for the bootstrapped standard
//  errors which is strictly for example purposes.  We recommend using 
//  at least 2000 repetitions in practice.

version 12.1
clear all
set more off
mata: mata mlib index

use spmdata
bfit logit w pindex eindex, corder(3) base(0) sort(aic)

predict double (phat0 phat1 phat2), pr
sort w
by w: summarize phat0 phat1 phat2

bfit regress spmeasure pindex eindex, corder(3) 

poparms (w c.(pindex eindex)##c.(pindex eindex)) 	///
	(spmeasure c.(pindex eindex)##c.(pindex eindex)) 	

poparms  , coeflegend
contrast ar.w, nowald

contrast r.w, nowald

margins i.w, pwcompare
marginsplot, unique plotopts(connect(none))

set seed 12345671
poparms (w c.(pindex eindex)##c.(pindex eindex)) 	        ///
	(spmeasure c.(pindex eindex)##c.(pindex eindex)) ,      ///
	quantile(.25 .5 .75) vce(bootstrap, reps(50))

margins i.w , pwcompare predict(equation(#2))

margins i.w , pwcompare predict(equation(#3))

margins i.w , pwcompare predict(equation(#4))


