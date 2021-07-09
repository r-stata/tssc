* ivreg2 cert script 1.1.06 CFB/MS 09feb2016
cscript ivreg2 adofile ivreg2
if _caller() < 10 {
	clear
	}
else {
	clear all
	}
capture log close
set more off
set rmsg on
program drop _all
// mata: mata mlib index
log using cs_ivreg2,replace
about
which ivreg2
which ranktest
which livreg2.mlib
// cap noi to enable running cert under earlier Statas
cap noi mata: whichlivreg2()
ivreg2, version  
assert "`e(version)'" == "04.1.11"

// Start tests

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

* line 4 of table via ivreg2, small
ivreg2 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , small
assert reldif(_b[s],0.172)<1e-3
assert reldif(_se[s],0.021)<1e-3
assert reldif(_b[iq],-0.009)<1e-3
assert reldif(_se[iq],0.0047)<1e-3
assert reldif(_b[expr],0.049)<1e-3
assert reldif(_se[expr],0.0082)<1e-3
assert reldif(_b[tenure],0.042)<1e-3
assert reldif(_se[tenure],0.0095)<1e-3
assert reldif(e(rmse),0.379)<1e-3
* 1.0.6: insts order now differs between ivreg, ivreg2
* savedresults comp iv e(), include(macros: insts instd depvar scalar: rmse matrix: b V) tol(1e-7) verbose
savedresults comp iv e(), include(macros: instd depvar scalar: rmse matrix: b V) tol(1e-7) verbose

* line 4 of table to match sargan (large sample stat)
ivreg2 lw expr tenure rns smsa _I* (iq s = med kww mrt age) 
assert reldif(e(sargan),13.3)<1e-2
assert e(sargandf)==2
assert reldif(e(sarganp),0.00131)<1e-3
rcof "noi ivreg2 lw expr tenure rns smsa _I* (iq s med kww = mrt age)" == 481

* OLS option
ivreg2 lw expr tenure rns smsa _I*, small
savedresults save ols e()
regress lw expr tenure rns smsa _I*
savedresults comp ols e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7) verbose

ivreg lw expr tenure rns smsa _I* (iq =  age) in 1/8
* insuff observations
rcof "noi ivreg2 lw expr tenure rns smsa _I* (iq =  age) in 1/8" == 2001
* ivreg2 lw expr tenure rns smsa _I* (iq=age) in 1/8
* assert "`e(collin)'" == "rns _Iyear_69 _Iyear_70 _Iyear_71 _Iyear_73"

* exact id
ivreg2 lw expr tenure rns smsa _I* (iq =  age)
assert reldif(e(sargan),0.0)<1e-3

* robust option
ivreg  lw expr tenure rns smsa _I* (iq s = med kww mrt age) , robust
savedresults save ivrob e()
ivreg2 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , robust small
* 1.0.6: same as above
*savedresults comp ivrob e(), include(macros: insts instd depvar vcetype scalar: rmse matrix: b V) tol(1e-7) verbose
savedresults comp ivrob e(), include(macros: instd depvar vcetype scalar: rmse matrix: b V) tol(1e-7) verbose


* GMM2S option
which ivgmm0
ivgmm0 lw expr tenure rns smsa _I* (iq s = med kww mrt age)
savedresults save ivgmm e()
ivreg2 lw expr tenure rns smsa _I* (iq s = med kww mrt age), gmm2s robust
* 1.0.6: same as above; cannot compare W
* savedresults comp ivgmm e(), include(macros: insts instd depvar scalar: N rmse j matrix: b V W) tol(1e-7) verbose
* savedresults comp ivgmm e(), include(macros: instd depvar scalar: N rmse j matrix: b V W) tol(1e-7) verbose
savedresults comp ivgmm e(), include(macros: instd depvar scalar: N rmse j matrix: b V ) tol(1e-7) verbose


* vs ivregress gmm
which ivregress
ivregress gmm lw expr tenure rns smsa _I* (iq s = med kww mrt age), wmatrix(robust) vce(unadjusted)
savedresults save ivregress e()
// mat vivregress = e(V)
ivreg2 lw expr tenure rns smsa _I* (iq s = med kww mrt age), gmm2s robust
// mat vivreg2 = e(V)
// mata: vdiff = mreldif(st_matrix("vivregress"),st_matrix("vivreg2")); vdiff
* 1.0.6: same as above; cannot compare W
* savedresults comp ivgmm e(), include(macros: insts instd depvar scalar: N rmse j matrix: b V W) tol(1e-7) verbose
* savedresults comp ivgmm e(), include(macros: instd depvar scalar: N rmse j matrix: b V W) tol(1e-7) verbose
savedresults comp ivregress e(), include(macros: instd depvar scalar: N rmse matrix: b V) tol(1e-7) verbose


* orthog option
rcof "noi ivreg2  lw expr tenure rns smsa _I* (iq = med kww mrt ), orthog(s)" == 198
ivreg2  lw expr tenure rns smsa _I* (iq = med kww mrt ), orthog(expr)
ivreg2  lw expr tenure rns smsa _I* (iq = med kww ), orthog(expr)
ivreg2  lw expr tenure rns smsa _I* (iq = med kww ), orthog(med)
ivreg2  lw expr tenure rns smsa _I* (iq = med kww ), orthog(med kww)

* cluster option
ivreg lw expr tenure rns smsa _I* (iq s = med kww mrt age) , robust cluster(age)
savedresults save ivclu e()
* 1.0.6: should yield 498? If so cannot execute following line
* rcof "ivreg2 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , small robust cluster(age)" == 498
ivreg2 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , small robust cluster(age)
* do not compare insts
savedresults comp ivclu e(), include(macros:  instd depvar scalar: N rmse  matrix: b) verbose tol(1e-7)
ivreg lw expr tenure rns smsa (iq s = med kww mrt age) , robust cluster(age)
savedresults save ivclu2 e()
ivreg2 lw expr tenure rns smsa (iq s = med kww mrt age) , small robust cluster(age)
* 1.0.6: similar to above
* savedresults comp ivclu2 e(), include(macros: insts instd depvar scalar: N matrix: b V)  tol(1e-7) verbose
savedresults comp ivclu2 e(), include(macros: instd depvar scalar: N matrix: b V)  tol(1e-7) verbose

