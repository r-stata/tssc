clear all
set more off
capture log close

// install the package with additional files
ssc install xtprobitunbal, all replace

log using exportunbal.log, replace

// load data
sysuse exportunbal

// estimate model
xtprobitunbal export size trend med_skill age, meansvars(size med_skill)

// marginal effect of the lagged dependent variable
mgf_unbal, dydx(lag)

// marginal effect of the lagged dependent variable
//  for observations whose initial status is not being an exporter
sort id time
qby id: gen int YY0=export[1]
mgf_unbal if YY0==0, dydx(lag)

// marginal effect of a continuous change in an exogenous explanatory variable
mgf_unbal, dydx(c.med_skill) 

// marginal effect of discrete change, from 2 to 3, in an exogenous explanatory variable
mgf_unbal, dydx(d.age) val0(2) val1(3)


log close
