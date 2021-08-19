
*** This file tests the egen function _gwmean (weighted, byable, arithmetic, geometric and harmonic means)
*** 20 March 2021, Gueorgui I. Kolev

sysuse auto, clear

keep foreign price weight

* Introduce some missing, and negative values

sort foreign

replace price = . in 1/4

replace weight = . in 4/7

replace price = -price in -3/l

egen arimean = wmean(price), by(foreign) weights(weight) label // the default is Arithmetic mean, 
//Weights can be abbreviated to w. Option Label can be abbreviated to l, and labels the new generated variable. 

egen geomean = wmean(price), by(foreign) w(weight) geometric 
							// Geometric mean option can be abbreviated to g. 

egen harmean = wmean(price), by(foreign) w(weight) harmonic label // Harmonic mean option can be 
							// abbreviated to h. 

* The native Stata's -ameans- calculate on this data the same Arithmetic, 
* Geometric, and Harmonic means as our -egen, wmean- function above. 

by foreign: ameans price [aw=weight]

tabstat arimean geomean harmean, by(foreign) stat(mean count) notot 

* And an example where the argument of the function is a general expression, and with If and In.

egen arimeanexpre = wmean(log(price)*price) if weight>3000 in 10/l, by(foreign) weights(weight) label