* rcof "noi ivreg2 lw expr tenure rns smsa _I* (iq s = med kww mrt age) , gmm2s robust cluster(age)" == 498

* replay
ivreg2  lw expr tenure rns smsa _I* (iq s = med kww mrt age) , robust
savedresults save replay e()
ivreg2
savedresults comp replay e(), include(macros: insts instd depvar scalar: N matrix: b)  tol(1e-7) verbose

* 1.0.10 test exog regressors
ivreg2  lw  (iq = med kww mrt age) , nocons

* 1.0.12 test smatrix, wmatrix
qui ivreg2  lw  (iq = med kww mrt age), gmm2s
savedresults save ivs e()
mat S=e(S)
mat W=e(W)
mat check = trace(W - syminv(S))
assert check[1,1] == 0
ivreg2  lw  (iq = med kww mrt age) , gmm2s smatrix(S)
savedresults save ivss e()
savedresults comp ivs e(),  include(macros: instd depvar scalar: N matrix: b V) verbose tol(1e-7)

ivreg2  lw  (iq = med kww mrt age) ,  wmatrix(W)
savedresults comp ivs e(),  include(macros: instd depvar scalar: N matrix: b V) verbose tol(1e-7)
assert "`e(model)'"=="gmmw"
savedresults comp ivss e(),  include(macros: instd depvar scalar: N matrix: b V) verbose tol(1e-7)

ivreg2 lw (iq=med kww age), gmm2s
scalar J0 = e(j)
mat S0 = e(S)
qui ivreg2 lw (iq=kww) med age, gmm2s smatrix(S0)
test med age
di J0
assert reldif(r(chi2),J0)<1.0e-7
qui ivreg2 lw (iq=med) kww age, gmm2s smatrix(S0)
test kww age
assert reldif(r(chi2),J0)<1.0e-7
qui ivreg2 lw (iq=age) med kww, gmm2s smatrix(S0)
test med kww
assert reldif(r(chi2),J0)<1.0e-7

* 1.0.10 test xi
xi: ivreg2  lw  (iq = med kww mrt age) i.year
savedresults save ivxi e()
ivreg2  lw  (iq = med kww mrt age) _I*
savedresults comp ivxi e(), include(macros: instd depvar scalar: N matrix: b V)  tol(1e-7) verbose

* 1.0.10 test by
webuse grunfeld, clear
tsset company year
ivreg2 invest (mvalue= kstock)  if company==10
savedresults save ivby e()
by company: ivreg2 invest (mvalue= kstock)
savedresults comp ivby e(), include(macros: instd depvar scalar: N matrix: b V)  tol(1e-7) verbose

* 1.0.10 test bootstrap
set seed 20070203
bootstrap, reps(100) saving(ivbs,replace): ivreg invest (mvalue= kstock) 
set seed 20070203
bootstrap, reps(100) saving(iv2bs,replace): ivreg2 invest (mvalue= kstock) 
use iv2bs,clear
cf _all using ivbs

* 1.0.10 test jackknife
webuse grunfeld, clear
set seed 20070203
jackknife _b _se, eclass: ivreg invest (mvalue= kstock) 
savedresults save ivjk e()
set seed 20070203
jackknife _b _se, eclass: ivreg2 invest (mvalue= kstock), small
savedresults compare ivjk e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose

* 1.0.10 test svy (jackknife) FAILS
// use http://www.stata-press.com/data/r9/hsng2.dta, clear
// svyset _n
// set seed 20070203
// svy: ivreg rent pcturban (hsngval = faminc reg2-reg4), vce(jackknife)
// savedresults save ivsj e()
// set seed 20070203
// svy: ivreg2 rent pcturban (hsngval = faminc reg2-reg4) // , vce(jackknife)
// savedresults compare ivsj e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose

/* test absence of ranktest (specific to Mac OS X file location)
NOT RELEVANT AT PRESENT -- USING RANKTEST2
if "$S_OS" == "MacOSX" & c(version)>=10 {
    findfile ranktest.ado
    cd ~
    cd "library/application support/stata/ado/plus/r"
    !mv ranktest.ado ranktest.ado.disabled
    program drop _all
    rcof "noi ivreg2 cinf (unem=L(1/2).unem) [aw=year], bw(3)  robust small" == 601
    !mv ranktest.ado.disabled ranktest.ado
}
*/

* 1.0.10 test statsby
use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
egen quin = cut(year),group(7)
statsby _b _se, by(quin) saving(quin,replace): ivreg unem (inf=L.inf L2.inf)
statsby _b _se, by(quin) saving(quin2,replace): ivreg2 unem (inf=L.inf L2.inf), small
use quin2,clear
cf _all using quin

* 1.0.10 test rolling
use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
rolling, window(10) saving(rolliv,replace): ivreg unem (inf=L.inf L2.inf)
rolling, window(10) saving(rolliv2,replace): ivreg2 unem (inf=L.inf L2.inf), small
use rolliv2
cf _all using rolliv

* 1.0.7 test fweights
use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta,clear
ivreg2 lw80 expr80 tenure80 rns80 smsa80 (s80 = med kww) [fw=age], ffirst gmm2s
savedresults save fw e()
expand age
ivreg2 lw80 expr80 tenure80 rns80 smsa80 (s80 = med kww), ffirst gmm2s
savedresults comp fw e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose
qui duplicates drop

/*
* sw option for within estimator
webuse grunfeld, clear
center invest mvalue kstock time, casewise double
ivreg2  c_invest (c_mvalue=c_kstock c_time) , robust sw i(company) nocons dofminus(10)
ivreg2  c_invest (c_mvalue=c_kstock c_time) , robust gmm2s sw i(company) nocons dofminus(10)
*/


* HAC option, with explicit and auto bw

