* ivreg29 cert script 1.0.25 CFB/MS 19jan2015
cscript ivreg29 adofile ivreg29
capture log close
set more off
set rmsg on
program drop _all
log using cs_ivreg29,replace
about
which ivreg29
which ranktest2
ivreg29, version  
assert "`e(version)'" == "02.2.14"
use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta,clear
* Hayashi Table 3.3 p.255 uses Blackburn-Neumark sample 
summ
assert _N == 758
xi  i.year
* line 4 of table via ivreg
which ivreg
ivreg lw expr tenure rns smsa _I* (iq s = med kww mrt age)
assert reldif(_b[s],0.172)< 1e-3
assert reldif(_se[s],0.021)< 1e-3
assert reldif(e(rmse),0.380)< 1e-3
savedresults save iv e()
 
* line 4 of table via ivreg29, small
ivreg29 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , small
assert reldif(_b[s],0.172)<1e-3
assert reldif(_se[s],0.021)<1e-3
assert reldif(_b[iq],-0.009)<1e-3
assert reldif(_se[iq],0.0047)<1e-3
assert reldif(_b[expr],0.049)<1e-3
assert reldif(_se[expr],0.0082)<1e-3
assert reldif(_b[tenure],0.042)<1e-3
assert reldif(_se[tenure],0.0095)<1e-3
assert reldif(e(rmse),0.379)<1e-3
* 1.0.6: insts order now differs between ivreg, ivreg29
* savedresults comp iv e(), include(macros: insts instd depvar scalar: rmse matrix: b V) tol(1e-7) verbose
savedresults comp iv e(), include(macros: instd depvar scalar: rmse matrix: b V) tol(1e-7) verbose

* line 4 of table to match sargan (large sample stat)
ivreg29 lw expr tenure rns smsa _I* (iq s = med kww mrt age) 
assert reldif(e(sargan),13.3)<1e-2
assert e(sargandf)==2
assert reldif(e(sarganp),0.00131)<1e-3
rcof "noi ivreg29 lw expr tenure rns smsa _I* (iq s med kww = mrt age)" == 481

* OLS option
ivreg29 lw expr tenure rns smsa _I*, small
savedresults save ols e()
regress lw expr tenure rns smsa _I*
savedresults comp ols e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7) verbose

ivreg lw expr tenure rns smsa _I* (iq =  age) in 1/8
* insuff observations
rcof "noi ivreg29 lw expr tenure rns smsa _I* (iq =  age) in 1/8" == 2001
* ivreg29 lw expr tenure rns smsa _I* (iq=age) in 1/8
* assert "`e(collin)'" == "rns _Iyear_69 _Iyear_70 _Iyear_71 _Iyear_73"

* exact id
ivreg29 lw expr tenure rns smsa _I* (iq =  age)
assert reldif(e(sargan),0.0)<1e-3

* robust option
ivreg  lw expr tenure rns smsa _I* (iq s = med kww mrt age) , robust
savedresults save ivrob e()
ivreg29 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , robust small
* 1.0.6: same as above
*savedresults comp ivrob e(), include(macros: insts instd depvar vcetype scalar: rmse matrix: b V) tol(1e-7) verbose
savedresults comp ivrob e(), include(macros: instd depvar vcetype scalar: rmse matrix: b V) tol(1e-7) verbose


* GMM2S option
which ivgmm0
ivgmm0 lw expr tenure rns smsa _I* (iq s = med kww mrt age)
savedresults save ivgmm e()
ivreg29 lw expr tenure rns smsa _I* (iq s = med kww mrt age), gmm2s robust
* 1.0.6: same as above; cannot compare W
* savedresults comp ivgmm e(), include(macros: insts instd depvar scalar: N rmse j matrix: b V W) tol(1e-7) verbose
* savedresults comp ivgmm e(), include(macros: instd depvar scalar: N rmse j matrix: b V W) tol(1e-7) verbose
savedresults comp ivgmm e(), include(macros: instd depvar scalar: N rmse j matrix: b V ) tol(1e-7) verbose


