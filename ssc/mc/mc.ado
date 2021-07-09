*! version 1.01, Chao Wang, 26/10/2017
* calculates matched concordance index, C3i
* see: A. R. Brentnall, J. Cuzick, J. Field, and S. W. Duffy, "A concordance index for matched case-control studies with applications in cancer risk," Statistics in Medicine, vol. 34, pp. 396-405, Feb 10 2015.
* adapted from ARB's R code (fn.C3i, and fn.mcid)
program mc, rclass byable(recall)

version 13.1
syntax varlist(fv min=2 numeric) [if] [in] [, group(varname numeric) BREPs(integer 1000) NOBOOTstrap]
marksample touse

quietly count if `touse'
if `r(N)'==0 {
 error 2000
}

gettoken depvar indepvar : varlist
// local depvar: word 1 of `varlist'
// local indepvar: list varlist-depvar

tempname
tempvar id
tempfile original myW

quietly clogit `depvar' if `touse', group(`group')
di "N = " e(N)
quietly save `original'
quietly keep if e(sample)==1

** calculate myW & C3i (fn.C3i) ***
preserve
keep `varlist' `group'
gen `id'=_n
quietly reshape wide `indepvar', i(`id') j(`depvar')
egen tocompare=max(`indepvar'1), by(`group')
quietly drop if `indepvar'0==.
quietly gen myW=1 if `indepvar'0>tocompare
  quietly replace myW=0.5 if `indepvar'0==tocompare
  quietly replace myW=0 if `indepvar'0<tocompare
collapse (sum) myW, by(`group')
quietly save `myW'
restore, preserve

collapse (count) grpnum=`depvar' (sum) casenum=`depvar', by(`group')
quietly merge 1:1 `group' using `myW'
gen c3=1-myW/(casenum*(grpnum-casenum))
gen mysig1=(grpnum+1)/(12*casenum*(grpnum-casenum))
gen mysig1_inv=1/mysig1

** summarize C3 (fn.mcid) **
quietly sum mysig1_inv
gen myw=(1/mysig1)/r(sum)

gen myC3=myw*c3
quietly sum myC3
return scalar mc=r(sum)
di "mC = " r(sum)

* bootstrap for CI *
if "`nobootstrap'" == "" {
  quietly bootstrap mC=r(sum), cluster(`group') reps(`breps'): sum myC3
  estat bootstrap, all
}

restore

use `original', clear
end
