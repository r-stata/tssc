log using apc_example.log, replace

*replicate table 5 and cols 7-9 of table 3 in Yang, Fu and Land (2004)

*Stata can maximize GLM objective functions using two different numerical
*optimization methods: Newton-Raphson (NR) and iterative reweighted least
*squares (IRLS). NR is the default in Stata. However, NR presents a 
*problem in replicating Yang, Fu and Land: The paper set the scale 
*parameter equal to the deviance divided by the residual degrees of 
*freedom, but Stata allows this scale parameter only with IRLS and not 
*with NR. So, we show two sets of results below:
*   1. NR optimization with scale parameter=Pearson chi-squared/residual df
*   2. IRLS optimization with scale parameter=deviance/residual df
*Version 1 is basically the default in Stata. Version 2 matches what was
*done in the paper. The results are numerically identical to the number of
*decimal places shown in the paper.

use apc_example_data.dta

*first, using Newton-Raphson optimization (the default in Stata) and scale(x2)
* (scale parameter = Pearson chi-squared / residual degrees of freedom)
#delim ;
apc_ie death_f if age<=90,
  age(age) period(year) cohort(cohort) family(poisson) link(log) 
  exposure(exp_f) scale(x2);
apc_cglim death_f if age<=90,
  age(age) period(year) cohort(cohort)
  agepfx("_A") periodpfx("_P") cohortpfx("_C")
  family(poisson) link(log) 
  exposure(exp_f) scale(x2) constraint("a5=a10");
drop _A* _P* _C*;
apc_cglim death_f if age<=90,
  age(age) period(year) cohort(cohort)
  agepfx("_A") periodpfx("_P") cohortpfx("_C")
  family(poisson) link(log) 
  exposure(exp_f) scale(x2) constraint("p1965=p1960");
drop _A* _P* _C*;
apc_cglim death_f if age<=90,
  age(age) period(year) cohort(cohort)
  agepfx("_A") periodpfx("_P") cohortpfx("_C")
  family(poisson) link(log) 
  exposure(exp_f) scale(x2) constraint("c1995=c1990");
drop _A* _P* _C*;
#delim cr

*next, using IRLS optimization (the default in S-Plus) and scale(dev)
* (scale parameter = deviance / residual degrees of freedom)
#delim ;
apc_ie death_f if age<=90,
  age(age) period(year) cohort(cohort) family(poisson) link(log) 
  exposure(exp_f) scale(dev) irls;
apc_cglim death_f if age<=90,
  age(age) period(year) cohort(cohort)
  agepfx("_A") periodpfx("_P") cohortpfx("_C")
  family(poisson) link(log) 
  exposure(exp_f) scale(dev) irls constraint("a5=a10");
drop _A* _P* _C*;
apc_cglim death_f if age<=90,
  age(age) period(year) cohort(cohort)
  agepfx("_A") periodpfx("_P") cohortpfx("_C")
  family(poisson) link(log) 
  exposure(exp_f) scale(dev) irls constraint("p1965=p1960");
drop _A* _P* _C*;
apc_cglim death_f if age<=90,
  age(age) period(year) cohort(cohort)
  agepfx("_A") periodpfx("_P") cohortpfx("_C")
  family(poisson) link(log) 
  exposure(exp_f) scale(dev) irls constraint("c1995=c1990");
drop _A* _P* _C*;
#delim cr


log close
exit