* orthog option
rcof "noi ivreg29  lw expr tenure rns smsa _I* (iq = med kww mrt ), orthog(s)" == 198
ivreg29  lw expr tenure rns smsa _I* (iq = med kww mrt ), orthog(expr)
ivreg29  lw expr tenure rns smsa _I* (iq = med kww ), orthog(expr)
ivreg29  lw expr tenure rns smsa _I* (iq = med kww ), orthog(med)
ivreg29  lw expr tenure rns smsa _I* (iq = med kww ), orthog(med kww)

* cluster option
ivreg lw expr tenure rns smsa _I* (iq s = med kww mrt age) , robust cluster(age)
savedresults save ivclu e()
* 1.0.6: should yield 498? If so cannot execute following line
* rcof "ivreg29 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , small robust cluster(age)" == 498
ivreg29 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , small robust cluster(age)
* do not compare insts
savedresults comp ivclu e(), include(macros:  instd depvar scalar: N rmse  matrix: b) verbose tol(1e-7)
ivreg lw expr tenure rns smsa (iq s = med kww mrt age) , robust cluster(age)
savedresults save ivclu2 e()
ivreg29 lw expr tenure rns smsa (iq s = med kww mrt age) , small robust cluster(age)
* 1.0.6: similar to above
* savedresults comp ivclu2 e(), include(macros: insts instd depvar scalar: N matrix: b V)  tol(1e-7) verbose
savedresults comp ivclu2 e(), include(macros: instd depvar scalar: N matrix: b V)  tol(1e-7) verbose

* rcof "noi ivreg29 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , gmm2s robust cluster(age)" == 498

* replay
ivreg29  lw expr tenure rns smsa _I* (iq s = med kww mrt age) , robust
savedresults save replay e()
ivreg29
savedresults comp replay e(), include(macros: insts instd depvar scalar: N matrix: b)  tol(1e-7) verbose

* 1.0.10 test exog regressors
ivreg29  lw  (iq = med kww mrt age) , nocons

* 1.0.12 test smatrix, wmatrix
qui ivreg29  lw  (iq = med kww mrt age), gmm2s
savedresults save ivs e()
mat S=e(S)
mat W=e(W)
mat check = trace(W - syminv(S))
assert check[1,1] == 0
ivreg29  lw  (iq = med kww mrt age) , gmm2s smatrix(S)
savedresults save ivss e()
savedresults comp ivs e(),  include(macros: instd depvar scalar: N matrix: b V) verbose tol(1e-7)

ivreg29  lw  (iq = med kww mrt age) ,  wmatrix(W)
savedresults comp ivs e(),  include(macros: instd depvar scalar: N matrix: b V) verbose tol(1e-7)
assert "`e(model)'"=="gmmw"
savedresults comp ivss e(),  include(macros: instd depvar scalar: N matrix: b V) verbose tol(1e-7)

ivreg29 lw (iq=med kww age), gmm2s
scalar J0 = e(j)
mat S0 = e(S)
qui ivreg29 lw (iq=kww) med age, gmm2s smatrix(S0)
test med age
di J0
assert reldif(r(chi2),J0)<1.0e-7
qui ivreg29 lw (iq=med) kww age, gmm2s smatrix(S0)
test kww age
assert reldif(r(chi2),J0)<1.0e-7
qui ivreg29 lw (iq=age) med kww, gmm2s smatrix(S0)
test med kww
assert reldif(r(chi2),J0)<1.0e-7

* 1.0.10 test xi
xi: ivreg29  lw  (iq = med kww mrt age) i.year
savedresults save ivxi e()
ivreg29  lw  (iq = med kww mrt age) _I*
savedresults comp ivxi e(), include(macros: instd depvar scalar: N matrix: b V)  tol(1e-7) verbose

