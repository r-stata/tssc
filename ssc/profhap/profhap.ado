*! Date    : 24 Mar 2005
*! Version : 1.24
*! Author  : Adrian Mander
*! Email   : adrian.p.mander@gsk.com

*! A program to obtain a profile likelihood estimate of an odds ratio
*! from the EM algorithm

program define profhap, rclass
version 8.0
syntax varlist(min=2) [if], OR(string) ipf(string) [ BY(string) STRata(string) ACC(real 0.5) DIOR(string) LEVel(real 0.05) QUIet LI UI GRAPH NOCI DEBUG NOISE ORSTRata(string) HAPACC(real 0.0000001) SAVECON SAVEGRAPH MV MVDEL]

/* IF program crashes.. you need to still do a postclose to rerun this.. */
cap postclose ade

tempfile master efreqs efreqs1
qui save "`master'",replace

/* Check to see if the ipf model contains independence.. crude test of syntax */
if index("`ipf'","+") ==0 {
  di as error "There is no + in `ipf'"
  di as text "Check the help file for profhap....
  di "the model you put in ipf() generally makes the OR of interest = 1"
  di "i.e. INDEPENDENT"
  di "The OR of interest is actually fitted using constraint files see hapipf for more information"
  exit(198)
}


/* if dior isnt specfied then it takes the first two arguments of or */

if "`if'"~="" keep `if'
if "`dior'"=="" {
  tokenize "`or'"
  local dior "`1' `2'"
}

/*********************************************
 * Pair the data from the varlist
 *********************************************/

global all_name = "`varlist'"
global nloc 0

di
tokenize "`varlist'"
while "`1'"~="" {
  if "`2'"==""  di as error "There must be paired data" 
  global nloc =$nloc+1
  local wc1=2*$nloc-1
  local wc2=`wc1'+1
  local root1: word `wc1' of $all_name
  local root2: word `wc2' of $all_name
  if "`quiet'"=="" {
    local len = length("Alleles at marker $nloc are contained in variables (`root1' `root2')")
    di as text "Alleles at marker $nloc are contained in variables (`root1' `root2')"
    di in smcl "{dup `len':{c -}}"
  }
mac shift 2
}

local nloc = $nloc

if "`nloc'"~="1" local haptext "Haplotype" 
else local haptext "   Allele" 

tempfile start constr
qui save "`start'",replace

/*************************************************
 * The odds ratio of interest is defined by
 * two haplotypes one haplotype being exposed
 * and the other unexposed. The case and control
 * variable must also be used!
 *************************************************/

tokenize "`or'"
local cc "`1'"
local loci1 "`2'"
local loci2 "`3'"

/**********************************************************
 * calculate the exposed haplotype in an if statement
 * note that cases are when cc is 1 and controls are cc=0
 **********************************************************/

local exhap "`3'"
local exphap "`3'"
local ifcon " "

tokenize "`varlist'"
forval i=1/$nloc {
  local len = index("`exhap'",".")-1
  if `i'==$nloc {
    if `i'==1 local ifcon "l`i'==`exhap'"
    else  local ifcon "`ifcon' & l`i'==`exhap'" 
    local exall "`exhap'"
  }
  else {
    if `i'==1 local ifcon ="`ifcon' l`i'=="+substr("`exhap'",1,`len')
    else local ifcon ="`ifcon' & l`i'=="+substr("`exhap'",1,`len')
    local exall = substr("`exhap'",1,`len')
    local len2 = index("`exhap'",".")+1
    local exhap = substr("`exhap'",`len2',.)
  }
    
  local v1= 2*(`i'-1)+1
  local v2= 2*`i'
  qui count if ``v1''==`exall' | ``v2''==`exall'
  if `r(N)'==0 {
    di as error "the exposure allele `exall' isnt observed for var ``v1'' or ``v2''"
    di as error "CHANGE: or() option"
    exit(198)
  }
    
}

local ifcon "`cc'==1 & `ifcon'"

if "`debug'"~=""  di "The if statement for the exposed cases = `ifcon'" 

/************************************************
 * Now create the constraints file
 ************************************************/
  
drop _all
qui set obs 2
qui gen `cc'=0
qui gen str70 locus=cond(_n==1,"`loci1'","`loci2'")

/**************************************************
 * Now I want to include many more odds ratios so
 * that these can all be included in the constrain
 * file
 **************************************************/

tokenize "`or'"

local nobs = _N
while "`4'"~="" {
  local nobs=`nobs'+1
  set obs `nobs'
  replace caco=0 in `nobs'
  replace locus="`4'" in `nobs'
  mac shift 1
}

