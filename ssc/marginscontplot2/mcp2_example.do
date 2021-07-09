/*
	Example of using marginscontplot2 for graphical comparison of
	margins for two diffeent models, linear and quadratic.
	Patrick Royston, 04jan2018.
*/
sysuse auto, clear

* Define (e.g.) 20 equally spaced plotting values of predictor weight
quietly summarize weight
range w1 r(min) r(max) 20

* Fit model linear in weight and save margins to file flin.dta.
regress mpg weight i.foreign
marginscontplot2 weight, var1(w1) ci saving(flin,replace) prefix(lin)

* Fit model quadratic in weight and save margins to file fquad.dta.
gen w2 = weight^2
regress mpg weight w2 i.foreign

gen w1a = w1
gen w1b = w1^2
marginscontplot2 weight (weight w2), var1(w1 (w1a w1b)) ci saving(fquad,replace) prefix(quad)

use fquad, clear
lab var quad_margin "Quadratic"
save fquad,replace

use flin, clear
lab var lin_margin "Linear"
save flin,replace

* Merge files and plot margins against "weight"
 merge 1:1 _n using fquad
line lin_margin quad_margin weight

* Note: Could include pointwise confidence intervals in plot if desired.
