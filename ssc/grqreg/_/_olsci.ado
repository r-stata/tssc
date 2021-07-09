*! version 1.3 JP Azevedo March2011
* compatible with SQREG
*! version 1.2 JP Azevedo Dec05
* including weights [`weight' `exp']
*! version 1.1 JP Azevedo Fev05
* fix OLS coef plots
* version 1.0 JP Azevedo Jan04

program define _olsci
version 8.2

syntax [varlist]                        ///
            [fweight aweight]           ///
            [,                          ///
            quantile(string)            ///
            qmin(real .05)              ///
            qmax(real .95)              ///
            qstep(real .05)             ///
            level(integer $S_level)     ///
            REPlace                     ///
            mfx(string)                 ///
            *                           ///
            ]                           ///
            saving(str)


tempvar sample tmp new
tempname b valnum rcount nxtrow coef output C testn

*-> get comand from last regress

    local cmd = e(cmd)

*-> get regressors from last regression

    if  ("`e(cmd)'" == "sqreg") {

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

*-> get dependent variable from last qreg

    local depvar = e(depvar)

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
  local vlist "`vlist' ols_`v' ols_`v'_cihi ols_`v'_cilo  "
}

local plevel=(100-`level')/200

local qmax=`qmax'+.000001

tempname tmp

if ("`mfx'"!="") {
    postfile `tmp' qtile `vlist' using `saving' , `replace'
}
if ("`mfx'"=="") {
    postfile `tmp' qtile `vlist' ols_cons ols_cons_cihi ols_cons_cilo using `saving' , `replace'
}

if ("`quantile'" == "") {
    local loopsyntax "forvalues qtile =`qmin'(`qstep')`qmax' "
}
if ("`quantile'" != "") {
    local loopsyntax "foreach qtile in `quantile' "
}

`loopsyntax' {

     if ("`mfx'"!="") {

        cap regress `depvar' `rhs' [`weight' `exp'] if `sample', `options'
        cap mfx, `mfx'
        mat ols_mfxb=e(Xmfx_`mfx')
        mat ols_mfxse=e(Xmfx_se_`mfx')
        local i=1
        if _rc==0 {
           local ols_topost " (`qtile') "
           foreach var of varlist `rhs' {
              local ols_thisv=ols_mfxb[1,`i']
              local  ols_vcilo=ols_mfxb[1,`i']-ols_mfxse[1,`i']*invnorm(1-(1-`level'/100)/2)
              local  ols_vcihi=ols_mfxb[1,`i']+ols_mfxse[1,`i']*invttail(e(df_r),`plevel')
              local  ols_topost "`ols_topost' (`ols_thisv') (`ols_vcihi') (`ols_vcilo')"
              local i=`i'+1
           }
           post `tmp' `ols_topost'
        }
     }

     if ("`mfx'"=="") {

       cap regress `depvar' `rhs' [`weight' `exp'] if `sample', `options'
       if _rc==0 {
       local ols_topost " (`qtile') "
       foreach var of varlist `rhs' {
         local ols_thisv=_b[`var']
         local  ols_vcihi=_b[`var']+_se[`var']*invttail(e(df_r),`plevel')
         local  ols_vcilo=_b[`var']-_se[`var']*invttail(e(df_r),`plevel')
         local  ols_topost "`ols_topost' (`ols_thisv') (`ols_vcihi') (`ols_vcilo')"

       }
       local ols_thiscons=_b[_cons]
       local  ols_conscihi=_b[_cons]+_se[_cons]*invttail(e(df_r),`plevel')
       local  ols_conscilo=_b[_cons]-_se[_cons]*invttail(e(df_r),`plevel')
       local ols_topost "`ols_topost' (`ols_thiscons') (`ols_conscihi') (`ols_conscilo') "
       post `tmp' `ols_topost'
       }
    }
}


postclose `tmp'

end