qui compress
local i 1
local vlist " "
qui qui gen str70 plocus = locus
while `i'<=$nloc {
   qui gen len = index(plocus,".")-1
   qui gen l`i'=real(substr(plocus,1,len))
   if `i'==$nloc  qui replace l`i'=real(plocus) 
   else { 
     qui gen len2 = index(plocus,".")+1
     qui replace plocus=substr(plocus,len2,.) 
   }
   drop len
   cap drop len2
   local vlist "`vlist' l`i'"
   local `i++'
}
drop plocus

gen double Efreqold=1
qui expand 2
sort locus
qui replace `cc'=1 if mod(_n,2)==0

drop locus
local convars "`vlist' `cc'"

/*****************************************************************
 * look at the strata information
 *
 * Should be an option say strat 0 1 2 3 and the file should be
 * expanded by 4 lines each line containing 0 1 2 3 
 *****************************************************************/

if "`strata'"~="" {
  tokenize "`strata'"
  local macno=1
  while "``macno''"~="" {

  /* Generate a line number so only one line is added per levels of the haps and caco. */

    gen long lineno1=_n
    
    local macvar "``macno''"
    local convars "`convars' `macvar'"
    local contmac 1
    if "`contmac'"=="1" {
      local macno = `macno'+1
      di "what is in `macno'"
      confirm number ``macno''
      di "gen `macvar'=``macno''"
      gen `macvar'=``macno''
      local contmac 2
    }
    while "`contmac'"=="2" {
      local macno = `macno'+1
         
      cap confirm number ``macno''
      if _rc~=0 local contmac 0
      else {
        sort lineno1 `macvar'
        qui by lineno1: gen long expand= (_n==1)+1
        qui expand expand
        sort lineno1 `macvar'
        qui by lineno1: replace `macvar'=``macno'' if _n==1
        drop expand
      }
    }
    drop lineno1
  }
}


/************* display the constraints file  */

di as text "The constraints file looks like this"
di "the variables are :" as res "`convars'"

qui replace Efreqold=. if `ifcon'
list, noobs

di
di as text "NOTE: the . represents the cells that change within the profile likelihood"


sort `convars'
qui save "`constr'",replace

if "`savecon'"~="" qui save confile,replace 

/**********************************************
 * Fit the model first and get a point est of
 * the OR
 *
 * make a postfile :) for the oddsratios and
 * the llhd
 **********************************************/
  
qui use "`start'",replace
di "starting initial model estimation....."

