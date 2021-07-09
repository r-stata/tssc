*! Date    : 19 Mar 2004
*! Version : 1.06
*! Author  : Adrian Mander
*! Email   : adrian.p.mander@gsk.com

prog def swblock
version 8.0
syntax [varlist] [, Noise Stop MV(string) Pvalue(real 0.05) ACC(real 0.0001) IPFacc(real 0.0000001) START STORE REPLACE SM(integer 0)]

if "`mv'"=="" local mv "mv"

di in smcl as text  "{hline}"
di as text "Significance level for inclusion :", as res `pvalue'
di as text "HAPIPF likelihood accuracy       :", as res `acc'
di as text "IPF    likelihood accuracy       :", as res `ipfacc'
di as text _continue "Missing data is assumed to be    : "
if "`mv'"=="mvdel" di  as res "MCAR"
else di as res "MAR"
di in smcl as text  "{hline}"

local i:list sizeof varlist
if mod(`i',2)==1 {
   di as error "You have not got an even number of variables!"
   exit(198)
}
local nloc = `i'/2

if "`store'"~="" {
  preserve
  qui drop _all
  qui set obs 0
  qui gen str50 model=""
  qui gen double lpv =.
  qui gen double lchi=.
  qui gen ldf=.
  qui gen df=.
  qui gen double llhd=.
  qui g pctmiss=.
  qui gen str5 miss=""
  qui gen str40 modelc=""
  qui gen str70 vlist=""
  qui g acchap = `acc'
  qui g accipf = `ipfacc'
  qui save fresults, `replace'
  restore
}

local fi 1
local sipf "l1"
forv i=2/`nloc' { /* Loop of the models to be fitted */
  local sipf "`sipf'+l`i'"
}
di as text "Start Model (complete LE)", as res "`sipf'"

qui hapipf `varlist', `mv' ipf(`sipf') model(0) nolog quiet acc(`acc') ipfacc(`ipfacc') `start' savew(sweight)

if "`store'"~="" {
  preserve
  use fresults,replace
  qui set obs `fi'
  qui replace model = "`sipf'" in `fi'
  qui replace modelc = "" in `fi'
  qui replace df = $hapdf0 in `fi'
  qui replace llhd = $hapllhd0 in `fi'
  qui replace vlist = "`varlist'" in `fi'
  qui replace miss = "`mv'" in `fi'
  qui replace pctmiss = `r(nmiss)'/`r(N)' in `fi'
  qui replace acchap = `acc'
  qui replace accipf = `ipfacc'
  qui save fresults,replace
  local `fi++'
  restore
}

/* Given the start model go through deciding the best model by adding one + */

local bestmod "`sipf'"

/* First step is to add in all pairwise comparisons */

_binary `nloc'
forv i=2/`nloc' {
  local term`i' `r(mod`i')'
}

local fi 2


forv i=2/`nloc' {
  di in smcl as text  "{hline}"
  if length("`bestmod'")<50  di as text "Fitting order", as res  `i', as text "LD terms" as text "   Current Best =" as res "`bestmod'" 
  else {
    di as text "Fitting order", as res `i', as text "LD terms" 
    di as text "Current Best (CB) =", as res "`bestmod'" 
  }
  if "`orderpbest'"=="`bestmod'" { 
    if "`stop'"~="" {
      di as error "The current best model has not changed and no further terms will be fitted "
      di in smcl as text "{hline}"
      exit
    }
    else di as error "The current best model has not changed" 
  }
  local orderpbest "`bestmod'"
  di in smcl as text "{hline}"
 
  local cbestmod ""
  local besterm ""
  local mstart 0
  while "`bestmod'"~="`cbestmod'" {
    /* Do not refit the best term */
    if "`besterm'"~="" {
      local temp ""
      foreach tt of local term`i' {
        if "`tt'"~="`besterm'" local temp "`temp' `tt'" 
      }
      local term`i' "`temp'" 
      local besterm ""
    }
    if "`cbestmod'"~="" {
      local bestmod "`cbestmod'"
      qui copy cweight.dta sweight.dta ,replace
    }
     if `mstart' {
       di in smcl as text "{hline}"
       if length("Current Best (CB) = `bestmod'")<85  di as text "Current Best =" as res "`bestmod'" 
       else { 
         di as text "Current Best (CB) ="
         di as res "`bestmod'"
       }
       di in smcl as text "{hline}"
     }
     local mstart 1

    /* FIT each term of the order i interaction*/
    local j 1
    local best 0
    local maxpv 1

/*a dbug*/ 
    local whichm 0

    foreach term of local term`i' {

      /* Fit model compare to best model */    
      local model "`bestmod'+`term'"

      /* Must try and make the model term smaller */
      _simple `model'
      local model "`r(smod)'"

      local whichm = `whichm'+1
      if `whichm'>`sm'{
        hapipf `varlist', `mv' model(`j') ipf(`model') lrtest(`j',0) nolog quiet noprint acc(`acc') ipfacc(`ipfacc') usew(sweight) savew(tweight)
      }
      local root "hapmod`j'"
      local root2 "hapdf`j'"
      local root3 "hapllhd`j'"

      if `whichm'>`sm' {
       if `r(lrtpv)' <`pvalue' & `r(lrtpv)'<0.00001 di _continue as inp "*** p=", %7.5f `r(lrtpv)'  
       if `r(lrtpv)' <`pvalue' & `r(lrtpv)'>=0.00001 & `r(lrtpv)'<0.01 di _continue as res "**  p=", %7.5f `r(lrtpv)'  
       if `r(lrtpv)' <`pvalue' & `r(lrtpv)'>=0.01    & `r(lrtpv)'<`pvalue'  di _continue as res "*   p=", %7.5f `r(lrtpv)' 
       if `r(lrtpv)' >=`pvalue' di _continue as text "    p=", %7.5f `r(lrtpv)' 

       if "`noise'"~=""  di _continue " chi(`r(lrtdf)')=", %7.3f `r(lrtchi)' 
       di as text "  $`root'"
       local pv`j' = `r(lrtpv)'
       local chi`j' = `r(lrtchi)'
      }
      else {
        di as text "  $`root'"
        local pv`j' = 0.1
        local chi`j' 1
      }
   
      /* Check if this model is better than the current best*/
      if `pv`j''<`maxpv' & `pv`j''<`pvalue' {
        local maxpv `pv`j''
        local cbestmod "`model'"
        local besterm "`term'"
        local best `j'
        qui copy tweight.dta cweight.dta, replace
      }

      if "`store'"~="" {
        preserve
        use fresults,replace
        qui set obs `fi'
        qui replace model = "`model'" in `fi'
        qui replace modelc = "$hapmod0" in `fi'
        qui replace lpv=`r(lrtpv)' in `fi'
        qui replace lchi=`r(lrtchi)' in `fi'
        qui replace ldf=`r(lrtdf)' in `fi'
        qui replace df = $`root2' in `fi'
        qui replace llhd = $`root3' in `fi'
        qui replace vlist = "`varlist'" in `fi'
        qui replace miss = "`mv'" in `fi'
        qui replace pctmiss = `r(nmiss)'/`r(N)' in `fi'
        qui replace acchap = `acc'
        qui replace accipf = `ipfacc'
        qui save fresults,replace
        local `fi++'
        restore
      }
      local `j++'
    }

    if "`cbestmod'"==""  local cbestmod "`bestmod'" 

    local root1 "hapdf`best'"
    local root2 "hapmod`best'"
    local root3 "hapllhd`best'"
    global hapdf0 "$`root1'"
    global hapmod0 "$`root2'"
    global hapllhd0 "$`root3'"

  }

}

