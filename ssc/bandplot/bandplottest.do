sysuse auto, clear
capture erase results.dta 
bandplot mpg foreign rep78 weight, cat(for rep) 
more 
bandplot mpg foreign rep78 weight, cont(weight) 
more 
bandplot mpg foreign rep78 weight, cont(weight) missing 
more 
bandplot mpg foreign rep78 weight, cont(weight) missing dta(results) 
more 
bandplot mpg foreign rep78 weight, cont(weight) missing nq(8) dta(results, replace) 
more 
bandplot mpg foreign rep78 weight, cont(weight) missing nq(8) s(mean p50) legend(order(1 "mean" 2 "median")) marker(1, ms(Sh)) marker(2, ms(Dh)) 
more  
bandplot (trunk turn) foreign rep78 weight, cont(weight) yvarlabels 
more 
bandplot (trunk turn) foreign rep78 weight, cont(weight) yvarlabels xvarlabels marker(1, ms(Sh)) marker(2, ms(Dh))  
more 
bandplot (trunk turn) foreign rep78 weight, cont(weight) number yvarlabels xopts(relabel(1 `" "Car" "type" "' 2 `" "Repair" "record" "1978" "' 3 `" "Weight" "(lb)" "'))   
more 
bandplot (trunk turn) foreign rep78 weight, cont(weight) number yvarlabels xopts(relabel(1 `" "Car" "type" "' 2 `" "Repair" "record" "1978" "' 3 `" "Weight" "(lb)" "'))  recast(hbar)
more  
bandplot (trunk turn) foreign rep78 weight, cont(weight) number yvarlabels xopts(relabel(1 `" "Car" "type" "' 2 `" "Repair" "record" "1978" "' 3 `" "Weight" "(lb)" "')) bandopts(label(labsize(*0.8))) 
more 




