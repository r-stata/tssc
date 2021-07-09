clear all
set more off

use http://urban.hunter.cuny.edu/~deb/Stata/datasets/mepssmall.dta

gen lntotexp = ln(totexp)
gen anyuse = totexp>0

mtreatreg lntotexp age female minority education nchroniccond ///
	, mtreat(instype = age female minority education nchroniccond firmsize govtjob) ///
	density(normal) sim(100) basecat(ffs) robust
predict yhat if e(sample)
sum lntotexp yhat if e(sample)
drop yhat
mfx, force

mtreatreg totexp age female minority education nchroniccond if totexp>0 ///
	, mtreat(instype = age female minority education nchroniccond firmsize govtjob) ///
	density(gamma) sim(100) basecat(ffs) robust
predict yhat if e(sample)
predict yhat1 if e(sample), at(0.5, 0.5)
sum totexp yhat* if e(sample)
drop yhat*
mfx, force

mtreatreg docvis age female minority education nchroniccond ///
	, mtreat(instype = age female minority education nchroniccond firmsize govtjob) ///
	density(negbin2) sim(100) basecat(ffs) robust
predict yhat if e(sample)
predict yhat1 if e(sample), at(-0.5, 0.5)
sum docvis yhat* if e(sample)
drop yhat*
mfx, force

mtreatreg anyuse age female minority education nchroniccond ///
	, mtreat(instype = age female minority education nchroniccond firmsize govtjob) ///
	density(logit) sim(100) basecat(ffs) robust
predict yhat if e(sample)
sum anyuse yhat if e(sample)
drop yhat
mfx, force