di in smcl "{hline}"
di as text "The parsimonious model is", as res "$`root2'"
di as text in smcl "{hline}"

if "`store'"~="" {
  preserve
  use fresults
  qui compress
  save fresults,replace
  restore
}

end

/* Get all the models terms to fit in terms of order */

prog def _binary, rclass
args nloc

local max=2^`nloc'-1

forval i=1/`max' {
  local num `i'
  local pbin ""
  local fact =2^(`nloc'-1)
  local ind 1
  local noones 0
  while `fact'>1 {
    if `num'>=`fact' {
      if "`pbin'"=="" local pbin "l`ind'" 
      else local pbin "`pbin'*l`ind'" 
      local num = `num'-`fact'
      local `noones++'
    }
    local fact = `fact'/2
    local `ind++'
  }
  if `num'==1 {
   if "`pbin'"=="" local pbin "l`ind'"
   else local pbin "`pbin'*l`ind'"
   local `noones++'
  }
 
  local mod`noones' "`mod`noones'' `pbin'"
  return local mod`noones' "`mod`noones''"
}
end 

/* Simplify model */

prog def _simple,rclass
args model
tokenize `model', p("+")

local tlist ""
while "`1'"~="" {
  if "`1'"~="+"  local tlist "`tlist' `1'" 
  mac shift 1
}
local nlist " `tlist'"

foreach term of local tlist {
  if index("`term'","*")~=0 {
    local vlist " "
    tokenize `term', p("*")
    while "`1'"~="" {
      if "`1'"~="*" local vlist "`vlist' `1'" 
      mac shift 1
    }
    _bin2 "`vlist'"
    local temp "`r(mod)'"
    local delterm : subinstr loc temp "`term'" " "
    foreach dterm of local delterm {
      local temp " `nlist'"
      local nlist: subinstr loc temp " `dterm' " " "
    }
  }
}

local rlist ""
foreach nt of local nlist {
  if "`rlist'"==""  local rlist "`nt'" 
  else local rlist "`rlist'+`nt'"
}

return local smod "`rlist'"

end

/* Get all the terms in a x*y*.. model */

prog def _bin2, rclass
args loc

local nloc:word count `loc'

local max=2^`nloc'-1

forval i=1/`max' {
  local num `i'
  local pbin ""
  local fact =2^(`nloc'-1)
  local ind 1
  while `fact'>1 {
    if `num'>=`fact' {
      if "`pbin'"=="" { 
        local t:word `ind' of `loc'
        local pbin "`t'" 
      }
      else {
         local t:word `ind' of `loc'
         local pbin "`pbin'*`t'" 
      }
      local num = `num'-`fact'
    }
    local fact = `fact'/2
    local `ind++'
  }
  if `num'==1 {
   if "`pbin'"=="" {
     local t:word `ind' of `loc'
     local pbin "`t'" 
   }
   else {
     local t:word `ind' of `loc'
     local pbin "`pbin'*`t'" 
   }
  }
 
  local mod "`mod' `pbin'"
  return local mod "`mod'"
}

end 
