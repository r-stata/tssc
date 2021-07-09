*! version 1.2 JP Azevedo March2011
*! version 1.1 JP Azevedo Mar10
* include proper support to sqreg
*! version 1.0 JP Azevedo Jan04

program define _bsqregtrace
version 8.2

syntax [varlist] [,     ///
            qmin(real .05) ///
            qmax(real .95) ///
            qstep(real .05) ///
            quantile(string) ///
            level(integer $S_level) * ///
            REPlace ///
            mfx(string) ///
            seed(str)   ///
            reps(str)] ///
            saving(str) ///

tempvar sample tmp new
tempname b valnum rcount nxtrow coef output C testn

*-> get comand from last regress

    local cmd = e(cmd)

*-> get dependent variable from last bsqreg

    local depvar = e(depvar)

*-> get regressors from last bsqreg or sqreg

    if ("`quantile'" != "") & ("`e(cmd)'" == "sqreg") {

        matrix `coef' = e(b)
        local cols = colsof(`coef')
        local regs = `cols' / (e(k_cat) - 1)
        matrix `b' = `coef'[1, 1..`regs']
        local rhs : colnames(`b')

		loc tmp0 : word count `e(eqnames)'
        loc tmp1 : word count `rhs'
        loc tmp2 = (`tmp1'/`tmp0') - 1
        forvalues i = 1(1)`tmp2' {
            loc rhs0  = word("`rhs'",`i')
            loc rhs1 "`rhs1' `rhs0'"
        }
        loc rhs  "`rhs1'"
    }
    else {
        matrix `coef' = e(b)
        local cols = colsof(`coef')
        local regs = `cols' / (e(k_cat) - 1)
        matrix `b' = `coef'[1, 1..`regs']
        local rhs : colnames(`b')
        local rhs : subinstr local rhs "_cons" ""
    }

*-> get weight info from last bsqreg

    if "`e(wtype)'" != "" {
        local wtis "[`e(wtype)'`e(wexp)']"
        local wexp2 "`e(wexp)'"
    }

*-> check that estimation sample matches n from regression

    quietly {
        generate `sample' = e(sample)

        if "`e(wtype)'" == "" | "`e(wtype)'" == "aweight" /*
            */ | "`e(wtype)'" == "pweight" {
            count if `sample'
            scalar `testn' = r(N)
        }
        else if "`e(wtype)'" == "fweight" | /*
            */ "`e(wtype)'" == "iweight" {
            local wtexp = substr("`e(wexp)'", 3, .)
            gen `tmp' = (`wtexp') * `sample'
            su `tmp', meanonly
            scalar `testn' = round(r(sum),1)
        }
    }

    if e(N) ~= `testn' {
        di  _n in r "data has been altered since " /*
        */ in y "qreg" in r " was estimated"
        exit 459
    }

foreach v of local rhs {
  local vlist "`vlist' `v' `v'_cihi `v'_cilo  "
}

local plevel=(100-`level')/200

local qmax=`qmax'+.000001

tempname tmp

if ("`mfx'"!="") {
    postfile `tmp' qtile `vlist' using `saving' , `replace'
}
if ("`mfx'"=="") {
    postfile `tmp' qtile `vlist' cons cons_cihi cons_cilo using `saving' , `replace'
}

if ("`quantile'" == "") {

    forvalues qtile = `qmin'(`qstep')`qmax' {

    if ("`mfx'"!="") {

      set seed `seed'
      cap bsqreg `depvar' `rhs' `wtis' if `sample', `options' q(`qtile') reps(`reps')
      cap mfx, `mfx'
      mat mfxb=e(Xmfx_`mfx')
      mat mfxse=e(Xmfx_se_`mfx')
      local i=1
      if _rc==0 {
      local topost " (`qtile') "
      foreach var of varlist `rhs' {
        local thisv=mfxb[1,`i']
        local  vcihi=mfxb[1,`i']+mfxse[1,`i']*invnorm(1-(1-`level'/100)/2)
        local  vcilo=mfxb[1,`i']-mfxse[1,`i']*invnorm(1-(1-`level'/100)/2)
        local  topost "`topost' (`thisv') (`vcihi') (`vcilo')"
       local i=`i'+1
      }
       post `tmp' `topost'
    }

      }
    if ("`mfx'"=="") {

      set seed `seed'
      cap bsqreg `depvar' `rhs' `wtis' if `sample', `options' q(`qtile') reps(`reps')
      if _rc==0 {
      local topost " (`qtile') "
      foreach var of varlist `rhs' {
        local thisv=_b[`var']
        local  vcihi=_b[`var']+_se[`var']*invttail(e(df_r),`plevel')
        local  vcilo=_b[`var']-_se[`var']*invttail(e(df_r),`plevel')
        local  topost "`topost' (`thisv') (`vcihi') (`vcilo')"

      }
      local thiscons=_b[_cons]
      local  conscihi=_b[_cons]+_se[_cons]*invttail(e(df_r),`plevel')
      local  conscilo=_b[_cons]-_se[_cons]*invttail(e(df_r),`plevel')
      local topost "`topost' (`thiscons') (`conscihi') (`conscilo') "
      post `tmp' `topost'
        }
      }
    }
}


if ("`quantile'" != "") {

    foreach qtile in local `quantile' {

    if ("`mfx'"!="") {

      set seed `seed'
      cap bsqreg `depvar' `rhs' `wtis' if `sample', `options' q(`qtile') reps(`reps')
      cap mfx, `mfx'
      mat mfxb=e(Xmfx_`mfx')
      mat mfxse=e(Xmfx_se_`mfx')
      local i=1
      if _rc==0 {
      local topost " (`qtile') "
      foreach var of varlist `rhs' {
        local thisv=mfxb[1,`i']
        local  vcihi=mfxb[1,`i']+mfxse[1,`i']*invnorm(1-(1-`level'/100)/2)
        local  vcilo=mfxb[1,`i']-mfxse[1,`i']*invnorm(1-(1-`level'/100)/2)
        local  topost "`topost' (`thisv') (`vcihi') (`vcilo')"
       local i=`i'+1
      }
       post `tmp' `topost'
    }

      }
    if ("`mfx'"=="") {

      set seed `seed'
      cap bsqreg `depvar' `rhs' `wtis' if `sample', `options' q(`qtile') reps(`reps')
      if _rc==0 {
      local topost " (`qtile') "
      foreach var of varlist `rhs' {
        local thisv=_b[`var']
        local  vcihi=_b[`var']+_se[`var']*invttail(e(df_r),`plevel')
        local  vcilo=_b[`var']-_se[`var']*invttail(e(df_r),`plevel')
        local  topost "`topost' (`thisv') (`vcihi') (`vcilo')"

      }
      local thiscons=_b[_cons]
      local  conscihi=_b[_cons]+_se[_cons]*invttail(e(df_r),`plevel')
      local  conscilo=_b[_cons]-_se[_cons]*invttail(e(df_r),`plevel')
      local topost "`topost' (`thiscons') (`conscihi') (`conscilo') "
      post `tmp' `topost'
        }
      }
    }
}

postclose `tmp'


quietly {
  preserve
  foreach var in `rhs' {
    local temp : variable label `var'
    local labels "`labels' `"`temp'"'"
  }

  use `saving', clear

  local i = 1
  foreach var in `rhs' {
    local label : word `i' of `labels'
    label variable `var' `"`label'"'
    local i = `i' + 1
  }

if ("`mfx'"=="") {
  label var cons "Intercept"
}

  save, replace
  restore
}

end
