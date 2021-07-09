program mcmcsummarize

  version 12.1

  *summary statistics for draws from mcmc chains
  * varlist: variables to analyze
  * addpctiles: additional percentiles to capture, besides those in summarize, detail
  * nopctiles: do not capture any percentiles except possibly those in addpctiles

  syntax varlist [if] [in], saving(string asis) [addpctiles(numlist) nopctiles replace]

  marksample touse

  unab vars : `varlist'
  local nv : word count `vars'

  local ncols 2
  local collist "mean sd"
  local sfx ""
  local dopctiles 0
  local nadd 0
  local apstart 2
  if "`pctiles'"=="" {
    local ncols=`ncols'+9
    local collist "`collist' p1 p5 p10 p25 p50 p75 p90 p95 p99"
    local sfx ", det"
    local dopctiles 1
    local apstart `apstart'+9
    }
  if "`addpctiles'"~="" {
    local nadd: word count `addpctiles'
    local ncols=`ncols'+`nadd'
    forvalues j=1/`nadd' {
      local collist "`collist' ap`j'"
      }
    }
  tempname res
  mat `res'=J(`nv',`ncols',.)
  mat colnames `res' = `collist'

  preserve
  qui keep if `touse'

  forvalues i=1/`nv' {
    local v : word `i' of `vars'
    lab def variable `i' "`v'", add
    qui sum `v' `sfx'
    mat `res'[`i',1]=r(mean)
    mat `res'[`i',2]=r(sd)
    if `dopctiles'!=0 {
      mat `res'[`i',3]=r(p1)
      mat `res'[`i',4]=r(p5)
      mat `res'[`i',5]=r(p10)
      mat `res'[`i',6]=r(p25)
      mat `res'[`i',7]=r(p50)
      mat `res'[`i',8]=r(p75)
      mat `res'[`i',9]=r(p90)
      mat `res'[`i',10]=r(p95)
      mat `res'[`i',11]=r(p99)
      }
    if `nadd'!=0 {
      qui _pctile `v', percentiles(`addpctiles')
      forvalues j=1/`nadd' {
        mat `res'[`i',`apstart'+`j']=r(r`j')
        }
      }
    }
  qui drop _all
  qui svmat `res', names(col)
  qui gen variable=_n
  lab values variable variable
  if `nadd'!=0 {
    local j=0
    foreach k of numlist `addpctiles' {
      local j=`j'+1
      lab var ap`j' "p`k'"
      }
    }
  order variable 
  qui compress
  qui save `saving', `replace'

end
