* egranger cert script 1.0.0 ms 20101202
set more off
cscript egranger adofile egranger
capture log close
log using cs_egranger, replace smcl
which egranger
version

* average per-capita disposable personal income dataset
use http://www.stata-press.com/data/r9/rdinc, clear

* T is zero in the first period (lost in 2nd step and test regressions)
gen t=_n-1
gen tsq=t^2

* Cointegration test

egranger ln_ne ln_se, regress
scalar Zt=e(Zt)
capture drop resid
regress ln_ne ln_se
predict double resid, res
regress D.resid L.resid, nocons
qui test L.resid
assert reldif(abs(Zt),sqrt(r(F))) < 1e-8

egranger ln_ne ln_se, lags(2) regress
scalar Zt=e(Zt)
capture drop resid
regress ln_ne ln_se
predict double resid, res
regress D.resid L.resid L(1/2)D.resid, nocons
qui test L.resid
assert reldif(abs(Zt),sqrt(r(F))) < 1e-8

egranger ln_ne ln_se ln_me, lags(2) regress
scalar Zt=e(Zt)
capture drop resid
regress ln_ne ln_se ln_me
predict double resid, res
regress D.resid L.resid L(1/2)D.resid, nocons
qui test L.resid
assert reldif(abs(Zt),sqrt(r(F))) < 1e-8

egranger ln_ne ln_se, lags(3) regress trend
scalar Zt=e(Zt)
capture drop resid
regress ln_ne ln_se t
predict double resid, res
regress D.resid L.resid L(1/3)D.resid, nocons
qui test L.resid
assert reldif(abs(Zt),sqrt(r(F))) < 1e-8

egranger ln_ne ln_se ln_me, lags(4) regress qtrend
scalar Zt=e(Zt)
capture drop resid
regress ln_ne ln_se ln_me t tsq
predict double resid, res
regress D.resid L.resid L(1/4)D.resid, nocons
qui test L.resid
assert reldif(abs(Zt),sqrt(r(F))) < 1e-8

* 2-step ECM

egranger ln_ne ln_se, regress ecm
savedresults save eg e()
capture drop resid
regress ln_ne ln_se
predict double resid, res
regress D.ln_ne L.resid D.ln_se
savedresults comp eg e(), include(macros: depvar scalar: ll matrix: b V) tol(1e-7) verbose

egranger ln_ne ln_se, lags(2) regress ecm
savedresults save eg e()
capture drop resid
regress ln_ne ln_se
predict double resid, res
regress D.ln_ne L.resid D.ln_se L(1/2)D.(ln_ne ln_se)
savedresults comp eg e(), include(macros: depvar scalar: ll matrix: b V) tol(1e-7) verbose

egranger ln_ne ln_se ln_me, lags(2) regress ecm
savedresults save eg e()
capture drop resid
regress ln_ne ln_se ln_me
predict double resid, res
regress D.ln_ne L.resid D.(ln_se ln_me) L(1/2)D.(ln_ne ln_se ln_me)
savedresults comp eg e(), include(macros: depvar scalar: ll matrix: b V) tol(1e-7) verbose

egranger ln_ne ln_se, lags(3) regress trend ecm
savedresults save eg e()
capture drop resid
regress ln_ne ln_se t
predict double resid, res
regress D.ln_ne L.resid D.ln_se L(1/3)D.(ln_ne ln_se)
savedresults comp eg e(), include(macros: depvar scalar: ll matrix: b V) tol(1e-7) verbose

egranger ln_ne ln_se ln_me, lags(4) regress qtrend ecm
savedresults save eg e()
capture drop resid
regress ln_ne ln_se ln_me t tsq
predict double resid, res
regress D.ln_ne L.resid D.(ln_se ln_me) L(1/4)D.(ln_ne ln_se ln_me)
savedresults comp eg e(), include(macros: depvar scalar: ll matrix: b V) tol(1e-7) verbose

log close
