* xtivreg2 cert script 1.0.9 cfb 20111016 updated ms 20150219/20150618
* requires -eret2- for last check at end
set more off
cscript xtivreg2 adofile xtivreg2
set matsize 800        
capture log close
log using cs_xtivreg2, replace
cap noi prog drop xtivreg2
cap noi prog drop ivreg2
cap noi prog drop ranktest
about
which xtivreg2
which ivreg2
which ranktest

* Layard-Nickell-Arellano-Bond dataset
use http://www.stata-press.com/data/r7/abdata.dta, clear
tsset, clear

******************* LSDV **************************

* Prepare mean-deviations
capture drop *_md
capture drop *_m
sort id
foreach var of varlist n w k ys wage emp {
	by id: gen double `var'_m  = sum(`var')/_N
	by id: gen double `var'_md = `var'-`var'_m[_N]
	}

xtreg n w k ys, fe i(id)
mat xtb=e(b)
mat xtV=e(V)
xtivreg2 n w k ys, fe i(id) small
mat xtiv2b=e(b)
mat xtiv2V=e(V)
assert reldif(xtb[1,1],xtiv2b[1,1]) < 1e-6
assert reldif(xtb[1,2],xtiv2b[1,2]) < 1e-6
assert reldif(xtb[1,3],xtiv2b[1,3]) < 1e-6
assert reldif(xtV[1,1],xtiv2V[1,1]) < 1e-6
assert reldif(xtV[1,2],xtiv2V[1,2]) < 1e-6
assert reldif(xtV[1,3],xtiv2V[1,3]) < 1e-6
assert reldif(xtV[2,1],xtiv2V[2,1]) < 1e-6
assert reldif(xtV[2,2],xtiv2V[2,2]) < 1e-6
assert reldif(xtV[2,3],xtiv2V[2,3]) < 1e-6
assert reldif(xtV[3,1],xtiv2V[3,1]) < 1e-6
assert reldif(xtV[3,2],xtiv2V[3,2]) < 1e-6
assert reldif(xtV[3,3],xtiv2V[3,3]) < 1e-6

* LSDV, robust
areg n w k ys, absorb(id) robust
mat xtb=e(b)
mat xtV=e(V)
xtivreg2 n w k ys, fe i(id) small robust
mat xtiv2b=e(b)
mat xtiv2V=e(V)
assert reldif(xtb[1,1],xtiv2b[1,1]) < 1e-6
assert reldif(xtb[1,2],xtiv2b[1,2]) < 1e-6
assert reldif(xtb[1,3],xtiv2b[1,3]) < 1e-6
assert reldif(xtV[1,1],xtiv2V[1,1]) < 1e-6
assert reldif(xtV[1,2],xtiv2V[1,2]) < 1e-6
assert reldif(xtV[1,3],xtiv2V[1,3]) < 1e-6
assert reldif(xtV[2,1],xtiv2V[2,1]) < 1e-6
assert reldif(xtV[2,2],xtiv2V[2,2]) < 1e-6
assert reldif(xtV[2,3],xtiv2V[2,3]) < 1e-6
assert reldif(xtV[3,1],xtiv2V[3,1]) < 1e-6
assert reldif(xtV[3,2],xtiv2V[3,2]) < 1e-6
assert reldif(xtV[3,3],xtiv2V[3,3]) < 1e-6

* LSDV, cluster
* No dof adjustment need (areg is over-conservative)
regress n_md w_md k_md ys_md, nocons cluster(id)
mat xtb=e(b)
mat xtV=e(V)
xtivreg2 n w k ys, fe i(id) small cluster(id)
mat xtiv2b=e(b)
mat xtiv2V=e(V)
assert reldif(xtb[1,1],xtiv2b[1,1]) < 1e-6
assert reldif(xtb[1,2],xtiv2b[1,2]) < 1e-6
assert reldif(xtb[1,3],xtiv2b[1,3]) < 1e-6
assert reldif(xtV[1,1],xtiv2V[1,1]) < 1e-6
assert reldif(xtV[1,2],xtiv2V[1,2]) < 1e-6
assert reldif(xtV[1,3],xtiv2V[1,3]) < 1e-6
assert reldif(xtV[2,1],xtiv2V[2,1]) < 1e-6
assert reldif(xtV[2,2],xtiv2V[2,2]) < 1e-6
assert reldif(xtV[2,3],xtiv2V[2,3]) < 1e-6
assert reldif(xtV[3,1],xtiv2V[3,1]) < 1e-6
assert reldif(xtV[3,2],xtiv2V[3,2]) < 1e-6
assert reldif(xtV[3,3],xtiv2V[3,3]) < 1e-6