use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year, yearly
which newey
newey cinf unem, lag(2)
savedresults save newey e()
ivreg2 cinf unem, bw(3) kernel(bartlett) robust small
savedresults comp newey e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose

ivreg2 cinf (unem=L(1/2).unem), bw(auto) 
ivreg2 cinf (unem=L(1/2).unem), bw(auto) kernel(par)
ivreg2 cinf unem, bw(auto) kernel(qua)
ivreg2 cinf (unem=L(1/2).unem), bw(auto) kernel(qua)

* equivalence of ivendog and orthog option (Wooldridge 2002, pp.59, 61)

use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta
 ivreg2 lwage exper expersq (educ=age kidslt6 kidsge6)
// CANNOT EXEC WITH ivreg2--NOT SET UP TO RUN > ivreg2
/*
 which ivendog
 ivendog educ
 local rdf = r(df)
 local dwh = r(DWH)
 local dwhp = r(DWHp)
 ivreg2 lwage exper expersq educ (=age kidslt6 kidsge6), orthog(educ)
 assert `rdf' == e(cstatdf)
 assert reldif(`dwh',e(cstat)) < 1.0e-5
 assert reldif(`dwhp',e(cstatp)) < 1.0e-5
*/


* equivalence of coviv+liml and cue options
 ivreg2 lwage exper expersq (educ=age kidslt6 kidsge6), liml coviv
 savedresults save limlcov e()
 ivreg2 lwage exper expersq (educ=age kidslt6 kidsge6), cue
 savedresults comp limlcov e(), include(macros: inst instd depvar scalar: N rmse matrix: b V)  tol(1e-4) verbose
* savedresults save ols e()
ivreg2 lwage exper expersq educ (=age kidslt6 kidsge6),small
* savedresults comp ols e(), include(macros: depvar scalar: N df_r matrix: b V) tol(1e-4) verbose
preserve

* 1.0.22 second cue test

webuse klein, clear
tsset yr
ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt ///
 capital1 L.totinc), liml coviv
savedresults save limlcov2 e()
ivreg2 consump L.profits (profits wagetot = govt taxnetx year wagegovt ///
 capital1 L.totinc), cue
savedresults comp limlcov2 e(), include(macros: inst instd depvar scalar: N rmse matrix: b V)  tol(1e-6) verbose
 
 
* 1.0.13 cue with nocons
restore
ivreg2 lwage exper expersq (educ=age kidslt6 kidsge6), cue nocons

* 1.0.13 b0 option
ivreg2 lwage exper expersq (educ=age kidslt6 kidsge6)
mat b=e(b)
savedresults save b0 e()
ivreg2 lwage exper expersq (educ=age kidslt6 kidsge6), b0(b)
savedresults comp b0 e(), include(scalar: j) tol(1e-7) verbose
rcof "noi ivreg2 lwage exper expersq (educ=age kidslt6 kidsge6), b0(b) liml" == 198

* ivendog cstat versus ivreg2 cstat
ivreg lwage exper expersq (educ=age kidslt6 kidsge6)
savedresults save ivendog e()
ivendog educ
scalar cstat = r(DWH)
scalar cstatp = r(DWHp)
scalar cstatdf = r(df)
ivreg2 lwage exper expersq educ (=age kidslt6 kidsge6), orthog(educ)
savedresults compare ivendog e(), include(macros: depvar scalar: N df_m) tol(1e-7) verbose
assert reldif(e(cstat),cstat) < 1e-7
assert reldif(e(cstatp),cstatp) < 1e-7
assert cstatdf == e(cstatdf)

use http://fmwww.bc.edu/ec-p/data/hayashi/griliches76.dta,clear
assert _N == 758
xi  i.year
ivreg2 lw s expr tenure rns _I* (iq=kww age), cluster(year)
mat bfwl1 = e(b)
mat Vfwl1 = e(V)
savedresults save nofwl e()
ivreg2 lw s expr tenure rns _I* (iq=kww age), cluster(year) partial(_I*)
mat bfwl2 = e(b)
mat Vfwl2 = e(V)
savedresults compare nofwl e(), include(scalar: N N_clust rss rmse idstat) tol(1e-7)
assert reldif(bfwl1[1,1],bfwl2[1,1]) < 1e-7
assert reldif(bfwl1[1,2],bfwl2[1,2]) < 1e-7
assert reldif(Vfwl1[1,1],Vfwl2[1,1]) < 1e-7
assert reldif(Vfwl1[1,2],Vfwl2[1,2]) < 1e-7
assert reldif(Vfwl1[2,2],Vfwl2[2,2]) < 1e-7

// 1.0.22 test _cons
sysuse auto, clear
rename mpg d_consmpg
rename turn d_consturn
ivreg2 price d_consmpg d_consturn (weight = d_consturn foreign), nocons

// 1.0.29 check resid, stdp w/w/o partial()
sysuse auto, clear
qui reg price mpg weight
predict double resid0, r
predict double xb0, xb
predict double stdp0, stdp

