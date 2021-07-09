*! version 1.2.3  Jul 3, 2018 @ 17:51:41
*! MH and TB
program define unique, sort rclass
  version 10.1
  syntax varlist(min=1) [if] [in] [, GENerate(name) Detail BY(varname)]
  tempvar uniq count
  marksample touse, strok novarlist
  sort `varlist'
  summ `touse', meanonly
  local N = r(sum)
  sort `varlist' `touse'
  qui by `varlist': gen byte `uniq' = (`touse' & _n==_N)
  qui summ `uniq'
  di as txt "Number of unique values of `varlist' is  " as result r(sum)
  di as txt "Number of records is  " as result "`N'"
  // returned results
  return scalar unique = r(sum)
  return scalar sum = r(sum)
  return scalar N = `N'
  if "`detail'" != "" {
    sort `by' `varlist' `touse'
    qui by `by' `varlist' `touse': gen int `count' = _N if _n == 1
    label var `count' "Records per `varlist'"
    if "`by'" == "" {
      summ `count' if `touse', d
    }
    else {
      by `by': summ `count' if `touse', d
    }
  }
  if "`by'" !="" {
    if "`generate'"=="" {
      cap drop _Unique
      local generate _Unique
    }
    else {
      confirm new var `generate'
    }

    drop `uniq'
    sort `by' `varlist' `touse'
    qui by `by' `varlist': gen byte `uniq' = (`touse' & _n==_N)
    qui by `by': replace `uniq' = sum(`uniq')
    qui by `by': gen `generate' = `uniq'[_N] if _n==1
    di as txt "variable `generate' contains number of unique values of `varlist' by `by'"
    list `by' `generate' if `generate'!=., noobs nodisplay
  }
end
