*! Date        : 18 Jul 2012
*! Version     : 1.05
*! Author      : Adrian Mander
*! Email       : adrian.mander@mrc-bsu.cam.ac.uk
*! Description : Case/control association test on chromosome data with permutation test
*! Example     : clump cc a1578 b1578,  noi maxiter(10)

/*
v1.04 23 Jul 09 The latest version
v1.05 18 Jul 12 Add return values
*/

program define clump,rclass
preserve
version 10.0
syntax varlist(min=3 max=3), [ SAVE(string) OUTPUT LRCHI2 NOIse SPEED MAXITER(integer 100) ]

/* Generate the temporary variables */
tempvar pid loc grp rand
qui gen long `pid' = _n
qui gen `loc'=.
lab var `loc' "Alleles"
local cc "`1'"
lab var `cc' "Case/control status"

if "`lrchi2'"=="" {
  local chi2 "chi2"
  local rchi2 "r(chi2)"
}
else {
  local chi2 "lrchi2"
  local rchi2 "r(chi2_lr)"
}
/*
 * Delete missing case/control status
 */
qui count if `cc'==.
if `r(N)'>0 {
  di in red "The `r(N)' missing values in `cc' are being deleted..."
  qui drop if `cc'==.
}

tokenize "`varlist'"
di "{txt}{dup 60:{c -}}"
di in green "{txt} Case/control status is contained in  {res}`1'"
confirm numeric variable `1'
qui inspect `1'
if `r(N_unique)'~=2 {
  di in red "There are `r(N_unique)' values in `1' there should only be 2 values 1 and 0"
  exit(198)
}
else {
  qui count if `cc'==1
  local nc1 = `r(N)'
  qui count if `cc'==0
  local nc0 = `r(N)'
  if (`nc1'+`nc0'<_N) {
    di "{err}`1' should be coded as 1 for a case and 0 for a control"
    exit(198)
  }
}
di "{txt}Marker information per person is contained in {res}(`2',`3')"

qui _ctab `2' `3' `pid' `loc'

qui tab `cc' `loc', matcol(alleles) `chi2'
local t1 = "``rchi2''"

local i 1
while `i'<=colsof(alleles) {
  local codes="`codes' "+string(alleles[1,`i'])
  local i=`i'+1
}
di "{txt}Alleles found at the marker are :"
di "{res} `codes'"
di "{txt}{dup 60:{c -}}"

qui drop if `loc'==.

if "`speed'"~=""  di "$S_TIME" 

tempname memhold
tempfile results
postfile `memhold' iter t1 t4 using `results'

qui count if `cc'==1
local cc1 =`r(N)'
local ncase = `r(N)'/2
local ss=_N

tempfile orig

sort `loc'
gen freq=1
qui by `loc': gen cfreq=sum(freq)
qui by `loc': replace cfreq=cfreq[_N]
drop freq

qui save `orig'
local iter 0
while `iter'<=`maxiter' {

  use `orig',replace
  /* Permute the CC vector on the subjects */
  if `iter'==1 local cc "pcaco"
  if `iter'>0 {
    cap drop `rand' pcaco
    sort `pid'
    qui by `pid': gen `rand' = uniform() if _n==1
    sort `rand'
    qui gen pcaco = 1 if _n <= `ncase'
    sort `pid' pcaco
    qui by `pid': replace pcaco=cond(pcaco[1]~=.,pcaco[1],0)
  }

/* generate the group variable by looking at all the O-E and grouping positives together */

  cap drop freq oe `grp'
  sort `cc' `loc'
  qui by `cc' `loc': gen freq=_N
  qui by `cc' `loc': keep if _n==1
  sort `loc' `cc'
  qui by `loc': gen `grp'=cond(`cc'==1, (freq-cfreq*`cc1'/`ss')>0, cond( _N==2, (freq[2]-cfreq[2]*`cc1'/`ss')>0 ,0 ) )
  lab var `grp' "Group"

  /* Just chi-squared on whole table */
  if `iter'>0 {
     qui tab `cc' `loc' [fw=freq], `chi2'
     local t1 = "``rchi2''"
  }

/* Find the max chi */
  local oldmax 0
  local maxchi = -1

  while `maxchi'~=`oldmax' {
    qui tab `cc' `grp' [fw=freq], `chi2'
    local maxchi = ``rchi2''
    local oldmax = `maxchi'
    local lchange ""

    local i 1
    while `i'<colsof(alleles) {
      qui gen test = cond(`loc'==alleles[1,`i'],cond(`grp'==1,0,1),`grp')
      qui inspect test
      if `r(N_unique)'>1 {
        qui tab `cc' test [fw=freq],`chi2'
        *di "``rchi2''" alleles[1,`i']
        if ``rchi2''>`maxchi' {
          local maxchi = ``rchi2''
          local lchange = alleles[1,`i']
        }
      }
      drop test
      local i = `i'+1
    }
    if "`lchange'"~="" qui replace `grp' = cond(`loc'==`lchange',cond(`grp'==1,0,1),`grp') 
  }

  if `iter'==0 {
    _subun `loc' `grp'
    local group1 "`r(grp1)'"
    local group0 "`r(grp0)'"
  }

  if "`noise'"~="" & `iter'==0 {
    di "{txt}FULL TABLE(T1)"
    tab `loc' `cc' [fw=freq], `chi2'
    di "{txt}MAX CHI (T4)"
    tab `grp' `cc' [fw=freq], `chi2'
  }

  post `memhold' (`iter') (`t1') (`maxchi')

  local iter = `iter'+1
} /* end of iter loop */

if "`speed'"~="" di "$S_TIME" 
postclose `memhold'
use `results',replace

qui count if t1> t1[1]
local pv1 = `r(N)'/(_N-1)
local t1 = t1[1]
qui count if t4> t4[1]
local pv4 = `r(N)'/(_N-1)
local t4 = t4[1]

di
di "{txt}Max iterations = {res}`maxiter'"
di
di "{txt}Chi-square on full table (T1)"
di "{dup 29:{c -}}"
di "Chi2 = {res}`t1'   {txt}(Empirical p-value={res}`pv1'{txt})"
di

di "{txt}Max chi-square on 2*2 table (T4)"
di "{dup 32:{c -}}"
di "Max chi2 =  {res}`t4' {txt}(Empirical p-value={res}`pv4'{txt})"
di "Max chi using groups (`group1') v (`group0')"

if "`save'"~="" save `save'

/*
 * Return values that people might want
 */
return scalar T1_pvalue = `pv1'
return scalar T4_pvalue = `pv4'
return scalar T1_chi2 = `t1'
return scalar T4_chi2pvalue = `t4'
return scalar maxiter = `maxiter'

restore
end

/*********************************************************
 * chromosome tabulate
 *********************************************************/

program define _ctab, rclass
syntax varlist
tokenize "`varlist'"

expand 2
sort `3'
qui by `3': replace `4'= cond(_n==1,`1',`2')

end

/****************************
 * Calculate the grouping
 ****************************/

program define _subun,rclass
  args loc grp
  preserve
  sort `grp' `loc'
  qui by `grp' `loc': keep if _n==1

  local grp1 ""
  local grp0 ""
  sort `grp'
  local i 1
  while `i'<=_N {
    if `grp'[`i']==1 local grp1="`grp1' "+string(`loc'[`i']) 
    else  local grp0="`grp0' "+string(`loc'[`i']) 
    local i=`i'+1
  }
  return local grp1 = "`grp1'"
  return local grp0 = "`grp0'"
  restore
end

