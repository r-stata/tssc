
// it is important to install SPost first to make sure 
// that all grcompare commands work as the latter uses
// some low utility program from SPost

clear all
set more off
cap log close
log using grcompare.log, replace

// install SPost first
// net from http://www.indiana.edu/~jslsoc/stata/
// net install spost9_ado, force
adopath + d:\project\stat\brgc\grcompare

// read in data binlfp2.dta
use binlfp2.dta, clear
logit _all


// difference in group ageraved probabilities
grdigap, group(wc 0 1) reps(1000) dots

// difference in difference in predicted probabilities
grdidip, x4(wc=1 k5=3) x3(wc=0 k5=3) x2(wc=1 k5=0) x1(wc=0 k5=0)

// difference in group averaged marginal effect
grdiame, group(wc 0 1)

// averaged differences in predicted probabilities
gradip age, group(wc 0 1) from(30) to(60) reps(1000) dots

// difference in local marginal effects
grmarg, x(wc=0) rest(min) save
grmarg, x(wc=1) rest(max) diff

// grmarg, x(wc=0) rest(min) save reps(500) dots
// grmarg, x(wc=1) rest(max) diff reps(500) dots

// graph


use binlfp2.dta, clear
logit _all
set more off
cap drop dagex 
cap mat drop dmargraph
gen dagex = .
loc k = 1
forval i=30(5)60   {
    loc nowage = (`k'+5)*5 
    replace dagex = `nowage' if _n==`k'
    _grmargd, x(wc=0 age=`nowage') save 
    _grmargd, x(wc=1 age=`nowage') diff
    
    // ret list
    // pause whatever
    
    mat dmargci = r(dmargci)
    sca dagelo = dmargci[3, 1]
    sca dage   = dmargci[3,2]
    sca dagehi = dmargci[3, 3]
    mat dmargraph = nullmat(dmargraph) \ dagelo, dage, dagehi
    
    loc ++k

}

mat list dmargraph
svmat dmargraph
graph twoway connected dmargraph1 dmargraph2 dmargraph3 dagex, /// 
lpattern(dash solid dash) clc(gs8 gs8 gs8) msymbol(none T none) mcolor(gs8 gs8 gs8) ///
xlabel(30(5)60, val labsize(small)) xtitle("Age",size(small)) ///
legend(col(1) textwidth(5) label(2 "College Wife-Non College Wife Differences in Marginal Effects") label(1 "95% Lower End") label(3 "95% Upper End"))    ///
title("Figure 1 College Wife - Non College Wife Differences in Marginal Effects",size(medsmall)) /// yt("Differences in Marginal Effects (dp/dx)") 
yline(0)
graph export example-fig001.wmf, replace as(wmf)

log close

