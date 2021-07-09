* actest cert script 1.0.13 CFB 24jan2015
cscript actest adofile actest 
clear all
capture log close
set more off
set rmsg on
program drop _all
log using cs_actest,replace
about
which actest

webuse air2, clear
wntestq air, lags(1)
sca twntestq = r(stat)
sca dwntestq = r(df)
actest air, lags(1) bp small
assert reldif(r(chi2), twntestq) < 1e-3
assert r(df) == dwntestq

webuse air2, clear
wntestq air in 1/72, lags(1)
sca twntestq = r(stat)
sca dwntestq = r(df)
actest air in 1/72, lags(1) bp small
assert reldif(r(chi2), twntestq) < 1e-3
assert r(df) == dwntestq

wntestq air, lags(4)
sca twntestq = r(stat)
sca dwntestq = r(df)
actest air, lags(4) bp small
assert reldif(r(chi2), twntestq) < 1e-3
assert r(df) == dwntestq

wntestq air if t>80, lags(4)
sca twntestq = r(stat)
sca dwntestq = r(df)
actest air if t>80, lags(4) bp small
assert reldif(r(chi2), twntestq) < 1e-3
assert r(df) == dwntestq

wntestq D.air, lags(4)
sca twntestq = r(stat)
sca dwntestq = r(df)
actest D.air, lags(4) bp small
assert reldif(r(chi2), twntestq) < 1e-3
assert r(df) == dwntestq

qui reg air time
qui predict double airhat, residual
wntestq airhat, lags(4)
sca twntestq = r(stat)
sca dwntestq = r(df)
actest airhat, lags(4) bp small strict
assert reldif(r(chi2), twntestq) < 1e-3
assert r(df) == dwntestq

drop airhat
qui arima air, ar(2) ma(2)
qui predict double airhat, residual
wntestq airhat, lags(4)
sca twntestq = r(stat)
sca dwntestq = r(df)
actest airhat, lags(4) bp small 
assert reldif(r(chi2), twntestq) < 1e-3
assert r(df) == dwntestq

drop airhat
qui arima air time, ar(2) ma(1)
qui predict double airhat, residual
wntestq airhat, lags(12)
sca twntestq = r(stat)
sca dwntestq = r(df)
actest airhat, lags(12) bp small 
assert reldif(r(chi2), twntestq) < 1e-3
assert r(df) == dwntestq

qui reg air
estat bgodfrey, lags(1)
mata: st_numscalar("tbgod", st_matrix("r(chi2)")[1,1])
mata: st_numscalar("dbgod", st_matrix("r(df)")[1,1])
actest, lags(1)
assert reldif(r(chi2), tbgod) < 1e-3
assert r(df) == dbgod

estat bgodfrey, lags(4)
mata: st_numscalar("tbgod", st_matrix("r(chi2)")[1,1])
mata: st_numscalar("dbgod", st_matrix("r(df)")[1,1])
actest, lags(4)
assert reldif(r(chi2), tbgod) < 1e-3
assert r(df) == dbgod
actest, lags(4) robust

qui reg air L(1/2).air
estat bgodfrey, lags(4)
mata: st_numscalar("tbgod", st_matrix("r(chi2)")[1,1])
mata: st_numscalar("dbgod", st_matrix("r(df)")[1,1])
actest, lags(4)
ret li
assert reldif(r(chi2), tbgod) < 1e-3
assert r(df) == dbgod
actest, lags(3 4)

webuse lutkepohl, clear
qui reg investment L(1/4).income
estat bgodfrey, lags(1/8)
mata: st_matrix("tbgod", st_matrix("r(chi2)")')
actest, lags(8)
mata: st_matrix("abgod", st_matrix("r(results)")[.,3])
forv i=1/8 {
	assert reldif(tbgod[`i',1], abgod[`i',1]) < 1e-4
}

which ivreg2
qui ivreg2 investment (income=L(1/2).income)
actest, lags(3)
actest, lags(3) robust

which abar
qui reg investment income
abar, lags(2)
mat tabar = (r(ar1)^2 * e(N)/e(df_r) \ r(ar2)^2 * e(N)/e(df_r))
actest, lags(2) q0
mata: st_matrix("aabar", st_matrix("r(results)")[.,6])
forv i=1/2 {
	assert reldif(tabar[`i',1], aabar[`i',1]) < 1e-4
}

qui ivreg2 investment income, robust kernel(bartlett) bw(5)
actest, lags(4) q0 robust kernel(bartlett) bw(5)

webuse abdata, clear
qui reg n w k, clu(id)
abar, lags(2)
mat tabar = (r(ar1)^2 \ r(ar2)^2)
actest, lags(2) clu(id)
mata: st_matrix("aabar", st_matrix("r(results)")[.,6])
forv i=1/2 {
	assert reldif(tabar[`i',1], aabar[`i',1]) < 1e-4
}

qui ivreg2 D.n (D.w D.k = D(1/2).(w k)), noco gmm2s clu(id)
actest, lags(3) clu(id)

webuse grunfeld, clear
qui reg invest L(1/2).kstock c.mvalue##i.company
actest
mat res1 = r(results)

g l1k = L1.kstock
g l2k = L2.kstock
xi i.company*mvalue
reg invest l1k l2k mvalue _I*
actest
mat res2 = r(results)
mat diff = res1-res2
mata: st_numscalar("norm", norm(st_matrix("diff"),1))
assert norm < 1e-4

qui reg invest L(1/2).kstock c.mvalue##i.company, clu(company)
actest
mat res1 = r(results)

reg invest l1k l2k mvalue _I*, clu(company)
actest
mat res2 = r(results)
mat diff = res1-res2
mata: st_numscalar("norm", norm(st_matrix("diff"),1))
assert norm < 1e-4

qui reg invest L(1/2).kstock c.mvalue##i.company, clu(year)
actest
mat res1 = r(results)

reg invest l1k l2k mvalue _I*, clu(year)
actest
mat res2 = r(results)
mat diff = res1-res2
mata: st_numscalar("norm", norm(st_matrix("diff"),1))
assert norm < 1e-4

// need to add two-way clustering

log close
set more on
set rmsg off