if "`noise'"~="" hapipf `varlist' using "`efreqs'", ipf(`ipf')  convars(`convars') confile(`constr') acc(`hapacc') ipfacc(`hapacc') noise start `mv' `mvdel'
else  hapipf `varlist' using "`efreqs'", ipf(`ipf')  convars(`convars') confile(`constr') acc(`hapacc') ipfacc(`hapacc') nolog start `mv' `mvdel'

if "`noise'"~="" {
   if "`by'"=="" dior using "`efreqs'", or(`dior') locus(locus) caco(`cc') nopre  
   else dior using "`efreqs'", or(`dior') by(`by') locus(locus) caco(`cc')  nopre 
}
else {
   if "`by'"==""  dior using "`efreqs'", or(`dior') locus(locus) caco(`cc')  nopre 
   else dior using "`efreqs'", or(`dior') by(`by') locus(locus) caco(`cc') nopre  
}

qui local mlelhd=$loglik

gen thison = locus~="`exphap'"
sort thison

if "`orstrata'"~="" {
   tokenize "`orstrata'"
   local orstif " `1'~=`2'"
   mac shift 2
   while "`1'"~="" {
     local orstif "`orstif' | `1'~=`2'"
     mac shift 2
   }
   gen thisone= `orstif'
   sort thison thisone
}
                     
qui local mleor = or[1]

tempfile results
postfile ade or llhd using "`results'"
post ade (`mleor') (`mlelhd')

if "`quiet'"=="" {
  di
  di as res "The estimate of the OR is `mleor'"
  di as res "The loglikelihood is `mlelhd' "
}

local exca = exca[1]
local exco = exco[1]
local uxca = uexca[1]
local uxco = uexco[1]

local diff = invchi2(1,(1-`level'))

if "`debug'"~="" {
  qui use "`constr'",replace
  qui replace Efreqold=`mleor' if `ifcon'
  qui save "`constr'"  ,replace                               

  qui use "`start'",replace
  hapipf `varlist' using "`efreqs'", ipf(`ipf') convars(`convars') confile(`constr') nolog acc(`hapacc') ipfacc(`hapacc') `mvdel' `mv'
  if "`noise'"~="" {
    if "`by'"=="" dior using "`efreqs'", or(`dior') locus(locus)  caco(`cc') nopre  
    else dior using "`efreqs'", or(`dior') by(`by') locus(locus)  caco(`cc')   nopre
  }
  else {
     if "`by'"=="" dior using "`efreqs'", or(`dior')  locus(locus)  caco(`cc')  nopre  
     else dior using "`efreqs'", or(`dior') by(`by') locus(locus)  caco(`cc')   nopre 
  }
qui use "`master'",replace
exit
}

if "`noci'"=="" {
  if "`li'"=="" {

/**********************************************
 * Given the mle I shall work up to the
 * upper CI
 **********************************************/

/* First of all try and find the starting value for out. */

    if "`quiet'"=="" {
      local len=length("Calculation of the upper confidence interval to the nearest `acc'")
      di in smcl as text "{c TLC}{dup `len':{c -}}{c -}{c TRC}"
      di in smcl "{c |}Calculation of the upper confidence interval to the nearest `acc' {c |}"
      di in smcl as text "{c BLC}{dup `len':{c -}}{c -}{c BRC}"
    }
    local out = `mleor'*2
    local in = `mleor'

    local conv 0
    while `conv'==0 {
      local mid = `out'
      if "`quiet'"==""  di as res _continue "Calculating llhd at `mid' = " 

      qui use "`constr'",replace
      qui replace Efreqold=`mid' if `ifcon'
      qui save "`constr'"  ,replace                               

      qui use "`start'",replace
   
      qui hapipf `varlist' using "`efreqs1'", ipf(`ipf') convars(`convars' ) confile(`constr') display nolog  `mvdel' `mv' 
      if "`noise'"~="" {
        if "`by'"==""  dior using "`efreqs1'", or(`dior') locus(locus)  caco(`cc')   nopre
        else dior using "`efreqs1'", or(`dior') by(`by')  locus(locus) caco(`cc')   nopre 
      }
      else {
        if "`by'"==""  qui dior using "`efreqs1'", or(`dior')  locus(locus)  caco(`cc')  nopre  
        else  qui dior using "`efreqs1'", or(`dior') by(`by') locus(locus)  caco(`cc')   nopre 
      }

      post ade (`mid') ($loglik)

      if "`quiet'"=="" di "$loglik" 

      if (`lastlhd'-$loglik)<0.0000000001 {
         di as error "WARNING: Likelihood hasn't changed!"
         di as error "Make sure there is independence between outcome and haplotypes in the ipf() option"
      }
      local lastlhd "$loglik"
     
      if 2*(`mlelhd'-$loglik)>`diff' {
        local out = `mid'
        local in = `mid'/2
        local conv 1
      }
      else local out=`out'*2
    }

    local conv 0
    while `conv'==0 {
      local mid=(`in'+`out')/2

      if "`quiet'"=="" di as res _continue "Calculating llhd at `mid' = " 
      qui use "`constr'",replace
      qui replace Efreqold=`mid' if `ifcon'
      qui save "`constr'"  ,replace                               

      qui use "`start'",replace
      qui hapipf `varlist' using "`efreqs1'", ipf(`ipf') convars(`convars') display confile(`constr') nolog `mvdel' `mv'

      if "`noise'"~="" {
        if "`by'"==""  dior using "`efreqs1'", or(`dior') locus(locus) caco(`cc')   nopre 
        else dior using "`efreqs1'", or(`dior') by(`by') locus(locus)  caco(`cc')   nopre 
      }
      else {
        if "`by'"==""  qui dior using "`efreqs1'", or(`dior') locus(locus)   caco(`cc')  nopre  
        else qui dior using "`efreqs1'", or(`dior') by(`by') locus(locus)  caco(`cc')  nopre  
      }

      post ade (`mid') ($loglik)

      if "`quiet'"==""  di "$loglik" 



      if 2*(`mlelhd'-$loglik)>`diff'  local out = `mid'
      else  local in = `mid' 

      if abs(`in'-`out')< `acc'  local conv 1 
    }

    if "`quiet'"==""  di "Upper CI is `mid'" 

    local uci=`mid'
    return scalar uci=`mid'

    if "`li'"=="" {

/**********************************************
 * Given the mle   I shall work up to the
 * lower CI
 **********************************************/

/* First of all try and find the starting value for out. */

      if "`quiet'"=="" {
        local len=length("Calculation of the lower confidence interval to the nearest `acc'")
        di in smcl as text "{c TLC}{dup `len':{c -}}{c -}{c TRC}"
        di in smcl "{c |}Calculation of the lower confidence interval to the nearest `acc' {c |}"
        di in smcl as text "{c BLC}{dup `len':{c -}}{c -}{c BRC}"
      }

      local oldout = `mleor'
      local out = `mleor'/2
      local in = `mleor'

      local iter 2
      local conv 0
      while `conv'==0 {
        local mid = `out'
        if "`quiet'"==""  di as res _continue "Calculating llhd at `mid' = " 

        qui use "`constr'",replace
        qui replace Efreqold=`mid' if `ifcon'
        qui save "`constr'"  ,replace                               

        qui use "`start'",replace
        qui hapipf `varlist' using "`efreqs1'", ipf(`ipf') convars(`convars') confile(`constr') nolog display `mvdel' `mv'

        if "`noise'"~="" {
          if "`by'"==""  dior using "`efreqs1'", or(`dior') locus(locus)  caco(`cc')   nopre 
          else dior using "`efreqs1'", or(`dior') by(`by') locus(locus)  caco(`cc')   nopre 
        }
        else {
          if "`by'"==""  qui dior using "`efreqs1'", or(`dior') locus(locus)   caco(`cc')  nopre  
          else  qui dior using "`efreqs1'", or(`dior') by(`by') locus(locus)  caco(`cc')   nopre 
        }
        post ade (`mid') ($loglik)

        if "`quiet'"=="" di "$loglik" 
        if 2*(`mlelhd'-$loglik)>`diff' {
          local out = `mid'
          local in = `oldout'
          local conv 1
        }
        else {
          local oldout = `out'
          local out=`out'/`iter'
          local iter=`iter'+1
          if (`oldout'-`out')<`acc'  local conv 2 
        }
      }
      if `conv' ~=2 {
  
        local conv 0
        while `conv'==0 {
          local mid=(`in'+`out')/2
          if "`quiet'"==""  di as res  _continue "Calculating llhd at `mid' = " 

          qui use "`constr'",replace
          qui replace Efreqold=`mid' if `ifcon'
          qui save "`constr'"  ,replace                               

          qui use "`start'",replace
          qui hapipf `varlist' using "`efreqs1'", ipf(`ipf') convars(`convars' ) display confile(`constr') nolog `mvdel' `mv'
          if "`noise'"~="" {
            if "`by'"==""  dior using "`efreqs1'", or(`dior') locus(locus)  caco(`cc')  nopre  
            else   dior using "`efreqs1'", or(`dior') by(`by')  locus(locus) caco(`cc')  nopre  
          }
          else {
            if "`by'"==""  qui dior using "`efreqs1'", or(`dior') locus(locus)   caco(`cc')  nopre  
            else  qui dior using "`efreqs1'", or(`dior') by(`by') locus(locus)  caco(`cc')  nopre  
          }

          post ade (`mid') ($loglik)
          if "`quiet'"==""  di "$loglik" 

          if 2*(`mlelhd'-$loglik)>`diff'      local out = `mid'
          else  local in = `mid' 

          if abs(`in'-`out')< `acc'  local conv 1 
        }
      }
    }
    if "`quiet'"=="" di as res "Lower CI is `mid'" 

    return scalar lci = `mid'
  } /* end of ui if statement */
} /* end of noci if statement */

return scalar max = `mleor'

di
di in smcl as text "{col 15}Case-control table"
di in smcl as text "{col 15}{dup 18:{c -}}"

di in smcl "{col 27}Cases{col 40}Controls"
local tmp1 = string(`uxca',"%7.4f")
local tmp2 = string(`uxco',"%7.4f")
di in smcl as res "`haptext's{col 12}{ralign 10:`loci1'}{col 25}{ralign 8:`tmp1'}{col 40}{ralign 8:`tmp2'}"
local tmp1 = string(`exca',"%7.4f")
local tmp2 = string(`exco',"%7.4f")
di in smcl as res "{col 12}{ralign 10:`loci2'}{col 25}{ralign 8:`tmp1'}{col 40}{ralign 8:`tmp2'}"
di
local levci = 100*(1-`level')
di " OR  =  ", %6.4f `mleor',"with `levci'% CI interval (" %6.4f `mid',"," %6.4f `uci',")"
di
         
postclose ade

if "`graph'"~="" {
  qui use "`results'",replace
  label variable or "Odds-ratio"
  label variable llhd "Log-likelihood"
  if "`savegraph'"~="" twoway connected llhd or,  saving(profile,replace) sort
  else twoway connected llhd or, sort
}

qui use "`master'",replace
end