************** IV ************************

* Standard homoskedastic, small
* Check just b, V and sargan with dof adjustment
tsset id year
set matsize 200
eststo clear
eststo: qui xi: ivreg2 n i.id year (w=k ys wage), small
mat ivb=e(b)
mat ivV=e(V)
scalar ivsargan=e(sargan)
eststo: qui xi: ivreg n i.id year (w=k ys wage)
rcof "noi xtivreg2 n year (w=k ys wage), fe small)" == 198
g year2 = year
eststo: xtivreg2 n year2 (w=k ys wage), fe small
mat xtiv2b=e(b)
mat xtiv2V=e(V)
esttab, keep(w year year2) b(%15.8f) se(%15.8f) mti("ivreg2_i." "ivreg" "xtivreg2")
assert reldif(ivb[1,1],xtiv2b[1,1]) < 1e-6
assert reldif(ivV[1,1],xtiv2V[1,1]) < 1e-6
assert reldif(ivsargan*(e(df_r)+e(df_b))/e(N),e(sargan)) < 1e-6

* Fixed effects is identical to FD when only two time periods (and nocons in latter)

* Prepare mean-deviations
capture drop *_md
capture drop *_m
capture drop touse
gen touse=1 if year==1980 | year==1981
sort id touse
foreach var of varlist n w k ys wage emp year {
	by id touse: gen double `var'_m  = sum(`var')/_N 
	by id touse: gen double `var'_md = `var'-`var'_m[_N]
	}

