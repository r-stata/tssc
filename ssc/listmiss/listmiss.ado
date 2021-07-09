*! version 1.0 P.MILLAR 21Mar2005
*! version 1.1 P.MILLAR 07Mar2006 Bug fix (xi, logistic)
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Copyright 2005 Paul Millar

program define listmiss , byable(recall)
  version 8.0
  syntax [anything] [if] [in] [, ]

if "`e(cmd)'"=="" {
  di as error "last estimates not found"
  exit 301
  } 

_est clear
_est hold model1, copy restore

local dv "`e(depvar)'"
local cmd="`e(cmd)'"
local wgtexp="[`e(wtype)' `e(wexp)']"

/* get options */
if "`e(offset)'"!="" {
  tempvar off 
  gen `off'=`e(offset)'
  lab var `off' "`e(offset)'"
  local offset offset(`off')
  }
if "`e(vcetype)'"~="" { 
  local robust="robust"
  }
if "`e(clustvar)'"~="" {
  local cluster cluster(`e(clustvar)')
  }
local ops `offset' `robust' `cluster' `dist' `iter'
  
tempvar smpl
qui gen `smpl'=e(sample)
mat bs=e(b) 
local xnames : colnames(bs) 

/* process the variable names to account for xi: or dummy variables */
local totnvars : word count `xnames'
local totnvars=`totnvars'-1
if `totnvars'==0 {
  di as error "No independent variables found in previous estimation command"
  exit
  }
tokenize `xnames'

/* note that macros can contain very long strings, but strings themselves can only be 80 characters each */
/* ouch */
/* so we have up to 10 lists of independent variables, called ivl# */
forvalues i=1/10 {
  local ivl`i'=" "
  }
local nivl=1
local prevvar=" "
local curvarno=0
local max=0
forvalues i=1/`totnvars' {
  local varname="``i''"
  local lstr=length("`ivl`nivl''")+length("`varname'")
  if `lstr' > 80 {
    local nivl=`nivl'+1
    }
  local repeat=index("`ivl1'","`varname'") +index("`ivl2'","`varname'") +index("`ivl3'","`varname'") +index("`ivl4'","`varname'") +index("`ivl5'","`varname'")
  if "`varname'" != "_cons" & substr("`varname'",1,4) != "_cut" & `repeat' == 0 {
    local ivl`nivl'="`ivl`nivl'' `varname'"
    }
  local uscore=substr("`varname'",1,2)
  if "`uscore'"=="_I" {
    local varname=subinstr("`varname'","_I","",1)
    local nextus=index("`varname'","_")-1
    if `nextus' > 0 {
       local varname=substr("`varname'",1,`nextus')
       }
    if "`varname'" != "`prevvar'" {
      local varnam`i'="`varname'"
      local varno`i'=`i'
      local curvarno=`curvarno'+1
      local rowno`i'=`curvarno'
      local prevvar="`varname'"
      }
    else {
      local lasti=`i'-1
      local varnam`i'="`varname'"
      local varno`i'=`varno`lasti''
      local rowno`i'=`curvarno'
      } 
    } 
  else if "`varname'" == "_cons" | substr("`varname'",1,4) == "_cut" {
    local varnam`i'="`varname'"
    local varno`i'=0
    local rowno`i'=0
    if `max'==0 {
      local max=`i'-1
      }
    }
  else {
    local varnam`i'="`varname'"
    local varno`i'=`i'
    local curvarno=`curvarno'+1
    local rowno`i'=`curvarno'
    local prevvar="`varname'"
    }
  }

if `max' < `totnvars' & `max' != 0 {
  local totnvars=`max'
  }

/* set up the rownames - since we have only 80 columns per variable, must have multiple rowname variables */
local nrn=1
forvalues i=1/10 {
  local rn`i'=" "
  }
local nvars=0
forvalues i=1/`totnvars' {
  if "`varno`i''" == "`i'" {
    local nvars=`nvars'+1
    local lstr=length("`rn`nrn''")+length("`varname'")
    if `lstr' > 80 {
      local nrn=`nrn'+1
      }
    local rn`nrn'="`rn`nrn'' `varnam`i''"
    }
  }

/* set up the matrices that will contain the return values */
mat vars=J(`totnvars',2,0)
mat rownames vars= `ivl1'  `ivl2' `ivl3' `ivl4' `ivl5' `ivl6' `ivl7' `ivl8' `ivl9' `ivl10'
mat colnames vars= xnames vnames
forvalues i=1/`totnvars' {
  mat vars[`i',1]=`varno`i''
  mat vars[`i',2]=`rowno`i''
  }

