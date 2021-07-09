/*
Paper: Effect of tobacco control policies on the Swedish Smoking Quitline using intervention time series analysis. BMJ Open.
Authors: Xingwu Zhou, Alessio Crippa, Anna-Karin Danielsson, Rosaria Galanti, and Nicola Orsini
Affiliation: Department of Public Health Sciences, Karolinska Institutet
Goal: This do-file can be useful to reproduce the results 
Author: Orsini N
Date: October 17, 2019
*/

* Open the dataset 
preserve 

use http://www.stats4life.se/data/quitline, clear
tsset time, monthly

* Evaluation of the effect of the EU Directive on May 2016 (Figure 1)

keep if inrange(time, 625, 691)

* Generate transformations of time to be used in the Poisson model

* Splines of degree 0 and 1 with a knot at the intervention time of 676 (May 2016)

gen s0676 = (time>676)
gen s1676 = (time>676)*(time-676)

* Fourier transformations 
* degrees variable for time divided by the number of time points in a year (i.e. 12 for months)
gen degrees=(time/12)*360
fourier degrees, n(3)

* Poisson model considering seasonality, change in level at the intervention, and change in linear trends

glm call cos_* sin_*  time s0676 s1676, fam(poisson) lnoffset(pop) link(log) scale(x2)

* Shift at the intervention 
lincom s0676, eform

* Linear trend before intervention (per year)
lincom time*12, eform

* Linear trend after intervention (per year)
lincom (time+s1676)*12, eform 

* Graph the predicted rates over a fine grid of time values

set obs 500
range timef 625 691
capture drop cos_* sin_*
capture drop degreesf
gen degreesf=(timef/12)*360
fourier degreesf, n(3)

capture drop s0676 s1676
gen s0676 = (timef>676)
gen s1676 = (timef>676)*(timef-676)
 
predictnl fitc3 = _b[_cons] + _b[cos_1]*cos_1+ _b[cos_2]*cos_2  + _b[cos_3]*cos_3 ///
+ _b[sin_1]*sin_1+ _b[sin_2]*sin_2 + _b[sin_3]*sin_3  + _b[time]*timef
 
 replace fitc3  = exp(fitc3)*10^5
 
predictnl fitp3 = _b[_cons] + _b[cos_1]*cos_1+ _b[cos_2]*cos_2  + _b[cos_3]*cos_3 ///
+ _b[sin_1]*sin_1+ _b[sin_2]*sin_2 + _b[sin_3]*sin_3  + _b[time]*timef + _b[s0676]*s0676+ _b[s1676]*s1676

replace fitp3 = exp(fitp3)*10^5

 * Fix transformations at April  -.0608104   -.9926042    .1815316    .9981493   -.1213956   -.9833851

predictnl fitc31 = _b[_cons] + _b[cos_1]* -.0608104  + _b[cos_2]* -.9926042 + _b[cos_3]*   .1815316     ///
+ _b[sin_1]* .9981493  + _b[sin_2]*-.1213956 + _b[sin_3]* -.9833851 + _b[time]*timef

predictnl fitc32 = _b[_cons] + _b[cos_1]* -.0608104  + _b[cos_2]* -.9926042 + _b[cos_3]*   .1815316     ///
+ _b[sin_1]* .9981493  + _b[sin_2]*-.1213956 + _b[sin_3]* -.983385 + _b[time]*timef + _b[s0676]*s0676+ _b[s1676]*s1676
 
replace fitc31  = exp(fitc31)*10^5
replace fitc32  = exp(fitc32)*10^5

gen low = 40
gen high = 120

twoway ///
(rarea low high timef if inrange(timef,676, .), color(gs14) ) ///
(scatter rate time, ms(o) c(l) mc(black) msize(small) lp(dot) lw(vthin) lc(black)) ///   
(line fitp3 timef if timef >= 676.6, sort lc(blue) ) ///  
(line fitc3 timef if timef <= 676, sort lc(blue)) /// 
(line fitc31 timef if timef <= 676, sort lc(red)) ///  
(line fitc31 timef if timef >= 677, sort lp(dash) lc(red)) ///  
(line fitc32 timef if timef >= 676.8, sort lc(red)) ///  
, plotregion(style(none)) scheme(s1mono) ///
ytitle("Calling rates per 100,000 smokers") ///
xtitle("Calendar time") ylabel(#5, angle(horiz)) ///
xlabel(625(3)691, angle(45) format(%tm) ) xmtick(625(1)691) legend(off)  name(figure1, replace)

restore
