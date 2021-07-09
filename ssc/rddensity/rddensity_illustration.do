********************************************************************************
** RDDENSITY Stata Package  
** Do-file for Empirical Illustration
** Authors: Matias D. Cattaneo, Michael Jansson and Xinwei Ma
** 14-Jul-2019
********************************************************************************
** hlp2winpdf, cdn(rddensity) replace
** hlp2winpdf, cdn(rdbwdensity) replace
********************************************************************************
** net install rddensity, from(https://sites.google.com/site/rdpackages/rddensity/stata) replace
********************************************************************************
clear all
set more off
set linesize 200

********************************************************************************
** Summary Stats
********************************************************************************
use rddensity_senate.dta, clear
sum margin

********************************************************************************
** rddensity: default options
********************************************************************************
rddensity margin

********************************************************************************
** rddensity: with plot
********************************************************************************
net install lpdensity, from(https://sites.google.com/site/nppackages/lpdensity/stata) replace
rddensity margin, plot
graph export output/figure1.pdf, replace

********************************************************************************
** rddensity: with plot and graph_options
********************************************************************************
rddensity margin, plot ///
                  graph_options(graphregion(color(white)) ///
				  xtitle("Margin of Victory") ytitle("Density") legend(off))
graph export output/figure2.pdf, replace

********************************************************************************
** rddensity: all statistics & default options
********************************************************************************
rddensity margin, all

********************************************************************************
** rddensity: default statistic, restricted model & plugin standard errors
********************************************************************************
rddensity margin, fitselect(restricted) vce(plugin)

********************************************************************************
** rdbwdensity: default options
********************************************************************************
rdbwdensity margin

********************************************************************************
** rdbwdensity: compute bandwidth and then use them
********************************************************************************
qui rdbwdensity margin
mat h = e(h)
local hr = h[2,1]
rddensity margin, h(10 `hr')

********************************************************************************
** Other examples
********************************************************************************
rddensity margin, kernel(uniform)
rddensity margin, bwselect(diff)
rddensity margin, h(10 15)
rddensity margin, p(2) q(4)
rddensity margin, c(5) all

rdbwdensity margin, p(3) fitselect(restricted)
rdbwdensity margin, kernel(uniform) vce(jackknife)



