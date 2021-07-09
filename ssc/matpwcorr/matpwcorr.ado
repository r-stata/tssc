*! Date        : 29 Nov 2006
*! Version     : 1.03
*! Authors     : Adrian Mander
*! Email       : adrian.mander@mrc-hnr.cam.ac.uk
*! Description : Finding correlations and putting them into matrices

/*
version 1.03: Fixes bug due to missing data. Needed the novarlist option in marksample.
*/

pr matpwcorr
version 9.1
syntax [varlist] [if] [in] [, Gen]
marksample touse, novarlist

unab myvar : `varlist'
local nvar: list sizeof varlist

if "`gen'"~="" {
  qui gen var1=""
  qui gen var2=""
  qui gen corr=.
  qui gen pv=.
}

mat corr=I(`nvar')
mat pv=I(`nvar')-I(`nvar')
mat colnames corr= `varlist'
mat rownames corr= `varlist'
mat colnames pv= `varlist'
mat rownames pv= `varlist'

local line 1
local i 1
foreach v1 of local varlist {
  local j 1
  foreach v2 of local varlist {
     if `j'>`i' {
        qui corr `v1' `v2' if `touse'
        local t = abs(`r(rho)')* sqrt( (`r(N)'-2)/(1-`r(rho)'^2) )
        local p = 2*ttail(`r(N)'-2, `t')
        mat corr[`i',`j'] = `r(rho)'
        mat corr[`j',`i'] = `r(rho)'
        mat pv[`i',`j'] = `p'
        mat pv[`j',`i'] = `p'
        if "`gen'"~="" {
          if `line'>_N qui set obs `line'
          qui replace var1 = "`v1'" in `line'
          qui replace var2 = "`v2'" in `line'
          qui replace corr = `r(rho)' in `line'
          qui replace pv= `p'   in `line'
        }
        local `line++'
     }
     local `j++'     
  }
local `i++'
}

local ntests "`--line'"

if "`gen'"~="" {
  qui gen pv_bonf = pv * `ntests'
  qui replace pv_bonf=1 if pv_bonf>1
  qui gen pv_sidak = 1 - (1-pv)^`ntests'
  qui replace pv_sidak=1 if pv_sidak>1
  sort pv
  list var1 var2 corr pv pv_bonf pv_sidak if pv~=.
  di "A significant p-value (pv) under a Bonferroni correction would be 0.05/`ntests' tests = " 0.05/`ntests' 
  /*
  The Dunn-Sidak correction  is   ac = 1 - (1-ae)^(1/j)  
  The Bonferroni correction is    ac = ae/j
  */
  local sidak = 1 - (1-0.05)^(1/`line')
  di "A significant p-value (pv) under a Dunn-Sidak correction would be `sidak'"
}

mat pv_bonf = pv * `ntests'
mat pv_sidak = pv
forv i=1/`nvar' {
  forv j=1/`nvar' {
    mat pv_sidak[`i',`j'] = 1-(1-pv[`i',`j'])^`ntests'
    if pv_bonf[`i',`j']>1 mat pv_bonf[`i',`j']=1
    if pv_sidak[`i',`j']>1 mat pv_sidak[`i',`j']=1
  }
}

end
