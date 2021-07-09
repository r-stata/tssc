**************************************
* Data
**************************************
* The data used in the examples can be downloaded after registration from The DHS Program website: 
* http://www.dhsprogram.com/data/dataset_admin/login_main.cfm?logout=&CFID=8679569&CFTOKEN=40f990b41b421b7e-9C675AF9-9325-ECB7-18E9AA5A272CE050 .

**************************************
* Indices in Table 1 for healthexp:
**************************************
use "CDHS2010hh.dta", clear
sum healthexp [aweight=sampweight_hh]
xtile wealthquint_hh = wealthindex [pweight=sampweight_hh], n(5)
graph bar (mean) healthexp [pweight = sampweight_hh], over(wealthquint_hh)
conindex healthexp [aweight=sampweight_hh], rankvar(wealthindex) truezero cluster(PSU) graph ytitle(Cumulative share of healthexp) xtitle(Fractional Income rank)
conindex healthexp [aweight=sampweight_hh], rankvar(wealthindex) generalized truezero cluster(PSU) 
conindex healthexp [aweight=sampweight_hh], rankvar(wealthindex) v(1.5) truezero cluster(PSU)
conindex healthexp [aweight=sampweight_hh], rankvar(wealthindex) v(5) truezero cluster(PSU)
conindex healthexp [aweight=sampweight_hh], rankvar(wealthindex) beta(1.5) truezero cluster(PSU)
conindex healthexp [aweight=sampweight_hh], rankvar(wealthindex) beta(5) truezero cluster(PSU)

**************************************
* Indices in Table 1 for u1mr/u1sr:
**************************************
use "CDHS2010kids.dta", clear
sum u1mr [aweight=sampweight]
xtile wealthquint = wealthindex [pweight=sampweight], n(5)
graph bar (mean) u1mr [pweight = sampweight], over(wealthquint)
gen u1sr=1-u1mr
conindex u1mr [aweight=sampweight], rankvar(wealthindex) truezero cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) truezero cluster(PSU) 
conindex u1mr [aweight=sampweight], rankvar(wealthindex) generalized truezero cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) generalized truezero cluster(PSU) 

conindex u1mr [aweight=sampweight], rankvar(wealthindex) erreygers bounded limits(0 1) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) erreygers bounded limits(0 1) cluster(PSU) 
conindex u1mr [aweight=sampweight], rankvar(wealthindex) wagstaff bounded limits(0 1) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) wagstaff bounded limits(0 1) cluster(PSU) 

conindex u1mr [aweight=sampweight], rankvar(wealthindex) truezero v(1.5) cluster(PSU) 
conindex u1mr [aweight=sampweight], rankvar(wealthindex) truezero beta(1.5) cluster(PSU) 
conindex u1mr [aweight=sampweight], rankvar(wealthindex) truezero v(5) cluster(PSU) 
conindex u1mr [aweight=sampweight], rankvar(wealthindex) truezero beta(5) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) truezero v(1.5) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) truezero beta(1.5) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) truezero v(5) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) truezero beta(5) cluster(PSU) 

conindex u1mr [aweight=sampweight], rankvar(wealthindex) generalized truezero v(1.5) cluster(PSU) 
conindex u1mr [aweight=sampweight], rankvar(wealthindex) generalized truezero beta(1.5) cluster(PSU) 
conindex u1mr [aweight=sampweight], rankvar(wealthindex) generalized truezero v(5) cluster(PSU) 
conindex u1mr [aweight=sampweight], rankvar(wealthindex) generalized truezero beta(5) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) generalized truezero v(1.5) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) generalized truezero beta(1.5) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) generalized truezero v(5) cluster(PSU) 
conindex u1sr [aweight=sampweight], rankvar(wealthindex) generalized truezero beta(5) cluster(PSU) 

******************
* Compare Option:
******************
conindex u1mr [aweight=sampweight], rankvar(wealthindex) erreygers bounded limits(0 1) cluster(PSU) compare(urban)
bys urban: conindex u1mr [aweight=sampweight], rankvar(wealthindex) erreygers bounded limits(0 1) cluster(PSU) 