* Standard homoskedastic, small
tsset id year
ivreg2 d.n (d.w=d.k d.ys d.wage) if year==1981, nocons small ffirst orthog(d.ys) redundant(d.ys)
savedresults save iv2 e()
xtivreg2 n (w=k ys wage) if year==1980 | year==1981, fe small ffirst orthog(ys) redundant(ys)
// 1.0.3  no cdchi2 in either program, remove from comparisons below
//        remove redstat
savedresults comp iv2 e(), include( /*
	*/	scalar: df_r sargan sargandf cstat cstatdf idstat iddf  cdf /*
	*/  reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
xtivreg2 n (w=k ys wage) if year==1981, fd nocons small ffirst orthog(ys) redundant(ys)
savedresults comp iv2 e(), include( /*
	*/	scalar: df_r sargan sargandf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
savedresults drop iv2
* Ditto, large
tsset id year
ivreg2 d.n (d.w=d.k d.ys d.wage) if year==1981, nocons ffirst orthog(d.ys) redundant(d.ys)
savedresults save iv2 e()
xtivreg2 n (w=k ys wage) if year==1980 | year==1981, fe ffirst orthog(ys) redundant(ys)
savedresults comp iv2 e(), include( /*
	*/	scalar:      sargan sargandf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
xtivreg2 n (w=k ys wage) if year==1981, fd nocons ffirst orthog(ys) redundant(ys)
savedresults comp iv2 e(), include( /*
	*/	scalar:      sargan sargandf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
savedresults drop iv2

* Robust, small
tsset id year
ivreg2 d.n (d.w=d.k d.ys d.wage) if year==1981, nocons small ffirst orthog(d.ys) redundant(d.ys) robust
savedresults save iv2 e()
xtivreg2 n (w=k ys wage) if year==1980 | year==1981, fe small ffirst orthog(ys) redundant(ys) robust
savedresults comp iv2 e(), include( /*
	*/	scalar: df_r j jdf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
xtivreg2 n (w=k ys wage) if year==1981, fd nocons small ffirst orthog(ys) redundant(ys) robust
savedresults comp iv2 e(), include( /*
	*/	scalar: df_r j jdf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
savedresults drop iv2
* Ditto, large
tsset id year
ivreg2 d.n (d.w=d.k d.ys d.wage) if year==1981, nocons ffirst orthog(d.ys) redundant(d.ys) robust
savedresults save iv2 e()
xtivreg2 n (w=k ys wage) if year==1980 | year==1981, fe ffirst orthog(ys) redundant(ys) robust
savedresults comp iv2 e(), include( /*
	*/	scalar: j jdf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
xtivreg2 n (w=k ys wage) if year==1981, fd nocons ffirst orthog(ys) redundant(ys) robust
savedresults comp iv2 e(), include( /*
	*/	scalar: j jdf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
savedresults drop iv2

* cluster, small
* Do not use AR F stats because they don't match between FD and MD methods
* Stata's finite sample qc correction is (N-1)/(N-k)*M/(M-1)
* With FDs, N=140, AR F=66.60
* With MDs, N=280, AR F=67.09
tsset id year
ivreg2 d.n (d.w=d.k d.ys d.wage) if year==1981, nocons small ffirst orthog(d.ys) redundant(d.ys) cluster(id)
savedresults save iv2 e()
xtivreg2 n (w=k ys wage) if year==1980 | year==1981, fe small ffirst orthog(ys) redundant(ys) cluster(id)
savedresults comp iv2 e(), include( /*
	*/	scalar: df_r j jdf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
xtivreg2 n (w=k ys wage) if year==1981, fd nocons small ffirst orthog(ys) redundant(ys) cluster(id)
savedresults comp iv2 e(), include( /*
	*/	scalar: df_r j jdf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
savedresults drop iv2
* cluster, large
tsset id year
ivreg2 d.n (d.w=d.k d.ys d.wage) if year==1981, nocons ffirst orthog(d.ys) redundant(d.ys) cluster(id)
savedresults save iv2 e()
xtivreg2 n (w=k ys wage) if year==1980 | year==1981, fe ffirst orthog(ys) redundant(ys) cluster(id)
savedresults comp iv2 e(), include( /*
	*/	scalar: j jdf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
xtivreg2 n (w=k ys wage) if year==1981, fd nocons ffirst orthog(ys) redundant(ys) cluster(id)
savedresults comp iv2 e(), include( /*
	*/	scalar: j jdf cstat cstatdf idstat iddf  cdf /*
	*/	reddf archi2 arf ardf ardf_r /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
savedresults drop iv2

* arf ardf ardf_r 
* AR stats with cluster by hand
xtivreg2 n (w=k ys wage) if year==1980 | year==1981, fe small ffirst cluster(id)
scalar archi2=e(archi2)
scalar arf=e(arf)
scalar ardf=e(ardf)
scalar ardf_r=e(ardf_r)
regress n_md k_md ys_md wage_md if year==1980 | year==1981, cluster(id) nocons
test k_md ys_md wage_md
assert reldif(arf,r(F)) < 1e-6
assert reldif(ardf,r(df)) < 1e-6
assert reldif(ardf_r,r(df_r)) < 1e-6
ivreg2 n_md k_md ys_md wage_md if year==1980 | year==1981, cluster(id) nocons small
test k_md ys_md wage_md
assert reldif(arf,r(F)) < 1e-6
ivreg2 d.n d.k d.ys d.wage if year==1981, cluster(id) nocons
test d.k d.ys d.wage
assert reldif(archi2,r(chi2)) < 1e-6

* Frequency weights
* Need to use i(.) option for compatibility with Stata 8
xtivreg2 n (w=k ys wage) [fw=ind], fe small ffirst orthog(ys) redundant(ys) i(id)
savedresults save fw e()
expand ind
xtivreg2 n (w=k ys wage), fe small ffirst orthog(ys) redundant(ys) i(id)
savedresults comp fw e(), include(macros: depvar scalar: N g_min g_avg g_max matrix: b V) tol(1e-6) verbose
qui duplicates drop

* Singleton groups
tsset id year
xtivreg2 n (w=k ys wage) if ~(id<=3 & year>1977), fe
assert e(singleton)==3
assert e(N)==1010
assert e(N_g)==137

* HAC
xtivreg2 n (w=k ys wage), fe small ffirst bw(3) ivar(id) tvar(year)

* vs. official xtivreg

* FD
tsset id year
xtivreg  n (w=k ys wage), fd small
savedresults save iv e()
xtivreg2 n (w=k ys wage), fd small
savedresults comp iv e(), include( /*
	*/	scalar: N N_g df_r F df_b sigma_e g_min g_max g_avg /*
	*/	matrix: b V /*
	*/	) tol(1e-6) verbose
savedresults drop iv

* FE
tsset id year
xtivreg  n cap (w=k ys wage), fe small
mat b2=e(b)
mat b2=b2[1,1..2]
mat V2=e(V)
mat V2=V2[1..2,1..2]
eret2 mat b2=b2
eret2 mat V2=V2
savedresults save iv e()
xtivreg2 n cap (w=k ys wage), fe small
mat b2=e(b)
mat V2=e(V)
eret2 mat b2=b2
eret2 mat V2=V2
eret2 scalar r2_w=e(r2)
savedresults comp iv e(), include( /*
	*/	scalar: N N_g df_r F df_b sigma_e g_min g_max g_avg r2_w /*
	*/	matrix: b2 V2 /*
	*/	) tol(1e-6) verbose
savedresults drop iv

* Check first stage and reduced form saved results
tsset id year
* First-stage

rcof "xtivreg2 n year (w=k ys wage), fe small first savefirst savefprefix(_csxtivreg2_)" == 198
g yr = year
xtivreg2 n yr (w=k ys wage), fe small first savefirst savefprefix(_csxtivreg2_)
estimates replay _csxtivreg2_w
estimates restore _csxtivreg2_w
savedresults save fs e()
xtivreg2 w k ys wage yr, fe small
savedresults compare fs e(), exclude(	macro:					///
											_estimates_name		///
											_estimates_title	///
											estimates_title		///
											model				///
										scalar:					///
											k_eq				///
											)					///
							tol(1e-14)
* Reduced-form
xtivreg2 n yr (w=k ys wage), fe small rf saverf saverfprefix(_csxtivreg2_)
estimates replay _csxtivreg2_n
estimates restore _csxtivreg2_n
savedresults save fs e()
xtivreg2 n k ys wage yr, fe small
savedresults compare fs e(), exclude(	macro:					///
											_estimates_name		///
											_estimates_title	///
											estimates_title		///
											model				///
										scalar:					///
											k_eq				///
											)					///
							tol(1e-14)

* Check that orthog/cstat and endog/estat generate same test statistic
qui xtivreg2 n yr w (=k ys wage), orthog(w) fe i(id)
scalar cstat=e(cstat)
qui xtivreg2 n yr (w=k ys wage), endog(w) fe i(id)
scalar estat=e(estat)
assert reldif(cstat,estat) < 1e-6

// 1.0.4 handling of no obs
if _caller()>9 {
	use http://fmwww.bc.edu/ec-p/data/wooldridge/rental,clear
	tab year
	tsset city year
	rcof "xtivreg2 lrent y90 lpop lavginc pctstu, fd" == 2000
	tsset city year, delta(10)
	xtivreg2 lrent y90 lpop lavginc pctstu, fd
}

// 1.0.14 handling of collinearities and duplicates and nooutput option
use http://www.stata-press.com/data/r7/abdata.dta, clear
tsset id year
gen k2=k
xtivreg2 n k (w=ys wage), fe nooutput
xtivreg2 n k k (w=ys wage), fe nooutput
xtivreg2 n k k2 (w=ys wage), fe nooutput
xtivreg2 n k k2 k (w=ys wage), fe nooutput
xtivreg2 n (w=k ys wage), fe nooutput
xtivreg2 n (w=k ys wage k), fe nooutput
xtivreg2 n (w=k ys wage k2), fe nooutput
xtivreg2 n (w=k ys wage k2 k), fe nooutput

log close
