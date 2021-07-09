* Run several examples
set more off
version 10.0

* 1. Store regression results in the active dataset:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave
 cf _all using "examp1.dta"


* 2. Store regression results in a file:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave using results, tstat covar(mpg trunk) replace
 use results, clear
 cf _all using "examp2.dta"

* 3. Store regression results in table form:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave, tstat pval table(regression_1, parentheses(stderr) brackets(tstat pval))
 cf _all using "examp3.dta"

* 4. Store a user-created statistic and label a series of regressions:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length if gear_ratio > 3
 regsave using results, addlabel(scenario, gear ratio > 3, dataset, auto) replace
 regress price mpg trunk headroom length if gear_ratio <= 3
 regsave using results, addlabel(scenario, gear ratio <=3, dataset, auto) append
 use "results", clear
 cf _all using "examp4.dta"

* 5. Store regression results and add coefficient and standard error estimates for an additional variable:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 local mycoef = _b[mpg]*5
 local mystderr = _se[mpg]*5
 regsave, addvar(mpg_5, `mycoef', `mystderr')
 cf _all using "examp5.dta"


* 6. Run a series of regressions and outsheet them into a text file that can be opened by MS Excel:

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave mpg trunk using results, table(OLS_stderr, order(regvars r2)) replace
 regress price mpg trunk headroom length, robust
 regsave mpg trunk using results, table(Robust_stderr, order(regvars r2)) append
 use results, clear
 cf _all using "examp6.dta"


* 7. Run a series of regressions and output the results in a nice LaTeX format that can be opened by Scientific Word. (This example requires the user-written command {help texsave:texsave to be installed.):

 sysuse auto.dta, clear
 regress price mpg trunk headroom length
 regsave mpg trunk using results, table(OLS, order(regvars r2) format(%5.3f) parentheses(stderr) asterisk()) replace
 regress price mpg trunk headroom length, robust
 regsave mpg trunk using results, table(Robust, order(regvars r2) format(%5.3f) parentheses(stderr) asterisk()) append
 use results, clear
 replace var = subinstr(var,"_coef","",.)
 replace var = "" if strpos(var,"_stderr")!=0
 replace var = "R-squared" if var == "r2"
 rename var Variable
 cf _all using "examp7.dta"

* Test time series notation for one lag
sysuse "tsline1.dta", clear
regress ar L.ar F1.ma S1.ma
regsave L1.ar F1.ma S1.ma using results, replace addlabel(Scen, 1)
regress ar L1.ar F.ma S.ma
regsave L.ar F.ma S.ma using results, append addlabel(Scen, 2)
use results, clear
cf _all using "ts0.dta"

* Test the order option, with time series variables and an added var
sysuse "tsline1.dta", clear
regress ar S2.ar
local mycoef = _b[S2.ar]*5
local mystderr = _se[S2.ar]*5
regsave, addvar(mpg 5, `mycoef', `mystderr')
cf _all using "ts1.dta"
regsave S2.ar, addvar(mpg 5 somebad^&chars and a very long name, `mycoef', `mystderr') table(my_tbl, order(_cons))
cf _all using "ts2.dta"
regsave S2.ar using results, addvar(mpg 5, `mycoef', `mystderr') table(my_tbl, order(_cons)) replace		
regsave S2.ar using results, table(my_tbl2, order(S2.ar r2 mpg)) append
use results, clear
cf _all using "ts3.dta"

* Equation example
sysuse auto, clear
gen selection = trunk>15
heckman price mpg, select(selection = rep78)
regsave mpg rep78, table(eqtbl)
cf _all using "eq.dta"

* Wildcard example
sysuse auto, clear
tempfile t
regress price mpg rep78 headroom trunk turn
regsave t* mpg-headroom using "`t'", replace
use "`t'", clear
cf _all using "wildcards.dta"

* Dprobit and coef/varmat examples
sysuse auto, clear
gen bin = price>8000
dprobit bin trunk mpg
regsave using "`t'", replace addlabel(Scenario, dfdx)
regsave using "`t'", coefmat(e(b)) varmat(e(V)) addlabel(Scenario, std) append
nlcom (ratio: _b[trunk]/_b[mpg])
regsave using "`t'", coefmat(r(b)) varmat(r(V)) addlabel(Scenario, nlcom) append
use "`t'", clear
cf _all using "dprobit.dta"

* Asterisk examples
sysuse auto.dta, clear
regress price mpg trunk headroom length
regsave mpg trunk, table(OLS, order(regvars r2) format(%5.3f) parentheses(pval) asterisk(30 15)) pval
cf _all using "asterisk.dta"

* ci examples
sysuse auto.dta, clear
regress price mpg trunk headroom length, level(80)
regsave mpg trunk, ci level(80) table(OLS, order(regvars r2) format(%5.3f) brackets(stderr))



** EOF

