*! version 2.3 JP Azevedo Dec05
* including weights [`weight' `exp']
*! version 2.2 JP Azevedo Jan04 (Hacks)
*! version 2.1 M Blasnik dec03

program define _qregtrace
version 8.2

syntax                                      ///     /*[varlist]*/
            [fweight aweight]               ///
            [,                              ///
            qmin(real .05)                  ///
            qmax(real .95)                  ///
            qstep(real .05)                 ///
            level(integer $S_level) *       ///
            REPlace                         ///
            mfx(string)]                    ///
            saving(str)


tempvar sample tmp new
tempname b valnum rcount nxtrow coef output C testn mfxb mfxse

*-> get comand from last regress

    local cmd = e(cmd)

*-> get dependent variable from last qreg

    local depvar = e(depvar)

*-> get regressors from last qreg

    matrix `coef' = e(b)
    local cols = colsof(`coef')
    local regs = `cols' / (e(k_cat) - 1)
    matrix `b' = `coef'[1, 1..`regs']
    local rhs : colnames(`b')
    local rhs : subinstr local rhs "_cons" ""

*-> get weight info from last qreg

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

forvalues qtile=`qmin'(`qstep')`qmax' {

if ("`mfx'"!="") {

  cap qreg `depvar' `rhs' [`weight' `exp'] if `sample', `options' q(`qtile')
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

  cap qreg `depvar' `rhs' [`weight' `exp'] if `sample', `options' q(`qtile')
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