* 1.0.21 overid tests per ivregress_9B04.do
if c(version)>=10 {
// (A) overid stats for 2SLS classical VCE ---------------------------------------

webuse hsng2, clear
qui ivregress 2sls rent pcturban (hsngval = faminc popden pop)
savedresults save ivregress0 e()
estat overid
scalar oid0 = r(sargan)
qui ivreg29 rent pcturban (hsngval = faminc popden pop)
savedresults comp ivregress0 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg29 overid stat = " e(j)
assert reldif(e(j), oid0) < 1.0e-7
overid, all

// (B) overid stats for 2SLS robust VCE ---------------------------------------

qui ivregress 2sls rent pcturban (hsngval = faminc popden pop), robust
savedresults save ivregress1 e()
estat overid
scalar oid1 = r(score)
qui ivreg29 rent pcturban (hsngval = faminc popden pop), robust
savedresults comp ivregress1 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg29 overid stat = " e(j)
assert reldif(e(j), oid1) < 1.0e-7

// (E) overid stats for GMM robust VCE ---------------------------------------

qui ivregress gmm rent pcturban (hsngval = faminc popden pop), wmat(robust) vce(unadj)
savedresults save ivregress3 e()
estat overid
scalar oid3 = r(HansenJ)
qui ivreg29 rent pcturban (hsngval = faminc popden pop), robust gmm2s
savedresults comp ivregress3 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg29 overid stat = " e(j)
assert reldif(e(j), oid3) < 1.0e-7

// (F) overid stats for GMM cluster-robust VCE ---------------------------------------

qui ivregress gmm rent pcturban (hsngval = faminc popden pop), wmat(clu division) vce(unadj)
savedresults save ivregress6 e()
estat overid
scalar oid6 = r(HansenJ)
qui ivreg29 rent pcturban (hsngval = faminc popden pop), gmm2s clu(division)
savedresults comp ivregress6 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg29 overid stat = " e(j)
assert reldif(e(j), oid6) < 1.0e-7

// (G) overid stats for GMM HAC VCE ---------------------------------------

g t = _n
tsset t
qui ivregress gmm rent pcturban (hsngval = faminc popden pop), wmat(hac bartlett 4) vce(unadj)
savedresults save ivregress4 e()
estat overid
scalar oid4 = r(HansenJ)
qui ivreg29 rent pcturban (hsngval = faminc popden pop), robust gmm2s bw(5)
savedresults comp ivregress4 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg29 overid stat = " e(j)
assert reldif(e(j), oid4) < 1.0e-7
}

* 1.0.14 test HAC with auto bw selection (vs Stata 10 ivregress)
if c(version)>=10 {
webuse lutkepohl, clear
ivregress 2sls consumption (income=L(1/2).income) qtr L.consumption, vce(hac bartlett opt)
savedresults save ivhacau1 e()
local ivregressopt `e(vcelagopt)'
ivreg29 consumption (income=L(1/2).income) qtr L.consumption, bw(auto) robust
savedresults compare ivhacau1 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose
assert `ivregressopt' + 1 == `e(bw)'

ivreg29 consumption (income=L(1/2).income) qtr L.consumption, bw(auto) robust kernel(bartlett)
savedresults compare ivhacau1 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose
assert `ivregressopt' + 1 == `e(bw)'

ivregress 2sls consumption (income=L(1/2).income) qtr L.consumption, vce(hac parzen opt)
savedresults save ivhacau2 e()
local ivregressopt `e(vcelagopt)'
ivreg29 consumption (income=L(1/2).income) qtr L.consumption, bw(auto) robust kernel(parzen)
savedresults compare ivhacau2 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose
assert `ivregressopt' + 1 == `e(bw)'

ivregress 2sls consumption (income=L(1/2).income) qtr L.consumption, vce(hac qua opt)
savedresults save ivhacau3 e()
local ivregressopt `e(vcelagopt)'
ivreg29 consumption (income=L(1/2).income) qtr L.consumption, bw(auto) robust kernel(qua)
// note lowered tolerance
savedresults compare ivhacau3 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-4) verbose
di "`ivregressopt'  `e(bw)'"
assert `ivregressopt' + 1 == `e(bw)'
}

