* Program to reproduce the some results from Blundell-Bond 1998, as revised in "bbest1.out" in http://www.doornik.com/download/dpdox121.zip.
clear all
set matsize 800
use "http://www.stata-press.com/data/r7/abdata.dta"

* Make variables whose first differences are year dummies and the constant term.
* These are not necessary in general, but is needed to exactly imitate DPD because it enters time dummies
* and the constant term directly, undifferenced, in difference GMM.
forvalues y = 1979/1984 {
	gen yr`y'c = year>=`y'
}
gen cons = year

* difference GMM runs
xtabond2 n L.n L(0/1).(w k) yr*c cons, gmm(L.(w k n)) iv(yr*c cons) noleveleq noconstant robust
xtabond2 n L.n L(0/1).(w k) yr*c cons, gmm(L.(w k n)) iv(yr*c cons) noleveleq robust twostep

* system GMM runs
* eq(level) option is also not necessary in general, but needed for perfect imitation.
* Similarly, dpds2 is an undocumented option that simulates what appears to be a bug in DPD in one-step GMM
* that doubles the point estimate of the variance of the errors (sig2) and affects the Sargan and AR() statistics.
* dpds2 is only for demonstrating the capacity of xtabond2 to match DPD perfectly.
xtabond2 n L.n L(0/1).(w k) yr1978-yr1984, gmm(L.n, split) gmm(L.(w k)) iv(yr1978-yr1984, eq(level)) h(2) dpds2 robust
xtabond2 n L.n L(0/1).(w k) yr1978-yr1984, gmm(L.n, split) gmm(L.(w k)) iv(yr1978-yr1984, eq(level)) h(2) robust twoste
