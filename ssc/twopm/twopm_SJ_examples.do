* twopm: Estimating two-part models
* Federico Belotti, Partha Deb, Willard G. Manning, Edward C. Norton
* Stata Journal
* This .do file shows the two examples for -twopm-.

clear all
set more off
set scheme sj

* Data
sjlog using twopm_setup, replace
* Use MEPS data on health care expenditures
use http://www.econometrics.it/stata/data/meps_ashe_subset5.dta, clear
svyset [pweight=wtdper], strata(varstr) psu(varpsu)
sjlog close, replace

sjlog using twopm_sumstats, replace
* Summarize data
svy: mean exp_tot age female
sjlog close, replace


* GLM
sjlog using twopm_glm, replace
* Two-part model, with probit first part and GLM second part
svy: twopm exp_tot c.age i.female, f(probit) s(glm, family(gamma) link(log))
sjlog close, replace

sjlog using twopm_glm_yhat, replace
* Overall conditional mean
margins
sjlog close, replace

sjlog using twopm_glm_test, replace
* Test whether coefficients on interaction terms are jointly zero
test age
test 1.female
sjlog close, replace

sjlog using twopm_glm_me, replace
* Marginal effects, averaged over the sample
margins, dydx(*)
sjlog close, replace

sjlog using twopm_glm_mebyage, replace
* Marginal effects at different ages
margins, dydx(*) at(age=(20(20)80)) 
sjlog close, replace


* OLS
sjlog using twopm_ols, replace
* Two-part model, with logit first part and OLS second part
twopm exp_tot c.age i.female, f(logit) s(regress, log)
sjlog close, replace

sjlog using twopm_ols_yhat, replace
* Overall conditional mean
margins, predict(duan) post
sjlog close, replace

sjlog using twopm_ols_yhatboot, replace
* Overall conditional mean
capture program drop Ey_boot
program define Ey_boot, eclass
	twopm exp_tot c.age i.female, f(logit) s(regress, log)
	margins, predict(duan) nose post
end
bootstrap _b, seed(14) reps(1000): Ey_boot
sjlog close, replace

sjlog using twopm_ols_meboot, replace
* Marginal effects, averaged over the sample
capture program drop dydx_boot
program define dydx_boot, eclass
	twopm exp_tot c.age i.female, f(logit) s(regress, log)
	margins, dydx(*) predict(duan) nose post
end
bootstrap _b, seed(14) reps(1000): dydx_boot
sjlog close, replace