* 1.0.10 test by
webuse grunfeld, clear
tsset company year
ivreg29 invest (mvalue= kstock)  if company==10
savedresults save ivby e()
by company: ivreg29 invest (mvalue= kstock)
savedresults comp ivby e(), include(macros: instd depvar scalar: N matrix: b V)  tol(1e-7) verbose

* 1.0.10 test bootstrap
set seed 20070203
bootstrap, reps(100) saving(ivbs,replace): ivreg invest (mvalue= kstock) 
set seed 20070203
bootstrap, reps(100) saving(iv2bs,replace): ivreg29 invest (mvalue= kstock) 
use iv2bs,clear
cf _all using ivbs

* 1.0.10 test jackknife
webuse grunfeld, clear
set seed 20070203
jackknife _b _se, eclass: ivreg invest (mvalue= kstock) 
savedresults save ivjk e()
set seed 20070203
jackknife _b _se, eclass: ivreg29 invest (mvalue= kstock), small
savedresults compare ivjk e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose

* 1.0.10 test svy (jackknife) FAILS
// use http://www.stata-press.com/data/r9/hsng2.dta, clear
// svyset _n
// set seed 20070203
// svy: ivreg rent pcturban (hsngval = faminc reg2-reg4), vce(jackknife)
// savedresults save ivsj e()
// set seed 20070203
// svy: ivreg29 rent pcturban (hsngval = faminc reg2-reg4) // , vce(jackknife)
// savedresults compare ivsj e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose

* 1.0.13 test HAC with aw (vs Stata 10 ivregress)
if c(version) >= 10 {
use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
ivregress 2sls cinf unem [aw=year], vce(hac bartlett 2)  small
savedresults save ivhacaw1 e()
ivreg29 cinf unem [aw=year], bw(3)  robust small
savedresults compare ivhacaw1 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose

use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
ivregress 2sls cinf (unem=L(1/2).unem) [aw=year], vce(hac bartlett 2)  small
savedresults save ivhacaw2 e()
ivreg29 cinf (unem=L(1/2).unem) [aw=year], bw(3)  robust small
savedresults compare ivhacaw2 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose
}

* test partial() with TS ops 
use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
rcof "noi ivreg29 cinf (unem=L(1/2).unem) L.year, partial(L.year)" == 101

/* test absence of ranktest (specific to Mac OS X file location)
NOT RELEVANT AT PRESENT -- USING RANKTEST2
if "$S_OS" == "MacOSX" & c(version)>=10 {
    findfile ranktest.ado
    cd ~
    cd "library/application support/stata/ado/plus/r"
    !mv ranktest.ado ranktest.ado.disabled
    program drop _all
    rcof "noi ivreg29 cinf (unem=L(1/2).unem) [aw=year], bw(3)  robust small" == 601
    !mv ranktest.ado.disabled ranktest.ado
}
*/

* 1.0.10 test statsby
use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
egen quin = cut(year),group(7)
statsby _b _se, by(quin) saving(quin,replace): ivreg unem (inf=L.inf L2.inf)
statsby _b _se, by(quin) saving(quin2,replace): ivreg29 unem (inf=L.inf L2.inf), small
use quin2,clear
cf _all using quin

* 1.0.10 test rolling
use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
rolling, window(10) saving(rolliv,replace): ivreg unem (inf=L.inf L2.inf)
rolling, window(10) saving(rolliv2,replace): ivreg29 unem (inf=L.inf L2.inf), small
use rolliv2
cf _all using rolliv

