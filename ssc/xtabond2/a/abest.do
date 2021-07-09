* Program to reproduce results from Arellano-Bond 1991, as contained in "abest1.out" and "abest1.out" in http://www.doornik.com/download/dpdox121.zip.
* These results match those in the paper except for the AR() tests, as explained in footnote 7, page 29, of the DPD for Ox manual
* (dpd.pdf in the above .zip file).

clear all
set mem 32m
set matsize 800
use "http://www.stata-press.com/data/r7/abdata.dta"

* Make variables whose first differences are year dummies and the constant term.
* This step is not necessary in general, but is needed to exactly imitate DPD because it enters time dummies
* and the constant term directly, undifferenced, in difference GMM.
forvalues y = 1979/1984 {
	gen yr`y'c = year>=`y'
}
gen cons = year

* Replicate difference GMM runs in Arellano and Bond 1991, Table 4
* Column (a1)
xtabond2 n L(0/1).(l.n w) l(0/2).(k ys) yr198?c cons, gmm(L.n) iv(L(0/1).w l(0/2).(k ys) yr198?c cons) noleveleq noconstant robust

* Column (a2)
xtabond2 n L(0/1).(l.n w) l(0/2).(k ys) yr198?c cons, gmm(L.n) iv(L(0/1).w l(0/2).(k ys) yr198?c cons) noleveleq noconstant two

* Column (b)
xtabond2 n L(0/1).(l.n ys w) k yr198?c cons, gmm(L.n) iv(L(0/1).(ys w) k yr198?c cons) noleveleq noconstant two

* Column (c)--approximate. The data available set lacks sales and stock information, so different instruments must be used here. This regression
* replicates prefectly the results in abest3.out in the DPD for Ox package
xtabond2 n L(0/1).(l.n ys w) k yr198?c cons, gmm(L.n) gmm(w k, lag(2 3)) iv(L(0/1).ys yr198?c cons) noleveleq noconstant two