qui ivreg2 price mpg weight, small
predict double resid2, r
predict double xb2, xb
predict double stdp2, stdp
qui ivreg2 price mpg weight, small partial(weight)
predict double resid2p, r
qui ivreg2 price mpg weight, small partial(weight _cons)
predict double resid2pc, r
qui ivreg2 price mpg weight, small partial(_cons)
predict double resid2c, r
desc resid*
sum resid*
sum xb*
sum stdp*
foreach v in 0 2 2p 2pc 2c {
	su resid`v', mean
	loc mu`v' = r(mean)
	capt su xb`0', mean
	loc xi`v' = r(mean)
	capt su stdp`v', mean
	loc nu`v' = r(mean)
}
foreach v in 2 2p 2pc 2c {
	assert reldif(`mu0', `mu`v'') < 1e-7
}
assert reldif(`xi0', `xi2') < 1e-7
assert reldif(`nu0', `nu2') < 1e-7

capture drop resid*
capture drop xb*
capture drop stdp*

qui reg price mpg weight, nocons
predict double resid0, r
predict double xb0, xb
predict double stdp0, stdp
qui ivreg2 price mpg weight, small nocons
predict double resid2, r
predict double xb2, xb
predict double stdp2, stdp
qui ivreg2 price mpg weight, small partial(weight) nocons
predict double resid2p, r
desc resid*
sum resid*
sum xb*
sum stdp*

foreach v in 0 2 2p  {
	su resid`v', mean
	loc mu`v' = r(mean)
	capt su xb`0', mean
	loc xi`v' = r(mean)
	capt su stdp`v', mean
	loc nu`v' = r(mean)
}
foreach v in 2 2p  {
	assert reldif(`mu0', `mu`v'') < 1e-6
}
assert reldif(`xi0', `xi2') < 1e-7
assert reldif(`nu0', `nu2') < 1e-7

* 1.0.29 Layard-Nickell-Arellano-Bond dataset
use http://www.stata-press.com/data/r7/abdata.dta, clear
tsset id year
ivreg2 d.n (d.w=d.k d.ys d.wage) if year==1981, nocons small ffirst orthog(d.ys) redundant(d.ys) cluster(id)

* 1.0.36 test Danielle kernel
use http://www.stata-press.com/data/r7/abdata.dta, clear
tsset id year
ivreg2 n w k, bw(3) kernel(danielle)

// 1.1.04
// checks of partial+weighting
// lower tolerance than for more recent ivreg2s
// repeated below with tougher tolerance
sysuse auto, clear
foreach spec in " " "[aw=weight]" "[fw=weight]" "[pw=weight]" "[iw=weight]" {
	di "Weight spec: `spec'"
	ivreg2 price foreign gear_ratio (mpg = turn trunk) `spec'
	scalar b1=_b[foreign]
	scalar b2=_b[mpg]
	ivreg2 price foreign gear_ratio (mpg = turn trunk) `spec', partial(gear_ratio)
	assert reldif(_b[foreign],b1) < 1e-7
	assert reldif(_b[mpg],b2) < 1e-7
}


// ********** EXIT IF CALLED BY STATA 9 OR EARLIER (LEGACY IVREG2) ******** //

if _caller() < 10 {
	log close
	set more on
	set rmsg off
	exit
}

// **************** REQUIRES IVREG2 FOR STATA 10 OR HIGHER ***************** //


* 1.0.21 overid tests per ivregress_9B04.do

// (A) overid stats for 2SLS classical VCE ---------------------------------------

webuse hsng2, clear
qui ivregress 2sls rent pcturban (hsngval = faminc popden pop)
savedresults save ivregress0 e()
estat overid
scalar oid0 = r(sargan)
qui ivreg2 rent pcturban (hsngval = faminc popden pop)
savedresults comp ivregress0 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg2 overid stat = " e(j)
assert reldif(e(j), oid0) < 1.0e-7
overid, all

// (B) overid stats for 2SLS robust VCE ---------------------------------------

qui ivregress 2sls rent pcturban (hsngval = faminc popden pop), robust
savedresults save ivregress1 e()
estat overid
scalar oid1 = r(score)
qui ivreg2 rent pcturban (hsngval = faminc popden pop), robust
savedresults comp ivregress1 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg2 overid stat = " e(j)
assert reldif(e(j), oid1) < 1.0e-7

// (E) overid stats for GMM robust VCE ---------------------------------------

qui ivregress gmm rent pcturban (hsngval = faminc popden pop), wmat(robust) vce(unadj)
savedresults save ivregress3 e()
estat overid
scalar oid3 = r(HansenJ)
qui ivreg2 rent pcturban (hsngval = faminc popden pop), robust gmm2s
savedresults comp ivregress3 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg2 overid stat = " e(j)
assert reldif(e(j), oid3) < 1.0e-7

// (F) overid stats for GMM cluster-robust VCE ---------------------------------------

qui ivregress gmm rent pcturban (hsngval = faminc popden pop), wmat(clu division) vce(unadj)
savedresults save ivregress6 e()
estat overid
scalar oid6 = r(HansenJ)
qui ivreg2 rent pcturban (hsngval = faminc popden pop), gmm2s clu(division)
savedresults comp ivregress6 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg2 overid stat = " e(j)
assert reldif(e(j), oid6) < 1.0e-7

// (G) overid stats for GMM HAC VCE ---------------------------------------

g t = _n
tsset t
qui ivregress gmm rent pcturban (hsngval = faminc popden pop), wmat(hac bartlett 4) vce(unadj)
savedresults save ivregress4 e()
estat overid
scalar oid4 = r(HansenJ)
qui ivreg2 rent pcturban (hsngval = faminc popden pop), robust gmm2s bw(5)
savedresults comp ivregress4 e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7)
di "ivreg2 overid stat = " e(j)
assert reldif(e(j), oid4) < 1.0e-7


* 1.0.14 test HAC with auto bw selection (vs Stata 10 ivregress)

webuse lutkepohl, clear
ivregress 2sls consumption (income=L(1/2).income) qtr L.consumption, vce(hac bartlett opt)
savedresults save ivhacau1 e()
local ivregressopt `e(vcelagopt)'
ivreg2 consumption (income=L(1/2).income) qtr L.consumption, bw(auto) robust
savedresults compare ivhacau1 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose
assert `ivregressopt' + 1 == `e(bw)'

ivreg2 consumption (income=L(1/2).income) qtr L.consumption, bw(auto) robust kernel(bartlett)
savedresults compare ivhacau1 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose
assert `ivregressopt' + 1 == `e(bw)'

ivregress 2sls consumption (income=L(1/2).income) qtr L.consumption, vce(hac parzen opt)
savedresults save ivhacau2 e()
local ivregressopt `e(vcelagopt)'
ivreg2 consumption (income=L(1/2).income) qtr L.consumption, bw(auto) robust kernel(parzen)
savedresults compare ivhacau2 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose
assert `ivregressopt' + 1 == `e(bw)'

ivregress 2sls consumption (income=L(1/2).income) qtr L.consumption, vce(hac qua opt)
savedresults save ivhacau3 e()
local ivregressopt `e(vcelagopt)'

ivreg2 consumption (income=L(1/2).income) qtr L.consumption, bw(auto) robust kernel(qua)
ivreg2 consumption (income=L(1/2).income) qtr L.consumption, bw(auto) robust kernel(qs)
// note lowered tolerance
savedresults compare ivhacau3 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-4) verbose
di "`ivregressopt'  `e(bw)'"
assert `ivregressopt' + 1 == `e(bw)'


* 1.0.13 test HAC with aw (vs Stata 10 ivregress)

use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
ivregress 2sls cinf unem [aw=year], vce(hac bartlett 2)  small
savedresults save ivhacaw1 e()
ivreg2 cinf unem [aw=year], bw(3)  robust small
savedresults compare ivhacaw1 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose

use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
ivregress 2sls cinf (unem=L(1/2).unem) [aw=year], vce(hac bartlett 2)  small
savedresults save ivhacaw2 e()
ivreg2 cinf (unem=L(1/2).unem) [aw=year], bw(3)  robust small
savedresults compare ivhacaw2 e(), include(macros: depvar scalar: N matrix: b V) tol(1e-7) verbose

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
* Issues!
* ivreg is same as ivregress allowing a perfectly predicted regress (dlk1)
* ivregress drops an instrument instead of reclassifying the regressor
* ivreg2 reclassifies it as exogenous
* older ivreg2s would not pick this up
ivreg invest li2 (li1 lk1 dlk1 = lk2 lk3 lk4 lk5)
ivregress 2sls invest li2 (li1 lk1 dlk1 = lk2 lk3 lk4 lk5), small perfect
ivregress 2sls invest li2 (li1 lk1 dlk1 = lk2 lk3 lk4 lk5), small
/* overid
savedresults save fabio1 e()
*/
ivreg2 invest li2 (li1 lk1 dlk1 = lk2 lk3 lk4 lk5), small
/*
assert "`e(collin)'" == ""
savedresults compare fabio1 e(), include(macros: inst instd depvar scalar:N matrix: b) tol(1e-7) 
*/

// 1.0.21 test for tsdelta
local inst L(1/2).inf
local bbw 1
local hacbw = `bbw' + 1
use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
drop if year>1973
tsset year, yearly
ivregress 2sls unem (inf = `inst'), robust
savedresults save rdelta1 e()
ivreg2 unem (inf = `inst'), robust
savedresults comp rdelta1 e(), include(macros: depvar scalar: N rmse matrix: b V) tol(1e-7) verbose

ivregress 2sls unem (inf = `inst'), vce(hac bartlett `bbw')
savedresults save hacdelta1 e()
ivreg2 unem (inf = `inst'), bw(`hacbw') robust
savedresults comp hacdelta1 e(), include(macros: depvar scalar: N rmse matrix: b V) tol(1e-7) verbose

g yq = qofd(dofy(year))
tsset yq, quarterly delta(4)
ivregress 2sls unem (inf = `inst'), robust
savedresults save rdelta e()
ivreg2 unem (inf = `inst'), robust
tsset
savedresults comp rdelta e(), include(macros: depvar scalar: N rmse matrix: b V) tol(1e-7) verbose

ivregress 2sls unem (inf = `inst'), vce(hac bartlett `bbw')
savedresults save hacdelta e()
tsset
ivreg2 unem (inf = `inst'), bw(`hacbw') robust
savedresults comp hacdelta e(), include(macros: depvar scalar: N rmse matrix: b V) tol(1e-7) verbose

// 1.0.23 test no obs
use http://fmwww.bc.edu/ec-p/data/wooldridge/rental,clear
tab year
xtset city year
capt noi ivreg2 D.lrent D.lpop D.lavginc D.pctstu
rcof "ivreg2 D.lrent D.lpop D.lavginc D.pctstu" == 2000
xtset city year, delta(10)
ivreg2 D.lrent D.lpop D.lavginc D.pctstu

// 1.0.26 test two-way cluster with HAC, one-way clustering by time alone, string vars
webuse nlswork, clear
ivreg2 ln_wage grade age ttl_exp tenure, robust cluster(idcode year) bw(2) kernel(tru)
ivreg2 ln_wage grade age ttl_exp tenure, robust cluster(year) bw(2) kernel(tru)
ivreg2 ln_wage (tenure=grade) age ttl_exp, robust cluster(year) bw(2) kernel(tru)
ivreg2 ln_wage grade age ttl_exp tenure, cluster(idcode year) bw(4) 
webuse auto, clear
tostring mpg, gen(smpg)
ivreg2 price (mpg = turn weight), clu(smpg)

// 1.0.27 partialling of tsset variable
webuse grunfeld, clear
tsset company year
capt noi ivreg2 invest (mvalue=kstock) year, partial(year)
rcof "ivreg2 invest (mvalue=kstock) year, partial(year)" == 198

// 1.0.30 equivalence to xtscc for Driscoll-Kraay SEs
clear
input id t y want
1 1 11 1
1 2 12 0
2 1 21 0
2 2 22 1
2 3 23 1
end
tsset id t
l
su y if want
mean y if want
ivreg2 y if want, small
ivreg2 y if want, small robust
ivreg2 y if want, small clu(t)
ivreg2 y if want, small bw(1) kernel(tru)
ivreg2 y if want, small bw(1) kernel(tru) clu(t)

webuse grunfeld, clear
ivreg2 invest mvalue kstock, dkraay(2) small
savedresults save dkr e()
ivreg2 invest mvalue kstock, cluster(year) bw(2) small
which xtscc
xtscc invest mvalue kstock, lag(1)
savedresults comp dkr e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7) verbose

// 1.0.35 test empty excl list
capt noi ivreg2 invest (mvalue= ) kstock
rcof "ivreg2 invest (mvalue= ) kstock" == 481

// 1.0.36 equivalence of cluster-robust and kernel-robust with max bw and truncated kernel
webuse abdata, clear
ivreg2 n w k, cluster(id)
savedresults save clu e()
// test for bandwidth < timespan
rcof "ivreg2 n w k, bw(9) kernel(tru) robust" == 198
ivreg2 n w k, bw(8) kernel(tru) robust
savedresults comp clu e(), include(macros: depvar scalar: rmse matrix: b V) tol(1e-7) verbose

* 1.0.37 setting of e(sample)
// clear all
use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta, clear
qui reg lwage educ exper
g byte es = e(sample)
su es, mean
sca esright = r(sum)
di esright
drop es
estimates esample:, replace

use http://fmwww.bc.edu/ec-p/data/wooldridge/mroz.dta, clear
ivreg2 lwage educ exper, partial(_cons)
est esample
g byte es1 = e(sample)
su es1
sca eswrong = r(sum)
di eswrong
assert esright == eswrong

// ********** EXIT IF CALLED BY STATA 10 OR EARLIER (LEGACY IVREG2) ******** //

if _caller() < 11 {
	log close
	set more on
	set rmsg off
	exit
}

// **************** REQUIRES IVREG2 FOR STATA 11 OR HIGHER ***************** //

// test partial() with TS ops 
// ts varlists not allowed with earlier ivreg2s
use http://fmwww.bc.edu/ec-p/data/wooldridge/phillips.dta, clear
tsset year,yearly
ivreg2 cinf (unem=L(1/2).unem) L.year, partial(L.year)

* 1.0.29
sysuse auto, clear
gen singleton=(_n==1)
* Exits with error if non-full-rank S matrix (since inverse not unique)
rcof "ivreg2 price singleton (mpg = weight turn), rob gmm2s" == 506
* J stat is missing but would be zero if reported.  Beta and SEs are fine.
// ivreg23007 price singleton (mpg = weight turn), rob gmm2s
* Partialling out the singleton solves the problem
ivreg2 price singleton (mpg = weight turn), rob gmm2s partial(singleton)
* And now reports the same thing as Wooldridge's score stat, as it should
ivregress 2sls price singleton (mpg = weight turn), rob
estat overid

// 1.1.01 factor variables
sysuse auto, clear
label drop origin

// OLS, no endogenous
// IV and other moved to higher Stata versions because
// of change between versions in ivregress behavior.
foreach arg in	"i.rep78"						///
				"i.rep78 rep78"					/// collinearity
				"rep78 i.rep78"					/// collinearity
				"i.rep78 i.foreign"				///
				"i.rep78#i.foreign"				///
				"i.rep78##i.foreign"			///
				"i.foreign##c.turn"				///
				"i.rep78##c.turn##i.foreign" 	{
	di "checking: `arg'"
	qui ivregress 2sls price `arg' if ~3.rep78
	mat b1=e(b)
	qui ivreg2 price `arg' if ~3.rep78
	mat b2=e(b)
	local vlist : colnames b2					//  since may not appear in b1
	foreach vn in `vlist' {
		_ms_parse_parts `vn'
		if ~r(omit) {
			di "`vn' " _c
			assert reldif(el(b1,1,colnumb(b1,"`vn'")),	///
							el(b2,1,colnumb(b2,"`vn'"))) < 1e-6
		}
	}
	di
}

// 1.1.02 collinearities with nocollin option
gen mpg2 = 2*mpg
gen weight2 = 2*weight

// Loop through specs, checking dropped vars, rank of V and S, and J.
// Some estimations may crash, which is OK;
// only a problem if the nocollin version completes
// but doesn't match the one with collinearity checks.
// Estimations with nocollin may also report missing id stats; also OK.
// Problems arise only if assert fails; loop will exit.
foreach spec in																///
	"price mpg mpg2 weight foreign foreign2, "								///
	"price mpg mpg2 weight foreign foreign2, rob"							///
	"price mpg mpg2 weight foreign foreign2, cluster(foreign)"				///
	"price mpg mpg2 weight foreign foreign2, partial(foreign)"				///
	"price mpg mpg2 weight foreign foreign2, partial(foreign*)"				///
	"price (mpg = weight turn) foreign foreign2, "							///
	"price (mpg = weight turn) foreign foreign2, rob"						///
	"price (mpg = weight turn) foreign foreign2, rob liml"					///
	"price (mpg = weight turn) foreign foreign2, rob gmm2s"					///
	"price (mpg = weight turn) foreign foreign2, cluster(foreign)"			///
	"price (mpg = weight turn) foreign foreign2, cluster(foreign) liml"		///
	"price (mpg = weight turn) foreign foreign2, cluster(foreign) gmm2s"	///
	"price (mpg = weight turn) foreign foreign2, rob partial(foreign)"		///
	"price (mpg = weight turn) foreign foreign2, rob liml partial(foreign)"	///
	"price (mpg = weight turn) foreign foreign2, rob gmm2s partial(foreign)"	///
	"price (mpg mpg2 rep78 = weight turn trunk gear) head, "						///
	"price (mpg mpg2 rep78 = weight turn trunk gear) head, rob"					///
	"price (mpg mpg2 rep78 = weight turn trunk gear) head, rob liml"				///
	"price (mpg mpg2 rep78 = weight turn trunk gear) head, rob gmm2s"			///
	"price (mpg mpg2 rep78 = weight turn trunk gear) head, cluster(foreign)"		///
	"price (mpg mpg2 rep78 = weight turn trunk gear) head, cluster(foreign) liml"	///
	"price (mpg mpg2 rep78 = weight turn trunk gear) head, cluster(foreign) gmm2s"	///
	"price (mpg = weight foreign turn foreign2) disp, "						///
	"price (mpg = weight foreign turn foreign2) disp, rob"					///
	"price (mpg = weight foreign turn foreign2) disp, rob liml"				///
	"price (mpg = weight foreign turn foreign2) disp, rob gmm2s"			///
	"price (mpg = weight foreign turn foreign2) disp, cluster(foreign)"		///
	"price (mpg = weight foreign turn foreign2) disp, cluster(foreign) liml"	///
	"price (mpg = weight foreign turn foreign2) disp, cluster(foreign) gmm2s"	///
	"price (mpg mpg2 rep78 = weight turn trunk gear) foreign head foreign2, "		///
	"price (mpg mpg2 rep78 = weight turn trunk gear) foreign head foreign2, rob"		///
	"price (mpg mpg2 rep78 = weight turn trunk gear) foreign head foreign2, rob gmm2s"	///
	"price (mpg mpg2 = foreign turn foreign2 disp) weight weight2, "		///
	"price (mpg mpg2 = foreign turn foreign2 disp) weight weight2, rob"		///
	"price (mpg mpg2 = foreign turn foreign2 disp) weight weight2, rob gmm2s"	///
	"price (mpg mpg2 = foreign turn disp) foreign2 weight, "				///
	"price (mpg mpg2 = foreign turn disp) foreign2 weight, rob"				///
	"price (mpg mpg2 = foreign turn disp) foreign2 weight, rob gmm2s"		///
								{
	di in ye "ivreg2 `spec'"
// Can crash for efficient GMM so capture
	cap noi ivreg2 `spec' nooutput
	if _rc==0 {
		mat b0			= diag0cnt(diag(e(b)))
		mat V0			= diag0cnt(e(V))
		scalar rankS	= e(rankS)
		scalar rankV	= e(rankV)
		scalar jdf		= e(jdf)
	}
	else {							//  crash so set to missing
		mat b0			= .
		mat V0			= .
		scalar rankS	= .
		scalar rankV	= .
	}
	cap noi ivreg2 `spec' nooutput nocollin
// Should either crash or have right counts
	if _rc==0 {
		mat b0n = diag0cnt(diag(e(b)))
		mat V0n = diag0cnt(e(V))
		if ~e(partial_ct) {						//  partialling-out removes
												//  omitted so can't count
			assert el(b0,1,1)	== el(b0n,1,1)
			assert el(V0,1,1)	== el(V0n,1,1)
		}
		assert rankS			== e(rankS)
		assert rankV			== e(rankV)
		assert jdf				== e(jdf)
	}
}

// 1.1.03 center option
sysuse auto, clear
gen t=_n
tsset t

// robust
ivregress gmm price (mpg=weight turn trunk), wmatrix(rob) vce(unadjusted) center
savedresults save centrob e()
estat overid
scalar j=r(HansenJ)
ivreg2 price (mpg=weight turn trunk), rob center gmm2s
savedresults comp centrob e(), include(matrix: b V)  tol(1e-7) verbose
assert abs(j-e(j)) < 1e-10

// HAC
ivregress gmm price (mpg=weight turn trunk), wmatrix(hac bartlett 2) vce(unadjusted) center
savedresults save centhac e()
estat overid
scalar j=r(HansenJ)
ivreg2 price (mpg=weight turn trunk), rob center gmm2s bw(3)
savedresults comp centhac e(), include(matrix: b V)  tol(1e-7) verbose
assert abs(j-e(j)) < 1e-10

// cluster
ivregress gmm price (mpg=weight turn trunk), wmatrix(cluster trunk) vce(unadjusted) center
savedresults save centclust e()
estat overid
scalar j=r(HansenJ)
ivreg2 price (mpg=weight turn trunk), rob cluster(trunk) center gmm2s
savedresults comp centclust e(), include(matrix: b V)  tol(1e-7) verbose
assert abs(j-e(j)) < 1e-10

// 1.1.04
// checks of partial+weighting
// tougher tolerance than for earlier ivreg2s above
sysuse auto, clear
foreach spec in " " "[aw=weight]" "[fw=weight]" "[pw=weight]" "[iw=weight]" {
	di "Weight spec: `spec'"
	ivreg2 price foreign gear_ratio (mpg = turn trunk) `spec'
	scalar b1=_b[foreign]
	scalar b2=_b[mpg]
	ivreg2 price foreign gear_ratio (mpg = turn trunk) `spec', partial(gear_ratio)
	assert reldif(_b[foreign],b1) < 1e-10
	assert reldif(_b[mpg],b2) < 1e-10
}

// ********** EXIT IF CALLED BY STATA 11 OR EARLIER *********************** //

if _caller() < 12 {
	log close
	set more on
	set rmsg off
	exit
}

// **************** REQUIRES STATA 12 OR HIGHER *************************** //

// 1.1.01 factor variables
sysuse auto, clear
label drop origin

* Syntax
* Allowed
ivreg2 1.foreign price mpg
* Not allowed - expands to multiple dep vars (base + dummy)
cap noi ivreg2 i.foreign price mpg
assert _rc==198

* Handling of duplicates, collinearities, margins, etc.
cap gen foreign2=2*foreign

ivreg2 price rep78 i.rep78
assert "`e(collin)'"=="5.rep78"
margins rep78
mat b1=r(b)
mat V1=r(V)
qui ivregress 2sls price rep78 i.rep78
qui margins rep78
mat b2=r(b)
mat V2=r(V)
assert mreldif(b1, b2) < 1e-8
assert mreldif(V1, V2) < 1e-8

ivreg2 price i.rep78, bvclean
rcof "margins rep78" == 322

ivreg2 price i.rep78 rep78
assert "`e(collin)'"=="rep78"
margins rep78

ivreg2 price i.rep78 rep78 i.foreign foreign
assert "`e(collin)'"=="rep78 foreign"
margins rep78 foreign

ivreg2 price i.rep78 rep78 i.foreign i.foreign
assert "`e(collin)'"=="rep78"
assert "`e(dups)'"==""			// EMPTY - because of how fvexpand works
margins rep78

ivreg2 price i.rep78 rep78 foreign foreign
assert "`e(collin)'"=="rep78"
assert "`e(dups)'"=="foreign"	// NOT EMPTY
margins rep78 

ivreg2 price i.rep78 rep78 i.foreign i.foreign2
assert "`e(collin)'"=="rep78 2.foreign2"
margins rep78 foreign
mat b1=r(b)
mat V1=r(V)
qui ivregress 2sls price i.rep78 rep78 i.foreign i.foreign2
qui margins rep78 foreign
mat b2=r(b)
mat V2=r(V)
assert mreldif(b1, b2) < 1e-8
assert mreldif(V1, V2) < 1e-8

ivreg2 price (i.foreign foreign = weight turn trunk)
assert "`e(collin)'"=="foreign"
margins foreign

ivreg2 price (foreign i.foreign = weight turn trunk)
assert "`e(collin)'"=="1.foreign"
margins foreign

ivreg2 price (mpg = weight turn trunk i.foreign foreign)
assert "`e(collin)'"=="foreign"
margins, dydx(mpg)
mat b1=r(b)
mat V1=r(V)
qui ivregress 2sls price (mpg = weight turn trunk i.foreign foreign)
qui margins, dydx(mpg)
mat b2=r(b)
mat V2=r(V)
assert mreldif(b1, b2) < 1e-8
assert mreldif(V1, V2) < 1e-8

ivreg2 price (mpg = weight turn trunk foreign i.foreign)
assert "`e(collin)'"=="1.foreign"
margins, dydx(mpg)

ivreg2 price (rep78 = i.rep78)
assert "`e(ecollin)'"=="rep78"
assert "`e(collin)'"=="5.rep78"

ivreg2 price i.rep78 (rep78 = weight turn trunk)
assert "`e(ecollin)'"=="rep78"
assert "`e(collin)'"=="5.rep78"
margins rep78
mat b1=r(b)
mat V1=r(V)
// Different handling by ivregress of collinearities
// This does NOT reclassify rep78 as exogenous
// qui ivregress 2sls price i.rep78 (rep78 = weight turn trunk)
// So must do this instead:
ivregress 2sls price rep78 i.rep78
qui margins rep78
mat b2=r(b)
mat V2=r(V)
assert mreldif(b1, b2) < 1e-8
assert mreldif(V1, V2) < 1e-8

// ********** EXIT IF CALLED BY STATA 12 OR EARLIER *********************** //

if _caller() < 13 {
	log close
	set more on
	set rmsg off
	exit
}

// **************** REQUIRES STATA 13 OR HIGHER *************************** //

// 1.1.01 factor variables
sysuse auto, clear
label drop origin

// IV
// IV and other tested here under higher versions because
// of change between versions in ivregress behavior.
foreach arg in	"i.rep78"						///
				"i.rep78 rep78"					/// collinearity
				"rep78 i.rep78"					/// collinearity
				"i.rep78 i.foreign"				///
				"i.rep78#i.foreign"				///
				"i.rep78##i.foreign"			/// official ivregress bug in Stata 11
				"i.foreign##c.turn"				///
				"i.rep78##c.turn##i.foreign" 	{
	di "checking: `arg'"
	qui ivregress 2sls price (mpg=`arg') if ~3.rep78
	mat b1=e(b)
	qui ivreg2 price (mpg=`arg') if ~3.rep78
	mat b2=e(b)
	local vlist : colnames b2					//  since may not appear in b1
	foreach vn in `vlist' {
		_ms_parse_parts `vn'
		if ~r(omit) {
			di "`vn' " _c
			assert reldif(el(b1,1,colnumb(b1,"`vn'")),	///
							el(b2,1,colnumb(b2,"`vn'"))) < 1e-6
		}
	}
	di
}

/* TEMP DISABLED (Stata 15)
* IV with FV in endogenous
foreach arg in	"i.mpg##c.turn"				///
				"c.turn##i.weight"	{
	di "checking: `arg'"
	qui ivregress 2sls price (i.foreign i.rep78=`arg') if ~3.rep78
	mat b1=e(b)
	qui ivreg2 price (i.foreign i.rep78=`arg') if ~3.rep78
	mat b2=e(b)
	local vlist : colnames b2					//  since may not appear in b1
	foreach vn in `vlist' {
		_ms_parse_parts `vn'
		if ~r(omit) {
			di "`vn' " _c
			assert reldif(el(b1,1,colnumb(b1,"`vn'")),	///
							el(b2,1,colnumb(b2,"`vn'"))) < 1e-6
		}
	}
	di
}
*/

* Combined TS and FV
cap gen t=_n
tsset t
foreach arg in	"i.mpg#L(1/2)c.turn"				///
				"c.turn#L(1/2)i.foreign"	{
	di "checking: `arg'"
	qui ivregress 2sls price (L2i(2/3).rep78=`arg')
	mat b1=e(b)
	qui ivreg2 price (L2i(2/3).rep78=`arg')
	mat b2=e(b)
	local vlist : colnames b2					//  since may not appear in b1
	foreach vn in `vlist' {
		_ms_parse_parts `vn'
		if ~r(omit) {
			di "`vn' " _c
			assert reldif(el(b1,1,colnumb(b1,"`vn'")),	///
							el(b2,1,colnumb(b2,"`vn'"))) < 1e-6
		}
	}
	di
}


ivreg2 price (i.foreign i.foreign = weight turn trunk)
assert "`e(dups)'"==""			// EMPTY - because of how fvexpand works
margins foreign
mat b1=r(b)
mat V1=r(V)
qui ivregress 2sls price (i.foreign i.foreign = weight turn trunk)
qui margins foreign
mat b2=r(b)
mat V2=r(V)
assert mreldif(b1, b2) < 1e-8
assert mreldif(V1, V2) < 1e-8

ivreg2 price i.rep78 (c.mpg#c.mpg = weight length turn) 
margins, dydx(mpg)
mat b1=r(b)
mat V1=r(V)
qui ivregress 2sls price i.rep78 (c.mpg#c.mpg = weight length turn)
qui margins, dydx(mpg)
mat b2=r(b)
mat V2=r(V)
assert mreldif(b1, b2) < 1e-8
assert mreldif(V1, V2) < 1e-8

ivreg2 price i.rep78 (c.mpg#c.mpg = weight length turn), partial(i.rep78)
rcof "margins, dydx(mpg)" == 322

// 1.1.04 string in command line
sysuse auto, clear
label drop origin
ivreg2 price mpg if "a"=="a"
// Next line fails if command line has "s incorrectly stripped out.
`e(cmdline)'

// ******************* COMPLETE *********************** //

log close
set more on
set rmsg off

