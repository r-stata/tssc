*! 1.0.1 Stephen Soldz 11/12/2002
program define minap, rclass
  version 7

  **************************************************************************
  * Calulates Velicer(1976) minimum average partial correlation           **
  * estimate of number of principal components to extract.                **
  * Author: Stephen Soldz, Boston Graduate School of Psychoanalysis,      **
  * 11/8/2002                                                             **
  * Reference: Velicer, W.F. (1976). Determining the number of components **
  *   from the matrix of partial correlations. Psychometrka, 41, 321-327. **
  **************************************************************************

  capture syntax varlist(min=3 numeric) [if] [in]
  if _rc {
    capture syntax , corr(str)
  }
  if _rc {
    display as err "specify either varlist of at least 3 variables or corr()"
    exit 198
  }

  tempname Cov N R Rstar X v sqrv A p pminus1 Cstar i j k fm f0 fmvec
  tempname numeigen index prior

  if "`varlist'" ~= "" {
          qui mat accum `Cov' = `varlist' `if' `in', dev noconst
    local N = r(N)
    mat `Cov' = `Cov' / (`N' - 1)
    mat `R' = corr(`Cov')
  }
  else if "`corr'" ~= "" {
    mat `R' = `corr'
  }

  local p = colsof(`R')
  scalar `f0' = 0

  forval i = 2 / `p' {
    local j = `i' - 1
    forval k = 1 / `j' {
      scalar `f0' = `f0' + `R'[`i', `k']^2
    }
  }

  scalar `f0' = 2 * `f0' / (`p' * (`p' - 1))

  dis as text _ne "{title:Minimum Average Partial Correlation for Number of Principal Components}"
  dis as text _ne "NOTE:  Pick number of components (m) at which fm is minimum."
  dis as text     "       If f1 > f0 (average intervariable correlation) "
  dis as text     "       then no components should be extracted."
  dis as text _ne _col(5) "m = 0" _col(15) "f0 = " _col(25) as result `f0' _ne

  * Initialize holder of fm values
  mat `fmvec' = J(1, `p' - 1, 0)

  mat symeigen `X' `v' = `R'

  * get number of eigenvalues > 1
  local numeigen = 0
  forval i = 1 / `p' {
          local numeigen = `numeigen' + (`v'[1, `i'] > 1.0)
  }

  * Rescale `v'  `X' so square of columns sum to eigenvalues
  mat `sqrv' = J(`p', `p', 0)
  forval i = 1 / `p' {
    mat `sqrv'[`i', `i'] = sqrt(`v'[1, `i'])
  }
  mat `X' = `X' * `sqrv'

  local pminus1 = `p' - 1

  forval m = 1 / `pminus1' {
    ** Main loop for calculating
    mat `A' = `X'[1..`p', 1..`m']
    mat `Cstar' = `R' - `A' * `A''
    mat `Rstar' = corr(`Cstar')
      scalar `fm' = 0

    forval i = 2 / `p' {
      local j = `i' - 1
      forval k = 1 / `j' {
              scalar `fm' = `fm' + (`Rstar'[`i', `k']^2)
            }
    }

    scalar `fm' = 2 * `fm' / (`p' * (`p' - 1))
    mat `fmvec'[1, `m'] = `fm'
    dis _col(5) as text "m = "  `m' _col(15) "f`m' = " /*
    */ _col(25) as result `fm'
  }

  local index = 0
  scalar `prior' = `f0'

  forval i= 1 / `pminus1' {
    if `fmvec'[1, `i'] < `prior' {
      scalar `prior' =  `fmvec'[1, `i']
      local index = `i'
    }
  }

  local s = cond(`index' != 1, "s", "")
  dis as text _ne "{p}{cmd:minap} procedure suggests that {res:`index'} "
  dis as text "principal component`s' should be extracted"
  local s = cond(`numeigen' != 1, "s", "")
  dis as text _ne "{p}For comparison, the Kaiser eigenvalue > 1 rule suggests extracting"
  dis as text "{res:`numeigen'} principal component`s'"

  return scalar minap =`index'
  return scalar Kaiser = `numeigen'
  return matrix Cormat `R'
  return matrix EigenVal `v'
  return matrix EigenVec `X'
  return matrix FmVec `fmvec'
end