* 1.0.7 test fweights
use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta,clear
ivreg29 lw80 expr80 tenure80 rns80 smsa80 (s80 = med kww) [fw=age], ffirst gmm2s
savedresults save fw e()
expand age
ivreg29 lw80 expr80 tenure80 rns80 smsa80 (s80 = med kww), ffirst gmm2s
savedresults comp fw e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose
qui duplicates drop

/*
* sw option for within estimator
webuse grunfeld, clear
center invest mvalue kstock time, casewise double
ivreg29  c_invest (c_mvalue=c_kstock c_time) , robust sw i(company) nocons dofminus(10)
ivreg29  c_invest (c_mvalue=c_kstock c_time) , robust gmm2s sw i(company) nocons dofminus(10)
*/

* ensure no inappropriate dropping of endog. regressors

webuse grunfeld, clear
qui {
g li1 = L.invest
g li2 = L2.invest
g li3 = L3.invest
g lk1 = L.kstock
g lk2 = L2.kstock
g lk3 = L3.kstock
g lk4 = L4.kstock
g lk5 = L5.kstock
g dlk1 = lk1-lk2
}
ivreg invest li2 (li1 lk1 dlk1 = lk2 lk3 lk4 lk5)
overid
savedresults save fabio1 e() 
ivreg29 invest li2 (li1 lk1 dlk1 = lk2 lk3 lk4 lk5), small
assert "`e(collin)'" == ""
savedresults compare fabio1 e(), include(macros: inst instd depvar scalar:N matrix: b) tol(1e-7) 

* HAC option, with explicit and auto bw

use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year, yearly
which newey
newey cinf unem, lag(2)
savedresults save newey e()
ivreg29 cinf unem, bw(3) kernel(bartlett) robust small
savedresults comp newey e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose

ivreg29 cinf (unem=L(1/2).unem), bw(auto) 
ivreg29 cinf (unem=L(1/2).unem), bw(auto) kernel(par)
ivreg29 cinf unem, bw(auto) kernel(qua)
ivreg29 cinf (unem=L(1/2).unem), bw(auto) kernel(qua)

* equivalence of ivendog and orthog option (Wooldridge 2002, pp.59, 61)

use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta
 ivreg29 lwage exper expersq (educ=age kidslt6 kidsge6)
// CANNOT EXEC WITH ivreg29--NOT SET UP TO RUN > ivreg29
/*
 which ivendog
 ivendog educ
 local rdf = r(df)
 local dwh = r(DWH)
 local dwhp = r(DWHp)
 ivreg29 lwage exper expersq educ (=age kidslt6 kidsge6), orthog(educ)
 assert `rdf' == e(cstatdf)
 assert reldif(`dwh',e(cstat)) < 1.0e-5
 assert reldif(`dwhp',e(cstatp)) < 1.0e-5
*/


* equivalence of coviv+liml and cue options
 ivreg29 lwage exper expersq (educ=age kidslt6 kidsge6), liml coviv
 savedresults save limlcov e()
 ivreg29 lwage exper expersq (educ=age kidslt6 kidsge6), cue
 savedresults comp limlcov e(), include(macros: inst instd depvar scalar: N rmse matrix: b V)  tol(1e-4) verbose
* savedresults save ols e()
ivreg29 lwage exper expersq educ (=age kidslt6 kidsge6),small
* savedresults comp ols e(), include(macros: depvar scalar: N df_r matrix: b V) tol(1e-4) verbose
preserve

* 1.0.22 second cue test

webuse klein, clear
tsset yr
ivreg29 consump L.profits (profits wagetot = govt taxnetx year wagegovt ///
 capital1 L.totinc), liml coviv
savedresults save limlcov2 e()
ivreg29 consump L.profits (profits wagetot = govt taxnetx year wagegovt ///
 capital1 L.totinc), cue
savedresults comp limlcov2 e(), include(macros: inst instd depvar scalar: N rmse matrix: b V)  tol(1e-6) verbose
 
 
* 1.0.13 cue with nocons
restore
ivreg29 lwage exper expersq (educ=age kidslt6 kidsge6), cue nocons

