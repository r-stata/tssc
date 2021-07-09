*! version 1.1 P.MILLAR 16Mar2005 (suggested by Richard Williams)
*! version 1.2 18 July 2006 mods for event history
*! Based on the approach of lrdrop1 version 1.0, developed by  Z.WANG  07Nov1999
*! This software can be used for non-commercial purposes only. 
*! The copyright is retained by the developer.
*! Copyright 2005 Paul Millar

program define bicdrop1, rclass
  version 7.0
  syntax [, Highlight(string)]

if "`e(cmd)'"=="" {
  di as error "last estimates not found"
  exit 301
  } 

/* see if the statistcally significant variables are to be highlighted */
local hlight="off"
local highlight=substr("`highlight'",1,1)
if "`highlight'" !="" {
  if "`highlight'"=="g" {
    local hlight="as text"
    }
  else if "`highlight'"=="y" {
    local hlight="as result"
    }
  else if "`highlight'"=="w" {
    local hlight="as input"
    }
  else if "`highlight'"=="r" {
    local hlight="as error"
    }
  else if "`highlight'"=="s" {
    local hlight="sigonly"
    }
  else {
    di as error "Highlight colour not allowed"
    exit 198
    }
  }
local yvar "`e(depvar)'"
local cmd="`e(cmd)'"

