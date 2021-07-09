// ANALYSE OVERALL
use MIsim, clear
l in 1/9, sepby(dataset)
summ 
simsum b, se(se) methodvar(method) id(dataset) true(0.5) mcse format(%7.0g)