/* adjust the degrees of freedom by model type */
local asis=""
local nconst `r(factn)'
if "`nconst'"=="" {
  local nconst=1
  }
if e(cmd)=="mlogit" {
  local nconst=e(k_cat)-1
  }
else if e(cmd)=="ologit" |  e(cmd)=="oprobit"  {
  local nconst=e(k_cat)-1
  }
else if e(cmd)=="nbreg" {
  local nconst=2
  if e(rc) != 0 {
    di as error "nbreg command did not converge"
    exit 198
    }
  }
else if e(cmd)=="logistic" | e(cmd)=="logit" | e(cmd)=="probit" {
  local asis="asis"
  }

/* Number of cases of the dependent variable */
qui summ `dv' `if' `in' `wgtexp'
local totobs=r(N)

tempvar miflag
/*
capture confirm new variable miflag
if _rc!=0 {
  drop miflag
  }
qui gen miflag=0
*/

qui gen `miflag'=0

qui `cmd' `dv' `if' `in' `wgtexp' , `ops'
local bic0=-2*e(ll) - ( (e(N)-(e(df_m)+`nconst')) * ln(e(N)) )

di as text " "
di "        Missing                    *------ BIC -----*"
di "Variable Values  %    t     p          Diff.    prob."
di "-------- ------ --- ----- -----    ----------  ------"

local curvar=" "
forvalues i=1/`totnvars' {
  if "`curvar'" != "`varnam`i'" {
    local curvar="`varnam`i''"
    qui replace `miflag'=0
    qui replace `miflag'=1 if `curvar'>=.
    qui summ `miflag' if `miflag'==0 & `dv'<.
    local nobs=r(N)
    if `totobs'==`nobs' & `varno`i''==`i' {
      di as text substr("`curvar'       ",1,8) as result "      0" "   0"
      }
    if `totobs'>`nobs' {
      qui `cmd' `dv' `miflag' `if' `in' `wgtexp', `ops' `asis'
      local ndfs=e(df_m)
      if `ndfs' > 0 & "`varno`i''" == "`i'" {
        local bic=-2*e(ll) - ( (e(N)-(e(df_m)+`nconst')) * ln(e(N)) )
        local bicdiff=`bic0'-`bic'
        local pbic=1-(exp(0.5*`bicdiff')/(1+exp(0.5*`bicdiff')))
        local sb=_se[`miflag']
        local b=_b[`miflag']
        local t=`b'/`sb'
        local p=ttail(e(N)-1,abs(`b'/`sb'))*2
        local stars="   "
        if `p' <= 0.001 {
          local stars="***"
          }
        else if `p' <= 0.01 {
          local stars="** "
          }
        else if `p' <= 0.05 {
          local stars="*  "
          }
        if `nobs' == 0 {
          local stars="   "
          }
        local bicstars="   "
        if `pbic' <= 0.001 {
          local bicstars="***"
          }
        else if `pbic' <= 0.01 {
          local bicstars="** "
          }
        else if `pbic' <= 0.05 {
          local bicstars="*  "
          }
        if `nobs' == 0 {
          local bicstars="   "
          }
        local starclr="as text"
        if "`stars'" != "   "  & length("`stars'")>0 {
          local starclr="as result"
          }
        local bstarclr="as text"
        if "`bicstars'" != "   " & length("`bicstars'")>0 {
          local bstarclr="as result"
          }
        di as text substr("`curvar'       ",1,8) as result %7.0f `totobs'-`nobs' %4.0f (`totobs'-`nobs')/`totobs'*100  `starclr' %6.2f `t' %6.3f `p' %3s "`stars' " _col(36)  `bstarclr' %10.2f `bicdiff' %8.3f `pbic'  %-3s "`bicstars'   "
        }
      }
    }
  }
mat drop bs
mat drop vars

_est unhold model1

end