* 1.0.13 b0 option
ivreg29 lwage exper expersq (educ=age kidslt6 kidsge6)
mat b=e(b)
savedresults save b0 e()
ivreg29 lwage exper expersq (educ=age kidslt6 kidsge6), b0(b)
savedresults comp b0 e(), include(scalar: j) tol(1e-7) verbose
rcof "noi ivreg29 lwage exper expersq (educ=age kidslt6 kidsge6), b0(b) liml" == 198

* ivendog cstat versus ivreg29 cstat
ivreg lwage exper expersq (educ=age kidslt6 kidsge6)
savedresults save ivendog e()
ivendog educ
scalar cstat = r(DWH)
scalar cstatp = r(DWHp)
scalar cstatdf = r(df)
ivreg29 lwage exper expersq educ (=age kidslt6 kidsge6), orthog(educ)
savedresults compare ivendog e(), include(macros: depvar scalar: N df_m) tol(1e-7) verbose
assert reldif(e(cstat),cstat) < 1e-7
assert reldif(e(cstatp),cstatp) < 1e-7
assert cstatdf == e(cstatdf)

use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta,clear
assert _N == 758
xi  i.year
ivreg29 lw s expr tenure rns _I* (iq=kww age), cluster(year)
mat bfwl1 = e(b)
mat Vfwl1 = e(V)
savedresults save nofwl e()
ivreg29 lw s expr tenure rns _I* (iq=kww age), cluster(year) partial(_I*)
mat bfwl2 = e(b)
mat Vfwl2 = e(V)
savedresults compare nofwl e(), include(scalar: N N_clust rss rmse idstat) tol(1e-7)
assert reldif(bfwl1[1,1],bfwl2[1,1]) < 1e-7
assert reldif(bfwl1[1,2],bfwl2[1,2]) < 1e-7
assert reldif(Vfwl1[1,1],Vfwl2[1,1]) < 1e-7
assert reldif(Vfwl1[1,2],Vfwl2[1,2]) < 1e-7
assert reldif(Vfwl1[2,2],Vfwl2[2,2]) < 1e-7

// 1.0.21 test for tsdelta
if c(version)>=10 {

local inst L(1/2).inf
local bbw 1
local hacbw = `bbw' + 1
use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
drop if year>1973
tsset year, yearly
ivregress 2sls unem (inf = `inst'), robust
savedresults save rdelta1 e()
ivreg29 unem (inf = `inst'), robust
savedresults comp rdelta1 e(), include(macros: depvar scalar: N rmse matrix: b V) tol(1e-7) verbose

ivregress 2sls unem (inf = `inst'), vce(hac bartlett `bbw')
savedresults save hacdelta1 e()
ivreg29 unem (inf = `inst'), bw(`hacbw') robust
savedresults comp hacdelta1 e(), include(macros: depvar scalar: N rmse matrix: b V) tol(1e-7) verbose

g yq = qofd(dofy(year))
tsset yq, quarterly delta(4)
ivregress 2sls unem (inf = `inst'), robust
savedresults save rdelta e()
ivreg29 unem (inf = `inst'), robust
tsset
savedresults comp rdelta e(), include(macros: depvar scalar: N rmse matrix: b V) tol(1e-7) verbose

ivregress 2sls unem (inf = `inst'), vce(hac bartlett `bbw')
savedresults save hacdelta e()
tsset
ivreg29 unem (inf = `inst'), bw(`hacbw') robust
savedresults comp hacdelta e(), include(macros: depvar scalar: N rmse matrix: b V) tol(1e-7) verbose
}

// 1.0.22 test _cons
sysuse auto, clear
rename mpg d_consmpg
rename turn d_consturn
ivreg29 price d_consmpg d_consturn (weight = d_consturn foreign), nocons

log close
set more on
set rmsg off
