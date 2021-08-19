*! version 2.2  01feb2020  Matteo Pinna, matteo.pinna@gess.ethz.ch

/*
This work is licensed under a Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License.  
The full legal text as well as a human-readable summary can be accessed at http://creativecommons.org/licenses/by-nc-sa/4.0/
*/

* Any feedback on issues and possible additions is very welcome.

* This program is based on the original binscatter by Michael Stepner (2013): "BINSCATTER: Stata module to generate binned scatterplots" - https://EconPapers.repec.org/RePEc:boc:bocode:s457709 and uses Ben Jann (2014): "ADDPLOT: Stata module to add twoway plot objects to an existing twoway graph," Statistical Software Components S457917, Boston College Department of Economics, revised 28 Jan 2015 <https://ideas.repec.org/c/boc/bocode/s457917.html>

/* WORKING EXAMPLE */
clear all

cd /Users/matteop/Dropbox/a_projects/stata_programs/binscatterhist/working_example
webuse nlsw88, clear

* cd ../binscatterhist_1.4/working_example/

* The basic binscatterhist works exactly as binscatter
binscatterhist wage tenure
graph export "example1.png", replace

* Let's add the distribution of the x variable tenure
binscatterhist wage tenure, histogram(tenure) 
graph export "example2.png", replace

* The default position of the x graph is not pleasant, let's fix that and add both variables distribution this time
binscatterhist wage tenure, histogram(wage tenure) ymin(4)
graph export "example3.png", replace

* We want to experiment with the look, let's try a simpler look and a smaller width
binscatterhist wage tenure, histogram(wage tenure) ymin(4) yhistbarwidth(50) xhistbarwidth(50) ybstyle(outline) xbstyle(outline)
graph export "example4.png", replace

* Let's now try some further options: increasing number of bins and height of the x and y distribution
binscatterhist wage tenure, histogram(wage tenure) ymin(4) xhistbarheight(15) yhistbarheight(15) xhistbins(40) yhistbins(40)
graph export "example5.png", replace

* Let's further report estimation results, using robust standard errors and with grade fixed effects
binscatterhist wage tenure, absorb(grade) vce(robust) coef(0.01) sample xmin(-2.2) ymin(5) histogram(wage tenure)  xhistbarheight(15) yhistbarheight(15) xhistbins(40) yhistbins(40)
graph export "example6.png", replace

* Let's use now areg - therefore keeping singleton fixed effects. With a negative slope, the reported coefficient and sample adjust automatically their position
replace tenure=-tenure
binscatterhist wage tenure, regtype(areg) absorb(grade) vce(robust) coef(0.01) sample xmin(-22) ymin(5) histogram(wage tenure)  xhistbarheight(15) yhistbarheight(15) xhistbins(40) yhistbins(40)
graph export "example7.png", replace