/* handle event history models */
if "`e(cmd)'"=="cox" {
  if "`e(cmd2)'"!="" {
    local cmd `e(cmd2)'
    local yvar
    } 
  else {
    di as text "Please use stcox instead of cox in the last model."
    exit
    }
  }
if "`e(cmd2)'"=="streg" {
  local cmd="`e(cmd2)'"
  local yvar=""
  local dist="dist(`e(cmd)')"
  if "`e(cmd)'" == "ereg" {
    local dist="dist(exponential)"
    }
  }
  
if "`e(offset)'"!="" {
  tempvar off 
  gen `off'=`e(offset)'
  lab var `off' "`e(offset)'"
  local offset offset(`off')
  }
if "`e(vcetype)'"=="robust" | "`e(vcetype)'"=="oim" | "`e(vcetype)'"=="opg" { 
  local robust="`e(vcetype)'"
  }
if "`e(clustvar)'"~="" {
  local cluster cluster(`e(clustvar)')
  }
if "`e(cmd)'"!="regress" & "`e(cmd)'"!="tobit" & substr("`e(cmd)'",1,2)!="xt" & "`e(cmd)'"!="factor" {
  local iter="iter(50)"
  }

local ops `offset' `robust' `cluster' `dist' `iter'
/* Tobit Options */
if "`e(cmd)'" == "tobit" {
  local ops `offset' `robust' `cluster' 
  if "'e(ulopt)'" != "" {
    local ops= "`ops' ul(`e(ulopt)')"
    }
  if "'e(llopt)'" != "" {
    local ops= "`ops' ll(`e(llopt)')"
    }
  } 

tempvar smpl
qui gen `smpl'=e(sample)
mat bs=e(b) 
local xnames : colnames(bs) 
if "`e(cmd)'" == "factor" {
  local xnames : rownames(e(L))
  mat bs=e(L)
  }

/* process the variable names to account for xi: or dummy variables */
local totnvars : word count `xnames'
local totnvars=`totnvars'-1
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
local nvars1=`nvars'+1
mat bicmat=J(`nvars1',1,0)
mat rownames bicmat= "fullmodel" `rn1' `rn2' `rn3' `rn4' `rn5' `rn6' `rn7' `rn8' `rn9' `rn10'
mat colnames bicmat= "BIC"
mat pdrop1=J(`nvars',1,0)
mat colnames pdrop1= "drop1_prob"
mat rownames pdrop1=  `rn1' `rn2' `rn3' `rn4' `rn5' `rn6' `rn7' `rn8' `rn9' `rn10'
mat vars=J(`totnvars',2,0)
mat rownames vars= `ivl1'  `ivl2' `ivl3' `ivl4' `ivl5' `ivl6' `ivl7' `ivl8' `ivl9' `ivl10'
mat colnames vars= xnames vnames
forvalues i=1/`totnvars' {
  mat vars[`i',1]=`varno`i''
  mat vars[`i',2]=`rowno`i''
  }

/* adjust the degrees of freedom by model type */
if "`nconst'"=="" {
  local nconst=0
  }
if e(cmd)=="mlogit" {
  local nconst=e(k_cat)-2
  }
else if e(cmd)=="ologit" |  e(cmd)=="oprobit"  {
  local nconst=e(k_cat)-2
  }
else if e(cmd)=="nbreg" {
  local nconst=2
  if e(rc) != 0 {
    di as error "nbreg command did not converge"
    exit 198
    }
  }

if substr("`e(cmd)'",1,2) == "xt" {   
  qui `cmd' `yvar' if `smpl' [`e(wtype)' `e(wexp)'], `ops' 
  local e(ll_0)="`e(ll)'"
  }

// di "`cmd' `yvar' `ivl1'  `ivl2' `ivl3' `ivl4' `ivl5' `ivl6' `ivl7' `ivl8' `ivl9' `ivl10' if `smpl' [`e(wtype)' `e(wexp)'], `ops' "

qui `cmd' `yvar' `ivl1'  `ivl2' `ivl3' `ivl4' `ivl5' `ivl6' `ivl7' `ivl8' `ivl9' `ivl10' if `smpl' [`e(wtype)' `e(wexp)'], `ops' 

local mdf0=e(df_m)+`nconst'
if length("`e(ll)'") > 0 {
  local aic0=(-2*e(ll)+2*(`mdf0'))
  local bic0=-2*e(ll) - ( (e(N)-(`mdf0')-1) * ln(e(N)) )
  local bicp0= -2*(e(ll)-e(ll_0)) + (e(df_m)*ln(e(N)))
  local dev0=-2*e(ll)
  if "`cmd'" == "cox" | "`cmd'"=="ereg" {
    local bic0=-2*e(ll) - ( (e(N_fail)-(`mdf0')-1) * ln(e(N_fail)) )
    local bicp0= -2*(e(ll)-e(ll_0)) + (e(df_m)*ln(e(N_fail)))
    } 
  }
else if length("`e(deviance)'") > 0 {
  local aic0=(e(deviance)+2*(`mdf0'))
  local bic0=e(deviance) - ( (e(N)-(`mdf0')-1) * ln(e(N)) )
  local bicp0="."
  local dev0=e(deviance)
  if "`cmd'" == "cox" | "`cmd'"=="ereg" {
    local bic0=e(deviance) - ( (e(N_fail)-(`mdf0')) * ln(e(N_fail)) )
    } 
  }    
else if length("`e(chi2_i)'") > 0 {
  local bic0=e(chi2_i) - ( (e(N)-(`mdf0')) * ln(e(N)) )
  local bicp0="."
  }  

mat bicmat[1,1]=`bic0'

local tested=index(`"regress logit logistic probit oprobit ologit mlogit nbreg poisson"', `"`cmd'"')
if `tested'==0 { di as text "not yet tested for `cmd' (may not be correct)"}

di as text "BIC Difference Tests: drop 1 term"  
local cmdname="`cmd'"
if "`cmd'"=="regress" {
  local cmdname="OLS"
  }
di as text "`cmdname' regression"
if "`cmd'" == "streg" | "`cmd'" == "stcox" {
  local addon1 = "     number of failures = "
  local addon2 = "e(N_fail)"
  }
di as text "number of obs = " as result e(N) "   " as text "`addon1'" as result `addon2'
di as text "{hline 78}"
di as text %8s "`yvar'" _col(11) " df   -2*log ll       AIC      BICprime       BIC     BICdiff  prob"
di as text "{hline 78}"
di as text "Full Model" as result _col(11) %3.0f `mdf0' %12.2f `dev0' %12.2f `aic0' %12.2f `bicp0'  %13.2f `bic0'
forvalues i=1/`totnvars' {
  forvalues j=1/10 {
    local ivl`j'=" "
    }
  local nivl=1
  forvalues j=1/`totnvars' {
    if `varno`j'' != `i' {
      local lstr=length("`ivl`nivl''")+length("``j''")
      if `lstr' > 80 {
        local nivl=`nivl'+1
        }
      if "``j''" != "_cons" {
        local ivl`nivl'="`ivl`nivl'' ``j''"
        }
      }
    }
  if `varno`i'' == `i' {
//    di "`cmd' `yvar' `ivl1' `ivl2' `ivl3' `ivl4' `ivl5' `ivl6' `ivl7' `ivl8' `ivl9' `ivl10' if `smpl' [`e(wtype)' `e(wexp)'], `ops'"
 qui `cmd' `yvar' `ivl1' `ivl2' `ivl3' `ivl4' `ivl5' `ivl6' `ivl7' `ivl8' `ivl9' `ivl10' if `smpl' [`e(wtype)' `e(wexp)'], `ops'
    local mdf=e(df_m)+`nconst'
    if length("`e(ll)'") > 0 {
      local aic=(-2*e(ll)+2*(`mdf'))
      local bic=-2*e(ll) - ( (e(N)-(`mdf')-1) * ln(e(N)) )
      local bicp= -2*(e(ll)-e(ll_0)) + (e(df_m)*ln(e(N)))
      local dev=-2*e(ll)
      if "`cmd'" == "cox" | "`cmd'"=="ereg" {
        local bic=-2*e(ll) - ( (e(N_fail)-(`mdf0')) * ln(e(N_fail)) )
        local bicp= -2*(e(ll)-e(ll_0)) + (e(df_m)*ln(e(N_fail)))
        }
      }
    else if length("`e(deviance)'") > 0 {
      local aic=(e(deviance)+2*(`mdf'))
      local bic=e(deviance) - ( (e(N)-(`mdf')) * ln(e(N)) )
      local bicp="."
      local dev=e(deviance)
      if "`cmd'" == "cox" | "`cmd'"=="ereg" {
        local bic=e(deviance) - ( (e(N_fail)-(`mdf')) * ln(e(N_fail)) )
        local bicp=(e(deviance)-e(ll_0)) + (e(df_m)*ln(e(N_fail)))
        }
      }
    else if length("`e(chi2_i)'") > 0 {
      local aic=.
      local bic=e(chi2_i) - ( (e(N)-(`mdf')) * ln(e(N)) )
      local bicp=.
	  }
    local chi=`dev' - `dev0'
    local df = `mdf0'-`mdf'
    local p = chiprob(`df',`chi')
    local bicdiff=`bic'-`bic0'
    local pval=1-exp(0.5*`bicdiff')/(1+exp(0.5*`bicdiff'))
    if `bicdiff' > 1000 {
      local pval=0
      }
    mat bicmat[`rowno`i''+1,1]=`bic'
    mat pdrop1[`rowno`i'',1]=`pval'
    local varclr="as text"
    local numclr="as result"
    if "`hlight'" == "sigonly" {
      local numclr="as text"
      }
    if ("`hlight'" != "off") & (`pval' <.05 ) {
      local varclr="`hlight'"
      local numclr="`hlight'"
      if "`hlight'" == "sigonly" {
        local varclr="as result"
        local numclr="as result"
        }
      }
    if "`cmd'" == "nbreg" & "`e(rc)'" != "0" {
      di "Model did not converge"
     }
    else {
      local vname=substr("`varnam`i''",1,7)
      if ~("`vname'" == "_t" & ("`cmd'" == "cox" | "`cmd'" == "ereg")) { 
        di `varclr' " -" %-7s "`vname'" `numclr'  _col(10) " " _col(11) %3.0f `mdf'/*
          */  %12.2f `dev'  %12.2f `aic'  %12.2f `bicp'  %13.2f `bic' " "  %8.1f `bicdiff' " " %6.3f `pval'
        }
      }
    }
  } 

di as text "{hline 78}"
di as text "Terms dropped one at a time in turn."

/* restore the original ereturn values */
forvalues i=1/10 {
  local ivl`i'=" "
  }
local nivl=1
forvalues i=1/`nvars' {
  local varname="``i''"
  local lstr=length("`ivl`nivl''")+length("`varname'")
  if `lstr' > 80 {
    local nivl=`nivl'+1
    }
  if "`varname'" != "_cons" {
    local ivl`nivl'="`ivl`nivl'' `varname'"
    }
  }
qui `cmd' `yvar' `ivl1' `ivl2' `ivl3' `ivl4' `ivl5' `ivl6' `ivl7' `ivl8' `ivl9' `ivl10' if `smpl', `ops'

return matrix prob  pdrop1
return matrix varnum  vars
return matrix bic  bicmat
return local xnames `xnames'
return local vnames `rn1' `rn2' `rn3' `rn4' `rn5' `rn6' `rn7' `rn8' `rn9'  `rn10'
return local cmd "`cmd'"
return local depvar "`yvar'"
return local smpl `smpl'
return local options="`ops'"
return local wgtexp="[`e(wtype)' `e(wexp)']"
return local totnvars `totnvars'
return local nvars `nvars'
return local bicfull `bic0'
return local nconst `nconst'

end
